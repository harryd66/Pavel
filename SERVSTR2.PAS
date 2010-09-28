{$I Compile.INC}

{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}
Unit ServStr2;

Interface

Uses Objects,ServStr;

Type AllStr1 = String[20{минимум 16 а лучше динамической}];


Type TPrintersFont = record
      Bold : Array [0..4] Of AllStr1;
      NoBold: Array [0..4] Of AllStr1;
      Double: Array [0..4] Of AllStr1;
      NoDouble: Array [0..4] Of AllStr1;
      Pitch : Array [0..4] Of AllStr1;
      NoPitch : Array [0..4] Of AllStr1;
      Condensed0: Array [0..4] Of AllStr1;
      Condensed: Array [0..4] Of AllStr1;
      Condensed2: Array [0..4] Of AllStr1;
      Condensed3: Array [0..4] Of AllStr1;
      Condensed4: Array [0..4] Of AllStr1;
      Condensed5: Array [0..4] Of AllStr1;
      NoCondensed: Array [0..4] Of AllStr1;
      High : Array [0..4] Of AllStr1;
      High1 : Array [0..4] Of AllStr1;
      High2 : Array [0..4] Of AllStr1;
      High3 : Array [0..4] Of AllStr1;
      High4 : Array [0..4] Of AllStr1;
      NoHigh: Array [0..4] Of AllStr1;
      Italic: Array [0..4] Of   AllStr1;
      NoItalic: Array [0..4] Of AllStr1;
      MaxLine:Array [0..4] Of word;
      EndPage : Array [0..4] Of AllStr1;
      DopIni : Array[0..4] of AllStr1;
      OrientNormal : Array[0..4] of AllStr1;
      OrientAlbom  : Array[0..4] of AllStr1;
      MinInterval  : Array[0..4] of AllStr1;
      MinInterval2 : Array[0..4] of AllStr1;
      MinInterval3 : Array[0..4] of AllStr1;
      MinInterval4 : Array[0..4] of AllStr1;
      Normal       : Array[0..4] of AllStr1;
end;

Type PPrintersFont = ^TPrintersFontPtr;
     TPrintersFontPtr = object(TObject)
     Dat: TPrintersFont;
     constructor Init;
     destructor Done; virtual;
     end;

{строка выписки}
Type BankVipiskaElement =Record
     OperatorSelector : Word;{группа контрагентов}
     Kod       : String[CCLientKod];{код контрагента}
     Rashet    : Word;{0-наличные поступления;1-безналичные}
     BN        : BNType;{банковские реквизиты платежа}
     Summa     : String[CIZena];{зачисляемая сумма}
     Comment   : AllStr;{назначение платежа}
     ENd;

Type TBankVipiskaType =Record
     Element : Array [1..CMAx] Of BankVipiskaElement;
     Document: String[CDocNumer]; {номер документа}
     Summa   : String[CIZena];{Итоговая сумма выписки +/-}
     DateC   : LongInt;{дата создания}
     TimeC   : LongInt;{время создания}
     DateM   : LongInt;{дата изменения}
     TimeM   : LongInt;{время изменения}
     Caption : String[CRazdelKod];
     Status  : Word;{0-сформирована;1-введена на склад
	               {и корректироваться не может}
     Active  : Word;{0-активен;1-анулирован}
     Locked  : Boolean;
     LockCaption : String[CRazdelKod];
     LockComputer: String[CKto];
     End;

Type PBankVipiska = ^TBankVipiskaPtr;
     TBankVipiskaPtr = object(TObject)
     Dat: TBankVipiskaType;
     constructor Init;
     destructor Done; virtual;
     end;

Type BufPersonalType = Record
     Dat : Array [1..BufferVipiska] Of TBankVipiskaType;
End;


Var
    GlobalPrn : PPrintersFont;
    DelTovar,DelDocument,DelRazdel, DelOperator, DelBazName,
    MsgErrorRazdelDel, Zapret, DelAll,
    DelDoc,NoClient,NoMake, NoSertif, NoAkzis,NoNds,
    NoNalog,ErrorNds,ErrorNAlog, NullKol,NullFantomKol,
    ErrorZakupka,ErrorRZena, ErrorSpecZena,ErrorOZena, NoInput,
    ErrorClientFile,ErrorMakeFile,ErrorRazdelFile,ErrorOperatorFile,
    WarningTZakupka,WarningTZakupka2,WarningDZakupka,WarningDZakupka2,
    SeeTovar,ErrorClient,InternalDocumentError,ClicProgrammer,NullStr,
    TTNStr1,TTNStr2,TTNStr3,TTNStr4,
    Seria_Akzis,Expert_RegNom,
    WarningUpDAte,WarningToProgramer,NoKursUSD,NoCorrectKAssa,
    NoConsigClient,NoComplect,Monopolia,Line_Separator,ErrorReport,
    OkReport,FullReport,KurzReport,NoWorkStation,NoMArket,NoReportToExcel,
    WarningExport,REstructError,NoExistsModul,
    NazenkaError,SkidkaError,NoRightAccess,SrokDeistvIstekaet,SrokRealizIstekaet,
    WarningExportRepeat,WarningFoundEKRSERV,WarningFoundEKRSERV1,
    WarningNoOneCopy,FoundRunCopyProgram,NoLizensiaFromProgram,
    IstekSrokLizensii,IstekaetSrokLizensii,
    ReadOnlyStr,PathToConfig,PrilogenieNakl,
    EnableImportMakeS,PharmS,AutoDetectS,DisablePrintXeroxS,RunFromExitS,
    RunFromCloseS,ReadOnlyS,OnlyOneCopyS,TerminalS,ChangeAdressS,
    DisableControlTulaSpirtS,EnableTempLockS,EnableSSpisanie,
    DisableControlOtsrS,
    DisableSOtgruzkaS,DisableControlMinNazenkaS,DisableControlMinNazClS,
    NoPosition,ErrorOpen,Zanato1,Zanato2,NoLock,NoFound,NoRoznica: PString;

     EnableSpisanie,EnableDixyZeni,EnableControlZakupka,
  DisableOtgruzkaSertif,ControlPricePosition,EnableSound,
  AutoMarket,RunFromExit,RunFromClose,
  ReadOnlyConst,BakIni,Terminal,ChangeAdress,DisableControlMinNazenka,
     DisableControlMinNazCl: Word;


Procedure LoadResursMessage;
Procedure DisposeResursMessage;
Function StringToOrdString(s:string):string;
Function OrdStringToString(s:string):string;



Implementation


Uses StHolder,tpDate;

CONSTRUCTOR TPrintersFontPtr.Init;
var i: byte;
BEGIN
   inherited Init;
   with Dat do
   for i:=0 to 4 do
   begin
      Bold[i]:='';
      NoBold[i]:='';
      Double[i]:='';
      NoDouble[i]:='';
      Pitch[i]:='';
      NoPitch[i]:='';
      Condensed0[i]:='';
      Condensed[i]:='';
      Condensed2[i]:='';
      Condensed3[i]:='';
      Condensed4[i]:='';
      Condensed5[i]:='';
      NoCondensed[i]:='';
      High[i]:='';
      High1[i]:='';
      High2[i]:='';
      High3[i]:='';
      High4[i]:='';
      NoHigh[i]:='';
      Italic[i]:='';
      NoItalic[i]:='';
      MaxLine[i]:=0;
      EndPage[i]:='';
      DopIni[i]:='';
      OrientNormal[i]:='';
      OrientAlbom[i]:='';
      MinInterval[i]:='';
      MinInterval2[i]:='';
      MinInterval3[i]:='';
      MinInterval4[i]:='';
      Normal[i]:='';
   end;
END;




DESTRUCTOR TPrintersFontPtr.Done;
BEGIN
 inherited Done;
END;





Function StringToOrdString(s:string):string;
var i: word;
    str: string[4];
    rez: string;
Begin
  rez:='';
  for i:=1 to ord(s[0]) do
  begin
    str:='';
    Str:=IntToStr(ord(s[i]),CArtikul);
    DelSpace(str);
    rez:=rez+'#'+str;
  end;
  StringToOrdString:=rez;
End;



Function OrdStringToString(s:string):string;
var i: byte;
    rez: string;
    str: string[4];
Begin
  rez:='';
  while pos('#',s) > 0 do
  begin
    delete(s,1,1);
    i:=pos('#',s);
    if i>0 then
     begin
       str:=copy(s,1,i-1);
       delete(s,1,i-1);
     end
    else str:=s;
    rez:=rez+chr(StrToInt(str));
  end;
  OrdStringToString:=rez;
End;






Procedure LoadResursMessage;
Var s : String;
    c,i : Word;
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


Begin
SH.Init;
SH.LoadFromFile ('sklad.lng');

    DelTovar:=NewStr(^M+#3+GetAsString('DelTovar'));
    DelDocument:=NewStr(^M+#3+GetAsString('DelDocument'));
    DelRazdel:=NewStr(^M+#3+GetAsString('DelRazdel'));
    DelOperator:=NewStr(^M+#3+GetAsString('DelOperator'));
    DelBazName:=NewStr(^M+#3++GetAsString('DelBazName'));
    MsgErrorRazdelDel:=NewStr(^M+#3+GetAsString('MsgErrorRazdelDel'));
    Zapret:=NewStr(^M+#3+GetAsString('Zapret'));
    DelAll:=NewStr(^M+#3+GetAsString('DelAll'));
    DelDoc:=NewStr(^M+#3+GetAsString('DelDoc'));
    NoClient:=NewStr(^M+#3+GetAsString('NoClient'));
    NoMake:=NewStr(^M+#3+GetAsString('NoMake'));
    NoSertif:=NewStr(^M+#3+GetAsString('NoSertif'));
    NoAkzis:=NewStr(^M+#3+GetAsString('NoAkzis'));
    NoNds:=NewStr(^M+#3+GetAsString('NoNds'));
    NoNalog:=NewStr(^M+#3+GetAsString('NoNalog'));
    ErrorNds:=NewStr(^M+#3+GetAsString('ErrorNds'));
    ErrorNAlog:=NewStr(^M+#3+GetAsString('ErrorNAlog'));
    NullKol:=NewStr(^M+#3+GetAsString('NullKol'));
    NullFantomKol:=NewStr(^M+#3+GetAsString('NullFantomKol'));
    ErrorZakupka:=NewStr(^M+#3+GetAsString('ErrorZakupka'));
    ErrorRZena:=NewStr(^M+#3+GetAsString('ErrorRZena'));
    ErrorSpecZena:=NewStr(^M+#3+GetAsString('ErrorSpecZena'));
    ErrorOZena:=NewStr(^M+#3+GetAsString('ErrorOZena'));
    NoInput:=NewStr(^M+#3+GetAsString('NoInput'));
    ErrorClientFile:=NewStr(^M+#3+GetAsString('ErrorClientFile'));
    ErrorMakeFile:=NewStr(^M+#3+GetAsString('ErrorMakeFile'));
    ErrorRazdelFile:=NewStr(^M+#3+GetAsString('ErrorRazdelFile'));
    ErrorOperatorFile:=NewStr(^M+#3+GetAsString('ErrorOperatorFile'));
    WarningTZakupka:=NewStr(^M+#3+GetAsString('WarningTZakupka'));
    WarningTZakupka2:=NewStr(^M+#3+GetAsString('WarningTZakupka2'));
    WarningDZakupka:=NewStr(^M+#3+GetAsString('WarningDZakupka'));
    WarningDZakupka2:=NewStr(^M+#3+GetAsString('WarningDZakupka2'));
    SeeTovar:=NewStr(^M+#3+GetAsString('SeeTovar'));
    ErrorClient:=NewStr(^M+#3+GetAsString('ErrorClient'));
    InternalDocumentError:=NewStr(^M+#3+GetAsString('InternalDocumentError'));
    ClicProgrammer:=NewStr(^M+#3+GetAsString('ClicProgrammer'));
    Seria_Akzis:=NewStr(GetAsString('Seria_Akzis'));
    Expert_RegNom:=NewStr(GetAsString('Expert_RegNom'));
    NoConsigClient:=NewStr(^M+#3+GetAsString('NoConsigClient'));
    NoComplect:=NewStr(^M+#3+GetAsString('NoComplect'));
    Monopolia:=NewStr(#3+GetAsString('Monopolia'));
    Line_Separator:=NewStr(GetAsString('Line_Separator'));
    NullStr:=NewStr(GetAsString('NullStr'));
    TTNStr1:=NewStr(GetAsString('TTNStr1'));
    TTNStr2:=NewStr(GetAsString('TTNStr2'));
    TTNStr3:=NewStr(GetAsString('TTNStr3'));
    TTNStr4:=NewStr(GetAsString('TTNStr4'));
    WarningUpDAte:=NewStr(#3+GetAsString('WarningUpDAte'));
    WarningToProgramer:=NewStr(#3+GetAsString('WarningToProgramer'));
	    NoKursUSD:=NewStr(GetAsString('NoKursUSD'));
    NoCorrectKassa:=NewStr(GetAsString('NoCorrectKassa'));
    OkReport:=NewStr(#3+GetAsString('OkReport'));
    FullReport:=NewStr(GetAsString('FullReport'));
    KurzReport:=NewStr(GetAsString('KurzReport'));
    NoWorkStation:=NewStr(#3+GetAsString('NoWorkStation'));
    ReadOnlyStr:=NewStr(#3+GetAsString('ReadOnlyStr'));
    ErrorReport:=NewStr(GetAsString('ErrorReport'));
    NoMarket:=NewStr(^M+#3+GetAsString('NoMarket'));
    NoReportToExcel:=NewStr(^M+#3+GetAsString('NoReportToExcel'));
    WarningExport:=NewStr(#3+GetAsString('WarningExport'));
    RestructError:=NewStr(^M+#3+GetAsString('RestructError'));
    NoExistsModul:=NewStr(^M+#3+GetAsString('NoExistsModul'));
    NazenkaError:=NewStr(^M+#3+GetAsString('NazenkaError'));
    SkidkaError:=NewStr(^M+#3+GetAsString('SkidkaError'));
    NoRightAccess:=NewStr(^M+#3+GetAsString('NoRightAccess'));
    SrokDeistvIstekaet:=NewStr(GetAsString('SrokDeistvIstekaet'));
    SrokRealizIstekaet:=NewStr(GetAsString('SrokRealizIstekaet'));
    WarningExportRepeat:=NewStr(^M+#3+GetAsString('WarningExportRepeat'));
    WarningFoundEKRSERV:=NewStr(^M+^M+#3+GetAsString('WarningFoundEKRSERV'));
    WarningFoundEKRSERV1:=NewStr(^M+#3+GetAsString('WarningFoundEKRSERV1'));
    WarningNoOneCopy:=NewStr(^M+#3+GetAsString('WarningNoOneCopy'));
    FoundRunCopyProgram:=NewStr(#3+GetAsString('FoundRunCopyProgram'));
    NoLizensiaFromProgram:=NewStr(#3+GetAsString('NoLizensiaFromProgram'));
    IstekSrokLizensii:=NewStr(#3+GetAsString('IstekSrokLizensii'));
    IstekaetSrokLizensii:=NewStr(#3+GetAsString('IstekaetSrokLizensii'));

    EnableImportMakeS:=NewStr(GetAsString('EnableImportMake'));
    PharmS:=NewStr(GetAsString('Pharm'));
    AutoDetectS:=NewStr(GetAsString('AutoDetect'));
    DisablePrintXeroxS:=NewStr(GetAsString('DisablePrintXerox'));
    RunFromExitS:=NewStr(GetAsString('RunFromExit'));
    RunFromCloseS:=NewStr(GetAsString('RunFromClose'));
    ReadOnlyS:=NewStr(GetAsString('ReadOnly'));
    OnlyOneCopyS:=NewStr(GetAsString('EnableControlOnlyOneCopy'));
    TerminalS:=NewStr(GetAsString('Terminal'));
    ChangeAdressS:=NewStr(GetAsString('ChangeAdress'));
    DisableControlTulaSpirtS:=NewStr(GetAsString('DisableControlTulaSpirt'));
    EnableTempLockS:=NewStr(GetAsString('EnableTempLock'));
    DisableControlMinNazenkaS:=NewStr(GetAsString('DisableControlMinNazenka'));
    DisableControlMinNazClS:=NewStr(GetAsString('DisableControlMinNazCl'));
    DisableSOtgruzkaS:=NewStr(GetAsString('DisableOtgruzkaSertif'));
    EnableSSpisanie:=NewStr(GetAsString('EnableSpisanie'));
    DisableControlOtsrS:=NewStr(GetAsString('DisableControlOtsr'));

    NoPosition:=NewStr(GetAsString('NoPosition'));
    ErrorOpen:=NewStr(GetAsString('ErrorOpen'));
    Zanato1:=NewStr(GetAsString('Zanato1'));
    Zanato2:=NewStr(GetAsString('Zanato2'));
    NoLock:=NewStr(GetAsString('NoLock'));
    NoFound:=NewStr(GetAsString('NoFound'));
    NoRoznica:=NewStr(GetAsString('NoRoznica'));

    For c:=0 To 8 Do
     Begin
       GroupName[c]:=NewStr(GetAsString('GroupName['+IntToStr(c,COne)+']'));
     End;

New(GlobalPrn,Init);

for i:=0 to 4 do
Begin
  With GlobalPrn^.DAt Do
  Begin
  Bold[i]:=OrdStringToString(GetAsString('Bold['+IntToStr(i,1)+']'));
  If Not Sh.OkOp Then Begin
                     {MessageBox(#3^M+#3'Не обнаружен параметр Bold'+IntToStr(i,1),Nil,mfError+mfCancelButton);}
                     {Goto 45;}
                    End;
  NoBold[i]:=OrdStringToString(GetAsString('NoBold['+IntToStr(i,1)+']'));
  If Not Sh.OkOp Then Begin
                     {MessageBox(#3^M+#3'Не обнаружен параметр NoBold'+IntToStr(i,1),Nil,mfError+mfCancelButton);}
                     {Goto 45;}
                    End;
  Double[i]:=OrdStringToString(GetAsString('Double['+IntToStr(i,1)+']'));
  If Not Sh.OkOp Then Begin
                     {MessageBox(#3^M+#3'Не обнаружен параметр Double'+IntToStr(i,1),Nil,mfError+mfCancelButton);}
                     {Goto 45;}
                    End;
  NoDouble[i]:=OrdStringToString(GetAsString('NoDouble['+IntToStr(i,1)+']'));
  If Not Sh.OkOp Then Begin
                     {MessageBox(#3^M+#3'Не обнаружен параметр NoDouble'+IntToStr(i,1),Nil,mfError+mfCancelButton);}
                     {Goto 45;}
                    End;
  Pitch[i]:=OrdStringToString(GetAsString('Pitch['+IntToStr(i,1)+']'));
  If Not Sh.OkOp Then Begin
                     {MessageBox(#3^M+#3'Не обнаружен параметр Pitch'+IntToStr(i,1),Nil,mfError+mfCancelButton);}
                     {Goto 45;}
                    End;
  NoPitch[i]:=OrdStringToString(GetAsString('NoPitch['+IntToStr(i,1)+']'));
  If Not Sh.OkOp Then Begin
                     {MessageBox(#3^M+#3'Не обнаружен параметр NoPitch'+IntToStr(i,1),Nil,mfError+mfCancelButton);}
                     {Goto 45;}
                    End;
  Condensed0[i]:=OrdStringToString(GetAsString('Condensed0['+IntToStr(i,1)+']'));
  If Not Sh.OkOp Then Begin
                     {MessageBox(#3^M+#3'Не обнаружен параметр Condensed0'+IntToStr(i,1),Nil,mfError+mfCancelButton);}
                     {Goto 45;}
                    End;
  Condensed[i]:=OrdStringToString(GetAsString('Condensed['+IntToStr(i,1)+']'));
  If Not Sh.OkOp Then Begin
                     {MessageBox(#3^M+#3'Не обнаружен параметр Condensed'+IntToStr(i,1),Nil,mfError+mfCancelButton);}
                     {Goto 45;}
                    End;
  Condensed2[i]:=OrdStringToString(GetAsString('Condensed2['+IntToStr(i,1)+']'));
  If Not Sh.OkOp Then Begin
                     {MessageBox(#3^M+#3'Не обнаружен параметр Condensed2'+IntToStr(i,1),Nil,mfError+mfCancelButton);}
                     {Goto 45;}
                    End;
  Condensed3[i]:=OrdStringToString(GetAsString('Condensed3['+IntToStr(i,1)+']'));
  If Not Sh.OkOp Then Begin
                     {MessageBox(#3^M+#3'Не обнаружен параметр Condensed3'+IntToStr(i,1),Nil,mfError+mfCancelButton);}
                     {Goto 45;}
                    End;
  Condensed4[i]:=OrdStringToString(GetAsString('Condensed4['+IntToStr(i,1)+']'));
  If Not Sh.OkOp Then Begin
                     {MessageBox(#3^M+#3'Не обнаружен параметр Condensed4'+IntToStr(i,1),Nil,mfError+mfCancelButton);}
                     {Goto 45;}
                    End;
  Condensed5[i]:=OrdStringToString(GetAsString('Condensed5['+IntToStr(i,1)+']'));
  If Not Sh.OkOp Then Begin
                     {MessageBox(#3^M+#3'Не обнаружен параметр Condensed5'+IntToStr(i,1),Nil,mfError+mfCancelButton);}
                     {Goto 45;}
                    End;
  NoCondensed[i]:=OrdStringToString(GetAsString('NoCondensed['+IntToStr(i,1)+']'));
  If Not Sh.OkOp Then Begin
                     {MessageBox(#3^M+#3'Не обнаружен параметр NoCondensed'+IntToStr(i,1),Nil,mfError+mfCancelButton);
                     {Goto 45;}
                    End;
  High[i]:=OrdStringToString(GetAsString('High['+IntToStr(i,1)+']'));
  If Not Sh.OkOp Then Begin
                     {MessageBox(#3^M+#3'Не обнаружен параметр High'+IntToStr(i,1),Nil,mfError+mfCancelButton);}
                     {Goto 45;}
                    End;
  High1[i]:=OrdStringToString(GetAsString('High1['+IntToStr(i,1)+']'));
  If Not Sh.OkOp Then Begin
                     {MessageBox(#3^M+#3'Не обнаружен параметр High1'+IntToStr(i,1),Nil,mfError+mfCancelButton);}
                     {Goto 45;}
                    End;
  High2[i]:=OrdStringToString(GetAsString('High2['+IntToStr(i,1)+']'));
  If Not Sh.OkOp Then Begin
                     {MessageBox(#3^M+#3'Не обнаружен параметр High2'+IntToStr(i,1),Nil,mfError+mfCancelButton);}
                     {Goto 45;}
                    End;
  High3[i]:=OrdStringToString(GetAsString('High3['+IntToStr(i,1)+']'));
  If Not Sh.OkOp Then Begin
                     {MessageBox(#3^M+#3'Не обнаружен параметр High3'+IntToStr(i,1),Nil,mfError+mfCancelButton);}
                     {Goto 45;}
                    End;
  High4[i]:=OrdStringToString(GetAsString('High4['+IntToStr(i,1)+']'));
  If Not Sh.OkOp Then Begin
                     {MessageBox(#3^M+#3'Не обнаружен параметр High4'+IntToStr(i,1),Nil,mfError+mfCancelButton);}
                     {Goto 45;}
                    End;
  NoHigh[i]:=OrdStringToString(GetAsString('NoHigh['+IntToStr(i,1)+']'));
  If Not Sh.OkOp Then Begin
                     {MessageBox(#3^M+#3'Не обнаружен параметр NoHigh'+IntToStr(i,1),Nil,mfError+mfCancelButton);}
                     {Goto 45;}
                    End;
  Italic[i]:=OrdStringToString(GetAsString('Italic['+IntToStr(i,1)+']'));
  If Not Sh.OkOp Then Begin
                     {MessageBox(#3^M+#3'Не обнаружен параметр Italic'+IntToStr(i,1),Nil,mfError+mfCancelButton);}
                     {Goto 45;}
                    End;
  NoItalic[i]:=OrdStringToString(GetAsString('NoItalic['+IntToStr(i,1)+']'));
  If Not Sh.OkOp Then Begin
                     {MessageBox(#3^M+#3'Не обнаружен параметр NoItalic'+IntToStr(i,1),Nil,mfError+mfCancelButton);}
                     {Goto 45;}
                    End;
  MaxLine[i]:=GetAsInteger('MaxLine['+IntToStr(i,1)+']');
  If Not Sh.OkOp Then Begin
                     {MessageBox(#3^M+#3'Не обнаружен параметр MaxLine'+IntToStr(i,1),Nil,mfError+mfCancelButton);}
                     {Goto 45;}
                    End;
  EndPage[i]:=OrdStringToString(GetAsString('EndPage['+IntToStr(i,1)+']'));
  If Not Sh.OkOp Then Begin
                     {MessageBox(#3^M+#3'Не обнаружен параметр EndPage'+IntToStr(i,1),Nil,mfError+mfCancelButton);}
                     {Goto 45;}
                    End;
  DopIni[i]:=OrdStringToString(GetAsString('DopIni['+IntToStr(i,1)+']'));
  If Not Sh.OkOp Then Begin
                     {MessageBox(#3^M+#3'Не обнаружен параметр '+IntToStr(i,1),Nil,mfError+mfCancelButton);}
                     {Goto 45;}
                    End;
  OrientNormal[i]:=OrdStringToString(GetAsString('OrientNormal['+IntToStr(i,1)+']'));
  If Not Sh.OkOp Then Begin
                     {MessageBox(#3^M+#3'Не обнаружен параметр OrientNormal'+IntToStr(i,1),Nil,mfError+mfCancelButton);}
                     {Goto 45;}
                    End;
  OrientAlbom[i]:=OrdStringToString(GetAsString('OrientAlbom['+IntToStr(i,1)+']'));
  If Not Sh.OkOp Then Begin
                     {MessageBox(#3^M+#3'Не обнаружен параметр OrientAlbom'+IntToStr(i,1),Nil,mfError+mfCancelButton);}
                     {Goto 45;}
                    End;
  MinInterval[i]:=OrdStringToString(GetAsString('MinInterval['+IntToStr(i,1)+']'));
  If Not Sh.OkOp Then Begin
                     {MessageBox(#3^M+#3'Не обнаружен параметр MinInterval'+IntToStr(i,1),Nil,mfError+mfCancelButton);}
                     {Goto 45;}
                    End;
  MinInterval2[i]:=OrdStringToString(GetAsString('MinInterval2['+IntToStr(i,1)+']'));
  If Not Sh.OkOp Then Begin
                     {MessageBox(#3^M+#3'Не обнаружен параметр MinInterval2'+IntToStr(i,1),Nil,mfError+mfCancelButton);}
                     {Goto 45;}
                    End;
  MinInterval3[i]:=OrdStringToString(GetAsString('MinInterval3['+IntToStr(i,1)+']'));
  If Not Sh.OkOp Then Begin
                     {MessageBox(#3^M+#3'Не обнаружен параметр MinInterval3'+IntToStr(i,1),Nil,mfError+mfCancelButton);}
                     {Goto 45;}
                    End;
  MinInterval4[i]:=OrdStringToString(GetAsString('MinInterval4['+IntToStr(i,1)+']'));
  If Not Sh.OkOp Then Begin
                     {MessageBox(#3^M+#3'Не обнаружен параметр MinInterval3'+IntToStr(i,1),Nil,mfError+mfCancelButton);}
                     {Goto 45;}
                    End;
  Normal[i]:=OrdStringToString(GetAsString('Normal['+IntToStr(i,1)+']'));
  If Not Sh.OkOp Then Begin
                    { MessageBox(#3^M+#3'Не обнаружен параметр Normal'+IntToStr(i,1),Nil,mfError+mfCancelButton);}
                     {Goto 45;}
                    End;
  End;{With}
End;{for}





SH.Done;
End;



Procedure DisposeResursMessage;
VAr c : Word;
Begin
    DisposeStr(DelTovar);
    DisposeStr(DelDocument);
    DisposeStr(DelRazdel);
    DisposeStr(DelOperator);
    DisposeStr(DelBazName);
    DisposeStr(MsgErrorRazdelDel);
    DisposeStr(Zapret);
    DisposeStr(DelAll);
    DisposeStr(DelDoc);
    DisposeStr(NoClient);
    DisposeStr(NoMake);
    DisposeStr(NoSertif);
    DisposeStr(NoAkzis);
    DisposeStr(NoNds);
    DisposeStr(NoNalog);
    DisposeStr(ErrorNds);
    DisposeStr(ErrorNAlog);
    DisposeStr(NullKol);
    DisposeStr(NullFantomKol);
    DisposeStr(ErrorZakupka);
    DisposeStr(ErrorRZena);
    DisposeStr(ErrorSpecZena);
    DisposeStr(ErrorOZena);
    DisposeStr(NoInput);
    DisposeStr(ErrorClientFile);
    DisposeStr(ErrorMakeFile);
    DisposeStr(ErrorRazdelFile);
    DisposeStr(ErrorOperatorFile);
    DisposeStr(WarningTZakupka);
    DisposeStr(WarningTZakupka2);
    DisposeStr(WarningDZakupka);
    DisposeStr(WarningDZakupka2);
    DisposeStr(SeeTovar);
    DisposeStr(ErrorClient);
    DisposeStr(InternalDocumentError);
    DisposeStr(ClicProgrammer);
    DisposeStr(Seria_Akzis);
    DisposeStr(Expert_RegNom);
    DisposeStr(NoConsigClient);
    DisposeStr(NoComplect);
    DisposeStr(Monopolia);
    DisposeStr(Line_Separator);
    DisposeStr(NullStr);
    DisposeStr(TTNStr1);
    DisposeStr(TTNStr2);
    DisposeStr(TTNStr3);
    DisposeStr(TTNStr4);
    DisposeStr(WarningUpDAte);
    DisposeStr(WarningToProgramer);
    DisposeStr(NoKursUSD);
    DisposeStr(NoCorrectKassa);
    DisposeStr(OkReport);
    DisposeStr(FullReport);
    DisposeStr(KurzReport);
    DisposeStr(NoWorkStation);
    DisposeStr(ReadOnlyStr);
    DisposeStr(ErrorReport);
    DisposeStr(NoMarket);
    DisposeStr(NoReportToExcel);
    DisposeStr(WarningExport);
    DisposeStr(RestructError);
    DisposeStr(NoExistsModul);
    DisposeStr(NazenkaError);
    DisposeStr(SkidkaError);
    DisposeStr(NoRightAccess);
    DisposeStr(SrokDeistvIstekaet);
    DisposeStr(SrokRealizIstekaet);
    DisposeStr(WarningExportRepeat);
    DisposeStr(WarningFoundEKRSERV);
    DisposeStr(WarningFoundEKRSERV1);
    DisposeStr(WarningNoOneCopy);
    DisposeStr(FoundRunCopyProgram);
    DisposeStr(NoLizensiaFromProgram);
    DisposeStr(IstekSrokLizensii);
    DisposeStr(IstekaetSrokLizensii);


    DisposeStr(EnableImportMakeS);
    DisposeStr(PharmS);
    DisposeStr(AutoDetectS);
    DisposeStr(DisablePrintXeroxS);
    DisposeStr(RunFromExitS);
    DisposeStr(RunFromCloseS);
    DisposeStr(ReadOnlyS);
    DisposeStr(OnlyOneCopyS);
    DisposeStr(TerminalS);
    DisposeStr(ChangeAdressS);
    DisposeStr(DisableControlTulaSpirtS);
    DisposeStr(EnableTempLockS);
    DisposeStr(DisableControlMinNazenkaS);
    DisposeStr(DisableControlMinNazClS);
    DisposeStr(DisableSOtgruzkaS);
    DisposeStr(EnableSSpisanie);
    DisposeStr(DisableControlOtsrS);

    DisposeStr(NoPosition);
    DisposeStr(ErrorOpen);
    DisposeStr(Zanato1);
    DisposeStr(Zanato2);
    DisposeStr(NoLock);
    DisposeStr(NoFound);
    DisposeStr(NoRoznica);


    For c:=0 To 8 Do
     Begin
       DisposeStr(GroupNAme[c]);
     End;
   Dispose(GlobalPrn,Done);
End;


Constructor TBankVipiskaPtr.Init;
Var j: Word;
Begin
TObject.Init;
With Dat Do
 Begin
     For j:=1 To CMAX Do
      Begin
       Element[j].BN.BankKod[0]:=#0;
       Element[j].BN.Date [0]:=#0;
       Element[j].BN.NPlat[0]:=#0;
       Element[j].BN.Summa[0]:=#0;{сумма ПП}
       Element[j].OperatorSelector :=0;
       Element[j].Kod[0]:=#0;
       Element[j].Summa [0]:=#0;{+/-}
       Element[j].Comment[0]:=#0;
       Element[j].Rashet:=0;
      End;{For}
     Document[0]:=#0;
     Summa[0]:=#0;{сумма к зачислению в банковское сальдо +/-}
     DateC:=DateStringToDate('dd-mm-yy',FDate);
     TimeC:=TimeStringToTime('hh:mm:ss',CurrentTimeString('hh:mm:ss'));
     DateM:=DateStringToDate('dd-mm-yy',FDate);
     TimeM:=TimeStringToTime('hh:mm:ss',CurrentTimeString('hh:mm:ss'));
     Caption[0]:=#0;
     Status  :=0;{0-сформирована;1-введена на склад
	             {и корректироваться не может}
     Active  :=0;{0-активен;1-анулирован}
     Locked  :=False;
     LockCaption[0] :=#0;
     LockComputer[0]:=#0;
 End;
End;

Destructor TBankVipiskaPtr.Done;
Begin
TObject.Done;
End;




Begin
End.