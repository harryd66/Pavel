{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}

{$I Compile.INC}

{$L-}
Unit PrihodI;


Interface


Uses Dialogs,Drivers,Glob,ServStr;





Procedure InputPrihodToSklad(As : DocumentEditZ);

Type
  PTestOpenPosition = ^TestOpenPosition;
  TestOpenPosition = object(TDialog)
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure CalcPosition;
    procedure MAkeReport;
    Destructor Done;Virtual;
  end;


Function ExclusiveLockAllImportPosition(Const E:PBox):Boolean;
Function ExclusiveLockAllImportMake(Const E:PBox):Boolean;
Function ExclusiveLockAllImportGroup(Const E:PBox):Boolean;
Procedure UnLockAllImportPosition(Const E:PBox);
Procedure UnLockAllImportMake(Const E:PBox);
Procedure UnLockAllImportGroup(Const E:PBox);

Function GetGRZena(Art:ArtikulStr):AllStr;
Function GetNGTD(Art:ArtikulStr):AllStr;
Function GetExpert(Art:ArtikulStr):AllStr;

Function GetValuta(Art:ArtikulStr):AllStr;
Function GetStrihKod(Art:ArtikulStr):AllStr;
Function GetMarka(Art:ArtikulStr):AllStr;
Function GetSpecMarka(Art:ArtikulStr):String;
Function GetVirabotano(Art:ArtikulStr):AllStr;
Function GetGodnost(Art:ArtikulStr):AllStr;
Function GetProzFromPrihod(Art:ArtikulStr):String;
Function GetRegionMarkaFromPrihod(Art:ArtikulStr):ArtikulStr;
Function GetAkzisSbor(Art:ArtikulStr):String;
Function GetZenaMarki(Art:ArtikulStr):String;
procedure PeremeshenieToDivision;
Procedure FormNewMake(VAr NewCL:PClientType);
Procedure Podgotovka(c: Word;VAr P:PImportSuperMarketType);
{Procedure LoadExpert(Const P:PImportSuperMarketType;Var PP: PBox;ss:TMyString);}
Procedure ReadScreenPrihod(Var L :PPrihodType;Const TempPrihod:PBox);

Procedure ww1(l:PPrihodType);
Procedure ww2(l:PPrihodType);
Procedure RecalcZeni(c:Word;Var P:PImportSuperMarketType);
Procedure Formating(c:Word;Var PrevPrihod:PPrihodType);
Function TestEmploy(Const Baz:PBox):Boolean;
Procedure RefreshPTovarList(Var BakList : PBox; Var s,PrevS:String;Bron : Word);


Var

 NewTovar :PBox;
 StrihKod : PBox;
 GTD : PBox;
 Expert : PBox;

Implementation




uses DBEngine,Objects, Views, MsgBox,Vision5,Vision2,Vision1,Protect,{MyCalc,}Windos,Menus,
     Access2,TpDate,Printers,App, ColorTxt,Serv,InpLong,Validate,CPrihod,
     Utils4,TestPrh,DbEngin2,
     NetCall,Net,Net2,NetDbEng,Utils,Utils1,Utils5,Utils3;

Var testw,TestWindow : PTestOpenPosition;
 WarningList : PBox;
    Control_Pos : PView;

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

 Writeln(Txt,Space+'Склад: ',GetClientField(FClient,Rek^.Dat.Kod,1)+'  Оператор: '+CurrentPassword+' EYE & 1997-98');

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





Procedure InputPrihodToSklad(As : DocumentEditZ);
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
    Op : StrName;
Begin
 Save:=False;


 If Not TestEqualTovar(As) Then Exit;


 New(E,Init);


    i:=Lockprihod(As,E,True);
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

    If Not(SetClientLock(E^.Dat.MakeKod,1,E^.Dat.OperatorSelector,Op)) Then
     Begin
      Repeat
      Until (UnLockPrihod(E^.Dat.Document,E^.Dat.DateC) in [0,2]);
      Sound(100);
      {DinfoMsg('Не могу заблокировать поставщика '+E^.Dat.MAkeKod+'! Попробуйте повторить!',False);}
      DInfoMsg('Поставщик ['+E^.Dat.MAkeKod+'] используется '+Op+'! Не могу заблокировать поставщика!',False);

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
PereozenkaElement^.Dat.Vid:=0{по приход}{As.Vid};{надо исправит для случая возврата и прихода}

j:=1;
Logik:=True;
Search:=False;
For i:=1 To E^.DAt.Amount Do
 Begin
  If ((StrToReal(E^.Dat.PrihodElement[i].Input.R_Zena)<>StrToReal(BakGetField(FRZena,E^.Dat.PrihodElement[i].Bazkod,0)))Or
        (StrToReal(E^.Dat.PrihodElement[i].Input.Spec_Zena)<>StrToReal(BakGetField(FSpecZena,
           E^.Dat.PrihodElement[i].Bazkod,0))))
{  And(StrToInt(BakGetField(FKol,E^.Dat.PrihodElement[i].BazKod,0))>0)} Then
        Begin
         If (StrToInt(BakGetField(FKolNew,E^.Dat.PrihodElement[i].BazKod,0))>0) Then
         Begin
         Logik:=False;
         Search:=True;
         End;
         PereozenkaElement^.Dat.Element[j].BazKod:=E^.Dat.PrihodElement[i].BazKod;
         PereozenkaElement^.Dat.Element[j].Kol:=BakGetField(FKolNew,E^.Dat.PrihodElement[i].BazKod,0);
         PereozenkaElement^.Dat.Element[j].Bak_R_Zena:=BakGetField(FRZena,E^.Dat.PrihodElement[i].BazKod,0);
         PereozenkaElement^.Dat.Element[j].Bak_O_Zena:=BakGetField(FSpecZena,E^.Dat.PrihodElement[i].BazKod,0);
         PereozenkaElement^.Dat.Element[j].New_R_Zena:=E^.Dat.PrihodElement[i].Input.R_Zena;
         PereozenkaElement^.Dat.Element[j].New_O_Zena:=E^.Dat.PrihodElement[i].Input.Spec_Zena;
{   PereozenkaElement^.Dat.Sklad:=Rek.SkladsName;}
         PereozenkaElement^.Dat.Caption := CurrentPassword;
         MyStr(
         StrToInt(
         BakGetField(FKolNew,E^.Dat.PrihodElement[i].BazKod,0))*StrToReal(BakGetField(FRZena,E^.Dat.PrihodElement[i].BazKod,0))
	    +
          StrToReal(PereozenkaElement^.Dat.Itogo_Bak_R_Zena),CIZena,CMantissa
         ,PereozenkaElement^.Dat.Itogo_Bak_R_Zena);
         DelSpace(PereozenkaElement^.Dat.Itogo_Bak_R_Zena);
         MyStr(
         StrToInt(
         BakGetField(FKolNew,E^.Dat.PrihodElement[i].BazKod,0))*StrToReal(BakGetField(FSpecZena,
            E^.Dat.PrihodElement[i].BazKod,0))+
          StrToReal(PereozenkaElement^.Dat.Itogo_Bak_O_Zena),CIZena,CMantissa
         ,PereozenkaElement^.Dat.Itogo_Bak_O_Zena);
         DelSpace(PereozenkaElement^.Dat.Itogo_Bak_O_Zena);
         MyStr(StrToInt(BakGetField(FKolNew,E^.Dat.PrihodElement[i].BazKod,0))*StrToReal(E^.Dat.PrihodElement[i].Input.R_Zena)+
          StrToReal(PereozenkaElement^.Dat.Itogo_New_R_Zena),CIZena,CMantissa
         ,PereozenkaElement^.Dat.Itogo_New_R_Zena);
         DelSpace(PereozenkaElement^.Dat.Itogo_New_R_Zena);
         MyStr(StrToInt(BakGetField(FKolNew,E^.Dat.PrihodElement[i].BazKod,0))*
	    StrToReal(E^.Dat.PrihodElement[i].Input.Spec_Zena)+
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



Function ExclusiveLockAllImportPosition(Const E:PBox):Boolean;
Var l,Count : Word;
    Error : Boolean;
    Operator : Strname;
    Event : TEvent;
    SArt : ArtikulStr;
Begin
ExclusiveLockAllImportPosition:=False;
Error:=False;
If (E^.List^.Count-1)>=0 Then
Begin
For Count:=0 To E^.List^.Count-1 Do
 Begin
   SArt:=Copy(E^.GetText(Count,E^.List^.Count),1+1,CArtikul);
  If Not(SetNameLock(SArt,Operator)) Then
   Begin
    Beep;
    DInfoMsg('Позиция ['+SArt+'] используется'+Operator+'. Не могу заблокировать!',
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
If Not(Error) Then ExclusiveLockAllImportPosition:=True;
If (Error) And (Count>0) Then
 Begin
  For l:=Count-1 DownTo 0 Do
   Begin
    SArt:=Copy(E^.GetText(l,E^.List^.Count),1+1,CArtikul);
    Repeat
    Until SetNameUnLock(SArt);
   End;
 End;
End;


Function ExclusiveLockAllImportMake(Const E:PBox):Boolean;
Var l,Count : Word;
    Error : Boolean;
    Operator : Strname;
    Event : TEvent;
    SArt : ArtikulStr;
    Ext,VdOperation : Byte;
Begin
ExclusiveLockAllImportMake:=False;
Error:=False;
If (E^.List^.Count-1)>=0 Then
Begin
For Count:=0 To E^.List^.Count-1 Do
 Begin
   SArt:=Copy(E^.GetText(Count,E^.List^.Count),1+1,CArtikul);
   Ext:=StrToint(Copy(SArt,1,1));
   SArt:=Copy(SArt,2,CCLientKod);
  If Not(SetClientLock(SArt,1{работа с поставщиками},Ext,Operator)) Then
   Begin
    Beep;
    DInfoMsg('Клиент ['+SArt+'] используется'+Operator+'. Не могу заблокировать!',
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
If Not(Error) Then ExclusiveLockAllImportMake:=True;
If (Error) And (Count>0) Then
 Begin
  For l:=Count-1 DownTo 0 Do
   Begin
    SArt:=Copy(E^.GetText(l,E^.List^.Count),1+1,CArtikul);
    Ext:=StrToint(Copy(SArt,1,1));
    SArt:=Copy(SArt,2,CCLientKod);
    Repeat
    Until SetClientUnLock(SArt,1{работа с поставщиками},Ext);
   End;
 End;
End;


Function ExclusiveLockAllImportGroup(Const E:PBox):Boolean;
Var l,Count : Word;
    Error : Boolean;
    Operator : Strname;
    Event : TEvent;
    SArt : ArtikulStr;
    Ext,VdOperation : Byte;
Begin
ExclusiveLockAllImportGroup:=False;
Error:=False;
If (E^.List^.Count-1)>=0 Then
Begin
For Count:=0 To E^.List^.Count-1 Do
 Begin
   SArt:=Copy(E^.GetText(Count,E^.List^.Count),1+1,CClientKod);
  If Not(SetElementLock(FGroup,SArt,Operator)) Then
   Begin
    Beep;
    DInfoMsg('Группа ['+SArt+'] используется'+Operator+'. Не могу заблокировать!',
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

If Not(Error) Then ExclusiveLockAllImportGroup:=True;
If (Error) And (Count>0) Then
 Begin
  For l:=Count-1 DownTo 0 Do
   Begin
    SArt:=Copy(E^.GetText(l,E^.List^.Count),1+1,CClientKod);
    Repeat
    Until SetElementUnLock(FGroup,SArt);
   End;
 End;
End;



Procedure UnLockAllImportPosition(Const E:PBox);
Var Count : Word;
    SArt : ArtikulStr;
Begin
If (E^.List^.Count-1)>=0 Then
Begin
For Count:=0 To E^.List^.Count-1 Do
 Begin
  SArt:=Copy(E^.GetText(Count,E^.List^.Count),1+1,CArtikul);
  Repeat
  Until SetNameUnLock(SArt);
 End;
End;
End;


Procedure UnLockAllImportMake(Const E:PBox);
Var Count : Word;
    SArt : ArtikulStr;
    Ext,VdOperation : Byte;
Begin
If (E^.List^.Count-1)>=0 Then
Begin
For Count:=0 To E^.List^.Count-1 Do
 Begin
  SArt:=Copy(E^.GetText(Count,E^.List^.Count),1+1,CArtikul);
  Ext:=StrToint(Copy(SArt,1,1));
  SArt:=Copy(SArt,2,CCLientKod);
  Repeat
  Until SetClientUnLock(SArt,1,Ext);
 End;
End;
End;


Procedure UnLockAllImportGroup(Const E:PBox);
Var Count : Word;
    SArt : ArtikulStr;
    Ext,VdOperation : Byte;
Begin
If (E^.List^.Count-1)>=0 Then
Begin
For Count:=0 To E^.List^.Count-1 Do
 Begin
  SArt:=Copy(E^.GetText(Count,E^.List^.Count),1+1,CClientKod);
  Repeat
  Until SetELementUnLock(FGroup,SArt);
 End;
End;
End;


Function GetNGTD(Art:ArtikulStr):AllStr;
VAr s: String;
Begin
 GetNGTD[0]:=#0;
 s:=Copy(GTD^.GetText(Location(GTD,Art,True),Gtd^.List^.Count),1+CArtikul+1,CArtikul);
 DelSpaceRight(s);
 GetNGTD:=s;
End;






Function GetExpert(Art:ArtikulStr):AllStr;
VAr s: String;
Begin
 GetExpert[0]:=#0;
 s:=Copy(Expert^.GetText(Location(Expert,Art,True),Expert^.List^.Count),1+CArtikul+1,CArtikul);
 DelSpaceRight(s);
 GetExpert:=s;
End;

Function GetMarka(Art:ArtikulStr):AllStr;
VAr s: String;
Begin
 GetMarka[0]:=#0;
 s:=Copy(GTD^.GetText(Location(GTD,Art,True),Gtd^.List^.Count),1+CArtikul+1+CArtikul+1,CArtikul);
 DelSpaceRight(s);
 GetMarka:=s;
End;


Function GetSpecMarka(Art:ArtikulStr):String;
VAr s: String;
Begin
 GetSpecMarka[0]:=#0;
 s:=Copy(GTD^.GetText(Location(GTD,Art,True),Gtd^.List^.Count),1+CArtikul+1+CArtikul+1+CArtikul+1+CDate+1+
 CDate+1,CArtikul);
 GetSpecMarka:=s;
End;





Function GetVirabotano(Art:ArtikulStr):AllStr;
VAr s: String;
Begin
 GetVirabotano[0]:=#0;
 s:=Copy(GTD^.GetText(Location(GTD,Art,True),Gtd^.List^.Count),1+CArtikul+1+CArtikul+1+CArtikul+1,CDate);
 DelSpaceRight(s);
 GetVirabotano:=s;
End;


Function GetGodnost(Art:ArtikulStr):AllStr;
VAr s: String;
Begin
 GetGodnost[0]:=#0;
 s:=Copy(GTD^.GetText(Location(GTD,Art,True),Gtd^.List^.Count),1+CArtikul+1+CArtikul+1+CArtikul+1+CDate+1,
 CDate);
 DelSpaceRight(s);
 GetGodnost:=s;
End;

{
        s2:=SArtikul+'│'+Input.StrihKod+'│'+Input.GRZena+'│'+IntToStr(Input.USD,COne)+'│'+
           +'│'+Input.Proz+'│'+IntToStr(Input.RegionMArka,COne)+'│'+
		 +Input.AkzisSbor+'│'+Input.ZenaMarki+'│';
}

Function GetStrihKod(Art:ArtikulStr):AllStr;
VAr s: String;
Begin
 GetStrihKod[0]:=#0;
 s:=Copy(StrihKod^.GetText(Location(StrihKod,Art,True),StrihKod^.List^.Count),1+CArtikul+1,CStrihKod);
 DelSpaceRight(s);
 GetStrihKod:=s;
End;

Function GetGRZena(Art:ArtikulStr):AllStr;
VAr s: String;
Begin
 GetGRZena[0]:=#0;
 s:=Copy(StrihKod^.GetText(Location(StrihKod,Art,True),StrihKod^.List^.Count),1+CArtikul+1+CStrihKod+1,CZenaZ);
 DelSpace(s);
 GetGRZena:=s;
End;

Function GetValuta(Art:ArtikulStr):AllStr;
VAr s: String;
Begin
 GetValuta[0]:=#0;
 s:=Copy(StrihKod^.GetText(Location(StrihKod,Art,True),StrihKod^.List^.Count),1+CArtikul+1+CStrihKod+1+CZenaZ+1,COne);
 DelSpace(s);
 GetValuta:=s;
End;


Function GetProzFromPrihod(Art:ArtikulStr):String;
VAr s: String;
Begin
 GetProzFromPrihod[0]:=#0;
 s:=Copy(StrihKod^.GetText(Location(StrihKod,Art,True),StrihKod^.List^.Count),1+CArtikul+1+CStrihKod+1+CZenaZ+1+COne+1,CLitr);
 GetProzFromPrihod:=s;
End;


Function GetRegionMarkaFromPrihod(Art:ArtikulStr):ArtikulStr;
VAr s: String;
Begin
 GetRegionMarkaFromPrihod[0]:=#0;
 s:=Copy(StrihKod^.GetText(Location(StrihKod,Art,True),StrihKod^.List^.Count),
 1+CArtikul+1+CStrihKod+1+CZenaZ+1+COne+1+CLitr+1,COne);
 GetRegionMarkaFromPrihod:=s;
End;


Function GetAkzisSbor(Art:ArtikulStr):String;
VAr s: String;
Begin
 GetAkzisSbor[0]:=#0;
 s:=Copy(StrihKod^.GetText(Location(StrihKod,Art,True),StrihKod^.List^.Count),
 1+CArtikul+1+CStrihKod+1+CZenaZ+1+COne+1+CLitr+1+COne+1,CZenaZ);
 GetAkzisSbor:=s;
End;


Function GetZenaMarki(Art:ArtikulStr):String;
VAr s: String;
Begin
 GetZenaMarki[0]:=#0;
 s:=Copy(StrihKod^.GetText(Location(StrihKod,Art,True),StrihKod^.List^.Count),
 1+CArtikul+1+CStrihKod+1+CZenaZ+1+COne+1+CLitr+1+COne+1+CZenaZ+1,CZenaZ);
 GetZenaMarki:=s;
End;


procedure PeremeshenieToDivision;
Const Shablon='0    0    0    0    0    0    0    0    ';
              {1234512345123451234512345123451234512345}
Var DDD,c : Word;
    Artikul,AllKol : ArtikulStr;
    s : String;
    Temp : PBox;
    R : TRect;
    s1 : String;
    SArtikul : AllStr;
Begin
{$IfDef DPMI}
If (NewTovar^.List<>Nil)And(NewTovar^.List^.Count>=1) Then
Begin
 If SelectKuda(DDD) Then
  Begin
   R.Assign(0,0,0,0);
   Temp := New(PBox, Init(R, 1, Nil));
   Temp^.NewList(New(PTextCollection, Init(0,1)));
   For c:=0 To NewTovar^.List^.Count-1 Do
    Begin
    s:=NewTovar^.GetText(c,NewTovar^.List^.Count);
    SArtikul:=Copy(s,1+CName+1,CArtikul);
    If Not GetRazdelStatus(SArtikul) Then
    Begin
    System.Delete(s,1+CName+1+CArtikul+1+CLitr+1+CInPack+1+CKol+1+CZena+1+CZena+
         1+CArtikul+1+CArtikul+1+CZenaZ+1+CZenaZ+1,CKol*CDivision);
    AllKol:=Copy(s,1+CName+1+CArtikul+1+CLitr+1+CInPack+1,CKol);
    s1:=Shablon;

    {корректируем шаблон}
    System.Delete(s1,DDD*CKol+1,CKol);
    System.Insert(AllKol,s1,DDD*CKol+1);

    {вставляем шаблон в исходную строку}
    System.Insert(s1,s,1+CName+1+CArtikul+1+CLitr+1+CInPack+1+CKol+1+CZena+1+CZena+
         1+CArtikul+1+CArtikul+1+CZenaZ+1+CZenaZ+1);
    End;{Перемешщение}

     Temp^.List^.Insert(NewStr(s));
     Temp^.SetRange(Temp^.List^.Count);
    End;{сформировали новый List}

   NewTovar^.NewList(nil);
   NewTovar^.NewList(New(PTextCollection, Init(0,1)));

   For c:=0 To Temp^.List^.Count-1 Do
    Begin
     s:=Temp^.GetText(c,Temp^.List^.Count);
     NewTovar^.List^.Insert(NewStr(s));
     NewTovar^.SetRange(NewTovar^.List^.Count);
    End;{сформировали новый List}

   Dispose(Temp,Done);
   NewTovar^.FocusItem(0);
   MessageBox(^M+#3+'Операция успешно завершена!',Nil,mfWarning+mfCancelButton);

  End;
End;{если список не пустой}
{$ENDIF}
End;{Procedure}


Procedure FormNewMake(VAr NewCL:PClientType);
BEgin
With NewCL^.Dat Do
Begin
Name     :='СМ.РЕЗЕРВНЫЙ СКЛАД';
FullName :='СМ.РЕЗЕРВНЫЙ СКЛАД';
Dogovor  [0]:=#0;
AdressF  :='СМ.РЕЗЕРВНЫЙ СКЛАД';
{For j:=1 To 4 Do Punkt[j,0]:=#0;}
{1 Павильоны} {2 Палатки} {3 Магазин} {4 Кафе}
Limit    [0]:=#0;
Lizo     :=0;
Adress   :='СМ.РЕЗЕРВНЫЙ СКЛАД';
Telefon  :='СМ.РЕЗЕРВНЫЙ СКЛАД';
R_Sh     [0]:=#0;
BankKod:=NoBankStr;
INN      [0]:=#0;
OKONH    [0]:=#0;
OKPO     [0]:=#0;
Enviropment[0]:=#0;
Svidetelstvo[0]:=#0;
VekselIP[0]:=#0;
VekselDP[0]:=#0;
Seria   [0]:=#0;
Passport[0]:=#0;
Vidan   [0]:=#0;
Messages[0]:=#0;
RegionKod:=NoRegionStr;
Debit   :=0;
SrokLizensia[0]:=#0;
Employ   :=True;{становится задействованной}
RCD     :=False;
End;{With}
End;{Procedure}



Procedure Podgotovka(c: Word;VAr P:PImportSuperMarketType);
VAr Skl : PSkladType;
Begin
         Format(P^.Dat.Element[c].Input.Kol,CKol);
         Format(P^.Dat.Element[c].Input.Zakupka,CZenaZ);
         Format(P^.Dat.Element[c].Input.Zakupka2,CZenaZ);
         Format(P^.Dat.Element[c].Input.Spec_Zena,CZena);


         Format(P^.Dat.Element[c].Input.R_Zena,CZena);
         Format(P^.Dat.Element[c].Input.O_Zena,CZena);
         Format(P^.Dat.SkladKod,CMakeKod);

   If EnableImport=1 Then{цикл не работает на резервном складе
   т.к. на нем самая полная база всегда 14/12/2001}
      Begin
         RFormatZerro(P^.Dat.Element[c].Input.NGTD,CArtikul);
         Format(P^.Dat.Element[c].Input.Virabotano,CDate);
         Format(P^.Dat.Element[c].Input.Godnost,CDate);
         RFormatZerro(P^.Dat.Element[c].Input.Marka,CArtikul);
         RFormatZerro(P^.Dat.Element[c].Input.SpecMarka,CArtikul);
         RFormatZerro(P^.Dat.Element[c].Input.NMakeKod,CArtikul);
         RFormatZerro(P^.Dat.Element[c].Input.NSertif,CArtikul);
         RFormatZerro(P^.Dat.Element[c].Input.Expert,CArtikul);
         Format(P^.Dat.Element[c].Input.StrihKod,CStrihKod);
         Format(P^.Dat.Element[c].Input.AkzisSbor,CZenaZ);
         Format(P^.Dat.Element[c].Input.ZenaMarki,CZenaZ);
      End
      Else
       {если это склад резервный то берем текущие значения параметров}
       Begin
        New(Skl,Init);
        Skl^.DAt.BazKod:=P^.Dat.Element[c].Baz.BazKod;
        GetSkladRecord(Skl);

        P^.Dat.Element[c].Input.NGTD:=Skl^.Dat.Input.NGTD;
         Format(P^.Dat.Element[c].Input.NGTD,CArtikul);
        P^.Dat.Element[c].Input.Virabotano:=Skl^.Dat.Input.Virabotano;
         Format(P^.Dat.Element[c].Input.Virabotano,CDate);
        P^.Dat.Element[c].Input.Godnost:=Skl^.Dat.Input.Godnost;
         Format(P^.Dat.Element[c].Input.Godnost,CDate);
        P^.Dat.Element[c].Input.Marka:=Skl^.Dat.Input.Marka;
         RFormatZerro(P^.Dat.Element[c].Input.Marka,CArtikul);
        P^.Dat.Element[c].Input.Expert:=Skl^.Dat.Input.Expert;
         RFormatZerro(P^.Dat.Element[c].Input.Expert,CArtikul);
        P^.Dat.Element[c].Input.SpecMarka:=Skl^.Dat.Input.SpecMarka;
         RFormatZerro(P^.Dat.Element[c].Input.SpecMarka,CArtikul);
        P^.Dat.Element[c].Input.NMAkeKod:=Skl^.Dat.Input.NMakeKod;
         RFormatZerro(P^.Dat.Element[c].Input.NMakeKod,CArtikul);
        P^.Dat.Element[c].Input.NSertif:=Skl^.Dat.Input.NSertif;
         RFormatZerro(P^.Dat.Element[c].Input.NSertif,CArtikul);
        P^.Dat.Element[c].Input.StrihKod:=Skl^.Dat.Input.StrihKod;
         Format(P^.Dat.Element[c].Input.StrihKod,CStrihKod);

        Format(P^.Dat.Element[c].Input.AkzisSbor,CZenaZ);
        Format(P^.Dat.Element[c].Input.ZenaMarki,CZenaZ);
        {
        P^.Dat.Element[c].Input.AkzisSbor:=Skl^.Dat.Input.AkzisSbor;
         Format(P^.Dat.Element[c].Input.AkzisSbor,CZenaZ);
        P^.Dat.Element[c].Input.ZenaMArki:=Skl^.Dat.Input.ZenaMarki;
         Format(P^.Dat.Element[c].Input.ZenaMarki,CZenaZ);
        }
        Dispose(Skl,Done);
       End;
End;{Procedure}


(*
Procedure LoadExpert(Const P:PImportSuperMarketType;Var PP: PBox;ss:TMyString);
VAr Skl : PSkladType;
    txt : Text;
    exps,s : STring;
    c : Word;
    Art : ArtikulStr;
Begin
ExpS[0]:=#0;
Format(ExpS,CNAme);

Assign(txt,ss);
c:=IOResult;
Reset(txt);
c:=IOResult;
If c<>0 Then
Begin
 MessageBox(^M+#3+'Ошибка открытия '+ss+'!'^M+#3+
 ClicProgrammer^+' Код:'+IntToStr(c,CLitrMantissa),Nil,mfError+mfCancelButton);

 DInfoMsg('Минуточку. Заполняю не найденные экспертные заключения...',False);
   For c:=1 To P^.Dat.Amount Do
    Begin
     If P^.Dat.Element[c].Employ Then
      Begin
       If TestElement(P^.Dat.Element[c].Baz.BazKod,Expert) Then
        Begin
         s:=P^.Dat.Element[c].Baz.BazKod+'│'+ExpS;
         Expert^.List^.Insert(NewStr(s));
         Expert^.SetRange(Expert^.List^.Count);
        End;
      End;{Employ}
    End;{For}


   For c:=1 To P^.Dat.AmountS Do
    Begin
     If P^.Dat.ElementS[c].Employ Then
      Begin
       If TestElement(P^.Dat.ElementS[c].Baz.BazKod,Expert) Then
        Begin
         s:=P^.Dat.Elements[c].BAz.BazKod+'│'+ExpS;
         Expert^.List^.Insert(NewStr(s));
         Expert^.SetRange(Expert^.List^.Count);
        End;
      End;{Employ}
    End;{For}
 NoInfoMsg;

 Exit;
End;

 DInfoMsg('Минуточку. Формирую список экспертных заключений...',False);

  While Not (Eof(txt)) Do
   Begin
    Readln(txt,s);
    Art:=Copy(s,1,CArtikul);
    Exps:=s;

   If EnableImport=1 Then{цикл не работает на резервном складе т.к. на нем самая полная база всегда 14/12/2001}
      Begin
       System.Delete(Exps,1,1+CArtikul);
      End
      Else
       Begin
        ExpS:=BakGetField(FExpert,Art,0);
       End;

       If TestElement(Art,Expert) Then
        Begin
         Expert^.List^.Insert(NewStr(Art+'│'+Exps));
         Expert^.SetRange(Expert^.List^.Count);
        End;
   End;

NoInfoMsg;
c:=IOResult;
Close(txt);
c:=IOResult;
Erase(txt);
c:=IOResult;
End;{Procedure}
*)


Procedure ww2(l:PPrihodType);
VAr As:DocumentEditZ;
Begin
                 If Glob.Status=DocNormal Then
                 AddProtocol('Формирование накладной прихода N '+L^.Dat.Document+' от '+TekDate,'','')
                 Else
                 AddProtocol('Корректировка накладной прихода N '+L^.Dat.Document+' от '+TekDate,'','');

                        As.D:=TekDate;
                        As.EditPosition:=L^.Dat.Document;

                 If MessageBox(#3^M+#3'Накладная прихода сформирована !'^M+
                 #3'Печатать накладную прихода ?',Nil,mfConfirmation+mfOkCancel)=cmOk Then
                  Begin
                        PrintPrihod(As);
                  End;

                If Pharm=1 Then
                  If MessageBox(^M+#3'Печатать накладную комиссии по документу '+As.EditPosition+' от '+
                            As.D+'?',Nil,
                     mfConfirmation+mfOKCancel)=cmOk Then
                    Begin
                     PrintPrihodAsMarket(As);
                    End;
End;


Procedure ww1(l:PPrihodType);
VAr As:DocumentEditZ;
Begin
                                          If Glob.Status=DocNormal Then
                                          AddProtocol('Формирование накладной прихода N '+L^.Dat.Document+' от '+TekDate,'','')
                                          Else
                                        AddProtocol('Корректировка накладной прихода N '+L^.Dat.Document+' от '+TekDate,'','');

                As.D:=TekDate;
                As.EditPosition:=L^.Dat.Document;

                If MessageBox(#3^M+#3'Накладная прихода сформирована !'^M+
                              #3'Печатать накладную прихода ?',Nil,mfConfirmation+mfOkCancel)=cmOk Then
                 Begin
                  PrintPrihod(As);
                 End;

                If Pharm=1 Then
                  If MessageBox(^M+#3'Печатать накладную комиссии по документу '+As.EditPosition+' от '+
                            As.D+'?',Nil,
                     mfConfirmation+mfOKCancel)=cmOk Then
                    Begin
                     PrintPrihodAsMarket(As);
                    End;
End;


Procedure ReadScreenPrihod(Var L :PPrihodType;Const TempPrihod:PBox);
VAr i : Word;
    st,s : String;
    j : Word;
Begin
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

         Zakupka:=Copy(s,1+CRazdelKod+1+CName+1+(CArtikul-CRazdelKod)+1+CLitr+1+CInPack+1+CKol+1+CZena+1+CZena+1+
         CArtikul+1+CArtikul+1,CZenaZ);
         DelSpace(Zakupka);

         Zakupka2:=Copy(s,1+CRazdelKod+1+CName+1+(CArtikul-CRazdelKod)+1+CLitr+1+CInPack+1+CKol+1+CZena+1+CZena+1+
         CArtikul+1+CArtikul+1+CZenaZ+1,CZenaZ);
         DelSpace(Zakupka2);

         For j:=1 To CDivision Do
         Begin
          Division[j]:=Copy(s,1+CRazdelKod+1+CName+1+(CArtikul-CRazdelKod)+1+CLitr+1+CInPack+1+CKol+1+CZena+1+CZena+
          1+CArtikul+1+CArtikul+1+CZenaZ+1+CZenaZ+1+CKol*(j-1){+1*(j-1)},CKol);
          DelSpace(Division[j]);
         End;





         NMAkeKod:=Copy(s,1+CRazdelKod+1+CName+1+(CArtikul-CRazdelKod)+1+CLitr+1+CInPack+1+CKol+1+CZena+1+CZena+
                1+CArtikul+1,CArtikul);
         DelSpace(NMakeKod);
         RFormatZerro(NMAkeKod,CArtikul);

         Spec_Zena:=Copy(s,1+CRazdelKod+1+CName+1+(CArtikul-CRazdelKod)+1+CLitr+1+CInPack+1+CKol+1+CZena+1+CZena+
         1+CArtikul+1+CArtikul+1+CzenaZ+1+CZenaZ+1+CKol*CDivision+1,CZena);
         DelSpace(Spec_Zena);
        End;

        st:=Copy(s,1,CRazdelKod);

        L^.Dat.PrihodElement[i+1].BazKod:=Copy(s,1+CName+1+CRazdelKod+1,CArtikul-CRazdelKod);

        L^.Dat.PrihodElement[i+1].BazKod:=st+L^.Dat.PrihodElement[i+1].BazKod;

        L^.Dat.PrihodElement[i+1].Input.NGTD:=GetNGTD(L^.Dat.PrihodElement[i+1].BazKod);
        DelSpaceRight(L^.Dat.PrihodElement[i+1].Input.NGTD);

        L^.Dat.PrihodElement[i+1].Input.Expert:=GetExpert(L^.Dat.PrihodElement[i+1].BazKod);
        DelSpaceRight(L^.Dat.PrihodElement[i+1].Input.Expert);

        L^.Dat.PrihodElement[i+1].Input.StrihKod:=GetStrihKod(L^.Dat.PrihodElement[i+1].BazKod);
        DelSpaceRight(L^.Dat.PrihodElement[i+1].Input.StrihKod);

        L^.Dat.PrihodElement[i+1].Input.GRZena:=GetGRZena(L^.Dat.PrihodElement[i+1].BazKod);
        DelSpace(L^.Dat.PrihodElement[i+1].Input.GRZena);

        L^.Dat.PrihodElement[i+1].Input.USD:=StrToInt(GetVAluta(L^.Dat.PrihodElement[i+1].BazKod));

        L^.Dat.PrihodElement[i+1].Input.Marka:=GetMarka(L^.Dat.PrihodElement[i+1].BazKod);
        DelSpaceRight(L^.Dat.PrihodElement[i+1].Input.Marka);



        L^.Dat.PrihodElement[i+1].Input.SpecMarka:=GetSpecMarka(L^.Dat.PrihodElement[i+1].BazKod);
        DelSpaceRight(L^.Dat.PrihodElement[i+1].Input.SpecMarka);
        L^.Dat.PrihodElement[i+1].Input.Virabotano:=GetVirabotano(L^.Dat.PrihodElement[i+1].BazKod);
        DelSpaceRight(L^.Dat.PrihodElement[i+1].Input.Virabotano);
        L^.Dat.PrihodElement[i+1].Input.Godnost:=GetGodnost(L^.Dat.PrihodElement[i+1].BazKod);
        DelSpaceRight(L^.Dat.PrihodElement[i+1].Input.Godnost);

        L^.Dat.PrihodElement[i+1].Input.StrihKod:=GetStrihKod(L^.Dat.PrihodElement[i+1].BazKod);
        DelSpaceRight(L^.Dat.PrihodElement[i+1].Input.StrihKod);

        L^.Dat.PrihodElement[i+1].Input.AkzisSbor:=GetAkzisSbor(L^.Dat.PrihodElement[i+1].BazKod);
        DelSpace(L^.Dat.PrihodElement[i+1].Input.AkzisSbor);

        L^.Dat.PrihodElement[i+1].Input.ZenaMarki:=GetZenaMarki(L^.Dat.PrihodElement[i+1].BazKod);
        DelSpace(L^.Dat.PrihodElement[i+1].Input.ZenaMarki);

        L^.Dat.PrihodElement[i+1].Input.Proz:=GetProzFromPrihod(L^.Dat.PrihodElement[i+1].BazKod);
        DelSpaceRight(L^.Dat.PrihodElement[i+1].Input.Proz);

        L^.Dat.PrihodElement[i+1].Input.RegionMarka:=StrToInt(GetRegionMArkaFromPrihod(L^.Dat.PrihodElement[i+1].BazKod));


        L^.Dat.PrihodElement[i+1].Nalog:=GetIDField(FNalog,L^.Dat.PrihodElement[i+1].BazKod);
        L^.Dat.PrihodElement[i+1].VidNalog:=StrToInt(GetIDField(FVidNalog,L^.Dat.PrihodElement[i+1].BazKod));

        L^.Dat.PrihodElement[i+1].NDS:=GetIDField(FNDS,L^.Dat.PrihodElement[i+1].BazKod);
        L^.Dat.PrihodElement[i+1].VidNDS:=StrToInt(GetIDField(FVidNDS,L^.Dat.PrihodElement[i+1].BazKod));

 End;
End;


Procedure RecalcZeni(c:Word;Var P:PImportSuperMarketType);
Begin
 P^.Dat.Element[c].Input.Zakupka2:=P^.Dat.Element[c].Input.Zakupka;
 P^.Dat.Element[c].Input.Zakupka:=P^.Dat.Element[c].Input.R_Zena;

 MyStr(StrToReal(P^.Dat.Element[c].Input.Zakupka)*PrivolyeProz{1.05 с 19/04/2004 из-за кирова
 чтобы была возможность маневра},
 CZena,CMantissa,P^.Dat.Element[c].Input.R_Zena);

 DelSpace(P^.Dat.Element[c].Input.R_Zena);
 Normalizasia(P^.Dat.Element[c].Input.R_Zena);

 P^.Dat.Element[c].Input.O_Zena:=P^.Dat.Element[c].Input.R_Zena;
 P^.Dat.Element[c].Input.Spec_Zena:=P^.Dat.Element[c].Input.R_Zena;
End;



Procedure Formating(c:Word;Var PrevPrihod:PPrihodType);
Begin
         Format(PrevPrihod^.Dat.PrihodElement[c].Input.Kol,CKol);
         Format(PrevPrihod^.Dat.PrihodElement[c].Input.R_Zena,CZena);
         Format(PrevPrihod^.Dat.PrihodElement[c].Input.Spec_Zena,CZena);
         Format(PrevPrihod^.Dat.PrihodElement[c].Input.GRZena,CZenaZ);
         Format(PrevPrihod^.Dat.PrihodElement[c].Input.Zakupka,CZenaZ);
         Format(PrevPrihod^.Dat.PrihodElement[c].Input.Zakupka2,CZenaZ);
         Format(PrevPrihod^.Dat.PrihodElement[c].Input.AkzisSbor,CZenaZ);
         Format(PrevPrihod^.Dat.PrihodElement[c].Input.ZenaMarki,CZenaZ);
         Format(PrevPrihod^.Dat.PrihodElement[c].Input.O_Zena,CZena);
         Format(PrevPrihod^.Dat.PrihodElement[c].Input.Proz,CLitr);
         Format(PrevPrihod^.Dat.PrihodElement[c].Input.NGTD,CArtikul);
         Format(PrevPrihod^.Dat.PrihodElement[c].Input.Expert,CArtikul);
         Format(PrevPrihod^.Dat.PrihodElement[c].Input.Virabotano,CDate);
         Format(PrevPrihod^.Dat.PrihodElement[c].Input.Godnost,CDate);
         Format(PrevPrihod^.Dat.PrihodElement[c].Input.Marka,CArtikul);
         Format(PrevPrihod^.Dat.PrihodElement[c].Input.SpecMarka,CArtikul);
         Format(PrevPrihod^.Dat.PrihodElement[c].Input.NSertif,CArtikul);
         Format(PrevPrihod^.Dat.PrihodElement[c].Input.NMakeKod,CArtikul);
         Format(PrevPrihod^.Dat.PrihodElement[c].Input.StrihKod,CStrihKod);
         Format(PrevPrihod^.Dat.MakeKod,CMakeKod);
End;


Function TestEmploy(Const Baz:PBox):Boolean;
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
         Application^.ClearEvent(Event);
         Application^.ClearEvent(Event);
         repeat
         Application^.GetEvent(Event);
         {until (Event.What in [evKeyDown,evMouseDown]);}
         until (Event.What <> evNothing)And(Event.Command<>cmMenu);
         NoInfoMsg;
         Application^.ClearEvent(Event);
         Application^.ClearEvent(Event);
         Event.What:=EvCommand;
         Event.Command:=cmRefresh;
         Application^.PutEvent(Event);
         Application^.ClearEvent(Event);
         Exit;
        End;
  TestEmploy:=R;
End;


Procedure RefreshPTovarList(Var BakList : PBox; Var s,PrevS:String;Bron : Word);
Var s1,s2 : String;
    BF : File;
    BE : PBufSkladTypeNew;
    BB : PBazType;
    Snsertif,skol,sa : ArtikulStr;
    j,Count , c : Word;
    SKolR : AllStr;
    SPack,SName,SLitr,spost,SZena  : AllStr;
    IO : Word;
Begin
                                        If (s <> PrevS) Or(s[0]=#0) Or (PrevS[0]=#0) Then
                                          Begin
                                                DInfoMsg('Читаю список товаров...',False);
                                                PrevS:=S;
                                                s:=Copy(s,1+CRazdel+1,CRazdelKod);
                                                DelSPace(s);
                                                BakList^.NewList(nil);
                                                BakList^.NewList(New(PTextCollection, Init(1,1)));
                                                if s[0]<>#0 then
                                                begin
                                                Assign (BF,Path^.Dat.ToIndex+s+'.kdx');
                                                IO:=IOResult;
                                                Reset (BF,SizeOf(SkladTypeNew));
                                                IO:=IOResult;
                                                IF IO=0 Then
                                                Begin
                                                While Not(Eof(BF)) Do
                                                 Begin

          New(BE,Init);
          Count:=0;
          ReadBufNewSklad(BF,BE,Count);

For c:=1 To Count Do
Begin
                                                  If BE^.Point.Dat[c].Employ Then
                                                        Begin
                                        New(bb,Init);
                                        sa:=IntToStr(BE^.Point.Dat[c].BazKod,CArtikul);
                                        RFormatZerro(sa,CArtikul);
                                        GetBazElement(sa,bb^.Dat);
                                        SName:=BB^.Dat.Name;
                                        Format(SName,CName);
                                        SLitr:=BB^.Dat.Litr;
                                        Format(SLitr,CLitr);
                                        SPack:=BB^.Dat.InPack;
                                        Format(SPack,CInPack);
                                        SPost:=GetPostField(FPost,BB^.Dat.PostKod);
                                        Format(SPost,CPost);
                                        Dispose(bb,done);



      SKolR[0]:=#0;
      For j:=1 To CDivision Do
      MyStr(BE^.Point.Dat[c].DivisionR[j]+StrToInt(SKolR),CKol,0,SKolR);

      Case Bron Of
{забронированный}
      1:BE^.Point.Dat[c].Kol:=StrToInt(SKolR);
{не забронированный}
      2:BE^.Point.Dat[c].Kol:=BE^.Point.Dat[c].Kol-StrToInt(SKolR);
      Else;
      End;


         SKol:=IntToStr(BE^.Point.Dat[c].Kol,CKOl);
         RFormat(SKol,CKol);

         MyStr(BE^.Point.Dat[c].R_Zena,CZena,CMantissa,SZena);

         If BE^.Point.Dat[c].NSertif=0 Then BE^.Point.Dat[c].NSertif:=StrToInt(NoSertifStr);
         snSertif:=IntToStr(BE^.Point.Dat[c].NSertif,CArtikul);
         RFormatZerro(sNSertif,CArtikul);

         BakList^.List^.Insert(NewStr(SName+'│'+sa+'│'+SLitr+
         '│'+SPack+'│'+SKOl+'│'+
         +SZena+'│'+SNSertif+'│'+SPost));

         BakList^.SetRange(BakList^.List^.Count);
                                                        End;

End;{For}
Dispose(BE,Done);
                                                 End;{While}
                                                System.Close(BF);
                                                End;
                                                End
                                                Else
                                                Begin
                                                 MessageBox(^M+#3+'Отказано в доступе к '+
                                                                            Path^.Dat.ToIndex+s+'.kdx',Nil,
                                                                            mfError+mfCancelButton);
                                                 PrevS[0]:=#0;
                                                End;
                                                NoInfoMsg;
                                                BakList^.FocusItem(0);
                                                {MessageBox(^M+#3+IntToStr(BakList^.List^.COunt,3),Nil,mfOkButton);}
                                          End;
End;





End.