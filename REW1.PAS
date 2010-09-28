{12345678901234567890123456│12345│123456│123456│123456│123456│123456│123456│12345678│12345678│}
{Наименование               Код   Всего  1отд   2отд   3отд   4отд   5отд   Цена Р   Цена О}
{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}

Unit Rewisia;

Interface


Uses Dialogs,Drivers,Glob,Access,MyCalc;

Type
  PRewWindow = ^TRewWindow;
  TRewWindow = object(TDialog)
   Calc        : PMyCalculator;
    Procedure Ini(Var s:String;Regim:Word);
    procedure HandleEvent(var Event: TEvent); virtual;
    Destructor Done;Virtual;
  end;


Type
  PRewisiaWindow = ^TRewisiaWindow;
  TRewisiaWindow = object(TDialog)
    Rew : PRewWindow;
    Rz  : PRazdelWindow;
    Nam : PNameWindow;
    constructor Init(Var l: Boolean);
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure FreshBazHint;
    procedure FreshAktHint;
    procedure AddName;
    procedure OpenRewisiaWindow;
    procedure CalcItogo;
    Procedure SaveToFileRew(Var Save : Boolean);
    procedure UnlockAllName;
  end;


Procedure EditRewisiaComment(As:DocumentEdit);

 Implementation

uses DBEngine,Objects, Views, MsgBox,Vision3,Protect,{Calc,}Windos,
        App, ColorTxt,Serv,Validate,ServStr,Net,NetDbEng,NetCall;

var
 RewWin : PRewWindow;
 RewisiaWindow : PRewisiaWindow;
{ PrevRewisia : PRewisiaType;}
 ControlKol,ControlPack,Control2,Control3,Control4,Control5,Control1,
 ControlRazdel,ControlDoc,ControlCurrent,ControlPackList,ControlKolList,
 ControlRZenaList,ControlItogo,ControlItogoPlus,ControlItogoMinus,
 ControlLitrList,ControlDivisionRewisia : PView;
 PrevS : String;
 PrevCurrent : String;
 PrevNakl : String;
 SArtikul : ArtikulStr;
 InPut : InputRewisiaType;


Procedure TRewisiaWindow.FreshBazHint;
Var s : String;
    SArtikul : ArtikulStr;
    SKol : String[CKol];
    SInPack:String[CInPack];
    SZena,SPack : String[CPack];
    SLitr : String[CLitr];
    R : TRect;
Begin
 If (Baz^.List<>Nil)And(Baz^.List^.Count>0)  Then
  Begin
   s:=Baz^.GetText(Baz^.Focused,Baz^.List^.Count);
   If s <> PrevCurrent Then
    Begin
        PrevCurrent:=s;
        SArtikul:=Copy(s,1+CName+1,Cartikul);
        SLitr:=GetIdField(FLitr,SArtikul);
        DelSpace(SLitr);
        SKol:=BakGetField(FKoL,SArtikul,1);
        STr(StrToInt(SKol):CKol,SKol);
        DelSpace(SKol);
        SZena :=BakGetField(FRZena,SArtikul,1);
        STr(StrToReal(SZena):CZena:CMantissa,SZena);
        DelSpace(SZena);
        SInPack:=GetIdField(FInPack,SArtikul);
        DelSpace(SInPack);
        sPack:=CalcPack(sArtikul,skol);
        DelSpace(spack);

Dispose(ControlPackList,Done);
R.Assign(13, 20, 22, 21);
ControlPackList := New(PColoredText, Init(R, #3+SPAck, $7E));
Insert(ControlPackList);

Dispose(ControlKolList,Done);
R.Assign(32, 20, 37, 21);
ControlKolList := New(PColoredText, Init(R, #3+SKol, $7E));
Insert(ControlKolList);

Dispose(ControlRZenaList,Done);
R.Assign(13, 21, 21, 22);
ControlRZenaList := New(PColoredText, Init(R, #3+SZena, $7E));
Insert(ControlRZenaList);

Dispose(ControlLitrList,Done);
R.Assign(32, 21, 37, 22);
ControlLitrList := New(PColoredText, Init(R, #3+SLitr, $7E));
Insert(ControlLitrList);

    End;
  End
  Else
   Begin
Dispose(ControlPackList,Done);
R.Assign(13, 20, 22, 21);
ControlPackList := New(PColoredText, Init(R, #3+'', $7E));
Insert(ControlPackList);

Dispose(ControlKolList,Done);
R.Assign(32, 20, 37, 21);
ControlKolList := New(PColoredText, Init(R, #3+'', $7E));
Insert(ControlKolList);

Dispose(ControlRZenaList,Done);
R.Assign(13, 21, 21, 22);
ControlRZenaList := New(PColoredText, Init(R, #3+'', $7E));
Insert(ControlRZenaList);

Dispose(ControlLitrList,Done);
R.Assign(32, 21, 37, 22);
ControlLitrList := New(PColoredText, Init(R, #3+'', $7E));
Insert(ControlLitrList);
   End;
End;

Procedure TRewisiaWindow.FreshAktHint;
Var s : String;
    St : ArtikulStr;
    s1 : TDateString;
    R : TRect;
    j : Byte;
Begin
 If (NewTovar^.List<>Nil)And(NewTovar^.List^.Count>0)  Then
  Begin
   s:=NewTovar^.GetText(NewTovar^.Focused,NewTovar^.List^.Count);
   If s <> PrevNakl Then
    Begin
        PrevNakl:=s;
        s[0]:=#0;

    For j:=1 To CDivision Do
    Begin
        s1:=Copy(PrevNakl,1+CName+1+CArtikul+1+(CKol+1)*j+1*j,CKol+1);
        DelSpace(s1);
        Format(s1,CKol+1);
        Str(j:COne,st);
        s:=s+St+':'+s1+' ';
    End;

Dispose(ControlDivisionRewisia,Done);
R.Assign(35, 22, 79, 23);
ControlDivisionRewisia := New(PColoredText, Init(R, s, $71));
Insert(ControlDivisionRewisia);

    End;
  End
  Else
   Begin
    If PrevNakl[0]<>#0 Then
    Begin
        Dispose(ControlDivisionRewisia,Done);
        R.Assign(35, 22, 79, 23);
        ControlDivisionRewisia := New(PColoredText, Init(R, #3+'', $71));
        Insert(ControlDivisionRewisia);
        PrevNakl[0]:=#0;
    End;
   End;
End;


(*
Function WriteRewisiaToFile(L:PRewisiaType) : Boolean;
Var RewisiaFile : File Of RewisiaType;
    c : Byte;
Begin
 WriteRewisiaToFile:=False;
 Assign(RewisiaFile,Path.ToRewisia+L^.Dat.DateC+'.rwz');
 c:=IOResult;
{$I-}
 Reset(RewisiaFile);
 c:=IOResult;
If c<>0 Then
 Begin
  If MessageBox(#3+'Файл '+L^.Dat.DateC+'.rwz не существует !'^M+
        'Создать такой файл?'+
        +' Код:'+IntToStr(c,3),nil, mfConfirmation + mfOkCancel)=cmOk  Then
        Begin
         Rewrite(RewisiaFile);
         c:=IOResult;
        End
    Else
        Begin
         Exit;
        End;
 End;
 If c <> 0 Then Begin
                          MessageBox(#3^M+#3'Нет доступа к файлу '+L^.Dat.DateC+'.rwz!',
                          nil, mfError + mfOkButton);
                          Exit;
                         End
 Else
  Begin
   Seek(RewisiaFile,StrToInt(ClearChar(L^.Dat.Document))-1);
   Write(RewisiaFile,L^.Dat);
   Close(RewisiaFile);
   WriteRewisiatoFile:=True;
  End;
End;
*)


Function TestRewisiaInSkladFile(L:PRewisiaType) : Boolean;
Var SkladFile : File Of SkladType;
    Sklad : PSkladType;
    i,p,k : Byte;
    Ls:LongInt;
    s1,s2 : TEnjoyStr;

Begin
TestRewisiaInSkladFile:=False;
 For i:=1 To L^.DAt.Amount{J} Do
  Begin
   For k:=1 To CDivision Do
    Begin
        If (StrtoInt(BakGetField(FDiv,L^.Dat.Element[i].Bazkod,k))+
           StrToInt(L^.Dat.Element[i].Input.Division[k]))<0 Then
         Begin
          MessageBox(#3'На складе в позиции '+L^.Dat.Element[i].Bazkod+
                ' получится ОТРИЦАТЕЛЬНОЕ КОЛИЧЕСТВО.'^M+
                #3+'Исправьте ошибку и повторите ввод!!!',Nil,mfError+mfCancelButton);
          Exit;
         End;
    End;
  End;
TestRewisiaInSkladFile:=True;
End;


Function WriteRewisiaToSkladFile(L:PRewisiaType) : Boolean;
Var SkladFile : File Of SkladType;
    Sklad : PSkladType;
    i,p,k : Byte;
    Ls:LongInt;
    s1,s2 : TEnjoyStr;
Begin
WriteRewisiaToSkladFile:=False;
New(Sklad,Init);
 For i:=1 To L^.DAt.Amount{J} Do
  Begin
   S1:=Copy(L^.Dat.Element[i].BazKod,1,CRazdelKod);
   Assign(SkladFile,Path.ToSklad+s1+'.db');
   p:=IOResult;
   Reset(SkladFile);
   p:=IOResult;
   If p <> 0 Then
    Begin
        MessageBox(#3^M+#3'Ошибка доступа к файлу '+S1+'.db!',Nil,mfError+mfCancelButton);
        Dispose(Sklad,Done);
        Exit;
    End;

   Seek(SkladFile,GetFileLocation3(Copy(L^.Dat.Element[i].BazKod,CRazdelKod+1,CKod)));

   {блокируем позицию предварительной блокировкой}

   Repeat
    Pause(1);
   Until Lock(SkladFile,FilePos(SkladFile)*SizeOf(SkladType),SizeOf(SkladType));

   Read(SkladFile,Sklad^.DAt);

    {модифицируем поля}
   With Sklad^.Dat.Input Do
   Begin
        Caption:=L^.Dat.Caption;
        DelSpace(L^.Dat.Element[i].Input.Kol);
        Sklad^.Dat.Date := FDate;
        Sklad^.Dat.Time := Times;
   End;


   For k:=1 To CDivision Do
   Str((StrToInt(Sklad^.Dat.Input.Division[k])+StrToInt(L^.Dat.Element[i].Input.Division[k])):CKol,
   Sklad^.Dat.Input.Division[k]);

   Sklad^.Dat.Input.Kol[0]:=#0;

   For k:=1 To CDivision Do
   Str((StrToInt(Sklad^.Dat.Input.Division[k])+StrToInt(Sklad^.Dat.Input.Kol)):CKol,Sklad^.Dat.Input.Kol);

   Sklad^.Dat.Employ:=True;

    {сохраняем изменения}
    Seek(SkladFile,FilePos(SkladFile)-1);
    Write(SkladFile,Sklad^.Dat);
    {деблокируем позицию}

    Seek(SkladFile,FilePos(SkladFile)-1);
    Repeat
     UnLock(SkladFile,FilePos(SkladFile)*SizeOf(SkladType),SizeOf(SkladType));
    Until (DosError=0);

   Close(SkladFile);{закрытие файла}
  End;
Dispose(Sklad,Done);
WriteRewisiaToSkladFile:=True;
End;

procedure TRewisiaWindow.UnlockAllName;
Var i : Integer;
    s : String;
Begin
If (NewTovar^.List^.Count-1)>=0 Then
 For i:=0 To NewTovar^.List^.Count-1 Do
 Begin
  s:=NewTovar^.GetText(i,NewTovar^.List^.Limit);
  s:=Copy(s,1+CName+1,CArtikul);
  Repeat
  Until(SetNameUnlock(s));
 End;
End;


Function AddComment(Var l:PRewisiaType):Boolean;
var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  c : Word;
begin
AddComment:=False;
R.Assign(6, 10, 74, 13);
New(Dlg, Init(R, 'Примечание к акту ревизии N '+L^.Dat.Document +' от '+L^.Dat.DateC));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx := $E002;

R.Assign(1, 1, 67, 2);
Control := New(PInputLine, Init(R, CSertif));
Dlg^.Insert(Control);

Dlg^.SetData(L^.Dat.Comment);
Dlg^.SelectNext(False);

c:=Desktop^.ExecView(Dlg);
If c<>cmCancel Then
 Begin
  Dlg^.GetData(L^.Dat.Comment);
  DelSpaceRight(L^.Dat.Comment);
  AddComment:=True;
 End;
Dispose(Control,Done);
Dispose(Dlg,Done);
end;



Procedure TRewisiaWindow.SaveToFileRew(Var Save : Boolean);
Var
    L : PRewisiaType;
    I : Byte;
    J : Word;
    s : String;
    st : String[CAll];
    As : DocumentEdit;
 TempRewisia : PBox;
    R : TRect;
Begin
Save:=False;
New(L,Init);{:=TestPr;}

{чтение с экрана прихода}
If NewTovar^.List^.Count-1>=0 Then
Begin
{создаем промежуточный список}
R.Assign(0,0,0,0);
TempRewisia := New(PBox, Init(R, 1, Nil));
TempRewisia^.NewList(New(PTextCollection, Init(1,1)));

For i:=0 To NewTovar^.List^.Count-1 Do
 Begin
  s:=NewTovar^.GetText(i,NewTovar^.List^.Limit);
  st:=Copy(s,1+CName+1,CRazdelKod);
  System.Delete(s,1+CName+1,CRazdelKod);
  System.Insert(st+'│',s,1);
  TempRewisia^.List^.Insert(NewStr(S));
  TempRewisia^.SetRange(TempRewisia^.List^.Count);
 End;

For i:=0 To TempRewisia^.List^.Count-1 Do
 Begin
  s:=TempRewisia^.GetText(i,TempRewisia^.List^.Limit);
  With L^.Dat.Element[i+1].Input Do
   Begin
    Kol:=Copy(s,1+CRazdelKod+1+CName+1+(CArtikul-CRazdelKod)+1,CKol+1);
    DelSpace(Kol);
    R_Zena:=Copy(s,1+CRazdelKod+1+CName+1+(CArtikul-CRazdelKod)+1+(CKol+1)+1+(CKol+1)*5+1*5,CZena);
    DelSpace(R_Zena);
    O_Zena:=Copy(s,1+CRazdelKod+1+CName+1+(CArtikul-CRazdelKod)+1+(CKol+1)+1+(CKol+1)*5+1*5+CZena+1,CZena);
    DelSpace(O_Zena);
    NSertif:=Copy(s,1+CRazdelKod+1+CName+1+(CArtikul-CRazdelKod)+1+(CKol+1)+1+(CKol+1)*5+1*5+CZena+1+CZena+1,CNSertif);
    Akzis1:=Copy(s,1+CRazdelKod+1+CName+1+(CArtikul-CRazdelKod)+1+(CKol+1)+1+(CKol+1)*5+1*5+CZena+1+CZena+1+CNSertif+1,
    CAkzis1);
    Zakupka:=Copy(s,1+CRazdelKod+1+CName+1+(CArtikul-CRazdelKod)+1+(CKol+1)+1+(CKol+1)*CDivision+1*CDivision+CZena+1+CZena+1,
    CZena);
    DelSpace(Zakupka);

    For j:=1 To CDivision Do
    Begin
    Division[j]:=Copy(s,1+CRazdelKod+1+CName+1+(CArtikul-CRazdelKod)+1+(CKol+1)*j+1*j,CKol+1);

    DelSpace(Division[j]);
    End;
   End;
   st:=Copy(s,1,CRazdelKod);
   L^.Dat.Element[i+1].BazKod:=Copy(s,1+CName+1+CRazdelKod+1,CArtikul-CRazdelKod);
   L^.Dat.Element[i+1].BazKod:=st+L^.Dat.Element[i+1].BazKod;
 End;
{
   SummaL,SummaR,SummaO : String[CIZena];
}

Dispose(TempRewisia,Done);
End;
 L^.Dat.Caption:=CurrentPassword;
 PStaticText(ControlDoc)^.GetText(s);
 DelSpace(S);
 System.Delete(S,Pos(#3,S),1);
 L^.Dat.Document:=s;
 L^.Dat.DateM:=FDate;
 L^.Dat.TimeM:=Times;
 L^.Dat.DateC:=FDate;
 L^.Dat.TimeC:=Times;
 L^.Dat.Amount:=NewTovar^.List^.Count;


 PStaticText(ControlItogoPlus)^.GetText(s);
 DelSpace(S);
 System.Delete(S,Pos(#3,S),1);
 L^.Dat.ItogoPlus:=s;

 PStaticText(ControlItogoMinus)^.GetText(s);
 DelSpace(S);
 System.Delete(S,Pos(#3,S),1);
 L^.Dat.ItogoMinus:=s;

 PStaticText(ControlItogo)^.GetText(s);
 DelSpace(S);
 System.Delete(S,Pos(#3,S),1);
 L^.Dat.Itogo:=s;


 Save:=TestRewisiaInSkladFile(l);

 AddComment(l);

 If SAve Then  Save:=WriteRewisiaToSkladFile(l);

 If Save Then  Save:=LockAndWriteRewisia(l);

 As.EditPosition := L^.Dat.Document;
 As.D := L^.Dat.DateC;


 If Save Then AddProtocol('Ввод акта ревизии N '+L^.Dat.Document+' от '+L^.Dat.DateC+' на склад','','');


 Dispose(l,Done);
 UnLockAllName;

 If SAve Then
  If MessageBox(^M+#3'Печатать акт ревизии N '+As.EditPosition+'?',Nil,mfOkCancel)=cmOk Then PrintRewisia(As);
End;


Procedure DrawPack;
Var s: String[CPack];
    R : TRect;
    i : Byte;
    Minus : Boolean;
Begin
    RewWin^.GetData(Input);
    InPut.Kol[0]:=#0;
    For i:=1 To CDivision Do
    Str(StrToInt(InPut.Division[i])+StrToInt(Input.Kol),Input.Kol);
    DelSpace(Input.Kol);


    Dispose(ControlKol,Done);

    R.Assign(10, 5, 15, 6);
    ControlKol := New(PStaticText, Init(R, #3+Input.Kol));
    RewWin^.Insert(ControlKol);

    If Pos('-',Input.Kol)>0 Then Begin
                                                        System.Delete(Input.Kol,Pos('-',Input.Kol),1);
                                                        Minus:=True;
                                                   End
                                                   Else
                                                   Minus:=False;

    s:=CalcPack(sArtikul,input.kol);
    DelSpace(s);
    If Minus Then s:='-('+s+')';
    Dispose(ControlPack,Done);
    R.Assign(25, 5, 34, 6);
    ControlPack := New(PColoredText, Init(R, #3+s, $3E));
    RewWin^.Insert(ControlPack);
End;


Procedure EditRewisiaComment(As:DocumentEdit);
Var i,C: Word;
    RewisiaFile : RewisiaFileType;
    PrevRewisia : PRewisiaType;
    Event : TEvent;
    SAve : Boolean;
Begin

If Not(TestOpenDate1(As.D)) Then
   Begin
    MessageBox(#3^M+#3'Доступ к данным за '+As.D+' заблокирован!',Nil,mfError+mfCancelButton);
    TekDate:=FDate;
    Exit;
   End;
  C:=IOResult;
  Assign(RewisiaFile,Path.ToRewisia+As.D+'.rwz');
  Reset(RewisiaFile);
  C:=IOResult;
  If C<>0 Then
   Begin
    If MessageBox(^M+#3'Файл ревизии за '+As.D+' не найден'^M+
    #3'Создавать файл ревизии? '+
    +' Код:'+IntToStr(c,3),Nil, mfWarning+mfOkCancel)=cmOk Then
    Begin
     If Not(CreatToDayF(DocRewisia,As.D)) Then Exit;
     Reset(RewisiaFile);
     c:=IOResult;
    End
    Else
    Exit;
   End;
   System.Close(RewisiaFile);

   New(PrevRewisia,Init);

    i:=LockRewisia(As,PrevRewisia);

    If I=3 Then
     Begin
      Beep;
      DinfoMsg('Не могу заблокировать док-т ревизии N '+PrevRewisia^.Dat.Document+' от '+PrevRewisia^.Dat.DateC+
         '. Попробуйте повторить!');
      Dispose(PrevRewisia,Done);
      Application^.ClearEvent(Event);
      Application^.GetEvent(Event);
      Application^.ClearEvent(Event);
      repeat
        Application^.GetEvent(Event);
      until (Event.What <> evNothing) And (Event.Command<>cmMenu);
      NoInfoMsg;
      Application^.ClearEvent(Event);
      Exit;
     End;

    If I<>0 Then
     Begin
      Dispose(PrevRewisia,Done);
      Exit;
     End;

 If AddComment(PrevRewisia) Then
 Begin
 PrevRewisia^.Dat.DateM:=FDate;
 PrevRewisia^.Dat.TimeM:=Times;
 Save:=LockAndWriteRewisiaOutEdit(PrevRewisia);
 If Save Then AddProtocol('Корректировка комментария акта ревизии N '+PrevRewisia^.Dat.Document+' от '+PrevRewisia^.Dat.DateC
 ,'','');
 If Save Then
   If MessageBox(^M+#3'Печатать акт ревизии N '+As.EditPosition+'?',Nil,mfOkCancel)=cmOk Then PrintRewisia(As);
 End;

 Dispose(PrevRewisia,Done);

End;



Procedure TRewWindow.Ini(Var s:String;Regim:Word);
Label 1;
var
  R : TRect;
  c: Word;
  Control : PView;
  SNAlog,WS,SName,SLitr,SKol,SSertif,SAkzis,SInPack: String[CAll];
  Zen : TDateString;
  Kkol : ArtikulStr;
  As : DocumentEdit;
  ClientKod : ArtikulStr;
  St : Allstr;
  SMsg : TMyString;
  l : LongInt;
  logik : Boolean;

Begin
SName:=Copy(S,1,CName);
SArtikul:=Copy(S,1+CName+1,CArtikul);
SLitr:=GetIdField(FLitr,SArtikul);
SNalog:=GetIdField(FNAlog,SArtikul);
DelSpace(SNalog);
SInPack:=GetIdField(FInPack,SArtikul);
Case Regim Of
0:Begin
  Input.Akzis1:=BakGetField(FAkzis,SArtikul,0);
  Input.NSertif:=BakGetField(FSertif,SArtikul,0);
  Input.R_Zena:=BakGetField(FRZena,SArtikul,0);
  Input.O_Zena:=BakGetField(FOZena,SArtikul,0);
  Input.Kol[0]:=#0;
    For c:=1 To CDivision Do
    Begin
    Input.Division[c,0]:=#0;
    DelSpace(Input.Division[c]);
    End;
  End;
1:Begin
  With Input Do
   Begin
    Akzis1:=Copy(s,1+CName+1+CArtikul+1+(CKol+1)+1+(CKol+1)*5+1*5+CZena+1+CZena+1+CNSertif+1,CAkzis);
    NSertif:=Copy(s,1+CName+1+CArtikul+1+(CKol+1)+1+(CKol+1)*5+1*5+CZena+1+CZena+1,CNSertif);
    R_Zena:=Copy(s,1+CName+1+CArtikul+1+(CKol+1)+1+(CKol+1)*5+1*5,CZena);
    O_Zena:=Copy(s,1+CName+1+CArtikul+1+(CKol+1)+1+(CKol+1)*5+1*5+CZena+1,CZena);
    For c:=1 To CDivision Do
    Begin
    Division[c]:=Copy(s,1+CName+1+CArtikul+1+(CKol+1)*c+1*c,CKol+1);
    DelSpace(Division[c]);
    End;
    Kol:=Copy(s,1+CName+1+CArtikul+1,CKol+1);
   End;
  End;
  Else;
  End;
DelSPace(Input.R_Zena);
DelSPace(Input.O_Zena);
DelSPace(Input.Kol);
DelSpaceRight(Input.NSertif);
DelSpaceRight(Input.Akzis1);
ClearFind;

1:

DInfo('Читаю информацию о товаре...');
R.Assign(0, 12, 80, 21);
New(RewWin, Init(R, 'Карточка товара'));
RewWin^.Palette := dpCyanDialog;
RewWin^.Options := RewWin^.Options or ofCenterX;
RewWin^.HelpCtx := $E191;

R.Assign(27, 3, 35, 4);
Control1 := New(PInputLine, Init(R, CKol+1));
RewWin^.Insert(Control1);
  PInputLine(Control1)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','-']));

  R.Assign(24, 3, 27, 4);
  RewWin^.Insert(New(PLabel, Init(R, '~1~:', Control1)));


R.Assign(28, 2, 33, 3);
Control := New(PColoredText, Init(R,BakGetField(FDiv,SArtikul,1), $31));
RewWin^.Insert(Control);

R.Assign(38, 3, 46, 4);
Control2 := New(PInputLine, Init(R, CKol+1));
RewWin^.Insert(Control2);
  PInputLine(Control2)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','-']));

  R.Assign(35, 3, 38, 4);
  RewWin^.Insert(New(PLabel, Init(R, '~2~:', Control2)));

R.Assign(39, 2, 44, 3);
Control := New(PColoredText, Init(R,BakGetField(FDiv,SArtikul,2), $31));
RewWin^.Insert(Control);

R.Assign(49, 3, 57, 4);
Control3 := New(PInputLine, Init(R, CKol+1));
RewWin^.Insert(Control3);
  PInputLine(Control3)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','-']));

  R.Assign(46, 3, 49, 4);
  RewWin^.Insert(New(PLabel, Init(R, '~3~:', Control3)));

R.Assign(50, 2, 55, 3);
Control := New(PColoredText, Init(R,BakGetField(FDiv,SArtikul,3), $31));
RewWin^.Insert(Control);

R.Assign(60, 3, 68, 4);
Control4 := New(PInputLine, Init(R, CKol+1));
RewWin^.Insert(Control4);
  PInputLine(Control4)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','-']));

  R.Assign(57, 3, 60, 4);
  RewWin^.Insert(New(PLabel, Init(R, '~4~:', Control4)));

R.Assign(61, 2, 66, 3);
Control := New(PColoredText, Init(R,BakGetField(FDiv,SArtikul,4), $31));
RewWin^.Insert(Control);

R.Assign(71, 3, 79, 4);
Control5 := New(PInputLine, Init(R, CKol+1));
RewWin^.Insert(Control5);
  PInputLine(Control5)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','-']));

  R.Assign(68, 3, 71, 4);
  RewWin^.Insert(New(PLabel, Init(R, '~5~:', Control5)));

R.Assign(72, 2, 77, 3);
Control := New(PColoredText, Init(R,BakGetField(FDiv,SArtikul,5), $31));
RewWin^.Insert(Control);

R.Assign(45, 5, 55, 6);
Control := New(PInputLine, Init(R, CZena));
Control^.Options := Control^.Options and not(ofSelectable or ofFirstClick);
RewWin^.Insert(Control);

  R.Assign(37, 5, 45, 6);
  RewWin^.Insert(New(PLabel, Init(R, 'Р/Цена:', Control)));

R.Assign(64, 5, 74, 6);
Control := New(PInputLine, Init(R, CZena));
Control^.Options := Control^.Options and not(ofSelectable or ofFirstClick);
RewWin^.Insert(Control);

  R.Assign(56, 5, 64, 6);
  RewWin^.Insert(New(PLabel, Init(R, 'О/Цена:', Control)));

R.Assign(13, 6, 79, 7);
Control := New(PInputLine, Init(R, CNSertif));
RewWin^.Insert(Control);

  R.Assign(1, 6, 13, 7);
  RewWin^.Insert(New(PLabel, Init(R, '~С~ертификат:', Control)));

R.Assign(13, 7, 79, 8);
Control := New(PInputLine, Init(R, CAkzis1));
RewWin^.Insert(Control);

  R.Assign(1, 7, 13, 8);
  RewWin^.Insert(New(PLabel, Init(R, '~П~римечание:', Control)));

R.Assign(2, 3, 24, 4);
Control := New(PStaticText, Init(R, 'Ревизия по отделениям:'));
RewWin^.Insert(Control);

R.Assign(2, 2, 24, 3);
Control := New(PStaticText, Init(R, 'Имеется по отделениям:'));
RewWin^.Insert(Control);

R.Assign(1, 1, 79, 2);
Control := New(PStaticText, Init(R, 'Наименование:'+SName+' Код:'+SArtikul+' Литраж:'+SLitr+' Фас:'+SInPack+
' НП:'+SNAlog));
RewWin^.Insert(Control);

R.Assign(7, 4, 22, 5);
Control := New(PColoredText, Init(R, '┌─── Всего ───┐', $31));
RewWin^.Insert(Control);

R.Assign(3, 5, 10, 6);
Control := New(PColoredText, Init(R, 'Кол-во:', $31));
RewWin^.Insert(Control);

R.Assign(10, 5, 15, 6);
ControlKol := New(PStaticText, Init(R, #3+'0'));
RewWin^.Insert(ControlKol);

R.Assign(16, 5, 25, 6);
Control := New(PColoredText, Init(R, 'Упаковок:', $31));
RewWin^.Insert(Control);

R.Assign(25, 5, 34, 6);
ControlPack := New(PStaticText, Init(R, #3+'0'));
RewWin^.Insert(ControlPack);

RewWin^.SelectNext(False);

RewWin^.SetData(Input);

NoInfo;

DrawPack;

c:=Desktop^.ExecView(RewWin);
If c<>cmCancel Then
 Begin
  RewWin^.GetData(Input);
  Str(StrToReal(Input.R_Zena):CZena:CMantissa,Input.R_Zena);
  DelSpace(Input.R_Zena);
  Str(StrToReal(Input.O_Zena):CZena:CMantissa,Input.O_Zena);
  DelSpace(Input.O_Zena);
  Dispose(Control,Done);
  Dispose(RewWin,Done);
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
    Str(StrToInt(InPut.Division[c])+StrToInt(S),S);
    DelSpace(S);
  If (Abs(StrToInt(s))> CMaxKol) Then
   Begin
     MessageBox('Слишком большое количество товара'^M+
                         'Попробуйте оприходовать его в разные позиции! ',nil, mfError + mfCancelButton);
     GoTo 1;
   End;
   Input.Kol:=S;


  If (StrToInt(BakGetField(FKol,SArtikul,0))+(StrTOInt(Input.Kol))> CMaxKol) Then
   Begin
        MessageBox('Слишком большое количество товара'^M+
                         'Попробуйте оприходовать его в другую позицию! ',nil, mfError + mfCancelButton);
        GoTo 1;
   End;

  If (Input.R_Zena[0]=#0) Or (StrTOReal(Input.R_Zena)>CMaxZena) Then
   Begin
        MessageBox(#3+ErrorRZena,nil, mfError + mfCancelButton);
        GoTo 1;
   End;

  If (Input.O_Zena[0]=#0) Or (StrTOReal(Input.O_Zena)>CMaxZena) Then
   Begin
        MessageBox(#3+ErrorOZena,nil, mfError + mfCancelButton);
        GoTo 1;
   End;

  If (StrToReal(Input.R_Zena)<>StrTOReal(Input.O_Zena)) Then
   Begin
        MessageBox(#3^M+#3+'Розничная цена не равна оптовой !',nil, mfError + mfCancelButton);
        GoTo 1;
   End;
{12345678901234567890123456│12345│123456│123456│123456│123456│123456│123456│12345678│12345678│}
{Наименование               Код   Всего  1отд   2отд   3отд   4отд   5отд   Цена Р   Цена О}

   Logik:=False;
   For c:=1 To CDivision Do
    Begin
        Str(StrToInt(Input.Division[c]):CKol+1,Input.Division[c]);
        If StrToInt(Input.Division[c])<>0 Then Logik:=True;
        Format(Input.Division[c],CKol+1);
    End;

   If Not(Logik) Then
    Begin
        MessageBox(#3+NullKol,nil, mfWarning + mfCancelButton);
    End;

   Format(SInpack,CInPack);
  s:=SName+'│'+SArtikul+'│';
  With Input Do
   Begin
   Format(Kol,CKol+1);

   Str(StrToInt(Kol):CKol+1,Kol);
   Str(StrToReal(R_Zena):CZena:CMantissa,R_Zena);
   Str(StrToReal(O_Zena):CZena:CMantissa,O_Zena);

   Format(R_Zena,CZena);
   Format(O_Zena,CZena);
   Format(NSertif,CNSertif);
   Format(Akzis1,CAkzis1);
   s:=s+Kol+'│';{+'│'+R_Zena+'│'+O_Zena+'│'+Sertifikat+'│'+Akzis+'│';}
   For c:=1 To CDivision Do
    Begin
        {Str(StrToInt(Input.Division[c]):CKol+1,Input.Division[c]);
        Format(Input.Division[c],CKol+1);}
        s:=s+Input.Division[c]+'│';
    End;
   s:=s+R_Zena+'│'+O_Zena+'│'+NSertif+'│'+Akzis1+'│';
   End;
   {DelSpaceRight(Input.Post);
   ChekPost(Input.Post);
   Format(Input.Post,CPost);
   s:=s+Input.Post;}
   If Regim=1 Then
    Begin
        NewTovar^.List^.AtFree(NewTovar^.Focused);
        NewTovar^.SetRange(NewTovar^.List^.Count);
    End;
   NewTovar^.List^.Insert(NewStr(S));
   NewTovar^.SetRange(NewTovar^.List^.Count);
   NewTovar^.FocusItem(LoCation(NewTovar,SArtikul,ProdagaWindow));
 End
 Else
 Begin
  If Regim=0 Then
  Repeat
  until (SetNameUnLock(SArtikul));
  Dispose(Control,Done);
  Dispose(RewWin,Done);
 End;

End;

Destructor TRewWinDow.Done;
Begin
Dispose(ControlKol,Done);
Dispose(ControlPack,Done);
TDialog.Done;
End;


procedure TRewWindow.HandleEvent(var Event: TEvent);
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
Begin
Case Event.What Of
 evCommand :
   Case Event.Command Of
        cmLocalCalc:Calculator;
   Else;
   End;
   Else;
   End;

  If (Event.What=evKeyboard)And((Event.CharCode in ['0','1','2','3','4','5','6','7','8','9','-'])
  Or (Event.KeyCode=kbDel) Or (Event.KeyCode=kbBack)) Then DrawP:=True
  Else DrawP:=False;
  inherited HandleEvent(Event);
  If DrawP Then Begin
                          If (Control1^.State and sfFocused <> 0) Or
                                (Control2^.State and sfFocused <> 0) Or
                                (Control3^.State and sfFocused <> 0) Or
                                (Control4^.State and sfFocused <> 0) Or
                                (Control5^.State and sfFocused <> 0) Then DrawPack;
                         End;

  ClearEvent(Event);
End;



procedure TRewisiaWindow.OpenRewisiaWindow;
Var l : Boolean;
begin
  l:=False;
  ClearFind;
  if Message(Desktop, evBroadcast, cmPrihod, nil) = nil then
  begin
    DInfo('Инициализация ревизии...');
    L:=True;
    RewisiaWindow := New(PRewisiaWindow, Init(L));
    If L Then
    Begin
    Application^.InsertWindow(RewisiaWindow);
    NoInfo;
    End
    Else
     Begin
      TekDAte:=FDate;
      Status:=DocNormal;
      Dispose(RewisiaWindow,Done);
      NoInfo;
     End;
  end
  else
    if PView(RewisiaWindow) <> Desktop^.TopView then RewisiaWindow^.Select;
end;

constructor TRewisiaWindow.Init(Var l : Boolean);
var
  R : TRect;
  Control : PView;
  C : Word;
  DocumentNumer : TDateString;
  RewisiaFile : File Of RewisiaType;
  s: String;
  ws : TDateString;
  i : Byte;
  SName : String[CName];
  SLitr : String[CLitr];
  SPack : String[CInPack];
begin

 R.Assign(0, 0, 80, 23);
PrevS:='Акт ревизии';

inherited Init(R, PrevS);
Options := Options or ofCenterX or ofCenterY;
HelpCtx:=$E011;
L:=False;

If Not(TestOpenDate1(FDate)) Then
   Begin
    MessageBox(#3^M+#3'Доступ к данным за '+FDate+' заблокирован!',Nil,mfError+mfCancelButton);
    TekDate:=FDate;
    Exit;
   End;
  C:=IOResult;
  Assign(RewisiaFile,Path.ToRewisia+TekDate+'.rwz');
  Reset(RewisiaFile);
  C:=IOResult;
  If C<>0 Then
   Begin
    If MessageBox(^M+#3'Файл ревизии за '+FDate+' не найден'^M+
    #3'Создавать файл ревизии? '+
    +' Код:'+IntToStr(c,3),Nil, mfWarning+mfOkCancel)=cmOk Then
    Begin
{     c:=IOResult;
     Reset(RewisiaFile);
     c:=IOResult;
     If C<>0 Then  Rewrite(RewisiaFile);}
     If Not(CreatToDayF(DocRewisia,FDate)) Then Exit;
     Reset(RewisiaFile);
     c:=IOResult;
    End
    Else
    Exit;
   End;
   System.Close(RewisiaFile);
{   DocumentNumer:=IntToStr(FileSize(RewisiaFile)+1,CDocNumer);}
   If Not(UseDocNumer(DocRewisia,FDate,DocumentNumer)) Then Exit;



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
    Razdel^.List^.Insert(NewStr(RazdelElement.Name+'│'+RazdelElement.Kod));
    Razdel^.SetRange(Razdel^.List^.Count);
   End;
 End;
System.Close(RazdelFile);
Razdel^.FocusItem(0);

PrevS:=Razdel^.GEtText(Razdel^.Focused,Razdel^.List^.COunt);

Dispose(Razdel,Done);


R.Assign(9, 1, 34, 2);
ControlRazdel := New(PColoredText, Init(R, #3+PrevS, $1F));
ControlRazdel^.Options := ControlRazdel^.Options or ofSelectable;
Insert(ControlRazdel);


R.Assign(1, 1, 9, 2);
Insert(New(PLabel, Init(R, 'Ра~з~дел:',ControlRazdel)));

R.Assign(38, 3, 39, 20);
Control := New(PScrollBar, Init(R));
Insert(Control);

R.Assign(1, 3, 38, 20);
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

  If BazElement.Employ Then
{Наименование│код│Фас│Литраж│количество│ЦенаР│ЦенаО│}
{  If GetIdEmploy(BazElement.BazKod) Then}
   Begin
    SName:=GetIdField(FName,BazElement.BazKod);
    Format(SName,CName);
    SLitr:=GetIdField(FLitr,BazElement.BazKod);
    Format(SLitr,CLitr);
    Format (BazElement.Input.Kol,CLitr);
    SPack:=GetIdField(FInPack,BazElement.BazKod);
    Format(SPack,CInPack);
    RFormat (BazElement.Input.R_Zena,CZena);
    RFormat (BazElement.Input.O_Zena,CZena);
    Prevs:=SName+'│'+BazElement.BazKod+'│'+SPack;
    Baz^.List^.Insert(NewStr(Prevs));
    Baz^.SetRange(Baz^.List^.Count);
   End;
 End;
System.Close(BazFile);
 End;
Baz^.FocusItem(0);
Baz^.HelpCtx:=$E141;
Insert(Baz);

  R.Assign(1, 2, 38, 3);
  Insert(New(PLabel, Init(R, 'Н~а~именование товара         Код  Фас', Baz)));

R.Assign(79, 2, 80, 20);
Control := New(PScrollBar, Init(R));
Insert(Control);

R.Assign(39, 2, 79, 20);
Newtovar := New(PBox, Init(R, 1, PScrollbar(Control)));
NewTovar^.NewList(New(PTextCollection, Init(1,1)));
(*
If Status=DocEdit Then
 Begin
  c:=1;
  For c:=1 To PrevRewisia^.Dat.Amount Do
   Begin
{12345678901234567890123456│12345│123456│123456│123456│123456│123456│123456│12345678│12345678│+Сертификаты+Примечания+
Производитедь}
{Наименование               Код   Всего  1отд   2отд   3отд   4отд   5отд   Цена Р   Цена О}

    S:=GetIdField(FName,PrevRewisia^.Dat.Element[c].BazKod);
    Format(S,CName);
    s:=s+'│'+PrevRewisia^.Dat.Element[c].BazKod;
    Format(PrevRewisia^.Dat.Element[c].Input.Kol,CKol+1);
    Format(PrevRewisia^.Dat.Element[c].Input.R_Zena,CZena);
    Format(PrevRewisia^.Dat.Element[c].Input.O_Zena,CZena);
    Format(PrevRewisia^.Dat.Element[c].Input.Sertifikat,CSertif);
    Format(PrevRewisia^.Dat.Element[c].Input.Akzis,CAkzis);

    s:=s+'│'+PrevRewisia^.Dat.Element[c].Input.Kol+'│';
    For i:=1 To CDiviSion Do
    Begin
        Format(PrevRewisia^.Dat.Element[c].Input.Division[i],CKol+1);
        s:=s+PrevRewisia^.Dat.Element[c].Input.Division[i]+'│';
    End;
    s:=s+PrevRewisia^.Dat.Element[c].Input.R_Zena+'│'+PrevRewisia^.Dat.Element[c].Input.O_Zena
           +'│'+PrevRewisia^.Dat.Element[c].Input.Sertifikat+'│'+PrevRewisia^.Dat.Element[c].Input.Akzis;
           {'│'+PrevRewisia^.Dat.Element[c].Input.Post;}
    NewTovar^.List^.Insert(NewStr(s));
    NewTovar^.SetRange(NewTovar^.List^.Count);
   End;
 End;
*)
NewTovar^.HelpCtx:=$E150;
NewTovar^.FocusItem(0);
Insert(NewTovar);

  R.Assign(39, 1, 79, 2);
  Insert(New(PLabel, Init(R, 'Проверенн~ы~е товары         Код   Колич', NewTovar)));

R.Assign(2, 0, 8, 1);
Control := New(PColoredText, Init(R, 'Склад:', $74));
Insert(Control);

R.Assign(8, 0, 28, 1);
Control := New(PColoredText, Init(R, #3+GetClientField(FClient,Rek.Kod,1), $7E));
Insert(Control);

R.Assign(49, 0, 60, 1);
Control := New(PColoredText, Init(R, 'Документ N:', $74));
Insert(Control);

R.Assign(60, 0, 63, 1);
ControlDoc := New(PColoredText, Init(R, #3+DocumentNumer, $7E));
Insert(ControlDoc);


R.Assign(65, 0, 70, 1);
Control := New(PColoredText, Init(R, 'Дата:', $74));
Insert(Control);

R.Assign(70, 0, 78, 1);
Control := New(PColoredText, Init(R, #3+FDate, $7E));
Insert(Control);


{R.Assign(66, 20, 74, 21);}
R.Assign(66, 20, 74, 21);
Control := New(PColoredText, Init(R, 'Выбрано:', $74));
Insert(Control);

R.Assign(74, 20, 77, 21);
ControlCurrent := New(PColoredText, Init(R, '0', $4E));
Insert(ControlCurrent);


R.Assign(4, 20, 13, 21);
Control := New(PColoredText, Init(R, 'Упаковок:', $74));
Insert(Control);

R.Assign(13, 20, 22, 21);
ControlPackList := New(PColoredText, Init(R, #3+'', $7E));
Insert(ControlPackList);

R.Assign(23, 20, 32, 21);
Control := New(PColoredText, Init(R, 'Колич,шт:', $74));
Insert(Control);

R.Assign(32, 20, 37, 21);
ControlKolList := New(PColoredText, Init(R, #3+'', $7E));
Insert(ControlKolList);

R.Assign(2, 21, 13, 22);
Control := New(PColoredText, Init(R, 'Р/Цена,руб:', $74));
Insert(Control);

R.Assign(13, 21, 21, 22);
ControlRZenaList := New(PColoredText, Init(R, #3+'', $7E));
Insert(ControlRZenaList);

R.Assign(25, 21, 32, 22);
Control := New(PColoredText, Init(R, 'Литраж:', $74));
Insert(Control);

R.Assign(32, 21, 37, 22);
ControlLitrList := New(PColoredText, Init(R, #3+'', $7E));
Insert(ControlLitrList);

R.Assign(40, 20, 45, 21);
Control := New(PColoredText, Init(R, 'E(+):', $74));
Insert(Control);

R.Assign(45, 20, 60, 21);
ControlItogoPlus := New(PColoredText, Init(R, #3+'', $5E));
Insert(ControlItogoPlus);

R.Assign(40, 21, 45, 22);
Control := New(PColoredText, Init(R, 'E(-):', $74));
Insert(Control);

R.Assign(45, 21, 60, 22);
ControlItogoMinus := New(PColoredText, Init(R, #3+'', $5E));
Insert(ControlItogoMinus);

R.Assign(61, 21, 64, 22);
Control := New(PColoredText, Init(R, 'EE:', $74));
Insert(Control);

R.Assign(64, 21, 79, 22);
ControlItogo := New(PColoredText, Init(R, #3+'', $4E));
Insert(ControlItogo);

R.Assign(7, 22, 35, 23);
Control := New(PColoredText, Init(R, 'Количество по отделениям,шт:', $71));
Insert(Control);

R.Assign(35, 22, 79, 23);
ControlDivisionRewisia := New(PColoredText, Init(R, #3+'', $71));
Insert(ControlDivisionRewisia);

SelectNext(False);
CalcItogo;
AddName;
L:=True;
PrevS[0]:=#0;
PrevCurrent[0]:=#0;
PrevNakl[0]:=#0;
end;




procedure TRewisiaWindow.CalcItogo;
Var R:TRect;
    t,l,k : Real;
    Sl,Sk,So,Sr : Real;
    KolPlus,KolMinus : LongInt;
    Plus,Minus,Itog:Real;
    Division : Array[1..CDivision] Of String[CKol+1];
    SSr,Itogo_Plus,Itogo_Minus,Itogo_:String[CIZena];
    ls : Word;
    Code:Integer;
    j,kol : LongInt;
Begin
SO:=0;
SR:=0;
Minus:=0;
Plus:=0;
For ls:=0 To NewTovar^.List^.Limit Do
Begin
{колич}
    KolPlus:=0;
    KolMinus:=0;



    For j:=1 To CDivision Do
    Begin
        Division[j]:=Copy(NewTovar^.GetText(ls,NewTovar^.List^.Limit),1+CName+1+CArtikul+1+(CKol+1)*j+1*j,CKol+1);
        DelSpace(Division[j]);
        If StrToInt(Division[j])>0 Then KolPlus:=KolPlus+StrToInt(Division[j])
        Else KolMinus:=KolMinus+StrToInt(Division[j]);
    End;

{розничная цена}
SSr:=Copy(NewTovar^.GetText(ls,NewTovar^.List^.Limit),1+CName+1+CArtikul+1+(CKol+1)+1+(CKol+1)*5+1*5,CZena);
DelSpace(sSr);

Plus:=Plus+KolPlus*StrToReal(ssr);
Minus:=Minus+KolMinus*StrToReal(ssr);


End;{for}

Str(Plus:CIZena:CMantissa,Itogo_Plus);
DelSpace(Itogo_Plus);

Str(Minus:CIZena:CMantissa,Itogo_Minus);
DelSpace(Itogo_Minus);

Str(Plus+Minus:CIZena:CMantissa,Itogo_);
DelSpace(Itogo_);

Dispose(ControlItogoPlus,Done);
R.Assign(45, 20, 60, 21);
ControlItogoPlus := New(PColoredText, Init(R,#3+Itogo_Plus,$5E));
Insert(ControlItogoPlus);

Dispose(ControlItogoMinus,Done);
R.Assign(45, 21, 60, 22);
ControlItogoMinus := New(PColoredText, Init(R,#3+Itogo_Minus, $5E));
Insert(ControlItogoMinus);

Dispose(ControlItogo,Done);
R.Assign(64, 21, 79, 22);
ControlItogo := New(PColoredText, Init(R,#3+Itogo_,$4E));
Insert(ControlItogo);
End;



Procedure TRewisiaWindow.AddName;

Var R : TRect;
    KolStr : String[2];

Begin
  Str(NewTovar^.List^.Count:2,KolStr);
  Dispose(ControlCurrent,Done);
  {R.Assign(74, 20, 77, 21);}
  R.Assign(74, 20, 77, 21);
  ControlCurrent := New(PColoredText, Init(R, #3+KolStr, $7E));
  Insert(ControlCurrent);
  Redraw;
End;



procedure TRewisiaWindow.HandleEvent(var Event: TEvent);
Var test : Word;
    s,s1 : String;
    l : Boolean;
  SName : String[CName];
  SLitr : String[CLitr];
  SPack : String[CInPack];
  SDoc : ArtikulStr;
  SDate: TDateString;

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
Begin
                        If s <> PrevS Then
                          Begin
                           DInfo('Читаю список товаров..');
                           PrevS:=S;
                           s:=Copy(s,1+CRazdel+1,CRazdelKod);
                           Baz^.NewList(nil);
                           Baz^.NewList(New(PTextCollection, Init(1,1)));
                           Assign (BazFile,Path.ToSklad+s+'.db');
                  Test:=IOResult;
                           Reset (BazFile);
                  Test:=IOResult;
                  If Test=0 Then
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
                                If BazElement.Employ Then
                                 Begin
    SName:=GetIdField(FName,BazElement.BazKod);
    Format(SName,CName);
    SLitr:=GetIdField(FLitr,BazElement.BazKod);
    Format(SLitr,CLitr);
    Format (BazElement.Input.Kol,CLitr);
    SPack:=GetIdField(FInPack,BazElement.BazKod);
    Format(SPack,CInPack);
    Prevs:=SName+'│'+BazElement.BazKod+'│'+SPack;
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
                            PrevCurrent[0]:=#0;
                            PrevNakl[0]:=#0;
                  End;

                           NoInfo;
                  Baz^.FocusItem(0);
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
Dispose(cl,Done);
NoInfo;
End;

begin
  Case Event.What Of
  evKeyDown :
  Case Event.KeyCode Of
        kbDel: Begin
        If (NewTovar^.State and sfFocused <> 0) And (NewTovar^.List<>Nil)And(NewTovar^.List^.Count>=1) Then
                  Begin
                    If MessageBox(#3^M+#3'Удалить товар из документа?',nil,mfConfirmation+mfOkCancel)=cmOk Then
                        Begin
                s:=NewTovar^.GetText(NewTovar^.Focused,NewTovar^.List^.Count);
                s:=Copy(s,1+CName+1,CArtikul);
                Repeat
                Until (SetNameUnLock(s));
                         NewTovar^.List^.AtFree(NewTovar^.Focused);
                         NewTovar^.SetRange(NewTovar^.List^.Count);
                         If NewTovar^.Focused>0 Then NewTovar^.FocusItem(NewTovar^.Focused);

                If (NewTovar^.Focused>=NewTovar^.List^.Count) and(NewTovar^.Focused>0) Then
                NewTovar^.FocusItem(NewTovar^.Focused-1);

                         CalCItogo;
                         PrevCurrent[0]:=#0;
                         Redraw;
                        End;
                    ClearEvent(Event);
                  End;
                  AddName;
                  Redraw;
                  End;
  kbF5     :Begin
                        PStaticText(ControlDoc)^.GetTExt(sdoc);
               If Pos(#3,sdoc)>0 Then System.Delete(sdoc,1,1);
               SDate:=FDate;

                        PStaticText(ControlItogoPlus)^.GetTExt(s1);
               If Pos(#3,s1)>0 Then System.Delete(s1,1,1);
               DelSpace(s1);
               S:=' Итого приход: '+s1;

                        PStaticText(ControlItogoMinus)^.GetTExt(s1);
               If Pos(#3,s1)>0 Then System.Delete(s1,1,1);
               DelSpace(s1);
               S:=s+'  '+'Итого расход: '+s1;

                        PStaticText(ControlItogo)^.GetTExt(s1);
               If Pos(#3,s1)>0 Then System.Delete(s1,1,1);
               DelSpace(s1);
               S:=s+'  '+'Итого ревизия: '+s1;
                     FullScreen(NewTovar,'Проверенн~ы~е товары         Код   Колич',S,SDoc,SDate,0);
                  End;
  kbCtrLDel: Begin
        If (NewTovar^.State and sfFocused <> 0) And (NewTovar^.List<>Nil)And(NewTovar^.List^.Count>=1) Then
                  Begin
                   If MessageBox(#3^M+#3'Удалить весь товар?',nil,mfConfirmation+mfOkCancel)=cmOk Then
                   Begin
              UnLockAllName;
                    NewTovar^.NewList(nil);
                    NewTovar^.NewList(New(PTextCollection, Init(1,1)));
                    CalCItogo;
                         PrevCurrent[0]:=#0;
                         PrevNakl[0]:=#0;
                        AddName;
                    Redraw;
                   End;
                  End;
                  End;
  kbEnter:    Begin
        If (Baz^.State and sfFocused <> 0) And (Baz^.List<>Nil)And(Baz^.List^.Count>=1) Then
                  Begin
        If (Baz^.State and sfFocused <> 0) And (Baz^.List<>Nil)And(NewTovar^.List^.Count>CMax-1) Then
                    Begin
      MessageBox(#3^M+#3'В документе может быть'^M+
                 #3'не более '+ IntToStr(CMax,2)+' наименований !',Nil,mfError+mfCanCelButton);
               ClearEVent(Event);
               Exit;
                    End;
              s:=Copy(Baz^.GetText(Baz^.Focused,Baz^.List^.Count),1+CName+1,CArtikul);
              If TestElement(S,NewTovar) Then
                        Begin
                if Not(lockselect) then
                          Begin
           	            ClearEvent(Event);
                           Exit;
                          End;
                         s:=Baz^.GetText(Baz^.Focused,Baz^.List^.Count);
                         Rew^.Ini(s,0);
                         PrevCurrent[0]:=#0;
                         PrevNakl[0]:=#0;
                         CalcItogo;
                         AddName;
                         If (Baz^.Focused+1)<Baz^.List^.Count Then
                          Begin
                          Baz^.FocusItem(Baz^.Focused+1);
                          End;
                         Redraw;
                         ClearEvent(Event);
                        End
                    Else MessageBox(#3^M+#3'Товар с кодом '+s+' уже есть'^M+
                    #3'в документе !',Nil,mfError+mfCanCelButton);
                    ClearEVent(Event);
                  End
                  End;
         kbF4,kbEnter: Begin
                  If (NewTovar^.State and sfFocused <> 0) And (NewTovar^.List<>Nil)
               And (NewTovar^.List^.Count>=1)  Then
            Begin
              s:=NewTovar^.GetText(NewTovar^.Focused,NewTovar^.List^.Count);
                    Rew^.Ini(s,1);
                    PrevCurrent[0]:=#0;
                    PrevNakl[0]:=#0;
                    CalcItogo;
                    Redraw;
                    ClearEvent(Event);
                  End;
                    ClearEvent(Event);

                  Redraw;
                  End;
     kbAlt1:UnlockAll;
        kbEsc: Begin
                    ClearFind;
                    Event.What:=evCommand;
                    Event.Command:=cmCancel;
                    PutEvent(Event);
            End;
      Else;
      End;{KeyDown}
  evCommand :
     Case Event.Command Of
     cmRewisia : Begin
                  ClearEvent(Event);
                 End;
        cmOk : Begin
               If ((NewTovar^.List<>Nil)And(NewTovar^.List^.Count>0))Or(Status=DocEdit) Then
             Begin
                PStaticText(ControlDoc)^.GetTExt(sdoc);
               If Pos(#3,sdoc)>0 Then System.Delete(sdoc,1,1);
               SDate:=FDate;

               PStaticText(ControlItogoPlus)^.GetTExt(s1);
               If Pos(#3,s1)>0 Then System.Delete(s1,1,1);
               DelSpace(s1);
               S:=' Итого приход: '+s1;

               PStaticText(ControlItogoMinus)^.GetTExt(s1);
               If Pos(#3,s1)>0 Then System.Delete(s1,1,1);
               DelSpace(s1);
               S:=s+'  '+'Итого расход: '+s1;

               PStaticText(ControlItogo)^.GetTExt(s1);
               If Pos(#3,s1)>0 Then System.Delete(s1,1,1);
               DelSpace(s1);
               S:=s+'  '+'Итого ревизия: '+s1;

               If FullScreen(NewTovar,'Проверенн~ы~е товары         Код   Колич',S,SDoc,SDate,1)
               Then
                 Begin
                   L:=False;
                   SaveToFileRew(L);
                   {L:=True;}
                    If L Then
                     Begin
                       Event.What:=evCommand;
                       Event.Command:=cmClose;
                       PutEvent(Event);
                       ClearEvent(Event);
                       Status:=DocNormal;
                       TekDate := FDate;
                     End; {L}
                 End{Message}
                 Else ClearEvent(Event);
                    End;
              ClearFind;
            End;
 cmRefresh:Begin
            PStaticText(ControlRazdel)^.GetText(S);
            System.Delete(S,1,1);
            PrevS[0]:=#0;
            Refresh(s,PrevS);
               ClearEvent(Event);
           End;
      cmCancel : Begin
               l:=False;
                        s:=#3^M+#3'Желаете отказаться от регистрации акта ревизии?';
               If (NewTovar^.List<>Nil)And(NewTovar^.List^.Count>0) Then
               If MessageBox(s,Nil,mfConFirmation+mfOkCancel)<>cmOk
             Then
               Begin
                         l:=True;
               End;
               If Not(L) Then
                 Begin
                 UnLockAllName;
{                Repeat
                 Until (FreeDocNumer(DocRewisia,TekDate,SDoc));}
                 Event.What:=evCommand;
                 Event.Command:=cmClose;
                 PutEvent(Event);
                 {
                  If Status = DocEdit Then
                    Begin
                     Dispose(PrevRewisia,Done)
                    End;
                 }
                 Status:=DocNormal;
                 TekDate := FDate;
                         End;
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
     PrevCurrent[0]:=#0;
     PrevNakl[0]:=#0;
     Refresh(s,PrevS);
     ClearEvent(Event);

  End
 End;
         Else;
         End;{evCommand}
         Else;
         End;{*Case*}
  if (Event.What = evBroadcast) and
    (Event.Command = cmRewisia) then ClearEvent(Event);

  if (Event.What = evBroadcast) and
         (Event.Command = cmQuit) then ClearEvent(Event);

 If (PView(Rz)<>Desktop^.TopView)And(ControlRazdel^.State and sfFocused <> 0)
 And (Event.Command<>cmSelectRazdel) And (Event.What <> EvKeyDown)Then
                  Begin
                   Event.What:=EvCommand;
                   Event.Command:=cmSelectRazdel;
                   PutEvent(Event);
                   ClearEvent(Event);
                  End;


  inherited HandleEvent(Event);

  If (Desktop^.Current=PView(RewisiaWindow)) And (Event.What <> EvKeyDown) Then
                   Begin
                    FreshBazHint;
                    FreshAktHint;
                   ENd;




end;



End.


