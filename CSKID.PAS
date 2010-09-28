{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}

Unit CSkid;

Interface


Uses Dialogs,Drivers,Glob,Access,ServStr,MyCalc;

Type TSkidkaArray = Array[1..6] Of String[CLitr+1];
Type TZenaArray = Array[1..CShkala] Of String[CZena];

Type
  PZenaSkidWindow = ^TZenaSkidWindow;
  TZenaSkidWindow = object(TDialog)
   Calc        : PMyCalculator;
    Procedure Ini(Ar:ArtikulStr;Zena_Z,Zena_R,Zena_O:TDAteString;Var SP:TSkidkaArray);
    Procedure RefreshSkid;
    procedure PereshetZen(s: TDateString);
    procedure HandleEvent(var Event: TEvent); virtual;
    Destructor Done;Virtual;
  end;

Type
  PCartSkidWindow = ^TCartSkidWindow;
  TCartSkidWindow = object(TDialog)
    ZZ : PZenaSkidWindow;
    Calc        : PMyCalculator;
    Procedure Ini(s:TMyString);
    procedure HandleEvent(var Event: TEvent); virtual;
    Destructor Done;Virtual;
  end;



Type
  PSkidWindow = ^TSkidWindow;
  TSkidWindow = object(TDialog)
    Rz  : PRazdelWindow;
    Car : PCartSkidWindow;
    Nam : PNameWindow;
    constructor Init(Var l: Boolean);
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure OpenSkidWindow;
    procedure DrawCurrent;
  end;

 Implementation

uses DBEngine,Objects, Views, MsgBox,Protect,
        App, ColorTxt,Serv,InpLong,Validate,Net,NetCall,WinDos,NetDbEng;

var
 ZenaWin : PZenaSkidWindow;
 CartWinSkid : PCartSkidWindow;
 SkidWindow : PSkidWindow;
 ControlZena,ControlNAzenka,ControlProz : Array [1..{CShkala}6] Of PView;
 ControlGetSkidka,ControlRazdel,
 ControlModifyTime,ControlModifyDate,ControlOperator: PView;
 PrevCur,PrevS : AllStr;
 SArtikul : artikulstr;
 InPut : PSkidkaType1;
 Input1 : PSkidkaType;

 TempSkidProz,skidproz:TSkidkaArray;
 GZ,GR : String[CZena];
 Region : Word;
 SRegion : AllStr;



Procedure TCartSkidWindow.Ini(s:TMyString);
Label 1;
var
  R : TRect;
  c,l: Word;
  Control : PView;
  SZakupka,SRZena,SName,SLitr,SKol,SSertif,SAkzis,SInPack: String[CAll];
  f : File Of SkidkaType;
  skf : SkidkaType;
  Enable:Boolean;
  s1,s2 : String;
  j : word;

Begin

Enable:=False;
SName:=Copy(S,1,CName);
SArtikul:=Copy(S,1+CName+1,Cartikul);


If Not Password(3) Then
Begin
 Repeat
 Until SetNameUnLock(SArtikul);
Exit;
End
Else
 Enable:=True;



Region:=0;
Region:=SelectRegion(False);
If Not (Region in [0..3]) Then
Begin
 Repeat
 Until SetNameUnLock(SArtikul);
Exit;
End;

Case Region Of
0:sregion:='Офис';
1:sregion:='Город';
2:sregion:='Область';
3:sregion:='Резерв';
Else;
End;



SLitr:=GetIdField(FLitr,SArtikul);
SInPack:=GetIdField(FInPack,SArtikul);
SRZena:=BAkGetField(FRZena,SArtikul,0);
SZakupka:=BAkGetField(FZakupka,SArtikul,0);




New(Input1,Init);

New(Input,Init);

GetSkidka(SArtikul,Input1^.Dat);




  s2[0]:=#0;
  j:=1;

  For c:=1+Round(6*Region) To (6*Region+6) Do
   Begin
    s2:=s2+'Цена '+IntToStr(c,CMAntissa){Input^.Dat.Skidka[c].Up}
    +'-'+Input1^.Dat.Skidka[c].Proz+';';
    InPut^.Dat.Skidka[j].Up:=Input1^.Dat.Skidka[c].Up;
    InPut^.Dat.Skidka[j].Proz:=Input1^.Dat.Skidka[c].Proz;
    InPut^.Dat.Skidka[j].MinNaz:=Input1^.Dat.Skidka[c].MinNaz;
    Inc(j);
   End;


1:
AInfo('Читаю информацию о скидках...');
R.Assign(0, 7, 52, 18);
New(CartWinSkid, Init(R, 'Таблица скидок -"'+SRegion+'"'));
CartWinSkid^.Palette := dpCyanDialog;
CartWinSkid^.HelpCtx := $E015;
CartWinSkid^.Options := CartWinSkid^.Options or ofCenterX;


For c:=1 To 6{11} Do
Begin
R.Assign(10, 3+c, 28, 4+c);
Control := New(PInputLine, Init(R, CIZena));

CartWinSkid^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));

R.Assign(29, 3+c, 37, 4+c);
Control := New(PInputLine, Init(R, CLitr+1));
CartWinSkid^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));


R.Assign(38, 3+c, 46, 4+c);
Control := New(PInputLine, Init(R, CLitr+1));
CartWinSkid^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));
End;

R.Assign(1, 1, 50, 4);
Control := New(PStaticText, Init(R, 'Наименование:'+SNAme+' Код:'+SArtikul+^M+' Литраж:'+SLitr+' Фас:'+SInPAck+
' З/Цена: '+SZakupka+'  Р/Цена:'+SRZena));
CartWinSkid^.Insert(Control);


{CartWinSkid^.SetData(Input);}

CartWinSkid^.SelectNext(False);

CartWinSkid^.SetData(Input^.Dat.Skidka);

NoInfo;
c:=Desktop^.ExecView(CartWinSkid);
If c<>cmCancel Then
 Begin
  Dispose(Control,Done);
  CArtWinSkid^.GetData(Input^.Dat.Skidka);
  {переприсваивание }

  j:=1;
  For c:=1+Round(6*Region) To (6*Region+6) Do
   Begin
    InPut1^.Dat.Skidka[c].Up:=Input^.Dat.Skidka[j].Up;
    InPut1^.Dat.Skidka[c].Proz:=Input^.Dat.Skidka[j].Proz;
    InPut1^.Dat.Skidka[c].MinNaz:=Input^.Dat.Skidka[j].MinNaz;
    Inc(j);
   End;

  For c:=1 To CShkala Do
   Begin
    {If Abs(StrToReal(Input1^.Dat.Skidka[c].Up))<0.01 Then
	 Begin
	  Input1^.Dat.Skidka[c].Proz:='1.0000';
      End;}
      MyStr(StrToReal(Input1^.Dat.Skidka[c].Up),CIZena,CMantissa,Input1^.Dat.Skidka[c].Up);
      DelSpace(Input1^.Dat.Skidka[c].Up);
      MyStr(StrToReal(Input1^.Dat.Skidka[c].Proz),CLitr+1,CMantissa+2,Input1^.Dat.Skidka[c].Proz);
      DelSpace(Input1^.Dat.Skidka[c].Proz);
      MyStr(StrToReal(Input1^.Dat.Skidka[c].MinNaz),CLitr+1,CMantissa+2,Input1^.Dat.Skidka[c].MinNaz);
      DelSpace(Input1^.Dat.Skidka[c].MinNaz);
   End;

  For c:=1 To 6 Do
   Begin
     If Abs(StrToReal(Input1^.Dat.Skidka[c].Up))<0.01 Then
	 Begin
	  Input1^.Dat.Skidka[c].Proz:='1.0000';
      End;
      MyStr(StrToReal(Input1^.Dat.Skidka[c].Up),CIZena,CMantissa,Input1^.Dat.Skidka[c].Up);
      DelSpace(Input1^.Dat.Skidka[c].Up);
      MyStr(StrToReal(Input1^.Dat.Skidka[c].Proz),CLitr+1,CMantissa+2,Input1^.Dat.Skidka[c].Proz);
      DelSpace(Input1^.Dat.Skidka[c].Proz);
      MyStr(StrToReal(Input1^.Dat.Skidka[c].MinNaz),CLitr+1,CMantissa+2,Input1^.Dat.Skidka[c].MinNaz);
      DelSpace(Input1^.Dat.Skidka[c].MinNaz);

    For l:=1 To 6 Do
     Begin
      If (StrToReal(Input1^.Dat.Skidka[c].Up)=StrToReal(Input1^.Dat.Skidka[l].Up))
         And (c<>l) And (StrToReal(Input1^.Dat.Skidka[c].Up)<>0)
         And (StrToReal(Input1^.Dat.Skidka[c].Proz)<>StrToReal(Input1^.Dat.Skidka[l].Proz)) Then
         Begin
          Dispose(CartWinSkid,Done);
          MessageBox(#3^M+#3'Дублирование границы шкалы скидок!',Nil,mfError+mfCancelButton);
          Goto 1;
         End;
     End;

    If StrToReal(Input1^.Dat.Skidka[c].Proz)>99.99 Then
     Begin
      Dispose(CartWinSkid,Done);
      MessageBox(#3^M+#3'Скидка не может превышать 99.99%!',Nil,mfError+mfCancelButton);
      Goto 1;
     End;
   End;


   If Not(SortSkidka(Input1)) Then
   MessageBox(#3^M+#3'Ошибка при сортировке скидок!',Nil,mfError+mfCancelButton);


   s1[0]:=#0;


  For c:=1+Round(6*Region) To (6*Region+6) Do
   Begin
    s1:=s1+'Цена '+IntToStr(c,CMAntissa){Input^.Dat.Skidka[c].Up}
    +'-'+Input1^.Dat.Skidka[c].Proz+';';
   End;

   Input1^.Dat.Time:=Times;
   Input1^.Dat.Date:=FDate;
   Input1^.Dat.Caption:=CurrentPassword;
   SName:=Copy(SArtikul,1,CRazdelKod);
   Assign(f,Path.ToSkidki+SName+'.skl');
   c:=IOResult;
   Reset(f);
   c:=IOResult;
   If c<>0 Then
   Begin
    Repeat
    Until SetNameUnLock(SArtikul);
    Dispose(CartWinSkid,Done);
    Dispose(Input,Done);
    Dispose(Input1,Done);
    MessageBox(#3^M+#3'Ошибка доступа к файлу '+SName+'.skl!',Nil,mfError+mfCancelButton);
    Exit;
   End;
   sName:=Copy(SArtikul,CRazdelKod+1,CKod);
   Seek(f,GetFileLocation3(sNAme));
   Repeat
    Pause(1);
   Until NetCall.Lock(f,FilePos(f)*SizeOf(SkidkaType),SizeOf(SkidkaType));


   Read(f,skf);
   For c:=1 To CShkala Do Skf.Skidka[c]:=Input1^.Dat.Skidka[c];
   skf.Date:=FDate;
   skf.Time:=Times;
   skf.Caption:=CurrentPassword;
   Seek(f,FilePos(f)-1);
   Write(f,skf);

   Seek(f,FilePos(f)-1);
   Repeat
    NetCall.UnLock(f,FilePos(f)*SizeOf(SkidkaType),SizeOf(SkidkaType));
   Until (DosError=0);

   System.Close(f);



   If s2<>s1 Then
   AddProtocol('Коррекция скидок у '+GetIdField(FName,SArtikul)+' ('+SArtikul+') {!Скидки! напрямую}',
   'Было:'+s2,
   'Стал:'+s1);
   PrevCur[0]:=#0;
   Dispose(CartWinSkid,Done);
   Dispose(Input,Done);
   Dispose(Input1,Done);
 End
 Else
 Begin
  Dispose(Control,Done);
  Dispose(CartWinSkid,Done);
  Dispose(Input,Done);
  Dispose(Input1,Done);
 End;

 Repeat
 Until SetNameUnLock(SArtikul);


End;

Destructor TCartSkidWinDow.Done;
Begin
TDialog.Done;
End;


procedure TCartSkidWindow.HandleEvent(var Event: TEvent);
VAr s:String;
    InPut2 : PSkidkaType1;
    c : Word;
    SkidProz1 :TSkidkaArray;
    MinNaz1 :TSkidkaArray;
    sz,sr,so : String[CZena];

procedure Calculator;
begin
  Calc^.Start;
end;

Begin
  Case Event.What Of
 evCommand :
   Case Event.Command Of
        cmLocalCalc:Begin Calculator; ClearEvent(Event);End;

        cmTest :Begin
                 New(Input2,Init);
                 CartWinSkid^.GetData(Input^.Dat.Skidka);

                 For c:=1 To 6 Do
                 Begin
                  SkidProz1[c]:=Input^.Dat.Skidka[c].Proz;
                  MinNaz1[c]:=Input^.Dat.Skidka[c].MinNaz;
                 End;

SZ:=BakGetField(FZakupka,SArtikul,0);
MyStr(StrToReal(SZ),CZena,CMantissa,SZ);
SR:=BakGetField(FRZena,SArtikul,0);
MyStr(StrToReal(SR),CZena,CMantissa,SR);
SO:=BakGetField(FOZena,SArtikul,0);
MyStr(StrToReal(SO),CZena,CMantissa,SO);

	            ZZ^.Ini(SArtikul,SZ,SR,SO,SkidProz1);

                 For c:=1 To 6 Do
                 Begin
                  Input2^.Dat.Skidka[c].Proz:=SkidProz1[c];
                  DelSpace(Input2^.Dat.Skidka[c].Proz);
                  Input2^.Dat.Skidka[c].MinNaz:=MinNaz1[c];
                  DelSpace(Input2^.Dat.Skidka[c].MinNaz);
                  Input2^.Dat.Skidka[c].Up:=Input^.Dat.Skidka[c].Up;
                 End;
                 CartWinSkid^.SetData(Input2^.DAt.Skidka);
                 Dispose(Input2,Done);

			  ClearEvent(Event);
			 End;
   Else;
   End;
  Else;
  End;

Inherited HandleEvent(Event);

End;


Procedure TZenaSkidWindow.Ini(Ar:ArtikulStr;Zena_Z,Zena_R,Zena_O:TDAteString;Var SP:TSkidkaArray);
Label 1;
var
  R : TRect;
  c,l: Word;
  Control : PView;
  SZakupka,SName,SLitr,SKol,SOZena,SRZena: String[CAll];
  f : File Of SkidkaType;
  skf : SkidkaType;
  ZenaMas : TZenaArray;

Begin
{c1:=SelectRegion;
If c1=4 Then Exit;}

SName:=GetIdField(FName,ar);
DelSpaceRight(SNAme);
DelSpace(Zena_Z);
DelSpace(Zena_R);
DelSpace(Zena_O);
SZakupka:=Zena_Z{BakGetField(FZakupka,Ar,0)};
GZ:=Zena_Z;
MyStr(StrToReal(SZakupka),CZena,CMantissa,SZakupka);
SRZena:=Zena_R{BakGetField(FRZena,Ar,0)};
GR:=Zena_R;
MyStr(StrToReal(SRZena),CZena,CMantissa,SRZena);
SOZena:=Zena_O{BakGetField(FOZena,Ar,0)};
MyStr(StrToReal(SOZena),CZena,CMantissa,SOZena);


For c:=1 To 6 Do
 Begin
  MyStr(StrToReal(SRZena)*StrToReal(SP[c]),CZena,CMantissa,ZenaMas[c]);
  DelSpace(ZenaMas[c]);
  MyStr(StrToReal(SP[c]),CLitr+1,CMantissa+2,SP[c]);
  DelSpace(SP[c]);
 End;




1:

AInfo('Читаю информацию о скидках...');

R.Assign(15, 2, 65, 15);
New(ZenaWin, Init(R, 'Шкала цен - "'+SRegion+'"'));
ZenaWin^.Options := ZenaWin^.Options or ofCenterX or ofCenterY;
ZenaWin^.Palette := dpCyanDialog;
ZenaWin^.HelpCtx := $E195;

For c:=1 To 6 Do
 Begin
  R.Assign(10, 5+c, 20, 6+c);
  ControlZena[c] := New(PInputLine, Init(R, CZena));
  ZenaWin^.Insert(ControlZena[c]);
  PInputLine(ControlZena[c])^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));

  R.Assign(1, 5+c, 10, 6+c);
  ZenaWin^.Insert(New(PLabel, Init(R, 'Цена '+IntToStr(c,CMantissa)+':', ControlZena[c])));

  R.Assign(21, 5+c, 28, 6+c);
  ControlProz[c] := New(PStaticText, Init(R, #3+SP[c]));
  ZenaWin^.Insert(ControlProz[c]);


  R.Assign(30, 5+c, 40, 6+c);
  ControlNAzenka[c] := New(PStaticText, Init(R, #3+'0.000'));
  ZenaWin^.Insert(ControlNAzenka[c]);
 End;




(*
For c:=1 To 6{11} Do
Begin
R.Assign(10, 3+c, 28, 4+c);
Control := New(PInputLine, Init(R, CIZena));

CartWinSkid^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));

R.Assign(29, 3+c, 37, 4+c);
Control := New(PInputLine, Init(R, CLitr+1));
CartWinSkid^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));
End;
*)




R.Assign(1, 1, 27, 2);
Control := New(PColoredText, Init(R, #3+SName, $31));
ZenaWin^.Insert(Control);
{
R.Assign(19, 5, 27, 6);
Control := New(PColoredText, Init(R, 'Скидка,%', $31));
ZenaWin^.Insert(Control);
}
R.Assign(1, 2, 27, 5);
Control := New(PColoredText, Init(R, ' Закупочная цена:'+SZakupka+^M+
     'Розничная цена :'+SRZena+''^M+
     'Оптовая цена   :'+SOZena, $3E));
ZenaWin^.Insert(Control);


R.Assign(21, 5, 40, 6);
Control := New(PColoredText, Init(R, 'Коэф.   Наценка,%', $3E));
ZenaWin^.Insert(Control);


ZenaWin^.SelectNext(False);
ZenaWin^.SetData(ZenaMas);
RefreshSkid;
NoInfo;

c:=Desktop^.ExecView(ZenaWin);

If c<>cmCancel Then
 Begin
  ZenaWin^.GetData(ZenaMas);
  For c:=1 To 6 Do
   Begin
    If (StrToReal(TempSkidProz[c]))<0 Then
     Begin
      MessageBox(^M+#3+'Недопустимая велечина скидки в колонке '+IntToStr(c,CMAntissa)+'!'^M+
	 #3+'Отрицательная скидка!',
                 Nil,mfError+mfCancelButton);
      Dispose(Control,Done);
      Dispose(ZenaWin,Done);
      Goto 1;
     End;

    If (StrToReal(TempSkidProz[c]))>99.9 Then
     Begin
      MessageBox(^M+#3+'Недопустимая велечина скидки в колонке '+IntToStr(c,CMAntissa)+'!',
                 Nil,mfError+mfCancelButton);
      Dispose(Control,Done);
      Dispose(ZenaWin,Done);
      Goto 1;
     End;

    If StrToReal(ZenaMas[c])<StrToreal(SZakupka) Then
     Begin
      SpecialBeep;
      MessageBox(^M+#3'Продажная цена ниже закупочной в колонке '+IntToStr(c,COne)+'!',Nil,mfError+mfCancelButton);
      Dispose(Control,Done);
      Dispose(ZenaWin,Done);
      Goto 1;
     End;
    DelSpace(TempSkidProz[c]);
   End;

  For c:=1 To 6 Do SP[c]:=TempSkidProz[c];

   Dispose(Control,Done);
   Dispose(ZenaWin,Done);
 End
 Else
 Begin
  Dispose(Control,Done);
  Dispose(ZenaWin,Done);
 End;


End;

Destructor TZenaSkidWinDow.Done;
VAr C: Word;
Begin
  For c:=1 To 6 Do
   Begin
    Dispose(ControlZena[c],Done);
    Dispose(ControlProz[c],Done);
    Dispose(ControlNazenka[c],Done);
   End;
TDialog.Done;
End;


Function CorrectZeni (Var s : TDAteString): Boolean;
var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  c : Word;
begin
s[0]:=#0;
CorrectZeni:=False;
R.Assign(32, 8, 48, 13);
New(Dlg, Init(R, ''));
Dlg^.Options := Dlg^.Options or ofCenterX;
Dlg^.HelpCtx := $E002;

R.Assign(2, 2, 14, 3);
Control := New(PInputLine, Init(R, 9));
PInputLine(Control)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));

Dlg^.Insert(Control);

Dlg^.SelectNext(False);
c:=Desktop^.ExecView(DLG);
If c<>cmCAncel Then
 Begin
  Dlg^.GetDAta(s);
  CorrectZeni:=True;
  DelSpace(s);
 End;
Dispose(Control,Done);
Dispose(Dlg,Done);
end;



procedure TZenaSkidWinDow.RefreshSkid;
VAr C: Word;
    R : TRect;
  ZenaMas : TZenaArray;
    SZakupka,SRZena : AllStr;
    Nazenka : Array [1..6] Of String[CLitr+1];
Begin
  ZenaWin^.GetData(ZenaMas);
  SZakupka:=GZ;
  SRZena  :=GR;

For c:=1 To 6 Do
 Begin
    MyStr(StrToReal(ZenaMas[c]),CZena,CMantissa,ZenaMas[c]);

    If Abs(StrToReal(SRZena))<0.01 Then
     Begin
      TempSkidProz[c]:='1.0000';
      Nazenka[c]:='??.???';
     End
    Else
    Begin
    MyStr((StrToReal(ZenaMas[c])/StrToReal(SRZena)),CLitr+1,CMantissa+2,TempSkidProz[c]);
    If Abs(StrToReal(SZakupka))<0.01 Then
     Begin
      Nazenka[c]:='??.???';
     End
     Else
     MyStr(((StrToReal(ZenaMas[c])-StrToReal(SZakupka))/StrToReal(SZakupka))*100,CLitr+1,CMantissa+2,Nazenka[c]);
    End;

  Dispose(ControlProz[c],Done);

  R.Assign(21, 5+c, 28, 6+c);
  ControlProz[c] := New(PStaticText, Init(R, #3+TempSkidProz[c]));
  ZenaWin^.Insert(ControlProz[c]);
  DelSpace(TempSkidProz[c]);

  Dispose(ControlNazenka[c],Done);
  R.Assign(30, 5+c, 40, 6+c);
  ControlNAzenka[c] := New(PStaticText, Init(R, #3+NAzenka[c]));
  ZenaWin^.Insert(ControlNAzenka[c]);


 End;

End;


procedure TZenaSkidWinDow.PereshetZen(s: TDateString);
VAr C: Word;
    R : TRect;
  ZenaMas : TZenaArray;
Begin
  ZenaWin^.GetData(ZenaMas);

For c:=1 To 6 Do
 Begin
    MyStr(StrToReal(ZenaMas[c])*StrToReal(s),CZena,CMantissa,ZenaMas[c]);
    DelSpace(ZenaMas[c]);
 End;

  ZenaWin^.SetData(ZenaMas);


End;




procedure TZenaSkidWindow.HandleEvent(var Event: TEvent);
Var DrawP:Boolean;
    s : TDAteString;

procedure Calculator;
begin
  Calc^.Start;
end;


Begin
  DrawP:=False;

Case Event.What Of
 evKeyDown:Begin
            Case Event.KeyCode Of
            kbGrayPlus:Begin
                        If CorrectZeni(s) Then
                        PereshetZen(s);
                        Drawp:=True;
                       End;
            Else;
            End;
           End;
 evCommand :
   Case Event.Command Of
        cmLocalCalc:Calculator;
   Else;
   End;
   Else;
   End;


  If (Event.What=evKeyboard)And((Event.CharCode in ['0','1','2','3','4','5','6','7','8','9','.'])
  Or (Event.KeyCode=kbDel) Or (Event.KeyCode=kbShiftIns) Or (Event.KeyCode=kbBack)) Then Drawp:=True;
Inherited HandleEvent(Event);
  If Drawp Then RefreshSkid;
End;




procedure TSkidWindow.OpenSkidWindow;
Var l : Boolean;
begin
  ClearFind;
  if Message(Desktop, evBroadcast, cmSkidki, nil) = nil then
  begin
    DInfo('Инициализация настройки скидок...');
    L:=True;
    SkidWindow := New(PSkidWindow, Init(L));
    If L Then
    Begin
    Application^.InsertWindow(SkidWindow);
    NoInfo;
    End
    Else
     Begin
      Dispose(SkidWindow,Done);
      NoInfo;
     End;
  end
  else
    if PView(SkidWindow) <> Desktop^.TopView then SkidWindow^.Select;
end;

constructor TSkidWindow.Init(Var l : Boolean);
var
  R : TRect;
  Control : PView;
  C : Word;
  DocumentNumer : TDateString;
  SkladFile : File Of SkladType;
  s: TEnjoyStr;
  ws : TDateString;
  i : Byte;
  SNAme : String[CName];
begin

R.Assign(2, 0, 77, 23);
inherited Init(R, 'Настройка скидок');
Options := Options or ofCenterX or ofCenterY;

L:=False;
TekDAte:=FDate;
{
If Not(TestOpenDate(TekDate)) Then
   Begin
    MessageBox(#3^M+#3+'Доступ к данным за '+TekDate+' заблокирован!',Nil,mfError+mfCancelButton);
    Exit;
   End;
}

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
Razdel^.HelpCtx:=$E001;

PrevS:=Razdel^.GEtText(Razdel^.Focused,Razdel^.List^.COunt);

Dispose(Razdel,Done);


R.Assign(47, 1, 72, 2);
ControlRazdel := New(PColoredText, Init(R, #3+PrevS, $1F));
ControlRazdel^.Options := ControlRazdel^.Options or ofSelectable;
Insert(ControlRazdel);

R.Assign(39, 1, 47, 2);
Insert(New(PLabel, Init(R, 'Ра~з~дел:',ControlRazdel)));

R.Assign(71, 2, 72, 18);
Control := New(PScrollBar, Init(R));
Insert(Control);

R.Assign(3, 2, 71, 18);
Baz := New(PBox, Init(R, 2, PScrollbar(Control)));
Baz^.NewList(New(PTextCollection, Init(1,1)));
c:=Pos('│',PrevS);
PrevS:=Copy(Prevs,c+1,CArtikul);
If Prevs[0]<>#0 Then
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
{  If GetIdEmploy(BazElement.BazKod) Then}
  If (BazElement^.Dat.Employ)Then
   Begin
    SName := GetIdField(FName,BazElement^.Dat.BazKod);
    Format(SName,CName);
    Baz^.List^.Insert(NewStr(SNAme+'│'+BazElement^.Dat.BazKod));
    Baz^.SetRange(Baz^.List^.Count);
   End;
 End;
System.Close(BazFile);
 End;
Baz^.FocusItem(0);
Baz^.HelpCtx:=$E166;
Insert(Baz);

SArtikul:=Copy(Baz^.GetText(Baz^.Focused,Baz^.List^.Count),1+CName+1,CArtikul);

  R.Assign(3, 1, 35, 2);
  Insert(New(PLabel, Init(R, '~Н~аименование товара         Код', Baz)));

R.Assign(8, 0, 16, 1);
Control := New(PColoredText, Init(R, FDate, $7E));
Insert(Control);

R.Assign(2, 0, 8, 1);
Control := New(PColoredText, Init(R, ' Дата:', $74));
Insert(Control);

R.Assign(47, 0, 54, 1);
Control := New(PColoredText, Init(R, ' Склад:', $74));
Insert(Control);

R.Assign(54, 0, 73, 1);
Control := New(PColoredText, Init(R, #3+GetClientField(FClient,Rek.Kod,1), $7E));
Insert(Control);

R.Assign(44, 20, 51, 21);
Control := New(PColoredText, Init(R, 'Операт:', $74));
Insert(Control);

R.Assign(51, 20, 63, 21);
ControlOperator := New(PColoredText, Init(R, CurrentPassword, $7E));
Insert(ControlOperator);

R.Assign(13, 20, 18, 21);
Control := New(PColoredText, Init(R, 'Дата:', $74));
Insert(Control);

R.Assign(18, 20, 26, 21);
ControlModifyDate := New(PColoredText, Init(R, '', $7E));
Insert(ControlModifyDate);

R.Assign(28, 20, 34, 21);
Control := New(PColoredText, Init(R, 'Время:', $74));
Insert(Control);

R.Assign(34, 20, 42, 21);
ControlModifyTime := New(PColoredText, Init(R, '', $7E));
Insert(ControlModifyTime);

R.Assign(1, 18, 74, 20);
ControlGetSkidka := New(PColoredText, Init(R,#3'', $7E));
Insert(ControlGetSkidka);

SelectNext(False);

DrawCurrent;
L:=True;
PrevS[0]:=#0;
PrevCur[0]:=#0;
end;


procedure TSkidWindow.HandleEvent(var Event: TEvent);
Var test,IO : Word;
    s,s1 : String;
    l : Boolean;
    SName : String[CName];
    Art   : ArtikulStr;

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
               If s <> PrevS Then
                 Begin
                  DInfo('Читаю список товаров...');
                  PrevS:=S;
                  s:=Copy(s,1+CRazdel+1,CRazdelKod);
                  Baz^.NewList(nil);
                  Baz^.NewList(New(PTextCollection, Init(1,1)));
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
{                    If GetIdEmploy(BazElement.BazKod) Then}
                    If (BazElement^.Dat.Employ) Then
                     Begin
                      SName:=GetIdField(FName,BazElement^.Dat.BazKod);
                      Format (SName,CName);
                      Baz^.List^.Insert(NewStr(SNAme+'│'+BazElement^.Dat.BazKod));
                      Baz^.SetRange(Baz^.List^.Count);
                     End;
                   End;
                  System.Close(BazFile);
                  End
                  Else
                  Begin
                   MessageBox(^M+#3+'Отказано в доступе к '+Path.ToSklad+s+'.db',Nil,mfError+mfCancelButton);
                   PrevS[0]:=#0;
                  End;

                  Baz^.FocusItem(0);
                  PrevCur[0]:=#0;
                  NoInfo;
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
   cl^.Dat.Locked:=False;
   cl^.Dat.LockCAption[0]:=#0;
   Seek(f,FilePos(f)-1);
   Write(f,cl^.Dat);
  End;
System.close(f);
Dispose(cl,Done);
NoInfo;
End;


begin

  Case Event.What Of
  evKeyDown :
  Case Event.KeyCode Of
     kbDel: Begin
If Not(TestOpenDate1(FDAte)) Then
   Begin
    MessageBox(#3^M+#3'Доступ к данным за '+TekDate+' заблокирован!',Nil,mfError+mfCancelButton);
    ClearEvent(Event);
    Exit;
   End;

{Удаление товара со склада}
     If Password(3) Then
     If (Baz^.State and sfFocused <> 0) And (Baz^.List<>Nil)And(Baz^.List^.Count>=1) Then
            Begin
             If MessageBox(#3+DelBazName,nil,mfConfirmation+mfOkCancel)=cmOk
              Then
              Begin
               test := IOResult;
               s:=Baz^.GetText(Baz^.Focused,Baz^.List^.Count);
               s:=Copy(s,1+CName+1,Cartikul);
               Art:=s;

               If Not(LockSelect) Then
                        Begin
                ClearEvent(Event);
                         exit;
               End;

                If DelNameFromDB(s) Then
                Begin
                 Baz^.List^.AtFree(Baz^.Focused);
                 Baz^.SetRange(Baz^.List^.Count);
                 If (BAz^.Focused>=BAz^.List^.Count) and(Baz^.Focused>0) Then
                 Baz^.FocusItem(Baz^.Focused-1);
                 AddProtocol('Удаление наименования:'+s+' '+GetIdField(FName,s),'','')
                End
                 Else
                  Begin
                   s1:=Copy(s,1,CRazdelKod);
                   MessageBox(^m+#3'Ошибка доступа к файлу '+s1+'.Db!',nil,mfError+mfCanCelButton);
                  End;

                Repeat
                Until (SetNameUnLock(Art));


              End
              Else Begin
                    ClearEvent(Event);
                   End;
            ClearEvent(Event);
            End;
            Redraw;
            End;
  kbEnter:
  Begin
If Not(TestOpenDate1(FDate)) Then
   Begin
    MessageBox(#3^M+#3+'Доступ к данным за '+TekDate+' заблокирован!',Nil,mfError+mfCancelButton);
    ClearEvent(Event);
    Exit;
   End;
     If (Baz^.State and sfFocused <> 0) And (Baz^.List<>Nil)And(Baz^.List^.Count>=1) Then
            Begin
               If Not(LockSelect) Then
                         Begin
                         ClearEvent(Event);
                         Exit;
                         End;
             s:=Baz^.GetText(Baz^.Focused,Baz^.List^.Count);
             s:=Copy(s,1+CName+1,Cartikul);
             Art:=s;

             ClearEvent(Event);
                s:=Copy(Baz^.GetText(Baz^.Focused,Baz^.List^.Count),1+CName+1,Cartikul);
                s:=Baz^.GetText(Baz^.Focused,Baz^.List^.Count);
                Car^.Ini(s);
                Redraw;
                ClearEvent(Event);
            End
            End;

kbAlt1 : if Password(4) Then UnlockAll;

kbGrayPlus,kbF4: Begin
If(Baz^.State and sfFocused <> 0)And(Not(Event.KeyCode=kbF4))Or
  ((Event.KeyCode=kbF4)And(Baz^.List<>Nil)And(Baz^.List^.Count>=1)) Then
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
               SName:=GetIdField(FName,BazElement^.Dat.BazKod);
               Format (SName,CName);
               Baz^.List^.Insert(NewStr(SNAme+'│'+BazElement^.Dat.BazKod));
               Baz^.SetRange(Baz^.List^.Count);
               Baz^.FocusItem(LoCation(Baz,BazElement^.Dat.BazKod,ProdagaWindow));
               PrevCur[0]:=#0;
               Art:=BazElement^.Dat.BazKod;
               Redraw;
              End;

            If Event.KeyCode=kbF4 Then
            Begin
               Repeat
               Until (SetNameUnLock(Art));
            End;

              ClearEvent(Event);
            End;
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
     cmSkidki: Begin
                 ClearEvent(Event);
                End;
     cmOk :     Begin
                 Dispose(ControlGetSkidka,Done);
                 Dispose(ControlModifyTime,Done);
                 Dispose(ControlModifyDate,Done);
                 Dispose(ControlOperator,Done);
                 Event.What:=evCommand;
                 Event.Command:=cmClose;
                 PutEvent(Event);
                 ClearEvent(Event);
                 Status:=DocNormal;
                End;
     cmCancel : Begin
                 Dispose(ControlGetSkidka,Done);
                 Dispose(ControlModifyTime,Done);
                 Dispose(ControlModifyDate,Done);
                 Dispose(ControlOperator,Done);
                 Event.What:=evCommand;
                 Event.Command:=cmClose;
                 PutEvent(Event);
                 Status:=DocNormal;
                 ClearEvent(Event);
                End;
 cmRefresh:Begin
            PStaticText(ControlRazdel)^.GetText(S);
            System.Delete(S,1,1);
            PrevS[0]:=#0;
            PrevCur[0]:=#0;
            Refresh(s,PrevS);
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
     PrevS[0]:=#0;
     PrevCur[0]:=#0;
     Refresh(s,Prevs);
     ClearEvent(Event);
  End
 End;
      Else;
      End;{evCommand}
      Else;
      End;{*Case*}
  if (Event.What = evBroadcast) and
    (Event.Command = cmSkidki) then ClearEvent(Event);
 If (PView(Rz)<>Desktop^.TopView)And(ControlRazdel^.State and sfFocused <> 0)
 And (Event.Command<>cmSelectRazdel) And (Event.What <> EvKeyDown)Then
            Begin
             Event.What:=EvCommand;
             Event.Command:=cmSelectRazdel;
             PutEvent(Event);
             ClearEvent(Event);
            End;


  inherited HandleEvent(Event);
  If (Desktop^.Current=PView(SkidWindow)) And (Event.What <> EvKeyDown) Then
             Begin
             if (Baz^.List<>Nil)And(Baz^.List^.Count>=1) Then
              Begin
               s:=Baz^.GetText(Baz^.Focused,Baz^.List^.Count);
               If s <> PrevCur Then
                 Begin
                  PrevCur:=S;
                  DrawCurrent;
                 End;
               End;

             End;

end;


procedure TSkidWindow.DrawCurrent;
VAr S : String;
    R : TRect;
    SKol : TDateString;
Begin
   If (Baz^.List<>Nil)And(Baz^.List^.Count>=1) Then
   Begin
   SArtikul:=Copy(Baz^.GetText(Baz^.Focused,Baz^.List^.Count),1+CName+1,CArtikul);
   S:=GetTextSkidka(SArtikul);
   Dispose(ControlGetSkidka,Done);
   R.Assign(1, 18, 74, 20);
   ControlGetSkidka := New(PColoredText, Init(R, S, $7E));
   Insert(ControlGEtSkidka);

   S:=GetSkidkaOperator(SArtikul);
   Dispose(ControlOperator,Done);
   R.Assign(51, 20, 63, 21);
   ControlOperator := New(PColoredText, Init(R, S, $7E));
   Insert(ControlOperator);

   S:=GetSkidkaDAtes(SArtikul);
   Dispose(ControlModifyDate,Done);
   R.Assign(18, 20, 26, 21);
   ControlModifyDate := New(PColoredText, Init(R, S, $7E));
   Insert(ControlModifyDate);

   S:=GetSkidkaTimes(SArtikul);
   Dispose(ControlModifyTime,Done);
   R.Assign(34, 20, 42, 21);
   ControlModifyTime := New(PColoredText, Init(R, S, $7E));
   Insert(ControlModifyTime);
  End;
End;


End.
