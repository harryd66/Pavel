{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}


Unit ClCrView;

INTERFACE

Uses Glob,Dialogs,ServStr,MyCalc,Drivers;

Type
  PClientCorrectView = ^TClientCorrectView;
  TClientCorrectView = object(TDialog)
      Calc        : PMyCalculator;
      Procedure PrintCorrClient(const E:PBox);
      Function ViewClCorrect(Kod:ArtikulStr;Reg,Sel:Byte):Boolean;
      procedure HandleEvent(var Event: TEvent); virtual;
      Destructor Done;Virtual;
  end;

{procedure TestClCor;}


IMPLEMENTATION

{$I Compile.INC}


Uses Serv,Objects,Views,App,TPDate,
     DbEngine,DbEngin3,NetDBeng,MsgBox,Validate,ColorTxt,
     x_dialog,tools,Printers;

var ClBox:PBox;
    NoScreen: PBox;
    ClCorrWin: PClientCorrectView;
    ControlDebitList1,ControlOtgruskaList1:PMyListBox;
    F : ClientFileType;
    _Reg,_Sel: byte;
    _Kod: string[CCLientKod];


Procedure TClientCorrectView.PrintCorrClient(const E:PBox);
const Space = ' ';

var t: text;
    i,IORez: word;
    s: string;
Begin
  if (E<>nil) and (E^.List^.Count>0) then
  begin
    Assign(t,Path^.Dat.ToTemp+'clcorr.txt');
    IOrez:=ioresult;
    Rewrite(t);
    IOrez:=ioresult;
    if iorez<>0 then
    begin
     MessageBox(^M+#3'Не могу создать файл отчета '+Path^.Dat.ToTemp+'clcorr.txt',Nil,mfError+mfCancelButton);
     exit;
    end;

Writeln(t,Header+Space+'Склад: ',GetClientField(FClient,Rek^.Dat.Kod,1)+'  Оператор: '+CurrentPassword);
writeln(t,Space+'                    ХРОНОЛОГИЯ КОРРЕКТИРОВОК КЛИЕНТА '+_kod);
writeln(t,Space+'┌───────┬────────┬────────────┬────────────────────┬────────────────────┬──┐');
writeln(t,Space+'│ Дата  │ Время  │ Оператор   │ Название           │ Юр.название        │В │');
writeln(t,Space+'└───────┴────────┴────────────┴────────────────────┴────────────────────┴──┘'+HeaderStop);

    for i:=0 to E^.List^.Count-1 do
    begin
      s:=E^.GetText(i,E^.List^.Count);
      writeln(t,Space+s);
    end;
     Writeln(t,Space+' ---------------------------------------------------------------------------- ');
     Writeln(t);
     Writeln(t,Space,'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
     Writeln(t,Space+' ============================================================================ ');

    System.Close(t);
    {ViewAsText(Path^.Dat.ToTemp+'clcorr.txt','Справка по корректировке клиентской базы ',False);}
    ReportNew(Path^.Dat.ToTemp+'clcorr.txt','',NprintC^.DAt.CopyAll,False,False);
  end;
End;

Procedure ViewElementCorr(var ClientFile : ClientFileType; ver:word; Reg,Sel:Byte);
Label 1;
var
  R : TRect;
  Control : PView;
  s : TEnjoyStr;{!!!}
  sss : String;
  j,c: Word;
  k : LongInt;
  Dlg : PDialog;
  Event:TEvent;
  Count : Word;
  st,ss,SRegName,SRouteNAme : String[CAll];
  SArtik : ArtikulStr;
  ClientElement : ClientType;
begin

c:=ioresult;
Reset(ClientFile);
c:=ioresult;
Seek(ClientFile,ver);
c:=ioresult;
if c<>0 then
begin
  exit;
end;

ReadClient(ClientFile,ClientElement);

{System.Close(ClientFile);}


ClientElement.BankKod:=IntToStr(StrToInt(ClientElement.BankKod),CCLientKod);
RFormatZerro(ClientElement.BankKod,CClientKod);

ClientElement.RouteKod:=IntToStr(StrToInt(ClientElement.RouteKod),CClientKOd);
RFormatZerro(ClientElement.RouteKod,CClientKOd);

ClientElement.RegionKod:=IntToStr(StrToInt(ClientElement.RegionKod),CClientKOd);
RFormatZerro(ClientElement.RegionKod,CClientKOd);

ClientElement.FantomKod:=IntToStr(StrToInt(ClientElement.FantomKod),CClientKOd);
RFormatZerro(ClientElement.FantomKod,CClientKOd);

ClientElement.Kod:=IntToStr(StrToInt(ClientElement.Kod),CClientKOd);
RFormatZerro(ClientElement.Kod,CClientKOd);


R.Assign(0, 0, 80, 23);
If Reg in [bClient,bMAke] Then
New(Dlg, Init(R, 'Контрагент'));

If Reg in [bAgent] Then
New(Dlg, Init(R, 'Агент'));

If Reg in [bEksped] Then
New(Dlg, Init(R, 'Экспедитор'));


Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.Palette := dpCyanDialog;
Dlg^.HelpCtx:=$F991;

R.Assign(9, 1, 31, 2);
Control := New(PInputLine, Init(R, CClient));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);

  R.Assign(1, 1, 9, 2);
Case Reg Of
bClient: Dlg^.Insert(New(PLabel, Init(R, 'К~л~иент:', Control)));
bMake: Dlg^.Insert(New(PLabel, Init(R, 'Постав:', Control)));
bAgent: Dlg^.Insert(New(PLabel, Init(R, ' Агент:', Control)));
bEksped: Dlg^.Insert(New(PLabel, Init(R, 'Экспед:', Control)));
Else;
End;

R.Assign(39, 1, 47, 2);
Control := New(PInputLine, Init(R, CIZena));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);

  R.Assign(34, 1, 39, 2);
  Dlg^.Insert(New(PLabel, Init(R, 'VIP:', Control)));

R.Assign(54, 1, 61, 2);
Control := New(PInputLine, Init(R, CIZena));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);

  R.Assign(47, 1, 54, 2);
  Dlg^.Insert(New(PLabel, Init(R, 'Ли~м~ит:', Control)));

R.Assign(69, 1, 79, 2);
Control := New(PInputLine, Init(R, CDAte));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PPXPictureValidator, Init('[##-##-##]', True));

  R.Assign(61, 1, 69, 2);
  Dlg^.Insert(New(PLabel, Init(R, 'Сверка:', Control)));

R.Assign(9, 2, 52, 3);
Control := New(PRadioButtons, Init(R,
  NewSItem('Акт',NewSItem('~П~ас',NewSItem('~С~Б',NewSItem('~З~акр',NewSItem('?', Nil)))))));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);

  R.Assign(1, 2, 9, 3);
  Dlg^.Insert(New(PLabel, Init(R, 'Статус:', Control)));

R.Assign(61, 2, 66, 3);
Control := New(PInputLine, Init(R, CLitrMantissa));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['0','1','2','3','4','5','6','7','8','9']));

  R.Assign(53, 2, 61, 3);
  Dlg^.Insert(New(PLabel, Init(R, 'Пери~о~д:', Control)));


R.Assign(73, 2, 79, 3);
Control := New(PInputLine, Init(R, CClientKod));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['0','1','2','3','4','5','6','7','8','9']));

  R.Assign(66, 2, 73, 3);
  Dlg^.Insert(New(PLabel, Init(R, 'КОД1С:', Control)));


R.Assign(4, 3, 24, 4);
Control := New(PColoredText, Init(R, 'Реквизиты партнера', $4F));
Dlg^.Insert(Control);

R.Assign(4, 4, 77, 13);
Control := New(PColoredText, Init(R, '', $3E));
Control^.Options := Control^.Options or ofFramed;
Dlg^.Insert(Control);

R.Assign(4, 13, 27, 14);
Control := New(PColoredText, Init(R, 'Реквизиты контрагента', $4F));
Dlg^.Insert(Control);

R.Assign(18, 4, 65, 5);
Control := New(PInputLine, Init(R, CAll));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);

  R.Assign(4, 4, 18, 5);
  Dlg^.Insert(New(PLabel, Init(R, 'Полн.назв~а~н.:', Control)));

R.Assign(18, 5, 65, 6);
Control := New(PInputLine, Init(R, CAll));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);

  R.Assign(9, 5, 18, 6);
  Dlg^.Insert(New(PLabel, Init(R, 'Адрес Ю:', Control)));


R.Assign(18, 6, 42, 7);
Control := New(PInputLine, Init(R, CAll));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);

  R.Assign(6, 6, 18, 7);
  Dlg^.Insert(New(PLabel, Init(R, 'N Дого~в~ора:', Control)));

R.Assign(47, 6, 65, 7);
Control := New(PRadioButtons, Init(R,
  NewSItem('Юр.',
  NewSItem('Физ.', Nil))));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);

  R.Assign(42, 6, 47, 7);
  Dlg^.Insert(New(PLabel, Init(R, 'В~и~д:', Control)));

R.Assign(18, 7, 39, 8);
Control := New(PInputLine, Init(R, CNAme));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);

  R.Assign(13, 7, 18, 8);
  Dlg^.Insert(New(PLabel, Init(R, 'И~Н~Н:', Control)));



R.Assign(44, 7, 65, 8);
Control := New(PInputLine, Init(R, CName));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);

  R.Assign(39, 7, 44, 8);
  Dlg^.Insert(New(PLabel, Init(R, 'КПП:', Control)));


{банк}

R.Assign(59, 8, 65, 9);
Control := New(PROInputLine, Init(R, CClientKod));
Control^.Options := Control^.Options and not ofFirstClick;
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);

  R.Assign(12, 8, 18, 9);
  Dlg^.Insert(New(PLabel, Init(R, 'Банк:', Control)));

R.Assign(18, 8, 60, 9);
RFormatZerro(ClientElement.BankKod,CClientKod);
ss:=GetBankField(FBank,ClientElement.BankKod);
Format(ss,40);
Control := New(PColoredText, Init(R, ' '+ss+'│', $13));
Dlg^.Insert(Control);


R.Assign(18, 9, 36, 10);
Control := New(PInputLine, Init(R, CAll));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);

  R.Assign(10, 9, 18, 10);
  Dlg^.Insert(New(PLabel, Init(R, 'Р/Счет:', Control)));


R.Assign(43, 9, 51, 10);
Control := New(PInputLine, Init(R, CName));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);

  R.Assign(36, 9, 43, 10);
  Dlg^.Insert(New(PLabel, Init(R, 'ОКОНХ:', Control)));

R.Assign(57, 9, 65, 10);
Control := New(PInputLine, Init(R, CNAme));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);

  R.Assign(51, 9, 57, 10);
  Dlg^.Insert(New(PLabel, Init(R, 'ОКПО:', Control)));

R.Assign(18, 10, 65, 11);
Control := New(PInputLine, Init(R, CAll));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);

  R.Assign(7, 10, 18, 11);
  Dlg^.Insert(New(PLabel, Init(R, 'Свид~е~т-во:', Control)));

R.Assign(18, 11, 65, 12);
Control := New(PInputLine, Init(R, CAll));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);

  R.Assign(8, 11, 18, 12);
  Dlg^.Insert(New(PLabel, Init(R, 'Ли~ц~ензия:', Control)));

R.Assign(18, 12, 47, 13);
Control := New(PInputLine, Init(R, CAll));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);

  R.Assign(10, 12, 18, 13);
  Dlg^.Insert(New(PLabel, Init(R, 'Выдана:', Control)));

R.Assign(55, 12, 65, 13);
Control := New(PInputLine, Init(R, CDate));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);

  R.Assign(46, 12, 55, 13);
  Dlg^.Insert(New(PLabel, Init(R, 'Сро~к~ до:', Control)));

R.Assign(66, 4, 76, 13);
Control := New(PCheckboxes, Init(R,
  NewSItem('Сп  ',
  NewSItem('Тч ',
  NewSItem('ФЛ  ',
  NewSItem('СФ* ',
  NewSItem('СФБ ',
  NewSItem('Д*  ',
  NewSItem('ДСФ ',
  NewSItem('Д   ',
  NewSItem('ДСФБ', Nil)))))))))));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);


R.Assign(10, 14, 38, 15);
Control := New(PInputLine, Init(R, CName));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);

  {R.Assign(2, 14, 11, 15);}
  R.Assign(1, 14, 10, 15);
  Dlg^.Insert(New(PLabel, Init(R, 'Телефон:', Control)));

{R.Assign(69, 14, 79, 15);}
R.Assign(50, 14, 60, 15);
Control := New(PInputLine, Init(R, CSeriaPassport));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);

  {R.Assign(57, 14, 69, 15);}
  R.Assign(38, 14, 50, 15);
  Dlg^.Insert(New(PLabel, Init(R, 'Серия пасп:', Control)));

{R.Assign(5, 15, 17, 16);}
R.Assign(63, 14, 75, 15);
Control := New(PInputLine, Init(R, CNumerPassport));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);

  {R.Assign(2, 15, 5, 16);}
  R.Assign(60, 14, 63, 15);
  Dlg^.Insert(New(PLabel, Init(R, 'N:', Control)));

{R.Assign(22, 15, 49, 16);}
R.Assign(6, 15, 31, 16);
Control := New(PInputLine, Init(R, Call));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);

  {R.Assign(17, 15, 22, 16);}
  R.Assign(1, 15, 6, 16);
  Dlg^.Insert(New(PLabel, Init(R, 'Кем:', Control)));

{R.Assign(13, 16, 42, 17);}
R.Assign(35, 15, 57, 16);
Control := New(PInputLine, Init(R, CAll));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);

  {R.Assign(1, 16, 13, 17);}
  R.Assign(31, 15, 35, 16);
  Dlg^.Insert(New(PLabel, Init(R, 'ИП:', Control)));

{R.Assign(53, 16, 79, 17);}
R.Assign(61, 15, 79, 16);
Control := New(PInputLine, Init(R, CAll));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);

  {R.Assign(42, 16, 53, 17);}
  R.Assign(57, 15, 61, 16);
  Dlg^.Insert(New(PLabel, Init(R, 'ДП:', Control)));

{R.Assign(53, 17, 79, 18);}
R.Assign(10, 16, 40, 17);
Control := New(PInputLine, Init(R, CAll));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);

  {R.Assign(44, 17, 53, 18);}
  R.Assign(1, 16, 10, 17);
  Dlg^.Insert(New(PLabel, Init(R, 'Адрес ~Ф~:', Control)));

R.Assign(46, 16, 79, 17);
Control := New(PInputLine, Init(R, CSertif));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);

  R.Assign(40, 16, 46, 17);
  Dlg^.Insert(New(PLabel, Init(R, 'Авто:', Control)));


{R.Assign(13, 17, 44, 18);}
R.Assign(12, 17, 79, 18);
Control := New(PInputLine, Init(R, CSertif));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);

  {R.Assign(2, 17, 13, 18);}
  R.Assign(1, 17, 12, 18);
  Dlg^.Insert(New(PLabel, Init(R, 'Сообщение:', Control)));



{R.Assign(13, 18, 18, 19);}
R.Assign(13, 18, 18, 19);
Control := New(PInputLine, Init(R, CLitrMantissa));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);

  {R.Assign(2, 18, 13, 19);}
  R.Assign(2, 18, 13, 19);
  Dlg^.Insert(New(PLabel, Init(R, 'Delta Max:', Control)));



If Reg in [bClient,bMAke] Then
Begin
R.Assign(18, 18, 32, 19);
Control := New(PCheckboxesLong, Init(R,
NewSItem('Отгр~у~зка', Nil)));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);


R.Assign(42, 18, 79, 22);
ControlDebitList1 := New(PMyListBox, Init(R, 'X', 4, Nil,True{ReadOnly=True}));
ControlDebitList1^.NewList(New(PCollection, Init(0,1)));

For c:=1 To Max30 Do
 Begin
  St:=IntToStr(C,CMantissa);
  RFormatZerro(st,CMantissa);
  ControlDebitList1^.List^.Insert(New(PStringO,Init(st)));
  ControlDebitList1^.SetRange(ControlDebitList1^.List^.Count);
 End;
ControlDebitList1^.Options := ControlDebitList1^.Options and not ofSelectable;
Dlg^.Insert(ControlDebitList1);

  R.Assign(32, 18, 42, 19);
  Dlg^.Insert(New(PLabel, Init(R, 'Отсро~ч~ка:', ControlDebitList1)));
End;


If Reg in [bAgent,bEksped] Then
Begin
R.Assign(42, 18, 79, 21);
ControlOtgruskaList1 := New(PMyListBox, Init(R, 'X', 5, Nil,True{ReadOnly=True}));
ControlOtgruskaList1^.NewList(New(PCollection, Init(0,1)));

For c:=1 To Max30 Do
 Begin
  St:=IntToStr(C,CMantissa);
  RFormatZerro(st,CMantissa);
  ControlOtgruskaList1^.List^.Insert(New(PStringO,Init(st)));
  ControlOtgruskaList1^.SetRange(ControlOtgruskaList1^.List^.Count);
 End;
ControlOtgruskaList1^.Options := ControlOtgruskaList1^.Options and not ofSelectable;
Dlg^.Insert(ControlOtgruskaList1);

  R.Assign(32, 18, 42, 19);
  Dlg^.Insert(New(PLabel, Init(R, 'Отгр~у~зка:', ControlOtgruskaList1)));

R.Assign(42, 21, 56, 22);
Control := New(PCheckboxesLong, Init(R,
  NewSItem('Отсро~ч~ка', Nil)));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);
End;


R.Assign(36, 19, 42, 20);
Control := New(PROInputLine, Init(R, CClientKod));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);

  R.Assign(1, 19, 9, 20);
  Dlg^.Insert(New(PLabel, Init(R, '~Р~егион:', Control)));

R.Assign(9, 19, 37, 20);
RFormatZerro(ClientElement.RegionKod,CClientKod);
ss:=GetRegionField(FName,ClientElement.RegionKod);
Format(ss,CNAme);
Control := New(PColoredText, Init(R, ' '+ss+'│', $13));
Dlg^.Insert(Control);


R.Assign(36, 20, 42, 21);
Control := New(PROInputLine, Init(R, CClientKod));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);

  R.Assign(1, 20, 9, 21);
  Dlg^.Insert(New(PLabel, Init(R, 'Мар~ш~рут:', Control)));

R.Assign(9, 20, 37, 21);
RFormatZerro(ClientElement.RouteKod,CClientKod);
ss:=GetRouteField(FName,ClientElement.RouteKod);
Format(ss,CNAme);
Control := New(PColoredText, Init(R, ' '+ss+'│', $13));
Dlg^.Insert(Control);


R.Assign(1, 21, 15, 22);
Control := New(PCheckboxes, Init(R,
  NewSItem('Дочерний', Nil)));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);

R.Assign(36, 21, 42, 22);
RFormatZerro(ClientElement.FantomKod,CClientKod);
Control := New(PROInputLine, Init(R, CClientKod));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);

R.Assign(15, 21, 37, 22);
RFormatZerro(ClientElement.FantomKod,CClientKod);
Case Reg Of
bClient:ss:=GetClientField(FClient,ClientElement.FantomKod,Sel);
bMAke:ss:=GetMakeField(FClient,ClientElement.FantomKod,Sel);
bAgent:ss:=GetAgentField(FClient,ClientElement.FantomKod);
bEksped:ss:=GetEkspedField(FClient,ClientElement.FantomKod);
Else;
End;
Format(ss,CClient);
Control := New(PColoredText, Init(R, ' '+ss+'│', $13));
Dlg^.Insert(Control);



Dlg^.SetData(ClientElement);

  R.Assign(2, 0, 6, 1);
  Control := New(PColoredText, Init(R, 'Код:', $3E));
  Dlg^.Insert(Control);
  R.Assign(6, 0, 10, 1);
  Control := New(PColoredText, Init(R, ClientElement.Kod,$3E));
  Dlg^.Insert(Control);



  R.Assign(48, 0, 79, 1);
  Control := New(PColoredText, Init(R, #3+GetOperatorField(FName,ClientElement.LastCaption)+' '+
  DateToDateString(DateMask,ClientElement.DateM)+' '+TimeToTimeString('hh:mm:ss',ClientElement.TimeM), $5E));
  Dlg^.Insert(Control);

Dlg^.SelectNext(False);
c:=Desktop^.ExecView(Dlg);


Dispose(Control,Done);

If Reg in [bClient,bMAke] Then
Begin
 Dispose(PMyListBox(ControlDebitList1)^.List,Done);
End;

If Reg in [bAgent,bEksped] Then
Begin
 Dispose(PMyListBox(ControlOtgruskaList1)^.List,Done);
End;


Dispose(Dlg,Done);
end;




Function TClientCorrectView.ViewClCorrect(Kod:ArtikulStr;Reg,Sel:Byte):Boolean;
var
    cl: PClientType;
    IOrez,i: word;
    ws,s,sss:string;
    R: TRect;
    sDate:TDateString;
Begin

  _Reg:=Reg;
  _Sel:=Sel;
  _Kod:=Kod;

  ViewClCorrect:=false;

Case Reg of
bClient:
Case Sel Of
0:sss:=Path^.Dat.ToClient+ClientPrefix+kod+'.cor';
1:sss:=Path^.Dat.ToClient+SkladPrefix+kod+'.cor';
2:sss:=Path^.Dat.ToClient+BarterPrefix+kod+'.cor';
Else exit;
End;

bMake:
Case Sel Of
0:sss:=Path^.Dat.ToClient+MakePrefix+kod+'.cor';
1:sss:=Path^.Dat.ToClient+SkladPrefix+kod+'.cor';
2:sss:=Path^.Dat.ToClient+BarterPrefix+kod+'.cor';
Else Exit;
End;

bAgent:sss:=Path^.Dat.ToClient+AgentPrefix+kod+'.cor';

bEksped:sss:=Path^.Dat.ToClient+EkspeditorPrefix+kod+'.cor';

Else Exit;
End;

  R.Assign(0,0,0,0);
  NoScreen := New(PBox, Init(R, 1, Nil));
  NoScreen^.NewList(New(PTextCollection, Init(0,1)));

  DelSpace(kod);
  Assign(f,sss);
  IOrez:=ioresult;
  Reset(f);
  IOrez:=ioresult;
  if IORez<>0 then
  begin
    Dispose(NoScreen,Done);
    exit;
  end
  else
  while not eof(f) do
  begin
    new(cl,Init);
    Read(f,cl^.Dat);

    s:='';
    {s:=s+Cl^.Dat.Kod+'│';}
    {Дата}
    {s:=s+DateToDateString(DateMask,Cl^.Dat.DateM)+'│';}
    ws:=IntToStr(Cl^.Dat.DateM,CDate);
    rformat(ws,CDate);
    s:=s+ws+'│';
    {Время}
    ws:=IntToStr(Cl^.Dat.TimeM,CDate);
    rformat(ws,CDate);
    s:=s+ws+'│';
    {s:=s+TimeToTimeString(TimeMask,Cl^.Dat.TimeM)+'│';}
    {Оператор}
    {s:=s+Cl^.Dat.LastCaption+'│';}
    ws:=GetOperatorField(FNAme,Cl^.Dat.LastCaption);
    Format(Ws,CKto);
    s:=s+ws+'│';
    {Наименование}
    ws:=Cl^.Dat.Name;
    Format(Ws,CClient);
    s:=s+ws+'│';
    {Юр. наименование }
    ws:=Cl^.Dat.FullName;
    Format(Ws,CClient);
    s:=s+ws+'│';
    {Версия}
    ws:=IntToStr(FilePos(f),3);
    format(ws,2);
    s:=s+ws+'│';

    NoScreen^.List^.Insert(NewStr(s));
    NoScreen^.SetRange(NoScreen^.List^.Count);

    Dispose(cl,Done);
  end;

  IOrez:=ioresult;
  System.close(f);
  IOrez:=ioresult;

  R.Assign(1, 1, 79, 24);
  New(ClCorrWin, Init(R, 'Просмотр корректировок клиента '+Kod));
  ClCorrWin^.Options := ClCorrWin^.Options or ofCenterX or ofCenterY;
  ClCorrWin^.HelpCtx:=$F991;

  R.Assign(1,2,77,21);
  ClBox := New(PBox, Init(R, 1, Nil));
  ClBox^.NewList(New(PMyCollection, Init(0,1)));

  if (Noscreen<>nil) and (NoScreen^.List^.Count>0) then
  for i:=0 to NoScreen^.List^.Count-1 do
  begin
    s:=NoScreen^.GetText(i,NoScreen^.List^.Count);

    sDate:=copy(s,1,CDate);
    sDate:=DateToDateString(DateMask,StrToInt(sDate));
    System.Delete(s,1,CDate);
    s:=sDate+s;

    sDate:=copy(s,1+CDate+1,CDate);
    sDate:=TimeToTimeString(TimeMask,StrToInt(sDate));
    System.Delete(s,1+CDate+1,CDate);
    System.Insert(sDate,s,1+CDate+1);

    ClBox^.List^.Insert(NewStr(s));
    ClBox^.SetRange(ClBox^.List^.Count);
  end;

  ClCorrWin^.Insert(ClBox);

  R.Assign(1, 1, 77, 2);
  ClCorrWin^.Insert(New(PLabel, Init(R, '  Дата    Время    Оператор     Название             Юр.название         В',
  ClBox)));
                                        {12345678 12345678 123456789012 12345678901234567890 12345678901234567890 12}
  DeskTop^.ExecView(ClCorrWin);

  Dispose(ClBox,Done);
  Dispose(ClCorrWin,Done);
  Dispose(NoScreen,Done);
End;




procedure TClientCorrectView.HandleEvent(var Event: TEvent);

procedure Calculator;
begin
  Calc^.Start;
end;

var s: string;

Begin
 Case Event.What Of
  evCommand :
  Case Event.Command Of
  cmLocalCalc:Calculator;
  cmFullview: Begin
     If _Reg=0 Then
     Begin
      ViewElementCorr(F,ClBox^.Focused,_Reg,_Sel);
     End
     Else
     Begin
      ViewElementCorr(F,ClBox^.Focused,_Reg,_Sel);
     End;
     ClearEvent(Event);
      End;
  cmReestrReport: Begin
      ClearFind;
      if (ClBox<>Nil) and (ClBox^.List^.Count>0) then
      begin
       PrintCorrClient(ClBox);
      end;
      ClearEvent(Event);
     end;
 end;
end;

   if (Event.What = evBroadcast) and
    (Event.Command = cmQuit) then ClearEvent(Event);

 inherited HandleEvent(Event);
End;

Destructor TClientCorrectView.Done;
Begin
 inherited Done;
End;

{
procedure TestClCor;
begin
 clCorrWin^.ViewClCorrect('0791',0,0);
end;
}

BEGIN
END.
