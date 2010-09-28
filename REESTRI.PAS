{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}

{$I Compile.INC}

Unit ReestrI;

Interface

Uses Dialogs,Drivers,{Glob,}Access,ServStr,Utils,CorMrk,Glob,Utils8;

Type
  PReestrIWindow = ^TReestrIWindow;
  TReestrIWindow = object(TDialog)
    ViewTrans  : PFullScreenTrans;
    constructor Init(Var l: Boolean);
    procedure OpenReestrWindow;
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure SortScreenList(Logik:Boolean);
   {Procedure FormReport(Const p:PBox);}
    procedure Refresh;
    Procedure FormReport(Const P:PBox);
  end;


Implementation

uses DBEngine,Objects, Views, MsgBox,{Vision,Calc,}Dos,Vision4,Vision9,TpDate,
     App, ColorTxt,Serv,{InpLong,{Validate,}Tools,Printers,Mail,
     Prise,Utils4,Utils5,Utils7,Access1,Access4,Utils6,TrNakl,
     ComboBox,NetDbEng,Net,Protect,Utils1,Validate,Utils3;



var
 NoScreenList,DocList : PBox;
 ControlActiv,ControlAgent,
 ControlEdit,ControlSort,ControlDirection,ControlVidDoc,ControlAllDoc,ControlAllSumma,
 ControlAllSkid,ControlAllTara,ControlAllClient,ControlSf,
 ControlSertifFiltr,ControlAuto,ControlRemark,
 ControlEksp,
 ControlPeriod,
 ControlFiltr,ControlModifyDate,ControlRefreshTime,ControlCombo: PView;
 PrevCur : String;
 DocReestrWindow:PReestrIWindow;
 DocDate : TDateString;
 Izmen,Direction ,Sorting : Word;
 M3:Maska3;
 StartDate,StopDate:TDAteString;
 FiltrOtdel1,FiltrOtdel2 : MAska8;
 Auto : Word;
 Sertifword,Activ,Filtr,FiltrR : Word;
 RegimExt: Word;
 OldFileMode : Word;



Function Setup:Boolean;

Type MyType=Record
    Postavshik,Polushatel:Word;
    Ext: Word;
  end;

var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  VVV : MyType;
  c : Word;
  Change : Boolean;

begin
Setup:=FAlse;

If Password(9) Then Change:=True
Else Change:=False;


With VVV Do
 Begin
Convert8(FiltrOtdel1);
BitToWord8(FiltrOtdel1,c);
Postavshik:=c;

Convert8(FiltrOtdel2);
BitToWord8(FiltrOtdel2,c);
Polushatel:=c;

Ext := RegimExt;
End;


R.Assign(15, 4, 65, 19);
New(Dlg, Init(R, 'Параметры реестра внутренних перемещений'));
Dlg^.Options := Dlg^.Options or ofCenterX;
Dlg^.HelpCtx:=$E002;

R.Assign(2, 2, 48, 6);
Control := New(PCheckboxes, Init(R,
  NewSItem('~1~ '+Rek^.Dat.Otdel[1],
  NewSItem('~2~ '+Rek^.Dat.Otdel[2],
  NewSItem('~3~ '+Rek^.Dat.Otdel[3],
  NewSItem('~4~ '+Rek^.Dat.Otdel[4],
  NewSItem('~5~ '+Rek^.Dat.Otdel[5],
  NewSItem('~6~ '+Rek^.Dat.Otdel[6],
  NewSItem('~7~ '+Rek^.Dat.Otdel[7],
  NewSItem('~8~ '+Rek^.Dat.Otdel[8],
  Nil))))))))));
Dlg^.Insert(Control);

  R.Assign(2, 1, 23, 2);
  Dlg^.Insert(New(PLabel, Init(R, 'Отделение ~п~оставщик:', Control)));

R.Assign(2, 7, 48, 11);
Control := New(PCheckboxes, Init(R,
  NewSItem('1 '+Rek^.Dat.Otdel[1],
  NewSItem('2 '+Rek^.Dat.Otdel[2],
  NewSItem('3 '+Rek^.Dat.Otdel[3],
  NewSItem('4 '+Rek^.Dat.Otdel[4],
  NewSItem('5 '+Rek^.Dat.Otdel[5],
  NewSItem('6 '+Rek^.Dat.Otdel[6],
  NewSItem('7 '+Rek^.Dat.Otdel[7],
  NewSItem('8 '+Rek^.Dat.Otdel[8],
  Nil))))))))));
Dlg^.Insert(Control);

  R.Assign(2, 6, 24, 7);
  Dlg^.Insert(New(PLabel, Init(R, 'Отделение по~л~учатель:', Control)));




R.Assign(16, 12, 36, 14);
Control := New(PRadioButtons, Init(R,
  NewSItem('~Р~/Цена',
  NewSItem('~З~акупка 1',
  Nil))));
If Not((FindPARAM('/EZ')) Or (EnableZakupka=1) Or (StrToInt(CurrentPassword)=0)) Then
  Control^.Options := Control^.Options and not ofSelectable;

Dlg^.Insert(Control);

  R.Assign(4, 12, 16, 13);
  Dlg^.Insert(New(PLabel, Init(R, 'Вид отчета:', Control)));

Dlg^.SelectNext(False);

Dlg^.SetData(VVV);

c:=Desktop^.ExecView(Dlg);
If c<>cmCancel Then
Begin
 Setup:=True;
 Dlg^.GetData(VVV);

With VVV Do
 Begin
RegimExt:=Ext;

WordToBit8(Postavshik,FiltrOtdel1);
WordToBit8(Polushatel,FiltrOtdel2);
 End;

End;
Convert8(FiltrOtdel1);
Convert8(FiltrOtdel2);
Dispose(Control,Done);
Dispose(Dlg,Done);
end;




procedure TReestrIWindow.OpenReestrWindow;
Var l : Boolean;
begin
  if Message(Desktop, evBroadcast, cmReestrDoc, nil) = nil then
  begin
    L:=True;
    {If Not(DatePeriodDialog(StartDAte,StopDate,False)) Then Exit;}
    StartDate:=FDate;
    StopDate:=FDate;
    DInfo('Инициализация реестра внутренних перемещений...');
    DocReestrWindow := New(PReestrIWindow, Init(L));
    If L Then
    Begin
    Application^.InsertWindow(DocReestrWindow);
    NoInfo;
    End
    Else
     Begin
      TekDate:=FDate;
      Dispose(DocReestrWindow,Done);
      NoInfo;
     End;
  end
  else
    if PView(DocReestrWindow) <> Desktop^.TopView then DocReestrWindow^.Select;
end;



Procedure TReestrIWindow.SortScreenList(Logik:Boolean);
Var c,i,j : Word;
    ws,ws1 : String;
    Doc : String;
         TempBox : PBox;
    R : TRect;
    Find : Boolean;
    Numer,LongDate : TDateString;
Begin
Dispose(ControlPeriod,Done);
R.Assign(6, 0, 74, 1);
ControlPeriod := New(PColoredText, Init(R, #3+'Реестр внутренних перемещений за период с '+StartDAte+' по '+StopDAte, $4F));
ControlPeriod^.Options := ControlPeriod^.Options or ofCenterX;
Insert(ControlPeriod);



DInfoMsg('Сортирую документы...',False);

if (DocList^.List^.Count>0) And Not(Logik) Then
  Doc:=DocList^.GEtText(DocList^.Focused,DocList^.List^.Count)
Else Doc[0]:=#0;



R.Assign(0,0,0,0);
TempBox := New(PBox, Init(R, 1, Nil));
TempBox^.NewList(New(PTextCollection, Init(0,1)));


DocList^.NewList(Nil);
DocList^.NewList(New(PMyCollection, Init(0,1)));



DistanationSorting:=Direction;




If NoScreenList^.List^.Count>0 Then
Begin
{формируем отсортированный список}
For j:=0 to NoScreenList^.List^.Count-1 Do
Begin
 ws:=NoScreenList^.GEtText(j,NoScreenList^.List^.Count);

{приводим строку к виду поставщик получатель номер дата сумма оператор}
 System.Delete(ws,1+CIZena+1,CMantissa);
 System.Delete(ws,1+CIZena+1+CIZena+1,CMantissa);

LongDate:=Copy(ws,1+CIZena+1+CIZena+1+CDocNumer+1,CDate);

LongDate:=IntToStr(DateStringToDate(DateMask,LongDate),CDAte);

RFormat(LongDate,CDAte);

Numer:=Copy(ws,1+CIZena+1+CIZena+1,CDocNumer);

Case Sorting Of
{поставщик}
0:Begin
   System.Insert(Numer,ws,1+CIZena+1);
   System.Insert(LongDate,ws,1+CIZena+1);
  End;
{получатель}
1:Begin
   ws1:=Copy(ws,1+CIZENA+1,CIZena);
   ws:=ws1+LongDate+Numer+' '+ws;
  End;
{сумма}
2:Begin
   ws1:=Copy(ws,1+CIZena+1+CIZena+1+CDocNumer+1+CDate+1,CIZena);
   RFormatZerro(ws1,CIZena);
   ws:=ws1+LongDate+Numer+' '+ws;
  End;
{дата}
3:Begin
   ws:=LongDate+Numer+' '+ws;
  End;
Else;
End;{CAse}
  TempBox^.List^.Insert(NewStr(ws));
  TempBox^.SetRange(TempBox^.List^.Count);
End;


{форматируем сформированый список под экранную форму}
If TempBox^.List^.Count>0 Then
Begin
For j:=0 to TempBox^.List^.Count-1 Do
Begin
  ws:=TempBox^.GEtText(j,TempBox^.List^.Count);
Case Sorting Of
{поставщик}
0:Begin
   System.Delete(ws,1+CIZena+1,CDate+CDocNumer);
   ws:=ws;
  End;
{получатель}
1:Begin
   System.Delete(ws,1,CDate+CDocNumer+CIZena+1);
  End;
{сумма отгрузки}
2:Begin
   System.Delete(ws,1,CIZena+CDate+CDocNumer+1);
  End;
{дата}
3:Begin
   System.Delete(ws,1,CDate+CDocNumer+1);
  End;
Else;
End;{CAse}
  DocList^.List^.Insert(NewStr(ws));
  DocList^.SetRange(DocList^.List^.Count);
End;
End;
End;{If TempCalcList^.List^.Count>0 Then}


Dispose(TempBox,Done);

NoInfoMsg;

If Doc[0]=#0 Then
DocList^.FocusItem(0)
Else
 Begin
   Find:=FAlse;
   if (DocList^.List^.Count>0)Then
    Begin
     For c:=0 To DocList^.List^.Count-1 Do
      Begin
       If Doc=DocList^.GEtText(c,DocList^.List^.Count) Then
        Begin
         Find:=True;
         Break;
        End;
      End;
      If Find Then DocList^.FocusItem(c)
      Else DocList^.FocusItem(0);
     End
   Else DocList^.FocusItem(0);
 End;
 DocList^.HelpCtx:=$F911;

DistanationSorting:=0;
PrevCur[0]:=#0;

End;



Procedure TReestrIWindow.Refresh;
Var   F : TransportFileType;
      s: String;
      ws : AllStr;
      AllDoc,AllClient,AllSkid,AllSumma : String[CIZena];
      E : PTransportType;
      TempArtikul,FS : AllStr;
      Sh,c : Word;
      R : TRect;
      cc , Count : Word;
      l,lStart,lStop : LongInt;
      CurStr : TDateString;
      InfoStr : String;
      SKod,SDAte,SDAteM,STime,STimeM : TDAteString;
      OpName,SClient,SumZ,Skid,SertifSumZ,SertifSkid : AllStr;
Var jk :Word;
Begin
LStart:=DateStringToDate(DateMask,StartDate);
LStop :=DateStringToDate(DateMask,StopDate);

NoScreenList^.NewList(Nil);
NoScreenList^.NewList(New(PTextCollection, Init(1,1)));

AllDoc[0]:=#0;
AllSkid[0]:=#0;
AllSumma[0]:=#0;
AllClient[0]:=#0;


For l:=LStart To LStop Do
Begin
CurStr:=DateToDateString(DateMask,l);
DInfoMsgShkala('Просматриваю внутренние перемещения за '+CurStr+' ...',LStart,LStop,l);
c:=IOResult;
Assign(f,Path^.Dat.ToTransport+CurStr+'.trn');
OldFileMode:=FileMode;
FileMode:=ReadOnlyN;
Reset(f);
FileMode:=OldFileMode;
c:=IOResult;
If c=0 Then
 Begin

While Not(Eof(F)) Do
 Begin
  New(E,Init);
  Count:=0;

  {BlockRead(fp,E^.Point,BufferMrkIDX,Count);}
  ReadTransport(f,E);
Begin
  If (E^.Dat.Active) And (StrToInt(E^.Dat.SkladKod)=StrToInt(Rek^.Dat.Kod))Then
   Begin
        Begin
   {If (FiltrSf=0)Or(E^.Point.Dat[cc].DocSelector in [3,4,6,8]) Then}
Begin
   Begin
    If FiltrOtdel1[E^.Dat.MakeOtdelenie]=1 Then
 Begin
    If FiltrOtdel2[E^.Dat.ClientOtdelenie]=1 Then
Begin
    s:=E^.Dat.Document;

    Str(StrToInt(AllDoc)+1:CArtikul,AllDoc);
    DelSpace(AllDoc);

    s:=Rek^.Dat.Otdel[E^.Dat.MakeOtdelenie];
    Format(S,CIZena);

    SKod:=IntToStr(E^.Dat.MakeOtdelenie,COne);
    s:=s+'│'+SKod;

    RFormatZerro(E^.Dat.Document,CDocNumer);

    SClient:=Rek^.Dat.Otdel[E^.Dat.ClientOtdelenie];

    Format(SClient,CIZena);

    SKod:=IntToStr(E^.Dat.ClientOtdelenie,COne);

    SDAte:=E^.Dat.DateC;


    MyStr(StrToReal(E^.Dat.SummaZ),CIZena,CMantissaZ,E^.Dat.SummaZ);

    OpName:=GetOperatorField(FName,E^.Dat.Caption);
    Format(OpName,CKto);

    s:=s+'│'+SClient+'│'+SKod+'│'+E^.Dat.Document+'│'+SDAte+'│'+E^.Dat.SummaZ+'│'+OpName;


    Case RegimExt Of
    0:
    MyStr(StrToReal(AllSumma)+StrToReal(E^.Dat.SummaZ),CIZena,CMantissa,AllSumma);
    1:
    MyStr(StrToReal(AllSumma)+StrToReal(E^.Dat.SummaZakupka),CIZena,CMantissaZ,AllSumma);
    Else;
    End;


      If NoScreenList^.List^.Count>=MaxCollectionSize-1 Then
      Begin
       Dispose(E,Done);
       System.Close(F);
       NoInfoMsg;
       MessageBox(^M+#3+'Переполнение коллекции!',Nil,mfError+mfCancelButton);
       Exit;
      End;

         NoScreenList^.List^.Insert(NewStr(s));
         NoScreenList^.SetRange(NoScreenList^.List^.Count);
End;{Фильтр активных продаж}
        End;
End;
        End;
        End;
End;
End;{For}
Dispose(E,Done);
 End;{While}
{NoScreenList^.FocusItem(0);}

System.Close(F);
 End;{c=0}
End;{For}

NoInfoMsg;

FileMode:=OldFileMode;

MyStr(StrToReal(AllSkid),CIZena,CMantissa,AllSkid);
DelSpace(AllSkid);

MyStr(StrToReal(AllSumma),CIZena,CMantissaZ,AllSumma);
DelSpace(AllSumma);

Str(StrToInt(AllDoc):CArtikul,AllDoc);
DelSpace(AllDoc);

MyStr(StrToReal(AllClient),CIZena,CMantissa,AllClient);
DelSpace(AllClient);



Dispose(ControlAllDoc,Done);
R.Assign(44, 22, 52, 23);
ControlAllDoc := New(PColoredText, Init(R, #3+AllDoc, $4E));
Insert(ControlAllDoc);

Dispose(ControlAllSumma,Done);
R.Assign(61, 22, 76, 23);
ControlAllSumma := New(PColoredText, Init(R, #3+AllSumma, $4E));
Insert(ControlAllSumma);

NoInfoMsg;

{Memc('Авто:'+IntToStr(Auto,CIZena)+' Ручная:'+IntToStr(Hand,CIZena));}

End;



constructor TReestrIWindow.Init(Var l : Boolean);
var
  R : TRect;
  Control : PView;
  C : Word;
  s: String;
  ws : AllStr;
  AllDoc,AllClient,AllSkid,AllTara,AllSumma : String[CIZena];
  E : PSuperMarketType;
begin
L:=False;


For c:=1 To CDivision Do
Begin
FiltrOtdel1[c]:=1;
FiltrOtdel2[c]:=1;
End;

R.Assign(0, 0, 80, 23);
inherited Init(R, '');
Options := Options or ofCenterX or ofCenterY;
HelpCtx:=$E002;

R.Assign(0, 0, 0, 0);
NoScreenList := New(PBox, Init(R, 1, Nil));
NoScreenList^.NewList(New(PTextCollection, Init(1,1)));
AllDoc[0]:=#0;
AllSumma[0]:=#0;

NoScreenList^.FocusItem(0);

MyStr(StrToReal(AllSumma),CIZena,CMantissa,AllSumma);
DelSpace(AllSumma);

Str(StrToInt(AllDoc):CLitrMantissa,AllDoc);
DelSpace(AllDoc);

R.Assign(6, 0, 74, 1);
ControlPeriod := New(PColoredText, Init(R,
#3+'Реестр внутренних перемещений за период с '+StartDAte+' по '+StopDAte, $4F));
ControlPeriod^.Options := ControlPeriod^.Options or ofCenterX;
Insert(ControlPeriod);

R.Assign(13, 1, 64, 2);
ControlSort := New(PRadioButtons, Init(R,
  NewSItem('~П~оставщик',
  NewSItem('П~о~лучатель',
  NewSItem('~С~умма',
  NewSItem('~Д~ата', Nil))))));
ControlSort^.SetData(Sorting);
Insert(ControlSort);

  R.Assign(1, 1, 13, 2);
  Insert(New(PLabel, Init(R, 'Сортировка:', ControlSort)));


R.Assign(65, 1, 79, 2);
ControlDirection := New(PRadioButtons, Init(R,
  NewSItem(#30,
  NewSItem(#31, Nil))));

ControlDirection^.SetData(Direction);
Insert(ControlDirection);

R.Assign(79, 3, 80, 22);
Control := New(PScrollBar, Init(R));
Insert(Control);

R.Assign(1, 3, 79, 22);
DocList := New(PBox, Init(R, 1, PScrollbar(Control)));
DocList^.NewList(New(PMyCollection, Init(0,1)));
DocList^.FocusItem(0);
DocList^.HelpCtx:=$F911;

Insert(DocList);

  R.Assign(1, 2, 76, 3);
  Insert(New(PLabel, Init(R,'Поставщик       Получатель      Док.   Дата        Сумма      Оператор', DocList)));

R.Assign(52, 22, 61, 23);
Control := New(PColoredText, Init(R,' E Сумма:', $74));
Insert(Control);

MyStr(StrToReal(AllSumma),CIZena,CMantissa,AllSumma);
DelSpace(AllSumma);

R.Assign(61, 22, 76, 23);
ControlAllSumma := New(PColoredText, Init(R, #3+AllSumma, $4E));
Insert(ControlAllSumma);

R.Assign(30, 22, 44, 23);
Control := New(PColoredText, Init(R, ' E документов:', $74));
Insert(Control);

R.Assign(44, 22, 52, 23);
ControlAllDoc := New(PColoredText, Init(R, #3+AllDoc, $4E));
Insert(ControlAllDoc);

SelectNext(False);
SelectNext(False);
SelectNext(False);

L:=True;
Refresh;
PrevCur[0]:=#0;
SortScreenList(True);
end;




Procedure TReestrIWindow.FormReport(Const P:PBox);
Const Space=' ';
Var   f : text;
      SVersia,Skidka,Summa,ws,s : String;
      AllLitr,NDSZ,NDS,Zakupka,Litr,AllNDS20,AllNDS10,AllNDS_,
      ZakupkaOutNDS,Itogo,ISkid : Real;
         c,k,VidZak : Word;
         Open : String;
      As : DocumentEditZ;
      Tip : Word;
      SAllLitr,SNDS,SNDSZ,SClient,SLitr,SZakupka,SZakupkaOutNDS,SEkspeditor,
      OplataOutNDS,
         SLocNDS,SLocNDSZ,SLocNDS20,SLocNDS10,SLocNDS_,SLocLitr,SLocZakupkaOutNDS : AllStr;
      Agent : PBox;
      AgKod : AllStr;
      R : TRect;
      E : PSuperMArketType;
      TempStr,DateStr,SClientKod,SDoc,SDAte : TDAteString;
      NDS20,NDS10,NDS_,
      LocNDS,LocNDS20,LocNDS10,LocNDS_,LocLitr,
         LocZakupkaOutNDS,LocNDSZ:Real;
      PrintItog,PrintDate : Boolean;
      sertif2 : Maska2;
      LocLocOpl,LocLocNDS,LocLocZ,LocLocZOutNDS,LocLocLitr : Real;
      AllDoc,LocLocDoc:Word;

Begin


If (P^.List<>Nil) And (P^.List^.Count>=1) Then
 Begin

 Assign (f,Path^.Dat.ToTemp+'listi.txt');
 c:=0;
 Rewrite(f);
 c:=IOResult;
 If c<>0 Then
  Begin
   MessageBox(#3^m+#3+'Не могу создать файл '+
   Path^.Dat.ToTemp+'listi.txt',Nil,mfError+mfCancelButton);
   Exit;
  End;



 Writeln(f,Header+Space+ 'Склад: ',GetClientField(FClient,Rek^.Dat.Kod,1)+'  Оператор: '+CurrentPassword+' EYE & 1997-98');

 Write(f,Space+'Вид сортировки:');
 Case Sorting Of
 0:Writeln(f,Space+'"Поставщик"');
 1:Writeln(f,Space+'"Получатель"');
 2:Writeln(f,Space+'"Сумма"');
 3:Writeln(f,Space+'"Дата"');
 Else Writeln(f);
 End;

 Write(f,Space+'Вид цены:');
 Case RegimExt Of
 0:Writeln(f,Space+'"Р/Цена"');
 1:Writeln(f,Space+'"Закупка"');
 Else Writeln(f);
 End;
 Writeln(f);

 Writeln(f,Space+'Отделения поставщики:');
 Write(f,Space);
 For c:=1 To CDivision Do
  Begin
   If FiltrOtdel1[c]=1 Then Write(f,' "'+IntToStr(c,COne)+'" ');
  End;
 Writeln(f);
 Writeln(f,Space+'Отделения получатели:');
 Write(f,Space);
 For c:=1 To CDivision Do
  Begin
   If FiltrOtdel2[c]=1 Then Write(f,' "'+IntToStr(c,COne)+'" ');
  End;
 Writeln(f);

 Writeln(f);

 Writeln(f,Space+'РЕЕСТР ВНУТРЕННИХ ПЕРЕМЕЩЕНИЙ  с '+StartDate+' по '+StopDate+
 ' ('+FDate+' '+Times+')');

 Writeln(f,Space+'┌───────────────┬───────────────┬────┬────────┬───────────────┬────────────┐');
 Writeln(f,Space+'│               │               │    │        │ Сумма по      │  Оператор  │');
                 {│123456789012345│123456789012345│Док.│12345678│123456789012345│123456789012│}
 Writeln(f,Space+'│Поставщик      │Получатель     │Док.│  Дата  │ документу     │            │');
 Writeln(f,Space+'└───────────────┴───────────────┴────┴────────┴───────────────┴────────────┘'+
 HeaderStop);
                 {12345678901234567890│12345│1234│12345678│1234567890│12345678│12345678│12345678│1234567890│123456789│}

  Itogo:=0;
  AllDoc:=0;




If Sorting=3 Then
Begin
s := P^.GetText(0,P^.List^.Count);
DateStr:=Copy(s,1+CIZena+1+CIZena+1+CDocNumer+1,CDate);
Writeln(f,Space+'Дата: '+DateStr);
End;


 LocLocOpl:=0;
 LocLocDoc:=0;



 For c:=0 To P^.List^.Count-1 Do
  Begin
     DInfoMsgShkala('Формирую отчет за период с '+StartDate+' по '+StopDate+' ...',0,P^.List^.Count-1,c);

   PrintItog:=False;
   PrintDate:=False;


     s := P^.GetText(c,P^.List^.Count);

Begin
        While Pos('│',s)>0 Do
         Begin
          k:=Pos('│',s);
          System.Delete(s,k,1);
          System.Insert(SeparatorChar,s,k);
         End;

        As.EditPosition := Copy(s,1+CIZena+1+CIZena+1,CDocNumer);
        As.D := Copy(s,1+CIZena+1+CIZena+1+CDocNumer+1,CDAte);
        Summa:=Copy(s,1+CIZena+1+CIZena+1+CDocNumer+1+CDAte+1,CIZena);

        LocLocOpl:=LocLocOpl+StrToReal(Summa);


  If Sorting=3 Then
   Begin
     LocLocOpl:=LocLocOpl+StrToReal(Summa);
     Inc(LocLocDoc);
   End;



  If Sorting = 3 Then
  Begin
   If c<P^.List^.Count-1 Then
    Begin
     ws := P^.GetText(c+1,P^.List^.Count);
     TempStr:=Copy(ws,1+CIZena+1+CIZena+1+CDocNumer+1,CDate);
     If TempStr<>DateStr Then
      Begin
       PrintDate:=True;
       PrintItog:=True;
      End;
    End
    Else PrintItog:=True;
  End;



    Itogo:=Itogo+StrToReal(Summa);

    If c=(P^.List^.Count-1) Then s:=ONLYLINK+S;

    Writeln(f,Space+' '+s);


  If Sorting = 3 Then
Begin
 If PrintItog Then
 Begin
 Writeln(f,Space,' ── Всего за:'+DateStr+' на сумму: ', RecognizReal(LocLocOpl,CIZena,CMantissaZ),
 ' док-тов: ',LocLocDoc:3,' ───────────');
 DateStr:=TempStr;
 LocLocOpl:=0;
 LocLocDoc:=0;
 End;
 If PrintDate Then
 Writeln(f,Space+'Дата: '+DateStr);
end;

End;{AgKod}
  End;
 Writeln(f,Space+'────────────────────────────────────────────────────────────────────────────');


 MyStr(Itogo,CIZena,CMantissaZ,Summa);

 s:='Всего на сумму: '+Recogniz(Summa)+' руб ';
 Writeln(f,Space+s);
 Writeln(f,Space+'Всего документов: ',P^.List^.Count:8);

 Writeln(f,Space,'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
 Writeln(f,Space+'============================================================================');

 System.Close(f);

 NoInfoMsg;
 ViewAsText(Path^.Dat.ToTemp+'listi.txt','Отчет реестр внутренних перемещений с '+StartDate+' по '+StopDate,True);
 {ReportNew(Path^.Dat.ToTemp+'listi.txt','',NprintC^.DAt.CopyAll,False,False);}
 End;
End;





procedure TReestrIWindow.HandleEvent(var Event: TEvent);
Var test : Word;
    s,s1,s2 : String;
    SDoc : ArtikulStr;
    SDate: TDateString;
    l : Boolean;
    FC:Byte;
    FS : AllStr;
    V: Word;
    Vid : Word;
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
     kbF7 : Begin
              ClearFind;
              Event.What:=evCommand;
              Event.Command:=cmDocFiltr;
              PutEvent(Event);
              ClearEvent(Event);
            End;
     kbF2 : Begin
              ClearFind;
              Event.What:=evCommand;
              Event.Command:=cmChangeDiapason;
              PutEvent(Event);
              ClearEvent(Event);
            End;

      Else;
      End;{KeyDown}

  evCommand :
     Case Event.Command Of

  cmGetName: Begin
              PString(Event.InfoPtr)^ := 'Реестр внутренних перемещений за период с '+StartDate+' по '+StopDate;
              ClearEvent(Event);
              Exit;
             End;

  cmChangeDiapason:Begin
              s1:=StartDate;
              s2:=StopDate;
              If DatePeriodDialog(s1,s2,False) Then
              Begin
              StartDate:=s1;
              StopDate:=s2;
              Refresh;
              ClearEvent(Event);
              PrevCur[0]:=#0;
              SortScreenList(True);
              Redraw;
              End;
                            End;
  cmDocFiltr:Begin

              If Setup Then
              Begin
              Refresh;
              ClearEvent(Event);
              PrevCur[0]:=#0;
              SortScreenList(True);
              Redraw;
              End;

                ClearEvent(Event);
             End;

  cmRefresh: Begin
  If (DeskTop^.Current=PView(DocReestrWindow)) And (Event.What <> EvKeyDown)
      And Not(Glob.Show) And Not(Glob.ShowMsg) And Not(Glob.GlobalShow) Then
           Begin
              FS:=FindStrok;
              FC:=Ord(FindStrok[0]);
              Refresh;
              ClearEvent(Event);
              PrevCur[0]:=#0;
              SortScreenList(False);
              FindStrok:=FS;
              FindSymbol:=FC;
              Redraw;
           End
           Else
            ClearEvent(Event);
          End;

  cmPrintReestr:    Begin
                 ClearFind;
     If (DocList^.State and sfFocused <> 0) And (DocList^.List<>Nil)And(DocList^.List^.Count>=1) Then
            Begin
                Assistent.EditPosition:=Copy(DocList^.GetText(DocList^.Focused,DocList^.List^.Count),1+CIZena+1+CIZena+1,
			 CDocNumer);
                DelSpace(Assistent.EditPosition);
                DelZerro(Assistent.EditPosition);
                {Assistent.D:=DocDate;}
                s:=DocList^.GetText(DocList^.Focused,DocList^.List^.Count);
                Assistent.D:=Copy(s,1+CIZena+1+CIZena+1+CDocNumer+1,CDate);
                         {Copy(s,Ord(s[0])-CArtikul-1-CDAte-1-CMantissa,CDate);}

                DelSpace(Assistent.D);
                {Status:=DocPrint;}
                PrintTransport(Assistent);
                {Status:=DocNormal;}
            End
            End;

 cmReestrReport:    Begin
                 ClearFind;
     If (DocList^.List<>Nil)And(DocList^.List^.Count>=1) Then
            Begin
             FormReport(DocList);
            End
            End;


cmFullView: Begin
                 ClearFind;
     If (DocList^.State and sfFocused <> 0) And (DocList^.List<>Nil)And(DocList^.List^.Count>=1) Then
            Begin
                Assistent.EditPosition:=Copy(DocList^.GetText(DocList^.Focused,DocList^.List^.Count),1+CIZena+1+CIZena+1,
			 CDocNumer);
                DelSpace(Assistent.EditPosition);
                DelZerro(Assistent.EditPosition);
                {Assistent.D:=DocDate;}
                s:=DocList^.GetText(DocList^.Focused,DocList^.List^.Count);
                Assistent.D:=Copy(s,1+CIZena+1+CIZena+1+CDocNumer+1,CDate);
                         {Copy(s,Ord(s[0])-CArtikul-1-CDAte-1-CMantissa,CDate);}

                DelSpace(Assistent.D);
                {Status:=DocPrint;}
                ViewTrans^.FullScreenTrans(Assistent);
                {Status:=DocNormal;}
            End
            End;

     cmReestrIDoc:Begin
                  ClearFind;
                  ClearEvent(Event);
                 End;
     cmCancel    : Begin
                 Dispose(NoScreenList,Done);
                 ClearFind;
                 Event.What:=evCommand;
                 Event.Command:=cmClose;
                 PutEvent(Event);
                 ClearEvent(Event);
                 PrevCur[0]:=#0;
                End;

      Else;
      End;{evCommand}
      Else;
      End;{*Case*}

  if (Event.What = evBroadcast) and
    (Event.Command = cmReestrIDoc) then ClearEvent(Event);

  if (Event.What = evBroadcast) and
    (Event.Command = cmQuit) then ClearEvent(Event);


  inherited HandleEvent(Event);


  If (Desktop^.Current=PView(DocReestrWindow)) And (Event.What <> EvKeyDown) Then
             Begin

                if (ControlSort^.State and sfFocused <> 0)Then
                    Begin
                        ControlSort^.GetData(Test);
                        If Test <> Sorting Then
                        Begin
                           ClearFind;
                           Sorting:=Test;
                           SortScreenList(False);
                           Redraw;
                        End;
                    End;

                if (ControlDirection^.State and sfFocused <> 0)Then
                    Begin
                        ControlDirection^.GetData(Test);
                        If Test <> Direction Then
                        Begin
                           ClearFind;
                           Direction:=Test;
                           SortScreenList(False);
                           Redraw;
                        End;
                    End;

         End;
end;



Var c,Ver : Word;


BEgin
Direction:=0;
Sorting:=0;
Izmen:=0;

M3[1]:=1;
M3[2]:=1;
M3[3]:=1;



StartDAte:=FDAte;
StopDate:=FDAte;
RegimExt:=0;

For c:=1 To CDivision Do
Begin
FiltrOtdel1[c]:=1;
FiltrOtdel2[c]:=1;
End;

{
 Ver := DosVersion;
 Writeln('This is DOS version ', Lo(Ver), '.',Hi(Ver));
 Writeln('This is DOS version ', Ver);

 Readln;
}


End.