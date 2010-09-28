{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}

{$I Compile.INC}

Unit ReestrZ;

Interface


Uses Dialogs,Drivers,{Glob,}Access,MyCalc,ServStr,
     CorMrk,Glob,ViewMrk;

Type
  PReestrZWindow = ^TReestrZWindow;
  TReestrZWindow = object(TDialog)
    ViewMrk: PFullScreenMrk;
    constructor Init(Var l: Boolean);
    procedure OpenReestrZWindow;
    procedure FullPreview;
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure DrawCurrent;
    procedure SortScreenList(Logik:Boolean);
    procedure NetUnLock;
    Procedure FormReport(Const p:PBox);
    Procedure FormReportRegion(Const p:PBox);
    procedure Refresh;
  end;


Implementation


uses DBEngine,Objects, Views, MsgBox,{Vision,Calc,}Dos,Vision4,TpDate,
     App, ColorTxt,Serv,{InpLong,{Validate,}Tools,Printers,Mail,Prise,Utils3,
     Utils,DbEngin2,ServStr2,ReplAgnt,
     Utils5,ComboBox,NetDbEng,Net,Net2,Protect,Utils1,Vision8,Validate;

const cmEditStatus = 401;

var
 NoScreenList,DocList : PBox;
 ControlActiv,ControlAgent,
 ControlEdit,ControlSort,ControlDirection,ControlVidDoc,ControlAllDoc,ControlAllSumma,
 ControlAllSkid,ControlAllTara,ControlAllClient,ControlSf,
 ControlSertifFiltr,ControlAuto,ControlStatus,
 ControlPeriod,ControlTimeC,
 ControlFiltr,ControlModifyDate,ControlRefreshTime,ControlCombo: PView;
 PrevCur : String;
 DocReestrWindow:PReestrZWindow;
 DocDate : TDateString;
 Izmen,Direction ,Sorting,ClientStatus : Word;
 StartTime:LongInt;
 RefreshTime:LongInt;
 ActivMas:Maska2;
 M3:Maska3;
 sertif2:Maska2;
 StartDate,StopDate:TDAteString;

 FiltrDoc : MAska9;
{$IFNDEF RemoteClient}
 FiltrStatus : MAska3;
{$ELSE}
 FiltrStatus : MAska5;
{$ENDIF}
 Auto : Word;
 DateTrans : TDateString;
 Sertifword,Activ,FiltrSf,Filtr,FiltrR : Word;
 RegimExt:Word;



function SelectStatus(VAr Res : Word) : Boolean;
var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  c : Word;

begin
SelectStatus:=False;
R.Assign(17, 9, 62, 16);
New(Dlg, Init(R, 'Введите статус документа'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx:= $E002;

R.Assign(1, 1, 44, 6);
Control := New(PRadioButtons, Init(R,
  NewSItem('0 - оформление',
  NewSItem('1 - подписан',
  NewSItem('2 - отправлен',
  NewSItem('3 - удален',
  NewSItem('4 ',
  NewSItem('5 - подтвержден',
  NewSItem('6 - анулирован',

   Nil)))))))));
Dlg^.Insert(Control);

Dlg^.SelectNext(False);
Dlg^.SetDAta(Res);

c:=Desktop^.ExecView(Dlg);
if c<>cmCancel Then
Begin
 Dlg^.GetData(c);
 SelectStatus:=True;
 Res:=c;
End;
Dispose(Control,Done);
Dispose(Dlg,Done);
end;



function SelectStatusOformlenie(VAr Res : Word) : Boolean;
var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  c : Word;

begin
SelectStatusOformlenie:=False;
R.Assign(17, 9, 62, 15);
New(Dlg, Init(R, 'Введите статус документа'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx:= $E002;

R.Assign(1, 1, 44, 4);
Control := New(PRadioButtons, Init(R,
  NewSItem('0 - проект',
  NewSItem('1 - оформлен',
  NewSItem('2 - аннулирован',
  Nil)))));
Dlg^.Insert(Control);

Dlg^.SelectNext(False);
Dlg^.SetDAta(Res);

c:=Desktop^.ExecView(Dlg);
if c<>cmCancel Then
Begin
 Dlg^.GetData(c);
 SelectStatusOformlenie:=True;
 Res:=c;
End;
Dispose(Control,Done);
Dispose(Dlg,Done);
end;


Function SelectProcessingStatus(CurStatus:Word):word;
var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  c : Word;

begin
SelectProcessingStatus:=CurStatus;
R.Assign(26, 9, 53, 14);
New(Dlg, Init(R, 'Процессинг заказа'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx:=$E002;


R.Assign(1, 1, 26, 4);
Control := New(PRadioButtons, Init(R,
  NewSItem('Редактируется',
  NewSItem('Готов к отборке',
  NewSItem('Готов к отгрузке',
  Nil)))));
Dlg^.Insert(Control);

Dlg^.SelectNext(False);
Dlg^.SetData(CurStatus);
c:=Desktop^.ExecView(Dlg);
If c<>cmCAncel Then
 Begin
  Dlg^.GetData(CurStatus);
  SelectProcessingStatus:=CurStatus;
 End
 Else
 SelectProcessingStatus:=10;

Dispose(Control,Done);
Dispose(Dlg,Done);

end;






Function Setup:Boolean;

Label 1;

Type MyType=Record
    Docs : Word;
    Operation : Word;
    ZakazStatus : Word;
    Tovar: Word;
    Akt  : Word;
    Modify: Word;
    Trans : TDAteString;
    Ext: Word;
  end;

var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  VVV : MyType;
  c : Word;
  L : LongInt;
  TestD : TDateString;

begin
Setup:=FAlse;

With VVV Do
 Begin
Modify:=Izmen;
Tovar:=SertifWord;
Akt:=Activ;

Convert9(FiltrDoc);
BitToWord9(FiltrDoc,c);
Docs:=c;

{$IFNDEF RemoteClient}
Convert3(FiltrStatus);
BitToWord3(FiltrStatus,c);
ZakazStatus:=c;
{$ELSE}
Convert5(FiltrStatus);
BitToWord5(FiltrStatus,c);
ZakazStatus:=c;
{$ENDIF}

Convert3(M3);
BitToWord3(M3,Filtr);
Operation:=Filtr;
Ext := RegimExt;
Trans:=DateTrans;
End;

1:
R.Assign(4, 9, 76, 20);
New(Dlg, Init(R, 'Параметры реестра заказов'));
Dlg^.Options := Dlg^.Options or ofCenterX;
Dlg^.HelpCtx:=$E002;

R.Assign(1, 2, 34, 5);
Control := New(PCheckboxes, Init(R,
  NewSItem('Списо~к~',
  NewSItem('Тов.ч~е~к',
  NewSItem('Фи~з~.лиц',
  NewSItem('С~Ф~',
  NewSItem('СФБ',
  NewSItem('Д*',
  NewSItem('ДСФ',
  NewSItem('Д',
  NewSItem('~Д~СФБ', Nil)))))))))));
Dlg^.Insert(Control);

  R.Assign(1, 1, 16, 2);
  Dlg^.Insert(New(PLabel, Init(R, 'Вид документа:', Control)));

R.Assign(35, 2, 50, 5);
Control := New(PCheckboxes, Init(R,
  NewSItem('К~л~иент',
  NewSItem('~С~клад',
  NewSItem('~О~бмен', Nil)))));
Dlg^.Insert(Control);

  R.Assign(35, 1, 49, 2);
  Dlg^.Insert(New(PLabel, Init(R, 'Вид опреаций:', Control)));

{$IFNDEF RemoteClient}
R.Assign(51, 2, 71, 5);
Control := New(PCheckboxes, Init(R,
  NewSItem('Не оформленные',
  NewSItem('Офо~р~мленные',
  NewSItem('~А~нулированные', Nil)))));
Dlg^.Insert(Control);

  R.Assign(51, 1, 66, 2);
  Dlg^.Insert(New(PLabel, Init(R, 'Статус заказа:', Control)));
{$ELSE}
R.Assign(51, 1, 71, 6);
Control := New(PCheckboxes, Init(R,
  NewSItem('Оформленные',
  NewSItem('Подписанные',
  NewSItem('Отправленные',
  NewSItem('Подтвержденные',
  NewSItem('Анулированные',
  Nil)))))));
Dlg^.Insert(Control);
{$ENDIF}

R.Assign(1, 6, 34, 8);
Control := New(PCheckboxes, Init(R,
  NewSItem('~Т~овар',
  NewSItem('Сопроводительные документ~ы~', Nil))));
Dlg^.Insert(Control);

  R.Assign(1, 5, 15, 6);
  Dlg^.Insert(New(PLabel, Init(R, 'Вид отгрузки:', Control)));

R.Assign(35, 6, 50, 8);
Control := New(PCheckboxes, Init(R,
  NewSItem('~П~ассивные',
  NewSItem('Актив~н~ые', Nil))));
Dlg^.Insert(Control);

  R.Assign(34, 5, 44, 6);
  Dlg^.Insert(New(PLabel, Init(R, '"Бон~у~сы":', Control)));



{$IFNDEF RemoteClient}
R.Assign(51, 6, 71, 7);
{$ELSE}
R.Assign(51, 7, 71, 8);
{$ENDIF}
If StrToInt(CurrentPassword)=0 Then
Control := New(PCheckboxes, Init(R,
  NewSItem('Из~м~ененные', Nil)))
Else
 Begin
Control := New(PCheckboxes, Init(R,
  NewSItem('??????????', Nil)));
  Control^.Options := Control^.Options and not ofSelectable;

 End;
Dlg^.Insert(Control);


{$IFNDEF RemoteClient}
  R.Assign(51, 5, 66, 6);
{$ELSE}
  R.Assign(51, 6, 66, 7);
{$ENDIF}
  Dlg^.Insert(New(PLabel, Init(R, 'Дополнительно:', Control)));


R.Assign(24, 9, 34, 10);
Control := New(PInputLine, Init(R, CDAte));
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PPXPictureValidator, Init(DateFiltr, True));

  R.Assign(9, 9, 24, 10);
  Dlg^.Insert(New(PLabel, Init(R, 'Срок доста~в~ки:', Control)));


{$IFNDEF RemoteClient}
R.Assign(51, 8, 71, 9);
{$ELSE}
R.Assign(51, 9, 71, 10);
{$ENDIF}
Control := New(PCheckboxes, Init(R,
  NewSItem('Сводный', Nil)));
Dlg^.Insert(Control);

{$IFNDEF RemoteClient}
  R.Assign(51, 7, 63, 8);
{$ELSE}
  R.Assign(51, 8, 63, 9);
{$ENDIF}
  Dlg^.Insert(New(PLabel, Init(R, 'Вид отчета:', Control)));

Dlg^.SelectNext(False);

Dlg^.SetData(VVV);

c:=Desktop^.ExecView(Dlg);
If c<>cmCancel Then
Begin
 Setup:=True;
 Dlg^.GetData(VVV);

 TestD:=VVV.Trans;
 If TestD[0]<>#0 Then
  Begin
   If Not TestDate(TestD,l) Then
    Begin
     Dispose(Control,Done);
     Dispose(Dlg,Done);
     Goto 1;
    End
    Else
    DateTrans:=TestD;
  End
  Else
    DateTrans:=TestD;

With VVV Do
 Begin
Izmen:=Modify;
Activ:=Akt;
SertifWord:=Tovar;
RegimExt:=Ext;


WordToBit9(Docs,FiltrDoc);
{Convert9(FiltrDoc);}


{$IFNDEF RemoteClient}
WordToBit3(ZakazStatus,FiltrStatus);
{$ELSE}
WordToBit5(ZakazStatus,FiltrStatus);
{$ENDIF}


WordToBit3(Operation,M3);
{Convert3(M3);}

 End;

End;

{$IFNDEF RemoteClient}
Convert3(FiltrStatus);
{$ELSE}
Convert5(FiltrStatus);
{$ENDIF}
Convert3(M3);
Convert9(FiltrDoc);
Dispose(Control,Done);
Dispose(Dlg,Done);
end;



procedure TReestrZWindow.DrawCurrent;
VAr S,s1 : String;
    R : TRect;
    TempS : AllStr;
Begin

If (DocList^.List<>Nil)And(DocList^.List^.Count>=1) Then
  Begin

   Dispose(ControlModifyDate,Done);
   s:=Copy(DocList^.GetText(DocList^.Focused,DocList^.List^.Count),1+CClient+1
           +(CDocNumer+1)+1+CDate+1+CDate+1+CIZenaK+1+CIZenaK+1+CKto+1+(1)+1+(1)+1+(1)+1+(Cmantissa)+1+CDate+1,CDate+1+CDAte);
   s[9]:='(';
   s:=s+')';
   R.Assign(8, 21, 27, 22);
   ControlModifyDate := New(PColoredText, Init(R, #3+s, $7E));
   Insert(ControlModifyDate);


   s:=Copy(DocList^.GetText(DocList^.Focused,DocList^.List^.Count),1+CClient+1
           +(CDocNumer+1)+1+CDate+1+CDate+1+CIZenaK+1+CIZenaK+1+CKto+1+(1)+1,COne);

     CAse StrToInt(s) Of
     0:s:='Список';
     1:s:='Тов.чек*';
     2:s:='Физ.лиц.*';
        3:s:='СФ*';
        4:s:='СФ Б';
        5:s:='Дебит*';
        6:s:='Дебит СФ*';
        7:s:='Дебит';
        8:s:='Дебит СФБ';
        Else s:='???';
        End;

        Dispose(ControlVidDoc,Done);
        R.Assign(8, 20, 17, 21);
        ControlVidDoc := New(PColoredText, Init(R, #3+s, $7E));
        Insert(ControlVidDoc);

   s:=Copy(DocList^.GetText(DocList^.Focused,DocList^.List^.Count),1+CClient+1
           +(CDocNumer+1)+1+CDate+1+CDate+1+CIZenaK+1+CIZenaK+1+CKto+1+(1)+1+(1)+1+(1)+1+(CMantissa)+1+CDate+1+
                 CDate+1+CDAte+1,CClient+1+CClientKod);


   Dispose(ControlAgent,Done);
   DelSpaceRight(S);
   Format(TempS,CClient);
   R.Assign(28, 20, 55, 21);
   ControlAgent := New(PColoredText, Init(R, s, $7E));
   Insert(ControlAgent);


   s:=Copy(DocList^.GetText(DocList^.Focused,DocList^.List^.Count),1+CClient+1
           +(CDocNumer+1)+1+CDate+1+CDate+1+CIZenaK+1+CIZenaK+1+CKto+1+(1)+1+(1)+1+(1)+1+(CMAntissa)+1,CDate);
   Dispose(ControlTimeC,Done);
   R.Assign(68, 20, 76, 21);
   ControlTimeC := New(PColoredText, Init(R, #3+s, $7E));
   Insert(ControlTimeC);

{$IFNDEF RemoteClient}
   s:=Copy(DocList^.GetText(DocList^.Focused,DocList^.List^.Count),1+CClient+1
           +(CDocNumer+1)+1+CDate+1+CDate+1+CIZenaK+1+CIZenaK+1+CKto+1+(1)+1+(1)+1,COne);

   Case StrToInt(s) Of
   0:s:='Не оформлен';
   1:Begin
     s1:=Copy(DocList^.GetText(DocList^.Focused,DocList^.List^.Count),1+CClient+1
           +(CDocNumer+1)+1+CDate+1+CDate+1+CIZenaK+1+CIZenaK+1+CKto+1+(1)+1+(1)+1+(1)+1+(CMAntissa)+1+CDate+1+CDate+1+CDAte+1+
                 CClient+1+CClientKod+1+CMAntissa+1,CDocNumer);
     DelSpace(s1);
     DelZerro(s1);
     s:='Оформлен N '+s1+' от ';

     s1:=Copy(DocList^.GetText(DocList^.Focused,DocList^.List^.Count),1+CClient+1
           +(CDocNumer+1)+1+CDate+1+CDate+1+CIZenaK+1+CIZenaK+1+CKto+1+(1)+1+(1)+1+(1)+1+(CMAntissa)+1+CDate+1+CDate+1+CDAte+1+
                 CClient+1++CClientKod+1+CMAntissa+1+CDocNumer+1,CDAte);
     DelSpace(s1);
     s:=s+s1;

     End;
   2:s:='Анулирован';
   Else s:='???';

   End;
{$ELSE}
   s:=DocList^.GetText(DocList^.Focused,DocList^.List^.Count);
   Case StrToInt(copy(s,length(s)-{1}3,1)) of
   0:s:='Формирование (в буфере)';
   1:s:='Подписан (готов к отправке)';
   2:s:='Отправлен';
   3:s:='';
   4:s:='';
   5:s:='Получено подтверждение';
   6:s:='Анулирован';
   end;
{$ENDIF}

   Dispose(ControlStatus,Done);
   R.Assign(36, 21, 67, 22);
   ControlStatus := New(PColoredText, Init(R, #3+s, $5E));
   Insert(ControlStatus);


  End
  Else
   Begin
    If PStaticText(ControlModifyDate)^.Text^<>#3'???' Then
    Begin
    Dispose(ControlModifyDate,Done);
    R.Assign(8, 21, 27, 22);
    ControlModifyDate := New(PColoredText, Init(R, #3+'???', $7E));
    Insert(ControlModifyDate);


    Dispose(ControlVidDoc,Done);
    R.Assign(8, 20, 17, 21);
    ControlVidDoc := New(PColoredText, Init(R, #3+'???', $7E));
    Insert(ControlVidDoc);

    Dispose(ControlAgent,Done);
    R.Assign(28, 20, 55, 21);
    ControlAgent := New(PColoredText, Init(R, #3'???', $7E));
    Insert(ControlAgent);

    Dispose(ControlTimeC,Done);
    R.Assign(68, 20, 76, 21);
    ControlTimeC := New(PColoredText, Init(R, #3+'???', $7E));
    Insert(ControlTimeC);

    Dispose(ControlStatus,Done);
    R.Assign(36, 21, 67, 22);
    ControlStatus := New(PColoredText, Init(R, #3+'???', $5E));
    Insert(ControlStatus);

    End;
   End;

End;


procedure TReestrZWindow.OpenReestrZWindow;
Var l : Boolean;
begin
  if Message(Desktop, evBroadcast, cmReestrZakaz, nil) = nil then
  begin
    L:=True;
    RegimExt:=0;
    StartDate:=DateToDateString(DateMask,DAteStringToDate(DateMask,FDAte)-10);
    StopDate:=FDate;
    DInfo('Инициализация реестра заказов...');
    DocReestrWindow := New(PReestrZWindow, Init(L));
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



Procedure TReestrZWindow.SortScreenList(Logik:Boolean);
Var i,j : Word;
    ws,ws1 : String;
    Doc : ArtikulStr;
         TempBox : PBox;
    R : TRect;
    LongDate : TDateString;
Begin
Dispose(ControlPeriod,Done);

R.Assign(6, 0, 6+Length('Реестр заказов за период с '+StartDate+' по '+StopDate+' (Доставка: ????????)')+2, 1);

If DateTrans[0]=#0 Then
ControlPeriod := New(PColoredText, Init(R, #3+'Реестр заказов за период с '+StartDate+' по '+StopDate+
' (Доставка: ????????)', $4F))
Else
ControlPeriod := New(PColoredText, Init(R, #3+'Реестр заказов за период с '+StartDate+' по '+StopDate+
' (Доставка: '+DateTrans+')', $4F));


ControlPeriod^.Options := ControlPeriod^.Options or ofCenterX;
Insert(ControlPeriod);

{
R.Assign(6, 0, 6+Length('Реестр заказов с '+StartDate+' по '+StopDate)+2, 1);
ControlPeriod := New(PColoredText, Init(R, #3+'Реестр заказов с '+StartDAte+' по '+StopDAte, $4F));
ControlPeriod^.Options := ControlPeriod^.Options or ofCenterX;
Insert(ControlPeriod);
}
DInfoMsg('Сортирую документы...',False);

if (DocList^.List^.Count>0) And Not(Logik) Then
  Doc:=Copy(DocList^.GEtText(DocList^.Focused,DocList^.List^.Count),
      1+CClient+1,CArtikul)
Else Doc[0]:=#0;

R.Assign(0,0,0,0);
TempBox := New(PBox, Init(R, 1, Nil));
TempBox^.NewList(New(PTextCollection, Init(0,1)));

DocList^.NewList(Nil);
DocList^.NewList(New(PMyCollection, Init(0,1)));

If Direction=1 Then
DistanationSorting:=1
Else
DistanationSorting:=0;

If NoScreenList^.List^.Count>0 Then
Begin
{формируем отсортированный список}
For j:=0 to NoScreenList^.List^.Count-1 Do
Begin
 ws:=NoScreenList^.GEtText(j,NoScreenList^.List^.Count);
BEGIN

LongDate:=Copy(ws,1+CClient+1+(CDocNumer+1)+1,CDate);

LongDate:=IntToStr(DateStringToDate(DateMask,LongDate),CDAte);

RFormat(LongDate,CDAte);


Case Sorting Of
{клиент}
0:Begin
   System.Insert(LongDate,ws,1+CClient+1);
  End;
{номер документа}
1:Begin
   ws1:=Copy(ws,1+CClient+1,CDocNumer+1);
   System.Delete(ws,1+CClient+1,(CDocNumer+1)+1);
   ws:=LongDate+ws1+' '+ws;
  End;
{сумма отгрузки}
2:Begin
   ws1:=Copy(ws,1+CClient+1+(CDocNumer+1)+1+CDate+1+CDate+1,CIZenaK);
   RFormatZerro(ws1,CIZenaK);
   {System.Delete(ws,1+CClient+1+CDocNumer+1+CDate+1,CIZena+1);}
   ws:=ws1+' '+ws;
  End;
{сумма скидки}
3:Begin
   ws1:=Copy(ws,1+CClient+1+(CDocNumer+1)+1+CDAte+1+CDate+1+CIZenaK+1,CIZenaK);
   RFormatZerro(ws1,CIZenaK);
   {System.Delete(ws,1+CClient+1+CDocNumer+1+CDAte+1+CIZena+1,CIZena+1);}
   ws:=ws1+' '+ws;
  End;
Else;
End;{CAse}
  TempBox^.List^.Insert(NewStr(ws));
  TempBox^.SetRange(TempBox^.List^.Count);

END; {if StrToInt(copy(s,length(s)-1,1))=ClientStatus}

End;


{форматируем сформированый список под экранную форму}
If TempBox^.List^.Count>0 Then
Begin
For j:=0 to TempBox^.List^.Count-1 Do
Begin
  ws:=TempBox^.GEtText(j,TempBox^.List^.Count);

Case Sorting Of
{клиент}
0:Begin
   System.Delete(ws,1+CClient+1,CDate);
   ws:=ws;
  End;
{N документа}
1:Begin
   System.Delete(ws,1,CDate);
   ws1:=Copy(ws,1,CDocNumer+1);
   System.Delete(ws,1,(CDocNumer+1)+1);
   System.Insert(ws1+'│',ws,1+CClient+1);
  End;
{сумма отгрузки}
2:Begin
   ws1:=Copy(ws,1,CIZenaK);
   System.Delete(ws,1,CIZenaK+1);
   {System.Insert(ws1+'│',ws,1+CClient+1+CDocNumer+1+CDate+1);}
  End;
{сумма скидки}
3:Begin
   ws1:=Copy(ws,1,CIZenaK);
   System.Delete(ws,1,CIZenaK+1);
   {System.Insert(ws1+'│',ws,1+CClient+1+CDocNumer+1+CDAte+1+CIZena+1);}
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

{If Doc[0]=#0 Then}
DocList^.FocusItem(0);
{
Else
DocList^.FocusItem(Location(DocList,Doc,False));}

{$IFDEF RemoteClient}
DocList^.HelpCtx:=$F259;
{$ELSE}
DocList^.HelpCtx:=$F257;
{$ENDIF}


DistanationSorting:=0;
PrevCur[0]:=#0;

End;



Function FindAkzis(N:ArtikulStr):Boolean;
Var E : PZakazType;
    c : Word;
Begin
FindAkzis:=False;
New(E,Init);

If Not GetZakaz(N,E) Then
 Begin
  Dispose(E,Done);
  Exit;
 End;

For c:=1 To E^.Dat.Amount Do
 Begin
  If StrToReal(BakGetField(FAkzisSbor,E^.Dat.MarketElement[c].BazKod,0))>0.009 Then
   Begin
    FindAkzis:=True;
    Break;
   End;
 End;

 Dispose(E,Done);

End;



Procedure TReestrZWindow.Refresh;
Var   Zf : File;
         s: String;
         ws : AllStr;
         AllDoc,AllClient,AllSkid,AllTara,AllSumma : String[CIZena];
         E : PBufHeaderZakazType;
         FPos:Byte;
         SAgent,SVersia,TempArtikul,FS : AllStr;

         Sh,c : Word;
      R : TRect;
      DocNum,DoDate : TDateString;
      cc , Count : Word;
      l,lStart,lStop : LongInt;
      CurStr : TDateString;
      InfoStr : String;
      Txt : Text;
      i : Word;
      Start : LongInt;
      wspom,wsSumma,wsSertifSumma,wsSkidka,wsSertifSkidka : AllStr;
      TempList : PBox;
      TestOtgruska : Boolean;
      StartRashet : Boolean;

Procedure LoadClientFromMemory;
Var c,ch: LongInt;
    clf : File;
  s : String[CSertif];
  CLE : PBufKurzClientType;
  Count : Word;
  St1 : ArtikulStr;
Begin
For ch:=0 To 2 Do
Begin

    Case ch Of
     0:Assign (ClF,Path^.Dat.ToClientBaseIndex+'Client.idx');
     1:Assign (ClF,Path^.Dat.ToClientBaseIndex+'Sklad.idx');
     2:Assign (ClF,Path^.Dat.ToClientBaseIndex+'Barter.idx');
     Else;
     End;{CAse}

c:=IOResult;
Reset (ClF,SizeOf(KurzClientType));
c:=IOResult;
If c=0 Then
Begin
{AInfo('Читаю списки...');}
While Not(Eof(ClF)) Do
 Begin
    New(CLE,Init);
    ReadBufKurzClient(Clf,CLE,Count);
  For c:=1 To Count Do
  Begin
  If ClE^.Point.Dat[c].Employ Then
   Begin
    Format (ClE^.Point.Dat[c].Name,CClient);
    St1:=IntToStr(ClE^.Point.Dat[c].Kod,CClientKod);
    RFormatZerro(St1,CClientKod);
    TempList^.List^.Insert(NewStr(ClE^.Point.Dat[c].Name+'│'+IntToStr(ch,COne)+{ClE^.Point.Dat[c].Kod}st1));
    TempList^.SetRange(TempList^.List^.Count);
   End;{Employ}
  End;{For}
     Dispose(CLE,Done);
 End;{Eof}
System.Close(ClF);
End;{IO=0}
End;{For ch}

End;{LoadClientFromMemory}


Function GetClientFromMemory(S:ArtikulStr;C:Word):AllStr;
Var ls : Word;
    k  : Byte;
    st : String[CALL];

Begin
GetClientFromMemory:='!!!КЛИЕНТ УДАЛЕН!!! ';
RFormatZerro(s,CClientKod);
s:=IntToStr(c,COne)+s;
For ls :=0 To TempList^.List^.Count Do
Begin
St:=TempList^.GetText(ls,TempList^.List^.Count);
k:=Pos('│',St);
ST:=Copy(St,K+1,CArtikul);
If St=S Then
   Begin
    GetClientFromMemory:=Copy(TempList^.GetText(ls,TempList^.List^.Count),1,CClient);
    Break;
   End;
End;
End;{GetClient}





Begin
LStart:=DateStringToDate(DateMask,StartDate);
LStop :=DateStringToDate(DateMask,StopDate);

NoScreenList^.NewList(Nil);
NoScreenList^.NewList(New(PTextCollection, Init(1,1)));

AllDoc[0]:=#0;
AllSkid[0]:=#0;
AllSumma[0]:=#0;
AllClient[0]:=#0;
AllTara[0]:=#0;

{ControlActiv^.GetData(Activ);}
WordToBit2(Activ,ActivMas);
Convert2(ActivMas);

{ControlSertifFiltr^.GetData(sertif2);}
WordToBit2(sertifword,sertif2);
Convert2(sertif2);


Assign(ZF,Path^.Dat.ToMarketIndex+'Zakaz.idx');
i:=IOResult;
Reset(ZF,SizeOf(HeaderZakazType));
i:=IOResult;
If i<>0 Then
 Begin
  MessageBox(^M+#3+'Ошибка открытия файла '+Path^.Dat.ToMarketIndex+'Zakaz.idx',Nil,mfError+
  mfCancelButton);
  Exit;
 End;

{                                                                           опрдокст TimeC    DateM    TimeM
   AgentDocReal DocDate}
{12345678901234567890│12345│12345678│12345678│1234567890│1234567890│123456789012│1│1│1│12345678│12345678│12345678│
1234│1234│12345678}

Start:=FileSize(ZF);

R.Assign(0,0,0,0);
TempList := New(PBox, Init(R, 1, Nil));
TempList^.NewList(New(PTextCollection, Init(1,1)));
TempList^.FocusItem(0);

DInfoMsg('Читаю базу клиентов ...',False);
LoadClientFromMemory;
NoInfoMsg;



While Not(Eof(ZF)) Do
 Begin
  DInfoMsgShkala('Просматриваю реестр заказов объект 1 ...',0,Start,FilePos(ZF));
  New(E,Init);
  Count:=0;
  ReadBufHeaderZakaz(Zf,E,Count);

For cc:=1 To Count Do
Begin
{  If (StrToInt(E^.Point.Dat[cc].SkladKod)=StrToInt(Rek.Kod))Then}

  TestOtgruska:=False;
  If DateTrans[0]<>#0 Then
   Begin
    If (E^.Point.Dat[cc].DateC+E^.Point.Dat[cc].EndDate)=DateStringToDate(DateMask,DateTrans) Then
    TestOtgruska:=True;
   End
  Else TestOtgruska:=True;



If TestOtgruska Then
Begin

  If (E^.Point.Dat[cc].DateC>=LStart)
  And (E^.Point.Dat[cc].DateC<=LStop) Then
   Begin
{$IFNDEF RemoteClient}
   If FiltrStatus[E^.Point.Dat[cc].Oformlenie+1]=1 Then
{$ELSE}
   If ((FiltrStatus[E^.Point.Dat[cc].Status+1]=1) and (E^.Point.Dat[cc].Status<3))
       or ((E^.Point.Dat[cc].Status=5) and (FiltrStatus[4]=1))
       Or ((E^.Point.Dat[cc].Status=6) and (FiltrStatus[5]=1))
	   Then
{$ENDIF}
   If FiltrDoc[E^.Point.Dat[cc].DocSelector+1]=1 Then
   If M3[E^.Point.Dat[cc].OperatorSelector+1]=1 Then
        Begin
  If ((ActivMas[1]=1) And (E^.Point.Dat[cc].AgentKod=0)) Or
     ((ActivMas[2]=1) And (E^.Point.Dat[cc].AgentKod<>0)) Then
      Begin
       If (Izmen=0) Or ((Izmen=1)And(E^.Point.Dat[cc].TimeC<>E^.Point.Dat[cc].TimeM)) Then{фильтр изменения}
        Begin

StartRashet:=True;
{If RegimExt=1 Then StartRashet:=FindAkzis(IntToStr(E^.Point.Dat[cc].Document,CArtikul));}

If StartRashet Then
Begin
         Str(StrToInt(AllDoc)+1:CArtikul,AllDoc);
         DelSpace(AllDoc);
         {s[0]:=#0;}
         s:=GetClientFromMemory(IntToStr(E^.Point.Dat[cc].ClientKod,CClientKod),E^.Point.Dat[cc].OperatorSelector);
         Format(S,CClient);
         s:=s+'│';
         DocNum:=IntToStr(E^.Point.Dat[cc].Document,CDocNumer+1);
         RFormatZerro(DocNum,CDocNumer+1);
         DoDate:=DAteToDateString(DAteMask,
         E^.Point.DAt[cc].DateC+E^.Point.Dat[cc].EndDate);
         Format(DoDate,CDAte);
         s:=s+DocNum+'│'+DAteToDateString(DAteMask,E^.Point.Dat[cc].DateC)+'│'+DoDate;

         MyStr(E^.Point.Dat[cc].SummaZ,CIZena,CMAntissa,wsSumma);

         MyStr(E^.Point.Dat[cc].SertifSummaZ,CIZena,CMAntissa,wsSertifSumma);

         If Sertif2[1]=1 Then
         MyStr(StrToReal(AllSumma)+E^.Point.Dat[cc].SummaZ,CIZena,CMantissa,AllSumma);
         If Sertif2[2]=1 Then
         MyStr(StrToReal(AllSumma)+E^.Point.Dat[cc].SertifSummaZ,CIZena,CMantissa,AllSumma);

         DelSpace(AllSumma);

         If Sertif2[1]=1 Then
           MyStr(StrToReal(AllClient)+E^.Point.Dat[cc].SummaZ+E^.Point.Dat[cc].Skidka
          ,CIZena,CMantissa,AllClient);
         If Sertif2[2]=1 Then
                 MyStr(StrToReal(AllClient)+E^.Point.Dat[cc].SertifSummaZ+E^.Point.Dat[cc].SertifSkidka
          ,CIZena,CMantissa,AllClient);
           DelSpace(AllClient);

         If Sertif2[1]=1 Then
           E^.Point.Dat[cc].SummaZ:=E^.Point.Dat[cc].SummaZ+E^.Point.Dat[cc].Skidka
         Else E^.Point.Dat[cc].SummaZ:=0;

         If Sertif2[2]=1 Then
           E^.Point.Dat[cc].SummaZ:=E^.Point.Dat[cc].SummaZ+E^.Point.Dat[cc].SertifSummaZ+
                 E^.Point.Dat[cc].SertifSkidka;

         MyStr(E^.Point.Dat[cc].SummaZ,CIZenaK,CMAntissa,wsSumma);

         s:=s+'│'+wsSumma+'│';


         If Sertif2[1]=1 Then
         E^.Point.Dat[cc].Skidka:=E^.Point.Dat[cc].Skidka
         Else E^.Point.Dat[cc].Skidka:=0;


         If Sertif2[2]=1 Then
         E^.Point.Dat[cc].Skidka:=E^.Point.Dat[cc].Skidka+E^.Point.Dat[cc].SertifSkidka;


         MyStr(StrToReal(AllSkid)+E^.Point.Dat[cc].Skidka,CIZena,CMantissa,AllSkid);
         DelSpace(AllSkid);

         MyStr(E^.Point.Dat[cc].Skidka,CIZenaK,CMAntissa,wsSkidka);

         s:=s+wsSkidka+'│';

{                                            опрдокст TimeC    DateM    TimeM   AgentDocReal DocDate}
{12345678901234567890│12345│12345678│12345678│1234567890│1234567890│123456789012│1│1│1│1│12345678│12345678│
12345678│1234│1234│12345678}

         ws:=GetOperatorField(FNAme,IntToStr(E^.Point.Dat[cc].Caption,CMantissa));
            Format(Ws,CKto);
         s:=s+ws+'│';

         Str(E^.Point.Dat[cc].OperatorSelector:1,ws);
         s:=s+ws+'│';
         Str(E^.Point.Dat[cc].DocSelector:1,ws);
         s:=s+ws+'│';
         Str(E^.Point.Dat[cc].Oformlenie:1,ws);
         s:=s+ws+'│';
         SVersia:=InttoStr(E^.Point.Dat[cc].Versia,CMantissa);
         RFormatZerro(SVersia,CMAntissa);
            s:=s+SVersia+'│';
         s:=s+TimeToTimeString('hh:mm:ss',E^.Point.Dat[cc].TimeC)+'│';
         s:=s+DateToDateString(DateMask,E^.Point.Dat[cc].DateM)+'│'+
            TimeToTimeString('hh:mm:ss',E^.Point.Dat[cc].TimeM)+'│';

         SAgent:=GetAgentField(FAgent,IntToStr(E^.Point.Dat[cc].AgentKod,CClientKod));
         Format(SAgent,CClient);
         wspom:=IntToStr(E^.Point.Dat[cc].AgentKod,CClientKod);
         RFormatZerro(wspom,CClientKod);
         s:=s+SAgent+' '+wspom+'│';

         wspom:=IntToStr(E^.Point.Dat[cc].SkladKod,CMantissa);
         RFormatZerro(wspom,CMantissa);
         s:=s+'│'+wspom;

         wspom[0]:=#0;
         If E^.Point.Dat[cc].DocReal>0 Then
         wspom:=IntToStr(E^.Point.Dat[cc].DocReal,CDocNumer);
         Format(wspom,CDocNumer);

         s:=s+wspom+'│';

   wspom[0]:=#0;
   If E^.Point.Dat[cc].DocDate>0 Then
   wspom:=DateToDAteString(DateMask,E^.Point.Dat[cc].DocDate)
   Else
   Format(wspom,CDate);

         s:=s+wspom+'│';


         s:=s+IntToStr(E^.Point.Dat[cc].Status,1)+'│';

         s:=s+IntToStr(E^.Point.Dat[cc].Processing,1)+'│';



        If NoScreenList^.List^.Count>=MaxCollectionSize-1 Then
         Begin
          Dispose(E,Done);
          System.Close(Zf);
          NoInfoMsg;
          MessageBox(^M+#3+'Переполнение коллекции!',Nil,mfError+mfCancelButton);
          Exit;
         End;

            NoScreenList^.List^.Insert(NewStr(s));
            NoScreenList^.SetRange(NoScreenList^.List^.Count);

           End;{фильтр измененных}
      End;{Фильтр активных продаж}
        End;{фильтр группы операции}
   End;{фильтр склада}
End;{TestOtgruska}
End;
End;{For}
Dispose(E,Done);
 End;{While}
i:=IOResult;
System.Close(Zf);
i:=IOResult;
NoInfoMsg;




If RegimExt=1 Then
Begin


Assign(ZF,Path^.Dat.ToFantomBaz+'IDX\MARKET\Zakaz.idx');
i:=IOResult;
Reset(ZF,SizeOf(HeaderZakazType));
i:=IOResult;
If i=0 Then
 Begin

Start:=FileSize(ZF);

While Not(Eof(ZF)) Do
 Begin
  DInfoMsgShkala('Просматриваю реестр заказов объект 2 ...',0,Start,FilePos(ZF));
  New(E,Init);
  Count:=0;
  ReadBufHeaderZakaz(Zf,E,Count);

For cc:=1 To Count Do
Begin
  TestOtgruska:=False;

  If DateTrans[0]<>#0 Then
   Begin
    If (E^.Point.Dat[cc].DateC+E^.Point.Dat[cc].EndDate)=DateStringToDate(DateMask,DateTrans) Then
    TestOtgruska:=True;
   End
  Else TestOtgruska:=True;



If TestOtgruska Then
Begin

  If (E^.Point.Dat[cc].DateC>=LStart)
  And (E^.Point.Dat[cc].DateC<=LStop) Then
   Begin
{$IFNDEF RemoteClient}
   If FiltrStatus[E^.Point.Dat[cc].Oformlenie+1]=1 Then
{$ELSE}
   If ((FiltrStatus[E^.Point.Dat[cc].Status+1]=1) and (E^.Point.Dat[cc].Status<3))
       or ((E^.Point.Dat[cc].Status=5) and (FiltrStatus[4]=1))
       or ((E^.Point.Dat[cc].Status=6) and (FiltrStatus[5]=1)) Then
{$ENDIF}


   If FiltrDoc[E^.Point.Dat[cc].DocSelector+1]=1 Then
   If M3[E^.Point.Dat[cc].OperatorSelector+1]=1 Then
        Begin
  If ((ActivMas[1]=1) And (E^.Point.Dat[cc].AgentKod=0)) Or
     ((ActivMas[2]=1) And (E^.Point.Dat[cc].AgentKod<>0)) Then
      Begin
       If (Izmen=0) Or ((Izmen=1)And(E^.Point.Dat[cc].TimeC<>E^.Point.Dat[cc].TimeM)) Then{фильтр изменения}
        Begin

StartRashet:=True;

If StartRashet Then
Begin
         Str(StrToInt(AllDoc)+1:CArtikul,AllDoc);
         DelSpace(AllDoc);
         {s[0]:=#0;}

         s:=GetClientFromMemory(IntToStr(E^.Point.Dat[cc].ClientKod,CClientKod),E^.Point.Dat[cc].OperatorSelector);
         Format(S,CClient);
         s:=s+'│';


         DocNum:=IntToStr(E^.Point.Dat[cc].Document,CDocNumer+1);
         RFormatZerro(DocNum,CDocNumer+1);
         DoDate:=DAteToDateString(DAteMask,
         E^.Point.DAt[cc].DateC+E^.Point.Dat[cc].EndDate);
         Format(DoDate,CDAte);
         s:=s+DocNum+'│'+DAteToDateString(DAteMask,E^.Point.Dat[cc].DateC)+'│'+DoDate;


         MyStr(E^.Point.Dat[cc].SummaZ,CIZena,CMAntissa,wsSumma);

         MyStr(E^.Point.Dat[cc].SertifSummaZ,CIZena,CMAntissa,wsSertifSumma);

         If Sertif2[1]=1 Then
         MyStr(StrToReal(AllSumma)+E^.Point.Dat[cc].SummaZ,CIZena,CMantissa,AllSumma);
         If Sertif2[2]=1 Then
         MyStr(StrToReal(AllSumma)+E^.Point.Dat[cc].SertifSummaZ,CIZena,CMantissa,AllSumma);

         DelSpace(AllSumma);

         If Sertif2[1]=1 Then
           MyStr(StrToReal(AllClient)+E^.Point.Dat[cc].SummaZ+E^.Point.Dat[cc].Skidka
          ,CIZena,CMantissa,AllClient);
         If Sertif2[2]=1 Then
           MyStr(StrToReal(AllClient)+E^.Point.Dat[cc].SertifSummaZ+E^.Point.Dat[cc].SertifSkidka
          ,CIZena,CMantissa,AllClient);
           DelSpace(AllClient);

         If Sertif2[1]=1 Then
           E^.Point.Dat[cc].SummaZ:=E^.Point.Dat[cc].SummaZ+E^.Point.Dat[cc].Skidka
         Else E^.Point.Dat[cc].SummaZ:=0;

         If Sertif2[2]=1 Then
           E^.Point.Dat[cc].SummaZ:=E^.Point.Dat[cc].SummaZ+E^.Point.Dat[cc].SertifSummaZ+
                 E^.Point.Dat[cc].SertifSkidka;

         MyStr(E^.Point.Dat[cc].SummaZ,CIZenaK,CMAntissa,wsSumma);

         s:=s+'│'+wsSumma+'│';


         If Sertif2[1]=1 Then
         E^.Point.Dat[cc].Skidka:=E^.Point.Dat[cc].Skidka
         Else E^.Point.Dat[cc].Skidka:=0;


         If Sertif2[2]=1 Then
         E^.Point.Dat[cc].Skidka:=E^.Point.Dat[cc].Skidka+E^.Point.Dat[cc].SertifSkidka;


         MyStr(StrToReal(AllSkid)+E^.Point.Dat[cc].Skidka,CIZena,CMantissa,AllSkid);
         DelSpace(AllSkid);

         MyStr(E^.Point.Dat[cc].Skidka,CIZenaK,CMAntissa,wsSkidka);

         s:=s+wsSkidka+'│';

{                                            опрдокст TimeC    DateM    TimeM   AgentDocReal DocDate}
{12345678901234567890│12345│12345678│12345678│1234567890│1234567890│123456789012│1│1│1│1│12345678│12345678│
12345678│1234│1234│12345678}

         ws:=GetOperatorField(FNAme,IntToStr(E^.Point.Dat[cc].Caption,CMantissa));
            Format(Ws,CKto);
         s:=s+ws+'│';

         Str(E^.Point.Dat[cc].OperatorSelector:1,ws);
         s:=s+ws+'│';
         Str(E^.Point.Dat[cc].DocSelector:1,ws);
         s:=s+ws+'│';
         Str(E^.Point.Dat[cc].Oformlenie:1,ws);
         s:=s+ws+'│';
         SVersia:=InttoStr(E^.Point.Dat[cc].Versia,CMantissa);
         RFormatZerro(SVersia,CMAntissa);
            s:=s+SVersia+'│';
         s:=s+TimeToTimeString('hh:mm:ss',E^.Point.Dat[cc].TimeC)+'│';
         s:=s+DateToDateString(DateMask,E^.Point.Dat[cc].DateM)+'│'+
            TimeToTimeString('hh:mm:ss',E^.Point.Dat[cc].TimeM)+'│';

         SAgent:=GetAgentField(FAgent,IntToStr(E^.Point.Dat[cc].AgentKod,CClientKod));
         Format(SAgent,CClient);
         wspom:=IntToStr(E^.Point.Dat[cc].AgentKod,CClientKod);
         RFormatZerro(wspom,CClientKod);
         s:=s+SAgent+' '+wspom+'│';

         wspom:=IntToStr(E^.Point.Dat[cc].SkladKod,CMantissa);
         RFormatZerro(wspom,CMantissa);
         s:=s+'│'+wspom;

         wspom[0]:=#0;
         If E^.Point.Dat[cc].DocReal>0 Then
         wspom:=IntToStr(E^.Point.Dat[cc].DocReal,CDocNumer);
         Format(wspom,CDocNumer);

         s:=s+wspom+'│';



   wspom[0]:=#0;
   If E^.Point.Dat[cc].DocDate>0 Then
   wspom:=DateToDAteString(DateMask,E^.Point.Dat[cc].DocDate)
   Else
   Format(wspom,CDate);

         s:=s+wspom+'│';

{новые строки}
         s:=s+IntToStr(E^.Point.Dat[cc].Status,1)+'│';
{статус по процессингу}
         s:=s+IntToStr(E^.Point.Dat[cc].Processing,1)+'│';

        If NoScreenList^.List^.Count>=MaxCollectionSize-1 Then
         Begin
          Dispose(E,Done);
          System.Close(Zf);
          NoInfoMsg;
          MessageBox(^M+#3+'Переполнение коллекции!',Nil,mfError+mfCancelButton);
          Exit;
         End;
            NoScreenList^.List^.Insert(NewStr(s));
            NoScreenList^.SetRange(NoScreenList^.List^.Count);
           End;{фильтр измененных}
      End;{Фильтр активных продаж}
        End;{фильтр группы операции}
   End;{фильтр склада}
End;{TestOtgruska}
End;
End;{For}
Dispose(E,Done);
 End;{While}

i:=IOResult;
System.Close(Zf);
i:=IOResult;
NoInfoMsg;
End{i=0}
Else
  Begin
   MessageBox(^M+#3+'Ошибка открытия файла '+Path^.Dat.ToFantomBaz+'IDX\MARKET\Zakaz.idx',Nil,mfError+
   mfCancelButton);
  End;


End;{If RegimExt=1 Then}











Dispose(TempList,Done);




MyStr(StrToReal(AllSkid),CIZena,CMantissa,AllSkid);
DelSpace(AllSkid);

MyStr(StrToReal(AllSumma),CIZena,CMantissa,AllSumma);
DelSpace(AllSumma);

MyStr(StrToReal(AllClient),CIZena,CMantissa,AllClient);
DelSpace(AllClient);

Str(StrToInt(AllDoc):CArtikul,AllDoc);
DelSpace(AllDoc);

Dispose(ControlAllClient,Done);
R.Assign(63, 22, 78, 23);
ControlAllClient := New(PColoredText, Init(R, #3+AllSumma, $4E));
Insert(ControlAllClient);

Dispose(ControlAllDoc,Done);
R.Assign(42, 22, 47, 23);
ControlAllDoc := New(PColoredText, Init(R, #3+AllDoc, $4E));
Insert(ControlAllDoc);

Dispose(ControlAllSkid,Done);
R.Assign(12, 22, 27, 23);
ControlAllSkid := New(PColoredText, Init(R, #3+AllSkid, $4E));
Insert(ControlAllSkid);


End;



constructor TReestrZWindow.Init(Var l : Boolean);
var
  R : TRect;
  Control : PView;
  C : Word;
  s: TMyString;
  ws : AllStr;
  AllDoc,AllClient,AllSkid,AllTara,AllSumma : String[CIZena];
  E : PSuperMarketType;
begin
L:=False;

{$IFNDEF RemoteClient}
FiltrStatus[1]:=1;
FiltrStatus[2]:=0;
FiltrStatus[3]:=0;
{$ELSE}
FiltrStatus[1]:=1;
FiltrStatus[2]:=1;
FiltrStatus[3]:=0;
FiltrStatus[4]:=0;
FiltrStatus[5]:=0;
{$ENDIF}


FiltrDoc[1]:=1;
FiltrDoc[2]:=1;
FiltrDoc[3]:=1;
FiltrDoc[4]:=1;
FiltrDoc[5]:=1;
FiltrDoc[6]:=1;
FiltrDoc[7]:=1;
FiltrDoc[8]:=1;
FiltrDoc[9]:=1;

DateTrans[0]:=#0;



R.Assign(0, 0, 80, 23);
inherited Init(R, ''{'Реестр документов отгрузки товара со склада с '+StartDate+' по '+StopDate});
Options := Options or ofCenterX or ofCenterY;
HelpCtx:=$E002;




R.Assign(0, 0, 0, 0);
NoScreenList := New(PBox, Init(R, 1, Nil));
NoScreenList^.NewList(New(PTextCollection, Init(1,1)));
AllDoc[0]:=#0;
AllSkid[0]:=#0;
AllTara[0]:=#0;
AllSumma[0]:=#0;
AllClient[0]:=#0;

NoScreenList^.FocusItem(0);


MyStr(StrToReal(AllSkid),CIZena,CMantissa,AllSkid);
DelSpace(AllSkid);

MyStr(StrToReal(AllSumma),CIZena,CMantissa,AllSumma);
DelSpace(AllSumma);

Str(StrToInt(AllDoc):CLitrMantissa,AllDoc);
DelSpace(AllDoc);

MyStr(StrToReal(AllClient),CIZena,CMantissa,AllClient);
DelSpace(AllClient);

R.Assign(6, 0, 6+Length('Реестр заказов за период с '+StartDate+' по '+StopDate+' (Доставка: ????????)')+2, 1);

If DateTrans[0]=#0 Then
ControlPeriod := New(PColoredText, Init(R, #3+'Реестр заказов за период с '+StartDate+' по '+StopDate+
' (Доставка: ????????)', $4F))
Else
ControlPeriod := New(PColoredText, Init(R, #3+'Реестр заказов за период с '+StartDate+' по '+StopDate+
' (Доставка: '+DateTrans+')', $4F));


ControlPeriod^.Options := ControlPeriod^.Options or ofCenterX;
Insert(ControlPeriod);


R.Assign(13, 1, 63, 2);
ControlSort := New(PRadioButtons, Init(R,
  NewSItem('Кл~и~ент',
  NewSItem('N ~д~ок.',
  NewSItem('Отгр~у~зка',
  NewSItem('Скидка', Nil))))));
ControlSort^.SetData(Sorting);
Insert(ControlSort);

  R.Assign(1, 1, 13, 2);
  Insert(New(PLabel, Init(R, 'Сортировка:', ControlSort)));

R.Assign(64, 1, 78, 2);
ControlDirection := New(PRadioButtons, Init(R,
  NewSItem(#30,
  NewSItem(#31, Nil))));

ControlDirection^.SetData(Direction);
Insert(ControlDirection);

Convert3(M3);
BitToWord3(M3,Filtr);

Convert3(M3);

Convert2(ActivMas);
BitToWord2(ActivMas,Activ);

Convert2(Sertif2);
BitToWord2(sertif2,sertifword);
Convert2(sertif2);

Auto:=0;


If StrToInt(CurrentPassword)=0 Then
Begin

R.Assign(68, 2, 73, 3);
ControlAuto := New(PCheckboxes, Init(R,NewSItem('~А~', Nil)));
ControlAuto^.SetDAta(Auto);
Insert(ControlAuto);

R.Assign(73, 2, 77, 3);
ControlRefreshTime := New(PInputLine, Init(R, 2));
Insert(ControlRefreshTime);

s:=IntToStr(RefreshTime,2);
DelSpace(s);
ControlRefreshTime^.SetData(s);

  R.Assign(77, 2, 80, 3);
  ControlCombo := New(PCombo, Init(R, PInputLine(ControlRefreshTime), cbxOnlyList or cbxDisposesList or cbxNoTransfer,
    NewSItem('│10',
    NewSItem('│15',
    NewSItem('│20',
    NewSItem('│25',
    NewSItem('│30',
    NewSItem('│35',
    NewSItem('│40',
    NewSItem('│45',
    NewSItem('│50',
    NewSItem('│55',
    NewSItem('│60',
    NewSItem('│65',
    NewSItem('│70',
    NewSItem('│75',
    NewSItem('│80',
    NewSItem('│85',
    NewSItem('│90',
    NewSItem('│95',
    Nil))))))))))))))))))));
  PCombo(ControlCombo)^.ActivateChar('*');
{$IFNDEF NetVersion}
  ControlCombo^.Options := ControlCombo^.Options and not ofSelectable;
{$ENDIF}
  Insert(ControlCombo);
End
Else
 Begin

R.Assign(68, 2, 73, 3);
ControlAuto := New(PCheckboxes, Init(R,NewSItem('~А~', Nil)));
ControlAuto^.SetDAta(Auto);
Insert(ControlAuto);

R.Assign(73, 2, 77, 3);
ControlRefreshTime := New(PInputLine, Init(R, 2));
Insert(ControlRefreshTime);

s:=IntToStr(RefreshTime,2);
DelSpace(s);
ControlRefreshTime^.SetData(s);

  R.Assign(77, 2, 80, 3);
  ControlCombo := New(PCombo, Init(R, PInputLine(ControlRefreshTime), cbxOnlyList or cbxDisposesList or cbxNoTransfer,
    NewSItem('│10',
    NewSItem('│15',
    NewSItem('│20',
    NewSItem('│25',
    NewSItem('│30',
    NewSItem('│35',
    NewSItem('│40',
    NewSItem('│45',
    NewSItem('│50',
    NewSItem('│55',
    NewSItem('│60',
    NewSItem('│65',
    NewSItem('│70',
    NewSItem('│75',
    NewSItem('│80',
    NewSItem('│85',
    NewSItem('│90',
    NewSItem('│95',
    Nil))))))))))))))))))));
  PCombo(ControlCombo)^.ActivateChar('*');
{$IFNDEF NetVersion}
  ControlCombo^.Options := ControlCombo^.Options and not ofSelectable;
{$ENDIF}
  Insert(ControlCombo);
 End;

R.Assign(79, 3, 80, 20);
Control := New(PScrollBar, Init(R));
Insert(Control);


R.Assign(0, 3, 79, 20);
DocList := New(PBox, Init(R, 1, PScrollbar(Control)));
DocList^.NewList(New(PMyCollection, Init(0,1)));
DocList^.FocusItem(0);

{$IFDEF RemoteClient}
DocList^.HelpCtx:=$F259;
{$ELSE}
DocList^.HelpCtx:=$F257;
{$ENDIF}

Insert(DocList);

  R.Assign(1, 2, 68, 3);
{ Insert(New(PLabel, Init(R, ' Клиент               N   Время    Сумма отгрузки   Сумма скидки  Т ', DocList)));}
  Insert(New(PLabel, Init(R, ' Клиент             Заказ  Дата    Срок До  Сумма отгр.Сумма скид', DocList)));

{
R.Assign(2, 20, 10, 21);
ControlSf := New(PCheckboxes, Init(R,
  NewSItem('С~Ф~', Nil)));
Insert(ControlSf);
ControlSf^.SetData(FiltrSf);
}

R.Assign(4, 20, 8, 21);
Control := New(PColoredText, Init(R, 'Вид:', $74));
Insert(Control);

R.Assign(8, 20, 17, 21);
ControlVidDoc := New(PColoredText, Init(R, #3, $7E));
Insert(ControlVidDoc);


R.Assign(22, 20, 28, 21);
Control := New(PColoredText, Init(R, 'Агент:', $74));
Insert(Control);

R.Assign(28, 20, 55, 21);
ControlAgent := New(PColoredText, Init(R, #3+'', $7E));
Insert(ControlAgent);

R.Assign(60, 20, 68, 21);
Control := New(PColoredText, Init(R, 'Выписан:', $74));
Insert(Control);

R.Assign(68, 20, 76, 21);
ControlTimeC := New(PColoredText, Init(R, #3+'', $7E));
Insert(ControlTimeC);

R.Assign(4, 21, 8, 22);
Control := New(PColoredText, Init(R, 'Изм:', $74));
Insert(Control);

R.Assign(8, 21, 27, 22);
ControlModifyDate := New(PColoredText, Init(R, #3+'', $7E));
Insert(ControlModifyDate);

R.Assign(29, 21, 36, 22);
Control := New(PColoredText, Init(R, 'Статус:', $74));
Insert(Control);

R.Assign(36, 21, 67, 22);
ControlStatus := New(PColoredText, Init(R, #3+'', $5E));
Insert(ControlStatus);


R.Assign(51, 22, 63, 23);
Control := New(PColoredText, Init(R, ' ў К оплате:', $74));
Insert(Control);


R.Assign(63, 22, 78, 23);
ControlAllClient := New(PColoredText, Init(R, #3+AllClient, $4E));
Insert(ControlAllClient);


R.Assign(33, 22, 42, 23);
Control := New(PColoredText, Init(R, ' Док-тов:', $74));
Insert(Control);


R.Assign(42, 22, 47, 23);
ControlAllDoc := New(PColoredText, Init(R, #3+AllDoc, $4E));
Insert(ControlAllDoc);



R.Assign(2, 22, 12, 23);
Control := New(PColoredText, Init(R, ' ў Скидка:', $74));
Insert(Control);

R.Assign(12, 22, 27, 23);
ControlAllSkid := New(PColoredText, Init(R, #3+AllSkid, $4E));
Insert(ControlAllSkid);



SelectNext(False);
SelectNext(False);
SelectNext(False);
SelectNext(False);
SelectNext(False);
SelectNext(False);
SelectNext(False);
SelectNext(False);
SelectNext(False);
SelectNext(False);

{If StrToInt(CurrentPassword)=0 Then SelectNext(False);}

L:=True;
Refresh;
PrevCur[0]:=#0;
SortScreenList(True);
StartTime:=TimeStringToTime('hh:mm:ss',Times);
end;




procedure TReestrZWindow.FullPreview;
Var Ass : DocumentEditZ;
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
If (DocList^.List<>Nil)And(DocList^.List^.Count>=1) Then
Begin
  Ass.EditPosition:=Copy(DocList^.GetText(DocList^.Focused,DocList^.List^.Count),1+CClient+1,CDocNumer+1);
  DelSpace(Ass.EditPosition);
  DelZerro(Ass.EditPosition);
  s:=DocList^.GetText(DocList^.Focused,DocList^.List^.Count);
  Ass.D:=Copy(DocList^.GetText(DocList^.Focused,DocList^.List^.Count),1+CClient+1+(CDocNumer+1)+1,CDAte);;

  DelSpace(Ass.D);

{$IFNDEF RemoteClient}
  ViewMrk^.FullScreenMrk(Ass,True);
{$ELSE}
  if not OtvetFullPreview(Ass)
  then ViewMrk^.FullScreenMrk(Ass,True);
{$ENDIF}


End;
End;


Procedure TReestrZWindow.NetUnLock;
Var Ass : DocumentEditZ;
     s : String;
Begin
If (DocList^.List<>Nil)And(DocList^.List^.Count>=1) Then
Begin
  If Password(2) Then
  Begin
  Ass.EditPosition:=Copy(DocList^.GetText(DocList^.Focused,DocList^.List^.Count),1+CClient+1,CDocNumer+1);
  DelSpace(Ass.EditPosition);
  DelZerro(Ass.EditPosition);
  s:=DocList^.GetText(DocList^.Focused,DocList^.List^.Count);
  Ass.D:=Copy(DocList^.GetText(DocList^.Focused,DocList^.List^.Count),1+CClient+1+
  (CDocNumer+1)+1,CDate);

  {Ass.D:=DocDate;}
  DelSpace(Ass.D);
  Repeat
  Until (UnLockZakaz(Ass.EditPosition) in [0,2]);
  MessageBox(^M+#3'Заказ N '+Ass.EditPosition+' от '+Ass.D+' '+
  'успешно деблокирован!',Nil,mfInformation+mfCancelButton);
  End;
end;
End;


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




Procedure TReestrZWindow.FormReport(Const P:PBox);
Const Space=' ';
Var f : text;
         SVersia,Skidka,Summa,ws,s : String;
         Itogo,ISkid,NDS20,NDS10,NDS_ : Array[0..8] Of Real;
         c,k : Word;
         Open : String;
      As : DocumentEditZ;
      Tip : Word;
      NDS,LocNDS,LocNDS20,LocNDS10,LocNDS_:Real;
      Agent : PBox;
      AgKod : AllStr;
      SkKod : ArtikulStr;
      R : TRect;
Begin


If (P^.List<>Nil) And (P^.List^.Count>=1) Then
 Begin
 Assign (f,Path^.Dat.ToTemp+'listz1.txt');
 c:=0;
 Rewrite(f);
 c:=IOResult;
 If c<>0 Then
  Begin
        MessageBox(#3^m+#3+'Не могу создать файл '+Path^.Dat.ToTemp+'listz1.txt',Nil,mfError+mfCancelButton);
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
 1:Writeln(f,Space+'"Номер заказа"');
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

 Writeln(f,Space+'Включены в рассмотрение заказы со статусом:');
 Write(f,Space);
 For c:=1 To Max3 Do
  Begin
   If FiltrStatus[c]=1 Then
    Case c Of
    1:Write(f,' "Не оформлен" ');
    2:Write(f,' "Оформлен" ');
    3:Write(f,' "Анулирован" ');
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


 Writeln(f);

 If Izmen=1 Then
 Begin
  Writeln(f,Space+'Внимание! В справку включены только изменявшиеся документы!');
  Writeln(f);
 End;

 If RegimExt=1 Then Writeln(f,Space+'По 2-ум объектам');

 Writeln(f);

 Writeln(f,Space+'РЕЕСТР ЗАКАЗОВ ТОВАРА И СОПРОВОД.ДОКУМ-ОВ '+' с '+StartDate+' по '+StopDate+
 ' ('+FDate+' '+Times+')');

 If DateTrans[0]<>#0 Then
 Writeln(f,Space+'Доставка: '+DateTrans);
(*
 Writeln(f,Space+'Выбраны следующие агенты:');
 For c:=0 To Agent^.List^.Count-1 Do
  Begin
   s:=Agent^.GetText(c,Agent^.List^.Count);

   AgKod:=Copy(s,1+1,CClientKod);

   S:=GetAgentField(FClient,AgKod);
   Format(s,CClient);
   s:=s+' ('+AgKod+')';
   Writeln(f,Space+s);
  End;
*)

 Writeln(f,Space+'┌───────────────────┬─────┬────────┬────────┬──────────┬──────────┬───────┬────────┬──────┐');
 Writeln(f,Space+'│Клиент             │Заказ│ Дата   │Срок До │Сумма отг.│Сумма скид│Вид док│Оператор│Склад │');
 Writeln(f,Space+'└───────────────────┴─────┴────────┴────────┴──────────┴──────────┴───────┴────────┴──────┘'+HeaderStop);
                 {12345678901234567890-12345-12345678-12345678-1234567890-1234567890-1234567-12345678-123456}


 For c:=0 To 8 Do
 Begin
  ISkid[c]:=0;
  Itogo[c]:=0;
 End;


 For c:=0 To P^.List^.Count-1 Do
  Begin
     DInfoMsgShkala('Формирую отчет ...',0,P^.List^.Count-1,c);
        s := P^.GetText(c,P^.List^.Count);

AgKod:=Copy(s,1+CClient+1
           +(CDocNumer+1)+1+CDate+1+CDate+1+CIZenaK+1+CIZenaK+1+CKto+1+(1)+1+(1)+1+(1)+1+(CMantissa)+1+CDate+1+
                 CDate+1+CDAte+1+CClient+1,CClientKod);

SkKod:=Copy(s,1+CClient+1
           +(CDocNumer+1)+1+CDate+1+CDate+1+CIZenaK+1+CIZenaK+1+CKto+1+(1)+1+(1)+1+(1)+1+(CMantissa)+1+CDate+1+
                 CDate+1+CDAte+1+CClient+1+CClientKod+1+1,CMAntissa);

If TestAgent(Agent,AgKod) Then
Begin
As.EditPosition:=Copy(s,1+CClient+1,CDocNumer+1);
As.D:=Copy(s,1+CClient+1+(CDocNumer+1)+1,CDate);

        While Pos('│',s)>0 Do
         Begin
          k:=Pos('│',s);
          System.Delete(s,k,1);
          System.Insert(SeparatorChar,s,k);
         End;

{                                                                               опр  ст  TimeC
DateM    TimeM   AgentDocReal DocDate}
{12345678901234567890│12345│12345678│12345678│1234567890│1234567890│123456789012│1│1│1│1│12345678│
12345678│12345678│1234│1234│12345678}
{                                                                                 док}

         SVersia:=Copy(s,1+CClient+1
           +(CDocNumer+1)+1+CDate+1+CDate+1+CIZenaK+1+CIZenaK+1+CKto+1+(1)+1+(1)+1+(1)+1,CMantissa);

         If StrToInt(SVersia)>1 Then SVersia:='!'
         Else SVersia[0]:=#0;

        ws:=Copy(s,1+CClient+1
           +(CDocNumer+1)+1+CDate+1+CDate+1+CIZenaK+1+CIZenaK+1+CKto+1+(1)+1,COne);


        s[0]:=Chr(1+CClient+1+(CDocNumer+1)+1+CDate+1+CDate+1+CIZenaK+1+CIZenaK+1+CKto);


        Summa:=Copy(s,1+CClient+1+(CDocNumer+1)+1+CDate+1+CDate+1,CIZenaK);
       Skidka:=Copy(s,1+CClient+1+(CDocNumer+1)+1+CDate+1+CDate+1+CIZenaK+1,CIZenaK);


        Case StrToInt(Ws) of
        8:Begin ws:='Деб.СФБ';
                          Itogo[8]:=Itogo[8]+StrToReal(Summa);
                          ISkid[8]:=Iskid[8]+StrToReal(Skidka);
          End;
        7:Begin ws:='Деб.';
                          Itogo[7]:=Itogo[7]+StrToReal(Summa);
                          ISkid[7]:=Iskid[7]+StrToReal(Skidka);
          End;
        6:Begin ws:='Деб.СФ*';
                          Itogo[6]:=Itogo[6]+StrToReal(Summa);
                          ISkid[6]:=Iskid[6]+StrToReal(Skidka);
          End;
        5:Begin ws:='Деб.*';
                          Itogo[5]:=Itogo[5]+StrToReal(Summa);
                          ISkid[5]:=Iskid[5]+StrToReal(Skidka);
          End;
        4:Begin ws:='СФБ';
                          Itogo[4]:=Itogo[4]+StrToReal(Summa);
                          ISkid[4]:=Iskid[4]+StrToReal(Skidka);
          End;
        3:Begin ws:='СФ*';
                          Itogo[3]:=Itogo[3]+StrToReal(Summa);
                          ISkid[3]:=Iskid[3]+StrToReal(Skidka);
          End;
        2:Begin ws:='Ф.лицо*';
                          Itogo[2]:=Itogo[2]+StrToReal(Summa);
                          ISkid[2]:=Iskid[2]+StrToReal(Skidka);
          End;
        1:Begin ws:='Т.Чек*';
                          Itogo[1]:=Itogo[1]+StrToReal(Summa);
                          ISkid[1]:=Iskid[1]+StrToReal(Skidka);
          End;
        0:Begin ws:='Список';
                          Itogo[0]:=Itogo[0]+StrToReal(Summa);
                          ISkid[0]:=Iskid[0]+StrToReal(Skidka);
          End;
        Else ws[0]:=#0;
        End;

        Format(ws,7{10});
        {System.Delete(s,1+CClient+1+(CDocNumer+1)+1+CDate+1+CDate+1+CIZenaK+1+CIZenaK+1,1);}
        System.Insert(ws,s,1+CClient+1+(CDocNumer+1)+1+CDate+1+CDate+1+CIZenaK+1+CIZenaK+1);
        Writeln(f,Space+s+SeparatorChar+SkKod+SeparatorChar+SVersia);
End;{AgKod}
  End;
 Writeln(f,Space+'───────────────────────────────────────────────────────────────────────────────────────────-');

 Summa[0]:=#0;
 For c:=0 To 8 Do MyStr(StrToReal(Summa)+Itogo[c],CIZena,CMantissa,Summa);

 Skidka[0]:=#0;
 For c:=0 To 8 Do MyStr(StrToReal(Skidka)+ISkid[c],CIZena,CMantissa,SKidka);

 s:='Всего по РЦ на сумму: '+Recogniz(Summa)+' руб '+^M;
 ws[0]:=#0;
 For c:=0 To 8 Do
  Begin
    If Abs(Itogo[c])>=0.01 Then
     Begin
     Case c Of
      0:ws:=ws+Space+SeparatorChar+'Список:   '+SeparatorChar+RecognizReal(Itogo[c],CIZena,CMantissa)+SeparatorChar+'руб '+^M;
      1:ws:=ws+Space+SeparatorChar+'Тов.Чек*: '+SeparatorChar+RecognizReal(Itogo[c],CIZena,CMantissa)+SeparatorChar+'руб '+^M;
      2:ws:=ws+Space+SeparatorChar+'Физ.лицо*:'+SeparatorChar+RecognizReal(Itogo[c],CIZena,CMantissa)+SeparatorChar+'руб '+^M;
      3:ws:=ws+Space+SeparatorChar+'С/Ф*:     '+SeparatorChar+RecognizReal(Itogo[c],CIZena,CMantissa)+SeparatorChar+'руб '+^M;
      4:ws:=ws+Space+SeparatorChar+'С/Ф Б:    '+SeparatorChar+RecognizReal(Itogo[c],CIZena,CMantissa)+SeparatorChar+'руб '+^M;
      5:ws:=ws+Space+SeparatorChar+'Дебит*:   '+SeparatorChar+RecognizReal(Itogo[c],CIZena,CMantissa)+SeparatorChar+'руб '+^M;
      6:ws:=ws+Space+SeparatorChar+'Дебит СФ*:'+SeparatorChar+RecognizReal(Itogo[c],CIZena,CMantissa)+SeparatorChar+'руб '+^M;
      7:ws:=ws+Space+SeparatorChar+'Дебит    :'+SeparatorChar+RecognizReal(Itogo[c],CIZena,CMantissa)+SeparatorChar+'руб '+^M;
      8:ws:=ws+Space+SeparatorChar+'Дебит СФБ:'+SeparatorChar+RecognizReal(Itogo[c],CIZena,CMantissa)+SeparatorChar+'руб '+^M;
     Else ;
     End;
    End;
  End;
 Writeln(f,Space+s+ws);
 s:='Всего скидка: '+Recogniz(Skidka)+' руб '+^M;
 ws[0]:=#0;
 For c:=0 To 8 Do
  Begin
   If Abs(ISkid[c])>=0.01 Then
    Begin
     Case c Of
     0:ws:=ws+Space+' Список:   '+RecognizReal(ISkid[c],CIZena,CMantissa)+' руб '+^M;
     1:ws:=ws+Space+' Тов.Чек*: '+RecognizReal(ISkid[c],CIZena,CMantissa)+' руб '+^M;
     2:ws:=ws+Space+' Физ.лицо*:'+RecognizReal(ISkid[c],CIZena,CMantissa)+' руб '+^M;
     3:ws:=ws+Space+' С/Ф*:     '+RecognizReal(ISkid[c],CIZena,CMantissa)+' руб '+^M;
     4:ws:=ws+Space+' С/Ф Б:    '+RecognizReal(ISkid[c],CIZena,CMantissa)+' руб '+^M;
     5:ws:=ws+Space+' Дебит*:   '+RecognizReal(ISkid[c],CIZena,CMantissa)+' руб '+^M;
     6:ws:=ws+Space+' Дебит СФ*:'+RecognizReal(ISkid[c],CIZena,CMantissa)+' руб '+^M;
     7:ws:=ws+Space+' Дебит    :'+RecognizReal(ISkid[c],CIZena,CMantissa)+' руб '+^M;
     8:ws:=ws+Space+' Дебит СФБ:'+RecognizReal(ISkid[c],CIZena,CMantissa)+' руб '+^M;
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
 ViewAsText(Path^.Dat.ToTemp+'listz1.txt','Отчет реестр заказов товара и сопр.док-ов (форма1) с '+
 StartDate+' по '+StopDate,True);
 If Izmen=1 Then
 MessageBox(^M+#3'В справку включены только изменявшиеся документы!',Nil,mfWarning+mfCancelButton);;
 {ReportNew(Path^.Dat.ToTemp+'listz.txt','',NprintC^.DAt.CopyAll,False,False);}
 End;
End;


Procedure TReestrZWindow.FormReportRegion(Const P:PBox);
Const Space=' ';
Var f : text;
         SVersia,Skidka,Summa,ws,s : String;
         Itogo,ISkid,NDS20,NDS10,NDS_ : Array[0..8] Of Real;
         c,k : Word;
         Open : String;
      As : DocumentEditZ;
      Tip : Word;
      NDS,LocNDS,LocNDS20,LocNDS10,LocNDS_:Real;
      Agent : PBox;
      AgKod : AllStr;
      c1,Count : Word;
      R : TRect;
      Zak : PZakazType;
      Massa,RegionNumber,ZNumer,
      RegKod,RegNAme,
	 AllMassa,AllSumma,LocMassa,LocSumma : AllStr;
      SkKod : AllStr;
      TempRegion,TempListZ :PBox;
      Cl : PClientType;
      LocCount,AllCount : Word;
  RegionFile : File;
  RegionElement : PBufRegionType;
Begin


If (P^.List<>Nil) And (P^.List^.Count>=1) Then
 Begin
 Assign (f,Path^.Dat.ToTemp+'listzr.txt');
 c:=0;
 Rewrite(f);
 c:=IOResult;
 If c<>0 Then
  Begin
        MessageBox(#3^m+#3+'Не могу создать файл '+Path^.Dat.ToTemp+'listzr.txt',Nil,mfError+mfCancelButton);
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
 1:Writeln(f,Space+'"Номер заказа"');
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

 Writeln(f,Space+'Включены в рассмотрение заказы со статусом:');
 Write(f,Space);
 For c:=1 To Max3 Do
  Begin
   If FiltrStatus[c]=1 Then
    Case c Of
    1:Write(f,' "Не оформлен" ');
    2:Write(f,' "Оформлен" ');
    3:Write(f,' "Анулирован" ');
    Else;
    End;
  End;
 Writeln(f);


 If RegimExt=1 Then Writeln(f,Space+'По 2-ум объектам');


 Write(f,Space+'Вид отгрузки: ');
 WordToBit2(sertifword,sertif2);
 Convert2(sertif2);

 If Sertif2[1]=1 Then Write(f,'"Товар" ');
 If Sertif2[2]=1 Then Write(f,'"Сопроводительные документы"');

 Writeln(f);


 Writeln(f);

 If Izmen=1 Then
 Begin
  Writeln(f,Space+'Внимание! В справку включены только изменявшиеся документы!');
  Writeln(f);
 End;


 Writeln(f);

 Writeln(f,Space+'РЕЕСТР ЗАКАЗОВ ТОВАРА '+' с '+StartDate+' по '+StopDate+'  ПО РЕГИОНАМ'+HeaderStop);

 If DateTrans[0]<>#0 Then
 Writeln(f,Space+'Доставка: '+DateTrans);
(*
 Writeln(f,Space+'Выбраны следующие агенты:');
 For c:=0 To Agent^.List^.Count-1 Do
  Begin
   s:=Agent^.GetText(c,Agent^.List^.Count);

   AgKod:=Copy(s,1+1,CClientKod);

   S:=GetAgentField(FClient,AgKod);
   Format(s,CClient);
   s:=s+' ('+AgKod+')';
   Writeln(f,Space+s);
  End;
*)

R.Assign(0,0,0,0);
TempListZ := New(PBox, Init(R, 1, Nil));
TempListZ^.NewList(New(PTextCollection, Init(0,1)));



{цикл формирования списка заказов по регионам}
 For c:=0 To P^.List^.Count-1 Do
  Begin
     DInfoMsgShkala('Распределяю заказы по регионам ...',0,P^.List^.Count-1,c);
     s := P^.GetText(c,P^.List^.Count);
     AgKod:=Copy(s,1+CClient+1+(CDocNumer+1)+1+CDate+1+CDate+1+CIZenaK+1+CIZenaK+1+CKto+1+(1)+1+(1)+1+(1)+1+
	(CMantissa)+1+CDate+1+
                 CDate+1+CDAte+1+CClient+1,CClientKod);

SkKod:=Copy(s,1+CClient+1
           +(CDocNumer+1)+1+CDate+1+CDate+1+CIZenaK+1+CIZenaK+1+CKto+1+(1)+1+(1)+1+(1)+1+(CMantissa)+1+CDate+1+
                 CDate+1+CDAte+1+CClient+1+CClientKod+1+1,CMAntissa);

If TestAgent(Agent,AgKod) Then
Begin
    ZNumer:=Copy(s,1+CClient+1,CDocNumer+1);
    s[0]:=Chr(1+CClient+1+(CDocNumer+1)+1+CDate+1+CDate+1+CIZenaK);
    New(Zak,Init);

    If StrToInt(SkKod)=StrToInt(Rek^.DAt.Kod) Then
    Begin
    GetZakaz(ZNumer,Zak);
    Massa:=CalcZakazMassa(Zak);
    New(Cl,Init);
    Cl^.DAt.Kod:=Zak^.Dat.ClientKod;
    GetClient(Cl,Zak^.Dat.OperatorSelector);
    End
    Else
     Begin
      GetZakazExt(ZNumer,Zak);
      Massa:=CalcZakazMassaExt(Zak);
      New(Cl,Init);
      Cl^.DAt.Kod:=Zak^.Dat.ClientKod;
      GetClient(Cl,Zak^.Dat.OperatorSelector);
     End;

    MyStr(StrToReal(Massa),CPAck,CLitrMantissa,Massa);
    RFormatZerro(Cl^.Dat.RegionKod,CClientKod);
    Format(Cl^.DAt.AdressF,CAll-5);
    s:='│'+Cl^.Dat.RegionKod+'│'+s+Massa+'│'+Cl^.Dat.AdressF+'│'+SkKod;
    {
    Writeln(s);
    Readln;
    }
    TempListZ^.List^.Insert(NewStr(s));
    TempListZ^.SetRange(TempListZ^.List^.Count);
    Dispose(Cl,Done);
    Dispose(Zak,Done);
End;
  End;{цикл расборки по регионам}
NoInfoMsg;

R.Assign(0,0,0,0);
TempRegion := New(PBox, Init(R, 1, Nil));
TempRegion^.NewList(New(PTextCollection, Init(0,1)));


DInfoMsg('Сортирую регионы ...',True);
{формируем листинг регионов для основного цикла}
Assign (RegionFile,Path^.Dat.ToSPR+'Region.db');
c:=IOResult;
Reset (RegionFile,SizeOf(RegionType));
c:=IOResult;
While Not(Eof(RegionFile)) Do
 Begin
    New(RegionElement,Init);
    ReadBufRegion(RegionFile,RegionElement,Count);
For c1:=1 To Count Do
Begin
  If (RegionElement^.Point.Dat[c1].Employ) Then
  Begin
  If Not TestElement(RegionElement^.Point.Dat[c1].Kod+'│',TempListZ) Then
   Begin
    TempRegion^.List^.Insert(NewStr(RegionElement^.Point.Dat[c1].Kod+'│'+RegionElement^.Point.Dat[c1].RegionName));
    TempRegion^.SetRange(TempRegion^.List^.Count);
   End;
  End;
End;{For}
  Dispose(RegionElement,Done);
 End;
System.Close(RegionFile);
NoInfoMsg;



{основный цикл по листингу регионов}
DInfoMsg('Формирую отчет ...',True);
AllMassa[0]:=#0;
AllSumma[0]:=#0;
AllCount:=0;
If (TempRegion^.List<>Nil) And (TempRegion^.List^.Count>=1) Then
 Begin
  For c1:=0 To TempRegion^.List^.Count-1 Do
   Begin
    s:=TempRegion^.GetText(c1,TempRegion^.List^.Count);
    RegKod:=Copy(s,1,CClientKod);
    RegNAme:=Copy(s,1+CClientKod+1,CCLient);
    LocMassa[0]:=#0;
    LocSumma[0]:=#0;
    LocCount:=0;
    Writeln(f,Space+'Регион: '+RegNAme+' ('+RegKod+')');
    Writeln(f,Space+'┌───────────────────┬─────┬──────────┬─────────┬───────────────────────────────────────┬───┐');
    Writeln(f,Space+'│Клиент             │Заказ│Сумма отг.│ Масса,кг│Фактический адрес достав.              │Скл│');
                    {12345678901234567890│12345│1234567890│123456789│12345678901234567890123456789012345│}
    Writeln(f,Space+'└───────────────────┴─────┴──────────┴─────────┴───────────────────────────────────────┴───┘');
    If (TempListZ^.List<>Nil) And (TempListZ^.List^.Count>=1) Then
     Begin
      For c:=0 To TempListZ^.List^.Count-1 Do
       Begin
        s:=TempListZ^.GetText(c,TempListZ^.List^.Count);
        ws:=Copy(s,1+1,CClientKod);
        {отбираем из общего списка нужный нам регион}
        If StrToInt(ws)=StrToInt(RegKod) Then
         Begin
          System.Delete(s,1,1+CClientKod+1);
          System.Delete(s,1+CClient+1+(CDocNumer+1)+1,CDate+1+CDAte+1);
          While Pos('│',s)>0 Do
           Begin
            k:=Pos('│',s);
            System.Delete(s,k,1);
            System.Insert(SeparatorChar,s,k);
           End;
          MyStr(StrToReal(LocSumma)+StrToReal(
		Copy(s,1+CClient+1+(CDocNumer+1)+1,CIZenaK)),CIZenaK,CMantissa,LocSumma);
          MyStr(StrToReal(LocMassa)+StrToReal(
		Copy(s,1+CClient+1+(CDocNumer+1)+1+CIZenaK+1,CPAck)),CPacK,CLitrMantissa,LocMassa);
          Writeln(f,Space+s);
          Inc(LocCount);
          Inc(AllCount);
         End;
       End;

     MyStr(StrToReal(AllSumma)+StrToReal(LocSumma),CIZena,CMAntissa,AllSumma);
     MyStr(StrToReal(AllMassa)+StrToReal(LocMassa),CIZena,CLitrMAntissa,AllMAssa);

     End;{TempListZ}
    Writeln(f,Space+'────────────────────────────────────────────────────────────────────────────────────────────');
    Writeln(f,Space+'Всего по региону точек :'+SeparatorChar,LocCount:3,SeparatorChar,RecognizReal(StrToReal(LocSumma),CIZena,
    CMantissa)+
    ' руб '+SeparatorChar+ RecognizReal(StrToReal(LocMassa),CPack,CLitrMantissa)+SeparatorChar+'кг ');
    Writeln(f,Space+'────────────────────────────────────────────────────────────────────────────────────────────');
    Writeln(f);

   End;{For c1}
 End;{если список регионов не пустой}

 Writeln(f,Space,'Всего отгружено РЦ:'+
 SeparatorChar+RecognizReal(StrToReal(AllSumma),CIZena,CMantissa)+SeparatorChar+'руб');
 Writeln(f,Space,'       Всего масса:'+
 SeparatorChar+RecognizReal(StrToReal(AllMassa),CPack,CLitrMantissa)+SeparatorChar+'кг ');

 Writeln(f);
 Writeln(f,Space,'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
 Writeln(f,Space+'============================================================================================');

 System.Close(f);
 Dispose(Agent,Done);
 Dispose(TempListZ,Done);
 Dispose(TempRegion,Done);

 NoInfoMsg;
 ViewAsText(Path^.Dat.ToTemp+'listzr.txt','Отчет реестр заказов товара и сопр.док-ов (форма2) с '+StartDate+' по '+
 StopDate,True);
 If Izmen=1 Then
 MessageBox(^M+#3'В справку включены только изменявшиеся документы!',Nil,mfWarning+mfCancelButton);;
 {ReportNew(Path^.Dat.ToTemp+'listzr.txt','',NprintC^.DAt.CopyAll,False,False);}
 End;
End;





procedure TReestrZWindow.HandleEvent(var Event: TEvent);
Var test : Word;
    s,s1,s2 : String;
    SDoc : ArtikulStr;
    SDate: TDateString;
    l : Boolean;
    FC:Byte;
    FS : AllStr;
    V: Word;
    SkKod : ArtikulStr;
    Stat: word;
begin
  if (Abs(TimeStringToTime('hh:mm:ss',Times)-StartTime)>RefreshTime) And (Auto=1) then
   Begin
     Event.What:=evCommand;
     Event.Command:=cmRefresh;
   End;


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

     kbCtrlRusN
	        : Begin
                ClearFind;
                Event.What:=evCommand;
                Event.Command:=cmRefresh;
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
{$IFDEF RemoteClient}

     kbF8: Begin
              ClearFind;
              Event.What:=evCommand;
              Event.Command:=cmPodpis;
              PutEvent(Event);
              ClearEvent(Event);
           end;



     kbCtrlF7: Begin
                ClearFind;
                Event.What:=evCommand;
                Event.Command:=cmDelPodpis;
                PutEvent(Event);
                ClearEvent(Event);
               End;
{$ENDIF}

    kbCtrlF8:  Begin
                ClearFind;
                Event.What:=evCommand;
                Event.Command:=cmProperty;
                PutEvent(Event);
                ClearEvent(Event);
               End;

    kbCtrlF9:  Begin
                ClearFind;
                Event.What:=evCommand;
                Event.Command:=cmEditStatus;
                PutEvent(Event);
                ClearEvent(Event);
               End;




      Else;
      End;{KeyDown}
  evCommand :
     Case Event.Command Of

  cmPodpis
            : Begin
     If (DocList^.State and sfFocused <> 0) And (DocList^.List<>Nil)And(DocList^.List^.Count>=1) Then
            Begin
              Assistent.EditPosition:=Copy(DocList^.GetText(DocList^.Focused,DocList^.List^.Count),1+CName-5,CArtikul);
              DelSpace(Assistent.EditPosition);
              Assistent.D:=Copy(DocList^.GetText(DocList^.Focused,DocList^.List^.Count),1+CName-5+1+CArtikul,CDate);

              SendCLMail(Assistent);

              Event.What:=evCommand;
              Event.What:=evCommand;
              Event.Command:=cmRefresh;
              PutEvent(Event);
              PrevCur[0]:=#0;
            End;
              ClearEvent(Event);
             End;

     cmDelPodpis: Begin
     If (DocList^.State and sfFocused <> 0) And (DocList^.List<>Nil)And(DocList^.List^.Count>=1) Then
            Begin
                 Event.What:=evCommand;
                 s:=DocList^.GetText(DocList^.Focused,DocList^.List^.Count);
                 If StrToInt(copy(S,length(s)-{1}3,1))=1 Then
                 begin
                  Assistent.EditPosition:=Copy(DocList^.GetText(DocList^.Focused,DocList^.List^.Count),1+CName-5,CArtikul);
                  DelSpace(Assistent.EditPosition);
                  Assistent.D:=Copy(DocList^.GetText(DocList^.Focused,DocList^.List^.Count),1+CName-5+1+CArtikul,CDate);
                  if MessageBox(^M+#3+'Отменить подпись заказа N'+ASsistent.EditPosition+
                  ' от '+Assistent.D+' ?',Nil,mfWarning+mfOkCancel) = cmOk then
                  SetPodpis(Assistent,0);
                  PrevCur[0]:=#0;
                 end
                 else
                 Begin
                 Case StrToInt(copy(S,length(s)-{1}3,1)) Of
                 2:MessageBox(#3^M+#3'Заказ уже отправлен и корректироваться не может!',Nil,mfWarning+mfCancelButton);
                 5:MessageBox(#3^M+#3'Заказ уже подтвержден и корректироваться не может!',Nil,mfWarning+mfCancelButton);
                 6:MessageBox(#3^M+#3'Заказ уже анулирован и корректироваться не может!',Nil,mfWarning+mfCancelButton);
                 Else;
                 End;
                 End;
                 Event.What:=evCommand;
                 Event.Command:=cmRefresh;
                 PutEvent(Event);
            End;
                 ClearEvent(Event);

               End;

     cmEditStatus: Begin
     If Password(20) Then
     If (DocList^.State and sfFocused <> 0) And (DocList^.List<>Nil)And(DocList^.List^.Count>=1) Then
            Begin
                 Event.What:=evCommand;
                 s:=DocList^.GetText(DocList^.Focused,DocList^.List^.Count);
                 begin
                  Assistent.EditPosition:=Copy(DocList^.GetText(DocList^.Focused,DocList^.List^.Count),1+CName-5,CArtikul);
                  DelSpace(Assistent.EditPosition);
                  Assistent.D:=Copy(DocList^.GetText(DocList^.Focused,DocList^.List^.Count),1+CName-5+1+CArtikul,CDate);
                  if MessageBox(^M+#3+'Изменить статус заказа N'+ASsistent.EditPosition+
                  ' от '+Assistent.D+' ? ',Nil,
                  mfWarning+mfOkCancel) = cmOk then
                  begin
                  Stat:=0;
                  if SelectStatus(Stat) then SetPodpis(Assistent,Stat);
                  end;
                 end;

                 Event.What:=evCommand;
                 Event.Command:=cmRefresh;
                 PutEvent(Event);
            End;
                 ClearEvent(Event);

               End;


     cmProperty: Begin

     If Password(20) Then
     If (DocList^.State and sfFocused <> 0) And (DocList^.List<>Nil)And(DocList^.List^.Count>=1) Then
            Begin
                 Event.What:=evCommand;
                 s:=DocList^.GetText(DocList^.Focused,DocList^.List^.Count);
                 begin
                  Assistent.EditPosition:=Copy(DocList^.GetText(DocList^.Focused,DocList^.List^.Count),1+CName-5,CArtikul);
                  DelSpace(Assistent.EditPosition);
                  Assistent.D:=Copy(DocList^.GetText(DocList^.Focused,DocList^.List^.Count),1+CName-5+1+CArtikul,CDate);
                  Stat:=0;
                  if SelectStatusOformlenie(Stat) then
			   SetZakazStatus(Stat,Assistent.EditPosition,'','');
                 end;
                 Event.What:=evCommand;
                 Event.Command:=cmRefresh;
                 PutEvent(Event);
                 PrevCur[0]:=#0;
            End;
                 ClearEvent(Event);

               End;


  cmGetName: Begin
              PString(Event.InfoPtr)^ := 'Реестр заказов за период с '+StartDate+' по '+StopDate;
              ClearEvent(Event);
              Exit;
             End;
  cmDocFiltr:Begin
              If Setup Then
              Begin
              Refresh;
              ClearEvent(Event);
              StartTime:=TimeStringToTime('hh:mm:ss',Times);
              PrevCur[0]:=#0;
              SortScreenList(True);
              Redraw;
              End;
                ClearEvent(Event);
             End;

  cmChangeDiapason:Begin
              s1:=StartDate;
              s2:=StopDate;
              If DatePeriodDialog(s1,s2,False) Then
              Begin
              StartDate:=s1;
              StopDate:=s2;

If ((DateStringToDate(DAteMask,StopDate)-
   DateStringToDate(DAteMask,StartDate))>6) Then  Auto:=0
   Else Auto:=1;
              ControlAuto^.SetDAta(Auto);
              Refresh;
              ClearEvent(Event);
              StartTime:=TimeStringToTime('hh:mm:ss',Times);
              PrevCur[0]:=#0;
              SortScreenList(True);
              Redraw;
              End;
                            End;
  cmRefresh: Begin
  If (DeskTop^.Current=PView(DocReestrWindow)) And (Event.What <> EvKeyDown)
      And Not(Glob.Show) And Not(Glob.ShowMsg) And Not(Glob.GlobalShow) Then
           Begin
              FS:=FindStrok;
                    FC:=Ord(FindStrok[0]);
              Refresh;
              ClearEvent(Event);
              StartTime:=TimeStringToTime('hh:mm:ss',Times);
              PrevCur[0]:=#0;
              SortScreenList(False);
              FindStrok:=FS;
              FindSymbol:=FC;
              Redraw;
           End
           Else
            ClearEvent(Event);
          End;
  cmUnlockMarket :
   Begin
    ClearFind;
     If (DocList^.State and sfFocused <> 0) And (DocList^.List<>Nil)And(DocList^.List^.Count>=1) Then
     NetUnLock;
   End;
  cmEdit:    Begin

If (GlobalReadOnly=1) Or (ReadOnlyConst=1) Then
   Begin
    MessageBox(#3^M+ReadOnlyStr^,Nil,mfWarning+mfCancelButton);
    ClearEvent(Event);
    Exit;
   End;
ClearFind;

     If (DocList^.State and sfFocused <> 0) And (DocList^.List<>Nil)And(DocList^.List^.Count>=1) Then
            Begin

   s:=Copy(DocList^.GetText(DocList^.Focused,DocList^.List^.Count),1+CClient+1
           +(CDocNumer+1)+1+CDate+1+CDate+1+CIZenaK+1+CIZenaK+1+CKto+1+(1)+1+(1)+1,COne);

   SkKod:=Copy(DocList^.GetText(DocList^.Focused,DocList^.List^.Count),1+CClient+1+(CDocNumer+1)+
               1+CDate+1+CDate+1+CIZenaK+1+CIZenaK+1+CKto+1+(1)+1+(1)+1+(1)+1+
           	(CMantissa)+1+CDate+1+
               CDate+1+CDAte+1+CClient+1+CClientKod+1+1,CMantissa);


   If StrToInt(SkKod)<>StrToInt(Rek^.DAt.Kod) Then
    Begin
     MessageBox(#3^M+#3'Документ другого склада корректировать не может!',Nil,mfWarning+mfCancelButton);
     ClearEvent(Event);
     Exit;
    End;

   If StrToInt(s)=1 Then
   Begin
    MessageBox(#3^M+#3'Заказ уже оформлен и корректироваться не может!',Nil,mfWarning+mfCancelButton);
    ClearEvent(Event);
    Exit;
   End;

   If StrToInt(s)=2 Then
   Begin
    MessageBox(#3^M+#3'Заказ анулирован по истечении срока доставки и корректироваться не может!',Nil,
    mfWarning+mfCancelButton);
    ClearEvent(Event);
    Exit;
   End;

{$IFDEF RemoteClient}
   s:=DocList^.GetText(DocList^.Focused,DocList^.List^.Count);
   If StrToInt(copy(S,length(s)-3{1},1))<>0 Then
    Begin
     MessageBox(#3^M+#3'Заказ подписан и корректироваться не может!',Nil,mfWarning+mfCancelButton);
     ClearEvent(Event);
     Exit;
    End;
{$ENDIF}


                AssistentZ.EditPosition:=Copy(DocList^.GetText(DocList^.Focused,DocList^.List^.Count),1+CClient+1,
                         (CDocNumer+1));
                DelSpace(AssistentZ.EditPosition);
                DelZerro(AssistentZ.EditPosition);
                AssistentZ.D:=Copy(DocList^.GetText(DocList^.Focused,DocList^.List^.Count),1+CClient+1+(CDocNumer+1)+1,CDate);
                DelSpace(AssistentZ.D);

                Dispose(NoScreenList,Done);
                Event.What:=evCommand;
                Event.Command:=cmSuperZakaz;
                PutEvent(Event);
                ClearEvent(Event);
                Status:=DocEdit;

            End
            End;

  cmPrintReestr:    Begin
                 ClearFind;
     If (DocList^.State and sfFocused <> 0) And (DocList^.List<>Nil)And(DocList^.List^.Count>=1) Then
            Begin
   SkKod:=Copy(DocList^.GetText(DocList^.Focused,DocList^.List^.Count),1+CClient+1+(CDocNumer+1)+
               1+CDate+1+CDate+1+CIZenaK+1+CIZenaK+1+CKto+1+(1)+1+(1)+1+(1)+1+
           	(CMantissa)+1+CDate+1+
               CDate+1+CDAte+1+CClient+1+CClientKod+1+1,CMantissa);


   If StrToInt(SkKod)<>StrToInt(Rek^.DAt.Kod) Then
    Begin
     MessageBox(#3^M+#3'Документ другого склада печатать нельзя!',Nil,mfWarning+mfCancelButton);
     ClearEvent(Event);
     Exit;
    End;

                Assistent.EditPosition:=Copy(DocList^.GetText(DocList^.Focused,DocList^.List^.Count),1+CClient+1,
                         (CDocNumer+1));
                DelSpace(Assistent.EditPosition);
                DelZerro(Assistent.EditPosition);
                Assistent.D:=Copy(DocList^.GetText(DocList^.Focused,DocList^.List^.Count),1+CClient+1+(CDocNumer+1)+1,CDate);
                DelSpace(Assistent.D);

                PrintZakaz(Assistent,NprintC^.DAt.CopyZakaz);
                {Status:=DocNormal;}
            End
            End;
 cmReestrReport:    Begin
                 ClearFind;
     If (DocList^.List<>Nil)And(DocList^.List^.Count>=1) Then
            Begin
            If MessageBox(^M+#3'Провести разбивку по регионам?',Nil,mfConfirmation+mfOkCancel)=cmOk Then
            FormReportRegion(DocList)
            Else
            FormReport(DocList);
            End
            End;
  cmFullView:    Begin
                 ClearFind;
     If (DocList^.State and sfFocused <> 0) And (DocList^.List<>Nil)And(DocList^.List^.Count>=1) Then
            Begin
   SkKod:=Copy(DocList^.GetText(DocList^.Focused,DocList^.List^.Count),1+CClient+1+(CDocNumer+1)+
               1+CDate+1+CDate+1+CIZenaK+1+CIZenaK+1+CKto+1+(1)+1+(1)+1+(1)+1+
           	(CMantissa)+1+CDate+1+
               CDate+1+CDAte+1+CClient+1+CClientKod+1+1,CMantissa);


   If StrToInt(SkKod)<>StrToInt(Rek^.DAt.Kod) Then
    Begin
     MessageBox(#3^M+#3'Это документ другого склада!',Nil,mfWarning+mfCancelButton);
     ClearEvent(Event);
     Exit;
    End;

              FullPreview;
            End
            End;
     cmReestrZakaz:Begin
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
                End;

      Else;
      End;{evCommand}
      Else;
      End;{*Case*}

  if (Event.What = evBroadcast) and
    (Event.Command = cmReestrZakaz) then ClearEvent(Event);

  if (Event.What = evBroadcast) and
    (Event.Command = cmQuit) then ClearEvent(Event);


  inherited HandleEvent(Event);


  If (Desktop^.Current=PView(DocReestrWindow)) And (Event.What <> EvKeyDown) Then
             Begin

            if (DocList^.List<>Nil)And(DocList^.List^.Count>=1) Then
              Begin
               s:=DocList^.GetText(DocList^.Focused,DocList^.List^.Count);
               If s <> PrevCur Then
                 Begin
                  PrevCur:=S;
                  DrawCurrent;
                 End;
              End
              Else
                  DrawCurrent;

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


                if (ControlAuto^.State and sfFocused <> 0)Then
                    Begin
                        ControlAuto^.GetData(Test);
                        If Test <> Auto Then
                        Begin
                           ClearFind;
                           Auto:=Test;
                           Redraw;
                        End;
                    End;

                if (ControlRefreshTime^.State and sfFocused <> 0)Then
                    Begin
                        ControlRefreshTime^.GetData(s);
                        If StrToInt(s) <> RefreshTime Then
                        Begin
                           ClearFind;
                           RefreshTime:=StrToInt(s);
                        End;
                    End;
         End;
end;


BEgin
Direction:=0; {направление сортировки}
Sorting:=0;   {ключ сортировки}
RefreshTime:=20; {стартовое время обновления}
Izmen:=0;

M3[1]:=1;
M3[2]:=1;
M3[3]:=1;

sertif2[1]:=1;
sertif2[2]:=1;

ActivMas[1]:=1;
ActivMas[2]:=1;

{$IFNDEF RemoteClient}
FiltrStatus[1]:=1;
FiltrStatus[2]:=0;
FiltrStatus[3]:=0;
{$ELSE}
FiltrStatus[1]:=1;
FiltrStatus[2]:=1;
FiltrStatus[3]:=0;
FiltrStatus[4]:=0;
FiltrStatus[5]:=0;
{$ENDIF}

FiltrDoc[1]:=1;
FiltrDoc[2]:=1;
FiltrDoc[3]:=1;
FiltrDoc[4]:=1;
FiltrDoc[5]:=1;
FiltrDoc[6]:=1;
FiltrDoc[7]:=1;
FiltrDoc[8]:=1;
FiltrDoc[9]:=1;
{$IFDEF Pharm}
StartDAte:=DateToDateString(DateMask,DAteStringToDate(DateMask,FDAte)-31);
{$ELSE}
StartDAte:=DateToDateString(DateMask,DAteStringToDate(DateMask,FDAte)-4);
{$ENDIF}
StopDate:=FDAte;
RegimExt:=0;
DateTrans[0]:=#0;
End.