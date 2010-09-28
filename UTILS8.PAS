{$I Compile.INC}

{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}
Unit Utils8;

Interface

Uses Dialogs,Glob,CorMrk,ColorTxt,ServStr,Drivers,
     Views,MyCalc,LockInfo,FindPrh,Utils10,Utils1,TrNakl;


Type
  PFullScreenTrans = ^TFullScreenTrans;
  TFullScreenTrans = object(TDialog)
      Calc        : PMyCalculator;
      FP         : PFindPrh;
      Numer      : ArtikulStr;
      Date       : TDateString;
      Function FullScreenTrans(Ass:DocumentEditZ):Boolean;
      procedure HandleEvent(var Event: TEvent); virtual;
      Destructor Done;Virtual;
  end;




Type
  PFullScreenRwz = ^TFullScreenRwz;
  TFullScreenRwz = object(TDialog)
      Calc        : PMyCalculator;
      FP         : PFindPrh;
      Numer      : ArtikulStr;
      Date       : TDateString;
      Function FullScreenRwz(Ass:DocumentEditZ):Boolean;
      Procedure DrawCurrent;
      Procedure Refresh;
      procedure HandleEvent(var Event: TEvent); virtual;
      Destructor Done;Virtual;
  end;



Type
  PFullScreenPrz = ^TFullScreenPrz;
  TFullScreenPrz = object(TDialog)
      Calc       : PMyCalculator;
      VRet       : PFullScreenVzw;
      FP         : PFindPrh;
      Numer      : ArtikulStr;
      Date       : TDateString;
      DocWith    : String[CDocNumer];
      DateWith   : String[CDate];
      Function FullScreenPrz(Ass:DocumentEditZ):Boolean;
      procedure HandleEvent(var Event: TEvent); virtual;
      Destructor Done;Virtual;
  end;


Type
  PLinkNGTDWindow = ^TLinkNGTDWindow;
  TLinkNGTDWindow = object(TDialog)
         Calc    : PMyCalculator;
         Lnk : PLinkWindow;
         FP  : PFindPrh;
         procedure Start(LinkArt:ArtikulStr);
         procedure FormReport;
         procedure Refresh;
         procedure DrawCurrent;
         procedure HandleEvent(var Event: TEvent); virtual;
         Destructor Done;Virtual;
  end;



Type
  PLinkSpecMarkaWindow = ^TLinkSpecMarkaWindow;
  TLinkSpecMarkaWindow = object(TDialog)
         Calc    : PMyCalculator;
         Lnk : PLinkWindow;
         FP  : PFindPrh;
         procedure Start(LinkArt:ArtikulStr);
         procedure FormReport;
         procedure Refresh;
         procedure DrawCurrent;
         procedure HandleEvent(var Event: TEvent); virtual;
         Destructor Done;Virtual;
  end;



Procedure CalcNewToDaymarket(TDate:TDateString;
                             Var RashetList,RashetList2,MrkListDiv:PBox);

Procedure CalcNewTodayMarketClientBarter(TDate:TDateString;
          Var RashetList,RashetListClient
		,RashetListBarter:PBox);


Procedure CalcNewTodayPrihod(TDate:TDateString;
          Var RashetList,RashetList2:PBox);


Function FindSertifikat(LinkArt:ArtikulStr;SArt:ArtikulStr;Var SertifCod:ArtikulStr):Boolean;
Procedure ReCalcAkzis(SArt : ArtikulStr;Var SAkzis : AllStr);
Procedure SelectDeActivDocument;


implementation

Uses App,Objects,Serv,ServStr2,DbEngine,Utils,Vision2,Vision10,netDbEng,
     Validate,net,Utils5,
     dbEngin2,dbEngin3,TpDate,Printers,MsgBox;

Var NoScreenList1 : PBox;
    ViewList : PBoxNew;
    ViewListS: PBoxNew;
    MrkWin : PFullScreenTrans;
    PzWin  : PFullScreenPredZakaz;
    PrzWin : PFullScreenPrz;
    RwzWin : PFullScreenRwz;

    Control,ControlG : PView;
    Filtr : Word;

    LArt : ArtikulStr;
    LinkNGTDWindow : PLinkNGTDWindow;
    LinkSpecMarkaWindow : PLinkSpecMarkaWindow;
    LinkList: PBox;
    ControlInfo,ControlCount,ControlSelector,ControlVidOtboraG,ControlGroup,
    ControlOtd,ControlOtbor,ControlPosition,ControlConfirmation,ControlComment1,
    ControlComment2,ControlDateOtpr,ControlStatus,ControlDateEnd,
    ControlDoc,ControlDateC,ControlDateM,ControlOperator,
    ControlFiltr,ControlItog,ControlOtdel,ControlAmount,ControlSum,
    ControlVidOtbora : PView;
    VidOtbora,VidProsmotra,Otobragenie : Word;
    ControlHeader,ControlOtobragenie : PView;
    ControlNGTD,ControlKSertif,
    ControlMarka,ControlVirabotano,ControlDo,
    ControlFullNAme,ControlMsg,ControlR,ControlRz,ControlText,ControlCl : PView;
    CurrentLine : String;
    VidSkidki : AllStr;
    Otd,ReturnCount : Word;

    MMM2 : Maska2;
    MMM8 : Maska8;



Function TFullScreenTrans.FullScreenTrans(Ass:DocumentEditZ):Boolean;
var
  R : TRect;
  ws,s,s1,St,s2 : String;
  AgName,ClName : AllStr;
  c,i : Word;
  ff,ff1,ff2 : String;
  E :PTransportType;
  Find:Boolean;
  SDate : TDateString;
  ws1,WspomSkidka:String[CIZena];
  Res : Word;
  DDD3,DDD4,DDD,DDD2,Status : AllStr;
  Color : Word;
  AssZ:DocumentEditZ;
  BArter : AllStr;

begin
  FullScreenTrans:=False;
  Find := False;
  DInfoMsg('Ищу документ...',True);
  New(E,Init);
  ClearChar(Ass.EditPosition);
  DelSpace(Ass.D);
  Find:=GetTransport(Ass,E);
  NoInfoMsg;



If Not Find Then
  Begin
   Dispose(E,Done);
   NoInfoMsg;
   Exit;
  End;


DInfoMsg('Формирую документы...',True);
ClearFind;


R.Assign(0, 0, 80, 23);
New(MrkWin, Init(R, 'Просмотр перемещения'));
MrkWin^.HelpCtx:={E091}{E556}$F916{F222};

MrkWin^.Numer:=Ass.EditPosition;
MrkWin^.Date:=Ass.D;

R.Assign(79, 3, 80, 22);
Control := New(PScrollBar, Init(R));
MrkWin^.Insert(Control);


R.Assign(75, 22, 78, 23);
ControlG := New(PScrollBar, Init(R));
ControlG^.Options := ControlG^.Options or ofPostProcess;
MrkWin^.Insert(ControlG);


R.Assign(1, 3, 79, 22);
ViewList := New(PBoxNew, Init(R, 1,
PScrollBar(ControlG), PScrollBar(Control)));
ViewList^.NewList(New(PTextCollection, Init(0,1)));

{вставляем в список товары}
For c:=1 To E^.Dat.Amount Do
 Begin
  S:=E^.Dat.TransportElement[c].BazKod;
  ws:=GetIdField(FFFName,s);
  Format(ws,CName+CName);
  s:=ws+'│'+s;

  MyStr(StrToReal(E^.Dat.TransPortElement[c].Input.Zena),CZena,CMantissa,E^.Dat.TransPortElement[c].Input.Zena);
  If Not (EnableZakupka=1)  Then
  E^.Dat.TransPortElement[c].Input.Zakupka:=CodeZakupka
  Else
  MyStr(StrToReal(E^.Dat.TransPortElement[c].Input.Zakupka),CZenaZ,CMantissaZ,E^.Dat.TransPortElement[c].Input.Zakupka);

  DelSpace(E^.Dat.TransportElement[c].Input.Kol);
  RFormat(E^.Dat.TransportElement[c].Input.Kol,CKol);
  s:=s+'│'+E^.Dat.TransportElement[c].Input.Kol+'│'+
  E^.Dat.TransPortElement[c].Input.Zena+'│'+
  E^.Dat.TransPortElement[c].Input.Zakupka;

  ViewList^.List^.Insert(NewStr(s));
  ViewList^.SetRange(ViewList^.List^.Count);
 End;

ViewList^.FocusItem(0);

MrkWin^.Insert(ViewList);

  R.Assign(1, 2, 76, 3);
  MrkWin^.Insert(New(PLabel, Init(R, 'Наименование товара                                  Код   Колич  Р/Цена  ', ViewList)));


R.Assign(1, 0, 28, 1);
Control := New(PColoredText, Init(R, 'Документ:'+E^.Dat.Document+' от '+E^.Dat.DateC, $4E));
MrkWin^.Insert(Control);

R.Assign(67, 0, 79, 1);
Control := New(PColoredText, Init(R, 'Позиций:'+IntToStr(E^.DAt.Amount,CMAntissa), $4E));
MrkWin^.Insert(Control);

MyStr(StrToReal(E^.DAt.SummaZ),CIZena,CMAntissa,E^.DAt.SummaZ);
DelSpace(E^.DAt.SummaZ);
MyStr(StrToReal(E^.DAt.SummaZakupka),CIZena,CMAntissaZ,E^.DAt.SummaZakupka);
DelSpace(E^.DAt.SummaZakupka);
If Not(EnableZakupka=1) Then
  E^.Dat.SummaZakupka:=CodeSummaZ;

s:=#3+'Всего по Р/Ценам:'+E^.DAt.SummaZ+' по '+
     'З/Ценам:'+E^.DAt.SummaZakupka;
R.Assign(2, 22, 2+Length(s)+1, 23);
Control := New(PColoredText, Init(R, s, $4E));
Control^.Options := Control^.Options or ofCenterX;
MrkWin^.Insert(Control);

R.Assign(12, 1, 31, 2);
s:=Rek^.DAt.Otdel[E^.DAt.MakeOtdelenie];
Format(s,CIZena);
Control := New(PColoredText, Init(R, #3+s+'│'+IntToStr(E^.DAt.MakeOtdelenie,COne), $1F));
MrkWin^.Insert(Control);

R.Assign(2, 1, 12, 2);
Control := New(PStaticText, Init(R, 'Поставщик:'));
MrkWin^.Insert(Control);

R.Assign(32, 1, 43, 2);
Control := New(PStaticText, Init(R, 'Получатель:'));
MrkWin^.Insert(Control);

R.Assign(43, 1, 62, 2);
s:=Rek^.DAt.Otdel[E^.DAt.ClientOtdelenie];
Format(s,CIZena);
Control := New(PColoredText, Init(R, #3+s+'│'+IntToStr(E^.DAt.ClientOtdelenie,COne), $1F));
MrkWin^.Insert(Control);

R.Assign(63, 1, 79, 2);
Control := New(PColoredText, Init(R, #3+GetOperatorField(FName,E^.Dat.Caption)+'('+E^.Dat.Caption+')', $4E));
MrkWin^.Insert(Control);

Dispose(E,Done);

NoInfoMsg;

i := Desktop^.ExecView(MrkWin);

Dispose(Control,Done);
Dispose(ControlG,Done);
Dispose(ViewList,Done);
Dispose(MrkWin,Done);

end;




procedure TFullScreenTrans.HandleEvent(var Event: TEvent);

procedure Calculator;
begin
  Calc^.Start;
end;

Var s : String;
    Prom : Word;
    Assistent : DocumentEditZ;
    Sn : ArtikulStr;
Begin

Case Event.What Of
 evCommand :
   Case Event.Command Of
  cmLocalCalc:Calculator;

cmViewPrihodTovar
     :Begin
if (ViewList^.State and sfFocused <> 0) And(ViewList^.List<>Nil) And (ViewList^.List^.Count>=1)Then
      If (ViewList^.List^.Count-1)>=0 Then
       begin
        Sn:=Copy(ViewList^.GEtTExt(ViewList^.Focused,ViewList^.List^.Count),1+CName+CName+1,CArtikul);
        FP^.FindScreenPrh(SN);
        ClearEvent(Event);
       End;
      End;

  cmPrintReestr:    Begin
                ClearFind;
                Assistent.EditPosition:=Numer;
                DelSpace(Assistent.EditPosition);
                DelZerro(Assistent.EditPosition);
                Assistent.D:=Date;
                DelSpace(Assistent.D);
                PrintTransPort(Assistent);
                    End;
        Else;
        End;
 Else;
 End;

inherited HandleEvent(Event);
End;


Destructor TFullScreenTrans.Done;
Begin
TDialog.Done;
End;





Function TFullScreenRwz.FullScreenRwz(Ass:DocumentEditZ):Boolean;
var
  R : TRect;
  ws,s,s1,St,s2 : String;
  AgName,ClName : AllStr;
  c,i : Word;
  ff,ff1,ff2 : String;
  E :PRewisiaType;
  Find:Boolean;
  SDate : TDateString;
  ws1,WspomSkidka:String[CIZena];
  Res : Word;
  DDD3,DDD4,DDD,DDD2,Status : AllStr;
  Color : Word;
  AssZ:DocumentEditZ;
  BArter : AllStr;
  add : Boolean;
begin
  FullScreenRwz:=False;
  Find := False;
  DInfoMsg('Ищу документ...',True);
  New(E,Init);
  ClearChar(Ass.EditPosition);
  DelSpace(Ass.D);
  Find:=GetRewisia(Ass,E);
  NoInfoMsg;

If Not Find Then
  Begin
   Dispose(E,Done);
   NoInfoMsg;
   Exit;
  End;


DInfoMsg('Формирую документы...',True);
ClearFind;


R.Assign(1, 0, 79, 23);
New(RwzWin, Init(R, 'Просмотр ревизии'));
RwzWin^.HelpCtx:={E091}{E556}$F916{F222};

RwzWin^.Numer:=Ass.EditPosition;
RwzWin^.Date:=Ass.D;

R.Assign(77, 4, 78, 19);
Control := New(PScrollBar, Init(R));
RwzWin^.Insert(Control);


R.Assign(75, 22, 78, 23);
ControlG := New(PScrollBar, Init(R));
ControlG^.Options := ControlG^.Options or ofPostProcess;
RwzWin^.Insert(ControlG);


R.Assign(1, 4, 77, 19);
ViewList := New(PBoxNew, Init(R, 1,
PScrollBar(ControlG), PScrollBar(Control)));
ViewList^.NewList(New(PTextCollection, Init(0,1)));
E^.DAt.Itogo[0]:=#0;
E^.DAt.ItogoZ[0]:=#0;
Filtr:=3;
Otd:=255;
WordToBit2(Filtr,MMM2);
Convert2(MMM2);

WordToBit8(Otd,MMM8);
Convert8(MMM8);
For c:=1 To E^.Dat.Amount Do
 Begin
  S:=E^.Dat.Element[c].BazKod;
  ws:=GetIdField(FFFName,s);
  Format(ws,CName+1+CName);
  s:=ws+'│'+s;

  MyStr(StrToReal(E^.Dat.Element[c].Input.R_Zena),CZena,CMantissa,E^.Dat.Element[c].Input.R_Zena);

  If Not(EnableZakupka=1)  Then
  E^.Dat.Element[c].Input.Zakupka:=CodeZakupka
  Else
  MyStr(StrToReal(E^.Dat.Element[c].Input.Zakupka),CZenaZ,CMantissaZ,E^.Dat.Element[c].Input.Zakupka);

  E^.Dat.Element[c].Input.Kol[0]:=#0;
  Add:=False;
  For i:=1 To CDivision Do
   Begin

    If MMM8[i]=0 Then E^.Dat.Element[c].Input.Division[i,0]:=#0;

    If MMM2[1]=0 Then
    If StrToInt(E^.Dat.Element[c].Input.Division[i])>0 Then E^.Dat.Element[c].Input.Division[i,0]:=#0;

    If MMM2[2]=0 Then
    If StrToInt(E^.Dat.Element[c].Input.Division[i])<0 Then E^.Dat.Element[c].Input.Division[i,0]:=#0;

    E^.Dat.Element[c].Input.Division[i]:=IntToStr(StrToInt(E^.Dat.Element[c].Input.Division[i]),CKol+1);
    RFormat(E^.Dat.Element[c].Input.Division[i],CKol+1);

    E^.Dat.Element[c].Input.Kol:=IntToStr(
    StrToInt(E^.Dat.Element[c].Input.Kol)+
    StrToInt(E^.Dat.Element[c].Input.Division[i]),CKol+1);

    If StrToInt(E^.Dat.Element[c].Input.Division[i])<>0 Then Add:=True;
   End;{For i}

  If Add Then{т.е есть не нулевая позиция}
Begin
  RFormat(E^.Dat.Element[c].Input.Kol,CKol+1);
  s:=s+'│'+E^.Dat.Element[c].Input.Kol+'│'+
  E^.Dat.Element[c].Input.R_Zena+'│'+
  E^.Dat.Element[c].Input.Zakupka+'│';

  For i:=1 To CDivision Do
   Begin
    s:=s+E^.Dat.Element[c].Input.Division[i]+'│';
   End;

  MyStr(StrToReal(E^.Dat.Itogo)+
  StrToInt(E^.Dat.Element[c].Input.Kol)*
  StrToReal(E^.Dat.Element[c].Input.R_Zena),CIZena,CMAntissa,E^.Dat.Itogo);
  DelSpace(E^.DAt.Itogo);

  MyStr(StrToReal(E^.Dat.ItogoZ)+
  StrToInt(E^.Dat.Element[c].Input.Kol)*
  StrToReal(E^.Dat.Element[c].Input.Zakupka),CIZena,CMAntissaZ,E^.Dat.ItogoZ);
  DelSpace(E^.DAt.ItogoZ);

  ViewList^.List^.Insert(NewStr(s));
  ViewList^.SetRange(ViewList^.List^.Count);
End;

 End;



ViewList^.FocusItem(0);

RwzWin^.Insert(ViewList);

  R.Assign(1, 3, 76, 4);
  RwzWin^.Insert(New(PLabel, Init(R, 'Наименование товара                                    Код  Колич     Цена', ViewList)));


R.Assign(1, 0, 27, 1);
Control := New(PColoredText, Init(R, 'Документ:'+E^.Dat.Document+' от '+E^.Dat.DateC, $4E));
RwzWin^.Insert(Control);

R.Assign(59, 0, 77, 1);
ControlAmount := New(PColoredText, Init(R, 'Позиций:'+IntToStr(ViewList^.List^.Count,CMAntissa)+' из '+
IntToStr(E^.Dat.Amount,CMantissa), $4E));
RwzWin^.Insert(ControlAmount);

MyStr(StrToReal(E^.DAt.Itogo),CIZena,CMAntissa,E^.DAt.Itogo);
DelSpace(E^.DAt.Itogo);
MyStr(StrToReal(E^.DAt.ItogoZ),CIZena,CMAntissaZ,E^.DAt.ItogoZ);
DelSpace(E^.DAt.ItogoZ);

If Not(EnableZakupka=1) Then
  E^.Dat.ItogoZ:=CodeSummaZ;

s:=#3+'Всего по РЦ:'+E^.DAt.Itogo+' по '+
     'ЗЦ:'+E^.DAt.ItogoZ;

R.Assign(2, 22, 2+Length(s)+1, 23);
ControlItog := New(PColoredText, Init(R, s, $4E));
ControlItog^.Options := ControlItog^.Options or ofCenterX;
RwzWin^.Insert(ControlItog);

R.Assign(59, 1, 77, 2);
Control := New(PColoredText, Init(R, #3+GetOperatorField(FName,E^.Dat.Caption)+'('+E^.Dat.Caption+')', $4E));
RwzWin^.Insert(Control);

R.Assign(2, 19, 16, 20);
Control := New(PColoredText, Init(R, 'По отделениям:', $71));
RwzWin^.Insert(Control);

R.Assign(2, 20, 75, 21);
ControlOtdel := New(PColoredText, Init(R, #3+'', $71));
RwzWin^.Insert(ControlOtdel);

R.Assign(2, 21, 14, 22);
Control := New(PColoredText, Init(R, 'Комментарий:', $71));
RwzWin^.Insert(Control);

R.Assign(14, 21, 59, 22);
Control := New(PColoredText, Init(R, E^.Dat.Comment, $7E));
RwzWin^.Insert(Control);


R.Assign(1, 1, 22, 3);
ControlFiltr := New(PCheckboxes, Init(R,
  NewSItem('~П~риходная часть',
  NewSItem('~Р~асходная часть', Nil))));
RwzWin^.Insert(ControlFiltr);

ControlFiltr^.SetData(Filtr);

R.Assign(23, 1, 51, 3);
ControlOtd := New(PCheckboxes, Init(R,
  NewSItem('~1~',
  NewSItem('~2~',
  NewSItem('~3~',
  NewSItem('~4~',
  NewSItem('~5~',
  NewSItem('~6~',
  NewSItem('~7~',
  NewSItem('~8~', Nil))))))))));
RwzWin^.Insert(ControlOtd);
ControlOtd^.SetData(Otd);




Dispose(E,Done);

NoInfoMsg;
CurrentLine[0]:=#0;
DrawCurrent;
RwzWin^.SelectNext(False);
RwzWin^.SelectNext(False);
i := Desktop^.ExecView(RwzWin);

Dispose(Control,Done);
Dispose(ControlG,Done);
Dispose(ControlItog,Done);
Dispose(ControlOtd,Done);
Dispose(ControlAmount,Done);
Dispose(ControlOtdel,Done);
Dispose(ControlFiltr,Done);
Dispose(ViewList,Done);
Dispose(RwzWin,Done);

end;




procedure TFullScreenRwz.HandleEvent(var Event: TEvent);

procedure Calculator;
begin
  Calc^.Start;
end;

Var s : String;
    Prom : Word;
    Assistent : DocumentEditZ;
    Sn : ArtikulStr;
Begin

Case Event.What Of
 evCommand :
   Case Event.Command Of
  cmLocalCalc:Calculator;

cmViewPrihodTovar
     :Begin
if (ViewList^.State and sfFocused <> 0) And(ViewList^.List<>Nil) And (ViewList^.List^.Count>=1)Then
      If (ViewList^.List^.Count-1)>=0 Then
       begin
        Sn:=Copy(ViewList^.GEtTExt(ViewList^.Focused,ViewList^.List^.Count),1+CName+1+CName+1,CArtikul);
        FP^.FindScreenPrh(SN);
        ClearEvent(Event);
       End;
      End;

  cmPrintReestr:    Begin
                ClearFind;
                Assistent.EditPosition:=Numer;
                DelSpace(Assistent.EditPosition);
                DelZerro(Assistent.EditPosition);
                Assistent.D:=Date;
                DelSpace(Assistent.D);
                PrintRewisia(Assistent);
                    End;
        Else;
        End;
 Else;
 End;

  If (Desktop^.Current=PView(RwzWin)) And (Event.What <> EvKeyDown) Then
   Begin

          if (ControlFiltr^.State and sfFocused <> 0)Then
              Begin
               ControlFiltr^.GetData(Prom);
               If Prom <> Filtr Then
               Begin
                  Filtr:=Prom;
                  Refresh;
                  Redraw;
               End;
              End;

          if (ControlOtd^.State and sfFocused <> 0)Then
              Begin
               ControlOtd^.GetData(Prom);
               If Prom <> Otd Then
               Begin
                  Otd:=Prom;
                  Refresh;
                  Redraw;
               End;
              End;

    DrawCurrent;


   End;


inherited HandleEvent(Event);
End;


Destructor TFullScreenRwz.Done;
Begin
TDialog.Done;
End;


Procedure TFullScreenRwz.DrawCurrent;
Var st,s,s2 : String;
    R : TRect;
    c : Word;
Begin
if (ViewList^.List<>Nil)And(ViewList^.List^.Count>=1) Then
 Begin
  st:=ViewList^.GetText(ViewList^.Focused,ViewList^.List^.Count);
  If st <> CurrentLine Then
    Begin
      CurrentLine:=St;
      Dispose(ControlOtdel,Done);
      s2[0]:=#0;
      R.Assign(2, 20, 75, 21);
      For c:=1 To CDivision Do
       Begin
       s:=Copy(st,1+CNAme+1+CNAme+1+CArtikul+1+(CKol+1)+1+CZena+1+CZenaZ+1+(c-1)*(CKol+1+1),CKol+1);
       s2:=s2+IntToStr(c,COne)+':'+s+' ';
       End;
      ControlOtdel := New(PColoredText, Init(R, #3+s2, $71));
      RwzWin^.Insert(ControlOtdel);

    End;
 End
End;


Procedure TFullScreenRwz.Refresh;
Var e : PRewisiaType;
    Ass : DocumentEditZ;
    Add,Find : Boolean;
    s,ws : String;
    i,c : Word;
    R : TRect;
Begin
  DInfoMsg('Минуточку...',False);
  New(E,Init);
  Ass.EditPosition:=RwzWin^.Numer;
  Ass.D:=RwzWin^.Date;
  ClearChar(Ass.EditPosition);
  DelSpace(Ass.D);
  Find:=GetRewisia(Ass,E);

If Not Find Then
  Begin
   Dispose(E,Done);
   NoInfoMsg;
   Exit;
  End;

ViewList^.NewList(Nil);
ViewList^.NewList(New(PTextCollection, Init(0,1)));

E^.DAt.Itogo[0]:=#0;
E^.DAt.ItogoZ[0]:=#0;

WordToBit2(Filtr,MMM2);
Convert2(MMM2);

WordToBit8(Otd,MMM8);
Convert8(MMM8);

For c:=1 To E^.Dat.Amount Do
 Begin
  S:=E^.Dat.Element[c].BazKod;
  ws:=GetIdField(FFFName,s);
  Format(ws,CName+1+CName);
  s:=ws+'│'+s;

  MyStr(StrToReal(E^.Dat.Element[c].Input.R_Zena),CZena,CMantissa,E^.Dat.Element[c].Input.R_Zena);

  If Not(EnableZakupka=1)  Then
  E^.Dat.Element[c].Input.Zakupka:=CodeZakupka
  Else
  MyStr(StrToReal(E^.Dat.Element[c].Input.Zakupka),CZenaZ,CMantissaZ,E^.Dat.Element[c].Input.Zakupka);

  E^.Dat.Element[c].Input.Kol[0]:=#0;
  Add:=False;
  For i:=1 To CDivision Do
   Begin
    If MMM8[i]=0 Then E^.Dat.Element[c].Input.Division[i,0]:=#0;
    If MMM2[1]=0 Then
    If StrToInt(E^.Dat.Element[c].Input.Division[i])>0 Then E^.Dat.Element[c].Input.Division[i,0]:=#0;

    If MMM2[2]=0 Then
    If StrToInt(E^.Dat.Element[c].Input.Division[i])<0 Then E^.Dat.Element[c].Input.Division[i,0]:=#0;

    E^.Dat.Element[c].Input.Division[i]:=IntToStr(StrToInt(E^.Dat.Element[c].Input.Division[i]),CKol+1);
    RFormat(E^.Dat.Element[c].Input.Division[i],CKol+1);

    E^.Dat.Element[c].Input.Kol:=IntToStr(
    StrToInt(E^.Dat.Element[c].Input.Kol)+
    StrToInt(E^.Dat.Element[c].Input.Division[i]),CKol+1);

    If StrToInt(E^.Dat.Element[c].Input.Division[i])<>0 Then Add:=True;
   End;{For i}


  If Add Then{т.е есть не нулевая позиция}
Begin
  RFormat(E^.Dat.Element[c].Input.Kol,CKol+1);
  s:=s+'│'+E^.Dat.Element[c].Input.Kol+'│'+
  E^.Dat.Element[c].Input.R_Zena+'│'+
  E^.Dat.Element[c].Input.Zakupka+'│';

  For i:=1 To CDivision Do
   Begin
    s:=s+E^.Dat.Element[c].Input.Division[i]+'│';
   End;

  MyStr(StrToReal(E^.Dat.Itogo)+
  StrToInt(E^.Dat.Element[c].Input.Kol)*
  StrToReal(E^.Dat.Element[c].Input.R_Zena),CIZena,CMAntissa,E^.Dat.Itogo);
  DelSpace(E^.DAt.Itogo);

  MyStr(StrToReal(E^.Dat.ItogoZ)+
  StrToInt(E^.Dat.Element[c].Input.Kol)*
  StrToReal(E^.Dat.Element[c].Input.Zakupka),CIZena,CMAntissaZ,E^.Dat.ItogoZ);
  DelSpace(E^.DAt.ItogoZ);

  ViewList^.List^.Insert(NewStr(s));
  ViewList^.SetRange(ViewList^.List^.Count);
End;

 End;

ViewList^.FocusItem(0);

Dispose(ControlAmount,Done);
R.Assign(59, 0, 77, 1);
ControlAmount := New(PColoredText, Init(R, 'Позиций:'+IntToStr(ViewList^.List^.Count,CMAntissa)+' из '+
IntToStr(E^.Dat.Amount,CMantissa), $4E));
RwzWin^.Insert(ControlAmount);

MyStr(StrToReal(E^.DAt.Itogo),CIZena,CMAntissa,E^.DAt.Itogo);
DelSpace(E^.DAt.Itogo);
MyStr(StrToReal(E^.DAt.ItogoZ),CIZena,CMAntissaZ,E^.DAt.ItogoZ);
DelSpace(E^.DAt.ItogoZ);

If Not(EnableZakupka=1) Then
  E^.Dat.ItogoZ:=CodeSummaZ;

Dispose(ControlItog,Done);
s:=#3+'Всего по Р/Ценам:'+E^.DAt.Itogo+' по '+
     'З/Ценам:'+E^.DAt.ItogoZ;
R.Assign(2, 22, 2+Length(s)+1, 23);
ControlItog := New(PColoredText, Init(R, s, $4E));
ControlItog^.Options := ControlItog^.Options or ofCenterX;
RwzWin^.Insert(ControlItog);

Redraw;

Dispose(E,Done);
NoInfoMsg;
CurrentLine[0]:=#0;

End;






Function TFullScreenPrz.FullScreenPrz(Ass:DocumentEditZ):Boolean;
var
  R : TRect;
  ws,s,s1,St,s2 : String;
  AgName,ClName : AllStr;
  c,i : Word;
  ff,ff1,ff2 : String;
  E :PPereozenkaType;
  Find:Boolean;
  SDate : TDateString;
  ws1,WspomSkidka:String[CIZena];
  Res : Word;
  DDD3,DDD4,DDD,DDD2,Status : AllStr;
  Color : Word;
  Msg : String;
  AssZ:DocumentEditZ;
  Proz: AllStr;
  BArter : AllStr;

begin
  FullScreenPrz:=False;
  Find := False;
  DInfoMsg('Ищу документ...',True);
  New(E,Init);
  ClearChar(Ass.EditPosition);
  DelSpace(Ass.D);
  Find:=GetPereozenka(Ass,E);
  NoInfoMsg;

If Not Find Then
  Begin
   Dispose(E,Done);
   NoInfoMsg;
   Exit;
  End;

DInfoMsg('Формирую документы...',True);
ClearFind;

R.Assign(0, 0, 80, 23);
New(PrzWin, Init(R, 'Просмотр переоценки'));
PrzWin^.HelpCtx:={E091}{E556}$F916{F222};
If E^.Dat.Vid=1 Then PrzWin^.HelpCtx:=$F975;

PrzWin^.Numer:=Ass.EditPosition;
PrzWin^.Date:=Ass.D;

PrzWin^.DocWith :=E^.Dat.DocumentWith;
PrzWin^.DateWith:=E^.Dat.DateWith;


R.Assign(79, 3, 80, 22);
Control := New(PScrollBar, Init(R));
PrzWin^.Insert(Control);

R.Assign(75, 22, 78, 23);
ControlG := New(PScrollBar, Init(R));
ControlG^.Options := ControlG^.Options or ofPostProcess;
PrzWin^.Insert(ControlG);


R.Assign(1, 3, 79, 22);
ViewListS := New(PBoxNew, Init(R, 1,PScrollBar(ControlG), PScrollBar(Control)));
{New(PBox, Init(R, 1, PScrollbar(Control)));}
ViewListS^.NewList(New(PTextCollection, Init(0,1)));

{вставляем в список товары}
For c:=1 To E^.Dat.Amount Do
 Begin
  S:=E^.Dat.Element[c].BazKod;
  ws:=GetIdField(FFFName,s);
  Format(ws,{CName+CName}47);
  s:=ws+'│'+s;

  MyStr(StrToReal(E^.Dat.Element[c].Bak_R_Zena),CZena,CMantissa,E^.Dat.Element[c].Bak_R_Zena);
  MyStr(StrToReal(E^.Dat.Element[c].New_R_Zena),CZena,CMantissa,E^.Dat.Element[c].New_R_Zena);

  If Abs(StrToReal(E^.Dat.Element[c].Bak_R_Zena))>0.009 Then
  MyStr((StrToReal(E^.Dat.Element[c].New_R_Zena)-StrToReal(E^.Dat.Element[c].Bak_R_Zena))/
  StrToReal(E^.Dat.Element[c].Bak_R_Zena)*100,CKol+1,CMantissa,Proz)
  Else
  Proz:='???.??';


  DelSpace(E^.Dat.Element[c].Kol);
  RFormat(E^.Dat.Element[c].Kol,CKol);
  s:=s+'│'+E^.Dat.Element[c].Kol+'│'+
  E^.Dat.Element[c].Bak_R_Zena+'│'+
  E^.Dat.Element[c].New_R_Zena+'│'+Proz;

  ViewListS^.List^.Insert(NewStr(s));
  ViewListS^.SetRange(ViewListS^.List^.Count);
 End;
ViewListS^.FocusItem(0);

PrzWin^.Insert(ViewListS);

  R.Assign(1, 2, 77, 3);
  PrzWin^.Insert(New(PLabel, Init(R,'Наименование товара                              Код  Колич   Было    Стало',
  ViewListS)));

R.Assign(1, 0, 27, 1);
Control := New(PColoredText, Init(R, 'Документ:'+E^.Dat.Document+' от '+E^.Dat.DateC, $4E));
PrzWin^.Insert(Control);

R.Assign(67, 0, 79, 1);
Control := New(PColoredText, Init(R, 'Позиций:'+IntToStr(E^.DAt.Amount,CMAntissa), $4E));
PrzWin^.Insert(Control);

Msg[0]:=#0;
If E^.Dat.Vid=1 Then
 Msg:='По возврату '+E^.Dat.DocumentWith+' от '+E^.Dat.DateWith
 Else
 Msg:='Стандартная';

R.Assign(23, 1, 54, 2);
If Msg[0]<>#0 Then
Control := New(PColoredText, Init(R, #3+Msg, $5F))
Else
Control := New(PColoredText, Init(R, #3+Msg, $77));
PrzWin^.Insert(Control);


MyStr(StrToReal(E^.DAt.Itogo_Bak_R_Zena),CIZena,CMAntissa,E^.DAt.Itogo_Bak_R_Zena);
DelSpace(E^.DAt.Itogo_Bak_R_Zena);

MyStr(StrToReal(E^.DAt.Itogo_New_R_Zena),CIZena,CMAntissa,E^.DAt.Itogo_New_R_Zena);
DelSpace(E^.DAt.Itogo_New_R_Zena);

MyStr(StrToReal(E^.DAt.Delta_RZ),CIZena,CMAntissa,E^.DAt.Delta_RZ);
DelSpace(E^.DAt.Delta_RZ);


If Abs(StrToReal(E^.DAt.Itogo_Bak_R_Zena))>0.009 Then
MyStr(StrToReal(E^.DAt.Delta_RZ)/StrToReal(E^.DAt.Itogo_Bak_R_Zena)*100,CLitr+1,CMAntissa,Proz)
Else Proz:='??.??';
DelSpace(Proz);


s:=#3+'Всего по Р/Ценам Было:'+E^.DAt.Itogo_Bak_R_Zena+' Стало:'+E^.DAt.Itogo_Bak_R_Zena+
' Переоценка:'+E^.DAt.Delta_RZ+' ('+Proz+'%)';
R.Assign(2, 22, 2+Length(s)+1, 23);
Control := New(PColoredText, Init(R, s, $4E));
Control^.Options := Control^.Options or ofCenterX;
PrzWin^.Insert(Control);

R.Assign(61, 1, 79, 2);
Control := New(PColoredText, Init(R, #3+GetOperatorField(FName,E^.Dat.Caption)+'('+E^.Dat.Caption+')', $4E));
PrzWin^.Insert(Control);

Dispose(E,Done);

NoInfoMsg;

i := Desktop^.ExecView(PrzWin);

Dispose(Control,Done);
Dispose(ControlG,Done);
Dispose(ViewListS,Done);
Dispose(PrzWin,Done);

end;




procedure TFullScreenPrz.HandleEvent(var Event: TEvent);

procedure Calculator;
begin
  Calc^.Start;
end;

Var s : String;
    Prom : Word;
    Assistent : DocumentEditZ;
    Sn : ArtikulStr;
Begin

Case Event.What Of
 evCommand :
   Case Event.Command Of
  cmLocalCalc:Calculator;
  cmFullview : Begin
                ClearFind;
                Assistent.EditPosition:=PrzWin^.DocWith;
                DelSpace(Assistent.EditPosition);
                DelZerro(Assistent.EditPosition);
                Assistent.D:=PrzWin^.DateWith;
                DelSpace(Assistent.D);
                VRet^.FullScreenVzw(Assistent);
                ClearEvent(Event);
               End;
cmViewPrihodTovar
     :Begin
if (ViewListS^.State and sfFocused <> 0) And(ViewListS^.List<>Nil) And (ViewListS^.List^.Count>=1)Then
      If (ViewListS^.List^.Count-1)>=0 Then
       begin
        Sn:=Copy(ViewListS^.GEtTExt(ViewListS^.Focused,ViewListS^.List^.Count),1+47+1,CArtikul);
        FP^.FindScreenPrh(SN);
        ClearEvent(Event);
       End;
      End;

  cmPrintReestr:    Begin
                ClearFind;
                Assistent.EditPosition:=Numer;
                DelSpace(Assistent.EditPosition);
                DelZerro(Assistent.EditPosition);
                Assistent.D:=Date;
                DelSpace(Assistent.D);
                PrintAktPrz(Assistent);
                    End;
        Else;
        End;
 Else;
 End;

inherited HandleEvent(Event);
End;


Destructor TFullScreenPrz.Done;
Begin
TDialog.Done;
End;


Function TestNoClientStatKod(OperatorSelector:Word;Kod:ArtikulStr):Boolean;
Var SArt: ArtikulStr;
    c : Word;
Begin
RFormatZerro(Kod,CClientKod);
SArt:=IntToStr(OperatorSelector,COne)+Kod;
TestNoClientStatKod:=True;
For c:=1 To 10 Do
 Begin
  If NoClientStatKod[c]=SArt Then
   Begin
    TestNoClientStatKod:=False;
    Exit;
   End;
 End;
End;



Procedure CalcNewToDaymarket(TDate:TDateString;
                             Var RashetList,RashetList2,MrkListDiv:PBox);
Const
Shablon1=
'    0            0.00     0            0.00     0            0.00     0            0.00     0 '+
{12345│123456789012345│12345│123456789012345│12345│123456789012345│12345│123456789012345│12345}
'           0.00     0            0.00';

Shablon2='         0.0000          0.0000          0.0000'+' '+
         { приход от кл З приход от кл З2  приход от склЗ}
         '         0.0000          0.0000          0.0000';
         { приход скл  З2    приход обм З   приход обм З2}
         {123456789012345│123456789012345│123456789012345│123456789012345│123456789012345│
          123456789012345│123456789012345}

ShablonDiv
        ='     0      0      0      0      0      0      0      0 '+
         '     0      0      0      0      0      0      0      0 '+
         '     0      0      0      0      0      0      0      0 ';
         {123456│123456│123456│123456│123456│123456│123456│123456│}

(*
     MrkRoznC   : String[CKol];
     MrkRoznRZC : Double;{продажа в розницу по лобовым ценам}
    MrkRoznCOpl : Double;{продажа в розницу по ценам к оплате}
    MrkRoznCZZ  : Double;{продажа в розницу по ценам закупка для бухгалтерии}
    MrkRoznCZZ2 : Double;{продажа в розницу по ценам закупка 2}
     MrkOptC    : String[CKol];
     MrkOptRZC  : Double;{продажа в оптом по лобовым ценам}
    MrkOptCOpl  : Double;{продажа в оптом по ценам к оплате}
    MrkOptCZZ   : Double;{продажа в оптом по ценам закупка для бухгалтерии}
    MrkOptCZZ2  : Double;{продажа в оптом по ценам закупка 2}

     MrkRoznB   : String[CKol];
     MrkRoznRZB : Double;{продажа в розницу по лобовым ценам}
    MrkRoznBOpl : Double;{продажа в розницу по ценам к оплате}
    MrkRoznBZZ  : Double;{продажа в розницу по ценам закупка для бухгалтерии}
    MrkRoznBZZ2 : Double;{продажа в розницу по ценам закупка 2}
     MrkOptB    : String[CKol];
     MrkOptRZB  : Double;{продажа в оптом по лобовым ценам}
    MrkOptBOpl  : Double;{продажа в оптом по ценам к оплате}
    MrkOptBZZ   : Double;{продажа в оптом по ценам закупка для бухгалтерии}
    MrkOptBZZ2  : Double;{продажа в оптом по ценам закупка 2}
*)

ShablonOPTROZN='    0            0.00            0.00          0.0000          0.0000 '+
               '    0            0.00            0.00          0.0000          0.0000 '+
               '    0            0.00            0.00          0.0000          0.0000 '+
               '    0            0.00            0.00          0.0000          0.0000';
               {12345│123456789012345│123456789012345│123456789012345│123456789012345│}






(*
Shablon2='         0.0000          0.0000          0.0000          0.0000          0.0000'+
         {продажи коплате    продажи по З   продажи по З2   продажи скл З  продажи скл З2}
         '         0.0000          0.0000          0.0000          0.0000          0.0000'+
         {  продажи обм З  продажи обм З2  приход от кл З приход от кл З2  приход от склЗ}
         '         0.0000          0.0000          0.0000';
         { приход скл  З2    приход обм З   приход обм З2}


*)


         {123456789012345│123456789012345│123456789012345│123456789012345│123456789012345│
          123456789012345│123456789012345}
Var MarketFile : File;
    E : PBufSuperMarketType;
    i,vo : Byte;
    ws,ws2,ws3,s,ws1 : String;
    BakKol,NewKol : AllStr;
    KOplateCl,ProdagiCZ,ProdagiCZ2,
              ProdagiSZ,ProdagiSZ2,
              ProdagiBZ,ProdagiBZ2 : AllStr;
    L : Boolean;
    jk,Count : Word;
Begin
 Assign(MarketFile,Path^.Dat.ToMarket+TDate+'.mrk');
 i:=IOResult;
 Reset(MarketFile,SizeOf(SuperMarketType));
 i:=IOResult;
 If i <> 0 Then
  Begin
   Exit;
  End;
 While Not(Eof(MarketFile)) Do
  Begin
   New(E,Init);
   Count:=0;
   ReadBufMarket(MarketFile,E,Count);
For jk:=1 To Count Do
Begin


   If (E^.Point.DAt[jk].Active) And (Not(E^.Point.DAt[jk].Realiz) Or ((E^.Point.DAt[jk].Realiz)
   And(E^.Point.DAt[jk].DocSelector in [5,6,7,8]))) Then
   If (TestNoClientStatKod(E^.Point.DAt[jk].OperatorSelector,E^.Point.DAt[jk].ClientKod)) Then
   Begin
    For i:=1 To E^.Point.DAt[jk].Amount Do
     Begin
      If Not TestElement(E^.Point.DAt[jk].MarketElement[i].BazKod,RashetList) Then
       Begin
        l:=ProdagaWindow;
        ProdagaWindow:=False;
        s:=RashetList^.GetText(Location(RashetList,E^.Point.DAt[jk].MarketElement[i].BazKod,ProdagaWindow),
        RashetList^.List^.Count);

        DelSpace(E^.Point.DAt[jk].MarketElement[i].Input.R_Zena);
        {Kol}
        ws:=Copy(s,1+1+CArtikul+1+CKol+1+CIzena+1+(CKol+1+CIZena+1)*3+(CKol+1+CIZena+1)*
	   E^.Point.DAt[jk].OperatorSelector,Ckol);
        Str((StrToInt(E^.Point.DAt[jk].MarketElement[i].Input.Kol)+StrToInt(ws)):CKol,ws);
        {Summa}
        ws1:=Copy(s,1+1+CArtikul+1+CKol+1+CIzena+1+Ckol+1+(CKol+1+CIZena+1)*3+(CKol+1+CIZena+1)*
	   E^.Point.DAt[jk].OperatorSelector,
           CIZena);
        MyStr((StrToInt(E^.Point.DAt[jk].MarketElement[i].Input.Kol)*StrToReal(E^.Point.DAt[jk].MarketElement[i].Input.R_Zena)
             +StrToReal(ws1)),CIZena,CMantissa,ws1);
        ws:=ws+'│'+ws1;
        {Del BakString}
        Delete(s,1+1+CArtikul+1+CKol+1+CIzena+1+(CKol+1+CIZena+1)*3+(CKol+1+CIZena+1)*E^.Point.DAt[jk].OperatorSelector,
	   CKol+1+CIZena);
        {Inserting NewString}
        Insert(ws,s,1+1+CArtikul+1+CKol+1+CIzena+1+(CKol+1+CIZena+1)*3+(CKol+1+CIZena+1)*E^.Point.DAt[jk].OperatorSelector);

        RashetList^.List^.AtFree(Location(RashetList,E^.Point.DAt[jk].MarketElement[i].BazKod,ProdagaWindow));
        RashetList^.SetRange(RashetList^.List^.Count);
        RashetList^.List^.Insert(NewStr(s));
        RashetList^.SetRange(RashetList^.List^.Count);

        {обработка закупок}

        s:=RashetList2^.GetText(Location(RashetList2,E^.Point.DAt[jk].MarketElement[i].BazKod,ProdagaWindow),
        RashetList2^.List^.Count);


        KOplateCl[0]:=#0;
        ProdagiCZ[0]:=#0;
        ProdagiCZ2[0]:=#0;
        ProdagiSZ[0]:=#0;
        ProdagiSZ2[0]:=#0;
        ProdagiBZ[0]:=#0;
        ProdagiBZ2[0]:=#0;

        CAse E^.Point.DAt[jk].OperatorSelector Of
        0:{клиент}
          Begin
            ws:=Copy(s,1+1+CArtikul+1,CIZena);{сумма к оплате}
           ws2:=Copy(s,1+1+CArtikul+1+CIZena+1,CIZena);{закупка}
           ws3:=Copy(s,1+1+CArtikul+1+CIZena+1+CIZena+1,CIZena);{закупка2}
            {подсчитываем к оплате}

            Case E^.Point.DAt[jk].SkidkaSelector Of
            0,2:
               Begin{скидка автоматическая}
               MyStr(StrToReal(E^.Point.DAt[jk].MarketElement[i].Input.Zena)/
               (1+StrToReal(E^.Point.DAt[jk].MarketElement[i].Input.Proz)/100),CZena,CMantissa,
               E^.Point.DAt[jk].MarketElement[i].Input.Zena);
              End;
            1:Begin{скидка ручная}
                MyStr(StrToReal(E^.Point.DAt[jk].MarketElement[i].Input.Zena)-
                StrToReal(E^.Point.DAt[jk].MarketElement[i].Input.Skidka),CZena,CMantissa,
                E^.Point.DAt[jk].MarketElement[i].Input.Zena);
               End;
            Else;
            End;

            {к оплате}
            MyStr(StrToReal(E^.Point.DAt[jk].MarketElement[i].Input.Zena)*
   	       StrToInt(E^.Point.DAt[jk].MarketElement[i].Input.Kol),CIZena,CMantissaZ,
            KOplateCl);{просчитали цену к оплате по позиции}
            MySTr(StrToReal(ws)+StrToReal(KOplateCL),CIZena,CMantissa,KOplateCL);
            {просчитали новую итоговую сумму к оплате по позиции}
            System.Delete(s,1+1+CArtikul+1,CIZena);
            System.Insert(KOplateCl,s,1+1+CArtikul+1);

            {по закупке}
            MyStr(StrToReal(E^.Point.DAt[jk].MarketElement[i].Input.Zakupka)*
   	       StrToInt(E^.Point.DAt[jk].MarketElement[i].Input.Kol),CIZena,CMantissaZ,
            ProdagiCZ);{просчитали }
            MyStr(StrToReal(ws2)+StrToReal(ProdagiCZ),CIZena,CMantissa,ProdagiCZ);
            {просчитали новую итоговую сумму по закупке}
            System.Delete(s,1+1+CArtikul+1+CIZena+1,CIZena);
            System.Insert(ProdagiCZ,s,1+1+CArtikul+1+CIZena+1);

            {по закупке2}
            MyStr(StrToReal(E^.Point.DAt[jk].MarketElement[i].Input.Zakupka2)*
   	       StrToInt(E^.Point.DAt[jk].MarketElement[i].Input.Kol),CIZena,CMantissaZ,
            ProdagiCZ2);{просчитали }
            MyStr(StrToReal(ws3)+StrToReal(ProdagiCZ2),CIZena,CMantissa,ProdagiCZ2);
            {просчитали новую итоговую сумму по закупке}
            System.Delete(s,1+1+CArtikul+1+CIZena+1+CIZena+1,CIZena);
            System.Insert(ProdagiCZ2,s,1+1+CArtikul+1+CIZena+1+CIZena+1);
          End;{0}
        1:{склад}
	     Begin
           ws:=Copy(s,1+1+CArtikul+1+CIZena+1+CIZena+1+CIZena+1,CIZena);{складской вид закупка}
          ws2:=Copy(s,1+1+CArtikul+1+CIZena+1+CIZena+1+CIZena+1+CIZena+1,CIZena);{складской вид закупка}

            {по закупке}
            MyStr(StrToReal(E^.Point.DAt[jk].MarketElement[i].Input.Zakupka)*
   	       StrToInt(E^.Point.DAt[jk].MarketElement[i].Input.Kol),CIZena,CMantissaZ,
            ProdagiSZ);{просчитали }
            MyStr(StrToReal(ws)+StrToReal(ProdagiSZ),CIZena,CMantissa,ProdagiSZ);
            {просчитали новую итоговую сумму по закупке}
            System.Delete(s,1+1+CArtikul+1+CIZena+1+CIZena+1+CIZena+1,CIZena);
            System.Insert(ProdagiSZ,s,1+1+CArtikul+1+CIZena+1+CIZena+1+CIZena+1);

            {по закупке2}
            MyStr(StrToReal(E^.Point.DAt[jk].MarketElement[i].Input.Zakupka2)*
   	       StrToInt(E^.Point.DAt[jk].MarketElement[i].Input.Kol),CIZena,CMantissaZ,
            ProdagiSZ2);{просчитали }
            MyStr(StrToReal(ws2)+StrToReal(ProdagiSZ2),CIZena,CMantissa,ProdagiSZ2);
            {просчитали новую итоговую сумму по закупке}
            System.Delete(s,1+1+CArtikul+1+CIZena+1+CIZena+1+CIZena+1+CIZena+1,CIZena);
            System.Insert(ProdagiSZ2,s,1+1+CArtikul+1+CIZena+1+CIZena+1+CIZena+1+CIZena+1);

          End;
        2:{обмен}
          Begin
           ws:=Copy(s,1+1+CArtikul+1+CIZena+1+CIZena+1+CIZena+1+CIZena+1+CIZena+1,CIZena);{обмен вид закупка}
          ws2:=Copy(s,1+1+CArtikul+1+CIZena+1+CIZena+1+CIZena+1+CIZena+1+CIZena+1+CIZena+1,CIZena);{обмен вид закупка}
            {по закупке}
            MyStr(StrToReal(E^.Point.DAt[jk].MarketElement[i].Input.Zakupka)*
   	       StrToInt(E^.Point.DAt[jk].MarketElement[i].Input.Kol),CIZena,CMantissaZ,
            ProdagiBZ);{просчитали }
            MyStr(StrToReal(ws)+StrToReal(ProdagiBZ),CIZena,CMantissa,ProdagiBZ);
            {просчитали новую итоговую сумму по закупке}
            System.Delete(s,1+1+CArtikul+1+CIZena+1+CIZena+1+CIZena+1+CIZena+1+CIZena+1,CIZena);
            System.Insert(ProdagiBZ,s,1+1+CArtikul+1+CIZena+1+CIZena+1+CIZena+1+CIZena+1+CIZena+1);

            {по закупке2}
            MyStr(StrToReal(E^.Point.DAt[jk].MarketElement[i].Input.Zakupka2)*
   	       StrToInt(E^.Point.DAt[jk].MarketElement[i].Input.Kol),CIZena,CMantissaZ,
            ProdagiBZ2);{просчитали }
            MyStr(StrToReal(ws2)+StrToReal(ProdagiBZ2),CIZena,CMantissa,ProdagiBZ2);
            {просчитали новую итоговую сумму по закупке}
            System.Delete(s,1+1+CArtikul+1+CIZena+1+CIZena+1+CIZena+1+CIZena+1+CIZena+1+CIZena+1,CIZena);
            System.Insert(ProdagiBZ2,s,1+1+CArtikul+1+CIZena+1+CIZena+1+CIZena+1+CIZena+1+CIZena+1+CIZena+1);
          End;
        Else;
        End;
        RashetList2^.List^.AtFree(Location(RashetList2,E^.Point.DAt[jk].MarketElement[i].BazKod,ProdagaWindow));
        RashetList2^.SetRange(RashetList2^.List^.Count);
        RashetList2^.List^.Insert(NewStr(s));
        RashetList2^.SetRange(RashetList2^.List^.Count);
        {конец обработки закупок}

        {обработка продаж по отделениям}
        s:=MrkListDiv^.GetText(Location(MrkListDiv,E^.Point.DAt[jk].MarketElement[i].BazKod,ProdagaWindow),
	   MrkListDiv^.List^.Count);

        Case E^.Point.DAt[jk].OperatorSelector Of
        0:Begin
           BakKol:=Copy(s,1+1+CArtikul+1+(CKol+1+1)*(E^.Point.DAt[jk].MarketElement[i].Input.DivisionNumber-1),CKol+1);
           Str(StrToInt(BakKol)+StrToInt(E^.Point.DAt[jk].MarketElement[i].Input.Kol):CKol+1,BakKol);
           System.Delete(s,1+1+CArtikul+1+(CKol+1+1)*(E^.Point.DAt[jk].MarketElement[i].Input.DivisionNumber-1),CKol+1);
           System.Insert(BakKol,s,1+1+CArtikul+1+(CKol+1+1)*(E^.Point.DAt[jk].MarketElement[i].Input.DivisionNumber-1));
          End;
        1:Begin
           BakKol:=Copy(s,1+1+CArtikul+1+(CKol+1+1)*CDivision+(CKol+1+1)*
		 (E^.Point.DAt[jk].MarketElement[i].Input.DivisionNumber-1),
		 CKol+1);
           Str(StrToInt(BakKol)+StrToInt(E^.Point.DAt[jk].MarketElement[i].Input.Kol):CKol+1,BakKol);
           System.Delete(s,1+1+CArtikul+1+(CKol+1+1)*CDivision+(CKol+1+1)*
		 (E^.Point.DAt[jk].MarketElement[i].Input.DivisionNumber-1),
		 CKol+1);
           System.Insert(BakKol,s,1+1+CArtikul+1+(CKol+1+1)*CDivision+(CKol+1+1)*
		 (E^.Point.DAt[jk].MarketElement[i].Input.DivisionNumber-1));
          End;
        2:Begin
           BakKol:=Copy(s,1+1+CArtikul+1+(CKol+1+1)*CDivision*2+(CKol+1+1)*
		 (E^.Point.DAt[jk].MarketElement[i].Input.DivisionNumber-1),
		 CKol+1);
           Str(StrToInt(BakKol)+StrToInt(E^.Point.DAt[jk].MarketElement[i].Input.Kol):CKol+1,BakKol);
           System.Delete(s,1+1+CArtikul+1+(CKol+1+1)*CDivision*2+(CKol+1+1)*
		 (E^.Point.DAt[jk].MarketElement[i].Input.DivisionNumber-1),
		 CKol+1);
           System.Insert(BakKol,s,1+1+CArtikul+1+(CKol+1+1)*CDivision*2+(CKol+1+1)*
		 (E^.Point.DAt[jk].MarketElement[i].Input.DivisionNumber-1));
          End;
        Else;
        End;
{
        If E^.Point.DAt[jk].MarketElement[i].BazKod='21696' Then
        begin
        Writeln(s);
        Readln;
        End;
}
        MrkListDiv^.List^.AtFree(Location(MrkListDiv,E^.Point.DAt[jk].MarketElement[i].BazKod,ProdagaWindow));
        MrkListDiv^.SetRange(MrkListDiv^.List^.Count);
        MrkListDiv^.List^.Insert(NewStr(s));
        MrkListDiv^.SetRange(MrkListDiv^.List^.Count);
        {завершена обработка продаж по отделениям}
        ProdagaWindow:=l;

       End{If TestElement Then}
      Else
       Begin{position not found in List}
        s:='│'+E^.Point.DAt[jk].MarketElement[i].BazKod+'│    0            0.00 '+Shablon1;
        Str(StrToInt(E^.Point.DAt[jk].MarketElement[i].Input.Kol):CKol,ws);
        MyStr(StrToInt(E^.Point.DAt[jk].MarketElement[i].Input.Kol)*StrToReal(E^.Point.DAt[jk].MarketElement[i].Input.R_Zena)
               ,CIZena,CMantissa,ws1);
        ws:=ws+'│'+ws1;
        Delete(s,1+1+CArtikul+1+CKol+1+CIzena+1+(CKol+1+CIZena+1)*3+(CKol+1+CIZena+1)*E^.Point.DAt[jk].OperatorSelector,
	   CKol+1+CIZena);
        {Inserting NewString}
        Insert(ws,s,1+1+CArtikul+1+CKol+1+CIzena+1+(CKol+1+CIZena+1)*3+(CKol+1+CIZena+1)*E^.Point.DAt[jk].OperatorSelector);
        RashetList^.List^.Insert(NewStr(s));
        RashetList^.SetRange(RashetList^.List^.Count);



        {обработка информации по з/ц}
        Str(StrToInt(E^.Point.DAt[jk].MarketElement[i].Input.Kol):CKol,ws);

        MyStr(StrToInt(E^.Point.DAt[jk].MarketElement[i].Input.Kol)*StrToReal(E^.Point.DAt[jk].MarketElement[i].Input.Zakupka)
               ,CIZena,CMantissa,ws1);{сумма реализации по закупочным}


        MyStr(StrToInt(E^.Point.DAt[jk].MarketElement[i].Input.Kol)*StrToReal(E^.Point.DAt[jk].MarketElement[i].Input.Zakupka2)
               ,CIZena,CMantissa,ws2);{сумма реализации по закупочным2}

        KOplateCl[0]:=#0;
        ProdagiCZ[0]:=#0;
        ProdagiCZ2[0]:=#0;
        ProdagiSZ[0]:=#0;
        ProdagiSZ2[0]:=#0;
        ProdagiBZ[0]:=#0;
        ProdagiBZ2[0]:=#0;
        MySTr(StrToReal(KOplateCl),CIZena,CMantissaZ,KOplateCl);
        MySTr(StrToReal(ProdagiCZ),CIZena,CMantissaZ,ProdagiCZ);
        MySTr(StrToReal(ProdagiCZ2),CIZena,CMantissaZ,ProdagiCZ2);
        MySTr(StrToReal(ProdagiSZ),CIZena,CMantissaZ,ProdagiSZ);
        MySTr(StrToReal(ProdagiSZ2),CIZena,CMantissaZ,ProdagiSZ2);
        MySTr(StrToReal(ProdagiBZ),CIZena,CMantissaZ,ProdagiBZ);
        MySTr(StrToReal(ProdagiBZ2),CIZena,CMantissaZ,ProdagiBZ2);

        Case E^.Point.DAt[jk].OperatorSelector Of
        0:Begin
	      ProdagiCZ:=ws1;
           ProdagiCZ2:=ws2;
          End;
        1:Begin
	      ProdagiSZ:=ws1;
           ProdagiSZ2:=ws2;
          End;
        2:Begin
	      ProdagiBZ:=ws1;
           ProdagiBZ2:=ws2;
          End;
        Else;
        End;


        If E^.Point.DAt[jk].OperatorSelector=0 Then
        Begin
            Case E^.Point.DAt[jk].SkidkaSelector Of
            0,2:
               Begin{скидка автоматическая}
               MyStr(StrToReal(E^.Point.DAt[jk].MarketElement[i].Input.Zena)/
               (1+StrToReal(E^.Point.DAt[jk].MarketElement[i].Input.Proz)/100),CZena,CMantissa,
               E^.Point.DAt[jk].MarketElement[i].Input.Zena);
              End;
            1:Begin{скидка ручная}
                MyStr(StrToReal(E^.Point.DAt[jk].MarketElement[i].Input.Zena)-
                StrToReal(E^.Point.DAt[jk].MarketElement[i].Input.Skidka),CZena,CMantissa,
                E^.Point.DAt[jk].MarketElement[i].Input.Zena);
               End;
            Else;
            End;

                MyStr(StrToReal(E^.Point.DAt[jk].MarketElement[i].Input.Zena)*
			 StrToInt(E^.Point.DAt[jk].MarketElement[i].Input.Kol),CIZena,CMantissaZ,
                KOplateCl);
        End;

        s:='│'+E^.Point.DAt[jk].MarketElement[i].BazKod+'│'+KOplateCl+' '+
        +ProdagiCZ+' '+ProdagiCZ2+' '+ProdagiSZ+' '+ProdagiSZ2+' '+
        ProdagiBZ+' '+ProdagiBZ2+' '+Shablon2;

        RashetList2^.List^.Insert(NewStr(s));
        RashetList2^.SetRange(RashetList2^.List^.Count);
        {конец обработки по з/ц}


        {обработка продаж по отделениям}
        s:='│'+E^.Point.DAt[jk].MarketElement[i].BazKod+'│'+ShablonDiv;
        BakKol[0]:=#0;
        Case E^.Point.DAt[jk].OperatorSelector Of
        0:Begin
           BakKol:=Copy(s,1+1+CArtikul+1+(CKol+1+1)*(E^.Point.DAt[jk].MarketElement[i].Input.DivisionNumber-1),CKol+1);
           Str(StrToInt(BakKol)+StrToInt(E^.Point.DAt[jk].MarketElement[i].Input.Kol):CKol+1,BakKol);
           System.Delete(s,1+1+CArtikul+1+(CKol+1+1)*(E^.Point.DAt[jk].MarketElement[i].Input.DivisionNumber-1),CKol+1);
           System.Insert(BakKol,s,1+1+CArtikul+1+(CKol+1+1)*(E^.Point.DAt[jk].MarketElement[i].Input.DivisionNumber-1));
          End;
        1:Begin
           BakKol:=Copy(s,1+1+CArtikul+1+(CKol+1+1)*CDivision+(CKol+1+1)*
		 (E^.Point.DAt[jk].MarketElement[i].Input.DivisionNumber-1),
		 CKol+1);
           Str(StrToInt(BakKol)+StrToInt(E^.Point.DAt[jk].MarketElement[i].Input.Kol):CKol+1,BakKol);
           System.Delete(s,1+1+CArtikul+1+(CKol+1+1)*CDivision+(CKol+1+1)*
		 (E^.Point.DAt[jk].MarketElement[i].Input.DivisionNumber-1),
		 CKol+1);
           System.Insert(BakKol,s,1+1+CArtikul+1+(CKol+1+1)*CDivision+(CKol+1+1)*
		 (E^.Point.DAt[jk].MarketElement[i].Input.DivisionNumber-1));
          End;
        2:Begin
           BakKol:=Copy(s,1+1+CArtikul+1+(CKol+1+1)*CDivision*2+(CKol+1+1)*
		 (E^.Point.DAt[jk].MarketElement[i].Input.DivisionNumber-1),
		 CKol+1);
           Str(StrToInt(BakKol)+StrToInt(E^.Point.DAt[jk].MarketElement[i].Input.Kol):CKol+1,BakKol);
           System.Delete(s,1+1+CArtikul+1+(CKol+1+1)*CDivision*2+(CKol+1+1)*
		 (E^.Point.DAt[jk].MarketElement[i].Input.DivisionNumber-1),
		 CKol+1);
           System.Insert(BakKol,s,1+1+CArtikul+1+(CKol+1+1)*CDivision*2+(CKol+1+1)*
		 (E^.Point.DAt[jk].MarketElement[i].Input.DivisionNumber-1));
          End;
        Else;
        End;

        MrkListDiv^.List^.Insert(NewStr(s));
        MrkListDiv^.SetRange(MrkListDiv^.List^.Count);
        {завершена обработка продаж по отделениям}

       End;{Else}

     End;{For}

    For i:=1 To E^.Point.DAt[jk].AmountS Do
     Begin
      With E^.Point.DAt[jk] Do
      Begin
      If Not TestElement(E^.Point.DAt[jk].DocumentElement[i].BazKod,RashetList) Then
       Begin
        l:=ProdagaWindow;
        ProdagaWindow:=False;
        s:=RashetList^.GetText(Location(RashetList,E^.Point.DAt[jk].DocumentElement[i].BazKod,ProdagaWindow),
              RashetList^.List^.Count);
        DelSpace(E^.Point.DAt[jk].DocumentElement[i].Input.R_Zena);
        {Kol}
        ws:=Copy(s,1+1+CArtikul+1+CKol+1+CIzena+1+(CKol+1+CIZena+1)*3+(CKol+1+CIZena+1)*
	   E^.Point.DAt[jk].OperatorSelector,Ckol);
        Str((StrToInt(E^.Point.DAt[jk].DocumentElement[i].Input.Kol)+StrToInt(ws)):CKol,ws);
        {Summa}
        ws1:=Copy(s,1+1+CArtikul+1+CKol+1+CIzena+1+Ckol+1+(CKol+1+CIZena+1)*3+(CKol+1+CIZena+1)*
	   E^.Point.DAt[jk].OperatorSelector,
           CIZena);
        MyStr((StrToInt(E^.Point.DAt[jk].DocumentElement[i].Input.Kol)*
	   StrToReal(E^.Point.DAt[jk].DocumentElement[i].Input.R_Zena)
             +StrToReal(ws1)),CIZena,CMantissa,ws1);
        ws:=ws+'│'+ws1;
        {Del BakString}
        Delete(s,1+1+CArtikul+1+CKol+1+CIzena+1+(CKol+1+CIZena+1)*3+(CKol+1+CIZena+1)*
	   E^.Point.DAt[jk].OperatorSelector,CKol+1+CIZena);
        {Inserting NewString}
        Insert(ws,s,1+1+CArtikul+1+CKol+1+CIzena+1+(CKol+1+CIZena+1)*3+(CKol+1+CIZena+1)*E^.Point.DAt[jk].OperatorSelector);

        RashetList^.List^.AtFree(Location(RashetList,E^.Point.DAt[jk].DocumentElement[i].BazKod,ProdagaWindow));
        RashetList^.SetRange(RashetList^.List^.Count);
        RashetList^.List^.Insert(NewStr(s));
        RashetList^.SetRange(RashetList^.List^.Count);



        {обработка закупок}
        s:=RashetList2^.GetText(Location(RashetList2,E^.Point.DAt[jk].DocumentElement[i].BazKod,ProdagaWindow),
        RashetList2^.List^.Count);

        KOplateCl[0]:=#0;
        ProdagiCZ[0]:=#0;
        ProdagiCZ2[0]:=#0;
        ProdagiSZ[0]:=#0;
        ProdagiSZ2[0]:=#0;
        ProdagiBZ[0]:=#0;
        ProdagiBZ2[0]:=#0;

        CAse E^.Point.DAt[jk].OperatorSelector Of
        0:{клиент}
          Begin
            ws:=Copy(s,1+1+CArtikul+1,CIZena);{сумма к оплате}
           ws2:=Copy(s,1+1+CArtikul+1+CIZena+1,CIZena);{закупка}
           ws3:=Copy(s,1+1+CArtikul+1+CIZena+1+CIZena+1,CIZena);{закупка2}
            {подсчитываем к оплате}

            Case E^.Point.DAt[jk].SkidkaSelector Of
            0,2:
               Begin{скидка автоматическая}
               MyStr(StrToReal(E^.Point.DAt[jk].DocumentElement[i].Input.Zena)/
               (1+StrToReal(E^.Point.DAt[jk].DocumentElement[i].Input.Proz)/100),CZena,CMantissa,
               E^.Point.DAt[jk].DocumentElement[i].Input.Zena);
              End;
            1:Begin{скидка ручная}
                MyStr(StrToReal(E^.Point.DAt[jk].DocumentElement[i].Input.Zena)-
                StrToReal(E^.Point.DAt[jk].DocumentElement[i].Input.Skidka),CZena,CMantissa,
                E^.Point.DAt[jk].DocumentElement[i].Input.Zena);
               End;
            Else;
            End;

            {к оплате}
            MyStr(StrToReal(E^.Point.DAt[jk].DocumentElement[i].Input.Zena)*
   	       StrToInt(E^.Point.DAt[jk].DocumentElement[i].Input.Kol),CIZena,CMantissaZ,
            KOplateCl);{просчитали цену к оплате по позиции}
            MySTr(StrToReal(ws)+StrToReal(KOplateCL),CIZena,CMantissa,KOplateCL);
            {просчитали новую итоговую сумму к оплате по позиции}
            System.Delete(s,1+1+CArtikul+1,CIZena);
            System.Insert(KOplateCl,s,1+1+CArtikul+1);

            {по закупке}
            MyStr(StrToReal(E^.Point.DAt[jk].DocumentElement[i].Input.Zakupka)*
   	       StrToInt(E^.Point.DAt[jk].DocumentElement[i].Input.Kol),CIZena,CMantissaZ,
            ProdagiCZ);{просчитали }
            MyStr(StrToReal(ws2)+StrToReal(ProdagiCZ),CIZena,CMantissa,ProdagiCZ);
            {просчитали новую итоговую сумму по закупке}
            System.Delete(s,1+1+CArtikul+1+CIZena+1,CIZena);
            System.Insert(ProdagiCZ,s,1+1+CArtikul+1+CIZena+1);

            {по закупке2}
            MyStr(StrToReal(E^.Point.DAt[jk].DocumentElement[i].Input.Zakupka2)*
   	       StrToInt(E^.Point.DAt[jk].DocumentElement[i].Input.Kol),CIZena,CMantissaZ,
            ProdagiCZ2);{просчитали }
            MyStr(StrToReal(ws3)+StrToReal(ProdagiCZ2),CIZena,CMantissa,ProdagiCZ2);
            {просчитали новую итоговую сумму по закупке}
            System.Delete(s,1+1+CArtikul+1+CIZena+1+CIZena+1,CIZena);
            System.Insert(ProdagiCZ2,s,1+1+CArtikul+1+CIZena+1+CIZena+1);
          End;{0}
        1:{склад}
	     Begin
           ws:=Copy(s,1+1+CArtikul+1+CIZena+1+CIZena+1+CIZena+1,CIZena);{складской вид закупка}
          ws2:=Copy(s,1+1+CArtikul+1+CIZena+1+CIZena+1+CIZena+1+CIZena+1,CIZena);{складской вид закупка}

            {по закупке}
            MyStr(StrToReal(E^.Point.DAt[jk].DocumentElement[i].Input.Zakupka)*
   	       StrToInt(E^.Point.DAt[jk].DocumentElement[i].Input.Kol),CIZena,CMantissaZ,
            ProdagiSZ);{просчитали }
            MyStr(StrToReal(ws)+StrToReal(ProdagiSZ),CIZena,CMantissa,ProdagiSZ);
            {просчитали новую итоговую сумму по закупке}
            System.Delete(s,1+1+CArtikul+1+CIZena+1+CIZena+1+CIZena+1,CIZena);
            System.Insert(ProdagiSZ,s,1+1+CArtikul+1+CIZena+1+CIZena+1+CIZena+1);

            {по закупке2}
            MyStr(StrToReal(E^.Point.DAt[jk].DocumentElement[i].Input.Zakupka2)*
   	       StrToInt(E^.Point.DAt[jk].DocumentElement[i].Input.Kol),CIZena,CMantissaZ,
            ProdagiSZ2);{просчитали }
            MyStr(StrToReal(ws2)+StrToReal(ProdagiSZ2),CIZena,CMantissa,ProdagiSZ2);
            {просчитали новую итоговую сумму по закупке}
            System.Delete(s,1+1+CArtikul+1+CIZena+1+CIZena+1+CIZena+1+CIZena+1,CIZena);
            System.Insert(ProdagiSZ2,s,1+1+CArtikul+1+CIZena+1+CIZena+1+CIZena+1+CIZena+1);

          End;
        2:{обмен}
          Begin

           ws:=Copy(s,1+1+CArtikul+1+CIZena+1+CIZena+1+CIZena+1+CIZena+1+CIZena+1,CIZena);{обмен вид закупка}
          ws2:=Copy(s,1+1+CArtikul+1+CIZena+1+CIZena+1+CIZena+1+CIZena+1+CIZena+1+CIZena+1,CIZena);{обмен вид закупка}

            {по закупке}
            MyStr(StrToReal(E^.Point.DAt[jk].DocumentElement[i].Input.Zakupka)*
   	       StrToInt(E^.Point.DAt[jk].DocumentElement[i].Input.Kol),CIZena,CMantissaZ,
            ProdagiBZ);{просчитали }
            MyStr(StrToReal(ws)+StrToReal(ProdagiBZ),CIZena,CMantissa,ProdagiBZ);
            {просчитали новую итоговую сумму по закупке}
            System.Delete(s,1+1+CArtikul+1+CIZena+1+CIZena+1+CIZena+1+CIZena+1+CIZena+1,CIZena);
            System.Insert(ProdagiBZ,s,1+1+CArtikul+1+CIZena+1+CIZena+1+CIZena+1+CIZena+1+CIZena+1);

            {по закупке2}
            MyStr(StrToReal(E^.Point.DAt[jk].DocumentElement[i].Input.Zakupka2)*
   	       StrToInt(E^.Point.DAt[jk].DocumentElement[i].Input.Kol),CIZena,CMantissaZ,
            ProdagiBZ2);{просчитали }
            MyStr(StrToReal(ws2)+StrToReal(ProdagiBZ2),CIZena,CMantissa,ProdagiBZ2);
            {просчитали новую итоговую сумму по закупке}
            System.Delete(s,1+1+CArtikul+1+CIZena+1+CIZena+1+CIZena+1+CIZena+1+CIZena+1+CIZena+1,CIZena);
            System.Insert(ProdagiBZ2,s,1+1+CArtikul+1+CIZena+1+CIZena+1+CIZena+1+CIZena+1+CIZena+1+CIZena+1);
          End;
        Else;
        End;
        RashetList2^.List^.AtFree(Location(RashetList2,E^.Point.DAt[jk].DocumentElement[i].BazKod,ProdagaWindow));
        RashetList2^.SetRange(RashetList2^.List^.Count);
        RashetList2^.List^.Insert(NewStr(s));
        RashetList2^.SetRange(RashetList2^.List^.Count);
        {конец обработки закупок}

        {обработка продаж по отделениям}
        s:=MrkListDiv^.GetText(Location(MrkListDiv,E^.Point.DAt[jk].DocumentElement[i].BazKod,ProdagaWindow),
	   MrkListDiv^.List^.Count);

        Case E^.Point.DAt[jk].OperatorSelector Of
        0:Begin
           BakKol:=Copy(s,1+1+CArtikul+1+(CKol+1+1)*(E^.Point.DAt[jk].DocumentElement[i].Input.DivisionNumber-1),CKol+1);
           Str(StrToInt(BakKol)+StrToInt(E^.Point.DAt[jk].DocumentElement[i].Input.Kol):CKol+1,BakKol);
           System.Delete(s,1+1+CArtikul+1+(CKol+1+1)*(E^.Point.DAt[jk].DocumentElement[i].Input.DivisionNumber-1),CKol+1);
           System.Insert(BakKol,s,1+1+CArtikul+1+(CKol+1+1)*(E^.Point.DAt[jk].DocumentElement[i].Input.DivisionNumber-1));
          End;
        1:Begin
           BakKol:=Copy(s,1+1+CArtikul+1+(CKol+1+1)*CDivision+(CKol+1+1)*(DocumentElement[i].Input.DivisionNumber-1),
		 CKol+1);
           Str(StrToInt(BakKol)+StrToInt(E^.Point.DAt[jk].DocumentElement[i].Input.Kol):CKol+1,BakKol);
           System.Delete(s,1+1+CArtikul+1+(CKol+1+1)*CDivision+(CKol+1+1)*(DocumentElement[i].Input.DivisionNumber-1),
		 CKol+1);
           System.Insert(BakKol,s,1+1+CArtikul+1+(CKol+1+1)*CDivision+(CKol+1+1)*
		 (E^.Point.DAt[jk].DocumentElement[i].Input.DivisionNumber-1));
          End;
        2:Begin
           BakKol:=Copy(s,1+1+CArtikul+1+(CKol+1+1)*CDivision*2+(CKol+1+1)*(DocumentElement[i].Input.DivisionNumber-1),
		 CKol+1);
           Str(StrToInt(BakKol)+StrToInt(E^.Point.DAt[jk].DocumentElement[i].Input.Kol):CKol+1,BakKol);
           System.Delete(s,1+1+CArtikul+1+(CKol+1+1)*CDivision*2+(CKol+1+1)*(DocumentElement[i].Input.DivisionNumber-1),
		 CKol+1);
           System.Insert(BakKol,s,1+1+CArtikul+1+(CKol+1+1)*CDivision*2+(CKol+1+1)*
		 (E^.Point.DAt[jk].DocumentElement[i].Input.DivisionNumber-1));
          End;
        Else;
        End;

        MrkListDiv^.List^.AtFree(Location(MrkListDiv,E^.Point.DAt[jk].DocumentElement[i].BazKod,ProdagaWindow));
        MrkListDiv^.SetRange(MrkListDiv^.List^.Count);
        MrkListDiv^.List^.Insert(NewStr(s));
        MrkListDiv^.SetRange(MrkListDiv^.List^.Count);
        {завершена обработка продаж по отделениям}




        ProdagaWindow:=l;

       End{If TestElement Then}
      Else
       Begin{position not found in List}
        s:='│'+E^.Point.DAt[jk].DocumentElement[i].BazKod+'│    0            0.00 '+Shablon1;
        Str(StrToInt(E^.Point.DAt[jk].DocumentElement[i].Input.Kol):CKol,ws);
        MyStr(StrToInt(E^.Point.DAt[jk].DocumentElement[i].Input.Kol)*StrToReal(DocumentElement[i].Input.R_Zena)
               ,CIZena,CMantissa,ws1);
        ws:=ws+'│'+ws1;
        Delete(s,1+1+CArtikul+1+CKol+1+CIzena+1+(CKol+1+CIZena+1)*3+(CKol+1+CIZena+1)*OperatorSelector,CKol+1+CIZena);
        {Inserting NewString}
        Insert(ws,s,1+1+CArtikul+1+CKol+1+CIzena+1+(CKol+1+CIZena+1)*3+(CKol+1+CIZena+1)*E^.Point.DAt[jk].OperatorSelector);
        RashetList^.List^.Insert(NewStr(s));
        RashetList^.SetRange(RashetList^.List^.Count);

        {обработка информации по з/ц}
        Str(StrToInt(E^.Point.DAt[jk].DocumentElement[i].Input.Kol):CKol,ws);

        MyStr(StrToInt(E^.Point.DAt[jk].DocumentElement[i].Input.Kol)*StrToReal(DocumentElement[i].Input.Zakupka)
               ,CIZena,CMantissa,ws1);{сумма реализации по закупочным}


        MyStr(StrToInt(E^.Point.DAt[jk].DocumentElement[i].Input.Kol)*StrToReal(DocumentElement[i].Input.Zakupka2)
               ,CIZena,CMantissa,ws2);{сумма реализации по закупочным2}

        KOplateCl[0]:=#0;
        ProdagiCZ[0]:=#0;
        ProdagiCZ2[0]:=#0;
        ProdagiSZ[0]:=#0;
        ProdagiSZ2[0]:=#0;
        ProdagiBZ[0]:=#0;
        ProdagiBZ2[0]:=#0;
        MySTr(StrToReal(KOplateCl),CIZena,CMantissaZ,KOplateCl);
        MySTr(StrToReal(ProdagiCZ),CIZena,CMantissaZ,ProdagiCZ);
        MySTr(StrToReal(ProdagiCZ2),CIZena,CMantissaZ,ProdagiCZ2);
        MySTr(StrToReal(ProdagiSZ),CIZena,CMantissaZ,ProdagiSZ);
        MySTr(StrToReal(ProdagiSZ2),CIZena,CMantissaZ,ProdagiSZ2);
        MySTr(StrToReal(ProdagiBZ),CIZena,CMantissaZ,ProdagiBZ);
        MySTr(StrToReal(ProdagiBZ2),CIZena,CMantissaZ,ProdagiBZ2);

        Case E^.Point.DAt[jk].OperatorSelector Of
        0:Begin
	      ProdagiCZ:=ws1;
           ProdagiCZ2:=ws2;
          End;
        1:Begin
	      ProdagiSZ:=ws1;
           ProdagiSZ2:=ws2;
          End;
        2:Begin
	      ProdagiBZ:=ws1;
           ProdagiBZ2:=ws2;
          End;
        Else;
        End;


        If E^.Point.DAt[jk].OperatorSelector=0 Then
        Begin
            Case E^.Point.DAt[jk].SkidkaSelector Of
            0,2:
               Begin{скидка автоматическая}
               MyStr(StrToReal(E^.Point.DAt[jk].DocumentElement[i].Input.Zena)/
               (1+StrToReal(E^.Point.DAt[jk].DocumentElement[i].Input.Proz)/100),CZena,CMantissa,
               E^.Point.DAt[jk].DocumentElement[i].Input.Zena);
              End;
            1:Begin{скидка ручная}
                MyStr(StrToReal(E^.Point.DAt[jk].DocumentElement[i].Input.Zena)-
                StrToReal(E^.Point.DAt[jk].DocumentElement[i].Input.Skidka),CZena,CMantissa,
                E^.Point.DAt[jk].DocumentElement[i].Input.Zena);
               End;
            Else;
            End;

                MyStr(StrToReal(E^.Point.DAt[jk].DocumentElement[i].Input.Zena)*
			 StrToInt(E^.Point.DAt[jk].DocumentElement[i].Input.Kol),CIZena,CMantissaZ,
                KOplateCl);
        End;

        s:='│'+E^.Point.DAt[jk].DocumentElement[i].BazKod+'│'+KOplateCl+' '+
        +ProdagiCZ+' '+ProdagiCZ2+' '+ProdagiSZ+' '+ProdagiSZ2+' '+
        ProdagiBZ+' '+ProdagiBZ2+' '+Shablon2;

        RashetList2^.List^.Insert(NewStr(s));
        RashetList2^.SetRange(RashetList2^.List^.Count);
        {конец обработки по з/ц}

        {обработка продаж по отделениям}
        s:='│'+E^.Point.DAt[jk].DocumentElement[i].BazKod+'│'+ShablonDiv;
        BakKol[0]:=#0;
        Case E^.Point.DAt[jk].OperatorSelector Of
        0:Begin
           BakKol:=Copy(s,1+1+CArtikul+1+(CKol+1+1)*(E^.Point.DAt[jk].DocumentElement[i].Input.DivisionNumber-1),CKol+1);
           Str(StrToInt(BakKol)+StrToInt(E^.Point.DAt[jk].DocumentElement[i].Input.Kol):CKol+1,BakKol);
           System.Delete(s,1+1+CArtikul+1+(CKol+1+1)*(E^.Point.DAt[jk].DocumentElement[i].Input.DivisionNumber-1),CKol+1);
           System.Insert(BakKol,s,1+1+CArtikul+1+(CKol+1+1)*(E^.Point.DAt[jk].DocumentElement[i].Input.DivisionNumber-1));
          End;
        1:Begin
           BakKol:=Copy(s,1+1+CArtikul+1+(CKol+1+1)*CDivision+(CKol+1+1)*(DocumentElement[i].Input.DivisionNumber-1),
		 CKol+1);
           Str(StrToInt(BakKol)+StrToInt(E^.Point.DAt[jk].DocumentElement[i].Input.Kol):CKol+1,BakKol);
           System.Delete(s,1+1+CArtikul+1+(CKol+1+1)*CDivision+(CKol+1+1)*(DocumentElement[i].Input.DivisionNumber-1),
		 CKol+1);
           System.Insert(BakKol,s,1+1+CArtikul+1+(CKol+1+1)*CDivision+(CKol+1+1)*
		 (E^.Point.DAt[jk].DocumentElement[i].Input.DivisionNumber-1));
          End;
        2:Begin
           BakKol:=Copy(s,1+1+CArtikul+1+(CKol+1+1)*CDivision*2+(CKol+1+1)*(DocumentElement[i].Input.DivisionNumber-1),
		 CKol+1);
           Str(StrToInt(BakKol)+StrToInt(E^.Point.DAt[jk].DocumentElement[i].Input.Kol):CKol+1,BakKol);
           System.Delete(s,1+1+CArtikul+1+(CKol+1+1)*CDivision*2+(CKol+1+1)*(DocumentElement[i].Input.DivisionNumber-1),
		 CKol+1);
           System.Insert(BakKol,s,1+1+CArtikul+1+(CKol+1+1)*CDivision*2+(CKol+1+1)*
		 (E^.Point.DAt[jk].DocumentElement[i].Input.DivisionNumber-1));
          End;
        Else;
        End;

        MrkListDiv^.List^.Insert(NewStr(s));
        MrkListDiv^.SetRange(MrkListDiv^.List^.Count);
        {завершена обработка продаж по отделениям}


       End;{Else}
      End;{With}
     End;{For}
   End;
End;{For Count}
 Dispose(E,Done);
  End;{While}
 Close(MArketFile);
 jk:=IOResult;
End;


Procedure CalcNewTodayMarketClientBarter(TDate:TDateString;
          Var RashetList,RashetListClient
		,RashetListBarter:PBox);

Const
(*
     MrkRoznC   : String[CKol];
     MrkRoznRZC : Double;{продажа в розницу по лобовым ценам}
    MrkRoznCOpl : Double;{продажа в розницу по ценам к оплате}
    MrkRoznCZZ  : Double;{продажа в розницу по ценам закупка для бухгалтерии}
    MrkRoznCZZ2 : Double;{продажа в розницу по ценам закупка 2}
     MrkOptC    : String[CKol];
     MrkOptRZC  : Double;{продажа в оптом по лобовым ценам}
    MrkOptCOpl  : Double;{продажа в оптом по ценам к оплате}
    MrkOptCZZ   : Double;{продажа в оптом по ценам закупка для бухгалтерии}
    MrkOptCZZ2  : Double;{продажа в оптом по ценам закупка 2}

     MrkRoznB   : String[CKol];
     MrkRoznRZB : Double;{продажа в розницу по лобовым ценам}
    MrkRoznBOpl : Double;{продажа в розницу по ценам к оплате}
    MrkRoznBZZ  : Double;{продажа в розницу по ценам закупка для бухгалтерии}
    MrkRoznBZZ2 : Double;{продажа в розницу по ценам закупка 2}
     MrkOptB    : String[CKol];
     MrkOptRZB  : Double;{продажа в оптом по лобовым ценам}
    MrkOptBOpl  : Double;{продажа в оптом по ценам к оплате}
    MrkOptBZZ   : Double;{продажа в оптом по ценам закупка для бухгалтерии}
    MrkOptBZZ2  : Double;{продажа в оптом по ценам закупка 2}
*)

ShablonOPTROZN='    0            0.00            0.00          0.0000          0.0000 '+
               '    0            0.00            0.00          0.0000          0.0000';

Shablon1=
'    0            0.00     0            0.00     0            0.00     0            0.00     0 '+
{12345│123456789012345│12345│123456789012345│12345│123456789012345│12345│123456789012345│12345}
'           0.00     0            0.00';
{123456789012345│12345│123456789012345│12345│123456789012345│12345│123456789012345│12345}

Function GetZenaOplatiT(l:SuperMArketType;j:Word):AllStr;
Var SRZena: TDAteString;
BEgin
GetZenaOplatiT[0]:=#0;

        Case L.SkidkaSelector Of
        0,2:MyStr((StrToReal(l.MarketElement[j].Input.Zena)/
              (1+StrToReal(l.MarketElement[j].Input.Proz)/100)),CZena,CMantissa,SRZena);

        1:MyStr(StrToReal(L.marketElement[j].Input.Zena)-
                   StrToReal(L.marketElement[j].Input.Skidka),CZena,CMantissa,SRZena);
        Else SRZena:=L.marketElement[j].Input.Zena;{CAse}
        End;

GetZenaOplatiT:=SRZena;
End;

Function GetZenaOplatiS(l:SuperMArketType;j:Word):AllStr;
Var SRZena: TDAteString;
BEgin
GetZenaOplatiS[0]:=#0;
        Case L.SkidkaSelector Of
        0,2:MyStr((StrToReal(l.DocumentElement[j].Input.Zena)/
              (1+StrToReal(l.DocumentElement[j].Input.Proz)/100)),CZena,CMantissa,SRZena);

        1:MyStr(StrToReal(L.DocumentElement[j].Input.Zena)-
                   StrToReal(L.DocumentElement[j].Input.Skidka),CZena,CMantissa,SRZena);
        Else SRZena:=L.DocumentElement[j].Input.Zena;{CAse}
        End;

GetZenaOplatiS:=SRZena;
End;



Var MarketFile : File;
    E : PBufSuperMarketType;
    i : Byte;
    StartPosKol,
    StartPosZ2,
    StartPosZ,
    StartPosRZ,
    StartPosOpl : Word;
    ws,s,ws1 : String;
    l : Boolean;
    jk,Count : Word;
Begin
 Assign(MarketFile,Path^.Dat.ToMarket+TDate+'.mrk');
 i:=IOResult;
 Reset(MarketFile,SizeOf(SuperMarketType));
 i:=IOResult;
 If i <> 0 Then
  Begin
   Exit;
  End;

 While Not(Eof(MarketFile)) Do
  Begin
   New(E,Init);
   ReadBufMarket(MarketFile,E,Count);
For jk:=1 To Count Do
Begin
  If (E^.Point.DAt[jk].Active) And
     (Not(E^.Point.DAt[jk].Realiz) Or ((E^.Point.DAt[jk].Realiz)And(E^.Point.DAt[jk].DocSelector in [5,6,7,8]))) Then
  If E^.Point.DAt[jk].OperatorSelector in [0,2] Then
  If (TestNoClientStatKod(E^.Point.DAt[jk].OperatorSelector,E^.Point.DAt[jk].ClientKod)) Then
  Begin


        Case E^.Point.DAt[jk].DocSelector Of
        0,1,2,5,7:Begin{розница}
                   StartPosKol:=1+1+CArtikul+1+CKol+1+CIZena+1+CIZena+1+CIZena+1+CIZena+1;
                   StartPosRZ :=1+1+CArtikul+1+CKol+1+CIZena+1+CIZena+1+CIZena+1+CIZena+1+CKol+1;
                   StartPosOpl:=1+1+CArtikul+1+CKol+1+CIZena+1+CIZena+1+CIZena+1+CIZena+1+CKol+1+CIZena+1;
                   StartPosZ  :=1+1+CArtikul+1+CKol+1+CIZena+1+CIZena+1+CIZena+1+CIZena+1+CKol+1+CIZena+1+CIZena+1;
                   StartPosZ2 :=1+1+CArtikul+1+CKol+1+CIZena+1+CIZena+1+CIZena+1+CIZena+1+CKol+1+CIZena+1+CIZena+1+CIZena+1;
                  End;
        3,4,6,8  :Begin{опт}
                   StartPosKol:=1+1+CArtikul+1;
                   StartPosRZ :=1+1+CArtikul+1+CKol+1;
                   StartPosOpl:=1+1+CArtikul+1+CKol+1+CIZena+1;
                   StartPosZ  :=1+1+CArtikul+1+CKol+1+CIZena+1+CIZena+1;
                   StartPosZ2 :=1+1+CArtikul+1+CKol+1+CIZena+1+CIZena+1+CIZena+1;
                  End;
        Else Continue;
        End;

    For i:=1 To E^.Point.DAt[jk].Amount Do
     Begin
      l:=ProdagaWindow;
      ProdagaWindow:=False;
If E^.Point.DAt[jk].OperatorSelector=0 Then
Begin
      If Not TestElement(E^.Point.DAt[jk].MArketElement[i].BazKod,RashetListClient) Then
       Begin
        s:=RashetListClient^.GetText(Location(RashetListClient,E^.Point.DAt[jk].MArketElement[i].BazKod,ProdagaWindow),
        RashetListClient^.List^.Count);
        RashetListClient^.List^.AtFree(Location(RashetListClient,E^.Point.DAt[jk].MarketElement[i].BazKod,ProdagaWindow));
        RashetListClient^.SetRange(RashetListClient^.List^.Count);
       End
       Else
        Begin
         s:='│'+E^.Point.DAt[jk].MarketElement[i].BazKod+'│'+ShablonOPTRozn;
        End;

        ws:=Copy(s,StartPosKol,CKol);
        Str((StrToInt(E^.Point.DAt[jk].MarketElement[i].Input.Kol)+StrToInt(ws)):CKol,ws);
        System.Delete(s,StartPosKol,CKol);
        System.Insert(ws,s,StartPosKol);

        {SummaRZ}
        ws1:=Copy(s,StartPosRZ,CIZena);
        MyStr((StrToInt(E^.Point.DAt[jk].MarketElement[i].Input.Kol)*StrToReal(E^.Point.DAt[jk].MarketElement[i].Input.R_Zena)
             +StrToReal(ws1)),CIZena,CMantissa,ws1);
        System.Delete(s,StartPosRZ,CIZena);
        System.Insert(ws1,s,StartPosRZ);

        {SummaOpl}
        ws1:=Copy(s,StartPosOpl,CIZena);
        MyStr((StrToInt(E^.Point.DAt[jk].MarketElement[i].Input.Kol)*StrToReal(GetZenaOplatiT(E^.Point.Dat[jk],i))
             +StrToReal(ws1)),CIZena,CMantissa,ws1);
        System.Delete(s,StartPosOpl,CIZena);
        System.Insert(ws1,s,StartPosOpl);

        {SummaZZ}
        ws1:=Copy(s,StartPosZ,CIZena);
        MyStr((StrToInt(E^.Point.DAt[jk].MarketElement[i].Input.Kol)*StrToReal(E^.Point.DAt[jk].MarketElement[i].Input.Zakupka)
             +StrToReal(ws1)),CIZena,CMantissaZ,ws1);
        System.Delete(s,StartPosZ,CIZena);
        System.Insert(ws1,s,StartPosZ);

        {SummaZZ2}
        ws1:=Copy(s,StartPosZ2,CIZena);
        MyStr((StrToInt(E^.Point.DAt[jk].MarketElement[i].Input.Kol)*
	   StrToReal(E^.Point.DAt[jk].MarketElement[i].Input.Zakupka2)
             +StrToReal(ws1)),CIZena,CMantissaZ,ws1);
        System.Delete(s,StartPosZ2,CIZena);
        System.Insert(ws1,s,StartPosZ2);

        RashetListClient^.List^.Insert(NewStr(s));
        RashetListClient^.SetRange(RashetListClient^.List^.Count);
End
Else
 Begin
      If Not TestElement(E^.Point.DAt[jk].MArketElement[i].BazKod,RashetListBarter) Then
       Begin
        s:=RashetListBarter^.GetText(Location(RashetListBarter,E^.Point.DAt[jk].MArketElement[i].BazKod,ProdagaWindow),
        RashetListBarter^.List^.Count);
        RashetListBarter^.List^.AtFree(Location(RashetListBarter,E^.Point.DAt[jk].MarketElement[i].BazKod,ProdagaWindow));
        RashetListBarter^.SetRange(RashetListBarter^.List^.Count);
       End
       Else
        Begin
         s:='│'+E^.Point.DAt[jk].MarketElement[i].BazKod+'│'+ShablonOPTRozn;
        End;

        ws:=Copy(s,StartPosKol,CKol);
        Str((StrToInt(E^.Point.DAt[jk].MarketElement[i].Input.Kol)+StrToInt(ws)):CKol,ws);
        System.Delete(s,StartPosKol,CKol);
        System.Insert(ws,s,StartPosKol);

        {SummaRZ}
        ws1:=Copy(s,StartPosRZ,CIZena);
        MyStr((StrToInt(E^.Point.DAt[jk].MarketElement[i].Input.Kol)*StrToReal(E^.Point.DAt[jk].MarketElement[i].Input.R_Zena)
             +StrToReal(ws1)),CIZena,CMantissa,ws1);
        System.Delete(s,StartPosRZ,CIZena);
        System.Insert(ws1,s,StartPosRZ);

        {SummaOpl}
        ws1:=Copy(s,StartPosOpl,CIZena);
        MyStr((StrToInt(E^.Point.DAt[jk].MarketElement[i].Input.Kol)*StrToReal(GetZenaOplatiT(E^.Point.DAt[jk],i))
             +StrToReal(ws1)),CIZena,CMantissa,ws1);
        System.Delete(s,StartPosOpl,CIZena);
        System.Insert(ws1,s,StartPosOpl);

        {SummaZZ}
        ws1:=Copy(s,StartPosZ,CIZena);
        MyStr((StrToInt(E^.Point.DAt[jk].MarketElement[i].Input.Kol)*StrToReal(E^.Point.DAt[jk].MarketElement[i].Input.Zakupka)
             +StrToReal(ws1)),CIZena,CMantissaZ,ws1);
        System.Delete(s,StartPosZ,CIZena);
        System.Insert(ws1,s,StartPosZ);

        {SummaZZ2}
        ws1:=Copy(s,StartPosZ2,CIZena);
        MyStr((StrToInt(E^.Point.DAt[jk].MarketElement[i].Input.Kol)*
	   StrToReal(E^.Point.DAt[jk].MarketElement[i].Input.Zakupka2)
             +StrToReal(ws1)),CIZena,CMantissaZ,ws1);
        System.Delete(s,StartPosZ2,CIZena);
        System.Insert(ws1,s,StartPosZ2);

        RashetListBarter^.List^.Insert(NewStr(s));
        RashetListBarter^.SetRange(RashetListBarter^.List^.Count);
 End;

      If TestElement(E^.Point.DAt[jk].MArketElement[i].BazKod,RashetList) Then
       Begin
        s:='│'+E^.Point.DAt[jk].MArketElement[i].BazKod+'│    0            0.00 '+Shablon1;
        RashetList^.List^.Insert(NewStr(s));
        RashetList^.SetRange(RashetList^.List^.Count);
       End;


End;

     StartPosKol:=1+1+CArtikul+1+CKol+1+CIZena+1+CIZena+1+CIZena+1+CIZena+1;
     StartPosRZ :=1+1+CArtikul+1+CKol+1+CIZena+1+CIZena+1+CIZena+1+CIZena+1+CKol+1;
     StartPosOpl:=1+1+CArtikul+1+CKol+1+CIZena+1+CIZena+1+CIZena+1+CIZena+1+CKol+1+CIZena+1;
     StartPosZ  :=1+1+CArtikul+1+CKol+1+CIZena+1+CIZena+1+CIZena+1+CIZena+1+CKol+1+CIZena+1+CIZena+1;
     StartPosZ2 :=1+1+CArtikul+1+CKol+1+CIZena+1+CIZena+1+CIZena+1+CIZena+1+CKol+1+CIZena+1+CIZena+1+CIZena+1;



    For i:=1 To E^.Point.DAt[jk].AmountS Do
     Begin
      l:=ProdagaWindow;
      ProdagaWindow:=False;
If E^.Point.DAt[jk].OperatorSelector=0 Then
Begin
      If Not TestElement(E^.Point.DAt[jk].DocumentElement[i].BazKod,RashetListClient) Then
       Begin
        s:=RashetListClient^.GetText(Location(RashetListClient,E^.Point.DAt[jk].DocumentElement[i].BazKod,ProdagaWindow),
        RashetListClient^.List^.Count);
        RashetListClient^.List^.AtFree(Location(RashetListClient,E^.Point.DAt[jk].DocumentElement[i].BazKod,ProdagaWindow));
        RashetListClient^.SetRange(RashetListClient^.List^.Count);
       End
       Else
        Begin
         s:='│'+E^.Point.DAt[jk].DocumentElement[i].BazKod+'│'+ShablonOPTRozn;
        End;

        ws:=Copy(s,StartPosKol,CKol);
        Str((StrToInt(E^.Point.DAt[jk].DocumentElement[i].Input.Kol)+StrToInt(ws)):CKol,ws);
        System.Delete(s,StartPosKol,CKol);
        System.Insert(ws,s,StartPosKol);

        {SummaRZ}
        ws1:=Copy(s,StartPosRZ,CIZena);
        MyStr((StrToInt(E^.Point.DAt[jk].DocumentElement[i].Input.Kol)*
	   StrToReal(E^.Point.DAt[jk].DocumentElement[i].Input.R_Zena)
             +StrToReal(ws1)),CIZena,CMantissa,ws1);
        System.Delete(s,StartPosRZ,CIZena);
        System.Insert(ws1,s,StartPosRZ);

        {SummaOpl}
        ws1:=Copy(s,StartPosOpl,CIZena);
        MyStr((StrToInt(E^.Point.DAt[jk].DocumentElement[i].Input.Kol)*StrToReal(GetZenaOplatiS(E^.Point.DAt[jk],i))
             +StrToReal(ws1)),CIZena,CMantissa,ws1);
        System.Delete(s,StartPosOpl,CIZena);
        System.Insert(ws1,s,StartPosOpl);

        {SummaZZ}
        ws1:=Copy(s,StartPosZ,CIZena);
        MyStr((StrToInt(E^.Point.DAt[jk].DocumentElement[i].Input.Kol)*
	   StrToReal(E^.Point.DAt[jk].DocumentElement[i].Input.Zakupka)
             +StrToReal(ws1)),CIZena,CMantissaZ,ws1);
        System.Delete(s,StartPosZ,CIZena);
        System.Insert(ws1,s,StartPosZ);

        {SummaZZ2}
        ws1:=Copy(s,StartPosZ2,CIZena);
        MyStr((StrToInt(E^.Point.DAt[jk].DocumentElement[i].Input.Kol)*
	   StrToReal(E^.Point.DAt[jk].DocumentElement[i].Input.Zakupka2)
             +StrToReal(ws1)),CIZena,CMantissaZ,ws1);
        System.Delete(s,StartPosZ2,CIZena);
        System.Insert(ws1,s,StartPosZ2);

        RashetListClient^.List^.Insert(NewStr(s));
        RashetListClient^.SetRange(RashetListClient^.List^.Count);
End
Else
 Begin
      If Not TestElement(E^.Point.DAt[jk].DocumentElement[i].BazKod,RashetListBarter) Then
       Begin
        s:=RashetListBarter^.GetText(Location(RashetListBarter,E^.Point.DAt[jk].DocumentElement[i].BazKod,ProdagaWindow),
        RashetListBarter^.List^.Count);
        RashetListBarter^.List^.AtFree(Location(RashetListBarter,E^.Point.DAt[jk].DocumentElement[i].BazKod,ProdagaWindow));
        RashetListBarter^.SetRange(RashetListBarter^.List^.Count);
       End
       Else
        Begin
         s:='│'+E^.Point.DAt[jk].DocumentElement[i].BazKod+'│'+ShablonOPTRozn;
        End;

        ws:=Copy(s,StartPosKol,CKol);
        Str((StrToInt(E^.Point.DAt[jk].DocumentElement[i].Input.Kol)+StrToInt(ws)):CKol,ws);
        System.Delete(s,StartPosKol,CKol);
        System.Insert(ws,s,StartPosKol);

        {SummaRZ}
        ws1:=Copy(s,StartPosRZ,CIZena);
        MyStr((StrToInt(E^.Point.DAt[jk].DocumentElement[i].Input.Kol)*
	   StrToReal(E^.Point.DAt[jk].DocumentElement[i].Input.R_Zena)
             +StrToReal(ws1)),CIZena,CMantissa,ws1);
        System.Delete(s,StartPosRZ,CIZena);
        System.Insert(ws1,s,StartPosRZ);

        {SummaOpl}
        ws1:=Copy(s,StartPosOpl,CIZena);
        MyStr((StrToInt(E^.Point.DAt[jk].DocumentElement[i].Input.Kol)*StrToReal(GetZenaOplatiS(E^.Point.DAt[jk],i))
             +StrToReal(ws1)),CIZena,CMantissa,ws1);
        System.Delete(s,StartPosOpl,CIZena);
        System.Insert(ws1,s,StartPosOpl);

        {SummaZZ}
        ws1:=Copy(s,StartPosZ,CIZena);
        MyStr((StrToInt(E^.Point.DAt[jk].DocumentElement[i].Input.Kol)*
	   StrToReal(E^.Point.DAt[jk].DocumentElement[i].Input.Zakupka)
             +StrToReal(ws1)),CIZena,CMantissaZ,ws1);
        System.Delete(s,StartPosZ,CIZena);
        System.Insert(ws1,s,StartPosZ);

        {SummaZZ2}
        ws1:=Copy(s,StartPosZ2,CIZena);
        MyStr((StrToInt(E^.Point.DAt[jk].DocumentElement[i].Input.Kol)*
	   StrToReal(E^.Point.DAt[jk].DocumentElement[i].Input.Zakupka2)
             +StrToReal(ws1)),CIZena,CMantissaZ,ws1);
        System.Delete(s,StartPosZ2,CIZena);
        System.Insert(ws1,s,StartPosZ2);

        RashetListBarter^.List^.Insert(NewStr(s));
        RashetListBarter^.SetRange(RashetListBarter^.List^.Count);
 End;

      If TestElement(E^.Point.DAt[jk].DocumentElement[i].BazKod,RashetList) Then
       Begin
        s:='│'+E^.Point.DAt[jk].MArketElement[i].BazKod+'│    0            0.00 '+Shablon1;
        RashetList^.List^.Insert(NewStr(s));
        RashetList^.SetRange(RashetList^.List^.Count);
       End;

End;{For}

   End;{условие фильтра}
End;{For Count}
 Dispose(E,Done);
  End;{While}
 Close(MArketFile);
 jk:=IOResult;
End;




Procedure CalcNewTodayPrihod(TDate:TDateString;
          Var RashetList,RashetList2:PBox);
Const
Shablon1=
'    0            0.00     0            0.00     0            0.00     0            0.00     0 '+
{12345│123456789012345│12345│123456789012345│12345│123456789012345│12345│123456789012345│12345}
'           0.00     0            0.00';
{123456789012345│12345│123456789012345│12345│123456789012345│12345│123456789012345│12345}


Shablon2='         0.0000          0.0000          0.0000          0.0000          0.0000'+
         {продажи коплате    продажи по З   продажи по З2   продажи скл З  продажи скл З2}
         '         0.0000          0.0000';

Const StartP=1+1+CArtikul+1+CIZena+1+CIZena+1+CIZena+1+CIZena+1+CIZena+1+CIZena+1;

Var
    MarketFile : File;
    E : PBufPrihodType;
    i : Byte;
    PrihodCZ,PrihodCZ2,PrihodSZ,PrihodSZ2,PrihodBZ,PrihodBZ2:AllSTr;
    ws,s,ws1 : String;
    l : Boolean;
    jk,count : Word;

Begin
 Assign(MarketFile,Path^.Dat.ToPrihod+TDate+'.prh');
 i:=IOResult;
 Reset(MarketFile,SizeOf(PrihodType));
 i:=IOResult;
 If i <> 0 Then
  Begin
   Exit;
  End;
 While Not(Eof(MarketFile)) Do
  Begin
   New(E,Init);
   Count:=0;
   ReadBufPrihod(MarketFile,E,Count);
 For jk:=1 To Count Do
   Begin
    For i:=1 To E^.Point.DAt[jk].Amount Do
     Begin
      If Not TestElement(E^.Point.DAt[jk].PrihodElement[i].BazKod,RashetList) Then
       Begin
        l:=ProdagaWindow;
        ProdagaWindow:=False;
        s:=RashetList^.GetText(Location(RashetList,E^.Point.DAt[jk].PrihodElement[i].BazKod,ProdagaWindow),
        RashetList^.List^.Count);
        DelSpace(E^.Point.DAt[jk].PrihodElement[i].Input.R_Zena);
        {Kol}
        ws:=Copy(s,1+1+CArtikul+1+CKol+1+CIzena+1+(CKol+1+CIZena+1)*E^.Point.DAt[jk].OperatorSelector,Ckol);
        Str((StrToInt(E^.Point.DAt[jk].PrihodElement[i].Input.Kol)+StrToInt(ws)):CKol,ws);
        {Summa}
        ws1:=Copy(s,1+1+CArtikul+1+CKol+1+CIzena+1+Ckol+1+(CKol+1+CIZena+1)*E^.Point.DAt[jk].OperatorSelector,CIZena);
        MyStr((StrToInt(E^.Point.DAt[jk].PrihodElement[i].Input.Kol)*StrToReal(E^.Point.DAt[jk].PrihodElement[i].Input.R_Zena)
             +StrToReal(ws1)),CIZena,CMantissa,ws1);
        ws:=ws+'│'+ws1;
        {Del BakString}
        Delete(s,1+1+CArtikul+1+CKol+1+CIzena+1+(CKol+1+CIZena+1)*E^.Point.DAt[jk].OperatorSelector,CKol+1+CIZena);
        {Inserting NewString}
        Insert(ws,s,1+1+CArtikul+1+CKol+1+CIzena+1+(CKol+1+CIZena+1)*E^.Point.DAt[jk].OperatorSelector);
        RashetList^.List^.AtFree(Location(RashetList,E^.Point.DAt[jk].PrihodElement[i].BazKod,ProdagaWindow));
        RashetList^.SetRange(RashetList^.List^.Count);
        RashetList^.List^.Insert(NewStr(s));
        RashetList^.SetRange(RashetList^.List^.Count);


        {обработка закупочных цен}
        s:=RashetList2^.GetText(Location(RashetList2,E^.Point.DAt[jk].PrihodElement[i].BazKod,ProdagaWindow),
        RashetList2^.List^.Count);
        PrihodCZ:='0.0000';
        MySTr(StrToReal(PrihodCZ),CIZena,CMAntissaZ,PrihodCZ);
	   PrihodCZ2:='0.0000';
        MySTr(StrToReal(PrihodCZ2),CIZena,CMAntissaZ,PrihodCZ2);
	   PrihodSZ:='0.0000';
        MySTr(StrToReal(PrihodSZ),CIZena,CMAntissaZ,PrihodSZ);
	   PrihodSZ2:='0.0000';
        MySTr(StrToReal(PrihodSZ2),CIZena,CMAntissaZ,PrihodSZ2);
	   PrihodBZ:='0.0000';
        MySTr(StrToReal(PrihodBZ),CIZena,CMAntissaZ,PrihodBZ);
	   PrihodBZ2:='0.0000';
        MySTr(StrToReal(PrihodBZ2),CIZena,CMAntissaZ,PrihodBZ2);


        Case E^.Point.DAt[jk].OperatorSelector Of
        0:Begin
           ws:=Copy(s,StartP,CIZena);
           ws1:=Copy(s,StartP+CIZena+1,CIZena);

           MyStr((StrToInt(E^.Point.DAt[jk].PrihodElement[i].Input.Kol)*
		        StrToReal(E^.Point.DAt[jk].PrihodElement[i].Input.Zakupka)
			  +StrToReal(ws)),CIZena,CMantissa,PrihodCZ);
           System.delete(s,StartP,CIZena);
           System.Insert(PrihodCZ,s,StartP);


           MyStr((StrToInt(E^.Point.DAt[jk].PrihodElement[i].Input.Kol)*
		        StrToReal(E^.Point.DAt[jk].PrihodElement[i].Input.Zakupka2)
                 +StrToReal(ws1)),CIZena,CMantissa,PrihodCZ2);
           System.delete(s,StartP+CIZena+1,CIZena);
           System.Insert(PrihodCZ2,s,StartP+CIZena+1);
          End;
        1:Begin
           ws:=Copy(s,StartP+CIZena+1+CIZena+1,CIZena);
           ws1:=Copy(s,StartP+CIZena+1+CIZena+1+CIZena+1,CIZena);

           MyStr((StrToInt(E^.Point.DAt[jk].PrihodElement[i].Input.Kol)*
		        StrToReal(E^.Point.DAt[jk].PrihodElement[i].Input.Zakupka)
			  +StrToReal(ws)),CIZena,CMantissa,PrihodSZ);
           System.delete(s,StartP+CIZena+1+CIZena+1,CIZena);
           System.Insert(PrihodSZ,s,StartP+CIZena+1+CIZena+1);

           MyStr((StrToInt(E^.Point.DAt[jk].PrihodElement[i].Input.Kol)*
		        StrToReal(E^.Point.DAt[jk].PrihodElement[i].Input.Zakupka2)
                 +StrToReal(ws1)),CIZena,CMantissa,PrihodSZ2);
           System.delete(s,StartP+CIZena+1+CIZena+1+CIZena+1,CIZena);
           System.Insert(PrihodSZ2,s,StartP+CIZena+1+CIZena+1+CIZena+1);
          End;

        2:Begin
           ws:=Copy(s,StartP+CIZena+1+CIZena+1+CIZena+1+CIZena+1,CIZena);
           ws1:=Copy(s,StartP+CIZena+1+CIZena+1+CIZena+1+CIZena+1+CIZena+1,CIZena);

           MyStr((StrToInt(E^.Point.DAt[jk].PrihodElement[i].Input.Kol)*
		        StrToReal(E^.Point.DAt[jk].PrihodElement[i].Input.Zakupka)
			  +StrToReal(ws)),CIZena,CMantissa,PrihodBZ);
           System.delete(s,StartP+CIZena+1+CIZena+1+CIZena+1+CIZena+1,CIZena);
           System.Insert(PrihodBZ,s,StartP+CIZena+1+CIZena+1+CIZena+1+CIZena+1);

           MyStr((StrToInt(E^.Point.DAt[jk].PrihodElement[i].Input.Kol)*
		        StrToReal(E^.Point.DAt[jk].PrihodElement[i].Input.Zakupka2)
                 +StrToReal(ws1)),CIZena,CMantissa,PrihodBZ2);
           System.delete(s,StartP+CIZena+1+CIZena+1+CIZena+1+CIZena+1+CIZena+1,CIZena);
           System.Insert(PrihodBZ2,s,StartP+CIZena+1+CIZena+1+CIZena+1+CIZena+1+CIZena+1);
          End;
        Else;
        End;

        RashetList2^.List^.AtFree(Location(RashetList2,E^.Point.DAt[jk].PrihodElement[i].BazKod,ProdagaWindow));
        RashetList2^.SetRange(RashetList2^.List^.Count);
        RashetList2^.List^.Insert(NewStr(s));
        RashetList2^.SetRange(RashetList2^.List^.Count);
        {конец обработки закупочных цен}

        ProdagaWindow:=l;
       End{If TestElement Then}
      Else
       Begin{position not found in List}
        s:='│'+E^.Point.DAt[jk].PrihodElement[i].BazKod+'│    0            0.00 '+Shablon1;
        Str(StrToInt(E^.Point.DAt[jk].PrihodElement[i].Input.Kol):CKol,ws);
        MyStr(StrToInt(E^.Point.DAt[jk].PrihodElement[i].Input.Kol)*StrToReal(E^.Point.DAt[jk].PrihodElement[i].Input.R_Zena)
               ,CIZena,CMantissa,ws1);
        ws:=ws+'│'+ws1;
        Delete(s,1+1+CArtikul+1+CKol+1+CIzena+1+(CKol+1+CIZena+1)*E^.Point.DAt[jk].OperatorSelector,CKol+1+CIZena);
        {Inserting NewString}
        Insert(ws,s,1+1+CArtikul+1+CKol+1+CIzena+1+(CKol+1+CIZena+1)*E^.Point.DAt[jk].OperatorSelector);
        RashetList^.List^.Insert(NewStr(s));
        RashetList^.SetRange(RashetList^.List^.Count);


        PrihodCZ:='0.0000';
        MySTr(StrToReal(PrihodCZ),CIZena,CMAntissaZ,PrihodCZ);
	   PrihodCZ2:='0.0000';
        MySTr(StrToReal(PrihodCZ2),CIZena,CMAntissaZ,PrihodCZ2);
	   PrihodSZ:='0.0000';
        MySTr(StrToReal(PrihodSZ),CIZena,CMAntissaZ,PrihodSZ);
	   PrihodSZ2:='0.0000';
        MySTr(StrToReal(PrihodSZ2),CIZena,CMAntissaZ,PrihodSZ2);
	   PrihodBZ:='0.0000';
        MySTr(StrToReal(PrihodBZ),CIZena,CMAntissaZ,PrihodBZ);
	   PrihodBZ2:='0.0000';
        MySTr(StrToReal(PrihodBZ2),CIZena,CMAntissaZ,PrihodBZ2);

        Case E^.Point.DAt[jk].OperatorSelector Of
        0:Begin
           MyStr(StrToInt(E^.Point.DAt[jk].PrihodElement[i].Input.Kol)*
		 StrToReal(E^.Point.DAt[jk].PrihodElement[i].Input.Zakupka)
          ,CIZena,CMantissaZ,PrihodCZ);
           MyStr(StrToInt(E^.Point.DAt[jk].PrihodElement[i].Input.Kol)*
		 StrToReal(E^.Point.DAt[jk].PrihodElement[i].Input.Zakupka2)
          ,CIZena,CMantissaZ,PrihodCZ2);
          End;
        1:Begin
           MyStr(StrToInt(E^.Point.DAt[jk].PrihodElement[i].Input.Kol)*
		 StrToReal(E^.Point.DAt[jk].PrihodElement[i].Input.Zakupka)
          ,CIZena,CMantissaZ,PrihodSZ);
           MyStr(StrToInt(E^.Point.DAt[jk].PrihodElement[i].Input.Kol)*
		 StrToReal(E^.Point.DAt[jk].PrihodElement[i].Input.Zakupka2)
          ,CIZena,CMantissaZ,PrihodSZ2);
          End;
        2:Begin
           MyStr(StrToInt(E^.Point.DAt[jk].PrihodElement[i].Input.Kol)*
		 StrToReal(E^.Point.DAt[jk].PrihodElement[i].Input.Zakupka)
          ,CIZena,CMantissaZ,PrihodBZ);
           MyStr(StrToInt(E^.Point.DAt[jk].PrihodElement[i].Input.Kol)*
		 StrToReal(E^.Point.DAt[jk].PrihodElement[i].Input.Zakupka2)
          ,CIZena,CMantissaZ,PrihodBZ2);
          End;
        Else;
        End;

       s:='│'+E^.Point.DAt[jk].PrihodElement[i].BazKod+' '+Shablon2+' '+
	  PrihodCZ+' '+PrihodCZ2+' '+PrihodSZ+' '+PrihodSZ2+' '+PrihodBZ+' '+PrihodBZ2;
       RashetList2^.List^.Insert(NewStr(s));
       RashetList2^.SetRange(RashetList2^.List^.Count);

       End;{Else}
     End;{For}
   End;
 Dispose(E,Done);
  End;{While}
 Close(MArketFile);
End;


procedure TLinkNGTDWindow.Start(LinkArt:ArtikulStr);
var
  R : TRect;
  Control : PView;
  RazdelFile : RazdelFileType;
  RazdelElement : PRazdelType;
  FSkl : File;
  Count,C,i : Word;
  BF : File;
  BE : PBufSkladTypeNew;
  SArt,SKol : AllStr;
  s : String;
  st : TMyString;
  Find : Boolean;
begin

LArt:=LinkArt;


R.Assign(0,0,0,0);
NoScreenList1 := New(PBox, Init(R, 1, Nil));
NoScreenList1^.NewList(New(PTextCollection, Init(0,1)));


Assign(RazdelFile,Path^.Dat.ToRazdel+'razdel.db');
i:=IOResult;
Reset(RazdelFile);
i:=IOResult;
Find:=False;
If i=0 Then
 Begin
  {DInfoMsg('Идет поиск связанных наименований...',True);}
  New(RazdelElement,Init);
  While Not(Eof(Razdelfile)) Do
   Begin
    Read(RazdelFile,RazdelElement^.Dat);

    DInfoMsgShkala('Идет поиск связанных с объектом наименований в разделе '+RazdelElement^.Dat.Kod+'. Ждите...',
    1,EmployRazdel,StrToInt(RazdelElement^.Dat.Kod)+1);
    If (RazdelElement^.Dat.Employ) And (Razdelelement^.Dat.EnableDoc=0) Then
     Begin
      Assign(bf,Path^.Dat.ToIndex+RazdelElement^.Dat.Kod+'.kdx');
      i:=ioresult;
      reset(bf,SizeOf(SkladTypeNew));
      i:=ioresult;
      If i=0 Then
       Begin
        While Not(Eof(bf)) Do
         Begin
          New(be,Init);
          ReadBufNewSklad(Bf,be,Count);
          For c:=1 To Count Do
Begin
          If Be^.Point.Dat[c].Employ Then
          If Be^.Point.Dat[c].NGTDKod=StrToInt(LinkArt) Then
           Begin
            Find:=True;
            s[0]:=#0;
            st:=Be^.Point.Dat[c].Name;
            DelSpaceRight(st);
            s:=st;
            st:=Be^.Point.Dat[c].Name2;
            DelSpaceRight(st);
            s:=s+' '+st;
            Format(s,CName+1+CNAme);

            SKol:=IntToStr(Be^.Point.Dat[c].Kol,CKOl);
            RFormat(SKol,CKol);
            SArt:=IntToStr(Be^.Point.Dat[c].BazKod,CArtikul);
            RFormatZerro(SArt,CArtikul);
            st:=CalcPack(SArt,SKol);
            DelSpace(st);
            RFormat(st,CPAck);
            s:=s+'│'+SArt+'│'+SKol+'│'+st;

            SArt:=IntToStr(Be^.Point.Dat[c].NMarkaKod,CArtikul);
            RFormatZerro(SArt,CArtikul);
            St:=GetMarkaField(FMarka,SArt);
            st:=St+' ['+SArt+']';
            Format(st,CNGTD);
            s:=s+'│'+st;

            SArt:=IntToStr(Be^.Point.Dat[c].NExpertKod,CArtikul);
            RFormatZerro(SArt,CArtikul);
            St:=GetExpertField(FExpert,SArt);
            st:=St+' ['+SArt+']';
            Format(st,CNGTD);
            s:=s+'│'+st;


            SArt:=IntToStr(Be^.Point.Dat[c].NSertif,CArtikul);
            RFormatZerro(SArt,CArtikul);
            St:=GetIdField(FFFName,SArt);
            st:=St+' ['+SArt+']';
            Format(st,CNSertif);
            s:=s+'│'+st;

            SArt:=IntToStr(Be^.Point.Dat[c].FirmaPostKod,CClientKod);
            RFormatZerro(SArt,CClientKod);
            St:=GetFirmaPostField(FFirmaPost,SArt);
            st:=St+' ['+SArt+']';
            Format(st,CNSertif);
            s:=s+'│'+st;


            SArt:=IntToStr(Be^.Point.Dat[c].BazKod,CArtikul);
            RFormatZerro(SArt,CArtikul);
            SArt:=GetIDField(FGroup,SArt);
            RFormatZerro(SArt,CClientKod);
            St:=GetGroupField(FName,SArt);
            st:=St+' ['+SArt+']';
            Format(st,CNSertif);
            s:=s+'│'+st;

            {
            St:=Be^.Point.Dat[c].Godnost;
            Format(st,CDate);
            s:=s+'│'+st;
            }

      If NoScreenList1^.List^.Count>=MaxCollectionSize-1 Then
      Begin
       MessageBox(^M+#3+'Переполнение коллекции!',Nil,mfError+mfCancelButton);
       Break;
      End;


            NoScreenList1^.List^.Insert(NewStr(s));
            NoScreenList1^.SetRange(NoScreenList1^.List^.Count);
           End;
End;{For}
         Dispose(BE,Done);
         End;{While}
         System.Close(BF);
       End
       Else
        Begin
            NoInfoMsg;
            MessageBox(^M+#3+'Ошибка открытия файла разделов '+Path^.Dat.ToSklad+RazdelElement^.Dat.Kod+'.db!'+
            ClicProgrammer^,Nil,mfError+mfCancelButton);
        End;
     End;
   End;
  NoInfoMsg;
  System.Close(RazdelFile);
  Dispose(RazdelElement,Done);
 End
Else
Begin
 MessageBox(^M+#3+'Ошибка открытия файла разделов '+Path^.Dat.ToRazdel+'razdel.db! '+
            ClicProgrammer^,Nil,
            mfError+mfCancelButton);
 Exit;
End;


If Not(Find) Then
 Begin
  Dispose(NoScreenList1,Done);
  MessageBox(^M+#3'С данным объектом не связано ни одно наименование товара!',
             Nil,mfError+mfCancelButton);
  Exit;
 End;

R.Assign(1, 2, 79, 24);
New(LinkNGTDWindow, Init(R, ''));
LinkNGTDWindow^.Options := LinkNGTDWindow^.Options or ofCenterX or ofCenterY;
LinkNGTDWindow^.HelpCtx:=$F941;

R.Assign(77, 4, 78, 16);
Control := New(PScrollBar, Init(R));
LinkNGTDWindow^.Insert(Control);

R.Assign(1, 4, 77, 16);
LinkList := New(PBox, Init(R, 1, PScrollbar(Control)));
LinkList^.NewList(New(PTextCollection, Init(0,1)));

If NoScreenList1^.List^.Count-1>=0 Then
 For c:=0 To NoScreenList1^.List^.Count-1 Do
  Begin
   s:=NoScreenList1^.GetText(c,NoScreenList1^.List^.Count);
   LinkList^.List^.Insert(NewStr(s));
   LinkList^.SetRange(LinkList^.List^.Count);
  End;
LinkList^.FocusItem(0);
LinkNGTDWindow^.Insert(LinkList);


  R.Assign(1, 3, 77, 4);
  LinkNGTDWindow^.Insert(New(PLabel, Init(R, 'Наименования товара, связанные с ГТД                   Код  Колич  Упаковок',
  LinkList)));

R.Assign(14, 1, 75, 2);
st:=GetNGTDField(FNGTD,LinkArt);
DelSpaceRight(st);
Control := New(PColoredText, Init(R, st+'('+LinkArt+')', $7E));
LinkNGTDWindow^.Insert(Control);

R.Assign(3, 1, 14, 2);
Control := New(PColoredText, Init(R, '       ГТД:', $74));
LinkNGTDWindow^.Insert(Control);

R.Assign(2, 21, 25, 22);
ControlCount := New(PColoredText, Init(R, 'Всего позиций: '+IntToStr(LinkList^.List^.Count,CLitr+1), $4E));
LinkNGTDWindow^.Insert(ControlCount);

R.Assign(1, 16, 16, 17);
Control := New(PColoredText, Init(R, '         Марка:', $74));
LinkNGTDWindow^.Insert(Control);

R.Assign(16, 16, 56, 17);
ControlMarka := New(PColoredText, Init(R, '???', $7E));
LinkNGTDWindow^.Insert(ControlMarka);

R.Assign(16, 17, 77, 18);
ControlNGTD := New(PColoredText, Init(R, '???', $7E));
LinkNGTDWindow^.Insert(ControlNGTD);

R.Assign(1, 17, 16, 18);
Control := New(PColoredText, Init(R, Expert_RegNom^+':', $74));
LinkNGTDWindow^.Insert(Control);

R.Assign(1, 18, 16, 19);
Control := New(PColoredText, Init(R, '    Сертификат:', $74));
LinkNGTDWindow^.Insert(Control);

R.Assign(16, 18, 77, 19);
ControlVirabotano := New(PColoredText, Init(R, '???', $7E));
LinkNGTDWindow^.Insert(ControlVirabotano);

R.Assign(16, 19, 77, 20);
ControlDo := New(PColoredText, Init(R, '???', $7E));
LinkNGTDWindow^.Insert(ControlDo);

R.Assign(1, 19, 16, 20);
Control := New(PColoredText, Init(R, 'Фирма-производ:', $74));
LinkNGTDWindow^.Insert(Control);


R.Assign(1, 20, 16, 21);
Control := New(PColoredText, Init(R, '        Группа:', $74));
LinkNGTDWindow^.Insert(Control);

R.Assign(16, 20, 77, 21);
ControlGroup := New(PColoredText, Init(R, '???', $7E));
LinkNGTDWindow^.Insert(ControlGroup);



VidOtbora:=0;

R.Assign(40, 21, 76, 22);
ControlVidOtboraG := New(PRadioButtons, Init(R,
  NewSItem('~В~се',
  NewSItem('Не ну~л~евое количество', Nil))));
LinkNGTDWindow^.Insert(ControlVidOtboraG);

ControlVidOtboraG^.SetData(VidOtbora);
{
  R.Assign(28, 19, 40, 20);
  LinkNGTDWindow^.Insert(New(PLabel, Init(R, 'Вид отбора:', ControlVidOtboraG)));
}
LinkNGTDWindow^.SelectNext(False);

CurrentLine[0]:=#0;
Refresh;
CurrentLine[0]:=#0;

c:=Desktop^.ExecView(LinkNGTDWindow);

Dispose(NoScreenList1,Done);
Dispose(Control,Done);
Dispose(LinkNGTDWindow,Done);

End;





procedure TLinkNGTDWindow.FormReport;
Var txt : Text;
    c,w : Word;
   Space: AllStr;
      s : String;

begin
Space:='       ';
DInfoMsg('Формирую отчет.Ждите...',True);
 Assign(txt,Path^.Dat.ToTemp+'linkgtd.txt');
 c:=IOResult;
 Rewrite(txt);
 c:=IOResult;
 If c<>0 Then
  Begin
   MessageBox(#3'Ошибка создания '+Path^.Dat.ToTemp+'linkgtd.txt',Nil,mfError+mfCancelButton);
   Exit;
  End;

 Writeln(txt,Header+Space+'Склад: ',GetClientField(FClient,Rek^.Dat.Kod,1)+'  Оператор: '+CurrentPassword+' EYE & 1997-00');
 Writeln(txt);
 Writeln(txt,Space+GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+'         ОТЧЕТ ПО НАИМЕНОВАНИЯМ ТОВАРА, СВЯЗАННЫМ С ГТД'+
 GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]);
 Writeln(txt,Space+GetNGTDField(FName,LArt)+' ('+LArt+')');
 Write(txt,Space+'Вид отбора:');

 Case VidOtbora Of
 0:Writeln(txt,'Все');
 1:Writeln(txt,'Не нулевое количество');
 Else Writeln(txt);
 End;
 Writeln(txt,Space+'┌────────────────────────────────────────────────────┬─────┬─────┬─────────┐');
 Writeln(txt,Space+'│Наименования товара, связанные с объектом           │ Код │Колич│ Упаковок│');
 Writeln(txt,Space+'└────────────────────────────────────────────────────┴─────┴─────┴─────────┘'+HeaderStop);

 For c:=0 To LinkList^.List^.Count-1 Do
  Begin
   s:=LinkList^.GetText(c,LinkList^.List^.Count);
   s[0]:=Chr(1+CNAme+1+CNAme+1+CArtikul+1+CKol+1+CPAck);

   While Pos('│',s)>0 Do
    Begin
     w:=Pos('│',s);
     System.Delete(s,w,1);
     System.Insert(' ',s,w);
    End;

   Writeln(txt,Space+s)
  End;
 Writeln(txt,Space+'────────────────────────────────────────────────────────────────────────────');
 Writeln(txt,Space+' Всего позиций: ',LinkList^.List^.Count:6);
 Writeln(txt);
 Writeln(txt,Space,'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
 Writeln(txt,Space+'============================================================================');
 System.Close(txt);
NoInfoMsg;
ReportNew(Path^.Dat.ToTemp+'linkgtd.txt','',1,False,False);
End;


procedure TLinkNGTDWindow.Refresh;
Var SKol : ArtikulStr;
    c : Word;
    R : TRect;
    s : String;
begin
DInfoMsg('Минуточку...',True);
LinkList^.NewList(Nil);
LinkList^.NewList(New(PTextCollection, Init(0,1)));

If NoScreenList1^.List^.Count>0 Then
 For c:=0 To NoScreenList1^.List^.Count-1 Do
  Begin
   s:=NoScreenList1^.GetText(c,NoScreenList1^.List^.Count);
   SKol:=Copy(s,1+CNAme+1+CName+1+CArtikul+1,CKol);
   If ((StrToInt(Skol)>0)And (VidOtbora=1)) Or (VidOtbora=0) Then
   Begin
    LinkList^.List^.Insert(NewStr(s));
    LinkList^.SetRange(LinkList^.List^.Count);
   End;
  End;
LinkList^.FocusItem(0);

Dispose(ControlCount,Done);
R.Assign(2, 21, 25, 22);
ControlCount := New(PColoredText, Init(R, 'Всего позиций: '+IntToStr(LinkList^.List^.Count,CLitr+1), $4E));
LinkNGTDWindow^.Insert(ControlCount);
NoInfoMsg;

CurrentLine[0]:=#0;

End;

procedure TLinkNGTDWindow.HandleEvent(var Event: TEvent);

procedure Calculator;
begin
  Calc^.Start;
end;

Var Prom : Word;
    Art : ArtikulStr;
Begin

Case Event.What Of
 evCommand :
   Case Event.Command Of
        cmLocalCalc:Calculator;
        cmReestrReport:Begin
                        If LinkList^.List^.Count>0 Then FormReport;
                        ClearEvent(Event);
                       End;
 cmFindLink:Begin
             Art:=Copy(LinkList^.GetText(LinkList^.Focused,LinkList^.List^.Count),1+CName+1+CName+1,Cartikul);
             Lnk^.Start(Art);
             ClearEvent(Event);
            End;

 cmViewPrihodTovar:
            Begin
             Art:=Copy(LinkList^.GetText(LinkList^.Focused,LinkList^.List^.Count),1+CName+1+CName+1,Cartikul);
             FP^.FindScreenPrh(Art);
             ClearEvent(Event);
            End;

        Else;
        End;
 Else;
 End;

inherited HandleEvent(Event);

 If (Desktop^.Current=PView(LinkNGTDWindow)) And (Event.What <> EvKeyDown) Then
     Begin
          if (ControlVidOtboraG^.State and sfFocused <> 0)Then
              Begin
               ControlVidOtboraG^.GetData(Prom);
               If Prom <> VidOtbora Then
               Begin
                  VidOtbora:=Prom;
                  Refresh;
                  Redraw;
               End;
              End;
      DrawCurrent;
     End;
End;



Procedure TLinkNGTDWindow.DrawCurrent;
Var st : String;
    R : TRect;
Begin
if (LinkList^.List<>Nil)And(LinkList^.List^.Count>=1) Then
 Begin
  st:=LinkList^.GetText(LinkList^.Focused,LinkList^.List^.Count);
  If st <> CurrentLine Then
   Begin
    CurrentLine:=St;
    st:=Copy(CurrentLine,1+CName+1+CName+1+CArtikul+1+CKol+1+CPack+1,CNSertif);
    DelSpaceRight(st);
    Dispose(ControlMarka,Done);
    R.Assign(16, 16, 56, 17);
    ControlMarka := New(PColoredText, Init(R, st, $7E));
    LinkNGTDWindow^.Insert(ControlMarka);

    st:=Copy(CurrentLine,1+CName+1+CName+1+CArtikul+1+CKol+1+CPack+1+CNSertif+1,
    CNSertif);
    DelSpaceRight(st);
    Dispose(ControlNGTD,Done);
    R.Assign(16, 17, 77, 18);
    ControlNGTD := New(PColoredText, Init(R, st, $7E));
    LinkNGTDWindow^.Insert(ControlNGTD);

    st:=Copy(CurrentLine,1+CName+1+CName+1+CArtikul+1+CKol+1+CPack+1+CNSertif+1+
    CNSertif+1,CNSertif);
    DelSpaceRight(st);
    Dispose(ControlVirabotano,Done);
    R.Assign(16, 18, 77, 19);
    ControlVirabotano := New(PColoredText, Init(R, St, $7E));
    LinkNGTDWindow^.Insert(ControlVirabotano);

    st:=Copy(CurrentLine,1+CName+1+CName+1+CArtikul+1+CKol+1+CPack+1+CNSertif+1+
    CNSertif+1+CNSertif+1,CNSertif);
    DelSpaceRight(st);
    Dispose(ControlDo,Done);
    R.Assign(16, 19, 77, 20);
    ControlDo := New(PColoredText, Init(R, St, $7E));
    LinkNGTDWindow^.Insert(ControlDo);


    st:=Copy(CurrentLine,1+CName+1+CName+1+CArtikul+1+CKol+1+CPack+1+CNSertif+1+
    CNSertif+1+CNSertif+1+CNSertif+1,CNSertif);
    DelSpaceRight(st);
    Dispose(ControlGroup,Done);
    R.Assign(16, 20, 77, 21);
    ControlGroup := New(PColoredText, Init(R, St, $7E));
    LinkNGTDWindow^.Insert(ControlGroup);
   End;
 End
 Else
  Begin
   PStaticText(ControlMarka)^.GetText(st);
   If St<>'???' Then
   Begin
   Dispose(ControlMarka,Done);
   R.Assign(16, 16, 56, 17);
   ControlMarka := New(PColoredText, Init(R, '???', $7E));
   LinkNGTDWindow^.Insert(ControlMarka);

   Dispose(ControlNGTD,Done);
   R.Assign(7, 17, 47, 18);
   ControlNGTD := New(PColoredText, Init(R, '???', $7E));
   LinkNGTDWindow^.Insert(ControlNGTD);

   Dispose(ControlVirabotano,Done);
   R.Assign(16, 18, 77, 19);
   ControlVirabotano := New(PColoredText, Init(R, '???', $7E));
   LinkNGTDWindow^.Insert(ControlVirabotano);

   Dispose(ControlDo,Done);
   R.Assign(16, 19, 77, 20);
   ControlDo := New(PColoredText, Init(R, '???', $7E));
   LinkNGTDWindow^.Insert(ControlDo);

   Dispose(ControlGroup,Done);
   R.Assign(16, 20, 77, 21);
   ControlGroup := New(PColoredText, Init(R, '???', $7E));
   LinkNGTDWindow^.Insert(ControlGroup);
   End;
  End;
End;


Destructor TLinkNGTDWindow.Done;
Begin
TDialog.Done;
End;


Function FindSertifikat(LinkArt:ArtikulStr;SArt:ArtikulStr;Var SertifCod:ArtikulStr):Boolean;
var
  R : TRect;
  Control : PView;
  RazdelFile : RazdelFileType;
  RazdelElement : PRazdelType;
  FSkl : File;
  Count,C,i : Word;
  BF : File;
  BE : PBufSkladTypeNew;
  s : String;
  st : TMyString;
  SName,SNameFind :String[CName+1+CNAme];
  Find : Boolean;
Begin
FindSertifikat:=False;
SertifCod:=NoSertifStr;
SName:=getIdField(FFFName,SArt);
DelSpace(SName);
Assign(RazdelFile,Path^.Dat.ToRazdel+'razdel.db');
i:=IOResult;
Reset(RazdelFile);
i:=IOResult;
Find:=False;
If i=0 Then
 Begin
  New(RazdelElement,Init);
  While Not(Eof(Razdelfile)) And Not(Find) Do
   Begin
    Read(RazdelFile,RazdelElement^.Dat);

    DInfoMsgShkala('Идет поиск связанных с объектом сертификатов в разделе '+RazdelElement^.Dat.Kod+'. Ждите...',
    1,EmployRazdel,StrToInt(RazdelElement^.Dat.Kod)+1);
    If (RazdelElement^.Dat.Employ) And (Razdelelement^.Dat.EnableDoc=0) Then
     Begin
      Assign(bf,Path^.Dat.ToIndex+RazdelElement^.Dat.Kod+'.kdx');
      i:=ioresult;
      reset(bf,SizeOf(SkladTypeNew));
      i:=ioresult;
      If i=0 Then
       Begin
        While Not(Eof(bf)) And Not(Find) Do
         Begin
          New(be,Init);
          ReadBufNewSklad(Bf,be,Count);
          For c:=1 To Count Do
Begin
          If Be^.Point.Dat[c].Employ Then
          If Be^.Point.Dat[c].BazKod<>StrToInt(SArt) Then
          If Be^.Point.Dat[c].NMarkaKod=StrToInt(LinkArt) Then
           Begin
            SNameFind[0]:=#0;
            SNameFind:=Be^.Point.Dat[c].Name+' '+Be^.Point.Dat[c].Name2;
            DelSpace(SNameFind);
            If (SName=SNameFind) Then
            Begin
             Find:=True;
             SertifCod:=IntToStr(Be^.Point.Dat[c].NSertif,CArtikul);
             RFormatZerro(SertifCod,CArtikul);
             FindSertifikat:=True;
             Break;{}
            End;
           End;
End;{For}
         Dispose(BE,Done);
         End;{While}
i:=IOResult;
         System.Close(BF);
i:=IOResult;
       End
       Else
        Begin
            NoInfoMsg;
            MessageBox(^M+#3+'Ошибка открытия файла разделов '+Path^.Dat.ToSklad+RazdelElement^.Dat.Kod+'.db!'+
            ClicProgrammer^,Nil,mfError+mfCancelButton);
        End;
     End;
   End;
  NoInfoMsg;
  System.Close(RazdelFile);
  Dispose(RazdelElement,Done);
 End
Else
Begin
 MessageBox(^M+#3+'Ошибка открытия файла разделов '+Path^.Dat.ToRazdel+'razdel.db! '+
            ClicProgrammer^,Nil,
            mfError+mfCancelButton);
 Exit;
End;
End;




procedure TLinkSpecMarkaWindow.Start(LinkArt:ArtikulStr);
var
  R : TRect;
  Control : PView;
  RazdelFile : RazdelFileType;
  RazdelElement : PRazdelType;
  FSkl : File;
  Count,C,i : Word;
  BF : File;
  BE : PBufSkladTypeNew;
  SArt,SKol : AllStr;
  s : String;
  st : TMyString;
  Find : Boolean;
begin

LArt:=LinkArt;


R.Assign(0,0,0,0);
NoScreenList1 := New(PBox, Init(R, 1, Nil));
NoScreenList1^.NewList(New(PTextCollection, Init(0,1)));


Assign(RazdelFile,Path^.Dat.ToRazdel+'razdel.db');
i:=IOResult;
Reset(RazdelFile);
i:=IOResult;
Find:=False;
If i=0 Then
 Begin
  {DInfoMsg('Идет поиск связанных наименований...',True);}
  New(RazdelElement,Init);
  While Not(Eof(Razdelfile)) Do
   Begin
    Read(RazdelFile,RazdelElement^.Dat);

    DInfoMsgShkala('Идет поиск связанных с объектом наименований в разделе '+RazdelElement^.Dat.Kod+'. Ждите...',
    1,EmployRazdel,StrToInt(RazdelElement^.Dat.Kod)+1);
    If (RazdelElement^.Dat.Employ) And (Razdelelement^.Dat.EnableDoc=0) Then
     Begin
      Assign(bf,Path^.Dat.ToIndex+RazdelElement^.Dat.Kod+'.kdx');
      i:=ioresult;
      reset(bf,SizeOf(SkladTypeNew));
      i:=ioresult;
      If i=0 Then
       Begin
        While Not(Eof(bf)) Do
         Begin
          New(be,Init);
          ReadBufNewSklad(Bf,be,Count);
          For c:=1 To Count Do
Begin
          If Be^.Point.Dat[c].Employ Then
          If Be^.Point.Dat[c].NSpecMarkaKod=StrToInt(LinkArt) Then
           Begin
            Find:=True;
            s[0]:=#0;
            st:=Be^.Point.Dat[c].Name;
            DelSpaceRight(st);
            s:=st;
            st:=Be^.Point.Dat[c].Name2;
            DelSpaceRight(st);
            s:=s+' '+st;
            Format(s,CName+1+CNAme);

            SKol:=IntToStr(Be^.Point.Dat[c].Kol,CKOl);
            RFormat(SKol,CKol);
            SArt:=IntToStr(Be^.Point.Dat[c].BazKod,CArtikul);
            RFormatZerro(SArt,CArtikul);
            st:=CalcPack(SArt,SKol);
            DelSpace(st);
            RFormat(st,CPAck);
            s:=s+'│'+SArt+'│'+SKol+'│'+st;

            SArt:=IntToStr(Be^.Point.Dat[c].NMarkaKod,CArtikul);
            RFormatZerro(SArt,CArtikul);
            St:=GetMarkaField(FMarka,SArt);
            st:=St+' ['+SArt+']';
            Format(st,CMarka);
            s:=s+'│'+st;

            SArt:=IntToStr(Be^.Point.Dat[c].NExpertKod,CArtikul);
            RFormatZerro(SArt,CArtikul);
            St:=GetExpertField(FExpert,SArt);
            st:=St+' ['+SArt+']';
            Format(st,CExpert);
            s:=s+'│'+st;


            SArt:=IntToStr(Be^.Point.Dat[c].NGTDKOD,CArtikul);
            RFormatZerro(SArt,CArtikul);
            St:=GetNGTDField(FNGTD,SArt);
            st:=St+' ['+SArt+']';
            Format(st,CNGTD);
            s:=s+'│'+st;

            SArt:=IntToStr(Be^.Point.Dat[c].FirmaPostKod,CClientKod);
            RFormatZerro(SArt,CClientKod);
            St:=GetFirmaPostField(FFirmaPost,SArt);
            st:=St+' ['+SArt+']';
            Format(st,CNSertif);
            s:=s+'│'+st;


            SArt:=IntToStr(Be^.Point.Dat[c].BazKod,CArtikul);
            RFormatZerro(SArt,CArtikul);
            SArt:=GetIDField(FGroup,SArt);
            RFormatZerro(SArt,CClientKod);
            St:=GetGroupField(FName,SArt);
            st:=St+' ['+SArt+']';
            Format(st,CNSertif);
            s:=s+'│'+st;

            {
            St:=Be^.Point.Dat[c].Godnost;
            Format(st,CDate);
            s:=s+'│'+st;
            }
      If NoScreenList1^.List^.Count>=MaxCollectionSize-1 Then
      Begin
       MessageBox(^M+#3+'Переполнение коллекции!',Nil,mfError+mfCancelButton);
       Break;
      End;

            NoScreenList1^.List^.Insert(NewStr(s));
            NoScreenList1^.SetRange(NoScreenList1^.List^.Count);
           End;
End;{For}
         Dispose(BE,Done);
         End;{While}
         System.Close(BF);
       End
       Else
        Begin
            NoInfoMsg;
            MessageBox(^M+#3+'Ошибка открытия файла разделов '+Path^.Dat.ToSklad+RazdelElement^.Dat.Kod+'.db!'+
            ClicProgrammer^,Nil,mfError+mfCancelButton);
        End;
     End;
   End;
  NoInfoMsg;
  System.Close(RazdelFile);
  Dispose(RazdelElement,Done);
 End
Else
Begin
 MessageBox(^M+#3+'Ошибка открытия файла разделов '+Path^.Dat.ToRazdel+'razdel.db! '+
            ClicProgrammer^,Nil,
            mfError+mfCancelButton);
 Exit;
End;


If Not(Find) Then
 Begin
  Dispose(NoScreenList1,Done);
  MessageBox(^M+#3'С данным объектом не связано ни одно наименование товара!',
             Nil,mfError+mfCancelButton);
  Exit;
 End;

R.Assign(1, 2, 79, 24);
New(LinkSpecMarkaWindow, Init(R, ''));
LinkSpecMarkaWindow^.Options := LinkSpecMarkaWindow^.Options or ofCenterX or ofCenterY;
LinkSpecMarkaWindow^.HelpCtx:=$F941;

R.Assign(77, 4, 78, 16);
Control := New(PScrollBar, Init(R));
LinkSpecMarkaWindow^.Insert(Control);

R.Assign(1, 4, 77, 16);
LinkList := New(PBox, Init(R, 1, PScrollbar(Control)));
LinkList^.NewList(New(PTextCollection, Init(0,1)));

If NoScreenList1^.List^.Count-1>=0 Then
 For c:=0 To NoScreenList1^.List^.Count-1 Do
  Begin
   s:=NoScreenList1^.GetText(c,NoScreenList1^.List^.Count);
   LinkList^.List^.Insert(NewStr(s));
   LinkList^.SetRange(LinkList^.List^.Count);
  End;
LinkList^.FocusItem(0);
LinkSpecMarkaWindow^.Insert(LinkList);


  R.Assign(1, 3, 77, 4);
  LinkSpecMarkaWindow^.Insert(New(PLabel, Init(R,
  'Наименования товара, связанные со спец.маркой          Код  Колич  Упаковок',
  LinkList)));

R.Assign(14, 1, 75, 2);
st:=GetSpecMarkaField(FSpecMarka,LinkArt);
DelSpaceRight(st);
Control := New(PColoredText, Init(R, st+'('+LinkArt+')', $7E));
LinkSpecMarkaWindow^.Insert(Control);

R.Assign(3, 1, 14, 2);
Control := New(PColoredText, Init(R, 'Спец.марка:', $74));
LinkSpecMarkaWindow^.Insert(Control);

R.Assign(2, 21, 25, 22);
ControlCount := New(PColoredText, Init(R, 'Всего позиций: '+IntToStr(LinkList^.List^.Count,CLitr+1), $4E));
LinkSpecMarkaWindow^.Insert(ControlCount);

R.Assign(1, 16, 16, 17);
Control := New(PColoredText, Init(R, '         Марка:', $74));
LinkSpecMarkaWindow^.Insert(Control);

R.Assign(16, 16, 56, 17);
ControlMarka := New(PColoredText, Init(R, '???', $7E));
LinkSpecMarkaWindow^.Insert(ControlMarka);

R.Assign(16, 17, 77, 18);
ControlNGTD := New(PColoredText, Init(R, '???', $7E));
LinkSpecMarkaWindow^.Insert(ControlNGTD);

R.Assign(1, 17, 16, 18);
Control := New(PColoredText, Init(R, Expert_RegNom^+':', $74));
LinkSpecMarkaWindow^.Insert(Control);

R.Assign(1, 18, 16, 19);
Control := New(PColoredText, Init(R, '           ГТД:', $74));
LinkSpecMarkaWindow^.Insert(Control);

R.Assign(16, 18, 77, 19);
ControlVirabotano := New(PColoredText, Init(R, '???', $7E));
LinkSpecMarkaWindow^.Insert(ControlVirabotano);

R.Assign(16, 19, 77, 20);
ControlDo := New(PColoredText, Init(R, '???', $7E));
LinkSpecMarkaWindow^.Insert(ControlDo);

R.Assign(1, 19, 16, 20);
Control := New(PColoredText, Init(R, 'Фирма-производ:', $74));
LinkSpecMarkaWindow^.Insert(Control);


R.Assign(1, 20, 16, 21);
Control := New(PColoredText, Init(R, '        Группа:', $74));
LinkSpecMarkaWindow^.Insert(Control);

R.Assign(16, 20, 77, 21);
ControlGroup := New(PColoredText, Init(R, '???', $7E));
LinkSpecMarkaWindow^.Insert(ControlGroup);



VidOtbora:=0;

R.Assign(40, 21, 76, 22);
ControlVidOtboraG := New(PRadioButtons, Init(R,
  NewSItem('~В~се',
  NewSItem('Не ну~л~евое количество', Nil))));
LinkSpecMarkaWindow^.Insert(ControlVidOtboraG);

ControlVidOtboraG^.SetData(VidOtbora);
{
  R.Assign(28, 19, 40, 20);
  LinkSpecMarkaWindow^.Insert(New(PLabel, Init(R, 'Вид отбора:', ControlVidOtboraG)));
}
LinkSpecMarkaWindow^.SelectNext(False);

CurrentLine[0]:=#0;
Refresh;
CurrentLine[0]:=#0;

c:=Desktop^.ExecView(LinkSpecMarkaWindow);

Dispose(NoScreenList1,Done);
Dispose(Control,Done);
Dispose(LinkSpecMarkaWindow,Done);

End;





procedure TLinkSpecMarkaWindow.FormReport;
Var txt : Text;
    c,w : Word;
   Space: AllStr;
      s : String;

begin
Space:='       ';
DInfoMsg('Формирую отчет.Ждите...',True);
 Assign(txt,Path^.Dat.ToTemp+'linksm.txt');
 c:=IOResult;
 Rewrite(txt);
 c:=IOResult;
 If c<>0 Then
  Begin
   MessageBox(#3'Ошибка создания '+Path^.Dat.ToTemp+'linksm.txt',Nil,mfError+mfCancelButton);
   Exit;
  End;

 Writeln(txt,Header+Space+'Склад: ',GetClientField(FClient,Rek^.Dat.Kod,1)+'  Оператор: '+CurrentPassword+' EYE & 1997-00');
 Writeln(txt);
 Writeln(txt,Space+GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+'         ОТЧЕТ ПО НАИМЕНОВАНИЯМ ТОВАРА, СВЯЗАННЫМ СО СПЕЦ.МАРКОЙ'+
 GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]);
 Writeln(txt,Space+GetSpecMarkaField(FName,LArt)+' ('+LArt+')');
 Write(txt,Space+'Вид отбора:');

 Case VidOtbora Of
 0:Writeln(txt,'Все');
 1:Writeln(txt,'Не нулевое количество');
 Else Writeln(txt);
 End;
 Writeln(txt,Space+'┌────────────────────────────────────────────────────┬─────┬─────┬─────────┐');
 Writeln(txt,Space+'│Наименования товара, связанные с объектом           │ Код │Колич│ Упаковок│');
 Writeln(txt,Space+'└────────────────────────────────────────────────────┴─────┴─────┴─────────┘'+HeaderStop);

 For c:=0 To LinkList^.List^.Count-1 Do
  Begin
   s:=LinkList^.GetText(c,LinkList^.List^.Count);
   s[0]:=Chr(1+CNAme+1+CNAme+1+CArtikul+1+CKol+1+CPAck);

   While Pos('│',s)>0 Do
    Begin
     w:=Pos('│',s);
     System.Delete(s,w,1);
     System.Insert(' ',s,w);
    End;

   Writeln(txt,Space+s)
  End;
 Writeln(txt,Space+'────────────────────────────────────────────────────────────────────────────');
 Writeln(txt,Space+' Всего позиций: ',LinkList^.List^.Count:6);
 Writeln(txt);
 Writeln(txt,Space,'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
 Writeln(txt,Space+'============================================================================');
 System.Close(txt);
NoInfoMsg;
ReportNew(Path^.Dat.ToTemp+'linksm.txt','',1,False,False);
End;



procedure TLinkSpecMarkaWindow.Refresh;
Var SKol : ArtikulStr;
    c : Word;
    R : TRect;
    s : String;
begin
DInfoMsg('Минуточку...',True);
LinkList^.NewList(Nil);
LinkList^.NewList(New(PTextCollection, Init(0,1)));

If NoScreenList1^.List^.Count>0 Then
 For c:=0 To NoScreenList1^.List^.Count-1 Do
  Begin
   s:=NoScreenList1^.GetText(c,NoScreenList1^.List^.Count);
   SKol:=Copy(s,1+CNAme+1+CName+1+CArtikul+1,CKol);
   If ((StrToInt(Skol)>0)And (VidOtbora=1)) Or (VidOtbora=0) Then
   Begin
    LinkList^.List^.Insert(NewStr(s));
    LinkList^.SetRange(LinkList^.List^.Count);
   End;
  End;
LinkList^.FocusItem(0);

Dispose(ControlCount,Done);
R.Assign(2, 21, 25, 22);
ControlCount := New(PColoredText, Init(R, 'Всего позиций: '+IntToStr(LinkList^.List^.Count,CLitr+1), $4E));
LinkSpecMarkaWindow^.Insert(ControlCount);
NoInfoMsg;

CurrentLine[0]:=#0;

End;

procedure TLinkSpecMarkaWindow.HandleEvent(var Event: TEvent);

procedure Calculator;
begin
  Calc^.Start;
end;

Var Art  : ArtikulStr;
    Prom : Word;
Begin

Case Event.What Of
 evCommand :
   Case Event.Command Of
        cmLocalCalc:Calculator;
        cmReestrReport:Begin
                        If LinkList^.List^.Count>0 Then FormReport;
                        ClearEvent(Event);
                       End;
 cmFindLink:Begin
             Art:=Copy(LinkList^.GetText(LinkList^.Focused,LinkList^.List^.Count),1+CName+1+CName+1,Cartikul);
             Lnk^.Start(Art);
             ClearEvent(Event);
            End;

 cmViewPrihodTovar:
            Begin
             Art:=Copy(LinkList^.GetText(LinkList^.Focused,LinkList^.List^.Count),1+CName+1+CName+1,Cartikul);
             FP^.FindScreenPrh(Art);
             ClearEvent(Event);
            End;

        Else;
        End;
 Else;
 End;

inherited HandleEvent(Event);

 If (Desktop^.Current=PView(LinkSpecMarkaWindow)) And (Event.What <> EvKeyDown) Then
     Begin
          if (ControlVidOtboraG^.State and sfFocused <> 0)Then
              Begin
               ControlVidOtboraG^.GetData(Prom);
               If Prom <> VidOtbora Then
               Begin
                  VidOtbora:=Prom;
                  Refresh;
                  Redraw;
               End;
              End;
      DrawCurrent;
     End;
End;



Procedure TLinkSpecMarkaWindow.DrawCurrent;
Var st : String;
    R : TRect;
Begin
if (LinkList^.List<>Nil)And(LinkList^.List^.Count>=1) Then
 Begin
  st:=LinkList^.GetText(LinkList^.Focused,LinkList^.List^.Count);
  If st <> CurrentLine Then
   Begin
    CurrentLine:=St;
    st:=Copy(CurrentLine,1+CName+1+CName+1+CArtikul+1+CKol+1+CPack+1,CNSertif);
    DelSpaceRight(st);
    Dispose(ControlMarka,Done);
    R.Assign(16, 16, 56, 17);
    ControlMarka := New(PColoredText, Init(R, st, $7E));
    LinkSpecMarkaWindow^.Insert(ControlMarka);

    st:=Copy(CurrentLine,1+CName+1+CName+1+CArtikul+1+CKol+1+CPack+1+CNSertif+1,
    CNSertif);
    DelSpaceRight(st);
    Dispose(ControlNGTD,Done);
    R.Assign(16, 17, 77, 18);
    ControlNGTD := New(PColoredText, Init(R, st, $7E));
    LinkSpecMarkaWindow^.Insert(ControlNGTD);

    st:=Copy(CurrentLine,1+CName+1+CName+1+CArtikul+1+CKol+1+CPack+1+CNSertif+1+
    CNSertif+1,CNSertif);
    DelSpaceRight(st);
    Dispose(ControlVirabotano,Done);
    R.Assign(16, 18, 77, 19);
    ControlVirabotano := New(PColoredText, Init(R, St, $7E));
    LinkSpecMarkaWindow^.Insert(ControlVirabotano);

    st:=Copy(CurrentLine,1+CName+1+CName+1+CArtikul+1+CKol+1+CPack+1+CNSertif+1+
    CNSertif+1+CNSertif+1,CNSertif);
    DelSpaceRight(st);
    Dispose(ControlDo,Done);
    R.Assign(16, 19, 77, 20);
    ControlDo := New(PColoredText, Init(R, St, $7E));
    LinkSpecMarkaWindow^.Insert(ControlDo);


    st:=Copy(CurrentLine,1+CName+1+CName+1+CArtikul+1+CKol+1+CPack+1+CNSertif+1+
    CNSertif+1+CNSertif+1+CNSertif+1,CNSertif);
    DelSpaceRight(st);
    Dispose(ControlGroup,Done);
    R.Assign(16, 20, 77, 21);
    ControlGroup := New(PColoredText, Init(R, St, $7E));
    LinkSpecMarkaWindow^.Insert(ControlGroup);
   End;
 End
 Else
  Begin
   PStaticText(ControlMarka)^.GetText(st);
   If St<>'???' Then
   Begin
   Dispose(ControlMarka,Done);
   R.Assign(16, 16, 56, 17);
   ControlMarka := New(PColoredText, Init(R, '???', $7E));
   LinkSpecMarkaWindow^.Insert(ControlMarka);

   Dispose(ControlNGTD,Done);
   R.Assign(7, 17, 47, 18);
   ControlNGTD := New(PColoredText, Init(R, '???', $7E));
   LinkSpecMarkaWindow^.Insert(ControlNGTD);

   Dispose(ControlVirabotano,Done);
   R.Assign(16, 18, 77, 19);
   ControlVirabotano := New(PColoredText, Init(R, '???', $7E));
   LinkSpecMarkaWindow^.Insert(ControlVirabotano);

   Dispose(ControlDo,Done);
   R.Assign(16, 19, 77, 20);
   ControlDo := New(PColoredText, Init(R, '???', $7E));
   LinkSpecMarkaWindow^.Insert(ControlDo);

   Dispose(ControlGroup,Done);
   R.Assign(16, 20, 77, 21);
   ControlGroup := New(PColoredText, Init(R, '???', $7E));
   LinkSpecMarkaWindow^.Insert(ControlGroup);
   End;
  End;
End;


Destructor TLinkSpecMarkaWindow.Done;
Begin
TDialog.Done;
End;



Procedure ReCalcAkzis(SArt : ArtikulStr;Var SAkzis : AllStr);
Begin
  SAkzis:='    0.00';
  if StrToInt(GetIdField(FBuchGroup,SArt)) in [1,2,3,4,7] then
    begin
         if StrToInt(GetIdField(FBuchGroup,SArt)) in [1,2,3] then
         MyStr(
	    StrToReal(AkzisKoeff[StrToInt(GetIdField(FBuchGroup,SArt))])
	   *0.8
	   *StrToReal(GetIdField(FLitr,SArt))
	   *StrToReal(GetIdField(FEtil,SArt))
        /100,
         CZena,CMantissaZ,SAkzis)
         Else
         MyStr(
	    StrToReal(AkzisKoeff[StrToInt(GetIdField(FBuchGroup,SArt))])
	   *0.65
	   *StrToReal(GetIdField(FLitr,SArt))
	   *StrToReal(GetIdField(FEtil,SArt))
        /100,
         CZena,CMantissaZ,SAkzis);
    end
        else
    begin
         if StrToInt(GetIdField(FBuchGroup,SArt)) in [1,2,3] then
         MyStr(
	    StrToReal(AkzisKoeff[StrToInt(GetIdField(FBuchGroup,SArt))])
	   *0.8
	   *StrToReal(GetIdField(FLitr,SArt))
        ,CZena,CMantissaZ,SAkzis)
        Else
         MyStr(
	    StrToReal(AkzisKoeff[StrToInt(GetIdField(FBuchGroup,SArt))])
	   *0.65
	   *StrToReal(GetIdField(FLitr,SArt))
        ,CZena,CMantissaZ,SAkzis);
    end;

End;





Procedure SelectDeActivDocument;
Label 1;
var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  c : Word;
  Num: ArtikulStr;
  As : DocumentEditZ;
  E : PSuperMArketType;
  Status : AllStr;

var
  DataRec : record
    Numer : String[CDocNumer];
    Date  : String[CDate];
  end;

begin
DataRec.Numer[0]:=#0;
DataRec.Date[0]:=#0;
1:
R.Assign(29, 9, 51, 14);
New(Dlg, Init(R, 'Специально'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx := $E002;

R.Assign(2, 2, 8, 3);
Control := New(PInputLine, Init(R, CDocNumer));
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0']));

R.Assign(10, 2, 20, 3);
Control := New(PInputLine, Init(R, CDate));
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PPXPictureValidator, Init(DateFiltr, True));

Dlg^.SelectNext(False);

Dlg^.SetData(DataRec);

c:=Desktop^.ExecView(Dlg);

If c<>cmCancel Then
Begin
 Dlg^.GetData(DataRec);
 Num:=DataRec.Numer;

 DelSpace(Num);
 DelSpace(DataRec.DAte);
 Dispose(Control,Done);
 Dispose(Dlg,Done);

 If Num[0]=#0 Then
  Begin
   Goto 1;
  End;

 If DataRec.Date[0]=#0 Then
  Begin
   Goto 1;
  End;

 As.EditPosition:=Num;
 As.D:=DataRec.Date;

 New(E,Init);

 If GetMarketSpecial(As,E) Then
Begin

 If Activ_DeActiv_MArket(Num,DataRec.Date,Not(E^.DAt.Active)) Then
  Begin
   If Not(E^.DAt.Active) Then Status:='TRUE'
   Else Status:='FALSE';
   MessageBox(^M+#3'Операция успешно завершена!'^M+#3'Статус документа изменен!',Nil,mfError+mfCancelButton);
   AddProtocol('Изменение статуса документа N '+Num+' от '+DataRec.Date+
   ' новый статус:'+Status,'{сетевая безопасность}','');
  End;
End;
 Dispose(E,Done);
End
Else
 Begin
  Dispose(Control,Done);
  Dispose(Dlg,Done);
 End;
end;





End.