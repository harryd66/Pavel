{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}


{$I Compile.INC}

Unit MrkTool;

Interface


Uses Servstr,MArket,Glob,NetDbEng;


Function DeleteRealizasToClientFile:Boolean;
Procedure SetEnabledDoc(i:Byte);
Procedure AddNaklNumer(Art:ArtikulStr;Prev:PSuperMArketType;Var Osn : Osnovanie);
Function CalcVes(As:DocumentEdit):String;
Function TestReturn(Doc,Date,TimeOpl,DateOpl:TDateString;Var s : String;Prevs: TEnjoyStr):Boolean;
Procedure PrintOrder3(Osn,Lizo,Doc,Date,Kod,Summa:AllStr);

 Var PrevMarket : PSuperMarketType;

Implementation

Uses MsgBox,Serv,Utils,Dialogs,DBEngine,Printers,TPDate;

Procedure PrintOrder3(Osn,Lizo,Doc,Date,Kod,Summa:AllStr);
 {kod=1 - приходник}
Const Space=' ';
Var s,ws1,ws2,SdOC : TMyString;
    Status,Res : Word;
    Txt : Text;
    fName: string;
Begin
{$IfDEF DPMI}
fName:=Doc+Date;
DelSpace(fName);
while pos('-',fName)>0 do Delete(fName,pos('-',fName),1);
delete(fName,length(fName)-2,2);
fName:=FName+Fdate;
while pos('-',fName)>0 do Delete(fName,pos('-',fName),1);
delete(fName,length(fName)-2,2);
while pos('0',fName)>0 do Delete(fName,pos('0',fName),1);
Insert('.',fname,length(fName)-2);

if not (CurrentPassword='00') then
if FExists(Path.ToOperator+fName) then
Begin
MessageBox(#3+'Документ уже напечатан!!!',Nil,mfError+mfCancelButton);
exit;
End;

Assign(txt,Path.TooPERATOR+fName);
Res:=IoResult;
Rewrite(txt);
Res:=IoResult;
If Res<>0 Then
 Begin
  MessageBox(#3+'Ошибка создания '+Path.tOoPERATOR+fName+' Код:'+
  IntToStr(Res,CKol),Nil,mfError+mfCancelButton);
  Exit;
 End;

s:='ИП Еродский П.Е.';
Format(s,CAll-15);

Status:=StrToInt(Kod);


If Status=1 Then
Begin

Writeln(txt,Space+'Организация:                                       ||');
Writeln(txt,Space+s+' Склад:'+Rek.Kod+'          || '+S);
Writeln(txt,Space+'                                                   ||');
DelZerro(Doc);

SDoc:='____';



Writeln(txt,Space+Bold[NPrint.Printer]+Double[NPrint.Printer]+'       ПРИХОДНЫЙ КАССОВЫЙ ОРДЕР N '+sDoc+
NoDouble[NPrint.Printer]+
NoBold[NPrint.Printer]+'             ||        '
+Bold[NPrint.Printer]+
+Double[NPrint.Printer]+' К В И Т А Н Ц И Я'+NoDouble[NPrint.Printer]+NoBold[NPrint.Printer]);
Writeln(txt,Space+'              от '+fDate+'                          || к приходному кассовому ордеру N '+
sDoc);
s:='____________________';

s:=Lizo;
Format (s,CClient+7);

Writeln(Txt,Space+'                                                   ||     от '+fDate);
Writeln(txt,Space+'    Принято от '+s+'         ||  Принято от '+s);
s:=Osn;
Format (s,CClient-5);
rFormat(Doc,CDocNumer);
Writeln(txt,Space+'    Основание: '+s+Doc+' от '+Date+'     ||  Основание: '+s+Doc+' от '+Date);
Writeln(txt,Space+'                                                   ||');

s:=Summa;
DelSpace(s);
ws1[0]:=#0;
ws2[0]:=#0;

Writeln(Txt,Space+' Сумма(прописью)_________________________________  || Сумма(прописью)_________________________________');
Writeln(Txt,Space+' ________________________________________________  || ________________________________________________');
Writeln(Txt,Space+'                                                   ||');
Writeln(Txt,Space+' Сумма(цифрами)____________________руб.______коп.  || Сумма(цифрами)____________________руб.______коп.');
Writeln(Txt,Space+'                                                   ||');
Writeln(Txt,Space+' Главный бухгалтер: _________    ________________  || Главный бухгалтер: ________ ______________');
Writeln(txt,Space+'                     Подпись      Расшифр.         ||                     Подпись  Расшифр.');

Writeln(txt,Space+'                                                   ||');
Writeln(Txt,Space+' Кассир:            _________    ________________  || Кассир:            ________ ______________');
Writeln(txt,Space+'                     Подпись      Расшифр.         ||                     Подпись  Расшифр.');
Writeln(txt,Space+'                                                   ||');
Writeln(Txt,Space+' Торговый                                          || Торговый                             ');
Writeln(Txt,Space+' представитель:     _________    ________________  || представитель:     ________ ______________');
Writeln(Txt,Space+'                     Подпись      Расшифр.         ||                     Подпись  Расшифр.');

Writeln(txt,Space+'=======================================================================================================');
End
  Else
    Begin

{MyStr(StrToReal(Summa)*(-1),CZena,CMAntissa,Summa);}
DelSpace(Summa);
Doc:='_____';
Writeln(txt,Space+'Предприятие:ИП Еродский П.Е.                         Склад:'+Rek.Kod);
Writeln(txt,Space+Bold[NPrint.Printer]+Double[NPrint.Printer]+
'                      РАСХОДНЫЙ КАССОВЫЙ ОРДЕР N '+Doc+' от '+
Date+NoDouble[NPrint.Printer]+NoBold[NPrint.Printer]);
Writeln(txt);
s:='____________________';
s:=Lizo;
Format(s,CClient);
WriteLN(txt,Space+' Выдать: '+s);
s:=osn;
Format(s,CClient);
WriteLN(txt,Space+' Основание: '+s);


s:=Summa;
{Propis(s,ws1);}
s:=ws1+s;
SpecialFormat(s,ws1,ws2);

ws1:=ws1+ws2;
Ws1[1]:=UpperCase(ws1[1]);
Writeln(txt,Space+' Сумма:   '+Italic[NPrint.Printer]+Double[NPrint.Printer]+ws1+NoDouble[NPrint.Printer]
+NoItalic[NPrint.Printer]);
If s[0]<>#0 Then
Begin
Format(s,41);
Writeln(txt,Space+Italic[NPrint.Printer]+Double[NPrint.Printer]+s+NoDouble[NPrint.Printer]+NoItalic[NPrint.Printer]);
End;
Writeln(txt,Space+'                    '+Double[NPrint.Printer]+Summa+' руб.'+NoDouble[NPrint.Printer]);
WriteLN(txt,Space+' Приложение: _____________________________________________________________________________');
WriteLN(txt);
WriteLN(txt,Space+'        Руководитель: ________ ___________   Главный бухгалтер: ________ ___________');
WriteLN(txt,Space+'                       Подпись   Расшифр.                        Подпись   Расшифр.');
WriteLN(txt);
WriteLN(txt,Space+'             "'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+
'  Подпись получателя: ___________________');
WriteLN(txt);

Writeln(txt,Space+' Получил: ________________________________________________________________________________');

WriteLN(txt,Space+' по документу: ___________________________________________________________________________');
WriteLN(txt);
WriteLN(txt,Space+'                            Выдал кассир: _________  ____________');
WriteLN(txt,Space+'                                           Подпись     Расшифр.');
WriteLN(txt,Space+'==========================================================================================');
    End;



Res:=IoResult;
Close(txt);
Res:=IoResult;
Report(Path.TooPERATOR+fName,'',1,False,False,true);

{$EndIf}
End;


Function TestReturn(Doc,Date,TimeOpl,DateOpl:TDateString;Var s : String;Prevs: TEnjoyStr):Boolean;
Var Ass : DocumentEdit;
    Test : Word;
    SDAte,STime:TDateString;
    Find : Boolean;
    ClientOplataFile : File Of ClientOplataRealizasiaType;
    ClientOplata : ClientOplataRealizasiaType;

Begin
  Ass.EditPosition:=Doc;
  DelSpace(Ass.EditPosition);
  ClearChar(Ass.EditPosition);
  Ass.D:=DAte;
  DelSpace(Ass.D);

  TestReturn:=False;
  Assign (ClientOplataFile,Path.ToClientOplata+PrevS+'.cpl');
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

     If  (StrToInt(ClientOplata.Document)=StrToInt(Ass.EditPosition)) And (Ass.D=ClientOplata.DateDoc)
     And (ClientOplata.DateC=DateOpl) And (ClientOplata.TimeC=Timeopl) {And (ClientOplata.SummaZ=SSumma)}Then
      Begin
       Find:=True;
      End;
    End;
    System.Close(ClientOplataFile);
    If Not(Find) Then
     Begin
      MessageBox(^M+#3'Документ '+Ass.EditPosition+' в файле оплаты долгов клиента не найден!',Nil,mfError+mfCancelButton);
      s[0]:=#0;
      Exit;
     End;
    If ClientOplata.Vozwrat Then
    Begin
      TestReturn:=true;
      s:='Внимание! Возврат по документу N'+ClientOplata.DocNumerReturn+' от '+ClientOplata.DocDateReturn;
    End;
  End;
End;



Function CalcVes(As:DocumentEdit):String;
var  ef : MarketFileType;
     Find : Boolean;
     i : Word;
     L : PSuperMarketType;
     sMassa: string[CIZena];
Begin
  sMassa:='';
  CalcVes:='';
  Assign(ef,Path.ToMarket+As.D+'.mrk');
  i:=IOResult;
  Reset(ef);
  i:=IOResult;
  If i<>0 Then
   Begin
    MessageBox(^M+#3+'Ошибка открытия '+Path.ToMarket+As.D+'.mrk!'^M+#3+
               ClicProgrammer,Nil,mfInsertInApp+mfError+mfCancelButton);
    Exit;
   End;
  New(L,Init);
  DelSpace(As.EditPosition);
  Find:=False;
 {оптимизация поиска}
   If FileSize(ef)>(StrToInt(As.EditPosition)-1) Then
    Begin
     Seek(ef,StrToInt(As.EditPosition)-1);
     ReadMarket(ef,L);
     DelSpace(L^.Dat.Document);
     If ((StrToInt(ClearChar(As.EditPosition))=StrToInt(ClearChar(L^.Dat.Document)))And
          (As.D=L^.Dat.DateC) And (L^.Dat.Active)) Then
         Begin
             Find:=True;
         End
         Else Seek(ef,0);
    End;

  While Not(Eof(ef)) And Not(Find) Do
        Begin
         ReadMarket(ef,L);
         DelSpace(L^.Dat.Document);
          If ((StrToInt(ClearChar(As.EditPosition))=StrToInt(ClearChar(L^.Dat.Document)))And
          (As.D=L^.Dat.DateC) And (L^.Dat.Active)) Then Find:=True;
        End;

  If Not(Find) Then
   Begin
    {NoInfoMsg;}
    Dispose(L,Done);
    Close(Ef);
    MessageBox(^M+#3'Документ N '+ClearChar(As.EditPosition)+
    ' от '+As.D+' не найден !'^M+
    #3+ClicProgrammer,Nil,mfInsertInApp+mfError+mfCancelButton);
    Exit;
   End
   else
   Begin

  sMassa:='';
  for i:=1 to L^.Dat.Amount do
  begin

    MyStr(StrToReal(sMassa)+
    StrToreal(GetIdField(flITR,L^.Dat.MarketeLEMENT[i].Bazkod))*StrToReal(L^.Dat.MarketeLEMENT[i].iNPUT.KOl)
    ,CIZena,CMantissa,sMassa)
  end;
  end;

  Dispose(L,Done);
  Close(Ef);
  CalcVes:=sMassa;

End;


Function DeleteRealizasToClientFile:Boolean;
Var l :  PRealizasiaType;
    RealFile : File Of RealizasiaType;
    NewFile : File Of RealizasiaType;
    i : Byte;
    Find,Log : Boolean;

Begin
 DeleteRealizasToClientFile:=False;
 Assign(RealFile,Path.ToDolg+PrevMarket^.Dat.ClientKod+'.dlg');
 i:=IOResult;
 Reset(RealFile);
 i:=IOResult;
 If i <> 0 Then
  Begin
    MessageBox(#3^M+#3'Файл задолженности клиента '^M+#3+Path.ToDolg+PrevMarket^.Dat.ClientKod+'.dlg не найден!'^M
   ,Nil,mfError+mfCancelButton);
    Exit;
  End;
  New(l,Init);
  DelSpace(PrevMarket^.Dat.Document);
  Find:=False;
  DInfoMsg('Ищу документ в долгах клиента '+PrevMarket^.Dat.ClientKod+'...');
  While Not(Eof(RealFile)) And Not(Find) Do
        Begin
         Read(RealFile,L^.Dat);
         DelSpace(L^.Dat.Market.Document);
          If ((ClearChar(PrevMarket^.Dat.Document)=ClearChar(L^.Dat.Market.Document))And
          (PrevMArket^.Dat.DateC=L^.Dat.Market.DateC) And (L^.Dat.Market.Active)) Then Find:=True;
        End;

  If Not(Find) Then
   Begin
    NoInfoMsg;
    Dispose(L,Done);
    Close(RealFile);
    MessageBox(#3'Документ N '+ClearChar(PrevMarket^.Dat.Document)+
    ' от '+PrevMArket^.Dat.DateC+' в долгах клиента не найден!'^M+
    ClicProgrammer,Nil,mfError+mfCancelButton);
    Exit;
   End;

    Seek(RealFile,FilePos(RealFile)-1);
    L^.Dat.Market.Active:=False;
    Write(RealFile,L^.Dat);
    i:=IoREsult;
    Close(RealFile);
    i:=IoREsult;
    Dispose(L,Done);
    NoInfoMsg;
    DeleteRealizasToClientFile:=True;
End;


Procedure SetEnabledDoc(i:Byte);
Var mm : Maska9;
    mmms,c : Word;
    mm10 : Maska10;
Begin
If i=0 Then
Begin
WordToBit9(MasDocNumer,MM);
For c:=1 To Max9 Do
If Mm[c]=1 Then Mm[c]:=0
Else Mm[c]:=1;

For c:=1 to Max10-1 Do Mm10[c+1]:=mm[c];{переход к 8 видам документа}
mm10[1]:=0;

BitToWord10(MM10,MMMS);
PCluster(ControlSelect)^.SetButtonState(MMMS, False);
End;
If i=1 Then
 Begin
  mm10[1]:=0;
  mm10[2]:=0;
  mm10[3]:=0;
  mm10[4]:=0;
  mm10[5]:=0;
  mm10[6]:=0;
  mm10[7]:=0;
  mm10[8]:=0;
  mm10[9]:=0;
  mm10[10]:=1;
  BitToWord10(MM10,MMMS);
  PCluster(ControlSelect)^.SetButtonState(MMMS, True);
 End;
End;



Procedure AddNaklNumer(Art:ArtikulStr;Prev:PSuperMArketType;Var Osn : Osnovanie);
Var Found : Boolean;
      c : Word;
Begin
  Found := False;
  For c:=1 To Prev^.Dat.Amount Do
   Begin
    If Art=Prev^.Dat.MarketElement[c].BazKod Then
     Begin
      Osn.NaklNumer:=Prev^.Dat.MarketElement[c].Input.Osn.NaklNumer;
      Osn.DateNakl :=Prev^.Dat.MarketElement[c].Input.Osn.DateNakl;
      Found:=True;
      Break;
     End;
   End;

  If Not Found Then
   Begin
    Osn.NaklNumer:=BakGetField(FNaklOsn,Art,0);
    Osn.DateNakl :=BakGetField(FDateOsn,Art,0);
   End;

End;





End.