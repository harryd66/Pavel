{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}


{$I Compile.INC}

Unit Market;

Interface


Uses Dialogs,Drivers,Glob,Access1,Access,ServStr,MyCalc,Views,SertMrk;


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


Type
  PSuperMarketWindow = ^TSuperMarketWindow;
  TSuperMarketWindow = object(TDialog)
    Ag   : PAgentWindow;
    Cl   : PClientWindow;
    Mark : PMarketWindow;
    NetTest :PNetTestWindow;
    constructor Init(Var l: Boolean);
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure AddName;
    {Procedure SetEnabledDoc(i:Byte);}
    procedure OpenSuperMarketWindow;
    Function  CalcItogo (Var ItogNalog:NalogType): Real;
    Procedure SaveToFile(Var Save : Boolean);
    Procedure Refresh(REgim:Boolean);
    Procedure FreshClient;
    Procedure SetMaska(O:Word);
    Procedure FreshComment(Kod:ArtikulStr;OperatorSelector:Word);
    Procedure FreshMarketHint;
    Procedure FreshSkladHint;
    Procedure FreshShkala;
    Procedure DrawFullName;
{   Procedure Sbros;}
    Procedure SetSelector;
    end;


Var ControlSelect : PView;

 Implementation

uses App,DBEngine,Objects, MsgBox,Vision1,Vision5,Nastr,Protect,{Calc,}NetCall,Windos,
     MrkTool,UtilsP,Utils2,
     Utils,ColorTxt,Serv,InpLong,Validate,CPrihod,TpDate,Net,NetDbEng;

Type MW = Record
     Pack   : Word;
     Kol    : String[CKol];
     Zena   : String[CZena];
     Skidka : String[CZena];
     End;

Const Est='Е';
      Netu='Н';

Const ReadOnly=0+$42 {на самом деле не ReadOnly a DenyNone
                      открытие на чтениеи запись но всем разрешено все};

var
 Control1Skidka,
 ControlFullName,ControlSkidka,ControlKol,Pack,ControlItogoSkidka,
 ControlRegion,
 ControlLS,Control_Litr,ControlSertif,{ControlAkzis,}ControlOperatorSelect,
 ControlDoc,Control_I,ControlCurrent,ControlPack,ControlClient,
 ControlBKol,ControlBZena ,ControlProdagaSkidka,ControlProdagaZena,ControlMesto,
 ControlSpecNalog,ControlError,ControlNetNDS,ControlNetKol,ControlNetZena,
 ControlAgent,ControlSrok,ControlMsg,ControlSpecZ,ControlZen,ControlZakupka,
 ControlZak,ControlPPP,
 ControlDost,
 ControlNetNalog,ControlShkala: PView;
{ Mark : PMarketWindow;}

 MarketWin : PMarketWindow;
 SuperMarketWindow : PSuperMarketWindow;
 NetTestWindow : PNetTestWindow;
 NetTestBox : PBox;
 InputPassword: Boolean;
 PrevS,SZakupka : string[100];
 PrevNet,PrevSMarket,PrevAgent :string[100];
 SOtd,SArtikul : String[CArtikul];
 PrevCl: string[CCLientKOd];
 El : MW;
 ClientShkala,Selector,Skidka,DostSel,
 SpecZ,OperatorSelector,SF,Prom   : Word;
 PrevKolPack : Byte;
 PrevKol : String[CKol];
 Information,DebInfo : Boolean;
 VidRashet : Word;
 ActiveOtdel :String[CKol];
 ItogNalog:NalogType;
 PrevName : string[100];
 SSrok : String[3];
 SDost : String[1];
 Region : Word;
 ShowSZena : Boolean;
 SpecRazdel: word;
 Realiz: word;
 {ssName: string[CName];
 ssArtikul: string[CArtikul];}


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
    Proz,Zena : TDAteString;
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
Zena:=BakGetField(FRZena,PrevS,0)
Else
Zena:=BakGetField(FOZena,PrevS,0);

{$IFDEF Opt}
Str((GetShkalaProz(PrevS,1,0,'0999')):CLitr+1:CMantissa+2,Proz);
{$ELSE}
Str((GetShkalaProz(PrevS,5,0,'0999')):CLitr+1:CMantissa+2,Proz);
{$ENDIF}
DelSpace(Proz);



Str(StrToReal(Zena)*(StrToReal(Proz)):CZena:CMAntissa,PrevS);

DelSpace(PrevS);
Format(PrevS,CZena);
ControlBZena := New(PColoredText, Init(R, #3+PrevS, $7E));
Insert(ControlBZena);
End;

End;


Procedure TSuperMarketWindow.FreshShkala;
Var R : TRect;

Begin
(*Dispose(ControlShkala,Done);
R.Assign(39, 21, 49, 22);

If Skidka in [2] Then
Begin
If ClientShkala>0 Then
Begin
ControlShkala := New(PColoredText, Init(R, #3+'Шкл '+
IntToStr(ClientShkala-(6*Region),CMantissa)+'('+IntToStr(ClientShkala,CMantissa)+')', $5F))
End
 Else
 ControlShkala := New(PColoredText, Init(R, #3+'Шкл 0(0)', $5F))
End
Else
ControlShkala := New(PColoredText, Init(R, '', $74));
Insert(ControlShkala);  *)
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


Procedure TSuperMarketWindow.DrawFullName;
Var S: String;
         R : TRect;
         SArt : ArtikulStr;
Begin
if (Prodaga^.State and sfFocused <> 0)  Then
Begin
If (Prodaga^.List<>Nil)And(Prodaga^.List^.Count>=1) Then
Begin
s:=Prodaga^.GetText(Prodaga^.Focused,Prodaga^.List^.Count);
If s<>PrevName Then
Begin
 PrevName:=s;
 Sart:=Copy(s,1,CArtikul);
 Dispose(ControlFullName,Done);
 R.Assign(22, 20, 79, 21);
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
 R.Assign(22, 20, 79, 21);
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
 R.Assign(22, 20, 79, 21);
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
 R.Assign(22, 20, 79, 21);
 s:=' ';
 ControlFullName := New(PColoredText, Init(R, s, $7e));
 Insert(ControlFullName);
  End;
End;

if (Baz^.State and sfFocused = 0) And (Prodaga^.State and sfFocused = 0)Then
 Begin
 PrevName[0]:=#0;
 Dispose(ControlFullName,Done);
 R.Assign(22, 20, 79, 21);
 s:=' ';
 ControlFullName := New(PColoredText, Init(R, s, $7e));
 Insert(ControlFullName);
 End;

End;


Procedure TNetTestWindow.Refresh;
Var r :TRect;
    Ansver,Res : String[150];
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
  1:Ansver:=Ansver+'запр.к продаже; ';
  2:Ansver:=Ansver+'нет необх.колич.; ';
  3:Ansver:=Ansver+'изм.цена; ';
  4:Ansver:=Ansver+'изм.НДС; ';

  5: Ansver:=Ansver+'изм.вид НДС; ';
  6: Ansver:=Ansver+'изм.НП; ';
  7: Ansver:=Ansver+'изм.вид НП; ';
  8: Ansver:=Ansver+'изм.скид.; ';
  9: Ansver:=Ansver+'изм.закуп.; ';
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


Procedure NetChangeProdaga(A,otd:allstr;Vid:Byte;Znashenie:AllStr);
Var Count : Word;
    s : String[150];
    find : boolean;
    FindArt,FindOtd:ArtikulStr;
    Summa : String[CInputIZena];
    SRZena,SOZena,Zena:String[CZena];
Begin
Find:=False;
{$IFDEF DPMI}
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
{     MessageBox(#3'Позиция '+A+' из отделения '+Otd+' не найдена!'^M+
        ClicProgrammer,Nil,mfError+mfCancelButton);
}     Exit;
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
         CZena+1+CZena+1+CLitr+1+COne+1+(CLitr+1)+1+COne+1,CZena);
      Insert(Znashenie,s,1+CName+1+CArtikul+1+COne+1+CKol+1+CLitr+1+CZena+1+CZena+1+CInputIZena+1+
         CZena+1+CZena+1+CLitr+1+COne+1+(CLitr+1)+1+COne+1);
     End;
   Else;
   End;{Case}
   Prodaga^.List^.AtFree(Count);
   Prodaga^.SetRange(Prodaga^.List^.Count);
   Prodaga^.List^.Insert(NewStr(S));
   Prodaga^.SetRange(Prodaga^.List^.Count);
 End;
{$ENDIF}
End;




Function TNetTestWindow.Start(L:PSuperMarketType;Itog:Real;LockBox:PBox):Boolean;
Label 1,2;
Var R:TRect;
    Control : PView;
    ssk,ErrorStr:AllStr;
    s,Msg:String[150];
    i : Word;
    FindError:Boolean;
    Temp : PBox;
    sklad,res:longint;
    StopProcess,LogikZena : boolean;
Begin
Start:=True;
{$IFNDEF Kurz}
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
StopProcess:=False;
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
     res:=GetKolMarket(L^.Dat.MarketElement[i].BazKod,L^.Dat.MarketElement[i].Input.DiviSionSNumber,PrevMarket);
     Res:=StrToInt(L^.Dat.MarketElement[i].Input.Kol)-res;
     sklad:=StrToInt(BakGetField(FDiv,L^.Dat.MarketElement[i].BazKod,L^.Dat.MarketElement[i].Input.DiviSionSNumber));
     If (Sklad-res)<0 Then
     Begin
      ErrorStr:=ErrorStr+'2';
      Msg:=IntToStr(Sklad,CKol);
      DelSpace(Msg);
      NetChangeProdaga(L^.Dat.MarketElement[i].BazKod,IntToStr(L^.Dat.MarketElement[i].Input.DiviSionSNumber,COne),2,Msg);
     End;

     {изменена цена оптовая или розничная}
     If Status=DocNormal Then LogikZena:=True
     Else
      Begin
       {проверяем бала ли позиция в накладной}
       LogikZena:=Not FindMarket(L^.Dat.MarketElement[i].BazKod,PrevMarket);
       If LogikZena Then{если позиции не бало в накладной}
        Begin
       (*
         LogikZena:=TestMarket(L^.Dat.MarketElement[i].Bazkod,PrevMarket,0,True);
         {если была переоценка после выписки накладной тогда остановить процесс
            и запретить выписку товара LogikZena=True}
         If Not(LogikZena) Then StopProcess:=True;
         If Not(LogikZena) Then FindError:=True;
         If Not(LogikZena) Then Goto 2;
          *)
         if TestMarket(L^.Dat.MarketElement[i].Bazkod,PrevMarket,0,True) then
           begin
            StopProcess:=True;
            FindError:=True;
            Goto 2;
           end;
         LogikZena:=True;
        End
       Else             {если позиция была в накладной}
        Begin
                                                                      {не выводить сообщение}
          If Not(TestMarket(L^.Dat.MarketElement[i].Bazkod,PrevMarket,0,False)) Then
            Begin{если переоценки после выписки первого варианта не было}
             LogikZena:=False;
            End
                Else
                  Begin{если переоценка была после выписки}
             If GetFullKolMArket(L^.Dat.MarketElement[i].Bazkod,L)>
                GetFullKolMArket(L^.Dat.MarketElement[i].Bazkod,PrevMarket) Then
               Begin{если количество новое изменилось в большую сторону}
                LogikZena:=FAlse;
                StopProcess:=True;
                FindError:=True;
               MessageBox(#3+'Товар с кодом ('+L^.Dat.MarketElement[i].Bazkod+') после выписки документа уже был переоценен! '
			,Nil,mfError+mfCancelButton);
                Goto 2;
               End{конец уловия если новое количество не изменилось}
              Else
               Begin{если новое количество не изменилось или стало меньше}
                LogikZena:=False;
               End;
                  End;
        End;{Else если позиция была в наклдной}
      End;{Status=DocEdit}
{Алгоритм проверки:
1 позия была в накладной?
 да - была ли переоценка?
  да - новое количество больше старого?
   да - запрет выписки!
  нет - цену не проверяем
 нет - проверяем цену
...}
     If LogikZena Then
     If((StrToReal(BakGetField(FRZena,L^.Dat.MarketElement[i].BazKod,0)))<>
           (StrToReal(L^.Dat.MarketElement[i].Input.R_Zena))) Or
       ((StrToReal(BakGetField(FOZena,L^.Dat.MarketElement[i].BazKod,0)))<>
           (StrToReal(L^.Dat.MarketElement[i].Input.O_Zena))) Then
        Begin
         ErrorStr:=ErrorStr+'3';
         Msg:=BakGetField(FRZena,L^.Dat.MarketElement[i].BazKod,0);
         DelSpace(Msg);
         NetChangeProdaga(L^.Dat.MarketElement[i].BazKod,IntToStr(L^.Dat.MarketElement[i].Input.DiviSionSNumber,COne),3,Msg);
         Msg:=BakGetField(FOZena,L^.Dat.MarketElement[i].BazKod,0);
         DelSpace(Msg);
         NetChangeProdaga(L^.Dat.MarketElement[i].BazKod,IntToStr(L^.Dat.MarketElement[i].Input.DiviSionSNumber,COne),3,Msg);
        End;
     {изменена ставка ндс}
    If Status<>DocEdit Then
     If (StrToReal(GetIDField(FNDS,L^.Dat.MarketElement[i].BazKod)))<>
        (StrToReal(L^.Dat.MarketElement[i].Input.NDS)) Then
        Begin
{        ErrorStr:=ErrorStr+'4';}
         Msg:=GetIDField(FNDS,L^.Dat.MarketElement[i].BazKod);
         DelSpace(Msg);
         NetChangeProdaga(L^.Dat.MarketElement[i].BazKod,IntToStr(L^.Dat.MarketElement[i].Input.DiviSionSNumber,COne),4,Msg);
        End;
     {изменен вид ндс}
    If Status<>DocEdit Then
     If (StrToInt(GetIDField(FVidNDS,L^.Dat.MarketElement[i].BazKod)))<>
           (L^.Dat.MarketElement[i].Input.VidNDS) Then
        Begin
{        ErrorStr:=ErrorStr+'5';}
         Msg:=GetIDField(FVidNDS,L^.Dat.MarketElement[i].BazKod);
         DelSpace(Msg);
         NetChangeProdaga(L^.Dat.MarketElement[i].BazKod,IntToStr(L^.Dat.MarketElement[i].Input.DiviSionSNumber,COne),5,Msg);
        End;
     {изменена ставка нп}
    If Status<>DocEdit Then
     If (StrToReal(GetIDField(FNalog,L^.Dat.MarketElement[i].BazKod)))<>
        (StrToReal(L^.Dat.MarketElement[i].Input.SpecNalog)) Then
        Begin
        {ErrorStr:=ErrorStr+'6';}
         Msg:=GetIDField(FNalog,L^.Dat.MarketElement[i].BazKod);
         DelSpace(Msg);
         NetChangeProdaga(L^.Dat.MarketElement[i].BazKod,IntToStr(L^.Dat.MarketElement[i].Input.DiviSionSNumber,COne),6,Msg);
        End;

     {изменен вид нп}
    If Status<>DocEdit Then
     If (StrToInt(GetIDField(FVidNalog,L^.Dat.MarketElement[i].BazKod)))<>
        (L^.Dat.MarketElement[i].Input.VidNAlog) Then
        Begin
         {ErrorStr:=ErrorStr+'7';}
         Msg:=GetIDField(FVidNalog,L^.Dat.MarketElement[i].BazKod);
         DelSpace(Msg);
         NetChangeProdaga(L^.Dat.MarketElement[i].BazKod,IntToStr(L^.Dat.MarketElement[i].Input.DiviSionSNumber,COne),7,Msg);
        End;

     {изменена таблица авто-скидок}
     {If Skidka=0 Then}
(*
     Str((GetSkidkaProz(L^.Dat.MarketElement[i].BazKod,Itog)):CLitr+1:CMantissa+2,Msg);
     If Skidka=2 Then
     Str((GetShkalaProz(L^.Dat.MarketElement[i].BazKod,ClientShkala)):CLitr+1:CMantissa+2,Msg);
     DelSpace(msg);
     If (Msg<>L^.Dat.MarketElement[i].Input.proz) Then ErrorStr:=ErrorStr+'8';
*)


     {изменена закупочная цена}
     If (StrToReal(BakGetField(FZakupka,L^.Dat.MarketElement[i].BazKod,0)))<>
        (StrToReal(L^.Dat.MarketElement[i].Input.Zakupka)) Then
        Begin
        {ErrorStr:=ErrorStr+'9';}
         Msg:=BakGetField(FZakupka,L^.Dat.MarketElement[i].BazKod,0);
         DelSpace(Msg);
         NetChangeProdaga(L^.Dat.MarketElement[i].BazKod,IntToStr(L^.Dat.MarketElement[i].Input.DiviSionSNumber,COne),9,Msg);
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
       Format(L^.Dat.MarketElement[i].Input.Proz,CLitr+1);
       DelSpace(L^.Dat.MarketElement[i].Input.Zakupka);
       Format(L^.Dat.MarketElement[i].Input.Zakupka,CZena);
       s:=s+'│'+L^.Dat.MarketElement[i].BazKod+'│'+IntToSTr(L^.Dat.MarketElement[i].Input.DivisionSNumber,COne)+'│'
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

2:
UnLockAllPosition(LockBox);

If StopProcess Then
 Begin
  Dispose(Temp,Done);
  Start:=False;
  Exit;
 End;


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

{$ENDIF}
End;


Procedure TNetTestWindow.HandleEvent(Var Event:TEvent);
Var s: String;
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
    Scl,s2,s : String;
    ws : AllStr;
    PereozenkaElement :PPereozenkaType;
    PereozenkaFile : File Of PereozenkaType;
    As : DocumentEdit;
    PredSumma:Real;
    SZakupka,SSpecZena: AllStr;
    TempBox,LockBox:PBox;
    MinN,SOpl,TDoc,BakSkid,NewSkid:TDAteString;
    Otdels : LongInt;
    My,PlKr : Real;
Begin
Save:=False;
sf := False;

If OperatorSelector=1 Then
   If Not Password(11) Then Exit;

New(L,Init);{:=TestPr;}
Itog := CalcItogo(ItogNAlog);
{чтение с экрана прихода}

 PStaticText(ControlClient)^.GetText(S);
 System.Delete(S,Pos(#3,S),1);
 L^.Dat.ClientKod:=Copy(s,1+CClient+1,CClientKod);

 PStaticText(ControlAgent)^.GetText(S);
 System.Delete(S,Pos(#3,S),1);
 L^.Dat.AgentKod:=Copy(s,1+CClient+1,CClientKod);
 Otdels:=StrToInt(GetAgentField(Fotdel,L^.Dat.AgentKod));

 If Skidka=2 Then
 PlKr:=GetPlataKredit(Region,ClientShkala,Selector,StrToInt(SSrok){Srokдня})
 Else
 PlKr:=1.0000;

If (Prodaga^.List^.Count)>0 Then
For i:=0 To Prodaga^.List^.Count-1 Do
 Begin
  s:=Prodaga^.GetText(i,Prodaga^.List^.Count);
{L^.Dat.MarketElement[i+1].BazKod:=Copy(s,1+CName+1,CArtikul);}
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
    DelSpace(Nds);

    VidNDS:=StrToInt(Copy(s,1+CName+1+CArtikul+1+CLitr+1+CKol+1+CZena+1+CZena+1+CInputIZena+1+COne+1+CZena+1+
            CZena+1+clitr+1+COne+1+Clitr+1,COne));




    If OperatorSelector<>1 Then
    If VidNDS=2 Then
    If Selector in [3,4,6,8] Then
     Begin
      If MessageBox(^M+#3'Отгрузка ['+L^.Dat.MarketElement[i+1].BazKod+
	 '] со ставкой НДС=0% на СФ! Продолжить?',Nil,mfConfirmation+mfOkCancel)=cmCancel Then
       Begin
        Dispose(L,Done);
  	   Exit;
       End;
     End;





    Zakupka:=Copy(s,1+CName+1+CArtikul+1+CLitr+1+CKol+1+CZena+1+CZena+1+CInputIZena+1+COne+1+CZena+1+
                    CZena+1+clitr+1+COne+1+Clitr+1+COne+1,CZena);
    DelSpace(Zakupka);

    Kol:=Copy(s,1+COne+1+CName+1+CArtikul+1,CKol);
    DelSpace(Kol);
    Zena:=Copy(s,1+COne+1+CName+1+CArtikul+1+CLitr+1+CKol+1,CZena);
    DelSpace(Zena);
    Skidka:=Copy(s,1+COne+1+CName+1+CArtikul+1+CLitr+1+CKol+1+CZena+1,CZena);
    DelSpace(Skidka);


    If Status=DocEdit Then
     Begin
      AddNaklNumer(L^.Dat.MarketElement[i+1].BazKod,
	 PrevMarket,L^.Dat.MarketElement[i+1].Input.Osn);
     End
     Else
      Begin
       Osn.NaklNumer:=BakGetField(FNaklOsn,L^.Dat.MarketElement[i+1].BazKod,0);
       Osn.DateNakl :=BakGetField(FDateOsn,L^.Dat.MarketElement[i+1].BazKod,0);
      End;

(*    If (Abs(StrToReal(Skidka))<>0.0000) And (OperatorSelector=1) Then
     Begin
      MessageBox(#3'Для внутреннего документа!'^M+
                 #3'Обнулите скидку в позиции с кодом '+L^.Dat.MarketElement[i+1].BazKod,Nil,mfError+mfCancelButton);
      Dispose(L,Done);
      Exit;
     End;    *)

{$IFNDEF Aisha}
If Not(FindParam('/PEREEZD')) Then
Begin
    {проверка ручной скидки}
    If (Market.Skidka=1) Then
    If ((StrToReal(Zena)-StrToReal(Skidka))<StrToReal(Zakupka))  Then
     Begin
      If MessageBox(^M+#3'Товар '+L^.Dat.MarketElement[i+1].BazKod+' продается ниже себестоимости!'^M+
        #3'Продолжить?',Nil,mfError+mfOkCancel)=cmOk Then
      Begin
      If Not Password(13) Then
	 Begin
       Dispose(L,Done);
 	  Exit;
      End;
      End
      Else
       Begin
        Dispose(L,Done);
    	   Exit;
       End;
     End;

    If (Market.Skidka=10) Then
    If ((StrToReal(Zena)-StrToReal(Skidka)-100)<
    (StrToReal(Zakupka)*(1+StrToReal(GetIdField(FMinNazenka,L^.Dat.MarketElement[i+1].BazKod))/100)))  Then
     Begin
      If MessageBox(^M+#3'Товар '+L^.Dat.MarketElement[i+1].BazKod+' продается ниже минимальной наценки!'^M+
         #3'Продолжить',Nil,mfError+mfOkCancel)=cmOk Then
                 Begin
      If Not Password(3) Then
	 Begin
       Dispose(L,Done);
 	  Exit;
      End;
                 End
                  Else
                   Begin
                    Dispose(L,Done);
                	Exit;
                   End;
     End;
End;
{$ENDIF}


    Itogo:=Copy(s,1+COne+1+CName+1+CArtikul+1+CLitr+1+CKol+1+CZena+1+CZena+1,CInputIZena);
    DelSpace(Itogo);
    R_Zena:=Copy(s,1+CName+1+CArtikul+1+CLitr+1+CKol+1+CZena+1+CZena+1+CInputIZena+1+COne+1,CZena);
    DelSpace(R_Zena);
    O_Zena:=Copy(s,1+CName+1+CArtikul+1+CLitr+1+CKol+1+CZena+1+CZena+1+CInputIZena+1+COne+1+CZena+1,CZena);
    DelSpace(O_Zena);
    DiviSionSNumber:=StrToInt(Copy(s,1+CName+1+CArtikul+1,COne));





    {проверка при сохранении}
If FindParam('/BAKREGIM') Then
begin
    If OperatorSelector<>1 Then
    If ((Selector in [1,5,7]) And (DivisionSNumber<>1)) Or
       (Not(Selector in [1,5,7]) And (DivisionsNumber=1)) Then
        Begin
         MessageBox(^M+#3'Недопустимое сочетание вид документа и отделения в позиции с кодом '+
	    L^.Dat.MarketElement[i+1].BazKod,
	    Nil,mfError+mfCancelButton);
         Dispose(L,Done);
         Exit;
        End;
End
 Else
  Begin
    If OperatorSelector<>1 Then
    If Otdels<>0 Then
     If DiviSionSNumber<>Otdels Then
      Begin
       If Not FindParam('/SOFT') Then
       Begin
       MessageBox(^M+#3'Недопуст. агента и отделения в позиции с кодом ['+L^.Dat.MarketElement[i+1].BazKod+']',
       Nil,mfError+mfCancelButton);
       Dispose(L,Done);
       Exit;
       End
        Else
         Begin
       If MessageBox(^M+#3'Недопуст.агента и отделения в позиции с кодом ['+
	  L^.Dat.MarketElement[i+1].BazKod+']!'+
	  'Желаете продолжить?',
       Nil,mfError+mfCancelButton)=cmCancel Then
       Begin
       Dispose(L,Done);
       Exit;
       End;
         End;
      End;
  End;


{Юрий Григорьевич}

    PStaticText(ControlClient)^.GetText(Scl);
    System.Delete(Scl,1,1);
    Scl:=Copy(Scl,1+CClient+1,CClientKod);


    If Market.Skidka in [0,1] Then {запоминаем авто скидку если не использовались шкалы}
    Str((GetSkidkaProz(L^.Dat.MarketElement[i+1].BazKod,OperatorSelector,Scl,Itog)):CLitr+1:CMantissa+2,Proz)
    Else
    Begin
    Str((GetShkalaProz(L^.Dat.MarketElement[i+1].BazKod,ClientShkala,OperatorSelector,Scl))*PlKr:CLitr+1:CMantissa+2,Proz);
    DelSpace(Proz);

    Str((GetShkalaMin(L^.Dat.MarketElement[i+1].BazKod,ClientShkala)):CLitr+1:CMantissa+2,MinN);
    DelSpace(MinN);
    End;

    My:=StrToReal(R_Zena)*StrToReal(Proz);


{$IFNDEF Aisha}
If Not(FindParam('/PEREEZD')) Then
Begin
    If (Market.Skidka in [0,2]) Then
     Begin
      If My<StrToReal(Zakupka) Then
      begin
       If MessageBox(^M+#3'Товар '+L^.Dat.MarketElement[i+1].BazKod+' продается ниже себестоимости!'^M+
       #3'Продолжить?',Nil,mfWarning+mfOkCancel)=cmOk Then
       Begin
         If Not Password(13) Then
          Begin
           Dispose(L,Done);
           Exit;
          End;
       End
       Else
	    Begin
          Dispose(L,Done);
	     Exit;
         End;

      End;
     End;
End;
{$ENDIF}

{$IFNDEF Aisha}
If Not(FindParam('/PEREEZD')) Then
Begin
    If (Market.Skidka in [0,2]) And
    Not TestSpecZena(L^.Dat.MarketElement[i+1].BazKod,L^.Dat.ClientKod,SZakupka,SSpecZena) Then
     Begin
      If My<(StrToReal(Zakupka)*(1+StrToReal(MinN)/100)) Then
      begin
       If MessageBox(^M+#3'Товар '+L^.Dat.MarketElement[i+1].BazKod+' продается ниже мин. наценки!'^M+
       RealToStr(My,CIZena,CMantissa)+'<'+RealToStr(
	  StrToReal(Zakupka)*(1+StrToReal(MinN)/100),CIZena,CMantissa)+'! Продолжить?',Nil,mfWarning+mfOkCancel)=
	  cmOk Then
       Begin
         If Not Password(3) Then
          Begin
           Dispose(L,Done);
           Exit;
          End;
       End
       Else
        begin
          Dispose(L,Done);
	     Exit;
        End;
      End;
     End;
End;
{$ENDIF}

   End;
 End;

 ControlOperatorSelect^.GetData(L^.Dat.OperatorSelector);
 ControlSelect^.GetData(L^.Dat.DocSelector);
 ControlSkidka^.GetData(L^.Dat.SkidkaSelector);
 ControlSrok^.GetData(SSrok);


 ControlRegion^.GetData(L^.Dat.Region);

 L^.Dat.ShkalaNumer:=ClientShkala;

 PStaticText(ControlClient)^.GetText(S);
 System.Delete(S,Pos(#3,S),1);
 L^.Dat.ClientKod:=Copy(s,1+CClient+1,CClientKod);

 PStaticText(ControlAgent)^.GetText(S);
 System.Delete(S,Pos(#3,S),1);
 L^.Dat.AgentKod:=Copy(s,1+CClient+1,CClientKod);

 PStaticText(ControlItogoSkidka)^.GetText(S);
 System.Delete(S,Pos(#3,S),1);
 Str(StrToreal(S):CIZena:CMantissa,S);
 DelSpace(S);
 L^.Dat.Skidka:=S;


(*If FindParam('/SKIDKAC') Then
If Not (Abs(StrToReal(s))>0.009) Then
If MessageBox(^M+#3+'Вы наверняка забыли сделать скидку!'+
^M+#3+'Желаете исправить?',Nil,mfConfirmation+
mfOkCancel)=cmOk Then
 Begin
  Save:=False;
  Goto 1;
 End;  *)



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

If OperatorSelector=0 THen
Begin
 PStaticText(ControlClient)^.GetText(S2);
 System.Delete(S2,1,1);
 If (TestClientSrok(Copy(s2,1+CClient+1,CClientKod),OperatorSelector))Then Goto 1;
End;


(*
 If L^.DAt.DocSelector in [3,4,6,8] Then
  Begin
   ws:=GetClientField(FEnvir,{s}L^.Dat.ClientKod,0);
   DelSpace(wS);
   If ws[0]=#0 Then
   If Not NewPassword(3)Then Goto 1;
  End;
*)

if Not(TestDolgClientNew1(s)) Then
    begin
     MessageBox(^M+#3'Просроч. долг клиента со сроком 1 день!',Nil,mfInformation+mfCancelButton);
     If Not (StrToInt(CurrentPassword)=0) {Not NewPassword(0)} Then Goto 1;
    end;

 If L^.Dat.DocSelector in [5..8] Then
  Begin
   PStaticText(ControlClient)^.GetText(S);
   s:=Copy(s,1+1+CClient+1,CClientKod);

   PredSumma:=0;
   If Status=DocEdit Then
   Begin
    PredSumma:=StrToReal(PrevMarket^.Dat.SummaZ);
   End;

If Not FindParam('/NOLIMIT') Then
Begin
   if StrtoReal(GetClientField(FLimit,s,0))<(Itog-PredSumma+StrToReal(GetClientField(FDolg,s,0))) Then
    begin
     MessageBox(^M+#3'Долг клиента превысит лимит ',Nil,mfInformation+mfCancelButton);
     If Not (StrToInt(CurrentPassword)=0) {Not NewPassword(0)} Then Goto 1;
    End;

   If Not(StrToInt(GetClientField(FNoLimit,s,0))=1) Then
   Begin
   if Not(TestDolgClient(s)) Then
    begin
     If (StrToInt(CurrentPassword)=0) Then
      Begin
       If Not NewPassword(1)Then Goto 1;
      End
     Else
	 Begin
       MessageBox(#3'За клиентом числится просроченный не'+
     'оплаченный документ консигнации!',Nil,mfWarning+mfCancelButton);
	  Goto 1;
      End;
    End;

   End;
End;
   ws:=GetClientField(FNDogovor,s,0);
   DelSpace(wS);
   If ws[0]=#0 Then
    Begin
      MessageBox(#3'Внимание! Не указан договор!',Nil,mfInformation+mfCancelButton);
      If Not (StrToInt(CurrentPassword)=0) Then Goto 1;
    End;
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
    MessageBox(^M+#3+'Клиенту запрещено отпускать в кредит!',Nil,mfError+mfCancelButton);
    Save:=False;
    Goto 1;
   End;

  If L^.Dat.DocSelector in [6,8] Then
   Begin
       Sf:=True;
   End
   Else Sf:=False;


  If (Itog>=0.009) Then
   Begin
    i:=DateStringToDate(DAteMask,TekDate)+StrToInt(SSrok);
    {
    If (DefaultLizensia=1) And SF Then
    If Not(TestSrokLizensia(L^.Dat.ClientKod,TekDate)) Then
    Begin
     If Not NewPassword(5) Then Goto 1;
    End;
    }
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


(*
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
*)

    L^.Dat.Srok:=i;
    L^.Dat.Realiz:=True;
End;


 If (L^.Dat.DocSelector = 4) Then
  Begin
  If Status=DocEdit Then
  Save:=InputBN(L,PrevMarket,false)
  Else
  Save:=InputBN(L,L,false);
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


Save:=AddMArkerLast(L);
If Not(Save) Then
 Begin
  {$IFDEF NetVersion}
   UnLockAllPosition(LockBox);
   Dispose(LockBox,Done);
   Dispose(TempBox,Done);
  {$ENDIF}
   Goto 1;
 End;



If Status=DocNormal Then
Begin
    New(PereozenkaElement,Init);
    Assign(PereozenkaFile,Path.ToCorrect+TekDate+'.prz');
    i:=IOResult;
    Reset(Pereozenkafile);
    i:=IOResult;
    If I <> 0 Then
    Begin
  (*If MessageBox('Файл переоценки '+TekDate+'.prz не найден!'^M+
        'Создаю файл? '+
           +' Код:'+IntToStr(i,3),nil,
           mfConfirmation + mfOkCancel)=cmOk  Then *)
        Begin
         If Not(CreatToDayF(DocPereozen,TekDate)) Then
            Begin
          Save:=False;
          Dispose(l,Done);
          Dispose(PereozenkaElement,Done);
  {$IFDEF NetVersion}
   UnLockAllPosition(LockBox);
   Dispose(LockBox,Done);
   Dispose(TempBox,Done);
  {$ENDIF}
             Exit;
         End;
         Reset(PereozenkaFile);
         i:=IOResult;
        End
 (*   Else
        Begin
         Save:=False;
         Dispose(l,Done);
         Dispose(PereozenkaElement,Done);
  {$IFDEF NetVersion}
   UnLockAllPosition(LockBox);
   Dispose(LockBox,Done);
   Dispose(TempBox,Done);
  {$ENDIF}
         Exit;
        End;  *)
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

 If L^.Dat.OperatorSelector =2 Then
  Begin
   Save:=CreatClientBArterFile(L^.Dat.ClientKod);
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

 If Status=DocNormal Then
  Begin
   if L^.Dat.OperatorSelector in [0,2] Then
    If L^.Dat.DocSelector in [3,4,6,8] Then
     GetReestrNum(2,L^.DAt.NaklNumer,L^.Dat);{номер накладной}

   if L^.Dat.OperatorSelector in [0,2] Then
    If L^.Dat.DocSelector in [2,3] Then
     GetReestrNum(0,L^.DAt.PrhNumer,L^.Dat);{номер приходника}

   if L^.Dat.OperatorSelector in [0,2] Then
    If L^.Dat.DocSelector in [3,4,6,8] Then
     GetReestrNum(1,L^.DAt.SfNumer,L^.Dat);{номер счета-фактуры}
  End
  Else
   Begin
     L^.DAt.PrhNumer:=PrevMarket^.DAt.PrhNumer;
     L^.DAt.NaklNumer:=PrevMarket^.DAt.NaklNumer;
     L^.DAt.SfNumer:=PrevMarket^.DAt.SfNumer;
     DelSpace(L^.DAt.PrhNumer);
     DelSpace(L^.DAt.NaklNumer);
     DelSpace(L^.DAt.SfNumer);

     If L^.Dat.OperatorSelector in [0,2] Then
      Begin
       If L^.Dat.DocSelector in [3,4,6,7,8] Then
        begin

   if L^.DAt.NaklNumer='' Then
     GetReestrNum(2,L^.DAt.NaklNumer,L^.Dat){номер накладной};

   if L^.DAt.PrhNumer='' Then
    If L^.Dat.DocSelector in [2,3] Then
     GetReestrNum(0,L^.DAt.PrhNumer,L^.Dat);{номер приходника}

   if L^.DAt.SfNumer='' Then
    If L^.Dat.DocSelector in [3,4,6,7,8] Then
     GetReestrNum(1,L^.DAt.SfNumer,L^.Dat);{номер счета-фактуры}

        end;
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
          if Realiz=1 then
          Save:=SaveToStatFile(L,Sf,true)
          else Save:=SaveToStatFile(L,Sf,false);
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
         if realiz=1 then
         Save:=SaveRealizasToClientFile(L,Sf,true)
         else Save:=SaveRealizasToClientFile(L,Sf,false);
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


 {записываем статистику}
(* If (L^.Dat.OperatorSelector=2) Then
         Begin
          Save:=SaveToBarterRashodFile(L);
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
 {конец запись статистики}*)


 Save:=WriteMarketToSkladFile(L,L);

{$IFDEF NetVersion}
  UnLockAllPosition(LockBox);
  Dispose(LockBox,Done);
  Dispose(TempBox,Done);
{$ENDIF}




 If Save Then
  Repeat
  Until (UnLockMArket(L^.Dat.Document,L^.Dat.DateC) in [0,2]);

 If Save then SaveDostavka(L^.Dat,false);

 If Save Then
                Begin
                 {AddProtocol('Продажа товара по документу N '+L^.Dat.Document+' от '+L^.Dat.DateC,'','');}
                 As.D:=TekDate;
                 As.EditPosition:=L^.Dat.Document;
                 {PrintNaklSklad(As,NPrint.CopyNkl+1);}
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

 If L^.Dat.OperatorSelector =2 Then
  Begin
   Save:=CreatClientBArterFile(L^.Dat.ClientKod);
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

 {удаляем предыдущую}
 If (PrevMarket^.Dat.OperatorSelector=2) Then
  Begin
   Save := DeleteRashodOfBarterFile(PrevMarket);
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
         if Realiz=1 then
         Save:=SaveToStatFile(L,Sf,true)
	    else Save:=SaveToStatFile(L,Sf,false);
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

 {записываем новый бартер}
 If (L^.Dat.OperatorSelector=2) Then
  Begin
     Save:=SaveToBarterRashodFile(L);
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
 {конец запись бартера нового}

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


 If Status=DocNormal Then
  Begin
   if L^.Dat.OperatorSelector in [0,2] Then
    If L^.Dat.DocSelector in [3,4,6,8] Then
     GetReestrNum(2,L^.DAt.NaklNumer,L^.Dat);{номер накладной}

   if L^.Dat.OperatorSelector in [0,2] Then
    If L^.Dat.DocSelector in [2,3] Then
     GetReestrNum(0,L^.DAt.PrhNumer,L^.Dat);{номер приходника}

   if L^.Dat.OperatorSelector in [0,2] Then
    If L^.Dat.DocSelector in [3,4,6,8] Then
     GetReestrNum(1,L^.DAt.SfNumer,L^.Dat);{номер счета-фактуры}
  End
  Else
   Begin
     L^.DAt.PrhNumer:=PrevMarket^.DAt.PrhNumer;
     L^.DAt.NaklNumer:=PrevMarket^.DAt.NaklNumer;
     L^.DAt.SfNumer:=PrevMarket^.DAt.SfNumer;
     DelSpace(L^.DAt.PrhNumer);
     DelSpace(L^.DAt.NaklNumer);
     DelSpace(L^.DAt.SfNumer);

     If L^.Dat.OperatorSelector in [0,2] Then
      Begin
       If L^.Dat.DocSelector in [3,4,6,7,8] Then
         begin
   if L^.DAt.NaklNumer='' Then
     GetReestrNum(2,L^.DAt.NaklNumer,L^.Dat){номер накладной};

   if L^.DAt.PrhNumer='' Then
    If L^.Dat.DocSelector in [2,3] Then
     GetReestrNum(0,L^.DAt.PrhNumer,L^.Dat);{номер приходника}

   if L^.DAt.SfNumer='' Then
    If L^.Dat.DocSelector in [3,4,6,7,8] Then
     GetReestrNum(1,L^.DAt.SfNumer,L^.Dat);{номер счета-фактуры}
        end;
      End;
   End;

 If (L^.Dat.DocSelector in [5..8]) Then
         Begin
         if realiz=1 then
         Save:=SaveRealizasToClientFile(L,Sf,true)
         else Save:=SaveRealizasToClientFile(L,Sf,false);
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

 If Save Then Save:=WriteMarketToSkladFile(PrevMarket,L);

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
                 Case PrevMarket^.Dat.SkidkaSelector Of
                 0:BakSkid:='Авто';
                 1:BakSkid:='Ручн.';
                 2:BakSkid:='Шкала'+IntToStr(PrevMarket^.Dat.ShkalaNumer,COne);
                 Else BakSkid:='???';
                 End;

                 Case L^.Dat.SkidkaSelector Of
                 0:NewSkid:='Авто';
                 1:NewSkid:='Ручн.';
                 2:NewSkid:='Шкала'+IntToStr(L^.Dat.ShkalaNumer,COne);
                 Else NewSkid:='???';
                 End;

 If Save then SaveDostavka(L^.Dat,true);

              (*   AddProtocol('Корректировка документа продажи N '+L^.Dat.Document+' от '+L^.Dat.DateC+'  {возможна кража}',
                          ' Было Со скл.:'+RealToStr(StrToReal(PrevMarket^.Dat.SummaZ)-StrToReal(PrevMarket^.Dat.ENalog)+
                          StrToReal(PrevMarket^.Dat.Skidka),9{CIZena},CMantissa)+
                          ' Скидка:'+RealToStr(StrToReal(PrevMarket^.Dat.Skidka),9{CIZena},CMAntissa)+
{                          ' Тип:'+BakSkid+' Вид:'+IntToStr(PrevMarket^.Dat.DocSelector,COne)}+
                          ' Опл.:'+RealToStr(StrToReal(PrevMarket^.Dat.SummaZ),9,CMantissa),
                          'Стало Со скл.:'+RealToStr(StrToReal(L^.Dat.SummaZ)-StrToReal(L^.Dat.ENalog)+
                          StrToReal(L^.Dat.Skidka),9{CIZena},CMantissa)+
                          ' Скидка:'+RealToStr(StrToReal(L^.Dat.Skidka),{CIZena}9,CMAntissa)+
{                          ' Тип:'+NewSkid+' Вид:'+IntToStr(L^.Dat.DocSelector,COne)}+
                          ' Опл.:'+RealToStr(StrToReal(L^.Dat.SummaZ),9,CMantissa));        *)
(*
                 AddProtocolVozwrat('Корректировка документа продажи N '+L^.Dat.Document+' от '+L^.Dat.DateC+
                          '  {возможна кража}'^M+
                          ' Было Со скл.:'+RealToStr(StrToReal(PrevMarket^.Dat.SummaZ)-StrToReal(PrevMarket^.Dat.ENalog)+
                          StrToReal(PrevMarket^.Dat.Skidka),9{CIZena},CMantissa)+
                          ' Скидка:'+RealToStr(StrToReal(PrevMarket^.Dat.Skidka),9{CIZena},CMAntissa)+
                          ' Тип:'+BakSkid+' Вид:'+IntToStr(PrevMarket^.Dat.DocSelector,COne)+
                          ' Опл.:'+RealToStr(StrToReal(PrevMarket^.Dat.SummaZ),9,CMantissa)+^M+
                          'Стало Со скл.:'+RealToStr(StrToReal(L^.Dat.SummaZ)-StrToReal(L^.Dat.ENalog)+
                          StrToReal(L^.Dat.Skidka),9{CIZena},CMantissa)+
                          ' Скидка:'+RealToStr(StrToReal(L^.Dat.Skidka),{CIZena}9,CMAntissa)+
                          ' Тип:'+NewSkid+' Вид:'+IntToStr(L^.Dat.DocSelector,COne)+
                          ' Опл.:'+RealToStr(StrToReal(L^.Dat.SummaZ),9,CMantissa));
*)

                 As.D:=TekDate;
                 As.EditPosition:=L^.Dat.Document;
                 {PrintNaklSklad(As,NPrint.CopyNkl+1);}
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
    R.Assign(54, 4, 59, 5);
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
  j,c: Word;
  Control : PView;
  Ws,ws1,Strok,TempStrok : TEnjoyStr;
  s2,SSkidka,SName,SName2: String[CAll];
  SNDS,SNalog,SOZena,SRZena,SLitr,SKol,SInPack:String[CZena];
  Event : TEvent;
  VidNalog,VidNDS : Word;
  www : Real;
  ClKod,SpecZena : AllStr;
  ViewZakupka : Boolean;
  Scl : String;
  Zena: string[CZena];
  sAgent,sClient: string[CClientKOd];
  ss: string[CAll];
  opt,dost: boolean;
  sSF: String;
  localSpecRazdel:word;
  localRealiz: word;
Begin
ClearFind;

{memcc(s);}


SName:=Copy(S,1,CName);

SOtd:=Copy(s,1+CName+1+CArtikul+1,COne);
ActiveOtdel:=SOtd;

If OperatorSelector=0 THen
Begin
 PStaticText(ControlClient)^.GetText(S2);
 System.Delete(S2,1,1);
 If (TestClientSrok(Copy(s2,1+CClient+1,CClientKod),OperatorSelector))Then Exit;
End;



{Для новой структуры строки}
If Regim=0 Then SArtikul:=Copy(S,1+CName+1,CArtikul)
Else SArtikul:=Copy(S,1,CArtikul);

SName2:=GetIdField(FName2,SArtikul);
DelSpaceRight(SNAme2);


    PStaticText(ControlClient)^.GetText(Scl);
    System.Delete(Scl,1,1);
    Scl:=Copy(Scl,1+CClient+1,CClientKod);

If (Selector<>0) Or
  ((Selector=0)And(OperatorSelector=0)) Then
Begin
If GetIdMarket(Sartikul)=0 Then
  Begin
{$IfDef Sound}
     Sound(100);
{$EndIf}
     DinfoMsg('Внимание! Товар с кодом '+SArtikul+' запрещено отгружать клиенту!');
{$IfDef Sound}
     Delay(300);
     NoSound;
{$EndIf}
     ClearEvent(Event);
     repeat
       Application^.GetEvent(Event);
     until (Event.What <> evNothing) And (Event.Command<>cmMenu);
     NoInfoMsg;
     ClearEvent(Event);
     Exit;
  End;
End;

  if GetIdRealiz(sArtikul) then localrealiz:=1  {Товар на реализацию}
  else localRealiz:=2; {обычная консигнация}

  if StrToReal(GetRazdelSFProc(copy(sArtikul,1,2)))>0.01 then
  localSpecRazdel:=1    {спец раздел}
  else localSpecRazdel:=2;  {обычный раздел}

  if SpecRazdel=0 then SpecRazdel:=localSpecRazdel;
  if Realiz=0 then Realiz:=localRealiz;

 if (SpecRazdel<>localSpecRazdel) or (Realiz<>localRealiz)
 Then
  Begin
{$IfDef Sound}
     Sound(100);
{$EndIf}
     DinfoMsg('Внимание! Товар '+SArtikul+' не может войти в эту накладную!');
{$IfDef Sound}
     Delay(300);
     NoSound;
{$EndIf}
     ClearEvent(Event);
     repeat
       Application^.GetEvent(Event);
     until (Event.What <> evNothing) And (Event.Command<>cmMenu);
     NoInfoMsg;
     ClearEvent(Event);
     Exit;
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

(*PStaticText(ControlAgent)^.GetText(ss);
sAgent:=Copy(ss,1+CClient+1+1,CClientKod);

dost:=false;
if sAgent='0000' then ;*)


if FindParam('/NEWSKIDKA') then
begin

PStaticText(ControlClient)^.GetText(ss);
sClient:=Copy(ss,1+CClient+1+1,CClientKod);
{тип документа}
ControlSelect^.GetData(SF);

{самовывоз}
ControlDost^.GetData(DostSel);
if DostSel=1 then dost:=false
else dost:=TRUE;

{опт или розница}
opt:=false;
opt:=GetClientOpt(sClient,0);

 if SSrok='' then
 begin
 {$IfDef Sound}
     Sound(100);
 {$EndIf}
     DinfoMsg('Внимание! Необходимо ввести срок консигнации!');
 {$IfDef Sound}
     Delay(300);
     NoSound;
 {$EndIf}
     ClearEvent(Event);
     repeat
       Application^.GetEvent(Event);
     until (Event.What <> evNothing) And (Event.Command<>cmMenu);
     NoInfoMsg;
     ClearEvent(Event);
     Exit;
 end;


Skidka:=1;
Zena:=BakGetField(FRZena,SArtikul,0);
Str((StrToReal(Zena)*(StrToReal(GetAutoSkidka(opt,dost,SSrok))/100)):CZena:CMantissa,El.Skidka);

if SF in [6,8] then
if StrToReal(GetRazdelSFProc(copy(SArtikul,1,2)))>0.01 then
begin
Str(StrToReal(Zena)-
    ((StrToReal(Zena)-StrToReal(El.Skidka))
     *StrToReal(GetRazdelSFProc(copy(SArtikul,1,2)))/100)-(strtoreal(Zena)-strtoreal(El.Skidka))
:CZena:CMantissa,El.Skidka);
DelSpace(El.Skidka);
end
else
begin

DelSpace(El.Skidka);
end;
end; {if FindParam('/NEWSKIDKA')}

{Control1Skidka^.SetDAta(El.Skidka);
MarketWin^.Redraw;}


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
  if not FindParam('/NEWSKIDKA') then El.Skidka[0]:=#0;
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

PStaticText(ControlClient)^.GetText(S2);
System.Delete(S2,1,1);
ClKod:=Copy(s2,1+CClient+1,CClientKod);

ShowSZena:=TestSpecZena(SArtikul,ClKod,SZakupka,SpecZena);
El.Zena:=SRZena;

If Regim=0 Then
Begin
If ShowSZena Then
 Begin
    MyStr(StrToReal(SRZena)-StrToReal(SpecZena),CZena,CMAntissa,El.Skidka);
    DelSPace(El.Skidka);
    El.Zena:=SpecZena;
 End;
End;

If Regim=1 Then
 Begin
  MyStr(StrToReal(SRZena)-StrToReal(El.Skidka),CZena,CMantissa,El.Zena);
 End;

DelSpace(El.Zena);
DelSPace(El.Skidka);


1:
AInfo('Читаю информацию о товаре...');
R.Assign(1, 12, 80, 21);
New(MarketWin, Init(R, 'Продажа наименования товара - отделение ['+SOtd+']'));
MarketWin^.Options := MarketWin^.Options or ofCenterX;
MarketWin^.Palette := dpCyanDialog;
MarketWin^.HelpCtx := $E199;

{R.Assign(1, 3, 37, 5);}
R.Assign(1, 4, 44, 6);
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

  R.Assign(1, 3, 25, 4);
  MarketWin^.Insert(New(PLabel, Init(R, 'Количество ~у~паковок:', Pack)));


R.Assign(45, 4, 54, 5);
Control := New(PColoredText, Init(R, 'Упаковок:', $3E));
MarketWin^.Insert(Control);


R.Assign(54, 4, 59, 5);
ControlPack := New(PStaticText, Init(R, #3+'0+0'));
MarketWin^.Insert(ControlPack);


R.Assign(50, 5, 57, 6);
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

  R.Assign(42{38}, 5, 50, 6);
  MarketWin^.Insert(New(PLabel, Init(R, 'К~о~лич.:', ControlKol)));

R.Assign(2, 1, 74, 2);
Control := New(PStaticText, Init(R, 'Наименование:'+SName+' Код:'+SArtikul+' Масса:'+Slitr+' Фас:'+SInPack));
MarketWin^.Insert(Control);


If ShowSZena Then
Begin
DelSpace(SpecZena);
R.Assign(55, 2, 75, 3);
Control := New(PColoredText, Init(R, #3+'Спец.цена:'+SpecZena, $DF));
MarketWin^.Insert(Control);
End;



If (Skidka=1) Then
Begin
EnableCommands([cmLocalSkidka,cmLocalNazenka]);

R.Assign(65, 5, 75, 6);
ControlZen := New(PInputLine, Init(R, CZena));
MarketWin^.Insert(ControlZen);
  PInputLine(ControlZen)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));

  If (ShowSZena) Then
   Begin
   End;
  R.Assign(57, 5, 65, 6);
  MarketWin^.Insert(New(PLabel, Init(R, '  ~Ц~ена:', ControlZen)));

    If SpecZ<>1 Then
     Begin
	 ControlZen^.Options := ControlZen^.Options and not ofSelectable;
     End;

R.Assign(65, 6, 75, 7);
Control1Skidka := New(PInputLine, Init(R, CZena));
MarketWin^.Insert(Control1Skidka);
  PInputLine(Control1Skidka)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.','-']));

  If {(StrToInt(Copy(SArtikul,1,CRAzdelKod))=20) Or} (ShowSZena) Then
   Begin
   Control1Skidka^.Options := Control1Skidka^.Options and not ofSelectable;
   DisableCommands([cmLocalSkidka,cmLocalNazenka]);
   End;
  Control1Skidka^.Options := Control1Skidka^.Options and not ofSelectable;
  R.Assign(57, 6, 65, 7);
  MarketWin^.Insert(New(PLabel, Init(R, '~С~кидка:', Control1Skidka)));
End
Else
DisableCommands([cmLocalSkidka,cmLocalNazenka]);


SZakupka:=BakGetField(FZakupka,SArtikul,0);
Format(SZakupka,CZena);

If SpecZ>1 Then ViewZakupka:=False
Else ViewZakupka:=True;

If Skidka=1 Then
Begin
  If StrToReal(SZakupka)>0.009 Then
   Begin
    s[0]:=#0;
    MyStr((StrToREal(El.Zena)-StrToReal(SZakupka))/StrToReal(SZakupka)*100,CLitr,CMantissa,s);
    s:=''+s+'%';
   End
   Else s:='??.??%';
End;


R.Assign(60, 4, 69, 5);
ControlZak:=New(PColoredText, Init(R, 'ЗЦ:'+SZakupka, $31));
 MarketWin^.Insert(ControlZak);



R.Assign(70, 4, 78, 5);
 If (SpecZ=1) Then
ControlPPP := New(PColoredText, Init(R,s, $31))
 Else
ControlPPP:=New(PColoredText, Init(R, s, $33));
 MarketWin^.Insert(ControlPPP);


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

ws:=ws+SRZena;


R.Assign(23, 3, 71, 4);
Control := New(PColoredText, Init(R,ws, $31));
MarketWin^.Insert(Control);

{
R.Assign(64, 4, 75, 5);
Control := New(PColoredText, Init(R,'ЗЦ:'+SZakupka, $31));
MarketWin^.Insert(Control);
}

If Status=DocNormal Then ws1:=BakGetField(FKol,SArtikul,0);
DelSpace(Ws1);
ws1:=CalcPack(SArtikul,ws1);
DelSpace(Ws1);
R.Assign(1, 8, Length(' На складе имеется: '+ws1+' упаковок(ки)'+' Ставка НП:'+SNalog+' Ставка НДС:'+SNDS)+2, 9);
Control := New(PColoredText, Init(R,' На складе имеется: '+ws1+' упаковок(ки)'+' Ставка НП:'+SNalog+' Ставка НДС:'+SNDS, $31));
Control^.Options := Control^.Options or ofCenterX;
MarketWin^.Insert(Control);


Strok:=' ';
c:=1;
For j:=1+(Region*6) To 1+(Region*6)+5 Do
Begin
Tempstrok:='Ц_'+IntToStr(c,COne)+':';
Strok:=Strok+TempStrok;
Str(GetShkalaProz(SArtikul,j,OperatorSelector,Scl):CLitr+1:CMantissa+2,TempStrok);
Str(StrToReal(TempStrok)*StrToReal(SRZena):CZena:CMantissa,TempStrok);
DelSpace(TempStrok);
Strok:=Strok+TempStrok+'  ';
Inc(c);
End;

R.Assign(1, 7, Length(Strok)+1, 8);
Control := New(PColoredText, Init(R,#3+Strok, $5f));
Control^.Options := Control^.Options or ofCenterX;
MarketWin^.Insert(Control);

MarketWin^.SelectNext(False);
MarketWin^.SetData(El);

DrawPack;

NoInfo;

PrevKol[0]:=#0;

{!!!!!!!!!!!!!!!!!!!!!!! Для наборов не вызывать}
c:=Desktop^.ExecView(MarketWin);


c:=cmOk;

If c<>cmCancel Then
 Begin
  MarketWin^.GetData(El);
  Dispose(Control,Done);
  Dispose(MarketWin,Done);

{!!!!!!!!!!!!!!!!!!!!!!! Для наборов здесь присваивать кол-во}
{El.Kol:='10';}

If ShowSZena Then
 Begin
  If Skidka=1 Then{если ручной режим скидки}
   Begin
    MyStr(StrToReal(SRZena)-StrToReal(SpecZena),CZena,CMAntissa,El.Skidka);
    DelSPace(El.Skidka);
   End;
 End;


If SpecZ=1 Then
 Begin
  If Skidka=1 Then{если ручной режим скидки}
   Begin
    MyStr(StrToReal(SRZena)-StrToReal(El.Zena),CZena,CMAntissa,El.Skidka);
    DelSPace(El.Skidka);
   End;
 End;


  If (El.Kol[0]=#0) Or (StrTOInt(El.Kol)=0) Then
   Begin
    MessageBox(#3+NullKol,nil, mfError + mfCancelButton);
    GoTo 1;
   End;
  If Status=DocNormal Then
   Begin
  If (StrToInt(BakGetField(FDiv,SArtikul,StrToInt(SOtd)))<(StrTOInt(El.Kol))) Then
   Begin
     MessageBox(^M+'На складе (отделение ['+SOtd+']) отсутствует такое количество! ',nil, mfError + mfCancelButton);
     GoTo 1;
   End;
   End;
  If Status=DocEdit Then
  Begin
If (StrToInt(BakGetField
(FDiv,SArtikul,StrToInt(SOtd)))-StrTOInt(El.Kol)+GetKolMarket(SArtikul,StrToInt(SOtd),PrevMarket))<0 Then
   Begin
     MessageBox(^M+'На складе (отделение ['+SOtd+']) отсутствует такое количество! ',nil, mfError + mfCancelButton);
     GoTo 1;
   End;
  End;

  If Selector in [0,1] Then
  Begin
  If (StrTOReal(El.Skidka))>(StrtoReal(SRZena){(StrToReal(GetRZena(SArtikul))}) Then
   Begin
      MessageBox('Скидка превышает розничную цену !',nil, mfError + mfCancelButton);
      GoTo 1;
    End
  End;


{$IFNDEF Aisha}
If Not(FindParam('/PEREEZD')) Then
Begin
   If (OperatorSelector in[0,2]) And (Skidka=1)  And Not(ShowSZena) Then
    Begin
     If ((StrtoReal(SRZena)-StrTOReal(El.Skidka))-
	(StrToReal(SZakupka)*(1+StrToReal(GetIDField(FMinNazenka,SArtikul))/100)))<-0.0009 Then
      Begin
       SpecialBeep;
       MessageBox(^M+#3'Товар продается ниже мин.наценки!',Nil,mfFatalError+mfCancelButton);
       If Not Password(13) Then
	   Begin
         GoTo 1;
	   End;
      End;
    End;


   If (OperatorSelector in[0,2]) And (Skidka=1) Then
    Begin
     If (StrtoReal(SRZena)-StrTOReal(El.Skidka)-StrToReal(SZakupka))<-0.0009 Then
      Begin
       SpecialBeep;
       MessageBox(^M+#3'Товар продается ниже себестоимости!',Nil,mfFatalError+mfCancelButton);
       If Not Password(3) Then
	   Begin
         GoTo 1;
	   End;
      End;
    End;
End;
{$ENDIF}


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

VAr DZ,DS : Boolean;
procedure Calculator;
begin
  Calc^.Start;
end;


Procedure ReCalc;
Var s,sz : AllStr;
    R : TRect;
    NDS,sr1,sr2,sr : String[CZena];
    Color : Word;
    SRegion : AllStr;
Begin
                 ControlZen^.GetData(sr);
If (Skidka=1) And (SpecZ=1) Then
Begin
                 sz:=SZakupka;
                 ControlZen^.GetData(sr);
                 DelSpace(Sz);
                 DelSpace(Sr);
                 If StrToReal(sz)>0.009 Then
                 Begin
                  s[0]:=#0;
                  MyStr((StrToREal(sr)-StrToReal(sz))/StrToReal(sz)*100,CLitr,CMantissa,s);
                  s:=''+s+'%';
                 End
                 Else s:='??.??%';
                 {s:=sz+s;}
End;
                 Dispose(ControlPPP,Done);
                 R.Assign(70, 4, 78, 5);
                 If (SpecZ=1) Then
                 ControlPPP := New(PColoredText, Init(R,s, $31))
                 Else
                 ControlPPP:=New(PColoredText, Init(R, s, $33));
                 MarketWin^.Insert(ControlPPP);

    Redraw;
    ClearEvent(Event);
End;

Procedure DrawZena;
Var s: String[CPack];
    R : TRect;
    c,Color : Word;
    Zena : TDateString;
    i : Byte;

Begin
    ControlZen^.GetData(El.Zena);
    Control1Skidka^.GetData(El.Skidka);
    Zena:=BakGetField(FRZena,SArtikul,c);
    MyStr(StrToReal(Zena)-StrToreal(El.Skidka),CZena,CMantissa,El.Zena);
    DelSpace(El.Zena);
    ControlZen^.SetDAta(El.Zena);
End;



Procedure DrawSkidka;
Var s: String[CPack];
    R : TRect;
    c,Color : Word;
    Zena : TDateString;
    i : Byte;
Begin
    ControlZen^.GetData(El.Zena);
    Control1Skidka^.GetData(El.Skidka);
    Zena:=BakGetField(FRZena,SArtikul,c);
    MyStr(StrToReal(Zena)-StrToreal(El.Zena),CZena,CMantissa,El.Skidka);
    DelSpace(El.Skidka);
    Control1Skidka^.SetDAta(El.Skidka);
End;



Procedure InputLocalSkidka;
var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  c : Word;
  st : String[CLitr+1];
  Zena : TDateString;
  {Event : TEvent;}
  Sr : TDateString;
begin
Sr:=Copy(SArtikul,1,CRAzdelKod);

{If StrToInt(Sr)=20 Then Exit;}
MarketWin^.GetData(El);

c:=1;

If Selector in[0,1] Then
Zena:=BakGetField(FRZena,SArtikul,c)
Else
Zena:=BakGetField(FOZena,SArtikul,c);

If StrToREal(El.Skidka)>=0.01 Then
 Begin
  Str(StrToReal(El.Skidka)/StrToReal(Zena)*100:CLitr+1:CLitrMantissa+1,st);
 End
 Else St:='0';

 DelSpace(St);

R.Assign(28, 9, 50, 12);
New(Dlg, Init(R, 'Скидка-%'));
Dlg^.Palette := dpCyanDialog;
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx := $E004;
R.Assign(10, 1, 19, 2);
Control := New(PInputLine, Init(R, CLitr+1));
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));

  R.Assign(1, 1, 9, 2);
  Dlg^.Insert(New(PLabel, Init(R, 'Скидка:', Control)));
{
R.Assign(9, 1, 11, 2);
Control := New(PColoredText, Init(R, '1.', $1F));
Dlg^.Insert(Control);
}

Dlg^.SetData(St);

Dlg^.SelectNext(False);

{Event.KeyCode:=kbEnd;
Event.What:=evKeyDown;
PutEvent(Event); }

c:=Desktop^.ExecView(Dlg);

If c<>cmCancel Then
 Begin
  Dlg^.GetData(st);
  Dispose(Control,Done);
  Dispose(Dlg,Done);
  DelSpace(St);


  If (StrToReal(St)>5) And Not(CurrentPassword='00') Then
   If Not (NewPassword(4)) Then Exit;

  If StrToReal(st)<1.0000 Then
   Begin
    Messagebox(^M+#3'Недопустимое ЗНАЧЕНИЕ скидки!',Nil,mfError+mfCancelButton);
    Exit;
   End;

   Str((StrToReal(Zena)*(StrToReal(st)/100)):CZena:CMantissa,El.Skidka);
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
      cmLocalSkidka: Begin
	                  If Skidka=1 Then InputLocalSkidka;
                       DrawZena;
                       recalc;
                     End;
     cmLocalNazenka: Begin
	                  If Skidka=1 Then InputLocalNazenka;
                       DrawZena;
                       recalc;
                     End;
   Else;
   End;
 evKeyDown:
   Case Event.KeyCode Of
     (*  kbF4: BEGIN
          format(sSName,CName);
          {memcc(sSName+'!'+sSArtikul);}
          CorrectSertifMrk(sSName+'!'+sSArtikul);
        END;  *)

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

  DZ:=False;
  DS:=False;

  If Skidka=1 Then
  If (Event.What=evKeyboard)And
  ((Event.CharCode in ['0','1','2','3','4','5','6','7','8','9','.','-'])
Or (Event.KeyCode=kbDel)
Or (Event.KeyCode=kbBack)
Or (Event.KeyCode=kbShiftIns))
  And  ((Control1Skidka^.State and sfFocused <> 0)) Then
  DZ:=True;

  If Skidka=1 Then
  If (Event.What=evKeyboard)And((Event.CharCode in ['0','1','2','3','4','5','6','7','8','9','.','-'])
  Or (Event.KeyCode=kbDel) Or (Event.KeyCode=kbBack)
  Or (Event.KeyCode=kbShiftIns))
  And  ((ControlZen^.State and sfFocused <> 0)) Then
  DS:=True;



  inherited HandleEvent(Event);

  If DZ Then
   Begin
    DrawZena;
    Recalc;
   End;

  If DS Then
   Begin
    DrawSkidka;
    Recalc;
   End;


  If (Pack^.State and sfFocused <> 0) Then
   Begin
    ShowWarning:=FAlse;
    InputPAck[0]:=#0;
    DrawKol(ShowWarning,InputPack);
    If ShowWarning Then
    Begin
{$IfDef Sound}
     Sound(100);
{$EndIf}

     DinfoMsg('Внимание! В отделении ['+ActiveOtdel+'] нет такого количества '+InputPack+' шт.');
{$IfDef Sound}
     Delay(700);
     NoSound;
     Delay(700);
{$EndIf}
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
  SpecRazdel:=0;
  Realiz:=0;
  InputPassword:=False;
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


Procedure TSuperMarketWindow.FreshComment(Kod:ArtikulStr;OperatorSelector:Word);
VAr MMM : AllStr;
    R : TRect;
Begin
RFormatZerro(Kod,CClientKod);
mmm:=GetClientField(FMessages,Kod,OperatorSelector);
DelSpaceRight(mmm);
R.Assign(37, 19, 79, 20);
Dispose(ControlMsg,Done);
If mmm[0]<>#0 Then
ControlMsg := New(PColoredText, Init(R, #3+mmm, $DE))
Else
ControlMsg := New(PColoredText, Init(R, #3+mmm, $7E));
Insert(ControlMsg);
Redraw;
End;



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
  m2:Maska2;
  Event : TEvent;
  Cod : ArtikulStr;
  MMM : AllStr;

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
{    If MessageBox(#3'Файл продаж за '+TekDate+' не найден'^M+
    #3'Если Вы раннее что-то продавали'^M+
    #3'немедленно позовите программиста'^M+
    #3'Создавать файл продажи?'+' Код:'+IntToStr(c,3),Nil, mfWarning+mfOkCancel)=cmOk Then
     Begin}

      If Not(CreatToDayF(DocMarket,TekDate)) Then Exit;
      Reset(SuperMarketFile);
      c:=IOResult;
 {
     End
    Else Exit;
 }
   End;

   System.Close(SuperMarketFile);

  If Status=DocNormal Then
  Begin
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
         '.');
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
{$IfDef Sound}
     Sound(100);
{$EndIf}
     DinfoMsg('Не могу заблокировать клиента '+PrevMarket^.Dat.ClientKod+'! Попробуйте повторить!');
{$IfDef Sound}
     NoSound;
{$EndIf}
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

R.Assign(46, 4, 79, 5);
ControlDost := New(PRadioButtons, Init(R,
  NewSItem('Доставка',
  NewSItem('Самовывоз',
  Nil))));
(*if not FindParam('/NEWSKIDKA') then
ControlDost^.Options := ControlDost^.Options And Not ofSelectable;*)
  Insert(ControlDost);


R.Assign(56, 0, 79, 1);
ControlOperatorSelect := New(PRadioButtons, Init(R,
  NewSItem('К~л~',
  NewSItem('С',
  NewSItem('~О~б',
  Nil)))));
  Insert(ControlOperatorSelect);



If Status=DocEdit Then
  OperatorSelector:=PrevMarket^.Dat.OperatorSelector
Else OperatorSelector:=0;
ControlOperatorSelect^.SetData(OperatorSelector);

If nOT FindParam('/EB') Then
PCluster(ControlOperatorSelect)^.SetButtonState($00000004, False);

Prom:=OperatorSelector;


  R.Assign(51, 0, 56, 1);
  Insert(New(PLabel, Init(R, 'Вид:', ControlOperatorSelect)));



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




If Status=DocEdit Then
Begin

Selector:=PrevMarket^.Dat.DocSelector;

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


i:=DateStringToDate(DAteMask,TekDate)+StrToInt(SSrok);

SSrok[0]:=#0;
If Status=DocEdit Then
 Begin
  If PrevMArket^.Dat.DocSelector in [5,6,7,8] Then
   SSrok:=IntToStr(PrevMArket^.Dat.Srok-
                   DateStringToDate(DAteMask,PrevMArket^.Dat.DateC),3);

   If StrToInt(SSrok)<=0 Then SSrok[0]:=#0;
 End;


R.Assign(38, 2, 43, 3);
ControlSrok := New(PInputLine, Init(R, 3));
Insert(ControlSrok);
  PInputLine(ControlSrok)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0']));


  R.Assign(37, 1, 43, 2);
  Insert(New(PLabel, Init(R, 'Срок:', ControlSrok)));

ControlSrok^.SetData(SSrok);

SpecZ:=0;

R.Assign(36, 3, 44, 4);
ControlSpecZ := New(PCheckboxes, Init(R,
  NewSItem('~С~Ц', Nil)));
if not (User[81] or (CurrentPassword='00')) then
PCluster(ControlSpecZ)^.SetButtonState($00000001, False);
Insert(ControlSpecZ);
ControlSpecZ^.SetDAta(SpecZ);

R.Assign(0, 0, 0, 0);
Client := New(PBox, Init(R, 1, Nil));
Client^.NewList(New(PTextCollection, Init(0,1)));
{If Selector<>5 Then
Begin}

Case OperatorSelector Of
0:Assign (ClientFile,Path.ToClient+'Client.db');
1:Assign (ClientFile,Path.ToClient+'Sklad.db');
2:Assign (ClientFile,Path.ToClient+'Barter.db');
Else;
End;


{
If OperatorSelector=0 Then
Assign (ClientFile,Path.ToClient+'Client.db')
Else
Assign (ClientFile,Path.ToClient+'Sklad.db');
}
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
     ReadClient(ClientFile,ClientElement^.Dat);
     {
     Repeat
      NetCall.UnLock(ClientFile,(FilePos(ClientFile)-1)*SizeOf(ClientType),SizeOf(ClientType));
     Until (DosError=0);
     }

  If ClientElement^.Dat.Employ Then
   Begin
    Format (ClientElement^.Dat.Name,CClient);
    Client^.List^.Insert(NewStr(ClientElement^.Dat.Name+'│'+ClientElement^.Dat.Kod));
    Client^.SetRange(Client^.List^.Count);
   End;
 End;
System.Close(ClientFile);
End;

If Status=DocEdit Then Client^.FocusItem(Location(Client,PrevMarket^.Dat.ClientKod,ProdagaWindow))
Else
Begin
  If Not(SetLockNearClient({Client,}0,0,Cod)) Then
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


if FindParam('/NEWSKIDKA') then
begin
SSrok:=GetClientField(FPunkt1,copy(PrevS,1+CClient+1,CClientKod),0);
Delspace(SSrok);
ControlSrok^.SetData(SSrok);
sDost:=GetClientField(FPunkt2,copy(PrevS,1+CClient+1,CClientKod),0);
if pos('-',sDost)>0 then DostSel:=1
else DostSel:=0;
ControlDost^.SetData(DostSel);
end;

{R.Assign(48, 1, 75, 2);}
R.Assign(52, 1, 79, 2);
ControlClient := New(PColoredText, Init(R, #3+PrevS, $1F));
ControlClient^.Options := ControlClient^.Options or ofSelectable;
Insert(ControlClient);

{R.Assign(40, 1, 48, 2);}
R.Assign(44, 1, 52, 2);
Insert(New(PLabel, Init(R, 'Кл~и~ент:', ControlClient)));



R.Assign(0, 0, 0, 0);
Client := New(PBox, Init(R, 1, Nil));
Client^.NewList(New(PTextCollection, Init(0,1)));

Assign (ClientFile,Path.ToClient+'Agent.db');
I:=IOResult;
Reset (ClientFile);
I:=IOResult;
If i=0 Then
Begin
While Not(Eof(ClientFile)) Do
 Begin
     ReadClient(ClientFile,ClientElement^.Dat);
  If ClientElement^.Dat.Employ Then
   Begin
    Format (ClientElement^.Dat.Name,CClient);
    Client^.List^.Insert(NewStr(ClientElement^.Dat.Name+'│'+ClientElement^.Dat.Kod));
    Client^.SetRange(Client^.List^.Count);
   End;
 End;
System.Close(ClientFile);
End;

If Status=DocEdit Then Client^.FocusItem(Location(Client,PrevMarket^.Dat.AgentKod,ProdagaWindow))
Else Client^.FocusItem(0);
PrevAgent:=Client^.GEtText(Client^.Focused,Client^.List^.COunt);
Client^.HelpCtx:=$E001;
Dispose(Client,Done);


R.Assign(52, 2, 79, 3);
ControlAgent := New(PColoredText, Init(R, #3+PrevAgent, $1F));
ControlAgent^.Options := ControlAgent^.Options or ofSelectable;
Insert(ControlAgent);

R.Assign(45, 2, 52, 3);
Insert(New(PLabel, Init(R, '~А~гент:', ControlAgent)));



{R.Assign(51, 2, 74, 3);}
R.Assign(45, 3, 75, 4);
ControlSkidka := New(PRadioButtons, Init(R,
  NewSItem('А~в~то',
  NewSItem('Руч~н~',
  NewSItem('~Ш~кал.', Nil)))));
ControlSkidka^.Options:= ControlSkidka^.Options Or ofSelectable;
if FindParam('/NEWSKIDKA') then
begin
Skidka:=1;
ControlSkidka^.Options := ControlSkidka^.Options And Not ofSelectable;
end;
Insert(ControlSkidka);

If Status=DocEdit Then Skidka:=PrevMarket^.Dat.SkidkaSelector
Else Skidka:=1;{!!!!!}

ControlSkidka^.SetData(Skidka);
{PCluster(ControlSkidka)^.SetButtonState($5, False);}

{  R.Assign(42, 2, 51, 3);}
  R.Assign(37, 4, 45, 4);
  Insert(New(PLabel, Init(R, 'Скидка:', ControlSkidka)));


R.Assign(1, 4, 37, 5);
ControlRegion := New(PRadioButtons, Init(R,
  NewSItem('Оф',
  NewSItem('Гор',
  NewSItem('Обл',
  NewSItem('Рез', Nil))))));
ControlRegion^.Options := ControlRegion^.Options Or ofSelectable;
Insert(ControlRegion);


If Status=DocEdit Then
  Region:=PrevMarket^.Dat.Region
Else Region:=0;

ControlRegion^.SetDAta(Region);

If Status=DocNormal Then
Begin
Region:=StrToInt(GetClientField(FRegion,Cod,OperatorSelector));


 If ClientShkala>0 Then
 Begin
  ClientShkala:=ClientShkala+(6)*(Region);
 End
 Else
 ClientShkala:=0;

     If ClientShkala=0 Then
	 Begin
	  Skidka:=0;
       if FindParam('/NEWSKIDKA') then
       begin
	  Skidka:=1;
       ControlRegion^.Options := ControlRegion^.Options And Not ofSelectable;
       ControlSkidka^.Options := ControlSkidka^.Options And Not ofSelectable;
       end;
      End
      Else
       Begin
        Skidka:=2;
        if FindParam('/NEWSKIDKA') then Skidka:=1;
        ControlRegion^.Options := ControlRegion^.Options And Not ofSelectable;
        ControlSkidka^.Options := ControlSkidka^.Options And Not ofSelectable;
       End;
       ControlSkidka^.SetDAta(Skidka);
       ControlRegion^.SetDAta(Region);

End;




R.Assign(0, 0, 0, 0);
FZRazdel := New(PBox, Init(R, 1, Nil));
FZRazdel^.NewList(New(PTextCollection, Init(0,1)));
{
Assign (RazdelFile,Path.ToRazdel+'zaprfl!.db');
Reset (RazdelFile);
While Not(Eof(RazdelFile)) Do
Begin
Read(RazdelFile,RazdelElement);
FZRazdel^.List^.Insert(NewStr(RazdelElement.Kod));
FZRazdel^.SetRange(FZRazdel^.List^.Count);
End;
System.Close(RazdelFile);
}
R.Assign(0, 0, 0, 0);
SpisokRazdel := New(PBox, Init(R, 1, Nil));
SpisokRazdel^.NewList(New(PTextCollection, Init(0,1)));
{
Assign (RazdelFile,Path.ToRazdel+'zaprsp.db');
Reset (RazdelFile);
While Not(Eof(RazdelFile)) Do
Begin
Read(RazdelFile,RazdelElement);
SpisokRazdel^.List^.Insert(NewStr(RazdelElement.Kod));
SpisokRazdel^.SetRange(SpisokRazdel^.List^.Count);
End;
System.Close(RazdelFile);
}
R.Assign(0, 0, 0, 0);
SFRazdel := New(PBox, Init(R, 1, Nil));
SFRazdel^.NewList(New(PTextCollection, Init(0,1)));
{
Assign (RazdelFile,Path.ToRazdel+'zaprsf!.db');
Reset (RazdelFile);
While Not(Eof(RazdelFile)) Do
Begin
Read(RazdelFile,RazdelElement);
SFRazdel^.List^.Insert(NewStr(RazdelElement.Kod));
SFRazdel^.SetRange(SFRazdel^.List^.Count);
End;
System.Close(RazdelFile);
}
R.Assign(0, 0, 0, 0);
SFBRazdel := New(PBox, Init(R, 1, Nil));
SFBRazdel^.NewList(New(PTextCollection, Init(0,1)));
{
Assign (RazdelFile,Path.ToRazdel+'zaprsb.db');
Reset (RazdelFile);
While Not(Eof(RazdelFile)) Do
Begin
Read(RazdelFile,RazdelElement);
SFBRazdel^.List^.Insert(NewStr(RazdelElement.Kod));
SFBRazdel^.SetRange(SFBRazdel^.List^.Count);
End;
System.Close(RazdelFile);
}

R.Assign(0, 0, 0, 0);
TChekRazdel := New(PBox, Init(R, 1, Nil));
TChekRazdel^.NewList(New(PTextCollection, Init(0,1)));
{
Assign (RazdelFile,Path.ToRazdel+'zaprth!.db');
Reset (RazdelFile);
While Not(Eof(RazdelFile)) Do
Begin
Read(RazdelFile,RazdelElement);
TChekRazdel^.List^.Insert(NewStr(RazdelElement.Kod));
TChekRazdel^.SetRange(TChekRazdel^.List^.Count);
End;
System.Close(RazdelFile);
}

R.Assign(0, 0, 0, 0);
DebitRAzdel := New(PBox, Init(R, 1, Nil));
DebitRAzdel^.NewList(New(PTextCollection, Init(0,1)));
{
Assign (RazdelFile,Path.ToRazdel+'zaprd!.db');
Reset (RazdelFile);
While Not(Eof(RazdelFile)) Do
Begin
Read(RazdelFile,RazdelElement);
DebitRAzdel^.List^.Insert(NewStr(RazdelElement.Kod));
DebitRAzdel^.SetRange(DebitRAzdel^.List^.Count);
End;
System.Close(RazdelFile);
}
R.Assign(0, 0, 0, 0);
DebitRazdel_Sn := New(PBox, Init(R, 1, Nil));
DebitRazdel_Sn^.NewList(New(PTextCollection, Init(0,1)));
{
Assign (RazdelFile,Path.ToRazdel+'zaprd.db');
Reset (RazdelFile);
While Not(Eof(RazdelFile)) Do
Begin
Read(RazdelFile,RazdelElement);
DebitRazdel_Sn^.List^.Insert(NewStr(RazdelElement.Kod));
DebitRazdel_Sn^.SetRange(DebitRazdel_Sn^.List^.Count);
End;
System.Close(RazdelFile);
}
R.Assign(0, 0, 0, 0);
DebitSFRazdel := New(PBox, Init(R, 1, Nil));
DebitSFRazdel^.NewList(New(PTextCollection, Init(0,1)));
{
Assign (RazdelFile,Path.ToRazdel+'zaprdsf!.db');
Reset (RazdelFile);
While Not(Eof(RazdelFile)) Do
Begin
Read(RazdelFile,RazdelElement);
DebitSFRazdel^.List^.Insert(NewStr(RazdelElement.Kod));
DebitSFRazdel^.SetRange(DebitSFRazdel^.List^.Count);
End;
System.Close(RazdelFile);
}
R.Assign(0, 0, 0, 0);
DebitSFBRazdel := New(PBox, Init(R, 1, Nil));
DebitSFBRazdel^.NewList(New(PTextCollection, Init(0,1)));
{
Assign (RazdelFile,Path.ToRazdel+'zaprdsb.db');
Reset (RazdelFile);
While Not(Eof(RazdelFile)) Do
Begin
Read(RazdelFile,RazdelElement);
DebitSFBRazdel^.List^.Insert(NewStr(RazdelElement.Kod));
DebitSFBRazdel^.SetRange(DebitSFBRazdel^.List^.Count);
End;
System.Close(RazdelFile);
}
R.Assign(36, 5, 37, 20);
Control := New(PScrollBar, Init(R));
Insert(Control);




R.Assign(1, 6, 36, 20);
Baz := New(PBox, Init(R, 1, PScrollbar(Control)));
Baz^.NewList(New(PTextCollection, Init(0,1)));
Baz^.FocusItem(0);
Baz^.HelpCtx:={E141}$F036;
Insert(Baz);

l:=False;

  R.Assign(1, 5, 36, 6);
  Insert(New(PLabel, Init(R, 'На складе и~м~еется           Код  N', Baz)));

R.Assign(79, 6, 80, 19);
Control := New(PScrollBar, Init(R));
Insert(Control);

R.Assign(37, 6, 79, 19);
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
    Str(PrevMarket^.Dat.MarketElement[c].Input.DiviSionSNumber:1,SArtikul);
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

  R.Assign(37, 5, 79, 6);
  Insert(New(PLabel, Init(R, 'Код   Выбранн~ы~е товары           N Колич', Prodaga)));
{                             12345678901234567890123456 12345 1}


R.Assign(2, 20, 22, 21);
Control := New(PColoredText, Init(R, 'Наименование товара:', $74));
Insert(Control);

R.Assign(22, 20, 79, 21);
ControlFullName := New(PColoredText, Init(R, #3+'???', $7e));
Insert(ControlFullName);
PrevName[0]:=#0;


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


R.Assign(37, 19, 79, 20);
ControlMsg := New(PColoredText, Init(R, #3+'', $7E));
Insert(ControlMsg);


R.Assign(75, 3, 79, 4);
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


FreshComment(Cod,OperatorSelector);

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
    Gluk : TDateString;
    PlKr : Real;
    Scl : String[150];

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


If Not(Selector in [5,6,7,8]) Then
Begin
SSrok[0]:=#0;
ControlSrok^.SetData(SSrok);
ControlSrok^.Options := ControlSrok^.Options and not ofSelectable;
End
Else
 Begin

  ControlSrok^.Options := ControlSrok^.Options or ofSelectable;
  ControlSrok^.GetData(SSrok);
  DelSpace(SSrok);
 End;



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
MyStr((l*Kol),CInputIZena,CMantissa,Itogo_L);


l:=StrToReal(Zakupka);{Закупка}
MyStr((l*Kol),CInputIZena,CMantissa,Itogo_Zakupka);


MyStr((1+StrToReal(NalogStr)/100),CLitr,CMantissa,Koefficient);
DelSpace(Koefficient);

MyStr(StrToReal(SSo)-StrToReal(Skid),CZena,CMAntissa,Zena);

MyStr(StrToREal(Zena)*StrToReal(Koefficient),CZena,CMantissa,RealZena);

MySTr(StrToReal(RealZena)-StrToReal(Zena),CZena,CMantissa,RealZena);


MyStr((StrToReal(Itogo_Zakupka)+StrToReal(ItogNalog.Zakupka)),CIZena,CMantissa,ItogNalog.Zakupka);

{расчитываем если необходимо велечину спец налога}
If Selector in [{1,}2,3,5,6] Then {отключен расчет налога с продажи в тч}
Begin
{велечина спец налога с единицы товара}

MyStr(StrToReal(RealZena)*Kol,CIZena,CMantissa,RealZena);
DelSpace(RealZena);

{суммарная ставка налога}
MyStr((StrToReal(RealZena)+StrToReal(ItogNalog.ENalog)),CIZena,CMantissa,ItogNalog.ENalog);
CAse VidNalog Of
0:myStr((StrToReal(RealZena)+StrToReal(ItogNalog.Nalog5)),CIZena,CMantissa,ItogNalog.Nalog5);
1:myStr((StrToReal(RealZena)+StrToReal(ItogNalog.Nalog3)),CIZena,CMantissa,ItogNalog.Nalog3);
2:myStr((StrToReal(RealZena)+StrToReal(ItogNalog.Nalog_)),CIZena,CMantissa,ItogNalog.Nalog_);
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



 If Skidka=2 Then
 PlKr:=GetPlataKredit(Region,ClientShkala,Selector,StrToInt(SSrok){Srokдня})
 Else
 PlKr:=1.0000;


    PStaticText(ControlClient)^.GetText(Scl);
    System.Delete(Scl,1,1);
    Scl:=Copy(Scl,1+CClient+1,CClientKod);

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
  0: Begin
      l:=StrToReal(SSo)*GetSkidkaProz(Sa,OperatorSelector,Scl,Itogo);
     End;
  2: Begin
      myStr(GetShkalaProz(Sa,ClientShkala,OperatorSelector,Scl)*PlKr,CLitr+1,CMantissa+2,Gluk);
      l:=StrToReal(SSo)*StrToReal(Gluk);{GetShkalaProz(Sa,ClientShkala)*PlKr;}
     End;
  Else;
  End;

  myStr(L,CZena,CMantissa,Itogo_L);

  {memCC(Itogo_L+' '+RealToStr(GetShkalaProz(Sa,ClientShkala)*PlKr,CIzena,4));}

  MyStr((1+StrToReal(NalogStr)/100),CLitr,CMantissa,Koefficient);
  DelSpace(Koefficient);

  MyStr(StrToReal(Itogo_L)*StrToReal(Koefficient),CZena,CMantissa,RealZena);

  MyStr((StrToReal(RealZena)-StrToReal(Itogo_L)),CZena,CMAntissa,RealZena);



  L:=StrToReal(Itogo_L);

If Selector in [{1,}2,3,5,6] Then {отключаем расчет нп по тч}
Begin
  {расчитываем абсолютное значение сбора по спецналогу с единицы товара}
{  Str((StrToReal(RealZena)-StrToReal(Itogo_L)):CZena:CMantissa,NAlogStr);}
  {всего с позиции}
  MyStr(StrToReal(RealZena)*Kol,CIZena,CMantissa,RealZena);
  {суммарная ставка налога}
  MyStr((StrToReal(RealZena)+StrToReal(ItogNalog.ENalog)),CIZena,CMantissa,ItogNalog.ENalog);
 CAse VidNalog Of
 0:MyStr((StrToReal(RealZena)+StrToReal(ItogNalog.Nalog5)),CIZena,CMantissa,ItogNalog.Nalog5);
 1:MyStr((StrToReal(RealZena)+StrToReal(ItogNalog.Nalog3)),CIZena,CMantissa,ItogNalog.Nalog3);
 2:MyStr((StrToReal(RealZena)+StrToReal(ItogNalog.Nalog_)),CIZena,CMantissa,ItogNalog.Nalog_);
 Else;
 End;
End;
  MyStr((L*Kol),CInputIZena,CMantissa,Itogo_L);

  Sr:=Sr+StrToReal(Itogo_L);


  End;{for}
  SkidkaItogo:=Itogo-Sr;

Dispose(TempCalc,Done);
End;
End;


Itogo:=Itogo-SkidkaItogo;

MyStr(Sl,CILitr,CMantissa,Itogo_L);
DelSpace(Itogo_L);

MyStr(SkidkaItogo,CIZena,CMantissa,Skid);
DelSpace(Skid);

If Selector in [{1,}2,3,5,6] Then {отключен расчет нп в тч}
 MyStr((Itogo+STrToReal(ItogNalog.ENalog)),CIZena,CMantissa,Itogo_O)
 Else
 MyStr(Itogo,CIZena,CMantissa,Itogo_O);


DelSpace(Itogo_O);

If Selector In [0,1] Then Sr:=0.00;
MyStr(Sr,CIZena,CMantissa,Itogo_R);
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

MyStr(StrToreal(ItogNalog.ENalog),CIZena,CMantissa,Itogo_O);
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
  MessageBox(#3^M+#3'Долг клиента превышает ( '+s+' руб. )!',Nil,mfWarning+mfCancelButton);
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
  R.Assign(75, 3, 79, 4);
  ControlCurrent := New(PColoredText, Init(R, #3+KolStr, $4e));
  Insert(ControlCurrent);
End;


(*
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
    ts1,ts2 : String;
Begin
{Test1:=CurrentTime;}
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
     Str(StrToInt(BazElement.Input.DivisionS[i])+GetKolMarket(BazElement.BazKod,i,PrevMarket):CKol,
     BazElement.Input.DivisionS[i]);
     DelSpace(BazElement.Input.DivisionS[i]);
     Format (BazElement.Input.DivisionS[i],CKol);
     Str(StrToInt(BazElement.Input.DivisionS[i]):CKol,BazElement.Input.DivisionS[i]);

     Str(i:1,SArtikul);
     Prevs:=SName+'│'+BazElement.BazKod+'│'+SArtikul+'│';

     If StrToInt(BazElement.Input.DivisionS[i])>0 Then
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


EDAUTOSkidka;

CalcItogo(ItogNAlog);


PrevS[0]:=#0;
Noinfo;

If Selector in [5..8] Then
 Begin
     PStaticText(ControlClient)^.GetText(S);
     System.Delete(S,1,1);
      Art:=Copy(s,1+CClient+1,CClientKod);

      If StrToInt(GEtClientField(FDebit,Art,0))<>1 Then
       Begin
        MessageBox(^M+#3+'Клиенту запрещено отпускать товар на консигнацию!',Nil,mfError+mfCancelButton);
       End;
 End;


End;
*)


Procedure TSuperMarketWindow.Refresh(Regim:Boolean);
Var R : TRect;
    i : Word;
    S : TMyString;
    PrevArt,Art : ArtikulStr;
    St : String[CZena];
    BazFile : File;
    jk : Word;
    Si : String[CInputIZena];
    l,Logik : Boolean;
    Count : Word;
    SName : AllStr;
    SLitr : TDateString;
    Test1,Test2 : LongInt;
    ts1,ts2 : String[150];
    AgentKod,ClientKod : AllStr;
    Otdel : LongInt;
    bOpt: boolean;
    BazElement : PBufSkladType;
Begin
{Test1:=CurrentTime;}
DInfo('Формирую список товаров...');

 PStaticText(ControlAgent)^.GetText(S);
 System.Delete(S,Pos(#3,S),1);
 AgentKod:=Copy(s,1+CClient+1,CClientKod);

 PStaticText(ControlClient)^.GetText(S);
 System.Delete(S,Pos(#3,S),1);
 ClientKod:=Copy(s,1+CClient+1,CClientKod);

 bOpt:=GetClientOpt(ClientKod,0);

 Otdel:=StrToInt(GetAgentField(FOtdel,AgentKod));

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
(*
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

{Старт проверки на Дебит}
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

{Старт проверки на Дебит С/Ф}
 If Selector=6 Then
 If (DebitSFRazdel^.List<>Nil)And(DebitSFRazdel^.List^.Count>0) Then
  Begin
   For i:=0 To DebitSFRazdel^.List^.Count-1 Do
    Begin
     PrevS:=Copy(DebitSFRazdel^.GetText(i,DebitSFRazdel^.List^.Count),1,CRazdelKod);
     If PrevS=RazdelElement.Kod Then logik:=False;
    End;
  End;
{Стоп проверки на дебит С/Ф}

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
*)


If Logik Then
Begin
Assign (BazFile,Path.ToSklad+RazdelElement.Kod+'.db');
i:=ioresult;
Reset (BazFile,SizeOf(SkladType));
i:=ioresult;
If i=0 Then
Begin
While Not(Eof(BazFile)) Do
 Begin
     {
     Repeat
     Until NetCall.Lock(BazFile,FilePos(BazFile)*SizeOf(SkladType),SizeOf(SkladType));
     }
     Count:=0;
     New(BazElement,Init);
     ReadBufSklad(BazFile,BazElement,Count);
     {
     Repeat
      NetCall.UnLock(BazFile,(FilePos(BazFile)-1)*SizeOf(SkladType),SizeOf(SkladType));
     Until (DosError=0);
     }
{  If GetIdEmploy(BazElement.BazKod) Then}
  For jk:=1 To Count Do
Begin
  if not(bOpt and GetIdZapretOpt(BazElement^.Point.Dat[jk].BAzKod)) then
  If BazElement^.Point.Dat[jk].Employ Then
  Begin
  l:=false;
  If Status=DocNormal Then
  If (StrToInt(BazElement^.Point.Dat[jk].Input.Kol)>0) then
        l:=true;
  If Status=DocEdit Then
  if ((StrToInt(BazElement^.Point.Dat[jk].Input.Kol)+
GetFullKolMarket(BazElement^.Point.Dat[jk].BazKod,PrevMarket))>0) Then l:=true;
 if l then
   Begin
    SName := GetIdField(FName,BazElement^.Point.Dat[jk].BazKod);
    Format(SName,CName);

    For i:=1 To CDivision Do
    Begin
    {вставка для павла}
    If FindParam('/BAKREGIM') Then
   Begin
    If OperatorSelector<>1 Then
    Begin
    If (Selector in [1,5,7]) And (i<>1) Then Continue;
    If Not (Selector in [1,5,7]) And (i=1{отделение}) Then Continue;
    End;
   End
    Else{новая схема}
      Begin
       If OperatorSelector<>1 Then
       If Otdel<>0 Then
       If i<> Otdel Then Continue;
      End;

     If Status=DocEdit Then
     Str(StrToInt(BazElement^.Point.Dat[jk].Input.DivisionS[i])+
	GetKolMarket(BazElement^.Point.Dat[jk].BazKod,i,PrevMarket):CKol,
     BazElement^.Point.Dat[jk].Input.DivisionS[i]);
     DelSpace(BazElement^.Point.Dat[jk].Input.DivisionS[i]);
     Format (BazElement^.Point.Dat[jk].Input.DivisionS[i],CKol);
     Str(StrToInt(BazElement^.Point.Dat[jk].Input.DivisionS[i]):CKol,
	BazElement^.Point.Dat[jk].Input.DivisionS[i]);

     Str(i:1,SArtikul);
     Prevs:=SName+'│'+BazElement^.Point.Dat[jk].BazKod+'│'+SArtikul+'│';

     If StrToInt(BazElement^.Point.Dat[jk].Input.DivisionS[i])>0 Then
     Begin
     Baz^.List^.Insert(NewStr(Prevs));
     Baz^.SetRange(Baz^.List^.Count);
     End;
    End;{For}

   End;{If l=True}
  End;{Employ}
End;{For}
 Dispose(BazElement,Done);
 End;{While}
System.Close(BazFile);

End
 Else
  Begin
   MessageBox(^M+#3' Ошибка '+Path.ToSklad+RazdelElement.Kod+'.db'^M+
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
 MyStr((StrToInt(si)*StrToReal(St)),CInputIZena,CMantissa,Si);
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


PrevS[0]:=#0;
Noinfo;

If Selector in [5..8] Then
 Begin
     PStaticText(ControlClient)^.GetText(S);
     System.Delete(S,1,1);
      Art:=Copy(s,1+CClient+1,CClientKod);
      {
      If Not(TestDolgClient(Art)) Then
      Begin
      SpecialBeep;
       MessageBox(#3'За клиентом числится просроченный не'+
     'оплаченный документ консигнации!'^M+
     #3'Возможно не следует выдавать ему товар на консигнацию!',Nil,mfWarning+mfCancelButton);
      End;
      }


      If StrToInt(GEtClientField(FDebit,Art,0))<>1 Then
       Begin
        MessageBox(^M+#3+'Клиенту запрещено отпускать товар на консигнацию!',Nil,mfError+mfCancelButton);
       End;
 End;


(*
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
*)
{Test2:=CurrentTime;
Str(test1,ts1);
Str(test2,ts2);
MessageBox(Ts1+^M+Ts2,Nil,mfError+mfCancelButton);}
End;






Procedure TSuperMarketWindow.SetSelector;
Var l : Maska10;
    i,j : Word;
    PrevArt,Art : ArtikulStr;
    s1,s : String[150];
Begin
If OperatorSelector in [0,2] Then
Begin
For i:=1 To Max10 Do
   l[i]:=0; {очистка маски}

If (Prodaga^.List<>Nil)And(Prodaga^.List^.Count>0) Then
 Begin
For i:=0 To Prodaga^.List^.Count-1 Do
Begin
 s:=Copy(Prodaga^.GetText(i,Prodaga^.List^.Count),1{+CName+1},CRazdelKod);
(*
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
*)

End;
End;

if operatorselector=2 then
 Begin
  l[2]:=1;
  l[3]:=1;
  l[4]:=1;
  l[5]:=1;
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
Redraw;

End;




Procedure TSuperMarketWindow.FreshClient;
Var i : Byte;
    R : TRect;
    Cod : ArtikulStr;
    c, Count : Word;
    CLF : fILE;
    CLE : PBufClientType;
Begin
(*DInfo('Обновляю список клиентов...');
R.Assign(0, 0, 0, 0);
Client := New(PBox, Init(R, 1, Nil));
Client^.NewList(New(PTextCollection, Init(0,1)));

{If Selector <>5 Then
Begin}

Case OperatorSelector Of
0:Assign (ClF,Path.ToClient+'Client.db');
1:Assign (ClF,Path.ToClient+'Sklad.db');
2:Assign (ClF,Path.ToClient+'Barter.db');
Else;
End;

I:=IOResult;
Reset (ClF,SizeOf(Clienttype));
I:=IOResult;
If i=0 Then
Begin
While Not(Eof(ClF)) Do
 Begin
    New(CLE,Init);
    ReadBufClient(Clf,CLE,Count);
  For c:=1 To Count Do
  Begin
  If CLE^.Point.Dat[c].Employ Then
   Begin
    Format (CLE^.Point.Dat[c].Name,CClient);
    Client^.List^.Insert(NewStr(CLE^.Point.Dat[c].Name+'│'+CLE^.Point.Dat[c].Kod));
    Client^.SetRange(Client^.List^.Count);
   End;
  End;{For}
   Dispose(CLE,Done);
 End;
System.Close(ClF);
End
 Else
  MessageBox(^M+#3'Ошибка открытия файла клиентов!'^M+
  ClicProgrammer+' Код: ('+IntTostr(i,3)+')',Nil,mfError+mfCancelButton);
 If Not(SetLockNearClient({Client,}0,OperatorSelector,Cod)) Then
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
NoInfo;*)

DInfo('Обновляю список клиентов...');

 If Not(SetLockNearClient(0,OperatorSelector,Cod)) Then
  Begin
   NoInfo;
   MessageBox(^M+#3'Не могу заблокировать ни одного клиента!',Nil,mfError+mfCancelButton);
   Exit;
  End;

PrevS:=GetClientField(FClient,Cod,OperatorSelector);
Format(PrevS,CClient);
PrevS:=PrevS+'│'+Cod;

PStaticText(ControlClient)^.Text^:=#3+PrevS;


FreshComment(Cod,OperatorSelector);

Redraw;
NoInfo;

End;



Procedure SetBarier;
Begin
 If Password(15) Then
  begin
   ControlRegion^.Options := ControlRegion^.Options Or ofSelectable;
   ControlSkidka^.Options := ControlSkidka^.Options Or ofSelectable;
   PCluster(ControlSkidka)^.SetButtonState($3, False)
  End;
End;



Procedure TSuperMarketWindow.SetMaska(O:Word);
Var R:TRect;
    Prevs : Byte;
    mm:Maska9;
    c,mmms:Word;
    Art : ArtikulStr;
Begin

Prevs:=O;
{If O in [1]{,3,4,5,6,7] Then}
Case O Of
1:{настройка межскладских перевозок}
   Begin
    ControlSelect^.GetData(Prom);
    O:=0;
    ControlSelect^.SetData(O);
    PCluster(ControlSelect)^.SetButtonState($000003FE, False);
    Inc(O);
    ControlSkidka^.SetData(O);
    PCluster(ControlSkidka)^.SetButtonState($1, False);
    Skidka:=O;
    Redraw;
    If Prevs<>3 Then FreshClient;{обновление списка клиентов}
    If Not((Prom=0)And(Selector=0)) Then
    Begin
    Selector:=0;
    SetEnabledDoc(OperatorSelector);
    Redraw;

    Refresh(False);
    Redraw;
    CalcItogo(ItogNAlog);
    End
     Else
     Begin
     Selector:=0;
     SetEnabledDoc(OperatorSelector);
     Redraw;

          Refresh(False);
     CalcItogo(ItogNAlog);
     End;
   End;
0,2: Begin
      Selector:=9;
      ControlSelect^.SetData(Selector);
      Skidka:=0;
      ControlSkidka^.SetData(Skidka);
      PCluster(ControlSelect)^.SetButtonState(255, True);{1e}
      PCluster(ControlSkidka)^.SetButtonState($1, True);
      If O=2 Then
       Begin
        PCluster(ControlSelect)^.SetButtonState($000001E0, False);
        Skidka:=1;
        ControlSkidka^.SetData(Skidka);
       End;
      Redraw;
      SetSelector;
      Redraw;
      FreshClient;
                Refresh(False);
      CalcItogo(ItogNAlog);
         {Refresh;}
   End;
Else;
End;{case}
End;



procedure TSuperMarketWindow.HandleEvent(var Event: TEvent);
Var R : TRect;
    rr,test,iAg : Word;
    s,s1 : TMyString;
    l : Boolean;
    Nk_RZena,Nk_OZena : TDateString;
    {Rash : RashetType;}
    SDoc :ArtikulStr;
    SDate : TDateString;
    STest : String[3];
    SAg,SAgName:AllStr;
    sKOd: string[CClientKod];

begin
  Case Event.What Of
  evKeyDown :
  Case Event.KeyCode Of
     kbF7: BEgin
            If (Baz^.State and sfFocused <> 0) And (Baz^.List<>Nil)And(Baz^.List^.Count>=1) Then
            begin
              s:=Baz^.GetText(Baz^.Focused,Prodaga^.List^.Count);
              CorrectSertifMrk(s);
              Redraw;
		  end;
           end;
     kbF8 :Begin
            SetBarier;
            Redraw;
           End;
     kbDel: Begin
     If (Prodaga^.State and sfFocused <> 0) And (Prodaga^.List<>Nil)And(Prodaga^.List^.Count>=1) Then
            Begin
              If MessageBox(#3+DelTovar,nil,mfConfirmation+mfOkCancel)=cmOk Then
               Begin
                l:=False;
                If Status=DocEdit Then
                Begin
                 L:=False;
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
  kbGrayPlus : Begin
            (*   If (Skidka=1) And (OperatorSelector in [0,2]) Then
               Begin
                PStaticText(ControlClient)^.GetText(S);
                System.Delete(S,1,1);
                s:=Copy(s,1+CClient+1,CClientKod);
                GlobalSkidka(s,OperatorSelector);
                CalCItogo(ItogNAlog);
                Redraw;
                ClearEvent(Event);
               End
               Else ClearEvent(Event); *)
               End;

  kbAltF4       : Begin
               If (Skidka=1) And (OperatorSelector in [0,2]) Then
               Begin
                PStaticText(ControlClient)^.GetText(S);
                System.Delete(S,1,1);
                s:=Copy(s,1+CClient+1,CClientKod);
                GlobalSkidkaPereezd(s,OperatorSelector);
                CalCItogo(ItogNAlog);
                Redraw;
                ClearEvent(Event);
               End
               Else ClearEvent(Event);
               End;
kbAltEqual : Begin
            (*   If (Skidka=1) And (OperatorSelector in [0,2]) Then
               Begin
                PStaticText(ControlClient)^.GetText(S);
                System.Delete(S,1,1);
                s:=Copy(s,1+CClient+1,CClientKod);
                GlobalSkidkaOutZakupka(s,OperatorSelector);
                CalCItogo(ItogNAlog);
                Redraw;
                ClearEvent(Event);
               End
               Else ClearEvent(Event); *)
               End;
  kbGrayMinus: Begin
            (*   If (Skidka=1) And (OperatorSelector in [0,2]) Then
               Begin
                PStaticText(ControlClient)^.GetText(S);
                System.Delete(S,1,1);
                s:=Copy(s,1+CClient+1,CClientKod);
                GlobalNAzenka(s,OperatorSelector);
                CalCItogo(ItogNAlog);
                Redraw;
                ClearEvent(Event);
               End
               Else ClearEvent(Event); *)
               End;
  kbAltRus,
  kbAltRusSh1,
  kbCtrlRusSh1,
  kbCtrlRusSh:Begin
               Event.What:=evCommand;
               Event.Command:=CmChangeShkala;
               PutEvent(Event);
              End;
(*
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
*)
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

     cmAbout: Begin
                ClearEvent(Event);
                AboutCHM('7');
              End;

     cmSuperMarket: Begin
                 ClearEvent(Event);
                End;
  cmRefresh :
     Begin
      Refresh(False);
      FreshSkladHint;
     End;

 cmSelectAgent:
 Begin
  If ((PView(Ag)<>Desktop^.TopView)And(ControlAgent^.State and sfFocused <> 0))
   Then
  Begin
     PStaticText(ControlAgent)^.GetText(S);
     System.Delete(S,1,1);
     l:=True;

     Ag^.ShowAgentList(s,Test);

     PStaticText(ControlAgent)^.Text^:=#3+S;
     Redraw;
     Case Test Of
      0,3 :FocusNext(True);
      1,2 :FocusNext(False);
     Else;
     End;
     ClearEvent(Event);
     If Status=DocEdit Then Refresh(True)
     Else Refresh(False);
  End
  Else
  ClearEvent(Event);
 End;



 cmSelectClient:
 Begin
  If (PView(Cl)<>Desktop^.TopView)And(ControlClient^.State and sfFocused <> 0) Then
  Begin
     PStaticText(ControlClient)^.GetText(S);
     System.Delete(S,1,1);
     PrevCL:=Copy(s,1+CClient+1,CClientKod);
     {If Selector<>5 Then l:=False
     Else} l:=True;

     If Status=DocNormal Then
     Begin
     Repeat
     Until (SetClientUnLock(Copy(s,1+CClient+1,CClientKod),0,OperatorSelector));
     Cl^.ShowClientList(s,OperatorSelector,0,L,True,True,-1,-1,-1,-1,Test);
     End
     Else
      Begin
       If Not((PrevMarket^.Dat.ClientKod=Copy(s,1+CClient+1,CClientKod))
        And(PrevMarket^.Dat.OperatorSelector=OperatorSelector)) Then
        Begin
         Repeat
         Until (SetClientUnLock(Copy(s,1+CClient+1,CClientKod),0,OperatorSelector));
        End;
       Cl^.ShowClientList(s,OperatorSelector,0,L,True,True,StrToInt(PrevMarket^.Dat.ClientKod),
                               PrevMarket^.Dat.OperatorSelector,-1,-1,Test);
      End;

     ClientShkala:=StrToInt(GetClientField(FShkala,Copy(s,1+CClient+1,CClientKod),OperatorSelector));
     RR:=StrToInt(GetClientField(FRegion,Copy(s,1+CClient+1,CClientKod),OperatorSelector));

 If OperatorSelector=2 Then
  Begin
   Region:=0;
   ClientShkala:=0;
  End;

 If ClientShkala>0 Then
 Begin
  ClientShkala:=ClientShkala+(6)*(RR);
 End
 Else
 ClientShkala:=0;

     If ClientShkala=0 Then
	 Begin
	  Skidka:=0;
       Region:=RR;
       ControlRegion^.Options := ControlRegion^.Options Or ofSelectable;
       ControlSkidka^.Options := ControlSkidka^.Options Or ofSelectable;
       if FindParam('/NEWSKIDKA') then
	  Skidka:=1;
       Begin
       ControlRegion^.Options := ControlRegion^.Options And Not ofSelectable;
       ControlSkidka^.Options := ControlSkidka^.Options And Not ofSelectable;
       End;
      End
      Else
       Begin
        Region:=RR;
        Skidka:=2;
        if FindParam('/NEWSKIDKA') then Skidka:=1;
        ControlRegion^.Options := ControlRegion^.Options And Not ofSelectable;
        ControlSkidka^.Options := ControlSkidka^.Options And Not ofSelectable;
       End;
       ControlSkidka^.SetDAta(Skidka);
       ControlRegion^.SetDAta(Region);

     If Not(PrevCl=Copy(s,1+CClient+1,CClientKod)) then
     if FindParam('/NEWSKIDKA') then
     begin
     sDost:=GetClientField(FPunkt2,copy(S,1+CClient+1,CClientKod),0);
     if pos('-',sDost)>0 then DostSel:=1
     else DostSel:=0;
     ControlDost^.SetData(DostSel);
     end;

     If Not(PrevCl=Copy(s,1+CClient+1,CClientKod)) then
      if FindParam('/NEWSKIDKA') then
      begin
         SSrok:=GetClientField(FPunkt1,Copy(s,1+CClient+1,CClientKod),0);
         ControlSrok^.SetData(SSrok);
      end;


     CalcItogo(ItogNAlog);
     PStaticText(ControlClient)^.Text^:=#3+S;
     Redraw;
     Case Test Of
      0,3 :FocusNext(True);
      1,2 :FocusNext(False);
     Else;
     End;

    { ControlDost^.getData(DostSel);
     MEMCC(IntToStr(DostSel,5));}

     If Selector in[5..8] Then
     Begin
      s1:=Copy(s,1+CClient+1,CClientKod);

      If Not(TestDolgClient(s1)) Then
      Begin
      SpecialBeep;
       MessageBox(#3'За клиентом числится просроченный '+
     'документ консигнации!',Nil,mfWarning+mfCancelButton);
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
    (* If DefaultLiZensia=1 Then
      Begin
     If Selector in [3,4,6,8] Then
      Begin
       s1:=Copy(s,1+CClient+1,CClientKod);
       If Not(TestSrokLizensia(s1,TekDate)) Then
        Begin
        SpecialBeep;
        MessageBox(#3+'У клиента просрочена лицензия!'^M+
         #3+'Нельзя отпускать на С/Ф!',Nil,mfError+mfCancelButton);
       End;

      End;
      End;  *)

      FreshComment(Copy(s,1+CClient+1,CClientKod),OperatorSelector);

   If OperatorSelector in [0,2] Then
   Begin
   s1:=Copy(s,1+CClient+1,CClientKod);
   if StrToInt(Rek.ven)>0 then iAg:=1
   else iAg:=SelectImport(33);

   if iAg>=2 then iAg:=1;

   if iAg=0 then SAg:=GetCLientField(FAgSamKod,s1,0)
   else SAg:=GetCLientField(FAgVenKod,s1,0);

   {SAg:=GetCLientField(FAgKod,s1,0);}
   ClearChar(SAg);
   {SAg:=IntToStr(StrToInt(SAg),CKOl);}
   SAgName:=GetAgentField(FAgent,SAg);
   Format(SAgName,CClient);
   RFormatZerro(SAg,CCLientKod);
   S:=SagName+'│'+SAg;

     PStaticText(ControlAgent)^.Text^:=#3+S;
     Redraw;
     FocusNext(False);
     {FocusNext(True);}
     ClearEvent(Event);
     If Status=DocEdit Then Refresh(True)
     Else Refresh(False);

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
{$IfDef Sound}
               Sound(100);
{$EndIf}
               DinfoMsg('не определен вид документа...');
{$IfDef Sound}
               Delay(700);
               NoSound;
{$EndIf}
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
              sKod:=copy(s,pos('│',s)+1,CClientKod);
              if DateStringToDate(DateMask,Fdate)+14>
              DateStringToDate(DateMask,GetCLientField(fSrok,sKod,0))
              then
              begin
                MessageBox(#3^M+#3'Внимание! Срок действия договора'^M+
                #3'склиентом истекает '+GetCLientField(fSrok,sKod,0),Nil,mfError+mfCanCelButton);
              end;

              DelSpace(s);

              If OperatorSelector=0 Then
              if DateStringToDate(DateMask,Fdate)>
              DateStringToDate(DateMask,GetCLientField(fSrok,copy(s,pos('│',s)+1,CClientKod),0))
              then
              begin
               DinfoMsg('Истек срок действия договора клиента '+
                        sKod+'...');
                repeat
                  Application^.GetEvent(Event);
                until (Event.What <> evNothing)And(Event.Command<>cmMenu);

               NoInfoMsg;
               ClearEvent(Event);
               Exit;

              end;

(*               If OperatorSelector=1 Then
               If StrToInt(Rek.Kod)=StrToInt(Copy(s,1+CClient+1,CClientKod)) Then
                Begin
{$IfDef Sound}
               Sound(100);
{$EndIf}
               DinfoMsg('Нельзя отгружать клиенту с кодом '+
                        Copy(s,1+CClient+1,CClientKod)+'...');
{$IfDef Sound}
               Delay(700);
               NoSound;
{$EndIf}
                repeat
                  Application^.GetEvent(Event);
                {until (Event.What in [evKeyDown,evMouseDown]);}
                until (Event.What <> evNothing)And(Event.Command<>cmMenu);

               NoInfoMsg;
               ClearEvent(Event);
               Exit;

                End;     *)


               If (s<>'│')And(s[0]<>#0) Then
               Begin
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
               PStaticText(ControlClient)^.GetText(S);
               System.Delete(S,1,1);
            {  If (StrToInt(CurrentPassword)=0) Or
		    (StrToInt(GetClientField(FShkala,Copy(s,1+CClient+1,CClientKod),OperatorSelector))=0)Then}
              Begin
              If Skidka=2 Then
              Begin
               Test:=ClientShkala;
               If SelectShkala(Test,Region) Then
               Begin
                ClientShkala:=Test;
                CalcItogo(ItogNAlog);
                Redraw;
               End;
              End;
              End;
               ClearEvent(Event);
              End;

  cmCancel : Begin
               l:=False;
               If (Prodaga^.List<>Nil)And(Prodaga^.List^.Count>0) Then
If MessageBox(#3^M+#3'Желаете отказаться от продажи ?',Nil,mfConFirmation+mfOkCancel)<>cmOk
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
 if (CurrentPassword='00') then
 If (PView(Cl)<>Desktop^.TopView)And(ControlAgent^.State and sfFocused <> 0)
 And (Event.Command<>cmSelectAgent) And (Event.What <> EvKeyDown)Then
            Begin
             Event.What:=EvCommand;
             Event.Command:=cmSelectAgent;
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
                  R.Assign(36, 21, 39, 22);
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

              DrawFullName;

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

     PStaticText(ControlClient)^.GetText(S);
     System.Delete(S,1,1);


     ClientShkala:=StrToInt(GetClientField(FShkala,Copy(s,1+CClient+1,CClientKod),OperatorSelector));
     RR:=StrToInt(GetClientField(FRegion,Copy(s,1+CClient+1,CClientKod),OperatorSelector));

 If Test=2 Then
  Begin
   Region:=0;
   ClientShkala:=0;
  End;

 If ClientShkala>0 Then
 Begin
  ClientShkala:=ClientShkala+(6)*(RR);
 End
 Else
 ClientShkala:=0;

     If ClientShkala=0 Then
	 Begin
	  Skidka:=0;
       Region:=RR;
       ControlRegion^.Options := ControlRegion^.Options Or ofSelectable;
       ControlSkidka^.Options := ControlSkidka^.Options Or ofSelectable;
       if FindParam('/NEWSKIDKA') then Skidka:=1;
       ControlRegion^.Options := ControlRegion^.Options And Not ofSelectable;
       ControlSkidka^.Options := ControlSkidka^.Options And Not ofSelectable;
      End
      Else
       Begin
        Region:=RR;
        Skidka:=2;
        if FindParam('/NEWSKIDKA') then Skidka:=1;
        ControlRegion^.Options := ControlRegion^.Options And Not ofSelectable;
        ControlSkidka^.Options := ControlSkidka^.Options And Not ofSelectable;
       End;
       ControlSkidka^.SetDAta(Skidka);
       ControlRegion^.SetDAta(Region);




     CalcItogo(ItogNAlog);
                EDAutoSkidka;
                Redraw;
               End;
              End;

          if (ControlSelect^.State and sfFocused <> 0)Then
              Begin
               ControlSelect^.GetData(Prom);
               If Prom <> Selector Then
               Begin
                Begin
                  Selector:=Prom;
                  Refresh(False);
                  EDAutoSkidka;
                  Redraw;
                End;
               End;
              End;



         if (ControlRegion^.State and sfFocused <> 0)Then
              Begin
               ControlRegion^.GetData(Prom);
               If Prom <> Region Then
               Begin

 If ClientShkala>0 Then
 Begin
  If Prom<Region Then ClientShkala:=ClientShkala-(6)*(Region-Prom)
  Else ClientShkala:=ClientShkala+(6)*(Prom-Region);
 End
 Else
 ClientShkala:=0;

                  Region:=Prom;
                  CalcItogo(ItogNAlog);
                  Redraw;
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


          if (ControlSrok^.State and sfFocused <> 0)Then
              Begin
               ControlSrok^.GetData(STest);
               If STest <> SSrok Then
               Begin
                  SSrok:=STest;
                  CalcItogo(ItogNAlog);
                  Redraw;
               End;
              End;


          if (ControlSpecZ^.State and sfFocused <> 0)Then
              Begin
               ControlSpecZ^.GetData(Prom);
               If (Prom <> SpecZ) Then
               Begin
                  SpecZ:=Prom;
                  If Not InputPassword Then
                  If SpecZ=1 Then
                  Begin
                  If Not password(14) Then
			    Begin
                    SpecZ:=0;
                    ControlSpecZ^.SetData(SpecZ);
			    End
                   Else InputPassword:=True;
                  End;
               End;
              End;

          If Skidka in [0,1] Then
           DisableCommands([cmChangeShkala])
          Else
           EnableCommands([cmChangeShkala]);


          End;

end;

End.