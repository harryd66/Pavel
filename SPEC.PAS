{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}

Unit Spec;


Interface

Uses Glob,ServStr;

Procedure Analys;
Procedure FormReportKassa;

Implementation

Uses App,Objects,Dialogs,Validate,Access1,Access,ColorTxt,Tools,MyView,
     DbEngine,NetDbEng,Net,Serv,MsgBox,Views,TpDate,Prise,Vision2;


Type FindShkalaShablon = Record
      Graniza : Array[2..7] Of String[CLitr+1];
     End;

Type ResType = Record
      DohodAbs:String[CIZena];
     DohodProz:String[CIZena];
       Zakupka:String[CIZena];
        Oplata:String[CIZena];
        Skidka:String[CIZena];
        Client:LongInt;
     End;

Type GlobalResult = Record
     Res : Array[1..8] Of ResType;
     End;

Type
    PGlobalResult = ^GlobalResultPtr;
    GlobalResultPtr=Object(TObject)
    Dat  :  GlobalResult;
     Constructor Init;
     Destructor Done; Virtual;
 end;




Var StartDate,StopDAte:TDateString;
    Start,Stop,Cur:LongInt;
    Curs:TDAteString;
    f : MarketFileType;
    f1 : OplataRealizasiaFileType;
    f2 : File Of ClientOplataRealizasiaType;
    i : LongInt;
    E : PSuperMarketType;
    Oplata : OplataRealizasiaType;
    COplata : ClientOplataRealizasiaType;
    FF : Boolean;
    Find : FindShkalaShablon;
    RR : PGlobalResult;


Constructor GlobalResultPtr.Init ;
Var c : Word;
Begin
TObject.Init;
For c:=1 To 8 Do
With Dat.Res[c] Do
 Begin
      DohodAbs[0]:=#0;
     DohodProz[0]:=#0;
       Zakupka[0]:=#0;
        Oplata[0]:=#0;
        Skidka[0]:=#0;
       Client:=0;
 End;
End;

Destructor GlobalResultPtr.Done;
Begin
TObject.Done;
End;




{индекс по продажам клиенту}

Function GetGranizi : Boolean;
Label 1;
var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  Find1 : FindShkalaShablon;
  c : Word;
  txt : Text;

begin
GetGranizi:=False;

Assign(txt,Path.ToProgram+'gran.ini');
c:=IOResult;
reset(txt);
c:=IOResult;
For c:=2 To 7 Do
 Begin
  Readln(txt,Find.Graniza[c]);
 End;
Close(txt);
c:=IOResult;

For c:=2 to 7 Do DelSpace(Find.Graniza[c]);


Find1:=Find;

1:
R.Assign(31, 6, 49, 17);
New(Dlg, Init(R, 'Границы'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx := $E002;
R.Assign(7, 3, 14, 4);
Control := New(PInputLine, Init(R, CLitr+1));
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['0','1','2','3','4','5','6','7','8','9','0','.']));

  R.Assign(1, 3, 7, 4);
  Dlg^.Insert(New(PLabel, Init(R, '~1~ до:', Control)));

R.Assign(7, 4, 14, 5);
Control := New(PInputLine, Init(R, CLitr+1));
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['0','1','2','3','4','5','6','7','8','9','0','.']));

  R.Assign(1, 4, 7, 5);
  Dlg^.Insert(New(PLabel, Init(R, '~2~ до:', Control)));

R.Assign(7, 5, 14, 6);
Control := New(PInputLine, Init(R, CLitr+1));
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['0','1','2','3','4','5','6','7','8','9','0','.']));

  R.Assign(1, 5, 7, 6);
  Dlg^.Insert(New(PLabel, Init(R, '~3~ до:', Control)));

R.Assign(7, 6, 14, 7);
Control := New(PInputLine, Init(R, CLitr+1));
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['0','1','2','3','4','5','6','7','8','9','0','.']));

  R.Assign(1, 6, 7, 7);
  Dlg^.Insert(New(PLabel, Init(R, '~4~ до:', Control)));

R.Assign(7, 7, 14, 8);
Control := New(PInputLine, Init(R, CLitr+1));
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['0','1','2','3','4','5','6','7','8','9','0','.']));

  R.Assign(1, 7, 7, 8);
  Dlg^.Insert(New(PLabel, Init(R, '~5~ до:', Control)));

R.Assign(7, 8, 14, 9);
Control := New(PInputLine, Init(R, CLitr+1));
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['0','1','2','3','4','5','6','7','8','9','0','.']));

  R.Assign(1, 8, 7, 9);
  Dlg^.Insert(New(PLabel, Init(R, '~6~ до:', Control)));
{
R.Assign(7, 2, 14, 3);
Control := New(PColoredText, Init(R, 'Базовая', $13));
Dlg^.Insert(Control);

R.Assign(7, 1, 14, 2);
Control := New(PColoredText, Init(R, 'Наценка', $13));
Dlg^.Insert(Control);

R.Assign(7, 9, 14, 10);
Control := New(PColoredText, Init(R, 'Более 6 колонки', $13));
Dlg^.Insert(Control);
}
Dlg^.SelectNext(False);
Dlg^.SetData(Find1);
c:=Desktop^.ExecView(Dlg);
If c<>cmCancel Then
 Begin
   Dlg^.GetData(Find1);
   For c:=2 To 7 Do
    Begin
     If c<>2 Then
      Begin
       If StrToReal(Find1.Graniza[c])>=StrToReal(Find1.Graniza[c-1]) Then
        Begin
         Dispose(Control,Done);
         Dispose(Dlg,Done);
         MessageBox(^M+#3'Ошибка в '+IntToStr(c,1)+' границе шкалы классификации!',Nil,mfError+mfCancelButton);
         Goto 1;
        End;
      End;
    End;

   For c:=2 To 7 Do
    Begin
     Str(StrToReal(Find1.Graniza[c]):CLitr+1:CMantissa+2,Find.Graniza[c]);
     DelSpace(Find.Graniza[c]);
    End;
    GetGranizi:=True;

Assign(txt,Path.ToProgram+'gran.ini');
c:=IOResult;
rewrite(txt);
c:=IOResult;
For c:=2 To 7 Do
 Begin
  Writeln(txt,Find.Graniza[c]);
 End;
Close(txt);
c:=IOResult;




 End;
Dispose(Control,Done);
Dispose(Dlg,Done);
end;


(*
Function GetNaklIndex(E:PSuperMarketType):Word;
Var c:Word;
    f : Boolean;
    r1,r2,r3:Double;
    s3 : TDateString;
Begin
GetNaklIndex:=0;

If StrToReal(E^.Dat.Skidka)<0 Then
 Begin
  Exit;
 End;

DelSpace(E^.Dat.Skidka);
If {StrToReal(}E^.Dat.Skidka='0.00'{)<0.009} Then
{If StrToReal(E^.Dat.Skidka)<0.009 Then}
 Begin
  GetNaklIndex:=1;
  Exit;
 End;
f:=False;
For c:=2 To 7 Do
 Begin
  {сумма со склада}
  r1:=StrToReal(E^.Dat.SummaZ)+StrToReal(E^.Dat.Skidka){-StrToReal(E^.Dat.ENalog)};
  {сумма скидки}
  r2:=StrToReal(E^.Dat.Skidka);
  Str((r1/(r2)):CLitr+1:CLitrMantissa+1,s3);
  If StrToReal(s3)<=StrToReal(Find.Graniza[c]) Then
   Begin
    f:=True;
    Break;
   End;
 End;

if f Then
 Begin
  GetNaklIndex:=c;
  Exit;
 End;
GetNaklIndex:=8;{свыше}
End;
*)


Function GetNaklIndex(E:PSuperMarketType):Word;
Var c:Word;
    f : Boolean;
    r1,r2,r3:Double;
    s3 : TDateString;
Begin
GetNaklIndex:=1;

  r1:=StrToReal(E^.Dat.SummaZ)+StrToReal(E^.Dat.Skidka){-StrToReal(E^.Dat.ENalog)};
  {сумма скидки}
  r2:=StrToReal(E^.Dat.Skidka);
  If Abs(r1)>0.009 Then
  Str(1-(r2/(r1)):CLitr+1:CLitrMantissa+1,s3)
  Else
  s3:='1.0000';

  If StrToReal(s3)>=StrToReal(Find.Graniza[2]) Then
   Begin
    GetNaklIndex:=1;
    Exit;
   End;


f:=False;
For c:=7 DownTo 2 Do
 Begin
  {сумма со склада}
  r1:=StrToReal(E^.Dat.SummaZ)+StrToReal(E^.Dat.Skidka){-StrToReal(E^.Dat.ENalog)};
  {сумма скидки}
  r2:=StrToReal(E^.Dat.Skidka);
  If Abs(r1)>0.009 Then
  Str(1-(r2/(r1)):CLitr+1:CLitrMantissa+1,s3)
  Else
  s3:='1.0000';

  If StrToReal(s3)<=StrToReal(Find.Graniza[c]) Then
   Begin
    f:=True;
    Break;
   End;
 End;

if f Then
 Begin
 {If (c=2) And (StrToReal(s3)<StrToReal(Find.Graniza[c])) Then
   Begin
    c:=1;
   End;}
  GetNaklIndex:=c;
  Exit;
 End;


End;



Procedure Analys;
Var Txt : Text;
    Index,l,Start,Stop,Cur : LongInt;
    Agent1 : PBox;
    R : TRect;
    s,Space : String;
    ClientList : Array [0..8] Of PBox;
    E : PSuperMarketType;
    f : MarketFileType;
    DohodProz:ArtikulStr;
    Dohod :String[CIZena];
    AllZakupka,AllOplata,AllDohod,AllDohodProz:Real;
    AllClient:LongInt;
    Count : Word;

Begin
Space:='   ';
If Not(DatePeriodDialog(StartDate,StopDate,False)) Then Exit;

Start:=DateStringToDate(DatemAsk,StartDate);
Stop:=DateStringToDate(DatemAsk,StopDate);

 Assign(Txt,Path.ToTemp+'polskid.txt');
 l:=IOResult;
 Rewrite(Txt);
 l:=IOResult;
 If L <> 0 Then
  Begin
   MessageBox(#3^M+#3'Не могу создать файл отчета'+Path.ToTemp+'polskid.txt',Nil,mfError+mfCancelButton);
   Exit;
  End;


If Not(GetGranizi) Then Exit;

R.Assign(0,0,0,0);
Agent1 := New(PBox, Init(R, 1, Nil));
Agent1^.NewList(New(PTextCollection, Init(1,1)));

If Not SelectionAgent(Agent1) Then
 Begin
  Close(txt);
  Dispose(Agent1,Done);
  Exit;
 End;

R.Assign(0,0,0,0);
For cur:=1 to 8 Do
 Begin
  ClientList[cur] := New(PBox, Init(R, 1, Nil));
  ClientList[cur]^.NewList(New(PTextCollection, Init(1,1)));
 End;

Count:=0;

New(RR,init);
For cur:=Start to Stop Do
 Begin
  s:=DateToDateString(DateMask,Cur);
  Assign(f,Path.ToMarket+s+'.mrk');
  l:=IoResult;
  Reset(f);
  l:=IoResult;
  If l=0 Then
  Begin
  New(E,Init);
  While Not(eof(f)) Do
   Begin
    ReadMarket(f,E);
    If E^.DAt.Active Then
    If Not TestElement(E^.Dat.Agentkod+'│',Agent1) Then
    If E^.DAt.OperatorSelector in [0,2] Then
     If ((E^.Dat.Realiz) And (E^.Dat.DocSelector in [5,6,7,8])) Or
       (Not(E^.Dat.Realiz) And (E^.DAt.DocSelector in [0,1,2,3,4])) Then
      {накладная подходит под классификацию}
      Begin
       Index := GetNaklIndex(E);

       Inc(Count);
       Str(StrToReal(E^.Dat.SummaZakupka)+StrToReal(RR^.Dat.Res[Index].Zakupka):CIZena:CMantissa,
	  RR^.Dat.Res[Index].Zakupka);

       Str(StrToReal(E^.Dat.SummaZ){-StrToReal(E^.Dat.ENalog)}:
	  CIZena:CMantissa,E^.Dat.SummaZ);


       Str(StrToReal(E^.Dat.SummaZ)+StrToReal(RR^.Dat.Res[Index].Oplata):
	  CIZena:CMantissa,RR^.Dat.Res[Index].Oplata);


       Str(StrToReal(E^.Dat.Skidka)+StrToReal(RR^.Dat.Res[Index].Skidka):
	  CIZena:CMantissa,RR^.Dat.Res[Index].Skidka);

       {добавляем клиента в список}
       If TestElement(E^.Dat.ClientKod,ClientList[Index]) Then
        Begin
         ClientList[Index]^.List^.Insert(NewStr('│'+E^.Dat.ClientKod));
         ClientList[Index]^.SetRange(ClientList[Index]^.List^.Count);
        End

      End;{TestElement для агентов}

   End;{While}
  Dispose(E,Done);
  l:=IoResult;
  Close(f);
  l:=IoResult;
  End;{l=0}
 End;{For}

For cur:=1 To 8 Do
 Begin
  RR^.Dat.Res[Cur].Client:=ClientList[Cur]^.List^.Count;
 End;



Writeln(txt,Space+'Склад: '+FormKod(Rek.Kod)+'  Оператор: '+CurrentPassword);

If (Agent1^.List^.Count)>=1 Then
Begin
 Writeln(txt);
 Writeln(txt,'Выбранные агенты:');
For Index:=0 To Agent1^.List^.Count-1 Do
Begin
s:=Agent1^.GetText(Index,Agent1^.List^.Count);
s:=Copy(s,1+1,CClientKod);
Writeln(txt,GetAgentField(FClient,s)+' ('+s+')');
End;
End;

Writeln(txt);
Writeln(txt,Space+'{по отгрузке}');
Writeln(txt,Space+'   АНАЛИЗ  ЦЕНОВОЙ  ПОЛИТИКИ  за период с '+StartDate+' по '+StopDAte);
Writeln(txt,Space+'----------------------------------------------------------------------');
Writeln(txt,Space+'N Колонка Сумма к оплате  Сумма по закуп. Доход      Доход      Клиент');
Writeln(txt,Space+'                руб             руб         %     Сумма, руб          ');
Writeln(txt,Space+'----------------------------------------------------------------------');

 AllClient:=0;
 AllZakupka:=0;
 AllOplata :=0;
 AllDohod :=0;
 AllDohodProz:=0;
 Index:=0;

For cur:=1 To 7 Do
Begin
 If Not(cur in [1,8]) Then
 Write(txt,Space,cur-1:1,' ')
 Else Write(txt,Space,'  ');

 If cur in [2..7] Then Format(Find.Graniza[Cur],CLitr+1);
 Case cur Of
{
 0:Write(txt,'Наценка ');}
 1:Write(txt,'>'+Find.Graniza[Cur+1]+' ');
 2:Write(txt,'<'+Find.Graniza[Cur]+' ');
 3:Write(txt,'<'+Find.Graniza[Cur]+' ');
 4:Write(txt,'<'+Find.Graniza[Cur]+' ');
 5:Write(txt,'<'+Find.Graniza[Cur]+' ');
 6:Write(txt,'<'+Find.Graniza[Cur]+' ');
 7:Write(txt,'<'+Find.Graniza[Cur]+' ');
 8:Write(txt,'<'+Find.Graniza[Cur-1]+' ');
 Else;
 End;
 Str(StrToReal(RR^.Dat.Res[cur].Oplata):CIZena:CMantissa,RR^.Dat.Res[cur].Oplata);
 Str(StrToReal(RR^.Dat.Res[cur].Zakupka):CIZena:CMantissa,RR^.Dat.Res[cur].Zakupka);

 Write(txt,RR^.Dat.Res[cur].Oplata+' '+RR^.Dat.Res[cur].Zakupka+' ');
 If StrToReal(RR^.Dat.Res[Cur].Zakupka)>0.009 Then
  Begin
   Str((StrToReal(RR^.Dat.Res[Cur].Oplata)-StrToReal(RR^.Dat.Res[Cur].Zakupka))/
               StrToReal(RR^.Dat.Res[Cur].Zakupka)*100:CLitr:CMantissa,DohodProz);

  End
 Else
  If StrToReal(RR^.Dat.Res[cur].Oplata)>0.009 Then DohodProz:='100.0'
  Else DohodProz:=' 0.00';

 Str(StrToReal(RR^.Dat.Res[Cur].Oplata)-StrToReal(RR^.Dat.Res[Cur].Zakupka)
     :CIZena:CMAntissa,Dohod);
 WriteLn(txt,DohodProz+' '+Dohod+' ',RR^.Dat.Res[Cur].Client:CKol);
 AllClient:=AllClient+RR^.Dat.Res[Cur].Client;
 AllZakupka:=AlLZakupka+StrToReal(RR^.Dat.Res[cur].Zakupka);
 AllOplata :=AllOplata+StrToReal(RR^.Dat.Res[cur].Oplata);
 AllDohod :=AllDohod+StrToReal(Dohod);
 AllDohodProz:=AllDohodProz+StrToReal(DohodProz);
 If DohodProz<>' 0.00' Then Inc(Index);
End;
Writeln(txt,Space+'----------------------------------------------------------------------');
Writeln(txt,Space+'          Всего           Всего                  Всего          Всего');

If Index<>0 Then
Writeln(txt,Space,'          ',AllOplata:CIZena:CMantissa,' ',AllZakupka:CIZena:CMantissa,
' ',(AllOplata-AllZakupka)/AllZakupka*100:CLitr:CMantissa,' ',AllDohod:CIZena:CMantissa,' ',AllClient:CKol)
Else
Writeln(txt,Space,'          ',AllOplata:CIZena:CMantissa,' ',AllZakupka:CIZena:CMantissa,
' ','     '{' ??.??',' ',AllDohod:CIZena:CMantissa},' ',AllClient:CKol);

Writeln(txt,Space);
{Writeln(txt,Space,Count:5);}
  l:=IoResult;
                  {1│123456789012345 12345│123456789012345│12345}
Dispose(RR,Done);






{уничтожаем списоки клиентов}
For cur:=1 to 8 Do Dispose(ClientList[cur],Done);


R.Assign(0,0,0,0);
For cur:=1 to 8 Do
 Begin
  ClientList[cur] := New(PBox, Init(R, 1, Nil));
  ClientList[cur]^.NewList(New(PTextCollection, Init(1,1)));
 End;


New(RR,init);
For cur:=Start to Stop Do
 Begin
  s:=DateToDateString(DateMask,Cur);
  Assign(f,Path.ToMarket+s+'.mrk');
  l:=IoResult;
  Reset(f);
  l:=IoResult;
  If l=0 Then
  Begin
  New(E,Init);
  While Not(eof(f)) Do
   Begin
    ReadMarket(f,E);
    If E^.DAt.Active Then
    If Not TestElement(E^.Dat.Agentkod+'│',Agent1) Then
    If E^.DAt.OperatorSelector in [0,2] Then
     If ((E^.Dat.DocSelector in [0,1,2,3,4])) Then
      {накладная подходит под классификацию}
      Begin
       Index := GetNaklIndex(E);

       Str(StrToReal(E^.Dat.SummaZakupka)+StrToReal(RR^.Dat.Res[Index].Zakupka):CIZena:CMantissa,
	  RR^.Dat.Res[Index].Zakupka);

       Str(StrToReal(E^.Dat.SummaZ){-StrToReal(E^.Dat.ENalog)}:
	  CIZena:CMantissa,E^.Dat.SummaZ);


       Str(StrToReal(E^.Dat.SummaZ)+StrToReal(RR^.Dat.Res[Index].Oplata):
	  CIZena:CMantissa,RR^.Dat.Res[Index].Oplata);


       Str(StrToReal(E^.Dat.Skidka)+StrToReal(RR^.Dat.Res[Index].Skidka):
	  CIZena:CMantissa,RR^.Dat.Res[Index].Skidka);

       {добавляем клиента в список}
       If TestElement(E^.Dat.ClientKod,ClientList[Index]) Then
        Begin
         ClientList[Index]^.List^.Insert(NewStr('│'+E^.Dat.ClientKod));
         ClientList[Index]^.SetRange(ClientList[Index]^.List^.Count);
        End

      End;{TestElement для агентов}

   End;{While}
  Dispose(E,Done);
  l:=IoResult;
  Close(f);
  l:=IoResult;
  End;{l=0}
 End;{For}

For cur:=1 To 8 Do
 Begin
  RR^.Dat.Res[Cur].Client:=ClientList[Cur]^.List^.Count;
 End;


Writeln(txt);
Writeln(txt,Space+'{по оплате}');
Writeln(txt,Space+'   АНАЛИЗ  ЦЕНОВОЙ  ПОЛИТИКИ  за период с '+StartDate+' по '+StopDAte);
Writeln(txt,Space+'----------------------------------------------------------------------');
Writeln(txt,Space+'N Колонка Сумма к оплате  Сумма по закуп. Доход      Доход      Клиент');
Writeln(txt,Space+'                руб             руб         %     Сумма, руб          ');
Writeln(txt,Space+'----------------------------------------------------------------------');

 AllClient:=0;
 AllZakupka:=0;
 AllOplata :=0;
 AllDohod :=0;
 AllDohodProz:=0;
 Index:=0;

For cur:=1 To 7 Do
Begin
 If Not(cur in [1,8]) Then
 Write(txt,Space,cur-1:1,' ')
 Else Write(txt,Space,'  ');

 If cur in [2..7] Then Format(Find.Graniza[Cur],CLitr+1);
 Case cur Of
{
 0:Write(txt,'Наценка ');}
 1:Write(txt,'>'+Find.Graniza[Cur+1]+' ');
 2:Write(txt,'<'+Find.Graniza[Cur]+' ');
 3:Write(txt,'<'+Find.Graniza[Cur]+' ');
 4:Write(txt,'<'+Find.Graniza[Cur]+' ');
 5:Write(txt,'<'+Find.Graniza[Cur]+' ');
 6:Write(txt,'<'+Find.Graniza[Cur]+' ');
 7:Write(txt,'<'+Find.Graniza[Cur]+' ');
 8:Write(txt,'<'+Find.Graniza[Cur-1]+' ');
 Else;
 End;
 Str(StrToReal(RR^.Dat.Res[cur].Oplata):CIZena:CMantissa,RR^.Dat.Res[cur].Oplata);
 Str(StrToReal(RR^.Dat.Res[cur].Zakupka):CIZena:CMantissa,RR^.Dat.Res[cur].Zakupka);

 Write(txt,RR^.Dat.Res[cur].Oplata+' '+RR^.Dat.Res[cur].Zakupka+' ');
 If StrToReal(RR^.Dat.Res[Cur].Zakupka)>0.009 Then
  Begin
   Str((StrToReal(RR^.Dat.Res[Cur].Oplata)-StrToReal(RR^.Dat.Res[Cur].Zakupka))/
               StrToReal(RR^.Dat.Res[Cur].Zakupka)*100:CLitr:CMantissa,DohodProz);

  End
 Else
  If StrToReal(RR^.Dat.Res[cur].Oplata)>0.009 Then DohodProz:='100.0'
  Else DohodProz:=' 0.00';

 Str(StrToReal(RR^.Dat.Res[Cur].Oplata)-StrToReal(RR^.Dat.Res[Cur].Zakupka)
     :CIZena:CMAntissa,Dohod);
 WriteLn(txt,DohodProz+' '+Dohod+' ',RR^.Dat.Res[Cur].Client:CKol);
 AllClient:=AllClient+RR^.Dat.Res[Cur].Client;
 AllZakupka:=AlLZakupka+StrToReal(RR^.Dat.Res[cur].Zakupka);
 AllOplata :=AllOplata+StrToReal(RR^.Dat.Res[cur].Oplata);
 AllDohod :=AllDohod+StrToReal(Dohod);
 AllDohodProz:=AllDohodProz+StrToReal(DohodProz);
 If DohodProz<>' 0.00' Then Inc(Index);
End;

Writeln(txt,Space+'----------------------------------------------------------------------');
Writeln(txt,Space+'          Всего           Всего                  Всего          Всего');

If Index<>0 Then
Writeln(txt,Space,'          ',AllOplata:CIZena:CMantissa,' ',AllZakupka:CIZena:CMantissa,
' ',(AllOplata-AllZakupka)/AllZakupka*100:CLitr:CMantissa,' ',AllDohod:CIZena:CMantissa,' ',AllClient:CKol)
Else
Writeln(txt,Space,'          ',AllOplata:CIZena:CMantissa,' ',AllZakupka:CIZena:CMantissa,
' ','     '{' ??.??',' ',AllDohod:CIZena:CMantissa},' ',AllClient:CKol);

Writeln(txt,Space);
Writeln(Txt,Space+'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
Writeln(txt,Space+'======================================================================');
                  {1│123456789012345 12345│123456789012345│12345}
  l:=IoResult;
Close(txt);
  l:=IoResult;
Dispose(RR,Done);

{уничтожаем список агентов}
Dispose(Agent1,Done);
{уничтожаем списоки клиентов}
For cur:=1 to 8 Do Dispose(ClientList[cur],Done);

ViewAsText(Path.ToTemp+'polskid.txt',True);


End;


Procedure FormReportKassa;
Var f,f1 : Text;
    i : Word;
    Fk : File Of KassaType;
    Fk1 : File Of HiddenKassaType;
    Tag,c,l,l1,l2 : LongInt;
    Ext,s : String;
    EOst,EConsig,Epereozen,EBarter,EBarterl,ESoSklada,EPrihod,EDohod,ERP,ERashod,ESdano:Real;
    Evzz,Evza,EOstL,EConsigL,EpereozenL,ESoSkladaL,EPrihodL,EDohodL,ERPL,ERashodL,ESdanoL,
    EDolgL,EProsroshenieDolgiL,EProsrosheniePlategiL,EPlategiL,ERewiziaL,
    EDolg,EProsroshenieDolgi,EDohodOtg,EDohodOtgL,EMinusDohodOtg,
    EMinusDohodOtgL,EProsrosheniePlategi,EPlategi,ERewizia,
    EVidanoL,EVidanoLBn,EVidanoLN,EVidanoBN,EVidanoN,EVidano:Real;
    All,AllN,AllBn : Real;
    K : PKassaType;
    K1 : PHiddenKassaType;
    Start,Stop : TDAteString;
Begin
    EOst:=0;
 ESoSklada:=0;
   EPrihod:=0;
   EConsig:=0;
 Epereozen:=0;
    EDohod:=0;
    ESdano:=0;
    EDolg:=0;
    EProsroshenieDolgi:=0;
    EProsrosheniePlategi:=0;
    EPlategi:=0;
    ERewizia:=0;
    EDohodOtg:=0;
    EMinusDohodOtg:=0;
    EVidanoBN:=0;
    EVidanoN:=0;
    EVidano:=0;

 If Not DatePeriodDialog(Start,Stop,False) Then Exit;

 Assign(f,Path.ToTemp+'stati.txt');
 i:=IOResult;
 Rewrite(f);
 i:=IOResult;
 If I<>0 Then
  Begin
   MessageBox(^M+#3+'Не могу создать '+Path.ToTemp+'stati.txt',Nil,mfError+mfCancelButton);
   Exit;
  End;

 Assign(f1,Path.ToTemp+'er.txt');
 i:=IOResult;
 Rewrite(f1);
 i:=IOResult;
 If I<>0 Then
  Begin
   Close(f);
   MessageBox(^M+#3+'Не могу создать '+Path.ToTemp+'er.txt',Nil,mfError+mfCancelButton);
   Exit;
  End;

 Writeln(f,'             Статистика за период с '+Start+' по '+Stop);
 WriteLn(f);

Writeln(f,'------------------------------------------------------------------------------------------------------------------'+
'-------------------------------------------------------------------------------------');
Writeln(f,'Дата     Сумма в кас.Прих.на скл Ост.на скл. Выд. на кон.Переоценка  Доход.опл.  Доход.отгр. Упущ.дох.  Остаток Ко'+
'н Просрочено  Поставщики  Просрочено  Выдано пост Выдано Нал. Выдано Б/Н  Ревизия З/Ц');
Writeln(f,'------------------------------------------------------------------------------------------------------------------'+
'-------------------------------------------------------------------------------------');
{
Writeln(f,'--------------------------------------------------------------------------------');
Writeln(f,'Дата     Сумма в кас.Прих.на скл Ост.на скл. Выд. на кон.Остаток К Просроч К  Отсток
долга пост Отсток просроч долг пост Переоценка  Доходность ');
Writeln(f,'--------------------------------------------------------------------------------');
}

 New(K,Init);
 New(K1,Init);
 l1:=DateStringToDate(DateMask,Start);
 l2:=DateStringToDate(DateMask,Stop);
 Tag:=0;
 For l:=l1 To l2 Do
  Begin
  If Not(DayOfWeek(L) in [Sunday]) Then
Begin
    EOstL:=0;
 ESoSkladaL:=0;
   EPrihodL:=0;
   EConsigL:=0;
 EpereozenL:=0;
    EDohodL:=0;
    ESdanoL:=0;
    EDolgL:=0;
    EProsroshenieDolgiL:=0;
    EProsrosheniePlategiL:=0;
    EPlategiL:=0;
    ERewiziaL:=0;
    EDohodOtgL:=0;
    EMinusDohodOtgL:=0;
    EVidanoLBN:=0;
    EVidanoLN:=0;
    EVidanoL:=0;
    All:=0;
    AllN:=0;
    AllBn:=0;

   s:=DateToDateString(DateMask,l);
   {Вставит код формирования статистики}
   Inc(Tag);
   c:=StrToInt(Rek.Kod);
     Ext:=IntToStr(c,4);
     Insert('.k0',Ext,1);
     i:=IOResult;
     Assign(fk,Path.ToArchiv+s+Ext);
     Reset(fk);
     i:=IOResult;
     If i<>0 Then Writeln(f1,'Ошибка доступа к файлу '+Path.ToArchiv+s+Ext+' за '+S)
     Else
      Begin
       Read(fk,K^.Dat);
       i:=IOResult;
       If i<>0 Then Writeln(f1,'Ошибка чтения файла '+Path.ToArchiv+s+Ext+' за '+S);

       Close(Fk);
       i:=IOResult;

    EOstL:=EOstL+StrToReal(K^.Dat.Ostatok);
ESoSkladaL:=ESoSkladaL+StrToReal(K^.Dat.SummaOutSklad);
  EPrihodL:=EPrihodL+StrToReal(K^.Dat.Prihod)+StrToReal(K^.DAt.BarterPrihodRZ);
   EConsigL:=EConsigL+StrToReal(K^.Dat.VidanoConsig);
 EpereozenL:=EpereozenL+StrToReal(K^.Dat.Pereozenka)+StrToReal(K^.Dat.PereozenkafromReturn);
    EDohodL:=EDohodL+StrToReal(K^.Dat.VidanoSF);{по оплате}
    ESdanoL:=ESdanoL+StrToReal(K^.Dat.Sdano);

       CalcOplBArter(s,All,AllN,AllBN);


      End;

     Ext:=IntToStr(c,4);
     Insert('.h0',Ext,1);
     i:=IOResult;
     Assign(fk1,Path.ToArchiv+s+Ext);
     Reset(fk1);
     i:=IOResult;
     If i<>0 Then Writeln(f1,'Ошибка доступа к файлу '+Path.ToArchiv+s+Ext+' за '+S)
     Else
      Begin
       Read(fk1,K1^.Dat);
       i:=IOResult;
       If i<>0 Then Writeln(f1,'Ошибка чтения файла '+Path.ToArchiv+s+Ext+' за '+S);

       Close(Fk1);
       i:=IOResult;
    EDolgL:=EDolgL+StrToReal(K1^.Dat.DolgiVse);
EProsroshenieDolgiL:=EProsroshenieDolgiL+StrToReal(K1^.Dat.DolgiIstekshie);
  EProsrosheniePlategiL:=EProsrosheniePlategiL+StrToReal(K1^.Dat.PlategiVse);
  EPlategiL:=EPlategiL+StrToReal(K1^.Dat.PlategiIstekshie);
   ERewiziaL:=ERewiziaL+StrToReal(K1^.Dat.RewisiaZ);
   EDohodOtgL :=EDohodOtgL+StrToReal(K1^.Dat.AllDohod)+StrToReal(K1^.Dat.AllDohodA);
   EMinusDohodOtgL :=EMinusDohodOtgL+StrToReal(K1^.Dat.MinusDohod);

      End;







    s:=s+'│'+RealToStr(ESdanoL,11,CMantissa)+'│'+RealToStr(EPrihodL,11
    ,CMantissa)+'│'+
    +RealToStr(EOstL,11,CMantissa)+'│'+RealToStr(EConsigL,11,CMantissa)+'│'+
    +RealToStr(EPereozenL,11,CMantissa)+'│'+RealToStr(EDohodl,11,CMantissa)+'│'+
    +RealToStr(EDohodOtgl,11,CMantissa)+'│'+RealToStr(EMinusDohodOtgl,11,CMantissa)+'│'+

    +RealToStr(EDolgL,11,CMAntissa)+'│'+RealToStr(EProsroshenieDolgiL,11,CMAntissa)+'│'+
    +RealToStr(EProsrosheniePlategiL,11,CMAntissa)+'│'+RealToStr(EPlategiL,11,CMantissa)+'│'+
    +RealToStr(All,11,CMAntissa)+'│'+RealToStr(AllN,11,CMAntissa)+'│'+RealToStr(AllBN,11,CMAntissa)+'│'+
    +RealToStr(ERewiziaL,11,CMantissa);
     Writeln(f,s);
   i:=IOResult;

 ESoSklada:=ESoSklada+ESoSkladaL;
   EPrihod:=EPrihod+EPrihodL;
    EDohod:=EDohod+EDohodL;
    ESdano:=ESdano+ESdanoL;
    EOst:=EOst+EOstL;
   EConsig:=EConsig+EConsigL;
 Epereozen:=Epereozen+EPereozenL;
    EDolg:=EDolg+EDolgL;
EProsroshenieDolgi:=EProsroshenieDolgi+EProsroshenieDolgiL;
  EProsrosheniePlategi:=EProsrosheniePlategi+EProsrosheniePlategiL;
  EPlategi:=EPlategi+EPlategiL;
   ERewizia:=ERewizia+ERewiziaL;
   EDohodOtg :=EDohodOtg+EDohodOtgL;
   EMinusDohodOtg :=EMinusDohodOtg+EMinusDohodOtgL;

    EVidanoBN:=EVidanoBN+AllBn;
    EVidanoN:=EVidanoN+AllN;
    EVidano:=EVidano+All;


End;{Sunday}
  End;{for по датам}
 Dispose(K,Done);
 Dispose(K1,Done);

Writeln(f,'------------------------------------------------------------------------------------------------------------------'+
'-------------------------------------------------------------------------------------');
 s:='   Всего '+RealToStr(ESdano,11,CMantissa)+' '+RealToStr(EPrihod,11
    ,CMantissa)+' '+RealToStr(EOst,11,CMantissa)+' '+RealToStr(EConsig,11,CMantissa)+' '+
    +RealToStr(EPereozen,11,CMantissa)+' '+RealToStr(EDohod,11,CMantissa)+' '+RealToStr(EDohodOtg,11,CMantissa)+
    +' '+RealToStr(EMinusDohodOtg,11,CMantissa)+' '+RealToStr(EDolg,11,CMantissa)
    +' '+RealToStr(EProsroshenieDolgi,11,CMantissa)+' '+RealToStr(EProsrosheniePlategi,11,CMantissa)
    +' '+RealToStr(EPlategi,11,CMantissa)+' '+RealToStr(EVidano,11,CMantissa)+
    +' '+RealToStr(EVidanoN,11,CMantissa)+' '+RealToStr(EVidanoBN,11,CMantissa)
    +' '+RealToStr(ERewizia,11,CMantissa);

 Writeln(f,s);
 Writeln(f);

 Writeln(f,'           Рабочих дней: ',(Tag):CKol);
If Tag>0 Then
Begin
 Writeln(f,'           В среднем сдано    : ',ESdano/(Tag):CIZena+2:CMantissa);

 Writeln(f,'          В среднем приход    : ',EPrihod/(Tag):CIZena+2:CMantissa);

 Writeln(f,'В среднем остаток на складе   : ',EOst/(Tag):CIZena+2:CMantissa);

 Writeln(f,'В среднем выдано на консигнац.: ',EConsig/(Tag):CIZena+2:CMantissa);

 Writeln(f,'      В среднем переоценка    : ',EPereozen/(Tag):CIZena+2:CMantissa);

 Writeln(f,'    В среднем доход оплата    : ',EDohod/(Tag):CIZena+2:CMantissa);

 Writeln(f,'  В среднем доход отгрузка    : ',EDohodOtg/(Tag):CIZena+2:CMantissa);

 Writeln(f,'В среднем упущенный доход отгр: ',EMinusDohodOtg/(Tag):CIZena+2:CMantissa);

 Writeln(f,'         В среднем ревизия    : ',ERewizia/(Tag):CIZena+2:CMantissa);

 Writeln(f,'   В среднем оплата поставщику: ',EVidano/(Tag):CIZena+2:CMantissa);

 Writeln(f,' В среднем оплата поставщику Н: ',EVidanoN/(Tag):CIZena+2:CMantissa);

 Writeln(f,'В среднем оплата поставщику БН: ',EVidanoBN/(Tag):CIZena+2:CMantissa);
End;

 Writeln(f);
 Writeln(f,'[Примечание:]');
 Close(f1);

 Assign(f1,Path.ToTemp+'er.txt');
 i:=IOResult;
 Reset(f1);
 i:=IOResult;
 While Not (Eof(f1)) Do
  Begin
 i:=IOResult;
   Readln(f1,s);
 i:=IOResult;
   Writeln(f,s);
  End;
 Close(f1);
 i:=IOResult;

 Writeln(f);

 Writeln(f,' Отпечатано:"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
 Close(f);

 ViewAsText(Path.ToTemp+'stati.txt',True);
End;




Begin
Find.Graniza[2]:='1.0000';
Find.Graniza[3]:='1.0000';
Find.Graniza[4]:='1.0000';
Find.Graniza[5]:='1.0000';
Find.Graniza[6]:='1.0000';
Find.Graniza[7]:='1.0000';
End.

