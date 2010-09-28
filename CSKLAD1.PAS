{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}
Unit CSklad;

Interface


Uses Dialogs,Drivers,Glob,Access,Access3,ServStr,MyCalc;

Type
  PCartSkladWindow = ^TCartSkladWindow;
  TCartSkladWindow = object(TDialog)
   Calc        : PMyCalculator;
   GroupWin    : PGroupWindow;
    Procedure Ini(s:TMyString);
    procedure HandleEvent(var Event: TEvent); virtual;
    Destructor Done;Virtual;
  end;


Type
  PSkladWindow = ^TSkladWindow;
  TSkladWindow = object(TDialog)
    Rz  : PRazdelWindow;
    Car : PCartSkladWindow;
    Nam : PNameWindow;
    constructor Init(Var l: Boolean);
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure OpenSkladWindow;
    procedure CalcItogo;
    procedure DrawCurrent;
  end;

Procedure ViewCorrect;
Procedure ViewVozwrat;

 Implementation

uses DBEngine,Objects, Views, MsgBox,{Vision,Calc,}Dos,TpDAte,
     App, ColorTxt,Serv,InpLong,Validate,Tools,Protect,net,NetCall,NetDbEng;

var
 CartWinSklad : PCartSkladWindow;
 SkladWindow : PSkladWindow;
 ControlModifyTime,ControlFullName,
 ControlModifyDate,ControlOperator,ControlDiviSion,
 Control1,Control2,Control3,Control4,Control5,
 Control6,Control7,Control8,ControlRazdel,ControlPost,
 ControlNGroup,
 Control_IO,Control_IR,Control_IL,ControlSertif,ControlAkzis,ControlL,
 ControlOZ,ControlRZ,ControlMake,ControlNDS, ControllNDS,ControlLAkzis,ControlMarket,
 ControlLSertif,ControlLRZ,ControlLKol, COntrolLOZ,ControlPack,
 ControlDSertif,ControlKSertif,ControlPost1,
 ControlNalog : PView;
 PrevS,PrevCur : String;
 SArtikul : String[5];
 UnPack : String[CPack];
 InPut : InputType;


Procedure DrawPack;
Var s: String[CPack];
    R : TRect;
    i : Byte;
Begin
    {CartWinSklad^.GetData(Input);}

  Control1^.GetDAta(Input.DivisionS[1]);
  Control2^.GetDAta(Input.DivisionS[2]);
  Control3^.GetDAta(Input.DivisionS[3]);
  Control4^.GetDAta(Input.DivisionS[4]);
  Control5^.GetDAta(Input.DivisionS[5]);
  Control6^.GetDAta(Input.DivisionS[6]);
  Control7^.GetDAta(Input.DivisionS[7]);
  Control8^.GetDAta(Input.DivisionS[8]);


    InPut.Kol[0]:=#0;
    For i:=1 To CDivision Do
    Str(StrToInt(InPut.DivisionS[i])+StrToInt(Input.Kol),Input.Kol);
    DelSpace(Input.Kol);

    Dispose(ControlLKol,Done);
    R.Assign(8, 6, 13, 7);
    ControllKol := New(PStaticText, Init(R, #3+Input.Kol));
    CartWinSklad^.Insert(ControllKol);

    s:=CalcPack(sArtikul,input.kol);
    DelSpace(s);
    Dispose(ControlPack,Done);
    R.Assign(23, 6, 32, 7);
    ControlPack := New(PColoredText, Init(R, #3+s, $3E));
    CartWinSklad^.Insert(ControlPack);

End;


Procedure DrawOpt;
Var s: String[CPack];
    R : TRect;
Begin
    ControllRZ^.GetData(Input.R_Zena);
    s:=GetIdField(FLitr,sArtikul);
    If StrToReal(Input.R_Zena)+Lizensia*StrToReal(GetIdField(FLitr,sArtikul))> CMaxZena Then
    Begin
    s[0]:=#0;
    COntrolLOZ^.SetData(s);
    End
    Else
    Begin
    Str(StrToReal(Input.R_Zena)+Lizensia*StrToReal(GetIdField(FLitr,sArtikul)):CZena:CMantissa,s);
    DelSpace(S);
    InPut.O_Zena:=S;
    COntrolLOZ^.SetData(Input.O_Zena);
    End;
end;


Procedure TCartSkladWindow.Ini(s:TMyString);
Label 1;
var
  R : TRect;
  c: Word;
  Control : PView;
  Nazenka,SNAlog,WS,SName,SNAme2,SLitr,SKol,SSertif,SAkzis,SInPack: String[CAll];
  St : TMyString;
  PrevInput:InputType;
  NameFile : File Of BazType;
  NameElement : PBazType;
  Test : LongInt;
  NGroup : String[CName+1+CClientKod];
  NewGroupKod: ArtikulStr;

Begin
SName:=Copy(S,1,CName);


SArtikul:=Copy(S,1+CName+1,Cartikul);
SName2:=GetIdField(FName2,SArtikul);
DelSpaceRight(SNAme2);

SLitr:=GetIdField(FLitr,SArtikul);
SNalog:=GetIdField(FNalog,SArtikul);
DelSpace(SNalog);
SInPack:=GetIdField(FInPack,SArtikul);

Input.Zakupka:=BakGetField(FZakupka,SArtikul,0);
Input.Akzis1:=BakGetField(FAkzis,SArtikul,0);
Input.Post:=BakGetField(FPost,SArtikul,0);
{Input.Sertifikat:=BakGetField(FSertif,SArtikul,0);}
Input.NSertif:=BakGetField(FSertif,SArtikul,0);
Input.DSertif:=BakGetField(FDateSertif,SArtikul,0);
Input.KSertif:=BakGetField(FKtoSertif,SArtikul,0);
Input.R_Zena:=BakGetField(FRZena,SArtikul,0);
Input.O_Zena:=BakGetField(FOZena,SArtikul,0);
Input.Kol:=BakGetField(FKol,SArtikul,0);
Input.NGroupKod:=BakGetField(FGroup,SArtikul,0);


NewGroupKod:=Input.NGroupKod;
NGroup:=Input.NGroupKod;

st:=GetGroupField(FName,NewGroupKod);
Format(st,CNAme);
NGroup:=St+'│'+NGroup;



Input.Zakupka:=RealToStr(StrToReal(Input.Zakupka),CZena,CMantissa);
DelSpace(Input.Zakupka);
Input.R_Zena:=RealToStr(StrToReal(Input.R_Zena),CZena,CMantissa);
DelSpace(Input.R_Zena);
Input.O_Zena:=RealToStr(StrToReal(Input.O_Zena),CZena,CMantissa);
DelSpace(Input.O_Zena);

St:='Корректировка склада для кода '+SArtikul+' {Очень важно}'+''^M+
' Было: Р/Цена:'+Input.R_Zena+' О/Ц:'+Input.O_Zena+' З/Ц:'+Input.Zakupka+' По отделениям:';


PrevInPut:=Input;

1:
DelSPace(Input.ZAkupka);
DelSPace(Input.R_Zena);
DelSPace(Input.O_Zena);
DelSPace(Input.Kol);
DelSpaceRight(Input.Post);
DelSpaceRight(Input.NSertif);
DelSpaceRight(Input.DSertif);
DelSpaceRight(Input.KSertif);
DelSpaceRight(Input.Akzis1);

For c:=1 To CDivision Do
  Begin
   Input.DivisionS[c]:=BakGetField(FDiv,SArtikul,c);
   DelSpace(Input.DivisionS[c]);
   st:=St+' '+Input.DivisionS[c];
  End;

AInfo('Читаю информацию о товаре...');
R.Assign(0, 10, 80, 23);
New(CartWinSklad, Init(R, 'Карточка товара'));
CartWinSklad^.Palette := dpCyanDialog;
CartWinSklad^.HelpCtx := $E191;

R.Assign(29, 3, 36, 4);
Control1 := New(PInputLine, Init(R, CKol));
CartWinSklad^.Insert(Control1);
  PInputLine(Control1)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));

  R.Assign(26, 3, 29, 4);
  CartWinSklad^.Insert(New(PLabel, Init(R, '~1~:', Control1)));
Control1^.SetData(Input.DivisionS[1]);



R.Assign(39, 3, 46, 4);
Control2 := New(PInputLine, Init(R, CKol));
CartWinSklad^.Insert(Control2);
  PInputLine(Control2)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));

  R.Assign(36, 3, 39, 4);
  CartWinSklad^.Insert(New(PLabel, Init(R, '~2~:', Control2)));
Control2^.SetData(Input.DivisionS[2]);

R.Assign(49, 3, 56, 4);
Control3 := New(PInputLine, Init(R, CKol));
CartWinSklad^.Insert(Control3);
  PInputLine(Control3)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));

  R.Assign(46, 3, 49, 4);
  CartWinSklad^.Insert(New(PLabel, Init(R, '~3~:', Control3)));
Control3^.SetData(Input.DivisionS[3]);

R.Assign(59, 3, 66, 4);
Control4 := New(PInputLine, Init(R, CKol));
CartWinSklad^.Insert(Control4);
  PInputLine(Control4)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));

  R.Assign(56, 3, 59, 4);
  CartWinSklad^.Insert(New(PLabel, Init(R, '~4~:', Control4)));
Control4^.SetData(Input.DivisionS[4]);

R.Assign(69, 3, 76, 4);
Control5 := New(PInputLine, Init(R, CKol));
CartWinSklad^.Insert(Control5);
  PInputLine(Control5)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));

  R.Assign(66, 3, 69, 4);
  CartWinSklad^.Insert(New(PLabel, Init(R, '~5~:', Control5)));
Control5^.SetData(Input.DivisionS[5]);



R.Assign(29, 5, 36, 6);
Control6 := New(PInputLine, Init(R, CKol));
CartWinSklad^.Insert(Control6);
  PInputLine(Control6)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));

  R.Assign(26, 5, 29, 6);
  CartWinSklad^.Insert(New(PLabel, Init(R, '~6~:', Control6)));
Control6^.SetData(Input.DivisionS[6]);


R.Assign(39, 5, 46, 6);
Control7 := New(PInputLine, Init(R, CKol));
CartWinSklad^.Insert(Control7);
  PInputLine(Control7)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));

  R.Assign(36, 5, 39, 6);
  CartWinSklad^.Insert(New(PLabel, Init(R, '~7~:', Control7)));
Control7^.SetData(Input.DivisionS[7]);

R.Assign(49, 5, 56, 6);
Control8 := New(PInputLine, Init(R, CKol));
CartWinSklad^.Insert(Control8);
  PInputLine(Control8)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));

  R.Assign(46, 5, 49, 6);
  CartWinSklad^.Insert(New(PLabel, Init(R, '~8~:', Control8)));
Control8^.SetData(Input.DivisionS[8]);




R.Assign(45, 6, 78, 7);
ControlNGroup := New(PColoredText, Init(R, #3+NGroup, $1F));
ControlNGroup^.Options := ControlNGroup^.Options Or ofSelectable;
CartWinSklad^.Insert(ControlNGroup);
R.Assign(37, 6, 45, 7);
CartWinSklad^.Insert(New(PLabel, Init(R, 'Гр~у~ппа:', ControlNGroup)));




R.Assign(38, 7, 48, 8);
(*
if strtoint(currentpassword)=0 then
begin*)
ControllNDS := New(PInputLine, Init(R, CZena));
CartWinSklad^.Insert(ControllNDS);
PInputLine(ControllNDS)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));
(*
end
 else
  begin
  ControllNDS := New(PSInputLine, Init(R, CZena));
  ControllNDS^.Options := ControllNDS^.Options and not ofSelectable;
  CartWinSklad^.Insert(ControllNDS);
  PInputLine(ControllNDS)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));
  end;
*)

{
ControlLNDS := New(PInputLine, Init(R, CZena));
CartWinSklad^.Insert(ControlLNDS);
  PInputLine(ControlLNDS)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));
}
 R.Assign(33, 7, 38, 8);
  CartWinSklad^.Insert(New(PLabel, Init(R, '~З~/Ц:', ControlLNDS)));
ControllNDS^.SetData(Input.Zakupka);

R.Assign(53, 7, 63, 8);
ControlLRZ := New(PInputLine, Init(R, CZena));
CartWinSklad^.Insert(ControlLRZ);
  PInputLine(ControlLRZ)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));

  R.Assign(48, 7, 53, 8);
  CartWinSklad^.Insert(New(PLabel, Init(R, '~Р~/Ц:', ControlLRZ)));
ControlLRZ^.SetData(Input.R_Zena);

R.Assign(68, 7, 78, 8);
ControlLOZ := New(PInputLine, Init(R, CZena));
CartWinSklad^.Insert(ControlLOZ);
  PInputLine(ControlLOZ)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));

  R.Assign(63, 7, 68, 8);
  CartWinSklad^.Insert(New(PLabel, Init(R, '~О~/Ц:', ControlLOZ)));
ControlLOZ^.SetData(Input.O_Zena);


{
R.Assign(13, 6, 79, 7);
ControlLSertif := New(PInputLine, Init(R, CSertif));
CartWinSklad^.Insert(ControlLSertif);

  R.Assign(1, 6, 13, 7);
  CartWinSklad^.Insert(New(PLabel, Init(R, '~С~ертификат:', ControlLSertif)));
}

(*
R.Assign(7, 6, 33, 7);
ControlLSertif := New(PInputLine, Init(R, CNSertif));
CartWinSklad^.Insert(ControllSertif);
  PInputLine(ControllSertif)^.Validator :=
  New(PPXPictureValidator, Init('[росс.][РОСС.][@@@@@@@@@@@@@@@@@@@@@@@@@@@@]', True));

  R.Assign(1, 6, 7, 7);
  CartWinSklad^.Insert(New(PLabel, Init(R, '~С~ерт:', ControllSertif)));

R.Assign(39, 6, 49, 7);
Control := New(PInputLine, Init(R, CDSertif));
CartWinSklad^.Insert(Control);
  PInputLine(Control)^.Validator := New(PPXPictureValidator, Init('[##-##-##]', True));

  R.Assign(33, 6, 39, 7);
  CartWinSklad^.Insert(New(PLabel, Init(R, 'Срок:', Control)));

R.Assign(56, 6, 79, 7);
Control := New(PInputLine, Init(R, CKSertif));
CartWinSklad^.Insert(Control);

  R.Assign(49, 6, 56, 7);
  CartWinSklad^.Insert(New(PLabel, Init(R, 'Выдан:', Control)));

R.Assign(13, 7, 79, 8);
ControlLAkzis := New(PInputLine, Init(R, CAkzis));
CartWinSklad^.Insert(ControlLAkzis);

{
  R.Assign(6, 3, 13, 4);
  CartWinSklad^.Insert(New(PLabel, Init(R, '~А~кциз:', ControlLAkzis)));
}

  R.Assign(1, 7, 13, 8);
  CartWinSklad^.Insert(New(PLabel, Init(R, '~П~римечание:', ControlLAkzis)));



R.Assign(34, 8, 54, 9);
Control := New(PInputLine, Init(R, CPost));
CartWinSklad^.Insert(Control);

  R.Assign(54, 8, 57, 9);
  CartWinSklad^.Insert(New(PHistory, Init(R, PInputline(Control), 99)));

  R.Assign(19, 8, 34, 9);
  CartWinSklad^.Insert(New(PLabel, Init(R, 'Производитель:', Control)));
*)
R.Assign(13, 8, 57, 9);
ControlLSertif := New(PInputLine, Init(R, CNSertif));
CartWinSklad^.Insert(ControlLSertif);
  R.Assign(1, 8, 13, 9);
  CartWinSklad^.Insert(New(PLabel, Init(R, '~С~ертификат:', ControlLSertif)));
ControlLSertif^.SetData(Input.NSertif);

R.Assign(68, 8, 78, 9);
ControlDSertif := New(PInputLine, Init(R, CDSertif));
CartWinSklad^.Insert(ControlDSertif);
  PInputLine(ControlDSertif)^.Validator := New(PPXPictureValidator, Init(DateFiltr, True));


  R.Assign(57, 8, 68, 9);
  CartWinSklad^.Insert(New(PLabel, Init(R, 'Срок д~е~йс:', ControlDSertif)));
ControlDSertif^.SetData(Input.DSertif);

R.Assign(8, 9, 55, 10);
ControlKSertif := New(PInputLine, Init(R, CKSertif));
CartWinSklad^.Insert(ControlKSertif);

  R.Assign(1, 9, 8, 10);
  CartWinSklad^.Insert(New(PLabel, Init(R, '~В~ыдан:', ControlKSertif)));
ControlKSertif^.SetData(Input.KSertif);




R.Assign(8, 10, 43, 11);
ControllAkzis := New(PInputLine, Init(R, CAkzis1));
CartWinSklad^.Insert(ControllAkzis);

  R.Assign(2, 10, 8, 11);
  CartWinSklad^.Insert(New(PLabel, Init(R, '~П~рим:', ControllAkzis)));
ControllAkzis^.SetData(Input.Akzis1);


R.Assign(56, 10, 76, 11);
ControlPost1 := New(PInputLine, Init(R, CPost));
CartWinSklad^.Insert(ControlPost1);

  R.Assign(76, 10, 79, 11);
  CartWinSklad^.Insert(New(PHistory, Init(R, PInputline(ControlPost1), 99)));

  R.Assign(43, 10, 56, 11);
  CartWinSklad^.Insert(New(PLabel, Init(R, 'Производ-ль:', ControlPost1)));
ControlPost1^.SetData(Input.Post);




R.Assign(30, 2, 35, 3);
Control := New(PColoredText, Init(R, BakGetField(FDiv,SArtikul,1),$31));
CartWinSklad^.Insert(Control);

R.Assign(40, 2, 45, 3);
Control := New(PColoredText, Init(R, BakGetField(FDiv,SArtikul,2),$31));
CartWinSklad^.Insert(Control);

R.Assign(50, 2, 55, 3);
Control := New(PColoredText, Init(R, BakGetField(FDiv,SArtikul,3),$31));
CartWinSklad^.Insert(Control);

R.Assign(60, 2, 65, 3);
Control := New(PColoredText, Init(R, BakGetField(FDiv,SArtikul,4),$31));
CartWinSklad^.Insert(Control);

R.Assign(70, 2, 75, 3);
Control := New(PColoredText, Init(R, BakGetField(FDiv,SArtikul,5),$31));
CartWinSklad^.Insert(Control);

R.Assign(30, 4, 35, 5);
Control := New(PColoredText, Init(R, BakGetField(FDiv,SArtikul,6),$31));
CartWinSklad^.Insert(Control);

R.Assign(40, 4, 45, 5);
Control := New(PColoredText, Init(R, BakGetField(FDiv,SArtikul,7),$31));
CartWinSklad^.Insert(Control);

R.Assign(50, 4, 55, 5);
Control := New(PColoredText, Init(R, BakGetField(FDiv,SArtikul,8),$31));
CartWinSklad^.Insert(Control);




R.Assign(5, 5, 20, 6);
Control := New(PColoredText, Init(R, '┌─── Всего ───┐', $31));
CartWinSklad^.Insert(Control);

R.Assign(1, 6, 8, 7);
Control := New(PColoredText, Init(R, 'Кол-во:', $31));
CartWinSklad^.Insert(Control);

R.Assign(8, 6, 13, 7);
ControlLKol := New(PStaticText, Init(R, #3+''));
CartWinSklad^.Insert(ControlLKol);

R.Assign(14, 6, 23, 7);
Control := New(PColoredText, Init(R, 'Упаковок:', $31));
CartWinSklad^.Insert(Control);

R.Assign(23, 6, 32, 7);
ControlPack := New(PStaticText, Init(R, ''));
CartWinSklad^.Insert(ControlPack);

R.Assign(3, 2, 24, 3);
Control := New(PStaticText, Init(R, 'Было по отделениям:'));
CartWinSklad^.Insert(Control);

R.Assign(3, 3, 25, 4);
Control := New(PStaticText, Init(R, 'Имеется по отделениям:'));
CartWinSklad^.Insert(Control);

R.Assign(1, 1, 79, 2);
Control := New(PStaticText, Init(R, 'Наименование:'+SName+' Код:'+SArtikul+' Масса:'+SLitr+' Фас:'+SInPack+
' НП:'+SNAlog));
CartWinSklad^.Insert(Control);

If SNAme2[0]<>#0 Then
Begin
 R.Assign(14, 2, 40, 3);
 Control := New(PStaticText, Init(R, sName2));
 CartWinSklad^.Insert(Control);
End;



R.Assign(58, 0, 78, 1);
If GetIdMArket(SArtikul)=1 Then
Control := New(PColoredText, Init(R, 'Продажа: разрешена', $3F))
Else
Control := New(PColoredText, Init(R, 'Продажа: запрещена', $DF));
CartWinSklad^.Insert(Control);


{CartWinSklad^.SetData(Input);}

CartWinSklad^.SelectNext(False);

NoInfo;


DrawPack;
DrawOpt;

c:=Desktop^.ExecView(CartWinSklad);
If c<>cmCancel Then
 Begin
  Control1^.GetDAta(Input.DivisionS[1]);
  Control2^.GetDAta(Input.DivisionS[2]);
  Control3^.GetDAta(Input.DivisionS[3]);
  Control4^.GetDAta(Input.DivisionS[4]);
  Control5^.GetDAta(Input.DivisionS[5]);
  Control6^.GetDAta(Input.DivisionS[6]);
  Control7^.GetDAta(Input.DivisionS[7]);
  Control8^.GetDAta(Input.DivisionS[8]);
  ControllNDS^.GetDAta(Input.Zakupka);
  ControllRZ^.GetDAta(Input.R_Zena);
  ControllOZ^.GetDAta(Input.R_Zena);
  ControllSertif^.GetDAta(Input.NSertif);
  ControlDSertif^.GetData(Input.DSertif);
  ControlKSertif^.GetData(Input.KSertif);
  ControllAkzis^.GetDAta(Input.Akzis1);
  ControlPost1^.GetDAta(Input.Post);

  PStaticText(ControlNGroup)^.GetText(NGroup);
  System.Delete(NGroup,1,1);
  Input.NGroupKod:=Copy(NGroup,1+CNAme+1,CClientKod);


  {CartWinSklad^.GetData(Input);}
  Dispose(Control,Done);
  Dispose(CartWinSklad,Done);
  DelSpaceRight(Input.NSertif);
  DelSpace(Input.DSertif);
  DelSpaceRight(Input.KSertif);

{Временно
   s:=Input.Sertifikat;
   DelSpace(s);
   If (s[0]=#0)Then
   Begin
    MessageBox(#3+NoSertif,nil, mfWarning + mfCancelButton);
   End;
   s:=Input.Post;
   DelSpace(s);
   If (s[0]=#0)Then
   Begin
    MessageBox(#3+NoPost,nil, mfWarning + mfCancelButton);
   End;
   s:=Input.Akzis;
   DelSpace(s);
  If (s[0]=#0) Then
   Begin
    MessageBox(#3+NoAkzis,nil, mfWarning + mfCancelButton);
   End;}

   s[0]:=#0;
   For c:=1 To CDivision Do
    Begin
    Input.DivisionS[c]:=InttoStr(StrToInt(Input.DivisionS[c]),CKol);
    DelSpace(Input.DivisionS[c]);
    Str(StrToInt(InPut.DivisionS[c])+StrToInt(S),S);
    End;
    DelSpace(S);
    Input.Kol:=S;
  If (StrToInt(s)> CMaxKol) Then
   Begin
     MessageBox('Слишком большое количество товара'^M+
                'Попробуйте разместить его в разные позиции! ',nil, mfError + mfCancelButton);
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
    MessageBox(#3+NullKol,nil, mfWarning + mfCancelButton);
   End;

  If (StrTOReal(Input.Zakupka)>CMaxZena)Then
   Begin
     MessageBox(#3+ErrorZakupka,nil, mfError + mfCancelButton);
   End;

  If (Input.R_Zena[0]=#0) Or
  (((StrTOReal(Input.R_Zena)>CMaxZena)Or(StrTOReal(Input.R_Zena)=0.0))
  and (StrToInt(Input.Kol)>0)) Then
{  (StrTOReal(Input.R_Zena)>CMaxZena)Or(StrTOReal(Input.R_Zena)=0.0) Then}
   Begin
     MessageBox(ErrorRZena,nil, mfError + mfCancelButton);
     GoTo 1;
   End;
  If (Input.O_Zena[0]=#0) Or
  (((StrTOReal(Input.O_Zena)>CMaxZena)Or(StrTOReal(Input.O_Zena)=0.0))
  and (StrToInt(Input.Kol)>0)) Then
   Begin
     MessageBox(ErrorOZena,nil, mfError + mfCancelButton);
     GoTo 1;
   End;
  If (StrToReal(Input.R_Zena)<>StrTOReal(Input.O_Zena)) Then
   Begin
     MessageBox(#3^M+#3+'Розничная цена не равна оптовой !',nil, mfError + mfCancelButton);
     GoTo 1;
   End;
   Format(SInpack,CInPack);
  s:=SName+'│'+SArtikul+'│'+SLitr+'│'+SInPack+'│';
  With Input Do
  Begin
   Str(StrToInt(Kol):CKol,Kol);
   Str(StrToReal(R_Zena):CZena:CMantissa,R_Zena);
   Str(StrToReal(O_Zena):CZena:CMantissa,O_Zena);
   Str(StrToReal(Zakupka):CZena:CMantissa,Zakupka);
{   DelSpace(R_Zena);}
   Format(R_Zena,CZena);
   Format(Zakupka,CZena);
{   DelSpace(O_Zena);}
   Format(O_Zena,CZena);
   Format(Post,CPost);

   If FindParam('/PROZENT') Then
   Begin
    If StrToReal(Zakupka)>0.001 Then
     Begin
        Str((StrToReal(R_Zena)-StrToReal(Zakupka))/
        StrToReal(Zakupka)*100:CZena:CMantissa,Nazenka);
     End
     Else Nazenka:='   ??.??';

   End
   Else
    Nazenka:=O_Zena;




   s:=s+Kol+'│'+R_Zena+'│'+O_Zena+'│';
  End;
   If (StrToInt (Input.Kol)   <>StrToInt (PrevInput.Kol)) Or
      (StrToReal(Input.R_Zena)<>StrToReal(PrevInput.R_Zena))Or
      (StrToReal(Input.Zakupka)<>StrToReal(PrevInput.Zakupka))Or
      (StrToReal(Input.O_Zena)<>StrToReal(PrevInput.O_Zena)) Then

    If {Not(Password(2))} Not(StrToInt(CurrentPassword)=0) Then
    Begin
    MessageBox(#3^M+#3+'Уровень Вашего доступа не позволяет изменять общее количество товара и цену!',Nil,
    mfError+mfCancelButton);
    Goto 1;
    End;
   SName:=CalcPackNoFile(SInPack,Input.Kol);
   DelSpace(SName);
   s:=s+SName;
   DelSpaceRight(Input.Post);
   ChekPost(Input.Post);
   Input.Caption:=CurrentPassword;
   sName:=Copy(SArtikul,1,CRazdelKod);

   {начало записи в файл}
  Assign(NameFile,Path.ToName+SNAme+'.id');
  Reset(NameFile);
  C:=IOResult;
  If C<>0 Then
   Begin
    Repeat
    Until SetNameUnLock(SArtikul);
    MessageBox(^M+#3'Ошибка доступа к файлу '+sName+'.id!',nil,mfError+mfCancelButton);
    Exit;
   End;


   Assign(BazFile,Path.ToSklad+sName+'.db');
   c:=IOResult;
   Reset(BazFile);
   C:=IOResult;
  If C<>0 Then
   Begin
    System.Close(NAmeFile);
    Repeat
    Until SetNameUnLock(SArtikul);
    MessageBox(#3^M+#3'Ошибка доступа к файлу '+sName+'.db!',nil,mfError+mfCancelButton);
    Exit;
   End;
   sName:=Copy(SArtikul,CRazdelKod+1,CKod);
   Seek(BazFile,GetFileLocation3(sNAme));

   {блокируем позицию предварительной блокировкой}
   Repeat
    Pause(1);
   Until NetCall.Lock(BazFile,FilePos(BazFile)*SizeOf(SkladType),SizeOf(SkladType));

   Read(BazFile,BazElement);
   {модифицируем поля}


Input.Zakupka:=RealToStr(StrToReal(Input.Zakupka),CZena,CMantissa);
DelSpace(Input.Zakupka);
Input.R_Zena:=RealToStr(StrToReal(Input.R_Zena),CZena,CMantissa);
DelSpace(Input.R_Zena);
Input.O_Zena:=RealToStr(StrToReal(Input.O_Zena),CZena,CMantissa);
DelSpace(Input.O_Zena);

   Bazelement.Input:=Input;
   BazElement.Date:=FDate;
   BazElement.Time:=Times;
   BazElement.Employ:=True;
   BazElement.Locked:=True;


   Seek(BazFile,FilePos(BazFile)-1);
   Write(BazFile,BazElement);

   Seek(BazFile,FilePos(BazFile)-1);
   Repeat
    NetCall.UnLock(BazFile,FilePos(BazFile)*SizeOf(SkladType),SizeOf(SkladType));
   Until (DosError=0);

   System.Close(BazFile);{закрытие файла наличия}


   New(NAmeElement,Init);
   Seek(NAmeFile,GetFileLocation3(sNAme));
   Repeat
    Pause(1);
   Until NetCall.Lock(NameFile,FilePos(NameFile)*SizeOf(BazType),SizeOf(BazType));

   Read(NameFile,NameElement^.Dat);
   NAmeElement^.Dat.Caption:=CurrentPassword;
   NAmeElement^.Dat.Locked:=True;
   NAmeElement^.Dat.Employ:=True;
   NAmeElement^.Dat.LockCaption:=CurrentPassword;

   Seek(NAmeFile,FilePos(NAmeFile)-1);
   Write(NameFile,NAmeElement^.Dat);

   Seek(NameFile,FilePos(NameFile)-1);

   Repeat
    NetCAll.UnLock(NameFile,FilePos(NameFile)*SizeOf(BazType),SizeOf(BazType));
   Until DosError=0;


   System.Close(NAmeFile);{закрытие файла наименований}

   Dispose(NameElement,Done);

   {конец записи в файл }
   Baz^.List^.AtFree(Baz^.Focused);
   Baz^.SetRange(Baz^.List^.Count);
   Baz^.List^.Insert(NewStr(S));
   Baz^.SetRange(Baz^.List^.Count);
   Baz^.FocusItem(LoCation(Baz,SArtikul,ProdagaWindow));

   DelSpace(Input.R_Zena);
   DelSpace(Input.O_Zena);

Input.Zakupka:=RealToStr(StrToReal(Input.Zakupka),CZena,CMantissa);
DelSpace(Input.Zakupka);
Input.R_Zena:=RealToStr(StrToReal(Input.R_Zena),CZena,CMantissa);
DelSpace(Input.R_Zena);
Input.O_Zena:=RealToStr(StrToReal(Input.O_Zena),CZena,CMantissa);
DelSpace(Input.O_Zena);

s:='Стало: Р/Цена:'+Input.R_Zena+' О/Ц:'+Input.O_Zena+' З/Ц:'+Input.Zakupka+' По отделениям:';
For c:=1 To CDivision Do
  Begin
   DelSpace(Input.DivisionS[c]);
   s:=S+' '+Input.DivisionS[c];
  End;
   AddProtocol(St+''^M+S,'','');
 End
 Else
 Begin
  Dispose(Control,Done);
  Dispose(CartWinSklad,Done);
 End;

 Repeat
 Until SetNameUnLock(SArtikul);

End;

Destructor TCartSkladWinDow.Done;
Begin
Dispose(ControlLSertif,Done);
Dispose(ControlKSertif,Done);
Dispose(ControlDSertif,Done);
Dispose(ControlLAkzis,Done);
Dispose(ControlPost1,Done);
Dispose(ControlLKol,Done);
Dispose(ControlPack,Done);
Dispose(ControlLRZ,Done);
Dispose(ControlLOZ,Done);
TDialog.Done;
End;

procedure TCartSkladWindow.HandleEvent(var Event: TEvent);
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


Var DrawP : Boolean;
    s : AllStr;
    Test : Word;

Begin
Case Event.What Of
 evCommand :
   Case Event.Command Of
        cmLocalCalc:Calculator;


   cmSelectGroup : Begin
  If (PView(GroupWin)<>Desktop^.TopView)And(ControlNGroup^.State and sfFocused <> 0) Then
  Begin
     PStaticText(ControlNGroup)^.GetText(S);
     System.Delete(S,1,1);
     GroupWin^.ShowGroupList(s,Test);
     PStaticText(ControlNGroup)^.Text^:=#3+S;

     Case Test Of
      0,3 :FocusNext(True);
      1,2 :FocusNext(False);
     Else;
          End;

     Redraw;

     ClearEvent(Event);
  End
  Else
   ClearEvent(Event);
 End;

   Else;
   End;
{
 evKeyDown:
   Case Event.KeyCode Of
        kbEnter:Begin
                inherited HandleEvent(Event);
                If (CartWinSklad^.Current=ControlLSertif) Then
                   Begin
                    Event.What:=evCommand;
                    Event.Command:=CmOk;
                   End;
                End;
   Else;
   End;
}
   Else;
   End;
  If (Event.What=evKeyboard)And((Event.CharCode in ['0','1','2','3','4','5','6','7','8','9','.'])
  Or (Event.KeyCode=kbDel) Or (Event.KeyCode=kbBack)){And(Status=DocNormal)}
  And (ConTrolLRZ^.State and sfFocused <> 0) Then
  Begin
  Inherited HandleEvent(Event);
  DrawOpt;
  End
  Else
  Begin
  If (Event.What=evKeyboard)And((Event.CharCode in ['0','1','2','3','4','5','6','7','8','9'])
  Or (Event.KeyCode=kbDel) Or (Event.KeyCode=kbBack)) Then DrawP:=True
  Else DrawP:=False;


 If (PView(GroupWin)<>Desktop^.TopView)And(ControlNGroup^.State and sfFocused <> 0)
 And (Event.Command<>cmSelectGroup) And (Event.What <> EvKeyDown)Then
            Begin
             Event.What:=EvCommand;
             Event.Command:=cmSelectGroup;
             PutEvent(Event);
             ClearEvent(Event);
            End;


  inherited HandleEvent(Event);
  If DrawP Then Begin
                 If (Control1^.State and sfFocused <> 0)Or
                    (Control2^.State and sfFocused <> 0)Or
                    (Control3^.State and sfFocused <> 0)Or
                    (Control4^.State and sfFocused <> 0)Or
                    (Control5^.State and sfFocused <> 0)Or
                    (Control6^.State and sfFocused <> 0)Or
                    (Control7^.State and sfFocused <> 0)Or
                    (Control8^.State and sfFocused <> 0)
				Then DrawPack;
                End;
  End;
  ClearEvent(Event);
End;


procedure TSkladWindow.DrawCurrent;
VAr S : TMyString;
    R : TRect;
    SKol : TDateString;
    S3   : String[3];
    i : Byte;
Begin
If (Baz^.List<>Nil)And(Baz^.List^.Count>=1) Then
  Begin
   SArtikul:=Copy(Baz^.GetText(Baz^.Focused,Baz^.List^.Count),1+CName+1,CArtikul);

   S:=BakGetField(FSertif,SArtikul,0);
   SKol:=BakGetField(FDAteSertif,SArtikul,0);
   Dispose(ControlSertif,Done);
   R.Assign(13, 20, 78, 21);
   DelSpaceRight(s);
   If (s[0]<>#0) Then
   s:=s+' до:'+SKol;
   ControlSertif := New(PColoredText, Init(R, S, $7E));
   Insert(ControlSertif);

   S:=BakGetField(FAkzis,SArtikul,0);
   Dispose(ControlAkzis,Done);
   R.Assign(13, 21, 78, 22);
   ControlAkzis := New(PColoredText, Init(R, S, $7E));
   Insert(ControlAkzis);

   S:=BakGetField(FKMake,SArtikul,0);
   S:=GetMakeField(FClient,S,StrToInt(BakGetField(FMake,SArtikul,0)));
   Dispose(ControlMake,Done);
   R.Assign(15, 18, 35, 19);
   ControlMake :=New(PColoredText, Init(R, S, $7E));
   Insert(ControlMake);

   S:=BakGetField(FNds,SArtikul,0);
   Dispose(Controlnds,Done);
   R.Assign(35, 19, 40, 20);
   ControlNDS := New(PColoredText, Init(R, S, $7E));
   Insert(ControlNDS);

   S:=BakGetField(FOperator,SArtikul,0);
   Dispose(ControlOperator,Done);
   R.Assign(8, 1, 16, 2);
   s:=IntToStr(StrToInt(s),CMAntissa);
   s:=GetOperatorName(s);
   DelSpace(s);
   ControlOperator := New(PColoredText, Init(R, S, $7E));
   Insert(ControlOperator);

   S:=BakGetField(FDates,SArtikul,0);
   Dispose(ControlModifyDate,Done);
   R.Assign(22, 1, 30, 2);
   ControlModifyDate := New(PColoredText, Init(R, S, $7E));
   Insert(ControlModifyDate);

   S:=BakGetField(FTimes,SArtikul,0);
   Dispose(ControlModifyTime,Done);
   R.Assign(37, 1, 45, 2);
   ControlModifyTime := New(PColoredText, Init(R, S, $7E));
   Insert(ControlModifyTime);

   Skol:=BakGetField(FKol,SArtikul,0);
   Str((StrToInt(SKol)*StrToReal(GetIdField(FLitr,SArtikul))):CInputILitr:CMantissa,S);
   DelSpace(S);
   Dispose(ControlL,Done);
   R.Assign(15, 19, 28, 20);
   ControlL := New(PColoredText, Init(R, S, $7E));
   {u:=0.5*(mf/bf*u^aa) * (M^2)*(W^2)*eta}

   Insert(ControlL);

   Str((StrToInt(SKol)*StrToReal(BakGetField(FOZena,SArtikul,0))):CInputIZena:CMantissa,S);
   DelSpace(S);
   Dispose(ControlOZ,Done);
   R.Assign(57, 19, 72, 20);
   ControlOZ := New(PColoredText, Init(R, S, $7E));
   Insert(ControlOZ);

   Str((StrToInt(SKol)*StrToReal(BakGetField(FRZena,SArtikul,0))):CInputIZena:CMantissa,S);
   DelSpace(S);
   Dispose(ControlRZ,Done);
   R.Assign(57, 18, 72, 19);
   ControlRZ := New(PColoredText, Init(R, S, $7E));
   Insert(ControlRZ);

   Dispose(ControlFullName,Done);
   R.Assign(22, 15, 79, 16);
   s:=GetIdField(FName,SArtikul);
   DelSpaceRight(s);
   s:=' '+s+' '+GetIdField(FName2,SArtikul);
   ControlFullName := New(PColoredText, Init(R, s, $7e));
   Insert(ControlFullName);



   S:='По отделен.:';
   For i:=1 To CDivision Do
    Begin
     SKol:=BakGetField(FDiv,SArtikul,i);
     Str(StrToInt(SKol):CKol,SKol);
     Format(Skol,CKol);
     Str(i:2,S3);
     s:=s+S3+':'+SKol;
    End;
   Dispose(ControlDivision,Done);
   R.Assign(2, 16, 79, 17);
   ControlDiviSion := New(PColoredText, Init(R, S, $71));
   Insert(ControlDiviSion);

   Dispose(ControlPost,Done);
   R.Assign(19, 17, 39, 18);
   ControlPost := New(PColoredText, Init(R, BakGetField(FPost,SArtikul,0), $7E));
   Insert(ControlPost);

   Dispose(ControlMarket,Done);
   R.Assign(52, 17, 61, 18);
   Case GetIdMarket(SArtikul) Of
   0:s:='Запрещена';
   1:s:='Разрешена';
   Else s:='???';
   End;

   If GetIdMarket(SArtikul)=1 Then
   ControlMarket := New(PColoredText, Init(R, s, $7E))
   Else
   ControlMarket := New(PColoredText, Init(R, s, $Df));
   Insert(ControlMarket);

   Dispose(ControlNalog,Done);
   R.Assign(73, 17, 78, 18);
   s:=GetIdField(FNalog,SArtikul);
   s:=RealToStr(StrToReal(s),CLitr,CMantissa);
   DelSpace(s);

   ControlNalog := New(PColoredText, Init(R, s, $7E));
   Insert(ControlNalog);

  End;


End;


procedure TSkladWindow.OpenSkladWindow;
Var l : Boolean;
begin
  ClearFind;
  if Message(Desktop, evBroadcast, cmCorrectSklad, nil) = nil then
  begin
    DInfo('Инициализация корректировки склада...');
    L:=True;
    SkladWindow := New(PSkladWindow, Init(L));
    If L Then
    Begin
    Application^.InsertWindow(SkladWindow);
    NoInfo;
    End
    Else
     Begin
      Dispose(SkladWindow,Done);
      NoInfo;
     End;
  end
  else
    if PView(SkladWindow) <> Desktop^.TopView then SkladWindow^.Select;
end;

constructor TSkladWindow.Init(Var l : Boolean);
var
  R : TRect;
  Control : PView;
  C : Word;
  DocumentNumer : TDateString;
  SkladFile : File Of SkladType;
  Nazenka,s: TEnjoyStr;
  ws : TDateString;
  i : Byte;
  SName : String[CName];
  SLitr : String[CLitr];
  SPack : String[CInPack];

begin

 R.Assign(0, 0, 80, 23);
inherited Init(R, 'Корректировка склада');
Options := Options or ofCenterX or ofCenterY;

L:=False;
TekDate:=FDate;
{
If Not(TestOpenDate(TekDate)) Then
   Begin
    MessageBox(#3^M+#3'Доступ к данным за '+TekDate+' заблокирован!',Nil,mfError+mfCancelButton);
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
    {MemCC(RazdelElement.Kod+' '+RazdelElement.Name);}
    Razdel^.List^.Insert(NewStr(RazdelElement.Name+'│'+RazdelElement.Kod));
    Razdel^.SetRange(Razdel^.List^.Count);
   End;
 End;
System.Close(RazdelFile);
Razdel^.FocusItem(0);

PrevS:=Razdel^.GetText(Razdel^.Focused,Razdel^.List^.COunt);
Dispose(Razdel,Done);

R.Assign(53, 1, 78, 2);
ControlRazdel := New(PColoredText, Init(R, #3+PrevS, $1F));
ControlRazdel^.Options := ControlRazdel^.Options or ofSelectable;
Insert(ControlRazdel);

R.Assign(45, 1, 53, 2);
Insert(New(PLabel, Init(R, 'Ра~з~дел:',ControlRazdel)));

R.Assign(78, 3, 79, 15);
Control := New(PScrollBar, Init(R));
Insert(Control);

R.Assign(1, 3, 78, 15);
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
     ReadSklad(BazFile,BazElement);
     {
     Repeat
      NetCall.UnLock(BazFile,(FilePos(BazFile)-1)*SizeOf(SkladType),SizeOf(SkladType));
     Until (DosError=0);
     }
{  If GetIdEmploy(BazElement.BazKod) Then}
   If (BazElement.Employ)Then
   Begin
               SName:=GetIdField(FName,BazElement.BazKod);
               Format(SName,CName);
               SLitr:=GetIdField(FLitr,BazElement.BazKod);
               Format(SLitr,CLitr);
               Format (BazElement.Input.Kol,CLitr);
               SPack:=GetIdField(FInPack,BazElement.BazKod);
               Format(SPack,CInPack);

{    Format (BazElement.Baz.Name,CName);
    Format (BazElement.Baz.Litr,CLitr);}
    Format (BazElement.Input.Kol,CLitr);
{    Format (BazElement.Baz.InPack,CInPack);}
    Str(StrToReal(BazElement.Input.R_Zena):CZena:CMantissa,BazElement.Input.R_Zena);
    Format (BazElement.Input.R_Zena,CZena);
    Str(StrToReal(BazElement.Input.O_Zena):CZena:CMantissa,BazElement.Input.O_Zena);
    Format (BazElement.Input.O_Zena,CZena);
    UnPack:=CalcPackNoFile(SPack,BazElement.Input.Kol);

    DelSpace(BazElement.Input.Kol);
    RFormat (BazElement.Input.Kol,CLitr);

    DelSpace(UnPack);

   If FindParam('/PROZENT') Then
   Begin
    If StrToReal(BazElement.Input.Zakupka)>0.001 Then
     Begin
        Str((StrToReal(BazElement.Input.R_Zena)-StrToReal(BazElement.Input.Zakupka))/
        StrToReal(BazElement.Input.Zakupka)*100:CZena:CMantissa,Nazenka);
     End
     Else Nazenka:='   ??.??';

   End
   Else
    Nazenka:=BazElement.Input.O_Zena;


    Prevs:=SName+'│'+BazElement.BazKod+'│'+SLitr+
    '│'+SPack+'│'+BazElement.Input.Kol+'│'+
    +BazElement.Input.R_Zena+'│'+BazElement.Input.O_Zena+'│'+UnPack;
    Baz^.List^.Insert(NewStr(Prevs));
    Baz^.SetRange(Baz^.List^.Count);
   End;
 End;
System.Close(BazFile);
 End;
Baz^.FocusItem(0);
Baz^.HelpCtx:=$E166;
Insert(Baz);
SArtikul:=Copy(Baz^.GetText(Baz^.Focused,Baz^.List^.Count),1+CName+1,CArtikul);

  R.Assign(1, 2, 77, 3);
  Insert(New(PLabel, Init(R, '~Н~аименование товара         Код  Литр. Фас Колич Р/Цена   О/Цена   Упаковок ', Baz)));

R.Assign(2, 15, 22, 16);
Control := New(PColoredText, Init(R, 'Наименование товара:', $74));
Insert(Control);

R.Assign(22, 15, 79, 16);
If Baz^.List^.Count>0 Then
ControlFullName := New(PColoredText, Init(R, GetIdField(FFFName,SArtikul), $7e))
Else
ControlFullName := New(PColoredText, Init(R, ' ', $7e));
Insert(ControlFullName);



R.Assign(2, 16, 79, 17);
If Baz^.List^.Count>0 Then
ControlDiviSion := New(PColoredText, Init(R, 'Имеется по отделениям:  1:'+BakGetField(FDiv,SArtikul,1)
+'  2:'+BakGetField(FDiv,SArtikul,2)+
'  3:'+BakGetField(FDiv,SArtikul,3)+'  4:'+BakGetField(FDiv,SArtikul,4)+'  5:'+BakGetField(FDiv,SArtikul,5), $71))
Else
ControlDiviSion := New(PColoredText, Init(R, 'Имеется по отделениям:', $71));
Insert(ControlDiviSion);

R.Assign(5, 17, 19, 18);
Control := New(PColoredText, Init(R, 'Производитель:', $74));
Insert(Control);

R.Assign(19, 17, 39, 18);
ControlPost := New(PColoredText, Init(R, #3+'', $7E));
Insert(ControlPost);

R.Assign(44, 17, 52, 18);
Control := New(PColoredText, Init(R, 'Продажа:', $74));
Insert(Control);

R.Assign(52, 17, 61, 18);
ControlMarket := New(PColoredText, Init(R, #3+'', $7E));
Insert(ControlMarket);


R.Assign(53, 22, 63, 23);
Control := New(PColoredText, Init(R, 'Итого О/Ц:', $74));
Insert(Control);

R.Assign(63, 22, 78, 23);
Control_IO := New(PColoredText, Init(R, '0.00',$4E));
Insert(Control_IO);

R.Assign(27, 22, 37, 23);
Control := New(PColoredText, Init(R, 'Итого Р/Ц:', $74));
Insert(Control);

R.Assign(37, 22, 52, 23);
Control_IR := New(PColoredText, Init(R, '0.00', $4E));
Insert(Control_IR);

R.Assign(1, 22, 13, 23);
Control := New(PColoredText, Init(R, 'Итого масса:', $74));
Insert(Control);

R.Assign(13, 22, 26, 23);
Control_IL := New(PColoredText, Init(R, '0.000',$4E));
Insert(Control_IL);

R.Assign(2, 20, 13, 21);
Control := New(PColoredText, Init(R, 'Сертификат:', $74));
Insert(Control);

R.Assign(13, 20, 78, 21);
ControlSertif := New(PColoredText, Init(R, #3+'', $7E));
Insert(ControlSertif);

R.Assign(2, 21, 13, 22);
Control := New(PColoredText, Init(R, 'Примечание:', $74));
Insert(Control);

R.Assign(13, 21, 78, 22);
ControlAkzis := New(PColoredText, Init(R, #3+'', $7E));
Insert(ControlAkzis);

R.Assign(15, 19, 28, 20);
ControlL := New(PColoredText, Init(R, #3+'0.000', $4E));
Insert(ControlL);

R.Assign(2, 19, 15, 20);
Control := New(PColoredText, Init(R, 'Итого масса:', $74));
Insert(Control);

R.Assign(31, 19, 35, 20);
Control := New(PColoredText, Init(R, 'НДС:', $74));
Insert(Control);

R.Assign(61, 0, 67, 1);
Control := New(PColoredText, Init(R, ' Склад:', $74));
Insert(Control);

R.Assign(67, 0, 79, 1);
Control := New(PColoredText, Init(R, #3+GetClientField(FClient,Rek.Kod,1){SkladsName}, $7E));
Insert(Control);

R.Assign(44, 18, 57, 19);
Control := New(PColoredText, Init(R, 'Итого по Р/Ц:', $74));
Insert(Control);

R.Assign(57, 19, 72, 20);
ControlOZ := New(PColoredText, Init(R, #3+'0.00', $7E));
Insert(ControlOZ);

R.Assign(44, 19, 57, 20);
Control := New(PColoredText, Init(R, 'Итого по О/Ц:', $74));
Insert(Control);

R.Assign(57, 18, 72, 19);
ControlRZ := New(PColoredText, Init(R, #3+'0.00', $7E));
Insert(ControlRZ);

R.Assign(5, 18, 15, 19);
Control := New(PColoredText, Init(R, 'Поставщик:', $74));
Insert(Control);

R.Assign(15, 18, 35, 19);
ControlMake := New(PColoredText, Init(R, #3+'', $7E));
Insert(ControlMake);

R.Assign(35, 19, 40, 20);
ControlNDS := New(PColoredText, Init(R, #3+'0.00', $7E));
Insert(ControlNDS);

R.Assign(8, 0, 16, 1);
Control := New(PColoredText, Init(R, FDate, $7E));
Insert(Control);

R.Assign(2, 0, 8, 1);
Control := New(PColoredText, Init(R, ' Дата:', $74));
Insert(Control);

R.Assign(1, 1, 10, 2);
Control := New(PColoredText, Init(R, 'Операт:', $74));
Insert(Control);

R.Assign(8, 1, 16, 2);
ControlOperator := New(PColoredText, Init(R, #3+'', $7E));
Insert(ControlOperator);

R.Assign(17, 1, 22, 2);
Control := New(PColoredText, Init(R, 'Дата:', $74));
Insert(Control);

R.Assign(22, 1, 30, 2);
ControlModifyDate := New(PColoredText, Init(R, #3+'', $7E));
Insert(ControlModifyDate);

R.Assign(31, 1, 37, 2);
Control := New(PColoredText, Init(R, 'Время:', $74));
Insert(Control);

R.Assign(37, 1, 45, 2);
ControlModifyTime := New(PColoredText, Init(R, #3+'', $7E));
Insert(ControlModifyTime);

R.Assign(62, 17, 73, 18);
Control := New(PColoredText, Init(R, 'Налог с пр:', $74));
Insert(Control);

R.Assign(73, 17, 78, 18);
ControlNalog := New(PColoredText, Init(R, #3+'0.00', $7E));
Insert(ControlNalog);


SelectNext(False);
CalcItogo;
DrawCurrent;
L:=True;
PrevS[0]:=#0;
PrevCur[0]:=#0;
SArtikul[0]:=#0;
end;


procedure TSkladWindow.CalcItogo;
Var R:TRect;
    t,l,k : Real;
    Sl,Sk,So,Sr : Real;
    SSl,SSk,SSo,SSr,Itogo_O,Itogo_R,Itogo_L:String[CIZena];
    ls : Word;
    Code:Integer;
    kol : LongInt;
Begin
SO:=0;
SR:=0;
SL:=0;
For ls:=0 To Baz^.List^.Count Do
Begin
{литраж}
SSl:=Copy(Baz^.GetText(ls,Baz^.List^.Limit),1+CName+1+Cartikul+1,CLitr);
DelSpace(Ssl);
{колич}
SSk:=Copy(Baz^.GetText(ls,Baz^.List^.Limit),1+CName+1+Cartikul+1+CLitr+1+CInPack+1,CKol);
DelSpace(sSk);
{розничная цена}
SSr:=Copy(Baz^.GetText(ls,Baz^.List^.Limit),1+CName+1+Cartikul+1+CLitr+1+CInPack+1+CKol+1,CZena);
DelSpace(sSr);
{оптовая цена}
SSo:=Copy(Baz^.GetText(ls,Baz^.List^.Limit),1+CName+1+Cartikul+1+CLitr+1+CInPack+1+CKol+1+CZena+1,CZena);
DelSpace(sso);
Val(ssk,kol,Code);
Val(ssl,l,Code);
Sl:=Sl+L*Kol;
Val(ssr,l,Code);
Sr:=Sr+l*Kol;
Val(sso,l,Code);
So:=So+l*Kol;
End;{for}
Str(Sl:CILitr:CMantissa,Itogo_L);
DelSpace(Itogo_L);
Str(Sr:CIZena:CMantissa,Itogo_R);
DelSpace(Itogo_R);
Str(So:CIZena:CMantissa,Itogo_O);
DelSpace(Itogo_O);

Dispose(Control_IO,Done);
R.Assign(63, 22, 78, 23);
Control_IO := New(PColoredText, Init(R,#3+Itogo_O,$4E));
Insert(Control_IO);

Dispose(Control_IR,Done);
R.Assign(37, 22, 52, 23);
Control_IR := New(PColoredText, Init(R,#3+Itogo_R, $4E));
Insert(Control_IR);

Dispose(Control_IL,Done);
R.Assign(13, 22, 26, 23);
Control_IL := New(PColoredText, Init(R,#3+Itogo_L,$4E));
Insert(Control_IL);
End;


procedure TSkladWindow.HandleEvent(var Event: TEvent);
Var test : Word;
    s,s1 : String;
    l : Boolean;
  SName : String[CName];
  Art   : ArtikulStr;
  SLitr : String[CLitr];
  SPack : String[CInPack];
  IO : Word;

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
Var Nazenka : AllStr;
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
     ReadSklad(BazFile,BazElement);
     {
     Repeat
      NetCall.UnLock(BazFile,(FilePos(BazFile)-1)*SizeOf(SkladType),SizeOf(SkladType));
     Until (DosError=0);
     }
{                    If GetIdEmploy(BazElement.BazKod) Then}
                    If BazElement.Employ Then
                     Begin
               SName := GetIdField(FName,BazElement.BazKod);
               Format(SName,CName);
               SLitr := GetIdField(FLitr,BazElement.BazKod);
               Format(SLitr,CLitr);
               Format (BazElement.Input.Kol,CLitr);
               SPack := GetIdField(FInPack,BazElement.BazKod);
               Format(SPack,CInPack);

    DelSpace(BazElement.Input.Kol);
    RFormat (BazElement.Input.Kol,CLitr);
    Str(StrToReal(BazElement.Input.R_Zena):CZena:CMantissa,BazElement.Input.R_Zena);
    Format (BazElement.Input.R_Zena,CZena);
    Str(StrToReal(BazElement.Input.O_Zena):CZena:CMantissa,BazElement.Input.O_Zena);
    Format (BazElement.Input.O_Zena,CZena);
    UnPack:=CalcPackNoFile(SPack,BazElement.Input.Kol);
    DelSpace(UnPack);

   If FindParam('/PROZENT') Then
   Begin
    If StrToReal(BazElement.Input.Zakupka)>0.001 Then
     Begin
        Str((StrToReal(BazElement.Input.R_Zena)-StrToReal(BazElement.Input.Zakupka))/
        StrToReal(BazElement.Input.Zakupka)*100:CZena:CMantissa,Nazenka);
     End
     Else Nazenka:='   ??.??';
   End
   Else
    Nazenka:=BazElement.Input.O_Zena;


    Prevs:=SName+'│'+BazElement.BazKod+'│'+SLitr+
    '│'+SPack+'│'+BazElement.Input.Kol+'│'+
    +BazElement.Input.R_Zena+'│'+BazElement.Input.O_Zena+'│'+UnPack;
    Baz^.List^.Insert(NewStr(Prevs));
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
                  CalcItogo;
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
  kbEnter:    Begin
If Not(TestOpenDate1(FDate)) Then
   Begin
    MessageBox(#3^M+#3'Доступ к данным за '+TekDate+' заблокирован!',Nil,mfError+mfCancelButton);
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
                      s:=Copy(Baz^.GetText(Baz^.Focused,Baz^.List^.Count),1+CName+1,Cartikul);
                s:=Baz^.GetText(Baz^.Focused,Baz^.List^.Count);
                Car^.Ini(s);
                CalcItogo;
                If (Baz^.Focused+1)<Baz^.List^.Count Then
                 Begin
                 Baz^.FocusItem(Baz^.Focused+1);
                 End;
                Redraw;
                ClearEvent(Event);
            End
            End;
kbAlt1 : if Password(4) Then UnlockAll;
kbGrayPlus,
kbF4      : Begin

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
               SName := GetIdField(FName,BazElement.BazKod);
               Format(SName,CName);
               SLitr := GetIdField(FLitr,BazElement.BazKod);
               Format(SLitr,CLitr);
               Format (BazElement.Input.Kol,CLitr);
               SPack := GetIdField(FInPack,BazElement.BazKod);
               Format(SPack,CInPack);
               DelSpace(BazElement.Input.Kol);
               RFormat (BazElement.Input.Kol,CLitr);
               Str(StrToReal(BazElement.Input.R_Zena):CZena:CMantissa,BazElement.Input.R_Zena);
               Format (BazElement.Input.R_Zena,CZena);
               Str(StrToReal(BazElement.Input.O_Zena):CZena:CMantissa,BazElement.Input.O_Zena);
               Format (BazElement.Input.O_Zena,CZena);
               UnPack:=CalcPackNoFile(SPack,BazElement.Input.Kol);
               DelSpace(UnPack);
               Baz^.List^.Insert(NewStr(SName+'│'+BazElement.BazKod+'│'+SLitr+
               '│'+SPack+'│'+BazElement.Input.Kol+'│'+
               +BazElement.Input.R_Zena+'│'+BazElement.Input.O_Zena+'│'+UnPack));
               Baz^.SetRange(Baz^.List^.Count);
               Baz^.FocusItem(LoCation(Baz,BazElement.BazKod,ProdagaWindow));
               PrevCur[0]:=#0;
               Art:=BazElement.BazKod;
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
     cmCorrectSklad: Begin
                 ClearEvent(Event);
                End;

     cmCancel : Begin
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
     Refresh(s,PrevS);
     ClearEvent(Event);
  End;
  End

      Else;
      End;{evCommand}
      Else;
      End;{*Case*}
  if (Event.What = evBroadcast) and
    (Event.Command = cmCorrectSklad) then ClearEvent(Event);

 If (PView(Rz)<>Desktop^.TopView)And(ControlRazdel^.State and sfFocused <> 0)
 And (Event.Command<>cmSelectRazdel) And (Event.What <> EvKeyDown) Then
            Begin
             Event.What:=EvCommand;
             Event.Command:=cmSelectRazdel;
             PutEvent(Event);
             ClearEvent(Event);
            End;

  inherited HandleEvent(Event);
  If (Desktop^.Current=PView(SkladWindow)) And (Event.What <> EvKeyDown) Then
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

(*
Procedure ViewCorrect;
Var s:TDateString;
    protocol,txt : Text;
    i : word;
    ws : String;

Begin
 If DateDialog(s) Then
 Begin

 Assign(txt,Path.ToTemp+s+'.tmp');
 i:=ioresult;
 rewrite(txt);
 i:=ioresult;
 if i<>0 then
  begin
   messagebox(^M+#3+'Не могу создать временный файл!',nil,mfError+mfCancelButton);
   exit;
  end;

 Assign(protocol,Path.Toprotocol+s+'.pr');
 i:=ioresult;
 reset(protocol);
 i:=ioresult;
 if i<>0 then
  begin
   Close(txt);
   messagebox(^M+#3+'Не могу открыть файл протокола!',nil,mfError+mfCancelButton);
   exit;
  end;
  While Not(Eof(protocol)) Do
   Begin
    Readln(protocol,ws);
    Writeln(txt,ws);
   End;

  Close(txt);
  Close(Protocol);

 ViewAsText(Path.ToTemp+S+'.tmp',True);
 End;
End;
*)


Procedure ViewCorrect;
Var s1,s2:TDateString;
    protocol,txt : Text;
    i : word;
    ws : String;
    Cur,l1,l2 : LongInt;

Begin
 If DatePeriodDialog(s1,s2,True) Then
 Begin
 Assign(txt,Path.ToTemp+s2+'.tmp');
 i:=ioresult;
 rewrite(txt);
 i:=ioresult;
 if i<>0 then
  begin
   messagebox(^M+#3+'Не могу создать временный файл!',nil,mfError+mfCancelButton);
   exit;
  end;
 DInfo('Выполняю слияние протоколов...');
 l1:=DAteStringToDate(DateMask,s1);
 l2:=DAteStringToDate(DateMask,s2);

 For Cur:=l1 To L2 Do
 Begin
    {If DayOfWeek(Cur)<>Sunday Then}
     Begin
 s1:=DAteToDAteString(DAteMask,Cur);
 Assign(protocol,Path.Toprotocol+s1+'.pr');
 If LockPrWriteRead(s1) Then
Begin
 i:=ioresult;
 reset(protocol);
 i:=ioresult;
 if i=0 then
  begin
  If Cur=L1 Then
   Writeln(txt,'ПРОТОКОЛ ОПЕРАЦИЙ НА СКЛАДЕ ЗА ПЕРИОД С '+s1+' по '+S2);
  While Not(Eof(protocol)) Do
   Begin
    Readln(protocol,ws);
    If Not(Pos('--------',ws)>0) Then
    ws:=Decode(ws);
    Writeln(txt,ws);
   End;
   Close(Protocol);
  end
  Else
    messagebox(^M+#3+'Не могу открыть файл протокола за '+s1+ '!',nil,mfError+mfCancelButton);
  Repeat
  Until UnLockPrWriteRead(s1);
End;
End;{если не воскресенье}
  End;

  Close(txt);
 NoInfo;
 ViewAsText(Path.ToTemp+S2+'.tmp',True);
 End;

End;

Procedure ViewVozwrat;
Var s1,s2:TDateString;
    protocol,txt : Text;
    i : word;
    ws : String;
    Cur,l1,l2 : LongInt;

Begin
 If DatePeriodDialog(s1,s2,True) Then
 Begin
 Assign(txt,Path.ToTemp+s2+'.tmp');
 i:=ioresult;
 rewrite(txt);
 i:=ioresult;
 if i<>0 then
  begin
   messagebox(^M+#3+'Не могу создать временный файл!',nil,mfError+mfCancelButton);
   exit;
  end;
 DInfo('Выполняю слияние протоколов возврата...');
 l1:=DAteStringToDate(DateMask,s1);
 l2:=DAteStringToDate(DateMask,s2);

 For Cur:=l1 To L2 Do
 Begin
{    If DayOfWeek(Cur)<>Sunday Then}
     Begin
 s1:=DAteToDAteString(DAteMask,Cur);
 Assign(protocol,Path.Toprotocol+s1+'.vpr');
 If LockreturnWriteRead(s1) Then
Begin
 i:=ioresult;
 reset(protocol);
 i:=ioresult;
 if i=0 then
  begin
  If Cur=L1 Then
   Writeln(txt,'ПРОТОКОЛ КОРРЕКТИРОВОК И ВОЗВРАТОВ НА СКЛАДЕ ЗА ПЕРИОД С '+s1+' по '+S2);
  While Not(Eof(protocol)) Do
   Begin
    Readln(protocol,ws);
    If Not(Pos('--------',ws)>0) Then
    ws:=Decode(ws);
    Writeln(txt,ws);
   End;
   Close(Protocol);
  end
  Else
    messagebox(^M+#3+'Не могу открыть файл протокола возврата за '+s1+ '!',nil,mfError+mfCancelButton);
  Repeat
  Until UnLockreturnWriteRead(s1);
End;
End;{если не воскресенье}
  End;
 Close(txt);
 NoInfo;
 ViewAsText(Path.ToTemp+S2+'.tmp',True);
 End;
End;

{
Procedure ViewVozwrat;
Var s:TDateString;
Begin
 If DateDialog(s) Then
 ViewAsText(Path.ToProtocol+S+'.vpr',True);
End;
}

{
Procedure ViewVozwrat;
Var s:TDateString;
    protocol,txt : Text;
    i : word;
    ws : String;
Begin
 If DateDialog(s) Then
 Begin
 Assign(txt,Path.ToTemp+s+'.tmp');
 i:=ioresult;
 rewrite(txt);
 i:=ioresult;
 if i<>0 then
  begin
   messagebox(^M+#3+'Не могу создать временный файл!',nil,mfError+mfCancelButton);
   exit;
  end;

 Assign(protocol,Path.Toprotocol+s+'.vpr');
 i:=ioresult;
 reset(protocol);
 i:=ioresult;
 if i<>0 then
  begin
   Close(txt);
   messagebox(^M+#3+'Не могу открыть файл протокола возврата!',nil,mfError+mfCancelButton);
   exit;
  end;
  While Not(Eof(protocol)) Do
   Begin
    Readln(protocol,ws);
    Writeln(txt,ws);
   End;

  Close(txt);
  Close(Protocol);

 ViewAsText(Path.ToTemp+S+'.tmp',True);
 End;
End;
}

End.
