{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}

Unit PrhTools;

Interface


Uses Dialogs,Drivers,Glob,Access1,Access,MyCalc;

Type
  PCartWindow = ^TCartWindow;
  TCartWindow = object(TDialog)
  SertifWin   : PSertifWindow;
  Calc        : PMyCalculator;
    Procedure Ini(Var s:String;Regim:Word);
    procedure HandleEvent(var Event: TEvent); virtual;
    Destructor Done;Virtual;
  end;

Type
  PTestOpenPosition = ^TestOpenPosition;
  TestOpenPosition = object(TDialog)
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure CalcPosition;
    procedure MAkeReport;
    Destructor Done;Virtual;
  end;


Type
  PPrihodWindow = ^TPrihodWindow;
  TPrihodWindow = object(TDialog)
    Car : PCartWindow;
    Cl  : PClientWindow;
    Rz  : PRazdelWindow;
    Nam : PNameWindow;
    constructor Init(Var l: Boolean);
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure AddName;
         procedure DrawFullNAme;
         procedure OpenPrihodWindow;
         procedure CalcItogo;
    procedure Refresh;
         Procedure SaveToFilePr(Var Save : Boolean);
  end;



Procedure InputPrihodToSklad(As : DocumentEdit);
Function GetOpt(Lz:PNewVozwratType):Boolean;
Function  Zapros    (PereozenkaElement : PPereozenkaType;j:Byte): Boolean;
{Function WritePereozenkaToFile(L:PPereozenkaType) : Boolean;}

{$I Compile.INC}

 Implementation

uses DBEngine,Objects, Views, MsgBox,Vision5,Vision2,Vision1,Protect,{MyCalc,}
     Windos,Menus,Utils,TpDate,Printers,App,ColorTxt,Serv,InpLong,
	Validate,CPrihod,ServStr,NetCall,Net,NetDbEng;



var
 CartWin : PCartWindow;
 testw,TestWindow : PTestOpenPosition;
 WarningList : PBox;
 PrihodWindow : PPrihodWindow;
 ControlFullName,ControlDoc,ControlT,Control_IO,ControlArtikul,Control_IR,Control_Litr,
 ControlOZ,ControlCurrent,ControlPack,R_ZenaControl,ControlKol,ControlS,
 Control1,Control2,Control3,Control4,Control5,ControlOperatorSelect,
 ControlClient, ControlVDate,ControlVDoc,ControlRazdel,
 {элементы окна ввода}
 ControlZakupka,ControlNGTDL,ControlPostL,ControlA,ControlData,ControlDo,ControllAkzis,
 ControlLink,ControlLSertif,ControlKSertif,ControlSrokDo,
 Control_Zakupka,Control_Pos : PView;
 PrevPrihod : PPrihodType;
 PrevVozwrat : PVozwratType;
 NSertif : String[CNAme+1+CNAme+1+CArtikul];
 PrevS : String;
 SArtikul : ArtikulStr;
 InPut : InputType;
 NewTovar :PBox;
 OperatorSelector : Word;
 AllZakupka : AllStr;
 GTD : PBox;
 PrevName : String;



Function GetNGTD(Art:ArtikulStr):AllStr;
VAr s: String;
Begin
 GetNGTD[0]:=#0;
 s:=Copy(GTD^.GetText(Location(GTD,Art,True),Gtd^.List^.Count),1+CArtikul+1,CNSertif);
 DelSpaceRight(s);
 GetNGTD:=s;
End;

Function GetMarka(Art:ArtikulStr):AllStr;
VAr s: String;
Begin
 GetMarka[0]:=#0;
 s:=Copy(GTD^.GetText(Location(GTD,Art,True),Gtd^.List^.Count),1+CArtikul+1+CNSertif+1,CNSertif);
 DelSpaceRight(s);
 GetMarka:=s;
End;

Function GetVirabotano(Art:ArtikulStr):AllStr;
VAr s: String;
Begin
 GetVirabotano[0]:=#0;
 s:=Copy(GTD^.GetText(Location(GTD,Art,True),Gtd^.List^.Count),1+CArtikul+1+CNSertif+1+CNSertif+1,CDate);
 DelSpaceRight(s);
 GetVirabotano:=s;
End;

Function GetGodnost(Art:ArtikulStr):AllStr;
VAr s: String;
Begin
 GetGodnost[0]:=#0;
 s:=Copy(GTD^.GetText(Location(GTD,Art,True),Gtd^.List^.Count),1+CArtikul+1+CNSertif+1+CNSertif+1+CDate+1,
 CDate);
 DelSpaceRight(s);
 GetGodnost:=s;
End;



Function GetOpt(Lz:PNewVozwratType):Boolean;
Var F : MarketFIleType;
    i : Byte;
    l : LongInt;
    E : PSuperMarketType;
Begin
GetOpt:=True;
Assign(f,Path^.Dat.ToMarket+Lz^.Dat.BasisDate+'.mrk');
i:=IOResult;
Reset(F);
i:=IOResult;
If i <> 0 Then
  Begin
   MessageBox(#3^M+#3+'Данные за '+Lz^.Dat.BasisDate+' в базе отсутствуют !',Nil,mfError+mfCancelButton);
   Exit;
  End;
  New(E,Init);
DelSpace(Lz^.Dat.BasisDoc);
While Not(Eof(f)) And
      Not((ClearChar(Lz^.Dat.BasisDoc)=ClearChar(E^.Dat.Document))
      And(Lz^.Dat.MakeKod=E^.Dat.ClientKod)And(E^.Dat.Active)) Do
      Begin
     {
     Repeat
     Until Lock(f,FilePos(f)*SizeOf(SuperMarketType),SizeOf(SuperMarketType));
     }
     ReadMArket(f,E);
     {
     Repeat
      UnLock(f,(FilePos(f)-1)*SizeOf(SuperMarketType),SizeOf(SuperMarketType));
     Until (DosError=0);
     }
      DelSpace(E^.Dat.Document);
      DelSpace(E^.Dat.ClientKod);
      End;

If Eof(f) And Not
   ((ClearChar(Lz^.Dat.BasisDoc)=ClearChar(E^.Dat.Document))And
   (Lz^.Dat.MakeKod=E^.Dat.ClientKod)And(E^.DAt.Active))
      Then
   Begin
   Close(f);
   Dispose(E,Done);
   MessageBox(^M+#3+'В базе данных за '+Lz^.Dat.BasisDate+' документ N '+Lz^.Dat.BasisDoc+ ' с клиентом '+
   Lz^.Dat.MakeKod+
   ' не найден!',Nil,mfError+mfCancelButton);
   Exit;
   End;

   Close(f);

If E^.Dat.DocSelector in [0,1,2] Then GetOpt:=False
Else
 Begin

  If E^.Dat.DocSelector in [6,8] Then
         GetOpt:=True{TestSf(E^.Dat.ClientKod,E^.Dat.Document,E^.Dat.DateC)};
  If E^.Dat.DocSelector in [5,7] Then
         GetOpt:=False{TestSf(E^.Dat.ClientKod,E^.Dat.Document,E^.Dat.DateC)};


 End;
{
 Else
  If E^.Dat.DocSelector=5 Then
  GetOpt:=TestSf(E^.Dat.ClientKod,E^.Dat.Document,E^.Dat.DateC);
}
Dispose(E,Done);
End;






Function Zapros(PereozenkaElement : PPereozenkaType;j:Byte): Boolean;
var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  ControlBak_R_Zena : PColoredText;
  ControlBak_O_Zena : PColoredText;
  ControlNew_R_Zena : PColoredText;
  ControlNew_O_Zena : PColoredText;
  ControlItogo_R_Zena : PColoredText;
  ControlItogo_O_Zena : PColoredText;
  ControlDocNum : PColoredText;
  ControlDate : PColoredText;
  ControlSklad : PColoredText;
  ws,s : String;
  c:Word;

begin
ClearFind;
R.Assign(1, 0, 78, 23);
New(Dlg, Init(R, 'Автоматическая переоценка товара'));
Dlg^.Options := Dlg^.Options or ofTileable or ofCenterX or ofCenterY;
Dlg^.HelpCtx :=$E080;

R.Assign(76, 3, 77, 19);
Control := New(PScrollBar, Init(R));
Dlg^.Insert(Control);

R.Assign(1, 3, 76, 19);
Pereozenka := New(PBox, Init(R, 1, PScrollbar(Control)));
Pereozenka^.NewList(New(PTextCollection, Init(1,1)));
For c:=1 To j Do
 Begin
  ws:=GetIdField(FName,PereozenkaElement^.Dat.Element[c].BazKod);
  Format(ws,CName);
  s:=ws;
  ws:=PereozenkaElement^.Dat.Element[c].BazKod;
  Format(ws,CArtikul);
  s:=s+'│'+ws;
  ws:=PereozenkaElement^.Dat.Element[c].Kol;
  Format(ws,CKol);
  s:=s+'│'+ws;
  ws:=PereozenkaElement^.Dat.Element[c].Bak_R_Zena;
  MySTr(StrToReal(ws),CZena,CMantissa,ws);
  Format(ws,CZena);
  s:=s+'│'+ws;
  ws:=PereozenkaElement^.Dat.Element[c].Bak_O_Zena;
  MySTr(StrToReal(ws),CZena,CMantissa,ws);
  Format(ws,CZena);
  s:=s+'│'+ws;
  ws:=PereozenkaElement^.Dat.Element[c].New_R_Zena;
  MySTr(StrToReal(ws),CZena,CMantissa,ws);
  Format(ws,CZena);
  s:=s+'│'+ws;
  ws:=PereozenkaElement^.Dat.Element[c].New_O_Zena;
  MySTr(StrToReal(ws),CZena,CMantissa,ws);
  Format(ws,CZena);
  s:=s+'│'+ws;
  Pereozenka^.List^.Insert(NewStr(s));
  Pereozenka^.SetRange(Pereozenka^.List^.Count);
 End;
Pereozenka^.FocusItem(0);

Dlg^.Insert(Pereozenka);

  R.Assign(1, 2, 76, 3);
  Dlg^.Insert(New(PLabel, Init(R, 'Наименование               Код   Колич Р/Цена   О/Цена   Р/Цена   О/Цена  ', Pereozenka)));

R.Assign(3, 19, 23, 20);
Control := New(PColoredText, Init(R, 'Итого по старым Р/Ц:', $74));
Dlg^.Insert(Control);

R.Assign(3, 20, 23, 21);
Control := New(PColoredText, Init(R, 'Итого по старым О/Ц:', $74));
Dlg^.Insert(Control);

R.Assign(23, 19, 38, 20);
ControlBak_R_Zena := New(PColoredText, Init(R, ''+PereozenkaElement^.Dat.Itogo_Bak_R_Zena, $7E));
Dlg^.Insert(ControlBak_R_Zena);

R.Assign(23, 20, 38, 21);
ControlBak_O_Zena := New(PColoredText, Init(R, ''+PereozenkaElement^.Dat.Itogo_Bak_O_Zena, $7E));
Dlg^.Insert(ControlBak_O_Zena);

R.Assign(40, 19, 59, 20);
Control := New(PColoredText, Init(R, 'Итого по новым Р/Ц:', $74));
Dlg^.Insert(Control);

R.Assign(59, 19, 74, 20);
ControlNew_R_Zena := New(PColoredText, Init(R, ''+PereozenkaElement^.Dat.Itogo_New_R_Zena, $7E));
Dlg^.Insert(ControlNew_R_Zena);

R.Assign(40, 20, 59, 21);
Control := New(PColoredText, Init(R, 'Итого по новым О/Ц:', $74));
Dlg^.Insert(Control);

R.Assign(59, 20, 74, 21);
ControlNew_O_Zena := New(PColoredText, Init(R, ''+PereozenkaElement^.Dat.Itogo_New_O_Zena, $7E));
Dlg^.Insert(ControlNew_O_Zena);

R.Assign(1, 1, 12, 2);
Control := New(PColoredText, Init(R, 'Документ N:', $74));
Dlg^.Insert(Control);

R.Assign(16, 1, 21, 2);
Control := New(PColoredText, Init(R, 'Дата:', $74));
Dlg^.Insert(Control);

R.Assign(3, 21, 23, 22);
Control := New(PColoredText, Init(R, 'Переоценка  по  Р/Ц:', $74));
Dlg^.Insert(Control);

R.Assign(23, 21, 38, 22);
ControlItogo_R_Zena := New(PColoredText, Init(R, ''+PereozenkaElement^.Dat.Delta_RZ, $7E));
Dlg^.Insert(ControlItogo_R_Zena);

R.Assign(40, 21, 59, 22);
Control := New(PColoredText, Init(R, 'Переоценка  по О/Ц:', $74));
Dlg^.Insert(Control);

R.Assign(59, 21, 74, 22);
ControlItogo_O_Zena := New(PColoredText, Init(R, ''+PereozenkaElement^.Dat.Delta_OZ, $7E));
Dlg^.Insert(ControlItogo_O_Zena);

{Str(PereozenkaElement.Document:3,S);}
R.Assign(12, 1, 15, 2);
ControlDocNum := New(PColoredText, Init(R, ''+PereozenkaElement^.Dat.Document, $7E));
Dlg^.Insert(ControlDocNum);

R.Assign(21, 1, 29, 2);
ControlDate := New(PColoredText, Init(R, ''+TekDate, $7E));
Dlg^.Insert(ControlDate);

R.Assign(57, 0, 64, 1);
ControlSklad := New(PColoredText, Init(R, ' Склад:', $74));
Dlg^.Insert(ControlSklad);

R.Assign(64, 0, 76, 1);
Control := New(PColoredText, Init(R, ''+GetClientField(FClient,PereozenkaElement^.Dat.SkladKod,1), $7E));
Dlg^.Insert(Control);

R.Assign(45, 1, 51, 2);
Control := New(PColoredText, Init(R, 'Старые', $74));
Dlg^.Insert(Control);

R.Assign(64, 1, 69, 2);
Control := New(PColoredText, Init(R, 'Новые', $74));
Dlg^.Insert(Control);

R.Assign(2, 0, 16, 1);
Control := New(PColoredText, Init(R, 'Всего позиций:', $74));
Dlg^.Insert(Control);

Str(j:2,ws);
DelSpace(ws);

R.Assign(16, 0, 20, 1);
Control := New(PColoredText, Init(R, #3+ws, $4E));
Dlg^.Insert(Control);



Dlg^.SelectNext(False);
C:=Desktop^.ExecView(Dlg);
If c<> CmCancel Then
      Zapros:=True
Else
     Zapros:=False;
Dispose(  Pereozenka,Done);
Dispose(  ControlBak_R_Zena,Done);
Dispose(  ControlBak_O_Zena,Done);
Dispose(  ControlNew_R_Zena,Done);
Dispose(  ControlNew_O_Zena,Done);
Dispose(  ControlItogo_R_Zena,Done);
Dispose(  ControlItogo_O_Zena,Done);
Dispose(  ControlDocNum,Done);
Dispose(  ControlDate,Done);
Dispose(  ControlSklad,Done);
Dispose(  Control,Done);
Dispose(Dlg,Done);
ClearFind;
End;

(*
Function WritePrihodToFile(L:PPrihodType) : Boolean;
Var PrihodFile : File Of PrihodType;
    c : Byte;
    Find : Boolean;
    Test : PPrihodType;
Begin
 WritePrihodToFile:=False;
 Assign(PrihodFile,Path^.Dat.ToPrihod+L^.Dat.DateC+'.prh');
 c:=IOResult;
{$I-}
 Reset(PrihodFile);
 c:=IOResult;
If c<>0 Then
 Begin
  If MessageBox('Файл '+L^.Dat.DateC+'.prh не существует !'^M+
     'Создать такой файл ?'+' Код:'+IntToStr(c,3),nil, mfConfirmation + mfOkCancel)=cmOk  Then
     Begin
      Rewrite(PrihodFile);
      c:=IOResult;
     End
    Else
     Begin
      Exit;
     End;
 End;
 If c <> 0 Then Begin
                 MessageBox(#3^M+#3'Нет доступа к файлу '+L^.Dat.DateC+'.prh!',
                 nil, mfError + mfOkButton);
                 Exit;
                End
 Else
  Begin
   If Status=DocEdit Then
    Begin
     New(test,Init);
     Find := False;
     DelSPace(L^.DAt.Document);
     DelSPace(L^.DAt.DAteC);
     DelSPace(L^.DAt.SkladKod);
     {цикл поиска исходного документа в файле}
     While Not(Eof(PrihodFile)) And Not(Find) Do
      Begin
       Read(PrihodFile,Test^.DAt);
       DelSpace(Test^.Dat.Document);
       DelSpace(Test^.Dat.DateC);
       DelSpace(Test^.Dat.SkladKod);
       If (Test^.Dat.Document=L^.DAt.Document) And
          (Test^.Dat.DateC=L^.DAt.DateC) And
          (Test^.Dat.SkladKod=L^.DAt.SkladKod) Then Find:=True;
      End;
      Dispose(Test,Done);

     {если документ не найден тогда выходим с сообщением}
     If Not(Find) Then
      Begin
       Close(PrihodFile);
       MessageBox(#3^M+#3'Документ прихода N '+ L^.Dat.Document+' в базе за '+L^.DAt.DAteC+' не найден!',Nil,
          mfError+mfCancelButton);
       Exit;
      End;
     {если мы нашли документ тогда блокируем его и записываем}
     Seek(PrihodFile,FilePos(PrihodFile)-1);
     Repeat
     Until (Lock(PrihodFile,FilePos(PrihodFile)*SizeOf(PrihodType),SizeOf(PrihodType)));
     Write(PrihodFile,L^.DAt);
     Repeat
     Until ;

     Close(PrihodFile);

    End;



   Seek(PrihodFile,StrToInt(ClearChar(L^.Dat.Document))-1);
   Write(PrihodFile,L^.Dat);
   Close(PrihodFile);
   WritePrihodToFile:=True;
  End;
End;*)


Function WritePrihodToSkladFile(L:PPrihodType) : Boolean;
Var SkladFile : File Of SkladType;
    Sklad : PSkladType;
    i,p,k : Byte;
    Ls:LongInt;
    s1,s2 : TEnjoyStr;
    Bilo,Stalo : ArtikulStr;
Begin
WritePrihodToSkladFile:=False;
New(Sklad,Init);
 For i:=1 To L^.DAt.Amount{J} Do
  Begin
   S1:=Copy(L^.Dat.PrihodElement[i].BazKod,1,CRazdelKod);
   Assign(SkladFile,Path^.Dat.ToSklad+s1+'.db');
   p:=IOResult;
   Reset(SkladFile);
   p:=IOResult;
   If p <> 0 Then
    Begin
     MessageBox(#3^M+#3'Ошибка доступа к файлу '+S1+'.db!',Nil,mfError+mfCancelButton);
     Dispose(Sklad,Done);
     Exit;
    End;
         Ls:=GetFileLocation3(Copy(L^.Dat.PrihodElement[i].BazKod,CRazdelKod+1,CKod));
         Seek(SkladFile,Ls);

        {блокируем позицию предварительной блокировкой}
        Repeat
        Pause(1);
        Until Lock(SkladFile,FilePos(SkladFile)*SizeOf(SkladType),SizeOf(SkladType));

        Read(SkladFile,Sklad^.DAt);
        Bilo:=Sklad^.Dat.Input.Kol;

         {модифицируем поля}

        With Sklad^.Dat.Input Do
        Begin
            Post:=L^.Dat.PrihodElement[i].Input.Post;
         Zakupka:=L^.Dat.PrihodElement[i].Input.Zakupka;
          R_Zena:=L^.Dat.PrihodElement[i].Input.R_Zena;
          O_Zena:=L^.Dat.PrihodElement[i].Input.O_Zena;
         NSertif:=L^.Dat.PrihodElement[i].Input.NSertif;
            NGTD:=L^.Dat.PrihodElement[i].Input.NGTD;
           Marka:=L^.Dat.PrihodElement[i].Input.Marka;
      Virabotano:=L^.Dat.PrihodElement[i].Input.Virabotano;
         Godnost:=L^.Dat.PrihodElement[i].Input.Godnost;

          Akzis1:=L^.Dat.PrihodElement[i].Input.Akzis1;

          Sklad^.Dat.MakeKod:=L^.Dat.MakeKod;
          Caption:=L^.Dat.Caption;
          DelSpace(L^.Dat.PrihodElement[i].Input.Kol);
          Sklad^.Dat.Date := FDate;
          Sklad^.Dat.Time := Times;
          For k:=1 To CDivision Do
          Str((StrToInt(Division[k])+StrToInt(L^.Dat.PrihodElement[i].Input.Division[k])):CKol,Division[k]);
          Kol[0]:=#0;
        End;
        Sklad^.Dat.MakeVid:=L^.Dat.OperatorSelector;
        Sklad^.Dat.Input.Kol[0]:=#0;
        For k:=1 To CDivision Do
        Str((StrToInt(Sklad^.Dat.Input.Division[k])+StrToInt(Sklad^.Dat.Input.Kol)):CKol,Sklad^.Dat.Input.Kol);
        Sklad^.Dat.Employ:=True;

        Stalo:=Sklad^.Dat.Input.Kol;

  {сохраняем изменения}
        Seek(SkladFile,FilePos(SkladFile)-1);
        Write(SkladFile,Sklad^.Dat);
  {деблокируем позицию}

        Seek(SkladFile,FilePos(SkladFile)-1);
        If (StrToInt(Stalo)>0) And (StrToInt(Bilo)=0) Then SetIndex(Sklad^.Dat.BazKod,True);

        Repeat
         UnLock(SkladFile,FilePos(SkladFile)*SizeOf(SkladType),SizeOf(SkladType));
        Until (DosError=0);


        Close(SkladFile);{закрытие файла}
  End;
Dispose(Sklad,Done);
WritePrihodToSkladFile:=True;
End;




(*
Function WritePereozenkaToFile( L:PPereozenkaType) : Boolean;
Var PereozenkaFile : File of PereozenkaType;
          c : Byte;
Begin

 WritePereozenkaToFile:=False;
 Assign(PereozenkaFile,Path^.Dat.ToCorrect+TekDate+'.prz');
 c:=IOResult;
{$I-}
 Reset(PereozenkaFile);
 c:=IOResult;
If c<>0 Then
 Begin
  If MessageBox('Файл '+TekDate+'.prz не существует !'^M+
          'Создать такой файл ?'++' Код:'+IntToStr(c,3),nil, mfConfirmation + mfOkCancel)=cmOk Then
          Begin
                Rewrite(PereozenkaFile);
                c:=IOResult;
          End
         Else
          Begin
                Exit;
          End;
 End;
 If c <> 0 Then Begin
                                          MessageBox(#3^M+#3'Нет доступа к файлу '+TekDate+'.prz!',
                                          nil, mfError + mfOkButton);
                 Exit;
                End
 Else
  Begin
   Seek(PereozenkaFile,StrToInt(ClearChar(L^.Dat.Document))-1);
   Write(PereozenkaFile,L^.Dat);
   Close(PereozenkaFile);
   WritePereozenkaToFile:=True;
  End;
End;
*)

Function ExclusiveLockAllPosition(E:PPrihodType):Boolean;
Var l,Count : Word;
    Error : Boolean;
    Operator : Strname;
    Event : TEvent;

Begin
ExclusiveLockAllPosition:=False;
Error:=False;
For Count:=1 To E^.Dat.Amount Do
 Begin
  If Not(SetNameLock(E^.Dat.PrihodElement[Count].BazKod,Operator)) Then
   Begin
    Beep;
    DInfoMsg('Позиция ['+E^.Dat.PrihodElement[Count].BazKod+'] используется'+Operator+'. Не могу заблокировать!',
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

If Not (Error) Then ExclusiveLockAllPosition:=True;

If (Error) And (Count>1) Then
 Begin
  For l:=Count-1 DownTo 1 Do
   Begin
    Repeat
    Until SetNameUnLock(E^.Dat.PrihodElement[l].BazKod);
   End;
 End;

End;

Procedure UnLockAllPosition(E:PPrihodType);
Var L : Word;
Begin
  For l:=1 To E^.Dat.Amount Do
    Repeat
    Until SetNameUnLock(E^.Dat.PrihodElement[l].BazKod);
End;

Procedure Start(E:PPrihodType;S:String);
VAr    r : TRect;
    Find : Boolean;
       i : Word;
 Control : PView;
Begin
Find:=False;
If E^.Dat.Amount>0 Then
 Begin
  For i:=1 To E^.DAt.Amount Do
   Begin
    If Not(GetIdMArket(E^.Dat.PrihodElement[i].BazKod)=1) Then
     Begin
      Find:=True;
      Break;
     End;
   End;
 End;

 If Not(Find) Then Exit;

AddProtocol('Предупреждение о поступлении на склад закрытых к продаже позиций','','');

SpecialBeep;
R.Assign(15, 2, 65, 21);
New(TestW, Init(R, 'Внимание'));
TestW^.Options := TestW^.Options or ofCenterX or ofCenterY;
{TestW^.HelpCtx:=$E606;}
TestW^.HelpCtx:=$F012;

R.Assign(1, 1, 49, 3);
Control := New(PColoredText, Init(R, #3+S, $5e));
TestW^.Insert(Control);

R.Assign(49, 4, 50, 18);
Control := New(PScrollBar, Init(R));
TestW^.Insert(Control);

R.Assign(1, 4, 49, 18);
WarningList := New(PBox, Init(R, 1, PScrollbar(Control)));
WarningList^.NewList(New(PTextCollection, Init(0,1)));


  For i:=i To E^.DAt.Amount Do
   Begin
    If Not(GetIdMArket(E^.Dat.PrihodElement[i].BazKod)=1) Then
     Begin
      s:=GEtIdField(FNAme,E^.Dat.PrihodElement[i].BazKod);
      Format(s,CNAme);
      DelSpace(E^.Dat.PrihodElement[i].Input.Kol);
      RFormat(E^.Dat.PrihodElement[i].Input.Kol,CKol);
      DelSpace(E^.Dat.PrihodElement[i].Input.R_Zena);
      RFormat(E^.Dat.PrihodElement[i].Input.R_Zena,CZena);
      s:=s+'│'+E^.Dat.PrihodElement[i].BazKod+'│'+E^.Dat.PrihodElement[i].Input.Kol+
           '│'+E^.Dat.PrihodElement[i].Input.R_Zena;
      DelSpace(E^.Dat.PrihodElement[i].Input.Kol);
      DelSpace(E^.Dat.PrihodElement[i].Input.R_Zena);
      WarningList^.List^.Insert(NewStr(s));
      WarningList^.SetRange(WarningList^.List^.Count);
     End;
   End;
WarningList^.FocusItem(0);
TestW^.Insert(WarningList);

  R.Assign(1, 3, 48, 4);
  TestW^.Insert(New(PLabel, Init(R, 'Наименование товара         Код  Колич  Р/Цена', WarningList)));

R.Assign(14, 18, 29, 19);
Control := New(PColoredText, Init(R, ' Всего позиций:', $74));
TestW^.Insert(Control);

R.Assign(29, 18, 33, 19);
Control_Pos := New(PColoredText, Init(R, #3+IntToStr(WarningList^.List^.Count,2), $4E));
TestW^.Insert(Control_Pos);

TestW^.SelectNext(False);

DeskTop^.ExecView(TestW);
Dispose(Control,Done);
Dispose(TestW,Done);
End;

Procedure TestOpenPosition.CalcPosition;
Var R : TRect;
    KolStr : String[3];
Begin
Str(WarningList^.List^.Count:2,KolStr);
Dispose(Control_Pos,Done);
R.Assign(29, 18, 33, 19);
Control_Pos := New(PColoredText, Init(R, #3+KolStr, $4E));
TestW^.Insert(Control_Pos);
End;


Procedure TestOpenPosition.MakeReport;
Const Space='                  ';
Var Txt : Text;
    k,c : Word;
    st,s,ws : String;
Begin
 Assign(txt,Path^.Dat.ToTemp+'closepos.txt');
 c := IOResult;
 Rewrite(txt);
 c:=IoResult;
 If c<>0 Then
  Begin
   MessageBox(^M+#3+'Не могу создать файл '+Path^.Dat.ToTemp+'closepos.txt!',Nil,mfError+mfCancelButton);
   Exit;
  End;
 DInfoMsg('Формирую отчет. Ждите...',False);

 Writeln(Txt,Space+'Склад: ',GetClientField(FClient,Rek.Kod,1)+'  Оператор: '+CurrentPassword+' EYE & 1997-98');

 Writeln(txt,Space+' ПРЕДУПРЕЖДЕНИЕ О ЗАКРЫТЫХ К ПРОДАЖЕ ПОЗИЦИЯХ');
 Writeln(txt,Space+'--------------------------------------------------');
 Writeln(txt,Space+' N  Код  Наименование товара        Колич  Р/Цена');
                   {12 12345 12345678901234567890123456 12345 12345678}
 Writeln(txt,Space+'--------------------------------------------------');

If WarningList^.List^.Count>0 Then
Begin
 For c:=0 To WarningList^.List^.Count-1 Do
 Begin
    ws := WarningList^.GetText(c,WarningList^.List^.Count);
    s:= Copy(ws,1+CNAme+1,CArtikul);
    System.Delete(ws,1+CName+1,CArtikul+1);
    ws:=s+'│'+ws;

    While Pos('│',ws)>0 Do
    Begin
     k:=Pos('│',ws);
     System.Delete(ws,k,1);
     System.Insert(' ',ws,k);
    End;
    Writeln(txt,Space,(c+1):2,' ',Ws);
 End;
End;
 Writeln(txt);
 Writeln(txt,Space,'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
 Writeln(txt,Space+'==================================================');

 System.Close(txt);
 NoInfoMsg;
 Report(Path^.Dat.ToTemp+'closepos.txt','',1,False,False);
End;

Procedure TestOpenPosition.HandleEvent(Var Event:TEVent);
Var S : String;
    C : Word;
Begin
Case Event.What Of
 evCommand :
    Case Event.Command Of
        cmReestrReport:
        Begin
       If(warninglist^.State and sfFocused <> 0)And(warninglist^.List^.Count>=1) Then
        Begin
            MakeReport;
        End;
         ClearEvent(Event);
        End;
        cmAllTCh : Begin
                   If(warninglist^.State and sfFocused <> 0)And(warninglist^.List^.Count>=1) Then
                     Begin
                     If Password(2) Then
                     Begin
                     For c:=0 To WarningList^.List^.Count-1 Do
                      Begin
                       s := WarningList^.GetText(WarningList^.Focused,WarningList^.List^.Count);
                       s:= Copy(s,1+CNAme+1,CArtikul);
                       DInfoMsg('Открываю позицию ['+s+'] для продажи...',False);
                       setidmarket(s,1);
                       NoInfoMsg;
                       AddProtocol('Открытие к продаже позиции ['+s+'] '
                                            +GetIdField(Fname,s),'','');

                       WarningList^.List^.AtFree(WarningList^.Focused);
                       WarningList^.SetRange(WarningList^.List^.Count);
                       If WarningList^.Focused>0 Then
                       WarningList^.FocusItem(WarningList^.Focused);
                       If (WarningList^.Focused>=WarningList^.List^.Count) and(WarningList^.Focused>0) Then
                       WarningList^.FocusItem(WarningList^.Focused-1);
                      End;
                       CalcPosition;
                       redraw;
                     End;
                     End;
                    ClearEvent(Event);
                      End;
        CmDeblock: Begin
                   If(warninglist^.State and sfFocused <> 0)And(warninglist^.List^.Count>=1) Then
                     Begin
                     If Password(2) Then
                     Begin
                      s := WarningList^.GetText(WarningList^.Focused,WarningList^.List^.Count);
                      s:= Copy(s,1+CNAme+1,CArtikul);
                      DInfoMsg('Открываю позицию ['+s+'] для продажи...',False);
                      setidmarket(s,1);
                      NoInfoMsg;
                      AddProtocol('Открытие к продаже позиции ['+s+']'
                                            +GetIdField(Fname,s),'','');

                      WarningList^.List^.AtFree(WarningList^.Focused);
                      WarningList^.SetRange(WarningList^.List^.Count);
                      If WarningList^.Focused>0 Then
                      WarningList^.FocusItem(WarningList^.Focused);

                      If (WarningList^.Focused>=WarningList^.List^.Count) and(WarningList^.Focused>0) Then
                      WarningList^.FocusItem(WarningList^.Focused-1);
                      CalcPosition;
                      redraw;
                     End;
                     End;
                    ClearEvent(Event);
                   End;
      Else;
    End;
   Else;
   End;


inherited HandleEvent(Event);
End;

destructor TestOpenPosition.Done;
Begin
Dispose(WarningList,Done);
Dispose(Control_Pos,Done);
TDialog.Done;
End;


Procedure InputPrihodToSklad(As : DocumentEdit);
Var f : File Of PrihodType;
    E : PPrihodType;
    PereozenkaElement :PPereozenkaType;
    PereozenkaFile : File Of PereozenkaType;
    l  : LongInt;
    j,i:Byte;
    R : TRect;
    free,Find,Search,Logik,Save : Boolean;
    Event: TEvent;
    FantomBox:PBox;
Begin
 Save:=False;
 New(E,Init);
(*
 Assign(F,Path^.Dat.ToPrihod+As.D+'.prh');
 l:=IOResult;
 Reset(f);
 l:=Ioresult;
 If L <> 0 Then
  Begin
   MessageBox(#3^M+#3'Не найден файл '+Path^.Dat.ToPrihod+As.D+'.prh',Nil,mfError+mfCancelButton);
   Exit;
  End;
 New(E,Init);
 Find:=False;
 DelSpace(As.EditPosition);
 DelZerro(As.EditPosition);
 While Not(eof(f)) And Not(Find) Do
 Begin
  Read(f,E^.Dat);
  DelSpace(E^.DAt.Document);

  If (E^.DAt.Document=As.EditPosition) And (E^.DAt.DateC=As.D) Then Find:=True;
 End;

 {L:=GetFileLocation3(ClearChar(As.EditPosition));}
 If Not(Find) Then
 Begin
   Dispose(E,Done);
   Close(f);
   MessageBox(#3^M+#3'Документ прихода N '+ As.EditPosition+' в базе за '+As.D+' не найден!',Nil,mfError+mfCancelButton);
   Exit;
 End;
{
 Seek(f,L-1);
 New(E,Init);
 Read(f,E^.Dat);
}
 Close(f);
 If (E^.Dat.StatusDoc=0) Then
 Begin
 Dispose(E,Done);
 MessageBox(#3^M+#3'Документ прихода N '+As.EditPosition+' от '+As.D+''^M+
 #3'уже введен на склад!',Nil,mfError+mfCancelButton);
 Exit;
 End;
*)

    i:=Lockprihod(As,E);
    If I=3 Then
     Begin
      DinfoMsg('Не могу заблокировать док-т прихода N '+E^.Dat.Document+' от '+E^.Dat.DateC+
         '. Попробуйте повторить!',False);
      Dispose(E,Done);
      Beep;
      Application^.ClearEvent(Event);
      Application^.GetEvent(Event);
      Application^.ClearEvent(Event);
      repeat
        Application^.GetEvent(Event);
      until (Event.What <> evNothing) And (Event.Command<>cmMenu);
      NoInfoMsg;
      Application^.ClearEvent(Event);
      Exit;
     End;
    If I<>0 Then
     Begin
      Dispose(E,Done);
      Exit;
     End;

    If Not(SetClientLock(E^.Dat.MakeKod,1,E^.Dat.OperatorSelector)) Then
     Begin
      Repeat
      Until (UnLockPrihod(E^.Dat.Document,E^.Dat.DateC) in [0,2]);
      Sound(100);
      DinfoMsg('Не могу заблокировать поставщика '+E^.Dat.MAkeKod+'! Попробуйте повторить!',False);
                NoSound;
      Application^.ClearEvent(Event);
      Application^.GetEvent(Event);
      Application^.ClearEvent(Event);
      repeat
        Application^.GetEvent(Event);
      until (Event.What <> evNothing) And (Event.Command<>cmMenu);
      NoInfoMsg;
      Application^.ClearEvent(Event);
      Exit;
     End;



If Not(ExclusiveLockAllPosition(E)) Then
     Begin
      Repeat
      Until (UnLockPrihod(E^.Dat.Document,E^.Dat.DateC) in [0,2]);
      Repeat
      Until (SetClientUnLock(E^.Dat.MakeKod,1,E^.Dat.OperatorSelector));
      Dispose(E,Done);
      Exit;
     End;

R.Assign(0,0,0,0);
FantomBox := New(PBox, Init(R, 1, Nil));
FantomBox^.NewList(New(PTextCollection, Init(0,1)));

If FindFantom(E,FAntomBox) Then
     Begin
      Dispose(FantomBox,Done);
      Save:=False;
      UnLockAllPosition(E);
      Repeat
      Until (UnLockPrihod(E^.Dat.Document,E^.Dat.DateC) in [0,2]);
      Repeat
      Until (SetClientUnLock(E^.Dat.MakeKod,1,E^.Dat.OperatorSelector));
      Dispose(E,Done);
      Exit;
     End;

Dispose(FantomBox,Done);

If E^.Dat.OperatorSelector=2 Then
Begin
If Not(Password(2)) Then
    Begin
        Save:=False;
        UnLockAllPosition(E);
        Repeat
        Until (UnLockPrihod(E^.Dat.Document,E^.Dat.DateC) in [0,2]);
        Repeat
        Until (SetClientUnLock(E^.Dat.MakeKod,1,E^.Dat.OperatorSelector));
        Dispose(E,Done);
        MessageBox(#3'Ваш уровень доступа не позволяет проводить'+
           ' поступление товара на склад для приходов по взаимозачету!',Nil,mfError+mfCancelButton);
        Exit;
    End;
End;{OperatorSelector}

E^.Dat.StatusDoc:=0;
New(PereozenkaElement,Init);
PereozenkaElement^.Dat.DateM:=FDate;
PereozenkaElement^.Dat.TimeM:=Times;
PereozenkaElement^.Dat.DateC:=FDate;
PereozenkaElement^.Dat.TimeC:=Times;
PereozenkaElement^.Dat.Vid:=As.Vid;{надо исправит для случая возврата и прихода}

j:=1;
Logik:=True;
Search:=False;
For i:=1 To E^.DAt.Amount Do
 Begin
  If ((StrToReal(E^.Dat.PrihodElement[i].Input.R_Zena)<>StrToReal(BakGetField(FRZena,E^.Dat.PrihodElement[i].Bazkod,0)))Or
                (StrToReal(E^.Dat.PrihodElement[i].Input.O_Zena)<>StrToReal(BakGetField(FOZena,E^.Dat.PrihodElement[i].Bazkod,0))))
{  And(StrToInt(BakGetField(FKol,E^.Dat.PrihodElement[i].BazKod,0))>0)} Then
        Begin
         If (StrToInt(BakGetField(FKol,E^.Dat.PrihodElement[i].BazKod,0))>0) Then
         Begin
         Logik:=False;
         Search:=True;
         End;
         PereozenkaElement^.Dat.Element[j].BazKod:=E^.Dat.PrihodElement[i].BazKod;
         PereozenkaElement^.Dat.Element[j].Kol:=BakGetField(FKol,E^.Dat.PrihodElement[i].BazKod,0);
         PereozenkaElement^.Dat.Element[j].Bak_R_Zena:=BakGetField(FRZena,E^.Dat.PrihodElement[i].BazKod,0);
         PereozenkaElement^.Dat.Element[j].Bak_O_Zena:=BakGetField(FOZena,E^.Dat.PrihodElement[i].BazKod,0);
         PereozenkaElement^.Dat.Element[j].New_R_Zena:=E^.Dat.PrihodElement[i].Input.R_Zena;
         PereozenkaElement^.Dat.Element[j].New_O_Zena:=E^.Dat.PrihodElement[i].Input.O_Zena;
{   PereozenkaElement^.Dat.Sklad:=Rek.SkladsName;}
         PereozenkaElement^.Dat.Caption := CurrentPassword;
         MyStr(
         StrToInt(
         BakGetField(FKol,E^.Dat.PrihodElement[i].BazKod,0))*StrToReal(BakGetField(FRZena,E^.Dat.PrihodElement[i].BazKod,0))+
          StrToReal(PereozenkaElement^.Dat.Itogo_Bak_R_Zena),CIZena,CMantissa
         ,PereozenkaElement^.Dat.Itogo_Bak_R_Zena);
         DelSpace(PereozenkaElement^.Dat.Itogo_Bak_R_Zena);
         MyStr(
         StrToInt(
         BakGetField(FKol,E^.Dat.PrihodElement[i].BazKod,0))*StrToReal(BakGetField(FOZena,E^.Dat.PrihodElement[i].BazKod,0))+
          StrToReal(PereozenkaElement^.Dat.Itogo_Bak_O_Zena),CIZena,CMantissa
         ,PereozenkaElement^.Dat.Itogo_Bak_O_Zena);
         DelSpace(PereozenkaElement^.Dat.Itogo_Bak_O_Zena);
         MyStr(StrToInt(BakGetField(FKol,E^.Dat.PrihodElement[i].BazKod,0))*StrToReal(E^.Dat.PrihodElement[i].Input.R_Zena)+
          StrToReal(PereozenkaElement^.Dat.Itogo_New_R_Zena),CIZena,CMantissa
         ,PereozenkaElement^.Dat.Itogo_New_R_Zena);
         DelSpace(PereozenkaElement^.Dat.Itogo_New_R_Zena);
         MyStr(StrToInt(BakGetField(FKol,E^.Dat.PrihodElement[i].BazKod,0))*StrToReal(E^.Dat.PrihodElement[i].Input.O_Zena)+
          StrToReal(PereozenkaElement^.Dat.Itogo_New_O_Zena),CIZena,CMantissa
         ,PereozenkaElement^.Dat.Itogo_New_O_Zena);
         DelSpace(PereozenkaElement^.Dat.Itogo_New_O_Zena);
         E^.Dat.PrihodElement[i].Input.Auto:=True;
         Inc(j);
         Inc(PereozenkaElement^.Dat.Amount);
        End;
 End;
         MyStr(StrToReal(PereozenkaElement^.Dat.Itogo_New_R_Zena)-StrToReal(PereozenkaElement^.Dat.Itogo_Bak_R_Zena),
         CIZena,CMantissa
         ,PereozenkaElement^.Dat.Delta_RZ);
         DelSpace(PereozenkaElement^.Dat.Delta_RZ);
         MyStr(StrToReal(PereozenkaElement^.Dat.Itogo_New_O_Zena)-StrToReal(PereozenkaElement^.Dat.Itogo_Bak_O_Zena),
         CIZena,CMantissa
         ,PereozenkaElement^.Dat.Delta_OZ);
         DelSpace(PereozenkaElement^.Dat.Delta_OZ);
{конец Цикла проверки возможности автоматической переоценки}

Start(E,'Вы оприходывали товар на склад, однако'+
                                                  ' на складе следующие позиции запрещены к продаже!');

         Assign(PereozenkaFile,Path^.Dat.ToCorrect+TekDate+'.prz');
         i:=IOResult;
         Reset(Pereozenkafile);
         i:=IOResult;
         If I <> 0 Then
         Begin
  If MessageBox(#3'Файл переоценки '+TekDate+'.prz не найден!'^M+
          'Создаю файл ? Если вы раньше что-либо переоценили позовите программиста!'
                  +' Код:'+IntToStr(i,3),nil, mfConfirmation + mfOkCancel)=cmOk  Then
          Begin
{      i:=Ioresult;
                Reset(PereozenkaFile);
                i:=Ioresult;
                If I<>0 Then Rewrite(PereozenkaFile);}
                If Not(CreatToDayF(DocPereozen,TekDate)) Then
                         Begin
                  Save:=False;
                  UnLockAllPosition(E);
                  Repeat
                  Until (UnLockPrihod(E^.Dat.Document,E^.Dat.DateC) in [0,2]);
                  Repeat
                  Until (SetClientUnLock(E^.Dat.MakeKod,1,E^.Dat.OperatorSelector));
                  Dispose(E,Done);
                  Dispose(PereozenkaElement,Done);
                          Exit;
                 end;
                Reset(PereozenkaFile);
                i:=IOResult;
          End
         Else
          Begin
                Save:=False;
                UnLockAllPosition(E);
                Repeat
                Until (UnLockPrihod(E^.Dat.Document,E^.Dat.DateC) in [0,2]);
                Repeat
                Until (SetClientUnLock(E^.Dat.MakeKod,1,E^.Dat.OperatorSelector));

                Dispose(E,Done);
                Dispose(PereozenkaElement,Done);
                Exit;
          End;
         End;{I<>0}
  PereozenkaElement^.Dat.Document:=InttoStr(FileSize(PereozenkaFile)+1,CDocNumer);
  System.Close(PereozenkaFile);
  E^.Dat.DocumentPrz:=PereozenkaElement^.Dat.Document;

  free:=false;

If E^.Dat.OperatorSelector=2 Then
  Begin
        Save:=CreatClientBArterFile(E^.Dat.MAkeKod);
        If Not(Save) Then
         Begin
                Save:=FAlse;
                UnLockAllPosition(E);
                Repeat
                Until (UnLockPrihod(E^.Dat.Document,E^.Dat.DateC) in [0,2]);
                Repeat
                Until (SetClientUnLock(E^.Dat.MakeKod,1,E^.Dat.OperatorSelector));
                Dispose(E,Done);
                Dispose(PereozenkaElement,Done);
                Exit;
         End;
  End;


If {J>1}PereozenkaElement^.Dat.Amount>0 Then {если нужна переоценка, тогда запрос на экран}
  Begin
{   Logik:=False;}
  If Not(UseDocNumer(DocPereozen,TekDate,PereozenkaElement^.Dat.Document)) Then
  Begin
         Save:=False;
         UnLockAllPosition(E);
         Repeat
         Until (UnLockPrihod(E^.Dat.Document,E^.Dat.DateC) in [0,2]);
         Repeat
         Until (SetClientUnLock(E^.Dat.MakeKod,1,E^.Dat.OperatorSelector));
         Dispose(E,Done);
         Dispose(PereozenkaElement,Done);
         Exit;
  End;
         If Not(Logik) Then
                 Logik:=Zapros(PereozenkaElement,{j-1}PereozenkaElement^.Dat.Amount)
                 Else
                 Logik:=True;

         If Logik Then
          Begin
                j:=E^.DAt.Amount;
                Save:=LockAndWritePrihod(E,True);
 {записываем статистику}
 If Save Then
 If (E^.Dat.OperatorSelector=2) Then
  Begin
         Save:=SaveToBarterPrihodFile(E);
         If Not(Save) Then
         Begin
                Save:=FAlse;
                UnLockAllPosition(E);
                Repeat
                Until (UnLockPrihod(E^.Dat.Document,E^.Dat.DateC) in [0,2]);
                Repeat
                Until (SetClientUnLock(E^.Dat.MakeKod,1,E^.Dat.OperatorSelector));
                Dispose(E,Done);
                Dispose(PereozenkaElement,Done);
                Exit;
         End;
  End;
 {конец запись статистики}

                Repeat
                Until (UnLockPrihod(E^.Dat.Document,E^.Dat.DateC) in [0,2]);

                Repeat
                Until (SetClientUnLock(E^.Dat.MakeKod,1,E^.Dat.OperatorSelector));

{     If Not(Save) Then
                Begin
                  Repeat
                  Until (FreeDocNumer(Docpereozen,TekDate,PereozenkaElement^.Dat.Document));
                  free:=True;
                End;}

                If Save Then Save:=WritePrihodToSkladFile(E);

                If Not(Save) Then
                 Begin
{       If Not(Free) Then
                  Repeat
                  Until (FreeDocNumer(Docpereozen,TekDate,PereozenkaElement^.Dat.Document));}
                  UnLockAllPosition(E);
                  Dispose(E,Done);
                  Dispose(PereozenkaElement,Done);
                  Exit;
                 End;

                If Save Then Save:=LockAndWritePereozenka(PereozenkaElement)
                Else
        Begin
{
                        If Not(Free) Then
                        Repeat
                        Until (FreeDocNumer(Docpereozen,TekDate,PereozenkaElement^.Dat.Document));
}
        End;
      If Save Then
                 Begin
                 If MessageBox(#3^M+#3'Накладная прихода введена на склад !'^M+
                 #3'Печатать накладную прихода ?',Nil,mfConfirmation+mfOkCancel)=cmOk Then
                  Begin
                   As.D:=TekDate;
                   As.EditPosition:=E^.Dat.Document;
                   PrintPrihod(As);
                  End;

              If Search Then
                 If MessageBox(#3^M+#3'Печатать акт переоценки ?',Nil,mfConfirmation+mfOkCancel)=cmOk Then
                  Begin
                   As.D:=TekDate;
                   As.EditPosition:=E^.Dat.DocumentPrz;
                   PrintAktPrz(As);
                  End;
                   AddProtocol('Ввод накладной прихода N '+E^.Dat.Document+' от '+TekDate+' на склад','','');
                 End;
     End
     Else Begin
           Save:=False;
           Repeat
           Until (UnLockPrihod(E^.Dat.Document,E^.Dat.DateC) in [0,2]);
           Repeat
           Until (SetClientUnLock(E^.Dat.MakeKod,1,E^.Dat.OperatorSelector));
          End;
{         If Not(Free) Then
           Repeat
           Until (FreeDocNumer(Docpereozen,TekDate,PereozenkaElement^.Dat.Document));}
   Dispose(PereozenkaElement,Done);
  End{конец если переоценка}
  Else{если нет переоценки}
   Begin
   Dispose(PereozenkaElement,Done);
   Save:=LockAndWritePrihod(E,True);

 {записываем статистику}
 If Save Then
 If (E^.Dat.OperatorSelector=2) Then
  Begin
    Save:=SaveToBarterPrihodFile(E);
    If Not(Save) Then
    Begin
      Save:=FAlse;
      UnLockAllPosition(E);
      Repeat
      Until (UnLockPrihod(E^.Dat.Document,E^.Dat.DateC) in [0,2]);
      Repeat
      Until (SetClientUnLock(E^.Dat.MakeKod,1,E^.Dat.OperatorSelector));
      Dispose(E,Done);
      Dispose(PereozenkaElement,Done);
      Exit;
    End;
  End;
 {конец запись статистики}

   Repeat
   Until (UnLockPrihod(E^.Dat.Document,E^.Dat.DateC) in [0,2]);

   Repeat
   Until (SetClientUnLock(E^.Dat.MakeKod,1,E^.Dat.OperatorSelector));

   If Save Then Save:=WritePrihodToSkladFile(E);
   If Save Then
                 Begin
                 If MessageBox(#3^M+#3'Накладная прихода введена на склад !'^M+
                 #3'Печатать накладную прихода ?',Nil,mfConfirmation+mfOkCancel)=cmOk Then
                  Begin
                   As.D:=TekDate;
                   As.EditPosition:=E^.Dat.Document;
                   PrintPrihod(As);
                  End;
                   AddProtocol('Ввод накладной прихода N '+E^.Dat.Document+' от '+TekDate+' на склад','','');
                 End;
   End;
UnLockAllPosition(E);
Dispose(E,Done);
End;


Procedure TPrihodWindow.DrawFullName;
Var S: String;
    R : TRect;
    SArt : ArtikulStr;
Begin
if (NewToVar^.State and sfFocused <> 0)  Then
Begin
{If (NewToVar^.List^.Count>0) Then}
If (NewToVAr^.List<>Nil)And(NewTovar^.List^.Count>=1) Then
Begin
s:=NewToVar^.GetText(NewToVar^.Focused,NewToVar^.List^.Count);
If s<>PrevName Then
Begin
 PrevName:=s;
 Sart:=Copy(s,1+CName+1,CArtikul);
 Dispose(ControlFullName,Done);
 R.Assign(22, 12, 79, 13);
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
 R.Assign(22, 12, 79, 13);
 s:=' ';
 ControlFullName := New(PColoredText, Init(R, s, $7e));
 Insert(ControlFullName);
  End;
End;

if (Baz^.State and sfFocused <> 0)  Then
Begin
{If (Baz^.List^.Count>0) Then}
If (BAz^.List<>Nil)And(Baz^.List^.Count>=1) Then
Begin
s:=Baz^.GetText(Baz^.Focused,Baz^.List^.Count);
If s<>PrevName Then
Begin
 PrevName:=s;
 Sart:=Copy(s,1+CName+1,CArtikul);
 Dispose(ControlFullName,Done);
 R.Assign(22, 12, 79, 13);
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
        R.Assign(22, 12, 79, 13);
        s:=' ';
        ControlFullName := New(PColoredText, Init(R, s, $7e));
        Insert(ControlFullName);
  End;
End;

if (Baz^.State and sfFocused = 0) And (NewToVar^.State and sfFocused = 0) Then
 Begin
  PrevName[0]:=#0;
  Dispose(ControlFullName,Done);
  R.Assign(22, 12, 79, 13);
  s:=' ';
  ControlFullName := New(PColoredText, Init(R, s, $7e));
  Insert(ControlFullName);
 End;

End;



Procedure TPrihodWindow.SaveToFilePr(Var Save : Boolean);
Var
         L : PPrihodType;
    PereozenkaElement : PPereozenkaType;
    PereozenkaFile : File of PereozenkaType;
    I : Byte;
    J : Word;
    s : String;
    st : String[CAll];
    As : DocumentEdit;
 TempPrihod : PBox;
    R : TRect;
    Logik : Boolean;
Begin
Save:=False;

New(L,Init);{:=TestPr;}

{чтение с экрана прихода}
If NewTovar^.List^.Count>0 Then
Begin
{создаем промежуточный список}
R.Assign(0,0,0,0);
TempPrihod := New(PBox, Init(R, 1, Nil));
TempPrihod^.NewList(New(PTextCollection, Init(1,1)));


For i:=0 To NewTovar^.List^.Count-1 Do
 Begin
  s:=NewTovar^.GetText(i,NewTovar^.List^.Limit);
  st:=Copy(s,1+CName+1,CRazdelKod);
  System.Delete(s,1+CName+1,CRazdelKod);
  System.Insert(st+'│',s,1);
  TempPrihod^.List^.Insert(NewStr(S));
  TempPrihod^.SetRange(TempPrihod^.List^.Count);
 End;

For i:=0 To TempPrihod{NewTovar}^.List^.Count-1 Do
 Begin
  s:=TempPrihod{NewTovar}^.GetText(i,{NewTovar}TempPrihod^.List^.Limit);
  With L^.Dat.PrihodElement[i+1].Input Do
        Begin
         Kol:=Copy(s,1+CRazdelKod+1+CName+1+(CArtikul-CRazdelKod)+1+CLitr+1+CInPack+1,CKol);
         DelSpace(Kol);
         R_Zena:=Copy(s,1+CRazdelKod+1+CName+1+(CArtikul-CRazdelKod)+1+CLitr+1+CInPack+1+CKol+1,CZena);
         DelSpace(R_Zena);
         O_Zena:=Copy(s,1+CRazdelKod+1+CName+1+(CArtikul-CRazdelKod)+1+CLitr+1+CInPack+1+CKol+1+CZena+1,CZena);
         DelSpace(O_Zena);
         NSertif:=Copy(s,1+CRazdelKod+1+CName+1+(CArtikul-CRazdelKod)+1+CLitr+1+CInPack+1+CKol+1+CZena+1+CZena+1,CArtikul);

         Akzis1:=Copy(s,1+CRazdelKod+1+CName+1+(CArtikul-CRazdelKod)+1+CLitr+1+CInPack+1+CKol+1+CZena+1+CZena+1+CArtikul+1,
         CAkzis1);

         Zakupka:=Copy(s,1+CRazdelKod+1+CName+1+(CArtikul-CRazdelKod)+1+CLitr+1+CInPack+1+CKol+1+CZena+1+CZena+1+
         CArtikul+1+CAkzis1+1,CZena);
         DelSpace(Zakupka);

         For j:=1 To CDivision Do
         Begin
          Division[j]:=Copy(s,1+CRazdelKod+1+CName+1+(CArtikul-CRazdelKod)+1+CLitr+1+CInPack+1+CKol+1+CZena+1+CZena+
          1+CArtikul+1+CAkzis1+1+CZena+1+CKol*(j-1){+1*(j-1)},CKol);
          DelSpace(Division[j]);
         End;
         Post:=Copy(s,1+CRazdelKod+1+CName+1+(CArtikul-CRazdelKod)+1+CLitr+1+CInPack+1+CKol+1+CZena+1+CZena+
                1+CArtikul+1+CAkzis1+1+Czena+1+CKol*(CDivision),CPost);

         DelSpaceRight(Post);

        End;
        st:=Copy(s,1,CRazdelKod);
        L^.Dat.PrihodElement[i+1].BazKod:=Copy(s,1+CName+1+CRazdelKod+1,CArtikul-CRazdelKod);
        L^.Dat.PrihodElement[i+1].BazKod:=st+L^.Dat.PrihodElement[i+1].BazKod;

        L^.Dat.PrihodElement[i+1].Input.NGTD:=GetNGTD(L^.Dat.PrihodElement[i+1].BazKod);
        DelSpaceRight(L^.Dat.PrihodElement[i+1].Input.NGTD);
        L^.Dat.PrihodElement[i+1].Input.Marka:=GetMarka(L^.Dat.PrihodElement[i+1].BazKod);
        DelSpaceRight(L^.Dat.PrihodElement[i+1].Input.Marka);
        L^.Dat.PrihodElement[i+1].Input.Virabotano:=GetVirabotano(L^.Dat.PrihodElement[i+1].BazKod);
        DelSpaceRight(L^.Dat.PrihodElement[i+1].Input.Virabotano);
        L^.Dat.PrihodElement[i+1].Input.Godnost:=GetGodnost(L^.Dat.PrihodElement[i+1].BazKod);
        DelSpaceRight(L^.Dat.PrihodElement[i+1].Input.Godnost);

{  If Status = DocEdit Then L^.Dat.PrihodElement[i+1].Input.Auto:=PrevPrihod^.Dat.PrihodElement[i+1].Input.Auto;}
 End;
Dispose(TempPrihod,Done);
End;
{ L.Document:=DocumentNumer;}
 ControlOperatorSelect^.GetData(L^.Dat.OperatorSelector);
 L^.Dat.Caption:=CurrentPassword;
 PStaticText(ControlClient)^.GetText(S);
 System.Delete(S,Pos(#3,S),1);
 L^.Dat.MakeKod:=Copy(S,1+CMake+1,CMakeKod);
 PStaticText(ControlDoc)^.GetText(s);
 DelSpace(S);
 System.Delete(S,Pos(#3,S),1);
 L^.Dat.Document:=s;
 PStaticText(Control_Litr)^.GetText(L^.Dat.SummaL);
 DelSpace(L^.Dat.SummaL);
 System.Delete(L^.Dat.SummaL,Pos(#3,L^.Dat.SummaL),1);
 PStaticText(Control_IR)^.GetText(L^.Dat.SummaR);
 DelSpace(L^.Dat.SummaR);
 System.Delete(L^.Dat.SummaR,Pos(#3,L^.Dat.SummaR),1);
 PStaticText(Control_IO)^.GetText(L^.Dat.SummaO);
 DelSpace(L^.Dat.SummaO);
 System.Delete(L^.Dat.SummaO,Pos(#3,L^.Dat.SummaO),1);

 L^.Dat.SummaZakupka:=AllZakupka;
 DelSpace(L^.Dat.SummaZakupka);

{ L^.Dat.Sklad:=Rek.SkladsName;}
 L^.Dat.Caption:=CurrentPassword;
 L^.Dat.DateM:=FDate;
 L^.Dat.TimeM:=Times;
 If Status=DocNormal Then
 Begin
 L^.Dat.DateC:=FDate;
 L^.Dat.TimeC:=Times;
 End
 Else
  Begin
 L^.Dat.DateC:=PrevPrihod^.Dat.DateC;
 L^.Dat.TimeC:=PrevPrihod^.Dat.TimeC;
  End;

 L^.Dat.Amount:=NewTovar^.List^.Count;
 L^.Dat.StatusDoc:=1;
{прочитали с экрана приход}


{Цикл проверки возможности автоматической переоценки}
New(PereozenkaElement,Init);
PereozenkaElement^.Dat.DateM:=FDate;
PereozenkaElement^.Dat.TimeM:=Times;
PereozenkaElement^.Dat.DateC:=FDate;
PereozenkaElement^.Dat.TimeC:=Times;
PereozenkaElement^.Dat.Vid:=0;

j:=1;
Logik := True;
For i:=1 To NewTovar^.List^.Count Do
 Begin
  If ((StrToReal(L^.Dat.PrihodElement[i].Input.R_Zena)<>StrToReal(BakGetField(FRZena,L^.Dat.PrihodElement[i].Bazkod,0)))Or
                (StrToReal(L^.Dat.PrihodElement[i].Input.O_Zena)<>StrToReal(BakGetField(FOZena,L^.Dat.PrihodElement[i].Bazkod,0))))
  {And(StrToInt(BakGetField(FKol,L^.Dat.PrihodElement[i].BazKod,0))>0)} Then
        Begin
If (StrToInt(BakGetField(FKol,L^.Dat.PrihodElement[i].BazKod,0))>0) Then
          Logik:= False;
         PereozenkaElement^.Dat.Element[j].BazKod:=L^.Dat.PrihodElement[i].BazKod;
         PereozenkaElement^.Dat.Element[j].Kol:=BakGetField(FKol,L^.Dat.PrihodElement[i].BazKod,0);
         PereozenkaElement^.Dat.Element[j].Bak_R_Zena:=BakGetField(FRZena,L^.Dat.PrihodElement[i].BazKod,0);
         PereozenkaElement^.Dat.Element[j].Bak_O_Zena:=BakGetField(FOZena,L^.Dat.PrihodElement[i].BazKod,0);
         PereozenkaElement^.Dat.Element[j].New_R_Zena:=L^.Dat.PrihodElement[i].Input.R_Zena;
         PereozenkaElement^.Dat.Element[j].New_O_Zena:=L^.Dat.PrihodElement[i].Input.O_Zena;
{    PereozenkaElement^.Dat.Sklad:=Rek.SkladsName;}
         PereozenkaElement^.Dat.Caption := CurrentPassword;

         MyStr(StrToInt(BakGetField(FKol,L^.Dat.PrihodElement[i].BazKod,0))*StrToReal(BakGetField(
         FRZena,L^.Dat.PrihodElement[i].BazKod,0))+
          StrToReal(PereozenkaElement^.Dat.Itogo_Bak_R_Zena),CIZena,CMantissa
         ,PereozenkaElement^.Dat.Itogo_Bak_R_Zena);

         DelSpace(PereozenkaElement^.Dat.Itogo_Bak_R_Zena);
         MyStr(StrToInt(BakGetField(
         FKol,L^.Dat.PrihodElement[i].BazKod,0))*StrToReal(BakGetField(FOZena,L^.Dat.PrihodElement[i].BazKod,0))+
          StrToReal(PereozenkaElement^.Dat.Itogo_Bak_O_Zena),CIZena,CMantissa
         ,PereozenkaElement^.Dat.Itogo_Bak_O_Zena);
         DelSpace(PereozenkaElement^.Dat.Itogo_Bak_O_Zena);
         MyStr(StrToInt(BakGetField(FKol,L^.Dat.PrihodElement[i].BazKod,0))*StrToReal(L^.Dat.PrihodElement[i].Input.R_Zena)+
          StrToReal(PereozenkaElement^.Dat.Itogo_New_R_Zena),CIZena,CMantissa
         ,PereozenkaElement^.Dat.Itogo_New_R_Zena);
         DelSpace(PereozenkaElement^.Dat.Itogo_New_R_Zena);
         MyStr(StrToInt(BakGetField(FKol,L^.Dat.PrihodElement[i].BazKod,0))*StrToReal(L^.Dat.PrihodElement[i].Input.O_Zena)+
          StrToReal(PereozenkaElement^.Dat.Itogo_New_O_Zena),CIZena,CMantissa
         ,PereozenkaElement^.Dat.Itogo_New_O_Zena);
         DelSpace(PereozenkaElement^.Dat.Itogo_New_O_Zena);
         L^.Dat.PrihodElement[i].Input.Auto:=True;
         Inc(j);
         Inc(PereozenkaElement^.Dat.Amount);
        End;
 End;
         MyStr(StrToReal(PereozenkaElement^.Dat.Itogo_New_R_Zena)-StrToReal(PereozenkaElement^.Dat.Itogo_Bak_R_Zena),
         CIZena,CMantissa
         ,PereozenkaElement^.Dat.Delta_RZ);
         DelSpace(PereozenkaElement^.Dat.Delta_RZ);
         MyStr(StrToReal(PereozenkaElement^.Dat.Itogo_New_O_Zena)-StrToReal(PereozenkaElement^.Dat.Itogo_Bak_O_Zena),
         CIZena,CMantissa
         ,PereozenkaElement^.Dat.Delta_OZ);
         DelSpace(PereozenkaElement^.Dat.Delta_OZ);
{конец Цикла проверки возможности автоматической переоценки}

         Assign(PereozenkaFile,Path^.Dat.ToCorrect+TekDate+'.prz');
         i:=IOResult;
         Reset(Pereozenkafile);
         i:=IOResult;
         If I <> 0 Then
         Begin
  If MessageBox(#3'Файл переоценки '+TekDate+'.prz не найден!'^M+
          'Создаю файл? Если вы раньше что-либо переоценили позовите программиста!'
                  +' Код:'+IntToStr(i,3),nil, mfConfirmation + mfOkCancel)=cmOk  Then
          Begin
{     i:=Ioresult;
                Reset(PereozenkaFile);
                i:=Ioresult;
                If I<>0 Then Rewrite(PereozenkaFile);}
                If Not(CreatToDayF(DocPereozen,TekDate)) Then Exit;
                Reset(PereozenkaFile);
                i:=IOResult;
          End
         Else
          Begin
                Save:=False;
                Dispose(l,Done);
                Dispose(PereozenkaElement,Done);
                Exit;
          End;
         End;{I<>0}
  PereozenkaElement^.Dat.Document:=InttoStr(FileSize(PereozenkaFile)+1,CDocNumer);
  System.Close(PereozenkaFile);
  L^.Dat.DocumentPrz:=PereozenkaElement^.Dat.Document;



If {J>1}PereozenkaElement^.Dat.Amount>0 Then {если нужна переоценка, тогда запрос на экран}
  Begin
         {Logik:=False;}

  If Not(UseDocNumer(DocPereozen,TekDate,PereozenkaElement^.Dat.Document)) Then
        Begin
         Save:=False;
         Dispose(L,Done);
         Dispose(PereozenkaElement,Done);
         Exit;
        End;
{ убрал потому что пока номер не забирается окончательно
        Repeat
        Until (FreeDocNumer(Docpereozen,TekDate,PereozenkaElement^.Dat.Document));

}
         If Not(Logik) Then
                 Logik:=Zapros(PereozenkaElement,{j-1}PereozenkaElement^.Dat.Amount)
                 Else
                 Logik:=True;

         If Logik Then
          Begin
                j:=NewTovar^.List^.Count;
                Save:=LockAndWritePrihod(L,False);

                {деблокировка накладной возврата
                 накладная деблокируется здесь только в случае удачной записи}
                If Save Then
                Repeat
                Until (UnLockPrihod(L^.Dat.Document,L^.Dat.DateC) in [0,2]);

                If Not(Save) Then
                 Begin
                  Dispose(l,Done);
                  Dispose(PereozenkaElement,Done);
                  Exit;
                 End;

                If Save Then
                                          Begin
                                          If Status=DocNormal Then
                                          AddProtocol('Формирование накладной прихода N '+L^.Dat.Document+' от '+TekDate,'','')
                                          Else
                                          AddProtocol('Корректировка накладной прихода N '+L^.Dat.Document+' от '+TekDate,'','');
                                          If MessageBox(#3^M+#3'Накладная прихода сформирована !'^M+
                                          #3'Печатать накладную прихода ?',Nil,mfConfirmation+mfOkCancel)=cmOk Then
                                                Begin
                                                 As.D:=TekDate;
                                                 As.EditPosition:=L^.Dat.Document;
                                                 PrintPrihod(As);
                                                End;
                                          End;
          End
          Else Save:=False;
        Dispose(PereozenkaElement,Done);
  End{конец если переоценка}
  Else{если нет переоценки}
        Begin
        Dispose(PereozenkaElement,Done);
        Save:=LockAndWritePrihod(L,False);

        if save then
        Repeat
        Until (UnLockPrihod(L^.Dat.Document,L^.Dat.DateC) in [0,2]);


                If Not(Save) Then
                 Begin
        Dispose(l,Done);
        Exit;
                 End;

        If Save Then
                 Begin
                 If Status=DocNormal Then
                 AddProtocol('Формирование накладной прихода N '+L^.Dat.Document+' от '+TekDate,'','')
                 Else
                 AddProtocol('Корректировка накладной прихода N '+L^.Dat.Document+' от '+TekDate,'','');
                 If MessageBox(#3^M+#3'Накладная прихода сформирована !'^M+
                 #3'Печатать накладную прихода ?',Nil,mfConfirmation+mfOkCancel)=cmOk Then
                  Begin
                        As.D:=TekDate;
                        As.EditPosition:=L^.Dat.Document;
                        PrintPrihod(As);
                  End;
                 End;
        End;
Dispose(l,Done);
End;


Procedure DrawPack;
Var s: String[CPack];
         R : TRect;
         i : Byte;
Begin
         CartWin^.GetData(Input);
         InPut.Kol[0]:=#0;
         For i:=1 To CDivision Do
         Str(StrToInt(InPut.Division[i])+StrToInt(Input.Kol),Input.Kol);
         DelSpace(Input.Kol);

         Dispose(ControlKol,Done);
         R.Assign(8, 6, 13, 7);
         ControlKol := New(PStaticText, Init(R, #3+Input.Kol));
         CartWin^.Insert(ControlKol);

         s:=CalcPack(sArtikul,input.kol);
         DelSpace(s);
         Dispose(ControlPack,Done);
         R.Assign(23, 6, 32, 7);
         ControlPack := New(PColoredText, Init(R, #3+s, $3E));
         CartWin^.Insert(ControlPack);
End;


Procedure DrawOpt;
Var s: String[CPack];
         R : TRect;
Begin
         CartWin^.GetData(Input);
         s:=GetIdField(FLitr,sArtikul);
         If StrToReal(Input.R_Zena)+Lizensia*StrToReal(GetIdField(FLitr,sArtikul))> CMaxZena Then
         Begin
         s[0]:=#0;
         ControlOZ^.SetData(s);
         End
         Else
         Begin
         MyStr(StrToReal(Input.R_Zena)+Lizensia*StrToReal(GetIdField(FLitr,sArtikul)),CZena,CMantissa,s);
         DelSpace(S);
         InPut.O_Zena:=S;
         COntrolOZ^.SetData(Input.O_Zena);
         End;
End;




Procedure TCartWindow.Ini(Var s:String;Regim:Word);
Label 1;
var
  R : TRect;
  c: Word;
  Control : PView;
  TekKol,zap,SNAlog,WS,SName,SName2,SLitr,SKol,
  SSertif,SAkzis,SInPack: String[CAll];
  Zen : TDateString;
  Kkol : ArtikulStr;
  As : DocumentEdit;
  ClientKod : ArtikulStr;
  St,St2 : TMyString;
  SMsg : TMyString;
  s1 : String;
  l,Test : LongInt;
  PositionGTD : Word;
  SertifCod:ArtikulStr;

Begin
SName:=Copy(S,1,CName);
SArtikul:=Copy(S,1+CName+1,CArtikul);
SNAlog:=GetIdField(FNAlog,SArtikul);
SLitr:=GetIdField(FLitr,SArtikul);
SInPack:=GetIdField(FInPack,SArtikul);
SNAme2:=GetIDField(FNAme2,SArtikul);
TekKol:=BAkGetField(FKol,SArtikul,0);
DelSpaceRight(SName2);


Case Regim Of
0:Begin
  Input.Zakupka:=BakGetField(FZakupka,SArtikul,0);
  Input.Akzis1:=BakGetField(FAkzis,SArtikul,0);
  Input.NSertif:=BakGetField(FNSertif,SArtikul,0);
  SertifCod:=Input.NSertif;
  Input.NGtd:=BakGetField(FNGTD,SArtikul,0);

  NSertif:=BakGetField(FNSertif,SArtikul,0);
  SertifCod:=NSertif;
  st:=BakGetField(FNAme,NSertif,0);
  st2:=BakGetField(FNAme2,NSertif,0);
  St:=St+' '+St2;
  Format(St,CNAme+1+CNAme);
  NSertif:=St+'│'+NSertif;


  Input.Marka:=BakGetField(FMarka,SArtikul,0);
  Input.Virabotano:=BakGetField(FVirabotano,SArtikul,0);
  Input.Godnost:=BakGetField(FGodnost,SArtikul,0);

  Input.Post:=BakGetField(FPost,SArtikul,0);
  DelSpaceRight(Input.Post);

  Input.R_Zena:=BakGetField(FRZena,SArtikul,0);
  Input.O_Zena:=BakGetField(FOZena,SArtikul,0);
  Input.Kol[0]:=#0;
         For c:=1 To CDivision Do
         Begin
         Input.Division[c,0]:=#0;
         DelSpace(Input.Division[c]);
         End;
  End;
1:Begin
  With Input Do
        Begin
         NGTD := GetNGTD(sartikul);
         Marka := GetMarka(sartikul);
         Virabotano := GetVirabotano(sartikul);
         Godnost := GetGodnost(sartikul);
         Zakupka:=Copy(s,1+CName+1+CArtikul+1+CLitr+1+CInPack+1+CKol+1+CZena+1+CZena+1+CArtikul+1+CAkzis1+1,
         CZena);
         Akzis1:=Copy(s,1+CName+1+CArtikul+1+CLitr+1+CInPack+1+CKol+1+CZena+1+CZena+1+CArtikul+1,CAkzis1);
         input.NSertif:=Copy(s,1+CName+1+CArtikul+1+CLitr+1+CInPack+1+CKol+1+CZena+1+CZena+1,CArtikul);
         SertifCod:=Input.NSertif;
         Prihod.NSertif:=SertifCod;
         st:=GetIdField(FNAme,Prihod.NSertif);
         st2:=GetIdField(FNAme2,Prihod.NSertif);
         St:=St+' '+St2;
         Format(St,CNAme+1+CNAme);
         Prihod.NSertif:=St+'│'+Prihod.NSertif;

         R_Zena:=Copy(s,1+CName+1+CArtikul+1+CLitr+1+CInPack+1+CKol+1,CZena);
         O_Zena:=Copy(s,1+CName+1+CArtikul+1+CLitr+1+CInPack+1+CKol+1+CZena+1,CZena);

         For c:=1 To CDivision Do
         Begin
         Division[c]:=Copy(s,1+CName+1+CArtikul+1+CLitr+1+CInPack+1+CKol+1+CZena+1+CZena+
         1+CArtikul+1+CAkzis1+1+CZena+1+CKol*(c-1),CKol);
         DelSpace(Division[c]);
         End;
          Post:=Copy(s,1+CName+1+CArtikul+1+CLitr+1+CInPack+1+CKol+1+CZena+1+CZena+
                1+CArtikul+1+CAkzis1+1+Czena+1+CKol*CDiviSion,CPost);
          Kol:=Copy(s,1+CName+1+CArtikul+1+CLitr+1+CInPack+1,CKol);
        End;
        DelSpaceRight(Input.Post);
  End;
  Else;
  End;

  Input.Zakupka:=RealToStr(StrToReal(Input.Zakupka),CZena,CMantissa);
  Input.R_Zena:=RealToStr(StrToReal(Input.R_Zena),CZena,CMantissa);
  Input.O_Zena:=RealToStr(StrToReal(Input.O_Zena),CZena,CMantissa);


DelSPace(SNalog);

DelSPace(Input.Zakupka);
DelSPace(Input.R_Zena);
DelSPace(Input.O_Zena);
DelSPace(Input.Kol);

DelSpaceRight(Input.NSertif);
DelSpaceRight(Input.NGTD);
DelSpaceRight(Input.Marka);

DelSpace(Input.Virabotano);
DelSpace(Input.Godnost);
DelSpaceRight(Input.Akzis1);
ClearFind;


1:
DInfo('Читаю информацию о товаре...');
If Not GetRazdelStatus(SArtikul) Then
R.Assign(0, 10, 80, 22)
Else
R.Assign(0, 15, 80, 22);
New(CartWin, Init(R, 'Карточка товара'));
CartWin^.Palette := dpCyanDialog;
CartWin^.Options := CartWin^.Options or ofCenterX;
CartWin^.HelpCtx := $E191;

R.Assign(29, 4, 36, 5);
Control1 := New(PInputLine, Init(R, CKol));
Control1^.SetData(Input.Division[1]);
CartWin^.Insert(Control1);
  PInputLine(Control1)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0']));

  R.Assign(26, 4, 29, 5);
  CartWin^.Insert(New(PLabel, Init(R, '~1~:', Control1)));

R.Assign(30, 3, 35, 4);
Control := New(PColoredText, Init(R, BakGetField(FDiv,SArtikul,1), $31));
CartWin^.Insert(Control);


R.Assign(39, 4, 46, 5);
Control2 := New(PInputLine, Init(R, CKol));
If GetRazdelStatus(SArtikul) Then Control2^.Options := Control2^.Options and not ofSelectable;
Control2^.SetData(Input.Division[2]);
CartWin^.Insert(Control2);
  PInputLine(Control2)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0']));

  R.Assign(36, 4, 39, 5);
  CartWin^.Insert(New(PLabel, Init(R, '~2~:', Control2)));

R.Assign(40, 3, 45, 4);
Control := New(PColoredText, Init(R, BakGetField(FDiv,SArtikul,2), $31));
CartWin^.Insert(Control);


R.Assign(49, 4, 56, 5);
Control3 := New(PInputLine, Init(R, CKol));
If GetRazdelStatus(SArtikul) Then Control3^.Options := Control3^.Options and not ofSelectable;
Control3^.SetData(Input.Division[3]);
CartWin^.Insert(Control3);
  PInputLine(Control3)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0']));

  R.Assign(46, 4, 49, 5);
  CartWin^.Insert(New(PLabel, Init(R, '~3~:', Control3)));

R.Assign(50, 3, 55, 4);
Control := New(PColoredText, Init(R, BakGetField(FDiv,SArtikul,3), $31));
CartWin^.Insert(Control);


R.Assign(59, 4, 66, 5);
Control4 := New(PInputLine, Init(R, CKol));
If GetRazdelStatus(SArtikul) Then Control4^.Options := Control4^.Options and not ofSelectable;
Control4^.SetData(Input.Division[4]);
CartWin^.Insert(Control4);
  PInputLine(Control4)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0']));

  R.Assign(56, 4, 59, 5);
  CartWin^.Insert(New(PLabel, Init(R, '~4~:', Control4)));

R.Assign(60, 3, 65, 4);
Control := New(PColoredText, Init(R, BakGetField(FDiv,SArtikul,4), $31));
CartWin^.Insert(Control);


R.Assign(69, 4, 76, 5);
Control5 := New(PInputLine, Init(R, CKol));
Control5^.SetData(Input.Division[5]);
If StrToInt(CurrentPassword)<>0 Then
  Control5^.Options := Control5^.Options and not ofSelectable;
If GetRazdelStatus(SArtikul) Then Control5^.Options := Control5^.Options and not ofSelectable;

CartWin^.Insert(Control5);
  PInputLine(Control5)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0']));

  R.Assign(66, 4, 69, 5);
  CartWin^.Insert(New(PLabel, Init(R, '~5~:', Control5)));

R.Assign(70, 3, 75, 4);
Control := New(PColoredText, Init(R, BakGetField(FDiv,SArtikul,5), $31));
CartWin^.Insert(Control);


R.Assign(38, 6, 48, 7);
if (strtoint(currentpassword)=0) Or (OperatorSelector=2) Or ((EnableZakupka=1)) then
begin
ControlZakupka := New(PREalInputLine, Init(R, CZena));
ControlZakupka^.SetData(Input.Zakupka);
end
 else
  begin
  ControlZakupka := New(PSInputLine, Init(R, CZena));
  ControlZakupka^.SetData(Input.Zakupka);
  ControlZakupka^.Options := ControlZakupka^.Options and not ofSelectable;
  end;
CartWin^.Insert(ControlZakupka);

  R.Assign(33, 6, 38, 7);
  CartWin^.Insert(New(PLabel, Init(R, '~З~/Ц:', ControlZakupka)));

R.Assign(53, 6, 63, 7);
R_ZenaControl := New(PRealInputLine, Init(R, CZena));
R_ZenaControl^.SetData(Input.R_Zena);
CartWin^.Insert(R_ZenaControl);


  R.Assign(48, 6, 53, 7);
  CartWin^.Insert(New(PLabel, Init(R, '~Р~/Ц:', R_ZenaControl)));

R.Assign(68, 6, 78, 7);
ControlOZ := New(PRealInputLine, Init(R, CZena));
ControlOZ^.SetData(Input.O_Zena);
CartWin^.Insert(ControlOZ);


  R.Assign(63, 6, 68, 7);
  CartWin^.Insert(New(PLabel, Init(R, '~О~/Ц:', ControlOZ)));


R.Assign(8, 7, 47, 8);
ControlNGTDL := New(PInputLine, Init(R, CNSertif));
ControlNGTDL^.SetDAta(Input.NGTD);
If GetRazdelStatus(SArtikul) Then
ControlNGTDL^.Options := ControlNGTDL^.Options and not ofSelectable;
CartWin^.Insert(ControlNGTDL);
If Not GetRazdelStatus(SArtikul) Then
Begin
  R.Assign(47, 7, 50, 8);
  CartWin^.Insert(New(PHistory, Init(R, PInputline(ControlNGTDL), 102)));
End;
  R.Assign(1, 7, 8, 8);
  CartWin^.Insert(New(PLabel, Init(R, 'N ~Г~ТД:', ControlNGTDL)));


R.Assign(59, 7, 76, 8);
ControlPostL := New(PInputLine, Init(R, CPost));
ControlPostL^.SetDAta(Input.Post);
If GetRazdelStatus(SArtikul) Then
ControlPostL^.Options := ControlPostL^.Options and not ofSelectable;
CartWin^.Insert(ControlPostL);

  R.Assign(76, 7, 79, 8);
  CartWin^.Insert(New(PHistory, Init(R, PInputline(ControlPostL), 99)));

  R.Assign(50, 7, 59, 8);
  CartWin^.Insert(New(PLabel, Init(R, 'Произв.:', ControlPostL)));


R.Assign(8, 8, 32, 9);
ControlA := New(PInputLine, Init(R, CNSertif));
ControlA^.SetDAta(Input.Marka);
If GetRazdelStatus(SArtikul) Then
ControlA^.Options := ControlA^.Options and not ofSelectable;
CartWin^.Insert(ControlA);

If Not GetRazdelStatus(SArtikul) Then
Begin
  R.Assign(32, 8, 35, 9);
  CartWin^.Insert(New(PHistory, Init(R, PInputline(ControlA), 101)));
End;

  R.Assign(1, 8, 8, 9);
  CartWin^.Insert(New(PLabel, Init(R, 'Ак~ц~из:', ControlA)));

R.Assign(47, 8, 57, 9);
ControlData := New(PInputLine, Init(R, CDate));
ControlData^.SetDAta(Input.Virabotano);
If GetRazdelStatus(SArtikul) Then
ControlData^.Options := ControlData^.Options and not ofSelectable;
CartWin^.Insert(ControlData);
  PInputLine(ControlData)^.Validator := New(PPXPictureValidator, Init(DateFiltr, True));

  R.Assign(35, 8, 47, 9);
  CartWin^.Insert(New(PLabel, Init(R, 'В~ы~работано:', ControlData)));

R.Assign(68, 8, 78, 9);
ControlDo := New(PInputLine, Init(R, CDate));
ControlDo^.SetDAta(Input.Godnost);
If GetRazdelStatus(SArtikul) Then
ControlDo^.Options := ControlDo^.Options and not ofSelectable;
CartWin^.Insert(ControlDo);
  PInputLine(ControlDo)^.Validator := New(PPXPictureValidator, Init(DateFiltr, True));

  R.Assign(57, 8, 68, 9);
  CartWin^.Insert(New(PLabel, Init(R, 'Реа~л~из.до:', ControlDo)));

R.Assign(37, 9, 57, 10);
ControllAkzis := New(PInputLine, Init(R, CAkzis1));
ControllAkzis^.SetDAta(Input.Akzis1);
If GetRazdelStatus(SArtikul) Then
ControllAkzis^.Options := ControllAkzis^.Options and not ofSelectable;
CartWin^.Insert(ControllAkzis);

  R.Assign(25, 9, 37, 10);
  CartWin^.Insert(New(PLabel, Init(R, '~П~римечание:', ControllAkzis)));


If Not GetRazdelStatus(SArtikul) Then
BEgin
R.Assign(17, 10, 78, 11);
ControlLSertif := New(PColoredText, Init(R, #3+NSertif, $1F));
ControlLSertif^.Options := ControlLsertif^.Options Or ofSelectable;
End
Else
Begin
R.Assign(1, 7, 79, 11);
ControlLSertif := New(PColoredText, Init(R, #3+NSertif, $33));
End;
CartWin^.Insert(ControlLSertif);

If Not GetRazdelStatus(SArtikul) Then
BEgin
  R.Assign(5, 10, 17, 11);
  CartWin^.Insert(New(PLabel, Init(R, 'Серти~ф~икат:', ControlLSertif)));
End;



R.Assign(1, 1, 79, 2);
Control := New(PStaticText, Init(R, 'Наименование:'+SName+' Код:'+SArtikul+' Литраж:'+SLitr+' Фас:'+SInPack+
' НП:'+SNAlog));
CartWin^.Insert(Control);

DelSpaceRight(SNAme2);
If SNAme2[0]<>#0 Then
 Begin
  R.Assign(14, 2, 40, 3);
  Control := New(PStaticText, Init(R, SName2));
  CartWin^.Insert(Control);
 End;

R.Assign(14, 6, 23, 7);
Control := New(PColoredText, Init(R, 'Упаковок:', $31));
CartWin^.Insert(Control);

R.Assign(23, 6, 32, 7);
ControlPack := New(PStaticText, Init(R, #3+'0'));
CartWin^.Insert(ControlPack);

R.Assign(3, 3, 25, 4);
Control := New(PStaticText, Init(R, 'Имеется по отделениям:'));
CartWin^.Insert(Control);

R.Assign(3, 4, 24, 5);
Control := New(PStaticText, Init(R, 'Пришло по отделениям:'));
CartWin^.Insert(Control);

R.Assign(1, 6, 8, 7);
Control := New(PColoredText, Init(R, 'Кол-во:', $31));
CartWin^.Insert(Control);

R.Assign(8, 6, 13, 7);
ControlKol := New(PStaticText, Init(R, #3+'0'));
CartWin^.Insert(ControlKol);

R.Assign(5, 5, 20, 6);
Control := New(PColoredText, Init(R, '┌─── Всего ───┐', $31));
CartWin^.Insert(Control);


R.Assign(58, 0, 78, 1);
If GetIdMArket(SArtikul)=1 Then
Control := New(PColoredText, Init(R, 'Продажа: разрешена', $3F))
Else
Control := New(PColoredText, Init(R, 'Продажа: запрещена', $DF));

CartWin^.Insert(Control);


R.Assign(1, 0, 25, 1);
If GetIdDebit(SArtikul)=1 Then
Control := New(PColoredText, Init(R, 'Консигнация: разрешена', $3F))
Else
Control := New(PColoredText, Init(R, 'Консигнация: запрещена', $DF));
CartWin^.Insert(Control);

CartWin^.SelectNext(False);

{CartWin^.SetData(Input);}

NoInfo;

DrawPack;

{If Status = DocNormal Then DrawOpt;}
c:=Desktop^.ExecView(CartWin);
If c<>cmCancel Then
 Begin

  Control1^.GetData(Input.Division[1]);
  Control2^.GetData(Input.Division[2]);
  Control3^.GetData(Input.Division[3]);
  Control4^.GetData(Input.Division[4]);
  Control5^.GetData(Input.Division[5]);
  ControLZakupka^.GetData(Input.Zakupka);
  R_ZenaControl^.GetData(Input.R_Zena);
  ControlOZ^.GetData(Input.O_Zena);

  ControlNGTDL^.GetData(Input.NGTD);
  ControlPostL^.GetData(Input.Post);
  ControlA^.GetData(Input.Marka);
  ControlData^.GetData(Input.Virabotano);
  ControlDo^.GetData(Input.Godnost);
  ControllAkzis^.GetData(Input.Akzis1);

  PStaticText(ControlLSertif)^.GetText(NSertif);
  System.Delete(NSertif,1,1);
  Input.NSertif:=Copy(NSertif,1+CNAme+1+CNAme+1,CArtikul);


  Dispose(Control,Done);
  Dispose(CartWin,Done);

  DelSpaceRight(Input.NSertif);

  DelSpaceRight(Input.NGTD);
  DelSpaceRight(Input.Marka);
  DelSpace(Input.Virabotano);
  DelSpace(Input.Godnost);

  DelSpaceRight(NSertif);

If GetRazdelStatus(SArtikul) Then
 Begin
  Input.NSertif:=Glob.NoSertifStr;
 End;




  MyStr(StrToReal(Input.R_Zena),CZena,CMantissa,Input.R_Zena);
  DelSpace(Input.R_Zena);
  MyStr(StrToReal(Input.Zakupka),CZena,CMantissa,Input.Zakupka);
  DelSpace(Input.Zakupka);
  MyStr(StrToReal(Input.O_Zena),CZena,CMantissa,Input.O_Zena);
  DelSpace(Input.O_Zena);
{  SMakeList:=MakeList^.GetText(MakeList^.Focused,Makelist^.List^.Count);}
{Временно
   s:=Input.Sertifikat;
    DelSpace(s);
   If (s[0]=#0)Then
   Begin
    MessageBox(#3+NoSertif,nil, mfWarning + mfCancelButton);
   End;
        s:=Input.Post;
    DelSpace(s);
        If (s[0]=#0)Then
        Begin
         MessageBox(#3+NoPost,nil, mfWarning + mfCancelButton);
        End;
        s:=Input.Akzis;
        DelSpace(s);
  If (s[0]=#0) Then
        Begin
         MessageBox(#3+NoAkzis,nil, mfWarning + mfCancelButton);
        End;
}
        s[0]:=#0;
        For c:=1 To CDivision Do
         Str(StrToInt(InPut.Division[c])+StrToInt(S),S);
         DelSpace(S);
  If (StrToInt(s)> CMaxKol) Then
        Begin
          MessageBox('Слишком большое количество товара'^M+
                                         'Попробуйте оприходывать его в разные позиции! ',nil, mfError + mfCancelButton);
          GoTo 1;
        End;
        Input.Kol:=S;


  If (Input.Kol[0]=#0) Or (StrTOInt(Input.Kol)=0) Then
        Begin
         MessageBox(#3+NullKol,nil, mfError + mfCancelButton);
         {Goto 1;}
        End;
  If (StrToInt(BakGetField(FKol,SArtikul,0))+(StrTOInt(Input.Kol))> CMaxKol) Then
        Begin
          MessageBox('Слишком большое количество товара'^M+
                                         'Попробуйте оприходывать его в другую позицию! ',nil, mfError + mfCancelButton);
          GoTo 1;
        End;

        MyStr(StrToReal(Input.Zakupka),CZena,CMantissa,Input.Zakupka);
        DelSpace(Input.Zakupka);

  If (StrTOReal(Input.Zakupka)>CMaxZena)Then
        Begin
          MessageBox(#3+ErrorZakupka,nil, mfError + mfCancelButton);
          GoTo 1;
        End;

  If (StrTOReal(Input.Zakupka)<0.009) And (OperatorSelector=2) Then
        Begin
          MessageBox(#3+ErrorZakupka,nil, mfError + mfCancelButton);
          GoTo 1;
        End;

  If (Input.R_Zena[0]=#0) Or (StrTOReal(Input.R_Zena)>CMaxZena)Or(StrTOReal(Input.R_Zena)=0.0) Then
        Begin
          MessageBox(#3+ErrorRZena,nil, mfError + mfCancelButton);
          GoTo 1;
        End;

  If (Input.O_Zena[0]=#0) Or (StrTOReal(Input.O_Zena)>CMaxZena)Or(StrTOReal(Input.O_Zena)=0.0) Then
        Begin
          MessageBox(#3+ErrorOZena,nil, mfError + mfCancelButton);
          GoTo 1;
        End;

  If (StrToReal(Input.R_Zena)<>StrTOReal(Input.O_Zena)) Then
   Begin
     MessageBox(#3^M+#3+'Розничная цена не равна оптовой !',nil, mfError + mfCancelButton);
     GoTo 1;
   End;

  If (OperatorSelector=2) Then
  If (StrToReal(Input.Zakupka)>StrTOReal(Input.R_Zena)) Then
   Begin
     SpecialBeep;
     MessageBox(#3^M+#3+'Закупочная цена больше продажной !',nil, mfError + mfCancelButton);
     GoTo 1;
   End;

{@@
   DelSpace(Input.DSertif);

   If (Input.DSertif[0]<>#0) Then
   Begin
   If Not(TestDate(Input.DSertif,Test)) Then
    Begin
     MessageBox(^M+#3'Ошибка при вводе срока действия сертификата!',Nil,mfError+mfCancelButton);
     Goto 1;
    End;
   If Not(DateStringToDate(DateMask,Input.DSertif)>DateStringToDate(DateMask,FDate)) Then
    Begin
     MessageBox(^M+#3'Истек срок действия сертификата!',Nil,mfError+mfCancelButton);
    End;
   End
   Else
     MessageBox(^M+#3'Не указан срок действия сертификата!',Nil,mfError+mfCancelButton);
}

        {проверка даты производства и срока реализации}
        DelSpace(Input.Virabotano);
        DelSpace(Input.Godnost);

If Not GetRazdelStatus(SArtikul) Then
BEgin
        If (Input.Virabotano[0]<>#0) Then
        Begin
        If Not(TestDate(Input.Virabotano,Test)) Then
         Begin
          MessageBox(^M+#3'Ошибка при вводе даты выработки (разлива)!',Nil,mfError+mfCancelButton);
          Goto 1;
         End;
        End
        Else
         If Input.Godnost[0]=#0 Then
          MessageBox(^M+#3'Не указана дата выработки (разлива)!',Nil,mfError+mfCancelButton);

        If (Input.Godnost[0]<>#0) Then
        Begin
        If Not(TestDate(Input.Godnost,Test)) Then
         Begin
          MessageBox(^M+#3'Ошибка при вводе даты реализации!',Nil,mfError+mfCancelButton);
          Goto 1;
         End;
        End
        Else
         If Input.Virabotano[0]=#0 Then
          MessageBox(^M+#3'Не указана дата реализации продукции!',Nil,mfError+mfCancelButton);
End;
        {конец проверки}


        Format(SInpack,CInPack);
  s1:=SArtikul+'│';
  s:=SName+'│'+SArtikul+'│'+SLitr+'│'+SInPack+'│';
  With Input Do
        Begin
        Format(Kol,CKol);
        Format(Zakupka,CZena);
        Format(R_Zena,CZena);
        Format(O_Zena,CZena);

        Format(Marka,CNSertif);
        Format(Virabotano,CDate);
        Format(Godnost,CDate);
        Format(NGTD,CNSertif);
        Format(NSertif,CArtikul);
{@@
        Format(DSertif,CDSertif);
        Format(KSertif,CKSertif);
}
        Format(Akzis1,CAkzis1);

{   s:=s+Kol+'│'+R_Zena+'│'+O_Zena+'│'+Sertifikat+'│'+Akzis+'│'+Zakupka+'│';}
        s:=s+Kol+'│'+R_Zena+'│'+O_Zena+'│'+NSertif+'│'+Akzis1+'│'+Zakupka+'│';

        For c:=1 To CDivision Do
         Begin
          Input.Division[c]:=InttoStr(StrToInt(Input.Division[c]),CKol);
          Format(Input.Division[c],CKol);
          s:=s+Input.Division[c]{+'│'};
         End;
        End;
(*   System.Delete(s,236,1);{удаление последнего разделителя }*)
        DelSpaceRight(Input.Post);
        ChekPost(Input.Post);
        DelSpaceRight(Input.NGTD);
        DelSpaceRight(Input.Marka);

        ChekAddStr(Input.Marka,1);
        ChekAddStr(Input.NGTD,2);

        Format(Input.Marka,CNSertif);
        Format(Input.NGTD,CNSertif);

        Format(Input.Post,CPost);
        s:=s+Input.Post;
        s1:=s1+Input.NGTD+'│'+Input.Marka+'│'+Input.Virabotano+'│'+Input.Godnost;

        If Regim=1 Then
         Begin
          NewTovar^.List^.AtFree(NewTovar^.Focused);
          NewTovar^.SetRange(NewTovar^.List^.Count);

          GTD^.List^.AtFree(Location(GTD,SArtikul,True));
          GTD^.SetRange(GTD^.List^.Count);
         End;

        NewTovar^.List^.Insert(NewStr(S));
        NewTovar^.SetRange(NewTovar^.List^.Count);
        NewTovar^.FocusItem(LoCation(NewTovar,SArtikul,ProdagaWindow));

        GTD^.List^.Insert(NewStr(S1));
        GTD^.SetRange(GTD^.List^.Count);
 End
 Else
 Begin
  Dispose(Control,Done);
  Dispose(CartWin,Done);
 End;
End;

Destructor TCartWinDow.Done;
Begin
{Dispose(ControlKol,Done);
Dispose(ControlZakupka,Done);
Dispose(ControlNGTDL,Done);
Dispose(ControlPostL,Done);
Dispose(ControlA,Done);
Dispose(ControlLink,Done);
Dispose(ControlData,Done);
Dispose(ControlSrokDo,Done);
Dispose(ControlDo,Done);
Dispose(ControlLAkzis,Done);
Dispose(ControlKSertif,Done);
Dispose(ControlLSertif,Done);

Dispose(R_ZenaControl,Done);
Dispose(ControlOZ,Done);
Dispose(ControlPack,Done);}

TDialog.Done;
End;


procedure TCartWindow.HandleEvent(var Event: TEvent);
{
procedure Calculator;
Var Control : PDialog;
begin
  control:=New(PCalculator, Init);
  Desktop^.Execview(Control);
  Dispose(Control,Done);
end;
}

procedure Calculator;
begin
  Calc^.Start;
end;

Var DrawP : Boolean;
    s : String;
    Test : Word;
    R : TRect;
    Art : ArtikulStr;

Begin
Case Event.What Of
 evCommand :
   Case Event.Command Of
        cmLocalCalc:Calculator;
   cmSelectSertif : Begin
  If (PView(SertifWin)<>Desktop^.TopView)And(ControlLSertif^.State and sfFocused <> 0) Then
  Begin
     PStaticText(ControlLSertif)^.GetText(S);
     System.Delete(S,1,1);
     SertifWin^.ShowSertifList(s,Test);
     PStaticText(ControlLSertif)^.Text^:=#3+S;

     Case Test Of
      0,3 :FocusNext(True);
      1,2 :FocusNext(False);
     Else;
          End;

     Art:=Copy(S,1+CNAme+1+CNAme+1,CArtikul);

     If StrToInt(Copy(S,1+CNAme+1+CNAme+1,CArtikul))=Glob.NoSertif{85000} Then
      Begin
(*     Input.EnableLink:=0;
       ControlLink^.SetData(Input.EnableLink);
       Dispose(ControlLSertif,Done);
       R.Assign(17, 10, 78, 11);
       ControlLSertif := New(PColoredText, Init(R, #3+s, $13));
       ControlLSertif^.Options := ControlLsertif^.Options and not ofSelectable;
       CartWin^.Insert(ControlLSertif);*)
       If GetRazdelStatus(SArtikul) Then
        Begin
         ControlSrokDo^.Options := ControlSrokDo^.Options and not ofSelectable;
         ControlKSertif^.Options := ControlKsertif^.Options and not ofSelectable;
        End;

      End;
     Redraw;

     ClearEvent(Event);
  End
  Else
   ClearEvent(Event);
 End;
   Else;
   End;
   Else;
   End;

  If (Event.What=evKeyboard)And((Event.CharCode in ['0','1','2','3','4','5','6','7','8','9','.'])
  Or (Event.KeyCode=kbDel) Or (Event.KeyCode=kbBack)){And(Status=DocNormal)}
  And (R_ZenaConTrol^.State and sfFocused <> 0) Then
  Begin
  Inherited HandleEvent(Event);
  DrawOpt;
  End
  Else
  Begin
  If (Event.What=evKeyboard)And((Event.CharCode in ['0','1','2','3','4','5','6','7','8','9'])
  Or (Event.KeyCode=kbDel) Or (Event.KeyCode=kbBack)) Then DrawP:=True
  Else DrawP:=False;

 If (PView(SertifWin)<>Desktop^.TopView)And(ControlLSertif^.State and sfFocused <> 0)
 And (Event.Command<>cmSelectSertif) And (Event.What <> EvKeyDown)Then
            Begin
             Event.What:=EvCommand;
             Event.Command:=cmSelectSertif;
             PutEvent(Event);
             ClearEvent(Event);
            End;


  inherited HandleEvent(Event);

  If DrawP Then Begin
                 If (Control1^.State and sfFocused <> 0) Or
                    (Control2^.State and sfFocused <> 0) Or
                    (Control3^.State and sfFocused <> 0) Or
                    (Control4^.State and sfFocused <> 0) Or
                    (Control5^.State and sfFocused <> 0) Then DrawPack;
                End;
  End;
(*
 If (Desktop^.Current=PView(CartWin)) And (Event.What <> EvKeyDown) Then

          if (ControlLink^.State and sfFocused <> 0)Then
              Begin
               ControlLink^.GetData(Test);
               If Test <> Input.EnableLink Then
               Begin
                  Input.EnableLink:=Test;
                  If Test=1 Then
                     Begin
                      PStaticText(ControlLSertif)^.GetText(S);
                      Dispose(ControlLSertif,Done);
                      R.Assign(17, 10, 78, 11);
                      ControlLSertif := New(PColoredText, Init(R, s, $1F));
                      ControlLSertif^.Options := ControlLsertif^.Options Or ofSelectable;
                      CartWin^.Insert(ControlLSertif);
                     End
                     Else
                     Begin
                      PStaticText(ControlLSertif)^.GetText(S);
                      Dispose(ControlLSertif,Done);
                      R.Assign(17, 10, 78, 11);
                      ControlLSertif := New(PColoredText, Init(R, s, $13));
                      ControlLSertif^.Options := ControlLsertif^.Options and not ofSelectable;
                                                         CartWin^.Insert(ControlLSertif);

                      If GetRazdelStatus(SArtikul) Then
                      Begin
                       ControlSrokDo^.Options := ControlSrokDo^.Options and not ofSelectable;
                       ControlKSertif^.Options := ControlKsertif^.Options and not ofSelectable;
                      End
                     End;
                  Redraw;
               End;
              End;
*)


  ClearEvent(Event);
End;



procedure TPrihodWindow.OpenPrihodWindow;
Var l : Boolean;
begin
  l:=False;
  ClearFind;
  if Message(Desktop, evBroadcast, cmPrihod, nil) = nil then
  begin
    DInfo('Инициализация прихода...');
    L:=True;
    PrihodWindow := New(PPrihodWindow, Init(L));
    If L Then
    Begin
    Application^.InsertWindow(PrihodWindow);
    NoInfo;
    End
    Else
     Begin
      TekDAte:=FDate;
      Status:=DocNormal;
      Dispose(PrihodWindow,Done);
      NoInfo;
     End;
  end
  else
    if PView(PrihodWindow) <> Desktop^.TopView then PrihodWindow^.Select;
end;

constructor TPrihodWindow.Init(Var l : Boolean);
var
  R : TRect;
  Control : PView;
  C : Word;
  DocumentNumer : TDateString;
  PrihodFile : File Of PrihodType;
  VozwratFile : File Of VozwratType;
  s: String;
  ws : TDateString;
  i : Byte;
  s1,s2 : String;
  SName : String[CName];
  SLitr : String[CLitr];
  SPack : String[CInPack];
  Event : TEvent;

begin

 R.Assign(0, 0, 80, 23);
If Status=DocNormal Then PrevS:='Регистрация прихода'
Else PrevS:='Коррекция прихода';

inherited Init(R, PrevS);
Options := Options or ofCenterX or ofCenterY;
HelpCtx:=$E011;
L:=False;

If Not(TestOpenDate1(TekDate)) Then
   Begin
    MessageBox(#3^M+#3'Доступ к данным за '+TekDate+' заблокирован!',Nil,mfError+mfCancelButton);
    TekDate:=FDate;
    Exit;
   End;
ClearFind;

If (GlobalReadOnly=1) Or (ReadOnlyConst=1) Then
   Begin
    MessageBox(#3^M+ReadOnlyStr^,Nil,mfWarning+mfCancelButton);
    TekDate:=FDate;
    Exit;
   End;
ClearFind;



If Not(TestSetupKurs(TekDate)) Then
   Begin
    {MessageBox(#3^M+#3'Не установлен курс USD на '+TekDate+'!',Nil,mfError+mfCancelButton);}
    TekDate:=FDAte;
    Exit;
   End;
ClearFind;


  C:=IOResult;
  Assign(PrihodFile,Path^.Dat.ToPrihod+TekDate+'.prh');
  Reset(PrihodFile);
  C:=IOResult;
  If C<>0 Then
        Begin
         If MessageBox(#3'Файл прихода за '+TekDate+' не найден'^M+
         #3'Если Вы ранее что-то оприходывали'^M+
         #3'немедленно позовите программиста'^M+
         #3'Создавать файл прихода?'+
         +' Код:'+IntToStr(c,3),Nil, mfWarning+mfOkCancel)=cmOk Then
         Begin
{     i:=Ioresult;
                Reset(PrihodFile);
                i:=Ioresult;
                If I<>0 Then Rewrite(PrihodFile);}
                If Not(CreatToDayF(DocPrihod,TekDate)) Then Exit;
                Reset(PrihodFile);
                i:=IOResult;
         End
         Else
         Exit;
        End;
  System.Close(PrihodFile);
  If Status=DocNormal Then
  Begin
        If Not(UseDocNumer(DocPrihod,TekDate,DocumentNumer)) Then Exit;
  End
  Else
        Begin
         New(Prevprihod,Init);

         i:=Lockprihod(Assistent,PrevPrihod);
         If I=3 Then
          Begin
      Beep;
      DinfoMsg('Не могу заблокировать док-т прихода N '+PrevPrihod^.Dat.Document+' от '+PrevPrihod^.Dat.DateC+
         '. Попробуйте повторить!',False);
      Dispose(PrevPrihod,Done);
      ClearEvent(Event);
      Application^.GetEvent(Event);
      ClearEvent(Event);
      repeat
        Application^.GetEvent(Event);
     until (Event.What <> evNothing) And (Event.Command<>cmMenu);

      NoInfoMsg;
      ClearEvent(Event);
      Exit;
     End;

    If I<>0 Then
     Begin
      Dispose(PrevPrihod,Done);
      Exit;
     End;
    DocumentNumer:=PrevPrihod^.Dat.Document;

  If (EnableBarter=0)And(PrevPrihod^.Dat.OperatorSelector=2) Then
   Begin
    Repeat
    Until (UnLockPrihod(PrevPrihod^.Dat.Document,PrevPrihod^.Dat.DateC) in [0,2]);
    Dispose(PrevPrihod,Done);
    MessageBox(^m+#3'Операции этого вида на Вашем складе запрещены!',Nil,mfError+mfCancelButton);
    l:=False;
    Exit;
   End;


   End;

R.Assign(56, 0, 79, 1);
ControlOperatorSelect := New(PRadioButtons, Init(R,
  NewSItem('К~л~',
  NewSItem('С',
  NewSItem('~О~б', Nil)))));

If (EnableBarter=0) Then
PCluster(ControlOperatorSelect)^.SetButtonState($00000004, False);
  Insert(ControlOperatorSelect);

  Insert(ControlOperatorSelect);

If Status=DocEdit Then OperatorSelector:=PrevPrihod^.Dat.OperatorSelector
Else OperatorSelector:=0;

ControlOperatorSelect^.SetData(OperatorSelector);

  R.Assign(51, 0, 56, 1);
  Insert(New(PLabel, Init(R, 'Вид:', ControlOperatorSelect)));

R.Assign(0, 0, 0, 0);
Client := New(PBox, Init(R, 1, Nil));
Client^.NewList(New(PTextCollection, Init(1,1)));

Case OperatorSelector Of
0:Assign (MakeFile,Path^.Dat.ToClient+'Make.db');
1:Assign (MakeFile,Path^.Dat.ToClient+'Sklad.db');
2:Assign (MakeFile,Path^.Dat.ToClient+'Barter.db');
Else;
End;
{
If OperatorSelector=0 Then
Assign (MakeFile,Path^.Dat.ToClient+'Make.db')
Else
Assign (MakeFile,Path^.Dat.ToClient+'Sklad.db');
}

I:=IOResult;
Reset (MakeFile);
I:=IOResult;
If i=0 Then
Begin
While Not(Eof(MakeFile)) Do
 Begin
     {
     Repeat
     Until NetCall.Lock(MakeFile,FilePos(MakeFile)*SizeOf(ClientType),SizeOf(ClientType));
     }
          ReadMAke(MakeFile,MakeElement);
          {
     Repeat
      NetCall.UnLock(MakeFile,(FilePos(MakeFile)-1)*SizeOf(ClientType),SizeOf(ClientType));
     Until (DosError=0);
     }
  If MakeElement.Employ Then
   Begin
    Format (MakeElement.Name,CClient);
    Client^.List^.Insert(NewStr(MakeElement.Name+'│'+MakeElement.Kod));
    Client^.SetRange(Client^.List^.Count);
   End;
 End;
System.Close(MakeFile);
End;
If Status=DocEdit Then Client^.FocusItem(Location(Client,PrevPrihod^.Dat.MakeKod,ProdagaWindow))
Else Client^.FocusItem(0);

PrevS:=Client^.GEtText(Client^.Focused,Client^.List^.COunt);

Dispose(Client,Done);

R.Assign(3, 2, 13, 3);
Control := New(PColoredText, Init(R, 'Поставщик:', $74));
Insert(Control);


R.Assign(13, 2, 40, 3);
if prevs[0]=#0 then Prevs:='│';
ControlClient := New(PColoredText, Init(R, #3+PrevS, $1F));
ControlClient^.Options := ControlClient^.Options or ofSelectable;
Insert(ControlClient);

R.Assign(0, 0, 0, 0);
Razdel := New(PBox, Init(R, 1, Nil));
Razdel^.NewList(New(PTextCollection, Init(1,1)));
Assign (RazdelFile,Path^.Dat.ToRazdel+'razdel.db');
Reset  (RazdelFile);

{Repeat
Until NetMessage (Print.PathToMain+'razdel.db') in [0,1];
Reset (RazdelFile);}

While Not(Eof(RazdelFile)) Do
 Begin
  Read(RazdelFile,RazdelElement);
  If RazdelElement.Employ Then
   Begin
    Format (RazdelElement.Name,CClient);
    Razdel^.List^.Insert(NewStr(RazdelElement.Name+'│'+RazdelElement.Kod));
    Razdel^.SetRange(Razdel^.List^.Count);
   End;
 End;
System.Close(RazdelFile);
Razdel^.FocusItem(0);

PrevS:=Razdel^.GEtText(Razdel^.Focused,Razdel^.List^.COunt);

Dispose(Razdel,Done);


R.Assign(51, 2, 76, 3);
ControlRazdel := New(PColoredText, Init(R, #3+PrevS, $1F));
ControlRazdel^.Options := ControlRazdel^.Options or ofSelectable;
Insert(ControlRazdel);

R.Assign(43, 2, 51, 3);
Insert(New(PLabel, Init(R, 'Ра~з~дел:',ControlRazdel)));

R.Assign(79, 4, 80, 12);
Control := New(PScrollBar, Init(R));
Insert(Control);

R.Assign(1, 4, 79, 12);
Baz := New(PBox, Init(R, 1, PScrollbar(Control)));
Baz^.NewList(New(PTextCollection, Init(1,1)));
c:=Pos('│',PrevS);
PrevS:=Copy(Prevs,c+1,CArtikul);
DelSpace(PrevS);
If (Prevs[0]<>#0)  And (PrevS<>'│') Then
 Begin
Assign (BazFile,Path^.Dat.ToSklad+Prevs+'.db');
Reset (BazFile);
While Not(Eof(BazFile)) Do
 Begin
     ReadSklad(BazFile,BazElement);

  If BazElement.Employ Then
        Begin
    SName:=GetIdField(FName,BazElement.BazKod);
         Format(SName,CName);
         SLitr:=GetIdField(FLitr,BazElement.BazKod);
         Format(SLitr,CLitr);
         Format (BazElement.Input.Kol,CLitr);
         SPack:=GetIdField(FInPack,BazElement.BazKod);
         Format(SPack,CInPack);
         MyStr(StrToReal(BazElement.Input.Zakupka),CZena,CMantissa,BazElement.Input.Zakupka);
         MyStr(StrToReal(BazElement.Input.R_Zena),CZena,CMantissa,BazElement.Input.R_Zena);
         MyStr(StrToReal(BazElement.Input.O_Zena),CZena,CMantissa,BazElement.Input.O_Zena);
         Format (BazElement.Input.Zakupka,CZena);
         Format (BazElement.Input.R_Zena,CZena);
         Format (BazElement.Input.O_Zena,CZena);
         Format (BazElement.Input.Post,CPost);

         DelSpaceRight(BazElement.Input.NSertif);
         If (BazElement.Input.NSertif[0]<>#0) Then
         Format (BazElement.Input.NSertif,CArtikul)
         Else BazElement.Input.NSertif:='85000';


{   Format (BazElement.Input.DSertif,CDSertif);
         Format (BazElement.Input.KSertif,CKSertif);}

         DelSpace(BazElement.Input.Kol);
         RFormat (BazElement.Input.Kol,CLitr);

         Prevs:=SName+'│'+BazElement.BazKod+'│'+SLitr+
         '│'+SPAck+'│'+BazElement.Input.Kol+'│'+
         +BazElement.Input.R_Zena+'│'+BazElement.Input.NSertif+'│'+BazElement.Input.Post;

         Baz^.List^.Insert(NewStr(Prevs));
         Baz^.SetRange(Baz^.List^.Count);
        End;
 End;
System.Close(BazFile);
 End;
Baz^.FocusItem(0);
Baz^.HelpCtx:=$E001;
Insert(Baz);

  R.Assign(1, 3, 79, 4);
  Insert(New(PLabel, Init(R, '~Н~аименование товара         Код  Литр. Фас Колич  Р/Цена   Серт.Производство', Baz)));

R.Assign(79, 14, 80, 22);
Control := New(PScrollBar, Init(R));
Insert(Control);

R.Assign(1, 14, 79, 22);
GTD := New(PBox, Init(R, 1, Nil));
Gtd^.NewList(New(PTextCollection, Init(1,1)));

R.Assign(1, 14, 79, 22);
Newtovar := New(PBox, Init(R, 1, PScrollbar(Control)));
NewTovar^.NewList(New(PTextCollection, Init(1,1)));
If Status=DocEdit Then
 Begin
  c:=1;
  For c:=1 To PrevPrihod^.Dat.Amount Do
        Begin
         S:=GetIdField(FName,PrevPrihod^.Dat.PrihodElement[c].BazKod);
         Format(S,CName);
         s:=s+'│'+PrevPrihod^.Dat.PrihodElement[c].BazKod;
         ws:=GetIdField(FLitr,PrevPrihod^.Dat.PrihodElement[c].BazKod);
         Format(WS,CLitr);
         s:=s+'│'+ws;
         ws:=GetIdField(FInPack,PrevPrihod^.Dat.PrihodElement[c].BazKod);
         Format(ws,CInPack);
         s:=s+'│'+ws;
         Format(PrevPrihod^.Dat.PrihodElement[c].Input.Kol,CKol);
         Format(PrevPrihod^.Dat.PrihodElement[c].Input.R_Zena,CZena);
         Format(PrevPrihod^.Dat.PrihodElement[c].Input.Zakupka,CZena);
         Format(PrevPrihod^.Dat.PrihodElement[c].Input.O_Zena,CZena);

         Format(PrevPrihod^.Dat.PrihodElement[c].Input.NGTD,CNSertif);
         Format(PrevPrihod^.Dat.PrihodElement[c].Input.Virabotano,CDate);
         Format(PrevPrihod^.Dat.PrihodElement[c].Input.Godnost,CDate);
         Format(PrevPrihod^.Dat.PrihodElement[c].Input.Marka,CNSertif);

         Format(PrevPrihod^.Dat.PrihodElement[c].Input.NSertif,CArtikul);

         Format(PrevPrihod^.Dat.PrihodElement[c].Input.Akzis1,CAkzis1);

         Format(PrevPrihod^.Dat.PrihodElement[c].Input.Zakupka,CZena);
         Format(PrevPrihod^.Dat.PrihodElement[c].Input.Post,CPost);
         Format(PrevPrihod^.Dat.MakeKod,CMakeKod);

         s:=s+'│'+PrevPrihod^.Dat.PrihodElement[c].Input.Kol+'│'+PrevPrihod^.Dat.PrihodElement[c].Input.R_Zena
          +'│'+PrevPrihod^.Dat.PrihodElement[c].Input.O_Zena+'│'+PrevPrihod^.Dat.PrihodElement[c].Input.NSertif+'│'+
          +PrevPrihod^.Dat.PrihodElement[c].Input.Akzis1+'│'+PrevPrihod^.Dat.PrihodElement[c].Input.Zakupka+'│';

         For i:=1 To CDiviSion Do
         Begin
          Format(PrevPrihod^.Dat.PrihodElement[c].Input.Division[i],CKol);
          s:=s+PrevPrihod^.Dat.PrihodElement[c].Input.Division[i]{+'│'};
         End;
         s:=s+PrevPrihod^.Dat.PrihodElement[c].Input.Post;
         NewTovar^.List^.Insert(NewStr(s));
         NewTovar^.SetRange(NewTovar^.List^.Count);
         GTD^.List^.Insert(NewStr(
         PrevPrihod^.Dat.PrihodElement[c].BazKod+'│'+PrevPrihod^.Dat.PrihodElement[c].Input.NGTD+'│'+
         PrevPrihod^.Dat.PrihodElement[c].Input.Marka+'│'+PrevPrihod^.Dat.PrihodElement[c].Input.Virabotano+'│'+
         PrevPrihod^.Dat.PrihodElement[c].Input.Godnost));
         GTD^.SetRange(GTD^.List^.Count);
        End;
 End;

NewTovar^.HelpCtx:=$E150;
NewTovar^.FocusItem(0);
Insert(NewTovar);

  R.Assign(1, 13, 79, 14);
  Insert(New(PLabel, Init(R, 'Приходуем~ы~е товары          Код  Литр. Фас Колич Р/Цена   О/Цена   Серт.', NewTovar)));


R.Assign(2, 12, 22, 13);
Control := New(PColoredText, Init(R, 'Наименование товара:', $74));
Insert(Control);

R.Assign(22, 12, 79, 13);
ControlFullName := New(PColoredText, Init(R, ' ', $7e));
Insert(ControlFullName);



R.Assign(42, 1, 51, 2);
Control := New(PColoredText, Init(R, ' Выбрано:', $74));
Insert(Control);

R.Assign(51, 1, 54, 2);
ControlCurrent := New(PColoredText, Init(R, '0', $7E));
Insert(ControlCurrent);

R.Assign(26, 22, 37, 23);
Control := New(PColoredText, Init(R, ' Итого О/Ц:', $74));
Insert(Control);

R.Assign(37, 22, 52, 23);
Control_IO := New(PColoredText, Init(R, '0.0',$4E));
Insert(Control_IO);

R.Assign(52, 22, 63, 23);
Control := New(PColoredText, Init(R, ' Итого Р/Ц:', $74));
Insert(Control);

R.Assign(63, 22, 78, 23);
Control_IR := New(PColoredText, Init(R, '0.0', $4E));
Insert(Control_IR);

R.Assign(1, 0, 11, 1);
Control := New(PColoredText, Init(R, ' Документ:', $74));
Insert(Control);

R.Assign(21, 0, 29, 1);
Control := New(PColoredText, Init(R, TekDate, $7E));
Insert(Control);

R.Assign(11, 0, 15, 1);
ControlDoc := New(PColoredText, Init(R, ''+DocumentNumer, $7E));
Insert(ControlDoc);

R.Assign(16, 0, 21, 1);
Control := New(PColoredText, Init(R, 'Дата:', $74));
Insert(Control);

R.Assign(1, 22, 14, 23);
Control := New(PColoredText, Init(R, ' Итого литр.:', $74));
Insert(Control);

R.Assign(14, 22, 26, 23);
Control_Litr := New(PColoredText, Init(R, '0.000',$7E));
Insert(Control_Litr);

R.Assign(2, 1, 15, 2);
Control := New(PColoredText, Init(R, 'Итого по З/Ц:', $74));
Insert(Control);

R.Assign(15, 1, 30, 2);
Control_Zakupka := New(PColoredText, Init(R, #3+'0.00', $7E));
Insert(Control_Zakupka);




SelectNext(False);

AllZakupka[0]:=#0;

CalcItogo;
AddName;
L:=True;
PrevNAme[0]:=#0;
PrevS[0]:=#0;
end;

procedure TPrihodWindow.CalcItogo;
Var R:TRect;
         t,l,k : Real;
         z,Sl,Sk,So,Sr : Real;
         zz,SSl,SSk,SSo,SSr,Itogo_O,Itogo_R,Itogo_L:String[CIZena];
         ls : Word;
         Code:Integer;
         kol : LongInt;
Begin
SO:=0;
SR:=0;
SL:=0;
z:=0;
AllZakupka[0]:=#0;
For ls:=0 To NewTovar^.List^.Limit Do
Begin
{литраж}
SSl:=Copy(NewTovar^.GetText(ls,NewTovar^.List^.Limit),1+CName+1+CArtikul+1,CLitr);
DelSpace(Ssl);
{колич}
SSk:=Copy(NewTovar^.GetText(ls,NewTovar^.List^.Limit),1+CName+1+CArtikul+1+CLitr+1+CInPack+1,CKol);
DelSpace(sSk);
{розничная цена}
SSr:=Copy(NewTovar^.GetText(ls,NewTovar^.List^.Limit),1+CName+1+CArtikul+1+CLitr+1+CInPack+1+CKol+1,CZena);
DelSpace(sSr);
{оптовая цена}
SSo:=Copy(NewTovar^.GetText(ls,NewTovar^.List^.Limit),1+CName+1+CArtikul+1+CLitr+1+CInPack+1+CKol+1+CZena+1,CZena);
DelSpace(sso);

{закупочная цена}
{
ZZ:=Copy(NewTovar^.GetText(ls,NewTovar^.List^.Limit),1+CName+1+CArtikul+1+CLitr+1+CInPack+1+CKol+1+CZena+1+CZena+
                        1+CSertif+1+CAkzis+1,CZena);
}
ZZ:=Copy(NewTovar^.GetText(ls,NewTovar^.List^.Limit),1+CName+1+CArtikul+1+CLitr+1+CInPack+1+CKol+1+CZena+1+CZena+
                        1+CArtikul+1+CAkzis1+1,CZena);

delSpace(zz);



Val(ssk,kol,Code);
Val(ssl,l,Code);
Sl:=Sl+L*Kol;
Val(ssr,l,Code);
Sr:=Sr+l*Kol;
Val(sso,l,Code);
So:=So+l*Kol;

Val(zz,l,Code);
Z:=z+l*Kol;
End;{for}

MyStr(Sl,CILitr,CLitrMantissa,Itogo_L);
DelSpace(Itogo_L);
MyStr(Sr,CIZena,CMantissa,Itogo_R);
DelSpace(Itogo_R);
MyStr(So,CIZena,CMantissa,Itogo_O);
DelSpace(Itogo_O);

MyStr(z,CIZena,CMantissa,AllZakupka);
DelSpace(AllZakupka);

Dispose(Control_IO,Done);
R.Assign(37, 22, 52, 23);
Control_IO := New(PColoredText, Init(R,#3+Itogo_O,$4E));
Insert(Control_IO);

Dispose(Control_IR,Done);
R.Assign(63, 22, 78, 23);
Control_IR := New(PColoredText, Init(R,#3+Itogo_R, $4E));
Insert(Control_IR);

Dispose(Control_Litr,Done);
R.Assign(14, 22, 26, 23);
Control_Litr := New(PColoredText, Init(R,#3+Itogo_L,$7E));
Insert(Control_Litr);

Dispose(Control_Zakupka,Done);
R.Assign(15, 1, 30, 2);
if (strtoint(currentpassword)=0) Or (OperatorSelector=2) Or ((EnableZakupka=1)) then
Control_Zakupka := New(PColoredText, Init(R,#3+AllZakupka,$7E))
Else
Control_Zakupka := New(PColoredText, Init(R,#3+'!!!.!!',$7E));

Insert(Control_Zakupka);
End;



Procedure TPrihodWindow.AddName;

Var R : TRect;
         KolStr : String[2];

Begin
  Str(NewTovar^.List^.Count:2,KolStr);
  Dispose(ControlCurrent,Done);
  R.Assign(51, 1, 54, 2);
  ControlCurrent := New(PColoredText, Init(R, #3+KolStr, $7E));
  Insert(ControlCurrent);
  Redraw;
End;


Procedure TPrihodWindow.Refresh;
Var i : Byte;
         R : TRect;
Begin
R.Assign(0, 0, 0, 0);
Client := New(PBox, Init(R, 1, Nil));
Client^.NewList(New(PTextCollection, Init(1,1)));

DInfo('Обновляю список клиентов...');

Case OperatorSelector Of
0:Assign (MakeFile,Path^.Dat.ToClient+'Make.db');
1:Assign (MakeFile,Path^.Dat.ToClient+'Sklad.db');
2:Assign (MakeFile,Path^.Dat.ToClient+'Barter.db');
Else;
End;


{
If OperatorSelector=0 Then
Assign (MakeFile,Path^.Dat.ToClient+'Make.db')
Else
Assign (MakeFile,Path^.Dat.ToClient+'Sklad.db');
}

I:=IOResult;
Reset (MakeFile);
I:=IOResult;
If i=0 Then
Begin
While Not(Eof(MakeFile)) Do
 Begin
          {
          Repeat
          Until NetCall.Lock(MakeFile,FilePos(MakeFile)*SizeOf(ClientType),SizeOf(ClientType));
          }
          ReadMake(MakeFile,MakeElement);
          {
          Repeat
                NetCall.UnLock(MakeFile,(FilePos(MakeFile)-1)*SizeOf(ClientType),SizeOf(ClientType));
          Until (DosError=0);
          }

  If MakeElement.Employ Then
        Begin
         Format (MakeElement.Name,CClient);
         Client^.List^.Insert(NewStr(MakeElement.Name+'│'+MakeElement.Kod));
         Client^.SetRange(Client^.List^.Count);
        End;
 End;
System.Close(MakeFile);
End;
Client^.FocusItem(0);
PrevS:=Client^.GetText(Client^.Focused,Client^.List^.Count);
If prevS[0]=#0 then prevS:='│';
          PStaticText(ControlClient)^.Text^:=#3+PrevS;
Dispose(Client,Done);
NoInfo;
CalcItogo;
End;


procedure TPrihodWindow.HandleEvent(var Event: TEvent);
Var test,IO : Word;
         s,s1 : String;
         l : Boolean;
  SName : String[CName];
  SLitr : String[CLitr];
  SPack : String[CInPack];
  ARt,SClientKod : ArtikulStr;
  SDoc : ArtikulStr;
  SDate: TDateString;


Function LockSelect:Boolean;
Var s : String;
         Event : TEvent;
         R : Boolean;
         Msg : StrNAme;
Begin
  LockSelect:=False;
  s:=Copy(Baz^.GetText(Baz^.Focused,Baz^.List^.Count),1+CName+1,Cartikul);
  R:=GetIdEmploy(s);
  If Not(r) Then
        Begin
         Beep;
         DInfoMsg('Позиция ['+s+'] отмечена как удаленная. Нельзя использовать эту позицию!',False);
         ClearEvent(Event);
         ClearEvent(Event);
         repeat
         Application^.GetEvent(Event);
         {until (Event.What in [evKeyDown,evMouseDown]);}
         until (Event.What <> evNothing)And(Event.Command<>cmMenu);

         NoInfoMsg;
         ClearEvent(Event);
         ClearEvent(Event);
         Event.What:=EvCommand;
         Event.Command:=cmRefresh;
         PutEvent(Event);
         ClearEvent(Event);
         Exit;
        End;

  If SetNameLock(s,Msg) Then LockSelect:=True
  Else
        Begin
         Beep;
         DInfoMsg('Позиция ['+s+'] используется'+Msg+'. Не могу заблокировать!',False);
         ClearEvent(Event);
         ClearEvent(Event);
         repeat
         Application^.GetEvent(Event);
         {until (Event.What in [evKeyDown,evMouseDown]);}
         until (Event.What <> evNothing)And(Event.Command<>cmMenu);

         NoInfoMsg;
         ClearEvent(Event);
        End;
End;

Function TestEmploy:Boolean;
Var s : String;
         Event : TEvent;
         R : Boolean;
         Msg : StrNAme;
Begin
  TestEmploy:=False;
  s:=Copy(Baz^.GetText(Baz^.Focused,Baz^.List^.Count),1+CName+1,Cartikul);
  R:=GetIdEmploy(s);
  If Not(r) Then
        Begin
         Beep;
         DInfoMsg('Позиция ['+s+'] отмечена как удаленная. Нельзя использовать эту позицию!',False);
         ClearEvent(Event);
         ClearEvent(Event);
         repeat
         Application^.GetEvent(Event);
         {until (Event.What in [evKeyDown,evMouseDown]);}
         until (Event.What <> evNothing)And(Event.Command<>cmMenu);

         NoInfoMsg;
         ClearEvent(Event);
         ClearEvent(Event);
         Event.What:=EvCommand;
         Event.Command:=cmRefresh;
         PutEvent(Event);
         ClearEvent(Event);
         Exit;
        End;
  TestEmploy:=R;
End;



Procedure UnlockAll;
Var  f : File Of BazType;
          cl : PBazType;
          r : Byte;
          s : StrName;
Begin
DInfo('Минуточку...');
PStaticText(ControlRazdel)^.GetText(S);
System.Delete(S,1,1);
s:=Copy(s,1+CRazdel+1,CRazdelKod);
Assign(f,Path^.Dat.ToName+s+'.id');
r:=IOResult;
Reset(f);
r:=IOResult;
If R<>0 Then
 Begin
  NoInfo;
  Exit;
 End;

New(cl,Init);
While Not(Eof(f)) Do
  Begin
        Read(f,Cl^.Dat);
        cl^.Dat.Locked:=False;
        cl^.Dat.LockCAption[0]:=#0;
        Seek(f,FilePos(f)-1);
        Write(f,cl^.Dat);
  End;
System.close(f);
Dispose(cl,Done);
NoInfo;
AddProtocol('Общая деблокировка наименований раздела '+s+'{сетевая безопасность транзакций}','','');
End;


Procedure RefreshTovarList(Var s,PrevS:String);
Var s1,s2 : String;
Begin
                                        If (s <> PrevS) Or(s[0]=#0) Or (PrevS[0]=#0) Then
                                          Begin
                                                DInfo('Читаю список товаров...');
                                                PrevS:=S;
                                                s:=Copy(s,1+CRazdel+1,CRazdelKod);
                                                DelSPace(s);
                                                Baz^.NewList(nil);
                                                Baz^.NewList(New(PTextCollection, Init(1,1)));
                                                if s[0]<>#0 then
                                                begin
                                                Assign (BazFile,Path^.Dat.ToSklad+s+'.db');
                                                IO:=IOResult;
                                                Reset (BazFile);
                                                IO:=IOResult;
                                                IF IO=0 Then
                                                Begin
                                                While Not(Eof(BazFile)) Do
                                                 Begin

          {
          Repeat
          Until NetCall.Lock(BazFile,FilePos(BazFile)*SizeOf(SkladType),SizeOf(SkladType));
          }
          ReadSklad(BazFile,BazElement);
          {
          Repeat
                NetCall.UnLock(BazFile,(FilePos(BazFile)-1)*SizeOf(SkladType),SizeOf(SkladType));
          Until (DosError=0);
          }
                                                  If BazElement.Employ Then
{                   If GetIdEmploy(BazElement.BazKod) Then}

                                                        Begin
                                        SName:=GetIdField(FName,BazElement.BazKod);
                                        Format(SName,CName);
                                        SLitr:=GetIdField(FLitr,BazElement.BazKod);
                                        Format(SLitr,CLitr);
                                        Format(BazElement.Input.Kol,CLitr);
                                        SPack:=GetIdField(FInPack,BazElement.BazKod);
                                        Format(SPack,CInPack);
                                        DelSpace(BazElement.Input.Kol);
         RFormat (BazElement.Input.Kol,CLitr);
         MyStr(StrToReal(BazElement.Input.R_Zena),CZena,CMantissa,BazElement.Input.R_Zena);
         MyStr(StrToReal(BazElement.Input.O_Zena),CZena,CMantissa,BazElement.Input.O_Zena);
{
         Format (BazElement.Input.R_Zena,CZena);
         Format (BazElement.Input.O_Zena,CZena);
         Format (BazElement.Input.Sertifikat,CSertif);
         Baz^.List^.Insert(NewStr(SName+'│'+BazElement.BazKod+'│'+SLitr+
         '│'+SPack+'│'+BazElement.Input.Kol+'│'+
         +BazElement.Input.R_Zena+'│'+BazElement.Input.O_Zena+'│'+BazElement.Input.Sertifikat));
}
         DelSpaceRight(BazElement.Input.NSertif);
         If (BazElement.Input.NSertif[0]<>#0) Then
         Format (BazElement.Input.NSertif,CArtikul)
         Else BazElement.Input.NSertif:='85000';

         Format (BazElement.Input.Post,CPost);



{   Format (BazElement.Input.NSertif,CNSertif);
         Format (BazElement.Input.DSertif,CDSertif);
         Format (BazElement.Input.KSertif,CKSertif);}

         Baz^.List^.Insert(NewStr(SName+'│'+BazElement.BazKod+'│'+SLitr+
         '│'+SPack+'│'+BazElement.Input.Kol+'│'+
         +BazElement.Input.R_Zena+'│'+BazElement.Input.NSertif+'│'+BazElement.Input.Post));

         Baz^.SetRange(Baz^.List^.Count);
                                                        End;
                                                 End;
                                                System.Close(BazFile);
                                                End;
                                                End
                                                Else
                                                Begin
                                                 MessageBox(^M+#3+'Отказано в доступе к '+Path^.Dat.ToSklad+s+'.db',Nil,mfError+mfCancelButton);
                                                 PrevS[0]:=#0;
                                                End;
                                                NoInfo;
                                                Baz^.FocusItem(0);
                                                {MessageBox(^M+#3+IntToStr(Baz^.List^.COunt,3),Nil,mfOkButton);}
                                                Redraw;
                                          End;
End;



begin
  Case Event.What Of
  evKeyDown :
  Case Event.KeyCode Of
          kbDel: Begin
          If (NewTovar^.State and sfFocused <> 0) And (NewTovar^.List<>Nil)And(NewTovar^.List^.Count>=1) Then
                                Begin
                                  If MessageBox(#3^M+#3'Удалить товар из накладной?',nil,mfConfirmation+mfOkCancel)=cmOk Then
                                        Begin
                                         NewTovar^.List^.AtFree(NewTovar^.Focused);
                                         NewTovar^.SetRange(NewTovar^.List^.Count);
                                         If NewTovar^.Focused>0 Then NewTovar^.FocusItem(NewTovar^.Focused);

                                         If (NewTovar^.Focused>=NewTovar^.List^.Count) and(NewTovar^.Focused>0) Then
                                         NewTovar^.FocusItem(NewTovar^.Focused-1);

                                         CalCItogo;
                                         Redraw;
                                        End;
                                  ClearEvent(Event);
                                End;

                                PrihodWindow^.Redraw;
                                AddName;
                                End;
  kbF5     :Begin
                                 PStaticText(Control_IR)^.GetTExt(s);
                                 If Pos(#3,s)>0 Then System.Delete(s,1,1);
                                 PStaticText(Control_IO)^.GetTExt(s1);
                                 If Pos(#3,s1)>0 Then System.Delete(s1,1,1);
                                 s:=' Итого по Р/Ц:'+s+'  Итого по О/Ц:'+S1+'  Итого по З/Ц:'+AllZakupka;
                                 {Вставить номер и дату документа в просмотре}
                                 If Status=DocEdit Then
                                  Begin
                                        SDoc:=PrevPrihod^.Dat.Document;
                                        SDate:=PrevPrihod^.Dat.DateC;
                                  End
                                  Else
                                  Begin
                                        PStaticText(ControlDoc)^.GetTExt(sdoc);
                                        If Pos(#3,sdoc)>0 Then System.Delete(sdoc,1,1);
                                        SDate:=FDate;
                                  End;
                                 FullScreen(NewTovar,'Приход~у~емые товары          Код  Литр. Фас Колич Р/Цена   О/Цена   Сертификат',s,
                                 SDoc,SDate,0);
                                End;
  kbCtrLDel: Begin
          If (NewTovar^.State and sfFocused <> 0) And (NewTovar^.List<>Nil)And(NewTovar^.List^.Count>=1) Then
                                Begin
                                 If MessageBox(#3^M+#3'Удалить всю накладную?',nil,mfConfirmation+mfOkCancel)=cmOk Then
                                 Begin
                                  NewTovar^.NewList(nil);
                                  NewTovar^.NewList(New(PTextCollection, Init(1,1)));
                                  CalCItogo;
                                  AddName;
                                  PrihodWindow^.Redraw;
                                 End;
                                End;
                                End;
  kbEnter:    Begin
          If (Baz^.State and sfFocused <> 0) And (Baz^.List<>Nil)And(Baz^.List^.Count>=1) Then
                                Begin
{            ls:=NewTovar^.List^.Count;}
                                 If Not(TestEmploy) Then
                                  Begin
                                         ClearEvent(Event);
                                         Exit;
                                  End;
          If (Baz^.State and sfFocused <> 0) And (Baz^.List<>Nil)And(NewTovar^.List^.Count>CMax-1) Then
                                  Begin
                MessageBox(#3^M+#3'В документе может быть'^M+
                                          #3'не более '+ IntToStr(CMax,2)+' наименований !',Nil,mfError+mfCanCelButton);
                                        ClearEVent(Event);
                                        Exit;
                                  End;
                                  s:=Copy(Baz^.GetText(Baz^.Focused,Baz^.List^.Count),1+CName+1,CArtikul);
                                  If TestElement(S,NewTovar) Then
                                        Begin
                                         s:=Baz^.GetText(Baz^.Focused,Baz^.List^.Count);
                                         Car^.Ini(s,0);
                                         CalcItogo;
                                         AddName;
                                         If (Baz^.Focused+1)<Baz^.List^.Count Then
                                          Begin
                                          Baz^.FocusItem(Baz^.Focused+1);
                                          End;
                                         Redraw;
                                         ClearEvent(Event);
                                        End
                                  Else MessageBox(#3^M+#3'Товар с кодом '+s+' уже есть'^M+
                                  #3'в накладной !',Nil,mfError+mfCanCelButton);
                                  ClearEVent(Event);
                                End;

                                End;

kbAlt1 : If Password(5) Then UnlockAll;

kbGrayPlus,kbF4: Begin
If(Baz^.State and sfFocused <> 0)And(Not(Event.KeyCode=kbF4))Or
((Event.KeyCode=kbF4)And(Baz^.List<>Nil)And(Baz^.List^.Count>=1)And(Baz^.State and sfFocused <> 0)) Then
                                Begin

                                 If Event.KeyCode=kbF4 Then
                                  Begin
                                        If Not(LockSelect) Then
                                                                 Begin
                                                                         ClearEvent(Event);
                                                                         Exit;
                                                                 End;
                                         Art:=Copy(Baz^.GetText(Baz^.Focused,Baz^.List^.Count),1+CName+1,Cartikul);
                                  End;


                                 PStaticText(ControlRazdel)^.GetText(s);
                                 S:=Copy(s,1+1+CRazdel+1,CRazdelKod);
                                 Nam^.AddBazINI(Event.KeyCode,S,True,l);
                                 If L Then
                                  Begin
                                        If (Event.KeyCode=kbF4)And(Baz^.List<>Nil)And(Baz^.List^.Count>=1) Then
                                        Baz^.List^.AtFree(Baz^.Focused);
                                        SName := GetIdField(FName,BazElement.BazKod);
                                        Format(SName,CName);
                                        SLitr := GetIdField(FLitr,BazElement.BazKod);
                                        Format(SLitr,CLitr);
                                        Format (BazElement.Input.Kol,CLitr);
                                        SPack := GetIdField(FInPack,BazElement.BazKod);
                                        Format(SPack,CInPack);

                                        DelSpace(BazElement.Input.Kol);
                                        RFormat (BazElement.Input.Kol,CLitr);
                                        MyStr(StrToReal(BazElement.Input.R_Zena),CZena,CMantissa,BazElement.Input.R_Zena);

                                        Format (BazElement.Input.R_Zena,CZena);
                                        Format (BazElement.Input.Post,CPost);
{
                                        Format (BazElement.Input.Sertifikat,CSertif);
                                        Baz^.List^.Insert(NewStr(SName+'│'+BazElement.BazKod+'│'+SLitr+
                                        '│'+SPack+'│'+BazElement.Input.Kol+'│'+
                                        +BazElement.Input.R_Zena+'│'+BazElement.Input.O_Zena+'│'+BazElement.Input.Sertifikat));
}
                                        Format (BazElement.Input.NSertif,CArtikul);
                                        Baz^.List^.Insert(NewStr(SName+'│'+BazElement.BazKod+'│'+SLitr+
                                        '│'+SPack+'│'+BazElement.Input.Kol+'│'+
                                        +BazElement.Input.R_Zena+'│'+BazElement.Input.NSertif+'│'+BazElement.Input.Post));

                                        Baz^.SetRange(Baz^.List^.Count);
                                        Baz^.FocusItem(LoCation(Baz,BazElement.BazKod,ProdagaWindow));
                                        If Event.KeyCode=kbF4 Then
                                        RenameList(Element,NewToVar);
                                        CalcItogo;
                                        Redraw;
                                  End;
                                  If Event.KeyCode=kbF4 Then
                                  Begin
                                         Repeat
                                         Until (SetNameUnLock(Art));
                                  End;
                                  ClearEvent(Event);
                                End;
                                If (Event.KeyCode=kbF4)And(NewTovar^.State and sfFocused <> 0) And (NewTovar^.List<>Nil)
                                        And (NewTovar^.List^.Count>=1)  Then
                                Begin
                                  s:=NewTovar^.GetText(NewTovar^.Focused,NewTovar^.List^.Count);
                                  Car^.Ini(s,1);
                                  CalcItogo;
                                  Redraw;
                                  ClearEvent(Event);
                                End;
                                  ClearEvent(Event);

                                Redraw;
                                End;
          kbEsc: Begin
                                  ClearFind;
                                  Event.What:=evCommand;
                                  Event.Command:=cmCancel;
                                  PutEvent(Event);
{            Done;}
                                End;
                Else;
                End;{KeyDown}
  evCommand :
          Case Event.Command Of
          cmPrihod: Begin
                                                ClearEvent(Event);
                                          End;
          cmVozwrat: Begin
                                                ClearEvent(Event);
                                          End;
          cmOk : Begin
If Not(TestOpenDate1(TekDate)) Then
        Begin
         MessageBox(#3^M+#3'Доступ к данным за '+TekDate+' заблокирован!',Nil,mfError+mfCancelButton);
         ClearEvent(Event);
         Exit;
        End;

If (GlobalReadOnly=1) Or (ReadOnlyConst=1) Then
   Begin
    MessageBox(#3^M+ReadOnlyStr^,Nil,mfWarning+mfCancelButton);
    ClearEvent(Event);
    Exit;
   End;


If Not(TestSetupKurs(TekDate)) Then
        Begin
         {MessageBox(#3^M+#3'Не установлен курс USD на '+TekDate+'!',Nil,mfError+mfCancelButton);}
         ClearEvent(Event);
         Exit;
        End;
ClearFind;

                                        PStaticText(ControlClient)^.GetText(S);
                                        System.Delete(S,1,1);
                                        SClientKod:=Copy(s,1+CClient+1,CClientKod);
                                        DelSpace(s);
                                        If ((STRToInt(SClientKod)=StrToInt(ClientRP)) And (OperatorSelector=1)) Or
                                                ((STRToInt(SClientKod)=StrToInt(Rek.Kod)) And (OperatorSelector=1)) Then
                                         Begin
                                          Sound(100);
                                          DinfoMsg('Ошибка! Нельзя делать приход от внутреннего поставщика с кодом '+SClientKod+'!',False);
                                          Delay(300);
                                          NoSound;
                                          ClearEvent(Event);
                                         repeat
                                                Application^.GetEvent(Event);
                                         {until (Event.What in [evKeyDown,evMouseDown]);}
                                         until (Event.What <> evNothing)And(Event.Command<>cmMenu);
                                          NoInfoMsg;
                                          ClearEvent(Event);
                                          Exit;
                                         End;


                                        If (s<>'│')And(s[0]<>#0) Then
                                        Begin
                                        If ((NewTovar^.List<>Nil)And(NewTovar^.List^.Count>0))Or(Status=DocEdit) Then
                                 Begin
                                 PStaticText(Control_IR)^.GetTExt(s);
                                 If Pos(#3,s)>0 Then System.Delete(s,1,1);
                                 PStaticText(Control_IO)^.GetTExt(s1);
                                 If Pos(#3,s1)>0 Then System.Delete(s1,1,1);
                                 s:=' Итого по Р/Ц:'+s+'  Итого по О/Ц:'+S1+'  Итого по З/Ц:'+AllZakupka;
                                 {Вставить номер и дату документа в просмотре}

                                 If Status=DocEdit Then
                                  Begin
                                        SDoc:=PrevPrihod^.Dat.Document;
                                        SDate:=PrevPrihod^.Dat.DateC;
                                  End
                                  Else
                                  Begin
                                        PStaticText(ControlDoc)^.GetTExt(sdoc);
                                        If Pos(#3,sdoc)>0 Then System.Delete(sdoc,1,1);
                                        SDate:=FDate;
                                  End;

                                If FullScreen(NewTovar,'Приход~у~емые товары          Код  Литр. Фас Колич Р/Цена   О/Цена   Сертификат',S,
                                SDoc,SDate,1)
                                         Then
                                          Begin
                                                 L:=False;
                                                 SaveToFilePr(L);
                                                 If L Then
                                                        Begin
                                                          Event.What:=evCommand;
                                                          Event.Command:=cmClose;
                                                          PutEvent(Event);
                                                          ClearEvent(Event);
                                                          Dispose(GTD,Done);
                                                          If Status = DocEdit Then
                                                                                          Begin
                                                                                                Dispose(PrevPrihod,Done);
                                                                                          End;
                                                          Status:=DocNormal;
                                                          TekDate := FDate;
                                                        End; {L}
                                          End{Message}
                                          Else ClearEvent(Event);
                                  End;
                                        End
                                        Else
                                         MessageBox(#3+NoMAke+''^M+
                                         #3'Ввод информации на склад невозможен !',Nil,mfError+mfOkCancel);
                                  ClearFind;
                                End;
                cmCancel : Begin
                                        l:=False;
                                        s:=#3^M+#3'Желаете отказаться от регистрации/корректировки прихода ?';
                                        If (NewTovar^.List<>Nil)And(NewTovar^.List^.Count>0) Then
                                        If MessageBox(s,Nil,mfConFirmation+mfOkCancel)<>cmOk
                                 Then
                                        Begin
                                         l:=True;
                                        End;
                                        If Not(L) Then
                                          Begin
                                          If Status = DocEdit Then
                                                Begin
                                                  Repeat
                                                  Until (UnLockPrihod(PrevPrihod^.Dat.Document,PrevPrihod^.Dat.DateC) in [0,2]);
                                                  Dispose(PrevPrihod,Done)
                                                End
                                                Else
                                                 Begin
                                                  PStaticText(ControlDoc)^.GetText(sdoc);
                                                  If Pos(#3,sdoc)>0 Then System.Delete(sdoc,1,1);
                                                  DelSpace(SDoc);
                                                  {
                                                  Repeat
                                                  Until (FreeDocNumer(DocPrihod,TekDate,SDoc));
                                                  }
                                                 End;
                                          Event.What:=evCommand;
                                          Event.Command:=cmClose;
                                          PutEvent(Event);
                                          Status:=DocNormal;
                                          Dispose(GTD,Done);
                                          TekDate := FDate;
                                         End;
                                          ClearEvent(Event);
                                         End;
 cmRefresh:Begin
                                PStaticText(ControlRazdel)^.GetText(S);
                                System.Delete(S,1,1);
                                PrevS[0]:=#0;
                                RefreshTovarList(s,PrevS);
                                ClearEvent(Event);
                          End;
  cmSelectClient:
 Begin
  If (PView(Cl)<>Desktop^.TopView)And(ControlClient^.State and sfFocused <> 0) Then
  Begin
          PStaticText(ControlClient)^.GetText(S);
          System.Delete(S,1,1);
          Cl^.ShowClientList(s,OperatorSelector,1,False,False,-1,-1,-1,-1,Test);
          PStaticText(ControlClient)^.Text^:=#3+S;
          Redraw;
          Case Test Of
                0,3 :FocusNext(True);
                1,2 :FocusNext(False);
          Else;
          End;
          ClearEvent(Event);
  End
 End;
 cmSelectRazdel:
 Begin
  If (PView(Rz)<>Desktop^.TopView)And(ControlRazdel^.State and sfFocused <> 0) Then
  Begin
          PStaticText(ControlRazdel)^.GetText(S);
          System.Delete(S,1,1);
          l:=False;
          Rz^.ShowRazdelList(s,Test,L);
          PStaticText(ControlRazdel)^.Text^:=#3+S;
          Redraw;
          Case Test Of
                0,3 :FocusNext(True);
                1,2 :FocusNext(False);
          Else;
          End;
          RefreshTovarList(s,PrevS);
          ClearEvent(Event);
  End
 End;
                Else;
                End;{evCommand}
                Else;
                End;{*Case*}
  if (Event.What = evBroadcast) and
         (Event.Command = cmPrihod) then ClearEvent(Event);

  if (Event.What = evBroadcast) and
         (Event.Command = cmQuit) then ClearEvent(Event);

 If (PView(Rz)<>Desktop^.TopView)And(ControlRazdel^.State and sfFocused <> 0)
 And (Event.Command<>cmSelectRazdel) And (Event.What <> EvKeyDown)Then
                                Begin
                                 Event.What:=EvCommand;
                                 Event.Command:=cmSelectRazdel;
                                 PutEvent(Event);
                                 ClearEvent(Event);
                                End;

 If (PView(Cl)<>Desktop^.TopView)And(ControlClient^.State and sfFocused <> 0)
 And (Event.Command<>cmSelectClient) And (Event.What <> EvKeyDown)Then
                                Begin
                                 Event.What:=EvCommand;
                                 Event.Command:=cmSelectClient;
                                 PutEvent(Event);
                                 ClearEvent(Event);
                                End;

  inherited HandleEvent(Event);

  If (Desktop^.Current=PView(PrihodWindow)) And (Event.What <> EvKeyDown) Then
        Begin
                         if (ControlOperatorSelect^.State and sfFocused <> 0)Then
                                  Begin
                                        ControlOperatorSelect^.GetData(Test);
                                        If Test <> OperatorSelector Then
                                        Begin
                                         OperatorSelector:=Test;
                                         Refresh;
                                         PrihodWindow^.Redraw;
                                        End;
                                  End;
                         DrawFullName;
         End;
end;


End.