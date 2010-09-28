{$I Compile.INC}

{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}
Unit Utils;

Interface

Uses Dialogs,Glob,ColorTxt,ServStr,Drivers,Views,MyCalc;

Const Bit5=5;
      Bit8=8;
      Max2=2;
      Max3=3;
      Max4=4;
      Max6=6;
      Max8=8;
      Max7=7;
      Max9=9;
      Max10=10;
      Max16=15;
      Max16new=16;
      Max24=CShkala;
      {Max30=30;}
      Max40=40;
      Max100=100;


Type MaskaBak = Array [1..Bit5] Of Word;
Type MaskaNew = Array [1..Bit8] Of Word;
Type Maska5 = Array [1..5] Of Word;
Type Maska6 = Array [1..6] Of Word;
Type Maska7 = Array [1..7] Of Word;
Type Maska9 = Array [1..9] Of Word;
Type Maska10 = Array [1..10] Of Word;
Type Maska16 = Array [1..15] Of Word;
Type Maska16new = Array [0..15] Of Word;
Type Maska24 = Array [1..CShkala] Of Word;
Type Maska8 = Array [1..8] Of Word;
Type Maska4 = Array [1..4] Of Word;
Type Maska3 = Array [1..3] Of Word;
Type Maska2 = Array [1..2] Of Word;

Type Maska40 = Array [1..Max40] Of Word;
Type Maska100 = Array [1..Max100] Of Word;

Type BBB=Record
    Summa : String[CIZena];
    Rashet: Word;
    Prim  : String[CAll];
    Link  : Word;
    Doc   : String[CDocNumer];
    DAte  : TDAteString;
  end;


Type
  PFullScreenMrk = ^TFullScreenMrk;
  TFullScreenMrk = object(TDialog)
        Calc        : PMyCalculator;
      Function FullScreenMrk(Ass:DocumentEdit):Boolean;
      {
         Function FullScreenMrk(Const P:PBox;Const s,s1:String;SDoc,SClientKod,SAgentKod:ArtikulStr;SDate:TDateString;
         t,V:Byte):Boolean;
      }
      procedure CalcItogo;
         procedure DrawCurrent(s: String);
         procedure Refresh;
         procedure HandleEvent(var Event: TEvent); virtual;
         Destructor Done;Virtual;
  end;

Function FormLineOtdel(R:Byte):AllStr;

Function TestRazdelA(S:ArtikulStr;P:PBox):Boolean;
Function TestElement (Const S : AllStr;Const P : PBox) : Boolean;
Function TestRazdelClient (Const SC,S : AllStr;Const P : PBox) : Boolean;
Function TestRazdelMemory (Const S : AllStr;Const P : PBox) : Boolean;
Procedure GlobalSkidka1(Var P:PBox;Summa:String);
Procedure GlobalNazenka1(Var P:PBox;Summa:String);
Function TTime:Boolean;
Function GetEnvMy:string;
{function NewPassword(i:Byte) : Boolean;}
Procedure CalcRaspredelenie(L:PSuperMarketType;Var Es:PstatClientType);
Procedure CompressMarket(Auto:Boolean;StartDate,StopDate:TDateString);
Function CompressDolg(Auto:Boolean):Boolean;
Procedure TestClientBaza;
Function Filtration(Var M : Maska9):Boolean;
Procedure CalcSpecialKassa( Var
    AllZakupka,
    AllPrihod,
    AllRewisia,
    AllReturn,
    MinusDohod,
    AllDohod,
    AllDohodA,
    AllDolg,
    AllDolgA,
    DolgiIstekshie,
    DolgiVse,
    PlategiIstekshie,
    PlategiVse: AllStr);


{Procedure Unique(Path: string[150]; Var FileName: String);}
function Crypt(S : String) : string;
Function InputBezNal(Var Bn:BezNal;B: BBB):Boolean;

function Decrypt(S : String) : string;
function Encrypt(S : String) : string;
{Procedure SetupPassword;}

Procedure WordToBitBak (n:Word; Var b : MaskaBak);
Procedure WordToBitNew (n:Word; Var b : MaskaNew);
Procedure WordToBit2 (n:Word; Var b : Maska2);
Procedure WordToBit4 (n:Word; Var b : Maska4);
Procedure WordToBit5 (n:Word; Var b : Maska5);
Procedure WordToBit6 (n:Word; Var b : Maska6);
Procedure WordToBit7 (n:Word; Var b : Maska7);
Procedure WordToBit9 (n:Word; Var b : Maska9);
Procedure WordToBit10 (n:Word; Var b : Maska10);
Procedure WordToBit16 (n:Word; Var b : Maska16);
Procedure WordToBit16new (n:Word; Var b : Maska16new);
Procedure WordToBit40 (n:Word; Var b : Maska40);
Procedure WordToBit100 (n:Word; Var b : Maska100);
Procedure WordToBit8 (n:Word; Var b : Maska8);
Procedure WordToBit3 (n:Word; Var b : Maska3);
Function Stepen(i:Word):Word;
Procedure BitToWordBak ( b : MaskaBak; Var n:Word);
Procedure BitToWordNew ( b : MaskaNew; Var n:Word);

Procedure BitToWord2 ( b : Maska2; Var n:Word);
Procedure BitToWord4 ( b : Maska4; Var n:Word);
Procedure BitToWord6 ( b : Maska6; Var n:Word);
Procedure BitToWord5 ( b : Maska5; Var n:Word);
Procedure BitToWord7 ( b : Maska7; Var n:Word);
Procedure BitToWord9 ( b : Maska9; Var n:Word);
Procedure BitToWord10 ( b : Maska10; Var n:Word);
Procedure BitToWord16 ( b : Maska16; Var n:Word);
Procedure BitToWord16new ( b : Maska16new; Var n:Word);
Procedure BitToWord40 ( b : Maska40; Var n:Word);
Procedure BitToWord100 ( b : Maska100; Var n:Word);
Procedure BitToWord3 ( b : Maska3; Var n:Word);
Procedure Invert3 ( Var b : Maska3);
Procedure MarketToDolg(E:PSuperMarketType;Var D: PRealizasiaType);
Procedure ConvertBak(Var b:MaskaBak);
Procedure ConvertNew(Var b:MaskaNew);
Procedure Convert7(Var b:Maska7);
Procedure Convert6(Var b:Maska6);
Procedure Convert5(Var b:Maska5);
Procedure Convert3(Var b:Maska3);
Procedure Convert4(Var b:Maska4);
Procedure Convert2(Var b:Maska2);
Procedure Convert8(Var b:Maska8);
Procedure Convert9(Var b:Maska9);
Procedure Convert10(Var b:Maska10);
Procedure Convert16(Var b:Maska16);
Procedure Convert16new(Var b:Maska16new);
Procedure Convert40(Var b:Maska40);
Procedure Convert100(Var b:Maska100);
Procedure Invert2 ( Var b : Maska2);

Function SortSkidka(inp:PSkidkaType): Boolean;
Function AssignTemp(VAr f1:TExt;St:String):string;

Function MaskaSelect (Var s: AllStr;Var Res:Word):Boolean;

Function FindParam(s:String):Boolean;
Function ListFind(Var s:AllStr):Boolean;
Procedure ChekAddStr(st:AllStr; Res:Word);
Function TestAgent(Cod:ArtikulStr):Boolean;
Procedure InputKredit;
Procedure SetupPassword;

Procedure ViewClientBaza;
function NewPassword(i:Byte) : Boolean;
Function InputBN(Var l,PrevMarket:PSuperMarketType;rashod: boolean):Boolean;
Function SelectOperationAndDocument(Var mm3s:Maska3;Var mm9S:Maska9):Boolean;
Function SelectClass(Var l : Maska16):Boolean;

function GetGranizi(M:Maska6;VAr MMM : TAutoString1):Boolean;
Procedure CorrectRazdel(Cod:Integer);
Function GetImportFileName(As:DocumentEdit;SkladKod:ArtikulStr):AllStr;
Function TestElementR (Const S : AllStr;Const P : PBox) : Boolean;
Function SelectShkala(Var l : Word;Reg : Word):Boolean;

Function SaveToStatFile(L:PSuperMarketType;S:Boolean;R:boolean):Boolean;
Function DeleteOfStatFile(PrevMarket:PSuperMarketType):Boolean;
Function TestSrokLizensia(c:AllStr;Date:TDateString):Boolean;
function SelectOtdel(Var Otdel:Word) : Boolean;
Procedure SetupStart;



implementation


Uses app,Memory,Dos,MsgBox,Objects,Validate,TpDate,Serv,WinDos,Nastr,Access,
 DbEngine,NetCall,NetDbEng,CPrihod,Protect{,StarSky},Gadgets,Printers,Tools;


Const EncryptionKey : String[80]='MNOPQRSTUVWXYZABCDEFGHIJKL';
const
  Digits : Array[0..$F] of Char = '0123456789ABCDEF';

Const StartPos= 1+CArtikul+1+CName+1+COne+1+CKol+1+CZena+1+CZena+1+CZena+1+CZena+1;

Var FullScr : PFullScreenMrk;
    ControlFull : PBox;
    MrkWin :PFullScreenMrk;
    ControlNGTD,ControlMarka,ControlVirabotano,ControlDo,
    ControlFullNAme,ControlMsg,ControlR,ControlRz,ControlText,ControlCl,Control : PView;
    CurrentLine : string[150];
    VidSkidki : AllStr;
    LArt : ArtikulStr;
    ReturnCount : Word;
    ControlInfo,ControlCount,ControlSelector,ControlVidOtbora : PView;
    VidOtbora,VidProsmotra : Word;
    LinkList,NoScreenList1: PBox;
    Filtr : Maska2;



Function TestRazdelA(S:ArtikulStr;P:PBox):Boolean;
Var i : Word;
    St : ArtikulStr;
Begin
TestRazdelA := True;
S:=Copy(s,1,CRazdelKod);
If (P^.List<>Nil)And(P^.List^.Count>0) Then
  Begin
   For i:=0 To P^.List^.Count-1 Do
    Begin
     St:=Copy(P^.GetText(i,P^.List^.Count),1,CRazdelKod);
     If St=S Then
      Begin
       TestRazdelA:=False;
       Break;
      End;
    End;
  End;
End;


Function TestElement (Const S : AllStr;Const P : PBox) : Boolean;
Var ls : Word;
    k  : Byte;
    st : String[CALL];
Begin
TestElement:=True;
For ls :=0 To P^.List^.Count Do
Begin
St:=P^.GetText(ls,P^.List^.Count);
k:=Pos('│',St);
ST:=Copy(St,K+1,CArtikul);
If St=S Then
   Begin
    TestElement:=False;
    Break;
   End;
End;
End;

Function TestRazdelClient (Const SC,S : AllStr;Const P : PBox) : Boolean;
Var ls : Word;
    k  : Byte;
    st,sct : String[CALL];
Begin
TestRazdelClient:=True;
For ls :=0 To P^.List^.Count Do
Begin
St:=P^.GetText(ls,P^.List^.Count);
sct:=Copy(St,1,CArtikul);
rformatzerro(sct,CArtikul);
k:=Pos('│',St);
ST:=Copy(St,K+1,CRazdelKod);
if sct=sc then
If St=Copy(S,1,CRazdelKod) Then
   Begin
    TestRazdelClient:=False;
    Break;
   End;
End;
End;


Function TestRazdelMemory (Const S : AllStr;Const P : PBox) : Boolean;
Var ls : Word;
    k  : Byte;
    st : String[CALL];
Begin
TestRazdelMemory:=True;
For ls :=0 To P^.List^.Count Do
Begin
St:=P^.GetText(ls,P^.List^.Count);
k:=Pos('│',St);
ST:=Copy(St,K+1,CRazdelKod);
If St=Copy(S,1,CRazdelKod) Then
   Begin
    TestRazdelMemory:=False;
    Break;
   End;
End;
End;


Procedure GlobalSkidka1(Var P:PBox;Summa:String);
var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  c : Word;
  st : String[CZena];
  ws,Zena : TDateString;
  s : string[150];
  WspomList1:PBox;
  ls : Word;
  k : AllStr;
  Full:Boolean;
begin
If P^.List^.Count>0 Then
Begin

If StrToReal(Summa)<0.009 Then
 Begin
  Messagebox(^M+#3'Недопустимая сумма по документу!',Nil,mfError+mfCancelButton);
  Exit;
 End;

R.Assign(28, 9, 48, 12);
New(Dlg, Init(R, 'Скидка,руб'));
Dlg^.Palette := dpCyanDialog;
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx := $E004;

R.Assign(8, 1, 18, 2);
Control := New(PInputLine, Init(R, CZena));
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));

  R.Assign(1, 1, 8, 2);
  Dlg^.Insert(New(PLabel, Init(R, 'Сумма:', Control)));

Dlg^.SelectNext(False);

st[0]:=#0;

Dlg^.SetData(st);

c:=Desktop^.ExecView(Dlg);

If c<>cmCancel Then
 Begin
  Dlg^.GetData(st);
  Dispose(Control,Done);
  Dispose(Dlg,Done);
  DelSpace(St);

  Full:=False;
  If (StrToReal(Summa)-StrToReal(St))<0.009 Then
   Begin
    Full:=True;
    If StrToReal(Summa)-StrToReal(St)<0.0 Then
     Begin
      MessageBox(^M+#3'Не много ли Вы хотите?'^M+
         #3'Может ему еще выдать деньги из кассы?',Nil,mfError+mfCancelButton);
     End;
   End
  Else
   Begin
    k:=RealToStr(StrToReal(Summa)/(StrToReal(Summa)-StrToReal(St)),CLitr,CLitrMantissa);
   End;


If P^.List^.Count>0 Then
Begin
  R.Assign(0,0,0,0);
  WspomlIST1 := New(PBox, Init(R, 1, Nil));
  WspomList1^.NewList(New(PTextCollection, Init(0,1)));

For ls:=0 To P^.List^.Count-1 Do
 Begin
{артикул}
 s:=P^.GetText(ls,P^.List^.Count);
 Zena:=Copy(s,1+COne+1+CName+1+CArtikul+1+CLitr+1+CKol+1,CZena);
 If Full Then
  Str(StrToReal(Zena):CZena:CMantissa,ws)
 Else
 Begin
  Str(StrToReal(Zena)-StrToReal(Zena)/StrToReal(k):CZena:CMantissa,ws);
 End;
{Удаляем старую ручную скидку}
 System.Delete(s,1+COne+1+CName+1+CArtikul+1+CLitr+1+CKol+1+CZena+1,CZena);
{Добавляем новую ручную скидку}
 System.Insert(ws,S,1+COne+1+CName+1+CArtikul+1+CLitr+1+CKol+1+CZena+1);
{вставляем исправленную строку}
 WspomList1^.List^.Insert(NewStr(s));
 WspomList1^.SetRange(WspomList1^.List^.Count);

End;{For}
{очистка P}

  P^.NewList(Nil);
  P^.NewList(New(PTextCollection, Init(0,1)));

{обновление P}
For ls:=0 To WspomList1^.List^.Count-1 Do
 Begin
{артикул}
 s:=WspomList1^.GetText(ls,WspomList1^.List^.Count);
 P^.List^.Insert(NewStr(s));
 P^.SetRange(P^.List^.Count);
End;{For}

{удаление Wspom}
Dispose(WspomList1,Done);
P^.FocusItem(0);
End;{P^.List^.Count>0}
 End
 Else
 Begin
  Dispose(Control,Done);
  Dispose(Dlg,Done);
 End;
End;{If P^.List^.Count>0 Then}
end;

Procedure GlobalNazenka1(Var P:PBox;Summa:String);
var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  c : Word;
  st : String[CZena];
  ws,Zena : TDateString;
  s : string[150];
  WspomList1:PBox;
  ls : Word;
  k : AllStr;
  Full:Boolean;
begin
If P^.List^.Count>0 Then
Begin

If StrToReal(Summa)<0.009 Then
 Begin
  Messagebox(^M+#3'Недопустимая сумма по документу!',Nil,mfError+mfCancelButton);
  Exit;
 End;

R.Assign(28, 9, 49, 12);
New(Dlg, Init(R, 'Наценка,руб'));
Dlg^.Palette := dpCyanDialog;
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx := $E003;

R.Assign(8, 1, 18, 2);
Control := New(PInputLine, Init(R, CZena));
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));

  R.Assign(1, 1, 8, 2);
  Dlg^.Insert(New(PLabel, Init(R, 'Сумма:', Control)));

Dlg^.SelectNext(False);

st[0]:=#0;

Dlg^.SetData(st);

c:=Desktop^.ExecView(Dlg);

If c<>cmCancel Then
 Begin
  Dlg^.GetData(st);
  Dispose(Control,Done);
  Dispose(Dlg,Done);
  DelSpace(St);

  k:=RealToStr(StrToReal(St)/StrToReal(Summa),CLitr,CLitrMantissa);

If P^.List^.Count>0 Then
Begin

  R.Assign(0,0,0,0);
  WspomlIST1 := New(PBox, Init(R, 1, Nil));
  WspomList1^.NewList(New(PTextCollection, Init(0,1)));

For ls:=0 To P^.List^.Count-1 Do
 Begin
{артикул}
 s:=P^.GetText(ls,P^.List^.Count);
 Zena:=Copy(s,1+COne+1+CName+1+CArtikul+1+CLitr+1+CKol+1,CZena);
 Str(StrToReal(Zena)*StrToReal(k)*(-1):CZena:CMantissa,ws);
{Удаляем старую ручную скидку}
 System.Delete(s,1+COne+1+CName+1+CArtikul+1+CLitr+1+CKol+1+CZena+1,CZena);
{Добавляем новую ручную скидку}
 System.Insert(ws,S,1+COne+1+CName+1+CArtikul+1+CLitr+1+CKol+1+CZena+1);
{вставляем исправленную строку}
 WspomList1^.List^.Insert(NewStr(s));
 WspomList1^.SetRange(WspomList1^.List^.Count);

End;{For}
{очистка P}

  P^.NewList(Nil);
  P^.NewList(New(PTextCollection, Init(0,1)));

{обновление P}
For ls:=0 To WspomList1^.List^.Count-1 Do
 Begin
{артикул}
 s:=WspomList1^.GetText(ls,WspomList1^.List^.Count);
 P^.List^.Insert(NewStr(s));
 P^.SetRange(P^.List^.Count);
End;{For}

{удаление Wspom}
Dispose(WspomList1,Done);
P^.FocusItem(0);

End;{P^.List^.Count>0}
 End
 Else
 Begin
  Dispose(Control,Done);
  Dispose(Dlg,Done);
 End;
End;{If P^.List^.Count>0 Then}
end;




Function TTime:Boolean;
var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  st : TDateString;
  c : Word;
begin
TTime := True;
R.Assign(27, 9, 53, 14);
New(Dlg, Init(R, 'Вы согласны ?'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.Flags := Dlg^.Flags and not wfClose;

R.Assign(1, 2, 25, 3);
Control := New(PColoredText, Init(R, 'Текущее время:'+Times, $9E));
Dlg^.Insert(Control);
Dlg^.HelpCtx:=$E241;

Dlg^.SelectNext(False);


c:=Desktop^.ExecView(dlg);
If c<>cmCancel Then
 Begin
  Dispose(Control,Done);
  Dispose(Dlg,Done);
  TTime:=True;
 End
 Else
 Begin
  TTime := False;
  Dispose(Control,Done);
  Dispose(Dlg,Done);
  Application^.Done;
  Halt;
 End;
End;
(*

Procedure Unique(Path: string[150]; Var FileName: String);
Var
  reg: TRegisters;
  i: integer;
  ErrCode: Byte;
  f : Text;
begin                                      { Unique }
Repeat
  FileName:='';
  if Path='' then Exit;
  for i:=1 to 15 do Path:=concat(Path,#0);
  reg.ds:=Seg(Path[1]); reg.dx:=Ofs(Path[1]);
  reg.cx:=0;
  reg.ah:=$5A;
  MsDos(reg);
  ErrCode:=0;
  if (reg.flags AND FCarry)=1 then ErrCode:=reg.ax;
  if ErrCode=0 then
  begin
    FileName:=Path;
    i:=1;
    while (i<length(FileName)) and (FileName[i]<>#0) do Inc(i);
    if FileName[i]=#0 then Delete(FileName,i,length(FileName)-i+1);
    {Now delete the zero length file created by DOS}
    Assign(f,FileName);
    Rewrite(f);
    ErrCode:=IOresult;
    If ErrCode<>0 Then
      MessageBox(^M+#3'Ошибка создания '+FileName+'!'^M+
      ClicProgrammer+' (Код:'+IntToStr(i,2)+')',Nil,mfFatalError+mfCancelButton)
    Else
     Close(f);
    i:=IOResult;
    {reg.ds:=Seg(Path[1]); reg.dx:=Ofs(Path[1]);
    reg.ah:=$3E;
    reg.bx:=reg.ax;
    MsDos(reg);}
  end;
  DosError:=ErrCode;
  i:=IOResult;
Until (ErrCode=0);
  DosError:=0;
end;                                      { Unique }

*)

  function HexB(B : Byte) : string;
    {-Return hex string for byte}
  begin
    HexB[0] := #2;
    HexB[1] := Digits[B shr 4];
    HexB[2] := Digits[B and $F];
  end;


Function AssignTemp(VAr f1:Text;St:String):string;
VAr c,cd,cd1 : Word;
    s,s1 : string[150];
    r : Byte;
    Stop : Boolean;
    M:Maska8;
Begin
c:=IOResult;
DosError:=0;

Stop:=FAlse;
While Not(Stop) Do
Begin
cd:=Random(999);
cd1:=Random(999);

{WordToBit8(cd,m);}
s:=IntToSTr(cd,3);
RFormatZerro(s,3);
s1:=IntToSTr(cd1,3);
RFormatZerro(s1,3);
{for c:=1 to Max8 Do s:=s+IntToSTr(m[c],COne);}
s:='$'+s+'$'+s1+'.tmp';
If Not(FExists(st+s)) Then
 Begin
  Assign(f1,st+s);
  c:=IOResult;
  Rewrite(f1);
  c:=IOResult;
  If c=0 Then
  Begin
  c:=IOResult;
  Close(f1);
  Stop:=True;
  AssignTemp:=st+s;
  Break;
  End;
 End;
End;{While}
c:=IOResult;
End;



  function Crypt(S : String) : string;
    {-simple self-reversing xor encryption}
  var
    SI, KI : Byte;
    T : string[150];
  begin
    T := '';
    KI := 1;
    for SI := 1 to Length(S) do begin
      T := T + Chr(Byte(S[SI]) xor Byte(EncryptionKey[KI]));
      Inc(KI);
      if KI > Length(EncryptionKey) then
        KI := 1;
    end;
    Crypt := T;
  end;


  function Encrypt(S : String) : string;
    {-Convert S to XOR-encrypted string, then "hex-ize"}
  var
    T, U : string[150];
    I : Integer;
  begin
    U := '';
    T := Crypt(S);
    for I := 1 to Length(T) do
      U := U + HexB(Byte(T[i]));
    Encrypt := U;
  end;




  function Decrypt(S : String) : string;
    {-Convert "hex-ized" string to encrypted raw string, and decrypt}
  var
    T,U : string[150];
    I,C : Integer;
  begin
    T := '';
    while S <> '' do begin
      U := '$'+Copy(S, 1, 2);
      Delete(S, 1, 2);
      Val(U, I, C);
      T := T + Char(I);
    end;
    Decrypt := Crypt(T);
  end;



Procedure WordToBitBak (n:Word; Var b : MaskaBak);
  Var i : Word;
Begin
 For i:=Bit5 DownTo 1 Do
  Begin
   if odd(n) Then b[i]:=1 Else b[i]:=0;
   n:=n Shr 1;
  End;
End;

Procedure WordToBitNew (n:Word; Var b : MaskaNew);
  Var i : Word;
Begin
 For i:=Bit8 DownTo 1 Do
  Begin
   if odd(n) Then b[i]:=1 Else b[i]:=0;
   n:=n Shr 1;
  End;
End;

Procedure WordToBit2 (n:Word; Var b : Maska2);
  Var i : Word;
Begin
 For i:=2 DownTo 1 Do
  Begin
   if odd(n) Then b[i]:=1 Else b[i]:=0;
   n:=n Shr 1;
  End;
End;

Procedure WordToBit3 (n:Word; Var b : Maska3);
  Var i : Word;
Begin
 For i:=3 DownTo 1 Do
  Begin
   if odd(n) Then b[i]:=1 Else b[i]:=0;
   n:=n Shr 1;
  End;
End;

Procedure WordToBit4 (n:Word; Var b : Maska4);
  Var i : Word;
Begin
 For i:=4 DownTo 1 Do
  Begin
   if odd(n) Then b[i]:=1 Else b[i]:=0;
   n:=n Shr 1;
  End;
End;


Procedure WordToBit16 (n:Word; Var b : Maska16);
  Var i : Word;
Begin
 For i:=15 DownTo 1 Do
  Begin
   if odd(n) Then b[i]:=1 Else b[i]:=0;
   n:=n Shr 1;
  End;
End;

Procedure WordToBit16New (n:Word; Var b : Maska16new);
  Var i : Word;
Begin
 For i:=15 DownTo 0 Do
  Begin
   if odd(n) Then b[i]:=1 Else b[i]:=0;
   n:=n Shr 1;
  End;
End;


Procedure WordToBit40 (n:Word; Var b : Maska40);
  Var i : Word;
Begin
 For i:=40 DownTo 1 Do
  Begin
   if odd(n) Then b[i]:=1 Else b[i]:=0;
   n:=n Shr 1;
  End;
End;

Procedure WordToBit100 (n:Word; Var b : Maska100);
  Var i : Word;
Begin
 For i:=Max100 DownTo 1 Do
  Begin
   if odd(n) Then b[i]:=1 Else b[i]:=0;
   n:=n Shr 1;
  End;
End;




Procedure WordToBit6 (n:Word; Var b : Maska6);
  Var i : Word;
Begin
 For i:=6 DownTo 1 Do
  Begin
   if odd(n) Then b[i]:=1 Else b[i]:=0;
   n:=n Shr 1;
  End;
End;


Procedure WordToBit5 (n:Word; Var b : Maska5);
  Var i : Word;
Begin
 For i:=5 DownTo 1 Do
  Begin
   if odd(n) Then b[i]:=1 Else b[i]:=0;
   n:=n Shr 1;
  End;
End;

Procedure WordToBit7 (n:Word; Var b : Maska7);
  Var i : Word;
Begin
 For i:=7 DownTo 1 Do
  Begin
   if odd(n) Then b[i]:=1 Else b[i]:=0;
   n:=n Shr 1;
  End;
End;

Procedure WordToBit8 (n:Word; Var b : Maska8);
  Var i : Word;
Begin
 For i:=8 DownTo 1 Do
  Begin
   if odd(n) Then b[i]:=1 Else b[i]:=0;
   n:=n Shr 1;
  End;
End;

Procedure WordToBit9 (n:Word; Var b : Maska9);
  Var i : Word;
Begin
 For i:=Max9 DownTo 1 Do
  Begin
   if odd(n) Then b[i]:=1 Else b[i]:=0;
   n:=n Shr 1;
  End;
End;

Procedure WordToBit10 (n:Word; Var b : Maska10);
  Var i : Word;
Begin
 For i:=Max10 DownTo 1 Do
  Begin
   if odd(n) Then b[i]:=1 Else b[i]:=0;
   n:=n Shr 1;
  End;
End;

Function Stepen(i:Word):Word;
Var j,l: Word;
Begin
 Stepen:=1;
 j:=1;
 For l:=1 To i Do j:=j*2;
 Stepen:=j;
End;


Procedure BitToWordBak ( b : MaskaBak; Var n:Word);
  Var i : Word;
Begin
 N:=0;
 For i:=1 To Bit5 Do
  Begin
  N:=N+b[i]*Stepen(Bit5-i);
  End;
End;


Procedure BitToWordNew ( b : MaskaNew; Var n:Word);
  Var i : Word;
Begin
 N:=0;
 For i:=1 To Bit8 Do
  Begin
  N:=N+b[i]*Stepen(Bit8-i);
  End;
End;

Procedure BitToWord16 ( b : Maska16; Var n:Word);
  Var i : Word;
Begin
 N:=0;
 For i:=1 To 15 Do
  Begin
  N:=N+b[i]*Stepen(15-i);
  End;
End;

Procedure BitToWord16new ( b : Maska16new; Var n:Word);
  Var i : Word;
Begin
 N:=0;
 For i:=0 To 15 Do
  Begin
  N:=N+b[i]*Stepen(15-i);
  End;
End;


Procedure BitToWord2 ( b : Maska2; Var n:Word);
  Var i : Word;
Begin
 N:=0;
 For i:=1 To 2 Do
  Begin
  N:=N+b[i]*Stepen(2-i);
  End;
End;

Procedure BitToWord4( b : Maska4; Var n:Word);
  Var i : Word;
Begin
 N:=0;
 For i:=1 To 4 Do
  Begin
  N:=N+b[i]*Stepen(4-i);
  End;
End;


Procedure BitToWord40( b : Maska40; Var n:Word);
  Var i : Word;
Begin
 N:=0;
 For i:=1 To 40 Do
  Begin
  N:=N+b[i]*Stepen(2-i);
  End;
End;

Procedure BitToWord100( b : Maska100; Var n:Word);
  Var i : Word;
Begin
 N:=0;
 For i:=1 To Max100 Do
  Begin
  N:=N+b[i]*Stepen(2-i);
  End;
End;


Procedure BitToWord3 ( b : Maska3; Var n:Word);
  Var i : Word;
Begin
 N:=0;
 For i:=1 To 3 Do
  Begin
  N:=N+b[i]*Stepen(3-i);
  End;
End;

Procedure Invert3 ( Var b : Maska3);
Var i : Word;
Begin
 For i:=1 To 3 Do
  Begin
  If b[i]=1 Then b[i]:=0
  Else b[i]:=1;
  End;
End;

Procedure Invert2 ( Var b : Maska2);
Var i : Word;
Begin
 For i:=1 To 2 Do
  Begin
  If b[i]=1 Then b[i]:=0
  Else b[i]:=1;
  End;
End;

Procedure BitToWord6 ( b : Maska6; Var n:Word);
  Var i : Word;
Begin
 N:=0;
 For i:=1 To 6 Do
  Begin
  N:=N+b[i]*Stepen(6-i);
  End;
End;


Procedure BitToWord5 ( b : Maska5; Var n:Word);
  Var i : Word;
Begin
 N:=0;
 For i:=1 To 5 Do
  Begin
  N:=N+b[i]*Stepen(5-i);
  End;
End;


Procedure BitToWord7 ( b : Maska7; Var n:Word);
  Var i : Word;
Begin
 N:=0;
 For i:=1 To 7 Do
  Begin
  N:=N+b[i]*Stepen(7-i);
  End;
End;

Procedure BitToWord8 ( b : Maska8; Var n:Word);
  Var i : Word;
Begin
 N:=0;
 For i:=1 To 8 Do
  Begin
  N:=N+b[i]*Stepen(8-i);
  End;
End;

Procedure BitToWord9 ( b : Maska9; Var n:Word);
  Var i : Word;
Begin
 N:=0;
 For i:=1 To Max9 Do
  Begin
  N:=N+b[i]*Stepen(Max9-i);
  End;
End;

Procedure BitToWord10 ( b : Maska10; Var n:Word);
  Var i : Word;
Begin
 N:=0;
 For i:=1 To Max10 Do
  Begin
  N:=N+b[i]*Stepen(Max10-i);
  End;
End;

Procedure ConvertBak(Var b:MaskaBak);
Var l : Byte;
Begin
 l:=b[1];
 b[1]:=b[5];
 b[5]:=l;
 l:=b[2];
 b[2]:=b[4];
 b[4]:=l;
End;



Procedure ConvertNew(Var b:MaskaNew);
Var l : Byte;
Begin
 l:=b[1];
 b[1]:=b[8];
 B[8]:=l;
 l:=b[2];
 b[2]:=b[7];
 B[7]:=l;
 l:=b[3];
 b[3]:=b[6];
 B[6]:=l;
 l:=b[4];
 b[4]:=b[5];
 B[5]:=l;
End;



Procedure Convert7(Var b:Maska7);
Var l,k : Byte;
    w : Maska7;
Begin
 k:=7;
 For l:=1 To 7 Do
  Begin
  w[k]:=b[l];
  Dec(k);
  End;
  b:=w;
End;


Procedure Convert16(Var b:Maska16);
Var l,k : Byte;
    w : Maska16;
Begin
 k:=15;
 For l:=1 To 15 Do
  Begin
  w[k]:=b[l];
  Dec(k);
  End;
  b:=w;
End;

Procedure Convert16new(Var b:Maska16new);
Var l,k : Byte;
    w : Maska16new;
Begin
 k:=15;
 For l:=0 To 15 Do
  Begin
  w[k]:=b[l];
  Dec(k);
  End;
  b:=w;
End;



Procedure Convert6(Var b:Maska6);
Var l,k : Byte;
    w : Maska6;
Begin
 k:=6;
 For l:=1 To 6 Do
  Begin
  w[k]:=b[l];
  Dec(k);
  End;
  b:=w;

End;


Procedure Convert40(Var b:Maska40);
Var l,k : Byte;
    w : Maska40;
Begin
 k:=40;
 For l:=1 To 40 Do
  Begin
  w[k]:=b[l];
  Dec(k);
  End;
  b:=w;

End;

Procedure Convert100(Var b:Maska100);
Var l,k : Byte;
    w : Maska100;
Begin
 k:=100;
 For l:=1 To 100 Do
  Begin
  w[k]:=b[l];
  Dec(k);
  End;
  b:=w;

End;

Procedure Convert5(Var b:Maska5);
Var l,k : Byte;
    w : Maska5;
Begin
 k:=5;
 For l:=1 To 5 Do
  Begin
  w[k]:=b[l];
  Dec(k);
  End;
  b:=w;
End;



Procedure Convert8(Var b:Maska8);
Var l,k : Byte;
    w : Maska8;
Begin
 k:=8;
 For l:=1 To 8 Do
  Begin
  w[k]:=b[l];
  Dec(k);
  End;
  b:=w;
End;

Procedure Convert9(Var b:Maska9);
Var l,k : Byte;
    w : Maska9;
Begin
 k:=Max9;
 For l:=1 To Max9 Do
  Begin
  w[k]:=b[l];
  Dec(k);
  End;
  b:=w;
End;

Procedure Convert10(Var b:Maska10);
Var l,k : Byte;
    w : Maska10;
Begin
 k:=Max10;
 For l:=1 To Max10 Do
  Begin
  w[k]:=b[l];
  Dec(k);
  End;
  b:=w;
End;

Procedure Convert4(Var b:Maska4);
Var l,k : Byte;
    w : Maska4;
Begin
 k:=Max4;
 For l:=1 To Max4 Do
  Begin
  w[k]:=b[l];
  Dec(k);
  End;
  b:=w;
End;

Procedure Convert3(Var b:Maska3);
Var l : Byte;
Begin
 l:=b[1];
 b[1]:=b[3];
 b[3]:=l;
End;


Procedure Convert2(Var b:Maska2);
Var l : Byte;
Begin
 l:=b[1];
 b[1]:=b[2];
 b[2]:=l;
End;





function KeyPressed: Boolean; assembler;
asm
 mov ah, 1
 int 16h
 mov ax,1
 jnz @@1
 xor ax,ax
 @@1:
end;



procedure RunScreenSaver;
Var c: Word;
    Event: TEvent;
begin
end;





(*
Procedure SetupPassword;
var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  ArrayPsw : Array [1..9] Of String[10];
  CodePsw : Array [1..9] Of String[20];
  f : Text;
  c : Word;
begin
     For c:=1 To 9 Do
      Begin
       ArrayPsw[c,0]:=#0;
      End;
  Assign(f,'c:\windows\p.pwl');
  c:=IOResult;
  Reset(f);
  c:=IOResult;
  If c=0 Then
   Begin
    c:=0;
    While Not(Eof(f)) And (c<9) Do
    Begin
     Inc(c);
     Readln(f,CodePsw[c]);
     ArrayPsw[c]:=Decrypt(CodePsw[c]);
    End;
    c:=IOResult;
    Close(f);
   End
   Else
    Begin
     For c:=1 To 9 Do
      Begin
       ArrayPsw[c,0]:=#0;
      End;
    End;

R.Assign(23, 6, 56, 17);
New(Dlg, Init(R, 'Настройка паролей'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.Palette := dpCyanDialog;
Dlg^.HelpCtx := $E002;

R.Assign(20, 1, 32, 2);
Control := New(PInputLine, Init(R, 10));
Dlg^.Insert(Control);

  R.Assign(1, 1, 20, 2);
  Dlg^.Insert(New(PLabel, Init(R, 'Уровень доступа ~1~:', Control)));

R.Assign(20, 2, 32, 3);
Control := New(PInputLine, Init(R, 10));
Dlg^.Insert(Control);

  R.Assign(1, 2, 20, 3);
  Dlg^.Insert(New(PLabel, Init(R, 'Уровень доступа ~2~:', Control)));

R.Assign(20, 3, 32, 4);
Control := New(PInputLine, Init(R, 10));
Dlg^.Insert(Control);

  R.Assign(1, 3, 20, 4);
  Dlg^.Insert(New(PLabel, Init(R, 'Уровень доступа ~3~:', Control)));

R.Assign(20, 4, 32, 5);
Control := New(PInputLine, Init(R, 10));
Dlg^.Insert(Control);

  R.Assign(1, 4, 20, 5);
  Dlg^.Insert(New(PLabel, Init(R, 'Уровень доступа ~4~:', Control)));

R.Assign(20, 5, 32, 6);
Control := New(PInputLine, Init(R, 10));
Dlg^.Insert(Control);

  R.Assign(1, 5, 20, 6);
  Dlg^.Insert(New(PLabel, Init(R, 'Уровень доступа ~5~:', Control)));

R.Assign(20, 6, 32, 7);
Control := New(PInputLine, Init(R, 10));
Dlg^.Insert(Control);

  R.Assign(1, 6, 20, 7);
  Dlg^.Insert(New(PLabel, Init(R, 'Уровень доступа ~6~:', Control)));

R.Assign(20, 7, 32, 8);
Control := New(PInputLine, Init(R, 10));
Dlg^.Insert(Control);

  R.Assign(1, 7, 20, 8);
  Dlg^.Insert(New(PLabel, Init(R, 'Уровень доступа ~7~:', Control)));

R.Assign(20, 8, 32, 9);
Control := New(PInputLine, Init(R, 10));
Dlg^.Insert(Control);

  R.Assign(1, 8, 20, 9);
  Dlg^.Insert(New(PLabel, Init(R, 'Уровень доступа ~8~:', Control)));

R.Assign(20, 9, 32, 10);
Control := New(PInputLine, Init(R, 10));
Dlg^.Insert(Control);

  R.Assign(1, 9, 20, 10);
  Dlg^.Insert(New(PLabel, Init(R, 'Уровень доступа ~9~:', Control)));

Dlg^.SelectNext(False);

Dlg^.SetData(ArrayPsw);

c:=Desktop^.ExecView(Dlg);
If c<>cmCancel Then
 Begin
  Dlg^.GetData(ArrayPsw);

       Assign(f,'c:\windows\p.pwl');
       c:=IOResult;
       Rewrite(f);
       c:=IOResult;

     For c:=1 To 9 Do
      Begin
       CodePsw[c]:=Encrypt(ArrayPsw[c]);
       Writeln(f,CodePsw[c]);
      End;
       Close(f);
       c:=IOResult;
      AddProtocol ('Корректировка уровней доступа в системе!  {Очень важно}','','');
End;

Dispose(Control,Done);
Dispose(Dlg,Done);
end;

*)



Function TFullScreenMrk.FullScreenMrk(Ass:DocumentEdit):Boolean;
{
(Const P:PBox;Const s,s1:String;SDoc,SClientKod,SAgentKod:ArtikulStr;SDate:TDateString;
    t,V:Byte):Boolean;
}
var
  R : TRect;
  ws,s,s1,St,s2 : string[150];
  AgName,ClName : AllStr;
  c,i : Word;
  ff,ff1,ff2 : string[150];
  F : MArketFileType;
  E :PSuperMarketType;
  Find:Boolean;
    SKolish,SDoc,SClientKod,SAgentKod : ArtikulStr;
    SCommentr : string[150];
    SDate : TDateString;
    ws1,WspomSkidka:String[CIZena];

begin
FullScreenMrk:=False;

  Assign(f,Path.ToMarket+Ass.d+'.mrk');
  c:=IOResult;
  Reset(f);
  c:=IOResult;
  If c<>0 Then
  Begin
   MessageBox(#3^M+#3'Ошибка доступа к файлу '+Path.ToMarket+Ass.d+'.mrk',Nil,mfError+mfCancelButton);
   Exit;
  End;
  DInfoMsg('Ищу документ...');
  New(E,Init);

  Find := False;
  ClearChar(Ass.EditPosition);
  DelSpace(Ass.D);
  While Not(Eof(f)) And Not(Find) Do
   Begin
    ReadMarket(F,E);
    ClearChar(E^.Dat.Document);
    If (E^.Dat.Active) And (E^.Dat.DateC=Ass.D) and
    (StrToInt(E^.Dat.Document)=StrToInt(Ass.EditPosition)) Then
          Begin
           Find:=True;
           Break;
          End;
   End;
   System.Close(f);
   NoInfoMsg;

If Not Find Then
  Begin
   Dispose(E,Done);
   MessageBox(#3^M+#3'Искомый документ не найден!',Nil,mfError+mfCancelButton);
   Exit;
  End;

DInfoMsg('Формирую документы...');
ClearFind;
ProdagaWindow:=True;


{Формируем список позиций в перемешку товар и сертификаты}
  R.Assign(0,0,0,0);
  NoScreenList1 := New(PBox, Init(R, 1, Nil));
  NoScreenList1^.NewList(New(PTextCollection, Init(0,1)));

{вставляем в список товары}
For c:=1 To E^.Dat.Amount Do
 Begin
  S:=E^.Dat.MarketElement[c].BazKod;
  ws:=GetIdField(FName,s);
  Format(ws,CName);
  s:=s+'│'+ws+'│';
  Str(E^.Dat.MarketElement[c].Input.DivisionSNumber:1,ws);
  s:=s+ws;



  DelSpace(E^.Dat.MarketElement[c].Input.Kol);
  RFormat(E^.Dat.MarketElement[c].Input.Kol,CKol);
  s:=s+'│'+E^.Dat.MarketElement[c].Input.Kol;
  {  ws:=GetIdField(FLitr,E^.Dat.MarketElement[c].BazKod);
  Format(Ws,CLitr);
  s:=s+'│'+ws;}
  DelSpace(E^.Dat.MarketElement[c].Input.Zena);
  RFormat(E^.Dat.MarketElement[c].Input.Zena,CZena);
  s:=s+'│'+E^.Dat.MarketElement[c].Input.Zena;

      Case E^.Dat.SkidkaSelector Of
      0:Begin{скидка автоматическая}

         MyStr(StrToReal(E^.Dat.MarketElement[c].Input.Zena)-StrToReal(E^.Dat.MarketElement[c].Input.Zena)*
             StrToReal(E^.Dat.MarketElement[c].Input.Proz),CZena,CMantissa,E^.Dat.MarketElement[c].Input.Skidka);

         MyStr(StrToReal(E^.Dat.MarketElement[c].Input.Skidka),CZena,CMantissa,E^.Dat.MarketElement[c].Input.Skidka);

         MyStr(StrToReal(E^.Dat.MarketElement[c].Input.Zena)*
             StrToReal(E^.Dat.MarketElement[c].Input.Proz),CZena,CMantissa,wspomSkidka);

         MyStr((1-StrToReal(E^.Dat.MarketElement[c].Input.Proz))*100,CLitr+1,CLitrMantissa+1,
      E^.Dat.MarketElement[c].Input.Proz);
         MyStr(StrToReal(E^.Dat.MarketElement[c].Input.Proz),CZena,CLitrMantissa+1,ws1);

         S:=s+'│'+WspomSkidka+'║'+E^.Dat.MarketElement[c].Input.Skidka+'│'+ws1+'║';
        End;
      1:Begin{скидка ручная}
          if StrToReal(E^.Dat.MarketElement[c].Input.Zena)>0.005 then
          MyStr((StrToReal(E^.Dat.MarketElement[c].Input.Zena)-
          StrToReal(E^.Dat.MarketElement[c].Input.Skidka))/StrToReal(E^.Dat.MarketElement[c].Input.Zena)
          ,CZena,CLitrMantissa+1,ws1)
          else ws1:='0.00';

          MyStr((1-StrToReal(Ws1))*100,CZena,CLitrMantissa+1,ws1);
          MyStr(StrToReal(E^.Dat.MarketElement[c].Input.Skidka),CZena,CMantissa,E^.Dat.MarketElement[c].Input.Skidka);

          MyStr((StrToReal(E^.Dat.MarketElement[c].Input.Zena)-StrToReal(E^.Dat.MarketElement[c].Input.Skidka))
          ,CZena,CMantissa,wspomskidka);

          S:=s+'│'+WspomSkidka+'║'+E^.Dat.MarketElement[c].Input.Skidka+'│'+ws1+'║';
        End;
      2:Begin{скидка ручная по шкале}

         MyStr(StrToReal(E^.Dat.MarketElement[c].Input.Zena)-StrToReal(E^.Dat.MarketElement[c].Input.Zena)*
             StrToReal(E^.Dat.MarketElement[c].Input.Proz),CZena,CMantissa,E^.Dat.MarketElement[c].Input.Skidka);

         MyStr(StrToReal(E^.Dat.MarketElement[c].Input.Skidka),CZena,CMantissa,E^.Dat.MarketElement[c].Input.Skidka);

         MyStr(StrToReal(E^.Dat.MarketElement[c].Input.Zena)*
             StrToReal(E^.Dat.MarketElement[c].Input.Proz),CZena,CMantissa,wspomSkidka);

         MyStr((1-StrToReal(E^.Dat.MarketElement[c].Input.Proz))*100,CLitr+1,CLitrMantissa+1,
      E^.Dat.MarketElement[c].Input.Proz);
         MyStr(StrToReal(E^.Dat.MarketElement[c].Input.Proz),CZena,CLitrMantissa+1,ws1);

         S:=s+'│'+WspomSkidka+'║'+E^.Dat.MarketElement[c].Input.Skidka+'│'+ws1+'║';
        End;

      Else;
      End;{E^.Dat.SkidkaSelector}

  SKolish[0]:=#0;
  SCommentr[0]:=#0;
  CalcReturnPosition(E^.Dat.Document,E^.Dat.DateC,E^.Dat.ClientKod,E^.Dat.MarketElement[c].BazKod,
  IntToStr(E^.Dat.MarketElement[c].Input.DivisionSNumber,COne),E^.Dat.OperatorSelector,Skolish,SCommentr);
  Format(SKolish,CKol);
  s:=s+SKolish+'│'+sCommentr;
  NoScreenList1^.List^.Insert(NewStr(s));
  NoScreenList1^.SetRange(NoScreenList1^.List^.Count);
 End;


{вставляем в список сертификаты}

Case E^.Dat.SkidkaSelector Of
0:Vidskidki:='(Авто)';
1:Vidskidki:='(Ручная)';
2:Vidskidki:='(Шкала: '+IntToStr(E^.Dat.ShkalaNumer,CMantissa)+')';
Else Vidskidki:='???';
End;


R.Assign(0, 0, 80, 23);
New(MrkWin, Init(R, 'Просмотр документа'));
MrkWin^.HelpCtx:={E091}$E556;


R.Assign(1, 1, 8, 2);
Control := New(PColoredText, Init(R, 'Клиент:', $74));
MrkWin^.Insert(Control);

ClName:=GetClientField(FClient,E^.Dat.ClientKod,E^.Dat.OperatorSelector);
Format(ClName,CClient);
R.Assign(8, 1, 35, 2);
Control := New(PColoredText, Init(R, #3+ClName+'│'+E^.Dat.ClientKod, $1F));
MrkWin^.Insert(Control);

AgName:=GetAgentField(FAgent,E^.Dat.AgentKod);
Format(AgName,CClient);
R.Assign(37, 1, 64, 2);
Control := New(PColoredText, Init(R, #3+AgName+'│'+E^.Dat.AgentKod, $1F));
MrkWin^.Insert(Control);

Dispose(E,Done);

R.Assign(65, 1, 73, 2);
ControlRZ := New(PColoredText, Init(R, 'Возврат:', $77{74}));
MrkWin^.Insert(ControlRZ);

R.Assign(73, 1, 78, 2);
ControlR := New(PColoredText, Init(R, #3+'', $77{1f}));
MrkWin^.Insert(ControlR);

R.Assign(1, 2, 79, 2);
ControlText := New(PColoredText, Init(R, #3+'', $5E));
MrkWin^.Insert(ControlText);

R.Assign(79, 4, 80, 21);
Control := New(PScrollBar, Init(R));
MrkWin^.Insert(Control);


ReturnCount:=0;

R.Assign(1, 4, 79, 21);
ControlFull := New(PBox, Init(R, 1, PScrollbar(Control)));
ControlFull^.NewList(New(PTextCollection, Init(0,1)));
If (NoScreenList1^.List^.Count-1)>=0 Then
For i:=0 To NoScreenList1^.List^.Count-1 Do
 Begin
  st :=NoScreenList1^.GetText(i,NoScreenList1^.List^.Count);
  s2:=Copy(st,StartPos,CKol);

  If StrToInt(s2)>0 Then Inc(ReturnCount);
  ControlFull^.List^.Insert(NewStr(St));
  ControlFull^.SetRange(ControlFull^.List^.Count);
 End;

ControlFull^.HelpCtx:={E091}$E556;

ControlFull^.FocusItem(0);

MrkWin^.Insert(ControlFull);

  R.Assign(1, 3, 79, 4);
  MrkWin^.Insert(New(PLabel, Init(R,
  ' Код  Выбранн~ы~е товары           N Колич Цена лоб Цена опл  Скидка   Процент', ControlFull)));

R.Assign(1, 21, 54, 22);
ControlFullNAme := New(PColoredText, Init(R, #3+'', $7e));
MrkWin^.Insert(ControlFullNAme);

Str(ControlFull^.List^.Count:CMantissa,st);
R.Assign(53, 0, 71, 1);
ControlCount := New(PColoredText, Init(R, 'Всего позиций:'+st, $4E));
MrkWin^.Insert(ControlCount);

If ReturnCount>0 Then
Begin
R.Assign(26, 2, 52, 3);
ControlMsg := New(PColoredText, Init(R, #3' Возрат по '+InttoStr(ReturnCount,CMantissa)+' позиции(ям)', $5E));
ControlMsg^.Options := ControlMsg^.Options or ofCenterX;
End
Else
Begin
R.Assign(26, 2, 52, 3);
ControlMsg := New(PColoredText, Init(R, #3+' Возратов не было !!!', $5E));
ControlMsg^.Options := ControlMsg^.Options or ofCenterX;
End;
MrkWin^.Insert(ControlMsg);


DelZerro(Ass.EditPosition);
R.Assign(2, 0, 28, 1);
Control := New(PColoredText, Init(R, 'Документ:'+Ass.EditPosition+' от '+Ass.D, $4E));
MrkWin^.Insert(Control);

s1:='???';
R.Assign(1, 22, 2+Ord(s1[0]), 23);
ControlInfo := New(PColoredText, Init(R, #3+S1, $4E));
ControlInfo^.Options := ControlInfo^.Options or ofCenterX;
MrkWin^.Insert(ControlInfo);



MrkWin^.SelectNext(False);

CurrentLine[0]:=#0;


Refresh;

CalcItogo;

NoInfoMsg;

i := Desktop^.ExecView(MrkWin);
ProdagaWindow:=False;
ClearFind;
If i=cmOk Then FullScreenMrk:=True;
Dispose(Control,Done);
{
Dispose(ControlSelector,Done);
Dispose(ControlCount,Done);
Dispose(ControlInfo,Done);
}
Dispose(MrkWin,Done);
Dispose(NoScreenList1,Done);

end;

procedure TFullScreenMrk.HandleEvent(var Event: TEvent);

procedure Calculator;
begin
  Calc^.Start;
end;

Var s : string[150];
    Prom : Word;
Begin

Case Event.What Of
 evCommand :
   Case Event.Command Of
        cmLocalCalc:Calculator;
        Else;
        End;
 Else;
 End;

inherited HandleEvent(Event);

if (ControlFull^.State and sfFocused <> 0) And(ControlFull^.List<>Nil) And (ControlFull^.List^.Count>=1)Then
        Begin
    s:=ControlFull^.GetText(ControlFull^.Focused,ControlFull^.List^.Count);
    If s <> CurrentLine Then
     Begin
      DrawCurrent(s);
     End
   End;



End;

procedure TFullScreenMrk.DrawCurrent(s: String);
Var s1,s2,s3,s4: string[150];
    R : TRect;
    Art : ArtikulStr;
    f1,f2 : string[150];
Begin

s1:=Copy(s,StartPos,CKol);
If StrToInt(s1)>0 Then
 Begin

 Dispose(ControlFullName,Done);
 Art:=Copy(s,1,CArtikul);
 f1:=GetIdField(FFFName,Art);
 DelSpaceRight(f1);
 R.Assign(1, 21, 65, 22);
 ControlFullName := New(PColoredText, Init(R, f1, $7e));
 MrkWin^.Insert(ControlFullName);


 Dispose(ControlRZ,Done);
 R.Assign(65, 1, 73, 2);
 ControlRZ := New(PColoredText, Init(R, 'Возврат:', $74));
 MrkWin^.Insert(ControlRZ);

 Dispose(ControlR,Done);
 R.Assign(73, 1, 78, 2);
 ControlR := New(PColoredText, Init(R, #3+IntToStr(StrToInt(s1),CKol), $1F));
 MrkWin^.Insert(ControlR);

 Dispose(ControlMsg,Done);
If ReturnCount>0 Then
 Begin
  R.Assign(26, 2, 52, 3);
  ControlMsg := New(PColoredText, Init(R, #3+' Возрат по '+InttoStr(ReturnCount,CMantissa)+' позиции(ям)', $77));
  ControlMsg^.Options := ControlMsg^.Options or ofCenterX;
 End
 Else
 Begin
  R.Assign(26, 2, 52, 3);
  ControlMsg := New(PColoredText, Init(R, #3+' Возратов не было !', $77));
  ControlMsg^.Options := ControlMsg^.Options or ofCenterX;
 End;
 MrkWin^.Insert(ControlMsg);


 s2:=Copy(s,StartPos+CKol+1,Ord(s[0])-StartPos-CKol-1);
 Dispose(ControlText,Done);
 R.Assign(1, 2, 1+Ord(s[0])-StartPos-CKol, 3);
 ControlText := New(PColoredText, Init(R, s2, $5E{de}));
 ControlText^.Options := ControlText^.Options or ofCenterX;

 MrkWin^.Insert(ControlText);
 End
Else
 Begin
 Dispose(ControlFullName,Done);
 Art:=Copy(s,1,CArtikul);
 f1:=GetIdField(FFFName,Art);
 DelSpaceRight(f1);
 R.Assign(1, 21, 65, 22);
 ControlFullName := New(PColoredText, Init(R, f1, $7e));
 MrkWin^.Insert(ControlFullName);

 Dispose(ControlRZ,Done);
 R.Assign(65, 1, 73, 2);
 ControlRZ := New(PColoredText, Init(R, 'Возврат:', $77));
 MrkWin^.Insert(ControlRZ);

 Dispose(ControlR,Done);
 R.Assign(73, 1, 78, 2);
 ControlR := New(PColoredText, Init(R, #3+IntToStr(StrToInt(s1),CKol), $77));
 MrkWin^.Insert(ControlR);

 s2:=Copy(s,StartPos+CKol+1,Ord(s[0])-StartPos+CKol+1);
 Dispose(ControlText,Done);
 R.Assign(1, 2, 79, 3);
 ControlText := New(PColoredText, Init(R, #3+'', $77));
 ControlText^.Options := ControlText^.Options or ofCenterX;
 MrkWin^.Insert(ControlText);

 Dispose(ControlMsg,Done);
If ReturnCount>0 Then
 Begin
  R.Assign(26, 2, 52, 3);
  ControlMsg := New(PColoredText, Init(R, #3+' Возрат по '+InttoStr(ReturnCount,CMantissa)+' позиции(ям)', $5E));
  ControlMsg^.Options := ControlMsg^.Options or ofCenterX;
 End
 Else
 Begin
  R.Assign(26, 2, 52, 3);
  ControlMsg := New(PColoredText, Init(R, #3+' Возратов не было !', $5E));
  ControlMsg^.Options := ControlMsg^.Options or ofCenterX;
 End;
 MrkWin^.Insert(ControlMsg);


 End;
Redraw;
CurrentLine:=s;
End;

procedure TFullScreenMrk.Refresh;
Var s,st,s2: string[150];
    R : TRect;
    L : Boolean;
    i : Word;
    SArt:ArtikulStr;
    V :MAska2;

Begin

WordToBit2(VidProsmotra,V);
Convert2(V);
ControlFull^.NewList(Nil);
ControlFull^.NewList(New(PTextCollection, Init(0,1)));
ReturnCount:=0;
If (NoScreenList1^.List^.Count-1)>=0 Then
For i:=0 To NoScreenList1^.List^.Count-1 Do
 Begin
  st:=NoScreenList1^.GetText(i,NoScreenList1^.List^.Count);
  SArt:=Copy(st,1,CArtikul);
  ControlFull^.List^.Insert(NewStr(St));
  ControlFull^.SetRange(ControlFull^.List^.Count);
 End;
ControlFull^.FocusItem(0);
End;


procedure TFullScreenMrk.CalcItogo;
Var st,s2: string[150];
    R : TRect;
    L : Boolean;
    i : Word;
    SArt:ArtikulStr;
    V :MAska2;
    SKol : ArtikulStr;
    SZena,Skidka: TDateString;
SoSklada,SoSkidka,Amount,Oplata: AllStr;

Begin

SoSklada:='0.00';
Skidka:='0.00';
SoSkidka:='0.00';
Oplata:='0.00';
Amount:='0';


If (ControlFull^.List^.Count-1)>=0 Then
For i:=0 To ControlFull^.List^.Count-1 Do
 Begin
  st:=ControlFull^.GetText(i,ControlFull^.List^.Count);
  SKol:=Copy(st,1+CName+1+CArtikul+1+COne+1,CKol);
  SZena:=Copy(st,1+CName+1+CArtikul+1+COne+1+CKol+1,CZena);
  Skidka:=Copy(st,1+CName+1+CArtikul+1+COne+1+CKol+1+CZena+1+CZena+1,CZena);
  MyStr(StrToReal(SoSklada)+
  StrToInt(SKol)*StrToReal(SZena),CIZena,CMAntissa,SoSklada);

  MyStr(StrToReal(SoSkidka)+
  StrToInt(SKol)*StrToReal(Skidka),CIZena,CMAntissa,SoSkidka);
 End;



  MyStr(StrToReal(SoSklada)-
        StrToReal(SoSkidka),CIZena,CMAntissa,Oplata);

Str(ControlFull^.List^.Count:CMantissa,Amount);


Dispose(ControlCount,Done);
R.Assign(53, 0, 71, 1);
ControlCount := New(PColoredText, Init(R, 'Всего позиций:'+Amount, $4E));
MrkWin^.Insert(ControlCount);



DelSpace(Oplata);
DelSpace(SoSklada);
DelSpace(SoSkidka);

s2:=' К оплате:'+Oplata+' '+' Скидка '+VidSkidki+':'+SoSkidka+' '+
' Со склада: '+SoSklada;


Dispose(ControlInfo,Done);
R.Assign(1, 22, 2+Ord(s2[0]), 23);
ControlInfo := New(PColoredText, Init(R, #3+S2, $4E));
ControlInfo^.Options := ControlInfo^.Options or ofCenterX;
MrkWin^.Insert(ControlInfo);

CurrentLine[0]:=#0;

End;

Destructor TFullScreenMrk.Done;
Begin
TDialog.Done;
End;


Procedure CompressMarket(Auto:Boolean;StartDate,StopDate:TDateString);
Var i:LongInt;
    Cur,Start,Stop:LongInt;
    Nef,Ef,efb : MarketFileType;
    E : PSuperMarketType;
    s : DateString;
Begin
If Not(Auto) Then
 Begin
  If MessageBox(^M+#3'Функция требует монопольного использования базы данных!',Nil,mfWarning+mfOkCancel)<>cmOk Then
   Exit;
 End;
If Auto Then
  Begin
   StartDate:=FDate;
   StopDate:=FDate;
  End
 Else
  Begin
   StopDate:=FDate;
   DateToDateString(DateMask,DAteStringToDate(DateMask,StopDate)-30);
   If Not(DatePeriodDialog(StartDate,StopDate,False)) Then Exit;
  End;

New(E,Init);
Start:=DateStringToDate(DateMask,StartDate);
Stop :=DateStringToDate(DateMask,StopDate);
For Cur:=Start To Stop Do
 Begin
  S:=DateToDateString(DateMask,Cur);
  DInfoMsg('Компрессия продаж за '+S+'...');
  Assign(Ef,Path.ToMArket+S+'.mrk');
  i:=IOResult;
  Reset(Ef);
  i:=IOResult;
  If I=0 Then
   Begin
    Assign(NEf,Path.ToMarket+S+'.new');
    i:=IOResult;
    Rewrite(NEf);
    i:=IOResult;
    If IOResult=0 Then
     Begin
      While Not(eof(Ef)) Do
       Begin
        Read(Ef,E^.DAt);
        If E^.Dat.Active Then
         Begin
          Seek(NEf,FileSize(Nef));
          Write(NEf,E^.Dat);
         End;{Active}
       End;{While}
      Close(Nef);
      i:=IOResult;
      Close(Ef);
      i:=IOResult;
      Assign(efb,Path.ToMArket+s+'.bak');
      If FExists(Path.ToMArket+s+'.bak') Then  Erase(efb);
      i:=IOResult;
      Rename(ef,PAth.ToMArket+s+'.bak');
      i:=IOResult;
      If IOResult=0 Then
        Begin
         Rename(Nef,PAth.ToMArket+s+'.mrk');
         i:=IOResult;
         If IOResult<>0 Then
           MessageBox(^M+#3+'Не могу сохранить файл '+PAth.ToMArket+s+'.mrk',
                      Nil,mfError+mfCancelButton);
        End
      Else MessageBox(^M+#3+'Не могу сохранить файл '+PAth.ToMArket+s+'.bak',
                      Nil,mfError+mfCancelButton);
     End{создание файла}
     Else
         Begin
          Close(Ef);
          MessageBox(^M+#3'Ошибка создания файла '+Path.ToMarket+S+'.new (Код:'+
          IntToSTr(i,CMantissa)+'!',Nil,mfError+mfCancelButton);
         End;
   End;{Открытие файла продаж}
  NoInfoMsg;
 End;{For}
Dispose(E,Done);
AddProtocol('Компрессия продаж за период с '+StartDAte+' по '+StopDAte,'','');
End;

Function CompressDolg(Auto:Boolean):Boolean;
Var i:LongInt;
    Ef,Efb,Nef : File Of RealizasiaType;
    E : PRealizasiaType;
    Cl : ClientType;
    Clf : ClientFileType;
Begin
If Not(Auto) Then
 Begin
  If MessageBox(^M+#3'Функция требует монопольного использования базы данных!',Nil,mfWarning+mfOkCancel)<>cmOk Then
   Exit;
 End;
DInfoMsg('Компрессия долгов консигнации...');

Assign(Clf,PAth.ToClient+'Client.db');
i:=IOResult;
Reset(clf);
i:=IOResult;
If i<>0 Then
 Begin
  NoInfoMsg;
  MessageBox(^M+#3'Ошибка открытия '+PAth.ToClient+'Client.db'^M+
             #3+ClicProgrammer,Nil,mfError+mfCancelButton);
  Exit;
 End;

New(E,Init);
While Not(Eof(Clf)) Do
Begin
 ReadClient(Clf,Cl);
 If (Cl.Employ) And (Cl.Debit=1) Then
  Begin
   Assign(Ef,PAth.ToDolg+Cl.Kod+'.dlg');
   I:=IOResult;
   Reset(ef);
   I:=IOResult;
   If i=0 Then
    Begin
     Assign(NEf,Path.ToDolg+Cl.Kod+'.new');
     i:=IOResult;
     Rewrite(NEf);
     i:=IOResult;
     If IOResult=0 Then
      Begin
       While Not(eof(Ef)) Do
        Begin
         Read(Ef,E^.DAt);
         If E^.Dat.Market.Active Then
          Begin
           Seek(NEf,FileSize(Nef));
           Write(NEf,E^.Dat);
          End;{Active}
        End;{While}
        i:=IOResult;
        Close(ef);
        i:=IOResult;
        Close(Nef);
        i:=IOResult;
        Assign(efb,Path.ToDolg+Cl.Kod+'.bak');
        If FExists(Path.ToDolg+Cl.Kod+'.bak') Then  Erase(efb);
        i:=IOResult;
        Rename(ef,PAth.ToDolg+Cl.Kod+'.bak');
        i:=IOResult;
        If IOResult=0 Then
         Begin
          Rename(Nef,PAth.ToDolg+Cl.Kod+'.dlg');
          i:=IOResult;
          If IOResult<>0 Then
            MessageBox(^M+#3+'Не могу сохранить файл '+PAth.ToDolg+Cl.Kod+'.dlg',
                      Nil,mfError+mfCancelButton);
         End
         Else MessageBox(^M+#3+'Не могу сохранить файл '+PAth.ToDolg+Cl.Kod+'.bak',
                      Nil,mfError+mfCancelButton);

      End{если создан фантом}
     Else
      Begin
       Close(Ef);
       MessageBox(^M+#3'Ошибка создания файла '+Path.ToDolg+Cl.Kod+'.new (Код:'+
       IntToSTr(i,CMantissa)+'!',Nil,mfError+mfCancelButton);
      End;
    End;{i=0}
  End;{Employ and Debit=1}
End;{While}

Dispose(E,Done);
i:=IoResult;
Close(Clf);
i:=IoResult;
NoInfoMsg;
AddProtocol('Компрессия долгов консигнации','','');
End;


Function ObrezanieDolg:Boolean;
Begin
 If MessageBox(^M+#3'Функция требует монопольного использования базы данных!',Nil,mfWarning+mfOkCancel)<>cmOk Then
 Exit;
End;


Procedure MarketToDolg(E:PSuperMarketType;Var D:PRealizasiaType);
Begin
 If E^.Dat.DocSelector in [3,4,6,8] Then D^.Dat.Sf:=True
 Else D^.Dat.Sf:=False;
 D^.Dat.PayMent:=False;
 D^.DAt.Full:=False;
 D^.Dat.Dolg:=StrToReal(E^.Dat.SummaZ);
 With D^.DAt.MArket Do
 Begin
     OperatorSelector:=E^.DAt.OperatorSelector;
     DocSelector :=E^.DAt.DocSelector;
     SkidkaSelector :=E^.DAt.SkidkaSelector;
     ClientKod :=E^.DAt.ClientKod;
     AgentKod :=E^.DAt.AgentKod;
     Document :=E^.DAt.Document;
     DateC   :=E^.DAt.DateC;
     {TimeC   :=E^.DAt.TimeC;}
     Region  :=E^.Dat.Region;
     SummaZ  :=E^.DAt.SummaZ;
     Skidka  :=E^.DAt.Skidka;
  SkladKod   :=E^.DAt.SkladKod;
     Caption :=E^.DAt.Caption;
     Active  :=E^.DAt.Active;
     Srok    :=E^.DAt.Srok;
 End;
End;

{
procedure TGlobalLock.OpenAdministratorWindow;
Var l : Boolean;
begin
  ClearFind;
  if Message(Desktop, evBroadcast,cmGlobalAdmin, nil) = nil then
  begin
    L:=True;
    GlobalMsg := New(PGlobalLock, Init(L));
    If L Then
    Begin
    Application^.Insert(GlobalMsg);
    End
    Else
     Begin
      Status:=DocNormal;
      Dispose(GlobalMsg,Done);
     End;
  end
  else
    if PView(GlobalMsg) <> Application^.TopView then GlobalMsg^.Select;
end;
}



Function SortSkidka(inp:PSkidkaType): Boolean;
Label Stop;
Var bp,cp,tp : PSHkala;
    p : Shkala;
    i : Byte;
    l : Boolean;
Begin
 SortSkidka:=False;
 P.Up[0]:=#0;
 P.Proz[0]:=#0;
 New(Bp,Init(P));
 For i :=1 To 6 Do
  Begin
   If Not LowMemory Then new(Cp,Init(inp^.Dat.Skidka[i]))
   Else
         Begin
          GoTo Stop;
         End;
   Tp:=Bp;
   L := False;
   While  (Not (L)) And (Tp^.Next <> Nil) Do
   Begin
   If (StrToReal(Tp^.Next^.Dat.Up) > StrToReal(Cp^.Dat.Up))
   Or((StrToReal(Tp^.Next^.Dat.Up)=StrToReal(Cp^.Dat.Up))And
   (StrToReal(Tp^.Next^.Dat.Proz)>StrToReal(Cp^.Dat.Proz))) Then L := True
   Else Tp:=Tp^.Next;
   End;
   If Not(L) And (Tp^.Next<> Nil) Then Tp^.Next:=Cp
   Else
       Begin
        Cp^.Next:=Tp^.Next;
        Tp^.Next:=Cp;
       End;
  End; {For}
  Cp := Bp^.Next;
  For i:=1 To 6 Do
  Begin
   Inp^.Dat.Skidka[i]:=Cp^.Dat;
   Cp:=Cp^.Next;
  End;
  SortSkidka:=True;
Stop:   Dispose(Bp,Done);
End;



{
VAr s : string[150];
Begin

s:='Привет';
s:=Encrypt(s);
Writeln(s);
s:=crypt(s);
Writeln(s);
s:=crypt(s);
Writeln(Decrypt(s));
Readln;
}



Function MaskaSelect (Var s: AllStr;Var Res:Word):Boolean;
var
  Dlg : PDialog;
  R : TRect;
  ControlO,ControlS : PView;
  c : Word;
begin
MaskaSelect:=False;

R.Assign(23, 8, 56, 14);
New(Dlg, Init(R, 'Маска выбора элементов'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.Palette := dpCyanDialog;
Dlg^.HelpCtx := $E002;

R.Assign(1, 2, 29, 3);
ControlS := New(PInputLine, Init(R, CAll));
Dlg^.Insert(ControlS);
ControlS^.SetData(S);

  R.Assign(29, 2, 32, 3);
  Dlg^.Insert(New(PHistory, Init(R, PInputline(ControlS), 55)));


R.Assign(3, 4, 26, 5);
ControlO := New(PCheckboxes, Init(R,
  NewSItem('Точное совпадение', Nil)));
Dlg^.Insert(ControlO);
ControlO^.SetData(Res);

Dlg^.SelectNext(False);

c:=Desktop^.ExecView(Dlg);

If c<>cmCancel Then
 Begin
  ControlO^.GetData(Res);
  ControlS^.GetData(s);
  DelSpaceRight(s);
  If s[0]<>#0 Then MaskaSelect:=True;
 End;
Dispose(ControlS,Done);
Dispose(ControlO,Done);
Dispose(Dlg,Done);

End;



Function FindParam(s:String):Boolean;
Var i : Word;
Begin
 FindParam:=False;
 For i:=1 To ParamCount+1 Do
  Begin
   If (Pos(s,UpCAses(ParamStr(i)))>0) Then
         Begin
          FindParam:=True;
          Break;
         End;
  End;
End;

Function ListFind(Var s:AllStr):Boolean;
var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  c : Word;
begin
ListFind:=FAlse;
R.Assign(0, 19, 49, 22);
New(Dlg, Init(R, 'Искать вхождение'));
Dlg^.Palette := dpCyanDialog;

R.Assign(1, 1, 48, 2);
Control := New(PInputLine, Init(R, 45));
Dlg^.Insert(Control);

Dlg^.SelectNext(False);
Dlg^.SetData(s);
c:=Desktop^.ExecView(Dlg);
if c<>cmCancel Then
Begin
 Dlg^.GetData(s);
 ListFind:=True;
End;
Dispose(Control,Done);
Dispose(Dlg,Done);

end;



Procedure ChekAddStr(st:AllStr; Res:Word);
VAr f : Text;
         s : TMyString;
         Test : Boolean;
         Wspom : PBox;
         R:TRect;
         i : Word;
         Temp:PBox;
Begin
DelSpaceRight(St);
If st[0]<>#0 Then
Begin
i:=IOResult;
CAse Res of
0:Assign(f,Path.ToSklad+'ksertif.db');
1:Assign(f,Path.ToSklad+'akzis.db');
2:Assign(f,Path.ToSklad+'gtd.db');
Else;
End;

Begin
Reset(f);
i:=IOResult;
If i<>0 Then
 Begin
  Exit;
 End;
Test:=False;
While Not(Eof(f)) Do
 Begin
  Readln(f,s);
  If Pos(st,s)=1 Then
        Begin
         Test:=True;
         Break;
        End;
 End;
Close(f);
If Not(Test) Then
 Begin
 Reset(f);
 R.Assign(0, 0, 0, 0);
 Temp := New(PBox, Init(R, 1, Nil));
 Temp^.NewList(New(PTextCollection, Init(1,1)));
 While Not(Eof(F)) Do
  Begin
        Readln(f,s);
        Temp^.List^.Insert(NewStr(s));
        Temp^.SetRange(Temp^.List^.Count);
  End;
        Temp^.List^.Insert(NewStr(st));
        Temp^.SetRange(Temp^.List^.Count);
 Close(f);
 Rewrite(f);
 i:=IOResult;
 If i=0 Then
 Begin
 For i:=Temp^.List^.Count-1 DownTo 0 Do
  Begin
        s:=Temp^.GetText(i,Temp^.List^.Count);
        Writeln(f,s);
  End;
 Close(f);
 End;
 i:=IOResult;
 Dispose(Temp,Done);
 End;
End;
End;
End;


Function SelSkidka:Word;
var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  c : Word;
begin
SelSkidka:=2;
R.Assign(30, 9, 49, 13);
New(Dlg, Init(R, ''));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx:=$E241;

R.Assign(1, 1, 18, 3);
Control := New(PRadioButtons, Init(R,
  NewSItem('~Т~овар',
  NewSItem('~С~ертификаты', Nil))));
Dlg^.Insert(Control);

C:=0;

Dlg^.SetData(c);

Dlg^.SelectNext(False);
c:=DeskTop^.ExecView(Dlg);
If c<>cmCancel Then
 Begin
  Dlg^.GetData(c);
  SelSkidka:=c;
  Dispose(Control,Done);
  Dispose(Dlg,Done);
 End
Else
 Begin
  Dispose(Control,Done);
  Dispose(Dlg,Done);
 End;

end;



Function TestAgent(Cod:ArtikulStr):Boolean;
Var L : Boolean;
    i : word;
    st : string[150];
Begin
TestAgent:=False;
If (Agent^.List^.Count-1)>=0 Then
Begin
For i:=0 To Agent^.List^.Count-1 Do
 Begin
  st:=Agent^.GetText(i,Agent^.List^.Count);
  st:=Copy(st,1+1,CClientKod);
  If (St=Cod) Then
   Begin
    TestAgent:=True;
    Break;
   End;{St=Cod}
 End;
End;
End;



Procedure InputKredit;
LAbel 1;
VAr c,j : Word;
    E : PKreditType;
    f : File Of KreditType;
    Dlg : PDialog;
    Control :PView;
    R : TRect;
    SRegion : AllStr;
    Res : Word;
Begin

Res:=SelectRegion(False);

If Res=5 Then Exit;

Case Res Of
0:SRegion:='office';
1:SRegion:='gorod';
2:SRegion:='region';
3:SRegion:='rezerv';
Else ;
End;

Assign(f,Path.ToDolg+SRegion+'.dlg');
c:=IOResult;
Reset(f);
If IOResult<>0 Then
 Begin
  MessageBox(#3'Ошибка открытия файла '+Path.ToDolg+SRegion+'.dlg'+' настройки кредита!'+
  ClicProgrammer,Nil,mfError+mfCancelButton);
  Exit;
 End;


New(E,Init);
Read(f,E^.DAt);
Close(f);
c:=IOResult;

1:


Case Res Of
0:SRegion:='Офис';
1:SRegion:='Город';
2:SRegion:='Область';
3:SRegion:='Резерв';
Else ;
End;

R.Assign(0, 6, 80, 16);
New(Dlg, Init(R, 'Настройка платного кредита - '+SRegion));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx := $E002;


R.Assign(1, 2, 6, 9);
Control := New(PColoredText, Init(R, 'РЦ'^M+
     'Ш 1'^M+
     'Ш 2'^M+
     'Ш 3'^M+
     'Ш 4'^M+
     'Ш 5'^M+
     'Ш 6', $74));
Dlg^.Insert(Control);

R.Assign(8, 1, 79, 2);
Control := New(PColoredText, Init(R, '1дн.  2дн.  3дн.  4дн.  5дн.  6дн.  7дн.  8дн.  9дн. 10дн. 11дн. 12дн.', $74));
Dlg^.Insert(Control);


  For c:=1 To 7 Do
   For j:=1 To 12 Do
    Begin
     MyStr(StrToREal(E^.Dat.Kredit[c].Proz[j]),CLitr+1,CLitrMantissa+1,E^.Dat.Kredit[c].Proz[j]);
     DelSpace(E^.Dat.Kredit[c].Proz[j]);
    End;


For c:=0 To 6 Do
 For j:=1 To 12 Do
Begin
R.Assign(6*j, 2+c, 6*j+7, 3+c);
Control := New(PInputLine, Init(R, CLitr+1));
Dlg^.Insert(Control);
PInputLine(Control)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));
End;

Dlg^.SetDAta(E^.DAt);
Dlg^.SelectNext(False);

c:=Desktop^.ExecView(Dlg);

If c<>CmCAncel Then
 Begin
  Dlg^.GEtDAta(E^.DAt);
  For c:=1 To 7 Do
   For j:=1 To 12 Do
    Begin
     MyStr(StrToREal(E^.Dat.Kredit[c].Proz[j]),CLitr+1,CLitrMantissa+1,E^.Dat.Kredit[c].Proz[j]);
     DelSpace(E^.Dat.Kredit[c].Proz[j]);
     If Abs(StrToREal(E^.Dat.Kredit[c].Proz[j]))<0.8 Then
      BEgin
       MessageBox(#3'Недопустимое значение ставки кредита в позиции '+
          IntToStr(c,COne)+','+IntToStr(j,COne),Nil,mfError+mfCancelButton);
       Dispose(Control,Done);
       Dispose(Dlg,Done);
       Goto 1;
      End;
    End;
  Reset(F);
  c:=IOResult;
  Write(F,E^.DAt);
  c:=IOResult;
  Close(f);
  c:=IOResult;
  Dispose(Control,Done);
  Dispose(Dlg,Done);
  Dispose(E,Done);
 End
Else
 BEgin
  Dispose(Control,Done);
  Dispose(Dlg,Done);
  Dispose(E,Done);
 End;
End;




Procedure CalcSpecialKassa( Var
    AllZakupka,
    AllPrihod,
    AllRewisia,
    AllReturn,
    MinusDohod,
    AllDohod,
    AllDohodA,
    AllDolg,
    AllDolgA,
    DolgiIstekshie,
    DolgiVse,
    PlategiIstekshie,
    PlategiVse: AllStr);

VAr sklFile : SkladFileType;
    PF : PrihodFileType;
    E : PPrihodType;
    RF : RewisiaFileType;
    RE : PRewisiaType;
    vF : NewVozwratFileType;
    vE : PNewVozwratType;
    mF : MarketFileType;
    me : PSuperMarketType;
    skl : pSkladType;
    RazdelFile : File Of RazdelType;
    RazdelElement : RazdelType;
    F : Boolean;
    c : Word;
    ch : LongInt;
    ws : string[150];
    k,All : LongInt;
    St,w: AllStr;
    R : TRect;
    ClientList : PBox;
    ClientFile : ClientFileType;
    ClientElement : ClientType;
    RealFile : File Of RealizasiaType;
    DE : PRealizasiaType;
    ii : LongInt;
    t2,t1 : LongInt;
    RealFile1 : BarterClientFileType;
    E1  : PBArterClientType;

Begin
AllZakupka[0]:=#0;
AllPrihod[0]:=#0;
AllRewisia[0]:=#0;
AllReturn[0]:=#0;
MinusDohod[0]:=#0;
AllDohod[0]:=#0;
AllDohodA[0]:=#0;
AllDolg[0]:=#0;
AllDolgA[0]:=#0;
DolgiIstekshie[0]:=#0;
DolgiVse[0]:=#0;
PlategiIstekshie[0]:=#0;
PlategiVse[0]:=#0;

{расчитываем остаток по закупочным ценам}
c:=IOResult;
Assign(RazdelFile,Path.ToRazdel+'Razdel.db');
Reset(RazdelFile);
c:=IOResult;
If c<>0 Then
 Begin
  MessageBox(^M+#3'Ошибка доступа к файлу разделов!',Nil,mfError+mfCancelButton);
  Exit;
 End;

While Not(Eof(RazdelFile)) Do
 Begin
  Read(RazdelFile,RazdelElement);
  If RazdelElement.Employ Then
  Begin
   Assign(SklFile,Path.ToSklad+RazdelElement.Kod+'.db');
   c:=IOResult;
   Reset(SklFile);
   c:=IOResult;

If c<>0 Then
 Begin
  Close(RazdelFile);
  NoInfo;
  MessageBox(^M+#3'Ошибка доступа к файлу '+Path.ToSklad+RazdelElement.Kod+'.db',Nil,mfError+mfCancelButton);
  Exit;
 End;

   New(Skl,Init);
   ch:=0;
   While Not(Eof(sklFile)) Do
    Begin

     ReadSklad(SklFile,Skl^.Dat);

     With Skl^.Dat.Input Do
     Begin
      All:=0;
      For k:=1 To CDivision Do
        Begin
           Str(StrToInt(DivisionS[k]):CKol,DivisionS[k]);
           DelSpace(DivisionS[k]);
           All:=All+StrToInt(DivisionS[k]);
        End;

     Str(All:CKol,Skl^.Dat.Input.Kol);
     DelSpace(Skl^.Dat.Input.Kol);

     Str(StrToReal(Skl^.Dat.Input.Zakupka)*
             StrToInt(Skl^.Dat.Input.Kol)+StrToReal(AllZakupka):CIZena:CMantissa,AllZakupka);
     End;{With}


   End;{While}

   Dispose(Skl,Done);
   c:=IOResult;
   Close(SklFile);
   c:=IOResult;
   End;
 End;
   c:=IOResult;
Close(RazdelFile);
   c:=IOResult;

{приход на склад по закупке}
Assign(Pf,Path.ToPrihod+FDate+'.prh');
   c:=IOResult;
Reset(Pf);
   c:=IOResult;
If c=0 Then
 Begin
  New(E,Init);
  While Not(Eof(PF)) Do
   Begin
    ReadPrihod(Pf,E);
    If E^.Dat.OperatorSelector = 0 Then
    MyStr(StrToReal(E^.Dat.SummaZakupka)+
           StrToREal(AllPrihod),CIZena,CMantissa,AllPrihod);
   End;
  Dispose(E,Done);
   c:=IOResult;
   Close(PF);
   c:=IOResult;
 End;

{ревизия на складе по закупке}
Assign(Rf,Path.ToRewisia+FDate+'.rwz');
   c:=IOResult;
Reset(Rf);
   c:=IOResult;
If c=0 Then
 Begin
  New(RE,Init);
  While Not(Eof(RF)) Do
   Begin
    ReadRewisia(Rf,RE);
    MyStr(StrToReal(RE^.Dat.ItogoZ)+
           StrToREal(AllRewisia),CIZena,CMantissa,AllRewisia);
   End;
  Dispose(RE,Done);
   c:=IOResult;
   Close(RF);
   c:=IOResult;
 End;


{возврат на складе по закупке}
{упущенный доход}
Assign(vf,Path.ToReturn+FDate+'.vzw');
   c:=IOResult;
Reset(vf);
   c:=IOResult;

If c=0 Then
 Begin
  New(vE,Init);
  While Not(Eof(vF)) Do
   Begin
    ReadNewVozwrat(vf,vE);
    MyStr(StrToReal(vE^.Dat.SummaZakupka)+
           StrToREal(AllReturn),CIZena,CMantissa,AllReturn);

    MyStr(StrToReal(vE^.Dat.Delta)+
           StrToREal(MinusDohod),CIZena,CMantissa,MinusDohod);

   End;
  Dispose(vE,Done);
   c:=IOResult;
   Close(vF);
   c:=IOResult;
 End;


{доходность по отгрузке}
Assign(mf,Path.ToMarket+FDate+'.mrk');
   c:=IOResult;
Reset(mf);
   c:=IOResult;

If c=0 Then
 Begin
  New(mE,Init);
  While Not(Eof(mF)) Do
   Begin
    ReadMarket(mf,mE);
   If (ME^.Dat.OperatorSelector=0) Then
   Begin
    If (me^.Dat.Active) Then
    Begin
     If ((ME^.Dat.DocSelector in [0,1,2,3,4]) And Not(ME^.Dat.Realiz)) Or
        (ME^.Dat.DocSelector in [5,6,7,8]) Then
     Begin

      If StrToInt(me^.DAt.AgentKod)=0 Then
        MyStr(StrToReal(mE^.Dat.SummaZ)-StrToReal(mE^.Dat.SummaZakupka)+
             StrToREal(AllDohod),CIZena,CMantissa,AllDohod)
      Else
       Begin
(*
          If StrToInt(mE^.DAt.AgentKod)=17 Then
           Begin
     {13}   Str(StrToReal(mE^.Dat.SummaZ)*0.98:CIZena:CMantissa,mE^.Dat.SummaZ);
           End;
*)
         MyStr(StrToReal(mE^.Dat.SummaZ)-StrToReal(mE^.Dat.SummaZakupka)+
            StrToREal(AllDohodA),CIZena,CMantissa,AllDohodA)
       End;

     End;{DocSelector}
    End;{Active}
   End;{OperatorSelector}
   End;{While}
  Dispose(mE,Done);
   c:=IOResult;
   Close(mF);
   c:=IOResult;
 End;{c=0}


R.Assign(0, 0, 0, 0);
ClientList := New(PBox, Init(R, 1, Nil));
ClientList^.NewList(New(PTextCollection, Init(0,1)));

Assign (ClientFile,Path.ToClient+'Client.db');
c:=IOResult;
Reset (ClientFile);
c:=IOResult;
If c=0 Then
Begin

While Not(Eof(ClientFile)) Do
 Begin
     ReadClient(ClientFile,ClientElement);
     If Not(FExists(Path.ToDolg+ClientElement.Kod+'.dlg')) Then ClientElement.Employ:=False;

  If ClientElement.Employ Then
   Begin
    Format (ClientElement.Name,CClient);
    ClientList^.List^.Insert(NewStr(ClientElement.Name+'│'+ClientElement.Kod));
    ClientList^.SetRange(ClientList^.List^.Count);
   End;
 End;
System.Close(ClientFile);
End
Else
 Begin
  Dispose(ClientList,Done);
  Exit;
 End;

If (ClientList^.List^.Count-1)>=0 Then
 Begin
  For c:=0 To ClientList^.List^.Count-1 Do
   Begin
    st := ClientList^.GetText(c,ClientList^.List^.Count);
    St := Copy(st,1+CClient+1,CClientKod);
    Assign(RealFile,Path.ToDolg+st+'.dlg');
    ii:=IOResult;
    Reset(RealFile);
    ii:=IOResult;
    If ii=0 Then
     Begin
      New(DE,Init);
      While Not(Eof(RealFile)) Do
       Begin
        Read(RealFile,DE^.Dat);
        If (DE^.Dat.Market.Active) Then
Begin
        If (DE^.Dat.Dolg>0.009) And Not(DE^.Dat.Full) Then
         Begin
          MyStr((DE^.Dat.Dolg),CIZena,CMantissa,w);

      If StrToInt(De^.DAt.Market.AgentKod)=0 Then
        MyStr(StrToReal(w)+StrToREal(AllDolg),CIZena,CMantissa,AllDolg)
      Else
        MyStr(StrToReal(w)+StrToReal(AllDolgA),CIZena,CMantissa,AllDolgA);


        t2:=DateStringToDate(DAteMask,FDate);
        t1:=DE^.Dat.MArket.Srok;
        If (t2-t1)>=0 Then
         Begin
          MyStr(StrToreal(DolgiIstekshie)+StrToReal(w),CIZena,CMantissa,DolgiIstekshie);
         End;




         End;
End;{active}
       End;{While}
      Dispose(DE,Done);
   ii:=IOResult;
      Close(RealFile);
   ii:=IOResult;
     End;{II=0}

   End;
 End;
Dispose(ClientList,Done);

R.Assign(0, 0, 0, 0);
ClientList := New(PBox, Init(R, 1, Nil));
ClientList^.NewList(New(PTextCollection, Init(0,1)));
Assign (ClientFile,Path.ToClient+'Barter.db');
c:=IOResult;
Reset (ClientFile);
c:=IOResult;

If c=0 Then
Begin
While Not(Eof(ClientFile)) Do
 Begin
     ReadClient(ClientFile,ClientElement);
  If ClientElement.Employ Then
   Begin
    Format (ClientElement.Name,CClient);
    ClientList^.List^.Insert(NewStr(ClientElement.Name+'│'+ClientElement.Kod));
    ClientList^.SetRange(ClientList^.List^.Count);
   End;
 End;
System.Close(ClientFile);
End
Else
 Begin
  Dispose(ClientList,Done);
  Exit;
 End;

If (ClientList^.List^.Count-1)>=0 Then
 Begin
  For c:=0 To ClientList^.List^.Count-1 Do
   Begin
    st := ClientList^.GetText(c,ClientList^.List^.Count);
    St := Copy(st,1+CClient+1,CClientKod);
    Assign(RealFile1,Path.ToBarter+st+'.brt');
    ii:=IOResult;
    Reset(RealFile1);
    ii:=IOResult;
    If ii=0 Then
     Begin
      New(E1,Init);
      While Not(Eof(RealFile1)) Do
       Begin
        Read(RealFile1,E1^.Dat);
        With E1^.Dat Do
        Begin
        If (E1^.Dat.Active) And (E1^.Dat.OperatorSelector=0){приходы}
            And (E1^.Dat.VidPrihoda=1) Then
          Begin

        {вычленяем просроченные}
        t2:=DateStringToDate(DAteMask,FDate);
        t1:=DateStringToDate(DAteMask,E1^.Dat.SrokPlatega);
        If (t2-t1)>=0 Then
         Begin
MyStr(StrToReal(PlategiIstekshie)+STrToReal(OstatokDolga),CIZena,CMAntissa,PlategiIstekshie);
         End;
MyStr(StrToReal(PlategiVse)+STrToReal(OstatokDolga),CIZena,CMAntissa,PlategiVse);

          End;{active}
        End;{With}
       End;{While}
      Dispose(E1,Done);
      Close(RealFile1);
      ii:=IOResult;
     End;{ii=0}
   End;{For}
 End;
Dispose(ClientList,Done);






End;


Function TestSrokLock(Kod:ArtikulStr;Srok:ArtikulStr):Boolean;
Var f : File Of StatClientType;
    Cl : PStatClientType;
    Find : Boolean;
    c : Word;
Begin
TestSrokLock:=False;
Assign(f,Path.ToClient+Kod+'.his');
c:=IOResult;
Reset (f);
c:=IOResult;
If c<>0 Then Exit;
Find := False;
New(Cl,Init);
While Not(Eof(f)) And Not(Find) Do
 Begin
  Read(F,Cl^.Dat);
  If Cl^.Dat.Active Then
   Begin
    If Not
       (
       (DateStringToDate(DAteMask,Cl^.Dat.DateC)+StrToInt(Srok))<=
       (DateStringToDate(DAteMask,FDate))
          ) Then Find:=True


   End;
   if Cl^.Dat.TrueRealiz then Find:=True;
 End;

c:=IOResult;
Close(F);
c:=IOResult;
Dispose(Cl,Done);

If Find Then TestSrokLock:=True;
End;


Function TestSrokLockDetal(Kod,Srok:ArtikulStr;
                           Var LastDoc:ArtikulStr;
                                          Var LastDate:TDateString;
                                          Var LastSummaZ:AllStr):Boolean;

Var f : File Of StatClientType;
    Cl : PStatClientType;
    Find : Boolean;
    c : Word;
Begin
LastDoc[0]:=#0;
LastDate[0]:=#0;
LastSummaZ[0]:=#0;

TestSrokLockDetal:=False;
Assign(f,Path.ToClient+Kod+'.his');
c:=IOResult;
Reset (f);
c:=IOResult;
If c<>0 Then Exit;
Find := False;
New(Cl,Init);
While Not(Eof(f)) And Not(Find) Do
 Begin
  Read(F,Cl^.Dat);
  If Cl^.Dat.Active Then
   Begin

         LastDate:=Cl^.DAt.DAteC;
         LastDoc :=Cl^.DAt.Document;
         LastSummaZ:=Cl^.DAt.SummaZ;
         {
         If Kod='0540' Then
          Begin
           MessageBox(LastDate+' '+LastDoc+' '+LastSummaZ,
                 Nil,mfError+mfCancelButton);
          End;
         }
    If Not
       (
       (DateStringToDate(DAteMask,Cl^.Dat.DateC)+StrToInt(Srok))<=
       (DateStringToDate(DAteMask,FDate))
          ) Then
           Begin
            Find:=True;
        End;

     if Cl^.Dat.TrueRealiz then Find:=True;

   End;
 End;
c:=IOResult;
Close(F);
c:=IOResult;
Dispose(Cl,Done);

If Find Then TestSrokLockDetal:=True;
End;


Procedure TestClientBaza;
Var ClientFile : ClientFileType;
    ClientElement : ClientType;
    c : Word;
Begin
DInfoMsg('Проверяю базу клиентов...');
Assign (ClientFile,Path.ToClient+'Client.db');
c:=IOResult;
Reset (ClientFile);
c:=IOResult;
If c<>0 Then
Begin
NoInfoMsg;
MessageBox(^M+'Не могу произвести тестирование базы клиентов!',Nil,
mfError+mfCancelButton);
Exit;
End;
While Not(Eof(ClientFile)) Do
 Begin
  ReadClient(ClientFile,ClientElement);


  If ClientElement.Employ Then

  If Not(ClientElement.LockTime) Then
  If Not (TestSrokLock(ClientElement.Kod,ClientElement.Test_Srok)) Then
   Begin
   ClientElement.LockTime:=True;
   Seek(ClientFile,Filepos(ClientFile)-1);
   c:=IoResult;

   Repeat
   Pause(1);
   Until (Lock(ClientFile,FilePos(ClientFile)*SizeOf(ClientType),SizeOf(ClientType)));

   ClientElement.LockTime:=True;
   c:=IoResult;

   Write(ClientFile,ClientElement);
   c:=IoResult;

   Repeat
   Unlock(ClientFile,(FilePos(ClientFile)-1)*SizeOf(ClientType),SizeOf(ClientType));
   Until DosError=0;


   SaveTempLock(ClientElement.Kod,1,'99');


    {установка временной блокировки}
   End;
 End;
c:=IOResult;
Close(ClientFile);
c:=IOResult;
NoInfoMsg;
End;

Procedure ViewClientBaza;
Const Space='    ';
Var ClientFile : ClientFileType;
    ClientElement : ClientType;
    c : Word;
    txt : Text;
    S : string[150];
    Count : Word;
    Numer,Delta,LastDoc,LastDate,LastSummaZ : AllStr;
    R : TRect;
    ClientList:PBox;
Begin
DInfo('Проверяю базу клиентов...');
Assign (ClientFile,Path.ToClient+'Client.db');
c:=IOResult;
Reset (ClientFile);
c:=IOResult;
If c<>0 Then
Begin
NoInfo;
MessageBox(^M+'Не могу произвести тестирование базы клиентов!',Nil,
mfError+mfCancelButton);
Exit;
End;

Assign(txt,Path.ToTemp+'testbaza.txt');
c:=IOResult;
Rewrite(txt);
c:=IOResult;
If c<>0 Then
Begin
NoInfo;
Close(ClientFile);
MessageBox(^M+'Не могу создать '+Path.ToTemp+'testbaza.txt',Nil,
mfError+mfCancelButton);
Exit;
End;

Writeln(Txt,Space+'Склад: '+Rek.Name+' Оператор: '+CurrentPassword+' EYE & 2000');
Writeln(Txt,Space+'                   СПИСОК ВРЕМЕННО ЗАБЛОКИРОВАННЫХ КЛИЕНТОВ ');
Writeln(Txt,Space+'----------------------------------------------------------------------------');
Writeln(Txt,Space+'  N  Клиент               Код Период   Delta  Докум.  Дата        Сумма ');
Writeln(Txt,Space+'----------------------------------------------------------------------------');
                  {1234│12345678901234567890│1234│12345│12345678│12345│12345678│123456789012345}

R.Assign(0, 0, 0, 0);
ClientList := New(PBox, Init(R, 1, Nil));
ClientList^.NewList(New(PTextCollection, Init(0,1)));




Count :=0;

While Not(Eof(ClientFile)) Do
 Begin
  ReadClient(ClientFile,ClientElement);
  If ClientElement.Employ Then
  If ClientElement.LockTime Then
  If Not (TestSrokLockDetal(ClientElement.Kod,ClientElement.Test_Srok,LastDoc,LastDate,LastSummaZ)) Then
   Begin
    Inc(Count);
    DelSpace(LastDoc);
    RFormat(LastDoc,5);
    DelSpace(LastSummaZ);
    MyStr(StrToReal(LastSummaZ),CIZena,CMantissa,LastSummaZ);
    Format(ClientElement.Name,CClient);
    Format(ClientElement.Kod,4);
    Format(ClientElement.Test_Srok,CArtikul);

    If LastDate[0]<>#0 Then
    Str(
       (DateStringToDate(DAteMask,LastDate)+StrToInt(ClientElement.Test_Srok))-
       (DateStringToDate(DAteMask,FDate)):8,Delta)
    Else Delta:='        ';

    DelSpace(LastDate);
    RFormat(LastDAte,CDAte);

    s:=ClientElement.Name+' '+ClientElement.Kod+' '+
    ClientElement.Test_Srok+' '+Delta+' '+
    LastDoc+' '+LastDate+' '+LastSummaZ;

    ClientList^.List^.Insert(NewStr(s));
    ClientList^.SetRange(ClientList^.List^.Count);

   End;
 End;
c:=IOResult;
Close(ClientFile);
c:=IOResult;


If (ClientList^.List^.Count-1)>=0 Then
 Begin
  For c:=0 To ClientList^.List^.Count-1 Do
   Begin
    Str(C+1:4,Numer);
    s := ClientList^.GetText(c,ClientList^.List^.Count);
    Writeln(txt,Space+Numer+' '+s);
   End;{For}
 End;{If ClientList}




Writeln(Txt);
Writeln(Txt,Space+'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
Writeln(Txt,Space+'============================================================================');

Dispose(ClientList,Done);


c:=IOResult;
Close(Txt);
c:=IOResult;

 NoInfo;

 ViewAsText(Path.ToTemp+'testbaza.txt',True);

 Report(Path.ToTemp+'testbaza.txt','',1,False,False,false);
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
0:Control := New(PStaticText, Init(R, 'Долг клиента превышает сумму допусти'+
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


Function InputBN(Var l,PrevMarket:PSuperMarketType;rashod: boolean):Boolean;
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
if not rashod then
New(Dlg, Init(R, 'Безналичный расчет'))
else
New(Dlg, Init(R, 'По Расходно-Кассов.Ордеру'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.Palette := dpCyanDialog;
Dlg^.HelpCtx := $E002;

R.Assign(3, 2, 13, 3);
Control := New(PInputLine, Init(R, 8));
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PPXPictureValidator, Init(DateFiltr, True));

if not rashod then
begin
  R.Assign(2, 1, 8, 2);
  Dlg^.Insert(New(PLabel, Init(R, '~Д~ата:', Control)));
end
else
begin
  R.Assign(2, 1, 12, 2);
  Dlg^.Insert(New(PLabel, Init(R, '~Д~ата РКО:', Control)));
end;

R.Assign(19, 2, 31, 3);
Control := New(PInputLine, Init(R, 10));
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0']));

  R.Assign(18, 1, 25, 2);
if not rashod then
  Dlg^.Insert(New(PLabel, Init(R, 'N ~п~/п:', Control)))
else Dlg^.Insert(New(PLabel, Init(R, 'N ~Р~КО:', Control)));

R.Assign(35, 2, 52, 3);
Control := New(PInputLine, Init(R, 15));
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));

  R.Assign(34, 1, 50, 2);
  Dlg^.Insert(New(PLabel, Init(R, '~С~умма платежа:', Control)));

R.Assign(7, 4, 54, 5);
Control := New(PInputLine, Init(R, 45));

if rashod then
Control^.Options := Control^.Options and not ofSelectable;
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
  MyStr(StrToReal(B.Summa),CIZena,CMAntissa,B.Summa);
  DelSpace(B.Summa);
  if rashod then B.Bank:='РКО';
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
    if not rashod then
    MessageBox(#3^M+#3'Не указана дата п/п !',Nil,mfError+mfCancelButton)
    else MessageBox(#3^M+#3'Не указана дата РКО !',Nil,mfError+mfCancelButton);
    Goto 1;
   End;
  If b.NPlat[0]=#0 Then
   Begin
    Dispose(Control,Done);
    Dispose(Dlg,Done);
    if not rashod then
    MessageBox(#3^M+#3'Не указан номер п/п !',Nil,mfError+mfCancelButton)
    else MessageBox(#3^M+#3'Не указан номер РКО !',Nil,mfError+mfCancelButton);
    Goto 1;
   End;
  If StrToReal(b.Summa)=0 Then
   Begin
    Dispose(Control,Done);
    Dispose(Dlg,Done);
    MessageBox(#3^M+#3'Нулевая сумма платежа !',Nil,mfError+mfCancelButton);
    Goto 1;
   End;
  InputBn:=True;
  L^.Dat.Bn:=B;
 End;
Dispose(Control,Done);
Dispose(Dlg,Done);
end;


Function SelectOperationAndDocument(Var mm3s:Maska3;Var mm9S:Maska9):Boolean;
Label 1;
var
  Dlg : PDialog;
  R : TRect;
  ControlOperation : PView;
  Control,ControlDoc : PView;
  Test,c,OperationFiltr,DocFiltr:Word;
  mm3:Maska3;
  mm9:Maska9;

begin
SelectOperationAndDocument:=False;
For c:=1 to 3 Do mm3s[c]:=1;
For c:=1 to 9 Do mm9s[c]:=1;
BitToWord3(mm3s,OperationFiltr);
BitToWord9(mm9s,DocFiltr);
1:
R.Assign(16, 9, 63, 14);
New(Dlg, Init(R, 'Фильтр операций и документов отгрузки'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx:=$E002;

R.Assign(2, 1, 14, 4);
ControlOperation := New(PCheckboxes, Init(R,
  NewSItem('Клиент',
  NewSItem('Склад',
  NewSItem('Бартер', Nil)))));
Dlg^.Insert(ControlOperation);
ControlOperation^.SetData(OperationFiltr);



R.Assign(17, 1, 45, 4);
ControlDoc := New(PCheckboxes, Init(R,
  NewSItem('Сп',
  NewSItem('Тч',
  NewSItem('ФЛ',
  NewSItem('СФ',
  NewSItem('СФБ',
  NewSItem('Д*',
  NewSItem('Д СФ*',
  NewSItem('Д',
  NewSItem('Д СФБ', Nil)))))))))));
Dlg^.Insert(ControlDoc);
ControlDoc^.SetData(DocFiltr);

Dlg^.SelectNext(False);

c:=Desktop^.ExecView(Dlg);

If c <>cmCancel Then
 Begin
  ControlOperation^.getData(OperationFiltr);
  ControlDoc^.getData(DocFiltr);
  WordToBit3(OperationFiltr,mm3);
  Test:=0;
  For c:=1 To 3 Do If mm3[c]=1 Then Inc(Test);
  If Test=0 Then
   Begin
    MessageBox(^M+#3'Не выбран ни один вид отгрузки!',Nil,mfError+mfCancelButton);
    Dispose(ControlOperation,Done);
    Dispose(ControlDoc,Done);
    Dispose(Dlg,Done);
    Goto 1;
   End;

  WordToBit9(DocFiltr,mm9);
  Test:=0;
  For c:=1 To 9 Do If mm9[c]=1 Then Inc(Test);
  If Test=0 Then
   Begin
    MessageBox(^M+#3'Не выбран ни один вид документа отгрузки!',Nil,mfError+mfCancelButton);
    Dispose(ControlOperation,Done);
    Dispose(ControlDoc,Done);
    Dispose(Dlg,Done);
    Goto 1;
   End;

   Convert3(mm3);
   Convert9(mm9);

   For c:=1 to 3 Do mm3s[c]:=mm3[c];
   For c:=1 to 9 Do mm9s[c]:=mm9[c];
   SelectOperationAndDocument:=True;
 End;
 Dispose(ControlOperation,Done);
 Dispose(ControlDoc,Done);
 Dispose(Dlg,Done);
end;



Function SelectClass(Var l : Maska16):Boolean;

var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  c,k : Word;
Begin
SelectClass:=False;
BitToWord16(l,k);

R.Assign(11, 6, 69, 17);
New(Dlg, Init(R, 'Укажите вид ревизии'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx := $E002;

R.Assign(1, 1, 57, 10);
Control := New(PCheckboxes, Init(R,
  NewSItem(ClassName[1],
  NewSItem(ClassName[2],
  NewSItem(ClassName[3],
  NewSItem(ClassName[4],
  NewSItem(ClassName[5],
  NewSItem(ClassName[6],
  NewSItem(ClassName[7],
  NewSItem(ClassName[8],
  NewSItem(ClassName[9],
  NewSItem(ClassName[10],
  NewSItem(ClassName[11],
  NewSItem(ClassName[12],
  NewSItem(ClassName[13],
  NewSItem(ClassName[14],
  NewSItem(ClassName[15],
  Nil)))))))))))))))));

Dlg^.Insert(Control);

Dlg^.SelectNext(False);

Dlg^.SetData(k);

c:=Desktop^.ExecView(Dlg);

If c<>cmCancel Then
 BEgin
  Dlg^.GetDAta(k);
  WordToBit16(k,l);
  Convert16(l);
  SelectClass:=True;
 End;
  Dispose(Control,Done);
  Dispose(Dlg,Done);
End;



function GetGranizi(M:Maska6;VAr MMM : TAutoString1):Boolean;
var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  c : Word;
  l : LongInt;
begin
GetGranizi:=FAlse;
R.Assign(31, 7, 54, 15);
New(Dlg, Init(R, 'Нац на З/Ц, %'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx := $E002;

For c:=1 To 6 Do
Begin
R.Assign(9, 0+c, 16, 1+c);
Control := New(PInputLine, Init(R, CLitr+1));
If M[c]=0 Then Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['0','1','2','3','4','5','6','7','8','9','0','.']));

  R.Assign(1, 0+c, 9, 1+c);
  Dlg^.Insert(New(PLabel, Init(R, 'Цена ~'+IntToStr(c,COne)+'~:', Control)));
End;

Dlg^.SetData(MMM);
Dlg^.SelectNext(False);
c:=Desktop^.ExecView(Dlg);
If c<>cmCancel Then
 Begin
  Dlg^.GetData(MYS);
  GetGranizi:=True;
  MMM:=MYS;
  WriteNewIni(l);
 End;
Dispose(Control,Done);
Dispose(Dlg,Done);
end;


Function InputBezNal(Var Bn:BezNal;B: BBB):Boolean;
Label 1;
var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  c : WOrd;
  k : LongInt;

begin
1:
InputBezNAl:=False;

R.Assign(12, 8, 67, 15);
New(Dlg, Init(R, 'Безналичный расчет'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.Palette := dpCyanDialog;
Dlg^.HelpCtx := $E002;

R.Assign(3, 2, 13, 3);
Control := New(PInputLine, Init(R, 8));
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PPXPictureValidator, Init({'[##-##-9#]'}DAteFiltr, True));

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
{  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));}

  R.Assign(34, 1, 50, 2);
  Dlg^.Insert(New(PLabel, Init(R, '~С~умма платежа:', Control)));

R.Assign(7, 4, 54, 5);
Control := New(PInputLine, Init(R, 45));
Dlg^.Insert(Control);

  R.Assign(1, 4, 7, 5);
  Dlg^.Insert(New(PLabel, Init(R, 'Б~а~нк:', Control)));

Dlg^.SelectNext(False);

Bn.Date:=B.Date;
Bn.Summa:=B.Summa;
{Bn.NPlat:=B.Doc;
Bn.Bank:=B.Prim;}

Dlg^.SetData(Bn);
c:=Desktop^.ExecView(Dlg);
If c<>cmCancel Then
 Begin
  Dlg^.GetData(Bn);
  DelSpace(Bn.Date);
  DelSpace(Bn.NPlat);
  MyStr(StrToReal(Bn.Summa),CIZena,CMAntissa,Bn.Summa);
  DelSpace(Bn.Summa);
  DelSpaceRight(Bn.Bank);
  If bn.Bank[0]=#0 Then
   Begin
    Dispose(Control,Done);
    Dispose(Dlg,Done);
    MessageBox(#3^M+#3'Не указан банк !',Nil,mfError+mfCancelButton);
    Goto 1;
   End;
  If Not(TestDate(Bn.Date,k)) Then
   Begin
    Dispose(Control,Done);
    Dispose(Dlg,Done);
    MessageBox(#3^M+#3'Не существующая дата !',Nil,mfError+mfCancelButton);
    Goto 1;
   End;
  If bn.Date[0]=#0 Then
   Begin
    Dispose(Control,Done);
    Dispose(Dlg,Done);
    MessageBox(#3^M+#3'Не указана дата п/п !',Nil,mfError+mfCancelButton);
    Goto 1;
   End;
  If bn.NPlat[0]=#0 Then
   Begin
    Dispose(Control,Done);
    Dispose(Dlg,Done);
    MessageBox(#3^M+#3'Не указан номер п/п !',Nil,mfError+mfCancelButton);
         Goto 1;
   End;

  If StrToReal(bn.Summa)=0 Then
   Begin
    Dispose(Control,Done);
    Dispose(Dlg,Done);
    MessageBox(#3^M+#3'Нулевая сумма б/н платежа !',Nil,mfError+mfCancelButton);
    Goto 1;
   End;

  InputBezNal:=True;
End;
Dispose(Control,Done);
Dispose(Dlg,Done);
end;



Procedure CorrectRazdel(Cod:Integer);
Label 1;
Var s  : AllStr;
         c,c1  : LongInt;
         Eb : BazFileType;
         BB : PBAzType;
         Es : SkladFileType;
         SS : PSKladType;
         Skf: SkidkaFileType;
         SkS: PSkidkaType;
         Max,Pr,Emp : AllStr;
         Setup : String[4];
         RKod : ArtikulStr;
         Dlg : PDialog;
         R : TRect;
         Control : PView;

Begin
ClearFind;

If Not(TestOpenDate1(FDate)) Then
        Begin
         MessageBox(#3^M+#3'Доступ к данным за '+FDate+' заблокирован!',Nil,mfError+mfCancelButton);
         Exit;
        End;



C:=IOResult;

If Not(Password(5)) Then Exit;
s:=IntToSTr(Cod,CMAntissa);
RFormatZerro(s,CMAntissa);
RKod:=S;
Assign(Eb,Path.ToName+s+'.id');
Reset(Eb);
C:=IOResult;
If C<>0 Then
Begin
 MessageBox(^M+#3'Ошибка доступа к наименований '+Path.ToName+s+'.id!',nil,mfError+mfCancelButton);
 Exit;
End;

Max:=IntToSTr(FileSize(Eb),4);
DInfoMsg('Определяю свойства раздела...');
New(BB,Init);
Emp[0]:=#0;
Pr[0]:=#0;
While Not(Eof(Eb)) Do
 BEgin
  ReadBazPointer(Eb,BB);
  If (BB^.DAt.Employ) Then
        Begin
         Str((StrToInt(Emp)+1):4,Emp);{занятые позиции}
         Pr:=Copy(BB^.DAt.BAzKod,3,CKod);{последний занятый код}
        End;
 End;
CLose(Eb);
Dispose(BB,Done);
NoInfoMsg;

1:
R.Assign(22, 7, 58, 16);
New(Dlg, Init(R, 'Свойства раздела'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx := $E002;


R.Assign(9,3,23,4);
Control := New(PColoredText, Init(R, 'Всего позиций:', $74));
Dlg^.Insert(Control);

R.Assign(23,3,27,4);
STr(StrToInt(MAx):4,MAx);
Control := New(PColoredText, Init(R, #3+Max, $7E));
Dlg^.Insert(Control);

R.Assign(2, 2, 23, 3);
Control := New(PColoredText, Init(R, 'Используется позиций:', $74));
Dlg^.Insert(Control);

If StrToInt(MAx)>0 Then
Str(StrToInt(Emp)/StrToInt(Max)*100:CLitr+1:CMantissa,s)
Else s:='0.00';

R.Assign(23, 2, 35, 3);
Control := New(PColoredText, Init(R, Emp+' '+s+'%', $7E));
Dlg^.Insert(Control);

R.Assign(2, 1, 35, 2);
Control := New(PColoredText, Init(R, #3+GetRazdel(Rkod)+' ('+
Rkod+')', $7E));
Dlg^.Insert(Control);

R.Assign(1, 6, 35, 7);
Control := New(PStaticText, Init(R, ''));
Control^.Options := Control^.Options or ofFramed;
Dlg^.Insert(Control);


R.Assign(24, 6, 30, 7);
Control := New(PInputLine, Init(R, 4));
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['0','1','2','3','4','5','6','7','8','9']));

  R.Assign(4, 6, 24, 7);
  Dlg^.Insert(New(PLabel, Init(R, 'Установить позиций:', Control)));

R.Assign(6, 4, 23, 5);
Control := New(PColoredText, Init(R, 'Максимальный код:', $74));
Dlg^.Insert(Control);

R.Assign(23, 4, 35, 5);
If pr[0]=#0 Then Pr:='0';
Control := New(PColoredText, Init(R, Pr+' ('+IntToSTr(StrToInt(Pr),4)+')', $7E));
Dlg^.Insert(Control);

Setup:=Max;
DelSpace(Setup);
Dlg^.SetData(Setup);

Dlg^.SelectNext(False);
c:=Desktop^.ExecView(Dlg);
if c<>cmCancel Then
  BEgin
        Dlg^.GetData(Setup);
        If StrToInt(Setup)<(StrToInt(Pr)+1) Then
         BEgin
          Dispose(Control,Done);
          Dispose(Dlg,Done);
          MessageBox(^M+#3'Эта опреация приведет к потере данных! '+
          'Исправьте ошибку и повторите ввод!',Nil,mfError+mfCAncelButton);
          Goto 1;
         End;

        If StrToInt(Setup)>=(1000) Then
         BEgin
          Dispose(Control,Done);
          Dispose(Dlg,Done);
          MessageBox(^M+#3'Слишком большое количество элементов внутри раздела! ',Nil,
          mfError+mfCAncelButton);
          Goto 1;
         End;

Dispose(Control,Done);
Dispose(Dlg,Done);


DInfoMsg('Провожу реструктуризацию. Ждите ...');

        If StrToInt(Setup)>StrToInt(MAx) Then{надо добавлять позиции}
        Begin
         Assign(Eb,Path.ToName+RKod+'.id');
         Reset(Eb);
         c:=Ioresult;
         If c=0 Then
         Begin
          Seek(Eb,StrToInt(Max));
          New(bb,Init);
          For c:=1 To (StrToInt(Setup)-StrToInt(MAx)) Do
                Begin
                 Str(C+StrToInt(MAx)-1:3,S);
                 RFormatZerro(s,3);
                 bb^.Dat.BazKod:=RKod+s;
                 bb^.Dat.Employ:=False;
                 bb^.Dat.Caption:=CurrentPassword;
                 Seek(eb,FileSize(eb));
                 Write(eb,bb^.Dat);
                End;
          Dispose(bb,Done);
          c:=Ioresult;
          Close(Eb);
          c:=Ioresult;
         End{If}
          Else
                Begin
                 NoInfoMsg;
                 MessageBox(^M+#3'Ошибка открытия '+Path.ToName+RKod+'.id',Nil,mfError+mfCancelButton);
                 Exit;
                End;{Else}

         Assign(Es,Path.ToSklad+RKod+'.db');
         Reset(Es);
         c:=Ioresult;
         If c=0 Then
         Begin
          Seek(Es,StrToInt(Max));
          New(ss,Init);
          For c:=1 To (StrToInt(Setup)-StrToInt(MAx)) Do
                Begin
                 Str(C-1+StrToInt(MAx):3,S);
                 RFormatZerro(s,3);
                 ss^.Dat.BazKod:=RKod+s;
                 ss^.Dat.Employ:=False;
                 ss^.Dat.Time:=Times;
                 ss^.Dat.Date:=FDate;
                 Seek(es,FileSize(es));
                 Write(es,ss^.Dat);
                End;
          Dispose(ss,Done);
          c:=Ioresult;
          Close(Es);
          c:=Ioresult;
         End{If}
          Else
                Begin
                 NoInfoMsg;
                 MessageBox(^M+#3'Ошибка открытия '+Path.ToSklad+RKod+'.db',Nil,mfError+mfCancelButton);
                 Exit;
                End;{Else}

         Assign(skf,Path.ToSkidki+RKod+'.skl');
         Reset(skf);
         c:=Ioresult;
         If c=0 Then
         Begin
          Seek(skf,StrToInt(Max));
          New(sks,Init);
          For c:=1 To (StrToInt(Setup)-StrToInt(MAx)) Do
                Begin
                 Str(C-1+StrToInt(MAx):3,S);
                 RFormatZerro(s,3);
                 For c1:=1 To CShkala Do
                 Begin
                  sks^.Dat.Skidka[c1].Up:='0.00';
                  sks^.Dat.Skidka[c1].Proz:='0.00';
                 End;
                 sks^.Dat.Caption:=CurrentPassword;
                 sks^.Dat.BazKod:=RKod+s;
                 sks^.Dat.Time:=Times;
                 sks^.Dat.Date:=FDate;
                 Seek(skf,FileSize(skf));
                 Write(skf,sks^.Dat);
                End;
          Dispose(sks,Done);
          c:=Ioresult;
          Close(skf);
          c:=Ioresult;
         End{If}
          Else
                Begin
                 NoInfoMsg;
                 MessageBox(^M+#3'Ошибка открытия '+Path.ToSkidki+RKod+'.skl',Nil,mfError+mfCancelButton);
                 Exit;
                End;{Else}

        End;


If StrToInt(Setup)<=StrToInt(MAx) Then{надо сокращать позиции}
Begin
         Assign(Eb,Path.ToName+RKod+'.id');
         Reset(Eb);
         c:=Ioresult;
         If c=0 Then
         Begin
         Seek(Eb,StrToInt(Setup));
         c:=Ioresult;
         Truncate(Eb);
         c:=Ioresult;
         Close(Eb);
         c:=Ioresult;
         End
         Else
          Begin
                NoInfoMsg;
                MessageBox(^M+#3'Ошибка открытия '+Path.ToName+RKod+'.id',Nil,mfError+mfCancelButton);
                Exit;
          End;

         Assign(Es,Path.ToSklad+RKod+'.db');
         Reset(Es);
         c:=Ioresult;
         If c=0 Then
         Begin
         Seek(Es,StrToInt(Setup));
         c:=Ioresult;
         Truncate(Es);
         c:=Ioresult;
         Close(Es);
         c:=Ioresult;
         End
         Else
          Begin
                NoInfoMsg;
                MessageBox(^M+#3'Ошибка открытия '+Path.ToSklad+RKod+'.db',Nil,mfError+mfCancelButton);
                Exit;
          End;

         Assign(skf,Path.ToSkidki+RKod+'.skl');
         Reset(skf);
         c:=Ioresult;
         If c=0 Then
         Begin
         Seek(skf,StrToInt(Setup));
         c:=Ioresult;
         Truncate(skf);
         c:=Ioresult;
         Close(skf);
         c:=Ioresult;
         End
         Else
          Begin
                NoInfoMsg;
                MessageBox(^M+#3'Ошибка открытия '+Path.ToSkidki+RKod+'.skl',Nil,mfError+mfCancelButton);
                Exit;
          End;
End;
NoInfoMsg;


  End
Else
Begin
Dispose(Control,Done);
Dispose(Dlg,Done);
End;

End;



Procedure SetupPassword;
var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  ArrayPsw : Array [1..15] Of String[10];
  f : Text;
  c : Word;
begin

  Assign(f,Path.ToSklad+'p.pwl');
  c:=IOResult;
  Reset(f);
  c:=IOResult;
  If c=0 Then
   Begin
    c:=0;
    While Not(Eof(f)) And (c<15) Do
    Begin
    Inc(c);
    Readln(f,ArrayPsw[c]);
    UpStr(ArrayPsw[c]);
    ArrayPsw[c]:=Decode(ArrayPsw[c])
    End;
    c:=IOResult;
    Close(f);
   End
   Else
    Begin
     For c:=1 To 15 Do
      Begin
       ArrayPsw[c,0]:=#0;
      End;
    End;

R.Assign(23, 6, 56, 25);
New(Dlg, Init(R, 'Настройка паролей'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.Palette := dpCyanDialog;
Dlg^.HelpCtx := $E002;

R.Assign(20, 1, 32, 2);
Control := New(PInputLine, Init(R, 10));
Dlg^.Insert(Control);

  R.Assign(1, 1, 20, 2);
  Dlg^.Insert(New(PLabel, Init(R, 'Уровень доступа ~1~:', Control)));

R.Assign(20, 2, 32, 3);
Control := New(PInputLine, Init(R, 10));
Dlg^.Insert(Control);

  R.Assign(1, 2, 20, 3);
  Dlg^.Insert(New(PLabel, Init(R, 'Уровень доступа ~2~:', Control)));

R.Assign(20, 3, 32, 4);
Control := New(PInputLine, Init(R, 10));
Dlg^.Insert(Control);

  R.Assign(1, 3, 20, 4);
  Dlg^.Insert(New(PLabel, Init(R, 'Уровень доступа ~3~:', Control)));

R.Assign(20, 4, 32, 5);
Control := New(PInputLine, Init(R, 10));
Dlg^.Insert(Control);

  R.Assign(1, 4, 20, 5);
  Dlg^.Insert(New(PLabel, Init(R, 'Уровень доступа ~4~:', Control)));

R.Assign(20, 5, 32, 6);
Control := New(PInputLine, Init(R, 10));
Dlg^.Insert(Control);

  R.Assign(1, 5, 20, 6);
  Dlg^.Insert(New(PLabel, Init(R, 'Уровень доступа ~5~:', Control)));

R.Assign(20, 6, 32, 7);
Control := New(PInputLine, Init(R, 10));
Dlg^.Insert(Control);

  R.Assign(1, 6, 20, 7);
  Dlg^.Insert(New(PLabel, Init(R, 'Уровень доступа ~6~:', Control)));

R.Assign(20, 7, 32, 8);
Control := New(PInputLine, Init(R, 10));
Dlg^.Insert(Control);

  R.Assign(1, 7, 20, 8);
  Dlg^.Insert(New(PLabel, Init(R, 'Уровень доступа ~7~:', Control)));

R.Assign(20, 8, 32, 9);
Control := New(PInputLine, Init(R, 10));
Dlg^.Insert(Control);

  R.Assign(1, 8, 20, 9);
  Dlg^.Insert(New(PLabel, Init(R, 'Уровень доступа ~8~:', Control)));

R.Assign(20, 9, 32, 10);
Control := New(PInputLine, Init(R, 10));
Dlg^.Insert(Control);

  R.Assign(1, 9, 20, 10);
  Dlg^.Insert(New(PLabel, Init(R, 'Уровень доступа ~9~:', Control)));

R.Assign(20, 10, 32, 11);
Control := New(PInputLine, Init(R, 10));
Dlg^.Insert(Control);

  R.Assign(1, 10, 20, 11);
  Dlg^.Insert(New(PLabel, Init(R, 'Уровень доступа10:', Control)));


R.Assign(20, 11, 32, 12);
Control := New(PInputLine, Init(R, 10));
Dlg^.Insert(Control);

  R.Assign(1, 11, 20, 12);
  Dlg^.Insert(New(PLabel, Init(R, 'Уровень доступа11:', Control)));

R.Assign(20, 12, 32, 13);
Control := New(PInputLine, Init(R, 10));
Dlg^.Insert(Control);

  R.Assign(1, 12, 20, 13);
  Dlg^.Insert(New(PLabel, Init(R, 'Уровень доступа12:', Control)));

R.Assign(20, 13, 32, 14);
Control := New(PInputLine, Init(R, 10));
Dlg^.Insert(Control);

  R.Assign(1, 13, 20, 14);
  Dlg^.Insert(New(PLabel, Init(R, 'Уровень доступа13:', Control)));

R.Assign(20, 14, 32, 15);
Control := New(PInputLine, Init(R, 10));
Dlg^.Insert(Control);

  R.Assign(1, 14, 20, 15);
  Dlg^.Insert(New(PLabel, Init(R, 'Уровень доступа14:', Control)));

R.Assign(20, 15, 32, 16);
Control := New(PInputLine, Init(R, 10));
Dlg^.Insert(Control);

  R.Assign(1, 15, 20, 16);
  Dlg^.Insert(New(PLabel, Init(R, 'Уровень доступа15:', Control)));

Dlg^.SelectNext(False);

Dlg^.SetData(ArrayPsw);

c:=Desktop^.ExecView(Dlg);
If c<>cmCancel Then
 Begin
  Dlg^.GetData(ArrayPsw);

       Assign(f,Path.ToSklad+'p.pwl');
       c:=IOResult;
       Rewrite(f);
       c:=IOResult;

     For c:=1 To 15 Do
      Begin
       ArrayPsw[c]:=Code(ArrayPsw[c]);
       Writeln(f,ArrayPsw[c]);
      End;
       Close(f);
       c:=IOResult;
      AddProtocol ('Корректировка уровней доступа в системе!  {Очень важно}','','');
End;

Dispose(Control,Done);
Dispose(Dlg,Done);
end;





Function GetImportFileName(As:DocumentEdit;SkladKod:ArtikulStr):AllStr;
Begin
 SkladKod:=IntToStr(StrToInt(SkladKod),CMantissa);
 RFormatZerro(SkladKod,CMantissa);
 DelSpace(As.EditPosition);
 As.EditPosition:=IntToStr(StrToInt(As.EditPosition),CDocNumer);
 RFormatZerro(As.EditPosition,CLitrMantissa);
 While Pos('-',As.D)>0 Do As.D[Pos('-',As.D)]:=' ';
 DelSpace(As.D);
 GetImportFileName:=SkladKod+As.D+'.'+As.EditPosition;
End;


Function Filtration(Var M : Maska9):Boolean;
Label 1;
Var i,j: Word;
    Dlg : PDialog;
    R :  TRect;
    Control : PView;
Begin
Filtration:=False;
For i:=1 To Max9 Do m[i]:=1;
BitToWord9(m,i);
1:
R.Assign(21, 8, 60, 13);
New(Dlg, Init(R, 'Фильтр документов'));
Dlg^.HelpCtx:=$E002;

R.Assign(1, 1, 38, 4);
Control := New(PCheckboxes, Init(R,
  NewSItem('Список',
  NewSItem('Тов.чек*',
  NewSItem('Физ.Л',
  NewSItem('СФ',
  NewSItem('СФБ',
  NewSItem('Дебит*',
  NewSItem('Д СФ',
  NewSItem('Дебит',
  NewSItem('Д СФБ', Nil)))))))))));
Dlg^.Insert(Control);

Dlg^.SetData(i);

Dlg^.SelectNext(False);

i:=Desktop^.ExecView(Dlg);
if i<>cmCancel Then
 Begin
  Dlg^.GetData(j);
  WordToBit9(j,m);
  Convert9(m);
  j:=0;
  For i:=1 To Max9 Do
   Begin
    If m[i]=1 Then
     Begin
         Inc(j);
      Break;
     End;
   End;
  BitToWord9(m,i);
   If j=0 Then
    Begin
     MessageBox(^M+#3'Вы не выбрали ни один вид документов отгрузки!'+
        ' Повторите выбор!',Nil,mfWarning+mfCancelButton);
     Dispose(Control,Done);
     Dispose(Dlg,Done);
     Goto 1;
    End;
  Filtration:=True;
 End;

Dispose(Control,Done);
Dispose(Dlg,Done);
End;


Function TestElementR (Const S : AllStr;Const P : PBox) : Boolean;
Var ls : Word;
    k  : Byte;
    st : String[CALL];
Begin
TestElementR:=True;
For ls :=0 To P^.List^.Count Do
Begin
St:=P^.GetText(ls,P^.List^.Count);
k:=Pos('│',St);
ST:=Copy(St,K+1,CRAzdelKod);
If St=S Then
   Begin
    TestElementR:=False;
    Break;
   End;
End;
End;


Function SelectShkala(Var l : Word;Reg : Word):Boolean;
var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  c : Word;
  TestBox : PBox;
  s : AllStr;
  SRegion : TDateString;
begin
SelectShkala:=False;

{
Region:=0;
Region:=SelectRegion;
If Region=4 Then
Begin
Exit;
End;
}

SRegion[0]:=#0;
CAse Reg Of
0:SRegion:='Офис';
1:SRegion:='Город';
2:SRegion:='Область';
3:SRegion:='Резерв';
Else;
End;


R.Assign(29, 4, 60, 18);
New(Dlg, Init(R, SRegion));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx:=$E241;

R.Assign(30, 1, 31, 13);
Control := New(PScrollBar, Init(R));
Dlg^.Insert(Control);

R.Assign(1, 1, 30, 13);
TestBox := New(PBox, Init(R, 1, PScrollbar(Control)));
TestBox^.NewList(New(PMyCollection{TextCollection}, Init(0,1)));

  s:='Р/Цена';
  TestBox^.List^.Insert(NewStr(s));

  For c:=1 To 6 Do
   Begin
    s:=IntToStr(c,cMantissa);
    RFormat(s,CMantissa);
    s:='Цена '+IntToStr(C,CMantissa);
    TestBox^.List^.Insert(NewStr(s));
    TestBox^.SetRange(TestBox^.List^.Count);
   End;

Dlg^.Insert(TestBox);

TestBox^.FocusItem(0);

Dlg^.SelectNext(False);
c:=Desktop^.ExecView(Dlg);
if c<>cmCancel Then
Begin
 SelectShkala:=True;
 c:=TestBox^.Focused;
 If c=0 Then l:=0
 Else
  l:=Reg*6+c;
End;
Dispose(TestBox,Done);
Dispose(Control,Done);
Dispose(Dlg,Done);
end;




Procedure CalcRaspredelenie(L:PSuperMarketType;Var Es:PstatClientType);
Var i,j:Word;
    k : Real;
    MasStr1,MasStr2 : Array[0..MaxStatRazdel] of AllStr;
    ws,ws1 : String[CIZena];
Begin
 For j:=0 To MaxStatRazdel Do
 Begin
  For i:=1 To L^.Dat.Amount Do
   Begin
    {нашли позицию}

    If StrToInt(Copy(L^.Dat.MarketElement[i].BazKod,1,CRazdelKod))=j Then
     Begin
      {расчитываем сумму отгрузки}
      (*
      ws:=RealToStr(Es^.Dat.RazdelSum[j],CIZena,CMantissa);
      Str(StrToReal(ws){Es^.Dat.RazdelSum[j]}+StrToReal(L^.Dat.MarketElement[i].Input.Zena)*
                                StrToInt (L^.Dat.MarketElement[i].Input.Kol):CIZena:CMantissa,ws);
      Es^.Dat.RazdelSum[j]:=StrToReal(ws);
      *)
      Case L^.Dat.SkidkaSelector Of
      0,2:Begin
        Str(
        (StrToReal(L^.Dat.MarketElement[i].Input.Zena)-
         StrToReal(L^.Dat.MarketElement[i].Input.Zena)*(StrToReal(L^.Dat.MarketElement[i].Input.Proz))):CIZena:CMantissa,ws);
        Str(Es^.Dat.RazdelSkid[j]+StrToInt (L^.Dat.MarketElement[i].Input.Kol)*
        StrToReal(ws):CIZena:CMantissa,ws);
        Es^.Dat.RazdelSkid[j]:=StrToReal(ws);

        Str(
        (StrToReal(L^.Dat.MarketElement[i].Input.Zena)-
         StrToReal(L^.Dat.MarketElement[i].Input.Zena)*
        (StrToReal(L^.Dat.MarketElement[i].Input.Proz))):CIZena:CMantissa,ws1);

        Str(
        StrToReal(L^.Dat.MarketElement[i].Input.Zena)-
        StrToReal(ws1):CIZena:CMantissa,ws1);
        End;
      1:Begin
        ws:=RealToStr(Es^.Dat.RazdelSkid[j],CIZena,CMantissa);
        Str(StrToReal(ws)+StrToInt (L^.Dat.MarketElement[i].Input.Kol)*
        StrToReal(L^.Dat.MarketElement[i].Input.Skidka):CIZena:CMantissa,ws);
        Es^.Dat.RazdelSkid[j]:=StrToReal(ws);
        Str(
        StrToReal(L^.Dat.MarketElement[i].Input.Zena)-
        StrToReal(L^.Dat.MarketElement[i].Input.Skidka):CIZena:CMantissa,ws1);
        End;
      Else;
      End;

      ws:=RealToStr(Es^.Dat.RazdelSum[j],CIZena,CMantissa);
      Str(StrToReal(ws){Es^.Dat.RazdelSum[j]}+StrToReal(ws1)*
                                StrToInt (L^.Dat.MarketElement[i].Input.Kol):CIZena:CMantissa,ws);
      Es^.Dat.RazdelSum[j]:=StrToReal(ws);


      ws:=RealToStr(Es^.Dat.RazdelZak[j],CIZena,CMantissa);
      Str(StrToReal(ws)+StrToReal(L^.Dat.MarketElement[i].Input.Zakupka)*
                                StrToInt (L^.Dat.MarketElement[i].Input.Kol):CIZena:CMantissa,ws);
      Es^.Dat.RazdelZak[j]:=StrToReal(ws);
     End;
   End;{по позициям}
 End;{по разделам}
End;


Function SaveToStatFile(L:PSuperMarketType;S:Boolean;R:boolean):Boolean;
Var Es : PstatClientType;
    Esf : File Of StatClientType;
    i : Byte;
Begin
 SaveToStatFile:=False;
 Assign(esf,Path.ToClient+L^.Dat.ClientKod+'.his');
 i:=IOResult;
 Reset(esf);
 i:=IOResult;
 If i <> 0 Then
  Begin
   If MessageBox(#3'Файл расчетов с клиентом '^M+#3+Path.ToClient+L^.Dat.ClientKod+'.his не найден!'^M+
   #3'Создать файл заново ?',Nil,mfWarning+mfOkCancel)=cmOk Then
    Begin
        i:=IOResult;
        Rewrite(Esf);
        i:=IOResult;
        If i<>0 Then
         Begin
          MessageBox(^m+#3'Не могу создать файл '^M+
          #3+Path.ToClient+L^.Dat.ClientKod+'.his',Nil,mfError+mfCancelButton);
          Exit;
         End;
    End
    Else Exit;
  End;
 New(Es,Init);
         With Es^.Dat Do
          Begin
        If L^.Dat.DocSelector in [4,8] Then    Rashet:=0
        Else    Rashet:=1;

        TrueRealiz:=R;

        Realiz:=L^.Dat.Realiz;
        Document:=L^.Dat.Document;
        ENalog  :=L^.Dat.ENalog;
        Nalog5  :=L^.Dat.Nalog5;
        Nalog3  :=L^.Dat.Nalog3;
        Nalog_  :=L^.Dat.Nalog_;
        SummaZ:=L^.Dat.SummaZ;;
        Skidka:=L^.Dat.Skidka;
        SummaZakupka:=L^.Dat.SummaZakupka;
        Bn.DAte:=L^.Dat.bn.Date;
        Bn.NPlat:=L^.Dat.bn.NPlat;
        Bn.Bank:=L^.Dat.bn.Bank;
        Bn.Summa:=L^.Dat.bn.Summa;
        Caption:=L^.Dat.Caption;
        DateC:=L^.Dat.DateC;;
        TimeC:=L^.Dat.TimeC;
        DateM:=L^.Dat.DateM;
        TimeM:=L^.Dat.TimeM;;
        SkladKod:=FormKod(Rek.Kod);
        ShkalaNumer:=L^.DAt.ShkalaNumer;
        Region:=L^.DAt.Region;
        DocSelector :=L^.Dat.DocSelector;
        SkidkaSelector :=L^.Dat.SkidkaSelector;
        ClientKod:=L^.Dat.ClientKod;
        AgentKod:=L^.Dat.AgentKod;
        Active:=True;
        Sf :=S;
        CalcRaspredelenie(L,Es);
          End;
          i:=IOResult;
          Seek(Esf,FileSize(Esf));
          i:=IOResult;
          Write(Esf,Es^.Dat);
          i:=IOResult;

        If i<>0 Then
         Begin
          DiSpose(Es,Done);
          Close(Esf);
          MessageBox(#3'Ошибка записи в файл '^M+
          #3+Path.ToClient+L^.Dat.ClientKod+'.his'^M+ClicProgrammer+' '+
                IntToStr(i,3),Nil,mfError+mfCancelButton);
          Exit;
         End;

Dispose(Es,Done);
i:=IOResult;
Close(Esf);
i:=IOResult;
SaveToStatFile:=True;
End;

(*
Function DeleteOfStatFile(PrevMarket:PSuperMarketType):Boolean;
Var Es : PStatClientType;
    Esf : File Of StatClientType;
    NewEsf : File Of StatClientType;
    i : Byte;
    Log : Boolean;
Begin
 DeleteOfStatFile:=False;
 Assign(Esf,Path.ToClient+PrevMarket^.Dat.ClientKod+'.his');
 Assign(NewEsf,Path.ToClient+PrevMarket^.Dat.ClientKod+'.new');
 Rewrite(NewEsf);
 i:=IOResult;
 Reset(Esf);
 i:=IOResult;
 If i <> 0 Then
  Begin
    MessageBox(#3^M+#3'Файл долгов клиента '^M+#3+Path.ToClient+PrevMarket^.Dat.ClientKod+'.his не найден!'^M
   ,Nil,mfError+mfCancelButton);
    Close(NewEsf);
    Exit;
  End;
        New(Es,Init);
        DelSpace(PrevMarket^.Dat.Document);
        While Not(Eof(Esf))Do
        Begin
         Read(Esf,Es^.Dat);
         DelSpace(Es^.Dat.Document);
          If Not((ClearChar(PrevMarket^.Dat.Document)=ClearChar(Es^.Dat.Document))And
          (PrevMArket^.Dat.DateC=Es^.Dat.DateC)) Then
          Write(NewEsF,Es^.Dat);
        End;
    Close(NewEsf);
    Close(Esf);
    Dispose(Es,Done);
    Erase(Esf);
    Rename(NewEsf,Path.ToClient+PrevMarket^.Dat.ClientKod+'.his');
    DeleteOfStatFile:=True;
End;
*)



Function DeleteOfStatFile(PrevMarket:PSuperMarketType):Boolean;
Var Es : PStatClientType;
    Esf : File Of StatClientType;
    i : Byte;
    Find : Boolean;
Begin
 DeleteOfStatFile:=False;
 Assign(Esf,Path.ToClient+PrevMarket^.Dat.ClientKod+'.his');
 i:=IOResult;
 Reset(Esf);
 i:=IOResult;
 If i <> 0 Then
  Begin
    MessageBox(#3+'Файл расчетов с клиентом '^M+#3+Path.ToClient+PrevMarket^.Dat.ClientKod+'.his не найден!'^M+
    ClicProgrammer
   ,Nil,mfError+mfCancelButton);
    Exit;
  End;
        New(Es,Init);
        DelSpace(PrevMarket^.Dat.Document);
        Find:=False;
        DInfoMsg('Ищу документ в персональном файле клиента '+PrevMarket^.Dat.ClientKod+'...');
        While Not(Eof(Esf)) and not(find) Do
        Begin
         Read(Esf,Es^.Dat);
         DelSpace(Es^.Dat.Document);
          If ((ClearChar(PrevMarket^.Dat.Document)=ClearChar(Es^.Dat.Document))And
          (PrevMArket^.Dat.DateC=Es^.Dat.DateC) And (Es^.Dat.Active)) Then Find:=True;
        End;

  If Not(Find) Then
   Begin
    NoInfoMsg;
    Dispose(Es,Done);
    Close(EsF);
    MessageBox(#3'Документ N '+ClearChar(PrevMarket^.Dat.Document)+
    ' от '+PrevMArket^.Dat.DateC+' в файле расчетов с клиентом не найден!'^M+
    ClicProgrammer,Nil,mfError+mfCancelButton);
    Exit;
   End;

    Seek(Esf,FilePos(Esf)-1);
    Es^.Dat.Active:=False;
    i:=IOResult;
    Write(Esf,Es^.Dat);
    i:=IoREsult;
        If i<>0 Then
         Begin
          DiSpose(Es,Done);
          Close(Esf);
          MessageBox(#3'Ошибка записи в файл '^M+
          #3+Path.ToClient+PrevMArket^.Dat.ClientKod+'.his'^M+ClicProgrammer+' '+
                IntToStr(i,3),Nil,mfError+mfCancelButton);
          Exit;
         End;
    Close(EsF);
    i:=IoREsult;
    Dispose(Es,Done);
    NoInfoMsg;
    DeleteOfStatFile:=True;
End;


Function TestSrokLizensia(c:AllStr;Date:TDateString):Boolean;
Var f : ClientFileType;
    l : LongInt;
    Code : Integer;
    s : ClientType;
    st : ArtikulStr;
Begin
 Assign(f,Path.ToClient+'Client.db');
 TestSrokLizensia:=False;
 l:=IOResult;
 Reset(f);
 l:=IOResult;
 If l <> 0 Then
 Begin
  MessageBox(#3'Ошибка открытия файла клиентов!',nil,mfError+mfCancelButton);
  Exit;
 End
 Else
  Begin
   DelSpace(c);
   l:=StrToInt(c);
   Seek(f,l);
     {
     Repeat
     Until NetCall.Lock(f,FilePos(f)*SizeOf(ClientType),SizeOf(ClientType));
     }
     ReadClient(f,s);
     {
     Repeat
      NetCall.UnLock(f,(FilePos(f)-1)*SizeOf(ClientType),SizeOf(ClientType));
     Until (DosError=0);
     }
   Close(f);
   {l:=DateStringToDate(DateMask,S.SrokLizensia);}
   DelSpace(S.SrokLizensia);
   If (DateStringToDate(DateMAsk,Date)<=DateStringToDate(DateMask,S.SrokLizensia))And
      (S.SrokLizensia[0]<>#0)  Then
   TestSrokLizensia:=True;
  End;
End;




function SelectOtdel(Var Otdel:Word) : Boolean;
Label 1;
var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  w,c : Word;

begin
Otdel:=255;
SelectOtdel:=False;
1:
R.Assign(30, 7, 47, 13);
New(Dlg, Init(R, 'Укажите отделения'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx:=$E002;
R.Assign(1, 1, 16, 5);
Control := New(PCheckboxes, Init(R,
  NewSItem('~1~',
  NewSItem('~2~',
  NewSItem('~3~',
  NewSItem('~4~',
  NewSItem('~5~',
  NewSItem('~6~',
  NewSItem('~7~',
  NewSItem('~8~',
  Nil))))))))));
Dlg^.Insert(Control);
Dlg^.SetData(Otdel);

Dlg^.SelectNext(False);
w:=Desktop^.ExecView(Dlg);
If w<>cmCancel Then
 Begin
  Dlg^.GetDAta(Otdel);
  If Otdel<>0 Then SelectOtdel:=True;
  If Otdel=0 Then
   Begin
    Dispose(Control,Done);
    Dispose(Dlg,Done);
    MessageBox(^M+#3'Не выбрано ни одного отделения!',nil,mfError+mfCancelButton);
    Goto 1;
   End;
 End;
Dispose(Control,Done);
Dispose(Dlg,Done);
end;


Function GetEnvMy:string;
Var Ver : Word;
Begin
Ver := DosVersion;
If Ver<>5{ у XP и 2000 версия 5} {Not(FindParam('/WIN2K'))} Then GetEnvMy:=GetEnv('Comspec')
Else GetEnvMy:=GetEnv('SYSTEMROOT')+'\SYSTEM32\cmd.exe';
End;


Procedure SetupStart;

Label 1;

Type StartNumer=Record
     PrhNum : ArtikulStr;
     NaklNum : ArtikulStr;
     SfNum : ArtikulStr;
     End;
var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  Start : StartNumer;
  C : Word;

begin
Start.PrhNum[0]:=#0;
Start.NaklNum[0]:=#0;
Start.SfNum[0]:=#0;
MessageBox(^M+#3'Функция требует монопольного использования базы!',Nil,mfWarning+mfCancelButton);

1:

R.Assign(27, 9, 53, 14);
New(Dlg, Init(R, 'Стартовые номера'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx := $E002;

R.Assign(12, 1, 19, 2);
Control := New(PInputLine, Init(R, 5));
Dlg^.Insert(Control);

  R.Assign(7, 1, 12, 2);
  Dlg^.Insert(New(PLabel, Init(R, 'ПКО:', Control)));

R.Assign(12, 2, 19, 3);
Control := New(PInputLine, Init(R, 5));
Dlg^.Insert(Control);

  R.Assign(1, 2, 12, 3);
  Dlg^.Insert(New(PLabel, Init(R, 'Накладные:', Control)));

R.Assign(12, 3, 19, 4);
Control := New(PInputLine, Init(R, 5));
Dlg^.Insert(Control);

  R.Assign(7, 3, 12, 4);
  Dlg^.Insert(New(PLabel, Init(R, 'С/Ф:', Control)));

Dlg^.SelectNext(False);
Dlg^.SetData(Start);
c:=Desktop^.ExecView(Dlg);

If c<>cmCancel Then
 Begin
  Dlg^.GetData(Start);
  Dispose(Control,Done);
  Dispose(Dlg,Done);
  If StrToInt(Start.PrhNum)=0 Then
  Begin
   MessageBox(^M+#3'Недопустимый номер ПКО!',Nil,mfError+mfCancelButton);
   Goto 1;
  End;
  If StrToInt(Start.NaklNum)=0 Then
  Begin
   MessageBox(^M+#3'Недопустимый номер накладной!',Nil,mfError+mfCancelButton);
   Goto 1;
  End;

  If StrToInt(Start.SfNum)=0 Then
  Begin
   MessageBox(^M+#3'Недопустимый номер Счета-фактуры!',Nil,mfError+mfCancelButton);
   Goto 1;
  End;

  SetFreeReestrNum( 0,Start.PrhNum);
  SetFreeReestrNum( 1,Start.SfNum);
  SetFreeReestrNum( 2,Start.NaklNum);


 End
Else
BEgin
Dispose(Control,Done);
Dispose(Dlg,Done);
End;
end;



Function FormLineOtdel(R:Byte):AllStr;
VAr s : AllStr;
Begin
s:=Rek.Otdel[r];
Format(s,CIZena);
s:='Отделение N '+IntToStr(r,COne)+' - '+s;
FormLineOtdel:=s;
End;



Begin
 Randomize;
 RandSeed:=4;
End.
