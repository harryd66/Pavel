{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}

Unit LockInfo;


Interface


Uses Dialogs,Drivers,Glob,Access,ServStr;



Type PLocalInfoDynamicDebit =^TLocalInfoDynamicDebit;
    TLocalInfoDynamicDebit = object(TDialog)
    procedure LockPrintReport;
    Procedure LockStart(S:String;Clientkod:ArtikulStr);
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure LockFreshRashetHint;
    Destructor Done;virtual;
  end;

Type PEmplLocalInfoDynamicDebit =^TEmplLocalInfoDynamicDebit;
    TEmplLocalInfoDynamicDebit = object(TDialog)
    procedure LockPrintReport;
    Procedure LockStart(S:String;Clientkod:ArtikulStr);
    procedure HandleEvent(var Event: TEvent); virtual;
    Destructor Done;virtual;
  end;


{
Type PLocalInfoDynamicReturn =^TLocalInfoDynamicReturn;
        TLocalInfoDynamicReturn = object(TDialog)
    Procedure LockStart(S:String;Clientkod:ArtikulStr);
    procedure HandleEvent(var Event: TEvent); virtual;
    Destructor Done;virtual;
  end;
}

Type PInfoDynamicReturn =^TInfoDynamicReturn;
        TInfoDynamicReturn = object(TDialog)
    Cl  : PClientWindow;
    procedure OpenDynamicReturnWindow;
    procedure FullPreview;
    Procedure FormReport(Const P:PBox);
    constructor Init(Var l: Boolean);
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure Refresh;
    procedure FreshInfoHint;
  end;

Procedure CalcNDS (As: DocumentEdit;Var NDS,NP:Real);
Implementation

uses DBEngine,Objects, Views, MsgBox,Protect,{Calc,}TPDate,{Market,}Tools,Printers,
        App, ColorTxt,Serv,Vision4,Vision1,NetDbEng,UtilsP;



VAr  LocalInfo :PLocalInfoDynamicDebit;
     LocalInfoEmpl :PEmplLocalInfoDynamicDebit;
     InfoReturnWindow : PInfoDynamicReturn;
     LocalDolgList: PBox;
     ControlReturn,ControlVid,ControlKassa,ControlClient,ControlBank,ControlPP,ControlRashet,ControlSummaPP,ControlDatePP,
     ControlPrim,ControlPassword  : PView;
     ControlClientLock : PView;
     PrevS,PrevSLock : TEnjoyStr;
     PrevDoc:ArtikulStr;
     PrevDate :TDateString;
     PrevCurrent : TMyString;
     DynamicReturnList : PBox;

Procedure TLocalInfoDynamicDebit.LockPrintReport;
Const Space='  ';
Var Ass : DocumentEdit;
    s : String;
    SClientKod : ArtikulStr;
    Txt : Text;
    w : Word;
    wp : AllStr;
    p1,p2,p0 : Real;
    clf : File Of ClientOplataRealizasiaType;
    cl  : ClientOplataRealizasiaType;
Begin
If (LocalDolgList^.List<>Nil)And(LocalDolgList^.List^.Count>=1) Then
 Begin
  Assign(txt,Path.ToTemp+'lockrep.txt');
  w:=IOResult;
  Rewrite(Txt);
  w:=IOResult;
  If w <>0 Then
   Begin
    MessageBox(#3^M+#3'Не могу создать файл отчета '+Path.ToTemp+'lockrep.txt',Nil,mfError+mfCancelButton);
    Exit;
   End;
  s:=LocalDolgList^.GetText(0,LocalDolgList^.List^.Count);
  Ass.EditPosition:=copy(s,1+1,CDocNumer);
  DelZerro(Ass.EditPosition);
  Ass.D:=Copy(s,1+1+CDocNumer+1,CDAte);

  PStaticText(ControlClientLock)^.GetText(s);
  System.Delete(s,1,1);
  SClientKod:=Copy(s,1+CClient+1,CClientKod);

  Assign (ClF,Path.ToClientOplata+SClientKod+'.cpl');
  w:=IOResult;
  Reset (ClF);
  w:=IOResult;
  If w <>0 Then
   Begin
    System.Close(txt);
    MessageBox(#3^M+#3'Не найден файл оплаты долгов клиента '+SClientKod,Nil,mfError+mfCancelButton);
    Exit;
   End;
  wp:=GetClientField(FClient,SClientKod,0);
  Writeln(txt,Space+Bold[NPrint.Printer]+Double[NPrint.Printer]+'ХРОНОЛОГИЯ ОПЛАТЫ ДОЛГОВ ПО ДОКУМЕНТУ N '+
  Ass.EditPosition+' от '+
  Ass.D+' клиент:'+wp+'('+SClientKod+')'+NoBold[NPrint.Printer]+NoBold[NPrint.Printer]);
  Writeln(txt,Space+'-----------------------------------------------------------------------------------------');
  Writeln(txt,Space+' N   Дата Док Срок Оп. Дата Оп. Время Оп.   Сумма оплаты   Скидка возвр. Del   Оператор');
                    {1234 12345678 12345678 12345678 12345678 1234567890123450123456789012345 123 123456789012}
{123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890}
  Writeln(txt,Space+'-----------------------------------------------------------------------------------------');

   p0:=0;
   p1:=0;
   p2:=0;
   While Not(Eof(ClF))Do
    Begin
     Read(ClF,Cl);
     ClearChar(Cl.Document);
     DelZerro(Cl.Document);
     DelSpace(Cl.DateDoc);
        DelSpace(Cl.SummaZ);
     If (Cl.Document=Ass.EditPosition) And (Ass.D=Cl.DateDoc)  Then
     Begin
    With Cl Do
    Begin
    Format (Document,CDocNumer);
    Format (DateDoc,CDate);
    Format (Srok,CDate);
    Format (DAteC,CDate);
    Format (TimeC,CDate);
    Format (SummaZ,CIZena);
    Str(StrToReal(SummaZ):CIZena:CMantissa,SummaZ);
    Str(StrToReal(Skidka):CIZena:CMantissa,Skidka);
    p2:=p2+StrToReal(Skidka);{скидка возврата}
    if Vozwrat Then
    p1:=p1+StrToReal(SummaZ){сумма  возврата}
    else
    p0:=p0+StrToReal(SummaZ);{сумма  опдаты}
    wp:=GetOperatorName(Caption);
    Format(wp,CKto);
    Format(Delta,CLitrMantissa);
    Writeln(txt,Space+Document+' '+DateDoc+' '+Srok+' '+DateC+' '+TimeC+' '+SummaZ+' '+Skidka+' '+Delta+' '+wp);
    If Vozwrat Then
     Begin
        Writeln(txt,Space+'Возврат по документу N'+Cl.DocNumerReturn+' от '+Cl.DocDateReturn);
     End;
    End;
    End;
    End;
  Writeln(txt,Space+'-----------------------------------------------------------------------------------------');
  Writeln(Txt,Space+'                                                Всего скидка возврата:',
  RecognizReal(p2,CIZena,CMantissa));
  Writeln(Txt,Space+'                                                 Всего сумма возврата:',
  RecognizReal(p1,CIZena,CMantissa));
  Writeln(Txt,Space+'                                                       Всего оплачено:',
  RecognizReal(p0,CIZena,CMantissa));

  Writeln(txt,Space,'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
  Writeln(txt,Space+'=========================================================================================');
  System.Close(ClF);
  System.Close(txt);
  Report(Path.ToTemp+'lockrep.txt','',1,False,False,false);
 End;
End;

Procedure TEmplLocalInfoDynamicDebit.LockPrintReport;
Const Space='  ';
Var Ass : DocumentEdit;
    s : String;
    SClientKod : ArtikulStr;
    Txt : Text;
    w : Word;
    wp : AllStr;
    p1,p2,p0 : Real;
    clf : File Of ClientOplataRealizasiaType;
    cl  : ClientOplataRealizasiaType;
Begin
If (LocalDolgList^.List<>Nil)And(LocalDolgList^.List^.Count>=1) Then
 Begin
  Assign(txt,Path.ToTemp+'lockrep.txt');
  w:=IOResult;
  Rewrite(Txt);
  w:=IOResult;
  If w <>0 Then
   Begin
    MessageBox(#3^M+#3'Не могу создать файл отчета '+Path.ToTemp+'lockrep.txt',Nil,mfError+mfCancelButton);
    Exit;
   End;
  s:=LocalDolgList^.GetText(0,LocalDolgList^.List^.Count);
  Ass.EditPosition:=copy(s,1+1,CDocNumer);
  DelZerro(Ass.EditPosition);
  Ass.D:=Copy(s,1+1+CDocNumer+1,CDAte);

  PStaticText(ControlClientLock)^.GetText(s);
  System.Delete(s,1,1);
  SClientKod:=Copy(s,1+CClient+1,CClientKod);

  Assign (ClF,Path.ToClientOplata+SClientKod+'.cpl');
  w:=IOResult;
  Reset (ClF);
  w:=IOResult;
  If w <>0 Then
   Begin
    System.Close(txt);
    MessageBox(#3^M+#3'Не найден файл оплаты долгов клиента '+SClientKod,Nil,mfError+mfCancelButton);
    Exit;
   End;
  wp:=GetClientField(FClient,SClientKod,0);
  Writeln(txt,Space+Bold[NPrint.Printer]+Double[NPrint.Printer]+'ХРОНОЛОГИЯ ОПЛАТЫ ДОЛГОВ ПО ДОКУМЕНТУ N '+
  Ass.EditPosition+' от '+
  Ass.D+' клиент:'+wp+'('+SClientKod+')'+NoBold[NPrint.Printer]+NoBold[NPrint.Printer]);
  Writeln(txt,Space+'-----------------------------------------------------------------------------------------');
  Writeln(txt,Space+' N   Дата Док Срок Оп. Дата Оп. Время Оп.   Сумма оплаты   Скидка возвр. Del   Оператор');
                    {1234 12345678 12345678 12345678 12345678 1234567890123450123456789012345 123 123456789012}
{123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890}
  Writeln(txt,Space+'-----------------------------------------------------------------------------------------');

   p0:=0;
   p1:=0;
   p2:=0;
   While Not(Eof(ClF))Do
    Begin
     Read(ClF,Cl);
     ClearChar(Cl.Document);
     DelZerro(Cl.Document);
     DelSpace(Cl.DateDoc);
        DelSpace(Cl.SummaZ);
     If (Cl.Document=Ass.EditPosition) And (Ass.D=Cl.DateDoc)  Then
     Begin
    With Cl Do
    Begin
    Format (Document,CDocNumer);
    Format (DateDoc,CDate);
    Format (Srok,CDate);
    Format (DAteC,CDate);
    Format (TimeC,CDate);
    Format (SummaZ,CIZena);
    Str(StrToReal(SummaZ):CIZena:CMantissa,SummaZ);
    Str(StrToReal(Skidka):CIZena:CMantissa,Skidka);
    p2:=p2+StrToReal(Skidka);{скидка возврата}
    if Vozwrat Then
    p1:=p1+StrToReal(SummaZ){сумма  возврата}
    else
    p0:=p0+StrToReal(SummaZ);{сумма  опдаты}
    wp:=GetOperatorName(Caption);
    Format(wp,CKto);
    Format(Delta,CLitrMantissa);
    Writeln(txt,Space+Document+' '+DateDoc+' '+Srok+' '+DateC+' '+TimeC+' '+SummaZ+' '+Skidka+' '+Delta+' '+wp);
    If Vozwrat Then
     Begin
        Writeln(txt,Space+'Возврат по документу N'+Cl.DocNumerReturn+' от '+Cl.DocDateReturn);
     End;
    End;
    End;
    End;
  Writeln(txt,Space+'-----------------------------------------------------------------------------------------');
  Writeln(Txt,Space+'                                                Всего скидка возврата:',
  RecognizReal(p2,CIZena,CMantissa));
  Writeln(Txt,Space+'                                                 Всего сумма возврата:',
  RecognizReal(p1,CIZena,CMantissa));
  Writeln(Txt,Space+'                                                       Всего оплачено:',
  RecognizReal(p0,CIZena,CMantissa));

  Writeln(txt,Space,'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
  Writeln(txt,Space+'=========================================================================================');
  System.Close(ClF);
  System.Close(txt);
  Report(Path.ToTemp+'lockrep.txt','',1,False,False,false);
 End;
End;






Procedure TLocalInfoDynamicDebit.LockStart(S:String;ClientKod:ArtikulStr);
var
  R : TRect;
  Control : PView;
  C : LongInt;
  p0,p1,p2 : Real;
  wp : String[cIzena];
  ClientOplataFile : File Of ClientoplataRealizasiaType;
  ClientOplata     : ClientoplataRealizasiaType;
  SDoc:ArtikulStr;
  SDate:TDateString;
  SClientkod:ArtikulStr;
  s1 : AllStr;


begin
ClearFind;
SDoc:=Copy(s,1+1,CDocNumer);
DelSpace(SDoc);
DelZerro(SDoc);

SDate:=Copy(s,1+1+CDocNumer+1,CDate);
DelSpace(SDate);
{
SDoc:=Copy(DolgList^.GetText(DolgList^.Focused,DolgList^.List^.Count),1+1,CDocNumer);
DelSpace(SDoc);
DelZerro(SDoc);

SDate:=Copy(DolgList^.GetText(DolgList^.Focused,DolgList^.List^.Count),1+1+CDocNumer+1,CDate);
DelSpace(SDate);
}
{
PStaticText(ControlClient)^.GetText(PrevSLock);
System.Delete(PrevSLock,1,1);
s1:=PrevSLock;
s1:=Copy(s1,1+CClient+1,CClientKod);
SClientKod:=s1;
}
SClientKod:=ClientKod;


Assign(ClientOplataFile,Path.ToClientOplata+SClientKod+'.cpl');
c:=IOResult;
Reset(ClientOplataFile);
c:=IOResult;
If c<>0 Then
 Begin
  MessageBox(#3+'Клиент не проводил оплаты долгов!'^M+#3'Ошибка доступа к файлу оплаты консигнации клиента ('
  +SclientKod+')',
                   Nil,mfError+mfCancelButton);
  Exit;
 End;

AInfo('Читаю хронологию оплаты долгов клиентом...');

PrevSLock:=GetClientField(FClient,SClientKod,0);
Format(PrevSLock,CClient);


R.Assign(0, 0, 80, 23);
New(LocalInfo, Init(R, 'Хронология оплаты клиентом долга по документу N '+SDoc+' от '+SDate));

LocalInfo^.Options := LocalInfo^.Options or ofCenterX or ofCenterY;
R.Assign(51, 1, 79, 2);
PrevSLock:=PrevSLock+'('+SClientKod+')';
ControlClientLock := New(PColoredText, Init(R, #3+PrevSLock, $7E));
LocalInfo^.Insert(ControlClientLock);

 R.Assign(43, 1, 51, 2);
Control := New(PColoredText, Init(R, 'Клиент:', $74));
LocalInfo^.Insert(Control);


R.Assign(79, 3, 80, 19);
Control := New(PScrollBar, Init(R));
LocalInfo^.Insert(Control);

R.Assign(1, 3, 79, 19);
LocalDolgList := New(PBox, Init(R, 1, PScrollbar(Control)));
LocalDolgList^.NewList(New({PText}PMyCollection, Init(0,1)));

p0:=0;
p1:=0;
p2:=0;
While Not(Eof(ClientOplataFile)) Do
 Begin
  Read(ClientOplataFile,ClientOplata);
  DelZerro(ClientOplata.Document);


  If (ClearChar(ClientOplata.Document)=ClearChar(SDoc)) And
        (ClientOplata.DateDoc=SDate) Then
   Begin
    With ClientOplata Do
    Begin
    RFormatZerro(Document,CDocNumer);
    Format (Document,CDocNumer);
    Format (DateDoc,CDate);
    Format (Srok,CDate);
    Format (DAteC,CDate);
    Format (TimeC,CDate);
    Format (SummaZ,CIZena);
    Str(StrToReal(Skidka):CIZena:CMantissa,Skidka);
    p2:=p2+StrToReal(Skidka);{скидка возврата}
    if Vozwrat Then
    p1:=p1+StrToReal(SummaZ){сумма  возврата}
    else
    p0:=p0+StrToReal(SummaZ);{сумма  опдаты}
    wp:=GetOperatorName(Caption);
    Format(wp,CKto);
    Format(Delta,CLitrMantissa);
    LocalDolgList^.List^.Insert(NewStr('│'+Document+'│'
    +DateDoc+'│'++Srok+'│'+DateC+'│'+TimeC+'│'+SummaZ+'│'+Skidka+'│'+Delta+'│'+wp));
    End;
    LocalDolgList^.SetRange(LocalDolgList^.List^.Count);
  End;
 End;
System.Close(ClientOplataFile);

PrevDoc:=SDoc;
PrevDate:=SDate;

LocalDolgList^.FocusItem(0);
LocalDolgList^.HelpCtx:=$E100;

LocalInfo^.Insert(LocalDolgList);

  R.Assign(1, 2, 79, 3);
{LocalInfo^.Insert(New(PLabel, Init(R, ' Дата Док   N   Срок Оп Дата Оп. Время Оп.   Сумма оплаты   Скидка возвр. Del',}
LocalInfo^.Insert(New(PLabel, Init(R, '  N   Дата Док Срок Оп. Дата Оп. Время Оп.   Сумма оплаты   Скидка возвр. Del',
LocalDolgList)));

R.Assign(18, 20, 24, 21);
Control := New(PColoredText, Init(R, 'N п/п:', $74));
LocalInfo^.Insert(Control);

R.Assign(15, 19, 24, 20);
Control := New(PColoredText, Init(R, 'Дата п/п:', $74));
LocalInfo^.Insert(Control);

R.Assign(24, 20, 34, 21);
ControlPP := New(PColoredText, Init(R, #3'', $7E));
LocalInfo^.Insert(ControlPP);

R.Assign(24, 19, 32, 20);
ControlDatePP := New(PColoredText, Init(R, #3'', $7E));
LocalInfo^.Insert(ControlDatePP);

R.Assign(35, 19, 45, 20);
Control := New(PColoredText, Init(R, 'Сумма п/п:', $74));
LocalInfo^.Insert(Control);

R.Assign(45, 19, 60, 20);
ControlSummaPP := New(PColoredText, Init(R, #3'', $7E));
LocalInfo^.Insert(ControlSummaPP);

R.Assign(40, 20, 45, 21);
Control := New(PColoredText, Init(R, 'Банк:', $74));
LocalInfo^.Insert(Control);

R.Assign(45, 20, 78, 21);
ControlBank := New(PColoredText, Init(R, '', $7E));
LocalInfo^.Insert(ControlBank);

R.Assign(3, 19, 10, 20);
Control := New(PColoredText, Init(R, 'Расчет:', $71));
LocalInfo^.Insert(Control);

R.Assign(10, 19, 13, 20);
ControlRashet := New(PColoredText, Init(R, #3'', $7E));
LocalInfo^.Insert(ControlRashet);

R.Assign(2, 21, 13, 22);
Control := New(PColoredText, Init(R, 'Примечание:', $71));
LocalInfo^.Insert(Control);

R.Assign(13, 21, 53, 22);
ControlPrim := New(PColoredText, Init(R, #3'', $7E));
LocalInfo^.Insert(ControlPrim);

R.Assign(55, 21, 64, 22);
Control := New(PColoredText, Init(R, 'Оператор:', $74));
LocalInfo^.Insert(Control);

R.Assign(64, 21, 76, 22);
ControlPassword := New(PColoredText, Init(R, #3+'', $7E));
LocalInfo^.Insert(ControlPassword);


R.Assign(29, 22, 38, 23);
Control := New(PColoredText, Init(R, ' Возврат:', $74));
LocalInfo^.Insert(Control);

Str(p1:CIZena:CMantissa,wp);
DelSpace(wp);
R.Assign(38, 22, 53, 23);
Control := New(PColoredText, Init(R, #3+wp, $4E));
LocalInfo^.Insert(Control);


R.Assign(1, 22, 13, 23);
Control := New(PColoredText, Init(R, ' Cкид.возвр:', $74));
LocalInfo^.Insert(Control);

Str(p2:CIZena:CMantissa,wp);
DelSpace(wp);
R.Assign(13, 22, 28, 23);
Control := New(PColoredText, Init(R, #3+wp, $4E));
LocalInfo^.Insert(Control);


R.Assign(54, 22, 64, 23);
Control := New(PColoredText, Init(R, ' Оплачено:', $74));
LocalInfo^.Insert(Control);


Str(p0:CIZena:CMantissa,wp);
DelSpace(wp);
R.Assign(64, 22, 79, 23);
Control := New(PColoredText, Init(R, #3+wp, $4E));
LocalInfo^.Insert(Control);


PrevCurrent[0]:=#0;

LocalInfo^.SelectNext(False);
PrevCurrent[0]:=#0;
LocalInfo^.LockFreshRashetHint;
NoInfo;
c:=Desktop^.ExecView(LocalInfo);
Dispose(Control,Done);
Dispose(LocalInfo,Done);

end;


Procedure TEmplLocalInfoDynamicDebit.LockStart(S:String;ClientKod:ArtikulStr);
var
  R : TRect;
  Control : PView;
  C : LongInt;
  p0,p1,p2 : Real;
  wp : String[cIzena];
  ClientOplataFile : File Of DolgKassa;
  ClientOplata     : DolgKassa;
  SDoc:ArtikulStr;
  SDate:TDateString;
  SClientkod:ArtikulStr;
  sSumma,sSummadoc: string[CIZena];
  s1 : AllStr;


begin
ClearFind;

SDoc:=Copy(s,1+1,CDocNumer);
DelSpace(SDoc);
DelZerro(SDoc);

SDate:=Copy(s,1+1+CDocNumer+1,CDate);
DelSpace(SDate);
{
SDoc:=Copy(DolgList^.GetText(DolgList^.Focused,DolgList^.List^.Count),1+1,CDocNumer);
DelSpace(SDoc);
DelZerro(SDoc);

SDate:=Copy(DolgList^.GetText(DolgList^.Focused,DolgList^.List^.Count),1+1+CDocNumer+1,CDate);
DelSpace(SDate);
}
{
PStaticText(ControlClient)^.GetText(PrevSLock);
System.Delete(PrevSLock,1,1);
s1:=PrevSLock;
s1:=Copy(s1,1+CClient+1,CClientKod);
SClientKod:=s1;
}
SClientKod:=ClientKod;


Assign(ClientOplataFile,Path.ToClient+SClientKod+'.dls');
c:=IOResult;
Reset(ClientOplataFile);
c:=IOResult;
If c<>0 Then
 Begin
  MessageBox(#3+'Клиент не проводил оплаты долгов!'^M+#3'Ошибка доступа к файлу оплаты консигнации клиента ('
  +SclientKod+')',
                   Nil,mfError+mfCancelButton);
  Exit;
 End;

AInfo('Читаю хронологию оплаты долгов клиентом...');

PrevSLock:=GetLizoField(FClient,SClientKod);
Format(PrevSLock,CClient);


R.Assign(0, 0, 80, 23);
New(LocalInfoEmpl, Init(R, 'Хронология оплаты сотрудником долга по документу N '+SDoc+' от '+SDate));

LocalInfoEmpl^.Options := LocalInfoEmpl^.Options or ofCenterX or ofCenterY;
R.Assign(51, 1, 79, 2);
PrevSLock:=PrevSLock+'('+SClientKod+')';
ControlClientLock := New(PColoredText, Init(R, #3+PrevSLock, $7E));
LocalInfoEmpl^.Insert(ControlClientLock);

 R.Assign(40, 1, 51, 2);
Control := New(PColoredText, Init(R, 'Сотрудник:', $74));
LocalInfoEmpl^.Insert(Control);


R.Assign(79, 3, 80, 19);
Control := New(PScrollBar, Init(R));
LocalInfoEmpl^.Insert(Control);

R.Assign(1, 3, 79, 19);
LocalDolgList := New(PBox, Init(R, 1, PScrollbar(Control)));
LocalDolgList^.NewList(New({PText}PMyCollection, Init(0,1)));

p0:=0;
p1:=0;
p2:=0;
While Not(Eof(ClientOplataFile)) Do
 Begin
  Read(ClientOplataFile,ClientOplata);
  DelZerro(ClientOplata.Doc);
  if StrToInt(GetOperationField(FStatus,ClientOplata.Kod))=1 then
  If (ClearChar(ClientOplata.Doc)=ClearChar(SDoc)) And
        (ClientOplata.DateC=DateStringToDate(DateMAsk,SDate)) Then
   Begin

    With ClientOplata Do
    Begin
    p0:=p0+Summa;
    RFormatZerro(Doc,CDocNumer);
    Format (DocTek,CDocNumer);
    MyStr(Summa,CIZena,CMantissa,sSumma);
    LocalDolgList^.List^.Insert(NewStr('│'+DocTek+'│'
    +DateToDateString(DateMAsk,DateC)+'│'+DateToDateString(DateMAsk,DateTek)+'│'+sSumma+'│'
      +GetOperatorName(Caption)));
    End;
    LocalDolgList^.SetRange(LocalDolgList^.List^.Count);
  End;
 End;
System.Close(ClientOplataFile);

PrevDoc:=SDoc;
PrevDate:=SDate;

LocalDolgList^.FocusItem(0);
LocalDolgList^.HelpCtx:=$E100;

LocalInfoEmpl^.Insert(LocalDolgList);

  R.Assign(1, 2, 79, 3);
{LocalInfoEmpl^.Insert(New(PLabel, Init(R, ' Дата Док   N   рок Оп Дата Оп. Время Оп.   Сумма оплаты   Скидка возвр. Del',}
LocalInfoEmpl^.Insert(New(PLabel, Init(R, '  N   Дата Док  Дата Оп.  Сумма оплаты   Оператор',
LocalDolgList)));

R.Assign(18, 20, 24, 21);
Control := New(PColoredText, Init(R, {'N п/п:'}'', $74));
LocalInfoEmpl^.Insert(Control);

R.Assign(15, 19, 24, 20);
Control := New(PColoredText, Init(R, {'Дата п/п:'}'', $74));
LocalInfoEmpl^.Insert(Control);

R.Assign(24, 20, 34, 21);
ControlPP := New(PColoredText, Init(R, {#3''}'', $7E));
LocalInfoEmpl^.Insert(ControlPP);

R.Assign(24, 19, 32, 20);
ControlDatePP := New(PColoredText, Init(R, {#3}'', $7E));
LocalInfoEmpl^.Insert(ControlDatePP);

R.Assign(35, 19, 45, 20);
Control := New(PColoredText, Init(R, {'Сумма п/п:'}'', $74));
LocalInfoEmpl^.Insert(Control);

R.Assign(45, 19, 60, 20);
ControlSummaPP := New(PColoredText, Init(R, {#3}'', $7E));
LocalInfoEmpl^.Insert(ControlSummaPP);

R.Assign(40, 20, 45, 21);
Control := New(PColoredText, Init(R, {'Банк:'}'', $74));
LocalInfoEmpl^.Insert(Control);

R.Assign(45, 20, 78, 21);
ControlBank := New(PColoredText, Init(R, '', $7E));
LocalInfoEmpl^.Insert(ControlBank);

R.Assign(3, 19, 10, 20);
Control := New(PColoredText, Init(R, {'Расчет:'}'', $71));
LocalInfoEmpl^.Insert(Control);

R.Assign(10, 19, 13, 20);
ControlRashet := New(PColoredText, Init(R, {#3}'', $7E));
LocalInfoEmpl^.Insert(ControlRashet);

R.Assign(2, 21, 13, 22);
Control := New(PColoredText, Init(R, {'Примечание:'}'', $71));
LocalInfoEmpl^.Insert(Control);

R.Assign(13, 21, 53, 22);
ControlPrim := New(PColoredText, Init(R, {#3}'', $7E));
LocalInfoEmpl^.Insert(ControlPrim);

R.Assign(55, 21, 64, 22);
Control := New(PColoredText, Init(R, {'Оператор:'}'', $74));
LocalInfoEmpl^.Insert(Control);

R.Assign(64, 21, 76, 22);
ControlPassword := New(PColoredText, Init(R,{ #3+}'', $7E));
LocalInfoEmpl^.Insert(ControlPassword);


{R.Assign(29, 22, 38, 23);
Control := New(PColoredText, Init(R, ' Возврат:', $74));
LocalInfoEmpl^.Insert(Control);}

R.Assign(0,0, 0, 0);
Control := New(PColoredText, Init(R, ' Возврат:', $74));
LocalInfoEmpl^.Insert(Control);


Str(p1:CIZena:CMantissa,wp);
DelSpace(wp);
{R.Assign(38, 22, 53, 23);
Control := New(PColoredText, Init(R, #3+wp, $4E));
LocalInfoEmpl^.Insert(Control);}

R.Assign(0,0,0,0);
Control := New(PColoredText, Init(R, #3+wp, $4E));
LocalInfoEmpl^.Insert(Control);


{R.Assign(1, 22, 13, 23);
Control := New(PColoredText, Init(R, ' Cкид.возвр:', $74));
LocalInfoEmpl^.Insert(Control);

Str(p2:CIZena:CMantissa,wp);
DelSpace(wp);
R.Assign(13, 22, 28, 23);
Control := New(PColoredText, Init(R, #3+wp, $4E));
LocalInfoEmpl^.Insert(Control);}

R.Assign(0, 0, 0, 0);
Control := New(PColoredText, Init(R, ' Cкид.возвр:', $74));
LocalInfoEmpl^.Insert(Control);

Str(p2:CIZena:CMantissa,wp);
DelSpace(wp);
R.Assign(0, 0, 0, 0);
Control := New(PColoredText, Init(R, #3+wp, $4E));
LocalInfoEmpl^.Insert(Control);

R.Assign(54, 22, 64, 23);
Control := New(PColoredText, Init(R, ' Оплачено:', $74));
LocalInfoEmpl^.Insert(Control);


Str(p0:CIZena:CMantissa,wp);
DelSpace(wp);
R.Assign(64, 22, 79, 23);
Control := New(PColoredText, Init(R, #3+wp, $4E));
LocalInfoEmpl^.Insert(Control);


PrevCurrent[0]:=#0;

LocalInfoEmpl^.SelectNext(False);
PrevCurrent[0]:=#0;
{LocalInfoEmpl^.LockFreshRashetHint;}
NoInfo;
c:=Desktop^.ExecView(LocalInfoEmpl);
Dispose(Control,Done);
Dispose(LocalInfoEmpl,Done);
end;




Procedure TLocalInfoDynamicDebit.HandleEvent(Var Event : TEvent);
var s : tmystring;
    Vid : Word;
Begin
  Case Event.What Of
   EvCommand:
    Case Event.Command Of
    cmReestrReport :Begin
                     PStaticText(ControlClientLock)^.GetText(s);
                     System.Delete(s,1,1);
                     S:=Copy(s,1+CClient+1,CClientKod);
                     If Password(3) Then
				  begin
              LockPrintReport;
                       AddProtocol('Печать хронологии оплаты долгов клиентов ('+s+') {Возможна утечка информации}','','');
                      end;
                    End;

    Else;
    End;
  Else;
  End;

  inherited HandleEvent(Event);
  LockFreshRashetHint;
  ClearEvent(Event);
End;

Procedure TEmplLocalInfoDynamicDebit.HandleEvent(Var Event : TEvent);
var s : tmystring;
    Vid : Word;
Begin
  Case Event.What Of
   EvCommand:
    Case Event.Command Of
    cmReestrReport :Begin
                     PStaticText(ControlClientLock)^.GetText(s);
                     System.Delete(s,1,1);
                     S:=Copy(s,1+CClient+1,CClientKod);
                     If Password(3) Then
				  begin
              LockPrintReport;
                       AddProtocol('Печать хронологии оплаты долгов клиентов ('+s+') {Возможна утечка информации}','','');
                      end;
                    End;

    Else;
    End;
  Else;
  End;

  inherited HandleEvent(Event);

  ClearEvent(Event);
End;



Procedure TLocalInfoDynamicDebit.LockFreshRashetHint;
Var Ass : DocumentEdit;
    Test : Word;
    R : TRect;
    s,ws : TMyString;
    SClientKod,SDAte,STime:TDateString;
    SSumma :String[CIZena];
    Find : Boolean;
    Kto : String[CKto];
    ClientOplataFile : File Of ClientOplataRealizasiaType;
    ClientOplata : ClientOplataRealizasiaType;
Begin

If (LocalDolgList^.State and sfFocused <> 0) And (LocalDolgList^.List<>Nil)And(LocalDolgList^.List^.Count>=1) Then
 Begin
  s:=LocalDolgList^.GetText(LocalDolgList^.Focused,LocalDolgList^.List^.Count);
  If s <> PrevCurrent Then
  Begin
  PrevCurrent:=S;
{  Ass.EditPosition:=Copy(LocalDolgList^.GetText(LocalDolgList^.Focused,LocalDolgList^.List^.Count),1+1+CDate+1,CDocNumer);}
  Ass.EditPosition:=Copy(LocalDolgList^.GetText(LocalDolgList^.Focused,LocalDolgList^.List^.Count),1+1,CDocNumer);
  DelSpace(Ass.EditPosition);
  ClearChar(Ass.EditPosition);
  DelZerro(Ass.EditPosition);
{  Ass.D:=Copy(LocalDolgList^.GetText(LocalDolgList^.Focused,LocalDolgList^.List^.Count),1+1,CDate);}
  Ass.D:=Copy(LocalDolgList^.GetText(LocalDolgList^.Focused,LocalDolgList^.List^.Count),1+1+CDocNumer+1,CDate);
  DelSpace(Ass.D);
  SDate:=Copy(LocalDolgList^.GetText(LocalDolgList^.Focused,LocalDolgList^.List^.Count),1+1+CDocNumer+1+CDate+1+CDate+1,CDate);
  STime:=Copy(LocalDolgList^.GetText(LocalDolgList^.Focused,LocalDolgList^.List^.Count),1+1+CDocNumer+1+CDate+1+CDate+1+
  CDate+1,CDate);
  SSumma:=Copy(LocalDolgList^.GetText(LocalDolgList^.Focused,LocalDolgList^.List^.Count),1+1+CDocNumer+1+CDate+1+CDate+1+
  CDate+1+CDate+1,  CIZena);
  Kto:=Copy(LocalDolgList^.GetText(LocalDolgList^.Focused,LocalDolgList^.List^.Count),1+1+CDocNumer+1+CDate+1+CDate+1+CDate+
  1+CDate+1+CIZena+1+CIZena+1+CLitrMantissa+1,CKto);
  DelSpace(sdate);
  DelSpace(stime);
  DelSpace(ssumma);

  PStaticText(ControlClientLock)^.GetText(ws);
  System.Delete(ws,1,1);
  SClientKod:=Copy(ws,1+CClient+1,CClientKod);

  Assign (ClientOplataFile,Path.ToClientOplata+SClientKod+'.cpl');
  Test:=IOResult;
  Reset (ClientOplataFile);
  Test:=IOResult;
  If Test=0 Then
  Begin
   Find:=False;
   DelZerro(Ass.EditPosition);
   While Not(Eof(ClientOplataFile))And Not(find) Do
    Begin
        Read(ClientOplataFile,ClientOplata);
        ClearChar(ClientOplata.Document);
        DelZerro(ClientOplata.Document);
        DelSpace(ClientOplata.DateDoc);
        DelSpace(ClientOplata.SummaZ);
        If (ClientOplata.Document=Ass.EditPosition) And (Ass.D=ClientOplata.DateDoc)
    And (ClientOplata.DateC=SDate) And (ClientOplata.TimeC=STime) And (ClientOplata.SummaZ=SSumma)Then
         Begin
          Find:=True;
         End;
    End;
    System.Close(ClientOplataFile);
    If Not(Find) Then
        Begin
         MessageBox(^M+#3'Документ '+Ass.EditPosition+' в файле оплаты долгов клиента не найден!',Nil,mfError+mfCancelButton);
         Exit;
        End;

Dispose(ControlPP,Done);
R.Assign(24, 20, 34, 21);
ControlPP := New(PColoredText, Init(R, #3+ClientOplata.Bn.NPLat, $7E));
LocalInfo^.Insert(ControlPP);

Dispose(ControlDatePP,Done);
R.Assign(24, 19, 32, 20);
ControlDatePP := New(PColoredText, Init(R, #3+ClientOplata.Bn.Date, $7E));
LocalInfo^.Insert(ControlDatePP);

Dispose(ControlSummaPP,Done);
R.Assign(45, 19, 60, 20);
ControlSummaPP := New(PColoredText, Init(R, #3+ClientOplata.Bn.Summa, $7E));
LocalInfo^.Insert(ControlSummaPP);

Dispose(ControlBank,Done);
R.Assign(45, 20, 78, 21);
ControlBank := New(PColoredText, Init(R, ClientOplata.Bn.Bank, $7E));
LocalInfo^.Insert(ControlBank);

Dispose(ControlRashet,Done);
R.Assign(10, 19, 13, 20);
If ClientOplata.Rashet Then
ControlRashet := New(PColoredText, Init(R, #3'Б/Н', $7E))
Else
Begin
ControlRashet := New(PColoredText, Init(R, #3'Нал', $7E));
if ClientOplata.Bn.Bank<>'' then ControlRashet := New(PColoredText, Init(R, #3'В/З', $7E));
End;
LocalInfo^.Insert(ControlRashet);

Dispose(ControlPrim,Done);
R.Assign(13, 21, 53, 22);
If ClientOplata.Vozwrat Then
ControlPrim := New(PColoredText, Init(R, #3'Возврат по документу N'+ClientOplata.DocNumerReturn+
 ' от '+ClientOplata.DocDateReturn, $7E))
 Else
ControlPrim := New(PColoredText, Init(R, #3'', $7E));
LocalInfo^.Insert(ControlPrim);

Dispose(ControlPassword,Done);
R.Assign(64, 21, 76, 22);
ControlPassword := New(PColoredText, Init(R, #3+Kto, $7E));
LocalInfo^.Insert(ControlPassword);
  End
  Else
   MessageBox(^M+#3'Ошибка доступа к файлу '+Path.ToClientOplata+PrevS+'.cpl!',Nil,mfError+mfCancelButton);
   Redraw;
 End;
 End;
End;

(*Procedure TEmplLocalInfoDynamicDebit.LockFreshRashetHint;
Var Ass : DocumentEdit;
    Test : Word;
    R : TRect;
    s,ws : TMyString;
    SClientKod,SDAte,STime:TDateString;
    SSumma :String[CIZena];
    Find : Boolean;
    Kto : String[CKto];
    ClientOplataFile : File Of ClientOplataRealizasiaType;
    ClientOplata : ClientOplataRealizasiaType;
Begin

If (LocalDolgList^.State and sfFocused <> 0) And (LocalDolgList^.List<>Nil)And(LocalDolgList^.List^.Count>=1) Then
 Begin
  s:=LocalDolgList^.GetText(LocalDolgList^.Focused,LocalDolgList^.List^.Count);
  If s <> PrevCurrent Then
  Begin
  PrevCurrent:=S;
{  Ass.EditPosition:=Copy(LocalDolgList^.GetText(LocalDolgList^.Focused,LocalDolgList^.List^.Count),1+1+CDate+1,CDocNumer);}
  Ass.EditPosition:=Copy(LocalDolgList^.GetText(LocalDolgList^.Focused,LocalDolgList^.List^.Count),1+1,CDocNumer);
  DelSpace(Ass.EditPosition);
  ClearChar(Ass.EditPosition);
  DelZerro(Ass.EditPosition);
{  Ass.D:=Copy(LocalDolgList^.GetText(LocalDolgList^.Focused,LocalDolgList^.List^.Count),1+1,CDate);}
  Ass.D:=Copy(LocalDolgList^.GetText(LocalDolgList^.Focused,LocalDolgList^.List^.Count),1+1+CDocNumer+1,CDate);
  DelSpace(Ass.D);
  SDate:=Copy(LocalDolgList^.GetText(LocalDolgList^.Focused,LocalDolgList^.List^.Count),1+1+CDocNumer+1+CDate+1+CDate+1,CDate);
  STime:=Copy(LocalDolgList^.GetText(LocalDolgList^.Focused,LocalDolgList^.List^.Count),1+1+CDocNumer+1+CDate+1+CDate+1+
  CDate+1,CDate);
  SSumma:=Copy(LocalDolgList^.GetText(LocalDolgList^.Focused,LocalDolgList^.List^.Count),1+1+CDocNumer+1+CDate+1+CDate+1+
  CDate+1+CDate+1,  CIZena);
  Kto:=Copy(LocalDolgList^.GetText(LocalDolgList^.Focused,LocalDolgList^.List^.Count),1+1+CDocNumer+1+CDate+1+CDate+1+CDate+
  1+CDate+1+CIZena+1+CIZena+1+CLitrMantissa+1,CKto);
  DelSpace(sdate);
  DelSpace(stime);
  DelSpace(ssumma);

  PStaticText(ControlClientLock)^.GetText(ws);
  System.Delete(ws,1,1);
  SClientKod:=Copy(ws,1+CClient+1,CClientKod);

  Assign (ClientOplataFile,Path.ToClientOplata+SClientKod+'.cpl');
  Test:=IOResult;
  Reset (ClientOplataFile);
  Test:=IOResult;
  If Test=0 Then
  Begin
   Find:=False;
   DelZerro(Ass.EditPosition);
   While Not(Eof(ClientOplataFile))And Not(find) Do
    Begin
        Read(ClientOplataFile,ClientOplata);
        ClearChar(ClientOplata.Document);
        DelZerro(ClientOplata.Document);
        DelSpace(ClientOplata.DateDoc);
        DelSpace(ClientOplata.SummaZ);
        If (ClientOplata.Document=Ass.EditPosition) And (Ass.D=ClientOplata.DateDoc)
    And (ClientOplata.DateC=SDate) And (ClientOplata.TimeC=STime) And (ClientOplata.SummaZ=SSumma)Then
         Begin
          Find:=True;
         End;
    End;
    System.Close(ClientOplataFile);
    If Not(Find) Then
        Begin
         MessageBox(^M+#3'Документ '+Ass.EditPosition+' в файле оплаты долгов клиента не найден!',Nil,mfError+mfCancelButton);
         Exit;
        End;

Dispose(ControlPP,Done);
R.Assign(24, 20, 34, 21);
ControlPP := New(PColoredText, Init(R, #3+ClientOplata.Bn.NPLat, $7E));
LocalInfo^.Insert(ControlPP);

Dispose(ControlDatePP,Done);
R.Assign(24, 19, 32, 20);
ControlDatePP := New(PColoredText, Init(R, #3+ClientOplata.Bn.Date, $7E));
LocalInfo^.Insert(ControlDatePP);

Dispose(ControlSummaPP,Done);
R.Assign(45, 19, 60, 20);
ControlSummaPP := New(PColoredText, Init(R, #3+ClientOplata.Bn.Summa, $7E));
LocalInfo^.Insert(ControlSummaPP);

Dispose(ControlBank,Done);
R.Assign(45, 20, 78, 21);
ControlBank := New(PColoredText, Init(R, ClientOplata.Bn.Bank, $7E));
LocalInfo^.Insert(ControlBank);

Dispose(ControlRashet,Done);
R.Assign(10, 19, 13, 20);
If ClientOplata.Rashet Then
ControlRashet := New(PColoredText, Init(R, #3'Б/Н', $7E))
Else
ControlRashet := New(PColoredText, Init(R, #3'Нал', $7E));
LocalInfo^.Insert(ControlRashet);

Dispose(ControlPrim,Done);
R.Assign(13, 21, 53, 22);
If ClientOplata.Vozwrat Then
ControlPrim := New(PColoredText, Init(R, #3'Возврат по документу N'+ClientOplata.DocNumerReturn+
 ' от '+ClientOplata.DocDateReturn, $7E))
 Else
ControlPrim := New(PColoredText, Init(R, #3'', $7E));
LocalInfo^.Insert(ControlPrim);

Dispose(ControlPassword,Done);
R.Assign(64, 21, 76, 22);
ControlPassword := New(PColoredText, Init(R, #3+Kto, $7E));
LocalInfo^.Insert(ControlPassword);
  End
  Else
   MessageBox(^M+#3'Ошибка доступа к файлу '+Path.ToClientOplata+PrevS+'.cpl!',Nil,mfError+mfCancelButton);
   Redraw;
 End;
 End;
End;  *)


Destructor TLocalInfoDynamicDebit.Done;
Begin
Dispose(ControlClientLock,Done);
Dispose(ControlPassword,Done);
Dispose(ControlPrim,Done);
Dispose(ControlRashet,Done);
Dispose(ControlBank,Done);
Dispose(ControlSummaPP,Done);
Dispose(ControlDatePP,Done);
Dispose(ControlPP,Done);
Dispose(LocalDolgList,Done);

TDialog.Done;
End;

Destructor TEmplLocalInfoDynamicDebit.Done;
Begin
Dispose(ControlClientLock,Done);
Dispose(ControlPassword,Done);
Dispose(ControlPrim,Done);
Dispose(ControlRashet,Done);
Dispose(ControlBank,Done);
Dispose(ControlSummaPP,Done);
Dispose(ControlDatePP,Done);
Dispose(ControlPP,Done);
Dispose(LocalDolgList,Done);

TDialog.Done;
End;


procedure TInfoDynamicReturn.OpenDynamicReturnWindow;
Var l : Boolean;
begin
  if Message(Desktop, evBroadcast, cmInfoReturn, nil) = nil then
  begin
    DInfo('Инициализация хронологии возвратов...');
    L:=True;
    InfoReturnWindow := New(PInfoDynamicReturn, Init(L));
    If L Then
    Begin
    Application^.InsertWindow(InfoReturnWindow);
    NoInfo;
    End
    Else
     Begin
      Status:=DocNormal;
      Dispose(InfoReturnWindow,Done);
      NoInfo;
     End;
  end
  else
    if PView(InfoReturnWindow) <> Desktop^.TopView then InfoReturnWindow^.Select;
end;

procedure TInfoDynamicReturn.FullPreview;
Var Ass : DocumentEdit;
    E : PNewVozwratType;
    R : TRect;
    f : NewVozwratFileType;
    c : Word;
    P : PBox;
    s,ws : TMyString;
    Find : Boolean;
    SDoc : ArtikulStr;
    SDate : TDAteString;

Begin
If (DynamicReturnList^.List<>Nil)And(DynamicReturnList^.List^.Count>=1) Then
Begin
{  Ass.EditPosition:=Copy(DynamicReturnList^.GetText(DynamicReturnList^.Focused,DynamicReturnList^.List^.Count),
    1+1+CDate+1,CDocNumer-1);}
  Ass.EditPosition:=Copy(DynamicReturnList^.GetText(DynamicReturnList^.Focused,DynamicReturnList^.List^.Count),
    1+1,CDocNumer);
  DelSpace(Ass.EditPosition);
  DelZerro(Ass.EditPosition);
{  Ass.D:=Copy(DynamicReturnList^.GetText(DynamicReturnList^.Focused,DynamicReturnList^.List^.Count),1+1,CDate);}
  Ass.D:=Copy(DynamicReturnList^.GetText(DynamicReturnList^.Focused,DynamicReturnList^.List^.Count),1+1+CDocNumer+1,CDate);
  DelSpace(Ass.D);
  Assign(f,Path.ToReturn+Ass.d+'.vzw');
  c:=IOResult;
  Reset(f);
  c:=IOResult;
  If c<>0 Then
  Begin
   MessageBox(#3^M+#3'Ошибка доступа к файлу '+Path.ToReturn+Ass.d+'.vzw',Nil,mfError+mfCancelButton);
   Exit;
  End;
  DInfo('Ищу документ...');
  New(E,Init);
  Find := False;
  ClearChar(Ass.EditPosition);
  DelZerro(Ass.EditPosition);
  While Not(Eof(f)) And Not(Find) Do
   Begin
    {
     Repeat
     Until NetCall.Lock(f,FilePos(f)*SizeOf(NewVozwratType),SizeOf(NewVozwratType));
    }
     ReadNewVozwrat(f,E);
    {
     Repeat
      NetCall.UnLock(f,(FilePos(f)-1)*SizeOf(NewVozwratType),SizeOf(NewVozwratType));
     Until (DosError=0);
    }
    ClearChar(E^.Dat.Document);
    DelZerro(E^.Dat.Document);
    If (E^.Dat.DateC=Ass.D) and
    (E^.Dat.Document=Ass.EditPosition) Then
          Begin
           Find:=True;
           Break;
          End;
   End;
   System.Close(f);

If Find Then
  Begin
   R.Assign(0,0,0,0);
P := New(PBox, Init(R, 1, Nil));
P^.NewList(New(PTextCollection, Init(0,1)));
For c:=1 To E^.Dat.Amount Do
 Begin
  S:=E^.Dat.VozwratElement[c].BazKod;
  ws:=GetIdField(FName,s);
  Format(ws,CName);
  s:=ws+'│'+s+'│';

  Str(StrToInt(E^.Dat.VozwratElement[c].Input.DivisionS):1,ws);
  s:=s+ws;
  DelSpace(E^.Dat.VozwratElement[c].Input.Kol);
  Format(E^.Dat.VozwratElement[c].Input.Kol,CKol);
  s:=s+'│'+E^.Dat.VozwratElement[c].Input.Kol;

  DelSpace(E^.Dat.VozwratElement[c].Input.Zena);
  Format(E^.Dat.VozwratElement[c].Input.Zena,CZena);
  s:=s+'│'+E^.Dat.VozwratElement[c].Input.Zena;
  DelSpace(E^.Dat.VozwratElement[c].Input.LocalSkidka);
  Format(E^.Dat.VozwratElement[c].Input.LocalSkidka,CZena);
  s:=s+'│'+E^.Dat.VozwratElement[c].Input.LocalSkidka;
  DelSpace(E^.Dat.VozwratElement[c].Input.LocalProz);
  Format(E^.Dat.VozwratElement[c].Input.LocalProz,CLitr);
  s:=s+'│'+E^.Dat.VozwratElement[c].Input.LocalProz;
  DelSpace(E^.Dat.VozwratElement[c].Input.R_Zena);
  Format(E^.Dat.VozwratElement[c].Input.R_Zena,CZena);
  s:=s+'│'+E^.Dat.VozwratElement[c].Input.R_Zena;
  DelSpace(E^.Dat.VozwratElement[c].Input.O_Zena);
  Format(E^.Dat.VozwratElement[c].Input.O_Zena,CZena);
  s:=s+'│'+E^.Dat.VozwratElement[c].Input.O_Zena;
  P^.List^.Insert(NewStr(s));
  P^.SetRange(P^.List^.Count);
 End;
P^.FocusItem(0);
s:=E^.Dat.SummaR;
DelSpace(s);
s:=' Всего сумма возврата: '+s;
DelSpace(E^.Dat.Skidka);
s:=s+'  Всего скидка возврата: '+E^.Dat.Skidka;
SDoc:=E^.Dat.Document;
SDate:=E^.Dat.DateC;


Dispose(E,Done);

NoInfo;
             {Вставить номер и дату документа в просмотре}
FullScreen(P,' Выбранн~ы~е товары           Код  N Колич Цена     Скидка   Проц. Р/Цена   О/Цена',s,
SDoc,SDate,0);

Dispose(P,Done);
    End
Else
  Begin
  NoInfo;
  Dispose(E,Done);
  MessageBox(#3^M+#3'Документ не найден!',Nil,mfError+mfCancelButton);
  End;
End;
End;


constructor TInfoDynamicReturn.Init(Var l : Boolean);
var
  R : TRect;
  Control : PView;
  C : LongInt;
  p : Real;
  wp : String[cIzena];
begin
ClearFind;
L:=False;
R.Assign(0, 0, 80, 23);
inherited Init(R,'Хронология возвратов клиента');
Options := Options or ofCenterX or ofCenterY;

R.Assign(0, 0, 0, 0);
Client := New(PBox, Init(R, 1, Nil));
Client^.NewList(New(PTextCollection, Init(0,1)));
Assign (ClientFile,Path.ToClient+'Client.db');
c:=IOResult;
Reset (ClientFile);
c:=IOResult;
If c=0 Then
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
End
Else
 Begin
  L:=False;
  Exit;
 End;
PrevS:=Client^.GEtText(0,Client^.List^.COunt);
Dispose(Client,Done);

R.Assign(51, 1, 78, 2);
ControlClient := New(PColoredText, Init(R, #3+PrevS, $1F));
ControlClient^.Options := ControlClient^.Options or ofSelectable;
Insert(ControlClient);

  R.Assign(43, 1, 51, 2);
Insert(New(PLabel, Init(R, 'Кл~и~ент:', ControlClient)));

R.Assign(79, 3, 80, 21);
Control := New(PScrollBar, Init(R));
Insert(Control);

R.Assign(1, 3, 79, 21);
DynamicReturnList := New(PBox, Init(R, 1, PScrollbar(Control)));
DynamicReturnList^.NewList(New({PText}PMyCollection, Init(0,1)));
PrevS:=Copy(PrevS,1+CClient+1,CClientKod);

DynamicReturnList^.FocusItem(0);
DynamicReturnList^.HelpCtx:=$E316;

Insert(DynamicReturnList);

  R.Assign(1, 2, 79, 3);
  Insert(New(PLabel, Init(R, ' N    Дата взв.Дата Осн  N   Выдано из кассы  Сумма возврата Скидка возврата',
  DynamicReturnList)));
{
R.Assign(2, 20, 79, 22);
Control := New(PColoredText, Init(R, '0-Наличная продажа (авто) 1-Наличная '+
     'продажа (руч.) 2-Закрытая консиг. (авто) '^M+
     '3-Закрытая консиг. (руч.) 4-Открытая консиг. (авто) 5-Открытая '+
     'консиг. (руч.)', $74));
Insert(Control);
}
R.Assign(5, 21, 14, 22);
Control := New(PColoredText, Init(R, 'Оператор:', $74));
Insert(Control);

R.Assign(14, 21, 26, 22);
ControlPassword := New(PColoredText, Init(R, #3+'', $7E));
Insert(ControlPassword);

R.Assign(33, 21, 46, 22);
Control := New(PColoredText, Init(R, 'Вид возврата:', $74));
Insert(Control);

R.Assign(46, 21, 76, 22);
ControlVid := New(PColoredText, Init(R, #3+'', $7E));
Insert(ControlVid);



R.Assign(4, 22, 27, 23);
Control := New(PColoredText, Init(R, ' Итого выдано из кассы:', $74));
Insert(Control);

R.Assign(27, 22, 42, 23);
ControlKassa := New(PColoredText, Init(R, #3+'', $4E));
Insert(ControlKassa);

R.Assign(45, 22, 60, 23);
Control := New(PColoredText, Init(R, ' Итого возврат:', $74));
Insert(Control);

R.Assign(60, 22, 75, 23);
ControlReturn := New(PColoredText, Init(R, #3+'', $4E));
Insert(ControlReturn);

PrevCurrent[0]:=#0;

SelectNext(False);
L:=True;
end;

Procedure TInfoDynamicReturn.FormReport(Const P:PBox);
Const Space=' ';
Var f : text;
    r1,r2 : Real;
    s : TMystring;
    SummaK : String[CIZena];
    c,k : Word;
Begin
PStaticText(ControlClient)^.GetText(S);
System.Delete(S,Pos(#3,S),1);
S:=Copy(s,1+CClient+1,CClientKod);
If (P^.List<>Nil) And (P^.List^.Count>=1) Then
 Begin
 Assign (f,Path.ToTemp+'listdr.txt');
 c:=0;
 Rewrite(f);
 c:=IOResult;
 If c<>0 Then
  Begin
   MessageBox(#3^m+#3+'Не могу создать файл '+Path.ToTemp+'listdr.txt',Nil,mfError+mfCancelButton);
   Exit;
  End;
 Writeln(f,Space+'      СПРАВКА ПО ВОЗВРАТАМ КЛИЕНТА '+GetClientField(FClient,S,0)+'('+s+')'+' ('+FDate+' '+Times+')');
 Writeln(f,Space+'-------------------------------------------------------------------------------------------');
  Writeln(f,Space+' N    Дата взв.Дата Осн  N   Выдано из кассы  Сумма возврата Скидка возврата Т    Оператор');
 Writeln(f,Space+'-------------------------------------------------------------------------------------------');
 R1:=0;
 R2:=0;
 For c:=0 To P^.List^.Count-1 Do
  Begin
   s := P^.GetText(c,P^.List^.Count);
   While Pos('│',s)>0 Do
    Begin
     k:=Pos('│',s);
     System.Delete(s,k,1);
     System.Insert(' ',s,k);
    End;
   SummaK:=Copy(s,1+1+1+CDate+1+CDocNumer+1+CDate+CDocNumer+1,CIZena);
   Writeln(f,Space+s);
   R1:=R1+StrToReal(SummaK);
   SummaK:=Copy(s,1+1+1+CDate+1+CDocNumer+1+CDate+CDocNumer+1+CIZena+1,CIZena);
   R2:=R2+StrToReal(SummaK);
  End;
 Writeln(f,Space+'-------------------------------------------------------------------------------------------');
       s:='Всего из кассы выплачено:'+RecognizReal(R1,CIZena,CMantissa);
 Writeln(f,Space+s);
 s:='Всего возврат на склад составил:'+RecognizReal(R2,CIZena,CMantissa);
 Writeln(f,Space+s);
 Writeln(f,Space,'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
 Writeln(f,Space+'===========================================================================================');

 System.Close(f);
 ViewAsText(Path.ToTemp+'listdr.txt',True);
 Report(Path.ToTemp+'listdr.txt','',1,False,False,false);
 End;
End;



Procedure TInfoDynamicReturn.Refresh;
Var R : TRect;
    Test : LongInt;
    w,Wp : String[CIZena];
    ws : AllStr;
    Ret,Kassa : Real;

    ReturnFile : File Of NewVozwratType;
    Return : PNewVozwratType;
Begin
ClearFind;
DynamicReturnList^.NewList(Nil);
DynamicReturnList^.NewList(New({PText}PMyCollection, Init(0,1)));
PStaticText(ControlClient)^.GetText(PrevS);
System.Delete(PrevS,1,1);
PrevS:=Copy(PrevS,1+CClient+1,CClientKod);
Assign (ReturnFile,Path.ToClientReturn+PrevS+'.cvz');
Test:=IOResult;
Reset (ReturnFile);
Test:=IOResult;
Kassa:=0;
Ret:=0;
If Test=0 Then
Begin
DInfo('Читаю хронологию возвратов клиента...');
New(Return,Init);
While Not(Eof(ReturnFile)) Do
 Begin
  Read(ReturnFile,Return^.Dat);
  If Return^.Dat.OperatorSelector=0 Then
  Begin
    With Return^.Dat Do
    Begin
    RFormatZerro(Document,CDocNumer);
    Format (Document,CDocNumer);
    RFormatZerro(BasisDoc,CDocNumer);
    Format(BasisDoc,CDocNumer);
    Format (DAteC,CDate);
    Str(StrToReal(SummaR):CIZena:CMantissa,SummaR);
    Str(StrToReal(Skidka):CIZena:CMantissa,Skidka);
    Str(StrToReal(SummaR)-StrToReal(Skidka):CIZena:CMantissa,ws);
    Kassa:=Kassa+StrToReal(ws);
    Ret:=Ret+StrToReal(SummaR);
    wp:= GetOperatorName(Caption);
    Format(wp,CKto);
    Str(VidDocument:COne,w);

    DynamicReturnList^.List^.Insert(NewStr('│'+Document+'│'
    +DateC+'│'++BasisDate+'│'+BasisDoc+'│'+ws+'│'+SummaR+'│'+Skidka+'│'+w+'│'+wp));
    End;
    DynamicReturnList^.SetRange(DynamicReturnList^.List^.Count);
{' Дата взв. N  Дата Осн  N  Выдано из кассы  Сумма возврата Скидка возврата Т', DynamicReturnList)));}
  End;
 End;
System.Close(ReturnFile);
Dispose(Return,Done);
NoInfo;
End;

Str(Kassa:CIZena:CMantissa,ws);
DelSpace(ws);
Dispose(ControlKassa,Done);
R.Assign(27, 22, 42, 23);
ControlKassa := New(PColoredText, Init(R, #3+ws, $4E));
Insert(ControlKassa);

Str(Ret:CIZena:CMantissa,ws);
DelSpace(ws);
Dispose(ControlReturn,Done);
R.Assign(60, 22, 75, 23);
ControlReturn := New(PColoredText, Init(R, #3+ws, $4E));
Insert(ControlReturn);

DynamicReturnList^.FocusItem(0);
DynamicReturnList^.HelpCtx:=$E316;
PrevCurrent[0]:=#0;
Redraw;

End;

Procedure TInfoDynamicReturn.FreshInfoHint;
Var R : TRect;
    s : TMyString;
    wS : AllStr;
Begin
If (DynamicReturnList^.State and sfFocused <> 0) And (DynamicReturnList^.List<>Nil)And(DynamicReturnList^.List^.Count>=1) Then
 Begin
  s:=DynamicReturnList^.GetText(DynamicReturnList^.Focused,DynamicReturnList^.List^.Count);
  If s <> PrevCurrent Then
  Begin
  PrevCurrent:=S;
  ws:=Copy(s,1+1+CDate+1+CDocNumer+1+CDate+1+CDocNumer+1+CIZena+1+CIZena+1+CIZena+1+CONe+1,CKto);
  Dispose(ControlPassword,Done);
  R.Assign(14, 21, 26, 22);
  ControlPassword := New(PColoredText, Init(R, #3+ws, $7E));
  Insert(ControlPassword);

  ws:=Copy(s,1+1+CDate+1+CDocNumer+1+CDate+1+CDocNumer+1+CIZena+1+CIZena+1+CIZena+1,CONe);
  Case StrToInt(ws) Of
  0:ws:='Наличная продажа (авто)';
  1:ws:='Наличная продажа (руч.)';
  2:ws:='Закрытая консиг. (авто)';
  3:ws:='Закрытая консиг. (руч.)';
  4:ws:='Открытая консиг. (авто)';
  5:ws:='Открытая консиг. (руч.)';
  Else ws[0]:=#0;
  End;{Case}

  Dispose(ControlVid,Done);
  R.Assign(46, 21, 76, 22);
  ControlVid := New(PColoredText, Init(R, #3+ws, $7E));
  Insert(ControlVid);

 End;
End;

End;

procedure TInfoDynamicReturn.HandleEvent(var Event: TEvent);
Var test : Word;
    s : TMyString;
    l : Boolean;
    R : Real;
    b : Byte;
begin

  Case Event.What Of
  evCommand :
     Case Event.Command Of

      cmAbout: BEgin
        AboutCHM('46');
        ClearEvent(Event);
      End;

      cmCancel : Begin
                 Dispose(ControlClient,Done);
                 Dispose(DynamicReturnList,Done);
                 Event.What:=evCommand;
                 Event.Command:=cmClose;
                End;
     cmFullview : Begin
     If (DynamicReturnList^.State and sfFocused <> 0) And (DynamicReturnList^.List<>Nil)And(DynamicReturnList^.List^.Count>=1)
     Then
              FullPreview;
            End;
 cmReestrReport:    Begin
     If (DynamicReturnList^.State and sfFocused <> 0) And (DynamicReturnList^.List<>Nil)And(DynamicReturnList^.List^.Count>=1)
     Then
            Begin
            FormReport(DynamicReturnList);
            End
            End;

  cmSelectClient:
 Begin
  If (PView(Cl)<>Desktop^.TopView)And(ControlClient^.State and sfFocused <> 0) Then
  Begin
     ControlClient^.Focus;
     PStaticText(ControlClient)^.GetText(S);
     System.Delete(S,1,1);
     Cl^.ShowClientList(s,0,0,True,False,False,-1,-1,-1,-1,Test);
     PStaticText(ControlClient)^.Text^:=#3+S;
     PrevS:=S;
        Case Test Of
      0,3 :FocusNext(True);
      1,2 :FocusNext(False);
     Else;
  End;
  Refresh;
     End;
     Redraw;
     ClearEvent(Event);
 End;

      Else;
      End;
      Else;
      End;{*Case*}

  if (Event.What = evBroadcast) and
    (Event.Command = cmInfoReturn) then ClearEvent(Event);
  if (Event.What = evBroadcast) and
    (Event.Command = cmQuit) then ClearEvent(Event);

 If (PView(Cl)<>Desktop^.TopView)And(ControlClient^.State and sfFocused <> 0)
 And (Event.Command<>cmSelectClient) And (Event.What <> EvKeyDown)Then
            Begin
             Event.What:=EvCommand;
             Event.Command:=cmSelectClient;
             PutEvent(Event);
             ClearEvent(Event);
            End;
  inherited HandleEvent(Event);

  If (Desktop^.Current=PView(InfoReturnWindow)) And (Event.What <> EvKeyDown) Then
   Begin
{    If (DynamicReturnList^.List^.Count>=1) Then
       EnableCommands([cmFullview,cmReestrReport])
      Else
         DisableCommands([cmFullview,cmReestrReport]);}

      FreshInfoHint;
   End;
end;



Procedure CalcNDS (As: DocumentEdit;Var NDS,NP:Real);
Var f : MarketFileType;
    E : PSuperMarketType;
    NDS20,NDS10,NDS_,ItogoSkidka,Itogo : Real;
    NP5,NP3,NP_ : Real;
    L : Word;
    SArtikul1:ArtikulStr;
    Find : Boolean;
    txt : Text;
Begin
 NDS:=0;
 Np:=0;
 Assign(F,Path.ToMarket+As.D+'.mrk');
 l:=IOResult;
 Reset(f);
 l:=Ioresult;
 If L <> 0 Then
  Begin
   MessageBox(#3^M+#3'Не найден файл '+Path.ToMarket+As.D+'.mrk',Nil,mfError+mfCancelButton);
   Exit;
  End;
 Assign(Txt,Path.ToTemp+'order.$$$');
 l:=IOResult;
 Rewrite(Txt);
 l:=IOResult;
 If L <> 0 Then
  Begin
   Close(f);
   MessageBox(#3^M+#3'Не могу создать файл отчета '+Path.ToTemp+'order.$$$',Nil,mfError+mfCancelButton);
   Exit;
  End;
 Close(Txt);

 Find :=False;
 New(E,Init);
 DelZerro(As.EditPosition);
 While Not(Eof(f))And Not(Find) Do
 Begin
     {
     Repeat
     Until Lock(f,FilePos(f)*SizeOf(SuperMarketType),SizeOf(SuperMarketType));
     }
     ReadMarket(f,E);
     {
     Repeat
      UnLock(f,(FilePos(f)-1)*SizeOf(SuperMarketType),SizeOf(SuperMarketType));
     Until (DosError=0);
     }
  DelSpace(E^.Dat.Document);
  DelZerro(E^.Dat.Document);
  If  (ClearChar(E^.Dat.Document)=ClearChar(As.EditPosition)) And(E^.Dat.Active)
  And(E^.Dat.DateC=As.D) Then Find:=True;
 End;

 If Not(Find) Then
 Begin
   Dispose(E,Done);
   Close(f);
   MessageBox(#3^M+#3'Документ N '+ As.EditPosition+' в базе за '+As.D+' не найден!',Nil,mfError+mfCancelButton);
   Exit;
 End;
 Close(f);

{уменьшаем количество на велечину возврата}
 For l:=1 To E^.Dat.Amount Do
Begin
  Str(E^.Dat.MarketElement[L].Input.DiviSionSNumber:1,SArtikul1);

  Str(STrToInt(E^.Dat.MarketElement[l].Input.Kol)-
  StrToInt(GetReturnKol(E^.Dat.Document,E^.Dat.DateC,E^.Dat.ClientKod,
  E^.Dat.MarketElement[l].BazKod,SArtikul1,
  E^.Dat.OperatorSelector)):CKol,E^.Dat.MarketElement[L].Input.Kol);
End;
 Rewrite(Txt);
 FormSf(False, E, Txt, NDS, Itogo, ItogoSkidka,NDS20,NDS10,NDS_);

 Dispose(E,Done);
 NP:=Np5+Np3+Np_;
 Close(Txt);
End;



End.
