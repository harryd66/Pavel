




{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}

Unit Access2;

Interface

Uses Dialogs,Objects,Glob,Drivers,ServStr;

Type PPersonalCartWindow= ^TPersonalCartWindow;
     TPersonalCartWindow = object(TDialog)
    Procedure EditZeni(EditMode:Word;Var s:String);
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure DrawZena;
    Procedure Pereshet1;
    Procedure Pereshet2;
    Destructor Done;Virtual;
  end;

Type PSelectOtdelWindow= ^TSelectOtdelWindow;
     TSelectOtdelWindow = object(TDialog)
{   Procedure Start(Var Res : Word;Var s : AllStr);}
    Procedure Start(Var Res : Word;Var s : AllStr;
    R1:TRect;Regim:Word{поставщик=0 получатель=1};
    DisableKod:Word{запрещенное отделение};EnableControl:Boolean);
    procedure HandleEvent(var Event: TEvent); virtual;
    Destructor Done;Virtual;
  end;



Type PPersonalRAzdelWindow= ^TPersonalRAzdelWindow;
     TPersonalRAzdelWindow = object(TDialog)
    Procedure EditZeni(EditMode:Word;Var s:String);
    Destructor Done;Virtual;
  end;


Type PPersonalWindow= ^TPersonalWindow;
     TPersonalWindow = object(TDialog)
     WW : PPersonalCartWindow;
     RR : PPersonalRAzdelWindow;
     Kod : ArtikulStr;
    Procedure ShowList(ClKod:AllStr);
    Procedure DrawCurrent;
    Procedure Refresh;
    Procedure FormReport(ClKod:AllStr);
    procedure HandleEvent(var Event: TEvent); virtual;
    Destructor Done;Virtual;
  end;

Function InputPostawshik(Kod:ArtikulStr;Op:Word;Var Doc:AllStr;Var D:TDateString):Boolean;
Procedure EditSkidka;


Implementation



Uses Printers,Vision4,App,Views,MsgBox,Serv,ColorTxt,Validate,DbEngine,Memory,TpDate,
     Protect,Net,NetDbEng,NetCall,WinDos,Utils,UtilsP;

Var
 TovarFile : File Of TovarClientType;
 ToVarElement : TovarClientType;
 RazdelTovarFile : File Of RazdelClientType;
 RazdelToVarElement : RazdelClientType;
 VidProd:Word;

 ElementFile : BazFileType;
 Element : BazType;
 ClWin : PPersonalWindow;
 Control : PView;
 NameList,SelNAmeList : PBox;
 Id : PBazType;
 NazWin : PPersonalCartWindow;
 RazdNazWin : PPersonalRazdelWindow;
 Baz : BazFileType;
 RazdelFile : File Of RazdelType;
 RazdelElement : RAzdelType;
 CurrentStr,s,ws : String[150];
 SControlVidProd,
 ControlMin,ControlNewZena,ControlComment1,ControlSZena,ControlAuto,
 ControlComment2,ControlCom2,ControlOp,ControlNaz,ControlCom1,
 ControlD,ControlT: PView;
 ControlNaz1,ControlReg,ControlShk:PView;
 SArtikul : ArtikulStr;
 SZakupka : AllStr;
 PrevRes : AllStr;
 Res : AllStr;
 _RazdelList,_SelRazdelList : PBox;


Procedure EditSkidka;
Const ReadOnly=0+$42;
var  Dlg : PDialog;
  R : TRect;
  Control : PView;
  ControlRozn1 : PInputLine;
  ControlRozn7 : PInputLine;
  ControlRozn14 : PInputLine;
  ControlRozn21 : PInputLine;
  ControlRozn28 : PInputLine;
  ControlRoznSam1 : PInputLine;
  ControlRoznSam7 : PInputLine;
  ControlRoznSam14 : PInputLine;
  ControlOpt1 : PInputLine;
  ControlOpt7 : PInputLine;
  ControlOpt14 : PInputLine;
  ControlOpt21 : PInputLine;
  ControlOpt28 : PInputLine;
  ControlOptSam1 : PInputLine;
  ControlOptSam7 : PInputLine;
  ControlOptSam14 : PInputLine;
  c: word;
  f: file of AutoSkidkaType;
  sk: PAutoSkidkaType;
  iorez: word;
  OldFileMode: word;
Begin
OldFileMode:=FileMode;
FileMode:=ReadOnly;

Assign(f,Path.ToClient+'skidki.db');
iorez:=ioresult;
{Rewrite(f);}
Reset(f);
iorez:=ioresult;
if iorez<>0 then
begin
 MessageBox(#3^M+#3'Ошибк открытия файла скидок '+Path.ToClient+'skidki.db!',Nil,mfError+mfCancelButton);
 exit;
end;

new(sk,init);

read(f,sk^.dat);

R.Assign(10, 2, 65, 15);
New(Dlg, Init(R, 'Назначение скидок'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.Palette := dpCyanDialog;
Dlg^.HelpCtx:=$E011;

R.Assign(10, 3, 18, 4);
ControlRozn1 := New(PInputLine, Init(R, 6));
Dlg^.Insert(ControlRozn1);
  PInputLine(ControlRozn1)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.','-']));
  ControlRozn1^.SetData(sk^.Dat.Rozn.dost1);

R.Assign(10, 5, 18, 6);
ControlRozn7 := New(PInputLine, Init(R, 6));
Dlg^.Insert(ControlRozn7);
  PInputLine(ControlRozn7)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.','-']));
  ControlRozn7^.SetData(sk^.Dat.Rozn.dost7);

R.Assign(10, 7, 18, 8);
ControlRozn14 := New(PInputLine, Init(R, 6));
Dlg^.Insert(ControlRozn14);
  PInputLine(ControlRozn14)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.','-']));
  ControlRozn14^.SetData(sk^.Dat.Rozn.dost14);

R.Assign(10, 9, 18, 10);
ControlRozn21 := New(PInputLine, Init(R, 6));
Dlg^.Insert(ControlRozn21);
  PInputLine(ControlRozn21)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.','-']));
  ControlRozn21^.SetData(sk^.Dat.Rozn.dost21);

R.Assign(10, 11, 18, 12);
ControlRozn28 := New(PInputLine, Init(R, 6));
Dlg^.Insert(ControlRozn28);
  PInputLine(ControlRozn28)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.','-']));
  ControlRozn28^.SetData(sk^.Dat.Rozn.dost28);

R.Assign(20, 3, 28, 4);
ControlRoznSam1 := New(PInputLine, Init(R, 6));
Dlg^.Insert(ControlRoznSam1);
  PInputLine(ControlRoznSam1)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.','-']));
  ControlRoznSam1^.SetData(sk^.Dat.Rozn.Sam1);

R.Assign(20, 5, 28, 6);
ControlRoznSam7 := New(PInputLine, Init(R, 6));
Dlg^.Insert(ControlRoznSam7);
  PInputLine(ControlRoznSam7)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.','-']));
  ControlRoznSam7^.SetData(sk^.Dat.Rozn.Sam7);

R.Assign(20, 7, 28, 8);
ControlRoznSam14 := New(PInputLine, Init(R, 6));
Dlg^.Insert(ControlRoznSam14);
  PInputLine(ControlRoznSam14)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.','-']));
  ControlRoznSam14^.SetData(sk^.Dat.Rozn.Sam14);

R.Assign(33, 3, 41, 4);
ControlOpt1 := New(PInputLine, Init(R, 6));
Dlg^.Insert(ControlOpt1);
  PInputLine(ControlOpt1)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.','-']));
  ControlOpt1^.SetData(sk^.Dat.OPt.dost1);

R.Assign(33, 5, 41, 6);
ControlOpt7 := New(PInputLine, Init(R, 6));
Dlg^.Insert(ControlOpt7);
  PInputLine(ControlOpt7)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.','-']));
  ControlOpt7^.SetData(sk^.Dat.OPt.dost7);

R.Assign(33, 7, 41, 8);
ControlOpt14 := New(PInputLine, Init(R, 6));
Dlg^.Insert(ControlOpt14);
  PInputLine(ControlOpt14)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.','-']));
  ControlOpt14^.SetData(sk^.Dat.OPt.dost14);

R.Assign(33, 9, 41, 10);
ControlOpt21 := New(PInputLine, Init(R, 6));
Dlg^.Insert(ControlOpt21);
  PInputLine(ControlOpt21)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.','-']));
  ControlOpt21^.SetData(sk^.Dat.OPt.dost21);

R.Assign(33, 11, 41, 12);
ControlOpt28 := New(PInputLine, Init(R, 6));
Dlg^.Insert(ControlOpt28);
  PInputLine(ControlOpt28)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.','-']));
  ControlOpt28^.SetData(sk^.Dat.OPt.dost28);


R.Assign(44, 3, 52, 4);
ControlOptSam1 := New(PInputLine, Init(R, 6));
Dlg^.Insert(ControlOptSam1);
  PInputLine(ControlOptSam1)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.','-']));
  ControlOptSam1^.SetData(sk^.Dat.OPt.Sam1);

R.Assign(44, 5, 52, 6);
ControlOptSam7 := New(PInputLine, Init(R, 6));
Dlg^.Insert(ControlOptSam7);
  PInputLine(ControlOptSam7)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.','-']));
  ControlOptSam7^.SetData(sk^.Dat.OPt.Sam7);

R.Assign(44, 7, 52, 8);
ControlOptSam14 := New(PInputLine, Init(R, 6));
Dlg^.Insert(ControlOptSam14);
  PInputLine(ControlOptSam14)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.','-']));
  ControlOptSam14^.SetData(sk^.Dat.OPt.Sam14);


R.Assign(39, 1, 44, 2);
Control := New(PStaticText, Init(R, 'Опт'));
Dlg^.Insert(Control);

R.Assign(10, 2, 19, 3);
Control := New(PStaticText, Init(R, 'Доставка'));
Dlg^.Insert(Control);

R.Assign(20, 2, 29, 3);
Control := New(PStaticText, Init(R, 'Самовывоз'));
Dlg^.Insert(Control);

R.Assign(2, 5, 10, 6);
Control := New(PStaticText, Init(R, '7 дней'));
Dlg^.Insert(Control);

R.Assign(2, 7, 10, 8);
Control := New(PStaticText, Init(R, '14 дней'));
Dlg^.Insert(Control);

R.Assign(2, 9, 10, 10);
Control := New(PStaticText, Init(R, '21 день'));
Dlg^.Insert(Control);

R.Assign(2, 11, 10, 12);
Control := New(PStaticText, Init(R, '28 дней'));
Dlg^.Insert(Control);

R.Assign(15, 1, 26, 2);
Control := New(PStaticText, Init(R, 'Розница'));
Dlg^.Insert(Control);

R.Assign(33, 2, 42, 3);
Control := New(PStaticText, Init(R, 'Доставка'));
Dlg^.Insert(Control);

R.Assign(43, 2, 53, 3);
Control := New(PStaticText, Init(R, 'Самовывоз'));
Dlg^.Insert(Control);

R.Assign(2, 3, 10, 4);
Control := New(PStaticText, Init(R, '1 День'));
Dlg^.Insert(Control);


Dlg^.SelectNext(False);

c:=Desktop^.ExecView(Dlg);
If c<>cmCancel Then
 Begin
  ControlRozn1^.GetData(sk^.Dat.Rozn.dost1);
  ControlRozn7^.GetData(sk^.Dat.Rozn.dost7);
  ControlRozn14^.GetData(sk^.Dat.Rozn.dost14);
  ControlRozn21^.GetData(sk^.Dat.Rozn.dost21);
  ControlRozn28^.GetData(sk^.Dat.Rozn.dost28);
  ControlRoznSam1^.GetData(sk^.Dat.Rozn.sam1);
  ControlRoznSam7^.GetData(sk^.Dat.Rozn.sam7);
  ControlRoznSam14^.GetData(sk^.Dat.Rozn.sam14);
  ControlOpt1^.GetData(sk^.Dat.Opt.dost1);
  ControlOpt7^.GetData(sk^.Dat.Opt.dost7);
  ControlOpt14^.GetData(sk^.Dat.Opt.dost14);
  ControlOpt21^.GetData(sk^.Dat.Opt.dost21);
  ControlOpt28^.GetData(sk^.Dat.Opt.dost28);
  ControlOptSam1^.GetData(sk^.Dat.Opt.sam1);
  ControlOptSam7^.GetData(sk^.Dat.Opt.sam7);
  ControlOptSam14^.GetData(sk^.Dat.Opt.sam14);
 end;


  iorez:=ioresult;
  close(f);
  iorez:=ioresult;
  Rewrite(f);
  iorez:=ioresult;
  write(f,sk^.dat);
  iorez:=ioresult;

  Dispose(Control,Done);
  Dispose(ControlRozn1,Done);
  Dispose(ControlRozn7,Done);
  Dispose(ControlRozn14,Done);
  Dispose(ControlRozn21,Done);
  Dispose(ControlRozn28,Done);
  Dispose(ControlRoznSam1,Done);
  Dispose(ControlRoznSam7,Done);
  Dispose(ControlOpt1,Done);
  Dispose(ControlOpt7,Done);
  Dispose(ControlOptSam1,Done);
  Dispose(ControlOptSam7,Done);

  Dispose(dlg,done);

  dispose(sk,done);

iorez:=ioresult;
close(f);
iorez:=ioresult;
FileMode:=OldFileMode;

End;


Procedure TPersonalCartWindow.DrawZena;
Var Spec : String[CLitr+1];
    R : TRect;
Begin

ControlMin^.GetData(Spec);

MyStr(StrToReal(SZakupka)*(1+StrToReal(Spec)/100),CZena,CMAntissa,Res);
DelSpace(Res);

If PrevRes<>Res Then
Begin
PrevRes:=Res;
Dispose(ControlNewZena,Done);
R.Assign(58, 3, 68, 4);
ControlNewZena := New(PColoredText, Init(R, #3+Res, $5E));
NazWin^.Insert(ControlNewZena);
Redraw;
End;

End;


Procedure TPersonalCartWindow.Pereshet1;
Var Spec : String[CLitr+1];
    R : TRect;
    Res : String[CZena];
    Test : Word;
Begin
ControlAuto^.GetData(Test);
If Test=0 Then Exit;
ControlMin^.GetData(Spec);

MyStr(StrToReal(SZakupka)*(1+StrToReal(Spec)/100),CZena,CMAntissa,Res);
DelSpace(Res);
ControlSZena^.SetDAta(Res);
Redraw;

End;

Procedure TPersonalCartWindow.Pereshet2;
Var Spec : String[CLitr+1];
    R : TRect;
    Res : String[CZena];
    Test : Word;
Begin
ControlAuto^.GetData(Test);
If Test=0 Then Exit;
ControlSZena^.GetData(Res);
If StrToReal(SZakupka)>0.009 Then
MyStr((StrToReal(Res)/StrToReal(SZakupka)-1)*100,CLitr+1,CLitrMAntissa,Spec)
Else
Spec:='0.000';
DelSpace(Spec);
ControlMin^.SetDAta(Spec);
Redraw;
End;


Procedure TPersonalCartWindow.EditZeni(EditMode:Word;Var s:String);
{EditMode=0 добавление
         =1 редактирование}
var
  R : TRect;
  Control : PView;
  Auto,c : Word;
  SNAme,SInPack,SSpecZ,SRZena,SKol,SComment1,SComment2 : String[64];
  SMin : String[CLitr+1];

begin
sArtikul:=Copy(s,1+CNAme+1,CArtikul);
CAse EditMode Of
0:Begin
   SNAme:=Copy(s,1,CNAme);
   SKol :=BakGetField(FKol,SArtikul,0);
   SRZena:=BakGetField(FRZena,SArtikul,0);
   DelSpace(SRZena);
   SZakupka:=BakGetField(FZakupka,SArtikul,0);
   SInPack:=Copy(s,1+CNAme+1+CArtikul+1,CInPack);
   SMin:='10.00';
   Str(StrToReal(SZakupka)*(1+StrToReal(SMin)/100):CZena:CMAntissa,SSpecz);
   DelSpace(SSpecZ);
   SComment1[0]:=#0;
   SComment2[0]:=#0;
   Auto:=1;
  End;
1:Begin
{Наименование│код│фасовка│наценка│комментарий│комментарий2│оператор│дата│время
{12345678901234567890123456│12345│123│123456│1234567890123456789012345678901234567890123456789012345678901234│
1234567890123456789012345678901234567890123456789012345678901234│12│12345678│12345678}
   SNAme:=Copy(s,1,CNAme);
   SKol :=BakGetField(FKol,SArtikul,0);
   SRZena:=BakGetField(FRZena,SArtikul,0);
   SZakupka:=BakGetField(FZakupka,SArtikul,0);
   SInPack:=Copy(s,1+CNAme+1+CArtikul+1,CInPack);
   SMin:=Copy(s,1+CNAme+1+CArtikul+1+CInPack+1,(CLitr+1));
   SSpecZ:=Copy(s,1+CNAme+1+CArtikul+1+CInPack+1+(CLitr+1)+1,CZena);
   SComment1:=Copy(s,1+CNAme+1+CArtikul+1+CInPack+1+(CLitr+1)+1+CZena+1,CSertif);;
   SComment2:=Copy(s,1+CNAme+1+CArtikul+1+CInPack+1+(CLitr+1)+1+CZena+1+CSertif+1,CSertif);
   Auto:=0;
  End;
Else;
End;

Str(StrToInt(SKol):CKOl,SKol);
DelSpace(SKol);
Str(StrToReal(SRZena):CZena:CMantissa,SRZena);
DelSpace(SRZena);
Str(StrToReal(SZakupka):CZena:CMantissa,SZakupka);
DelSpace(SZakupka);
DelSpaceRight(SComment1);
DelSpaceRight(SComment2);
Str(StrToReal(SMin):CLitr+1:4,SMin);
DelSpace(SMin);
Str(StrToReal(SSpecZ):CZena:CMAntissa,SSpecZ);
DelSpace(SSpecZ);

R.Assign(5, 7, 74, 16);
New(NazWin, Init(R, 'Настройка персональных цен'));
NazWin^.Options := NazWin^.Options or ofCenterX or ofCenterY;
NazWin^.Palette := dpCyanDialog;
NazWin^.HelpCtx := $E002;

R.Assign(2, 1, 55, 2);
Control := New(PStaticText, Init(R, SNAme));
NazWin^.Insert(Control);

R.Assign(57, 1, 67, 2);
Control := New(PStaticText, Init(R, 'Код: '+SArtikul));
NazWin^.Insert(Control);

R.Assign(9, 2, 59, 3);
Control := New(PColoredText, Init(R, 'Р/Ц: '+SRZena+'  З/Ц: '+SZakupka+'  Количе'+
     'ство: '+SKol, $3E));
Control^.Options := Control^.Options or ofCenterX;
NazWin^.Insert(Control);

R.Assign(32, 3, 34, 4);
Control := New(PColoredText, Init(R, '%', $30));
NazWin^.Insert(Control);

R.Assign(34, 3, 58, 4);
Control := New(PColoredText, Init(R, 'Расчетная цена отгрузки:', $3E));
NazWin^.Insert(Control);

R.Assign(58, 3, 68, 4);
ControlNewZena := New(PColoredText, Init(R, #3+'???', $5E));
NazWin^.Insert(ControlNewZena);

R.Assign(22, 3, 30, 4);
ControlMin := New(PInputLine, Init(R, 6));
NazWin^.Insert(ControlMin);
  PInputLine(ControlMin)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));
ControlMin^.SetDAta(SMin);

  R.Assign(1, 3, 22, 4);
  NazWin^.Insert(New(PLabel, Init(R, 'Минимальная наценка:', ControlMin)));

R.Assign(22, 4, 36, 5);
ControlAuto := New(PCheckboxes, Init(R,
  NewSItem('Пересчет', Nil)));
NazWin^.Insert(ControlAuto);
ControlAuto^.SetDAta(Auto);

R.Assign(58, 4, 68, 5);
ControlSZena := New(PInputLine, Init(R, CZena));
NazWin^.Insert(ControlSZena);
  PInputLine(ControlSZena)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));
ControlSZena^.SetDAta(SSpecZ);

R.Assign(39, 4, 58, 5);
Control := New(PColoredText, Init(R, 'Спец.цена отгрузки:', $3E));
NazWin^.Insert(Control);

R.Assign(1, 4, 14, 5);
Control := New(PColoredText, Init(R, 'Комментарий:', $3E));
NazWin^.Insert(Control);

R.Assign(1, 5, 67, 6);
ControlComment1 := New(PInputLine, Init(R, 64));
NazWin^.Insert(ControlComment1);
ControlComment1^.SetDAta(SComment1);

R.Assign(1, 6, 67, 7);
ControlComment2 := New(PInputLine, Init(R, 64));
NazWin^.Insert(ControlComment2);
ControlComment2^.SetDAta(SComment2);

NazWin^.SelectNext(False);
NazWin^.SelectNext(False);
NazWin^.SelectNext(False);
PrevRes[0]:=#0;
Res[0]:=#0;


c:=Desktop^.ExecView(NazWin);
if c <> cmCAncel Then
 Begin
  ControlMin^.GetDAta(SMin);
  ControlSZena^.GetDAta(SSpecZ);
  ControlComment1^.GetDAta(SComment1);
  ControlComment2^.GetDAta(SComment2);
  Str(StrToReal(SMin):CLitr+1:4,SMin);
  Str(StrToReal(SSpecZ):CZena:CMAntissa,SSpecZ);
  Format(SMin,CLitr+1);
  Format(SSpecZ,CZena);
  Format(SComment1,CSertif);
  Format(SComment2,CSertif);
  Format(SName,CName);
  Format(SInPack,CInPAck);
  s:=SNAme+'│'+SArtikul+'│'+SInPack+'│'+SMin+'│'+SSpecZ+'│'+SComment1+'│'+SComment2+'│'+CurrentPassword+'│'+FDate+'│'+Times;
  If EditMode=1 Then
  Begin
   SelNameList^.List^.AtFree(SelNameList^.Focused);
   SelNameList^.SetRange(SelNameList^.List^.Count);
  End;
  SelNameList^.List^.Insert(NewStr(S));
  SelNameList^.SetRange(SelNameList^.List^.Count);
  SelNameList^.FocusItem(Location(SelNameList,SArtikul,False));
 End;
Dispose(Control,DOne);
Dispose(NazWin,DOne);
end;




procedure TPersonalCartWindow.HandleEvent(var Event: TEvent);
Var Test : Word;
    StartPereshet1,StartPereshet2:Boolean;
Begin
  StartPereshet1:=False;
  StartPereshet2:=False;
  If (Event.What=evKeyboard)And((Event.CharCode in ['0','1','2','3','4','5','6','7','8','9','.'])
  Or (Event.KeyCode=kbDel) Or (Event.KeyCode=kbCtrlDel) Or (Event.KeyCode=kbShiftIns) Or (Event.KeyCode=kbBack))
  And(ControlMin^.State and sfFocused <> 0)Then StartPereshet1:=True
  Else
  If (Event.What=evKeyboard)And((Event.CharCode in ['0','1','2','3','4','5','6','7','8','9','.'])
  Or (Event.KeyCode=kbDel) Or (Event.KeyCode=kbCtrlDel) Or (Event.KeyCode=kbShiftIns) Or (Event.KeyCode=kbBack))
  And(ControlSZena^.State and sfFocused <> 0)Then StartPereshet2:=True;

  Inherited HandleEvent(Event);
  DrawZena;
  If (Desktop^.Current=PView(NazWin)) And (Event.What <> EvKeyDown) Then
   Begin
          if (ControlAuto^.State and sfFocused <> 0)Then
              Begin
               ControlAuto^.GetData(Test);
               If Test=1 Then
                Begin
                 PereShet1;
                End;
              End;

   If StartPereshet1 Then Pereshet1;
   If StartPereshet2 Then Pereshet2;

   End;
End;


Destructor TPersonalCartWindow.Done;
Begin
TDialog.Done;
end;





Procedure TPersonalRAzdelWindow.EditZeni(EditMode:Word;Var s:String);
{EditMode=0 добавление
         =1 редактирование}
LAbel 55;
var
  R : TRect;
  Control : PView;
  Auto,c : Word;
  SNAme,SComment1,SComment2 : String[64];
  SInPack: Word;
  SNAzenka : String[CLitr+1];
  SShkala : String[CMAntissa];
  SMin : String[CLitr+1];

begin
sArtikul:=Copy(s,1+CRAzdel+1,CRazdelKod);


CAse EditMode Of
0:Begin
   SNAme:=Copy(s,1,CRAzdel);
   SInPack:=0;
   SNAzenka:='10.00';
   SShkala:='1';
   SComment1[0]:=#0;
   SComment2[0]:=#0;
  End;
1:Begin
   SNAme:=Copy(s,1,CRazdel);
   SInPack:=StrToInt(Copy(s,1+CRAzdel+1+CRAzdelKod+1,COne));
   SNAzenka:=Copy(s,1+CRAzdel+1+CRAzdelKod+1+COne+1,(CLitr+1));
   SNAzenka:=RealToStr(StrToReal(SNAzenka),Clitr+1,Cmantissa);
   DelSpace(SNAzenka);
   SShkala :=Copy(s,1+CRAzdel+1+CRAzdelKod+1+COne+1+(CLitr+1)+1,CMAntissa);
   DelSpace(SShkala);
   SComment1:=Copy(s,1+CRAzdel+1+CRAzdelKod+1+COne+1+(CLitr+1)+1+CMAntissa+1,CSertif);
   DelSpaceRight(SComment1);
   SComment2:=Copy(s,1+CRAzdel+1+CRAzdelKod+1+COne+1+(CLitr+1)+1+CMAntissa+1+CSertif+1,CSertif);
   DelSpaceRight(SComment2);
  End;
Else;
End;

55:

R.Assign(18, 7, 62, 15);
New(RAzdNAzWin, Init(R, 'Настройка цен для раздела'));
RAzdNAzWin^.Options := RAzdNAzWin^.Options or ofCenterX or ofCenterY;
RAzdNAzWin^.Palette := dpCyanDialog;
RAzdNAzWin^.HelpCtx := $E002;

R.Assign(2, 1, 22, 2);
Control := New(PStaticText, Init(R, SNAme));
RAzdNAzWin^.Insert(Control);

R.Assign(23, 1, 30, 2);
Control := New(PStaticText, Init(R, 'Код: '+SArtikul));
RAzdNAzWin^.Insert(Control);


R.Assign(2, 2, 30, 3);
ControlReg := New(PRadioButtons, Init(R,
  NewSItem('Наценка, % ',
  NewSItem('Шкала', Nil))));
RAzdNAzWin^.Insert(ControlReg);
ControlReg^.SetDAta(SInPAck);


R.Assign(3, 3, 11, 4);
ControlNaz1 := New(PInputLine, Init(R, (CLitr+1)));
RAzdNAzWin^.Insert(ControlNaz1);
  PInputLine(ControlNaz1)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));
ControlNaz1^.SetDAta(SNAzenka);


R.Assign(20, 3, 24, 4);
ControlShk := New(PInputLine, Init(R, CMAntissa));
RAzdNAzWin^.Insert(ControlShk);
  PInputLine(ControlShk)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0']));
ControlShk^.SetDAta(SShkala);

R.Assign(2, 5, 42, 6);
ControlComment1 := New(PInputLine, Init(R, CSertif));
RAzdNAzWin^.Insert(ControlComment1);
ControlComment1^.SetDAta(SComment1);

R.Assign(2, 6, 42, 7);
ControlComment2 := New(PInputLine, Init(R, CSertif));
RAzdNAzWin^.Insert(ControlComment2);
ControlComment2^.SetDAta(SComment2);

RAzdNAzWin^.SelectNext(False);
RAzdNAzWin^.SelectNext(False);

c:=Desktop^.ExecView(RAzdNAzWin);
if c <> cmCAncel Then
 Begin
  ControlReg^.GetDAta(SInPAck);
  ControlNaz1^.GetDAta(SNAzenka);
  ControlShk^.GetDAta(SShkala);
  ControlComment1^.GetDAta(SComment1);
  ControlComment2^.GetDAta(SComment2);
  If Not((StrToInt(SShkala)<=24)) Then
   Begin
    Dispose(Control,DOne);
    Dispose(RAzdNAzWin,DOne);
    MessageBox(^M+#3'Недопустимое значение номера шкалы!',Nil,mfError+mfCAncelButton);
    Goto 55;
   End;

  Str(StrToReal(SNazenka):CLitr+1:2,SNAzenka);
  Str(StrToInt (SShkala):CMAntissa,SShkala);
  Format(SComment1,CSertif);
  Format(SComment2,CSertif);
  Format(SName,CRAzdel);
  s:=SNAme+'│'+SArtikul+'│'+IntToStr(SInPack,COne)+'│'+SNAzenka+'│'+SSHkala+'│'+
     SComment1+'│'+SComment2+'│'+CurrentPassword+'│'+FDate+'│'+Times;

  If EditMode=1 Then
  Begin
   _SelRAzdelList^.List^.AtFree(_SelRAzdelList^.Focused);
   _SelRAzdelList^.SetRange(_SelRAzdelList^.List^.Count);
  End;
  _SelRAzdelList^.List^.Insert(NewStr(S));
  _SelRAzdelList^.SetRange(_SelRAzdelList^.List^.Count);
  _SelRAzdelList^.FocusItem(LocationR(_SelRAzdelList,SArtikul,False));
 End;
Dispose(Control,DOne);
Dispose(RAzdNAzWin,DOne);
end;




Destructor TPersonalRazdelWindow.Done;
Begin
Dispose(ControlReg,Done);
Dispose(ControlNaz1,Done);
Dispose(ControlShk,Done);
Dispose(ControlComment1,Done);
Dispose(ControlComment2,Done);
TDialog.Done;
end;






Procedure TPersonalWindow.Refresh;
VAr Res : Word;
    MySet:Set Of Byte;
Begin

  MySet:=[];

  Case VidProd Of
  0:MySet:=[0..29];
  1:MySet:=[30..75];
  2:MySet:=[76..99];
  Else Exit;
  End;

DInfoMsg('Минуточку...');
NameList^.NewList(Nil);
NameList^.NewList(New(PTextCollection, Init(0,1)));
New(Id,Init);
Assign(RazdelFile,Path.ToRazdel+'razdel.db');
Res:=IOResult;
Reset(RazdelFile);
Res:=IOResult;
If Res=0 Then
 Begin
  While Not(Eof(RazdelFile)) Do
  Begin
  Read(RazdelFile,RazdelElement);
  If RazdelElement.Employ Then
   If StrToInt(RAzdelElement.Kod) in MySet Then
  Begin
  Assign(Baz,Path.ToName+RazdelElement.Kod+'.id');
  Res:=IOResult;
  Reset(Baz);
  Res:=IOResult;


  If Res=0 Then
   Begin
    While Not (Eof(Baz)) Do
     Begin
      ReadBazPointer(Baz,Id);
      If Id^.Dat.Employ Then
       Begin
        ws:=Id^.Dat.BazKod;
        s:=Id^.Dat.NAme{GetIdField(FName,ws)};
        DelSpaceRight(s);
        Format(S,CNAme);
        s:=s+'│'+ws+'│';
        ws:=Id^.Dat.InPack{GetIdField(FInPack,ws)};
        DelSpaceRight(ws);
        RFormat(wS,CInPaCk);
        s:=s+ws;
        NameList^.List^.Insert(NewStr(s));
        NameList^.SetRange(NameList^.List^.Count);
       End;{If}
     End;{While}
    System.Close(Baz);
   End{Res=0}
   Else
    MessageBox(^M+#3'Ошибка открытия '+Path.ToName+RazdelElement.Kod+'.id'+^M+ClicProgrammer,Nil,mfError+mfCancelButton);



   End;{RazdelElement.Employ}

  End;{While Not(Eof(RazdelFile))}
  System.Close(RazdelFile);
 End
 Else
  Begin
  NoInfo;
  MessageBox(^M+#3'Ошибка открытия '+Path.ToRazdel+'Razdel.db'^M+ClicProgrammer,Nil,mfError+mfCancelButton);
  End;

Dispose(Id,Done);
NameList^.FocusItem(0);
NameList^.HelpCtx:=$F203;;

NoInfoMsg;

End;




Procedure TPersonalWindow.ShowList(ClKod:AllStr);
var
  R : TRect;
  c : Word;
  res : Word;
  SS : AllStr;
  s,SNAme,SInPack : string[150];
  s1,s2,s3 : string[150];
Begin
AInfo('Минуточку...');
R.Assign(1, 0, 78, 23);
New(ClWin, Init(R, 'Персональные цены для клиента '+GetClientField(FClient,ClKod,0)+' ('+ClKod+')'));
ClWin^.Options := ClWin^.Options or ofCenterX or ofCenterY;
ClWin^.HelpCtx := $F203;;
ClWin^.Kod := ClKod;


VidProd:=0;

R.Assign(1, 1, 38, 2);
SControlVidProd := New(PRadioButtons, Init(R,
  NewSItem('0-29',
  NewSItem('30-75',
  NewSItem('76-99', Nil)))));
ClWin^.Insert(SControlVidProd);
SControlVidProd^.SetData(VidProd);



R.Assign(38, 3, 39, 10);
Control := New(PScrollBar, Init(R));
ClWin^.Insert(Control);

R.Assign(1, 3, 38, 10);
NameList:= New(PBox, Init(R, 1, PScrollbar(Control)));
NameList^.NewList(New(PTextCollection, Init(0,1)));
(*
New(Id,Init);
Assign(RazdelFile,Path.ToRazdel+'razdel.db');
Res:=IOResult;
Reset(RazdelFile);
Res:=IOResult;
If Res=0 Then
 Begin
  While Not(Eof(RazdelFile)) Do
  Begin
  Read(RazdelFile,RazdelElement);
  If RazdelElement.Employ Then
  Begin
  Assign(Baz,Path.ToName+RazdelElement.Kod+'.id');
  Res:=IOResult;
  Reset(Baz);
  Res:=IOResult;
  If Res=0 Then
   Begin
    While Not (Eof(Baz)) Do
     Begin
      ReadBazPointer(Baz,Id);
      If Id^.Dat.Employ Then
       Begin
        ws:=Id^.Dat.BazKod;
        s:=Id^.Dat.NAme{GetIdField(FName,ws)};
        DelSpaceRight(s);
        Format(S,CNAme);
        s:=s+'│'+ws+'│';
        ws:=Id^.Dat.InPack{GetIdField(FInPack,ws)};
        DelSpaceRight(ws);
        RFormat(wS,CInPaCk);
        s:=s+ws;
        NameList^.List^.Insert(NewStr(s));
        NameList^.SetRange(NameList^.List^.Count);
       End;
    End;
    System.Close(Baz);
   End
   Else
    MessageBox(^M+#3'Ошибка открытия '+Path.ToName+RazdelElement.Kod+'.id'+^M+ClicProgrammer,Nil,mfError+mfCancelButton);
   End;{RazdelElement.Employ}

  End;{While Not(Eof(RazdelFile))}
  System.Close(RazdelFile);
 End
 Else
  Begin
  NoInfo;
  MessageBox(^M+#3'Ошибка открытия '+Path.ToRazdel+'Razdel.db'^M+ClicProgrammer,Nil,mfError+mfCancelButton);
  End;

Dispose(Id,Done);
*)
Refresh;

NameList^.FocusItem(0);
NameList^.HelpCtx:=$F203;;

ClWin^.Insert(NameList);


  R.Assign(1, 2, 38, 3);
  ClWin^.Insert(New(PLabel, Init(R, 'Наименование товара         Код  Фас', NameList)));

R.Assign(76, 2, 77, 10);
Control := New(PScrollBar, Init(R));
ClWin^.Insert(Control);

R.Assign(39, 2, 76, 10);
SelNameList:= New(PBox, Init(R, 1, PScrollbar(Control)));
SelNameList^.NewList(New(PTextCollection, Init(0,1)));

Assign(TovarFile,Path.ToClient+ClKod+'.skl');
c:=IOResult;
Reset(TovarFile);
c:=IOResult;
If c=0 Then
Begin

 While Not(Eof(TovarFile)) DO
  Begin
   Read(ToVarFile,ToVArElement);
   If ToVArElement.Active Then
   Begin
    SNAme:=GetIdField(FName,TovarElement.BazKod);
    Format(SNAme,CNAme);
    SInPack:=GetIdField(FInPAck,TovarElement.BazKod);
    Format(SInPack,CInPack);
    Format(ToVarElement.Nazenka,CLitr+1);
    Format(ToVarElement.SpecZena,CZena);
    Format(ToVarElement.Comment1,CSertif);
    Format(ToVarElement.Comment2,CSertif);
    Format(ToVarElement.DateC,CDate);
    Format(ToVarElement.TimeC,CDate);
    s:=SNAme+'│'+TovarElement.BazKod+'│'+SInPAck+'│'+ToVarElement.Nazenka+'│'+
    ToVarElement.Speczena+'│'+
    ToVarElement.Comment1+'│'+ToVarElement.Comment2+'│'+ToVarElement.Caption+'│'+
    ToVarElement.DateC+'│'+ToVarElement.TimeC;
    SelNameList^.List^.Insert(NewStr(S));
    SelNameList^.SetRange(SelNameList^.List^.Count);
   End;
  End;
  c:=IOResult;
  System.Close(TovarFile);
  c:=IOResult;
End;
SelNameList^.FocusItem(0);
SelNameList^.HelpCtx := $F206;;
ClWin^.Insert(SelNameList);

  R.Assign(39, 1, 76, 2);
  ClWin^.Insert(New(PLabel, Init(R, 'Выбранные наименования      Код  Фас', SelNameList)));


R.Assign(50, 11, 51, 18);
Control := New(PScrollBar, Init(R));
ClWin^.Insert(Control);



R.Assign(1, 11, 50, 18);
_RazdelList := New(PBox, Init(R, 2, PScrollbar(Control)));
_RazdelList^.NewList(New(PTextCollection, Init(0,1)));

Assign(RazdelFile,Path.ToRazdel+'razdel.db');
Res:=IOResult;
Reset(RazdelFile);
Res:=IOResult;
If Res=0 Then
 Begin
  While Not(Eof(RazdelFile)) Do
  Begin
  Read(RazdelFile,RazdelElement);
  If RazdelElement.Employ Then
  Begin
    Format(RazdelElement.Name,CRazdel);
    Format(RazdelElement.Kod,CRazdelKod);
    s:=RazdelElement.NAme+'│'+RazdelElement.Kod;
    _RazdelList^.List^.Insert(NewStr(S));
    _RazdelList^.SetRange(_RazdelList^.List^.Count);
  End;{While Not(Eof(RazdelFile))}
 End;
 System.Close(RazdelFile);
 Res:=IOResult;
End
 Else
  Begin
  NoInfo;
  MessageBox(^M+#3'Ошибка открытия '+Path.ToRazdel+'Razdel.db'^M+ClicProgrammer,Nil,mfError+mfCancelButton);
  End;
ClWin^.Insert(_RazdelList);

  R.Assign(1, 10, 17, 11);
  ClWin^.Insert(New(PLabel, Init(R, 'Укажите раздел:', _RazdelList)));


R.Assign(76, 11, 77, 18);
Control := New(PScrollBar, Init(R));
ClWin^.Insert(Control);

R.Assign(52, 11, 76, 18);
_SelRazdelList := New(PBox, Init(R, 1, PScrollbar(Control)));
_SelRazdelList^.NewList(New(PTextCollection, Init(0,1)));

Assign(RazdelTovarFile,Path.ToClient+ClKod+'.rsk');
c:=IOResult;
Reset(RazdelTovarFile);
c:=IOResult;
If c=0 Then
Begin

 While Not(Eof(RAzdelTovarFile)) DO
  Begin
   Read(RazdelToVarFile,RazdelToVArElement);
   If RazdelToVArElement.Active Then
   Begin
    SNAme:=GetRAzdel(Copy(RazdelTovarElement.BazKod,1,2));
    Format(SNAme,CRAzdel);
    Format(RAzdelToVarElement.Shkala,CMAntissa);
    Format(RAzdelToVarElement.Nazenka,CLitr+1);
    SS:=IntToStr(RAzdelToVarElement.Vid,COne);
    Format(SS,COne);
    Format(RAzdelToVarElement.Comment1,CSertif);
    Format(RAzdelToVarElement.Comment2,CSertif);
    Format(RAzdelToVarElement.DateC,CDate);
    Format(RAzdelToVarElement.TimeC,CDate);
    Format(RAzdelToVarElement.Caption,CMAntissa);
    s:=SNAme+'│'+Copy(RAzdelTovarElement.BazKod,1,2)+'│'+SS+'│'+
    RazdelToVarElement.Nazenka+'│'+RAzdelToVarElement.Shkala+'│'+
    RazdelToVarElement.Comment1+'│'+RazdelToVarElement.Comment2+'│'+
    RazdelToVarElement.Caption+'│'+
    RazdelToVarElement.DateC+'│'+RazdelToVarElement.TimeC;
    _SelRAzdelList^.List^.Insert(NewStr(S));
    _SelRAzdelList^.SetRange(_SelRAzdelList^.List^.Count);
   End;
  End;
  c:=IOResult;
  System.Close(RazdelTovarFile);
  c:=IOResult;
End;
_SelRAzdelList^.FocusItem(0);
_SelRAzdelList^.HelpCtx := $F206;;
ClWin^.Insert(_SelRAzdelList);

  R.Assign(51, 10, 70, 11);
  ClWin^.Insert(New(PLabel, Init(R, 'Выбранные разделы:', _SelRAzdelList)));


R.Assign(1, 20, 65, 21);
ControlCom1 := New(PColoredText, Init(R, '???', $7E));
ClWin^.Insert(ControlCom1);

R.Assign(1, 21, 65, 22);
ControlCom2 := New(PColoredText, Init(R, '???', $7E));
ClWin^.Insert(ControlCom2);

R.Assign(1, 19, 13, 20);
Control := New(PColoredText, Init(R, 'Комментарий:', $74));
ClWin^.Insert(Control);

R.Assign(19, 18, 28, 19);
Control := New(PColoredText, Init(R, 'Оператор:', $74));
ClWin^.Insert(Control);

R.Assign(28, 18, 40, 19);
ControlOP := New(PColoredText, Init(R, '???', $7E));
ClWin^.Insert(ControlOP);

R.Assign(59, 18, 75, 19);
ControlNaz := New(PColoredText, Init(R, '???', $7E));
ClWin^.Insert(ControlNaz);

R.Assign(51, 18, 59, 19);
Control := New(PColoredText, Init(R, 'Наценка:', $74));
ClWin^.Insert(Control);

R.Assign(43, 19, 48, 20);
Control := New(PColoredText, Init(R, 'Дата:', $74));
ClWin^.Insert(Control);

R.Assign(48, 19, 56, 20);
ControlD := New(PColoredText, Init(R, '???', $7E));
ClWin^.Insert(ControlD);

R.Assign(57, 19, 63, 20);
Control := New(PColoredText, Init(R, 'Время:', $74));
ClWin^.Insert(Control);

R.Assign(63, 19, 71, 20);
ControlT := New(PColoredText, Init(R, '???', $7E));
ClWin^.Insert(ControlT);

ClWin^.SelectNext(False);
NoInfo;

CurrentStr[0]:=#0;

c:=Desktop^.ExecView(ClWin);
If c=cmOk Then
 Begin
  Assign(TovarFile,Path.ToClient+ClKod+'.skl');
  c:=IOResult;
  Rewrite(TovarFile);
  c:=IOResult;
  If c=0 Then
Begin

If (SelNameList^.List^.Count)>0 Then
Begin
s1:='Стало: ';
For c:=0 To SelNAmeList^.List^.Count-1 Do
 Begin
  s:=SelNameList^.GetText(c,SelNameList^.List^.Count);
  ToVarElement.BAzKod:=Copy(s,1+CNAme+1,CArtikul);
  ToVarElement.Nazenka:=Copy(s,1+CNAme+1+CArtikul+1+CInPack+1,(CLitr+1));
  DelSpace(ToVarElement.Nazenka);
  ToVarElement.SpecZena:=Copy(s,1+CNAme+1+CArtikul+1+CInPack+1+(CLitr+1)+1,CZena);
  DelSpace(ToVarElement.SpecZena);
  ToVarElement.Comment1:=Copy(s,1+CNAme+1+CArtikul+1+CInPack+1+(CLitr+1)+1+CZena+1,CSertif);;
  DelSpaceRight(ToVarElement.Comment1);
  ToVarElement.Comment2:=Copy(s,1+CNAme+1+CArtikul+1+CInPack+1+(CLitr+1)+1+CZena+1+CSertif+1,CSertif);
  DelSpaceRight(ToVarElement.Comment2);
  ToVarElement.Caption:=Copy(s,1+CNAme+1+CArtikul+1+CInPack+1+(CLitr+1)+1+CZena+1+CSertif+1+CSertif+1,CRazdelKod);
  ToVarElement.DAteC:=Copy(s,1+CNAme+1+CArtikul+1+CInPack+1+(CLitr+1)+1+CZena+1+CSertif+1+CSertif+1+CRazdelKod+1,CDAte);
  ToVarElement.TimeC:=Copy(s,1+CNAme+1+CArtikul+1+CInPack+1+(CLitr+1)+1+CZena+1+CSertif+1+CSertif+1+CRazdelKod+1+CDAte+1,
  CDAte);
  TovarElement.Active:=True;
  Seek(ToVarFile,FileSize(ToVarFile));
  Write(ToVarFile,ToVArElement);
  s1:=s1+ToVarElement.BAzKod+'   -  '+ToVarElement.Nazenka+'%'+^M;
 End;{For}
AddProtocol('Корректировка персональных цен для клиента ('+ClKod+') '+
GetClientField(FClient,ClKod,0),s1,'');
End;
  c:=IOResult;
  System.Close(TovarFile);
  c:=IOResult;
  MessageBox(^M+#3+'Персональные цены успешно изменены!',Nil,mfInFormation+mfCancelButton);
End{c=0}
 Else
  MessageBox(^M+#3+'Ошибка создания файла персональных позиционных цен!',Nil,mfError+mfCancelButton);


  Assign(RazdelTovarFile,Path.ToClient+ClKod+'.rsk');
  c:=IOResult;
  Rewrite(RazdelTovarFile);
  c:=IOResult;
  If c=0 Then
Begin

If (_SelRAzdelList^.List^.Count)>0 Then
Begin
s1:='Стало: ';
For c:=0 To _SelRAzdelList^.List^.Count-1 Do
 Begin
  s:=_SelRAzdelList^.GetText(c,_SelRAzdelList^.List^.Count);
  RAzdelToVarElement.BAzKod:=Copy(s,1+CRazdel+1,CRazdelKod);
  RAzdelToVarElement.Vid:=StrToInt(Copy(s,1+CRazdel+1+CRAzdelKod+1,COne));
  RAzdelToVarElement.Nazenka:=Copy(s,1+CRazdel+1+CRAzdelKod+1+COne+1,(CLitr+1));
  DelSpace(RazdelToVarElement.Nazenka);
  RazdelToVarElement.Shkala:=Copy(s,1+CRazdel+1+CRAzdelKod+1+COne+1+(CLitr+1)+1,CMantissa);
  DelSpace(RAzdelToVarElement.Shkala);
  RAzdelToVarElement.Comment1:=Copy(s,1+CRazdel+1+CRAzdelKod+1+COne+1+(CLitr+1)+1+CMantissa+1,CSertif);
  DelSpaceRight(RAzdelToVarElement.Comment1);
  RAzdelToVarElement.Comment2:=Copy(s,1+CRazdel+1+CRAzdelKod+1+COne+1+(CLitr+1)+1+CMantissa+1+CSertif+1,CSertif);
  DelSpaceRight(RazdelToVarElement.Comment2);
  RAzdelToVarElement.Caption:=Copy(s,1+CRazdel+1+CRAzdelKod+1+COne+1+(CLitr+1)+1+CMantissa+1+CSertif+1+CSertif+1,CMAntissa);
  RAzdelToVarElement.DAteC:=Copy(s,1+CRazdel+1+CRAzdelKod+1+COne+1+(CLitr+1)+1+CMantissa+1+CSertif+1+CSertif+1+CMAntissa+1,
  CDAte);
  RAzdelToVarElement.TimeC:=Copy(s,1+CRazdel+1+CRAzdelKod+1+COne+1+(CLitr+1)+1+CMantissa+1+CSertif+1+CSertif+1+CMAntissa+1+
  CDAte+1,
  CDAte);
  RazdelTovarElement.Active:=True;
  Write(RazdelToVarFile,RazdelToVArElement);
  s1:=s1+RazdelToVarElement.BAzKod+'   -  '+RazdelToVarElement.Nazenka+'%'+' - '+RazdelToVarElement.Shkala+^M;
 End;{For}
AddProtocol('Корректировка персональных по разделам цен для клиента ('+ClKod+') '+
GetClientField(FClient,ClKod,0),s1,'');
End;
  c:=IOResult;
  System.Close(RAzdelTovarFile);
  c:=IOResult;
  MessageBox(^M+#3+'Персональные цены по разделам успешно изменены!',Nil,mfInFormation+mfCancelButton);
End{c=0}
 Else
  MessageBox(^M+#3+'Ошибка создания файла персональных цен!',Nil,mfError+mfCancelButton);





End{Rewrite};






Dispose(SControlVidProd,Done);
Dispose(SelNameList,Done);
Dispose(NameList,Done);
Dispose(_RazdelList,Done);
Dispose(_SelRazdelList,Done);
Dispose(Control,Done);
Dispose(ClWin,Done);
End;



procedure TPersonalWindow.HandleEvent(var Event: TEvent);
Label 2,3;
Var s,s1 : String{[CClient+1+CClientKod]};
    ls : Word;
    res,Test : Word;
    Logik : Boolean;
    fstr : string;
Begin
  Case Event.What Of
  evKeyDown :
  Case Event.KeyCode Of
     kbDel: Begin
             ClearFind;
     If (SelNameList^.State and sfFocused <> 0) And (SelNameList^.List<>Nil)And(SelNameList^.List^.Count>=1) Then
            Begin
             SelNameList^.List^.AtFree(SelNameList^.Focused);
             SelNameList^.SetRange(SelNameList^.List^.Count);
             If SelNameList^.Focused>0 Then
             SelNameList^.FocusItem(SelNameList^.Focused);

             If (SelNameList^.Focused>=SelNameList^.List^.Count) and(SelNameList^.Focused>0) Then
             SelNameList^.FocusItem(SelNameList^.Focused-1);

            End;

     If (_SelRAzdelList^.State and sfFocused <> 0) And (_SelRAzdelList^.List<>Nil)And(_SelRAzdelList^.List^.Count>=1) Then
            Begin
             _SelRAzdelList^.List^.AtFree(_SelRAzdelList^.Focused);
             _SelRAzdelList^.SetRange(_SelRAzdelList^.List^.Count);
             If _SelRAzdelList^.Focused>0 Then
             _SelRAzdelList^.FocusItem(_SelRAzdelList^.Focused);

             If (_SelRAzdelList^.Focused>=_SelRAzdelList^.List^.Count) and(_SelRAzdelList^.Focused>0) Then
             _SelRAzdelList^.FocusItem(_SelRAzdelList^.Focused-1);

            End;
              ClearEvent(Event);
              Redraw;
            End;

      kbIns: Begin
              ClearFind;
            If(NameList^.State and sfFocused <> 0) And (NameList^.List^.Count>=1) Then
            Begin
               s:=NameList^.GetText(NameList^.Focused,NameList^.List^.COunt);
               If TestElement(Copy(s,1+CName+1,CArtikul),SelNameList) Then
               Begin
                WW^.EditZeni(0,s);
               End;
               If (NameList^.Focused+1) <  NameList^.List^.Count Then
               NameList^.FocusItem(NameList^.Focused+1);
            End;

            If(_RAzdelList^.State and sfFocused <> 0) And (_RAzdelList^.List^.Count>=1) Then
            Begin
               s:=_RAzdelList^.GetText(_RAzdelList^.Focused,_RAzdelList^.List^.COunt);
               If TestElementR(Copy(s,1+CRAzdel+1,CRAzdelKod),_SelRAzdelList) Then
               Begin
                RR^.EditZeni(0,s);
               End;
               If (_RAzdelList^.Focused+1) <  _RAzdelList^.List^.Count Then
               _RAzdelList^.FocusItem(_RAzdelList^.Focused+1);
            End;
              ClearEvent(Event);
              Redraw;
            End;

      kbF4: Begin
              ClearFind;
            If(SelNameList^.State and sfFocused <> 0) And (SelNameList^.List^.Count>=1) Then
            Begin
               s:=SelNameList^.GetText(SelNameList^.Focused,SelNameList^.List^.COunt);
               WW^.EditZeni(1,s);
            End;

            If(_SelRAzdelList^.State and sfFocused <> 0) And (_SelRAzdelList^.List^.Count>=1) Then
            Begin
               s:=_SelRAzdelList^.GetText(_SelRAzdelList^.Focused,_SelRAzdelList^.List^.COunt);
               RR^.EditZeni(1,s);
            End;
              ClearEvent(Event);
              Redraw;
            End;
    Else;
    End;
   evcommand:
  Case Event.Command Of
    cmReestrReport : Begin
                      FormReport(Kod);
                     End;
          Else;
          End;
    Else;
    End;

inherited HandleEvent(Event);

   If (Desktop^.Current=PView(ClWin)) And (Event.What <> EvKeyDown) Then
   Begin
        DrawCurrent;

          if (SControlVidProd^.State and sfFocused <> 0)Then
              Begin
               SControlVidProd^.GetData(Test);
               If Test <> VidProd Then
               Begin
                  VidProd:=Test;
                  Refresh;
                  Redraw;
               End;
              End;

   End;


End;


Procedure TPersonalWindow.DrawCurrent;
Var SClientKod,s1,s : AllStr;
    St : TMyString;
    TempS : string;
    R : TRect;
    L : Boolean;
    i : Byte;
    wp,ws : AllStr;
  SNAme,SOp,SD,SInPack,SSpecZena,SRZena,SZakupka,SKol,SComment1,SComment2 : String[64];
  SMin : String[CLitr+1];
Begin
if (SelNameList^.List<>Nil)And(SelNameList^.List^.Count>=1) Then
 Begin
  st:=SelNameList^.GetText(SelNameList^.Focused,SelNameList^.List^.Count);
  If st <> CurrentStr Then
    Begin
      CurrentStr:=St;

        SMin:=Copy(CurrentStr,1+CNAme+1+CArtikul+1+CInPack+1,(CLitr+1));
   SSpecZena:=Copy(CurrentStr,1+CNAme+1+CArtikul+1+CInPack+1+(CLitr+1)+1,CZena);
   SComment1:=Copy(CurrentStr,1+CNAme+1+CArtikul+1+CInPack+1+(CLitr+1)+1+CZena+1,CSertif);
   SComment2:=Copy(CurrentStr,1+CNAme+1+CArtikul+1+CInPack+1+(CLitr+1)+1+CZena+1+CSertif+1,CSertif);
   SOp:=      Copy(CurrentStr,1+CNAme+1+CArtikul+1+CInPack+1+(CLitr+1)+1+CZena+1+CSertif+1+CSertif+1,CRAzdelKod);
   SOp:=GetOperatorNAme(SOp);
   SD:=       Copy(CurrentStr,1+CNAme+1+CArtikul+1+CInPack+1+(CLitr+1)+1+CZena+1+CSertif+1+CSertif+1+CRAzdelKod+1,CDAte);
   ST:=       Copy(CurrentStr,1+CNAme+1+CArtikul+1+CInPack+1+(CLitr+1)+1+CZena+1+CSertif+1+CSertif+1+CRAzdelKod+1+CDAte+1,
   CDAte);


Dispose(ControlCom1,Done);
R.Assign(1, 20, 65, 21);
ControlCom1 := New(PColoredText, Init(R, SComment1, $7E));
ClWin^.Insert(ControlCom1);

Dispose(ControlCom2,Done);
R.Assign(1, 21, 65, 22);
ControlCom2 := New(PColoredText, Init(R, SComment2, $7E));
ClWin^.Insert(ControlCom2);

Dispose(ControlOp,Done);
R.Assign(28, 18, 40, 19);
ControlOP := New(PColoredText, Init(R, SOp, $7E));
ClWin^.Insert(ControlOP);

Dispose(ControlNaz,Done);
R.Assign(59, 18, 75, 19);
ControlNaz := New(PColoredText, Init(R, SMin, $7E));
ClWin^.Insert(ControlNaz);

Dispose(ControlD,Done);
R.Assign(48, 19, 56, 20);
ControlD := New(PColoredText, Init(R, Sd, $7E));
ClWin^.Insert(ControlD);

Dispose(ControlT,Done);
R.Assign(63, 19, 71, 20);
ControlT := New(PColoredText, Init(R, St, $7E));
ClWin^.Insert(ControlT);

      Redraw;
    End {If St<>PrevCurrent}
 End
Else
 Begin
Dispose(ControlCom1,Done);
R.Assign(1, 20, 65, 21);
ControlCom1 := New(PColoredText, Init(R, '???', $7E));
ClWin^.Insert(ControlCom1);

Dispose(ControlCom2,Done);
R.Assign(1, 21, 65, 22);
ControlCom2 := New(PColoredText, Init(R, '???', $7E));
ClWin^.Insert(ControlCom2);

Dispose(ControlOp,Done);
R.Assign(28, 18, 40, 19);
ControlOP := New(PColoredText, Init(R, '???', $7E));
ClWin^.Insert(ControlOP);

Dispose(ControlNaz,Done);
R.Assign(59, 18, 75, 19);
ControlNaz := New(PColoredText, Init(R, '???', $7E));
ClWin^.Insert(ControlNaz);

Dispose(ControlD,Done);
R.Assign(48, 19, 56, 20);
ControlD := New(PColoredText, Init(R, '???', $7E));
ClWin^.Insert(ControlD);

Dispose(ControlT,Done);
R.Assign(63, 19, 71, 20);
ControlT := New(PColoredText, Init(R, '???', $7E));
ClWin^.Insert(ControlT);

  Redraw;
End;
End;





Destructor TPersonalWindow.Done;
Begin
 TDialog.Done;
End;


Procedure TPersonalWindow.FormReport;
Var txt : Text;
    c   : Word;
    Space : AllStr;
    SOp : AllStr;
Begin
If (SelNameList^.List^.Count)>0 Then
Begin
Assign(txt,Path.ToTemp+'resskl.txt');
c:=IOResult;
Rewrite(txt);
c:=IOResult;

If c=0 Then
Begin
  Space:='    ';
  Writeln(Txt,Space+'Склад:'+FormKod(Rek.Kod)+' Оператор: '+CurrentPassword);
  Writeln(Txt,Space+'Дата и время расчета: '+FDate+'  ('+Times+')');
  Writeln(Txt,Space+'ПЕРСОНАЛЬНЫЕ ЦЕНЫ ДЛЯ КЛИЕНТА '+GetClientField(FCLient,ClKod,0));
  Writeln(txt,Space+'----------------------------------------------------------------------');
  Writeln(txt,Space+' Код  Наименование товара          %    Оператор      Дата     Время  ');
  Writeln(txt,Space+'----------------------------------------------------------------------');
                    {12345│12345678901234567890123456│123456│123456789012│12345678│12345678}

For c:=0 To SelNAmeList^.List^.Count-1 Do
 Begin
  s:=SelNameList^.GetText(c,SelNameList^.List^.Count);
  ToVarElement.BAzKod:=Copy(s,1+CNAme+1,CArtikul);
  ToVarElement.Nazenka:=Copy(s,1+CNAme+1+CArtikul+1+CInPack+1,(CLitr+1));
  ToVarElement.SpecZena:=Copy(s,1+CNAme+1+CArtikul+1+CInPack+1+(CLitr+1)+1,CZena);
  ToVarElement.Comment1:=Copy(s,1+CNAme+1+CArtikul+1+CInPack+1+(CLitr+1)+1+CZena+1,CSertif);;
  DelSpaceRight(ToVarElement.Comment1);
  ToVarElement.Comment2:=Copy(s,1+CNAme+1+CArtikul+1+CInPack+1+(CLitr+1)+1+CZena+1+CSertif+1,CSertif);
  DelSpaceRight(ToVarElement.Comment2);
  ToVarElement.Caption:=Copy(s,1+CNAme+1+CArtikul+1+CInPack+1+(CLitr+1)+1+CZena+1+CSertif+1+CSertif+1,CRazdelKod);
  SOp:=GetOperatorNAme(ToVarElement.Caption);
  Format(SOp,CKto);
  ToVarElement.DAteC:=Copy(s,1+CNAme+1+CArtikul+1+CInPack+1+(CLitr+1)+1+CZena+1+CSertif+1+CSertif+1+CRazdelKod+1,CDAte);
  ToVarElement.TimeC:=Copy(s,1+CNAme+1+CArtikul+1+CInPack+1+(CLitr+1)+1+CZena+1+CSertif+1+CSertif+1+CRazdelKod+1+CDAte+1,
  CDAte);
  s:=Copy(s,1,CNAme);
  Writeln(txt,Space+ToVarElement.BAzKod+' '+s+' '+ToVarElement.Nazenka+' '+ToVarElement.SpecZena+' '+SOp+' '+
  ToVarElement.DAteC+' '+ToVarElement.TimeC);

  If ToVarElement.Comment1[0]<>#0 Then
   Begin
    Writeln(txt,Space+ToVarElement.Comment1);
   End;

  If ToVarElement.Comment2[0]<>#0 Then
   Begin
    Writeln(txt,Space+ToVarElement.Comment2);
   End;

 End;{For}

Writeln(Txt,Space+'"'+DayString[DayOfWeek(ToDay)]+'" '+FDate+'('+Times+')');
Writeln(Txt,Space+'=======================================================================');
Writeln(Txt);

 c:=IOResult;
 System.Close(txt);
 c:=IOResult;

 Report(Path.ToTemp+'resskl.txt','',1,False,False,false);

End;{c=0}
End;

End;




Function InputPostawshik(Kod:ArtikulStr;Op:Word;Var Doc:AllStr;Var D:TDateString):Boolean;
Label 1;
var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  c : Word;
  l : LongInt;
  ddd : Osnovanie;
  SNAme : AllStr;
begin
InputPostawshik:=FAlse;
DDD.NaklNumer[0]:=#0;
DDD.DateNakl[0]:=#0;

If Status=DocEdit Then
Begin
 DDD.NaklNumer:=Doc;
 DDD.DateNAkl:=D;
 DelSpaceRight(DDD.NaklNumer);
 DelSpace(DDD.DAteNakl);
End;

1:
R.Assign(18, 9, 61, 14);
New(Dlg, Init(R, ''));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx := $E002;

R.Assign(4, 1, 14, 2);
Control := New(PColoredText, Init(R, 'Поставщик:', $70));
Dlg^.Insert(Control);

SName:=GetMakeField(FClient,Kod,Op);
DelSpaceRight(SNAme);
Format(SName,CClient);
SName:=' '+SName+' ('+Kod+')';

R.Assign(14, 1, 42, 2);
Control := New(PColoredText, Init(R, SName, $1F));
Dlg^.Insert(Control);

R.Assign(14, 2, 42, 3);
Control := New(PInputLine, Init(R, 20));
Dlg^.Insert(Control);

  R.Assign(1, 2, 14, 3);
  Dlg^.Insert(New(PLabel, Init(R, 'N накладной:', Control)));

R.Assign(14, 3, 24, 4);
Control := New(PInputLine, Init(R, CDate));
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PPXPictureValidator, Init(DateFiltr, True));

  R.Assign(8, 3, 14, 4);
  Dlg^.Insert(New(PLabel, Init(R, 'Дата:', Control)));

Dlg^.SelectNext(False);

Dlg^.SetData(DDD);

c:=Desktop^.ExecView(Dlg);
If c<>cmCancel Then
 Begin
  Dlg^.GEtDAta(DDD);
  DelSpaceRight(ddd.NaklNumer);
  DelSpace(ddd.DateNAkl);
  If Not(TestDAte(ddd.DateNAkl,L)) Then
   Begin
    Dispose(Control,Done);
    Dispose(Dlg,Done);
    MessageBox(^M+#3'Не правильно указана дата накладной поставщика!',Nil,
    mfError+mfCancelButton);
    Goto 1;
   End;

  If (ddd.NaklNumer[0]=#0) Then
   Begin
    Dispose(Control,Done);
    Dispose(Dlg,Done);
    MessageBox(^M+#3'Не указан номер накладной поставщика!',Nil,
    mfError+mfCancelButton);
    Goto 1;
   End;
  InputPostawshik:=True;
  Doc:=DDD.NaklNumer;
  D:=DDD.DateNAkl;
 End;
Dispose(Control,Done);
Dispose(Dlg,Done);
end;


Var
   OtdelWindow : PSelectOtdelWindow;
   OtdelList : PBox;
   Disable: Word;
   EnableC : Boolean;

Procedure TSelectOtdelWindow.Start(Var Res : Word;Var s : AllStr;
R1:TRect;
Regim:Word{поставщик=0 получатель=1};
DisableKod:Word{запрещенное отделение};EnableControl:Boolean);
Label 1;
var
  R : TRect;
  Control : PView;
  c: Word;
  ws : string[150];
Begin
1:
Disable:=DisableKod;
{R.Assign(22, 5, 58, 17);}
If Regim=0 Then
New(OtdelWindow, Init(R1, 'Отделение-поставщик'))
Else
New(OtdelWindow, Init(R1, 'Отделение-получатель'));

{OtdelWindow^.Options := OtdelWindow^.Options or ofCenterX or ofCenterY;}
OtdelWindow^.HelpCtx := $E176;

R.Assign(35, 1, 36, 11);
Control := New(PScrollBar, Init(R));
OtdelWindow^.Insert(Control);

R.Assign(1, 1, 35, 11);
OtdelList := New(PBox, Init(R, 1, PScrollbar(Control)));
OtdelList^.NewList(New(PTextCollection, Init(0,1)));
For c:=1 To CDivision Do
 Begin
  ws:=FormLineOtdel(c);
  ws:=ws+'│'+IntToStr(c,COne);
  Format(ws,33);
  OtdelList^.List^.Insert(NewStr(ws));
  OtdelList^.SetRange(OtdelList^.List^.Count);
 End;

OtdelWindow^.Insert(OtdelList);

ws:=Copy(s,33,COne);
OtdelList^.FocusItem(Location(OtdelList,wS,False));


OtdelWindow^.SelectNext(False);

c:=DeskTop^.ExecView(OtdelWindow);
   If c=CmOk Then Res:=2;
   If c=CmYes Then Res:=3;
   If c=CmCancel Then Res:=1;
   S:=OtdelList^.GetText(OtdelList^.Focused,OtdelList^.List^.Count);

Dispose(Control,Done);
Dispose(OtdelWindow,Done);

If EnableControl Then
If StrToInt(Copy(s,33,COne))=DisableKod Then
  Begin
   MessageBox(^M+#3'Нельзя выбрать одинакового поставщика и получателя!',
   Nil,mfError+mfCancelButton);
   Goto 1;
  End;


End;


procedure TSelectOtdelWindow.HandleEvent(var Event: TEvent);
Var R : TRect;
    test : Word;
    s : TMyString;
    L : Boolean;
begin

  if ((Event.What = evMouseDown) and (Event.Double)) or
     ((Event.What = evKeyDown) and (Event.KeyCode =kbEnter)) Or
     ((Event.What = evKeyDown) and (Event.KeyCode =kbTab)) Or
     ((Event.What = evKeyDown) and (Event.KeyCode =kbCtrlRight)) Then
  begin
              Event.What:=evCommand;
              Event.Command:=cmOk;
              PutEvent(Event);
  end;
  if ((Event.What = evKeyDown) and (Event.KeyCode =kbShiftTab))Or
     ((Event.What = evKeyDown) and (Event.KeyCode =kbCtrlLeft)) Then
  begin
              Event.What:=evCommand;
              Event.Command:=cmYes;
              PutEvent(Event);
  end;
  if ((Event.What = evKeyDown) and (Event.KeyCode = kbEsc))then
  begin
              Event.What:=evCommand;
              Event.Command:=cmCancel;
              PutEvent(Event);
  end;

 if (Event.What = evBroadcast) and
     (Event.Command = cmSelectOtdelenie) then ClearEvent(Event);

  If (Event.What=EvCommand) And (Event.Command in [cmYes,cmOk,cmCancel,cmClose]) Then
   Begin
   S:=OtdelList^.GetText(OtdelList^.Focused,OtdelList^.List^.Count);

If StrToInt(Copy(s,33,COne))=Disable Then
  Begin
          Sound(100);
          DinfoMsg('Нельзя выбрать одинакового поставщика и получателя!');
          Delay(300);
          NoSound;
          repeat
           ClearEvent(Event);
          until (Event.What = evNothing);

          ClearEvent(Event);
       Event.What:=evNothing;
       Event.Command:=cmNone;
          repeat
                 Application^.GetEvent(Event);
          until (Event.What <> evNothing) And (Event.Command<>cmMenu);
       Event.Command:=cmNone;
          ClearEvent(Event);

          repeat
                 Application^.GetEvent(Event);
          until (Event.What <> evNothing) And (Event.Command<>cmMenu);

          NoInfoMsg;
          ClearEvent(Event);
          Exit;
  End;
{
If Not TestOtdel(StrToInt(Copy(s,33,COne))) Then
  Begin
          Sound(100);
          DinfoMsg('Операции с этим отделением запрещены!',False);
          Delay(300);
          NoSound;
          repeat
           ClearEvent(Event);
          until (Event.What = evNothing);

          ClearEvent(Event);
       Event.What:=evNothing;
       Event.Command:=cmNone;
          repeat
                 Application^.GetEvent(Event);
          until (Event.What <> evNothing) And (Event.Command<>cmMenu);
       Event.Command:=cmNone;
          ClearEvent(Event);

          repeat
                 Application^.GetEvent(Event);
          until (Event.What <> evNothing) And (Event.Command<>cmMenu);

          NoInfoMsg;
          ClearEvent(Event);
          Exit;
  End;
}
   End;


  inherited HandleEvent(Event);
  ClearEvent(Event);
end;


Destructor TSelectOtdelWindow.Done;
Begin
ClearFind;
Dispose(OtdelList,Done);
TDialog.Done;
End;




End.