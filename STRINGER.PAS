{$N+,E+}
UNIT Stringer;
{ работа со строками }
INTERFACE

TYPE
  Numeric = Extended;

FUNCTION Str2 (i :word):String; { преобразовать 2-значное целое в строку }
FUNCTION GetSubString (S:String; i,j:word):String; { выделение подстроки }
FUNCTION StringToNumeric (S:String):Numeric; { перевод строки в число }
FUNCTION DeleteSpacesAndRems (S:String):String; { удалить из строки все пробелы и отрезать комментарии }
FUNCTION UpString (S:String):String; { перевод всей строки в верхний регистр }

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
{ выбрать подстроку из строки S от i-го символа до j-го включительно }
VAR
  St :String; { временная строка }
  k  :word;   { индекс }
BEGIN
  St := '';
  if i <= length (S) then
  { если строка не длиннее младшего индекса }
  begin
    { если старший индекс больше длинны строки, уменьшить его }
    if j > length (S) then j := length (S);
    { копируем часть строки }
    for k := i to j do St := St + S[k];
  end;
  { возвращаем результат }
  GetSubString := St;
END;

FUNCTION DeleteSpacesAndRems (S:String):String;
{ удалить из строки все пробелы и отрезать комментарии }
VAR
  i  :word;    { индекс }
  St :String;  { временная строка }
BEGIN
  St := '';
  { перебор всех символов строки }
  for i := 1 to length (S) do
  begin
    { если встречен символ ';' то дальше идет комментарий }
    if S[i] = ';' then Break;
    { если на пробел, добавить символ }
    if S[i] <> ' ' then St := St + S[i];
  end;
  { вернуть результат }
  DeleteSpacesAndRems := St;
END;

FUNCTION StringToNumeric (S:String):Numeric;
{ перевод строки в число }
VAR
  N ,R :Numeric;  { временные переменные }
  i :word;        { индекс }
  d: byte;        { текущая цифра }
  flag : boolean; { флаг до или после точки }
BEGIN
  N := 0;
  R := 0.1;
  flag := false;  { до точки }
  for i := 1 to length (S) do
  { перебор свех символов }
  begin
    if S[i] = ' ' then continue;
    { пробелы пропускаем }
    if S[i] = '.' then
    begin
      flag := true;
      continue;
    end;
    { если точка - устанавливаем флаг }
    if S[i] in ['0'..'9'] then d := Ord (S[i]) - Ord ('0');
    { если цифра, узнаем ее значение }
    if flag then
    begin
      { после запятой }
      N := N + R * d;
      { уменьшаем вес цифры }
      R := R * 0.1;
    end
    else
      N := N * 10 + d;  { добавляем еще одну цифру }
  end;
  StringToNumeric := N;
END;

FUNCTION UpString (S:String):String;
{ перевод всей строки в верхний регистр }
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