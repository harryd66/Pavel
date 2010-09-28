{$I Compile.INC}

{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}
Unit FindPrh;


Interface

Uses Glob,ServStr,Dialogs,MyCalc,Drivers,ViewPrh;



Type
  PFindPrh = ^TFindPrh;
  TFindPrh = object(TDialog)
        Calc        : PMyCalculator;
        ViewPrh     : PFullScreenPrh;
        KodArt      : ArtikulStr;
        FindNAme    : TMyString;
      Function FindScreenPrh(Art:ArtikulStr):Boolean;
      procedure DrawCurrent;
      procedure FastRefresh;
      procedure Sorting;
      procedure FormReport;
      procedure HandleEvent(var Event: TEvent); virtual;
      Destructor Done;Virtual;
  end;


implementation


Uses Objects,DbEngine,MsgBox,NetDbEng,Protect,DbEngin2,
     TpDate,Utils1,NetCall,Net,WinDos,Access1,Vision5,ServStr2,
	Utils,Views,ColorTxt,Validate,App,Printers,Utils5,Utils4,Utils3,
	Vision8,Vision4,Tools,Serv;

{Const ReadOnly=0;}

Var
    ControlArt,ControlNumer,ControlNumerPost,ControlDAtePost,
    Control,ControlDo,ControlVirabotano,ControlMArka,
    ControlPost,ControlFirmaPost,ControlNGTD,ControlOperator,
    ControlAkzisSbor,ControlIndicator,ControlItog,
    ControlBC,ControlNSertif,ControlSort,ControlFiltr:PView;
    OldFileMode : Word;
    FindWin : PFindPrh;
    ScreenList,NoScreenList1,NoScreenList2 : PBox;
    PrevCurrent : String;
    Sort : Word;{указывает на ключ сортировки}
    Filtr   : Word;{фильтр видов документов}
    AllKol,AllRZ,AllZZ,AllZZ2,AllAkz : String[CIZena];
    Reg : Word;
    StartDAte,StopDAte : TDAteString;




Function TFindPrh.FindScreenPrh;
var
  R : TRect;
  CurDate : TDateString;
  Start,Stop,Cur : LongInt;
  c,sh : Word;
  AddKod : Boolean;
  s1,s2,SName,sPost,sFirmaPost,sNGTD,sMarka,
  SSNAme : String;
  SClient:AllStr;
  E : PBufPrihodType;
  f : File;
  Find : Boolean;
  SertifName : TMySTring;
  PrevProd : Boolean;
  BBB : PBazType;
  jk,Count : Word;

begin
  ClearFind;
  FindScreenPrh:=False;

  StartDAte:=FDAte;
  StopDAte:=FDAte;

  If Not(DatePeriodDialog(StartDate,StopDate,False)) Then Exit;

  Reg:=SelectImport(24);
  If Reg=2 Then Exit;


  Start:=DateStringToDate(DateMask,StartDAte);
  Stop:=DateStringToDate(DateMask,StopDAte);

R.Assign(0,0,0,0);
NoScreenList2 := New(PBox, Init(R, 1, Nil));
NoScreenList2^.NewList(New(PTextCollection, Init(0,1)));

R.Assign(0,0,0,0);
NoScreenList1 := New(PBox, Init(R, 1, Nil));
NoScreenList1^.NewList(New(PTextCollection, Init(0,1)));

   SNAme:=GetIDField(FFFName,Art);
   Format(SName,CName+1+CNAme);
   SSNAme[0]:=#0;

   If Reg=1 Then
    begin
      New(BBB,Init);
      BBB^.Dat.BazKod:=Art;
      GetBazElement(Art,BBB^.Dat);
      If (BBB^.Dat.Main=1) Then Art:=BBB^.Dat.FantomKod;
      Dispose(BBB,Done);
    End;


PrevProd:=ProdagaWindow;
ProdagaWindow:=False;


   For Cur:=Start To Stop Do
   Begin
    CurDate:=DateToDateString(DateMask,Cur);
    DInfoMsgShkala('Просматриваю приходы за '+CurDAte+' ...',Start,Stop,Cur);
    Assign(f,Path^.DAt.ToPrihod+CurDate+'.prh');
    c:=IOResult;
    OldFileMode:=FileMode;
    FileMode:=ReadOnlyN;
    reset(f,SizeOf(PrihodType));
    c:=IOResult;
    FileMode:=OldFileMode;
    If c<>0 Then Continue;

    While Not(Eof(f)) Do
     Begin
      New(E,Init);
      Count:=0;
      ReadBufPrihod(f,E,Count);

For jk:=1 To Count Do
Begin
      For sh:=1 To E^.Point.DAt[jk].Amount Do
       Begin

        AddKod:=False;
        If Reg=1 Then
        Begin
         { убрана т.к. теперь код фантомной позиции храниться}
         New(BBB,Init);
         BBB^.Dat.BazKod:={Art}E^.Point.DAt[jk].PrihodElement[sh].BAzKod;
         GetBazElement({Art}E^.Point.DAt[jk].PrihodElement[sh].BAzKod,BBB^.Dat);
         If ((BBB^.Dat.Main=1) And (BBB^.Dat.FantomKod=Art))
	    Or(E^.Point.DAt[jk].PrihodElement[sh].BAzKod=Art) Then AddKod:=True;
         DelSpaceRight(BBB^.Dat.Name);
         DelSpaceRight(BBB^.Dat.Name2);
 	    SSNAme:=BBB^.Dat.Name+' '+BBB^.Dat.Name2;
         Format(SSName,CName+1+CNAme);
         Dispose(BBB,Done);
         {If (E^.Point.DAt[jk].PrihodElement[sh].FantomKod=Art) Then AddKod:=True;}
        End
        Else
         Begin
         End;

        If ((AddKod{SName=SSNAme})And(Reg=1))  Or
	   ((Reg=0)And(E^.Point.DAt[jk].PrihodElement[sh].BAzKod=Art))Then
         Begin
          SertifNAme:=GetIDField(FFFName,E^.Point.DAt[jk].PrihodElement[sh].Input.NSertif);
          Format(SertifNAme,CName+1+CName);
          Format(E^.Point.DAt[jk].PrihodElement[sh].Input.Virabotano,CDate);
          Format(E^.Point.DAt[jk].PrihodElement[sh].Input.Godnost,CDate);
          Format(E^.Point.DAt[jk].PrihodElement[sh].Input.StrihKod,CStrihKod);
          DelSpace(E^.Point.DAt[jk].PrihodElement[sh].Input.Kol);
          RFormat(E^.Point.DAt[jk].PrihodElement[sh].Input.Kol,CKol);
          RFormatZerro(E^.Point.DAt[jk].Caption,2);
          Format(E^.Point.DAt[jk].DateC,CDate);
          Format(E^.Point.DAt[jk].Document,CDocNumer);
          Format(E^.Point.DAt[jk].Rekwizit.Numer,CName);
          Format(E^.Point.DAt[jk].Rekwizit.Date,CDate);
          RFormatZerro(E^.Point.DAt[jk].Caption,CRAzdelKod);

          sPost:=GetPostField(FPost,GetIdField(FPost,E^.Point.DAt[jk].PrihodElement[sh].BazKod));
          Format(sPost,CPost);
          sFirmaPost:=GetFirmaPostField(FFirmaPost,GetIdField(FFirmaPost,E^.Point.DAt[jk].PrihodElement[sh].BazKod));
          Format(sFirmaPost,CFirmaPost);
          sNGTD:=GETNGTDField(FNGTD,E^.Point.DAt[jk].PrihodElement[sh].Input.NGTD);
          Format(sNGTD,CNGTD);
          sMarka:=GetMarkaField(FMarka,E^.Point.DAt[jk].PrihodElement[sh].Input.Marka);
          Format(sMarka,CMarka);

       If EnableZakupka=1 Then
       MyStr(StrToReal(E^.Point.DAt[jk].PrihodElement[sh].Input.Zakupka),CZenaZ,CMantissaZ,
	  E^.Point.DAt[jk].PrihodElement[sh].Input.Zakupka)
       Else
       E^.Point.DAt[jk].PrihodElement[sh].Input.Zakupka:=CodeZakupka;

       If EnableZakupka=1 Then
       MyStr(StrToReal(E^.Point.DAt[jk].PrihodElement[sh].Input.Zakupka2),CZenaZ,CMantissaZ,
	  E^.Point.DAt[jk].PrihodElement[sh].Input.Zakupka2)
       Else
       E^.Point.DAt[jk].PrihodElement[sh].Input.Zakupka2:=CodeZakupka;
       MyStr(StrToReal(E^.Point.DAt[jk].PrihodElement[sh].Input.AkzisSbor),CZenaZ,CMantissaZ,
	  E^.Point.DAt[jk].PrihodElement[sh].Input.AkzisSbor);
       MyStr(StrToReal(E^.Point.DAt[jk].PrihodElement[sh].Input.R_Zena),CZena,CMantissa,
	  E^.Point.DAt[jk].PrihodElement[sh].Input.R_Zena);
          SClient:=GetMakeField(FMake,E^.Point.DAt[jk].MakeKod,E^.Point.DAt[jk].OperatorSelector);
          Format(SClient,CClient);

          s1:=SClient+'│'+IntToStr(E^.Point.DAt[jk].OperatorSelector,COne)+E^.Point.DAt[jk].MakeKod+'│'+
          E^.Point.DAt[jk].DateC+'│'+E^.Point.DAt[jk].PrihodElement[sh].Input.Kol+'│'+
          E^.Point.DAt[jk].PrihodElement[sh].Input.Zakupka+'│'+E^.Point.DAt[jk].PrihodElement[sh].Input.R_Zena+'│'+
          sPost+'│'+
		E^.Point.DAt[jk].PrihodElement[sh].BazKod+'│'+E^.Point.DAt[jk].Caption+'│'+IntToStr(
		E^.Point.DAt[jk].PrihodElement[sh].Input.RegionMarka,COne)+'│'+
          E^.Point.DAt[jk].Document+'│'+E^.Point.DAt[jk].Rekwizit.Numer+'│'+E^.Point.DAt[jk].Rekwizit.Date+'│'+
		E^.Point.DAt[jk].PrihodElement[sh].Input.AkzisSbor+'│'+
          E^.Point.DAt[jk].PrihodElement[sh].Input.Zakupka2+'│'+SertifName+'│'+
		E^.Point.DAt[jk].PrihodElement[sh].Input.NSertif;

          s2:='│'+IntToStr(E^.Point.DAt[jk].OperatorSelector,COne)+E^.Point.DAt[jk].MakeKod+'│'+
          E^.Point.DAt[jk].DateC+'│'+E^.Point.DAt[jk].PrihodElement[sh].BazKod+'│'+E^.Point.DAt[jk].Document+'│'+
          sMarka+'│'+sNGTD+'│'+
          E^.Point.DAt[jk].PrihodElement[sh].Input.StrihKod+'│'+sFirmaPost+'│'+
          E^.Point.DAt[jk].PrihodElement[sh].Input.Virabotano+'│'+E^.Point.DAt[jk].PrihodElement[sh].Input.Godnost;

         NoScreenList1^.List^.Insert(NewStr(s1));
         NoScreenList1^.SetRange(NoScreenList1^.List^.Count);
         NoScreenList2^.List^.Insert(NewStr(s2));
         NoScreenList2^.SetRange(NoScreenList2^.List^.Count);

         End;
        End;{for по накладной}
End;{For Count}
   Dispose(E,Done);
     End;{While}
    c:=IOResult;
    System.Close(f);
    c:=IOResult;

   End;{For за период}

NoInfoMsg;

s1[0]:=#0;
CAse Reg Of
0:s1:='(по коду)';
1:s1:='(по наименованию)';
Else;
End;


R.Assign(0, 0, 80, 23);
New(FindWin, Init(R, 'Хронология прихода за период с '+StartDAte+' по '+StopDate+' '+s1));
FindWin^.Options := FindWin^.Options or ofCenterX;
FindWin^.HelpCtx := $F381;
FindWin^.KodArt:=Art;

Sort:=0;{ключ сортировки по дате}
R.Assign(1, 1, 38, 2);
ControlSort := New(PRadioButtons, Init(R,
  NewSItem('~Д~ата',
  NewSItem('Поста~в~щик',
  NewSItem('К~о~лич.', Nil)))));
FindWin^.Insert(ControlSort);
ControlSort^.SetDAta(Sort);


Filtr:=7;{все операции включены}
R.Assign(45, 1, 79, 2);
ControlFiltr := New(PCheckboxes, Init(R,
  NewSItem('К~л~иент',
  NewSItem('~С~клад',
  NewSItem('Об~м~ен', Nil)))));
FindWin^.Insert(ControlFiltr);

ControlFiltr^.SetDAta(Filtr);


R.Assign(1, 2, 24, 3);
Control := New(PColoredText, Init(R, 'Искомая позиция товара:', $71));
FindWin^.Insert(Control);

R.Assign(24, 2, 77, 3);
DelSpaceRight(SNAme);
Control := New(PColoredText, Init(R, SNAme+' ('+Art+')', $7E));
FindWin^.Insert(Control);


R.Assign(1, 16, 5, 17);
Control := New(PColoredText, Init(R, 'Код:', $74));
FindWin^.Insert(Control);

R.Assign(5, 16, 10, 17);
ControlArt := New(PColoredText, Init(R, #3+'???', $7E));
FindWin^.Insert(ControlArt);

R.Assign(12, 16, 14, 17);
Control := New(PColoredText, Init(R, 'N:', $74));
FindWin^.Insert(Control);

R.Assign(14, 16, 19, 17);
ControlNumer := New(PColoredText, Init(R, #3+'???', $7E));
FindWin^.Insert(ControlNumer);

R.Assign(20, 16, 33, 17);
Control := New(PColoredText, Init(R, 'N поставщика:', $74));
FindWin^.Insert(Control);

R.Assign(33, 16, 59, 17);
ControlNumerPost := New(PColoredText, Init(R, #3+'???', $7E));
FindWin^.Insert(ControlNumerPost);

R.Assign(61, 16, 66, 17);
Control := New(PColoredText, Init(R, 'Дата:', $74));
FindWin^.Insert(Control);

R.Assign(66, 16, 74, 17);
ControlDatePost := New(PColoredText, Init(R, #3+'???', $7E));
FindWin^.Insert(ControlDatePost);

R.Assign(3, 17, 7, 18);
Control := New(PColoredText, Init(R, 'ГТД:', $74));
FindWin^.Insert(Control);

R.Assign(7, 17, 47, 18);
ControlNGTD := New(PColoredText, Init(R, #3+'???', $7E));
FindWin^.Insert(ControlNGTD);

R.Assign(51, 18, 61, 19);
Control := New(PColoredText, Init(R, ' Штрихкод:', $74));
FindWin^.Insert(Control);

R.Assign(61, 18, 79, 19);
ControlBC := New(PColoredText, Init(R, #3+'???', $7E));
FindWin^.Insert(ControlBC);

R.Assign(1, 18, 7, 19);
Control := New(PColoredText, Init(R, Seria_Akzis^+':', $74));
FindWin^.Insert(Control);

R.Assign(7, 18, 47, 19);
ControlMarka := New(PColoredText, Init(R, #3+'???', $7E));
FindWin^.Insert(ControlMarka);

R.Assign(58, 19, 67, 20);
Control := New(PColoredText, Init(R, 'Оператор:', $74));
FindWin^.Insert(Control);

R.Assign(67, 19, 79, 20);
ControlOperator := New(PColoredText, Init(R, #3+'???', $7E));
FindWin^.Insert(ControlOperator);

R.Assign(1, 19, 21, 20);
Control := New(PColoredText, Init(R, 'Фирма-производитель:', $74));
FindWin^.Insert(Control);

R.Assign(21, 19, 56, 20);
ControlFirmaPost := New(PColoredText, Init(R, #3+'???', $7E));
FindWin^.Insert(ControlFirmaPost);

R.Assign(1, 21, 12, 22);
Control := New(PColoredText, Init(R, 'Сертификат:', $74));
FindWin^.Insert(Control);

R.Assign(12, 21, 73, 22);
ControlNSertif := New(PColoredText, Init(R, #3+'???', $7E));
FindWin^.Insert(ControlNSertif);

R.Assign(12, 22, 67, 23);
ControlItog := New(PColoredText, Init(R, #3+'ЗЦ1:0.0000  РЦ:0.00 (0.000л)', $4F));
ControlItog^.Options := ControlItog^.Options or ofCenterX;
FindWin^.Insert(ControlItog);

R.Assign(14, 20, 25, 21);
Control := New(PColoredText, Init(R, 'Выработано:', $74));
FindWin^.Insert(Control);

R.Assign(25, 20, 33, 21);
ControlVirabotano := New(PColoredText, Init(R, #3+'???', $7E));
FindWin^.Insert(ControlVirabotano);

R.Assign(38, 20, 53, 21);
Control := New(PColoredText, Init(R, 'Реализовать до:', $74));
FindWin^.Insert(Control);

R.Assign(53, 20, 61, 21);
ControlDO := New(PColoredText, Init(R, #3+'???', $7E));
FindWin^.Insert(ControlDO);

R.Assign(49, 17, 55, 18);
Control := New(PColoredText, Init(R, 'Марка:', $74));
FindWin^.Insert(Control);

R.Assign(55, 17, 59, 18);
ControlIndicator:= New(PColoredText, Init(R, #3+'???', $7E));
FindWin^.Insert(ControlIndicator);

R.Assign(60, 17, 66, 18);
Control := New(PColoredText, Init(R, 'Ак.сб:', $74));
FindWin^.Insert(Control);

R.Assign(66, 17, 76, 18);
ControlAkzisSbor := New(PColoredText, Init(R, #3+'???', $7E));
FindWin^.Insert(ControlAkzisSbor);


R.Assign(79, 4, 80, 16);
Control := New(PScrollBar, Init(R));
FindWin^.Insert(Control);

R.Assign(1, 4, 79, 16);
ScreenList := New(PBox, Init(R, 1, PScrollBar(Control)));
ScreenList^.NewList(New(PMyCollection, Init(0,1)));
ScreenList^.FocusItem(0);
FindWin^.Insert(ScreenList);

  R.Assign(1, 3, 79, 4);
  FindWin^.Insert(New(PLabel, Init(R, 'Поставщик            Код    Дата    Колич  З/Цена1   Р/Цена   Страна происхож.',
  ScreenList)));

{PrevCurrent:=NewStr('');}


FindWin^.SelectNext(False);
PrevCurrent[0]:=#0;



FastRefresh;
Sorting;

PrevCurrent[0]:=#0;

c:=Desktop^.ExecView(FindWin);


Dispose(Control,Done);
Dispose(ScreenList,Done);
Dispose(FindWin,Done);

Dispose(NoScreenList2,Done);
Dispose(NoScreenList1,Done);

PrevCurrent[0]:=#0;
ProdagaWindow:=PrevProd;

end;



Function GetField(Field:Word;SPost,SDAte,SNumer,SArt:TDAteString):String;
Var s : String;
    c : Word;
    ss : TMyString;
    Find : Boolean;
    SSPost,SSDAte,SSNumer,SSArt:TDAteString;
Begin
GetField[0]:=#0;
ss[0]:=#0;
If (NoScreenList2^.List^.Count-1)>=0 Then
 Begin
 Find:=False;
 For c:=0 To NoScreenList2^.List^.Count-1 Do
  Begin
   s:=NoScreenList2^.GetText(c,NoScreenList2^.List^.Count);
   SSPost:=Copy(s,1+1,CArtikul);
   SSDate:=Copy(s,1+1+CArtikul+1,CDAte);
   SSArt :=Copy(s,1+1+CArtikul+1+CDAte+1,CArtikul);
   SSNumer:=Copy(s,1+1+CArtikul+1+CDAte+1+CArtikul+1,CDocNumer);
   DelSpace(SSPost);
   DelSpace(SSDate);
   DelSpace(SSNumer);
   DelSpace(SSArt);

   If (SSPost=SPost) And(SSDAte=SDAte) And (SSNumer=SNumer) And (SSArt=SArt) Then
    Begin
     Find:=True;
     Break
    End;
  End;{For}


  If Find Then
   Begin
    Case Field Of
    FMarka:ss:=Copy(s,1+1+CArtikul+1+CDAte+1+CArtikul+1+CDocNumer+1,CNSertif);
    FNGTD:ss:=Copy(s,1+1+CArtikul+1+CDAte+1+CArtikul+1+CDocNumer+1+CNSertif+1,CNSertif);
    FStrihKod:ss:=Copy(s,1+1+CArtikul+1+CDAte+1+CArtikul+1+CDocNumer+1+CNSertif+1+CNSertif+1,CStrihKod);
    FFirmaPost:ss:=Copy(s,1+1+CArtikul+1+CDAte+1+CArtikul+1+CDocNumer+1+CNSertif+1+CNSertif+1+CStrihKod+1,CFirmaPost);
    FVirabotano:ss:=Copy(s,1+1+CArtikul+1+CDAte+1+CArtikul+1+CDocNumer+1+CNSertif+1+CNSertif+1+CStrihKod+1+
    CFirmaPost+1,CDAte);
    FGodnost:ss:=Copy(s,1+1+CArtikul+1+CDAte+1+CArtikul+1+CDocNumer+1+CNSertif+1+CNSertif+1+CStrihKod+1+
    CFirmaPost+1+CDAte+1,CDAte);
    Else;
    End;{CAse}

    DelSpaceRight(ss);
    GetField:=ss;
   End;{Find}


 End;{<>Nil}

End;




procedure TFindPrh.DrawCurrent;
VAr S : String;
    R : TRect;
    SPost,SNumer,SDate,SNArt,SArt : TDAteString;
    SS : TMyString;
    Color : Word;
Begin

If (ScreenList^.List<>Nil)And(ScreenList^.List^.Count>=1) Then
  Begin
   s:=ScreenList^.GetText(ScreenList^.Focused,ScreenList^.list^.Count);
   Begin
   PrevCurrent:=S;
   SPost:=Copy(s,1+CClient+1,CArtikul);
   SDate:=Copy(s,1+CClient+1+CArtikul+1,CDAte);
   SNumer:=Copy(s,1+CClient+1+CArtikul+1+CDAte+1+CKol+1+CZenaZ+1+CZena+1+CPost+1+
             CArtikul+1+CRAzdelKod+1+COne+1,CDocNumer);
   SArt :=Copy(s,1+CClient+1+CArtikul+1+CDAte+1+CKol+1+CZenaZ+1+CZena+1+CPost+1,
          CArtikul);
   DelSpace(SPost);
   DelSpace(SDate);
   DelSpace(SNumer);
   DelSpace(SArt);

   Dispose(ControlArt,Done);
   R.Assign(5, 16, 10, 17);
   ControlArt := New(PColoredText, Init(R, #3+SArt, $7E));
   FindWin^.Insert(ControlArt);

   Dispose(ControlNumer,Done);
   R.Assign(14, 16, 19, 17);
   ControlNumer := New(PColoredText, Init(R, SNumer, $7E));
   FindWin^.Insert(ControlNumer);

{
   Ss:=Copy(s,1+CClient+1+CArtikul+1+CDAte+1+CKol+1+CZenaZ+1+CZena+1+CPost+1+
             CArtikul+1+CRAzdelKod+1+COne+1+CDocNumer+1+CName+1+CDate+1+CZenaZ+1,CZenaZ);
}
   Ss:=Copy(s,1+CClient+1+CArtikul+1+CDAte+1+CKol+1+CZenaZ+1+CZena+1+CPost+1+
             CArtikul+1+CRAzdelKod+1+COne+1+CDocNumer+1,CName);
   DelSPaceRight(ss);

   Dispose(ControlNumerPost,Done);
   R.Assign(33, 16, 59, 17);
   ControlNumerPost := New(PColoredText, Init(R, ss, $7E));
   FindWin^.Insert(ControlNumerPost);


   Ss:=Copy(s,1+CClient+1+CArtikul+1+CDAte+1+CKol+1+CZenaZ+1+CZena+1+CPost+1+
             CArtikul+1+CRAzdelKod+1+COne+1+CDocNumer+1+CName+1,CDate);
   DelSPaceRight(ss);
   Dispose(ControlDAtePost,Done);
   R.Assign(66, 16, 74, 17);
   ControlDatePost := New(PColoredText, Init(R, #3+ss, $7E));
   FindWin^.Insert(ControlDatePost);

   Ss:=Copy(s,1+CClient+1+CArtikul+1+CDAte+1+CKol+1+CZenaZ+1+CZena+1+CPost+1+
             CArtikul+1,CRAzdelKod);
   DelSPaceRight(ss);
   SS:=GetOperatorField(FNAme,ss);
   DelSPaceRight(ss);
   Dispose(ControlOperator,Done);
   R.Assign(67, 19, 79, 20);
   ControlOperator := New(PColoredText, Init(R, ss, $7E));
   FindWin^.Insert(ControlOperator);


   Ss:=Copy(s,1+CClient+1+CArtikul+1+CDAte+1+CKol+1+CZenaZ+1+CZena+1+CPost+1+
             CArtikul+1+CRAzdelKod+1,COne);
   DelSPaceRight(ss);
   Color:=$7E;
   Case StrToInt(ss) Of
   0:Begin ss:='Нет'; Color:=$7E; End;
   1:Begin ss:='Есть'; Color:=$5F; End;
   Else ss:='???';
   End;
   DelSPaceRight(ss);
   Dispose(ControlIndicator,Done);
   R.Assign(55, 17, 59, 18);
   ControlIndicator:= New(PColoredText, Init(R, #3+ss, Color));
   FindWin^.Insert(ControlIndicator);

   Ss:=Copy(s,1+CClient+1+CArtikul+1+CDAte+1+CKol+1+CZenaZ+1+CZena+1+CPost+1+
             CArtikul+1+CRAzdelKod+1+COne+1+CDocNumer+1+CName+1+CDate+1,CZenaZ);
   DelSPace(ss);
   Dispose(ControlAkzisSbor,Done);
   R.Assign(66, 17, 76, 18);
   ControlAkzisSbor := New(PColoredText, Init(R, ss, $7E));
   FindWin^.Insert(ControlAkzisSbor);


   Ss:=Copy(s,1+CClient+1+CArtikul+1+CDAte+1+CKol+1+CZenaZ+1+CZena+1+CPost+1+
             CArtikul+1+CRAzdelKod+1+COne+1+CDocNumer+1+CName+1+CDate+1+CZenaZ+1+CZenaZ+1,CNAme+1+CNAme);

   SNArt:=Copy(s,1+CClient+1+CArtikul+1+CDAte+1+CKol+1+CZenaZ+1+CZena+1+CPost+1+
             CArtikul+1+CRAzdelKod+1+COne+1+CDocNumer+1+CName+1+CDate+1+CZenaZ+1+CZenaZ+1+(CNAme+1+CNAme)+1,
		   CArtikul);
   DelSPaceRight(sNArt);
   DelSPaceRight(ss);


   Dispose(ControlNSertif,Done);
   R.Assign(12, 21, 73, 22);
   ControlNSertif := New(PColoredText, Init(R, ss+' ['+SNArt+']', $7E));
   FindWin^.Insert(ControlNSertif);



   ss:=GetField(FNGTD,SPost,SDAte,SNumer,SArt);
   Dispose(ControlNGTD,Done);
   R.Assign(7, 17, 47, 18);
   ControlNGTD := New(PColoredText, Init(R, ss, $7E));
   FindWin^.Insert(ControlNGTD);


   ss:=GetField(FStrihKod,SPost,SDAte,SNumer,SArt);
   Dispose(ControlBC,Done);
   R.Assign(61, 18, 79, 19);
   ControlBC := New(PColoredText, Init(R, ss, $7E));
   FindWin^.Insert(ControlBC);

   ss:=GetField(FMarka,SPost,SDAte,SNumer,SArt);
   Dispose(ControlMArka,Done);
   R.Assign(7, 18, 47, 19);
   ControlMarka := New(PColoredText, Init(R, ss, $7E));
   FindWin^.Insert(ControlMarka);

   ss:=GetField(FFirmaPost,SPost,SDAte,SNumer,SArt);
   Dispose(ControlFirmaPost,Done);
   R.Assign(21, 19, 56, 20);
   ControlFirmaPost := New(PColoredText, Init(R, ss, $7E));
   FindWin^.Insert(ControlFirmaPost);

   ss:=GetField(FVirabotano,SPost,SDAte,SNumer,SArt);
   Dispose(ControlVirabotano,Done);
   R. Assign(25, 20, 33, 21);
   ControlVirabotano := New(PColoredText, Init(R, ss, $7E));
   FindWin^.Insert(ControlVirabotano);

   ss:=GetField(FGodnost,SPost,SDAte,SNumer,SArt);
   Dispose(ControlDo,Done);
   R.Assign(53, 20, 61, 21);
   ControlDO := New(PColoredText, Init(R, ss, $7E));
   FindWin^.Insert(ControlDO);




   Redraw;
   End;{PrevCurrent<>S}

  End
  Else
   Begin
    If PStaticText(ControlArt)^.Text^<>#3'???' Then
    Begin
Dispose(ControlArt,Done);
R.Assign(5, 16, 10, 17);
ControlArt := New(PColoredText, Init(R, #3+'???', $7E));
FindWin^.Insert(ControlArt);

Dispose(ControlNumer,Done);
R.Assign(14, 16, 19, 17);
ControlNumer := New(PColoredText, Init(R, #3+'???', $7E));
FindWin^.Insert(ControlNumer);

Dispose(ControlNumerPost,Done);
R.Assign(33, 16, 59, 17);
ControlNumerPost := New(PColoredText, Init(R, #3+'???', $7E));
FindWin^.Insert(ControlNumerPost);

Dispose(ControlDAtePost,Done);
R.Assign(66, 16, 74, 17);
ControlDatePost := New(PColoredText, Init(R, #3+'???', $7E));
FindWin^.Insert(ControlDatePost);

Dispose(ControlNGTD,Done);
R.Assign(7, 17, 47, 18);
ControlNGTD := New(PColoredText, Init(R, #3+'???', $7E));
FindWin^.Insert(ControlNGTD);

Dispose(ControlBC,Done);
R.Assign(61, 18, 79, 19);
ControlBC := New(PColoredText, Init(R, #3+'???', $7E));
FindWin^.Insert(ControlBC);

Dispose(ControlMArka,Done);
R.Assign(7, 18, 47, 19);
ControlMarka := New(PColoredText, Init(R, #3+'???', $7E));
FindWin^.Insert(ControlMarka);

Dispose(ControlOperator,Done);
R.Assign(67, 19, 79, 20);
ControlOperator := New(PColoredText, Init(R, #3+'???', $7E));
FindWin^.Insert(ControlOperator);

Dispose(ControlFirmaPost,Done);
R.Assign(21, 19, 56, 20);
ControlFirmaPost := New(PColoredText, Init(R, #3+'???', $7E));
FindWin^.Insert(ControlFirmaPost);

Dispose(ControlNSertif,Done);
R.Assign(12, 21, 73, 22);
ControlNSertif := New(PColoredText, Init(R, #3+'???', $7E));
FindWin^.Insert(ControlNSertif);

Dispose(ControlVirabotano,Done);
R.Assign(25, 20, 33, 21);
ControlVirabotano := New(PColoredText, Init(R, #3+'???', $7E));
FindWin^.Insert(ControlVirabotano);

Dispose(ControlDo,Done);
R.Assign(53, 20, 61, 21);
ControlDO := New(PColoredText, Init(R, #3+'???', $7E));
FindWin^.Insert(ControlDO);

Dispose(ControlIndicator,Done);
R.Assign(55, 17, 59, 18);
ControlIndicator:= New(PColoredText, Init(R, #3+'???', $7E));
FindWin^.Insert(ControlIndicator);

Dispose(ControlAkzisSbor,Done);
R.Assign(66, 17, 76, 18);
ControlAkzisSbor := New(PColoredText, Init(R, #3+'???', $7E));
FindWin^.Insert(ControlAkzisSbor);

    End;
   End;

End;


procedure TFindPrh.Sorting;
VAr R : TRect;
    s : String;
    TempBox : PBox;
    SKey : AllStr;
    c : Word;
Begin
DInfoMsg('Сортирую выборку...',True);

If (ScreenList^.List^.Count-1)>=0 Then
 Begin

R.Assign(0,0,0,0);
TempBox := New(PBox, Init(R, 1, Nil));
TempBox^.NewList(New(PTextCollection, Init(0,1)));
 {цикл создания виртуального отсортированного списка}
 For c:=0 To ScreenList^.List^.Count-1 Do
  Begin

   s:=ScreenList^.GetText(c,ScreenList^.List^.Count);


   CAse Sort Of
   {дата}
   0:Begin
      sKey:=Copy(s,1+CClient+1+CArtikul+1,CDAte);
      Str(DateStringToDate(DAteMAsk,SKey):CDate,SKey);
      s:=SKey+'│'+s;
     End;
   {поставщик}
   1:s:=s;
   {количество}
   2:Begin
      sKey:=Copy(s,1+CClient+1+CArtikul+1+CDAte+1,CKol);
      Str(StrToInt(SKey):CDate,SKey);
      s:=SKey+'│'+s;
     End;
   Else;
   End;

     TempBox^.List^.Insert(NewStr(s));
     TempBox^.SetRange(TempBox^.List^.Count);
  End;{For сортируем виртуальный список}



{очищаем экранный список}
ScreenList^.NewList(Nil);
ScreenList^.NewList(New(PMyCollection, Init(0,1)));

 {цикл создания виртуального отсоротированного списка}
 For c:=0 To TempBox^.List^.Count-1 Do
  Begin
   s:=TempBox^.GetText(c,TempBox^.List^.Count);
   CAse Sort Of
   {дата}
   0:Begin
      System.Delete(s,1,CDate+1);
     End;
   {поставщик}
   1:s:=s;
   {количество}
   2:Begin
      System.Delete(s,1,CDate+1);
     End;
   Else;
   End;

     ScreenList^.List^.Insert(NewStr(s));
     ScreenList^.SetRange(ScreenList^.List^.Count);
  End;{For формируем отсрортированный экранный список}


 Dispose(TempBox,Done);

 End;
NoInfoMsg;
PrevCurrent[0]:=#0;

end;


procedure TFindPrh.FastRefresh;
Var R : TRect;
    s : String;
    c : Word;
    MMM : Maska3;
    ClKod : ArtikulStr;
    AllLitr,Kol,ZZ,ZZ2,RZ,Akz : AllStr;
Begin

ScreenList^.NewList(Nil);
ScreenList^.NewList(New(PMyCollection, Init(0,1)));


DInfoMsg('Обрабатываю запрос...',True);

AllKol[0]:=#0;
AllRZ[0]:=#0;
AllZZ[0]:=#0;
AllZZ2[0]:=#0;
AllAkz[0]:=#0;
WordToBit3(Filtr,MMM);

If (NoScreenList1^.List^.Count-1)>=0 Then
 Begin
 For c:=0 To NoScreenList1^.List^.Count-1 Do
  Begin
   s:=NoScreenList1^.GetText(c,NoScreenList1^.List^.Count);
   ClKod:=Copy(s,1+CClient+1,COne);
   If MMM[StrToInt(ClKod)+1]=1 Then
    Begin

   ScreenList^.List^.Insert(NewStr(s));
   ScreenList^.SetRange(ScreenList^.List^.Count);

   Kol:=Copy(s,1+CClient+1+CArtikul+1+CDAte+1,CKol);
   ZZ:=Copy(s,1+CClient+1+CArtikul+1+CDAte+1+CKol+1,CZenaZ);
   RZ:=Copy(s,1+CClient+1+CArtikul+1+CDAte+1+CKol+1+CZenaZ+1,CZena);

   ZZ2:=Copy(s,1+CClient+1+CArtikul+1+CDAte+1+CKol+1+CZenaZ+1+CZena+1+CPost+1+
             CArtikul+1+CRAzdelKod+1+COne+1+CDocNumer+1+CName+1+CDate+1+CZenaZ+1,CZenaZ);

   Akz:=Copy(s,1+CClient+1+CArtikul+1+CDAte+1+CKol+1+CZenaZ+1+CZena+1+CPost+1+
             CArtikul+1+CRAzdelKod+1+COne+1+CDocNumer+1+CName+1+CDate+1,CZenaZ);
   Str(StrToInt(AllKol)+StrToInt(Kol):CKol+1,AllKol);

   MyStr(StrToReal(AllRZ)+StrToInt(Kol)*StrToReal(RZ),CIZena,CMantissa,AllRZ);
   MyStr(StrToReal(AllZZ)+StrToInt(Kol)*StrToReal(ZZ),CIZena,CMantissaZ,AllZZ);
   MyStr(StrToReal(AllZZ2)+StrToInt(Kol)*StrToReal(ZZ2),CIZena,CMantissaZ,AllZZ2);
   MyStr(StrToReal(AllAkz)+StrToInt(Kol)*StrToReal(Akz),CIZena,CMantissaZ,AllAkz);

    End;
  End;{For отбираем нужные операции}
 End;{NoScreenList<>Nil}

   MyStr(StrToReal(AllRZ),CIZena,CMantissa,AllRZ);
   MyStr(StrToReal(AllZZ),CIZena,CMantissaZ,AllZZ);
   MyStr(StrToReal(AllZZ2),CIZena,CMantissaZ,AllZZ2);
   MyStr(StrToReal(AllAkz),CIZena,CMantissaZ,AllAkz);

DelSpace(ALLRZ);
DelSpace(ALLKol);
DelSpace(ALLZZ);
DelSpace(ALLZZ2);
DelSpace(ALLAkz);
MyStr(StrToInt(AllKol)*StrToReal(GetIdField(FLitr,FindWin^.KodArt)),CZenaZ,CMantissaZ,
AllLitr);

Str(StrToInt(AllKol):CKol,AllKol);
DelSpace(AllKol);
DelSpace(AllLitr);

If EnableZakupka=1 Then
Begin
s:='ЗЦ1:'+AllZZ+' ЗЦ2:'+AllZZ2+' РЦ:'+ALLRZ+' Всего:'+AllKol+' шт  ('+AllLitr+'л)';
End
Else
 Begin
  s:='РЦ:'+ALLRZ+'   Всего: '+AllKol+' шт  ('+AllLitr+'л)';
 End;

Dispose(ControlItog,Done);
R.Assign(12, 22, 12+Ord(s[0])+2, 23);
ControlItog := New(PColoredText, Init(R, #3+s, $4E));
ControlItog^.Options := ControlItog^.Options or ofCenterX;
FindWin^.Insert(ControlItog);

NoInfoMsg;


PrevCurrent[0]:=#0;
end;




procedure TFindPrh.HandleEvent(var Event: TEvent);
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
 evKeyDown :
   CAse Event.KeyCode Of
   kbEnter:
      Begin
     If (ScreenList^.State and sfFocused <> 0) And (ScreenList^.List<>Nil)And(ScreenList^.List^.Count>=1) Then
            Begin
             SelectNext(False);
             ClearEvent(Event);
            End;

      End;
   Else;
   End;

 evCommand :

   Case Event.Command Of
        cmLocalCalc:Calculator;


  cmFullView:    Begin
                 ClearFind;
     If (ScreenList^.State and sfFocused <> 0) And (ScreenList^.List<>Nil)And(ScreenList^.List^.Count>=1) Then
            Begin
             Assistent.EditPosition:=Copy(ScreenList^.GetText(ScreenList^.Focused,ScreenList^.List^.Count),
		   1+CClient+1+CArtikul+1+CDAte+1+CKol+1+CZenaZ+1+CZena+1+CPost+1+
             CArtikul+1+CRAzdelKod+1+COne+1,CDocNumer);
             DelSpace(Assistent.EditPosition);
             Assistent.D:=Copy(ScreenList^.GetText(ScreenList^.Focused,ScreenList^.List^.Count),
		   1+CClient+1+CArtikul+1,CDAte);
             DelSpace(Assistent.D);
             ViewPrh^.FullScreenPrh(Assistent);
             Redraw;
            End
            End;

  cmPrintReestr:    Begin
                 ClearFind;
     If (ScreenList^.State and sfFocused <> 0) And (ScreenList^.List<>Nil)And(ScreenList^.List^.Count>=1) Then
            Begin
             Assistent.EditPosition:=Copy(ScreenList^.GetText(ScreenList^.Focused,ScreenList^.List^.Count),
		   1+CClient+1+CArtikul+1+CDAte+1+CKol+1+CZenaZ+1+CZena+1+CPost+1+
             CArtikul+1+CRAzdelKod+1+COne+1,CDocNumer);
             DelSpace(Assistent.EditPosition);
             Assistent.D:=Copy(ScreenList^.GetText(ScreenList^.Focused,ScreenList^.List^.Count),
		   1+CClient+1+CArtikul+1,CDAte);
             DelSpace(Assistent.D);

              If MessageBox(^M+#3'Печатать накладную прихода N '+Assistent.EditPosition+' от '+Assistent.D+'?',Nil,
                      mfConfirmation+mfOKCancel)=cmOk Then
                PrintPrihod(Assistent);

             Redraw;
            End
            End;

 cmReestrReport:    Begin
                 ClearFind;
     If (ScreenList^.State and sfFocused <> 0) And (ScreenList^.List<>Nil)And(ScreenList^.List^.Count>=1) Then
            Begin
            FormReport;
            Redraw;
            End
            End;

        Else;
        End;
 Else;
 End;

inherited HandleEvent(Event);



  If (Desktop^.Current=PView(FindWin)) And (Event.What <> EvKeyDown) Then
             Begin

            if (ScreenList^.List<>Nil)And(ScreenList^.List^.Count>=1) Then
              Begin
               s:=ScreenList^.GetText(ScreenList^.Focused,ScreenList^.List^.Count);
               If s <> PrevCurrent Then
                 Begin
                  PrevCurrent:=S;
                  DrawCurrent;
                 End;
              End
              Else
                  DrawCurrent;

              if (ControlSort^.State and sfFocused <> 0)Then
                    Begin
                        ControlSort^.GetData(Prom);
                        If Prom <> Sort Then
                        Begin
                           Sort:=Prom;
                           Sorting;
                           Redraw;
                        End;
                    End;

              if (ControlFiltr^.State and sfFocused <> 0)Then
                    Begin
                        ControlFiltr^.GetData(Prom);
                        If Prom <> Filtr Then
                        Begin
                           Filtr:=Prom;
                           FastRefresh;
                           Sorting;
                           Redraw;
                        End;
                    End;
         End;

End;


Destructor TFindPrh.Done;
Begin
TDialog.Done;
end;


Procedure TFindPrh.FormReport;
Var txt : Text;
   Space: AllStr;
      s : String;
   sFirma,SAkzisSbor,SMArka,SGTD,SSrok,SVirabotano : AllStr;
   w,c : Word;
  SPost,SNumer,SDate,SNArt,SArt : TDAteString;
  SNumNakl,SDAteNakl,SNGTD,SInd,Sop,SSertif,SGodnost:String[80];
  MMM : Maska3;

begin
Space:='   ';
DInfoMsg('Формирую отчет.Ждите...',True);

 Assign(txt,Path^.Dat.ToTemp+'findprh!.txt');
 c:=IOResult;
 Rewrite(txt);
 c:=IOResult;
 If c<>0 Then
  Begin
   MessageBox(#3'Ошибка создания '+Path^.Dat.ToTemp+'findprh!.txt',Nil,mfError+mfCancelButton);
   Exit;
  End;

 Writeln(txt,Header+Space+'Склад: ',GetClientField(FClient,Rek^.Dat.Kod,1)+'  Оператор: '+CurrentPassword+
 ' EYE & 1997-01');
 Writeln(txt);
 Writeln(txt,Space+GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+'  ОТЧЕТ ПО ПРИХОДАМ НАИМЕНОВАНИЯ ТОВАРА за период с '+
 StartDAte+' по '+StopDAte+GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]);
 Writeln(txt,Space+'Искомое наименование: '+GetIdField(FFFName,FindWin^.KodArt)+' ('+FindWin^.KodArt+')');
 Write(txt,Space+'Вид поиска:');
 Case Reg Of
 0:Writeln(txt,'По коду');
 1:Writeln(txt,'По наименованию');
 Else Writeln(txt);
 End;

 Write(txt,Space+'Вид сортировки:');
 Case Sort Of
 0:Writeln(txt,'По дате прихода');
 1:Writeln(txt,'По поставщику');
 2:Writeln(txt,'По количеству');
 Else Writeln(txt);
 End;

 Write(txt,Space+'Виды операций:');
 WordToBit3(Sort,MMM);
 For c:=1 To 3 Do
 Begin
 If MMM[c]=1 Then
 Case c Of
 1:Write(txt,'{Клиент} ');
 2:Write(txt,'{Склад} ');
 3:Write(txt,'{Обмен} ');
 Else Write(txt);
 End;
 End;
 Writeln(txt);
                    {12345678901234567890│12345│12345678│12345│1234567890│12345678│123456789012345}
                   
 Writeln(txt,Space+'┌────────────────────┬─────┬────────┬─────┬──────────┬────────┬───────────────┐');
 Writeln(txt,Space+'│Поставщик           │ Код │Дата прх│Колич│   З/Цена1│  Р/Цена│    Страна     │');
 Writeln(txt,Space+'└────────────────────┴─────┴────────┴─────┴──────────┴────────┴───────────────┘'+HeaderStop);

 For c:=0 To ScreenList^.List^.Count-1 Do
  Begin
   s:=ScreenList^.GetText(c,ScreenList^.List^.Count);

   SPost:=Copy(s,1+CClient+1,CArtikul);
   SDate:=Copy(s,1+CClient+1+CArtikul+1,CDAte);
   SNumer:=Copy(s,1+CClient+1+CArtikul+1+CDAte+1+CKol+1+CZenaZ+1+CZena+1+CPost+1+
             CArtikul+1+CRAzdelKod+1+COne+1,CDocNumer);
   SArt :=Copy(s,1+CClient+1+CArtikul+1+CDAte+1+CKol+1+CZenaZ+1+CZena+1+CPost+1,
          CArtikul);

   DelSpace(SPost);
   DelSpace(SDate);
   DelSpace(SNumer);
   DelSpace(SArt);

   SNumNakl:=Copy(s,1+CClient+1+CArtikul+1+CDAte+1+CKol+1+CZenaZ+1+CZena+1+CPost+1+
             CArtikul+1+CRAzdelKod+1+COne+1+CDocNumer+1,CName);
   DelSPaceRight(SNumNakl);

   SDateNakl:=Copy(s,1+CClient+1+CArtikul+1+CDAte+1+CKol+1+CZenaZ+1+CZena+1+CPost+1+
             CArtikul+1+CRAzdelKod+1+COne+1+CDocNumer+1+CName+1,CDate);
   DelSPaceRight(SDateNakl);

   SOp:=Copy(s,1+CClient+1+CArtikul+1+CDAte+1+CKol+1+CZenaZ+1+CZena+1+CPost+1+
             CArtikul+1,CRAzdelKod);
   DelSPaceRight(Sop);
   SOp:=GetOperatorField(FNAme,sOp);
   DelSPaceRight(sOp);

   SInd:=Copy(s,1+CClient+1+CArtikul+1+CDAte+1+CKol+1+CZenaZ+1+CZena+1+CPost+1+
             CArtikul+1+CRAzdelKod+1,COne);
   DelSPaceRight(SInd);
   Case StrToInt(SInd) Of
   0:Begin SInd:='Нет' End;
   1:Begin SInd:='Есть' End;
   Else sInd:='???';
   End;
   DelSPaceRight(SInd);

   SAkzisSbor:=Copy(s,1+CClient+1+CArtikul+1+CDAte+1+CKol+1+CZenaZ+1+CZena+1+CPost+1+
             CArtikul+1+CRAzdelKod+1+COne+1+CDocNumer+1+CName+1+CDate+1,CZenaZ);
   DelSPace(sAkzisSbor);


   SSertif:=Copy(s,1+CClient+1+CArtikul+1+CDAte+1+CKol+1+CZenaZ+1+CZena+1+CPost+1+
             CArtikul+1+CRAzdelKod+1+COne+1+CDocNumer+1+CName+1+CDate+1+CZenaZ+1+CZenaZ+1,CNAme+1+CNAme);

   SNArt:=Copy(s,1+CClient+1+CArtikul+1+CDAte+1+CKol+1+CZenaZ+1+CZena+1+CPost+1+
             CArtikul+1+CRAzdelKod+1+COne+1+CDocNumer+1+CName+1+CDate+1+CZenaZ+1+CZenaZ+1+(CNAme+1+CNAme)+1,
		   CArtikul);
   DelSPaceRight(sNArt);
   DelSPaceRight(ssertif);


   sNGTD:=GetField(FNGTD,SPost,SDAte,SNumer,SArt);
   sMarka:=GetField(FMarka,SPost,SDAte,SNumer,SArt);
   sFirma:=GetField(FFirmaPost,SPost,SDAte,SNumer,SArt);
   sVirabotano:=GetField(FVirabotano,SPost,SDAte,SNumer,SArt);
   sGodnost:=GetField(FGodnost,SPost,SDAte,SNumer,SArt);




   s[0]:=Chr(1+CClient+1+CArtikul+1+CDAte+1+CKol+1+CZenaZ+1+CZena+1+CPost);

   While Pos('│',s)>0 Do
    Begin
     w:=Pos('│',s);
     System.Delete(s,w,1);
     System.Insert(SeparatorChar,s,w);
    End;

   Writeln(txt,Space+s);




   Writeln(txt,Space+'Код:'+SArt+SeparatorChar+'N накл.:'+SNumer+SeparatorChar+'Акцизный сбор:'+SAkzisSbor+
   +SeparatorChar+'Рег.марка:'+SInd);
   Writeln(txt,Space+'N накл.пост.:'+SNumNakl+SeparatorChar+'Дата накл.пост.:'+SDAteNakl+SeparatorChar+
   'Оператор:'+Sop);
   Writeln(txt,Space+Seria_Akzis^+':'+SMarka+SeparatorChar+'Выработано:'+SVirabotano+SeparatorChar+
   'Реализовать до:'+SGodnost);
   Writeln(txt,Space+'ГТД:'+SNGTD+SeparatorChar+'Фирма-производитель:'+SFirma);
   Writeln(txt,Space+'Сертификат:'+SSertif+' ('+SNArt+')');
   Writeln(txt,Space+'──────────────────────────────────────────────────────────────────────────');
  End;
 Writeln(txt,Space+'────────────────────────────────────────────────────────────────────────────');
 Writeln(txt,Space+' Всего приход: ',AllKol,' шт');
 Writeln(txt,Space+' Всего по Р/Ц: ',AllRZ);
 Writeln(txt);
 Writeln(txt,Space,'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
 Writeln(txt,Space+'============================================================================');
 System.Close(txt);
NoInfoMsg;
ReportNew(Path^.Dat.ToTemp+'findprh!.txt','',1,False,False);
End;







Begin

End.