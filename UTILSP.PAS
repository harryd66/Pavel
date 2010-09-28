{$I Compile.INC}

{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}
Unit Utilsp;

Interface

Uses Dialogs,Glob,ColorTxt,ServStr,Views,Utils;

Const Max2=2;
      Max4=4;
      Max6=6;
      Max9=9;
      Max10=10;
      Max11=11;
{
Type Maska5 = Array [1..5] Of Word;
Type Maska6 = Array [1..6] Of Word;
Type Maska7 = Array [1..7] Of Word;
Type Maska9 = Array [1..9] Of Word;
Type Maska10 = Array [1..10] Of Word;
Type Maska8 = Array [1..8] Of Word;
Type Maska4 = Array [1..4] Of Word;
Type Maska3 = Array [1..3] Of Word;
Type Maska2 = Array [1..2] Of Word;
}

Type Maska11 = Array [1..Max11] Of Word;

Function TestElement (Const S : AllStr;Const P : PBox) : Boolean;
Function TestRazdelMemory (Const S : AllStr;Const P : PBox) : Boolean;
{Procedure GlobalSkidka1(Summa:String);}
{Procedure GlobalNazenka1(Summa:String);}
Function TTime:Boolean;
function NewPassword(i:Byte) : Boolean;

Procedure Unique(Path: string; Var FileName: String);
function Crypt(S : String) : string;

function Decrypt(S : String) : string;
function Encrypt(S : String) : string;
Procedure CalcToDayOplata(ClKod:ArtikulStr; Var Sum:AllStr);
procedure AboutChm(page:string);
Procedure WordToBit2 (n:Word; Var b : Maska2);
Procedure WordToBit4 (n:Word; Var b : Maska4);
Procedure WordToBit5 (n:Word; Var b : Maska5);
Procedure WordToBit6 (n:Word; Var b : Maska6);
{Procedure WordToBit7 (n:Word; Var b : Maska7);}
Procedure WordToBit9 (n:Word; Var b : Maska9);
Procedure WordToBit10 (n:Word; Var b : Maska10);
Procedure WordToBit11 (n:Word; Var b : Maska11);
{Procedure WordToBit8 (n:Word; Var b : Maska8);}
Procedure WordToBit3 (n:Word; Var b : Maska3);
Function Stepen(i:Word):Word;
Procedure BitToWord2 ( b : Maska2; Var n:Word);
Procedure BitToWord4 ( b : Maska4; Var n:Word);
Procedure BitToWord6 ( b : Maska6; Var n:Word);
Procedure BitToWord5 ( b : Maska5; Var n:Word);
Procedure BitToWord9 ( b : Maska9; Var n:Word);
Procedure BitToWord10 ( b : Maska10; Var n:Word);
Procedure BitToWord11 ( b : Maska11; Var n:Word);
Procedure BitToWord3 ( b : Maska3; Var n:Word);

Procedure Convert7(Var b:Maska7);
Procedure Convert6(Var b:Maska6);
Procedure Convert5(Var b:Maska5);
Procedure Convert3(Var b:Maska3);
Procedure Convert4(Var b:Maska4);
Procedure Convert2(Var b:Maska2);
Procedure Convert8(Var b:Maska8);
Procedure Convert9(Var b:Maska9);
Procedure Convert10(Var b:Maska10);
Procedure Convert11(Var b:Maska11);
Procedure CorrectBaza(Reg,Sel:Word);
Function SelectImportDocument(Var P:PImportSuperMarketType):Boolean;
Function AddMarkerLast(Var L:PSuperMarketType) : Boolean;
Procedure ReadRekSF(Var Res : LongInt);
Procedure WriteRekSF(Var Res : LongInt);
Procedure ChangeRekwizitiSF;
Procedure GlobalSkidkaPereezd(ClKod:ArtikulStr;Op:Word);
procedure About;
Procedure Test_Srok(Const Spis:PBox;Const M:MaskaNew;Const Assort,Sort:Word);
function DosToWin(s:string):string;

implementation


Uses app,Drivers,Memory,Dos,MsgBox,Objects,Validate,TpDate,Serv,WinDos,
     Printers,Vision1,Tools,
     DbEngine,NetCall,CPrihod,Protect,NetDbEng,MrkTool;


Const EncryptionKey : String[80]='MNOPQRSTUVWXYZABCDEFGHIJKL';
const
  Digits : Array[0..$F] of Char = '0123456789ABCDEF';


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


Procedure GlobalSkidka1(Summa:String);
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
If Prodaga^.List^.Count>0 Then
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
    k:=RealToStr(StrToReal(St)/StrToReal(Summa),CLitr+1,CLitrMantissa+1);
   End;


If Prodaga^.List^.Count>0 Then
Begin

  R.Assign(0,0,0,0);
  WspomlIST1 := New(PBox, Init(R, 1, Nil));
  WspomList1^.NewList(New(PTextCollection, Init(0,1)));

For ls:=0 To Prodaga^.List^.Count-1 Do
 Begin
{артикул}
 s:=Prodaga^.GetText(ls,Prodaga^.List^.Count);
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
{очистка Prodaga}

  Prodaga^.NewList(Nil);
  Prodaga^.NewList(New(PTextCollection, Init(0,1)));

{обновление Prodaga}
For ls:=0 To WspomList1^.List^.Count-1 Do
 Begin
{артикул}
 s:=WspomList1^.GetText(ls,WspomList1^.List^.Count);
 Prodaga^.List^.Insert(NewStr(s));
 Prodaga^.SetRange(Prodaga^.List^.Count);
End;{For}

{удаление Wspom}
Dispose(WspomList1,Done);
End;{Prodaga^.List^.Count>0}
 End
 Else
 Begin
  Dispose(Control,Done);
  Dispose(Dlg,Done);
 End;
End;{If Prodaga^.List^.Count>0 Then}
end;

Procedure GlobalNazenka1(Summa:String);
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
If Prodaga^.List^.Count>0 Then
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


If Prodaga^.List^.Count>0 Then
Begin

  R.Assign(0,0,0,0);
  WspomlIST1 := New(PBox, Init(R, 1, Nil));
  WspomList1^.NewList(New(PTextCollection, Init(0,1)));

For ls:=0 To Prodaga^.List^.Count-1 Do
 Begin
{артикул}
 s:=Prodaga^.GetText(ls,Prodaga^.List^.Count);
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
{очистка Prodaga}

  Prodaga^.NewList(Nil);
  Prodaga^.NewList(New(PTextCollection, Init(0,1)));

{обновление Prodaga}
For ls:=0 To WspomList1^.List^.Count-1 Do
 Begin
{артикул}
 s:=WspomList1^.GetText(ls,WspomList1^.List^.Count);
 Prodaga^.List^.Insert(NewStr(s));
 Prodaga^.SetRange(Prodaga^.List^.Count);
End;{For}

{удаление Wspom}
Dispose(WspomList1,Done);
End;{Prodaga^.List^.Count>0}
 End
 Else
 Begin
  Dispose(Control,Done);
  Dispose(Dlg,Done);
 End;
End;{If Prodaga^.List^.Count>0 Then}
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

Procedure Unique(Path: string; Var FileName: String);
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



  function HexB(B : Byte) : string;
    {-Return hex string for byte}
  begin
    HexB[0] := #2;
    HexB[1] := Digits[B shr 4];
    HexB[2] := Digits[B and $F];
  end;




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

Procedure WordToBit11 (n:Word; Var b : Maska11);
  Var i : Word;
Begin
 For i:=Max11 DownTo 1 Do
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

Procedure BitToWord3 ( b : Maska3; Var n:Word);
  Var i : Word;
Begin
 N:=0;
 For i:=1 To 3 Do
  Begin
  N:=N+b[i]*Stepen(3-i);
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

Procedure BitToWord11 ( b : Maska11; Var n:Word);
  Var i : Word;
Begin
 N:=0;
 For i:=1 To Max11 Do
  Begin
  N:=N+b[i]*Stepen(Max11-i);
  End;
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

Procedure Convert11(Var b:Maska11);
Var l,k : Byte;
    w : Maska11;
Begin
 k:=Max11;
 For l:=1 To Max11 Do
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



Procedure CorrectBaza(Reg,Sel:Word);
Label 1;
Var s,s1  : AllStr;
         c,c1  : LongInt;
         Max,Pr,Emp : AllStr;
         Setup : String[4];
         RKod : ArtikulStr;
         Dlg : PDialog;
         R : TRect;
      ClientFile : ClientFileType;
         Control : PView;
      BB : PClientType;
Begin
ClearFind;

If Not(TestOpenDate1(FDate)) Then
        Begin
         MessageBox(#3^M+#3'Доступ к данным за '+FDate+' заблокирован!',Nil,mfError+mfCancelButton);
         Exit;
        End;



C:=IOResult;

If Not(Password(2)) Then Exit;

s[0]:=#0;
s1[0]:=#0;
Case Reg Of
0:Begin
    Case Sel Of
     0:Begin s:=Path.ToClient+'Client.db'; s1:='Client.db'; End;
     1:Begin s:=Path.ToClient+'Sklad.db'; s1:='Sklad.db'; End;
     2:Begin s:=Path.ToClient+'Barter.db';s1:='Barter.db'; End;
     Else;
     End;{CAse}
  End;

1:Begin
    Case Sel Of
     0:Begin s:=Path.ToClient+'Make.db'; s1:='Make.db'; End;
     1:Begin s:=Path.ToClient+'Sklad.db'; s1:='Sklad.db'; End;
     2:Begin s:=Path.ToClient+'Barter.db'; s1:='Barter.db'; End;
     Else;
     End;{CAse}
  End;
Else;
End;



Assign(ClientFile,s);
C:=IOResult;
Reset(ClientFile);
C:=IOResult;
If C<>0 Then
Begin
 MessageBox(^M+#3'Ошибка доступа к базе!'^M+
 #3+ClicProgrammer,nil,mfError+mfCancelButton);
 Exit;
End;


Max:=IntToSTr(FileSize(ClientFile),4);
DInfoMsg('Определяю свойства базы...');
New(BB,Init);
Emp[0]:=#0;
Pr[0]:=#0;
While Not(Eof(ClientFile)) Do
 BEgin
  ReadClient(ClientFile,BB^.Dat);
  If (BB^.DAt.Employ) Then
        Begin
         Str((StrToInt(Emp)+1):4,Emp);{занятые позиции}
         Pr:=Copy(BB^.DAt.Kod,1,CClientKod);{последний занятый код}
        End;
 End;

CLose(ClientFile);
Dispose(BB,Done);
NoInfoMsg;

1:
R.Assign(21, 7, 58, 16);
New(Dlg, Init(R, 'Свойства базы'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx := $E002;


R.Assign(9, 3, 23, 4);
Control := New(PColoredText, Init(R, 'Всего позиций:', $74));
Dlg^.Insert(Control);

R.Assign(23, 3, 35, 4);
STr(StrToInt(MAx):4,MAx);
Control := New(PColoredText, Init(R, #3+Max, $7E));
Dlg^.Insert(Control);

R.Assign(2, 2, 23, 3);
Control := New(PColoredText, Init(R, 'Используется позиций:', $74));
Dlg^.Insert(Control);

If StrToInt(MAx)>0 Then
MyStr(StrToInt(Emp)/StrToInt(Max)*100,CLitr+1,CMantissa,s)
Else s:='0.00';

R.Assign(23, 2, 35, 3);
Control := New(PColoredText, Init(R, Emp+' '+s+'%', $7E));
Dlg^.Insert(Control);

R.Assign(2, 1, 35, 2);
Control := New(PColoredText, Init(R, #3+s1, $7E));
Dlg^.Insert(Control);

R.Assign(1, 6, 36, 7);
Control := New(PStaticText, Init(R, ''));
Control^.Options := Control^.Options or ofFramed;
Dlg^.Insert(Control);


R.Assign(26, 6, 32, 7);
Control := New(PInputLine, Init(R, 4));
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['0','1','2','3','4','5','6','7','8','9']));

  R.Assign(6, 6, 26, 7);
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

        If StrToInt(Setup)>=(9999) Then
         BEgin
          Dispose(Control,Done);
          Dispose(Dlg,Done);
          MessageBox(^M+#3'Слишком большое количество элементов внутри базы! ',Nil,
          mfError+mfCAncelButton);
          Goto 1;
         End;

Dispose(Control,Done);
Dispose(Dlg,Done);


DInfoMsg('Провожу реструктуризацию '+s1+'. Ждите ...');
{MemC('Расчет');}

        If StrToInt(Setup)>StrToInt(MAx) Then{надо добавлять позиции}
        Begin
         c:=Ioresult;
         Reset(ClientFile);
         c:=Ioresult;
         If c=0 Then
         Begin
          Seek(ClientFile,StrToInt(Max));
          New(bb,Init);
          For c:=1 To (StrToInt(Setup)-StrToInt(MAx)) Do
                Begin
                 Str(C+StrToInt(MAx)-1:4,S);
                 RFormatZerro(s,4);
                 bb^.Dat.Kod:=s;
                 bb^.Dat.Employ:=False;
                 Seek(ClientFile,FileSize(ClientFile));
                 Write(ClientFile,bb^.Dat);
                End;
          Dispose(bb,Done);
          c:=Ioresult;
          Close(ClientFile);
          c:=Ioresult;
         End{If}
          Else
                Begin
                 NoInfoMsg;
                 MessageBox(^M+#3'Ошибка открытия базы!'^M+
                 #3+ClicProgrammer,Nil,mfError+mfCancelButton);
                 Exit;
                End;{Else}
     End
     Else
      Begin
         c:=Ioresult;
         Reset(ClientFile);
         c:=Ioresult;
         If c=0 Then
         Begin
         Seek(ClientFile,StrToInt(Setup));
         c:=Ioresult;
         Truncate(ClientFile);
         c:=Ioresult;
         Close(ClientFile);
         c:=Ioresult;
         End
         Else
          Begin
                NoInfoMsg;
                MessageBox(^M+#3'Ошибка открытия базы!'^M+
                #3+ClicProgrammer,Nil,mfError+mfCancelButton);
                Exit;
          End;
      End;

NoInfoMsg;

     MessageBox(^M+#3+'Реструктаризация успешно завершена!',Nil,mfInformation+mfCancelButton);
     AddProtocol('Реструктаризация базы ' +s1,'','');
  End
Else
Begin
Dispose(Control,Done);
Dispose(Dlg,Done);
End;

End;


Function SelectImportDocument(Var P:PImportSuperMarketType):Boolean;
Label 1;

Type As1 = Record
    Document : String[CDocNumer];
    Date     : TDateString;
    SkladKod : Word;
End;

var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  C : Word;
  A : As1;
  St: Array [0..7] Of String[CClient+1+1+CArtikul+1];
  s : ArtikulStr;
  As : DocumentEdit;

begin
SelectImportDocument:=False;
for c:=0 to 7 Do
 begin
  st[c,0]:=#0;
  st[c]:=GetMakeField(FMake,IntToStr(c,Cone),1);
  Format(st[c],CClient);
  s:=IntToStr(c,Cone);
  RFormatZerro(s,CClientKod);
  St[c]:=st[c]+'  ('+s+')';
 end;

A.Document[0]:=#0;
A.Date:=FDate;
A.SkladKod:=0;


1:

R.Assign(21, 5, 59, 17);
New(Dlg, Init(R, 'Импорт прихода'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx := $E002;

R.Assign(15, 1, 21, 2);
Control := New(PInputLine, Init(R, CDocNumer));
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0']));

  R.Assign(1, 1, 15, 2);
  Dlg^.Insert(New(PLabel, Init(R, 'По ~д~окументу:', Control)));


R.Assign(27, 1, 37, 2);
Control := New(PInputLine, Init(R, CDate));
{Control^.Options := Control^.Options and not ofSelectable;}
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PPXPictureValidator, Init(DAteFiltr, True));

  R.Assign(21, 1, 27, 2);
  Dlg^.Insert(New(PLabel, Init(R, 'Дата:', Control)));


R.Assign(1, 3, 37, 11);
Control := New(PRadioButtons, Init(R,
  NewSItem(st[0],
  NewSItem(st[1],
  NewSItem(st[2],
  NewSItem(st[3],
  NewSItem(st[4],
  NewSItem(st[5],
  NewSItem(st[6],
  NewSItem(st[7], Nil))))))))));
Control^.Options := Control^.Options or ofFramed;
Dlg^.Insert(Control);

  R.Assign(1, 2, 18, 3);
  Dlg^.Insert(New(PLabel, Init(R, '~С~клад поставщик:', Control)));


Dlg^.SelectNext(False);
Dlg^.SetData(A);

c:=Desktop^.ExecView(Dlg);

If c<>cmCancel Then
 Begin
  Dlg^.GetData(A);

  If A.SkladKod=0 Then
   Begin
    Dispose(Control,Done);
    Dispose(Dlg,Done);
    MessageBox(^M+#3'Нельзя делать приход от этого поставщика!',Nil,mfError+mfCancelButton);
    Goto 1;
   End;

  DelSpaceRight(A.Document);
  If A.Document[0]=#0 Then
   Begin
    Dispose(Control,Done);
    Dispose(Dlg,Done);
    MessageBox(^M+#3'Не указан номер документа отгрузки!',Nil,mfError+mfCancelButton);
    Goto 1;
   End;

  DelSpaceRight(A.Document);
  If StrToInt(A.Document)=0 Then
   Begin
    Dispose(Control,Done);
    Dispose(Dlg,Done);
    MessageBox(^M+#3'Недопустимый номер документа отгрузки!',Nil,mfError+mfCancelButton);
    Goto 1;
   End;

   As.EditPosition:=A.Document;
   As.D:=A.Date;

  If Not(GetImport(As,IntToStr(A.SkladKod,CMantissa),P)) Then
   Begin
    Dispose(Control,Done);
    Dispose(Dlg,Done);
    Goto 1;
   End;


  SelectImportDocument:=True;
 End;

Dispose(Control,Done);
Dispose(Dlg,Done);

end;


Function AddMarkerLast(Var L:PSuperMarketType) : Boolean;
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
     Str((StrToInt(DiviSionS[L^.Dat.MarketElement[i].Input.DiviSionSNumber])+
            +GetKolMarket(L^.Dat.MarketElement[i].BazKod,L^.Dat.MarketElement[i].Input.DiviSionSNumber,PrevMarket)
            -StrToInt(L^.Dat.MarketElement[i].Input.Kol))
     :CKol,DivisionS[L^.Dat.MarketElement[i].InPut.DiviSionSNumber])
     Else
     Str((StrToInt(DiviSionS[L^.Dat.MarketElement[i].Input.DiviSionSNumber])-StrToInt(L^.Dat.MarketElement[i].Input.Kol))
     :CKol,DivisionS[L^.Dat.MarketElement[i].InPut.DiviSionSNumber]);
     if StrToInt(divisionS[L^.Dat.MarketElement[i].InPut.DiviSionSNumber])<=0 Then
     L^.Dat.MarketElement[i].Input.Last:=True;
   End;
   Dispose(Sklad,Done);
End;{For}

AddMarkerLast:=True;
End;


Procedure ReadRekSF(Var Res : LongInt);
Var f : Text;
    c : Word;
Begin
Assign (f,'Sklad1.inf');
Reset(f);
Res := IOResult;
If Res <> 0 Then Exit Else Readln(f,RekSF.Kod);
Res := IOResult;
If Res <> 0 Then Exit Else Readln(f,RekSF.Name);
Res := IOResult;
If Res <> 0 Then Exit Else Readln(f,RekSF.Adress);
Res := IOResult;
If Res <> 0 Then Exit Else Readln(f,RekSF.Telefon);
Res := IOResult;
If Res <> 0 Then Exit Else Readln(f,RekSF.R_Sh);
Res := IOResult;
If Res <> 0 Then Exit Else Readln(f,RekSF.Gde);
Res := IOResult;
If Res <> 0 Then Exit Else Readln(f,RekSF.Gorod);
Res := IOResult;
If Res <> 0 Then Exit Else Readln(f,RekSF.INN);
Res := IOResult;
If Res <> 0 Then Exit Else Readln(f,RekSF.Okonh);
Res := IOResult;
If Res <> 0 Then Exit Else Readln(f,RekSF.OKPO);
Res := IOResult;
If Res <> 0 Then Exit Else Readln(f,RekSF.AdressGruza);
Res := IOResult;
If Res <> 0 Then Exit Else Readln(f,RekSF.LizensiaOptL_V);
Res := IOResult;
If Res <> 0 Then Exit Else Readln(f,RekSF.LizensiaOptSig);
Res := IOResult;

For c:=1 To 5 Do
Begin
If Res <> 0 Then Exit Else Readln(f,RekSF.LizensiaOptPiv[c]);
Res := IOResult;
End;

If Res <> 0 Then Exit Else Readln(f,RekSF.Svidetelstvo);
Res := IOResult;
If Res <> 0 Then Exit Else Readln(f,RekSF.Header);
Res := IOResult;
If Res <> 0 Then Exit Else Readln(f,RekSF.Shapka1);
Res := IOResult;
If Res <> 0 Then Exit Else Readln(f,RekSF.Shapka2);
Res := IOResult;
If Res <> 0 Then Exit Else Readln(f,RekSF.Shapka3);
Res := IOResult;
If Res <> 0 Then Exit Else Readln(f,RekSF.Otdel[1]);
Res := IOResult;
If Res <> 0 Then Exit Else Readln(f,RekSF.Otdel[2]);
Res := IOResult;
If Res <> 0 Then Exit Else Readln(f,RekSF.Otdel[3]);
Res := IOResult;
If Res <> 0 Then Exit Else Readln(f,RekSF.Otdel[4]);
Res := IOResult;
If Res <> 0 Then Exit Else Readln(f,RekSF.Otdel[5]);
Res := IOResult;
If Res <> 0 Then Exit Else Readln(f,RekSF.SkladsName);
Res := IOResult;
If Res <> 0 Then Exit;
Close (f);
Res := IOResult;
End;

Procedure WriteRekSF(Var Res : LongInt);
Var f,fbak : Text;
    c : Word;
Begin
Assign (f,'Sklad1.inf');
Rewrite(f);
Res := IOResult;
If Res <> 0 Then Exit Else writeln(f,RekSF.Kod);
Res := IOResult;
If Res <> 0 Then Exit Else writeln(f,RekSF.Name);
Res := IOResult;
If Res <> 0 Then Exit Else writeln(f,RekSF.Adress);
Res := IOResult;
If Res <> 0 Then Exit Else writeln(f,RekSF.Telefon);
Res := IOResult;
If Res <> 0 Then Exit Else writeln(f,RekSF.R_Sh);
Res := IOResult;
If Res <> 0 Then Exit Else Writeln(f,RekSF.Gde);
Res := IOResult;
If Res <> 0 Then Exit Else Writeln(f,RekSF.Gorod);
Res := IOResult;
If Res <> 0 Then Exit Else Writeln(f,RekSF.INN);
Res := IOResult;
If Res <> 0 Then Exit Else Writeln(f,RekSF.Okonh);
Res := IOResult;
If Res <> 0 Then Exit Else Writeln(f,RekSF.OKPO);
Res := IOResult;
If Res <> 0 Then Exit Else Writeln(f,RekSF.AdressGruza);
Res := IOResult;
If Res <> 0 Then Exit Else writeln(f,RekSF.LizensiaOptL_V);
Res := IOResult;
If Res <> 0 Then Exit Else writeln(f,RekSF.LizensiaOptSig);
Res := IOResult;

For c:=1 To 5 Do
Begin
If Res <> 0 Then Exit Else writeln(f,RekSF.LizensiaOptPiv[c]);
Res := IOResult;
End;

If Res <> 0 Then Exit Else writeln(f,RekSF.Svidetelstvo);
Res := IOResult;
If Res <> 0 Then Exit Else writeln(f,RekSF.Header);
Res := IOResult;
If Res <> 0 Then Exit Else writeln(f,RekSF.Shapka1);
Res := IOResult;
If Res <> 0 Then Exit Else writeln(f,RekSF.Shapka2);
Res := IOResult;
If Res <> 0 Then Exit Else writeln(f,RekSF.Shapka3);
Res := IOResult;
If Res <> 0 Then Exit Else Writeln(f,RekSF.Otdel[1]);
Res := IOResult;
If Res <> 0 Then Exit Else Writeln(f,RekSF.Otdel[2]);
Res := IOResult;
If Res <> 0 Then Exit Else Writeln(f,RekSF.Otdel[3]);
Res := IOResult;
If Res <> 0 Then Exit Else Writeln(f,RekSF.Otdel[4]);
Res := IOResult;
If Res <> 0 Then Exit Else Writeln(f,RekSF.Otdel[5]);
Res := IOResult;
If Res <> 0 Then Exit Else writeln(f,RekSF.SkladsName);
Res := IOResult;
If Res <> 0 Then Exit;
Close (f);
Res := IOResult;
End;


Procedure ChangeRekwizitiSF;
var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  C: LongInt;
begin
ClearFind;
R.Assign(0, 0, 80, 23);
New(Dlg, Init(R, 'Реквизиты предприятия 2'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.Palette := dpCyanDialog;
Dlg^.HelpCtx:=$E002;

R.Assign(14, 0, 20, 1);
Control := New(PInputLine, Init(R, 4));
If CurrentPassword<>'00' Then
Begin
Control^.Options := Control^.Options and not(ofSelectable or ofFirstClick);
Control^.EventMask := Control^.EventMask and not(evMouseDown or evKeyDown or evCommand);
End;
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0']));

  R.Assign(2, 0, 14, 1);
  Dlg^.Insert(New(PLabel, Init(R, 'Код склада:', Control)));



R.Assign(27, 1, 74, 2);
Control := New(PInputLine, Init(R, 100));
Dlg^.Insert(Control);

  R.Assign(14, 1, 27, 2);
  Dlg^.Insert(New(PLabel, Init(R, 'Пред~п~риятие:', Control)));

R.Assign(27, 2, 74, 3);
Control := New(PInputLine, Init(R, 45));
Dlg^.Insert(Control);

  R.Assign(20, 2, 27, 3);
  Dlg^.Insert(New(PLabel, Init(R, '~А~дрес:', Control)));

R.Assign(27, 3, 74, 4);
Control := New(PInputLine, Init(R, 45));
Dlg^.Insert(Control);

  R.Assign(18, 3, 27, 4);
  Dlg^.Insert(New(PLabel, Init(R, '~Т~елефон:', Control)));

R.Assign(27, 4, 74, 5);
Control := New(PInputLine, Init(R, 45));
Dlg^.Insert(Control);

  R.Assign(11, 4, 27, 5);
  Dlg^.Insert(New(PLabel, Init(R, '~Р~асчетный счет:', Control)));

R.Assign(27, 5, 74, 6);
Control := New(PInputLine, Init(R, 45));
Dlg^.Insert(Control);

  R.Assign(24, 5, 27, 6);
  Dlg^.Insert(New(PLabel, Init(R, 'в:', Control)));

R.Assign(27, 6, 74, 7);
Control := New(PInputLine, Init(R, 45));
Dlg^.Insert(Control);

  R.Assign(20, 6, 27, 7);
  Dlg^.Insert(New(PLabel, Init(R, '~Г~ород:', Control)));

R.Assign(27, 7, 74, 8);
Control := New(PInputLine, Init(R, 45));
Dlg^.Insert(Control);

  R.Assign(22, 7, 27, 8);
  Dlg^.Insert(New(PLabel, Init(R, '~И~НН:', Control)));

R.Assign(27, 8, 74, 9);
Control := New(PInputLine, Init(R, 45));
Dlg^.Insert(Control);

  R.Assign(13, 8, 27, 9);
  Dlg^.Insert(New(PLabel, Init(R, 'Ко~д~ по ОКОНХ:', Control)));

R.Assign(27, 9, 74, 10);
Control := New(PInputLine, Init(R, 45));
Dlg^.Insert(Control);

  R.Assign(14, 9, 27, 10);
  Dlg^.Insert(New(PLabel, Init(R, 'Код по ~О~КПО:', Control)));

R.Assign(27, 10, 74, 11);
Control := New(PInputLine, Init(R, 45));
Dlg^.Insert(Control);

  R.Assign(8, 10, 27, 11);
  Dlg^.Insert(New(PLabel, Init(R, 'Адрес гру~з~оотправ:', Control)));

R.Assign(27, 11, 74, 12);
Control := New(PInputLine, Init(R, 45));
Dlg^.Insert(Control);

  R.Assign(3, 11, 27, 12);
  Dlg^.Insert(New(PLabel, Init(R, 'Почтовый индекс:', Control)));

R.Assign(27, 12, 74, 13);
Control := New(PInputLine, Init(R, 45));
Dlg^.Insert(Control);

  R.Assign(2, 12, 27, 13);
  Dlg^.Insert(New(PLabel, Init(R, 'Опт.лицензия сигарет~ы~ N:', Control)));


(*
R.Assign(27, 13, 74, 14);
Control := New(PInputLine, Init(R, 45));
Dlg^.Insert(Control);

  R.Assign(3, 13, 27, 14);
  Dlg^.Insert(New(PLabel, Init(R, 'Опт.лицензия на пи~в~о N:', Control)));
*)
R.Assign(6, 13, 18, 14);
Control := New(PInputLine, Init(R, 10));
Dlg^.Insert(Control);

  R.Assign(3, 13, 6, 14);
  Dlg^.Insert(New(PLabel, Init(R, '1:', Control)));

R.Assign(21, 13, 33, 14);
Control := New(PInputLine, Init(R, 10));
Dlg^.Insert(Control);

  R.Assign(18, 13, 21, 14);
  Dlg^.Insert(New(PLabel, Init(R, '2:', Control)));

R.Assign(36, 13, 48, 14);
Control := New(PInputLine, Init(R, 10));
Dlg^.Insert(Control);

  R.Assign(33, 13, 36, 14);
  Dlg^.Insert(New(PLabel, Init(R, '3:', Control)));

R.Assign(51, 13, 63, 14);
Control := New(PInputLine, Init(R, 10));
Dlg^.Insert(Control);

  R.Assign(48, 13, 51, 14);
  Dlg^.Insert(New(PLabel, Init(R, '4:', Control)));

R.Assign(66, 13, 78, 14);
Control := New(PInputLine, Init(R, 10));
Dlg^.Insert(Control);

  R.Assign(63, 13, 66, 14);
  Dlg^.Insert(New(PLabel, Init(R, '5:', Control)));

R.Assign(27, 14, 74, 15);
Control := New(PInputLine, Init(R, 45));
Dlg^.Insert(Control);

  R.Assign(12, 14, 27, 15);
  Dlg^.Insert(New(PLabel, Init(R, 'Свидетельство:', Control)));

R.Assign(27, 15, 74, 16);
Control := New(PInputLine, Init(R, 45));
Dlg^.Insert(Control);

  R.Assign(20, 15, 27, 16);
  Dlg^.Insert(New(PLabel, Init(R, 'Девиз:', Control)));

R.Assign(27, 16, 74, 17);
Control := New(PInputLine, Init(R, 16));
Dlg^.Insert(Control);

  R.Assign(7, 16, 27, 17);
  Dlg^.Insert(New(PLabel, Init(R, 'Заголовок прайса 1:', Control)));

R.Assign(27, 17, 74, 18);
Control := New(PInputLine, Init(R, 16));
Dlg^.Insert(Control);

  R.Assign(7, 17, 27, 18);
  Dlg^.Insert(New(PLabel, Init(R, 'Заголовок прайса 2:', Control)));

R.Assign(27, 18, 74, 19);
Control := New(PInputLine, Init(R, 16));
Dlg^.Insert(Control);

  R.Assign(7, 18, 27, 19);
  Dlg^.Insert(New(PLabel, Init(R, 'Заголовок прайса 3:', Control)));



R.Assign(9, 19, 26, 20);
Control := New(PInputLine, Init(R, 15));
Dlg^.Insert(Control);

  R.Assign(6, 19, 9, 20);
  Dlg^.Insert(New(PLabel, Init(R, '~1~:', Control)));

R.Assign(9, 20, 26, 21);
Control := New(PInputLine, Init(R, 15));
Dlg^.Insert(Control);

  R.Assign(6, 20, 9, 21);
  Dlg^.Insert(New(PLabel, Init(R, '~2~:', Control)));

R.Assign(31, 19, 48, 20);
Control := New(PInputLine, Init(R, 15));
Dlg^.Insert(Control);

  R.Assign(28, 19, 31, 20);
  Dlg^.Insert(New(PLabel, Init(R, '~3~:', Control)));

R.Assign(31, 20, 48, 21);
Control := New(PInputLine, Init(R, 15));
Dlg^.Insert(Control);

  R.Assign(28, 20, 31, 21);
  Dlg^.Insert(New(PLabel, Init(R, '~4~:', Control)));

R.Assign(53, 19, 70, 20);
Control := New(PInputLine, Init(R, 15));
Dlg^.Insert(Control);

  R.Assign(50, 19, 53, 20);
  Dlg^.Insert(New(PLabel, Init(R, '~5~:', Control)));


R.Assign(53, 20, 70, 21);
Control := New(PInputLine, Init(R, 15));
Dlg^.Insert(Control);

  R.Assign(50, 20, 53, 21);
  Dlg^.Insert(New(PLabel, Init(R, '~6~:', Control)));


R.Assign(9, 21, 26, 22);
Control := New(PInputLine, Init(R, 15));
Dlg^.Insert(Control);

  R.Assign(6, 21, 9, 22);
  Dlg^.Insert(New(PLabel, Init(R, '~7~:', Control)));

R.Assign(31, 21, 48, 22);
Control := New(PInputLine, Init(R, 15));
Dlg^.Insert(Control);

  R.Assign(28, 21, 31, 22);
  Dlg^.Insert(New(PLabel, Init(R, '~8~:', Control)));




R.Assign(56, 21, 70, 22);
Control := New(PInputLine, Init(R, 12));
Dlg^.Insert(Control);

  R.Assign(49, 21, 56, 22);
  Dlg^.Insert(New(PLabel, Init(R, 'Ск~л~ад:', Control)));

Dlg^.SelectNext(False);
Dlg^.SetData(RekSF);
c:=Desktop^.ExecView(Dlg);
If c <> cmCancel Then
    Begin
     Dlg^.GetData(RekSF);
     Dispose(Control,Done);
     Dispose(Dlg,Done);
     WriteRekSF(c);
     If C<>0 Then Errors('Ошибка при записи файла реквизитов2!');
     AddProtocol('Корректировка реквизитов предприятия 2!!! {Очень важно}','','');
    End
Else
 Begin
     Dispose(Control,Done);
     Dispose(Dlg,Done);
 End;
End;


Procedure GlobalSkidkaPereezd(ClKod:ArtikulStr;Op:Word);
var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  c : Word;
  st : String[CLitr+1];
  SArt,SArt1,ws,Zena : TDateString;
  s : string[150];
  WspomList1:PBox;
  ls : Word;
  Add : Boolean;
  SZakupka : AllStr;
begin
If Not FindParam('/PEREEZD') Then Exit;
If Prodaga^.List^.Count>0 Then
Begin

  R.Assign(0,0,0,0);
  WspomlIST1 := New(PBox, Init(R, 1, Nil));
  WspomList1^.NewList(New(PTextCollection, Init(0,1)));

For ls:=0 To Prodaga^.List^.Count-1 Do
 Begin
{артикул}
 s:=Prodaga^.GetText(ls,Prodaga^.List^.Count);
 SArt:=Copy(s,1,CRazdelKod);
 SArt1:=Copy(s,1,CArtikul);

 SZakupka:=BakGetField(FZakupka,SArt1,0);
 DelSpace(SZakupka);
  Zena:=Copy(s,1+COne+1+CName+1+CArtikul+1+CLitr+1+CKol+1,CZena);
  Str(StrToReal(Zena)-StrToReal(SZakupka):CZena:CMantissa,ws);
{Удаляем старую ручную скидку}
  System.Delete(s,1+COne+1+CName+1+CArtikul+1+CLitr+1+CKol+1+CZena+1,CZena);
{Добавляем новую ручную скидку}
  System.Insert(ws,S,1+COne+1+CName+1+CArtikul+1+CLitr+1+CKol+1+CZena+1);
{вставляем исправленную строку}

  WspomList1^.List^.Insert(NewStr(s));
  WspomList1^.SetRange(WspomList1^.List^.Count);
End;{For}
{очистка Prodaga}
  Prodaga^.NewList(Nil);
  Prodaga^.NewList(New(PTextCollection, Init(0,1)));

{обновление Prodaga}
For ls:=0 To WspomList1^.List^.Count-1 Do
 Begin
{артикул}
 s:=WspomList1^.GetText(ls,WspomList1^.List^.Count);
 Prodaga^.List^.Insert(NewStr(s));
 Prodaga^.SetRange(Prodaga^.List^.Count);
End;{For}

{удаление Wspom}
Dispose(WspomList1,Done);
End;{Prodaga^.List^.Count>0}

end;

procedure AboutChm(page:string);
Begin
 DelSpace(page);
 Exec(GetEnvMy,' /C Start hh.exe ms-its:'+Path.ToOperator+'sklad.chm::page_'+
 page+'.htm');
End;


procedure About;
var
  Dlg: PDialog;
  Control: PView;
  R: TRect;
  s : AllStr;
begin
ClearFind;
R.Assign(16, 6, 64, 16);
New(Dlg, Init(R, 'О программе'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.Palette := dpBlueDialog;
Dlg^.HelpCtx := $E090;

R.Assign(1, 1, 47, 2);
{$IfDEF NetVersion}
Control := New(PColoredText, Init(R, 'Программа "Склад 2000", Версия 4.0 (сетев'+
     'ая)', $1A));
{$Else}
Control := New(PColoredText, Init(R, 'Программа "Склад 2000", Версия 4.0', $1A));
{$EndIf}
Control^.Options := Control^.Options or ofCenterX;
Dlg^.Insert(Control);

R.Assign(1, 5, 47, 6);
{$IfDEF Opt}
Control := New(PStaticText, Init(R, 'Специально для (Союзная)...'));
{$ELSE}
Control := New(PStaticText, Init(R, 'Специально для (Луначарского)...'));
{$EndIf}
Control^.Options := Control^.Options or ofCenterX;
Dlg^.Insert(Control);

R.Assign(2, 7, 46, 9);
Control := New(PStaticText, Init(R, 'Все права защищены , EYE Copyright, '+
     '1999, раб.тел. 20-66-63 '));
Control^.Options := Control^.Options or ofCenterX;
Dlg^.Insert(Control);

R.Assign(1, 2, 47, 3);
{$IfDEF Debug}
Control := New(PColoredText, Init(R, 'Срок лицензионного соглашения до:'+
'Отладка', $5F));
{$Else}
Control := New(PColoredText, Init(R, 'Срок лицензионного соглашения до:'+
GetLizensiaFromProgramm, $5F));
{$EndIf}

Dlg^.Insert(Control);

R.Assign(1, 3, 47, 4);
Control := New(PColoredText, Init(R, 'Осталось запусков: 0', $5E));
Dlg^.Insert(Control);

Dlg^.SelectNext(False);
    Desktop^.ExecView(Dlg);
    Dispose(Dlg, Done);
end;


Procedure CalcToDayOplata(ClKod:ArtikulStr; Var Sum:AllStr);
Var f : File Of OplataRealizasiaType;
    E : OplataRealizasiaType;
    c : Word;
Begin
 Sum[0]:=#0;
 Assign(f,Path.ToOplata+FDate+'.opl');
 c:=IOResult;
 Reset(f);
 c:=IOResult;
 If c<>0 Then Exit;

 While Not(Eof(f)) Do
  Begin
   Read(f,E);
   If (E.ClientKod=ClKod) And Not(E.Vozwrat) Then
    Begin
     MyStr(StrToreal(Sum)+StrToReal(E.SummaZ),CIZena,CMantissa,Sum);
    End;
  End;

 c:=IOResult;
 Close(f);
 c:=IOResult;
End;


Procedure Test_Srok(Const Spis:PBox;Const M:MaskaNew;Const Assort,Sort:Word);
Var R,R1 : TRect;
    i,l,lk : Word;
    Txt : Text;
    RazdelName,Fas,TempArtikul,s,ss : AllStr;
    ws,ws1,ws2 : string[150];
    Pack,P : String[CPack];
    Space : TEnJoyStr;
    VidProsmotra : Word; {1 - все остатки продажи,
                          0 - остатки только по продающимся позициям}
    RazdelO,RazdelR,ItogoR,ItogoO : Real;
    E : PSkladType;
    Wk : String[CKol];
    Ef : SkladFileType;
    Skidka : Boolean;
    TempList : PBox;
    WspomList: PBox;
    Regim : Word;
    Separator : ArtikulStr;
    {esbox : PBox;}
    MyWsopList : PBox;
    SInPack,MarketKol,MarketPack:string[CPack];
    SDelta,PositionZena,Date : TDateString;
    VidPoiska,Diapason,EdIzm : Word;
    Protocol : Text;
    LocalTempBox : PBox;


Begin
{ Assign(Protocol,'c:\temp.txt');
 Rewrite(Protocol);            }
 Separator:=' ';
 Assign(Txt,Path.ToTemp+'dsrok.txt');
 l:=IOResult;
 Rewrite(Txt);
 l:=IOResult;
 If L <> 0 Then
  Begin
   MessageBox(#3^M+#3'Не могу создать файл отчета '+Path.ToTemp+'dsrok.txt',Nil,mfError+mfCancelButton);
   {Dispose(Spis,Done);}
   Exit;
  End;
 Close(txt);


  R.Assign(0,0,0,0);
  TemplIST := New(PBox, Init(R, 1, Nil));
  TempList^.NewList(New(PTextCollection, Init(0,1)));
  For L:=0 To Spis^.List^.Count-1 Do
 Begin
  s:=Spis^.GetText(l,Spis^.List^.Count);
  TempList^.List^.Insert(NewStr(s));
  TempList^.SetRange(TempList^.List^.Count);
 End;
 {Dispose(Spis,Done);}

 Regim:=SelectSort;

   CAse Regim Of
   0:Begin
  R1.Assign(0,0,0,0);
  WspomlIST := New(PBox, Init(R1, 1, Nil));
  WspomList^.NewList(New(PTextCollection, Init(0,1)));
  For L:=0 To TempList^.List^.Count-1 Do
   Begin
    s:=Copy(TempList^.GetText(l,TempList^.List^.Count),1+CRazdel+1,CRazdelKod)+'│'+
       Copy(TempList^.GetText(l,TempList^.List^.Count),1,CRazdel);
    WspomList^.List^.Insert(NewStr(s));
    WspomList^.SetRange(WspomList^.List^.Count);
   End;

  TEmpList^.NewList(Nil);
  TEmpList^.NewList(New(PTextCollection, Init(0,1)));
  For L:=0 To WspomList^.List^.Count-1 Do
   Begin
    s:=WspomList^.GetText(l,WspomList^.List^.Count);
    TempList^.List^.Insert(NewStr(s));
    TempList^.SetRange(TempList^.List^.Count);
   End;
   Dispose(WspomList,Done);

     End;
   2:Begin
      Dispose(TempList,Done);
      Exit;
     End;

   Else;
   End;




 If Not(SelectDSertif(VidPoiska,Diapason)) Then
    Begin
     Dispose(TempList,Done);
     Exit;
    End;

R.Assign(0, 0, 0, 0);
LocalTempBox := New(PBox, Init(R, 1, Nil));
LocalTempBox^.NewList(New(PTextCollection, Init(0,1)));

  DInfo('Анализирую остатки...');
  Append(txt);
  Space:=' ';
  Writeln(Txt,Space+'Склад:'+FormKod(Rek.Kod)+' Оператор:'+CurrentPassword+' EYE & 1999');

  Writeln(Txt,Space+'Выбранные отделения:');
  Write(Txt,Space);
  For l:=1 To CDivision Do
  If M[l]=1 Then Write(txt,l:2,':',Rek.Otdel[l],' ');
  Writeln(Txt);
Space:='      ';
If VidPoiska=1 Then
Writeln(Txt,Space+'ТОВАРЫ, СРОК РЕАЛИЗАЦИИ КОТОРЫХ ИСТЕКАЕТ В БЛИЖАЙШИЕ '+IntToStr(Diapason,3)+' дней ')
Else
Writeln(Txt,Space+'              СРОКИ РЕАЛИЗАЦИИ ПРОДУКЦИИ');

writeln(txt,Condensed[NPrint.Printer]);
Writeln(txt,Space+'_____________________________________________________________');
Writeln(txt,Space+' Код    N  Наименование товара        Колич Годен До Дельта  ');
Writeln(txt,Space+'_____________________________________________________________');
Writeln(Txt);

 New(E,Init);

 For L:=0 To TempList^.List^.Count-1 Do
 Begin
  If Regim=0 Then s:=Copy(TempList^.GetText(l,TempList^.List^.Count),1,CRazdelKod)
  Else s:=Copy(TempList^.GetText(l,TempList^.List^.Count),1+CRazdel+1,CRazdelKod);



  If TestRazdel(s,M,0,2) Then
  Begin
      RazdelName:=GetRazdel(s);

      Assign(Ef,Path.ToSklad+s+'.db');
      Reset(Ef);

      R1.Assign(0, 0, 0, 0);
      MyWsopList := New(PBox, Init(R, 1, Nil));
      MyWsopList^.NewList(New(PTextCollection, Init(0,1)));
      While Not(Eof(ef)) Do
      Begin
       ReadSkladPointer(ef,E);
       For i:=1 To CDivision Do
        If M[i]=1 Then
       Begin
        DelSpace(E^.Dat.Input.Kol);

      If ((E^.Dat.Employ) And (StrToInt(E^.Dat.Input.DivisionS[i])>0)And(Assort=0))Or
       ((E^.Dat.Employ)And(Assort>0)And(((StrToInt(E^.Dat.Input.DivisionS[i])>0))Or(i<=1)))Then
         Begin
          If NPrint.FullName=0 Then Ws:=GetIdField(FName,E^.Dat.Bazkod)
          Else Ws:=GetIdField(FFName,E^.Dat.Bazkod);
          Format(ws,CName);
          RFormat(E^.Dat.Input.DiviSionS[i],CKol);

          Str(i:2,S);

          Str(StrToInt(E^.Dat.Input.DivisionS[i]):CKol,E^.Dat.Input.DivisionS[i]);

          Ws:=Space+E^.Dat.BazKod+Separator+Separator+s+Separator+Separator+ws+Separator+
                E^.Dat.Input.DivisionS[i]+Separator;
          ws1:=E^.DAt.Input.RealizovatDo;
          DelSpaceRight(ws1);
          Format(ws1,CDate);
          ws:=ws+ws1+Separator;

          Str(DateStringToDate(DateMask,E^.Dat.Input.RealizovatDo)-
             (DateStringToDate(DateMask,FDate)):CDate,SDelta);

          ws:=ws+SDelta+Separator;


          If (VidPoiska=0) Or
             (VidPoiska=1) And (DateStringToDate(DateMask,E^.Dat.Input.RealizovatDo)<=
                                     (DateStringToDate(DateMask,FDate)+Diapason)) Then
         Begin
          If Sort>0 Then
           Begin
            P:=Copy(ws,Ord(Space[0])+1,CArtikul+2+2);
            Delete(ws,Ord(Space[0])+1,CArtikul+2+2);
            ws:=ws+Separator+P;
           End;
          {Writeln(txt,ws);}
          MyWsopList^.List^.Insert(NewStr(ws));
          MyWsopList^.SetRange(MyWsopList^.List^.Count);
         End;
         End;
       End;{ if m[i]=1}
      End;{While}

      Close(Ef);

       If ((MyWsopList^.List^.Count-1)>=0) {And (MyWsopList^.List<>Nil)} Then
       Begin
       {печать заголовка раздела}

       Writeln(Txt,'                       Раздел: '+RazdelName);
       Writeln(Txt);

       For lk:=0 To MyWsopList^.List^.Count-1 Do
        Begin
        ws:=MyWsopList^.GetText(lk,MyWsopList^.List^.Count);
        If Sort>0 Then
         Begin
          P:=Copy(ws,Ord(ws[0])-CArtikul-2-1,CArtikul+2+2);
          Delete(ws,Ord(ws[0])-CArtikul-2-2,CArtikul+2+2+1);
          Insert(P,ws,Ord(Space[0])+1);
         End;
          Writeln(txt,ws);

     	ws1:=Copy(ws,Ord(Space[0])+1,CArtikul);
          If NPrint.FullName=0 Then Ws2:=GetIdField(FName2,ws1)
		Else Ws2:=GetIdField(FFName2,ws1);
          DelSpaceRight(ws2);

          If ws2[0]<>#0 Then
          Begin
           Format(ws2,CNAme);
           Writeln(txt,Space+'      '+Separator+Separator+'   '+ws2);
          End;


        End;
        Writeln(txt);
       End;
        {MyWsopList^.NewList(Nil);}
        Dispose(MyWsopList,Done);
        {MemC;}
   End;{TestRazdel}
 End;{for по разделам}

    Writeln(Txt,Space+'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');

Writeln(txt,Space+'========================================');

 Close(txt);
 Dispose(E,Done);

 Dispose(TempList,Done);
 Dispose(LocalTempBox,Done);
 Str(ItogoR:CIZena:CMantissa,ws);
 NoInfo;
 ViewAsText(Path.ToTemp+'dsrok.txt',True);
{ If Not(TestOpenDate(FDate)) Then}
 Report(Path.ToTemp+'dsrok.txt','',1,False,False
 ,false);
End;



Const

 koi82win: array[0..127] of byte = (
 $20, $20, $20, $20, $20, $20, $20, $20,
 $20, $20, $20, $20, $20, $20, $20, $20,
 $20, $20, $20, $20, $20, $95, $20, $20,
 $20, $20, $a0, $20, $b0, $20, $b7, $20,
 $20, $20, $20, $b8, $20, $20, $20, $20,
 $20, $20, $20, $20, $20, $20, $20, $20,
 $20, $20, $20, $a8, $20, $20, $20, $20,
 $20, $20, $20, $20, $20, $20, $20, $a9,
 $fe, $e0, $e1, $f6, $e4, $e5, $f4, $e3,
 $f5, $e8, $e9, $ea, $eb, $ec, $ed, $ee,
 $ef, $ff, $f0, $f1, $f2, $f3, $e6, $e2,
 $fc, $fb, $e7, $f8, $fd, $f9, $f7, $fa,
 $de, $c0, $c1, $d6, $c4, $c5, $d4, $c3,
 $d5, $c8, $c9, $ca, $cb, $cc, $cd, $ce,
 $cf, $df, $d0, $d1, $d2, $d3, $c6, $c2,
 $dc, $db, $c7, $d8, $dd, $d9, $d7, $da
);


alt2koi8: array[0..127] of byte = (
 $e1, $e2, $f7, $e7, $e4, $e5, $f6, $fa,
 $e9, $ea, $eb, $ec, $ed, $ee, $ef, $f0,
 $f2, $f3, $f4, $f5, $e6, $e8, $e3, $fe,
 $fb, $fd, $ff, $f9, $f8, $fc, $e0, $f1,
 $c1, $c2, $d7, $c7, $c4, $c5, $d6, $da,
 $c9, $ca, $cb, $cc, $cd, $ce, $cf, $d0,
 $90, $91, $92, $81, $87, $b2, $b4, $a7,
 $a6, $b5, $a1, $a8, $ae, $ad, $ac, $83,
 $84, $89, $88, $86, $80, $8a, $af, $b0,
 $ab, $a5, $bb, $b8, $b1, $a0, $be, $b9,
 $ba, $b6, $b7, $aa, $a9, $a2, $a4, $bd,
 $bc, $85, $82, $8d, $8c, $8e, $8f, $8b,
 $d2, $d3, $d4, $d5, $c6, $c8, $c3, $de,
 $db, $dd, $df, $d9, $d8, $dc, $c0, $d1,
 $b3, $a3, $99, $98, $93, $9b, $9f, $97,
 $9c, $95, $9e, $96, $bf, $9d, $94, $9a
);


function DosToWin(s:string):string;

Const Digits=['0','1','2','3','4','5','6','7','8','9'];
var i: byte;
begin
  for i:=1 to word(s[0]) do
    begin
       If s[i]=SeparatorChar Then s[i]:=';';

       IF Ord(s[i]) > 127 then
       begin
         s[i] := Chr(alt2Koi8[Ord(s[i])-128]);
         s[i] := Chr(Koi82Win[Ord(s[i])-128]);
       end;



       If i>1 Then
        Begin
         If s[i]='.' Then
          If s[i-1] in Digits Then s[i]:=',';
        End;

    end;
  DosToWin:=s;
end;




End.
