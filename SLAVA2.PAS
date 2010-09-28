{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}

{$I Compile.INC}


unit Slava2;

Interface

Uses Dialogs,Drivers,ServStr,MyCalc,Nastr,Glob;

{Procedure SelectVidDoc;}
Procedure CalcMenedgerOtgruz(Filtr,Oplata:Word;StartDate,StopDate:TDatestring;P:PBox);
Procedure CalcDolgDebitAgent;
Procedure CalcMenedger2(Const Client,Agent:PBox; Filtr,Oplata:Word;StartD,StopD:TDateString;
OpSel : Word);
Procedure ConvertMarket(Var E:PSuperMarketType;j:Word);
Procedure ConvertReturn(Var E:PVozwratType);
Function CalcAgentfromMrk(Doc:ArtikulStr;Date:TDateString;Var Cod : ArtikulStr):Boolean;
Function CalcSrokOpozdania(Cl:ArtikulStr;Num:ArtikulStr;Date,DateR:TDateString):AllStr;
Procedure CAlcZenaFromVozwrat(VAr Ret : PNewVozwratType;L : Word);

Implementation

uses Objects, Views, MsgBox,Vision3,Validate,
     DBEngine,TPDate,Vision1,Vision4,Vision2,
     Tools,Prise,App, Serv, ColorTxt,Protect,
     Prihod,Return,NetDbEng,Printers,Net,Utils;



Function CalcSrokOpozdania(Cl:ArtikulStr;Num:ArtikulStr;Date,DateR:TDateString):AllStr;
Var Fr : File Of RealizasiaType;
    Er : PRealizasiaType;
    E  : PRealizasiaType;
    ww : ArtikulStr;
  Find : Boolean;
     Count,c,cc : Word;
     DAteL,l1,l2 : LongInt;

Begin
CalcSrokOpozdania[0]:=#0;
DelSpace(cl);
DelSpace(Num);
DelSpace(Date);
DateL:=DAteStringToDAte(DAteMAsk,Date);

Assign(fr,Path.ToDolg+cl+'.dlg');
c:=IOResult;
Reset(fr);
c:=IOResult;
If c<>0 Then
 Begin
  MessageBox(^M+#3+'Ошибка доступа к файлу '+cl+'.dlg!',Nil,mfError+mfCancelButton);
  Exit;
 End;
 Find:=False;
 New(E,Init);{искомый экземпляр}
 While Not(Eof(fr)) And Not(Find) Do
  Begin
   New(Er,Init);
   Count:=0;
   Read(fr,Er^.Dat);
   DelSpace(Er^.Dat.Market.Document);
   If (Num=Er^.Dat.Market.Document)And
      (Er^.Dat.Market.DateC=DateToDateString(DateMask,DateL)) And
      (Er^.Dat.Market.Active) Then
        Begin
         Find:=True;
         E^.Dat:=Er^.Dat;
         Break;
        End;
   Dispose(Er,Done)
  End;

  Close(fr);

 If Not Find Then
  Begin
  CalcSrokOpozdania:='???';
  Dispose(E,Done);
  Exit;
  End;


  Str(DateStringToDate(DateMask,DateR)-E^.Dat.Market.Srok:CLitrMantissa+1,ww);
  DelSpace(ww);
  CalcSrokOpozdania:=ww;
  Dispose(E,Done);
End;





Procedure CAlcZenaFromVozwrat(VAr Ret : PNewVozwratType;L : Word);
Begin
If Ret^.Dat.DocSelector in [1,2,3,5,6] Then
   Begin

Case Ret^.Dat.VidDocument Of
0,2,4:{Авто}
       Begin
        {получили новую цену с учетом скидки}
        MyStr(StrToReal(Ret^.Dat.VozwratElement[l].Input.Zena)/
           (1+StrToReal(Ret^.Dat.VozwratElement[l].Input.LocalProz)/100),CZena,CMantissa,
           Ret^.Dat.VozwratElement[l].Input.Zena);
      End;

1,3,5:{Ручная}
        Begin
          MyStr(StrToReal(Ret^.Dat.VozwratElement[l].Input.Zena)-
                    StrToReal(Ret^.Dat.VozwratElement[l].Input.LocalSkidka),CZena,CMantissa,
                    Ret^.Dat.VozwratElement[l].Input.Zena);
        End;
Else;
End;{Case}
End{If VidDocSelector}
Else

 Begin
Case Ret^.Dat.VidDocument Of
0,2,4:{Авто}
       Begin
        {получили новую цену с учетом скидки}
        MyStr(StrToReal(Ret^.Dat.VozwratElement[l].Input.Zena)/
           (1+StrToReal(Ret^.Dat.VozwratElement[l].Input.LocalProz)/100),CZena,CMantissa,
                 Ret^.Dat.VozwratElement[l].Input.Zena);
       End;

1,3,5:{Ручная}
        Begin
          MyStr(StrToReal(Ret^.Dat.VozwratElement[l].Input.Zena)-
                    StrToReal(Ret^.Dat.VozwratElement[l].Input.LocalSkidka),CZena,CMantissa,
                    Ret^.Dat.VozwratElement[l].Input.Zena);
        End;
Else;
End;{Case}
 End;
End;




















Function SelOpozdanie(Var L : LongInt):Boolean;
var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  c : Word;
  S : String[3];

begin
SelOpozdanie:=False;
R.Assign(31, 10, 49, 13);
New(Dlg, Init(R, 'Опоздание'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx := $E002;

R.Assign(5, 1, 10, 2);
Control := New(PInputLine, Init(R, 3));
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0']));

  R.Assign(2, 1, 5, 2);
  Dlg^.Insert(New(PLabel, Init(R, '>:', Control)));

R.Assign(11, 1, 16, 2);
Control := New(PColoredText, Init(R, 'дней', $7F));
Dlg^.Insert(Control);

Dlg^.SelectNext(False);
c:=Desktop^.ExecView(Dlg);
If c<>cmCancel Then
 Begin
  Dlg^.GetDAta(s);
  l:=StrToInt(s);
  SelOpozdanie:=True;
 End;
 Dispose(Control,Done);
 Dispose(Dlg,Done);
end;



Function CalcAgentfromMrk(Doc:ArtikulStr;Date:TDateString;Var Cod : ArtikulStr):Boolean;
Var find : Boolean;
    st,s : string[150];
    i : word;
    ef : MarketFileType;
    e : PSupermarketType;
Begin
CalcAgentfromMrk:=False;
Str(StrToInt(Doc):CDocNumer,Doc);
DelSpace(Doc);
DelSpace(Date);
Assign(ef,Path.ToMarket+Date+'.mrk');
i:=IOResult;
Reset(ef);
i:=IOResult;
If i<>0 Then
 Begin
  MessageBox(^M+#3'Ошибка открытия '+Path.ToMarket+Date+'.mrk',Nil,mfError+mfCancelButton);
  Exit;
 End;

New(E,Init);
Find:=False;

 {оптимизация поиска}
  If FileSize(eF)>(StrToInt(Doc)-1) Then
   Begin
     Seek(eF,StrToInt(Doc)-1);
     ReadMarket(eF,E);
     Str(StrToInt(E^.Dat.Document):CDocNumer,E^.Dat.Document);
     DelSpace(E^.Dat.Document);
     DelSpace(E^.Dat.DAtec);
     If (E^.Dat.Document=Doc) And (E^.Dat.DAtec=Date) Then
         Begin
             Find:=True;
             Cod:=E^.Dat.AgentKod;
         End
         Else Seek(eF,0);
   End;


While Not(Eof(ef)) And Not(Find) Do
Begin
 ReadMarket(ef,E);
 Str(StrToInt(E^.Dat.Document):CDocNumer,E^.Dat.Document);
 DelSpace(E^.Dat.Document);
 DelSpace(E^.Dat.DAtec);
 If (E^.Dat.Document=Doc) And (E^.Dat.DAtec=Date) Then
  Begin
   Find:=True;
   Cod:=E^.Dat.AgentKod;
   Break;
  End;
End;
Close(Ef);
Dispose(E,done);
If Not(Find) Then
 MessageBox(^M+#3'Документ отгрузки N: '+Doc+' от '+Date+' в базе не найден!'
 ,Nil,MfError+mfCancelButton);
CalcAgentfromMrk:=Find;
End;





Function SetupDialog(VAr Vid,Tip,Teor,Kto,Sort,Dis:Word):Boolean;
Var c: Word;
  Dlg : PDialog;
  R : TRect;
  ControlSort,ControlVid,
  ControlDistant,ControlTip,ControlKto, ControlTeor: PView;

Begin
SetupDialog:=False;
R.Assign(14, 5, 65, 18);
New(Dlg, Init(R, 'Формирование запроса по долгам клиента'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx := $E002;

R.Assign(1, 2, 22, 5);
ControlVid := New(PRadioButtons, Init(R,
  NewSItem('~Н~е просроченные',
  NewSItem('~П~росроченные',
  NewSItem('~В~се', Nil)))));
Dlg^.Insert(ControlVid);
ControlVid^.SetDAta(Vid);

  R.Assign(1, 1, 14, 2);
  Dlg^.Insert(New(PLabel, Init(R, 'Срок оплаты:', ControlVid)));

R.Assign(1, 6, 22, 9);
ControlTip := New(PRadioButtons, Init(R,
  NewSItem('Со С/~Ф~',
  NewSItem('Бе~з~ С/Ф',
  NewSItem('Все', Nil)))));
Dlg^.Insert(ControlTip);
ControlTip^.SetData(Tip);

  R.Assign(1, 5, 17, 6);
  Dlg^.Insert(New(PLabel, Init(R, 'Вид документов:', ControlTip)));

R.Assign(1, 10, 21, 12);
ControlTeor := New(PRadioButtons, Init(R,
  NewSItem('~Р~еальные',
  NewSItem('~Т~еоретические', Nil))));
Dlg^.Insert(ControlTeor);
ControlTeor^.SetDAta(Teor);

  R.Assign(1, 9, 8, 10);
  Dlg^.Insert(New(PLabel, Init(R, 'Долги:', ControlTeor)));

R.Assign(23, 2, 50, 4);
ControlKto := New(PRadioButtons, Init(R,
  NewSItem('~У~казать доставку',
  NewSItem('Не указ~ы~вать доставку', Nil))));
Dlg^.Insert(ControlKto);
ControlKto^.SetDAta(Kto);

  R.Assign(23, 1, 33, 2);
  Dlg^.Insert(New(PLabel, Init(R, 'Доставка:', ControlKto)));

R.Assign(23, 5, 50, 9);
ControlSort := New(PRadioButtons, Init(R,
  NewSItem('~К~лиент',
  NewSItem('Су~м~ма оплаты',
  NewSItem('Сумма ск~и~дки',
  NewSItem('Срок опоз~д~ания', Nil))))));
Dlg^.Insert(ControlSort);
ControlSort^.SetData(Sort);

  R.Assign(23, 4, 35, 5);
  Dlg^.Insert(New(PLabel, Init(R, 'Сортировка:', ControlSort)));

R.Assign(23, 10, 50, 12);
ControlDistant := New(PRadioButtons, Init(R,
  NewSItem('По возр~а~станию',
  NewSItem('По убыванию', Nil))));
Dlg^.Insert(ControlDistant);
ControlDistant^.SetData(Dis);

  R.Assign(23, 9, 36, 10);
  Dlg^.Insert(New(PLabel, Init(R, 'Направление:', ControlDistant)));

Dlg^.SelectNext(False);

c:=DeskTop^.ExecView(Dlg);
If c<>cmCancel Then
 Begin
  ControlVid^.GetDAta(Vid);
  ControlTip^.GetData(Tip);
  ControlTeor^.GetDAta(Teor);
  ControlKto^.GetDAta(Kto);
  ControlSort^.GetData(Sort);
  ControlDistant^.GetData(Dis);

  SetupDialog:=True;

 End;
 {
 Dispose(ControlTip,Done);
 Dispose(ControlVid,Done);
 Dispose(ControlTeor,Done);
 Dispose(ControlSort,Done);
 Dispose(ControlDistant,Done);
 Dispose(ControlKto,Done);}
 Dispose(Dlg,Done);

End;



Procedure CalcMenedgerOtgruz(Filtr,Oplata:Word;StartDate,StopDate:TDatestring;P:PBox);
Var f : MarketFileType;
    E : PSuperMarketType;
    Er : PRealizasiaType;
    Ef : File Of RealizasiaType;
    l : Word;

    Delta,DateOpl,Date : TDAteString;
    NDS,z,AllSkidka,AllItogo,Skidka,ItogoSkidka,Itogo : Real;
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

Begin

 StartL:=DateStringToDate(DateMask,StartDate);
 StopL:=DateStringToDate(DateMask,StopDate);

 Space:='  ';


 Assign(Txt1,Path.ToTemp+'cmengotg.txt');
 l:=IOResult;
 Rewrite(Txt1);
 l:=IOResult;
 If L <> 0 Then
  Begin
   MessageBox(#3^M+#3'Не могу создать файл отчета'+Path.ToTemp+'cmengotg.txt',Nil,mfError+mfCancelButton);
   Exit;
  End;



Writeln(txt1,Space+'Склад: '+FormKod(Rek.Kod)++'  Оператор: '+CurrentPassword);
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


Writeln(txt1,Space,'     СПРАВКА ПО ОТГРУЗКЕ ЗА ПЕРИОД с '+StartDate+' по '+StopDate);
Writeln(txt1,Space+'┌───────────────────────────────────────────────────────────────────────────────────────┐');
Writeln(txt1,Space+'│N  Клиент               Док.Дата отг.Сумма отгруз.  Сумма скидки  Сумма к опл.    Вид  │');
Writeln(txt1,Space+'└───────────────────────────────────────────────────────────────────────────────────────┘');
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
 Reset(f);
 l:=Ioresult;
{
 If L <> 0 Then
  Begin
   MessageBox(#3^M+#3'Не найден файл '+Path^.Dat.ToMarket+Date+'.mrk',Nil,mfError+mfCancelButton);
  End;
}
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
          Reset(Ef);
          Res:=IOResult;

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
        s:=s+' '+ws;

        DelSpace(E^.Dat.Document);
        RFormat(E^.Dat.Document,CDocNumer-1);
        Format(E^.Dat.DateC,CDate);

        MyStr(StrToReal(E^.Dat.SummaZ)+StrToReal(E^.Dat.Skidka),CIZena-2,CMantissa,ws);
        MyStr(StrToReal(E^.Dat.Skidka),CIZena-2,CMantissa,E^.Dat.Skidka);
        MyStr(StrToReal(E^.Dat.SummaZ),CIZena-2,CMantissa,E^.Dat.SummaZ);
        Itogo:=Itogo+StrToreal(E^.Dat.SummaZ);
        Skidka:=Skidka+StrToreal(E^.Dat.Skidka);
        s:=s+' '+E^.Dat.Document+' '+E^.Dat.DateC+' '+ws+' '+
        +E^.Dat.Skidka+' '+E^.Dat.SummaZ;
        Case E^.Dat.DocSelector Of
        0:s:=s+' '+'Список';
        1:s:=s+' '+'Тов.чек';
        2:s:=s+' '+'Физ.лиц';
        3:s:=s+' '+'СФ';
        4:s:=s+' '+'СФ Б';
        5:s:=s+' '+'Дебит *';
        6:s:=s+' '+'ДебитСФ';
        7:s:=s+' '+'Дебит';
        8:s:=s+' '+'Дебит СФБ';
        Else;
        End;
        Writeln(txt1,Space+s);
        Adress:=GetClientField(FAdress,E^.Dat.ClientKod,E^.Dat.OperatorSelector);
        DelSpaceLeftRight(Adress);
        Writeln(txt1,Space+'    '+Adress);
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



(*
Type
  PDocWindow = ^TDocWindow;
  TDocWindow = object(TDialog)
    Calc : PMYCalculator;
    procedure Start;
    procedure HandleEvent(var Event: TEvent); virtual;
    Destructor Done; virtual;
  end;



Type FindMinMax=Record
    FindDoc : Word;
    FStart  : TDateString;
    FStop   : TDateString;
   End;


Var Find : FindMinMax;
    DocWindow : PDocWindow;



Procedure TDocWindow.Start;
Const Space='                 ';
Var lStart,LStop,LCur:LongInt;
    Max,Min:Real;
    DocCount,MaxDoc,MinDoc:Word;
    MaxDate,MinDate:TDateString;
    f : File;
    E : PBufSuperMarketType;
    Ok: Boolean;
    i : Word;
    Open,s,ws : string[150];
    NDoc : ArtikulStr;
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  Txt : Text;
  c,Count : Word;
Begin
LStart:= DateStringToDate(DateMask,Find.FStart);
LStop := DateStringToDate(DateMask,Find.FStop);
DocCount:=0;
Ok:=False;
DInfo('Минуточку...');
For lcur:=LStart To LStop Do
 Begin
  Assign(f,Path^.Dat.ToMarket+DateToDateString(DateMask,LCur)+'.mrk');
  i:=IOResult;
  Reset(f,SizeOf(SuperMarketType));
  i:=IOResult;
  If i=0 Then
   Begin
    While Not(Eof(f)) And Not(ok) Do
     Begin
      New(E,Init);
      Count:=0;
      ReadBufMarket(f,e,Count);
For c:=1 To Count Do
Begin
      If (E^.Point.Dat[c].DocSelector=Find.FindDoc) And (E^.Point.Dat[c].Active)
         And(E^.Point.Dat[c].OperatorSelector=0)Then
       Begin
 If ((Not(E^.Point.Dat[c].Realiz)) And (Find.FindDoc in [0,1,2,3,4])) Or
    ((E^.Point.Dat[c].Realiz) And (Find.FindDoc in [5,6,7,8])) Then
    Begin

        Ok:=True;
        Max:=StrToReal(E^.Point.Dat[c].SummaZ);
           Min:=StrToReal(E^.Point.Dat[c].SummaZ);
        MaxDoc:=StrToInt(E^.Point.Dat[c].Document);
           MinDoc:=StrToInt(E^.Point.Dat[c].Document);
        MaxDate:=E^.Point.Dat[c].DateC;
           MinDate:=E^.Point.Dat[c].DateC;
    End;
       End;
End;{For}
     Dispose(E,Done);
     End;{While}
     System.Close(f);
   End;
 End;

 If Not(Ok) Then
  Begin
   NoInfo;
   SpeCialBeep;
   MessageBox(^M+#3+'Документов указанного вида за период с '+Find.FStart+' по '+
   Find.FStart+' не обнаружено!',Nil,mfInformation+mfCancelButton);
   Exit;
  End;
 For lcur:=LStart To LStop Do
 Begin
  Assign(f,Path^.Dat.ToMarket+DateToDateString(DateMask,LCur)+'.mrk');
  i:=IOResult;
  Reset(f,SizeOf(SuperMarketType));
  i:=IOResult;
  If i=0 Then
   Begin
    While Not(Eof(f)) Do
     Begin
      New(E,Init);
      Count:=0;
      ReadBufMarket(f,e,Count);
For c:=1 To Count Do
Begin
      If (E^.Point.Dat[c].DocSelector=Find.FindDoc) And (E^.Point.Dat[c].Active)
         And(E^.Point.Dat[c].OperatorSelector=0)Then
       Begin

 If ((Not(E^.Point.Dat[c].Realiz)) And (Find.FindDoc in [0,1,2,3,4])) Or
    ((E^.Point.Dat[c].Realiz) And (Find.FindDoc in [5,6,7,8])) Then
    Begin
        Inc(DocCount);
        If StrToReal(E^.Point.Dat[c].SummaZ)>Max Then
         Begin
          Max:=StrToReal(E^.Point.Dat[c].SummaZ);
          MaxDoc:=StrToInt(E^.Point.Dat[c].Document);
          MaxDate:=E^.Point.Dat[c].DateC;
         End;

        If StrToReal(E^.Point.Dat[c].SummaZ)<Min Then
         Begin
          Min:=StrToReal(E^.Point.Dat[c].SummaZ);
          MinDoc:=StrToInt(E^.Point.Dat[c].Document);
          MinDate:=E^.Point.Dat[c].DateC;
         End;
       End;
    End;
End;{For}
      Dispose(E,Done);
     End;{While}
     System.Close(f);
   End;
 End;


Assign(txt,Path^.Dat.ToTemp+'today.txt');
i:=IOResult;
Rewrite(txt);
i:=IOResult;
If i<>0 Then
 Begin
  MessageBox(#3'Ошибка создания файла '+Path^.Dat.ToTemp+'today.txt! '+IntToStr(i,3),Nil,mfError+mfCancelButton);
  Exit;
 End;


R.Assign(7, 9, 72, 14);
New(DocWindow, Init(R, 'За период с '+Find.FStart+' по '+Find.FStop));
DocWindow^.Options := DocWindow^.Options or ofCenterX or ofCenterY;
DocWindow^.HelpCtx := $E607;

Case Find.FindDoc Of
0:s:=#3+'Список';
1:s:=#3+'Товарный чек';
2:s:=#3+'Физическое лицо';
3:s:=#3+'Счет-фактура';
4:s:=#3+'Счет-фактура Б';
5:s:=#3+'Дебит*';
6:s:=#3+'Дебит* со счетом-фактурой';
7:s:=#3+'Дебит'^M;
8:s:=#3+'Дебит со счетом-фактурой Б';
Else s:=#3+'???';
End;

s:=s+'  (Всего: '+IntToStr(DocCount,CKol)+')';

Writeln(Txt,Space+'Склад:'+GetClientField(FClient,Rek.Kod,1)+'  Оператор: '+CurrentPassword+' EYE & 1997-98');

{$IfDEF DPMI}
Writeln(txt,Space+'За период с '+Find.FStart+' по '+Find.FStop+NoBold[NPrint.Printer]);
Writeln(txt,Space+'---------------------------------------------------------------');
Writeln(txt,Space+' Вид док-та:'+Double[NPrint.Printer]+Bold[NPrint.Printer]+S+
NoBold[NPrint.Printer]+NoDouble[NPrint.Printer]);
{$EndIf}

s:=s+^M;



R.Assign(1, 1, 11, 4);
Control := New(PColoredText, Init(R, ' Вид док.:'^M+
     ' Максимум:'^M+
     '  Минимум:', $30));
DocWindow^.Insert(Control);

Case TestOpenDate1(MaxDate) Of
False  :Open:='Заблокирован';
True   :Open:='Не заблокирован';
Else;
End;

NDoc:=IntToStr(MaxDoc,CDocNumer);
RFormat(NDoc,CDocNumer);

ws:=RealToStr(Max,CIZena,CMantissa);
{$IfDEF DPMI}
Writeln(txt,Space+'   Максимум:'+Bold[NPrint.Printer]+Double[NPrint.Printer]+
RecognizReal(StrToReal(ws),CIZena,CMAntissa)+NoBold[NPrint.Printer]+NoDouble[NPrint.Printer]+
+'  N'+NDoc+' от '+MaxDate+' '+Open);
{$EndIf}
s:=s+ws;
s:=s+'│ N'+NDoc+' от '+MaxDate+'│ '+Open+^M;

Case TestOpenDate1(MinDate) Of
False  :Open:='Заблокирован';
True   :Open:='Не заблокирован';
Else;
End;

NDoc:=IntToStr(MinDoc,CDocNumer);
RFormat(NDoc,CDocNumer);

ws:=RealToStr(Min,CIZena,CMantissa);
{$IfDEF DPMI}
Writeln(txt,Space+'    Минимум:'+Bold[NPrint.Printer]+Double[NPrint.Printer]+RecognizReal(StrToReal(ws),CIZena,CMAntissa)
+NoBold[NPrint.Printer]+NoDouble[NPrint.Printer]+
+'  N'+NDoc+' от '+MinDate+' '+Open);
Writeln(Txt);
Writeln(Txt,Space+'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
Writeln(txt,Space+'===============================================================');
{$EndIf}

system.close(txt);

s:=s+ws;
s:=s+'│ N'+NDoc+' от '+MinDate+'│ '+Open;

R.Assign(11, 1, 64, 4);
Control := New(PColoredText, Init(R, s, $3E));
DocWindow^.Insert(Control);

DocWindow^.SelectNext(False);
NoInfo;
Desktop^.ExecView(DocWindow);
Dispose(Control,Done);
Dispose(DocWindow,Done);
End;


Destructor TDocWindow.Done;
Begin
TDialog.Done;
End;

procedure TDocWindow.HandleEvent(var Event: TEvent);

procedure Calculator;
begin
  Calc^.Start;
end;

Begin
Case Event.What Of
 evCommand :
   Case Event.Command Of
        cmLocalCalc:Calculator;

        cmReestrReport: begin
                        Report(Path^.Dat.ToTemp+'today.txt','',1,False,False);
                        ClearEvent(Event);
                          end;
   Else;
   End;
 else;
 end;
 inherited HAndleEvent(Event);
 ClearEvent(Event);
End;


Procedure SelectVidDoc;
Label 1;
var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  c : Word;
  l : LongInt;
  s1 : TDateString;

begin

1:
R.Assign(24, 6, 55, 16);
New(Dlg, Init(R, 'Min/Max'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx := $E011;


R.Assign(1, 1, 30, 6);
Control := New(PRadioButtons, Init(R,
  NewSItem('С~п~исок',
  NewSItem('Тов.~Ч~ек*',
  NewSItem('Физ.Л*',
  NewSItem('С~Ф~',
  NewSItem('~С~ФБ',
  NewSItem('Дебит~*~',
  NewSItem('Деб~и~т СФ*',
  NewSItem('~Д~ебит',
  NewSItem('Д~е~бит СФБ', Nil)))))))))));
Dlg^.Insert(Control);

R.Assign(2, 7, 29, 8);
Control := New(PStaticText, Init(R, ''));
Control^.Options := Control^.Options or ofFramed;
Dlg^.Insert(Control);

R.Assign(5, 7, 15, 8);
Control := New(PInputLine, Init(R, 8));
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PPXPictureValidator, Init({'[##-##-9#]'}DateFiltr, True));

  R.Assign(2, 7, 5, 8);
  Dlg^.Insert(New(PLabel, Init(R, 'с:', Control)));

R.Assign(19, 7, 29, 8);
Control := New(PInputLine, Init(R, 8));
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PPXPictureValidator, Init({'[##-##-9#]'}DateFiltr, True));

  R.Assign(15, 7, 19, 8);
  Dlg^.Insert(New(PLabel, Init(R, 'п~о~:', Control)));

Dlg^.SelectNext(False);
Dlg^.SetDAta(Find);
c:=Desktop^.ExecView(Dlg);
If c<>cmCancel Then
 Begin
  Dlg^.GetData(Find);
  Dispose(Control,Done);
  Dispose(Dlg,Done);

   If Not(TestDate(Find.FStart,L)) Then
    Begin
     MessageBox(^M+#3'Ошибка при вводе начала периода!',Nil,mfError+mfCancelButton);
     Goto 1;
    End;

   If Not(TestDate(Find.FStop,L)) Then
    Begin
     MessageBox(^M+#3'Ошибка при вводе конца периода!',Nil,mfError+mfCancelButton);
     Goto 1;
    End;

   If DateStringToDate(DateMask,Find.FStop)<DateStringToDate(DateMask,Find.FStart) Then
    Begin
        s1:=Find.FStop;
        Find.FStop:=Find.FStart;
        Find.FStart:=s1;
    End;
    DocWindow^.Start;

 End
 Else
 Begin
  Dispose(Control,Done);
  Dispose(Dlg,Done);
 End;
end;




Begin
 With Find Do
 Begin
  FindDoc:=1;
  FStart:=FDate;
  FStop:=FDate;
 End;
*)

Procedure CalcDolgDebitAgent;
Var R : TRect;
    ClientFile : File;
    ClientElement : PBufKurzClientType;
    RealFile : File;
    Result,AgentList,ClientList :PBox;
    E  : PBufRealizasiaType;
    st,s,s1 : string[150];
    TempS,w,w1 : AllStr;
    ws : TMyString;
    ii,c,t1,t2 : LongInt;
    r1,r2,Rsf,RsfSkid :Float;
    f : Text;
    {DateMask : TDateString;}
    Delta,Space : AllStr;
    PrevDistant:Boolean;
    Tip,Vid,Realno,
    Sort,Dis,IncludeDostavka: Word;
    jjj,Count : Word;
    Del : LongInt;
    St1 : ArtikulStr;
begin
memcc('SLAVA2.PAS');
Vid:=2;
Tip:=2;
Realno:=0;
IncludeDostavka:=1;
Sort:=0;
Dis:=0;

If (SetupDialog(Vid,Tip,Realno,IncludeDostavka,Sort,Dis)) Then
 Begin
 {
 Vid:=SelectSpecify(False,1);
 If Vid=3 Then Exit;


 Tip:=SelectSpecify(False,4);
 If Tip=3 Then Exit;


 Realno:=SelectImport(5);
 If Realno=2 Then Exit;

 IncludeDostavka:=SelectImport(8);
 If IncludeDostavka=2 Then Exit;
 }

 Del:=0;
 If Vid=1 Then
  If Not SelOpozdanie(Del) Then
   Begin
    Exit;
   End;


Assign(f,Path^.Dat.ToTemp+'dolga.txt');

c:=IOResult;
Rewrite(f);
c:=IOResult;
If (c<>0) Then
 Begin
  MessageBox(#3^M+#3'Ошибка создания файла '+Path^.Dat.ToTemp+'dolga.txt!!',Nil,mfError+mfCancelButton);
  Exit;
 End;

R.Assign(0, 0, 0, 0);
AgentList := New(PBox, Init(R, 1, Nil));
AgentList^.NewList(New(PTextCollection, Init(0,1)));
If Not(SelectionAgent(AgentList)) Then
 Begin
  Close(f);
  Dispose(AgentList,Done);
  Exit;
 End;


R.Assign(0, 0, 0, 0);
ClientList := New(PBox, Init(R, 1, Nil));
ClientList^.NewList(New(PTextCollection, Init(0,1)));
Assign (ClientFile,Path^.Dat.ToClient+'Client.idx');
c:=IOResult;
Reset (ClientFile,SizeOf(KurzClientType));
c:=IOResult;
If c=0 Then
Begin

While Not(Eof(ClientFile)) Do
 Begin
     {ReadClient(ClientFile,ClientElement);}
     DInfoMsgShkala('Читаю списки консигнаторов. Ждите... ',0,FileSize(CLientFile),FilePos(CLientFile));
     New(ClientElement,Init);
     Count:=0;
     ReadBufKurzClient(ClientFile,ClientElement,Count);
For jjj:=1 To Count Do
Begin
  If ClientElement^.Point.Dat[jjj].Employ Then
   Begin
     Format(ClientElement^.Point.Dat[jjj].Name,CClient);
     St1:=IntToStr(ClientElement^.Point.Dat[jjj].Kod,CClientKod);
     RFormatZerro(St1,CClientKod);
     ClientList^.List^.Insert(NewStr(ClientElement^.Point.Dat[jjj].Name+'│'+st1{ClientElement^.Point.Dat[jjj].Kod}));
     ClientList^.SetRange(ClientList^.List^.Count);
   End;
End;{For}
  Dispose(ClientElement,Done);
 End;{While}
System.Close(ClientFile);
End
Else
 Begin
  Close(f);
  NoInfoMsg;
  Dispose(AgentList,Done);
  Dispose(ClientList,Done);
  MessageBox(#3^M+#3'Ошибка доступа к файлу клиентов',Nil,mfError+mfCancelButton);
  Exit;
 End;
NoInfoMsg;



Space:='';
r1:=0;r2:=0;
rsf:=0;
rsfSkid:=0;
Writeln(f,Header+Space+'Склад: ',GetClientField(FClient,Rek^.Dat.Kod,1)+'  Оператор: '+CurrentPassword);
Case Vid Of
2:
Writeln(f,Space+'                 СПРАВКА ПО ДОЛГАМ КОНСИГНАТОРОВ'+'  '+FDate+' ('+Times+')');
1:
Writeln(f,Space+'             СПРАВКА ПО ПРОСРОЧЕННЫМ ДОЛГАМ КОНСИГНАТОРОВ'+' (>='+IntToStr(Del,CLitrMAntissa)+') '+
FDate+' ('+Times+')');
0:
Writeln(f,Space+'            СПРАВКА ПО НЕ ПРОСРОЧЕННЫМ ДОЛГАМ КОНСИГНАТОРОВ'+'  '+FDate+' ('+Times+')');
Else;
End;
Write(f,Space+'Вид отбора: ');
Case Tip Of
0:Writeln(f,'"Только со С/Ф"');
1:Writeln(f,'"Только без С/Ф"');
2:Writeln(f,'"Все"');
Else Writeln(f);
End;

Write(f,Space+'Вид долгов: ');
Case Realno Of
1:Writeln(f,'"Теоретичекие"');
0:Writeln(f,'"Реальные по оплате"');
Else Writeln(f);
End;

Case IncludeDostavka Of
0:Writeln(f,'"Указывать доствку"');
1:Writeln(f,'"Не указывать доствку"');
Else;
End;

{Клиент
 оплата
 скидка
 опоздание}

Write(f,Space+'Вид сортировки: ');
Case Sort Of
0:Writeln(f,'"Клиент"');
1:Writeln(f,'"Долг по оплате"');
2:Writeln(f,'"Скида"');
3:Writeln(f,'"Опоздание"');
Else Writeln(f);
End;

Write(f,Space+'Направление сортировки: ');
Case Dis Of
0:Writeln(f,'"По возрастанию"');
1:Writeln(f,'"По убыванию"');
Else Writeln(f);
End;

WriteLN(f,Space+HeaderStop);

WriteLN(f,Space+'Выбранные агенты: ');
For c:=0 To AgentList^.List^.Count-1 Do
 Begin
  s:=AgentList^.GetText(c,AgentList^.List^.Count);
  s1:=Copy(s,1+1,CClientKod);
  s1:=GetAgentField(FAgent,s1);
  Format(s1,CClient);
  s:=s1+s;
  While Pos('│',s)>0 Do s[Pos('│',s)]:=' ';
  s[0]:=Chr(1+CClient+1+CClientKod);
  Writeln(f,Space+s);
 End;
WriteLN(f);


R.Assign(0, 0, 0, 0);
Result := New(PBox, Init(R, 1, Nil));
Result^.NewList(New(PTextCollection, Init(0,1)));


PrevDistant:=DistanationSorting;
If Dis=0 Then
DistanationSorting:=True Else DistanationSorting:=False;


Writeln(f,Header+Space+'┌───┬────────────────────┬────┬────────┬────────┬─────┬────┬────────────┬───────────────┬───┐');
If Realno=1 Then
Writeln(f,Space+'│пп │       Клиент       │Код │Дата Пок│Дата Взв│Delta│Nдок│Сумма скидки│  Сумма долга Т│Вид│')
Else
Writeln(f,Space+'│пп │       Клиент       │Код │Дата Пок│Дата Взв│Delta│Nдок│Сумма скидки│ Р долг по опл.│Вид│');
{                1234│12345678901234567890|1234|12345678|12345678|     |1234|123456789012│123456789012345│}
Writeln(f,Space+'└───┼────────────────────┼────┼────────┼────────┼─────┼────┼────────────┼───────────────┼───┤'+HeaderStop);

If ((ClientList^.List^.Count-1)>=0) Then
 Begin
  For c:=0 To ClientList^.List^.Count-1 Do
   Begin
    DInfoMsgShkala('Рассчитываю долги клиентов. Ждите... ',0,ClientList^.List^.Count-1,c);
    st := ClientList^.GetText(c,ClientList^.List^.Count);
    St := Copy(st,1+CClient+1,CClientKod);


    Assign(RealFile,Path^.Dat.ToDolg+st+'.dlg');
    ii:=IOResult;
    Reset(RealFile,SizeOf(RealizasiaType));
    ii:=IOResult;
    If ii=0 Then
     Begin
      While Not(Eof(RealFile)) Do
       Begin
        New(E,Init);
        Count:=0;
        BlockRead(RealFile,E^.Point,BufferDLG,Count);

        For jjj:=1 To Count Do
Begin
        If (E^.Point.Dat[jjj].Market.Active) Then
Begin
        If Not(TestElement(E^.Point.Dat[jjj].Market.AgentKod+'│',AgentList)) Then
         Begin
        t2:=DateStringToDate(DAteMask,FDate);
        t1:=E^.Point.Dat[jjj].MArket.Srok;
        If (((Not(E^.Point.Dat[jjj].Full)And((t2-t1)>=Del{0}))And(Vid=1))Or
           (Vid=2)Or
           ((((Not(E^.Point.Dat[jjj].Full))And((t2-t1)<0))And(Vid=0)))) And Not(E^.Point.Dat[jjj].Full) Then
         Begin
         If ((E^.Point.Dat[jjj].Market.DocSelector in [6,8]) And (Tip=0)) Or (Tip=2) Or
	    (Not(E^.Point.Dat[jjj].Market.DocSelector in [6,8]) And (Tip=1)) Then
         Begin
          Str((t2-t1):5,w);
          Delta:=w;
          ws:=GetClientField(FClient,St,0);
          Format(ws,CClient);
          DelSpace(E^.Point.Dat[jjj].MArket.Document);
          RFormat(E^.Point.Dat[jjj].MArket.Document,CDocnumer);
          ws:=ws+'│'+St+'│'+
		DateToDateString(DateMask,E^.Point.Dat[jjj].Market.DateC)+'│'+DateToDateString(DAteMask,E^.Point.Dat[jjj].Market.Srok)+'│'+w+
          '│'+E^.Point.Dat[jjj].Market.Document+'│';


          If Realno=1 Then
          MyStr((E^.Point.Dat[jjj].Dolg+E^.Point.Dat[jjj].Market.Skidka),CIZena,CMantissa,w)
          Else
          MyStr((E^.Point.Dat[jjj].Dolg),CIZena,CMantissa,w);
          {
          MyStr(StrToReal(E^.Point.Dat[jjj].Market.Skidka),CIZena-3,CMantissa,E^.Point.Dat[jjj].Market.Skidka);
          }
          r1:=r1+E^.Point.Dat[jjj].Dolg+(E^.Point.Dat[jjj].Market.Skidka);
          r2:=r2+(E^.Point.Dat[jjj].Market.Skidka);
          ws:=ws+RealToStr(E^.Point.Dat[jjj].Market.Skidka,CIZena-3,CMantissa)+'│'+w;

                         If E^.Point.Dat[jjj].MArket.DocSelector in [6,8] Then
                          Begin
                                rsf:=rsf+E^.Point.Dat[jjj].Dolg+E^.Point.Dat[jjj].Market.Skidka;
                  rsfSkid:=rsfSkid+E^.Point.Dat[jjj].Market.Skidka;

                 If E^.Point.Dat[jjj].Market.Rashet=2 Then ws:=ws+'│'+'Вкс'+'│'+E^.Point.Dat[jjj].Market.AgentKod
                 Else
                 If E^.Point.Dat[jjj].Market.Rashet=1 Then ws:=ws+'│'+'СФБ'+'│'+E^.Point.Dat[jjj].Market.AgentKod
                 Else ws:=ws+'│'+'СФ '+'│'+E^.Point.Dat[jjj].Market.AgentKod;
                          End
           Else
           ws:=ws+'│   │'+E^.Point.Dat[jjj].Market.AgentKod;
{
          If E^.Point.Dat[jjj].Sf Then
           Begin
            rsf:=rsf+E^.Point.Dat[jjj].Dolg+StrToReal(E^.Point.Dat[jjj].Market.Skidka);
        rsfSkid:=rsfSkid+StrToReal(E^.Point.Dat[jjj].Market.Skidka);
           ws:=ws+'│'+'СФ '+'│'+E^.Point.Dat[jjj].Market.AgentKod;
           End
           Else
           ws:=ws+'│'+E^.Point.Dat[jjj].Market.AgentKod;
}

{Клиент
 оплата
 скидка
 опоздание}
           Case Sort Of
           0:{Клиент}
             Begin
              ws:=ws;
             End;
           1:{Оплата}
             Begin
              ws:=w+'│'+ws
             End;
           2:{Скидка}
             Begin
              ws:={E^.Point.Dat[jjj].Market.Skidka}RealToStr(E^.Point.Dat[jjj].Market.Skidka,CIZena-3,CMantissa)+'│'+ws;
             End;
           3:{Опоздание}
             Begin
              ws:=Delta+'│'+ws;
             End;
           Else ws:=ws;;
           End;

           Result^.List^.Insert(NewStr(ws));
           Result^.SetRange(Result^.List^.Count);

         End;
         End;
End;{active}
End;{Otbor}

End;{For}
      Dispose(E,Done);

       End;{While}

      Close(RealFile);
     End;

(*{деблокировка клиента}
 Repeat
 Until (SetClientUnLock(St,0,0));*)

   End;
 End;
NoInfoMsg;


DInfoMsg('Сортирую долги клиентов',True);
If ((Result^.List^.Count-1)>=0) Then
BEgin
  For c:=0 To Result^.List^.Count-1 Do
   Begin
    st := Result^.GetText(c,Result^.List^.Count);
    Case Sort of
    0:st:=st;
  {Оплата}
    1:Delete(St,1,CIZena+1);
  {Скидка}
    2:Delete(St,1,CIZena-3+1);
  {Опоздание}
    3:Delete(St,1,5+1);
    Else st:=st;
    End;

    TempS:=Copy(st,Ord(st[0])-CClientKod+1,CClientKod);
    Delete(St,Ord(st[0])-CClientKod+1,CClientKod);

    If IncludeDostavka=0 Then
     Begin
      TempS:=GetAgentField(FAgent,TempS);
      Writeln(f,Space+'     Доставка: '+TempS);
     End;

     ws:=IntToStr(c+1,4);
     RFormat(ws,4);

     Writeln(f,Space+ws+'│'+st);
   End;
End;

Dispose(Result,Done);
Dispose(ClientList,Done);
Dispose(AgentList,Done);
Writeln(f,Space+'────┴────────────────────┴────┴────────┴────────┴─────┴────┴────────────┴───────────────┴───┘');
If Tip In [1,2] Then
Begin
Writeln(f,Space+'                                                   Всего долг:'+RecognizReal(R1,CIZena,CMantissa));
Writeln(f,Space+'                                                 Всего скидка:'+RecognizReal(R2,CIZena,CMantissa));
Writeln(f,Space+'                                      Реальный долг по оплате:'+RecognizReal(R1-R2,CIZena,CMantissa));
End;


If Tip In [0,2] Then
Begin
Writeln(f,Space+'                                               Всего долг С/Ф:'+RecognizReal(RSf,CIZena,CMantissa));
Writeln(f,Space+'                                             Всего скидка С/Ф:'+RecognizReal(RsfSkid,CIZena,CMantissa));
Writeln(f,Space+'                                  Реальный долг по оплате С/Ф:'+RecognizReal(Rsf-RsfSkid,CIZena,CMantissa));
End;

Writeln(f,Space,'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
Writeln(f,Space+'============================================================================================');

c:=IOresult;
Close(f);

NoInfoMsg;
ViewAsText(Path^.Dat.ToTemp+'dolga.txt',True);
ReportNew(Path^.Dat.ToTemp+'dolga.txt','',1,False,False);
DistanationSorting:=PrevDistant;

 End;

end;


Procedure CalcMenedger2(Const Client,Agent:PBox; Filtr,Oplata:Word;StartD,StopD:TDateString;
OpSel : Word);

Var f,fr : File;
    R : TRect;
    Ret : PNewVozwratType;
    RetF : NewVozwratFileType;
    E : PBufSuperMarketType;
    s : string[150];
    l : Word;
    Razdel1 :PBox;
    Delta,DateOpl,Date : TDAteString;
    NDS,z,AllSkidka,AllItogo,ItogoSkidka,Itogo : Float;
    AllZakupka,AllAkzis,AllReturn,AllSkidkaReturn:Float;
    ws,ws2,ws1,ws3 : string[150];
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
Writeln(txt1,Space+'┌───────────────────┬─────┬────────────┬────────────┬────────────┬───────────┬─────┬──────────┐');
Writeln(txt1,Space+'│Поставщик          │ Код │  Сумма опл.│ Отгрузка ЗЦ│  Возврат ЦО│  Доход,руб│  %  │Акциз.сбор│');
Writeln(txt1,Space+'└───────────────────┴─────┴────────────┴────────────┴────────────┴───────────┴─────┴──────────┘');
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

  While Pos('│',s)>0 Do s[Pos('│',s)]:=' ';

  s:=s+' '+SumOpl+' '+SumOZ+' '+SumROpl+' '+DohodStr;

If (Abs(StrToReal(SumOZ)-StrToReal(SumRz))>0.009) Then
Begin
  If (Abs(StrToReal(DohodStr))>0.009) Then
  MyStr(StrToReal(DohodStr)/(StrToReal(SumOZ)-StrToReal(SumRz))*100,CLitr,CMantissa,ws1)
  Else ws1:='??.??';
End
  Else ws1:=' 0.00';

  s:=s+' '+ws1+' '+SAkzis;

 If (Abs(StrToreal(SumOpl))>0.009) Or
    (Abs(StrToreal(SumROpl))>0.009) Or
    (Abs(StrToreal(SumOZ))>0.009) Or
    (Abs(StrToreal(DohodStr))>0.009) Or
    (Abs(StrToreal(SAkzis))>0.009) Or
    (Abs(StrToreal(SumRZ))>0.009) then Writeln(txt1,Space+s);
 End;
Writeln(txt1,Space+'──────────────────────────────────────────────────────────────────────────────────────────────');
Writeln(txt1,Space+'                  Всего:',RealToStr(StrToReal(AllOpl),CIZena,CMantissa)+'              '+
RealToStr(StrToReal(AllRet),CIZena-3,CMantissa)+' '+RealToStr(StrToReal(AllDohod),CIZena-3,CMantissaZ)+
'    '+RealToStr(StrToReal(SAllAkzis),CIZena-3,CMantissaZ));
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

  While Pos('│',s)>0 Do s[Pos('│',s)]:=' ';

  s:=s+' '+SumOpl+' '+SumOZ+' '+SumROpl+' '+DohodStr;

If (Abs(StrToReal(SumOZ)-StrToReal(SumRz))>0.009) Then
Begin
  If (Abs(StrToReal(DohodStr))>0.009) Then
  MyStr(StrToReal(DohodStr)/(StrToReal(SumOZ)-StrToReal(SumRz))*100,CLitr,CMantissa,ws1)
  Else ws1:='??.??';
End
  Else ws1:=' 0.00';

  s:=s+' '+ws1+' '+SAkzis;

 If (Abs(StrToreal(SumOpl))>0.009) Or
    (Abs(StrToreal(SumROpl))>0.009) Or
    (Abs(StrToreal(SumOZ))>0.009) Or
    (Abs(StrToreal(DohodStr))>0.009) Or
    (Abs(StrToreal(SAkzis))>0.009) Or
    (Abs(StrToreal(SumRZ))>0.009) then Writeln(txt1,Space+s);
 End;

Writeln(txt1,Space+'──────────────────────────────────────────────────────────────────────────────────────────────');
Writeln(txt1,Space+'                  Всего:',RealToStr(StrToReal(AllOpl),CIZena,CMantissa)+'              '+
RealToStr(StrToReal(AllRet),CIZena-3,CMantissa)+' '+RealToStr(StrToReal(AllDohod),CIZena-3,CMantissaZ)+
'    '+RealToStr(StrToReal(SAllAkzis),CIZena-3,CMantissaZ));

End;{If Grouplist}
End;



(*
Procedure AddPostListOtgruska(Cod:ArtikulStr;ww1,ww2:AllStr);
Var L : Boolean;
    st,s : string[150];
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
    st,s : string[150];
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
    st,s : string[150];
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
    st,s : string[150];
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
    st,s : string[150];
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
    st,s : string[150];
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
    st,s : string[150];
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
    st,s : string[150];
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
    st : string[150];
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
    st : string[150];
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
     ZakupkaOpora : Word;

Procedure NewElement(Kod : Word);
Var R : TRect;
    s : string[150];
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
Writeln(txt1,Space+'┌──────────────────────────────────────────────────────────────────────────────────────────────┐');
Writeln(txt1,Space+'│N        Агент         Код   Отгружен.сумма   %       Всего штраф   Доход,руб   %             │');
Writeln(txt1,Space+'│                                            от E                              доход Акциз.сбор│');
Writeln(txt1,Space+'└──────────────────────────────────────────────────────────────────────────────────────────────┘');
                   {12 12345678901234567890 1234 123456789012345 12345 123456789012345│12345678901│12345│1234567890}

For Cur:=0 To NewAgent^.List^.Count-1 Do
 Begin
  s:=NewAgent^.GetText(Cur,NewAgent^.List^.Count);
  {объем клиента по З/Цене }
  SumZ:=Copy(s,1+1+CClientKod+1+CIZena+1+CIZena+1,CIZena);
  {объем клиента по акцизному сбору }
  SAkzis:=Copy(s,1+1+CClientKod+1+CIZena+1+CIZena+1+CIZena+1,CIZena);
  {удалем отгрузку по закупке и акциз}
  System.Delete(s,1+1+CClientKod+1+CIZena+1+CIZena+1,CIZena+1+CIZena);


  While Pos('│',s)>0 Do s[Pos('│',s)]:=' ';
  Delete(s,1,1);
  ws1:=Copy(s,1+1,CClientKod);
  ws1:=GetAgentField(FClient,ws1);
  Format(ws1,CClient+1);
  System.Insert(ws1,s,1);
  ws1:=Copy(s,1+CClient+1+CClientKod+1,CIZena);{объемы агента}
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
  System.Insert(ws1,s,1+CClient+1+CClientKod+1+CIZena+1);
  s:=ws2+' '+s+' ';

If (StrToReal(SumO)>0.009) Then
Begin
  If StRToReal(SumZ)>0.009 Then
  MyStr((StrToReal(SumO)-StrToReal(SumZ)-StrToReal(SAkzis))/StrToReal(SumZ)*100,CLitr,CMantissa,ws1)
  Else ws1:='??.??';
End
  Else ws1:=' 0.00';

  MyStr((StrToReal(SumO)-StrToReal(SumZ)-StrToReal(SAkzis)),CIZena-4,CMantissaZ,ws2);

  MyStr(StrToReal(SAkzis),CZenaZ,CMantissaZ,SAkzis);


  s:=s+ws2+' '+ws1+' '+SAkzis;

  Writeln(txt1,Space+s);
 End;
Writeln(txt1,Space+'────────────────────────────────────────────────────────────────────────────────────────────────');

End;{If NewAgent}
End;




Procedure CreatDetalReport;
Var c1,c,l,Cur : Word;
Begin
 Assign(txt1,Path^.Dat.ToTemp+'fullotg.txt');
 Rewrite(txt1);
 Cur:=IOResult;
 If Cur=0 Then
  Begin

  DInfoMsg('Провожу детализацию ...',True);

  Client^.FocusItem(0);

  Writeln(Txt1,'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+') Отчет сформирован по отгрузке');
  Write(Txt1,'                   '+'$'+'    '+'$'+'     '+'$');

For Cur:=0 To Razdel1^.List^.Count-1 Do
 Begin
  s:=Razdel1^.GetText(Cur,Razdel1^.List^.Count);
  Delete(s,1,1);
  ws1:=Copy(s,1,CRazdelKod);
  Delete(s,1+CRazdelKod,3);
  ww1:=GetRazdel(ws1);
  Format(ww1,CRazdel-(CRazdelKod+1));
  Write(txt1,ww1+' '+ws1+'$');
 End;
  WriteLn(txt1);


  For c1:=0 To Client^.List^.Count-1 Do
   Begin
    s:=Client^.GetText(c1,Client^.List^.Count);
    Cur:=StrToInt(Copy(Client^.GetText(c1,Client^.List^.Count),1+CClient+1,CClientKod));

    If (Stat[Cur].Employ) And ((Stat[Cur].DocKol>0) Or (Stat[Cur].DocKolRet>0))  Then
     Begin
      Write(txt1,Copy(s,1,CClient)+'$',Cur:4,'$',Stat[Cur].DocKol:5,'$');
      For l:=0 To Stat[Cur].RList^.List^.Count-1 Do
        Begin
         s:=Stat[Cur].RList^.GetText(l,Stat[Cur].RList^.List^.Count);
         {прочитали возвраты по оплате}
         ws1:=Copy(s,1+1+CArtikul+1+CIZena+1+CIZena+1,CIZena);
         {прочитали отгрузку по оплате}
         s:=Copy(s,1+1+CArtikul+1,CIZena);
         MyStr(StrToReal(s)-StrToReal(ws1),CIZena,CMantissa,s);
         Write(txt1,s+'     $');
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
 MessageBox(^M+#3'Ошибка создания '+Path^.Dat.ToTemp+'fullotg.txt'^M+
 #3' Код: ',nil,mfError+mfCanCelButton);
 Assign(txt1,Path^.Dat.ToTemp+'fullotg.txt');
 Erase(txt1);
 Cur:=IOResult;
End;


End;

VAr SSAkzis : AllStr;

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





If Distant=0 Then DistanationSorting:=True
Else DistanationSorting:=False;


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


If Distant=0 Then DistanationSorting:=True
Else DistanationSorting:=False;


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
	RazdelElement.Kod+'000'+'│           0.00│           0.00│           0.00│           0.00│          0.000│         0.0000'));
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
Writeln(txt1,Space+'┌───────────────────────────────────────────────────────────────────────────────────────┐');
Writeln(txt1,Space+'│N  Клиент               Код  Агент          Док. Дата док Сумма к опл Сумма по ЗЦ   %  │');
Writeln(txt1,Space+'└───────────────────────────────────────────────────────────────────────────────────────┘');
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
 Reset(f,SizeOf(SuperMArketType));
 l:=Ioresult;

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
          Reset(fr,SizeOf(RealizasiaType));
          Res:=IOResult;

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
        s:=s+ws+' '+E^.Point.Dat[c1].ClientKod+' '+AgName+' '+
           +E^.Point.Dat[c1].Document+' '+E^.Point.Dat[c1].DAteC+' '+E^.Point.Dat[c1].SummaZ+' '+
           E^.Point.Dat[c1].SummaZakupka+' '+
           Dohod+' '+ClShk;


        Case Key Of
        1{дата отгр}:Begin
                       tr:=IntToStr(
                       DateStringToDate(DAteMask,E^.Point.Dat[c1].DateC),CKol+1);
                          s:=tr+' '+s;
                     End;
        2{Сумма опл}:s:=E^.Point.Dat[c1].SummaZ+' '+s;
        3{Сумма зак}:Begin
                         s:=E^.Point.Dat[c1].SummaZakupka+' '+s;
                     End;
        4{доход}  :s:=Dohod+' '+s;
        5{шкала клиентов}:s:=ClShk+' '+s;
        6{агент}  : s:=AgName+' '+s;
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


     Writeln(txt1,Space+wS+' '+s);
   End;
 End;


Writeln(txt1,Space+'────────────────────────────────────────────────────────────────────────────────────────-');


Writeln(Txt1,Space+'                                                    Всего документов: ',
AllDoc:CIZena);
Writeln(Txt1,Space+
'                                                     Всего отгружено: ',RecognizReal(AllItogo,CIZena,CMantissa));
Writeln(Txt1,Space+
'                                                        Всего по З/Ц: ',RecognizReal(AllZakupka,CIZena,CMantissaZ));
Writeln(Txt1,Space+
'                                                 Всего акцизный сбор: ',RecognizReal(AllAkzis,CIZena,CMantissaZ));
If AllZakupka>0.009 Then
Begin
Writeln(Txt1,Space+
'                                                       Всего доход %: ',
RecognizReal((AllItogo-AllZakupka-AllAkzis)/AllZakupka*100,CIZena,CMantissa));
End;

Writeln(Txt1,Space+
'                                                         Всего доход: ',RecognizReal(AllItogo-AllZakupka-AllAkzis,CIZena,
CMantissaZ));
Dispose(NoScreen,Done);
DistanationSorting:=True;
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

Writeln(txt1,Space+'┌────────────────────────────────────────────────────────────────────────────────────────┐');
Writeln(txt1,Space+'│N  Клиент               Док.Дата отг.Взв.Дата взв. Сумма возвр.  Сумма возвр. Упущенный │');
                   {123 12345678901234567890 123 12345789 123 12345678 1234567890123 1234567890123 12345.7890}
Writeln(txt1,Space+'│                                                   по ценам опл     по З/Ц      доход   │');
Writeln(txt1,Space+'└────────────────────────────────────────────────────────────────────────────────────────┘');

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
 Reset(Retf);
 l:=Ioresult;
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
        s:=s+' '+ws;

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

        s:=s+' '+Ret^.Dat.BasisDoc+' '+Ret^.Dat.BasisDate+' '+Ret^.Dat.Document+' '+REt^.Dat.DateC+' '+
        +Ret^.Dat.SummaR+' '+Ret^.Dat.SummaZakupka+' '+NoDohod;

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

Writeln(Txt1,Space+'                                        Всего документов: ',AllReturnDoc:CIZena);
Writeln(Txt1,Space+
                   '                           Всего возврат по ценам оплаты: ',RecognizReal(AllReturn-AllSkidkaReturn,
                            CIZena,CMantissa));

Writeln(Txt1,Space+
                   '                                Всего возврат по З/Ценам: ',RecognizReal(AllReturnZakupka,
                            CIZena,CMantissaZ));
Writeln(Txt1,Space+
                   '                        Всего акцизный сбор по возвратам: ',RecognizReal(AllReturnAkzis,
                            CIZena,CMantissaZ));

Writeln(Txt1,Space+
                   '                                   Всего упущенный доход: ',RecognizReal(AllReturn-
                            AllReturnZakupka-AllReturnAkzis,
                            CIZena,CMantissa));


ProdagaWindow:=FFF;



If M[1]=1 Then
Begin
If (Razdel1^.List^.Count-1)>=0 Then
Begin
Space:='';
Writeln(txt1,Condensed[NPrint.Printer]);
If OpSel=0 Then
Writeln(txt1,Space+'ИТОГОВАЯ СПРАВКА ПО ОТГРУЗКАМ ПО РАЗДЕЛАМ (для выбранных клиентов)')
Else
Writeln(txt1,Space+'ИТОГОВАЯ СПРАВКА ПО ОТГРУЗКАМ ВСЧЕТ ВЗАИМОЗАЧЕТОВ ПО РАЗДЕЛАМ (для выбранных клиентов)');
Writeln(txt1,Space+'┌──────────────────────────────────────────────────────────────────────────────────────────────────────'+
'──────────────────────┐');
Writeln(txt1,Space+'│N Раздел                Сумма отгрузки  Сумма отгрузки Сумма возвратов Сумма возвратов  Итого литров, '+
'  Акцизный сбор  Рент.│');
Writeln(txt1,Space+'│                       по ценам оплаты      по З/Ц     по ценам оплаты      по З/Ц      за вычетом воз'+
'в.за вычетом воз.     │');
Writeln(txt1,Space+'└──────────────────────────────────────────────────────────────────────────────────────────────────────'+
'──────────────────────┘');
{12 12345678901234567890 123456789012345 123456789012345 123456789012345 123456789012345 123456789012345 123456789012345│1234}


(*
Writeln(txt1,Space+'┌────────────────────────────────────────────────────────────────────────────────────────────┐');
Writeln(txt1,Space+'│N Раздел                Сумма отгрузки  Сумма отгрузки Сумма возвратов Сумма возвратов Рент.│');
Writeln(txt1,Space+'│                       по ценам оплаты      по З/Ц     по ценам оплаты      по З/Ц       %  │');
Writeln(txt1,Space+'└────────────────────────────────────────────────────────────────────────────────────────────┘');
*)
                   {12 12345678901234567890 123456789012345 123456789012345 123456789012345 123456789012345 123456}

AllLitr:=0;
AllAkzis:=0;
For Cur:=0 To Razdel1^.List^.Count-1 Do
 Begin
  s:=Razdel1^.GetText(Cur,Razdel1^.List^.Count);
  While Pos('│',s)>0 Do s[Pos('│',s)]:=' ';
  Delete(s,1,1);
  ws1:=Copy(s,1,CRazdelKod);
  Delete(s,1+CRazdelKod,3);
  ws1:=GetRazdel(ws1);
  Format(ws1,CRazdel+1);
  Insert(ws1,s,1+CRazdelKod+1);

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

  s:=s+' '+ws1;
  Writeln(txt1,Space+s);
End;
 End;{}
End;

Writeln(txt1,Space+
'──────────────────────────────────────────────────────────────────────────────────────────────────────────────'+
'───────────────────────'+
NoCondensed[NPrint.Printer]);

Writeln(txt1,Space+'Всего алкогольной продукции: ',RecognizReal(AllLitr/10,CIZena,CLitrMantissa)+' Далл.');
Writeln(txt1,Space+'Всего акцизный сбор составил за вычетом возвратов: ',RecognizReal(AllAkzis,CIZena,CMantissaZ)+' руб.');
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

ViewAsText(Path^.Dat.ToTemp+'ncmengob.txt',True);
End;{CalcMenedger2}



Procedure ConvertMarket(Var E:PBufSuperMarketType;j:Word);
Var c: Word;
Begin

 For c:=1 To E^.Point.DAt[j].Amount Do
  Begin
{  If E^.Point.DAt[j].MarketElement[c].Input.Zakupka<>
      E^.Point.DAt[j].MarketElement[c].Input.Zakupka2 Then
       Begin
        memC(E^.Point.DAt[j].Document+' от '+E^.Point.DAt[j].DateC+
        E^.Point.DAt[j].MarketElement[c].BazKod+' '+
	   ' '+E^.Point.DAt[j].MarketElement[c].Input.Zakupka+' '+
	   E^.Point.DAt[j].MarketElement[c].Input.Zakupka2);
       End;}
   E^.Point.DAt[j].MarketElement[c].Input.Zakupka:=
   E^.Point.DAt[j].MarketElement[c].Input.Zakupka2;
  End;

 For c:=1 To E^.Point.DAt[j].AmountS Do
  Begin
   E^.Point.DAt[j].DocumentElement[c].Input.Zakupka:=
   E^.Point.DAt[j].DocumentElement[c].Input.Zakupka2;
  End;

   E^.Point.DAt[j].SummaZakupka:=E^.Point.DAt[j].SummaZakupka2;
   E^.Point.DAt[j].SertifSummaZakupka:=E^.Point.DAt[j].SertifSummaZakupka2;


End;

Procedure ConvertReturn(Var E:PNewVozwratType);
Var c: Word;
Begin
 For c:=1 To E^.DAt.Amount Do
  Begin
   E^.DAt.VozwratElement[c].Input.Zakupka:=
   E^.DAt.VozwratElement[c].Input.Zakupka2;
  End;
  E^.DAt.SummaZakupka:=E^.DAt.SummaZakupka2;
End;




End.