Unit TulaDecl;

{Декларация по рознице - изобретение адм.Тул.обл}

INTERFACE

Uses Glob,ServStr;

function CalcTulaDeclareOborot: boolean;

IMPLEMENTATION

Uses Objects,App,Views,Validate,MsgBox, TPDate,Printers,Prise,
     Serv,Dialogs,Drivers,DBengin2,
     NetDbEng,DBEngine, Tools, Utils,Utils5, ColorTxt,Utils3,Utils4;

const posArt = 1;
      posOstN = posArt+CArtikul+1;
      posPrhProizvTUla = posOstN+CIZena+1;
      posPrhProizvNeTula = posPrhProizvTUla+CIZena+1;
      posPrhOptTula = posPrhProizvNeTula+CIZena+1;
      posPrhOptNeTula = posPrhOptTula+CIZena+1;
      posPrhOptImp = posPrhOptNeTula+CIZena+1;
      posMrkTula = posPrhOptImp+CIZena+1;
      posMrkNeTula = posMrkTula+CIZena+1;
      posMrkEksp = posMrkNeTula+CIZena+1;
      posMrkSumma = posMrkEksp+CIZena+1;
      posVozvRew = posMrkSumma+CIZena+1;
      posOstK = posVozvRew+CIZena+1;
      posDate = posOstK+CIZena+1;
      posDoc = posDate+CDate+1;

      Dall = 10000;

Shablon ='│              0│              0│              0│              0│              0│              0│              0│'

{          posOstN         posPrhProizvTUla posPrhProizvNeTula posPrhOptTula posPrhOptNeTula posPrhOptImp  posMrkTula
  posMrkNeTula    posMrkEksp      posMrkSumma     posVozvRew      posOstK }
+'              0│              0│              0│              0│              0│';
ShablonD ='│              0';


Type {выбор клиентов}
  PSelectClientWindow = ^TSelectClientWindow;
  TSelectClientWindow = object(TDialog)
    procedure AddName;
    Destructor Done; virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
  end;


const BufferNewItog = 30;

Type BufNewItogType = Record
     Dat : Array [1..BufferNewItog] Of NewItogType;
     end;

var TempBox: PBox;
    PostavkaBox: PBox;
    PostavkaBox1: PBox;
    ZakupkaBox: PBox;
    {ZakupkaBox1: PBox;}
    ErrorBox: PBox;
    SelectClass: boolean;
    bClient: boolean;
    ClientWin:PSelectClientWindow;
    ClientAll,Cl : PBox;
    ClientSelect : PBox;
    n200: PBox;
    n212: PBox;
    n230: PBox;
    n211: PBox;
    n420: PBox;
    n250: PBox;
    n260: PBox;

    s200: string[CIZena];
    s212: string[CIZena];
    s230: string[CIZena];
    s211: string[CIZena];
    s420: string[CIZena];
    s250: string[CIZena];
    s260: string[CIZena];


    ControlAmount2,ControlAmount1,ControlAmount : PView;

Function TestAgent(Cod:ArtikulStr;Const Agent:PBox):Boolean;
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


Destructor TSelectClientWindow.Done;
Begin
TDialog.Done;
End;



procedure TSelectClientWindow.HandleEvent(var Event: TEvent);
Label 2,3;
Var s,s1 : String{[CClient+1+CClientKod]};
    ls : Word;
    res : Word;
    Logik : Boolean;
    fstr : TMyString;
Begin
  Case Event.What Of
  evCommand : Begin
              End;
  evKeyDown :
  Case Event.KeyCode Of
   kbEnter  :Begin
                ClearFind;
                inherited HandleEvent(Event);
                If (ClientWin^.Current=PView(ClientSelect)) Then
                   Begin
                    Event.What:=evCommand;
                    Event.Command:=CmOk;
                   End;
             End;

   kbGrayPlus,kbAltF1:Begin
                ClearFind;
          If ((ClientAll^.State and sfFocused <> 0)And(ClientAll^.List^.Count>= 1)) Then
            Begin
               fstr[0]:=#0;
               Res:=0;
               ProdagaWindow:=False;
               ClearFind;
               If MaskaSelect(fstr,Res) Then
                Begin
             DInfoMsg('Минуточку...',True);
             For ls :=0 To ClientAll^.List^.Count-1 Do
              Begin
               s:=ClientAll^.GetText(ls,ClientAll^.List^.Count);
               Logik:=False;
               s1:=Copy(s,1,CClient);
               DelSpaceRight(s1);
               Case Res Of
               0:If (Pos(fstr,s1)>0) Or (Pos('*',Fstr)>0) Then Logik:=True;
               1:If (fstr=s1)Then Logik:=True;
               Else ;
               End;{Case}

               If Logik Then
               If TestElement(Copy(s,1+CClient+1,CArtikul),ClientSelect) Then
                Begin
                 ClientSelect^.List^.Insert(NewStr(s));
                 ClientSelect^.SetRange(ClientSelect^.List^.Count);
                End;{TestElement}
              End;{For}
              NoInfoMsg;
              ProdagaWindow:=False;
              If ClientSelect^.Focused+1<ClientSelect^.List^.Count Then
              ClientSelect^.FocusItem(ClientSelect^.List^.Count-1);
              ClientSelect^.FocusItem(0);
              AddName;
                End;{Maska}
              Redraw;
            End;{Nil}
              ClearEvent(Event);
              End;
   kbGrayMinus,kbAltF2:Begin
                ClearFind;

          If ((ClientSelect^.State and sfFocused <> 0)And(ClientSelect^.List^.Count>= 1)) Then
            Begin
               fstr[0]:=#0;
               Res:=0;
               ProdagaWindow:=False;
               ClearFind;
               If MaskaSelect(fstr,Res) Then
                Begin
             DInfoMsg('Минуточку...',True);
             3:
             if (ClientSelect^.List^.Count>= 1) Then
             For ls :=0 To ClientSelect^.List^.Count-1 Do
              Begin
               s:=ClientSelect^.GetText(ls,ClientSelect^.List^.Count);
               Logik:=False;
               s1:=Copy(s,1,CClient);
               DelSpaceRight(s1);
               Case Res Of
               0:If (Pos(fstr,s1)>0)Or (Pos('*',Fstr)>0)  Then Logik:=True;
               1:If (fstr=s1) Then Logik:=True;
               Else ;
               End;{Case}

               If Logik Then
               Begin
                ClientSelect^.List^.AtFree(Ls);
                ClientSelect^.SetRange(ClientSelect^.List^.Count);
                goto 3;
               End;
              End;{For}

             If ClientSelect^.Focused>0 Then
             ClientSelect^.FocusItem(ClientSelect^.Focused);

             If (ClientSelect^.Focused>=ClientSelect^.List^.Count) and(ClientSelect^.Focused>0) Then
             ClientSelect^.FocusItem(ClientSelect^.Focused-1);


              NoInfoMsg;
              ProdagaWindow:=False;
              AddName;
              ClientSelect^.FocusItem(0);
                End;{Maska}
             Redraw;
            End;{Nil}
              ClearEvent(Event);
              End;
   kbCtrlIns: Begin
                ClearFind;
            If ((ClientAll^.State and sfFocused <> 0)And(ClientAll^.List^.Count>= 1)) Then
            Begin
            DInfoMsg('Минуточку...',True);
             ClientSelect^.Focusitem(0);
             For ls :=0 To ClientAll^.List^.Count-1 Do
              Begin
               s:=ClientAll^.GetText(ls,ClientAll^.List^.Count);
               if Testelement(Copy(s,1+CClient+1,CClientKod),ClientSelect) then
                Begin
                 ClientSelect^.List^.Insert(NewStr(s));
                End;
              End;
                 ClientSelect^.SetRange(ClientSelect^.List^.Count);
                 If ClientAll^.Focused+1<ClientAll^.List^.Count Then ClientAll^.FocusItem(ClientAll^.Focused+1);
                 If ClientSelect^.Focused+1<ClientSelect^.List^.Count Then
                 ClientSelect^.FocusItem(ClientSelect^.List^.Count-1);
            NoInfoMsg;
             End
            Else ClearEvent(Event);
            AddName;
            Redraw;
            End;

  kbCtrLDel: Begin
                ClearFind;
     If (ClientSelect^.State and sfFocused <> 0) And (ClientSelect^.List<>Nil)And(ClientSelect^.List^.Count>=1) Then
            Begin
             ClientSelect^.NewList(nil);
             ClientSelect^.NewList(New(PTextCollection, Init(1,25)));
            End;
            AddName;
            ClearEvent(Event);
             Redraw;
            End;
     kbDel: Begin
                ClearFind;
     If (ClientSelect^.State and sfFocused <> 0) And (ClientSelect^.List<>Nil)And(ClientSelect^.List^.Count>=1) Then
            Begin
             ClientSelect^.List^.AtFree(ClientSelect^.Focused);
             ClientSelect^.SetRange(ClientSelect^.List^.Count);
             If ClientSelect^.Focused>0 Then
             ClientSelect^.FocusItem(ClientSelect^.Focused);

             If (ClientSelect^.Focused>=ClientSelect^.List^.Count) and(ClientSelect^.Focused>0) Then
             ClientSelect^.FocusItem(ClientSelect^.Focused-1);

            End;
              AddName;
              ClearEvent(Event);
              Redraw;
            End;
      kbIns: Begin
                ClearFind;
            If(ClientAll^.State and sfFocused <> 0) And (ClientAll^.List^.Count>=1) Then
            Begin
               s:=ClientAll^.GetText(ClientAll^.Focused,ClientAll^.List^.COunt);
               If TestElement(Copy(s,1+CClient+1,CClientKod),ClientSelect) Then
               Begin
               ClientSelect^.List^.Insert(NewStr(s));
               ClientSelect^.SetRange(ClientSelect^.List^.Count);
               s:=Copy(s,1+CClient+1,CClientKod);
               ClientSelect^.FocusItem(LoCation(ClientSelect,S,ProdagaWindow));
             If ClientSelect^.Focused+1<ClientSelect^.List^.Count Then
             ClientSelect^.FocusItem(ClientSelect^.List^.Count-1);
               End;
               If (ClientAll^.Focused+1) <  ClientAll^.List^.Count Then
               ClientAll^.FocusItem(ClientAll^.Focused+1);
              End;
              AddName;
              ClearEvent(Event);
              Redraw;
            End;
    Else;
    End;
    Else;
    End;

  inherited HandleEvent(Event);

End;


procedure TSelectClientWindow.AddName;
Var R : TRect;
    KolStr : String[5];
Begin

  Str(ClientSelect^.List^.Count:4,KolStr);
  Dispose(ControlAmount1,Done);
  R.Assign(35, 22, 41, 23);
  ControlAmount1 := New(PColoredText, Init(R, #3+KolStr, $4e));
  ClientWin^.Insert(ControlAmount1);
End;




Function SelectVid:Byte;
var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  c : Word;
begin
SelectVid:=0;

R.Assign(26, 9, 56, 13);

New(Dlg, Init(R, 'Назначение'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx:=$E241;

R.Assign(1, 1, 29, 3);


  Control := New(PRadioButtons, Init(R,
  NewSItem('Для Триады',
  NewSItem('Для клиентов',  Nil))));

Dlg^.Insert(Control);

c:=0;


Dlg^.SetData(c);

Dlg^.SelectNext(False);
c:=Desktop^.ExecView(Dlg);
If c<>cmCancel Then
  Begin
   Dlg^.GetData(c);
   Dispose(Control,Done);
   Dispose(Dlg,Done);
   SelectVid:=c;
  End
  Else
  Begin
   Dispose(Control,Done);
   Dispose(Dlg,Done);
   SelectVid:=2;
  End;
end;

Function SelectionClient(Const OnlyLink:Boolean;Art:ArtikulStr;Var P:PBox):Boolean;
Label 1;
var
  R : TRect;
  Control : PView;
  i : Word;
  ClientFile : File;
  ClientElement : PBufKurzClientType;
  SKod : ArtikulStr;
  c,count : Word;
  s: string;
begin
1:
SelectionClient:=False;
ClearFind;
DInfoMsg('Минуточку...',False);
R.Assign(12, 0, 68, 23);

New(ClientWin, Init(R, 'Выборка клиентов'));

ClientWin^.Options := ClientWin^.Options or ofCenterX or ofCenterY;
ClientWin^.HelpCtx:=$E002;

R.Assign(27, 2, 28, 22);
Control := New(PScrollBar, Init(R));
ClientWin^.Insert(Control);

R.Assign(1, 2, 27, 22);
ClientAll := New(PBox, Init(R, 1, PScrollbar(Control)));
ClientAll^.NewList(New(PTextCollection, Init(1,1)));
Assign (ClientFile,Path^.Dat.ToClientBaseIndex+'Client.idx');
i:=IOResult;
Reset (ClientFile,SizeOf(KurzClientType));

i:=IOResult;
If I=0 Then
Begin
While Not(Eof(ClientFile)) Do
 Begin
  New(ClientElement,Init);
  ReadBufKurzClient(ClientFile,ClientElement,Count);
For c:=1 To Count Do
Begin

  If ClientElement^.Point.Dat[c].Employ Then
  If (Not (OnlyLink)) Or (OnlyLink And (ClientElement^.Point.Dat[c].FantomKod=StrToInt(Art)))
  Or ((ClientElement^.Point.Dat[c].Kod=StrToInt(Art))) Then
   Begin
    Format (ClientElement^.Point.Dat[c].Name,CClient);
    SKod:=IntToStr(ClientElement^.Point.Dat[c].Kod,CCLientKod);
    RFormatZerro(SKod,CClientKod);
    ClientAll^.List^.Insert(NewStr(ClientElement^.Point.Dat[c].Name+'│'+SKod));
    ClientAll^.SetRange(ClientAll^.List^.Count);
   End;
End;{For}
  Dispose(ClientElement,Done);
 End;{Eof}
System.Close(ClientFile);
End
 Else
  Begin
   NoinfoMsg;
   Dispose(Control,Done);
   Dispose(ClientAll,Done);
   Dispose(ClientWin,Done);
   MessageBox(^M+#3'Ошибка открытия файла '+Path^.Dat.ToClientBaseIndex+'client.Idx Код:'+IntToStr(I,CKol),Nil,
   mfError+mfCancelButton);
   Exit;
  End;
ClientAll^.FocusItem(0);
ClientAll^.HelpCtx:={E044}$F367;
ClientWin^.Insert(ClientAll);


  R.Assign(1, 1, 27, 2);
  ClientWin^.Insert(New(PLabel, Init(R, 'Клиент               Код ', ClientAll)));

R.Assign(55, 2, 56, 22);
Control := New(PScrollBar, Init(R));
ClientWin^.Insert(Control);

R.Assign(29, 2, 55, 22);
ClientSelect := New(PBox, Init(R, 1, PScrollbar(Control)));
ClientSelect^.NewList(New(PTextCollection, Init(1,1)));
ClientSelect^.HelpCtx:=$E044{F362};
ClientWin^.Insert(ClientSelect);

  R.Assign(29, 1, 54, 2);
  ClientWin^.Insert(New(PLabel, Init(R,'Выбранные клиенты    Код', ClientSelect)));


R.Assign(17, 22, 36, 23);
Control := New(PColoredText, Init(R, ' Выбрано клиентов:', $74));
ClientWin^.Insert(Control);

R.Assign(35, 22, 40, 23);
ControlAmount1 := New(PColoredText, Init(R, #3+'0', $4e));
ClientWin^.Insert(ControlAmount1);



ClientWin^.SelectNext(False);

{ClientWin^.AddName;}

NoInfoMsg;

C := Desktop^.ExecView(ClientWin);

If C <> cmCancel Then
 Begin
   ClearFind;
   If (ClientSelect^.List^.Count>= 1) Then
    Begin
     For c :=0 To ClientSelect^.List^.Count-1 Do
      Begin
       s:=ClientSelect^.GetText(c,ClientSelect^.List^.Count);
       Delete(s,1,CClient);
       s:=s+'│           0.00│           0.00│           0.00│           0.00│';
                                                             {акцизный сбор}
       P^.List^.Insert(NewStr(s));
       P^.SetRange(P^.List^.Count);
      End;
       Dispose(Control,Done);
       Dispose(ControlAmount1,Done);
       Dispose(ClientAll,Done);
       Dispose(ClientSelect,Done);
       Dispose(ClientWin,Done);
       SelectionClient:=True;
    End
    Else
     Begin
       MessageBox(^M+#3'Не выбрано ни одного клиента!',Nil,mfError+mfCancelButton);
       Dispose(Control,Done);
       Dispose(ControlAmount1,Done);
       Dispose(ClientAll,Done);
       Dispose(ClientSelect,Done);
       Dispose(ClientWin,Done);
       Goto 1;
     End;
 End
 Else
  Begin
   Dispose(Control,Done);
   Dispose(ControlAmount1,Done);
   Dispose(ClientAll,Done);
   Dispose(ClientSelect,Done);
   Dispose(ClientWin,Done);
  End;

End;


function BinSearch(P:PBox;var ind:word;s: string): boolean;
{по коду товара}
var l,r,m: word;
    st: string;
Begin
 BinSearch:=false;
 ind:=0;
 l:=0; r:=P^.List^.Count;
 while l<r do
 begin
   m:=(l+r) div 2;
   St:=P^.GetText(m,P^.List^.Count);
   ST:=Copy(St,1,CArtikul);
   If StrToInt(St)=StrToInt(S) Then
     begin
      BinSearch:=true;
      ind:=m;
      exit;
     end;
   if StrToInt(St)<StrToInt(s) then l:=m+1
   else r:=m;
 end;
 if StrToInt(St)=StrToInt(S) then
  Begin
   BinSearch:=true;
   ind:=m;
  End;
End;


procedure OstNAddToList(E: NewItogType);

var i,j : word;
    find: boolean;
    SumKol:String[CIZena];
    sLitr,SumZena:String[CIZena];
    sKol: String[CIZena];
    sClass: string[CClientKod];
    sRazd: string[CRazdelKOd];
    sKOd,sKOd1 : string[CArtikul];
    s: string;
Begin
if GetRazdelLitr(copy(E.bazkod,1,CRazdelKod))=1 then
begin
 find:=false;
 if not SelectClass then sKOd:=E.bazkod
 else
 sKOd:=GetIdField(FClass,E.BazKod);
 case StrToInt(sKOd) of
  0,1,200: sKOd:='200';
  420,430,440,450,400: sKod:='420';
 end;
 rformatzerro(sKOd,CArtikul);
 sLitr:=GetIdField(FLitr,E.bazkod);
 sLitr:=IntToStr(Round(StrToReal(sLitr)*1000),CIZena);
 If (TempBox^.List^.Count>0){ and (TempBox^.List^.Count<10)} Then
   begin
    for j:=0 to TempBox^.List^.Count-1 do
      begin
         s:=TempBox^.GetText(j,TempBox^.List^.Count);
         sKod1:=copy(s,1,CArtikul);
         if StrToInt(sKod1)=StrToInt(sKod) then
         begin
           {код есть в списке}

           sKol:=E.Ost;

           SumKol:=IntToStr(StrToInt(E.Ost)*StrToInt(sLitr)+
              StrToInt(copy(s,posOstN,CIzena)),CIZena);

           rformat(SumKol,CIZena);
           System.Delete(s,posOstN,CIZena);
           System.Insert(SumKol,s,posOstN);

           TempBox^.List^.AtFree(j);
           TempBox^.SetRange(TempBox^.List^.Count);

           TempBox^.List^.Insert(NewStr(s));
           TempBox^.SetRange(TempBox^.List^.Count);

           find:=true;
           break;
         end; {if StrToInt(sKod1)=StrToInt(sKod)}
      end; {for j:=0 to TempBox^.List^.Count-1}
   end  {If TempBox^.List^.Count>0}
   else
   If TempBox^.List^.Count>0 then
   if BinSearch(TempBox,j,sKOd) then
     begin
       s:=TempBox^.GetText(j,TempBox^.List^.Count);
       sKol:=E.Ost;

       SumKol:=IntToStr(StrToInt(E.Ost)*StrToInt(sLitr)+
       StrToInt(copy(s,posOstN,CIzena)),CIZena);

       rformat(SumKol,CIZena);
       System.Delete(s,posOstN,CIZena);
       System.Insert(SumKol,s,posOstN);

       TempBox^.List^.AtFree(j);
       TempBox^.SetRange(TempBox^.List^.Count);

       TempBox^.List^.Insert(NewStr(s));
       TempBox^.SetRange(TempBox^.List^.Count);

       find:=true;
     end; {if BinSearch(}

   if not Find then
   begin
    {позиция новая}
    s:=sKOd+Shablon;

    sKol:=IntToStr(StrToInt(E.Ost)*StrToInt(sLitr),CIZena);
    rFormat(sKOl,CIzena);
    System.Delete(s,posOstN,CIZena);
    System.Insert(sKol,s,posOstN);

    TempBox^.List^.Insert(NewStr(s));
    TempBox^.SetRange(TempBox^.List^.Count);
   end;

  end; {if GetRazdelLitr(sKOd)}

End;

procedure MrkAddToList(E: SuperMarkettype);
{расходы = закупке!!!!!!!}
var i,j : word;
    find: boolean;
    SumKol:String[CIZena];
    SumZena:String[CIZena];
    sKol: String[CIZena];
    sClass: string[CClientKod];
    sRazd: string[CRazdelKOd];
    sKOd,sKOd1 : string[CArtikul];
    s,ws,ws1: string;
    sLitr:String[CIZena];
    bTula: boolean;
Begin
 find:=false;

For i:=1 to E.Amount do
Begin

if GetRazdelLitr(copy(E.MarketElement[i].bazkod,1,CRazdelKod))=1 then
begin
 find:=false;
 if not SelectClass then sKOd:=E.MarketElement[i].bazkod
 else
 sKOd:=GetIdField(FClass,E.MarketElement[i].BazKod);
 bTula:=false;
 if StrToInt(sKOd)=1 then bTula:=true;
 case StrToInt(sKOd) of
  0,1,200: sKOd:='200';
  420,430,440,450,400: sKOd:='420';
 end;
 rformatzerro(sKOd,CArtikul);
 sLitr:=GetIdField(FLitr,E.MarketElement[i].bazkod);
 sLitr:=IntToStr(Round(StrToReal(sLitr)*1000),CIZena);
 If (TempBox^.List^.Count>0){ and (TempBox^.List^.Count<10)} Then
   begin
    for j:=0 to TempBox^.List^.Count-1 do
      begin
         s:=TempBox^.GetText(j,TempBox^.List^.Count);
         sKod1:=copy(s,1,CArtikul);
         if StrToInt(sKod1)=StrToInt(sKod) then
         begin
           {код есть в списке}
           sKol:=E.MarketElement[i].Input.kol;
           {БАБЛО}
           If E.SkidkaSelector=0 Then{Если автомат}
           MyStr((StrToReal(E.MarketElement[i].Input.Zena)/
           (1+StrToReal(E.MarketElement[i].Input.Proz)/100))
           ,CIZena,CMantissa,ws1){новая цена}
           Else
           MyStr((StrToReal(E.MarketElement[i].Input.Zena)-
	   StrToReal(E.MarketElement[i].Input.Skidka))
            ,CIZena,CMantissa,ws1);{новая цена}
           MyStr(StrToReal(ws1)*StrToReal(E.MarketElement[i].Input.kol)+
           StrToReal(copy(s,posMrkSumma,CIzena)),CIzena,CMantissa,ws1);
           rformat(ws1,CIZena);
           System.Delete(s,posMrkSumma,CIZena);
           System.Insert(ws1,s,posMrkSumma);

           ws:=GetPostField(FPost,GetIDField(FPost,E.MarketElement[i].BazKod));
           DelSpace(ws);
           {Тула}
           if bTula then
           begin
             SumKol:=IntToStr(StrToInt(E.MarketElement[i].Input.kol)*StrToInt(sLitr)+
             StrToInt(copy(s,posMrkTula,CIzena)),CIZena);
             rformat(SumKol,CIZena);
             System.Delete(s,posMrkTula,CIZena);
             System.Insert(SumKol,s,posMrkTula);
              {в закупки}
             System.Delete(s,posPrhOptTula,CIZena);
             System.Insert(SumKol,s,posPrhOptTula);
           end
           {Россия - не Тула}
           else if UpCAses(ws)='РОССИЯ' Then
               Begin
                 SumKol:=IntToStr(StrToInt(E.MarketElement[i].Input.kol)*StrToInt(sLitr)+
                 StrToInt(copy(s,posMrkNeTula,CIzena)),CIZena);
                 rformat(SumKol,CIZena);
                 System.Delete(s,posMrkNeTula,CIZena);
                 System.Insert(SumKol,s,posMrkNeTula);
                 System.Delete(s,posPrhOptNeTula,CIZena);
                 System.Insert(SumKol,s,posPrhOptNeTula);
               End
               {Импорт}
               else
               Begin
                 SumKol:=IntToStr(StrToInt(E.MarketElement[i].Input.kol)*StrToInt(sLitr)+
                 StrToInt(copy(s,posMrkEksp,CIzena)),CIZena);
                 rformat(SumKol,CIZena);
                 System.Delete(s,posMrkEksp,CIZena);
                 System.Insert(SumKol,s,posMrkEksp);
                 {в закупки}
                 System.Delete(s,posPrhOptImp,CIZena);
                 System.Insert(SumKol,s,posPrhOptImp);
               End;

          { memc('1!'+s);}

           TempBox^.List^.AtFree(j);
           TempBox^.SetRange(TempBox^.List^.Count);

           TempBox^.List^.Insert(NewStr(s));
           TempBox^.SetRange(TempBox^.List^.Count);

           find:=true;
           break;

         end; {if StrToInt(sKod1)=StrToInt(sKod)}
      end; {for j:=0 to TempBox^.List^.Count-1}
   end {If TempBox^.List^.Count>0}
   else
     If TempBox^.List^.Count>0 then
     if BinSearch(TempBox,j,sKOd) then
     begin
           s:=TempBox^.GetText(j,TempBox^.List^.Count);
           {БАБЛО}
           If E.SkidkaSelector=0 Then{Если автомат}
           MyStr((StrToReal(E.MarketElement[i].Input.Zena)/
           (1+StrToReal(E.MarketElement[i].Input.Proz)/100))
           ,CIZena,CMantissa,ws1){новая цена}
           Else
           MyStr((StrToReal(E.MarketElement[i].Input.Zena)-
	   StrToReal(E.MarketElement[i].Input.Skidka))
            ,CIZena,CMantissa,ws1);{новая цена}
           MyStr(StrToReal(ws1)*StrToReal(E.MarketElement[i].Input.kol)+
           StrToReal(copy(s,posMrkSumma,CIzena)),CIzena,CMantissa,ws1);
           rformat(ws1,CIZena);
           System.Delete(s,posMrkSumma,CIZena);
           System.Insert(ws1,s,posMrkSumma);
           sKol:=E.MarketElement[i].Input.kol;
           rformat(SumKol,CIZena);

           ws:=GetPostField(FPost,GetIDField(FPost,E.MarketElement[i].BazKod));
           DelSpace(ws);
           {Тула}
           if bTula then
           begin
             SumKol:=IntToStr(StrToInt(E.MarketElement[i].Input.kol)*StrToInt(sLitr)+
             StrToInt(copy(s,posMrkTula,CIzena)),CIZena);
             rformat(SumKol,CIZena);
             System.Delete(s,posMrkTula,CIZena);
             System.Insert(SumKol,s,posMrkTula);
             {в закупки}
             rformat(SumKol,CIZena);
             System.Delete(s,posPrhOptTula,CIZena);
             System.Insert(SumKol,s,posPrhOptTula);
           end
           {Россия - не Тула}
           else if UpCAses(ws)='РОССИЯ' Then
               Begin
                 SumKol:=IntToStr(StrToInt(E.MarketElement[i].Input.kol)*StrToInt(sLitr)+
                 StrToInt(copy(s,posMrkNeTula,CIzena)),CIZena);
                 rformat(SumKol,CIZena);
                 System.Delete(s,posMrkNeTula,CIZena);
                 System.Insert(SumKol,s,posMrkNeTula);
                 {в закупки}
                 System.Delete(s,posPrhOptNeTula,CIZena);
                 System.Insert(SumKol,s,posPrhOptNeTula);
               End
               {Импорт}
               else
               Begin
                 SumKol:=IntToStr(StrToInt(E.MarketElement[i].Input.kol)*StrToInt(sLitr)+
                 StrToInt(copy(s,posMrkEksp,CIzena)),CIZena);
                 rformat(SumKol,CIZena);
                 System.Delete(s,posMrkEksp,CIZena);
                 System.Insert(SumKol,s,posMrkEksp);
                 {в закупки}
                 System.Delete(s,posPrhOptImp,CIZena);
                 System.Insert(SumKol,s,posPrhOptImp);
               End;

           TempBox^.List^.AtFree(j);
           TempBox^.SetRange(TempBox^.List^.Count);

           TempBox^.List^.Insert(NewStr(s));
           TempBox^.SetRange(TempBox^.List^.Count);

           find:=true;
     end;

   if not Find then
   begin
    {позиция новая}
    {s:=E.MarketElement[i].bazkod+Shablon;}
    s:=sKOd+Shablon;

    {БАБЛО}
           If E.SkidkaSelector=0 Then{Если автомат}
           MyStr((StrToReal(E.MarketElement[i].Input.Zena)/
           (1+StrToReal(E.MarketElement[i].Input.Proz)/100))
           ,CIZena,CMantissa,ws1){новая цена}
           Else
           MyStr((StrToReal(E.MarketElement[i].Input.Zena)-
	   StrToReal(E.MarketElement[i].Input.Skidka))
            ,CIZena,CMantissa,ws1);{новая цена}
           MyStr(StrToReal(ws1)*StrToReal(E.MarketElement[i].Input.kol),CIzena,CMantissa,ws1);
           rformat(ws1,CIZena);
           System.Delete(s,posMrkSumma,CIZena);
           System.Insert(ws1,s,posMrkSumma);

    sumKol:=IntToStr(StrToInt(E.MarketElement[i].Input.Kol)*StrToInt(sLitr),CIZena);
    rFormat(sumKol,CIzena);

    ws:=GetPostField(FPost,GetIDField(FPost,E.MarketElement[i].BazKod));
    DelSpace(ws);
           {Тула}
           if bTula then
           begin
             System.Delete(s,posMrkTula,CIZena);
             System.Insert(SumKol,s,posMrkTula);
             System.Delete(s,posPrhOptTula,CIZena);
             System.Insert(SumKol,s,posPrhOptTula);
           end
           {Россия - не Тула}
           else if UpCAses(ws)='РОССИЯ' Then
               Begin
                 System.Delete(s,posMrkNeTula,CIZena);
                 System.Insert(SumKol,s,posMrkNeTula);
                 System.Delete(s,posPrhOptNeTula,CIZena);
                 System.Insert(SumKol,s,posPrhOptNeTula);
               End
               {Импорт}
               else
               Begin
                 System.Delete(s,posMrkEksp,CIZena);
                 System.Insert(SumKol,s,posMrkEksp);
                 System.Delete(s,posPrhOptImp,CIZena);
                 System.Insert(SumKol,s,posPrhOptImp);
               End;

            {   memc('3!'+s);}

    TempBox^.List^.Insert(NewStr(s));
    TempBox^.SetRange(TempBox^.List^.Count);
   end;

  end; {if GetRazdelLitr(sKOd)}
 end;  {For i:=1 to E.Amount}

End;

procedure MrkClientAddToList(E: SuperMarkettype;skl:word);
{расходы = закупке!!!!!!! - тока зачем это клиентам??????}
var i,j : word;
    find: boolean;
    SumKol:String[CIZena];
    SumZena:String[CIZena];
    sKol: String[CIZena];
    sClass: string[CClientKod];
    sRazd: string[CRazdelKOd];
    sKOd,sKOd1 : string[CArtikul];
    s,ws,ws1: string;
    sLitr:String[CIZena];
    bTula: boolean;
    sDate,sDoc,sDoc1: string;
Begin
 find:=false;

For i:=1 to E.Amount do
Begin

if GetRazdelLitr(copy(E.MarketElement[i].bazkod,1,CRazdelKod))=1 then
begin
 find:=false;
 if not SelectClass then sKOd:=E.MarketElement[i].bazkod
 else
 sKOd:=GetIdField(FClass,E.MarketElement[i].BazKod);


 bTula:=false;
 if StrToInt(sKOd)=1 then bTula:=true;
 case StrToInt(sKOd) of
  0,1,200: sKOd:='200';
  420,430,440,450,400: sKOd:='420';
 end;

 {memc(E.MarketElement[i].BazKod+' '+sKOd);}

 rformatzerro(sKOd,CArtikul);
 sLitr:=GetIdField(FLitr,E.MarketElement[i].bazkod);
 sLitr:=IntToStr(Round(StrToReal(sLitr)*1000),CIZena);
 If (TempBox^.List^.Count>0) {and (TempBox^.List^.Count<10)} Then
   begin
    for j:=0 to TempBox^.List^.Count-1 do
      begin
         s:=TempBox^.GetText(j,TempBox^.List^.Count);
         sKod1:=copy(s,1,CArtikul);
         sDate:=copy(s,posDate,CDate);
         sDoc:=copy(s,posDoc,CDocNumer+3);
         Delspace(sDoc);
         sDoc1:=E.Document+'/'+IntToStr(skl,2);
         {memc(sDoc1+' '+sDoc);}
         Delspace(sDoc1);
         if StrToInt(sKod1)=StrToInt(sKod) then
         if E.DateC=sDate then
         if sDoc1=sDoc then
         begin
           {код есть в списке}
           sKol:=E.MarketElement[i].Input.kol;
           {БАБЛО}
           If E.SkidkaSelector=0 Then{Если автомат}
           MyStr((StrToReal(E.MarketElement[i].Input.Zena)/
           (1+StrToReal(E.MarketElement[i].Input.Proz)/100))
           ,CIZena,CMantissa,ws1){новая цена}
           Else
           MyStr((StrToReal(E.MarketElement[i].Input.Zena)-
	   StrToReal(E.MarketElement[i].Input.Skidka))
            ,CIZena,CMantissa,ws1);{новая цена}
           MyStr(StrToReal(ws1)*StrToReal(E.MarketElement[i].Input.kol)+
           StrToReal(copy(s,posMrkSumma,CIzena)),CIzena,CMantissa,ws1);
           rformat(ws1,CIZena);
           System.Delete(s,posMrkSumma,CIZena);
           System.Insert(ws1,s,posMrkSumma);

           {memc(E.MarketElement[i].BazKod);}

           ws:=GetPostField(FPost,GetIDField(FPost,E.MarketElement[i].BazKod));
           DelSpace(ws);
           {Тула}
           if bTula then
           begin
             SumKol:=IntToStr(StrToInt(E.MarketElement[i].Input.kol)*StrToInt(sLitr)+
             StrToInt(copy(s,posMrkTula,CIzena)),CIZena);
             rformat(SumKol,CIZena);
             System.Delete(s,posMrkTula,CIZena);
             System.Insert(SumKol,s,posMrkTula);
              {в закупки}
             System.Delete(s,posPrhOptTula,CIZena);
             System.Insert(SumKol,s,posPrhOptTula);
           end
           {Россия - не Тула}
           else if UpCAses(ws)='РОССИЯ' Then
               Begin
                 SumKol:=IntToStr(StrToInt(E.MarketElement[i].Input.kol)*StrToInt(sLitr)+
                 StrToInt(copy(s,posMrkNeTula,CIzena)),CIZena);
                 rformat(SumKol,CIZena);
                 System.Delete(s,posMrkNeTula,CIZena);
                 System.Insert(SumKol,s,posMrkNeTula);
                 System.Delete(s,posPrhOptNeTula,CIZena);
                 System.Insert(SumKol,s,posPrhOptNeTula);
               End
               {Импорт}
               else
               Begin
                 SumKol:=IntToStr(StrToInt(E.MarketElement[i].Input.kol)*StrToInt(sLitr)+
                 StrToInt(copy(s,posMrkEksp,CIzena)),CIZena);
                 rformat(SumKol,CIZena);
                 System.Delete(s,posMrkEksp,CIZena);
                 System.Insert(SumKol,s,posMrkEksp);
                 {в закупки}
                 System.Delete(s,posPrhOptImp,CIZena);
                 System.Insert(SumKol,s,posPrhOptImp);
               End;

          { memc('1!'+s);}

           TempBox^.List^.AtFree(j);
           TempBox^.SetRange(TempBox^.List^.Count);

           TempBox^.List^.Insert(NewStr(s));
           TempBox^.SetRange(TempBox^.List^.Count);

           find:=true;
           break;

         end; {if StrToInt(sKod1)=StrToInt(sKod)}
      end; {for j:=0 to TempBox^.List^.Count-1}
   end {If TempBox^.List^.Count>0}
   else
   If (TempBox^.List^.Count>0) then
   if BinSearch(TempBox,j,sKOd) then
     begin
           memcc;
           s:=TempBox^.GetText(j,TempBox^.List^.Count);
           {БАБЛО}
           If E.SkidkaSelector=0 Then{Если автомат}
           MyStr((StrToReal(E.MarketElement[i].Input.Zena)/
           (1+StrToReal(E.MarketElement[i].Input.Proz)/100))
           ,CIZena,CMantissa,ws1){новая цена}
           Else
           MyStr((StrToReal(E.MarketElement[i].Input.Zena)-
	   StrToReal(E.MarketElement[i].Input.Skidka))
            ,CIZena,CMantissa,ws1);{новая цена}
           MyStr(StrToReal(ws1)*StrToReal(E.MarketElement[i].Input.kol)+
           StrToReal(copy(s,posMrkSumma,CIzena)),CIzena,CMantissa,ws1);
           rformat(ws1,CIZena);
           System.Delete(s,posMrkSumma,CIZena);
           System.Insert(ws1,s,posMrkSumma);
           sKol:=E.MarketElement[i].Input.kol;
           rformat(SumKol,CIZena);

           ws:=GetPostField(FPost,GetIDField(FPost,E.MarketElement[i].BazKod));
           DelSpace(ws);
           {Тула}
           if bTula then
           begin
             SumKol:=IntToStr(StrToInt(E.MarketElement[i].Input.kol)*StrToInt(sLitr)+
             StrToInt(copy(s,posMrkTula,CIzena)),CIZena);
             rformat(SumKol,CIZena);
             System.Delete(s,posMrkTula,CIZena);
             System.Insert(SumKol,s,posMrkTula);
             {в закупки}
             rformat(SumKol,CIZena);
             System.Delete(s,posPrhOptTula,CIZena);
             System.Insert(SumKol,s,posPrhOptTula);
           end
           {Россия - не Тула}
           else if UpCAses(ws)='РОССИЯ' Then
               Begin
                 SumKol:=IntToStr(StrToInt(E.MarketElement[i].Input.kol)*StrToInt(sLitr)+
                 StrToInt(copy(s,posMrkNeTula,CIzena)),CIZena);
                 rformat(SumKol,CIZena);
                 System.Delete(s,posMrkNeTula,CIZena);
                 System.Insert(SumKol,s,posMrkNeTula);
                 {в закупки}
                 System.Delete(s,posPrhOptNeTula,CIZena);
                 System.Insert(SumKol,s,posPrhOptNeTula);
               End
               {Импорт}
               else
               Begin
                 SumKol:=IntToStr(StrToInt(E.MarketElement[i].Input.kol)*StrToInt(sLitr)+
                 StrToInt(copy(s,posMrkEksp,CIzena)),CIZena);
                 rformat(SumKol,CIZena);
                 System.Delete(s,posMrkEksp,CIZena);
                 System.Insert(SumKol,s,posMrkEksp);
                 {в закупки}
                 System.Delete(s,posPrhOptImp,CIZena);
                 System.Insert(SumKol,s,posPrhOptImp);
               End;

           TempBox^.List^.AtFree(j);
           TempBox^.SetRange(TempBox^.List^.Count);

           TempBox^.List^.Insert(NewStr(s));
           TempBox^.SetRange(TempBox^.List^.Count);

           find:=true;
     end;

   if not Find then
   begin
    {позиция новая}
    {s:=E.MarketElement[i].bazkod+Shablon;}
    s:=sKOd+Shablon;
    sDate:=E.DateC;
    sDoc:=E.Document+'/'+IntToStr(skl,2);
    format(sDate,CDate);
    rformat(sDoc,CDocNumer);
    s:=s+sDate+'│'+sDoc;
    {БАБЛО}
           If E.SkidkaSelector=0 Then{Если автомат}
           MyStr((StrToReal(E.MarketElement[i].Input.Zena)/
           (1+StrToReal(E.MarketElement[i].Input.Proz)/100))
           ,CIZena,CMantissa,ws1){новая цена}
           Else
           MyStr((StrToReal(E.MarketElement[i].Input.Zena)-
	   StrToReal(E.MarketElement[i].Input.Skidka))
            ,CIZena,CMantissa,ws1);{новая цена}
           MyStr(StrToReal(ws1)*StrToReal(E.MarketElement[i].Input.kol),CIzena,CMantissa,ws1);
           rformat(ws1,CIZena);
           System.Delete(s,posMrkSumma,CIZena);
           System.Insert(ws1,s,posMrkSumma);

    sumKol:=IntToStr(StrToInt(E.MarketElement[i].Input.Kol)*StrToInt(sLitr),CIZena);
    rFormat(sumKol,CIzena);

    ws:=GetPostField(FPost,GetIDField(FPost,E.MarketElement[i].BazKod));
    DelSpace(ws);
           {Тула}
           if bTula then
           begin
             System.Delete(s,posMrkTula,CIZena);
             System.Insert(SumKol,s,posMrkTula);
             System.Delete(s,posPrhOptTula,CIZena);
             System.Insert(SumKol,s,posPrhOptTula);
           end
           {Россия - не Тула}
           else if UpCAses(ws)='РОССИЯ' Then
               Begin
                 System.Delete(s,posMrkNeTula,CIZena);
                 System.Insert(SumKol,s,posMrkNeTula);
                 System.Delete(s,posPrhOptNeTula,CIZena);
                 System.Insert(SumKol,s,posPrhOptNeTula);
               End
               {Импорт}
               else
               Begin
                 System.Delete(s,posMrkEksp,CIZena);
                 System.Insert(SumKol,s,posMrkEksp);
                 System.Delete(s,posPrhOptImp,CIZena);
                 System.Insert(SumKol,s,posPrhOptImp);
               End;

           {    writeln(s);
               readln;     }

    TempBox^.List^.Insert(NewStr(s));
    TempBox^.SetRange(TempBox^.List^.Count);
   end;

  end; {if GetRazdelLitr(sKOd)}
 end;  {For i:=1 to E.Amount}

End;



procedure PrhOptAddToList(E: Prihodtype);
var i,j : word;
    find: boolean;
    SumKol:String[CIZena];
    sLitr,SumZena:String[CIZena];
    sKol: String[CIZena];
    sClass: string[CClientKod];
    sRazd: string[CRazdelKOd];
    sKOd,sKOd1: string[CArtikul];
    bTula: boolean;
    s,ws: string;
Begin
 find:=false;

For i:=1 to E.Amount do
Begin
if GetRazdelLitr(copy(E.PrihodElement[i].bazkod,1,CRazdelKod))=1 then
begin
 find:=false;
 if not SelectClass then sKOd:=E.PrihodElement[i].bazkod
 else
 sKOd:=GetIdField(FClass,E.PrihodElement[i].BazKod);
 bTula:=false;
 if StrToInt(sKOd)=1 then bTula:=true;
 case StrToInt(sKOd) of
  0,1,200: sKOd:='200';
  420,430,400,440,450: sKod:='420';
 end;
 rformatzerro(sKOd,CArtikul);
 sLitr:=GetIdField(FLitr,E.PrihodElement[i].bazkod);
 sLitr:=IntToStr(Round(StrToReal(sLitr)*1000),CIZena);
 If (TempBox^.List^.Count>0) and (TempBox^.List^.Count<10) Then
   begin
    for j:=0 to TempBox^.List^.Count-1 do
      begin
         s:=TempBox^.GetText(j,TempBox^.List^.Count);
         sKod1:=copy(s,1,CArtikul);
         if StrToInt(sKod1)=StrToInt(sKod) then
         begin
           {код есть в списке}
           sKol:=E.PrihodElement[i].Input.kol;
           ws:=GetPostField(FPost,GetIDField(FPost,E.PrihodElement[i].BazKod));
           DelSpace(ws);
           {Тула}
           if bTula then
           begin
             SumKol:=IntToStr(StrToInt(E.PrihodElement[i].Input.kol)*StrToInt(sLitr)+
             StrToInt(copy(s,posPrhOptTula,CIzena)),CIZena);
             rformat(SumKol,CIZena);
             System.Delete(s,posPrhOptTula,CIZena);
             System.Insert(SumKol,s,posPrhOptTula);
           end
           {Россия - не Тула}
           else if UpCAses(ws)='РОССИЯ' Then
               Begin
                 SumKol:=IntToStr(StrToInt(E.PrihodElement[i].Input.kol)*StrToInt(sLitr)+
                 StrToInt(copy(s,posPrhOptNeTula,CIzena)),CIZena);
                 rformat(SumKol,CIZena);
                 System.Delete(s,posPrhOptNeTula,CIZena);
                 System.Insert(SumKol,s,posPrhOptNeTula);
               End
               {Импорт}
               else
               Begin
                 SumKol:=IntToStr(StrToInt(E.PrihodElement[i].Input.kol)*StrToInt(sLitr)+
                 StrToInt(copy(s,posPrhOptImp,CIzena)),CIZena);
                 rformat(SumKol,CIZena);
                 System.Delete(s,posPrhOptImp,CIZena);
                 System.Insert(SumKol,s,posPrhOptImp);
               End;

           TempBox^.List^.AtFree(j);
           TempBox^.SetRange(TempBox^.List^.Count);

           TempBox^.List^.Insert(NewStr(s));
           TempBox^.SetRange(TempBox^.List^.Count);

           find:=true;
           break;
         end; {if StrToInt(sKod1)=StrToInt(sKod)}
      end; {for j:=0 to TempBox^.List^.Count-1}
   end  {If TempBox^.List^.Count>0}
   else if BinSearch(TempBox,j,sKOd) then
   begin
           {код есть в списке}
           sKol:=E.PrihodElement[i].Input.kol;
           ws:=GetPostField(FPost,GetIDField(FPost,E.PrihodElement[i].BazKod));
           DelSpace(ws);
           {Тула}
           if bTula then
           begin
             SumKol:=IntToStr(StrToInt(E.PrihodElement[i].Input.kol)*StrToInt(sLitr)+
             StrToInt(copy(s,posPrhOptTula,CIzena)),CIZena);
             rformat(SumKol,CIZena);
             System.Delete(s,posPrhOptTula,CIZena);
             System.Insert(SumKol,s,posPrhOptTula);
           end
           {Россия - не Тула}
           else if UpCAses(ws)='РОССИЯ' Then
               Begin
                 SumKol:=IntToStr(StrToInt(E.PrihodElement[i].Input.kol)*StrToInt(sLitr)+
                 StrToInt(copy(s,posPrhOptNeTula,CIzena)),CIZena);
                 rformat(SumKol,CIZena);
                 System.Delete(s,posPrhOptNeTula,CIZena);
                 System.Insert(SumKol,s,posPrhOptNeTula);
               End
               {Импорт}
               else
               Begin
                 SumKol:=IntToStr(StrToInt(E.PrihodElement[i].Input.kol)*StrToInt(sLitr)+
                 StrToInt(copy(s,posPrhOptImp,CIzena)),CIZena);
                 rformat(SumKol,CIZena);
                 System.Delete(s,posPrhOptImp,CIZena);
                 System.Insert(SumKol,s,posPrhOptImp);
               End;

           TempBox^.List^.AtFree(j);
           TempBox^.SetRange(TempBox^.List^.Count);

           TempBox^.List^.Insert(NewStr(s));
           TempBox^.SetRange(TempBox^.List^.Count);

           find:=true;
   end;

   if not Find then
   begin
    {позиция новая}
    s:=sKOd+Shablon;

    sKol:=IntToStr(StrToInt(E.PrihodElement[i].Input.Kol)*StrToInt(sLitr),CIZena);
    rFormat(sKOl,CIzena);
    ws:=GetPostField(FPost,GetIDField(FPost,E.PrihodElement[i].BazKod));
           DelSpace(ws);
           {Тула}
           if bTula then
           begin
             System.Delete(s,posPrhOptTula,CIZena);
             System.Insert(SumKol,s,posPrhOptTula);
           end
           {Россия - не Тула}
           else if UpCAses(ws)='РОССИЯ' Then
               Begin
                 System.Delete(s,posPrhOptNeTula,CIZena);
                 System.Insert(SumKol,s,posPrhOptNeTula);
               End
               {Импорт}
               else
               Begin
                 System.Delete(s,posPrhOptImp,CIZena);
                 System.Insert(SumKol,s,posPrhOptImp);
               End;
    TempBox^.List^.Insert(NewStr(s));
    TempBox^.SetRange(TempBox^.List^.Count);
   end;

  end; {if GetRazdelLitr(sKOd)}
 end;  {For i:=1 to E.Amount}

End;




function CalcTulaDeclareOborot: boolean;

label l1,l2;

var AllSkl: Maska30;
    t,tt: text;
    IORez,cc, Count,i: word;
    Den, Start, Stop,OstNach: longint;
    Errors: PBox;
    tekSkl,ii: word;
    Date: TDateString;
    StartDate,StopDate,ostDate : TDateString;
    OldFileMode,c1,l : Word;
    AllEnable: longint;
    pf: file;
    fm,fp:File;
    p: PBufPrihodType;
    m: PBufSuperMarketType;
    fv: file of NewVozwratType;
    v: PNewVozwratType;
    R: Trect;
    s: string;
    SklKod: string[CRazdelKod];
    BufItog: BufNewItogType;
    NItg: PNewItogType;
    findost: boolean;
    FR:RewisiaFileType;
    RW: PRewisiaType;
    sKOd,sKod1: string[CArtikul];
    sAllPrh, sAll1Prh,sAllMrk, sAll1Mrk: string[CIZena];
    sLitr,sLitr1: string[CIZena];
    sCl: string[CClientKod];
    INN : String[CName];
    Event: TEvent;
    ws: string;
    sVsego,sVsegoTula,sVsegoNeTula,sVsegoImp: string[CIzena];
    sDate: string[CDate];
    sNum: string[CDocNumer+3];

procedure Print2(s:string;n:PBox);
var ws: string;
    i: word;
Begin
  write(t,';'+s+';');
  write(t,DosToWin(Rek^.Dat.Name+','+Rek^.Dat.Adress+','+s+';'));
  if n^.List^.Count>0 then
  for i:=0 to n^.List^.Count-1 do
  begin
   ws:=n^.GetText(i,n^.List^.Count);
   write(t,DosToWin(ws));
  end;
  writeln(t);
End;


Begin

   cc:=SelectVid;
   if cc=2 then exit;
   if cc=1 then bClient:=true
   else bClient:=false;


if bClient then
begin
   R.Assign(0, 0, 0, 0);
   Cl := New(PBox, Init(R, 1, Nil));
   Cl^.NewList(New(PTextCollection, Init(0,1)));
   If Not(SelectionClient(false,'',Cl)) Then
   Begin
     Dispose(Cl,Done);
   Exit;
   End;
end;

   cc:=SelectImport(33);
   if cc=2 then exit;
   if cc=1 then SelectClass:=true
   else selectclass:=false;

  {Выбор периода}
  If Not DatePeriodDialog(StartDate,StopDate,False) Then Exit;
  Start:=DateStringToDate(DateMask,StartDate);
  Stop:=DateStringToDate(DateMask,StopDate);
  {Выбор складов}
  AllEnable:=AllSKlads;
  If Not SelAssortiment(AllEnable) Then Exit;
  WordToBit30(AllEnable,AllSkl);
  Convert30(AllSkl);

  R.Assign(0, 0, 0, 0);
  ErrorBox := New(PBox, Init(R, 1, Nil));
  ErrorBox^.NewList(New(PMyCollection, Init(0,1)));

  R.Assign(0, 0, 0, 0);
  TempBox := New(PBox, Init(R, 1, Nil));
  TempBox^.NewList(New(PTextCollection, Init(0,1)));

  Assign(t,Path^.Dat.ToTemp+'tuladecl.csv');
  Iorez:=ioresult;
  Rewrite(t);
  Iorez:=ioresult;
  if IORez<>0 then
  begin
  end;


(* оказ-ся НЕНАДА! на начало-0 закупки=отгрузке, на конец - 0
    11.10.2006 - гл. бух ПМи ТС

{ОСТАТКИ НА НАЧАЛО}
  for TekSkl:=1 to CMaxSklads do
  begin
   if AllSkl[TekSkl]=1 then
   begin
   DelSpace(PathSklads^.Dat.Path[TekSkl]);

      OstNach:=Start-1;
l1:   ostDate:=DateToDateString(DateMask,OstNach);
      while pos('-',ostdate)>0 do delete(ostdate,pos('-',ostdate),1);
      if ostDate[1]='0' then delete(ostdate,1,1);
      Str(TekSkl:CRazdelKod,SklKOd);
      RformatZerro(SklKOd,CRAzdelKOd);
      if FExists (PathSklads^.Dat.Path[TekSkl]+'ARC\'+ostDate+'.p'+sklKod) then
      begin
        Assign(pf,PathSklads^.Dat.Path[TekSkl]+'ARC\'+ostDate+'.p'+sklKod);
        ioRez:=ioresult;
        Reset(pf,SizeOf(NewItogType));
        ioRez:=ioresult;
        findost:=true;
      end
      else
      begin
          dec(OstNach);
          if ostNach>Start-4 then goto l1
          else findost:=false;
      End;

if findost then
begin
New(NItg,Init);
      while not eof(pf) do
      begin
        Count:=0;
DInfoMsgShkala('Просматриваю остатки за '+DateToDateString(DateMask,OstNach)+' склада '
+GetClientField(FClient,IntToStr(TekSkl,CClientKod),1),0,FileSize(pf),FilePos(pf));
        BlockRead(pf,BufItog.Dat,BufferNewItog,Count);
        For c1:=1 To Count Do
        Begin
          NItg^.Dat:=BufItog.Dat[c1];
         if Not(GetRazdelStatus(NItg^.Dat.BazKod)) then
         begin
           OstNAddToList(NItg^.Dat);
         end;
        end; {For c1:=1 To Count Do}
      end; {while not eof(pf)}
      close(pf);
Dispose(NItg,Done);
NoinfoMsg;
end {if findost then}
else
begin
   ErrorBox^.List^.Insert(NewStr(' Отсутствуют остатки склада '+GetClientField(FClient,IntToStr(TekSkl,CClientKod),1)+' за '
    +DateToDateString(DateMask,OstNach)
     + ' "'+DayString[DayOfWeek(OstNach)]+'" '));
   ErrorBox^.SetRange(ErrorBox^.List^.Count);
end;

 end;  {if AllSkl[TekSkl]=1}
end;  {for TekSkl:=1 to CMaxSklads}

 for TekSkl:=1 to CMaxSklads do
  begin
   if AllSkl[TekSkl]=1 then
   {по датам}
   for Den:=Start to stop do
   begin
     Date:=DateToDateString(DateMask,DEn);
     DelSpace(PathSklads^.Dat.Path[TekSkl]);
     DInfoMsgShkala('Просматриваю приходы склада '+GetClientField(FClient,IntToStr(TekSkl,CClientKod),1)+'...',Start,Stop,Den);
     if PathSklads^.Dat.Path[TekSkl]<>'' then
     begin
      Assign(FP,PathSklads^.Dat.Path[TekSkl]+'PRIHOD\'+Date+'.prh');
      OldFileMode:=FileMode;
      FileMode:=ReadOnlyN;
      IORez:=IOResult;
      Reset(fp,SizeOf(PrihodType));
      IORez:=IOResult;
      FileMode:=OldFileMode;
      If IORez <> 0 Then
      Begin
       {MessageBox(#3^M+#3'Не могу ... файл '+PathSklads^.Dat.Path[TekSkl]+Date+'.prh',Nil,mfError+mfCancelButton);}
       continue;
      End;

       While Not(Eof(fp)) Do
       Begin
       cc:=0;
       New(p,Init);
       ReadBufPrihod(fp,p,Count);
       For cc:=1 To Count Do
        Begin
         If p^.Point.Dat[cc].OperatorSelector in [1] Then
         BEGIN
            PrhOptAddToList(p^.Point.Dat[cc]);
         END; {}
        End; {For cc:=1 To}
        Dispose(p,Done);
       End;{While Not(Eof(ef)) Do}
     IORez:=ioresult;
     close(fp);
     IORez:=ioresult;
     end;{if PathSklads^.Dat.Path[TekSkl]<>''}
   end;{по датам}
     NoInfoMsg;
  end;{по складам}
                               *)
 {РАСХОД}
  {по складам}
  for TekSkl:=1 to CMaxSklads do
  begin
   if AllSkl[TekSkl]=1 then
   {по датам}
   for Den:=Start to stop do
   begin
     Date:=DateToDateString(DateMask,DEn);
     DelSpace(PathSklads^.Dat.Path[TekSkl]);
     DInfoMsgShkala('Просматриваю продажи склада '+GetClientField(FClient,IntToStr(TekSkl,CClientKod),1)+'...',Start,Stop,Den);
     if PathSklads^.Dat.Path[TekSkl]<>'' then
     begin
      Assign(FM,PathSklads^.Dat.Path[TekSkl]+'MARKET\'+Date+'.mrk');
      OldFileMode:=FileMode;
      FileMode:=ReadOnlyN;
      IORez:=IOResult;
      Reset(fm,SizeOf(SuperMarketType));
      IORez:=IOResult;
      FileMode:=OldFileMode;
      If IORez <> 0 Then
      Begin
       {MessageBox(#3^M+#3'Не могу ... файл '+PathSklads^.Dat.Path[TekSkl]+Date+'.mrk',Nil,mfError+mfCancelButton);}
      ErrorBox^.List^.Insert(NewStr(' Отсутствуют продажи склада '+GetClientField(FClient,IntToStr(TekSkl,CClientKod),1)+' за '
         +DateToDateString(DateMask,Den)
         + ' "'+DayString[DayOfWeek(Den)]+'" '));
         ErrorBox^.SetRange(ErrorBox^.List^.Count);
       continue;
      End;

       While Not(Eof(fm)) Do
       Begin
       cc:=0;
       New(m,Init);
       ReadBufMarket(fm,m,Count);
       For cc:=1 To Count Do
        Begin
         If m^.Point.Dat[cc].Active Then
         If m^.Point.Dat[cc].OperatorSelector in [0,2] Then
         If ((m^.Point.Dat[cc].Realiz) And (m^.Point.Dat[cc].DocSelector in [5,6,7,8])) or Not(m^.Point.Dat[cc].Realiz) Then

         BEGIN
           if m^.Point.Dat[cc].DocSelector in [3,4,6,8] then
           begin
            {со СФ - в отчет для клиентов}
            if bClient then
            If TestAgent(m^.Point.Dat[cc].ClientKod,Cl) Then
            MrkClientAddToList(m^.Point.Dat[cc],TekSkl);
           end
           else
           begin
             {без СФ}
             if not bClient then
             MrkAddToList(m^.Point.Dat[cc]);
           end;
         END; {If m^.Point.Dat[cc].Active}
        End; {For cc:=1 To}
        Dispose(m,Done);
       End;{While Not(Eof(ef)) Do}
     IORez:=ioresult;
     close(fm);
     IORez:=ioresult;
     end;{if PathSklads^.Dat.Path[TekSkl]<>''}
   end;{по датам}
     NoInfoMsg;
  end;{по складам}

  Writeln(t,dOStOwIN('Выбраны следующие склады:'));
  for TekSkl:=1 to CMaxSklads do
  if AllSkl[TekSkl]=1 then
  writeln(t,DosToWin(GetClientField(FClient,IntToStr(TekSkl,CClientKod),1)));
  Writeln(t);

  if bClient then
  IF(cl<>nil) and (cl^.List^.Count>0) then
  for i:=0 to cl^.List^.Count-1 do
  begin
    s:=cl^.GetText(i,cl^.List^.Count);
    writeln(t,DosToWin('Клиент:'));
    writeln(t,DosToWin(GetClientField(FFullClient,copy(s,2,CClientKOd),0))+' ('+copy(s,2,CClientKOd)+')');
  end;


if not bClient then
begin
  writeln(t,DosToWin('Свдения об организации:'));
  writeln(t,DosToWin('Наименование'));
  writeln(t,DosToWin('ИНН'));
  writeln(t,DosToWin('КПП'));
  writeln(t,DosToWin('Юридический адрес'));
  writeln(t,DosToWin('Фактическое местонахождение, телефон'));
  writeln(t,DosToWin('Серия, номер, дата получения, срок действия лицензии, кем выдана'));
  writeln(t,DosToWin('Количество территориально-обособленных подразделений'));
  writeln(t,DosToWin('Адрес обособленного подразделения, телефон'));
  writeln(t,DosToWin('Вид деятельности'));
  writeln(t);
end;
  writeln(t,DosToWin(';ДЕКЛАРАЦИЯ'));
  writeln(t,DosToWin(';О РОЗНИЧНОЙ ПРОДАЖЕ АЛКОГОЛЬНОЙ ПРОДУКЦИИ'));
  writeln(t,DosToWin(';НА ТЕРРИТОРИИ ТУЛЬСКОЙ ОБЛАСТИ'));
  writeln(t,DosToWin(';за _______________ квартал 200____г'));
  writeln(t);
  writeln(t,DosToWin(';Раздел1. Сведения о закупке и продаже'));
  writeln(t,DosToWin(';алкогольной продукции'));

if not bClient then
begin
  writeln(t,DosToWin('Наименование видов продукции;Остаток на начало квартала;Закупки;;;;;;;;;Продажа;;;'
  +'Возврат поставщику, списание (бой, представительские расходы);Остаток на конец квартала'));
  writeln(t,DosToWin(';;всего;от производителей;;от организаций оптовой торговли;;;;всего;втом числе;;;'+
  'в стоимостном выражении, тыс. руб;;'));
  writeln(t,DosToWin(';;;Тульской области;других регионов РФ;Всего;в том числе;;;;производителей Тульской области;'
  +'производителей других регионов РФ;импортного производства'));
  writeln(t,DosToWin(';;;;;;производителей Тульской области;производителей других регионов РФ;импортного производства'));
  writeln(t,DosToWin('1;2;3;4;5;6;7;8;9;10;11;12;13;14;15;16'));
end
else
begin
{  writeln(t,DosToWin('Наименование видов продукции;Остаток на начало квартала;Закупки;'));
  writeln(t,DosToWin(';;всего;от производителей;;от организаций оптовой торговли;'));
  writeln(t,DosToWin(';;;Тульской области;других регионов РФ;Всего;в том числе;'));
  writeln(t,DosToWin(';;;;;;производителей Тульской области;производителей других регионов РФ;импортного производства;'));
  writeln(t,DosToWin('1;2;3;4;5;6;7;8;9;'));}

  writeln(t,DosToWin('Наименование видов продукции;Всего;производителей Тульской области;'
  +'производителей других регионов РФ;импортного производства;'));
end;

 {ФОРМИРОВАНИЕ ОТЧЕТА}
 sVsego:='0.0';
 sVsegoTula:='0.0';
 sVsegoNeTula:='0.0';
 sVsegoImp:='0.0';
 sKOd1:='200';
 s200:='';
 s212:='';
 s230:='';
 s211:='';
 s420:='';
 s250:='';
 s260:='';


 R.Assign(0, 0, 0, 0);
   n200 := New(PBox, Init(R, 1, Nil));
   n200^.NewList(New(PTextCollection, Init(0,1)));
 R.Assign(0, 0, 0, 0);
   n212 := New(PBox, Init(R, 1, Nil));
   n212^.NewList(New(PTextCollection, Init(0,1)));
 R.Assign(0, 0, 0, 0);
   n230 := New(PBox, Init(R, 1, Nil));
   n230^.NewList(New(PTextCollection, Init(0,1)));
 R.Assign(0, 0, 0, 0);
   n211 := New(PBox, Init(R, 1, Nil));
   n211^.NewList(New(PTextCollection, Init(0,1)));
 R.Assign(0, 0, 0, 0);
   n420 := New(PBox, Init(R, 1, Nil));
   n420^.NewList(New(PTextCollection, Init(0,1)));
 R.Assign(0, 0, 0, 0);
   n250 := New(PBox, Init(R, 1, Nil));
   n250^.NewList(New(PTextCollection, Init(0,1)));
 R.Assign(0, 0, 0, 0);
   n260 := New(PBox, Init(R, 1, Nil));
   n260^.NewList(New(PTextCollection, Init(0,1)));

 if TempBox^.List^.Count>0 then
  for i:=0 to TempBox^.List^.Count-1 do
  begin
   DInfoMsgShkala('Формирую декларацию об объемах оборота ...',0,TempBox^.List^.Count,i);
   s:= TempBox^.GetText(i,TempBox^.List^.Count);
   sKod:=copy(s,1,CArtikul);

   sAllPrh:=IntToStr(StrToInt(sAllPrh)+StrToInt(copy(s,posPrhOptTula,CIzena))+
   StrToInt(copy(s,posPrhOptNeTula,CIzena))+StrToInt(copy(s,posPrhOptImp,CIzena)),CIZena);

   sDate:=copy(s,posDate,CDate);
   sNum:=copy(s,posDoc,CDocNumer+3);
   DelSpace(sNum);
    {перевод в дал}

    MyStr(StrToReal(sAllPrh)/Dall,CIZena,8,sAllPrh);

    sLitr1:=copy(s,posOstN,CIZena);
    MyStr(StrToReal(sLitr1)/Dall,CIZena,8,sLitr1);
    System.Delete(s,posOstN,CIZena);
    System.Insert(sLitr1,s,posOstN);

    sLitr1:=copy(s,posPrhProizvTUla,CIZena);
    MyStr(StrToReal(sLitr1)/Dall,CIZena,8,sLitr1);
    System.Delete(s,posPrhProizvTUla,CIZena);
    System.Insert(sLitr1,s,posPrhProizvTUla);

    sLitr1:=copy(s,posPrhProizvNeTula,CIZena);
    MyStr(StrToReal(sLitr1)/Dall,CIZena,8,sLitr1);
    System.Delete(s,posPrhProizvNeTula,CIZena);
    System.Insert(sLitr1,s,posPrhProizvNeTula);

    sLitr1:=copy(s,posPrhOptTula,CIZena);
    MyStr(StrToReal(sLitr1)/Dall,CIZena,8,sLitr1);
    System.Delete(s,posPrhOptTula,CIZena);
    System.Insert(sLitr1,s,posPrhOptTula);

    sLitr1:=copy(s,posPrhOptNeTula,CIZena);
    MyStr(StrToReal(sLitr1)/Dall,CIZena,8,sLitr1);
    System.Delete(s,posPrhOptNeTula,CIZena);
    System.Insert(sLitr1,s,posPrhOptNeTula);

    sLitr1:=copy(s,posPrhOptImp,CIZena);
    MyStr(StrToReal(sLitr1)/Dall,CIZena,8,sLitr1);
    System.Delete(s,posPrhOptImp,CIZena);
    System.Insert(sLitr1,s,posPrhOptImp);

if not bClient then
begin
    sLitr1:=copy(s,posMrkTula,CIZena);
    MyStr(StrToReal(sLitr1)/Dall,CIZena,8,sLitr1);
    System.Delete(s,posMrkTula,CIZena);
    System.Insert(sLitr1,s,posMrkTula);

    sLitr1:=copy(s,posMrkNeTula,CIZena);
    MyStr(StrToReal(sLitr1)/Dall,CIZena,8,sLitr1);
    System.Delete(s,posMrkNeTula,CIZena);
    System.Insert(sLitr1,s,posMrkNeTula);

    sLitr1:=copy(s,posMrkEksp,CIZena);
    MyStr(StrToReal(sLitr1)/Dall,CIZena,8,sLitr1);
    System.Delete(s,posMrkEksp,CIZena);
    System.Insert(sLitr1,s,posMrkEksp);

    sLitr1:=copy(s,posVozvRew,CIZena);
    MyStr(StrToReal(sLitr1)/Dall,CIZena,8,sLitr1);
    System.Delete(s,posVozvRew,CIZena);
    System.Insert(sLitr1,s,posVozvRew);

    sLitr1:=copy(s,posOstK,CIZena);
    MyStr(StrToReal(sLitr1)/Dall,CIZena,8,sLitr1);
    System.Delete(s,posOstK,CIZena);
    System.Insert(sLitr1,s,posOstK);

    {Для БАБЛА - тыс руб}
    sLitr1:=copy(s,posMrkSumma,CIZena);
    MyStr(StrToReal(sLitr1)/1000,CIZena,2,sLitr1);
    System.Delete(s,posMrkSumma,CIZena);
    System.Insert(sLitr1,s,posMrkSumma);

    System.Insert(sAllPrh+';',s,posMrkTula);
end
else for l:=1 to 6 do system.delete(s,posMrkTula,CIZena+1);


   if bClient then
   if (StrToInt(sKOd)<>StrToInt(sKOd1)) then
   begin
    case StrToInt(sKOd1) of
     200: begin
          write(t,DosToWin('Водка'));
          s200:=sVsego;
          end;
     212: begin
          write(t,DosToWin('Ликероводочные изделия с содержанием этилового спирта свыше 25 процентов (кроме водки)'));
          s212:=sVsego;
          end;
     230: begin
          write(t,DosToWin('Коньяки, виски, бренди, джины и другие'));
          s230:=sVsego;
          end;
     211: begin
          write(t,DosToWin('Ликероводочные изделия с содержанием этилового спирта до 25 процентов включительно'));
          s211:=sVsego;
          end;
     420: begin
          write(t,DosToWin('Натуральное вино, в том числе шампанское и игристое вино'));
          s420:=sVsego;
          end;
     250: begin
          write(t,DosToWin('Напитки винные'));
          s250:=sVsego;
          end;
     260: begin
          write(t,DosToWin('Напитки слабоалкогольные (1,5 процента до 9 процентов)'));
          s260:=sVsego;
          end;
   end;
    writeln(t,DosToWin(';'+sVsego+';'+sVsegoTula+';'+sVsegoNeTula+';'+sVsegoImp));
    sVsego:='0.0';
    sVsegoTula:='0.0';
    sVsegoNeTula:='0.0';
    sVsegoImp:='0.0';

    sKOd1:=sKOd;
   end;

   MyStr(StrToReal(sVsego)+StrToReal(sAllPrh),CIZena,CMantissaZ,sVsego);
   MyStr(StrToReal(sVsegoTula)+StrToReal(copy(s,posPrhOptTula,CIZena)),CIZena,CMantissaZ,sVsegoTula);
   MyStr(StrToReal(sVsegoNeTula)+StrToReal(copy(s,posPrhOptNeTula,CIZena)),CIZena,CMantissaZ,sVsegoNeTula);
   MyStr(StrToReal(sVsegoImp)+StrToReal(copy(s,posPrhOptImp,CIZena)),CIZena,CMantissaZ,sVsegoImp);


    System.Insert(sAllPrh+';',s,posPrhOptTula);
    System.Insert(sAllPrh+';',s,posPrhProizvTUla);

    while Pos('│', S) > 0 do   S[Pos('│', S)] := ';';

    System.Delete(s,1,CArtikul);

  if not bClient then
  begin
   case StrToInt(sKOd) of
     200: write(t,DosToWin('Водка'));
     212: write(t,DosToWin('Ликероводочные изделия с содержанием этилового спирта свыше 25 процентов (кроме водки)'));
     230: write(t,DosToWin('Коньяки, виски, бренди, джины и другие'));
     211: write(t,DosToWin('Ликероводочные изделия с содержанием этилового спирта до 25 процентов включительно'));
     420: write(t,DosToWin('Натуральное вино, в том числе шампанское и игристое вино'));
     250: write(t,DosToWin('Напитки винные'));
     260: write(t,DosToWin('Напитки слабоалкогольные (1,5 процента до 9 процентов)'));
   end;

   writeln(t,DosToWin(s));
  end;

   {Запоминаем номера накладных}
    case StrToInt(sKOd) of
     200: begin
           n200^.List^.Insert(NewStr(sNum+' от '+sDate+','));
           n200^.SetRange(n200^.List^.Count);
          end;
     212: begin
           n212^.List^.Insert(NewStr(sNum+' от '+sDate+','));
           n212^.SetRange(n212^.List^.Count);
          end;
     230: begin
           n230^.List^.Insert(NewStr(sNum+' от '+sDate+','));
           n230^.SetRange(n230^.List^.Count);
          end;
     211: begin
           n211^.List^.Insert(NewStr(sNum+' от '+sDate+','));
           n211^.SetRange(n211^.List^.Count);
          end;
     420: begin
           n420^.List^.Insert(NewStr(sNum+' от '+sDate+','));
           n420^.SetRange(n420^.List^.Count);
          end;
     250: begin
            n250^.List^.Insert(NewStr(sNum+' от '+sDate+','));
            n250^.SetRange(n250^.List^.Count);
          end;
     260: begin
            n260^.List^.Insert(NewStr(sNum+' от '+sDate+','));
            n260^.SetRange(n200^.List^.Count);
          end;
    end;

   if bClient then
   if (i=TempBox^.List^.Count-1) then
   begin
    case StrToInt(sKOd) of
     200: begin
          write(t,DosToWin('Водка'));
          s200:=sVsego;
          end;
     212: begin
          write(t,DosToWin('Ликероводочные изделия с содержанием этилового спирта свыше 25 процентов (кроме водки)'));
          s212:=sVsego;
          end;
     230: begin
          write(t,DosToWin('Коньяки, виски, бренди, джины и другие'));
          s230:=sVsego;
          end;
     211: begin
          write(t,DosToWin('Ликероводочные изделия с содержанием этилового спирта до 25 процентов включительно'));
          s211:=sVsego;
          end;
     420: begin
          write(t,DosToWin('Натуральное вино, в том числе шампанское и игристое вино'));
          s420:=sVsego;
          end;
     250: begin
          write(t,DosToWin('Напитки винные'));
          s250:=sVsego;
          end;
     260: begin
          write(t,DosToWin('Напитки слабоалкогольные (1,5 процента до 9 процентов)'));
          s260:=sVsego;
          end;
     else write(t,sKOd);
    end;

    writeln(t,DosToWin(';'+sVsego+';'+sVsegoTula+';'+sVsegoNeTula+';'+sVsegoImp));
   end;

  end;

  writeln(t);
  writeln(t);
  writeln(t);
  writeln(t);
  writeln(t,DosToWin(';Раздел 2. Сведения о поставщиках алкогольной продукции '));
  writeln(t);
  if not bClient then
  begin
  writeln(t,DosToWin('Наименование алкогольной продукции;Объем закупленной продукции в дал;;'
  +'Поставщик, его адрес,объем поставленной продукции в дал;Номера товарно-транспортных накладных, дата отгрузки'));
  writeln(t,DosToWin(';За отчетный квартал;С начала года'));
  writeln(t,DosToWin('1;2;3;4;5'));
  end
  else
  begin
    writeln(t,DosToWin('Наименование алкогольной продукции;Объем закупленной продукции в дал;'
  +'Поставщик, его адрес,объем поставленной продукции в дал;Номера товарно-транспортных накладных, дата отгрузки'));
  end;

     if s200<>'' then
      begin
       write(t,DosToWin('Водка'));
       Print2(s200,n200);
      end;
     if s212<>'' then
      begin
       write(t,DosToWin('Ликероводочные изделия с содержанием этилового спирта свыше 25 процентов (кроме водки)'));
       Print2(s212,n212);
      end;
     if s230<>'' then
      begin
       write(t,DosToWin('Коньяки, виски, бренди, джины и другие'));
       Print2(s230,n230);
      end;
     if s211<>'' then
      begin
       write(t,DosToWin('Ликероводочные изделия с содержанием этилового спирта до 25 процентов включительно'));
       Print2(s211,n211);
      end;
     if s420<>'' then
      begin
       write(t,DosToWin('Натуральное вино, в том числе шампанское и игристое вино'));
       Print2(s420,n420);
      end;
     if s250<>'' then
      begin
       write(t,DosToWin('Напитки винные'));
       Print2(s250,n250);
      end;
     if s260<>'' then
      begin
       write(t,DosToWin('Напитки слабоалкогольные (1,5 процента до 9 процентов)'));
       Print2(s260,n260);
      end;


  writeln(t);
  writeln(t);

  writeln(t,DosToWin(';;;Руководитель организации'));
  writeln(t,DosToWin(';МП;;Главный бухгалтер'));
(*  if ErrorBox^.List^.Count>0 then
  begin
    writeln(t);
    writeln(t,DosToWin(';ВНИМАНИЕ!'));
    for i:=0 to ErrorBox^.List^.Count-1 do
      begin
        s:=ErrorBox^.GetTExt(i,ErrorBox^.List^.Count);
        writeln(t,';'+DosToWin(s));
      end;
  end;    *)


  {if bClient then Dispose(Cl,Done);}
    Dispose(n200,Done);
    Dispose(n212,Done);
    Dispose(n230,Done);
    Dispose(n211,Done);
    Dispose(n420,Done);
    Dispose(n250,Done);
    Dispose(n260,Done);

  Dispose(ErrorBox,Done);
  Dispose(TempBox,Done);

  NoinfoMsg;
  System.close(t);

  Sound(100);
  DInfoMsg('Данные импортированы в '+Path^.Dat.ToTemp+'tuladecl.csv',False);
  NoSound;
  Application^.ClearEvent(Event);
  Application^.GetEvent(Event);
  Application^.ClearEvent(Event);
  repeat
  Application^.GetEvent(Event);
  until (Event.What <> evNothing) And (Event.Command<>cmMenu);
  NoInfoMsg;
  Application^.ClearEvent(Event);

End;


BEGIN
END.