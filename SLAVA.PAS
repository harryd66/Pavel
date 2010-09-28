{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}

{$I Compile.INC}


unit Slava;

Interface

Uses Glob,Dialogs,Drivers,ServStr,MyCalc,Nastr;

Procedure CalcMenedger1;
Procedure GetZakupka(E:PSuperMarketType;FKod:ArtikulStr;Var Zakupka:TDAteString);


Implementation

uses Objects, Views, MsgBox,Vision3,Validate,Access,
     DBEngine,TPDate,Vision1,Vision4,Vision2,
     Tools,Prise,App, Serv, ColorTxt,Protect,
        Prihod,Return,NetDbEng,Printers,Net,Utils;


Const CMantissaZ=4;

Var
    ItogClient : PBox;
    RazdelClient : PBox;
    TempBox: PBox;
    UseClient: PBox;
    BonusBox:  PBox;
    {код клиента,код раздела,сумма опл,сумма закуп,кол-во бонусн.товара}
     ZakupkaOpora:Word;
     SumOpl,SumOZ,SumROpl,SumRZ,DohodStr,AllDohod,AllOpl,AllRet : AllStr;
    SumO,SumZ:AllStr;
    StrDohod : AllStr;
    OldGrKod,GrKOd: String[CrazdelKod];


Procedure GetZakupka(E:PSuperMarketType;FKod:ArtikulStr;Var Zakupka:TDAteString);
Var c: Word;
    Find : Boolean;
Begin
 Zakupka[0]:=#0;
 Find :=False;
 For c:=1 To E^.Dat.Amount Do
  Begin
   If E^.Dat.MArketElement[c].BazKod=FKod Then
    Begin
     Zakupka:=E^.Dat.MArketElement[c].Input.Zakupka;
     Find:=True;
     Break;
    End;
  End;
End;

function GetGroupName(kod:ArtikulStr):AllStr;
var i: word;
    s,skod: string;
Begin
  GetGroupName:='';
  delspace(kod);
  if (Group<>nil) and (Group^.List^.Count>0) then
  begin
   for i:=0 to Group^.List^.Count-1 do
   begin
     s:=Group^.GetText(i,Group^.List^.Count);
     skod:=copy(s,1+CRazdel+1,CRazdelKod);

     if StrToInt(kod)=StrToInt(skod) then
     begin
	  GetGroupName:=copy(s,1,CRazdel);
       exit;
     end;
   end;
  end;
End;

{проверена}
Procedure CreatReportFromGroup(VAr txt1 : Text);
VAr Cur : Word;
    s: string;
    ws1,Space,SAllAkzis,SAkzis : AllStr;

Begin
If (Grouplist^.List^.Count-1)>=0 Then
Begin
Space:='';
Writeln(txt1);

Writeln(txt1,Space+'   СПРАВКА ПО ОПЛАЧЕННЫМ ОТГРУЗКАМ ПО ГРУППАМ ПРОДУКЦИИ');
Writeln(txt1,Space+'┌───────────────────┬────┬────────────┬────────────┬────────────┬───────────┬─────┬──────────┐');
Writeln(txt1,Space+'│Группа продукции   │Код │  Сумма опл.│ Отгрузка ЗЦ│  Возврат ЦО│  Доход,руб│  %  │Акциз.сбор│');
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

  MyStr(StrToReal(SAkzis),10,CMAntissa,SAkzis);

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

Writeln(txt1,Space+'                 Всего: '+SeparatorChar,RealToStr(StrToReal(AllOpl),CIZena,CMantissa)+
'             '+SeparatorChar+RealToStr(StrToReal(AllRet),CIZena-3,CMantissa)+SeparatorChar+
RealToStr(StrToReal(AllDohod),CIZena-3,CMantissaZ)+
'   '+SeparatorChar+RealToStr(StrToReal(SAllAkzis),CIZena-3,CMantissaZ));

End;{If Grouplist}
End;






Function  CalcSrokOpozdania(Cl:ArtikulStr;Num:ArtikulStr;Date,DateR:TDateString):AllStr;
Var Fr : File Of  RealizasiaType;
    Er : PRealizasiaType;
    E  : PRealizasiaType;
    ww : ArtikulStr;
  Find : Boolean;
     Count,c,cc : Word;
     l1,l2 : LongInt;
Begin
CalcSrokOpozdania[0]:=#0;
DelSpace(cl);
DelSpace(Num);
DelSpace(Date);

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
Begin
   DelSpace(Er^.Dat.Market.Document);
   If (Num=Er^.Dat.Market.Document)And
      (Er^.Dat.Market.DateC=Date) And
      (Er^.Dat.Market.Active) Then
        Begin
         Find:=True;
      E^.Dat:=Er^.Dat;
      Break;
     End;
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
 MessageBox(^M+#3'Документ отгрузки N: '+Doc+' от '+Date+' в базе не найден!'^M+
 ClicProgrammer,Nil,MfError+mfCancelButton);
CalcAgentfromMrk:=Find;

End;




Procedure CalcMenedger1;
Const
      Arhipov=0; Ilishev=1;
Var f : MArketFileType;
    R : TRect;
    E : PSuperMarketType;
    s : string[150];
    l : Word;
    RetF : NewVozwratFileType;
    Ret  : PNewVozwratType;
    Razdel1 :PBox;
    Razdel2 :PBox;
    t: text;

    SZakupka,Delta,DateOpl,Date : TDAteString;
    NDS,z,AllLocZakupka,
    AllSkidka,AllItogo,ItogoSkidka,Itogo : Real;
    AllReturn,AllSkidkaReturn:Real;
    AllZakupka,AllReturnZakupka:Real;
    ww1,ww2,ws,ws2 : TMyString;
    ww1r,ww2r,wsr,ws2r : TMyString;
    Txt2,txt1 : Text;
    AllDoc : Word;
    DocS : Word;
    Slujba,Current,Cur,sh,VidSkidka,Vid : Word;

    ws1,Space : TMyString;
    AllReturnDoc,RAbday,Start,Stop,Den : LongInt;
    NoScreen : PBox;
    mm : Maska9;
    Key,Distant : Word;
    NameDoc,Names,Otgruz : AllStr;
    DateOtgr,DateOplata: TDateString;
    StartDate,StopDate : TDateString;
    VidReport,c,Count,SelectorOplata : Word;

    FFF : Boolean;
    Doc,Cod,Ag:AllStr;
    Dohod,Dolg : Real;
    ws11,ws22:string[150];
    SumO,SumZ:AllStr;

    EStraf,Straf: Real;


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
  st:=Copy(st,1+1,CClientKod);
  If (St=Cod) Then
   Begin
    TestAgent:=True;
    Break;
   End;{St=Cod}
 End;
End;
End;



Procedure AddAgentSumma(Cod:ArtikulStr;s1,s2,s3{сумма по закупке}:AllStr);
Var L : Boolean;
    st,s : string[150];
    i : word;
Begin
l:=False;
If (Agent^.List^.Count-1)>=0 Then
Begin
For i:=0 To Agent^.List^.Count-1 Do
 Begin
  st:=Agent^.GetText(i,Agent^.List^.Count);
  st:=Copy(st,1+1,CClientKod);
  If (St=Cod) Then
   Begin
    st:=Agent^.GetText(i,Agent^.List^.Count);
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


    Agent^.List^.AtFree(i);
    Agent^.SetRange(Agent^.List^.Count);
    Agent^.List^.Insert(NewStr(st));
    Agent^.SetRange(Agent^.List^.Count);
    l:=True;
    Break;
   End;{St=Cod}
 End;
if Not(l) Then
 MessageBox(^M+#3'Элемент ('+Cod+') в списке не найден!',Nil,mfError+mfCancelButton);
End;
End;





Procedure AddAgentStraf(Cod:ArtikulStr;straf:Real);
Var L : Boolean;
    st,s : string;
    i : word;
Begin
l:=False;
If (Agent^.List^.Count-1)>=0 Then
Begin
For i:=0 To Agent^.List^.Count-1 Do
 Begin
  st:=Agent^.GetText(i,Agent^.List^.Count);
  st:=Copy(st,1+1,CClientKod);
  If (St=Cod) Then
   Begin
    st:=Agent^.GetText(i,Agent^.List^.Count);
    {добавляем отгрузку}
    s:=Copy(st,1+1+CClientKod+1+CIZena+1,CIZena);
    System.Delete(st,1+1+CClientKod+1+CIZena+1,CIZena);
    MyStr(StrToReal(s)+Straf,CIZena,CMantissa,s);
    System.Insert(s,st,1+1+CClientKod+1+CIZena+1);

    Agent^.List^.AtFree(i);
    Agent^.SetRange(Agent^.List^.Count);
    Agent^.List^.Insert(NewStr(st));
    Agent^.SetRange(Agent^.List^.Count);
    l:=True;
    Break;
   End;{St=Cod}
 End;
if Not(l) Then
 MessageBox(^M+#3'Элемент ('+Cod+') в списке не найден!',Nil,mfError+mfCancelButton);
End;
End;

Function CalcRazdelClient(rKOd:ArtikulStr):word;
Var i: word;
    st: string;
    rrkod: ArtikulStr;
    count: word;
Begin
  CalcRazdelClient:=0;
  count:=0;
If (RazdelClient^.List^.Count-1)>=0 Then
Begin
For i:=0 To RazdelClient^.List^.Count-1 Do
 Begin
  st:=RazdelClient^.GetText(i,RazdelClient^.List^.Count);
  rrkod:=copy(st,1+CArtikul+1,CRazdelKOd);
  {memcc(rrkod+' '+rKOd);}
  if StrToint(rrkod)=StrToInt(rKOd) then
  begin
    {memc;}
    inc(Count);
  end;
 End;
End;
  CalcRazdelClient:=count;
End;

Procedure AddItogRazdelClient(Cod:ArtikulStr;rKOd:ArtikulStr;ww1,ww2,ww3:AllStr);
Var L : Boolean;
    st,s : string[150];
    rrKOd:ArtikulStr;
    i : word;
Begin
l:=False;
RFormatZerro(Cod,CArtikul);
DelSpace(ww1);
DelSpace(ww2);
If (RazdelClient^.List^.Count-1)>=0 Then
Begin
For i:=0 To RazdelClient^.List^.Count-1 Do
 Begin
  st:=RazdelClient^.GetText(i,RazdelClient^.List^.Count);
  rrkod:=copy(st,1+CArtikul+1,CRazdelKOd);
  st:=Copy(st,1,CArtikul);
  If (St=Cod) and (rKOd=rrkod)Then
   Begin
    st:=RazdelClient^.GetText(i,RazdelClient^.List^.Count);

    {добавляем отгрузку}
      s:=Copy(st,1+CRazdelKod+1+CArtikul+1,CIZena);
      System.Delete(st,1+CRazdelKod+1+CArtikul+1,CIZena);

      MyStr(StrToReal(s)+StrToReal(ww1){отгрзка},CIZena,CMantissa,s);
      System.Insert(s,st,1+CRazdelKod+1+CArtikul+1);

      s:=Copy(st,1+CRazdelKod+1+CArtikul+1+CIZena+1,CIZena);
      System.Delete(st,1+CRazdelKod+1+CArtikul+1+CIZena+1,CIZena);

      MyStr(StrToReal(s)+StrToReal(ww2){доход},CIZena,CMantissaZ,s);
      System.Insert(s,st,1+CRazdelKod+1+CArtikul+1+CIZena+1);


      s:=Copy(st,1+CRazdelKod+1+CArtikul+1+CIZena+1+CIZena+1,CKOl);
      System.Delete(st,1+CRazdelKod+1+CArtikul+1+CIZena+1+CIZena+1,CKOl);

      s:=IntToStr(StrToInt(s)+StrToInt(ww3){кол-во нулевых},CKOl);
      rformat(s,Ckol);
      System.Insert(s,st,1+CRazdelKod+1+CArtikul+1+CIZena+1+CIZena+1);


      RazdelClient^.List^.AtFree(i);
      RazdelClient^.SetRange(RazdelClient^.List^.Count);
      RazdelClient^.List^.Insert(NewStr(st));
      RazdelClient^.SetRange(RazdelClient^.List^.Count);
      l:=True;
      Break;

   End;{St=Cod}
 End;
if Not(l) Then
 MessageBox(^M+#3'Элемент ('+Cod+') в списке не найден!',Nil,mfError+mfCancelButton);
End;
End;


Procedure AddBonus(Cod:ArtikulStr;ww1:AllStr);
Var L : Boolean;
    st,s : string[150];
    i : word;
Begin
l:=False;
RFormatZerro(Cod,CArtikul);
DelSpace(ww1);
If (BonusBox^.List^.Count-1)>=0 Then
Begin
For i:=0 To BonusBox^.List^.Count-1 Do
 Begin
  st:=BonusBox^.GetText(i,BonusBox^.List^.Count);
  st:=Copy(st,1+1,CArtikul);
  If (St=Cod) Then
   Begin
    st:=BonusBox^.GetText(i,BonusBox^.List^.Count);
        {добавляем отгрузку}
    s:=Copy(st,1+1+CArtikul+1,CKol);
    System.Delete(st,1+1+CArtikul+1,CKol);
    s:=IntToStr(StrToInt(s)+StrToInt(ww1),Ckol);
    rformat(s,CKol);
    System.Insert(s,st,1+1+CArtikul+1);

    BonusBox^.List^.AtFree(i);
    BonusBox^.SetRange(BonusBox^.List^.Count);

    BonusBox^.List^.Insert(NewStr(st));
    BonusBox^.SetRange(BonusBox^.List^.Count);

    l:=True;
    Break;
   End;{St=Cod}
 End;
if Not(l) Then
 MessageBox(^M+#3'Элемент ('+Cod+') в списке не найден!',Nil,mfError+mfCancelButton);
End;
End;


Procedure AddItogClient(Cod:ArtikulStr;ww1,ww2,ww3:AllStr);
Var L : Boolean;
    st,s : string;
    i : word;
Begin
l:=False;
RFormatZerro(Cod,CArtikul);
DelSpace(ww1);
DelSpace(ww2);
If (ItogClient^.List^.Count-1)>=0 Then
Begin
For i:=0 To ItogClient^.List^.Count-1 Do
 Begin
  st:=ItogClient^.GetText(i,ItogClient^.List^.Count);
  st:=Copy(st,1+CClient+1,CArtikul);
  If (St=Cod) Then
   Begin
    st:=ItogClient^.GetText(i,ItogClient^.List^.Count);
    {добавляем отгрузку}
    s:=Copy(st,1+CClient+1+CArtikul+1,CIZena);
    System.Delete(st,1+CClient+1+CArtikul+1,CIZena);

    MyStr(StrToReal(s)+StrToReal(ww1){отгрзка},CIZena,CMantissa,s);
    System.Insert(s,st,1+CClient+1+CArtikul+1);

    s:=Copy(st,1+CClient+1+CArtikul+1+CIZena+1,CIZena);
    System.Delete(st,1+CClient+1+CArtikul+1+CIZena+1,CIZena);

    MyStr(StrToReal(s)+StrToReal(ww2){доход},CIZena,CMantissaZ,s);
    System.Insert(s,st,1+CClient+1+CArtikul+1+CIZena+1);


    s:=Copy(st,1+CClient+1+CArtikul+1+CIZena+1+CIZena+1,CIZena);
    System.Delete(st,1+CClient+1+CArtikul+1+CIZena+1+CIZena+1,CIZena);

    MyStr(StrToReal(s)+StrToReal(ww3){акциз},CIZena,CMantissaZ,s);
    System.Insert(s,st,1+CClient+1+CArtikul+1+CIZena+1+CIZena+1);


    ItogClient^.List^.AtFree(i);
    ItogClient^.SetRange(ItogClient^.List^.Count);
    ItogClient^.List^.Insert(NewStr(st));
    ItogClient^.SetRange(ItogClient^.List^.Count);
    l:=True;
    Break;
   End;{St=Cod}
 End;
if Not(l) Then
 MessageBox(^M+#3'Элемент ('+Cod+') в списке не найден!',Nil,mfError+mfCancelButton);
End;
End;


Procedure CreatReportFromRazdelClient(VAr txt1 : Text);
var Separator: TDAteSTring;
    Cur : Word;
    clKOd,oldKOd: string[CArtikul];
    sName,sOldName: string[CClient];
    SumOpl,SumOz: string[CIzena];
    sr: string[CRazdelKod];
Begin
If (RazdelClient^.List^.Count-1)>=0 Then
Begin

R.Assign(0,0,0,0);
TempBox:= New(PBox, Init(R, 1, Nil));
TempBox^.NewList(New(PTextCollection, Init(0,1)));

Space:='';
Writeln(txt1);
{If MessageBox(^M+#3'Подготовить отчет к конвертации в Excel?',Nil,mfConfirmation+mfOkCancel)=cmOk Then
Separator:='$' Else Separator:=' ';}
Separator:=' ';

Writeln(txt1,Space+'   СПРАВКА ПО ДОХОДНОСТИ И ОПЛАЧЕННЫМ ОТГРУЗКАМ ПО КЛИЕНТАМ И РАЗДЕЛАМ');

Writeln(txt1,Space+'┌───────────────────────┬───────────────┬───────────────┬─────┬─────┐');
Writeln(txt1,Space+'│                       │Сумма оплачен. │  Доход, руб   │ %дох│Бонус│');
Writeln(txt1,Space+'│Клиент/Раздел          │отгрузок       │               │     │ шт. │');
Writeln(txt1,Space+'└───────────────────────┴───────────────┴───────────────┴─────┴─────┘');

(*Writeln(txt1,Space+'┌───────────────────┬─────┬───────────────┬───────────────┬─────┬─────┬─────────────┐');
Writeln(txt1,Space+'│                   │     │Сумма оплачен. │  Доход, руб   │     │     │ Расчетная   │');
Writeln(txt1,Space+'│Клиент             │ Код │отгрузок за выч│  за вычетом   │ %дох│% кл.│   сумма     │');
Writeln(txt1,Space+'│                   │     │   возвратов   │упущенного дох.│     │     │             │');
Writeln(txt1,Space+'└───────────────────┴─────┴───────────────┴───────────────┴─────┴─────┴─────────────┘');*)

  s:=RazdelClient^.GetText(0,RazdelClient^.List^.Count);
  oldKOd:=copy(s,1,CArtikul);
For Cur:=0 To RazdelClient^.List^.Count-1 Do
 Begin
  s:=RazdelClient^.GetText(Cur,RazdelClient^.List^.Count);
  clKOd:=copy(s,1,CArtikul);
  SumOpl:=copy(s,1+CArtikul+1+CRazdelKod+1,CIzena);
  SumOz:=copy(s,1+CArtikul+1+CRazdelKod+1+CIzena+1,CIzena);
  System.Delete(clKod,1,1);
  System.Delete(s,1,CArtikul);
  sNAme:=GetClientField(FClient,ClKod,0);
 { if (cur=0) or (oldKod<>clKOd) then
  begin
   sNAme:=GetClientField(FClient,ClKod,0);
   format(sName,CClient);
   Writeln(txt1,Space+GetClientField(FClient,ClKod,0));
   oldKod:=clKod;
  end; }
  If ((StrToReal(SumOpl)-StrToReal(SumOz))>0.0009) Then
Begin
  If ((StrToReal(SumOZ))>0.0009) Then
  MyStr(StrToReal(SumOZ)/(StrToReal(SumOpl)-StrToReal(SumOz))*100,CLitr,CMantissa,ws1)
  Else ws1:='??.??';
end;
  System.Insert(ws1+'│',s,1+CRazdelKod+1+CIzena+1+CIzena+1+1);

  {Writeln(txt1,Space+s);}
    TempBox^.List^.Insert(NewStr(sName+s));
    TempBox^.SetRange(ItogClient^.List^.Count);


 end;

sOldNAme:=copy(TempBox^.GetText(0,TempBox^.List^.Count),1,CClient);
format(sOldNAme,CClient);
For Cur:=0 To TempBox^.List^.Count-1 Do
 Begin
  s:=TempBox^.GetText(Cur,TempBox^.List^.Count);
  sNAme:=copy(s,1,CClient);
  format(sNAme,CClient);

  System.Delete(s,1,CClient);
  if (cur=0) or (sName<>sOldName) then
  begin
   {format(sName,CClient);}
   if cur<>0 then writeln(txt1,space+'-------------------------------------------------------------------─');
   Writeln(txt1,Space+sName);
   sOldName:=sName
  end;
  sr:=copy(s,2,2);
  sName:=GetRazdel(sr);
      Format(sName,CRazdel);
  System.Insert(sName+' ',s,1+CRazdelKod+1+1);
  While Pos('│',s)>0 Do s[Pos('│',s)]:=Separator[1];
  writeln(txt1,Space+s);
 End;
dispose(TempBox,Done);
writeln(txt1,space+'____________________________________________________________________');
end;
End;

{проверена}
Procedure CreatReportFromClient(VAr txt1 : Text);
VAr Cur : Word;
    PPP,KodCl,SAllAkzis,SAkzis : AllStr;
    AllD:Real;
    Separator: TDAteSTring;
Begin
If (ItogClient^.List^.Count-1)>=0 Then
Begin
Space:='';
Writeln(txt1);
If MessageBox(^M+#3'Подготовить отчет к конвертации в Excel?',Nil,mfConfirmation+mfOkCancel)=cmOk Then
Separator:='$' Else Separator:=' ';

Writeln(txt1,Space+'   СПРАВКА ПО ДОХОДНОСТИ И ОПЛАЧЕННЫМ ОТГРУЗКАМ ПО КЛИЕНТАМ');
Writeln(txt1,Space+'┌───────────────────┬─────┬───────────────┬───────────────┬─────┬─────┬─────────────┐');
Writeln(txt1,Space+'│                   │     │Сумма оплачен. │  Доход, руб   │     │     │ Расчетная   │');
Writeln(txt1,Space+'│Клиент             │ Код │отгрузок за выч│  за вычетом   │ %дох│% кл.│   сумма     │');
Writeln(txt1,Space+'│                   │     │   возвратов   │упущенного дох.│     │     │             │');
Writeln(txt1,Space+'└───────────────────┴─────┴───────────────┴───────────────┴─────┴─────┴─────────────┘');
                   {12345678901234567890│12345│123456789012345│123456789012345│123456│1234567890123}

AllOpl[0]:=#0;
AllRet[0]:=#0;
SAllAkzis[0]:=#0;
AllD:=0;
For Cur:=0 To ItogClient^.List^.Count-1 Do
 Begin
  s:=ItogClient^.GetText(Cur,ItogClient^.List^.Count);
  {объем клиента по З/Цене }
  writeln(txt1,s);

  KodCl:=Copy(s,1+CClient+1,CArtikul);
  System.Delete(KodCl,1,1);
  PPP:=GetClientField(FCProz,KodCl,0);
  RFormat(PPP,CLitr);
  SumOpl:=Copy(s,1+CClient+1+CArtikul+1,CIZena);
  MyStr(StrToReal(SumOpl),CIZena,2,SumOpl);

  SumOZ:=Copy(s,1+CClient+1+CArtikul+1+CIZena+1,CIZena);
  MyStr(StrToReal(SumOZ),CIZena,CMAntissaZ,SumOZ);

  SAkzis:=Copy(s,1+CClient+1+CArtikul+1+CIZena+1+CIZena+1,CIZena);
  MyStr(StrToReal(SAkzis),CIZena-2,CMAntissaZ,SAkzis);

  SAkzis[0]:=#0;

  MyStr(StrToReal(AllOpl)+StrToReal(SumOpl),CIZena,CMAntissa,AllOpl);
  MyStr(StrToReal(AllRet)+StrToReal(SumOZ)-StrToReal(SAkzis),CIZena,CMAntissa,AllRet);
  MyStr(StrToReal(SAllAkzis)+StrToReal(SAkzis),CIZena-2,CMAntissaZ,SAllAkzis);
  MyStr(StrToReal(SumOZ)-StrToReal(SAkzis),CIZena,CMAntissaZ,SumOz);


  While Pos('│',s)>0 Do s[Pos('│',s)]:=Separator[1];

  s[0]:=Chr(CClient+1+CArtikul+1+CIZena+1{+CIZena});
  s:=s+SumOz;

If ((StrToReal(SumOpl)-StrToReal(SumOz)-StrToReal(SAkzis))>0.0009) Then
Begin
  If ((StrToReal(SumOZ))>0.0009) Then
  MyStr(StrToReal(SumOZ)/(StrToReal(SumOpl)-StrToReal(SumOz)-StrToReal(SAkzis))*100,CLitr,CMantissa,ws1)
  Else ws1:='??.??';

  {MemC(SumOZ+'/('+SumOpl+'-'+SumOZ+'-'+SAkzis);}

End
  Else ws1:=Separator+'0.00';

  s:=s+Separator+ws1+Separator+PPP;

  SAkzis[0]:=#0;
  MyStr((StrToReal(SumOpl){StrToReal(SumOz)})*StrToREal(PPP)/100,CIZena-2,CMAntissa,SAkzis);

  AllD:=AllD+StrToReal(SAkzis);

 If (Abs(StrToreal(SumOpl))>0.0009) Or
    (Abs(StrToreal(SAkzis))>0.0009) Or
    (Abs(StrToreal(SumOZ))>0.0009)then Writeln(txt1,Space+s+Separator+SAkzis);
 End;

Writeln(txt1,Space+'───────────────────────────────────────────────────────────────────────────────');

Writeln(txt1,Space+'                    Всего: ',RealToStr(StrToReal(AllOpl),CIZena,CMantissa)+Separator+
RealToStr(StrToReal(AllRet),CIZena,CMantissaZ)+Separator+'         '+Separator+RealToStr(AllD,CIZena-2,CMantissaZ));



End;{If ItogClient}
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




Procedure AddClientOplata(SelectorOplata,VidReport:Word; Cod:ArtikulStr;
                                Doc,Date:TDateString;Dolg:Real;
                                                  Var f : Text;Var EStraf:Real);
Const Space='     ';
Var L : Boolean;
    st,s : string;
    i : word;
    Cl : ClientOplataRealizasiaType;
    clf : File Of ClientOplataRealizasiaType;
    Find,Shapka : Boolean;
    Straf : Real;
    c1,COunt : Word;
Begin
EStraf:=0;
Straf:=0;
Find:=False;
Assign(clf,Path.ToClientOplata+Cod+'.cpl');
i:=IOresult;
Reset(clf);
i:=IOresult;
If (i<>0) Then
 Begin
  if (VidReport=0) then Writeln(f,Space+'Нет файла оплаты!      Штраф:',EStraf:CIZena:CMantissa);
  Exit;
 End;

DelSpace(Doc);
DelSpace(Date);
Shapka:=False;
While Not(Eof(clf)) Do
 Begin
  Read(Clf,Cl);
Begin
  Str(StrToInt(Cl.Document):CDocNumer,Cl.Document);
  DelSpace(Cl.Document);
  DelSpace(Cl.DateDoc);
  If (Cl.Document=Doc) And (Cl.DateDoc=Date) And
  (StrToInt(Cl.SkladKod)=StrToInt(Rek.Kod)) And Not(Cl.Vozwrat) Then
   Begin
    Find:=True;
    If (SelectorOplata=0) And (VidReport=0) Then
     Begin
      If Not(Shapka) Then
       Begin
        Writeln(f,Space+'--------------------------------------------------------------------------');
        Writeln(f,Space+'Дата опл    Сумма оплаты   Остаток долга   Текущий штраф Del  Оператор  ');
                        {12345678 123456789012345 123456789012345 123456789012345 1234 123456789012}
        Writeln(f,Space+'--------------------------------------------------------------------------');
       End;{печать шапки}

      if Cl.Realiz then Cl.Delta:='0';

      If StrToInt(Cl.Delta)>0 Then
      Begin
      If StrToInt(Cl.Delta)-3>0 Then{в этом месте исключается первый день опоздания}
      Straf:=StrToReal(Cl.SummaZ)*0.005*(StrToInt(Cl.Delta)-3);
      End
      Else
       Begin
        If (StrToInt(Cl.Delta))<0 Then
        {Straf:=StrToReal(Cl.SummaZ)*0.005*(StrToInt(Cl.Delta))};
       End;

      Shapka:=True;
      MyStr(Dolg,CIZena,CMantissa,st);
      s:=GetOperatorName(Cl.Caption);
      Format(s,CKto);
      MyStr(StrToReal(Cl.SummaZ),CIZena,CMantissa,Cl.SummaZ);
      Str(StrToInt(Cl.Delta):CLitrMantissa+1,Cl.Delta);
      Writeln(f,Space+Cl.DateC+' '+Cl.SummaZ+' '+St+' ',Straf:CIzena:cmantissa,' '+
         Cl.Delta+' '+s);
     End{если развернутый вариант оплаты}
     Else
     begin
      if Cl.Realiz then Cl.Delta:='0';
      If StrToInt(Cl.Delta)>0 Then
      Begin
      If StrToInt(Cl.Delta)-3>0 Then
       Straf:=StrToReal(Cl.SummaZ)*0.005*(StrToInt(Cl.Delta)-3);
      end
      Else
       Begin
        If (StrToInt(Cl.Delta))<0 Then
        {Straf:=StrToReal(Cl.SummaZ)*0.005*(StrToInt(Cl.Delta))};
       End;

     End;

     EStraf:=EStraf+Straf;
     Dolg :=Dolg-StrToReal(Cl.SummaZ);
   End;{Если нужный документ}
End;{For}
 End;{While}

If (VidReport=0) Then
Begin
If Find Then
Writeln(f,Space+'                         Штраф:',EStraf:CIZena:CMantissa)
Else
Writeln(f,Space+'Оплаты не найдены!       Штраф:',EStraf:CIZena:CMantissa);
End;
Close(clf);
i:=IOresult;
End;




 Var i : LongInt;
     SertifKol : LongInt;
     TestE:PSuperMarketType;
     StartLogik:Boolean;
     A : DocumentEdit;
     Ass : DocumentEdit;
     EEE : PSuperMArketType;




Begin
 If Not(DatePeriodDialog(StartDate,StopDate,False)) Then Exit;
{
 Assign(ClientFile,Path.ToClient+'agent.db');
 Reset(ClientFile);
 i:=IOResult;
 If i<>0 Then
  Begin
   MessageBox(^M+#3+'Ошибка открытия файла агентов!',Nil,mfError+mfCancelButton);
   Exit;
  End;
}
R.Assign(0, 0, 0, 0);
Agent := New(PBox, Init(R, 1, Nil));
Agent^.NewList(New(PTextCollection, Init(0,1)));

If Not(SelectionAgent(Agent)) Then
 Begin
  Dispose(Agent,Done);
  Exit;
 End;


R.Assign(0, 0, 0, 0);
GroupList := New(PBox, Init(R, 1, Nil));
GroupList^.NewList(New(PTextCollection, Init(0,1)));
If Not(CreatGroupList(GroupList)) Then
 Begin
  Dispose(GroupList,Done);
  Dispose(Agent,Done);
  Exit;
 End;


{
If Not(eof(ClientFile)) Then Read(ClientFile,ClientElement);
 While Not(Eof(ClientFile)) Do
  Begin
   Read(ClientFile,ClientElement);
   If ClientElement.Employ Then
    Begin
     Agent^.List^.Insert(NewStr('│'+ClientElement.Kod+'│           0.00│           0.00'));
     Agent^.SetRange(Agent^.List^.Count);
    End;
  End;
Close(ClientFile);
}



 Start:=DateStringToDate(DateMask,StartDate);
 Stop:=DateStringToDate(DateMask,StopDate);

 Vid:=0;

 Slujba:=0;
 Slujba:=SelectImport(8);
 If Slujba=2 Then
  Begin
   Dispose(Agent,Done);
   Dispose(GroupList,Done);
   Exit;
  End;

{
 Vid:=SelectImport(6);
 If Vid=2 Then Exit;
}

  VidReport:=1;
  VidReport:=SelectImport(19);
 If VidReport=2 Then
  Begin
   Dispose(Agent,Done);
   Dispose(GroupList,Done);
   Exit;
  End;


  If Not(Filtration(mm)) Then
  Begin
   Dispose(Agent,Done);
   Dispose(GroupList,Done);
   Exit;
  End;



 VidSkidka:=1;
If VidReport=0 Then
Begin
 VidSkidka:=SelectImport(7);
 If VidSkidka=2 Then
  Begin
   Dispose(Agent,Done);
   Dispose(GroupList,Done);
   Exit;
  End;
End;


 SelectorOplata:=1;
If VidReport=0 Then
Begin
 SelectorOplata:=SelectImport(10);
 If SelectorOplata=2 Then
  Begin
   Dispose(Agent,Done);
   Dispose(GroupList,Done);
   Exit;
  End;
End;



 Key:=0;
 Distant:=0;
If VidReport=0 Then
Begin
 If Not(KeySorting(Key,Distant)) Then
   Begin
   Dispose(Agent,Done);
   Dispose(GroupList,Done);
   Exit;
  End;
End;


 Space[0]:=#0;
 Assign(Txt1,Path.ToTemp+'cmeng.txt');
 l:=IOResult;
 Rewrite(Txt1);
 l:=IOResult;
 If L <> 0 Then
  Begin
   Dispose(Agent,Done);
   Dispose(GroupList,Done);
   MessageBox(#3^M+#3'Не могу создать файл отчета'+Path.ToTemp+'cmeng.txt',Nil,mfError+mfCancelButton);
   Exit;
  End;


 Assign(Txt2,Path.ToTemp+'cmengerr.txt');
 l:=IOResult;
 Rewrite(Txt2);
 l:=IOResult;
 If L <> 0 Then
  Begin
   Close(txt1);
   Dispose(Agent,Done);
   Dispose(GroupList,Done);
   MessageBox(#3^M+#3'Не могу создать файл отчета'+Path.ToTemp+'cmengerr.txt'+' Код:'+IntToStr(L,3) ,Nil,
   mfError+mfCancelButton);
   Exit;
  End;



If Distant=0 Then DistanationSorting:=True
Else DistanationSorting:=False;


 Assign(RazdelFile,Path.ToRAzdel+'Razdel.db');
 Reset(RazdelFile);
 i:=IOResult;
 If i<>0 Then
  Begin
   DistanationSorting:=True;
   Dispose(Agent,Done);
   Dispose(GroupList,Done);
   MessageBox(^M+#3+'Ошибка открытия файла разделов!',Nil,mfError+mfCancelButton);
   Exit;
  End;

R.Assign(0, 0, 0, 0);
Razdel1 := New(PBox, Init(R, 1, Nil));
Razdel1^.NewList(New(PTextCollection, Init(0,1)));
 While Not(Eof(RazdelFile)) Do
  Begin
   Read(RazdelFile,RazdelElement);
   If (RazdelElement.Employ){ And (RazdelElement.EnableDoc=0)} Then
    Begin                                       {базовая} {возвратыпоБазе}        {оплата}        {закупка}
     Razdel1^.List^.Insert(
        NewStr('│'+RazdelElement.Kod+'000'+'│           0.00│           0.00│           0.00│           0.00│'+
	   GetRazdelGroup(RazdelElement.Kod)));
     Razdel1^.SetRange(Razdel1^.List^.Count);
    End;
  End;
Close(RazdelFile);





R.Assign(0,0,0,0);
NoScreen:= New(PBox, Init(R, 1, Nil));
NoScreen^.NewList(New(PTextCollection, Init(0,1)));

R.Assign(0,0,0,0);
ItogClient:= New(PBox, Init(R, 1, Nil));
ItogClient^.NewList(New(PTextCollection, Init(0,1)));

R.Assign(0,0,0,0);
RazdelClient:= New(PBox, Init(R, 1, Nil));
RazdelClient^.NewList(New(PTextCollection, Init(0,1)));

R.Assign(0,0,0,0);
UseClient:= New(PBox, Init(R, 1, Nil));
UseClient^.NewList(New(PTextCollection, Init(0,1)));

R.Assign(0,0,0,0);
BonusBox:= New(PBox, Init(R, 1, Nil));
BonusBox^.NewList(New(PTextCollection, Init(0,1)));



Writeln(txt1,Space+'Склад: '+FormKod(Rek.Kod)++'  Оператор: '+CurrentPassword);
{
Write(txt1,Space+'Вид отбора:');
Case Vid Of
                     0:Writeln(txt1,'Служба доставки');
1:Writeln(txt1,'Сигаретники');
Else;
End;
}
Write(txt1,Space+'Отображать скидку:');
Case VidSkidka Of
0:Writeln(txt1,'Процентом');
1:Writeln(txt1,'Суммой');
Else;
End;




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
Write(txt1,Space+'Сортировка по:');
 Case Key Of
0{клиент}   :Write(txt1,'Клиенту');
1{дата отгр}:Write(txt1,'Дата отгрузки');
2{дата опл} :Write(txt1,'Дата оплаты');
3{скидка}   :Write(txt1,'Сумма скидки');
4{оплата}   :Write(txt1,'Сумма к оплате');
5{вид док}  :Write(txt1,'Вид документа');
6{Delta}    :Write(txt1,'Срок опоздания');
Else;
End;

Case Distant Of
0{клиент}   :WriteLn(txt1,' По возрастанию');
1{дата отгр}:WriteLn(txt1,' По убыванию');
Else WriteLn(txt1);
End;

Writeln(txt1);
Writeln(txt1,Space,'     СПРАВКА ПО ОПЛАЧЕННЫМ ОТГРУЗКАМ ЗА ПЕРИОД с '+StartDate+' по '+StopDate);
Writeln(txt1,Space+'┌─────────────────────────────────────────────────────────────────────────────────────┐');
Writeln(txt1,Space+'│N  Клиент               Док. Д отгруз Док. Д оплат.    Скидка  Сумма к опл. Вид. Del │');
Writeln(txt1,Space+'└─────────────────────────────────────────────────────────────────────────────────────┘');
                   {123 12345678901234567890 1234 12345678 1234 12345678 123456789 1234567890123 1234 1234}


AllItogo:=0;
AllSkidka:=0;
AllZakupka:=0;
AllDoc:=0;
SertifKol:=0;

Straf:=0;
EStraf:=0;
DInfo('Минуточку...');

FFF:=ProdagaWindow;

For Den:=Start To Stop Do
Begin
 Date:=DateToDateString(DateMask,DEn);
 Assign(F,Path.ToMarket+Date+'.mrk');
 DInfoMsg('Просматриваю продажи ...');

 l:=IOResult;
 Reset(f);
 l:=Ioresult;
 If L <> 0 Then
  Begin
   {MessageBox(^M+#3'Не найден файл '+Path.ToMarket+Date+'.mrk',Nil,mfError+mfCancelButton);}
   Writeln(txt2,'Не найден файл продаж за '+Date+'  "'+DayString[DayOfWeek(DAteStringToDate(DAteMask,Date))]+'"'+
   +' Код:'+IntToStr(L,3));

  End;
If l=0 Then
 Begin
  While Not (Eof(f)) Do
   Begin
      New(E,Init);
      Count:=0;
      ReadMArket(f,E);
Begin
If E^.Dat.Active Then
    If (E^.Dat.OperatorSelector=0) And TestAgent(E^.Dat.AgentKod)
       And (E^.Dat.DocSelector in [0,1,2,3,4])
       Then
Begin
        Docs:=0;
        If (E^.Dat.Realiz)  Then
       Begin
         Case E^.Dat.DocSelector Of
         0:Docs:=7;
         1:Docs:=5;
         3:Docs:=6;
         4:Docs:=8;
         Else ;
         End;
       End
        Else
              Begin
            Docs:=E^.Dat.DocSelector;
           End;
{фильтр документов подлежащих обработке}

        If mm[Docs+1]=1 Then
       Begin
        ProdagaWindow:=False;


        If (TestElement(IntToStr(E^.Dat.OperatorSelector,COne)+
           E^.Dat.ClientKod,ItogClient))
		 Then
         Begin
          ws1:=GetClientField(FClient,E^.Dat.ClientKod,
                E^.Dat.OperatorSelector);{отгрузка по базовым ценам}
          Format(ws1,CClient);
          ws1:=ws1+'│'+IntToStr(E^.Dat.OperatorSelector,COne)+
             E^.Dat.ClientKod+'│           0.00│         0.0000│         0.0000│';
          ItogClient^.List^.Insert(NewStr(ws1));
          ItogClient^.SetRange(ItogClient^.List^.Count);
         End;

         UseClient^.List^.Insert(NewStr(E^.Dat.ClientKod));
         UseClient^.SetRange(UseClient^.List^.Count);

        MySTr(StrToReal(E^.Dat.SummaZ)
                -StrToReal(E^.Dat.SummaZakupka),CIZena,CMAntissaZ,StrDohod);
                DelSpace(StrDohod);

        Delta:=CalcSrokOpozdania(E^.Dat.ClientKod,E^.Dat.DocReal,E^.Dat.DocDate,
                 E^.Dat.DateC);

        if StrToInt(Delta)<=28 then
        AddItogClient(IntToStr(E^.Dat.OperatorSelector,COne)+
           E^.Dat.ClientKod,E^.Dat.SummaZ,StrDohod,'0.00')
	   else
	   AddItogClient(IntToStr(E^.Dat.OperatorSelector,COne)+
           E^.Dat.ClientKod,'           0.00','         0.0000','0.00');

        For Cur:=1 To E^.Dat.Amount Do
         Begin
	    If Not(TestRazdelMemory(Copy(E^.Dat.MarketElement[cur].BazKod,1,CRazdelKod),Razdel1)) Then
           Begin
            s:=Razdel1^.GetText(
            LocationR(Razdel1,E^.Dat.MarketElement[Cur].BazKod,ProdagaWindow),Razdel1^.List^.Count);
            ws1:=Copy(s,1+1+CArtikul+1,CIZena);{отгрузка по базовым ценам}
            ww1:=Copy(s,1+1+CArtikul+1+CIZena+1+CIZena+1,CIZena);{отгрузка по ценам к оплате}
            ww2:=Copy(s,1+1+CArtikul+1+CIZena+1+CIZena+1+CIZena+1,CIZena);{отгрузка по з/ценам}
            {считаем отгрузку по базовым ценам}
            MyStr(StrToReal(ws1)+
            StrToInt(E^.Dat.MArketElement[Cur].Input.Kol)*
            StrToReal(E^.Dat.MArketElement[Cur].Input.Zena),CIZena,CMantissa,ws1);
            Delete(s,1+1+CArtikul+1,CIZena);
            Insert(ws1,s,1+1+CArtikul+1);

            {считаем отгрузку по ценам к оплате}
            Case E^.Dat.SkidkaSelector Of
            0,2:Begin{скидка автоматическая}
               MyStr(StrToReal(E^.Dat.MarketElement[cur].Input.Zena)*
               (StrToReal(E^.Dat.MarketElement[cur].Input.Proz)),CZena,CMantissa,
                        E^.Dat.MarketElement[cur].Input.Zena);
              End;
            1:Begin{скидка ручная}
                MyStr(StrToReal(E^.Dat.MarketElement[Cur].Input.Zena)-
                StrToReal(E^.Dat.MarketElement[Cur].Input.Skidka),CZena,CMantissa,
                         E^.Dat.MarketElement[Cur].Input.Zena);
              End;
            Else;
            End;

            MyStr(StrToReal(ww1)+
            StrToInt(E^.Dat.MArketElement[Cur].Input.Kol)*
            StrToReal(E^.Dat.MArketElement[Cur].Input.Zena),CIZena,CMantissa,ww1);

            MyStr(StrToInt(E^.Dat.MArketElement[Cur].Input.Kol)*
            StrToReal(E^.Dat.MArketElement[Cur].Input.Zena),CIZena,CMantissa,ww1r);

            Delete(s,1+1+CArtikul+1+CIZena+1+CIZena+1,CIZena);
            Insert(ww1,s,1+1+CArtikul+1+CIZena+1+CIZena+1);

            {считаем отгрузку по закупочным ценам}
            MyStr(StrToReal(ww2)+
            StrToInt(E^.Dat.MArketElement[Cur].Input.Kol)*
            StrToReal(E^.Dat.MArketElement[Cur].Input.Zakupka),CIZena,CMantissaZ,ww2);
            Delete(s,1+1+CArtikul+1+CIZena+1+CIZena+1+CIZena+1,CIZena);
            Insert(ww2,s,1+1+CArtikul+1+CIZena+1+CIZena+1+CIZena+1);

            MyStr(StrToInt(E^.Dat.MArketElement[Cur].Input.Kol)*
            StrToReal(E^.Dat.MArketElement[Cur].Input.Zena),CIZena,CMantissa,ww1);

            MyStr(StrToInt(E^.Dat.MArketElement[Cur].Input.Kol)*
            StrToReal(E^.Dat.MArketElement[Cur].Input.Zakupka),CIZena,CMantissa,ww2);

            MyStr(StrToInt(E^.Dat.MArketElement[Cur].Input.Kol)*
            StrToReal(E^.Dat.MArketElement[Cur].Input.Zakupka),CIZena,CMantissa,ww2r);

            if StrToReal(ww1r)>0.009 then
            MyStr(StrToReal(ww1r)-StrToReal(ww2r),CIZena,CMantissa,ww2r)
            else ww2r:='         0.0000';

            if (TestRazdelClient(IntToStr(E^.Dat.OperatorSelector,COne)+
            E^.Dat.ClientKod,
		  copy(E^.Dat.MarketElement[Cur].BazKod,1,2),RazdelClient))
		  Then
            Begin
             wsr:=IntToStr(E^.Dat.OperatorSelector,COne)+
            E^.Dat.ClientKod+'│'+copy(E^.Dat.MarketElement[Cur].BazKod,1,2)+
		  '│           0.00│         0.0000│    0│';
             RazdelClient^.List^.Insert(NewStr(wsr));
             RazdelClient^.SetRange(RazdelClient^.List^.Count);
            end;

            if StrToReal(ww1r)>0.009 then
            AddItogRazdelClient(IntToStr(E^.Dat.OperatorSelector,COne)+
            E^.Dat.ClientKod,copy(E^.Dat.MarketElement[Cur].BazKod,1,2),
		  ww1r,ww2r,'0')
		  else
            begin
            AddItogRazdelClient(IntToStr(E^.Dat.OperatorSelector,COne)+
            E^.Dat.ClientKod,copy(E^.Dat.MarketElement[Cur].BazKod,1,2),
		  ww1r,ww2r,E^.Dat.MarketElement[Cur].Input.kol);
            if (TestElement(E^.Dat.MarketElement[Cur].BazKod,BonusBox))  then
            begin
              wsr:='│'+E^.Dat.MarketElement[Cur].BazKod+'│    0│';
              BonusBox^.List^.Insert(NewStr(wsr));
              BonusBox^.SetRange(BonusBox^.List^.Count);
            end;
            AddBonus(E^.Dat.MarketElement[Cur].BazKod,E^.Dat.MarketElement[Cur].Input.Kol);
            AddGroupListOtgruska(BakGetField(FNGroupKod,E^.DAt.MarketElement[Cur].BazKod,0),
            ww1{по оплате},ww2{по закупке},'0.00');

            end;

            Razdel1^.List^.Atfree(LocationR(Razdel1,E^.Dat.MarketElement[Cur].BazKod,ProdagaWindow));
            Razdel1^.SetRange(Razdel1^.List^.Count);
            Razdel1^.List^.Insert(NewStr(s));
            Razdel1^.SetRange(Razdel1^.List^.Count);
           End;
         End;


         New(TestE,Init);
         StartLogik:=False;

         If E^.Dat.Realiz Then
         Begin
          A.EditPosition:=E^.Dat.DocReal;
          A.D:=E^.Dat.DocDate;
          If GetMarket1(A,TestE) Then StartLogik:=True;
         End
         Else
          Begin
           TestE^.Dat:=E^.Dat;
           StartLogik:=True;
          End;

        Dispose(TestE,Done);

        Inc(AllDoc);
        s:=IntToStr(AllDoc,3);
        RFormat(s,CLitrMantissa);
        ws:=GetClientField(FClient,E^.Dat.ClientKod,E^.Dat.OperatorSelector);
        Format(ws,CClient);
        Names:=ws;
        s:={s+' '}ws;
        Docs:=0;
        If (E^.Dat.Realiz)  Then
          Begin
           Delta:=CalcSrokOpozdania(E^.Dat.ClientKod,E^.Dat.DocReal,E^.Dat.DocDate,
                 E^.Dat.DateC);
           DelSpace(Delta);
           RFormat(Delta,CLitrMantissa+1);
         Case E^.Dat.DocSelector Of
         0:Docs:=7;
         1:Docs:=5;
         3:Docs:=6;
         4:Docs:=8;
         Else ;
         End;
          {E^.Dat.DateC:=E^.Dat.DocDate;
           E^.Dat.Document:=E^.Dat.DocReal;}
          End
        Else
              Begin
            Docs:=E^.Dat.DocSelector;
                  Delta:='   0';
                  E^.Dat.DocDate:=E^.Dat.DateC;
            E^.Dat.DocReal:=E^.Dat.Document;
           End;

        If mm[Docs+1]=1 Then
       Begin

        DelSpace(E^.Dat.Document);
        RFormat(E^.Dat.Document,CDocNumer{-1});
        DelSpace(E^.Dat.DocReal);
        RFormat(E^.Dat.DocReal,CDocNumer{-1});

        Format(E^.Dat.DateC,CDate);
        DateOtgr:=E^.Dat.DocDate;
        DateOplata:=E^.Dat.DateC;
        E^.Dat.DateC:=Copy(E^.Dat.DateC,1,CDate{-3});{сокращаем дату}
        E^.Dat.DocDate:=Copy(E^.Dat.DocDate,1,CDate{-3});{сокращаем дату}
        DateOpl:=Date;

        Format(DateOpl,CDate);
        DateOpl:=Copy(DateOpl,1,CDate{-3});{сокращаем дату}

        ws[0]:=#0;
        MyStr(StrToReal(E^.Dat.SummaZ)+StrToReal(E^.Dat.Skidka),CIZena-2,CMantissa,ws);
        Otgruz:=ws;
        MyStr(StrToReal(E^.Dat.Skidka),CIZena-6,CMantissa,E^.Dat.Skidka);
        MyStr(StrToReal(E^.Dat.SummaZ),CIZena-2,CMantissa,E^.Dat.SummaZ);

        AllItogo:=AllItogo+StrToreal(E^.Dat.SummaZ);
        AllZakupka:=AllZakupka+StrToReal(E^.Dat.SummaZakupka);
        AllSkidka:=AllSkidka+StrToreal(E^.Dat.Skidka);
        {
        If E^.Dat.Document='122' Then
         Begin
          Readln;
         End;
        }
        If VidSkidka=0 Then
        Begin
        If (StrToReal(E^.Dat.Skidka)<=0) Then
         Begin
          If Abs(StrToReal(ws))>0.009 Then
          MyStr(StrToReal(E^.Dat.Skidka)/StrToReal(ws)*100,CIZena-6,CMantissa,E^.Dat.Skidka)
          Else MyStr(0.00,CIZena-6,CMantissa,E^.Dat.Skidka);
         End
         Else
          Begin
           If Abs(StrToReal(ws)-StrToReal(E^.Dat.Skidka))>0.009 Then
           MyStr(
                   (StrToReal(ws)/
                    (StrToReal(ws)-StrToReal(E^.Dat.Skidka))-1)*100,CIZena-6,CMantissa,E^.Dat.Skidka)
           Else
             MyStr(99.99,CIZena-6,CMantissa,E^.Dat.Skidka);
          End;
        End;

        s:=s+' '+E^.Dat.DocReal+' '+E^.Dat.DocDate+' '+E^.Dat.Document+' '+
           E^.Dat.DateC+' '+{ws+' '+}
        +E^.Dat.Skidka+' '+E^.Dat.SummaZ;
        If (E^.Dat.DocSelector in [0,1,2,3,4]) And Not(E^.Dat.Realiz) Then
        Begin
         Case E^.Dat.DocSelector Of
         0:NameDoc:=' нСП ';
         1:NameDoc:=' нТЧ*';
         2:NameDoc:=' нФЛ*';
         3:NameDoc:=' нСФ*';
         4:NameDoc:=' нСФБ';
         Else NameDoc:='     ';
         End;
         s:=s+NameDoc;
        End
           Else
        Begin
         Case E^.Dat.DocSelector Of
         0:NameDoc:=' ДЕБ ';
         1:NameDoc:=' ДЕБ*';
         3:NameDoc:=' ДСФ*';
         4:NameDoc:=' ДСФБ';
         Else NameDoc:='     ';
         End;
         s:=s+NameDoc;
        End;
        s:=s+' '+Delta+' '+E^.Dat.ClientKod;
        RFormatZerro(Delta,CLitrMantissa+1);
        {Writeln(txt1,Space+s);}

        Str(DateStringToDate(DateMask,DateOtgr):6,DateOtgr);
        Str(DateStringToDate(DateMask,DateOplata):6,DateOplata);

        Case Key Of
        0{клиент}   :s:=Names+' '+s;
        1{дата отгр}:s:=DateOtgr+' '+s;
        2{дата опл} :s:=DateOplata+' '+s;
        3{скидка}   :Begin
                      RFormatZerro(E^.Dat.Skidka,(CIZena-6));
                      If Pos('-',E^.Dat.Skidka)>0 Then
                      Begin
                       E^.Dat.Skidka[Pos('-',E^.Dat.Skidka)]:='0';
                       E^.Dat.Skidka[1]:='-';
                      End;
                         s:=E^.Dat.Skidka+' '+s;
                     End;
        4{оплата}   :s:=E^.Dat.SummaZ+' '+s;
        5{вид док}  :s:=NameDoc+' '+s;
        6{Delta}    :s:=Delta+' '+s;
        Else;
        End;

        s:=s+' '+E^.Dat.AgentKod;
        AddAgentSumma(E^.Dat.AgentKod,E^.Dat.SummaZ,'0.00',E^.Dat.SummaZakupka);

        NoScreen^.List^.Insert(NewStr(s));
        NoScreen^.SetRange(NoScreen^.List^.Count);
       End;{If mm[Docs]}
 End;{If mm[Docs]}
End;{If}
End;{For по буферу}
Dispose(E,Done);
   End;{While}
   Close(f);
 End;{If l=0}
End;{For}
{Writeln(Txt1);}


NoInfoMsg;




DInfoMsg('Сохраняю промежуточные результаты расчета ...');



If NoScreen^.List^.Count>=1 Then
 Begin
  For Den:=0 To NoScreen^.List^.Count-1 Do
   Begin
     s:=NoScreen^.GetText(Den,NoScreen^.List^.Count);
        Case Key Of
        0{клиент}   :Delete(s,1,CClient+1);
        1{дата отгр}:Delete(s,1,CKol+1+1);
        2{дата опл} :Delete(s,1,CKol+1+1);
        3{скидка}   :Delete(s,1,(CIZena-6)+1);
        4{оплата}   :Delete(s,1,(CIZena-2)+1);
        5{вид док}  :Delete(s,1,(CKol)+1);
        6{Delta}    :Delete(s,1,(CLitrMantissa+1)+1);
        Else;
        End;

     Otgruz:=IntToStr(Den+1,CLitrMantissa);
     RFormat(Otgruz,CLitrMantissa);

     Cod:=Copy(s,Ord(s[0])-CClientKod*2,CClientKod);
     Ag:=Copy(s,Ord(s[0])-CClientKod+1,CClientKod);
     Doc:=Copy(s,1+CClient+1,CDocnumer);
     DelSpace(doc);
     date:=Copy(s,1+CClient+1+CDocnumer+1,CDate);
     DelSpace(Date);
     ws2:=Copy(s,1+CClient+1+(CDocnumer+1+CDate+1)*2+CIZena-6+1,CIZena-2);
     Dolg:=StrToReal(Copy(s,1+CClient+1+(CDocnumer+1+CDate+1)*2+CIZena-6+1,CIZena-2));
     s:=Otgruz+' '+s;
     Delete(s,Ord(s[0])-CClientKod*2-1,1+CClientKod*2+1);

     If VidReport=0 Then
     Begin
     If Slujba=0 Then
     Writeln(txt1,Space+'    Доставка: '+GetAgentField(FClient,Ag)+' ('+Ag+')'^M+Space+s)
     Else
     Writeln(txt1,Space+s);
     End;
     Straf:=0;


     {If (Pos(' ДЕБ ',s)>0)  Or (Pos(' ДЕБ*',s)>0)
        Or (Pos(' ДСФ*',s)>0)  Or (Pos(' ДСФБ',s)>0) Then}
     AddClientOplata(SelectorOplata,VidReport,Cod,Doc,Date,Dolg,txt1,Straf);
     AddAgentStraf(Ag,Straf);
     EStraf:=EStraf+Straf;
   End;
 End;
Writeln(Txt1);


Writeln(txt1,Space+'────────────────────────────────────────────────────────────────────────────────────-');

Writeln(Txt1,Space+'                                                    Всего документов: ',
AllDoc:CIZena);
Writeln(Txt1,Space+
'                                                      Всего к оплате: ',RecognizReal(AllItogo,CIZena,CMantissa));
Writeln(Txt1,Space+
'                                                    Всего по З/Ценам: ',RecognizReal(AllZakupka,CIZena,CMantissaZ));
Writeln(Txt1,Space+
'                                                         Всего доход: ',RecognizReal(AllItogo-AllZakupka,CIZena,CMantissaZ));

If AllZakupka>0.009 Then
Writeln(Txt1,Space+
'                                                      Рентабельность: ',RecognizReal((AllItogo-
AllZakupka)/
AllZakupka*100,CIZena,CMantissa)+' %');

Writeln(Txt1,Space+
'                                                     Начислено штраф: ',RecognizReal(EStraf,CIZena,CMantissa));
Writeln(Txt1,Space+
'                                                        Всего скидка: ',RecognizReal(AllSkidka,CIZena,CMantissa));
Writeln(Txt1,Space+
'                                                     Всего со склада: ',RecognizReal(AllItogo+AllSkidka,CIZena,CMantissa));
Writeln(Txt1,Space+
'                                    Всего израсходовано сертификатов: ',SertifKol:CIZena);
Writeln(Txt1,Space+
'                                     Количество сработавших клиентов: ',UseClient^.List^.Count:CIZena);


NoInfoMsg;

Dispose(NoScreen,Done);
DistanationSorting:=True;

AllReturn:=0;
AllReturnZakupka:=0;
AllSkidkaReturn:=0;
AllReturnDoc:=0;

Space:='   ';
Writeln(txt1);
Writeln(txt1,Space+'СПРАВКА О ВОЗВРАТАХ ПО ОПЛАЧЕННЫМ за ПЕРИОД с '+StartDate+' по '+StopDate+' ДОКУМЕНТАМ');
Writeln(txt1,Space+'┌───────────────────────────────────────────────────────────────────────────────┐');
Writeln(txt1,Space+'│N  Клиент               Док.Дата отг.Взв.Дата взв. Сумма возвр.  Сумма скидки п│');
Writeln(txt1,Space+'└───────────────────────────────────────────────────────────────────────────────┘');
                   {123 12345678901234567890 123 12345789 123 12345678 1234567890123 1234567890123 1 123}


New(Ret,Init);

For Den:=Start To Stop Do
Begin
 Date:=DateToDateString(DateMask,DEn);
 DInfoMsg('Просматриваю возвраты ...');
 Assign(RetF,Path.ToReturn+Date+'.vzw');
 l:=IOResult;
 Reset(Retf);
 l:=Ioresult;
If l=0 Then
 Begin
  While Not (Eof(Retf)) Do
   Begin
      ReadNewVozwrat(Retf,Ret);

If (Ret^.Dat.OperatorSelector=0) Then
    If (Ret^.Dat.StatusDoc=0) And
    {(TestClientName(GetClientField(FClient,Ret^.Dat.MakeKod,Ret^.Dat.OperatorSelector))=Vid)}
       (Ret^.Dat.VidDocument in [0,1,2,3])
       Then
       Begin
       If CalcAgentfromMrk(Ret^.Dat.BasisDoc,Ret^.Dat.BasisDate,Ag) Then
Begin
    If TestAgent(Ag) Then
Begin
        Ass.EDitPosition:=Ret^.Dat.BasisDoc;
        Ass.D:=Ret^.Dat.BasisDate;
        New(EEE,Init);
        GetMarket1(Ass,EEE);
        AllLocZakupka:=0;


        If TestElement(IntToStr(Ret^.Dat.OperatorSelector,COne)+REt^.Dat.MakeKod,ItogClient) Then
         Begin
          ws1:=GetClientField(FClient,Ret^.Dat.MakeKod,
                Ret^.Dat.OperatorSelector);{отгрузка по базовым ценам}
          Format(ws1,CClient);
          ws1:=ws1+'│'+IntToStr(Ret^.Dat.OperatorSelector,COne)+
          Ret^.Dat.MakeKod+'│           0.00│         0.0000│         0.0000│';
          ItogClient^.List^.Insert(NewStr(ws1));
          ItogClient^.SetRange(ItogClient^.List^.Count);
         End;


         {возврат по ценам к оплате}
         MyStr(StrToReal(RET^.Dat.SummaR)-StrToReal(RET^.Dat.Skidka),CIZena,CMantissa,ws);
         DelSpace(ws);
         MyStr(StrToReal(ws)-StrToReal(RET^.Dat.SummaZakupka),CIZena,CMantissaZ,StrDohod);
         DelSpace(StrDohod);

         AddItogClient(IntToStr(Ret^.Dat.OperatorSelector,COne)+
         Ret^.Dat.MAkeKod,'-'+ws,'-'+StrDohod,'-'+'0.00');



        For Cur:=1 To Ret^.Dat.Amount Do
         Begin
          If Not(TestRazdelMemory(Ret^.Dat.VozwratElement[cur].BazKod,Razdel1)) Then
           Begin
            s:=Razdel1^.GetText(
            LocationR(Razdel1,Ret^.Dat.VozwratElement[Cur].BazKod,ProdagaWindow),Razdel1^.List^.Count);
            ws1:=Copy(s,1+1+CArtikul+1+CIZena+1,CIZena);
            MyStr(StrToReal(ws1)+StrToInt(Ret^.DAt.VozwratElement[Cur].Input.Kol)*
            StrToReal(Ret^.DAt.VozwratElement[Cur].Input.Zena),CIZena,CMantissa,ws1);
            Delete(s,1+1+CArtikul+1+CIZena+1,CIZena);
            Insert(ws1,s,1+1+CArtikul+1+CIZena+1);
            Razdel1^.List^.Atfree(LocationR(Razdel1,Ret^.Dat.VozwratElement[Cur].BazKod,ProdagaWindow));
            Razdel1^.SetRange(Razdel1^.List^.Count);
            Razdel1^.List^.Insert(NewStr(s));
            Razdel1^.SetRange(Razdel1^.List^.Count);
           End;
          GetZakupka(EEE,Ret^.Dat.VozwratElement[cur].BazKod,SZakupka);

          MyStr(StrToInt(Ret^.DAt.VozwratElement[Cur].Input.Kol)*
          StrToReal(Ret^.DAt.VozwratElement[Cur].Input.Zena),CIZena,CMantissa,ww1);

          MyStr(StrToInt(Ret^.DAt.VozwratElement[Cur].Input.Kol)*
          StrToReal(SZakupka),CIZena,CMantissa,ww2);

          AddGroupListReturn(BakGetField(FNGroupKod,Ret^.Dat.VozwratElement[Cur].BazKod,0),
          ww1{по оплате},ww2{по закупке},'0.00');

          AllLocZakupka:=AllLocZakupka+StrToReal(SZakupka);
         End;

        Dispose(EEE,Done);
        Docs:=0;

        If (Ret^.Dat.VidDocument in [0,1]) Then{наличная продажа}
         Begin
         Case Ret^.Dat.DocSelector Of
         0:Docs:=7;
         1:Docs:=5;
         3:Docs:=6;
         4:Docs:=8;
         Else ;
         End;
         End
        Else
         Begin {закрытая консигнация}
          Docs:=Ret^.Dat.DocSelector;
         End;

        If mm[Docs+1]=1 Then
       Begin

        DelSpace(Ret^.Dat.BasisDate);
{       If (DateStringToDate(DateMask,Ret^.Dat.BasisDate)<Start) Then}
        Begin
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
        MyStr(StrToReal(RET^.Dat.Skidka),CIZena-2,CMantissa,RET^.Dat.Skidka);
        MyStr(StrToReal(RET^.Dat.SummaR),CIZena-2,CMantissa,RET^.Dat.SummaR);

        AllReturn:=AllReturn+StrToreal(RET^.Dat.SummaR);

        AllReturnZakupka:=AllReturnZakupka+AllLocZakupka;

        AllSkidkaReturn:=AllSkidkaReturn+StrToreal(Ret^.Dat.Skidka);
        s:=s+' '+Ret^.Dat.BasisDoc+' '+Ret^.Dat.BasisDate+' '+Ret^.Dat.Document+' '+REt^.Dat.DateC+' '+
        +Ret^.Dat.SummaR+' '+Ret^.Dat.Skidka;
        If (Ret^.Dat.VidDocument in [0,1]) Then s:=s+' '+'н' Else s:=s+'  ';
     If Slujba=0 Then
     Writeln(txt1,Space+'    Доставка: '+GetAgentField(FClient,Ag)+' ('+Ag+')'^M+Space+s)
     Else
     Writeln(txt1,Space+s)
        End;
       End;{mm[docs+1]=1}
End;{TestAgent(Ag)}
End;{CalcAgentfromMrk}
       End;{If}
   End;{While}
   Close(Retf);
 End;{If l=0}
End;{For}

NoInfoMsg;

Dispose(Ret,Done);

ProdagaWindow:=FFF;


DInfoMsg('Сохраняю промежуточные результаты расчета ...');

Writeln(Txt1);
Writeln(txt1,Space+'───────────────────────────────────────────────────────────────────────────────-');

Writeln(Txt1,Space+'                                        Всего документов: ',AllReturnDoc:CIZena);
Writeln(Txt1,Space+
                   '                         Всего возврат по ценам отгрузки: ',RecognizReal(AllReturn-AllSkidkaReturn,
                            CIZena,CMantissa));

Writeln(Txt1,Space+
                   '                                Всего возврат по З/Ценам: ',RecognizReal(AllReturnZakupka,
                            CIZena,CMantissaZ));

Writeln(Txt1,Space+
                   '                                   Всего упущенный доход: ',RecognizReal(AllReturn-AllSkidkaReturn-
                            AllReturnZakupka,
                            CIZena,CMantissa));

Writeln(Txt1,Space+
                   '                                   Всего скидка возврата: ',RecognizReal(AllSkidkaReturn,
                            CIZena,CMantissa));
Writeln(Txt1,Space+
                   '                          Всего возврат по базовым ценам: ',RecognizReal(AllReturn,CIZena,CMantissa));

If (Razdel1^.List^.Count-1)>=0 Then
Begin
{Space:='        ';}
Space:='';
Writeln(txt1);
Writeln(txt1,Space+'ИТОГОВАЯ СПРАВКА ПО ОПЛАЧЕННЫМ ОТГРУЗКАМ И ВОЗВРАТАМ ПО РАЗДЕЛАМ');
Writeln(txt1,Space+'┌───────────────────────────────────────────────────────────────────────────────────────────────────┐');
Writeln(txt1,Space+'│N Раздел                Сумма отгр   %   Сумма возвр.Сумма к опл.Сумма по ЗЦ   Доход,     %   К-во │');
Writeln(txt1,Space+'│                        теор, руб  от E  теор, руб      руб          руб        руб     доход клиен│');
Writeln(txt1,Space+'└───────────────────────────────────────────────────────────────────────────────────────────────────┘');
                   {12 12345678901234567890 12345678901│12345│12345678901│12345678901│12345678901│1234567890│12345}
{12 12345678901234567890 123456789012345 12345│123456789012345│12345│1234567890123│1234567890123}

{расчет дохода}
Dohod:=0.00;
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

  ws1:=Copy(s,1+CRazdelKod+1+CRazdel+1+CIZena+1+CIZena+1,CIZena);
  ws :=Copy(s,1+CRazdelKod+1+CRazdel+1+CIZena+1+CIZena+1+CIZena+1,CIZena);
  Dohod:=Dohod+StrToReal(ws1)-StrToReal(ws);
End;

{}
R.Assign(0,0,0,0);
Razdel2:= New(PBox, Init(R, 1, Nil));
Razdel2^.NewList(New(PTextCollection, Init(0,1)));

For Cur:=0 To Razdel1^.List^.Count-1 Do
Begin
  s:=Razdel1^.GetText(Cur,Razdel1^.List^.Count);
  ws:=copy(s,Length(s)-1,2);
  Razdel2^.List^.Insert(NewStr(ws+s));
  Razdel2^.SetRange(Razdel2^.List^.Count);
End;

R.Assign(0, 0, 0, 0);
Group := New(PBox, Init(R, 1,nil));
Group^.NewList(New(PTextCollection, Init(0,1)));

Assign(t,Path.ToSklad+'group.txt');
c:=ioresult;
Reset(t);
c:=ioresult;

If c=0 Then
Begin
While Not(Eof(t)) Do
 Begin
  Readln(t,s);
  Group^.List^.Insert(NewStr(s));
  Group^.SetRange(Group^.List^.Count);
 End;
System.Close(t);
End;

OldGrKOd:='00';
For Cur:=0 To Razdel2^.List^.Count-1 Do
 Begin

  s:=Razdel2^.GetText(Cur,Razdel2^.List^.Count);
  grkod:=copy(s,1,CRazdelKod);
  system.Delete(s,1,CRazdelKod);

  if (OldGrKOd<>grKOd) or (cur=0) then
  begin
    writeln(txt1,Space+'Товарная группа: '+GetGroupName(grKOd));
    OldGrKOd:=grKOd;
  end;

  While Pos('│',s)>0 Do s[Pos('│',s)]:=' ';
  Delete(s,1,1);

  ws1:=Copy(s,1,CRazdelKod);
  Delete(s,1+CRazdelKod,3);

  ws1:=GetRazdel(ws1);

  Format(ws1,CRazdel+1);
  Insert(ws1,s,1+CRazdelKod+1);

  {отгрузка}
  ws1:=Copy(s,1+CRazdelKod+1+CRazdel+1,CIZena);
  Str(StrToReal(ws1):CIZena-4:CMAntissa,ws1);
  {возврат}
  ws:=Copy(s,1+CRazdelKod+1+CRazdel+1+CIZena+1,CIZena);
  Str(StrToReal(ws):CIZena-4:CMAntissa,ws);
  {оплата}
  ww1:=Copy(s,1+CRazdelKod+1+CRazdel+1+CIZena+1+CIZena+1,CIZena);
  Str(StrToReal(ww1):CIZena-4:CMAntissa,ww1);
  {закупка}
  ww2:=Copy(s,1+CRazdelKod+1+CRazdel+1+CIZena+1+CIZena+1+CIZena+1,CIZena);
  Str(StrToReal(ww2):CIZena-4:CMAntissaZ,ww2);


If (StrToReal(ws1)>0.009) Or (StrToReal(ws)>0.009) Or (StrToReal(ww1)>0.009)
Or (StrToReal(ww2)>0.009) OR (CalcRazdelClient(cOPY(S,1,craZDELkOD))>0) Then
Begin

 If StrToReal(ww2)>0.009 Then
 Begin
  If (AllItogo+AllSkidka)>0.009 Then
  MyStr(StrToReal(ws1)/(AllItogo+AllSkidka)*100,CLitr,CMantissa,ws11)
  Else ws11:='??.??';
 End
 Else
   ws11:=' 0.00';

 If StrToReal(ww2)>0.009 Then
 Begin
  If ((StrToReal(ww1)-StrToReal(ww2))>0.009) Then
  MyStr((StrToReal(ww1)-StrToReal(ww2))/(StrToReal(ww2))*100,CLitr,CMantissa,ws22)
  Else ws22:='??.??';
 End
 Else
  ws22:=' 0.00';

  s[0]:=Chr(CRazdelKod+1+CRazdel+1);
  wsr:=IntToStr(CalcRazdelClient(cOPY(S,1,craZDELkOD)),Ckol);
  rformat(wsr,CKOl);
  s:=s+ws1+' '+ws11+' '+ws+' '+ww1+' '+ww2+' '+RealToStr(StrToReal(ww1)-StrToReal(ww2),CIZena-5,CMAntissaZ)+' '+ws22+' '+wsr;
{
  Insert(ws1+' ',s,1+CRazdelKod+1+CRazdel+1+CIZena+1);
  s:=s+' '+ws;
}
  Writeln(txt1,Space+s);
End;
 End;
End;
Writeln(txt1,Space+'────────────────────────────────────────────────────────────────────────────────────────────────────-');
Writeln(txt1,Space+'Всего доход:',Dohod:CIZena:CMantissaZ);

Dispose(Razdel2,Done);
Dispose(Group,Done);

If (BonusBox^.List^.Count-1)>=0 Then
Begin
{Space:='        ';}
Space:='   ';
Writeln(txt1);
Writeln(txt1,Space+'ИТОГОВАЯ СПРАВКА ПО БОНУСНЫМ ОТГРУЗКАМ ');
Writeln(txt1,Space+'┌─────────────────────────────────────┐');
Writeln(txt1,Space+'│ Код    Наименование            К-во,│');
Writeln(txt1,Space+'│                                шт.  │');
Writeln(txt1,Space+'└─────────────────────────────────────┘');

s:=BonusBox^.GetText(0,BonusBox^.List^.Count);
ws2:=Copy(s,1+1,CRazdelKod);
For Cur:=0 To BonusBox^.List^.Count-1 Do
 Begin
  s:=BonusBox^.GetText(Cur,BonusBox^.List^.Count);
  While Pos('│',s)>0 Do s[Pos('│',s)]:=' ';
  ws1:=Copy(s,1+1,CRazdelKod);
  if (StrToInt(ws1)<>StrToInt(ws2)) or (cur=0) then
  begin
   writeln(txt1,Space+'Раздел: '+GetRazdel(ws1));
   ws2:=ws1;
  end;
  ws:=BakGetField(FName,copy(s,1+1,CArtikul),0);
  format(ws,CName);
  System.Insert(' '+ws,s,1+1+CArtikul);
  Writeln(txt1,Space+s);
 end;

Writeln(txt1,Space+'───────────────────────────────────────');

End;


If (Agent^.List^.Count-1)>=0 Then
Begin
Space:='  ';
Writeln(txt1);
Writeln(txt1,Space+'   СПРАВКА ПО ОПЛАЧЕННЫМ ОТГРУЗКАМ ПО АГЕНТАМ');

Writeln(txt1,Space+'┌───────────────────────────────────────────────────────────────────────────────────────┐');
Writeln(txt1,Space+'│N        Агент         Код   Оплачена сумма   %      Всего штраф        Доход,руб   %  │');
Writeln(txt1,Space+'│                                            от E                                  доход│');
Writeln(txt1,Space+'└───────────────────────────────────────────────────────────────────────────────────────┘');

                   {12 12345678901234567890 1234 123456789012345 12345 123456789012345│123456789012345│12345}

For Cur:=0 To Agent^.List^.Count-1 Do
 Begin
  s:=Agent^.GetText(Cur,Agent^.List^.Count);
  {объем клиента по З/Цене }
  SumZ:=Copy(s,1+1+CClientKod+1+CIZena+1+CIZena+1,CIZena);
  System.Delete(s,1+1+CClientKod+1+CIZena+1+CIZena+1,CIZena);

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
  MyStr((StrToReal(SumO)-StrToReal(SumZ))/StrToReal(SumZ)*100,CLitr,CMantissa,ws1)
  Else ws1:='??.??';
End
  Else ws1:=' 0.00';

  MyStr((StrToReal(SumO)-StrToReal(SumZ)),CIZena,CMantissaZ,ws2);

  s:=s+ws2+' '+ws1;

  Writeln(txt1,Space+s);
 End;
End;{If Agent}

CreatReportFromClient(txt1);

CreatReportFromRazdelClient(txt1);



Space:='   ';


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

Close(txt2);
End;



Writeln(Txt1);
Writeln(Txt1,Space+'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
Writeln(txt1,Space+'================================================================================');

NoInfoMsg;

Close(txt1);
Dispose(Razdel1,Done);
Dispose(Agent,Done);
Dispose(GroupList,Done);
Dispose(ItogClient,Done);
Dispose(RazdelClient,Done);
Dispose(UseClient,Done);

NoInfo;
ViewAsText(Path.ToTemp+'cmeng.txt',True);
Report(Path.ToTemp+'cmeng.txt','',1,False,False,false);
End;{CalcTch}



End.