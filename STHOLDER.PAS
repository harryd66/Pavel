UNIT StHolder;
{ модуль для хранения строк по их именам }
INTERFACE

TYPE

  String16 = String[30];
  String80 = String[180];

  PStringNode = ^TStringNode;
  TStringNode = RECORD        { узел списка строк }
    Name    :String16;        { имя строки }
    Content :String80;        { содержимое }
    Next    :PStringNode;     { указатель на следующий элемент }
  END;

  PStringHolder = ^TStringHolder;
  TStringHolder = OBJECT       { объект-хранитель строк }
    OkOp          : Boolean;
    CONSTRUCTOR   Init;        { конструктор }
    DESTRUCTOR    Done;        { деструктор }
    PROCEDURE     LoadFromFile (FileName :String); { загрузка массива строк из файла }
    PROCEDURE     AddString (Name:String16; Content:String80); { добавить строку }
    PROCEDURE     SetString (Name:String16; Content:String80); { установить значение }
    FUNCTION      GetString (Name:String16):String80; { получить строку }
    FUNCTION      IsOk: boolean; { все ли хорошо }
  PRIVATE
    StringList   :PStringNode; { список строк }
    status       :boolean; { статус операции }
  END;

IMPLEMENTATION

USES Stringer,ServStr;

CONSTRUCTOR TStringHolder.Init;
{ конструктор }
BEGIN
  { список еще пустой }
  StringList := nil;
  status := true;
  OkOp:=False;

END;

DESTRUCTOR TStringHolder.Done;
{ деструктор }
VAR
  CS, NS :PStringNode;
BEGIN
  { удаляем список строк }
  CS := StringList;
  while Assigned (CS) do
  begin
    NS := CS^.Next;
    Dispose (CS);
    CS := NS;
  end;
END;

PROCEDURE TStringHolder.AddString (Name:String16; Content:String80);
{ добавить строку }
VAR
  CS, LS :PStringNode;
BEGIN
  status := false;
  New (CS);
  { если удалось распределить память }
  if Assigned (CS) then
  begin
    CS^.Name := Name;
    CS^.Content := Content;
    CS^.Next := nil;
    { дописываем в конец списка }
    if Assigned (StringList) then
    begin
      { ищем конец списка }
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
{ установить значение строки }
VAR
  CS :PStringNode;
BEGIN
  CS := StringList;
  while Assigned (CS) do
  { ищем строку }
  begin
    if CS^.Name = Name then
    { нашли }
    begin
      CS^.Content := Content;
      Exit;
    end
    else CS := CS^.Next;
  end;
END;

FUNCTION TStringHolder.GetString (Name:String16):String80;
{ получить значение строки }
VAR
  CS :PStringNode;
BEGIN
  GetString := '';
  OkOp:=False;
  CS := StringList;
  Name:=UpCases(NAme);
  while Assigned (CS) do
  { ищем строку }
  begin
    if CS^.Name = Name then
    { нашли }
    begin
      OkOp:=True;
      GetString := CS^.Content;
      Exit;
    end
    else CS := CS^.Next;
  end;

END;


PROCEDURE TStringHolder.LoadFromFile (FileName :String);
{ загрузка массива строк из файла }
VAR
  F :Text;    { файловый обработчик }
  S :String;
  c,i :word;
  S16 :String;
BEGIN
  status := false;
  Assign (F, FileName);
  Reset (F);
  { пытаемся открыть файл }
  if IOResult <> 0 then Exit;
  while not EOF (F) do
  { читаем файл полностью }
  begin
    Readln (F, S);
    { прочесть строку }
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
    { пустые строки и строки, которые начинаются с ; или rem игнорируем }
    for i := 1 to length (S) do
    { разбор строки }
    begin
      if S[i] = '=' then
      { ищем символ = }
      begin
        S16 := GetSubString (S, 1, i-1);
        { до = идет имя переменной-строки }
        S := GetSubString (S, i+1, length (S));
        { после = идет содержимое строки }
        if length (S16) > (sizeof (String16) - 1) then S16 := GetSubString (S16, 1, 25);
        s16:=UpCAses(s16);
        AddString (S16, S);
        { добавляем строку в список }
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