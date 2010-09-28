{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}

{$I Compile.INC}

Unit ReestrZ;

Interface


Uses Dialogs,Drivers,{Glob,}Access,MyCalc,ServStr,Utils,CorMrk,Glob;

Type
  PReestrZWindow = ^TReestrZWindow;
  TReestrZWindow = object(TDialog)
    ViewMrk: PFullScreenMrk;
    constructor Init(Var l: Boolean);
    procedure OpenReestrZWindow;
    procedure FullPreview;
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure DrawCurrent;
    procedure SortScreenList(Logik:Boolean);
    procedure NetUnLock;
    Procedure FormReport(Const p:PBox);
    Procedure FormReportRegion(Const p:PBox);
    procedure Refresh;
  end;


Implementation


uses DBEngine,Objects, Views, MsgBox,{Vision,Calc,}Dos,Vision4,TpDate,
     App, ColorTxt,Serv,{InpLong,{Validate,}Tools,Printers,Mail,Prise,Utils3,
     ComboBox,NetDbEng,Net,Protect,Utils1,Vision8,Validate;

var
 NoScreenList,DocList : PBox;
 ControlActiv,ControlAgent,
 ControlEdit,ControlSort,ControlDirection,ControlVidDoc,ControlAllDoc,ControlAllSumma,
 ControlAllSkid,ControlAllTara,ControlAllClient,ControlSf,
 ControlSertifFiltr,ControlAuto,ControlStatus,
 ControlPeriod,ControlTimeC,
 ControlFiltr,ControlModifyDate,ControlRefreshTime,ControlCombo: PView;
 PrevCur : String;
 DocReestrWindow:PReestrZWindow;
 DocDate : TDateString;
 Izmen,Direction ,Sorting : Word;
 StartTime:LongInt;
 RefreshTime:LongInt;
 ActivMas:Maska2;
 M3:Maska3;
 sertif2:Maska2;
 StartDate,StopDate:TDAteString;

 FiltrDoc : MAska9;
 FiltrStatus : MAska3;
 Auto : Word;
 DateTrans : TDateString;
 Sertifword,Activ,FiltrSf,Filtr,FiltrR : Word;
 RegimExt:Word;



Function Setup:Boolean;

Label 1;

Type MyType=Record
    Docs : Word;
    Operation : Word;
    ZakazStatus : Word;
    Tovar: Word;
    Akt  : Word;
    Modify: Word;
    Trans : TDAteString;
    Ext: Word;
  end;

var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  VVV : MyType;
  c : Word;
  L : LongInt;
  TestD : TDateString;

begin
Setup:=FAlse;

With VVV Do
 Begin
Modify:=Izmen;
Tovar:=SertifWord;
Akt:=Activ;

Convert9(FiltrDoc);
BitToWord9(FiltrDoc,c);
Docs:=c;

Convert3(FiltrStatus);
BitToWord3(FiltrStatus,c);
ZakazStatus:=c;

Convert3(M3);
BitToWord3(M3,Filtr);
Operation:=Filtr;
Ext := RegimExt;
Trans:=DateTrans;
End;

1:
R.Assign(4, 9, 76, 20);
New(Dlg, Init(R, '��ࠬ���� ॥��� �������'));
Dlg^.Options := Dlg^.Options or ofCenterX;
Dlg^.HelpCtx:=$E002;

R.Assign(1, 2, 34, 5);
Control := New(PCheckboxes, Init(R,
  NewSItem('����~�~',
  NewSItem('���.�~�~�',
  NewSItem('��~�~.���',
  NewSItem('�~�~',
  NewSItem('���',
  NewSItem('�*',
  NewSItem('���',
  NewSItem('�',
  NewSItem('~�~���', Nil)))))))))));
Dlg^.Insert(Control);

  R.Assign(1, 1, 16, 2);
  Dlg^.Insert(New(PLabel, Init(R, '��� ���㬥��:', Control)));

R.Assign(35, 2, 50, 5);
Control := New(PCheckboxes, Init(R, 
  NewSItem('�~�~����',
  NewSItem('~�~����',
  NewSItem('~�~����', Nil)))));
Dlg^.Insert(Control);

  R.Assign(35, 1, 49, 2);
  Dlg^.Insert(New(PLabel, Init(R, '��� ��ॠ権:', Control)));

R.Assign(51, 2, 71, 5);
Control := New(PCheckboxes, Init(R,
  NewSItem('�� ��ଫ����',
  NewSItem('��~�~������',
  NewSItem('~�~�㫨஢����', Nil)))));
Dlg^.Insert(Control);

  R.Assign(51, 1, 66, 2);
  Dlg^.Insert(New(PLabel, Init(R, '����� ������:', Control)));

R.Assign(1, 6, 34, 8);
Control := New(PCheckboxes, Init(R,
  NewSItem('~�~����',
  NewSItem('���஢���⥫�� ���㬥��~�~', Nil))));
Dlg^.Insert(Control);

  R.Assign(1, 5, 15, 6);
  Dlg^.Insert(New(PLabel, Init(R, '��� ���㧪�:', Control)));

R.Assign(35, 6, 50, 8);
Control := New(PCheckboxes, Init(R,
  NewSItem('~�~��ᨢ��',
  NewSItem('��⨢~�~�', Nil))));
Dlg^.Insert(Control);

  R.Assign(34, 5, 44, 6);
  Dlg^.Insert(New(PLabel, Init(R, '"���~�~��":', Control)));

R.Assign(51, 6, 71, 7);
If StrToInt(CurrentPassword)=0 Then
Control := New(PCheckboxes, Init(R,
  NewSItem('��~�~������', Nil)))
Else
 Begin
Control := New(PCheckboxes, Init(R,
  NewSItem('??????????', Nil)));
  Control^.Options := Control^.Options and not ofSelectable;

 End;
Dlg^.Insert(Control);

  R.Assign(51, 5, 66, 6);
  Dlg^.Insert(New(PLabel, Init(R, '�������⥫쭮:', Control)));


R.Assign(24, 9, 34, 10);
Control := New(PInputLine, Init(R, CDAte));
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PPXPictureValidator, Init(DateFiltr, True));

  R.Assign(9, 9, 24, 10);
  Dlg^.Insert(New(PLabel, Init(R, '�ப ����~�~��:', Control)));


R.Assign(51, 8, 71, 9);
Control := New(PCheckboxes, Init(R,
  NewSItem('��樧�', Nil)));
Dlg^.Insert(Control);

  R.Assign(51, 7, 63, 8);
  Dlg^.Insert(New(PLabel, Init(R, '��� ����:', Control)));

Dlg^.SelectNext(False);

Dlg^.SetData(VVV);

c:=Desktop^.ExecView(Dlg);
If c<>cmCancel Then
Begin
 Setup:=True;
 Dlg^.GetData(VVV);

 TestD:=VVV.Trans;
 If TestD[0]<>#0 Then
  Begin
   If Not TestDate(TestD,l) Then
    Begin
     Dispose(Control,Done);
     Dispose(Dlg,Done);
     Goto 1;
    End
    Else
    DateTrans:=TestD;
  End
  Else
    DateTrans:=TestD;

With VVV Do
 Begin
Izmen:=Modify;
Activ:=Akt;
SertifWord:=Tovar;
RegimExt:=Ext;


WordToBit9(Docs,FiltrDoc);
{Convert9(FiltrDoc);}


WordToBit3(ZakazStatus,FiltrStatus);
{Convert3();}


WordToBit3(Operation,M3);
{Convert3(M3);}

 End;

End;

Convert3(FiltrStatus);
Convert3(M3);
Convert9(FiltrDoc);
Dispose(Control,Done);
Dispose(Dlg,Done);
end;





procedure TReestrZWindow.DrawCurrent;
VAr S,s1 : String;
    R : TRect;
    TempS : AllStr;
Begin

If (DocList^.List<>Nil)And(DocList^.List^.Count>=1) Then
  Begin

   Dispose(ControlModifyDate,Done);
   s:=Copy(DocList^.GetText(DocList^.Focused,DocList^.List^.Count),1+CClient+1
           +(CDocNumer+1)+1+CDate+1+CDate+1+CIZenaK+1+CIZenaK+1+CKto+1+(1)+1+(1)+1+(1)+1+(1)+1+CDate+1,CDate+1+CDAte);
   s[9]:='(';
   s:=s+')';
   R.Assign(8, 21, 27, 22);
   ControlModifyDate := New(PColoredText, Init(R, #3+s, $7E));
   Insert(ControlModifyDate);


   s:=Copy(DocList^.GetText(DocList^.Focused,DocList^.List^.Count),1+CClient+1
           +(CDocNumer+1)+1+CDate+1+CDate+1+CIZenaK+1+CIZenaK+1+CKto+1+(1)+1,COne);

     CAse StrToInt(s) Of
     0:s:='���᮪';
     1:s:='���.祪*';
     2:s:='���.���.*';
        3:s:='��*';
        4:s:='�� �';
        5:s:='�����*';
        6:s:='����� ��*';
        7:s:='�����';
        8:s:='����� ���';
        Else s:='???';
        End;

        Dispose(ControlVidDoc,Done);
        R.Assign(8, 20, 17, 21);
        ControlVidDoc := New(PColoredText, Init(R, #3+s, $7E));
        Insert(ControlVidDoc);
{                                                                   ���  ��  TimeC    DateM    TimeM
AgentDocReal DocDate}
{12345678901234567890�12345�12345678�12345678�1234567890�1234567890�123456789012�1�1�1�1�12345678�12345678�12345678�
1234�1234�12345678}

   s:=Copy(DocList^.GetText(DocList^.Focused,DocList^.List^.Count),1+CClient+1
           +(CDocNumer+1)+1+CDate+1+CDate+1+CIZenaK+1+CIZenaK+1+CKto+1+(1)+1+(1)+1+(1)+1+(1)+1+CDate+1+
                 CDate+1+CDAte+1,CClient+1+CClientKod);


   Dispose(ControlAgent,Done);
   DelSpaceRight(S);
   Format(TempS,CClient);
   R.Assign(28, 20, 55, 21);
   ControlAgent := New(PColoredText, Init(R, s, $7E));
   Insert(ControlAgent);


   s:=Copy(DocList^.GetText(DocList^.Focused,DocList^.List^.Count),1+CClient+1
           +(CDocNumer+1)+1+CDate+1+CDate+1+CIZenaK+1+CIZenaK+1+CKto+1+(1)+1+(1)+1+(1)+1+(1)+1,CDate);
   Dispose(ControlTimeC,Done);
   R.Assign(68, 20, 76, 21);
   ControlTimeC := New(PColoredText, Init(R, #3+s, $7E));
   Insert(ControlTimeC);

   s:=Copy(DocList^.GetText(DocList^.Focused,DocList^.List^.Count),1+CClient+1
           +(CDocNumer+1)+1+CDate+1+CDate+1+CIZenaK+1+CIZenaK+1+CKto+1+(1)+1+(1)+1,COne);

{                                                                               ���  ��  TimeC
DateM    TimeM   AgentDocReal DocDate}
{12345678901234567890�12345�12345678�12345678�1234567890�1234567890�123456789012�1�1�1�1�12345678�
12345678�12345678�1234�1234�12345678}
{                                                                                 ���}

   Case StrToInt(s) Of
   0:s:='�� ��ଫ��';
   1:Begin
     s1:=Copy(DocList^.GetText(DocList^.Focused,DocList^.List^.Count),1+CClient+1
           +(CDocNumer+1)+1+CDate+1+CDate+1+CIZenaK+1+CIZenaK+1+CKto+1+(1)+1+(1)+1+(1)+1+(1)+1+CDate+1+CDate+1+CDAte+1+
                 CClient+1+CClientKod+1,CDocNumer);
     DelSpace(s1);
     DelZerro(s1);
     s:='��ଫ�� N '+s1+' �� ';

     s1:=Copy(DocList^.GetText(DocList^.Focused,DocList^.List^.Count),1+CClient+1
           +(CDocNumer+1)+1+CDate+1+CDate+1+CIZenaK+1+CIZenaK+1+CKto+1+(1)+1+(1)+1+(1)+1+(1)+1+CDate+1+CDate+1+CDAte+1+
                 CClient+1++CClientKod+1+CDocNumer+1,CDAte);
     DelSpace(s1);
     s:=s+s1;
{                                                                               ���  ��  TimeC
DateM    TimeM   AgentDocReal DocDate}
{12345678901234567890�12345�12345678�12345678�1234567890�1234567890�123456789012�1�1�1�1�12345678�
12345678�12345678�1234�1234�12345678}
{                                                                                 ���}
     End;
   2:s:='��㫨஢��';
   Else s:='???';
   End;

   Dispose(ControlStatus,Done);
   R.Assign(36, 21, 67, 22);
   ControlStatus := New(PColoredText, Init(R, #3+s, $5E));
   Insert(ControlStatus);


  End
  Else
   Begin
    If PStaticText(ControlModifyDate)^.Text^<>#3'???' Then
    Begin
    Dispose(ControlModifyDate,Done);
    R.Assign(8, 21, 27, 22);
    ControlModifyDate := New(PColoredText, Init(R, #3+'???', $7E));
    Insert(ControlModifyDate);


    Dispose(ControlVidDoc,Done);
    R.Assign(8, 20, 17, 21);
    ControlVidDoc := New(PColoredText, Init(R, #3+'???', $7E));
    Insert(ControlVidDoc);

    Dispose(ControlAgent,Done);
    R.Assign(28, 20, 55, 21);
    ControlAgent := New(PColoredText, Init(R, #3'???', $7E));
    Insert(ControlAgent);

    Dispose(ControlTimeC,Done);
    R.Assign(68, 20, 76, 21);
    ControlTimeC := New(PColoredText, Init(R, #3+'???', $7E));
    Insert(ControlTimeC);

    Dispose(ControlStatus,Done);
    R.Assign(36, 21, 67, 22);
    ControlStatus := New(PColoredText, Init(R, #3+'???', $5E));
    Insert(ControlStatus);

    End;
   End;

End;


procedure TReestrZWindow.OpenReestrZWindow;
Var l : Boolean;
begin
  if Message(Desktop, evBroadcast, cmReestrZakaz, nil) = nil then
  begin
    L:=True;
    StartDate:=DateToDateString(DateMask,DAteStringToDate(DateMask,FDAte)-3);
    StopDate:=FDate;
    DInfo('���樠������ ॥��� �������...');
    DocReestrWindow := New(PReestrZWindow, Init(L));
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



Procedure TReestrZWindow.SortScreenList(Logik:Boolean);
Var i,j : Word;
    ws,ws1 : String;
    Doc : ArtikulStr;
         TempBox : PBox;
    R : TRect;
    LongDate : TDateString;
Begin
Dispose(ControlPeriod,Done);

R.Assign(6, 0, 6+Length('������ ������� �� ��ਮ� � '+StartDate+' �� '+StopDate+' (���⠢��: ????????)')+2, 1);

If DateTrans[0]=#0 Then
ControlPeriod := New(PColoredText, Init(R, #3+'������ ������� �� ��ਮ� � '+StartDate+' �� '+StopDate+
' (���⠢��: ????????)', $4F))
Else
ControlPeriod := New(PColoredText, Init(R, #3+'������ ������� �� ��ਮ� � '+StartDate+' �� '+StopDate+
' (���⠢��: '+DateTrans+')', $4F));


ControlPeriod^.Options := ControlPeriod^.Options or ofCenterX;
Insert(ControlPeriod);

{
R.Assign(6, 0, 6+Length('������ ������� � '+StartDate+' �� '+StopDate)+2, 1);
ControlPeriod := New(PColoredText, Init(R, #3+'������ ������� � '+StartDAte+' �� '+StopDAte, $4F));
ControlPeriod^.Options := ControlPeriod^.Options or ofCenterX;
Insert(ControlPeriod);
}
DInfoMsg('������� ���㬥���...',False);

if (DocList^.List^.Count>0) And Not(Logik) Then
  Doc:=Copy(DocList^.GEtText(DocList^.Focused,DocList^.List^.Count),
      1+CClient+1,CArtikul)
Else Doc[0]:=#0;

R.Assign(0,0,0,0);
TempBox := New(PBox, Init(R, 1, Nil));
TempBox^.NewList(New(PTextCollection, Init(0,1)));

DocList^.NewList(Nil);
DocList^.NewList(New(PMyCollection, Init(0,1)));

If Direction=1 Then
DistanationSorting:=False
Else
DistanationSorting:=True;

If NoScreenList^.List^.Count>0 Then
Begin
{�ନ�㥬 �����஢���� ᯨ᮪}
For j:=0 to NoScreenList^.List^.Count-1 Do
Begin
 ws:=NoScreenList^.GEtText(j,NoScreenList^.List^.Count);

LongDate:=Copy(ws,1+CClient+1+(CDocNumer+1)+1,CDate);

LongDate:=IntToStr(DateStringToDate(DateMask,LongDate),CDAte);

RFormat(LongDate,CDAte);


Case Sorting Of
{������}
0:Begin
   System.Insert(LongDate,ws,1+CClient+1);
  End;
{����� ���㬥��}
1:Begin
   ws1:=Copy(ws,1+CClient+1,CDocNumer+1);
   System.Delete(ws,1+CClient+1,(CDocNumer+1)+1);
   ws:=LongDate+ws1+' '+ws;
  End;
{�㬬� ���㧪�}
2:Begin
   ws1:=Copy(ws,1+CClient+1+(CDocNumer+1)+1+CDate+1+CDate+1,CIZenaK);
   RFormatZerro(ws1,CIZenaK);
   {System.Delete(ws,1+CClient+1+CDocNumer+1+CDate+1,CIZena+1);}
   ws:=ws1+' '+ws;
  End;
{�㬬� ᪨���}
3:Begin
   ws1:=Copy(ws,1+CClient+1+(CDocNumer+1)+1+CDAte+1+CDate+1+CIZenaK+1,CIZenaK);
   RFormatZerro(ws1,CIZenaK);
   {System.Delete(ws,1+CClient+1+CDocNumer+1+CDAte+1+CIZena+1,CIZena+1);}
   ws:=ws1+' '+ws;
  End;
Else;
End;{CAse}
  TempBox^.List^.Insert(NewStr(ws));
  TempBox^.SetRange(TempBox^.List^.Count);
End;


{�ଠ��㥬 ��ନ஢��� ᯨ᮪ ��� �࠭��� ���}
If TempBox^.List^.Count>0 Then
Begin
For j:=0 to TempBox^.List^.Count-1 Do
Begin
  ws:=TempBox^.GEtText(j,TempBox^.List^.Count);

Case Sorting Of
{������}
0:Begin
   System.Delete(ws,1+CClient+1,CDate);
   ws:=ws;
  End;
{N ���㬥��}
1:Begin
   System.Delete(ws,1,CDate);
   ws1:=Copy(ws,1,CDocNumer+1);
   System.Delete(ws,1,(CDocNumer+1)+1);
   System.Insert(ws1+'�',ws,1+CClient+1);
  End;
{�㬬� ���㧪�}
2:Begin
   ws1:=Copy(ws,1,CIZenaK);
   System.Delete(ws,1,CIZenaK+1);
   {System.Insert(ws1+'�',ws,1+CClient+1+CDocNumer+1+CDate+1);}
  End;
{�㬬� ᪨���}
3:Begin
   ws1:=Copy(ws,1,CIZenaK);
   System.Delete(ws,1,CIZenaK+1);
   {System.Insert(ws1+'�',ws,1+CClient+1+CDocNumer+1+CDAte+1+CIZena+1);}
  End;
Else;
End;{CAse}

  DocList^.List^.Insert(NewStr(ws));
  DocList^.SetRange(DocList^.List^.Count);
End;
End;
End;{If TempCalcList^.List^.Count>0 Then}


Dispose(TempBox,Done);

NoInfoMsg;

{If Doc[0]=#0 Then}
DocList^.FocusItem(0);
{
Else
DocList^.FocusItem(Location(DocList,Doc,False));}

DocList^.HelpCtx:=$F256;

DistanationSorting:=True;
PrevCur[0]:=#0;

End;



Function FindAkzis(N:ArtikulStr):Boolean;
Var E : PZakazType;
    c : Word;
Begin
FindAkzis:=False;
New(E,Init);

If Not GetZakaz(N,E) Then
 Begin
  Dispose(E,Done);
  Exit;
 End;

For c:=1 To E^.Dat.Amount Do
 Begin
  If StrToReal(BakGetField(FAkzisSbor,E^.Dat.MarketElement[c].BazKod,0))>0.009 Then
   Begin
    FindAkzis:=True;
    Break;
   End;
 End;

 Dispose(E,Done);

End;



Procedure TReestrZWindow.Refresh;
Var   Zf : File;
         s: String;
         ws : AllStr;
         AllDoc,AllClient,AllSkid,AllTara,AllSumma : String[CIZena];
         E : PBufHeaderZakazType;
         FPos:Byte;
         SAgent,SVersia,TempArtikul,FS : AllStr;
         Sh,c : Word;
      R : TRect;
      DocNum,DoDate : TDateString;
      cc , Count : Word;
      l,lStart,lStop : LongInt;
      CurStr : TDateString;
      InfoStr : String;
      Txt : Text;
      i : Word;
      Start : LongInt;
      wspom,wsSumma,wsSertifSumma,wsSkidka,wsSertifSkidka : AllStr;
      TempList : PBox;
      TestOtgruska : Boolean;
      StartRashet : Boolean;

Procedure LoadClientFromMemory;
Var c,ch: LongInt;
    clf : File;
  s : String[CSertif];
  CLE : PBufKurzClientType;
  Count : Word;
  St1 : ArtikulStr;
Begin
For ch:=0 To 2 Do
Begin

    Case ch Of
     0:Assign (ClF,Path^.Dat.ToClientBaseIndex+'Client.idx');
     1:Assign (ClF,Path^.Dat.ToClientBaseIndex+'Sklad.idx');
     2:Assign (ClF,Path^.Dat.ToClientBaseIndex+'Barter.idx');
     Else;
     End;{CAse}

c:=IOResult;
Reset (ClF,SizeOf(KurzClientType));
c:=IOResult;
If c=0 Then
Begin
{AInfo('���� ᯨ᪨...');}
While Not(Eof(ClF)) Do
 Begin
    New(CLE,Init);
    ReadBufKurzClient(Clf,CLE,Count);
  For c:=1 To Count Do
  Begin
  If ClE^.Point.Dat[c].Employ Then
   Begin
    Format (ClE^.Point.Dat[c].Name,CClient);
    St1:=IntToStr(ClE^.Point.Dat[c].Kod,CClientKod);
    RFormatZerro(St1,CClientKod);
    TempList^.List^.Insert(NewStr(ClE^.Point.Dat[c].Name+'�'+IntToStr(ch,COne)+{ClE^.Point.Dat[c].Kod}st1));
    TempList^.SetRange(TempList^.List^.Count);
   End;{Employ}
  End;{For}
     Dispose(CLE,Done);
 End;{Eof}
System.Close(ClF);
End;{IO=0}
End;{For ch}

End;{LoadClientFromMemory}


Function GetClientFromMemory(S:ArtikulStr;C:Word):AllStr;
Var ls : Word;
    k  : Byte;
    st : String[CALL];

Begin
GetClientFromMemory:='!!!������ ������!!! ';
RFormatZerro(s,CClientKod);
s:=IntToStr(c,COne)+s;
For ls :=0 To TempList^.List^.Count Do
Begin
St:=TempList^.GetText(ls,TempList^.List^.Count);
k:=Pos('�',St);
ST:=Copy(St,K+1,CArtikul);
If St=S Then
   Begin
    GetClientFromMemory:=Copy(TempList^.GetText(ls,TempList^.List^.Count),1,CClient);
    Break;
   End;
End;
End;{GetClient}





Begin
LStart:=DateStringToDate(DateMask,StartDate);
LStop :=DateStringToDate(DateMask,StopDate);

NoScreenList^.NewList(Nil);
NoScreenList^.NewList(New(PTextCollection, Init(1,1)));

AllDoc[0]:=#0;
AllSkid[0]:=#0;
AllSumma[0]:=#0;
AllClient[0]:=#0;
AllTara[0]:=#0;

{ControlActiv^.GetData(Activ);}
WordToBit2(Activ,ActivMas);
Convert2(ActivMas);

{ControlSertifFiltr^.GetData(sertif2);}
WordToBit2(sertifword,sertif2);
Convert2(sertif2);


Assign(ZF,Path^.Dat.ToMarketIndex+'Zakaz.idx');
i:=IOResult;
Reset(ZF,SizeOf(HeaderZakazType));
i:=IOResult;
If i<>0 Then
 Begin
  MessageBox(^M+#3+'�訡�� ������ 䠩�� '+Path^.Dat.ToMarketIndex+'Zakaz.idx',Nil,mfError+
  mfCancelButton);
  Exit;
 End;

{                                                                           ��म��� TimeC    DateM    TimeM
   AgentDocReal DocDate}
{12345678901234567890�12345�12345678�12345678�1234567890�1234567890�123456789012�1�1�1�12345678�12345678�12345678�
1234�1234�12345678}

Start:=FileSize(ZF);

R.Assign(0,0,0,0);
TempList := New(PBox, Init(R, 1, Nil));
TempList^.NewList(New(PTextCollection, Init(1,1)));
TempList^.FocusItem(0);

DInfoMsg('���� ���� �����⮢ ...',False);
LoadClientFromMemory;
NoInfoMsg;



While Not(Eof(ZF)) Do
 Begin
  DInfoMsgShkala('��ᬠ�ਢ�� ॥��� ������� ...',0,Start,FilePos(ZF));
  New(E,Init);
  Count:=0;
  ReadBufHeaderZakaz(Zf,E,Count);

For cc:=1 To Count Do
Begin
{  If (StrToInt(E^.Point.Dat[cc].SkladKod)=StrToInt(Rek.Kod))Then}

  TestOtgruska:=False;
  If DateTrans[0]<>#0 Then
   Begin
    If (E^.Point.Dat[cc].DateC+E^.Point.Dat[cc].EndDate)=DateStringToDate(DateMask,DateTrans) Then
    TestOtgruska:=True;
   End
  Else TestOtgruska:=True;



If TestOtgruska Then
Begin

  If (E^.Point.Dat[cc].DateC>=LStart)
  And (E^.Point.Dat[cc].DateC<=LStop) Then
   Begin
   If FiltrStatus[E^.Point.Dat[cc].Oformlenie+1]=1 Then
   If FiltrDoc[E^.Point.Dat[cc].DocSelector+1]=1 Then
   If M3[E^.Point.Dat[cc].OperatorSelector+1]=1 Then
        Begin
  If ((ActivMas[1]=1) And (E^.Point.Dat[cc].AgentKod=0)) Or
     ((ActivMas[2]=1) And (E^.Point.Dat[cc].AgentKod<>0)) Then
      Begin
       If (Izmen=0) Or ((Izmen=1)And(E^.Point.Dat[cc].TimeC<>E^.Point.Dat[cc].TimeM)) Then{䨫��� ���������}
        Begin

StartRashet:=True;
If RegimExt=1 Then StartRashet:=FindAkzis(IntToStr(E^.Point.Dat[cc].Document,CArtikul));

If StartRashet Then
Begin
         Str(StrToInt(AllDoc)+1:CArtikul,AllDoc);
         DelSpace(AllDoc);
         {s[0]:=#0;}
         s:=GetClientFromMemory(IntToStr(E^.Point.Dat[cc].ClientKod,CClientKod),E^.Point.Dat[cc].OperatorSelector);
         Format(S,CClient);
         s:=s+'�';
         DocNum:=IntToStr(E^.Point.Dat[cc].Document,CDocNumer);
         RFormatZerro(DocNum,CDocNumer+1);
         DoDate:=DAteToDateString(DAteMask,
         E^.Point.DAt[cc].DateC+E^.Point.Dat[cc].EndDate);
         Format(DoDate,CDAte);
         s:=s+DocNum+'�'+DAteToDateString(DAteMask,E^.Point.Dat[cc].DateC)+'�'+DoDate;

         MyStr(E^.Point.Dat[cc].SummaZ,CIZena,CMAntissa,wsSumma);

         MyStr(E^.Point.Dat[cc].SertifSummaZ,CIZena,CMAntissa,wsSertifSumma);

         If Sertif2[1]=1 Then
         MyStr(StrToReal(AllSumma)+E^.Point.Dat[cc].SummaZ,CIZena,CMantissa,AllSumma);
         If Sertif2[2]=1 Then
         MyStr(StrToReal(AllSumma)+E^.Point.Dat[cc].SertifSummaZ,CIZena,CMantissa,AllSumma);

         DelSpace(AllSumma);

         If Sertif2[1]=1 Then
           MyStr(StrToReal(AllClient)+E^.Point.Dat[cc].SummaZ+E^.Point.Dat[cc].Skidka
          ,CIZena,CMantissa,AllClient);
         If Sertif2[2]=1 Then
                 MyStr(StrToReal(AllClient)+E^.Point.Dat[cc].SertifSummaZ+E^.Point.Dat[cc].SertifSkidka
          ,CIZena,CMantissa,AllClient);
           DelSpace(AllClient);

         If Sertif2[1]=1 Then
           E^.Point.Dat[cc].SummaZ:=E^.Point.Dat[cc].SummaZ+E^.Point.Dat[cc].Skidka
         Else E^.Point.Dat[cc].SummaZ:=0;

         If Sertif2[2]=1 Then
           E^.Point.Dat[cc].SummaZ:=E^.Point.Dat[cc].SummaZ+E^.Point.Dat[cc].SertifSummaZ+
                 E^.Point.Dat[cc].SertifSkidka;

         MyStr(E^.Point.Dat[cc].SummaZ,CIZenaK,CMAntissa,wsSumma);

         s:=s+'�'+wsSumma+'�';


         If Sertif2[1]=1 Then
         E^.Point.Dat[cc].Skidka:=E^.Point.Dat[cc].Skidka
         Else E^.Point.Dat[cc].Skidka:=0;


         If Sertif2[2]=1 Then
         E^.Point.Dat[cc].Skidka:=E^.Point.Dat[cc].Skidka+E^.Point.Dat[cc].SertifSkidka;


         MyStr(StrToReal(AllSkid)+E^.Point.Dat[cc].Skidka,CIZena,CMantissa,AllSkid);
         DelSpace(AllSkid);

         MyStr(E^.Point.Dat[cc].Skidka,CIZenaK,CMAntissa,wsSkidka);

         s:=s+wsSkidka+'�';

{                                            ��म��� TimeC    DateM    TimeM   AgentDocReal DocDate}
{12345678901234567890�12345�12345678�12345678�1234567890�1234567890�123456789012�1�1�1�1�12345678�12345678�
12345678�1234�1234�12345678}

         ws:=GetOperatorName(IntToStr(E^.Point.Dat[cc].Caption,CMantissa));
            Format(Ws,CKto);
         s:=s+ws+'�';

         Str(E^.Point.Dat[cc].OperatorSelector:1,ws);
         s:=s+ws+'�';
         Str(E^.Point.Dat[cc].DocSelector:1,ws);
         s:=s+ws+'�';
         Str(E^.Point.Dat[cc].Oformlenie:1,ws);
         s:=s+ws+'�';
            s:=s+InttoStr(E^.Point.Dat[cc].Versia,CMantissa)+'�';
         s:=s+TimeToTimeString('hh:mm:ss',E^.Point.Dat[cc].TimeC)+'�';
         s:=s+DateToDateString(DateMask,E^.Point.Dat[cc].DateM)+'�'+
            TimeToTimeString('hh:mm:ss',E^.Point.Dat[cc].TimeM)+'�';

         SAgent:=GetAgentField(FAgent,IntToStr(E^.Point.Dat[cc].AgentKod,CClientKod));
         Format(SAgent,CClient);
         wspom:=IntToStr(E^.Point.Dat[cc].AgentKod,CClientKod);
         RFormatZerro(wspom,CClientKod);
         s:=s+SAgent+' '+wspom+'�';

         wspom[0]:=#0;
         If E^.Point.Dat[cc].DocReal>0 Then
         wspom:=IntToStr(E^.Point.Dat[cc].DocReal,CDocNumer);
         Format(wspom,CDocNumer);

         s:=s+wspom+'�';



   wspom[0]:=#0;
   If E^.Point.Dat[cc].DocDate>0 Then
   wspom:=DateToDAteString(DateMask,E^.Point.Dat[cc].DocDate)
   Else
   Format(wspom,CDate);

         s:=s+wspom+'�';

        If NoScreenList^.List^.Count>=MaxCollectionSize-1 Then
         Begin
          Dispose(E,Done);
          System.Close(Zf);
          NoInfoMsg;
          MessageBox(^M+#3+'��९������� ������樨!',Nil,mfError+mfCancelButton);
          Exit;
         End;

            NoScreenList^.List^.Insert(NewStr(s));
            NoScreenList^.SetRange(NoScreenList^.List^.Count);

           End;{䨫��� ����������}
      End;{������ ��⨢��� �த��}
        End;{䨫��� ��㯯� ����樨}
   End;{䨫��� ᪫���}
End;{TestOtgruska}
End;
End;{For}
Dispose(E,Done);
 End;{While}

Dispose(TempList,Done);


i:=IOResult;
System.Close(Zf);
i:=IOResult;

NoInfoMsg;

MyStr(StrToReal(AllSkid),CIZena,CMantissa,AllSkid);
DelSpace(AllSkid);

MyStr(StrToReal(AllSumma),CIZena,CMantissa,AllSumma);
DelSpace(AllSumma);

MyStr(StrToReal(AllClient),CIZena,CMantissa,AllClient);
DelSpace(AllClient);

Str(StrToInt(AllDoc):CArtikul,AllDoc);
DelSpace(AllDoc);

Dispose(ControlAllClient,Done);
R.Assign(63, 22, 78, 23);
ControlAllClient := New(PColoredText, Init(R, #3+AllSumma, $4E));
Insert(ControlAllClient);

Dispose(ControlAllDoc,Done);
R.Assign(42, 22, 47, 23);
ControlAllDoc := New(PColoredText, Init(R, #3+AllDoc, $4E));
Insert(ControlAllDoc);

Dispose(ControlAllSkid,Done);
R.Assign(12, 22, 27, 23);
ControlAllSkid := New(PColoredText, Init(R, #3+AllSkid, $4E));
Insert(ControlAllSkid);


End;



constructor TReestrZWindow.Init(Var l : Boolean);
var
  R : TRect;
  Control : PView;
  C : Word;
  s: TMyString;
  ws : AllStr;
  AllDoc,AllClient,AllSkid,AllTara,AllSumma : String[CIZena];
  E : PSuperMarketType;
begin
L:=False;

FiltrStatus[1]:=1;
FiltrStatus[2]:=0;
FiltrStatus[3]:=0;


FiltrDoc[1]:=1;
FiltrDoc[2]:=1;
FiltrDoc[3]:=1;
FiltrDoc[4]:=1;
FiltrDoc[5]:=1;
FiltrDoc[6]:=1;
FiltrDoc[7]:=1;
FiltrDoc[8]:=1;
FiltrDoc[9]:=1;

DateTrans[0]:=#0;



R.Assign(0, 0, 80, 23);
inherited Init(R, ''{'������ ���㬥�⮢ ���㧪� ⮢�� � ᪫��� � '+StartDate+' �� '+StopDate});
Options := Options or ofCenterX or ofCenterY;
HelpCtx:=$E002;




R.Assign(0, 0, 0, 0);
NoScreenList := New(PBox, Init(R, 1, Nil));
NoScreenList^.NewList(New(PTextCollection, Init(1,1)));
AllDoc[0]:=#0;
AllSkid[0]:=#0;
AllTara[0]:=#0;
AllSumma[0]:=#0;
AllClient[0]:=#0;

NoScreenList^.FocusItem(0);


MyStr(StrToReal(AllSkid),CIZena,CMantissa,AllSkid);
DelSpace(AllSkid);

MyStr(StrToReal(AllSumma),CIZena,CMantissa,AllSumma);
DelSpace(AllSumma);

Str(StrToInt(AllDoc):CLitrMantissa,AllDoc);
DelSpace(AllDoc);

MyStr(StrToReal(AllClient),CIZena,CMantissa,AllClient);
DelSpace(AllClient);

R.Assign(6, 0, 6+Length('������ ������� �� ��ਮ� � '+StartDate+' �� '+StopDate+' (���⠢��: ????????)')+2, 1);

If DateTrans[0]=#0 Then
ControlPeriod := New(PColoredText, Init(R, #3+'������ ������� �� ��ਮ� � '+StartDate+' �� '+StopDate+
' (���⠢��: ????????)', $4F))
Else
ControlPeriod := New(PColoredText, Init(R, #3+'������ ������� �� ��ਮ� � '+StartDate+' �� '+StopDate+
' (���⠢��: '+DateTrans+')', $4F));


ControlPeriod^.Options := ControlPeriod^.Options or ofCenterX;
Insert(ControlPeriod);






R.Assign(13, 1, 63, 2);
ControlSort := New(PRadioButtons, Init(R,
  NewSItem('��~�~���',
  NewSItem('N ~�~��.',
  NewSItem('���~�~���',
  NewSItem('������', Nil))))));
ControlSort^.SetData(Sorting);
Insert(ControlSort);

  R.Assign(1, 1, 13, 2);
  Insert(New(PLabel, Init(R, '����஢��:', ControlSort)));


R.Assign(64, 1, 78, 2);
ControlDirection := New(PRadioButtons, Init(R,
  NewSItem(#30,
  NewSItem(#31, Nil))));

ControlDirection^.SetData(Direction);
Insert(ControlDirection);

Convert3(M3);
BitToWord3(M3,Filtr);

Convert3(M3);

Convert2(ActivMas);
BitToWord2(ActivMas,Activ);

Convert2(Sertif2);
BitToWord2(sertif2,sertifword);
Convert2(sertif2);

Auto:=0;


If StrToInt(CurrentPassword)=0 Then
Begin

R.Assign(68, 2, 73, 3);
ControlAuto := New(PCheckboxes, Init(R,NewSItem('~�~', Nil)));
ControlAuto^.SetDAta(Auto);
Insert(ControlAuto);

R.Assign(73, 2, 77, 3);
ControlRefreshTime := New(PInputLine, Init(R, 2));
Insert(ControlRefreshTime);

s:=IntToStr(RefreshTime,2);
DelSpace(s);
ControlRefreshTime^.SetData(s);

  R.Assign(77, 2, 80, 3);
  ControlCombo := New(PCombo, Init(R, PInputLine(ControlRefreshTime), cbxOnlyList or cbxDisposesList or cbxNoTransfer,
    NewSItem('�10',
    NewSItem('�15',
    NewSItem('�20',
    NewSItem('�25',
    NewSItem('�30',
    NewSItem('�35',
    NewSItem('�40',
    NewSItem('�45',
    NewSItem('�50',
    NewSItem('�55',
    NewSItem('�60',
    NewSItem('�65',
    NewSItem('�70',
    NewSItem('�75',
    NewSItem('�80',
    NewSItem('�85',
    NewSItem('�90',
    NewSItem('�95',
    Nil))))))))))))))))))));
  PCombo(ControlCombo)^.ActivateChar('*');
{$IFNDEF NetVersion}
  ControlCombo^.Options := ControlCombo^.Options and not ofSelectable;
{$ENDIF}
  Insert(ControlCombo);
End
Else
 Begin

R.Assign(68, 2, 73, 3);
ControlAuto := New(PCheckboxes, Init(R,NewSItem('~�~', Nil)));
ControlAuto^.SetDAta(Auto);
Insert(ControlAuto);

R.Assign(73, 2, 77, 3);
ControlRefreshTime := New(PInputLine, Init(R, 2));
Insert(ControlRefreshTime);

s:=IntToStr(RefreshTime,2);
DelSpace(s);
ControlRefreshTime^.SetData(s);

  R.Assign(77, 2, 80, 3);
  ControlCombo := New(PCombo, Init(R, PInputLine(ControlRefreshTime), cbxOnlyList or cbxDisposesList or cbxNoTransfer,
    NewSItem('�10',
    NewSItem('�15',
    NewSItem('�20',
    NewSItem('�25',
    NewSItem('�30',
    NewSItem('�35',
    NewSItem('�40',
    NewSItem('�45',
    NewSItem('�50',
    NewSItem('�55',
    NewSItem('�60',
    NewSItem('�65',
    NewSItem('�70',
    NewSItem('�75',
    NewSItem('�80',
    NewSItem('�85',
    NewSItem('�90',
    NewSItem('�95',
    Nil))))))))))))))))))));
  PCombo(ControlCombo)^.ActivateChar('*');
{$IFNDEF NetVersion}
  ControlCombo^.Options := ControlCombo^.Options and not ofSelectable;
{$ENDIF}
  Insert(ControlCombo);
 End;

R.Assign(79, 3, 80, 20);
Control := New(PScrollBar, Init(R));
Insert(Control);

R.Assign(0, 3, 79, 20);
DocList := New(PBox, Init(R, 1, PScrollbar(Control)));
DocList^.NewList(New(PMyCollection, Init(0,1)));
DocList^.FocusItem(0);
DocList^.HelpCtx:=$F256;

Insert(DocList);

  R.Assign(1, 2, 68, 3);
{ Insert(New(PLabel, Init(R, ' ������               N   �६�    �㬬� ���㧪�   �㬬� ᪨���  � ', DocList)));}
  Insert(New(PLabel, Init(R, ' ������             �����  ���    �ப ��  �㬬� ���.�㬬� ᪨�', DocList)));

{
R.Assign(2, 20, 10, 21);
ControlSf := New(PCheckboxes, Init(R,
  NewSItem('�~�~', Nil)));
Insert(ControlSf);
ControlSf^.SetData(FiltrSf);
}

R.Assign(4, 20, 8, 21);
Control := New(PColoredText, Init(R, '���:', $74));
Insert(Control);

R.Assign(8, 20, 17, 21);
ControlVidDoc := New(PColoredText, Init(R, #3, $7E));
Insert(ControlVidDoc);


R.Assign(22, 20, 28, 21);
Control := New(PColoredText, Init(R, '�����:', $74));
Insert(Control);

R.Assign(28, 20, 55, 21);
ControlAgent := New(PColoredText, Init(R, #3+'', $7E));
Insert(ControlAgent);

R.Assign(60, 20, 68, 21);
Control := New(PColoredText, Init(R, '�믨ᠭ:', $74));
Insert(Control);

R.Assign(68, 20, 76, 21);
ControlTimeC := New(PColoredText, Init(R, #3+'', $7E));
Insert(ControlTimeC);

R.Assign(4, 21, 8, 22);
Control := New(PColoredText, Init(R, '���:', $74));
Insert(Control);

R.Assign(8, 21, 27, 22);
ControlModifyDate := New(PColoredText, Init(R, #3+'', $7E));
Insert(ControlModifyDate);

R.Assign(29, 21, 36, 22);
Control := New(PColoredText, Init(R, '�����:', $74));
Insert(Control);

R.Assign(36, 21, 67, 22);
ControlStatus := New(PColoredText, Init(R, #3+'', $5E));
Insert(ControlStatus);


R.Assign(51, 22, 63, 23);
Control := New(PColoredText, Init(R, ' � � �����:', $74));
Insert(Control);


R.Assign(63, 22, 78, 23);
ControlAllClient := New(PColoredText, Init(R, #3+AllClient, $4E));
Insert(ControlAllClient);


R.Assign(33, 22, 42, 23);
Control := New(PColoredText, Init(R, ' ���-⮢:', $74));
Insert(Control);


R.Assign(42, 22, 47, 23);
ControlAllDoc := New(PColoredText, Init(R, #3+AllDoc, $4E));
Insert(ControlAllDoc);



R.Assign(2, 22, 12, 23);
Control := New(PColoredText, Init(R, ' � ������:', $74));
Insert(Control);

R.Assign(12, 22, 27, 23);
ControlAllSkid := New(PColoredText, Init(R, #3+AllSkid, $4E));
Insert(ControlAllSkid);



SelectNext(False);
SelectNext(False);
SelectNext(False);
SelectNext(False);
SelectNext(False);
SelectNext(False);
SelectNext(False);
SelectNext(False);
SelectNext(False);
SelectNext(False);

{If StrToInt(CurrentPassword)=0 Then SelectNext(False);}

L:=True;
Refresh;
PrevCur[0]:=#0;
SortScreenList(True);
StartTime:=TimeStringToTime('hh:mm:ss',Times);
end;




procedure TReestrZWindow.FullPreview;
Var Ass : DocumentEditZ;
    E : PSuperMarketType;
    R : TRect;
    f : MarketFileType;
         c : Word;
    P : PBox;
    ws : TMyString;
    Find : Boolean;
    SKolish,SDoc,SClientKod,SAgentKod : ArtikulStr;
    s,SCommentr : String;
    SDate : TDateString;
    ws1,WspomSkidka:String[CIZena];
    v : Byte;


Begin
If (DocList^.List<>Nil)And(DocList^.List^.Count>=1) Then
Begin
  Ass.EditPosition:=Copy(DocList^.GetText(DocList^.Focused,DocList^.List^.Count),1+CClient+1,CDocNumer+1);
  DelSpace(Ass.EditPosition);
  DelZerro(Ass.EditPosition);
  s:=DocList^.GetText(DocList^.Focused,DocList^.List^.Count);
  Ass.D:=Copy(DocList^.GetText(DocList^.Focused,DocList^.List^.Count),1+CClient+1+(CDocNumer+1)+1,CDAte);;

  DelSpace(Ass.D);
  ViewMrk^.FullScreenMrk(Ass,True);
End;
End;


Procedure TReestrZWindow.NetUnLock;
Var Ass : DocumentEditZ;
     s : String;
Begin
If (DocList^.List<>Nil)And(DocList^.List^.Count>=1) Then
Begin
  If Password(2) Then
  Begin
  Ass.EditPosition:=Copy(DocList^.GetText(DocList^.Focused,DocList^.List^.Count),1+CClient+1,CDocNumer+1);
  DelSpace(Ass.EditPosition);
  DelZerro(Ass.EditPosition);
  s:=DocList^.GetText(DocList^.Focused,DocList^.List^.Count);
  Ass.D:=Copy(DocList^.GetText(DocList^.Focused,DocList^.List^.Count),1+CClient+1+
  (CDocNumer+1)+1,CDate);

  {Ass.D:=DocDate;}
  DelSpace(Ass.D);
  Repeat
  Until (UnLockZakaz(Ass.EditPosition) in [0,2]);
  MessageBox(^M+#3'����� N '+Ass.EditPosition+' �� '+Ass.D+' '+
  '�ᯥ譮 �������஢��!',Nil,mfInformation+mfCancelButton);
  End;
end;
End;


Function TestAgent(Agent:PBox;Cod:ArtikulStr):Boolean;
Var L : Boolean;
    i : word;
    st : String;
Begin
TestAgent:=False;
If (Agent^.List^.Count-1)>=0 Then
Begin
For i:=0 To Agent^.List^.Count-1 Do
 Begin
  st:=Agent^.GetText(i,Agent^.List^.Count);
  st:=Copy(st,1+1,CClientKod);
  If (St=Cod) Then
   Begin
    TestAgent:=True;
    Break;
   End;{St=Cod}
 End;
End;
End;




Procedure TReestrZWindow.FormReport(Const P:PBox);
Const Space=' ';
Var f : text;
         SVersia,Skidka,Summa,ws,s : String;
         Itogo,ISkid,NDS20,NDS10,NDS_ : Array[0..8] Of Real;
         c,k : Word;
         Open : String;
      As : DocumentEditZ;
      Tip : Word;
      NDS,LocNDS,LocNDS20,LocNDS10,LocNDS_:Real;
      Agent : PBox;
      AgKod : AllStr;
      R : TRect;
Begin


If (P^.List<>Nil) And (P^.List^.Count>=1) Then
 Begin
 Assign (f,Path^.Dat.ToTemp+'listz.txt');
 c:=0;
 Rewrite(f);
 c:=IOResult;
 If c<>0 Then
  Begin
        MessageBox(#3^m+#3+'�� ���� ᮧ���� 䠩� '+Path^.Dat.ToTemp+'listz.txt',Nil,mfError+mfCancelButton);
   Exit;
  End;


R.Assign(0, 0, 0, 0);
Agent := New(PBox, Init(R, 1, Nil));
Agent^.NewList(New(PTextCollection, Init(0,1)));


If Not(SelectionAgent(Agent)) Then
 Begin
  System.Close(f);
  Dispose(Agent,Done);
  Exit;
 End;


 Writeln(f,Header+Space+ '�����: ',GetClientField(FClient,Rek^.Dat.Kod,1)+'  ������: '+CurrentPassword+' EYE & 1997-98');


 Write(f,Space+'��� ���஢��:');
 Case Sorting Of
 0:Writeln(f,Space+'"������"');
 1:Writeln(f,Space+'"����� ������"');
 2:Writeln(f,Space+'"�㬬� ���㧪�"');
 3:Writeln(f,Space+'"�㬬� ᪨���"');
 Else Writeln(f);
 End;


 Writeln(f,Space+'����祭� � ��ᬮ�७�� ���� ���㬥�⮢:');
 Write(f,Space);
 For c:=1 To Max9 Do
  Begin
   If FiltrDoc[c]=1 Then
    Case c Of
    1:Write(f,' "���᮪" ');
    2:Write(f,' "���.���*" ');
    3:Write(f,' "���.�*" ');
    4:Write(f,' "��*" ');
    5:Write(f,' "�� �" ');
    6:Write(f,' "�����*" ');
    7:Write(f,' "����� ��*" ');
    8:Write(f,' "�����" ');
    9:Write(f,' "����� ���" ');
    Else;
    End;
  End;
 Writeln(f);

 Writeln(f,Space+'����祭� � ��ᬮ�७�� ������ � ����ᮬ:');
 Write(f,Space);
 For c:=1 To Max3 Do
  Begin
   If FiltrStatus[c]=1 Then
    Case c Of
    1:Write(f,' "�� ��ଫ��" ');
    2:Write(f,' "��ଫ��" ');
    3:Write(f,' "��㫨஢��" ');
    Else;
    End;
  End;
 Writeln(f);

 Writeln(f);

 Write(f,Space+'��� ���㧪�: ');
 WordToBit2(sertifword,sertif2);
 Convert2(sertif2);

 If Sertif2[1]=1 Then Write(f,'"�����" ');
 If Sertif2[2]=1 Then Write(f,'"���஢���⥫�� ���㬥���"');

 Writeln(f);


 Writeln(f);

 If Izmen=1 Then
 Begin
  Writeln(f,Space+'��������! � �ࠢ�� ����祭� ⮫쪮 ������訥�� ���㬥���!');
  Writeln(f);
 End;

 If RegimExt=1 Then Writeln(f,Space+'������ �������� �����');

 Writeln(f);

 Writeln(f,Space+'������ ������� ������ � ��������.�����-�� '+' � '+StartDate+' �� '+StopDate+
 ' ('+FDate+' '+Times+')');

 If DateTrans[0]<>#0 Then
 Writeln(f,Space+'���⠢��: '+DateTrans);
(*
 Writeln(f,Space+'��࠭� ᫥���騥 ������:');
 For c:=0 To Agent^.List^.Count-1 Do
  Begin
   s:=Agent^.GetText(c,Agent^.List^.Count);

   AgKod:=Copy(s,1+1,CClientKod);

   S:=GetAgentField(FClient,AgKod);
   Format(s,CClient);
   s:=s+' ('+AgKod+')';
   Writeln(f,Space+s);
  End;
*)
 Writeln(f,Space+'������������������������������������������������������������������������������������������Ŀ');
 Writeln(f,Space+'�������              �����  ���    �ப ��  �㬬� ��. �㬬� ᪨�.��� ����. ������     �');
 Writeln(f,Space+'��������������������������������������������������������������������������������������������'+HeaderStop);


 For c:=0 To 8 Do
 Begin
  ISkid[c]:=0;
  Itogo[c]:=0;
 End;


 For c:=0 To P^.List^.Count-1 Do
  Begin
     DInfoMsgShkala('��ନ��� ���� ...',0,P^.List^.Count-1,c);
        s := P^.GetText(c,P^.List^.Count);

AgKod:=Copy(s,1+CClient+1
           +(CDocNumer+1)+1+CDate+1+CDate+1+CIZenaK+1+CIZenaK+1+CKto+1+(1)+1+(1)+1+(1)+1+(1)+1+CDate+1+
                 CDate+1+CDAte+1+CClient+1,CClientKod);


If TestAgent(Agent,AgKod) Then
Begin
As.EditPosition:=Copy(s,1+CClient+1,CDocNumer+1);
As.D:=Copy(s,1+CClient+1+(CDocNumer+1)+1,CDate);

        While Pos('�',s)>0 Do
         Begin
          k:=Pos('�',s);
          System.Delete(s,k,1);
          System.Insert(' ',s,k);
         End;

{                                                                               ���  ��  TimeC
DateM    TimeM   AgentDocReal DocDate}
{12345678901234567890�12345�12345678�12345678�1234567890�1234567890�123456789012�1�1�1�1�12345678�
12345678�12345678�1234�1234�12345678}
{                                                                                 ���}

         SVersia:=Copy(s,1+CClient+1
           +(CDocNumer+1)+1+CDate+1+CDate+1+CIZenaK+1+CIZenaK+1+CKto+1+(1)+1+(1)+1+(1)+1,COne);

         If StrToInt(SVersia)>1 Then SVersia:='!'
         Else SVersia[0]:=#0;

        ws:=Copy(s,1+CClient+1
           +(CDocNumer+1)+1+CDate+1+CDate+1+CIZenaK+1+CIZenaK+1+CKto+1+(1)+1,COne);


        s[0]:=Chr(1+CClient+1+(CDocNumer+1)+1+CDate+1+CDate+1+CIZenaK+1+CIZenaK+1+CKto);


        Summa:=Copy(s,1+CClient+1+(CDocNumer+1)+1+CDate+1+CDate+1,CIZenaK);
       Skidka:=Copy(s,1+CClient+1+(CDocNumer+1)+1+CDate+1+CDate+1+CIZenaK+1,CIZenaK);


        Case StrToInt(Ws) of
        8:Begin ws:='����� ���';
                          Itogo[8]:=Itogo[8]+StrToReal(Summa);
                          ISkid[8]:=Iskid[8]+StrToReal(Skidka);
          End;
        7:Begin ws:='�����';
                          Itogo[7]:=Itogo[7]+StrToReal(Summa);
                          ISkid[7]:=Iskid[7]+StrToReal(Skidka);
          End;
        6:Begin ws:='����� ��*';
                          Itogo[6]:=Itogo[6]+StrToReal(Summa);
                          ISkid[6]:=Iskid[6]+StrToReal(Skidka);
          End;
        5:Begin ws:='�����*';
                          Itogo[5]:=Itogo[5]+StrToReal(Summa);
                          ISkid[5]:=Iskid[5]+StrToReal(Skidka);
          End;
        4:Begin ws:='�� �';
                          Itogo[4]:=Itogo[4]+StrToReal(Summa);
                          ISkid[4]:=Iskid[4]+StrToReal(Skidka);
          End;
        3:Begin ws:='��*';
                          Itogo[3]:=Itogo[3]+StrToReal(Summa);
                          ISkid[3]:=Iskid[3]+StrToReal(Skidka);
          End;
        2:Begin ws:='���.���*';
                          Itogo[2]:=Itogo[2]+StrToReal(Summa);
                          ISkid[2]:=Iskid[2]+StrToReal(Skidka);
          End;
        1:Begin ws:='���.���*';
                          Itogo[1]:=Itogo[1]+StrToReal(Summa);
                          ISkid[1]:=Iskid[1]+StrToReal(Skidka);
          End;
        0:Begin ws:='���᮪';
                          Itogo[0]:=Itogo[0]+StrToReal(Summa);
                          ISkid[0]:=Iskid[0]+StrToReal(Skidka);
          End;
        Else ws[0]:=#0;
        End;

        Format(ws,10);
        {System.Delete(s,1+CClient+1+(CDocNumer+1)+1+CDate+1+CDate+1+CIZenaK+1+CIZenaK+1,1);}
        System.Insert(ws,s,1+CClient+1+(CDocNumer+1)+1+CDate+1+CDate+1+CIZenaK+1+CIZenaK+1);
        Writeln(f,Space+s+' '+SVersia);
End;{AgKod}
  End;
 Writeln(f,Space+'�������������������������������������������������������������������������������������������-');

 Summa[0]:=#0;
 For c:=0 To 8 Do MyStr(StrToReal(Summa)+Itogo[c],CIZena,CMantissa,Summa);

 Skidka[0]:=#0;
 For c:=0 To 8 Do MyStr(StrToReal(Skidka)+ISkid[c],CIZena,CMantissa,SKidka);

 s:='�ᥣ� �� �㬬�: '+Recogniz(Summa)+' �� '+^M;
 ws[0]:=#0;
 For c:=0 To 8 Do
  Begin
        If Abs(Itogo[c])>=0.01 Then
         Begin
          Case c Of
          0:ws:=ws+Space+' ���᮪:   '+RecognizReal(Itogo[c],CIZena,CMantissa)+' �� '+^M;
          1:ws:=ws+Space+' ���.���*: '+RecognizReal(Itogo[c],CIZena,CMantissa)+' �� '+^M;
          2:ws:=ws+Space+' ���.���*:'+RecognizReal(Itogo[c],CIZena,CMantissa)+' �� '+^M;
          3:ws:=ws+Space+' �/�*:     '+RecognizReal(Itogo[c],CIZena,CMantissa)+' �� '+^M;
          4:ws:=ws+Space+' �/� �:    '+RecognizReal(Itogo[c],CIZena,CMantissa)+' �� '+^M;
          5:ws:=ws+Space+' �����*:   '+RecognizReal(Itogo[c],CIZena,CMantissa)+' �� '+^M;
          6:ws:=ws+Space+' ����� ��*:'+RecognizReal(Itogo[c],CIZena,CMantissa)+' �� '+^M;
          7:ws:=ws+Space+' �����    :'+RecognizReal(Itogo[c],CIZena,CMantissa)+' �� '+^M;
     8:ws:=ws+Space+' ����� ���:'+RecognizReal(Itogo[c],CIZena,CMantissa)+' �� '+^M;
     Else ;
     End;
    End;
  End;
 Writeln(f,Space+s+ws);
 s:='�ᥣ� ᪨���: '+Recogniz(Skidka)+' �� '+^M;
 ws[0]:=#0;
 For c:=0 To 8 Do
  Begin
   If Abs(ISkid[c])>=0.01 Then
    Begin
     Case c Of
     0:ws:=ws+Space+' ���᮪:   '+RecognizReal(ISkid[c],CIZena,CMantissa)+' �� '+^M;
     1:ws:=ws+Space+' ���.���*: '+RecognizReal(ISkid[c],CIZena,CMantissa)+' �� '+^M;
     2:ws:=ws+Space+' ���.���*:'+RecognizReal(ISkid[c],CIZena,CMantissa)+' �� '+^M;
     3:ws:=ws+Space+' �/�*:     '+RecognizReal(ISkid[c],CIZena,CMantissa)+' �� '+^M;
     4:ws:=ws+Space+' �/� �:    '+RecognizReal(ISkid[c],CIZena,CMantissa)+' �� '+^M;
     5:ws:=ws+Space+' �����*:   '+RecognizReal(ISkid[c],CIZena,CMantissa)+' �� '+^M;
     6:ws:=ws+Space+' ����� ��*:'+RecognizReal(ISkid[c],CIZena,CMantissa)+' �� '+^M;
     7:ws:=ws+Space+' �����    :'+RecognizReal(ISkid[c],CIZena,CMantissa)+' �� '+^M;
     8:ws:=ws+Space+' ����� ���:'+RecognizReal(ISkid[c],CIZena,CMantissa)+' �� '+^M;
     Else ;
     End;
    End;
  End;
 Writeln(f,Space+s+ws);


 Writeln(f,Space,'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
 Writeln(f,Space+'============================================================================================');

 System.Close(f);
 Dispose(Agent,Done);

 NoInfoMsg;
 ViewAsText(Path^.Dat.ToTemp+'listz.txt',True);
 If Izmen=1 Then
 MessageBox(^M+#3'� �ࠢ�� ����祭� ⮫쪮 ������訥�� ���㬥���!',Nil,mfWarning+mfCancelButton);;
 {ReportNew(Path^.Dat.ToTemp+'listz.txt','',1,False,False);}
 End;
End;


Procedure TReestrZWindow.FormReportRegion(Const P:PBox);
Const Space=' ';
Var f : text;
         SVersia,Skidka,Summa,ws,s : String;
         Itogo,ISkid,NDS20,NDS10,NDS_ : Array[0..8] Of Real;
         c,k : Word;
         Open : String;
      As : DocumentEditZ;
      Tip : Word;
      NDS,LocNDS,LocNDS20,LocNDS10,LocNDS_:Real;
      Agent : PBox;
      AgKod : AllStr;
      c1,Count : Word;
      R : TRect;
      Zak : PZakazType;
      Massa,RegionNumber,ZNumer,
      RegKod,RegNAme,
	 AllMassa,AllSumma,LocMassa,LocSumma : AllStr;
      TempRegion,TempListZ :PBox;
      Cl : PClientType;
      LocCount,AllCount : Word;
  RegionFile : File;
  RegionElement : PBufRegionType;
Begin


If (P^.List<>Nil) And (P^.List^.Count>=1) Then
 Begin
 Assign (f,Path^.Dat.ToTemp+'listzr.txt');
 c:=0;
 Rewrite(f);
 c:=IOResult;
 If c<>0 Then
  Begin
        MessageBox(#3^m+#3+'�� ���� ᮧ���� 䠩� '+Path^.Dat.ToTemp+'listzr.txt',Nil,mfError+mfCancelButton);
   Exit;
  End;


R.Assign(0, 0, 0, 0);
Agent := New(PBox, Init(R, 1, Nil));
Agent^.NewList(New(PTextCollection, Init(0,1)));


If Not(SelectionAgent(Agent)) Then
 Begin
  System.Close(f);
  Dispose(Agent,Done);
  Exit;
 End;


 Writeln(f,Header+Space+ '�����: ',GetClientField(FClient,Rek^.Dat.Kod,1)+'  ������: '+CurrentPassword+' EYE & 1997-98');


 Write(f,Space+'��� ���஢��:');
 Case Sorting Of
 0:Writeln(f,Space+'"������"');
 1:Writeln(f,Space+'"����� ������"');
 2:Writeln(f,Space+'"�㬬� ���㧪�"');
 3:Writeln(f,Space+'"�㬬� ᪨���"');
 Else Writeln(f);
 End;


 Writeln(f,Space+'����祭� � ��ᬮ�७�� ���� ���㬥�⮢:');
 Write(f,Space);
 For c:=1 To Max9 Do
  Begin
   If FiltrDoc[c]=1 Then
    Case c Of
    1:Write(f,' "���᮪" ');
    2:Write(f,' "���.���*" ');
    3:Write(f,' "���.�*" ');
    4:Write(f,' "��*" ');
    5:Write(f,' "�� �" ');
    6:Write(f,' "�����*" ');
    7:Write(f,' "����� ��*" ');
    8:Write(f,' "�����" ');
    9:Write(f,' "����� ���" ');
    Else;
    End;
  End;
 Writeln(f);

 Writeln(f,Space+'����祭� � ��ᬮ�७�� ������ � ����ᮬ:');
 Write(f,Space);
 For c:=1 To Max3 Do
  Begin
   If FiltrStatus[c]=1 Then
    Case c Of
    1:Write(f,' "�� ��ଫ��" ');
    2:Write(f,' "��ଫ��" ');
    3:Write(f,' "��㫨஢��" ');
    Else;
    End;
  End;
 Writeln(f);


 If RegimExt=1 Then Writeln(f,Space+'������ �������� �����');


 Write(f,Space+'��� ���㧪�: ');
 WordToBit2(sertifword,sertif2);
 Convert2(sertif2);

 If Sertif2[1]=1 Then Write(f,'"�����" ');
 If Sertif2[2]=1 Then Write(f,'"���஢���⥫�� ���㬥���"');

 Writeln(f);


 Writeln(f);

 If Izmen=1 Then
 Begin
  Writeln(f,Space+'��������! � �ࠢ�� ����祭� ⮫쪮 ������訥�� ���㬥���!');
  Writeln(f);
 End;


 Writeln(f);

 Writeln(f,Space+'������ ������� ������ '+' � '+StartDate+' �� '+StopDate+'  �� ��������'+HeaderStop);

 If DateTrans[0]<>#0 Then
 Writeln(f,Space+'���⠢��: '+DateTrans);
(*
 Writeln(f,Space+'��࠭� ᫥���騥 ������:');
 For c:=0 To Agent^.List^.Count-1 Do
  Begin
   s:=Agent^.GetText(c,Agent^.List^.Count);

   AgKod:=Copy(s,1+1,CClientKod);

   S:=GetAgentField(FClient,AgKod);
   Format(s,CClient);
   s:=s+' ('+AgKod+')';
   Writeln(f,Space+s);
  End;
*)

R.Assign(0,0,0,0);
TempListZ := New(PBox, Init(R, 1, Nil));
TempListZ^.NewList(New(PTextCollection, Init(0,1)));



{横� �ନ஢���� ᯨ᪠ ������� �� ॣ�����}
 For c:=0 To P^.List^.Count-1 Do
  Begin
     DInfoMsgShkala('���।���� ������ �� ॣ����� ...',0,P^.List^.Count-1,c);
     s := P^.GetText(c,P^.List^.Count);
     AgKod:=Copy(s,1+CClient+1+(CDocNumer+1)+1+CDate+1+CDate+1+CIZenaK+1+CIZenaK+1+CKto+1+(1)+1+(1)+1+(1)+1+(1)+1+CDate+1+
                 CDate+1+CDAte+1+CClient+1,CClientKod);

If TestAgent(Agent,AgKod) Then
Begin
    ZNumer:=Copy(s,1+CClient+1,CDocNumer+1);
    s[0]:=Chr(1+CClient+1+(CDocNumer+1)+1+CDate+1+CDate+1+CIZenaK);
    New(Zak,Init);

    GetZakaz(ZNumer,Zak);
    Massa:=CalcZakazMassa(Zak);
    MyStr(StrToReal(Massa),CPAck,CLitrMantissa,Massa);
    New(Cl,Init);
    Cl^.DAt.Kod:=Zak^.Dat.ClientKod;
    GetClient(Cl,Zak^.Dat.OperatorSelector);
    RFormatZerro(Cl^.Dat.RegionKod,CClientKod);
    {Format(Cl^.Dat.AdressF,CNAme35);}
    s:='�'+Cl^.Dat.RegionKod+'�'+s+Massa+'�'+Cl^.Dat.AdressF;
    TempListZ^.List^.Insert(NewStr(s));
    TempListZ^.SetRange(TempListZ^.List^.Count);
    Dispose(Cl,Done);
    Dispose(Zak,Done);
End;
  End;{横� �ᡮન �� ॣ�����}
NoInfoMsg;

R.Assign(0,0,0,0);
TempRegion := New(PBox, Init(R, 1, Nil));
TempRegion^.NewList(New(PTextCollection, Init(0,1)));


DInfoMsg('������� ॣ���� ...',True);
{�ନ�㥬 ���⨭� ॣ����� ��� �᭮����� 横��}
Assign (RegionFile,Path^.Dat.ToSPR+'Region.db');
c:=IOResult;
Reset (RegionFile,SizeOf(RegionType));
c:=IOResult;
While Not(Eof(RegionFile)) Do
 Begin
    New(RegionElement,Init);
    ReadBufRegion(RegionFile,RegionElement,Count);
For c1:=1 To Count Do
Begin
  If (RegionElement^.Point.Dat[c1].Employ) Then
  Begin
  If Not TestElement(RegionElement^.Point.Dat[c1].Kod+'�',TempListZ) Then
   Begin
    TempRegion^.List^.Insert(NewStr(RegionElement^.Point.Dat[c1].Kod+'�'+RegionElement^.Point.Dat[c1].RegionName));
    TempRegion^.SetRange(TempRegion^.List^.Count);
   End;
  End;
End;{For}
  Dispose(RegionElement,Done);
 End;
System.Close(RegionFile);
NoInfoMsg;



{�᭮��� 横� �� ���⨭�� ॣ�����}
DInfoMsg('��ନ��� ���� ...',True);
AllMassa[0]:=#0;
AllSumma[0]:=#0;
AllCount:=0;
If (TempRegion^.List<>Nil) And (TempRegion^.List^.Count>=1) Then
 Begin
  For c1:=0 To TempRegion^.List^.Count-1 Do
   Begin
    s:=TempRegion^.GetText(c1,TempRegion^.List^.Count);
    RegKod:=Copy(s,1,CClientKod);
    RegNAme:=Copy(s,1+CClientKod+1,CCLient);
    LocMassa[0]:=#0;
    LocSumma[0]:=#0;
    LocCount:=0;
    Writeln(f,Space+'������: '+RegNAme+' ('+RegKod+')');
    Writeln(f,Space+'������������������������������������������������������������������������������������������Ŀ');
    Writeln(f,Space+'�������              ����� �㬬� ��.  ����,�� �����᪨� ���� ���⠢.                  �');
                    {12345678901234567890�12345�1234567890�123456789�12345678901234567890123456789012345}
    Writeln(f,Space+'��������������������������������������������������������������������������������������������');
    If (TempListZ^.List<>Nil) And (TempListZ^.List^.Count>=1) Then
     Begin
      For c:=0 To TempListZ^.List^.Count-1 Do
       Begin
        s:=TempListZ^.GetText(c,TempListZ^.List^.Count);
        ws:=Copy(s,1+1,CClientKod);
        {�⡨ࠥ� �� ��饣� ᯨ᪠ �㦭� ��� ॣ���}
        If StrToInt(ws)=StrToInt(RegKod) Then
         Begin
          System.Delete(s,1,1+CClientKod+1);
          System.Delete(s,1+CClient+1+(CDocNumer+1)+1,CDate+1+CDAte+1);
          While Pos('�',s)>0 Do
           Begin
            k:=Pos('�',s);
            System.Delete(s,k,1);
            System.Insert(' ',s,k);
           End;
          MyStr(StrToReal(LocSumma)+StrToReal(
		Copy(s,1+CClient+1+(CDocNumer+1)+1,CIZenaK)),CIZenaK,CMantissa,LocSumma);
          MyStr(StrToReal(LocMassa)+StrToReal(
		Copy(s,1+CClient+1+(CDocNumer+1)+1+CIZenaK+1,CPAck)),CPacK,CLitrMantissa,LocMassa);
          Writeln(f,Space+s);
          Inc(LocCount);
          Inc(AllCount);
         End;
       End;
     End;{TempListZ}
    Writeln(f,Space+'��������������������������������������������������������������������������������������������');
    Writeln(f,Space+'�ᥣ� �� ॣ���� �祪 : ',LocCount:3,' ',RecognizReal(StrToReal(LocSumma),CIZena,CMantissa)+
    ' ��  '+ RecognizReal(StrToReal(LocMassa),CPack,CLitrMantissa)+' �� ');
    Writeln(f,Space+'��������������������������������������������������������������������������������������������');
    Writeln(f);

   End;{For c1}
   MyStr(StrToReal(AllSumma)+StrToReal(LocSumma),CIZena,CMAntissa,AllSumma);
   MyStr(StrToReal(AllMassa)+StrToReal(LocMassa),CIZena,CLitrMAntissa,AllMAssa);
 End;{�᫨ ᯨ᮪ ॣ����� �� ���⮩}

 Writeln(f);
 Writeln(f,Space,'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
 Writeln(f,Space+'============================================================================================');

 System.Close(f);
 Dispose(Agent,Done);
 Dispose(TempListZ,Done);
 Dispose(TempRegion,Done);

 NoInfoMsg;
 ViewAsText(Path^.Dat.ToTemp+'listzr.txt',True);
 If Izmen=1 Then
 MessageBox(^M+#3'� �ࠢ�� ����祭� ⮫쪮 ������訥�� ���㬥���!',Nil,mfWarning+mfCancelButton);;
 {ReportNew(Path^.Dat.ToTemp+'listzr.txt','',1,False,False);}
 End;
End;





procedure TReestrZWindow.HandleEvent(var Event: TEvent);
Var test : Word;
    s,s1,s2 : String;
    SDoc : ArtikulStr;
    SDate: TDateString;
    l : Boolean;
    FC:Byte;
    FS : AllStr;
    V: Word;

begin
  if (Abs(TimeStringToTime('hh:mm:ss',Times)-StartTime)>RefreshTime) And (Auto=1) then
   Begin
     Event.What:=evCommand;
     Event.Command:=cmRefresh;
   End;


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

     kbF7 : Begin
              ClearFind;
              Event.What:=evCommand;
              Event.Command:=cmDocFiltr;
              PutEvent(Event);
              ClearEvent(Event);
            End;
     kbF2 : Begin
              ClearFind;
              Event.What:=evCommand;
              Event.Command:=cmChangeDiapason;
              PutEvent(Event);
              ClearEvent(Event);
            End;



      Else;
      End;{KeyDown}
  evCommand :
     Case Event.Command Of
  cmDocFiltr:Begin
              If Setup Then
              Begin
              Refresh;
              ClearEvent(Event);
              StartTime:=TimeStringToTime('hh:mm:ss',Times);
              PrevCur[0]:=#0;
              SortScreenList(True);
              Redraw;
              End;
                ClearEvent(Event);
             End;

  cmChangeDiapason:Begin
              s1:=StartDate;
              s2:=StopDate;
              If DatePeriodDialog(s1,s2,False) Then
              Begin
              StartDate:=s1;
              StopDate:=s2;

If ((DateStringToDate(DAteMask,StopDate)-
   DateStringToDate(DAteMask,StartDate))>6) Then  Auto:=0
   Else Auto:=1;
              ControlAuto^.SetDAta(Auto);
              Refresh;
              ClearEvent(Event);
              StartTime:=TimeStringToTime('hh:mm:ss',Times);
              PrevCur[0]:=#0;
              SortScreenList(True);
              Redraw;
              End;
                            End;
  cmRefresh: Begin
  If (DeskTop^.Current=PView(DocReestrWindow)) And (Event.What <> EvKeyDown)
      And Not(Glob.Show) And Not(Glob.ShowMsg) And Not(Glob.GlobalShow) Then
           Begin
              FS:=FindStrok;
                    FC:=Ord(FindStrok[0]);
              Refresh;
              ClearEvent(Event);
              StartTime:=TimeStringToTime('hh:mm:ss',Times);
              PrevCur[0]:=#0;
              SortScreenList(False);
              FindStrok:=FS;
              FindSymbol:=FC;
              Redraw;
           End
           Else
            ClearEvent(Event);
          End;
  cmUnlockMarket :
   Begin
    ClearFind;
     If (DocList^.State and sfFocused <> 0) And (DocList^.List<>Nil)And(DocList^.List^.Count>=1) Then
     NetUnLock;
   End;
  cmEdit:    Begin
If (GlobalReadOnly=1) Or (ReadOnlyConst=1) Then
   Begin
    MessageBox(#3^M+ReadOnlyStr^,Nil,mfWarning+mfCancelButton);
    ClearEvent(Event);
    Exit;
   End;
ClearFind;

     If (DocList^.State and sfFocused <> 0) And (DocList^.List<>Nil)And(DocList^.List^.Count>=1) Then
            Begin

   s:=Copy(DocList^.GetText(DocList^.Focused,DocList^.List^.Count),1+CClient+1
           +(CDocNumer+1)+1+CDate+1+CDate+1+CIZenaK+1+CIZenaK+1+CKto+1+(1)+1+(1)+1,COne);

   If StrToInt(s)=1 Then
   Begin
    MessageBox(#3^M+#3'����� 㦥 ��ଫ�� � ���४�஢����� �� �����!',Nil,mfWarning+mfCancelButton);
    ClearEvent(Event);
    Exit;
   End;

   If StrToInt(s)=2 Then
   Begin
    MessageBox(#3^M+#3'����� ��㫨஢�� �� ���祭�� �ப� ���⠢�� � ���४�஢����� �� �����!',Nil,
    mfWarning+mfCancelButton);
    ClearEvent(Event);
    Exit;
   End;

                AssistentZ.EditPosition:=Copy(DocList^.GetText(DocList^.Focused,DocList^.List^.Count),1+CClient+1,
                         (CDocNumer+1));
                DelSpace(AssistentZ.EditPosition);
                DelZerro(AssistentZ.EditPosition);
                AssistentZ.D:=Copy(DocList^.GetText(DocList^.Focused,DocList^.List^.Count),1+CClient+1+(CDocNumer+1)+1,CDate);
                DelSpace(AssistentZ.D);

                Dispose(NoScreenList,Done);
                Event.What:=evCommand;
                Event.Command:=cmSuperZakaz;
                PutEvent(Event);
                ClearEvent(Event);
                Status:=DocEdit;

            End
            End;

  cmPrintReestr:    Begin
                 ClearFind;
     If (DocList^.State and sfFocused <> 0) And (DocList^.List<>Nil)And(DocList^.List^.Count>=1) Then
            Begin
                Assistent.EditPosition:=Copy(DocList^.GetText(DocList^.Focused,DocList^.List^.Count),1+CClient+1,
                         (CDocNumer+1));
                DelSpace(Assistent.EditPosition);
                DelZerro(Assistent.EditPosition);
                Assistent.D:=Copy(DocList^.GetText(DocList^.Focused,DocList^.List^.Count),1+CClient+1+(CDocNumer+1)+1,CDate);
                DelSpace(Assistent.D);

                PrintZakaz(Assistent,NPrint.CopyNkl);
                {Status:=DocNormal;}
            End
            End;
 cmReestrReport:    Begin
                 ClearFind;
     If (DocList^.List<>Nil)And(DocList^.List^.Count>=1) Then
            Begin
            If MessageBox(^M+#3'�஢��� ࠧ����� �� ॣ�����?',Nil,mfConfirmation+mfOkCancel)=cmOk Then
            FormReportRegion(DocList)
            Else
            FormReport(DocList);
            End
            End;
  cmFullView:    Begin
                 ClearFind;
     If (DocList^.State and sfFocused <> 0) And (DocList^.List<>Nil)And(DocList^.List^.Count>=1) Then
            Begin
              FullPreview;
            End
            End;
     cmReestrZakaz:Begin
                  ClearFind;
                  ClearEvent(Event);
                 End;
     cmCancel    : Begin
                 Dispose(NoScreenList,Done);
                 ClearFind;
                 Event.What:=evCommand;
                 Event.Command:=cmClose;
                 PutEvent(Event);
                 ClearEvent(Event);
                End;

      Else;
      End;{evCommand}
      Else;
      End;{*Case*}

  if (Event.What = evBroadcast) and
    (Event.Command = cmReestrZakaz) then ClearEvent(Event);

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

                if (ControlSort^.State and sfFocused <> 0)Then
                    Begin
                        ControlSort^.GetData(Test);
                        If Test <> Sorting Then
                        Begin
                           ClearFind;
                           Sorting:=Test;
                           SortScreenList(False);
                           Redraw;
                        End;
                    End;

                if (ControlDirection^.State and sfFocused <> 0)Then
                    Begin
                        ControlDirection^.GetData(Test);
                        If Test <> Direction Then
                        Begin
                           ClearFind;
                           Direction:=Test;
                           SortScreenList(False);
                           Redraw;
                        End;
                    End;

                if (ControlAuto^.State and sfFocused <> 0)Then
                    Begin
                        ControlAuto^.GetData(Test);
                        If Test <> Auto Then
                        Begin
                           ClearFind;
                           Auto:=Test;
                           Redraw;
                        End;
                    End;

                if (ControlRefreshTime^.State and sfFocused <> 0)Then
                    Begin
                        ControlRefreshTime^.GetData(s);
                        If StrToInt(s) <> RefreshTime Then
                        Begin
                           ClearFind;
                           RefreshTime:=StrToInt(s);
                        End;
                    End;
         End;
end;






BEgin
Direction:=0; {���ࠢ����� ���஢��}
Sorting:=0;   {���� ���஢��}
RefreshTime:=20; {���⮢�� �६� ����������}
Izmen:=0;

M3[1]:=1;
M3[2]:=1;
M3[3]:=1;

sertif2[1]:=1;
sertif2[2]:=1;

ActivMas[1]:=1;
ActivMas[2]:=1;

FiltrStatus[1]:=1;
FiltrStatus[2]:=0;
FiltrStatus[3]:=0;

FiltrDoc[1]:=1;
FiltrDoc[2]:=1;
FiltrDoc[3]:=1;
FiltrDoc[4]:=1;
FiltrDoc[5]:=1;
FiltrDoc[6]:=1;
FiltrDoc[7]:=1;
FiltrDoc[8]:=1;
FiltrDoc[9]:=1;
{$IFDEF Pharm}
StartDAte:=DateToDateString(DateMask,DAteStringToDate(DateMask,FDAte)-31);
{$ELSE}
StartDAte:=DateToDateString(DateMask,DAteStringToDate(DateMask,FDAte)-4);
{$ENDIF}
StopDate:=FDAte;
RegimExt:=0;
DateTrans[0]:=#0;
End.