{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}
{$I Compile.INC}

Unit PostZak;

Interface

Uses Dialogs,Drivers,Glob,Access,MyCalc;

Type
  PPZCartWindow = ^TPZCartWindow;
  TPZCartWindow = object(TDialog)
  Calc        : PMyCalculator;
    Procedure Ini(Var s:String;Regim:Word);
    function CalcOptKol(art: string;var Market,Ost:string):String;
    procedure HandleEvent(var Event: TEvent); virtual;
    Destructor Done;Virtual;
  end;

Type
  PPZTestOpenPosition = ^PZTestOpenPosition;
  PZTestOpenPosition = object(TDialog)
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure CalcPosition;
    procedure MAkeReport;
    Destructor Done;Virtual;
  end;


Type
  PPZPrihodWindow = ^TPZPrihodWindow;
  TPZPrihodWindow = object(TDialog)
    Car : PPZCartWindow;
    Cl  : PClientWindow;
    Rz  : PRazdelWindow;
    Nam : PNameWindow;
    constructor Init(Var l: Boolean);
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure AddName;
    procedure OpenPrihodWindow;
    Procedure DrawFullName;
    procedure ImportNakl;
    procedure CalcItogo;
    procedure Refresh;
    Procedure PrintToFilePr(Var Save : Boolean);
  end;


 Implementation

uses DBEngine,Objects, Views, MsgBox,Vision2,Vision1,
     Protect,{MyCalc,}Windos,Menus,UtilsP,Utils,Access2,
     TpDate,Printers,App, ColorTxt,Serv,InpLong,Validate,CPrihod,ServStr,NetCall,Net,NetDbEng;

Type LocalInputPrihodType = Record
     Division: TKolString;
     Zakupka : String[CZena];
     R_Zena  : String[CZena];
     O_Zena  : String[CZena];
     AutoSkidka: Array[1..CShkala] Of String[CZena];
     NSertif : String[CNSertif];
     DSertif : String[CDSertif];
     KSertif : String[CKSertif];
RealizovatDo  : String[CDate];
     Akzis1  : String[CAkzis1];
       Post  : String[CPost];
     Kol     : String[CKol];
     Caption : String [CRazdelKod];
        Auto : Boolean;
     End;



var
 CartWin : PPZCartWindow;
 testw,TestWindow : PPZTestOpenPosition;
 WarningList : PBox;
 PZPrihodWindow : PPZPrihodWindow;
 ControlDoc,ControlFullName,
 ControlT,Control_IO,ControlArtikul,Control_IR,Control_Litr,
 ControlOZ,ControlCurrent,ControlPack,R_ZenaControl,ControlKol,ControlS,
 Control1,Control2,Control3,Control4,Control5,Control6,
 Control7,Control8,
 ControlMrk,
 ControlOperatorSelect,
 ControlClient, ControlVDate,ControlVDoc,ControlRazdel,ControlZakupka,
 Control_Zakupka,Control_Pos : PView;
 ControlProz,ControlShkala : Array [1..CShkala] Of PView;
 GlobalStatus : Word;
 PrevPrihod : PPrihodType;
 PrevVozwrat : PVozwratType;
 PrevS : String[150];
 SArtikul : ArtikulStr;
 InPut : LocalInputPrihodType;
 OperatorSelector : Word;
 AllZakupka : AllStr;
 SProz : Array [1..CShkala] Of String[CLitr+1];
 PrevName : String[180];
 SkidkaList : PBox;


Function GetSkidkaList(Art:ArtikulStr; j : Word):String;
VAr s: String;
Begin
 GetSkidkaList[0]:=#0;
 s:=SkidkaList^.GetText(Location(SkidkaList,Art,True),SkidkaList^.List^.Count);
 s:=Copy(s,1+CArtikul+1+CDate+1+(CLitr+1)*(j-1),CLitr+1);
 DelSpace(s);
 GetSkidkaList:=s;
End;


Function GetRealiz(Art:ArtikulStr):String;
VAr s: String;
Begin
 GetRealiz[0]:=#0;
 s:=SkidkaList^.GetText(Location(SkidkaList,Art,True),SkidkaList^.List^.Count);
 s:=Copy(s,1+CArtikul+1,CDate);
 DelSpace(s);
 GetRealiz:=s;
End;


Function WritePrihodToSkladFile(L:PPrihodType) : Boolean;
Var SkladFile : File Of SkladType;
    Sklad : PSkladType;
    i,p,k : Byte;
    Ls:LongInt;
    c : Word;
    s1,s2 : TEnjoyStr;
    s3,s4 : String;
    SkidFile : File Of SkidkaType;
    Skidka : PSkidkaType;
Begin
WritePrihodToSkladFile:=False;
New(Sklad,Init);
New(Skidka,Init);
 For i:=1 To L^.DAt.Amount{J} Do
  Begin
   S1:=Copy(L^.Dat.PrihodElement[i].BazKod,1,CRazdelKod);
   Assign(SkladFile,Path.ToSklad+s1+'.db');
   Assign(SkidFile,Path.ToSkidki+s1+'.skl');
   p:=IOResult;
   Reset(SkladFile);
   p:=IOResult;
   If p <> 0 Then
    Begin
     MessageBox(#3^M+#3'Ошибка доступа к файлу '+S1+'.db!',Nil,mfError+mfCancelButton);
     Dispose(Sklad,Done);
     Exit;
    End;

   p:=IOResult;
   Reset(SkidFile);
   p:=IOResult;
   If p <> 0 Then
    Begin
     MessageBox(#3^M+#3'Ошибка доступа к файлу '+S1+'.skl!',Nil,mfError+mfCancelButton);
     Dispose(Skidka,Done);
     Dispose(Sklad,Done);
     Close(SkladFile);
     Exit;
    End;

    Ls:=GetFileLocation3(Copy(L^.Dat.PrihodElement[i].BazKod,CRazdelKod+1,CKod));

    Seek(SkladFile,Ls);
    Seek(SkidFile,Ls);

   {блокируем позицию предварительной блокировкой}
   Repeat
   Pause(1);
   Until Lock(SkladFile,FilePos(SkladFile)*SizeOf(SkladType),SizeOf(SkladType));


   Repeat
   Pause(1);
   Until Lock(SkidFile,FilePos(SkidFile)*SizeOf(SkidkaType),SizeOf(SkidkaType));


   Read(SkladFile,Sklad^.DAt);

   Read(SkidFile,Skidka^.DAt);

    With Skidka^.Dat Do
    Begin
    s4[0]:=#0;
    For c:=1 To CShkala Do
    Begin
     DelSpace(Skidka[c].Proz);
     DelSpace(Skidka[c].Up);
     s4:=s4+Skidka[c].Up+'-'+Skidka[c].Proz+';'
    End;
    End;

    {модифицируем поля}
    {таблица скидок}
   With Skidka^.DAt Do
   Begin
    s3[0]:=#0;
    For c:=1 To CShkala Do
    Begin
     MyStr(StrToReal(L^.Dat.PrihodElement[i].Input.AutoSkidka[c]),CLitr+1,CMAntissa+2,Skidka[c].Proz);
     DelSpace(Skidka[c].Proz);
     s3:=s3+Skidka[c].Up+'-'+Skidka[c].Proz+';'
    End;
    Date:=FDate;
    Time:=Times;
    Caption:=CurrentPassword;
   End;

   {склад}
   With Sklad^.Dat.Input Do
   Begin
       Post:=L^.Dat.PrihodElement[i].Input.Post;
    Zakupka:=L^.Dat.PrihodElement[i].Input.Zakupka;
     R_Zena:=L^.Dat.PrihodElement[i].Input.R_Zena;
     O_Zena:=L^.Dat.PrihodElement[i].Input.O_Zena;
    NSertif:=L^.Dat.PrihodElement[i].Input.NSertif;
    DSertif:=L^.Dat.PrihodElement[i].Input.DSertif;
    KSertif:=L^.Dat.PrihodElement[i].Input.KSertif;
    RealizovatDo:=L^.Dat.PrihodElement[i].Input.RealizovatDo;
    Osn.NaklNumer:=L^.Dat.Osn.NaklNumer;
    Osn.DAteNakl:=L^.Dat.Osn.DateNakl;

 {Sertifikat:=L^.Dat.PrihodElement[i].Input.Sertifikat;}
     Akzis1:=L^.Dat.PrihodElement[i].Input.Akzis1;
     Sklad^.Dat.MakeKod:=L^.Dat.MakeKod;
     Caption:=L^.Dat.Caption;
     DelSpace(L^.Dat.PrihodElement[i].Input.Kol);
     Sklad^.Dat.Date := FDate;
     Sklad^.Dat.Time := Times;
     For k:=1 To CDivision Do
     Str((StrToInt(DivisionS[k])+StrToInt(L^.Dat.PrihodElement[i].Input.DivisionS[k])):CKol,DivisionS[k]);
     Kol[0]:=#0;
   End;
   Sklad^.Dat.MakeVid:=L^.Dat.OperatorSelector;
   Sklad^.Dat.Input.Kol[0]:=#0;
   For k:=1 To CDivision Do
   Str((StrToInt(Sklad^.Dat.Input.DivisionS[k])+StrToInt(Sklad^.Dat.Input.Kol)):CKol,Sklad^.Dat.Input.Kol);
   Sklad^.Dat.Employ:=True;

  {сохраняем изменения}
   Seek(SkidFile,FilePos(SkidFile)-1);
   Write(SkidFile,Skidka^.Dat);

   Seek(SkladFile,FilePos(SkladFile)-1);
   Write(SkladFile,Sklad^.Dat);
  {деблокируем позицию}

   Seek(SkidFile,FilePos(SkidFile)-1);
   Repeat
    UnLock(SkidFile,FilePos(SkidFile)*SizeOf(SkidkaType),SizeOf(SkidkaType));
   Until (DosError=0);

   Seek(SkladFile,FilePos(SkladFile)-1);
   Repeat
    UnLock(SkladFile,FilePos(SkladFile)*SizeOf(SkladType),SizeOf(SkladType));
   Until (DosError=0);

   Close(SkidFile);{закрытие файла}

   Close(SkladFile);{закрытие файла}

   If s3<>s4 Then
    AddProtocol('Коррекция таблицы скидок у '+GetIdField(FName,L^.Dat.PrihodElement[i].BazKod)+
    ' ('+L^.Dat.PrihodElement[i].BazKod+') по приходу N'+L^.Dat.Document+' от '+L^.Dat.DateC+'{!Скидки! приход}',
    'Было:'+s4,
    'Стал:'+s3);

  End;
Dispose(Sklad,Done);
Dispose(Skidka,Done);
WritePrihodToSkladFile:=True;
End;


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
    DInfoMsg('Позиция ['+E^.Dat.PrihodElement[Count].BazKod+'] используется'+Operator+'. Не могу заблокировать позицию!');
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

Procedure PZTestOpenPosition.CalcPosition;
Var R : TRect;
    KolStr : String[3];
Begin
Str(WarningList^.List^.Count:2,KolStr);
Dispose(Control_Pos,Done);
R.Assign(29, 18, 33, 19);
Control_Pos := New(PColoredText, Init(R, #3+KolStr, $4E));
TestW^.Insert(Control_Pos);
End;


Procedure PZTestOpenPosition.MakeReport;
Const Space='                  ';
Var Txt : Text;
    k,c : Word;
    st,s,ws : String;
Begin
 Assign(txt,Path.ToTemp+'closepos.txt');
 c := IOResult;
 Rewrite(txt);
 c:=IoResult;
 If c<>0 Then
  Begin
   MessageBox(^M+#3+'Не могу создать файл '+Path.ToTemp+'closepos.txt!',Nil,mfError+mfCancelButton);
   Exit;
  End;
 DInfoMsg('Формирую отчет. Ждите...');

 Writeln(Txt,Space+'Склад: ',GetClientField(FClient,Rek.Kod,1)+'  Оператор: '+CurrentPassword+' EYE & 1999');

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
 Report(Path.ToTemp+'closepos.txt','',1,False,False,false);
End;

Procedure PZTestOpenPosition.HandleEvent(Var Event:TEVent);
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
                     For c:=0 To WarningList^.List^.Count-1 Do
                      Begin
                       s := WarningList^.GetText(WarningList^.Focused,WarningList^.List^.Count);
                       s:= Copy(s,1+CNAme+1,CArtikul);
                       DInfoMsg('Открываю позицию ['+s+'] для продажи...');
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
                    ClearEvent(Event);
                      End;
        CmDeblock: Begin
                   If(warninglist^.State and sfFocused <> 0)And(warninglist^.List^.Count>=1) Then
                     Begin
                      s := WarningList^.GetText(WarningList^.Focused,WarningList^.List^.Count);
                      s:= Copy(s,1+CNAme+1,CArtikul);
                      DInfoMsg('Открываю позицию ['+s+'] для продажи...');
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
                    ClearEvent(Event);
                   End;
      Else;
    End;
   Else;
   End;


inherited HandleEvent(Event);
End;

destructor PZTestOpenPosition.Done;
Begin
Dispose(WarningList,Done);
Dispose(Control_Pos,Done);
TDialog.Done;
End;




Procedure TPZPrihodWindow.DrawFullName;
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

Procedure TPZPrihodWindow.PrintToFilePr(Var Save : Boolean);
Var s : String;
    st : String[CAll];
    I : Byte;
    J,k : Word;
    TempPrihod : PBox;
    R : TRect;
    t: text;
    BazKod:string[CArtikul];
    R_Zena,Vol:string[CZena];
    Kol: string[CKOl];
    Summa:string[CIZena];
    AllSumma, AllMassa, AllVol:string[CIZena];
    sInPack: string[CInPack];
    sMassa: string[CLitr];
    sVol:String[CKol];
    AllKol:String[CKol];
    sName1,sName2: string[CName];
Begin
Save:=False;

Assign(t,Path.ToTemp+'zakaz.txt');
I:=ioresult;
Rewrite(t);
I:=ioresult;
if i<>0 then
begin
MessageBox(#3^M+#3+'Не могу создать файл '+Path.ToTemp+'zakaz.txt',Nil,mfError+mfCancelButton);
exit;
end;

Writeln(t,'                     Б Л А Н К   З А К А З А');
Writeln(t,' Дата: '+FDate);
Write(t,' Кому: ');
PStaticText(ControlClient)^.GetText(S);
System.Delete(S,Pos(#3,S),1);
Writeln(t,GetMAkeField(FMAke,Copy(S,1+CMake+1,CMakeKod),2));
Writeln(t,' От кого: ООО Продлайн-М');
Writeln(t);

Writeln(t,'┌──────────────────────────┬─────┬────────┬─────┬───┬─────┬───────────────┬─────┬─────┐');
Writeln(t,'│     Товар                │НДС  │Цена кор│ Вес │Фас│Кол.кор Сумма        │объем│вес  │');
Writeln(t,'└──────────────────────────┼─────┼────────┼─────┼───┼─────┼───────────────┼─────┼─────┤');


If NewTovar^.List^.Count>0 Then
Begin
{создаем промежуточный список}
R.Assign(0,0,0,0);
TempPrihod := New(PBox, Init(R, 1, Nil));
TempPrihod^.NewList(New(PTextCollection, Init(1,1)));

AllSumma:='0.00';
AllMassa:='0.00';
AllVol:='0.00';
AllKol:='0';
For i:=0 To NewTovar^.List^.Count-1 Do
 Begin
  s:=NewTovar^.GetText(i,NewTovar^.List^.Limit);
  BazKod:=Copy(s,1+CName+1,CArtikul);
  GetIDField(FNDS,BazKod);
  R_Zena:=Copy(s,CRazdelKod+1+CName+1+(CArtikul-CRazdelKod)+1+CLitr+1+CInPack+1+CKol+1,CZena);
  DelSpace(R_Zena);
  Kol:=Copy(s,CRazdelKod+1+CName+1+(CArtikul-CRazdelKod)+1+CLitr+1+CInPack+1,CKol);


  {Наименование}
  sName2:='';
  sName1:='';
  sName2:=GetIDField(FName2,BazKod);
  delSpace(sName2);
  if sName2<>'' then
  begin
   s[0]:=chr(CName);
   sName1:=s;
   sName2:=GetIDField(FName2,BazKod);
   format(sName2,CName);
                    {┼─────┼────────┼─────┼───┼─────┼───────────────┼─────┼─────┤}
   writeln(t,' '+sName1+'│     │        │     │   │     │               │     │     │');
   s:=sName2;
  end
  else
  s[0]:=chr(CName);

  s:=' '+s+'│';
  {Ставка НДС}
  s:=s+GetIDField(FNDS,BazKod)+'│';
  {Цена}
  rformat(R_Zena,CZena);
  s:=s+R_Zena+'│';
  {вес пачки}
  sInPack:=GetIDField(FInPack,BazKod);
  MyStr(StrToReal(GetIDField(FLitr,BazKod))*StrToReal(sInPack),CLitr,CMantissa,sMassa);
  s:=s+sMassa+'│';
  {фасовка}
  rFormat(sInPack,CInPack);
  s:=s+sInPack+'│';
  {кол-во}
  rformat(Kol,CKOl);
  s:=s+Kol+'│';
  AllKol:=IntToStr(StrToInt(AllKol)+StrToInt(Kol),CKol);
  {Сумма руб}
  MyStr(StrToReal(Kol)*StrToReal(R_Zena),CIZena,CMantissa,Summa);
  MyStr(StrToReal(AllSumma)+StrToReal(Summa),CIZena,CMantissa,AllSumma);
  s:=s+Summa+'│';
  {Объем}
  sVol:=GetIDField(FVol,BazKod);
  MyStr(StrToReal(Kol)*StrToReal(sInPack)*StrToReal(sVol),CKol,CMantissa-1,sVol);
  rformat(sVol,CKol);
  s:=s+sVol+'│';
  MyStr(StrToReal(AllVol)+StrToReal(SVol),CIZena,CMantissa-1,AllVol);
  {Вес}
  MyStr(StrToReal(sMassa)*StrToReal(KOl),CKol,CMantissa-1,sMassa);
  MyStr(StrToReal(AllMassa)+StrToReal(sMassa),CIZena,CMantissa-1,AllMassa);
  s:=s+sMassa+'│';
  writeln(t,s);
  writeln(t,' ─────────────────────────────────────────────────────────────────────────────────────');
  TempPrihod^.List^.Insert(NewStr(S));
  TempPrihod^.SetRange(TempPrihod^.List^.Count);
 End;

End;

rformat(AllKol,CKol);
rformat(AllSumma,CIZena);
rformat(AllVol,CKol);
rformat(AllMassa,CLitr);
writeln(t,' ИТОГО                                               '+AllKol+' '+AllSumma+
' '+AllVol+' '+AllMassa);

(*writeln(t);
writeln(t,' Итого кор.: ',AllKol);
writeln(t,' Итого руб.: ',AllSumma);
writeln(t,' Итого объем: ',AllVol);
writeln(t,' Итого вес: ',AllMassa);*)

writeln(t);
writeln(t,' Менеджер по закупкам _________________________');
writeln(t);
writeln(t,' Торговый отдел       _________________________');
writeln(t);
writeln(t,' Директор             _________________________');
writeln(t);
writeln(t);
Writeln(t,' =====================================================================================');

System.close(t);
Dispose(TempPrihod);

                 If MessageBox(#3^M+#3'Заказ поставщику сформирован!'^M+
                 #3'Печатать заказ поставщику ?',Nil,mfConfirmation+mfOkCancel)=cmOk Then
                  Begin
                   Report(Path.ToTemp+'Zakaz.txt','',1,False,False,false);
                   Save:=true;
                  End;




End;


Procedure DrawPack(SMarket,sOst:string);
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

    Dispose(ControlMrk,Done);
    R.Assign(40, 2, 79, 3);
    ControlMrk := New(PStaticText, Init(R, 'Продажи за 4 нед.:'+SMarket+' Остатки:'+SOst));
    CartWin^.Insert(ControlMrk);


    s:='';{CalcPack(sArtikul,input.kol);}
    DelSpace(s);
    Dispose(ControlPack,Done);
    R.Assign(23, 6, 32, 7);
    ControlPack := New(PColoredText, Init(R, #3+s, $3E));
    CartWin^.Insert(ControlPack);
End;


Procedure DrawProz;
Var s: String[CPack];
    R : TRect;
    Color : Word;
    i : Word;
Begin
    CartWin^.GetData(Input);
    For i:=0 To 11 Do
    Begin
     Color:=$3E;
     If StrToReal(Input.R_Zena)<0.01 Then
      Begin
       {SProz[i+1]:='1.0000';}
      End
     Else
     MyStr(StrToReal(Input.AutoSkidka[i+1])/StrToReal(Input.R_Zena),CLitr+1,CMantissa+2,SProz[i+1]);
     Dispose(ControlProz[i+1],Done);

     R.Assign(31, 8+i, 37, 9+i);
     If StrToReal(Input.AutoSkidka[i+1])<StrToReal(Input.Zakupka)Then Color:= $CF;

     If StrToReal(Input.AutoSkidka[i+1]) < (StrToReal(Input.Zakupka)*(1+StrToReal(GetMinNazenka(SArtikul,I+1))/100))
	Then Color:=$AE;


     ControlProz[i+1] := New(PColoredText, Init(R, #3+SProz[i+1], Color));
     CartWin^.Insert(ControlProz[i+1]);
    End;

    For i:=12 To 23 Do
    Begin
     Color:=$3E;
     If StrToReal(Input.R_Zena)<0.01 Then
      Begin
       {SProz[i+1]:='1.0000';}
      End
     Else

     MyStr(StrToReal(Input.AutoSkidka[i+1])/StrToReal(Input.R_Zena),CLitr+1,CMantissa+2,SProz[i+1]);
     Dispose(ControlProz[i+1],Done);

     R.Assign(60, 8+(i-12), 66, 9+(i-12));
     If StrToReal(Input.AutoSkidka[i+1])<StrToReal(Input.Zakupka)Then Color:= $CF;

     If StrToReal(Input.AutoSkidka[i+1]) < (StrToReal(Input.Zakupka)*(1+StrToReal(GetMinNazenka(SArtikul,I+1))/100))
	Then Color:=$AE;

     ControlProz[i+1] := New(PColoredText, Init(R, #3+SProz[i+1], Color));
     CartWin^.Insert(ControlProz[i+1]);
    End;


End;

Procedure DrawZena;
Var s: String[CPack];
    R : TRect;
    Color : Word;
    i : Byte;
Begin
    CartWin^.GetData(Input);
    For i:=0 To 11 Do
    Begin
    MyStr(StrToReal(Input.R_Zena)*StrToReal(SProz[i+1]),CZena,CMantissa,Input.AutoSkidka[i+1]);
    DelSpace(Input.AutoSkidka[i+1]);
    ControlShkala[i+1]^.SetDAta(Input.AutoSkidka[i+1]);
    Color:=$3E;

    If StrToReal(Input.AutoSkidka[i+1]) < StrToReal(Input.Zakupka) Then Color:=$CF;

     If StrToReal(Input.AutoSkidka[i+1]) < (StrToReal(Input.Zakupka)*(1+StrToReal(GetMinNazenka(SArtikul,I+1))/100))
	Then Color:=$AE;


    Dispose(ControlProz[i+1],Done);

    R.Assign(31, 8+i, 37, 9+i);
    ControlProz[i+1] := New(PColoredText, Init(R, #3+SProz[i+1], Color));
    CartWin^.Insert(ControlProz[i+1]);
    End;

    For i:=12 To 23 Do
    Begin
    MyStr(StrToReal(Input.R_Zena)*StrToReal(SProz[i+1]),CZena,CMantissa,Input.AutoSkidka[i+1]);
    DelSpace(Input.AutoSkidka[i+1]);
    ControlShkala[i+1]^.SetDAta(Input.AutoSkidka[i+1]);
    Color:=$3E;

    If StrToReal(Input.AutoSkidka[i+1]) < StrToReal(Input.Zakupka) Then Color:=$CF;

     If StrToReal(Input.AutoSkidka[i+1]) < (StrToReal(Input.Zakupka)*(1+StrToReal(GetMinNazenka(SArtikul,I+1))/100))
	Then Color:=$AE;



    Dispose(ControlProz[i+1],Done);


    R.Assign(60, 8+(i-12), 66, 9+(i-12));
    ControlProz[i+1] := New(PColoredText, Init(R, #3+SProz[i+1], Color));
    CartWin^.Insert(ControlProz[i+1]);
    End;

{DrawProz;}
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


function TPZCartWindow.CalcOptKol(art: string;var Market,Ost:string):String;
var  FM: file of NewItogType;
     M: PNewItogType;
     Ext: ArtikulStr;
     MarketKol: word;
	sOstKol: string[CKol];
     Start,Stop,Den: longint;
     StartDate,StopDate,Date: string[CDate];
     Day,Srok:word; {DAy дни 0 недели 1}
     iorez,i: word;
     Proc: real;
     fas: integer;

function CalcWeekendSrok:word;
Var St,d,sr:longint;
Begin
 CalcWeekendSrok:=0;
 sr:=0;
 St:=Stop-Srok;
 for d:=st to stop do
 begin
   inc(sr);
   if DayOfWeek(d) in [Sunday, Saturday] then
   inc(sr);
 end;
 CalcWeekendSrok:=sr;
ENd;

Begin
  Day:=1;
  Srok:=4;
  CalcOptKol:='';
  Str(StrToInt(Rek.Kod):2,Ext);
  RFormatZerro(Ext,2);
  If Not SelectVidOstatkiMarket(Day,Srok,StopDate) then exit;
  if day=1 then Srok:=Srok*7;
  CalcOptKol:='';
  DelSpace(art);
  StopDate:=Fdate;
  Stop:=DateStringToDate(DateMask,StopDate);
  Start:=Stop-CalcWeekendSrok;
  MarketKol:=0;
  sOstKol:='0';
  for Den:=Start to Stop do
  begin
   DInfoMsg('Просматриваю проджи за '+DateToDateString(DateMask,DEn));

   Date:=DateToDateString(DateMask,Den);
   If Not FExists(Path.ToArchiv+Date+'.p'+Ext) Then continue;
   Assign(fm,Path.ToArchiv+Date+'.p'+Ext);
   iorez:=ioresult;
   Reset(fm);
   iorez:=ioresult;
   if iorez<>0 then Continue
   else
   begin
     new(M,Init);
     while not eof(fm) do
     begin
       read(fm,m^.dat);
       if StrToInt(art)=StrToInt(m^.Dat.BazKod) then
         begin
           MarketKol:=MarketKol+StrToInt(m^.Dat.MrkC);
           sOstKol:=IntToStr(StrToInt(sOstKol)+StrToInt(m^.Dat.Ost),CKol);
        end;
     end;
     System.Close(fm);
     Dispose(M,Done);
   end;{else}
   NoInfoMsg;
  end; {for Den:=Start to Stop}

  NoInfoMsg;
  fas:=StrToInt(GetIDField(FInPack,art));
  Market:=IntToStr(MarketKol div fas,CKOl+1);
  sOstKol:=BakGetField(FKol,art,0);
  Ost:=IntToStr(StrToInt(sOstKol)div fas,CKol);

  if MarketKol>0 then
  Proc:=(StrToReal(sOstKOl)/MarketKol)*100
  else Proc:=100;

  if Proc-70.0>=0.0009 then CalcOptKol:='0';

  if (Proc-70.0<0.0009) and (Proc-40.0>0.0009) then
     MarketKol:=MarketKol div 2;

  if Proc-40.0<=0.0009 then MarketKol:=MarketKol;

  {начало сезона +20%}
  if GetRazdelBegin(copy(art,1,Crazdelkod)) then
  MarketKol:=MarketKol+(MarketKol div 5);

  {конец сезона -25%}
  if GetRazdelEnd(copy(art,1,Crazdelkod)) then
  MarketKol:=MarketKol-(MarketKol div 4);

  CalcOptKol:=IntToStr(MarketKol div fas,CKol);
End;

Procedure TPZCartWindow.Ini(Var s:String;Regim:Word);
Label 1;
var
  R : TRect;
  c: Word;
  Control : PView;
  zap,SNAlog,WS,SName,SName2,SLitr,SKol,SSertif,SAkzis,SInPack: String[CAll];
  Zen : TDateString;
  Kkol : ArtikulStr;
  As : DocumentEdit;
  ClientKod : ArtikulStr;
  St : Allstr;
  SMsg : TMyString;
  Test,l : LongInt;
  sk : PSkidkaType;
  Shk : Array [1..CShkala] Of String[CIZena];
  s2 : String;
  MMM : MAskanew;
  sMarket,sOst: string;

Begin
SName:=Copy(S,1,CName);
SArtikul:=Copy(S,1+CName+1,CArtikul);
SName2:=GetIdField(FName2,SArtikul);
DelSpaceRight(SNAme2);

SNAlog:=GetIdField(FNAlog,SArtikul);
SLitr:=GetIdField(FLitr,SArtikul);
SInPack:=GetIdField(FInPack,SArtikul);


WordToBitnew(StrToInt(GetIdField(FEnableOtdel,SArtikul)),MMM);
Convertnew(MMM);

sMarket:='0';
sOst:='0';

Case Regim Of
0:Begin
  Input.Zakupka:=BakGetField(FZakupka,SArtikul,0);
  Input.Akzis1:=BakGetField(FAkzis,SArtikul,0);
  Input.NSertif:=BakGetField(FSertif,SArtikul,0);
  Input.DSertif:=BakGetField(FDateSertif,SArtikul,0);
  Input.KSertif:=BakGetField(FKtoSertif,SArtikul,0);
  Input.Post:=BakGetField(FPost,SArtikul,0);
  DelSpaceRight(Input.Post);
  Input.R_Zena:=BakGetField(FRZena,SArtikul,0);
  Input.O_Zena:=BakGetField(FOZena,SArtikul,0);
  Input.RealizovatDo:=BakGetField(FRealiz,SArtikul,0);
  Input.Kol:=CalcOptKol(SArtikul,SmARKET,SoST);

    For c:=1 To CDivision Do
    Begin
    Input.Division[c,0]:=#0;
    DelSpace(Input.Division[c]);
    End;
    Input.Division[1]:=Input.Kol;

    New(sk,Init);
    GetSkidka(SArtikul,Sk^.Dat);
    For c:=1 To CShkala Do
    Begin
     shk[c]:=Sk^.DAt.Skidka[c].Up;
     MyStr(StrToReal(shk[c]),CInputIZena,CMAntissa,Shk[c]);
     SProz[c]:=Sk^.DAt.Skidka[c].Proz;
     MyStr(StrToReal(SProz[c]),CLitr+1,CMAntissa+2,SProz[c]);

     MyStr((StrToReal(Input.R_Zena)*StrToReal(SProz[c])),CZena,CMantissa,Input.AutoSkidka[c]);
     DelSpace(Input.AutoSkidka[c]);
    End;
    Dispose(Sk,Done);
{  ws:=GetKodMake(SArtikul);}
  End;
1:Begin
  With Input Do
   Begin
{    ws:=Copy(s,1+CName+1+CArtikul+1+CLitr+1+CInPack+1+CKol+1+CZena+1+CZena+1+CSertif+1+CAkzis+1+CLitr+1,CMakeKod);}
    Zakupka:=Copy(s,1+CName+1+CArtikul+1+CLitr+1+CInPack+1+CKol+1+CZena+1+CZena+1+CNSertif+CDSertif+CKSertif+CAkzis1,CZena);
    Akzis1:=Copy(s,1+CName+1+CArtikul+1+CLitr+1+CInPack+1+CKol+1+CZena+1+CZena+1+CNSertif+CDSertif+CKSertif,CAkzis1);
    NSertif:=Copy(s,1+CName+1+CArtikul+1+CLitr+1+CInPack+1+CKol+1+CZena+1+CZena+1,CNSertif);
    DSertif:=Copy(s,1+CName+1+CArtikul+1+CLitr+1+CInPack+1+CKol+1+CZena+1+CZena+1+CNSertif,CDSertif);
    KSertif:=Copy(s,1+CName+1+CArtikul+1+CLitr+1+CInPack+1+CKol+1+CZena+1+CZena+1+CNSertif+CDSertif,CKSertif);
    R_Zena:=Copy(s,1+CName+1+CArtikul+1+CLitr+1+CInPack+1+CKol+1,CZena);
    O_Zena:=Copy(s,1+CName+1+CArtikul+1+CLitr+1+CInPack+1+CKol+1+CZena+1,CZena);
{*******}
    Input.RealizovatDo:=GetRealiz(SArtikul);

    For c:=1 To CDivision Do
    Begin
    Division[c]:=Copy(s,1+CName+1+CArtikul+1+CLitr+1+CInPack+1+CKol+1+CZena+1+CZena+
      1+CNSertif+CDSertif+CKSertif+CAkzis1+CZena+CKol*(c-1),CKol);
    DelSpace(Division[c]);
    End;


    For c:=1 To CShkala Do
    Begin
    SProz[c]:=GetSkidkaList(SArtikul,c);
    MyStr((StrToReal(R_Zena)*StrToReal(SProz[c])),CZena,CMantissa,AutoSkidka[c]);
    DelSpace(AutoSkidka[c]);
    End;

    Post:=Copy(s,1+CName+1+CArtikul+1+CLitr+1+CInPack+1+CKol+1+CZena+1+CZena+
      1+CNSertif+CDSertif+CKSertif+CAkzis1+Czena+CKol*CDiviSion,CPost);
     Kol:=Copy(s,1+CName+1+CArtikul+1+CLitr+1+CInPack+1,CKol);


    New(sk,Init);
    GetSkidka(SArtikul,Sk^.Dat);
    For c:=1 To CShkala Do
    Begin
     shk[c]:=Sk^.DAt.Skidka[c].Up;
     MyStr(StrToReal(shk[c]),CInputIZena,CMAntissa,Shk[c]);
    End;
    Dispose(Sk,Done);

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
DelSpaceRight(Input.DSertif);
DelSpaceRight(Input.KSertif);
DelSpaceRight(Input.Akzis1);
ClearFind;

1:
DInfo('Читаю информацию о товаре...');
R.Assign(0, 0, 80, 23);
New(CartWin, Init(R, 'Карточка товара'));
CartWin^.Palette := dpCyanDialog;
CartWin^.Options := CartWin^.Options or ofCenterX;
CartWin^.HelpCtx := $E191;

R.Assign(29, 3, 36, 4);
Control1 := New(PInputLine, Init(R, 5));
CartWin^.Insert(Control1);
  PInputLine(Control1)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));
  If MMM[1]=0 Then Control1^.Options:=Control1^.Options and not ofSelectable;

  If FindParam('/BAKREGIM') Then
  If GlobalStatus=1 Then Control1^.Options:=Control1^.Options and not ofSelectable;

  R.Assign(26, 3, 29, 4);
  CartWin^.Insert(New(PLabel, Init(R, '~1~:', Control1)));

R.Assign(39, 3, 46, 4);
Control2 := New(PInputLine, Init(R, CKol));
CartWin^.Insert(Control2);
  PInputLine(Control2)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));
  {If MMM[2]=0 Then }Control2^.Options:=Control2^.Options and not ofSelectable;

  If FindParam('/BAKREGIM') Then
  If GlobalStatus=0 Then Control2^.Options:=Control2^.Options and not ofSelectable;

  R.Assign(36, 3, 39, 4);
  CartWin^.Insert(New(PLabel, Init(R, '~2~:', Control2)));


R.Assign(49, 3, 56, 4);
Control3 := New(PInputLine, Init(R, CKol));
CartWin^.Insert(Control3);
  PInputLine(Control3)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));
  {If MMM[3]=0 Then }Control3^.Options:=Control3^.Options and not ofSelectable;
  If FindParam('/BAKREGIM') Then
  If GlobalStatus=0 Then Control3^.Options:=Control3^.Options and not ofSelectable;

  R.Assign(46, 3, 49, 4);
  CartWin^.Insert(New(PLabel, Init(R, '~3~:', Control3)));


R.Assign(59, 3, 66, 4);
Control4 := New(PInputLine, Init(R, CKol));
CartWin^.Insert(Control4);
  PInputLine(Control4)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));
  {If MMM[4]=0 Then }Control4^.Options:=Control4^.Options and not ofSelectable;
  If FindParam('/BAKREGIM') Then
  If GlobalStatus=0 Then Control4^.Options:=Control4^.Options and not ofSelectable;

  R.Assign(56, 3, 59, 4);
  CartWin^.Insert(New(PLabel, Init(R, '~4~:', Control4)));


R.Assign(69, 3, 76, 4);
Control5 := New(PInputLine, Init(R, CKol));
CartWin^.Insert(Control5);
  PInputLine(Control5)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));
  {If MMM[5]=0 Then }Control5^.Options:=Control5^.Options and not ofSelectable;
  If FindParam('/BAKREGIM') Then
  If GlobalStatus=0 Then Control5^.Options:=Control5^.Options and not ofSelectable;

  R.Assign(66, 3, 69, 4);
  CartWin^.Insert(New(PLabel, Init(R, '~5~:', Control5)));

R.Assign(29, 5, 36, 6);
Control6 := New(PInputLine, Init(R, CKol));
CartWin^.Insert(Control6);
  PInputLine(Control6)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));
  {If MMM[6]=0 Then }Control6^.Options:=Control6^.Options and not ofSelectable;
  If FindParam('/BAKREGIM') Then
  If GlobalStatus=0 Then Control6^.Options:=Control6^.Options and not ofSelectable;

  R.Assign(26, 5, 29, 6);
  CartWin^.Insert(New(PLabel, Init(R, '~6~:', Control6)));


R.Assign(39, 5, 46, 6);
Control7 := New(PInputLine, Init(R, CKol));
CartWin^.Insert(Control7);
  PInputLine(Control7)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));
  {If MMM[7]=0 Then }Control7^.Options:=Control7^.Options and not ofSelectable;
  If FindParam('/BAKREGIM') Then
  If GlobalStatus=0 Then Control7^.Options:=Control7^.Options and not ofSelectable;

  R.Assign(36, 5, 39, 6);
  CartWin^.Insert(New(PLabel, Init(R, '~7~:', Control7)));


R.Assign(49, 5, 56, 6);
Control8 := New(PInputLine, Init(R, CKol));
CartWin^.Insert(Control8);
  PInputLine(Control8)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));
  {If MMM[8]=0 Then }Control8^.Options:=Control8^.Options and not ofSelectable;
  If FindParam('/BAKREGIM') Then
  If GlobalStatus=0 Then Control8^.Options:=Control8^.Options and not ofSelectable;

  R.Assign(46, 5, 49, 6);
  CartWin^.Insert(New(PLabel, Init(R, '~8~:', Control8)));






R.Assign(38, 6, 48, 7);
{if strtoint(currentpassword)=0 then
begin}
ControlZakupka := New(PInputLine, Init(R, CZena));
CartWin^.Insert(ControlZakupka);
  PInputLine(ControlZakupka)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));
ControlZakupka^.Options := ControlZakupka^.Options and not ofSelectable;
{
end
 else
  begin
  Control := New(PSInputLine, Init(R, CZena));
  Control^.Options := Control^.Options and not ofSelectable;
  CartWin^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));
  end;
}
  R.Assign(33, 6, 38, 7);
  CartWin^.Insert(New(PLabel, Init(R, '~З~/Ц:', ControlZakupka)));

R.Assign(53, 6, 63, 7);
R_ZenaControl := New(PInputLine, Init(R, CZena));
R_ZenaControl^.Options := R_ZenaControl^.Options and not ofSelectable;
CartWin^.Insert(R_ZenaControl);
  PInputLine(R_ZenaControl)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));

  R.Assign(48, 6, 53, 7);
  CartWin^.Insert(New(PLabel, Init(R, '~Р~/Ц:', R_ZenaControl)));

R.Assign(68, 6, 78, 7);
ControlOZ := New(PInputLine, Init(R, CZena));
ControlOZ^.Options := ControlOZ^.Options and not ofSelectable;
CartWin^.Insert(ControlOZ);

  PInputLine(ControlOZ)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));

  R.Assign(63, 6, 68, 7);
  CartWin^.Insert(New(PLabel, Init(R, '~О~/Ц:', ControlOZ)));


R.Assign(18, 7, 41, 8);
Control := New(PColoredText, Init(R, #3+' Настройка шкалы цен ',$4F));
Control^.Options:=Control^.Options and not ofSelectable;
CArtWin^.Insert(Control);


R.Assign(2, 8, 66, 20);
Control := New(PColoredText, Init(R, '', $3E));
Control^.Options := Control^.Options or ofFramed;
Control^.Options:=Control^.Options and not ofSelectable;
CartWin^.Insert(Control);


For c:=0 To 11 Do
 Begin
  R.Assign(2, 8+c, 20, 9+c);
  Control := New(PStaticText, Init(R, 'от '+shk[c+1]+' :'));
  CartWin^.Insert(Control);

  R.Assign(31, 8+c, 36, 9+c);
  ControlProz[c+1] := New(PStaticText, Init(R, SProz[c]));
  CartWin^.Insert(ControlProz[c+1]);

  R.Assign(20, 8+c, 30, 9+c);
  ControlShkala[c+1] := New(PInputLine, Init(R, CZena));
  ControlShkala[c+1]^.Options := ControlShkala[c+1]^.Options and not ofSelectable;

  CartWin^.Insert(ControlShkala[c+1]);
  PInputLine(ControlShkala[c+1])^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));
 End;

For c:=12 To 23 Do
 Begin
  R.Assign(31, 8+(c-12), 49, 9+(c-12));
  Control := New(PStaticText, Init(R, 'от '+shk[c+1]+' :'));
  CartWin^.Insert(Control);

  R.Assign(60, 8+(c-12), 66, 9+(c-12));
  ControlProz[c+1] := New(PStaticText, Init(R, SProz[c]));
  CartWin^.Insert(ControlProz[c+1]);

  R.Assign(49, 8+(c-12), 59, 9+(c-12));
  ControlShkala[c+1] := New(PInputLine, Init(R, CZena));
  ControlShkala[c+1]^.Options := ControlShkala[c+1]^.Options and not ofSelectable;

  CartWin^.Insert(ControlShkala[c+1]);
  PInputLine(ControlShkala[c+1])^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));

 End;


R.Assign(13, 21, 40, 22);
ControlS := New(PInputLine, Init(R, CNSertif));
ControlS^.Options:=ControlS^.Options and not ofSelectable;
CartWin^.Insert(ControlS);
  R.Assign(1, 21, 13, 22);
  CartWin^.Insert(New(PLabel, Init(R, '~С~ертификат:', ControlS)));


R.Assign(51, 21, 61, 22);
Control := New(PInputLine, Init(R, CDSertif));
CartWin^.Insert(Control);
Control^.Options:=Control^.Options and not ofSelectable;
  PInputLine(Control)^.Validator := New(PPXPictureValidator, Init(DateFiltr, True));

  R.Assign(40, 21, 50, 22);
  CartWin^.Insert(New(PLabel, Init(R, 'Срок д~е~йс:', Control)));



R.Assign(8, 22, 35, 23);
Control := New(PInputLine, Init(R, CKSertif));
Control^.Options:=Control^.Options and not ofSelectable;
CartWin^.Insert(Control);

  R.Assign(1, 22, 8, 23);
  CartWin^.Insert(New(PLabel, Init(R, '~В~ыдан:', Control)));



R.Assign(67, 18, 77, 19);
Control := New(PInputLine, Init(R, CDate));
  PInputLine(Control)^.Validator := New(PPXPictureValidator, Init(DateFiltr, True));
Control^.Options:=Control^.Options and not ofSelectable;
CartWin^.Insert(Control);

  R.Assign(67, 17, 77, 18);
  CartWin^.Insert(New(PLabel, Init(R, 'Годен до:', Control)));



R.Assign(41, 22, 57, 23);
Control := New(PInputLine, Init(R, CAkzis1));
Control^.Options:=Control^.Options and not ofSelectable;
CartWin^.Insert(Control);

  R.Assign(35, 22, 41, 23);
  CartWin^.Insert(New(PLabel, Init(R, '~Г~ТД:', Control)));


R.Assign(58, 22, 75, 23);
Control := New(PInputLine, Init(R, CPost));
Control^.Options:=Control^.Options and not ofSelectable;
CartWin^.Insert(Control);

  R.Assign(75, 22, 78, 23);
  CartWin^.Insert(New(PHistory, Init(R, PInputline(Control), 99)));

  R.Assign(61, 21, 75, 22);
  CartWin^.Insert(New(PLabel, Init(R, 'Производ-ль:', Control)));



R.Assign(1, 1, 79, 2);
Control := New(PStaticText, Init(R, 'Наименование:'+SName+' Код:'+SArtikul+' Масса:'+SLitr+' Фас:'+SInPack+
' НП:'+SNAlog));
CartWin^.Insert(Control);

R.Assign(40, 2, 79, 3);
ControlMrk := New(PStaticText, Init(R, 'Продажи за 4 нед.:'+SMarket+' Остатки:'+SOst));
CartWin^.Insert(ControlMrk);


If SNAme2[0]<>#0 Then
Begin
 R.Assign(14, 2, 40, 3);
 Control := New(PStaticText, Init(R, sName2));
 CartWin^.Insert(Control);
End;



R.Assign(14, 6, 23, 7);
Control := New(PColoredText, Init(R, '', $31));
CartWin^.Insert(Control);

R.Assign(23, 6, 32, 7);
ControlPack := New(PStaticText, Init(R, #3+'0'));
CartWin^.Insert(ControlPack);

R.Assign(3, 3, 25, 4);
Control := New(PStaticText, Init(R, 'Количество (упаковок):'));
CartWin^.Insert(Control);

R.Assign(3, 4, 24, 5);
Control := New(PStaticText, Init(R, ''));
CartWin^.Insert(Control);

R.Assign(1, 6, 8, 7);
Control := New(PColoredText, Init(R, 'Кол-во:', $31));
CartWin^.Insert(Control);

R.Assign(8, 6, 13, 7);
ControlKol := New(PStaticText, Init(R, #3+'0'));
CartWin^.Insert(ControlKol);

R.Assign(5, 5, 20, 6);
Control := New(PColoredText, Init(R, '', $31));
CartWin^.Insert(Control);


R.Assign(58, 0, 78, 1);
If GetIdMArket(SArtikul)=1 Then
Control := New(PColoredText, Init(R, 'Продажа: разрешена', $3F))
Else
Control := New(PColoredText, Init(R, 'Продажа: запрещена', $DF));

CartWin^.Insert(Control);


CartWin^.SelectNext(False);

CartWin^.SetData(Input);

NoInfo;

DrawPack(sMarket,sOst);
DrawZena;

{If Status = DocNormal Then DrawOpt;}

c:=Desktop^.ExecView(CartWin);
If c<>cmCancel Then
 Begin

  CartWin^.GetData(Input);
  DelSpaceRight(Input.NSertif);
  DelSpaceRight(Input.DSertif);
  DelSpaceRight(Input.KSertif);
  DelSpace(Input.RealizovatDo);

  MyStr(StrToReal(Input.R_Zena),CZena,CMantissa,Input.R_Zena);
  DelSpace(Input.R_Zena);
  MyStr(StrToReal(Input.Zakupka),CZena,CMantissa,Input.Zakupka);
  DelSpace(Input.Zakupka);
  MyStr(StrToReal(Input.O_Zena),CZena,CMantissa,Input.O_Zena);
  DelSpace(Input.O_Zena);
{  SMakeList:=MakeList^.GetText(MakeList^.Focused,Makelist^.List^.Count);}
  Dispose(Control,Done);
  Dispose(CartWin,Done);

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

   DelSpace(Input.DSertif);
   If (Input.DSertif[0]<>#0) Then
   Begin
   If Not(TestDate(Input.DSertif,Test)) Then
    Begin
     MessageBox(^M+#3'Ошибка при вводе срока действия сертификата!',Nil,mfError+mfCancelButton);
     Goto 1;
    End;
   If ShowSertif=1 Then
    If DateStringToDate(DateMask,Input.DSertif)<DateStringToDate(DateMask,FDAte) Then
     Begin
      SpecialBeep;
      MessageBox(^M+#3'Срок действия сертификата уже истек!',Nil,mfWarning+mfCancelButton);
     End;
   End
   Else
   If ShowSertif=1 Then
     MessageBox(^M+#3'Не указан срок действия сертификата!',Nil,mfError+mfCancelButton);

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
   End;



If Not(FindParam('/NOTEST')) Then
Begin

  If (StrTOReal(Input.Zakupka)<0.009) And (OperatorSelector=2) Then
        Begin
          MessageBox(#3+ErrorZakupka,nil, mfError + mfCancelButton);
          GoTo 1;
        End;
End;


  If (StrToReal(Input.R_Zena)<>StrTOReal(Input.O_Zena)) Then
   Begin
     MessageBox(#3^M+#3+'Розничная цена не равна оптовой !',nil, mfError + mfCancelButton);
     GoTo 1;
   End;



{$IFDEF Opt}
  If Not FindParam('/NO19') Then
  If ((StrToReal(Input.Zakupka)*1.19)>StrTOReal(Input.R_Zena)) Then
   Begin
     SpecialBeep;
     MessageBox(#3^M+#3+'Наценка менее 19%!',nil, mfError + mfCancelButton);
     If StrToInt(CurrentPAssword)<>0 Then GoTo 1;
   End;
{$ENDIF}


   Format(SInpack,CInPack);
  s:=SName+'│'+SArtikul+'│'+SLitr+'│'+SInPack+'│';
  With Input Do
   Begin
   Format(Kol,CKol);
   MyStr(StrToReal(SInpack)*StrToReal(Zakupka),CZena,CMantissa,Zakupka);
   Format(Zakupka,CZena);
   MyStr(StrToReal(SInpack)*StrToReal(R_Zena),CZena,CMantissa,R_Zena);
   Format(R_Zena,CZena);
   MyStr(StrToReal(SInpack)*StrToReal(O_Zena),CZena,CMantissa,O_Zena);;
   Format(O_Zena,CZena);
   Format(NSertif,CNSertif);
   Format(DSertif,CDSertif);
   Format(KSertif,CKSertif);
   Format(Akzis1,CAkzis1);
{   s:=s+Kol+'│'+R_Zena+'│'+O_Zena+'│'+NSertif+DSertif+KSertif+'│'+Akzis1+'│'+Zakupka+'│';}
   s:=s+Kol+'│'+Zakupka+'│'+O_Zena+'│'+NSertif+DSertif+KSertif+Akzis1+Zakupka;

   For c:=1 To CDivision Do
    Begin
     Input.Division[c]:=InttoStr(StrToInt(Input.Division[c]),CKol);
     Format(Input.Division[c],CKol);
     s:=s+Input.Division[c]{+'│'};
    End;

   DelSpaceRight(Input.Post);
   ChekPost(Input.Post);
   Format(Input.Post,CPost);
   s:=s+Input.Post;

   DelSpace(Input.RealizovatDo);
   Format(Input.RealizovatDo,CDate);

   s2:=SArtikul+'│'+Input.RealizovatDo+'│';



   For c:=1 To CShkala Do
    Begin
     SProz[c]:=RealtoStr(StrToReal(SProz[c]),CLitr+1,CMantissa+2);
     Format(SProz[c],CLitr+1);
     s2:=s2+SProz[c]{+'│'};
    End;
   End;

(*   System.Delete(s,236,1);{удаление последнего разделителя }*)
   If Regim=1 Then
    Begin
     NewTovar^.List^.AtFree(NewTovar^.Focused);
     NewTovar^.SetRange(NewTovar^.List^.Count);

     SkidkaList^.List^.AtFree(Location(SkidkaList,SArtikul,True));
     SkidkaList^.SetRange(SkidkaList^.List^.Count);
    End;



   NewTovar^.List^.Insert(NewStr(S));
   NewTovar^.SetRange(NewTovar^.List^.Count);
   NewTovar^.FocusItem(LoCation(NewTovar,SArtikul,ProdagaWindow));

   SkidkaList^.List^.Insert(NewStr(S2));
   SkidkaList^.SetRange(SkidkaList^.List^.Count);

 End
 Else
 Begin
  Dispose(Control,Done);
  Dispose(CartWin,Done);
 End;

End;

Destructor TPZCartWinDow.Done;
Var c: Word;
Begin
Dispose(ControlKol,Done);
{If Status = DocNormal Then
Begin}
Dispose(ControlZakupka,Done);
Dispose(R_ZenaControl,Done);
Dispose(ControlOZ,Done);
{End;}
Dispose(ControlPack,Done);

For c:=1 To CShkala Do
Begin
 Dispose(ControlProz[c],Done);
 Dispose(ControlShkala[c],Done);
End;

TDialog.Done;
End;


procedure TPZCartWindow.HandleEvent(var Event: TEvent);

procedure Calculator;
begin
  Calc^.Start;
end;

Var DrawP : Boolean;
Begin
Case Event.What Of
 evCommand :
   Case Event.Command Of
        cmLocalCalc:Calculator;
   Else;
   End;
   Else;
   End;
  If (Event.What=evKeyboard)And(Event.KeyCode=kbF1) then AboutCHM('24');
  If (Event.What=evKeyboard)And((Event.CharCode in ['0','1','2','3','4','5','6','7','8','9','.'])
  Or (Event.KeyCode=kbDel) Or (Event.KeyCode=kbBack)){And(Status=DocNormal)}
  And((R_ZenaConTrol^.State and sfFocused <> 0)
  or  (ControlZakupka^.State and sfFocused <> 0)) Then
  Begin
  Inherited HandleEvent(Event);

  {DrawOpt;}
  {DrawZena;}

  End
  Else
  Begin


  If (Event.What=evKeyboard)And((Event.CharCode in ['0','1','2','3','4','5','6','7','8','9','.'])
  Or (Event.KeyCode=kbDel) Or (Event.KeyCode=kbBack)) Then DrawP:=True
  Else DrawP:=False;
  inherited HandleEvent(Event);
  If DrawP Then Begin

                End;
  End;
  ClearEvent(Event);
End;



Procedure TestStatusPrihod;
Var j : Word;
    s,st : String;
    DivisionS : TKolString;
Begin
If FindParam('/BAKREGIM') Then
Begin
    If NewTovar^.List^.Count>0 Then
     Begin
       s:=NewTovar^.GetText(0,NewTovar^.List^.Limit);
       st:=Copy(s,1+CName+1,CRazdelKod);
       System.Delete(s,1+CName+1,CRazdelKod);
       System.Insert(st+'│',s,1);
       For j:=1 To CDivision Do
       Begin
        DivisionS[j]:=Copy(s,1+CRazdelKod+1+CName+1+(CArtikul-CRazdelKod)+1+CLitr+1+CInPack+1+CKol+1+CZena+1+CZena+
        1+CNSertif+CDSertif+CKSertif+CAkzis1+CZena+CKol*(j-1){+1*(j-1)},CKol);
        DelSpace(DivisionS[j]);
       End;

       If StrToInt(DivisionS[1])>0 Then GlobalStatus:=0
       Else GlobalStatus:=1;
     End
    Else
     Begin
      If MessageBox(^M+#3'Будете оформлять розничный приход?',Nil,mfConfirmation+mfOkCancel)=cmOk Then
	 GlobalStatus:=0
      Else GlobalStatus:=1;
     End;
End
 Else
  GlobalStatus:=0;
End;


procedure TPZPrihodWindow.OpenPrihodWindow;
Var l : Boolean;
begin
  l:=False;
  ClearFind;
  if Message(Desktop, evBroadcast, cmPostZak, nil) = nil then
  begin
    DInfo('Инициализация заказа...');
    L:=True;
    PZPrihodWindow := New(PPZPrihodWindow, Init(L));
    If L Then
    Begin
    Application^.InsertWindow(PZPrihodWindow);
    NoInfo;
    End
    Else
     Begin
      TekDAte:=FDate;
      Status:=DocNormal;
      Dispose(PZPrihodWindow,Done);
      NoInfo;
     End;
  end
  else
    if PView(PZPrihodWindow) <> Desktop^.TopView then PZPrihodWindow^.Select;
end;

constructor TPZPrihodWindow.Init(Var l : Boolean);
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
  SName : String[CName];
  SLitr : String[CLitr];
  SPack : String[CInPack];
  Event : TEvent;
  s2 : String;

begin
R.Assign(0, 0, 80, 23);
PrevS:='Формирование заявки';

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
  begin
    I:=0;
    If I=777 Then
     Begin
      Beep;
      DinfoMsg('Не могу заблокировать док-т прихода N '+PrevPrihod^.Dat.Document+' от '+PrevPrihod^.Dat.DateC+
         '. Попробуйте повторить!');
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

    DocumentNumer:='1';
   End;

R.Assign(56, 0, 79, 1);
ControlOperatorSelect := New(PRadioButtons, Init(R,
  NewSItem('К~л~',
  NewSItem('С',
  NewSItem('~О~б', Nil)))));
  Insert(ControlOperatorSelect);

OperatorSelector:=2;

PCluster(ControlOperatorSelect)^.SetButtonState($00000003, False);
Insert(ControlOperatorSelect);


ControlOperatorSelect^.SetData(OperatorSelector);

  R.Assign(51, 0, 56, 1);
  Insert(New(PLabel, Init(R, 'Вид:', ControlOperatorSelect)));

R.Assign(0, 0, 0, 0);
Client := New(PBox, Init(R, 1, Nil));
Client^.NewList(New(PTextCollection, Init(1,1)));




Case OperatorSelector Of
0:Assign (MakeFile,Path.ToClient+'Make.db');
1:Assign (MakeFile,Path.ToClient+'Sklad.db');
2:Assign (MakeFile,Path.ToClient+'Barter.db');
Else;
End;


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

     ReadMAke(MakeFile,MakeElement^.Dat);
     {
     Repeat
      NetCall.UnLock(MakeFile,(FilePos(MakeFile)-1)*SizeOf(ClientType),SizeOf(ClientType));
     Until (DosError=0);
     }
  If MakeElement^.Dat.Employ Then
   Begin
    Format (MakeElement^.Dat.Name,CClient);
    Client^.List^.Insert(NewStr(MakeElement^.Dat.Name+'│'+MakeElement^.Dat.Kod));
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
Assign (RazdelFile,Path.ToRazdel+'razdel.db');
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
Assign (BazFile,Path.ToSklad+Prevs+'.db');
Reset (BazFile);
While Not(Eof(BazFile)) Do
 Begin
     {
     Repeat
     Until NetCall.Lock(BazFile,FilePos(BazFile)*SizeOf(SkladType),SizeOf(SkladType));
     }
     ReadSklad(BazFile,BazElement^.Dat);
     {
     Repeat
      NetCall.UnLock(BazFile,(FilePos(BazFile)-1)*SizeOf(SkladType),SizeOf(SkladType));
     Until (DosError=0);
     }

  If BazElement^.Dat.Employ Then
{  If GetIdEmploy(BazElement.BazKod) Then}
   Begin
    SName:=GetIdField(FName,BazElement^.Dat.BazKod);
    Format(SName,CName);
    SLitr:=GetIdField(FLitr,BazElement^.Dat.BazKod);
    Format(SLitr,CLitr);
    Format (BazElement^.Dat.Input.Kol,CLitr);
    SPack:=GetIdField(FInPack,BazElement^.Dat.BazKod);
    Format(SPack,CInPack);
    MyStr(StrToReal(BazElement^.Dat.Input.Zakupka),CZena,CMantissa,BazElement^.Dat.Input.Zakupka);
    MyStr(StrToReal(BazElement^.Dat.Input.R_Zena),CZena,CMantissa,BazElement^.Dat.Input.R_Zena);
    MyStr(StrToReal(BazElement^.Dat.Input.O_Zena),CZena,CMantissa,BazElement^.Dat.Input.O_Zena);
    Format (BazElement^.Dat.Input.Zakupka,CZena);
    Format (BazElement^.Dat.Input.R_Zena,CZena);
    Format (BazElement^.Dat.Input.O_Zena,CZena);

    Format (BazElement^.Dat.Input.NSertif,CNSertif);
    Format (BazElement^.Dat.Input.DSertif,CDSertif);
    Format (BazElement^.Dat.Input.KSertif,CKSertif);

    DelSpace(BazElement^.Dat.Input.Kol);
    RFormat (BazElement^.Dat.Input.Kol,CLitr);
    Prevs:=SName+'│'+BazElement^.Dat.BazKod+'│'+SLitr+
    '│'+SPAck+'│'+BazElement^.Dat.Input.Kol+'│'+
    +BazElement^.Dat.Input.R_Zena+'│'+BazElement^.Dat.Input.O_Zena+'│'+BazElement^.Dat.Input.NSertif+
    BazElement^.Dat.Input.DSertif+BazElement^.Dat.Input.KSertif;
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
  Insert(New(PLabel, Init(R, '~Н~аименование товара         Код  Литр. Фас Колич Р/Цена   О/Цена   Сертификат', Baz)));

R.Assign(79, 14, 80, 22);
Control := New(PScrollBar, Init(R));
Insert(Control);

R.Assign(1, 14, 79, 22);
SkidkaList := New(PBox, Init(R, 1, Nil));
SkidkaList^.NewList(New(PTextCollection, Init(1,1)));


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
    Format(PrevPrihod^.Dat.PrihodElement[c].Input.NSertif,CNSertif);
    Format(PrevPrihod^.Dat.PrihodElement[c].Input.DSertif,CDSertif);
    Format(PrevPrihod^.Dat.PrihodElement[c].Input.KSertif,CKSertif);
    Format(PrevPrihod^.Dat.PrihodElement[c].Input.Akzis1,CAkzis1);
    Format(PrevPrihod^.Dat.PrihodElement[c].Input.Zakupka,CZena);
    Format(PrevPrihod^.Dat.PrihodElement[c].Input.Post,CPost);
    Format(PrevPrihod^.Dat.MakeKod,CMakeKod);
    s:=s+'│'+PrevPrihod^.Dat.PrihodElement[c].Input.Kol+'│'+PrevPrihod^.Dat.PrihodElement[c].Input.R_Zena
     +'│'+PrevPrihod^.Dat.PrihodElement[c].Input.O_Zena+'│'+PrevPrihod^.Dat.PrihodElement[c].Input.NSertif+
     PrevPrihod^.Dat.PrihodElement[c].Input.DSertif+PrevPrihod^.Dat.PrihodElement[c].Input.KSertif+
     +PrevPrihod^.Dat.PrihodElement[c].Input.Akzis1+PrevPrihod^.Dat.PrihodElement[c].Input.Zakupka;
    For i:=1 To CDiviSion Do
    Begin
     Format(PrevPrihod^.Dat.PrihodElement[c].Input.DivisionS[i],CKol);
     s:=s+PrevPrihod^.Dat.PrihodElement[c].Input.DivisionS[i]{+'│'};
    End;
(*    System.Delete(s,236,1);{удаление последнего разделителя }*)
    s:=s+PrevPrihod^.Dat.PrihodElement[c].Input.Post;


    DelSpace(PrevPrihod^.Dat.PrihodElement[c].Input.RealizovatDo);
    Format(PrevPrihod^.Dat.PrihodElement[c].Input.RealizovatDo,CDate);
    s2:=PrevPrihod^.Dat.PrihodElement[c].BazKod+'│'+PrevPrihod^.Dat.PrihodElement[c].Input.RealizovatDo+'│';
    For i:=1 To CShkala Do
    Begin
     Format(PrevPrihod^.Dat.PrihodElement[c].Input.AutoSkidka[i],CLitr+1);
     s2:=s2+PrevPrihod^.Dat.PrihodElement[c].Input.AutoSkidka[i];
    End;



    NewTovar^.List^.Insert(NewStr(s));
    NewTovar^.SetRange(NewTovar^.List^.Count);

    SkidkaList^.List^.Insert(NewStr(s2));
    SkidkaList^.SetRange(SkidkaList^.List^.Count);

   End;
 End;

NewTovar^.HelpCtx:=$E150;
NewTovar^.FocusItem(0);
Insert(NewTovar);

  R.Assign(1, 13, 79, 14);
  Insert(New(PLabel, Init(R, 'Заказываемые  товары       Код  Литр. Фас Колич   Цена   Р/Цена   Сертификат', NewTovar)));


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
Control_IO := New(PColoredText, Init(R, '0.00',$4E));
Insert(Control_IO);

R.Assign(52, 22, 63, 23);
Control := New(PColoredText, Init(R, ' Итого Р/Ц:', $74));
Insert(Control);

R.Assign(63, 22, 78, 23);
Control_IR := New(PColoredText, Init(R, '0.00', $4E));
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
Control := New(PColoredText, Init(R, ' Итого масса:', $74));
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

{TestStatusPrihod;}

CalcItogo;
AddName;

L:=True;

PrevS[0]:=#0;
PrevNAme[0]:=#0;

end;

procedure TPZPrihodWindow.CalcItogo;
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
ZZ:=Copy(NewTovar^.GetText(ls,NewTovar^.List^.Limit),1+CName+1+CArtikul+1+CLitr+1+CInPack+1+CKol+1+CZena+1+CZena+
         1+CNSertif+CDSertif+CKSertif+CAkzis1,CZena);
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

MyStr(Sl,CILitr,CMantissa,Itogo_L);
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
{If StrToInt(CurrentPassword)=0 Then}
Control_Zakupka := New(PColoredText, Init(R,#3+AllZakupka,$7E));
{Else
Control_Zakupka := New(PColoredText, Init(R,#3+'!!!.!!',$7E));}

Insert(Control_Zakupka);
End;



Procedure TPZPrihodWindow.AddName;

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


Procedure TPZPrihodWindow.Refresh;
Var i : Byte;
    R : TRect;
Begin
R.Assign(0, 0, 0, 0);
Client := New(PBox, Init(R, 1, Nil));
Client^.NewList(New(PTextCollection, Init(1,1)));

DInfo('Обновляю список клиентов...');

Case OperatorSelector Of
0:Assign (MakeFile,Path.ToClient+'Make.db');
1:Assign (MakeFile,Path.ToClient+'Sklad.db');
2:Assign (MakeFile,Path.ToClient+'Barter.db');
Else;
End;

I:=IOResult;
Reset (MakeFile);
I:=IOResult;
If i=0 Then
Begin
While Not(Eof(MakeFile)) Do
 Begin
     ReadMake(MakeFile,MakeElement^.Dat);

  If MakeElement^.Dat.Employ Then
   Begin
    Format (MakeElement^.Dat.Name,CClient);
    Client^.List^.Insert(NewStr(MakeElement^.Dat.Name+'│'+MakeElement^.Dat.Kod));
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

End;





procedure TPZPrihodWindow.ImportNakl;
Var P :PImportSuperMarketType;
    i,C,j : Word;
    SKol,SPrim : Allstr;
    ws,s,s1,s2 : String;
    BazElement : SkladType;
    Skl : PSkladType;
    Sk : PSkidkaType;
Begin
New(P,Init);

 If SelectImportDocument(P) Then
  Begin
   For c:=1 To P^.Dat.Amount Do
    Begin
     If Not(GetIdEmploy(P^.Dat.Element[c].BazKod)) Then
      Begin


   BazElement.BazKod:=P^.Dat.Element[c].BazKod;
   new(skl,init);
   Skl^.Dat.BazKod:=P^.Dat.Element[c].BazKod;

   GetSkladRecord(Skl);

   BazElement:=Skl^.Dat;
   Dispose(Skl,Done);

   BazElement.Input.Caption:=CurrentPassword;
   BazElement.Input.Post[0] :=#0;
   BazElement.Input.NSertif[0]:=#0;
   BazElement.Input.DSertif[0]:=#0;
   BazElement.Input.KSertif[0]:=#0;
   BazElement.Input.Akzis1[0] :=#0;
   BazElement.Input.Kol     :='0';
   For j:=1 To CDivision Do
   BazElement.Input.DivisionS[j]:='0';
   BazElement.Input.Zakupka :='0.00';
   BazElement.Input.R_Zena  :='0.00';
   BazElement.Input.O_Zena  :='0.00';

   BazElement.DAte:=FDAte;
   BazELement.Employ:=True;
   BazElement.Locked:=False;
   BazElement.Time:=Times;

  {если не удалось записать информацию}
   WriteLockName(P^.Dat.Element[c].Baz,BazElement);
   Repeat
   Until (SetNAmeUnLock(P^.Dat.Element[c].BazKod));

      End;{emloy}
    End;{for}

   NewTovar^.NewList(nil);
   NewTovar^.NewList(New(PTextCollection, Init(1,1)));

   SkidkaList^.NewList(nil);
   SkidkaList^.NewList(New(PTextCollection, Init(1,1)));


  For c:=1 To P^.Dat.Amount Do
   Begin
    S:=GetIdField(FName,P^.Dat.Element[c].BazKod);
    Format(S,CName);
    s:=s+'│'+P^.Dat.Element[c].BazKod;
    ws:=GetIdField(FLitr,P^.Dat.Element[c].BazKod);
    Format(WS,CLitr);
    s:=s+'│'+ws;
    ws:=GetIdField(FInPack,P^.Dat.Element[c].BazKod);
    Format(ws,CInPack);
    s:=s+'│'+ws;
    Format(P^.Dat.Element[c].Input.Kol,CKol);
    Format(P^.Dat.Element[c].Input.R_Zena,CZena);
    Format(P^.Dat.Element[c].Input.Zakupka,CZena);
    Format(P^.Dat.Element[c].Input.O_Zena,CZena);
    Format(P^.Dat.Element[c].Input.NSertif,CNSertif);
    Format(P^.Dat.Element[c].Input.DSertif,CDSertif);
    Format(P^.Dat.Element[c].Input.KSertif,CKSertif);
    Format(P^.Dat.Element[c].Input.Zakupka,CZena);
    Format(P^.Dat.Element[c].Input.Post,CPost);
    Format(P^.Dat.MakeKod,CMakeKod);

    SPrim:=BakGetField(FAkzis,P^.Dat.Element[c].BazKod,0);
    Format(SPrim,CAkzis1);
    s:=s+'│'+P^.Dat.Element[c].Input.Kol+'│'+P^.Dat.Element[c].Input.Zakupka{R_Zena}
     +'│'+P^.Dat.Element[c].Input.Zakupka{O_Zena}+'│'+P^.Dat.Element[c].Input.NSertif+
     P^.Dat.Element[c].Input.DSertif+P^.Dat.Element[c].Input.KSertif+
     +SPrim+P^.Dat.Element[c].Input.Zakupka;

    For i:=1 To CDiviSion Do
    Begin
     SKOl[0]:=#0;
     If I=1 Then SKol:=P^.Dat.Element[c].Input.Kol;
     Format(SKol,CKol);
     s:=s+SKol{+'│'};
    End;
    s:=s+P^.Dat.Element[c].Input.Post;


    s2:=P^.Dat.Element[c].BazKod+'│'+'        '+'│';




    New(Sk,Init);
    GetSkidka(P^.Dat.Element[c].BazKod,Sk^.DAt);
    For i:=1 To CShkala Do
    Begin
     Format(Sk^.Dat.Skidka[i].ProZ,CLitr+1);
     s2:=s2+Sk^.Dat.Skidka[i].ProZ;
    End;
    Dispose(Sk,Done);

    NewTovar^.List^.Insert(NewStr(s));
    NewTovar^.SetRange(NewTovar^.List^.Count);

    SkidkaList^.List^.Insert(NewStr(s2));
    SkidkaList^.SetRange(SkidkaList^.List^.Count);
   End;
  End;{SelectImportDocument(P)}

   OperatorSelector:=2{1};
   ControlOperatorSelect^.SetData(OperatorSelector);
   PCluster(ControlOperatorSelect)^.SetButtonState($00000003{5}, False);
   s:=GetMakeField(FMake,P^.Dat.SkladKod,OperatorSelector);
   Format(s,CClient);
   PStaticText(ControlClient)^.Text^:=#3+S+'│'+P^.Dat.SkladKod;
   {ControlClient^.Options := ControlClient^.Options And Not ofSelectable;}
   Redraw;


Dispose(p,Done);
End;










procedure TPZPrihodWindow.HandleEvent(var Event: TEvent);
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
    DInfoMsg('Позиция ['+s+'] отмечена как удаленная. Нельзя использовать эту позицию!');
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
    DInfoMsg('Позиция ['+s+'] используется'+Msg+'. Не могу заблокировать позицию!');
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
    DInfoMsg('Позиция ['+s+'] отмечена как удаленная. Нельзя использовать эту позицию!');
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
Assign(f,Path.ToName+s+'.id');
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
End;


Procedure RefreshTovarList(Var s,PrevS:String);
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
                  Assign (BazFile,Path.ToSklad+s+'.db');
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
     ReadSklad(BazFile,BazElement^.Dat);
     {
     Repeat
      NetCall.UnLock(BazFile,(FilePos(BazFile)-1)*SizeOf(SkladType),SizeOf(SkladType));
     Until (DosError=0);
     }
                    If BazElement^.Dat.Employ Then
{                   If GetIdEmploy(BazElement.BazKod) Then}

                     Begin
               SName:=GetIdField(FName,BazElement^.Dat.BazKod);
               Format(SName,CName);
               SLitr:=GetIdField(FLitr,BazElement^.Dat.BazKod);
               Format(SLitr,CLitr);
               Format(BazElement^.Dat.Input.Kol,CLitr);
               SPack:=GetIdField(FInPack,BazElement^.Dat.BazKod);
               Format(SPack,CInPack);
               DelSpace(BazElement^.Dat.Input.Kol);
    RFormat (BazElement^.Dat.Input.Kol,CLitr);
    MyStr(StrToReal(BazElement^.Dat.Input.R_Zena),CZena,CMantissa,BazElement^.Dat.Input.R_Zena);
    MyStr(StrToReal(BazElement^.Dat.Input.O_Zena),CZena,CMantissa,BazElement^.Dat.Input.O_Zena);

    Format (BazElement^.Dat.Input.R_Zena,CZena);
    Format (BazElement^.Dat.Input.O_Zena,CZena);
    Format (BazElement^.Dat.Input.NSertif,CNSertif);
    Format (BazElement^.Dat.Input.DSertif,CDSertif);
    Format (BazElement^.Dat.Input.KSertif,CKSertif);
    Baz^.List^.Insert(NewStr(SName+'│'+BazElement^.Dat.BazKod+'│'+SLitr+
    '│'+SPack+'│'+BazElement^.Dat.Input.Kol+'│'+
    +BazElement^.Dat.Input.R_Zena+'│'+BazElement^.Dat.Input.O_Zena+'│'+BazElement^.Dat.Input.NSertif+
    +BazElement^.Dat.Input.DSertif+BazElement^.Dat.Input.KSertif));
    Baz^.SetRange(Baz^.List^.Count);
                     End;
                   End;
                  System.Close(BazFile);
                  End;
                  End
                  Else
                  Begin
                   MessageBox(^M+#3+'Отказано в доступе к '+Path.ToSklad+s+'.db',Nil,mfError+mfCancelButton);
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

                If Not (NewTovar^.List^.Count>=1) Then
                TestStatusPrihod;


               End;
              ClearEvent(Event);
            End;

            PZPrihodWindow^.Redraw;
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
              PZPrihodWindow^.Redraw;
              TestStatusPrihod;
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
            End
            End;

kbAlt1 : if Password(4) Then UnlockAll;

kbGrayPlus,kbF4: if (User[64] or (CurrentPassword='00')) then
Begin
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
             Nam^.AddBazINI(Event.KeyCode,S,l);
             If L Then
              Begin
               If (Event.KeyCode=kbF4)And(Baz^.List<>Nil)And(Baz^.List^.Count>=1) Then
               Baz^.List^.AtFree(Baz^.Focused);
               SName := GetIdField(FName,BazElement^.Dat.BazKod);
               Format(SName,CName);
               SLitr := GetIdField(FLitr,BazElement^.Dat.BazKod);
               Format(SLitr,CLitr);
               Format (BazElement^.Dat.Input.Kol,CLitr);
               SPack := GetIdField(FInPack,BazElement^.Dat.BazKod);
               Format(SPack,CInPack);

               DelSpace(BazElement^.Dat.Input.Kol);
               RFormat (BazElement^.Dat.Input.Kol,CLitr);
               MyStr(StrToReal(BazElement^.Dat.Input.R_Zena),CZena,CMantissa,BazElement^.Dat.Input.R_Zena);
               MyStr(StrToReal(BazElement^.Dat.Input.O_Zena),CZena,CMantissa,BazElement^.Dat.Input.O_Zena);

               Format (BazElement^.Dat.Input.R_Zena,CZena);
               Format (BazElement^.Dat.Input.O_Zena,CZena);

               Format (BazElement^.Dat.Input.NSertif,CNSertif);
               Format (BazElement^.Dat.Input.DSertif,CDSertif);
               Format (BazElement^.Dat.Input.KSertif,CKSertif);
               Baz^.List^.Insert(NewStr(SName+'│'+BazElement^.Dat.BazKod+'│'+SLitr+
               '│'+SPack+'│'+BazElement^.Dat.Input.Kol+'│'+
               +BazElement^.Dat.Input.R_Zena+'│'+BazElement^.Dat.Input.O_Zena+'│'+BazElement^.Dat.Input.NSertif+
                        +BazElement^.Dat.Input.DSertif+BazElement^.Dat.Input.KSertif));

               Baz^.SetRange(Baz^.List^.Count);
               Baz^.FocusItem(LoCation(Baz,BazElement^.Dat.BazKod,ProdagaWindow));
               If Event.KeyCode=kbF4 Then
               RenameList(Element^.Dat,NewToVar);
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
       kbF8 : Begin
                     Event.What:=evCommand;
                     Event.Command:=cmExportImport;
                     PutEvent(Event);
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
     cmAbout: Begin
     ClearEvent(Event);
	AboutCHM('4');
              End;
     cmPrihod: Begin
                  ClearEvent(Event);
                 End;
     cmPostZak: Begin
                  ClearEvent(Event);
                 End;
     cmVozwrat: Begin
                  ClearEvent(Event);
                 End;
 cmExportImport : Begin
                  L:=True;
          If (NewTovar^.List<>Nil)And(NewTovar^.List^.Count>=1) Then
                                Begin
                                  If MessageBox(#3^M+#3'Эта операция может привести к очистке уже сформированной накладной?',
						    nil,
                                  mfConfirmation+mfOkCancel)=cmOk Then
                          L:=True
                      Else
                          L:=False;
                                End;
                   If L Then
                             Begin
                                 ImportNakl;
                                 CalcItogo;
                                 AddName;
                    ControlClient^.Select;
                    End;
                                ClearEvent(Event);
                  End;
     cmOk : Begin
               PStaticText(ControlClient)^.GetText(S);
               System.Delete(S,1,1);
               SClientKod:=Copy(s,1+CClient+1,CClientKod);
               DelSpace(s);
               If ((STRToInt(SClientKod)=StrToInt(ClientRP)) And (OperatorSelector=1)) Or
                  ((STRToInt(SClientKod)=StrToInt(Rek.Kod)) And (OperatorSelector=1)) Then
                Begin
{$IfDEF Sound}
                 Sound(100);
{$EndIf}
                 DinfoMsg('Ошибка! Нельзя делать приход от внутреннего поставщика с кодом '+SClientKod+'!');
{$IfDEF Sound}
                 Delay(300);
                 NoSound;
{$EndIf}
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

            If FullScreen(NewTovar,'Заказываемые  товары          Код  Литр. Фас Колич   Цена   Р/Цена   Сертификат',S,
            SDoc,SDate,1)
                Then
                 Begin
                   L:=False;
                   {!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!}
                   PrintToFilePr(L);
                   If L Then
                     Begin
                       Event.What:=evCommand;
                       Event.Command:=cmClose;
                       PutEvent(Event);
                       ClearEvent(Event);
                       If Status = DocEdit Then
                                   Begin
                                    Dispose(PrevPrihod,Done);
                       End;
                       Dispose(SkidkaList,Done);
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
               s:=#3^M+#3'Желаете отказаться от формирования заказа?';
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
                 Dispose(SkidkaList,Done);
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
     Cl^.ShowClientList(s,OperatorSelector,1,False,False,False,-1,-1,-1,-1,Test);
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
    (Event.Command = cmVozwrat) then ClearEvent(Event);

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

  If (Desktop^.Current=PView(PZPrihodWindow)) And (Event.What <> EvKeyDown) Then
   Begin
          if (ControlOperatorSelect^.State and sfFocused <> 0)Then
              Begin
               ControlOperatorSelect^.GetData(Test);
               If Test <> OperatorSelector Then
               Begin
                OperatorSelector:=Test;
                Refresh;
                PZPrihodWindow^.Redraw;
               End;
              End;
                         DrawFullName;

    End;
end;


Begin
GlobalStatus:=0;

End.


