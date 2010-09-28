{$I Compile.INC}

{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}

Unit Access;

Interface

Uses Dialogs,Glob,Drivers,ServStr,Access2;

Type PNameWindow= ^TNameWindow;
     TNameWindow = object(TDialog)
    Procedure AddBazINI( Cod:Integer; st:ArtikulStr;Var Res:Boolean);
    procedure HandleEvent(var Event: TEvent); virtual;
    Destructor Done;Virtual;
  end;


Type PClientWindow= ^TClientWindow;
     TClientWindow = object(TDialog)
     NNN : PPersonalWindow;
    Procedure PrintClientInfo(s:ArtikulStr;Reg,Sel:Byte);
    Procedure ShowClientList(Var st:AllStr;Selector,Regim:Word;VidClienta,Net,TestSrok:Boolean;
          NoLocked1,VidNoLocked1,NoLocked2,VidNoLocked2:Integer;Var Res: Word);
    {
    Procedure ShowClientList(Var st:AllStr;Selector,
    Regim:Word;VidClienta,Net:Boolean;NoLocked1,VidNoLocked1,NoLocked2,VidNoLocked2:Integer;
    Var Res: Word);
    }
    Procedure Refresh(Reg,Sel:Word);
    procedure HandleEvent(var Event: TEvent); virtual;
    Procedure DrawCurrent(Reg,Sel: Byte);
    Destructor Done;Virtual;
  end;

Type PRazdelWindow= ^TRazdelWindow;
     TRazdelWindow = object(TDialog)
    Procedure ShowRazdelList(Var st:AllStr;Var Res: Word;l:Boolean);
    procedure HandleEvent(var Event: TEvent); virtual;
    Destructor Done;Virtual;
  end;





Function AddMake( Cod:Integer; Var MakeListElement:ClientType;MakeVid:Byte;VidClienta:Boolean):Boolean;
Function AddClient( Cod:Integer; Var ClientElement:ClientType;ClientVid:Byte;VidClienta:Boolean):Boolean;
{
Function AddDolgCount(C:ArtikulStr;Reg:Byte;Itog:Real):Boolean;
Function DelDolgCount(C:ArtikulStr;Reg:Byte;Itog:Real):Boolean;
}
{Function AddOperator( Cod:Integer; Var OperatorElement:TSystemReestr):Boolean;}
Function SortSkidka(inp:PSkidkaType): Boolean;
Function AddRazdel( Cod:Integer; Var RazdelElement:RazdelType):Boolean;
Procedure RenameList(Element:BazType;Const P : PBox);
Function CalcDolg(s:ALLStr):TEnjoyStr;

Procedure SaveTempLock(Kod:ArtikulStr;Status:Word;Caption:ArtikulStr);


Var
 OperatorNum,ClientNum,MakeListNum,RazdelNum,BazNum : PBox;
 OperatorFile :File Of  TSystemReestr;
 OperatorElement : TSystemReestr;
 MakeFile : ClientFileType;
 MakeElement : PClientType;
 RazdelFile : File Of RazdelType;
 RazdelElement : RazdelType;
 ClientFile : ClientFileType;
 ClientElement : PClientType;
 LizoFile: ClientFileType;
 BazFile : SkladFileType;
 BazElement : PSkladType;
 ElementFile : BazFileType;
 Element : PBazType;
 WithNetLock : Boolean;
 WithTEstSrok : Boolean;
 NotLockedCod1   : Integer;
 NotLockedCod2   : Integer;
 VidNotLockedCod1   : Integer;
 VidNotLockedCod2   : Integer;
 NullNDS: boolean;

Implementation


Uses Printers,Vision4,App,Views,Objects,MsgBox,Serv,ColorTxt,Validate,DbEngine,Memory,TpDate,
     Protect,Net,NetDbEng,NetCall,WinDos,Utils,UtilsP,UchDoh;


Var
   ControlLine,ControlLine2,ControlName2,ControlName,ControlGroup : PView;
   ControlDogovor,ControlSrokLizensia,ControlStatus,
   OptControl,ControlEnviropment,ControlLimit,ControlDolg,
   ControlVidNalog,ControlNalog,ControlNDS,ControlVidNDS,ControlNullNDS: PView;
   Reg,Sel : Word;
   NoDelete : Boolean;
   Debitors : Boolean;
   NameWin : PNameWindow;
   ClientWindow : PClientWindow;
   RazdelWindow : PRazdelWindow;
   PrevClient : String[CAll];
{
Function AddDolgCount(C:ArtikulStr;Reg:Byte;Itog:Real):Boolean;
Var i : Byte;
    r : Real;
    L : LongInt;
Begin
AddDolgCount:=False;
If Reg=0 Then
Assign(ClientFile,Print.PAthToMAin+'client.db')
Else
Assign(ClientFile,Print.PAthToMAin+'sklad.db');

i:=IoResult;
Reset(ClientFile);
i:=IOREsult;
If i <> 0 Then
 Begin
  MessageBox(#3'Ошибка открытия файла клиентов!',nil,mfError+mfCancelButton);
 End;
 l:=StrToInt(c);
 Seek(ClientFile,l);
 Read(ClientFile,ClientElement);
 r:=StrToReal(ClientElement.Dolg)+Itog;
 Str(r:CIZena:CMantissa,ClientElement.Dolg);
 DelSpace(ClientElement.Dolg);
 Seek(ClientFile,FilePos(ClientFile)-1);
 Write(ClientFile,ClientElement);
 Close(ClientFile);
 AddDolgCount:=True;
 i:=IOResult;
End;

Function DelDolgCount(C:ArtikulStr;Reg:Byte;Itog:Real):Boolean;
Var i : Byte;
    r : Real;
    L : LongInt;
Begin
DelDolgCount:=False;
If Reg=0 Then
Assign(ClientFile,Print.PAthToMAin+'client.db')
Else
Assign(ClientFile,Print.PAthToMAin+'sklad.db');

i:=IoResult;
Reset(ClientFile);
i:=IOREsult;
If i <> 0 Then
 Begin
  MessageBox(#3'Ошибка открытия файла клиентов!',nil,mfError+mfCancelButton);
 End;
 l:=StrToInt(c);
 Seek(ClientFile,l);
 Read(ClientFile,ClientElement);
 r:=StrToReal(ClientElement.Dolg)-Itog;
 If r<0 Then r:=0;
 Str(r:CIZena:CMantissa,ClientElement.Dolg);
 DelSpace(ClientElement.Dolg);
 Seek(ClientFile,FilePos(ClientFile)-1);
 Write(ClientFile,ClientElement);
 Close(ClientFile);
 DelDolgCount:=True;
 i:=IOResult;
End;


}

function GetGroupName(kod:ArtikulStr):AllStr;
var i: word;
    s,skod: string;
Begin
  GetGroupName:='';
  delspace(kod);
  if (Group<>nil) and (Group^.List^.Count>0) then
  begin
   for i:=0 to Group^.List^.Count-1 do
   begin
     s:=Group^.GetText(i,Group^.List^.Count);
     skod:=copy(s,1+CRazdel+1,CRazdelKod);

     if StrToInt(kod)=StrToInt(skod) then
     begin
	  GetGroupName:=copy(s,1,CRazdel);
       exit;
     end;
   end;
  end;
End;

function GetGroupKod(kod:AllStr):ArtikulStr;
var i: word;
    s,skod: string;
Begin
  GetGroupKod:='00';
  delspace(kod);
  if (Group<>nil) and (Group^.List^.Count>0) then
  begin
   for i:=0 to Group^.List^.Count-1 do
   begin
     s:=Group^.GetText(i,Group^.List^.Count);
     skod:=copy(s,1,CRazdel);
     delspace(sKod);
     if kod=skod then
     begin
	  GetGroupKod:=copy(s,1+CRazdel+1,CrazdelKod);
       exit;
     end;
   end;
  end;
End;


Function CalcDolg(s:ALLStr):TEnjoyStr;
Label 1;
Var i : Byte;
    R : Real;
    RealFile : File Of RealizasiaType;
    E : PRealizasiaType;
Begin
r:=0;
Assign (RealFile,Path.ToDolg+s+'.dlg');
i:=Ioresult;
Reset(Realfile);
i:=IOresult;
If (i<>0) Then Begin
                s:='НЕТ_КОНСИГНАЦИИ';
                Goto 1;
               End;
New(E,Init);
While Not(Eof(RealFile)) Do
 Begin
  Read(RealFile,E^.Dat);
  If E^.Dat.Market.Active Then  r:=r+E^.Dat.Dolg;
 End;
 Dispose(E,Done);
Close(RealFile);
Str(R:CIZena:CMantissa,s);
1:
DelSpace(S);
CalcDolg:=s;
End;


Function SortSkidka(inp:PSkidkaType): Boolean;
Label Stop;
Var bp,cp,tp : PSHkala;
    p : Shkala;
    i : Byte;
    l : Boolean;
Begin
 SortSkidka:=False;
 P.Up[0]:=#0;
 P.Proz[0]:=#0;
 New(Bp,Init(P));
 For i :=1 To 6{именно 6 а не CShkala тк только первые 6 цен используются для
                автоскидок} Do
  Begin
   If Not LowMemory Then new(Cp,Init(inp^.Dat.Skidka[i]))
   Else
         Begin
          GoTo Stop;
         End;
   Tp:=Bp;
   L := False;
   While  (Not (L)) And (Tp^.Next <> Nil) Do
   Begin
   If (StrToReal(Tp^.Next^.Dat.Up) > StrToReal(Cp^.Dat.Up))
{
   Or((StrToReal(Tp^.Next^.Dat.Up)=StrToReal(Cp^.Dat.Up))And
   (StrToReal(Tp^.Next^.Dat.Proz)>StrToReal(Cp^.Dat.Proz)))} Then L := True
   Else Tp:=Tp^.Next;
   End;
   If Not(L) And (Tp^.Next<> Nil) Then Tp^.Next:=Cp
   Else
       Begin
        Cp^.Next:=Tp^.Next;
        Tp^.Next:=Cp;
       End;
  End; {For}
  Cp := Bp^.Next;

  For i:=1 To 6 Do
  Begin
   Inp^.Dat.Skidka[i]:=Cp^.Dat;
   Cp:=Cp^.Next;
  End;
  SortSkidka:=True;
Stop:   Dispose(Bp,Done);
End;


Function AddMake( Cod:Integer; Var MakeListElement:ClientType;MakeVid:Byte;VidClienta:Boolean):Boolean;
Label 1;
var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  s : TEnjoyStr;{!!!}
  j,c: Word;
  Event : TEvent;
begin
ClearFind;

If Not(TestOpenDate1(FDate)) Then
   Begin
    MessageBox(#3^M+#3'Доступ к данным за '+FDate+' заблокирован!',Nil,mfError+mfCancelButton);
    AddMake:=False;
    Exit;
   End;

C:=IOResult;
AddMake:=False;
{If Not(VidClienta) Then
Begin}

Case MAkeVid Of
0:Assign(MakeFile,Path.ToClient+'Make.db');
1:Assign(MakeFile,Path.ToClient+'Sklad.db');
2:Assign(MakeFile,Path.ToClient+'Barter.db');
3:Assign(MakeFile,Path.ToClient+'Lizo.db');
Else;
End;

{End
Else
Begin
 If MakeVid=0 Then
 Assign(MakeFile,Print.PathToMain+'Debit.db')
 Else
 Assign(MakeFile,Print.PathToMain+'Debitp.db');
End;
}

Reset(MakeFile);
C:=IOResult;
If C<>0 Then
Begin
 MessageBox(#3^M+#3'Ошибка доступа к файлу поставщиков!',nil,mfError+mfCancelButton);
 AddMake:=False;
 Exit;
End;
AInfo('Читаю списки...');
 Case Cod Of
  kbGrayPlus:Begin
     MakeListElement.Employ:=True;
     While Not(Eof(MakeFile)) And (MakeListElement.Employ) Do
     Begin
      ReadMake(MAkeFile,MakeListElement);
{
     Repeat
     Until NetCall.Lock(MakeFile,FilePos(MakeFile)*SizeOf(ClientType),SizeOf(ClientType));

     Read(MakeFile,MakeListElement);

     Repeat
      NetCall.UnLock(MakeFile,(FilePos(MakeFile)-1)*SizeOf(ClientType),SizeOf(ClientType));
     Until (DosError=0);
}
     End;

     {Read(MakeFile,MakeListElement);}

     If Eof(MakeFile) And (MakeListElement.Employ) Then
      Begin
       NoInfo;
       MessageBox(#3^M+#3'Свободных позиций нет!',nil,mfWarning+mfCancelButton);
       Close(MakeFile);
       AddMake:=False;
       Exit;
      End;
      s:=MakeListElement.Kod;
      MakeListElement.Name[0]       :=#0;
      MakeListElement.FullName[0]       :=#0;
      MAkeListElement.Dogovor[0] :=#0;
      MAkeListElement.Limit[0]:=#0;
{      MAkeListElement.Dolg[0]:=#0;}
      For c:=1 To CPunkt Do
      MakeListElement.Punkt[c,0]     :=#0;
      MakeListElement.Adress[0]     :=#0;
      MakeListElement.INN[0]        :=#0;
      MakeListElement.R_Sh[0]       :=#0;
      MakeListElement.Gde[0]        :=#0;
      MakeListElement.Gorod[0]      :=#0;
      MakeListElement.Prozent[0]:=#0;
      MakeListElement.Region:=0;
      MakeListElement.Okonh[0]      :=#0;
      MakeListElement.Okpo[0]       :=#0;
      MakeListElement.Enviropment[0]:=#0;
      MakeListElement.Telefon[0]    :=#0;

      MakeListElement.Stat          :=False;
      MakeListElement.Locked        :=True;
      MakeListElement.Debit      :=0;
      MAkeListElement.ClientShkala :=0;
      MAkeListElement.SrokLizensia[0]    :=#0;
      MAkeListElement.Messages[0]    :=#0;
      MakeListElement.NoLimit:=0;
      MakeListElement.AgentKod[1]:='0000';
      MakeListElement.AgentKod[2]:='0000';
    End;
  kbF4:Begin
     s:=Copy(MakeList^.GetText(MakeList^.Focused,MakeList^.List^.Count),1+CMake+1,CMakeKod);
     Repeat

     ReadMake(MakeFile,MakeListElement);
{
     Repeat
     Until NetCall.Lock(MakeFile,FilePos(MakeFile)*SizeOf(ClientType),SizeOf(ClientType));

     Read(MakeFile,MakeListElement);

     Repeat
      NetCall.UnLock(MakeFile,(FilePos(MakeFile)-1)*SizeOf(ClientType),SizeOf(ClientType));
     Until (DosError=0);
}
     Until (Eof(MakeFile)) Or (MakeListElement.Kod=s);

     If Eof(MakeFile) And (MakeListElement.Kod<>s) Then
      Begin
       NoInfo;
       MessageBox(#3^M+#3'Поставщик в базе не найден!',nil,mfError+mfCancelButton);
       Close(MakeFile);
       AddMake:=False;
       Exit;
      End;
    End;
  Else;
 End;
Close(MakeFile);
1:
If Cod=kbGrayPlus Then
Begin
R.Assign(9, 1, 71, 22);
{If Not(VidClienta) Then}
 New(Dlg, Init(R, 'Добавить поставщика'));
{ Else  New(Dlg, Init(R, 'Добавить дебитора'))}
End
Else
Begin
R.Assign(9, 1, 71, 17);
{If Not(VidClienta) Then}
New(Dlg, Init(R, 'Изменить поставщика'))
{ Else  New(Dlg, Init(R, 'Изменить дебитора'))}
End;
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.Palette := dpCyanDialog;
Dlg^.HelpCtx:=$E011;

R.Assign(14, 1, 36, 2);
Control := New(PInputLine, Init(R, 20));
Dlg^.Insert(Control);

  R.Assign(36, 1, 39, 2);
  Dlg^.Insert(New(PHistory, Init(R, PInputline(Control), 11)));

{ If Not(VidClienta) Then
  Begin}
  R.Assign(3, 1, 14, 2);
  Dlg^.Insert(New(PLabel, Init(R, 'По~с~тавщик:', Control)));
{  End
  Else
  Begin
  R.Assign(5, 1, 14, 2);
  Dlg^.Insert(New(PLabel, Init(R, 'Дебитор:', Control)));
  End;}

R.Assign(14, 2, 39, 3);
Control := New(PInputLine, Init(R, 100));
Dlg^.Insert(Control);

  R.Assign(5, 2, 14, 3);
{ If Not(VidClienta) Then}
  Dlg^.Insert(New(PLabel, Init(R, 'Пол~н~ое:', Control)));


{ Else
  Dlg^.Insert(New(PLabel, Init(R, 'Дебитор:', Control)));}

R.Assign(48, 2, 61, 3);
Control := New(PInputLine, Init(R, 45));
(*If {((Not(VidClienta)Or Not(l))And}
   Not(l)And(Cod=kbF4){) Or (Not(VidClienta))} Then
Control^.Options := Control^.Options and not ofSelectable;*)
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);

  R.Assign(39, 2, 48, 3);
  Dlg^.Insert(New(PLabel, Init(R, 'Д~о~говор:', Control)));

R.Assign(14, 3, 18, 4);
Control := New(PInputLine, Init(R, 2));
If Not(VidClienta) Then
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);
{  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0']));}

  R.Assign(3, 3, 14, 4);
  Dlg^.Insert(New(PLabel, Init(R, 'Па~в~ильоны:', Control)));

R.Assign(29, 3, 33, 4);
Control := New(PInputLine, Init(R, 2));
If Not(VidClienta)Then
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);
 { PInputLine(Control)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0']));}

  R.Assign(20, 3, 29, 4);
  Dlg^.Insert(New(PLabel, Init(R, 'Р~а~звалы:', Control)));

R.Assign(44, 3, 48, 4);
Control := New(PInputLine, Init(R, 2));
If Not(VidClienta)Then
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);
{  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0']));}

  R.Assign(34, 3, 44, 4);
  Dlg^.Insert(New(PLabel, Init(R, 'Ма~г~азины:', Control)));

R.Assign(55, 3, 59, 4);
Control := New(PInputLine, Init(R, 2));
If Not(VidClienta)Then
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);
 { PInputLine(Control)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0']));}

  R.Assign(48, 3, 55, 4);
  Dlg^.Insert(New(PLabel, Init(R, 'От~д~ел:', Control)));

R.Assign(14, 4, 31, 5);
Control := New(PInputLine, Init(R, 15));
If Not(VidClienta)Then
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);
{  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));}

  R.Assign(1, 4, 14, 5);
  Dlg^.Insert(New(PLabel, Init(R, '~Л~имит долга:', Control)));
{
R.Assign(41, 4, 58, 5);
Control := New(PInputLine, Init(R, 15));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));

  R.Assign(35, 4, 41, 5);
  Dlg^.Insert(New(PLabel, Init(R, '~Д~олг:', Control)));
}

R.Assign(14, 5, 61, 6);
Control := New(PInputLine, Init(R, 45));
Dlg^.Insert(Control);

  R.Assign(7, 5, 14, 6);
  Dlg^.Insert(New(PLabel, Init(R, 'Адре~с~:', Control)));

R.Assign(14, 6, 61, 7);
Control := New(PInputLine, Init(R, 45));
Dlg^.Insert(Control);

  R.Assign(5, 6, 14, 7);
  Dlg^.Insert(New(PLabel, Init(R, '~Т~елефон:', Control)));

R.Assign(14, 7, 61, 8);
Control := New(PInputLine, Init(R, 45));
Dlg^.Insert(Control);

  R.Assign(6, 7, 14, 8);
  Dlg^.Insert(New(PLabel, Init(R, '~Р~/счет:', Control)));

R.Assign(14, 8, 61, 9);
Control := New(PInputLine, Init(R, 45));
Dlg^.Insert(Control);

  R.Assign(11, 8, 14, 9);
  Dlg^.Insert(New(PLabel, Init(R, 'в:', Control)));

R.Assign(14, 9, 61, 10);
Control := New(PInputLine, Init(R, 45));
Dlg^.Insert(Control);

  R.Assign(7, 9, 14, 10);
  Dlg^.Insert(New(PLabel, Init(R, 'Город:', Control)));

R.Assign(14, 10, 61, 11);
Control := New(PInputLine, Init(R, 45));
Dlg^.Insert(Control);

  R.Assign(9, 10, 14, 11);
  Dlg^.Insert(New(PLabel, Init(R, '~И~НН:', Control)));

R.Assign(14, 11, 61, 12);
Control := New(PInputLine, Init(R, 45));
Dlg^.Insert(Control);

  R.Assign(7, 11, 14, 12);
  Dlg^.Insert(New(PLabel, Init(R, 'О~Г~РН:', Control)));

R.Assign(14, 12, 61, 13);
Control := New(PInputLine, Init(R, 45));
Dlg^.Insert(Control);

  R.Assign(8, 12, 14, 13);
  Dlg^.Insert(New(PLabel, Init(R, 'ОК~П~О:', Control)));

R.Assign(14, 13, 61, 14);
Control := New(PInputLine, Init(R, 45));
Dlg^.Insert(Control);

  R.Assign(4, 13, 14, 14);
  Dlg^.Insert(New(PLabel, Init(R, 'Адрес Ф.:', Control)));

R.Assign(14, 14, 31, 15);
ControlNullNDS := New(PCheckboxes, Init(R,
  NewSItem('Нулевой НДС', Nil)));

Dlg^.Insert(ControlNullNDS);



{
R.Assign(14, 5, 61, 6);
Control := New(PInputLine, Init(R, 45));
Dlg^.Insert(Control);

  R.Assign(5, 2, 12, 3);
  Dlg^.Insert(New(PLabel, Init(R, '~А~дрес:', Control)));

R.Assign(14, 6, 61, 7);
Control := New(PInputLine, Init(R, 45));
Dlg^.Insert(Control);

  R.Assign(3, 3, 12, 4);
  Dlg^.Insert(New(PLabel, Init(R, '~Т~елефон:', Control)));

R.Assign(12, 4, 59, 5);
Control := New(PInputLine, Init(R, 45));
Dlg^.Insert(Control);

  R.Assign(4, 4, 12, 5);
  Dlg^.Insert(New(PLabel, Init(R, '~Р~/счет:', Control)));

R.Assign(12, 5, 59, 6);
Control := New(PInputLine, Init(R, 45));
Dlg^.Insert(Control);

  R.Assign(9, 5, 12, 6);
  Dlg^.Insert(New(PLabel, Init(R, 'в:', Control)));

R.Assign(12, 6, 59, 7);
Control := New(PInputLine, Init(R, 45));
Dlg^.Insert(Control);

  R.Assign(5, 6, 12, 7);
  Dlg^.Insert(New(PLabel, Init(R, '~Г~ород:', Control)));

R.Assign(12, 7, 59, 8);
Control := New(PInputLine, Init(R, 45));
Dlg^.Insert(Control);

  R.Assign(7, 7, 12, 8);
  Dlg^.Insert(New(PLabel, Init(R, 'И~Н~Н:', Control)));

R.Assign(12, 8, 59, 9);
Control := New(PInputLine, Init(R, 45));
Dlg^.Insert(Control);

  R.Assign(5, 8, 12, 9);
  Dlg^.Insert(New(PLabel, Init(R, 'ОК~О~НX:', Control)));

R.Assign(12, 9, 59, 10);
Control := New(PInputLine, Init(R, 45));
Dlg^.Insert(Control);

  R.Assign(6, 9, 12, 10);
  Dlg^.Insert(New(PLabel, Init(R, 'ОК~П~О:', Control)));

R.Assign(12, 10, 59, 11);
Control := New(PInputLine, Init(R, 45));
Dlg^.Insert(Control);

  R.Assign(1, 10, 12, 11);
  Dlg^.Insert(New(PLabel, Init(R, 'Доп. ~у~сл.:', Control)));
}
Dlg^.SetData(MakeListElement);

If Cod=kbGrayPlus Then NullNds:=false
else NullNds:=GetNullNds(MakeListElement.Kod);
ControlNullNDS^.SetData(NullNds);


If Cod = kbGrayPlus  Then
Begin
 R.Assign(61, 16, 62, 20);
 Control := New(PScrollBar, Init(R));
 Dlg^.Insert(Control);
 R.Assign(1, 16, 61, 20);
 MakeListNum := New(PBox, Init(R, 8, PScrollbar(Control)));
 MakeListNum^.NewList(New(PTextCollection, Init(0,1)));
{If Not(VidClienta) Then
Begin}
Case MAkeVid Of
0:Assign(MakeFile,Path.ToClient+'Make.db');
1:Assign(MakeFile,Path.ToClient+'Sklad.db');
2:Assign(MakeFile,Path.ToClient+'Barter.db');
Else;
End;

{End
Else
Begin
 If MakeVid=0 Then
 Assign(MakeFile,Print.PathToMain+'Debit.db')
 Else
 Assign(MakeFile,Print.PathToMain+'Debitp.db');
End;
}
 Reset (MakeFile);
 While Not(Eof(MakeFile)) Do
  Begin
   ReadMake(MakeFile,MakeListElement);
   DelSpace(MakeElement^.Dat.Test_Srok);

{
     Repeat
     Until NetCall.Lock(MakeFile,FilePos(MakeFile)*SizeOf(ClientType),SizeOf(ClientType));

     Read(MakeFile,MakeListElement);

     Repeat
      NetCall.UnLock(MakeFile,(FilePos(MakeFile)-1)*SizeOf(ClientType),SizeOf(ClientType));
     Until (DosError=0);
}
   If Not(MakeListElement.Employ) Then
   Begin
   Format (MakeListElement.Name,CMake);
   MakeListNum^.List^.Insert(NewStr({MakeListElement.Name+}'│'+MakeListElement.Kod));
   MakeListNum^.SetRange(MakeListNum^.List^.Count);
   MakeListNum^.FocusItem(MakeListNum^.List^.Count);
   End;
  End;
 System.Close(MakeFile);
 If Cod=kbF4 Then MakeListNum^.FocusItem(LoCation(MakeListNum,s,ProdagaWindow))
 Else MakeListNum^.FocusItem(0);

 Dlg^.Insert(MakeListNum);
 MakeListNum^.HelpCtx:=$E011;

  R.Assign(1, 15, 37, 16);
  Dlg^.Insert(New(PLabel, Init(R, '~Д~оступные коды:', MakeListNum)));
  Dlg^.Insert(Control);
 End;
If Cod=kbF4 Then
 Begin
  R.Assign(52, 1, 57, 2);
  Control := New(PColoredText, Init(R, 'Код:', $3E));
  Dlg^.Insert(Control);
  R.Assign(57, 1, 61, 2);
  Control := New(PColoredText, Init(R, MakeListElement.Kod,$3E));
  Dlg^.Insert(Control);
 End;


Dlg^.SelectNext(False);
NoInfo;

c:=Desktop^.ExecView(Dlg);
If c<>cmCancel Then
 Begin
  Dlg^.GetData(MakeListElement);
    MakeListElement.Debit      :=0;
    MakeListElement.NoLimit    :=0;
    MakeListElement.ClientShkala  :=0;
    MAkeListElement.SrokLizensia[0]    :=#0;
    MAkeListElement.Messages[0]    :=#0;
    makelistElement.LockTime :=False;


    DelSpaceRight(MakeListElement.Name);
    If VidClienta Then
    Begin
    j:=0;
    For c:=1 To CPunkt Do
    Begin
     j:=j+StrToInt(MakelistElement.Punkt[c]);
    End;
    If j=0 Then
     Begin
    MessageBox(#3^M+#3'Нет торговых точек !',nil,mfError+mfCancelButton);
{If Cod=kbGrayPlus Then
  Begin
   s:=MakeListNum^.GetText(MakeListNum^.Focused,MakeListNum^.List^.Count);
   s:=Copy(s,1+CMake+1,CMakeKod);
  MakeListNum^.NewList(Nil);
  Dispose(MakeListNum,Done);
  End;
  Dispose(Control,Done);
  Dispose(Dlg,Done);
    Goto 1;}
    End;
    End;
    If MakeListElement.Name[0]=#0 Then
   Begin
    MessageBox(#3^M+#3'Недопустимое имя поставщика!',nil,mfError+mfCancelButton);
If Cod=kbGrayPlus Then
  Begin
   s:=MakeListNum^.GetText(MakeListNum^.Focused,MakeListNum^.List^.Count);
   s:=Copy(s,1+CMake+1,CMakeKod);
  MakeListNum^.NewList(Nil);
  Dispose(MakeListNum,Done);
  End;
  Dispose(Control,Done);
  Dispose(Dlg,Done);
    Goto 1;
   End;

    If MakeListElement.FullName[0]=#0 Then
   Begin
    MessageBox(^M+#3'Недопустимое полное наименование поставщика!',nil,mfError+mfCancelButton);
If Cod=kbGrayPlus Then
  Begin
   s:=MakeListNum^.GetText(MakeListNum^.Focused,MakeListNum^.List^.Count);
   s:=Copy(s,1+CClient+1,CClientKod);
  MakeListNum^.NewList(Nil);
  Dispose(MakeListNum,Done);
  End;
  Dispose(Control,Done);
  Dispose(Dlg,Done);
    Goto 1;
   End;


(*
только для ХЭППИ
   If MakeVid=0 Then
   Begin
    If (Pos('КТИ',MakeElement.Name)>0)Or
       (Pos('СОЙФЕР',MAkeElement.Name)>0)Or
       (Pos('МЯСНОВ',MakeElement.Name)>0)Or
       (Pos('Р/П',MakeElement.Name)>0)Or
       (Pos('РЕЗЕРВ',MakeElement.Name)>0)
       Then
        Begin
  if MessageBox(#3'Подозрительное имя клиента!'^M+
    #3'Вы убеждены, что оформляете не внутренний документ ?',nil,mfWarning+mfOkCancel)<>cmOk Then
          Begin
If Cod=kbGrayPlus Then
  Begin
   s:=MakeListNum^.GetText(MakeListNum^.Focused,MakeListNum^.List^.Count);
   s:=Copy(s,1+CMAke+1,CMAkeKod);
   MakeListNum^.NewList(Nil);
   Dispose(MakeListNum,Done);
  End;
  Dispose(Control,Done);
  Dispose(Dlg,Done);
    Goto 1;
  End;{If Cod}
  End;{Message}
  End;{If CLientVid}
*)
  C:=IOResult;

If Cod=kbGrayPlus Then
  Begin
   s:=MakeListNum^.GetText(MakeListNum^.Focused,MakeListNum^.List^.Count);
   s:=Copy(s,1+1,CClientKod);
  end;

  {Если добавляем нового клиента то блокируем выбранный код}
  If Cod=kbGrayPlus Then
  Begin
   If Not(TestEmployClientAndLock(1,MAkeVid,s)) Then
    Begin
     Beep;
     DInfoMsg('Не могу заблокировать клиента с кодом '+s+'...');
     Application^.ClearEvent(Event);
     Application^.ClearEvent(Event);
      repeat
       Application^.GetEvent(Event);
      until (Event.What <> evNothing);
     NoInfoMsg;
     Application^.ClearEvent(Event);
     Dispose(MakeListNum,Done);
     Dispose(Control,Done);
     Dispose(Dlg,Done);
     Goto 1;
    End;
  End;

  {исходим из того что блокировка удалась}

   UpStr(MakeListElement.Name);
   UpStr(MakeListElement.FullName);
   UpStr(MakeListElement.Adress);
   UpStr(MakeListElement.INN);
   UpStr(MakeListElement.R_Sh);
   UpStr(MakeListElement.Gde);
   UpStr(MakeListElement.Gorod);
   UpStr(MakeListElement.Okonh);
   UpStr(MakeListElement.Okpo);
   UpStr(MakeListElement.Enviropment);
   UpStr(MakeListElement.Telefon);
   MakeListElement.Employ:=True;
   MakeListElement.Stat:=False;
   MakeListElement.Locked:=True;
   If Cod=kbGrayPlus Then MakeListElement.Kod:=s;
   ControlNullNDS^.GetData(NullNDS);
   if NullNds then SetNullNDS(MAkeListElement.KOd,true)
   else SetNullNDS(MAkeListElement.KOd,false);


  {если не удалось записать информацию}
  If Not (WriteLockClient(1,MAkeVid,MakeListElement)) Then
    Begin
     If Cod=kbGrayPlus Then Dispose(MakeListNum,Done);
     Dispose(Control,Done);
     Dispose(ControlNullNDS,Done);
     Dispose(Dlg,Done);
     Repeat
     Until (SetClientUnLock(s,1,MAkeVid));
     Goto 1;
    End;

  If Cod=kbGrayPlus Then
  Begin
   AddProtocol('Добавление нового поставщика:'+MakeListElement.Name+' ('+s+')','','');
   Repeat
   Until (SetClientUnLock(s,1,MAkeVid));
  End
  Else
   AddProtocol('Корректировка данных поставщика:'+MakeListElement.Name+' ('+MakeListElement.Kod+')','','');
  AddMake:=True;

 End;

If Cod=kbGrayPlus Then
  Begin
   MakeListNum^.NewList(Nil);
   Dispose(MakeListNum,Done);
  End;

  Dispose(Control,Done);
  Dispose(ControlNullNDS,Done);
  Dispose(Dlg,Done);
{  CartWin^.Select;}
  PrevClient[0]:=#0;
end;

Function AddClient(Cod:Integer; Var ClientElement:ClientType;ClientVid:Byte;VidClienta:Boolean):Boolean;
Label 1;
var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  ControlOpt: PView;
  s : TEnjoyStr;{!!!}
  j,c: Word;
  Full : Boolean;
  k : LongInt;
{  l : Boolean;}
  Event:TEvent;
  PrevLock:Boolean;
  PrevDate : TDateSTring;
  EnableProz,EnableProz1 : Boolean;
  ClKod: String[CClientKod];
begin

ClearFind;
PrevDate :=FDate;

If Not(TestOpenDate1(FDate)) Then
   Begin
    MessageBox(#3^M+#3'Доступ к данным за '+FDate+' заблокирован!',Nil,mfError+mfCancelButton);
    AddClient:=False;
    Exit;
   End;

C:=IOResult;
AddClient:=False;
If ClientVid=0 Then Full:=Password(1)
Else Full:=False;
{If Not (VidClienta) Then
Begin}

EnableProz:=False;
{EnableProz1:=False;}
EnableProz:=Password(10);
{EnableProz1:=Password(1);}

Case ClientVid Of
0:Assign(ClientFile,Path.ToClient+'Client.db');
1:Assign(ClientFile,Path.ToClient+'Sklad.db');
2:Assign(ClientFile,Path.ToClient+'Barter.db');
3:Assign(ClientFile,Path.ToClient+'Lizo.db');
Else;
End;


{End
Else
Begin
 If ClientVid=0 Then
 Assign(ClientFile,Print.PathToMain+'Debit.db')
 Else
 Assign(ClientFile,Print.PathToMain+'Debitp.db');
End;
}
{L:=False;
If Cod=kbF4 Then
 Begin
  If VidClienta Then
  If Password(2) Then l:=True;
 End;
}
Reset(ClientFile);
C:=IOResult;
If C<>0 Then
Begin
 MessageBox(#3^M+#3'Ошибка доступа к файлу клиентов!',nil,mfError+mfCancelButton);
 AddClient:=False;
 Exit;
End;
AInfo('Читаю списки...');
 Case Cod Of
  kbGrayPlus:Begin
     ClientElement.Employ:=True;
     While Not(Eof(ClientFile)) And (ClientElement.Employ) Do
     begin
{
     Repeat
     Until NetCall.Lock(ClientFile,FilePos(ClientFile)*SizeOf(ClientType),SizeOf(ClientType));

     Read(ClientFile,ClientElement);

     Repeat
      NetCall.UnLock(ClientFile,(FilePos(ClientFile)-1)*SizeOf(ClientType),SizeOf(ClientType));
     Until (DosError=0);
}
     ReadClient(ClientFile,ClientElement);
     end;


     If Eof(ClientFile) And (ClientElement.Employ) Then
      Begin
       NoInfo;
       MessageBox(#3^M+#3'Свободных позиций для клиентов-нет!',nil,mfWarning+mfCancelButton);
       System.Close(ClientFile);
       AddClient:=False;
       Exit;
      End;
      s:=ClientElement.Kod;
      ClientElement.Name[0]       :=#0;
      ClientElement.FullName[0]       :=#0;
      ClientElement.Adress[0]     :=#0;
      ClientElement.Dogovor[0]     :=#0;
      ClientElement.Limit     :='';
{      ClientElement.Dolg[0]:=#0;}
      For c:=1 To CPunkt Do
      ClientElement.Punkt[c,0]        :=#0;
      ClientElement.Punkt[4]        :='0';
      ClientElement.INN[0]        :=#0;
      ClientElement.R_Sh[0]       :=#0;
      ClientElement.Gde[0]        :=#0;
      ClientElement.Gorod[0]      :=#0;
      ClientElement.Okonh[0]      :=#0;
      ClientElement.Okpo       :='';
      ClientElement.Enviropment[0]:=#0;
      ClientElement.Telefon[0]    :=#0;
      ClientElement.Debit      :=0;
      ClientElement.Test_Srok :='';
      ClientElement.Prozent [0]:=#0;
      ClientElement.ClientShkala :=0;
      ClientElement.Region :=0;
      ClientElement.SrokLizensia    :='';
      ClientElement.Messages[0]:=#0;
      ClientElement.Stat          :=false;
      ClientElement.Prozent:='14';
      ClientElement.Locked        :=True;
      ClientElement.LockTime       :=False;
      ClientElement.AgentKod[1]:='0000';
      ClientElement.AgentKod[2]:='0000';
      ClientElement.NoLimit:=0;
      ClientElement.Opt:=false;

    End;
  kbF4:Begin
     s:=Copy(Client^.GetText(Client^.Focused,Client^.List^.Count),1+CClient+1,CClientKod);
     Repeat
     ReadClient(ClientFile,ClientElement);
{
     Repeat
     Until NetCall.Lock(ClientFile,FilePos(ClientFile)*SizeOf(ClientType),SizeOf(ClientType));

     Read(ClientFile,ClientElement);

     Repeat
      NetCall.UnLock(ClientFile,(FilePos(ClientFile)-1)*SizeOf(ClientType),SizeOf(ClientType));
     Until (DosError=0);
}
     Until (Eof(ClientFile)) Or (ClientElement.Kod=s);
     If Eof(ClientFile) And (ClientElement.Kod<>s) Then
      Begin
       NoInfo;
       MessageBox(#3^M+#3'Клиент в базе не найден!',nil,mfError+mfCancelButton);
       System.Close(ClientFile);
       AddClient:=False;
       Exit;
      End;
      PrevLock:=ClientElement.LockTime;

    End;
  Else;
 End;
System.Close(ClientFile);
1:
If Cod=kbGrayPlus Then
Begin
R.Assign(9, 1, 71, 24);
{If Not(VidClienta) Then}
New(Dlg, Init(R, 'Добавить клиента'));
{Else
New(Dlg, Init(R, 'Добавить дебитора'))}
End
Else
Begin
R.Assign(9, 1, 71, 20);
{If Not(VidClienta) Then}
New(Dlg, Init(R, 'Изменить клиента'));
{Else
New(Dlg, Init(R, 'Изменить дебитора'))}
End;
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.Palette := dpCyanDialog;
Dlg^.HelpCtx:=$E011;
R.Assign(14, 1, 36, 2);
Control := New(PInputLine, Init(R, 20));
Dlg^.Insert(Control);

  R.Assign(36, 1, 39, 2);
  Dlg^.Insert(New(PHistory, Init(R, PInputline(Control), 12)));

  R.Assign(5, 1, 14, 2);
{ If Not(VidClienta) Then}
  Dlg^.Insert(New(PLabel, Init(R, 'Кли~е~нт:', Control)));



R.Assign(14, 2, 39, 3);
Control := New(PInputLine, Init(R, 100));
Dlg^.Insert(Control);

  R.Assign(5, 2, 14, 3);
{ If Not(VidClienta) Then}
  Dlg^.Insert(New(PLabel, Init(R, 'Пол~н~ое:', Control)));


{ Else
  Dlg^.Insert(New(PLabel, Init(R, 'Дебитор:', Control)));}

R.Assign(48, 2, 61, 3);
Control := New(PInputLine, Init(R, 45));
(*If {((Not(VidClienta)Or Not(l))And}
   Not(l)And(Cod=kbF4){) Or (Not(VidClienta))} Then
Control^.Options := Control^.Options and not ofSelectable;*)
If (ClientVid=1) Or (Not(Full))Then
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);

  R.Assign(39, 2, 48, 3);
  Dlg^.Insert(New(PLabel, Init(R, 'Д~о~говор:', Control)));

R.Assign(14, 3, 18, 4);
Control := New(PInputLine, Init(R, 2));
{If Not(VidClienta) Then
Control^.Options := Control^.Options and not ofSelectable;}
If (ClientVid=1) Or (Not(Full))Then
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0']));

  R.Assign(2, 3, 14, 4);
  Dlg^.Insert(New(PLabel, Init(R, 'Срок конс.:', Control)));

R.Assign(38, 3, 42, 4);
Control := New(PInputLine, Init(R, 2));
{If Not(VidClienta)Then
Control^.Options := Control^.Options and not ofSelectable;}
If (ClientVid=1) Or (Not(Full))Then
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['+','-']));

  R.Assign(20, 3, 37, 4);
  Dlg^.Insert(New(PLabel, Init(R, 'Дост(+)Самов(-):', Control)));
  if pos('-',ClientElement.Punkt[2])>0 then ClientElement.Punkt[2]:='-'
  else ClientElement.Punkt[2]:='+';

R.Assign(44, 3, 44, 4);
Control := New(PInputLine, Init(R, 2));
{If Not(VidClienta)Then
Control^.Options := Control^.Options and not ofSelectable;}
If (ClientVid=1) Or (Not(Full))Then
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0']));

  R.Assign(44, 3, 44, 4);
  Dlg^.Insert(New(PLabel, Init(R, {'Ма~г~азины:'}' ', Control)));
Control^.Options := Control^.Options and not ofSelectable;
R.Assign(57, 3, 61, 4);
Control := New(PInputLine, Init(R, 2));
{If Not(VidClienta)Then
Control^.Options := Control^.Options and not ofSelectable;}
If (ClientVid=1) Or (Not(Full))Then
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0']));

  R.Assign(46, 3, 57, 4);
  Dlg^.Insert(New(PLabel, Init(R, {'От~д~ел:'}'Маршрут:', Control)));

R.Assign(14, 4, 31, 5);
Control := New(PInputLine, Init(R, 15));
(*If {((Not(VidClienta)Or Not(l))And}Not(l)And(Cod=kbF4){) Or (Not(VidClienta))} Then
Control^.Options := Control^.Options and not ofSelectable;*)
If (ClientVid=1) Or (Not(Full))Then
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));

  R.Assign(1, 4, 14, 5);
  Dlg^.Insert(New(PLabel, Init(R, '~Л~имит долга:', Control)));
{
R.Assign(41, 4, 58, 5);
Control := New(PInputLine, Init(R, 15));
If Not(VidClienta)Or(CurrentPassword<>'00')Then
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));

  R.Assign(35, 4, 41, 5);
  Dlg^.Insert(New(PLabel, Init(R, '~Д~олг:', Control)));
}
R.Assign(14, 5, 61, 6);
Control := New(PInputLine, Init(R, 45));
Dlg^.Insert(Control);

  R.Assign(7, 5, 14, 6);
  Dlg^.Insert(New(PLabel, Init(R, 'Адре~с~:', Control)));

R.Assign(14, 6, 48, 7);
Control := New(PInputLine, Init(R, 45));
Dlg^.Insert(Control);

  R.Assign(5, 6, 14, 7);
  Dlg^.Insert(New(PLabel, Init(R, '~Т~елефон:', Control)));

R.Assign(14, 7, 48, 8);
Control := New(PInputLine, Init(R, 45));
Dlg^.Insert(Control);

  R.Assign(6, 7, 14, 8);
  Dlg^.Insert(New(PLabel, Init(R, '~Р~/счет:', Control)));

R.Assign(14, 8, 48, 9);
Control := New(PInputLine, Init(R, 45));
Dlg^.Insert(Control);

  R.Assign(11, 8, 14, 9);
  Dlg^.Insert(New(PLabel, Init(R, 'в:', Control)));

R.Assign(14, 9, 48, 10);
Control := New(PInputLine, Init(R, 45));
Dlg^.Insert(Control);

  R.Assign(7, 9, 14, 10);
  Dlg^.Insert(New(PLabel, Init(R, 'Город:', Control)));

R.Assign(14, 10, 48, 11);
Control := New(PInputLine, Init(R, 45));
Dlg^.Insert(Control);

  R.Assign(9, 10, 14, 11);
  Dlg^.Insert(New(PLabel, Init(R, '~И~НН:', Control)));

R.Assign(14, 11, 48, 12);
Control := New(PInputLine, Init(R, 45));
Dlg^.Insert(Control);

  R.Assign(7, 11, 14, 12);
  Dlg^.Insert(New(PLabel, Init(R, 'О~Г~РН:', Control)));

R.Assign(14, 12, 48, 13);
Control := New(PInputLine, Init(R, 45));
Dlg^.Insert(Control);

  R.Assign(8, 12, 14, 13);
  Dlg^.Insert(New(PLabel, Init(R, 'ОК~П~О:', Control)));

R.Assign(14, 13, 48, 14);
Control := New(PInputLine, Init(R, 45));
Dlg^.Insert(Control);

  R.Assign(4, 13, 14, 14);
  Dlg^.Insert(New(PLabel, Init(R, 'Адрес Ф:', Control)));


R.Assign(14, 14, 48, 15);
Control := New(PInputLine, Init(R, CSertif));
If (ClientVid=1) Or (Not(Full))Then
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);

  R.Assign(3, 14, 14, 15);
  Dlg^.Insert(New(PLabel, Init(R, 'Сооб~щ~ение:', Control)));


R.Assign(12, 15, 33, 16);
Control := New(PCheckboxes, Init(R,
  NewSItem('Ра~з~решить дебит', Nil)));
If (ClientVid=1) Or (Not(Full))Then
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);


R.Assign(12, 16, 33, 17);
Control := New(PCheckboxes, Init(R,
  NewSItem('От~к~л.конт.проср', Nil)));
If Not (StrToInt(CurrentPassword)=0) Then
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);



R.Assign(49, 7, 61, 14);
Control := New(PRadioButtons, Init(R,
  NewSItem('Р/Це~н~а',
  NewSItem('Цена ~1~',
  NewSItem('Цена ~2~',
  NewSItem('Цена ~3~',
  NewSItem('Цена ~4~',
  NewSItem('Цена ~5~',
  NewSItem('Цена ~6~', Nil)))))))));
 If (ClientVid=1) Or (Not(Full))Then
 Control^.Options := Control^.Options and not ofSelectable;

Dlg^.Insert(Control);

  R.Assign(48, 6, 59, 7);
  Dlg^.Insert(New(PLabel, Init(R, 'Шкала цен:', Control)));

R.Assign(51, 15, 61, 16);
Control := New(PInputLine, Init(R, 8));

If (ClientVid=1) Then
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PPXPictureValidator, Init(DateFiltr, True));

  R.Assign(33, 15, 51, 16);
  Dlg^.Insert(New(PLabel, Init(R, 'Срок договора до:', Control)));

R.Assign(51, 16, 61, 17);
Control := New(PInputLine, Init(R, CArtikul));
If {Not EnableProz1}(Not(Full)) Then
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0']));

  R.Assign(33, 16, 51, 17);
  Dlg^.Insert(New(PLabel, Init(R, 'Периодичность:', Control)));


R.Assign(3, 17, 40, 18);
Control := New(PRadioButtons, Init(R,
  NewSItem('Оф',
  NewSItem('Гор.',
  NewSItem('Обл',
  NewSItem('Рез.', Nil))))));
Dlg^.Insert(Control);



R.Assign(51, 17, 61, 18);
Control := New(PInputLine, Init(R, CLitr));
If Not EnableProz Then
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));

R.Assign(41, 17, 51, 18);
  Dlg^.Insert(New(PLabel, Init(R, '% Агента:', Control)));


R.Assign(31, 18, 41, 19);
Control := New(PInputLine, Init(R, CLitr));
If (ClientVid=1) Or (Not(Full))Then
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);

  R.Assign(25, 18, 30, 19);
  Dlg^.Insert(New(PLabel, Init(R, 'ЗАК:', Control)));


R.Assign(51, 18, 61, 19);
Control := New(PInputLine, Init(R, CLitr));
If (ClientVid=1) Or (Not(Full))Then
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);

  R.Assign(44, 18, 50, 19);

  Dlg^.Insert(New(PLabel, Init(R, 'ВЭН:', Control)));

{
ClientElement.Name:='1';
ClientElement.FullName:='1';
}
Dlg^.SetData(ClientElement);


If Cod = kbGrayPlus  Then
Begin
 R.Assign(61, 19, 62, 22);
 Control := New(PScrollBar, Init(R));
 Dlg^.Insert(Control);
 R.Assign(1, 19, 61, 22);
 ClientNum := New(PBox, Init(R, 9, PScrollbar(Control)));
 ClientNum^.NewList(New(PTextCollection, Init(0,1)));

Case ClientVid Of
0:Assign(ClientFile,Path.ToClient+'Client.db');
1:Assign(ClientFile,Path.ToClient+'Sklad.db');
2:Assign(ClientFile,Path.ToClient+'Barter.db');
Else;
End;

 Reset (ClientFile);
 While Not(Eof(ClientFile)) Do
  Begin
   ReadClient(ClientFile,ClientElement);
{
     Repeat
     Until NetCall.Lock(ClientFile,FilePos(ClientFile)*SizeOf(ClientType),SizeOf(ClientType));

     Read(ClientFile,ClientElement);

     Repeat
      NetCall.UnLock(ClientFile,(FilePos(ClientFile)-1)*SizeOf(ClientType),SizeOf(ClientType));
     Until (DosError=0);
}
   If Not(ClientElement.Employ) Then
   Begin
   Format (ClientElement.Name,CClient);
   ClientNum^.List^.Insert(NewStr({MakeListElement.Name+}'│'+ClientElement.Kod));
   ClientNum^.SetRange(ClientNum^.List^.Count);
   ClientNum^.FocusItem(ClientNum^.List^.Count);
   End;
  End;
 System.Close(ClientFile);
 If Cod=kbF4 Then ClientNum^.FocusItem(LoCation(ClientNum,s,ProdagaWindow))
 Else ClientNum^.FocusItem(0);

 Dlg^.Insert(ClientNum);
 ClientNum^.HelpCtx:=$E011;

  R.Assign(1, 18, 11, 19);
  Dlg^.Insert(New(PLabel, Init(R, '~Д~оступны:', ClientNum)));
  Dlg^.Insert(Control);
 End;
If Cod=kbF4 Then
 Begin
  R.Assign(52, 1, 57, 2);
  Control := New(PColoredText, Init(R, 'Код:', $3E));
  Dlg^.Insert(Control);
  R.Assign(57, 1, 61, 2);
  ClKod:=ClientElement.Kod;
  Control := New(PColoredText, Init(R, ClientElement.Kod,$3E));
  Dlg^.Insert(Control);
 End;

R.Assign(3, 16, 11, 17);
ControlOpt := New(PCheckboxes, Init(R,
  NewSItem('Опт', Nil)));
If Not (StrToInt(CurrentPassword)=0) Then
ControlOpt^.Options := ControlOpt^.Options and not ofSelectable;
Dlg^.Insert(ControlOpt);
ControlOpt^.SetData(ClientElement.Opt);

Dlg^.SelectNext(False);
NoInfo;

c:=Desktop^.ExecView(Dlg);
If c<>cmCancel Then
 Begin
    Dlg^.GetData(ClientElement);
    ControlOpt^.GetData(ClientElement.Opt);
    DelSpaceRight(ClientElement.Name);
    DelSpace(ClientElement.Test_Srok);
    MyStr(StrToReal(ClientElement.Prozent),CLitr,CMantissa,ClientElement.Prozent);
    DelSpace(ClientElement.Prozent);
    If Cod=kbF4 Then ClientElement.Kod:=ClKod;
(*
    If VidClienta  And (ClientElement.Debit=1) Then
    Begin
    j:=0;
    For c:=1 To CPunkt Do
    Begin
     j:=j+StrToInt(ClientElement.Punkt[c]);
    End;

    If j=0 Then
     Begin
    MessageBox(#3^M+#3'Нет торговых точек !',nil,mfError+mfCancelButton);
 {
If Cod=kbGrayPlus Then
  Begin
   s:=ClientNum^.GetText(ClientNum^.Focused,ClientNum^.List^.Count);
   s:=Copy(s,1+CClient+1,CClientKod);
  ClientNum^.NewList(Nil);
  Dispose(ClientNum,Done);
  End;
  Dispose(Control,Done);
  Dispose(Dlg,Done);
    Goto 1;
}
    End;
    End;
*)
    DelSpaceRight(ClientElement.Messages);

    DelSpace(ClientElement.SrokLizensia);
(*
    If ClientVid=0 Then
    Begin
    If (ClientElement.SrokLizensia[0]<>#0) Or (DefaultLizensia=1) Then
     Begin
      If Not(TestDate(ClientElement.SrokLizensia,k)) Then
       Begin
        MessageBox(^M+#3'Недопустимое значение срока действия лицензии ('+ClientElement.SrokLizensia+')!',nil,
           mfError+mfCancelButton);
       End;
     End;
    End;{ClientVid=0}
*)

    If ClientElement.Name[0]=#0 Then
   Begin
    MessageBox(^M+#3'Недопустимое имя клиента!',nil,mfError+mfCancelButton);
If Cod=kbGrayPlus Then
  Begin
   s:=ClientNum^.GetText(ClientNum^.Focused,ClientNum^.List^.Count);
   s:=Copy(s,1+CClient+1,CClientKod);
  ClientNum^.NewList(Nil);
  Dispose(ClientNum,Done);
  End;
  Dispose(Control,Done);
  Dispose(Dlg,Done);
    Goto 1;
   End;

    If ClientElement.FullName[0]=#0 Then
   Begin
    MessageBox(^M+#3'Недопустимое полное наименование клиента!',nil,mfError+mfCancelButton);
If Cod=kbGrayPlus Then
  Begin
   s:=ClientNum^.GetText(ClientNum^.Focused,ClientNum^.List^.Count);
   s:=Copy(s,1+CClient+1,CClientKod);
  ClientNum^.NewList(Nil);
  Dispose(ClientNum,Done);
  End;
  Dispose(Control,Done);
  Dispose(Dlg,Done);
    Goto 1;
   End;

  C:=IOResult;

If Cod=kbGrayPlus Then
  Begin
   s:=ClientNum^.GetText(ClientNum^.Focused,ClientNum^.List^.Count);
   s:=Copy(s,1+1,CClientKod);
  end;

  {Если добавляем нового клиента то блокируем выбранный код}
  If Cod=kbGrayPlus Then
  Begin
   If Not(TestEmployClientAndLock(0,ClientVid,s)) Then
    Begin
     Beep;
     DInfoMsg('Не могу заблокировать клиента с кодом '+s+'... Попробуйте изменить код!');
     Application^.ClearEvent(Event);
     Application^.ClearEvent(Event);
      repeat
       Application^.GetEvent(Event);
      until (Event.What <> evNothing);
     NoInfoMsg;
     Application^.ClearEvent(Event);
     Dispose(ClientNum,Done);
     Dispose(Control,Done);
     Dispose(ControlOpt,Done);
     Dispose(Dlg,Done);
     Goto 1;
    End;
  End;

  {исходим из того что блокировка удалась}

   UpStr(ClientElement.Name);
   UpStr(ClientElement.FullName);
   UpStr(ClientElement.Adress);
   UpStr(ClientElement.INN);
   UpStr(ClientElement.R_Sh);
   UpStr(ClientElement.Gde);
   UpStr(ClientElement.Gorod);
   UpStr(ClientElement.Okonh);
   UpStr(ClientElement.Okpo);
   UpStr(ClientElement.Enviropment);
   UpStr(ClientElement.Telefon);
   ClientElement.Employ:=True;
   ClientElement.Stat:=False;
   ClientElement.Locked:=True;

   If Cod=kbGrayPlus Then ClientElement.Kod:=s;

   If ClientVid=0 Then
   Begin
   If Cod=kbGrayPlus Then
    Begin
     ClientElement.LockTime :=False;
    End
   Else
       Begin
        ClientElement.LockTime :=PrevLock;
       End;
   End
   Else
      Begin
        ClientElement.LockTime :=False;
      End;



  {если не удалось записать информацию}
  If Not (WriteLockClient(0,ClientVid,ClientElement)) Then
    Begin
     If Cod=kbGrayPlus Then Dispose(ClientNum,Done);
     Dispose(Control,Done);
     Dispose(Dlg,Done);
     Repeat
     Until (SetClientUnLock(s,0,ClientVid));
     Goto 1;
    End;

  If Cod=kbGrayPlus Then
  Begin
   AddProtocol('Добавление нового клиента:'+ClientElement.Name+' ('+s+')','','');
   Repeat
   Until (SetClientUnLock(s,0,ClientVid));
  End
  Else
   AddProtocol('Корректировка данных клиента:'+ClientElement.Name+' ('+ClientElement.Kod+')','','');
  AddClient:=True;

 End;

If Cod=kbGrayPlus Then
  Begin
  ClientNum^.NewList(Nil);
  Dispose(ClientNum,Done);
  End;
  Dispose(Control,Done);
  Dispose(ControlOpt,Done);
  Dispose(Dlg,Done);

  PrevClient[0]:=#0;
end;


Function AddRazdel( Cod:Integer; Var RazdelElement:RazdelType):Boolean;
Label 1;
var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  ControlProz: PView;
  ControlProzSF: PView;
  ControlFas:PView;
  s,ss : TEnjoyStr;
  c,Count,IORez: Word;
  l : Byte;
  Inp : PSkidkaType;
  f : File Of SkidkaType;
  skf : SkidkaType;
  f1 : File Of BazType;
  BBB : BazType;
  fGroup: text;
  ll: longint;

procedure GrayPlusAndDone;
Begin
If Cod=kbGrayPlus Then
  Begin
   s:=RazdelNum^.GetText(RazdelNum^.Focused,RazdelNum^.List^.Count);
   s:=Copy(s,1+CRazdel+1,CRazdelKod);
  RazdelNum^.NewList(Nil);
  Dispose(RazdelNum,Done);
  End;
     Dispose(Control,Done);
     Dispose(Dlg,Done);
end;


begin

ClearFind;
If Not(TestOpenDate1(FDate)) Then
   Begin
    MessageBox(#3^M+#3'Доступ к данным за '+FDate+' заблокирован!',Nil,mfError+mfCancelButton);
    AddRAzdel:=False;
    Exit;
   End;
C:=IOResult;
AddRazdel:=False;
If Not(Password(1)) Then Exit;
Assign(RazdelFile,Path.ToRazdel+'Razdel.db');
Reset(RazdelFile);
C:=IOResult;
If C<>0 Then
Begin
 MessageBox(^M+#3'Ошибка доступа к файлу разделов!',nil,mfError+mfCancelButton);
 AddRazdel:=False;
 Exit;
End;
{AInfo('Читаю список разделов...');}
 Case Cod Of
  kbGrayPlus:Begin
     RazdelElement.Employ:=True;
     While Not(Eof(RazdelFile)) And (RazdelElement.Employ) Do
     Read(RazdelFile,RazdelElement);
     If Eof(RazdelFile) And (RazdelElement.Employ) Then
      Begin
       NoInfo;
       MessageBox(#3^M+#3'Свободных позиций для разделов - нет !',nil,mfWarning+mfCancelButton);
       Close(RazdelFile);
       AddRazdel:=False;
       Exit;
      End;
      s:=RazdelElement.Kod;
      RazdelElement.Name[0]       :=#0;
      RazdelElement.Designation[0]:=#0;
      RazdelElement.EnableLitr    :=0;
      RazdelElement.BeginStartSeason[0]:=#0;
      RazdelElement.BeginStopSeason[0]:=#0;
      RazdelElement.EndStartSeason[0]:=#0;
      RazdelElement.EndStopSeason[0]:=#0;
      RazdelElement.MinNazenka:='1.000';
      RazdelElement.Locked          :=False;
      RazdelElement.Group:='00';
    End;
  kbF4:Begin
     s:=Copy(Razdel^.GetText(Razdel^.Focused,Razdel^.List^.Count),1+CRazdel+1,CRazdelKod);
     Repeat
     Read(RazdelFile,RazdelElement);
     Until (Eof(RazdelFile)) Or (RazdelElement.Kod=s);
     If Eof(RazdelFile) And (RazdelElement.Kod<>s) Then
      Begin
       NoInfo;
       MessageBox(#3^M+#3'Раздел в базе не найден!',nil,mfError+mfCancelButton);
       Close(RazdelFile);
       AddRazdel:=False;
       Exit;
      End;
    End;
  Else;
 End;
Close(RazdelFile);
1:
If Cod=kbGrayPlus Then
Begin
R.Assign(1, 1, 77, 23);
New(Dlg, Init(R, 'Добавить раздел'))
End
Else
Begin
R.Assign(1, 1, 77, 20);
New(Dlg, Init(R, 'Изменить раздел'));
End;
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.Palette := dpCyanDialog;
Dlg^.HelpCtx:=$E011;

R.Assign(2, 2, 24, 3);
Control := New(PInputLine, Init(R, 20));
Dlg^.Insert(Control);

  R.Assign(24, 2, 27, 3);
  Dlg^.Insert(New(PHistory, Init(R, PInputline(Control), 10)));

  R.Assign(1, 1, 23, 2);
  Dlg^.Insert(New(PLabel, Init(R, '~Н~аименование раздела:', Control)));


R.Assign(28, 2, 38, 3);
Control := New(PInputLine, Init(R, 8));
Dlg^.Insert(Control);

  R.Assign(25, 1, 39, 2);
  Dlg^.Insert(New(PLabel, Init(R, '~О~черед.прайс:', Control)));

R.Assign(41, 2, 53, 3);
Control := New(PCheckboxes, Init(R,
  NewSItem('Литраж', Nil)));
Dlg^.Insert(Control);

R.Assign(54, 2, 62, 3);
Control := New(PInputLine, Init(R, (CLitr+1)));
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));

R.Assign(14, 16, 24, 17);
Control := New(PInputLine, Init(R, (CDate)));
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PPXPictureValidator, Init(DateFiltr, True));

  R.Assign(1, 16, 14, 17);
  Dlg^.Insert(New(PLabel, Init(R, '~Н~ач.сезона:', Control)));


R.Assign(30, 16, 40, 17);
Control := New(PInputLine, Init(R, (CDate)));
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PPXPictureValidator, Init(DateFiltr, True));

  R.Assign(24, 16, 30, 17);
  Dlg^.Insert(New(PLabel, Init(R, ' ~п~о: ', Control)));

R.Assign(14, 17, 24, 18);
Control := New(PInputLine, Init(R, (CDate)));
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PPXPictureValidator, Init(DateFiltr, True));

  R.Assign(1, 17, 14, 18);
  Dlg^.Insert(New(PLabel, Init(R, '~К~он.сезона:', Control)));


R.Assign(30, 17, 40, 18);
Control := New(PInputLine, Init(R, (CDate)));
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PPXPictureValidator, Init(DateFiltr, True));

  R.Assign(24, 17, 30, 18);
  Dlg^.Insert(New(PLabel, Init(R, ' ~п~о: ', Control)));


For c:=0 To 11 Do
Begin
R.Assign(2, 4+c, 19, 5+c);
Control := New(PInputLine, Init(R, 15));
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));

R.Assign(20, 4+c, 28, 5+c);
Control := New(PInputLine, Init(R, (CLitr+1)));
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));

R.Assign(29, 4+c, 37, 5+c);
Control := New(PInputLine, Init(R, (CLitr+1)));
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));
End;


For c:=12 To 23 Do
Begin
R.Assign(30+8, 4+(c-12), 47+8, 5+(c-12));
Control := New(PInputLine, Init(R, 15));
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));

R.Assign(48+8, 4+(c-12), 56+8, 5+(c-12));
Control := New(PInputLine, Init(R, (CLitr+1)));
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));

R.Assign(57+8, 4+(c-12), 65+8, 5+(c-12));
Control := New(PInputLine, Init(R, (CLitr+1)));
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));

End;

R.Assign(43, 17, 65, 18);
ControlGroup := New(PInputLine, Init(R, 20));
Dlg^.Insert(ControlGroup);

  R.Assign(65, 17, 67, 18);
  Dlg^.Insert(New(PHistory, Init(R, PInputline(ControlGroup), 17)));

  R.Assign(43, 16, 65, 17);
  Dlg^.Insert(New(PLabel, Init(R, 'Товарная группа:', ControlGroup)));

Dlg^.SetData(RazdelElement);

ss:=GetGroupName(RazdelElement.Group);

ControlGroup^.SetData(ss);

If Cod = kbGrayPlus  Then
Begin
R.Assign(35, 17, 36, 21);
Control := New(PScrollBar, Init(R));
Dlg^.Insert(Control);

R.Assign(1, 17, 35, 21);
 RazdelNum := New(PBox, Init(R, 6, PScrollbar(Control)));
 RazdelNum^.NewList(New(PTextCollection, Init(0,1)));
 Assign (RazdelFile,Path.ToRazdel+'Razdel.db');
 Reset (RazdelFile);
 While Not(Eof(RazdelFile)) Do
  Begin
   Read(RazdelFile,RazdelElement);
   If Not(RazdelElement.Employ) Then
   Begin
   RazdelNum^.List^.Insert(NewStr('│'+RazdelElement.Kod));
   RazdelNum^.SetRange(RazdelNum^.List^.Count);
   RazdelNum^.FocusItem(RazdelNum^.List^.Count);
   End;
  End;
 System.Close(RazdelFile);
 If Cod=kbF4 Then RazdelNum^.FocusItem(LoCation(RazdelNum,s,ProdagaWindow))
 Else RazdelNum^.FocusItem(0);
 RazdelNum^.HelpCtx:=$E011;

Dlg^.Insert(RazdelNum);
  R.Assign(1, 16, 36, 17);
 Dlg^.Insert(New(PLabel, Init(R, '~Д~оступные коды для нового раздела:', RazdelNum)));

 End;
If Cod=kbF4 Then
 Begin
  R.Assign(41, 1, 53, 2);
  Control := New(PColoredText, Init(R, 'Код раздела:', $3E));
  Dlg^.Insert(Control);
  R.Assign(53, 1, 55, 2);
  Control := New(PColoredText, Init(R, RazdelElement.Kod, $3E));
  Dlg^.Insert(Control);
 End;



R.Assign(64, 2, 72, 3);
ControlProz := New(PInputLine, Init(R, (CLitr+1)));
Dlg^.Insert(ControlProz);
  PInputLine(ControlProz)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));

R.Assign(63, 1, 73, 2);
 Dlg^.Insert(New(PLabel, Init(R, 'Наценка,%:', ControlProz)));

ControlProz^.SetData(RazdelElement.DostProz);

R.Assign(64, 3, 72, 4);
ControlProzSF := New(PInputLine, Init(R, (CLitr+1)));
Dlg^.Insert(ControlProzSF);
  PInputLine(ControlProzSF)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));

R.Assign(45, 3, 62, 4);
 Dlg^.Insert(New(PLabel, Init(R, 'Наценка по СФ,%:', ControlProzSF)));

ControlProzSF^.SetData(RazdelElement.Skidka[CShkala].MinNaz);

R.Assign(2, 4, 77, 5);
Control := New(PColoredText, Init(R, 'Сумма, руб.       Скидка,% Мин.нац% Сумма, руб'+
     '.       Скидка,% Миннац%', $3E));
Dlg^.Insert(Control);

Dlg^.SelectNext(False);
NoInfo;

c:=Desktop^.ExecView(Dlg);

If c<>cmCancel Then
 Begin
  Dlg^.GetData(RazdelElement);
  DElSpaceRight(RazdelElement.Name);
  If RazdelElement.Name[0]=#0 Then
   Begin
    MessageBox(#3^M+#3'Недопустимое имя раздела!',nil,mfError+mfCancelButton);
    GrayPlusAndDone;
    Goto 1;
   End;
  For c:=1 To CShkala Do
   Begin
      If StrToReal(RazdelElement.Skidka[c].Up)=0 Then RazdelElement.Skidka[c].Proz:='1.0000';
      If StrToReal(RazdelElement.Skidka[c].Proz)=0 Then RazdelElement.Skidka[c].Up:='0.00';
      Str(StrToReal(RazdelElement.Skidka[c].Up):CIZena:CMantissa,RazdelElement.Skidka[c].Up);
      DelSpace(RazdelElement.Skidka[c].Up);
      Str(StrToReal(RazdelElement.Skidka[c].Proz):(CLitr+1):CMantissa+2,RazdelElement.Skidka[c].Proz);
      DelSpace(RazdelElement.Skidka[c].Proz);
      Str(StrToReal(RazdelElement.Skidka[c].MinNaz):(CLitr+1):CMantissa+2,RazdelElement.Skidka[c].MinNaz);
      DelSpace(RazdelElement.Skidka[c].MinNaz);
    For l:=1 To CShkala Do
     Begin
      If (StrToReal(RazdelElement.Skidka[c].Up)=StrToReal(RazdelElement.Skidka[l].Up))
         And (c<>l) And (StrToReal(RazdelElement.Skidka[c].Up)<>0)
         And (StrToReal(RazdelElement.Skidka[c].Proz)<>StrToReal(RazdelElement.Skidka[l].Proz)) Then
         Begin
          GrayPlusAndDone;
          MessageBox(#3^M+#3'Дублирование границы шкалы скидок!',Nil,mfError+mfCancelButton);
          Goto 1;
         End;
     End;


    If StrToReal(RazdelElement.Skidka[c].Proz)>99.99 Then
     Begin
      GrayPlusAndDone;
      Goto 1;
     End;

   End;
  C:=IOResult;
  Assign(RazdelFile,Path.ToRazdel+'Razdel.db');
  Reset(RazdelFile);
  C:=IOResult;
  If C<>0 Then
   Begin
    MessageBox(#3^M+#3'Ошибка доступа к файлу разделов !',nil,mfError+mfCancelButton);
    AddRazdel:=False;
    GrayPlusAndDone;
    Goto 1;
   End;
   UpStr(RazdelElement.Name);
   UpStr(RazdelElement.Designation);
   Str(StrToReal(RazdelElement.MinNAzenka):(CLitr+1):CMantissa+2,RazdelElement.MinNAzenka);
   DelSpace(RazdelElement.MinNAzenka);
   RazdelElement.Employ:=True;
   RazdelElement.Locked  :=False;
If Cod=kbGrayPlus Then
  Begin
   s:=RazdelNum^.GetText(RazdelNum^.Focused,RazdelNum^.List^.Count);
   s:=Copy(s,1+1,CRazdelKod);
   AddProtocol('Добавление нового раздела:'+RazdelElement.Name+' ('+s+')','','');
  End
  Else
   AddProtocol('Корректировка раздела:'+RazdelElement.Name+' ('+s+')','','');
   RazdelElement.Kod:=s;




{сортировка скидок}
   New(Inp,Init);
   For c:=1 To CShkala Do  Inp^.Dat.Skidka[c]:=RazdelElement.Skidka[c];

   If Not(SortSkidka(Inp)) Then
   MessageBox(^M+#3'Ошибка при сортировке скидок!',Nil,mfError+mfCancelButton)
   Else
   For c:=1 To CShkala Do  RazdelElement.Skidka[c]:=Inp^.Dat.Skidka[c];
   Dispose(Inp,Done);
{конец сортировки скидок}

ControlProz^.GetDAta(RazdelElement.DostProz);
ControlProzSF^.GetDAta(RazdelElement.Skidka[CShkala].MinNaz);
ss:='';
ControlGroup^.GetData(ss);
ss:=GetGroupKod(ss);
rformatzerro(ss,CRazdelKod);
RazdelElement.Group:=ss;

    If Not(TestDate(RazdelElement.BeginStartSeason,Ll)) Then
    Begin
     GrayPlusAndDone;
     MessageBox(^M+#3'Ошибка при вводе начала сезона (1)!',Nil,mfError+mfCancelButton);
     Goto 1;
    End;

   If Not(TestDate(RazdelElement.BeginStopSeason,Ll)) Then
    Begin
    GrayPlusAndDone;
    MessageBox(^M+#3'Ошибка при вводе начала сезона (2)!',Nil,mfError+mfCancelButton);
     Goto 1;
    End;

   If Not(TestDate(RazdelElement.EndStartSeason,Ll)) Then
    Begin
     GrayPlusAndDone;
     MessageBox(^M+#3'Ошибка при вводе конца сезона (1)!',Nil,mfError+mfCancelButton);
     Goto 1;
    End;

   If Not(TestDate(RazdelElement.EndStopSeason,Ll)) Then
    Begin
    GrayPlusAndDone;
    MessageBox(^M+#3'Ошибка при вводе конца сезона (2)!',Nil,mfError+mfCancelButton);
     Goto 1;
    End;



   Seek(RazdelFile,GetFileLocation3(s){-1});
   Write(RazdelFile,RazdelElement);
   Close(RazdelFile);
   AddRazdel:=True;

   {автоматическое отслеживание индекса скидок}
   Assign(f,Path.ToSkidki+RazdelElement.Kod+'.skl');
   count:=IOResult;
   Reset(f);
   count:=IOResult;
   If Count<>0 Then
   Begin {нужно создавать файл}
    MessageBox(#3+'Таблицы скидок у наименований '+
   'раздела "'+RazdelElement.Name+
   '" не существуют, сейчас программа их автоматически создаст!',Nil,mfCancelButton);
    count:=IOResult;
    Rewrite(f);
    count:=IOResult;
     Count:=0;
     For count:=0 to 999 Do
      Begin
       For c:=1 To CShkala Do skf.Skidka[c]:=RazdelElement.Skidka[c];
       Str(Count:3,S);
       RFormatZerro(s,3);
       skf.BazKod:=RazdelElement.Kod+s;
       skf.Time:=Times;
       skf.Date:=FDate;
       {Skf.MinHand:=RAzdelElement.MinNAzenka;}
       skf.Caption:=CurrentPassword;
       Seek(f,FileSize(f));
       Write(f,skf);
      End;
    Close(f);
   End{нужно создавать файл}
   Else {создание файла ненужно}
    Begin
     Close(f);
If StrToInt(CurrentPassword)=0 Then
Begin
   If MessageBox(#3+'Изменять таблицы скидок у наименований '+
   'раздела "'+RazdelElement.Name+
   '" ?',Nil,mfOkCancel)=cmOk Then
    Begin
     Assign(f,Path.ToSkidki+RazdelElement.Kod+'.skl');
     Reset(f);
     Assign(f1,Path.ToNAme+RazdelElement.Kod+'.id');
     Reset(f1);
     Count:=0;

     While Not(Eof(f1)) Do
      Begin


       Repeat
       Pause(1);
       Until NetCall.Lock(f,FilePos(f)*SizeOf(SkidkaType),SizeOf(SkidkaType));

       Repeat
       Pause(1);
       Until NetCall.Lock(f1,FilePos(f1)*SizeOf(BazType),SizeOf(BazType));

       Read(f,skf);
       Read(f1,bbb);

       For c:=1 To CShkala Do skf.Skidka[c]:=RazdelElement.Skidka[c];
       Str(Count:3,S);
       RFormatZerro(s,3);
       BBB.MinNazenka:=RAzdelElement.MinNAzenka;
       skf.BazKod:=RazdelElement.Kod+s;
       skf.Time:=Times;
       skf.Date:=FDate;
       skf.Caption:=CurrentPassword;
       {Skf.MinHand:=RAzdelElement.MinNAzenka;}
       Seek(f,FilePos(f)-1);
       Write(f,skf);

       Seek(f1,FilePos(f1)-1);
       Write(f1,BBB);

       Repeat
        NetCall.UnLock(f,(FilePos(f)-1)*SizeOf(SkidkaType),SizeOf(SkidkaType));
       Until (DosError=0);

       Repeat
        NetCall.UnLock(f1,(FilePos(f1)-1)*SizeOf(BazType),SizeOf(BazType));
       Until (DosError=0);

       Inc(Count);
      End;
     Close(f);
     Close(f1);

     AddProtocol('Корректировка скидок у наименований раздела ('+RazdelElement.Name+') ('+s+')'^M+
                 'в соответствии со скидками раздела {Очень важно}','','');
     MessageBox(#3^M+#3+'Изменения проведены!',Nil,mfInformation+mfCancelButton);
End;{StrToInt=0}
    End;{создание файла ненужно}

    End;
 End;


If Cod=kbGrayPlus Then
  Begin
  RazdelNum^.NewList(Nil);
  Dispose(RazdelNum,Done);
  End;
  Dispose(Control,Done);
  Dispose(Dlg,Done);

end;


Procedure DrawName;
Var s: String[CPack];
    R : TRect;
Begin
    NameWin^.GetData(Element^.Dat);
    COntrolName^.SetData(Element^.Dat.Name);
End;



Procedure RenameList(Element:BazType;Const P : PBox);
 Var i : Byte;
     s1,ws,s : string[150];
Begin
Format(Element.Name,CNAme);
Format(Element.Litr,CLitr);
Format(Element.InPack,CInPack);
If (P^.list^.Count)>=1 Then
 For i:=0 To P^.List^.Count-1 Do
  Begin
   s:=P^.GetText(i,P^.List^.Count-1);
   If Pos(Element.BazKod,s)>0 Then
    Begin
     ws:=Copy(s,1+CName+1,CArtikul);
     P^.FocusItem(LoCation(P,ws,ProdagaWindow));
     P^.List^.AtFree(P^.Focused);
     P^.SetRange(P^.List^.Count);
     System.Delete(s,1,CName+1+CArtikul+1+CLitr+1+CInPack);
     System.Insert(Element.Name+'│'+Element.BazKod+
     '│'+Element.Litr+'│'+Element.InPack,s,1);
     P^.List^.Insert(NewStr(S));
     P^.SetRange(P^.List^.Count);
     P^.FocusItem(LoCation(P,ws,ProdagaWindow));
    End;
  End;
End;


Procedure TNameWindow.AddBazINI( Cod:Integer; st:ArtikulStr;Var Res:Boolean);
Label 1;
var
  R : TRect;
  Control : PView;
  ControlProz: PView;
  ControlVol: PView;
  ControlFas: PView;
  sFas: string[CLitr];
  s,s1 : string;
  Oper : StrName;
  c: Word;
  skl : PSkladType;
  Regim : Boolean;
  Event : TEvent;
  j : Byte;
  EditNaz : Boolean;
  EditName : Boolean;
  ControlAkzEnable:PView;
  ControlOKol:PView;
  ControlRKol:PView;
  ControlOZena:PView;
  ControlRZena:PView;
  ControlRealiz:PView;
  Akzia: PAkziaZena;
  AkziaZenaFile: file of AkziaZena;
  fsize: longint;
begin

ClearFind;
{If Cod=kbF4 Then}

{
If Not(Password(1)) Then
 Begin
  Res:=False;
  Exit;
 End;
}

{Res:=True;}

If Not(TestOpenDate1(FDate)) Then
   Begin
    MessageBox(#3^M+#3'Доступ к данным за '+FDate+' заблокирован!',Nil,mfError+mfCancelButton);
    Res:=False;
    Exit;
   End;

Regim :=True;
EditNAz:=True;
EditName:=True;
Res:=False;


If cod=kbGrayPlus Then
 Begin
  If Not Password(8) Then
   Begin
    Exit;
   End
   Else EditNAme:=True;
 End;

If cod=kbF4 Then
 Begin
  If Not Password(8) Then
   Begin
    EditNAme:=False;
   End;
 End;

If Not(Password(4)) Then
 Begin
  Regim:=False;
 End;

If Not(Password(3)) Then
 Begin
  EditNAz:=False;
 End;

{If Cod=kbGrayPlus Then
MessageBox(^M+#3'Не забудьте согласовать код нового товара с центральным офисом !',Nil,mfWarning+mfCancelButton);}

C:=IOResult;
Res:=False;

{s:=Baz^.GetText(Baz^.Focused,Baz^.List^.Limit);
s:=Copy(s,1+CName+1,CRazdelKod);}

s1:=st;
Assign(ElementFile,Path.ToName+st+'.id');
Reset(ElementFile);
C:=IOResult;
If C<>0 Then
Begin
 MessageBox(^M+#3'Ошибка доступа к файлу '+s+'.id!',nil,mfError+mfCancelButton);
 Res:=False;
 Exit;
End;
{AInfo('Читаю информацию о товарах...');}
 Case Cod Of
  kbGrayPlus:Begin
     Element^.Dat.Employ:=True;
     While Not(Eof(ElementFile)) And (Element^.Dat.Employ) Do
     Begin
      ReadBaz(ElementFile,Element^.Dat);
     End;
     If Eof(ElementFile) And (Element^.Dat.Employ) Then
      Begin
       NoInfo;
       MessageBox(^M+#3'Свободных позиций для товара - нет !',nil,mfWarning+mfCancelButton);
       System.Close(ElementFile);
       Res:=False;
       Exit;
      End;
      with Element^.Dat do
      begin
        s:=BazKod;
        Name[0]:=#0;
        Name2[0]:=#0;
        Market:=0;
        Marker[0]:=#0;
        MinNazenka:='1.000';
        Minimum:='5';
        FullName[0]:=#0;
        FullName2[0]:=#0;
        Litr:='00.00';
        InPack[0]:=#0;
        EnableOtdel:=1;
        Stat :=False;
        Locked :=False;
        Caption:=CurrentPassword;
        VidNalog:=2;
        Nalog:='0.00';
        VidNDS:=0;
        NDS:='18.00';
        Mera:=0;
        Vol:='0.00';
        ZapretOpt:=false;
        Realiz:=false;
      end;
    End;
  kbF4:Begin
     s:=Copy(Baz^.GetText(Baz^.Focused,Baz^.List^.Count),1+CName+1,CArtikul);

     Repeat
      ReadBaz(ElementFile,Element^.Dat);
     Until (Eof(ElementFile)) Or (Element^.Dat.BazKod=s);

     If Eof(ElementFile) And (Element^.Dat.BazKod<>s) Then
      Begin
       MessageBox(^M+#3'Товар в базе не найден!',nil,mfError+mfCancelButton);
       System.Close(ElementFile);
       Res:=False;
       Exit;
      End;
      DelSpace(Element^.Dat.Nalog);
    End;
  Else;
 End;
System.Close(ElementFile);

1:
MySTr(StrToReal(Element^.Dat.Litr),CLitr,CMantissa,Element^.Dat.Litr);
DelSpace(Element^.Dat.Litr);

If Cod=kbGrayPlus Then
Begin
R.Assign(10, 2, 71, 21);
New(NameWin, Init(R, 'Добавить наименование товара'))
End
Else
Begin
R.Assign(10, 4, 71, 19);
New(NameWin, Init(R, 'Изменить наименование товара'));
End;
NameWin^.Options := NameWin^.Options or ofCenterX or ofCenterY;
NameWin^.Palette := dpCyanDialog;
NameWin^.HelpCtx:=$E011;


R.Assign(1, 3, 29, 4);
ControlLine := New(PInputLine, Init(R, CName));
NameWin^.Insert(ControlLiNe);

  R.Assign(29, 3, 32, 4);
  NameWin^.Insert(New(PHistory, Init(R, PInputline(ControlLine), 13)));

  R.Assign(1, 2, 21, 3);
  NameWin^.Insert(New(PLabel, Init(R, 'Наи~м~еновние товара:', ControlLine)));

  R.Assign(1, 4, 29, 5);
  ControlLine2 := New(PInputLine, Init(R, CName));
  NameWin^.Insert(ControlLiNe2);

If Not(EditName) Then
Begin
ControlLine^.Options := ControlLine^.Options and not ofSelectable;
ControlLine2^.Options := ControlLine2^.Options and not ofSelectable;
End;


If Cod=kbF4 Then
 Begin
  R.Assign(1, 1, 12, 2);
  Control := New(PColoredText, Init(R, 'Код товара:', $3E));
  NameWin^.Insert(Control);

  R.Assign(12, 1, 17, 2);
  Control := New(PColoredText, Init(R, s, $3E));
  NameWin^.Insert(Control);
 End;



R.Assign(1, 6, 29, 7);
ControlName := New(PInputLine, Init(R, CName));
NameWin^.Insert(ControlName);

  R.Assign(29, 6, 32, 7);
  NameWin^.Insert(New(PHistory, Init(R, PInputline(ControlName), 13)));

  R.Assign(1, 5, 22, 6);
  NameWin^.Insert(New(PLabel, Init(R, '~П~олное наименование:', ControlName)));



R.Assign(1, 7, 29, 8);
ControlName2 := New(PInputLine, Init(R, CName));
NameWin^.Insert(ControlName2);

If Not(EditName) Then
Begin
ControlName^.Options := ControlName^.Options and not ofSelectable;
ControlName2^.Options := ControlName2^.Options and not ofSelectable;
End;




R.Assign(32, 1, 39, 2);
Control := New(PInputLine, Init(R, CArtikul));
NameWin^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0']));

If Not(EditName) Then
Begin
Control^.Options := Control^.Options and not ofSelectable;
End;



  R.Assign(24, 1, 32, 2);
  NameWin^.Insert(New(PLabel, Init(R, '~М~иним.:', Control)));


R.Assign(40, 1, 47, 2);
Control := New(PInputLine, Init(R, CLitr+1));
NameWin^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));

If Not(EditNAz) Then
Control^.Options := Control^.Options and not ofSelectable;



R.Assign(32, 3, 39, 4);
Control := New(PInputLine, Init(R, CLitr));
NameWin^.Insert(Control);
  PInputLine(Control)^.Validator := New(PPXPictureValidator, Init('#[[#][.[#[#]]]]', True));

  R.Assign(31, 2, 39, 3);
  NameWin^.Insert(New(PLabel, Init(R, ' Масса:', Control)));


If Not(EditName) Then
Begin
Control^.Options := Control^.Options and not ofSelectable;
End;



R.Assign(40, 3, 45, 4);
Control := New(PInputLine, Init(R, 3));
NameWin^.Insert(Control);
  PInputLine(Control)^.Validator := New(PRangeValidator, Init(1, 999));

  R.Assign(41, 2, 50, 3);
  NameWin^.Insert(New(PLabel, Init(R, '~Ф~асовка:', Control)));


R.Assign(40, 4, 45, 5);
Control := New(PInputLine, Init(R, CInPack));
NameWin^.Insert(Control);

  R.Assign(32, 4, 40, 5);
  NameWin^.Insert(New(PLabel, Init(R, 'М~а~ркер:', Control)));


If Not(EditName) Then
Begin
Control^.Options := Control^.Options and not ofSelectable;
End;



R.Assign(32, 5, 45, 6);
Control := New(PCheckboxes, Init(R,
  NewSItem('Про~д~ажа', Nil)));



If Not(Regim) Then
Control^.Options := Control^.Options and not ofSelectable;
NameWin^.Insert(Control);


R.Assign(2, 9, 15, 12);
Control := New(PColoredText, Init(R, '', $3E));
Control^.Options := Control^.Options or ofFramed;
NameWin^.Insert(Control);


R.Assign(2, 9, 15, 12);
ControlVidNalog := New(PRadioButtons, Init(R,
  NewSItem('~И~мпорт',
  NewSItem('~О~теч.',
  NewSItem('Про~ч~ее', Nil)))));
NameWin^.Insert(ControlVidNalog);

  R.Assign(2, 8, 13, 9);
  NameWin^.Insert(New(PLabel, Init(R, 'Ставка НП:', ControlVidNalog)));

If Not(EditName) Then
Begin
ControlVidNalog^.Options := ControlVidNalog^.Options and not ofSelectable;
End;



R.Assign(7, 12, 14, 13);
ControlNalog := New(PInputLine, Init(R, CLitr));
If Element^.Dat.VidNAlog in [0,1] Then
  ControlNAlog^.Options := ControlNAlog^.Options and not ofSelectable
 Else
  ControlNAlog^.Options := ControlNAlog^.Options or ofSelectable;

NAmeWin^.Insert(ControlNalog);
  PInputLine(ControlNalog)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));

  R.Assign(2, 12, 7, 13);
  NameWin^.Insert(New(PLabel, Init(R, 'Н/П:', ControlNalog)));


If Not(EditName) Then
Begin
ControlNAlog^.Options := ControlNAlog^.Options and not ofSelectable;
End;

R.Assign(20, 9, 33, 12);
Control := New(PStaticText, Init(R, ''));
Control^.Options := Control^.Options or ofFramed;
NameWin^.Insert(Control);


R.Assign(20, 9, 33, 12);
ControlVidNDS := New(PRadioButtons, Init(R,
  NewSItem(CNDS20,
  NewSItem('~1~0 %   ',
  NewSItem('П~р~очее', Nil)))));
NameWin^.Insert(ControlVidNDS);

  R.Assign(20, 8, 32, 9);
  NameWin^.Insert(New(PLabel, Init(R, 'Ставка НДС:', ControlVidNDS)));

If Not(EditName) Then
Begin
ControlVidNDS^.Options := ControlVidNDS^.Options and not ofSelectable;
End;


R.Assign(25, 12, 32, 13);
ControlNDS := New(PInputLine, Init(R, CLitr));



If Element^.Dat.VidNDS in [0,1] Then
  ControlNDS^.Options := ControlNDS^.Options and not ofSelectable
 Else
  ControlNDS^.Options := ControlNDS^.Options or ofSelectable;

NameWin^.Insert(ControlNDS);
  PInputLine(ControlNDS)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));

  R.Assign(20, 12, 25, 13);
  NameWin^.Insert(New(PLabel, Init(R, '~Н~ДС:', ControlNDS)));

If Not(EditName) Then
Begin
ControlNDS^.Options := ControlNDS^.Options and not ofSelectable;
End;



R.Assign(32, 6, 60, 8);
Control := New(PCheckboxes, Init(R,
  NewSItem('1',
  NewSItem('2',
  NewSItem('~3~',
  NewSItem('~4~',
  NewSItem('~5~',
  NewSItem('~6~',
  NewSItem('~7~',
  NewSItem('~8~',
  Nil))))))))));
NameWin^.Insert(Control);


If Not(Regim) Then
Control^.Options := Control^.Options and not ofSelectable;


{
R.Assign(38, 7, 46, 12);
Control := New(PStaticText, Init(R, ''));
Control^.Options := Control^.Options or ofFramed;
NameWin^.Insert(Control);
}

R.Assign(36, 9, 44, 14);
Control := New(PRadioButtons, Init(R,
  NewSItem('~Ш~т',
  NewSItem('К~г~',
  NewSItem('Мш',
  NewSItem('Л',
  NewSItem('Бл',
  Nil)))))));
NameWin^.Insert(Control);

  R.Assign(36, 8, 44, 9);
  NameWin^.Insert(New(PLabel, Init(R, 'Ед.изм:', Control)));


If Not(EditName) Then
Begin
Control^.Options := Control^.Options and not ofSelectable;
End;

R.Assign(48, 3, 53, 4);
ControlFas := New(PInputLine, Init(R, 4));
NameWin^.Insert(ControlFas);
  PInputLine(ControlFas)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));

R.Assign(45, 3, 47, 4);
NameWin^.Insert(New(PLabel, Init(R, '~/~', ControlFas)));


R.Assign(54, 3, 60, 4);
ControlProz := New(PInputLine, Init(R, CZena));
NameWin^.Insert(ControlProz);
  PInputLine(ControlProz)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));

  R.Assign(50, 2, 61, 3);
  NameWin^.Insert(New(PLabel, Init(R, 'Наценка,%:', ControlProz)));

{R.Assign(47, 3, 55, 4);
ControlProz := New(PInputLine, Init(R, CZena));
NameWin^.Insert(ControlProz);
  PInputLine(ControlProz)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));}
{
  R.Assign(47, 2, 59, 3);
  NameWin^.Insert(New(PLabel, Init(R, 'Наценка,%:', ControlProz)));
}
R.Assign(53, 4, 60, 5);
ControlVol := New(PInputLine, Init(R, CKol));
NameWin^.Insert(ControlVol);

  R.Assign(44, 4, 52, 5);
  NameWin^.Insert(New(PLabel, Init(R, 'Объем:', ControlVol)));



NameWin^.SetData(Element^.Dat);


DelSpace(Element^.Dat.DostProc);
ControlProz^.SetData(Element^.Dat.DostProc);

DelSpace(Element^.Dat.Vol);
ControlVol^.SetData(Element^.Dat.Vol);


   new(skl,init);
   Skl^.Dat.BazKod:=Element^.Dat.BazKod;

   GetSkladRecord(Skl);

   BazElement^.Dat:=Skl^.Dat;
   Dispose(Skl,Done);

DelSpace(BazElement^.Dat.Input.Akzis1);
ControlFas^.SetData(BazElement^.Dat.Input.Akzis1);


If Cod = kbGrayPlus  Then
Begin
R.Assign(48, 15, 49, 18);
Control := New(PScrollBar, Init(R));
NameWin^.Insert(Control);

R.Assign(1, 15, 48, 18);
BazNum := New(PBox, Init(R, 6, PScrollbar(Control)));
 BazNum^.NewList(New(PTextCollection, Init(0,1)));
 Assign (ElementFile,Path.ToName+s1+'.id');
 Reset (ElementFile);
 While Not(Eof(ElementFile)) Do
  Begin
  {
   Repeat
   Until NetCall.Lock(ElementFile,FilePos(ElementFile)*SizeOf(BazType),SizeOf(BazType));
  }
   ReadBaz(ElementFile,Element^.Dat);
  {
   Repeat
    NetCall.UnLock(ElementFile,(FilePos(ElementFile)-1)*SizeOf(BazType),SizeOf(BazType));
   Until Doserror=0;
  }
   If Not(Element^.Dat.Employ) Then
   Begin
   Format (Element^.Dat.BazKod,CArtikul);
   BazNum^.List^.Insert(NewStr('│'+Element^.Dat.BazKod));
   BazNum^.SetRange(BazNum^.List^.Count);
   End;
  End;
 System.Close(ElementFile);
 If Cod=kbF4 Then BazNum^.FocusItem(LoCation(BazNum,s,ProdagaWindow))
 Else BazNum^.FocusItem(0);
 BazNum^.HelpCtx:=$E011;

NameWin^.Insert(BazNum);

  R.Assign(1, 14, 48, 15);
 NameWin^.Insert(New(PLabel, Init(R, 'Доступные ~к~оды для наименования товара:', BazNum)));

 End;
{
R.Assign(45, 2, 55, 4);
Control := New(PButton, Init(R, 'Ввод', cmOK, bfDefault));
NameWin^.Insert(Control);
{
R.Assign(45, 3, 55, 5);
Control := New(PButton, Init(R, 'Отмена', cmCancel, bfNormal));
NameWin^.Insert(Control);
}


(*New(Akzia,Init);

Assign(AkziaZenaFile,Path.ToName+copy(Element.BazKod,1,2)+'.akz');
c:=ioresult;
Reset(AkziaZenaFile);
c:=ioresult;
if c<>0 then
begin
 rewrite(AkziaZenaFile);
 c:=ioresult;
 if c=0 then
 begin
  for c:=0 to 100 do write (AkziaZenaFile,Akzia^.Dat);
  system.close(AkziaZenaFile)
 end
 else
 begin
  memcc('Не могу создать файл '+copy(Element.BazKod,1,2)+'.akz');
  exit;
 end;
end;

c:=ioresult;
Reset(AkziaZenaFile);
c:=ioresult;
Seek(AkziaZenaFile,StrToInt(copy(Element.BazKod,3,3)));
c:=ioresult;
read(AkziaZenaFile,Akzia^.Dat);
c:=ioresult;
if c<>0 then
begin
 fsize:=FileSize(AkziaZenaFile);
 Seek(AkziaZenaFile,fsize-1);
 c:=ioresult;
 for c:=FileSize(AkziaZenaFile) to StrToInt(copy(Element.BazKod,3,3))+10
  do write (AkziaZenaFile,Akzia^.Dat);
 Seek(AkziaZenaFile,StrToInt(copy(Element.BazKod,3,3)));
 c:=ioresult;
 read(AkziaZenaFile,Akzia^.Dat);
 c:=ioresult;
end;     *)

R.Assign(45, 9, 60, 10);
ControlAkzEnable:= New(PCheckboxes, Init(R,
NewSItem('Запрет.опт', Nil)));
NameWin^.Insert(ControlAkzEnable);
ControlAkzEnable^.SetData(Element^.Dat.ZapretOpt);

R.Assign(45, 11, 60, 12);
ControlRealiz:= New(PCheckboxes, Init(R,
NewSItem('Реализация', Nil)));
NameWin^.Insert(ControlRealiz);
ControlRealiz^.SetData(Element^.Dat.Realiz);


NameWin^.SelectNext(False);
Noinfo;
c:=Desktop^.ExecView(NameWin);
If c<>cmCancel Then
 Begin
  sFas:='';
  NameWin^.GetData(Element^.Dat);
  DelSpaceRight(Element^.Dat.Name);
  DelSpaceRight(Element^.Dat.fullName);
  DelSpaceRight(Element^.Dat.Marker);
  ControlProz^.GetData(Element^.Dat.DostProc);
  ControlVol^.GetData(Element^.Dat.Vol);
  ControlFas^.GetData(sFas);
  ControlAkzEnable^.GetData(Element^.Dat.ZapretOpt);
  ControlRealiz^.GetData(Element^.Dat.Realiz);
  DelSpaceRight(Element^.Dat.Vol);
  DelSpaceRight(Element^.Dat.DostProc);
  If Element^.Dat.Name[0]=#0 Then
   Begin
    MessageBox(^M+#3'Недопустимое наименование товара!',nil,mfError+mfCancelButton);
    If Cod=kbGrayPlus Then
      Begin
       BazNum^.NewList(Nil);
       Dispose(BazNum,Done);
      End;
    Dispose(Control,Done);
    Dispose(NameWin,Done);
    Goto 1;
   End;
  If Element^.Dat.FullName[0]=#0 Then
   Begin
    MessageBox(^M+#3'Недопустимое полное наименование товара!',nil,mfError+mfCancelButton);
    If Cod=kbGrayPlus Then
     Begin
       BazNum^.NewList(Nil);
       Dispose(BazNum,Done);
      End;
      Dispose(Control,Done);
      Dispose(NameWin,Done);
      Goto 1;
     End;

  Str(StrToReal(Element^.Dat.Litr):CKol:CMantissa,Element^.Dat.Litr);

  If (Element^.Dat.Litr[0]=#0) Then
    Begin
      MessageBox(^M+#3'У товара не указана масса!',nil,mfError+mfCancelButton);
       If Cod=kbGrayPlus Then
         Begin
          BazNum^.NewList(Nil);
          Dispose(BazNum,Done);
         End;
       Dispose(Control,Done);
       Dispose(NameWin,Done);
       Goto 1;
    End;

{
  If ((StrToReal(Element
  .Litr)=0)And(GetRazdelLitr(s1)<>0))
  Or((StrToReal(Element.Litr)<>0)And(GetRazdelLitr(s1)=0)) Then
    Begin
      MessageBox(^M+#3'Настройки раздела не соответствуют литражу у наименования!',nil,mfError+mfCancelButton);
      If Cod=kbGrayPlus Then
        Begin
         BazNum^.NewList(Nil);
         Dispose(BazNum,Done);
        End;
      Dispose(Control,Done);
      Dispose(NameWin,Done);
      Goto 1;
    End;
}
  If Element^.Dat.InPack[0]=#0 Then
    Begin
      MessageBox(^M+#3'У товара не указана фасовка!',nil,mfError+mfCancelButton);
      If Cod=kbGrayPlus Then
       Begin
         BazNum^.NewList(Nil);
         Dispose(BazNum,Done);
       End;
       Dispose(Control,Done);
       Dispose(NameWin,Done);
       Goto 1;
    End;

  If (Element^.Dat.Nalog[0]=#0) Or (StrTOReal(Element^.Dat.Nalog)=0) Then
   Begin
      MessageBox(#3+NoNalog,nil,mfWarning+mfCancelButton);
   End;

  If (StrTOReal(Element^.Dat.Nalog)>99.99) Then
   Begin
      MessageBox(#3+ErrorNAlog,nil,mfError+mfCancelButton);
      If Cod=kbGrayPlus Then
       Begin
         BazNum^.NewList(Nil);
         Dispose(BazNum,Done);
       End;
       Dispose(Control,Done);
       Dispose(NameWin,Done);
       Goto 1;
   End;

  Str(StrToReal(Element^.Dat.Nalog):CLitr:CMantissa,Element^.Dat.Nalog);
  DelSpace(Element^.Dat.Nalog);

  If (Element^.Dat.NDS[0]=#0) Or (StrTOReal(Element^.Dat.NDS)=0) Then
   Begin
      MessageBox(#3+NoNDS,nil,mfWarning+mfCancelButton);
   End;

  If (StrTOReal(Element^.Dat.NDS)>99.99) Then
   Begin
      MessageBox(#3+ErrorNDS,nil,mfError+mfCancelButton);
      If Cod=kbGrayPlus Then
       Begin
         BazNum^.NewList(Nil);
         Dispose(BazNum,Done);
       End;
       Dispose(Control,Done);
       Dispose(NameWin,Done);
       Goto 1;
   End;

  Str(StrToReal(Element^.Dat.NDS):CLitr:CMantissa,Element^.Dat.NDS);
  DelSpace(Element^.Dat.NDS);

  Str(StrToReal(Element^.Dat.MinNazenka):CLitr+1:CLitrMantissa,Element^.Dat.MinNazenka);
  DelSpace(Element^.Dat.MinNazenka);

  Format(Element^.Dat.Litr,CLitr);
  DelSpace(Element^.Dat.InPack);
  For c:=1 To CLitr Do If(Element^.Dat.Litr[c]=' ') Then Element^.Dat.Litr[c]:='0';

  If Cod=kbGrayPlus Then
  Begin
   s:=BazNum^.GetText(BazNum^.Focused,BazNum^.List^.Count);
   s:=Copy(s,1+1,CArtikul);
  end;



  {Если добавляем новое наименование то блокируем выбранный код}
  If Cod=kbGrayPlus Then
  Begin
   If Not(TestEmployNameAndLock(s,Oper)) Then
    Begin
     Beep;
     DInfoMsg('Позиция ['+s+'] используется'+Oper+'. Попробуйте изменить код!');

     Application^.ClearEvent(Event);
     Application^.ClearEvent(Event);
      repeat
       Application^.GetEvent(Event);
      until (Event.What <> evNothing);
     NoInfoMsg;
     Application^.ClearEvent(Event);
     Dispose(BazNum,Done);
     Dispose(Control,Done);
     Dispose(ControlProz,Done);
     Dispose(ControlVol,Done);
     Dispose(NameWin,Done);
     Goto 1;
    End;
  End;


  {исходим из того что блокировка удалась}
  with Element^.Dat do
  begin
    UpStr(Name);
    UpStr(FullName);
    Employ:=True;
    Stat  :=False;
    Locked:=True;
    Caption:=CurrentPassword;
    BazKod:=s;
  end;


   BazElement^.Dat.BazKod:=Element^.Dat.BazKod;
   new(skl,init);
   Skl^.Dat.BazKod:=BazElement^.Dat.BazKod;

   GetSkladRecord(Skl);

   BazElement^.Dat:=Skl^.Dat;
   Dispose(Skl,Done);

   BazElement^.Dat.Input.Caption:=CurrentPassword;
   BazElement^.Dat.Input.Akzis1:=sFas;

If Cod=kbGrayPlus Then
  Begin
   with BazElement^.Dat.Input do
   begin
    Post[0] :=#0;
    NSertif[0]:=#0;
    DSertif[0]:=#0;
    KSertif[0]:=#0;
    {BazElement.Input.Akzis1[0] :=#0;}
    Kol     :='0';
    For j:=1 To CDivision Do
    DivisionS[j]:='0';
    Zakupka :='0.00';
    R_Zena  :='0.00';
    O_Zena  :='0.00';
   end;
  End;
   with BazElement^.Dat do
   begin
     DAte:=FDAte;
     Employ:=True;
     Locked:=False;
     Time:=Times;
   end;


  {если не удалось записать информацию}
  If Not (WriteLockName(Element^.Dat,BazElement^.Dat)) Then
    Begin
     If Cod=kbGrayPlus Then Dispose(BazNum,Done);
     Dispose(Control,Done);
     Dispose(NAmeWin,Done);
     Repeat
     Until (SetNAmeUnLock(s));
     Goto 1;
    End;



If Cod=kbGrayPlus Then
  Begin
   s:=BazNum^.GetText(BazNum^.Focused,BazNum^.List^.Count);
   s:=Copy(s,1+1,CArtikul);
   AddProtocol('Добавление наименования:'+Element^.Dat.Name+' ('+s+')','','');
   Repeat
   Until (SetNAmeUnLock(s));
  End
   Else
   AddProtocol('Корректировка наименования:'+Element^.Dat.Name+' ('+s+')','','');
   Res:=True;

End;

If Cod=kbGrayPlus Then
  Begin
   BazNum^.NewList(Nil);
   Dispose(BazNum,Done);
  End;

  Dispose(Control,Done);
  Dispose(NameWin,Done);
end;

Destructor TNameWinDow.Done;
Begin
ClearFind;
Dispose(ControlVidNalog,Done);
Dispose(ControlNalog,Done);
Dispose(ControlVidNDS,Done);
Dispose(ControlNDS,Done);
Dispose(ControlLine,Done);
Dispose(ControlName,Done);
{Dispose(ControlT,Done);}
TDialog.Done;
End;

procedure TNameWindow.HandleEvent(var Event: TEvent);
Var l : Boolean;
    Test : Word;
    s : ArtikulStr;
 Begin
{
Case Event.What Of
 evKeyDown:
   Case Event.KeyCode Of

        kbEnter:Begin
                inherited HandleEvent(Event);
               If (NameWin^.Current=ControlLine) Then
                   Begin
                    Event.What:=evCommand;
                    Event.Command:=CmOk;
                   End;
                End;
   Else;
   End;
   Else;
   End;
}
  If (Event.What=EvKeyDown) And (ControlLine^.State and sfFocused <> 0) And
  (Event.KeyCode<>kbTab) And
  (Event.KeyCode<>kbEnter) And
  (Event.KeyCode<>kbShiftTab) And
  (Event.KeyCode<>kbCtrlLeft) And
  (Event.KeyCode<>kbLeft) And
  (Event.KeyCode<>kbRight) And
  (Event.KeyCode<>kbHome) And
  (Event.KeyCode<>kbEnd) And
  (Event.KeyCode<>kbCtrlRight) Then L:=True
  Else L:=False;

  inherited HandleEvent(Event);

  If (L) Then DrawName;

  If (ControlVidNalog^.State and sfFocused <> 0) Then
   Begin
    ControlVidNalog^.GetData(Test);
    Case Test Of
    0:Begin
       s:='5.00';
       ControlNalog^.Setdata(s);
       ControlNAlog^.Options := ControlNAlog^.Options and not ofSelectable;
       Redraw;
      End;
    1:Begin
       s:='3.00';
       ControlNalog^.Setdata(s);
       ControlNAlog^.Options := ControlNAlog^.Options and not ofSelectable;
       Redraw;
      End;
    2:Begin
       ControlNAlog^.Options := ControlNAlog^.Options Or ofSelectable;
       Redraw;
      End;
    Else;
    End;
   End;

  If (ControlVidNDS^.State and sfFocused <> 0) Then
   Begin
    ControlVidNDS^.GetData(Test);
    Case Test Of
    0:Begin
       s:='18.00';
       ControlNDS^.Setdata(s);
       ControlNDS^.Options := ControlNDS^.Options and not ofSelectable;
       Redraw;
      End;
    1:Begin
       s:='10.00';
       ControlNDS^.Setdata(s);
       ControlNDS^.Options := ControlNDS^.Options and not ofSelectable;
       Redraw;
      End;
    2:Begin
       ControlNDS^.Options := ControlNDS^.Options Or ofSelectable;
       Redraw;
      End;
    Else;
    End;
   End;

 End;


Procedure TClientWindow.ShowClientList(Var st:AllStr;Selector,Regim:Word;VidClienta,Net,TestSrok:Boolean;
          NoLocked1,VidNoLocked1,NoLocked2,VidNoLocked2:Integer;Var Res: Word);
Label 1;
var
  R : TRect;
  Control : PView;
  s : String[CSertif];
  c,Count: Word;
  CLF : ClientFileType;
  (*CLE : PBufClientType;*)
  CLE : PClientType;
begin
ClearFind;
AInfo('Читаю списки...');
Res:=0;
Debitors:=VidClienta;
WithNetLock:=Net;
WithTestSrok:=TestSrok;

NotLockedCod1:=NoLocked1;
NotLockedCod2:=NoLocked2;
VidNotLockedCod1:=VidNoLocked1;
VidNotLockedCod2:=VidNoLocked2;
R.Assign(0, 0, 80, 23);
{If Not(Debitors) Then}
Begin
If Regim=0 Then
New(ClientWindow, Init(R, 'Выбор клиента'))
Else
New(ClientWindow, Init(R, 'Выбор поставщика'));
End;
{Else New(ClientWindow, Init(R, 'Выбор дебитора'));}



Reg:=Regim;
Sel:=Selector;
R.Assign(79, 1, 80, 19);
Control := New(PScrollBar, Init(R));
ClientWindow^.Insert(Control);

If Reg=0 Then
Begin
R.Assign(0, 1, 80, 19);
Client := New(PBox, Init(R, 3, PScrollbar(Control)));
Client^.NewList(New(PTextCollection, Init(0,1)));
End
Else
 Begin
  R.Assign(0, 1, 80, 19);
  MakeList := New(PBox, Init(R, 3, PScrollbar(Control)));
  MakeList^.NewList(New(PTextCollection, Init(0,1)));
 End;
{If Not(Debitors) Then
Begin}

Case Reg Of
0:Begin
    Case Selector Of
     0:Assign (ClF,Path.ToClient+'Client.db');
     1:Assign (ClF,Path.ToClient+'Sklad.db');
     2:Assign (ClF,Path.ToClient+'Barter.db');
     Else;
     End;{CAse}
  End;
1:Begin
    Case Selector Of
     0:Assign (ClF,Path.ToClient+'Make.db');
     1:Assign (ClF,Path.ToClient+'Sklad.db');
     2:Assign (ClF,Path.ToClient+'Barter.db');
     Else;
     End;{CAse}
  End;
Else;
End;

{End
Else
Begin
 If Reg=0 Then
 Assign(ClientFile,Print.PathToMain+'Debit.db')
 Else
 Assign(ClientFile,Print.PathToMain+'Debitp.db');
End;}

c:=IOResult;
Reset (ClF);
c:=IOResult;
If c=0 Then
Begin
AInfo('Читаю списки...');
While Not(Eof(ClF)) Do
 Begin


    {ReadClient(ClientFile,ClientElement);}
    New(CLE,Init);

(*  ReadBufClient(Clf,CL,Count);
  For c:=1 To Count Do
  Begin
  If ClE^.Point.Dat[c].Employ Then
   Begin
    Format (ClE^.Point.Dat[c].Name,CClient);
    If Reg=0 Then
    Begin
    {If Odd(c) Then}
    Begin
    Client^.List^.Insert(NewStr(ClE^.Point.Dat[c].Name+'│'+ClE^.Point.Dat[c].Kod));
    Client^.SetRange(Client^.List^.Count);
    End;
    End
    Else
    Begin
    MakeList^.List^.Insert(NewStr(ClE^.Point.Dat[c].Name+'│'+ClE^.Point.Dat[c].Kod));
    MakeList^.SetRange(MakeList^.List^.Count);
    End;
   End;{Employ}
  End;{For} *)
     ReadClient(Clf,CLE^.Dat);
     If ClE^.Dat.Employ Then
   Begin
   Format (ClE^.Dat.Name,CClient);
    If Reg=0 Then
    Begin
    {If Odd(c) Then}
    Begin
    Client^.List^.Insert(NewStr(ClE^.Dat.Name+'│'+ClE^.Dat.Kod));
    Client^.SetRange(Client^.List^.Count);
    End;
    End
    Else
    Begin
    MakeList^.List^.Insert(NewStr(ClE^.Dat.Name+'│'+ClE^.Dat.Kod));
    MakeList^.SetRange(MakeList^.List^.Count);
    End;
   End;{Employ}
     Dispose(CLE,Done);
 End;{Eof}
System.Close(ClF);
End

Else
 Begin
  NoInfo;
  MessageBox(^M+#3'Ошибка доступа к файлам базы !',nil,mfError+mfCanCelButton);
  Goto 1;
 End;
s:=Copy(st,1+CClient+1,CClientKod);
If Reg=0 Then
Begin
Client^.FocusItem(Location(Client,S,ProdagaWindow));
Client^.HelpCtx:=$E171;
ClientWindow^.Insert(Client);
PrevClient:=Copy(Client^.GetText(Client^.Focused,CLient^.List^.Count),1+CClient+1,CClientKod);
End
Else
 Begin
MakeList^.FocusItem(Location(MakeList,S,ProdagaWindow));
MakeList^.HelpCtx:=$E171;
PrevClient:=Copy(MakeList^.GetText(MakeList^.Focused,MakeList^.List^.Count),1+CMake+1,CMakeKod);
ClientWindow^.Insert(MakeList);
 End;

R.Assign(1, 19, 12, 20);
Control := New(PColoredText, Init(R, 'N Договора:', $74));
ClientWindow^.Insert(Control);

R.Assign(12, 19, 32, 20);
ControlDogovor := New(PColoredText, Init(R, #3, $7E));
ClientWindow^.Insert(ControlDogovor);

R.Assign(33, 19, 35, 20);
If Reg=0 Then
Begin
GetClientOpt(Copy(Client^.GetText(Client^.Focused,CLient^.List^.Count),1+CClient+1,CClientKod),Selector);
if GetClientOpt(Copy(Client^.GetText(Client^.Focused,CLient^.List^.Count),1+CClient+1,CClientKod),Selector) then
OPtControl := New(PColoredText, Init(R, 'Опт.', $74))
else OPtControl := New(PColoredText, Init(R, 'Розн.', $74));
end
else
Begin
GetClientOpt(Copy(MakeList^.GetText(MakeList^.Focused,MakeList^.List^.Count),1+CClient+1,CClientKod),Selector);
if GetClientOpt(Copy(MakeList^.GetText(MakeList^.Focused,MakeList^.List^.Count),1+CClient+1,CClientKod),Selector) then
OPtControl := New(PColoredText, Init(R, 'Опт.', $74))
else OPtControl := New(PColoredText, Init(R, 'Розн.', $74));
end;
ClientWindow^.Insert(Control);

R.Assign(12, 20, 21, 21);
Control := New(PColoredText, Init(R, #3+'Лицензия:', $74));
ClientWindow^.Insert(Control);

R.Assign(21, 20, 66, 21);
{If Regim=1 Then}
ControlEnviropment := New(PColoredText, Init(R, #3{GetMakeField(FEnvir,PrevClient,Selector)}, $7E));
{Else
ControlEnviropment := New(PColoredText, Init(R, #3+GetClientField(FEnvir,PrevClient,Selector), $7E));}
ClientWindow^.Insert(ControlEnviropment);

R.Assign(1, 21, 7, 22);
Control := New(PColoredText, Init(R, 'Лимит:', $74));
ClientWindow^.Insert(Control);

R.Assign(7, 21, 22, 22);
{If Regim=1 Then
ControlLimit := New(PColoredText, Init(R, #3+GetMAkeField(FLimit,PrevClient,Selector), $7E))
Else}
ControlLimit := New(PColoredText, Init(R, #3{GetClientField(FLimit,PrevClient,Selector)}, $7E));

ClientWindow^.Insert(ControlLimit);

R.Assign(24, 21, 29, 22);
Control := New(PColoredText, Init(R, 'Долг:', $74));
ClientWindow^.Insert(Control);

R.Assign(29, 21, 44, 22);
{If Regim=1 Then
ControlDolg := New(PColoredText, Init(R, #3+GetMakeField(FDolg,PrevClient,Selector), $7E))
Else}
ControlDolg := New(PColoredText, Init(R, #3+'???'{GetClientField(FDolg,PrevClient,Selector)}, $FE));
ClientWindow^.Insert(ControlDolg);

R.Assign(45, 21, 71, 22);
Control := New(PColoredText, Init(R, 'Срок действия лицензии до:', $74));
ClientWindow^.Insert(Control);

R.Assign(71, 21, 79, 22);
ControlSrokLizensia := New(PColoredText, Init(R, #3+'', $7E));
ClientWindow^.Insert(ControlSrokLizensia);

R.Assign(58, 19, 79, 20);
ControlStatus := New(PColoredText, Init(R, #3+'', $7E));
ClientWindow^.Insert(ControlStatus);


{
If VidClienta And (Sel=0) Then
Begin
R.Assign(29, 22, 51, 23);
Control := New(PColoredText, Init(R, #3' F2 - Рассчитать долг', $71));
Control^.Options := Control^.Options or ofCenterX;
ClientWindow^.Insert(Control);
End;
}



ClientWindow^.SelectNext(False);
PrevClient[0]:=#0;
NoInfo;
c:=Desktop^.ExecView(ClientWindow);
If c<>CmCancel Then
   If c=CmOk Then Res:=2;
   If c=CmYes Then Res:=3;
   If c=CmCancel Then Res:=1;
   If Reg=0 Then
   St:=Client^.GetText(Client^.Focused,Client^.List^.Count)
   Else
   St:=MakeList^.GetText(MakeList^.Focused,MakeList^.List^.Count);

   If ShowClients=1 Then
    Begin
     s:=Copy(st,1+CCLient+1,CClientKod);
     If Reg=0 Then
     s:=GetClientField(FMessages,s,Selector)
     Else
     s:=GetMAkeField(FMessages,s,Selector);
     DelSpaceRight(s);

     If s[0]<>#0 Then
      Begin
       SpecialBeep;
       MessageBox(^M+#3+s,Nil,mfInformation+mfCancelButton);
      End;
    End;

(*
     If Reg=0 Then {фильтр старые и новые договоры}
     Begin
     s:=Copy(st,1+CCLient+1,CClientKod);
     c:=StrToInt(GetClientField(FDebit,s,Reg));
     s:=GetClientField(FNDogovor,s,Reg);

     If (Not(Pos('Н',s)>0)  And (c=1))And
        (Not(Pos('А',s)>0)  And (c=1)) Then
      Begin
       SpecialBeep;
       MessageBox(^M+#3+'Необходимо обновить договор консигнации!!!',Nil,mfInformation+mfCancelButton);
      End;
     End;{фильтр старые и новые договоры}
*)
1:
{If VidClienta Then }
Dispose(COntrol,Done);
Dispose(ClientWindow,Done);
end;


Procedure TClientWindow.Refresh(Reg,sel:Word);
var
  R : TRect;
  Control : PView;
  s : String[CSertif];
  CLF : File;
  CLE : PBufClientType;
  c,count : Word;

  Cod: Word;
begin
ClearFind;
AInfo('Обновляю списки клиентов...');

  If Reg=0 Then
  Cod:=Client^.Focused
  Else
  Cod:=MakeList^.Focused;

Case Reg Of
0:Begin
{ If Sel = 0 Then Assign (ClientFile,Path.ToClient+'Client.db')
  Else Assign (ClientFile,Path.ToClient+'Sklad.db');}

    Case Sel Of
     0:Assign (ClF,Path.ToClient+'Client.db');
     1:Assign (ClF,Path.ToClient+'Sklad.db');
     2:Assign (ClF,Path.ToClient+'Barter.db');
     Else;
     End;{CAse}


  Client^.NewList(Nil);
  Client^.NewList(New(PTextCollection, Init(0,1)));
  End;

1:Begin
{ If Sel = 0 Then Assign (ClientFile,Path.ToClient+'Make.db')
  Else Assign (ClientFile,Path.ToClient+'Sklad.db');}

    Case Sel Of
     0:Assign (ClF,Path.ToClient+'Make.db');
     1:Assign (ClF,Path.ToClient+'Sklad.db');
     2:Assign (ClF,Path.ToClient+'Barter.db');
     Else;
     End;{CAse}
  End;
Else;
End;

c:=IOResult;
Reset (ClF,SizeOf(ClientType));
c:=IOResult;
If c=0 Then
Begin
While Not(Eof(ClF)) Do
 Begin
   {ReadClient(ClientFile,ClientElement);}
    New(CLE,Init);
    ReadBufClient(Clf,CLE,Count);
  For c:=1 To Count Do
  Begin
  If ClE^.Point.Dat[c].Employ Then
   Begin
    Format (ClE^.Point.Dat[c].Name,CClient);
    If Reg=0 Then
    Begin
    {If Odd(c) Then}
    Begin
    Client^.List^.Insert(NewStr(ClE^.Point.Dat[c].Name+'│'+ClE^.Point.Dat[c].Kod));
    Client^.SetRange(Client^.List^.Count);
    End;
    End
    Else
    Begin
    MakeList^.List^.Insert(NewStr(ClE^.Point.Dat[c].Name+'│'+ClE^.Point.Dat[c].Kod));
    MakeList^.SetRange(MakeList^.List^.Count);
    End;
   End;{Employ}
  End;{For}
     Dispose(CLE,Done);
 End;{Eof}
System.Close(ClientFile);
If Cod<>0 Then Dec(Cod);

If Reg =0 Then  Client^.FocusItem(Cod);
If Reg =1 Then  MakeList^.FocusItem(Cod);
NoInfo;
End
Else
 Begin
  NoInfo;
  MessageBox(^M+#3'Ошибка доступа к файлам базы !',nil,mfError+mfCanCelButton);
  Exit;
 End;
Redraw;
PrevClient[0]:=#0;
end;





Procedure TClientWindow.DrawCurrent(Reg,Sel: Byte);
Var s: String[CAll];
    R : TRect;
Begin
  Case Reg Of
  0:s:=GetClientField(FEnvir,Copy(PrevClient,1+CClient+1,CClientKod),Sel);
  1:s:=GetMakeField(FEnvir,Copy(PrevClient,1+CClient+1,CClientKod),Sel);
  Else;
  End;
  Dispose(COntrolEnviropment,Done);
  R.Assign(21, 20, 66, 21);
  ControlEnviropment := New(PColoredText, Init(R, #3+S, $7E));
  Insert(ControlEnviropment);

  Case Reg Of
  0:s:=GetClientField(FLimit,Copy(PrevClient,1+CClient+1,CClientKod),Sel);
  1:s:=GetMakeField(FLimit,Copy(PrevClient,1+CClient+1,CClientKod),Sel);
  Else;
  End;
  Dispose(ControlLimit,Done);
  R.Assign(7, 21, 22, 22);
  ControlLimit := New(PColoredText, Init(R, #3+S, $DE));
  Insert(ControlLimit);
{
  Case Reg Of
  0:s:=GetClientField(FDolg,Copy(PrevClient,1+CClient+1,CClientKod),Sel);
  1:s:=GetMakeField(FDolg,Copy(PrevClient,1+CClient+1,CClientKod),Sel);
  Else;
  End;
{
  Dispose(COntrolDolg,Done);
  R.Assign(50, 21, 64, 22);
  ControlDolg := New(PColoredText, Init(R, #3, $FE));
  Insert(ControlDolg);
}
If Debitors And (Sel=0) Then
  Begin
  s:=Copy(PrevClient,1+CClient+1,CClientKod);
      If s[0]<>#0 Then
      Begin
{              AInfo('Считаю долг клиента...');}
               S:=CalcDolg(s);
               Dispose(ControlDolg,Done);
               R.Assign(29, 21, 44, 22);
               ControlDolg := New(PColoredText, Init(R, #3+s, $5E));
               Insert(ControlDolg);

               s:=Copy(PrevClient,1+CClient+1,CClientKod);
               s:=GetClientField(FDebit,s,Sel);
               Case StrToInt(s) Of
               0:Begin
                           s:='КОНСИГНАЦИЯ ЗАПРЕЩЕНА';
                  {Beep;}
                 End;
               1:s[0]:=#0;
               Else;
               End;
               Dispose(ControlStatus,Done);
               R.Assign(58, 19, 79, 20);
               If Ord(s[0])=0 Then
               ControlStatus := New(PColoredText, Init(R, #3+s, $FE))
               Else
               ControlStatus := New(PColoredText, Init(R, #3+s, $DE));

               Insert(ControlStatus);

{              Noinfo;}
      End;
  End;
  Case Reg Of
  0:s:=GetClientField(FNDogovor,Copy(PrevClient,1+CClient+1,CClientKod),Sel);
  1:s:=GetMakeField(FNDogovor,Copy(PrevClient,1+CClient+1,CClientKod),Sel);
  Else;
  End;
  Dispose(COntrolDogovor,Done);
  R.Assign(12, 19, 35, 20);
  ControlDogovor := New(PColoredText, Init(R, #3+S, $7E));
  Insert(ControlDogovor);
  Dispose(OptCOntrol,Done);
  R.Assign(36, 19, 41, 20);
  Case Reg Of
  0: begin
  if GetClientOpt(Copy(Client^.GetText(Client^.Focused,CLient^.List^.Count),1+CClient+1,CClientKod),sel) then
  OPtControl := New(PColoredText, Init(R, 'Опт.', $74))
   else OPtControl := New(PColoredText, Init(R, 'Розн.', $74));
     end;
  1: begin
  if GetClientOpt(Copy(MakeList^.GetText(MakeList^.Focused,MakeList^.List^.Count),1+CClient+1,CClientKod),sel) then
  OPtControl := New(PColoredText, Init(R, 'Опт.', $74))
   else OPtControl := New(PColoredText, Init(R, 'Розн.', $74));
     end;
   end;
  Insert(OPtControl);


  Case Reg Of
  0:s:=GetClientField(FSrok,Copy(PrevClient,1+CClient+1,CClientKod),Sel);
  1:s:=GetMakeField(FSrok,Copy(PrevClient,1+CClient+1,CClientKod),Sel);
  Else;
  End;

  Dispose(ControlSrokLizensia,Done);
  R.Assign(71, 21, 79, 22);
  ControlSrokLizensia := New(PColoredText, Init(R, #3+s, $7E));
  Insert(ControlSrokLizensia);

  Redraw;
End;



Destructor TClientWindow.Done;
Begin
ClearFind;

Dispose(ControlEnviropment,Done);
Dispose(ControlLimit,Done);
Dispose(ControlDolg,Done);
Dispose(ControlDogovor,Done);
Dispose(ControlSrokLizensia,Done);
Dispose(ControlStatus,Done);

If Reg=0 Then
Dispose(Client,Done)
Else
Dispose(MakeList,Done);
TDialog.Done;
End;


Procedure DelDolgFile(s:ArtikulStr);
Var f : File;
    i : Byte;
Begin
 i:=IOResult;
 Assign(f,Path.ToDolg+s+'.dlg');
 Erase(f);
 i:=IOResult;

 i:=IOResult;
 Assign(f,Path.ToClient+s+'.his');
 Erase(f);
 i:=IOResult;

 i:=IOResult;
 Assign(f,Path.ToClientOplata+s+'.cpl');
 Erase(f);
 i:=IOResult;

 i:=IOResult;
 Assign(f,Path.ToClientReturn+s+'.cvz');
 Erase(f);
 i:=IOResult;
End;

Procedure TClientWindow.PrintClientInfo(s:ArtikulStr;Reg,Sel:Byte);
Const Space='           ';
Var f : Text;
    c : Word;
Begin
 Assign(f,Path.ToTemp+'rek.txt');
 c:=IOResult;
 Rewrite(f);
 If c<>0 Then
  Begin
   MessageBox(^M+#3'Ошибка создания файла '+Path.ToTemp+'rek.txt!',Nil,mfError+mfCancelButton);
   Exit;
  End;
Case Reg Of
0:Begin
   Writeln(f,Space+Bold[NPrint.Printer]+Double[NPrint.Printer]+'         РЕКВИЗИТЫ КЛИЕНТА '+GetClientField(FClient,s,Sel)+
   ' ('+s+')'+NoBold[NPrint.Printer]+NoDouble[NPrint.Printer]);
   Writeln(f,Space+Bold[NPrint.Printer]+'       Договор: '+NoBold[NPrint.Printer]+Italic[NPrint.Printer]+
   GetClientField(FNDogovor,s,Sel)+NoItalic[NPrint.Printer]);
   Writeln(f,Space+Bold[NPrint.Printer]+'   Лимит долга: '+NoBold[NPrint.Printer]+Italic[NPrint.Printer]+
   GetClientField(FLimit,s,Sel)+NoItalic[NPrint.Printer]);
   Writeln(f,Space+Bold[NPrint.Printer]+'         Адрес: '+NoBold[NPrint.Printer]+Italic[NPrint.Printer]+
   GetClientField(FAdress,s,Sel)+NoItalic[NPrint.Printer]);;
   Writeln(f,Space+Bold[NPrint.Printer]+'       Телефон: '+NoBold[NPrint.Printer]+Italic[NPrint.Printer]+
   GetClientField(FTelefon,s,Sel)+NoItalic[NPrint.Printer]);;
   Writeln(f,Space+Bold[NPrint.Printer]+'Расчетный счет: '+NoBold[NPrint.Printer]+Italic[NPrint.Printer]+
   GetClientField(FRSh,s,Sel)+NoItalic[NPrint.Printer]);;
   Writeln(f,Space+Bold[NPrint.Printer]+'             в: '+NoBold[NPrint.Printer]+Italic[NPrint.Printer]+
   GetClientField(FGde,s,Sel)+NoItalic[NPrint.Printer]);;
   Writeln(f,Space+Bold[NPrint.Printer]+'         Город: '+NoBold[NPrint.Printer]+Italic[NPrint.Printer]+
   GetClientField(FGorod,s,Sel)+NoItalic[NPrint.Printer]);;
   Writeln(f,Space+Bold[NPrint.Printer]+'           ИНН: '+NoBold[NPrint.Printer]+Italic[NPrint.Printer]+
   GetClientField(FINN,s,Sel)+NoItalic[NPrint.Printer]);;
   Writeln(f,Space+Bold[NPrint.Printer]+'          ОГРН: '+NoBold[NPrint.Printer]+Italic[NPrint.Printer]+
   GetClientField(FOkonh,s,Sel)+NoItalic[NPrint.Printer]);;
   Writeln(f,Space+Bold[NPrint.Printer]+'          ОКПО: '+NoBold[NPrint.Printer]+Italic[NPrint.Printer]+
   GetClientField(FOkpo,s,Sel)+NoItalic[NPrint.Printer]);;
   Writeln(f,Space+Bold[NPrint.Printer]+'      Лицензия: '+NoBold[NPrint.Printer]+Italic[NPrint.Printer]+
   GetClientField(FEnvir,s,Sel)+NoItalic[NPrint.Printer]);;
   Writeln(f,Space+Bold[NPrint.Printer]+' Срок лицензии: '+NoBold[NPrint.Printer]+Italic[NPrint.Printer]+
   GetClientField(FSrok,s,Sel)+NoItalic[NPrint.Printer]);;
   Write(f,Space+Bold  [NPrint.Printer]+'   Консигнация: '+NoBold[NPrint.Printer]+Italic[NPrint.Printer]);

   If StrToInt(GetClientField(FDebit,s,Sel))=0 Then
   Writeln(f,'Запрещена!!!'+NoItalic[NPrint.Printer])
   Else
   Writeln(f,'Разрешена'+NoItalic[NPrint.Printer]);
   Writeln(f,Space+Bold[NPrint.Printer]+'         Шкала: '+NoBold[NPrint.Printer]+Italic[NPrint.Printer]+
   'Цена '+GetClientField(FShkala,s,Sel)+NoItalic[NPrint.Printer]);;
   Writeln(f,Space+'====================================================================');

  End;
1:Begin
   Writeln(f,Space+Bold[NPrint.Printer]+Double[NPrint.Printer]+'      РЕКВИЗИТЫ ПОСТАВЩИКА '+
   GetMakeField(FClient,s,Sel)+' ('+s+')'+NoBold[NPrint.Printer]+NoDouble[NPrint.Printer]);
  {Writeln(f,Space+Bold+'   Лимит долга: '+NoBold+Italic+GetMAkeField(FLimit,s,Sel)+NoItalic);}
   Writeln(f,Space+Bold[NPrint.Printer]+'         Адрес: '+NoBold[NPrint.Printer]+Italic[NPrint.Printer]+
   GetMAkeField(FAdress,s,Sel)+NoItalic[NPrint.Printer]);;
   Writeln(f,Space+Bold[NPrint.Printer]+'       Телефон: '+NoBold[NPrint.Printer]+Italic[NPrint.Printer]+
   GetMAkeField(FTelefon,s,Sel)+NoItalic[NPrint.Printer]);;
   Writeln(f,Space+Bold[NPrint.Printer]+'Расчетный счет: '+NoBold[NPrint.Printer]+Italic[NPrint.Printer]+
   GetMAkeField(FRSh,s,Sel)+NoItalic[NPrint.Printer]);;
   Writeln(f,Space+Bold[NPrint.Printer]+'             в: '+NoBold[NPrint.Printer]+Italic[NPrint.Printer]+
   GetMAkeField(FGde,s,Sel)+NoItalic[NPrint.Printer]);;
   Writeln(f,Space+Bold[NPrint.Printer]+'         Город: '+NoBold[NPrint.Printer]+Italic[NPrint.Printer]+
   GetMAkeField(FGorod,s,Sel)+NoItalic[NPrint.Printer]);;
   Writeln(f,Space+Bold[NPrint.Printer]+'           ИНН: '+NoBold[NPrint.Printer]+Italic[NPrint.Printer]+
   GetMAkeField(FINN,s,Sel)+NoItalic[NPrint.Printer]);;
   Writeln(f,Space+Bold[NPrint.Printer]+'          ОГРН: '+NoBold[NPrint.Printer]+Italic[NPrint.Printer]+
   GetMAkeField(FOkonh,s,Sel)+NoItalic[NPrint.Printer]);;
   Writeln(f,Space+Bold[NPrint.Printer]+'          ОКПО: '+NoBold[NPrint.Printer]+Italic[NPrint.Printer]+
   GetMAkeField(FOkpo,s,Sel)+NoItalic[NPrint.Printer]);
   Writeln(f,Space+Bold[NPrint.Printer]+'      Лицензия: '+NoBold[NPrint.Printer]+Italic[NPrint.Printer]+
   GetMAkeField(FEnvir,s,Sel)+NoItalic[NPrint.Printer]);
   Writeln(f,Space+'====================================================================');
  End;
 Else
 End;
System.Close(f);
Report(Path.ToTemp+'rek.txt','',1,False,False,false);
End;


Procedure SaveTempLock(Kod:ArtikulStr;Status:Word;Caption:ArtikulStr);
VAr f : File Of LockClientType;
    c : LockClientType;
    i : Word;
Begin
 Assign(f,Path.ToClient+Kod+'.lck');
 i:=IOResult;
 Reset(f);
 i:=IOResult;
 If i<>0 Then
  Begin
    Rewrite(f);
    i:=IOResult;
  End;
 Seek(f,FileSize(f));

 c.Status:=Status;
 C.LOCKDATE:=FDate;
 C.LOCKTime:=Times;
 C.Caption:=Caption;

 Write(f,c);
 i:=IOResult;
 System.Close(f);
 i:=IOResult;
End;



procedure TClientWindow.HandleEvent(var Event: TEvent);
Var R : TRect;
    test : Word;
    s : TMyString;
    L : Boolean;
   cod : ArtikulStr;

Function LockSelect:Boolean;
Var s : string[150];
    Event : TEvent;
    R : Boolean;
Begin
  LockSelect:=False;
  If Reg=0 Then
  s:=Client^.GetText(Client^.Focused,Client^.List^.Count)
  Else
  s:=MakeList^.GetText(MakeList^.Focused,MakeList^.List^.Count);
  s:=Copy(s,1+CClient+1,CClientKod);

  If Reg=0 Then R:=GetClientEmploy(s,Sel);
  If Reg=1 Then R:=GetMakeEmploy(s,Sel);

  If Not(r) Then
   Begin
    Beep;
    DInfoMsg('Не могу заблокировать клиента с кодом '+s+'. Клиент отмечен как удаленный!');
    ClearEvent(Event);
    ClearEvent(Event);
    repeat
    Application^.GetEvent(Event);
    {until (Event.What in [evKeyDown,evMouseDown]);}
    until (Event.What <> evNothing);
    NoInfoMsg;
    ClearEvent(Event);
    Event.What:=EvCommand;
    Event.Command:=cmRefresh;
    PutEvent(Event);
    ClearEvent(Event);
    Exit;
   End;

  If ((StrToInt(s)=NotLockedCod1)And(Sel=VidNotLockedCod1))
   Or((StrToInt(s)=NotLockedCod2)And(Sel=VidNotLockedCod2)) Then
    Begin
     LockSelect:=True;
     Exit;
    End;

  If SetClientLock(s,Reg,Sel) Then LockSelect:=True
  Else
   Begin
    Beep;
    DInfoMsg('Не могу заблокировать клиента с кодом '+s+'. Попробуйте повторить!');
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

Function TestEmploy:Boolean;
Var s : string[150];
    Event : TEvent;
    R : Boolean;
Begin
  TestEmploy:=False;
  If Reg=0 Then
  s:=Client^.GetText(Client^.Focused,Client^.List^.Count)
  Else
  s:=MakeList^.GetText(MakeList^.Focused,MakeList^.List^.Count);
  s:=Copy(s,1+CClient+1,CClientKod);

  r:=False;
  If Reg=0 Then R:=GetClientEmploy(s,Sel);
  If Reg=1 Then R:=GetMakeEmploy(s,Sel);

  If Not(r) Then
   Begin
    Beep;
    DInfoMsg(''+s+'. Клиент отмечен как удаленный!');
    ClearEvent(Event);
    ClearEvent(Event);
    repeat
    Application^.GetEvent(Event);
    {until (Event.What in [evKeyDown,evMouseDown]);}
    until (Event.What <> evNothing);
    NoInfoMsg;
    ClearEvent(Event);
    Event.What:=EvCommand;
    Event.Command:=cmRefresh;
    PutEvent(Event);
    ClearEvent(Event);
    Exit;
   End
   Else
   TestEmploy:=True;
End;


Procedure UnlockAll;
Var  f : File Of ClientType;
     cl : ClientType;
     r : Byte;
     cod : ArtikulStr;
Begin
AInfo('Минуточку...');
Case Reg Of
0:Begin
 {If Sel = 0 Then Assign (F,Path.ToClient+'Client.db')
  Else Assign (F,Path.ToClient+'Sklad.db');}
    Case Sel Of
     0:Assign (F,Path.ToClient+'Client.db');
     1:Assign (F,Path.ToClient+'Sklad.db');
     2:Assign (F,Path.ToClient+'Barter.db');
     3:Assign (F,Path.ToClient+'Lizo.db');
     Else;
     End;{CAse}
  End;
1:Begin
{ If Sel = 0 Then Assign (F,Path.ToClient+'Make.db')
  Else Assign (F,Path.ToClient+'Sklad.db');}
    Case Sel Of
     0:Assign (F,Path.ToClient+'Make.db');
     1:Assign (F,Path.ToClient+'Sklad.db');
     2:Assign (F,Path.ToClient+'Barter.db');
     3:Assign (F,Path.ToClient+'Lizo.db');
     Else;
     End;{CAse}
  End;
Else;
End;
r:=IOResult;
Reset(f);
r:=IOResult;
If R<>0 Then
 Begin
  NoInfo;
  Exit;
 End;

While Not(Eof(f)) Do
  Begin
   Read(f,Cl);
   r:=IOResult;

   cl.Locked:=False;
   Seek(f,FilePos(f)-1);
   r:=IOResult;

   Write(f,cl);
   r:=IOResult;

  End;
   r:=IOResult;
System.close(f);
   r:=IOResult;

NoInfo;
End;




Procedure UnlockAllTemp;
Var  f : File Of ClientType;
     cl : ClientType;
     r : Byte;
     cod : ArtikulStr;

Begin
If Password(10) Then
Begin
AInfo('Минуточку...');
Case Reg Of
0:Begin
 {If Sel = 0 Then Assign (F,Path.ToClient+'Client.db')
  Else Assign (F,Path.ToClient+'Sklad.db');}
    Case Sel Of
     0:Assign (F,Path.ToClient+'Client.db');
     1:Assign (F,Path.ToClient+'Sklad.db');
     2:Assign (F,Path.ToClient+'Barter.db');
     3:Assign (F,Path.ToClient+'Lizo.db');
     Else;
     End;{CAse}
  End;
1:Begin
{ If Sel = 0 Then Assign (F,Path.ToClient+'Make.db')
  Else Assign (F,Path.ToClient+'Sklad.db');}
    Case Sel Of
     0:Assign (F,Path.ToClient+'Make.db');
     1:Assign (F,Path.ToClient+'Sklad.db');
     2:Assign (F,Path.ToClient+'Barter.db');
     3:Assign (F,Path.ToClient+'Lizo.db');
     Else;
     End;{CAse}
  End;
Else;
End;
r:=IOResult;
Reset(f);
r:=IOResult;

If R<>0 Then
 Begin
  NoInfo;
  Exit;
 End;

While Not(Eof(f)) Do
  Begin
   Read(f,Cl);
   r:=IOResult;

   cl.LockTime:=False;
   Seek(f,FilePos(f)-1);
   r:=IOResult;

   Write(f,cl);
   r:=IOResult;


   if (reg=0) and (sel=0) Then SaveTempLock(Cl.Kod,0,CurrentPAssword);



  End;
System.close(f);
   r:=IOResult;

NoInfo;
End;
End;


Procedure LockAllTemp;
Var  f : File Of ClientType;
     cl : ClientType;
     r : Byte;
     cod : ArtikulStr;
Begin
If Password(12) Then
Begin
AInfo('Минуточку...');
Case Reg Of
0:Begin
 {If Sel = 0 Then Assign (F,Path.ToClient+'Client.db')
  Else Assign (F,Path.ToClient+'Sklad.db');}
    Case Sel Of
     0:Assign (F,Path.ToClient+'Client.db');
     1:Assign (F,Path.ToClient+'Sklad.db');
     2:Assign (F,Path.ToClient+'Barter.db');
     Else;
     End;{CAse}
  End;
1:Begin
{ If Sel = 0 Then Assign (F,Path.ToClient+'Make.db')
  Else Assign (F,Path.ToClient+'Sklad.db');}
    Case Sel Of
     0:Assign (F,Path.ToClient+'Make.db');
     1:Assign (F,Path.ToClient+'Sklad.db');
     2:Assign (F,Path.ToClient+'Barter.db');
     Else;
     End;{CAse}
  End;
Else;
End;
r:=IOResult;
Reset(f);
r:=IOResult;
If R<>0 Then
 Begin
  NoInfo;
  Exit;
 End;

While Not(Eof(f)) Do
  Begin
   Read(f,Cl);
   r:=IOResult;

   cl.LockTime:=True;
   Seek(f,FilePos(f)-1);
   r:=IOResult;

   Write(f,cl);
   r:=IOResult;

   if (reg=0) and (sel=0) Then SaveTempLock(Cl.Kod,1,CurrentPAssword);

  End;
System.close(f);
   r:=IOResult;

NoInfo;
End;
End;





begin
  Case Event.What Of
  evKeyDown :
  Case Event.KeyCode Of
     kbDel: Begin
If Not(TestOpenDate1(FDate)) Then
   Begin
    MessageBox(#3^M+#3'Доступ к данным за '+FDate+' заблокирован!',Nil,mfError+mfCancelButton);
    ClearEvent(Event);
    Exit;
   End;
     L:=False;
     If Reg=0 Then
     Begin
      if (User[55] or (CurrentPassword='00')) then
      If (Client^.State and sfFocused <> 0) And (Client^.List<>Nil)And(Client^.List^.Count>=2) Then L:=True;
     End
     Else
     Begin
      if (User[52] or (CurrentPassword='00')) then
      If (MakeList^.State and sfFocused <> 0) And (MakeList^.List<>Nil)And(MakeList^.List^.Count>=2) Then L:=True;
     End;

     If L Then
            Begin

     If Password(3) Then
             Begin
             s:=#3^M+#3'Желаете удалить запись?';
             If MessageBox(s,nil,mfConfirmation+mfOkCancel)=cmOk
              Then
              Begin

                If Reg=0 Then
                s:=Client^.GetText(Client^.Focused,Client^.List^.Count)
                Else
                s:=MakeList^.GetText(MakeList^.Focused,MakeList^.List^.Count);
                s:=Copy(s,1+CClient+1,CClientKod);


                If (((StrToInt(s)=NotLockedCod1)And(Sel=VidNotLockedCod1))
                Or((StrToInt(s)=NotLockedCod2)And(Sel=VidNotLockedCod2))) Then
                Begin
                 ClearEvent(Event);
                 Beep;
                 DInfoMsg(' Клиент с кодом '+s+' сейчас Вами используется. Клиента нельзя удалить!');
                 ClearEvent(Event);
                 ClearEvent(Event);
                 repeat
                  Application^.GetEvent(Event);
                 until (Event.What <> evNothing);
                 NoInfoMsg;
                 ClearEvent(Event);
                 Exit;
                End;

              {сетевая блокировка}
               If Not(LockSelect) Then
                         Begin
                            ClearEvent(Event);
                   Redraw;
                   Exit;
                End;

                 test := IOResult;
                 If Reg=0 Then
                 s:=Client^.GetText(Client^.Focused,Client^.List^.Count)
                 Else
                 s:=MakeList^.GetText(MakeList^.Focused,MakeList^.List^.Count);
                 s:=Copy(s,1+CClient+1,CClientKod);

                 If (StrToInt(Rek.Kod)=StrToInt(s)) And (Sel=1) Then
                     Begin
                      ClearEvent(Event);
                      Repeat
                      Until (SetClientUnLock(s,Reg,Sel));
                      Exit;
                     End;

                 Case Reg Of
0:begin
 {If Sel = 0 Then Assign (ClientFile,Path.ToClient+'Client.db')
  Else Assign (ClientFile,Path.ToClient+'Sklad.db');}
     Case Sel Of
     0:Assign (ClientFile,Path.ToClient+'Client.db');
     1:Assign (ClientFile,Path.ToClient+'Sklad.db');
     2:Assign (ClientFile,Path.ToClient+'Barter.db');
     Else;
     End;{CAse}

  end;
1:begin
{ If Sel = 0 Then Assign (ClientFile,Path.ToClient+'Make.db')
  Else Assign (ClientFile,Path.ToClient+'Sklad.db');}
       Case Sel Of
     0:Assign (ClientFile,Path.ToClient+'Make.db');
     1:Assign (ClientFile,Path.ToClient+'Sklad.db');
     2:Assign (ClientFile,Path.ToClient+'Barter.db');
     Else;
     End;{CAse}

  end;
Else;
End;{CAse}
                 with ClientElement^.Dat do
                 begin
                  Name[0]:=#0;
                  Employ:=False;
                  Limit[0]:=#0;
                  Dogovor[0]:=#0;
                  For Test:=1 To CPunkt Do
                  Punkt[Test,0]:=#0;
                  Stat:=False;
                  Adress[0]:=#0;
                  Gorod[0]:=#0;
                  Gde[0]:=#0;
                  Test_Srok[0]:=#0;
                  LockTime:=False;

                  INN[0]:=#0;
                  R_Sh[0]:=#0;
                  SrokLizensia[0]:=#0;
                  Debit:=0;
                  ClientShkala:=0;
                  Messages[0]:=#0;
                  Kod:=s;
                  Locked:=True;
                 end;

  If Not (WriteLockClient(Reg,Sel,ClientElement^.Dat)) Then
    Begin
     MessageBox(^M+#3'Ошибка доступа к файлам клиентов !',nil,mfError+mfCanCelButton);
     Repeat
     Until (SetClientUnLock(s,Reg,Sel));
     ClearEvent(Event);
     Exit;
    End;
    Repeat
    Until (SetClientUnLock(s,Reg,Sel));
                 AddProtoCol('Удаление клиента:'+s,'','');
                 If (Reg=0)And(Sel=0) Then
                           If MessageBox(^M+#3+'Удалить файлы клиента?',Nil,MfWarning+mfOkCancel)=cmOk Then
                                                  DelDolgFile(s);
                 If Reg=0 Then
                 Begin
                  Client^.List^.AtFree(Client^.Focused);
                  Client^.SetRange(Client^.List^.Count);
                  If Client^.Focused>0 Then
                  Client^.FocusItem(Client^.Focused);
                  If (cLIENT^.Focused>=Client^.List^.Count) and(cLIENT^.Focused>0) Then
                  Client^.FocusItem(Client^.Focused-1);
                  End
                 Else
                 Begin
                  MakeList^.List^.AtFree(MakeList^.Focused);
                  MakeList^.SetRange(MakeList^.List^.Count);
                  If MakeList^.Focused>0 Then
                  MakeList^.FocusItem(MakeList^.Focused);
                  If (MakeList^.Focused>=MakeList^.List^.Count) and(MakeList^.Focused>0) Then
                  MakeList^.FocusItem(MakeList^.Focused-1);
                 End;

              End;
              End;
            ClearEvent(Event);
            End;
             Redraw;
            End;

kbF1: case sel of
      0:AboutChm('17');
      2:AboutChm('15');
      end;

kbCtrlRusD :if (User[58] or (CurrentPassword='00')) then
            Begin
                         If (Reg=0) And (Sel=0)  Then
                          Begin
                           If Not Password(7) Then
                                           Begin
                             ClearEvent(Event);
                                            Exit;
                            End;

                             s:=Client^.GetText(Client^.Focused,Client^.List^.Count);
                             s:=Copy(s,1+CClient+1,CClientKod);


                            If SetClientStatus(s,0,false) Then
                             Begin
                              SaveTempLock(s,0,CurrentPAssword);
                              MessageBox(^M#3'С клиента снята временная блокировка!'
                                                ,nil,mfInformation+mfCancelButton);
                              ClearEvent(Event);
                              Exit;
                             End;
                           End;
                             ClearEvent(Event);
             End;

kbAltRusD : if (User[58] or (CurrentPassword='00')) then
            Begin
                         If (Reg=0) And (Sel=0)  Then
                          Begin
                           If Not Password(7) Then
                                           Begin
                             ClearEvent(Event);
                                            Exit;
                            End;

                             s:=Client^.GetText(Client^.Focused,Client^.List^.Count);
                             s:=Copy(s,1+CClient+1,CClientKod);

                            If SetClientStatus(s,0,True) Then
                             Begin
                              SaveTempLock(s,1,CurrentPAssword);
                              MessageBox(^M#3'Клиент временно заблокирован!'
                                                ,nil,mfInformation+mfCancelButton);
                              ClearEvent(Event);
                              Exit;
                             End;
                           End;
                             ClearEvent(Event);
             End;
kbF3: Begin
       If (reg=0) And (Sel=0) Then

       If Not(LockSelect) Then
         Begin
          ClearEvent(Event);
          Exit;
         End;

       If Password(7) Then
       Begin
       s:=Client^.GetText(Client^.Focused,Client^.List^.Count);
       s:=Copy(s,1+CClient+1,CClientKod);
       Cod:=s;
       NNN^.ShowList(s);
         Repeat
         Until (SetClientUnLock(Cod,Reg,Sel));
       End;
       ClearEvent(Event);
       Redraw;
      End;

kbF9: Begin
       CorrectBaza(Reg,Sel);
       ClearEvent(Event);
       Redraw;
      End;

kbAlt1         : if (User[58] or (CurrentPassword='00')) then if Password(4) Then UnlockAll;
kbAlt2         : if (User[58] or (CurrentPassword='00')) then If MessageBox(^M+#3'Снять блокировки?',nil,mfOkCancel)=cmOk
Then UnlockAllTemp;
kbAlt3         : if (User[58] or (CurrentPassword='00')) then If MessageBox(^M+#3'Установить блокировки?',nil,mfOkCancel)=cmOk
                 Then LockAllTemp;
kbAlt4         : SetupPeriodLockAllTemp(Reg,Sel);
kbAlt5         : SetupProzAll(Reg,Sel);


kbGrayPlus,kbF4: Begin
     L:=False;
     If Reg=0 Then
     Begin
If(Client^.State and sfFocused <> 0)And(Not(Event.KeyCode=kbF4))Or
((Event.KeyCode=kbF4)And(Client^.List<>Nil)And(Client^.List^.Count>=1)) Then l:=True;
     End
     Else
     Begin
If(MAkeList^.State and sfFocused <> 0)And(Not(Event.KeyCode=kbF4))Or
((Event.KeyCode=kbF4)And(MAkeList^.List<>Nil)And(MakeList^.List^.Count>=1)) Then l:=True;
     End;
            If L Then
            Begin
              {сетевая блокировка}
             If Event.KeyCode=kbF4 Then
               If (Reg=0) And (Sel=0) Then If Not Password(5) Then Exit
                    Else
                    Begin
               If Not(LockSelect) Then
                         Begin
                            ClearEvent(Event);
                   Exit;
                End;
              End;
            Case Reg Of
            0:Begin
              if (User[54] or (CurrentPassword='00')) then
               If AddClient(Event.KeyCode,ClientElement^.Dat,Sel,Debitors) Then
               Begin
               If (Event.KeyCode=kbF4)And(Client^.List<>Nil)And(Client^.List^.Count>=1) Then
                Client^.List^.AtFree(Client^.Focused);
                Format(ClientElement^.Dat.Name,CClient);
                Client^.List^.Insert(NewStr(ClientElement^.Dat.Name+'│'+ClientElement^.Dat.Kod));
                Client^.SetRange(Client^.List^.Count);
                Client^.FocusItem(LoCation(Client,ClientElement^.Dat.Kod,ProdagaWindow));
                Redraw;
               End
              End;
            1:Begin
             if (User[51] or (CurrentPassword='00')) then
             If AddMake(Event.KeyCode,MakeElement^.Dat,Sel,Debitors) Then
              Begin
              If (Event.KeyCode=kbF4)And(MakeList^.List<>Nil)And(MakeList^.List^.Count>=1) Then
               MakeList^.List^.AtFree(MakeList^.Focused);
               Format(MakeElement^.Dat.Name,CMake);
               MakeList^.List^.Insert(NewStr(MakeElement^.Dat.Name+'│'+MakeElement^.Dat.Kod));
               MakeList^.SetRange(MakeList^.List^.Count);
               MakeList^.FocusItem(LoCation(MakeList,MakeElement^.Dat.Kod,ProdagaWindow));
               Redraw;
              End
              End;
            Else;
            End;{Case}
            If Event.KeyCode=kbF4 Then
            Begin
               If Reg=0 Then Cod:=ClientElement^.Dat.Kod;
               If Reg=1 Then Cod:=MakeElement^.Dat.Kod;

               If Not(((StrToInt(Cod)=NotLockedCod1)And(Sel=VidNotLockedCod1))
                Or((StrToInt(Cod)=NotLockedCod2)And(Sel=VidNotLockedCod2))) Then

{                 If (StrToInt(Cod)<>NotLockedCod1)
                          And(StrToInt(Cod)<>NotLockedCod2) Then}
               Repeat
               Until (SetClientUnLock(Cod,Reg,Sel));
            End;
            End;
            ClearEvent(Event);
            Redraw;
            End;
{     kbEsc: Begin
              Event.What:=evCommand;
              Event.Command:=cmCancel;
              PutEvent(Event);
            End;
     kbShiftTab,kbCtrlLeft:
            Begin
              Event.What:=evCommand;
              Event.Command:=cmYes;
              PutEvent(Event);
            End;
     kbTab,kbCtrlRight,kbEnter:
            Begin
              Event.What:=evCommand;
              Event.Command:=cmOk;
              PutEvent(Event);
            End;
}      Else;
      End;{KeyDown}
evCommand:
 Case Event.Command Of
 cmRefresh: Refresh(Reg,Sel);
 cmPrintReestr:
  Begin
     l:=False;
     If Reg=0 Then
     Begin
If(Client^.State and sfFocused <> 0)And(Client^.List<>Nil)And(Client^.List^.Count>=1) Then l:=True;
     End
     Else
     Begin
If(MAkeList^.State and sfFocused <> 0)And(MAkeList^.List<>Nil)And(MakeList^.List^.Count>=1) Then l:=True;
     End;
     If l Then
      Begin
               If Reg=0 Then
               s:=Client^.GetText(Client^.Focused,Client^.List^.Count)
               Else
               s:=MakeList^.GetText(MakeList^.Focused,MakeList^.List^.Count);
               s:=Copy(s,1+CClient+1,CClientKod);

               if (User[57] or (CurrentPassword='00')) then
               If Password(3) Then
                         Begin
                          If Password(5) Then PrintClientInfo(s,Reg,Sel);
                 AddProtocol('Печать реквизитов клиента ('+s+')','','');
                End;
      End;

  End;

  Else;
  End;{evCommand}
      Else;
      End;{*Case*}

  if ((Event.What = evMouseDown) and (Event.Double)) or
     ((Event.What = evKeyDown) and (Event.KeyCode =kbEnter)) Or
     ((Event.What = evKeyDown) and (Event.KeyCode =kbCtrlEnter)) Or
     ((Event.What = evKeyDown) and (Event.KeyCode =kbTab)) Or
     ((Event.What = evKeyDown) and (Event.KeyCode =kbCtrlRight)) Then
  begin
              Event.What:=evCommand;
              Event.Command:=cmOk;
              PutEvent(Event);
              ClearEvent(Event);
  end;
  if ((Event.What = evKeyDown) and (Event.KeyCode =kbShiftTab))Or
     ((Event.What = evKeyDown) and (Event.KeyCode =kbCtrlLeft)) Then
  begin

              Event.What:=evCommand;
              Event.Command:=cmYes;
              PutEvent(Event);
              ClearEvent(Event);

  end;

  if ((Event.What = evKeyDown) and (Event.KeyCode = kbEsc))then
  begin
              Event.What:=evCommand;
              Event.Command:=cmCancel;
              PutEvent(Event);
              ClearEvent(Event);
  end;

 Case Event.What Of
 EvCommand : Begin
             Case Event.Command Of
 cmCancel,cmYes,cmOk,cmNo,cmClose,cmQuit
                     : Begin
                        If WithTestSrok Then
                         Begin
                          If (Reg=0) And (Sel=0) Then
                           Begin
                             s:=Client^.GetText(Client^.Focused,Client^.List^.Count);
                             s:=Copy(s,1+CClient+1,CClientKod);

                            If GetClientStatus(s,0) Then
                             Begin
                              SpecialBeep;
                              MessageBox(^M+#3'Клиент временно заблокирован!'^M+
                                                #3'Немедленно позовите руководство!',
                                                nil,mfInformation+mfCancelButton);

                              ClearEvent(Event);
                              Exit;
                             End;
                           End;
                         End;


                        If WithNetLock  Then
                         Begin
                          If Not(LockSelect) Then
                                   Begin
                                    ClearEvent(Event);
                                    Exit;
                                   End;
                         End
                        Else
                         Begin
                          If Not(TestEmploy) Then
                                   Begin
                                    ClearEvent(Event);
                                    Exit;
                                   End;
                         End;
                       End;

             Else Exit;
             End;
             End;
 Else;
 End;

 if (Event.What = evBroadcast) and
     (Event.Command = cmSelectClient) then ClearEvent(Event);


  inherited HandleEvent(Event);
  If (Desktop^.Current=PView(CLientWindow)) And (Event.What <> EvKeyDown) Then
          Begin
             Case Reg Of
             0:Begin
                If (Client^.List <> Nil) And (Client^.List^.Count>=1) Then
                 Begin
                  s:=Client^.GetText(Client^.Focused,Client^.List^.Count);
                  If s<>PrevClient Then
                   Begin
                    PrevClient:=S;
                    DrawCurrent(Reg,Sel);
                   End;
                 End;

               End;{0}
             1:Begin
                If (MakeList^.List <> Nil) And (MAkeList^.List^.Count>=1) Then
                 Begin
                  s:=MakeList^.GetText(MAkeList^.Focused,MakeList^.List^.Count);
                  If s<>PrevClient Then
                   Begin
                    PrevClient:=S;
                    DrawCurrent(Reg,Sel);
                   End;

                 End;

               End;{1}
             Else;
             End;{Case}
          End;
{
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
}
  ClearEvent(Event);
end;


Procedure TRazdelWindow.ShowRazdelList(Var st:AllStr;Var Res: Word;l:Boolean);
Label 1;
var
  R : TRect;
  Control : PView;
  s : AllStr;
  c: Word;
  fGroup: text;
begin
ClearFind;
NoDelete:=L;
AInfo('Читаю список разделов...');

Res:=0;
R.Assign(13, 3, 66, 20);
New(RazdelWindow, Init(R, 'Выбор раздела'));
RazdelWindow^.Options := RazdelWindow^.Options or ofCenterX or ofCenterY;

R.Assign(52, 1, 53, 16);
Control := New(PScrollBar, Init(R));
RazdelWindow^.Insert(Control);

R.Assign(1, 1, 52, 16);
Razdel := New(PBox, Init(R, 2, PScrollbar(Control)));
Razdel^.NewList(New(PTextCollection, Init(0,1)));

Assign (RazdelFile,Path.ToRazdel+'Razdel.db');

c:=IOResult;
Reset (RazdelFile);
c:=IOResult;
If c=0 Then
Begin
While Not(Eof(RazdelFile)) Do
 Begin
  Read(RazdelFile,RazdelElement);
  If RazdelElement.Employ Then
   Begin
    Format (RazdelElement.Name,CRazdel);
    Razdel^.List^.Insert(NewStr(RazdelElement.Name+'│'+RazdelElement.Kod));
    Razdel^.SetRange(Razdel^.List^.Count);
   End;
 End;
System.Close(RazdelFile);
End
Else
 Begin
  NoInfo;
  MessageBox(^M+#3'Ошибка открытия файла разделов!',nil,mfError+mfCancelButton);
  Goto 1;
 End;
s:=Copy(st,1+CRazdel+1,CRazdelKod);
Razdel^.FocusItem(Location(Razdel,S,ProdagaWindow));
Razdel^.HelpCtx:=$E166;
RazdelWindow^.Insert(Razdel);

RazdelWindow^.SelectNext(False);

R.Assign(0, 0, 0, 0);
Group := New(PBox, Init(R, 1,nil));
Group^.NewList(New(PTextCollection, Init(0,1)));

Assign(fGroup,Path.ToSklad+'group.txt');
c:=ioresult;
Reset(fGroup);
c:=ioresult;

If c=0 Then
Begin
While Not(Eof(fGroup)) Do
 Begin
  Readln(fGroup,s);
  Group^.List^.Insert(NewStr(s));
  Group^.SetRange(Group^.List^.Count);
 End;
System.Close(fGroup);
End;

NoInfo;
c:=Desktop^.ExecView(RazdelWindow);
   If c=CmOk Then Res:=2;
   If c=CmYes Then Res:=3;
   If c=CmCancel Then Res:=1;
   St:=Razdel^.GetText(Razdel^.Focused,Razdel^.List^.Count);
1:
Dispose(RazdelWindow,Done);
end;


Destructor TRazdelWindow.Done;
Begin
ClearFind;
Dispose(Razdel,Done);
TDialog.Done;
End;


Procedure LockUnlock(c:ArtikulStr;LockRegim:Word);
Var
    bazF : File Of BazType;
    b : PBazType;
    i : Word;
Begin
 Assign(Bazf,Path.ToName+c+'.id');
 i:=IOResult;
 Reset(Bazf);
 i:=IOResult;
 If i<>0 Then
  Begin
   MessageBox(^M+#3+'Ошибка открытия '+Path.ToName+c+'.id',Nil,mfError+mfCancelButton);
   Exit;
  End;
 New(B,Init);
  While Not(Eof(BazF)) Do
   Begin

     Repeat
     Pause(1);
     Until Lock(BazF,FilePos(BazF)*SizeOf(BazType),SizeOf(BazType));

     Read(BazF,b^.Dat);
     If B^.Dat.Employ Then
     Begin
      B^.Dat.Market:=LockRegim;
      Seek(BazF,FilePos(BazF)-1);
      Write(BazF,B^.Dat);
     End;

     Repeat
     Unlock(Bazf,(FilePos(Bazf)-1)*SizeOf(BazType),SizeOf(BazType));
     Until DosError=0;

   End;
 Close(BazF);
 Dispose(B,Done);
 MessageBox(^M+#3+'Операция успешно завершена!',Nil,mfInformation+mfCancelButton);
End;

Procedure SetMinimum(c:ArtikulStr);
Var
    bazF : File Of BazType;
    b : PBazType;
    i : Word;
Begin
 Assign(Bazf,Path.ToName+c+'.id');
 i:=IOResult;
 Reset(Bazf);
 i:=IOResult;
 If i<>0 Then
  Begin
   MessageBox(^M+#3+'Ошибка открытия '+Path.ToName+c+'.id',Nil,mfError+mfCancelButton);
   Exit;
  End;
 New(B,Init);
  While Not(Eof(BazF)) Do
   Begin

     Repeat
     Pause(1);
     Until Lock(BazF,FilePos(BazF)*SizeOf(BazType),SizeOf(BazType));

     Read(BazF,b^.Dat);
     If B^.Dat.Employ Then
     Begin
      B^.Dat.Minimum:='5';
      Seek(BazF,FilePos(BazF)-1);
      Write(BazF,B^.Dat);
     End;

     Repeat
     Unlock(Bazf,(FilePos(Bazf)-1)*SizeOf(BazType),SizeOf(BazType));
     Until DosError=0;

   End;
 Close(BazF);
 Dispose(B,Done);
 MessageBox(^M+#3+'Операция успешно завершена!',Nil,mfInformation+mfCancelButton);
End;


Procedure LockUnlockNalog(c:ArtikulStr;LockRegim:Word);
Var
    bazF : File Of BazType;
    b : PBazType;
    i : Word;
Begin
 Assign(Bazf,Path.ToName+c+'.id');
 i:=IOResult;
 Reset(Bazf);
 i:=IOResult;
 If i<>0 Then
  Begin
   MessageBox(^M+#3+'Ошибка открытия '+Path.ToName+c+'.id',Nil,mfError+mfCancelButton);
   Exit;
  End;
 New(B,Init);
  While Not(Eof(BazF)) Do
   Begin

     Repeat
     Pause(1);
     Until Lock(BazF,FilePos(BazF)*SizeOf(BazType),SizeOf(BazType));

     Read(BazF,b^.Dat);
     If B^.Dat.Employ Then
     Begin
      B^.Dat.VidNDS:=LockRegim;
      Case LockRegim Of
      0:B^.Dat.NDS:='18.00';
      1:B^.Dat.NDS:='10.00';
      Else B^.Dat.NDS:='0.00';
      End;{Case}
      Seek(BazF,FilePos(BazF)-1);
      Write(BazF,B^.Dat);
     End;

     Repeat
     Unlock(Bazf,(FilePos(Bazf)-1)*SizeOf(BazType),SizeOf(BazType));
     Until DosError=0;

   End;
 Close(BazF);
 Dispose(B,Done);
 MessageBox(^M+#3+'Операция успешно завершена!',Nil,mfInformation+mfCancelButton);
End;



Procedure SetOtdelStatus(c:ArtikulStr;LockRegim:Word;Value:Word);
Var
    bazF : File Of BazType;
    b : PBazType;
    i : Word;
    MMM : MaskaNew;
Begin
 Assign(Bazf,Path.ToName+c+'.id');
 i:=IOResult;
 Reset(Bazf);
 i:=IOResult;
 If i<>0 Then
  Begin
   MessageBox(^M+#3+'Ошибка открытия '+Path.ToName+c+'.id',Nil,mfError+mfCancelButton);
   Exit;
  End;
 New(B,Init);
  While Not(Eof(BazF)) Do
   Begin

     Repeat
     Pause(1);
     Until Lock(BazF,FilePos(BazF)*SizeOf(BazType),SizeOf(BazType));

     Read(BazF,b^.Dat);
     If B^.Dat.Employ Then
     Begin
      WordToBitNew(B^.DAt.EnableOtdel,MMM);
      Convertnew(MMM);
      MMM[LockRegim]:=Value;
      Convertnew(MMM);
      BitToWordnew(MMM,B^.DAt.EnableOtdel);
      Seek(BazF,FilePos(BazF)-1);
      Write(BazF,B^.Dat);
     End;

     Repeat
     Unlock(Bazf,(FilePos(Bazf)-1)*SizeOf(BazType),SizeOf(BazType));
     Until DosError=0;

   End;
 Close(BazF);
 Dispose(B,Done);
 MessageBox(^M+#3+'Операция успешно завершена!',Nil,mfInformation+mfCancelButton);
End;





procedure TRazdelWindow.HandleEvent(var Event: TEvent);
Var R : TRect;
    test : Word;
    s : TMyString;
    L : Boolean;
    Regim : Word;
begin
  Case Event.What Of
  evKeyDown :
  Case Event.KeyCode Of
     kbF1: AboutChm('16');
     kbDel: if (User[60] or (CurrentPassword='00')) then
	Begin
If Not(TestOpenDate1(FDate)) Then
   Begin
    MessageBox(#3^M+#3'Доступ к данным за '+FDate+' заблокирован!',Nil,mfError+mfCancelButton);
    ClearEvent(Event);
    Exit;
   End;
      If (Razdel^.State and sfFocused <> 0) And (Razdel^.List<>Nil)And(Razdel^.List^.Count>=2) Then
            Begin
             If Password(3) Then
             Begin
             If MessageBox(#3+DelRazdel,nil,mfConfirmation+mfOkCancel)=cmOk
              Then
              Begin
               test := IOResult;
               s:=Razdel^.GetText(Razdel^.Focused,Razdel^.List^.Count);
               s:=Copy(s,1+CRazdel+1,CRazdelKod);
               Assign (RazdelFile,Path.ToRazdel+'razdel.db');
               Reset(RazdelFile);
               Test:=IOResult;
               If (Test=0) Then
                Begin
                 Seek(RazdelFile,GetFileLocation3(s){-1});
                 RazdelElement.Name[0]:=#0;
                 RazdelElement.Designation[0]:=#0;
                 RazdelElement.EnableLitr:=0;
                 RazdelElement.Employ:=False;
                 RazdelElement.Locked:=False;
                 RazdelElement.Kod:=s;
                 Write(RazdelFile,RazdelElement);
                 System.Close(RazdelFile);
                 AddProtoCol('Удаление раздела:'+s,'','');
                 Razdel^.List^.AtFree(Razdel^.Focused);
                 Razdel^.SetRange(Razdel^.List^.Count);
                 If Razdel^.Focused>0 Then
                 Razdel^.FocusItem(Razdel^.Focused);

                 If (Razdel^.Focused>=Razdel^.List^.Count) and(Razdel^.Focused>0) Then
                 Razdel^.FocusItem(Razdel^.Focused-1);

                End
                Else
                MessageBox(#3+ErrorRazdelFile,nil,mfError+mfCanCelButton);
              End
             End;
             End;
            ClearEvent(Event);
             Redraw;
            End;
kbGrayPlus,kbF4: Begin
if  ((User[61] or (CurrentPassword='00')) and (Event.KeyCode=kbF4))
or ((User[59] or (CurrentPassword='00')) and (Event.KeyCode=kbGrayPlus)) then
{
If Not(TestOpenDate(FDate)) Then
   Begin
    MessageBox(#3^M+#3'Доступ к данным за '+FDate+' заблокирован!',Nil,mfError+mfCancelButton);
    ClearEvent(Event);
    Exit;
   End;
}
If((Razdel^.State and sfFocused <> 0)And(Razdel^.List^.Count>=1)And Not(Event.KeyCode=kbF4))Or
  ((Event.KeyCode=kbF4)And(Razdel^.List<>Nil)And(Razdel^.List^.Count>=1)) Then
            Begin
             If AddRazdel(Event.KeyCode,RazdelElement) Then
              Begin
              If (Event.KeyCode=kbF4)And(Razdel^.List<>Nil)And(Razdel^.List^.Count>=1) Then
               Razdel^.List^.AtFree(Razdel^.Focused);
               Format(RazdelElement.Name,CRazdel);
               Razdel^.List^.Insert(NewStr(RazdelElement.Name+'│'+RazdelElement.Kod));
               Razdel^.SetRange(Razdel^.List^.Count);
               Razdel^.FocusItem(LoCation(Razdel,RazdelElement.Kod,ProdagaWindow));
               Redraw;
              End;
            End;
            ClearEvent(Event);
            Redraw;
            End;
     kbF6: Begin
            If Not(StrToInt(CurrentPassword)=0) Then Exit;
If Not(TestOpenDate1(FDate)) Then
   Begin
    MessageBox(#3^M+#3'Доступ к данным за '+FDate+' заблокирован!',Nil,mfError+mfCancelButton);
    ClearEvent(Event);
    Exit;
   End;

If(Razdel^.State and sfFocused <> 0)And(Razdel^.List^.Count>=1) Then
            Begin
             If MessageBox(^M+#3+'Установить минимум = 5 на все наименования раздела?',Nil,mfOkCancel) = cmOk Then
              Begin
                s:=Razdel^.GetText(Razdel^.Focused,Razdel^.List^.Count);
                s:=Copy(s,1+CRazdel+1,CRazdelKod);
                SetMinimum(s);
                Redraw;
              End;
            End;
            ClearEvent(Event);
            Redraw;
           End;

     kbF7: Begin

If Not(TestOpenDate1(FDate)) Then
   Begin
    MessageBox(#3^M+#3'Доступ к данным за '+FDate+' заблокирован!',Nil,mfError+mfCancelButton);
    ClearEvent(Event);
    Exit;
   End;

If(Razdel^.State and sfFocused <> 0)And(Razdel^.List^.Count>=1) Then
            Begin
             If MessageBox(^M+#3+'Деблокировать все наименования раздела?',Nil,mfOkCancel) = cmOk Then
              Begin
                s:=Razdel^.GetText(Razdel^.Focused,Razdel^.List^.Count);
                s:=Copy(s,1+CRazdel+1,CRazdelKod);
                LockUnLock(s,1);
                Redraw;
              End;
            End;
            ClearEvent(Event);
            Redraw;
           End;


          kbF9: if (User[62] or (CurrentPassword='00')) then
		Begin
If PAssword(2) Then
If(Razdel^.State and sfFocused <> 0)And(Razdel^.List^.Count>=1) Then
                                Begin
                                 s:=Copy(Razdel^.GetText(Razdel^.Focused,Razdel^.List^.Count),1+CRAzdel+1,CRAzdelKod);
                                 CorrectRazdel(StrToInt(s));
                                End;
                          End;


 kbCtrlF9: Begin
If Not(TestOpenDate1(FDate)) Then
   Begin
    MessageBox(#3^M+#3'Доступ к данным за '+FDate+' заблокирован!',Nil,mfError+mfCancelButton);
    ClearEvent(Event);
    Exit;
   End;

If(Razdel^.State and sfFocused <> 0)And(Razdel^.List^.Count>=1) Then
            Begin
             If MessageBox(^M+#3+'Блокировать все наименования раздела?',Nil,mfOkCancel) = cmOk Then
              Begin
                s:=Razdel^.GetText(Razdel^.Focused,Razdel^.List^.Count);
                s:=Copy(s,1+CRazdel+1,CRazdelKod);
                LockUnLock(s,0);
                Redraw;
              End;
            End;
            ClearEvent(Event);
            Redraw;
           End;

kbAlt1,kbAlt2,kbAlt3 :
      Begin
If Not(TestOpenDate1(FDate)) Then
   Begin
    MessageBox(#3^M+#3'Доступ к данным за '+FDate+' заблокирован!',Nil,mfError+mfCancelButton);
    ClearEvent(Event);
    Exit;
   End;

If StrToInt(CurrentPassword)<>0 Then
   If Not Password(4) Then
   Begin
    ClearEvent(Event);
    Exit;
   End;

   Case Event.KeyCode Of
   kbAlt1:Begin
           s:=^M+#3+'Установить НДС=18%?';
           Regim:=0;
          End;
   kbAlt2:Begin
           s:=^M+#3+'Установить НДС=10%?';
           Regim:=1;
          End;
   kbAlt3:Begin
           s:=^M+#3+'Установить для НДС=0%?';
           Regim:=2;
          End;
   End;




If(Razdel^.State and sfFocused <> 0)And(Razdel^.List^.Count>=1) Then
            Begin
             If MessageBox(s,Nil,mfOkCancel) = cmOk Then
              Begin
                s:=Razdel^.GetText(Razdel^.Focused,Razdel^.List^.Count);

                s:=Copy(s,Pos('│',s)+1,CRazdelKod);
                LockUnLockNalog(s,0);
                AddProtoCol('Изменение НДС для раздела '+s,'','');
                Redraw;
              End;
            End;
            ClearEvent(Event);
            Redraw;
           End;


kbAltF1,kbAltF2,kbAltF3,kbAltF4,kbAltF5,kbAltF6,kbAltF7,kbAltF8 :
      Begin
If Not(TestOpenDate1(FDate)) Then
   Begin
    MessageBox(#3^M+#3'Доступ к данным за '+FDate+' заблокирован!',Nil,mfError+mfCancelButton);
    ClearEvent(Event);
    Exit;
   End;

If StrToInt(CurrentPassword)<>0 Then
   If Not Password(4) Then
   Begin
    ClearEvent(Event);
    Exit;
   End;

   Case Event.KeyCode Of
   kbAltF1:Begin
           s:=^M+#3+'разреш 1 отд?';
           Regim:=1;
          End;
   kbAltF2:Begin
           s:=^M+#3+'разреш 2 отд?';
           Regim:=2;
          End;
   kbAltF3:Begin
           s:=^M+#3+'разреш 3 отд?';
           Regim:=3;
          End;
   kbAltF4:Begin
           s:=^M+#3+'разреш 4 отд?';
           Regim:=4;
          End;
   kbAltF5:Begin
           s:=^M+#3+'разреш 5 отд?';
           Regim:=5;
          End;
   kbAltF6:Begin
           s:=^M+#3+'разреш 6 отд?';
           Regim:=6;
          End;
   kbAltF7:Begin
           s:=^M+#3+'разреш 7 отд?';
           Regim:=7;
          End;
   kbAltF8:Begin
           s:=^M+#3+'разреш 8 отд?';
           Regim:=8;
          End;
   End;
If(Razdel^.State and sfFocused <> 0)And(Razdel^.List^.Count>=1) Then
            Begin
             If MessageBox(s,Nil,mfOkCancel) = cmOk Then
              Begin
                s:=Razdel^.GetText(Razdel^.Focused,Razdel^.List^.Count);

                s:=Copy(s,Pos('│',s)+1,CRazdelKod);
                SetOtdelStatus(s,Regim,1);
                AddProtoCol('Изменение разрешенных отделений для раздела '+s,'','');
                Redraw;
              End;
            End;
            ClearEvent(Event);
            Redraw;
           End;

kbCtrlF1,kbCtrlF2,kbCtrlF3,kbCtrlF4,kbCtrlF5,kbCtrlF6,kbCtrlF7,kbCtrlF8 :
      Begin
If Not(TestOpenDate1(FDate)) Then
   Begin
    MessageBox(#3^M+#3'Доступ к данным за '+FDate+' заблокирован!',Nil,mfError+mfCancelButton);
    ClearEvent(Event);
    Exit;
   End;

If StrToInt(CurrentPassword)<>0 Then
   If Not Password(4) Then
   Begin
    ClearEvent(Event);
    Exit;
   End;

   Case Event.KeyCode Of
   kbCtrlF1:Begin
           s:=^M+#3+'1 отд?';
           Regim:=1;
          End;
   kbCtrlF2:Begin
           s:=^M+#3+'2 отд?';
           Regim:=2;
          End;
   kbCtrlF3:Begin
           s:=^M+#3+'3 отд?';
           Regim:=3;
          End;
   kbCtrlF4:Begin
           s:=^M+#3+'4 отд?';
           Regim:=4;
          End;
   kbCtrlF5:Begin
           s:=^M+#3+'5 отд?';
           Regim:=5;
          End;
   kbCtrlF6:Begin
           s:=^M+#3+'6 отд?';
           Regim:=6;
          End;
   kbCtrlF7:Begin
           s:=^M+#3+'7 отд?';
           Regim:=7;
          End;
   kbCtrlF8:Begin
           s:=^M+#3+'8 отд?';
           Regim:=8;
          End;
   End;
If(Razdel^.State and sfFocused <> 0)And(Razdel^.List^.Count>=1) Then
            Begin
             If MessageBox(s,Nil,mfOkCancel) = cmOk Then
              Begin
                s:=Razdel^.GetText(Razdel^.Focused,Razdel^.List^.Count);

                s:=Copy(s,Pos('│',s)+1,CRazdelKod);
                SetOtdelStatus(s,Regim,0);
                AddProtoCol('Изменение запр отдел раздела '+s,'','');
                Redraw;
              End;
            End;
            ClearEvent(Event);
            Redraw;
           End;



      Else;
      End;{KeyDown}
      Else;
      End;{*Case*}

  if ((Event.What = evMouseDown) and (Event.Double)) or
     ((Event.What = evKeyDown) and (Event.KeyCode =kbEnter)) Or
     ((Event.What = evKeyDown) and (Event.KeyCode =kbTab)) Or
     ((Event.What = evKeyDown) and (Event.KeyCode =kbCtrlRight)) Then
  begin
              Event.What:=evCommand;
              Event.Command:=cmOk;
              PutEvent(Event);
  end;
  if ((Event.What = evKeyDown) and (Event.KeyCode =kbShiftTab))Or
     ((Event.What = evKeyDown) and (Event.KeyCode =kbCtrlLeft)) Then
  begin
              Event.What:=evCommand;
              Event.Command:=cmYes;
              PutEvent(Event);
  end;
  if ((Event.What = evKeyDown) and (Event.KeyCode = kbEsc))then
  begin
              Event.What:=evCommand;
              Event.Command:=cmCancel;
              PutEvent(Event);
  end;

 if (Event.What = evBroadcast) and
     (Event.Command = cmSelectRazdel) then ClearEvent(Event);

  inherited HandleEvent(Event);
  ClearEvent(Event);
end;

Function LockSelectName(S:ArtikulStr):Boolean;
Var
    Event : TEvent;
    R : Boolean;
    Msg : StrNAme;
Begin
  LockSelectName:=False;
  R:=GetIdEmploy(s);
  If Not(r) Then
   Begin
    Beep;
    DInfoMsg('Позиция ['+s+'] отмечена как удаленная.');
    Application^.ClearEvent(Event);
    Application^.ClearEvent(Event);
    repeat
    Application^.GetEvent(Event);
    {until (Event.What in [evKeyDown,evMouseDown]);}
    until (Event.What <> evNothing);
    NoInfoMsg;
    Application^.ClearEvent(Event);
    Application^.ClearEvent(Event);
    Exit;
   End;

  If SetNameLock(s,Msg) Then LockSelectName:=True
  Else
   Begin
    Beep;
    DInfoMsg('Позиция ['+s+'] используется'+Msg+'.');
    Application^.ClearEvent(Event);
    Application^.ClearEvent(Event);
    repeat
    Application^.GetEvent(Event);
    {until (Event.What in [evKeyDown,evMouseDown]);}
    until (Event.What <> evNothing);
    NoInfoMsg;
    Application^.ClearEvent(Event);
    Application^.ClearEvent(Event);
   End;
End;







{$IFNDEF KURZ}


Function TestSrokLizensia(c:AllStr;Date:TDateString):Boolean;
Var f : ClientFileType;
    l : LongInt;
    Code : Integer;
    s : ClientType;
    st : ArtikulStr;
Begin
 Assign(f,Path.ToClient+'Client.db');
 TestSrokLizensia:=False;
 l:=IOResult;
 Reset(f);
 l:=IOResult;
 If l <> 0 Then
 Begin
  MessageBox(#3'Ошибка открытия файла клиентов!',nil,mfError+mfCancelButton);
  Exit;
 End
 Else
  Begin
   DelSpace(c);
   l:=StrToInt(c);
   Seek(f,l);
     {
     Repeat
     Until NetCall.Lock(f,FilePos(f)*SizeOf(ClientType),SizeOf(ClientType));
     }
     ReadClient(f,s);
     {
     Repeat
      NetCall.UnLock(f,(FilePos(f)-1)*SizeOf(ClientType),SizeOf(ClientType));
     Until (DosError=0);
     }
   Close(f);
   {l:=DateStringToDate(DateMask,S.SrokLizensia);}
   DelSpace(S.SrokLizensia);
   If (DateStringToDate(DateMAsk,Date)<=DateStringToDate(DateMask,S.SrokLizensia))And
      (S.SrokLizensia[0]<>#0)  Then
   TestSrokLizensia:=True;
  End;
End;



{$ELSE}


Function TestSrokLizensia(c:AllStr;Date:TDateString):Boolean;
Begin
End;

Function DeleteOfStatFile(PrevMarket:PSuperMarketType):Boolean;
Begin
End;

Function SpisDolgFromZerroDocRealiz(L:PSuperMarketType):Boolean;
Begin
End;


{$ENDIF}


End.