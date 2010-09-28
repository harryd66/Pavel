{$I Compile.INC}

{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}
Unit ServStr;

Interface


Const


  CMantissa  = 2;
  CMantissaZ = 4;
  CPunkt =4;
  CLitrMantissa  = 3;
  CDivision  = 8;{5}
  CMax       = 55;
  COne       = 1;
  CLitr      = 5;
  CAll       = 45;
  CKto       = 12;
  CPack      = 9;
  CZena      = 8;
  CArtikul   = 5;
  CDocNumer  = 4;
  CSertif    = 64{78};
  CAkzis     = 64;
  CAkzis1    = 30;
  CKol       = 5;
  CInPack    = 3;
  CKod       = 3;
  CClientKod = 4;
  CRazdelKod = 2;
  CMakeKod   = 4;
  CName      = 26;
  CNSertif   = 40;
  CDSertif   = 8;
  CKSertif   = 40;
  CIZena     = 15;
  CPost      = 15;{!}
  CILitr     = 12;
  CDate      = 8;
  CClient    = 20;{!}
  CMake      = 20;{!}
  CRazdel    = 20;{!}
  CInputIZena= 13;
  CInputILitr= 10;
  CMaxZena   = 99999.99;
  CMaxKol    = 99999;
  CShkala    = 24;
  CMAxRoles = 100;
  CVol = 6;

  FName=1;
  FFName=2;
  FPost=3;
  FDiv=4;
  FKol=5;
  FLitr=6;
  FInPack=7;
  FAkzis=8;
  FSertif=9;
  FNDS=10;
  FRZena=11;
  FOZena=12;
  FDates=13;
  FTimes=14;
  FOperator=15;
  FMake=16;
  FKMake=17;
  FStatus=18;
  FLock =19;
  FVidNalog=20;
  FNAlog=21;
  FVidNDS=22;
  FMera=23;
  FZakupka=24;

  FClient=25;
  FAdress=26;
  FEnvir=27;
  FINN =28;
  FOkonh =29;
  FOkpo=30;
  FRSh=31;
  FGde=32;
  FGorod=33;
  FLimit=34;
  FNDogovor=35;
  FPunkt=36;
  FDolg=37;
  FKod=38;
  FTelefon=39;
  FSrok = 40;
  FDebit=41;
  FMessages=42;
  FDateSertif=43;
  FKtoSertif=44;
  FShkala =45;
  FAgent = 46;

  FSrokLock = 47;

  FName2   = 57;
  FFNAme2  = 58;
  FFFName=63;
  FMArker = 64;
  FMinimum = 65;
  FMinNazenka = 66;
  FCProz=67;
  FEnableOtdel = 68;
  FGroup = 69;
  FNGroupKod = 69;
  FRegion = 70;
  FRealiz =71;
  FDateOsn = 72;
  FNaklOsn = 73;
  FOtdel = 74;
  FNoLimit = 75;
  FAgKod = 76;
  FVol = 77;

  FPunkt1 = 78;
  FPunkt2 = 79;
  FProz = 80;
  FMarsh = 81;

  FAgSamKod = 82;
  FAgVenKod = 83;
  FMaska = 84;

Const
    DelTovar=^M+#3'Удалить товар из накладной?';
    DelRazdel=^M+#3'Желаете удалить раздел?';
    DelOperator=^M+#3'Желаете удалить оператора?';
    DelBazName=^M+#3'Желаете удалить наименование из базы?';
    MsgErrorRazdelDel=^M+#3'Раздел не может быть удален'^M+#3'пока он содержит подэлементы!';
    Zapret=^M+#3'Эта операция запрещена!';
    DelAll=^M+#3'Удалить всю накладную?';
    NoClient=^M+#3'Не указан покупатель !';
    NoMake=^M+#3'Не указан поставщик !';
    NoSertif=^M+#3'Не введен N сертификата !';
    NoAkzis=^M+#3'Не указано примечание!';
    NoNds=^M+#3'Не указана ставка НДС!';
    NoNalog=^M+#3'Не указана ставка спец.налога!';
    ErrorNds=^M+#3'Не правильно указана ставка НДС!';
    ErrorNAlog=^M+#3'Не правильно указана ставка спец.налога!';
    NullKol=^M+#3'Введено нулевое количество товара!';
    ErrorZakupka=^M+#3'Неправильно введена закупочная цена'^M+'Повторите ввод !';
    ErrorRZena=^M+#3'Неправильно введена розничная цена'^M+'Повторите ввод !';
    ErrorOZena=^M+#3'Неправильно введена оптовая цена'^M+'Повторите ввод !';
    NoInput=#3'Ввод информации невозможнен !';
    ErrorClientFile=^M+#3'Ошибка доступа к файлу клиентов!';
    ErrorMakeFile=^M+#3'Ошибка доступа к файлу поставшиков!';
    ErrorRazdelFile=^M+#3'Ошибка доступа к файлу разделов !';
    ErrorOperatorFile=^M+#3'Ошибка доступа к файлу реестра!';
    NewElement='~+~ Новый';
    Find='~А..Я~ Поиск';
    Enter='~'+#17+#217+'~ Дальше';
    Vibor='~'+#17+#217+'~ Выбор';
    Edit='~F4~ Правка';
    Uprawlenie='~'+#27+#26+#24+#25+'~ Управление';
    Ok='~^'+#17+#217+'~ ОК';
    Ok1='~'+#17+#217+'~ ОК';
    Ok2='~'+#17+#217+'~ Ввести приход на склад';
    Cancel = '~Esc~ Отмена';
    Cancel2 = '~Esc~ Отказаться от ввода прихода на склад';
    Menu   = '~F10~ Меню';
    Vopros = '~'+#17+#217+'~ Закрыть документ';
    ClicProgrammer=' Ничего не трогай и позови программиста!';



Type TMyString = String[230];
     TEnjoyStr = TMyString;{String[CSertif];}
     AllStr = String[CALL];
     StrName = String [CName];
     SertifStr = String [CSertif];
     ArtikulStr = String[CArtikul];
     TDateString = String[CDate];
     Float = double;{тип с плавующей точкой}

Type NalogType=Record
      ENalog  : String[CIZena];
      Nalog5  : String[CIZena];
      Nalog3  : String[CIZena];
      Nalog_  : String[CIZena];
      Zakupka : String[CIZena]
     End;




Function FindParam(s:String):Boolean;
Procedure DelSpace (Var S : String);
Procedure DelZerro (Var S : String);
Function DelPunkt( Fi : String ):String;
Procedure RFormat(Var St : TEnjoyStr; Max : Byte);
Function Format(Var St : TEnjoyStr; Max : Byte):TEnjoyStr;
Function ClearChar(Var S : TDateString):TDateString;
Function SClearChar(S : AllStr):AllStr;
Function StrToInt(S:AllStr) : LongInt;
Function IntToStr(K:LongInt;Form:Integer) : AllStr;
Function RealToStr(K:Real;Form1,Form2:Integer) : AllStr;
Function StrToReal(S:AllStr) : Real;
function uppercase(c:Char):Char;
function upcases(stri:TEnjoyStr):TEnjoyStr;
Procedure UpStr(Var S: TEnjoyStr);
Procedure DelSpaceRight (Var S : TEnjoyStr);
Procedure DelSpaceLeftRight (Var S : TEnjoyStr);
Procedure DelSp(Var s :TEnjoyStr);
Procedure GetFileName( Y,M,D : Word; Var F:String);
Procedure Del2Space (Var S : String);
Function FormKod(s:ArtikulStr):ArtikulStr;
Procedure SpecialFormat(Var s,ws1,ws2 : TMyString);
Procedure RFormatZerro(Var St : TEnjoyStr; Max : Byte);
function Lowcase(c:Char):Char;
function Locases(stri:TEnjoyStr):TEnjoyStr;
Procedure Pause(L:Word);
Function MakeLine ( Fi : String ):String;
Procedure MyStr(S:Extended;A,B:Byte;Var As : String);

{
Procedure   ChrPadL(Var Str: String;Fill: Char;MaxLen: Integer);
Procedure   ChrPadR(Var Str: String;Fill: Char;MaxLen: Integer);
}
Procedure Sound ( Hz : word );
Procedure NoSound;
procedure Delay(Tics : LongInt);


Var
     FindStrok  : String[CAll];
     FindSymbol : Byte;
     FindLogik  : Byte;
     User: array[0..CMaxRoles] of boolean;

Implementation

Uses WinDos;

type
  {For calculating timeouts}
    TEventTimer = record
      StartTics : LongInt;
      ExpireTics : LongInt;
    end;



Const
  TicsFreq = 1675;
  SecsFreq = 92;
  TicsPerDay = 1573040;      {Assumes 18.20648 tics/sec}



var
  BiosTics : LongInt absolute $40:$6C;




Procedure   FastMove;Assembler;
Asm
   cmp   si,di
   jb    @@01
   cld
   shr   cx,1
   jnb   @@03
   movsb
   jmp   @@03
@@01:
   std
   add   si,cx
   dec   si
   add   di,cx
   dec   di
   shr   cx,1
   jnb   @@02
   movsb
@@02:
   dec   si
   dec   di
@@03:
   repne movsw
end;


Procedure   ChrPadC(Var Str: String;Fill: Char;MaxLen: Integer);Assembler;
Asm
   les   di,Str
   mov   si,di
   mov   dx,MaxLen
   or    dx,dx
   jz    @@08
   sub   cx,cx
   mov   cl,es:[di]
   cmp   cx,dx
   jae   @@08
   mov   es:[di],dl
   push  di
   sub   dx,cx
   mov   bx,dx
   shr   bx,1
   sub   dx,bx
   add   di,cx
   add   si,dx
   add   si,cx
   or    cx,cx
   jnz   @@01
   mov   bx,MaxLen
   jmp   @@03
@@01:
   push  si
@@02:
   mov   al,es:[di]
   mov   es:[si],al
   dec   di
   dec   si
   loop  @@02
   pop   si
@@03:
   mov   al,Fill
   mov   cx,bx
   jcxz  @@05
@@04:
   inc   si
   mov   es:[si],al
   loop  @@04
@@05:
   pop   di
   mov   cx,dx
   jcxz  @@08
   inc   di
@@06:
   cld
   shr   cx,1
   jnb   @@07
   stosb
@@07:
   mov   ah,al
   rep   stosw
@@08:
end;

Function    ChrPadC_  (Str: String;Fill: Char;MaxLen: Integer):String;Assembler;
Asm
   push  ds
   lds   si,Str
   mov   cl,[si]
   xor   ch,ch
   inc   cx
   les   di,@Result
   push  cs
   call  near ptr FastMove
   les   di,@Result
   push  es
   push  di
   mov   al,Fill
   push  ax
   push  Maxlen
   push  cs
   call  near ptr ChrPadC
   pop   ds
end;

Procedure   ChrPadL(Var Str: String;Fill: Char;MaxLen: Integer);Assembler;
Asm
   push  ds
   les   di,Str
   push  es
   pop   ds
   xor   ch,ch
   mov   cl,es:[di]
   mov   bx,MaxLen
   cmp   cl,bl
   jae   @@04
   mov   es:[di],bl
   mov   si,di
   add   si,cx
   add   di,bx
   sub   bx,cx
   std
   inc  cx
   shr   cx,1
   jnb   @@01
   movsb
@@01:
   rep   movsw
   mov   cx,bx
   mov   al,Fill
   mov   ah,al
   les   di,Str
   inc   di
   cld
   shr   cx,1
   jnb   @@03
   stosb
@@03:
   rep   stosw
@@04:
   pop   ds
End;

Function    ChrPadL_  (Str: String;Fill: Char;MaxLen: Integer):String;Assembler;
Asm
   push  ds
   lds   si,Str
   mov   cl,[si]
   xor   ch,ch
   inc   cx
   les   di,@Result
   push  cs
   call  near ptr FastMove
   les   di,@Result
   push  es
   push  di
   mov   al,Fill
   push  ax
   push  Maxlen
   push  cs
   call  near ptr ChrPadL
   pop   ds
end;

Procedure   ChrPadR(Var Str: String;Fill: Char;MaxLen: Integer);Assembler;
Asm
   les   di,Str
   xor   cx,cx
   mov   cl,es:[di]
   mov   bx,MaxLen
   cmp   cl,bl
   jae   @@03
   mov   es:[di],bl
   add   di,cx
   sub   bx,cx
   mov   cx,bx
   mov   al,Fill
   mov   ah,al
   cld
   inc  di
@@01:
   shr   cx,1
   jnb   @@02
   stosb
@@02:
   rep   stosw
@@03:
End;

Function    ChrPadR_(Str: String;Fill: Char;MaxLen: Integer):String;Assembler;
Asm
   push  ds
   lds   si,Str
   mov   cl,[si]
   xor   ch,ch
   inc   cx
   les   di,@Result
   push  cs
   call  near ptr FastMove
   les   di,@Result
   push  es
   push  di
   mov   al,Fill
   push  ax
   push  Maxlen
   push  cs
   call  near ptr ChrPadR
   pop   ds
end;







function uppercase(c:Char):Char; assembler;
asm
 mov al,c
 mov ah,al
 sub ah,32
 cmp al,97   {1}
 jc  @@1

 cmp al,123  {2}
 jc  @@2

 cmp al,160  {3}
 jc  @@1

 cmp al,176  {4}
 jc  @@2
 sub ah,48

 cmp al,224  {5}
 jc  @@1;

 cmp al,240  {6}
 jnc @@1
@@2: mov al,ah
@@1:         end;


function Lowcase(c:Char):Char; assembler;
asm
 mov al,c
 mov ah,al
 add ah,32

 cmp al,65 {проверяем прописная ли это английская буква}
 jc  @@1   {если нет то выходим}

 cmp al,91 {проверяем строчная ли это английская буква}
 jc  @@2   {если да то меняем}

 cmp al,128
 jc  @@1

 cmp al,144
 jc  @@2

 add ah,48
 cmp al,224
 jc  @@1;

 add ah,48
 cmp al,240
 jc  @@1;

 cmp al,255
 jnc @@2
@@2: mov al,ah
@@1:
end;

{
 add ah,80
 cmp al,224
 jc  @@1;
 cmp al,240
 jnc @@1
@@2: mov al,ah
@@1:
}

{
function upcases(stri:TEnjoyStr):TEnjoyStr; assembler;
asm
 push DS
 LES DI,@Result
 LDS Si,stri
 CLD
 LODSB
 STOSB
 mov cx,ax
 xor ch,ch
@@1: lodsb
     push ax
     push cs
     Call near PTR UpperCase
     Stosb
     LOOP @@1
     POP  DS
end;
}

function upcases(stri:TEnjoyStr):TEnjoyStr;
Var i: Byte;
Begin
 UpCases[0]:=#0;
 If Ord(Stri[0])>0 Then
 Begin
 For I:=1 To Ord(Stri[0]) Do
 UpCases[i]:=UpperCase(Stri[i]);
 UpCases[0]:=Chr(i);
 End;
End;

function Locases(stri:TEnjoyStr):TEnjoyStr;
Var i: Byte;
Begin
 LoCases[0]:=#0;
 If Ord(Stri[0])>0 Then
 Begin
 For I:=1 To Ord(Stri[0]) Do
 LoCases[i]:=LowCase(Stri[i]);
 LoCases[0]:=Chr(i);
 End;
End;

Procedure UpStr(Var S: TEnjoyStr);
Begin
S:=UpCases(s);
End;

Procedure LoStr(Var S: TEnjoyStr);
Begin
S:=LoCases(s);
End;

Procedure DelZerro (Var S : String);
 Var i,j : Integer;
Begin
i := Pos('0',s);
 While i=1 Do
  Begin
   Delete(s,i,1);
   i := Pos('0',s);
  End;
End;




Function ClearChar(Var S : TDateString):TDateString;
Var i,j : Byte;
    ss : TDateString;
Begin
DelZerro(s);
j:=1;
ss[0]:=#0;
For i := 1 To Ord(S[0]) Do
 If s[i] in ['1','2','3','4','5','6','7','8','9','0'] Then
  Begin
   ss[j]:=s[i];
   ss[0]:=Chr(j);
   Inc(j);
  End;
s:=ss;
ClearChar:=ss;
End;

Function SClearChar(S : AllStr):AllStr;
Var i,j : Byte;
    ss : AllStr;
Begin
DelZerro(s);
j:=1;
ss[0]:=#0;
For i := 1 To Ord(S[0]) Do
 If s[i] in ['1','2','3','4','5','6','7','8','9','0','-','+','.','(',')',#13,#3] Then
  Begin
   ss[j]:=s[i];
   ss[0]:=Chr(j);
   Inc(j);
  End;
SClearChar:=ss;
End;

Function StrToInt(S:AllStr) : LongInt;
Var Code : Integer;
    K : LongInt;
Begin
 k:=0;
 DelSpace(S);
 Val(S,K,Code);
 If Code = 0 Then
 StrToInt:=k
 Else StrToInt:=0;
End;

Procedure Del2Space (Var S : String);
Var ls:Byte;
Begin
 Repeat
 ls:=Pos('  ',S);
 If Ls>0 Then  Delete(s,ls,1);
 Until ls=0;
End;

Function IntToStr(K:LongInt;Form:Integer) : AllStr;
Var s : AllStr;
Begin
 Str(K:Form,S);
 DelSpace(S);
 IntToStr:=s;
End;

Function RealToStr(K:Real;Form1,Form2:Integer) : AllStr;
Var s : AllStr;
Begin
 Str(K:Form1:Form2,S);
 RealToStr:=s;
End;


Function StrToReal(S:AllStr) : Real;
Var Code : Integer;
    K : Real;
Begin
 k:=0;
 DelSpace(S);
 Val(S,K,Code);
 If Code = 0 Then
 StrToReal:=k
 Else StrToReal:=0;
End;


Procedure DelSpace (Var S : String);
 Var i,j : Integer;
Begin
i := Pos(' ',s);
 While i>0 Do
  Begin
   Delete(s,i,1);
   i := Pos(' ',s);
  End;
End;


Function DelPunkt( Fi : String ):String;
Var i,j : Byte;

Begin
 i := Length(Fi);
 For j:= 1 To I Do
 If Fi[j] In['.','/','\'] Then Fi[j]:='-';
 DelPunkt:=Fi;
End;

Function MakeLine ( Fi : String ):String;
Var i,j : Byte;

Begin
 i := Length(Fi);
 For j:= 1 To I Do
 Begin
  If Fi[j]='-' Then Fi[j]:='─';
  If Fi[j]='|' Then Fi[j]:='│';
 End;
 MakeLine:=Fi;
End;


Function Format(Var St : TEnjoyStr; Max : Byte):TEnjoyStr;
Var x,i : Byte;

Begin
 x := Ord(St[0]);
 If (X) > (Max) Then
 Begin
  St[0]:= Chr(Max-1);
  St[max] := '.';
  St[0] :=Chr(Max);
 End;
 If (X) < (Max) Then
        Begin
         For i := (x+1) To (Max) Do
         Begin
          St[i] := ' ';
          St[0] :=Chr(i);
         End;
        End;

{
ChrPadR(st,' ',Max);}
Format:=St;
End;


Procedure RFormat(Var St : TEnjoyStr; Max : Byte);
Var x,i : Byte;

Begin
 DelSpace(St);

x := Ord(St[0]);
While Ord(st[0]) < Max Do Insert(' ',St,1);

{
ChrPadl(st,' ',Max);}
End;

Procedure RFormatZerro(Var St : TEnjoyStr; Max : Byte);
Var x,i : Byte;

Begin
 DelSpace(St);

 x := Ord(St[0]);
While Ord(st[0]) < Max Do Insert('0',St,1);


End;

Procedure DelSpaceRight (Var S : TEnjoyStr);

 Var i : Integer;
Begin
i := Ord(S[0]);
Repeat
 If s[i]=' ' Then
 Begin
  s[0]:=Chr(i-1);
  Dec(i);
 End;
Until (s[i]<>' ') or (i=0);
End;

Procedure DelSpaceLeftRight (Var S : TEnjoyStr);
 Var i : Integer;
Begin
While Pos(' ',s)=1 Do
 Delete(s,1,1);
 DelSpaceRight(s);
End;

Procedure DelSp(Var s : TEnjoyStr);
 Var i, j : Byte;
Begin
If Ord(s[0]) <> 0 Then
 Begin
  j:=Ord(S[0]);
  For i:=1 to j Do
    If S[i]=' ' Then S[i]:='0';
 End;
End;


Procedure GetFileName( Y,M,D : Word; Var F:String);
Var s1,s2,s3:String[2];
Begin
 Str(D:2,S1);
 Str(M:2,S2);
 Str(Y:2,S3);
 F:=s1+'-'+s2+'-'+s3;
 Delsp(F);
End;

Function FormKod(s:ArtikulStr):ArtikulStr;
Var i : Byte;
Begin
While Pos(' ',S)>0 Do  s[Pos(' ',s)]:='0';
FormKod:=s;
End;


Procedure SpecialFormat(Var s,ws1,ws2 : TMyString);
Var b,bb: Byte;

Begin
 b:=Ord(s[0]);
 ws1[0]:=#0;
 ws2[0]:=#0;
 ws1:=Copy(s,1,41);
 bb:=Ord(ws1[0]);
 While ws1[bb]<>' ' Do Dec(bb);
 ws1[0]:=Chr(bb);
 ws2:=Copy(s,bb+1,41);
 bb:=Ord(ws2[0]);
 If {Pos(' ',ws2)>0}(bb+1+Ord(ws1[0]))<b Then
 Begin
 While ws2[bb]<>' ' Do Dec(bb);
 ws2[0]:=Chr(bb);
 End;
 s:=Copy(s,Ord(ws1[0])+Ord(ws2[0])+1,Ord(s[0]));
End;

Procedure MyStr(S:Extended;A,B:Byte;Var As : String);
Var R : Extended;
    Res : LongInt;
    Res1 : Extended;
    s1 : String;
    m : Extended;
Begin
 If s>=0 Then
 Begin
 Case b Of
 0 :r:=10;
 1 :r:=10;
 2 :r:=100;
 3 :r:=1000;
 4 :r:=10000;
 5 :r:=100000;
 6 :R:=1000000;
 7 :R:=10000000;
 8 :R:=100000000;
 9 :R:=1000000000;
 {
 10:R:=10000000000;
 11:R:=100000000000;
 12:R:=1000000000000;
 13:R:=10000000000000;
 14:R:=100000000000000;
 15:R:=1000000000000000;}
 Else
   R:=1e19;
 End;
 End
 Else Begin

 Case b Of
 0 :r:=-10;
 1 :r:=-10;
 2 :r:=-100;
 3 :r:=-1000;
 4 :r:=-10000;
 5 :r:=-100000;
 6 :R:=-1000000;
 7 :R:=-10000000;
 8 :R:=-100000000;
 9 :R:=-1000000000;
{
 10:R:=-10000000000;
 11:R:=-100000000000;
 12:R:=-1000000000000;
 13:R:=-10000000000000;
 14:R:=-100000000000000;
 15:R:=-1000000000000000;}
 Else
   R:=-1e19;
 End;
 End;

 S:=S*r;
 m:=Frac(s);
 If Frac(s)>=0.495 Then
                       S:=S+0.005;
 Res1:=s/R;
 Str(Res1:A:B,S1);
 If A>B Then
 s1[0]:=Chr(A)
 Else
 s1[0]:=Chr(B);
 as:=s1{Real2Str(s,A,B)};
End;




Procedure Sound ( Hz : word );assembler;
asm
        mov     ax,Hz
        cmp     ax,21
        jbe     @@2
        mov     bx,ax
        in      al,061h
        test    al,03
        jnz     @@1
        or      al,03
        out     061h,al
        mov     al,0B6h
        out     043h,al
@@1:    mov     ax,04F38h  {  divider = 144f38h / Hz  }
        mov     dx,014h
        div     bx
        out     042h,al
        mov     al,ah
        out     042h,al
@@2:
end;



Procedure Nosound ;assembler;
asm
        in      al,061h
        and     al,11111100b
        out     061h,al
end;


procedure NewTimer(var ET : TEventTimer; Tics : LongInt);
  {-Returns a set EventTimer that will expire in Tics}
begin
  {Max acceptable value is 24 hours}
  if Tics > TicsPerDay then
    Tics := TicsPerDay;

  with ET do begin
    StartTics := BiosTics;
    ExpireTics := StartTics + Tics;
  end;
end;


function TimerExpired(ET : TEventTimer) : Boolean;
  {-Returns True if ET has expired}
var
  CurTics : LongInt;
begin
  with ET do begin
    {Get current tics; assume timer has expired}
    CurTics := BiosTics;
    TimerExpired := True;

    {Check normal expiration}
    if CurTics > ExpireTics then
      Exit;
    {Check wrapped CurTics}
    if (CurTics < StartTics) and ((CurTics + TicsPerDay) > ExpireTics) then
      Exit;
    {If we get here, timer hasn't expired yet}
    TimerExpired := False;
  end;
end;



procedure Delay(Tics : LongInt);
  {-Delay for Tics tics}
var
  ET : TEventTimer;
begin
  Tics:=Round(Tics/100);
  if Tics <= 0 then
    Exit
  else if Tics > TicsPerDay then
    Tics := TicsPerDay;

  NewTimer(ET, Tics);
  repeat
  until TimerExpired(ET);
end;


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



Procedure Pause(L:Word);
Begin
Doserror:=0;
{$IFDEF NetVersion}
Delay(L);
{$ENDIF}
End;



End.