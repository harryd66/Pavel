Unit Access4;

Interface

Uses Dialogs,Glob,Drivers,ServStr,Access2,Access;

Function AddOperator( Cod:Integer; Var OperatorElement: TSystemReestr):Boolean;
Function AddDopOperator( Cod:Integer; Var OperatorElement: TSystemReestr):Boolean;

implementation

Uses Printers,Vision4,App,Views,Objects,MsgBox,Serv,ColorTxt,Validate,DbEngine,Memory,TpDate,
     Protect,Net,NetDbEng,NetCall,WinDos,Utils,UtilsP;

Function AddDopOperator( Cod:Integer; Var OperatorElement: TSystemReestr):Boolean;
Label 1;
var
  Dlg : PDialog;
  R : TRect;
  Control: PView;
  ControlPost : PView;
  ControlClient : PView;
  ControlPazdel : PView;
  ControlOther : PView;
  ControlDlg : PView;
  ControlBart : PView;
  ControlTov : PView;
  ControlMoveTov : PView;
  ControlPersonal : PView;
  ControlReestr: PView;
  s : TEnjoyStr;
  m: word;
  m2 : Maska2;
  M3 : Maska3;
  M4 : Maska4;
  M5 : Maska5;
  m6: Maska6;
  m7: Maska7;
  M11: MASKA11;
  c,i: Word;
Begin
ClearFind;
If Not(TestOpenDate1(FDate)) Then
   Begin
    MessageBox(#3^M+#3'����� � ����� �� '+FDate+' �������஢��!',Nil,mfError+mfCancelButton);
    AddDopOperator:=False;
    Exit;
   End;
C:=IOResult;
AddDopOperator:=False;
Assign(OperatorFile,Path.ToOperator+'System.db');
Reset(OperatorFile);
C:=IOResult;
If C<>0 Then
Begin
 MessageBox(^M+#3'�訡�� ����㯠 � 䠩�� ॥���!',nil,mfError+mfCancelButton);
 AddDopOperator:=False;
 Exit;
End;
     s:=Copy(Operator^.GetText(Operator^.Focused,Operator^.List^.Count),1+CKto+1,CRazdelKod);
     Repeat
     Read(OperatorFile,OperatorElement);
     Until (Eof(OperatorFile)) Or (OperatorElement.Kod=s);
     OperatorElement.Password:=DeCode(OperatorElement.Password);
     If Eof(OperatorFile) And (OperatorElement.Kod<>s) Then
      Begin
       MessageBox(^M+#3'������ � ॥��� �� ������!',nil,mfError+mfCancelButton);
       Close(OperatorFile);
       AddDopOperator:=False;
       Exit;
      End;

Close(OperatorFile);

1:
R.Assign(0, 0, 79, 23);
New(Dlg, Init(R, '�������� �ࠢ� ����㯠'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.Palette := dpCyanDialog;
Dlg^.HelpCtx:=$E011;

R.Assign(2, 3, 17, 6);
ControlPost := New(PCheckboxes, Init(R,
  NewSItem('��������',                  {51+}
  NewSItem('�������',                   {52+}
  NewSItem('��������', Nil)))));        {53+}

ControlPost^.Options := ControlPost^.Options or ofFramed;
Dlg^.Insert(ControlPost);

  R.Assign(1, 2, 12, 3);
  Dlg^.Insert(New(PLabel, Init(R, '���⠢騪�', ControlPost)));

  for i:=0 to 2 do
  if OperatorElement.User[i+51] then m3[i+1]:=1
     else m3[i+1]:=0;

  Convert3(m3);
  BitToWord3(M3,C);
  ControlPost^.SetData(C);

R.Assign(2, 7, 21, 12);
ControlClient := New(PCheckboxes, Init(R,
  NewSItem('��������',                 {54+}
  NewSItem('�������',                  {55+}
  NewSItem('��������',                 {56+}
  NewSItem('������',                 {57+}
  NewSItem('��������஢���', Nil))))))); {58+}
ControlClient^.Options := ControlClient^.Options or ofFramed;
Dlg^.Insert(ControlClient);

  R.Assign(1, 6, 9, 7);
  Dlg^.Insert(New(PLabel, Init(R, '�������', ControlClient)));

  for i:=0 to 4 do
  if OperatorElement.User[i+54] then m5[i+1]:=1
     else m5[i+1]:=0;

  Convert5(m5);
  BitToWord5(M5,C);
  ControlClient^.SetData(C);


R.Assign(2, 13, 21, 17);
ControlPazdel := New(PCheckboxes, Init(R,
  NewSItem('��������',                {59+}
  NewSItem('�������',                 {60+}
  NewSItem('��������',                {61+}
  NewSItem('�����⢠', Nil))))));     {62+}
ControlPazdel^.Options := ControlPazdel^.Options or ofFramed;
Dlg^.Insert(ControlPazdel);

  R.Assign(1, 12, 9, 13);
  Dlg^.Insert(New(PLabel, Init(R, '�������', ControlPazdel)));

  for i:=0 to 3 do
  if OperatorElement.User[i+59] then m4[i+1]:=1
     else m4[i+1]:=0;

  Convert4(m4);
  BitToWord4(M4,C);
  ControlPazdel^.SetData(C);


R.Assign(2, 18, 23, 22);
ControlTov := New(PCheckboxes, Init(R,
  NewSItem('����窠 ⮢��',           {63+}
  NewSItem('�ࠢ�� ����樨',            {64+}
  NewSItem('�ࠢ�� ��㯯�',             {65+}
  NewSItem('�������� ��㯯�', Nil)))))); {66+}
ControlTov^.Options := ControlTov^.Options or ofFramed;
Dlg^.Insert(ControlTov);

  R.Assign(2, 17, 9, 18);
  Dlg^.Insert(New(PLabel, Init(R, '������', ControlTov)));

  for i:=0 to 3 do
  if OperatorElement.User[i+63] then m4[i+1]:=1
     else m4[i+1]:=0;

  Convert4(m4);
  BitToWord4(M4,C);
  ControlTov^.SetData(C);


R.Assign(26, 3, 49, 5);
ControlDlg := New(PCheckboxes, Init(R,
  NewSItem('�����',                      {67+}
  NewSItem('��७�� � ������', Nil)))); {68+}
ControlDlg^.Options := ControlDlg^.Options or ofFramed;
Dlg^.Insert(ControlDlg);

  R.Assign(26, 2, 32, 3);
  Dlg^.Insert(New(PLabel, Init(R, '�����', ControlDlg)));

   for i:=0 to 1 do
  if OperatorElement.User[i+67] then m2[i+1]:=1
     else m2[i+1]:=0;

  Convert2(m2);
  BitToWord2(M2,C);
  ControlDlg^.SetData(C);


R.Assign(26, 6, 49, 9);
ControlBart := New(PCheckboxes, Init(R,
  NewSItem('�����',                    {69+}
  NewSItem('� �����',                   {70+}
  NewSItem('�� �����', Nil)))));        {71+}
ControlBart^.Options := ControlBart^.Options or ofFramed;
Dlg^.Insert(ControlBart);

  R.Assign(26, 5, 39, 6);
  Dlg^.Insert(New(PLabel, Init(R, '�����������', ControlBart)));

  for i:=0 to 2 do
  if OperatorElement.User[i+69] then m3[i+1]:=1
     else m3[i+1]:=0;

  Convert3(m3);
  BitToWord3(M3,C);
  ControlBart^.SetData(C);



R.Assign(2, 1, 13, 2);
Control := New(PStaticText, Init(R, '��ࠢ�筨��'));
Dlg^.Insert(Control);

R.Assign(26, 10, 49, 12);
ControlMoveTov := New(PCheckboxes, Init(R,
  NewSItem('�������',                    {72+}
  NewSItem('����� ��室����', Nil)))); {73+}
ControlMoveTov^.Options := ControlMoveTov^.Options or ofFramed;
Dlg^.Insert(ControlMoveTov);

  R.Assign(25, 9, 41, 10);
  Dlg^.Insert(New(PLabel, Init(R, '�������� ⮢��', ControlMoveTov)));

  for i:=0 to 1 do
  if OperatorElement.User[i+72] then m2[i+1]:=1
     else m2[i+1]:=0;

  Convert2(m2);
  BitToWord2(M2,C);
  ControlMoveTov^.SetData(C);


R.Assign(26, 13, 49, 20);
ControlPersonal := New(PCheckboxes, Init(R,
  NewSItem('�஭������ �����',       {74+}
  NewSItem('������ ������筮',      {75+}
  NewSItem('������ �� ��ਮ�',      {76+}
  NewSItem('��室����� ',            {77+}
  NewSItem('�����',                 {78+}
  NewSItem('����஢�� ?',             {79 ? }
  NewSItem('��ࠢ�� �� ����⠬ ', Nil)))))))));    {80 ? }
ControlPersonal^.Options := ControlPersonal^.Options or ofFramed;
Dlg^.Insert(ControlPersonal);

  R.Assign(25, 12, 43, 13);
  Dlg^.Insert(New(PLabel, Init(R, '����� � �����⮬', ControlPersonal)));

  for i:=0 to 6 do
  if OperatorElement.User[i+74] then m7[i+1]:=1
     else m7[i+1]:=0;

  Convert7(m7);
  BitToWord7(M7,C);
  ControlPersonal^.SetData(C);


R.Assign(52, 2, 72, 3);
ControlOther := New(PCheckboxes, Init(R,
  NewSItem('����業�', Nil)));          {81+}
ControlOther^.Options := ControlOther^.Options or ofFramed;
Dlg^.Insert(ControlOther);

  R.Assign(51, 1, 65, 2);
  Dlg^.Insert(New(PLabel, Init(R, '�������⥫쭮', ControlOther)));

  if OperatorElement.User[81] then m:=1
     else m:=0;

  ControlOther^.SetData(m);


R.Assign(51, 8, 78, 19);
ControlReestr := New(PCheckboxes, Init(R,
  NewSItem('�㬬� ���㧪�',            {82+}
  NewSItem('���४�஢�� ���㧪�',    {83+}
  NewSItem('��ࠢ�� �� ���㧪��',      {84+}
  NewSItem('����� ���㧪�',           {85+}
  NewSItem('��ࠢ�� �� ��室��',        {86+}
  NewSItem('����� ��室�',            {87+}
  NewSItem('��ࠢ�� �� ॢ����',       {88+}
  NewSItem('����� ॢ����',            {89+}
  NewSItem('���� 㤠���� ',            {90}
  NewSItem('���� �ࠢ��',              {91}
  NewSItem('������� - ��ࠬ.���. ', Nil)))))))))))));   {92+}
ControlReestr^.Options := ControlReestr^.Options or ofFramed;
Dlg^.Insert(ControlReestr);

  R.Assign(51, 7, 70, 8);
  Dlg^.Insert(New(PLabel, Init(R, '������� ���㬥�⮢', ControlReestr)));

  for i:=0 to 10 do
  if OperatorElement.User[i+82] then m11[i+1]:=1
     else m11[i+1]:=0;

  Convert11(m11);
  BitToWord11(M11,C);
  ControlReestr^.SetData(C);

Dlg^.SelectNext(False);

{Dlg^.SetData(OperatorElement);}

c:=Desktop^.ExecView(Dlg);
If c<>cmCancel Then
 Begin
If c<>cmCancel Then
 Begin
  {Dlg^.GetData(OperatorElement);}
{����������� � �������.....}
  ControlPost^.GetData(C);
  WordToBit3(C,M3);
  Convert3(m3);
  for i:=0 to 2 do if m3[i+1]=1 then OperatorElement.User[i+51]:=true
    else OperatorElement.User[i+51]:=false;


  ControlClient^.GetData(C);
  WordToBit5(C,M5);
  Convert5(m5);
  for i:=0 to 4 do if m5[i+1]=1 then OperatorElement.User[i+54]:=true
    else OperatorElement.User[i+54]:=false;


  ControlPazdel^.GetData(C);
  WordToBit4(C,M4);
  Convert4(m4);
  for i:=0 to 3 do if m4[i+1]=1 then OperatorElement.User[i+59]:=true
    else OperatorElement.User[i+59]:=false;

  ControlTov^.GetData(C);
  WordToBit4(C,M4);
  Convert4(m4);
  for i:=0 to 3 do if m4[i+1]=1 then OperatorElement.User[i+63]:=true
    else OperatorElement.User[i+63]:=false;


  ControlDlg^.GetData(C);
  WordToBit2(C,M2);
  Convert2(m2);
  for i:=0 to 1 do if m2[i+1]=1 then OperatorElement.User[i+67]:=true
    else OperatorElement.User[i+67]:=false;

  ControlBart^.GetData(C);
  WordToBit3(C,M3);
  Convert3(m3);
  for i:=0 to 2 do if m3[i+1]=1 then OperatorElement.User[i+69]:=true
    else OperatorElement.User[i+69]:=false;


  ControlMoveTov^.GetData(C);
  WordToBit2(C,M2);
  Convert2(m2);
  for i:=0 to 1 do if m2[i+1]=1 then OperatorElement.User[i+72]:=true
    else OperatorElement.User[i+72]:=false;


  ControlPersonal^.GetData(C);
  WordToBit7(C,M7);
  Convert7(m7);
  for i:=0 to 6 do if m7[i+1]=1 then OperatorElement.User[i+74]:=true
    else OperatorElement.User[i+74]:=false;

  ControlOther^.GetData(C);
  m:=c;
  if m=1 then OperatorElement.User[81]:=true
    else OperatorElement.User[81]:=false;

  ControlReestr^.GetData(C);
  WordToBit11(C,M11);
  Convert11(m11);
  for i:=0 to 10 do if m11[i+1]=1 then OperatorElement.User[i+82]:=true
    else OperatorElement.User[i+82]:=false;

 AddDopOperator:=true;
 End;
end;

  C:=IOResult;
  Assign(OperatorFile,Path.ToOperator+'System.db');
  Reset(OperatorFile);
  C:=IOResult;
  If C<>0 Then
   Begin
    MessageBox(^M+#3'�訡�� ����㯠 � 䠩�� ॥���!',nil,mfError+mfCancelButton);
    AddDopOperator:=False;
    Dispose(ControlPost,Done);
    Dispose(ControlClient,Done);
    Dispose(ControlPazdel,Done);
    Dispose(ControlOther,Done);
    Dispose(ControlDlg,Done);
    Dispose(ControlBart,Done);
    Dispose(ControlTov,Done);
    Dispose(ControlMoveTov,Done);
    Dispose(ControlPersonal,Done);
    Dispose(ControlReestr,Done);
    Dispose(Control,Done);
    Dispose(Dlg,Done);
    Goto 1;
   End;

   UpStr(OperatorElement.Name);
   OperatorElement.Employ:=True;

   AddProtocol('���४�஢�� ������ ������:'+OperatorElement.Name+' ('+s+')','','');
   OperatorElement.Kod:=s;
   OperatorElement.Password:=Code(OperatorElement.Password);
   Seek(OperatorFile,GetFileLocation3(s){-1});
   Write(OperatorFile,OperatorElement);
   Close(OperatorFile);
   AddDopOperator:=True;

  Dispose(ControlPOst,Done);
  Dispose(ControlClient,Done);
  Dispose(ControlPazdel,Done);
  Dispose(ControlOther,Done);
  Dispose(ControlDlg,Done);
  Dispose(ControlBart,Done);
  Dispose(ControlTov,Done);
  Dispose(ControlMoveTov,Done);
  Dispose(ControlPersonal,Done);
  Dispose(ControlReestr,Done);
  Dispose(Control,Done);
  Dispose(Dlg,Done);


End;

Function AddOperator( Cod:Integer; Var OperatorElement: TSystemReestr):Boolean;
Label 1;
var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  ControlUser1,ControlUser2,ControlUser3,ControlUser4: PView;
  s : TEnjoyStr;
  M : Maska16;
  m7: Maska7;
  c,i: Word;
begin

ClearFind;
If Not(TestOpenDate1(FDate)) Then
   Begin
    MessageBox(#3^M+#3'����� � ����� �� '+FDate+' �������஢��!',Nil,mfError+mfCancelButton);
    AddOperator:=False;
    Exit;
   End;
C:=IOResult;
AddOperator:=False;
Assign(OperatorFile,Path.ToOperator+'System.db');
Reset(OperatorFile);
C:=IOResult;
If C<>0 Then
Begin
 MessageBox(^M+#3'�訡�� ����㯠 � 䠩�� ॥���!',nil,mfError+mfCancelButton);
 AddOperator:=False;
 Exit;
End;
 Case Cod Of
  kbGrayPlus:Begin
     OperatorElement.Employ:=True;
     While Not(Eof(OperatorFile)) And (OperatorElement.Employ) Do
     Read(OperatorFile,OperatorElement);
     If Eof(OperatorFile) And (OperatorElement.Employ) Then
      Begin
       MessageBox(^M+#3'��������� ����権 ��� �����஢ - ��� !',nil,mfWarning+mfCancelButton);
       Close(OperatorFile);
       AddOperator:=False;
       Exit;
      End;
      s:=OperatorElement.Kod;
      OperatorElement.Password[0]:=#0;
      OperatorElement.Name[0]    :=#0;
    End;
  kbF4:Begin
     s:=Copy(Operator^.GetText(Operator^.Focused,Operator^.List^.Count),1+CKto+1,CRazdelKod);
     Repeat
     Read(OperatorFile,OperatorElement);
     Until (Eof(OperatorFile)) Or (OperatorElement.Kod=s);
     OperatorElement.Password:=DeCode(OperatorElement.Password);
     If Eof(OperatorFile) And (OperatorElement.Kod<>s) Then
      Begin
       MessageBox(^M+#3'������ � ॥��� �� ������!',nil,mfError+mfCancelButton);
       Close(OperatorFile);
       AddOperator:=False;
       Exit;
      End;
    End;
  Else;
 End;
Close(OperatorFile);
1:
If Cod=kbGrayPlus Then
Begin
R.Assign(21, 6, 58, 17);
New(Dlg, Init(R, '�������� ������'))
End
Else
Begin
R.Assign(0, 0, 79, 23);
New(Dlg, Init(R, '�������� ������'));
End;
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.Palette := dpCyanDialog;
Dlg^.HelpCtx:=$E011;

R.Assign(3, 3, 17, 4);
Control := New(PInputLine, Init(R, 12));
Dlg^.Insert(Control);

   R.Assign(2, 2, 17, 3);
  Dlg^.Insert(New(PLabel, Init(R, '��� ������:', Control)));

R.Assign(21, 3, 33, 4);
Control := New(PInputLine, Init(R, 10));
Dlg^.Insert(Control);

  R.Assign(20, 2, 28, 3);
  Dlg^.Insert(New(PLabel, Init(R, '��஫�:', Control)));

Dlg^.SetData(OperatorElement);
AInfo('���� ���ଠ�� �� �������...');
If Cod = kbGrayPlus  Then
Begin
R.Assign(35, 6, 36, 10);
Control := New(PScrollBar, Init(R));
Dlg^.Insert(Control);

R.Assign(1, 6, 35, 10);
OperatorNum := New(PBox, Init(R, 6, PScrollbar(Control)));
 OperatorNum^.NewList(New(PTextCollection, Init(0,1)));
 Assign (OperatorFile,Path.ToOperator+'System.db');
 Reset (OperatorFile);
 While Not(Eof(OperatorFile)) Do
  Begin
   Read(OperatorFile,OperatorElement);
   If Not(OperatorElement.Employ) Then
   Begin
   OperatorNum^.List^.Insert(NewStr('�'+OperatorElement.Kod));
   OperatorNum^.SetRange(OperatorNum^.List^.Count);
   OperatorNum^.FocusItem(OperatorNum^.List^.Count);
   End;
  End;
 System.Close(OperatorFile);
 If Cod=kbF4 Then OperatorNum^.FocusItem(LoCation(OperatorNum,s,ProdagaWindow))
 Else OperatorNum^.FocusItem(0);
 OperatorNum^.HelpCtx:=$E011;

Dlg^.Insert(OperatorNum);

  R.Assign(1, 5, 31, 6);
  Dlg^.Insert(New(PLabel, Init(R, '����㯭� ���� ��� ������:', OperatorNum)));

 End
else
begin
  R.Assign(1, 4, 26, 19);
  ControlUser1 := New(PCheckboxes, Init(R,
  NewSItem('��室� (�� ᪫��)',         {0}
  NewSItem('���㧪� (�� ᪫���)',       {1}
  NewSItem('����� ���ᨣ�����',         {2}
  NewSItem('����� �����������',         {3}
  NewSItem('(?) �������� ⮢��',        {4}
  NewSItem('(?) ������ �த��',          {5}
  NewSItem('(?) �த��� � ��室�',      {6}
  NewSItem('(?) ������஢��',           {7}
  NewSItem('(?) ���⠢騪�',             {8}
  NewSItem('(?) ���ᮭ��쭮',            {9}
  NewSItem('(?) �롮ઠ',                {10}
  NewSItem('(?) �롮�.����������',      {11}
  NewSItem('(?) ����� ���ᨣ��樨',     {12}
  NewSItem('(?) ����� �� ����⠬',      {13}
  NewSItem('(?) �������',               {14}
  Nil)))))))))))))))));
  Dlg^.Insert(ControlUser1);

  for i:=0 to 14 do
  if OperatorElement.User[i] then m[i+1]:=1
     else m[i+1]:=0;

  Convert16(m);
  BitToWord16(M,C);
  ControlUser1^.SetData(C);

  R.Assign(26, 4, 53, 19);
  ControlUser2 := New(PCheckboxes, Init(R,
  NewSItem('(?) ��壠���',              {15}
  NewSItem('������ ���㧪�',            {16}
  NewSItem('������ ��室�',             {17}
  NewSItem('������ �������',             {18}
  NewSItem('������ ����',               {19}
  NewSItem('������ �����⮢',           {20}
  NewSItem('��ᬮ����',                {21}
  NewSItem('���४�஢���',             {22}
  NewSItem('������',                   {23}
  NewSItem('������ ���� ᪫���',       {24}
  NewSItem('����稥 �� ᪫���',          {25}
  NewSItem('��娢 ������',              {26}
  NewSItem('�ࠩ�-����',                 {27}
  NewSItem('����஫�� ���ᮢ� ����',  {28}
  NewSItem('�����.�������-��������',     {29}
  Nil)))))))))))))))));
  Dlg^.Insert(ControlUser2);

  for i:=0 to 14 do
  if OperatorElement.User[i+15] then m[i+1]:=1
     else m[i+1]:=0;

  Convert16(m);
  BitToWord16(M,C);
  ControlUser2^.SetData(C);


  R.Assign(53, 4, 77, 19);
  ControlUser3 := New(PCheckboxes, Init(R,
  NewSItem('��壠���',            {30}
  NewSItem('��壠��� 2',          {31}
  NewSItem('����� ���ᨣ��樨',    {32}
  NewSItem('����� �����஢',       {33}
  NewSItem('����� �� ����⠬',      {34}
  NewSItem('���� ������',       {35}
  NewSItem('�⮣.�����������',     {36}
  NewSItem('������ � ���⠢騪���',{37}
  NewSItem('�����஢���� ���⥦��', {38}
  NewSItem('��⮪��',              {39}
  NewSItem('��८業�� ⮢��',     {40}
  NewSItem('���४�஢��� ᪫��',  {41}
  NewSItem('������� �� ᪫���',     {42}
  NewSItem('�⮣� ���',             {43}
  NewSItem('��ࢨ�-���䨣����',   {44}
  Nil)))))))))))))))));
  Dlg^.Insert(ControlUser3);

  for i:=0 to 14 do
  if OperatorElement.User[i+30] then m[i+1]:=1
     else m[i+1]:=0;

  Convert16(m);
  BitToWord16(M,C);
  ControlUser3^.SetData(C);


R.Assign(1, 19, 77, 22);
ControlUser4 := New(PCheckboxes, Init(R,
  NewSItem('���.���.�� ����⠬',    {45}
  NewSItem('����� ॢ����',             {46}
  NewSItem('�������⥫쭮',             {47}
  NewSItem('�����.��६�饭��',    {48}
  NewSItem('�����஢��� ����',          {49}
  NewSItem('�������஢��� ����',        {50}
  NewSItem('��⠫쭮 �� ࠧ�����',        {93}
  Nil)))))))));
Dlg^.Insert(ControlUser4);

  for i:=0 to 5 do
  begin
  if  OperatorElement.User[i+45] then m7[i+1]:=1
  else m7[i+1]:=0;
  end;

  if (OperatorElement.User[93]) then m7[7]:=1
  else
  m7[7]:=0;

  Convert7(m7);
  BitToWord7(M7,C);
  ControlUser4^.SetData(C);

Dlg^.Insert(Control);

end;
If Cod=kbF4 Then
 Begin
R.Assign(19, 1, 33, 2);
Control := New(PColoredText, Init(R, '��� ������:', $3E));
Dlg^.Insert(Control);
  R.Assign(33, 1, 35, 2);
  Control := New(PColoredText, Init(R, OperatorElement.Kod, $3E));
  Dlg^.Insert(Control);
 End;

Dlg^.SelectNext(False);
Noinfo;
c:=Desktop^.ExecView(Dlg);
If c<>cmCancel Then
 Begin
  Dlg^.GetData(OperatorElement);
{����������� � �������.....}
If Cod=kbF4 Then
begin
 ControlUser1^.GetData(C);
 WordToBit16(C,M);
 Convert16(m);
 for i:=0 to 14 do if m[i+1]=1 then OperatorElement.User[i]:=true
    else OperatorElement.User[i]:=false;

 ControlUser2^.GetData(C);
 WordToBit16(C,M);
 Convert16(m);
 for i:=0 to 14 do if m[i+1]=1 then OperatorElement.User[i+15]:=true
    else OperatorElement.User[i+15]:=false;

 ControlUser3^.GetData(C);
 WordToBit16(C,M);
 Convert16(m);
 for i:=0 to 14 do if m[i+1]=1 then OperatorElement.User[i+30]:=true
    else OperatorElement.User[i+30]:=false;

 ControlUser4^.GetData(C);
 WordToBit7(C,M7);
 Convert7(m7);
 for i:=0 to 5 do if m7[i+1]=1 then
    OperatorElement.User[i+45]:=true
    else
    OperatorElement.User[i+45]:=false;
  if m7[7]=1 then OperatorElement.User[93]:=true
   else OperatorElement.User[93]:=false;
end;

  DElSpaceRight(OperatorElement.Name);
    If OperatorElement.Name[0]=#0 Then
   Begin
    MessageBox(^M+#3'�������⨬�� ��� ������!',nil,mfError+mfCancelButton);
If Cod=kbGrayPlus Then
  Begin
   s:=OperatorNum^.GetText(OperatorNum^.Focused,OperatorNum^.List^.Count);
   s:=Copy(s,1+CKto+1,CRazdelKod);
  OperatorNum^.NewList(Nil);
  Dispose(OperatorNum,Done);
  End;
  Dispose(Control,Done);
  Dispose(Dlg,Done);
    Goto 1;
   End;
  DElSpaceRight(OperatorElement.Password);
    If OperatorElement.Password[0]=#0 Then
   Begin
    MessageBox(^M+#3'�������⨬� ��஫� ������!',nil,mfError+mfCancelButton);
If Cod=kbGrayPlus Then
  Begin
   s:=OperatorNum^.GetText(OperatorNum^.Focused,OperatorNum^.List^.Count);
   s:=Copy(s,1+CKto+1,CRazdelKod);
  OperatorNum^.NewList(Nil);
  Dispose(OperatorNum,Done);
  End;

  Dispose(ControlUser1,Done);
  Dispose(ControlUser2,Done);
  Dispose(ControlUser3,Done);
  Dispose(Control,Done);
  Dispose(Dlg,Done);
    Goto 1;
   End;
  C:=IOResult;
  Assign(OperatorFile,Path.ToOperator+'System.db');
  Reset(OperatorFile);
  C:=IOResult;
  If C<>0 Then
   Begin
    MessageBox(^M+#3'�訡�� ����㯠 � 䠩�� ॥���!',nil,mfError+mfCancelButton);
    AddOperator:=False;
If Cod=kbGrayPlus Then
  Begin
   s:=OperatorNum^.GetText(OperatorNum^.Focused,OperatorNum^.List^.Count);
   s:=Copy(s,1+CKto+1,CRazdelKod);
  OperatorNum^.NewList(Nil);
  Dispose(OperatorNum,Done);
  End;
  Dispose(Control,Done);
  Dispose(Dlg,Done);
    Goto 1;
   End;
   UpStr(OperatorElement.Name);
   OperatorElement.Employ:=True;

If Cod=kbGrayPlus Then
  Begin
   s:=OperatorNum^.GetText(OperatorNum^.Focused,OperatorNum^.List^.Count);
   s:=Copy(s,1+1,CRazdelKod);
   AddProtocol('���������� ������ ������:'+OperatorElement.Name+' ('+s+')','','');
  End
  Else
   AddProtocol('���४�஢�� ������ ������:'+OperatorElement.Name+' ('+s+')','','');
   OperatorElement.Kod:=s;
   OperatorElement.Password:=Code(OperatorElement.Password);
   Seek(OperatorFile,GetFileLocation3(s){-1});
   Write(OperatorFile,OperatorElement);
   Close(OperatorFile);
   AddOperator:=True;
 End;
If Cod=kbGrayPlus Then
  Begin
  OperatorNum^.NewList(Nil);
  Dispose(OperatorNum,Done);
  End;
  Dispose(Control,Done);
  Dispose(Dlg,Done);
end;




end.