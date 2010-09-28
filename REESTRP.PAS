{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}

{$I Compile.INC}

Unit ReestrP;

Interface


Uses Dialogs,Drivers,{Glob,}Access,ServStr,Barter;

Type
  PReestrPWindow = ^TReestrPWindow;
  TReestrPWindow = object(TDialog)
    PrhW : PPrihodBarterWindow;
    constructor Init(Var l: Boolean);
    procedure OpenReestrPWindow;
    procedure FullPreview;
    procedure HandleEvent(var Event: TEvent); virtual;
    Procedure FormPReport(Const p:PBox);
    procedure Refresh;
  end;


Implementation

uses Glob,DBEngine,Objects, Views, MsgBox,{Vision,Calc,}Dos,Vision1,TpDate,Vision2,UtilsP,
     App, ColorTxt,Serv,{InpLong,{Validate,}Tools,Printers,ComboBox,NetDbEng,Net,Utils;


var
 DocList : PBox;
 ControlStatus,Control,ControlSort,ControlAllDoc,ControlAllSumma,ControlAllZakupka: PView;
 PrevCur : TMyString;
 DocReestrPWindow:PReestrPWindow;
 StartDate,StopDAte,DocDate : TDateString;
 Status ,Sorting : Word;
 StartTime:LongInt;
 Start,Stop,RefreshTime:LongInt;
 AllDoc,AllZakupka,AllSumma : String[CIZena];


procedure TReestrPWindow.OpenReestrPWindow;
Var l : Boolean;
begin
StartDate:=FDate;
StopDate:=FDate;
  if Message(Desktop, evBroadcast, cmReestrPrh, nil) = nil then
  begin
    L:=True;
    If Not(DatePeriodDialog(StartDAte,StopDate,False)) Then Exit;
   start:=DateStringToDate(DAtemask,StartDate);
   stop:=DateStringToDate(DAtemask,StopDate);

    DInfo('Инициализация реестра документов прихода...');
    DocReestrPWindow := New(PReestrPWindow, Init(L));
    If L Then
    Begin
    Application^.InsertWindow(DocReestrPWindow);
    NoInfo;
    End
    Else
     Begin
      TekDate:=FDate;
      Dispose(DocReestrPWindow,Done);
      NoInfo;
     End;
  end
  else
    if PView(DocReestrPWindow) <> Desktop^.TopView then DocReestrPWindow^.Select;
end;


Procedure TReestrPWindow.Refresh;
Var Fp : PrihodFileType;
    s: TMyString;
    ws : AllStr;
    E : PPrihodType;
    FPos:Byte;
    FS : AllStr;
    c : Word;
    R : TRect;
    Cur : LongInt;
    TempS : TDateString;
    mSorting:Maska3;
    mStatus:Maska2;
Begin
DInfo('Минуточку...');
New(E,Init);
AllDoc[0]:=#0;
AllSumma[0]:=#0;
AllZakupka[0]:=#0;

DocList^.NewList(Nil);
DocList^.NewList(New(PMyCollection, Init(0,1)));

ControlStatus^.GetData(Status);
ControlSort^.GetData(Sorting);
WordToBit3(Sorting,mSorting);
Convert3(mSorting);
WordToBit2(STatus,mStatus);
Convert2(mStatus);


For Cur:=Start To Stop Do
Begin
c:=IOResult;
TempS:=DAteToDateString(DAteMask,Cur);
Assign(fp,Path.ToPrihod+TempS+'.prh');
Reset(fp);
c:=IOResult;
If c=0 Then
 Begin
While Not(Eof(Fp)) Do
 Begin
  ReadPrihod(Fp,E);
  If (mstatus[E^.Dat.StatusDoc+1]=1) And (msorting[E^.Dat.OperatorSelector+1]=1) Then
   Begin
    Str(StrToInt(AllDoc)+1:CLitrMantissa,AllDoc);
    DelSpace(AllDoc);
    s:=GetMakeField(FClient,E^.Dat.MakeKod,E^.Dat.OperatorSelector);
    Format(S,CClient);
    s:=s+'│';
    RFormatZerro(E^.Dat.Document,CDocNumer);
    Format(E^.Dat.Document,CDocNumer);
    s:=s+E^.Dat.Document+{'│'+E^.Dat.DateC}+'│'+E^.Dat.DateC+'│';
    DelSpace(E^.Dat.SummaR);
    RFormat(E^.Dat.SummaR,CIZena);
    DelSpace(E^.Dat.SummaZakupka);
    RFormat(E^.Dat.SummaZakupka,CIZena);
    Str(StrToReal(AllSumma)+StrToReal(E^.Dat.SummaR):CIZena:CMantissa,AllSumma);
    DelSpace(AllSumma);
    Str(StrToReal(AllZakupka)+StrToReal(E^.Dat.SummaZakupka):CIZena:CMantissa,AllZakupka);
    DelSpace(AllZakupka);
    s:=s+E^.Dat.SummaR+'│'+E^.Dat.SummaZakupka+'│';
    Str(E^.Dat.OperatorSelector:1,ws);
    s:=s+ws+'│';
    ws:=GetOperatorName(E^.Dat.Caption);
    Format(Ws,CKto);
    s:=s+ws;
    Str(E^.Dat.StatusDoc:1,ws);
    s:=s+'│'+ws;
    DocList^.List^.Insert(NewStr(s));
    DocList^.SetRange(DocList^.List^.Count);
   End;{If StatusDoc=0}
 End;{While}
System.Close(Fp);
End;{If IOResult}
End;{For}
Dispose(E,Done);
DocList^.FocusItem(0);


Str(StrToReal(AllSumma):CIZena:CMantissa,AllSumma);
DelSpace(AllSumma);
Str(StrToReal(AllZakupka):CIZena:CMantissa,AllZakupka);
DelSpace(AllZakupka);

Str(StrToInt(AllDoc):CLitrMantissa,AllDoc);
DelSpace(AllDoc);



Dispose(ControlAllSumma,Done);
R.Assign(64, 22, 79, 23);
ControlAllSumma := New(PColoredText, Init(R, #3+AllSumma, $4E));
Insert(ControlAllSumma);

Dispose(ControlAllZakupka,Done);
R.Assign(16, 22, 31, 23);
ControlAllZakupka := New(PColoredText, Init(R, #3+AllZakupka, $4E));
Insert(ControlAllZakupka);

Dispose(ControlAllDoc,Done);
R.Assign(44, 22, 48, 23);
ControlAllDoc := New(PColoredText, Init(R, #3+AllDoc, $4E));
Insert(ControlAllDoc);
NoInfo;

End;


constructor TReestrPWindow.Init(Var l : Boolean);
var
  R : TRect;
  Control : PView;
  C : Word;
  s: TMyString;
  ws : AllStr;
  E : PPrihodType;
  fp : PrihodFileType;
  Cur,start,Stop:LongInt;
begin

L:=False;
R.Assign(0, 0, 80, 23);
inherited Init(R, 'Реестр документов прихода товара на склад с '+StartDate+' по '+StopDate);
Options := Options or ofCenterX or ofCenterY;
HelpCtx:=$E002;
{
R.Assign(14, 1, 37, 2);
ControlSort := New(PCheckBoxes, Init(R,
  NewSItem('Кл~и~ент',
  NewSItem('Ск~л~ад', Nil))));
Sorting:=3;
ControlSort^.SetData(Sorting);
Insert(ControlSort);

  R.Assign(1, 1, 14, 2);
  Insert(New(PLabel, Init(R, 'Вид прихода:', ControlSort)));

R.Assign(53, 1, 79, 2);
ControlStatus := New(PCheckBoxes, Init(R,
  NewSItem('~В~веденные',
  NewSItem('Бу~ф~ер',
  Nil))));
Status:=3;
ControlStatus^.SetData(Status);
Insert(ControlStatus);

  R.Assign(37, 1, 53, 2);
  Insert(New(PLabel, Init(R, 'Статус прихода:', ControlStatus)));
}

R.Assign(11, 1, 45, 2);
ControlSort := New(PCheckBoxes, Init(R,
  NewSItem('Кл~и~ент',
  NewSItem('Ск~л~ад',
  NewSItem('Обмен',
   Nil)))));
Sorting:=7;
ControlSort^.SetData(Sorting);
Insert(ControlSort);

  R.Assign(1, 1, 11, 2);
  Insert(New(PLabel, Init(R, 'Вид прих:', ControlSort)));

R.Assign(54, 1, 79, 2);
ControlStatus := New(PCheckBoxes, Init(R,
  NewSItem('~В~веденные',
  NewSItem('Бу~ф~ер',
  Nil))));
Status:=3;
ControlStatus^.SetData(Status);
Insert(ControlStatus);

  R.Assign(46, 1, 54, 2);
  Insert(New(PLabel, Init(R, 'Статус:', ControlStatus)));

R.Assign(80, 3, 81, 21);
Control := New(PScrollBar, Init(R));
Insert(Control);



R.Assign(0, 3, 80, 22);
DoCList := New(PBox, Init(R, 1, Nil));
DoCList^.NewList(New(PMyCollection, Init(1,1)));
DocList^.HelpCtx:=$F061;
Insert(DocList);


Str(StrToReal(AllSumma):CIZena:CMantissa,AllSumma);
DelSpace(AllSumma);
Str(StrToReal(AllZakupka):CIZena:CMantissa,AllZakupka);
DelSpace(AllZakupka);

Str(StrToInt(AllDoc):CLitrMantissa,AllDoc);
DelSpace(AllDoc);

  R.Assign(1, 2, 78, 3);
  Insert(New(PLabel, Init(R, ' Поставщик            N   Дата     Сумма по Р/Ц     Сумма по З/Ц Вид  Оператор  ', DocList)));

R.Assign(49, 22, 64, 23);
Control := New(PColoredText, Init(R, ' Приход по Р/Ц:', $74));
Insert(Control);

R.Assign(64, 22, 79, 23);
ControlAllSumma := New(PColoredText, Init(R, #3+AllSumma, $4E));
Insert(ControlAllSumma);

R.Assign(1, 22, 16, 23);
Control := New(PColoredText, Init(R, ' Приход по З/Ц:', $74));
Insert(Control);

R.Assign(16, 22, 31, 23);
ControlAllZakupka := New(PColoredText, Init(R, #3+AllZakupka, $4E));
Insert(ControlAllZakupka);

R.Assign(32, 22, 44, 23);
Control := New(PColoredText, Init(R, ' Документов:', $74));
Insert(Control);

R.Assign(44, 22, 48, 23);
ControlAllDoc := New(PColoredText, Init(R, #3+AllDoc, $4E));
Insert(ControlAllDoc);



SelectNext(False);
SelectNext(False);
SelectNext(False);
L:=True;
Refresh;
PrevCur[0]:=#0;
end;



procedure TReestrPWindow.FullPreview;
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
If (DocList^.List<>Nil)And(DocList^.List^.Count>=1) Then
Begin
  Ass.EditPosition:=Copy(DocList^.GetText(DocList^.Focused,DocList^.List^.Count),1+CClient+1,CDocNumer);
  DelSpace(Ass.EditPosition);
  DelZerro(Ass.EditPosition);
  Ass.D:=Copy(DocList^.GetText(DocList^.Focused,DocList^.List^.Count),1+CClient+1+CDocNumer+1,CDate);
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
  DInfo('Ищу документ...');
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

  MyStr(StrToReal(E^.Dat.PrihodElement[c].Input.Zakupka)/
  StrToReal(GetIdField(FInPack,E^.Dat.PrihodElement[c].BazKOd)),CZena,CMantissaZ,E^.Dat.PrihodElement[c].Input.Zakupka);
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

NoInfo;
                   {Вставить номер и дату документа в просмотре}
FullScreen(P,'Наименование товара         Код  Фас Литр  Колич  З/Цена   Р/Цена   Упаковок',s,
             {12345678901234567890123456│12345│123│12345│12345│12345678│12345678│123456789}
SDoc,SDAte,0);



Dispose(P,Done);
    End
Else
  Begin
  NoInfo;
  MessageBox(#3^M+#3'Документ не найден!',Nil,mfError+mfCancelButton);
  Dispose(E,Done);
  End;
End;
End;



Procedure TReestrPWindow.FormPReport(Const P:PBox);
Const Space='';
Var f : text;
    Skidka,Summa,ws,s : string[150];
    i,c,k : Word;
    mSorting:Maska3;
    mStatus : Maska2;
    tt : Real;
    TempStr,Datestr:DateString;
    LocZ,LocP:Real;
    LocDoc:LongInt;
    PrintItog,PrintDate : Boolean;
Begin
If (P^.List<>Nil) And (P^.List^.Count>=1) Then
 Begin
 Assign (f,Path.ToTemp+'listp.txt');
 c:=0;
 Rewrite(f);
 c:=IOResult;
 If c<>0 Then
  Begin
   MessageBox(#3^m+#3+'Не могу создать файл '+Path.ToTemp+'listp.txt',Nil,mfError+mfCancelButton);
   Exit;
  End;

ControlStatus^.GetData(Status);
ControlSort^.GetData(Sorting);
WordToBit3(Sorting,mSorting);
Convert3(mSorting);
WordToBit2(STatus,mStatus);
Convert2(mStatus);

 Write(f,Space+'Вид прихода:');
 For i:=1 To 3 Do
 Case i Of
 1: If Msorting[i]=1 Then Write(f,' Клиент ');
 2: If Msorting[i]=1 Then Write(f,' Склад ');
 3: If Msorting[i]=1 Then Write(f,' Обмен ');
 Else;
 End;
 Writeln(f);

 Write(f,Space+'Статус документов:');
 For i:=1 To 2 Do
 Case i Of
 1: If MStatus[i]=1 Then Write(f,'{Введен на склад ') Else Write(f,'{');
 2: If MStatus[i]=1 Then Write(f,'Буфер}') Else Write(f,'}');
 Else;
 End;
 Writeln(f);


 Writeln(f,Space+'Склад: ',GetClientField(FClient,Rek.Kod,1)+'  Оператор: '+CurrentPassword+' EYE & 1999');
 Writeln(f,Space+' РЕЕСТР ДОКУМЕНТОВ ПРИХОДА ТОВАРА НА СКЛАД  с '+StartDate+
 ' по '+StopDate);
 Writeln(f,Space+'--------------------------------------------------------------------------------------------');
 Writeln(f,Space+'Поставщик            Док    Дата      Сумма по Р/Ц    Сумма по З/Ц  Вид прих.   Оператор   Т');
                 {12345678901234567890│1234│12-45-78│123456789012345│123456789012345│1234567890│123456789012│1}
 Writeln(f,Space+'--------------------------------------------------------------------------------------------');
 s := P^.GetText(0,P^.List^.Count);
 DateStr:=Copy(s,1+CClient+1+CDocNumer+1,CDate);
 LocZ:=0;
 LocP:=0;
 LocDoc:=0;
 Writeln(f,'Дата: '+DateStr);

 For c:=0 To P^.List^.Count-1 Do
  Begin
   PrintItog:=False;
   PrintDate:=False;
   s := P^.GetText(c,P^.List^.Count);
   While Pos('│',s)>0 Do
    Begin
     k:=Pos('│',s);
     System.Delete(s,k,1);
     System.Insert(' ',s,k);
    End;
    LocZ:=LocZ+StrToReal(Copy(s,1+CClient+1+CDocNumer+1+CDate+1,CIZena));
    LocP:=LocP+StrToReal(Copy(s,1+CClient+1+CDocNumer+1+CDate+1+CIZena+1,CIZena));
    Inc(LocDoc);
    Case StrToInt(Copy(s,1+CClient+1+CDocNumer+1+CDate+1+CIZena+1+CIZena+1,COne)) Of
    0:Begin
       System.Delete(s,1+CClient+1+CDocNumer+1+CDate+1+CIZena+1+CIZena+1,COne);
       System.Insert(' "Клиент" ',s,1+CClient+1+CDocNumer+1+CDate+1+CIZena+1+CIZena+1);
      End;
    1:Begin
       System.Delete(s,1+CClient+1+CDocNumer+1+CDate+1+CIZena+1+CIZena+1,COne);
       System.Insert(' "Склад"  ',s,1+CClient+1+CDocNumer+1+CDate+1+CIZena+1+CIZena+1);
      End;
    2:Begin
       System.Delete(s,1+CClient+1+CDocNumer+1+CDate+1+CIZena+1+CIZena+1,COne);
       System.Insert(' "Обмен"  ',s,1+CClient+1+CDocNumer+1+CDate+1+CIZena+1+CIZena+1);
      End;
    Else;
    End;
    Case StrToInt(Copy(s,1+CClient+1+CDocNumer+1+CDate+1+CIZena+1+CIZena+1+10+1+CKto+1,COne)) Of
    0:Begin
       S[0]:=Chr(Ord(S[0])-1);
       s:=s+'В';
      End;
    1:Begin
       S[0]:=Chr(Ord(S[0])-1);
       s:=s+'Б';
      End;
    Else;
    End;

   If c<P^.List^.Count-1 Then
    Begin
     ws := P^.GetText(c+1,P^.List^.Count);
     TempStr:=Copy(ws,1+CClient+1+CDocNumer+1,CDate);
     If TempStr<>DateStr Then
      Begin
       PrintDate:=True;
       PrintItog:=True;
      End;
    End
    Else PrintItog:=True;

   Writeln(f,Space+s);

 If PrintItog Then
 Begin
 Writeln(f,Space,'Всего за:'+DateStr+'  по РЦ: ',RecognizReal(LocZ,CIZena,CMantissa), '  по ЗЦ: ',
 RecognizReal(LocP,CIZena,CMantissa), '   документов: ',LocDoc:3,' --------');
 DateStr:=TempStr;
 LocZ:=0;
 LocP:=0;
 LocDoc:=0;
 End;
 If PrintDate Then
 Writeln(f,'Дата: '+DateStr);

  End;
 Writeln(f,Space+'--------------------------------------------------------------------------------------------');
 Writeln(f,Space,'                                                Всего документов за период: ',AllDoc);
 Writeln(f,Space,'                                              Всего приход по З/Ц составил: '+Recogniz(AllZakupka));
 Writeln(f,Space,'                                              Всего приход по Р/Ц составил: '+Recogniz(AllSumma));
 tt:=StrToReal(AllSumma)- StrToReal(AllZakupka);
 Skidka:=RealToStr(tt,CIZena,CMantissa);
 DelSpace(Skidka);
 Writeln(f,Space,'                                                   Всего сальдо  составило: '+
 Recogniz(Skidka));
 Writeln(f,Space,'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
 Writeln(f,Space+'============================================================================================');


 System.Close(f);
 ViewAsText(Path.ToTemp+'listp.txt',True);
 Report(Path.ToTemp+'listp.txt','',1,False,False,false);
 End;
End;


Function TestPrihod(As:DocumentEdit;VAr Cod: ArtikulStr):Boolean;
VAr e : PPrihodType;
    ef : PrihodFileType;
    Find : Boolean;
    c : Word;
Begin
Cod[0]:=#0;
TestPrihod:=FAlse;
Assign(ef,PAth.ToPrihod+As.D+'.prh');
c:=IoResult;
Reset(ef);
c:=IoResult;
if c<>0 then exit;

Find :=FAlse;
new(E,Init);

While Not(Eof(ef)) And Not(Find) Do
 Begin
  ReadPrihod(ef,E);
  If E^.DAt.OperatorSelector=2 Then
   Begin
    If E^.DAt.StatusDoc=0 Then
     Begin
      If (StrToInt(As.EditPosition)=StrToInt(E^.DAt.Document)) And
         (E^.DAt.DAteC=As.D) Then
          Begin
           TestPrihod:=True;
           Find:=True;
           Cod:=E^.DAt.MAkeKod;
           Break;
          End;
     End;
   End
 End;

Dispose(E,Done);
c:=IoResult;
Close(Ef);
c:=IoResult;
End;


procedure TReestrPWindow.HandleEvent(var Event: TEvent);
Var test : Word;
    s,s1 : string[150];
    SDoc : ArtikulStr;
    SDate: TDateString;
    l : Boolean;
    FC:Byte;
    FS : AllStr;
    Cod : ArtikulStr;

begin

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
      kbF4: Begin
              ClearFind;
              Event.What:=evCommand;
              Event.Command:=cmProperties;
              PutEvent(Event);
              ClearEvent(Event);
            End;
      Else;
      End;{KeyDown}
  evCommand :
     Case Event.Command Of

  cmAbout: Begin
    AboutCHM('52');
    ClearEvent(Event);
    End;

  cmPrintReestr: if (User[87] or (CurrentPassword='00')) then
     Begin
                 ClearFind;
     If (DocList^.State and sfFocused <> 0) And (DocList^.List<>Nil)And(DocList^.List^.Count>=1) Then
            Begin
                Assistent.EditPosition:=Copy(DocList^.GetText(DocList^.Focused,DocList^.List^.Count),1+CClient+1,CDocNumer);
                DelSpace(Assistent.EditPosition);
                DelZerro(Assistent.EditPosition);
                Assistent.D:=Copy(DocList^.GetText(DocList^.Focused,DocList^.List^.Count),1+CClient+1+CDocNumer+1,CDate);
                DelSpace(Assistent.D);
                PrintPrihod(Assistent);
            End
            End;
 cmProperties:Begin

                 ClearFind;
     If (DocList^.State and sfFocused <> 0) And (DocList^.List<>Nil)And(DocList^.List^.Count>=1) Then
            Begin
                Assistent.EditPosition:=Copy(DocList^.GetText(DocList^.Focused,DocList^.List^.Count),1+CClient+1,CDocNumer);
                DelSpace(Assistent.EditPosition);
                DelZerro(Assistent.EditPosition);
                Assistent.D:=Copy(DocList^.GetText(DocList^.Focused,DocList^.List^.Count),1+CClient+1+CDocNumer+1,CDate);
                DelSpace(Assistent.D);

                If TestPrihod(Assistent,Cod) Then
                Begin
                  If SetClientLock(Cod,0,2) Then
                   Begin
                    If PAssword(9) Then
                    PrhW^.Ini(Cod,Assistent.EditPosition,Assistent.D);
                    Repeat
                    Until (SetClientUnLock(Cod,0,2));
                   End
                   Else
                    MessageBox(^M+#3+'Не могу заблокировать поставщика! Повторите попытку позже!',Nil,mfError+mfCAncelButton);
                End;
             End;

              End;

 cmReestrReport: if (User[86] or (CurrentPassword='00')) then
      Begin
                 ClearFind;
     If (DocList^.State and sfFocused <> 0) And (DocList^.List<>Nil)And(DocList^.List^.Count>=1) Then
            Begin
            FormPReport(DocList);
            End
            End;
  cmFullView:    Begin
                 ClearFind;
     If (DocList^.State and sfFocused <> 0) And (DocList^.List<>Nil)And(DocList^.List^.Count>=1) Then
            Begin
              FullPreview;
{               Assistent.EditPosition:=Copy(DocList^.GetText(DocList^.Focused,DocList^.List^.Count),1+CClient+1,CDocNumer);
                DelSpace(Assistent.EditPosition);
                Assistent.D:=Copy(DocList^.GetText(DocList^.Focused,DocList^.List^.Count),1+CClient+1+CDocNumer+1,CDate);
                DelSpace(Assistent.D);
                Status:=DocPrint;
                PrintNaklSklad(Assistent);
                PrintNakl(Assistent);
                Status:=DocNormal;}
            End
            End;
     cmReestrDoc:Begin
                  ClearFind;
                  ClearEvent(Event);
                 End;
     cmRefresh  :Begin
                  ClearFind;
                  ClearEvent(Event);
                  Refresh;
                 End;
     cmCancel    : Begin
                 Dispose(DocList,Done);
                 {
                 Dispose(ControlRefreshTime,Done);
                 Dispose(ControlCombo,Done);
                 Dispose(ControlAllClient,Done);
                 Dispose(ControlAllSkid,Done);
                 Dispose(ControlAllSumma,Done);
                 Dispose(ControlAllDoc,Done);
                 }
                 ClearFind;
                 Event.What:=evCommand;
                 Event.Command:=cmClose;
                 PutEvent(Event);
                 ClearEvent(Event);
                End;
(*     cmClose  : Begin
                 {Dispose(ControlModifyDate,Done);}
                 {Dispose(ControlAllSkidka,Done);}
                 inherited HandleEvent(Event);
                 Exit;
                End;*)

      Else;
      End;{evCommand}
      Else;
      End;{*Case*}
  if (Event.What = evBroadcast) and
    (Event.Command = cmReestrDoc) then ClearEvent(Event);

  if (Event.What = evBroadcast) and
    (Event.Command = cmQuit) then ClearEvent(Event);


  inherited HandleEvent(Event);


  If (Desktop^.Current=PView(DocReestrPWindow)) And (Event.What <> EvKeyDown) Then
             Begin
                if (ControlStatus^.State and sfFocused <> 0)Then
                    Begin
                        ControlStatus^.GetData(Test);
                        If Test <> Status Then
                        Begin
                           ClearFind;
                           Status:=Test;
                           Refresh;
                           Redraw;
                        End;
                    End;

                if (ControlSort^.State and sfFocused <> 0)Then
                    Begin
                        ControlSort^.GetData(Test);
                        If Test <> Sorting Then
                        Begin
                           ClearFind;
                           Sorting:=Test;
                           Refresh;
                           Redraw;
                        End;
                    End;



             End;

end;

BEgin
Status:=3;
Sorting:=3;
RefreshTime:=20;
End.