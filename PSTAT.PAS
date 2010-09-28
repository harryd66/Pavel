{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}
Unit PStat;


Interface


Uses Dialogs,Drivers,Glob,Access,ServStr,MyCalc,LockInfo,DStat,TStatu,TStatu2,Utils;


Type
  PPrihodStatWindow = ^TPrihodStatWindow;
  TPrihodStatWindow = object(TDialog)
    procedure OpenPrihodStatWindow;
    procedure Refresh;
         procedure Rashet;
         procedure DrawFullName;
         Procedure RefreshToDisk(Const P1,P2:PBox);
         Procedure LoadFromDisk;
         procedure RefreshMake;
         Procedure AddName;
         Procedure DrawCurrent;
         Procedure SetMAska;
         constructor Init(Var l: Boolean);
         procedure HandleEvent(var Event: TEvent); virtual;
  end;


{$I Compile.INC}

implementation

uses DBEngine,Objects, Views, MsgBox,TPDate,Tools,Printers,
     App, ColorTxt,Validate,Serv,NetDbEng, Access3;
{
Type FindFiltr = Record
  Post : String[CPost];
  NSertif : String[CNSertif];
  KSertif : String[CNSertif];
  DSertifStart : String[CDate];
  DSertifStop : String[CDate];
  NGTD : String[CNSertif];
  MArka : String[CNSertif];
  VirabotanoStart : String[CDAte];
  VirabotanoStop : String[CDAte];
  GodnostStart : String[CDAte];
  GodnostStop : String[CDAte];
  End;

}


VAr PStatWindow:PPrihodStatWindow;
         SVidSort,SVidClient, SVidReport : Word;
         Control,ControlFullName,ControlVidClient,ControlVidReport:PView;
         Client,SelectClient,NAmeList,SelectNAmeList : PBox;
         StartDate,StopDate:TDateString;
         ControlExtend,ControlStart,ControlStop:PView;
         ControlVidSort,ControlNameCount,ControlMAkeCount,ControlCurrentKol,ControlCurrentRZ,
         ControlCurrentZZ : PView;
         PrevCurrent,PrevName: String;
      {Filtr : FindFiltr;}
      Extend : Word;

(*

Function InputShablon:Boolean;
Label 1;
var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  UU : FindFiltr;
  c : Word;
  Test : LongInt;

begin
InputShablon:=False;
UU:=Filtr;
1:
R.Assign(5, 6, 75, 16);
New(Dlg, Init(R, 'Свойства выборки по приходу'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;

Dlg^.HelpCtx := $E002;

R.Assign(27, 1, 44, 2);
Control := New(PInputLine, Init(R, CPost));
Dlg^.Insert(Control);

  R.Assign(44, 1, 47, 2);
  Dlg^.Insert(New(PHistory, Init(R, PInputline(Control), 99)));

  R.Assign(12, 1, 27, 2);
  Dlg^.Insert(New(PLabel, Init(R, 'П~р~оизводитель:', Control)));

R.Assign(27, 2, 69, 3);
Control := New(PInputLine, Init(R, CNSertif));
Dlg^.Insert(Control);

  R.Assign(15, 2, 27, 3);
  Dlg^.Insert(New(PLabel, Init(R, '~С~ертификат:', Control)));

R.Assign(27, 3, 69, 4);
Control := New(PInputLine, Init(R, CNSertif));
Dlg^.Insert(Control);

  R.Assign(16, 3, 27, 4);
  Dlg^.Insert(New(PLabel, Init(R, '~К~ем выдан:', Control)));

R.Assign(27, 4, 37, 5);
Control := New(PInputLine, Init(R, CDate));
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PPXPictureValidator, Init(DateFiltr, True));

  R.Assign(1, 4, 27, 5);
  Dlg^.Insert(New(PLabel, Init(R, 'Срок д~е~йствия истекает с:', Control)));

R.Assign(41, 4, 51, 5);
Control := New(PInputLine, Init(R, CDate));
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PPXPictureValidator, Init(DateFiltr, True));

  R.Assign(37, 4, 41, 5);
  Dlg^.Insert(New(PLabel, Init(R, '~п~о:', Control)));

R.Assign(27, 5, 69, 6);
Control := New(PInputLine, Init(R, CNSertif));
Dlg^.Insert(Control);

  R.Assign(20, 5, 27, 6);
  Dlg^.Insert(New(PLabel, Init(R, 'N ~Г~ТД:', Control)));

R.Assign(27, 6, 69, 7);
Control := New(PInputLine, Init(R, CNSertif));
Dlg^.Insert(Control);

  R.Assign(20, 6, 27, 7);
  Dlg^.Insert(New(PLabel, Init(R, 'Акц~и~з:', Control)));

R.Assign(27, 7, 37, 8);
Control := New(PInputLine, Init(R, CDAte));
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PPXPictureValidator, Init(DateFiltr, True));

  R.Assign(2, 7, 27, 8);
  Dlg^.Insert(New(PLabel, Init(R, 'Диапа~з~он производства с:', Control)));

R.Assign(41, 7, 51, 8);
Control := New(PInputLine, Init(R, CDAte));
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PPXPictureValidator, Init(DateFiltr, True));

  R.Assign(37, 7, 41, 8);
  Dlg^.Insert(New(PLabel, Init(R, 'п~о~:', Control)));

R.Assign(27, 8, 37, 9);
Control := New(PInputLine, Init(R, CDate));
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PPXPictureValidator, Init(DateFiltr, True));

  R.Assign(1, 8, 27, 9);
  Dlg^.Insert(New(PLabel, Init(R, 'Срок реализа~ц~.истекает с:', Control)));

R.Assign(41, 8, 51, 9);
Control := New(PInputLine, Init(R, CDate));
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PPXPictureValidator, Init(DateFiltr, True));

  R.Assign(37, 8, 41, 9);
  Dlg^.Insert(New(PLabel, Init(R, 'по:', Control)));

Dlg^.SelectNext(False);

Dlg^.SetDAta(UU);

c:=Desktop^.ExecView(Dlg);
If c<>cmCancel Then
 Begin
  Dlg^.GetData(UU);
  Dispose(Control,Done);
  Dispose(Dlg,Done);

  With UU Do
  Begin
   DelSpaceRight(Post);
   DelSpaceRight(NSertif);
   DelSpaceRight(KSertif);
   DelSpaceRight(NGTD);
   DelSpaceRight(MArka);
   DelSpace(DSertifStart);
   DelSpace(DSertifStop);
   DelSpace(VirabotanoStart);
   DelSpace(VirabotanoStop);
   DelSpace(GodnostStart);
   DelSpace(GodnostStop);
  End;{With}

  If UU.DSertifStart[0]<>#0 Then
   Begin
   If Not(TestDate(UU.DSertifStart,Test)) Then
    Begin
     MessageBox(^M+#3'Ошибка при вводе начала периода срока действия сертификата!',Nil,mfError+mfCancelButton);
     Goto 1;
    End;
   End;

  If UU.DSertifStop[0]<>#0 Then
   Begin
   If Not(TestDate(UU.DSertifStop,Test)) Then
    Begin
     MessageBox(^M+#3'Ошибка при вводе окончания периода срока действия сертификата!',Nil,mfError+mfCancelButton);
     Goto 1;
    End;
   End;

  If UU.VirabotanoStart[0]<>#0 Then
   Begin
   If Not(TestDate(UU.VirabotanoStart,Test)) Then
    Begin
     MessageBox(^M+#3'Ошибка при вводе начало периода срока выработки!',Nil,mfError+mfCancelButton);
     Goto 1;
    End;
   End;

  If UU.VirabotanoStop[0]<>#0 Then
   Begin
   If Not(TestDate(UU.VirabotanoStop,Test)) Then
    Begin
     MessageBox(^M+#3'Ошибка при вводе окончания периода срока выработки!',Nil,mfError+mfCancelButton);
     Goto 1;
    End;
   End;

  If UU.GodnostStart[0]<>#0 Then
   Begin
   If Not(TestDate(UU.GodnostStart,Test)) Then
    Begin
     MessageBox(^M+#3'Ошибка при вводе начала периода срока реализации!',Nil,mfError+mfCancelButton);
     Goto 1;
    End;
   End;

  If UU.GodnostStop[0]<>#0 Then
   Begin
   If Not(TestDate(UU.GodnostStart,Test)) Then
    Begin
     MessageBox(^M+#3'Ошибка при вводе окончания периода срока реализации!',Nil,mfError+mfCancelButton);
     Goto 1;
    End;
   End;

   Filtr:=UU;
   InputShablon:=True;

 End
Else
 Begin
  Dispose(Control,Done);
  Dispose(Dlg,Done);
 End;
end;
*)



procedure TPrihodStatWindow.OpenPrihodStatWindow;
Var l : Boolean;
begin
  if Message(Desktop, evBroadcast, cmAliaBakPrihod, nil) = nil then
  begin
    DInfo('Инициализация анализа...');
    L:=True;
    PStatWindow := New(PPrihodStatWindow, Init(L));
    If L Then
    Begin
    Application^.InsertWindow(PStatWindow);
    NoInfo;
    End
    Else
        Begin
         Status:=DocNormal;
         Dispose(PStatWindow,Done);
         NoInfo;
        End;
  end
  else
  if PView(PStatWindow) <> Desktop^.TopView then PStatWindow^.Select;
end;



constructor TPrihodStatWindow.Init(Var l: Boolean);
VAr r :TRect;
    ClientFile : ClientFileType;
    i : Word;
    S : String;
Begin
R.Assign(1, 0, 78, 23);
inherited Init(R, '');
Options := Options or ofCenterX or ofCenterY;
HelpCtx:=$E602;


R.Assign(45, 0, 55, 1);
ControlStart := New(PInputLine, Init(R, CDate));
Insert(ControlStart);
  PInputLine(ControlStart)^.Validator := New(PPXPictureValidator, Init('[##-##-##]', True));

ControlStart^.SetData(startDate);

  R.Assign(42, 0, 45, 1);
  Insert(New(PLabel, Init(R, 'с:', ControlStart)));

R.Assign(59, 0, 69, 1);
ControlStop := New(PInputLine, Init(R, CDate));
Insert(ControlStop);
  PInputLine(ControlStop)^.Validator := New(PPXPictureValidator, Init('[##-##-##]', True));

ControlStop^.SetData(StopDate);

  R.Assign(55, 0, 59, 1);
  Insert(New(PLabel, Init(R, '~п~о:', ControlStop)));

R.Assign(38, 2, 39, 9);
Control := New(PScrollBar, Init(R));
Insert(Control);

R.Assign(1, 2, 38, 9);
NameList := New(PBox, Init(R, 1, PScrollbar(Control)));
NameList^.NewList(New(PTextCollection, Init(0,1)));
NameList^.HelpCtx:=$E586;
NameList^.FocusItem(0);
Insert(NameList);

  R.Assign(1, 1, 38, 2);
  Insert(New(PLabel, Init(R, 'База наименований товара    Код  Фас', NameList)));

R.Assign(76, 2, 77, 9);
Control := New(PScrollBar, Init(R));
Insert(Control);

R.Assign(39, 2, 76, 9);
SelectNameList := New(PBox, Init(R, 1, PScrollbar(Control)));
SelectNameList^.NewList(New(PTextCollection, Init(0,1)));
SelectNameList^.HelpCtx:=$E596;
SelectNameList^.FocusItem(0);
Insert(SelectNameList);

  R.Assign(39, 1, 76, 2);
  Insert(New(PLabel, Init(R, 'Выбранные наименования       Код Фас', SelectNAmeList)));


R.Assign(2, 9, 23, 10);
Control := New(PColoredText, Init(R, 'Наименование товара:', $74));
Insert(Control);

R.Assign(24, 9, 76, 10);
ControlFullName := New(PColoredText, Init(R, #3+' ', $7E));
Insert(ControlFullNAme);


R.Assign(2, 12, 19, 14);
ControlVidReport := New(PRadioButtons, Init(R,
  NewSItem('Полн~ы~й',
  NewSItem('Спе~ц~иальный', Nil))));
Insert(ControlVidReport);

ControlVidReport^.SetData(sVidReport);

  R.Assign(2, 11, 14, 12);
  Insert(New(PLabel, Init(R, 'Вид отчета:', ControlVidReport)));

R.Assign(2, 15, 20, 18);
ControlVidSort := New(PRadioButtons, Init(R,
  NewSItem('~Д~ата',
  NewSItem('~Н~аименование',
  NewSItem('~П~оставщик', Nil)))));
Insert(ControlVidSort);

  R.Assign(2, 14, 14, 15);
  Insert(New(PLabel, Init(R, 'Сортировка:', ControlVidSort)));
  ControlVidSort^.SetData(SVidSort);



R.Assign(2, 19, 14, 22);
ControlVidClient := New(PRadioButtons, Init(R,
  NewSItem('К~л~иент',
  NewSItem('~С~клад',
  NewSItem('~О~бмен', Nil)))));
Insert(ControlVidClient);
ControlVidClient^.SetData(sVidClient);

  R.Assign(2, 18, 16, 19);
  Insert(New(PLabel, Init(R, 'Вид операций:', ControlVidClient)));

R.Assign(2, 22, 20, 23);
ControlExtend := New(PCheckBoxes, Init(R,
  NewSItem('Рас~ш~иренный', Nil)));
Insert(ControlExtend);
ControlExtend^.SetData(Extend);


R.Assign(47, 12, 48, 22);
Control := New(PScrollBar, Init(R));
Insert(Control);

R.Assign(21, 12, 47, 22);
Client := New(PBox, Init(R, 1, PScrollbar(Control)));
Client^.NewList(New(PTextCollection, Init(0,1)));
Client^.HelpCtx:=$E586;
Client^.FocusItem(0);
Insert(Client);

  R.Assign(20, 11, 38, 12);
  Insert(New(PLabel, Init(R, 'База поставщиков:', Client)));

R.Assign(76, 12, 77, 22);
Control := New(PScrollBar, Init(R));
Insert(Control);

R.Assign(49, 12, 76, 22);
SelectClient:= New(PBox, Init(R, 1, PScrollbar(Control)));
SelectClient^.NewList(New(PTextCollection, Init(0,1)));
SelectClient^.HelpCtx:=$E596;
SelectClient^.FocusItem(0);
Insert(SelectClient);

  R.Assign(48, 11, 70, 12);
  Insert(New(PLabel, Init(R, 'Выбранные поставщики:', SelectClient)));

R.Assign(49, 10, 71, 11);
Control := New(PColoredText, Init(R, ' Выбрано наименований:', $74));
Insert(Control);

R.Assign(71, 10, 76, 11);
ControlNAmeCount := New(PColoredText, Init(R, #3+'0', $4E));
Insert(ControlNAmeCount);


R.Assign(50, 22, 71, 23);
Control := New(PColoredText, Init(R, ' Выбрано поставщиков:', $74));
Insert(Control);

R.Assign(71, 22, 76, 23);
ControlMAkeCount := New(PColoredText, Init(R, #3+'0', $4E));
Insert(ControlMAkeCount);

R.Assign(2, 10, 12, 11);
Control := New(PColoredText, Init(R, 'На складе:', $74));
Insert(Control);

R.Assign(12, 10, 17, 11);
ControlCurrentKol := New(PColoredText, Init(R, #3+'?', $7E));
Insert(ControlCurrentKol);

R.Assign(18, 10, 22, 11);
Control := New(PColoredText, Init(R, 'Р/Ц:', $74));
Insert(Control);

R.Assign(22, 10, 30, 11);
ControlCurrentRZ := New(PColoredText, Init(R, '???', $7E));
Insert(ControlCurrentRZ);

R.Assign(31, 10, 35, 11);
Control := New(PColoredText, Init(R, 'З/Ц:', $74));
Insert(Control);

R.Assign(35, 10, 43, 11);
ControlCurrentZZ := New(PColoredText, Init(R, '???', $7E));
Insert(ControlCurrentZZ);

R.Assign(1, 0, 42, 1);
Control := New(PColoredText, Init(R, 'Формирование выборки по приходам товара', $4F));
Insert(Control);

SelectNext(False);
PrevCurrent[0]:=#0;
PrevName[0]:=#0;
l:=True;
LoadFromDisk;
AddName;
Refresh;
RefreshMake;
SetMAska;

End;


procedure TPrihodStatWindow.Refresh;
Var Id :PBufBazType;
    Res : Word;
    Baz : File;
    ws,s: String;
    Count,c : Word;
Begin

DInfo('Обновляю список наименований...');
NameList^.NewList(Nil);
NameList^.NewList(New(PTextCollection, Init(0,1)));

{New(Id,Init);}
Assign(RazdelFile,Path^.Dat.ToRazdel+'razdel.db');
Res:=IOResult;
Reset(RazdelFile);
Res:=IOResult;
If Res=0 Then
 Begin
  While Not(Eof(RazdelFile)) Do{!!!!!!!!!}
  Begin
  Read(RazdelFile,RazdelElement);
  If RazdelElement.Employ Then
  Begin

  Assign(Baz,Path^.Dat.ToName+RazdelElement.Kod+'.id');
  Res:=IOResult;
  Reset(Baz,SizeOf(BazType));
  Res:=IOResult;
  If Res=0 Then
   Begin
    While Not (Eof(Baz)) Do
     Begin
      Count:=0;
      New(Id,Init);
      ReadBufBaz(Baz,Id,Count);

For c:=1 To Count Do
Begin
      If Id^.Point.Dat[c].Employ Then
       Begin
        ws:=Id^.Point.Dat[c].BazKod;
        s:=Id^.Point.Dat[c].NAme{GetIdField(FName,ws)};
        DelSpaceRight(s);
        If RazdelElement.EnableDoc=1 Then s:='■'+s;
        Format(S,CNAme);
        s:=s+'│'+ws+'│';
        ws:=Id^.Point.Dat[c].InPack{GetIdField(FInPack,ws)};
        DelSpaceRight(ws);
        RFormat(wS,CInPaCk);
        s:=s+ws;
        NameList^.List^.Insert(NewStr(s));
        NameList^.SetRange(NameList^.List^.Count);
       End;
End;{For}
     Dispose(Id,Done);
          End;{While}
    System.Close(Baz);
   End
   Else
         MessageBox(^M+#3'Ошибка открытия '+Path^.Dat.ToName+RazdelElement.Kod+'.id Код:'+IntToStr(Res,CLitr)+ClicProgrammer^,
	    Nil,mfError+mfCancelButton);
{    NoInfoMsg;}
   End;{RazdelElement.Employ}

  End;{While Not(Eof(RazdelFile))}
  System.Close(RazdelFile);
 End
 Else
   MessageBox(^M+#3'Ошибка открытия '+Path^.Dat.ToRazdel+'Razdel.db'^M+ClicProgrammer^,Nil,mfError+mfCancelButton);


NameList^.FocusItem(0);
NameList^.HelpCtx:=$E586;
Insert(NameList);
NoInfo;
PrevCurrent[0]:=#0;
PrevName[0]:=#0;
Redraw;
End;


Procedure TPrihodStatWindow.AddName;
Var R : TRect;
    R1,R2 : Real;
    s1,s2 :String[CIZena+1];
    i : Word;
    r3: Word;
Begin

Dispose(ControlNameCount,Done);
R.Assign(71, 10, 76, 11);
ControlNameCount := New(PColoredText, Init(R, #3+IntToStr(SelectNameList^.List^.Count,CKol), $4E));
Insert(ControlNameCount);

Dispose(ControlMakeCount,Done);
R.Assign(71, 22, 76, 23);
ControlMAkeCount := New(PColoredText, Init(R, #3+IntToStr(SelectClient^.List^.Count,CKol), $4E));
Insert(ControlMAkeCount);
Redraw;
End;




Procedure TPrihodStatWindow.RefreshMake;
Var R : TRect;
    CLE : PBufClientType;
    CLF : File;
    Res : Word;
    c,Count : Word;
    s,ws:String;
Begin
CAse SVidClient Of
0:s:=Path^.Dat.ToClient+'make.db';
1:s:=Path^.Dat.ToClient+'sklad.db';
2:s:=Path^.Dat.ToClient+'barter.db';
Else Exit;;
End;

DInfoMsg('Обновляю список поставщиков...',False);

Client^.NewList(Nil);
Client^.NewList(New(PTextCollection, Init(0,1)));

  Assign(CLF,s);
  Res:=IOResult;
  Reset(CLF,SizeOf(ClientType));
  Res:=IOResult;
  If Res=0 Then
   Begin

    While Not (Eof(ClF)) Do
     Begin
      New(CLE,Init);
      Count:=0;
      ReadBufClient(ClF,CLE,Count);
For c:=1 To Count Do
Begin
      If CLE^.Point.Dat[c].Employ Then
       Begin
        ws:=CLE^.Point.Dat[c].Kod;
        s:=CLE^.Point.Dat[c].Name;
        DelSpaceRight(s);
        Format(S,CClient);
        s:=s+'│'+ws+'│';
        Client^.List^.Insert(NewStr(s));
        Client^.SetRange(Client^.List^.Count);
       End;
End;
      Dispose(CLE,Done);
     End;{While}
    System.Close(CLF);
   End
   Else
    MessageBox(^M+#3'Ошибка открытия файла поставщиков '+s+' Код:'+IntToStr(Res,CLitr)+ClicProgrammer^,Nil,
    mfError+mfCancelButton);

Client^.FocusItem(0);
Client^.HelpCtx:=$E586;
Insert(Client);
NoInfoMsg;
Redraw;
End;



Procedure TPrihodStatWindow.DrawCurrent;
Var R : TRect;
    s,st,st2 : String;
    Artikul : ArtikulStr;
    j : Word;
    Find : Boolean;

Begin
If (NameList^.List<>Nil)And(NameList^.List^.Count>0)  Then
 Begin
  st:=NameList^.GetText(NameList^.Focused,NAmeList^.List^.Count);
  If St <> PrevCurrent Then
   Begin
         PrevCurrent:=St;
    Artikul:=Copy(st,1+CNAme+1,CArtikul);
    s :=BakGetField(FKol,Artikul,0);
    S:=IntToStr(StrToInt(s),CKol);
    DelSpace(s);
    st:=BakGetField(FRZena,Artikul,0);
    st:=RealToStr(StrToReal(st),CZena,CMAntissa);
    st2:=BakGetField(FZakupka,Artikul,0);
    st2:=RealToStr(StrToReal(st2),CZenaZ,CMAntissaZ);

         Dispose(ControlCurrentKol,Done);
         R.Assign(12, 10, 17, 11);
         ControlCurrentKol := New(PColoredText, Init(R, #3+s, $7E));
         Insert(ControlCurrentKol);

         Dispose(ControlCurrentRZ,Done);
    R.Assign(22, 10, 30, 11);
    ControlCurrentRZ := New(PColoredText, Init(R, st, $7E));
    Insert(ControlCurrentRZ);

    Dispose(ControlCurrentZZ,Done);
    R.Assign(35, 10, 43, 11);
    ControlCurrentZZ := New(PColoredText, Init(R, st2, $7E));
    Insert(ControlCurrentZZ);

    Redraw;
        End;
 End
 Else
  Begin
        PrevCurrent[0]:=#0;
   s:='???';
   If (PStaticText(ControlCurrentRZ)^.Text^<>'???') Then
   Begin
    Dispose(ControlCurrentKol,Done);
    R.Assign(12, 10, 17, 11);
    ControlCurrentKol := New(PColoredText, Init(R, #3+'?', $7E));
    Insert(ControlCurrentKol);

    Dispose(ControlCurrentRZ,Done);
    R.Assign(22, 10, 30, 11);
    ControlCurrentRZ := New(PColoredText, Init(R, '???', $7E));
    Insert(ControlCurrentRZ);

    Dispose(ControlCurrentZZ,Done);
    R.Assign(35, 10, 43, 11);
    ControlCurrentZZ := New(PColoredText, Init(R, '???', $7E));
    Insert(ControlCurrentZZ);
    Redraw;
   End;
  End;
End;



procedure TPrihodStatWindow.HandleEvent(var Event: TEvent);
LAbel 1,2,3;
Var test : Word;
    fstr,s,s1 : String;
    razd,SDoc : ArtikulStr;
    SDate: TDateString;
    ClientKod : ArtikulStr;
    ls : LongInt;
    l : Boolean;
    R : TRect;
    kr,Res:Word;
    Logik : Boolean;
Begin
  Case Event.What Of
  evKeyDown :
  Case Event.KeyCode Of
                kbIns: Begin
               ProdagaWindow:=False;
               ClearFind;
            If(NameList^.State and sfFocused <> 0) And (NameList^.List^.Count>=1) Then
            Begin
               s:=NAmeList^.GetText(NameList^.Focused,NAmeList^.List^.COunt);
               If TestElement(Copy(s,1+CName+1,CArtikul),SelectNameList) Then
               Begin
               s:=Copy(s,1,CName+1+CArtikul+1+CInPack);
               SelectNameList^.List^.Insert(NewStr(s));
               SelectNAmeList^.SetRange(SelectNameList^.List^.Count);
               ProdagaWindow:=False;
               s:=NAmeList^.GetText(NameList^.Focused,NameList^.List^.COunt);
               s:=Copy(s,1+CName+1,CArtikul);
               SelectNAmeList^.FocusItem(LoCation(SelectNameList,S,ProdagaWindow));
             If SelectNameList^.Focused+1<SelectNameList^.List^.Count Then
             SelectNameList^.FocusItem(SelectNameList^.List^.Count-1);
               End;
               If (NameList^.Focused+1)<NameList^.List^.Count Then
               NameList^.FocusItem(NameList^.Focused+1);
               {RefreshToDisk(SelectNameList,SelectClient);}
            End;

            If(Client^.State and sfFocused <> 0) And (Client^.List^.Count>=1) Then
            Begin
               s:=Client^.GetText(Client^.Focused,Client^.List^.COunt);
               System.Insert(IntToStr(SVidClient,COne),s,1+CClient+1);
              If TestElement(Copy(s,1+CClient+1,CArtikul),SelectClient) Then
              Begin
               SelectClient^.List^.Insert(NewStr(s));
               SelectClient^.SetRange(SelectClient^.List^.Count);
               ProdagaWindow:=False;
               s:=Copy(s,1+CClient+1,CArtikul);
               SelectClient^.FocusItem(LoCation(SelectClient,S,ProdagaWindow));
                   If SelectClient^.Focused+1<SelectClient^.List^.Count Then
               SelectClient^.FocusItem(SelectClient^.List^.Count-1);
              End;
               If (Client^.Focused+1)<Client^.List^.Count Then
               Client^.FocusItem(Client^.Focused+1);
               {RefreshToDisk(SelectNameList,SelectClient);}
            End;
              ClearEvent(Event);
                                  PrevCurrent[0]:=#0;
              AddName;
            End;

  kbCtrLDel: Begin
               ClearFind;
               ProdagaWindow:=False;
     If (SelectNameList^.State and sfFocused <> 0) And (SelectNameList^.List<>Nil)And(SelectNameList^.List^.Count>=1) Then
            Begin
             SelectNameList^.NewList(nil);
             SelectNameList^.NewList(New(PTextCollection, Init(0,1)));
             {RefreshToDisk(SelectNameList,SelectClient);}
            End;

     If (SelectClient^.State and sfFocused <> 0) And (SelectClient^.List<>Nil)And(SelectClient^.List^.Count>=1) Then
            Begin
             SelectClient^.NewList(nil);
             SelectClient^.NewList(New(PTextCollection, Init(0,1)));
             {RefreshToDisk(SelectNameList,SelectClient);}
            End;
             ClearEvent(Event);
             AddName;
                                 PrevCurrent[0]:=#0;
            End;

     kbShiftDel: Begin
                ClearFind;
               ProdagaWindow:=False;
     If (SelectNameList^.State and sfFocused <> 0) And (SelectNameList^.List<>Nil)And(SelectNameList^.List^.Count>=1) Then
            Begin
              DInfoMSg('Минуточку...',True);
              razd:=copy(SelectNameList^.GetText(SelectNameList^.Focused,SelectNameList^.List^.Count),1+CNAme+1,CRazdelKod);
            1:
             If (SelectNameList^.List^.Count>=1) Then
             For ls :=0 To SelectNameList^.List^.Count-1 Do
              Begin
               s:=SelectNameList^.GetText(ls,SelectNameList^.List^.Count);
               If StrToInt(Copy(s,1+CNAme+1,CRazdelKod))=StrToInt(RAzd) Then
                Begin
                 {SelectNameList^.FocusItem(ls);}
                 SelectNameList^.List^.AtFree(Ls);
                 SelectNameList^.SetRange(SelectNameList^.List^.Count);
                 Dec(ls);
                 {goto 1;}
                End;
              End;

                 If SelectNameList^.Focused>0 Then
                            SelectNameList^.FocusItem(SelectNameList^.Focused);

                 If (SelectNameList^.Focused>=SelectNameList^.List^.Count)
                          and(SelectNameList^.Focused>0) Then
                   SelectNameList^.FocusItem(SelectNameList^.Focused-1);
              NoInfoMsg;
              ClearEvent(Event);
              {RefreshToDisk(SelectNameList,SelectClient);}
            End;
              AddName;
                                  PrevCurrent[0]:=#0;
            End;

     kbDel: Begin
               ClearFind;
               ProdagaWindow:=False;
     If (SelectNameList^.State and sfFocused <> 0) And (SelectNameList^.List<>Nil)And(SelectNameList^.List^.Count>=1) Then
            Begin
             SelectNameList^.List^.AtFree(SelectNameList^.Focused);
             SelectNameList^.SetRange(SelectNameList^.List^.Count);
             If SelectNameList^.Focused>0 Then
             SelectNameList^.FocusItem(SelectNameList^.Focused);

             If (SelectNameList^.Focused>=SelectNameList^.List^.Count) and(SelectNameList^.Focused>0) Then
             SelectNameList^.FocusItem(SelectNameList^.Focused-1);

              {RefreshToDisk(SelectNameList,SelectClient);}
              ClearEvent(Event);
            End;

     If (SelectClient^.State and sfFocused <> 0) And (SelectClient^.List<>Nil)And(SelectClient^.List^.Count>=1) Then
            Begin
             SelectClient^.List^.AtFree(SelectClient^.Focused);
             SelectClient^.SetRange(SelectClient^.List^.Count);
             If SelectClient^.Focused>0 Then
             SelectClient^.FocusItem(SelectClient^.Focused);

             If (SelectClient^.Focused>=SelectClient^.List^.Count) and(SelectClient^.Focused>0) Then
             SelectClient^.FocusItem(SelectClient^.Focused-1);

              {RefreshToDisk(SelectNameList,SelectClient);}
              ClearEvent(Event);
            End;
              AddName;
                                  PrevCurrent[0]:=#0;
            End;


   kbShiftIns:Begin
                ClearFind;
                 ProdagaWindow:=False;
          If ((NameList^.State and sfFocused <> 0)And(NameList^.List^.Count>= 1)) Then
            Begin
             DInfomsg('Минуточку...',True);
             razd:=copy(NameList^.GetText(NameList^.Focused,NameList^.List^.Count),1+CNAme+1,CRazdelKod);
             If NameList^.List^.Count>0 Then
             Begin
             {
             For ls :=0 To SelectNameList^.List^.Count-1 Do
              Begin
               s:=SelectNameList^.GetText(ls,SelectNameList^.List^.Count);
               If StrToInt(Copy(s,1+CNAme+1,CRazdelKod))=
                  StrToInt(RAzd) Then
                Begin
                 SelectNameList^.List^.AtFree(ls);
                 Dec(ls);
                 SelectNameList^.SetRange(SelectNameList^.List^.Count);
                End;
              End;
             }

             For ls :=0 To NameList^.List^.Count-1 Do
              Begin
               s:=NameList^.GetText(ls,NameList^.List^.Count);
               If Not TestElementMy({Copy(}s{,1+CName+1,CArtikul)},SelectNameList,kr) Then
               If StrToInt(Copy(s,1+CNAme+1,CRazdelKod))=
                  StrToInt(RAzd) Then
                Begin
                 s:=Copy(s,1,CName+1+CArtikul+1+CInPack);
                 SelectNameList^.List^.Insert(NewStr(s));
                 SelectNameList^.SetRange(SelectNameList^.List^.Count);
                End;
              End;
             End;
              NoInfoMsg;
              ProdagaWindow:=False;
              If NameList^.Focused+1<NameList^.List^.Count Then NameList^.FocusItem(NameList^.Focused+1);
              If SelectNameList^.Focused+1<SelectNameList^.List^.Count Then
              SelectNameList^.FocusItem(SelectNameList^.List^.Count-1);
             ClearEvent(Event);
             {RefreshToDisk(SelectNameList,SelectClient);}
            End;
            {else ClearEvent(Event);}
              AddName;
              SelectNameList^.FocusItem(0);
              End;
   kbGrayPlus:Begin
          If ((NameList^.State and sfFocused <> 0)And(NameList^.List^.Count>= 1)) Then
            Begin
               fstr[0]:=#0;
               Res:=0;
               ProdagaWindow:=False;
               ClearFind;
               If MaskaSelect(fstr,Res) Then
                Begin
                          DInfoMsg('Минуточку...',True);
             For ls :=0 To NameList^.List^.Count-1 Do
              Begin
               s:=NameList^.GetText(ls,NameList^.List^.Count);
               Logik:=False;
               s1:=Copy(s,1,CName);
               DelSpaceRight(s1);
               Case Res Of
               0:If (Pos(fstr,s1)>0) Or (Pos('*',Fstr)>0)Then Logik:=True;
               1:If (fstr=s1)  Then Logik:=True;
               Else ;
               End;{Case}

               If Logik Then
               If Not TestElementMy({Copy(}s{,1+CName+1,CArtikul)},SelectNameList,kr) Then
                Begin
                 s:=Copy(s,1,CName+1+CArtikul+1+CInPack);
                 SelectNameList^.List^.Insert(NewStr(s));
                 SelectNameList^.SetRange(SelectNameList^.List^.Count);
                End;{TestElement}
              End;{For}
              NoInfoMsg;
              ProdagaWindow:=False;
              If SelectNameList^.Focused+1<SelectNameList^.List^.Count Then
              SelectNameList^.FocusItem(SelectNameList^.List^.Count-1);
              AddName;
              SelectNameList^.FocusItem(0);
                End;{Maska}
            Redraw;
            End;{Nil}

          If ((Client^.State and sfFocused <> 0)And(Client^.List^.Count>= 1)) Then
            Begin
               fstr[0]:=#0;
               Res:=0;
               ProdagaWindow:=False;
               ClearFind;
               If MaskaSelect(fstr,Res) Then
                Begin
             DInfoMsg('Минуточку...',True);
             For ls :=0 To Client^.List^.Count-1 Do
              Begin
               s:=Client^.GetText(ls,Client^.List^.Count);
               Logik:=False;
               s1:=Copy(s,1,CClient);
                        DelSpaceRight(s1);
               Case Res Of
               0:If (Pos(fstr,s1)>0) Or (Pos('*',Fstr)>0) Then Logik:=True;
               1:If (fstr=s1) Then Logik:=True;
               Else;
               End;{Case}

               System.Insert(IntToStr(SVidClient,COne),s,1+CClient+1);

               If Logik Then
               If TestElement(Copy(s,1+CClient+1,CArtikul),SelectClient) Then
                Begin
                 SelectClient^.List^.Insert(NewStr(s));
                 SelectClient^.SetRange(SelectClient^.List^.Count);
                End;{TestElement}
              End;{For}
              NoInfoMsg;
              ProdagaWindow:=False;
              If SelectClient^.Focused+1<SelectClient^.List^.Count Then
              SelectClient^.FocusItem(SelectClient^.List^.Count-1);
              AddName;
              SelectClient^.FocusItem(0);
                End;{Maska}
              Redraw;
            End;{Nil}
              ClearEvent(Event);
              End;

   kbGrayMinus:Begin
          If ((SelectNameList^.State and sfFocused <> 0)And(SelectNameList^.List^.Count>= 1)) Then
            Begin
               fstr[0]:=#0;
               Res:=0;
               ProdagaWindow:=False;
               ClearFind;
               If MaskaSelect(fstr,Res) Then
                Begin
             DInfoMsg('Минуточку...',True);
             2:
             if (SelectNameList^.List^.Count>= 1) Then
             For ls :=0 To SelectNameList^.List^.Count-1 Do
              Begin
               s:=SelectNameList^.GetText(ls,SelectNameList^.List^.Count);
               Logik:=False;
               s1:=Copy(s,1,CName);
               DelSpaceRight(s1);
                                        Case Res Of
               0:If (Pos(fstr,s1)>0) Or (Pos('*',Fstr)>0) Then Logik:=True;
               1:If (fstr=s1) Then Logik:=True;
               Else ;
               End;{Case}

               If Logik Then
               Begin
               SelectNameList^.List^.AtFree(Ls);
               SelectNameList^.SetRange(SelectNameList^.List^.Count);
               goto 2;
               End;
              End;{For}
                 If SelectNameList^.Focused>0 Then
                            SelectNameList^.FocusItem(SelectNameList^.Focused);

                 If (SelectNameList^.Focused>=SelectNameList^.List^.Count)
                          and(SelectNameList^.Focused>0) Then
                   SelectNameList^.FocusItem(SelectNameList^.Focused-1);
              NoInfoMsg;
              ProdagaWindow:=False;
              AddName;
              SelectNameList^.FocusItem(0);
                End;{Maska}
              Redraw;
            End;{Nil}

          If ((SelectClient^.State and sfFocused <> 0)And(SelectClient^.List^.Count>= 1)) Then
            Begin
               fstr[0]:=#0;
               Res:=0;
               ProdagaWindow:=False;
               ClearFind;
               If MaskaSelect(fstr,Res) Then
                Begin
             DInfoMsg('Минуточку...',True);
             3:
             if (SelectClient^.List^.Count>= 1) Then
             For ls :=0 To SelectClient^.List^.Count-1 Do
              Begin
               s:=SelectClient^.GetText(ls,SelectClient^.List^.Count);
               Logik:=False;
               s1:=Copy(s,1,CClient);
               DelSpaceRight(s1);
               Case Res Of
                                        0:If (Pos(fstr,s1)>0)Or (Pos('*',Fstr)>0)  Then Logik:=True;
               1:If (fstr=s1)  Then Logik:=True;
               Else ;
               End;{Case}


               If Logik Then
               Begin
                SelectClient^.List^.AtFree(Ls);
                SelectClient^.SetRange(SelectClient^.List^.Count);
                goto 3;
               End;
              End;{For}
                 If SelectClient^.Focused>0 Then
                            SelectClient^.FocusItem(SelectClient^.Focused);

                 If (SelectClient^.Focused>=SelectClient^.List^.Count)
                          and(SelectClient^.Focused>0) Then
                   SelectClient^.FocusItem(SelectClient^.Focused-1);
              NoInfoMsg;
              ProdagaWindow:=False;
              AddName;
              SelectClient^.FocusItem(0);
                End;{Maska}
              Redraw;
            End;{Nil}
              ClearEvent(Event);
              End;

   kbCtrlIns: Begin
                ClearFind;
                 ProdagaWindow:=False;
          If ((NameList^.State and sfFocused <> 0)And(NameList^.List^.Count>= 1)) Then
            Begin
             DInfoMsg('Минуточку...',True);
             SelectNameList^.Focusitem(0);
             If NameList^.List^.Count>0 Then
             Begin
             SelectNameList^.NewList(nil);
             SelectNameList^.NewList(New(PTextCollection, Init(0,1)));

             For ls :=0 To NameList^.List^.Count-1 Do
              Begin
               s:=NameList^.GetText(ls,NameList^.List^.Count);
               {if Testelement(Copy(s,1+CNameList+1,CNameListKod),SelectNameListList) then}
                                         Begin
                 s:=Copy(s,1,CName+1+CArtikul+1+CInPack);
                 SelectNameList^.List^.Insert(NewStr(s));
                 SelectNameList^.SetRange(SelectNameList^.List^.Count);
                End;
              End;
             End;
                 NoInfoMsg;
                 ProdagaWindow:=False;
                 {SelectNameListList^.SetRange(SelectNameListList^.List^.Count);}
                 If NameList^.Focused+1<NameList^.List^.Count Then NameList^.FocusItem(NameList^.Focused+1);
                 If SelectNameList^.Focused+1<SelectNameList^.List^.Count Then
                 SelectNameList^.FocusItem(SelectNameList^.List^.Count-1);
                 {RefreshToDisk(SelectNameList,SelectClient);}
            End;
            {Else ClearEvent(Event);}

          If ((Client^.State and sfFocused <> 0)And(Client^.List^.Count>= 1)) Then
            Begin
             DInfoMsg('Минуточку...',True);
             SelectClient^.Focusitem(0);
             If Client^.List^.Count>0 Then
             Begin

             SelectClient^.NewList(nil);
             SelectClient^.NewList(New(PTextCollection, Init(0,1)));

             For ls :=0 To Client^.List^.Count-1 Do
              Begin
               s:=Client^.GetText(ls,Client^.List^.Count);
               System.Insert(IntToStr(SVidClient,COne),s,1+CClient+1);
               {If TestElement(Copy(s,1+CClient+1,CArtikul),SelectClient) Then}
                Begin
                 SelectClient^.List^.Insert(NewStr(s));
                 SelectClient^.SetRange(SelectClient^.List^.Count);
                End;
              End;
             End;
              NoInfoMsg;
              ProdagaWindow:=False;
              If Client^.Focused+1<Client^.List^.Count Then Client^.FocusItem(Client^.Focused+1);
              If SelectClient^.Focused+1<SelectClient^.List^.Count Then
              SelectClient^.FocusItem(SelectClient^.List^.Count-1);
              {RefreshToDisk(SelectNameList,SelectClient);}
            End;
             SelectClient^.Focusitem(0);
                ClearEvent(Event);
              AddName;
                                  PrevCurrent[0]:=#0;
            End;


        kbEsc: Begin
{                   Dispose(SControlPos,Done);
                    Dispose(SControlDop,Done);}
                    Event.What:=evCommand;
                    Event.Command:=cmCancel;
                    PutEvent(Event);
                    ClearEvent(Event);
                  End;
         Else;
         End;{KeyDown}
  evCommand :
        Case Event.Command Of
  cmRefresh :Begin
              Refresh;
              RefreshMake;
             End;

  cmCalcStat :Begin
              ClearFind;
              If (SelectNameList^.List<>Nil)And(SelectNAmeList^.List^.Count>0) And
                       (SelectClient^.List<>Nil)And(SelectClient^.List^.Count>0)  Then
             Begin
               {проверяем стартовую дату}

               ControlVidReport^.GetData(SVidReport);
               ControlExtend^.GetData(Extend);
               ControlVidSort^.GetData(SVidSort);

               ControlStart^.GetData(startDAte);
               ControlStart^.GetData(startDAte);
               ControlStart^.GetData(startDAte);
               If Not(TestDate(startDate,Ls)) Then
                Begin
                 MessageBox(^M+#3'Ошибка при вводе начала периода!',Nil,mfError+mfCancelButton);
                 ClearEvent(Event);
                 Exit;
                End;
               {проверям конечную дату}
               ControlStop^.GetData(stopDate);
               If Not(TestDate(stopDate,Ls)) Then
                                         Begin
                 MessageBox(^M+#3'Ошибка при вводе конца периода!',Nil,mfError+mfCancelButton);
                 ClearEvent(Event);
                 Exit;
                End;


               {назначаем диапазон дат}

               If DateStringToDate(DateMask,StartDate)>DateStringToDate(DateMask,StopDate) Then
                Begin
                 s1:=StartDate;
                 StartDate:=stopDate;
                 StopDate:=s1;
                End;

               ControlStart^.SetData(startDate);
               ControlStop^.SetData(stopDate);


               {GroupCalcWindow^.Start(l);}
               ClearEvent(Event);

               RefreshToDisk(SelectNameList,SelectClient);

               If Extend=1 Then
               Begin
               {if InputShablon Then} Rashet;
               End
               Else
                                    Rashet;
               {MessageBox(^M+#3'Начало расчета!',Nil,mfInformation+mfCancelButton);}
             End
               Else
                Begin
              If (SelectNameList^.List=Nil)Or(SelectNAmeList^.List^.Count=0) Then
                 Begin
                 MessageBox(^M+#3'Список выбранных наименований - пустой!',Nil,mfError+mfCancelButton);
                 ClearEvent(Event);
                 Exit;
                 End;

              If (SelectClient^.List=Nil)Or(SelectClient^.List^.Count=0) Then
                 Begin
                 MessageBox(^M+#3'Список выбранных поставщиков - пустой!',Nil,mfError+mfCancelButton);
                 ClearEvent(Event);
                 Exit;
                 End;
                End;

              End;

cmAliaBakPrihod:Begin
                 ClearEvent(Event);
                End;
        cmCancel    : Begin
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
         (Event.Command = cmAliaBakPrihod) then ClearEvent(Event);

inherited HandleEvent(Event);

  If (Desktop^.Current=PView(PStatWindow)) And (Event.What <> EvKeyDown) Then
   Begin

          if (ControlVidClient^.State and sfFocused <> 0)Then
              Begin
               ControlVidClient^.GetData(Test);
               If Test <> SVidClient Then
                                        Begin
                                                SVidClient:=Test;
                                                RefreshMake;
                                        End;
                 End;

          if (ControlVidReport^.State and sfFocused <> 0)Then
              Begin
               ControlVidReport^.GetData(Test);
               If Test <> SVidReport Then
                                        Begin
                                          SVidReport:=Test;
                                          SetMAska;
                           redraw;
                                        End;
                 End;

                DrawCurrent;
                DrawFullNAme;
   End;



End;


Procedure TPrihodStatWindow.RefreshToDisk(Const P1,P2:PBox);
VAr f,f2 : Text;
         s : String;
    i : Word;
    c : Word;
Begin
DInfoMsg('Сохраняю выборку...',True);
Assign(f,Path^.Dat.ToUtils+'selname.txt');
i:=IOResult;
Rewrite(f);
i:=IOResult;
If i<>0 Then
 Begin
  NoInfoMsg;
  MessageBox(^M+#3'Ошибка создания файла '+Path^.Dat.ToUtils+'selname.txt Код:'+IntToStr(i,CLitr)+' '+ClicProgrammer^,Nil,
  mfError+mfCancelButton);
  Exit;
 End;

Assign(f2,Path^.Dat.ToUtils+'selmake.txt');
i:=IOResult;
Rewrite(f2);
i:=IOResult;

If i<>0 Then
 Begin
  NoInfoMsg;
  i:=IOResult;
  System.Close(f);
  MessageBox(^M+#3'Ошибка создания файла '+Path^.Dat.ToUtils+'selmake.txt Код:'+IntToStr(i,CLitr)+' '+ClicProgrammer^,Nil,
  mfError+mfCancelButton);
  Exit;
 End;

ControlStart^.GetData(s);
Writeln(f,s);

ControlStop^.GetData(s);
Writeln(f,s);

ControlVidReport^.GetData(c);
Writeln(f,c);

ControlVidSort^.GetData(c);
Writeln(f,c);

ControlVidClient^.GetData(c);
Writeln(f,c);

If P1^.List^.Count>0 Then
Begin
 For c:=0 To P1^.List^.Count-1 Do
 Begin
  s:=P1^.GetText(c,P1^.List^.Count);
  Writeln(f,s);
 End;
End;

If P2^.List^.Count>0 Then
Begin
 For c:=0 To P2^.List^.Count-1 Do
 Begin
  s:=P2^.GetText(c,P2^.List^.Count);
  Writeln(f2,s);
 End;
End;

i:=IOResult;
System.Close(f);
i:=IOResult;
i:=IOResult;
System.Close(f2);
i:=IOResult;
NoInfoMsg;
End;


Procedure TPrihodStatWindow.SetMAska;
Begin
If SVidReport=0 Then
 Begin
   PCluster(ControlVidSort)^.SetButtonState($2, False);
   ControlVidSort^.GetDAta(SVidSort);
   If SVidSort=1 Then
     Begin
      SVidSort:=0;
      ControlVidSort^.SetDAta(SVidSort);
     End;
 End
Else
 Begin
   PCluster(ControlVidSort)^.SetButtonState($2, True);
 End
End;


Procedure TPrihodStatWindow.LoadFromDisk;
Var f,f1:Text;
    Res:Word;
    s : String;
Begin
  Assign(f,Path^.Dat.ToUtils+'selmake.txt');
  Res:=IOResult;
  Reset(f);
  Res:=IOResult;
  If Res=0 Then
   Begin
    SelectClient^.NewList(Nil);
    SelectClient^.NewList(New(PTextCollection, Init(0,1)));
    While Not (Eof(f)) Do
     Begin
      ReadLn(f,s);
      SelectClient^.List^.Insert(NewStr(s));
      SelectClient^.SetRange(SelectClient^.List^.Count);
     End;
    Res:=IOResult;
    System.Close(f);
    Res:=IOResult;
   End{Res=0};

  SelectClient^.FocusItem(0);
  SelectClient^.HelpCtx:=$E586;
  Insert(SelectClient);

  Assign(f,Path^.Dat.ToUtils+'selname.txt');
  Res:=IOResult;
  Reset(f);
  Res:=IOResult;
  If Res=0 Then
   Begin
    SelectNameList^.NewList(Nil);
    SelectNameList^.NewList(New(PTextCollection, Init(0,1)));
    Readln(f,s);
    ControlStart^.SetData(s);
    Readln(f,s);
    ControlStOp^.SetData(s);
    Readln(f,s);
    Res:=IOResult;
    SVidReport:=StrToInt(s);
    ControlVidReport^.SetData(SVidReport);
    Readln(f,s);
    Res:=IOResult;
    SVidSort:=StrToInt(s);
    ControlVidSort^.SetData(SVidSort);
    Res:=IOResult;
    Readln(f,s);
    SVidClient:=StrToInt(s);
    ControlVidClient^.SetData(SVidClient);
    Res:=IOResult;
    While Not (Eof(f)) Do
     Begin
      ReadLn(f,s);
      SelectNameList^.List^.Insert(NewStr(s));
      SelectNameList^.SetRange(SelectNameList^.List^.Count);
     End;
    Res:=IOResult;
    System.Close(f);
    Res:=IOResult;
   End{Res=0};
SelectNameList^.FocusItem(0);
SelectNameList^.HelpCtx:=$E586;
Insert(SelectNameList);
End;


Procedure TPrihodStatWindow.Rashet;
 const Space=' ';
 var
    StatPrih, ItogList, PrimechList: PStringCollection;
    SortStatPrih, SertList: PStringCollection;
    LStart,LStop,cur,lDat: longint;
    Prih: PPrihodType;
    PrihFile: PrihodFileType;
    OtchFile: text;
    IOrez,i,ii,l,p,posBazCod,posKol,posZ,posO,
     posDate, posNum, posPost, posKodPost, posKodTov,
     posTov :word;
    NDocum: integer;
    spost,sspost,ssspost:TMyString;
    ss:Allstr;
    st, bufNAme,stsert,stsertprn,stsert1,bufsert: TMystring;
    stov:array[1..CMAX] of string[CName];
    pst: PString;
    bufDate,bufDate1: TMystring;
    BufPost,bufPost1: TMystring;
    bufNum,bufNum1: TMystring;
    bufDlName, bufDlName1:TMystring;
    sBazCod: string[CArtikul];
    sKOl:string[CKOL];
    selector, bPost, bsum0,selF1,SelF2,SelF3,SelF4,SelF5,SelF6,
    selF7,selF8: boolean;


    rKol:word;
    sumKOl:word;
     sumKolOb: longint;
     sumkolPost: longint;


    Npp: string[CKod];
    sZ_zena : AllStr;
    sO_zena: String[CZena];
    sZ_zena1,sO_Zena1:TMystring;
    rZ_zena,rO_zena,sumZ,sumO,sumZPost,sumOPost,
    sumZPost1,sumOPost1,sumZOb, sumOOb, sum0: real;
    sPak:TMystring;

    Procedure PrintItog;
     Begin
      if SVidReport=0 then
       begin
        DelSpaceRight(bufPost1);
        DelSpaceRight(bufNum1);
        lDat:=StrToInt(bufDate1);
        Write(OtchFile,space,'------');
        write(OtchFile,bufPost1,space,'N',bufNum1,' от ',DateToDateString(DateMask,lDat));
      { if Parol}
        bsum0:=false;
        if sumZ<1e-5 then
          begin
           bsum0:=True;
           sumZ:=sumO/2;
          end;
        write(OtchFile,space,'  З/Ц:');
        if bsum0 then
        writeln(OtchFile,RealTostr(0,CIZena,CMantissaZ),'; Р/Ц:',RealTostr(sumO,CIZena,CMAntissaZ),
                        ';',RealToStr((SumO-sumZ)/sumZ*100,6,2),'%')
        else
           writeln(OtchFile,RealTostr(sumZ,CIZena,CMantissaZ),'; Р/Ц:',RealTostr(sumO,CIZena,CMAntissaZ),
                        ';',RealToStr((SumO-sumZ)/sumZ*100,6,2),'%');
        if bsum0 then sumz:=0;
        writeln(OtchFile,'');
       end;

      if bPost then
        begin
          format(BufPost1,CClient);
          spost:=REalToStr(sumZPost1,CZenaZ,CMantissaZ);
          RFormat(spost,CPack);
          sspost:=REalToStr(sumOPost1,CZena,CMAntissa);
          RFormat(sspost,CPack+1);
          if sumZPost1<1e-5 then
          begin
           bsum0:=True;
           sumZPost1:=sumOPost1/2;
          end;
          ssspost:=RealToStr((sumOPost1-sumZPost1)/sumZPost1*100,5,2);
          if bsum0 then sumzpost1:=0;
          rformat(ssspost,CArtikul);
          ItogList^.Insert(NewStr(space+bufPost1+spost+space+space+sspost+space+
                 +space+ssspost));
        end;

     END;

 Begin
 {new(Pst);}
 {extend:=0;}
 if extend=0 then
  (*
  with Filtr do
   begin
    Post           := '';
    NSertif        := '';
    KSertif        := '';
    DSertifStart   := '';
    DSertifStop    := '';
    NGTD           := '';
    MArka          := '';
    VirabotanoStart:= '';
    VirabotanoStop := '';
    GodnostStart   := '';
    GodnostStop    := '';
  end;
  *)
   SertList:=New(PStringCollection,Init(0,1));
   StatPrih:=New(PStringCollection,Init(0,1));
   SortStatPrih:=New(PStringCollection,Init(0,1));
   ItogList:=New(PStringCollection,Init(0,1));
   PrimechList:=New(PStringCollection,Init(0,1));
   Assign(OtchFile,Path^.Dat.ToTemp+'protch.txt');
   rewrite(OtchFile);
   IOrez:=Ioresult;
     If IOrez <> 0 Then
     Begin
       MessageBox(#3^M+#3'Не могу создать файл '+Path^.Dat.ToTemp+'protch.txt',Nil,mfError+mfCancelButton);
       Exit;
     End;
   DInfoMsg('Минуточку...',True);
   LStart:=DateStringToDate(DateMask,StartDate);
   LStop :=DateStringToDate(DateMask ,StopDate);
   Prih:=New(PPrihodType,Init);

   for cur := LStart to LStop do
         begin
          Assign(PrihFile,Path^.Dat.ToPrihod+DateToDateString(DateMask,Cur)+'.prh');
          Reset(PrihFile);
          IORez:=Ioresult;
          If IORez <> 0 Then
          Begin
           PrimechList^.Insert(NewStr('Отказ доступа к данным за '+DateToDateString(DateMask,Cur)+
                    ' "'+DayString[DayOfWeek(cUR)]+'" '));
           Continue;
          End;

            NDocum:=1;
            while not eof(Prihfile) do
            begin

             ReadPrihod(PrihFile,Prih);

             spost:='';
             If not TestElement(inttostr(Prih^.dat.Operatorselector,cone)+Prih^.Dat.Makekod,SelectClient) Then
              begin
               spost:=GetMakeField(FClient,Prih^.dat.MAkekod,Prih^.dat.Operatorselector);
               Selector:=True;
               for i:=1 to Prih^.Dat.Amount do
               begin
                 stov[i]:='';
                 If not TestElement(Prih^.Dat.PrihodElement[i].BazKod,SelectNameList) Then
                   begin
{********************* Фильтр по сертификатам}
     (*               selF1:=false;
                    selF2:=false;
                    selF3:=false;
                    selF4:=false;
                    selF5:=false;
                    selF6:=false;
                    selF7:=false;
                    selF8:=false;
                    with Filtr Do
                     begin
                     if (Post='') or
                        (pos(post,Prih^.Dat.PrihodElement[i].Input.Post)=1)  then selF1:=true;
                     if ((NSertif='') or
                        (pos(NSertif,Prih^.Dat.PrihodElement[i].Input.NSertif)=1))
                                                               then selF2:=true;
                     {
                     if ((KSertif='') or
                        (pos(KSertif,Prih^.Dat.PrihodElement[i].Input.KSertif)=1))
                                                              then selF3:=true;}

                     {if ((DSertifStart='') and (DSertifStop='') or

                        ((DateStringToDate(DateMask,DSertifStart)<
                               DateStringToDate(DateMask,Prih^.Dat.PrihodElement[i].Input.DSertif))and
                                (DateStringToDate(DateMask,DSertifStop)>
                                DateStringToDate(DateMask,Prih^.Dat.PrihodElement[i].Input.DSertif))))
                                               then selF4:=true;}

                     if ((NGTD='') or
                        (pos(NGTD,Prih^.Dat.PrihodElement[i].Input.NGTD)=1))
                                                            then selF5:=true;
                     if ((Marka='') or
                        (pos(Marka,Prih^.Dat.PrihodElement[i].Input.Marka)=1))
                                                            then selF6:=true;
                     if ((VirabotanoStart='') and (VirabotanoStop='') or
                        ((DateStringToDate(DateMask,VirabotanoStart)<
                               DateStringToDate(DateMask,Prih^.Dat.PrihodElement[i].Input.Virabotano))and
                                (DateStringToDate(DateMask,VirabotanoStop)>
                                DateStringToDate(DateMask,Prih^.Dat.PrihodElement[i].Input.Virabotano))))
                                               then selF7:=true;
                     if ((GodnostStart='') and (GodnostStop='') or
                        ((DateStringToDate(DateMask,GodnostStart)<
                               DateStringToDate(DateMask,Prih^.Dat.PrihodElement[i].Input.Godnost))and
                                (DateStringToDate(DateMask,GodnostStop)>
                                DateStringToDate(DateMask,Prih^.Dat.PrihodElement[i].Input.Godnost))))
                                               then selF8:=true;

                     end;
                   if self1 and self2 and self3 and self4 and self5 and
                      self6 and self7 and self8 then *)
                    begin
                     stov[i]:=GetIDField(FName,Prih^.Dat.PrihodElement[i].BazKod);
                     selector:=true;
                    end;
                   end;
               end;

                if selector then
                  begin
                  for i:= 1 to Prih^.Dat.Amount do
                   if stov[i]<>'' then
                   begin

                    St:=IntToStr(Cur,CDate);{DateToDateString(DateMask,Cur);}
                    Format(St,CDate);
                      posDate:=1;
                    stsert:=IntToStr(Cur,CDate);


                    Format( SPost,CClient);
                    St:=St+sPost;
                      posPost:=posDate+CDate;

                    ss:=IntToStr(NDocum,CKod);
                    rFormat(ss,CKod);
                    st:=st+ss;
                    stsert:=stsert+ss;
                      posNum:=posPost+CCLient;


                    ss:=Prih^.Dat.Makekod;
                    Format(ss,CClientKod);
                    St:=St+ss;
                      posKodPost:=posNum+CKod;

                    ss:=stov[i];
                    Format(ss,CName);
                    st:=St+ss;
                      posTov:=posKodPost+CClientKod;

                    ss:=Prih^.Dat.PrihodElement[i].BazKod;
                    Format(ss,CArtikul);
                    st:=st+ss;
                    stsert:=stsert+ss;
                      posKodTov:=posTov+CName;
                      posBazCod:=posTov+CName;

                    ss:=Prih^.Dat.PrihodElement[i].Input.kol;
                    rformat(ss,CKOL);
                    st:=st+ss;
                      posKol:=posKodTov+CArtikul;

                    ss:=Prih^.Dat.PrihodElement[i].Input.Zakupka;
                    rformat(ss,CZenaZ);
                    st:=st+ss;
                      posZ:=posKol+CKol;


                    ss:=Prih^.Dat.PrihodElement[i].Input.R_Zena;
                    rformat(ss,CZena);
                    st:=st+ss;
                      posO:=posZ+CZenaZ;

                    StatPrih^.Insert(NewStr(st));

                    ss:=Prih^.Dat.PrihodElement[i].Input.Post;
                    format(ss,CPOST);
                    stsert:=stsert+ss;
                    ss:=Prih^.Dat.PrihodElement[i].Input.NSertif;
                    format(ss,CNsertif);
                    stsert:=stsert+ss;
                    {
                    ss:=Prih^.Dat.PrihodElement[i].Input.KSertif;
                    format(ss,CKsertif);
                    stsert:=stsert+ss;}
                    {
                    ss:=Prih^.Dat.PrihodElement[i].Input.DSertif;
                    format(ss,CDsertif);
                    stsert:=stsert+ss;}
                    ss:=Prih^.Dat.PrihodElement[i].Input.NGTD;
                    format(ss,CNsertif);
                    stsert:=stsert+ss;
                    ss:=Prih^.Dat.PrihodElement[i].Input.Marka;
                    format(ss,CNsertif);
                    stsert:=stsert+ss;
                    ss:=Prih^.Dat.PrihodElement[i].Input.Virabotano;
                    format(ss,CDsertif);
                    stsert:=stsert+ss;
                    ss:=Prih^.Dat.PrihodElement[i].Input.Godnost;
                    format(ss,CDsertif);
                    stsert:=stsert+ss;

                    SertList^.Insert(NewStr(stsert));

                   {  );}
                   end;
                  end;
              end;
             inc(NDocum);
           end;
          System.Close(PrihFile);
   end;{for cur}


                        {1  ЗОЛОТЫЕ СТРУНЫ ЖЕМЧУЖ 0.7  07227   119     9+ 11   62.46   78.90    78.90   26.32}
       Writeln(OtchFile,space,'Склад: ',GetClientField(FClient,Rek^.Dat.Kod,1)+'  Оператор: '+
	  CurrentPassword+' EYE & 1997-98');
       Writeln(OtchFile,space);
       case SVidReport of
         0: writeln(OtchFile,space+'Вид отчета: полный');
         1: writeln(OtchFile,space+'Вид отчета: специальный');
       end;

       case SVidSort of
         0: writeln(OtchFile,space,'Вид сортировки: по дате');
         1: writeln(OtchFile,space,'Вид сортировки: по наименованию');
         2: writeln(OtchFile,space,'Вид сортировки: по поставщику');
       end;
       writeln(OtchFile,space);
(*
       if extend<>0 then writeln(OTchFile,space+     'Фильтр:');
       with Filtr do
         begin
          if Post<>'' then writeln(OTchFile,space,   '            Производство: ',Post);
          if NSertif<>'' then writeln(OTchFile,space,'              Сертификат:',NSertif);
          if KSertif<>'' then writeln(OTchFile,space,'               Кем выдан: ',KSertif);
          if (DSertifStart<>'') or (DSertifStop<>'') then writeln(OTchFile,space,
             'Срок действия истекает с: ',DSertifStart,' по: ',DSertifStop);
          if NGTD<>'' then writeln(OTchFile,space,   '                   N ГТД: ',NGTD);
          if Marka<>'' then writeln(OTchFile,space,  '                   Акциз: ',Marka);
          if (VirabotanoStart<>'') or (VirabotanoStop<>'') then writeln(OTchFile,space,
              ' Диапазон производства с: ',VirabotanoStart,' по: ',VirabotanoStop);
          if (GodnostStart<>'') or (GodnostStop<>'') then writeln(OTchFile,space,
             'Срок реализации истекает с: ',GodnostStart,' по: ',GodnostStop);
         end;
*)
       writeln(OTchFile,space);
       writeln(OtchFile,space+'      СПРАВКА О ПРИХОДАХ НА СКЛАДЫ ЗА ПЕРИОД С ',StartDAte,
                        ' по ',StopDate,'  ('+Times+')');
       writeln(OtchFile);

   case SVidReport of
    0:begin;                 {1   ЗОЛОТЫЕ СТРУНЫ ЖЕМЧУЖ 0.7  07227   119     9+ 11   62.46   78.90    78.90   26.32}
      Writeln(OtchFile,space+'-----------------------------------------------------------------------------------------');
      Writeln(OtchFile,space+'N      Наименование              Код Кол.шт   Кол.уп       З/Ц     Р/Ц  Р/Ц.тек.    % ');
      Writeln(OtchFile,space+'-----------------------------------------------------------------------------------------');

      end;
    1:begin
        {1  12-01-00 БАХУС ТОО            Н ДЖИН ТОНИК 1.5 БУТ ОЧАК  26066  5808   968       22.42   29.15    25.90   30.02}
Writeln(OtchFile,space+
      '---------------------------------------------------------------------------------------------------------------------');
        {1  БАХУС ТОО           12-01-00 Н ДЖИН ТОНИК 1.5 БУТ ОЧАК  26066  5808   968       22.42   29.15    25.90   30.02}
 case SVidSort of

     0: begin
Writeln(OtchFile,space+
'N    Дата     Поставщик                Наименование            Код Кол.шт   Кол.уп       З/Ц     Р/Ц  Р/Ц.тек      % ');
        end;{0}

     1: begin
       { 1   Н ДЖИН ТОНИК 1.5 БУТ ОЧАК 26066 12-01-00 БАХУС ТОО          5808   968       22.42   29.15    25.90   30.02}
Writeln(OtchFile,space+
        'N    Наименование               Код    Дата    Поставщик       Кол.шт    Кол.уп       З/Ц     Р/Ц  Р/Ц.тек     % ');
        end; {1}

     2: begin
     {   1  БАХУС ТОО           12-01-00 Н ДЖИН ТОНИК 1.5 БУТ ОЧАК  26066  5808   968       22.42   29.15    25.90   30.02}
Writeln(OtchFile,space+
'N    Поставщик            Дата      Наименование            Код  Кол.шт    Кол.уп       З/Ц     Р/Ц   Р/Ц.тек     % ');
        end;{2}

 end; {Case SVidSort}
Writeln(OtchFile,space+
      '---------------------------------------------------------------------------------------------------------------------');
      end;
    end; {Case VidReport}


if StatPrih^.COunt<=0 then
 begin
   if PrimechList^.Count>0 then
     begin
      writeln(OtchFile,'Примечание:');
      for i:=0 to PrimechList^.Count-1 do
        begin
        pst:=PrimechList^.At(i);
        st:=pst^;
        writeln(OtchFile,space,st);
        end;
      writeln(OtchFile,space);
     end;
  Writeln(OtchFile,Space,'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
  case SVidReport of
  0:
  Writeln(OtchFile,Space+'=======================================================================================');
  1:
  Writeln(OtchFile,Space+
        '===================================================================================================================');
  end;

  Dispose(SertList,Done);
  Dispose(PrimechList,Done);
  Dispose(ItogList,Done);
  Dispose(SortStatPrih,Done);
  Dispose(StatPrih,Done);
  Dispose(Prih,Done);
  System.close(OtchFile);
  NoInfoMsg;
  ViewAsText(Path^.Dat.ToTemp+'protch.txt',True);
  {Report(Path^.Dat.ToTemp+'protch.txt','',1,False,False);}

  exit;
 end;


         sumZ:=0; sumO:=0; sumKol:=0;
         sumZPost:=0; sumOPost:=0;
          sumZOb:=0; sumOOb:=0;

         p:=0;

   CASE SVidSort of

     0: Begin  {по дате}
         for i:=0 to StatPrih^.Count-1 do
         begin
          pst:=Statprih^.At(i);
          st:=Pst^;
          SortStatPrih^.insert(NewStr(st));
         end;
        End; {0}

     1: Begin   {по наименованию}
         for i:=0 to StatPrih^.Count-1 do
         begin
          pst:=Statprih^.At(i);
          st:=Pst^;
          bufName:=copy(st,posTov,CName+CArtikul);
          System.Delete(st,posTov,CName+CArtikul);
          {Format(bufName,CName+CArtikul);}
          System.Insert(bufName,st,1);
          SortStatPrih^.insert(NewStr(st));
         end;
         posTov:=1;
         posBazCod:=posTov+CName;
         posDate:=posBazCod+CArtikul;
         posPost:=posDate+CDate;
         posNum:=posPost+CClient;
         posKodPost:=posNum+CKod;
         posKol:=posKodPost+CClientKod;
         posZ:=posKol+CKol;
         posO:=posZ+CZenaZ;
        End; {1}

     2: begin
         {подготовка сортировки по поставщику}
         for i:=0 to StatPrih^.Count-1 do
         begin
          pst:=Statprih^.At(i);
          st:=Pst^;
          bufPost:=copy(st,posPost,CClient);
          system.delete(st,posPost,CClient);
          system.insert(bufPost,st,1);
          SortStatPrih^.insert(NewStr(st));
         end;
         { позиционирование на новый формат строки }
         posPost:=1;
         posDate:=posPost+CClient;
         posNum:=posDate+CDate;
         posKodPost:=posNum+CKod;
         posTov:=posKodPost+CClientKod;
         posBazCod:=posTov+CName;
         posKol:=posBazCod+CArtikul;
         posZ:=posKol+CKol;
         posO:=posZ+CZenaZ;
       end; {2}
   END; {CASE}

   if SortStatPrih^.COunt>0 then
      begin
         sumKolOb:=0;
         pst:=SortStatPrih^.At(0);
          st:=pst^;
          bufPost1:=copy(st,posPost,CClient);
          bufDate1:=copy(st,posDate,CDate);
          bufNum1:=copy(st,posNum,CKod);
       end;

                for i:=0 to SortStatPrih^.Count-1 do
         begin
          pst:=SortStatPrih^.At(i);
          st:=pst^;
           bufPost:=copy(st,posPost,CClient);
           bufDate:=copy(st,posDate,CDate);
           bufNum:=copy(st,posNum,CKod);
           sBazCod:=copy(st,posBazCod,CArtikul);
           sKol:=copy(st,posKol,CKol);
           rKol:=StrToInt(sKol);
           {Writeln(rKol);}
           {Readln;}

           sZ_zena:=copy(st,posZ,CZenaZ);
           sO_zena:=copy(st,posO,CZena);
           rZ_Zena:=StrToReal(sZ_Zena);
           rO_zena:=StrToReal(sO_Zena);
           sumOOb:=sumOOb+rO_zena*rKol;
           sumZOb:=sumZOb+rZ_zena*rKol;
           {Writeln(rKol);}
           {Readln;}
           {Writeln('SumKol ',sumKolOb);}
           {Readln;}
           sumKolOb:=sumKolOb+rKol;
           {Writeln(sumKolOb);}
           {Readln;}
          if bufPost1=bufPost then
                                begin
                                  sumKol:=sumKol+rKol;
                                  bPost:=False;
                                end
                                else
                                begin
                                   sumKolPost:=sumKol;
                                   sumKol:=rKol;
                                   bPost:=True;
                                end;

          if (bufPost1=bufPost) and (bufDate1=bufDate) and (bufNum1=bufNum)
            then
              begin
                sumO:=sumO+rO_zena*StrToInt(sKol);
                sumZ:=sumZ+rZ_zena*StrToInt(sKol);
                inc(p);
              end
            else
             begin
               if SVidReport= 0 then p:=1 else inc(p);
               sumZPost:=sumZPost+sumZ;
               sumOPost:=sumOPost+sumO;
               if bufPost=bufPost1 then
                 begin
                   sumZPost1:=sumZPost;
                   sumOPost1:=sumOPost;
                 end
                 else
                 begin
                   sumZPost1:=sumZPost;
                   sumOPost1:=sumOPost;
                   sumZPost:=0;
                   sumOPost:=0;
                 end;
               PrintItog;

               sumZ:=rZ_zena*StrToInt(sKol);
               sumO:=rO_zena*StrToInt(sKol);
               bufPost1:=bufPost;
               bufDate1:=BufDate;
               bufNum1:=BufNum;
             end;

           {Формирование строки на печать}

           stsertprn:='';
           if SertList^.Count>0 then
           for ii:=0 to SertList^.Count-1 do
            begin
             stsert:=''; stsert1:='';
             bufsert:=bufDate;
             DelSpace(bufsert);
             stsert:=stsert+bufsert;
             bufsert:=copy(st,posNum,CKod);
             rformat(bufsert,CKod);
             stsert:=stsert+bufsert;
             bufsert:=copy(st,posBazCod,CArtikul);
             stsert:=stsert+bufsert;
             pst:=SertList^.At(ii);
             stsert1:=pst^;
             if pos(stsert,stsert1)=1 then stsertprn:=stsert1;
            end;

           {Длинные имена}
           bufDlNAme:='';
           bufDlNAme:=GetIdField(FName2,sBazCod);
           if bufDlNAme<>'' then
              begin
                bufDlNAme1:=copy(st,posTov,CName);
                format(bufDlNAme,CName);
                format(bufDlNAme1,CName);
             { writeln(OtchFile,st);}
                System.Delete(st,posTov,CName);
                System.Insert(bufDlName,st,posTov);
             { writeln(OtchFile,st);
              writeln(OtchFile,BufDlName1);}
              end;

           lDat:=StrToInt(bufDate);

           System.Delete(st,posDate,CDate);
           System.Insert(DateToDateString(DateMask,lDat),st,posDate);



           if SVidSort=1 then
             begin
               System.Insert(space,st,posDate);
               System.Insert(Space,st,posDate+CDAte+1);
             end
             else
             begin
           System.Insert(space,st,PosKodTov);
           System.Insert(space,st,posKol+1);
             end;
           sPak:=CalcPack(sBazCod,sKol);
           delSpace(sPak);
           rFormat(sPak,CPack);
           System.Insert(sPak,st,posZ+2);
           System.Insert(SPACE,st,posZ+2);
           if SVidReport=0 then System.Delete(st,1,posTov-1)
                           else
                            begin
                             if SVidSOrt=1 then
                                 begin
                                   System.Delete(st,posNum,CClientKod-1);
                                   System.Insert(space,st,1+CNAme);
                                 end;
                             SYStem.Delete(st,posNum,CClientKod+CKod);
                             System.Insert(space,st,posNum);
                             If SvidSort=0 then System.Insert(space,st,posDate+CDate);
                            end;
           sPak:=BakGetField(FRzena,sBazCod,0);
           rFormat(sPak,CZena);
           st:=st+' '+sPak;
           bsum0:=false;
           if rZ_zena<1e-5 then
             begin
              rZ_zena:=rO_zena/2;
              bsum0:=true;
             end;
           sPak:=RealToStr((rO_zena-rZ_zena)/rZ_zena*100,5,2);
             if bsum0 then rZ_zena:=0;
           RFormat(sPak,CZena);
           st:=st+sPak;
           npp:=IntToStr(P,CKod);
           System.Insert(Format(npp,CKod+1),st,1);

           if bufDlName<>'' then
           Case SVidReport of

             0: begin
                   writeln(OtchFile,space+'    '+bufDlName1);
                end;

             1: begin
                 case SVidSort of
                   0: writeln(OtchFile,space+'                                  '+bufDlName1);
                   1: writeln(OtchFile,space+'    '+bufDlName1);
                   2: writeln(OtchFile,space+'                                 '+bufDlName1);
                 end;
                end;


           end;{case SVidReport}

           writeln(OtchFile,space+st);

       if extend<>0 then
        begin
         {writeln(OtchFile,space+'Сертификат:');}
         system.Delete(stsertprn,1,CDate+CKod+CArtikul-2);

         stsert:=copy(stSertPrn,1+CPost,CNSertif);
         delspace(stsert);
         writeln(OtchFile,space+'   Сертификат: '+stsert);

         stsert:=copy(stSertPrn,1+CPost+CNSertif+CKSertif,CDSertif);
         writeln(OtchFile,space+'   Срок дейст: '+stsert);

         stsert:=copy(stSertPrn,1+CPost+CNSertif,CKSertif);
         writeln(OtchFile,space+'        Выдан: '+stsert);

         stsert:=copy(stSertPrn,1+CPost+CNSertif+CKSertif+CDSertif,CNSertif);
         write(OtchFile,space+  '        N ГТД: '+stsert);

         stsert:=copy(stSertPrn,1,CPost);
         {delSpace(stsert);}
         writeln(OtchFile,space+' Производство: '+stsert);

         stsert:=copy(stSertPrn,1+CPost+CNSertif+CKSertif+CDSertif+CNSertif,
                      CNSertif);
         write(OtchFile,space+  '         '+Seria_Akzis^+': '+stsert);

         stsert:=copy(stSertPrn,1+CPost+CNSertif+CKSertif+CDSertif+CNSertif+
                      CNSertif, CDsertif);
         writeln(OtchFile,space+'Дата выработки: '+stsert);

         stsert:=copy(stSertPrn,1+CPost+CNSertif+CKSertif+CDSertif+CNSertif+
                      CNSertif+CDsertif,CDSertif);
         writeln(OtchFile,space+'   Срок реализ: '+stsert);

         writeln(OtchFile,'');
       end;

           if i=SortStatPrih^.Count-1 then
               begin
                 bPost:=true;
                 sumkolPOst:=sumKol;
                 sumZPost1:=sumZ;
                 sumOPost1:=sumO;
                 PrintItog;
               end;
         end;


  {Dispose(pst);}
   case SVidReport of
   0: Writeln(OtchFile,space+
        '---------------------------------------------------------------------------------------');
   1: Writeln(OtchFile,space+
        '-------------------------------------------------------------------------------------------------------------------');
   end;
   Writeln(OtchFile,Space);
   Writeln(OtchFile,Space+'Всего по З/Ц: ',RealToStr(sumZOb,CIZena,CMantissaZ));
   Writeln(OtchFile,Space+'Всего по Р/Ц: '+RealToStr(sumOOb,CIZena,CMantissaZ));
   bsum0:=false;
   if sumZOb<1e-5 then
             begin
              sumZOb:=sumOOb/2;
              bsum0:=true;
             end;
   Writeln(OtchFile,Space+'          % : ',RealToStr((sumOOb-sumZOb)/sumZOb*100,5,2));
   if bsum0 then sumZOB:=0;
   Writeln(OtchFile,Space+'Всего приход: ',IntToStr(sumKolOb,CIZena)+' шт.');
   Writeln(OtchFile,Space);
                           {АЛЬФА-ЭКО М ООО           181121.50       232480.50  28.36}
   Writeln(OtchFile,space+'------------------------------------------------------------');
   Writeln(OtchFile,space+'   Поставщик                 по З/Ц          по Р/Ц     % ');
   Writeln(OtchFile,space+'------------------------------------------------------------');
   if ItogList^.Count>0 then
    begin
     bPost:=False;
     pst:=ItogList^.At(0);
     st:=pst^;
     bufPost1:=copy(st,1,CClient);
     SumO:=0; SumZ:=0;
     for i:=0 to ItogList^.Count-1 do
      begin

        pst:=ItogList^.At(i);
        st:=Pst^;
        bufPost:=copy(st,1,CClient);
        sZ_zena1:=copy(st,CCLient,CPack+2+2);
        sO_zena1:=copy(st,CClient+CPack+2+4,CPack+1);
        rZ_Zena:=StrToReal(sZ_Zena1);
        rO_zena:=StrToReal(sO_Zena1);
         if (BufPOst=BufPost1) and (i<>ItogList^.Count-1) then
           begin
            if i<>ItogList^.Count-1 then
            begin
             bPost:=True;
             sumO:=sumO+rO_zena;
             sumZ:=sumZ+rZ_zena;
            end;
          end
          else
          begin
              if bPost then
                   begin
                    Write(OtchFile,BufPost1,space,RealToStr(sumZ,CIZena,CMantissaZ),
                    space,RealToStr(sumO,CIZena,CMantissaZ),space);
                      bsum0:=false;
                      if sumZ<1e-5 then
                      begin
                       sumZ:=sumO/2;
                       bsum0:=true;
                      end;
                    Writeln(OTchFile,space,RealToStr((sumO-sumZ)/sumZ*100,5,2));
                    if bsum0 then sumZ:=0;
                   end;
              if bsum0 then sumZ:=0;
              bufPost1:=bufPost;
              sumO:=rO_Zena;
              sumZ:=rZ_zena;
              if i=ItogList^.Count-1 then
               begin
               Write(OtchFile,BufPost1,space,RealToStr(sumZ,CIZena,CMantissaZ),
                    space,RealToStr(sumO,CIZena,CMantissa),space);
                 bsum0:=false;
                  if sumZ<1e-5 then
                   begin
                     sumZ:=sumO/2;
                     bsum0:=true;
                   end;
               Writeln(OTCHFile,space,RealToStr((sumO-sumZ)/sumZ*100,5,2));
               if bsum0 then sumZ:=0;
               end;
          end;
      end;
     end;
   Writeln(OtchFile,space+'------------------------------------------------------------');
   Writeln(OtchFile,Space);
   if StrToInt(CurrentPassword)=0 then
     begin
      Writeln(OtchFile,space,'Delta: ',RealToStr((sumOOb-sumZOb),CIZena,CMantissaZ));
      Writeln(OtchFile,Space);
     end;
   if PrimechList^.Count>0 then
     begin
      writeln(OtchFile,space+'Примечание:');
      for i:=0 to PrimechList^.Count-1 do
        begin
        pst:=PrimechList^.At(i);
        st:=pst^;
        writeln(OtchFile,space,st);
        end;
      writeln(OtchFile,space);
     end;
   Writeln(OtchFile,Space,'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
   Writeln(OtchFile,Space+'==============================================================');

  Dispose(SertList,Done);
  Dispose(PrimechList,Done);
  Dispose(ItogList,Done);
  Dispose(SortStatPrih,Done);
  Dispose(StatPrih,Done);
  Dispose(Prih,Done);
  System.close(OtchFile);
  NoInfoMsg;
  ViewAsText(Path^.Dat.ToTemp+'protch.txt',True);
  {Report(Path^.Dat.ToTemp+'protch.txt','',1,False,False);}
 End;





Procedure TPrihodStatWindow.DrawFullName;
Var S: String;
         R : TRect;
         SArt : ArtikulStr;
Begin
if (SelectNameList^.State and sfFocused <> 0)  Then
Begin
{If (SelectNameList^.List^.Count>0) Then  }
If (SelectNameList^.List<>Nil)And(SelectNameList^.List^.Count>=1) Then
Begin
s:=SelectNameList^.GetText(SelectNameList^.Focused,SelectNameList^.List^.Count);
If s<>PrevName Then
Begin
 PrevName:=s;
 Sart:=Copy(s,1+CName+1,CArtikul);
 Dispose(ControlFullName,Done);
 R.Assign(22, 9, 76, 10);
 s:=GetIdField(FName,Sart);
 DelSpaceRight(s);
 s:=' '+s+' '+GetIdField(FName2,Sart);
 ControlFullName := New(PColoredText, Init(R, s, $7e));
 Insert(ControlFullName);
End;
End
 Else
  Begin
 PrevName[0]:=#0;
 Dispose(ControlFullName,Done);
 R.Assign(22, 9, 76, 10);
 s:=' ';
 ControlFullName := New(PColoredText, Init(R, s, $7e));
 Insert(ControlFullName);
  End;
End;

if (NameList^.State and sfFocused <> 0)  Then
Begin
{If (NameList^.List^.Count>0) Then}
If (NameList^.List<>Nil)And(NameList^.List^.Count>=1) Then
Begin
s:=NameList^.GetText(NameList^.Focused,NameList^.List^.Count);
If s<>PrevName Then
Begin
 PrevName:=s;
 Sart:=Copy(s,1+CName+1,CArtikul);
 Dispose(ControlFullName,Done);
 R.Assign(22, 9, 76, 10);
 s:=GetIdField(FName,Sart);
 DelSpaceRight(s);
 s:=' '+s+' '+GetIdField(FName2,Sart);
 ControlFullName := New(PColoredText, Init(R, s, $7e));
 Insert(ControlFullName);
End;
End
 Else
  Begin
 PrevName[0]:=#0;
 Dispose(ControlFullName,Done);
 R.Assign(22, 9, 76, 10);
 s:=' ';
 ControlFullName := New(PColoredText, Init(R, s, $7e));
 Insert(ControlFullName);
  End;
End;

if (NameList^.State and sfFocused = 0) And (SelectNameList^.State and sfFocused = 0)Then
 Begin
 PrevName[0]:=#0;
 If PStaticText(ControlFullNAme)^.Text^<>' ' Then
 Begin
 Dispose(ControlFullName,Done);
 R.Assign(22, 9, 76, 10);
 s:=' ';
 ControlFullName := New(PColoredText, Init(R, s, $7e));
 Insert(ControlFullName);
 End;
 End;
End;




Begin
SVidClient:=0;
SVidReport:=0;
SVidSort:=0;
StartDate:=DateToDateString(DateMask,DateStringToDate(DateMask,FDate)-30);
StopDate:=FDate;
Extend:=0;
(*
With Filtr Do
Begin
  Post   [0]:=#0;
  NSertif[0]:=#0;
  KSertif[0]:=#0;
  DSertifStart[0]:=#0;
  DSertifStop [0]:=#0;
  NGTD        [0]:=#0;
  MArka       [0]:=#0;
  VirabotanoStart[0]:=#0;
  VirabotanoStop [0]:=#0;
  GodnostStart   [0]:=#0;
  GodnostStop    [0]:=#0;
End;
*)
End.