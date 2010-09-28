{*
*
*   Copyright (c) 1992,93 by Richard W. Hansen
*
*
*}
UNIT TvObject;
{$B+}
{$X+}
{$V-}

{$I TVDEFS.INC}

INTERFACE


USES
  TvString,
  Objects;


TYPE
  PbxObject = ^TbxObject;
  TbxObject = Object(TObject)
    Function    GetText(MaxLen : Integer): String;        Virtual;
  end;


  PbxSelectObject = ^TbxSelectObject;
  TbxSelectObject = Object(TbxObject)
    Selected : Boolean;

    Constructor Load(var S: TStream);
    Function    GetSelect: Boolean;                       Virtual;
    Procedure   SetSelect(AState : Boolean);              Virtual;
    Procedure   Store(var S: TStream);
  end;


  PbxSelectStr = ^TbxSelectStr;
  TbxSelectStr = Object(TbxSelectObject)
    St : PString;
    Constructor Init (const AString : String);
    Constructor Load(var S: TStream);
    Destructor  Done;                                     Virtual;
    Function    GetText(MaxLen : Integer): String;        Virtual;
    Procedure   Store(var S: TStream);
  end;


  PbxCollection = ^TbxCollection;
  TbxCollection = Object(TSortedCollection)
    Function Compare(Key1, Key2 : Pointer): Integer;      Virtual;
  end;


  PbxUnsortedStringCollection  = ^TbxUnsortedStringCollection;
  TbxUnsortedStringCollection  = Object(TStringCollection)
    Procedure   Insert(Item : Pointer);                 Virtual;
  end;


{ TvObject registration procedure }

Procedure RegisterTVObject;


{ Stream Registration Records }

CONST
  RbxSelectObject: TStreamRec = (
    ObjType : 5150;
    VmtLink : Ofs(TypeOf(TbxSelectObject)^);
    Load    : @TbxSelectObject.Load;
    Store   : @TbxSelectObject.Store
  );

CONST
  RbxSelectStr: TStreamRec = (
    ObjType : 5151;
    VmtLink : Ofs(TypeOf(TbxSelectStr)^);
    Load    : @TbxSelectStr.Load;
    Store   : @TbxSelectStr.Store
  );

CONST
  RbxCollection: TStreamRec = (
    ObjType : 5152;
    VmtLink : Ofs(TypeOf(TbxCollection)^);
    Load    : @TbxCollection.Load;
    Store   : @TbxCollection.Store
  );

CONST
  RbxUnsortedStringCollection: TStreamRec = (
    ObjType : 5153;
    VmtLink : Ofs(TypeOf(TbxUnsortedStringCollection)^);
    Load    : @TbxUnsortedStringCollection.Load;
    Store   : @TbxUnsortedStringCollection.Store
  );

implementation

function TbxObject.GetText(MaxLen: Integer): string;
begin
  RunError(211);
end;

constructor TbxSelectObject.Load(var S: TStream);
begin
  S.Read(Selected, SizeOf(Boolean));
end;

function TbxSelectObject.GetSelect: Boolean;
begin
  GetSelect := Selected;
end;

procedure TbxSelectObject.SetSelect(AState: Boolean);
begin
  Selected := AState;
end;

procedure TbxSelectObject.Store(var S: TStream);
begin
  S.Write(Selected, SizeOf(Boolean));
end;

constructor TbxSelectStr.Init(const AString: string);
begin
  inherited Init;
  St := NewStr(AString);
end;

constructor TbxSelectStr.Load(var S: TStream);
begin
  inherited Load(S);
  St := S.ReadStr;
end;

destructor TbxSelectStr.Done;
begin
  DisposeStr(St);
  inherited Done;
end;

function TbxSelectStr.GetText(MaxLen: Integer): string;
begin
  GetText := {FTruncateStr(}St^{, MaxLen)};
end;

procedure TbxSelectStr.Store(var S: TStream);
begin
  inherited Store(S);
  S.WriteStr(St);
end;

function TbxCollection.Compare(Key1, Key2: Pointer): Integer;
var
  Text1: string;
  Text2: string;
begin
  Text1 := PbxObject(Key1)^.GetText(255);
  Text2 := PbxObject(Key2)^.GetText(255);
  if (Text1 < Text2) then Compare := -1
  else if (Text1 > Text2) then Compare := 1
  else Compare := 0;
end;

procedure TbxUnsortedStringCollection.Insert(Item: Pointer);
begin
  AtInsert(Count, Item);
end;

procedure RegisterTvObject;
begin
  RegisterType(RbxSelectObject);
  RegisterType(RbxSelectStr);
  RegisterType(RbxCollection);
  RegisterType(RbxUnsortedStringCollection);
end;

end.
