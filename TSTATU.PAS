{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}
Unit tStatu;


Interface


Uses Dialogs,Drivers,Glob,Access,ServStr,MyCalc,LockInfo,Utils;

Type
  PViewMarketWindow = ^TViewMarketWindow;
  TViewMarketWindow = object(TDialog)
    LockInfo : PLocalInfoDynamicDebit;
    Calc     : PMyCalculator;
    ViewMrk  : PFullScreenMrk;
    procedure Start(SVidOperation:Word);
    procedure DrawCurrent;
    procedure Refresh(LocSort:Word);
    procedure Sorting (LocSort : Word);
    Procedure FullPrevView;
    procedure FormReport(E:PBox);
    procedure HandleEvent(var Event: TEvent); virtual;
    Destructor Done;Virtual;
  end;

Type
  PViewRPWindow = ^TViewRPWindow;
  TViewRPWindow = object(TDialog)
    Calc     : PMyCalculator;
    ViewMrk  : PFullScreenMrk;
    procedure Start(SVidOperation:Word);
    procedure DrawCurrent;
    procedure Refresh(LocSort:Word);
    procedure Sorting (LocSort : Word);
    Procedure FullPrevView;
    procedure FormReport(E:PBox);
    procedure HandleEvent(var Event: TEvent); virtual;
    Destructor Done;Virtual;
  end;


Type
  PViewPrihodWindow = ^TViewPrihodWindow;
  TViewPrihodWindow = object(TDialog)
    Calc        : PMyCalculator;
    procedure Start(SVidOperation:Word);
    procedure DrawCurrent;
    procedure Refresh(LocSort:Word);
    procedure Sorting (LocSort : Word);
    Procedure FullPrevView;
    procedure FormReport(E:PBox);
    procedure HandleEvent(var Event: TEvent); virtual;
    Destructor Done;Virtual;
  end;


Type
  PViewReturnWindow = ^TViewReturnWindow;
  TViewReturnWindow = object(TDialog)
    Calc        : PMyCalculator;
    procedure Start(SVidOperation:Word);
    procedure DrawCurrent;
    procedure Refresh(LocSort:Word);
    procedure Sorting (LocSort : Word);
    Procedure FullPrevView;
    procedure FormReport(E:PBox);
    procedure HandleEvent(var Event: TEvent); virtual;
    Destructor Done;Virtual;
  end;

implementation

uses DBEngine,Objects, Views, MsgBox,Protect,TPDate,Market,Tools,Printers,TStat,
     App, ColorTxt,Validate,Serv,Nastr,Prise,
	Vision5,Vision4,Vision2,Vision1,Vision3,NetDbEng;

Var NoScr : PBox;
 ControlSummaPP,ControlNPP,ControlDatePP,ControlComment,ControlAgent,ControlRashet,
 ControlBank,ControlSkidkaSelector,ControlDocSelector,ControlIKol,ControlIZZ,ControlIRZ:PView;

 PrhList : PBox;
 VPrh :PViewPrihodWindow;
 VMrk :PViewMarketWindow;
 VRP  :PViewRpWindow;
 VRet :PViewReturnWindow;
 ControlLocSort,ControlLocFiltr,ControlEditFiltr:PView;
 LocSort,LocOperation,LocFiltr : Word;
 SLocOperation : Maska3;

procedure TViewPrihodWindow.Start(SVidOperation:Word);
Var R : TRect;
    Control : PView;
    c : Word;
    s,s1 : String;
Begin
DInfoMsg('Минуточку...');
R.Assign(0, 0, 80, 23);
New(VPrh, Init(R, 'Приходы на склад за период с '+StartDatetov+' по '+StopDatetov));
VPrh^.HelpCtx:=$F077;
R.Assign(79, 4, 80, 22);
Control := New(PScrollBar, Init(R));
VPrh^.Insert(Control);

R.Assign(1, 4, 79, 22);
PrhList := New(PBox, Init(R, 1, PScrollBar(Control)));
PrhList^.NewList(New(PTextCollection, Init(0,1)));

PrhList^.FocusItem(0);
PrhList^.HelpCtx:=$F076;
VPrh^.Insert(PrhList);

R.Assign(0, 0, 0, 0);
NoScr := New(PBox, Init(R, 1, PScrollBar(Control)));
NoScr^.NewList(New(PMyCollection, Init(0,1)));


  R.Assign(1, 3, 77, 4);
  VPrh^.Insert(New(PLabel, Init(R, 'Поставщик             Код  Док.  Дата   Колич  З/Цена   Р/Цена  Оператор', PrhList)));

R.Assign(1, 2, 79, 3);
s:=GetIdField(FName,SKodtov);
Format(s,CNAme);
s:=s+' Код:'+SKodTov+' Фас:';
s1:=GetIdField(FInPack,SKodTov);
s:=s+s1+' Литраж:';
s1:=GetIdField(FLitr,SKodTov);
s:=s+s1+' Цена:';
s1:=BakGetField(FRZena,SKodTov,1);
s:=s+s1;
Control := New(PColoredText, Init(R, #3+s, $71));
VPrh^.Insert(Control);

R.Assign(2, 22, 9, 23);
Control := New(PColoredText, Init(R, ' Всего:', $74));
VPrh^.Insert(Control);

R.Assign(9, 22, 16, 23);
ControlIKol := New(PColoredText, Init(R, #3+'0', $4E));
VPrh^.Insert(ControlIKol);


R.Assign(50, 22, 64, 23);
Control := New(PColoredText, Init(R, ' Итого по Р/Ц:', $74));
VPrh^.Insert(Control);

R.Assign(64, 22, 79, 23);
ControlIRZ := New(PColoredText, Init(R, #3+'0.00', $4E));
VPrh^.Insert(ControlIRZ);

R.Assign(18, 22, 32, 23);
Control := New(PColoredText, Init(R, ' Итого по З/Ц:', $74));
VPrh^.Insert(Control);

R.Assign(32, 22, 47, 23);
ControlIZZ := New(PColoredText, Init(R, #3+'0.00', $4E));
VPrh^.Insert(ControlIZZ);

R.Assign(1, 1, 35, 2);
ControlLocFiltr := New(PCheckboxes, Init(R,
  NewSItem('Кл~и~ент',
  NewSItem('~С~клад',
  NewSItem('~О~бмен', Nil)))));
VPrh^.Insert(ControlLocFiltr);
LocOperation:=OperationTov;

WordToBit3(LocOperation,SLocOperation);

Invert3(SLocOperation);
BitToWord3(SLocOperation,c);
PCluster(ControlLocFiltr)^.SetButtonState(c, False);

Invert3(SLocOperation);{возвращаем в нормальное состояние}

BitToWord3(SLocOperation,LocOperation);

ControlLocFiltr^.SetData(LocOperation);


  R.Assign(1, 0, 11, 1);
  VPrh^.Insert(New(PLabel, Init(R, 'Опера~ц~ии:', ControlLocFiltr)));

R.Assign(42, 1, 79, 2);
ControlLocSort := New(PRadioButtons, Init(R,
  NewSItem('Поста~в~щик',
  NewSItem('Ко~л~-во',
  NewSItem('Д~а~та', Nil)))));
VPrh^.Insert(ControlLocSort);

c:=2;
LocSort:=c;
ControlLocSort^.SetData(c);

  R.Assign(35, 1, 42, 2);
  VPrh^.Insert(New(PLabel, Init(R, 'Со~р~т.:', ControlLocSort)));

VPrh^.SelectNext(False);

{вставить текст формирования списка позиций}
VPrh^.Refresh(c);
NoInfoMsg;
c:=Desktop^.ExecView(VPrh);
Dispose(Control,Done);
Dispose(VPrh,Done);
Dispose(NoScr,Done);
End;

procedure TViewPrihodWindow.DrawCurrent;
Begin
End;

procedure TViewPrihodWindow.Refresh(LocSort:Word);
Var i,j : Word;
    ws,ws1,ws2 : String;
    TempBox : PBox;
    R : TRect;
    f : File of StatTovarPrihodType;
    ef : PStatTovarPrihodType;
    AllKol,AllSZ,AllSR:AllStr;

Begin
WordToBit3(LocOperation,SLocOperation);
Convert3(SLocOperation);

DInfoMsg('Минуточку...');

NoScr^.NewList(Nil);
NoScr^.NewList(New(PMyCollection, Init(0,1)));

Assign(f,Path.ToAnalys+SKodTov+'.prh');
i:=IOResult;
Reset(f);
If i<>0 Then
 Begin
  MessageBox(#3'Ошибка открытия файла '+Path.ToAnalys+SKodTov+'.prh!'^M+
  #3+ClicProgrammer,Nil,mfError+mfCancelButton);
  Exit;
 End;

New(Ef,Init);
AllSR:='0.00';
AllSZ:='0.00';
AllKol:='0';
While Not(eof(f)) Do
Begin
Read(f,ef^.Dat);
ws[0]:=#0;
If StrToInt(Ef^.Dat.SkladKod)=StrToInt(Rek.Kod) Then
Begin
If SLocOperation[Ef^.Dat.OperatorSelector+1]=1 Then
Begin
RFormatZerro(Ef^.Dat.Document,CDocnumer);
Format(Ef^.Dat.DateC,CDate);
DelSpace(Ef^.Dat.Kol);
RFormat(Ef^.Dat.Kol,CKol);
Str(StrToInt(Ef^.Dat.Kol)+StrToInt(AllKol):CKol+2,AllKol);
Str(StrToReal(Ef^.Dat.SummaPrihod)+StrToReal(AllSR):CIZena:CMantissa,AllSR);
Str(StrToReal(Ef^.Dat.SummaZakupka)+StrToReal(AllSZ):CIZena:CMantissa,AllSZ);

ws:=GetMakeField(FMAke,Ef^.Dat.MakeKod,Ef^.Dat.OperatorSelector);
Format(ws,CMAke);
Str(StrToReal(Ef^.Dat.SummaPrihod)/StrToInt(Ef^.Dat.Kol):CZena:CMAntissa,ws1);
Str(StrToReal(Ef^.Dat.SummaZakupka)/StrToInt(Ef^.Dat.Kol):CZena:CMAntissa,ws2);
ws:=ws+'│'+Ef^.Dat.MakeKod+'│'+Ef^.Dat.Document+'│'+Ef^.Dat.DateC+'│'+Ef^.Dat.Kol+
'│'+ws2+'│'+ws1+'│';
ws1:=GetOperatorName(Ef^.Dat.Caption);
Format(ws1,CKto);
ws:=ws+ws1+'│'+Ef^.Dat.TimeC;
NoScr^.List^.Insert(NewStr(ws));
NoScr^.SetRange(NoScr^.List^.Count);
End;
End;
End;
NoScr^.FocusItem(0);
NoScr^.HelpCtx:=$F076;

Dispose(Ef,Done);
System.Close(f);

DelSpace(AllKol);
DelSpace(AllSR);
DelSpace(AllSZ);

Dispose(ControlIKol,Done);
R.Assign(9, 22, 16, 23);
ControlIKol := New(PColoredText, Init(R, #3+AllKol, $4E));
VPrh^.Insert(ControlIKol);

Dispose(ControlIRZ,Done);
R.Assign(64, 22, 79, 23);
ControlIRZ := New(PColoredText, Init(R, #3+AllSR, $4E));
VPrh^.Insert(ControlIRZ);

Dispose(ControlIZZ,Done);
R.Assign(32, 22, 47, 23);
ControlIZZ := New(PColoredText, Init(R, #3+AllSZ, $4E));
VPrh^.Insert(ControlIZZ);

Sorting(LocSort);
NoInfoMsg;
Redraw;
End;

procedure TViewPrihodWindow.Sorting(LocSort : Word);
Var j: Word;
    ws,ws1,ws2 : String;
    R : TRect;
    TempBox : PBox;
Begin
DInfoMsg('Сортирую выборку...');
R.Assign(0,0,0,0);
TempBox := New(PBox, Init(R, 1, Nil));
TempBox^.NewList(New(PTextCollection, Init(0,1)));

PrhList^.NewList(Nil);
PrhList^.NewList(New(PMyCollection, Init(0,1)));

If NoScr^.List^.Count>0 Then
Begin
{формируем отсортированый список}
For j:=0 to NoScr^.List^.Count-1 Do
Begin
 ws:=NoScr^.GEtText(j,NoScr^.List^.Count);
Case LocSort Of
{поставщик}
0:ws:=ws;
{Раздел}
1:Begin
   ws1:=Copy(ws,1+CClient+1+CMakeKod+1+CDocNumer+1+CDAte+1,CKol);
   ws:=ws1+ws;
  End;
{Дата поступления}
2:Begin
   ws1:=Copy(ws,1+CClient+1+CMakeKod+1+CDocNumer+1,CDate);

   ws2:=Copy(ws,Ord(ws[0])-CDate+1,CDate);{время}
   ws1:=IntToSTr(DateStringToDate(DateMask,ws1),CDate);
   Format(ws1,CDate);
(*
   ws2:=Copy(ws,1+CClient+1+CMakeKod+1+CDocNumer+1+CDAte+1+CKol+1+CZena+1+CZena+
   1+CKto+1,CDate);{время}
   ws1:=IntToStr(DateStringToDate(DateMask,ws1),CDAte);*)
   ws:=ws1+' '+ws2+ws;
  End;
Else;
End;{CAse}
  TempBox^.List^.Insert(NewStr(ws));
  TempBox^.SetRange(TempBox^.List^.Count);
End;{for}


{форматируем сформированый список под экранную форму}
If TempBox^.List^.Count>0 Then
Begin
For j:=0 to TempBox^.List^.Count-1 Do
Begin
  ws:=TempBox^.GEtText(j,TempBox^.List^.Count);
Case LocSort Of
{поставщик}
0:ws:=ws;
{количество}
1:Begin
   System.Delete(ws,1,CKol);
  End;
{дата поступления}
2:Begin
   System.Delete(ws,1,CDAte+1+CDAte);
  End;
Else;
End;{CAse}
  PrhList^.List^.Insert(NewStr(ws));
  PrhList^.SetRange(PrhList^.List^.Count);
End;
End;
End;{if}

{0:поставщик
 1:количество
 2:дата поступления}

PrhList^.FocusItem(0);
PrhList^.HelpCtx:=$F076;

Dispose(TempBox,Done);
NoInfoMsg;

End;

Procedure TViewPrihodWindow.FullPrevView;
Var Ass : DocumentEdit;
    E : PPrihodType;
    R : TRect;
    f : PrihodFileType;
    c : Word;
    P : PBox;
    s,ws : TMyString;
    Find : Boolean;
    SDoc : ArtikulStr;
    SDate : TDateString;
    ws1,WspomSkidka:String[CIZena];

Begin
If (PrhList^.List<>Nil)And(PrhList^.List^.Count>=1) Then
Begin
  Ass.EditPosition:=Copy(PrhList^.GetText(PrhList^.Focused,PrhList^.List^.Count),1+CClient+1+CMakeKod+1,
  CDocNumer);
  DelSpace(Ass.EditPosition);
  DelZerro(Ass.EditPosition);
  Ass.D:=Copy(PrhList^.GetText(PrhList^.Focused,PrhList^.List^.Count),1+CClient+1+CMakeKod+1+CDocNumer+1,
  CDate);
  DelSpace(Ass.D);
  Assign(f,Path.ToPrihod+Ass.d+'.prh');
  c:=IOResult;
  Reset(f);
  c:=IOResult;
  If c<>0 Then
  Begin
   MessageBox(#3^M+#3'Ошибка доступа к файлу '+Path.ToPrihod+Ass.d+'.prh',Nil,mfError+mfCancelButton);
   Exit;
  End;
  DInfoMsg('Ищу документ...');
  New(E,Init);
  Find := False;
  ClearChar(Ass.EditPosition);
  While Not(Eof(f)) And Not(Find) Do
   Begin
   ReadPrihod(F,E);
   ClearChar(E^.Dat.Document);
    If (E^.Dat.DateC=Ass.D) and (E^.Dat.Document=Ass.EditPosition) Then
          Begin
           Find:=True;
           Break;
          End;
   End;
   System.Close(f);
   If Find Then
    Begin
     R.Assign(0,0,0,0);
P := New(PBox, Init(R, 1, Nil));
P^.NewList(New(PTextCollection, Init(1,1)));
For c:=1 To E^.Dat.Amount Do
 Begin
  S:=E^.Dat.PrihodElement[c].BazKod;
  ws:=GetIdField(FName,s);
  Format(ws,CName);
  s:=ws+'│'+s;
  ws:=GetIdField(FInPack,E^.Dat.PrihodElement[c].BazKod);
  RFormat(ws,CInPack);
  s:=s+'│'+ws;

  ws:=GetIdField(FLitr,E^.Dat.PrihodElement[c].BazKod);
  RFormat(ws,CInPack);
  s:=s+'│'+ws;

  DelSpace(E^.Dat.PrihodElement[c].Input.Kol);
  RFormat(E^.Dat.PrihodElement[c].Input.Kol,CKol);
  s:=s+'│'+E^.Dat.PrihodElement[c].Input.Kol;

  DelSpace(E^.Dat.PrihodElement[c].Input.Zakupka);
  RFormat(E^.Dat.PrihodElement[c].Input.Zakupka,CZena);
  s:=s+'│'+E^.Dat.PrihodElement[c].Input.Zakupka;

  DelSpace(E^.Dat.PrihodElement[c].Input.R_Zena);
  RFormat(E^.Dat.PrihodElement[c].Input.R_Zena,CZena);
  s:=s+'│'+E^.Dat.PrihodElement[c].Input.R_Zena;

  ws:=CalcPack(E^.Dat.PrihodElement[c].BazKod,E^.Dat.PrihodElement[c].Input.Kol);
  DelSpace(ws);
  Format(ws,CPAck);
  s:=s+'│'+ws+'│';


  P^.List^.Insert(NewStr(s));
  P^.SetRange(P^.List^.Count);
 End;


P^.FocusItem(0);

s:=E^.Dat.SummaZakupka;
DelSpace(s);
s:=' Всего по З/Ценам: '+s;
ws:=E^.Dat.SummaR;
DelSpace(ws);
s:=s+' Всего по Р/Ценам: '+ws;

SDoc:=E^.Dat.Document;
SDate:=E^.Dat.DateC;

Dispose(E,Done);

NoInfomsg;
                   {Вставить номер и дату документа в просмотре}
FullScreen(P,'Наименование товара         Код  Фас Литр  Колич  З/Цена   Р/Цена   Упаковок',s,
             {12345678901234567890123456│12345│123│12345│12345│12345678│12345678│123456789}
SDoc,SDAte,0);
Dispose(P,Done);
    End
Else
  Begin
  NoInfomsg;
  MessageBox(#3^M+#3'Документ не найден!',Nil,mfError+mfCancelButton);
  Dispose(E,Done);
  End;
End;
End;

procedure TViewPrihodWindow.FormReport(E:PBox);
Const SPace = '     ';
Var txt : Text;
    i,c : Word;
    ws,s1 : String;
Begin
 WordToBit3(LocOperation,SLocOperation);
 Convert3(SLocOperation);

 Assign(txt,Path.ToTemp+'stprih.txt');
 i:=IOResult;
 Rewrite(txt);
 i:=IOResult;
 If i<>0 Then
  Begin
   MessageBox(^M+#3'Ошибка создания '+Path.ToTemp+'stprih.txt'+
   ^M+#3+ClicProgrammer,Nil,mfError+mfCancelButton);
   Exit;
  End;
 DInfoMsg('Формирую отчет. Ждите...');

 Writeln(Txt,Space+'Склад: ',GetClientField(FClient,Rek.Kod,1)+'  Оператор: '+CurrentPassword+' EYE & 1997-98');

 Writeln(txt,Space+'Включены в рассмотрение следующие виды операций:');
 Write(txt,Space);
 For c:=1 To Max3 Do
  Begin
   If SLocOperation[c]=1 Then
    Case c Of
    1:Write(txt,' "Клиент" ');
    2:Write(txt,' "Склад" ');
    3:Write(txt,' "Обмен" ');
    Else;
    End;
  End;
 Writeln(txt);
 Write(txt,Space+'Вид сортировки:');
    Case LocSort Of
    0:WriteLn(txt,' "Поставщик" ');
    1:WriteLn(txt,' "Количество" ');
    2:WriteLn(txt,' "Дата" ');
    Else;
    End;
 Writeln(txt,Space+Bold[NPrint.Printer]+'     СПРАВКА ПО ПРИХОДУ ТОВАРА ЗА ПЕРИОД С '+StartDateTov+' ПО '+StopDateTov+
 NoBold[NPrint.Printer]);
 Writeln(txt,Space+'Выбранная позиция товара:');

ws:=GetIdField(FName,SKodTov);
Format(ws,CNAme);
ws:=ws+' Код:'+SKodTov+' Фас:';
s1:=GetIdField(FInPack,SKodTov);
ws:=ws+s1+' Литраж:';
s1:=GetIdField(FLitr,SKodTov);
ws:=ws+s1+' Цена:';
s1:=BakGetField(FRZena,SKodTov,1);
ws:=ws+s1;
 Writeln(txt,Space+Italic[NPrint.Printer]+ws+NoItalic[NPrint.Printer]);

 Writeln(txt,Space+'----------------------------------------------------------------------------');
 Writeln(txt,Space+'     Поставщик       Код  Док.   Дата   Колич. З/Цена   Р/Цена   Оператор');
                   {12345678901234567890│1234│1234│12-45-78│12345│12345678│12345678│123456789012}
 Writeln(txt,Space+'----------------------------------------------------------------------------');
If E^.List^.Count>0 Then
Begin
 For c:=0 To E^.List^.Count-1 Do
 Begin
  ws:=E^.GetText(c,E^.List^.Count);
  While Pos('│',ws)>0 Do ws[Pos('│',ws)]:=' ';
  ws[0]:=Chr(CClient+1+CMakeKod+1+CDocNumer+1+CDate+1+CKol+1+CZena+1+CZena+1+CKto);
 Writeln(txt,Space+ws);
 End;
End;
 Writeln(txt,Space+'----------------------------------------------------------------------------');


PStaticText(ControlIKol)^.GetText(ws);
System.Delete(ws,1,1);
DelSpace(ws);
RFormat(ws,CIZena);

 Writeln(txt,Space+'                                             Всего приход: '+ws);

PStaticText(ControlIZZ)^.GetText(ws);
System.Delete(ws,1,1);
DelSpace(ws);

 Writeln(txt,Space+'                                         Всего по З/Ценам: '+
 Recogniz(RealToStr(StrToReal(ws),CIZena,CMAntissa)));

PStaticText(ControlIRZ)^.GetText(ws);
System.Delete(ws,1,1);
DelSpace(ws);

 Writeln(txt,Space+'                                         Всего по Р/Ценам: '+
 Recogniz(RealToStr(StrToReal(ws),CIZena,CMAntissa)));

 Writeln(txt);
 Writeln(txt,Space,'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
 Writeln(txt,Space+'============================================================================');

 System.Close(txt);
 NoInfoMsg;
 Report(Path.ToTemp+'stprih.txt','',1,False,False,false);
End;

procedure TViewPrihodWindow.HandleEvent(var Event: TEvent);

procedure Calculator;
begin
  Calc^.Start;
end;

Var Test : Word;

Begin
  Case Event.What Of
  evKeyDown :
  Case Event.KeyCode Of
     kbEsc: Begin
              ClearFind;
              Event.What:=evCommand;
              Event.Command:=cmCancel;
              PutEvent(Event);
              ClearEvent(Event);
            End;
      Else;
      End;{KeyDown}
  evCommand :
     Case Event.Command Of
       cmLocalCalc:Begin
                     ClearFind;
                     Calculator;
                   End;
  cmFullView:Begin
              ClearFind;
              If (PrhList^.State and sfFocused <> 0) And (PrhList^.List<>Nil)And(PrhList^.List^.Count>=1) Then
               Begin
                FullPrevView;
               End
            End;

  cmPrintReestr:    Begin
                 ClearFind;
     If (PrhList^.State and sfFocused <> 0) And (PrhList^.List<>Nil)And(PrhList^.List^.Count>=1) Then
            Begin
                Assistent.EditPosition:=Copy(PrhList^.GetText(PrhList^.Focused,PrhList^.List^.Count),1+CClient+1+CMakeKod+1,
			 CDocNumer);
                DelSpace(Assistent.EditPosition);
                DelZerro(Assistent.EditPosition);
                Assistent.D:=Copy(PrhList^.GetText(PrhList^.Focused,PrhList^.List^.Count),1+CClient+1+CMakeKod+1+CDocNumer+1,
			 CDate);
                DelSpace(Assistent.D);
                If MessageBox(^M+#3'Печатать накладную прихода N '+Assistent.EditPosition+' от '+Assistent.D+'?',Nil,
			 mfConfirmation+mfOKCancel)=cmOk Then
                PrintPrihod(Assistent);
            End
            End;
 cmReestrReport:    Begin
                 ClearFind;
     If (PrhList^.List<>Nil)And(PrhList^.List^.Count>=1) Then
            Begin
             FormReport(PrhList);
            End
            End;
      Else;
      End;{evCommand}
      Else;
      End;{*Case*}
  if (Event.What = evBroadcast) and
    (Event.Command = cmPrihC) then ClearEvent(Event);

  if (Event.What = evBroadcast) and
    (Event.Command = cmQuit) then ClearEvent(Event);

inherited HandleEvent(Event);

  if (ControlLocSort^.State and sfFocused <> 0)Then
                    Begin
                        ControlLocSort^.GetData(Test);
                        If Test <> LocSort Then
                        Begin
                           ClearFind;
                           LocSort:=Test;
                           Sorting(LocSort);
                           Redraw;
                        End;
                    End;

  if (ControlLocFiltr^.State and sfFocused <> 0)Then
                    Begin
                        ControlLocFiltr^.GetData(Test);
                        If Test <> LocOperation Then
                        Begin
                           ClearFind;
                           LocOperation:=Test;
                           Refresh(LocSort);
                           Redraw;
                        End;
                    End;

End;

Destructor TViewPrihodWindow.Done;
Begin
TDialog.Done;
End;


procedure TViewMarketWindow.Start(SVidOperation:Word);
Var R : TRect;
    Control : PView;
    c : Word;
    s,s1 : String;
Begin

R.Assign(0, 0, 0, 0);
Agent := New(PBox, Init(R, 1, Nil));
Agent^.NewList(New(PTextCollection, Init(0,1)));

If Not(SelectionAgent(Agent)) Then
 Begin
  Dispose(Agent,Done);
  Exit;
 End;


DInfoMsg('Минуточку...');
R.Assign(0, 0, 80, 23);
New(VMrk, Init(R, 'Отгрузки со склада за период с '+StartDateTov+' по '+StopDateTov));
VMrk^.HelpCtx:=$F082;
R.Assign(79, 4, 80, 18);
Control := New(PScrollBar, Init(R));
VMrk^.Insert(Control);

R.Assign(1, 4, 79, 18);
PrhList := New(PBox, Init(R, 1, PScrollBar(Control)));
PrhList^.NewList(New(PTextCollection, Init(0,1)));

PrhList^.FocusItem(0);
PrhList^.HelpCtx:=$F082;
VMrk^.Insert(PrhList);

R.Assign(0, 0, 0, 0);
NoScr := New(PBox, Init(R, 1, PScrollBar(Control)));
NoScr^.NewList(New(PMyCollection, Init(0,1)));


  R.Assign(1, 3, 77, 4);
  VMrk^.Insert(New(PLabel, Init(R, 'Клиент                Код  Док.  Дата   Колич  З/Цена   Р/Цена     Оператор', PrhList)));

R.Assign(1, 2, 79, 3);
s:=GetIdField(FName,SKodTov);
Format(s,CNAme);
s:=s+' Код:'+SKodTov+' Фас:';
s1:=GetIdField(FInPack,SKodTov);
s:=s+s1+' Литраж:';
s1:=GetIdField(FLitr,SKodTov);
s:=s+s1+' Цена:';
s1:=BakGetField(FRZena,SKodTov,1);
s:=s+s1;
Control := New(PColoredText, Init(R, #3+s, $71));
VMrk^.Insert(Control);

R.Assign(2, 22, 9, 23);
Control := New(PColoredText, Init(R, ' Всего:', $74));
VMrk^.Insert(Control);

R.Assign(9, 22, 16, 23);
ControlIKol := New(PColoredText, Init(R, #3+'0', $4E));
VMrk^.Insert(ControlIKol);


R.Assign(50, 22, 64, 23);
Control := New(PColoredText, Init(R, ' Итого по Р/Ц:', $74));
VMrk^.Insert(Control);

R.Assign(64, 22, 79, 23);
ControlIRZ := New(PColoredText, Init(R, #3+'0.00', $4E));
VMrk^.Insert(ControlIRZ);

R.Assign(18, 22, 32, 23);
Control := New(PColoredText, Init(R, ' Итого по З/Ц:', $74));
VMrk^.Insert(Control);

R.Assign(32, 22, 47, 23);
ControlIZZ := New(PColoredText, Init(R, #3+'0.00', $4E));
VMrk^.Insert(ControlIZZ);

R.Assign(1, 1, 35, 2);
ControlLocFiltr := New(PCheckboxes, Init(R,
  NewSItem('Кл~и~ент',
  NewSItem('~С~клад',
  NewSItem('~О~бмен', Nil)))));
VMrk^.Insert(ControlLocFiltr);
LocOperation:=OperationTov;

WordToBit3(LocOperation,SLocOperation);

Invert3(SLocOperation);
BitToWord3(SLocOperation,c);
PCluster(ControlLocFiltr)^.SetButtonState(c, False);

Invert3(SLocOperation);{возвращаем в нормальное состояние}

BitToWord3(SLocOperation,LocOperation);

ControlLocFiltr^.SetData(LocOperation);

  R.Assign(1, 0, 11, 1);
  VMrk^.Insert(New(PLabel, Init(R, 'Опера~ц~ии:', ControlLocFiltr)));

R.Assign(42, 1, 79, 2);
ControlLocSort := New(PRadioButtons, Init(R,
  NewSItem('Клиен~т~',
  NewSItem('Ко~л~-во',
  NewSItem('Д~а~та', Nil)))));
VMrk^.Insert(ControlLocSort);

c:=2;
LocSort:=c;
ControlLocSort^.SetData(c);

  R.Assign(35, 1, 42, 2);
  VMrk^.Insert(New(PLabel, Init(R, 'Со~р~т.:', ControlLocSort)));

R.Assign(27, 18, 41, 19);
Control := New(PColoredText, Init(R, 'Вид документа:', $74));
VMrk^.Insert(Control);

R.Assign(41, 18, 50, 19);
ControlDocSelector := New(PColoredText, Init(R, #3+'', $7E));
VMrk^.Insert(ControlDocSelector);

R.Assign(7, 18, 14, 19);
Control := New(PColoredText, Init(R, 'Расчет:', $74));
VMrk^.Insert(Control);

R.Assign(14, 18, 21, 19);
ControlRashet := New(PColoredText, Init(R, #3+'', $7E));
VMrk^.Insert(ControlRashet);

R.Assign(43, 20, 52, 21);
Control := New(PColoredText, Init(R, 'Доставка:', $74));
VMrk^.Insert(Control);

R.Assign(52, 20, 78, 21);
ControlAgent := New(PColoredText, Init(R, #3+'', $7E));
VMrk^.Insert(ControlAgent);

R.Assign(3, 19, 8, 20);
Control := New(PColoredText, Init(R, 'Банк:', $74));
VMrk^.Insert(Control);

R.Assign(8, 19, 53, 20);
ControlBank := New(PColoredText, Init(R, #3+'', $7E));
VMrk^.Insert(ControlBank);

R.Assign(56, 18, 63, 19);
Control := New(PColoredText, Init(R, 'Скидка:', $74));
VMrk^.Insert(Control);

R.Assign(63, 18, 71, 19);
ControlSkidkaSelector := New(PColoredText, Init(R, #3+'', $7E));
VMrk^.Insert(ControlSkidkaSelector);

R.Assign(13, 21, 58, 22);
ControlComment := New(PColoredText, Init(R, #3+'', $7E));
VMrk^.Insert(ControlComment);

R.Assign(2, 21, 13, 22);
Control := New(PColoredText, Init(R, 'Примечание:', $74));
VMrk^.Insert(Control);

R.Assign(56, 19, 66, 20);
Control := New(PColoredText, Init(R, 'Номер п/п:', $74));
VMrk^.Insert(Control);

R.Assign(66, 19, 76, 20);
ControlNPP := New(PColoredText, Init(R, #3+'', $7E));
VMrk^.Insert(ControlNPP);

R.Assign(3, 20, 12, 21);
Control := New(PColoredText, Init(R, 'Дата п/п:', $74));
VMrk^.Insert(Control);

R.Assign(12, 20, 20, 21);
ControlDatePP := New(PColoredText, Init(R, #3+'', $7E));
VMrk^.Insert(ControlDatePP);

R.Assign(22, 20, 32, 21);
Control := New(PColoredText, Init(R, 'Сумма п/п:', $74));
VMrk^.Insert(Control);

R.Assign(32, 20, 42, 21);
ControlSummaPP := New(PColoredText, Init(R, #3+'', $7E));
VMrk^.Insert(ControlSummaPP);

{Izmen:=0;}
{
If StrToInt(CurrentPassword)=0 Then
Begin
R.Assign(62, 21, 79, 22);
ControlEditFiltr := New(PCheckboxes, Init(R,
  NewSItem('Из~м~ененные', Nil)));
VMrk^.Insert(ControlEditFiltr);
ControlEditFiltr^.SetDAta(Izmen);
End;
}

VMrk^.SelectNext(False);

{вставить текст формирования списка позиций}
VMrk^.Refresh(c);
NoInfoMsg;
c:=Desktop^.ExecView(VMrk);
Dispose(Control,Done);
Dispose(VMrk,Done);
Dispose(NoScr,Done);
Dispose(Agent,Done);

End;

procedure TViewMarketWindow.DrawCurrent;
Var st,ts,ts1 : String;
    R : TRect;
Begin
If (PrhList^.List<>Nil)And(PrhList^.List^.Count>0)  Then
 Begin
  st:=PrhList^.GetText(PrhList^.Focused,PrhList^.List^.Count);
  If St <> PrevLine Then
   Begin
    PrevLine:=St;
    ts:=Copy(st,1+CClient+1+CMakeKod+1+CdocNumer+1+CDate+1+CKOl+1+CZena+1+CZena+1,COne);

    Case StrToInt(ts) Of
    0:ts:='Список';
    1:ts:='Тов.Чек*';
    2:ts:='Физ.Л*';
    3:ts:='СФ*';
    4:ts:='СФ ';
    5:ts:='Дебит*';
    6:ts:='Дебит СФ*';
    7:ts:='Дебит';
    8:ts:='Дебит СФ';
    Else ts:='???';
    End;
Dispose(ControlDocSelector,Done);
R.Assign(41, 18, 50, 19);
ControlDocSelector := New(PColoredText, Init(R, #3+ts, $7E));
VMrk^.Insert(ControlDocSelector);

    ts:=Copy(st,1+CClient+1+CMakeKod+1+CdocNumer+1+CDate+1+CKOl+1+CZena+1+CZena+1+COne+1+CKto+1+COne+1,COne);
    Case StrToInt(ts) Of
    0:ts:='Нал';
    1:ts:='Б/Н';
    2:ts:='Вексель';
    Else ts:='???';
    End;

Dispose(ControlRashet,Done);
R.Assign(14, 18, 21, 19);
ControlRashet := New(PColoredText, Init(R, #3+ts, $7E));
VMrk^.Insert(ControlRashet);


    ts:=Copy(st,1+CClient+1+CMakeKod+1+CdocNumer+1+CDate+1+CKOl+1+CZena+1+CZena+1+COne+1+CKto+1+COne+1
    +COne+1,CMAkeKod);
DelSpaceRight(ts);
ts1:=GetAgentField(Fagent,ts);
Format(ts1,CClient);
Dispose(ControlAgent,Done);
R.Assign(52, 20, 78, 21);
ControlAgent := New(PColoredText, Init(R, #3+ts1+'('+ts+')', $7E));
VMrk^.Insert(ControlAgent);

    ts:=Copy(st,1+CClient+1+CMakeKod+1+CdocNumer+1+CDate+1+CKOl+1+CZena+1+CZena+1+COne+1+CKto+1+COne+1
    +COne+1+CMAkeKod+1,CAll);
DelSpaceRight(ts);
Dispose(ControlBAnk,Done);
R.Assign(8, 19, 53, 20);
ControlBank := New(PColoredText, Init(R, #3+ts, $7E));
VMrk^.Insert(ControlBank);


    ts:=Copy(st,1+CClient+1+CMakeKod+1+CdocNumer+1+CDate+1+CKOl+1+CZena+1+CZena+1+COne+1+CKto+1,COne);

    Case StrToInt(ts) Of
    0:ts:='Авто';
    1:ts:='Ручная';
    Else ts:='???';
    End;

Dispose(ControlSkidkaSelector,Done);
R.Assign(63, 18, 71, 19);
ControlSkidkaSelector := New(PColoredText, Init(R, #3+ts, $7E));
VMrk^.Insert(ControlSkidkaSelector);

    ts:=Copy(st,1+CClient+1+CMakeKod+1+CdocNumer+1+CDate+1+CKOl+1+CZena+1+CZena+1+COne+1+CKto+1+COne+1
    +COne+1+CMAkeKod+1+CAll+1+CDate+1+10+1+CIZena+1,CAll);
    DelSpace(ts);

Dispose(ControlComment,Done);
R.Assign(13, 21, 58, 22);
ControlComment := New(PColoredText, Init(R, #3+ts, $7E));
VMrk^.Insert(ControlComment);

    ts:=Copy(st,1+CClient+1+CMakeKod+1+CdocNumer+1+CDate+1+CKOl+1+CZena+1+CZena+1+COne+1+CKto+1+COne+1
    +COne+1+CMAkeKod+1+CAll+1+CDate+1,10);
DelSpace(ts);
Dispose(ControlNPP,Done);
R.Assign(66, 19, 76, 20);
ControlNPP := New(PColoredText, Init(R, #3+ts, $7E));
VMrk^.Insert(ControlNPP);

    ts:=Copy(st,1+CClient+1+CMakeKod+1+CdocNumer+1+CDate+1+CKOl+1+CZena+1+CZena+1+COne+1+CKto+1+COne+1
    +COne+1+CMAkeKod+1+CAll+1,CDate);

Dispose(ControlDatePP,Done);
R.Assign(12, 20, 20, 21);
ControlDatePP := New(PColoredText, Init(R, #3+ts, $7E));
VMrk^.Insert(ControlDatePP);

    ts:=Copy(st,1+CClient+1+CMakeKod+1+CdocNumer+1+CDate+1+CKOl+1+CZena+1+CZena+1+COne+1+CKto+1+COne+1
    +COne+1+CMAkeKod+1+CAll+1+CDate+1+10+1,CIZena);
    DelSpace(ts);
Dispose(ControlSummaPP,Done);
R.Assign(32, 20, 42, 21);
ControlSummaPP := New(PColoredText, Init(R, #3+ts, $7E));
VMrk^.Insert(ControlSummaPP);
Redraw;
   End;
 End
 Else
  Begin
   PStaticText(ControlDocSelector)^.GetText(st);
  If (st)<>(#3+'???') Then
  Begin
Dispose(ControlDocSelector,Done);
R.Assign(41, 18, 50, 19);
ControlDocSelector := New(PColoredText, Init(R, #3+'???', $7E));
VMrk^.Insert(ControlDocSelector);

Dispose(ControlRashet,Done);
R.Assign(14, 18, 21, 19);
ControlRashet := New(PColoredText, Init(R, #3+'???', $7E));
VMrk^.Insert(ControlRashet);

Dispose(ControlAgent,Done);
R.Assign(52, 20, 78, 21);
ControlAgent := New(PColoredText, Init(R, #3+'???', $7E));
VMrk^.Insert(ControlAgent);

Dispose(ControlBAnk,Done);
R.Assign(8, 19, 53, 20);
ControlBank := New(PColoredText, Init(R, #3+'???', $7E));
VMrk^.Insert(ControlBank);

Dispose(ControlSkidkaSelector,Done);
R.Assign(63, 18, 71, 19);
ControlSkidkaSelector := New(PColoredText, Init(R, #3+'???', $7E));
VMrk^.Insert(ControlSkidkaSelector);

Dispose(ControlComment,Done);
R.Assign(13, 21, 58, 22);
ControlComment := New(PColoredText, Init(R, #3+'???', $7E));
VMrk^.Insert(ControlComment);

Dispose(ControlNPP,Done);
R.Assign(66, 19, 76, 20);
ControlNPP := New(PColoredText, Init(R, #3+'???', $7E));
VMrk^.Insert(ControlNPP);

Dispose(ControlDatePP,Done);
R.Assign(12, 20, 20, 21);
ControlDatePP := New(PColoredText, Init(R, #3+'???', $7E));
VMrk^.Insert(ControlDatePP);

Dispose(ControlSummaPP,Done);
R.Assign(32, 20, 42, 21);
ControlSummaPP := New(PColoredText, Init(R, #3+'???', $7E));
VMrk^.Insert(ControlSummaPP);
  st:='';
  PrevLine:=St;
  Redraw;
  End;
  End;


End;

procedure TViewMarketWindow.Refresh(LocSort:Word);
Var i,j : Word;
    ws,ws1,ws2,Comment : String;
    TempBox : PBox;
    R : TRect;
    f : File of StatTovarMarketType;
    ef : PStatTovarMarketType;
    AllKol,AllSZ,AllSR:AllStr;

Begin
WordToBit3(LocOperation,SLocOperation);
Convert3(SLocOperation);

DInfoMsg('Минуточку...');


Assign(f,Path.ToAnalys+SKodTov+'.mrk');
i:=IOResult;
Reset(f);
If i<>0 Then
 Begin
  NoinfoMsg;
  MessageBox(#3'Ошибка открытия файла '+Path.ToAnalys+SKodTov+'.mrk!'^M+
  #3+ClicProgrammer,Nil,mfError+mfCancelButton);
  Exit;
 End;

NoScr^.NewList(Nil);
NoScr^.NewList(New(PMyCollection, Init(0,1)));


New(Ef,Init);
AllSR:='0.00';
AllSZ:='0.00';
AllKol:='0';
While Not(eof(f)) Do
Begin
Read(f,ef^.Dat);
ws[0]:=#0;
If (StrToInt(Ef^.Dat.SkladKod)=StrToInt(Rek.Kod)) And (TestAgent(Ef^.Dat.AgentKod)) Then
Begin
If SLocOperation[Ef^.Dat.OperatorSelector+1]=1 Then
Begin
{If (Izmen=0) Or ((Izmen=1)And(Ef^.Dat.TimeC<>Ef^.Dat.TimeM)) Then}
Begin
RFormatZerro(Ef^.Dat.Document,CDocnumer);
Format(Ef^.Dat.DateC,CDate);
DelSpace(Ef^.Dat.Kol);
RFormat(Ef^.Dat.Kol,CKol);
Str(StrToInt(Ef^.Dat.Kol)+StrToInt(AllKol):CKol+2,AllKol);

Str(StrToReal(Ef^.Dat.SummaZ)+StrToReal(AllSR):CIZena:CMantissa,AllSR);
Str(StrToReal(Ef^.Dat.SummaZakupka)+StrToReal(AllSZ):CIZena:CMantissa,AllSZ);

ws:=GetClientField(FClient,Ef^.Dat.ClientKod,Ef^.Dat.OperatorSelector);
Format(ws,CMAke);
Str(StrToReal(Ef^.Dat.SummaZ)/StrToInt(Ef^.Dat.Kol):CZena:CMAntissa,ws1);
Str(StrToReal(Ef^.Dat.SummaZakupka)/StrToInt(Ef^.Dat.Kol):CZena:CMAntissa,ws2);
ws:=ws+'│'+Ef^.Dat.ClientKod+'│'+Ef^.Dat.Document+'│'+Ef^.Dat.DateC+'│'+Ef^.Dat.Kol+
'│'+ws2+'│'+ws1+'│'+IntToStr(Ef^.Dat.DocSelector,COne)+'│';
ws1:=GetOperatorName(Ef^.Dat.Caption);
Format(ws1,CKto);

{Ef^.Dat.Comment:='123456789012345678901234567890123456789012345';}

Format(Ef^.Dat.Bn.Bank,CAll);
Format(Ef^.Dat.Bn.Date,CDate);
Format(Ef^.Dat.Bn.NPlat,10);
Format(Ef^.Dat.Bn.Summa,CIZena);
Comment[0]:=#0;
Format(Comment,CAll);

ws:=ws+ws1+'│'+IntToStr(Ef^.Dat.SkidkaSelector,COne)+'│'+IntToStr(Ef^.Dat.Rashet,COne)+'│'+
               Ef^.Dat.AgentKod+'│'+Ef^.Dat.Bn.Bank+'│'+Ef^.Dat.Bn.Date+'│'+
               Ef^.Dat.Bn.NPlat+'│'+Ef^.Dat.Bn.Summa+'│'+Comment+'│'+Ef^.Dat.TimeC;
NoScr^.List^.Insert(NewStr(ws));
NoScr^.SetRange(NoScr^.List^.Count);
End;{Izmen}
End;
End;
End;
NoScr^.FocusItem(0);
NoScr^.HelpCtx:=$F082;

Dispose(Ef,Done);
System.Close(f);

DelSpace(AllKol);
DelSpace(AllSR);
DelSpace(AllSZ);

Dispose(ControlIKol,Done);
R.Assign(9, 22, 16, 23);
ControlIKol := New(PColoredText, Init(R, #3+AllKol, $4E));
VMrk^.Insert(ControlIKol);

Dispose(ControlIRZ,Done);
R.Assign(64, 22, 79, 23);
ControlIRZ := New(PColoredText, Init(R, #3+AllSR, $4E));
VMrk^.Insert(ControlIRZ);

Dispose(ControlIZZ,Done);
R.Assign(32, 22, 47, 23);
ControlIZZ := New(PColoredText, Init(R, #3+AllSZ, $4E));
VMrk^.Insert(ControlIZZ);

Sorting(LocSort);
NoInfoMsg;
Redraw;
End;

procedure TViewMarketWindow.Sorting(LocSort : Word);
Var j: Word;
    ws,ws1,ws2 : String;
    R : TRect;
    TempBox : PBox;
Begin
DInfoMsg('Сортирую выборку...');
R.Assign(0,0,0,0);
TempBox := New(PBox, Init(R, 1, Nil));
TempBox^.NewList(New(PTextCollection, Init(0,1)));

PrhList^.NewList(Nil);
PrhList^.NewList(New(PMyCollection, Init(0,1)));

If NoScr^.List^.Count>0 Then
Begin
{формируем отсортированый список}
For j:=0 to NoScr^.List^.Count-1 Do
Begin
 ws:=NoScr^.GEtText(j,NoScr^.List^.Count);
Case LocSort Of
{поставщик}
0:ws:=ws;
{Раздел}
1:Begin
   ws1:=Copy(ws,1+CClient+1+CMakeKod+1+CDocNumer+1+CDAte+1,CKol);
   ws:=ws1+ws;
  End;
{Дата поступления}
2:Begin
   ws1:=Copy(ws,1+CClient+1+CMakeKod+1+CDocNumer+1,CDate);
   ws2:=Copy(ws,Ord(ws[0])-CDate+1,CDate);{время}
   ws1:=IntToSTr(DateStringToDate(DateMask,ws1),CDate);
   Format(ws1,CDate);
   ws:=ws1+' '+ws2+ws;
  End;
Else;
End;{CAse}
  TempBox^.List^.Insert(NewStr(ws));
  TempBox^.SetRange(TempBox^.List^.Count);
End;{for}


{форматируем сформированый список под экранную форму}
If TempBox^.List^.Count>0 Then
Begin
For j:=0 to TempBox^.List^.Count-1 Do
Begin
  ws:=TempBox^.GEtText(j,TempBox^.List^.Count);
Case LocSort Of
{поставщик}
0:ws:=ws;
{количество}
1:Begin
   System.Delete(ws,1,CKol);
  End;
{дата поступления}
2:Begin
   System.Delete(ws,1,CDAte+1+CDAte);
  End;
Else;
End;{CAse}
  PrhList^.List^.Insert(NewStr(ws));
  PrhList^.SetRange(PrhList^.List^.Count);
End;
End;
End;{if}

{0:поставщик
 1:количество
 2:дата поступления}

PrhList^.FocusItem(0);
PrhList^.HelpCtx:=$F082;

Dispose(TempBox,Done);
NoInfoMsg;
PrevLine[0]:=#0;
End;

Procedure TViewMarketWindow.FullPrevView;
Var Ass : DocumentEdit;
    E : PSuperMarketType;
    R : TRect;
    f : MarketFileType;
    c : Word;
    P : PBox;
    ws : TMyString;
    Find : Boolean;
    SKolish,SDoc,SClientKod,SAgentKod : ArtikulStr;
    s,SCommentr : String;
    SDate : TDateString;
    ws1,WspomSkidka:String[CIZena];
    v : Byte;

Begin
If (PrhList^.List<>Nil)And(PrhList^.List^.Count>=1) Then
Begin
  Ass.EditPosition:=Copy(PrhList^.GetText(PrhList^.Focused,PrhList^.List^.Count),1+CClient+1+CClientKod+1,CDocNumer);
  DelSpace(Ass.EditPosition);
  DelZerro(Ass.EditPosition);
  Ass.D:=Copy(PrhList^.GetText(PrhList^.Focused,PrhList^.List^.Count),1+CClient+1+CClientKod+1+CDocNumer+1,CDate);
  DelSpace(Ass.D);
  ViewMrk^.FullScreenMrk(Ass);
End
End;

procedure TViewMarketWindow.FormReport(E:PBox);
Const SPace = '   ';
Var txt : Text;
    i,c : Word;
    ws,s1,s,ws1 : String;
Begin

 WordToBit3(LocOperation,SLocOperation);
 Convert3(SLocOperation);

 Assign(txt,Path.ToTemp+'stmrk.txt');
 i:=IOResult;
 Rewrite(txt);
 i:=IOResult;
 If i<>0 Then
  Begin
   MessageBox(^M+#3'Ошибка создания '+Path.ToTemp+'stmrk.txt'+
   ^M+#3+ClicProgrammer,Nil,mfError+mfCancelButton);
   Exit;
  End;
 DInfoMsg('Формирую отчет. Ждите...');

 Writeln(Txt,Space+'Склад: ',GetClientField(FClient,Rek.Kod,1)+'  Оператор: '+CurrentPassword+' EYE & 1997-98');

 Writeln(txt,Space+'Включены в рассмотрение следующие виды операций:');
 Write(txt,Space);
 For c:=1 To Max3 Do
  Begin
   If SLocOperation[c]=1 Then
    Case c Of
    1:Write(txt,' "Клиент" ');
    2:Write(txt,' "Склад" ');
    3:Write(txt,' "Обмен" ');
    Else;
    End;
  End;
 Writeln(txt);
 Writeln(txt,Space+'Включены в рассмотрение следующие виды документов:');
 Write(txt,Space);
 For c:=1 To Max9 Do
  Begin
   If SVidDocTov[c]=1 Then
    Case c Of
    1:Write(txt,' "Список"');
    2:Write(txt,' "Тов.Чек*"');
    3:Write(txt,' "Физ.Л*"');
    4:Write(txt,' "СФ*"');
    5:Write(txt,' "СФ "');
    6:Write(txt,' "Дебит*"');
    7:Write(txt,' "Дебит СФ*"');
    8:Write(txt,' "Дебит"');
    9:Write(txt,' "Дебит СФ"');
    Else;
    End;
  End;
 Writeln(txt);

 Write(txt,Space+'Вид сортировки:');
    Case LocSort Of
    0:WriteLn(txt,' "Клиент" ');
    1:WriteLn(txt,' "Количество" ');
    2:WriteLn(txt,' "Дата" ');
    Else;
    End;

 Write(txt,Space+'Выбранные агенты:');
 If Agent^.LiSt^.Count>0 Then
  Begin
   For c:=0 To Agent^.List^.Count-1 Do
    Begin
     s:=Agent^.GetText(c,Agent^.List^.Count);
     While Pos('│',s)>0 Do s[Pos('│',s)]:=' ';
     System.Delete(s,1,1);
     ws1:=Copy(s,1+1,CClientKod);
     ws1:=GetAgentField(FClient,ws1);
     Writeln(txt,' '+ws1);
    End;
  End;



 {
 If Izmen=1 Then
 Begin
 Writeln(txt,Space+'Внимание! В справку включены только изменявшиеся документы!');
 Writeln(txt);
 End;
 }
 Writeln(txt,Space+Bold[NPrint.Printer]+'     СПРАВКА ПО ОТГРУЗКАМ ТОВАРА ЗА ПЕРИОД С '+StartDateToV+' ПО '+StopDateToV+
 NoBold[NPrint.Printer]);
 Writeln(txt,Space+'Выбранная позиция товара:');

ws:=GetIdField(FName,SKodToV);
Format(ws,CNAme);
ws:=ws+' Код:'+SKodToV+' Фас:';
s1:=GetIdField(FInPack,SKodToV);
ws:=ws+s1+' Литраж:';
s1:=GetIdField(FLitr,SKodToV);
ws:=ws+s1+' Цена:';
s1:=BakGetField(FRZena,SKodToV,1);
ws:=ws+s1;
 Writeln(txt,Space+Italic[NPrint.Printer]+ws+NoItalic[NPrint.Printer]);

 Writeln(txt,Space+'--------------------------------------------------------------------------------------');
 Writeln(txt,Space+'     Клиент          Код  Док.   Дата   Колич. З/Цена   Р/Цена  Вид док.   Оператор');
                   {12345678901234567890│1234│1234│12-45-78│12345│12345678│12345678│ДЕБИТ СФБ│123456789012}
 Writeln(txt,Space+'--------------------------------------------------------------------------------------');
If E^.List^.Count>0 Then
Begin
 For c:=0 To E^.List^.Count-1 Do
 Begin
  ws:=E^.GetText(c,E^.List^.Count);
  While Pos('│',ws)>0 Do ws[Pos('│',ws)]:=' ';
  s1:=Copy(ws,1+CClient+1+CMakeKod+1+CDocNumer+1+CDate+1+CKol+1+CZena+1+CZena+1,COne);
    Case StrToInt(s1) Of
    0:s1:='Список   ';
    1:s1:='Тов.Чек* ';
    2:s1:='Физ.Л*   ';
    3:s1:='СФ*      ';
    4:s1:='СФ       ';
    5:s1:='Дебит*   ';
    6:s1:='Дебит СФ*';
    7:s1:='Дебит    ';
    8:s1:='Дебит СФ ';
    Else
      S1:='  ???    ';
    End;
  System.Delete(ws,1+CClient+1+CMakeKod+1+CDocNumer+1+CDate+1+CKol+1+CZena+1+CZena+1,COne);
  System.Insert(s1,ws,1+CClient+1+CMakeKod+1+CDocNumer+1+CDate+1+CKol+1+CZena+1+CZena+1);

  ws[0]:=Chr(CClient+1+CMakeKod+1+CDocNumer+1+CDate+1+CKol+1+CZena+1+CZena+1+9+1+CKto);
 Writeln(txt,Space+ws);
 End;
End;
 Writeln(txt,Space+'--------------------------------------------------------------------------------------');

PStaticText(ControlIKol)^.GetText(ws);
System.Delete(ws,1,1);
DelSpace(ws);
RFormat(ws,CIZena);

 Writeln(txt,Space+'                                             Всего отгрузка: '+ws);

PStaticText(ControlIZZ)^.GetText(ws);
System.Delete(ws,1,1);
DelSpace(ws);

 Writeln(txt,Space+'                                           Всего по З/Ценам: '+
 Recogniz(RealToStr(StrToReal(ws),CIZena,CMAntissa)));

PStaticText(ControlIRZ)^.GetText(ws);
System.Delete(ws,1,1);
DelSpace(ws);

 Writeln(txt,Space+'                                           Всего по Р/Ценам: '+
 Recogniz(RealToStr(StrToReal(ws),CIZena,CMAntissa)));

 Writeln(txt);
 Writeln(txt,Space,'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
 Writeln(txt,Space+'======================================================================================');

 System.Close(txt);
 NoInfoMsg;
{
 If Izmen=1 Then
 MessageBox(^M+#3'В справку включены только изменявшиеся документы!',Nil,mfWarning+mfCancelButton);;
}
 Report(Path.ToTemp+'stmrk.txt','',1,False,False,false);
End;

procedure TViewMarketWindow.HandleEvent(var Event: TEvent);

procedure Calculator;
begin
  Calc^.Start;
end;

Var Test : Word;
    sClientKod:ArtikulStr;
    s,s1 : String;
    SDoc,SDate : TDateString;

Begin
  Case Event.What Of
  evKeyDown :
  Case Event.KeyCode Of
     kbEsc: Begin
              ClearFind;
              Event.What:=evCommand;
              Event.Command:=cmCancel;
              PutEvent(Event);
              ClearEvent(Event);
            End;
      Else;
      End;{KeyDown}
  evCommand :
     Case Event.Command Of
       cmLocalCalc:Begin
                     ClearFind;
                     Calculator;
                   End;
  cmFullView:Begin
              ClearFind;
              If (PrhList^.State and sfFocused <> 0) And (PrhList^.List<>Nil)And(PrhList^.List^.Count>=1) Then
               Begin
                FullPrevView;
               End
            End;

  cmPrintReestr:    Begin
                 ClearFind;
     If (PrhList^.State and sfFocused <> 0) And (PrhList^.List<>Nil)And(PrhList^.List^.Count>=1) Then
            Begin
                Assistent.EditPosition:=Copy(PrhList^.GetText(PrhList^.Focused,PrhList^.List^.Count),1+CClient+1+CMakeKod+1,
			 CDocNumer);
                DelSpace(Assistent.EditPosition);
                DelZerro(Assistent.EditPosition);
                Assistent.D:=Copy(PrhList^.GetText(PrhList^.Focused,PrhList^.List^.Count),1+CClient+1+CMakeKod+1+CDocNumer+1,
			 CDate);
                DelSpace(Assistent.D);
                {PrintNaklSklad(Assistent,NPrint.CopyNkl);}
                PrintNakl(Assistent,NPrint.CopyNkl);
            End
            End;

        cmLocalInfo: Begin
        If (PrhList^.List<>Nil)And(PrhList^.List^.Count>=1) Then
            Begin
                 ClearFind;
                 s1:=Copy(PrevLine,1+CClient+1+CClientKod+1+CDocNumer+1+CDate+1+CKol+1+CZena+1+CZena+1,COne);
                 s:=PrevLine;
                 SClientKod:=Copy(PrevLine,1+CClient+1,CClientKod);
                 {Вид документа}
                 If StrToInt(s1) in [5,6,7,8] Then
                 Begin
                 System.Delete(s,1,CClient+1+CClientKod);
                 PrevLine[0]:=#0;
                 LockInfo^.LockStart(s,SClientKod);
                 End
                 Else
                  MessageBox(^M+#3+'Вы пытаетесь просмотреть историю оплаты по документу НЕ КОНСИГНАЦИИ!!!',Nil,
                  mfError+mfCancelButton);
            End;
                 ClearEvent(Event);
                          End;

 cmReestrReport:    Begin
                 ClearFind;
     If (PrhList^.List<>Nil)And(PrhList^.List^.Count>=1) Then
            Begin
             FormReport(PrhList);
            End
            End;
      Else;
      End;{evCommand}
      Else;
      End;{*Case*}
  if (Event.What = evBroadcast) and
    (Event.Command = cmMrkC) then ClearEvent(Event);

  if (Event.What = evBroadcast) and
    (Event.Command = cmQuit) then ClearEvent(Event);

inherited HandleEvent(Event);

  If (Desktop^.Current=PView(VMrk)) And (Event.What <> EvKeyDown) Then
   Begin

   DrawCurrent;
  if (ControlLocSort^.State and sfFocused <> 0)Then
                    Begin
                        ControlLocSort^.GetData(Test);
                        If Test <> LocSort Then
                        Begin
                           ClearFind;
                           LocSort:=Test;
                           Sorting(LocSort);
                           Redraw;
                        End;
                    End;

  if (ControlLocFiltr^.State and sfFocused <> 0)Then
                    Begin
                        ControlLocFiltr^.GetData(Test);
                        If Test <> LocOperation Then
                        Begin
                           ClearFind;
                           LocOperation:=Test;
									Refresh(LocSort);
                           Redraw;
                        End;
                    End;
{
  If StrToInt(CurrentPassword)=0 Then
  BEgin
  if (ControlEditFiltr^.State and sfFocused <> 0)Then
                    Begin
                        ControlEditFiltr^.GetData(Test);
                        If Test <> Izmen Then
                        Begin
                           ClearFind;
                           Izmen:=Test;
									Refresh(LocSort);
                           Redraw;
                        End;
                    End;
  End;
}
    End;

End;

Destructor TViewMarketWindow.Done;
Begin
TDialog.Done;
End;

procedure TViewReturnWindow.Start(SVidOperation:Word);
Var R : TRect;
    Control : PView;
    c : Word;
    s,s1 : String;
Begin
DInfoMsg('Минуточку...');
R.Assign(0, 0, 80, 23);
New(VRet, Init(R, 'Возвраты на склад за период с '+StartDateToV+' по '+StopDateToV));
VRet^.HelpCtx:=$F077;
R.Assign(79, 4, 80, 21);
Control := New(PScrollBar, Init(R));
VRet^.Insert(Control);

R.Assign(1, 4, 79, 21);
PrhList := New(PBox, Init(R, 1, PScrollBar(Control)));
PrhList^.NewList(New(PTextCollection, Init(0,1)));

PrhList^.FocusItem(0);
PrhList^.HelpCtx:=$F076;

VRet^.Insert(PrhList);

R.Assign(0, 0, 0, 0);
NoScr := New(PBox, Init(R, 1, PScrollBar(Control)));
NoScr^.NewList(New(PMyCollection, Init(0,1)));


  R.Assign(1, 3, 77, 4);
  VRet^.Insert(New(PLabel, Init(R, 'Клиент                Код  Док.  Дата   Колич  Р/Цена  Оператор      Время', PrhList)));

R.Assign(1, 2, 79, 3);
s:=GetIdField(FName,SKodToV);
Format(s,CNAme);
s:=s+' Код:'+SKodToV+' Фас:';
s1:=GetIdField(FInPack,SKodToV);
s:=s+s1+' Литраж:';
s1:=GetIdField(FLitr,SKodToV);
s:=s+s1+' Цена:';
s1:=BakGetField(FRZena,SKodToV,1);
s:=s+s1;
Control := New(PColoredText, Init(R, #3+s, $71));
VRet^.Insert(Control);

R.Assign(2, 22, 9, 23);
Control := New(PColoredText, Init(R, ' Всего:', $74));
VRet^.Insert(Control);

R.Assign(9, 22, 16, 23);
ControlIKol := New(PColoredText, Init(R, #3+'0', $4E));
VRet^.Insert(ControlIKol);


R.Assign(50, 22, 64, 23);
Control := New(PColoredText, Init(R, ' Итого по Р/Ц:', $74));
VRet^.Insert(Control);

R.Assign(64, 22, 79, 23);
ControlIRZ := New(PColoredText, Init(R, #3+'0.00', $4E));
VRet^.Insert(ControlIRZ);

R.Assign(1, 1, 24, 2);
ControlLocFiltr := New(PCheckboxes, Init(R,
  NewSItem('Кл~и~ент',
  NewSItem('~С~клад',Nil))));
VRet^.Insert(ControlLocFiltr);
LocOperation:=OperationToV;

WordToBit3(LocOperation,SLocOperation);

Invert3(SLocOperation);
BitToWord3(SLocOperation,c);
PCluster(ControlLocFiltr)^.SetButtonState(c, False);

Invert3(SLocOperation);{возвращаем в нормальное состояние}

BitToWord3(SLocOperation,LocOperation);

ControlLocFiltr^.SetData(LocOperation);


  R.Assign(1, 0, 11, 1);
  VRet^.Insert(New(PLabel, Init(R, 'Опера~ц~ии:', ControlLocFiltr)));

R.Assign(42, 1, 79, 2);
ControlLocSort := New(PRadioButtons, Init(R,
  NewSItem('Кли~е~нт',
  NewSItem('Ко~л~-во',
  NewSItem('Д~а~та', Nil)))));
VRet^.Insert(ControlLocSort);

c:=2;
LocSort:=c;
ControlLocSort^.SetData(c);

  R.Assign(35, 1, 42, 2);
  VRet^.Insert(New(PLabel, Init(R, 'Со~р~т.:', ControlLocSort)));


R.Assign(1, 21, 37, 22);
Control := New(PColoredText, Init(R, 'Документ-основание:      от', $74));
Vret^.Insert(Control);

R.Assign(48, 21, 61, 22);
Control := New(PColoredText, Init(R, 'Вид возврата:', $74));
Vret^.Insert(Control);

R.Assign(61, 21, 79, 22);
ControlDatePP := New(PColoredText, Init(R, #3+'???', $7E));
Vret^.Insert(ControlDatePP);

R.Assign(21, 21, 25, 22);
ControlNPP := New(PColoredText, Init(R, #3+'???', $7E));
Vret^.Insert(ControlNPP);


R.Assign(29, 21, 37, 22);
ControlSummaPP := New(PColoredText, Init(R, #3+'???', $7E));
VRet^.Insert(ControlSummaPP);

R.Assign(38, 21, 47, 22);
ControlBank := New(PColoredText, Init(R, #3+'???', $7E));
VRet^.Insert(ControlBank);


VRet^.SelectNext(False);

{вставить текст формирования списка позиций}
VRet^.Refresh(c);
NoInfoMsg;
c:=Desktop^.ExecView(VRet);
Dispose(Control,Done);
Dispose(VRet,Done);
Dispose(NoScr,Done);
End;

procedure TViewReturnWindow.DrawCurrent;
Var St,ts : String;
    R : TRect;
Begin

If (PrhList^.List<>Nil)And(PrhList^.List^.Count>0)  Then
 Begin
  st:=PrhList^.GetText(PrhList^.Focused,PrhList^.List^.Count);
  If St <> PrevLine Then
   Begin
    PrevLine:=St;

    ts:=Copy(st,1+CClient+1+CMakeKod+1+CdocNumer+1+CDate+1+CKOl+1+CZena+1+CKto+1+CDate+1,COne);


Case StrToInt(ts) Of
0:ts:='нал.продажа(авто)';
1:ts:='нал.продажа(ручн)';
2:ts:='закр.консиг(авто)';
3:ts:='закр.консиг(ручн)';
4:ts:='откр.консиг(авто)';
5:ts:='откр.консиг(ручн)';
Else;
End;

Dispose(ControlDatePP,Done);
R.Assign(61, 21, 79, 22);
ControlDatePP := New(PColoredText, Init(R, #3+ts, $7E));
Vret^.Insert(ControlDatePP);

    ts:=Copy(st,1+CClient+1+CMakeKod+1+CdocNumer+1+CDate+1+CKOl+1+CZena+1+CKto+1+CDate+1+COne+1,CDocNumer);

Dispose(ControlNPP,Done);
R.Assign(21, 21, 25, 22);
ControlNPP := New(PColoredText, Init(R, #3+ts, $7E));
Vret^.Insert(ControlNPP);

    ts:=Copy(st,1+CClient+1+CMakeKod+1+CdocNumer+1+CDate+1+CKOl+1+CZena+1+CKto+1+CDate+1+COne+1+CDocNumer+1,CDate);

Dispose(ControlSummaPP,Done);
R.Assign(29, 21, 37, 22);
ControlSummaPP := New(PColoredText, Init(R, #3+ts, $7E));
VRet^.Insert(ControlSummaPP);

    ts:=Copy(st,1+CClient+1+CMakeKod+1+CdocNumer+1+CDate+1+CKOl+1+CZena+1+CKto+1+CDate+1+COne+1+CDocNumer+1+CDate+1,COne);

    Case StrToInt(ts) Of
    0:ts:='Список';
    1:ts:='Тов.Чек*';
    2:ts:='Физ.Л*';
    3:ts:='СФ*';
    4:ts:='СФ ';
    5:ts:='Дебит*';
    6:ts:='Дебит СФ*';
    7:ts:='Дебит';
    8:ts:='Дебит СФ';
    Else
      ts:='???';
    End;

Dispose(ControlBank,Done);
R.Assign(38, 21, 47, 22);
ControlBank := New(PColoredText, Init(R, #3+ts, $7E));
VRet^.Insert(ControlBank);



Redraw;
   End;
 End
 Else
  Begin
   PStaticText(ControlNPP)^.GetText(st);
  If (st)<>(#3+'???') Then
  Begin

Dispose(ControlDatePP,Done);
R.Assign(61, 21, 79, 22);
ControlDatePP := New(PColoredText, Init(R, #3+'???', $7E));
Vret^.Insert(ControlDatePP);

Dispose(ControlNPP,Done);
R.Assign(21, 21, 25, 22);
ControlNPP := New(PColoredText, Init(R, #3+'???', $7E));
Vret^.Insert(ControlNPP);

Dispose(ControlSummaPP,Done);
R.Assign(29, 21, 37, 22);
ControlSummaPP := New(PColoredText, Init(R, #3+'???', $7E));
VRet^.Insert(ControlSummaPP);

Dispose(ControlBank,Done);
R.Assign(38, 21, 47, 22);
ControlBank := New(PColoredText, Init(R, #3+'???', $7E));
VRet^.Insert(ControlBank);

  st:='';
  PrevLine:=St;
  Redraw;
  End;
  End;


End;

procedure TViewReturnWindow.Refresh(LocSort:Word);
Var i,j : Word;
    ws,ws1,ws2 : String;
    TempBox : PBox;
    R : TRect;
    f : File of StatTovarReturnType;
    ef : PStatTovarReturnType;
    AllKol,AllSR:AllStr;

Begin
WordToBit3(LocOperation,SLocOperation);
Convert3(SLocOperation);

DInfoMsg('Минуточку...');


Assign(f,Path.ToAnalys+SKodToV+'.vzw');
i:=IOResult;
Reset(f);
If i<>0 Then
 Begin
  NoInfoMsg;
  MessageBox(#3'Ошибка открытия файла '+Path.ToAnalys+SKodToV+'.vzw!'^M+
  #3+ClicProgrammer,Nil,mfError+mfCancelButton);
  Exit;
 End;

NoScr^.NewList(Nil);
NoScr^.NewList(New(PMyCollection, Init(0,1)));


New(Ef,Init);
AllSR:='0.00';
AllKol:='0';

While Not(eof(f)) Do
Begin
Read(f,ef^.Dat);
ws[0]:=#0;
If StrToInt(Ef^.Dat.SkladKod)=StrToInt(Rek.Kod) Then
Begin
If SLocOperation[Ef^.Dat.OperatorSelector+1]=1 Then
Begin
RFormatZerro(Ef^.Dat.Document,CDocnumer);
Format(Ef^.Dat.DateC,CDate);

DelSpace(Ef^.Dat.BasisDoc);
RFormatZerro(Ef^.Dat.BasisDoc,CDocnumer);

Format(Ef^.Dat.DateC,CDate);
Format(Ef^.Dat.BasisDate,CDate);
DelSpace(Ef^.Dat.Kol);
RFormat(Ef^.Dat.Kol,CKol);
Str(StrToInt(Ef^.Dat.Kol)+StrToInt(AllKol):CKol+2,AllKol);
Str(StrToReal(Ef^.Dat.Summa)+StrToReal(AllSR):CIZena:CMantissa,AllSR);

ws:=GetClientField(FClient,Ef^.Dat.MakeKod,Ef^.Dat.OperatorSelector);
Format(ws,CMAke);
Str(StrToReal(Ef^.Dat.Summa)/StrToInt(Ef^.Dat.Kol):CZena:CMAntissa,ws1);
ws:=ws+'│'+Ef^.Dat.MakeKod+'│'+Ef^.Dat.Document+'│'+Ef^.Dat.DateC+'│'+Ef^.Dat.Kol+
'│'+ws1+'│';
ws1:=GetOperatorName(Ef^.Dat.Caption);
Format(ws1,CKto);
ws:=ws+ws1+'│'+Ef^.Dat.TimeC+'│'+IntToStr(Ef^.Dat.VidDocument,COne)+'│'+
+Ef^.Dat.BasisDoc+'│'+Ef^.Dat.BasisDate+'│'+IntToStr(Ef^.Dat.DocSelector,COne);
(*
Case Ef^.Dat.VidDocument Of
0:ws1:='нал.продажа(авто)';
       {12345678901234567}
1:ws1:='нал.продажа(ручн)';
2:ws1:='закр.консиг(авто)';
3:ws1:='закр.консиг(ручн)';
4:ws1:='откр.консиг(авто)';
5:ws1:='откр.консиг(ручн)';
Else;
End;
ws:=ws+'│'+ws1;
*)
NoScr^.List^.Insert(NewStr(ws));
NoScr^.SetRange(NoScr^.List^.Count);
End;
End;
End;
NoScr^.FocusItem(0);
NoScr^.HelpCtx:=$F076;

Dispose(Ef,Done);
System.Close(f);

DelSpace(AllKol);
DelSpace(AllSR);

Dispose(ControlIKol,Done);
R.Assign(9, 22, 16, 23);
ControlIKol := New(PColoredText, Init(R, #3+AllKol, $4E));
VRet^.Insert(ControlIKol);

Dispose(ControlIRZ,Done);
R.Assign(64, 22, 79, 23);
ControlIRZ := New(PColoredText, Init(R, #3+AllSR, $4E));
VRet^.Insert(ControlIRZ);

Sorting(LocSort);
NoInfoMsg;
Redraw;
End;

procedure TViewReturnWindow.Sorting(LocSort : Word);
Var j: Word;
    ws,ws1,ws2 : String;
    R : TRect;
    TempBox : PBox;
Begin
DInfoMsg('Сортирую выборку...');
R.Assign(0,0,0,0);
TempBox := New(PBox, Init(R, 1, Nil));
TempBox^.NewList(New(PTextCollection, Init(0,1)));

PrhList^.NewList(Nil);
PrhList^.NewList(New(PMyCollection, Init(0,1)));

If NoScr^.List^.Count>0 Then
Begin
{формируем отсортированый список}
For j:=0 to NoScr^.List^.Count-1 Do
Begin
 ws:=NoScr^.GEtText(j,NoScr^.List^.Count);
Case LocSort Of
{поставщик}
0:ws:=ws;
{Раздел}
1:Begin
   ws1:=Copy(ws,1+CClient+1+CMakeKod+1+CDocNumer+1+CDAte+1,CKol);
   ws:=ws1+ws;
  End;
{Дата поступления}
2:Begin
   ws1:=Copy(ws,1+CClient+1+CMakeKod+1+CDocNumer+1,CDate);

   ws2:=Copy(ws,1+CClient+1+CMakeKod+1+CDocNumer+1+CDate+1+CKol+1+CZena+1+CKto+1,CDAte);{время}
   ws1:=IntToSTr(DateStringToDate(DateMask,ws1),CDate);
   Format(ws1,CDate);
(* ws2:=Copy(ws,1+CClient+1+CMakeKod+1+CDocNumer+1+CDAte+1+CKol+1+CZena+1+CZena+
   1+CKto+1,CDate);{время}
   ws1:=IntToStr(DateStringToDate(DateMask,ws1),CDAte);*)
   ws:=ws1+' '+ws2+ws;
  End;
Else;
End;{CAse}
  TempBox^.List^.Insert(NewStr(ws));
  TempBox^.SetRange(TempBox^.List^.Count);
End;{for}


{форматируем сформированый список под экранную форму}
If TempBox^.List^.Count>0 Then
Begin
For j:=0 to TempBox^.List^.Count-1 Do
Begin
  ws:=TempBox^.GEtText(j,TempBox^.List^.Count);
Case LocSort Of
{поставщик}
0:ws:=ws;
{количество}
1:Begin
   System.Delete(ws,1,CKol);
  End;
{дата поступления}
2:Begin
   System.Delete(ws,1,CDAte+1+CDAte);
  End;
Else;
End;{CAse}
  PrhList^.List^.Insert(NewStr(ws));
  PrhList^.SetRange(PrhList^.List^.Count);
End;
End;
End;{if}

{0:поставщик
 1:количество
 2:дата поступления}

PrhList^.FocusItem(0);
PrhList^.HelpCtx:=$F076;

Dispose(TempBox,Done);
NoInfoMsg;
PrevLine[0]:=#0;


End;

Procedure TViewReturnWindow.FullPrevView;
Var Ass : DocumentEdit;
    E : PNewVozwratType;
    R : TRect;
    f : NewVozwratFileType;
    c : Word;
    P : PBox;
    s,ws : TMyString;
    Find : Boolean;
    SDoc : ArtikulStr;
    SDate : TDateString;
    ws1,WspomSkidka:String[CIZena];

Begin
If (PrhList^.List<>Nil)And(PrhList^.List^.Count>=1) Then
Begin
  Ass.EditPosition:=Copy(PrhList^.GetText(PrhList^.Focused,PrhList^.List^.Count),1+CClient+1+CMakeKod+1,
  CDocNumer);
  DelSpace(Ass.EditPosition);
  DelZerro(Ass.EditPosition);
  Ass.D:=Copy(PrhList^.GetText(PrhList^.Focused,PrhList^.List^.Count),1+CClient+1+CMakeKod+1+CDocNumer+1,
  CDate);
  DelSpace(Ass.D);
  Assign(f,Path.ToReturn+Ass.d+'.vzw');
  c:=IOResult;
  Reset(f);
  c:=IOResult;
  If c<>0 Then
  Begin
   MessageBox(#3^M+#3'Ошибка доступа к файлу '+Path.ToReturn+Ass.d+'.vzw',Nil,mfError+mfCancelButton);
   Exit;
  End;
  DInfoMsg('Ищу документ...');
  New(E,Init);
  Find := False;
  ClearChar(Ass.EditPosition);
  While Not(Eof(f)) And Not(Find) Do
   Begin
   ReadNewVozwrat(F,E);
   ClearChar(E^.Dat.Document);
    If (E^.Dat.DateC=Ass.D) and (E^.Dat.Document=Ass.EditPosition) Then
          Begin
           Find:=True;
           Break;
          End;
   End;
   System.Close(f);
   If Find Then
    Begin
     R.Assign(0,0,0,0);
P := New(PBox, Init(R, 1, Nil));
P^.NewList(New(PTextCollection, Init(1,1)));
For c:=1 To E^.Dat.Amount Do
 Begin
  S:=E^.Dat.VozwratElement[c].BazKod;
  ws:=GetIdField(FName,s);
  Format(ws,CName);
  s:=ws+'│'+s;
  ws:=GetIdField(FInPack,E^.Dat.VozwratElement[c].BazKod);
  RFormat(ws,CInPack);
  s:=s+'│'+ws;

  ws:=GetIdField(FLitr,E^.Dat.VozwratElement[c].BazKod);
  RFormat(ws,CInPack);
  s:=s+'│'+ws;

  DelSpace(E^.Dat.VozwratElement[c].Input.Kol);
  RFormat(E^.Dat.VozwratElement[c].Input.Kol,CKol);
  s:=s+'│'+E^.Dat.VozwratElement[c].Input.Kol;

  DelSpace(E^.Dat.VozwratElement[c].Input.R_Zena);
  RFormat(E^.Dat.VozwratElement[c].Input.R_Zena,CZena);
  s:=s+'│'+E^.Dat.VozwratElement[c].Input.R_Zena;

  ws:=CalcPack(E^.Dat.VozwratElement[c].BazKod,E^.Dat.VozwratElement[c].Input.Kol);
  DelSpace(ws);
  Format(ws,CPAck);
  s:=s+'│'+ws+'│';


  P^.List^.Insert(NewStr(s));
  P^.SetRange(P^.List^.Count);
 End;


P^.FocusItem(0);
s[0]:=#0;
ws:=E^.Dat.SummaR;
DelSpace(ws);
s:=s+' Всего возврат по Р/Ценам: '+ws;

 Begin
  Str(StrToReal(E^.Dat.RashodSumma):CIZena:CMAntissa,ws);
  DelSpace(ws);
  s:=s+' К выдаче клиенту: '+ws;
 End;

SDoc:=E^.Dat.Document;
SDate:=E^.Dat.DateC;

Dispose(E,Done);

NoInfomsg;
                   {Вставить номер и дату документа в просмотре}
FullScreen(P,'Наименование товара         Код  Фас Литр  Колич  Р/Цена  Упаковок',s,
             {12345678901234567890123456│12345│123│12345│12345│12345678│123456789}
SDoc,SDAte,0);
Dispose(P,Done);
    End
Else
  Begin
  NoInfomsg;
  MessageBox(#3^M+#3'Документ не найден!',Nil,mfError+mfCancelButton);
  Dispose(E,Done);
  End;
End;
End;

procedure TViewReturnWindow.FormReport(E:PBox);
Const SPace = '        ';
Var txt : Text;
    i,c : Word;
    ws,s1 : String;
Begin
 WordToBit3(LocOperation,SLocOperation);
 Convert3(SLocOperation);

 Assign(txt,Path.ToTemp+'stvzw.txt');
 i:=IOResult;
 Rewrite(txt);
 i:=IOResult;
 If i<>0 Then
  Begin
   MessageBox(^M+#3'Ошибка создания '+Path.ToTemp+'stvzw.txt'+
   ^M+#3+ClicProgrammer,Nil,mfError+mfCancelButton);
   Exit;
  End;
 DInfoMsg('Формирую отчет. Ждите...');

 Writeln(Txt,Space+'Склад: ',GetClientField(FClient,Rek.Kod,1)+'  Оператор: '+CurrentPassword+' EYE & 1997-98');

 Writeln(txt,Space+'Включены в рассмотрение следующие виды операций:');
 Write(txt,Space);
 For c:=1 To Max2 Do
  Begin
   If SLocOperation[c]=1 Then
    Case c Of
    1:Write(txt,' "Клиент" ');
    2:Write(txt,' "Склад" ');
    Else;
    End;
  End;
 Writeln(txt);
 Write(txt,Space+'Вид сортировки:');
    Case LocSort Of
    0:WriteLn(txt,' "Клиент" ');
    1:WriteLn(txt,' "Количество" ');
    2:WriteLn(txt,' "Дата" ');
    Else;
    End;
 Writeln(txt,Space+Bold[NPrint.Printer]+'     СПРАВКА ПО ВОЗВРАТАМ ТОВАРА ЗА ПЕРИОД С '+StartDateToV+' ПО '+StopDateToV+
 NoBold[NPrint.Printer]);
 Writeln(txt,Space+'Выбранная позиция товара:');

ws:=GetIdField(FName,SKodToV);
Format(ws,CNAme);
ws:=ws+' Код:'+SKodToV+' Фас:';
s1:=GetIdField(FInPack,SKodToV);
ws:=ws+s1+' Литраж:';
s1:=GetIdField(FLitr,SKodToV);
ws:=ws+s1+' Цена:';
s1:=BakGetField(FRZena,SKodToV,1);
ws:=ws+s1;
 Writeln(txt,Space+Italic[NPrint.Printer]+ws+NoItalic[NPrint.Printer]);

 Writeln(txt,Space+'---------------------------------------------------------------------------------');
 Writeln(txt,Space+'       Клиент        Код  Док.   Дата   Колич. Р/Цена   Оператор   Д.осн Дата осн');
                   {12345678901234567890│1234│1234│12-45-78│12345│12345678│123456789012│1234│12345678}
 Writeln(txt,Space+'---------------------------------------------------------------------------------');
If E^.List^.Count>0 Then
Begin
 For c:=0 To E^.List^.Count-1 Do
 Begin
  ws:=E^.GetText(c,E^.List^.Count);
  System.Delete(ws,1+CClient+1+CClientKod+1+CDocNumer+1+CDate+1+CKOl+1+CZena+1+CKto+1,CDAte+1+COne+1);
  While Pos('│',ws)>0 Do ws[Pos('│',ws)]:=' ';
  s1:=Copy(ws,1+CClient+1+CClientKod+1+CDocNumer+1+CDate+1+CKOl+1+CZena+1+CKto+1+CDocNumer+1+CDate+1,COne);
  Case StrToInt(s1) Of
  3,4,6,8 : S1:='СФ'
  Else s1[0]:=#0;
  End;
  ws[0]:=Chr(CClient+1+CMakeKod+1+CDocNumer+1+CDate+1+CKol+1+CZena+1+CKto+1+CDocNumer+1+CDate);
  Writeln(txt,Space+ws+' '+s1);
 End;
End;
 Writeln(txt,Space+'---------------------------------------------------------------------------------');


PStaticText(ControlIKol)^.GetText(ws);
System.Delete(ws,1,1);
DelSpace(ws);
RFormat(ws,CIZena);

 Writeln(txt,Space+'                                            Всего возврат: '+ws);

PStaticText(ControlIRZ)^.GetText(ws);
System.Delete(ws,1,1);
DelSpace(ws);

 Writeln(txt,Space+'                                         Всего по Р/Ценам: '+
 Recogniz(RealToStr(StrToReal(ws),CIZena,CMAntissa)));

 Writeln(txt);
 Writeln(txt,Space,'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
 Writeln(txt,Space+'=================================================================================');

 System.Close(txt);
 NoInfoMsg;
 Report(Path.ToTemp+'stvzw.txt','',1,False,False,false);
End;

procedure TViewReturnWindow.HandleEvent(var Event: TEvent);

procedure Calculator;
begin
  Calc^.Start;
end;

Var Test : Word;

Begin
  Case Event.What Of
  evKeyDown :
  Case Event.KeyCode Of
     kbEsc: Begin
              ClearFind;
              Event.What:=evCommand;
              Event.Command:=cmCancel;
              PutEvent(Event);
              ClearEvent(Event);
            End;
      Else;
      End;{KeyDown}
  evCommand :
     Case Event.Command Of
       cmLocalCalc:Begin
                     ClearFind;
                     Calculator;
                   End;
  cmFullView:Begin
              ClearFind;
              If (PrhList^.State and sfFocused <> 0) And (PrhList^.List<>Nil)And(PrhList^.List^.Count>=1) Then
               Begin
                FullPrevView;
               End
            End;

{$IFDEF DPMI}
  cmPrintReestr:    Begin
                 ClearFind;
     If (PrhList^.State and sfFocused <> 0) And (PrhList^.List<>Nil)And(PrhList^.List^.Count>=1) Then
            Begin
                Assistent.EditPosition:=Copy(PrhList^.GetText(PrhList^.Focused,PrhList^.List^.Count),1+CClient+1+CMakeKod+1,
			 CDocNumer);
                DelSpace(Assistent.EditPosition);
                DelZerro(Assistent.EditPosition);
                Assistent.D:=Copy(PrhList^.GetText(PrhList^.Focused,PrhList^.List^.Count),1+CClient+1+CMakeKod+1+CDocNumer+1,
			 CDate);
                DelSpace(Assistent.D);
                If MessageBox(^M+#3'Печатать накладную возврата N '+Assistent.EditPosition+' от '+Assistent.D+'?',Nil,
			 mfConfirmation+mfOKCancel)=cmOk Then
                NewPrintVozwrat(Assistent);
            End
            End;
{$ENDif}
 cmReestrReport:    Begin
                 ClearFind;
     If (PrhList^.List<>Nil)And(PrhList^.List^.Count>=1) Then
            Begin
             FormReport(PrhList);
            End
            End;
      Else;
      End;{evCommand}
      Else;
      End;{*Case*}
  if (Event.What = evBroadcast) and
    (Event.Command = cmReturnC) then ClearEvent(Event);

  if (Event.What = evBroadcast) and
    (Event.Command = cmQuit) then ClearEvent(Event);

inherited HandleEvent(Event);
  If (Desktop^.Current=PView(VRet)) And (Event.What <> EvKeyDown) Then
   Begin

   DrawCurrent;

  if (ControlLocSort^.State and sfFocused <> 0)Then
                    Begin
                        ControlLocSort^.GetData(Test);
                        If Test <> LocSort Then
                        Begin
                           ClearFind;
                           LocSort:=Test;
                           Sorting(LocSort);
                           Redraw;
                        End;
                    End;

  if (ControlLocFiltr^.State and sfFocused <> 0)Then
                    Begin
                        ControlLocFiltr^.GetData(Test);
                        If Test <> LocOperation Then
                        Begin
                           ClearFind;
                           LocOperation:=Test;
									Refresh(LocSort);
                           Redraw;
                        End;
                    End;
   End;
End;

Destructor TViewReturnWindow.Done;
Begin
TDialog.Done;
End;


procedure TViewRPWindow.Start(SVidOperation:Word);
Var R : TRect;
    Control : PView;
    c : Word;
    s,s1 : String;
Begin
DInfoMsg('Минуточку...');
R.Assign(0, 0, 80, 23);
New(VRP, Init(R, 'Списания (РП) со склада за период с '+StartDateTov+' по '+StopDateTov));
VRP^.HelpCtx:=$F082;
R.Assign(79, 4, 80, 18);
Control := New(PScrollBar, Init(R));
VRP^.Insert(Control);

R.Assign(1, 4, 79, 18);
PrhList := New(PBox, Init(R, 1, PScrollBar(Control)));
PrhList^.NewList(New(PTextCollection, Init(0,1)));

PrhList^.FocusItem(0);
PrhList^.HelpCtx:=$F082;
VRP^.Insert(PrhList);

R.Assign(0, 0, 0, 0);
NoScr := New(PBox, Init(R, 1, PScrollBar(Control)));
NoScr^.NewList(New(PMyCollection, Init(0,1)));


  R.Assign(1, 3, 77, 4);
  VRP^.Insert(New(PLabel, Init(R, 'Клиент                Код  Док.  Дата   Колич  З/Цена   Р/Цена     Оператор', PrhList)));

R.Assign(1, 2, 79, 3);
s:=GetIdField(FName,SKodTov);
Format(s,CNAme);
s:=s+' Код:'+SKodTov+' Фас:';
s1:=GetIdField(FInPack,SKodTov);
s:=s+s1+' Литраж:';
s1:=GetIdField(FLitr,SKodTov);
s:=s+s1+' Цена:';
s1:=BakGetField(FRZena,SKodTov,1);
s:=s+s1;
Control := New(PColoredText, Init(R, #3+s, $71));
VRP^.Insert(Control);

R.Assign(2, 22, 9, 23);
Control := New(PColoredText, Init(R, ' Всего:', $74));
VRP^.Insert(Control);

R.Assign(9, 22, 16, 23);
ControlIKol := New(PColoredText, Init(R, #3+'0', $4E));
VRP^.Insert(ControlIKol);


R.Assign(50, 22, 64, 23);
Control := New(PColoredText, Init(R, ' Итого по Р/Ц:', $74));
VRP^.Insert(Control);

R.Assign(64, 22, 79, 23);
ControlIRZ := New(PColoredText, Init(R, #3+'0.00', $4E));
VRP^.Insert(ControlIRZ);

R.Assign(18, 22, 32, 23);
Control := New(PColoredText, Init(R, ' Итого по З/Ц:', $74));
VRP^.Insert(Control);

R.Assign(32, 22, 47, 23);
ControlIZZ := New(PColoredText, Init(R, #3+'0.00', $4E));
VRP^.Insert(ControlIZZ);

R.Assign(1, 1, 35, 2);
ControlLocFiltr := New(PCheckboxes, Init(R,
  NewSItem('Кл~и~ент',
  NewSItem('~С~клад',
  NewSItem('~О~бмен', Nil)))));
PCluster(ControlLocFiltr)^.SetButtonState($00000007, False);
VRP^.Insert(ControlLocFiltr);
LocOperation:=OperationTov;

WordToBit3(LocOperation,SLocOperation);

Invert3(SLocOperation);
BitToWord3(SLocOperation,c);
PCluster(ControlLocFiltr)^.SetButtonState(c, False);

Invert3(SLocOperation);{возвращаем в нормальное состояние}

BitToWord3(SLocOperation,LocOperation);

ControlLocFiltr^.SetData(LocOperation);

  R.Assign(1, 0, 11, 1);
  VRP^.Insert(New(PLabel, Init(R, 'Опера~ц~ии:', ControlLocFiltr)));

R.Assign(42, 1, 79, 2);
ControlLocSort := New(PRadioButtons, Init(R,
  NewSItem('Клиен~т~',
  NewSItem('Ко~л~-во',
  NewSItem('Д~а~та', Nil)))));
PCluster(ControlLocSort)^.SetButtonState($00000001, False);
VRP^.Insert(ControlLocSort);

c:=2;
LocSort:=c;
ControlLocSort^.SetData(c);

  R.Assign(35, 1, 42, 2);
  VRP^.Insert(New(PLabel, Init(R, 'Со~р~т.:', ControlLocSort)));

R.Assign(27, 18, 41, 19);
Control := New(PColoredText, Init(R, 'Вид документа:', $74));
VRP^.Insert(Control);

R.Assign(41, 18, 50, 19);
ControlDocSelector := New(PColoredText, Init(R, #3+'', $7E));
VRP^.Insert(ControlDocSelector);

R.Assign(7, 18, 14, 19);
Control := New(PColoredText, Init(R, 'Расчет:', $74));
VRP^.Insert(Control);

R.Assign(14, 18, 21, 19);
ControlRashet := New(PColoredText, Init(R, #3+'', $7E));
VRP^.Insert(ControlRashet);

R.Assign(43, 20, 52, 21);
Control := New(PColoredText, Init(R, 'Доставка:', $74));
VRP^.Insert(Control);

R.Assign(52, 20, 78, 21);
ControlAgent := New(PColoredText, Init(R, #3+'', $7E));
VRP^.Insert(ControlAgent);

R.Assign(3, 19, 8, 20);
Control := New(PColoredText, Init(R, 'Банк:', $74));
VRP^.Insert(Control);

R.Assign(8, 19, 53, 20);
ControlBank := New(PColoredText, Init(R, #3+'', $7E));
VRP^.Insert(ControlBank);

R.Assign(56, 18, 63, 19);
Control := New(PColoredText, Init(R, 'Скидка:', $74));
VRP^.Insert(Control);

R.Assign(63, 18, 71, 19);
ControlSkidkaSelector := New(PColoredText, Init(R, #3+'', $7E));
VRP^.Insert(ControlSkidkaSelector);

R.Assign(13, 21, 58, 22);
ControlComment := New(PColoredText, Init(R, #3+'', $7E));
VRP^.Insert(ControlComment);

R.Assign(2, 21, 13, 22);
Control := New(PColoredText, Init(R, 'Примечание:', $74));
VRP^.Insert(Control);

R.Assign(56, 19, 66, 20);
Control := New(PColoredText, Init(R, 'Номер п/п:', $74));
VRP^.Insert(Control);

R.Assign(66, 19, 76, 20);
ControlNPP := New(PColoredText, Init(R, #3+'', $7E));
VRP^.Insert(ControlNPP);

R.Assign(3, 20, 12, 21);
Control := New(PColoredText, Init(R, 'Дата п/п:', $74));
VRP^.Insert(Control);

R.Assign(12, 20, 20, 21);
ControlDatePP := New(PColoredText, Init(R, #3+'', $7E));
VRP^.Insert(ControlDatePP);

R.Assign(22, 20, 32, 21);
Control := New(PColoredText, Init(R, 'Сумма п/п:', $74));
VRP^.Insert(Control);

R.Assign(32, 20, 42, 21);
ControlSummaPP := New(PColoredText, Init(R, #3+'', $7E));
VRP^.Insert(ControlSummaPP);

{Izmen:=0;}
{
If StrToInt(CurrentPassword)=0 Then
Begin
R.Assign(62, 21, 79, 22);
ControlEditFiltr := New(PCheckboxes, Init(R,
  NewSItem('Из~м~ененные', Nil)));
VRP^.Insert(ControlEditFiltr);
ControlEditFiltr^.SetDAta(Izmen);
End;
}

VRP^.SelectNext(False);

{вставить текст формирования списка позиций}
VRP^.Refresh(c);
NoInfoMsg;
c:=Desktop^.ExecView(VRP);
Dispose(Control,Done);
Dispose(VRP,Done);
Dispose(NoScr,Done);
End;

procedure TViewRPWindow.DrawCurrent;
Var st,ts,ts1 : String;
    R : TRect;
Begin
If (PrhList^.List<>Nil)And(PrhList^.List^.Count>0)  Then
 Begin
  st:=PrhList^.GetText(PrhList^.Focused,PrhList^.List^.Count);
  If St <> PrevLine Then
   Begin
    PrevLine:=St;
    ts:=Copy(st,1+CClient+1+CMakeKod+1+CdocNumer+1+CDate+1+CKOl+1+CZena+1+CZena+1,COne);

    Case StrToInt(ts) Of
    0:ts:='Список';
    1:ts:='Тов.Чек*';
    2:ts:='Физ.Л*';
    3:ts:='СФ*';
    4:ts:='СФ ';
    5:ts:='Дебит*';
    6:ts:='Дебит СФ*';
    7:ts:='Дебит';
    8:ts:='Дебит СФ';
    Else ts:='???';
    End;
Dispose(ControlDocSelector,Done);
R.Assign(41, 18, 50, 19);
ControlDocSelector := New(PColoredText, Init(R, #3+ts, $7E));
VRP^.Insert(ControlDocSelector);

    ts:=Copy(st,1+CClient+1+CMakeKod+1+CdocNumer+1+CDate+1+CKOl+1+CZena+1+CZena+1+COne+1+CKto+1+COne+1,COne);
    Case StrToInt(ts) Of
    0:ts:='Нал';
    1:ts:='Б/Н';
    2:ts:='Вексель';
    Else ts:='???';
    End;

Dispose(ControlRashet,Done);
R.Assign(14, 18, 21, 19);
ControlRashet := New(PColoredText, Init(R, #3+ts, $7E));
VRP^.Insert(ControlRashet);


    ts:=Copy(st,1+CClient+1+CMakeKod+1+CdocNumer+1+CDate+1+CKOl+1+CZena+1+CZena+1+COne+1+CKto+1+COne+1
    +COne+1,CMAkeKod);
DelSpaceRight(ts);
ts1:=GetAgentField(Fagent,ts);
Format(ts1,CClient);
Dispose(ControlAgent,Done);
R.Assign(52, 20, 78, 21);
ControlAgent := New(PColoredText, Init(R, #3+ts1+'('+ts+')', $7E));
VRP^.Insert(ControlAgent);

    ts:=Copy(st,1+CClient+1+CMakeKod+1+CdocNumer+1+CDate+1+CKOl+1+CZena+1+CZena+1+COne+1+CKto+1+COne+1
    +COne+1+CMAkeKod+1,CAll);
DelSpaceRight(ts);
Dispose(ControlBAnk,Done);
R.Assign(8, 19, 53, 20);
ControlBank := New(PColoredText, Init(R, #3+ts, $7E));
VRP^.Insert(ControlBank);


    ts:=Copy(st,1+CClient+1+CMakeKod+1+CdocNumer+1+CDate+1+CKOl+1+CZena+1+CZena+1+COne+1+CKto+1,COne);

    Case StrToInt(ts) Of
    0:ts:='Авто';
    1:ts:='Ручная';
    Else ts:='???';
    End;

Dispose(ControlSkidkaSelector,Done);
R.Assign(63, 18, 71, 19);
ControlSkidkaSelector := New(PColoredText, Init(R, #3+ts, $7E));
VRP^.Insert(ControlSkidkaSelector);

    ts:=Copy(st,1+CClient+1+CMakeKod+1+CdocNumer+1+CDate+1+CKOl+1+CZena+1+CZena+1+COne+1+CKto+1+COne+1
    +COne+1+CMAkeKod+1+CAll+1+CDate+1+10+1+CIZena+1,CAll);
    DelSpace(ts);

Dispose(ControlComment,Done);
R.Assign(13, 21, 58, 22);
ControlComment := New(PColoredText, Init(R, #3+ts, $7E));
VRP^.Insert(ControlComment);

    ts:=Copy(st,1+CClient+1+CMakeKod+1+CdocNumer+1+CDate+1+CKOl+1+CZena+1+CZena+1+COne+1+CKto+1+COne+1
    +COne+1+CMAkeKod+1+CAll+1+CDate+1,10);
DelSpace(ts);
Dispose(ControlNPP,Done);
R.Assign(66, 19, 76, 20);
ControlNPP := New(PColoredText, Init(R, #3+ts, $7E));
VRP^.Insert(ControlNPP);

    ts:=Copy(st,1+CClient+1+CMakeKod+1+CdocNumer+1+CDate+1+CKOl+1+CZena+1+CZena+1+COne+1+CKto+1+COne+1
    +COne+1+CMAkeKod+1+CAll+1,CDate);

Dispose(ControlDatePP,Done);
R.Assign(12, 20, 20, 21);
ControlDatePP := New(PColoredText, Init(R, #3+ts, $7E));
VRP^.Insert(ControlDatePP);

    ts:=Copy(st,1+CClient+1+CMakeKod+1+CdocNumer+1+CDate+1+CKOl+1+CZena+1+CZena+1+COne+1+CKto+1+COne+1
    +COne+1+CMAkeKod+1+CAll+1+CDate+1+10+1,CIZena);
    DelSpace(ts);
Dispose(ControlSummaPP,Done);
R.Assign(32, 20, 42, 21);
ControlSummaPP := New(PColoredText, Init(R, #3+ts, $7E));
VRP^.Insert(ControlSummaPP);
Redraw;
   End;
 End
 Else
  Begin
   PStaticText(ControlDocSelector)^.GetText(st);
  If (st)<>(#3+'???') Then
  Begin
Dispose(ControlDocSelector,Done);
R.Assign(41, 18, 50, 19);
ControlDocSelector := New(PColoredText, Init(R, #3+'???', $7E));
VRP^.Insert(ControlDocSelector);

Dispose(ControlRashet,Done);
R.Assign(14, 18, 21, 19);
ControlRashet := New(PColoredText, Init(R, #3+'???', $7E));
VRP^.Insert(ControlRashet);

Dispose(ControlAgent,Done);
R.Assign(52, 20, 78, 21);
ControlAgent := New(PColoredText, Init(R, #3+'???', $7E));
VRP^.Insert(ControlAgent);

Dispose(ControlBAnk,Done);
R.Assign(8, 19, 53, 20);
ControlBank := New(PColoredText, Init(R, #3+'???', $7E));
VRP^.Insert(ControlBank);

Dispose(ControlSkidkaSelector,Done);
R.Assign(63, 18, 71, 19);
ControlSkidkaSelector := New(PColoredText, Init(R, #3+'???', $7E));
VRP^.Insert(ControlSkidkaSelector);

Dispose(ControlComment,Done);
R.Assign(13, 21, 58, 22);
ControlComment := New(PColoredText, Init(R, #3+'???', $7E));
VRP^.Insert(ControlComment);

Dispose(ControlNPP,Done);
R.Assign(66, 19, 76, 20);
ControlNPP := New(PColoredText, Init(R, #3+'???', $7E));
VRP^.Insert(ControlNPP);

Dispose(ControlDatePP,Done);
R.Assign(12, 20, 20, 21);
ControlDatePP := New(PColoredText, Init(R, #3+'???', $7E));
VRP^.Insert(ControlDatePP);

Dispose(ControlSummaPP,Done);
R.Assign(32, 20, 42, 21);
ControlSummaPP := New(PColoredText, Init(R, #3+'???', $7E));
VRP^.Insert(ControlSummaPP);
  st:='';
  PrevLine:=St;
  Redraw;
  End;
  End;


End;

procedure TViewRPWindow.Refresh(LocSort:Word);
Var i,j : Word;
    ws,ws1,ws2,Comment : String;
    TempBox : PBox;
    R : TRect;
    f : File of StatTovarMarketType;
    ef : PStatTovarMarketType;
    AllKol,AllSZ,AllSR:AllStr;

Begin
WordToBit3(LocOperation,SLocOperation);
Convert3(SLocOperation);

DInfoMsg('Минуточку...');


Assign(f,Path.ToAnalys+SKodTov+'.rp');
i:=IOResult;
Reset(f);
If i<>0 Then
 Begin
  NoInfoMsg;
  MessageBox(#3'Ошибка открытия файла '+Path.ToAnalys+SKodTov+'.rp!'^M+
  #3+ClicProgrammer,Nil,mfError+mfCancelButton);
  Exit;
 End;

NoScr^.NewList(Nil);
NoScr^.NewList(New(PMyCollection, Init(0,1)));


New(Ef,Init);
AllSR:='0.00';
AllSZ:='0.00';
AllKol:='0';
While Not(eof(f)) Do
Begin
Read(f,ef^.Dat);
ws[0]:=#0;
If StrToInt(Ef^.Dat.SkladKod)=StrToInt(Rek.Kod) Then
Begin
If SLocOperation[Ef^.Dat.OperatorSelector+1]=1 Then
Begin
{If (Izmen=0) Or ((Izmen=1)And(Ef^.Dat.TimeC<>Ef^.Dat.TimeM)) Then}
Begin
RFormatZerro(Ef^.Dat.Document,CDocnumer);
Format(Ef^.Dat.DateC,CDate);
DelSpace(Ef^.Dat.Kol);
RFormat(Ef^.Dat.Kol,CKol);
Str(StrToInt(Ef^.Dat.Kol)+StrToInt(AllKol):CKol+2,AllKol);

Str(StrToReal(Ef^.Dat.SummaZ)+StrToReal(AllSR):CIZena:CMantissa,AllSR);
Str(StrToReal(Ef^.Dat.SummaZakupka)+StrToReal(AllSZ):CIZena:CMantissa,AllSZ);

ws:=GetClientField(FClient,Ef^.Dat.ClientKod,Ef^.Dat.OperatorSelector);
Format(ws,CMAke);
Str(StrToReal(Ef^.Dat.SummaZ)/StrToInt(Ef^.Dat.Kol):CZena:CMAntissa,ws1);
Str(StrToReal(Ef^.Dat.SummaZakupka)/StrToInt(Ef^.Dat.Kol):CZena:CMAntissa,ws2);
ws:=ws+'│'+Ef^.Dat.ClientKod+'│'+Ef^.Dat.Document+'│'+Ef^.Dat.DateC+'│'+Ef^.Dat.Kol+
'│'+ws2+'│'+ws1+'│'+IntToStr(Ef^.Dat.DocSelector,COne)+'│';
ws1:=GetOperatorName(Ef^.Dat.Caption);
Format(ws1,CKto);

{Ef^.Dat.Comment:='123456789012345678901234567890123456789012345';}

Format(Ef^.Dat.Bn.Bank,CAll);
Format(Ef^.Dat.Bn.Date,CDate);
Format(Ef^.Dat.Bn.NPlat,10);
Format(Ef^.Dat.Bn.Summa,CIZena);
Comment[0]:=#0;
Format(Comment,CAll);

ws:=ws+ws1+'│'+IntToStr(Ef^.Dat.SkidkaSelector,COne)+'│'+IntToStr(Ef^.Dat.Rashet,COne)+'│'+
               Ef^.Dat.AgentKod+'│'+Ef^.Dat.Bn.Bank+'│'+Ef^.Dat.Bn.Date+'│'+
               Ef^.Dat.Bn.NPlat+'│'+Ef^.Dat.Bn.Summa+'│'+Comment+'│'+Ef^.Dat.TimeC;
NoScr^.List^.Insert(NewStr(ws));
NoScr^.SetRange(NoScr^.List^.Count);
End;{Izmen}
End;
End;
End;
NoScr^.FocusItem(0);
NoScr^.HelpCtx:=$F082;

Dispose(Ef,Done);
System.Close(f);

DelSpace(AllKol);
DelSpace(AllSR);
DelSpace(AllSZ);

Dispose(ControlIKol,Done);
R.Assign(9, 22, 16, 23);
ControlIKol := New(PColoredText, Init(R, #3+AllKol, $4E));
VRP^.Insert(ControlIKol);

Dispose(ControlIRZ,Done);
R.Assign(64, 22, 79, 23);
ControlIRZ := New(PColoredText, Init(R, #3+AllSR, $4E));
VRP^.Insert(ControlIRZ);

Dispose(ControlIZZ,Done);
R.Assign(32, 22, 47, 23);
ControlIZZ := New(PColoredText, Init(R, #3+AllSZ, $4E));
VRP^.Insert(ControlIZZ);

Sorting(LocSort);
NoInfoMsg;
Redraw;
End;

procedure TViewRPWindow.Sorting(LocSort : Word);
Var j: Word;
    ws,ws1,ws2 : String;
    R : TRect;
    TempBox : PBox;
Begin
DInfoMsg('Сортирую выборку...');
R.Assign(0,0,0,0);
TempBox := New(PBox, Init(R, 1, Nil));
TempBox^.NewList(New(PTextCollection, Init(0,1)));

PrhList^.NewList(Nil);
PrhList^.NewList(New(PMyCollection, Init(0,1)));

If NoScr^.List^.Count>0 Then
Begin
{формируем отсортированый список}
For j:=0 to NoScr^.List^.Count-1 Do
Begin
 ws:=NoScr^.GEtText(j,NoScr^.List^.Count);
Case LocSort Of
{поставщик}
0:ws:=ws;
{Раздел}
1:Begin
   ws1:=Copy(ws,1+CClient+1+CMakeKod+1+CDocNumer+1+CDAte+1,CKol);
   ws:=ws1+ws;
  End;
{Дата поступления}
2:Begin
   ws1:=Copy(ws,1+CClient+1+CMakeKod+1+CDocNumer+1,CDate);
   ws2:=Copy(ws,Ord(ws[0])-CDate+1,CDate);{время}
   ws1:=IntToSTr(DateStringToDate(DateMask,ws1),CDate);
   Format(ws1,CDate);
   ws:=ws1+' '+ws2+ws;
  End;
Else;
End;{CAse}
  TempBox^.List^.Insert(NewStr(ws));
  TempBox^.SetRange(TempBox^.List^.Count);
End;{for}


{форматируем сформированый список под экранную форму}
If TempBox^.List^.Count>0 Then
Begin
For j:=0 to TempBox^.List^.Count-1 Do
Begin
  ws:=TempBox^.GEtText(j,TempBox^.List^.Count);
Case LocSort Of
{поставщик}
0:ws:=ws;
{количество}
1:Begin
   System.Delete(ws,1,CKol);
  End;
{дата поступления}
2:Begin
   System.Delete(ws,1,CDAte+1+CDAte);
  End;
Else;
End;{CAse}
  PrhList^.List^.Insert(NewStr(ws));
  PrhList^.SetRange(PrhList^.List^.Count);
End;
End;
End;{if}

{0:поставщик
 1:количество
 2:дата поступления}

PrhList^.FocusItem(0);
PrhList^.HelpCtx:=$F082;

Dispose(TempBox,Done);
NoInfoMsg;
PrevLine[0]:=#0;
End;

Procedure TViewRPWindow.FullPrevView;
Var Ass : DocumentEdit;
    E : PSuperMarketType;
    R : TRect;
    f : MarketFileType;
    c : Word;
    P : PBox;
    ws : TMyString;
    Find : Boolean;
    SKolish,SDoc,SClientKod,SAgentKod : ArtikulStr;
    s,SCommentr : String;
    SDate : TDateString;
    ws1,WspomSkidka:String[CIZena];
    v : Byte;

Begin
If (PrhList^.List<>Nil)And(PrhList^.List^.Count>=1) Then
Begin
  Ass.EditPosition:=Copy(PrhList^.GetText(PrhList^.Focused,PrhList^.List^.Count),1+CClient+1+CClientKod+1,CDocNumer);
  DelSpace(Ass.EditPosition);
  DelZerro(Ass.EditPosition);
  Ass.D:=Copy(PrhList^.GetText(PrhList^.Focused,PrhList^.List^.Count),1+CClient+1+CClientKod+1+CDocNumer+1,CDate);
  DelSpace(Ass.D);
  ViewMrk^.FullScreenMrk(Ass);
End;
End;

procedure TViewRPWindow.FormReport(E:PBox);
Const SPace = '      ';
Var txt : Text;
    i,c : Word;
    ws,s1 : String;
Begin

 WordToBit3(LocOperation,SLocOperation);
 Convert3(SLocOperation);

 Assign(txt,Path.ToTemp+'strp.txt');
 i:=IOResult;
 Rewrite(txt);
 i:=IOResult;
 If i<>0 Then
  Begin
   MessageBox(^M+#3'Ошибка создания '+Path.ToTemp+'strp.txt'+
   ^M+#3+ClicProgrammer,Nil,mfError+mfCancelButton);
   Exit;
  End;
 DInfoMsg('Формирую отчет. Ждите...');

 Writeln(Txt,Space+'Склад: ',GetClientField(FClient,Rek.Kod,1)+'  Оператор: '+CurrentPassword+' EYE & 1997-98');

 Writeln(txt,Space+'Включены в рассмотрение следующие виды операций:');
 Write(txt,Space);
 For c:=1 To Max3 Do
  Begin
   If SLocOperation[c]=1 Then
    Case c Of
    1:Write(txt,' "Клиент" ');
    2:Write(txt,' "Склад" ');
    3:Write(txt,' "Обмен" ');
    Else;
    End;
  End;
 Writeln(txt);
 Writeln(txt,Space+'Включены в рассмотрение следующие виды документов:');
 Write(txt,Space);
 For c:=1 To Max9 Do
  Begin
   If SVidDocTov[c]=1 Then
    Case c Of
    1:Write(txt,' "Список"');
    2:Write(txt,' "Тов.Чек*"');
    3:Write(txt,' "Физ.Л*"');
    4:Write(txt,' "СФ*"');
    5:Write(txt,' "СФ "');
    6:Write(txt,' "Дебит*"');
    7:Write(txt,' "Дебит СФ*"');
    8:Write(txt,' "Дебит"');
    9:Write(txt,' "Дебит СФ"');
    Else;
    End;
  End;
 Writeln(txt);

 Write(txt,Space+'Вид сортировки:');
    Case LocSort Of
    0:WriteLn(txt,' "Клиент" ');
    1:WriteLn(txt,' "Количество" ');
    2:WriteLn(txt,' "Дата" ');
    Else;
    End;
{
 If Izmen=1 Then
 Begin
 Writeln(txt,Space+'Внимание! В справку включены только изменявшиеся документы!');
 Writeln(txt);
 End;
}
 Writeln(txt,Space+Bold[NPrint.Printer]+'  СПРАВКА ПО СПИСАНИЯМ (РП) ТОВАРА ЗА ПЕРИОД С '+StartDateToV+' ПО '+StopDateToV+
 NoBold[NPrint.Printer]);
 Writeln(txt,Space+'Выбранная позиция товара:');

ws:=GetIdField(FName,SKodToV);
Format(ws,CNAme);
ws:=ws+' Код:'+SKodToV+' Фас:';
s1:=GetIdField(FInPack,SKodToV);
ws:=ws+s1+' Литраж:';
s1:=GetIdField(FLitr,SKodToV);
ws:=ws+s1+' Цена:';
s1:=BakGetField(FRZena,SKodToV,1);
ws:=ws+s1;
 Writeln(txt,Space+Italic[NPrint.Printer]+ws+NoItalic[NPrint.Printer]);

 Writeln(txt,Space+'--------------------------------------------------------------------------------------');
 Writeln(txt,Space+'     Клиент          Код  Док.   Дата   Колич. З/Цена   Р/Цена  Вид док.   Оператор');
                   {12345678901234567890│1234│1234│12-45-78│12345│12345678│12345678│ДЕБИТ СФБ│123456789012}
 Writeln(txt,Space+'--------------------------------------------------------------------------------------');
If E^.List^.Count>0 Then
Begin
 For c:=0 To E^.List^.Count-1 Do
 Begin
  ws:=E^.GetText(c,E^.List^.Count);
  While Pos('│',ws)>0 Do ws[Pos('│',ws)]:=' ';
  s1:=Copy(ws,1+CClient+1+CMakeKod+1+CDocNumer+1+CDate+1+CKol+1+CZena+1+CZena+1,COne);
    Case StrToInt(s1) Of
    0:s1:='Список   ';
    1:s1:='Тов.Чек* ';
    2:s1:='Физ.Л*   ';
    3:s1:='СФ*      ';
    4:s1:='СФ       ';
    5:s1:='Дебит*   ';
    6:s1:='Дебит СФ*';
    7:s1:='Дебит    ';
    8:s1:='Дебит СФ ';
    Else
      S1:='  ???    ';
    End;
  System.Delete(ws,1+CClient+1+CMakeKod+1+CDocNumer+1+CDate+1+CKol+1+CZena+1+CZena+1,COne);
  System.Insert(s1,ws,1+CClient+1+CMakeKod+1+CDocNumer+1+CDate+1+CKol+1+CZena+1+CZena+1);

  ws[0]:=Chr(CClient+1+CMakeKod+1+CDocNumer+1+CDate+1+CKol+1+CZena+1+CZena+1+9+1+CKto);
 Writeln(txt,Space+ws);
 End;
End;
 Writeln(txt,Space+'--------------------------------------------------------------------------------------');

PStaticText(ControlIKol)^.GetText(ws);
System.Delete(ws,1,1);
DelSpace(ws);
RFormat(ws,CIZena);

 Writeln(txt,Space+'                                             Всего отгрузка: '+ws);

PStaticText(ControlIZZ)^.GetText(ws);
System.Delete(ws,1,1);
DelSpace(ws);

 Writeln(txt,Space+'                                           Всего по З/Ценам: '+
 Recogniz(RealToStr(StrToReal(ws),CIZena,CMAntissa)));

PStaticText(ControlIRZ)^.GetText(ws);
System.Delete(ws,1,1);
DelSpace(ws);

 Writeln(txt,Space+'                                           Всего по Р/Ценам: '+
 Recogniz(RealToStr(StrToReal(ws),CIZena,CMAntissa)));

 Writeln(txt);
 Writeln(txt,Space,'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
 Writeln(txt,Space+'======================================================================================');

 System.Close(txt);
 NoInfoMsg;
{
 If Izmen=1 Then
 MessageBox(^M+#3'В справку включены только изменявшиеся документы!',Nil,mfWarning+mfCancelButton);;
}
 Report(Path.ToTemp+'strp.txt','',1,False,False,false);

End;

procedure TViewRPWindow.HandleEvent(var Event: TEvent);

procedure Calculator;
begin
  Calc^.Start;
end;

Var Test : Word;
    sClientKod:ArtikulStr;
    s,s1 : String;
    SDoc,SDate : TDateString;

Begin
  Case Event.What Of
  evKeyDown :
  Case Event.KeyCode Of
     kbEsc: Begin
              ClearFind;
              Event.What:=evCommand;
              Event.Command:=cmCancel;
              PutEvent(Event);
              ClearEvent(Event);
            End;
      Else;
      End;{KeyDown}
  evCommand :
     Case Event.Command Of
       cmLocalCalc:Begin
                     ClearFind;
                     Calculator;
                   End;
  cmFullView:Begin
              ClearFind;
              If (PrhList^.State and sfFocused <> 0) And (PrhList^.List<>Nil)And(PrhList^.List^.Count>=1) Then
               Begin
                FullPrevView;
               End
            End;

  cmPrintReestr:    Begin
                 ClearFind;
     If (PrhList^.State and sfFocused <> 0) And (PrhList^.List<>Nil)And(PrhList^.List^.Count>=1) Then
            Begin
                Assistent.EditPosition:=Copy(PrhList^.GetText(PrhList^.Focused,PrhList^.List^.Count),1+CClient+1+CMakeKod+1,
			 CDocNumer);
                DelSpace(Assistent.EditPosition);
                DelZerro(Assistent.EditPosition);
                Assistent.D:=Copy(PrhList^.GetText(PrhList^.Focused,PrhList^.List^.Count),1+CClient+1+CMakeKod+1+CDocNumer+1,
			 CDate);
                DelSpace(Assistent.D);
                PrintNakl(Assistent,NPrint.CopyNkl);
            End
            End;

 cmReestrReport:    Begin
                 ClearFind;
     If (PrhList^.List<>Nil)And(PrhList^.List^.Count>=1) Then
            Begin
             FormReport(PrhList);
            End
            End;
      Else;
      End;{evCommand}
      Else;
      End;{*Case*}
  if (Event.What = evBroadcast) and
    (Event.Command = cmRp) then ClearEvent(Event);

  if (Event.What = evBroadcast) and
    (Event.Command = cmQuit) then ClearEvent(Event);

inherited HandleEvent(Event);

  If (Desktop^.Current=PView(VRP)) And (Event.What <> EvKeyDown) Then
   Begin

   DrawCurrent;
  if (ControlLocSort^.State and sfFocused <> 0)Then
                    Begin
                        ControlLocSort^.GetData(Test);
                        If Test <> LocSort Then
                        Begin
                           ClearFind;
                           LocSort:=Test;
                           Sorting(LocSort);
                           Redraw;
                        End;
                    End;

  if (ControlLocFiltr^.State and sfFocused <> 0)Then
                    Begin
                        ControlLocFiltr^.GetData(Test);
                        If Test <> LocOperation Then
                        Begin
                           ClearFind;
                           LocOperation:=Test;
									Refresh(LocSort);
                           Redraw;
                        End;
                    End;

{
  If StrToInt(CurrentPassword)=0 Then
  BEgin
  if (ControlEditFiltr^.State and sfFocused <> 0)Then
                    Begin
                        ControlEditFiltr^.GetData(Test);
                        If Test <> Izmen Then
                        Begin
                           ClearFind;
                           Izmen:=Test;
									Refresh(LocSort);
                           Redraw;
                        End;
                    End;
  End;
}
    End;

End;

Destructor TViewRPWindow.Done;
Begin
TDialog.Done;
End;



Begin
{Izmen:=0;}
End.