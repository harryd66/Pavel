{$N+,E+}
UNIT Stringer;
{ ࠡ�� � ��ப��� }
INTERFACE

TYPE
  Numeric = Extended;

FUNCTION Str2 (i :word):String; { �८�ࠧ����� 2-���筮� 楫�� � ��ப� }
FUNCTION GetSubString (S:String; i,j:word):String; { �뤥����� �����ப� }
FUNCTION StringToNumeric (S:String):Numeric; { ��ॢ�� ��ப� � �᫮ }
FUNCTION DeleteSpacesAndRems (S:String):String; { 㤠���� �� ��ப� �� �஡��� � ��१��� �������ਨ }
FUNCTION UpString (S:String):String; { ��ॢ�� �ᥩ ��ப� � ���孨� ॣ���� }

IMPLEMENTATION

FUNCTION Str2 (i :word):String;
VAR
  S:String [2];
BEGIN
  S := '';
  if i < 99 then Str (i:2,S);
  if S[1] = ' ' then S[1] := '0';
  Str2 := S;
END;

FUNCTION GetSubString (S:String; i,j:word):String;
{ ����� �����ப� �� ��ப� S �� i-�� ᨬ���� �� j-�� �����⥫쭮 }
VAR
  St :String; { �६����� ��ப� }
  k  :word;   { ������ }
BEGIN
  St := '';
  if i <= length (S) then
  { �᫨ ��ப� �� ������� ����襣� ������ }
  begin
    { �᫨ ���訩 ������ ����� ������ ��ப�, 㬥����� ��� }
    if j > length (S) then j := length (S);
    { �����㥬 ���� ��ப� }
    for k := i to j do St := St + S[k];
  end;
  { �����頥� १���� }
  GetSubString := St;
END;

FUNCTION DeleteSpacesAndRems (S:String):String;
{ 㤠���� �� ��ப� �� �஡��� � ��१��� �������ਨ }
VAR
  i  :word;    { ������ }
  St :String;  { �६����� ��ப� }
BEGIN
  St := '';
  { ��ॡ�� ��� ᨬ����� ��ப� }
  for i := 1 to length (S) do
  begin
    { �᫨ ����祭 ᨬ��� ';' � ����� ���� �������਩ }
    if S[i] = ';' then Break;
    { �᫨ �� �஡��, �������� ᨬ��� }
    if S[i] <> ' ' then St := St + S[i];
  end;
  { ������ १���� }
  DeleteSpacesAndRems := St;
END;

FUNCTION StringToNumeric (S:String):Numeric;
{ ��ॢ�� ��ப� � �᫮ }
VAR
  N ,R :Numeric;  { �६���� ��६���� }
  i :word;        { ������ }
  d: byte;        { ⥪��� ��� }
  flag : boolean; { 䫠� �� ��� ��᫥ �窨 }
BEGIN
  N := 0;
  R := 0.1;
  flag := false;  { �� �窨 }
  for i := 1 to length (S) do
  { ��ॡ�� ᢥ� ᨬ����� }
  begin
    if S[i] = ' ' then continue;
    { �஡��� �ய�᪠�� }
    if S[i] = '.' then
    begin
      flag := true;
      continue;
    end;
    { �᫨ �窠 - ��⠭�������� 䫠� }
    if S[i] in ['0'..'9'] then d := Ord (S[i]) - Ord ('0');
    { �᫨ ���, 㧭��� �� ���祭�� }
    if flag then
    begin
      { ��᫥ ����⮩ }
      N := N + R * d;
      { 㬥��蠥� ��� ���� }
      R := R * 0.1;
    end
    else
      N := N * 10 + d;  { ������塞 �� ���� ���� }
  end;
  StringToNumeric := N;
END;

FUNCTION UpString (S:String):String;
{ ��ॢ�� �ᥩ ��ப� � ���孨� ॣ���� }
VAR
  St :String;
  i :word;
BEGIN
  St := '';
  for i := 1 to length (S) do St[i] := UpCase (S[i]);
  St[0] := S[0];
  UpString := St;
END;

END.