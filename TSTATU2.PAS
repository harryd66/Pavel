{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}
Unit tStatu2;


Interface


Uses Dialogs,Drivers,Glob,Access,ServStr,MyCalc,LockInfo,Utils ;


Type
  PViewRwzWindow = ^TViewRwzWindow;
  TViewRwzWindow = object(TDialog)
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

Procedure FormReportS(Const Cl,Agent,NoScreenList,NMakeList:PBox;
StartDateTov,StopDateTov:TDAteString;VidReport:Word;Var txt,er:Text);

implementation

uses DBEngine,Objects, Views, MsgBox,Protect,TPDate,Market,Tools,Printers,TStat,
     App, ColorTxt,Validate,Serv,Nastr,Vision1,Vision2,Vision3,NetDbEng;

Var NoScr : PBox;
 ControlSummaPP,ControlNPP,ControlDatePP,ControlComment,ControlAgent,ControlRashet,
 ControlBank,ControlSkidkaSelector,ControlDocSelector,ControlIKol,ControlIZZ,ControlIRZ:PView;

 PrhList : PBox;
 VRwz :PViewRwzWindow;
 ControlLocSort,ControlLocFiltr:PView;
 LocSort,LocOperation,LocFiltr : Word;
 SLocOperation : Maska3;


procedure TViewRwzWindow.Start(SVidOperation:Word);
Var R : TRect;
    Control : PView;
    c : Word;
    s,s1 : String;
Begin
DInfoMsg('Минуточку...');
R.Assign(0, 0, 80, 23);
New(VRwz, Init(R, 'Ревизии на складе за период с '+StartDatetov+' по '+StopDatetov));
VRwz^.HelpCtx:=$F076;

R.Assign(73, 4, 74, 20);
Control := New(PScrollBar, Init(R));
VRwz^.Insert(Control);

R.Assign(10, 4, 73, 20);
PrhList := New(PBox, Init(R, 1, PScrollBar(Control)));
PrhList^.NewList(New(PTextCollection, Init(0,1)));

PrhList^.FocusItem(0);
PrhList^.HelpCtx:=$F076;
VRwz^.Insert(PrhList);

R.Assign(0, 0, 0, 0);
NoScr := New(PBox, Init(R, 1, PScrollBar(Control)));
NoScr^.NewList(New(PMyCollection, Init(0,1)));


  R.Assign(10, 3, 73, 4);
  VRwz^.Insert(New(PLabel, Init(R, '   N    Дата   Колич. Цена Р/Ц  Итого ревизия   Оператор   Прв', PrhList)));

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
VRwz^.Insert(Control);

R.Assign(2, 22, 9, 23);
Control := New(PColoredText, Init(R, ' Всего:', $74));
VRwz^.Insert(Control);

R.Assign(9, 22, 16, 23);
ControlIKol := New(PColoredText, Init(R, #3+'0', $4E));
VRwz^.Insert(ControlIKol);


R.Assign(50, 22, 64, 23);
Control := New(PColoredText, Init(R, ' Итого по Р/Ц:', $74));
VRwz^.Insert(Control);

R.Assign(64, 22, 79, 23);
ControlIRZ := New(PColoredText, Init(R, #3+'0.00', $4E));
VRwz^.Insert(ControlIRZ);

R.Assign(1, 1, 35, 2);
ControlLocFiltr := New(PCheckboxes, Init(R,
  NewSItem('Кл~и~ент',
  NewSItem('~С~клад',
  NewSItem('~О~бмен', Nil)))));
PCluster(ControlLocFiltr)^.SetButtonState($00000007, False);
VRwz^.Insert(ControlLocFiltr);
LocOperation:=OperationTov;

WordToBit3(LocOperation,SLocOperation);

Invert3(SLocOperation);
BitToWord3(SLocOperation,c);
PCluster(ControlLocFiltr)^.SetButtonState(c, False);

Invert3(SLocOperation);{возвращаем в нормальное состояние}

BitToWord3(SLocOperation,LocOperation);

ControlLocFiltr^.SetData(LocOperation);


  R.Assign(1, 0, 11, 1);
  VRwz^.Insert(New(PLabel, Init(R, 'Опера~ц~ии:', ControlLocFiltr)));

R.Assign(42, 1, 73, 2);
ControlLocSort := New(PRadioButtons, Init(R,
  NewSItem('Ко~л~ич',
  NewSItem('~Ц~ена',
  NewSItem('Д~а~та', Nil)))));
VRwz^.Insert(ControlLocSort);

c:=2;
LocSort:=c;
ControlLocSort^.SetData(c);

  R.Assign(35, 1, 42, 2);
  VRwz^.Insert(New(PLabel, Init(R, 'Со~р~т.:', ControlLocSort)));

R.Assign(2, 20, 22, 21);
Control := New(PColoredText, Init(R, 'Подписан оператором:', $74));
VRwz^.Insert(Control);

R.Assign(2, 21, 13, 22);
Control := New(PColoredText, Init(R, 'Примечание:', $74));
VRwz^.Insert(Control);


R.Assign(22, 20, 58, 21);
ControlDatePP := New(PColoredText, Init(R, #3+'', $7E));
VRwz^.Insert(ControlDatePP);

R.Assign(13, 21, 79, 22);
ControlSummaPP := New(PColoredText, Init(R, #3+'', $7E));
VRwz^.Insert(ControlSummaPP);

VRwz^.SelectNext(False);

{вставить текст формирования списка позиций}
VRwz^.Refresh(c);
NoInfoMsg;
c:=Desktop^.ExecView(VRwz);
Dispose(Control,Done);
Dispose(VRwz,Done);
Dispose(NoScr,Done);
End;

procedure TViewRwzWindow.DrawCurrent;
Var st,ts,ts1 : String;
    R : TRect;
Begin
If (PrhList^.List<>Nil)And(PrhList^.List^.Count>0)  Then
 Begin
  st:=PrhList^.GetText(PrhList^.Focused,PrhList^.List^.Count);
  If St <> PrevLine Then
   Begin
    PrevLine:=St;
    ts1:=St;
    ts:=Copy(st,Ord(PrevLine[0])-CSertif+1,CSertif);
    DelSpaceRight(ts);

Dispose(ControlSummaPP,Done);
R.Assign(13, 21, 79, 22);
ControlSummaPP := New(PColoredText, Init(R, #3+ts, $7E));
VRwz^.Insert(ControlSummaPP);


  ts:=Copy(st,1+1+CDocNumer+1+CDate+1+(CKol+1)+1+CZena+1+CIZena+1+CKto+1,CRazdelKod);

  If ts='Ok' Then
   Begin
    ts:=Copy(st,1+1+CDocNumer+1+CDate+1+(CKol+1)+1+CZena+1+CIZena+1+CKto+1+CRazdelKod+1,CRazdelKod);
    ts:=GetOperatorName(ts);
    ts1:=Copy(st,1+1+CDocNumer+1+CDate+1+(CKol+1)+1+CZena+1+CIZena+1+CKto+1+CRazdelKod+1+CRazdelKod+1+CDAte+1,CDate+1+CDate);
    While Pos('│',ts1)>0 Do ts1[Pos('│',ts1)]:=' ';
    ts:=ts+' '+ts1;
   End
     Else ts[0]:=#0;




Dispose(ControlDatePP,Done);
R.Assign(22, 20, 58, 21);
ControlDatePP := New(PColoredText, Init(R, #3+ts, $7E));
VRwz^.Insert(ControlDatePP);
Redraw;
   End;
 End
 Else
  Begin
   PStaticText(ControlSummaPP)^.GetText(st);
  If (st)<>(#3+'???') Then
  Begin
Dispose(ControlDatePP,Done);
R.Assign(13, 21, 79, 22);
ControlDatePP := New(PColoredText, Init(R, #3+'???', $7E));
VRwz^.Insert(ControlDatePP);

Dispose(ControlSummaPP,Done);
R.Assign(22, 20, 58, 21);
ControlSummaPP := New(PColoredText, Init(R, #3+'???', $7E));
VRwz^.Insert(ControlSummaPP);
  st:='';
  PrevLine:=St;
  Redraw;
  End;
  End;
End;

procedure TViewRwzWindow.Refresh(LocSort:Word);
Var i,j : Word;
    ws,ws1,ws2,comment,CaptionTested : String;
    TempBox : PBox;
    R : TRect;
    f : File of StatTovarRwzType;
    ef : PStatTovarRwzType;
    TimeT,DateT,AllKol,AllSZ,AllSR:AllStr;

Begin
WordToBit3(LocOperation,SLocOperation);
Convert3(SLocOperation);

DInfoMsg('Минуточку...');


Assign(f,Path.ToAnalys+SKodTov+'.rwz');
i:=IOResult;
Reset(f);
If i<>0 Then
 Begin
  NoInfoMsg;
  MessageBox(#3'Ошибка открытия файла '+Path.ToAnalys+SKodTov+'.rwz!'^M+
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
RFormatZerro(Ef^.Dat.Document,CDocnumer);
Format(Ef^.Dat.DateC,CDate);
Comment[0]:=#0;
Format(Comment,CSertif);
DelSpace(Ef^.Dat.Kol);
RFormat(Ef^.Dat.Kol,CKol+1);
CaptionTested:='00';
RFormat(CaptionTested,CRazdelKod);
DAteT:='';
TimeT:='';
RFormat(DateT,CDate);
RFormat(Ef^.Dat.TimeC,CDate);
RFormat(TimeT,CDate);

Str(StrToInt(Ef^.Dat.Kol)+StrToInt(AllKol):CKol+2,AllKol);
{
Str(StrToReal(Ef^.Dat.Summa)+StrToReal(AllSR):CIZena:CMantissa,AllSR);
Str(StrToReal(Ef^.Dat.Summa):CIZena:CMAntissa,ws);
Str(StrToReal(Ef^.Dat.Summa)/StrToInt(Ef^.Dat.Kol):CZena:CMAntissa,ws1);
}


Str(StrToReal(Ef^.Dat.Summa)+StrToReal(AllSR):CIZena:CMantissa,AllSR);
Str(StrToReal(Ef^.Dat.Summa):CIZena:CMAntissa,ws);
Str(StrToReal(Ef^.Dat.Zena):CZena:CMAntissa,ws1);
ws:='│'+Ef^.Dat.Document+'│'+Ef^.Dat.DateC+'│'+Ef^.Dat.Kol+'│'+ws1+'│'+ws+'│';



{ws:='│'+Ef^.Dat.Document+'│'+Ef^.Dat.DateC+'│'+Ef^.Dat.Kol+'│'+ws1+'│'+ws+'│';}

ws1:=GetOperatorName(Ef^.Dat.Caption);
Format(ws1,CKto);

ws:=ws+ws1+'│';
Case 0 Of
1:ws1:='  ';
0:ws1:='Ok';
Else ws1:='??';
End;
ws:=ws+ws1+'│';
ws:=ws+CaptionTested+'│'+Ef^.Dat.TimeC+'│'+DateT+'│'+TimeT+'│'+Comment;

NoScr^.List^.Insert(NewStr(ws));
NoScr^.SetRange(NoScr^.List^.Count);
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
VRwz^.Insert(ControlIKol);

Dispose(ControlIRZ,Done);
R.Assign(64, 22, 79, 23);
ControlIRZ := New(PColoredText, Init(R, #3+AllSR, $4E));
VRwz^.Insert(ControlIRZ);

Sorting(LocSort);
NoInfoMsg;
Redraw;
End;

procedure TViewRwzWindow.Sorting(LocSort : Word);
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
1:Begin
   ws1:=Copy(ws,1+1+CDocNumer+1+CDAte+1+CKol+1+1,CZena);
   ws:=ws1+ws;
  End;

{Раздел}
0:Begin
   ws1:=Copy(ws,1+1+CDocNumer+1+CDAte+1,CKol+1);
   If Pos('-',ws1)>0 Then
                         Begin
                          System.Delete(ws1,Pos('-',ws1),1);
                          RFormat(ws1,CKol+1);
                          ws1[1]:='-';
					End;
   ws:=ws1+ws;
  End;
{Дата поступления}
2:Begin
   ws1:=Copy(ws,1+1+CDocNumer+1,CDate);
   ws2:=Copy(ws,1+1+CDocNumer+1+CDAte+1+(CKol+1)+1+CZena+1+CIZena+1+CKto+1+CRazdelKod+1+CRazdelKod,CDate);{время}
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
1:
  Begin
   System.Delete(ws,1,CZena);
  End;
{количество}
0:Begin
   System.Delete(ws,1,CKol+1);
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
PrhList^.HelpCtx:=$F077;

Dispose(TempBox,Done);
NoInfoMsg;
PrevLine[0]:=#0;
End;

Procedure TViewRwzWindow.FullPrevView;
Var Ass : DocumentEdit;
    E : PRewisiaType;
    R : TRect;
    f : RewisiaFileType;
    c,i : Word;
    P : PBox;
    s,ws : TMyString;
    Find : Boolean;
    SDoc : ArtikulStr;
    SDate,swspom : TDateString;
    ws1,WspomSkidka:String[CIZena];

Begin
If (PrhList^.List<>Nil)And(PrhList^.List^.Count>=1) Then
Begin
  Ass.EditPosition:=Copy(PrhList^.GetText(PrhList^.Focused,PrhList^.List^.Count),1+1,CDocNumer);
  DelSpace(Ass.EditPosition);
  DelZerro(Ass.EditPosition);
  Ass.D:=Copy(PrhList^.GetText(PrhList^.Focused,PrhList^.List^.Count),1+1+CDocNumer+1,CDate);
  DelSpace(Ass.D);
  DelSpace(Ass.D);
  SDate:=Ass.D;
  SDoc:=Ass.EditPosition;
  Assign(f,Path.ToRewisia+Ass.d+'.rwz');
  c:=IOResult;
  Reset(f);
  c:=IOResult;
  If c<>0 Then
  Begin
   MessageBox(#3^M+#3'Ошибка доступа к файлу '+Path.ToRewisia+Ass.d+'.rwz',Nil,mfError+mfCancelButton);
   Exit;
  End;

  DInfoMsg('Ищу документ...');
  New(E,Init);
  Find := False;
  ClearChar(Ass.EditPosition);
  While Not(Eof(f)) And Not(Find) Do
   Begin
   ReadRewisia(F,E);
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
P^.NewList(New(PTextCollection, Init(0,1)));
For c:=1 To E^.Dat.Amount Do
 Begin
{If StrToInt(E^.Dat.Element[c].Input.Kol)<>0 Then}
Begin
  S:=E^.Dat.Element[c].BazKod;
  ws:=GetIdField(FName,s);
  Format(ws,CName);
  s:=ws+'│'+s;
  {
  ws:=GetIdField(FInPack,E^.Dat.Element[c].BazKod);
  RFormat(ws,CInPack);
  s:=s+'│'+ws;


  ws:=GetIdField(FLitr,E^.Dat.Element[c].BazKod);
  RFormat(ws,CInPack);
  s:=s+'│'+ws;
  }

  For i:=1 To CDivision Do
   Begin
    DelSpace(E^.Dat.Element[c].Input.DivisionS[i]);
    RFormat(E^.Dat.Element[c].Input.DivisionS[i],CKol+1);
    s:=s+'│'+E^.Dat.Element[c].Input.DivisionS[i];
   End;
{
  DelSpace(E^.Dat.Element[c].Input.Kol);
  RFormat(E^.Dat.Element[c].Input.Kol,CKol+1);
  s:=s+'│'+E^.Dat.Element[c].Input.Kol;

}
  DelSpace(E^.Dat.Element[c].Input.R_Zena);
  RFormat(E^.Dat.Element[c].Input.R_Zena,CZena);
  s:=s+'│'+E^.Dat.Element[c].Input.R_Zena+'│';
{
  swspom:=E^.Dat.Element[c].Input.Kol;
  If Pos('-',swspom)>0 Then System.Delete(swspom,Pos('-',swspom),1);
  ws:=CalcPack(E^.Dat.Element[c].BazKod,swspom);
  DelSpace(ws);
  If StrToInt(E^.Dat.Element[c].Input.Kol)<0 Then
   Begin
    ws:='-('+ws+')';
   End;
  Format(ws,CPAck);

  s:=s+'│'+ws;
 }
  P^.List^.Insert(NewStr(s));
  P^.SetRange(P^.List^.Count);
 End;
 End;
P^.FocusItem(0);
NoInfoMsg;
s:=E^.Dat.Itogo;
DelSpace(s);
s:=' Всего: '+s+' в том числе ';
DelSpace(E^.Dat.ItogoPlus);
s:=s+' Приход'+': '+E^.Dat.ItogoPlus;
DelSpace(E^.Dat.ItogoMinus);
s:=s+' Расход: '+E^.Dat.ItogoMinus;
                   {Вставить номер и дату документа в просмотре}
FullScreen(P,'Наименование товара         Код  Колич1 Колич2 Колич3 Колич4 Колич5 Р/Цена',s,
             {12345678901234567890123456│12345│123456│123456│123456│123456│123456│12345678}
SDoc,SDAte,0);
Dispose(E,Done);
Dispose(P,Done);
    End{Find}
Else
  Begin
  NoInfoMsg;
  MessageBox(#3^M+#3'Документ не найден!',Nil,mfError+mfCancelButton);
  Dispose(E,Done);
  End;
End;{P^.List}
End;

procedure TViewRwzWindow.FormReport(E:PBox);
Const SPace = '         ';
Var txt : Text;
    i,c : Word;
    ws,s1 : String;
Begin
 WordToBit3(LocOperation,SLocOperation);
 Convert3(SLocOperation);

 Assign(txt,Path.ToTemp+'strwz.txt');
 i:=IOResult;
 Rewrite(txt);
 i:=IOResult;
 If i<>0 Then
  Begin
   MessageBox(^M+#3'Ошибка создания '+Path.ToTemp+'strwz.txt'+
   ^M+#3+ClicProgrammer,Nil,mfError+mfCancelButton);
   Exit;
  End;
 DInfoMsg('Формирую отчет. Ждите...');

 Writeln(Txt,Space+'Склад: ',GetClientField(FClient,Rek.Kod,1)+'  Оператор: '+CurrentPassword+' EYE & 1997-98');

 Writeln(txt,Space+'Включены в рассмотрение следующие виды операций:');
 Write(txt,Space);
 Write(txt,' "Склад" ');
 Writeln(txt);
 Write(txt,Space+'Вид сортировки:');
    Case LocSort Of
    0:WriteLn(txt,' "Количество" ');
    1:WriteLn(txt,' "Цена" ');
    2:WriteLn(txt,' "Дата" ');
    Else;
    End;
 Writeln(txt,Space+Bold[NPrint.Printer]+'     СПРАВКА ПО РЕВИЗИЯМ ТОВАРА ЗА ПЕРИОД С '+StartDateTov+' ПО '+StopDateTov+
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

 Writeln(txt,Space+'---------------------------------------------------------------------------');
 Writeln(txt,Space+'  Док   Дата   Колич.   Р/Цена     Итого по РЦ   Оператор  Прв   Проверил');
                   { 1234│12-45-78│123456│12345678│123456789012345│123456789012│12│123456789012}
 Writeln(txt,Space+'---------------------------------------------------------------------------');
If E^.List^.Count>0 Then
Begin
 For c:=0 To E^.List^.Count-1 Do
 Begin
  ws:=E^.GetText(c,E^.List^.Count);
  s1:=Copy(ws,1+1+CDocNumer+1+CDate+1+(CKol+1)+1+CZena+1+CIZena+1+CKto+1,CRazdelKod);
  If s1='Ok' Then
   Begin
    s1:=Copy(ws,1+1+CDocNumer+1+CDate+1+(CKol+1)+1+CZena+1+CIZena+1+CKto+1+CRazdelKod+1,CRazdelKod);
    s1:=GetOperatorName(s1)
   End
     Else s1[0]:=#0;
  Format(s1,CKto);
  While Pos('│',ws)>0 Do ws[Pos('│',ws)]:=' ';
  ws[0]:=Chr(1+CDocNumer+1+CDate+1+(CKol+1)+1+CZena+1+CIZena+1+CKto+1+CRazdelKod+1);
 Writeln(txt,Space+ws+s1);
 End;
End;
 Writeln(txt,Space+'---------------------------------------------------------------------------');


PStaticText(ControlIKol)^.GetText(ws);
System.Delete(ws,1,1);
DelSpace(ws);
RFormat(ws,CIZena);

 Writeln(txt,Space+'                                       Всего ревизия: '+ws);

PStaticText(ControlIRZ)^.GetText(ws);
System.Delete(ws,1,1);
DelSpace(ws);

 Writeln(txt,Space+'                                    Всего по Р/Ценам: '+
 Recogniz(RealToStr(StrToReal(ws),CIZena,CMAntissa)));

 Writeln(txt);
 Writeln(txt,Space,'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
 Writeln(txt,Space+'===========================================================================');

 System.Close(txt);
 NoInfoMsg;
 Report(Path.ToTemp+'strwz.txt','',1,False,False,false);
End;

procedure TViewRwzWindow.HandleEvent(var Event: TEvent);

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
                Assistent.EditPosition:=Copy(PrhList^.GetText(PrhList^.Focused,PrhList^.List^.Count),1+1,CDocNumer);
                DelSpace(Assistent.EditPosition);
                DelZerro(Assistent.EditPosition);
                Assistent.D:=Copy(PrhList^.GetText(PrhList^.Focused,PrhList^.List^.Count),1+1+CDocNumer+1,CDate);
                DelSpace(Assistent.D);
                If MessageBox(^M+#3'Печатать акт ревизии N '+Assistent.EditPosition+' от '+Assistent.D+'?',Nil,
			 mfConfirmation+mfOKCancel)=cmOk Then
                PrintRewisia(Assistent);
            End
            End;
 cmReestrReport:    Begin
                 ClearFind;
     If (PrhList^.State and sfFocused <> 0) And (PrhList^.List<>Nil)And(PrhList^.List^.Count>=1) Then
            Begin
             FormReport(PrhList);
            End
            End;
      Else;
      End;{evCommand}
      Else;
      End;{*Case*}
  if (Event.What = evBroadcast) and
    (Event.Command = cmRwz) then ClearEvent(Event);

  if (Event.What = evBroadcast) and
    (Event.Command = cmQuit) then ClearEvent(Event);

inherited HandleEvent(Event);

  If (Desktop^.Current=PView(VRwz)) And (Event.What <> EvKeyDown) Then
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

Procedure FormReportS(Const Cl,Agent,NoScreenList,NMakeList:PBox;
StartDateTov,StopDateTov:TDAteString;VidReport:Word;Var txt,er:Text);
Var Space : AllStr;
    ItogKol,ItogSum,s1,s2,s3,s4,s5,s6,s7 : AllStr;
    Cur : LongInt;
    s   : TMyString;
    wsd : TDateString;
    i : Word;
    AllMrk,AllReturn,AllRealiz:LongInt;
    AllMrkS,AllMrkSZ,AllReturnS,AllReturnSZ,AllRealizS : Real;
Begin
    AllMrk:=0;
    AllReturn:=0;
    AllRealiz:=0;
    AllMrkS:=0;
    AllMrkSZ:=0;
    AllReturnS:=0;
    AllReturnSZ:=0;
    AllRealizS:=0;;

Space[0]:=#0;
Writeln(Txt,Space+'Оператор: '+CurrentPassword+' EYE & 1997-01');

 WriteLn(Txt,Space+'ОТЧЕТ О РЕАЛИЗАЦИИ ВЫБРАННЫХ ПОЗИЦИЙ ТОВАРА ЗА ПЕРИОД С '+StartDatetov+' ПО '+StopDatetov+'('+FDate+' '+
 Times+')');


If (Agent^.List^.Count)>=1 Then
Begin
 Writeln(txt);
 Writeln(txt,Space+'Выбранные агенты:');
 For cur:=0 To Agent^.List^.Count-1 Do
  Begin
   s:=Agent^.GetText(cur,Agent^.List^.Count);
   s:=Copy(s,1+1,CClientKod);
   Writeln(txt,Space+GetAgentField(FClient,s)+' ('+s+')');
  End;
End;

If MessageBox(^M+#3'Указать клиентов?',Nil,mfConfirmation+mfOkCancel)=cmOk Then
If (Cl^.List^.Count)>=1 Then
Begin
 Writeln(txt);
 Writeln(txt,Space+'Выбранные клиенты:');
 For cur:=0 To Cl^.List^.Count-1 Do
  Begin
   s:=Cl^.GetText(cur,Cl^.List^.Count);
   s:=Copy(s,1+1,CClientKod);
   Writeln(txt,Space+GetClientField(FClient,s,0)+' ('+s+')');
  End;
End;


 Writeln(txt,Space+
                   '┌─────────────────────────┬─────┬───────┬─────────────┬─────┬─────────────┬──────┬────────────┐');

If VidReport=0 Then
 Writeln(txt,Space+'│Наименование товара      │ Код │ Колич.│ Сумма к опл.│Колич│ Сумма возвр.│Колич.│Итого реализ│')
                   {12345678901234567890123456│12345│123456│1234567890123│12345│1234567890123│123456│123456789012}
Else
Begin
 Writeln(txt,Space+'│Наименование товара      │ Код │ Колич.│ Сумма к опл.│Колич│ Сумма возвр.│Колич.│Итого Доход │');
 Writeln(txt,Space+'│                         │     │       │             │     │             │      │с учетом взв│');
End;
 Writeln(txt,Space+'└─────────────────────────┴─────┴───────┴─────────────┴─────┴─────────────┴──────┴────────────┘');

 For cur:=0 To NoScreenList^.List^.Count-1 Do
  Begin
   s:=NoScreenList^.GetText(cur,NoScreenList^.List^.Count);
   s1:=Copy(s,1,CName+1+CArtikul+1);

   While Pos('│',s1)>0 Do s1[Pos('│',s1)]:=SeparatorChar;


   S2:=Copy(s,1+CName+1+CArtikul+1,(CKol+1));

   AllMrk:=AllMrk+StrToInt(s2);

   {реализация по ценам к оплате}
   S3:=Copy(s,1+CName+1+CArtikul+1+(CKol+1)+1,CIZena);
   MyStr(StrToReal(s3),(CIZena-2),CMAntissa,S3);
   AllMrkS:=AllMrkS+StrToReal(s3);

   S4:=Copy(s,1+CName+1+CArtikul+1+(CKol+1)+1+CIZena+1+CIZena+1,(CKol+1));
   AllReturn:=AllReturn+StrToInt(s4);

   {возврат по ценам к оплате}
   s5:=Copy(s,1+CName+1+CArtikul+1+(CKol+1)+1+CIZena+1+CIZena+1+(CKol+1)+1,CIZena);
   MyStr(StrToReal(s5),(CIZena-3),CMAntissa,S5);
   AllReturns:=AllReturns+StrToReal(s5);

   Str(StrToInt(s2)-StrToInt(s4):(CKOl+1),ItogKol);
   AllRealiz:=AllRealiz+StrToInt(ItogKol);

   MyStr(StrToReal(s3)-StrToReal(s5),(CIZena-3),CMAntissa,ItogSum);

If VidReport=1 Then
Begin
   {реализация по ценам закупки}
   S6:=Copy(s,1+CName+1+CArtikul+1+(CKol+1)+1+CIZena+1,CIZena);
   MyStr(StrToReal(s6),(CIZena-2),CMAntissaZ,S6);
   AllMrkSZ:=AllMrkSZ+StrToReal(s6);

   {возврат по ценам закупки}
   s7:=Copy(s,1+CName+1+CArtikul+1+(CKol+1)+1+CIZena+1+CIZena+1+(CKol+1)+1+CIZena+1,CIZena);
   MyStr(StrToReal(s7),(CIZena-3),CMAntissaZ,S7);
   AllReturnsZ:=AllReturnsZ+StrToReal(s7);
         {доход от реализации}
   MyStr((StrToReal(s3)-StrToReal(s6))
         {упущенный доход по возврату}
        -(StrToReal(s5)-StrToReal(s7)),(CIZena-3),CMAntissaZ,ItogSum);
End;

   AllRealizS:=AllRealizS+StrToReal(ItogSum);

   Writeln(txt,Space+s1+s2+SeparatorChar+s3+SeparatorChar+s4+SeparatorChar+
   s5+SeparatorChar+ItogKol+SeparatorChar+ItogSum);
  End;


 Writeln(txt,Space+'──────────────────────────────────────────────────────────────────────────────────────────────');


 Writeln(txt,Space+'Всего позиций: ',NoScreenList^.List^.Count:CKol);
 Writeln(txt,Space+'Всего продано: ',AllMrk:(CKOl+1),' на сумму: ',RecognizReal(AllMrkS,CIZena,CMantissa));
 Writeln(txt,Space+'Всего возврат: ',AllReturn:(CKOl+1),' на сумму: ',RecognizReal(AllreturnS,CIZena,CMantissa));

 If VidReport=1 Then
 Begin
  If Abs(AllMrkSZ-AllReturnSZ)>0.00009 Then
  AllMrkS:=AllRealizS/(AllMrkSZ-AllReturnSZ)*100
  Else
  AllMrkS:=0;

  Writeln(txt,Space+'Всего реализовано с учетом возврата: ',AllRealiz:(CKOl+1),' с доходом: ',RecognizReal(AllRealizS,CIZena,
  CMantissaZ)+' (',AllMrkS:CZena:CMantissa,' %)');
 End
 Else
  Writeln(txt,Space+'Всего реализовано с учетом возврата: ',AllRealiz:(CKOl+1),' на сумму: ',RecognizReal(AllRealizS,CIZena,
 CMantissa));

  Writeln(txt);

system.Close(er);
i:=IoResult;
Reset(er);
i:=IoResult;
If IOResult=0 Then
Begin
If Not(Eof(er)) Then
 Begin
  Writeln(txt);
  Writeln(txt,'[Примечание]');
 End;

While Not(Eof(er)) Do
Begin
 Readln(er,s);
 Writeln(txt,Space+s);
End;
System.Close(er);
End;
i:=IoResult;


 Writeln(Txt,Space+'"'+DayString[DayOfWeek(ToDay)]+'" '+FDate+'('+Times+')');
 Writeln(Txt,Space+'==============================================================================================');

System.Close(txt);
i:=IoResult;

End;{Procedure}




Destructor TViewRwzWindow.Done;
Begin
TDialog.Done;
End;

End.