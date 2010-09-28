
{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}

{$I Compile.INC}

Unit Reestrve;

Interface


Uses Dialogs,Drivers,Glob,ViewMrk;

Type
  PReestrVeWindow = ^TReestrVeWindow;
  TReestrVeWindow = object(TDialog)
    ViewMrk: PFullScreenMrk;
    constructor Init(Var l: Boolean);
    procedure OpenReestrWindow;
    procedure FullPreview;
    procedure PrintVe;
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure SortScreenList(Logik:Boolean);
    Function  DeleteVeksel:Boolean;
    Procedure FormReport(Const p:PBox);
    procedure Refresh;
  end;

Implementation


uses ServStr,NetCAll,Dos,DBEngine,Objects, Views, MsgBox,
     Vision4,TpDate,Utils,DBEngin2,App, ColorTxt,Serv,Tools,ServStr2,
	Printers,PrnVeks,Vision5,Vision7,ComboBox,Protect,Utils1,
	Utils3,Utils10,Utils5;

var
 NoScreenList,DocList : PBox;
 PrevCur : TMyString;
 ControlDirection,ControlSort,ControlAllDoc,ControlAllSumma,
 ControlStart,ControlStop,Control : PView;
 DocReestrWindow:PReestrVeWindow;
 StartDate,StopDate : TDateString;
 AllDoc,AllSumma : String[CIZena];
 Direction,Sorting : Word;


procedure TReestrVeWindow.OpenReestrWindow;
Var l : Boolean;
begin
  if Message(Desktop, evBroadcast, cmReestrVe, nil) = nil then
  begin
    L:=True;
    DInfo('Инициализация реестра векселей...');
    DocReestrWindow := New(PReestrVeWindow, Init(L));
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



Procedure TReestrVeWindow.SortScreenList(Logik:Boolean);
Var i,j : Word;
    ws,ws1,ws2 : String;
    Doc : ArtikulStr;
         TempBox : PBox;
    R : TRect;
Begin
DInfoMsg('Сортирую документы...',False);

{
if (DocList^.List^.Count>0) And Not(Logik) Then
  Doc:=Copy(DocList^.GEtText(DocList^.Focused,DocList^.List^.Count),
      1+CClient+1,CArtikul)
Else Doc[0]:=#0;
}


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
Case Sorting Of
{клиент}
0:ws:=ws;
{номер векселя}
1:Begin
   ws1:=Copy(ws,1+CClient+1,CArtikul);
   System.Delete(ws,1+CClient+1,CArtikul+1);
   ws:=ws1+' '+ws;
  End;
{сумма отгрузки}
2:Begin
   ws1:=Copy(ws,1+CClient+1+CArtikul+1+CDate+1,CIZena);
   RFormatZerro(ws1,CIZena);
   {System.Delete(ws,1+CClient+1+CDocNumer+1+CDate+1,CIZena+1);}
   ws:=ws1+' '+ws;
  End;
{номер и дата документа}
3:Begin
   ws1:=Copy(ws,1+CClient+1+CArtikul+1+CDate+1+CIZena+1,CDocNumer);

   ws2:=Copy(ws,1+CClient+1+CArtikul+1+CDate+1+CIZena+1+CDocNumer+1,CDate);
   ws2:=IntToStr(DateStringToDate(DateMask,ws2),CDAte);
   RFormat(ws2,CDAte);
   {System.Delete(ws,1+CClient+1+CDocNumer+1+CDate+1,CIZena+1);}
   ws:=ws1+' '+ws2+' '+ws;
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
{клиент}
0:ws:=ws;
{N документа}
1:Begin
   ws1:=Copy(ws,1,CArtikul);
   System.Delete(ws,1,CArtikul+1);
   System.Insert(ws1+'│',ws,1+CClient+1);
  End;
{сумма отгрузки}
2:Begin
   ws1:=Copy(ws,1,CIZena);
   System.Delete(ws,1,CIZena+1);
  End;
{номер и дата документа}
3:Begin
   ws1:=Copy(ws,1,CDocNumer+1+CDAte);
   System.Delete(ws,1,CDocNumer+1+CDate+1);
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
DocList^.FocusItem(0);
DocList^.HelpCtx:=$F207;
DistanationSorting:=0;
PrevCur[0]:=#0;
End;



Procedure TReestrVeWindow.Refresh;
Var   Fp : File;
         s: TMyString;
         ws : AllStr;
         P : PBufDocBazType;
         FPos:Byte;
         sn,SVersia,TempArtikul,FS : AllStr;
         Sh : Word;
      R : TRect;
      clKod : ArtikulStr;
      Assss : DocumentEdit;
      Num : ArtikulStr;
      Sum : AllStr;
      Kto : String[CKto];
      Pos,Cur,Start,Stop : LongInt;
      c,Count : Word;

Begin
DInfo('Минуточку...');
c:=IOResult;
Assign(fp,Path^.Dat.ToSklad+'veksel.db');
Reset(fp,SizeOf(DocBazType));
c:=IOResult;
If c<>0 Then
 Begin
   NoInfo;
   MessageBox(#3^M+#3'Не найден файл '+Path^.Dat.ToSklad+'veksel.db',Nil,mfError+mfCancelButton);
   Exit;
 End;

NoScreenList^.NewList(Nil);
NoScreenList^.NewList(New(PTextCollection, Init(1,1)));
AllDoc[0]:=#0;
AllSumma[0]:=#0;

   Start:=DateStringToDate(DateMask,StartDate);
   Stop :=DateStringToDate(DateMask,StopDate);

While Not(Eof(Fp)) Do
 Begin

 Count:=0;
 New(P,Init);

 Pos:=FilePos(fp);

 Repeat
  Pause(1);
 Until NetCAll.Lock(fp,Pos*SizeOf(DocBazType),SizeOf(BufDocBazType));

  BlockRead(Fp,P^.Point,BufferVKS,Count);

 Repeat
  NetCall.Unlock(fp,Pos*SizeOf(DocBazType),SizeOf(BufDocBazType));
 Until (DosError=0);

For c:=1 To Count Do
Begin

 If (P^.Point.Dat[c].Status) And Not(P^.Point.Dat[c].Locked) Then
  Begin

   Cur:=DateStringToDate(DateMask,P^.Point.Dat[c].DateC);

   If (Cur>=Start) And (Cur<=Stop) Then

   Begin
   Assss.EditPosition:=P^.Point.Dat[c].Document;
   Assss.D:=P^.Point.Dat[c].DateDocument;
    Begin
     Str(StrToInt(AllDoc)+1:CArtikul,AllDoc);
     MyStr(StrToReal(AllSumma)+StrToReal(P^.Point.Dat[c].Summa),CIZena,CMantissa,AllSumma);
     clKod:=P^.Point.Dat[c].ClientKod;
     sn:=GetClientField(FClient,ClKod,0);
     Format(sn,CClient);
     Num:=P^.Point.Dat[c].Dogovornumer;
     RFormatZerro(Num,CArtikul);
     RFormatZerro(P^.Point.Dat[c].Document,CDocnumer);
     DelSpace(P^.Point.Dat[c].DateDocument);
     Format(P^.Point.Dat[c].DateDocument,CDate);
     Format(P^.Point.Dat[c].Data,CDate);
     MyStr(StrToReal(P^.Point.Dat[c].Summa),CIZena,CMAntissa,Sum);
     Kto := GetOperatorField(FNAme,P^.Point.Dat[c].Caption);
     s:=sn+'│'+Num+'│'+P^.Point.Dat[c].Data+'│'+sum+'│'+P^.Point.Dat[c].Document+'│'+P^.Point.Dat[c].DateDocument+'│'+Kto;
     NoScreenList^.List^.Insert(NewStr(s));
     NoScreenList^.SetRange(NoScreenList^.List^.Count);
    End;{GetIdMarket1}
  End;{P^.Point.Dat[c].Status}
 End;{Date}
End;{For}
Dispose(P,Done);

End;{While}


c:=IOREsult;
System.Close(Fp);
c:=IOREsult;


Str(StrToInt(AllDoc):CArtikul,AllDoc);
DelSpace(AllDoc);
MyStr(StrToReal(AllSumma),CIZena,CMantissa,AllSumma);
DelSpace(AllSumma);



Dispose(ControlAllDoc,Done);
R.Assign(24, 22, 29, 23);
ControlAllDoc := New(PColoredText, Init(R, #3+AllDoc, $4E));
Insert(ControlAllDoc);

Dispose(ControlAllSumma,Done);
R.Assign(57, 22, 72, 23);
ControlAllSumma := New(PColoredText, Init(R, #3+AllSumma, $4E));
Insert(ControlAllSumma);

NoInfo;
End;


constructor TReestrVeWindow.Init(Var l : Boolean);
var
  R : TRect;
  Control : PView;
  C : Word;
  s: TMyString;
  ws : AllStr;
  E : PSuperMarketType;
  fp : MarketFileType;
begin

StartDate:=FDate;
StopDate:=FDate;


R.Assign(0, 0, 80, 23);
inherited Init(R, 'Реестр векселей');
Options := Options or ofCenterX or ofCenterY;
HelpCtx:=$E002;

AllSumma[0]:=#0;
AllDoc[0]:=#0;

R.Assign(0, 0, 0, 0);
NoScreenList := New(PBox, Init(R, 1, Nil));
NoScreenList^.NewList(New(PTextCollection, Init(1,1)));
NoScreenList^.FocusItem(0);


MyStr(StrToReal(AllSumma),CIZena,CMantissa,AllSumma);
DelSpace(AllSumma);

Str(StrToInt(AllDoc):CArtikul,AllDoc);
DelSpace(AllDoc);


Sorting:=0;
R.Assign(1, 1, 62, 2);
ControlSort := New(PRadioButtons, Init(R,
  NewSItem('К~л~иент',
  NewSItem('Н~о~мер векселя',
  NewSItem('С~у~мма векселя',
  NewSItem('~Д~ок-т',
  Nil))))));
ControlSort^.SetData(Sorting);
Insert(ControlSort);


  R.Assign(1, 0, 13, 1);
  Insert(New(PLabel, Init(R, 'Сор~т~ировка:', ControlSort)));



Direction:=0;

R.Assign(65, 1, 79, 2);
ControlDirection := New(PRadioButtons, Init(R,
  NewSItem(#30,
  NewSItem(#31, Nil))));
ControlDirection^.SetData(Direction);
Insert(ControlDirection);


R.Assign(79, 3, 80, 21);
Control := New(PScrollBar, Init(R));
Insert(Control);

R.Assign(1, 3, 79, 21);
DocList := New(PBox, Init(R, 1, PScrollbar(Control)));
DocList^.NewList(New(PMyCollection, Init(0,1)));
DocList^.FocusItem(0);
DocList^.HelpCtx:=$F207;
Insert(DocList);

  R.Assign(1, 2, 78, 3);
  Insert(New(PLabel, Init(R, 'Клиент               Номер   Дата     Сумма векселя Док. Дата док.  Оператор', DocList)));


R.Assign(8, 22, 24, 23);
Control := New(PColoredText, Init(R, ' Всего векселей:', $74));
Insert(Control);


R.Assign(24, 22, 29, 23);
ControlAllDoc := New(PColoredText, Init(R, #3+'0', $4E));
Insert(ControlAllDoc);


R.Assign(35, 22, 57, 23);
Control := New(PColoredText, Init(R, ' Всего сумма векселей:', $74));
Insert(Control);


R.Assign(57, 22, 72, 23);
ControlAllSumma := New(PColoredText, Init(R, #3+'0.00', $4E));
Insert(ControlAllSumma);


R.Assign(47, 21, 59, 22);
Control := New(PColoredText, Init(R, 'За период с:', $74));
Insert(Control);


R.Assign(59, 21, 67, 22);
ControlStart := New(PColoredText, Init(R, StartDate, $7E));
Insert(ControlStart);


R.Assign(68, 21, 71, 22);
Control := New(PColoredText, Init(R, 'по:', $74));
Insert(Control);


R.Assign(71, 21, 79, 22);
ControlStop := New(PColoredText, Init(R, StopDate, $7E));
Insert(ControlStop);


R.Assign(51, 0, 58, 1);
Control := New(PColoredText, Init(R, ' Склад:', $74));
Insert(Control);

s:=GetClientField(FClient,Rek^.Dat.Kod,1);
DelSpaceLeftRight(s);
R.Assign(58, 0, 58+Ord(s[0])+1, 1);
Control := New(PColoredText, Init(R, s, $7E));
Insert(Control);


L:=True;
Refresh;
PrevCur[0]:=#0;
SortScreenList(True);
end;



procedure TReestrVeWindow.FullPreview;
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
  Ass.EditPosition:=Copy(DocList^.GetText(DocList^.Focused,DocList^.List^.Count),1+CClient+1+CArtikul+1+CDate+1+CIZena+1,
  CDocNumer);
  DelSpace(Ass.EditPosition);
  DelZerro(Ass.EditPosition);
  Ass.D:=Copy(DocList^.GetText(DocList^.Focused,DocList^.List^.Count),1+CClient+1+CArtikul+1+CDate+1+CIZena+1+CDocNumer+1,
  CDate);
  DelSpace(Ass.D);
  ViewMrk^.FullScreenMrk(Ass,False);
End;
End;

procedure TReestrVeWindow.PrintVe;
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
    Numer : ArtikulStr;
Begin
If (DocList^.List<>Nil)And(DocList^.List^.Count>=1) Then
Begin
  Ass.EditPosition:=Copy(DocList^.GetText(DocList^.Focused,DocList^.List^.Count),1+CClient+1+CArtikul+1+CDate+1+CIZena+1,
  CDocNumer);
  Numer:=Copy(DocList^.GetText(DocList^.Focused,DocList^.List^.Count),1+CClient+1,CArtikul);
  Numer:=IntToStr(StrToInt(Numer),CArtikul);
  DelSpace(Ass.EditPosition);
  DelZerro(Ass.EditPosition);
  Ass.D:=Copy(DocList^.GetText(DocList^.Focused,DocList^.List^.Count),1+CClient+1+CArtikul+1+CDate+1+CIZena+1+CDocNumer+1,
  CDate);
  DelSpace(Ass.D);
  DInfoMsg('Ищу документ...',True);
  New(E,Init);
  If GetPsevdoMarket(Ass,Numer,E) Then
   Begin
   NoInfoMsg;

   PrnComplect(E^.Dat.Veksel,E^.Dat.ClientKod,Ass.EditPosition,Ass.D);
(*
   If MessageBox(#3^M+#3'Провести заполнение векселей?',Nil,mfConfirmation+mfOkCancel)=CmOk Then
    PrintVeksel(E^.Dat.Veksel,E^.Dat.ClientKod);
    PrintAkt1(E^.Dat.Veksel,E^.Dat.ClientKod); {интраст-клиент}

    PrintAkt2(E^.Dat.Veksel,E^.Dat.ClientKod); {клиент-триада}
    PrintAkt3(E^.Dat.Veksel,E^.Dat.ClientKod); {интраст-триада}
    DogVeks1(E^.Dat.Veksel,E^.Dat.ClientKod);  {интраст-клиент}
    DogVeks2(E^.Dat.Veksel,E^.Dat.ClientKod);  {клиент-триада}
    SogVeks(E^.Dat.Veksel,E^.Dat.ClientKod,Ass.EditPosition,Ass.D);
*)
    If E^.Dat.DocSelector in [3,4,8] Then
    PrintOrderVeksel(E^.Dat.Veksel,E^.Dat.ClientKod,Ass.EditPosition,Ass.D);

   End
   Else NoInfoMsg;
  Dispose(E,Done);
End;
End;


Procedure TReestrVeWindow.FormReport(Const P:PBox);
Const Space=' ';
Var f : text;
         SVersia,Skidka,Summa,ws,s : String;
         Itogo,ISkid : Array[0..8] Of Real;
         c,k : Word;
         Open : String;
         Numer,SNumer : ArtikulStr;
Begin
If (P^.List<>Nil) And (P^.List^.Count>=1) Then
 Begin
 Assign (f,Path^.Dat.ToTemp+'listv.txt');
 c:=0;
 Rewrite(f);
 c:=IOResult;
 If c<>0 Then
  Begin
        MessageBox(#3^m+#3+'Не могу создать файл '+Path^.Dat.ToTemp+'listv.txt'+
        ' Код: '+IntToStr(c,3),Nil,mfError+mfCancelButton);
   Exit;
  End;
 Writeln(f,Header+Space+ 'Склад: ',GetClientField(FClient,Rek^.Dat.Kod,1)+'  Оператор: '+CurrentPassword+' EYE & 1997-00');

 Write(f,Space+'Вид сортировки:');
 Case Sorting Of
 0:Writeln(f,Space+'"Клиент"');
 1:Writeln(f,Space+'"Номер векселя"');
 2:Writeln(f,Space+'"Сумма векселя"');
 3:Writeln(f,Space+'"Номер документа"');
 Else Writeln(f);
 End;

 {Writeln(f,Space+'│Клиент              Номер   Дата     Сумма векселя Док.   Дата     Оператор │');}

 Writeln(f);
 Writeln(f,Space+'         РЕЕСТР ВЕКСЕЛЕЙ ЗА ПЕРИОД С '+StartDate+' ПО '+StopDate);
 Writeln(f,Space+'┌───┬────────────────────┬─────┬────────┬───────────────┬────┬────────┬───────────┐');
 Writeln(f,Space+'│Код│Клиент              │Номер│  Дата  │  Сумма векселя│Док.│  Дата  │  Оператор │');
 Writeln(f,Space+'└───┴────────────────────┴─────┴────────┴───────────────┴────┴────────┴───────────┘'+HeaderStop);

                      {12345678901234567890│12345│12345678│123456789012345│1234│12345678│123456789012}

 For c:=0 To P^.List^.Count-1 Do
  Begin
        s := P^.GetText(c,P^.List^.Count);
        SNumer[0]:=#0;
        Numer:=Copy(s,1+CClient+1,CArtikul);
        GetReestrVekselClient(Numer,SNumer);
        DelSpace(SNumer);

        While Pos('│',s)>0 Do
         Begin
          k:=Pos('│',s);
          System.Delete(s,k,1);
          System.Insert(SeparatorChar,s,k);
         End;
        Writeln(f,Space+SNumer+SeparatorChar+s);
  End;
 Writeln(f,Space+'───────────────────────────────────────────────────────────────────────────────────');

 s:='Всего на сумму:'+SeparatorChar+RecognizReal(StrToReal(AllSumma),CIZena,CMAntissa)+' руб';
 Writeln(f,Space+s);
 s:='Всего векселей:'+SeparatorChar+AllDoc;
 Writeln(f,Space+s);
 Writeln(f);
 Writeln(f,Space,'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
 Writeln(f,Space+'===================================================');


 System.Close(f);
 ViewAsText(Path^.Dat.ToTemp+'listv.txt','Отчет реестр векселей с '+StartDate+' по '+StopDate,True);
 {ReportNew(Path^.Dat.ToTemp+'listv.txt','',NprintC^.DAt.CopyAll,False,False);}
 End;
End;


Function TReestrVeWindow.DeleteVeksel:Boolean;
Var Doc,Date:TDateString;
    E  : PSuperMarketType;
    Ef : MarketFileType;
         i : Word;
    Fresh,Find : Boolean;
    Ass : DocumentEditZ;
    Summa : AllStr;
    Numer : TDateString;
    Ex : VekselType;
    Event : TEvent;
Begin
DeleteVeksel:=False;
If (DocList^.List<>Nil)And(DocList^.List^.Count>=1) Then
Begin
  Numer:=Copy(DocList^.GetText(DocList^.Focused,DocList^.List^.Count),1+CClient+1,CArtikul);
  Numer:=IntToStr(StrToInt(Numer),CArtikul);
  Ass.D:=Copy(DocList^.GetText(DocList^.Focused,DocList^.List^.Count),1+CClient+1+CArtikul+1,CDate);
  DelSpace(Ass.D);
End
Else Exit;

If Not(TestOpenDate1(Assistent.D)) Then
   Begin
    MessageBox(#3^M+#3'Доступ к данным за '+Assistent.D+' заблокирован!',Nil,mfError+mfCancelButton);
    Exit;
   End;

If (GlobalReadOnly=1) Or (ReadOnlyConst=1) Then
   Begin
    MessageBox(#3^M+ReadOnlyStr^,Nil,mfWarning+mfCancelButton);
    Exit;
   End;

If Not(TestSetupKurs(Ass.D)) Then
   Begin
    Exit;
   End;

If MessageBox(^M+#3'Удалить вексельную оплату?',Nil,mfConfirmation+mfOkCancel)<>cmOk Then Exit;

  If Not(FreeReestrVekselOne(Numer)) Then
    Begin
     MessageBox(^M+#3'Не могу освободить номера векселей! '+ClicProgrammer^,Nil,mfInformation+mfCancelButton);
     Exit;
    End;

   MessageBox(^M+#3'Вексельная оплата успешно удалена!',Nil,mfInformation+mfCancelButton);
DeleteVeksel:=True;
End;




procedure TReestrVeWindow.HandleEvent(var Event: TEvent);
Var test : Word;
    s,s1 : String;
    SDoc : ArtikulStr;
    SDate: TDateString;
    l : Boolean;
    FC:Byte;
    FS : AllStr;
    V: Word;
    R : TRect;

begin

  Case Event.What Of
  evKeyDown :
  Case Event.KeyCode Of
     kbDel:Begin
             If Password(12) Then
             Begin
              DeleteVeksel;
              Refresh;
              SortScreenList(False);
              Redraw;
             End;
           End;
kbCtrlF9: Begin
       CorrectVeksel;
       ClearEvent(Event);
       Redraw;
      End;
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

  cmGetName: Begin
              PString(Event.InfoPtr)^ := 'Реестр векселей за период с '+StartDate+' по '+StopDate;
              ClearEvent(Event);
              Exit;
             End;

 cmChangeDiapason :
        Begin
          If (DatePeriodDialog1(DateMask,StartDate,StopDate)) Then
                 Begin

Dispose(ControlStart,Done);
R.Assign(59, 21, 67, 22);
ControlStart := New(PColoredText, Init(R, StartDate, $7E));
Insert(ControlStart);

Dispose(ControlStop,Done);
R.Assign(71, 21, 79, 22);
ControlStop := New(PColoredText, Init(R, StopDate, $7E));
Insert(ControlStop);


            Refresh;
            SortScreenList(False);
            Redraw;
           End;
          ClearEvent(Event);
        End;

  cmRefresh: Begin
  If (DeskTop^.Current=PView(DocReestrWindow)) And (Event.What <> EvKeyDown)
      And Not(Glob.Show) And Not(Glob.ShowMsg) And Not(Glob.GlobalShow) Then
           Begin
              Refresh;
              ClearEvent(Event);
              PrevCur[0]:=#0;
              SortScreenList(False);
              Redraw;
           End
           Else
            ClearEvent(Event);
          End;
  cmPrintReestr:    Begin
                 ClearFind;
     If (DocList^.State and sfFocused <> 0) And (DocList^.List<>Nil)And(DocList^.List^.Count>=1) Then
            Begin
             PrintVe;
            End
                    End;
 cmReestrReport:    Begin
                 ClearFind;
     If (DocList^.List<>Nil)And(DocList^.List^.Count>=1) Then
            Begin
            FormReport(DocList);
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
                PrintNakl(Assistent);
                Status:=DocNormal;}
            End
            End;
     cmReestrVe:Begin
                  ClearFind;
                  ClearEvent(Event);
                 End;
     cmCancel    : Begin
                 Dispose(NoScreenList,Done);
                {Dispose(ControlRefreshTime,Done);
                 Dispose(ControlCombo,Done);
                 Dispose(ControlAllClient,Done);
                 Dispose(ControlAllSkid,Done);
                 Dispose(ControlAllSumma,Done);
                 Dispose(ControlAllDoc,Done);
                 Dispose(ControlAllTara,Done);
                 Dispose(ControlFiltr,Done);}
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
    (Event.Command = cmReestrVe) then ClearEvent(Event);

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

BEgin
Direction:=0;
Sorting:=0;

AllDoc[0]:=#0;
AllSumma[0]:=#0;
StartDate:=FDate;
StopDate:=FDate;
End.