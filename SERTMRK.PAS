{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}


{$I Compile.INC}

Unit SertMrk;

Interface

Uses  Dialogs,Drivers,Glob,Access,Access3,ServStr,MyCalc;

Type
  PCartMrkWindow = ^TCartMrkWindow;
  TCartMrkWindow = object(TDialog)
   Calc        : PMyCalculator;
   GroupWin    : PGroupWindow;
    Procedure Ini(s:TMyString);
    procedure HandleEvent(var Event: TEvent); virtual;
    Destructor Done;Virtual;
  end;


procedure CorrectSertifMrk(s:TMyString);
Function SaveDostavka(L:SuperMarketType;corr:boolean): boolean;

IMPLEMENTATION

uses App,DBEngine,Objects, MsgBox,Vision1,Vision5,Nastr,Protect,{Calc,}NetCall,Windos,
     MrkTool,UtilsP,Utils2,Views,
     Utils,ColorTxt,Serv,InpLong,Validate,CPrihod,TpDate,Net,NetDbEng;

var SArtikul:ArtikulStr;
    InPut : InputType;
    CartWinSklad : PCartmRKWindow;
     ControlModifyTime,ControlFullName,
 ControlModifyDate,ControlOperator,ControlDiviSion,
 Control1,Control2,Control3,Control4,Control5,
 Control6,Control7,Control8,ControlRazdel,ControlPost,
 ControlNGroup,ControlNakl,ControlDateNakl,
 Control_IO,Control_IR,Control_IL,ControlSertif,ControlAkzis,ControlL,
 ControlOZ,ControlRZ,ControlMake,ControlNDS, ControllNDS,ControlLAkzis,
 ControlMarket,ControlRealiz,
 ControlLSertif,ControlLRZ,ControlLKol, COntrolLOZ,ControlPack,
 ControlDSertif,ControlKSertif,ControlPost1,
 ControlNalog : PView;

Function SaveDostavka(L:SuperMarketType;corr:boolean): boolean;
var f: file of DostavkaType;
    d,d1: PDostavkaType;
    rvolume,rmassa: real;
    i: integer;
    sDost: STRING[1];
    IORez: word;
Begin
   SaveDostavka:=false;
   {определяем - надо ли сохранять документ -
    - }
   sDost:=GetClientField(FPunkt2,l.ClientKod,0);
   if pos('-',sDost)>0 then exit;

   New(d,Init);
   rvolume:=0.0;
   rmassa:=0.0;
   {записываем значения}
   with d^.Dat do
   begin
     DocSelector:=L.DocSelector;
     DocOsn:= L.Document;
     DateDoc:= L.DateC;


     {DateDost:}
     ClientKod:= L.ClientKod;
     SumOplata:= L.SummaZ;
     for i:=1 to L.Amount do
     begin
      rmassa:=rmassa+StrToReal(GetIdField(FLitr,L.MarketElement[i].BazKOd))*
	   StrToReal(L.MarketElement[i].Input.Kol);
      rvolume:=rvolume++StrToReal(GetIdField(FVol,L.MarketElement[i].BazKOd))*
	   StrToReal(L.MarketElement[i].Input.Kol);

     end;
      MyStr(rvolume,Ckol,1,Vol);
      MyStr(rmassa,CLitr,1,Massa);
      EkspedKod:='';
     Maska:=GetClientField(fMaska,l.ClientKod,0);
     Marsh:=GetClientfield(FMarsh,L.ClientKod,0);
     Oformlen:=false;
   end;
   {сохраняем в файл доставки}
   Assign(f,Path.ToMarket+FDate+'.dst');
   IORez:=ioresult;
   Reset(f);
   IORez:=ioresult;
   if IORez<>0 then Rewrite(f);

if not corr then
 Begin
   IORez:=ioresult;
   Seek(f,FileSize(f));
   IORez:=ioresult;
   Write(f,d^.dat);
 End
 Else
 Begin
  New(d1,Init);
  While not eof(f) do
  begin
   read(f,d1^.Dat);
   if (StrToInt(d^.Dat.DocOsn)=StrToInt(d1^.Dat.DocOsn)) and
      (d^.Dat.DateDoc=d1^.Dat.DateDoc) then
      begin
        IORez:=ioresult;
        Seek(f,FilePos(f)-1);
        IORez:=ioresult;
        write(f,d^.Dat);
        break;
      end;
  end;
  Dispose(d1,Done);
 End;

   IORez:=ioresult;
   close(f);
   IORez:=ioresult;
   Dispose(d,Done);
   SaveDostavka:=true;

End;


procedure CorrectSertifMrk(s:TMyString);
BEgin
 {s:='Полная херь';
 format(s,CName);}
 CartWinSklad^.Ini(s);
End;

Procedure TCartMrkWindow.Ini(s:TMyString);
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
  Enables : Boolean;
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
Input.RealizovatDo:=BakGetField(FRealiz,SArtikul,0);
Input.Osn.NaklNumer:=BakGetField(FNaklOsn,SArtikul,0);
Input.Osn.DateNakl:=BakGetField(FDateOsn,SArtikul,0);


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
Enables:=False;

If Password(8) Then Enables:=True;

DelSPace(Input.ZAkupka);
DelSPace(Input.R_Zena);
DelSPace(Input.O_Zena);
DelSPace(Input.RealizovatDo);
DelSPace(Input.Kol);
DelSpaceRight(Input.Post);
DelSpaceRight(Input.NSertif);
DelSpaceRight(Input.DSertif);
DelSpaceRight(Input.KSertif);
DelSpaceRight(Input.Akzis1);
DelSpaceRight(Input.Osn.NaklNumer);
DelSpace(Input.Osn.DateNakl);

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
Control1^.Options := Control1^.Options and not ofSelectable;
CartWinSklad^.Insert(Control1);
  PInputLine(Control1)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));


  R.Assign(26, 3, 29, 4);
  CartWinSklad^.Insert(New(PLabel, Init(R, '~1~:', Control1)));
Control1^.SetData(Input.DivisionS[1]);


R.Assign(39, 3, 46, 4);
Control2 := New(PInputLine, Init(R, CKol));
Control2^.Options := Control2^.Options and not ofSelectable;
CartWinSklad^.Insert(Control2);
  PInputLine(Control2)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));

  R.Assign(36, 3, 39, 4);
  CartWinSklad^.Insert(New(PLabel, Init(R, '~2~:', Control2)));
Control2^.SetData(Input.DivisionS[2]);

R.Assign(49, 3, 56, 4);
Control3 := New(PInputLine, Init(R, CKol));
Control3^.Options := Control3^.Options and not ofSelectable;
CartWinSklad^.Insert(Control3);
  PInputLine(Control3)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));

  R.Assign(46, 3, 49, 4);
  CartWinSklad^.Insert(New(PLabel, Init(R, '~3~:', Control3)));
Control3^.SetData(Input.DivisionS[3]);

R.Assign(59, 3, 66, 4);
Control4 := New(PInputLine, Init(R, CKol));
Control4^.Options := Control4^.Options and not ofSelectable;
CartWinSklad^.Insert(Control4);
  PInputLine(Control4)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));

  R.Assign(56, 3, 59, 4);
  CartWinSklad^.Insert(New(PLabel, Init(R, '~4~:', Control4)));
Control4^.SetData(Input.DivisionS[4]);

R.Assign(69, 3, 76, 4);
Control5 := New(PInputLine, Init(R, CKol));
Control5^.Options := Control5^.Options and not ofSelectable;
CartWinSklad^.Insert(Control5);
  PInputLine(Control5)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));

  R.Assign(66, 3, 69, 4);
  CartWinSklad^.Insert(New(PLabel, Init(R, '~5~:', Control5)));
Control5^.SetData(Input.DivisionS[5]);


R.Assign(29, 5, 36, 6);
Control6 := New(PInputLine, Init(R, CKol));
Control6^.Options := Control6^.Options and not ofSelectable;
CartWinSklad^.Insert(Control6);
  PInputLine(Control6)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));

  R.Assign(26, 5, 29, 6);
  CartWinSklad^.Insert(New(PLabel, Init(R, '~6~:', Control6)));
Control6^.SetData(Input.DivisionS[6]);


R.Assign(39, 5, 46, 6);
Control7 := New(PInputLine, Init(R, CKol));
Control7^.Options := Control7^.Options and not ofSelectable;
CartWinSklad^.Insert(Control7);
  PInputLine(Control7)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));

  R.Assign(36, 5, 39, 6);
  CartWinSklad^.Insert(New(PLabel, Init(R, '~7~:', Control7)));
Control7^.SetData(Input.DivisionS[7]);

R.Assign(49, 5, 56, 6);
Control8 := New(PInputLine, Init(R, CKol));
Control8^.Options := Control8^.Options and not ofSelectable;
CartWinSklad^.Insert(Control8);
  PInputLine(Control8)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));

  R.Assign(46, 5, 49, 6);
  CartWinSklad^.Insert(New(PLabel, Init(R, '~8~:', Control8)));
Control8^.SetData(Input.DivisionS[8]);




R.Assign(45, 6, 78, 7);
ControlNGroup := New(PColoredText, Init(R, #3+NGroup, $1F));
ControlNGroup^.Options := ControlNGroup^.Options Or not ofSelectable;
CartWinSklad^.Insert(ControlNGroup);
R.Assign(37, 6, 45, 7);
CartWinSklad^.Insert(New(PLabel, Init(R, 'Гр~у~ппа:', ControlNGroup)));



R.Assign(4, 7, 16, 8);
ControlNakl := New(PInputLine, Init(R, 20));
ControlNakl^.Options := ControlNakl^.Options and not ofSelectable;
CartWinSklad^.Insert(ControlNakl);

ControlNakl^.SetData(Input.Osn.NaklNumer);

  R.Assign(1, 7, 4, 8);
  CartWinSklad^.Insert(New(PLabel, Init(R, 'N:', ControlNakl)));

R.Assign(20, 7, 30, 8);
ControlDateNakl := New(PInputLine, Init(R, CDate));
  PInputLine(ControlDateNakl)^.Validator := New(PPXPictureValidator, Init(DateFiltr, True));
ControlDateNakl^.Options := ControlDateNakl^.Options and not ofSelectable;
CartWinSklad^.Insert(ControlDateNakl);

ControlDateNakl^.SetData(Input.Osn.DateNakl);

  R.Assign(16, 7, 20, 8);
  CartWinSklad^.Insert(New(PLabel, Init(R, 'от:', ControlDateNakl)));


ControlNakl^.Options := ControlNakl^.Options and not ofSelectable;
ControlDateNakl^.Options := ControlDateNakl^.Options and not ofSelectable;


R.Assign(38, 7, 48, 8);

if FindParam('/EZ') then
begin
ControllNDS := New(PInputLine, Init(R, CZena));
CartWinSklad^.Insert(ControllNDS);
ControllNDS^.Options := ControllNDS^.Options and not ofSelectable;
PInputLine(ControllNDS)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));
end
 else
  begin
  ControllNDS := New(PSInputLine, Init(R, CZena));
  ControllNDS^.Options := ControllNDS^.Options and not ofSelectable;
  CartWinSklad^.Insert(ControllNDS);
  PInputLine(ControllNDS)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));
  end;


{
ControlLNDS := New(PInputLine, Init(R, CZena));
CartWinSklad^.Insert(ControlLNDS);
  PInputLine(ControlLNDS)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));
}
 R.Assign(33, 7, 38, 8);
  CartWinSklad^.Insert(New(PLabel, Init(R, '~З~/Ц:', ControlLNDS)));
{ControllNDS^.SetData(Input.Zakupka);}

R.Assign(53, 7, 63, 8);
ControlLRZ := New(PInputLine, Init(R, CZena));
ControlLRZ^.Options := ControlLRZ^.Options and not ofSelectable;
CartWinSklad^.Insert(ControlLRZ);
  PInputLine(ControlLRZ)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));

  R.Assign(48, 7, 53, 8);
  CartWinSklad^.Insert(New(PLabel, Init(R, '~Р~/Ц:', ControlLRZ)));
ControlLRZ^.SetData(Input.R_Zena);

R.Assign(68, 7, 78, 8);
ControlLOZ := New(PInputLine, Init(R, CZena));
ControlLOZ^.Options := ControlLOZ^.Options and not ofSelectable;
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

R.Assign(66, 9, 76, 10);
ControlRealiz := New(PInputLine, Init(R, CDate));
  PInputLine(ControlRealiz)^.Validator := New(PPXPictureValidator, Init(DateFiltr, True));
CartWinSklad^.Insert(ControlRealiz);

R.Assign(56, 9, 66, 10);
CartWinSklad^.Insert(New(PLabel, Init(R, 'Годен до:', ControlRealiz)));
ControlRealiz^.SetData(Input.RealizovatDo);


R.Assign(8, 10, 43, 11);
ControllAkzis := New(PInputLine, Init(R, CAkzis1));
CartWinSklad^.Insert(ControllAkzis);

  R.Assign(2, 10, 8, 11);
  CartWinSklad^.Insert(New(PLabel, Init(R, '~Г~ТД:', ControllAkzis)));
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


{DrawPack;
DrawOpt;}

c:=Desktop^.ExecView(CartWinSklad);
If c<>cmCancel Then
 Begin
 (* Control1^.GetDAta(Input.DivisionS[1]);
  Control2^.GetDAta(Input.DivisionS[2]);
  Control3^.GetDAta(Input.DivisionS[3]);
  Control4^.GetDAta(Input.DivisionS[4]);
  Control5^.GetDAta(Input.DivisionS[5]);
  Control6^.GetDAta(Input.DivisionS[6]);
  Control7^.GetDAta(Input.DivisionS[7]);
  Control8^.GetDAta(Input.DivisionS[8]); *)
  {ControllNDS^.GetDAta(Input.Zakupka);}
(*  ControlNakl^.GetDAta(Input.Osn.NaklNumer);
  ControlDateNakl^.GetDAta(Input.Osn.DateNakl);
  ControllRZ^.GetDAta(Input.R_Zena);
  ControllOZ^.GetDAta(Input.R_Zena);   *)
  ControllSertif^.GetDAta(Input.NSertif);
  ControlDSertif^.GetData(Input.DSertif);
  ControlKSertif^.GetData(Input.KSertif);
  ControllAkzis^.GetDAta(Input.Akzis1);
  ControlRealiz^.GetDAta(Input.RealizovatDo);
  ControlPost1^.GetDAta(Input.Post);

(*  PStaticText(ControlNGroup)^.GetText(NGroup);
  System.Delete(NGroup,1,1);
  Input.NGroupKod:=Copy(NGroup,1+CNAme+1,CClientKod); *)


  {CartWinSklad^.GetData(Input);}
  Dispose(Control,Done);
  Dispose(CartWinSklad,Done);
  DelSpaceRight(Input.NSertif);
  DelSpaceRight(Input.Osn.NaklNumer);
  DelSpace(Input.Osn.DateNakl);
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

   If Input.Osn.NaklNumer[0]=#0 Then
    Begin
     If MessageBox('Не указан номер накладной поставки!'^M+
	#3'Желаете продолжить?',nil, mfError + mfOkCancel)=cmCancel Then GoTo 1;
    End;


   If Input.Osn.DateNakl[0]=#0 Then
    Begin
     If MessageBox('Не указана дата накладной поставки!'^M+
	#3'Желаете продолжить?',nil, mfError + mfOkCancel)=cmCancel Then GoTo 1;
    End;

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




   s:=s+Kol+'│'+R_Zena+'│'+Nazenka+'│';
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

   Read(BazFile,BazElement^.Dat);
   {модифицируем поля}


Input.Zakupka:=RealToStr(StrToReal(Input.Zakupka),CZena,CMantissa);
DelSpace(Input.Zakupka);
Input.R_Zena:=RealToStr(StrToReal(Input.R_Zena),CZena,CMantissa);
DelSpace(Input.R_Zena);
Input.O_Zena:=RealToStr(StrToReal(Input.O_Zena),CZena,CMantissa);
DelSpace(Input.O_Zena);

   Bazelement^.Dat.Input:=Input;
   BazElement^.Dat.Date:=FDate;
   BazElement^.Dat.Time:=Times;
   BazElement^.Dat.Employ:=True;
   BazElement^.Dat.Locked:=True;


   Seek(BazFile,FilePos(BazFile)-1);
   Write(BazFile,BazElement^.Dat);

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

Destructor TCartmRKWinDow.Done;
Begin
Dispose(ControlLSertif,Done);
Dispose(ControlKSertif,Done);
Dispose(ControlDSertif,Done);
Dispose(ControlLAkzis,Done);
Dispose(ControlRealiz,Done);
Dispose(ControlPost1,Done);
Dispose(ControlLKol,Done);
Dispose(ControlPack,Done);
Dispose(ControlLRZ,Done);
Dispose(ControlLOZ,Done);
TDialog.Done;
End;

procedure TCartmRKWindow.HandleEvent(var Event: TEvent);
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
  (*   PStaticText(ControlNGroup)^.GetText(S);
     System.Delete(S,1,1);
     GroupWin^.ShowGroupList(s,Test);
     PStaticText(ControlNGroup)^.Text^:=#3+S;

     Case Test Of
      0,3 :FocusNext(True);
      1,2 :FocusNext(False);
     Else;
          End;
                 *)
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
  {DrawOpt;}
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
  {If DrawP Then Begin
                 If (Control1^.State and sfFocused <> 0)Or
                    (Control2^.State and sfFocused <> 0)Or
                    (Control3^.State and sfFocused <> 0)Or
                    (Control4^.State and sfFocused <> 0)Or
                    (Control5^.State and sfFocused <> 0)Or
                    (Control6^.State and sfFocused <> 0)Or
                    (Control7^.State and sfFocused <> 0)Or
                    (Control8^.State and sfFocused <> 0)
				Then DrawPack;
                End; }
  End;
  ClearEvent(Event);
End;


BEGIN
END.