{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}

Unit Access8;

Interface

Uses Dialogs,Glob,Drivers,Objects,ServStr,Access5,Access6,Access8,Access3,Utils5,ViewMain;



Type
    PRazdelAgentZPWindow= ^TRazdelAgentZPWindow;
    TRazdelAgentZPWindow = object(TDialog)
    Kod : ArtikulStr;
    Procedure Start(SKod:ArtikulStr);
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure SaveToFile;
    Destructor Done;Virtual;
  end;



Var

Implementation

{$I Compile.INC}

Uses X_Dialog,ServStr2;

{Const ReadOnly=66;}


Var
   BazNum : PBox;





Procedure TNameWindow.AddBazINI( Cod:Integer; st:ArtikulStr;Status : Boolean;TTT:ArtikulStr;Var Res:Boolean);
{параметр Status указывает на то что добавляется или редактируется
сертификат или другой товар }
Label 1,Restart;
var
  R : TRect;
  Control : PView;
  s,s1,mys : String;
  Oper : StrName;
  c: Word;
  j,k : Byte;
  skl : PSkladType;
  Kdx : PSkladTypeNew;
  Regim : Boolean;
  Event : TEvent;
  EnL : Boolean;
  TovarCod : ArtikulStr;
  Test : LongInt;
  AddSertif : Boolean;
  ElementFile : File;
  l,Count : Word;
  BE : PBufBazType;
  Find : Boolean;
  NewStatus : Boolean;
  EnableNAme : Boolean;
  BKDX : SkladTypeNew;
  ss : String;
  Error: Boolean;
  SArt : ArtikulStr;
  Operator : AllStr;
  FindNoMain : Boolean;
  BakMarket,BakDebit : Word;
  BakInPack,BakInPack2 : ArtikulStr;

begin
Enl:=True;
NewStatus:=False;
ClearFind;
{If Cod=kbF4 Then}

{
If Not(Password(1)) Then
 Begin
  Res:=False;
  Exit;
 End;
}

{Res:=True;}


If (EnableNewTovar=0) And (Cod<>kbF4) Then
   Begin
    MessageBox(#3^M+#3'На данной рабочей станции операция запрещена!',Nil,mfError+mfCancelButton);
    Res:=False;
    Exit;
   End;



If Not(TestOpenDate1(FDate)) Then
   Begin
    MessageBox(#3^M+#3'Доступ к данным за '+FDate+' заблокирован!',Nil,mfError+mfCancelButton);
    Res:=False;
    Exit;
   End;

If (GlobalReadOnly=1) Or (ReadOnlyConst=1) Then
   Begin
    MessageBox(#3^M+ReadOnlyStr^,Nil,mfWarning+mfCancelButton);
    Res:=False;
    Exit;
   End;

If Not(TestSetupKurs(FDate)) Then
   Begin
    {MessageBox(#3^M+#3'Не установлен курс USD на '+FDate+'!',Nil,mfError+mfCancelButton);}
    Res:=False;
    Exit;
   End;

Regim :=True;
EnableNAme:=True;


{$IFNDEF Pharm}
If Not(Password(2)) Then
 Begin
  Regim:=False;
 End;

If Cod=kbF4 Then
If Not(Password(4)) Then
 Begin
  EnableNAme:=False;
 End;

Res:=False;
{выключено 27/10/2003 за ненадобностью
If (Cod=kbGrayPlus)Or (Cod=kbAltF1) Then
MessageBox(^M+#3'Не забудьте согласовать код нового товара с центральным офисом !',Nil,mfWarning+mfCancelButton);
}
{$ENDIF}

C:=IOResult;
Res:=False;

AddSertif:=False;
If Status Then
Begin
AddSertif:=GetRazdelStatus(St);
NewStatus:=AddSertif;
s1:=st;
Assign(ElementFile,Path^.Dat.ToName+st+'.id');
OldFileMode:=FileMode;
FileMode:=ReadOnlyN;
Reset(ElementFile,SizeOf(BazType));
c:=IOResult;
FileMode:=OldFileMode;
If C<>0 Then
Begin
 MessageBox(^M+#3'Ошибка доступа к файлу '+st+'.id!',nil,mfError+mfCancelButton);
 Res:=False;
 Exit;
End;
DInfoMsg('Читаю информацию о товарах...',False);
 Case Cod Of
  kbGrayPlus,kbAltF1:Begin
     Element.Employ:=True;
     Find:=False;
     While Not(Eof(ElementFile)) And Not(Find) Do
     Begin
      New(BE,Init);
      ReadBufBaz(ElementFile,BE,Count);
      For c:=1 To Count Do
       Begin
        If Not BE^.Point.Dat[c].Employ Then
         Begin
          Find:=True;
          s:=BE^.Point.Dat[c].BazKod;
          Break;
         End;
       End;{For}
      Dispose(BE,Done);
     End;{While}

     If Not Find Then
      Begin
       NoInfoMsg;
       MessageBox(^M+#3'Свободных позиций для товара - нет !',nil,mfWarning+mfCancelButton);
       System.Close(ElementFile);
       Res:=False;
       Exit;
      End;

      Element.Name[0]:=#0;
      Element.Name2[0]:=#0;
      Element.Market:=0;
      {Element.Gruppa:=0;}
      {Element.FullName[0]:=#0;
       Element.FullName2[0]:=#0;}
      Element.Litr[0]:=#0;
      Element.InPack[0]:=#0;
      Element.InPack2[0]:=#0;
      Element.OKP:=0;
      Element.EnableSklads:=1073741823;
      {Element.OKP[0]:=#0;}
      Element.Massa[0]:=#0;
      Element.BuchGroup:=0;
      Element.Etil[0]:=#0;
      Element.Prihod:=1;
      {Element.Stat :=False;}
      {Element.Locked :=False;}
      Element.Caption:=CurrentPassword;
      Element.Otdel:=255;
      Element.Class:=NoClassStr;

{$IfNDef Pharm}
      Element.VidNalog:=2;
      Element.Nalog:='0.00';
      Element.VidNDS:=3;
      Element.NDS:='18.00';
{$Else}
      Element.VidNalog:=2;
      Element.Nalog:='0.00';
      Element.VidNDS:=2;
      Element.NDS:='0.00';
{$EndIf}


      Element.KSertif:=NoOrganStr;
      Element.DSertif[0]:=#0;
      Element.Min:=  MinNazenkaStr;

      If (GetRazdelLitr(s1)=0) Then
       Begin
        Enl:=False;
        Element.Litr:='0.000';
       End;

{ЦСИККЛ ГОРОД МОСКВА}

      If AddSertif Then
       Begin
        Enl:=False;
        Element.Nalog:='0.00';
        Element.VidNalog:=2;
        Element.Market:=1;
        Element.Litr:='0.000';
        Element.InPack:='1';
        Element.EnableSklads:=1073741823;
        Element.Prihod:=1;
        Element.InPack2[0]:=#0;
        Element.Otdel:=17;{1 5}
{$IfDef Pharm}
        {Element.KSertif:='ГОССТАНДАРТ РОССИИ СИСТЕМА ГОСТР';}
{$Else}
        {Element.KSertif[0]:=#0;}
{$Endif}
        Element.DSertif[0]:=#0;
        Element.Min:=  '0.00';
       End;

      Element.Marker[0]:=#0;


      Element.Mera:=NoMeraStr;
      Element.NGroupKod:=NoGroupStr;

      Element.EnableDebit:=1;
      Element.EnableContract:=0;
      Element.Contract[0]:=#0;
      Element.ContractDate[0]:=#0;
      Element.KSertif := NoOrganStr;
      Element.PostKod := NoPostStr;
      Element.FirmaPostKod := NoPostStr;
      Element.Main:=0;
      Element.Prihod:=1;
      Element.FantomKod:=MainTovarStr;


    End;
  kbF4:Begin
     s:=TTT;
     TovarCod:=S;
     If Not GetBazElement(S,Element) Then
      Begin
       NoInfoMsg;
       MessageBox(^M+#3'Товар в базе не найден!',nil,mfError+mfCancelButton);
       System.Close(ElementFile);
       Res:=False;
       Exit;
      End;
      DelSpace(Element.Nalog);
      If (GetRazdelLitr(s1)=0) Then
       Begin
        Enl:=False;
       End;
    End;
  Else;
 End;
System.Close(ElementFile);
End
Else
 Begin
AddSertif:=True;
DInfoMsg('Читаю информацию о товарах...',False);
 Case Cod Of
  kbGrayPlus,kbAltF1:Begin
     Element.Employ:=True;
     For k:=0 To 99 Do
     Begin
      St:=IntToStr(k,CMAntissa);
      RFormatZerro(St,CMantissa);
      If GetRazdelStatus(st) Then
                 Begin
        Assign(ElementFile,Path^.Dat.ToName+st+'.id');
        C:=IOResult;
        OldFileMode:=FileMode;
        FileMode:=ReadOnlyN;
        Reset(ElementFile,SizeOf(BazType));
        C:=IOResult;
        FileMode:=OldFileMode;
        If c=0 Then
         Begin
          Element.Employ:=True;
          Find :=False;
          While Not(Eof(ElementFile)) And Not (Find) Do
           Begin
            New(BE,Init);
            ReadBufBaz(ElementFile,BE,Count);
            For c:=1 To Count Do
             Begin
        If Not BE^.Point.Dat[c].Employ Then
         Begin
          Find:=True;
          s:=BE^.Point.Dat[c].BazKod;
          Break;
         End;
             End;{For}
            Dispose(BE,Done);
           End;{While}
          System.Close(ElementFile);
          If Find Then Break;
         End;{c=0}
       End;{GetRazdelStatus}
     End;{For}

      If Not Find Then
       Begin
        NoInfoMsg;
        MessageBox(^M+#3'Свободных позиций для сертификатов - нет !',nil,mfWarning+mfCancelButton);
        Res:=False;
        Exit;
       End;

      Element.Name[0]:=#0;
      Element.Name2[0]:=#0;
      Element.Market:=1;

      Element.Litr[0]:=#0;
      Element.InPack:='1';
      Element.InPack2[0]:=#0;
      {Element.OKP[0]:=#0;}
      Element.Okp:=0;
      Element.Prihod:=1;
      Element.Massa[0]:=#0;
      Element.BuchGroup:=0;
      Element.Etil[0]:=#0;
      {Element.Stat :=False;}
      {Element.Locked :=False;}
      Element.Caption:=CurrentPassword;

      Element.VidNalog:=2;
      Element.Nalog:='0.00';
      Element.VidNDS:=0;
      Element.Class:=NoClassStr;
      Element.NDS:='20.00';

{$IfDef Pharm}
        Element.KSertif:=NoOrganStr;
        Element.VidNDS:=2;
        Element.NDS:='0.00';
{$Else}
        Element.KSertif:=NoOrganStr;
{$Endif}


      Element.DSertif[0]:=#0;
      Enl:=False;
      Element.Litr:='0.000';

      Element.Mera:=NoMeraStr;
      Element.Marker[0]:=#0;
      Element.Min:='0.00';
      Element.EnableSklads:=1073741823;
      Element.Otdel:=17;{1 5}
      Element.NGroupKod:=NoGroupStr;
      Element.EnableDebit:=1;
      Element.Prihod:=0;

      Element.EnableContract:=0;
      Element.Contract[0]:=#0;
      Element.ContractDate[0]:=#0;
      Element.KSertif := NoOrganStr;
      Element.PostKod := NoPostStr;
      Element.FirmaPostKod := NoPostStr;
      Element.Main:=0;
      Element.FantomKod:=MainTovarStr;

    End;
  kbF4:Begin
        ToVarCod:=St;
        s:=St;
        s1:=Copy(st,1,CRazdelKod);

     If Not GetBazElement(St,Element) Then
      Begin
       NoInfoMsg;
       MessageBox(^M+#3'Товар в базе не найден!',nil,mfError+mfCancelButton);
       Res:=False;
       Exit;
      End;
      DelSpace(Element.Nalog);
      Enl:=False;
    End;
  Else;
 End;
End;


R.Assign(0, 0, 0, 0);
LockPosition := New(PBox, Init(R, 1, Nil));
LockPosition^.NewList(New(PTextCollection, Init(0,1)));
FindNoMain:=False;

If (Cod=kbF4) Then
Begin
If Status And  Not(AddSertif) Then
 Begin
  If Element.Main=0 Then {если позиция является главной}
   Begin
    {смотрим список подчиненных позиций}

Assign(ElementFile,Path^.Dat.ToName+st+'.id');
OldFileMode:=FileMode;
FileMode:=ReadOnlyN;
Reset(ElementFile,SizeOf(BazType));
c:=IOResult;
FileMode:=OldFileMode;
If C<>0 Then
Begin
 MessageBox(^M+#3'Ошибка доступа к файлу '+st+'.id!',nil,mfError+mfCancelButton);
 Dispose(LockPosition,Done);
 Res:=False;
 Exit;
End;

     DInfoMsg('Проверяю товарный справочник...',False);
     While Not(Eof(ElementFile)) Do
     Begin
      New(BE,Init);
      ReadBufBaz(ElementFile,BE,Count);
      For c:=1 To Count Do
       Begin
        If BE^.Point.Dat[c].Employ And (BE^.Point.Dat[c].FantomKod=Element.BAzKod) And
	   (BE^.Point.Dat[c].BazKod<>Element.BAzKod) And (BE^.Point.Dat[c].Main=1)  Then
         Begin
          {блокируем SetNameLock}
          {если не удалось деблокирем наименования из списка чистим список}
          {добавляем в список}
          Format (BE^.Point.Dat[c].BazKod,CArtikul);
          LockPosition^.List^.Insert(NewStr('│'+BE^.Point.Dat[c].BazKod));
          LockPosition^.SetRange(LockPosition^.List^.Count);
         End;
       End;{For}
      Dispose(BE,Done);
     End;{While}
     c:=IOResult;
     System.Close(ElementFile);
     c:=IOResult;
     NoInfoMsg;

Error:=False;
If (LockPosition^.List^.Count-1)>=0 Then
Begin
For Count:=0 To LockPosition^.List^.Count-1 Do
 Begin
   SArt:=Copy(LockPosition^.GetText(Count,LockPosition^.List^.Count),1+1,CArtikul);
   FindNoMain:=True;
  If Not(SetNameLock(SArt,Operator)) Then
   Begin
    Beep;
    DInfoMsg('Дочерняя позиция ['+SArt+'] используется'+Operator+'. Не могу заблокировать!',
    False);
    Application^.ClearEvent(Event);
    Application^.ClearEvent(Event);
    repeat
    Application^.GetEvent(Event);
    until (Event.What <> evNothing) And (Event.Command<>cmMenu);
    NoInfoMsg;
    Application^.ClearEvent(Event);
    Error:=True;
    Break;
   End;
 End;
End;


If (Error) And (Count>0) Then
 Begin
  For l:=Count-1 DownTo 0 Do
   Begin
    SArt:=Copy(LockPosition^.GetText(l,LockPosition^.List^.Count),1+1,CArtikul);
    Repeat
    Until SetNameUnLock(SArt);
   End;
 End;

If Error Then
 Begin
  Dispose(LockPosition,Done);
  Exit;
 End;

   End;{If Element.Main=0 Then}
 End;{If Not(Status) And  Not(AddSertif) Then}
End;{If (Cod=kbGrayPlus) Or (Cod=kbAltF1) Then}



1:
If (Cod=kbGrayPlus)Or (Cod=kbAltF1) Then
Begin
{R.Assign(8, 0, 72, 23);}
R.Assign(5, 0, 78, 23);
New(NameWin, Init(R, 'Добавить наименование товара'))
End
Else
Begin
{R.Assign(8, 0, 72, 19);}
R.Assign(5, 0, 78, 20);
New(NameWin, Init(R, 'Изменить наименование товара'));
End;
NameWin^.Options := NameWin^.Options or ofCenterX or ofCenterY;
NameWin^.Palette := dpCyanDialog;
NameWin^.HelpCtx:=$E011;
NameWin^.SEnableName:=EnableName;{просмотр или редактирование}
NameWin^.SStatus:=Status;{True - товар False - сертификат}
NameWin^.SRegim:=Regim;{True - открыть закрыть к продаже /консигнации; False -изменить нельзя}
NameWin^.SEnl:=Enl;{True - литраж есть False - литраж нет}
NameWin^.AddSert:=AddSertif;{True - литраж есть False - литраж нет}
NameWin^.RKod:=St;{код предполагаемого раздела}
NameWin^.FoundNoMain:=FindNoMain;{имеются дочерние позиции}
If (Cod=kbGrayPlus)Or (Cod=kbAltF1) Then NameWin^.Edit:=False
Else NameWin^.Edit:=True;

If (Cod=kbF4) And (Element.Main=1) Then NameWin^.EditNoMain:=True
Else NameWin^.EditNoMain:=False;


{
R.Assign(32, 8, 55, 10);
Control := New(PColoredText, Init(R, '', $3E));
Control^.Options := Control^.Options or ofFramed;
NameWin^.Insert(Control);
}

R.Assign(16, 6, 29, 10);
Control := New(PStaticText, Init(R, ''));
Control^.Options := Control^.Options or ofFramed;
NameWin^.Insert(Control);


R.Assign(2, 6, 15, 10);
Control := New(PColoredText, Init(R, '', $3E));
Control^.Options := Control^.Options or ofFramed;
NameWin^.Insert(Control);


{первая строка наименования}
{R.Assign(1, 3, 29, 4);}
R.Assign(1, 2, 29, 3);
ControlLine := New(PInputLine, Init(R, CName));
If Not(ENableName) Then
ControlLine^.Options := ControlLine^.Options and not ofSelectable;
NameWin^.Insert(ControlLiNe);

If (ENableName) and Not(Element.Main=1) Then
Begin
  R.Assign(29, 2, 32, 3);
  If Status Then
  NameWin^.Insert(New(PHistory, Init(R, PInputline(ControlLine), 13)))
  Else
  NameWin^.Insert(New(PHistory, Init(R, PInputline(ControlLine), 14)));
End;
  {R.Assign(1, 2, 21, 3);}
  R.Assign(1, 1, 21, 2);
  NameWin^.Insert(New(PLabel, Init(R, 'Наи~м~еновние товара:', ControlLine)));

{вторая строка наименования}
{R.Assign(1, 4, 29, 5);}
R.Assign(1, 3, 29, 4);
ControlLine2 := New(PInputLine, Init(R, CName));
If Not(ENableName) Then
ControlLine2^.Options := ControlLine2^.Options and not ofSelectable;
NameWin^.Insert(ControlLiNe2);
{конец}

If Cod=kbF4 Then
 Begin
  S:=TovarCod;
  {R.Assign(1, 1, 12, 2);}
  R.Assign(52, 1, 56, 2);
  Control := New(PColoredText, Init(R, 'Код товара:', $3E));
  NameWin^.Insert(Control);

  {R.Assign(12, 1, 17, 2);}
  R.Assign(56, 1, 61, 2);
  Control := New(PColoredText, Init(R, s, $3E));
  NameWin^.Insert(Control);
 End;

{R.Assign(32, 3, 39, 4);}
R.Assign(40, 2, 47, 3);
ControlLitr := New(PRealInputLine, Init(R, CLitr));
NameWin^.Insert(ControlLitr);
If Not(ENl) Then
ControlLitr^.Options := ControlLitr^.Options and not ofSelectable;
If Not Status Then
ControlLitr^.Options := ControlLitr^.Options and not ofSelectable;

  PInputLine(ControlLitr)^.Validator := New(PPXPictureValidator, Init('#[#].[#[#[#]]]', True));

  {R.Assign(31, 2, 39, 3);}
  R.Assign(32, 2, 40, 3);
  NameWin^.Insert(New(PLabel, Init(R, '~Л~итраж:', ControlLitr)));

{R.Assign(40, 3, 45, 4);}
R.Assign(52, 2, 57, 3);
ControlInPack := New(PInputLine, Init(R, CInPack));
NameWin^.Insert(ControlInPack);

If Not Status Then
ControlInPack^.Options := ControlInPack^.Options and not ofSelectable;

  PInputLine(ControlInPack)^.Validator := New(PRangeValidator, Init(1, 999));

  {R.Assign(40, 2, 45, 3);}
  R.Assign(47, 2, 52, 3);
  NameWin^.Insert(New(PLabel, Init(R, '~Ф~ас:', ControlInPack)));


{R.Assign(40, 4, 45, 5);}
R.Assign(58, 2, 63, 3);
ControlInPack2 := New(PInputLine, Init(R, CInPack));

If Not Status Then
ControlInPack2^.Options := ControlInPack2^.Options and not ofSelectable;
NameWin^.Insert(ControlInPack2);


{R.Assign(46, 3, 54, 4);}
R.Assign(40, 3, 48, 4);
ControlOKP := New(PInputLong, Init(R, 6, 0, 999999, 0));
If Not Status Then
ControlOKP^.Options := ControlOKP^.Options and not ofSelectable;
NameWin^.Insert(ControlOKP);

  {R.Assign(45, 2, 54, 3);}
  R.Assign(31, 3, 40, 4);
  NameWin^.Insert(New(PLabel, Init(R, 'Код ОК~П~:', ControlOKP)));

{R.Assign(55, 3, 63, 4);}
R.Assign(55, 3, 63, 4);
ControlMassa := New(PInputLine, Init(R, CMAssa));
If Not Status Then
ControlMassa^.Options := ControlMassa^.Options and not ofSelectable;

NameWin^.Insert(ControlMassa);

  {R.Assign(55, 2, 62, 3);}
  R.Assign(48, 3, 55, 4);
  NameWin^.Insert(New(PLabel, Init(R, 'Масса:', ControlMassa)));


{R.Assign(14, 6, 17, 7);}
R.Assign(14, 4, 17, 5);
ControlBuch := New(PInputLong, Init(R, 1, 0, 8, 2));
NameWin^.Insert(ControlBuch);

If (Not Status) Or (EnableZakupka=0) Or (Pharm=1) Then
ControlBuch^.Options := ControlBuch^.Options and not ofSelectable;
ControlBuch^.Options := ControlBuch^.Options and not ofFirstClick;


  {R.Assign(1, 6, 14, 7);}
  R.Assign(1, 4, 14, 5);
  NameWin^.Insert(New(PLabel, Init(R, '~Г~руппа бух.:',ControlBuch)));


{R.Assign(24, 6, 31, 7);}
R.Assign(24, 4, 31, 5);
ControlEtil := New(PInputLine, Init(R, CLitr));
NameWin^.Insert(ControlEtil);

If (Not Status) Or (EnableZakupka=0) Or (Pharm=1) Then
ControlEtil^.Options := ControlEtil^.Options and not ofSelectable;
  PInputLine(ControlEtil)^.Validator := New(PPXPictureValidator, Init('#[[#][.][#[#]]]', True));

  {R.Assign(17, 6, 24, 7);}
  R.Assign(17, 4, 24, 5);
  NameWin^.Insert(New(PLabel, Init(R, 'Ал~к~ог:', ControlEtil)));


R.Assign(65, 4, 71, 5);
ControlClass := New(PROInputLine, Init(R, CClientKod));
If (Not Status) Or (AddSertif) Or (Element.MAin=1) Then
ControlClass^.Options := ControlClass^.Options and not ofSelectable;
ControlClass^.Options := ControlClass^.Options and not ofFirstClick;
NameWin^.Insert(ControlClass);

  {R.Assign(2, 14, 23, 15);}
  R.Assign(31, 4, 38, 5);
  NameWin^.Insert(New(PLabel, Init(R, 'Кл~а~сс:', ControlClass)));

R.Assign(38, 4, 66, 5);
RFormatZerro(Element.Class,CClientKod);
ss:=GetClassField(FClass,Element.Class);
Format(ss,CNAme);
ControlClassS := New(PColoredText, Init(R, ' '+ss+'│', $13));
NameWin^.Insert(ControlClassS);




{R.Assign(32, 5, 45, 6);}
R.Assign(32, 5, 45, 6);
ControlMrk := New(PCheckboxes, Init(R,
  NewSItem('Про~д~ажа', Nil)));


If Not Status Then
ControlMrk^.Options := ControlMrk^.Options and not ofSelectable;


If Not(Regim) Then
ControlMrk^.Options := ControlMrk^.Options and not ofSelectable;
NameWin^.Insert(ControlMrk);


{R.Assign(46, 5, 63, 6);}
R.Assign(44, 5, 61, 6);
ControlConsig := New(PCheckboxes, Init(R,
  NewSItem('О~т~срочка', Nil)));

If Not Status Then
ControlConsig^.Options := ControlConsig^.Options and not ofSelectable;
NameWin^.Insert(ControlConsig);

If Not(Regim) Then
ControlConsig^.Options := ControlConsig^.Options and not ofSelectable;
NameWin^.Insert(ControlConsig);


{R.Assign(32, 5, 45, 6);}
R.Assign(57, 5, 69, 6);
ControlPrh := New(PCheckboxes, Init(R,
  NewSItem('Приход', Nil)));


If Not Status Then
ControlPrh^.Options := ControlPrh^.Options and not ofSelectable;

If Not(Regim) Then
ControlPrh^.Options := ControlPrh^.Options and not ofSelectable;

If NameWin^.EditNoMain Then
ControlPrh^.Options := ControlPrh^.Options and not ofSelectable;
NameWin^.Insert(ControlPrh);



{
R.Assign(2, 8, 15, 13);
Control := New(PColoredText, Init(R, '', $3E));
Control^.Options := Control^.Options or ofFramed;
NameWin^.Insert(Control);
}

{R.Assign(2, 8, 15, 11);}
R.Assign(2, 6, 15, 9);
ControlVidNalog := New(PRadioButtons, Init(R,
  NewSItem('~И~мпорт',
  NewSItem('~О~теч.',
  NewSItem('Про~ч~ее', Nil)))));

If Not Status Then
ControlVidNalog^.Options := ControlVidNalog^.Options and not ofSelectable;
NameWin^.Insert(ControlVidNalog);

  {R.Assign(2, 7, 13, 8);}
  R.Assign(2, 5, 13, 6);
  NameWin^.Insert(New(PLabel, Init(R, 'Ставка НП:', ControlVidNalog)));


{R.Assign(7, 12, 14, 13);}
R.Assign(7, 9, 14, 10);
ControlNalog := New(PRealInputLine, Init(R, CLitr));
If Element.VidNAlog in [0,1] Then
  ControlNAlog^.Options := ControlNAlog^.Options and not ofSelectable
 Else
  ControlNAlog^.Options := ControlNAlog^.Options or ofSelectable;

If Not Status Then
ControlNalog^.Options := ControlNalog^.Options and not ofSelectable;

NAmeWin^.Insert(ControlNalog);
{  PInputLine(ControlNalog)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));}

  {R.Assign(2, 12, 7, 13);}
  R.Assign(2, 9, 7, 10);
  NameWin^.Insert(New(PLabel, Init(R, '~С~НП:', ControlNalog)));

{
R.Assign(16, 8, 29, 13);
Control := New(PStaticText, Init(R, ''));
Control^.Options := Control^.Options or ofFramed;
NameWin^.Insert(Control);
}
{R.Assign(16, 8, 29, 11);}
R.Assign(16, 6, 29, 10);
ControlVidNDS := New(PRadioButtons, Init(R,
  NewSItem('~2~0 %  ',
  NewSItem('~1~0 %   ',
  NewSItem('П~р~очее',
  NewSItem('1~8~ %',
 Nil))))));

If Not Status Then
ControlVidNDS^.Options := ControlVidNDS^.Options and not ofSelectable;

NameWin^.Insert(ControlVidNDS);

  {R.Assign(16, 7, 28, 8);}
  R.Assign(16, 5, 28, 6);
  NameWin^.Insert(New(PLabel, Init(R, 'Ставка НДС:', ControlVidNDS)));

{R.Assign(21, 12, 28, 13);}
R.Assign(21, 10, 28, 11);
ControlNDS := New(PRealInputLine, Init(R, CLitr));

If Element.VidNDS in [0,1,3] Then
  ControlNDS^.Options := ControlNDS^.Options and not ofSelectable
 Else
  ControlNDS^.Options := ControlNDS^.Options or ofSelectable;

If Not Status Then
ControlNDS^.Options := ControlNDS^.Options and not ofSelectable;


NameWin^.Insert(ControlNDS);
{  PInputLine(ControlNDS)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));}

  {R.Assign(16, 12, 21, 13);}
  R.Assign(16, 10, 21, 11);
  NameWin^.Insert(New(PLabel, Init(R, '~Н~ДС:', ControlNDS)));

{R.Assign(60, 6, 66, 7);}
R.Assign(47, 7, 53, 8);
ControlMera := New(PROInputLine, Init(R, CClientKod));
If (Not Status) Or (AddSertif) Or (Element.MAin=1) Then
ControlMera^.Options := ControlMera^.Options and not ofSelectable;
ControlMera^.Options := ControlMera^.Options and not ofFirstClick;

NameWin^.Insert(ControlMera);

  {R.Assign(31, 6, 44, 7);}
  R.Assign(30, 6, 49, 7);
  NameWin^.Insert(New(PLabel, Init(R, 'Едини~ц~а изм.:', ControlMera)));

{R.Assign(44, 6, 61, 7);}
R.Assign(31, 7, 48, 8);
ss:=GetMeraField(FMera,Element.Mera);
Format(ss,CMera);
ControlMeraS := New(PColoredText, Init(R, ' '+ss+'│', $13));
NameWin^.Insert(ControlMeraS);





{R.Assign(32, 7, 55, 8);}
R.Assign(30, 8, 53, 9);
ControlContract := New(PCheckboxes, Init(R,
  NewSItem('Серийн.прои~з~вод-во', Nil)));
If AddSertif Then
ControlContract^.Options := ControlContract^.Options and not ofSelectable;
NameWin^.Insert(ControlContract);


{R.Assign(32, 9, 40, 10);}
R.Assign(30, 10, 38, 11);
ControlContractNumer := New(PInputLine, Init(R, CContract));
If Not(Element.EnableContract=1) Then
ControlContractNumer^.Options := ControlContractNumer^.Options and not ofSelectable;
NameWin^.Insert(ControlContractNumer);


  {R.Assign(32, 8, 55, 9);}
  R.Assign(30, 9, 53, 10);
  NameWin^.Insert(New(PLabel, Init(R, 'Договор с поставщиком:', ControlContractNumer)));

{R.Assign(44, 9, 54, 10);}
R.Assign(42, 10, 53, 11);
ControlContractDate := New(PDateInputLine, Init(R, CDate));
If Not(Element.EnableContract=1) Then
ControlContractDAte^.Options := ControlContractDate^.Options and not ofSelectable;
NameWin^.Insert(ControlContractDate);
  PDateInputLine(ControlContractDate)^.Validator := New(PPXPictureValidator, Init(DateFiltr, True));

  {R.Assign(40, 9, 44, 10);}
  R.Assign(38, 10, 42, 11);
  NameWin^.Insert(New(PLabel, Init(R, 'от:', ControlContractDate)));



R.Assign(54, 7, 69, 11);
ControlOtdel := New(PCheckboxes, Init(R,
  NewSItem('1',
  NewSItem('2',
  NewSItem('~3~',
  NewSItem('~4~',
  NewSItem('~5~',
  NewSItem('~6~',
  NewSItem('~7~',
  NewSItem('8',
  Nil))))))))));
If (Not Status) Or (EnableZakupka=0) Or (Element.Main=1) or (Addsertif) Then
ControlOtdel^.Options := ControlOtdel^.Options and not ofSelectable;
NameWin^.Insert(ControlOtdel);


R.Assign(54, 6, 65, 7);
NameWin^.Insert(New(PLabel, Init(R, '~О~тделения:', ControlOtdel)));



{R.Assign(1, 11, 64, 13);}
R.Assign(1, 11, 71, 13);
{
ControlSkladFiltr := New(PCheckboxes, Init(R,
  NewSItem('1',
  NewSItem('2',
  NewSItem('3',
  NewSItem('4',
  NewSItem('5',
  NewSItem('6',
  NewSItem('7',
  NewSItem('8',
  NewSItem('9',
  NewSItem('10',
  NewSItem('11',
  NewSItem('12',
  NewSItem('13',
  NewSItem('14',
  NewSItem('15', Nil)))))))))))))))));
}

ControlSkladFiltr := New(PMyListBox, Init(R, 'X', 10, Nil,False{ReadOnlye=False}));
ControlSkladFiltr^.NewList(New(PCollection, Init(0,1)));

For c:=1 To Max30 Do
 Begin
  St:=IntToStr(C,CMantissa);
  RFormatZerro(st,CMantissa);
  ControlSkladFiltr^.List^.Insert(New(PStringO,Init(st)));
  ControlSkladFiltr^.SetRange(ControlSkladFiltr^.List^.Count);
 End;

If (Not Status) Or (EnableZakupka=0) {Or (Pharm=1)} Or (Element.Main=1) or (Addsertif) Then
ControlSkladFiltr^.Options := ControlSkladFiltr^.Options and not ofSelectable;

NameWin^.Insert(ControlSkladFiltr);


R.Assign(9, 13, 14, 14);
ControlMarker := New(PInputLine, Init(R, CLitrMantissa));
If (Not Status) Or (EnableZakupka=0) Or (Element.Main=1) or (Addsertif) Then
ControlMarker^.Options := ControlMarker^.Options and not ofSelectable;
NameWin^.Insert(ControlMarker);

  R.Assign(1, 13, 9, 14);
  NameWin^.Insert(New(PLabel, Init(R, '~М~аркер:', ControlMarker)));

R.Assign(9, 14, 16, 15);
If EnableZakupka=1 Then
ControlMin := New(PInputLine, Init(R, CArtikul))
Else
ControlMin := New(PSInputLine, Init(R, CArtikul));
If (Not Status) Or (EnableZakupka=0) Or(Element.Main=1) or (Addsertif) Then
ControlMin^.Options := ControlMin^.Options and not ofSelectable;
NameWin^.Insert(ControlMin);
  PInputLine(ControlMin)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));

  R.Assign(3, 14, 9, 15);
  NameWin^.Insert(New(PLabel, Init(R, 'Min%:', ControlMin)));


{R.Assign(39, 13, 45, 14);}
R.Assign(39, 13, 45, 14);
ControlLand := New(PROInputLine, Init(R, CClientKod));
If (Not Status) Or (AddSertif) Or (Element.MAin=1) Then
ControlLand^.Options := ControlLand^.Options and not ofSelectable;
ControlLand^.Options := ControlLand^.Options and not ofFirstClick;
NameWin^.Insert(ControlLand);

  {R.Assign(1, 13, 23, 14);}
  R.Assign(15, 13, 23, 14);
  NameWin^.Insert(New(PLabel, Init(R, 'Ст~р~ана:', ControlLand)));

R.Assign(23, 13, 40, 14);
RFormatZerro(Element.PostKod,CClientKod);
ss:=GetPostField(FPost,Element.PostKod);
Format(ss,CPost);
ControlLandS := New(PColoredText, Init(R, ' '+ss+'│', $13));
NameWin^.Insert(ControlLandS);


R.Assign(66, 14, 72, 15);
ControlFirmaPost := New(PROInputLine, Init(R, CClientKod));
If (Not Status) Or (AddSertif) Or (Element.MAin=1) Then
ControlFirmaPost^.Options := ControlFirmaPost^.Options and not ofSelectable;
ControlFirmaPost^.Options := ControlFirmaPost^.Options and not ofFirstClick;
NameWin^.Insert(ControlFirmaPost);

  {R.Assign(2, 14, 23, 15);}
  R.Assign(23, 14, 30, 15);
  NameWin^.Insert(New(PLabel, Init(R, 'Фирма:', ControlFirmaPost)));

R.Assign(30, 14, 67, 15);
RFormatZerro(Element.FirmaPostKod,CClientKod);
ss:=GetFirmaPostField(FFirmaPost,Element.FirmaPostKod);
Format(ss,CFirmaPost);
ControlFirmaPostS := New(PColoredText, Init(R, ' '+ss+'│', $13));
NameWin^.Insert(ControlFirmaPostS);

R.Assign(50, 15, 56, 16);
ControlGroup := New(PROInputLine, Init(R, CClientKod));
If (Not Status) Or (AddSertif) Or (Element.MAin=1) Then
ControlGroup^.Options := ControlGroup^.Options and not ofSelectable;
ControlGroup^.Options := ControlGroup^.Options and not ofFirstClick;
NameWin^.Insert(ControlGroup);

  R.Assign(15, 15, 23, 16);
  NameWin^.Insert(New(PLabel, Init(R, 'Гр~у~ппа:', ControlGroup)));

R.Assign(23, 15, 51, 16);
ss:=GetGroupField(FName,Element.NGroupKod);
RFormatZerro(Element.NGroupKod,CClientKod);
Format(ss,CName);
ControlGroupS := New(PColoredText, Init(R, ' '+ss+'│', $13));
NameWin^.Insert(ControlGroupS);



R.Assign(2, 16, 27, 17);
ControlMain := New(PCheckboxes, Init(R,
  NewSItem('Дочерн~я~я партия от:', Nil)));
NameWin^.Insert(ControlMain);

If Not(ENableName) Or Not(Status) Or (AddSertif) Or NameWin^.FoundNoMain
{Or ((NameWin^.EditNoMain) And (StrToInt(CurrentPassword)<>0))}Then
ControlMain^.Options := ControlMain^.Options and not ofSelectable;


If (Element.Main=0) Then
If (Cod=kbF4) Then Element.FAntomKod:=Element.BazKod
Else
Element.FAntomKod:=NoSertifStr;

R.Assign(56, 17, 63, 18);
ControlMainName := New(PROInputLine, Init(R, CArtikul));

RFormatZerro(Element.FantomKod,CArtikul);
If Not(ENableName) Or Not(Status) Or AddSertif Or NameWin^.FoundNoMain
{найдена дочерняя позиция
 Password(4) EnableName
 статус - товар True или сертификат False
идет добавление сертификата AddSertif}
Or ((NameWin^.EditNoMain) And (StrToInt(CurrentPassword)<>0)) Then
ControlMainName^.Options := ControlMainName^.Options and not ofSelectable;
ControlMainName^.Options := ControlMainName^.Options and not ofFirstClick;

NameWin^.Insert(ControlMainName);


If NameWin^.FoundNoMain then
Begin
R.Assign(26, 16, 69, 17);
Control := New(PColoredText,Init(R, '<-Обнаружены дочерние позиции!', $5E));
NameWin^.Insert(Control);
End;

ss:=GetIDFIeld(FFFNAme,Element.FantomKod);
Format(ss,CNAme+1+CNAme);
R.Assign(2, 17, 57, 18);
ControlMainNameS := New(PColoredText, Init(R, ' '+ss+'│', $13));

If (Element.Main=1) And Not AddSertif Then
Begin
ControlMainName^.Options := ControlMainName^.Options Or ofSelectable;
If Not(ENableName) Or Not(Status) Or (AddSertif)
Or ((NameWin^.EditNoMain) And (StrToInt(CurrentPassword)<>0))Then
ControlMainName^.Options := ControlMainName^.Options and not ofSelectable;
End
Else
Begin
ControlMainName^.Options := ControlMainName^.Options and not ofSelectable;
End;


{$IFDEF PHARM}
If (ENableName) And (Status) And Not(AddSertif) And Not(NameWin^.FoundNoMain) Then
ControlMain^.Options := ControlMainName^.Options Or ofSelectable;
If (ENableName) And (Status) And Not(AddSertif) And Not(NameWin^.FoundNoMain) Then
ControlMainName^.Options := ControlMainName^.Options Or ofSelectable;
{$ENDIF}

NameWin^.Insert(ControlMainNameS);

  {
  R.Assign(3, 13, 34, 14);
  NameWin^.Insert(New(PLabel, Init(R, 'Разрешен на следующих объектах', Control)));
  }
If AddSertif Then
Begin

R.Assign(49, 18, 55, 19);
ControlKSertif := New(PROInputLine, Init(R, CClientKod));
NameWin^.Insert(ControlKSertif);
ControlKSertif^.Options := ControlKSertif^.Options and not ofFirstClick;

  R.Assign(1, 18, 8, 19);
  NameWin^.Insert(New(PLabel, Init(R, 'Выдан:', ControlKSertif)));

R.Assign(8, 18, 50, 19);
RFormatZerro(Element.KSertif,CClientKod);
ss:=GetKSertifField(FKtoSertif,Element.KSertif);
Format(ss,CKSertif);
ControlKSertifS := New(PColoredText, Init(R, ' '+ss+'│', $13));
NameWin^.Insert(ControlKSertifS);

R.Assign(59, 18, 69, 19);
Control := New(PDAteInputLine, Init(R, CDate));
NameWin^.Insert(Control);
PDateInputLine(Control)^.Validator := New(PPXPictureValidator, Init(DateFiltr, True));

  R.Assign(55, 18, 59, 19);
  NameWin^.Insert(New(PLabel, Init(R, 'До:', Control)));
End;

DelSpace(Element.Contract);
DelSpace(Element.ContractDate);

NameWin^.SetData(Element);

If (Cod = kbGrayPlus)Or (Cod=kbAltF1)  Then
Begin
R.Assign(69, 19, 70, 22);
Control := New(PScrollBar, Init(R));
NameWin^.Insert(Control);

R.Assign(1, 20, 69, 22);

BazNum := New(PBox, Init(R, 8, PScrollbar(Control)));

BazNum^.NewList(New(PTextCollection, Init(0,1)));
If Status Then
Begin
 Assign (ElementFile,Path^.Dat.ToName+s1+'.id');
 OldFileMode:=FileMode;
 FileMode:=ReadOnlyN;
 Reset (ElementFile,SizeOf(BazType));
 FileMode:=OldFileMode;
 While Not(Eof(ElementFile)) Do
  Begin
    New(Be,Init);
    ReadBufBaz(ElementFile,BE,Count);
  For c:=1 To Count Do
  Begin
     If Not BE^.Point.Dat[c].Employ Then
     Begin
      Format (BE^.Point.Dat[c].BazKod,CArtikul);
      BazNum^.List^.Insert(NewStr('│'+BE^.Point.Dat[c].BazKod));
      BazNum^.SetRange(BazNum^.List^.Count);
     End;
  End;{For}
    Dispose(BE,Done);
  End;{While}
 System.Close(ElementFile);
End
Else
Begin
 For k:=0 To 99 Do
  Begin
   St:=IntToStr(k,CMAntissa);
   RFormatZerro(St,CMantissa);
   If GetRazdelStatus(st) Then
       Begin
        Assign(ElementFile,Path^.Dat.ToName+st+'.id');
        C:=IOResult;
        OldFileMode:=FileMode;
        FileMode:=ReadOnlyN;
        Reset(ElementFile,SizeOf(BazType));
        C:=IOResult;
        FileMode:=OldFileMode;
        If c=0 Then
         Begin
 While Not(Eof(ElementFile)) Do
  Begin
   New(BE,Init);
   ReadBufBaz(ElementFile,BE,Count);
  For c:=1 To Count Do
  Begin
   If Not(BE^.Point.Dat[c].Employ) Then
   Begin
   Format (BE^.Point.Dat[c].BazKod,CArtikul);
   BazNum^.List^.Insert(NewStr('│'+BE^.Point.Dat[c].BazKod));
   BazNum^.SetRange(BazNum^.List^.Count);
   End;
  End;{For}
   Dispose(BE,Done);
  End;{While}
   System.Close(ElementFile);

         End;{c=0}
       End;{GetRazdelStatus}
  End;{For}
End;{else}

 If Cod=kbF4 Then BazNum^.FocusItem(LoCation(BazNum,s,False))
 Else BazNum^.FocusItem(0);
 BazNum^.HelpCtx:=$E011;

NameWin^.Insert(BazNum);

 R.Assign(1, 19, 48, 20);
 NameWin^.Insert(New(PLabel, Init(R, 'Доступные ~к~оды для наименования товара:', BazNum)));
End;

NameWin^.SetStatus;

NameWin^.SelectNext(False);

NoinfoMsg;
c:=Desktop^.ExecView(NameWin);
If c<>cmCancel Then
 Begin
  NameWin^.GetData(Element);
  {memC(IntToStr(Element.EnableSklads,CAll));}
  DelSpaceRight(Element.Name);
  DelSpaceRight(Element.Name2);
  DelSpaceRight(Element.Mera);

  If AddSertif Then
  Begin
   DelSpaceRight(Element.KSertif);
   DelSpaceRight(Element.DSertif);
  End
   Else Begin
         Element.KSertif[0]:=#0;
         Element.DSertif[0]:=#0;
        End;

  If Element.Name[0]=#0 Then
   Begin
    MessageBox(^M+#3'Недопустимое наименование товара!',nil,mfError+mfCancelButton);
    If (Cod=kbGrayPlus)Or (Cod=kbAltF1) Then
      Begin
       BazNum^.NewList(Nil);
       Dispose(BazNum,Done);
      End;
    Dispose(Control,Done);
    Dispose(NameWin,Done);
    Goto 1;
   End;

If AddSertif Then
Begin
   If (Element.DSertif[0]<>#0) Then
   Begin
   If Not(TestDate(Element.DSertif,Test)) Then
    Begin
     MessageBox(^M+#3'Ошибка при вводе срока действия сертификата!',Nil,mfError+mfCancelButton);
     Goto 1;
    End;
   If Not(DateStringToDate(DateMask,Element.DSertif)>DateStringToDate(DateMask,FDate)) Then
    Begin
     MessageBox(^M+#3'Истек срок действия сертификата!',Nil,mfWarning+mfCancelButton);
    End;
   End
   Else
     MessageBox(^M+#3'Не указан срок действия сертификата!',Nil,mfError+mfCancelButton);
End;

  MyStr(StrToReal(Element.Litr),CKol,CLitrMantissa,Element.Litr);

  If (Element.Litr[0]=#0) Then
    Begin
      MessageBox(^M+#3'У товара не указан литраж!',nil,mfError+mfCancelButton);
       If (Cod=kbGrayPlus)Or (Cod=kbAltF1) Then
         Begin
          BazNum^.NewList(Nil);
          Dispose(BazNum,Done);
         End;
       Dispose(Control,Done);
       Dispose(NameWin,Done);
       Goto 1;
    End;

  If Status Then
  If ((StrToReal(Element.Litr)=0)And(GetRazdelLitr(s1)<>0))
  Or((StrToReal(Element.Litr)<>0)And(GetRazdelLitr(s1)=0)) Then
    Begin
      MessageBox(^M+#3'Настройки раздела не соответствуют литражу у наименования!',nil,mfError+mfCancelButton);
      If (Cod=kbGrayPlus)Or (Cod=kbAltF1) Then
        Begin
         BazNum^.NewList(Nil);
         Dispose(BazNum,Done);
        End;
      Dispose(Control,Done);
      Dispose(NameWin,Done);
      Goto 1;
    End;

  DelSpace(Element.Etil);
  If Status Then
  If ((StrToReal(Element.Etil)=0)And(GetRazdelLitr(s1)<>0))
  Or((StrToReal(Element.Etil)<>0)And(GetRazdelLitr(s1)=0)) Then
    Begin
      MessageBox(^M+#3'Настройки раздела не соответствуют крепости у наименования!',nil,mfError+mfCancelButton);
      If (Cod=kbGrayPlus)Or (Cod=kbAltF1) Then
        Begin
         BazNum^.NewList(Nil);
         Dispose(BazNum,Done);
        End;
      Dispose(Control,Done);
      Dispose(NameWin,Done);
      Goto 1;
    End;

  MyStr(StrToReal(Element.Etil),CLitr,CMantissa,Element.Etil);
  DelSpace(Element.Etil);

  If Element.InPack[0]=#0 Then
    Begin
      MessageBox(^M+#3'У товара не указана фасовка!',nil,mfError+mfCancelButton);
      If (Cod=kbGrayPlus)Or (Cod=kbAltF1) Then
       Begin
         BazNum^.NewList(Nil);
         Dispose(BazNum,Done);
       End;
       Dispose(Control,Done);
       Dispose(NameWin,Done);
       Goto 1;
    End;


 If Not AddSertif Then
 If Element.Main=1 Then
    Begin
      If Element.FantomKod=NoSertifStr Then
      Begin
       MessageBox(^M+#3'Недопустимый код главной позиции!',nil,mfError+mfCancelButton);
       If (Cod=kbGrayPlus)Or (Cod=kbAltF1) Then
       Begin
         BazNum^.NewList(Nil);
         Dispose(BazNum,Done);
       End;
       Dispose(Control,Done);
       Dispose(NameWin,Done);
       Goto 1;
      End;
    End;


  If Element.EnableContract=1 Then
    Begin
      DelSpace(Element.Contract);
      If Element.Contract[0]=#0 Then
     Begin
      MessageBox(^M+#3'У товара серийного производства не указан номер договора поставки!',nil,mfError+mfCancelButton);
      If (Cod=kbGrayPlus)Or (Cod=kbAltF1) Then
       Begin
         BazNum^.NewList(Nil);
         Dispose(BazNum,Done);
       End;
       Dispose(Control,Done);
       Dispose(NameWin,Done);
       Goto 1;
     End;{контракт}


   If Not(TestDate(Element.ContractDate,Test)) Then
    Begin
      MessageBox(#3'У товара серийного производства не указана или неправильно указана дата договора поставки!',
         nil,mfError+mfCancelButton);
      If (Cod=kbGrayPlus)Or (Cod=kbAltF1) Then
       Begin
         BazNum^.NewList(Nil);
         Dispose(BazNum,Done);
       End;
       Dispose(Control,Done);
       Dispose(NameWin,Done);
       Goto 1;
    End;{дата контракта}

   End;

  If Element.Mera[0]=#0 Then
      MessageBox(^M+#3'У товара не указана единица измерения!',nil,mfError+mfCancelButton)
   Else
   {ChekAddStr(Element.Mera,3);}


  {убрал 12.01.2000 т.к. все налоги у нас 0
  If (Element.Nalog[0]=#0) Or (StrTOReal(Element.Nalog)=0) Then
   Begin
      MessageBox(#3+NoNalog,nil,mfWarning+mfCancelButton);
   End;
  }
  If (StrTOReal(Element.Nalog)>99.99) Then
   Begin
      MessageBox(#3+ErrorNAlog^,nil,mfError+mfCancelButton);
      If (Cod=kbGrayPlus)Or (Cod=kbAltF1) Then
       Begin
         BazNum^.NewList(Nil);
         Dispose(BazNum,Done);
       End;
       Dispose(Control,Done);
       Dispose(NameWin,Done);
       Goto 1;
   End;

{добавлено 15/03/2000 но временно выключенно
  If Element.OKP[0]=#0 Then
    Begin
      MessageBox(^M+#3'У товара не указан код ОКП!',nil,mfError+mfCancelButton);
    End;

  If StrToReal(Element.Massa)<0.0009 Then
    Begin
      MessageBox(^M+#3'У товара не указана масса!',nil,mfError+mfCancelButton);
    End;
}
  MyStr(StrToReal(Element.Massa),CMassa,CLitrMAntissa,Element.Massa);
  DelSpace(Element.Massa);
  MyStr(StrToReal(Element.Etil),CLitr,CMAntissa,Element.Etil);
  DelSpace(Element.Etil);
  MyStr(StrToReal(Element.Nalog),CLitr,CMantissa,Element.Nalog);
  DelSpace(Element.Nalog);

  If (Element.NDS[0]=#0) Or (StrTOReal(Element.NDS)=0) Then
   Begin
      MessageBox(#3+NoNDS^,nil,mfError+mfCancelButton);
   End;

  If (StrTOReal(Element.NDS)>99.99) Then
   Begin
      MessageBox(#3+ErrorNDS^,nil,mfError+mfCancelButton);
      If (Cod=kbGrayPlus)Or (Cod=kbAltF1) Then
       Begin
         BazNum^.NewList(Nil);
         Dispose(BazNum,Done);
       End;
       Dispose(Control,Done);
       Dispose(NameWin,Done);
       Goto 1;
   End;

  MyStr(StrToReal(Element.NDS),CLitr,CMantissa,Element.NDS);
  DelSpace(Element.NDS);


  Format(Element.Litr,CLitr);
  DelSpace(Element.InPack);
  For c:=1 To CLitr Do If(Element.Litr[c]=' ') Then Element.Litr[c]:='0';

  If (Cod=kbGrayPlus)Or (Cod=kbAltF1) Then
  Begin
   s:=BazNum^.GetText(BazNum^.Focused,BazNum^.List^.Count);
   s:=Copy(s,1+1,CArtikul);
  end;

  {страховка на случай изменения}
  If Element.Main=1 Then
   Begin
    If StrToInt(GetIdField(FMain,Element.FantomKod))=1 Then
     Begin
      MessageBox(#3+'Указанная Вами главная позиция не может являться таковой! '+
	 'Измените код главной позиции!',nil,
	 mfError+mfCancelButton);
      Dispose(Control,Done);
      Dispose(NAmeWin,Done);
      Repeat
      Until (SetNAmeUnLock(Element.BazKod));
      Goto 1;
     End;
   End;


  {страховка на случай изменения}
  If Element.Main=1 Then
  If Cod=kbF4 Then
   Begin
    If StrToInt(Element.FantomKod)=StrToInt(Element.BazKod) Then
     Begin
      MessageBox(#3+'Позиция не может являться дочерней от самой себя!',nil,
	 mfError+mfCancelButton);
      Dispose(Control,Done);
      Dispose(NAmeWin,Done);
      Repeat
      Until (SetNAmeUnLock(Element.BazKod));
      Goto 1;
     End;
   End;

  {Если добавляем новое наименование то блокируем выбранный код}
  If (Cod=kbGrayPlus)Or (Cod=kbAltF1) Then
  Begin
   If Not(TestEmployNameAndLock(s,Oper)) Then
    Begin
     Beep;
     DInfoMsg('Позиция ['+s+'] используется'+Oper+'. Попробуйте изменить код!',False);
     Application^.ClearEvent(Event);
     Application^.ClearEvent(Event);
      repeat
       Application^.GetEvent(Event);
      until (Event.What <> evNothing);
     NoInfoMsg;
     Application^.ClearEvent(Event);
     Dispose(BazNum,Done);
     Dispose(Control,Done);
     Dispose(NameWin,Done);
     Goto 1;
    End;
  End;


  {исходим из того что блокировка удалась}
   UpStr(Element.Name);
   UpStr(Element.Name2);


   If Element.Market=0 Then
   Begin
   Element.NAme:=UpCases(Element.Name);
   Element.NAme2:=UpCases(Element.Name2);
   End;

   UpStr(Element.DSertif);

   Element.BazKod:=s;
   If Not(GetRazdelStatus(Element.BazKod)) Then
   Begin
    Element.DSertif:='01-01-20';
    Element.KSertif:=NoOrganStr;
   End
   Else
    Begin
    Element.EnableSklads:=1073741823;
    Element.Otdel:=17;{1 5}
    End;
   Element.Employ:=True;
   Element.Caption:=CurrentPassword;

   BazElement.BazKod:=Element.BazKod;
   new(skl,init);
   new(Kdx,init);
   Skl^.Dat.BazKod:=BazElement.BazKod;
   Kdx^.Dat.BazKod:=StrToInt(BazElement.BazKod);

   GetSkladRecord(Skl);
   GetSkladnewRecord(Kdx);

   BazElement:=Skl^.Dat;
   BKDX:=Kdx^.Dat;


   Dispose(Skl,Done);
   Dispose(Kdx,Done);

   BazElement.Input.Caption:=CurrentPassword;
   BazElement.DAte:=DateStringToDAte(DateMask,FDAte);
   BazELement.Employ:=True;
   BazElement.Locked:=False;
   BazElement.Time:=CurrentTime;
   BazElement.EnableDebit:=Element.EnableDebit;

If (Element.Main=0) Then
Element.FAntomKod:=Element.BazKod;

If (Cod=kbGrayPlus)Or (Cod=kbAltF1) Then
  Begin
   BazElement.BazKod :=BazElement.BazKod;
   BazElement.Input.NGTD:=NoNGTDStr;
   BazElement.Input.Godnost[0]:=#0;
   BazElement.Input.SpecMarka:=NoSpecMarkaStr;
   BazElement.Input.Marka:=NoMarkaStr;
   BazElement.Input.NSertif:=NoSertifStr;
   BazElement.Input.Virabotano[0]:=#0;
   BazElement.Input.RegionMarka:=0;
   BazElement.Input.Kol     :='0';
   BazElement.Input.KolR    :='0';

   For j:=1 To CDivision Do
   Begin
   BazElement.Input.Division[j]:='0';
   BazElement.Input.DivisionR[j]:='0';
   End;

   BazElement.Input.USD :=0;
   BazElement.Input.GRZena[0]:=#0;
   BazElement.Input.Zakupka :='0.0000';
   BazElement.Input.Zakupka2:='0.0000';
   BazElement.Input.R_Zena  :='0.00';
   BazElement.Input.O_Zena  :='0.00';
   BazElement.Input.NMAkeKod:=NoMakeKodStr;
   BazElement.Input.StrihKod[0] :=#0;


   bKdx.Name :=Element.Name;
   bKdx.Name2:=Element.Name2;
   bKdx.Virabotano :=0;
   bKdx.Employ :=True;
   bKdx.NSertif :=Glob.NoSertif;
   bkdx.Main:=Element.Main;
   Bkdx.NMakeKod:=0;
   {Bkdx.NGroupKod:=0;}
   bkdx.FantomKod:=StrToInt(Element.FantomKod);
   Bkdx.NGroupKod:=StrToInt(Element.NGroupKod);
   Bkdx.NGTDKod:=StrToInt(NoNGTDStr);
   Bkdx.NMarkaKod:=StrToInt(NoMarkaStr);
   Bkdx.NSpecMarkaKod:=StrToInt(NoSpecMarkaStr);
   Bkdx.NExpertKod:=StrToInt(NoExpertStr);
   Bkdx.FirmaPostKod:=StrToInt(Element.FirmaPostKod);
   For j:=1 To CDivision Do bKdx.Division[j]:=0;
   For j:=1 To CDivision Do bKdx.DivisionR[j]:=0;
   bKdx.R_Zena  :=0.00;
   bKdx.RegionMarka:=0;
   bKdx.BazKod:=StrToInt(BazElement.BazKod);
   bKdx.Kol:=0;
   bKdx.EnableSklads:=Element.EnableSklads;
   bkdx.AkzisSbor:=0;
   bkdx.Zakupka:=0;
   bkdx.Zakupka2:=0;
  End
  Else
   Begin
    bKdx.Name :=Element.Name;
    bKdx.Name2:=Element.Name2;
    bkdx.Main:=Element.Main;
    bkdx.FantomKod:=StrToInt(Element.FantomKod);
    bKdx.BazKod:=StrToInt(BazElement.BazKod);
    bKdx.EnableSklads:=Element.EnableSklads;
    Bkdx.FirmaPostKod:=StrToInt(Element.FirmaPostKod);
    Bkdx.NGroupKod:=StrToInt(Element.NGroupKod);
   End;


  {если не удалось записать информацию}
  If Not (WriteLockName(Element,BazElement,BKdx)) Then
    Begin
     If (Cod=kbGrayPlus)Or (Cod=kbAltF1) Then Dispose(BazNum,Done);
     Dispose(Control,Done);
     Dispose(NAmeWin,Done);
     Repeat
     Until (SetNAmeUnLock(Element.BazKod));
     Goto 1;
    End;

If NameWin^.FoundNoMain Then{начинаем править связанные дочерние позиции}
 Begin
   Element.Main:=1;
   Element.FantomKod:=Element.BazKod;

Restart:
  For Count:=0 To LockPosition^.List^.Count-1 Do
   Begin

   SArt:=Copy(LockPosition^.GetText(Count,LockPosition^.List^.Count),1+1,CArtikul);

   BakMarket:=GetIdMarket(SArt);
   BakDebit:=GetIdDebit(SArt);
   BakInPack:=GetIdField(FInPack,SArt);
   BakInPack2:=GetIdField(FInPack2,SArt);

   Element.BazKod:=SArt;

   If Not(GetRazdelStatus(Element.BazKod)) Then
   Begin
    Element.DSertif:='01-01-20';
    Element.KSertif:=NoOrganStr;
   End
    Else
    Begin
    Element.EnableSklads:=1073741823;
    Element.Otdel:=17;{1 5}
    End;


   Element.Employ:=True;
   Element.Caption:=CurrentPassword;
   Element.Market:=BakMarket;
   Element.InPack:=BakInPack;
   Element.InPack2:=BakInPack2;
   Element.EnableDebit:=BakDebit;

   BazElement.BazKod:=Element.BazKod;
   new(skl,init);
   new(Kdx,init);
   Skl^.Dat.BazKod:=BazElement.BazKod;
   Kdx^.Dat.BazKod:=StrToInt(BazElement.BazKod);

   GetSkladRecord(Skl);
   GetSkladnewRecord(Kdx);

   BazElement:=Skl^.Dat;
   BKDX:=Kdx^.Dat;


   Dispose(Skl,Done);
   Dispose(Kdx,Done);

   BazElement.Input.Caption:=CurrentPassword;
   BazElement.DAte:=DateStringToDAte(DateMask,FDAte);
   BazELement.Employ:=True;
   BazElement.Locked:=False;
   BazElement.Time:=CurrentTime;
   BazElement.EnableDebit:=Element.EnableDebit;

   bKdx.Name :=Element.Name;
   bKdx.Name2:=Element.Name2;
   bkdx.Main:=Element.Main;
   bkdx.FantomKod:=StrToInt(Element.FantomKod);
   bKdx.BazKod:=StrToInt(BazElement.BazKod);
   bKdx.EnableSklads:=Element.EnableSklads;
   Bkdx.FirmaPostKod:=StrToInt(Element.FirmaPostKod);
   Bkdx.NGroupKod:=StrToInt(Element.NGroupKod);

  If Not (WriteLockName(Element,BazElement,BKdx)) Then
    Begin
     DInfoMsg('Повторная попытка сохранить данные о товаре '+Element.BazKod,False);
     Goto Restart;
    End

   End;{For}

  For Count:=0 To LockPosition^.List^.Count-1 Do
   Begin
   SArt:=Copy(LockPosition^.GetText(Count,LockPosition^.List^.Count),1+1,CArtikul);
   Repeat
   Until (SetNAmeUnLock(SArt));
   AddProtocol('Связанная корректировка параметров наименования:'+Element.Name+' ('+sArt+')','','');
   End;


 End;{NameWin^.FoundNiMain}


If (Cod=kbGrayPlus)Or (Cod=kbAltF1) Then
  Begin
   s:=BazNum^.GetText(BazNum^.Focused,BazNum^.List^.Count);
   s:=Copy(s,1+1,CArtikul);
   AddProtocol('Добавление нового наименования:'+Element.Name+' ('+s+')','','');
   Repeat
   Until (SetNAmeUnLock(s));
  End
   Else
   AddProtocol('Корректировка параметров наименования:'+Element.Name+' ('+s+')','','');
   Res:=True;

   Element.BazKod:=s;
   BazElement.BazKod:=Element.BazKod;
   new(skl,init);
   Skl^.Dat.BazKod:=BazElement.BazKod;
   GetSkladRecord(Skl);
   BazElement:=Skl^.Dat;
   Dispose(Skl,Done);

   BazElement.Input.Caption:=CurrentPassword;
   BazElement.DAte:=DateStringToDAte(DateMask,FDAte);
   BazELement.Employ:=True;
   BazElement.Locked:=False;
   BazElement.Time:=CurrentTime;
   BazElement.EnableDebit:=Element.EnableDebit;

End
Else
 Begin
  If NameWin^.FoundNoMain Then{начинаем править связанные дочерние позиции}
   Begin
    For Count:=0 To LockPosition^.List^.Count-1 Do
     Begin
      SArt:=Copy(LockPosition^.GetText(Count,LockPosition^.List^.Count),1+1,CArtikul);
      Repeat
      Until (SetNAmeUnLock(SArt));
     End;
   End;{NameWin^.FoundNiMain}

 End;


RefreshCashOneRazdel(Element.BazKod);


If (Cod=kbGrayPlus)Or (Cod=kbAltF1) Then
  Begin
  BazNum^.NewList(Nil);
  Dispose(BazNum,Done);
  End;

  Dispose(Control,Done);
  Dispose(LockPosition,Done);
  Dispose(NameWin,Done);

end;



(*
Procedure TNameWindow.AddBazINI( Cod:Integer; st:ArtikulStr;Status : Boolean;Var Res:Boolean);
{параметр Status указывает на то что добавляется или редактируется
сертификат или другой товар }
Label 1;
var
  R : TRect;
  Control : PView;
  s,s1,mys : String;
  Oper : StrName;
  c: Word;
  j,k : Byte;
  skl : PSkladType;
  Regim : Boolean;
  Event : TEvent;
  EnL : Boolean;
  TovarCod : ArtikulStr;
  Test : LongInt;
  AddSertif : Boolean;
begin
Enl:=True;
ClearFind;
{If Cod=kbF4 Then}

{
If Not(Password(1)) Then
 Begin
  Res:=False;
  Exit;
 End;
}

{Res:=True;}

If Not(TestOpenDate1(FDate)) Then
   Begin
    MessageBox(#3^M+#3'Доступ к данным за '+FDate+' заблокирован!',Nil,mfError+mfCancelButton);
    Res:=False;
    Exit;
   End;

If Not(TestSetupKurs(FDate)) Then
   Begin
    MessageBox(#3^M+#3'Не установлен курс USD на '+FDate+'!',Nil,mfError+mfCancelButton);
    Res:=False;
    Exit;
        End;

Regim :=True;

If Not(Password(2)) Then
 Begin
  Regim:=False;
 End;

Res:=False;

If Cod=kbGrayPlus Then
MessageBox(^M+#3'Не забудьте согласовать код нового товара с центральным офисом !',Nil,mfWarning+mfCancelButton);

C:=IOResult;
Res:=False;
{s:=Baz^.GetText(Baz^.Focused,Baz^.List^.Limit);
s:=Copy(s,1+CName+1,CRazdelKod);}
AddSertif:=False;
If Status Then
Begin
AddSertif:=GetRazdelStatus(St);
s1:=st;
Assign(ElementFile,Path^.Dat.ToName+st+'.id');
Reset(ElementFile);
C:=IOResult;
If C<>0 Then
Begin
 MessageBox(^M+#3'Ошибка доступа к файлу '+st+'.id!',nil,mfError+mfCancelButton);
 Res:=False;
 Exit;
End;
AInfo('Читаю информацию о товарах...');
 Case Cod Of
  kbGrayPlus:Begin
     Element.Employ:=True;
     While Not(Eof(ElementFile)) And (Element.Employ) Do
     Begin

      ReadBaz(ElementFile,Element);
     End;
     If Eof(ElementFile) And (Element.Employ) Then
      Begin
       NoInfo;
       MessageBox(^M+#3'Свободных позиций для товара - нет !',nil,mfWarning+mfCancelButton);
                 System.Close(ElementFile);
       Res:=False;
       Exit;
      End;
      s:=Element.BazKod;

      Element.Name[0]:=#0;
      Element.Name2[0]:=#0;
      Element.Market:=0;
      Element.FullName[0]:=#0;
      Element.FullName2[0]:=#0;
      Element.Litr[0]:=#0;
      Element.InPack[0]:=#0;
      Element.OKP[0]:=#0;
      Element.Massa[0]:=#0;
      Element.Stat :=False;
      Element.Locked :=False;
      Element.Caption:=CurrentPassword;
      Element.VidNalog:=2;
      Element.Nalog:='0.00';
      Element.VidNDS:=0;
      Element.NDS:='20.00';
      Element.VidNDS:=0;
      Element.KSertif[0]:=#0;
      Element.DSertif[0]:=#0;

      If (GetRazdelLitr(s1)=0) Then
       Begin
        Enl:=False;
        Element.Litr:='0.000';
       End;

      If AddSertif Then
       Begin
        Enl:=False;
        Element.Market:=1;
        Element.Litr:='0.000';
        Element.InPack:='1';
        Element.KSertif[0]:=#0;
        Element.DSertif[0]:=#0;
       End;

{$IfDEF Tara}
      Element.FantomEnable:=0;
      Element.FantomKod[0]:=#0;
                Element.FantomInPack[0]:=#0;
{$EndIF}

      Element.NDS:='20.00';
      Element.Mera:=0;
      Element.Organization:=0;
      Element.EnableDebit:=1;

    End;
  kbF4:Begin
     s:=Copy(Baz^.GetText(Baz^.Focused,Baz^.List^.Count),1+CName+1,CArtikul);
     TovarCod:=S;
     Repeat
      ReadBaz(ElementFile,Element);
     Until (Eof(ElementFile)) Or (Element.BazKod=s);
     If Eof(ElementFile) And (Element.BazKod<>s) Then
      Begin
       NoInfo;
       MessageBox(^M+#3'Товар в базе не найден!',nil,mfError+mfCancelButton);
       System.Close(ElementFile);
       Res:=False;
       Exit;
      End;
      DelSpace(Element.Nalog);
      If (GetRazdelLitr(s1)=0) Then
       Begin
        Enl:=False;
       End;
    End;
  Else;
 End;
System.Close(ElementFile);
End
Else
 Begin
AddSertif:=True;
AInfo('Читаю информацию о товарах...');
 Case Cod Of
  kbGrayPlus:Begin
     Element.Employ:=True;
     For k:=0 To 99 Do
     Begin
      St:=IntToStr(k,CMAntissa);
      RFormatZerro(St,CMantissa);
      If GetRazdelStatus(st) Then
                 Begin
        Assign(ElementFile,Path^.Dat.ToName+st+'.id');
        C:=IOResult;
        Reset(ElementFile);
        C:=IOResult;
        If c=0 Then
         Begin
          Element.Employ:=True;
          While Not(Eof(ElementFile)) And (Element.Employ) Do
           Begin
            ReadBaz(ElementFile,Element);
           End;
          System.Close(ElementFile);
          If Not(Element.Employ) Then Break;
         End;{c=0}
       End;{GetRazdelStatus}
     End;{For}

      If Element.Employ Then
       Begin
        NoInfo;
        MessageBox(^M+#3'Свободных позиций для сертификатов - нет !',nil,mfWarning+mfCancelButton);
        Res:=False;
        Exit;
       End;

      s:=Element.BazKod;
      Element.Name[0]:=#0;
      Element.Name2[0]:=#0;
      Element.Market:=1;
      Element.FullName[0]:=#0;
      Element.FullName2[0]:=#0;
      Element.Litr[0]:=#0;
      Element.InPack:='1';
      Element.OKP[0]:=#0;
      Element.Massa[0]:=#0;
      Element.Stat :=False;
      Element.Locked :=False;
      Element.Caption:=CurrentPassword;
      Element.VidNalog:=2;
      Element.Nalog:='0.00';
      Element.VidNDS:=0;
      Element.NDS:='20.00';
      Element.VidNDS:=0;
      Element.KSertif[0]:=#0;
      Element.DSertif[0]:=#0;

      Enl:=False;
      Element.Litr:='0.000';

{$IfDEF Tara}
      Element.FantomEnable:=0;
      Element.FantomKod[0]:=#0;
      Element.FantomInPack[0]:=#0;
{$EndIF}

      Element.NDS:='20.00';
      Element.Mera:=0;
      Element.Organization:=0;
      Element.EnableDebit:=1;

    End;
  kbF4:Begin
        ToVarCod:=St;
        s:=St;
        s1:=Copy(st,1,CRazdelKod);
        Assign(ElementFile,Path^.Dat.ToName+s1+'.id');
        Reset(ElementFile);
        C:=IOResult;
        If C<>0 Then
        Begin
         NoInfo;
         MessageBox(^M+#3'Ошибка доступа к файлу '+s1+'.id!',nil,mfError+mfCancelButton);
         Res:=False;
         Exit;
        End;
     Repeat
      ReadBaz(ElementFile,Element);
     Until (Eof(ElementFile)) Or (Element.BazKod=st);

     If Eof(ElementFile) And (Element.BazKod<>st) Then
      Begin
       NoInfo;
       MessageBox(^M+#3'Товар в базе не найден!',nil,mfError+mfCancelButton);
       System.Close(ElementFile);
       Res:=False;
       Exit;
      End;
      System.Close(ElementFile);
      DelSpace(Element.Nalog);
                Enl:=False;
    End;
  Else;
 End;
End;


1:
If Cod=kbGrayPlus Then
Begin
{$IfDEF Tara}
R.Assign(12, 0, 67, 22);
{$Else}
{R.Assign(12, 2, 60, 21);}
R.Assign(8, 0, 72, 22);
{$EndIf}
New(NameWin, Init(R, 'Добавить наименование товара'))
End
Else
Begin
{$IfDEF Tara}
R.Assign(12, 0, 67, 17);
{$Else}
{R.Assign(12, 2, 60, 16);}
R.Assign(8, 0, 72, 17);
{$EndIf}
New(NameWin, Init(R, 'Изменить наименование товара'));
End;
NameWin^.Options := NameWin^.Options or ofCenterX or ofCenterY;
NameWin^.Palette := dpCyanDialog;
NameWin^.HelpCtx:=$E011;


R.Assign(1, 3, 29, 4);
ControlLine := New(PInputLine, Init(R, CName));
NameWin^.Insert(ControlLiNe);

  R.Assign(29, 3, 32, 4);
  If Status Then
  NameWin^.Insert(New(PHistory, Init(R, PInputline(ControlLine), 13)))
  Else
  NameWin^.Insert(New(PHistory, Init(R, PInputline(ControlLine), 14)));

  R.Assign(1, 2, 21, 3);
  NameWin^.Insert(New(PLabel, Init(R, 'Наи~м~еновние товара:', ControlLine)));


R.Assign(1, 4, 29, 5);
ControlLine2 := New(PInputLine, Init(R, CName));
NameWin^.Insert(ControlLiNe2);


If Cod=kbF4 Then
 Begin
  S:=TovarCod;
  R.Assign(1, 1, 12, 2);
  Control := New(PColoredText, Init(R, 'Код товара:', $3E));
  NameWin^.Insert(Control);

  R.Assign(12, 1, 17, 2);
  Control := New(PColoredText, Init(R, s, $3E));
  NameWin^.Insert(Control);
 End;



R.Assign(1, 6, 29, 7);
ControlName := New(PInputLine, Init(R, CName));
NameWin^.Insert(ControlName);

  R.Assign(29, 6, 32, 7);
  If Status Then
  NameWin^.Insert(New(PHistory, Init(R, PInputline(ControlName), 13)))
  Else
  NameWin^.Insert(New(PHistory, Init(R, PInputline(ControlName), 14)));

  R.Assign(1, 5, 22, 6);
  NameWin^.Insert(New(PLabel, Init(R, '~П~олное наименование:', ControlName)));

R.Assign(1, 7, 29, 8);
ControlName2 := New(PInputLine, Init(R, CName));
NameWin^.Insert(ControlName2);


{SFullName:=BazElement.Baz.FullName;

R.Assign(2, 5, 55, 6);
ControlT := New(PStaticText, Init(R, SFullName+' <- предлагаю'));
NameWin^.Insert(ControlT);}

R.Assign(32, 3, 39, 4);
Control := New(PRealInputLine, Init(R, CLitr));
NameWin^.Insert(Control);
If Not(ENl) Then
Control^.Options := Control^.Options and not ofSelectable;
  PInputLine(Control)^.Validator := New(PPXPictureValidator, Init('#.[#[#[#]]]', True));

  R.Assign(31, 2, 39, 3);
  NameWin^.Insert(New(PLabel, Init(R, '~Л~итраж:', Control)));

R.Assign(40, 3, 45, 4);
ControlInPack := New(PInputLine, Init(R, 3));
NameWin^.Insert(ControlInPack);
  PInputLine(ControlInPack)^.Validator := New(PRangeValidator, Init(1, 999));

  R.Assign(40, 2, 45, 3);
  NameWin^.Insert(New(PLabel, Init(R, '~Ф~ас:', ControlInPack)));


R.Assign(46, 3, 54, 4);
Control := New(PInputLine, Init(R, COKP));
NameWin^.Insert(Control);

  R.Assign(45, 2, 54, 3);
  NameWin^.Insert(New(PLabel, Init(R, 'Код ОК~П~:', Control)));

R.Assign(55, 3, 63, 4);
Control := New(PInputLine, Init(R, CMAssa));
NameWin^.Insert(Control);

  R.Assign(55, 2, 62, 3);
  NameWin^.Insert(New(PLabel, Init(R, 'Масс~а~:', Control)));


R.Assign(32, 5, 45, 6);
Control := New(PCheckboxes, Init(R,
  NewSItem('Про~д~ажа', Nil)));

If Not(Regim) Then
Control^.Options := Control^.Options and not ofSelectable;
NameWin^.Insert(Control);


R.Assign(46, 5, 63, 6);
Control := New(PCheckboxes, Init(R,
  NewSItem('~К~онсигнация', Nil)));
NameWin^.Insert(Control);




R.Assign(2, 9, 15, 14);
Control := New(PColoredText, Init(R, '', $3E));
Control^.Options := Control^.Options or ofFramed;
NameWin^.Insert(Control);


R.Assign(2, 9, 15, 12);
ControlVidNalog := New(PRadioButtons, Init(R,
  NewSItem('~И~мпорт',
  NewSItem('~О~теч.',
  NewSItem('Про~ч~ее', Nil)))));
NameWin^.Insert(ControlVidNalog);

  R.Assign(2, 8, 13, 9);
  NameWin^.Insert(New(PLabel, Init(R, 'Ставка НП:', ControlVidNalog)));


R.Assign(7, 13, 14, 14);
ControlNalog := New(PRealInputLine, Init(R, CLitr));
If Element.VidNAlog in [0,1] Then
  ControlNAlog^.Options := ControlNAlog^.Options and not ofSelectable
 Else
  ControlNAlog^.Options := ControlNAlog^.Options or ofSelectable;


NAmeWin^.Insert(ControlNalog);
{  PInputLine(ControlNalog)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));}

  R.Assign(2, 13, 7, 14);
  NameWin^.Insert(New(PLabel, Init(R, '~С~НП:', ControlNalog)));

R.Assign(16, 9, 29, 14);
Control := New(PStaticText, Init(R, ''));
Control^.Options := Control^.Options or ofFramed;
NameWin^.Insert(Control);

R.Assign(16, 9, 29, 12);
ControlVidNDS := New(PRadioButtons, Init(R,
  NewSItem('~2~0 %  ',
  NewSItem('~1~0 %   ',
  NewSItem('П~р~очее', 
  NewSItem('18 %', Nil)))));
NameWin^.Insert(ControlVidNDS);

  R.Assign(16, 8, 28, 9);
  NameWin^.Insert(New(PLabel, Init(R, 'Ставка НДС:', ControlVidNDS)));

R.Assign(21, 13, 28, 14);
ControlNDS := New(PRealInputLine, Init(R, CLitr));

If Element.VidNDS in [0,1,3] Then
  ControlNDS^.Options := ControlNDS^.Options and not ofSelectable
 Else
  ControlNDS^.Options := ControlNDS^.Options or ofSelectable;

NameWin^.Insert(ControlNDS);
{  PInputLine(ControlNDS)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));}

  R.Assign(16, 13, 21, 14);
  NameWin^.Insert(New(PLabel, Init(R, '~Н~ДС:', ControlNDS)));

R.Assign(30, 9, 38, 14);
Control := New(PStaticText, Init(R, ''));
Control^.Options := Control^.Options or ofFramed;
NameWin^.Insert(Control);

R.Assign(30, 9, 38, 14);
Control := New(PRadioButtons, Init(R,
  NewSItem('~Ш~т',
  NewSItem('К~г~',
  NewSItem('Мш',
  NewSItem('Л',
  NewSItem('Бл',
  Nil)))))));
NameWin^.Insert(Control);

  R.Assign(30, 8, 38, 9);
  NameWin^.Insert(New(PLabel, Init(R, 'Ед.изм:', Control)));

R.Assign(39, 9, 63, 11);
Control := New(PRadioButtons, Init(R,
  NewSItem('Хэппи',
  NewSItem('?',
  NewSItem('?', Nil)))));
NameWin^.Insert(Control);
PCluster(Control)^.SetButtonState($00000006, False);

  R.Assign(39, 8, 52, 9);
  NameWin^.Insert(New(PLabel, Init(R, 'Организация:', Control)));


{$IfDEF Tara}
R.Assign(40, 8, 53, 10);
Control := New(PColoredText, Init(R, '', $3E));
Control^.Options := Control^.Options or ofFramed;
NameWin^.Insert(Control);

R.Assign(40, 7, 53, 8);
ControlFantom := New(PCheckboxes, Init(R,
  NewSItem('См~е~жный', Nil)));
If Not(Regim) Then
ControlFantom^.Options := ControlFantom^.Options and not ofSelectable;
NameWin^.Insert(ControlFantom);

R.Assign(40, 9, 47, 10);
ControlFantomKod := New(PInputLine, Init(R, CArtikul));

If Element.FantomEnable=0 Then
ControlFantomKod^.Options := ControlFantomKod^.Options and not ofSelectable;

NameWin^.Insert(ControlFantomKod);
  PInputLine(ControlFantomKod)^.Validator := New(PPXPictureValidator, Init('[#####]', True));
{  PInputLine(ControlFantomKod)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0']));}

  R.Assign(40, 8, 45, 9);
  NameWin^.Insert(New(PLabel, Init(R, '~К~од:', ControlFantomKod)));

R.Assign(48, 9, 53, 10);
ControlFantomInPack := New(PInputLine, Init(R, CInPack));
If Element.FantomEnable=0 Then
ControlFantomInPack^.Options := ControlFantomInPack^.Options and not ofSelectable;

NameWin^.Insert(ControlFantomInPack);
  {PInputLine(ControlFantomInPack)^.Validator := New(PRangeValidator, Init(1, 999));}
  PInputLine(ControlFantomInPack)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0']));

  R.Assign(48, 8, 53, 9);
  NameWin^.Insert(New(PLabel, Init(R, 'Фа~с~:', ControlFantomInPack)));
{$EndIf}

If AddSertif Then
Begin
R.Assign(8, 15, 46, 16);
Control := New(PInputLine, Init(R, CKSertif));
{Control^.Options := Control^.Options and not ofSelectable;}
NameWin^.Insert(Control);

  R.Assign(46, 15, 49, 16);
  NameWin^.Insert(New(PHistory, Init(R, PInputline(Control), 100)));

  R.Assign(1, 15, 8, 16);
  NameWin^.Insert(New(PLabel, Init(R, '~В~ыдан:', Control)));

R.Assign(53, 15, 63, 16);
Control := New(PInputLine, Init(R, CDate));
{Control^.Options := Control^.Options and not ofSelectable;}
NameWin^.Insert(Control);
  PDateInputLine(Control)^.Validator := New(PPXPictureValidator, Init(DateFiltr, True));

  R.Assign(49, 15, 53, 16);
  NameWin^.Insert(New(PLabel, Init(R, 'До:', Control)));
End;

NameWin^.SetData(Element);



If Cod = kbGrayPlus  Then
Begin
If AddSertif Then  R.Assign(63, 17, 64, 21)
Else R.Assign(63, 16, 64, 21);
Control := New(PScrollBar, Init(R));
NameWin^.Insert(Control);

If AddSertif Then  R.Assign(1, 17, 63, 21)
Else R.Assign(1, 16, 63, 21);

BazNum := New(PBox, Init(R, 8, PScrollbar(Control)));

 BazNum^.NewList(New(PTextCollection, Init(0,1)));
If Status Then
Begin
 Assign (ElementFile,Path^.Dat.ToName+s1+'.id');
 Reset (ElementFile);
 While Not(Eof(ElementFile)) Do
  Begin
    ReadBaz(ElementFile,Element);
    If Not(Element.Employ) Then
     Begin
      Format (Element.BazKod,CArtikul);
      BazNum^.List^.Insert(NewStr('│'+Element.BazKod));
      BazNum^.SetRange(BazNum^.List^.Count);
     End;
  End;
 System.Close(ElementFile);
End
Else
Begin
 For k:=0 To 99 Do
  Begin
   St:=IntToStr(k,CMAntissa);
   RFormatZerro(St,CMantissa);
   If GetRazdelStatus(st) Then
       Begin
        Assign(ElementFile,Path^.Dat.ToName+st+'.id');
        C:=IOResult;
        Reset(ElementFile);
        C:=IOResult;
        If c=0 Then
         Begin
 While Not(Eof(ElementFile)) Do
  Begin
   ReadBaz(ElementFile,Element);
   If Not(Element.Employ) Then
   Begin
   Format (Element.BazKod,CArtikul);
   BazNum^.List^.Insert(NewStr('│'+Element.BazKod));
   BazNum^.SetRange(BazNum^.List^.Count);
   End;
  End;
   System.Close(ElementFile);

         End;{c=0}
       End;{GetRazdelStatus}
  End;{For}
End;{else}

 If Cod=kbF4 Then BazNum^.FocusItem(LoCation(BazNum,s,ProdagaWindow))
 Else BazNum^.FocusItem(0);
 BazNum^.HelpCtx:=$E011;

NameWin^.Insert(BazNum);

If AddSertif Then  R.Assign(1, 16, 63, 17)
Else R.Assign(1, 15, 63, 16);
 NameWin^.Insert(New(PLabel, Init(R, 'Доступные ~к~оды для наименования товара:', BazNum)));
End;

NameWin^.SelectNext(False);
Noinfo;
c:=Desktop^.ExecView(NameWin);
If c<>cmCancel Then
 Begin
  NameWin^.GetData(Element);
  DelSpaceRight(Element.Name);
  DelSpaceRight(Element.fullName);

  If AddSertif Then
  Begin
   DelSpaceRight(Element.KSertif);
   DelSpaceRight(Element.DSertif);
   ChekAddStr(Element.KSertif,0);
  End
   Else Begin
         Element.KSertif[0]:=#0;
         Element.DSertif[0]:=#0;
        End;

  If Element.Name[0]=#0 Then
   Begin
    MessageBox(^M+#3'Недопустимое наименование товара!',nil,mfError+mfCancelButton);
    If Cod=kbGrayPlus Then
      Begin
       BazNum^.NewList(Nil);
       Dispose(BazNum,Done);
      End;
    Dispose(Control,Done);
    Dispose(NameWin,Done);
    Goto 1;
   End;

If AddSertif Then
Begin
   If (Element.DSertif[0]<>#0) Then
   Begin
   If Not(TestDate(Element.DSertif,Test)) Then
    Begin
     MessageBox(^M+#3'Ошибка при вводе срока действия сертификата!',Nil,mfError+mfCancelButton);
     Goto 1;
    End;
   If Not(DateStringToDate(DateMask,Element.DSertif)>DateStringToDate(DateMask,FDate)) Then
    Begin
     MessageBox(^M+#3'Истек срок действия сертификата!',Nil,mfWarning+mfCancelButton);
    End;
   End
   Else
        MessageBox(^M+#3'Не указан срок действия сертификата!',Nil,mfError+mfCancelButton);
End;


  If Element.FullName[0]=#0 Then
   Begin
    MessageBox(^M+#3'Недопустимое полное наименование товара!',nil,mfError+mfCancelButton);
    If Cod=kbGrayPlus Then
     Begin
       BazNum^.NewList(Nil);
       Dispose(BazNum,Done);
      End;
      Dispose(Control,Done);
      Dispose(NameWin,Done);
      Goto 1;
     End;
  MyStr(StrToReal(Element.Litr),CKol,CLitrMantissa,Element.Litr);

  If (Element.Litr[0]=#0) Then
    Begin
      MessageBox(^M+#3'У товара не указан литраж!',nil,mfError+mfCancelButton);
       If Cod=kbGrayPlus Then
         Begin
          BazNum^.NewList(Nil);
          Dispose(BazNum,Done);
         End;
       Dispose(Control,Done);
       Dispose(NameWin,Done);
       Goto 1;
    End;

  If Status Then
  If ((StrToReal(Element.Litr)=0)And(GetRazdelLitr(s1)<>0))
  Or((StrToReal(Element.Litr)<>0)And(GetRazdelLitr(s1)=0)) Then
    Begin
      MessageBox(^M+#3'Настройки раздела не соответствуют литражу у наименования!',nil,mfError+mfCancelButton);
      If Cod=kbGrayPlus Then
        Begin
         BazNum^.NewList(Nil);
         Dispose(BazNum,Done);
        End;
      Dispose(Control,Done);
      Dispose(NameWin,Done);
      Goto 1;
    End;

  If Element.InPack[0]=#0 Then
    Begin
      MessageBox(^M+#3'У товара не указана фасовка!',nil,mfError+mfCancelButton);
      If Cod=kbGrayPlus Then
       Begin
         BazNum^.NewList(Nil);
         Dispose(BazNum,Done);
       End;
       Dispose(Control,Done);
       Dispose(NameWin,Done);
       Goto 1;
    End;


  {убрал 12.01.2000 т.к. все налоги у нас 0
  If (Element.Nalog[0]=#0) Or (StrTOReal(Element.Nalog)=0) Then
   Begin
      MessageBox(#3+NoNalog,nil,mfWarning+mfCancelButton);
   End;
  }
  If (StrTOReal(Element.Nalog)>99.99) Then
   Begin
      MessageBox(#3+ErrorNAlog,nil,mfError+mfCancelButton);
      If Cod=kbGrayPlus Then
       Begin
         BazNum^.NewList(Nil);
         Dispose(BazNum,Done);
       End;
       Dispose(Control,Done);
       Dispose(NameWin,Done);
       Goto 1;
   End;

{добавлено 15/03/2000 но временно выключенно
  If Element.OKP[0]=#0 Then
    Begin
      MessageBox(^M+#3'У товара не указан код ОКП!',nil,mfError+mfCancelButton);
    End;

  If StrToReal(Element.Massa)<0.0009 Then
    Begin
      MessageBox(^M+#3'У товара не указана масса!',nil,mfError+mfCancelButton);
    End;
}


  MyStr(StrToReal(Element.Massa),CMassa,CLitrMAntissa,Element.Massa);
  DelSpace(Element.Massa);
  MyStr(StrToReal(Element.Nalog),CLitr,CMantissa,Element.Nalog);
  DelSpace(Element.Nalog);

  If (Element.NDS[0]=#0) Or (StrTOReal(Element.NDS)=0) Then
   Begin
      MessageBox(#3+NoNDS,nil,mfError+mfCancelButton);
   End;

  If (StrTOReal(Element.NDS)>99.99) Then
   Begin
      MessageBox(#3+ErrorNDS,nil,mfError+mfCancelButton);
      If Cod=kbGrayPlus Then
       Begin
         BazNum^.NewList(Nil);
         Dispose(BazNum,Done);
       End;
       Dispose(Control,Done);
       Dispose(NameWin,Done);
       Goto 1;
   End;

  MyStr(StrToReal(Element.NDS),CLitr,CMantissa,Element.NDS);
  DelSpace(Element.NDS);

{$IfDEF Tara}
  if Element.FantomEnable=1 Then
  Begin
  If (Element.FantomKod[0]<>Chr(5)) Then
   Begin
      MessageBox(^M+#3+'Не указан код смежного наименования!',nil,mfError+mfCancelButton);
      If Cod=kbGrayPlus Then
       Begin
         BazNum^.NewList(Nil);
         Dispose(BazNum,Done);
       End;
       Dispose(Control,Done);
       Dispose(NameWin,Done);
       Goto 1;
   End;


  If (StrTOInt(Copy(Element.FantomKod,CRAzdelKod+1,CInPack))>=250) Then
   Begin
      MessageBox(^M+#3+'Недопустимый код смежного наименования!',nil,mfError+mfCancelButton);
      If Cod=kbGrayPlus Then
       Begin
         BazNum^.NewList(Nil);
         Dispose(BazNum,Done);
       End;
       Dispose(Control,Done);
       Dispose(NameWin,Done);
       Goto 1;
   End;

  If (StrTOInt(Copy(Element.FantomKod,1,CRazdelKod))>=26) Then
   Begin
      MessageBox(^M+#3+'Недопустимый код смежного наименования!',nil,mfError+mfCancelButton);
      If Cod=kbGrayPlus Then
       Begin
         BazNum^.NewList(Nil);
         Dispose(BazNum,Done);
       End;
       Dispose(Control,Done);
       Dispose(NameWin,Done);
       Goto 1;
   End;

  RFormatZerro(Element.FantomKod,CArtikul);

  If Not(GetIdEmploy(Element.FantomKod)) Then
   Begin
      MessageBox(#3+'Код смежного наименования '+Element.FantomKod+' не используется!'^M+
         #3+'Измените код смежного товара!',nil,mfError+mfCancelButton);
      If Cod=kbGrayPlus Then
       Begin
         BazNum^.NewList(Nil);
         Dispose(BazNum,Done);
       End;
       Dispose(Control,Done);
       Dispose(NameWin,Done);
       Goto 1;
   End;



  If Element.FantomInPack[0]=#0 Then
    Begin
      MessageBox(^M+#3'Не указана фасовка товара по отношению к смежному наименованию!',nil,mfError+mfCancelButton);
      If Cod=kbGrayPlus Then
       Begin
         BazNum^.NewList(Nil);
         Dispose(BazNum,Done);
       End;
       Dispose(Control,Done);
       Dispose(NameWin,Done);
       Goto 1;
    End;

  If StrToInt(Element.FantomInPack)=0 Then
    Begin
      MessageBox(^M+#3'Значение не находится в диапазоне 1..999!',nil,mfError+mfCancelButton);
      If Cod=kbGrayPlus Then
       Begin
         BazNum^.NewList(Nil);
         Dispose(BazNum,Done);
       End;
       Dispose(Control,Done);
       Dispose(NameWin,Done);
       Goto 1;
    End;
  End;
{$EndIf}

  Format(Element.Litr,CLitr);
  DelSpace(Element.InPack);
  For c:=1 To CLitr Do If(Element.Litr[c]=' ') Then Element.Litr[c]:='0';

  If Cod=kbGrayPlus Then
  Begin
   s:=BazNum^.GetText(BazNum^.Focused,BazNum^.List^.Count);
   s:=Copy(s,1+1,CArtikul);
  end;

  {Если добавляем новое наименование то блокируем выбранный код}
  If Cod=kbGrayPlus Then
  Begin
   If Not(TestEmployNameAndLock(s,Oper)) Then
    Begin
     Beep;
     DInfoMsg('Позиция ['+s+'] используется'+Oper+'. Попробуйте изменить код!',False);

     Application^.ClearEvent(Event);
     Application^.ClearEvent(Event);
      repeat
       Application^.GetEvent(Event);
      until (Event.What <> evNothing);
     NoInfoMsg;
     Application^.ClearEvent(Event);
     Dispose(BazNum,Done);
     Dispose(Control,Done);
     Dispose(NameWin,Done);
     Goto 1;
    End;
  End;


  {исходим из того что блокировка удалась}
   UpStr(Element.Name);
   UpStr(Element.FullName);
   UpStr(Element.Name2);
   UpStr(Element.FullName2);
   UpStr(Element.DSertif);
   UpStr(Element.KSertif);

   Element.BazKod:=s;
   If Not(GetRazdelStatus(Element.BazKod)) Then
   Begin
    Element.DSertif:='01-01-20';
    Element.KSertif:='НЕТ ДАННЫХ';
   End;
   Element.Employ:=True;
   Element.Stat  :=False;
   Element.Locked:=True;
   Element.Caption:=CurrentPassword;


   BazElement.BazKod:=Element.BazKod;
   new(skl,init);
   Skl^.Dat.BazKod:=BazElement.BazKod;

   GetSkladRecord(Skl);

   BazElement:=Skl^.Dat;
   Dispose(Skl,Done);

   BazElement.Input.Caption:=CurrentPassword;

If Cod=kbGrayPlus Then
  Begin
   BazElement.Input.Post[0] :=#0;

   BazElement.Input.NSertif:='85000';
   BazElement.Input.NGTD[0]:=#0;
   BazElement.Input.Virabotano[0]:=#0;
   BazElement.Input.Godnost[0]:=#0;
   BazElement.Input.Marka[0]:=#0;
   BazElement.Input.Akzis1[0] :=#0;
   BazElement.Input.Kol     :='0';
   For j:=1 To CDivision Do
   BazElement.Input.Division[j]:='0';
   BazElement.Input.Zakupka :='0.00';
   BazElement.Input.R_Zena  :='0.00';
   BazElement.Input.O_Zena  :='0.00';
  End;

   BazElement.DAte:=FDAte;
   BazELement.Employ:=True;
   BazElement.Locked:=False;
   BazElement.Time:=Times;
   BazElement.EnableDebit:=Element.EnableDebit;


  {если не удалось записать информацию}
  If Not (WriteLockName(Element,BazElement)) Then
    Begin
     If Cod=kbGrayPlus Then Dispose(BazNum,Done);
     Dispose(Control,Done);
     Dispose(NAmeWin,Done);
     Repeat
     Until (SetNAmeUnLock(s));
     Goto 1;
    End;



If Cod=kbGrayPlus Then
  Begin
   s:=BazNum^.GetText(BazNum^.Focused,BazNum^.List^.Count);
   s:=Copy(s,1+1,CArtikul);
   AddProtocol('Добавление нового наименования:'+Element.Name+' ('+s+')','','');
   Repeat
   Until (SetNAmeUnLock(s));
  End
   Else
   AddProtocol('Корректировка параметров наименования:'+Element.Name+' ('+s+')','','');
   Res:=True;

End;

If Cod=kbGrayPlus Then
  Begin
  BazNum^.NewList(Nil);
  Dispose(BazNum,Done);
  End;

  Dispose(Control,Done);
  Dispose(NameWin,Done);
end;
*)


Destructor TNameWinDow.Done;
Begin
ClearFind;
If NameWin^.AddSert Then
 Begin
  Dispose(ControlKSertif,Done);
  Dispose(ControlKSertifS,Done);
 End;

Dispose(ControlBuch,Done);
Dispose(ControlMain,Done);
Dispose(ControlMainName,Done);
Dispose(ControlMainNameS,Done);
Dispose(ControlVidNalog,Done);
Dispose(ControlNalog,Done);
Dispose(ControlVidNDS,Done);
Dispose(ControlNDS,Done);
Dispose(ControlInPack,Done);
Dispose(ControlInPack2,Done);
Dispose(ControlLine,Done);
{Dispose(ControlSkladFiltr,Done);}
Dispose(PMyListBox(ControlSkladFiltr)^.List,Done);
Dispose(ControlLitr,Done);
Dispose(ControlMera,Done);
Dispose(ControlMeraS,Done);
Dispose(ControlOtdel,Done);
Dispose(ControlMarker,Done);
Dispose(ControlMin,Done);
Dispose(ControlClass,Done);
Dispose(ControlClassS,Done);
Dispose(ControlLand,Done);
Dispose(ControlLandS,Done);
Dispose(ControlGroup,Done);
Dispose(ControlGroupS,Done);
Dispose(ControlFirmaPost,Done);
Dispose(ControlFirmaPostS,Done);

Dispose(ControlEtil,Done);
Dispose(ControlMassa,Done);
Dispose(ControlOKP,Done);
Dispose(ControlMrk,Done);
Dispose(ControlPrh,Done);
Dispose(ControlConsig,Done);

{Dispose(ControlName,Done);}
Dispose(ControlContract,Done);
Dispose(ControlContractNumer,Done);
Dispose(ControlContractDate,Done);
{Dispose(ControlT,Done);}
TDialog.Done;
End;


Procedure TNameWinDow.SetStatus;
Begin

If Element.Main=1 Then
Begin
 ControlLine^.Options := ControlLine^.Options and not ofSelectable;
 ControlLine2^.Options := ControlLine2^.Options and not ofSelectable;

 { потому что бываю позиции одинаковые но с разной фасовкой
   по просьбе девок 16/03/2004
 ControlInPack^.Options := ControlInPack^.Options and not ofSelectable;
 ControlInPack2^.Options := ControlInPack2^.Options and not ofSelectable;}

 ControlLitr^.Options := ControlLitr^.Options and not ofSelectable;
 ControlOkp^.Options := ControlOkp^.Options and not ofSelectable;
 ControlMassa^.Options := ControlMassa^.Options and not ofSelectable;
 ControlEtil^.Options := ControlEtil^.Options and not ofSelectable;
 ControlBuch^.Options := ControlBuch^.Options and not ofSelectable;
 ControlVidNDS^.Options := ControlVidNDS^.Options and not ofSelectable;
 ControlNDS^.Options := ControlNDS^.Options and not ofSelectable;
 ControlVidNalog^.Options := ControlVidNalog^.Options and not ofSelectable;
 ControlNalog^.Options := ControlNalog^.Options and not ofSelectable;
 ControlPrh^.Options := ControlPrh^.Options and not ofSelectable;
 ControlContract^.Options := ControlContract^.Options and not ofSelectable;
 ControlContractNumer^.Options := ControlContractNumer^.Options and not ofSelectable;
 ControlContractDate^.Options := ControlContractDate^.Options and not ofSelectable;
 ControlMera^.Options := ControlMera^.Options and not ofSelectable;
 ControlLand^.Options := ControlLand^.Options and not ofSelectable;
 ControlFirmaPost^.Options := ControlFirmaPost^.Options and not ofSelectable;
 ControlClass^.Options := ControlClass^.Options and not ofSelectable;
 ControlGroup^.Options := ControlGroup^.Options and not ofSelectable;
 ControlSkladFiltr^.Options := ControlSkladFiltr^.Options and not ofSelectable;
 ControlOtdel^.Options := ControlOtdel^.Options and not ofSelectable;
 ControlMarker^.Options := ControlMarker^.Options and not ofSelectable;
 ControlMin^.Options := ControlMin^.Options and not ofSelectable;
End
 Else
  Begin

 ControlLine^.Options := ControlLine^.Options or ofSelectable;
 If Not(NameWin^.SEnableName) Then
ControlLine^.Options := ControlLine^.Options and not ofSelectable;

 ControlLine2^.Options := ControlLine2^.Options or ofSelectable;
 If Not(NameWin^.SEnableName) Then
ControlLine2^.Options := ControlLine2^.Options and not ofSelectable;

 ControlLitr^.Options := ControlLitr^.Options or ofSelectable;
If Not(NameWin^.SENl) Then
ControlLitr^.Options := ControlLitr^.Options and not ofSelectable;
{
If Not NameWin^.SRegim Then
ControlLitr^.Options := ControlLitr^.Options and not ofSelectable;
}
 ControlInPack^.Options := ControlInPack^.Options or ofSelectable;
{
If Not NameWin^.SRegim Then
ControlInPack^.Options := ControlInPack^.Options and not ofSelectable;
}
 ControlInPack2^.Options := ControlInPack2^.Options or ofSelectable;
{
If Not NameWin^.SRegim Then
ControlInPack2^.Options := ControlInPack2^.Options and not ofSelectable;
}
 ControlOkp^.Options := ControlOkp^.Options or ofSelectable;
{
If Not NameWin^.SRegim Then
ControlOKP^.Options := ControlOKP^.Options and not ofSelectable;
}
 ControlMassa^.Options := ControlMassa^.Options or ofSelectable;
{
If Not NameWin^.SRegim Then
ControlMassa^.Options := ControlMassa^.Options and not ofSelectable;
}
 ControlEtil^.Options := ControlEtil^.Options or ofSelectable;
If {Not(Namewin^.SRegim) Or} (EnableZakupka=0) Or (Pharm=1) Then
ControlEtil^.Options := ControlEtil^.Options and not ofSelectable;
ControlEtil^.Options := ControlEtil^.Options and not ofFirstClick;

 ControlBuch^.Options := ControlBuch^.Options or ofSelectable;
If {Not(Namewin^.SRegim) Or} (EnableZakupka=0) Or (Pharm=1) Then
ControlBuch^.Options := ControlBuch^.Options and not ofSelectable;
ControlBuch^.Options := ControlBuch^.Options and not ofFirstClick;

ControlMrk^.Options := ControlMrk^.Options Or ofSelectable;
If Not(NameWin^.SRegim) Or Not(NameWin^.SStatus) Then
ControlMrk^.Options := ControlMrk^.Options and not ofSelectable;

ControlPrh^.Options := ControlPrh^.Options Or ofSelectable;
If Not(NameWin^.SRegim) Or Not(NameWin^.SStatus) Then
ControlPrh^.Options := ControlPrh^.Options and not ofSelectable;

ControlConsig^.Options := ControlConsig^.Options Or ofSelectable;
If Not(NameWin^.SRegim) Or Not(NameWin^.SStatus) Then
ControlConsig^.Options := ControlConsig^.Options and not ofSelectable;

 ControlVidNDS^.Options := ControlVidNDS^.Options or ofSelectable;
If Not(NameWin^.SStatus) {Or NameWin^.AddSert} Then
ControlVidNDS^.Options := ControlVidNDS^.Options and not ofSelectable;

 ControlNDS^.Options := ControlNDS^.Options or ofSelectable;
If Element.VidNDS in [0,1,3] Then
  ControlNDS^.Options := ControlNDS^.Options and not ofSelectable
 Else
  ControlNDS^.Options := ControlNDS^.Options or ofSelectable;

If Not NameWin^.SStatus Then
ControlNDS^.Options := ControlNDS^.Options and not ofSelectable;

 ControlVidNalog^.Options := ControlVidNalog^.Options or ofSelectable;
If Not(NameWin^.SStatus) {Or NameWin^.AddSert} Then
ControlVidNalog^.Options := ControlVidNalog^.Options and not ofSelectable;

 ControlNalog^.Options := ControlNalog^.Options or ofSelectable;
If Element.VidNAlog in [0,1] Then
  ControlNAlog^.Options := ControlNAlog^.Options and not ofSelectable
 Else
  ControlNAlog^.Options := ControlNAlog^.Options or ofSelectable;

If Not NameWin^.SStatus Then
ControlNalog^.Options := ControlNalog^.Options and not ofSelectable;

 ControlContract^.Options := ControlContract^.Options or ofSelectable;
If NameWin^.AddSert Then
ControlContract^.Options := ControlContract^.Options and not ofSelectable;

 ControlContractNumer^.Options := ControlContractNumer^.Options or ofSelectable;
If Not(Element.EnableContract=1) Then
ControlContractNumer^.Options := ControlContractNumer^.Options and not ofSelectable;

 ControlContractDate^.Options := ControlContractDate^.Options or ofSelectable;
If Not(Element.EnableContract=1) Then
ControlContractDate^.Options := ControlContractDate^.Options and not ofSelectable;

 ControlMera^.Options := ControlMera^.Options or ofSelectable;
If {(Not NameWin^.SStatus)  Or NameWin^.AddSert Or} (Element.Main=1)Then
ControlMera^.Options := ControlMera^.Options and not ofSelectable;


 ControlLand^.Options := ControlLand^.Options or ofSelectable;
If (Not NameWin^.SStatus)  Or NameWin^.AddSert  Or (Element.Main=1)Then
ControlLand^.Options := ControlLand^.Options and not ofSelectable;

 ControlFirmaPost^.Options := ControlFirmaPost^.Options or ofSelectable;
If (Not NameWin^.SStatus)  Or NameWin^.AddSert  Or (Element.Main=1)Then
ControlFirmaPost^.Options := ControlFirmaPost^.Options and not ofSelectable;

 ControlClass^.Options := ControlClass^.Options or ofSelectable;
If (Not NameWin^.SStatus)  Or NameWin^.AddSert  Or (Element.Main=1)Then
ControlClass^.Options := ControlClass^.Options and not ofSelectable;

 ControlGroup^.Options := ControlGroup^.Options or ofSelectable;
If (Not NameWin^.SStatus)  Or NameWin^.AddSert  Or (Element.Main=1)Then
ControlGroup^.Options := ControlGroup^.Options and not ofSelectable;
  End;



ControlMain^.Options := ControlMain^.Options or ofSelectable;
If (Not(NameWin^.SEnableName) {Or Not(NameWin^.SRegim)} Or Not(NameWin^.SStatus)) Or
(NameWin^.AddSert) Or (NameWin^.FoundNoMain)
Or ((NameWin^.EditNoMain) And (StrToInt(CurrentPassword)<>0))Then
ControlMain^.Options := ControlMain^.Options and not ofSelectable;


ControlMainName^.Options := ControlMainName^.Options or ofSelectable;
If (Not(NameWin^.SEnableName) {Or Not(NameWin^.SRegim)} Or Not(NameWin^.SStatus)) Or (NameWin^.AddSert)
Or (Element.MAin=0) Or (NameWin^.FoundNoMain)
Or ((NameWin^.EditNoMain) And (StrToInt(CurrentPassword)<>0))Then
ControlMainName^.Options := ControlMainName^.Options and not ofSelectable;
ControlMainName^.Options := ControlMainName^.Options and not ofFirstClick;

{
Writeln(NameWin^.SEnableName,' ',NameWin^.SRegim,' ',NameWin^.SStatus,' ',NameWin^.AddSert,' ',Element.Main);
Readln;
}

ControlSkladFiltr^.Options := ControlSkladFiltr^.Options or ofSelectable;
If (Not NameWin^.SStatus) Or (EnableZakupka=0) Or (Pharm=1) Or (Element.Main=1) or (NameWin^.Addsert) Then
ControlSkladFiltr^.Options := ControlSkladFiltr^.Options and not ofSelectable;

ControlOtdel^.Options := ControlOtdel^.Options or ofSelectable;
If (Not NameWin^.SStatus) Or (EnableZakupka=0) Or (Element.Main=1) or (NameWin^.Addsert) Then
ControlOtdel^.Options := ControlOtdel^.Options and not ofSelectable;

ControlMarker^.Options := ControlMarker^.Options or ofSelectable;
If (Not NameWin^.SStatus) Or (EnableZakupka=0) Or (Element.Main=1) or (NameWin^.Addsert) Then
ControlMarker^.Options := ControlMarker^.Options and not ofSelectable;

ControlMin^.Options := ControlMin^.Options or ofSelectable;
If (Not NameWin^.SStatus) Or (EnableZakupka=0) Or (Element.Main=1) or (NameWin^.Addsert) Then
ControlMin^.Options := ControlMin^.Options and not ofSelectable;


{$IFDEF PHARM}
If (NameWin^.SENableName) And (NameWin^.SStatus) And Not(NameWin^.AddSert) And Not(NameWin^.FoundNoMain) Then
ControlMain^.Options := ControlMainName^.Options Or ofSelectable;
If (NameWin^.SENableName) And (NameWin^.SStatus) And Not(NameWin^.AddSert) And Not(NameWin^.FoundNoMain) Then
ControlMainName^.Options := ControlMainName^.Options Or ofSelectable;
{$ENDIF}


Redraw;

End;



procedure TNameWindow.HandleEvent(var Event: TEvent);
Label Start;
Var f,l,r : Boolean;
    Test : Word;
    ss,s : ArtikulStr;
    sss : String;
    Ckod : String[cclientkod];
    NewElement : PBazType;
    Lz : LongInt;
    st : String;
    LL : Word;
 Begin
{
  If (Event.What=EvKeyDown) And
  (( ControlLine^.State and sfFocused <> 0)) And
  (Event.KeyCode<>kbTab) And
  (Event.KeyCode<>kbEnter) And
  (Event.KeyCode<>kbShiftTab) And
  (Event.KeyCode<>kbCtrlLeft) And
  (Event.KeyCode<>kbLeft) And
  (Event.KeyCode<>kbRight) And
  (Event.KeyCode<>kbHome) And
  (Event.KeyCode<>kbEnd) And
  (Event.KeyCode<>kbCtrlRight) Then L:=True
  Else L:=False;

  If (Event.What=EvKeyDown) And
  (( ControlLine2^.State and sfFocused <> 0)) And
  (Event.KeyCode<>kbTab) And
  (Event.KeyCode<>kbEnter) And
  (Event.KeyCode<>kbShiftTab) And
  (Event.KeyCode<>kbCtrlLeft) And
  (Event.KeyCode<>kbLeft) And
  (Event.KeyCode<>kbRight) And
  (Event.KeyCode<>kbHome) And
  (Event.KeyCode<>kbEnd) And
  (Event.KeyCode<>kbCtrlRight) Then r:=True
  Else r:=False;
}


  Case Event.What Of
  evCommand: Begin
              CAse Event.Command Of
          cmSelectBuchGroup : Begin
                               ControlBuch^.GetData(LZ);
                               SelAkz^.SelectVidAkzis(Lz,LL);
                               Case LL Of
                               2   :Begin
                                     ControlBuch^.SetDAta(Lz);
                                     FocusNext(False);
                                     ClearEvent(Event);
                                     Redraw;
                                    End;
                               3   :Begin
                                     ControlBuch^.SetDAta(Lz);
                                     FocusNext(True);
                                     ClearEvent(Event);
                                     Redraw;
                                    End;
                               0,1:Begin
                                     FocusNext(True);
                                     ClearEvent(Event);
                                     Redraw;
                                    End;
                                  Else;
                                  End;
                               ClearEvent(Event);
                              End;

          cmSelectGroup : Begin

     PStaticText(ControlGroups)^.GetText(St);
     ControlGroup^.GetData(ckod);
     System.Delete(St,1,1);
     st:=st+ckod;
     GroupWin^.ShowGroupList(st,Test);
     ckod:=Copy(st,Pos('│',st)+1,CClientKod);
     Element.NGroupKod:=ckod;
     ControlGroup^.SetData(Element.NGroupKod);
     st[0]:=Chr(Pos('│',st));
     PStaticText(ControlGroups)^.Text^:=' '+St;
     NameWin^.SetStatus;

     Case Test Of
      0,3 :FocusNext(True);
      1,2 :FocusNext(False);
     Else;
          End;

     Redraw;

     ClearEvent(Event);
                          End;

          cmSelectMera : Begin

     PStaticText(ControlMeras)^.GetText(St);
     ControlMera^.GetData(ckod);
     System.Delete(St,1,1);
     st:=st+ckod;
     MeraWin^.ShowMeraList(st,Test);
     ckod:=Copy(st,Pos('│',st)+1,CClientKod);
     Element.Mera:=ckod;
     ControlMera^.SetData(Element.Mera);
     st[0]:=Chr(Pos('│',st));
     PStaticText(ControlMeraS)^.Text^:=' '+St;
     NameWin^.SetStatus;

     Case Test Of
      0,3 :FocusNext(True);
      1,2 :FocusNext(False);
     Else;
          End;

     Redraw;

     ClearEvent(Event);
                          End;

          cmSelectKSertif : Begin

     PStaticText(ControlKSertifs)^.GetText(St);
     ControlKSertif^.GetData(ckod);
     System.Delete(St,1,1);
     st:=st+ckod;
     KSertifWin^.ShowKSertifList(st,Test);
     ckod:=Copy(st,Pos('│',st)+1,CClientKod);
     Element.KSertif:=ckod;
     ControlKSertif^.SetData(Element.KSertif);
     st[0]:=Chr(Pos('│',st));
     PStaticText(ControlKSertifS)^.Text^:=' '+St;
     NameWin^.SetStatus;

     Case Test Of
      0,3 :FocusNext(True);
      1,2 :FocusNext(False);
     Else;
          End;

     Redraw;

     ClearEvent(Event);
                          End;

          cmSelectPost : Begin

     PStaticText(ControlLands)^.GetText(St);
     ControlLand^.GetData(ckod);
     System.Delete(St,1,1);
     st:=st+ckod;
     PostWin^.ShowPostList(st,Test);
     ckod:=Copy(st,Pos('│',st)+1,CClientKod);
     Element.PostKod:=ckod;
     ControlLand^.SetData(Element.PostKod);
     st[0]:=Chr(Pos('│',st));
     PStaticText(ControlLands)^.Text^:=' '+St;
     NameWin^.SetStatus;

     Case Test Of
      0,3 :FocusNext(True);
      1,2 :FocusNext(False);
     Else;
          End;

     Redraw;

     ClearEvent(Event);
                          End;

     cmSelectFirmaPost : Begin

     PStaticText(ControlFirmaPosts)^.GetText(St);
     ControlFirmaPost^.GetData(ckod);
     System.Delete(St,1,1);
     st:=st+ckod;
     FirmaPostWin^.ShowFirmaPostList(st,Test);
     ckod:=Copy(st,Pos('│',st)+1,CClientKod);
     Element.FirmaPostKod:=ckod;
     ControlFirmaPost^.SetData(Element.FirmaPostKod);
     st[0]:=Chr(Pos('│',st));
     PStaticText(ControlFirmaPosts)^.Text^:=' '+St;
     NameWin^.SetStatus;

     Case Test Of
      0,3 :FocusNext(True);
      1,2 :FocusNext(False);
     Else;
          End;

     Redraw;

     ClearEvent(Event);
                          End;

     cmSelectClass     : Begin
     PStaticText(ControlClassS)^.GetText(St);
     ControlClass^.GetData(ckod);
     System.Delete(St,1,1);
     st:=st+ckod;
     ClassWin^.ShowClassList(st,Test);
     ckod:=Copy(st,Pos('│',st)+1,CClientKod);
     Element.Class:=ckod;
     ControlClass^.SetData(Element.Class);
     st[0]:=Chr(Pos('│',st));
     Format(st,CNAme);
     St:=St+'│';
     PStaticText(ControlClassS)^.Text^:=' '+St;
     NameWin^.SetStatus;
     Case Test Of
      0,3 :FocusNext(True);
      1,2 :FocusNext(False);
     Else;
          End;

     Redraw;

     ClearEvent(Event);
	                     End;


              cmSelectMainName : Begin
                               PStaticText(ControlMainNameS)^.GetText(St);
                               ControlMainName^.GetData(ss);
                               st:=st+ss;
Start:
                               SelMain^.ShowMainNameList(NameWin^.RKod,st,LL);
                               ClearEvent(Event);
                               Case LL Of
                               2,3 :Begin
                                     New(NewElement,Init);
                                     ss:=Copy(st,Pos('│',st)+1,CArtikul);
                                     NewElement^.Dat.BazKod:=ss;
                                     If GetBazElement(ss,NewElement^.Dat) Then
                                      Begin
                                       Element.FantomKod:=ss;
                                       Element.Name:=NewElement^.Dat.Name;
                                       Element.Name2:=NewElement^.Dat.Name2;
                                       Element.InPack:=NewElement^.Dat.InPack;
                                       Element.InPack2:=NewElement^.Dat.InPack2;
                                       Element.Litr:=NewElement^.Dat.Litr;
                                       Element.Massa:=NewElement^.Dat.Massa;
                                       Element.Okp:=NewElement^.Dat.Okp;
                                       Element.BuchGroup:=NewElement^.Dat.BuchGroup;
                                       Element.Etil:=NewElement^.Dat.Etil;
                                       Element.VidNalog:=NewElement^.Dat.VidNalog;
                                       Element.Nalog:=NewElement^.Dat.Nalog;
                                       Element.Prihod:=NewElement^.Dat.Prihod;
                                       Element.VidNDS:=NewElement^.Dat.VidNDS;
                                       Element.NDS:=NewElement^.Dat.NDS;
                                       Element.Mera:=NewElement^.Dat.Mera;
                                       Element.PostKod:=NewElement^.Dat.PostKod;
                                       Element.FirmaPostKod:=NewElement^.Dat.FirmaPostKod;
                                       Element.NGroupKod:=NewElement^.Dat.NGroupKod;
                                       Element.EnableContract:=NewElement^.Dat.EnableContract;
                                       Element.Contract:=NewElement^.Dat.Contract;
                                       Element.ContractDate:=NewElement^.Dat.ContractDate;
                                       Element.Class:=NewElement^.Dat.Class;

                                       Element.EnableSklads:=NewElement^.Dat.EnableSklads;
                                       Element.Otdel:=NewElement^.Dat.Otdel;
                                       Element.Marker:=NewElement^.Dat.Marker;
                                       Element.Min:=NewElement^.Dat.Min;

                                       ControlMainName^.SetDAta(Element.FantomKod);
                                       ControlLine^.SetDAta(Element.Name);
                                       ControlLine2^.SetDAta(Element.Name2);
                                       ControlInPack^.SetDAta(Element.InPack);
                                       ControlInPack2^.SetDAta(Element.InPack2);
                                       ControlLitr^.SetDAta(Element.Litr);
                                       ControlMassa^.SetDAta(Element.Massa);
                                       ControlOkp^.SetDAta(Element.Okp);
                                       ControlBuch^.SetDAta(Element.BuchGroup);
                                       ControlEtil^.SetDAta(Element.Etil);
                                       ControlPrh^.SetDAta(Element.Prihod);
                                       ControlVidNalog^.SetDAta(Element.VidNalog);
                                       ControlNalog^.SetDAta(Element.Nalog);
                                       ControlVidNDS^.SetDAta(Element.VidNDS);
                                       ControlNDS^.SetDAta(Element.NDS);
                                       ControlMera^.SetDAta(Element.Mera);
                                       ControlClass^.SetDAta(Element.Class);
                                       ControlLand^.SetDAta(Element.PostKod);
                                       ControlFirmaPost^.SetDAta(Element.FirmaPostKod);
                                       ControlGroup^.SetDAta(Element.NGroupKod);
                                       ControlContract^.SetDAta(Element.EnableContract);
                                       ControlContractNumer^.SetDAta(Element.Contract);
                                       ControlContractDate^.SetDAta(Element.ContractDate);

                                       ControlSkladFiltr^.SetData(Element.EnableSklads);
                                       ControlOtdel^.SetData(Element.Otdel);
                                       ControlMarker^.SetData(Element.Marker);
                                       ControlMin^.SetData(Element.Min);


RFormatZerro(Element.PostKod,CClientKod);
sss:=GetPostField(FPost,Element.PostKod);
Format(sss,CPost);
     PStaticText(ControlLands)^.Text^:=' '+sss+'│';

RFormatZerro(Element.Mera,CClientKod);
sss:=GetMeraField(FMera,Element.Mera);
Format(sss,CMera);
     PStaticText(ControlMeraS)^.Text^:=' '+sss+'│';

RFormatZerro(Element.NGroupKod,CClientKod);
sss:=GetGroupField(FClient,Element.NGroupKod);
Format(sss,CName);
     PStaticText(ControlGroups)^.Text^:=' '+sss+'│';

RFormatZerro(Element.Class,CClientKod);
sss:=GetClassField(FClass,Element.Class);
Format(sss,CName);
     PStaticText(ControlClassS)^.Text^:=' '+sss+'│';

RFormatZerro(Element.FirmaPostKod,CClientKod);
sss:=GetFirmaPostField(FFirmaPost,Element.FirmaPostKod);
Format(sss,CFirmaPost);
     PStaticText(ControlFirmaPosts)^.Text^:=' '+sss+'│';
                                       Dispose(NewElement,Done);
                                      End
                                      Else
							    Begin
                                        Dispose(NewElement,Done);
							     Goto Start;
                                       End;
                                     NameWin^.SetStatus;
                                     st[0]:=Chr(Pos('│',st));

                                     PStaticText(ControlMainNames)^.Text^:=' '+St;
                                     FocusNext(False);
                                     ClearEvent(Event);
                                    End;
                               0,1:Begin
              {
		     Element.Main:=0;
               ControlMain^.SetData(Element.Main);
               ControlMainName^.Options := ControlMainName^.Options and not ofSelectable;
		    }
                                     NameWin^.SetStatus;
                                     FocusNext(True);
                                     ClearEvent(Event);
                                    End;
                                  Else;
                                  End;
                               Redraw;
                               ClearEvent(Event);
                              End;
              Else;
              End;
             End;

  Else;
  End;

  inherited HandleEvent(Event);

  If (ControlVidNalog^.State and sfFocused <> 0) Then
   Begin
    ControlVidNalog^.GetData(Test);
    If Test<>Element.VidNalog Then
    Begin
    Element.VidNalog:=Test;
    Case Test Of
    0,1:Begin
       If Test=0 Then s:='5.00' Else s:='3.00';
       ControlNalog^.Setdata(s);
       ControlNAlog^.Options := ControlNAlog^.Options and not ofSelectable;
       Redraw;
      End;
    2:Begin
       ControlNAlog^.Options := ControlNAlog^.Options Or ofSelectable;
       Redraw;
      End;
    Else;
    End;
    End;
   End;

  If (ControlVidNDS^.State and sfFocused <> 0) Then
   Begin
    ControlVidNDS^.GetData(Test);
    If Test<>Element.VidNDS Then
    Begin
    Element.VidNDS:=Test;
    Case Test Of
    0,1,3:Begin
       If Test=0 Then s:='20.00' Else If Test=1 Then s:='10.00' Else s:='18.00';
       ControlNDS^.Setdata(s);
       ControlNDS^.Options := ControlNDS^.Options and not ofSelectable;
       Redraw;
      End;
    2:Begin
       ControlNDS^.Options := ControlNDS^.Options Or ofSelectable;
       Redraw;
      End;
    Else;
    End;
    End;
   End;

  If (ControlContract^.State and sfFocused <> 0) Then
   Begin
    ControlContract^.GetData(Test);
    If Test<>Element.EnableContract Then
    Begin
    Element.EnableContract:=Test;
    Case Test Of
    0:Begin
       ControlContractNumer^.Options := ControlContractNumer^.Options and not ofSelectable;
       ControlContractDAte^.Options := ControlContractDate^.Options and not ofSelectable;
       Redraw;
      End;
    1:Begin
       ControlContractNumer^.Options := ControlContractNumer^.Options or ofSelectable;
       ControlContractDAte^.Options := ControlContractDate^.Options or ofSelectable;
       Redraw;
      End;
    Else;
    End;
   End;
   End;


 If (PView(SelAkz)<>Desktop^.TopView)And (Desktop^.Current=PView(NameWin))
 And(ControlBuch^.State and sfFocused <> 0) And (Event.Command<>cmSelectGroup)
 And (Event.What <> EvKeyDown)Then
            Begin
             Event.What:=EvCommand;
             Event.Command:=cmSelectBuchGroup;
             PutEvent(Event);
             ClearEvent(Event);
            End;

          if (ControlMain^.State and sfFocused <> 0)Then
              Begin
               ControlMain^.GetData(Test);
               If Element.Main<>Test Then
             Begin
              Element.Main:=Test;
              If Test=1 Then{взведен флаг дочерней позиции}
               Begin
                ControlMainName^.Options := ControlMainName^.Options or ofSelectable;
                SetStatus;
                FocusNext(False);
               End
               Else
               Begin
                ControlMainName^.Options := ControlMainName^.Options and not ofSelectable;
                SetStatus;
               End
             End
              End;

 If (PView(SelMain)<>Desktop^.TopView) And (Desktop^.Current=PView(NameWin))
 And(ControlMainName^.State and sfFocused <> 0) And (Event.Command<>cmSelectMainName)
 And
(
 ((AutoList=1) And (Event.What <> EvKeyDown))
 Or
 ((AutoList=0)And(Event.What = EvKeyDown)And(Event.KeyCode=kbConst))
)
 Then
            Begin
             Event.What:=EvCommand;
             Event.Command:=cmSelectMainName;
             PutEvent(Event);
             ClearEvent(Event);
            End;

 If (PView(GroupWin)<>Desktop^.TopView) And (Desktop^.Current=PView(NameWin))
 And(ControlGroup^.State and sfFocused <> 0) And (Event.Command<>cmSelectGroup)
 And
(
 ((AutoList=1) And (Event.What <> EvKeyDown))
 Or
 ((AutoList=0)And(Event.What = EvKeyDown)And(Event.KeyCode=kbConst))
)
 Then
            Begin
             Event.What:=EvCommand;
             Event.Command:=cmSelectGroup;
             PutEvent(Event);
             ClearEvent(Event);
            End;

 If (PView(MeraWin)<>Desktop^.TopView) And (Desktop^.Current=PView(NameWin))
 And(ControlMera^.State and sfFocused <> 0) And (Event.Command<>cmSelectMera)
 And
(
 ((AutoList=1) And (Event.What <> EvKeyDown))
 Or
 ((AutoList=0)And(Event.What = EvKeyDown)And(Event.KeyCode=kbConst))
)
 Then
            Begin
             Event.What:=EvCommand;
             Event.Command:=cmSelectMera;
             PutEvent(Event);
             ClearEvent(Event);
            End;

 If NameWin^.AddSert Then
 Begin
 If (PView(KSertifWin)<>Desktop^.TopView) And (Desktop^.Current=PView(NameWin))
 And(ControlKSertif^.State and sfFocused <> 0) And (Event.Command<>cmSelectKSertif)
 And
(
 ((AutoList=1) And (Event.What <> EvKeyDown))
 Or
 ((AutoList=0)And(Event.What = EvKeyDown)And(Event.KeyCode=kbConst))
)
 Then

            Begin
             Event.What:=EvCommand;
             Event.Command:=cmSelectKSertif;
             PutEvent(Event);
             ClearEvent(Event);
            End;
 End;

 If (PView(PostWin)<>Desktop^.TopView) And (Desktop^.Current=PView(NameWin))
 And(ControlLand^.State and sfFocused <> 0) And (Event.Command<>cmSelectPost)
 And
(
 ((AutoList=1) And (Event.What <> EvKeyDown))
 Or
 ((AutoList=0)And(Event.What = EvKeyDown)And(Event.KeyCode=kbConst))
)
 Then

            Begin
             Event.What:=EvCommand;
             Event.Command:=cmSelectPost;
             PutEvent(Event);
             ClearEvent(Event);
            End;


 If (PView(ClassWin)<>Desktop^.TopView) And (Desktop^.Current=PView(NameWin))
 And(ControlClass^.State and sfFocused <> 0) And (Event.Command<>cmSelectClass)

 And
(
 ((AutoList=1) And (Event.What <> EvKeyDown))
 Or
 ((AutoList=0)And(Event.What = EvKeyDown)And(Event.KeyCode=kbConst))
)
 Then

            Begin
             Event.What:=EvCommand;
             Event.Command:=cmSelectClass;
             PutEvent(Event);
             ClearEvent(Event);
            End;



 If (PView(FirmaPostWin)<>Desktop^.TopView) And (Desktop^.Current=PView(NameWin))
 And(ControlFirmaPost^.State and sfFocused <> 0) And (Event.Command<>cmSelectFirmaPost)
 And
(
 ((AutoList=1) And (Event.What <> EvKeyDown))
 Or
 ((AutoList=0)And(Event.What = EvKeyDown)And(Event.KeyCode=kbConst))
)
 Then

            Begin
             Event.What:=EvCommand;
             Event.Command:=cmSelectFirmaPost;
             PutEvent(Event);
             ClearEvent(Event);
            End;



End;


(*
Procedure TClientWindow.ShowClientList(Var st:AllStr;Selector,Regim:Word;VidClienta,Net:Boolean;
          NoLocked1,VidNoLocked1,NoLocked2,VidNoLocked2:Integer;Var Res: Word);
Label 1;
var
  R : TRect;
  Control : PView;
  s : String[CSertif];
  c: Word;
begin
ClearFind;

Res:=0;
Debitors:=VidClienta;
WithNetLock:=Net;
NotLockedCod1:=NoLocked1;
NotLockedCod2:=NoLocked2;
VidNotLockedCod1:=VidNoLocked1;
VidNotLockedCod2:=VidNoLocked2;
R.Assign(0, 0, 80, 23);
Begin
Case Regim Of
0:New(ClientWindow, Init(R, 'Выбор клиента'));
1:New(ClientWindow, Init(R, 'Выбор поставщика'));
Else;
End;
End;

Reg:=Regim;
Sel:=Selector;
R.Assign(79, 1, 80, 18);
Control := New(PScrollBar, Init(R));
ClientWindow^.Insert(Control);

If  Reg=0 Then
Begin
R.Assign(0, 1, 80, 18);
Client := New(PBox, Init(R, 3, PScrollbar(Control)));
Client^.NewList(New(PTextCollection, Init(0,1)));
End
Else
 Begin
  R.Assign(0, 1, 80, 18);
  MakeList := New(PBox, Init(R, 3, PScrollbar(Control)));
  MakeList^.NewList(New(PTextCollection, Init(0,1)));
 End;
Case Reg Of
0:Begin
    Case Selector Of
     0:Assign (ClientFile,Path^.Dat.ToClient+'Client.db');
     1:Assign (ClientFile,Path^.Dat.ToClient+'Sklad.db');
     2:Assign (ClientFile,Path^.Dat.ToClient+'Barter.db');
     Else;
     End;{CAse}
  End;
1:Begin
    Case Selector Of
     0:Assign (ClientFile,Path^.Dat.ToClient+'Make.db');
     1:Assign (ClientFile,Path^.Dat.ToClient+'Sklad.db');
     2:Assign (ClientFile,Path^.Dat.ToClient+'Barter.db');
     Else;
     End;{CAse}
  End;
Else;
End;

c:=IOResult;
Reset (ClientFile);
c:=IOResult;
If c=0 Then
Begin
AInfo('Читаю списки...');
While Not(Eof(ClientFile)) Do
 Begin
     ReadClient(ClientFile,ClientElement);
  If ClientElement.Employ Then
   Begin
    Format (ClientElement.Name,CClient);
    If Reg=0 Then
    Begin
    Client^.List^.Insert(NewStr(ClientElement.Name+'│'+ClientElement.Kod));
    Client^.SetRange(Client^.List^.Count);
    End
    Else
    Begin
    MakeList^.List^.Insert(NewStr(ClientElement.Name+'│'+ClientElement.Kod));
    MakeList^.SetRange(MakeList^.List^.Count);
    End;
   End;
 End;
System.Close(ClientFile);
End
Else
 Begin
  MessageBox(^M+#3'Ошибка доступа к файлам базы !',nil,mfError+mfCanCelButton);
  Goto 1;
 End;
s:=Copy(st,1+CClient+1,CClientKod);
If Reg=0 Then
Begin
Client^.FocusItem(Location(Client,S,ProdagaWindow));
Client^.HelpCtx:=$E171;
ClientWindow^.Insert(Client);
PrevClient:=Copy(Client^.GetText(Client^.Focused,CLient^.List^.Count),1+CClient+1,CClientKod);
End
Else
 Begin
MakeList^.FocusItem(Location(MakeList,S,ProdagaWindow));
MakeList^.HelpCtx:=$E171;
PrevClient:=Copy(MakeList^.GetText(MakeList^.Focused,MakeList^.List^.Count),1+CMake+1,CMakeKod);
ClientWindow^.Insert(MakeList);
 End;

R.Assign(1, 19, 12, 20);
Control := New(PColoredText, Init(R, 'N Договора:', $74));
ClientWindow^.Insert(Control);

R.Assign(12, 19, 57, 20);
ControlDogovor := New(PColoredText, Init(R, #3, $7E));
ClientWindow^.Insert(ControlDogovor);

R.Assign(12, 20, 21, 21);
Control := New(PColoredText, Init(R, #3+'Лицензия:', $74));
ClientWindow^.Insert(Control);

R.Assign(21, 20, 66, 21);
{If Regim=1 Then}
ControlEnviropment := New(PColoredText, Init(R, #3{GetMakeField(FEnvir,PrevClient,Selector)}, $7E));
{Else
ControlEnviropment := New(PColoredText, Init(R, #3+GetClientField(FEnvir,PrevClient,Selector), $7E));}
ClientWindow^.Insert(ControlEnviropment);

R.Assign(1, 21, 7, 22);
Control := New(PColoredText, Init(R, 'Лимит:', $74));
ClientWindow^.Insert(Control);

R.Assign(7, 21, 22, 22);
{If Regim=1 Then
ControlLimit := New(PColoredText, Init(R, #3+GetMAkeField(FLimit,PrevClient,Selector), $7E))
Else}
ControlLimit := New(PColoredText, Init(R, #3{GetClientField(FLimit,PrevClient,Selector)}, $7E));

ClientWindow^.Insert(ControlLimit);

R.Assign(24, 21, 29, 22);
Control := New(PColoredText, Init(R, 'Долг:', $74));
ClientWindow^.Insert(Control);

R.Assign(29, 21, 44, 22);
{If Regim=1 Then
ControlDolg := New(PColoredText, Init(R, #3+GetMakeField(FDolg,PrevClient,Selector), $7E))
Else}
ControlDolg := New(PColoredText, Init(R, #3+'???'{GetClientField(FDolg,PrevClient,Selector)}, $FE));
ClientWindow^.Insert(ControlDolg);

R.Assign(45, 21, 71, 22);
Control := New(PColoredText, Init(R, 'Срок действия лицензии до:', $74));
ClientWindow^.Insert(Control);

R.Assign(71, 21, 79, 22);
ControlSrokLizensia := New(PColoredText, Init(R, #3+'', $7E));
ClientWindow^.Insert(ControlSrokLizensia);

R.Assign(58, 19, 79, 20);
ControlStatus := New(PColoredText, Init(R, #3+'', $7E));
ClientWindow^.Insert(ControlStatus);


{
If VidClienta And (Sel=0) Then
Begin
R.Assign(29, 22, 51, 23);
Control := New(PColoredText, Init(R, #3' F2 - Рассчитать долг', $71));
Control^.Options := Control^.Options or ofCenterX;
ClientWindow^.Insert(Control);
End;
}



ClientWindow^.SelectNext(False);
PrevClient[0]:=#0;
NoInfo;
c:=Desktop^.ExecView(ClientWindow);
If c<>CmCancel Then
   If c=CmOk Then Res:=2;
   If c=CmYes Then Res:=3;
   If c=CmCancel Then Res:=1;
   If  Reg=0 Then
   St:=Client^.GetText(Client^.Focused,Client^.List^.Count)
   Else
   St:=MakeList^.GetText(MakeList^.Focused,MakeList^.List^.Count);

   If ShowClients=1 Then
    Begin
     s:=Copy(st,1+CCLient+1,CClientKod);
     If  Reg=0 Then
     s:=GetClientField(FMessages,s,Selector)
     Else
     s:=GetMAkeField(FMessages,s,Selector);
     DelSpaceRight(s);

     If s[0]<>#0 Then
      Begin
       SpecialBeep;
       MessageBox(^M+#3+s,Nil,mfInformation+mfCancelButton);
      End;
     s:=Copy(st,1+CCLient+1,CClientKod);
     If  (((Reg=0) And (Selector in [0,2])) Or
         ((Reg=1) And (Selector in [2]))) And TestComment(s,Selector) Then
        ViewClientCommentProc1(s,Selector);

    End;

{ временно отключил 14.05.99
     If Reg=0 Then
     Begin
     s:=Copy(st,1+CCLient+1,CClientKod);
     c:=StrToInt(GetClientField(FDebit,s,Reg));
     s:=GetClientField(FNDogovor,s,Reg);

     If (Not(Pos('Н',s)>0)  And (c=1))And
        (Not(Pos('А',s)>0)  And (c=1)) Then
      Begin
       SpecialBeep;
       MessageBox(^M+#3+'Необходимо обновить договор консигнации!!!',Nil,mfInformation+mfCancelButton);
      End;

     End;}

1:
{If VidClienta Then }
Dispose(COntrol,Done);
Dispose(ClientWindow,Done);
end;
*)

(*
Procedure TClientWindow.ShowClientList(Var st:AllStr;Selector,Regim:Word;VidClienta,Net:Boolean;
          NoLocked1,VidNoLocked1,NoLocked2,VidNoLocked2:Integer;Var Res: Word);
Label 1;
var
  R : TRect;
  Control : PView;
  s : String[CSertif];
  c,j: Word;
  Clf : File;
  CLE : PBufClientType;
  Count : Word;
begin
ClearFind;

Res:=0;
Debitors:=VidClienta;

If InputZakaz<>1 Then
WithNetLock:=Net
Else
WithNetLock:=False;

NotLockedCod1:=NoLocked1;
NotLockedCod2:=NoLocked2;
VidNotLockedCod1:=VidNoLocked1;
VidNotLockedCod2:=VidNoLocked2;
R.Assign(0, 0, 80, 23);
Begin
Case Regim Of
0:New(ClientWindow, Init(R, 'Выбор клиента'));
1:New(ClientWindow, Init(R, 'Выбор поставщика'));
Else;
End;
End;

ClientWindow^.Options := ClientWindow^.Options or ofCenterX Or ofCenterY;


Reg:=Regim;
Sel:=Selector;
R.Assign(79, 1, 80, 18);
Control := New(PScrollBar, Init(R));
ClientWindow^.Insert(Control);

If  Reg=0 Then
Begin
R.Assign(0, 1, 80, 18);
Client := New(PBox, Init(R, 3, PScrollbar(Control)));
Client^.NewList(New(PTextCollection, Init(0,1)));
End
Else
 Begin
  R.Assign(0, 1, 80, 18);
  MakeList := New(PBox, Init(R, 3, PScrollbar(Control)));
  MakeList^.NewList(New(PTextCollection, Init(0,1)));
 End;
Case Reg Of
0:Begin
    Case Selector Of
     0:Assign (ClF,Path^.Dat.ToClient+'Client.db');
     1:Assign (ClF,Path^.Dat.ToClient+'Sklad.db');
     2:Assign (ClF,Path^.Dat.ToClient+'Barter.db');
     Else;
     End;{CAse}
  End;
1:Begin
    Case Selector Of
     0:Assign (ClF,Path^.Dat.ToClient+'Make.db');
     1:Assign (ClF,Path^.Dat.ToClient+'Sklad.db');
     2:Assign (ClF,Path^.Dat.ToClient+'Barter.db');
     Else;
     End;{CAse}
  End;
Else;
End;

c:=IOResult;
Reset (ClF,SizeOf(ClientType));
c:=IOResult;
If c=0 Then
Begin
{AInfo('Читаю списки...');}
While Not(Eof(ClF)) Do
 Begin
    DInfoMsgShkala('Читаю списки контрагентов. Ждите... ',0,FileSize(CLF),FilePos(CLF));
    Count:=0;
    New(CLE,Init);
    ReadBufClient(Clf,CLE,Count);
  For c:=1 To Count Do

  Begin
  If ClE^.Point.Dat[c].Employ Then
   Begin
    Format (ClE^.Point.Dat[c].Name,CClient);

    {If (ClE^.Point.Dat[1]=ClE^.Point.Dat[2]) Then;}
    If Reg=0 Then
    Begin
    {If Odd(c) Then}
    Begin
{номер договора}
{адрес фактический}
{лицензия}
    Client^.List^.Insert(NewStr(ClE^.Point.Dat[c].Name+'│'+ClE^.Point.Dat[c].Kod));
    Client^.SetRange(Client^.List^.Count);
    End;
    End
    Else
    Begin
    MakeList^.List^.Insert(NewStr(ClE^.Point.Dat[c].Name+'│'+ClE^.Point.Dat[c].Kod));
    MakeList^.SetRange(MakeList^.List^.Count);
    End;
   End;{Employ}
  End;{For}
     Dispose(CLE,Done);
 End;{Eof}
System.Close(ClF);
NoInfoMsg;
End
Else
 Begin
  MessageBox(^M+#3'Ошибка доступа к файлам базы !',nil,mfError+mfCanCelButton);
  Goto 1;
 End;

s:=Copy(st,1+CClient+1,CClientKod);

If Reg=0 Then
Begin
Client^.FocusItem(Location(Client,S,ProdagaWindow));
Client^.HelpCtx:=$E171;
ClientWindow^.Insert(Client);
PrevClient:=Copy(Client^.GetText(Client^.Focused,CLient^.List^.Count),1+CClient+1,CClientKod);
End
Else
 Begin
MakeList^.FocusItem(Location(MakeList,S,ProdagaWindow));
MakeList^.HelpCtx:=$E171;
PrevClient:=Copy(MakeList^.GetText(MakeList^.Focused,MakeList^.List^.Count),1+CMake+1,CMakeKod);
ClientWindow^.Insert(MakeList);
 End;

R.Assign(1, 19, 12, 20);
Control := New(PColoredText, Init(R, 'N Договора:', $74));
ClientWindow^.Insert(Control);

R.Assign(1, 18, 12, 19);
Control := New(PColoredText, Init(R, '   Адрес Ф:', $74));
ClientWindow^.Insert(Control);

R.Assign(12, 18, 57, 19);
ControlAdress := New(PColoredText, Init(R, #3+'', $7E));
ClientWindow^.Insert(ControlAdress);

R.Assign(12, 19, 57, 20);
ControlDogovor := New(PColoredText, Init(R, #3, $7E));
ClientWindow^.Insert(ControlDogovor);

R.Assign(1, 20, 10, 21);
Control := New(PColoredText, Init(R, #3+'Лицензия:', $74));
ClientWindow^.Insert(Control);

R.Assign(10, 20, 55, 21);
ControlEnviropment := New(PColoredText, Init(R, #3+'', $7E));
ClientWindow^.Insert(ControlEnviropment);



R.Assign(56, 20, 61, 21);
Control := New(PColoredText, Init(R, #3+'ИНН:', $74));
ClientWindow^.Insert(Control);

R.Assign(61, 20, 79, 21);
ControlINN := New(PColoredText, Init(R, #3+'', $7E));
ClientWindow^.Insert(ControlINN);



R.Assign(1, 21, 7, 22);
Control := New(PColoredText, Init(R, 'Лимит:', $74));
ClientWindow^.Insert(Control);

R.Assign(7, 21, 22, 22);
{If Regim=1 Then
ControlLimit := New(PColoredText, Init(R, #3+GetMAkeField(FLimit,PrevClient,Selector), $7E))
Else}
ControlLimit := New(PColoredText, Init(R, #3{GetClientField(FLimit,PrevClient,Selector)}, $7E));

ClientWindow^.Insert(ControlLimit);

R.Assign(24, 21, 29, 22);
Control := New(PColoredText, Init(R, 'Долг:', $74));
ClientWindow^.Insert(Control);

{
R.Assign(29, 21, 44, 22);
ControlDolg := New(PColoredText, Init(R, #3+'???', $FE));
ClientWindow^.Insert(ControlDolg);
}

               R.Assign(30, 21, 35, 22);
               ControlDolg := New(PColoredText, Init(R, 'Space', $7E));
               ClientWindow^.Insert(ControlDolg);

               R.Assign(36, 21, 44, 22);
               ControlDolgText := New(PColoredText, Init(R, 'Пересчет', $70));
               ClientWindow^.Insert(ControlDolgText);


R.Assign(45, 21, 71, 22);
Control := New(PColoredText, Init(R, 'Срок действия лицензии до:', $74));
ClientWindow^.Insert(Control);

R.Assign(71, 21, 79, 22);
ControlSrokLizensia := New(PColoredText, Init(R, #3+'', $7E));
ClientWindow^.Insert(ControlSrokLizensia);

R.Assign(58, 18, 79, 19);
ControlStatus := New(PColoredText, Init(R, #3+'', $7E));
ClientWindow^.Insert(ControlStatus);

{If VidClienta And (Sel=0) Then
Begin
R.Assign(29, 22, 51, 23);
Control := New(PColoredText, Init(R, #3' F2 - Рассчитать долг', $71));
Control^.Options := Control^.Options or ofCenterX;
ClientWindow^.Insert(Control);
End;}

ClientWindow^.SelectNext(False);
PrevClient[0]:=#0;
NoInfo;
c:=Desktop^.ExecView(ClientWindow);
If c<>CmCancel Then
   If c=CmOk Then Res:=2;
   If c=CmYes Then Res:=3;
   If c=CmCancel Then Res:=1;
   If  Reg=0 Then
   St:=Client^.GetText(Client^.Focused,Client^.List^.Count)
   Else
   St:=MakeList^.GetText(MakeList^.Focused,MakeList^.List^.Count);

   If ShowClients=1 Then
    Begin
     s:=Copy(st,1+CCLient+1,CClientKod);
     If  Reg=0 Then
     s:=GetClientField(FMessages,s,Selector)
     Else
     s:=GetMAkeField(FMessages,s,Selector);
     DelSpaceRight(s);

     If s[0]<>#0 Then
      Begin
       SpecialBeep;
       MessageBox(^M+#3+s,Nil,mfInformation+mfCancelButton);
      End;
     s:=Copy(st,1+CCLient+1,CClientKod);
     If  (((Reg=0) And (Selector in [0,2])) Or
         ((Reg=1) And (Selector in [2]))) And TestComment(s,Selector) Then
        ViewClientCommentProc1(s,Selector);
    End;

1:
{If VidClienta Then }
Dispose(COntrol,Done);
Dispose(ClientWindow,Done);
end;
*)



Procedure ChekBazAndAddingList(SArt:ArtikulStr;Var LockList:PBox);
Var ElementFile : File;
    c : Word;
    BE : PBUFBazType;
    Count : Word;
    s : String;
Begin

If GetRazdelStatus(SArt) Then Exit;{сертификат не может быть связанной позицией}

Assign(ElementFile,Path^.Dat.ToName+Copy(SArt,1,CRAzdelKod)+'.id');
OldFileMode:=FileMode;
FileMode:=ReadOnlyN;
Reset(ElementFile,SizeOf(BazType));
c:=IOResult;
FileMode:=OldFileMode;
If C<>0 Then
Begin
 MessageBox(^M+Path^.Dat.ToName+Copy(SArt,1,CRAzdelKod)+'.id'+
 ' Код:'+IntToStr(c,CKOl),nil,mfError+mfCancelButton);
 Exit;
End;

     While Not(Eof(ElementFile)) Do
     Begin
      New(BE,Init);
      ReadBufBaz(ElementFile,BE,Count);
      For c:=1 To Count Do
       Begin
        If(BE^.Point.Dat[c].Employ) And
	     (StrToInt(BE^.Point.Dat[c].FantomKod)=StrToInt(SArt)) And
	     (BE^.Point.Dat[c].Main=1)  Then
         Begin
          If testElement(SArt,LockList) then
           Begin
            s:='│'+SArt;
            LockList^.List^.Insert(NewStr(s));
            LockList^.SetRange(LockList^.List^.Count);
           End;
         End;
       End;{For}
      Dispose(BE,Done);
     End;{While}

     c:=IOResult;
     System.Close(ElementFile);
     c:=IOResult;
     NoInfoMsg;

End;



procedure TWindowCol.FreeItem;
begin
end;

function TWindowList.GetText;
 var S: String;
     P: PView;
begin
 P := List^.At(Item);
 S := '???';
 Message(P, evCommand, cmGetName, @S);
 GetText := S;
end;

procedure WindowManager;
 label 1;
 var D: PDialog;
     R: TRect;
     PC: PWindowCol;
     PV: PView;
     S: String;
     DT: record P: PCollection; N: Word; end;

  procedure InsView(P: PView); far;
  begin
    if P = nil then Exit;
    S := '';
    if (P^.GetState(sfVisible)) then
      begin
       Message(P, evCommand, cmGetName, @S);
       if (S <> '') then PC^.Insert(P);
      end;
  end;

begin
  New(PC, Init(10,10));
  Desktop^.ForEach(@InsView);
  if PC^.Count = 0 then
    begin
     Dispose(PC, Done);
	Exit
   end;

  R.Assign(1, 0, 80, 15);
  New(D, Init(R, 'Список окон'));
  D^.HelpCtx:=$E081;
  D^.Options := D^.Options or ofCenterX or ofCenterY;
  {D^.HelpCtx:=$E011;}

  R.Assign(D^.Size.X-1,1,D^.Size.X,D^.Size.Y-1);
  PV := New(PScrollBar, Init(R));
  PV^.Options := PV^.Options or ofPostProcess;
  D^.Insert(PV);

  R.Assign(2,1,D^.Size.X-1,D^.Size.Y-1);
  PV := New(PWindowList, Init(R,1,PScrollBar(PV)));
  PV^.Options := PV^.Options or ofPostProcess;
  PListBox(PV)^.NewList(PC);
  D^.Insert(PV);

1:
  R.A.X := Desktop^.ExecView(D);
  D^.GetData(DT);
  if PC^.Count > 0 then
  begin
    if R.A.X = cmNo then
    begin
      if PView(DT.P^.At(DT.N))^.Valid( cmClose ) then
	 begin
        PView(DT.P^.At(DT.N))^.Free;
        New(PC, Init(10,10));
        Desktop^.ForEach(@InsView);
        if PC^.Count > 0 then
	   begin
          DT.P^.AtDelete(DT.N);
          DT.P := NIL;
          D^.SetData( DT );
          If ( DT.N > 0 ) and ( DT.N >= PC^.Count ) then Dec( DT.N );
          DT.P := PC;
          D^.SetData( DT );
          goto 1
        end
      end
    end;
    if R.A.X = cmOK then PView(DT.P^.At(DT.N))^.Select;
  end;
  Dispose(D, Done);
  Dispose(PC, Done);
end;





Begin
End.