{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}

Unit Printers;

Interface

Uses Glob, Dos, Objects,App, Drivers, Memory,
     Views, Menus, Dialogs,ColorTxt,Serv,InpLong,
     Validate,WinDos,ServStr;

{
Const Bold : Array [0..1] Of AllStr=(#27#69,#27#40#115#52#66);
      NoBold: Array [0..1] Of AllStr=(#27#70,#27#40#115#48#66);
      Double: Array [0..1] Of AllStr=(#27#71,'');
      NoDouble: Array [0..1] Of AllStr=(#27#72,'');
      Pitch : Array [0..1] Of AllStr=(#27#33#129,#27#38#100#48#68);
      NoPitch : Array [0..1] Of AllStr=(#27#33#65#27#53,#27#38#100#66);
      Condensed: Array [0..1] Of AllStr=(#27#15,#027#040#115+'20'+#072);
      NoCondensed: Array [0..1] Of AllStr=(#27#18,#27#38#107#52#83);
      High : Array [0..1] Of AllStr=(#14,#027#040#115+'8'+#072+#27#40#115#52#66);
      NoHigh: Array [0..1] Of AllStr=('',#27#38#107#52#83+#27#40#115#48#66);

      Italic: Array [0..1] Of AllStr=(#27#33#65,#027#040#115#049#083);
      NoItalic: Array [0..1] Of AllStr=(#27#33#1,#027#040#115#054#052#083);
}
{HP взяты из PRNFLTR.PAS}
(*
Const Bold : Array [0..1] Of AllStr=(#27#69,#27#40#115#51#66);
      NoBold: Array [0..1] Of AllStr=(#27#70,#27#40#115#48#66);
      Double: Array [0..1] Of AllStr=(#27#71,'');
      NoDouble: Array [0..1] Of AllStr=(#27#72,'');
      Pitch : Array [0..1] Of AllStr=(#27#33#129,#27#38#100#48#68);
      NoPitch : Array [0..1] Of AllStr=(#27#33#65#27#53,#27#38#100#66);
      Condensed: Array [0..1] Of AllStr=(#27#15,#027#040#115+'20'+#072);
      NoCondensed: Array [0..1] Of AllStr=(#27#18,#27#38#107#52#83);
      High : Array [0..1] Of AllStr=(#14,#027#040#115+'8'+#072+#27#40#115#52#66);
      NoHigh: Array [0..1] Of AllStr=('',#27#38#107#52#83+#27#40#115#48#66);

      Italic: Array [0..1] Of   AllStr=(#27#33#65,#027#040#115#049#083);
      NoItalic: Array [0..1] Of AllStr=(#27#33#1 ,#027#040#115#048#083);
      MaxLine:Array [0..1] Of word=(10000,65);
      EndPage : Array[0..1] Of AllStr=(#10#10#10,#12);
*)
Const Bold : Array [0..3] Of AllStr=(#27#69,#27#69,#27#40#115#51#66,'');
      NoBold: Array [0..3] Of AllStr=(#27#70,#27#70,#27#40#115#48#66,'');
      Double: Array [0..3] Of AllStr=(#27#71,#27#71,'','');
      NoDouble: Array [0..3] Of AllStr=(#27#72,#27#72,'','');
      Pitch : Array [0..3] Of AllStr=(#27#33#129,#27#33#129,#27#38#100#48#68,'');
      NoPitch : Array [0..3] Of AllStr=(#27#33#65#27#53,#27#33#65#27#53,#27#38#100#66,'');
      Condensed: Array [0..3] Of AllStr=(#27#15,#27#15,#027#040#115+'20'+#072,'');
      Condensed2: Array [0..3] Of AllStr=(#27#15,#27#15,#027#040#115+'18'+#072,'');
      NoCondensed: Array [0..3] Of AllStr=(#27#18,#27#18,#27#38#107#52#83,'');
      High : Array [0..3] Of AllStr=(#14,#14,#027#040#115+'8'+#072+#27#40#115#52#66,'');
      NoHigh: Array [0..3] Of AllStr=('','',#27#38#107#52#83+#27#40#115#48#66,'');
      MinInterval2 : Array[0..3] of AllStr=('','',#27+#38+#108+#49+#50+#68,'');
      Normal       : Array[0..3] of AllStr=('!RCI3!','!RCI3!',#27+#38+#108+#55+#67,'');

      Italic: Array [0..3] Of   AllStr=(#27#33#65,#27#33#65,#027#040#115#049#083,'');
      NoItalic: Array [0..3] Of AllStr=(#27#33#1,#27#33#1,#027#040#115#048#083,'');
      MaxLine:Array [0..3] Of word=(65,10000,65,65);
      EndPage : Array [0..3] Of AllStr=(#12,#10#10#10#10#10,#12,#12);





Procedure Report(Obj1,Obj2 : TEnjoyStr;Copy : LongInt;Nakl:Boolean;Kassa:Boolean;oneCopy:boolean);
{Procedure Config;}
Procedure ConfigDistantion;
Procedure PrintConfig;
Function GetCopy(Copy:LongInt; Var L : Boolean): LongInt;

Implementation

Uses TpDate,MsgbOX,Gadgets,SwDos,Utils;
Const
      Nul=' >NUL ';

Function CalcLengthDoc(ss: TEnjoyStr;Var Max : LongInt) : LongInt;
Var f,f1 : Text;
    l : LongInt;
    s : string[150];
Begin
 Max:=0;
 Assign(f,ss);
 Reset(f);
 L:=0;
 S[0]:=#0;
 While Not(Eof(f))And(Pos('=',S)=0) Do
 Begin
 Readln(f,s);
 Inc(L);
 If Ord(s[0])>Max Then Max:=Ord(s[0]);
 End;
 Close(f);
 CalcLengthDoc:=L;
End;

(*
Procedure MakeCopy(obj1:TMyString;Var s:String);
Var f,f1:Text;
    i : LongInt;
    s1 : string[150];
Begin
 Assign(f,Obj1);
 i:=IOResult;
 Reset(f);
 i:=IOResult;
 If i<>0 Then Exit;
 Unique(Path.ToTemp,s);
 Assign(f1,s);
 i:=IOResult;
 Rewrite(f1);
 i:=IOResult;
 If i<>0 Then exit;
 While Not(eof(f)) Do
  Begin
   Readln(f,s1);
   Writeln(f1,s1);
  End;
 i:=IOResult;
 Close(f1);
 i:=IOResult;
 Close(f);
 i:=IOResult;
End;
*)

Function MakeCopy(obj1:TEnjoyStr;Var s:TEnjoyStr):Boolean;
Var f,f1:Text;
    i : LongInt;
    s1 : string[150];
Begin
 MakeCopy:=False;
 Assign(f,Obj1);
 i:=IOResult;
 Reset(f);
 i:=IOResult;
 If i<>0 Then
  Begin
   MessageBox(^M+#3'Ошибка открытия '+Obj1+'!'^M+
   ClicProgrammer+' (Код:'+IntToStr(i,2)+')',Nil,mfError+mfCancelButton);
   Exit;
  End;

 Repeat

 DosError:=0;
 i:=IOResult;
 Utils.AssignTemp(f1,Path.ToTemp);

 Until {(DosError=0) And} (IOResult=0);


 {Unique(Path.ToTemp,s);}
 {Assign(f1,s); связывание больше не нужно}
 i:=IOResult;
 Append{Rewrite}(f1);
 i:=IOResult;
If i<>0 Then
  Begin
   MessageBox(^M+#3'Ошибка открытия '+s+'!'^M+
   ClicProgrammer+' (Код:'+IntToStr(i,2)+')',Nil,mfError+mfCancelButton);
   i:=IOResult;
   Close(f);
   i:=IOResult;
   Exit;
  End;

 While Not(eof(f)) Do
  Begin
   Readln(f,s1);
   Writeln(f1,s1);
   i:=IOResult;
  End;
 i:=IOResult;
 Close(f1);
 i:=IOResult;
 Close(f);
 i:=IOResult;
 MakeCopy:=True;
 s:=GetFileName(f1);

End;



Function DeleteTempFile(s:String):Boolean;
Var f:File;
    i : LongInt;
Begin
 Assign(f,s);
 i:=IOResult;
 Erase(f);
 i:=IOResult;
End;

(*
Procedure ScanFile(ss,ssc: TEnjoyStr;C:LongInt;NAkl:Boolean;Kassa:Boolean);
Var f,f1,FF : Text;
    DocPos,DocLength,j,CurPage,StringLenght,PageLength,l : LongInt;
    s : string[150];
    Writef,Log : Boolean;
    i,jk,k : Byte;
Begin
 Assign(f1,Path.ToTemp+'temp.$$$');
 Rewrite(f1);
 PageLength:=CalcLengthDoc(ss,StringLenght);
 CurPage:=0;
 WriteLn(F1,NPrint.Ini);
 If PageLength>=MaxLine[NPrint.Printer] Then Log:=True
 Else Log:=False;

 If Nakl Then k:=C{+1}
 Else K:=C;

 For i:=1 To K Do
 Begin
 If (i=c+1)And(Nakl) Then Assign(f,ssc)
 Else Assign(f,ss);
 Reset(f);
 j:=1;
 While Not(Eof(f)) {And (Not (DocPos>DocLength))} Do
  Begin
   Readln(f,s);
   If (j=1) And (i=2) And (Nakl) Then
    Begin
     Format(s,69);
     If Not(KASSA)Then s:=S+Bold[NPrint.Printer]+'<< НА СКЛАД >> '+NoBold[NPrint.Printer]
     Else s:=S+Bold[NPrint.Printer]+'<< В БУХГАЛТЕРИЮ >> '+NoBold[NPrint.Printer];
    End;
   Inc(j);
   If(Pos(' Н А К Л А Д Н А Я ',s)>0)Or(Pos(' Д О К У М Е Н Т ',s)>0)Or(Pos(' АКТ ',s)>0)Or(Pos(' А К Т ',s)>0)Or
   (Pos(' П Р А Й С ',s)>0)Or
   (Pos(Rek.Header,s)>0)Or
   (Pos(' ПРЕДУПРЕЖДЕНИЕ ',s)>0)Or
   (Pos('Накладная ',s)>0)Or
   (Pos(' Н А Л И Ч И Е ',s)>0)Or
   (Pos('ВЕДОМОСТЬ',s)>0) Or
   (Pos(' Т О В А Р Н Ы Й  Ч Е К ',s)>0) Or
   (Pos('Всего',s)>0) Or
   (Pos('Налог с продажи:',s)>0) Or
   (Pos('Раздел:',s)>0){Or(Pos('Склад:',s)>0)} Or
   (Pos(' СПРАВКА ',s)>0) Or
   (Pos(' ПРОТОКОЛ ',s)>0) Or (Pos(' ОТГРУЗКИ ',s)>0) Or (Pos(' С П Р А В К А ',s)>0) Then
    Begin
     Insert(Bold[NPrint.Printer],s,1);
     s:=s+NoBold[NPrint.Printer];
    End;

   If (Pos('{',s)>0) And (Pos('}',s)>0) Then
    Begin
     Insert(Bold[NPrint.Printer],s,Pos('{',s));
     Insert(noBold[NPrint.Printer],s,Pos('}',s)+1);
    End;

   jk:=(Pos('Всего',s));
   If (jk>0)Then
    Begin
     Insert(Double[NPrint.Printer],s,jk);
     s:=s+NoDouble[NPrint.Printer];
    End;
    jk:=(Pos('Налог с продажи:',s));
   If (jk>0)Then
    Begin
     Insert(Double[NPrint.Printer],s,jk);
     s:=s+NoDouble[NPrint.Printer];
    End;
    jk:=(Pos('Раздел: ',s));
   If (jk>0)Then
    Begin
     Insert(Double[NPrint.Printer],s,jk);
     s:=s+NoDouble[NPrint.Printer];
    End;

    jk:=(Pos(' Н А К Л А Д Н А Я ',s));
   If (jk>0)Then
    Begin
     Insert(Double[NPrint.Printer],s,jk);
     s:=s+NoDouble[NPrint.Printer];
    End;
    jk:=(Pos(' Д О К У М Е Н Т ',s));
   If (jk>0)Then
    Begin
     Insert(Double[NPrint.Printer],s,jk);
     s:=s+NoDouble[NPrint.Printer];
    End;
    jk:=(Pos(' Т О В А Р Н Ы Й  Ч Е К ',s));
   If (jk>0)Then
    Begin
     Insert(Double[NPrint.Printer],s,jk);
     s:=s+NoDouble[NPrint.Printer];
    End;
    jk:=(Pos(' С П Р А В К А ',s));
   If (jk>0)Then
    Begin
     Insert(Double[NPrint.Printer],s,jk);
     s:=s+NoDouble[NPrint.Printer];
    End;
    jk:=(Pos(' СПРАВКА ',s));
   If (jk>0)Then
    Begin
     Insert(Double[NPrint.Printer],s,jk);
     s:=s+NoDouble[NPrint.Printer];
    End;
    jk:=(Pos(' ПРОТОКОЛ ',s));
   If (jk>0)Then
    Begin
     Insert(Double[NPrint.Printer],s,jk);
     s:=s+NoDouble[NPrint.Printer];
    End;
    jk:=(Pos(' АКТ ',s));
   If (jk>0)Then
    Begin
     Insert(Double[NPrint.Printer],s,jk);
     s:=s+NoDouble[NPrint.Printer];
    End;
    jk:=(Pos(' А К Т ',s));
   If (jk>0)Then
    Begin
     Insert(Double[NPrint.Printer],s,jk);
     s:=s+NoDouble[NPrint.Printer];
    End;

 If NPrint.Printler=1 Then
 Begin
  s:=MakeLine(s);
 End;

   Writeln(f1,s);
   If (Pos('=',s)>0)And (NPrint.Printer=0) Then
    Begin
     Writeln(f1,EndPage[NPrint.Printer]);
    End;
  End;
{  Writeln(f1,#7);}
 Close(f);
 Writef:=False;
 If Not(Log) Then
 Begin
  CurPage:=CurPage+PageLength;
  If CurPage>=MaxLine[NPrint.Printer] Then
   Begin
    Writef:=True;
    Writeln(f1,EndPage[NPrint.Printer]);
    CurPage:=0;
   End;
  If (CurPage+PageLength)>=MaxLine[NPrint.Printer] Then
   Begin
    Writef:=True;
    Writeln(f1,EndPage[NPrint.Printer]);
    CurPage:=0;
   End;
 End{If Not(Log)}
 Else
  Begin
    Writef:=True;
    Writeln(f1,EndPage[NPrint.Printer]);
  End;
 End;
 If Not(WriteF) Then
 Writeln(f1,EndPage[NPrint.Printer]);
 close(f1);
 If Nakl Then Assign(f,ss);
 Erase(f);
 Rename(f1,ss);
End;
*)


Procedure ScanFile(ss,ssc: TEnjoyStr;C:LongInt;NAkl:Boolean;Kassa:Boolean);
Var f,f1,FF : Text;
    j,CurPage,PageLength,l,StringLenght : LongInt;
    s : string[150];
    Writef,Log : Boolean;
    res,i,jk,k : Byte;
Begin
 Assign(f1,Path.ToTemp+'temp.$$$');
 Rewrite(f1);
 PageLength:=CalcLengthDoc(ss,StringLenght);
 CurPage:=0;
 Writeln(F1,NPrint.Ini);

 If PageLength>=MaxLine[NPrint.Printer] Then Log:=True
 Else Log:=False;

 If Nakl Then k:=C{+1}
 Else K:=C;

 If NPrint.Printer=3 Then k:=1;

 For i:=1 To K Do
 Begin
 If (i=c+1)And(Nakl) Then Assign(f,ssc)
 Else Assign(f,ss);
 Reset(f);
 j:=1;
 While Not(Eof(f)) Do
  Begin
   Readln(f,s);
   If (j=1) And (i=2) And (Nakl) Then
    Begin
     Format(s,69);
     If Not(KASSA)Then s:=S+Bold[NPrint.Printer]+'<< НА СКЛАД >> '+NoBold[NPrint.Printer]
     Else s:=S+Bold[NPrint.Printer]+'<< В БУХГАЛТЕРИЮ >> '+NoBold[NPrint.Printer];
    End;
   Inc(j);
   If(Pos(' Н А К Л А Д Н А Я ',s)>0)Or(Pos(' Д О К У М Е Н Т ',s)>0)Or(Pos(' АКТ ',s)>0)Or(Pos(' А К Т ',s)>0)Or
   (Pos(' П Р А Й С ',s)>0)Or
   (Pos(' ПРЕДУПРЕЖДЕНИЕ ',s)>0)Or
   (Pos('Накладная ',s)>0)Or
   (Pos(' Н А Л И Ч И Е ',s)>0)Or
   (Pos('ВЕДОМОСТЬ',s)>0) Or
   (Pos(' Т О В А Р Н Ы Й  Ч Е К ',s)>0) Or
   (Pos('Всего',s)>0) Or
   (Pos('Налог с продажи:',s)>0) Or
   (Pos('Раздел:',s)>0){Or(Pos('Склад:',s)>0)} Or
   (Pos(' СПРАВКА ',s)>0) Or
   (Pos('РЕЕСТР ',s)>0) Or
   (Pos(' БАЛАНСИРОВКА ',s)>0) Or
   (Pos(' ПРОТОКОЛ ',s)>0) Or (Pos(' ОТГРУЗКИ ',s)>0) Or (Pos(' С П Р А В К А ',s)>0) Then
    Begin
     Insert(Bold[NPrint.Printer],s,1);
     s:=s+NoBold[NPrint.Printer];
    End;
   (* снято выделение '{}'
   If (Pos('{',s)>0) And (Pos('}',s)>0) Then
    Begin
     Insert(Bold[NPrint.Printer],s,Pos('{',s));
     Insert(noBold[NPrint.Printer],s,Pos('}',s)+1);
    End;
   *)
    jk:=(Pos('Всего',s));
   If (jk>0)Then
    Begin
     Insert(Double[NPrint.Printer],s,jk);
     s:=s+NoDouble[NPrint.Printer];
    End;
    jk:=(Pos('Налог с продажи:',s));
   If (jk>0)Then
    Begin
     Insert(Double[NPrint.Printer],s,jk);
     s:=s+NoDouble[NPrint.Printer];
    End;
    jk:=(Pos('Раздел: ',s));
   If (jk>0)Then
    Begin
     Insert(Double[NPrint.Printer],s,jk);
     s:=s+NoDouble[NPrint.Printer];
    End;

    jk:=(Pos(' Н А К Л А Д Н А Я ',s));
   If (jk>0)Then
    Begin
     Insert(Double[NPrint.Printer],s,jk);
     s:=s+NoDouble[NPrint.Printer];
    End;
    jk:=(Pos(' Д О К У М Е Н Т ',s));
   If (jk>0)Then
    Begin
     Insert(Double[NPrint.Printer],s,jk);
     s:=s+NoDouble[NPrint.Printer];
    End;
    jk:=(Pos(' Т О В А Р Н Ы Й  Ч Е К ',s));
   If (jk>0)Then
    Begin
     Insert(Double[NPrint.Printer],s,jk);
     s:=s+NoDouble[NPrint.Printer];
    End;
    jk:=(Pos(' С П Р А В К А ',s));
   If (jk>0)Then
    Begin
     Insert(Double[NPrint.Printer],s,jk);
     s:=s+NoDouble[NPrint.Printer];
    End;
    jk:=(Pos(' СПРАВКА ',s));
   If (jk>0)Then
    Begin
     Insert(Double[NPrint.Printer],s,jk);
     s:=s+NoDouble[NPrint.Printer];
    End;
    jk:=(Pos(' САЛЬДО ',s));
   If (jk>0)Then
    Begin
     Insert(Double[NPrint.Printer],s,jk);
     s:=s+NoDouble[NPrint.Printer];
    End;
    jk:=(Pos(' ПРОТОКОЛ ',s));
   If (jk>0)Then
    Begin
     Insert(Double[NPrint.Printer],s,jk);
     s:=s+NoDouble[NPrint.Printer];
    End;
    jk:=(Pos(' АКТ ',s));
   If (jk>0)Then
    Begin
     Insert(Double[NPrint.Printer],s,jk);
     s:=s+NoDouble[NPrint.Printer];
    End;
    jk:=(Pos(' А К Т ',s));
   If (jk>0)Then
    Begin
     Insert(Double[NPrint.Printer],s,jk);
     s:=s+NoDouble[NPrint.Printer];
    End;

 If NPrint.Printer=1 Then
 Begin
  s:=MakeLine(s);
 End;

   Writeln(f1,s);

   {вставка для рулона из бытовой химии}
   If NPrint.Printer=1 Then
   Begin
   If (Pos('=',s)>0)And (NPrint.Printer in [0,2,3]) Then
    Begin
     if StrToInt(Rek.Kod)<>1 then
     begin
       Writeln(f1);
       Writeln(f1);
       Writeln(f1);
       Writeln(f1);
       Writeln(f1);
     end;
     Writeln(f1,EndPage[NPrint.Printer]);
    End;
   End;
   {конец вставки}

  End;
{  Writeln(f1,#7);}
 Res:=IOResult;
 Close(f);
 Res:=IOResult;
 Writef:=False;
 If Pos(EndPage[NPrint.Printer],s)>0 Then CurPage:=0;
 If Not(Log) Then
 Begin
  CurPage:=CurPage+PageLength;
  If CurPage>=MaxLine[NPrint.Printer] Then
   Begin
    Writef:=True;
    Writeln(f1,EndPage[NPrint.Printer]);
    CurPage:=0;
   End;
  If (CurPage+PageLength)>=MaxLine[NPrint.Printer] Then
   Begin
    Writef:=True;
    Writeln(f1,EndPage[NPrint.Printer]);
    CurPage:=0;
   End;
 End{If Not(Log)}
 Else
  Begin
    Writef:=True;
    Writeln(f1,EndPage[NPrint.Printer]);
  End;
 End;
 If Not(WriteF) Then
 Writeln(f1,EndPage[NPrint.Printer]);
 res:=IOResult;
 close(f1);
 res:=IOResult;
 If Nakl Then Assign(f,ss);
 res:=IOResult;
 Erase(f);
 res:=IOResult;

 reset(f1);
 res:=IOResult;
 Assign(f,ss);
 res:=IOResult;
 rewrite(f);
 res:=IOResult;
 while not eof(f1) do
 begin
   readln(f1,s);
   writeln(f,s);
 end;
 {Rename(f1,ss);}
 res:=IOResult;
 close(f);
 close(f1);
End;



Procedure MakeFontFile(Obj1,Obj2 : TEnjoyStr;Copy :LongInt;Nakl:Boolean;Kassa:Boolean);
Var f : File;
    f1 : Text;
begin
  Begin
   Assign(f1,Path.ToProgram+'print.bln');
   Rewrite(f1);
   Writeln(f1,NPrint.Ini);{#27+#64+#27+'!'+#1+#27+'R'+#15}
   ScanFile(Obj1,Obj2,Copy,Nakl,Kassa);           {отступ 12 колонок}
  {@U0P3%}
   Close(f1);
  End;
End;

Function GetCopy(Copy:LongInt; Var L : Boolean): LongInt;
var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  C:Word;
begin
L := True;
GetCopy:=Copy;
R.Assign(27, 9, 52, 14);
New(Dlg, Init(R, 'Печать'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx:=$E002;
R.Assign(19, 2, 22, 3);
Control := New(PInputLong, Init(R, 1, 1, 9, 0));
Dlg^.Insert(Control);

  R.Assign(1, 2, 19, 3);
  Dlg^.Insert(New(PLabel, Init(R, 'Количество копий:', Control)));

Dlg^.SelectNext(False);
Dlg^.SetData(Copy);
c:=Desktop^.ExecView(Dlg);
If c <> CmCancel Then
                 Begin
                  Dlg^.GetData(Copy);
                  GetCopy:=Copy;
                 End
                 Else L := False;
Dispose(Control,Done);
Dispose(Dlg,Done);
End;



Procedure Report(Obj1,Obj2 : TEnjoyStr;Copy : LongInt;Nakl:Boolean;Kassa:Boolean;oneCopy:boolean);
Var s,s1: string[150];
    i : Byte;
    L : Boolean;
    s2: string[150];
Begin
 l:=true;
 Copy:=1;
 if (CurrentPassword='00') or not OneCopy then
 Copy:=GetCopy(Copy,L);
 If Not(l) Then Exit;
 Case NPrint.Port Of
 0:Begin s:=' lpt1';s1:=' lpt1';End;
 1:Begin s:=' Lpt2';s1:=' lpt2';End;
 2:Begin s:=' Lpt3';s1:=' lpt3';End;
 3:Begin s:=' Lpt4';s1:=' lpt4';End;
 4:Begin s:=' Lpt5';s1:=' lpt5';End;
 Else;
 End;

 If (NPrint.SwapDisk=0){Not(FindParam('/NOSWAP'))} Then
Begin
  DInfoMsg('Записываю temp-файл...');
  Repeat
  Until MakeCopy(obj1,s2);
  NoInfoMsg;



  MakeFontFile(s2{Obj1},Obj2,Copy,Nakl,Kassa);
  AInfo('Идет печать документов...');

  DoneSysError;
  DoneEvents;
  Application^.HideCursor;
  DoneDosMem;
 SWAPVECTORS;

If NPrint.Printer<3 Then
Begin
 If NPrint.Port in [1,2,3,4] Then
 Begin
 Case NPrint.Port Of
{ 0:s1:='lpt1';}
 1:s1:='lpt2';
 2:s1:='lpt3';
 3:s1:='lpt4';
 4:s1:='lpt5';
  Else;
  End;
 {exec (GetEnv('Comspec'),' /c '+' net use '+s1+' '+NPrint.Computer+' /Yes '+NUL);}
  DelSpace(Nprint.Computer);
  If Nprint.Computer[0]<>#0 Then
  exec (GetEnvMy,' /c '+' net use '+s1+' '+Nprint.Computer+' /Yes '+NUL);
 End;

 exec (GetEnv('Comspec'),' /c '+'copy '+s2{Obj1}+' '+s1+' '+Nul);

End
 Else{графическая печать}
  Begin
   exec (GetEnv('Comspec'),' /c '+Path.ToProgram+'winprn.exe /t:'+Obj1+' /c:'+IntToStr(Copy,CMantissa));
  End;

 SWAPVECTORS;
  InitDosMem;
  InitEvents;
  InitSysError;
{ EraseFontFile;}
  NoInfo;


  Application^.Redraw;
  CursorLines:=1543;
  Application^.ShowCursor;

  DInfoMsg('Удаляю temp-файл...');
  DeleteTempFile(s2);

  NoInfoMsg;
End
 Else
Begin


  MakeFontFile(Obj1,Obj2,Copy,Nakl,Kassa);

  AInfo('Идет печать документов...');
  DoneSysError;
  DoneEvents;
  Application^.HideCursor;
  DoneDosMem;
 SWAPVECTORS;

If NPrint.Printer<3 Then
Begin
 If NPrint.Port in [1,2,3,4] Then
 Begin
 Case NPrint.Port Of
{ 0:s1:='lpt1';}
 1:s1:='lpt2';
 2:s1:='lpt3';
 3:s1:='lpt4';
 4:s1:='lpt5';
 {3:s1:='lpt2';}
  Else;
  End;
 {exec (GetEnv('Comspec'),' /c '+' net use '+s1+' '+NPrint.Computer+' /Yes '+NUL);}
  DelSpace(Nprint.Computer);

  If Nprint.Computer[0]<>#0 Then
  exec (GetEnvMy,' /c '+' net use '+s1+' '+Nprint.Computer+' /Yes '+NUL);

 End;
 exec (GetEnv('Comspec'),' /c '+'copy '+Obj1+' '+s1+' '+Nul);
End
 Else{графическая печать}
  Begin
   exec (GetEnv('Comspec'),' /c '+Path.ToProgram+'winprn.exe /t:'+Obj1+' /c:'+IntToStr(Copy,CMantissa));
  End;

 SWAPVECTORS;
  InitDosMem;
  InitEvents;
  InitSysError;
{ EraseFontFile;}
  NoInfo;

  Application^.Redraw;
  CursorLines:=1543;
  Application^.ShowCursor;


End;

End;

(*
Procedure Config;
var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  i: word;
  c : LongInt;
begin
R.Assign(0, 0, 80, 23);
New(Dlg, Init(R, 'Конфигурация системы'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx:=$E002;

R.Assign(2, 3, 18, 5);
Control := New(PRadioButtons, Init(R,
  NewSItem('~Л~азерный',
  NewSItem('~М~атричный', Nil))));
Dlg^.Insert(Control);

  R.Assign(1, 2, 15, 3);
  Dlg^.Insert(New(PLabel, Init(R, 'Тип пpинт~е~ра:', Control)));

R.Assign(29, 3, 45, 5);
Control := New(PRadioButtons, Init(R,
  NewSItem('~К~нижная',
  NewSItem('~А~льбомная', Nil))));
Dlg^.Insert(Control);

  R.Assign(29, 2, 41, 3);
  Dlg^.Insert(New(PLabel, Init(R, 'Ориентация:', Control)));

R.Assign(48, 3, 73, 5);
Control := New(PRadioButtons, Init(R,
  NewSItem('LPT~1~',
  NewSItem('LPT~2~',
  NewSItem('Сеть LPT1',
  NewSItem('Сеть LPT2', Nil))))));
Dlg^.Insert(Control);

  R.Assign(48, 2, 63, 3);
  Dlg^.Insert(New(PLabel, Init(R, 'Порт принтера:', Control)));

R.Assign(7, 6, 39, 7);
Control := New(PInputLine, Init(R, 30));
Dlg^.Insert(Control);

  R.Assign(39, 6, 42, 7);
  Dlg^.Insert(New(PHistory, Init(R, PInputline(Control), 15)));

  R.Assign(7, 5, 29, 6);
  Dlg^.Insert(New(PLabel, Init(R, '~С~етевое имя принтера:', Control)));

R.Assign(44, 6, 76, 7);
Control := New(PSpecialInputLine, Init(R, 30));
Dlg^.Insert(Control);

  R.Assign(43, 5, 74, 6);
  Dlg^.Insert(New(PLabel, Init(R, 'Строка ~и~нициализации принтера:', Control)));

R.Assign(10, 8, 14, 9);
Control := New(PInputLong, Init(R, 2, 1, 9, 0));
Dlg^.Insert(Control);

  R.Assign(2, 8, 10, 9);
  Dlg^.Insert(New(PLabel, Init(R, 'Прих~о~д:', Control)));

R.Assign(26, 8, 30, 9);
Control := New(PInputLong, Init(R, 2, 1, 9, 0));
Dlg^.Insert(Control);

  R.Assign(14, 8, 26, 9);
  Dlg^.Insert(New(PLabel, Init(R, 'П~е~реоценка:', Control)));

R.Assign(41, 8, 45, 9);
Control := New(PInputLong, Init(R, 2, 1, 9, 0));
Dlg^.Insert(Control);

  R.Assign(30, 8, 41, 9);
  Dlg^.Insert(New(PLabel, Init(R, 'Накла~д~ная:', Control)));

R.Assign(52, 8, 56, 9);
Control := New(PInputLong, Init(R, 2,1,9,0));
Dlg^.Insert(Control);

  R.Assign(45, 8, 52, 9);
  Dlg^.Insert(New(PLabel, Init(R, 'Орде~р~:', Control)));

R.Assign(61, 8, 65, 9);
Control := New(PInputLong, Init(R, 2, 1 ,9 ,0));
Dlg^.Insert(Control);

  R.Assign(56, 8, 61, 9);
  Dlg^.Insert(New(PLabel, Init(R, 'С/~Ф~:', Control)));


R.Assign(74, 8, 78, 9);
Control := New(PInputLong, Init(R, 2, 1, 9, 0));
Dlg^.Insert(Control);

  R.Assign(65, 8, 74, 9);
  Dlg^.Insert(New(PLabel, Init(R, 'Возвра~т~:', Control)));

R.Assign(12, 10, 78, 11);
Control := New(PInputLine, Init(R, 64));
Dlg^.Insert(Control);

  R.Assign(4, 10, 12, 11);
  Dlg^.Insert(New(PLabel, Init(R, ' Модем:', Control)));



R.Assign(12, 11, 78, 12);
Control := New(PInputLine, Init(R, 64));
Dlg^.Insert(Control);

  R.Assign(4, 11, 12, 12);
  Dlg^.Insert(New(PLabel, Init(R, 'Приход:', Control)));


R.Assign(12, 12, 78, 13);
Control := New(PInputLine, Init(R, 64));
Dlg^.Insert(Control);

  R.Assign(6, 12, 12, 13);
  Dlg^.Insert(New(PLabel, Init(R, 'Ба~з~а:', Control)));

R.Assign(12, 13, 78, 14);
Control := New(PInputLine, Init(R, 64));
Dlg^.Insert(Control);

  R.Assign(3, 13, 12, 14);
  Dlg^.Insert(New(PLabel, Init(R, 'Продажи:', Control)));

R.Assign(12, 14, 78, 15);
Control := New(PInputLine, Init(R, 64));
Dlg^.Insert(Control);

  R.Assign(5, 14, 12, 15);
  Dlg^.Insert(New(PLabel, Init(R, 'Архив:', Control)));

R.Assign(12, 15, 78, 16);
Control := New(PInputLine, Init(R, 64));
Dlg^.Insert(Control);

  R.Assign(3, 15, 12, 16);
  Dlg^.Insert(New(PLabel, Init(R, '~В~озврат:', Control)));

R.Assign(12, 16, 78, 17);
Control := New(PInputLine, Init(R, 64));
Dlg^.Insert(Control);

  R.Assign(1, 16, 12, 17);
  Dlg^.Insert(New(PLabel, Init(R, 'Про~г~рамма:', Control)));

R.Assign(12, 17, 78, 18);
Control := New(PInputLine, Init(R, 64));
Dlg^.Insert(Control);

  R.Assign(1, 17, 12, 18);
  Dlg^.Insert(New(PLabel, Init(R, 'Коррекци~я~:', Control)));

R.Assign(12, 18, 78, 19);
Control := New(PInputLine, Init(R, 64));
Dlg^.Insert(Control);

  R.Assign(1, 18, 12, 19);
  Dlg^.Insert(New(PLabel, Init(R, 'Архива~ц~ия:', Control)));

R.Assign(12, 19, 78, 20);
Control := New(PInputLine, Init(R, 64));
Dlg^.Insert(Control);

  R.Assign(1, 19, 12, 20);
  Dlg^.Insert(New(PLabel, Init(R, 'От~ч~ет:', Control)));

R.Assign(2, 21, 45, 22);
Control := New(PRadioButtons, Init(R,
  NewSItem('~Н~аименование',
  NewSItem('~П~олное наимeнование', Nil))));
Dlg^.Insert(Control);

R.Assign(19, 3, 28, 4);
Control := New(PColoredText, Init(R, '>───────>', $7A));
Dlg^.Insert(Control);

R.Assign(1, 7, 79, 8);
Control := New(PColoredText, Init(R, ' Количество копий для документов: ───'+
     '────────────────────────────────────────', $74));
Dlg^.Insert(Control);

R.Assign(1, 9, 79, 10);
Control := New(PColoredText, Init(R, ' Размещение программных файлов: ─────'+
     '────────────────────────────────────────', $74));
Dlg^.Insert(Control);

R.Assign(1, 1, 79, 2);
Control := New(PColoredText, Init(R, ' Принтер и подключение: ─────────────'+
     '────────────────────────────────────────', $74));
Dlg^.Insert(Control);

R.Assign(78, 1, 79, 8);
Control := New(PColoredText, Init(R, '┐'^M+
     '│'^M+
     '│'^M+
     '│'^M+
     '│'^M+
     '│'^M+
     '│'^M+
     '┘', $74));
Dlg^.Insert(Control);

R.Assign(78, 7, 79, 10);
Control := New(PColoredText, Init(R, '┤'^M+
     '│'^M+
     '│'^M+
     '┘', $74));
Dlg^.Insert(Control);

R.Assign(78, 9, 79, 20);
Control := New(PColoredText, Init(R, '┤'^M+
     '│'^M+
     '│'^M+
     '│'^M+
     '│'^M+
     '│'^M+
     '│'^M+
     '│'^M+
     '│'^M+
     '│'^M+
     '│'^M+
     '│', $74));
Dlg^.Insert(Control);

R.Assign(1, 20, 79, 21);
Control := New(PColoredText, Init(R, ' Печать в документах: ───────────────'+
     '────────────────────────────────────────┤', $74));
Dlg^.Insert(Control);



R.Assign(46, 21, 79, 22);
Control := New(PColoredText, Init(R, '────────────────────────────────┘', $74));
Dlg^.Insert(Control);

R.Assign(46, 21, 71, 22);
Control := New(PCheckboxes, Init(R,
  NewSItem('Печат~ь~ сертификатов', Nil)));
Dlg^.Insert(Control);

R.Assign(30, 22, 62, 23);
Control := New(PRadioButtons, Init(R,
  NewSItem('Скидка в %',
  NewSItem('Абс.скидка', Nil))));
Dlg^.Insert(Control);

  R.Assign(1, 22, 30, 23);
  Dlg^.Insert(New(PLabel, Init(R, 'Скидка в док~у~ментах продажи:', Control)));

Dlg^.SelectNext(False);
Dlg^.SetData(Print);
C := DeskTop^.ExecView(Dlg);
If (C <> cmCancel) Then
        Begin
         Dlg^.GetData(Print);
         i:=0;
         WriteIni(c);
         WriteNewIni(c);
         If c<> 0 Then Errors('Ошибка записи файла конфигурации !')
         Else AddProtocol('Корректировка общих настроек системы!!!')
        End;
Dispose(Control, Done);
Dispose(Dlg, Done);
End;
*)
Procedure ConfigDistantion;
var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  i: word;
  c : LongInt;

begin
R.Assign(0, 4, 80, 21);
New(Dlg, Init(R, 'Размещение баз данных'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.Palette := dpCyanDialog;
Dlg^.HelpCtx:=$E002;

R.Assign(16, 1, 42, 2);
Control := New(PInputLine, Init(R, 64));
Dlg^.Insert(Control);

  R.Assign(5, 1, 16, 2);
  Dlg^.Insert(New(PLabel, Init(R, 'Программ~а~:', Control)));

R.Assign(16, 2, 42, 3);
Control := New(PInputLine, Init(R, 64));
Dlg^.Insert(Control);

  R.Assign(8, 2, 16, 3);
  Dlg^.Insert(New(PLabel, Init(R, '~П~риход:', Control)));

R.Assign(16, 3, 42, 4);
Control := New(PInputLine, Init(R, 64));
Dlg^.Insert(Control);

  R.Assign(7, 3, 16, 4);
  Dlg^.Insert(New(PLabel, Init(R, 'П~р~одажи:', Control)));

R.Assign(16, 4, 42, 5);
Control := New(PInputLine, Init(R, 64));
Dlg^.Insert(Control);

  R.Assign(7, 4, 16, 5);
  Dlg^.Insert(New(PLabel, Init(R, '~В~озврат:', Control)));

R.Assign(16, 5, 42, 6);
Control := New(PInputLine, Init(R, 64));
Dlg^.Insert(Control);

  R.Assign(4, 5, 16, 6);
  Dlg^.Insert(New(PLabel, Init(R, 'П~е~реоценка:', Control)));

R.Assign(16, 6, 42, 7);
Control := New(PInputLine, Init(R, 64));
Dlg^.Insert(Control);

  R.Assign(1, 6, 16, 7);
  Dlg^.Insert(New(PLabel, Init(R, 'База к~л~иентов:', Control)));

R.Assign(16, 7, 42, 8);
Control := New(PInputLine, Init(R, 64));
Dlg^.Insert(Control);

  R.Assign(3, 7, 16, 8);
  Dlg^.Insert(New(PLabel, Init(R, 'База дол~г~ов:', Control)));

R.Assign(16, 8, 42, 9);
Control := New(PInputLine, Init(R, 64));
Dlg^.Insert(Control);

  R.Assign(1, 8, 16, 9);
  Dlg^.Insert(New(PLabel, Init(R, 'История возв.:', Control)));

R.Assign(16, 9, 42, 10);
Control := New(PInputLine, Init(R, 64));
Dlg^.Insert(Control);

  R.Assign(1, 9, 16, 10);
  Dlg^.Insert(New(PLabel, Init(R, 'Истори~я~ долг.:', Control)));

R.Assign(16, 10, 42, 11);
Control := New(PInputLine, Init(R, 64));
Dlg^.Insert(Control);

  R.Assign(1, 10, 16, 11);
  Dlg^.Insert(New(PLabel, Init(R, '~О~плата долгов:', Control)));

R.Assign(16, 11, 42, 12);
Control := New(PInputLine, Init(R, 64));
Dlg^.Insert(Control);

  R.Assign(5, 11, 16, 12);
  Dlg^.Insert(New(PLabel, Init(R, 'Оператор~ы~:', Control)));

R.Assign(16, 12, 42, 13);
Control := New(PInputLine, Init(R, 64));
Dlg^.Insert(Control);

  R.Assign(2, 12, 16, 13);
  Dlg^.Insert(New(PLabel, Init(R, 'Наи~м~енования:', Control)));

R.Assign(16, 13, 42, 14);
Control := New(PInputLine, Init(R, 64));
Dlg^.Insert(Control);

  R.Assign(2, 13, 16, 14);
  Dlg^.Insert(New(PLabel, Init(R, 'Ра~з~делы:', Control)));

R.Assign(53, 1, 79, 2);
Control := New(PInputLine, Init(R, 64));
Dlg^.Insert(Control);

  R.Assign(44, 1, 53, 2);
  Dlg^.Insert(New(PLabel, Init(R, 'Нали~ч~ие:', Control)));

R.Assign(53, 2, 79, 3);
Control := New(PInputLine, Init(R, 64));
Dlg^.Insert(Control);

  R.Assign(45, 2, 53, 3);
  Dlg^.Insert(New(PLabel, Init(R, '~С~кидки:', Control)));

R.Assign(53, 3, 79, 4);
Control := New(PInputLine, Init(R, 64));
Dlg^.Insert(Control);

  R.Assign(46, 3, 53, 4);
  Dlg^.Insert(New(PLabel, Init(R, '~М~одем:', Control)));

R.Assign(53, 4, 79, 5);
Control := New(PInputLine, Init(R, 64));
Dlg^.Insert(Control);

  R.Assign(42, 4, 53, 5);
  Dlg^.Insert(New(PLabel, Init(R, 'Арх~и~вация:', Control)));

R.Assign(53, 5, 79, 6);
Control := New(PInputLine, Init(R, 64));
Dlg^.Insert(Control);

  R.Assign(46, 5, 53, 6);
  Dlg^.Insert(New(PLabel, Init(R, '~А~рхив:', Control)));

R.Assign(53, 6, 79, 7);
Control := New(PInputLine, Init(R, 64));
Dlg^.Insert(Control);

  R.Assign(46, 6, 53, 7);
  Dlg^.Insert(New(PLabel, Init(R, 'О~т~чет:', Control)));

R.Assign(53, 7, 79, 8);
Control := New(PInputLine, Init(R, 64));
Dlg^.Insert(Control);

  R.Assign(43, 7, 53, 8);
  Dlg^.Insert(New(PLabel, Init(R, 'Опера~ц~ии:', Control)));

R.Assign(53, 8, 79,  9);
Control := New(PInputLine, Init(R, 64));
Dlg^.Insert(Control);

  R.Assign(44, 8, 53,  9);
  Dlg^.Insert(New(PLabel, Init(R, 'Ревизия:', Control)));

R.Assign(53,  9, 79, 10);
Control := New(PInputLine, Init(R, 64));
Dlg^.Insert(Control);

  R.Assign(42,  9, 53, 10);
  Dlg^.Insert(New(PLabel, Init(R, 'Фа~й~л-флаг:', Control)));

R.Assign(53, 10, 79, 11);
Control := New(PInputLine, Init(R, 64));
Dlg^.Insert(Control);

  R.Assign(47, 10, 53, 11);
  Dlg^.Insert(New(PLabel, Init(R, 'Temp:', Control)));

R.Assign(53, 11, 79, 12);
Control := New(PInputLine, Init(R, 64));
Dlg^.Insert(Control);

  R.Assign(45, 12, 53, 12);
  Dlg^.Insert(New(PLabel, Init(R, 'Анализ:', Control)));


R.Assign(53, 12, 79, 13);
Control := New(PInputLine, Init(R, 64));
Dlg^.Insert(Control);

  R.Assign(45, 12, 53, 13);
  Dlg^.Insert(New(PLabel, Init(R, 'Бартер:', Control)));

R.Assign(53, 13, 79, 14);
Control := New(PInputLine, Init(R, 64));
Dlg^.Insert(Control);

  R.Assign(45, 13, 53, 14);
  Dlg^.Insert(New(PLabel, Init(R, 'Экспорт', Control)));

R.Assign(53, 14, 79, 15);
Control := New(PInputLine, Init(R, 64));
Dlg^.Insert(Control);

  R.Assign(45, 14, 53, 15);
  Dlg^.Insert(New(PLabel, Init(R, 'Импорт:', Control)));

R.Assign(53, 15, 79, 16);
Control := New(PInputLine, Init(R, 64));
Dlg^.Insert(Control);

  R.Assign(40, 15, 53, 16);
  Dlg^.Insert(New(PLabel, Init(R, 'Главн.склад:', Control)));


Dlg^.SelectNext(False);
Dlg^.SetData(Path);
C := DeskTop^.ExecView(Dlg);
If (C <> cmCancel) Then
        Begin
         Dlg^.GetData(Path);
         i:=0;
         {WriteIni(c);}
         WriteNewIni(c);
         If c<> 0 Then Errors('Ошибка записи файла конфигурации !')
         Else AddProtocol('Корректировка общих настроек системы!!!','','')
        End;
Dispose(Control, Done);
Dispose(Dlg, Done);
end;


Procedure PrintConfig;
Label 1;
var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  i: word;
  c : LongInt;
  Wspom : TDateString;
  W : NewPrintIni;
begin
W:=NPrint;
1:
R.Assign(0, 1, 80, 22);
New(Dlg, Init(R, 'Печать документов'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.Palette := dpCyanDialog;
Dlg^.HelpCtx:=$E002;
{
R.Assign(2, 2, 17, 4);
Control := New(PRadioButtons, Init(R,
  NewSItem('~М~атричный',
  NewSItem('~Л~азерный', Nil))));
Control^.Options := Control^.Options or ofFramed;
Dlg^.Insert(Control);
}
R.Assign(2, 2, 17, 6);
Control := New(PRadioButtons, Init(R,
  NewSItem('~М~атр.(А4)',
  NewSItem('Матр.(Рул)',
  NewSItem('~Л~азерный',
  NewSItem('Win Ansi',
  Nil))))));
Control^.Options := Control^.Options or ofFramed;
Dlg^.Insert(Control);



  R.Assign(2, 1, 16, 2);
  Dlg^.Insert(New(PLabel, Init(R, 'Тип принтера:', Control)));

R.Assign(18, 2, 33, 4);
Control := New(PRadioButtons, Init(R,
  NewSItem('~К~нижная',
  NewSItem('~А~льбомная', Nil))));
Control^.Options := Control^.Options or ofFramed;
Dlg^.Insert(Control);

  R.Assign(18, 1, 30, 2);
  Dlg^.Insert(New(PLabel, Init(R, 'Ориентация:', Control)));

R.Assign(34, 2, 44, 7);
Control := New(PRadioButtons, Init(R,
  NewSItem('LPT~1~',
  NewSItem('LPT~2~',
  NewSItem('LPT~3~',
  NewSItem('LPT~4~',
  NewSItem('LPT~5~',
  Nil)))))));
Control^.Options := Control^.Options or ofFramed;
Dlg^.Insert(Control);

  R.Assign(34, 1, 40, 2);
  Dlg^.Insert(New(PLabel, Init(R, 'Порт:', Control)));

R.Assign(45, 2, 53, 4);
Control := New(PRadioButtons, Init(R,
  NewSItem('Да',
  NewSItem('Нет', Nil))));
Control^.Options := Control^.Options or ofFramed;
Dlg^.Insert(Control);

  R.Assign(45, 1, 51, 2);
  Dlg^.Insert(New(PLabel, Init(R, 'Свап:', Control)));



R.Assign(54, 2, 78, 3);
Control := New(PInputLine, Init(R, 45));
Control^.Options := Control^.Options or ofFramed;
Dlg^.Insert(Control);

  R.Assign(70, 1, 73, 2);
  Dlg^.Insert(New(PHistory, Init(R, PInputline(Control), 15)));

  R.Assign(54, 1, 67, 2);
  Dlg^.Insert(New(PLabel, Init(R, 'Сетевое им~я~:', Control)));


R.Assign(54, 4, 78, 5);
Control := New(PSpecialInputLine, Init(R, 45));
Control^.Options := Control^.Options or ofFramed;
Dlg^.Insert(Control);

  R.Assign(73, 3, 76, 4);
  Dlg^.Insert(New(PHistory, Init(R, PSpecialInputLine(Control), 16)));


  R.Assign(54, 3, 72, 4);
  Dlg^.Insert(New(PLabel, Init(R, 'Строка установки:', Control)));

R.Assign(3, 7, 44, 9);
Control := New(PStaticText, Init(R, ''));
Control^.Options := Control^.Options or ofFramed;
Dlg^.Insert(Control);

R.Assign(11, 7, 14, 8);
Control := New(PInputLong, Init(R, 1, 1, 9, 0));
Dlg^.Insert(Control);

  R.Assign(3, 7, 11, 8);
  Dlg^.Insert(New(PLabel, Init(R, 'Прих~о~д:', Control)));

R.Assign(11, 8, 14, 9);
Control := New(PInputLong, Init(R, 1, 1, 9, 0));
Dlg^.Insert(Control);

  R.Assign(4, 8, 11, 9);
  Dlg^.Insert(New(PLabel, Init(R, 'Орде~р~:', Control)));

R.Assign(27, 7, 30, 8);
Control := New(PInputLong, Init(R, 1, 1, 9, 0));
Dlg^.Insert(Control);

  R.Assign(15, 7, 27, 8);
  Dlg^.Insert(New(PLabel, Init(R, 'П~е~реоценка:', Control)));

R.Assign(27, 8, 30, 9);
Control := New(PInputLong, Init(R, 1, 1, 9, 0));
Dlg^.Insert(Control);

  R.Assign(22, 8, 27, 9);
  Dlg^.Insert(New(PLabel, Init(R, 'С/~Ф~:', Control)));

R.Assign(40, 7, 43, 8);
Control := New(PInputLong, Init(R, 1, 1, 9, 0));
Dlg^.Insert(Control);

  R.Assign(31, 7, 40, 8);
  Dlg^.Insert(New(PLabel, Init(R, 'Прод~а~жа:', Control)));

R.Assign(40, 8, 43, 9);
Control := New(PInputLong, Init(R, 1, 1, 9, 0));
Dlg^.Insert(Control);

  R.Assign(31, 8, 40, 9);
  Dlg^.Insert(New(PLabel, Init(R, 'Возвра~т~:', Control)));

R.Assign(47, 7, 78, 9);
Control := New(PRadioButtons, Init(R, 
  NewSItem('~П~роцент',
  NewSItem('Абс велич.',
  NewSItem('Срок реал.',
  NewSItem('Нет', Nil))))));
Control^.Options := Control^.Options or ofFramed;
Dlg^.Insert(Control);

{
R.Assign(49, 7, 74, 9);
Control := New(PRadioButtons, Init(R,
  NewSItem('~П~роцент',
  NewSItem('Абсолютная величина', Nil))));
Control^.Options := Control^.Options or ofFramed;
Dlg^.Insert(Control);
}



  R.Assign(49, 6, 70, 7);
  Dlg^.Insert(New(PLabel, Init(R, 'Скидка в документах:', Control)));

R.Assign(2, 11, 32, 14);
Control := New(PCheckboxes, Init(R,
  NewSItem('Межскладском расходе',
  NewSItem('Док-тах клиента',
  NewSItem('Док-тах прихода,возврата', Nil)))));
Control^.Options := Control^.Options or ofFramed;
Dlg^.Insert(Control);

  R.Assign(2, 10, 25, 11);
  Dlg^.Insert(New(PLabel, Init(R, 'Печать сертиф~и~катов в:', Control)));

R.Assign(34, 11, 64, 14);
Control := New(PCheckboxes, Init(R,
  NewSItem('Межскладском расходе',
  NewSItem('Док-тах клиента',
  NewSItem('Док-тах прихода,возврата', Nil)))));
Control^.Options := Control^.Options or ofFramed;
Dlg^.Insert(Control);

  R.Assign(34, 10, 55, 11);
  Dlg^.Insert(New(PLabel, Init(R, 'Печать примечани~й~ в:', Control)));

R.Assign(66, 11, 78, 13);
Control := New(PRadioButtons, Init(R,
  NewSItem('Краткие',
  NewSItem('Полные', Nil))));
Control^.Options := Control^.Options or ofFramed;
Dlg^.Insert(Control);

  R.Assign(66, 10, 77, 11);
  Dlg^.Insert(New(PLabel, Init(R, 'Наимено~в~.:', Control)));

R.Assign(6, 6, 33, 7);
Control := New(PStaticText, Init(R, ' Количество копий'));
Dlg^.Insert(Control);

R.Assign(2, 16, 22, 17);
Control := New(PCheckboxes, Init(R,
  NewSItem('Предупреждение', Nil)));
Control^.Options := Control^.Options or ofFramed;
Dlg^.Insert(Control);

R.Assign(24, 16, 67, 17);
Control := New(PColoredText, Init(R, 'Диапазон времени', $31));
Control^.Options := Control^.Options or ofFramed;
Dlg^.Insert(Control);



R.Assign(43, 16, 53, 17);
Control := New(PInputLine, Init(R, 8));
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PPXPictureValidator, Init('##:##:00', True));

  R.Assign(40, 16, 43, 17);
  Dlg^.Insert(New(PLabel, Init(R, '~c~:', Control)));

R.Assign(57, 16, 67, 17);
Control := New(PInputLine, Init(R, 8));
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PPXPictureValidator, Init('##:##:00', True));

  R.Assign(53, 16, 57, 17);
  Dlg^.Insert(New(PLabel, Init(R, 'по:', Control)));

R.Assign(2, 19, 67, 20);
Control := New(PInputLine, Init(R, 63));
Dlg^.Insert(Control);

  R.Assign(2, 18, 24, 19);
  Dlg^.Insert(New(PLabel, Init(R, 'Текст предупреждения:', Control)));





Dlg^.SelectNext(False);
Dlg^.SetData(W);
C := DeskTop^.ExecView(Dlg);
If (C <> cmCancel) Then
        Begin
         Dlg^.GetData(W);
         WordToBit3(W.FullSertif,PrintSertifDoc);
         Convert3(PrintSertifDoc);
         WordToBit3(W.FullAkzis,PrintAkzisDoc);
         Convert3(PrintAkzisDoc);
         i:=0;

         {матричный принтер}
         If W.Printer in [0,1] Then W.Ini:='@!R';
         {лазерный}
         If W.Printer in [2] Then W.Ini:=#27+#69+#27+#38+#108+#54+#68+#27+#38+#107+#52+#83;
         {WinAnsi}
         If W.Printer in [3] Then W.Ini:='';

         {WriteIni(c);}

         If (W.mESSAG=1) aND
               (Not(TimeStringToTime(TimeMask,W.TimeStart)>=60) Or
            Not(TimeStringToTime(TimeMask,W.TimeStop)<=86340)) Then
             Begin
              MessageBox(^m+#3'Не допустимый диапазон времени!'^M+
                    #3+'Повторите настройку !',Nil,mfError+mfCancelButton);
              Dispose(Control, Done);
              Dispose(Dlg, Done);
              Goto 1;
             End;

         If (W.mESSAG=1) aND
               ((TimeStringToTime(TimeMask,W.TimeStart)=-1) Or
            (TimeStringToTime(TimeMask,W.TimeStop)=-1)) Then
             Begin
              MessageBox(^m+#3'Не допустимый диапазон времени!'^M+
                    #3+'Повторите настройку !',Nil,mfError+mfCancelButton);
              Dispose(Control, Done);
              Dispose(Dlg, Done);
              Goto 1;
             End;

         If (TimeStringToTime(TimeMask,W.TimeStart))>(TimeStringToTime(TimeMask,W.TimeStop)) Then
          Begin
          Wspom:=W.TimeStart;
          W.TimeStart:=W.TimeStop;
          W.TimeStop:=Wspom;
          End;
          DelSpaceRight(W.TextMessag);
          NPrint:=W;

         WriteNewIni(c);
         SoundSignal:=True;
         If c<> 0 Then Errors('Ошибка записи файла конфигурации !')
         Else AddProtocol('Корректировка общих настроек системы!!!','','')
        End;
Dispose(Control, Done);
Dispose(Dlg, Done);
end;


End.
