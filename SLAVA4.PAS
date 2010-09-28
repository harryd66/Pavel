{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}

{$I Compile.INC}


unit Slava4;

Interface

Uses Dialogs,Drivers,ServStr,MyCalc,Nastr,Glob;

Procedure CalcMenedgerOtgruz(Filtr,Oplata:Word;StartDate,StopDate:TDatestring;P:PBox);
Procedure CalcMenedger2(Const Client,Agent:PBox; Filtr,Oplata:Word;StartD,StopD:TDateString;
OpSel : Word);

Procedure CreatRouteReport;

{Procedure CalcMenedgerOtgruz(Filtr,Oplata:Word;StartDate,StopDate:TDatestring;P:PBox);}


Implementation

uses Objects, Views, MsgBox,Vision3,Validate,Access,Access3,
     DBEngine,TPDate,Vision1,Vision4,Vision2,Slava2,ServStr2,
     Tools,Prise,App, Serv, ColorTxt,Protect,Utils5,Utils4,
     Prihod,Return,NetDbEng,Printers,Net,Utils,Utils1;

{Const ReadOnly=0;}

{VAr PostList : PBox;}
Var
     OldFileMode : Word;



Procedure CalcMenedgerOtgruz(Filtr,Oplata:Word;StartDate,StopDate:TDatestring;P:PBox);
Var f : MarketFileType;
    E : PSuperMarketType;
    Er : PRealizasiaType;
    Ef : File Of RealizasiaType;
    l : Word;

    Delta,DateOpl,Date : TDAteString;
    NDS,z,AllSkidka,AllItogo,Skidka,ItogoSkidka,Itogo : Float;
    AllReturn,AllSkidkaReturn:Float;
    s : TMyString;
    Adress,Dogovor : AllStr;
    ws : AllStr;
    txt1 : Text;
    Res,AllDoc : Word;
    Space : String [CAll];
    c : Word;

    Doc,AllReturnDoc,RAbday,StartL,StopL,Den : LongInt;
    mm:Maska9;
    ss:Maska2;
    Find,Add : Boolean;
    BakFileMode : Word;

Begin

 StartL:=DateStringToDate(DateMask,StartDate);
 StopL:=DateStringToDate(DateMask,StopDate);

 Space:='  ';


 Assign(Txt1,Path^.Dat.ToTemp+'cmengotg.txt');
 l:=IOResult;
 Rewrite(Txt1);
 l:=IOResult;
 If L <> 0 Then
  Begin
   MessageBox(#3^M+#3'Не могу создать файл отчета'+Path^.Dat.ToTemp+'cmengotg.txt',Nil,mfError+mfCancelButton);
   Exit;
  End;



Writeln(txt1,header+Space+'Склад: '+FormKod(Rek^.Dat.Kod)++'  Оператор: '+CurrentPassword+headerStop);
Writeln(txt1);
 Writeln(txt1,Space+'Включены в рассмотрение следующие виды документов:');
 Write(txt1,Space);

 WordTobit9(Filtr,mm);
 Convert9(mm);

 WordToBit2(Oplata,ss);
 Convert2(ss);

 For c:=1 To Max9 Do
  Begin
   If mm[c]=1 Then
    Case c Of
    1:Write(txt1,' "Список"');
    2:Write(txt1,' "Тов.Чек*"');
    3:Write(txt1,' "Физ.Л*"');
    4:Write(txt1,' "СФ*"');
    5:Write(txt1,' "СФ Б"');
    6:Write(txt1,' "Дебит*"');
    7:Write(txt1,' "Дебит СФ*"');
    8:Write(txt1,' "Дебит"');
    9:Write(txt1,' "Дебит СФБ"');
    Else;
    End;
  End;
 Writeln(txt1);
 Writeln(txt1);

 Writeln(txt1,Space+'Включены в рассмотрение документы со статусом:');
 Write(txt1,Space);
 For c:=1 To 2 Do
  Begin
   If ss[c]=1 Then
    Case c Of
    1:Write(txt1,' "Оплаченные"');
    2:Write(txt1,' "Не оплаченные"');
    Else;
    End;
  End;
 Writeln(txt1);
 Writeln(txt1);

Writeln(txt1,header+Space,'     СПРАВКА ПО ОТГРУЗКЕ ЗА ПЕРИОД с '+StartDate+' по '+StopDate);
Writeln(txt1,Space+'┌──┬────────────────────┬───┬────────┬─────────────┬─────────────┬─────────────┬────────┐');
Writeln(txt1,Space+'│N │Клиент              │Док│Дата отг│Сумма отгруз.│ Сумма скидки│ Сумма к опл.│   Вид  │');
Writeln(txt1,Space+'└──┴────────────────────┴───┴────────┴─────────────┴─────────────┴─────────────┴────────┘'+headerStop);
                   {123 12345678901234567890 123 12345789 1234567890123 1234567890123 1234567890123 Дебит СФБ}

AllItogo:=0;
AllSkidka:=0;
AllDoc:=0;

Itogo:=0;
Skidka:=0;
Doc:=0;

DInfoMsg('Идет формирование раскладки по дням...',True);
New(E,Init);


For Den:=StartL To StopL Do
Begin
 Date:=DateToDateString(DateMask,DEn);
 Assign(F,Path^.Dat.ToMarket+Date+'.mrk');
 l:=IOResult;
 OldFileMode:=FileMode;
 FileMode:=ReadOnlyN;
 Reset(f);
 l:=Ioresult;
{
 If L <> 0 Then
  Begin
   MessageBox(#3^M+#3'Не найден файл '+Path^.Dat.ToMarket+Date+'.mrk',Nil,mfError+mfCancelButton);
  End;
}
 FileMode:=OldFileMode;
If l=0 Then
 Begin

Itogo:=0;
Skidka:=0;
Doc:=0;
  While Not (Eof(f)) Do
   Begin
      ReadMArket(f,E);
If (E^.Dat.Active) And (E^.Dat.OperatorSelector=0) Then
If (E^.Dat.DocSelector in [5,6,7,8]) Or
   ( Not(E^.Dat.Realiz) And (E^.Dat.DocSelector in [0,1,2,3,4])) Then
If Not(TestElement(E^.Dat.ClientKod+'│',P))  Then
If mm[E^.Dat.DocSelector+1]=1 Then
       Begin
       Add:=False;

       If (E^.Dat.DocSelector in [5,6,7,8]) Then
       Begin
          DelZerro(E^.Dat.Document);
          DelSpace(E^.Dat.Document);

          Assign(ef,Path^.Dat.ToDolg+E^.Dat.ClientKod+'.dlg');
          Res:=IOResult;
          BakFileMode:=FileMode;
          FileMode:=$42;
          Reset(Ef);
          Res:=IOResult;
          FileMode:=BakFileMode;

          If Res<>0 Then
            MessageBox(^M+#3'Ошибка доступа к файлу долгов клиента '+E^.Dat.ClientKod+'!',Nil,mfError+mfCancelButton)
          Else
          Begin
          New(er,Init);
          Find:=False;
          While Not(Eof(ef)) And Not(Find) Do
           Begin
            Read(Ef,er^.Dat);
            If (ClearChar(Er^.Dat.Market.Document)=E^.Dat.Document)
                  And
                           (DateToDateString(DateMask,Er^.Dat.Market.DateC)=E^.Dat.DateC)
            And(Er^.Dat.Market.Active) Then
                Begin
                 Find:=True;
                 If ((Er^.Dat.Full) and (ss[1]=1)) Or
                             (Not(Er^.Dat.Full) and (ss[2]=1)) Then Add:=True;
                End;
           End;
          Dispose(Er,Done);
          System.Close(Ef);

          If Not(Find) Then  MessageBox(^M+#3'Документ не найден в долгах клиента '+E^.Dat.ClientKod+'!',Nil,
                mfError+mfCancelButton);
          End;{Res=0 файл успешно открыт}
       End
       Else
           If ss[1]=1 Then Add:=True;


       If Add Then
       Begin
        Inc(Doc);
        s:=IntToStr(Doc,3);
        RFormat(s,CLitrMantissa);
        ws:=GetClientField(FClient,E^.Dat.ClientKod,E^.Dat.OperatorSelector);
        Format(ws,CClient);
        s:=s+SeparatorChar+ws;

        DelSpace(E^.Dat.Document);
        RFormat(E^.Dat.Document,CDocNumer-1);
        Format(E^.Dat.DateC,CDate);

        MyStr(StrToReal(E^.Dat.SummaZ)+StrToReal(E^.Dat.Skidka),CIZena-2,CMantissa,ws);
        MyStr(StrToReal(E^.Dat.Skidka),CIZena-2,CMantissa,E^.Dat.Skidka);
        MyStr(StrToReal(E^.Dat.SummaZ),CIZena-2,CMantissa,E^.Dat.SummaZ);
        Itogo:=Itogo+StrToreal(E^.Dat.SummaZ);
        Skidka:=Skidka+StrToreal(E^.Dat.Skidka);
        s:=s+SeparatorChar+E^.Dat.Document+SeparatorChar+E^.Dat.DateC+SeparatorChar+ws+SeparatorChar+
        +E^.Dat.Skidka+SeparatorChar+E^.Dat.SummaZ;
        Case E^.Dat.DocSelector Of
        0:s:=s+SeparatorChar+'Список';
        1:s:=s+SeparatorChar+'Тов.чек';
        2:s:=s+SeparatorChar+'Физ.лиц';
        3:s:=s+SeparatorChar+'СФ';
        4:s:=s+SeparatorChar+'СФ Б';
        5:s:=s+SeparatorChar+'Дебит *';
        6:s:=s+SeparatorChar+'ДебитСФ';
        7:s:=s+SeparatorChar+'Дебит';
        8:s:=s+SeparatorChar+'Дебит СФБ';
        Else;
        End;
        Writeln(txt1,Space+s);
        Adress:=GetClientField(FAdress,E^.Dat.ClientKod,E^.Dat.OperatorSelector);
        DelSpaceLeftRight(Adress);
        Writeln(txt1,Space+'   '+SeparatorChar+Adress);
        End;{Add}
       End;{If}
   End;{While}
   System.Close(f);
   AllItogo:=AllItogo+Itogo;
   AllSkidka:=AllSkidka+Skidka;
   AllDoc:=AllDoc+Doc;
   If Doc>0 Then
   Writeln(txt1,Space+'--- Всего за '+ Date+' док-тов: ',Doc:3,' Сумма отгрузки: ',(Itogo+Skidka):CINputIZena:CMAntissa,
   ' Скидка: ',Skidka:CInputIZena:CMantissa,' --');
 End;{If l=0}
End;{For}
Writeln(Txt1);
Writeln(txt1,Space+'─────────────────────────────────────────────────────────────────────────────────────────');
Writeln(Txt1,Space+'                                                    Всего документов: ',AllDoc:CIZena);
Writeln(Txt1,Space+
                   '                                                      Всего к оплате: ',RecognizReal(AllItogo,
                            CIZena,CMantissa));
Writeln(Txt1,Space+
'                                                        Всего скидка: ',RecognizReal(AllSkidka,CIZena,CMantissa));
Writeln(Txt1,Space+
'                                                     Всего со склада: ',RecognizReal(AllItogo+AllSkidka,CIZena,CMantissa));

Dispose(E,Done);

Writeln(Txt1,Space+'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
Writeln(txt1,Space+'=========================================================================================');
System.Close(txt1);
NoInfoMsg;
Report(Path^.Dat.ToTemp+'cmengotg.txt','',1,False,False);
End;{CalcTch}





Procedure CalcMenedger2(Const Client,Agent:PBox; Filtr,Oplata:Word;StartD,StopD:TDateString;
OpSel : Word);

Var f,fr : File;
    R : TRect;
    Ret : PNewVozwratType;
    RetF : NewVozwratFileType;
    E : PBufSuperMarketType;
    EEE : PSuperMArketType;
    s : String;
    l : Word;
    Razdel1 :PBox;
    Delta,DateOpl,Date : TDAteString;
    NDS,z,AllSkidka,AllItogo,ItogoSkidka,Itogo : Float;
    AllZakupka,AllAkzis,AllReturn,AllSkidkaReturn:Float;
    ws,ws2,ws1,ws3 : String;
    ws4,ws5 : AllStr;
    txt1,txt2 : Text;
    Res,AllDoc : Word;
    DocS : Word;
    Slujba,Current,Cur,sh,VidSkidka,Vid : Word;
    Space : TMyString;
    i,AllReturnDoc,RAbday,Den,Start,Stop : LongInt;
    NoScreen : PBox;
    Key,Distant : Word;
    NameDoc,Names,Otgruz : AllStr;
    DateOtgr,DateOplata: TDateString;
    StartDate,StopDate : TDateString;
    Index :LongInt;
    FFF : Boolean;
    AgName,ClShk,Dohod,CurClientKod,tr,Doc,Cod,Ag:AllStr;
    Dolg : Float;
    mm : Maska9;
    ss : Maska2;
    Find,Add : Boolean;
    c1,c2,Count1,Count2 : Word;
    Er : PBufRealizasiaType;
    AllReturnZakupka,AllReturnAkzis,
    AllLitr:Float;
    NoDohod : AllStr;
    VidReport : Word;
    ww1,ww2 : AllStr;
    NewAgent:PBox;
    SumO,SumZ:AllStr;
    PostList : PBox;
    M : Maska5;
    SumOpl,SumOZ,SumROpl,SumRZ,DohodStr,AllDohod,AllOpl,AllRet : AllStr;


(*
Procedure CreatReportFromPost(VAr txt1 : Text);
VAr Cur : Word;
Begin
If (PostList^.List^.Count-1)>=0 Then
Begin
Space:='';
Writeln(txt1);
{
Writeln(txt1,Space+'   СПРАВКА ПО ОПЛАЧЕННЫМ ОТГРУЗКАМ ПО ПОСТАВЩИКАМ');
Writeln(txt1,Space+'┌───────────────────────────────────────────────────────────────────────────────────────┐');
Writeln(txt1,Space+'│Поставщик            Код     Сумма опл.   Отгрузка ЗЦ    Возврат ЦО   Доход, руб    %  │');
Writeln(txt1,Space+'└───────────────────────────────────────────────────────────────────────────────────────┘');
}

Writeln(txt1,Space+'   СПРАВКА ПО ОПЛАЧЕННЫМ ОТГРУЗКАМ ПО ПОСТАВЩИКАМ');
Writeln(txt1,Space+'┌────────────────────┬─────┬────────────┬────────────┬───────────┬───────────┬─────┬──────────┐');
Writeln(txt1,Space+'│Поставщик           │Код  │ Сумма опл. │Отгрузка ЗЦ │ Возврат ЦО│  Доход,руб│  %  │Акциз.сбор│');
Writeln(txt1,Space+'└────────────────────┴─────┴────────────┴────────────┴───────────┴───────────┴─────┴──────────┘');

                    {12345678901234567890│12345│1234567890123│1234567890123│1234567890123│1234567890123│123456}

AllOpl[0]:=#0;
AllRet[0]:=#0;


For Cur:=0 To PostList^.List^.Count-1 Do
 Begin
  s:=PostList^.GetText(Cur,PostList^.List^.Count);
  {объем клиента по З/Цене }

  SumOpl:=Copy(s,1+CClient+1+CArtikul+1,CIZena);
  MyStr(StrToReal(SumOpl),13,2,SumOpl);

  SumOZ:=Copy(s,1+CClient+1+CArtikul+1+CIZena+1,CIZena);
  MyStr(StrToReal(SumOZ),13,4,SumOZ);

  SumROpl:=Copy(s,1+CClient+1+CArtikul+1+CIZena+1+CIZena+1,CIZena);
  MyStr(StrToReal(SumROpl),13,2,SumROpl);

  SumRZ:=Copy(s,1+CClient+1+CArtikul+1+CIZena+1+CIZena+1+CIZena+1,CIZena);



  MyStr(StrToReal(AllOpl)+StrToReal(SumOpl),CIZena,CMAntissa,AllOpl);
  MyStr(StrToReal(AllRet)+StrToReal(SumROpl),CIZena,CMAntissa,AllRet);

  MyStr((StrToReal(SumOpl)-StrToReal(SumOZ))-(StrToReal(SumROpl)-StrToReal(SumRz)),
  13,4,DohodStr);

  MyStr(StrToReal(DohodStr)+StrToReal(AllDohod),CIZena,CMantissaZ,AllDohod);

  s[0]:=Chr(1+CClient+1+CArtikul+1);

  While Pos('│',s)>0 Do s[Pos('│',s)]:=' ';

  s:=s+' '+SumOpl+' '+SumOZ+' '+SumROpl+' '+DohodStr;

If (Abs(StrToReal(SumOZ)-StrToReal(SumRz))>0.009) Then
Begin
  If (Abs(StrToReal(DohodStr))>0.009) Then
  MyStr(StrToReal(DohodStr)/(StrToReal(SumOZ)-StrToReal(SumRz))*100,CLitr,CMantissa,ws1)
  Else ws1:='??.??';
End
  Else ws1:=' 0.00';

  s:=s+' '+ws1;

 If (Abs(StrToreal(SumOpl))>0.009) Or
    (Abs(StrToreal(SumROpl))>0.009) Or
    (Abs(StrToreal(SumOZ))>0.009) Or
    (Abs(StrToreal(DohodStr))>0.009) Or
    (Abs(StrToreal(SumRZ))>0.009) then Writeln(txt1,Space+s);
 End;

Writeln(txt1,Space+'─────────────────────────────────────────────────────────────────────────────────────────');

Writeln(txt1,Space+'                  Всего:',RealToStr(StrToReal(AllOpl),CIZena,CMantissa)+'              '+
RealToStr(StrToReal(AllRet),CIZena,CMantissa)+' '+RealToStr(StrToReal(AllDohod),CIZena,CMantissaZ));



End;{If PostList}
End;
*)


Procedure CreatReportFromPost(VAr txt1 : Text);
VAr Cur : Word;
    SAllAkzis,SAkzis : AllStr;

Begin
If (PostList^.List^.Count-1)>=0 Then
Begin
Space:='';
Writeln(txt1);

Writeln(txt1,Space+'   СПРАВКА ПО ОТГРУЗКАМ ПО ПОСТАВЩИКАМ');
Writeln(txt1,Space+'┌───────────────────┬─────┬────────────┬────────────┬────────────┬───────────┬─────┬──────────┐');
Writeln(txt1,Space+'│Поставщик          │ Код │  Сумма отг.│ Отгрузка ЗЦ│  Возврат ЦО│  Доход,руб│  %  │Акциз.сбор│');
Writeln(txt1,Space+'└───────────────────┴─────┴────────────┴────────────┴────────────┴───────────┴─────┴──────────┘');

                   {12345678901234567890│12345│123456789012│123456789012│123456789012│12345678901│12345│1234567890}
AllOpl[0]:=#0;
AllRet[0]:=#0;
SAllAkzis[0]:=#0;

For Cur:=0 To PostList^.List^.Count-1 Do
 Begin
  s:=PostList^.GetText(Cur,PostList^.List^.Count);
  {объем клиента по З/Цене }

  SumOpl:=Copy(s,1+CClient+1+CArtikul+1,CIZena);
  MyStr(StrToReal(SumOpl),12,2,SumOpl);

  SumOZ:=Copy(s,1+CClient+1+CArtikul+1+CIZena+1,CIZena);
  MyStr(StrToReal(SumOZ),12,4,SumOZ);

  SumROpl:=Copy(s,1+CClient+1+CArtikul+1+CIZena+1+CIZena+1,CIZena);
  MyStr(StrToReal(SumROpl),12,2,SumROpl);

  SumRZ:=Copy(s,1+CClient+1+CArtikul+1+CIZena+1+CIZena+1+CIZena+1,CIZena);

  SAkzis:=Copy(s,1+CClient+1+CArtikul+1+CIZena+1+CIZena+1+CIZena+1+CIZena+1,CIZena);
  MyStr(StrToReal(SAllAkzis)+StrToReal(SAkzis),10,4,SAllAkzis);


  MyStr(StrToReal(AllOpl)+StrToReal(SumOpl),CIZena,CMAntissa,AllOpl);
  MyStr(StrToReal(AllRet)+StrToReal(SumROpl),CIZena,CMAntissa,AllRet);

  MyStr(StrToReal(SAkzis),CZenaZ,CMAntissaZ,SAkzis);

  MyStr((StrToReal(SumOpl)-StrToReal(SumOZ)-StrToReal(SAkzis))-(StrToReal(SumROpl)-StrToReal(SumRz)),
  11,CMantissaZ,DohodStr);

  MyStr(StrToReal(DohodStr)+StrToReal(AllDohod),CIZena,CMantissaZ,AllDohod);

  s[0]:=Chr(CClient+1+CArtikul);

  While Pos('│',s)>0 Do s[Pos('│',s)]:=SeparatorChar;

  s:=s+SeparatorChar+SumOpl+SeparatorChar+SumOZ+SeparatorChar+SumROpl+SeparatorChar+DohodStr;

If (Abs(StrToReal(SumOZ)-StrToReal(SumRz))>0.009) Then
Begin
  If (Abs(StrToReal(DohodStr))>0.009) Then
  MyStr(StrToReal(DohodStr)/(StrToReal(SumOZ)-StrToReal(SumRz))*100,CLitr,CMantissa,ws1)
  Else ws1:='??.??';
End
  Else ws1:=' 0.00';

  s:=s+SeparatorChar+ws1+SeparatorChar+SAkzis;

 If (Abs(StrToreal(SumOpl))>0.009) Or
    (Abs(StrToreal(SumROpl))>0.009) Or
    (Abs(StrToreal(SumOZ))>0.009) Or
    (Abs(StrToreal(DohodStr))>0.009) Or
    (Abs(StrToreal(SAkzis))>0.009) Or
    (Abs(StrToreal(SumRZ))>0.009) then Writeln(txt1,Space+s);
 End;
Writeln(txt1,Space+'──────────────────────────────────────────────────────────────────────────────────────────────');
Writeln(txt1,Space+'                  Всего:',RealToStr(StrToReal(AllOpl),CIZena,CMantissa)+'             '+SeparatorChar+
RealToStr(StrToReal(AllRet),CIZena-3,CMantissa)+SeparatorChar+RealToStr(StrToReal(AllDohod),CIZena-3,CMantissaZ)+
'   '+SeparatorChar+RealToStr(StrToReal(SAllAkzis),CIZena-3,CMantissaZ));
End;{If PostList}
End;






Procedure CreatReportFromGroup(VAr txt1 : Text);
VAr Cur : Word;
    SAllAkzis,SAkzis : AllStr;

Begin
If (Grouplist^.List^.Count-1)>=0 Then
Begin
Space:='';
Writeln(txt1);

Writeln(txt1,Space+'   СПРАВКА ПО ОТГРУЗКАМ ПО ГРУППАМ ПРОДУКЦИИ');
Writeln(txt1,Space+'┌───────────────────┬────┬────────────┬────────────┬────────────┬───────────┬─────┬──────────┐');
Writeln(txt1,Space+'│Группа продукции   │Код │  Сумма отг.│ Отгрузка ЗЦ│  Возврат ЦО│  Доход,руб│  %  │Акциз.сбор│');
Writeln(txt1,Space+'└───────────────────┴────┴────────────┴────────────┴────────────┴───────────┴─────┴──────────┘');

                   {12345678901234567890│2345│123456789012│123456789012│123456789012│12345678901│12345│1234567890}
AllOpl[0]:=#0;
AllRet[0]:=#0;
SAllAkzis[0]:=#0;
AllDohod[0]:=#0;
For Cur:=0 To Grouplist^.List^.Count-1 Do
 Begin
  s:=Grouplist^.GetText(Cur,Grouplist^.List^.Count);
  {объем клиента по З/Цене }

  SumOpl:=Copy(s,1+CName+1+CClientKod+1,CIZena);
  MyStr(StrToReal(SumOpl),12,2,SumOpl);

  SumOZ:=Copy(s,1+CName+1+CClientKod+1+CIZena+1,CIZena);
  MyStr(StrToReal(SumOZ),12,4,SumOZ);

  SumROpl:=Copy(s,1+CName+1+CClientKod+1+CIZena+1+CIZena+1,CIZena);
  MyStr(StrToReal(SumROpl),12,2,SumROpl);

  SumRZ:=Copy(s,1+CName+1+CClientKod+1+CIZena+1+CIZena+1+CIZena+1,CIZena);

  SAkzis:=Copy(s,1+CName+1+CClientKod+1+CIZena+1+CIZena+1+CIZena+1+CIZena+1,CIZena);
  MyStr(StrToReal(SAllAkzis)+StrToReal(SAkzis),10,4,SAllAkzis);


  MyStr(StrToReal(AllOpl)+StrToReal(SumOpl),CIZena,CMAntissa,AllOpl);
  MyStr(StrToReal(AllRet)+StrToReal(SumROpl),CIZena,CMAntissa,AllRet);

  MyStr(StrToReal(SAkzis),CZenaZ,CMAntissaZ,SAkzis);

  MyStr((StrToReal(SumOpl)-StrToReal(SumOZ)-StrToReal(SAkzis))-(StrToReal(SumROpl)-StrToReal(SumRz)),
  11,CMantissaZ,DohodStr);

  MyStr(StrToReal(DohodStr)+StrToReal(AllDohod),CIZena,CMantissaZ,AllDohod);

  s[0]:=Chr(CName+1+CClientKod);
  System.delete(s,1+CClient,6);

  While Pos('│',s)>0 Do s[Pos('│',s)]:=SeparatorChar;

  s:=s+SeparatorChar+SumOpl+SeparatorChar+SumOZ+SeparatorChar+SumROpl+SeparatorChar+DohodStr;

If (Abs(StrToReal(SumOZ)-StrToReal(SumRz))>0.009) Then
Begin
  If (Abs(StrToReal(DohodStr))>0.009) Then
  MyStr(StrToReal(DohodStr)/(StrToReal(SumOZ)-StrToReal(SumRz))*100,CLitr,CMantissa,ws1)
  Else ws1:='??.??';
End
  Else ws1:=' 0.00';

  s:=s+SeparatorChar+ws1+SeparatorChar+SAkzis;

 If (Abs(StrToreal(SumOpl))>0.009) Or
    (Abs(StrToreal(SumROpl))>0.009) Or
    (Abs(StrToreal(SumOZ))>0.009) Or
    (Abs(StrToreal(DohodStr))>0.009) Or
    (Abs(StrToreal(SAkzis))>0.009) Or
    (Abs(StrToreal(SumRZ))>0.009) then Writeln(txt1,Space+s);
 End;

Writeln(txt1,Space+'──────────────────────────────────────────────────────────────────────────────────────────────');
Writeln(txt1,Space+'                 Всего:'+SeparatorChar,RealToStr(StrToReal(AllOpl),CIZena,CMantissa)+'             '+
SeparatorChar+RealToStr(StrToReal(AllRet),CIZena-3,CMantissa)+SeparatorChar+RealToStr(StrToReal(AllDohod),CIZena-3,CMantissaZ)+
'   '+SeparatorChar+RealToStr(StrToReal(SAllAkzis),CIZena-3,CMantissaZ));

End;{If Grouplist}
End;



(*
Procedure AddPostListOtgruska(Cod:ArtikulStr;ww1,ww2:AllStr);
Var L : Boolean;
    st,s : String;
    i : word;
Begin
l:=False;
RFormatZerro(Cod,CArtikul);
If (PostList^.List^.Count-1)>=0 Then
Begin
For i:=0 To PostList^.List^.Count-1 Do
 Begin
  st:=PostList^.GetText(i,PostList^.List^.Count);
  st:=Copy(st,1+CClient+1,CArtikul);
  If (St=Cod) Then
   Begin
    st:=PostList^.GetText(i,PostList^.List^.Count);
    {добавляем отгрузку}
    s:=Copy(st,1+CClient+1+CArtikul+1,CIZena);
    System.Delete(st,1+CClient+1+CArtikul+1,CIZena);

    MyStr(StrToReal(s)+StrToReal(ww1){отгрзка},CIZena,CMantissa,s);
    System.Insert(s,st,1+CClient+1+CArtikul+1);


    s:=Copy(st,1+CClient+1+CArtikul+1+CIZena+1,CIZena);
    System.Delete(st,1+CClient+1+CArtikul+1+CIZena+1,CIZena);

    MyStr(StrToReal(s)+StrToReal(ww2){отгрзка по закупке},CIZena,CMantissaZ,s);
    System.Insert(s,st,1+CClient+1+CArtikul+1+CIZena+1);

    PostList^.List^.AtFree(i);
    PostList^.SetRange(PostList^.List^.Count);
    PostList^.List^.Insert(NewStr(st));
    PostList^.SetRange(PostList^.List^.Count);
    l:=True;
    Break;
   End;{St=Cod}
 End;
if Not(l) Then
 MessageBox(^M+#3'Элемент ('+Cod+') в списке не найден!',Nil,mfError+mfCancelButton);
End;
End;
*)

Procedure AddPostListOtgruska(Cod:ArtikulStr;ww1,ww2,ww3{акциз}:AllStr);
Var L : Boolean;
    st,s : String;
    i : word;
Begin
l:=False;
RFormatZerro(Cod,CArtikul);
If (PostList^.List^.Count-1)>=0 Then
Begin
For i:=0 To PostList^.List^.Count-1 Do
 Begin
  st:=PostList^.GetText(i,PostList^.List^.Count);
  st:=Copy(st,1+CClient+1,CArtikul);
  If (St=Cod) Then
   Begin
    st:=PostList^.GetText(i,PostList^.List^.Count);
    {добавляем отгрузку}
    s:=Copy(st,1+CClient+1+CArtikul+1,CIZena);
    System.Delete(st,1+CClient+1+CArtikul+1,CIZena);

    MyStr(StrToReal(s)+StrToReal(ww1){отгрзка},CIZena,CMantissa,s);
    System.Insert(s,st,1+CClient+1+CArtikul+1);


    s:=Copy(st,1+CClient+1+CArtikul+1+CIZena+1,CIZena);
    System.Delete(st,1+CClient+1+CArtikul+1+CIZena+1,CIZena);

    MyStr(StrToReal(s)+StrToReal(ww2){отгрзка по закупке},CIZena,CMantissaZ,s);
    System.Insert(s,st,1+CClient+1+CArtikul+1+CIZena+1);



    s:=Copy(st,1+CClient+1+CArtikul+1+CIZena+1+CIZena+1+CIZena+1+CIZena+1,CIZena);
    System.Delete(st,1+CClient+1+CArtikul+1+CIZena+1+CIZena+1+CIZena+1+CIZena+1,CIZena);

    MyStr(StrToReal(s)+StrToReal(ww3){отгрзка акцизный сб},CIZena,CMantissaZ,s);
    System.Insert(s,st,1+CClient+1+CArtikul+1+CIZena+1+CIZena+1+CIZena+1+CIZena+1);

    PostList^.List^.AtFree(i);
    PostList^.SetRange(PostList^.List^.Count);
    PostList^.List^.Insert(NewStr(st));
    PostList^.SetRange(PostList^.List^.Count);
    l:=True;
    Break;
   End;{St=Cod}
 End;
if Not(l) Then
 MessageBox(^M+#3'Элемент ('+Cod+') в списке не найден!',Nil,mfError+mfCancelButton);
End;
End;

Procedure AddGroupListOtgruska(Cod:ArtikulStr;ww1,ww2,ww3{акциз}:AllStr);
Var L : Boolean;
    st,s : String;
    i : word;
Begin
l:=False;
RFormatZerro(Cod,CClientKod);
If (Grouplist^.List^.Count-1)>=0 Then
Begin
For i:=0 To Grouplist^.List^.Count-1 Do
 Begin
  st:=Grouplist^.GetText(i,Grouplist^.List^.Count);
  st:=Copy(st,1+CName+1,CClientKod);
  If (St=Cod) Then
   Begin
    st:=Grouplist^.GetText(i,Grouplist^.List^.Count);
    {добавляем отгрузку}
    s:=Copy(st,1+CName+1+CClientKod+1,CIZena);
    System.Delete(st,1+CName+1+CClientKod+1,CIZena);

    MyStr(StrToReal(s)+StrToReal(ww1){отгрзка},CIZena,CMantissa,s);
    System.Insert(s,st,1+CName+1+CClientKod+1);


    s:=Copy(st,1+CName+1+CClientKod+1+CIZena+1,CIZena);
    System.Delete(st,1+CName+1+CClientKod+1+CIZena+1,CIZena);

    MyStr(StrToReal(s)+StrToReal(ww2){отгрзка по закупке},CIZena,CMantissaZ,s);
    System.Insert(s,st,1+CName+1+CClientKod+1+CIZena+1);



    s:=Copy(st,1+CName+1+CClientKod+1+CIZena+1+CIZena+1+CIZena+1+CIZena+1,CIZena);
    System.Delete(st,1+CName+1+CClientKod+1+CIZena+1+CIZena+1+CIZena+1+CIZena+1,CIZena);

    MyStr(StrToReal(s)+StrToReal(ww3){отгрзка акцизный сб},CIZena,CMantissaZ,s);
    System.Insert(s,st,1+CName+1+CClientKod+1+CIZena+1+CIZena+1+CIZena+1+CIZena+1);

    Grouplist^.List^.AtFree(i);
    Grouplist^.SetRange(Grouplist^.List^.Count);
    Grouplist^.List^.Insert(NewStr(st));
    Grouplist^.SetRange(Grouplist^.List^.Count);
    l:=True;
    Break;
   End;{St=Cod}
 End;
if Not(l) Then
 MessageBox(^M+#3'Элемент ('+Cod+') в списке не найден!',Nil,mfError+mfCancelButton);
End;
End;




(*
Procedure AddPostListReturn(Cod:ArtikulStr;ww1{по оплате},ww2{по закупке}:AllStr);
Var L : Boolean;
    st,s : String;
    i : word;
Begin
l:=False;
RFormatZerro(Cod,CArtikul);
If (PostList^.List^.Count-1)>=0 Then
Begin
For i:=0 To PostList^.List^.Count-1 Do
 Begin
  st:=PostList^.GetText(i,PostList^.List^.Count);
  st:=Copy(st,1+CClient+1,CArtikul);
  If (St=Cod) Then
   Begin
    st:=PostList^.GetText(i,PostList^.List^.Count);
    {добавляем отгрузку}
    s:=Copy(st,1+CClient+1+CArtikul+1+CIZena+1+CIZena+1,CIZena);
    System.Delete(st,1+CClient+1+CArtikul+1+CIZena+1+CIZena+1,CIZena);

    MyStr(StrToReal(s)+StrToReal(ww1){по оплате},CIZena,CMantissa,s);
    System.Insert(s,st,1+CClient+1+CArtikul+1+CIZena+1+CIZena+1);


    s:=Copy(st,1+CClient+1+CArtikul+1+CIZena+1+CIZena+1+CIZena+1,CIZena);
    System.Delete(st,1+CClient+1+CArtikul+1+CIZena+1+CIZena+1+CIZena+1,CIZena);

    MyStr(StrToReal(s)+StrToReal(ww2){отгрзка по закупке},CIZena,CMantissaZ,s);
    System.Insert(s,st,1+CClient+1+CArtikul+1+CIZena+1+CIZena+1+CIZena+1);

    PostList^.List^.AtFree(i);
    PostList^.SetRange(PostList^.List^.Count);
    PostList^.List^.Insert(NewStr(st));
    PostList^.SetRange(PostList^.List^.Count);
    l:=True;
    Break;
   End;{St=Cod}
 End;
if Not(l) Then
 MessageBox(^M+#3'Элемент ('+Cod+') в списке не найден!',Nil,mfError+mfCancelButton);
End;
End;
*)

Procedure AddPostListReturn(Cod:ArtikulStr;ww1{по оплате},ww2{по закупке},ww3{акциз}:AllStr);
Var L : Boolean;
    st,s : String;
    i : word;
Begin
l:=False;
RFormatZerro(Cod,CArtikul);
If (PostList^.List^.Count-1)>=0 Then
Begin
For i:=0 To PostList^.List^.Count-1 Do
 Begin
  st:=PostList^.GetText(i,PostList^.List^.Count);
  st:=Copy(st,1+CClient+1,CArtikul);
  If (St=Cod) Then
   Begin
    st:=PostList^.GetText(i,PostList^.List^.Count);
    {добавляем отгрузку}
    s:=Copy(st,1+CClient+1+CArtikul+1+CIZena+1+CIZena+1,CIZena);
    System.Delete(st,1+CClient+1+CArtikul+1+CIZena+1+CIZena+1,CIZena);

    MyStr(StrToReal(s)+StrToReal(ww1){по оплате},CIZena,CMantissa,s);
    System.Insert(s,st,1+CClient+1+CArtikul+1+CIZena+1+CIZena+1);


    s:=Copy(st,1+CClient+1+CArtikul+1+CIZena+1+CIZena+1+CIZena+1,CIZena);
    System.Delete(st,1+CClient+1+CArtikul+1+CIZena+1+CIZena+1+CIZena+1,CIZena);

    MyStr(StrToReal(s)+StrToReal(ww2){отгрзка по закупке},CIZena,CMantissaZ,s);
    System.Insert(s,st,1+CClient+1+CArtikul+1+CIZena+1+CIZena+1+CIZena+1);


    s:=Copy(st,1+CClient+1+CArtikul+1+CIZena+1+CIZena+1+CIZena+1+CIZena+1,CIZena);
    System.Delete(st,1+CClient+1+CArtikul+1+CIZena+1+CIZena+1+CIZena+1+CIZena+1,CIZena);

    MyStr(StrToReal(s)-StrToReal(ww3){акциз сбор},CIZena,CMantissaZ,s);
    System.Insert(s,st,1+CClient+1+CArtikul+1+CIZena+1+CIZena+1+CIZena+1+CIZena+1);

    PostList^.List^.AtFree(i);
    PostList^.SetRange(PostList^.List^.Count);
    PostList^.List^.Insert(NewStr(st));
    PostList^.SetRange(PostList^.List^.Count);
    l:=True;
    Break;
   End;{St=Cod}
 End;
if Not(l) Then
 MessageBox(^M+#3'Элемент ('+Cod+') в списке не найден!',Nil,mfError+mfCancelButton);
End;
End;



Procedure AddGroupListReturn(Cod:ArtikulStr;ww1{по оплате},ww2{по закупке},ww3{акциз}:AllStr);
Var L : Boolean;
    st,s : String;
    i : word;
Begin
l:=False;
RFormatZerro(Cod,CClientKod);
If (Grouplist^.List^.Count-1)>=0 Then
Begin
For i:=0 To Grouplist^.List^.Count-1 Do
 Begin
  st:=Grouplist^.GetText(i,Grouplist^.List^.Count);
  st:=Copy(st,1+CName+1,CClientKod);
  If (St=Cod) Then
   Begin
    st:=Grouplist^.GetText(i,Grouplist^.List^.Count);
    {добавляем отгрузку}
    s:=Copy(st,1+CName+1+CClientKod+1+CIZena+1+CIZena+1,CIZena);
    System.Delete(st,1+CName+1+CClientKod+1+CIZena+1+CIZena+1,CIZena);

    MyStr(StrToReal(s)+StrToReal(ww1){по оплате},CIZena,CMantissa,s);
    System.Insert(s,st,1+CName+1+CClientKod+1+CIZena+1+CIZena+1);


    s:=Copy(st,1+CName+1+CClientKod+1+CIZena+1+CIZena+1+CIZena+1,CIZena);
    System.Delete(st,1+CName+1+CClientKod+1+CIZena+1+CIZena+1+CIZena+1,CIZena);

    MyStr(StrToReal(s)+StrToReal(ww2){отгрзка по закупке},CIZena,CMantissaZ,s);
    System.Insert(s,st,1+CName+1+CClientKod+1+CIZena+1+CIZena+1+CIZena+1);


    s:=Copy(st,1+CName+1+CClientKod+1+CIZena+1+CIZena+1+CIZena+1+CIZena+1,CIZena);
    System.Delete(st,1+CName+1+CClientKod+1+CIZena+1+CIZena+1+CIZena+1+CIZena+1,CIZena);

    MyStr(StrToReal(s)-StrToReal(ww3){акциз сбор},CIZena,CMantissaZ,s);
    System.Insert(s,st,1+CName+1+CClientKod+1+CIZena+1+CIZena+1+CIZena+1+CIZena+1);

    Grouplist^.List^.AtFree(i);
    Grouplist^.SetRange(Grouplist^.List^.Count);
    Grouplist^.List^.Insert(NewStr(st));
    Grouplist^.SetRange(Grouplist^.List^.Count);
    l:=True;
    Break;
   End;{St=Cod}
 End;
if Not(l) Then
 MessageBox(^M+#3'Элемент ('+Cod+') в списке не найден!',Nil,mfError+mfCancelButton);
End;
End;



Procedure AddAgentSumma(Cod:ArtikulStr;s1,s2,s3{сумма по закупке},s4{акциз}:AllStr);
Var L : Boolean;
    st,s : String;
    i : word;
Begin
l:=False;
If (NewAgent^.List^.Count-1)>=0 Then
Begin
For i:=0 To NewAgent^.List^.Count-1 Do
 Begin
  st:=NewAgent^.GetText(i,NewAgent^.List^.Count);
  st:=Copy(st,1+1,CClientKod);
  If (St=Cod) Then
   Begin
    st:=NewAgent^.GetText(i,NewAgent^.List^.Count);
    {добавляем отгрузку}

    s:=Copy(st,1+1+CClientKod+1,CIZena);
    System.Delete(st,1+1+CClientKod+1,CIZena);
    MyStr(StrToReal(s)+StrToReal(s1),CIZena,CMantissa,s);
    System.Insert(s,st,1+1+CClientKod+1);

    {добавляем отгрузку по закупочным ценам}
    s:=Copy(st,1+1+CClientKod+1+CIZena+1+CIZena+1,CIZena);
    System.Delete(st,1+1+CClientKod+1+CIZena+1+CIZena+1,CIZena);
    MyStr(StrToReal(s)+StrToReal(s3),CIZena,CMantissaZ,s);
    System.Insert(s,st,1+1+CClientKod+1+CIZena+1+CIZena+1);

    {добавляем акциз по оплаченной отгрузке}
    s:=Copy(st,1+1+CClientKod+1+CIZena+1+CIZena+1+CIZena+1,CIZena);
    System.Delete(st,1+1+CClientKod+1+CIZena+1+CIZena+1+CIZena+1,CIZena);
    MyStr(StrToReal(s)+StrToReal(s4),CIZena,CMantissaZ,s);
    System.Insert(s,st,1+1+CClientKod+1+CIZena+1+CIZena+1+CIZena+1);


    NewAgent^.List^.AtFree(i);
    NewAgent^.SetRange(NewAgent^.List^.Count);
    NewAgent^.List^.Insert(NewStr(st));
    NewAgent^.SetRange(NewAgent^.List^.Count);
    l:=True;
    Break;
   End;{St=Cod}
 End;
if Not(l) Then
 MessageBox(^M+#3'Элемент ('+Cod+') в списке не найден!',Nil,mfError+mfCancelButton);
End;
End;



(*
Procedure AddAgentSumma(Cod:ArtikulStr;s1,s2,s3{сумма по закупке}:AllStr);
Var L : Boolean;
    st,s : String;
    i : word;
Begin
l:=False;
If (NewAgent^.List^.Count-1)>=0 Then
Begin
For i:=0 To NewAgent^.List^.Count-1 Do
 Begin
  st:=NewAgent^.GetText(i,NewAgent^.List^.Count);
  st:=Copy(st,1+1,CClientKod);
  If (St=Cod) Then
   Begin
    st:=NewAgent^.GetText(i,NewAgent^.List^.Count);
    {добавляем отгрузку}

    s:=Copy(st,1+1+CClientKod+1,CIZena);
    System.Delete(st,1+1+CClientKod+1,CIZena);
    MyStr(StrToReal(s)+StrToReal(s1),CIZena,CMantissa,s);
    System.Insert(s,st,1+1+CClientKod+1);

    {добавляем отгрузку по закупочным ценам}
    s:=Copy(st,1+1+CClientKod+1+CIZena+1+CIZena+1,CIZena);
    System.Delete(st,1+1+CClientKod+1+CIZena+1+CIZena+1,CIZena);
    MyStr(StrToReal(s)+StrToReal(s3),CIZena,CMantissaZ,s);
    System.Insert(s,st,1+1+CClientKod+1+CIZena+1+CIZena+1);

    NewAgent^.List^.AtFree(i);
    NewAgent^.SetRange(NewAgent^.List^.Count);
    NewAgent^.List^.Insert(NewStr(st));
    NewAgent^.SetRange(NewAgent^.List^.Count);
    l:=True;
    Break;
   End;{St=Cod}
 End;
if Not(l) Then
 MessageBox(^M+#3'Элемент ('+Cod+') в списке не найден!',Nil,mfError+mfCancelButton);
End;
End;
*)




Function TestAgent1(Cod:ArtikulStr):Boolean;
Var L : Boolean;
    i : word;
    st : String;
Begin
TestAgent1:=False;

If (Agent^.List^.Count-1)>=0 Then
Begin
For i:=0 To Agent^.List^.Count-1 Do
 Begin
  st:=Agent^.GetText(i,Agent^.List^.Count);
  st:=Copy(st,1+CClient+1,CClientKod);
  If (St=Cod) Then
   Begin
    TestAgent1:=True;
    Break;
   End;{St=Cod}
 End;
End;
End;

Function TestAgent(Cod:ArtikulStr):Boolean;
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
  st:=Copy(st,1+CClient+1,CClientKod);
  If (St=Cod) Then
   Begin
    TestAgent:=True;
    Break;
   End;{St=Cod}
 End;
End;
End;



Type ArrayRazdelMemory = Record
     RList  : PBox;   {список разделов}
     Employ : Boolean;{признак инициализации списка}
     DocKol : Word;
     DocKolRet : Word;
    End;

 Var
     Idx : Word;
     Stat : Array [0..MaxStatClient] Of ArrayRazdelMemory;
     Client1 : PBox;
     A : DocumentEditZ;
     SumRetOpl : AllStr;
     ZakupkaOpora : Word;

Procedure NewElement(Kod : Word);
Var R : TRect;
    s : String;
    c : Word;
Begin
R.Assign(0, 0, 0, 0);
Stat[Kod].Employ:=True;
Stat[Kod].DocKol:=0;
Stat[Kod].DocKolRet:=0;
Stat[Kod].RList := New(PBox, Init(R, 1, Nil));
Stat[Kod].RList^.NewList(New(PTextCollection, Init(0,1)));
For c:=0 To Razdel1^.List^.Count-1 Do
Begin
 s:=Razdel1^.GetText(c,Razdel1^.List^.Count);
 s:=Copy(s,1+1,CRAzdelKod);
 s:=s+'000'+'│               │               │               │               │               ';

Stat[Kod].RList^.List^.Insert(
NewStr('│'+s));
     Stat[Kod].RList^.SetRange(Stat[Kod].RList^.List^.Count);
End;{For}
End;



Procedure DoneArrayList;
Var  c : Word;
Begin
For c:=0 To MaxStatClient Do
Begin
 If Stat[c].Employ Then
  Begin
   Dispose(Stat[c].RList,Done);
  End;
End;{For}
End;




Procedure CreatReportFromAgent(Var txt1 : Text);
VAr Cur : Word;
    SAkzis:AllStr;
Begin
If (NewAgent^.List^.Count-1)>=0 Then
Begin
Space:='';
Writeln(txt1);
Writeln(txt1,Space+'   СПРАВКА ПО ОТГРУЗКАМ ПО АГЕНТАМ');
Writeln(txt1,Space+'┌─┬────────────────────┬────┬───────────────┬─────┬───────────────┬───────────┬─────┬──────────┐');
Writeln(txt1,Space+'│N│       Агент        │Код │ Отгружен.сумма│  %  │    Всего штраф│ Доход,руб │  %  │Акциз.сбор│');
Writeln(txt1,Space+'│ │                    │    │с учетом возвр.│от E │               │с уч.возв. │доход│с уч.взв. │');
Writeln(txt1,Space+'└─┴────────────────────┴────┴───────────────┴─────┴───────────────┴───────────┴─────┴──────────┘');

                   {12 12345678901234567890 1234 123456789012345 12345 123456789012345│12345678901│12345│1234567890}

For Cur:=0 To NewAgent^.List^.Count-1 Do
 Begin
  s:=NewAgent^.GetText(Cur,NewAgent^.List^.Count);

  {объем клиента по З/Цене }
  SumZ:=Copy(s,1+1+CClientKod+1+CIZena+1+CIZena+1,CIZena);
  {объем клиента по акцизному сбору }
  SAkzis:=Copy(s,1+1+CClientKod+1+CIZena+1+CIZena+1+CIZena+1,CIZena);
  {удалем отгрузку по закупке и акциз}
  System.Delete(s,1+1+CClientKod+1+CIZena+1+CIZena+1,CIZena+1+CIZena+1);


  While Pos('│',s)>0 Do s[Pos('│',s)]:=SeparatorChar;

  Delete(s,1,1);
  ws1:=Copy(s,1,CClientKod);{!!!!}
  ws1:=GetAgentField(FClient,ws1);
  Format(ws1,CClient+1);
  System.Insert(ws1+SeparatorChar,s,1);
  ws1:=Copy(s,1+1+CClient+1+CClientKod+1,CIZena);{объемы агента}
  SumO:=ws1;


If (StrToReal(ws1)>0.009) Then
Begin
  If (AllItogo{+AllSkidka})>0.009 Then
  MyStr(StrToReal(ws1)/(AllItogo{+AllSkidka})*100,CLitr,CMantissa,ws1)
  Else ws1:='??.??';
End
  Else ws1:=' 0.00';



  ws2:=IntToStr(Cur+1,CMantissa);
  RFormat(ws2,CMantissa);
  System.Insert(SeparatorChar+ws1,s,1+CClient+1+CClientKod+1+CIZena+1);
  s:=ws2+SeparatorChar+s;


If (StrToReal(SumO)>0.009) Then
Begin
  If StRToReal(SumZ)>0.009 Then
  MyStr((StrToReal(SumO)-StrToReal(SumZ)-StrToReal(SAkzis))/StrToReal(SumZ)*100,CLitr,CMantissa,ws1)
  Else ws1:='??.??';
End
  Else ws1:=' 0.00';

  MyStr((StrToReal(SumO)-StrToReal(SumZ)-StrToReal(SAkzis)),CIZena-4,CMantissaZ,ws2);

  MyStr(StrToReal(SAkzis),CZenaZ,CMantissaZ,SAkzis);


  s:=s+ws2+SeparatorChar+ws1+SeparatorChar+SAkzis;

  Writeln(txt1,Space+s);




 End;
Writeln(txt1,Space+'────────────────────────────────────────────────────────────────────────────────────────────────');

End;{If NewAgent}
End;






Procedure CreatDetalReport;
Var c1,c,l,Cur : Word;
Begin
 Assign(txt1,Path^.Dat.ToTemp+'fullotg.csv');
 Rewrite(txt1);
 Cur:=IOResult;
 If Cur=0 Then
  Begin

  DInfoMsg('Провожу детализацию ...',True);

  Client^.FocusItem(0);

  Writeln(Txt1,DosToWin('"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+
  Times+') Отчет сформирован по отгрузке'));
  Write(Txt1,'                   '+';'+'    '+';'+'     '+';');

For Cur:=0 To Razdel1^.List^.Count-1 Do
 Begin
  s:=Razdel1^.GetText(Cur,Razdel1^.List^.Count);
  Delete(s,1,1);
  ws1:=Copy(s,1,CRazdelKod);
  Delete(s,1+CRazdelKod,3);
  ww1:=GetRazdel(ws1);
  Format(ww1,CRazdel-(CRazdelKod+1));
  Write(txt1,DosToWin(ww1+' '+ws1)+';');
 End;
  WriteLn(txt1);


  For c1:=0 To Client^.List^.Count-1 Do
   Begin
    s:=Client^.GetText(c1,Client^.List^.Count);
    Cur:=StrToInt(Copy(Client^.GetText(c1,Client^.List^.Count),1+CClient+1,CClientKod));

    If (Stat[Cur].Employ) And ((Stat[Cur].DocKol>0) Or (Stat[Cur].DocKolRet>0))  Then
     Begin
      Write(txt1,DosToWin(Copy(s,1,CClient))+';',Cur:4,';',Stat[Cur].DocKol:5,
         ';');
      For l:=0 To Stat[Cur].RList^.List^.Count-1 Do
        Begin
         s:=Stat[Cur].RList^.GetText(l,Stat[Cur].RList^.List^.Count);
         {прочитали возвраты по оплате}
         ws1:=Copy(s,1+1+CArtikul+1+CIZena+1+CIZena+1,CIZena);
         {прочитали отгрузку по оплате}
         s:=Copy(s,1+1+CArtikul+1,CIZena);
         MyStr(StrToReal(s)-StrToReal(ws1),CIZena,CMantissa,s);
         Write(txt1,DosToWin(s+'    ')+';');
        End;{For}
      Writeln(txt1);
     End;{Employ and DocKol>0}
   End;{For по клиентам}


  Close(txt1);
  Cur:=IOResult;
  NoInfoMsg;

  MessageBox(^M+#3'Детальный отчет успешно сформирован!',Nil,mfInformation+mfCancelButton);
  End
Else
Begin
 MessageBox(^M+#3'Ошибка создания '+Path^.Dat.ToTemp+'fullotg.csv'^M+
 #3' Код: ',nil,mfError+mfCanCelButton);
 Assign(txt1,Path^.Dat.ToTemp+'fullotg.csv');
 Erase(txt1);
 Cur:=IOResult;
End;


End;

VAr SSAkzis : AllStr;
    BakFileMode : Word;

Begin

 WordTobit9(Filtr,mm);
 Convert9(mm);

 WordToBit2(Oplata,ss);
 Convert2(ss);

For c1:=0 To MaxStatClient Do
 Begin
  Stat[c1].Employ:=False;
  Stat[c1].DocKol:=0;
  Stat[c1].DocKolRet:=0;
 End;


 Start:=DateStringToDate(DateMask,StartD);
 Stop:=DateStringToDate(DateMask,StopD);


 If Not(SelReport(l)) Then
   Begin
    Exit;
   End;
 WordToBit5(l,M);
 Convert5(M);




 VidReport:=1;
 VidReport:=SelectImport(19);
 If VidReport=2 Then
  Begin
   Exit;
  End;


 Key:=0;
 Distant:=0;

 If VidReport=0 Then
 If Not(KeySorting(Key,Distant,False)) Then
   Begin
    Exit;
   End;


 ZakupkaOpora:=0;
 ZakupkaOpora:=SelectImport(17);
 If ZakupkaOpora=2 Then
  Begin
   Exit;
  End;





If Distant=0 Then DistanationSorting:=0
Else DistanationSorting:=1;


 Space[0]:=#0;
 Assign(Txt1,Path^.Dat.ToTemp+'ncmengob.txt');
 l:=IOResult;
 Rewrite(Txt1);
 l:=IOResult;
 If L <> 0 Then
  Begin
   MessageBox(#3^M+#3'Не могу создать файл отчета'+Path^.Dat.ToTemp+'ncmengob.txt',Nil,mfError+mfCancelButton);
   Exit;
  End;

 Assign(Txt2,Path^.Dat.ToTemp+'ncmenger.txt');
 l:=IOResult;
 Rewrite(Txt2);
 l:=IOResult;
 If L <> 0 Then
  Begin
   Close(Txt1);
   MessageBox(#3^M+#3'Не могу создать файл отчета'+Path^.Dat.ToTemp+'ncmenger.txt',Nil,mfError+mfCancelButton);
   Exit;
  End;


If Distant=0 Then DistanationSorting:=0
Else DistanationSorting:=1;


 Assign(RazdelFile,Path^.Dat.ToRAzdel+'Razdel.db');
 Reset(RazdelFile);
 i:=IOResult;
 If i<>0 Then
  Begin
   MessageBox(^M+#3+'Ошибка открытия файла разделов!',Nil,mfError+mfCancelButton);
   Exit;
  End;


R.Assign(0, 0, 0, 0);
Razdel1 := New(PBox, Init(R, 1, Nil));
Razdel1^.NewList(New(PTextCollection, Init(0,1)));
 While Not(Eof(RazdelFile)) Do
  Begin
   Read(RazdelFile,RazdelElement);
   If RazdelElement.Employ Then
    Begin
     Razdel1^.List^.Insert(
     NewStr('│'+
     RazdelElement.Kod+'000'+
	'│           0.00│           0.00│           0.00│           0.00│          0.000│         0.0000'));
     Razdel1^.SetRange(Razdel1^.List^.Count);
    End;
  End;
Close(RazdelFile);


R.Assign(0,0,0,0);
NoScreen:= New(PBox, Init(R, 1, Nil));
NoScreen^.NewList(New(PTextCollection, Init(0,1)));


Writeln(txt1,Space+'Склад: '+FormKod(Rek^.Dat.Kod)++'  Оператор: '+CurrentPassword);

Write(txt1,Space+'Включены документы отгрузки:');
For sh:=1 To Max9 Do
Case (Sh-1) Of
0:If mm[sh]=1 Then Write(txt1,' Список');
1:If mm[sh]=1 Then Write(txt1,' Тов.Ч*');
2:If mm[sh]=1 Then Write(txt1,' Физ.Л*');
3:If mm[sh]=1 Then Write(txt1,' СФ*');
4:If mm[sh]=1 Then Write(txt1,' СФБ');
5:If mm[sh]=1 Then Write(txt1,' Д*');
6:If mm[sh]=1 Then Write(txt1,' ДСФ*');
7:If mm[sh]=1 Then Write(txt1,' Д');
8:If mm[sh]=1 Then Write(txt1,' ДСФБ');
Else;
End;
Writeln(txt1);

Write(txt1,Space+'Включены документы со статусом:');
For sh:=1 To CMantissa Do
Case (Sh-1) Of
0:If ss[sh]=1 Then Write(txt1,' Оплаченные ');
1:If ss[sh]=1 Then Write(txt1,' Не оплаченные ');
Else;
End;
Writeln(txt1);

Write(txt1,Space+'Сортировка по:');
 Case Key Of
0{клиент}   :Write(txt1,'Клиенту');
1{дата отгр}:Write(txt1,'Дата отгрузки');
2{дата опл} :Write(txt1,'Сумма оплаты');
3{скидка}   :Write(txt1,'Сумма закупки');
4{оплата}   :Write(txt1,'Доходность');
5{вид док}  :Write(txt1,'Резерв');
6{Delta}    :Write(txt1,'Агент');
Else;
End;


Case Distant Of
0{клиент}   :WriteLn(txt1,' По возрастанию');
1{дата отгр}:WriteLn(txt1,' По убыванию');
Else WriteLn(txt1);
End;


Write(txt1,Space+'Вид отчета:');
Case VidReport Of
0:WriteLn(txt1,' Полный ');
1:WriteLn(txt1,' Краткий ');
Else;
End;


Write(txt1,Space+'Опорная закупка:');
Case ZakupkaOpora Of
0{клиент}   :WriteLn(txt1,Space+' Закупка для бухгалтерии');
1{дата отгр}:WriteLn(txt1,Space+' Закупка 2');
Else WriteLn(txt1);
End;



{
If (Client^.List^.Count)>=1 Then
Begin
 Writeln(txt1,'Выбранные клиенты:');
For Index:=0 To Client^.List^.Count-1 Do
Begin
s:=Client^.GetText(Index,Client^.List^.Count);
While Pos('│',s)>0 Do s[Pos('│',s)]:=' ';
Writeln(txt1,s);
End;
End;
}




R.Assign(0,0,0,0);
NewAgent := New(PBox, Init(R, 1, Nil));
NewAgent^.NewList(New(PTextCollection, Init(0,1)));

If (Agent^.List^.Count)>=1 Then
Begin
 Writeln(txt1);
 Writeln(txt1,'Выбранные агенты:');
 For Index:=0 To Agent^.List^.Count-1 Do
  Begin
   s:=Agent^.GetText(Index,Agent^.List^.Count);
   While Pos('│',s)>0 Do s[Pos('│',s)]:=' ';
   Writeln(txt1,s);
   s:=Agent^.GetText(Index,Agent^.List^.Count);
   s:=Copy(s,1+CClient+1,CClientKod);
   s:='│'+s+'│           0.00│           0.00│           0.00│           0.00│';
   NewAgent^.List^.Insert(NewStr(s));
   NewAgent^.SetRange(NewAgent^.List^.Count);
  End;
End;



R.Assign(0, 0, 0, 0);
PostList := New(PBox, Init(R, 1, Nil));
PostList^.NewList(New(PTextCollection, Init(0,1)));

If Not(CreatMAkeList(PostList)) Then
 Begin
  Dispose(PostList,Done);
  Dispose(NewAgent,Done);
  Index:=IoResult;
  Close(txt1);
  Index:=IoResult;
  Close(Txt2);
  Index:=IoResult;
  Exit;
 End;


R.Assign(0, 0, 0, 0);
GroupList := New(PBox, Init(R, 1, Nil));
GroupList^.NewList(New(PTextCollection, Init(0,1)));

If Not(CreatGroupList(GroupList)) Then
 Begin
  Dispose(PostList,Done);
  Dispose(GroupList,Done);
  Dispose(NewAgent,Done);
  Index:=IoResult;
  Close(txt1);
  Index:=IoResult;
  Close(Txt2);
  Index:=IoResult;
  Exit;
 End;

Writeln(txt1);
If OpSel=0 Then
Writeln(txt1,Space,' СПРАВКА ПО ОТГРУЗКАМ ЗА ПЕРИОД с '+Startd+' по '+Stopd+' (по выбранным клиентам)')
Else
Writeln(txt1,Space,' СПРАВКА ПО ОТГРУЗКАМ ВСЧЕТ ВЗАИМОЗАЧЕТОВ ЗА ПЕРИОД с '+Startd+' по '+Stopd+' (по выбранным клиентам)');
Writeln(txt1,Space+'┌──┬────────────────────┬────┬──────────────┬────┬────────┬───────────┬───────────┬─────┐');
Writeln(txt1,Space+'│N │Клиент              │Код │Агент         │Док.│Дата док│Сумма к опл│Сумма по ЗЦ│  %  │');
Writeln(txt1,Space+'└──┴────────────────────┴────┴──────────────┴────┴────────┴───────────┴───────────┴─────┘');
                   {123 12345678901234567890 1234 12345678901234 1234 12345678 12345678901 12345678901 12345}
AllItogo:=0;
AllZakupka:=0;
AllAkzis:=0;
AllSkidka:=0;
AllDoc:=0;


For Index:=Start To Stop Do
Begin
 Date:=DateToDateString(DateMask,Index);
 Assign(F,Path^.Dat.ToMarket+Date+'.mrk');


{MemC(IntToStr(Start,CIZena)+' '+IntToStr(Stop,CIZena)+' '+IntToStr(Cur,CIZena));}

 DInfoMsgShkala('Просматриваю продажи за '+Date+' ...',Start,Stop,Index);



 l:=IOResult;
 OldFileMode:=FileMode;
 FileMode:=ReadOnlyN;
 Reset(f,SizeOf(SuperMArketType));
 l:=Ioresult;
 FileMode:=OldFileMode;

 If L <> 0 Then
  Begin
   Writeln(txt2,'Не найден файл продаж за '+Date+'  "'+DayString[DayOfWeek(DAteStringToDate(DAteMask,Date))]+'"'+
   +' Код:'+IntToStr(L,3));
  End
Else
 Begin
  While Not (Eof(f)) Do
   Begin
  New(E,Init);
  {BlockRead(f,E^.Point,BufferMrk,Count1);}
  Count1:=0;
  ReadBufMarket(F,E,Count1);

For c1:=1 To Count1 Do
Begin
 If (E^.Point.Dat[c1].Active) Then
 If (Not(E^.Point.Dat[c1].Realiz)) Or
   ((E^.Point.Dat[c1].Realiz) And (E^.Point.Dat[c1].DocSelector in [5,6,7,8])) Then
 If E^.Point.Dat[c1].OperatorSelector=OpSel Then
 If TestAgent(E^.Point.Dat[c1].AgentKod) And (mm[E^.Point.Dat[c1].DocSelector+1]=1) Then

 If Not TestElement(E^.Point.Dat[c1].ClientKod,Client) Then
  Begin
     Add:=False;
     If (E^.Point.Dat[c1].DocSelector in [0,1,2,3,4]) Then
     Begin
      If ss[1]=1 Then Add:=True;
     End
     Else{для случая консигнации}
     Begin
          DelZerro(E^.Point.Dat[c1].Document);
          DelSpace(E^.Point.Dat[c1].Document);

          Assign(fr,Path^.Dat.ToDolg+E^.Point.Dat[c1].ClientKod+'.dlg');
          Res:=IOResult;
          BakFileMode:=FileMode;
          FileMode:=$42;
          Reset(fr,SizeOf(RealizasiaType));
          Res:=IOResult;
          FileMode:=BakFileMode;
          If Res<>0 Then
            MessageBox(^M+#3'Ошибка доступа к файлу долгов клиента '+E^.Point.Dat[c1].ClientKod+'!',
                  Nil,mfError+mfCancelButton)
          Else
          Begin
          Find:=False;
          While Not(Eof(fr)) And Not(Find) Do
           Begin
            New(er,Init);
BlockRead(fr,Er^.Point,BufferDlg,Count2);
For c2:=1 To Count2 Do
Begin
            If (StrToInt(Er^.Point.Dat[c2].Market.Document)=StrToInt(E^.Point.Dat[c1].Document))
                  And
                           (DateToDateString(DateMask,Er^.Point.Dat[c2].Market.DateC)=E^.Point.Dat[c1].DateC)
            And(Er^.Point.Dat[c2].Market.Active) Then
                Begin
                 Find:=True;
                 If ((Er^.Point.Dat[c2].Full) and (ss[1]=1)) Or
                             (Not(Er^.Point.Dat[c2].Full) and (ss[2]=1)) Then Add:=True;
                End;
End;{For}
          Dispose(Er,Done);
           End;{While}
          c2:=IOResult;
          System.Close(fr);
          If Not(Find) Then  MessageBox(^M+#3'Документ не найден в долгах клиента '+
                E^.Point.Dat[c1].ClientKod+'!',
                Nil,mfError+mfCancelButton);
          End;{Res=0 файл успешно открыт}
     End;

    If Add Then
    Begin
        Inc(AllDoc);
        FFF:=ProdagaWindow;
        ProdagaWindow:=False;

        If ZakupkaOpora=1 Then ConvertMarket(E,c1);


        For Cur:=1 To E^.Point.Dat[c1].Amount Do
         Begin
          tr:=Copy(E^.Point.Dat[c1].MArketElement[Cur].BazKod,1,CRazdelKod);
          If Not(TestRazdelMemory(tr,Razdel1)) Then
           Begin
            s:=Razdel1^.GetText(
            LocationR(Razdel1,tr,ProdagaWindow),Razdel1^.List^.Count);
            ws1:=Copy(s,1+1+CArtikul+1,CIZena);

            Case E^.Point.Dat[c1].SkidkaSelector Of
            {авто}
            0:Begin
               MyStr((StrToReal(E^.Point.Dat[c1].MarketElement[Cur].Input.Zena)/
               (1+StrToReal(E^.Point.Dat[c1].MarketElement[Cur].Input.Proz)/100)),CZena,CMantissa,
                        E^.Point.Dat[c1].MarketElement[Cur].Input.Zena);
              End;
            {ручная}
            1:Begin
               MyStr(StrToREal(E^.Point.Dat[c1].MarketElement[Cur].Input.Zena)-
                     StrToREal(E^.Point.Dat[c1].MarketElement[Cur].Input.Skidka),
                     CZena,CMantissa,E^.Point.Dat[c1].MarketElement[Cur].Input.Zena);
              End;
            Else;
            End;


            MyStr(StrToReal(ws1)+
            StrToREal(E^.Point.Dat[c1].MarketElement[Cur].Input.Zena)
            *StrToInt(E^.Point.Dat[c1].MarketElement[Cur].Input.Kol)
                  ,CIZena,CMantissa,ws1);
            Delete(s,1+1+CArtikul+1,CIZena);
            Insert(ws1,s,1+1+CArtikul+1);


            ws1:=Copy(s,1+1+CArtikul+1+CIZena+1,CIZena);
            MyStr(StrToReal(ws1)+
            StrToREal(E^.Point.Dat[c1].MarketElement[Cur].Input.Zakupka)*
                  StrToInt(E^.Point.Dat[c1].MarketElement[Cur].Input.Kol),CIZena,CMantissaZ,ws1);
            Delete(s,1+1+CArtikul+1+CIZena+1,CIZena);
            Insert(ws1,s,1+1+CArtikul+1+CiZena+1);




            {расчет литража}
            ws:=Copy(s,1+1+CArtikul+1+CIZena+1+CIZena+1+CIZena+1+CIZena+1,CIZena);
            MyStr(StrToReal(ws)+
                StrToInt(E^.Point.Dat[c1].MarketElement[Cur].Input.Kol)*
                StrToReal(GetIdField(FLitr,E^.Point.Dat[c1].MarketElement[Cur].BazKod)),
                         CIZena,CLitrMantissa,ws);
            Delete(s,1+1+CArtikul+1+CIZena+1+CIZena+1+CIzena+1+CIZena+1,CIZena);
            Insert(ws,s,1+1+CArtikul+1+CIZena+1+CIZena+1+CIZena+1+CIZena+1);


            {расчет акциза}
            ws:=Copy(s,1+1+CArtikul+1+CIZena+1+CIZena+1+CIZena+1+CIZena+1+CIZena+1,CIZena);
            MyStr(StrToReal(ws)+
                StrToInt(E^.Point.Dat[c1].MarketElement[Cur].Input.Kol)*
                StrToReal(E^.Point.Dat[c1].MarketElement[Cur].Input.AkzisSbor),
                         CIZena,CMantissaZ,ws);
            Delete(s,1+1+CArtikul+1+CIZena+1+CIZena+1+CIzena+1+CIZena+1+CIZena+1,CIZena);
            Insert(ws,s,1+1+CArtikul+1+CIZena+1+CIZena+1+CIZena+1+CIZena+1+CIZena+1);


            Razdel1^.List^.Atfree(LocationR(Razdel1,tr,ProdagaWindow));
            Razdel1^.SetRange(Razdel1^.List^.Count);
            Razdel1^.List^.Insert(NewStr(s));
            Razdel1^.SetRange(Razdel1^.List^.Count);


            MyStr(StrToInt(E^.Point.Dat[c1].MArketElement[Cur].Input.Kol)*
            StrToReal(E^.Point.Dat[c1].MArketElement[Cur].Input.Zena),CIZena,CMantissa,ww1);

            MyStr(StrToInt(E^.Point.Dat[c1].MArketElement[Cur].Input.Kol)*
            StrToReal(E^.Point.Dat[c1].MArketElement[Cur].Input.Zakupka),CIZena,CMantissaZ,ww2);

            MyStr(StrToInt(E^.Point.Dat[c1].MArketElement[Cur].Input.Kol)*
            StrToReal(E^.Point.Dat[c1].MArketElement[Cur].Input.AkzisSbor),CIZena,CMantissaZ,SSAkzis);
            DelSpace(SSAkzis);


            AddPostListOtgruska(E^.Point.DAt[c1].MarketElement[Cur].Input.NMAkeKod,
                  ww1{по оплате},ww2{по закупке},SSAkzis);

            If m[5]=1 Then
            AddGroupListOtgruska(BakGetField(FNGroupKod,E^.Point.DAt[c1].MarketElement[Cur].BazKod,0),
                  ww1{по оплате},ww2{по закупке},SSAkzis);



            {заполняем персональную статистику}
            Idx:=StrToInt(E^.Point.Dat[c1].ClientKod);

           If Not Stat[Idx].Employ Then
           Begin
            NewElement(Idx);
           End;
            {дальше идет код отвечающий за расчет по деталям для каждого клиента}

            E^.Point.Dat[c1].MarketElement[Cur].Input.Zena:=
            E^.Point.Dat[c1].MarketElement[Cur].Input.R_Zena;

            s:=Stat[Idx].RList^.GetText(
            LocationR(Stat[Idx].RList,tr,ProdagaWindow),Stat[Idx].RList^.List^.Count);
            ws1:=Copy(s,1+1+CArtikul+1,CIZena);

            Case E^.Point.Dat[c1].SkidkaSelector Of
            {авто}
            0:Begin
               MyStr((StrToReal(E^.Point.Dat[c1].MarketElement[Cur].Input.Zena)/
               (1+StrToReal(E^.Point.Dat[c1].MarketElement[Cur].Input.Proz)/100)),CZena,CMantissa,
                        E^.Point.Dat[c1].MarketElement[Cur].Input.Zena);
              End;
            {ручная}
            1:Begin
               MyStr(StrToREal(E^.Point.Dat[c1].MarketElement[Cur].Input.Zena)-
                     StrToREal(E^.Point.Dat[c1].MarketElement[Cur].Input.Skidka),
                     CZena,CMantissa,E^.Point.Dat[c1].MarketElement[Cur].Input.Zena);
              End;
            Else;
            End;


            MyStr(StrToReal(ws1)+
            StrToREal(E^.Point.Dat[c1].MarketElement[Cur].Input.Zena)
            *StrToInt(E^.Point.Dat[c1].MarketElement[Cur].Input.Kol)
                  ,CIZena,CMantissa,ws1);
            Delete(s,1+1+CArtikul+1,CIZena);
            Insert(ws1,s,1+1+CArtikul+1);


            ws1:=Copy(s,1+1+CArtikul+1+CIZena+1,CIZena);
            MyStr(StrToReal(ws1)+
            StrToREal(E^.Point.Dat[c1].MarketElement[Cur].Input.Zakupka)*
                  StrToInt(E^.Point.Dat[c1].MarketElement[Cur].Input.Kol),CIZena,CMantissaZ,ws1);
            Delete(s,1+1+CArtikul+1+CIZena+1,CIZena);
            Insert(ws1,s,1+1+CArtikul+1+CiZena+1);


            {расчет литража}
            ws:=Copy(s,1+1+CArtikul+1+CIZena+1+CIZena+1+CIZena+1+CIZena+1,CIZena);
            MyStr(StrToReal(ws)+
                StrToInt(E^.Point.Dat[c1].MarketElement[Cur].Input.Kol)*
                StrToReal(GetIdField(FLitr,E^.Point.Dat[c1].MarketElement[Cur].BazKod)),
                         CIZena,CLitrMantissa,ws);
            Delete(s,1+1+CArtikul+1+CIZena+1+CIZena+1+CIzena+1+CIZena+1,CIZena);
            Insert(ws,s,1+1+CArtikul+1+CIZena+1+CIZena+1+CIZena+1+CIZena+1);

            Stat[Idx].RList^.List^.Atfree(LocationR(Stat[Idx].RList,tr,ProdagaWindow));
            Stat[Idx].RList^.SetRange(Stat[Idx].RList^.List^.Count);
            Stat[Idx].RList^.List^.Insert(NewStr(s));
            Stat[Idx].RList^.SetRange(Stat[Idx].RList^.List^.Count);

           End;
         End;

        For Cur:=1 To E^.Point.Dat[c1].AmountS Do
         Begin
          tr:=Copy(E^.Point.Dat[c1].DocumentElement[Cur].BazKod,1,CRazdelKod);
          tr:=IntToStr(StrToInt(tr),CRazdelKod);
          RFormatZerro(tr,CRazdelKod);

          If Not(TestRazdelMemory(tr,Razdel1)) Then
           Begin
            s:=Razdel1^.GetText(
            LocationR(Razdel1,tr,ProdagaWindow),Razdel1^.List^.Count);
            ws1:=Copy(s,1+1+CArtikul+1,CIZena);

            Case E^.Point.Dat[c1].SkidkaSelector Of
            {авто}
            0:Begin
               MyStr((StrToReal(E^.Point.Dat[c1].DocumentElement[Cur].Input.Zena)/
               (1+StrToReal(E^.Point.Dat[c1].DocumentElement[Cur].Input.Proz)/100)),CZena,CMantissa,
                        E^.Point.Dat[c1].DocumentElement[Cur].Input.Zena);
              End;
            {ручная}
            1:Begin
               MyStr(StrToREal(E^.Point.Dat[c1].DocumentElement[Cur].Input.Zena)-
                     StrToREal(E^.Point.Dat[c1].DocumentElement[Cur].Input.Skidka),
                     CZena,CMantissa,E^.Point.Dat[c1].DocumentElement[Cur].Input.Zena);
              End;
            Else;
            End;


            MyStr(StrToReal(ws1)+
            StrToREal(E^.Point.Dat[c1].DocumentElement[Cur].Input.Zena)
            *StrToInt(E^.Point.Dat[c1].DocumentElement[Cur].Input.Kol)
                  ,CIZena,CMantissa,ws1);
            Delete(s,1+1+CArtikul+1,CIZena);
            Insert(ws1,s,1+1+CArtikul+1);


            ws1:=Copy(s,1+1+CArtikul+1+CIZena+1,CIZena);
            MyStr(StrToReal(ws1)+
            StrToREal(E^.Point.Dat[c1].DocumentElement[Cur].Input.Zakupka)*
            StrToInt(E^.Point.Dat[c1].DocumentElement[Cur].Input.Kol),CIZena,CMantissaZ,ws1);
            Delete(s,1+1+CArtikul+1+CIZena+1,CIZena);
            Insert(ws1,s,1+1+CArtikul+1+CiZena+1);

            Razdel1^.List^.Atfree(LocationR(Razdel1,tr,ProdagaWindow));
            Razdel1^.SetRange(Razdel1^.List^.Count);
            Razdel1^.List^.Insert(NewStr(s));
            Razdel1^.SetRange(Razdel1^.List^.Count);

            MyStr(StrToInt(E^.Point.Dat[c1].DocumentElement[Cur].Input.Kol)*
            StrToReal(E^.Point.Dat[c1].DocumentElement[Cur].Input.Zena),CIZena,CMantissa,ww1);

            MyStr(StrToInt(E^.Point.Dat[c1].DocumentElement[Cur].Input.Kol)*
            StrToReal(E^.Point.Dat[c1].DocumentElement[Cur].Input.Zakupka),CIZena,CMantissaZ,ww2);

            AddPostListOtgruska(E^.Point.DAt[c1].DocumentElement[Cur].Input.NMAkeKod,
                  ww1{по оплате},ww2{по закупке},'0.0000');

            If m[5]=1 Then
            AddGroupListOtgruska(BakGetField(FNGroupKod,E^.Point.DAt[c1].DocumentElement[Cur].BazKod,0),
                  ww1{по оплате},ww2{по закупке},'0.0000');

            {заполняем персональную статистику}
            Idx:=StrToInt(E^.Point.Dat[c1].ClientKod);

           If Not Stat[Idx].Employ Then
           Begin
            NewElement(Idx);
           End;
            {дальше идет код отвечающий за расчет по деталям для каждого клиента}

            E^.Point.Dat[c1].DocumentElement[Cur].Input.Zena:=
            E^.Point.Dat[c1].DocumentElement[Cur].Input.R_Zena;

            s:=Stat[Idx].RList^.GetText(
            LocationR(Stat[Idx].RList,tr,ProdagaWindow),Stat[Idx].RList^.List^.Count);
            ws1:=Copy(s,1+1+CArtikul+1,CIZena);

            Case E^.Point.Dat[c1].SkidkaSelector Of
            {авто}
            0:Begin
               MyStr((StrToReal(E^.Point.Dat[c1].DocumentElement[Cur].Input.Zena)/
               (1+StrToReal(E^.Point.Dat[c1].DocumentElement[Cur].Input.Proz)/100)),CZena,CMantissa,
                        E^.Point.Dat[c1].DocumentElement[Cur].Input.Zena);
              End;
            {ручная}
            1:Begin
               MyStr(StrToREal(E^.Point.Dat[c1].DocumentElement[Cur].Input.Zena)-
                     StrToREal(E^.Point.Dat[c1].DocumentElement[Cur].Input.Skidka),
                     CZena,CMantissa,E^.Point.Dat[c1].DocumentElement[Cur].Input.Zena);
              End;
            Else;
            End;


            MyStr(StrToReal(ws1)+
            StrToREal(E^.Point.Dat[c1].DocumentElement[Cur].Input.Zena)
            *StrToInt(E^.Point.Dat[c1].DocumentElement[Cur].Input.Kol)
                  ,CIZena,CMantissa,ws1);
            Delete(s,1+1+CArtikul+1,CIZena);
            Insert(ws1,s,1+1+CArtikul+1);


            ws1:=Copy(s,1+1+CArtikul+1+CIZena+1,CIZena);
            MyStr(StrToReal(ws1)+
            StrToREal(E^.Point.Dat[c1].DocumentElement[Cur].Input.Zakupka)*
            StrToInt(E^.Point.Dat[c1].DocumentElement[Cur].Input.Kol),CIZena,CMantissaZ,ws1);
            Delete(s,1+1+CArtikul+1+CIZena+1,CIZena);
            Insert(ws1,s,1+1+CArtikul+1+CiZena+1);

            Stat[Idx].RList^.List^.Atfree(LocationR(Stat[Idx].RList,tr,ProdagaWindow));
            Stat[Idx].RList^.SetRange(Stat[Idx].RList^.List^.Count);
            Stat[Idx].RList^.List^.Insert(NewStr(s));
            Stat[Idx].RList^.SetRange(Stat[Idx].RList^.List^.Count);

           End;
         End;

         Inc(Stat[StrToInt(E^.Point.Dat[c1].ClientKod)].DocKol);



        ws:=GetClientField(FClient,E^.Point.Dat[c1].ClientKod,E^.Point.Dat[c1].OperatorSelector);
        Clshk:='0'{GetClientField(FShkala,E^.Dat.ClientKod,0)};
        Format(ws,CClient);

        DelSpace(E^.Point.Dat[c1].Document);
        RFormat(E^.Point.Dat[c1].Document,CDocNumer);

        AgName:=GetAgentField(FAgent,E^.Point.Dat[c1].AgentKod);
        Format(AgName,CClient-6);

        If (StrToReal(E^.Point.Dat[c1].SummaZakupka)>0.009) Then
         Begin
           Str(
          (StrToReal(E^.Point.Dat[c1].SummaZ)-StrToReal(E^.Point.Dat[c1].SummaZakupka))/
           StrToReal(E^.Point.Dat[c1].SummaZakupka)*100:CLitr+1:CMAntissa,Dohod);
         End
        Else
          Dohod:='  0.00';


        AllItogo:=AllItogo+StrToreal(E^.Point.Dat[c1].SummaZ);
        Allzakupka:=AllZakupka+StrToreal(E^.Point.Dat[c1].SummaZakupka);
        AllAkzis:=AllAkzis+StrToreal(E^.Point.Dat[c1].SummaAkzis);
        AllSkidka:=AllSkidka+StrToreal(E^.Point.Dat[c1].Skidka);

        DelSpace(E^.Point.Dat[c1].SummaZ);
        {RFormat(E^.Dat.SummaZ,CIZena-4);}
        MyStr(StrToReal(E^.Point.Dat[c1].SummaZ),CIZena-4,CMantissa,E^.Point.Dat[c1].SummaZ);
        DelSpace(E^.Point.Dat[c1].SummaZakupka);
        MyStr(StrToReal(E^.Point.Dat[c1].SummaZakupka),CIZena-4,CMantissaZ,E^.Point.Dat[c1].SummaZakupka);
        {RFormat(E^.Dat.SummaZakupka,CIZena-4);}

        s[0]:=#0;
        s:=s+ws+SeparatorChar+E^.Point.Dat[c1].ClientKod+SeparatorChar+AgName+SeparatorChar+
           +E^.Point.Dat[c1].Document+SeparatorChar+E^.Point.Dat[c1].DAteC+SeparatorChar+
                 E^.Point.Dat[c1].SummaZ+SeparatorChar+
           E^.Point.Dat[c1].SummaZakupka+SeparatorChar+
           Dohod+SeparatorChar+ClShk;


        Case Key Of
        1{дата отгр}:Begin
                       tr:=IntToStr(
                       DateStringToDate(DAteMask,E^.Point.Dat[c1].DateC),CKol+1);
                          s:=tr+SeparatorChar+s;
                     End;
        2{Сумма опл}:s:=E^.Point.Dat[c1].SummaZ+SeparatorChar+s;
        3{Сумма зак}:Begin
                         s:=E^.Point.Dat[c1].SummaZakupka+SeparatorChar+s;
                     End;
        4{доход}  :s:=Dohod+SeparatorChar+s;
        5{шкала клиентов}:s:=ClShk+SeparatorChar+s;
        6{агент}  : s:=AgName+SeparatorChar+s;
        Else;
        End;

       AddAgentSumma(E^.Point.Dat[c1].AgentKod,E^.Point.Dat[c1].SummaZ,'0.00',
          E^.Point.Dat[c1].SummaZakupka,E^.Point.Dat[c1].SummaAkzis);





      If NoScreen^.List^.Count<=MaxCollectionSize-1 Then
      Begin
        NoScreen^.List^.Insert(NewStr(s));
        NoScreen^.SetRange(NoScreen^.List^.Count);
      End;
   End;{Add}
       End;{If}
End;{For}
 Dispose(E,Done);
   End;{While}
   Close(f);
 End;{If l=0}

 End;{For по клиентам}


If VidReport=0 Then
If NoScreen^.List^.Count>=1 Then
 Begin
  For Den:=0 To NoScreen^.List^.Count-1 Do
   Begin
     s:=NoScreen^.GetText(Den,NoScreen^.List^.Count);
        Case Key Of
        1{дата отгр}:Delete(s,1,CKol+1+1);
        2{сумма опл}:Delete(s,1,(CIZena-4)+1);
        3{сумма зак}:Delete(s,1,(CIZena-4)+1);
        4{доход}    :Delete(s,1,CLitr+1+1);
        5{шкала кли}:Delete(s,1,1+1);
        6{агент}    :Delete(s,1,(CClient-6)+1);
        Else;
        End;

        s[0]:=Chr(Ord(s[0])-2);

        ws:=IntToStr(dEN+1,3);
        RFormat(ws,CLitrMantissa);


     Writeln(txt1,Space+wS+SeparatorChar+s);


   End;
 End;


Writeln(txt1,Space+'────────────────────────────────────────────────────────────────────────────────────────-');


Writeln(Txt1,Space+'                                                    Всего документов:'+SeparatorChar,
AllDoc:CIZena);
Writeln(Txt1,Space+
'                                                     Всего отгружено:'+SeparatorChar,RecognizReal(AllItogo,CIZena,CMantissa));
Writeln(Txt1,Space+
'                                                        Всего по З/Ц:'+SeparatorChar,RecognizReal(AllZakupka,CIZena,
CMantissaZ));
Writeln(Txt1,Space+
'                                                 Всего акцизный сбор:'+SeparatorChar,RecognizReal(AllAkzis,CIZena,
CMantissaZ));
If AllZakupka>0.009 Then
Begin
Writeln(Txt1,Space+
'                                                       Всего доход %:'+SeparatorChar,
RecognizReal((AllItogo-AllZakupka-AllAkzis)/AllZakupka*100,CIZena,CMantissa));
End;

Writeln(Txt1,Space+
'                                                         Всего доход:'+SeparatorChar,
RecognizReal(AllItogo-AllZakupka-AllAkzis,CIZena,
CMantissaZ));
Dispose(NoScreen,Done);
DistanationSorting:=0;
Writeln(txt1);



NoInfoMsg;
{закончили с продажами}


AllReturn:=0;
AllSkidkaReturn:=0;
AllReturnDoc:=0;
AllReturnZakupka:=0;
AllReturnAkzis:=0;

Writeln(txt1);
Writeln(txt1,Space+'СПРАВКА О ВОЗВРАТАХ за ПЕРИОД с '+StartD+' по '+StopD);

Writeln(txt1,Space+'┌──┬────────────────────┬───┬────────┬───┬────────┬─────────────┬─────────────┬──────────┐');
Writeln(txt1,Space+'│N │Клиент              │Док│Дата отг│Взв│Дата взв│ Сумма возвр.│ Сумма возвр.│Упущенный │');
                   {123 12345678901234567890 123 12345789 123 12345678 1234567890123 1234567890123 12345.7890}
Writeln(txt1,Space+'│  │                    │   │        │   │        │ по ценам опл│    по З/Ц   │  доход   │');
Writeln(txt1,Space+'└──┴────────────────────┴───┴────────┴───┴────────┴─────────────┴─────────────┴──────────┘');

AllReturnZakupka:=0;
AllReturnAkzis:=0;
AllReturn:=0;
AllReturnDoc:=0;

New(Ret,Init);

For Index:=Start To Stop Do
Begin
 Date:=DateToDateString(DateMask,Index);
 DInfoMsgShkala('Просматриваю возвраты за '+Date+' ...',Start,Stop,Index);
 Assign(RetF,Path^.Dat.ToReturn+Date+'.vzw');
 l:=IOResult;
 OldFileMode:=FileMode;
 FileMode:=ReadOnlyN;
 Reset(Retf);
 l:=Ioresult;
 FileMode:=OldFileMode;
 If l<>0 Then
  Begin
   Writeln(txt2,'Не найден файл возвратов за '+Date+'  "'+DayString[DayOfWeek(DAteStringToDate(DAteMask,Date))]+'"'+
   +' Код:'+IntToStr(L,3));
  End
 Else
 Begin
  While Not (Eof(Retf)) Do
   Begin
      ReadNewVozwrat(Retf,Ret);

If (Ret^.Dat.OperatorSelector=OpSel) Then
If mm[Ret^.Dat.DocSelector+1]=1 Then
    If (Ret^.Dat.StatusDoc=0) then
If Not TestElement(Ret^.Dat.MakeKod,Client) Then
       Begin
       If CalcAgentfromMrk(Ret^.Dat.BasisDoc,Ret^.Dat.BasisDate,Ag) Then
Begin

    If TestAgent1(Ag) Then
Begin


       If ZakupkaOpora=1 Then Convertreturn(Ret);


        For Cur:=1 To Ret^.Dat.Amount Do
         Begin
          If Not(TestRazdelMemory(Ret^.Dat.VozwratElement[cur].BazKod,Razdel1)) Then
           Begin
            s:=Razdel1^.GetText(
            LocationR(Razdel1,Ret^.Dat.VozwratElement[Cur].BazKod,ProdagaWindow),Razdel1^.List^.Count);


Case Ret^.Dat.VidDocument Of
0,2,4:{Авто}
       Begin
        {получили новую цену с учетом скидки}
        MyStr(StrToReal(Ret^.Dat.VozwratElement[Cur].Input.Zena)/
        (1+StrToReal(Ret^.Dat.VozwratElement[Cur].Input.LocalProz)/100),CZena,
           CMantissa,Ret^.Dat.VozwratElement[Cur].Input.Zena);
       End;

1,3,5:{Ручная}
        Begin
          MyStr(StrToReal(Ret^.Dat.VozwratElement[Cur].Input.Zena)-
                    StrToReal(Ret^.Dat.VozwratElement[Cur].Input.LocalSkidka),CZena,CMantissa,
                    Ret^.Dat.VozwratElement[Cur].Input.Zena);
        End;
Else;
End;{Case}

            ws1:=Copy(s,1+1+CArtikul+1+CIZena+1+CIZena+1,CIZena);
            MyStr(StrToReal(ws1)+
                StrToInt(Ret^.DAt.VozwratElement[Cur].Input.Kol)*
                StrToReal(Ret^.DAt.VozwratElement[Cur].Input.Zena),CIZena,CMantissa,ws1);
            Delete(s,1+1+CArtikul+1+CIZena+1+CIZena+1,CIzena);
            Insert(ws1,s,1+1+CArtikul+1+CIZena+1+CIZena+1);

            ws:=Copy(s,1+1+CArtikul+1+CIZena+1+CIZena+1+CIZena+1,CIZena);
            MyStr(StrToReal(ws)+
                StrToInt(Ret^.DAt.VozwratElement[Cur].Input.Kol)*
                StrToReal(Ret^.DAt.VozwratElement[Cur].Input.Zakupka),CIZena,CMantissaZ,ws);
            Delete(s,1+1+CArtikul+1+CIZena+1+CIZena+1+CIzena+1,CIZena);
            Insert(ws,s,1+1+CArtikul+1+CIZena+1+CIZena+1+CIZena+1);

            {расчет литража возвраты вычитаем}
            {MemC(ws);}
            ws:=Copy(s,1+1+CArtikul+1+CIZena+1+CIZena+1+CIZena+1+CIZena+1,CIZena);
            MyStr(StrToReal(ws)-
                StrToInt(Ret^.DAt.VozwratElement[Cur].Input.Kol)*
                StrToReal(GetIdField(FLitr,Ret^.DAt.VozwratElement[Cur].BazKod)),
                         CIZena,CLitrMantissa,ws);
            {MemC(ws);}
            Delete(s,1+1+CArtikul+1+CIZena+1+CIZena+1+CIzena+1+CIZena+1,CIZena);
            Insert(ws,s,1+1+CArtikul+1+CIZena+1+CIZena+1+CIZena+1+CIZena+1);


            {расчет акциза}
            ws:=Copy(s,1+1+CArtikul+1+CIZena+1+CIZena+1+CIZena+1+CIZena+1+CIZena+1,CIZena);
            MyStr(StrToReal(ws)-
                StrToInt(Ret^.DAt.VozwratElement[Cur].Input.Kol)*
                StrToReal(Ret^.DAt.VozwratElement[Cur].Input.AkzisSbor),
                         CIZena,CMantissaZ,ws);
            Delete(s,1+1+CArtikul+1+CIZena+1+CIZena+1+CIzena+1+CIZena+1+CIZena+1,CIZena);
            Insert(ws,s,1+1+CArtikul+1+CIZena+1+CIZena+1+CIZena+1+CIZena+1+CIZena+1);




            Razdel1^.List^.Atfree(LocationR(Razdel1,Ret^.Dat.VozwratElement[Cur].BazKod,ProdagaWindow));
            Razdel1^.SetRange(Razdel1^.List^.Count);
            Razdel1^.List^.Insert(NewStr(s));
            Razdel1^.SetRange(Razdel1^.List^.Count);

            MyStr(StrToInt(Ret^.DAt.VozwratElement[Cur].Input.Kol)*
                  StrToReal(Ret^.DAt.VozwratElement[Cur].Input.Zakupka),CIZena,CMantissaZ,ww2);

            MyStr(StrToInt(Ret^.DAt.VozwratElement[Cur].Input.Kol)*
                  StrToReal(Ret^.DAt.VozwratElement[Cur].Input.Zena),CIZena,CMantissa,ww1);

            MyStr(StrToInt(Ret^.DAt.VozwratElement[Cur].Input.Kol)*
                  StrToReal(Ret^.DAt.VozwratElement[Cur].Input.AkzisSbor),CIZena,CMantissaZ,SSAkzis);
                  DelSpace(SSAkzis);

            AddPostListReturn(Ret^.Dat.VozwratElement[Cur].Input.NMAkeKod,
                  ww1{по оплате},ww2{по закупке},SSAkzis);

            If m[5]=1 Then
            AddGroupListReturn(BakGetField(FNGroupKod,Ret^.Dat.VozwratElement[Cur].BazKod,0),
                  ww1{по оплате},ww2{по закупке},SSAkzis);

            {заполняем персональную статистику}
            Idx:=StrToInt(Ret^.Dat.MAkeKod);

           If Not Stat[Idx].Employ Then
           Begin
            NewElement(Idx);
           End;
            {дальше идет код отвечающий за расчет по деталям для каждого клиента}

            Ret^.Dat.VozwratElement[Cur].Input.Zena:=
            Ret^.Dat.VozwratElement[Cur].Input.R_Zena;

            s:=Stat[Idx].RList^.GetText(
            LocationR(Stat[Idx].RList,Ret^.Dat.VozwratElement[Cur].BazKod,ProdagaWindow),Stat[Idx].RList^.List^.Count);



Case Ret^.Dat.VidDocument Of
0,2,4:{Авто}
       Begin
        {получили новую цену с учетом скидки}
        MyStr(StrToReal(Ret^.Dat.VozwratElement[Cur].Input.Zena)/
        (1+StrToReal(Ret^.Dat.VozwratElement[Cur].Input.LocalProz)/100),CZena,
           CMantissa,Ret^.Dat.VozwratElement[Cur].Input.Zena);
       End;

1,3,5:{Ручная}
        Begin
          MyStr(StrToReal(Ret^.Dat.VozwratElement[Cur].Input.Zena)-
                    StrToReal(Ret^.Dat.VozwratElement[Cur].Input.LocalSkidka),CZena,CMantissa,
                    Ret^.Dat.VozwratElement[Cur].Input.Zena);
        End;
Else;
End;{Case}


            ws1:=Copy(s,1+1+CArtikul+1+CIZena+1+CIZena+1,CIZena);
            MyStr(StrToReal(ws1)+
                StrToInt(Ret^.DAt.VozwratElement[Cur].Input.Kol)*
                StrToReal(Ret^.DAt.VozwratElement[Cur].Input.Zena),CIZena,CMantissa,ws1);
            Delete(s,1+1+CArtikul+1+CIZena+1+CIZena+1,CIzena);
            Insert(ws1,s,1+1+CArtikul+1+CIZena+1+CIZena+1);

            ws:=Copy(s,1+1+CArtikul+1+CIZena+1+CIZena+1+CIZena+1,CIZena);
            MyStr(StrToReal(ws)+
                StrToInt(Ret^.DAt.VozwratElement[Cur].Input.Kol)*
                StrToReal(Ret^.DAt.VozwratElement[Cur].Input.Zakupka),CIZena,CMantissaZ,ws);
            Delete(s,1+1+CArtikul+1+CIZena+1+CIZena+1+CIzena+1,CIZena);
            Insert(ws,s,1+1+CArtikul+1+CIZena+1+CIZena+1+CIZena+1);

            {расчет литража возвраты вычитаем}
            {MemC(ws);}
            ws:=Copy(s,1+1+CArtikul+1+CIZena+1+CIZena+1+CIZena+1+CIZena+1,CIZena);
            MyStr(StrToReal(ws)-
                StrToInt(Ret^.DAt.VozwratElement[Cur].Input.Kol)*
                StrToReal(GetIdField(FLitr,Ret^.DAt.VozwratElement[Cur].BazKod)),
                         CIZena,CLitrMantissa,ws);
            {MemC(ws);}
            Delete(s,1+1+CArtikul+1+CIZena+1+CIZena+1+CIzena+1+CIZena+1,CIZena);
            Insert(ws,s,1+1+CArtikul+1+CIZena+1+CIZena+1+CIZena+1+CIZena+1);

            Stat[Idx].RList^.List^.Atfree(LocationR(Stat[Idx].RList,Ret^.Dat.VozwratElement[Cur].BazKod,ProdagaWindow));
            Stat[Idx].RList^.SetRange(Stat[Idx].RList^.List^.Count);
            Stat[Idx].RList^.List^.Insert(NewStr(s));
            Stat[Idx].RList^.SetRange(Stat[Idx].RList^.List^.Count);

           End;
         End;

        Inc(Stat[StrToInt(Ret^.Dat.MakeKod)].DocKolRet);

        DelSpace(Ret^.Dat.BasisDate);
        Inc(AllReturnDoc);
        s:=IntToStr(AllReturnDoc,3);
        RFormat(s,CLitrMantissa);
        ws:=GetClientField(FClient,Ret^.Dat.MakeKod,Ret^.Dat.OperatorSelector);
        Format(ws,CClient);
        s:=s+SeparatorChar+ws;

        DelSpace(Ret^.Dat.Document);
        RFormat(Ret^.Dat.Document,CDocNumer-1);
        Format(REt^.Dat.DateC,CDate);

        DelSpace(Ret^.Dat.BasisDoc);
        RFormat(Ret^.Dat.BasisDoc,CDocNumer-1);
        Format(REt^.Dat.BasisDate,CDate);

        MyStr(StrToReal(RET^.Dat.SummaR)-StrToReal(RET^.Dat.Skidka),CIZena-2,CMantissa,ws);

(*
*)
        MyStr(StrToReal(RET^.Dat.SummaR)-StrToReal(RET^.Dat.Skidka),CIZena-2,CMantissaZ,RET^.Dat.SummaR);
        MyStr(StrToReal(RET^.Dat.SummaZakupka),CIZena-2,CMantissaZ,RET^.Dat.SummaZakupka);

        MyStr(StrToReal(RET^.Dat.SummaR)-StrToReal(RET^.Dat.SummaZakupka),CIZena-5,CMantissaZ,NoDohod);


        AllReturn:=AllReturn+StrToreal(RET^.Dat.SummaR);
        AllReturnZakupka:=AllReturnZakupka+StrToreal(RET^.Dat.SummaZakupka);
        AllReturnAkzis:=AllReturnAkzis+StrToreal(RET^.Dat.SummaAkzis);


{вставка по просьюе гончарова 20/05/2003
 такая же есть в отчете по оплатам}
        A.EditPosition:=Ret^.Dat.BasisDoc;
        A.D:=Ret^.Dat.BasisDate;

        SumRetOpl[0]:=#0;
        MyStr(StrToReal(Ret^.Dat.SummaR)-StrToReal(Ret^.Dat.Skidka),CIZena-1,CMAntissa,SumRetOpl);

        MyStr(StrToReal(RET^.Dat.SummaAkzis),CIZena-1,CMantissaZ,RET^.Dat.SummaAkzis);
        DelSpace(RET^.Dat.SummaAkzis);

        MyStr(StrToReal(RET^.Dat.SummaZakupka),CIZena-1,CMantissaZ,RET^.Dat.SummaZakupka);
        DelSpace(RET^.Dat.SummaZakupka);

        AddAgentSumma(Ag,'-'+SumRetOpl,'0.00',
          '-'+Ret^.Dat.SummaZakupka,Ret^.Dat.SummaAkzis);

{
        New(EEE,Init);

        If GetMArketSpecial(A,EEE) Then
         Begin
          AddAgentSumma(EEE^.Dat.AgentKod,'-'+SumRetOpl,'0.00',
          '-'+Ret^.Dat.SummaZakupka,Ret^.Dat.SummaAkzis);
         End
         Else
          Begin
           MessageBox(^M+#3'Не могу определить код агента в возвратах',Nil,mfError+mfCancelButton);
          End;

        Dispose(EEE,Done);
}

        s:=s+SeparatorChar+Ret^.Dat.BasisDoc+SeparatorChar+
           Ret^.Dat.BasisDate+SeparatorChar+Ret^.Dat.Document+SeparatorChar+
           REt^.Dat.DateC+SeparatorChar+Ret^.Dat.SummaR+SeparatorChar+
           Ret^.Dat.SummaZakupka+SeparatorChar+NoDohod;

If VidReport=0 Then
        Writeln(txt1,Space+s)
End;{TestAgent(Ag)}
End;{CalcAgentfromMrk}
       End;{If}
   End;{While}
   Close(Retf);
 End;{If l=0}
End;{For}

NoInfoMsg;

Dispose(Ret,Done);



DInfoMsg('Сохраняю промежуточные результаты расчета ...',True);


Writeln(txt1,Space+'──────────────────────────────────────────────────────────────────────────────────────────');
Writeln(Txt1,Space+'                                        Всего документов:'+SeparatorChar,
AllReturnDoc:CIZena);
Writeln(Txt1,Space+
                   '                           Всего возврат по ценам оплаты:'+SeparatorChar,
                            RecognizReal(AllReturn-AllSkidkaReturn,
                            CIZena,CMantissa));

Writeln(Txt1,Space+
                   '                                Всего возврат по З/Ценам:'+SeparatorChar,RecognizReal(AllReturnZakupka,
                            CIZena,CMantissaZ));
Writeln(Txt1,Space+
                   '                        Всего акцизный сбор по возвратам:'+SeparatorChar,RecognizReal(AllReturnAkzis,
                            CIZena,CMantissaZ));

Writeln(Txt1,Space+
                   '                                   Всего упущенный доход:'+SeparatorChar,RecognizReal(AllReturn-
                            AllReturnZakupka-AllReturnAkzis,
                            CIZena,CMantissa));


ProdagaWindow:=FFF;



If M[1]=1 Then
Begin
If (Razdel1^.List^.Count-1)>=0 Then
Begin
Space:='';
Writeln(txt1,GlobalPrn^.Dat.Condensed[Nprint^.DAt.Printer]);
If OpSel=0 Then
Writeln(txt1,Space+'ИТОГОВАЯ СПРАВКА ПО ОТГРУЗКАМ ПО РАЗДЕЛАМ (для выбранных клиентов)')
Else
Writeln(txt1,Space+'ИТОГОВАЯ СПРАВКА ПО ОТГРУЗКАМ ВСЧЕТ ВЗАИМОЗАЧЕТОВ ПО РАЗДЕЛАМ (для выбранных клиентов)');
Writeln(txt1,Space+'┌─┬────────────────────┬───────────────┬───────────────┬───────────────┬───────────────┬───────────────'+
'─┬──────────────┬─────┐');
Writeln(txt1,Space+'│N│Раздел              │ Сумма отгрузки│ Сумма отгрузки│Сумма возвратов│Сумма возвратов│ Итого литров, '+
' │Акцизный сбор │Рент.│');
Writeln(txt1,Space+'│ │                    │по ценам оплаты│     по З/Ц    │по ценам оплаты│     по З/Ц    │ за вычетом воз'+
'в│за вычетом воз│     │');
Writeln(txt1,Space+'└─┴────────────────────┴───────────────┴───────────────┴───────────────┴───────────────┴───────────────'+
'─┴──────────────┴─────┘');
                   {12 12345678901234567890 123456789012345 123456789012345 123456789012345 123456789012345 123456789012345
			    123456789012345│1234}


(*
Writeln(txt1,Space+'┌─┬────────────────────┬───────────────┬───────────────┬───────────────┬───────────────┬─────┐');
Writeln(txt1,Space+'│N│Раздел              │ Сумма отгрузки│ Сумма отгрузки│Сумма возвратов│Сумма возвратов│Рент.│');
Writeln(txt1,Space+'│ │                    │по ценам оплаты│     по З/Ц    │по ценам оплаты│     по З/Ц    │  %  │');
Writeln(txt1,Space+'└─┴────────────────────┴───────────────┴───────────────┴───────────────┴───────────────┴─────┘');
*)
                   {12 12345678901234567890 123456789012345 123456789012345 123456789012345 123456789012345 123456}

AllLitr:=0;
AllAkzis:=0;

For Cur:=0 To Razdel1^.List^.Count-1 Do
 Begin
  s:=Razdel1^.GetText(Cur,Razdel1^.List^.Count);
  While Pos('│',s)>0 Do s[Pos('│',s)]:=SeparatorChar;
  Delete(s,1,1);

  ws1:=Copy(s,1,CRazdelKod);
  Delete(s,1+CRazdelKod,3);
  ws1:=GetRazdel(ws1);
  Format(ws1,CRazdel);

  Insert(ws1+SeparatorChar,s,1+CRazdelKod+1);



  ws1:=Copy(s,1+CRazdelKod+1+CRazdel+1,CIZena);{отгрузка Р/Ц}
  ws:=Copy(s,1+CRazdelKod+1+CRazdel+1+CIZena+1,CIZena);{отгрузка З/Ц}

  ws2:=Copy(s,1+CRazdelKod+1+CRazdel+1+CIZena+1+CIZena+1,CIZena);{возврат Р/Ц}
  ws3:=Copy(s,1+CRazdelKod+1+CRazdel+1+CIZena+1+CIZena+1+CIZena+1,CIZena);{возврат З/Ц}

  ws4:=Copy(s,1+CRazdelKod+1+CRazdel+1+CIZena+1+CIZena+1+CIZena+1+CIZena+1,CIZena);{литраж}
  ws5:=Copy(s,1+CRazdelKod+1+CRazdel+1+CIZena+1+CIZena+1+CIZena+1+CIZena+1+CIZena+1,CIZena);{Акциз}


If (Abs(StrToReal(ws1))>0.009)Or (Abs(StrToReal(ws))>0.009)Or (Abs(StrToReal(ws2))>0.009)
Or (Abs(StrToReal(ws3))>0.009)Or (Abs(StrToReal(ws4))>0.009) Or (Abs(StrToReal(ws5))>0.009)
Then
Begin

  MyStr(StrToReal(ws1)-StrToReal(ws2),CIZena,CMantissaZ,ws1);
  MyStr(StrToReal(ws)-StrToReal(ws3),CIZena,CMantissaZ,ws);

  AllLitr:=AllLitr+StrToReal(ws4);
  AllAkzis:=AllAkzis+StrToReal(ws5);

If ((StrToReal(ws))>0.009) Then
Str((StrToReal(ws1)-StrToReal(ws)-StrToReal(ws5))/StrToReal(ws)*100:CLitr+1:CMantissa,ws1)
Else
 If StrToReal(ws1)>0.009 Then
  ws1:='100.00'
 Else
  ws1:='  0.00';

  s:=s+SeparatorChar+ws1;
  Writeln(txt1,Space+s);
End;
 End;{}
End;

Writeln(txt1,Space+
'──────────────────────────────────────────────────────────────────────────────────────────────────────────────'+
'───────────────────────'+
GlobalPrn^.Dat.NoCondensed[Nprint^.DAt.Printer]);

Writeln(txt1,Space+'Всего алкогольной продукции:'+SeparatorChar,RecognizReal(AllLitr/10,CIZena,CLitrMantissa)+' Далл.');
Writeln(txt1,Space+'Всего акцизный сбор составил за вычетом возвратов:'+
SeparatorChar,RecognizReal(AllAkzis,CIZena,CMantissaZ)+' руб.');
End;{M[1]=1}

If M[2]=1 Then
Begin
CreatReportFromAgent(txt1);
End;
  Writeln(txt1);

If M[3]=1 Then
Begin
CreatReportFromPost(txt1);
End;

If m[5]=1 Then
CreatReportFromGroup(txt1);

Close(txt2);
i:=IoResult;
Reset(txt2);
i:=IoResult;
If IOResult=0 Then
Begin
If Not(Eof(txt2)) Then
 Begin
  Writeln(txt1);
  Writeln(txt1,'[Примечание]');
 End;
 While Not(Eof(txt2)) Do
 Begin
  Readln(txt2,s);
  Writeln(txt1,Space+s);
 End;
i:=IoResult;
 Close(txt2);
i:=IoResult;
End;

Space[0]:=#0;
Writeln(Txt1);
Writeln(Txt1,Space+'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
Writeln(Txt1,Space+'===========================================================================================');

i:=IoResult;
Close(txt1);
i:=IoResult;

Dispose(NewAgent,Done);
Dispose(PostList,Done);
Dispose(GroupList,Done);

NoInfoMsg;

If m[4]=1 Then
CreatDetalReport;

DInfoMsg('Уничтожаю промежуточные результаты расчета...',True);
Dispose(Razdel1,Done);
DoneArrayList;
NoInfoMsg;

ViewAsText(Path^.Dat.ToTemp+'ncmengob.txt','Справка по отгрузка за период с '+StartDate+' по '+StopDate,True);
End;{CalcMenedger2}




Procedure CreatRouteReport;

Begin
End;





End.