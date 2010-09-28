{$I Compile.INC}

{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}
Unit utils6;


Interface


Uses Glob,Views,Dialogs,ServSTr,Utils;


Procedure NewTmpAndAnalys;
Procedure NewTmpAndAnalysLocal;
Procedure ReadNewCFG(Var Res : LongInt);
{Procedure WriteNewCFG(Var Res : LongInt);}
Function ReadNewSystemIni(Var Res : LongInt):Boolean;

{Procedure CalcNDSP(E:PPrihodType;VidZakupka:Word;Var Zakup,NDS,NDS20,NDS10,NDS_,Litr,ZakupkaOutNDS,NDSZ:Real);}
{
Procedure CalcNDSP(E:PPrihodType;VidZakupka:Word;Var Zakup,NDS,NDS20,NDS10,NDS_,Litr,ZakupkaOutNDS,NDSZ,
ZakupkaOutNDS20,ZakupkaOutNDS10,ZakupkaOutNDS_,Litr20,Litr10,Litr_:Real;Var MMM:Maska3);
}
Procedure LoadMonitorZen;



implementation


Uses App,Serv,Objects,DbEngine,MsgBox,StHolder,Utils5,Utils4,Net,Mail,ColorTxt,
     Dos,Filetool,NetDbEng,Utils3,NetCall,ServStr2,
     Drivers,Printers,TPDate,Prise,Protect,MyView,Tools,Validate;

Const
     SklTMP='c:\TMPS';
     SklTMP1='TMP';
     SklTMP2='Analys';





Function TestExistCatalog(s:String):Boolean;
Var f : File;
    c : Word;
Begin
TestExistCatalog:=False;
Assign(f,s+'\test.txt');
c:=IoResult;
rewrite(f);
c:=IoResult;
If c<>0 Then Exit;
Close(f);
c:=IoResult;
Erase(f);
c:=IoResult;
TestExistCatalog:=(IOResult=0);
End;



Function ReadNewSystemIni(Var Res : LongInt):Boolean;
Const CC=20;

Var f : Text;
    i : Word;
    c : Byte;
    s,s1 : String;
    R : TRect;
    SH: TStringHolder;
    ShetConfig : Word;
    Num : ArtikulStr;
    ConfigName : Array[1..30] of String[CC];
    Config : Array[1..30] of String[CSertif];
    ConfigCmd : Array[1..30] of TMyString;
    Dlg : PDialog;
    ControlG,Control : PView;
    ListConfig : PBoxNew;
    LastK:ArtikulStr;
    Event : TEvent;

Function GetAsString(Name:AllStr):String;
Begin
GetAsString[0]:=#0;
GetAsString:=SH.GetString (Name);
End;

Begin
If FindParam('/CPATH=')Then
For c:=1 To ParamCount Do
 Begin
  s:=ParamStr(c);
  If Pos('/CPATH=',s)>0 Then
   Begin
    System.Delete(s,1,7{12});
    PathToConfig:=NewStr(s);{вариант принудительной передачи размещения конфигурации в ком.строке}
    ConfigCmdParameters[0]:=#0;
    res:=0;
    Exit;
   End;
 End;

ReadNewSystemIni:=True;
Assign (f,'system.ini');
Res := IOResult;
Reset(f);
Res := IOResult;
If Res <> 0 Then
 Begin
  PathToConfig:=NewStr('нет');{текущий каталог}
  ConfigCmdParameters[0]:=#0;
  Exit;
 End;
Close(f);
Res := IOResult;

SH.Init;
SH.LoadFromFile ('system.ini');

ShetConfig:=0;

For c:=1 To 30 Do
Begin
Config[c,0]:=#0;
ConfigNAme[c,0]:=#0;
ConfigCmd[c,0]:=#0;
Config[c]:=GetAsString('Config['+IntToStr(c,CMantissa)+']');
DelSpaceRight(Config[c]);
ConfigName[c]:=GetAsString('ConfigName['+IntToStr(c,CMantissa)+']');
ConfigCmd[c]:=GetAsString('ConfigCmd['+IntToStr(c,CMantissa)+']');

If Config[c,0]<>#0 Then
 Begin
  Inc(ShetConfig);
 End;
End;

{нет конфигураций}
If ShetConfig=0 Then
 Begin
  ReadNewSystemIni:=False;
  PathToConfig:=NewStr('нет');{текущий каталог}
  ConfigCmdParameters[0]:=#0;
  sh.Done;
  Exit;
 End;

{одна конфигурация}
If ShetConfig=1 Then
 Begin
  For c:=1 To 30 Do
   Begin
    If Config[c,0]<>#0 Then
    Begin
     PathToConfig:=NewStr(Config[c]);
     ConfigCmdParameters:=ConfigCmd[c];
     break;
    End;
   End;{For}
  sh.Done;
  Exit;
 End;

{вариант нескольких конфигураций}
R.Assign(27, 6, 53, 16);
New(Dlg, Init(R, 'Укажите объект'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx:=$E081;

R.Assign(25, 1, 26, 9);
Control := New(PScrollBar, Init(R));
Dlg^.Insert(Control);

R.Assign(15, 9, 25, 10);
ControlG := New(PScrollBar, Init(R));
ControlG^.Options := ControlG^.Options or ofPostProcess;
Dlg^.Insert(ControlG);

R.Assign(1, 1, 25, 9);
ListConfig := New(PBoxNew, Init(R, 1,
PScrollBar(ControlG), PScrollBar(Control)));
ListConfig^.NewList(New(PMyCollection, Init(0,1)));

For c:=1 To 30 Do
 Begin
  If Config[c,0]<>#0 Then
   Begin
    Format(ConfigName[c],CC);
    Num:=IntToStr(c,CMAntissa);
    RFormatZerro(Num,CMAntissa);
    Format(Config[c],CSertif);
    Format(ConfigCmd[c],152);
    ListConfig^.List^.Insert(NewStr(ConfigName[c]+'│'+Num+'│'+
    Config[c]+'│'+ConfigCmd[c]));
    ListConfig^.SetRange(ListConfig^.List^.Count);
   End;
 End;

{
 LastK:=inttostr(Strtoint(LastSkladKod),CMantissa);
 RFormatZerro(LastK,CMantissa);
 FindSymbol:=2;
 FindStrok:=LastK;
 Event.CharCode:=#255;
 Event.What:=evKeyDown;
 Application^.PutEvent(Event);
}

{помнить последний склад из которого выходишь}
If LastSkladKod[0]<>#0 Then
 Begin
 LastK:=inttostr(Strtoint(LastSkladKod),CMantissa);
 RFormatZerro(LastK,CMantissa);
 FindSymbol:=2;
 FindStrok:=LastK;
 Event.CharCode:=#255;
 Event.What:=evKeyDown;
 Application^.PutEvent(Event);
 End;


Dlg^.Insert(ListConfig);

{R.Assign(2, 5, 72, 6);
Control := New(PStaticText, Init(R, '12345678901234567890123456│01│1234567'+
     '8901234567890123456789012345678901234567890'));
Dlg^.Insert(Control);}


Dlg^.SelectNext(False);
i:=Desktop^.ExecView(Dlg);
If i<>cmCAncel Then
 Begin
  s:=ListConfig^.GetText(ListConfig^.Focused,ListConfig^.List^.Count);
  s1:=Config[StrToInt(Copy(s,1+CC+1,CMantissa))];
  DelSpaceRight(s1);
  PathToConfig:=NewStr(s1);
  ConfigCmdParameters:=Configcmd[StrToInt(Copy(s,1+CC+1,CMantissa))];
  DelSpaceRight(ConfigCmdParameters);
 End
 Else
  Begin
   ReadNewSystemINI:=False;
   PathToConfig:=NewStr('нет');
   ConfigCmdParameters:='';
  End;



Dispose(ListConfig,Done);
Dispose(Controlg,Done);
Dispose(Control,Done);
Dispose(Dlg,Done);

Sh.Done;


{несколько конфигураций}
(*
Readln(f,s);
Res := IOResult;
If Res<>0 Then Exit;
PathToConfig:=NewStr(s);
Res := IOResult;
Close(f);
Res := IOResult;
*)
End;





Procedure ReadNewCFG(Var Res : LongInt);
Var f : Text;
    i : Byte;
    Art : ArtikulStr;
    s : String;
    c : Byte;
    SH: TStringHolder;


Function GetAsString(Name:AllStr):String;
Begin
GetAsString[0]:=#0;
GetAsString:=SH.GetString (Name);
End;

Function GetAsInteger(Name:AllStr):LongInt;
Begin
GetAsInteger:=0;
GetAsInteger:=StrToInt(SH.GetString (Name));
End;

Function GetAsReal(Name:AllStr):Real;
Begin
GetAsReal:=0;
GetAsReal:=StrToReal(SH.GetString (Name));
End;


Function ReplacePsevdo(s:String):String;
Var Buf,st : String;
    Max,j : Word;
BEgin
ReplacePsevdo[0]:=#0;
Max:=Ord(s[0]);
st[0]:=#0;
Buf[0]:=#0;
For j:=1 To Max Do
 Begin
  If (s[j]='#') Then
   Begin
    If Buf[0]<>#0 Then
      Begin
          st:=st+Chr(StRToInt(Buf));
       Buf[0]:=#0;
      End;
    Continue;
   End;
  Buf:=Buf+s[j];
 End;{For}

    If Buf[0]<>#0 Then
      Begin
          st:=st+Chr(StRToInt(Buf));
      End;

ReplacePsevdo:=st;
End;


Procedure ReadDistanation(Var Res : LongInt);
Begin
Res := IOResult;
If Res <> 0 Then Exit;

Path^.Dat.ToProgram:=GetAsString('ToProgram');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

GetDir(0,Path^.Dat.ToProgram);
Path^.Dat.ToProgram:=Path^.Dat.ToProgram+'\';


Path^.Dat.ToUtils:=GetAsString('ToUtils');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

Path^.Dat.ToSPR:=GetAsString('ToSPR');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

Path^.Dat.ToPrihod :=GetAsString('ToPrihod');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;
Path^.Dat.ToMArket :=GetAsString('ToMArket');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;
Path^.Dat.ToMArketIndex :=GetAsString('ToMArketIndex');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;
Path^.Dat.ToReturn  :=GetAsString('ToReturn');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;
Path^.Dat.ToCorrect :=GetAsString('ToCorrect');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;
Path^.Dat.ToClient  :=GetAsString('ToClient');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;
Path^.Dat.ToClientBaseIndex  :=GetAsString('ToClientBaseIndex');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;
Path^.Dat.ToClientIndex  :=GetAsString('ToClientIndex');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;
Path^.Dat.ToDolg  :=GetAsString('ToDolg');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;
Path^.Dat.ToClientReturn  :=GetAsString('ToClientReturn');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;
Path^.Dat.ToClientOplata  :=GetAsString('ToClientOplata');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;
Path^.Dat.ToOplata :=GetAsString('ToOplata');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;
Path^.Dat.ToOperator:=GetAsString('ToOperator');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;
Path^.Dat.ToName:=GetAsString('ToName');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;
Path^.Dat.ToIndex:=GetAsString('ToIndex');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;
Path^.Dat.ToRazdel:=GetAsString('ToRazdel');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;
Path^.Dat.ToSklad:=GetAsString('ToSklad');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;
Path^.Dat.ToFantomBaz:=GetAsString('ToFantomBaz');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;
Path^.Dat.ToSkidki:=GetAsString('ToSkidki');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;
Path^.Dat.ToModem:=GetAsString('ToModem');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

Path^.Dat.ToArchiv:=GetAsString('ToArchiv');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

Path^.Dat.ArchivCode:=GetAsString('ArchivCode');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

Path^.Dat.ToReport:=GetAsString('ToReport');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

Path^.Dat.ToProtocol:=GetAsString('ToProtocol');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

Path^.Dat.ToRewisia:=GetAsString('ToRewisia');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;
Path^.Dat.FileFlag:=GetAsString('FileFlag');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

Path^.Dat.ToTemp:=GetAsString('ToTemp');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

Path^.Dat.ToTemp:={Path^.Dat.ToProgram+'Temp';}SklTmp+'\'+SklTmp1;
If Not TestExistCatalog(Path^.Dat.ToTemp)Then
Begin
MkDir(SklTmp);
c:=IoResult;
MkDir(Path^.Dat.ToTemp);
c:=IoResult;
if c <> 0 then
  MessageBox(#3'Ошибка создания '+Path^.Dat.ToTemp+' Код:'+IntToStr(c,CKol),Nil,mfError+mfCancelButton);
End;
Path^.Dat.ToTemp:=Path^.Dat.ToTemp+'\';



Path^.Dat.ToAnalys:=GetAsString('ToAnalys');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

Path^.Dat.ToAnalys:={Path^.Dat.ToProgram+'Analys'}SklTmp+'\'+SklTmp2;

If Not TestExistCatalog(Path^.Dat.ToAnalys)Then
Begin
MkDir(SklTmp);
c:=IoResult;
MkDir(Path^.Dat.ToAnalys);
c:=IoResult;
if c <> 0 then
  MessageBox(#3'Ошибка создания '+Path^.Dat.ToAnalys+' Код:'+IntToStr(c,CKol),Nil,mfError+mfCancelButton);
End;
Path^.Dat.ToAnalys:=Path^.Dat.ToAnalys+'\';


Path^.Dat.ToBarter:=GetAsString('ToBarter');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;
Path^.Dat.ToTransport:=GetAsString('ToTransport');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;
Path^.Dat.ToTerminal:=GetAsString('ToTerminal');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;
Path^.Dat.ToRemoteDir:=GetAsString('ToRemoteDir');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;
Path^.Dat.ToWinLnk:=GetAsString('ToWinLnk');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;
Path^.Dat.PriceName:=GetAsString('PriceName');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;
Path^.Dat.ToFlagDir:=GetAsString('ToFlagDir');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;
Path^.Dat.ToText:=GetAsString('ToText');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;


Path^.Dat.ToRekwiziti:=GetAsString('ToRekwiziti');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

Path^.Dat.ToPhoto:=GetAsString('ToPhoto');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;


Path^.Dat.ToExcel:=GetAsString('ToExcel');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;


NetPath^.Dat.ToProgram:=GetAsString('_ToProgram');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;
(*
GetDir(0,NetPath^.Dat.ToProgram);
NetPath^.Dat.ToProgram:=NetPath^.Dat.ToProgram+'\';
*)

NetPath^.Dat.ToUtils:=GetAsString('_ToUtils');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

NetPath^.Dat.ToSPR:=GetAsString('_ToSPR');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

NetPath^.Dat.ToPrihod :=GetAsString('_ToPrihod');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;
NetPath^.Dat.ToMArket :=GetAsString('_ToMArket');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;
NetPath^.Dat.ToMArketIndex :=GetAsString('_ToMArketIndex');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;
NetPath^.Dat.ToReturn  :=GetAsString('_ToReturn');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;
NetPath^.Dat.ToCorrect :=GetAsString('_ToCorrect');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;
NetPath^.Dat.ToClient  :=GetAsString('_ToClient');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;
NetPath^.Dat.ToClientBaseIndex  :=GetAsString('_ToClientBaseIndex');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;
NetPath^.Dat.ToClientIndex  :=GetAsString('_ToClientIndex');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;
NetPath^.Dat.ToDolg  :=GetAsString('_ToDolg');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;
NetPath^.Dat.ToClientReturn  :=GetAsString('_ToClientReturn');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;
NetPath^.Dat.ToClienToplata  :=GetAsString('_ToClienToplata');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;
NetPath^.Dat.ToOplata :=GetAsString('_ToOplata');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;
NetPath^.Dat.ToOperaTor:=GetAsString('_ToOperator');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;
NetPath^.Dat.ToName:=GetAsString('_ToName');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;
NetPath^.Dat.ToIndex:=GetAsString('_ToIndex');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;
NetPath^.Dat.ToRazdel:=GetAsString('_ToRazdel');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;
NetPath^.Dat.ToSklad:=GetAsString('_ToSklad');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;
NetPath^.Dat.ToFanTomBaz:=GetAsString('_ToFantomBaz');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;
NetPath^.Dat.ToSkidki:=GetAsString('_ToSkidki');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;
NetPath^.Dat.ToModem:=GetAsString('_ToModem');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

NetPath^.Dat.ToArchiv:=GetAsString('_ToArchiv');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

NetPath^.Dat.ArchivCode:=GetAsString('_ArchivCode');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

NetPath^.Dat.ToReport:=GetAsString('_ToReport');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

NetPath^.Dat.ToProTocol:=GetAsString('_ToProtocol');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

NetPath^.Dat.ToRewisia:=GetAsString('_ToRewisia');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;
NetPath^.Dat.FileFlag:=GetAsString('_FileFlag');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

NetPath^.Dat.ToTemp:=GetAsString('_ToTemp');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;
(*
NetPath^.Dat.ToTemp:={NetPath^.Dat.ToProgram+'Temp';}SklTmp+'\'+SklTmp1;
If Not TestExistCatalog(NetPath^.Dat.ToTemp)Then
Begin
MkDir(SklTmp);
c:=IoResult;
MkDir(NetPath^.Dat.ToTemp);
c:=IoResult;
if c <> 0 then
  MessageBox(#3'Ошибка создания '+NetPath^.Dat.ToTemp+' Код:'+IntToStr(c,CKol),Nil,mfError+mfCancelButTon);
End;
NetPath^.Dat.ToTemp:=NetPath^.Dat.ToTemp+'\';
*)


NetPath^.Dat.ToAnalys:=GetAsString('_ToAnalys');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

(*
NetPath^.Dat.ToAnalys:={NetPath^.Dat.ToProgram+'Analys'}SklTmp+'\'+SklTmp2;

If Not TestExistCatalog(NetPath^.Dat.ToAnalys)Then
Begin
MkDir(SklTmp);
c:=IoResult;
MkDir(NetPath^.Dat.ToAnalys);
c:=IoResult;
if c <> 0 then
  MessageBox(#3'Ошибка создания '+NetPath^.Dat.ToAnalys+' Код:'+IntToStr(c,CKol),Nil,mfError+mfCancelButTon);
End;
NetPath^.Dat.ToAnalys:=NetPath^.Dat.ToAnalys+'\';
*)

NetPath^.Dat.ToBarter:=GetAsString('_ToBarter');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;
NetPath^.Dat.ToTransport:=GetAsString('_ToTransport');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;
NetPath^.Dat.ToTerminal:=GetAsString('_ToTerminal');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;
NetPath^.Dat.ToRemoteDir:=GetAsString('_ToRemoteDir');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;
NetPath^.Dat.ToWinLnk:=GetAsString('_ToWinLnk');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;
NetPath^.Dat.PriceName:=GetAsString('_PriceName');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;
NetPath^.Dat.ToFlagDir:=GetAsString('_ToFlagDir');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;
NetPath^.Dat.ToText:=GetAsString('_ToText');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;


NetPath^.Dat.ToRekwiziti:=GetAsString('_ToRekwiziti');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

NetPath^.Dat.ToPhoTo:=GetAsString('_ToPhoto');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;


NetPath^.Dat.ToExcel:=GetAsString('_ToExcel');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;
End;



Begin

Assign (f,PathToConfig^+'sklad.cfg');
Res := IOResult;
Reset(f);
Res := IOResult;
If Res <> 0 Then Exit;
Close(f);
Res := IOResult;
SH.Init;
SH.LoadFromFile (PathToConfig^+'sklad.cfg');

Res := 0;

ReadDistanation(Res);


If Res<>0 Then Exit;


For c:=0 To 8 Do
Begin
AkzisKoeff[c]:=GetAsString('AkzisKoeff['+IntToStr(c,COne)+']');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;
End;


For c:=1 To 10 Do
Begin
NoClientStatKod[c]:=GetAsString('NoClientStat['+IntToStr(c,CMantissa)+']');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;
End;


ShemaAkzis:=GetAsInteger('ShemaAkzis');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

EnableImport:=GetAsInteger('EnableImport');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

AllSklads:=GetAsInteger('AllSklads');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

WordToBit30(AllSkladS,AllSkladMas);
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;
Convert30(AllSkladMas);

EnableAverageOtdel:=GetAsInteger('EnableAverageOtdel');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

AverageOtdel:=GetAsInteger('AverageOtdel');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;
WordToBit8(AverageOtdel,AverageOtdelMas);
Convert8(AverageOtdelMas);

For c:=1 To CDivision Do
 Begin
  If AverageOtdelMas[c]=1 Then Include(SetEnableOtdel,c); {заполняем список разрешенных отделений}
 End;

RegimOtsheta:=GetAsInteger('RegimOtsheta');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

DefaultSetMarker:=GetAsInteger('DefaultSetMarker');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

YesMarker:=GetAsString('YesMarker');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;
NoMarker:=GetAsString('NoMarker');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

remoteAccess:=GetAsInteger('remoteAccess');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

remoteProtocol:=GetAsInteger('remoteProtocol');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

RemoteScript:=GetAsInteger('remoteScript');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

EnableNewTovar:=GetAsInteger('EnableNewTovar');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;
EnableHandZeni:=GetAsInteger('EnableHandZeni');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

EnableAntiLock:=GetAsInteger('EnableAntiLock');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

EnableZakupka:=GetAsInteger('EnableZakupka');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

EnableRazdelSkidka:=GetAsInteger('EnableRazdelSkidka');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

EnableCommentMrk:=GetAsInteger('EnableCommentMrk');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;
{
PrintSeparatorPage:=GetAsInteger('PrintSeparatorPage');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;
}

DisableClose:=GetAsInteger('DisableClose');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;
DisableProtocol:=GetAsInteger('DisableProtocol');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

NetMonitoring:=GetAsInteger('NetMonitoring');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

NewGTD:=GetAsInteger('NewGTD');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

ShowDialogPrint:=GetAsInteger('ShowDialogPrint');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

PrintOGTD:=GetAsInteger('PrintOGTD');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

PrintOPhoto:=GetAsInteger('PrintOPhoto');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

NetworkPrinters:=GetAsString('NetworkPrinters');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

EnablePeremeshenie:=GetAsInteger('EnablePeremeshenie');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

EnablePrihod:=GetAsInteger('EnablePrihod');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;


EnableVeksel:=GetAsInteger('EnableVeksel');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

EnableMarket:=GetAsInteger('EnableMarket');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

EnableDolgControl:=GetAsInteger('EnableDolgControl');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

ShemaNazenka:=GetAsInteger('ShemaNazenka');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

EnableReturn:=GetAsInteger('EnableReturn');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

EnablePereozenka:=GetAsInteger('EnablePereozenka');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

EnableRewisia:=GetAsInteger('EnableRewisia');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

EnableConsigOplata:=GetAsInteger('EnableConsigOplata');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

EnableToolsRun:=GetAsInteger('EnableToolsRun');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

EnableBarter:=GetAsInteger('EnableBarter');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;


EnableAnalys:=GetAsInteger('EnableAnalys');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

EnableKassaOperation:=GetAsInteger('EnableKassaOperation');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

EnableControlKassa:=GetAsInteger('EnableControlKassa');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;



MarketSD:=GetAsInteger('MarketSD');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;


EnableRouteControl:=GetAsInteger('EnableRouteControl');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

EnableMarketPassword:=GetAsInteger('EnableMarketPassword');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;


FiktivSkidka:=GetAsInteger('FiktivSkidka');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

EnableAutoShk:=GetAsInteger('EnableAutoShk');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

EnablePosVersion:=GetAsInteger('EnablePosVersion');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

DisablePack:=GetAsInteger('DisablePack');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

EnableOtdel:=GetAsInteger('EnableOtdel');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;


PrihodFromClient:=GetAsInteger('PrihodFromClient');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

DefaultRazdelVid:=GetAsInteger('DefaultRazdelVid');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

AutoList:=GetAsInteger('AutoList');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

DefaultSkidka:=GetAsInteger('DefaultSkidka');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;


EnableBron:=GetAsInteger('EnableBron');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;



{разрешить использование предзаказов}
EnablePredZakaz:=GetAsInteger('EnablePredZakaz');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

{разбираемся с индексами}
EnableTovarIndex:=GetAsInteger('EnableTovarIndex');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

EnableDocumentIndex:=GetAsInteger('EnableDocumentIndex');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

EnableOborotIndex:=GetAsInteger('EnableOborotIndex');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

EnableManageZeni:=GetAsInteger('EnableManageZeni');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;





EnableSHK:=GetAsInteger('EnableSHK');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

EnableOtkat:=GetAsInteger('EnableOtkat');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

ZakazShema:=GetAsInteger('ZakazShema');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

VidZakupka:=GetAsInteger('VidZakupka');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

EnablePrivolye:=GetAsInteger('EnablePrivolye');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

PrivolyeProz:=GetAsReal('PrivolyeProz');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

{это страховка на случай если забыли в cfg-файле сделать настроку}
If PrivolyeProz<0.5 Then PrivolyeProz:=1.05;
If PrivolyeProz>2 Then PrivolyeProz:=1.05;


SortOtgruzka:=GetAsInteger('SortOtgruzka');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

If Not(SortOtgruzka in [0..4]) Then SortOtgruzka:=4;


SortPrihod:=GetAsInteger('SortPrihod');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

If Not(SortPrihod in [0..2]) Then SortPrihod:=1;

Nprint^.DAt.Printer:=GetAsInteger('Printer');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

Nprint^.DAt.Orient:=GetAsInteger('Orient');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

Nprint^.DAt.Port:=GetAsInteger('Port');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

Nprint^.DAt.SwapDisk:=GetAsInteger('SwapDisk');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

Nprint^.DAt.Computer:=GetAsString('Computer');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;


Nprint^.DAt.ShemaPrilB:=GetAsInteger('ShemaPrilB');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

Nprint^.DAt.PrintSeparatorPage:=GetAsInteger('PrintSeparatorPage');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;



Nprint^.DAt.Ini:=ReplacePsevdo(GetAsString('Ini'));
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;
{
Nprint^.DAt.CopyPrihod:=GetAsInteger('CopyPrihod');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

Nprint^.DAt.CopyPrz:=GetAsInteger('CopyPrz');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

Nprint^.DAt.CopyNKL:=GetAsInteger('CopyNkl');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

Nprint^.DAt.CopyTTN:=GetAsInteger('CopyTTN');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

Nprint^.DAt.CopySF:=GetAsInteger('CopySF');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

Nprint^.DAt.CopyReturn:=GetAsInteger('CopyReturn');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;
}
{новые константы печати}
NprintC^.DAt.CopyNaklC:=GetAsInteger('CNaklC');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

NprintC^.DAt.CopyNaklS:=GetAsInteger('CNaklS');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

NprintC^.DAt.CopyTTNC:=GetAsInteger('CTTNC');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

NprintC^.DAt.CopyTTNS:=GetAsInteger('CTTNS');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

NprintC^.DAt.CopySF:=GetAsInteger('CSF');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

NprintC^.DAt.CopyProtocol:=GetAsInteger('CProtocol');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

NprintC^.DAt.CopyPrilog:=GetAsInteger('CPrilog');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

NprintC^.DAt.CopyPrilog2:=GetAsInteger('CPrilog2');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

NprintC^.DAt.CopyShet:=GetAsInteger('CShet');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

NprintC^.DAt.CopyPamatka:=GetAsInteger('CPamatka');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

NprintC^.DAt.CopyGTDTTN:=GetAsInteger('CGTDTTN');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

NprintC^.DAt.CopyPKO:=GetAsInteger('CPKO');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

NprintC^.DAt.CopyRKO:=GetAsInteger('CRKO');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

NprintC^.DAt.CopyPrihod:=GetAsInteger('CPrihod');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

NprintC^.DAt.CopyReturn:=GetAsInteger('CReturn');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

NprintC^.DAt.CopyPrz:=GetAsInteger('CPrz');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

NprintC^.DAt.CopyRWZ:=GetAsInteger('CRwz');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

NprintC^.DAt.CopyZakaz:=GetAsInteger('CZakaz');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

NprintC^.DAt.CopyOtborka:=GetAsInteger('COtborka');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

NprintC^.DAt.CopyTrans:=GetAsInteger('CTrans');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

NprintC^.DAt.CopyAll:=GetAsInteger('CAll');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

NprintC^.DAt.CopyVeksel:=GetAsInteger('CVeksel');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

NprintC^.DAt.CopyKurzNakl:=GetAsInteger('CKurzNakl');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

NprintC^.DAt.AutoAnswerCopy:=GetAsInteger('AutoAnswerCopy');
{MemC(InTToStr(NprintC^.DAt.AutoAnswerCopy,CKol));}
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

NprintC^.DAt.AutoPrintRashod:=GetAsInteger('AutoPrintRashod');
{MemC(InTToStr(NprintC^.DAt.AutoPrintRashod,CKol));}
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;


{
     CopyNaklC   : LongInt;
     CopyNaklS   : LongInt;
     CopyTTNC    : LongInt;
     CopyTTNS    : LongInt;
     CopySF      : LongInt;
     CopyProtocol: LongInt;
     CopyPrilog  : LongInt;
     CopyPrilog2 : LongInt;
     CopyShet    : LongInt;
     CopyPamatka : LongInt;
     CopyGTDTTN  : LongInt;
     CopyPKO     : LongInt;
     CopyRKO     : LongInt;
     CopyPrihod  : LongInt;
     CopyReturn  : LongInt;
     CopyPrz     : LongInt;
     CopyRwz     : LongInt;
     CopyZakaz   : LongInt;
     CopyTrans   : LongInt;
     CopyAll     : LongInt;

}

Nprint^.DAt.FullSkidka:=GetAsInteger('FullSkidka');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

Nprint^.DAt.FullSertif:=GetAsInteger('FullSertif');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

WordToBit3(Nprint^.DAt.FullSertif,PrintSertifDoc);
Convert3(PrintSertifDoc);


Nprint^.DAt.FullAkzis:=GetAsInteger('FullAkzis');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

WordToBit3(Nprint^.DAt.FullAkzis,PrintAkzisDoc);
Convert3(PrintAkzisDoc);

Nprint^.DAt.FullGTD:=GetAsInteger('FullGTD');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

WordToBit3(Nprint^.DAt.FullGTD,PrintGTD);
Convert3(PrintGTD);

Nprint^.DAt.FullAkzizDate:=GetAsInteger('FullAkzizDate');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;
WordToBit3(Nprint^.DAt.FullAkzizDate,PrintAkzisDate);
Convert3(PrintAkzisDate);


Nprint^.DAt.FullExpert:=GetAsInteger('FullExpert');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;
WordToBit3(Nprint^.DAt.FullExpert,PrintExpert);
Convert3(PrintExpert);


Nprint^.DAt.FullName:=GetAsInteger('FullName');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

Nprint^.DAt.PrintPhoto:=GetAsInteger('PrintPhoto');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;


Nprint^.DAt.PrilogenieNakl:=GetAsInteger('PrilogenieNakl');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

Nprint^.DAt.PrintTTN:=GetAsInteger('PrintTTN');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

Nprint^.DAt.PrintTorg12:=GetAsInteger('PrintTorg12');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

Nprint^.DAt.PrintOtborka:=GetAsInteger('PrintOtborka');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

Nprint^.DAt.ShemaPhoto:=GetAsInteger('ShemaPhoto');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;
If Nprint^.DAt.ShemaPhoto>0 Then Nprint^.DAt.ShemaPhoto:=1;


Nprint^.DAt.PrintPrilogGTDTTN:=GetAsInteger('PrintPrilogGTDTTN');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

Nprint^.DAt.DisablePrint:=GetAsInteger('DisablePrint');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

Nprint^.DAt.EnablePrintRashetAkzis:=GetAsInteger('EnablePrintRashAkzis');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

If Not (Nprint^.DAt.EnablePrintRashetAkzis in [0,1]) Then Nprint^.DAt.EnablePrintRashetAkzis:=0;


EbanyMetro:=GetAsString('EbanyMetro');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;


Lizensia:=GetAsReal('Lizensia');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

DefaultDoc:=GetAsInteger('DefaultDoc');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

DefaultReal:=GetAsInteger('DefaultReal');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

MAsDocNumer:=GetAsInteger('MasDocNumer');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;
WordToBit9(MasDocNumer,MasDoc);
For i:=1 To Max9 Do
If MasDoc[i]=1 Then MasDoc[i]:=0
Else MasDoc[i]:=1;

DebitDocNumer:=GetAsInteger('DebitDocNumer');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;
WordToBit9(DebitDocNumer,DebitDoc);
For i:=1 To Max9 Do
If DebitDoc[i]=1 Then DebitDoc[i]:=0
Else DebitDoc[i]:=1;

Nprint^.DAt.Messag:=GetAsInteger('Messag');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

Nprint^.DAt.TimeStart:=GetAsString('TimeStart');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

Nprint^.DAt.TimeStop:=GetAsString('TimeStop');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

Nprint^.DAt.TextMessag:=GetAsString('TextMessag');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

DefaultLizensia:=GetAsInteger('DefaultLizensia');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

ShowClients:=GetAsInteger('ShowClients');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

ClientRP:=GetAsString('ClientRP');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

PrihodMax:=GetAsReal('PrihodMax');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

ShowNumer:=GetAsInteger('ShowNumer');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

EnableCashe:=GetAsInteger('EnableCashe');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

EnableFiltr:=GetAsInteger('EnableFiltr');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

Nprint^.DAt.ProtectScreen:=GetAsInteger('ProtectScreen');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

Nprint^.DAt.TimeProtectScreen:=GetAsString('TimeProtectScreen');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

Nprint^.DAt.ScreenSaverName:=GetAsString('ScreenSaverName');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

Compress:=GetAsInteger('Compress');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

AutoMarket:=GetAsInteger('AutoMarket');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

For c:=1 To CMaxSklads Do
Begin
PathSklads^.Dat.Path[c]:=GetAsString('ToExternalSklads['+IntToStr(c,CMantissa)+']');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;
End;

For c:=1 To Max30 Do
Begin
PathExpImp^.Dat.ToExport[c]:=GetAsString('ToExport['+IntToStr(c,CMantissa)+']');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;
End;

For c:=1 To Max30 Do
Begin
PathExpImp^.Dat.ToImport[c]:=GetAsString('ToImport['+IntToStr(c,CMantissa)+']');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;
End;

For c:=1 To 6 Do
Begin
FirstLockKod[c]:=GetAsString('FirstLockKod['+IntToStr(c,COne)+']');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;
End;

ZeniInZakaz:=GetAsInteger('ZeniInZakaz');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

EnableImportMake:=GetAsInteger('EnableImportMake');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

EnableImportGroup:=GetAsInteger('EnableImportGroup');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

Pharm:=GetAsInteger('Pharm');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

AutoDetect:=GetAsInteger('AutoDetect');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

DisablePrintXerox:=GetAsInteger('DisablePrintXerox');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

RunFromExit:=GetAsInteger('RunFromExit');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

RunFromClose:=GetAsInteger('RunFromClose');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

ReadOnlyConst:=GetAsInteger('ReadOnly');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;


Terminal:=GetAsInteger('Terminal');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

ChangeAdress:=GetAsInteger('ChangeAdress');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

DisableControlTulaSpirt:=GetAsInteger('DisableControlTulaSpirt');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

EnableTempLock:=GetAsInteger('EnableTempLock');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;


DisableControlOtsr:=GetAsInteger('DisableControlOtsr');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

DisableControlMinNazenka:=GetAsInteger('DisableControlMinNazenka');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;


DisableControlMinNazCl:=GetAsInteger('DisableControlMinNazCl');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;


OnlyOneCopy:=GetAsInteger('EnableControlOnlyOneCopy');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

DisableAutoFlagName:=GetAsInteger('DisableAutoFlag');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

DisableOtgruzkaSertif:=GetAsInteger('DisableOtgruzkaSertif');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

EnableSpisanie:=GetAsInteger('EnableSpisanie');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;


EnableDixyZeni:=GetAsInteger('EnableDixyZeni');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

If EnableDixyZeni<>0 Then EnableDixyZeni:=1;

EnableControlZakupka:=GetAsInteger('EnableControlZakupka');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

If Not (EnableControlZakupka in [0..2]) Then EnableControlZakupka:=0;




ControlPricePosition:=GetAsInteger('ControlPricePosition');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

If ControlPricePosition>1 Then
 Begin
  ControlPricePosition:=0;{жесткий режим}
 End;


EnableSound:=GetAsInteger('EnableSound');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

ShowPath:=GetAsInteger('ShowPath');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;


ShowMarker:=GetAsInteger('ShowMarker');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

EnableMinNazenka:=GetAsInteger('EnableMinNazenka');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

GlobalProz:=GetAsString('GlobalProz');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;


MinReturnDate:=GetAsString('MinReturnDate');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

TimeActualCash:=GetAsInteger('TimeActualCash');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

AutoRefreshCash:=GetAsInteger('AutoRefreshCash');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

If AutoRefreshCash<20 Then AutoRefreshCash:=20;

PrintRec.Copy:=1;
If (Nprint^.DAt.Printer=2) And (Nprint^.DAt.Port in [0,2]) Then
Begin
 If (Not FindParam('/(ЦШТ2Л')) And (Not FindParam('/(W2K3'))
    Then PrintRec.LoadFont:=1
 Else PrintRec.LoadFont:=0;
End
Else
PrintRec.LoadFont:=0;
SH.Done;
AddProtocol('Чтение файла конфигурации '+PathToConfig^+'sklad.cfg','','');

End;



Procedure LoadMonitorZen;
Var f : Text;
    Res : Word;
    s : String;
    Art : ArtikulStr;
    TimeD : LongInt;
    Showing : Boolean;
Begin

Assign (f,Path^.DAt.ToOperator+'range');
Res := IOResult;
Reset(f);
Res := IOResult;
If Res <> 0 Then
 Begin
  If ControlPricePosition in [0] Then
   Begin
    MessageBox(#3'Файл ценовых ограничений не найден!'+^M+#3+ClicProgrammer^,Nil,mfError+mfCancelButton);
    If (Desktop^.Current=Nil) And (Application^.Current=Nil) Then
    AddProtocol('Файл ценовых ограничений не найден!','предупреждение оператору','{ценовые соглашения}');
   End;
  Exit;
 End;

If  (Desktop^.Current=Nil) And (Application^.Current=Nil) Then
Case ControlPricePosition Of
0:AddProtocolNoMsg('включен контроль цен','','{ценовые соглашения}');
1:AddProtocolNoMsg('отключен контроль цен','','{ценовые соглашения}');
Else AddProtocolNoMsg('Котроль цен не определен','','{ценовые соглашения}');
End;

 Dos.GetFTime(f,TimeD);
 If TimeD<>LastRange Then
Begin
  LastRange:=TimeD;

  If Not(Glob.GlobalShow) And Not(Glob.ShowMsg) And Not(Glob.ShowNetMsg)
  And (Desktop^.Current=Nil) And (Application^.Current=Nil) Then
   Begin

    Showing:=True;
    DInfoMsg('Обновляю ценовые ограничения...',False);

   End
   Else
    Showing:=False;


ListRange^.NewList(Nil);
ListRange^.NewList(New(PTextCollection, Init(0,1)));

While Not(Eof(f)) Do
 Begin
  Readln(f,s);
  s:=UpCases(s);
  If (Not(Pos('REM',s)=1)) And (Not(Pos(';',s)=1)) And (Not(Pos('│',s)=1)) Then
  Begin
    Art:=Copy(s,1,CArtikul);
    DelSpaceRight(s);

    If s[0]<>#0 Then
   Begin
    {Art:=CalcMainKod(Art); выключено потому как в этом файле и так должны быть
    только главные позиции}
    If Not TestElement(Art,ListRange) Then
     Begin
      If Showing Then
      Begin
       AddProtocolNoMsg('Обнаружено дублирование ценновых ограничений для позиции '+Art+'!','','');
       MessageBox(#3'Обнаружено дублирование ценновых ограничений для позиции '+Art+'!'+
    ClicProgrammer^,Nil,mfError+mfCancelButton);
      End;{If Showing Then}
     End;{If Not TestElement(Art,ListRange) Then}

     If s[0]<>#0 Then
      Begin
       ListRange^.List^.Insert(NewStr('│'+s));
       ListRange^.SetRange(ListRange^.List^.Count);
      End;{s[0]<>#0}
   End;
  End;{If (Not(Pos('REM',s)=1)) And (Not(Pos(';',s)=1)) And (Not(Pos('│',s)=1)) Then}


 End;{While}

If Showing Then
AddProtocolNoMsg('Загрузка ценовых ограничений завершена!',
'Действуют ограничения на '+IntToStr(ListRange^.List^.Count,CKol)+' позиции товара','');
End;

Res := IOResult;
Close(f);
Res := IOResult;

  If Showing Then NoInfoMsg;

End;









Procedure NewTmpAndAnalys;
Var c : Word;
    st : AllStr;
Begin
St:=IntToStr(StrToInt(Rek^.Dat.Kod),CMAntissa);
RFormatZerro(St,CMAntissa);
If FindParam('/TERMINAL') Or (Terminal=1) Then
Begin
Path^.Dat.ToTemp:=SklTmp+'\'+St+'-'+CurrentPassword;
If Not TestExistCatalog(Path^.Dat.ToTemp)Then
Begin
MkDir(Path^.Dat.ToTemp);
c:=IoResult;
{if c <> 0 then
  MessageBox(#3'Ошибка создания '+Path^.Dat.ToTemp+' Код:'+IntToStr(c,CKol),Nil,mfError+mfCancelButton);}
End;
Path^.Dat.ToTemp:=Path^.Dat.ToTemp+'\';


Path^.Dat.ToAnalys:=SklTmp+'\'+SklTmp2+'\'+St+'-'+CurrentPassword;
If Not TestExistCatalog(Path^.Dat.ToAnalys)Then
Begin
MkDir(Path^.Dat.ToAnalys);
c:=IoResult;
{if c <> 0 then
  MessageBox(#3'Ошибка создания '+Path^.Dat.ToAnalys+' Код:'+IntToStr(c,CKol),Nil,mfError+mfCancelButton);}
End;
Path^.Dat.ToAnalys:=Path^.Dat.ToAnalys+'\';
End;{If Terminal}
End;


Procedure NewTmpAndAnalysLocal;
Var c : Word;
   ss : ArtikulStr;
Begin
ss:=Rek^.Dat.Kod;
ss:=IntToStr(StrToInt(Rek^.Dat.Kod),CMantissa);
DelSpace(SS);
RFormatZerro(ss,CMantissa);

If Not(FindParam('/TERMINAL') Or (Terminal=1)) Then
Begin
Path^.Dat.ToTemp:=Path^.Dat.ToTemp+ss;
If Not TestExistCatalog(Path^.Dat.ToTemp)Then
Begin
MkDir(Path^.Dat.ToTemp);
c:=IoResult;
{if c <> 0 then
  MessageBox(#3'Ошибка создания '+Path^.Dat.ToTemp+' Код:'+IntToStr(c,CKol),Nil,mfError+mfCancelButton);}
End;
Path^.Dat.ToTemp:=Path^.Dat.ToTemp+'\';


Path^.Dat.ToAnalys:=Path^.Dat.ToAnalys+ss;
If Not TestExistCatalog(Path^.Dat.ToAnalys)Then
Begin
MkDir(Path^.Dat.ToAnalys);
c:=IoResult;
if c <> 0 then
  MessageBox(#3'Ошибка создания '+Path^.Dat.ToAnalys+' Код:'+IntToStr(c,CKol),Nil,mfError+mfCancelButton);
End;
Path^.Dat.ToAnalys:=Path^.Dat.ToAnalys+'\';
End;{If Terminal}
End;








Var DirInfo: SearchRec;         { For Windows, use TSearchRec }
    s : String;
Begin
LastSkladKod:='';
ControlPricePosition:=0;
(*
 FindFirst('c:\test', AnyFile, DirInfo);
 while DosError=0 do
 begin
    s:=DirInfo.Name;
    Writeln(s,' ',DirInfo.Time);
    Readln;
    FindNext(DirInfo);
 end;{While}


 Writeln(GetFileTime('c:\test'));
    Readln;
    *)

End.