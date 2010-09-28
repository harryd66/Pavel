{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}


{$I Compile.INC}

Unit Trans;

Interface


Uses Dialogs,Drivers,MyCalc,Glob,ServStr,Access2,Access;


Type
  PTransNameWindow = ^TTransNameWindow;
  TTransNameWindow = object(TDialog)
   Calc        : PMyCalculator;
    Procedure Ini(s:TMyString;Regim:Word);
    procedure HandleEvent(var Event: TEvent); virtual;
    Destructor Done;Virtual;
  end;


Type
  PTransportWindow = ^TTransportWindow;
  TTransportWindow = object(TDialog)
    Otd :   PSelectOtdelWindow;
    Trans : PTransNameWindow;
    constructor Init(Var l: Boolean);
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure AddName;
    procedure OpenTransportWindow;
    procedure CalcItogo;
    Procedure SaveToFile(Var Save : Boolean);
    Procedure Refresh;
    Procedure FreshMarketHint;
    Procedure FreshSkladHint;
    Procedure RedrawHeader(Reg:Boolean);
    procedure UnlockAllName;
    Procedure DrawFullName;
    end;


 Implementation

uses App,DBEngine,Objects,ComboBox,TrNakl,UtilsP,
     Views, MsgBox,Vision4,Nastr,Protect,NetCall,

     Windos,ColorTxt,Serv,InpLong,Validate,Access3,
        CPrihod,TpDate,Net,NetDbEng,Utils,MrkTool;

Const Est='ДА';
      Netu='НЕТ';

var



 TransportWindow : PTransportWindow;
 TransportList : PBox;
 CurrentMakeOtdelenie,CurrentClientOtdelenie : Word;
 ControlFullName,ControlMakeOtdelenie,
 ControlClientOtdelenie,ControlMakeKol,ControlMAkeZena,
 ControlPack, ControlKol,ControlDoc,
 ControlRZena,ControlZZena,ControlPackMsg,ControlAmount,ControlItogoZ,ControlItogoR,
 ControlClientKol,ControlClientZena : PView;
 PrevNAme, PrevSMarket, PrevS : String;
 SArtikul : AllStr;
 TrWin : PTransNameWindow;
 AllZakupka : AllStr;
 OldFileMode : Word;
 PrevKolPack : Byte;
 PrevKol : String[CKol];
 ViewZakupka:Boolean;


Procedure TTransportWindow.RedrawHeader(Reg:Boolean);
Var s : String;
    R : TRect;
Begin
PStaticText(ControlMakeOtdelenie)^.GetText(S);
Dispose(ControlMAkeOtdelenie,Done);
R.Assign(1, 2, 36, 3);
If Reg Then
Begin
ControlMakeOtdelenie := New(PColoredText, Init(R, s, $1F));
ControlMakeOtdelenie^.Options := ControlMakeOtdelenie^.Options or ofSelectable;
End
Else
 Begin
  ControlMakeOtdelenie := New(PColoredText, Init(R, s, $13));
  ControlMakeOtdelenie^.Options := ControlMakeOtdelenie^.Options And Not ofSelectable;
 End;
Insert(ControlMakeOtdelenie);
{
  R.Assign(1, 1, 12, 2);
  Insert(New(PLabel, Init(R, '~П~оставщик:', ControlMakeOtdelenie)));
}
PStaticText(ControlClientOtdelenie)^.GetText(S);
Dispose(ControlClientOtdelenie,Done);
R.Assign(41, 2, 76, 3);
If Reg Then
Begin
ControlClientOtdelenie := New(PColoredText, Init(R, s, $1F));
ControlClientOtdelenie^.Options := ControlClientOtdelenie^.Options or ofSelectable;
End
Else
 Begin
  ControlClientOtdelenie := New(PColoredText, Init(R, s, $13));
  ControlClientOtdelenie^.Options := ControlClientOtdelenie^.Options And Not ofSelectable;
 End;
{
  R.Assign(40, 1, 52, 2);
  Insert(New(PLabel, Init(R, 'По~л~учатель:', ControlClientOtdelenie)));
}
Insert(ControlClientOtdelenie);
Redraw;


End;


Procedure DrawPack;
Var s: String[CPack];
    R : TRect;
    SKol : ArtikulStr;
Begin
    ControlKol^.GetData(SKol);
    If SKol<>PrevKol Then
    Begin
    PrevKol:=SKol;
    s:=CalcPack(sArtikul,SKol);
    DelSpace(s);
    Dispose(ControlPackMsg,Done);
    R.Assign(58, 4, 67, 5);
    ControlPackMsg:=New(PStaticText, Init(R, #3+s));
    TrWin^.Insert(ControlPackMsg);
    End;
End;



Procedure DrawKol(VAr Show:Boolean;Var Kol:ArtikulStr);
Var s: String[CKol];
    R : TRect;
    l : LongInt;
    sKol1 :Word;
    TestKol :String[CKol];
Begin
 Show:=FAlse;
 ControlPack^.GetData(SKol1);
 If SKol1<>10 Then
Begin
If SKol1<>PrevKolPack Then
 Begin
  s:=GetIdField(FINPack,SArtikul);
  Str(StrToInt(s)*(SKol1+1):CKol,s);
  DelSpace(s);
  Kol :=S;

  TestKol:=BakGetField(FDiv,SArtikul,CurrentMakeOtdelenie);

  If StrToInt(s)>StrToInt(TestKol) Then
  Begin
   Show:=True;
   DelSpace(TestKol);
   s:=TestKol;
   DelSpace(s);
  End;

  ControlKol^.SetData(s);
  PrevKolPack:=SKol1;
 End;
End{если не нажата буква ~А~}
 Else
  Begin
   TestKol:=BakGetField(FDiv,SArtikul,CurrentMakeOtdelenie);
   DelSpace(TestKol);
   ControlKol^.SetData(TestKol);
   PrevKolPack:=10{TestKol};
  End;
End;

Function WriteTransportToSkladFile(L:PTransportType) : Boolean;
Var SkladFile : File Of SkladType;
    Skl : PSkladType;
    i,p,j : Byte;
    Ls:LongInt;
    s1,s2 : TEnjoyStr;
Begin
WriteTransportToSkladFile:=False;
New(Skl,Init);
DInfoMsg('Провожу перемещение на складе...');
 For i:=1 To L^.DAt.Amount{J} Do
  Begin
   S1:=Copy(L^.Dat.TransportElement[i].BazKod,1,CRazdelKod);
   Assign(SkladFile,Path.ToSklad+s1+'.db');
   p:=IOResult;
   Reset(SkladFile);
   p:=IOResult;
   If p <> 0 Then
    Begin
     NoInfoMsg;
     MessageBox(#3^M+#3'Ошибка доступа к файлу '+S1+'.db!',Nil,mfError+mfCancelButton);
     Dispose(Skl,Done);
     Exit;
    End;


   Seek(SkladFile,GetFileLocation3(Copy(L^.Dat.TransportElement[i].BazKod,CRazdelKod+1,CKod)));

   {блокируем позицию предварительной блокировкой}

   Repeat
    Pause(1);
   Until Lock(SkladFile,FilePos(SkladFile)*SizeOf(SkladType),SizeOf(SkladType));

   Read(SkladFile,Skl^.DAt);
    {модифицируем поля связанные с ценной}
    With Skl^.Dat.Input Do
    Begin
      Caption:=L^.Dat.Caption;
      Skl^.Dat.Date := TekDate;
      Skl^.Dat.Time := TimeToTimeString('hh:mm:ss',CurrentTime);
      {внутренее перемещение}
      Str((StrToInt(DivisionS[CurrentClientOtdelenie])+StrToInt(L^.Dat.TransportElement[i].Input.Kol)):CKol,
         DivisionS[CurrentClientOtdelenie]);
      Str((StrToInt(DivisionS[CurrentMakeOtdelenie])-StrToInt(L^.Dat.TransportElement[i].Input.Kol)):CKol,
         DivisionS[CurrentMakeOtdelenie]);
      {завершение перемещения}
    End;






    {сохраняем изменения}
    Seek(SkladFile,FilePos(SkladFile)-1);
    Write(SkladFile,Skl^.Dat);

    {деблокируем позицию}

    Seek(SkladFile,FilePos(SkladFile)-1);
    Repeat
     UnLock(SkladFile,FilePos(SkladFile)*SizeOf(SkladType),SizeOf(SkladType));
    Until (DosError=0);

    Close(SkladFile);{закрытие файла}
  End;

Dispose(Skl,Done);

WriteTransportToSkladFile:=True;
NoInfoMsg;
End;




Procedure TTransNameWindow.Ini(s:TMyString;Regim:Word);
Label 1;
var
  R : TRect;
  Control : PView;
  SInPAck,SLitr,SName,SName2,SOtd,ActiveOtdel: String[CAll];
  SKol,SRZena,SZZena : TDateString;
  sr,s2,ws3,s1,ws2,ws1,SAkzis,SVirabotano,SGodnost : AllStr;
  Pack,c : Word;

Begin
ClearFind;
SArtikul:=Copy(s,1+CNAme+1,CArtikul);
SLitr:=GetIdField(FLitr,SArtikul);
SInPAck:=GetIdField(FInPack,SArtikul);

SName:=GetIdField(FName,SArtikul);
SName2:=GetIdField(FName2,SArtikul);
Format(SName,CName);
Format(SName2,CName);

SRZena:=BakGetField(FRZena,SArtikul,0);
MyStr(StrToReal(SRZena),CZena,CMantissa,SRZena);
DelSpace(SRZena);

SZZena:=BakGetField(FZakupka,SArtikul,0);
MyStr(StrToReal(SZZena),CZena,CMantissa,SZZena);
DelSpace(SZZena);


DelSpace(SLitr);
DelSpace(SInPack);
DelSpaceRight(SAkzis);
DelSpaceRight(SVirabotano);
DelSpaceRight(SGodnost);
PrevKol[0]:=#0;
PrevKolPack:=0;

Case Regim Of
0:
  Begin
   SKol:=BakGetField(FDiv,SArtikul,CurrentMakeOtdelenie);
   DelSpace(SKol);
  End;{добавление новой}
1:
  Begin
   SKol:=Copy(s,1+CNAme+1+CArtikul+1,CKol);
   DelSpace(SKol);
  End;{редактирование}
Else;
End;{CAse}
DelSpace(SKol);

1:
AInfo('Читаю информацию о товаре...');
R.Assign(0, 14, 80, 22);
New(TrWin, Init(R, 'Перемещение наименования товара [ '+IntToStr(CurrentMakeOtdelenie,COne)+' -> '+
IntToStr(CurrentClientOtdelenie,COne)+' ]'));

TrWin^.Options := TrWin^.Options or ofCenterX;
TrWin^.Palette := dpCyanDialog;
TrWin^.HelpCtx := $E199;

If Regim=0 Then
 Begin
  SKol:=GetIdField(FInPack,SArtikul);
  If StrToInt(SKol)>StrToInt(BakGetField(FDiv,SArtikul,CurrentMAkeOtdelenie)) Then
  SKol:=BakGetField(FDiv,SArtikul,CurrentMAkeOtdelenie)
 End;
  DelSpace(SKol);


ws1:=CalcPack(SArtikul,SKol);
System.Delete(ws1,Pos('+',ws1),Ord(wS1[0]));


    If (StrToInt(ws1)-1) >= 0 Then
    Pack:=StrToInt(ws1)-1
    Else Pack:=StrToInt(ws1);
    If PAck>9 Then Pack:=9;

R.Assign(1, 4, 44, 6);
ControlPack := New(PRadioButtons, Init(R,
  NewSItem('~1~',
  NewSItem('~2~',
  NewSItem('~3~',
  NewSItem('~4~',
  NewSItem('~5~',
  NewSItem('~6~',
  NewSItem('~7~',
  NewSItem('~8~',
  NewSItem('~9~',
  NewSItem('1~0~',
  NewSItem('~А~', Nil)))))))))))));
ControlPack^.SetData(Pack);
TrWin^.Insert(ControlPack);


  R.Assign(1, 3, 22, 4);
  TrWin^.Insert(New(PLabel, Init(R, 'Количество ~у~паковок:', ControlPack)));


R.Assign(59, 5, 66, 6);
ControlKol := New(PInputLine, Init(R, CKol));
 PInputLine(ControlKol)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0']));
ControlKol^.SetData(SKol);
TrWin^.Insert(ControlKol);

  R.Assign(44, 5, 59, 6);
  TrWin^.Insert(New(PLabel, Init(R, 'Ко~л~ичество,шт:', ControlKol)));

R.Assign(49, 4, 58, 5);
Control := New(PColoredText, Init(R, 'Упаковок:', $31));
TrWin^.Insert(Control);

R.Assign(71, 3, 79, 4);
ControlRZena := New(PColoredText, Init(R, SRZena, $31));
TrWin^.Insert(ControlRZena);

R.Assign(67, 3, 71, 4);
Control := New(PColoredText, Init(R, 'Р/Ц:', $31));
TrWin^.Insert(Control);

ViewZakupka:=False;
R.Assign(71, 4, 79, 5);
ControlZZena := New(PColoredText, Init(R, SZZEna, $33));
TrWin^.Insert(ControlZZena);

{
R.Assign(67, 4, 71, 5);
Control := New(PColoredText, Init(R, 'З/Ц:', $31));
TrWin^.Insert(Control);
}

s:=CalcPack(sArtikul,SKol);
DelSpace(s);
R.Assign(58, 4, 67, 5);
ControlPackMsg:=New(PStaticText, Init(R, #3+s));
TrWin^.Insert(ControlPackMsg);




s:=BakGetField(FDiv,SArtikul,CurrentMakeOtdelenie);
DelSpace(s);

ws1:=CalcPack(SArtikul,s);
DelSpace(Ws1);

sr:='0';
DelSpace(sr);


s2:=BakGetField(FDiv,SArtikul,CurrentClientOtdelenie);
DelSpace(s2);
ws3:=CalcPack(SArtikul,s2);
DelSpace(Ws3);

s1:=BakGetField(FKol,SArtikul,CurrentMakeOtdelenie);
DelSpace(s1);
ws2:=CalcPack(SArtikul,s1);
DelSpace(Ws2);

R.Assign(4, 7, Length(' В отделении '+IntToStr(CurrentMAkeOtdelenie,COne)+': '+s+' шт. '+ws1+' упак.'+
' В отделении '+IntToStr(CurrentClientOtdelenie,COne)+': '+s2+'('+sr+')'+' шт. '+ws3+' упак.'{ На складе'+
     ': '+s1+' шт. '+ws2+' упак.'})+1, 8);
Control := New(PColoredText, Init(R, ' В отделении '+IntToStr(CurrentMAkeOtdelenie,COne)+': '+s+' шт. '+ws1+' упак.'+
' В отделении '+IntToStr(CurrentClientOtdelenie,COne)+': '+s2+'('+sr+')'+' шт. '+ws3+' упак.'{ На складе'+
     ': '+s1+' шт. '+ws2+' упак.'}, $31));
Control^.Options := Control^.Options or ofCenterX;
TrWin^.Insert(Control);

R.Assign(3, 1, 76, 2);
Control := New(PColoredText, Init(R, ' Наименование:'+SName+' Код:'+SArtikul+' Литраж:'+SLitr+' Фас:'+SInPack, $3E));
TrWin^.Insert(Control);

R.Assign(17, 2, 43, 3);
Control := New(PStaticText, Init(R, SNAme2));
TrWin^.Insert(Control);

TrWin^.SelectNext(False);

DrawPack;

NoInfo;
c:=DeskTop^.ExecView(TrWin);
If c<>cmCAncel Then
 Begin
   ControlKol^.GetData(SKol);
   DelSpace(SKol);
   Dispose(Control,Done);
   Dispose(TrWin,Done);
   If (StrToInt(SKol)=0)Then
    Begin
     MessageBox(#3+NullKol,nil, mfError + mfCancelButton);
     GoTo 1;
    End;

   If (StrToInt(BakGetField(FDiv,SArtikul,CurrentMakeOtdelenie))<(StrTOInt(SKol))) Then
    Begin
     MessageBox(^M+'На складе (отделение ['+IntToStr(CurrentMAkeOtdelenie,COne)+']) отсутствует такое количество товара ! ',
        nil, mfError + mfCancelButton);
     GoTo 1;
    End;


   If (StrToInt(BakGetField(FKol,SArtikul,CurrentClientOtdelenie))+(StrTOInt(SKol)))>CMAxKol Then
    Begin
      MessageBox('Слишком большое количество товара'^M+
                'Попробуйте оприходывать его в разные позиции! ',nil, mfError + mfCancelButton);
      GoTo 1;
    End;
    DelSpace(SKol);
    RFormat(SKol,CKol);
    RFormat(SRZena,CZena);
    RFormat(SZZena,CZena);
    Format(SNAme,CNAme);
    s:=SName+'│'+SArtikul+'│'+SKol+'│'+SRZena+'│'+SZZena;

  If Regim=1 Then
    Begin
     TransportList^.List^.AtFree(TransportList^.Focused);
     TransportList^.SetRange(TransportList^.List^.Count);
    End;

   TransportList^.List^.Insert(NewStr(S));
   TransportList^.SetRange(TransportList^.List^.Count);
   TransportList^.FocusItem(Location(TransportList,SArtikul,False));
   PrevSMarket[0]:=#0;

 End
Else
 BEgin
  SetNameUnLock(SArtikul);
  Dispose(Control,Done);
  Dispose(TrWin,Done);
 End;
End;


procedure TTransNameWindow.HandleEvent(var Event: TEvent);

procedure Calculator;
begin
  Calc^.Start;
end;

VAr DZ,DS,ShowWarning : Boolean;
    InputPack   : ArtikulStr;
    St : TDateString;
    s : AllStr;
    R : TRect;
    Z : Word;

Begin
Case Event.What Of
 evCommand :
   Case Event.Command Of
        cmLocalCalc: Calculator;


  Else;
   End;

 evKeyDown:
  Case Event.KeyCode Of
        kbF6   :
                begin
  if(ControlPack^.State and sfFocused <> 0) Or
    (ControlKol^.State and sfFocused <> 0) Then
                Begin
                 s:=PStaticText(ControlZZena)^.Text^;
                 Dispose(ControlZZena,Done);
                 R.Assign(71, 4, 79, 5);
                 If Not(ViewZakupka) Then
                 ControlZZena := New(PColoredText, Init(R,s, $31))
                 Else
                 ControlZZena:=New(PColoredText, Init(R, s, $33));
                 TrWin^.Insert(ControlZZena);
                 ViewZakupka:=Not ViewZakupka;
                 Redraw;
                End;
                 ClearEvent(Event);
                end;

       Else;
       End;
   Else;
   End;

  inherited HandleEvent(Event);


  If (ControlPack^.State and sfFocused <> 0) Then
   Begin
    ShowWarning:=FAlse;
    InputPAck[0]:=#0;
    DrawKol(ShowWarning,InputPack);
    If ShowWarning Then
    Begin
     Sound(100);
     DinfoMsg('Внимание! В отделении ['+
	IntToStr(CurrentMakeOtdelenie,COne)+'] нет такого количества '+InputPack+' шт.');
     Delay(1000);
     NoSound;
     Delay(700);
     NoInfoMsg;
     ClearEvent(Event);
    End;
   End;
 DrawPack;

End;

Destructor TTransNameWindow.Done;
Begin
Dispose(ControlPack,Done);
Dispose(ControlKol,Done);
Dispose(ControlRZena,Done);
Dispose(ControlZZena,Done);
TDialog.Done;
End;



Procedure TTransportWindow.FreshMarketHint;
Var R : TRect;
    SArt:ArtikulStr;
    S : String;
Begin
If TransportList^.List^.Count>0 Then
Begin
Dispose(ControlClientZena,Done);
R.Assign(59, 21, 67, 22);
PrevSMarket:=Copy(TransportList^.GetText(TransportList^.Focused,TransportList^.List^.Count),
1+CName+1+CArtikul+1+CKol+1,CZena);
ControlClientZena:= New(PColoredText, Init(R, #3+PrevSMarket, $7E));
Insert(ControlClientZena);


PrevSMarket:=TransportList^.GetText(TransportList^.Focused,TransportList^.List^.Count);
End
Else
 Begin
Dispose(ControlClientZena,Done);
R.Assign(59, 21, 67, 22);
ControlClientZena := New(PColoredText, Init(R, #3+'', $7E));
Insert(ControlClientZena);
PrevSMarket[0]:=#0;

 End;
End;



Procedure TTransportWindow.FreshSkladHint;
Var R : TRect;
    Sart : ArtikulStr;
    l : LongInt;
    PrevS1,s : String;
Begin
If Baz^.List^.Count>0 Then
Begin
Dispose(ControlMakeKol,Done);
PrevS:=Copy(Baz^.GetText(Baz^.Focused,Baz^.List^.Count),1+CName+1,CArtikul);
Sart:=PrevS;
PrevS:=BakGetField(FDiv,PrevS,CurrentMakeOtdelenie);
{PrevS1:=BakGetField(FDivR,SArt,CurrentMakeOtdelenie);}

Str(StrToInt(PrevS)-StrToInt(PrevS1):CKol,PrevS);

DelSpace(PrevS);
Format(PrevS,CKol);

R.Assign(9, 21, 14, 22);
ControlMakeKol := New(PColoredText, Init(R, #3+PrevS, $7E));
Insert(ControlMakeKol);

Dispose(ControlMAkeZena,Done);
R.Assign(23, 21, 31, 22);
PrevS:=Copy(Baz^.GetText(Baz^.Focused,Baz^.List^.Count),1+CName+1,CArtikul);
PrevS:=BakGetField(FRZena,PrevS,CurrentMakeOtdelenie);
DelSpace(PrevS);
Format(PrevS,CZena);
ControlMAkeZena := New(PColoredText, Init(R, #3+PrevS, $7E));
Insert(ControlMAkeZena);

End
 Else
  Begin
Dispose(ControlMAkeKol,Done);
R.Assign(9, 21, 14, 22);
ControlMakeKol := New(PColoredText, Init(R, #3+'???', $7E));
Insert(ControlMAkeKol);

Dispose(ControlMAkeZena,Done);
R.Assign(23, 21, 31, 22);
ControlMakeZena := New(PColoredText, Init(R, #3+'???', $7E));
Insert(ControlMAkeZena);

  End;

End;

Procedure TTransportWindow.DrawFullName;
Var S: String;
    R : TRect;
    SArt : ArtikulStr;
Begin

if (TransportList^.State and sfFocused <> 0)  Then
Begin
If (TransportList^.List<>Nil)And(TransportList^.List^.Count>=1) Then
Begin
s:=TransportList^.GetText(TransportList^.Focused,TransportList^.List^.Count);
If s<>PrevName Then
Begin
 PrevName:=s;
 Sart:=Copy(s,1+CNAme+1,CArtikul);
 Dispose(ControlFullName,Done);

 R.Assign(21, 20, 76, 21);

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
 R.Assign(21, 20, 76, 21);
 s:=' ';
 ControlFullName := New(PColoredText, Init(R, s, $7e));
 Insert(ControlFullName);
  End;
End;

if (Baz^.State and sfFocused <> 0)  Then
Begin
If (BAz^.List<>Nil)And(Baz^.List^.Count>=1) Then
Begin
s:=Baz^.GetText(Baz^.Focused,Baz^.List^.Count);
If s<>PrevName Then
Begin
 PrevName:=s;
 Sart:=Copy(s,1+CName+1,CArtikul);
 Dispose(ControlFullName,Done);
 R.Assign(21, 20, 76, 21);
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
 R.Assign(21, 20, 76, 21);
 s:=' ';
 ControlFullName := New(PColoredText, Init(R, s, $7e));
 Insert(ControlFullName);
  End;
End;

if (Baz^.State and sfFocused = 0) And (TransportList^.State and sfFocused = 0)Then
 Begin
 PrevName[0]:=#0;
 Dispose(ControlFullName,Done);
 R.Assign(21, 20, 76, 21);
 s:=' ';
 ControlFullName := New(PColoredText, Init(R, s, $7e));
 Insert(ControlFullName);
 End;


End;


Procedure SortNKLTrn (Var l: PTransportType);
Var i : Word;
    R : TRect;
    E : PTransportType;
    Wk,Wn : AllStr;
    S : String;
    TempBox : PBox;
    Itogo : AllStr;
Begin
 R.Assign(0, 0, 0, 0);
 TempBox := New(PBox, Init(R, 1, Nil));
 TempBox^.NewList(New(PTextCollection, Init(0,1)));
 For i :=1 To L^.Dat.Amount Do
  Begin
   With L^.Dat.TransportElement[i].Input Do
   Begin
   Format(Kol,CKol);
   Format(Grammi,CGram);
   Format(Zena,CZena);
   Format(Zakupka,CZenaZ);
   Wk := Copy(L^.Dat.TransportElement[i].BazKod,1,CRazdelKod);
   Wn := GetIdField(FName,L^.Dat.TransportElement[i].BazKod);
   Format (wn,CName);
   s:=' '{s}+
   '│'+wk+{код раздела}
   '│'+Wn+{наименование}
   '│'+L^.Dat.TransPortElement[i].BazKod+{5знач}
   '│'+L^.Dat.TransPortElement[i].Input.Kol+{колич}
   '│'+L^.Dat.TransPortElement[i].Input.Grammi+{грамми}
   '│'+L^.Dat.TransPortElement[i].Input.Zena+{цена}
   '│'+L^.Dat.TransPortElement[i].Input.Zakupka+{закупка}
   '│'+IntToStr(L^.Dat.TransPortElement[i].Input.RegionMArka,COne);{рег.марка}
   TempBox^.List^.Insert(NewStr(s));
   TempBox^.SetRange(TempBox^.List^.Count);
   End;{With}
  End;{For}
  New(E,Init);
  E^.Dat:=L^.Dat;

If (TempBox^.List^.Count)>0 Then
For i:=0 To TempBox^.List^.Count-1 Do
 Begin
  s:=TempBox^.GetText(i,TempBox^.List^.Count);
{для новой структуры стороки}
  E^.Dat.TransportElement[i+1].BazKod:=Copy(s,1+COne+1+CRazdelKod+1+CName+1,CArtikul);

  With E^.Dat.TransportElement[i+1].Input Do
   Begin
    Kol:=Copy(s,1+COne+1+CName+1+CArtikul+1+CRazdelKod+1,CKol);
    DelSpace(Kol);
    Grammi:=Copy(s,1+COne+1+CName+1+CArtikul+1+CRazdelKod+1+CKol+1,CGram);
    DelSpace(Grammi);
    Zena:=Copy(s,1+COne+1+CName+1+CArtikul+1+CRazdelKod+1+CKol+1+CGram+1,CZena);
    DelSpace(Zena);
    Zakupka:=Copy(s,1+COne+1+CName+1+CArtikul+1+CRazdelKod+1+CKol+1+CGram+1+CZena+1,CZenaZ);
    DelSpace(Zakupka);

    RegionMarka:=StrToInt(
              Copy(s,1+COne+1+CName+1+CArtikul+1+CRazdelKod+1+CKol+1+CGram+1+CZena+1+CZenaZ+1,CONe));
   End;
 End;
 L^.Dat.TransportElement:=E^.Dat.TransportElement;
 Dispose(TempBox,Done);
 Dispose(E,Done);

End;





Procedure TTransportWindow.SaveToFile(Var Save : Boolean);
Label 1;
Var L : PTransportType;
    R:TRect;
    i : LongInt;
    pItog,itog : Real;
    s  : String;
    ws : AllStr;
    As : DocumentEdit;
    TempBox,LockBox:PBox;
    SOpl,TDoc,BakSkid,NewSkid:String[CIZena];
Begin
Save:=False;
New(l,Init);
If (TransportList^.List^.Count)>0 Then
For i:=0 To TransportList^.List^.Count-1 Do
 Begin
  s:=TransportList^.GetText(i,TransportList^.List^.Count);
{для новой структуры стороки}
  L^.Dat.TransportElement[i+1].BazKod:=Copy(s,1+CNAme+1,CArtikul);

  With L^.Dat.TransportElement[i+1].Input Do
   Begin
    Zakupka:=Copy(s,1+CName+1+CArtikul+1+CKol+1+CZena+1,CZena);
    DelSpace(Zakupka);
    Kol:=Copy(s,1+CName+1+CArtikul+1,CKol);
    DelSpace(Kol);
    Zena:=Copy(s,1+CName+1+CArtikul+1+CKol+1,CZena);
    DelSpace(Zena);
   End;
 End;


 PStaticText(ControlItogoR)^.GetText(S);
 System.Delete(S,Pos(#3,S),1);
 MyStr(StrToreal(S),CIZena,CMantissa,S);
 DelSpace(S);
 L^.Dat.SummaZ:=S;
 DelSpace(AllZakupka);
 L^.Dat.SummaZakupka:=AllZakupka;
 L^.Dat.Amount:=TransportList^.List^.Count;
 L^.Dat.ClientOtdelenie:=CurrentClientOtdelenie;
 L^.Dat.MakeOtdelenie:=CurrentMakeOtdelenie;

 PStaticText(ControlDoc)^.GetText(s);
 DelSpace(S);
 System.Delete(S,Pos(#3,S),1);
 DelSpace(s);
 L^.Dat.Document:=s;

 SortNKLTrn(l);

{прочитали с экрана перевозку}
 Save:=WriteTransportToSkladFile(L);
 If Save Then Save:=LockAndWriteTransport(L)
      Else
          Begin
           Goto 1;
       End;


 If Save Then
     Begin
      UnLockAllName;
       AddProtocol('Внутреннее перемещение товара по документу N '+L^.Dat.Document+' от '+L^.Dat.DateC,'','');
       If MessageBox(#3'Внутреннее перемещение произведено!'^M+
          #3'Печатать наладную на внутреннее перемещение товара?',Nil,mfConfirmation+mfOkCancel)=cmOk Then
         Begin
           As.D:=TekDate;
           As.EditPosition:=L^.Dat.Document;
           PrintTransport(As);
         End;
     End;
1: Dispose(l,Done);
End;




procedure TTransportWindow.OpenTransportWindow;
Var l : Boolean;
begin
  ClearFind;
  if Message(Desktop, evBroadcast, cmTransport, nil) = nil then
  begin
    DInfo('Инициализация внутренних перемещений...');
    L:=True;
    TransportWindow := New(PTransportWindow, Init(L));
    If L Then
    Begin
    Application^.InsertWindow(TransportWindow);
    NoInfo;
    End
    Else
     Begin
      TekDAte:=FDAte;
      Status:=DocNormal;
      Dispose(TransportWindow,Done);
      NoInfo;
     End;
  end
  else
    if PView(TransportWindow) <> Desktop^.TopView then TransportWindow^.Select;
end;



constructor TTransportWindow.Init(Var l : Boolean);
var
  R : TRect;
  Control : PView;
  C : Word;
  DocumentNumer : TDateString;
  TransportFile : File Of TransportType;
  s: TMyString;
  ws : TDateString;
  k,i : Byte;
  mm,mm2 : Maska9;
  Event : TEvent;
  Cod : ArtikulStr;
  Start,Stop : Word;

begin
R.Assign(0, 0, 80, 23);
inherited Init(R, 'Внутреннее перемещение товара');
TekDate:=FDate;
Options := Options or ofCenterX or ofCenterY;
HelpCtx:=$E011;
L:=False;

If Not(TestOpenDate1(TekDate)) Then
   Begin
    MessageBox(#3^M+#3'Доступ к данным за '+TekDate+' заблокирован!',Nil,mfError+mfCancelButton);
    TekDate:=FDAte;
    Exit;
   End;
ClearFind;



ClearFind;

  C:=IOResult;
  Assign(TransportFile,Path.ToRewisia+TekDate+'.trn');
  Reset(TransportFile);
  C:=IOResult;
  If C<>0 Then
   Begin
    If MessageBox(#3'Файл внутренних перемещений за '+TekDate+' не найден!'+
    'Если Вы раннее что-то перемещали немедленно позовите программиста! '+
    'Создавать файл внутренних пермещений?'+' Код:'+IntToStr(c,3),Nil, mfWarning+mfOkCancel)=cmOk Then
     Begin
      If Not(CreatToDayF(DocTransport,TekDate)) Then Exit;
      Reset(TransportFile);
      c:=IOResult;
     End
    Else Exit;
   End;

   System.Close(TransportFile);

   If Not(UseDocNumer(DocTransport,TekDate,DocumentNumer)) Then Exit;

R.Assign(1, 2, 36, 3);
c:=1;
s:=FormLineOtdel(c);
Format(s,31);
s:=s+'│'+IntToStr(c,COne);
Start:=c;
ControlMakeOtdelenie := New(PColoredText, Init(R, #3+s, $1F));
ControlMakeOtdelenie^.Options := ControlMakeOtdelenie^.Options or ofSelectable;
Insert(ControlMakeOtdelenie);


R.Assign(1, 1, 11, 2);
Control := New(PColoredText, Init(R, 'Поставщик:', $74));
Insert(Control);


{
R.Assign(1, 1, 11, 2);
Insert(New(PLabel, Init(R, 'П~о~ставщик:', ControlMakeOtdelenie)));
}

  {
  R.Assign(1, 1, 12, 2);
  Insert(New(PLabel, Init(R, '~П~оставщик:', ControlMakeOtdelenie)));
  }


R.Assign(41, 2, 76, 3);
c:=2;
Stop:=c;
s:=FormLineOtdel(c);
Format(s,31);
s:=s+'│'+IntToStr(c,COne);
ControlClientOtdelenie := New(PColoredText, Init(R, #3+s, $1F));
ControlClientOtdelenie^.Options := ControlClientOtdelenie^.Options or ofSelectable;
Insert(ControlClientOtdelenie);
{
  R.Assign(40, 1, 52, 2);
  Insert(New(PLabel, Init(R, 'По~л~учатель:', ControlClientOtdelenie)));
}


R.Assign(41, 1, 52, 2);
Control := New(PColoredText, Init(R, 'Получатель:', $74));
Insert(Control);

{
R.Assign(41, 1, 52, 2);
Insert(New(PLabel, Init(R, 'По~л~учатель:', ControlClientOtdelenie)));
}


R.Assign(34, 4, 35, 20);
Control := New(PScrollBar, Init(R));
Insert(Control);

R.Assign(1, 4, 34, 20);
Baz := New(PBox, Init(R, 1, PScrollbar(Control)));
Baz^.NewList(New(PMyCollection, Init(0,1)));
Baz^.FocusItem(0);
Baz^.HelpCtx:=$E141;
Insert(Baz);

l:=False;

  R.Assign(1, 3, 34, 4);
  Insert(New(PLabel, Init(R, 'В отделении ~и~меется          Код', Baz)));


R.Assign(79, 4, 80, 20);
Control := New(PScrollBar, Init(R));
Insert(Control);

R.Assign(40, 4, 79, 20);
TransportList := New(PBox, Init(R, 1, PScrollbar(Control)));
TransportList^.NewList(New(PTextCollection, Init(0,1)));
TransportList^.FocusItem(0);
TransportList^.HelpCtx:=$E141;
Insert(TransportList);

  R.Assign(40, 3, 53, 4);
  Insert(New(PLabel, Init(R, 'В накладной:', TransportList)));

R.Assign(21, 20, 76, 21);
ControlFullName := New(PColoredText, Init(R, #3+'???', $7E));
Insert(ControlFullName);

R.Assign(1, 20, 21, 21);
Control := New(PColoredText, Init(R, 'Полное наименование:', $71));
Insert(Control);

R.Assign(3, 21, 9, 22);
Control := New(PColoredText, Init(R, 'Колич:', $71));
Insert(Control);

R.Assign(9, 21, 14, 22);
ControlMakeKol := New(PColoredText, Init(R, #3+'', $7E));
Insert(ControlMakeKol);

R.Assign(18, 21, 23, 22);
Control := New(PColoredText, Init(R, 'Цена:', $71));
Insert(Control);

R.Assign(23, 21, 31, 22);
ControlMakeZena := New(PColoredText, Init(R, #3+'', $7E));
Insert(ControlMakeZena);

{
R.Assign(45, 21, 51, 22);
Control := New(PColoredText, Init(R, 'Колич:', $71));
Insert(Control);

R.Assign(51, 21, 56, 22);
ControlClientKol := New(PColoredText, Init(R, #3+'', $7E));
Insert(ControlClientKol);
}

R.Assign(54, 21, 59, 22);
Control := New(PColoredText, Init(R, 'Цена:', $71));
Insert(Control);

R.Assign(59, 21, 67, 22);
ControlClientZena := New(PColoredText, Init(R, #3+'', $7E));
Insert(ControlClientZena);

R.Assign(66, 22, 75, 23);
Control := New(PColoredText, Init(R, ' Позиций:', $74));
Insert(Control);

R.Assign(75, 22, 79, 23);
ControlAmount := New(PColoredText, Init(R, #3+'0', $4E));
Insert(ControlAmount);

R.Assign(1, 22, 15, 23);
Control := New(PColoredText, Init(R, ' Всего по З/Ц:', $74));
Insert(Control);

R.Assign(15, 22, 30, 23);
ControlItogoZ := New(PColoredText, Init(R, #3+'0.00', $4E));
Insert(ControlItogoZ);

R.Assign(33, 22, 47, 23);
Control := New(PColoredText, Init(R, ' Всего по Р/Ц:', $74));
Insert(Control);

R.Assign(47, 22, 62, 23);
ControlItogoR := New(PColoredText, Init(R, #3+'0.00', $4E));
Insert(ControlItogoR);


R.Assign(2, 0, 14, 1);
Control := New(PColoredText, Init(R, ' Документ N:', $74));
Insert(Control);


R.Assign(14, 0, 18, 1);
ControlDoc := New(PColoredText, Init(R, ''+DocumentNumer, $7E));
Insert(ControlDoc);

R.Assign(64, 0, 70, 1);
Control := New(PColoredText, Init(R, 'Дата:', $74));
Insert(Control);

R.Assign(70, 0, 78, 1);
Control := New(PColoredText, Init(R, TekDate, $7E));
Insert(Control);



PrevName[0]:=#0;
PrevS[0]:=#0;
PrevSMarket[0]:=#0;
CurrentMakeOtdelenie:=Start;
CurrentClientOtdelenie:=Stop;


AddName;
L:=True;
PrevS[0]:=#0;
PrevName[0]:=#0;
Refresh;
Baz^.Select;
end;




Procedure TTransportWindow.CalcItogo;
Var R : TRect;
    t,l : Real;
    Sl,Sk,So,Sr : Real;

    SA,SKol : ArtikulStr;
    RealZena,s : TMyString;
    ItogoZ,ZZena,ItogoR,RZena:String[CIZena];
    ls : Word;
Begin
ItogoZ[0]:=#0;
ZZena[0]:=#0;
ItogoR[0]:=#0;
RZena[0]:=#0;
SKol[0]:=#0;
If TransportList^.List^.Count>0 Then
Begin
For ls:=0 To TransportList^.List^.Count-1 Do
Begin
 Skol:=Copy(TransportList^.GetText(ls,TransportList^.List^.Count),1+CName+1+CArtikul+1,CKol);
 RZena:=Copy(TransportList^.GetText(ls,TransportList^.List^.Count),1+CName+1+CArtikul+1+CKol+1,CZena);
 ZZena:=Copy(TransportList^.GetText(ls,TransportList^.List^.Count),1+CName+1+CArtikul+1+CKol+1+CZena+1,CZena);
 MyStr(StrToReal(ItogoZ)+StrToInt(SKol)*StrToReal(ZZena),CIZena,CMAntissa,ItogoZ);
 MyStr(StrToReal(ItogoR)+StrToInt(SKol)*StrToReal(RZena),CIZena,CMAntissa,ItogoR);
End;{For}
End;{If}
{MemC(ItogoZ+','+ItogoR);}
MyStr(StrToReal(ItogoZ),CIZena,CMAntissa,ItogoZ);
DelSpace(ItogoZ);
MyStr(StrToReal(ItogoR),CIZena,CMAntissa,ItogoR);
DelSpace(ItogoR);

AllZakupka:=ItogoZ;
Dispose(ControlItogoZ,Done);
R.Assign(15, 22, 30, 23);
if (strtoint(currentpassword)=0) Or (FindParam('/EZ')) then
ControlItogoZ := New(PColoredText, Init(R, #3+ItogoZ, $4E))
Else
ControlItogoZ := New(PColoredText, Init(R, #3+'!!!', $4E));
Insert(ControlItogoZ);

Dispose(ControlItogoR,Done);
R.Assign(47, 22, 62, 23);
ControlItogoR := New(PColoredText, Init(R, #3+ItogoR, $4E));
Insert(ControlItogoR);
End;



Procedure TTransportWindow.AddName;
Var R : TRect;
    KolStr : String[3];
Begin
  Str(TransportList^.List^.Count:2,KolStr);
  {DelSPace(KolStr);}
  Dispose(ControlAmount,Done);
  R.Assign(75, 22, 79, 23);
  ControlAmount := New(PColoredText, Init(R, #3+KolStr, $4e));
  Insert(ControlAmount);
End;


Procedure TTransportWindow.Refresh;

Var R : TRect;
         i : Word;
         ws,S : TMyString;
         SArt,PrevArt,Art : ArtikulStr;
         SZena,SDiv,St : String[CZena];
         SDAte,Si : String[CInputIZena];
         l,Logik : Boolean;
         SCod,sz,SName : AllStr;
         BazFilef :File;
         BE : PBufSkladType;

         SLitr : TDateString;
         sh,rs,Test1,Test2 : LongInt;
         ts1,ts2 : String;
         {IndexFile : IndexFileType;}
         {Index : PIndexType;}
         WspomList :PBox;
      c,Count : Word;
Begin
{Test1:=CurrentTime;}
{DInfo('Формирую список товаров...');}

Baz^.NewList(Nil);
Baz^.NewList(New(PMyCollection{PTextCollection}, Init(0,1)));


R.Assign(0, 0, 0, 0);
WspomList := New(PBox, Init(R, 1, Nil));
WspomList^.NewList(New(PTextCollection, Init(0,1)));

DInfoMsg('Выполняется загрузка остатков товара...');

Assign (RazdelFile,Path.ToRazdel+'razdel.db');
i:=IOResult;
Reset (RazdelFile);
If I=0 Then
Begin
While Not(Eof(RazdelFile)) Do
Begin
Read(RazdelFile,RazdelElement);


If RazdelElement.Employ Then
Begin
Assign (BazFilef,Path.ToSklad+RazdelElement.Kod+'.db');
i:=ioresult;
OldFileMode:=FileMode;
FileMode:=$42;
Reset(BazFilef,SizeOf(SkladType));
FileMode:=OldFileMode;
i:=ioresult;
If i=0 Then
Begin
While Not(Eof(BazFilef)) Do
 Begin
     Count:=0;
     New(be,Init);
     ReadBufSklad(BazFilef,be,Count);

For c:=1 To Count Do
Begin
  If be^.Point.Dat[c].Employ Then
  Begin
   l:=false;
   If (StrToInt(be^.Point.Dat[c].Input.DivisionS[CurrentMAkeOtdelenie])>0) then l:=true;
   if l then
   Begin
    SName := GetIdField(FNAme,be^.Point.Dat[c].BazKod);
    Format(SName,CName);
    Str(CurrentMAkeOtdelenie:1,SArtikul);
    Str(StrToInt(be^.Point.Dat[c].Input.DivisionS[CurrentMakeOtdelenie]):CKol,
    SDiv);
    SArt:=be^.Point.Dat[c].BazKod;
    RFormatZerro(SArt,CArtikul);
    SZena:=be^.Point.Dat[c].Input.R_Zena;
    RFormat(SZena,CZena);

    SDate := IntToSTr(1,CZena);
    RFormat(SDAte,CDAte);


    Prevs:=SName+'│'+SDate+'│'+SArt+'│'+SArtikul+'│'+SZena+'│';
    WspomList^.List^.Insert(NewStr(Prevs));
    WspomList^.SetRange(WspomList^.List^.Count);
   End;{L=True}
  End;{Employ}
End;{For}
   Dispose(BE,Done);
 End;{While}
System.Close(BazFilef);
End{IOResult=0}
 Else
  Begin
   MessageBox(^M+#3' Ошибка открытия '+Path.ToSklad+RazdelElement.Kod+'.db'^M+
   #3'Код: '+IntToStr(i,3),Nil,mfError+mfCancelButton);
  End;{Else}

End{Employ}
End;{While RazdelFile}
i:=ioresult;
System.Close(RazdelFile);
i:=ioresult;
End;

If WspomList^.List^.Count>0 Then
Begin
 For sh:=0 To WspomList^.List^.Count-1 Do
  Begin
        PrevS:=WspomList^.GetText(sh,WspomList^.List^.Count);
        System.Delete(PrevS,1+CNAme+1,CDate+1);
        Baz^.List^.Insert(NewStr(Prevs));
        Baz^.SetRange(Baz^.List^.Count);
  End;
End;

Dispose(WspomList,Done);

NoInfoMsg;
Redraw;



Baz^.FocusItem(0);
{конец}

FreshMarketHint;

FreshSkladHint;


PrevS[0]:=#0;
{Noinfo;}
End;


procedure TTransportWindow.UnlockAllName;
Var i : Integer;
    s : String;
Begin
If (TransportList^.List^.Count-1)>=0 Then
 For i:=0 To TransportList^.List^.Count-1 Do
 Begin
  s:=TransportList^.GetText(i,TransportList^.List^.Limit);
  s:=Copy(s,1+CName+1,CArtikul);
  Repeat
  Until(SetNameUnlock(s));
 End;
End;



procedure TTransportWindow.HandleEvent(var Event: TEvent);
Var R,R1 : TRect;
    i,test : Word;
    SertifSumma,SertifSkidka,s,s1,s2 : TMyString;
    l : Boolean;
    SArt,Nk_RZena,Nk_OZena : TDateString;
    {Rash : RashetType;}
         SDoc :ArtikulStr;
         SDate : TDateString;
         st:TDateString;
      TempBox : PBox;
      SZena,SName,SKol:String[55];
      Art : TDateString;

    DisableTovar,DisableDocument,LogikToVar,LogikDoc:Boolean;

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
    DInfoMsg('Позиция ['+s+'] отмечена как удаленная. Не могу заблокировать!');
    ClearEvent(Event);
    ClearEvent(Event);
    repeat
    Application^.GetEvent(Event);
    {until (Event.What in [evKeyDown,evMouseDown]);}
    until (Event.What <> evNothing);
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
    DInfoMsg('Позиция ['+s+'] используется'+Msg+'. Не могу заблокировать!');
    ClearEvent(Event);
    ClearEvent(Event);
    repeat
    Application^.GetEvent(Event);
    {until (Event.What in [evKeyDown,evMouseDown]);}
    until (Event.What <> evNothing);
    NoInfoMsg;
    ClearEvent(Event);
   End;
End;




begin
  Case Event.What Of
  evKeyDown:
     CAse Event.KeyCode Of
  kbCtrLDel: Begin
     If (TransportList^.State and sfFocused <> 0) And (TransportList^.List<>Nil)And(TransportList^.List^.Count>=1) Then
            Begin
             If MessageBox(#3+DelAll,nil,mfConfirmation+mfOkCancel)=cmOk Then
             Begin
                 UnLockAllName;

                 RedrawHeader(True);
                 {
                 ControlMakeOtdelenie^.Options := ControlMakeOtdelenie^.Options or ofSelectable;
                 ControlClientOtdelenie^.Options := ControlClientOtdelenie^.Options or ofSelectable;
                 }
                 TransportList^.NewList(nil);
                 TransportList^.NewList(New(PTextCollection, Init(0,1)));
                 TransportList^.Select;

                 FreshMarketHint;
                 CalCItogo;
                 AddName;
                 Redraw;
             End;
            End;
           End;
          kbDel: Begin
          If (TransportList^.State and sfFocused <> 0) And (TransportList^.List<>Nil)And(TransportList^.List^.Count>=1) Then
                     Begin
                         If MessageBox(#3+DelTovar,nil,mfConfirmation+mfOkCancel)=cmOk Then
                       Begin
                s:=TransportList^.GetText(TransportList^.Focused,TransportList^.List^.Count);
                s:=Copy(s,1+CName+1,CArtikul);
                Repeat
                Until (SetNameUnLock(s));


  TransportList^.List^.AtFree(TransportList^.Focused);
  TransportList^.SetRange(TransportList^.List^.Count);

  If TransportList^.Focused>0 Then TransportList^.FocusItem(TransportList^.Focused);
  If (TransportList^.Focused>=TransportList^.List^.Count) and(TransportList^.Focused>0) Then
  TransportList^.FocusItem(TransportList^.Focused-1);
                  FreshMarketHint;
                  CalCItogo;
                  AddName;
        If (TransportList^.List<>Nil)And(TransportList^.List^.Count>=1) Then
             Begin
              RedrawHeader(False);
              {
              ControlMakeOtdelenie^.Options := ControlMakeOtdelenie^.Options And Not ofSelectable;
              ControlClientOtdelenie^.Options := ControlClientOtdelenie^.Options And Not ofSelectable;
              }
             End
             Else
              Begin
                 RedrawHeader(True);
                 {
                 ControlMakeOtdelenie^.Options := ControlMakeOtdelenie^.Options or ofSelectable;
                 ControlClientOtdelenie^.Options := ControlClientOtdelenie^.Options or ofSelectable;
                 }
              End;
                  TransportList^.Select;
                  Redraw;
                 End;
                 ClearEvent(Event);
               End;
               End;
  kbEnter,kbF4:    Begin
        If Event.KeyCode=kbEnter Then
        If (Baz^.State and sfFocused <> 0) And (Baz^.List<>Nil)And(Baz^.List^.Count>=1) Then
                  Begin
        If (Baz^.State and sfFocused <> 0) And (Baz^.List<>Nil)And(TransportList^.List^.Count>CMax-1) Then
                    Begin
      MessageBox(#3^M+#3'В документе может быть'^M+
                 #3'не более '+ IntToStr(CMax,2)+' наименований !',Nil,mfError+mfCanCelButton);
               ClearEVent(Event);
               Exit;
                    End;

              s:=Copy(Baz^.GetText(Baz^.Focused,Baz^.List^.Count),1+CName+1,CArtikul);
              If TestElement(S,TransportList) Then
                        Begin
                if Not(lockselect) then
                          Begin
                           ClearEvent(Event);
                           Exit;
                          End;
                         s:=Baz^.GetText(Baz^.Focused,Baz^.List^.Count);
                         Trans^.Ini(s,0);
                         CalcItogo;
                         AddName;
                         FreshMarketHint;
                         If (Baz^.Focused+1)<Baz^.List^.Count Then
                          Begin
                          Baz^.FocusItem(Baz^.Focused+1);
                          End;
                         Redraw;
                         ClearEvent(Event);
                        End
                    Else MessageBox(#3^M+#3'Товар с кодом '+s+' уже есть'^M+
                    #3'в документе !',Nil,mfError+mfCanCelButton);
                    ClearEVent(Event);

   If (TransportList^.List<>Nil)And(TransportList^.List^.Count>=1) Then
    Begin
     RedrawHeader(False);
     {
     ControlMakeOtdelenie^.Options := ControlMakeOtdelenie^.Options or Not ofSelectable;
     ControlClientOtdelenie^.Options := ControlClientOtdelenie^.Options or Not ofSelectable;
     }
     Baz^.Select;
    End;


                  End;{Baz^.State}


        If ((Event.KeyCode=kbEnter)Or(Event.KeyCode=kbF4))
           And(TransportList^.State and sfFocused <> 0) And (TransportList^.List<>Nil)
               And (TransportList^.List^.Count>=1) Then
         Begin

              s:=Copy(TransportList^.GetText(TransportList^.Focused,TransportList^.List^.Count),1+CName+1,CArtikul);
                         s:=TransportList^.GetText(TransportList^.Focused,TransportList^.List^.Count);
                         Trans^.Ini(s,1);
                         CalcItogo;
                         AddName;
                         FreshMarketHint;


   If (TransportList^.List<>Nil)And(TransportList^.List^.Count>=1) Then
    Begin
     RedrawHeader(False);
     TransportList^.Select;
    End;
                         Redraw;
                    ClearEVent(Event);
        End;{TransportList^.State}



                    ClearEVent(Event);

           End;{Enter}
     Else;
     End;{Case Evemt.KeyCode}
  evCommand :
     Case Event.Command Of

     cmAbout: Begin
        AboutCHM('96');
        ClearEvent(Event);
       End;

     cmTransPort: Begin
                 ClearEvent(Event);
                End;
  cmRefresh :
        Begin
                Refresh;
          FreshSkladHint;
        End;



     cmOk : Begin

    If (TransportList^.List^.Count<1) Then
               Begin
               ClearEvent(Event);
               Exit;
              End;
              ClearFind;


If Not(TestOpenDate1(TekDate)) Then
   Begin
    MessageBox(#3^M+#3'Доступ к данным за '+TekDate+' заблокирован!',Nil,mfError+mfCancelButton);
    ClearEvent(Event);
    Exit;
   End;
ClearFind;

ClearFind;
                 L:=False;

             R.Assign(0,0,0,0);
             TempBox := New(PBox, Init(R, 1, Nil));
             TempBox^.NewList(New(PTextCollection, Init(0,1)));

             If (TransportList^.List^.Count)>0 Then
             For i:=0 To TransportList^.List^.Count-1 Do
              Begin
               s:=TransportList^.GetText(i,TransportList^.List^.Count);
               System.Delete(s,1,CName);
               SArt:=Copy(s,1+1,CArtikul);
               SName:=GetIdField(FFFName,SArt);
               Format(SName,CName+1+CNAme);
               Skol:=Copy(s,1+CArtikul+1,CKol);
               SZena:=Copy(s,1+CArtikul+1+CKol+1,CZena);
               MyStr(StrToReal(SZena)*StrToInt(SKol),CIZena,CMantissa,SZena);
               s:=SNAme+s+'│'+SZena;
               TempBox^.List^.Insert(NewStr(s));
               TempBox^.SetRange(TempBox^.List^.Count);
              End;

             TempBox^.FocusItem(0);

             PStaticText(ControlItogoR)^.GetTExt(s);
             If Pos(#3,s)>0 Then System.Delete(s,1,1);
             s:=' Всего сумма:'+s;

             PStaticText(ControlDoc)^.GetTExt(sdoc);
             If Pos(#3,sdoc)>0 Then System.Delete(sdoc,1,1);
             SDate:=FDate;



         If  FullScreen(TempBox,' Выбранн~ы~е товары                                      Код  Колич     Цена',s,
         SDoc,SDate,1) Then
            Begin
                 SaveToFile(L);
                 If L Then
                           Begin
                  Event.What:=evCommand;
                  Event.Command:=cmClose;
                  PutEvent(Event);
                  Status:=DocNormal;
                  TekDate := FDate;
                             End;
            End;
             Dispose(TempBox,Done);

             ClearEvent(Event);
            End;
  cmCancel :Begin
            l:=False;
         If (TransportList^.List<>Nil)And(TransportList^.List^.Count>0) Then
If MessageBox(#3^M+#3'Желаете отказаться от внутреннего перемещения товара ?',Nil,mfConFirmation+mfOkCancel)<>cmOk
             Then
               Begin
                l:=True;
               End;
               If Not(L) Then
                Begin
                 Event.What:=evCommand;
                 Event.Command:=cmClose;
                 PutEvent(Event);
                 ProdagaWindow:=False;
                 Status:=DocNormal;
                 TekDate := FDate;
                 UnLockAllName;
                End;
                 ClearEvent(Event);
                End;


  cmSelectOtdelenie:
 Begin
  If (PView(Otd)<>Desktop^.TopView)And(ControlMAkeOtdelenie^.State and sfFocused <> 0) Then
  Begin
   If Not((TransportList^.List<>Nil)And(TransportList^.List^.Count>=1)) Then
  Begin
     PStaticText(ControlMakeOtdelenie)^.GetText(S);
     System.Delete(S,1,1);
     PStaticText(ControlClientOtdelenie)^.GetText(S1);
     System.Delete(S1,1,1);

     R1.Assign(0, 3, 36, 15);
     Otd^.Start(Test,s,R1,0,StrToInt(Copy(s1,33,COne)),True);

     CurrentMakeOtdelenie:=StrToInt(Copy(s,33,COne));


     PStaticText(ControlMakeOtdelenie)^.Text^:=#3+S;
     Redraw;
     Case Test Of
      0,3 :FocusNext(True);
      1,2 :FocusNext(False);
     Else;
     End;
     Refresh;
   ClearEvent(Event);
  End;
  End;{ControlMAkeOtdelenie}

  If (PView(Otd)<>Desktop^.TopView)And(ControlClientOtdelenie^.State and sfFocused <> 0) Then
  Begin
   If Not((TransportList^.List<>Nil)And(TransportList^.List^.Count>=1)) Then
  Begin
     PStaticText(ControlClientOtdelenie)^.GetText(S);
     System.Delete(S,1,1);

     PStaticText(ControlMakeOtdelenie)^.GetText(S1);
     System.Delete(S1,1,1);

     R1.Assign(41, 3, 77, 15);
     Otd^.Start(Test,s,R1,1,StrToInt(Copy(s1,33,COne)),True);

     CurrentClientOtdelenie:=StrToInt(Copy(s,33,COne));

     PStaticText(ControlClientOtdelenie)^.Text^:=#3+S;
     Redraw;
     Case Test Of
      0,3 :FocusNext(True);
      1,2 :FocusNext(False);
     Else;
     End;
     {Refresh;}
   ClearEvent(Event);
  End;{ControlMAkeOtdelenie}
 End;
 End;{cmSelectOtdelenie}

  cmCancel :    Begin
                 Event.What:=evCommand;
                 Event.Command:=cmClose;
                 PutEvent(Event);
                 Status:=DocNormal;
                 TekDate := FDate;
                 ClearEvent(Event);
                End;

      Else;
      End;{evCommand}
      Else;
      End;{*Case*}
 if (Event.What = evBroadcast) and
     (Event.Command = cmTransport) then ClearEvent(Event);

 If (PView(Otd)<>Desktop^.TopView)And
 ((ControlMakeOtdelenie^.State and sfFocused <> 0)Or(ControlClientOtdelenie^.State and sfFocused <> 0))
 And (Event.Command<>cmSelectOtdelenie) And (Event.What <> EvKeyDown)Then
            Begin
{
 If (ControlMakeOtdelenie^.State and sfFocused <> 0) And
    Not((TransportList^.List<>Nil)And(TransportList^.List^.Count>=1)) Then Exit;
}
             Event.What:=EvCommand;
             Event.Command:=cmSelectOtdelenie;
             PutEvent(Event);
             ClearEvent(Event);
            End;

 inherited HandleEvent(Event);

 If (Desktop^.Current=PView(TransportWindow)) And (Event.What <> EvKeyDown) Then
           Begin
              if (Baz^.State and sfFocused <> 0)  And(Baz^.List<>Nil) And (Baz^.List^.Count>=1)Then
              Begin
               s:=Baz^.GetText(Baz^.Focused,Baz^.List^.Count);
               If s <> PrevS Then
                 Begin
                  PrevS:=Copy(s,1+CName+1,CArtikul);
                  FreshSkladHint;
                  PrevS:=Baz^.GetText(Baz^.Focused,Baz^.List^.Count);
                End
              End;

              if (TransportList^.State and sfFocused <> 0)  And(TransportList^.List<>Nil)
                       And (TransportList^.List^.Count>=1)Then
              Begin
               s:=TransportList^.GetText(TransportList^.Focused,TransportList^.List^.Count);
               If s <> PrevSMarket Then
                 Begin
                  FreshMarketHint;
                 End
              End;


            DrawFullNAme;
           End;

end;


End.