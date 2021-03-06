UNIT StHolder;
{ ����� ��� �࠭���� ��ப �� �� ������ }
INTERFACE

TYPE

  String16 = String[30];
  String80 = String[180];

  PStringNode = ^TStringNode;
  TStringNode = RECORD        { 㧥� ᯨ᪠ ��ப }
    Name    :String16;        { ��� ��ப� }
    Content :String80;        { ᮤ�ন��� }
    Next    :PStringNode;     { 㪠��⥫� �� ᫥���騩 ������� }
  END;

  PStringHolder = ^TStringHolder;
  TStringHolder = OBJECT       { ��ꥪ�-�࠭�⥫� ��ப }
    OkOp          : Boolean;
    CONSTRUCTOR   Init;        { ��������� }
    DESTRUCTOR    Done;        { �������� }
    PROCEDURE     LoadFromFile (FileName :String); { ����㧪� ���ᨢ� ��ப �� 䠩�� }
    PROCEDURE     AddString (Name:String16; Content:String80); { �������� ��ப� }
    PROCEDURE     SetString (Name:String16; Content:String80); { ��⠭����� ���祭�� }
    FUNCTION      GetString (Name:String16):String80; { ������� ��ப� }
    FUNCTION      IsOk: boolean; { �� �� ��� }
  PRIVATE
    StringList   :PStringNode; { ᯨ᮪ ��ப }
    status       :boolean; { ����� ����樨 }
  END;

IMPLEMENTATION

USES Stringer,ServStr;

CONSTRUCTOR TStringHolder.Init;
{ ��������� }
BEGIN
  { ᯨ᮪ �� ���⮩ }
  StringList := nil;
  status := true;
  OkOp:=False;

END;

DESTRUCTOR TStringHolder.Done;
{ �������� }
VAR
  CS, NS :PStringNode;
BEGIN
  { 㤠�塞 ᯨ᮪ ��ப }
  CS := StringList;
  while Assigned (CS) do
  begin
    NS := CS^.Next;
    Dispose (CS);
    CS := NS;
  end;
END;

PROCEDURE TStringHolder.AddString (Name:String16; Content:String80);
{ �������� ��ப� }
VAR
  CS, LS :PStringNode;
BEGIN
  status := false;
  New (CS);
  { �᫨ 㤠���� ��।����� ������ }
  if Assigned (CS) then
  begin
    CS^.Name := Name;
    CS^.Content := Content;
    CS^.Next := nil;
    { �����뢠�� � ����� ᯨ᪠ }
    if Assigned (StringList) then
    begin
      { �饬 ����� ᯨ᪠ }
      LS := StringList;
      while Assigned (LS^.Next) do
        LS := LS^.Next;
      LS^.Next := CS;
    end
    else StringList := CS;
  end
  else Exit;
  status := true;
END;

PROCEDURE TStringHolder.SetString (Name:String16; Content:String80);
{ ��⠭����� ���祭�� ��ப� }
VAR
  CS :PStringNode;
BEGIN
  CS := StringList;
  while Assigned (CS) do
  { �饬 ��ப� }
  begin
    if CS^.Name = Name then
    { ��諨 }
    begin
      CS^.Content := Content;
      Exit;
    end
    else CS := CS^.Next;
  end;
END;

FUNCTION TStringHolder.GetString (Name:String16):String80;
{ ������� ���祭�� ��ப� }
VAR
  CS :PStringNode;
BEGIN
  GetString := '';
  OkOp:=False;
  CS := StringList;
  Name:=UpCases(NAme);
  while Assigned (CS) do
  { �饬 ��ப� }
  begin
    if CS^.Name = Name then
    { ��諨 }
    begin
      OkOp:=True;
      GetString := CS^.Content;
      Exit;
    end
    else CS := CS^.Next;
  end;

END;


PROCEDURE TStringHolder.LoadFromFile (FileName :String);
{ ����㧪� ���ᨢ� ��ப �� 䠩�� }
VAR
  F :Text;    { 䠩���� ��ࠡ��稪 }
  S :String;
  c,i :word;
  S16 :String;
BEGIN
  status := false;
  Assign (F, FileName);
  Reset (F);
  { ��⠥��� ������ 䠩� }
  if IOResult <> 0 then Exit;
  while not EOF (F) do
  { �⠥� 䠩� ��������� }
  begin
    Readln (F, S);
    { ������ ��ப� }
    if IOResult <> 0 then
    begin
      Close (F);
      Exit;
    end;
    if S[1] = ';' then Continue;
    DelSpaceRight(s);
    If Pos(UpCAses('REM'),S)=1 Then Continue;

    if S[1] = ';' then Continue;

    if S = '' then Continue;
    { ����� ��ப� � ��ப�, ����� ��稭����� � ; ��� rem ������㥬 }
    for i := 1 to length (S) do
    { ࠧ��� ��ப� }
    begin
      if S[i] = '=' then
      { �饬 ᨬ��� = }
      begin
        S16 := GetSubString (S, 1, i-1);
        { �� = ���� ��� ��६�����-��ப� }
        S := GetSubString (S, i+1, length (S));
        { ��᫥ = ���� ᮤ�ন��� ��ப� }
        if length (S16) > (sizeof (String16) - 1) then S16 := GetSubString (S16, 1, 25);
        s16:=UpCAses(s16);
        AddString (S16, S);
        { ������塞 ��ப� � ᯨ᮪ }
        if not status then
        begin
          c:=ioresult;
          Close (F);
          c:=ioresult;
          Exit;
        end;
        Continue;
      end;
    end;
  end;
  c:=ioresult;
  Close (F);
  c:=ioresult;
  status := true;
END;


FUNCTION TStringHolder.IsOk:boolean;
BEGIN
  IsOk := status;
END;

END.