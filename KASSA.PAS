{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}

{$I Compile.INC}
Unit Kassa;

Interface

Uses Glob,Dialogs,Drivers,Access,Access1,ServStr,Avans;


 Type PLizoWindow= ^TLizoWindow;
     TLizoWindow = object(TDialog)
    Procedure PrintAgentInfo(s:ArtikulStr);
    Procedure ShowAgentList(Var st:AllStr;Var Res: Word);
    Procedure DrawCurrent;
    Procedure Refresh;
    procedure HandleEvent(var Event: TEvent); virtual;
    Destructor Done;Virtual;
  end;


Type
  PAddOperation = ^TAddOperation;
  TAddOperation = object(TDialog)
    SelOperation : POperationWindow;
    procedure Start(dolg: boolean; AS: DocumentEdit);
    procedure HandleEvent(var Event: TEvent); virtual;
  end;

Type
  PDopAddOperation = ^TDopAddOperation;
  TDopAddOperation = object(TDialog)
    procedure Start;
    procedure HandleEvent(var Event: TEvent); virtual;
  end;


Type
  PReestrKWindow = ^TReestrKWindow;
  TReestrKWindow = object(TDialog)
    Op : PAddOperation;
    AS:DocumentEdit;
    constructor Init(Var l: Boolean);
    procedure OpenReestrWindow;
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure DrawCurrent;
    Procedure FormReport(Const p:PBox);
    procedure Refresh;
    procedure Print(Const p:PBox);
  end;

Type
  PDopReestrKWindow = ^TDopReestrKWindow;
  TDopReestrKWindow = object(TDialog)
    Op : PDopAddOperation;
    constructor Init(Var l: Boolean);
    procedure OpenReestrWindow;
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure DrawCurrent;
    procedure Refresh;
  end;

var bDolg: boolean;
    PrevS: TMyString;

Implementation

uses DBEngine,Objects, Views, MsgBox,{Vision,Calc,}Dos,
     Vision1,TpDate,Utils,Protect,Validate,Prise,Sotrudn,
     Vision5,App, ColorTxt,Serv,{InpLong,{Validate,}Tools,
	Printers,ComboBox,NetDbEng,Net,UtilsP;

var
 DocList, DopDocList : PBox;
 PrevCur : String[170];
 DocReestrWindow:PReestrKWindow;
 DopDocReestrWindow:PDopReestrKWindow;
 DopReestrKWindow:PDopReestrKWindow;
 DocDate,StopDAte : TDateString;
 ControlItogoMinus,ControlItogoPlus,ControlAll,ControlHeader,
 ControlSotr,ControlCom,Control:PView;
 DopControlItogoMinus,DopControlItogoPlus,DopControlAll,DopControlHeader,
 DopControlSotr,DopControlCom,DopControl:PView;
 Direction ,Sorting : Word;
 StartTime:LongInt;
 RefreshTime:LongInt;
 ActivMas:Maska2;
 M3:Maska3;
 ControlNameOperation,ControlComment,ControlSumma : PView;
 DControlComment,DControlSumma : PView;
 ControlLizo:PView;
 Activ,FiltrSf,Filtr : Word;
 AddWindow : PAddOperation;
 AdddOPWindow : PDopAddOperation;
 NameOperation : TMyString;
 All,AllDoc,AllPlus,AllMinus : String[CIZena];
 FiltrList : PBox;
 LizoWindow : PLizoWindow;
 PrevAgent : String[CAll];
 KassaElement : KassaOperation;
 KassaFile : OperationFileType;
 EditKassa: DocumentEdit;

Function ViewLizo(Art:ArtikulStr):Boolean;
var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  s : TEnjoyStr;{!!!}
  j,c: Word;
  Full : Boolean;
  k : LongInt;
  Event:TEvent;
begin
{$Ifdef DPMI}
ClearFind;

C:=IOResult;
ViewLizo:=False;

Assign(AgentFile,Path.ToClient+'Lizo.db');
Reset(AgentFile);
C:=IOResult;
If C<>0 Then
Begin
 MessageBox(#3^M+#3'Ошибка доступа к файлу клиентов!',nil,mfError+mfCancelButton);
 ViewLizo:=False;
 Exit;
End;

AInfo('Читаю списки...');

If Art[0]=#0 Then
s:=Copy(Client^.GetText(Client^.Focused,Client^.List^.Count),1+CClient+1,CClientKod)
Else
s:=Art;
DelSpace(Art);

Seek(AgentFile,StrToInt(S));

ReadClient(AgentFile,AgentElement);

If (AgentElement.Kod<>s) Then
   Begin
    NoInfo;
    MessageBox(#3^M+#3'Агент в базе не найден!',nil,mfError+mfCancelButton);
    System.Close(AgentFile);
    ViewLizo:=False;
    Exit;
   End;

System.Close(AgentFile);

R.Assign(9, 1, 71, 19);
New(Dlg, Init(R, 'Просмотр сотрудника'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.Palette := dpCyanDialog;
Dlg^.HelpCtx:=$E090;

R.Assign(14, 1, 36, 2);
{Control^.Options := Control^.Options and not ofSelectable;}
Control := New(PInputLine, Init(R, 20));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);
{
  R.Assign(36, 1, 39, 2);
  Dlg^.Insert(New(PHistory, Init(R, PInputline(Control), 12)));
}
  R.Assign(6, 1, 14, 2);
  Dlg^.Insert(New(PLabel, Init(R, 'Аг~е~нт:', Control)));

R.Assign(14, 2, 61, 3);
Control := New(PInputLine, Init(R, 45));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);

  R.Assign(2, 2, 14, 3);
  Dlg^.Insert(New(PLabel, Init(R, 'N д~о~говора:', Control)));

R.Assign(14, 3, 18, 4);
Control := New(PInputLine, Init(R, 2));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);


  R.Assign(3, 3, 14, 4);
  Dlg^.Insert(New(PLabel, Init(R, 'От~д~еление:', Control)));

R.Assign(29, 3, 33, 4);
Control := New(PInputLine, Init(R, 2));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);

  R.Assign(20, 3, 29, 4);
  Dlg^.Insert(New(PLabel, Init(R, 'П~а~латки:', Control)));

R.Assign(44, 3, 48, 4);
Control := New(PInputLine, Init(R, 2));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);

  R.Assign(34, 3, 44, 4);
  Dlg^.Insert(New(PLabel, Init(R, 'Ма~г~азины:', Control)));

R.Assign(55, 3, 59, 4);
Control := New(PInputLine, Init(R, 2));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);

  R.Assign(49, 3, 55, 4);
  Dlg^.Insert(New(PLabel, Init(R, 'Ка~ф~е:', Control)));

R.Assign(14, 4, 31, 5);
Control := New(PInputLine, Init(R, 15));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);

  R.Assign(1, 4, 14, 5);
  Dlg^.Insert(New(PLabel, Init(R, '~Л~имит долга:', Control)));
R.Assign(14, 5, 61, 6);
Control := New(PInputLine, Init(R, 45));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);

  R.Assign(7, 5, 14, 6);
  Dlg^.Insert(New(PLabel, Init(R, 'Адре~с~:', Control)));

R.Assign(14, 6, 61, 7);
Control := New(PInputLine, Init(R, 45));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);

  R.Assign(5, 6, 14, 7);
  Dlg^.Insert(New(PLabel, Init(R, '~Т~елефон:', Control)));

R.Assign(14, 7, 61, 8);
Control := New(PInputLine, Init(R, 45));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);

  R.Assign(6, 7, 14, 8);
  Dlg^.Insert(New(PLabel, Init(R, '~Р~/счет:', Control)));

R.Assign(14, 8, 61, 9);
Control := New(PInputLine, Init(R, 45));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);

  R.Assign(11, 8, 14, 9);
  Dlg^.Insert(New(PLabel, Init(R, 'в:', Control)));

R.Assign(14, 9, 61, 10);
Control := New(PInputLine, Init(R, 45));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);

  R.Assign(7, 9, 14, 10);
  Dlg^.Insert(New(PLabel, Init(R, 'Город:', Control)));

R.Assign(14, 10, 61, 11);
Control := New(PInputLine, Init(R, 45));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);

  R.Assign(9, 10, 14, 11);
  Dlg^.Insert(New(PLabel, Init(R, '~И~НН:', Control)));

R.Assign(14, 11, 61, 12);
Control := New(PInputLine, Init(R, 45));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);

  R.Assign(7, 11, 14, 12);
  Dlg^.Insert(New(PLabel, Init(R, 'О~К~ОНХ:', Control)));

R.Assign(14, 12, 61, 13);
Control := New(PInputLine, Init(R, 45));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);

  R.Assign(8, 12, 14, 13);
  Dlg^.Insert(New(PLabel, Init(R, 'ОК~П~О:', Control)));

R.Assign(14, 13, 61, 14);
Control := New(PInputLine, Init(R, 45));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);

  R.Assign(4, 13, 14, 14);
  Dlg^.Insert(New(PLabel, Init(R, 'Ли~ц~ензия:', Control)));


R.Assign(14, 14, 61, 15);
Control := New(PInputLine, Init(R, CSertif));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);

  R.Assign(3, 14, 14, 15);
  Dlg^.Insert(New(PLabel, Init(R, 'Сооб~щ~ение:', Control)));


R.Assign(12, 15, 33, 16);
Control := New(PCheckboxes, Init(R,
  NewSItem('Ра~з~решить дебит', Nil)));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);

R.Assign(12, 16, 33, 17);
Control := New(PCheckboxes, Init(R,
  NewSItem('От~к~лючить лимит', Nil)));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);


R.Assign(51, 15, 61, 16);
Control := New(PInputLine, Init(R, 8));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);

  R.Assign(33, 15, 51, 16);
  Dlg^.Insert(New(PLabel, Init(R, 'Срок ли~ц~ензии до:', Control)));

R.Assign(51, 16, 61, 17);
Control := New(PInputLine, Init(R, CArtikul));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0']));

  R.Assign(33, 16, 51, 17);
  Dlg^.Insert(New(PLabel, Init(R, 'Периодичность:', Control)));



Dlg^.SetData(AgentElement);


  R.Assign(52, 1, 57, 2);
  Control := New(PColoredText, Init(R, 'Код:', $3E));
  Dlg^.Insert(Control);
  R.Assign(57, 1, 61, 2);
  Control := New(PColoredText, Init(R, AgentElement.Kod,$3E));
  Dlg^.Insert(Control);

Dlg^.SelectNext(False);
NoInfo;

c:=Desktop^.ExecView(Dlg);
Dispose(Control,Done);
Dispose(Dlg,Done);
PrevAgent[0]:=#0;
{$ENDIF}
end;


Function AddLizo( Cod:Integer; Var AgentElement:ClientType):Boolean;
Label 1;
var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  s : TEnjoyStr;{!!!}
  j,c: Word;
  Full : Boolean;
  k : LongInt;
{  l : Boolean;}
  Event:TEvent;
begin
ClearFind;

If Not(TestOpenDate1(FDate)) Then
   Begin
    MessageBox(#3^M+#3'Доступ к данным за '+FDate+' заблокирован!',Nil,mfError+mfCancelButton);
    AddLizo:=False;
    Exit;
   End;

C:=IOResult;
AddLizo:=False;
Full:=True;

Assign(AgentFile,Path.ToClient+'lizo.db');

Reset(AgentFile);
C:=IOResult;
If C<>0 Then
Begin
 MessageBox(#3^M+#3'Ошибка доступа к файлу сотрудников!',nil,mfError+mfCancelButton);
 AddLizo:=False;
 Exit;
End;
AInfo('Читаю списки...');
 Case Cod Of
  kbGrayPlus:Begin
     AgentElement.Employ:=True;
     While Not(Eof(AgentFile)) And (AgentElement.Employ) Do
     begin
      ReadClient(AgentFile,AgentElement);
     end;


     If Eof(AgentFile) And (AgentElement.Employ) Then
      Begin
       NoInfo;
       MessageBox(#3^M+#3'Свободных позиций для сотрудников - нет!',nil,mfWarning+mfCancelButton);
       System.Close(AgentFile);
       AddLizo:=False;
       Exit;
      End;
      s:=AgentElement.Kod;
      AgentElement.Name[0]       :=#0;
      AgentElement.FullName[0]       :=#0;

      AgentElement.Adress[0]     :=#0;
      AgentElement.Dogovor[0]    :=#0;
      AgentElement.Limit[0]      :=#0;
      For c:=1 To CPunkt Do
      AgentElement.Punkt[c,0]        :=#0;
      AgentElement.INN[0]        :=#0;
      AgentElement.R_Sh[0]       :=#0;
      AgentElement.Gde[0]        :=#0;
      AgentElement.Gorod[0]      :=#0;
      AgentElement.Test_Srok[0]  :=#0;
      AgentElement.Prozent[0] :=#0;
      AgentElement.Region:=0;
      AgentElement.Okonh[0]      :=#0;
      AgentElement.Okpo[0]       :=#0;
      AgentElement.Enviropment[0]:=#0;
      AgentElement.Telefon[0]    :=#0;
      AgentElement.Debit      :=0;
      AgentElement.SrokLizensia[0]    :=#0;
      AgentElement.Messages[0]:=#0;
      AgentElement.Stat          :=False;
      AgentElement.Locked        :=True;
      AgentElement.NoLimit       :=0;
      AgentElement.AgentKod[1]:='0000';
      AgentElement.AgentKod[2]:='0000';
    End;
  kbF4:Begin
     s:=Copy(Client^.GetText(Client^.Focused,Client^.List^.Count),1+CClient+1,CClientKod);
     Seek(AgentFile,StrToInt(s));
     Repeat
      ReadClient(AgentFile,AgentElement);
     Until (Eof(AgentFile)) Or (AgentElement.Kod=s);
     If Eof(AgentFile) And (AgentElement.Kod<>s) Then
      Begin
       NoInfo;
       MessageBox(#3^M+#3'Агент в базе не найден!',nil,mfError+mfCancelButton);
       System.Close(AgentFile);
       AddLizo:=False;
       Exit;
      End;
    End;
  Else;
 End;
System.Close(AgentFile);
1:
If Cod=kbGrayPlus Then
Begin
R.Assign(9, 1, 71, 24);
New(Dlg, Init(R, 'Добавить сотрудника'));
End
Else
Begin
R.Assign(9, 1, 71, 19);
New(Dlg, Init(R, 'Изменить сотрудника'));
End;
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.Palette := dpCyanDialog;
Dlg^.HelpCtx:=$E011;
R.Assign(14, 1, 36, 2);
Control := New(PInputLine, Init(R, 20));
Dlg^.Insert(Control);

  R.Assign(36, 1, 39, 2);
  Dlg^.Insert(New(PHistory, Init(R, PInputline(Control), 12)));

  R.Assign(6, 1, 14, 2);
  Dlg^.Insert(New(PLabel, Init(R, 'Сотрудник:', Control)));


R.Assign(14, 2, 39, 3);
Control := New(PInputLine, Init(R, 100));
If (Not(Full))Then
Control^.Options := Control^.Options and not ofSelectable;
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
If (Not(Full))Then
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);

  R.Assign(39, 2, 48, 3);
  Dlg^.Insert(New(PLabel, Init(R, 'Д~о~говор:', Control)));





R.Assign(14, 3, 18, 4);
Control := New(PInputLine, Init(R, 2));
{Control^.Options := Control^.Options and not ofSelectable;}
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0']));

  R.Assign(3, 3, 14, 4);
  Dlg^.Insert(New(PLabel, Init(R, 'От~д~еление:', Control)));

R.Assign(29, 3, 33, 4);
Control := New(PInputLine, Init(R, 2));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0']));

  R.Assign(20, 3, 29, 4);
  Dlg^.Insert(New(PLabel, Init(R, 'П~а~латки:', Control)));

R.Assign(44, 3, 48, 4);
Control := New(PInputLine, Init(R, 2));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0']));

  R.Assign(34, 3, 44, 4);
  Dlg^.Insert(New(PLabel, Init(R, 'Ма~г~азины:', Control)));

R.Assign(55, 3, 59, 4);
Control := New(PInputLine, Init(R, 2));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0']));

  R.Assign(49, 3, 55, 4);
  Dlg^.Insert(New(PLabel, Init(R, 'Ка~ф~е:', Control)));

R.Assign(14, 4, 31, 5);
Control := New(PInputLine, Init(R, 15));
{Control^.Options := Control^.Options and not ofSelectable;}
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));

  R.Assign(1, 4, 14, 5);
  Dlg^.Insert(New(PLabel, Init(R, '~Л~имит долга:', Control)));

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

  R.Assign(5, 7, 14, 8);
  Dlg^.Insert(New(PLabel, Init(R, 'Паспорт :', Control)));

R.Assign(14, 8, 61, 9);
Control := New(PInputLine, Init(R, 45));
Dlg^.Insert(Control);

  R.Assign(7, 8, 14, 9);
  Dlg^.Insert(New(PLabel, Init(R, 'выдан:', Control)));

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
  Dlg^.Insert(New(PLabel, Init(R, 'О~К~ОНХ:', Control)));

R.Assign(14, 12, 61, 13);
Control := New(PInputLine, Init(R, 45));
Dlg^.Insert(Control);

  R.Assign(8, 12, 14, 13);
  Dlg^.Insert(New(PLabel, Init(R, 'ОК~П~О:', Control)));

R.Assign(14, 13, 61, 14);
Control := New(PInputLine, Init(R, 45));
Dlg^.Insert(Control);

  R.Assign(4, 13, 14, 14);
  Dlg^.Insert(New(PLabel, Init(R, 'Ли~ц~ензия:', Control)));


R.Assign(14, 14, 61, 15);
Control := New(PInputLine, Init(R, CSertif));
Dlg^.Insert(Control);

  R.Assign(3, 14, 14, 15);
  Dlg^.Insert(New(PLabel, Init(R, 'Сооб~щ~ение:', Control)));


R.Assign(12, 15, 33, 16);
Control := New(PCheckboxes, Init(R,
  NewSItem('Ра~з~решить дебит', Nil)));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);

R.Assign(12, 16, 33, 17);
Control := New(PCheckboxes, Init(R,
  NewSItem('От~к~лючить лимит', Nil)));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);


R.Assign(51, 15, 61, 16);
Control := New(PInputLine, Init(R, 8));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PPXPictureValidator, Init({'[##-##-9#]'}DateFiltr, True));

  R.Assign(33, 15, 51, 16);
  Dlg^.Insert(New(PLabel, Init(R, 'Срок ли~ц~ензии до:', Control)));

R.Assign(51, 16, 61, 17);
Control := New(PInputLine, Init(R, CArtikul));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0']));

  R.Assign(33, 16, 51, 17);
  Dlg^.Insert(New(PLabel, Init(R, 'Периодичность:', Control)));


Dlg^.SetData(AgentElement);


If Cod = kbGrayPlus  Then
Begin
 R.Assign(61, 18, 62, 22);
 Control := New(PScrollBar, Init(R));
 Dlg^.Insert(Control);
 R.Assign(1, 18, 61, 22);
 ClientNum := New(PBox, Init(R, 9, PScrollbar(Control)));
 ClientNum^.NewList(New(PTextCollection, Init(0,1)));

Assign(AgentFile,Path.ToClient+'lizo.db');
Reset (AgentFile);
 While Not(Eof(AgentFile)) Do
  Begin
   ReadClient(AgentFile,AgentElement);
   If Not(AgentElement.Employ) Then
   Begin
   Format (AgentElement.Name,CClient);
   ClientNum^.List^.Insert(NewStr({MakeListElement.Name+}'│'+AgentElement.Kod));
   ClientNum^.SetRange(ClientNum^.List^.Count);
   ClientNum^.FocusItem(ClientNum^.List^.Count);
   End;
  End;
 System.Close(AgentFile);
 If Cod=kbF4 Then ClientNum^.FocusItem(LoCation(ClientNum,s,ProdagaWindow))
 Else ClientNum^.FocusItem(0);

 Dlg^.Insert(ClientNum);
 ClientNum^.HelpCtx:=$E011;

  R.Assign(1, 17, 37, 18);
  Dlg^.Insert(New(PLabel, Init(R, '~Д~оступные коды:', ClientNum)));
  Dlg^.Insert(Control);
 End;
If Cod=kbF4 Then
 Begin
  R.Assign(52, 1, 57, 2);
  Control := New(PColoredText, Init(R, 'Код:', $3E));
  Dlg^.Insert(Control);
  R.Assign(57, 1, 61, 2);
  Control := New(PColoredText, Init(R, AgentElement.Kod,$3E));
  Dlg^.Insert(Control);
 End;

Dlg^.SelectNext(False);
NoInfo;
c:=Desktop^.ExecView(Dlg);
If c<>cmCancel Then
 Begin
    Dlg^.GetData(AgentElement);
    DelSpaceRight(AgentElement.Name);
    DelSpaceRight(AgentElement.Messages);
    DelSpace(AgentElement.SrokLizensia);


    If AgentElement.Name[0]=#0 Then
   Begin
    MessageBox(^M+#3'Недопустимое имя агента!',nil,mfError+mfCancelButton);
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
   If Not(TestEmployLizoAndLock(s)) Then
    Begin
     Beep;
     DInfoMsg('Не могу заблокировать сотрудника с кодом '+s+'... Попробуйте изменить код!');
     Application^.ClearEvent(Event);
     Application^.ClearEvent(Event);
      repeat
       Application^.GetEvent(Event);
      until (Event.What <> evNothing);
     NoInfoMsg;
     Application^.ClearEvent(Event);
     Dispose(ClientNum,Done);
     Dispose(Control,Done);
     Dispose(Dlg,Done);
     Goto 1;
    End;
  End;

  {исходим из того что блокировка удалась}

   UpStr(AgentElement.Name);
   UpStr(AgentElement.Adress);
   UpStr(AgentElement.INN);
   UpStr(AgentElement.R_Sh);
   UpStr(AgentElement.Gde);
   UpStr(AgentElement.Gorod);
   UpStr(AgentElement.Okonh);
   UpStr(AgentElement.Okpo);
   UpStr(AgentElement.Enviropment);
   UpStr(AgentElement.Telefon);
   AgentElement.Employ:=True;
   AgentElement.Stat:=False;
   AgentElement.Locked:=True;
   AgentElement.LockTime :=False;

   If Cod=kbGrayPlus Then AgentElement.Kod:=s;

  {если не удалось записать информацию}
  If Not (WriteLockLizo(AgentElement)) Then
    Begin
     If Cod=kbGrayPlus Then Dispose(ClientNum,Done);
     Dispose(Control,Done);
     Dispose(Dlg,Done);
     Repeat
     Until (SetAgentUnLock(s));
     Goto 1;
    End;

  If Cod=kbGrayPlus Then
  Begin
   AddProtocol('Добавление нового сотрудника:'+AgentElement.Name+' ('+s+')','','');
   Repeat
   Until (SetLizoUnLock(s));
  End
  Else
   AddProtocol('Корректировка данных сотрудника:'+AgentElement.Name+' ('+AgentElement.Kod+')','','');
  AddLizo:=True;

 End;

If Cod=kbGrayPlus Then
  Begin
  ClientNum^.NewList(Nil);
  Dispose(ClientNum,Done);
  End;
  Dispose(Control,Done);
  Dispose(Dlg,Done);

  PrevAgent[0]:=#0;
end;



Procedure TLizoWindow.ShowAgentList(Var st:AllStr;Var Res: Word);
Label 1;
var
  R : TRect;
  Control : PView;
  s : String[CSertif];
  c: Word;
begin
ClearFind;
AInfo('Читаю списки...');

Res:=0;
R.Assign(13, 3, 68, 20);
New(LizoWindow, Init(R, 'Выбор сотрудника'));

R.Assign(54, 1 ,55, 16);
Control := New(PScrollBar, Init(R));
LizoWindow^.Insert(Control);

R.Assign(1, 1, 54, 16);
Client := New(PBox, Init(R, 2, PScrollbar(Control)));
Client^.NewList(New(PTextCollection, Init(0,1)));
Assign (AgentFile,Path.ToClient+'lizo.db');
c:=IOResult;
Reset (AgentFile);
c:=IOResult;
If c=0 Then
Begin
While Not(Eof(AgentFile)) Do
 Begin
     ReadClient(AgentFile,AgentElement);
  If AgentElement.Employ Then
   Begin
    Format (AgentElement.Name,CClient);
    Client^.List^.Insert(NewStr(AgentElement.Name+'│'+AgentElement.Kod));
    Client^.SetRange(Client^.List^.Count);
   End;
 End;
System.Close(AgentFile);
End
Else
 Begin
  NoInfo;
  MessageBox(^M+#3'Ошибка доступа к файлам базы !',nil,mfError+mfCanCelButton);
  Goto 1;
 End;

s:=Copy(st,1+CClient+1,CClientKod);

{Client^.FocusItem(Location(Client,S,ProdagaWindow));}

Client^.HelpCtx:=$E171;
LizoWindow^.Insert(Client);
PrevAgent:=Copy(Client^.GetText(Client^.Focused,Client^.List^.Count),1+CClient+1,CClientKod);



LizoWindow^.SelectNext(False);
PrevAgent[0]:=#0;
NoInfo;
c:=Desktop^.ExecView(LizoWindow);
If c<>CmCancel Then
   If c=CmOk Then Res:=2;
   If c=CmYes Then Res:=3;
   If c=CmCancel Then Res:=1;
   St:=Client^.GetText(Client^.Focused,Client^.List^.Count);
   If ShowClients=1 Then
    Begin
     s:=Copy(st,1+CClient+1,CClientKod);
     s:=GetLizoField(FMessages,s);
     If s[0]<>#0 Then
      Begin
       SpecialBeep;
       MessageBox(^M+#3+s,Nil,mfInformation+mfCancelButton);
      End;
    End;
1:
Dispose(COntrol,Done);
Dispose(LizoWindow,Done);
end;

Procedure TLizoWindow.Refresh;
var
  R : TRect;
  Control : PView;
  s : String[CSertif];

  c,Cod: Word;
begin
ClearFind;
AInfo('Обновляю списки сотрудников...');
Cod:=Client^.Focused;

     Assign (AgentFile,Path.ToClient+'lizo.db');
     Client^.NewList(Nil);
     Client^.NewList(New(PTextCollection, Init(0,1)));

c:=IOResult;
Reset (AgentFile);
c:=IOResult;
If c=0 Then
Begin
While Not(Eof(AgentFile)) Do
 Begin
  ReadClient(AgentFile,AgentElement);
  If AgentElement.Employ Then
   Begin
    Format (AgentElement.Name,CClient);
    Client^.List^.Insert(NewStr(AgentElement.Name+'│'+AgentElement.Kod));
    Client^.SetRange(Client^.List^.Count);
   End;
 End;
System.Close(AgentFile);
If Cod<>0 Then Dec(Cod);

Client^.FocusItem(Cod);
NoInfo;
End
Else
 Begin
  NoInfo;
  MessageBox(^M+#3'Ошибка доступа к файлам базы !',nil,mfError+mfCanCelButton);
  Exit;
 End;
Redraw;
PrevAgent[0]:=#0;
end;

Procedure TLizoWindow.DrawCurrent;
Var s: String[CAll];
    R : TRect;
Begin
End;



Destructor TLizoWindow.Done;
Begin
ClearFind;
Dispose(Client,Done);
TDialog.Done;
End;



Procedure TLizoWindow.PrintAgentInfo(s:ArtikulStr);
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
   Writeln(f,Space+Bold[NPrint.Printer]+Double[NPrint.Printer]+'         РЕКВИЗИТЫ АГЕНТА '+GetLizoField(FClient,s)+
   ' ('+s+')'+NoBold[NPrint.Printer]+NoDouble[NPrint.Printer]);
   Writeln(f,Space+Bold[NPrint.Printer]+'       Договор: '+NoBold[NPrint.Printer]+Italic[NPrint.Printer]+
   GetLizoField(FNDogovor,s)+NoItalic[NPrint.Printer]);
   Writeln(f,Space+Bold[NPrint.Printer]+'   Лимит долга: '+NoBold[NPrint.Printer]+Italic[NPrint.Printer]+
   GetLizoField(FLimit,s)+NoItalic[NPrint.Printer]);
   Writeln(f,Space+Bold[NPrint.Printer]+'         Адрес: '+NoBold[NPrint.Printer]+Italic[NPrint.Printer]+
   GetLizoField(FAdress,s)+NoItalic[NPrint.Printer]);;
   Writeln(f,Space+Bold[NPrint.Printer]+'       Телефон: '+NoBold[NPrint.Printer]+Italic[NPrint.Printer]+
   GetLizoField(FTelefon,s)+NoItalic[NPrint.Printer]);;
   Writeln(f,Space+Bold[NPrint.Printer]+'Расчетный счет: '+NoBold[NPrint.Printer]+Italic[NPrint.Printer]+
   GetLizoField(FRSh,s)+NoItalic[NPrint.Printer]);;
   Writeln(f,Space+Bold[NPrint.Printer]+'             в: '+NoBold[NPrint.Printer]+Italic[NPrint.Printer]+
   GetLizoField(FGde,s)+NoItalic[NPrint.Printer]);;
   Writeln(f,Space+Bold[NPrint.Printer]+'         Город: '+NoBold[NPrint.Printer]+Italic[NPrint.Printer]+
   GetLizoField(FGorod,s)+NoItalic[NPrint.Printer]);;
   Writeln(f,Space+Bold[NPrint.Printer]+'           ИНН: '+NoBold[NPrint.Printer]+Italic[NPrint.Printer]+
   GetLizoField(FINN,s)+NoItalic[NPrint.Printer]);;
   Writeln(f,Space+Bold[NPrint.Printer]+'         ОКОНХ: '+NoBold[NPrint.Printer]+Italic[NPrint.Printer]+
   GetLizoField(FOkonh,s)+NoItalic[NPrint.Printer]);;
   Writeln(f,Space+Bold[NPrint.Printer]+'          ОКПО: '+NoBold[NPrint.Printer]+Italic[NPrint.Printer]+
   GetLizoField(FOkpo,s)+NoItalic[NPrint.Printer]);;
   Writeln(f,Space+Bold[NPrint.Printer]+'      Лицензия: '+NoBold[NPrint.Printer]+Italic[NPrint.Printer]+
   GetLizoField(FEnvir,s)+NoItalic[NPrint.Printer]);;
   Writeln(f,Space+Bold[NPrint.Printer]+' Срок лицензии: '+NoBold[NPrint.Printer]+Italic[NPrint.Printer]+
   GetLizoField(FSrok,s)+NoItalic[NPrint.Printer]);;
   Write(f,Space+Bold  [NPrint.Printer]+'   Консигнация: '+NoBold[NPrint.Printer]+Italic[NPrint.Printer]);

   If StrToInt(GetLizoField(FDebit,s))=0 Then
   Writeln(f,'Запрещена!!!'+NoItalic[NPrint.Printer])
   Else
   Writeln(f,'Разрешена'+NoItalic[NPrint.Printer]);

   Writeln(f,Space+'====================================================================');
System.Close(f);
Report(Path.ToTemp+'rek.txt','',1,False,False,false);
End;


procedure TLizoWindow.HandleEvent(var Event: TEvent);
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
  s:=Client^.GetText(Client^.Focused,Client^.List^.Count);
  s:=Copy(s,1+CClient+1,CClientKod);

  R:=GetLizoEmploy(s);
  If Not(r) Then
   Begin
    Beep;
    DInfoMsg('Не могу заблокировать сотрудника с кодом '+s+'. Сотрудник отмечен как удаленный!');
    ClearEvent(Event);
    ClearEvent(Event);
    repeat
    Application^.GetEvent(Event);
    until (Event.What <> evNothing);
    NoInfoMsg;
    ClearEvent(Event);
    Event.What:=EvCommand;
    Event.Command:=cmRefresh;
    PutEvent(Event);
    ClearEvent(Event);
    Exit;
   End;

  If SetLizoLock(s) Then LockSelect:=True
  Else
   Begin
    Beep;
    DInfoMsg('Не могу заблокировать сотрудника с кодом '+s+'. Попробуйте повторить!');
    ClearEvent(Event);
    ClearEvent(Event);
    repeat
    Application^.GetEvent(Event);
    until (Event.What <> evNothing);
    NoInfoMsg;
    ClearEvent(Event);
   End;
End;

Function TestEmploy:Boolean;
Var s : string;
    Event : TEvent;
    R : Boolean;
Begin
  TestEmploy:=False;
  s:=Client^.GetText(Client^.Focused,Client^.List^.Count);
  s:=Copy(s,1+CClient+1,CClientKod);

  r:=False;
  R:=GetLizoEmploy(s);
  If Not(r) Then
   Begin
    Beep;
    DInfoMsg('Нельзя работать с сотрудником '+s+'. Сотрудник отмечен как удаленный!');
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
Assign (F,Path.ToClient+'lizo.db');

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
System.close(f);
   r:=IOResult;

NoInfo;
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
     If (Client^.State and sfFocused <> 0) And (Client^.List<>Nil)And(Client^.List^.Count>=2) Then L:=True;

     If L Then
            Begin
     If Password(3) Then
             Begin
             s:=#3^M+#3'Желаете удалить запись?';
             If MessageBox(s,nil,mfConfirmation+mfOkCancel)=cmOk
              Then
              Begin
                s:=Client^.GetText(Client^.Focused,Client^.List^.Count);
                s:=Copy(s,1+CClient+1,CClientKod);

              {сетевая блокировка}
               If Not(LockSelect) Then
                Begin
                 ClearEvent(Event);
                 Redraw;
                 Exit;
                End;

                 test := IOResult;
                 s:=Client^.GetText(Client^.Focused,Client^.List^.Count);
                 s:=Copy(s,1+CClient+1,CClientKod);

                 Assign (AgentFile,Path.ToClient+'lizo.db');
                 AgentElement.Name[0]:=#0;
                 AgentElement.Employ:=False;
                 AgentElement.Limit[0]:=#0;
                 AgentElement.Dogovor[0]:=#0;
                 For Test:=1 To CPunkt Do
                 AgentElement.Punkt[Test,0]:=#0;
                 AgentElement.Stat:=False;
                 AgentElement.Adress[0]:=#0;
                 AgentElement.Gorod[0]:=#0;
                 AgentElement.Gde[0]:=#0;
                 AgentElement.INN[0]:=#0;
                 AgentElement.R_Sh[0]:=#0;
                 AgentElement.SrokLizensia[0]:=#0;
                 AgentElement.Debit:=0;
                 AgentElement.Messages[0]:=#0;
                 AgentElement.Kod:=s;
                 AgentElement.Locked:=True;

  If Not (WriteLockLizo(AgentElement)) Then
    Begin
     MessageBox(^M+#3'Ошибка доступа к файлам сотрудников !',nil,mfError+mfCanCelButton);
     Repeat
     Until (SetAgentUnLock(s));
     ClearEvent(Event);
     Exit;
    End;

    Repeat
    Until (SetLizoUnLock(s));
    AddProtoCol('Удаление сотрудника:'+s,'','');
    Client^.List^.AtFree(Client^.Focused);
    Client^.SetRange(Client^.List^.Count);
    If Client^.Focused>0 Then   Client^.FocusItem(Client^.Focused);
    If (Client^.Focused>=Client^.List^.Count) and(Client^.Focused>0) Then
    Client^.FocusItem(Client^.Focused-1);
    ClearEvent(Event);
    Redraw;
            End;
           End;
          End;
          End;


kbAlt1         : UnlockAll;
kbGrayPlus,kbF4:
Begin
L:=False;
If(Client^.State and sfFocused <> 0)And(Not(Event.KeyCode=kbF4))Or
((Event.KeyCode=kbF4)And(Client^.List<>Nil)And(Client^.List^.Count>=1)) Then l:=True;
 If L Then
   Begin
    If Event.KeyCode=kbF4 Then
      If Not(LockSelect) Then
       Begin
        ClearEvent(Event);
        Exit;
       End;
      If AddLizo(Event.KeyCode,AgentElement) Then
       Begin
        If (Event.KeyCode=kbF4)And(Client^.List<>Nil)And(Client^.List^.Count>=1) Then
           Client^.List^.AtFree(Client^.Focused);
        Format(AgentElement.Name,CClient);
        Client^.List^.Insert(NewStr(AgentElement.Name+'│'+AgentElement.Kod));
        Client^.SetRange(Client^.List^.Count);
        Client^.FocusItem(LoCation(Client,AgentElement.Kod,ProdagaWindow));
        Redraw;
       End;
   End;
 If Event.KeyCode=kbF4 Then
   Begin
    Cod:=AgentElement.Kod;
    Repeat
    Until (SetLizoUnLock(Cod));
   End;
            ClearEvent(Event);
            Redraw;
            End;
kbF3: Begin
     L:=False;
     ViewLizo('');
     ClearEvent(Event);
     Redraw;
      End;

      Else;
      End;{KeyDown}
evCommand:
 Case Event.Command Of
 cmRefresh: Refresh;
 cmPrintReestr:
  Begin
     l:=False;
If(Client^.State and sfFocused <> 0)And(Client^.List<>Nil)And(Client^.List^.Count>=1) Then l:=True;
     If l Then
      Begin
               s:=Client^.GetText(Client^.Focused,Client^.List^.Count);
               s:=Copy(s,1+CClient+1,CClientKod);
               PrintAgentInfo(s);
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
                          If Not(TestEmploy) Then
                                   Begin
                                    ClearEvent(Event);
                                    Exit;
                                   End;
                       End;

             Else Exit;
             End;
             End;
 Else;
 End;

 {if (Event.What = evBroadcast) and
     (Event.Command = cmSelectAgent) then ClearEvent(Event);}


  inherited HandleEvent(Event);
  {
  If (Desktop^.Current=PView(AgentWindow)) And (Event.What <> EvKeyDown) Then
          Begin
                If (Client^.List <> Nil) And (Client^.List^.Count>=1) Then
                 Begin
                  s:=Client^.GetText(Client^.Focused,Client^.List^.Count);
                  If s<>PrevAgent Then
                   Begin
                    PrevAgent:=S;
                    DrawCurrent;
                   End;
                 End;
          End;
  }
  ClearEvent(Event);
end;




procedure TReestrKWindow.DrawCurrent;
VAr S,s1 : TMyString;
    R : TRect;
    TempS : AllStr;
Begin
If (DocList^.List<>Nil)And(DocList^.List^.Count>=1) Then
  Begin

   s:=Copy(PrevCur,1+CDocNumer+1+CClient+1+7+1+CDAte+1+CDAte+1+CIZena+1+CKto+1,CSertif);
   s1:=Copy(PrevCur,1+CDocNumer+1+CClient+1+7+1+CDAte+1+CDAte+1+CIZena+1+CKto+1+CSertif+1+4+1,4);

   Dispose(ControlSotr,Done);
   R.Assign(11, 18, 40, 19);
   ControlSotr := New(PColoredText, Init(R, GetLizoField(fClient,s1), $7E));
   Insert(ControlSotr);
   Dispose(ControlCom,Done);
   R.Assign(13, 19, 79, 20);
   ControlCom := New(PColoredText, Init(R, s, $7E));
   Insert(ControlCom);

  End
  Else
   Begin
    Dispose(ControlCom,Done);
    R.Assign(13, 19, 79, 20);
    ControlCom := New(PColoredText, Init(R, '???', $7E));
    Insert(ControlCom);
   End;
End;


procedure TDopReestrKWindow.DrawCurrent;
VAr S,s1 : TMyString;
    R : TRect;
    TempS : AllStr;
Begin
If (DopDocList^.List<>Nil)And(DopDocList^.List^.Count>=1) Then
  Begin
   s:='';
   (*s:=Copy(PrevCur,1+CDocNumer+1+CClient+1+7+1+CDAte+1+CDAte+1+CIZena+1+CKto+1,CSertif);
   s1:=Copy(PrevCur,1+CDocNumer+1+CClient+1+7+1+CDAte+1+CDAte+1+CIZena+1+CKto+1+CSertif+1+4+1,4);
   *)
   (*Dispose(DopControlSotr,Done);
   R.Assign(11, 18, 40, 19);
   DopControlSotr := New(PColoredText, Init(R, GetLizoField(fClient,s1), $7E));
   Insert(DopControlSotr);*)
   Dispose(DopControlCom,Done);
   R.Assign(13, 19, 79, 20);
   DopControlCom := New(PColoredText, Init(R, s, $7E));
   Insert(DopControlCom);

  End
  Else
   Begin
    Dispose(DopControlCom,Done);
    R.Assign(13, 19, 79, 20);
    DopControlCom := New(PColoredText, Init(R, '???', $7E));
    Insert(ControlCom);
   End;
End;



procedure TReestrKWindow.OpenReestrWindow;
Var l : Boolean;
begin
  if Message(Desktop, evBroadcast, cmReestrKassa, nil) = nil then
  begin
    L:=True;
    DocDate:=FDAte;
    StopDate:=FDAte;

    If Not(DatePeriodDialog(DocDAte,StopDAte,FAlse)) Then Exit;
    DInfo('Инициализация реестра кассовых операций...');
    DocReestrWindow := New(PReestrKWindow, Init(L));
    If L Then
    Begin
    Application^.InsertWindow(DocReestrWindow);
    NoInfo;
    End
    Else
     Begin
      TekDate:=FDate;
      Dispose(DocReestrWindow,Done);
      NoInfo;
     End;
  end
  else
    if PView(DocReestrWindow) <> Desktop^.TopView then DocReestrWindow^.Select;
end;

procedure TDopReestrKWindow.OpenReestrWindow;
Var l : Boolean;
begin

  if Message(Desktop, evBroadcast, cmReestrKassa, nil) <> nil then
  begin
    L:=True;
    DocDate:=FDAte;
    StopDate:=FDAte;

  {  If Not(DatePeriodDialog(DocDAte,StopDAte,FAlse)) Then Exit;}
    DInfo('Инициализация реестра расшифровки кассовых операций...');
    DopDocReestrWindow := New(PDopReestrKWindow, Init(L));
    If L Then
    Begin
    Application^.InsertWindow(DopDocReestrWindow);
    NoInfo;
    End
    Else
     Begin
      TekDate:=FDate;
      Dispose(DopDocReestrWindow,Done);
      NoInfo;
     End;
  end
  else
    if PView(DopDocReestrWindow) <> Desktop^.TopView then DopDocReestrWindow^.Select;
end;



Procedure TReestrKWindow.Refresh;
Var
    s: TMyString;
    ws : AllStr;
    SDAte,STime,SSumma,SStatus,SDoc: String[CIZena];
    SKto,SComment : String[CSertif];
    E : PItogKAssa;
    Fp : ItogKAssaFileType;
    FPos:Byte;
    TempArtikul,FS : AllStr;
    Sh,c : Word;
    R : TRect;
    TT,TTStart,ttStop : LongInt;

Begin
DInfoMsg('Идет обновление информации...');

DocList^.NewList(Nil);
DocList^.NewList(New(PMyCollection, Init(1,1)));

ttStart:=DAteStringToDAte(DAteMask,DocDAte);
ttStop :=DAteStringToDAte(DAteMask,StopDAte);

AllDoc[0]:=#0;
AllPlus[0]:=#0;
AllMinus[0]:=#0;
All[0]:=#0;


For tt:=ttStart To TTStop Do
Begin

c:=IOResult;
Assign(fp,Path.ToClient+DAteToDAteString(DAteMask,tt)+'.kas');
Reset(fp);
c:=IOResult;
If c=0 Then
 Begin

New(E,Init);


While Not(Eof(Fp)) Do
 Begin

  ReadKassa(Fp,E^.DAt);

  {If E^.DAt.Active Then}
 Begin
  If Not TestElement(E^.DAt.Kod,FiltrList) Then
  Begin
    Str(StrToInt(AllDoc)+1:CLitrMantissa,AllDoc);
    DelSpace(AllDoc);
    s:=GetOperationField(FNAme,E^.Dat.Kod);
    sStatus:=GetOperationField(FStatus,E^.Dat.Kod);
    CAse StrToInt(SStatus) Of
    0:Begin
       SStatus:='расход';
       Str(StrToreal(AllMinus)+E^.DAt.Summa:CIZena:CMantissa,AllMinus);
      End;

    1:Begin
       SStatus:='приход';
       Str(StrToreal(AllPlus)+E^.DAt.Summa:CIZena:CMantissa,AllPlus);
      End;
    Else SStatus:='??????';;
    End;{CAse}

    Format(S,CClient);
    s:=s+'│';

    SDoc:=IntToStr(FilePos(Fp),CDocNumer);
    RFormatZerro(SDoc,CDocNumer);
    Format(SDoc,CDocNumer);

    STime:=TimeToTimeString('hh:mm:ss',E^.DAt.TimeC);
    SDate:=DateToDAteString(DateMAsk,E^.DAt.DateC);
    Str(E^.DAt.Summa:CIZena:CMAntissa,SSumma);
    SKto:=GetOperatorName(E^.DAt.Caption);
    Format(SKto,CKto);
    Format(E^.Dat.Comment,CSertif);
    RFormatZerro(E^.Dat.Kod,CKod);


    s:='│'+SDOc+'│'+S+SStatus+'│'+SDate+'│'+STime+'│'+SSumma+'│'+SKto+'│'+E^.Dat.Comment+'│'+E^.Dat.Kod+'│'+E^.Dat.Lizo;

    DocList^.List^.Insert(NewStr(s));
    DocList^.SetRange(DocList^.List^.Count);
 End;{Active}
  End;
End;{Фильтр активных продаж}


Dispose(E,Done);

System.Close(Fp);
c:=IOResult;
End;
End;{For  по датам}

c:=IOResult;
   Str(StrToreal(AllPlus)-StrToreal(AllMinus):CIZena:CMantissa,All);


Str(StrToReal(AllPlus):CIZena:CMAntissa,AllPlus);
Str(StrToReal(AllMinus):CIZena:CMAntissa,AllMinus);

DelSpace(AllPlus);
DelSpace(AllMinus);
DelSpace(All);



Dispose(ControlItogoPlus,Done);
R.Assign(16, 20, 31, 21);
ControlItogoPlus := New(PColoredText, Init(R, #3+AllPlus, $4E));
Insert(ControlItogoPlus);


Dispose(ControlItogoMinus,Done);
R.Assign(45, 20, 60, 21);
ControlItogoMinus := New(PColoredText, Init(R, #3+AllMinus, $4E));
Insert(ControlItogoMinus);


Dispose(ControlAll,Done);
R.Assign(64, 20, 79, 21);
ControlAll := New(PColoredText, Init(R, #3+All, $4E));
Insert(ControlAll);


Dispose(ControlHeader,Done);
R.Assign(10, 0, 70, 1);
ControlHeader := New(PColoredText, Init(R,#3+'Реестр кассовых операций за период c '+DocDate+' по '+StopDAte, $4F));
Insert(ControlHeader);


NoInfoMsg;
End;


Procedure TDopReestrKWindow.Refresh;
Var
    s: TMyString;
    ws : AllStr;
    SDAte,STime,SSumma,SStatus,SDoc: String[CIZena];
    SKto,SComment : String[CSertif];
    E : PItogKAssa;
    Fp : ItogKAssaFileType;
    FPos:Byte;
    TempArtikul,FS : AllStr;
    Sh,c : Word;
    R : TRect;
    TT,TTStart,ttStop : LongInt;
    dopAllDoc,dopAllPlus,dopAllMinus,dopAll: string[CIZena];

Begin
DInfoMsg('Идет обновление информации...');

DopDocList^.NewList(Nil);
DopDocList^.NewList(New(PMyCollection, Init(1,1)));

c:=IOResult;

Assign(fp,Path.ToClient+EditKassa.D+'.kas');
Reset(fp);
c:=IOResult;
If c=0 Then
Begin
 New(E,Init);
dopAllDoc:='0';
dopAllPlus:='0.00';
dopAllMinus:='0.00';
dopAll:='0.00';

While Not(Eof(Fp)) Do
 Begin

  ReadKassa(Fp,E^.DAt);

  if (StrToInt(EditKassa.EditPosition)=StrToInt(E^.DAt.Doc)) then
  For tt:=1 To E^.DAt.Amount Do
  begin
    sDoc:=IntToStr(tt,4);
    Str(E^.DAt.Input[tt].Summa:CIZena:CMantissa,ssUMMA);
    rformat(ssUmma,CIZena);
    rFormat(sDoc,4);
    s:='';
    s:='│'+sDoc+'│'+sSumma+'│'+E^.DAt.Input[tt].Comment;
    Str(StrToReal(dopAllMinus)+StrToReal(sSumma):CIZena:CMAntissa,dopAllMinus);
    DopDocList^.List^.Insert(NewStr(s));
    DopDocList^.SetRange(DopDocList^.List^.Count);

    MyStr(E^.DAt.Summa,CIZena,CMAntissa,dopAllPlus);

  end;

 end;
end;

Str(StrToreal(dopAllPlus)-StrToreal(dopAllMinus):CIZena:CMantissa,dopAll);

DelSpace(dopAllPlus);
DelSpace(dopAllMinus);
DelSpace(dopAll);

Dispose(DopControlItogoPlus,Done);
R.Assign(16, 20, 31, 21);
DopControlItogoPlus := New(PColoredText, Init(R, #3+dopAllPlus, $4E));
Insert(DopControlItogoPlus);

Dispose(DopControlItogoMinus,Done);
R.Assign(45, 20, 60, 21);
DopControlItogoMinus := New(PColoredText, Init(R, #3+dopAllMinus, $4E));
Insert(DopControlItogoMinus);

Dispose(DopControlAll,Done);
R.Assign(64, 20, 79, 21);
DopControlAll := New(PColoredText, Init(R, #3+dopAll, $4E));
Insert(DOpControlAll);


Dispose(DopControlHeader,Done);
R.Assign(10, 0, 70, 1);
DopControlHeader := New(PColoredText, Init(R,#3+'Расшифровка кассовых операций за период c '+DocDate+' по '+StopDAte, $4F));
Insert(DopControlHeader);


NoInfoMsg;
End;



constructor TReestrKWindow.Init(Var l : Boolean);
var
  R : TRect;
  Control : PView;
  C : Word;
  s: TMyString;
  ws : AllStr;
  AllDoc,AllClient,AllSkid,AllTara,AllSumma : String[CIZena];
  E : PItogKAssa;
  SuperMarketFile: ItogKAssaFileType;


begin
L:=False;

C:=IOResult;
  Assign(SuperMarketFile,Path.ToClient+FDAte+'.kas');
  Reset(SuperMarketFile);
  C:=IOResult;
  If C<>0 Then
   Begin
    If MessageBox(#3'Файл кассовых операций за '+FDAte+' не найден'^M+
    #3'Создавать файл кассовых операций?'+' Код:'+IntToStr(c,3),Nil, mfWarning+mfOkCancel)=cmOk Then
     Begin
      If Not(CreatToDayF(DocKassa,DocDate)) Then Exit;
      Reset(SuperMarketFile);
      c:=IOResult;
     End
    Else Exit;
   End;

  C:=IOResult;
  System.Close(SuperMarketFile);
  C:=IOResult;


R.Assign(0, 1, 80, 22);
inherited Init(R, ''{'Реестр кассовых операций за период c '+DocDate+' по '+StopDAte});
Options := Options or ofCenterX or ofCenterY;
HelpCtx:=$F155;


R.Assign(0, 1, 80, 22);
ControlHeader := New(PColoredText, Init(R,'Реестр кассовых операций за период c '+DocDate+' по '+StopDAte, $4F));
Insert(ControlHeader);


R.Assign(79, 2, 80, 18);
Control := New(PScrollBar, Init(R));
Insert(Control);

R.Assign(1, 2, 79, 18);
DocList := New(PBox, Init(R, 1, PScrollbar(Control)));
DocList^.NewList(New(PTextCollection, Init(0,1)));

DocList^.FocusItem(0);
DocList^.HelpCtx:=$F155;

Insert(DocList);

  R.Assign(1, 1, 78, 2);
  Insert(New(PLabel, Init(R, ' N   Наименование операции Статус   Дата    Время       Сумма       Оператор', DocList)));


R.Assign(0, 0, 0, 0);
FiltrList := New(PBox, Init(R, 1, Nil));
FiltrList^.NewList(New(PTextCollection, Init(0,1)));

Assign (KassaFile,Path.ToClient+'Kassa.db');
c:=IOResult;
Reset (KassaFile);
c:=IOResult;
If c=0 Then
Begin
While Not(Eof(KassaFile)) Do
 Begin
  ReadOperation(KassaFile,KassaElement);
  If KassaElement.Employ Then
   Begin
    Format (KassaElement.Name,CClient);
    FiltrList^.List^.Insert(NewStr(KassaElement.Name+'│'+KassaElement.Kod));
    FiltrList^.SetRange(FiltrList^.List^.Count);
   End;
 End;
System.Close(KassaFile);
End
 Else
  Begin
   MessageBox(^M+#3'Ошибка открытия файла '+Path.ToClient+'Kassa.db',Nil,mfError+mfCancelButton);
  End;




R.Assign(1, 20, 16, 21);
Control := New(PColoredText, Init(R, ' Всего принято:', $74));
Insert(Control);

R.Assign(16, 20, 31, 21);
ControlItogoPlus := New(PColoredText, Init(R, #3+'0.00', $4E));
Insert(ControlItogoPlus);

R.Assign(31, 20, 45, 21);
Control := New(PColoredText, Init(R, ' Всего выдано:', $74));
Insert(Control);

R.Assign(45, 20, 60, 21);
ControlItogoMinus := New(PColoredText, Init(R, #3+'0.00', $4E));
Insert(ControlItogoMinus);

R.Assign(61, 20, 64, 21);
Control := New(PColoredText, Init(R, ' E:', $74));
Insert(Control);

R.Assign(64, 20, 79, 21);
ControlAll := New(PColoredText, Init(R, #3+'0.00', $4E));
Insert(ControlAll);

R.Assign(41, 18, 79, 19);
Control := New(PColoredText, Init(R, #3+'F4-аванс.отчет F5-ордер F6-детально', $74));
Insert(Control);

R.Assign(1, 19, 13, 20);
Control := New(PColoredText, Init(R, 'Комментарий:', $74));
Insert(Control);

R.Assign(13, 19, 79, 20);
ControlCom := New(PColoredText, Init(R, '', $7E));
Insert(ControlCom);

R.Assign(1, 18, 13, 19);
Control := New(PColoredText, Init(R, 'Сотрудник:', $74));
Insert(Control);

R.Assign(13, 19, 40, 20);
ControlSotr := New(PColoredText, Init(R, '', $7E));
Insert(ControlSotr);

SelectNext(False);

L:=True;
Refresh;
PrevCur[0]:=#0;
StartTime:=TimeStringToTime('hh:mm:ss',Times);
end;


constructor TDopReestrKWindow.Init(Var l : Boolean);
var
  R : TRect;
  Control : PView;
  C : Word;
  s: TMyString;
  ws : AllStr;
  E : PItogKAssa;
  SuperMarketFile: ItogKAssaFileType;


begin
L:=False;


R.Assign(0, 1, 80, 22);
inherited Init(R, ''{'Реестр кассовых операций за период c '+DocDate+' по '+StopDAte});
Options := Options or ofCenterX or ofCenterY;
HelpCtx:=$F155;


R.Assign(0, 1, 80, 22);
DopControlHeader := New(PColoredText, Init(R,'Расшифровка кассовой операции за период c '+DocDate+' по '+StopDAte, $4F));
Insert(ControlHeader);


R.Assign(79, 2, 80, 18);
Control := New(PScrollBar, Init(R));
Insert(Control);

R.Assign(1, 2, 79, 18);
DopDocList := New(PBox, Init(R, 1, PScrollbar(Control)));
DopDocList^.NewList(New(PTextCollection, Init(0,1)));

DopDocList^.FocusItem(0);
DopDocList^.HelpCtx:=$F155;

Insert(DopDocList);

  R.Assign(1, 1, 78, 2);
  Insert(New(PLabel, Init(R, ' N       Сумма           Примечание', DocList)));

R.Assign(1, 20, 16, 21);
Control := New(PColoredText, Init(R, ' Всего :', $74));
Insert(Control);

R.Assign(16, 20, 31, 21);
DopControlItogoPlus := New(PColoredText, Init(R, #3+'0.00', $4E));
Insert(DopControlItogoPlus);

R.Assign(31, 20, 45, 21);
Control := New(PColoredText, Init(R, ' Детально:', $74));
Insert(Control);

R.Assign(45, 20, 60, 21);
DopControlItogoMinus := New(PColoredText, Init(R, #3+'0.00', $4E));
Insert(DopControlItogoMinus);

R.Assign(61, 20, 64, 21);
Control := New(PColoredText, Init(R, ' E:', $74));
Insert(Control);

R.Assign(64, 20, 79, 21);
DopControlAll := New(PColoredText, Init(R, #3+'0.00', $4E));
Insert(DopControlAll);

R.Assign(40, 18, 79, 19);
Control := New(PColoredText, Init(R, #3+'F5-Новая', $74));
Insert(Control);

R.Assign(1, 19, 13, 20);
Control := New(PColoredText, Init(R, '', $74));
Insert(Control);

R.Assign(13, 19, 79, 20);
DopControlCom := New(PColoredText, Init(R, '', $7E));
Insert(DopControlCom);

R.Assign(1, 18, 13, 19);
Control := New(PColoredText, Init(R, '', $74));
Insert(Control);

R.Assign(13, 19, 40, 20);
DopControlSotr := New(PColoredText, Init(R, '', $7E));
Insert(DopControlSotr);

SelectNext(False);

L:=True;
Refresh;
PrevCur[0]:=#0;
StartTime:=TimeStringToTime('hh:mm:ss',Times);
end;





Procedure TReestrKWindow.FormReport(Const P:PBox);
Const Space=' ';
Var f : text;
	 sDoc,sDate,ws,s,s1,s2 : string[150];
	 tt,c,w,cc : Word;
	 Find : Boolean;
	 SSaldo,sSumma,sAllSumma:String[CIZena];
      Fp : ItogKAssaFileType;
      E : PItogKAssa;
      sLizo:string[CClient];
Begin
If (P^.List<>Nil) And (P^.List^.Count>=1) Then
 Begin
 Assign (f,Path.ToTemp+'saldok.txt');
 c:=0;
 Rewrite(f);
 c:=IOResult;
 If c<>0 Then
  Begin
	MessageBox(#3^m+#3+'Не могу создать файл '+Path.ToTemp+'saldok.txt',Nil,mfError+mfCancelButton);
   Exit;
  End;

 Writeln(f);


 AInfo('Минуточку...');

 Writeln(f,Space+'Склад: ',GetClientField(FClient,Rek.Kod,1)+'  Оператор: '+CurrentPassword+' EYE & 1997-98');

 Writeln(f,Space+Space+'ОТЧЕТ ПО КАССОВЫМ ОПЕРАЦИЯМ ЗА ПЕРИОД С '+DocDate+' по '+StopDAte);
 Writeln(f);

If (FiltrList^.List<>Nil) And (FiltrList^.List^.Count>=1) Then
 Begin
  Writeln(f,Space+'Выбранные операции:');
  For c:=0 To FiltrList^.List^.Count-1 Do
  Begin
   s := FiltrList^.GetText(c,FiltrList^.List^.Count);
   While Pos('│',s)>0 Do
    Begin
     w:=Pos('│',s);
     System.Delete(s,w,1);
     System.Insert(' ',s,w);
    End;
   Writeln(f,Space+s);
  End;
 End;

   Writeln(f);


 Writeln(f,Space+' _______________________________________________________________________________');
 Writeln(f,Space+'  N   Сотрудник            Наменование операции Статус  Дата     Время       Сумма         Оператор  ');
			  { 1234│12345678901234567890│12345678901234567890││12345678901234567890│123456│12345678│12345678│12'}
 Writeln(f,Space+' _______________________________________________________________________________');

 For cc:=0 To P^.List^.Count-1 Do
  Begin
	s := P^.GetText(cc,P^.List^.Count);

	While Pos('│',s)>0 Do
	 Begin
	  w:=Pos('│',s);
	  System.Delete(s,w,1);
	  System.Insert(' ',s,w);
	 End;

	s[0]:=Chr(1+CDocNumer+1+CCLient+1+6+1+CDAte+1+CDate+1+CIZena+1+CKto);
	s:=s{+' '+s1};

     sDoc:=copy(s,1+1,CDocNumer);
     sDate:=copy(s,1+CDocNumer+1+CCLient+1+6+1+1,CDate);



     c:=IOResult;
     Assign(fp,Path.ToClient+sDate+'.kas');
     Reset(fp);
     c:=IOResult;

If c=0 Then
Begin
New(E,Init);
While Not(Eof(Fp)) Do
 Begin
  ReadKassa(Fp,E^.DAt);
  {writeln(f,'!!!'+s);}
    if (StrToInt(sDoc)=StrToInt(E^.DAt.Doc)) then
     begin

      sLizo:=GetLizoField(fClient,E^.DAt.Lizo);
      format(sLizo,CClient);
      System.Insert(' '+sLizo,s,6);
      Writeln(f,Space+s);

      Ws:='';
      For tt:=1 To E^.DAt.Amount Do
      begin
       if tt=1 then
       begin
         writeln(f,Space+'В том числе:');
         Str(E^.DAt.Summa:CIZena:CMAntissa,sAllSumma);
       end;
       sDoc:=IntToStr(tt,4);
       Str(E^.DAt.Input[tt].Summa:CIZena:CMantissa,ssUMMA);
       rformat(ssUmma,CIZena);
       rFormat(sDoc,4);
       ws:='';
       ws:=sDoc+'.'+sSumma+'│'+E^.DAt.Input[tt].Comment;
       Str(StrToReal(sAllSumma)-StrToReal(sSumma):CIZena:CMAntissa,sAllSumma);
       {if (tt<>E^.DAt.Amount) then} Writeln(f,Space+ws);
       if (StrToReal(sAllSumma)>0.005) and (tt=E^.DAt.Amount) then writeln(f,Space+'Нераспределено:'+sAllSumma)
    {Str(StrToReal(AllMinus)+StrToReal(sSumma):CIZena:CMAntissa,AllMinus);}
      end; {For tt:=1}
      break;
    end; {if (StrToInt(sDoc)}
  end; {While Not(Eof(Fp))}
Dispose(E,Done);
SyStem.close(fp);
end; {If c=0 Then}

  End; {For cc:=0 To P^.List^.Count-1}
 Writeln(f,Space+' _______________________________________________________________________________');


 Writeln(f,Space+'          Всего поступления в кассу: ',Recogniz(AllPlus));
 Writeln(f,Space+'              Всего расход из кассы: ',Recogniz(AllMinus));
 Writeln(f,Space+'                             Сальдо: ',Recogniz(All));





 Writeln(f,Space,' "'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
 Writeln(f,Space+' ===============================================================================');
 System.Close(f);
 NoInfo;
 ViewAsText(Path.ToTemp+'saldok.txt',True);
 Report(Path.ToTemp+'saldok.txt','',1,False,False,false);

 End;
End;



Procedure TReestrKWindow.Print(Const P:PBox);
Const Space=' ';
Var f : text;
	 OSN,sLizo,Kod,ws,s,s1,s2 : string[150];
	 c,w : Word;
	 Find : Boolean;
	 SSaldo:String[CIZena];
      Doc,Date,Summa : AllStr;
Begin

If (P^.List<>Nil)And(P^.List^.Count>=1) Then
Begin
  Doc:=Copy(DocList^.GetText(DocList^.Focused,DocList^.List^.Count),1+1,CDocNumer);
  DelSpace(Doc);
  DelZerro(Doc);
  Date:=Copy(DocList^.GetText(DocList^.Focused,DocList^.List^.Count),1+1+CClient+1+CDocNumer+1+6+1,CDate);
  DelSpace(Date);
  Summa:=Copy(DocList^.GetText(DocList^.Focused,DocList^.List^.Count),1+1+CClient+1+CDocNumer+1+CDate+1+CDate+1+
  6+1,CIZena);
  Kod:=Copy(DocList^.GetText(DocList^.Focused,DocList^.List^.Count),1+CDocNumer+1+CClient+1+7+1+CDAte+1+CDAte+1+
  CIZena+1+CKto+1+CSertif+1,4);
  sLizo:=Copy(DocList^.GetText(DocList^.Focused,DocList^.List^.Count),1+CDocNumer+1+CClient+1+7+1+CDAte+1+CDAte+1+
  CIZena+1+CKto+1+CSertif+1+4+1,4);
  OSN:=Copy(DocList^.GetText(DocList^.Focused,DocList^.List^.Count),1+1+1+CDocNumer,CClient);
  DelSpace(Kod);
  DelSpace(sLizo);

{
  Writeln(DocList^.GetText(DocList^.Focused,DocList^.List^.Count));
  Writeln(Doc);
  Writeln(Date);
  Writeln(Summa);
  Readln;
}
  PrintOrder2(Osn,GetLizoField(fClient,sLizo),Doc,Date,Kod,Summa);

 End;
End;






procedure TReestrKWindow.HandleEvent(var Event: TEvent);
Var test : Word;
    s,s1 : string;
    SDoc : ArtikulStr;
    SDate: TDateString;
    l : Boolean;
    FC:Byte;
    FS : AllStr;

begin
  Case Event.What Of
  evKeyDown :
  Case Event.KeyCode Of
     kbEsc: Begin
              ClearFind;
              Event.What:=evCommand;
              Event.Command:=cmCancel;
              PutEvent(Event);
              ClearEvent(Event);
            End;
  kbF6: if CurrentPassword='00' then begin
          if (DocList^.List<>Nil)And(DocList^.List^.Count>=1) Then
            Begin
            s:=DocList^.GetText(DocList^.Focused,DocList^.List^.Count);
            EditKassa.D:=copy(s,1+CDocNumer+1+CClient+1+7+1,CDAte);
            EditKassa.EditPosition:=copy(s,1+1,CDocNumer);

          DopReestrKWindow^.OpenReestrWindow;
            end;
        end;

  kbF4: {if CurrentPassword='00' then begin}
          if (DocList^.List<>Nil)And(DocList^.List^.Count>=1) Then
            Begin
            s:=DocList^.GetText(DocList^.Focused,DocList^.List^.Count);
            EditKassa.D:=copy(s,1+CDocNumer+1+CClient+1+7+1,CDAte);
            EditKassa.EditPosition:=copy(s,1+1,CDocNumer);
            if pos('расход',s)>0 then
            PrintAvansReport(EditKassa);
          {DopReestrKWindow^.OpenReestrWindow;}
           { end;}
        end;

  kbF5 :Begin
             {
             Event.What:=EvCommand;
             Event.Command:=CmReestrReport;
             PutEvent(Event);
             }
            if (DocList^.List<>Nil)And(DocList^.List^.Count>=1) Then
            Begin
             Print(DocList);
             ClearEvent(Event);
            End;

             ClearEvent(Event);
        End;
      Else;
      End;{KeyDown}
  evCommand :
     Case Event.Command Of

    cmAbout: Begin
    AboutCHM('51');
    ClearEvent(Event);
    End;


    cmParametr : Begin
                  If SelectionKAssa(FiltrList) Then
                   Begin
                    Refresh;
                    Redraw;
                   End;

                 End;


  cmRefresh : Begin
               Refresh;
               Redraw;
              End;
  cmReestrReport:    Begin
                 ClearFind;
     If (DocList^.State and sfFocused <> 0) And (DocList^.List<>Nil)And(DocList^.List^.Count>=1) Then
            Begin
             FormReport(DocList);
             ClearFind;
             ClearEvent(Event);
            End
            End;



 cmPrintReestr:    Begin
     If (DocList^.State and sfFocused <> 0) Then
            Begin
             s:=DocList^.GetText(DocList^.Focused,DocList^.List^.Count);
             Op^.Start(false,As);
             Refresh;
             Redraw;
            End
            End;

     cmReestrKAssa: Begin
               ClearFind;
               ClearEvent(Event);
                    End;

 cmChangeDiapason :Begin
                    If DAtePeriodDialog(DocDAte,StopDAte,FAlse) Then
                     Begin
                      Refresh;
                      Redraw;
                     End;
                   End;


     cmCancel    : Begin
                 ClearFind;
                 Event.What:=evCommand;
                 Event.Command:=cmClose;
                 Dispose(FiltrList,Done);
                 PutEvent(Event);
                 ClearEvent(Event);
                End;

      Else;
      End;{evCommand}
      Else;
      End;{*Case*}
  if (Event.What = evBroadcast) and
    (Event.Command = cmReestrKAssa) then ClearEvent(Event);

  if (Event.What = evBroadcast) and
    (Event.Command = cmQuit) then ClearEvent(Event);


  inherited HandleEvent(Event);


  If (Desktop^.Current=PView(DocReestrWindow)) And (Event.What <> EvKeyDown) Then
             Begin

            if (DocList^.List<>Nil)And(DocList^.List^.Count>=1) Then
              Begin
               s:=DocList^.GetText(DocList^.Focused,DocList^.List^.Count);
               If s <> PrevCur Then
                 Begin
                  PrevCur:=S;
                  DrawCurrent;
                 End;
              End
              Else
                  DrawCurrent;
             End;
end;

procedure TDopReestrKWindow.HandleEvent(var Event: TEvent);
Var test : Word;
    s,s1 : string;
    SDoc : ArtikulStr;
    SDate: TDateString;
    l : Boolean;
    FC:Byte;
    FS : AllStr;

begin
  Case Event.What Of
  evKeyDown :
  Case Event.KeyCode Of
     kbF5: begin
             Op^.Start;
             Refresh;
             Redraw;
            end;
     kbEsc: Begin
              ClearFind;
              Event.What:=evCommand;
              Event.Command:=cmCancel;
              PutEvent(Event);
              ClearEvent(Event);
            End;

      End;{KeyDown}
  evCommand :
     Case Event.Command Of

  cmRefresh : Begin
               Refresh;
               Redraw;
              End;
  cmReestrReport:    Begin
                 ClearFind;
     If (DopDocList^.State and sfFocused <> 0) And (DopDocList^.List<>Nil)And(DopDocList^.List^.Count>=1) Then
            Begin
             {FormReport(DocList);}
             ClearFind;
             ClearEvent(Event);
            End
            End;

 cmPrintReestr:    Begin
   (*  If (DocList^.State and sfFocused <> 0) Then
            Begin
             Op^.Start;
             Refresh;
             Redraw;
            End  *)
            End;

     cmReestrKAssa:Begin
             ClearFind;
             ClearEvent(Event);
                 End;

 cmChangeDiapason :Begin
(*                    If DAtePeriodDialog(DocDAte,StopDAte,FAlse) Then
                     Begin
                      Refresh;
                      Redraw;
                     End;  *)
                   End;


     cmCancel    : Begin
                 ClearFind;
                 Event.What:=evCommand;
                 Event.Command:=cmClose;
                 {Dispose(FiltrList,Done);}
                 PutEvent(Event);
                 ClearEvent(Event);
                End;

      Else;
      End;{evCommand}
      Else;
      End;{*Case*}
{  if (Event.What = evBroadcast) and
    (Event.Command = cmReestrKAssa) then ClearEvent(Event);}

{  if (Event.What = evBroadcast) and
    (Event.Command = cmQuit) then ClearEvent(Event);}


  inherited HandleEvent(Event);


  If (Desktop^.Current=PView(DopDocReestrWindow)) And (Event.What <> EvKeyDown) Then
             Begin

            if (DopDocList^.List<>Nil)And(DopDocList^.List^.Count>=1) Then
              Begin
               s:=DopDocList^.GetText(DopDocList^.Focused,DocList^.List^.Count);
               If s <> PrevCur Then
                 Begin
                  PrevCur:=S;
                  DrawCurrent;
                 End;
              End
              Else
                  DrawCurrent;
             End;
end;



procedure TAddOperation.Start(dolg: boolean; AS: DocumentEdit);
var
  R : TRect;
  Control : PView;
  c : Word;
  E : KassaOperation;
  f : OperationFileType;
  fd: file of ItogKassa;
  Summa : String[CIZena];
  Comment : String[CSertif];
  Ak : PItogKassa;
  S,s1  : string[150];
  i: word;
  test: word;
  AD,AD1: PDolgKassa;
  fad: file of DolgKassa;
  bFull: boolean;
begin

NAmeOperation[0]:=#0;
Assign(f,Path.ToClient+'kassa.db');
Reset(f);
c:=Ioresult;
If c=0 Then
 Begin
  While Not(Eof(f)) Do
   Begin
    ReadOperation(f,E);
    If E.Employ Then
     Begin
      Format(E.NAme,CClient);
      NAmeOperation:=#3+E.NAme+'│'+E.Kod;
      Break;
     End;
   End;
  System.Close(f);
  c:=Ioresult;
 End
 Else Exit;

{Добавление сотрудника}

if not dolg then
begin
bDolg:=false;
LizoWindow^.ShowAgentList(s,Test);
end
else
begin
bDolg:=true;
s:=PrevS;
end;


R.Assign(6, 8, 74, 15);

New(AddWindow, Init(R, 'Регистрация операции'));
AddWindow^.Options := AddWindow^.Options or ofCenterX or ofCenterY;
AddWindow^.HelpCtx:= $E002;

R.Assign(16, 1, 43, 2);
ControlNameOperation := New(PColoredText, Init(R,NameOperation, $1F));
ControlNameOperation^.Options := ControlNameOperation^.Options or ofSelectable;

AddWindow^.Insert(ControlNameOperation);


R.Assign(1, 1, 16, 2);
AddWindow^.Insert(New(PLabel, Init(R, '~В~ид операции:', ControlNameOperation)));

R.Assign(50, 1, 67, 2);
ControlSumma := New(PInputLine, Init(R, 15));
AddWindow^.Insert(ControlSumma);
  PInputLine(ControlSumma)^.Validator := New(PFilterValidator, Init(['0','1','2','3','4','5','6','7','8','9','0','.']));

  R.Assign(43, 1, 50, 2);
  AddWindow^.Insert(New(PLabel, Init(R, 'Сумма:', ControlSumma)));

R.Assign(1, 3, 67, 4);
ControlComment := New(PInputLine, Init(R, 64));
AddWindow^.Insert(ControlComment);

  R.Assign(1, 2, 25, 3);
  AddWindow^.Insert(New(PLabel, Init(R, 'Комментарий к операции:', ControlComment)));

R.Assign(6, 5, 33, 6);
ControlLizo := New(PInputLine, Init(R, 64));
AddWindow^.Insert(ControlLizo);

  R.Assign(1, 4, 25, 5);
  AddWindow^.Insert(New(PLabel, Init(R, 'Сотрудник:', ControlLizo)));

AddWindow^.SelectNext(False);

ControlLizo^.SetData(s);

c:=DeskTop^.ExecView(AddWindow);

If c <> cmCancel Then
 Begin
  ControlSumma^.GetData(Summa);
  DelSpace(Summa);
  ControlComment^.GetData(Comment);
  DelSpaceRight(Comment);
  s:=PStaticText(ControlNameOperation)^.Text^;
  System.Delete(s,1,1);

  s1:=PStaticText(ControlLizo)^.Text^;

  New(Ak,Init);
  New(AD,Init);
  Ak^.DAt.Kod:=Copy(s,1+CCLient+1,CClientKod);
   AD^.DAt.Kod:=Copy(s,1+CCLient+1,CClientKod);
  Ak^.DAt.Lizo:=Copy(s1,1+CCLient+1,CClientKod);

  Ak^.DAt.Main:=1;
  Ak^.DAt.Summa:=StrToReal(Summa);
   AD^.Dat.Summa:=StrToReal(Summa);
   AD^.Dat.SummaDoc:=StrToReal(Summa);
  Ak^.DAt.Comment:=Comment;
  Ak^.DAt.Caption:=CurrentPassword;
  AD^.DAt.Caption:=CurrentPassword;
  {Ak^.DAt.Active :=True;}

  LockAndWriteKassa(Ak,AD^.Dat.Doc);

  {запись долгов}
  rformatzerro(Ak^.DAt.Lizo,CClientKod);
  Assign(fd,Path.ToClient+Ak^.DAt.Lizo+'.dls');
  c:=IOResult;
  Reset(fd);
  c:=IOResult;
  If c<>0 Then Rewrite(fd);
  c:=IOResult;
  If c=0 then
  begin
    bFull:=false;
    CAse StrToInt(GetOperationField(FStatus,AD^.DAt.Kod)) Of
    0:Begin
       {расход}
        LockAndWriteLizoKassa(AD,Ak^.DAt.Lizo);
      End;

    1:Begin
       {приход}
         AD^.DAt.DocTek:=AD^.DAt.Doc;
         AD^.DAt.Doc:=As.EditPosition;
         AD^.DAt.DateTek:=AD^.DAt.DateC;
         AD^.DAt.DateC:=DateStringToDate(DAteMAsk,As.D);
         LockAndWriteLizoKassa(AD,Ak^.DAt.Lizo);
         {уменьшаем долг}
         Assign(fad,Path.ToClient+Ak^.DAt.Lizo+'.dls');

         c:=IOResult;
         Reset(fad);
         c:=IOResult;
         if c=0 then
         begin
         new(AD1,Init);
         while not eof(fad) do
         begin
          read(fad,AD1^.Dat);
          if StrToInt(GetOperationField(FStatus,AD1^.DAt.Kod))=0 then
          if (StrToInt(AD1^.Dat.Doc)=StrToInt(As.EditPosition)) and
          (AD1^.DAt.DateC=DateStringToDate(DAteMAsk,As.D)) then
          begin
            AD1^.DAt.Summa:=AD1^.DAt.Summa-AD^.DAt.Summa;
            if ABS(AD1^.DAt.Summa)<0.01 then
            begin
		    AD1^.DAt.Full:=true;
              bFull:=true;
            end;
            seek(fad,filepos(fad)-1);
            write(fad,AD1^.DAt);
          end;
          end;
         end
         else
         begin
           memcc(IntToStr(c,4));
         end;
         System.Close(fad);
         Dispose(AD1,Done)
      End;
    End;{CAse}
   End; {if}

 If MessageBox(^M+#3'Печатать кассовый ордер? ',Nil,mfConfirmation+mfOkCancel)=cmOk Then
 begin
  PrintOrder2(Ak^.DAt.Comment,GetLizoField(fClient,Ak^.DAt.Lizo),Ak^.DAt.Doc,
    DateToDateString(DateMask,Ak^.DAt.Datec),Ak^.DAt.Kod,Summa);
 end;

 if bFull then
 If MessageBox(^M+#3'Печатать авансовый отчет? ',Nil,mfConfirmation+mfOkCancel)=cmOk Then
 begin
  EditKassa.D:=DateToDateString(DateMask,Ak^.DAt.Datec);
  EditKassa.EditPosition:=Ak^.DAt.Doc;
  PrintAvansReport(EditKassa);
 end;

  Dispose(Ak,Done);
  Dispose(AD,Done);
 End;

Dispose(ControlNAmeOperation,Done);
Dispose(ControlSumma,Done);
Dispose(ControlComment,Done);
Dispose(ControlLizo,Done);
Dispose(AddWindow,Done);
End;

procedure TDopAddOperation.Start;
var
  R : TRect;
  Control : PView;
  c : Word;
  E : KassaOperation;
  f : OperationFileType;
  sSumma : String[CIZena];
  Comment : String[CSertif];
  Ak : PItogKassa;
  S,s1  : string[150];
  i: word;
  test: word;
  Fp : ItogKAssaFileType;
  AS: DocumentEdit;
begin

R.Assign(6, 8, 74, 15);

New(AdddOPWindow, Init(R, 'Регистрация операции'));
AdddOPWindow^.Options := AdddOPWindow^.Options or ofCenterX or ofCenterY;
AdddOPWindow^.HelpCtx:= $E002;

R.Assign(50, 1, 67, 2);
dControlSumma := New(PInputLine, Init(R, 15));
AdddOPWindow^.Insert(dControlSumma);
  PInputLine(dControlSumma)^.Validator := New(PFilterValidator, Init(['0','1','2','3','4','5','6','7','8','9','0','.']));

  R.Assign(43, 1, 50, 2);
  AdddOPWindow^.Insert(New(PLabel, Init(R, 'Сумма:',dControlSumma)));

R.Assign(1, 3, 67, 4);
dControlComment := New(PInputLine, Init(R, 64));
AdddOPWindow^.Insert(dControlComment);

  R.Assign(1, 2, 25, 3);
  AdddOPWindow^.Insert(New(PLabel, Init(R, 'Комментарий к операции:', DControlComment)));

AdddOPWindow^.SelectNext(False);

c:=DeskTop^.ExecView(AdddOPWindow);

If c <> cmCancel Then
 Begin
  sSumma:='';
  dControlSumma^.GetData(sSumma);
  DelSpace(sSumma);
  dControlComment^.GetData(Comment);
  DelSpaceRight(Comment);

Assign(fp,Path.ToClient+EditKassa.D+'.kas');
Reset(fp);
c:=IOResult;
If c=0 Then
Begin
  New(Ak,Init);
  While Not(Eof(Fp)) Do
   Begin
    ReadKassa(Fp,Ak^.DAt);
    if StrToInt(Ak^.DAt.Doc)=StrToInt(EditKassa.EditPosition) then
    begin
     Ak^.DAt.Input[Ak^.DAt.Amount+1].Summa:=StrToReal(sSumma);
     Ak^.DAt.Input[Ak^.DAt.Amount+1].Comment:=Comment;
     inc(Ak^.DAt.Amount);
     LockAndWriteKassaAs(EditKassa,Ak);
     break;
    end;
   end;
  Dispose(Ak,Done);
End;
End;


Dispose(dControlSumma,Done);
Dispose(dControlComment,Done);
Dispose(AdddOPWindow,Done);
End;



procedure TAddOperation.HandleEvent(var Event: TEvent);
Var s : string[100];
    L : Boolean;
    Test : Word;

Begin
CAse Event.What Of
 evCommand:
   Case Event.Command Of
    cmSelectKAssa:
         Begin
           If (PView(SelOperation)<>Desktop^.TopView)And(ControlNameOperation^.State and sfFocused <> 0) Then
            Begin
             PStaticText(ControlNameOperation)^.GetText(S);
             System.Delete(S,1,1);
             l:=True;
             SelOperation^.ShowOperationList(s,Test, bDolg);
             PStaticText(ControlNameOperation)^.Text^:=#3+S;
             Redraw;
             Case Test Of
              0,3 :FocusNext(True);
              1,2 :FocusNext(False);
             Else;
             End;
             ClearEvent(Event);
            End
            Else ClearEvent(Event);
         End;
   Else;
   End;

 Else;
 End;


 If (PView(SelOperation)<>Desktop^.TopView)   And
    (ControlNameOperation^.State and sfFocused <> 0) And
    (Event.Command<>cmSelectKAssa) And
    (Event.What <> EvKeyDown)Then
            Begin
             Event.What:=EvCommand;
             Event.Command:=cmSelectKAssa;
             PutEvent(Event);
             ClearEvent(Event);
            End;


  inherited HandleEvent(Event);

End;

procedure TDopAddOperation.HandleEvent(var Event: TEvent);
Var s : string[150];
    L : Boolean;
    Test : Word;

Begin
CAse Event.What Of
 evCommand:
   Case Event.Command Of
    cmSelectKAssa:
        Begin
       (*    If (PView(SelOperation)<>Desktop^.TopView)And(ControlNameOperation^.State and sfFocused <> 0) Then
            Begin
             PStaticText(ControlNameOperation)^.GetText(S);
             System.Delete(S,1,1);
             l:=True;
             SelOperation^.ShowOperationList(s,Test);
             PStaticText(ControlNameOperation)^.Text^:=#3+S;
             Redraw;
             Case Test Of
              0,3 :FocusNext(True);
              1,2 :FocusNext(False);
             Else;
             End;
             ClearEvent(Event);
            End
            Else ClearEvent(Event);*)
         End;
   Else;
   End;

 Else;
 End;


(* If (PView(SelOperation)<>Desktop^.TopView)   And
    (ControlNameOperation^.State and sfFocused <> 0) And
    (Event.Command<>cmSelectKAssa) And
    (Event.What <> EvKeyDown)Then
            Begin
             Event.What:=EvCommand;
             Event.Command:=cmSelectKAssa;
             PutEvent(Event);
             ClearEvent(Event);
            End; *)


  inherited HandleEvent(Event);

End;


BEgin

DocDate:=FDAte;
StopDate:=FDAte;
End.