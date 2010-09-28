{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}
{$I Compile.INC}

Unit Pereozen;

Interface


Uses Dialogs,Drivers,Glob,Access,MyCAlc;

Type
  PCartPrzWindow = ^TCartPrzWindow;
  TCartPrzWindow = object(TDialog)
  Calc        : PMyCalculator;
    Procedure Ini(Var s:String;Regim : Byte);
    procedure HandleEvent(var Event: TEvent); virtual;
    Destructor Done;Virtual;
  end;


Type
  PPrzWindow = ^TPrzWindow;
  TPrzWindow = object(TDialog)
    Rz  : PRazdelWindow;
    Car : PCartPrzWindow;
    Nam : PNameWindow;
    constructor Init(Var l: Boolean);
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure AddName;
    procedure DrawFullNAme;
    procedure UnlockAllName;
    procedure OpenPrzWindow;
    procedure CalcItogo;
    procedure SaveToFile(Var Save : Boolean);
  end;


 Implementation

uses Objects, Views, MsgBox,Vision2,DbEngine,Protect,WinDos,UtilsP,
     App, ColorTxt,Serv,InpLong,Validate{,CPrihod},ServStr,net,NetDbEng,NetCall;

Type Zena = Array [1..2] Of String[CZena];

Type LockCorrectType = Record
     New_R_Zena,New_O_Zena:String[CZena];
     AutoSkid : Array[1..CShkala] Of String[CZena];
     End;




var
 ControlCurrent,ControlNew_O_Zena,ControlNew_R_Zena,ControlBak_R_Zena,
 ControlBak_O_Zena,ControlRazdel,ControlFullNAme,
 ControlItogo_O_Zena,ControlItogo_R_Zena,ControlDocNum,ControlR,ControlO : PView;
 CartWin : PCartPrzWindow;
 ControlShkala,ControlProz : Array [1..CShkala] Of PView;
 PrevName : String;
 PrzWindow : PPrzWindow;
 PrevS : String;
 SArtikul : String[CArtikul];
 PrzFile : File Of PereozenkaType;
 LCorrect: LockCorrectType;
 SZakupka : AllStr;
 SProz : Array [1..CShkala] Of String[CLitr+1];



Procedure DrawProz;
Var s: String[CPack];
    R : TRect;
    Color : Word;
    i : Byte;
Begin
    CartWin^.GetData(LCorrect);

    For i:=0 To 11 Do
    Begin
    Color:=$3E;
    If Abs(StrToReal(LCorrect.AutoSkid[i+1]))<0.01 Then
     Begin
      {SProz[i+1]:='1.0000';}
     End
    Else
    MyStr(StrToReal(LCorrect.AutoSkid[i+1])/(StrToReal(LCorrect.New_R_Zena)),CLitr+1,CMantissa+2,SProz[i+1]);

    Dispose(ControlProz[i+1],Done);
    R.Assign(70-40, 9+i+1, 75-40+1, 10+i+1);
    If StrToReal(LCorrect.AutoSkid[i+1])<StrToReal(SZakupka)Then Color:= $CF;

    If StrToReal(LCorrect.AutoSkid[i+1]) < (StrToReal(SZakupka)*(1+StrToReal(GetMinNazenka(SArtikul,I+1))/100))
    Then Color:=$AE;


    ControlProz[i+1] := New(PColoredText, Init(R, #3+SProz[i+1], Color));
    CartWin^.Insert(ControlProz[i+1]);
    End;


    For i:=12 To 23 Do
    Begin
    Color:=$3E;
    If Abs(StrToReal(LCorrect.AutoSkid[i+1]))<0.01 Then
     Begin
      {SProz[i+1]:='1.0000';}
     End
    Else
    MyStr(StrToReal(LCorrect.AutoSkid[i+1])/(StrToReal(LCorrect.New_R_Zena)),CLitr+1,CMantissa+2,SProz[i+1]);

    Dispose(ControlProz[i+1],Done);

    R.Assign(60+5+1, 9+(i-11), 70+2, 10+(i-11));

    If StrToReal(LCorrect.AutoSkid[i+1])<StrToReal(SZakupka)Then Color:= $CF;

    If StrToReal(LCorrect.AutoSkid[i+1]) < (StrToReal(SZakupka)*(1+StrToReal(GetMinNazenka(SArtikul,I+1))/100))
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
    CartWin^.GetData(LCorrect);
    For i:=0 To 11 Do
    Begin
    MyStr((StrToReal(LCorrect.New_R_Zena)*
       (StrToReal(SProz[i+1]))),CZena,CMantissa,LCorrect.AutoSkid[i+1]);
    DelSpace(LCorrect.AutoSkid[i+1]);
    ControlShkala[i+1]^.SetDAta(LCorrect.AutoSkid[i+1]);
    Color:=$3E;
    If StrToReal(LCorrect.AutoSkid[i+1]) < StrToReal(SZakupka) Then Color:=$CF;

    If StrToReal(LCorrect.AutoSkid[i+1]) < (StrToReal(SZakupka)*(1+StrToReal(GetMinNazenka(SArtikul,I+1))/100))
    Then Color:=$AE;


      Dispose(ControlProz[i+1],Done);
       R.Assign(70-40, 9+i+1, 75-40+1, 10+i+1);
      ControlProz[i+1] := New(PColoredText, Init(R, #3+SProz[i+1], Color));
      CartWin^.Insert(ControlProz[i+1]);
    End;

    For i:=12 To 23 Do
    Begin
    MyStr((StrToReal(LCorrect.New_R_Zena)*
       (StrToReal(SProz[i+1]))),CZena,CMantissa,LCorrect.AutoSkid[i+1]);
    DelSpace(LCorrect.AutoSkid[i+1]);
    ControlShkala[i+1]^.SetDAta(LCorrect.AutoSkid[i+1]);
    Color:=$3E;
    If StrToReal(LCorrect.AutoSkid[i+1]) < StrToReal(SZakupka) Then Color:=$CF;

    If StrToReal(LCorrect.AutoSkid[i+1]) < (StrToReal(SZakupka)*(1+StrToReal(GetMinNazenka(SArtikul,I+1))/100))
    Then Color:=$AE;

      Dispose(ControlProz[i+1],Done);
      R.Assign(60+5+1, 9+(i-11), 70+2, 10+(i-11));
      ControlProz[i+1] := New(PColoredText, Init(R, #3+SProz[i+1], Color));
      CartWin^.Insert(ControlProz[i+1]);
    End;
End;





Procedure TCartPrzWindow.Ini(Var s:String;Regim : Byte);
Label 1;
var
  R : TRect;
  c: Word;
  Control : PView;
  SName,SName2,SLitr,SKol,SOZena,SRZena,SInPack: String[CAll];
  Sk : PSkidkaType;
  Shk : Array [1..CShkala] Of String[CIZena];


Begin
ClearFind;
SName:=Copy(S,1,CName);
SArtikul:=Copy(S,1+CName+1,CArtikul);
SLitr:=GetIdField(FLitr,SArtikul);
SInPack:=GetIdField(FINPack,SArtikul);
SKol:=BakGetField(FKol,SArtikul,0);
SRZena:=BakGetField(FRZena,SArtikul,0);
SZakupka:=BakGetField(FZakupka,SArtikul,0);
SOZena:=BakGetField(FOZena,SArtikul,0);

SName2:=GetIdField(FName2,SArtikul);
DelSpaceRight(SNAme2);


Case Regim Of
0:Begin
  LCorrect.New_R_Zena:=BakGetField(FRZena,SArtikul,0);
  LCorrect.New_O_Zena:=BakGetField(FOZena,SArtikul,0);
  DelSpace(LCorrect.New_R_Zena);
  DelSpace(LCorrect.New_O_Zena);

    New(sk,Init);
    GetSkidka(SArtikul,Sk^.Dat);
    For c:=1 To CShkala Do
    Begin
     shk[c]:=Sk^.DAt.Skidka[c].Up;
     MyStr(StrToReal(shk[c]),CInputIZena,CMAntissa,Shk[c]);
     SProz[c]:=Sk^.DAt.Skidka[c].Proz;
     MyStr(StrToReal(SProz[c]),CLitr+1,CMAntissa+2,SProz[c]);

     MyStr((StrToReal(LCorrect.New_R_Zena)*
       (StrToReal(SProz[c]))),CZena,CMantissa,LCorrect.AutoSkid[c]);
     DelSpace(LCorrect.AutoSkid[c]);
    End;
    Dispose(Sk,Done);


  End;
1:Begin
    LCorrect.New_R_Zena:=Copy(s,1+CName+1+CArtikul+1+CKol+1+CZena+1+CZena+1,CZena);
    LCorrect.New_O_Zena:=Copy(s,1+CName+1+CArtikul+1+CKol+1+CZena+1+CZena+1+CZena+1,CZena);
    DelSpace(LCorrect.New_R_Zena);
    DelSpace(LCorrect.New_O_Zena);

    For c:=1 To CShkala Do
    Begin

    SProz[c]:=Copy(s,1+CName+1+CArtikul+1+CKol+1+CZena+1+CZena+1+CZena+1+CZena+1+
    +(CLitr+1)*(c-1),CLitr+1);
    MyStr(StrToReal(SProz[c]),CLitr+1,CMAntissa+2,SProz[c]);

    MyStr((StrToReal(LCorrect.New_R_Zena)*
       (StrToReal(SProz[c]))),CZena,CMantissa,LCorrect.AutoSkid[c]);
    DelSpace(LCorrect.AutoSkid[c]);
    End;




    New(sk,Init);
    GetSkidka(SArtikul,Sk^.Dat);
    For c:=1 To CShkala Do
    Begin
     shk[c]:=Sk^.DAt.Skidka[c].Up;
     MyStr(StrToReal(shk[c]),CInputIZena,CMAntissa,Shk[c]);
    End;
    Dispose(Sk,Done);


  End;
  Else;
  End;
ClearFind;

1:
AInfo('Читаю информацию о товаре...');
R.Assign(1, 0, 78, 23);
New(CartWin, Init(R, 'Переоценка наименования товара'));
CartWin^.Options := CartWin^.Options or ofCenterX;
CartWin^.Palette := dpCyanDialog;
CartWin^.HelpCtx := $E191{E011};

R.Assign(2, 1, 15, 2);
Control := New(PStaticText, Init(R, 'Наименование:'));
CartWin^.Insert(Control);

R.Assign(15, 1, 41, 2);
Control := New(PStaticText, Init(R, #3+SName));
CartWin^.Insert(Control);

R.Assign(42, 1, 46, 2);
Control := New(PStaticText, Init(R, 'Код:'));
CartWin^.Insert(Control);

R.Assign(46, 1, 51, 2);
Control := New(PStaticText, Init(R, #3+SArtikul));
CartWin^.Insert(Control);

R.Assign(52, 1, 59, 2);
Control := New(PStaticText, Init(R, 'Литраж:'));
CartWin^.Insert(Control);

R.Assign(59, 1, 64, 2);
Control := New(PStaticText, Init(R, #3+SLitr));
CartWin^.Insert(Control);

R.Assign(65, 1, 73, 2);
Control := New(PStaticText, Init(R, 'Фасовка:'));
CartWin^.Insert(Control);

R.Assign(73, 1, 76, 2);
Control := New(PStaticText, Init(R, #3+SInPack));
CartWin^.Insert(Control);

If SName2[0]<>#0 Then
Begin
R.Assign(15, 2, 41, 3);
Control := New(PStaticText, Init(R, SName2));
CartWin^.Insert(Control);
End;



R.Assign(19, 6, 29, 7);
ControlR := New(PInputLine, Init(R, CZena));
CartWin^.Insert(ControlR);
  PInputLine(ControlR)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));

  R.Assign(1, 6, 19, 7);
  CartWin^.Insert(New(PLabel, Init(R, 'Стало ~Р~/Ценам:', ControlR)));

R.Assign(2, 5, 27, 6);
Control := New(PStaticText, Init(R, 'Было Р/Ценам: '+SRZena));
CartWin^.Insert(Control);

R.Assign(2, 4, 27, 5);
MyStr(StrToReal(SZakupka),CZena,CMantissa,SZakupka);
Control := New(PColoredText, Init(R, 'Закупочная цена:'+SZakupka, $31));
CArtWin^.Insert(Control);

R.Assign(19, 8, 29, 9);
ControlO := New(PInputLine, Init(R, CZena));
CartWin^.Insert(ControlO);
  PInputLine(ControlO)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));

  R.Assign(1, 8, 19, 9);
  CartWin^.Insert(New(PLabel, Init(R, 'Стало ~О~/Ценам:', ControlO)));

R.Assign(2, 7, 27, 8);
Control := New(PStaticText, Init(R, 'Было О/Ценам: '+SOZena));
CartWin^.Insert(Control);

R.Assign(2, 3, 20, 4);
Control := New(PStaticText, Init(R, 'На складе имеется:'));
CartWin^.Insert(Control);


R.Assign(2, 10, 73, 22);
Control := New(PColoredText, Init(R, '', $3E));
Control^.Options := Control^.Options or ofFramed;
CartWin^.Insert(Control);




R.Assign(20, 3, 25, 4);
Control := New(PStaticText, Init(R, #3+SKol));
CartWin^.Insert(Control);


R.Assign(25, 9, 46, 10);
Control := New(PColoredText, Init(R, 'Настройка шкалы цен', $4F));
CartWin^.Insert(Control);



For c:=0 To {CShkala}11 Do
 Begin
  R.Assign(2, 9+c+1, 59-40, 10+c+1);
  Control := New(PStaticText, Init(R, 'от '+Shk[c+1]+':'));
  CartWin^.Insert(Control);

  R.Assign(70-40, 9+c+1, 75-40, 10+c+1);
  ControlProz[c+1] := New(PColoredText, Init(R, SProz[c+1], $3E));
  CartWin^.Insert(ControlProz[c+1]);

  R.Assign(59-40, 9+c+1, 69-40, 10+c+1);
  ControlShkala[c+1] := New(PInputLine, Init(R, CZena));
  ControlShkala[c+1]^.Options := ControlShkala[c+1]^.Options and not ofSelectable;

  CartWin^.Insert(ControlShkala[c+1]);
  PInputLine(ControlShkala[c+1])^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));
 End;


For c:=12 To 23 Do
 Begin
  R.Assign(38, 9+(c-11), 55,10+(c-11));
  Control := New(PStaticText, Init(R, 'от '+Shk[c+1]+':'));
  CartWin^.Insert(Control);

  R.Assign(65, 9+(c-11), 66, 10+(c-11));
  ControlProz[c+1] := New(PColoredText, Init(R, SProz[c+1], $3E));
  CartWin^.Insert(ControlProz[c+1]);

  R.Assign(55, 9+(c-11), 65, 10+(c-11));
  ControlShkala[c+1] := New(PInputLine, Init(R, CZena));
  ControlShkala[c+1]^.Options := ControlShkala[c+1]^.Options and not ofSelectable;

  CartWin^.Insert(ControlShkala[c+1]);
  PInputLine(ControlShkala[c+1])^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));
 End;




CartWin^.SetData(LCorrect);

CartWin^.SelectNext(False);

NoInfo;

DrawZena;

{DrawProz;}

c:=Desktop^.ExecView(CartWin);
If c<>cmCancel Then
 Begin
  CArtwin^.GetData(LCorrect);
  Dispose(Control,Done);
  Dispose(CartWin,Done);
  MyStr(StrToReal(LCorrect.New_R_Zena),CZena,CMantissa,LCorrect.New_R_Zena);
  DelSpace(LCorrect.New_R_Zena);
  MyStr(StrToReal(LCorrect.New_O_Zena),CZena,CMantissa,LCorrect.New_O_Zena);
  DelSpace(LCorrect.New_O_Zena);

If Not(FindParam('/NOTEST')) Then
Begin
  If (LCorrect.New_R_Zena=#0) Or (StrTOReal(LCorrect.New_R_Zena)>CMaxZena)Or(StrTOReal(LCorrect.New_R_Zena)=0.0) Then
   Begin
     MessageBox(#3+ErrorRZena,nil, mfError + mfCancelButton);
     GoTo 1;
   End;

  If (LCorrect.New_O_Zena=#0) Or (StrTOReal(LCorrect.New_O_Zena)>CMaxZena)Or(StrTOReal(LCorrect.New_O_Zena)=0.0) Then
   Begin
     MessageBox(#3+ErrorOZena,nil, mfError + mfCancelButton);
     GoTo 1;
   End;
End;
  If (StrToReal(LCorrect.New_R_Zena)<>StrTOReal(LCorrect.New_O_Zena)) Then
   Begin
     MessageBox(#3^M+#3+'Розничная цена не равна оптовой !',nil, mfError + mfCancelButton);
     GoTo 1;
   End;


{$IFNDEF Aisha}
  If (StrToReal(LCorrect.New_R_Zena)<StrTOReal(SZakupka)) Then
   Begin
     SpecialBeep;
     MessageBox(#3^M+#3+'Продажная цена ниже закупочной !',nil, mfError + mfCancelButton);
     GoTo 1;
   End;
{$ENDIF}

{$IFDEF Opt}
    If Not FindParam('/NO19') Then
    If (StrToReal(SZakupka)*1.19)>StrToReal(LCorrect.New_R_Zena) Then
    Begin
     SpecialBeep;
     MessageBox(#3^M+#3+'Наценка по позиции ['+SArtikul+'] менее 19%!',nil,mfError+mfCancelButton);
     If StrToInt(CurrentPAssword)<>0 Then
	 Begin
       GoTo 1;
      End;
    End;
{$ENDIF}



  For c:=1 To CShkala Do
   Begin
    If (StrToReal(SProz[c]))<0.01 Then
     Begin
      SpecialBeep;
      MessageBox(^M+#3+'Недопустимая велечина скидки в колонке '+IntToStr(c,CMantissa)+'!'^M+
	 #3+'Отрицательная скидка!',
                 Nil,mfError+mfCancelButton);
      Goto 1;
     End;


    If (StrToReal(SProz[c]))>99.9 Then
     Begin
      SpecialBeep;
      MessageBox(^M+#3+'Недопустимая велечина скидки в колонке '+IntToStr(c,CMantissa)+'!',
                 Nil,mfError+mfCancelButton);
      Goto 1;
     End;

{$IFNDEF Aisha}
(*    If StrToReal(LCorrect.AutoSkid[c])<StrToreal(SZakupka) Then
     Begin
      SpecialBeep;
      MessageBox(^M+#3'Продажная цена ниже закупочной в колонке '+IntToStr(c,CMantissa)+'!',Nil,mfError+mfCancelButton);
      Goto 1;
     End;

    If StrToReal(LCorrect.AutoSkid[c])<(StrToReal(SZakupka)*(1+StrToReal(GetMinNazenka(SArtikul,c))/100)) Then
     Begin
      SpecialBeep;
      MessageBox(^M+#3'Продажная цена ниже минимальной наценки в колонке '+IntToStr(c,COne)+'!',Nil,mfError+mfCancelButton);
     End;  *)
{$ENDIF}

   End;

  For c:=1 To 6 Do
   Begin
    If c>1 Then
     If StrToReal(SProz[c-1])<StrToReal(SProz[c]) Then
     Begin
      SpecialBeep;
      MessageBox(^M+#3'Ошибка расстановки скидок в шкале!'^M+
	 #3+'Поменяйте местами колонки '+IntToStr(c-1,CMantissa)+' и '+IntToStr(c,CMantissa)+'!',Nil,mfError+mfCancelButton);
      Goto 1;
     End;
   End;

   Str(StrToInt(SKol):CKol,SKol);
   Format(SKol,CKol);
   MyStr(StrToReal(SRZena),CZena,CMantissa,SRZena);
   MyStr(StrToReal(SOZena),CZena,CMantissa,SOZena);
   Format(SRZena,CZena);
   Format(SOZena,CZena);
   MyStr(StrToReal(LCorrect.New_R_Zena),CZena,CMantissa,LCorrect.New_R_Zena);
   MyStr(StrToReal(LCorrect.New_O_Zena),CZena,CMantissa,LCorrect.New_O_Zena);
   Format(LCorrect.New_R_Zena,CZena);
   Format(LCorrect.New_O_Zena,CZena);
   s:=SName+'│'+SArtikul+'│'+SKol+'│'+SRZena+'│'+SOZena+'│'+LCorrect.New_R_Zena+'│'+LCorrect.New_O_Zena+'│';

   For c:=1 To CShkala Do
    Begin
     SProz[c]:=RealtoStr(StrToReal(SProz[c]),CLitr+1,CMantissa+2);
     Format(SProz[c],CLitr+1);
     s:=s+SProz[c]{+'│'};
    End;



   If Regim=1 Then
    Begin
     Pereozenka^.List^.AtFree(Pereozenka^.Focused);
     Pereozenka^.SetRange(Pereozenka^.List^.Count);
    End;
   Pereozenka^.List^.Insert(NewStr(S));
   Pereozenka^.SetRange(Pereozenka^.List^.Count);
   Pereozenka^.FocusItem(LoCation(Pereozenka,SArtikul,ProdagaWindow));
{                          Код   Литр  Фас Колич Р-Цена   О-Цена   Сертиф
Акциз                                                                        НДС
12345678901234567890123456│12345│12345│123│99999│999999.9│999999.9│
1234567890123456789012345678901234567890123456789012345678901234567890123456│
1234567890123456789012345678901234567890123456789012345678901234567890123456│12345│
}
 End
 Else
 Begin
  If Regim=0 Then
  Repeat
  until (SetNameUnLock(SArtikul));
  Dispose(Control,Done);
  Dispose(CartWin,Done);
 End;

End;

Destructor TCartPrzWinDow.Done;
VAr c: Word;
Begin
Dispose(ControlR,Done);
Dispose(ControlO,Done);
For c:=1 To CShkala Do
Begin
 Dispose(ControlProz[c],Done);
 Dispose(ControlShkala[c],Done);
End;

TDialog.Done;
End;

Procedure DrawOpt;
Var s: String[CPack];
    R : TRect;
    M : Zena;
Begin
    CartWin^.GetData(LCorrect);
    s:=GetIdField(FLitr,sArtikul);
    If StrToReal(LCorrect.New_R_Zena)+Lizensia*StrToReal(GetIdField(FLitr,sArtikul))>CMaxZena Then
    Begin
    s[0]:=#0;
    COntrolO^.SetData(s);
    End
    Else
    Begin
    MyStr(StrToReal(LCorrect.New_R_Zena)+Lizensia*StrToReal(GetIdField(FLitr,sArtikul)),CZena,CMantissa,s);
    DelSpace(S);
    COntrolO^.SetData(S);
    End;
End;



procedure TCartPrzWindow.HandleEvent(var Event: TEvent);
Var DrawP : Boolean;

procedure Calculator;
begin
  Calc^.Start;
end;

Begin
Case Event.What Of
 evCommand :
 Begin
   Case Event.Command Of
        cmLocalCalc:Calculator;
   Else;
   End;
 End;
 evKeyDown:
   Case Event.KeyCode Of
        kbEnter:Begin
                inherited HandleEvent(Event);
                If (CartWin^.Current=ControlR) Then
                   Begin
                    Event.What:=evCommand;
                    Event.Command:=CmOk;
                   End;
                End;
   Else;
   End;
   Else;
   End;
  If (Event.What=evKeyboard)And((Event.CharCode in ['0','1','2','3','4','5','6','7','8','9','.'])
  Or (Event.KeyCode=kbDel) Or (Event.KeyCode=kbBack))And (ConTrolR^.State and sfFocused <> 0) Then
   Begin
  inherited HandleEvent(Event);
  DrawOpt;
  DrawZena;
  End
  Else
   Begin
  If (Event.What=evKeyboard)And((Event.CharCode in ['0','1','2','3','4','5','6','7','8','9','.'])
  Or (Event.KeyCode=kbDel) Or (Event.KeyCode=kbBack)) Then DrawP:=True
  Else DrawP:=False;
  inherited HandleEvent(Event);
  If DrawP Then Begin
                 If (ControlShkala[1]^.State and sfFocused <> 0) Or
                    (ControlShkala[2]^.State and sfFocused <> 0) Or
                    (ControlShkala[3]^.State and sfFocused <> 0) Or
                    (ControlShkala[4]^.State and sfFocused <> 0) Or
                    (ControlShkala[5]^.State and sfFocused <> 0) Or
                    (ControlShkala[6]^.State and sfFocused <> 0) Or
                    (ControlShkala[7]^.State and sfFocused <> 0) Or
                    (ControlShkala[8]^.State and sfFocused <> 0) Or
                    (ControlShkala[9]^.State and sfFocused <> 0) Or
                   (ControlShkala[10]^.State and sfFocused <> 0) Or
                   (ControlShkala[11]^.State and sfFocused <> 0) Or
                   (ControlShkala[12]^.State and sfFocused <> 0) Or
                   (ControlShkala[13]^.State and sfFocused <> 0) Or
                   (ControlShkala[14]^.State and sfFocused <> 0) Or
                   (ControlShkala[15]^.State and sfFocused <> 0) Or
                   (ControlShkala[16]^.State and sfFocused <> 0) Or
                   (ControlShkala[17]^.State and sfFocused <> 0) Or
                   (ControlShkala[18]^.State and sfFocused <> 0) Or
                   (ControlShkala[19]^.State and sfFocused <> 0) Or
                   (ControlShkala[20]^.State and sfFocused <> 0) Or
                   (ControlShkala[21]^.State and sfFocused <> 0) Or
                   (ControlShkala[22]^.State and sfFocused <> 0) Or
                   (ControlShkala[23]^.State and sfFocused <> 0) Or
                   (ControlShkala[24]^.State and sfFocused <> 0) Then DrawProz;
                End;


   End;
  ClearEvent(Event);
End;

(*
Function WritePrzToFile(L:PPereozenkaType) : Boolean;
Var c : Byte;
Begin
 WritePrzToFile:=False;
 Assign(PrzFile,Path.ToCorrect+TekDate+'.prz');
 c:=IOResult;
{$I-}
 Reset(PrzFile);
 c:=IOResult;
If c<>0 Then
 Begin
  If MessageBox('Файл '+TekDate+'.prz не существует !'^M+
     'Создать такой файл? '
        +' Код:'+IntToStr(c,3),nil, mfConfirmation + mfOkCancel)=cmOk Then
     Begin
      Rewrite(PrzFile);
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
   Seek(PrzFile,StrToInt(ClearChar(L^.Dat.Document))-1);
   Write(PrzFile,L^.Dat);
   Close(PrzFile);
   WritePrzToFile:=True;
  End;
End;*)


Function WritePrzToSkladFile(L:PPereozenkaType) : Boolean;
Var SkladFile : File Of SkladType;
    Skl : PSkladType;
    SkidFile : File Of SkidkaType;
    Skid : PSkidkaType;
    i,p : Byte;
    c : Word;
    Ls:LongInt;
    s1,s2 : TEnjoyStr;
    s3,s4 : String;
Begin
WritePrzToSkladFile:=False;
New(Skl,Init);
New(Skid,Init);
 For i:=1 To L^.DAt.Amount{J} Do
  Begin
   S1:=Copy(L^.Dat.Element[i].BazKod,1,CRazdelKod);
   Assign(SkladFile,Path.ToSklad+s1+'.db');
   p:=IOResult;
   Reset(SkladFile);
   p:=IOResult;
   If p <> 0 Then
    Begin
     MessageBox(#3^M+#3'Ошибка доступа к файлу '+S1+'.db!',Nil,mfError+mfCancelButton);
     Dispose(Skl,Done);
     Exit;
    End;

   Assign(SkidFile,Path.ToSkidki+s1+'.skl');
   p:=IOResult;
   Reset(SkidFile);
   p:=IOResult;
   If p <> 0 Then
    Begin
     MessageBox(#3^M+#3'Ошибка доступа к файлу '+S1+'.skl!',Nil,mfError+mfCancelButton);
     Dispose(Skl,Done);
     Dispose(Skid,Done);
     Close(SkladFile);
     Exit;
    End;


   Seek(SkladFile,GetFileLocation3(Copy(L^.Dat.Element[i].BazKod,CRazdelKod+1,CKod)));
   Seek(SkidFile,GetFileLocation3(Copy(L^.Dat.Element[i].BazKod,CRazdelKod+1,CKod)));
   {блокируем позицию предварительной блокировкой}

   Repeat
    Pause(1);
   Until Lock(SkladFile,FilePos(SkladFile)*SizeOf(SkladType),SizeOf(SkladType));

   Repeat
    Pause(1);
   Until Lock(SkidFile,FilePos(SkidFile)*SizeOf(SkidkaType),SizeOf(SkidkaType));

   Read(SkladFile,Skl^.DAt);

   Read(SkidFile,Skid^.DAt);
    {модифицируем поля связанные с ценной}

    With Skid^.Dat Do
    Begin
    s4[0]:=#0;
    For c:=1 To CShkala Do
    Begin
     DelSpace(Skidka[c].Proz);
     DelSpace(Skidka[c].Up);
     s4:=s4+Skidka[c].Up+'-'+Skidka[c].Proz+';'
    End;
    End;
    {таблица скидок}
    With Skid^.Dat Do
    Begin
    s3[0]:=#0;
    For c:=1 To CShkala Do
    Begin
     MyStr(StrToReal(L^.Dat.Element[i].AutoSkid[c]),CLitr+1,CMAntissa+2,Skidka[c].Proz);
     DelSpace(Skidka[c].Proz);
     s3:=s3+Skidka[c].Up+'-'+Skidka[c].Proz+';'
    End;
    Date:=FDate;
    Time:=Times;
    Caption:=CurrentPassword;
    End;

    {склад}
    With Skl^.Dat.Input Do
    Begin
      R_Zena:=L^.Dat.Element[i].New_R_Zena;
      O_Zena:=L^.Dat.Element[i].New_O_Zena;
      Caption:=L^.Dat.Caption;
      Skl^.Dat.Date := TekDate;
      Skl^.Dat.Time := Times;
    End;
    {сохраняем изменения}
    Seek(SkladFile,FilePos(SkladFile)-1);
    Write(SkladFile,Skl^.Dat);

    Seek(SkidFile,FilePos(SkidFile)-1);
    Write(SkidFile,Skid^.Dat);

    {деблокируем позицию}

    Seek(SkladFile,FilePos(SkladFile)-1);
    Repeat
     UnLock(SkladFile,FilePos(SkladFile)*SizeOf(SkladType),SizeOf(SkladType));
    Until (DosError=0);

    Seek(SkidFile,FilePos(SkidFile)-1);
    Repeat
     UnLock(SkidFile,FilePos(SkidFile)*SizeOf(SkidkaType),SizeOf(SkidkaType));
    Until (DosError=0);

    Close(SkladFile);{закрытие файла}
    Close(SkidFile);{закрытие файла}

   If s3<>s4 Then
    AddProtocol('Коррекция таблицы скидок у '+GetIdField(FName,L^.Dat.Element[i].BazKod)+
    ' ('+L^.Dat.Element[i].BazKod+') по переоценке N'+L^.Dat.Document+' от '+L^.Dat.DateC+'{!Скидки! переоценка}',
    'Было:'+s4,
    'Стал:'+s3);
  End;
Dispose(Skl,Done);
Dispose(Skid,Done);

WritePrzToSkladFile:=True;
End;



procedure TPrzWindow.UnlockAllName;
Var i : Integer;
    s : String;
Begin
If (Pereozenka^.List^.Count-1)>=0 Then
 For i:=0 To Pereozenka^.List^.Count-1 Do
 Begin
  s:=Pereozenka^.GetText(i,Pereozenka^.List^.Limit);
  s:=Copy(s,1+CName+1,CArtikul);
  Repeat
  Until(SetNameUnlock(s));
 End;

End;


Procedure TPrzWindow.SaveToFile(Var Save : Boolean);
Var
    PrzElement : PPereozenkaType;
    I  : Byte;
    s  : String;
    st : TDateString;
    As : DocumentEdit;
    c  : Word;
Begin
Save:=False;
New(PrzElement,Init);{:=TestPr;}
PrzElement^.Dat.Vid:=0;
{чтение с экрана прихода}
For i:=0 To Pereozenka^.List^.Count-1 Do
 Begin
  s:=Pereozenka^.GetText(i,Pereozenka^.List^.Limit);
  With PrzElement^.Dat.Element[i+1] Do
   Begin
    Kol:=Copy(s,1+CName+1+CArtikul+1,CKol);
    DelSpace(Kol);
    Bak_R_Zena:=Copy(s,1+CName+1+CArtikul+1+CKol+1,CZena);
    DelSpace(Bak_R_Zena);
    Bak_O_Zena:=Copy(s,1+CName+1+CArtikul+1+CKol+1+CZena+1,CZena);
    DelSpace(Bak_O_Zena);
    New_R_Zena:=Copy(s,1+CName+1+CArtikul+1+CKol+1+CZena+1+CZena+1,CZena);
    DelSpace(New_R_Zena);
    New_O_Zena:=Copy(s,1+CName+1+CArtikul+1+CKol+1+CZena+1+CZena+1+CZena+1,CZena);
    DelSpace(New_O_Zena);
    BazKod:=Copy(s,1+CName+1,CArtikul);

    For c:=1 To CShkala Do
    Begin
    AutoSkid[c]:=Copy(s,1+CName+1+CArtikul+1+CKol+1+CZena+1+CZena+1+CZena+1+CZena+1+
    +(CLitr+1)*(c-1),CLitr+1);
    MyStr(StrToReal(AutoSkid[c]),CLitr+1,CMAntissa+2,AutoSkid[c]);
    DelSpace(AutoSkid[c]);
    End;
   End;
 End;
{L.Document:=DocumentNumer;}
 PrzElement^.Dat.DateM:=FDate;
 PrzElement^.Dat.TimeM:=Times;
 PrzElement^.Dat.DateC:=FDate;
 PrzElement^.Dat.TimeC:=Times;
 PrzElement^.Dat.Caption:=CurrentPassword;
{PrzElement^.Dat.Sklad:=Rek.SkladsName;}
 PStaticText(ControlDocNum)^.GetText(s);
 DelSpace(S);
 System.Delete(S,Pos(#3,S),1);
 PrzElement^.Dat.Document:=s;
 PrzElement^.Dat.Amount:=Pereozenka^.List^.Count;

 PStaticText(ControlBak_R_Zena)^.GetText(s);
 DElSpace(S);
 System.Delete(S,Pos(#3,S),1);
 PrzElement^.Dat.Itogo_Bak_R_Zena:=S;

 PStaticText(ControlBak_O_Zena)^.GetText(s);
 DElSpace(S);
 System.Delete(S,Pos(#3,S),1);
 PrzElement^.Dat.Itogo_Bak_O_Zena:=S;

 PStaticText(ControlNew_R_Zena)^.GetText(s);
 DElSpace(S);
 System.Delete(S,Pos(#3,S),1);
 PrzElement^.Dat.Itogo_New_R_Zena:=S;

 PStaticText(ControlNew_O_Zena)^.GetText(s);
 DElSpace(S);
 System.Delete(S,Pos(#3,S),1);
 PrzElement^.Dat.Itogo_New_O_Zena:=S;

 PStaticText(ControlItogo_R_Zena)^.GetText(s);
 DElSpace(S);
 System.Delete(S,Pos(#3,S),1);
 PrzElement^.Dat.Delta_RZ:=S;

 PStaticText(ControlItogo_O_Zena)^.GetText(s);
 DElSpace(S);
 System.Delete(S,Pos(#3,S),1);
 PrzElement^.Dat.Delta_OZ:=S;
{прочитали с экрана переоценку}
 Save:=WritePrzToSkladFile(PrzElement);
 If Save Then Save:=LockAndWritePereozenka(PrzElement)
      Else
       Begin
        Dispose(PrzElement,Done);
        Exit;
       End;
 If Save Then
     Begin
       AddProtocol('Переоценка товара согласно акту N '+PrzElement^.Dat.Document+' от '+FDate,'','');
       If MessageBox(#3^M+#3'Переоценка товара проведена!'^M+
          #3'Печатать акт переоценки ?',Nil,mfConfirmation+mfOkCancel)=cmOk Then
         Begin
           As.D:=TekDate;
           As.EditPosition:=PrzElement^.Dat.Document;
           PrintAktPrz(As);
         End;
     End;
Dispose(PrzElement,Done);
UnLockAllName;
End;



procedure TPrzWindow.OpenPrzWindow;
Var l : Boolean;
begin
  if Message(Desktop, evBroadcast, cmPereozen, nil) = nil then
  begin
    DInfo('Инициализация переоценки...');
    L:=True;
    PrzWindow := New(PPrzWindow, Init(L));
    If L Then
    Begin
    Application^.InsertWindow(PrzWindow);
    NoInfo;
    End
    Else
     Begin
      TekDate:=FDate;
      Status:=DocNormal;
      Dispose(PrzWindow,Done);
      Noinfo;
     End;
  end
  else
    if PView(PrzWindow) <> Desktop^.TopView then PrzWindow^.Select;
end;

constructor TPrzWindow.Init(Var l : Boolean);
var
  R : TRect;
  Control : PView;
  C : Word;
  DocumentNumer : TDateString;
  s: TEnjoyStr;
  SNAme : String[CName];

begin

R.Assign(1, 0, 78, 23);
inherited Init(R,'');
Options := Options or ofCenterX or ofCenterY;

L:=False;
TekDate:=FDate;
If Not(TestOpenDate1(TekDate)) Then
   Begin
    MessageBox(#3^M+#3'Доступ к данным за '+TekDate+' заблокирован!',Nil,mfError+mfCancelButton);
    Exit;
   End;
ClearFind;

C:=IOResult;
  Assign(PrzFile,Path.ToCorrect+TekDate+'.prz');
  Reset(PrzFile);
  C:=IOResult;
  If C<>0 Then
   Begin
     If MessageBox('Файл переоценки '+TekDate+'.prz не найден!'^M+
     #3'Если вы раньше что-либо переоценили позовите программиста! Создаю файл?'+
        +' Код:'+IntToStr(c,3),nil, mfWarning + mfOkCancel)=cmOk
     Then
         Begin
{       c:=Ioresult;
       Reset(PrzFile);
       c:=Ioresult;
       If c<>0 Then Rewrite(PrzFile);}
       If Not(CreatToDayF(DocPereozen,TekDate)) Then Exit;
       Reset(PrzFile);
       c:=IOResult;
      End
    Else Exit;
   End;
{   DocumentNumer:=IntToStr(FileSize(PrzFile)+1,CDocNumer);
   System.Close(PrzFile);}
   System.Close(PrzFile);
   If Not(UseDocNumer(DocPereozen,TekDate,DocumentNumer)) Then Exit;

R.Assign(0, 0, 0, 0);
Razdel := New(PBox, Init(R, 1, Nil));
Razdel^.NewList(New(PTextCollection, Init(1,1)));
Assign (RazdelFile,Path.ToRazdel+'razdel.db');
Reset (RazdelFile);
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

PrevS:=Razdel^.GetText(Razdel^.Focused,Razdel^.List^.Count);

Dispose(Razdel,Done);

R.Assign(51, 0, 76, 1);
ControlRazdel := New(PColoredText, Init(R, #3+PrevS, $1F));
ControlRazdel^.Options := ControlRazdel^.Options or ofSelectable;
Insert(ControlRazdel);

R.Assign(43, 0, 51, 1);
Insert(New(PLabel, Init(R, 'Ра~з~дел:', ControlRazdel)));

R.Assign(76, 2, 77, 9);
Control := New(PScrollBar, Init(R));
Insert(Control);

R.Assign(19, 2, 76, 9);
Baz := New(PBox, Init(R, 1, PScrollbar(Control)));
Baz^.NewList(New(PTextCollection, Init(1,1)));
PStaticText(ControlRazdel)^.GetText(PrevS);
System.Delete(PrevS,1,1);
c:=Pos('│',PrevS);
PrevS:=Copy(Prevs,c+1,CArtikul);
DelSpace(PrevS);
If (Prevs[0]<>#0)Then
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
   If BazElement^.Dat.Employ {And (StrToInt(BazElement.Input.Kol)>0)} Then
{  If GetIdEmploy(BazElement.BazKod)And (StrToInt(BazElement.Input.Kol)>0)  Then}
   Begin
    SName := GetIdField(FName,BazElement^.Dat.BazKod);
    Format(SName,CName);
    Str(StrToInt(BazElement^.Dat.Input.Kol):CLitr,BazElement^.Dat.Input.Kol);
    Format (BazElement^.Dat.Input.Kol,CLitr);
    MyStr(StrToReal(BazElement^.Dat.Input.R_Zena),CZena,CMantissa,BazElement^.Dat.Input.R_Zena);
    Format (BazElement^.Dat.Input.R_Zena,CZena);
    MyStr(StrToReal(BazElement^.Dat.Input.O_Zena),CZena,CMantissa,BazElement^.Dat.Input.O_Zena);
    Format (BazElement^.Dat.Input.O_Zena,CZena);
    Prevs:=SName+'│'+BazElement^.Dat.BazKod+'│'+BazElement^.Dat.Input.Kol+'│'+
    +BazElement^.Dat.Input.R_Zena+'│'+BazElement^.Dat.Input.O_Zena;
    Baz^.List^.Insert(NewStr(Prevs));
    Baz^.SetRange(Baz^.List^.Count);
   End;
 End;
System.Close(BazFile);
 End;
Baz^.FocusItem(0);
Baz^.HelpCtx:=$E141;
Insert(Baz);

  R.Assign(19, 1, 76, 2);
  Insert(New(PLabel, Init(R, 'Наи~м~енование товара         Код  Колич Р/Цена   О/Цена', Baz)));

R.Assign(2, 9, 22, 10);
Control := New(PColoredText, Init(R, 'Наименование товара:', $74));
Insert(Control);

R.Assign(22, 9, 76, 10);
ControlFullNAme := New(PColoredText, Init(R, #3+' ', $7E));
Insert(ControlFullNAme);



R.Assign(76, 12, 77, 19);
Control := New(PScrollBar, Init(R));
Insert(Control);

R.Assign(1, 12, 76, 19);
Pereozenka := New(PBox, Init(R, 1, PScrollbar(Control)));
Pereozenka^.NewList(New(PTextCollection, Init(1,1)));
Pereozenka^.HelpCtx:=$E150;
Pereozenka^.FocusItem(0);
Insert(Pereozenka);

  R.Assign(1, 11, 76, 12);
  Insert(New(PLabel, Init(R, '~Н~аименование               Код   Колич Р/Цена   О/Цена   Р/Цена   О/Цена  ', Pereozenka)));


R.Assign(4, 19, 24, 20);
Control := New(PColoredText, Init(R, 'Итого по старым Р/Ц:', $74));
Insert(Control);

R.Assign(4, 20, 24, 21);
Control := New(PColoredText, Init(R, 'Итого по старым О/Ц:', $74));
Insert(Control);

R.Assign(24, 19, 39, 20);
ControlBak_R_Zena := New(PColoredText, Init(R, '0.0', $7E));
Insert(ControlBak_R_Zena);

R.Assign(24, 20, 39, 21);
ControlBak_O_Zena := New(PColoredText, Init(R, '0.0', $7E));
Insert(ControlBak_O_Zena);

R.Assign(40, 19, 59, 20);
Control := New(PColoredText, Init(R, 'Итого по новым Р/Ц:', $74));
Insert(Control);

R.Assign(59, 19, 74, 20);
ControlNew_R_Zena := New(PColoredText, Init(R, '0.0', $7E));
Insert(ControlNew_R_Zena);

R.Assign(40, 20, 59, 21);
Control := New(PColoredText, Init(R, 'Итого по новым О/Ц:', $74));
Insert(Control);

R.Assign(59, 20, 74, 21);
ControlNew_O_Zena := New(PColoredText, Init(R, '0.0', $7E));
Insert(ControlNew_O_Zena);

R.Assign(2, 2, 13, 3);
Control := New(PColoredText, Init(R, 'Документ N:', $74));
Insert(Control);

R.Assign(3, 4, 8, 5);
Control := New(PColoredText, Init(R, 'Дата:', $74));
Insert(Control);

R.Assign(4, 21, 24, 22);
Control := New(PColoredText, Init(R, 'Переоценка  по  Р/Ц:', $74));
Insert(Control);

R.Assign(24, 21, 39, 22);
ControlItogo_R_Zena := New(PColoredText, Init(R, '0.0', $7E));
Insert(ControlItogo_R_Zena);

R.Assign(40, 21, 59, 22);
Control := New(PColoredText, Init(R, 'Переоценка  по О/Ц:', $74));
Insert(Control);

R.Assign(59, 21, 74, 22);
ControlItogo_O_Zena := New(PColoredText, Init(R, '0.0', $7E));
Insert(ControlItogo_O_Zena);

R.Assign(13, 2, 16, 3);
ControlDocNum := New(PColoredText, Init(R, ''+DocumentNumer, $7E));
Insert(ControlDocNum);

R.Assign(8, 4, 16, 5);
Control := New(PColoredText, Init(R, ''+TekDate, $7E));
Insert(Control);

R.Assign(6, 6, 13, 7);
Control := New(PColoredText, Init(R, ' Склад:', $74));
Insert(Control);

R.Assign(4, 7, 16, 8);
Control := New(PColoredText, Init(R, ''+{Rek.SkladsName}GetClientField(FClient,Rek.Kod,1), $7E));
Insert(Control);

R.Assign(41, 10, 55, 11);
Control := New(PColoredText, Init(R, #3+'┌─ Старые ─┐', $74));
Insert(Control);

R.Assign(60, 10, 73, 11);
Control := New(PColoredText, Init(R, #3+'┌─ Новые ──┐', $74));
Insert(Control);

R.Assign(4, 10, 12, 11);
Control := New(PColoredText, Init(R, 'Выбрано:', $74));
Insert(Control);

R.Assign(12, 9, 14, 10);
ControlCurrent := New(PColoredText, Init(R, #3+'0', $7E));
Insert(Control);

R.Assign(1, 0, 20, 1);
Control := New(PColoredText, Init(R, ' Переоценка товара', $4F));
Insert(Control);


SelectNext(False);
CalcItogo;
AddName;
PrevS[0]:=#0;
PrevName[0]:=#0;
L := True;
end;


procedure TPrzWindow.CalcItogo;
Var R:TRect;
    t,l,k : Real;
    Sl,Sk,So,bSo,Sr,bSr : Real;
    bSSo,SSl,SSk,SSo,SSr,bSSr,Itogo_O,Itogo_R,Itogo_L:String[CIZena];
    ls : Word;
    Code:Integer;
    kol : LongInt;
Begin
SO:=0;
SR:=0;
bSO:=0;
bSR:=0;
For ls:=0 To Pereozenka^.List^.Limit Do
Begin
{колич}
SSk:=Copy(Pereozenka^.GetText(ls,Pereozenka^.List^.Limit),1+CName+1+CArtikul+1,CKol);
DelSpace(sSk);
{новые р/ц}
SSr:=Copy(Pereozenka^.GetText(ls,Pereozenka^.List^.Limit),1+CName+1+CArtikul+1+CKol+1+CZena+1+CZena+1,CZena);
DelSpace(sSr);
{старые р/ц}
bSSr:=Copy(Pereozenka^.GetText(ls,Pereozenka^.List^.Limit),1+CName+1+CArtikul+1+CKol+1,CZena);
DelSpace(bsSr);
{новые о/ц}
SSo:=Copy(Pereozenka^.GetText(ls,Pereozenka^.List^.Limit),1+CName+1+CArtikul+1+CKol+1+CZena+1+CZena+1+CZena+1,CZena);
DelSpace(sso);
{старые р/ц}
bSSo:=Copy(Pereozenka^.GetText(ls,Pereozenka^.List^.Limit),1+CName+1+CArtikul+1+CKol+1+CZena+1,CZena);
DelSpace(bsso);
Val(ssk,kol,Code);
Val(ssr,l,Code);
Sr:=Sr+l*Kol;
Val(sso,l,Code);
So:=So+l*Kol;
Val(bssr,l,Code);
bSr:=bSr+l*Kol;
Val(bsso,l,Code);
bSo:=bSo+l*Kol;
End;{for}

MyStr(Sr,CIZena,CMantissa,Itogo_R);
DelSpace(Itogo_R);
MyStr(So,CIZena,CMantissa,Itogo_O);
DelSpace(Itogo_O);
MyStr(bSr,CIZena,CMantissa,Itogo_R);
DelSpace(Itogo_R);
MyStr(bSo,CIZena,CMantissa,Itogo_O);
DelSpace(Itogo_O);

MyStr(BSr,CIZena,CMantissa,Itogo_R);
DelSpace(Itogo_R);
Dispose(ControlBak_R_Zena,Done);
R.Assign(24, 19, 39, 20);
ControlBak_R_Zena := New(PColoredText, Init(R, #3+Itogo_R, $7E));
Insert(ControlBak_R_Zena);

MyStr(BSo,CIZena,CMantissa,Itogo_O);
DelSpace(Itogo_O);
Dispose(ControlBak_O_Zena,Done);
R.Assign(24, 20, 39, 21);
ControlBak_O_Zena := New(PColoredText, Init(R, #3+Itogo_O, $7E));
Insert(ControlBak_O_Zena);

MyStr(Sr,CIZena,CMantissa,Itogo_R);
DelSpace(Itogo_R);
Dispose(ControlNew_R_Zena,Done);
R.Assign(59, 19, 74, 20);
ControlNew_R_Zena := New(PColoredText, Init(R, #3+Itogo_R, $7E));
Insert(ControlNew_R_Zena);


MyStr(So,CIZena,CMantissa,Itogo_O);
DelSpace(Itogo_O);
Dispose(ControlNew_O_Zena,Done);
R.Assign(59, 20, 74, 21);
ControlNew_O_Zena := New(PColoredText, Init(R, #3+Itogo_O, $7E));
Insert(ControlNew_O_Zena);

MyStr((Sr-Bsr),CIZena,CMantissa,Itogo_R);
DelSpace(Itogo_R);
Dispose(ControlItogo_R_Zena,Done);
R.Assign(24, 21, 39, 22);
ControlItogo_R_Zena := New(PColoredText, Init(R, #3+Itogo_R, $7E));
Insert(ControlItogo_R_Zena);

MyStr((So-Bso),CIZena,CMantissa,Itogo_O);
DelSpace(Itogo_O);
Dispose(ControlItogo_O_Zena,Done);
R.Assign(59, 21, 74, 22);
ControlItogo_O_Zena := New(PColoredText, Init(R, #3+Itogo_O, $7E));
Insert(ControlItogo_O_Zena);
End;



Procedure TPrzWindow.AddName;

Var R : TRect;
    KolStr : String[3];

Begin
  Str(Pereozenka^.List^.Count:2,KolStr);
  Dispose(ControlCurrent,Done);
  R.Assign(12, 10, 14, 11);
  ControlCurrent := New(PColoredText, Init(R, #3+KolStr, $7E));
  Insert(ControlCurrent);
  Redraw;
End;


Procedure TPrzWindow.DrawFullName;
Var S: String;
    R : TRect;
    SArt : ArtikulStr;
Begin
if (Pereozenka^.State and sfFocused <> 0)  Then
Begin
If (Pereozenka^.List<>Nil)And(Pereozenka^.List^.Count>=1) Then
{If (Pereozenka^.List^.Count>0) Then}
Begin
s:=Pereozenka^.GetText(Pereozenka^.Focused,Pereozenka^.List^.Count);
If s<>PrevName Then
Begin
 PrevName:=s;
 Sart:=Copy(s,1+CName+1,CArtikul);
 Dispose(ControlFullName,Done);
 R.Assign(22, 9, 76, 10);
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
 R.Assign(22, 9, 76, 10);
 s:=' ';
 ControlFullName := New(PColoredText, Init(R, s, $7e));
 Insert(ControlFullName);
  End;
End;

if (Baz^.State and sfFocused <> 0)  Then
Begin
{If (Baz^.List^.Count>0) Then}
If (Baz^.List<>Nil)And(Baz^.List^.Count>=1) Then
Begin
s:=Baz^.GetText(Baz^.Focused,Baz^.List^.Count);
If s<>PrevName Then
Begin
 PrevName:=s;
 Sart:=Copy(s,1+CName+1,CArtikul);
 Dispose(ControlFullName,Done);
 R.Assign(22, 9, 76, 10);
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
 R.Assign(22, 9, 76, 10);
 s:=' ';
 ControlFullName := New(PColoredText, Init(R, s, $7e));
 Insert(ControlFullName);
  End;
End;

if (Baz^.State and sfFocused = 0) And (Pereozenka^.State and sfFocused = 0)Then
 Begin
 PrevName[0]:=#0;
 Dispose(ControlFullName,Done);
 R.Assign(22, 9, 76, 10);
 s:=' ';
 ControlFullName := New(PColoredText, Init(R, s, $7e));
 Insert(ControlFullName);
 End;

End;






procedure TPrzWindow.HandleEvent(var Event: TEvent);
Var test,IO : Word;
    s,s1 : String;
    l : Boolean;
    SNAme : String[CName];
    SDoc  : ArtikulStr;
    SDate : TDateString;

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
    DInfoMsg('Позиция ['+s+'] отмечена как удаленная. Не могу заблокировать позицию!');
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
    DInfoMsg('Позиция ['+s+'] используется'+Msg+'. Не могу заблокировать позицию!');
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

Procedure Refresh(Var s,PrevS:String);
Begin
{               If s <> PrevS Then}
               If (s <> PrevS) Or(s[0]=#0) Or (PrevS[0]=#0) Then
                 Begin
                  DInfo('Читаю список товаров..');
                  PrevS:=S;
                  s:=Copy(s,1+CRazdel+1,CRazdelKod);
                  DelSpace(S);
                  Baz^.NewList(nil);
                  Baz^.NewList(New(PTextCollection, Init(1,1)));
                  If s[0]<>#0 Then
                  Begin
                  Assign (BazFile,Path.ToSklad+s+'.db');
                  IO:=IOResult;
                  Reset (BazFile);
                  IO:=IOResult;
                  If IO=0 Then
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
                     If BazElement^.Dat.Employ {And (StrToInt(BazElement.Input.Kol)>0)} Then
{                     If GetIdEmploy(BazElement.BazKod)And (StrToInt(BazElement.Input.Kol)>0)  Then}

                     Begin
                      SName := GetIdField(FName,BazElement^.Dat.BazKod);
                      Format(SName,CName);
    Str(StrToInt(BazElement^.Dat.Input.Kol):CKol,BazElement^.Dat.Input.Kol);
    Format (BazElement^.Dat.Input.Kol,CLitr);
    MyStr(StrToReal(BazElement^.Dat.Input.R_Zena),CZena,CMantissa,BazElement^.Dat.Input.R_Zena);
    Format (BazElement^.Dat.Input.R_Zena,CZena);
    MyStr(StrToReal(BazElement^.Dat.Input.O_Zena),CZena,CMantissa,BazElement^.Dat.Input.O_Zena);
    Format (BazElement^.Dat.Input.O_Zena,CZena);
    Baz^.List^.Insert(NewStr(SName+'│'+BazElement^.Dat.BazKod+'│'+BazElement^.Dat.Input.Kol+'│'+
    +BazElement^.Dat.Input.R_Zena+'│'+BazElement^.Dat.Input.O_Zena));
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
                  Redraw;
                 End;
End;

Procedure UnlockAll;
Var  f : File Of BazType;
     cl : PBazType;
     r : Byte;
     s : StrName;
Begin
AInfo('Минуточку...');
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
   r:=IOResult;

   cl^.Dat.Locked:=False;
   cl^.Dat.LockCAption[0]:=#0;
   Seek(f,FilePos(f)-1);
   r:=IOResult;
   Write(f,cl^.Dat);
   r:=IOResult;
  End;
System.close(f);
r:=IOResult;
Dispose(cl,Done);
NoInfo;
End;


begin

  Case Event.What Of
  evKeyDown :
  Case Event.KeyCode Of
     kbDel: Begin
     If (Pereozenka^.State and sfFocused <> 0) And (Pereozenka^.List<>Nil)And(Pereozenka^.List^.Count>=1) Then
            Begin
              If MessageBox(#3^M+#3'Удалить товар из акта переоценки?',nil,mfConfirmation+mfOkCancel)=cmOk Then
               Begin
                s:=Pereozenka^.GetText(Pereozenka^.Focused,Pereozenka^.List^.Count);
                s:=Copy(s,1+CName+1,CArtikul);
                Repeat
                Until (SetNameUnLock(s));
                Pereozenka^.List^.AtFree(Pereozenka^.Focused);
                Pereozenka^.SetRange(Pereozenka^.List^.Count);
                If Pereozenka^.Focused>0 Then Pereozenka^.FocusItem(Pereozenka^.Focused);

             If (Pereozenka^.Focused>=Pereozenka^.List^.Count) and(Pereozenka^.Focused>0) Then
             Pereozenka^.FocusItem(Pereozenka^.Focused-1);

                CalCItogo;
                Redraw;
               End;
              ClearEvent(Event);
            End;

            PrzWindow^.Redraw;
            AddName;
            End;

 cmRefresh:Begin
            PStaticText(ControlRazdel)^.GetText(S);
            System.Delete(S,1,1);
            PrevS[0]:=#0;
            Refresh(s,PrevS);
               ClearEvent(Event);
           End;

  kbCtrLDel: Begin
     If (Pereozenka^.State and sfFocused <> 0) And (Pereozenka^.List<>Nil)And(Pereozenka^.List^.Count>=1) Then
            Begin
             If MessageBox(#3^M+#3'Удалить весь акт переоценки?',nil,mfConfirmation+mfOkCancel)=cmOk Then
             Begin
              UnLockAllNAme;
              Pereozenka^.NewList(nil);
              Pereozenka^.NewList(New(PTextCollection, Init(1,1)));
              CalCItogo;
              AddName;
              PrzWindow^.Redraw;
             End;
            End;
            End;
  kbEnter:    Begin
     If (Baz^.State and sfFocused <> 0) And (Baz^.List<>Nil)And(Baz^.List^.Count>=1) Then
            Begin
     If (Baz^.State and sfFocused <> 0) And (Baz^.List<>Nil)And(Pereozenka^.List^.Count>CMax-1) Then
              Begin
      MessageBox(#3^M+#3'В документе может быть'^M+
                 #3'не более '+ IntToStr(CMax,2)+' наименований !',Nil,mfError+mfCanCelButton);
               ClearEVent(Event);
               Exit;
              End;
              s:=Copy(Baz^.GetText(Baz^.Focused,Baz^.List^.Count),1+CName+1,CArtikul);

              If TestElement(S,Pereozenka) Then
               Begin
                if Not(lockselect) then
                          Begin
                 ClearEvent(Event);
                          Exit;
                 End;
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
              #3'в акте переоценки!',Nil,mfError+mfCanCelButton);
              ClearEVent(Event);
            End
            End;
  kbF5     :Begin
             PStaticText(ControlItogo_R_Zena)^.GetTExt(s);
             If Pos(#3,S)>0 Then System.Delete(s,1,1);
             PStaticText(ControlItogo_O_Zena)^.GetTExt(s1);
             If Pos(#3,S1)>0 Then System.Delete(s1,1,1);
             s:=' Переоценка по Р/Ц:'+s+'  по О/Ц:'+S1;
             {Вставить номер и дату документа в просмотре}

              Begin
               PStaticText(ControlDocNum)^.GetTExt(sdoc);
               If Pos(#3,sdoc)>0 Then System.Delete(sdoc,1,1);
               SDate:=FDate;
              End;

             FullScreen(Pereozenka,'~Н~аименование               Код   Колич Р/Цена   О/Цена   Р/Цена   О/Цена  ',s,
             SDoc,SDate,0);
            End;
   kbAlt1 : if Password(4) Then UnlockAll;
      kbF4: Begin
            If (Event.KeyCode=kbF4)And(Pereozenka^.State and sfFocused <> 0) And (Pereozenka^.List<>Nil)
               And (Pereozenka^.List^.Count>=1)  Then
            Begin
              s:=Pereozenka^.GetText(Pereozenka^.Focused,Pereozenka^.List^.Count);
              Car^.Ini(s,1);
              CalcItogo;
              Redraw;
              ClearEvent(Event);
            End;
              ClearEvent(Event);
            Redraw;
            End;
     kbEsc: Begin
              Event.What:=evCommand;
              Event.Command:=cmCancel;
              PutEvent(Event);
            End;
      Else;
      End;{KeyDown}
  evCommand :
     Case Event.Command Of
 cmAbout: Begin
  AboutCHM('88');
  ClearEvent(Event);
  end;

 cmRefresh:Begin
            PStaticText(ControlRazdel)^.GetText(S);
            System.Delete(S,1,1);
            PrevS[0]:=#0;
            Refresh(s,PrevS);
           End;
     cmPereozen: Begin
                 ClearEvent(Event);
                End;
     cmOk : Begin
             If (Pereozenka^.List<>Nil)And(Pereozenka^.List^.Count>0) Then
             Begin
             PStaticText(ControlItogo_R_Zena)^.GetTExt(s);
             If Pos(#3,S)>0 Then System.Delete(s,1,1);
             PStaticText(ControlItogo_O_Zena)^.GetTExt(s1);
             If Pos(#3,S1)>0 Then System.Delete(s1,1,1);
             s:=' Переоценка по Р/Ц:'+s+'  по О/Ц:'+S1;
             {Вставить номер и дату документа в просмотре}
              Begin
               PStaticText(ControlDocNum)^.GetTExt(sdoc);
               If Pos(#3,sdoc)>0 Then System.Delete(sdoc,1,1);
               SDate:=FDate;
              End;

       If FullScreen(Pereozenka,'~Н~аименование               Код   Колич Р/Цена   О/Цена   Р/Цена   О/Цена  ',s,
       SDoc,SDate,1) Then
                Begin
                 L:=False;
                 SaveToFile(L);
                 If L Then
                 Begin
                 Event.What:=evCommand;
                 Event.Command:=cmClose;
                 PutEvent(Event);
                 ClearEvent(Event);
                 Status:=DocNormal;
                 TekDate := FDate;
                 End
                 Else ClearEvent(Event);
                End;
             End;
            End;
      cmCancel : Begin
               l:=False;
               If (Pereozenka^.List<>Nil)And(Pereozenka^.List^.Count>0) Then
If MessageBox(#3^M+#3'Желаете отказаться от переоценки ?',Nil,mfConFirmation+mfOkCancel)<>cmOk
             Then
               Begin
                l:=True;
               End;
               If Not(L) Then
                 Begin
                 UnLockAllNAme;

                 PStaticText(ControlDocNum)^.GetText(sdoc);
                 If Pos(#3,sdoc)>0 Then System.Delete(sdoc,1,1);
                 DelSpace(SDoc);
{
                 Repeat
                 Until (FreeDocNumer(DocPereozen,TekDate,SDoc));
}

                 Event.What:=evCommand;
                 Event.Command:=cmClose;
                 PutEvent(Event);
                 Status:=DocNormal;
                 TekDate := FDate;
                End;
                 ClearEvent(Event);
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
     Refresh(s,PrevS);
     ClearEvent(Event);
  End;
  End;
      Else;
      End;{evCommand}
      Else;
      End;{*Case*}
  if (Event.What = evBroadcast) and
    (Event.Command = cmPereozen) then ClearEvent(Event);

 If (PView(Rz)<>Desktop^.TopView)And(ControlRazdel^.State and sfFocused <> 0)
 And (Event.Command<>cmSelectRazdel)Then
            Begin
             Event.What:=EvCommand;
             Event.Command:=cmSelectRazdel;
             PutEvent(Event);
             ClearEvent(Event);
            End;


  inherited HandleEvent(Event);

 If (Desktop^.Current=PView(PrzWindow)) And (Event.What <> EvKeyDown) Then
           Begin
             DrawFullName;
           End;



end;



End.
