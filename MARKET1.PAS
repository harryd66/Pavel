{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}


{$I Compile.INC}

Unit Market;

Interface


Uses Dialogs,Drivers,Glob,Access,ServStr,MyCalc;

Type
  PMarketWindow = ^TMarketWindow;
  TMarketWindow = object(TDialog)
   Calc        : PMyCalculator;
    Procedure Ini(s:TMyString;Regim:Word);
    procedure HandleEvent(var Event: TEvent); virtual;
    Destructor Done;Virtual;
  end;

Type
  PNetTestWindow = ^TNetTestWindow;
  TNetTestWindow = object(TDialog)
    Function Start(l:PSuperMarketType;Itog:Real;LockBox:PBox):Boolean;
    procedure Refresh;
    procedure HandleEvent(var Event: TEvent); virtual;
    Destructor Done;Virtual;
  end;


Type NalogType=Record
      ENalog  : String[CIZena];
      Nalog5  : String[CIZena];
      Nalog3  : String[CIZena];
      Nalog_  : String[CIZena];
      Zakupka : String[CIZena]
     End;


Type
  PSuperMarketWindow = ^TSuperMarketWindow;
  TSuperMarketWindow = object(TDialog)
    Cl   : PClientWindow;
    Mark : PMarketWindow;
    NetTest :PNetTestWindow;
    constructor Init(Var l: Boolean);
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure AddName;
    Procedure SetEnabledDoc(i:Byte);
    procedure OpenSuperMarketWindow;
    Function  CalcItogo (Var ItogNalog:NalogType): Real;
    Procedure SaveToFile(Var Save : Boolean);
    Procedure Refresh(REgim:Boolean);
    Procedure FreshClient;
    Procedure SetMaska(O:Word);
    Procedure FreshMarketHint;
    Procedure FreshSkladHint;
    Procedure FreshShkala;

{   Procedure Sbros;}
    Procedure SetSelector;
    end;


Procedure SortNKL (Var L:PSuperMarketType);
Function InputBN(Var l:PSuperMarketType):Boolean;

 Implementation

uses App,DBEngine,Objects, Views, MsgBox,Vision1,Nastr,Protect,{Calc,}NetCall,Windos,
        ColorTxt,Serv,InpLong,Validate,CPrihod,TpDate,Net,NetDbEng;

Type MW = Record
     Pack   : Word;
     Kol    : String[CKol];
     Skidka : String[CZena];
     End;

Const Est='ЕСТЬ';
      Netu='НЕТ';

var
 Control1Skidka,ControlSkidka,ControlKol,Pack,ControlItogoSkidka,
 ControlLS,Control_Litr,ControlSertif,{ControlAkzis,}ControlOperatorSelect,
 ControlDoc,Control_I,ControlCurrent,ControlPack,ControlSelect,ControlClient,
 ControlBKol,ControlBZena ,ControlProdagaSkidka,ControlProdagaZena,ControlMesto,
 ControlSpecNalog,ControlError,ControlNetNDS,ControlNetKol,ControlNetZena,
 ControlNetNalog,ControlShkala: PView;
{ Mark : PMarketWindow;}

 MarketWin : PMarketWindow;
 SuperMarketWindow : PSuperMarketWindow;
 NetTestWindow : PNetTestWindow;
 NetTestBox : PBox;
 PrevMarket : PSuperMarketType;
 PrevS : TEnjoyStr;
 PrevNet,PrevSMarket : string[150];
 SOtd,SArtikul : String[CArtikul];
 El : MW;
 ClientShkala,Selector,Skidka,OperatorSelector,Prom   : Word;
 PrevKolPack : Byte;
 PrevKol : String[CKol];
 Information,DebInfo : Boolean;
 VidRashet : Word;
 ActiveOtdel :String[CKol];
 ItogNalog:NalogType;


{запрещает автоматическую скидку по консигнации для не супервизора}
Procedure EDAutoSkidka;
Begin
(*нужна только в хэппи
If Selector in [0,5..8] Then
   Begin
    If Skidka=0 Then Skidka:=1;
    Begin
    ControlSkidka^.SetData(Skidka);
    End;
    PCluster(ControlSkidka)^.SetButtonState($1, False)
   End
Else
   PCluster(ControlSkidka)^.SetButtonState($1, True);
*)
End;


function NewPassword(i:Byte) : Boolean;
var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  s : String[10];
  c : Word;
  L : Boolean;
begin
s[0]:=#0;
NewPassword:=False;
R.Assign(18, 8, 61, 15);
New(Dlg, Init(R, 'Внимание - серьезная ошибка'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.Palette := dpBlueDialog;
Dlg^.HelpCtx:=$E241;


R.Assign(29, 4, 41, 5);
Control := New(PSInputLine, Init(R, 10));
Dlg^.Insert(Control);
{
R.Assign(2, 4, 29, 5);
Control := New(PStaticText, Init(R, 'Повторите свой код доступа:'));}
R.Assign(2, 3, 29, 5);
Control := New(PColoredText, Init(R, #3'Если рискнете продолжить'^M+
     'Повторите свой код доступа:',$1F));

Dlg^.Insert(Control);
{
R.Assign(5, 1, 38, 3);
CAse i Of
0:Control := New(PColoredText, Init(R, 'Долг клиента превышает сумму допусти'+
     'мого долга!', $1F));
3:Control := New(PColoredText, Init(R,#3'У клиента не указан номер лицензии!', $1F));

4:Control := New(PColoredText, Init(R,#3'Вы ввели слишком большую для вашего уровня доступа скидку!', $1F));

1:Control := New(PColoredText, Init(R, 'За клиентом числится просроченный не'+
     'оплаченный документ!', $1F));
2:Control := New(PColoredText, Init(R,#3'У клиента не указан договор консигнации!', $1F));
Else;
End;
}

R.Assign(5, 1, 38, 3);
CAse i Of
0:Control := New(PStaticText, Init(R, 'Долг клиента превышает лимит допусти'+
     'мого долга!'));
3:Control := New(PStaticText, Init(R,#3'У клиента не указан номер лицензии!'));

4:Control := New(PStaticText, Init(R,#3'Вы ввели слишком большую для вашего уровня доступа скидку!'));

5:Control := New(PStaticText, Init(R,#3'У клиента истекла лицензия! Клиенту нельзя выдавать С/Ф!'));

1:Control := New(PStaticText, Init(R, 'За клиентом числится просроченный не'+
     'оплаченный документ!'));
2:Control := New(PStaticText, Init(R,#3'У клиента не указан договор консигнации!'));
Else;
End;


Dlg^.Insert(Control);

l:=False;
Dlg^.SelectNext(False);
SpecialBeep;
c:=Desktop^.ExecView(Dlg);
 If c<>cmCancel Then
 Begin
 Dlg^.GetData(s);
 UpStr(S);
 DelSpace(s);
 If s<>Decode(GetOperatorPassword(CurrentPassword)) Then L:=False
 Else L:=True;
 End;

Dispose(Control,Done);
Dispose(Dlg,Done);

If Not(l) Then
 MessageBox(#3^M+#3'Ошибочный код доступа!',Nil,mfError+mfCancelButton);
NewPassword:=l;
end;




{
Function DeleteRealizasToClientFile:Boolean;
Var l : PRealizasiaType;
    RealFile : File Of RealizasiaType;
    NewFile : File Of RealizasiaType;
    i : Byte;
    Log : Boolean;
Begin
 DeleteRealizasToClientFile:=False;
 Assign(RealFile,Path.ToDolg+PrevMarket^.Dat.ClientKod+'.dlg');
 Assign(NewFile,Path.ToDolg+PrevMarket^.Dat.ClientKod+'.new');
 Rewrite(NewFile);
 i:=IOResult;
 Reset(RealFile);
 i:=IOResult;
 If i <> 0 Then
  Begin
    MessageBox(#3^M+#3'Файл задолженности клиента '^M+#3+Path.ToDolg+PrevMarket^.Dat.ClientKod+'.dlg не найден!'^M
   ,Nil,mfError+mfCancelButton);
    Close(NewFile);
    Exit;
  End;
        New(l,Init);
        DelSpace(PrevMarket^.Dat.Document);
        While Not(Eof(RealFile))Do
        Begin
         Read(RealFile,L^.Dat);
         DelSpace(L^.Dat.Market.Document);
          If Not((ClearChar(PrevMarket^.Dat.Document)=ClearChar(L^.Dat.Market.Document))And
          (PrevMArket^.Dat.DateC=L^.Dat.Market.DateC)) Then
          Write(NewFile,L^.Dat);
        End;
    Close(NewFile);
    Close(RealFile);
    Dispose(L,Done);
    DInfoMsg('Уничтожаю старый файл '+Path.ToDolg+PrevMarket^.Dat.ClientKod+'.dlg...');
    i:=IOResult;
    Repeat
    Erase(RealFile);
    i:=IOResult;
    Until i=0;
    NoInfoMsg;
    DInfoMsg('Создаю новый файл '+Path.ToDolg+PrevMarket^.Dat.ClientKod+'.dlg...');
    i:=IOResult;
    Repeat
    Rename(NewFile,Path.ToDolg+PrevMarket^.Dat.ClientKod+'.dlg');
    i:=IOResult;
    Until i=0;
    NoInfoMsg;
    DeleteRealizasToClientFile:=True;
End;
}

Function DeleteRealizasToClientFile:Boolean;
Var l : PRealizasiaType;
    RealFile : File Of RealizasiaType;
    NewFile : File Of RealizasiaType;
    i : Byte;
    Find,Log : Boolean;

Begin
 DeleteRealizasToClientFile:=False;
 Assign(RealFile,Path.ToDolg+PrevMarket^.Dat.ClientKod+'.dlg');
 i:=IOResult;
 Reset(RealFile);
 i:=IOResult;
 If i <> 0 Then
  Begin
    MessageBox(#3^M+#3'Файл задолженности клиента '^M+#3+Path.ToDolg+PrevMarket^.Dat.ClientKod+'.dlg не найден!'^M
   ,Nil,mfError+mfCancelButton);
    Exit;
  End;
  New(l,Init);
  DelSpace(PrevMarket^.Dat.Document);
  Find:=False;
  DInfoMsg('Ищу документ в долгах клиента '+PrevMarket^.Dat.ClientKod+'...');
  While Not(Eof(RealFile)) And Not(Find) Do
        Begin
         Read(RealFile,L^.Dat);
         DelSpace(L^.Dat.Market.Document);
          If ((ClearChar(PrevMarket^.Dat.Document)=ClearChar(L^.Dat.Market.Document))And
          (PrevMArket^.Dat.DateC=L^.Dat.Market.DateC) And (L^.Dat.Market.Active)) Then Find:=True;
        End;

  If Not(Find) Then
   Begin
    NoInfoMsg;
    Dispose(L,Done);
    Close(RealFile);
    MessageBox(#3'Документ N '+ClearChar(PrevMarket^.Dat.Document)+
    ' от '+PrevMArket^.Dat.DateC+' в долгах клиента не найден!'^M+
    ClicProgrammer,Nil,mfError+mfCancelButton);
    Exit;
   End;

    Seek(RealFile,FilePos(RealFile)-1);
    L^.Dat.Market.Active:=False;
    Write(RealFile,L^.Dat);
    i:=IoREsult;
    Close(RealFile);
    i:=IoREsult;
    Dispose(L,Done);
    NoInfoMsg;
    DeleteRealizasToClientFile:=True;
End;


Procedure TSuperMarketWindow.FreshMarketHint;
Var R : TRect;
Begin
If Prodaga^.List^.Count>0 Then
Begin
Dispose(ControlProdagaZena,Done);
R.Assign(54, 21, 62, 22);
PrevSMarket:=Copy(Prodaga^.GetText(Prodaga^.Focused,Prodaga^.List^.Count),1+CName+1+CArtikul+1+COne+1+CLitr+1+CKol+1,CZena);
DelSpace(PrevSMarket);
{PStaticText(ControlProdagaZena)^.Text^:=#3+PrevSMarket;}
ControlProdagaZena := New(PColoredText, Init(R, #3+PrevSMarket, $7E));
Insert(ControlProdagaZena);

Dispose(ControlProdagaSkidka,Done);
R.Assign(70, 21, 78, 22);
PrevSMarket:=Copy(Prodaga^.GetText(Prodaga^.Focused,Prodaga^.List^.Count),1+CName+1+CArtikul+1+COne+1+CLitr+1+CKol+1+CZena+1,
CZena);
DelSpace(PrevSMarket);
{PStaticText(ControlProdagaSkidka)^.Text^:=#3+PrevSMarket;}
ControlProdagaSkidka := New(PColoredText, Init(R, #3+PrevSMarket, $7E));
Insert(ControlProdagaSkidka);
PrevSMarket:=Prodaga^.GetText(Prodaga^.Focused,Prodaga^.List^.Count);
End
Else
 Begin
Dispose(ControlProdagaZena,Done);
R.Assign(54, 21, 62, 22);
ControlProdagaZena := New(PColoredText, Init(R, #3+'', $7E));
Insert(ControlProdagaZena);

Dispose(ControlProdagaSkidka,Done);
R.Assign(70, 21, 78, 22);
ControlProdagaSkidka := New(PColoredText, Init(R, #3+'', $7E));
Insert(ControlProdagaSkidka);
PrevSMarket[0]:=#0;
 End;
End;



Procedure TSuperMarketWindow.FreshSkladHint;
Var R : TRect;
    Otd : String[COne];
    Sart : ArtikulStr;
    l : LongInt;
Begin
If Baz^.List^.Count>0 Then
Begin
Dispose(ControlBKol,Done);
R.Assign(7, 21, 12, 22);
{PrevS:=Copy(Baz^.GetText(Baz^.Focused,Baz^.List^.Count),1+CName+1+CArtikul+1+COne+1+CLitr+1+CInPack+1,CKol);}
PrevS:=Copy(Baz^.GetText(Baz^.Focused,Baz^.List^.Count),1+CName+1,CArtikul);
Otd:=Copy(Baz^.GetText(Baz^.Focused,Baz^.List^.Count),1+CName+1+CArtikul+1,COne);
DelSpace(Otd);
Sart:=PrevS;
PrevS:=BakGetField(FDiv,PrevS,StrToInt(Otd));
If Status=DocEdit Then
 Begin
  Str((StrToInt(PrevS)+GetKolMarket(Sart,StrToInt(Otd),PrevMarket)):CKol,PrevS);
 End;
DelSpace(PrevS);
Format(PrevS,CKol);

{PStaticText(ControlBKol)^.Text^:=#3+PrevS;}
ControlBKol := New(PColoredText, Init(R, #3+PrevS, $7E));
Insert(ControlBKol);

Dispose(ControlBZena,Done);
R.Assign(18, 21, 26, 22);
PrevS:=Copy(Baz^.GetText(Baz^.Focused,Baz^.List^.Count),1+CName+1,CArtikul);
If Selector in [0,1] Then
PrevS:=BakGetField(FRZena,PrevS,0)
Else
PrevS:=BakGetField(FOZena,PrevS,0);
DelSpace(PrevS);
Format(PrevS,CZena);
ControlBZena := New(PColoredText, Init(R, #3+PrevS, $7E));
Insert(ControlBZena);
End;
End;

Procedure TSuperMarketWindow.FreshShkala;
Var R : TRect;
Begin
Dispose(ControlShkala,Done);
R.Assign(41, 21, 48, 22);
If Skidka in [2] Then
ControlShkala := New(PColoredText, Init(R, 'Шкала '+IntToStr(ClientShkala,COne), $5F))
Else
ControlShkala := New(PColoredText, Init(R, '', $74));
Insert(ControlShkala);
End;


(*
Function WriteMarketToFile(L:PSuperMarketType) : Boolean;
Var SuperMarketFile : File Of SuperMarketType;
    c : Byte;
    SDoc : ArtikulStr;
Begin
 WriteMarketToFile:=False;
 Assign(SuperMarketFile,Path.ToMarket+TekDate+'.mrk');
 c:=IOResult;
{$I-}
 Reset(SuperMarketFile);
 c:=IOResult;
If c<>0 Then
 Begin
  If MessageBox('Файл '+TekDate+'.mrk не существует !'^M+
     'Создать такой файл?'+
        +' Код:'+IntToStr(c,3),nil, mfConfirmation + mfOkCancel)=cmOk  Then
     Begin
     {
      c:=Ioresult;
      Reset(SuperMarketFile);
      c:=Ioresult;
      If c<>0 Then Rewrite(SuperMarketFile);
     }
      If Not(CreatToDayF(DocMarket,TekDate)) Then Exit;
      Reset(SuperMarketFile);
      c:=IOResult;
     End
    Else
     Begin
      Exit;
     End;
 End;
 If c <> 0 Then Begin
                 MessageBox('Нет доступа к файлу '+TekDate+'.mrk!',
                 nil, mfError + mfOkButton);
                 Exit;
                End
 Else
  Begin
   SDoc:=L^.Dat.Document;
   Seek(SuperMarketFile,StrToInt(ClearChar(SDoc))-1);
   Write(SuperMarketFile,L^.Dat);
   Close(SuperMarketFile);
   WriteMarketToFile:=True;
  End;
End;

*)


Function WriteMarketToSkladFile(L:PSuperMarketType) : Boolean;
Var SkladFile : File Of SkladType;
    Sklad : PSkladType;
    i,p : Byte;
    s1 : TEnjoyStr;
Begin
WriteMarketToSkladFile:=False;
If Status=DocEdit Then
Begin
 For i:=1 To PrevMarket^.Dat.Amount{J} Do
  Begin
   New(Sklad,Init);
   S1:=Copy(PrevMarket^.Dat.MarketElement[i].BazKod,1,CRazdelKod);
   Assign(SkladFile,Path.ToSklad+s1+'.db');
   p:=IOResult;
   Reset(SkladFile);
   p:=IOResult;
   If p <> 0 Then
    Begin
     MessageBox(#3^M+#3'Ошибка доступа к файлу '+S1+'.db!',Nil,mfError+mfCancelButton);
     Dispose(Sklad,Done);
     Exit;
    End;
   Seek(SkladFile,GetFileLocation3(Copy(PrevMarket^.Dat.MarketElement[i].BazKod,CRazdelKod+1,CKod)));

   Repeat
   Pause(1);
   Until Lock(SkladFile,FilePos(SkladFile)*SizeOf(SkladType),SizeOf(SkladType));

   Read(SkladFile,Sklad^.Dat);
   With Sklad^.Dat.Input Do
   Begin
     Caption:=PrevMarket^.Dat.Caption;
     DelSpace(PrevMarket^.Dat.MarketElement[i].Input.Kol);
     Sklad^.Dat.Date := TekDate;
     Sklad^.Dat.Time := Times;
     Str((StrToInt(DiviSion[PrevMarket^.Dat.MarketElement[i].Input.DiviSionNumber])
     +StrToInt(PrevMarket^.Dat.MarketElement[i].input.kol)):
     CKol,Division[PrevMarket^.Dat.MarketElement[i].InPut.DiviSionNumber]);
   End;
   {Sklad^.Dat.Employ:=True;}
   Sklad^.Dat.Input.Kol[0]:=#0;
   For p:=1 To CDiviSion Do
   Str((StrToInt(Sklad^.Dat.Input.Kol)+StrToInt(Sklad^.Dat.Input.Division[p])):CKol,Sklad^.Dat.Input.Kol);

   Seek(SkladFile,GetFileLocation3(Copy(PrevMarket^.Dat.MarketElement[i].BazKod,CRazdelKod+1,CKod)));
   Write(SkladFile,Sklad^.Dat);

   Seek(SkladFile,FilePos(SkladFile)-1);
   Repeat
    UnLock(SkladFile,FilePos(SkladFile)*SizeOf(SkladType),SizeOf(SkladType));
   Until (DosError=0);

   Close(SkladFile);
   Dispose(Sklad,Done);
  End;
End;

 For i:=1 To L^.DAt.Amount{J} Do
  Begin
   New(Sklad,Init);
   S1:=Copy(L^.Dat.MArketElement[i].BazKod,1,CRazdelKod);
   Assign(SkladFile,Path.ToSklad+s1+'.db');
   p:=IOResult;
   Reset(SkladFile);
   p:=IOResult;
   If p <> 0 Then
    Begin
     MessageBox(#3^M+#3'Ошибка доступа к файлу '+S1+'.db!',Nil,mfError+mfCancelButton);
     Dispose(Sklad,Done);
     Exit;
    End;
   Seek(SkladFile,GetFileLocation3(Copy(L^.Dat.MarketElement[i].BazKod,CRazdelKod+1,CKod)));

   Repeat
   Pause(1);
   Until Lock(SkladFile,FilePos(SkladFile)*SizeOf(SkladType),SizeOf(SkladType));

   Read(SkladFile,Sklad^.Dat);
   With Sklad^.Dat.Input Do
   Begin
     Caption:=L^.Dat.Caption;
     DelSpace(L^.Dat.MarketElement[i].Input.Kol);
     Sklad^.Dat.Date := TekDate;
     Sklad^.Dat.Time := Times;
Str((StrToInt(DiviSion[L^.Dat.MarketElement[i].Input.DiviSionNumber])-StrToInt(L^.Dat.MarketElement[i].Input.Kol))
:CKol,Division[L^.Dat.MarketElement[i].InPut.DiviSionNumber])
   End;
{   Sklad^.Dat.Baz.Employ:=True;}
   Sklad^.Dat.Input.Kol[0]:=#0;
   For p:=1 To CDiviSion Do
   Str((StrToInt(Sklad^.Dat.Input.Kol)+StrToInt(Sklad^.Dat.Input.Division[p])):CKol,Sklad^.Dat.Input.Kol);
   Seek(SkladFile,GetFileLocation3(Copy(L^.Dat.MarketElement[i].BazKod,CRazdelKod+1,CKod)));
   Write(SkladFile,Sklad^.Dat);

   Seek(SkladFile,FilePos(SkladFile)-1);

   Repeat
    UnLock(SkladFile,FilePos(SkladFile)*SizeOf(SkladType),SizeOf(SkladType));
   Until (DosError=0);

   Close(SkladFile);
   Dispose(Sklad,Done);
  End;
WriteMarketToSkladFile:=True;
End;

(*
Function AddMarkerLast(L:PSuperMarketType) : Boolean;
Var SkladFile : File Of SkladType;
    Sklad : PSkladType;
    i,p : Byte;
    s1 : TEnjoyStr;
Begin
AddMarkerLast:=False;
 For i:=1 To L^.DAt.Amount{J} Do
  Begin
   New(Sklad,Init);
   S1:=Copy(L^.Dat.MArketElement[i].BazKod,1,CRazdelKod);
   Assign(SkladFile,Path.ToSklad+s1+'.db');
   p:=IOResult;
   Reset(SkladFile);
   p:=IOResult;
   If p <> 0 Then
    Begin
     MessageBox(#3^M+#3'Ошибка доступа к файлу '+S1+'.db!',Nil,mfError+mfCancelButton);
     Dispose(Sklad,Done);
     Exit;
    End;
   Seek(SkladFile,GetFileLocation3(Copy(L^.Dat.MarketElement[i].BazKod,CRazdelKod+1,CKod)));

   Repeat
   Pause(1);
   Until Lock(SkladFile,FilePos(SkladFile)*SizeOf(SkladType),SizeOf(SkladType));

   Read(SkladFile,Sklad^.Dat);

   Seek(SkladFile,FilePos(SkladFile)-1);

   Repeat
    UnLock(SkladFile,FilePos(SkladFile)*SizeOf(SkladType),SizeOf(SkladType));
   Until (DosError=0);
   Close(SkladFile);

   With Sklad^.Dat.Input Do
   Begin
     DelSpace(L^.Dat.MarketElement[i].Input.Kol);
     If Status=DocEdit Then
     Str((StrToInt(DiviSion[L^.Dat.MarketElement[i].Input.DiviSionNumber])+
            -GetFullKolMarket(L^.Dat.MarketElement[i].BazKod,PrevMarket)
            -StrToInt(L^.Dat.MarketElement[i].Input.Kol))
     :CKol,Division[L^.Dat.MarketElement[i].InPut.DiviSionNumber])
     Else
     Str((StrToInt(DiviSion[L^.Dat.MarketElement[i].Input.DiviSionNumber])-StrToInt(L^.Dat.MarketElement[i].Input.Kol))
     :CKol,Division[L^.Dat.MarketElement[i].InPut.DiviSionNumber])
   End;

   Sklad^.Dat.Input.Kol[0]:=#0;
   For p:=1 To CDiviSion Do
   Str((StrToInt(Sklad^.Dat.Input.Kol)+StrToInt(Sklad^.Dat.Input.Division[p])):CKol,Sklad^.Dat.Input.Kol);
   If StrToInt(Sklad^.Dat.Input.Kol)=0 Then L^.Dat.MarketElement[i].Input.Last:=True;
   Dispose(Sklad,Done);
  End;{For}

AddMarkerLast:=True;
End;
*)


Procedure NetChangeProdaga(A,otd:allstr;Vid:Byte;Znashenie:AllStr);
Var Count : Word;
    s : string[150];
    find : boolean;
    FindArt,FindOtd:ArtikulStr;
    Summa : String[CInputIZena];
    SRZena,SOZena,Zena:String[CZena];
Begin
Find:=False;
If Prodaga^.List^.Count>0 Then
 Begin
  For count:=0 To Prodaga^.List^.Count-1 Do
   Begin
    s:=Prodaga^.GetText(count,Prodaga^.List^.Count);
    FindArt:=Copy(s,1,CArtikul);
    FindOtd:=Copy(s,1+CArtikul+1+CName+1,COne);
    If (FindArt=A) And (FindOtd=Otd) Then
     Begin
      Find:=True;
      Break;
     End;
   end;{For}

   If Not(Find) Then
    Begin
     MessageBox(#3'Позиция '+A+' из отделения '+Otd+' не найдена!'^M+
        ClicProgrammer,Nil,mfError+mfCancelButton);
     Exit;
    End;{if Not(Find)}

{1-наименование запретили к продаже
 2-отсутствует необходимое количество
 3-изменена цена
 4-изменена ставка ндс
 5-вид НДС
 6-изменена ставка нп
 7-вид НП
 8-изменена ставка скидки (авто)
 9-изменена закупка}

{Имя код отд кол литраж цена скидка сумма цена Р Цена О Налог ВидНП НДС ВидНДС Закупка}

   Case Vid Of
{количество}
   2:Begin
      Str(StrToInt(Znashenie):CKol,Znashenie);
      Format(ZnaShenie,CKol);
      Delete(s,1+CName+1+CArtikul+1+COne+1,CKol);
      Insert(Znashenie,s,1+CName+1+CArtikul+1+COne+1);
      {обновление суммы итого}
      SRZena:=Copy(s,1+CName+1+CArtikul+1+COne+1+CKol+1+CLitr+1,CZena);{новая цена}
      Str(StrToInt(Znashenie)*StrToReal(SRZena):CInputIZena:CMantissa,Summa);
      DelSPace(summa);
      Format(Summa,CInputIZena);
      Delete(s,1+CName+1+CArtikul+1+COne+1+CKol+1+CLitr+1+CZena+1+CZena+1,CInputIZena);
      Insert(Summa,s,1+CName+1+CArtikul+1+COne+1+CKol+1+CLitr+1+CZena+1+CZena+1);

     End;
{цена}
   3:Begin
      SRZena:=BakGetField(FRZena,A,0);
      DelSpace(SRZena);
      Str(StrToReal(SRZena):CZena:CMAntissa,SRZena);
      SOZena:=BakGetField(FOZena,A,0);
      DelSpace(SOZena);
      Str(StrToReal(SOZena):CZena:CMAntissa,SOZena);
      If Selector in [0,1] Then
      ZnaShenie:=SRZena
      Else ZnaShenie:=SOZena;
      Format(ZnaShenie,CZena);
      Format(SRZena,CZena);
      Format(SOZena,CZena);
      {замена цены продажи}
      Delete(s,1+CName+1+CArtikul+1+COne+1+CKol+1+CLitr+1,CZena);
      Insert(Znashenie,s,1+CName+1+CArtikul+1+COne+1+CKol+1+CLitr+1);
      {замена Р/Ц}
      Delete(s,1+CName+1+CArtikul+1+COne+1+CKol+1+CLitr+1+CZena+1+CZena+1+CInputIZena+1,CZena);
      Insert(SRZena,s,1+CName+1+CArtikul+1+COne+1+CKol+1+CLitr+1+CZena+1+CZena+1+CInputIZena+1);
      {замена О/Ц}
      Delete(s,1+CName+1+CArtikul+1+COne+1+CKol+1+CLitr+1+CZena+1+CZena+1+CInputIZena+1+CZena+1,CZena);
      Insert(SOZena,s,1+CName+1+CArtikul+1+COne+1+CKol+1+CLitr+1+CZena+1+CZena+1+CInputIZena+1+CZena+1);

      {обновление суммы итого}
      SRZena:=Copy(s,1+CName+1+CArtikul+1+COne+1,CKol);{новое количество}
      Str(StrToReal(Znashenie)*StrToInt(SRZena):CInputIZena:CMantissa,Summa);
      DelSPace(summa);
      Format(Summa,CInputIZena);

      Delete(s,1+CName+1+CArtikul+1+COne+1+CKol+1+CLitr+1+CZena+1+CZena+1,CInputIZena);
      Insert(Summa,s,1+CName+1+CArtikul+1+COne+1+CKol+1+CLitr+1+CZena+1+CZena+1);
     End;
{НДС}
   4:Begin
      Str(StrToReal(Znashenie):CLitr:CMAntissa,Znashenie);
      Format(ZnaShenie,CLitr);
      Delete(s,1+CName+1+CArtikul+1+COne+1+CKol+1+CLitr+1+CZena+1+CZena+1+CInputIZena+1+
         CZena+1+CZena+1+CLitr+1+COne+1,CLitr);
      Insert(Znashenie,s,1+CName+1+CArtikul+1+COne+1+CKol+1+CLitr+1+CZena+1+CZena+1+CInputIZena+1+
         CZena+1+CZena+1+CLitr+1+COne+1);
     End;
{вид НДС}
   5:Begin
      Format(ZnaShenie,COne);
      Delete(s,1+CName+1+CArtikul+1+COne+1+CKol+1+CLitr+1+CZena+1+CZena+1+CInputIZena+1+
         CZena+1+CZena+1+CLitr+1+COne+1+CLitr+1,COne);
      Insert(Znashenie,s,1+CName+1+CArtikul+1+COne+1+CKol+1+CLitr+1+CZena+1+CZena+1+CInputIZena+1+
         CZena+1+CZena+1+CLitr+1+COne+1+CLitr+1);
     End;
{НП}
   6:Begin
      Str(StrToReal(Znashenie):CLitr:CMAntissa,Znashenie);
      Format(ZnaShenie,CLitr);
      Delete(s,1+CName+1+CArtikul+1+COne+1+CKol+1+CLitr+1+CZena+1+CZena+1+CInputIZena+1+
         CZena+1+CZena+1,CLitr);
      Insert(Znashenie,s,1+CName+1+CArtikul+1+COne+1+CKol+1+CLitr+1+CZena+1+CZena+1+CInputIZena+1+
         CZena+1+CZena+1);
     End;
(*
{вид НП}
   7:Begin
      Format(ZnaShenie,COne);
      Delete(s,1+CName+1+CArtikul+1+COne+1+CKol+1+CLitr+1+CZena+1+CZena+1+CInputIZena+1+
         CZena+1+CZena+1+CLitr+1,COne);
      Insert(Znashenie,s,1+CName+1+CArtikul+1+COne+1+CKol+1+CLitr+1+CZena+1+CZena+1+CInputIZena+1+
         CZena+1+CZena+1+CLitr+1);
     End;
{Закупка}
   9:Begin
      Str(StrToReal(Znashenie):CZena:CMAntissa,Znashenie);
      Format(ZnaShenie,CZena);
      Delete(s,1+CName+1+CArtikul+1+COne+1+CKol+1+CLitr+1+CZena+1+CZena+1+CInputIZena+1+
         CZena+1+CZena+1+CLitr+1+COne+1+CLitr+1+COne+1,CZena);
      Insert(Znashenie,s,1+CName+1+CArtikul+1+COne+1+CKol+1+CLitr+1+CZena+1+CZena+1+CInputIZena+1+
         CZena+1+CZena+1+CLitr+1+COne+1+CLitr+1+COne+1);
     End;
*)
   Else;
   End;{Case}

   Prodaga^.List^.AtFree(Count);
   Prodaga^.SetRange(Prodaga^.List^.Count);

   Prodaga^.List^.Insert(NewStr(S));
   Prodaga^.SetRange(Prodaga^.List^.Count);
 End;
End;


Function InputBN(Var l:PSuperMarketType):Boolean;
Label 1;
var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  b : BezNal;
  c : WOrd;
  k : LongInt;

begin
If Status=DocEdit Then
 B:=PrevMArket^.Dat.Bn
 Else
 B:=L^.Dat.Bn;


1:
InputBN:=False;
R.Assign(12, 8, 67, 15);
New(Dlg, Init(R, 'Безналичный расчет'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.Palette := dpCyanDialog;
Dlg^.HelpCtx := $E002;

R.Assign(3, 2, 13, 3);
Control := New(PInputLine, Init(R, 8));
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PPXPictureValidator, Init('[##-##-9#]', True));

  R.Assign(2, 1, 8, 2);
  Dlg^.Insert(New(PLabel, Init(R, '~Д~ата:', Control)));

R.Assign(19, 2, 31, 3);
Control := New(PInputLine, Init(R, 10));
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0']));

  R.Assign(18, 1, 25, 2);
  Dlg^.Insert(New(PLabel, Init(R, 'N ~п~/п:', Control)));

R.Assign(35, 2, 52, 3);
Control := New(PInputLine, Init(R, 15));
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));

  R.Assign(34, 1, 50, 2);
  Dlg^.Insert(New(PLabel, Init(R, '~С~умма платежа:', Control)));

R.Assign(7, 4, 54, 5);
Control := New(PInputLine, Init(R, 45));
Dlg^.Insert(Control);

  R.Assign(1, 4, 7, 5);
  Dlg^.Insert(New(PLabel, Init(R, 'Б~а~нк:', Control)));

Dlg^.SelectNext(False);


Dlg^.SetData(B);
c:=Desktop^.ExecView(Dlg);
If c<>cmCancel Then
 Begin
  Dlg^.GetData(B);
  DelSpace(B.Date);
  DelSpace(B.NPlat);
  Str(StrToReal(B.Summa):CIZena:CMAntissa,B.Summa);
  DelSpace(B.Summa);
  DelSpaceRight(B.Bank);
  If b.Bank[0]=#0 Then
   Begin
    Dispose(Control,Done);
    Dispose(Dlg,Done);
    MessageBox(#3^M+#3'Не указан банк !',Nil,mfError+mfCancelButton);
    Goto 1;
   End;
  If Not(TestDate(B.Date,k)) Then
   Begin
    Dispose(Control,Done);
    Dispose(Dlg,Done);
    MessageBox(#3^M+#3'Не существующая дата !',Nil,mfError+mfCancelButton);
    Goto 1;
   End;
  If b.Date[0]=#0 Then
   Begin
    Dispose(Control,Done);
    Dispose(Dlg,Done);
    MessageBox(#3^M+#3'Не указана дата п/п !',Nil,mfError+mfCancelButton);
    Goto 1;
   End;
  If b.Date[0]=#0 Then
   Begin
    Dispose(Control,Done);
    Dispose(Dlg,Done);
    MessageBox(#3^M+#3'Не указан номер п/п !',Nil,mfError+mfCancelButton);
    Goto 1;
   End;
  If StrToReal(b.Summa)=0 Then
   Begin
    Dispose(Control,Done);
    Dispose(Dlg,Done);
    MessageBox(#3^M+#3'Нулевая сумма б/н платежа !',Nil,mfError+mfCancelButton);
    Goto 1;
   End;
  InputBn:=True;
  L^.Dat.Bn:=B;
 End;
Dispose(Control,Done);
Dispose(Dlg,Done);
end;



Procedure SortNKL (Var L:PSuperMarketType);
Var i : Word;
    R : TRect;
    E : PSuperMarketType;
    Wl,Wk,Wn : AllStr;
    S : TMyString;
    TempBox : PBox;
Begin
 R.Assign(0, 0, 0, 0);
 TempBox := New(PBox, Init(R, 1, Nil));
 TempBox^.NewList(New(PTextCollection, Init(0,1)));
 For i :=1 To L^.Dat.Amount Do
  Begin
   With L^.Dat.MarketElement[i].Input Do
   Begin
   Format(Kol,CKol);
   Format(Zena,CZena);
   Format(Skidka,CZena);
   Format(Itogo,CInputIZena);
   Format(R_Zena,CZena);
   Format(O_Zena,CZena);
   Format(Proz,CLitr);
   Format(SpecNalog,CLitr);
   Format(NDS,CLitr);
   Format(Zakupka,CZena);
   Wk := Copy(L^.Dat.MarketElement[i].BazKod,1,CRazdelKod);
   Wn := GetIdField(FName,L^.Dat.MarketElement[i].BazKod);
   Wl := GetIdField(FLitr,L^.Dat.MarketElement[i].BazKod);
   Format (wn,CName);
   Str(L^.Dat.MarketElement[i].Input.DivisionNumber:1,s);
   s:=s+'│'+wk+'│'+Wn+'│'+L^.Dat.MarketElement[i].BazKod+'│'+
   +L^.Dat.MarketElement[i].Input.Kol+'│'+Wl+'│'+L^.Dat.MarketElement[i].Input.Zena+'│'+
   +L^.Dat.MarketElement[i].Input.Skidka+'│'+L^.Dat.MarketElement[i].Input.R_Zena+'│'+
   +L^.Dat.MarketElement[i].Input.O_Zena+'│'+L^.Dat.MarketElement[i].input.Itogo+'│'+L^.Dat.MarketElement[i].Input.Proz+
   '│'+L^.Dat.MarketElement[i].Input.SpecNalog+'│'+IntToStr(VidNalog,COne)+
   '│'+L^.Dat.MarketElement[i].Input.Nds+'│'+IntToStr(VidNDS,COne)+
   '│'+L^.Dat.MarketElement[i].Input.Zakupka;
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
  E^.Dat.MarketElement[i+1].BazKod:=Copy(s,1+COne+1+CRazdelKod+1+CName+1,CArtikul);
  With E^.Dat.MarketElement[i+1].Input Do
   Begin
   {
    NDS:=BakGetField(FNds,E^.Dat.MarketElement[i+1].BazKod,0);
    DelSpace(Nds);
   }
    Kol:=Copy(s,1+COne+1+CName+1+CArtikul+1+CRazdelKod+1,CKol);
    DelSpace(Kol);
    Zena:=Copy(s,1+COne+1+CName+1+CArtikul+1+CLitr+1+CKol+1+CRazdelKod+1,CZena);
    DelSpace(Zena);
    Skidka:=Copy(s,1+COne+1+CName+1+CArtikul+1+CLitr+1+CKol+1+CZena+1+CRazdelKod+1,CZena);
    DelSpace(Skidka);
    Itogo:=Copy(s,1+COne+1+CName+1+CArtikul+1+CLitr+1+CKol+1+CZena+1+CZena+1+CZena+1+CZena+1+CRazdelKod+1,CInputIZena);
    DelSpace(Itogo);
    R_Zena:=Copy(s,1+CName+1+CArtikul+1+CLitr+1+CKol+1+CZena+1+CZena+1+COne+1+CRazdelKod+1,CZena);
    DelSpace(R_Zena);
    O_Zena:=Copy(s,1+CName+1+CArtikul+1+CLitr+1+CKol+1+CZena+1+CZena+1+COne+1+CZena+1+CRazdelKod+1,CZena);
    DelSpace(O_Zena);

    DiviSionNumber:=StrToInt(Copy(s,1,COne));
    Proz:=Copy(s,1+CName+1+CArtikul+1+CLitr+1+CKol+1+CZena+1+CZena+1+CZena+1+CZena+1+CInputIZena+1+COne+1+CRazdelKod+
    1{CZena+1},CLitr);
    DelSpace(Proz);

    SpecNalog:=Copy(s,1+CName+1+CArtikul+1+CLitr+1+CKol+1+CZena+1+CZena+1+CZena+1+CZena+1+CInputIZena+1+COne+1+CRazdelKod+
    1+CLitr+1,CLitr);
    DelSpace(SpecNalog);

    VidNalog:=StrToInt(Copy(s,1+CName+1+CArtikul+1+CLitr+1+CKol+1+CZena+1+CZena+1+CZena+1+CZena+1+CInputIZena+1+COne+
    1+CRazdelKod+1+CLitr+1+CLitr+1,COne));

    NDS:=Copy(s,1+CName+1+CArtikul+1+CLitr+1+CKol+1+CZena+1+CZena+1+CZena+1+CZena+1+CInputIZena+1+COne+
    1+CRazdelKod+1+CLitr+1+CLitr+1+COne+1,CLitr);
    DelSpace(NDS);

    VidNDS:=StrToInt(Copy(s,1+CName+1+CArtikul+1+CLitr+1+CKol+1+CZena+1+CZena+1+CZena+1+CZena+1+CInputIZena+1+COne+
    1+CRazdelKod+1+CLitr+1+CLitr+1+COne+1+CLitr+1,COne));

    Zakupka:=Copy(s,1+CName+1+CArtikul+1+CLitr+1+CKol+1+CZena+1+CZena+1+CZena+1+CZena+1+CInputIZena+1+COne+
    1+CRazdelKod+1+CLitr+1+CLitr+1+COne+1+CLitr+1+COne+1,CZena);
    DelSpace(Zakupka);

   End;
 End;
 L^.Dat:=E^.Dat;
 Dispose(TempBox,Done);
 Dispose(E,Done);

End;


Procedure TNetTestWindow.Refresh;
Var r :TRect;
    Ansver,Res : string[150];
    i : Word;
    Otd,A : ArtikulStr;

Begin
If NetTestBox^.List^.Count>0 Then
Begin
PrevNet:=NetTestBox^.GetText(NetTestBox^.Focused,NetTestBox^.List^.Count);
Res:=Copy(PrevNet,1+CNAme+1+CArtikul+1+COne+1+CKol+1+CZena+1+CLitr+1+CLitr+1+CZena+1+CLitr+1+CZena+1,
     Ord(PrevNet[0])-1+CNAme+1+CArtikul+1+COne+1+CKol+1+CZena+1+CLitr+1+CLitr+1+CZena+1+CLitr+1+CZena+1);
a:=Copy(NetTestBox^.GetText(NetTestBox^.Focused,NetTestBox^.List^.Count),1+CNAme+1,CArtikul);
Otd:=Copy(NetTestBox^.GetText(NetTestBox^.Focused,NetTestBox^.List^.Count),1+CNAme+1+CArtikul+1,COne);

{0-все ок
 1-наименование запретили к продаже
 2-отсутствует необходимое количество
 3-изменена цена
 4-изменена ставка ндс
 5-вид НДС
 6-изменена ставка нп
 7-вид НП
 8-изменена ставка скидки (авто)
 9-изменена закупка }

Ansver[0]:=#0;

For i:=1 To Ord(Res[0]) Do
 Begin
  Case StrToInt(Res[i]) Of
  1:If Ord(Ansver[0])<55 then Ansver:=Ansver+'запрет к продаже; '
    else Ansver:=Ansver+^M+'запрет к продаже; ';
  2:If Ord(Ansver[0])<55 then Ansver:=Ansver+'нет необх.колич.; '
    else Ansver:=Ansver+'нет необх.колич.; ';
  3:If Ord(Ansver[0])<55 then Ansver:=Ansver+'измен.цена; '
    else Ansver:=Ansver+'измен.цена; ';
  4:If Ord(Ansver[0])<55 then Ansver:=Ansver+'измен.НДС; '
    else Ansver:=Ansver+'измен.НДС; ';
  5:If Ord(Ansver[0])<55 then Ansver:=Ansver+'измен.вид НДС; '
    else Ansver:=Ansver+'измен.вид НДС; ';
  6:If Ord(Ansver[0])<55 then Ansver:=Ansver+'измен.НП; '
    else Ansver:=Ansver+'измен.НП; ';
  7:If Ord(Ansver[0])<55 then Ansver:=Ansver+'измен.вид НП; '
    else Ansver:=Ansver+'измен.вид НП; ';
  8:If Ord(Ansver[0])<55 then Ansver:=Ansver+'измен.скид.; '
    else Ansver:=Ansver+'измен.скид.; ';
  9:If Ord(Ansver[0])<55 then Ansver:=Ansver+'измен.закуп.; '
    else Ansver:=Ansver+'измен.закуп.; ';
  Else ansver:='???; ';
  End;
 End;

Dispose(ControlError,Done);
R.Assign(21, 16, 78, 18);
ControlError := New(PColoredText, Init(R,#3+Ansver, $5f));
NetTestWindow^.Insert(ControlError);


AnsVer:=BakGetField(FDiv,a,StrToInt(Otd));
DelSpace(ansver);
Dispose(ControlNetKol,Done);
R.Assign(28, 15, 33, 16);
Controlnetkol := New(PColoredText, Init(R, #3+Ansver, $7E));
nettestwindow^.Insert(Controlnetkol);


AnsVer:=BakGetField(FRZena,a,0);
DelSpace(ansver);

Dispose(ControlNetZena,Done);
R.Assign(42, 15, 50, 16);
Controlnetzena := New(PColoredText, Init(R, #3+Ansver, $7E));
nettestwindow^.Insert(Controlnetzena);

AnsVer:=GetIDField(FNDS,a);
DelSpace(ansver);

Dispose(ControlNetNDS,Done);
R.Assign(58, 15, 63, 16);
Controlnetnds := New(PColoredText, Init(R, #3+Ansver, $7E));
nettestwindow^.Insert(Controlnetnds);

AnsVer:=GetIDField(FNalog,a);
DelSpace(ansver);
Dispose(ControlNetNAlog,Done);
R.Assign(70, 15, 75, 16);
Controlnetnalog := New(PColoredText, Init(R, #3+Ansver, $7E));
nettestwindow^.Insert(Controlnetnalog);
Redraw;
End;

End;


Function TNetTestWindow.Start(L:PSuperMarketType;Itog:Real;LockBox:PBox):Boolean;
Label 1;
Var R:TRect;
    Control : PView;
    ssk,ErrorStr:AllStr;
    s,Msg:string[150];
    i : Word;
    FindError:Boolean;
    Temp : PBox;
    sklad,res:longint;

Begin
Start:=True;

R.Assign(0, 0, 0, 0);
Temp := New(PBox, Init(R, 1, Nil));
Temp^.NewList(New(PTextCollection, Init(0,1)));

{0-все ок
 1-наименование запретили к продаже
 2-отсутствует необходимое количество
 3-изменена цена
 4-изменена ставка ндс
 5-вид НДС
 6-изменена ставка нп
 7-вид НП
 8-изменена ставка скидки (авто)
 9-закупка}


FindError:=False;

 If L^.Dat.Amount>0 Then
  Begin
   For i:=1 To L^.Dat.Amount Do
    Begin
     ErrorStr[0]:=#0;
     {наименование запретили к продаже}
     If Not((L^.Dat.OperatorSelector=1)And(L^.Dat.DocSelector=0)) Then
     {если не межскладская первозка}
     If (GetIdMArket(L^.Dat.MarketElement[i].BazKod)=0) Then ErrorStr:=ErrorStr+'1';

     {в отделении отсутствует необходимое количество}
     res:=0;
     If Status=DocEdit Then
     res:=GetKolMarket(L^.Dat.MarketElement[i].BazKod,L^.Dat.MarketElement[i].Input.DiviSionNumber,PrevMarket);
     Res:=StrToInt(L^.Dat.MarketElement[i].Input.Kol)-res;
     sklad:=StrToInt(BakGetField(FDiv,L^.Dat.MarketElement[i].BazKod,L^.Dat.MarketElement[i].Input.DiviSionNumber));
     If (Sklad-res)<0 Then
     Begin
      ErrorStr:=ErrorStr+'2';
      Msg:=IntToStr(Sklad,CKol);
      DelSpace(Msg);
      NetChangeProdaga(L^.Dat.MarketElement[i].BazKod,IntToStr(L^.Dat.MarketElement[i].Input.DiviSionNumber,COne),2,Msg);
     End;

     {изменена цена оптовая или розничная}
     If((StrToReal(BakGetField(FRZena,L^.Dat.MarketElement[i].BazKod,0)))<>
           (StrToReal(L^.Dat.MarketElement[i].Input.R_Zena))) Or
       ((StrToReal(BakGetField(FOZena,L^.Dat.MarketElement[i].BazKod,0)))<>
           (StrToReal(L^.Dat.MarketElement[i].Input.O_Zena))) Then
        Begin
         ErrorStr:=ErrorStr+'3';
         Msg:=BakGetField(FRZena,L^.Dat.MarketElement[i].BazKod,0);
         DelSpace(Msg);
         NetChangeProdaga(L^.Dat.MarketElement[i].BazKod,IntToStr(L^.Dat.MarketElement[i].Input.DiviSionNumber,COne),3,Msg);
         Msg:=BakGetField(FOZena,L^.Dat.MarketElement[i].BazKod,0);
         DelSpace(Msg);
         NetChangeProdaga(L^.Dat.MarketElement[i].BazKod,IntToStr(L^.Dat.MarketElement[i].Input.DiviSionNumber,COne),3,Msg);
        End;

     {изменена ставка ндс}
    If Status<>DocEdit Then
     If (StrToReal(GetIDField(FNDS,L^.Dat.MarketElement[i].BazKod)))<>
        (StrToReal(L^.Dat.MarketElement[i].Input.NDS)) Then
        Begin
{        ErrorStr:=ErrorStr+'4';}
         Msg:=GetIDField(FNDS,L^.Dat.MarketElement[i].BazKod);
         DelSpace(Msg);
         NetChangeProdaga(L^.Dat.MarketElement[i].BazKod,IntToStr(L^.Dat.MarketElement[i].Input.DiviSionNumber,COne),4,Msg);
        End;

     {изменен вид ндс}
    If Status<>DocEdit Then
     If (StrToInt(GetIDField(FVidNDS,L^.Dat.MarketElement[i].BazKod)))<>
           (L^.Dat.MarketElement[i].Input.VidNDS) Then
        Begin
{        ErrorStr:=ErrorStr+'5';}
         Msg:=GetIDField(FVidNDS,L^.Dat.MarketElement[i].BazKod);
         DelSpace(Msg);
         NetChangeProdaga(L^.Dat.MarketElement[i].BazKod,IntToStr(L^.Dat.MarketElement[i].Input.DiviSionNumber,COne),5,Msg);
        End;
(*
     {изменена ставка нп}
    If Status<>DocEdit Then
     If (StrToReal(GetIDField(FNalog,L^.Dat.MarketElement[i].BazKod)))<>
        (StrToReal(L^.Dat.MarketElement[i].Input.SpecNalog)) Then
        Begin
        {ErrorStr:=ErrorStr+'6';}
         Msg:=GetIDField(FNalog,L^.Dat.MarketElement[i].BazKod);
         DelSpace(Msg);
         NetChangeProdaga(L^.Dat.MarketElement[i].BazKod,IntToStr(L^.Dat.MarketElement[i].Input.DiviSionNumber,COne),6,Msg);
        End;

     {изменен вид нп}
    If Status<>DocEdit Then
     If (StrToInt(GetIDField(FVidNalog,L^.Dat.MarketElement[i].BazKod)))<>
        (L^.Dat.MarketElement[i].Input.VidNAlog) Then
        Begin
         {ErrorStr:=ErrorStr+'7';}
         Msg:=GetIDField(FVidNalog,L^.Dat.MarketElement[i].BazKod);
         DelSpace(Msg);
         NetChangeProdaga(L^.Dat.MarketElement[i].BazKod,IntToStr(L^.Dat.MarketElement[i].Input.DiviSionNumber,COne),7,Msg);
        End;
*)
     {изменена таблица авто-скидок}
     If Skidka=0 Then
     Str((GetSkidkaProz(L^.Dat.MarketElement[i].BazKod,Itog)):CLitr:CMantissa,Msg);
     If Skidka=2 Then
     Str((GetShkalaProz(L^.Dat.MarketElement[i].BazKod,ClientShkala)):CLitr:CMantissa,Msg);
     DelSpace(msg);
     If Skidka in[0,2] Then
     If (Msg<>L^.Dat.MarketElement[i].Input.proz) Then ErrorStr:=ErrorStr+'8';

     {изменена закупочная цена}
     If (StrToReal(BakGetField(FZakupka,L^.Dat.MarketElement[i].BazKod,0)))<>
        (StrToReal(L^.Dat.MarketElement[i].Input.Zakupka)) Then
        Begin
        {ErrorStr:=ErrorStr+'9';}
         Msg:=BakGetField(FZakupka,L^.Dat.MarketElement[i].BazKod,0);
         DelSpace(Msg);
         NetChangeProdaga(L^.Dat.MarketElement[i].BazKod,IntToStr(L^.Dat.MarketElement[i].Input.DiviSionNumber,COne),9,Msg);
        End;



     If ErrorStr[0]<>#0 Then
      Begin
{наименование код n колич цена ндс нп скидка руч скидка авто errorstr}
       s:=GetIdField(FName,L^.Dat.MarketElement[i].BazKod);
       DelSpaceRight(s);
       Format(s,CName);
       DelSpace(L^.Dat.MarketElement[i].Input.Kol);
       Format(L^.Dat.MarketElement[i].Input.Kol,CKol);
       DelSpace(L^.Dat.MarketElement[i].Input.Zena);
       Format(L^.Dat.MarketElement[i].Input.Zena,CZena);
       DelSpace(L^.Dat.MarketElement[i].Input.NDS);
       Format(L^.Dat.MarketElement[i].Input.NDS,CLitr);
       DelSpace(L^.Dat.MarketElement[i].Input.SpecNalog);
       Format(L^.Dat.MarketElement[i].Input.SpecNAlog,CLitr);
       DelSpace(L^.Dat.MarketElement[i].Input.Skidka);
       Format(L^.Dat.MarketElement[i].Input.Skidka,CZena);
       DelSpace(L^.Dat.MarketElement[i].Input.Proz);
       Format(L^.Dat.MarketElement[i].Input.Proz,CLitr);
       DelSpace(L^.Dat.MarketElement[i].Input.Zakupka);
       Format(L^.Dat.MarketElement[i].Input.Zakupka,CZena);
       s:=s+'│'+L^.Dat.MarketElement[i].BazKod+'│'+IntToSTr(L^.Dat.MarketElement[i].Input.DivisionNumber,COne)+'│'
          +L^.Dat.MarketElement[i].Input.Kol+'│'+L^.Dat.MarketElement[i].Input.Zena+'│'+L^.Dat.MarketElement[i].Input.NDS+'│'+
       +L^.Dat.MarketElement[i].Input.SpecNAlog+'│'+L^.Dat.MarketElement[i].Input.Skidka+'│'+
       +L^.Dat.MarketElement[i].Input.Proz+'│'+L^.Dat.MarketElement[i].Input.Zakupka+'│'+ErrorStr;
       Temp^.List^.Insert(NewStr(s));
       Temp^.SetRange(Temp^.List^.Count);
       DelSpace(L^.Dat.MarketElement[i].Input.Kol);
       DelSpace(L^.Dat.MarketElement[i].Input.Zakupka);
       DelSpace(L^.Dat.MarketElement[i].Input.Zena);
       DelSpace(L^.Dat.MarketElement[i].Input.NDS);
       DelSpace(L^.Dat.MarketElement[i].Input.SpecNalog);
       DelSpace(L^.Dat.MarketElement[i].Input.Skidka);
       DelSpace(L^.Dat.MarketElement[i].Input.Proz);
       findError:=true;
       start:=false;
      End;
   End;
 end;{if}

If Not(FindError) Then
Begin
 Dispose(Temp,Done);
 Exit;
End;

UnLockAllPosition(LockBox);

NetBeep;
R.Assign(0, 3, 79, 22);
New(NetTestWindow, Init(R, 'Сетевое предупреждение'));
NetTestWindow^.Options := NetTestWindow^.Options or ofCenterX or ofCenterY;
NetTestWindow^.HelpCtx:=$E090;

R.Assign(78, 2, 79, 15);
Control := New(PScrollBar, Init(R));
NetTestWindow^.Insert(Control);

R.Assign(1, 2, 78, 15);
NetTestBox := New(PBox, Init(R, 1, PScrollbar(Control)));
NetTestBox^.NewList(New(PTextCollection, Init(0,1)));

If (Temp^.List^.Count)>0 Then
  For i:=0 To Temp^.List^.Count-1 Do
   Begin
    s:=Temp^.GetText(i,Temp^.List^.Count);
    NetTestBox^.List^.Insert(NewStr(s));
    NetTestBox^.SetRange(NetTestBox^.List^.Count);
   End;
Dispose(Temp,Done);

NetTestWindow^.Insert(NetTestBox);

R.Assign(1, 1, 77, 2);
NetTestWindow^.Insert(New(PLabel,
Init(R, 'Наименование товара         Код  N Колич.Цена лоб. НДС   НП    Скидка  Проц',
NetTestBox)));

R.Assign(1, 16, 21, 17);
Control := New(PColoredText, Init(R, 'Произошли изменения:', $7E));
NetTestWindow^.Insert(Control);

R.Assign(21, 16, 78, 18);
ControlError := New(PColoredText, Init(R,#3+'', $5f));
NetTestWindow^.Insert(ControlError);

R.Assign(21, 15, 28, 16);
Control := New(PColoredText, Init(R, 'Колич.:', $74));
nettestwindow^.Insert(Control);

R.Assign(28, 15, 33, 16);
Controlnetkol := New(PColoredText, Init(R, #3+'', $7E));
nettestwindow^.Insert(Controlnetkol);

R.Assign(37, 15, 42, 16);
Control := New(PColoredText, Init(R, 'Цена:', $74));
nettestwindow^.Insert(Control);

R.Assign(42, 15, 50, 16);
Controlnetzena := New(PColoredText, Init(R, #3+'', $7E));
nettestwindow^.Insert(Controlnetzena);

R.Assign(54, 15, 58, 16);
Control := New(PColoredText, Init(R, 'НДС:', $74));
nettestwindow^.Insert(Control);

R.Assign(58, 15, 63, 16);
Controlnetnds := New(PColoredText, Init(R, #3+'', $7E));
nettestwindow^.Insert(Controlnetnds);

R.Assign(67, 15, 70, 16);
Control := New(PColoredText, Init(R, 'НП:', $74));
nettestwindow^.Insert(Control);

R.Assign(70, 15, 75, 16);
Controlnetnalog := New(PColoredText, Init(R, #3+'', $7E));
nettestwindow^.Insert(Controlnetnalog);

R.Assign(4, 15, 16, 16);
Control := New(PColoredText, Init(R, 'На складе: ', $71));
nettestwindow^.Insert(Control);

NetTestWindow^.SelectNext(False);
PrevNet[0]:=#0;
DeskTop^.EXecView(NetTestWindow);
Dispose(Control,Done);
Dispose(NetTestWindow,Done);

1:

  If Prodaga^.List^.Count>0 Then
   Begin
    For i:=0 to prodaga^.list^.Count-1 Do
     Begin
     {колич}
      SSk:=Copy(Prodaga^.GetText(i,Prodaga^.List^.Count),1+COne+1+CName+1+CArtikul+1,CKol);
      DelSpace(sSk);

      If StrToInt(ssk)=0 Then
      Begin
       Prodaga^.List^.AtFree(i);
       Prodaga^.SetRange(Prodaga^.List^.Count);
       If Prodaga^.Focused>0 Then Prodaga^.FocusItem(Prodaga^.Focused);
       If (Prodaga^.Focused>=Prodaga^.List^.Count) and(Prodaga^.Focused>0) Then
       Prodaga^.FocusItem(Prodaga^.Focused-1);
       Goto 1;
      End;
     End;
   End;

End;


Procedure TNetTestWindow.HandleEvent(Var Event:TEvent);
Var s: string[150];
Begin
inherited handleEvent(Event);
 if (NetTestBox^.State and sfFocused <> 0)  And(NetTestBox^.List<>Nil) And (NetTestBox^.List^.Count>=1)Then
  Begin
   s:=NetTestBox^.GetText(NetTestBox^.Focused,NetTestBox^.List^.Count);
   If s <> PrevNet Then
    Begin
     Refresh;
    End
  End;
End;


Destructor TNetTestWindow.Done;
Begin
ClearFind;
Dispose(ControlError,Done);
Dispose(ControlNetKol,Done);
Dispose(ControlNetZena,Done);
Dispose(ControlNetNDS,Done);
Dispose(ControlNetNalog,Done);
TDialog.Done;
End;




Procedure TSuperMarketWindow.SaveToFile(Var Save : Boolean);
Label 1;
Var L : PSuperMarketType;
    R:TRect;
    i : LongInt;
    pItog,itog : Real;
    sf : Boolean;
    s : string[150];
    ws : AllStr;
    PereozenkaElement :PPereozenkaType;
    PereozenkaFile : File Of PereozenkaType;
    As : DocumentEdit;
    TempBox,LockBox:PBox;

Begin
Save:=False;
sf := False;
New(L,Init);{:=TestPr;}
Itog := CalcItogo(ItogNAlog);
{чтение с экрана прихода}
If (Prodaga^.List^.Count)>0 Then
For i:=0 To Prodaga^.List^.Count-1 Do
 Begin
  s:=Prodaga^.GetText(i,Prodaga^.List^.Count);
{  L^.Dat.MarketElement[i+1].BazKod:=Copy(s,1+CName+1,CArtikul);}
{для новой структуры стороки}
  L^.Dat.MarketElement[i+1].BazKod:=Copy(s,1,CArtikul);
  With L^.Dat.MarketElement[i+1].Input Do
   Begin
    SpecNalog:=Copy(s,1+CName+1+CArtikul+1+CLitr+1+CKol+1+CZena+1+CZena+1+CInputIZena+1+COne+1+CZena+1+
                    CZena+1,clitr);
    VidNalog:=StrToInt(Copy(s,1+CName+1+CArtikul+1+CLitr+1+CKol+1+CZena+1+CZena+1+CInputIZena+1+COne+1+CZena+1+
                    CZena+1+clitr+1,COne));
    DelSpace(SpecNalog);

    NDS:=Copy(s,1+CName+1+CArtikul+1+CLitr+1+CKol+1+CZena+1+CZena+1+CInputIZena+1+COne+1+CZena+1+
                    CZena+1+clitr+1+COne+1,Clitr);

    VidNDS:=StrToInt(Copy(s,1+CName+1+CArtikul+1+CLitr+1+CKol+1+CZena+1+CZena+1+CInputIZena+1+COne+1+CZena+1+
                    CZena+1+clitr+1+COne+1+Clitr+1,COne));
    DelSpace(Nds);

    Zakupka:=Copy(s,1+CName+1+CArtikul+1+CLitr+1+CKol+1+CZena+1+CZena+1+CInputIZena+1+COne+1+CZena+1+
                    CZena+1+clitr+1+COne+1+Clitr+1+COne+1,CZena);
    DelSpace(Zakupka);



    Kol:=Copy(s,1+COne+1+CName+1+CArtikul+1,CKol);
    DelSpace(Kol);
    Zena:=Copy(s,1+COne+1+CName+1+CArtikul+1+CLitr+1+CKol+1,CZena);
    DelSpace(Zena);
    Skidka:=Copy(s,1+COne+1+CName+1+CArtikul+1+CLitr+1+CKol+1+CZena+1,CZena);
    DelSpace(Skidka);
    If (Abs(StrToReal(Skidka))>0.01) And (OperatorSelector=1) Then
     Begin
      MessageBox(#3'Для внутреннего документа скидки не допустимы!'^M+
                 #3'Обнулите скидку в позиции с кодом '+L^.Dat.MarketElement[i+1].BazKod,Nil,mfError+mfCancelButton);
      Dispose(L,Done);
      Exit;
        End;
    Itogo:=Copy(s,1+COne+1+CName+1+CArtikul+1+CLitr+1+CKol+1+CZena+1+CZena+1,CInputIZena);
    DelSpace(Itogo);
    R_Zena:=Copy(s,1+CName+1+CArtikul+1+CLitr+1+CKol+1+CZena+1+CZena+1+CInputIZena+1+COne+1,CZena);
    DelSpace(R_Zena);
    O_Zena:=Copy(s,1+CName+1+CArtikul+1+CLitr+1+CKol+1+CZena+1+CZena+1+CInputIZena+1+COne+1+CZena+1,CZena);
    DelSpace(O_Zena);
    DiviSionNumber:=StrToInt(Copy(s,1+CName+1+CArtikul+1,COne));

    If Market.Skidka in [0,1] Then {запоминаем авто скидку если не использовались шкалы}
    Str((GetSkidkaProz(L^.Dat.MarketElement[i+1].BazKod,Itog)):CLitr:CMantissa,Proz)
    Else
    Str((GetShkalaProz(L^.Dat.MarketElement[i+1].BazKod,ClientShkala)):CLitr:CMantissa,Proz);

    DelSpace(Proz);
   End;
 End;
 ControlOperatorSelect^.GetData(L^.Dat.OperatorSelector);
 ControlSelect^.GetData(L^.Dat.DocSelector);
 ControlSkidka^.GetData(L^.Dat.SkidkaSelector);
 L^.Dat.ShkalaNumer:=ClientShkala;

 PStaticText(ControlClient)^.GetText(S);
 System.Delete(S,Pos(#3,S),1);

 L^.Dat.ClientKod:=Copy(s,1+CClient+1,CClientKod);

 PStaticText(ControlItogoSkidka)^.GetText(S);
 System.Delete(S,Pos(#3,S),1);
 Str(StrToreal(S):CIZena:CMantissa,S);
 DelSpace(S);
 L^.Dat.Skidka:=S;

 L^.Dat.ENalog  :=ItogNalog.ENalog;
 DelSpace(L^.Dat.ENalog);
 L^.Dat.Nalog5  :=ItogNalog.Nalog5;
 DelSpace(L^.Dat.Nalog5);
 L^.Dat.Nalog3  :=ItogNalog.Nalog3;
 DelSpace(L^.Dat.Nalog3);
 L^.Dat.Nalog_  :=ItogNalog.Nalog_;
 DelSpace(L^.Dat.Nalog_);
 L^.Dat.SummaZakupka :=ItogNalog.Zakupka;
 DelSpace(L^.Dat.SummaZakupka);



 If Status = DocNormal Then
 Begin
 L^.Dat.DateC:=FDate;
 L^.Dat.TimeC:=Times;
 End
 Else
  Begin
 L^.Dat.DateC:=PrevMarket^.Dat.DateC;
 L^.Dat.TimeC:=PrevMarket^.Dat.TimeC;
  End;
 L^.Dat.DateM:=FDate;
 L^.Dat.TimeM:=Times;



 If L^.DAt.DocSelector in [3,4,6,8] Then
  Begin
{  PStaticText(ControlClient)^.GetText(S);
   s:=Copy(s,1+1+CClient+1,CClientKod);}
   ws:=GetClientField(FEnvir,{s}L^.Dat.ClientKod,0);
   DelSpace(wS);
   If ws[0]=#0 Then

   If Not NewPassword(3)Then Goto 1;

   If (DefaultLizensia=1) Then
   If Not(TestSrokLizensia(L^.Dat.ClientKod,TekDate)) Then
      Begin
       If Not NewPassword(5)Then Goto 1;
      End;

  End;

 If L^.Dat.DocSelector in [5,6,7,8] Then
  Begin
   PStaticText(ControlClient)^.GetText(S);
   s:=Copy(s,1+1+CClient+1,CClientKod);
   if StrtoReal(GetClientField(FLimit,s,0))<(Itog+StrToReal(GetClientField(FDolg,s,0))) Then
    begin
     If Not NewPassword(0)Then Goto 1;
    End;
   if Not(TestDolgClient(s)) Then
    begin
     If Not NewPassword(1)Then Goto 1;
    End;
   ws:=GetClientField(FNDogovor,s,0);
   DelSpace(wS);
   If ws[0]=#0 Then
     If Not NewPassword(2)Then Goto 1;
  End;

 PStaticText(ControlDoc)^.GetText(s);
 DelSpace(S);
 System.Delete(S,Pos(#3,S),1);
 L^.Dat.Document:=s;
 PStaticText(Control_I)^.GetText(L^.Dat.SummaZ);
 DelSpace(L^.Dat.SummaZ);
 System.Delete(L^.Dat.SummaZ,Pos(#3,L^.Dat.SummaZ),1);

{L^.Dat.Sklad:=Rek.SkladsName;}
 L^.Dat.Caption:=CurrentPassword;
 L^.Dat.Amount:=Prodaga^.List^.Count;
 L^.Dat.Realiz:=False;
 If L^.Dat.DocSelector in [5,6,7,8] Then
  Begin
  If StrToInt(GEtClientField(FDebit,L^.Dat.ClientKod,0))<>1 Then
   Begin
    MessageBox(^M+#3+'Клиенту запрещено отпускать товар на консигнацию!',Nil,mfError+mfCancelButton);
    Save:=False;
    Goto 1;
   End;

If L^.Dat.DocSelector in [6,8] Then
Begin
{      L^.Dat.DocSelector:=5;}
       Sf:=True;
End
Else Sf:=False;

If (Itog>=0.01) Then
 Begin
  i:=ReturnDay(Itog,Sf);
  If (DefaultLizensia=1) And SF Then
  If Not(TestSrokLizensia(L^.Dat.ClientKod,TekDate)) Then
    Begin
     If Not NewPassword(5) Then Goto 1;
    End;
    If i=0 Then
        Begin
         Save:=False;
         Goto 1;
        End;
 End
     Else
      Begin
       i:=DateStringToDate(DAteMask,TekDate);
       If Not(SpisDolgFromZerroDocRealiz(L)) Then
        Begin
         Save:=False;
         Goto 1;
        End
      End;
    {l^.Dat.Sf:=Sf;}
    L^.Dat.Srok:=i;
    L^.Dat.Realiz:=True;
  End;

 If (L^.Dat.DocSelector = 4) Then
  Begin
  Save:=InputBN(L);
  If Not(Save) Then
   Begin
    Goto 1;
   End;
  End;

  SortNKL (L);

{прочитали с экрана продажу}

{$IFDEF NetVersion}

{формируем список позиций подлежащих блокировке}
R.Assign(0,0,0,0);
TempBox := New(PBox, Init(R, 1, Nil));
TempBox^.NewList(New(PTextCollection, Init(0,1)));

If L^.Dat.Amount>0 Then
 For i :=1 To L^.Dat.Amount Do
  Begin
   {если нет в списке}
   If TestElement(L^.Dat.marketElement[i].BazKod,TempBox) Then
    Begin
     TempBox^.List^.Insert(NewStr('│'+L^.Dat.marketElement[i].BazKod));
     TempBox^.SetRange(TempBox^.List^.Count);
    End;
  End;

if Status=DocEdit then
 Begin
If PrevMarket^.Dat.Amount>0 Then
 For i :=1 To PrevMarket^.Dat.Amount Do
  Begin
   {если нет в списке}
   If TestElement(PrevMarket^.Dat.marketElement[i].BazKod,TempBox) Then
    Begin
     TempBox^.List^.Insert(NewStr('│'+PrevMarket^.Dat.marketElement[i].BazKod));
     TempBox^.SetRange(TempBox^.List^.Count);
    End;
  End;{for}
 End;{status=docedit}

R.Assign(0,0,0,0);
LockBox := New(PBox, Init(R, 1, Nil));
LockBox^.NewList(New(PTextCollection, Init(0,1)));


If Not(LockAllPosition(TempBox,LockBox)) Then
 Begin
  UnLockAllPosition(LockBox);
  Dispose(LockBox,Done);
  Dispose(TempBox,Done);
  Save:=False;
  Goto 1;
 End;

if not(NetTest^.Start(l,Itog,lockbox)) then  {код для проверки корректности операции в сети}
 begin
  Dispose(LockBox,Done);
  Dispose(TempBox,Done);
  Save:=False;
  Goto 1;
 end;
{$ENDIF}



If Status=DocNormal Then
Begin
    New(PereozenkaElement,Init);
    Assign(PereozenkaFile,Path.ToCorrect+TekDate+'.prz');
    i:=IOResult;
    Reset(Pereozenkafile);
    i:=IOResult;
    If I <> 0 Then
    Begin
  If MessageBox('Файл переоценки '+TekDate+'.prz не найден!'^M+
        'Создаю файл? Если вы раньше что-либо переоценили позовите программиста!'+
           +' Код:'+IntToStr(i,3),nil,
           mfConfirmation + mfOkCancel)=cmOk  Then
        Begin
{         i:=Ioresult;
         Reset(PereozenkaFile);
         i:=Ioresult;
         If i<>0 Then Rewrite(PereozenkaFile);
         }
         If Not(CreatToDayF(DocPereozen,TekDate)) Then
            Begin
          Save:=False;
          Dispose(l,Done);
          Dispose(PereozenkaElement,Done);
             Exit;
         End;
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
  Dispose(PereozenkaElement,Done);

{If L^.Dat.DocSelector=5 Then
         Save:=AddDolgCount(L^.Dat.ClientKod,L^.Dat.OperatorSelector,Itog);
         If Not(Save) Then Goto 1;}


 {проверяем существование файла статистики и если нужно создаем}
 If L^.Dat.OperatorSelector=0 Then
  Begin
   Save:=CreatClientStatFile(L);
   If Not(Save) Then
    Begin
     {$IFDEF NetVersion}
      UnLockAllPosition(LockBox);
      Dispose(LockBox,Done);
      Dispose(TempBox,Done);
     {$ENDIF}
      Goto 1;
    End;
  End;

 If L^.Dat.DocSelector in [5..8] Then
  Begin
   Save:=CreatClientDolgFile(L);
   If Not(Save) Then
    Begin
     {$IFDEF NetVersion}
      UnLockAllPosition(LockBox);
      Dispose(LockBox,Done);
      Dispose(TempBox,Done);
     {$ENDIF}
      Goto 1;
    End;
  End;

 {записываем накладную, т.к. у нее может измениться номер}
 Save:=LockAndWriteMarket(L);
 If Not(Save) Then
    Begin
     {$IFDEF NetVersion}
      UnLockAllPosition(LockBox);
      Dispose(LockBox,Done);
      Dispose(TempBox,Done);
     {$ENDIF}
      Goto 1;
    End;


 {записываем статистику}
 If (L^.Dat.OperatorSelector=0) Then
         Begin
          Save:=SaveToStatFile(L,Sf);
          If Not(Save) Then
    Begin
     {$IFDEF NetVersion}
      UnLockAllPosition(LockBox);
      Dispose(LockBox,Done);
      Dispose(TempBox,Done);
     {$ENDIF}
      Goto 1;
    End;
         End;
 {конец запись статистики}


 If L^.Dat.DocSelector in [5..8] Then
        Begin
         Save:=SaveRealizasToClientFile(L,Sf);
         If Not(Save) Then
    Begin
     {$IFDEF NetVersion}
      UnLockAllPosition(LockBox);
      Dispose(LockBox,Done);
      Dispose(TempBox,Done);
     {$ENDIF}
      Goto 1;
    End;
        End;

 Save:=WriteMarketToSkladFile(L);

{$IFDEF NetVersion}
  UnLockAllPosition(LockBox);
  Dispose(LockBox,Done);
  Dispose(TempBox,Done);
{$ENDIF}




 If Save Then
  Repeat
  Until (UnLockMArket(L^.Dat.Document,L^.Dat.DateC) in [0,2]);

 If Save Then
                Begin
                 AddProtocol('Продажа товара по документу N '+L^.Dat.Document+' от '+L^.Dat.DateC);
                 As.D:=TekDate;
                 As.EditPosition:=L^.Dat.Document;
                 PrintNakl(As,NPrint.CopyNkl+1);
                End;
End
Else
 Begin

 L^.Dat.DocumentPrz:=PrevMarket^.Dat.DocumentPrz;

 {запись статистики}

 If L^.Dat.OperatorSelector=0 Then
  Begin
   Save:=CreatClientStatFile(L);
   If Not(Save) Then
    Begin
     {$IFDEF NetVersion}
      UnLockAllPosition(LockBox);
      Dispose(LockBox,Done);
      Dispose(TempBox,Done);
     {$ENDIF}
      Goto 1;
    End;
  End;

 If L^.Dat.DocSelector in [5..8] Then
  Begin
   Save:=CreatClientDolgFile(L);
   If Not(Save) Then
    Begin
     {$IFDEF NetVersion}
      UnLockAllPosition(LockBox);
      Dispose(LockBox,Done);
      Dispose(TempBox,Done);
     {$ENDIF}
      Goto 1;
    End;
  End;


 {удаляем предыдущую}
 If (PrevMarket^.Dat.OperatorSelector=0) Then
  Begin
   Save := DeleteOfStatFile(PrevMarket);
   If Not(Save) Then
    Begin
     {$IFDEF NetVersion}
      UnLockAllPosition(LockBox);
      Dispose(LockBox,Done);
      Dispose(TempBox,Done);
     {$ENDIF}
      Goto 1;
    End;
  End;

 {записываем новую}
 If (L^.Dat.OperatorSelector=0) Then
         Begin
         Save:=SaveToStatFile(L,Sf);
         If Not(Save) Then
    Begin
     {$IFDEF NetVersion}
      UnLockAllPosition(LockBox);
      Dispose(LockBox,Done);
      Dispose(TempBox,Done);
     {$ENDIF}
      Goto 1;
    End;
         End;


 {конец запись статистики}
 If (PrevMarket^.Dat.DocSelector in [5..8]) Then
  Begin
   Save := DeleteRealizasToClientFile;
   If Not(Save) Then
    Begin
     {$IFDEF NetVersion}
      UnLockAllPosition(LockBox);
      Dispose(LockBox,Done);
      Dispose(TempBox,Done);
     {$ENDIF}
      Goto 1;
    End;
  End;

 If (L^.Dat.DocSelector in [5..8]) Then
         Begin
         Save:=SaveRealizasToClientFile(L,Sf);
         If Not(Save) Then
    Begin
     {$IFDEF NetVersion}
      UnLockAllPosition(LockBox);
      Dispose(LockBox,Done);
      Dispose(TempBox,Done);
     {$ENDIF}
      Goto 1;
    End;
         End;


 Save:=LockAndWriteMarket(L);
 If Not(Save) Then
    Begin
     {$IFDEF NetVersion}
      UnLockAllPosition(LockBox);
      Dispose(LockBox,Done);
      Dispose(TempBox,Done);
     {$ENDIF}
      Goto 1;
    End;


 {корректировка актов переоценки}
 Save:=CorrectMarket(L,PrevMarket,0);

 If Save Then Save:=WriteMarketToSkladFile(L);

{$IFDEF NetVersion}
  UnLockAllPosition(LockBox);
  Dispose(LockBox,Done);
  Dispose(TempBox,Done);
{$ENDIF}


 If Save Then
  Repeat
  Until (UnLockMArket(L^.Dat.Document,L^.Dat.DateC) in [0,2]);

 If Save Then
                Begin
                 AddProtocol('Корректировка документа продажи N '+L^.Dat.Document+' от '+L^.Dat.DateC+'  {Очень важно}');
                 As.D:=TekDate;
                 As.EditPosition:=L^.Dat.Document;
                 PrintNakl(As,NPrint.CopyNkl+1);
                End;
 End;
1: Dispose(l,Done);

End;




Procedure DrawPack;
Var s: String[CPack];
    R : TRect;
Begin
    MarketWin^.GetData(El);
    If El.Kol<>PrevKol Then
    Begin
    PrevKol:=El.Kol;
    s:=CalcPack(sArtikul,El.Kol);
    DelSpace(s);
    Dispose(ControlPack,Done);
    R.Assign(54, 3, 63, 4);
{    PStaticText(ControlPack)^.Text^:=#3+S;}
    ControlPack:=New(PStaticText, Init(R, #3+s));
    MarketWin^.Insert(ControlPack);
{    MarketWin^.Redraw;}
    End;
End;



Procedure DrawKol(VAr Show:Boolean;Var Kol:ArtikulStr);
Var s: String[CKol];
    R : TRect;
    l : LongInt;
    TestKol :String[CKol];
Begin
 Show:=FAlse;
 MarketWin^.GetData(El);
 If El.PAck<>10 Then
Begin

If El.Pack<>PrevKolPack Then
 Begin
  s:=GetIdField(FINPack,SArtikul);
  Str(StrToInt(s)*(El.Pack+1):CKol,s);
  DelSpace(s);
  Kol :=S;

  TestKol:=BakGetField(FDiv,SArtikul,StrToInt(ActiveOtdel));

  If Status=DocNormal Then
  Begin
  If StrToInt(s)>StrToInt(TestKol) Then
  Begin
   Show:=True;
   DelSpace(TestKol);
   s:=TestKol;
   DelSpace(s);
  End;
  End;

  If Status=DocEdit Then
  Begin
  If StrToInt(s)>StrToInt(TestKol)+GetKolMarket(SArtikul,StrToInt(SOtd),PrevMarket) Then
  Begin
   Show:=True;
   s:=IntToStr(STrToInt(TestKol)+GetKolMarket(SArtikul,StrToInt(SOtd),PrevMarket),CKol);
   DelSpace(s);
  End;
  End;



  ControlKol^.SetData(s);
  PrevKolPack:=El.Pack;
 End;
End{если не нажата буква ~А~}
 Else
  Begin
   If Status=DocNormal Then
   TestKol:=BakGetField(FDiv,SArtikul,StrToInt(ActiveOtdel))
   Else
   TestKol:=IntToStr(StrToInt(BakGetField(FDiv,SArtikul,StrToInt(ActiveOtdel)))+
            GetKolMarket(SArtikul,StrToInt(SOtd),PrevMarket),CKol);
   DelSpace(TestKol);
   ControlKol^.SetData(TestKol);
   PrevKolPack:=El.Pack;
  End;
End;




Procedure TMarketWindow.Ini(s:TMyString;Regim:Word);
Label 1;
var
  R : TRect;
  c: Word;
  Control : PView;
  Ws,ws1 : TEnjoyStr;
  SSkidka,SName: String[CAll];
  SZakupka,SNDS,SNalog,SOZena,SRZena,SLitr,SKol,SInPack:String[CZena];
  Event : TEvent;
  VidNalog,VidNDS : Word;
Begin
ClearFind;
SName:=Copy(S,1,CName);
SOtd:=Copy(s,1+CName+1+CArtikul+1,COne);
ActiveOtdel:=SOtd;

{Для новой структуры строки}
If Regim=0 Then SArtikul:=Copy(S,1+CName+1,CArtikul)
Else SArtikul:=Copy(S,1,CArtikul);


If (Selector<>0) Or
  ((Selector=0)And(OperatorSelector=0)) Then
Begin
If GetIdMarket(Sartikul)=0 Then
  Begin
     Sound(100);
     DinfoMsg('Внимание! Товар с кодом '+SArtikul+' запрещено отгружать клиенту!');
     Delay(300);
     NoSound;
     ClearEvent(Event);
     repeat
       Application^.GetEvent(Event);
     until (Event.What <> evNothing) And (Event.Command<>cmMenu);
     NoInfoMsg;
     ClearEvent(Event);
     Exit;
  End;
End;


SLitr:=GetIdField(FLitr,SArtikul);
SInPack:=GetIdField(FINPack,SArtikul);
SKol:=Copy(s,1+CName+1+CArtikul+1+COne+1+CKol+1+CInPack+1,CKol);
SNalog:=GetIdField(FNalog,SArtikul);
SNDS:=GetIdField(FNDS,SArtikul);
VidNalog:=StrToInt(GetIdField(FVidNalog,SArtikul));
VidNDS:=StrToInt(GetIdField(FVidNDS,SArtikul));
DelSpace(SNalog);
DelSpace(SNDS);


Case Regim Of
0:Begin
  El.Pack:=0;
  PrevKolPack:=El.Pack;
  El.Kol:=GetIdField(FInPack,SArtikul);
  If Status = DocNormal Then
  If StrToInt(El.Kol)>StrToInt(BakGetField(FDiv,SArtikul,StrToInt(SOtd))) Then El.Kol:=BakGetField
  (FDiv,SArtikul,StrToInt(SOtd))
  Else
  If StrToInt(El.Kol)>StrToInt(BakGetField(FDiv,SArtikul,StrToInt(SOtd))) Then El.Kol:=SKol;
  DelSpace(El.kol);
  El.Skidka[0]:=#0;
  SRZena:=BakGetField(FRZena,SArtikul,0);
  Format(SRZena,CZena);
  SOZena:=BakGetField(FOZena,SArtikul,0);
  Format(SOZena,CZena);
  SZakupka:=BakGetField(FZakupka,SArtikul,0);
  Format(SZakupka,CZena);
  End;
1:Begin
{Для новой структуры строки}
    SArtikul:=Copy(S,1,CArtikul);
    SName:=Copy(S,1+CArtikul+1,CName);
    El.Kol:=Copy(s,1+CName+1+CArtikul+1+COne+1,CKol);
    El.SKidka:=Copy(s,1+CName+1+CArtikul+1+COne+1+CLitr+1+CKol+1+CZena+1,CZena);
    SOtd:=Copy(s,1+CName+1+CArtikul+1,COne);
    ActiveOtdel:=SOtd;
    sskidka:=CalcPack(SArtikul,El.Kol);
    System.Delete(sskidka,Pos('+',Sskidka),Ord(S[0]));
    If (StrToInt(sskidka)-1) >= 0 Then
    El.Pack:=StrToInt(sskidka)-1
    Else El.Pack:=StrToInt(sskidka);
    If El.PAck>9 Then El.Pack:=9;
    PrevKolPack:=El.Pack;
    SRZena:=Copy(s,1+CName+1+CArtikul+1+COne+1+CLitr+1+CKol+1+CZena+1+CZena+1+CInputIZena+1,CZena);
    SOZena:=Copy(s,1+CName+1+CArtikul+1+COne+1+CLitr+1+CKol+1+CZena+1+CZena+1+CInputIZena+1+CZena+1,CZena);
    SNalog:=Copy(s,1+CName+1+CArtikul+1+COne+1+CLitr+1+CKol+1+CZena+1+CZena+1+CInputIZena+1+CZena+1+CZena+1,CLitr);
    VidNalog:=StrToInt(Copy(s,1+CName+1+CArtikul+1+COne+1+CLitr+1+CKol+1+CZena+1+CZena+1+CInputIZena+1+CZena+1+CZena+1+CLitr+1,
              COne));
    SNDS  :=Copy(s,1+CName+1+CArtikul+1+COne+1+CLitr+1+CKol+1+CZena+1+CZena+1+CInputIZena+1+CZena+1+CZena+1+CLitr+1+COne+1,
    CLitr);

    VidNDS:=StrToInt(Copy(s,1+CName+1+CArtikul+1+COne+1+CLitr+1+CKol+1+CZena+1+CZena+1+CInputIZena+1+CZena+1+CZena+1+CLitr+1+
    COne+1+CLitr+1,COne));

    SZakupka:=Copy(s,1+CName+1+CArtikul+1+COne+1+CLitr+1+CKol+1+CZena+1+CZena+1+CInputIZena+1+CZena+1+CZena+1+CLitr+1+
              COne+1+CLitr+1+COne+1,CZena);


    DelSpace(SNAlog);
    DelSpace(SNDS);


    DelSpace(El.Kol);
    DelSpace(El.Skidka);
  End;
  Else;
  End;

ClearFind;

SZakupka:=RealToStr(StrToReal(SZakupka),CZena,CMantissa);
DelSpace(SZakupka);
Format(SZakupka,CZena);

1:
AInfo('Читаю информацию о товаре...');
R.Assign(2, 15, 78, 21);
New(MarketWin, Init(R, 'Продажа наименования товара - отделение ['+SOtd+']'));
MarketWin^.Options := MarketWin^.Options or ofCenterX;
MarketWin^.Palette := dpCyanDialog;
MarketWin^.HelpCtx := $E199;

{R.Assign(1, 3, 37, 5);}
R.Assign(1, 3, 44, 5);
Pack := New(PRadioButtons, Init(R,
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

{Мои изменения
If Status = DocEdit Then
Begin
Pack^.Options := Pack^.Options and not(ofSelectable or ofFirstClick);
Pack^.EventMask := Pack^.EventMask and not(evMouseDown or evKeyDown or evCommand);
End;
}

MarketWin^.Insert(Pack);

  R.Assign(1, 2, 25, 3);
  MarketWin^.Insert(New(PLabel, Init(R, 'Количество ~у~паковок:', Pack)));


R.Assign(45, 3, 54, 4);
Control := New(PColoredText, Init(R, 'Упаковок:', $3E));
MarketWin^.Insert(Control);


R.Assign(54, 3, 63, 4);
ControlPack := New(PStaticText, Init(R, #3+'0+0'));
MarketWin^.Insert(ControlPack);


R.Assign(50, 4, 57, 5);
ControlKol := New(PInputLine, Init(R, CKol));
{Мои изменения
If Status = DocEdit Then
Begin
ControlKol^.Options := ControlKol^.Options and not(ofSelectable or ofFirstClick);
ControlKol^.EventMask := ControlKol^.EventMask and not(evMouseDown or evKeyDown or evCommand);
End;
}
MarketWin^.Insert(ControlKol);
  PInputLine(ControlKol)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0']));

  R.Assign(42{38}, 4, 50, 5);
  MarketWin^.Insert(New(PLabel, Init(R, 'К~о~лич.:', ControlKol)));

R.Assign(2, 1, 74, 2);
Control := New(PStaticText, Init(R, 'Наименование:'+SName+' Код:'+SArtikul+' Литраж:'+Slitr+' Фас:'+SInPack));
MarketWin^.Insert(Control);

If Skidka=1 Then
Begin
EnableCommands([cmLocalSkidka,cmLocalNazenka]);
R.Assign(65, 4, 75, 5);
Control1Skidka := New(PInputLine, Init(R, CZena));
MarketWin^.Insert(Control1Skidka);
  PInputLine(Control1Skidka)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.','-']));

  R.Assign(57, 4, 65, 5);
  MarketWin^.Insert(New(PLabel, Init(R, '~С~кидка:', Control1Skidka)));
End
Else
DisableCommands([cmLocalSkidka,cmLocalNazenka]);

If Status=DocEdit Then
Begin
Str((StrToInt(BakGetField(FKol,SArtikul,0))+GetKolMarket(SArtikul,StrToInt(SOtd),PrevMarket)):CKol,ws1);
Str((StrToInt(BakGetField(FDiv,SArtikul,StrToInt(SOtd)))+GetKolMarket(SArtikul,StrToInt(SOtd),PrevMarket)):CKol,ws);

ws:='На складе:'+ws1+' В отделении:'+ws+' Цена:';
End
Else
ws:='На складе:'+BakGetField(FKol,SArtikul,0)+' В отделении:'+BakGetField(FDiv,Sartikul,StrToInt(SOtd))+' Цена:';

(*
Case Selector Of
0: ws:=ws+SRZena;{Список}
9:ws:=ws+SRZena;{?}
1:ws:=ws+SRZena;{ТЧ}
2,3,5,6:ws:=ws+SOZena;{ФЛ* СФ* Д* ДСФ* }
4,7,8:ws:=ws+SOZena;{СФБ Д ДСФБ}
Else;
End;
*)

If Selector in [0,1] Then ws:=ws+SRZena
Else ws:=ws+SOZena;


R.Assign(23, 2, 75, 3);
Control := New(PColoredText, Init(R,ws, $31));
MarketWin^.Insert(Control);

If Status=DocNormal Then ws1:=BakGetField(FKol,SArtikul,0);
DelSpace(Ws1);
ws1:=CalcPack(SArtikul,ws1);
DelSpace(Ws1);
R.Assign(1, 5, Length(' На складе имеется: '+ws1+' упаковок(ки)'+' Ставка НП:'+SNalog+' Ставка НДС:'+SNDS)+2, 6);
Control := New(PColoredText, Init(R,' На складе имеется: '+ws1+' упаковок(ки)'+' Ставка НП:'+SNalog+' Ставка НДС:'+SNDS, $31));
Control^.Options := Control^.Options or ofCenterX;
MarketWin^.Insert(Control);


MarketWin^.SelectNext(False);
MarketWin^.SetData(El);

DrawPack;

NoInfo;

PrevKol[0]:=#0;

c:=Desktop^.ExecView(MarketWin);

If c<>cmCancel Then
 Begin
  MarketWin^.GetData(El);
  Dispose(Control,Done);
  Dispose(MarketWin,Done);
  If (El.Kol[0]=#0) Or (StrTOInt(El.Kol)=0) Then
   Begin
    MessageBox(#3+NullKol,nil, mfError + mfCancelButton);
    GoTo 1;
   End;
  If Status=DocNormal Then
   Begin
  If (StrToInt(BakGetField(FDiv,SArtikul,StrToInt(SOtd)))<(StrTOInt(El.Kol))) Then
   Begin
     MessageBox(^M+'На складе (отделение ['+SOtd+']) отсутствует такое количество товара ! ',nil, mfError + mfCancelButton);
     GoTo 1;
   End;
   End;
  If Status=DocEdit Then
  Begin
If (StrToInt(BakGetField
(FDiv,SArtikul,StrToInt(SOtd)))-StrTOInt(El.Kol)+GetKolMarket(SArtikul,StrToInt(SOtd),PrevMarket))<0 Then
   Begin
     MessageBox(^M+'На складе (отделение ['+SOtd+']) отсутствует такое количество товара ! ',nil, mfError + mfCancelButton);
     GoTo 1;
   End;
  End;
  If Selector in [0,1] Then
  Begin
  If (StrTOReal(El.Skidka))>(StrtoReal(SRZena){(StrToReal(GetRZena(SArtikul))}) Then
   Begin
      MessageBox('Скидка превышает розничную цену !'^M+
                 'Повторите ввод ! ',nil, mfError + mfCancelButton);
      GoTo 1;
    End
   End
   Else
    Begin
     If (StrTOReal(El.Skidka))>(StrToReal(SOZena){(StrToReal(GetOZena(SArtikul))}) Then
      Begin
       MessageBox('Скидка превышает оптовую цену!'^M+
                'Повторите ввод ! ',nil, mfError + mfCancelButton);
      GoTo 1;
      End;
    End;


   Str(StrToReal(El.Skidka):CZena:CMantissa,El.Skidka);
   s:=SArtikul+'│'+SName+'│'+SOtd+'│';
   With El Do
   Begin
    Str(StrToInt(Kol):CKol,Kol);
    Format(Kol,CKol);
    Str(StrToReal(Skidka):CZena:CMAntissa,Skidka);
    Format(Skidka,CZena);

   If (Selector in [0,1]) Then
    Str(StrToReal(SRZena):CZena:CMantissa,ws)
   Else Str(StrToReal(SOZena):CZena:CMantissa,ws);

    Format(ws,CZena);
    Format(slitr,CLitr);
    Format(sNalog,CLitr);
    Format(sNDS,CLitr);

    s:=s+Kol+'│'+SLitr+'│'+ws+'│'+Skidka+'│';
    {Имя код отд кол литраж цена скидка сумма цена Р Цена О Налог ВидНП НДС ВидНДС Закупка}
   If (Selector in [0,1]) Then Str((StrToReal(SRZena)*StrToInt(El.Kol)):CInputIZena:CMantissa,ws)
   Else
   Str((StrToReal(SOZena)*StrToInt(El.Kol)):CInputIZena:CMantissa,ws);
    DelSpace(ws);
    Format(Ws,CInputIZena);
    s:=s+ws+'│'+SRZena+'│'+SOZena+'│'+SNalog+'│'+IntToStr(VidNalog,COne)+
    '│'+SNDS+'│'+IntToStr(VidNDS,COne)+'│'+SZakupka;
   End;

  If Regim=1 Then
    Begin
     Regim:=Prodaga^.Focused;
     Prodaga^.List^.AtFree(Prodaga^.Focused);
     Prodaga^.SetRange(Prodaga^.List^.Count);
    End;

   Prodaga^.List^.Insert(NewStr(S));
   Prodaga^.SetRange(Prodaga^.List^.Count);
   Prodaga^.FocusItem(Location(Prodaga,SArtikul,True));
 End
 Else
 Begin
  Dispose(Control,Done);
  Dispose(MarketWin,Done);
 End;
End;


Destructor TMarketWinDow.Done;
Begin
Dispose(Pack,Done);
Dispose(ControlPack,Done);
Dispose(ControlKol,Done);
If Skidka=1 Then Dispose(Control1Skidka,Done);
TDialog.Done;
End;



procedure TMarketWindow.HandleEvent(var Event: TEvent);
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

Procedure InputLocalSkidka;
var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  c : Word;
  st : ArtikulStr;
  Zena : TDateString;
  Event : TEvent;
begin
MarketWin^.GetData(El);
c:=1;
If Selector in[0,1] Then
Zena:=BakGetField(FRZena,SArtikul,c)
Else
Zena:=BakGetField(FOZena,SArtikul,c);

If StrToREal(El.Skidka)>=0.01 Then
 Begin
  Str(((StrToReal(Zena))/((StrToReal(Zena)-StrToReal(El.Skidka)))-1):COne:CLitrMantissa,st);
  System.Delete(st,Pos('.',st)-1,2);
 End
 Else St:='0';

 DelSpace(St);

R.Assign(28, 9, 45, 12);
New(Dlg, Init(R, 'Скидка'));
Dlg^.Palette := dpCyanDialog;
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx := $E004;
R.Assign(10, 1, 15, 2);
Control := New(PInputLine, Init(R, CLitrMantissa));
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0']));

  R.Assign(1, 1, 9, 2);
  Dlg^.Insert(New(PLabel, Init(R, 'Скидка:', Control)));

{
R.Assign(15, 1, 18, 2);
Control := New(PStaticText, Init(R, '%'));
Dlg^.Insert(Control);
}

R.Assign(9, 1, 11, 2);
Control := New(PColoredText, Init(R, '1.', $1F));
Dlg^.Insert(Control);


Dlg^.SetData(St);

Dlg^.SelectNext(False);
Event.KeyCode:=kbEnd;
Event.What:=evKeyDown;
PutEvent(Event);

c:=Desktop^.ExecView(Dlg);

If c<>cmCancel Then
 Begin
  Dlg^.GetData(st);
  Dispose(Control,Done);
  Dispose(Dlg,Done);
  DelSpace(St);

  If (St[1] in['2','3','4','5']) And Not(CurrentPassword='00') Then
   If Not (NewPassword(4)) Then Exit;

  St:='1.'+st;
  If StrToReal(st)>1.5 Then
   Begin
    Messagebox(^M+#3'Недопустимая ВЕЛИЧИНА скидки!',Nil,mfError+mfCancelButton);
    Exit;
   End;
  If StrToReal(st)<1.00 Then
   Begin
    Messagebox(^M+#3'Недопустимое ЗНАЧЕНИЕ скидки!',Nil,mfError+mfCancelButton);
    Exit;
   End;
   {}
   Str(StrToReal(Zena)-(StrToReal(Zena)/(StrToReal(st))):CZena:CMantissa,El.Skidka);
   DelSpace(El.Skidka);
   Control1Skidka^.SetDAta(El.Skidka);
   MarketWin^.Redraw;
 End
 Else
 Begin
  Dispose(Control,Done);
  Dispose(Dlg,Done);
 End;
end;

Procedure InputLocalNazenka;
var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  c : Word;
  st : ArtikulStr;
  Zena : TDateString;
  Event : TEvent;
begin
{If Not(Password(2)) Then Exit;}{убрал по желанию бакши}
MarketWin^.GetData(El);
c:=1;
If   Selector in[0,1] Then Zena:=BakGetField(FRZena,SArtikul,c)
Else Zena:=BakGetField(FOZena,SArtikul,c);

If (StrToREal(El.Skidka))<=-0.01 Then
 Begin
  Str((
      (Abs(StrToReal(El.Skidka))
      )
      /(
        (StrToReal(Zena)
        )
       )*100
     ):CKol:CMantissa,st);
 End
 Else St:='0';

 DelSpace(St);

R.Assign(29, 10, 50, 13);
New(Dlg, Init(R, 'Наценка'));
Dlg^.Palette := dpCyanDialog;
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx := $E003;
R.Assign(10, 1, 17, 2);
Control := New(PInputLine, Init(R, CKol));
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));

  R.Assign(1, 1, 10, 2);
  Dlg^.Insert(New(PLabel, Init(R, 'Наценка:', Control)));

R.Assign(18, 1, 20, 2);
Control := New(PColoredText, Init(R, '%',$BE));
Dlg^.Insert(Control);

Dlg^.SetData(St);

Dlg^.SelectNext(False);

{Event.KeyCode:=kbEnd;
Event.What:=evKeyDown;
PutEvent(Event);}

c:=Desktop^.ExecView(Dlg);

If c<>cmCancel Then
 Begin
  Dlg^.GetData(st);
  Dispose(Control,Done);
  Dispose(Dlg,Done);
  DelSpace(St);

   Str((StrToReal(Zena)*StrToReal(st)/(-100)):CZena:CMantissa,El.Skidka);
   DelSpace(El.Skidka);
   Control1Skidka^.SetDAta(El.Skidka);
   MarketWin^.Redraw;
 End
 Else
 Begin
  Dispose(Control,Done);
  Dispose(Dlg,Done);
 End;
end;

VAr ShowWarning : Boolean;
    InputPack   : ArtikulStr;

Begin
Case Event.What Of
 evCommand :
   Case Event.Command Of
        cmLocalCalc: Calculator;
      cmLocalSkidka: If Skidka=1 Then InputLocalSkidka;
     cmLocalNazenka: If Skidka=1 Then InputLocalNazenka;
   Else;
   End;
 evKeyDown:
   Case Event.KeyCode Of
        kbEnter:Begin
                inherited HandleEvent(Event);
                If (MarketWin^.Current=Pack) Then
                   Begin
                    Event.What:=evCommand;
                    Event.Command:=CmOk;
                   End;
                End;
   Else;
   End;
   Else;
   End;
  inherited HandleEvent(Event);
  If (Pack^.State and sfFocused <> 0) Then
   Begin
    ShowWarning:=FAlse;
    InputPAck[0]:=#0;
    DrawKol(ShowWarning,InputPack);
    If ShowWarning Then
    Begin
     Sound(100);
     DinfoMsg('Внимание! В отделении ['+ActiveOtdel+'] нет такого количества '+InputPack+' шт.');
     Delay(700);
     NoSound;
     Delay(700);
     NoInfoMsg;
     ClearEvent(Event);
    End;



   End;
  DrawPack;
End;



procedure TSuperMarketWindow.OpenSuperMarketWindow;
Var l : Boolean;
begin
  ClearFind;
  if Message(Desktop, evBroadcast, cmSuperMarket, nil) = nil then
  begin
    DInfo('Инициализация продажи...');
    L:=True;
    SuperMarketWindow := New(PSuperMarketWindow, Init(L));
    If L Then
    Begin
    Application^.InsertWindow(SuperMarketWindow);
    NoInfo;
    End
    Else
     Begin
      TekDAte:=FDAte;
      Status:=DocNormal;
      Dispose(SuperMarketWindow,Done);
      NoInfo;
     End;
  end
  else
    if PView(SuperMarketWindow) <> Desktop^.TopView then SuperMarketWindow^.Select;
end;



constructor TSuperMarketWindow.Init(Var l : Boolean);
var
  R : TRect;
  Control : PView;
  C : Word;
  DocumentNumer : TDateString;
  SuperMarketFile : File Of SuperMarketType;
  s: TMyString;
  ws : TDateString;
  k,i : Byte;
  mm,mm2 : Maska9;
  Event : TEvent;
  Cod : ArtikulStr;

begin
R.Assign(0, 0, 80, 23);
If Status=DocNormal Then
Begin
inherited Init(R, 'Продажа товара');
TekDate:=FDate;
End
Else
Begin
inherited Init(R, 'Коррекция продажи');
TekDate:=Assistent.D;
End;
Options := Options or ofCenterX or ofCenterY;
HelpCtx:=$E011;
L:=False;

If Not(TestOpenDate1(TekDate)) Then
   Begin
    MessageBox(#3^M+#3'Доступ к данным за '+TekDate+' заблокирован!',Nil,mfError+mfCancelButton);
    TekDate:=FDAte;
    Exit;
   End;

C:=IOResult;
  Assign(SuperMarketFile,Path.ToMarket+TekDate+'.mrk');
  Reset(SuperMarketFile);
  C:=IOResult;
  If C<>0 Then
   Begin
    If MessageBox(#3'Файл продаж за '+TekDate+' не найден'^M+
    #3'Если Вы раннее что-то продавали'^M+
    #3'немедленно позовите программиста'^M+
    #3'Создавать файл продажи?'+' Код:'+IntToStr(c,3),Nil, mfWarning+mfOkCancel)=cmOk Then
     Begin
{     c:=Ioresult;
      Reset(SuperMarketFile);
      c:=Ioresult;
      If c<>0 Then Rewrite(SuperMarketFile);}
      If Not(CreatToDayF(DocMarket,TekDate)) Then Exit;
      Reset(SuperMarketFile);
      c:=IOResult;
     End
    Else Exit;
   End;

   System.Close(SuperMarketFile);

  If Status=DocNormal Then
  Begin
(* DocumentNumer:=IntToStr(FileSize(SuperMarketFile)+1,CDocNumer){+'S'};
   System.Close(SuperMarketFile);*)
   If Not(UseDocNumer(DocMarket,TekDate,DocumentNumer)) Then Exit;
  End
  Else
   Begin
    New(PrevMarket,Init);

    i:=LockMArket(Assistent,PrevMArket);
    If I=2 Then
     Begin
      Beep;
      DinfoMsg('Не могу заблокировать док-т продажи N '+PrevMarket^.Dat.Document+' от '+PrevMarket^.Dat.DateC+
         '. Попробуйте повторить!');
      Dispose(PrevMarket,Done);
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
      Dispose(PrevMarket,Done);
      Exit;
     End;

    If Not(SetClientLock(PrevMarket^.Dat.ClientKod,0,PrevMArket^.Dat.OperatorSelector)) Then
     Begin

     Repeat
     Until (UnLockMarket(PrevMarket^.Dat.Document,PrevMarket^.Dat.DateC) in [0,2]);
     Sound(100);
     DinfoMsg('Не могу заблокировать клиента '+PrevMarket^.Dat.ClientKod+'! Попробуйте повторить!');
     NoSound;
     Dispose(PrevMarket,Done);
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

     DocumentNumer:=PrevMarket^.Dat.Document;

   End;

R.Assign(56, 0, 79, 1);
ControlOperatorSelect := New(PRadioButtons, Init(R,
  NewSItem('Кли~е~нт',
  NewSItem('Скл~а~д', Nil))));
  Insert(ControlOperatorSelect);

If Status=DocEdit Then
  OperatorSelector:=PrevMarket^.Dat.OperatorSelector
Else OperatorSelector:=0;

ControlOperatorSelect^.SetData(OperatorSelector);

Prom:=OperatorSelector;


  R.Assign(51, 0, 56, 1);
  Insert(New(PLabel, Init(R, 'Вид:', ControlOperatorSelect)));


{R.Assign(1, 1, 36, 3);}
R.Assign(1, 1, 37, 4);
ControlSelect := New(PRadioButtons, Init(R,
  NewSItem('С~п~',
  NewSItem('~Т~Ч',
  NewSItem('ФЛ*',
  NewSItem('~С~Ф*',
  NewSItem('СФБ',
  NewSItem('Д~*~',
  NewSItem('Д С~Ф~*',
  NewSItem('~Д~',
  NewSItem('Д СФБ',
  NewSItem('~?~', Nil))))))))))));
Insert(ControlSelect);

(*
New(PRadioButtons, Init(R,
  NewSItem('Спис~о~к',
  NewSItem('~Т~ Чек',
  NewSItem('Фи~з~.Л',
  NewSItem('С/~Ф~',
  NewSItem('С/Ф Б',
  NewSItem('Дебит',
  NewSItem('Деб С/Ф',
  NewSItem('~?~', Nil))))))))));
*)


If Status=DocEdit Then
Begin

Selector:=PrevMarket^.Dat.DocSelector;

If Status=DocEdit Then
 Begin
  {
  If PrevMarket^.Dat.DocSelector=5 Then
  If TestSF(PrevMarket^.Dat.ClientKod,PrevMarket^.Dat.Document,PrevMarket^.Dat.DateC) Then Selector:=6;
  }
 End;

  WordToBit9(MasDocNumer,MM);
  k:=1;
For c:=Max9 Downto 1 Do
   Begin
    mm2[k]:=mm[c];
    inc(k);
   End;

  If (Mm2[Selector+1]=0)And(OperatorSelector<>1) Then
   Begin
    Repeat
    Until (SetClientUnLock(PrevMarket^.Dat.ClientKod,0,PrevMarket^.Dat.OperatorSelector));
    Dispose(PrevMarket,Done);
    MessageBox(^m+#3'Вам нельзя редактировать этот вид документов!',Nil,mfError+mfCancelButton);
    l:=False;
    Exit;
   End;

End

Else Selector:=DefaultDoc;

ControlSelect^.SetData(Selector);
R.Assign(0, 0, 0, 0);
Client := New(PBox, Init(R, 1, Nil));
Client^.NewList(New(PTextCollection, Init(0,1)));
{If Selector<>5 Then
Begin}
If OperatorSelector=0 Then
Assign (ClientFile,Path.ToClient+'Client.db')
Else
Assign (ClientFile,Path.ToClient+'Sklad.db');
{End
Else
Assign (ClientFile,Print.PathToMain+'Debit.db');}

I:=IOResult;
Reset (ClientFile);
I:=IOResult;
If i=0 Then
Begin
While Not(Eof(ClientFile)) Do
 Begin
     {
     Repeat
     Until NetCall.Lock(ClientFile,FilePos(ClientFile)*SizeOf(ClientType),SizeOf(ClientType));
     }
     ReadClient(ClientFile,ClientElement);
     {
     Repeat
      NetCall.UnLock(ClientFile,(FilePos(ClientFile)-1)*SizeOf(ClientType),SizeOf(ClientType));
     Until (DosError=0);
     }

  If ClientElement.Employ Then
   Begin
    Format (ClientElement.Name,CClient);
    Client^.List^.Insert(NewStr(ClientElement.Name+'│'+ClientElement.Kod));
    Client^.SetRange(Client^.List^.Count);
   End;
 End;
System.Close(ClientFile);
End;

If Status=DocEdit Then Client^.FocusItem(Location(Client,PrevMarket^.Dat.ClientKod,ProdagaWindow))
Else
Begin
 If Not(SetLockNearClient(Client,0,0,Cod)) Then
  Begin
   Dispose(Client,Done);
   L:=False;
   MessageBox(^M+#3'Не могу заблокировать ни одного клиента!',Nil,mfError+mfCancelButton);
   Exit;
  End;
   Client^.FocusItem(Location(Client,Cod,False));
End;

ClientShkala:=StrToInt(GetClientField(FShkala,Cod,OperatorSelector));

Client^.HelpCtx:=$E001;
PrevS:=Client^.GEtText(Client^.Focused,Client^.List^.COunt);
Dispose(Client,Done);



{R.Assign(48, 1, 75, 2);}
R.Assign(52, 1, 79, 2);
ControlClient := New(PColoredText, Init(R, #3+PrevS, $1F));
ControlClient^.Options := ControlClient^.Options or ofSelectable;
Insert(ControlClient);

{R.Assign(40, 1, 48, 2);}
R.Assign(44, 1, 52, 2);
Insert(New(PLabel, Init(R, 'Кл~и~ент:', ControlClient)));

{R.Assign(51, 2, 74, 3);}
R.Assign(45, 2, 75, 3);
ControlSkidka := New(PRadioButtons, Init(R,
  NewSItem('А~в~то',
  NewSItem('Руч~н~',
  NewSItem('~Ш~кал.', Nil)))));

Insert(ControlSkidka);

If Status=DocEdit Then Skidka:=PrevMarket^.Dat.SkidkaSelector
Else Skidka:=0;

ControlSkidka^.SetData(Skidka);

{  R.Assign(42, 2, 51, 3);}
  R.Assign(37, 2, 45, 3);
  Insert(New(PLabel, Init(R, 'Скидка:', ControlSkidka)));





R.Assign(0, 0, 0, 0);
FZRazdel := New(PBox, Init(R, 1, Nil));
FZRazdel^.NewList(New(PTextCollection, Init(0,1)));
Assign (RazdelFile,Path.ToRazdel+'zaprfl!.db');
Reset (RazdelFile);
While Not(Eof(RazdelFile)) Do
Begin
Read(RazdelFile,RazdelElement);
FZRazdel^.List^.Insert(NewStr(RazdelElement.Kod));
FZRazdel^.SetRange(FZRazdel^.List^.Count);
End;
System.Close(RazdelFile);

R.Assign(0, 0, 0, 0);
SpisokRazdel := New(PBox, Init(R, 1, Nil));
SpisokRazdel^.NewList(New(PTextCollection, Init(0,1)));
Assign (RazdelFile,Path.ToRazdel+'zaprsp.db');
Reset (RazdelFile);
While Not(Eof(RazdelFile)) Do
Begin
Read(RazdelFile,RazdelElement);
SpisokRazdel^.List^.Insert(NewStr(RazdelElement.Kod));
SpisokRazdel^.SetRange(SpisokRazdel^.List^.Count);
End;
System.Close(RazdelFile);

R.Assign(0, 0, 0, 0);
SFRazdel := New(PBox, Init(R, 1, Nil));
SFRazdel^.NewList(New(PTextCollection, Init(0,1)));
Assign (RazdelFile,Path.ToRazdel+'zaprsf!.db');
Reset (RazdelFile);
While Not(Eof(RazdelFile)) Do
Begin
Read(RazdelFile,RazdelElement);
SFRazdel^.List^.Insert(NewStr(RazdelElement.Kod));
SFRazdel^.SetRange(SFRazdel^.List^.Count);
End;
System.Close(RazdelFile);

R.Assign(0, 0, 0, 0);
SFBRazdel := New(PBox, Init(R, 1, Nil));
SFBRazdel^.NewList(New(PTextCollection, Init(0,1)));
Assign (RazdelFile,Path.ToRazdel+'zaprsb.db');
Reset (RazdelFile);

While Not(Eof(RazdelFile)) Do
Begin
Read(RazdelFile,RazdelElement);
SFBRazdel^.List^.Insert(NewStr(RazdelElement.Kod));
SFBRazdel^.SetRange(SFBRazdel^.List^.Count);
End;
System.Close(RazdelFile);

R.Assign(0, 0, 0, 0);
TChekRazdel := New(PBox, Init(R, 1, Nil));
TChekRazdel^.NewList(New(PTextCollection, Init(0,1)));
Assign (RazdelFile,Path.ToRazdel+'zaprth!.db');
Reset (RazdelFile);
While Not(Eof(RazdelFile)) Do
Begin
Read(RazdelFile,RazdelElement);
TChekRazdel^.List^.Insert(NewStr(RazdelElement.Kod));
TChekRazdel^.SetRange(TChekRazdel^.List^.Count);
End;
System.Close(RazdelFile);

R.Assign(0, 0, 0, 0);
DebitRAzdel := New(PBox, Init(R, 1, Nil));
DebitRAzdel^.NewList(New(PTextCollection, Init(0,1)));
Assign (RazdelFile,Path.ToRazdel+'zaprd!.db');
Reset (RazdelFile);
While Not(Eof(RazdelFile)) Do
Begin
Read(RazdelFile,RazdelElement);
DebitRAzdel^.List^.Insert(NewStr(RazdelElement.Kod));
DebitRAzdel^.SetRange(DebitRAzdel^.List^.Count);
End;
System.Close(RazdelFile);

R.Assign(0, 0, 0, 0);
DebitRazdel_Sn := New(PBox, Init(R, 1, Nil));
DebitRazdel_Sn^.NewList(New(PTextCollection, Init(0,1)));
Assign (RazdelFile,Path.ToRazdel+'zaprd.db');
Reset (RazdelFile);
While Not(Eof(RazdelFile)) Do
Begin
Read(RazdelFile,RazdelElement);
DebitRazdel_Sn^.List^.Insert(NewStr(RazdelElement.Kod));
DebitRazdel_Sn^.SetRange(DebitRazdel_Sn^.List^.Count);
End;
System.Close(RazdelFile);

R.Assign(0, 0, 0, 0);
DebitSFRazdel := New(PBox, Init(R, 1, Nil));
DebitSFRazdel^.NewList(New(PTextCollection, Init(0,1)));
Assign (RazdelFile,Path.ToRazdel+'zaprdsf!.db');
Reset (RazdelFile);
While Not(Eof(RazdelFile)) Do
Begin
Read(RazdelFile,RazdelElement);
DebitSFRazdel^.List^.Insert(NewStr(RazdelElement.Kod));
DebitSFRazdel^.SetRange(DebitSFRazdel^.List^.Count);
End;
System.Close(RazdelFile);

R.Assign(0, 0, 0, 0);
DebitSFBRazdel := New(PBox, Init(R, 1, Nil));
DebitSFBRazdel^.NewList(New(PTextCollection, Init(0,1)));
Assign (RazdelFile,Path.ToRazdel+'zaprdsb.db');
Reset (RazdelFile);
While Not(Eof(RazdelFile)) Do
Begin
Read(RazdelFile,RazdelElement);
DebitSFBRazdel^.List^.Insert(NewStr(RazdelElement.Kod));
DebitSFBRazdel^.SetRange(DebitSFBRazdel^.List^.Count);
End;
System.Close(RazdelFile);

R.Assign(36, 5, 37, 21);
Control := New(PScrollBar, Init(R));
Insert(Control);


R.Assign(1, 5, 36, 21);
Baz := New(PBox, Init(R, 1, PScrollbar(Control)));
Baz^.NewList(New(PTextCollection, Init(0,1)));
{
Assign (RazdelFile,Print.PathToMain+'razdel.db');
Reset (RazdelFile);
While Not(Eof(RazdelFile)) Do
Begin
Read(RazdelFile,RazdelElement);
If RazdelElement.Employ Then
Begin
Assign (BazFile,Print.PathToMain+RazdelElement.Kod+'.db');
Reset (BazFile);
While Not(Eof(BazFile)) Do
 Begin
  Read(BazFile,BazElement);
  l:=false;
  If Status=DocNormal Then
  If (BazElement.Baz.Employ)And(StrToInt(BazElement.Baz.Input.Kol)>0) then
        l:=true;
  If Status=DocEdit Then
    if (BazElement.Baz.Employ)And((StrToInt(BazElement.Baz.Input.Kol)+
GetFullKolMarket(BazElement.Baz.BazKod,PrevMarket))>0) Then l:=true;
 if l then
   Begin
    Format (BazElement.Baz.Name,CName);
    Format (BazElement.Baz.Litr,CLitr);
    For i:=1 To CDivision Do
    Begin
     If Status=DocEdit Then
     Str(StrToInt(BazElement.Baz.Input.Division[i])+GetKolMarket(BazElement.Baz.BazKod,i,PrevMarket):CKol,
     BazElement.Baz.Input.Division[i]);
     DelSpace(BazElement.Baz.Input.Division[i]);
     Format (BazElement.Baz.Input.Division[i],CKol);
     Format (BazElement.Baz.InPack,CInPack);
     Format (BazElement.Baz.Input.R_Zena,CZena);
     Format (BazElement.Baz.Input.O_Zena,CZena);
     Str(StrToInt(BazElement.Baz.Input.Division[i]):CKol,BazElement.Baz.Input.Division[i]);
     Str(i:1,SArtikul);
     Prevs:=BazElement.Baz.Name+'│'+BazElement.Baz.BazKod+'│'+SArtikul+'│'+BazElement.Baz.Litr+
     '│'+BazElement.Baz.InPack+'│'+BazElement.Baz.Input.Division[i]+'│';
     If Selector in[0,1] Then PrevS:=PrevS+BazElement.Baz.Input.R_Zena
     Else PrevS:=PrevS+BazElement.Baz.Input.O_Zena;

     If StrToInt(BazElement.Baz.Input.Division[i])>0 Then
     Baz^.List^.Insert(NewStr(Prevs));
     Baz^.SetRange(Baz^.List^.Count);
    End;
   End;
 End;
System.Close(BazFile);
End;
End;
System.Close(RazdelFile);
}
Baz^.FocusItem(0);
Baz^.HelpCtx:={E141}$F036;
Insert(Baz);

l:=False;

  R.Assign(1, 4, 36, 5);
  Insert(New(PLabel, Init(R, 'На складе и~м~еется           Код  N', Baz)));

R.Assign(79, 4, 80, 21);
Control := New(PScrollBar, Init(R));
Insert(Control);

R.Assign(37, 4, 79, 21);
Prodaga := New(PBox, Init(R, 1, PScrollbar(Control)));
Prodaga^.NewList(New(PTextCollection, Init(0,1)));
If Status=DocEdit Then
 Begin
  ClientShkala:=PrevMarket^.Dat.ShkalaNumer;

  c:=1;
  For c:=1 To PrevMarket^.Dat.Amount Do
   Begin
    S:=GetIdField(FName,PrevMarket^.Dat.MarketElement[c].BazKod);
    Format(S,CName);
    s:=PrevMarket^.Dat.MarketElement[c].BazKod+'│'+s;
    s:=s;
Str(StrToInt(PrevMarket^.Dat.MarketElement[c].Input.Kol):CKol,PrevMarket^.Dat.MarketElement[c].Input.Kol);
    Format (PrevMarket^.Dat.MarketElement[c].Input.Kol,CKol);
Str(StrToReal(PrevMarket^.Dat.MarketElement[c].Input.Zena):CZena:CMantissa,PrevMarket^.Dat.MarketElement[c].Input.Zena);
    Format (PrevMarket^.Dat.MarketElement[c].Input.Zena,CZena);
Str(StrToReal(PrevMarket^.Dat.MarketElement[c].Input.Skidka):CZena:CMantissa,PrevMarket^.Dat.MarketElement[c].Input.Skidka);
    Format(PrevMarket^.Dat.MarketElement[c].Input.Skidka,CZena);
    Format(PrevMarket^.Dat.MarketElement[c].Input.R_Zena,CZena);
    Format(PrevMarket^.Dat.MarketElement[c].Input.O_Zena,CZena);
    Format(PrevMarket^.Dat.MarketElement[c].Input.Zakupka,CZena);
    Format(PrevMarket^.Dat.MarketElement[c].Input.SpecNAlog,CLitr);
    Format(PrevMarket^.Dat.MarketElement[c].Input.NDS,CLitr);
    Format(PrevMarket^.Dat.MarketElement[c].Input.Itogo,CInputIZena);
    Str(PrevMarket^.Dat.MarketElement[c].Input.DiviSionNumber:1,SArtikul);
    ws:=GetIdField(FLitr,PrevMarket^.Dat.MarketElement[c].BazKod);
    Format(WS,CLitr);
    s:=s+'│'+SArtikul+'│'+PrevMarket^.Dat.MarketElement[c].Input.Kol+'│'+ws+'│'+PrevMarket^.Dat.MarketElement[c].Input.Zena
    +'│'+PrevMarket^.Dat.MarketElement[c].Input.Skidka+'│'+PrevMarket^.Dat.MarketElement[c].Input.Itogo+'│'+
    PrevMarket^.Dat.MarketElement[c].Input.R_Zena+'│'+PrevMarket^.Dat.MarketElement[c].Input.O_Zena+
    '│'+PrevMarket^.Dat.MarketElement[c].Input.SpecNalog+'│'+
    IntToSTr(PrevMarket^.Dat.MarketElement[c].Input.VidNAlog,COne)+
    '│'+PrevMarket^.Dat.MarketElement[c].Input.NDS+'│'+
    IntToSTr(PrevMarket^.Dat.MarketElement[c].Input.VidNDS,COne)+'│'+
    PrevMarket^.Dat.MarketElement[c].Input.Zakupka;
    Prodaga^.List^.Insert(NewStr(s));
    Prodaga^.SetRange(Prodaga^.List^.Count);
   End;
 End;
Prodaga^.HelpCtx:={E150}$F047;
Prodaga^.FocusItem(0);
Insert(Prodaga);

  R.Assign(37, 3, 79, 4);
  Insert(New(PLabel, Init(R, 'Код   Выбранн~ы~е товары           N Колич', Prodaga)));
{                             12345678901234567890123456 12345 1}

{
R.Assign(34, 22, 43, 23);
Control := New(PColoredText, Init(R, ' Выбрано:', $74));
Insert(Control);
}

R.Assign(35, 22, 50, 23);
ControlSpecNalog := New(PColoredText, Init(R, #3+'0.00', $4E));
Insert(ControlSpecNalog);


R.Assign(41, 21, 48, 22);
If Skidka in [2] Then
ControlShkala := New(PColoredText, Init(R, 'Шкала '+IntToStr(ClientShkala,COne), $74))
Else
ControlShkala := New(PColoredText, Init(R, '', $74));



R.Assign(75, 2, 79, 3);
ControlCurrent := New(PColoredText, Init(R, #3+' 0', $4e));
Insert(ControlCurrent);

R.Assign(1, 0, 12, 1);
Control := New(PColoredText, Init(R, 'Документ N:', $74));
Insert(Control);


R.Assign(12, 0, 16, 1);
ControlDoc := New(PColoredText, Init(R, ''+DocumentNumer, $7E));
Insert(ControlDoc);

R.Assign(17, 0, 22, 1);
Control := New(PColoredText, Init(R, 'Дата:', $74));
Insert(Control);

R.Assign(22, 0, 30, 1);
Control := New(PColoredText, Init(R, TekDate, $7E));
Insert(Control);

R.Assign(50, 22, 64, 23);
Control := New(PColoredText, Init(R, ' E со скидкой:', $74));
Insert(Control);

R.Assign(64, 22, 79, 23);
Control_I := New(PColoredText, Init(R, '0.00', $4E{7E}));
Insert(Control_I);

R.Assign(27, 21, 36, 22);
Control := New(PColoredText, Init(R, 'Серт-кат:', $74));
Insert(Control);

R.Assign(23, 22, 35, 23);
Control := New(PColoredText, Init(R, +' Мест:', $74));
Insert(Control);

R.Assign(29, 22, 34, 23);
ControlMesto := New(PColoredText, Init(R, #3+'', $4E));
Insert(ControlMesto);




If Baz^.List^.Count>0 Then
Begin
Prevs:=Baz^.GetText(Baz^.Focused,Baz^.List^.Count);
SArtikul:=Copy(PrevS,1{+CName+1},CArtikul);
PrevS:=BakGetField(FSertif,SArtikul,0);
DelSpaceRight(PrevS);
If PrevS[0]=#0 Then PrevS:=Netu
Else PrevS:=Est;
End
Else PrevS:=Netu;

R.Assign(36, 21, 40, 22);
ControlSertif := New(PColoredText, Init(R, PrevS, $7E));
Insert(ControlSertif);

R.Assign(1, 22, 8, 23);
Control := New(PColoredText, Init(R, 'Скидка:', $74));
Insert(Control);

R.Assign(8, 22, 23, 23);
ControlItogoSkidka := New(PColoredText, Init(R, #3+'0.00', $4E));
Insert(ControlItogoSkidka);

R.Assign(1, 21, 7, 22);
Control := New(PColoredText, Init(R, 'Колич:', $71));
Insert(Control);

R.Assign(7, 21, 12, 22);
If Baz^.List^.Count>=1 Then
PrevS:=Copy(Baz^.GetText(Baz^.Focused,Baz^.List^.Count),1+CName+1+CArtikul+1+COne+1+CLitr+1+CInPack+1,CKol)
Else PrevS[0]:=#0;
DelSpace(PrevS);
ControlBKol := New(PColoredText, Init(R, #3+PrevS, $7E));
Insert(ControlBKol);

R.Assign(13, 21, 18, 22);
Control := New(PColoredText, Init(R, 'Цена:', $71));
Insert(Control);

R.Assign(18, 21, 26, 22);
If Baz^.List^.Count>=1 Then
PrevS:=Copy(Baz^.GetText(Baz^.Focused,Baz^.List^.Count),1+CName+1+CArtikul+1+COne+1+CLitr+1+CInPack+1+CKol+1,CZena)
Else PrevS[0]:=#0;
DelSpace(PrevS);
ControlBZena := New(PColoredText, Init(R, #3+PrevS, $7E));
Insert(ControlBZena);

R.Assign(49, 21, 54, 22);
Control := New(PColoredText, Init(R, 'Цена:', $71));
Insert(Control);

If Status=DocEdit Then
Begin
{Имя код отд кол литраж цена скидка сумма цена Р Цена О}
If Prodaga^.List^.Count>=1 Then
PrevSMarket:=Copy(Prodaga^.GetText(Prodaga^.Focused,Prodaga^.List^.Count),
1+CName+1+CArtikul+1+COne+1+CLitr+1+CKol+1,CZena)
Else PrevSMArket[0]:=#0;
DelSpace(PrevSMarket);
End
Else
PrevSMarket[0]:=#0;

R.Assign(54, 21, 62, 22);
ControlProdagaZena := New(PColoredText, Init(R, #3+PrevSMarket, $7E));
Insert(ControlProdagaZena);

R.Assign(63, 21, 70, 22);
Control := New(PColoredText, Init(R, 'Скидка:', $71));
Insert(Control);

If Status=DocEdit Then
Begin
{Имя код отд кол литраж цена скидка сумма цена Р Цена О}
If Prodaga^.List^.Count>=1 Then
PrevSMarket:=Copy(Prodaga^.GetText(Prodaga^.Focused,Prodaga^.List^.Count),
1+CName+1+CArtikul+1+COne+1+CLitr+1+CKol+1+CZena+1,CZena)
Else
PrevSMarket[0]:=#0;
DelSpace(PrevSMarket);
End
Else
PrevSMarket[0]:=#0;

R.Assign(70, 21, 78, 22);
ControlProdagaSkidka := New(PColoredText, Init(R, #3+PrevSMarket, $7E));
Insert(ControlProdagaSkidka);

PrevS[0]:=#0;
PrevSMarket[0]:=#0;
SArtikul[0]:=#0;

SelectNext(False);

information:=true;
DebInfo:=True;

{CalcItogo;}
FreshShkala;
AddName;
L:=True;
PrevS[0]:=#0;
If OperatorSelector=0 Then SetSelector;
{Для скидки у дебиторов}
If Status=DocEdit Then Refresh(True)
Else Refresh(False);

If (Status=DocEdit) And (OperatorSelector=1) Then SetMaska(2);
If Status=DocEdit Then EDAutoSkidka;
If Status=DocEdit Then Prodaga^.Select
Else Baz^.Select;
end;


Function TSuperMarketWindow.CalcItogo(Var ItogNalog:NalogType) : Real;
Var R : TRect;
    t,l : Real;
    nalogItogo,Itogo,SkidkaItogo,Sl,Sk,So,Sr : Real;
    SA : ArtikulStr;
    RealZena,s : TMyString;
    Itogo_Zakupka,Zakupka,zena,nalogstr,ws,SArt,Skid,SSl,SSk,SSo,SSr,Itogo_O,Itogo_R,Itogo_L:String[CIZena];
    ls : Word;
    VidNalog,Mesto,kol :LongInt;
    TempCalc : PBox;
    Koefficient :String[CLitr];

Begin
SO:=0;
SR:=0;
SL:=0;
Mesto:=0;
SkidkaItogo:=0;
Itogo_Zakupka[0]:=#0;
nalogItogo:=0;
kol:=0;

ItogNalog.ENalog[0]:=#0;
ItogNalog.Nalog5[0]:=#0;
ItogNalog.Nalog3[0]:=#0;
ItogNalog.Nalog_[0]:=#0;
ItogNalog.Zakupka[0]:=#0;

If Prodaga^.List^.Count>0 Then
Begin
For ls:=0 To Prodaga^.List^.Count-1 Do
Begin
{артикул}
Sa:=Copy(Prodaga^.GetText(ls,Prodaga^.List^.Count),1,CArtikul);
{литраж}
SSl:=Copy(Prodaga^.GetText(ls,Prodaga^.List^.Count),1+CName+1+CArtikul+1+COne+1+CKol+1,CLitr);
DelSpace(Ssl);
{колич}
SSk:=Copy(Prodaga^.GetText(ls,Prodaga^.List^.Count),1+COne+1+CName+1+CArtikul+1,CKol);
DelSpace(sSk);

ws:=CalcPack(Sa,SSk);
DelSpace(ws);
If Pos('+',ws)>0 Then ws:=Copy(ws,1,Pos('+',ws)-1);
Mesto:=Mesto+StrToInt(ws);

{Любая (оптовая или розничная зависит от вида документа) цена}
SSo:=Copy(Prodaga^.GetText(ls,Prodaga^.List^.Count),1+COne+1+CName+1+CArtikul+1+CLitr+1+CKol+1,CZena);
DelSpace(sso);

{Скидка}
Skid:=Copy(Prodaga^.GetText(ls,Prodaga^.List^.Count),1+COne+1+CName+1+CArtikul+1+CLitr+1+CKol+1+CZena+1,CZena);
DelSpace(skid);

VidNalog:=StrToInt(Copy(Prodaga^.GetText(ls,Prodaga^.List^.Count),1+CName+1+CArtikul+1+CLitr+1+CKol+1+CZena+1+
                        CZena+1+CInputIZena+1+COne+1+CZena+1+
                        CZena+1+clitr+1,COne));


{налог ставка налога}
Nalogstr:=Copy(Prodaga^.GetText(ls,Prodaga^.List^.Count),1+CName+1+CArtikul+1+COne+1+CLitr+1+CKol+1+CZena+1+CZena+
               1+CInputIZena+1+CZena+1+CZena+1,CLitr);
DelSpace(NalogStr);

Zakupka:=Copy(Prodaga^.GetText(ls,Prodaga^.List^.Count),1+CName+1+CArtikul+1+COne+1+CLitr+1+CKol+1+CZena+1+CZena+1+
              CInputIZena+1+CZena+1+CZena+1+CLitr+1+COne+1+CLitr+1+COne+1,CZena);


kol:=StrToInt(ssk);{количество}


t:=StrToReal(Skid);{размер позиционной скидки}
SkidkaItogo:=SkidkaItogo+t*Kol;{велечина общей позиционной скидки}

l:=StrToReal(SSl); {литраж}

Sl:=Sl+L*Kol; {общий литраж}

Sr:=Sr+l*Kol*Lizensia; {велечина ЛС}

l:=StrToReal(SSo);{Цена}
Str((l*Kol):CInputIZena:CMantissa,Itogo_L);


l:=StrToReal(Zakupka);{Закупка}
Str((l*Kol):CInputIZena:CMantissa,Itogo_Zakupka);


Str((1+StrToReal(NalogStr)/100):CLitr:CMantissa,Koefficient);
DelSpace(Koefficient);

Str(StrToReal(SSo)-StrToReal(Skid):CZena:CMAntissa,Zena);

Str(StrToREal(Zena)*StrToReal(Koefficient):CZena:CMantissa,RealZena);

STr(StrToReal(RealZena)-StrToReal(Zena):CZena:CMantissa,RealZena);


Str((StrToReal(Itogo_Zakupka)+StrToReal(ItogNalog.Zakupka)):CIZena:CMantissa,ItogNalog.Zakupka);

{расчитываем если необходимо велечину спец налога}
If Selector in [{1,}2,3,5,6] Then {отключен расчет налога с продажи в тч}
Begin
{велечина спец налога с единицы товара}

Str(StrToReal(RealZena)*Kol:CIZena:CMantissa,RealZena);
DelSpace(RealZena);

{суммарная ставка налога}
Str((StrToReal(RealZena)+StrToReal(ItogNalog.ENalog)):CIZena:CMantissa,ItogNalog.ENalog);
CAse VidNalog Of
0:Str((StrToReal(RealZena)+StrToReal(ItogNalog.Nalog5)):CIZena:CMantissa,ItogNalog.Nalog5);
1:Str((StrToReal(RealZena)+StrToReal(ItogNalog.Nalog3)):CIZena:CMantissa,ItogNalog.Nalog3);
2:Str((StrToReal(RealZena)+StrToReal(ItogNalog.Nalog_)):CIZena:CMantissa,ItogNalog.Nalog_);
Else;
End;
End;
So:=So+StrToReal(Itogo_L);{l*Kol};{стоимость всего накладной}
End;{for}
End;

Itogo:=So;
Sr:=Itogo;

If Skidka in [0,2] Then
 Begin
ItogNalog.ENalog[0]:=#0;
ItogNalog.Nalog5[0]:=#0;
ItogNalog.Nalog3[0]:=#0;
ItogNalog.Nalog_[0]:=#0;

If Prodaga^.List^.Count>0 Then
Begin
R.Assign(0, 0, 0, 0);
TempCalc := New(PBox, Init(R, 1, Nil));
TempCalc^.NewList(New(PTextCollection, Init(0,1)));
For ls:=0 To Prodaga^.List^.Count-1 Do
Begin
{артикул}
Sa:=Copy(Prodaga^.GetText(ls,Prodaga^.List^.Count),1,CArtikul);

{колич}
SSk:=Copy(Prodaga^.GetText(ls,Prodaga^.List^.Count),1+COne+1+CName+1+CArtikul+1,CKol);

{Любая (оптовая или розничная зависит от вида документа) цена}
SSo:=Copy(Prodaga^.GetText(ls,Prodaga^.List^.Count),1+COne+1+CName+1+CArtikul+1+CLitr+1+CKol+1,CZena);

{налог ставка налога}
Nalogstr:=Copy(Prodaga^.GetText(ls,Prodaga^.List^.Count),1+CName+1+CArtikul+1+COne+1+CLitr+1+CKol+1+CZena+1+CZena+
               1+CInputIZena+1+CZena+1+CZena+1,CLitr);

VidNalog:=StrToInt(Copy(Prodaga^.GetText(ls,Prodaga^.List^.Count)
          ,1+CName+1+CArtikul+1+CLitr+1+CKol+1+CZena+1+CZena+1+CInputIZena+1+COne+1+CZena+1+
          CZena+1+clitr+1,COne));


If TestElement(Sa,TempCalc) Then
 Begin
   TempCalc^.List^.Insert(NewStr('│'+Sa+'│'+SSk+'│'+SSo+'│'+NalogStr+'│'+IntToStr(VidNalog,COne)));
   TempCalc^.SetRange(TempCalc^.List^.Count);
 End
  Else
   Begin
    TempCalc^.FocusItem(Location(TempCalc,Sa,False)); {нашли фокус}
    S:=TempCalc^.GetText(TempCalc^.Focused,TempCalc^.List^.Count);
    Skid:=Copy(s,2+Cartikul+1,CKol); {Выяснили количество в фокусе}
    Str(StrToInt(Skid)+StrToInt(SSk):CKol,Skid);{Вычислили новое количество}
    Format(Skid,CKol);
    TempCalc^.List^.AtFree(TempCalc^.Focused); {Удалили старую строку}
    System.Delete(s,2+Cartikul+1,CKol); {Подставли новое количество}
    System.Insert(skid,s,2+Cartikul+1);
    TempCalc^.List^.Insert(NewStr(s));
   End;
End;{for}

 Sr:=0;
 For ls:=0 To TempCalc^.List^.Count-1 Do
  Begin
  {артикул}
  Sa:=Copy(TempCalc^.GetText(ls,TempCalc^.List^.Count),2,CArtikul);
  {колич}
  SSk:=Copy(TempCalc^.GetText(ls,TempCalc^.List^.Count),2+CArtikul+1,CKol);
  {Любая (оптовая или розничная зависит от вида документа) цена}
  SSo:=Copy(TempCalc^.GetText(ls,TempCalc^.List^.Count),2+CArtikul+1+CKol+1,CZena);
  kol:=StrToInt(ssk);

  VidNalog:=StrToInt(Copy(TempCalc^.GetText(ls,TempCalc^.List^.Count),2+CArtikul+1+CKol+1+CZena+1+CLitr+1,COne));

  {Процент ставки спец налога}
  NalogStr:=Copy(TempCalc^.GetText(ls,TempCalc^.List^.Count),2+CArtikul+1+CKol+1+CZena+1,CLitr);
  DelSpace(NAlogStr);

  {старый вариант скидки}
  Case Skidka Of
  0: l:=StrToReal(SSo)/(1+GetSkidkaProz(Sa,Itogo)/100);
  2: l:=StrToReal(SSo)/(1+GetShkalaProz(Sa,ClientShkala)/100);
  Else;
  End;

  Str(L:CZena:CMantissa,Itogo_L);

  Str((1+StrToReal(NalogStr)/100):CLitr:CMantissa,Koefficient);
  DelSpace(Koefficient);

  Str(StrToReal(Itogo_L)*StrToReal(Koefficient):CZena:CMantissa,RealZena);

  Str((StrToReal(RealZena)-StrToReal(Itogo_L)):CZena:CMAntissa,RealZena);



  L:=StrToReal(Itogo_L);

If Selector in [{1,}2,3,5,6] Then {отключаем расчет нп по тч}
Begin
  {расчитываем абсолютное значение сбора по спецналогу с единицы товара}
{  Str((StrToReal(RealZena)-StrToReal(Itogo_L)):CZena:CMantissa,NAlogStr);}
  {всего с позиции}
  Str(StrToReal(RealZena)*Kol:CIZena:CMantissa,RealZena);
  {суммарная ставка налога}
  Str((StrToReal(RealZena)+StrToReal(ItogNalog.ENalog)):CIZena:CMantissa,ItogNalog.ENalog);
 CAse VidNalog Of
 0:Str((StrToReal(RealZena)+StrToReal(ItogNalog.Nalog5)):CIZena:CMantissa,ItogNalog.Nalog5);
 1:Str((StrToReal(RealZena)+StrToReal(ItogNalog.Nalog3)):CIZena:CMantissa,ItogNalog.Nalog3);
 2:Str((StrToReal(RealZena)+StrToReal(ItogNalog.Nalog_)):CIZena:CMantissa,ItogNalog.Nalog_);
 Else;
 End;
End;
  Str((L*Kol):CInputIZena:CMantissa,Itogo_L);

  Sr:=Sr+StrToReal(Itogo_L);


  End;{for}
  SkidkaItogo:=Itogo-Sr;

Dispose(TempCalc,Done);
End;
End;


Itogo:=Itogo-SkidkaItogo;

Str(Sl:CILitr:CLitrMantissa,Itogo_L);
DelSpace(Itogo_L);

Str(SkidkaItogo:CIZena:CMantissa,Skid);
DelSpace(Skid);

If Selector in [{1,}2,3,5,6] Then {отключен расчет нп в тч}
 Str((Itogo+STrToReal(ItogNalog.ENalog)):CIZena:CMantissa,Itogo_O)
 Else
 Str(Itogo:CIZena:CMantissa,Itogo_O);


DelSpace(Itogo_O);

If Selector In [0,1] Then Sr:=0.00;
Str(Sr:CIZena:CMantissa,Itogo_R);
DelSpace(Itogo_R);

Dispose(ControlItogoSkidka,Done);
R.Assign(8, 22, 23, 23);
ControlItogoSkidka := New(PColoredText, Init(R, #3+Skid, $4E));
Insert(ControlItogoSkidka);

Dispose(Control_I,Done);
R.Assign(64, 22, 79, 23);
Control_I := New(PColoredText, Init(R, #3+Itogo_O, $4E));
Insert(Control_I);

Dispose(ControlMesto,Done);
Str(Mesto:CArtikul,ws);
DelSpace(ws);
R.Assign(29, 22, 34, 23);
ControlMesto := New(PColoredText, Init(R, #3+ws, $4E));
Insert(ControlMesto);

Str(StrToreal(ItogNalog.ENalog):CIZena:CMantissa,Itogo_O);
DelSpace(Itogo_O);

Dispose(ControlSpecNalog,Done);
R.Assign(35, 22, 50, 23);
ControlSpecNalog := New(PColoredText, Init(R, #3+Itogo_O, $4E));
Insert(ControlSpecNalog);

FreshShkala;



If (Information)And(StrToReal(Itogo_O)>PrihodMax) And (Selector in [2,3,4,6])Then
 Begin
  Information:=False;
  Beep;
  MessageBox(#3^M+#3'Сумма накладной превышает '+RealToStr(PrihodMax,CZena,CMantissa)+' руб.',
  Nil,mfInformation+mfCancelButton);
 End;

If (DebInfo) And (Selector in [5..8])Then
 Begin
  PStaticText(ControlClient)^.GetText(S);
  s:=Copy(s,1+1+CClient+1,CClientKod);
  if StrtoReal(GetClientField(FLimit,s,0))<(StrToReal(Itogo_O)+StrToReal(GetClientField(FDolg,s,0))) Then
  begin
  DebInfo:=False;
  Beep;
  s:=GetClientField(FLimit,s,0);
  SpecialBeep;
  MessageBox(#3^M+#3'Сумма долга клиента превышает допустимую сумму ( '+s+' руб. )!',Nil,mfWarning+mfCancelButton);
  end;
 End;
 CalcItogo:=Itogo+SkidkaItogo;
End;



Procedure TSuperMarketWindow.AddName;
Var R : TRect;
    KolStr : String[3];
Begin
  Str(Prodaga^.List^.Count:2,KolStr);
  Dispose(ControlCurrent,Done);
  R.Assign(75, 2, 79, 3);
  ControlCurrent := New(PColoredText, Init(R, #3+KolStr, $4e));
  Insert(ControlCurrent);
End;


Procedure TSuperMarketWindow.Refresh(Regim:Boolean);
Var R : TRect;
    i : Word;
    S : TMyString;
    PrevArt,Art : ArtikulStr;
    St : String[CZena];
    Si : String[CInputIZena];
    l,Logik : Boolean;
    SName : AllStr;
    SLitr : TDateString;
    Test1,Test2 : LongInt;
    ts1,ts2 : string[150];
Begin
Test1:=CurrentTime;
DInfo('Формирую список товаров...');
Baz^.NewList(Nil);
Baz^.NewList(New(PTextCollection, Init(0,1)));
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
Logik:=True;
{Старт проверки на товарный чек}
 If Selector=1 Then
 If (TChekRazdel^.List<>Nil)And(TChekRazdel^.List^.Count>0) Then
  Begin
   For i:=0 To TChekRazdel^.List^.Count-1 Do
    Begin
     PrevS:=Copy(TChekRazdel^.GetText(i,TChekRazdel^.List^.Count),1,CRazdelKod);
     If PrevS=RazdelElement.Kod Then logik:=False;
    End;
  End;
{Стоп проверки на товарный чек}

{Старт проверки на список}
 If (Selector=0) And (OperatorSelector=0) Then
 If (SpisokRazdel^.List<>Nil)And(SpisokRazdel^.List^.Count>0) Then
  Begin
   For i:=0 To SpisokRazdel^.List^.Count-1 Do
    Begin
     PrevS:=Copy(SpisokRazdel^.GetText(i,SpisokRazdel^.List^.Count),1,CRazdelKod);
     If PrevS=RazdelElement.Kod Then logik:=False;
    End;
  End;
{Стоп проверки на список}

{Старт проверки на С/Ф}
 If Selector=3 Then
 If (SFRazdel^.List<>Nil)And(SFRazdel^.List^.Count>0) Then
  Begin
   For i:=0 To SFRazdel^.List^.Count-1 Do
    Begin
     PrevS:=Copy(SFRazdel^.GetText(i,SFRazdel^.List^.Count),1,CRazdelKod);
     If PrevS=RazdelElement.Kod Then logik:=False;
    End;
  End;
{Стоп проверки на С/Ф}

{Старт проверки на С/Ф Б}
 If Selector=4 Then
 If (SFBRazdel^.List<>Nil)And(SFBRazdel^.List^.Count>0) Then
  Begin
   For i:=0 To SFBRazdel^.List^.Count-1 Do
    Begin
     PrevS:=Copy(SFBRazdel^.GetText(i,SFBRazdel^.List^.Count),1,CRazdelKod);
     If PrevS=RazdelElement.Kod Then logik:=False;
    End;
  End;
{Стоп проверки на C/Ф Б}

{Старт проверки на Дебит*}
 If Selector=5 Then
 If (DebitRAzdel^.List<>Nil)And(DebitRAzdel^.List^.Count>0) Then
  Begin
   For i:=0 To DebitRAzdel^.List^.Count-1 Do
    Begin
     PrevS:=Copy(DebitRAzdel^.GetText(i,DebitRAzdel^.List^.Count),1,CRazdelKod);
     If PrevS=RazdelElement.Kod Then logik:=False;
    End;
  End;
{Стоп проверки на дебит*}

{Старт проверки на Дебит С/Ф*}
 If Selector=6 Then
 If (DebitSFRazdel^.List<>Nil)And(DebitSFRazdel^.List^.Count>0) Then
  Begin
   For i:=0 To DebitSFRazdel^.List^.Count-1 Do
    Begin
     PrevS:=Copy(DebitSFRazdel^.GetText(i,DebitSFRazdel^.List^.Count),1,CRazdelKod);
     If PrevS=RazdelElement.Kod Then logik:=False;
    End;
  End;
{Стоп проверки на дебит С/Ф*}

{Старт проверки на Дебит}
 If Selector=7 Then
 If (DebitRazdel_Sn^.List<>Nil)And(DebitRazdel_Sn^.List^.Count>0) Then
  Begin
   For i:=0 To DebitRazdel_Sn^.List^.Count-1 Do
    Begin
     PrevS:=Copy(DebitRazdel_Sn^.GetText(i,DebitRazdel_Sn^.List^.Count),1,CRazdelKod);
     If PrevS=RazdelElement.Kod Then logik:=False;
    End;
  End;
{Стоп проверки на дебит}

{Старт проверки на Дебит С/Ф}
 If Selector=8 Then
 If (DebitSFBRazdel^.List<>Nil)And(DebitSFBRazdel^.List^.Count>0) Then
  Begin
   For i:=0 To DebitSFBRazdel^.List^.Count-1 Do
    Begin
     PrevS:=Copy(DebitSFBRazdel^.GetText(i,DebitSFBRazdel^.List^.Count),1,CRazdelKod);
     If PrevS=RazdelElement.Kod Then logik:=False;
    End;
  End;
{Стоп проверки на дебит С/Ф}


{Старт проверки на физ.лицо.}
If Selector=2 Then
 If (FZRazdel^.List<>Nil)And(FZRazdel^.List^.Count>0) Then
  Begin
   For i:=0 To FZRazdel^.List^.Count-1 Do
    Begin
     PrevS:=Copy(FZRazdel^.GetText(i,FZRazdel^.List^.Count),1,CRazdelKod);
     If PrevS=RazdelElement.Kod Then logik:=False;
    End;
  End;

{Стоп проверки на физ.лицо}

If Logik Then
Begin
Assign (BazFile,Path.ToSklad+RazdelElement.Kod+'.db');
i:=ioresult;
Reset (BazFile);
i:=ioresult;
If i=0 Then
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
{  If GetIdEmploy(BazElement.BazKod) Then}
  If BazElement.Employ Then
  Begin
  l:=false;
  If Status=DocNormal Then
  If (StrToInt(BazElement.Input.Kol)>0) then
        l:=true;
  If Status=DocEdit Then
  if ((StrToInt(BazElement.Input.Kol)+
GetFullKolMarket(BazElement.BazKod,PrevMarket))>0) Then l:=true;
 if l then
   Begin
    SName := GetIdField(FName,BazElement.BazKod);
    Format(SName,CName);
    For i:=1 To CDivision Do
    Begin
     If Status=DocEdit Then
     Str(StrToInt(BazElement.Input.Division[i])+GetKolMarket(BazElement.BazKod,i,PrevMarket):CKol,
     BazElement.Input.Division[i]);
     DelSpace(BazElement.Input.Division[i]);
     Format (BazElement.Input.Division[i],CKol);
     Str(StrToInt(BazElement.Input.Division[i]):CKol,BazElement.Input.Division[i]);
     Str(i:1,SArtikul);
     Prevs:=SName+'│'+BazElement.BazKod+'│'+SArtikul+'│';

     If StrToInt(BazElement.Input.Division[i])>0 Then
     Begin
     Baz^.List^.Insert(NewStr(Prevs));
     Baz^.SetRange(Baz^.List^.Count);
     End;
    End;{For}
   End;{If l=True}
  End;{Employ}
 End;{While}
System.Close(BazFile);
End
 Else
  Begin
   MessageBox(^M+#3' Ошибка открытия '+Path.ToSklad+RazdelElement.Kod+'.db'^M+
   #3'Код: '+IntToStr(i,3),Nil,mfError+mfCancelButton);
  End;
End;
End;
End;
System.Close(RazdelFile);
End;
Baz^.FocusItem(0);
{конец}
{обновление списка выбранных наименований}
If (Prodaga^.List<>Nil)And(Prodaga^.List^.Count>0) Then
 Begin
PrevArt:=Copy(Prodaga^.GetText(Prodaga^.Focused,Prodaga^.List^.Count),1,CArtikul);
For i:=0 To Prodaga^.List^.Count-1 Do
Begin
 s:=Prodaga^.GetText(i,Prodaga^.List^.Count);
 If Selector in [0,1] Then
 St:=Copy(s,1+CName+1+CArtikul+1+CKol+1+COne+1+CLitr+1+CZena+1+CZena+1+CInputIZena+1,CZena)
 Else
 St:=Copy(s,1+CName+1+CArtikul+1+CKol+1+COne+1+CLitr+1+CZena+1+CZena+1+CInputIZena+1+CZena+1,CZena);
{Имя код отд кол литраж цена скидка сумма цена Р Цена О С/Н}
 System.Delete(s,1+CName+1+CArtikul+1+CKol+CLitr+1+COne+1+1,CZena);
 System.Insert(st,s,1+CName+1+CArtikul+1+CKol+1+CLitr+1+COne+1);
 Si:=Copy(s,1+CName+1+CArtikul+1+COne+1,CKol);
 Str((StrToInt(si)*StrToReal(St)):CInputIZena:CMantissa,Si);
 DelSpace(Si);
 Format(Si,CInputIZena);
 System.Delete(s,1+COne+1+CName+1+CArtikul+1+CKol+1+CLitr+1+CZena+1+CZena+1,CInputIZena);
 System.Insert(si,s,1+COne+1+CName+1+CArtikul+1+CKol+1+CLitr+1+CZena+1+CZena+1);
 Prodaga^.List^.AtFree(i);
 Prodaga^.SetRange(Prodaga^.List^.Count);
 Prodaga^.List^.Insert(NewStr(S));
 Prodaga^.SetRange(Prodaga^.List^.Count);
End;
Prodaga^.FocusItem(LoCation(Prodaga,PrevArt,True));
 End;
{конец}

FreshMarketHint;

FreshSkladHint;

(* нужно только в хэппи
If Not(Regim) Then
Begin
 If (Selector in [5..8]) Then
    Begin
       i:=1;
       Skidka:=i;
       ControlSkidka^.SetData(i);
    End;
End;
*)

EDAUTOSkidka;
CalcItogo(ItogNAlog);

{ Убрано добавление буквы S для списка и межскладских перевозок
PStaticText(ControlDoc)^.GetText(Art);
Dispose(ControlDoc,Done);
R.Assign(12, 0, 16, 1);
If (Selector=0)And(Pos('S',Art)=0) Then Art:=Art+'S';
If (Selector<>0)And(Pos('S',Art)>0)Then System.Delete(Art,Pos('S',Art),1);
ControlDoc := New(PColoredText, Init(R, Art, $7E));
Insert(ControlDoc);
}

PrevS[0]:=#0;
Noinfo;
If Selector in [5..8] Then
 Begin
     PStaticText(ControlClient)^.GetText(S);
     System.Delete(S,1,1);
      Art:=Copy(s,1+CClient+1,CClientKod);
      If Not(TestDolgClient(Art)) Then
      Begin
      SpecialBeep;
       MessageBox(#3'За клиентом числится просроченный не'+
     'оплаченный документ консигнации!'^M+
     #3'Возможно не следует выдавать ему товар на консигнацию!',Nil,mfWarning+mfCancelButton);
      End;

      If Selector in [6,8] Then
      If DefaultLiZensia=1 Then
      Begin
       Art:=Copy(s,1+CClient+1,CClientKod);
       If Not(TestSrokLizensia(Art,TekDate)) Then
        Begin
         SpecialBeep;
         MessageBox(#3+'У клиента просрочена лицензия или не указан срок ее действия!'^M+
           #3+'Нельзя отпускать ему товар на С/Ф!',Nil,mfError+mfCancelButton);
        End;
      End;

      If StrToInt(GEtClientField(FDebit,Art,0))<>1 Then
       Begin
        MessageBox(^M+#3+'Клиенту запрещено отпускать товар на консигнацию!',Nil,mfError+mfCancelButton);
       End;
 End;

     {с/ф продажи}
     If DefaultLiZensia=1 Then
     Begin
     If Selector in [3,4] Then
      Begin
        PStaticText(ControlClient)^.GetText(S);
        System.Delete(S,1,1);
        Art:=Copy(s,1+CClient+1,CClientKod);
       If Not(TestSrokLizensia(Art,TekDate)) Then
        Begin
        SpecialBeep;
        MessageBox(#3+'У клиента просрочена лицензия или не  указан срок ее действия!'^M+
         #3+'Нельзя отпускать ему товар на С/Ф!',Nil,mfError+mfCancelButton);
       End;
      End;
     End;

Test2:=CurrentTime;
Str(test1,ts1);
Str(test2,ts2);
{MessageBox(Ts1+^M+Ts2,Nil,mfError+mfCancelButton);}
End;


Procedure TSuperMarketWindow.SetEnabledDoc(i:Byte);
Var mm : Maska9;
    mmms,c : Word;
    mm10 : Maska10;
Begin
If i=0 Then
Begin
WordToBit9(MasDocNumer,MM);
For c:=1 To Max9 Do
If Mm[c]=1 Then Mm[c]:=0
Else Mm[c]:=1;


For c:=1 to Max10-1 Do Mm10[c+1]:=mm[c];{переход к 8 видам документа}
mm10[1]:=0;


BitToWord10(MM10,MMMS);
PCluster(ControlSelect)^.SetButtonState(MMMS, False);
End;
If i=1 Then
 Begin
  mm10[1]:=0;
  mm10[2]:=0;
  mm10[3]:=0;
  mm10[4]:=0;
  mm10[5]:=0;
  mm10[6]:=0;
  mm10[7]:=0;
  mm10[8]:=0;
  mm10[9]:=0;
  mm10[10]:=1;
  BitToWord10(MM10,MMMS);
  PCluster(ControlSelect)^.SetButtonState(MMMS, True);
 End;
Redraw;
End;


Procedure TSuperMarketWindow.SetSelector;
Var l : Maska10;
    i,j : Word;
    PrevArt,Art : ArtikulStr;
    s1,s : string[150];
Begin
If OperatorSelector=0 Then
Begin
For i:=1 To Max10 Do
   l[i]:=0; {очистка маски}

If (Prodaga^.List<>Nil)And(Prodaga^.List^.Count>0) Then
 Begin
For i:=0 To Prodaga^.List^.Count-1 Do
Begin
 s:=Copy(Prodaga^.GetText(i,Prodaga^.List^.Count),1{+CName+1},CRazdelKod);

{Старт проверки на список}
 If (SpisokRazdel^.List<>Nil)And(SpisokRazdel^.List^.Count>0) Then
  Begin
   For j:=0 To SpisokRazdel^.List^.Count-1 Do
    Begin
     s1:=Copy(SpisokRazdel^.GetText(j,SpisokRazdel^.List^.Count),1,CRazdelKod);
     If s1=s Then
     l[10]:=1;
    End;
  End;
{Стоп проверки на список}

{Старт проверки на товарный чек}
 If (TChekRazdel^.List<>Nil)And(TChekRazdel^.List^.Count>0) Then
  Begin
   For j:=0 To TChekRazdel^.List^.Count-1 Do
    Begin
     s1:=Copy(TChekRazdel^.GetText(j,TChekRazdel^.List^.Count),1,CRazdelKod);
     If s1=s Then
     l[9]:=1;
    End;
  End;
{Стоп проверки на товарный чек}

{Старт проверки на физ.лицо.}
 If (FZRazdel^.List<>Nil)And(FZRazdel^.List^.Count>0) Then
  Begin
   For j:=0 To FZRazdel^.List^.Count-1 Do
    Begin
     s1:=Copy(FZRazdel^.GetText(j,FZRazdel^.List^.Count),1,CRazdelKod);
     If s1=s Then l[8]:=1;
    End;
  End;
{Стоп проверки на физ.лицо}

{Старт проверки на С/Ф}
 If (SFRazdel^.List<>Nil)And(SFRazdel^.List^.Count>0) Then
  Begin
   For j:=0 To SFRazdel^.List^.Count-1 Do
    Begin
     s1:=Copy(SFRazdel^.GetText(j,SFRazdel^.List^.Count),1,CRazdelKod);
     If s1=s Then
     l[7]:=1;
    End;
  End;
{Стоп проверки на С/Ф}

{Старт проверки на С/Ф Б}
 If (SFBRazdel^.List<>Nil)And(SFBRazdel^.List^.Count>0) Then
  Begin
   For j:=0 To SFBRazdel^.List^.Count-1 Do
    Begin
     s1:=Copy(SFBRazdel^.GetText(j,SFBRazdel^.List^.Count),1,CRazdelKod);
     If s1=s Then
     l[6]:=1;
    End;
  End;
{Стоп проверки на С/Ф Б}

{Старт проверки на дебит}
 If (DebitRAzdel^.List<>Nil)And(DebitRAzdel^.List^.Count>0) Then
  Begin
   For j:=0 To DebitRAzdel^.List^.Count-1 Do
    Begin
     s1:=Copy(DebitRAzdel^.GetText(j,DebitRAzdel^.List^.Count),1,CRazdelKod);
     If s1=s Then
     l[5]:=1;
    End;
  End;
{Стоп проверки на дебит}


{Старт проверки на дебит С/Ф}
 If (DebitSFRazdel^.List<>Nil)And(DebitSFRazdel^.List^.Count>0) Then
  Begin
   For j:=0 To DebitSFRazdel^.List^.Count-1 Do
    Begin
     s1:=Copy(DebitSFRazdel^.GetText(j,DebitSFRazdel^.List^.Count),1,CRazdelKod);
     If s1=s Then
     l[4]:=1;
    End;
  End;
{Стоп проверки на дебит С/Ф}

{Старт проверки на дебит*}
 If (DebitRazdel_Sn^.List<>Nil)And(DebitRazdel_Sn^.List^.Count>0) Then
  Begin
   For j:=0 To DebitRazdel_Sn^.List^.Count-1 Do
    Begin
     s1:=Copy(DebitRazdel_Sn^.GetText(j,DebitRazdel_Sn^.List^.Count),1,CRazdelKod);
     If s1=s Then
     l[3]:=1;
    End;
  End;
{Стоп проверки на дебит*}

{Старт проверки на дебит С/Ф Б}
 If (DebitSFBRazdel^.List<>Nil)And(DebitSFBRazdel^.List^.Count>0) Then
  Begin
   For j:=0 To DebitSFBRazdel^.List^.Count-1 Do
    Begin
     s1:=Copy(DebitSFBRazdel^.GetText(j,DebitSFBRazdel^.List^.Count),1,CRazdelKod);
     If s1=s Then
     l[2]:=1;
    End;
  End;
{Стоп проверки на дебит С/Ф Б}


End;
End;
BitToWord10(l,j);
PCluster(ControlSelect)^.SetButtonState(j, False);
Redraw;
For j:=1 To MAx10 Do
If l[j]=1 Then L[j]:=0
Else l[j]:=1;
BitToWord10(l,j);
PCluster(ControlSelect)^.SetButtonState(j, True);
Redraw;
End;
SetEnabledDoc(OperatorSelector);
End;



Procedure TSuperMarketWindow.FreshClient;
Var i : Byte;
    R : TRect;
    Cod : ArtikulStr;
Begin
DInfo('Обновляю список клиентов...');
R.Assign(0, 0, 0, 0);
Client := New(PBox, Init(R, 1, Nil));
Client^.NewList(New(PTextCollection, Init(0,1)));
{If Selector <>5 Then
Begin}
If OperatorSelector=0 Then
Assign (ClientFile,Path.ToClient+'Client.db')
Else
Assign (ClientFile,Path.ToClient+'Sklad.db');
{End
Else
Assign (ClientFile,Print.PathToMain+'Debit.db');}

I:=IOResult;
Reset (ClientFile);
I:=IOResult;
If i=0 Then
Begin
While Not(Eof(ClientFile)) Do
 Begin
     {
     Repeat
     Until NetCall.Lock(ClientFile,FilePos(ClientFile)*SizeOf(ClientType),SizeOf(ClientType));
     }
     ReadClient(ClientFile,ClientElement);
     {
     Repeat
      NetCall.UnLock(ClientFile,(FilePos(ClientFile)-1)*SizeOf(ClientType),SizeOf(ClientType));
     Until (DosError=0);
     }

  If ClientElement.Employ Then
   Begin
    Format (ClientElement.Name,CClient);
    Client^.List^.Insert(NewStr(ClientElement.Name+'│'+ClientElement.Kod));
    Client^.SetRange(Client^.List^.Count);
   End;
 End;
System.Close(ClientFile);
End
 Else
  MessageBox(^M+#3'Ошибка открытия файла клиентов!'^M+
  ClicProgrammer+' Код: ('+IntTostr(i,3)+')',Nil,mfError+mfCancelButton);
 If Not(SetLockNearClient(Client,0,OperatorSelector,Cod)) Then
  Begin
   NoInfo;
   Dispose(Client,Done);
   MessageBox(^M+#3'Не могу заблокировать ни одного клиента!',Nil,mfError+mfCancelButton);
   Exit;
  End;
Client^.FocusItem(Location(Client,Cod,False));

{Client^.FocusItem(0);}
PrevS:=Client^.GEtText(Client^.Focused,Client^.List^.COunt);
Dispose(Client,Done);
PStaticText(ControlClient)^.Text^:=#3+PrevS;
Redraw;
NoInfo;
End;


Procedure TSuperMarketWindow.SetMaska(O:Word);
Var R:TRect;
    Prevs : Byte;
    mm:Maska9;
    c,mmms:Word;
    Art : ArtikulStr;
Begin
Prevs:=O;
If O in [1,2,3,4,5,6,7] Then
   Begin
    ControlSelect^.GetData(Prom);
    O:=0;
    ControlSelect^.SetData(O);
    PCluster(ControlSelect)^.SetButtonState($000003FE, False);(*SetButtonState($fE, False);{3e}*)
    Inc(O);
    ControlSkidka^.SetData(O);
    PCluster(ControlSkidka)^.SetButtonState($5{1}, False);
    Skidka:=O;
    Redraw;
    If Prevs<>2 Then FreshClient;
    If Not((Prom=0)And(Selector=0)) Then
    Begin
    Selector:=0;
    SetEnabledDoc(OperatorSelector);
    Refresh(False);
    Redraw;
    End
     Else
     Begin
     Selector:=0;
     SetEnabledDoc(OperatorSelector);
     Refresh(False);
     CalcItogo(ItogNAlog);
     End;
   End
Else
   Begin

 {   WordToBit6(MasDocNumer,MM);}
{    For c:=1 To 6 Do
    If Mm[c]=1 Then Mm[c]:=0
    Else Mm[c]:=1;}
{
    For c:=1 To 7 Do
    if Mm[c]=1 Then Break;             }

{ убрана 25.11.98 за не нужность перерисовки номера накладной
PStaticText(ControlDoc)^.GetText(Art);
Dispose(ControlDoc,Done);
R.Assign(12, 0, 16, 1);
ControlDoc := New(PColoredText, Init(R, Art, $7E));
Insert(ControlDoc);
}

    Selector:=9;
    ControlSelect^.SetData(Selector);
    Skidka:=0;
    ControlSkidka^.SetData(Skidka);
    PCluster(ControlSelect)^.SetButtonState(255, True);{1e}
    PCluster(ControlSkidka)^.SetButtonState($5, True);
    Redraw;
    SetSelector;
    Redraw;
    FreshClient;
    Refresh(False);
    CalcItogo(ItogNAlog);
    {Refresh;}
   End;
End;

(*
Function TestMArketFromPrz(s:TMyString):Boolean;
Var SkKol,Nk_RZena,Sk_RZena,Nk_OZena,Sk_OZena : String[CZena];
    Sartikul: ArtikulStr;
    B : Boolean;
Begin
TestMArketFromPrz:=True;
{Розничная цена}
Nk_RZena:=Copy(s,1+CName+1+CArtikul+1+CKol+1+COne+1+CLitr+1+CZena+1+CZena+1+CInputIZena+1,CZena);
{Оптовая цена}
Nk_OZena:=Copy(s,1+CName+1+CArtikul+1+CKol+1+COne+1+CLitr+1+CZena+1+CZena+1+CInputIZena+1+CZena+1,CZena);
SArtikul:=Copy(s,1,CArtikul);
Sk_RZena:=BakGetField(FRZena,SArtikul,0);

If StrToReal(Sk_RZena)<0.01 Then
 Begin
 MessageBox(^M+#3+'Нулевая цена в позиции ('+Sartikul+')'^M+#3'Немедленно позовит программиста!',Nil,mfError+mfCancelButton);
 Exit;
 End;

Sk_OZena:=BakGetField(FOZena,SArtikul,0);
If StrToReal(Sk_OZena)<0.01 Then
 Begin
 MessageBox(^M+#3+'Нулевая цена в позиции ('+Sartikul+')'^M+#3'Немедленно позовит программиста!',Nil,mfError+mfCancelButton);
 Exit;
 End;

SkKol:=BakGetField(FKol,SArtikul,0);


If ((StrToReal(Nk_RZena)<>StrToReal(Sk_RZena)) And (StrToInt(SkKol)<>0)) Or
   ((StrToReal(Nk_OZena)<>StrToReal(Sk_OZena)) And (StrToInt(SkKol)<>0)) Then
   Begin
    B:=Not(TestMarket(SArtikul,PrevMarket,0,False));
    TestMarketFromPrz:=B;
    If B Then
    Begin
     SpecialBeep;
{    MessageBox(#3'Оптовая или розничная цена товара ('+SArtikul+') на складе не равна'+
     ' цене товара указанной в накладной!'^M+
     #3'ПРЕДЛОЖИ КЛИЕНТУ ПРОВЕСТИ ВОЗВРАТ ЗАВТРА!',Nil,mfError+mfCancelButton);}

     MessageBox(#3'Оптовая или розничная цена товара ('+SArtikul+') на скаде не равна'+
     ' цене товара указанной в накладной!'^M+
     #3'Перед коррекцией переоцени остатки!'^M+
     #3'НЕ ЗАБУДЬ ПРОВЕСТИ ОБРАТНУЮ ПЕРЕОЦЕНКУ!',Nil,mfError+mfCancelButton);
    End;
    {Если True значит переоценок не было и значит предупреждение на экран}
   End
Else
   TestMArketFromPrz:=False;
End;
*)


procedure TSuperMarketWindow.HandleEvent(var Event: TEvent);
Var R : TRect;
    test : Word;
    s,s1 : TMyString;
    l : Boolean;
    Nk_RZena,Nk_OZena : TDateString;
    {Rash : RashetType;}
    SDoc :ArtikulStr;
    SDate : TDateString;

begin
  Case Event.What Of
  evKeyDown :
  Case Event.KeyCode Of
     kbDel: Begin
     If (Prodaga^.State and sfFocused <> 0) And (Prodaga^.List<>Nil)And(Prodaga^.List^.Count>=1) Then
            Begin
              If MessageBox(#3+DelTovar,nil,mfConfirmation+mfOkCancel)=cmOk Then
               Begin
                l:=False;
                If Status=DocEdit Then
                Begin
{                s:=Copy(Prodaga^.GetText(Prodaga^.Focused,Prodaga^.List^.Count),1+CName+1,CArtikul);}
{                 s:=Prodaga^.GetText(Prodaga^.Focused,Prodaga^.List^.Count);}
                {l:=TestMarket(s,PrevMarket);}L:={TestMArketFromPrz(s);}False;
                End;
                If Not(l) Then
                Begin
                Prodaga^.List^.AtFree(Prodaga^.Focused);
                Prodaga^.SetRange(Prodaga^.List^.Count);
                If Prodaga^.Focused>0 Then Prodaga^.FocusItem(Prodaga^.Focused);

                If (Prodaga^.Focused>=Prodaga^.List^.Count) and(Prodaga^.Focused>0) Then
                Prodaga^.FocusItem(Prodaga^.Focused-1);

                SetSelector;
                FreshMarketHint;
                CalCItogo(ItogNAlog);
                Redraw;
                End;
               End;
              ClearEvent(Event);
            End;
            Redraw;
            AddName;
            End;
  kbCtrLDel: Begin
     If (Prodaga^.State and sfFocused <> 0) And (Prodaga^.List<>Nil)And(Prodaga^.List^.Count>=1) Then
            Begin
             If MessageBox(#3+DelAll,nil,mfConfirmation+mfOkCancel)=cmOk Then
             Begin
              L:=False;
{
              If Status=DocEdit Then
               Begin
                For Test:=0 To Prodaga^.List^.Count-1 Do
                 Begin
                  s:=Prodaga^.GetText(Prodaga^.Focused,Prodaga^.List^.Count);
                  L:=TestMArketFromPrz(s);
                  If L Then Break;
                 End;
               End;
}
               If Not (l) Then
                Begin
                 Prodaga^.NewList(nil);
                 Prodaga^.NewList(New(PTextCollection, Init(0,1)));
                 SetSelector;
                 FreshMarketHint;
                 CalCItogo(ItogNAlog);
                 AddName;
                 Redraw;
                End;
             End;
            End;
            End;
      kbF4: Begin
            If (Event.KeyCode=kbF4)And(Prodaga^.State and sfFocused <> 0) And (Prodaga^.List<>Nil)
               And (Prodaga^.List^.Count>=1)  Then
            Begin
              s:=Prodaga^.GetText(Prodaga^.Focused,Prodaga^.List^.Count);
              s1:=Copy(s,1{+CName+1},CArtikul);
              l:=False;
              If Status=DocEdit Then l:=TestMarket(s1,PrevMarket,0,True);
              If Not(l) Then
              Begin
              Mark^.Ini(s,1);
              SetSelector;
              FreshMarketHint;
              CalcItogo(ItogNAlog);
              Redraw;
              End;
              ClearEvent(Event);
            End;
              ClearEvent(Event);
            Redraw;
            End;
  kbEnter:    Begin
     If (Baz^.State and sfFocused <> 0) And (Baz^.List<>Nil)And(Baz^.List^.Count>=1) Then
            Begin
     If (Baz^.State and sfFocused <> 0) And (Baz^.List<>Nil)And(Prodaga^.List^.Count>CMax-1) Then
              Begin
      MessageBox(#3^M+#3'В документе может быть'^M+
                 #3'не более '+ IntToStr(CMax,2)+' наименований !',Nil,mfError+mfCanCelButton);
               ClearEVent(Event);
               Exit;
              End;
              s:=Copy(Baz^.GetText(Baz^.Focused,Baz^.List^.Count),1+CName+1,CArtikul);
              s1:=Copy(Baz^.GetText(Baz^.Focused,Baz^.List^.Count),1+CName+1+CArtikul+1,COne);
              If TestProdaga(S,s1,Prodaga) Then
               Begin
                l:=False;
                If Status=DocEdit Then l := TestMarket(s,PrevMarket,0,True);
                If Not(l) Then
                Begin
                s:=Baz^.GetText(Baz^.Focused,Baz^.List^.Count);
                Mark^.Ini(s,0);
                SetSelector;
                CalcItogo(ItogNAlog);
                AddName;
                If (Baz^.Focused+1)<Baz^.List^.Count Then
                 Begin
                 Baz^.FocusItem(Baz^.Focused+1);
                 End;
                Redraw;
                FreshMarketHint;
                End;
                ClearEvent(Event);
               End
              Else
              Begin
               MessageBox(#3^M+#3'Товар с кодом '+s+' (отделение '+S1+') уже есть в накладной !',Nil,mfError+mfCanCelButton);
              End;
              ClearEVent(Event);
            End;

            If (Event.KeyCode=kbEnter)And(Prodaga^.State and sfFocused <> 0) And (Prodaga^.List<>Nil)
               And (Prodaga^.List^.Count>=1)  Then
            Begin
              s:=Prodaga^.GetText(Prodaga^.Focused,Prodaga^.List^.Count);
              s1:=Copy(s,1{+CName+1},CArtikul);
              l:=False;
              If Status=DocEdit Then l:=TestMarket(s1,PrevMarket,0,True);
              If Not(l) Then
              Begin
              Mark^.Ini(s,1);
              SetSelector;
              FreshMarketHint;
              CalcItogo(ItogNAlog);
              Redraw;
              End;
              ClearEvent(Event);
            End;

            {ClearEvent(Event);}
            End;
  kbAltRus,
  kbAltRusSh1,
  kbCtrlRusSh1,
  kbCtrlRusSh:Begin
              Event.What:=evCommand;
              Event.Command:=CmChangeShkala;
              PutEvent(Event);
              End;

  kbF5     :Begin
             PStaticText(Control_I)^.GetTExt(s);
             If Pos(#3,s)>0 Then System.Delete(s,1,1);
             PStaticText(ControlItogoSkidka)^.GetTExt(s1);
             If Pos(#3,s1)>0 Then System.Delete(s1,1,1);

             s:=' Всего сумма:'+s+'   Скидка:'+S1;
             {Вставить номер и дату документа в просмотре}

             PStaticText(ControlMesto)^.GetTExt(s1);
             If Pos(#3,s1)>0 Then System.Delete(s1,1,1);
             s:=s+'    Всего мест:'+s1;




             If Status=DocEdit Then
              Begin
               SDoc:=PrevMarket^.Dat.Document;
               SDate:=PrevMarket^.Dat.DateC;
              End
              Else
              Begin
               PStaticText(ControlDoc)^.GetTExt(sdoc);
               If Pos(#3,sdoc)>0 Then System.Delete(sdoc,1,1);
               SDate:=FDate;
              End;

             FullScreen(Prodaga,' Код  Выбранн~ы~е товары           N Колич Литр.   Цена    Скидка  Итого',s,
             SDoc,SDate,0);
            End;
     kbEsc: Begin
              Event.What:=evCommand;
              Event.Command:=cmCancel;
              PutEvent(Event);

            End;
     kbAltSpace,kbCtrlRusN:
     Begin
      Refresh(False);
      FreshSkladHint;
     End;
      Else;
      End;{KeyDown}
  evCommand :
     Case Event.Command Of
     cmSuperMarket: Begin
                 ClearEvent(Event);
                End;
  cmRefresh :
     Begin
      Refresh(False);
      FreshSkladHint;
     End;

  cmSelectClient:
 Begin
  If (PView(Cl)<>Desktop^.TopView)And(ControlClient^.State and sfFocused <> 0) Then
  Begin
     PStaticText(ControlClient)^.GetText(S);
     System.Delete(S,1,1);
     {If Selector<>5 Then l:=False
     Else} l:=True;

     If Status=DocNormal Then
     Begin
     Repeat
     Until (SetClientUnLock(Copy(s,1+CClient+1,CClientKod),0,OperatorSelector));
     Cl^.ShowClientList(s,OperatorSelector,0,L,True,-1,-1,-1,-1,Test);
     End
     Else
      Begin
       If Not((PrevMarket^.Dat.ClientKod=Copy(s,1+CClient+1,CClientKod))
        And(PrevMarket^.Dat.OperatorSelector=OperatorSelector)) Then
        Begin
         Repeat
         Until (SetClientUnLock(Copy(s,1+CClient+1,CClientKod),0,OperatorSelector));
        End;
       Cl^.ShowClientList(s,OperatorSelector,0,L,True,StrToInt(PrevMarket^.Dat.ClientKod),
                               PrevMarket^.Dat.OperatorSelector,-1,-1,Test);
      End;

     ClientShkala:=StrToInt(GetClientField(FShkala,Copy(s,1+CClient+1,CClientKod),OperatorSelector));
     CalcItogo(ItogNAlog);
     PStaticText(ControlClient)^.Text^:=#3+S;
     Redraw;
     Case Test Of
      0,3 :FocusNext(True);
      1,2 :FocusNext(False);
     Else;
     End;
     If Selector in[5..8] Then
     Begin
      s1:=Copy(s,1+CClient+1,CClientKod);
      If Not(TestDolgClient(s1)) Then
      Begin
      SpecialBeep;
       MessageBox(#3'За клиентом числится просроченный не'+
     'оплаченный документ консигнации!'^M+
     #3'Возможно не следует выдавать ему товар на консигнацию!',Nil,mfWarning+mfCancelButton);
      End;

      {предупреждение для дебита}
{
      If Selector=6 Then
      If DefaultLiZensia=1 Then
      Begin
       s1:=Copy(s,1+CClient+1,CClientKod);
       If Not(TestSrokLizensia(s1,TEkDate)) Then
       Begin
       SpecialBeep;
       MessageBox(#3+'У клиента просрочена лицензия или не указан срок ее действия!'^M+
         #3+'Нельзя отпускать ему товар на С/Ф!',Nil,mfError+mfCancelButton);
       End;
      End;
}

  If StrToInt(GEtClientField(FDebit,S1,0))<>1 Then
   Begin
    MessageBox(^M+#3+'Клиенту запрещено отпускать товар на консигнацию!',Nil,mfError+mfCancelButton);
   End;


     End;

     {с/ф продажи}
      If DefaultLiZensia=1 Then
      Begin
     If Selector in [3,4,6,8] Then
      Begin
       s1:=Copy(s,1+CClient+1,CClientKod);
       If Not(TestSrokLizensia(s1,TekDate)) Then
        Begin
        SpecialBeep;
        MessageBox(#3+'У клиента просрочена лицензия или не указан срок ее действия!'^M+
         #3+'Нельзя отпускать ему товар на С/Ф!',Nil,mfError+mfCancelButton);
       End;

      End;
      End;
     ClearEvent(Event);
  End
  Else
   ClearEvent(Event);
 End;

     cmOk : Begin
               If ((Prodaga^.List<>Nil)And(Prodaga^.List^.Count>0))Or(Status=DocEdit) Then
               Begin
             If Selector=9 Then
              Begin
               Sound(100);
               DinfoMsg('Внимание! В окне продаж не определен вид документа...');
               Delay(700);
               NoSound;
                repeat
                  Application^.GetEvent(Event);
                {until (Event.What in [evKeyDown,evMouseDown]);}
                until (Event.What <> evNothing)And(Event.Command<>cmMenu);

               NoInfoMsg;
               ClearEvent(Event);
               Exit;
              End;


               PStaticText(ControlClient)^.GetText(S);
               System.Delete(S,1,1);
               DelSpace(s);
               If OperatorSelector=1 Then
               If StrToInt(Rek.Kod)=StrToInt(Copy(s,1+CClient+1,CClientKod)) Then
                Begin
               Sound(100);
               DinfoMsg('Ошибка! Нельзя отгружать товар внутреннему клиенту с кодом '+
                        Copy(s,1+CClient+1,CClientKod)+'...');
               Delay(700);
               NoSound;
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
{
             PStaticText(Control_I)^.GetTExt(s);
             If Pos(#3,s)>0 Then System.Delete(s,1,1);
             Str(StrToReal(S):CIZena:CMantissa,s);
             DelSpace(s);
             PStaticText(ControlItogoSkidka)^.GetTExt(s1);
}
             PStaticText(Control_I)^.GetTExt(s);
             If Pos(#3,s)>0 Then System.Delete(s,1,1);
             PStaticText(ControlItogoSkidka)^.GetTExt(s1);
             If Pos(#3,s1)>0 Then System.Delete(s1,1,1);
             s:=' Всего сумма:'+s+'   Скидка:'+S1;

             PStaticText(ControlMesto)^.GetTExt(s1);
             If Pos(#3,s1)>0 Then System.Delete(s1,1,1);
             s:=s+'    Всего мест:'+s1;

             {Вставить номер и дату документа в просмотре}
             If Status=DocEdit Then
              Begin
               SDoc:=PrevMarket^.Dat.Document;
               SDate:=PrevMarket^.Dat.DateC;
              End
              Else
              Begin
               PStaticText(ControlDoc)^.GetTExt(sdoc);
               If Pos(#3,sdoc)>0 Then System.Delete(sdoc,1,1);
               SDate:=FDate;
              End;

         If  FullScreen(Prodaga,' Код  Выбранн~ы~е товары           N Колич Литр.   Цена    Скидка  Итого',s,
         SDoc,SDate,1) Then
                Begin
                 L:=False;
                 SaveToFile(L);
                 If Not(L) Then
                           Begin
                            CalcItogo(ItogNalog);
                   AddName;
                   FreshMArketHint;
                   Redraw;
                  End;
                 If L Then
                 Begin
                  PStaticText(ControlClient)^.GetText(S);
                  System.Delete(S,1,1);
                  Repeat
                  Until (SetClientUnLock(Copy(s,1+CClient+1,CClientKod),0,OperatorSelector));
                  Dispose(TChekRazdel,Done);
                  Dispose(SpisokRazdel,Done);
                  Dispose(SFRazdel,Done);
                  Dispose(SFBRazdel,Done);
                  Dispose(DebitRazdel,Done);
                  Dispose(DebitSFRazdel,Done);
                  Dispose(DebitRazdel_Sn,Done);
                  Dispose(DebitSFBRazdel,Done);
                  Dispose(FZRazdel,Done);
                  Event.What:=evCommand;
                  Event.Command:=cmClose;
                  PutEvent(Event);
                  If Status = DocEdit Then
                            Begin
                    If Not((StrToInt(Copy(s,1+CClient+1,CClientKod))=StrToInt(PrevMarket^.Dat.ClientKod))
                       And (OperatorSelector=PrevMarket^.Dat.OperatorSelector)) Then
                    Repeat
                    Until (SetClientUnLock(PrevMarket^.Dat.ClientKod,0,PrevMarket^.Dat.OperatorSelector));
                             Dispose(PrevMarket,Done)
                            End
                 Else
                 Begin
                  Event.What:=evCommand;
                  Event.Command:=cmSuperMarket;
                  PutEvent(Event);
                 End;
                 ProdagaWindow:=False;
                 Status:=DocNormal;
                 TekDate := FDate;
                End
                 Else ClearEvent(Event);
                End;
               End
               Else
                MessageBox(#3+NoClient+''^M+#3+NoInput,Nil,mfError+mfOkCancel)
               End;
            End;
  cmChangeShkala:
              Begin
              If Skidka=2 Then
              Begin
               Test:=ClientShkala;
               If SelectShkala(Test) Then
               Begin
                ClientShkala:=Test;
                CalcItogo(ItogNAlog);
                Redraw;
               End;
              End;
               ClearEvent(Event);
              End;

  cmCancel : Begin
               l:=False;
               If (Prodaga^.List<>Nil)And(Prodaga^.List^.Count>0) Then
If MessageBox(#3^M+#3'Желаете отказаться от продажи/корректировки продажи ?',Nil,mfConFirmation+mfOkCancel)<>cmOk
             Then
               Begin
                l:=True;
               End;
               If Not(L) Then
                Begin
                 PStaticText(ControlClient)^.GetText(S);
                 System.Delete(S,1,1);
                 Repeat
                 Until (SetClientUnLock(Copy(s,1+CClient+1,CClientKod),0,OperatorSelector));
                  Dispose(TChekRazdel,Done);
                  Dispose(SpisokRazdel,Done);
                  Dispose(SFRazdel,Done);
                  Dispose(SFBRazdel,Done);
                  Dispose(DebitRazdel,Done);
                  Dispose(DebitSFRazdel,Done);
                  Dispose(DebitRazdel_Sn,Done);
                  Dispose(DebitSFBRazdel,Done);
                  Dispose(FZRazdel,Done);
                 If Status = DocEdit Then
                  Begin
                    If Not((StrToInt(Copy(s,1+CClient+1,CClientKod))
                                       =StrToInt(PrevMarket^.Dat.ClientKod))
                       And (OperatorSelector=PrevMarket^.Dat.OperatorSelector)) Then
                       Repeat
                       Until (SetClientUnLock(PrevMarket^.Dat.ClientKod,0,PrevMarket^.Dat.OperatorSelector));
                       Repeat
                       Until (UnLockMarket(PrevMarket^.Dat.Document,PrevMarket^.Dat.DateC) in [0,2]);
                                Dispose(PrevMarket,Done);
                  End;



                 Event.What:=evCommand;
                 Event.Command:=cmClose;
                 PutEvent(Event);
                 ProdagaWindow:=False;
                 Status:=DocNormal;
                 TekDate := FDate;
                End;
                 ClearEvent(Event);
                End;

      Else;
      End;{evCommand}
      Else;
      End;{*Case*}
 if (Event.What = evBroadcast) and
     (Event.Command = cmSuperMarket) then ClearEvent(Event);

 If (PView(Cl)<>Desktop^.TopView)And(ControlClient^.State and sfFocused <> 0)
 And (Event.Command<>cmSelectClient) And (Event.What <> EvKeyDown)Then
            Begin
             Event.What:=EvCommand;
             Event.Command:=cmSelectClient;
             PutEvent(Event);
             ClearEvent(Event);
            End;
  inherited HandleEvent(Event);
 If (Desktop^.Current=PView(SuperMarketWindow)) And (Event.What <> EvKeyDown) Then
           Begin
              if Not(Prodaga^.State and sfFocused <> 0)Then
              Begin
                   ProdagaWindow:=False
              End
              Else
                   ProdagaWindow:=True;

              if (Baz^.State and sfFocused <> 0)  And(Baz^.List<>Nil) And (Baz^.List^.Count>=1)Then
              Begin
               s:=Baz^.GetText(Baz^.Focused,Baz^.List^.Count);
               If s <> PrevS Then
                 Begin
                  PrevS:=Copy(s,1+CName+1,CArtikul);
                  s1:=BakGetField(FSertif,Prevs,0);
                  DelSpaceRight(s1);
                  If s1[0]=#0 Then s1:=Netu
                  Else s1:=Est;
                  S:=BakGetField(FAkzis,Prevs,0);
                  DelSpaceRight (S);
                  Dispose(ControlSertif,Done);
                  R.Assign(36, 21, 40, 22);
                  ControlSertif := New(PColoredText, Init(R, S1, $7E));
                  Insert(ControlSertif);
                  FreshSkladHint;
                  PrevS:=Baz^.GetText(Baz^.Focused,Baz^.List^.Count);
                End
              End;

              if (Prodaga^.State and sfFocused <> 0)  And(Prodaga^.List<>Nil) And (Prodaga^.List^.Count>=1)Then
              Begin
               s:=Prodaga^.GetText(Prodaga^.Focused,Prodaga^.List^.Count);
               ProdagaWindow:=True;
               If s <> PrevSMarket Then
                 Begin
                 FreshMarketHint;
                 End
              End;

          if (ControlOperatorSelect^.State and sfFocused <> 0)Then
              Begin
               ControlOperatorSelect^.GetData(Test);
               If Test <> OperatorSelector Then
               Begin

    {Вставить код деблокирования предыдущего клиента если это
     не PrevMarket}
     L:=True;
     PStaticText(ControlClient)^.GetText(S);
     System.Delete(S,1,1);


     ClientShkala:=StrToInt(GetClientField(FShkala,Copy(s,1+CClient+1,CClientKod),OperatorSelector));
     CalcItogo(ItogNAlog);

     If Status=DocNormal Then
     Begin
      Repeat
      Until (SetClientUnLock(Copy(s,1+CClient+1,CClientKod),0,OperatorSelector));
     End
     Else
      Begin
       If Not((PrevMarket^.Dat.ClientKod=Copy(s,1+CClient+1,CClientKod))
        And(PrevMarket^.Dat.OperatorSelector=OperatorSelector)) Then
        Begin
         Repeat
         Until (SetClientUnLock(Copy(s,1+CClient+1,CClientKod),0,OperatorSelector));
        End;
      End;
                OperatorSelector:=Test;
                SetMaska(OperatorSelector);
                EDAutoSkidka;
                Redraw;
               End;
              End;

          if (ControlSelect^.State and sfFocused <> 0)Then
              Begin
               ControlSelect^.GetData(Prom);
               If Prom <> Selector Then
               Begin
{               If ((Prom=4) And (Selector=3))Or
                   ((Prom=3) And (Selector=4))
                    Then
                Selector:=Prom
                Else}
                Begin
                  Selector:=Prom;
                  Refresh(False);
                  EDAutoSkidka;
                  Redraw;
                End;
               End;
              End;

          if (ControlSkidka^.State and sfFocused <> 0)Then
              Begin
               ControlSkidka^.GetData(Test);
               If Test <> Skidka Then
               Begin
                  Skidka:=Test;
                  {Sbros;}
                  CalcItogo(ItogNAlog);
                  Redraw;
               End;
              End;
          If Skidka in [0,1] Then
           DisableCommands([cmChangeShkala])
          Else
           EnableCommands([cmChangeShkala]);

          End;

end;


End.