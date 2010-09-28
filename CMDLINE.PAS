{F+,X+,O+}

unit CmdLine;

interface

uses Objects;

type

 PCmdLine = ^TCmdLine;
 TCmdLine = object(TObject)
  Params  : PStringCollection;
  constructor Init;
  function    Count: integer;
  function    Present(AParam: string): boolean;
  function    At(Item: integer): string;
  destructor  Done; virtual;
 end;

implementation

 function UpStr(AStr: string): string;
  var i: byte;
  begin
   for i:=1 to Length(AStr) do
    AStr[i]:=UpCase(AStr[i]);
   UpStr:=AStr;
  end;

 constructor TCmdLine.Init;
  var
   i: integer;
   s: string;
  begin
   TObject.Init;
   Params:=New(PStringCollection, Init(3,1));
   for i:=1 to ParamCount do
    begin
     S:=UpStr(ParamStr(i));
     if S[1] in ['/','-'] then
      begin
       Move(S[2], S[1], byte(S[0]) - 1);
       Dec(byte(S[0]));
      end;
     Params^.Insert(NewStr(S));
    end;
  end;

 destructor TCmdLine.Done;
  begin
   Dispose(Params, Done);
   TObject.Done;
  end;

 function TCmdLine.Count: integer;
  begin
   Count:=Params^.Count;
  end;

 function TCmdLine.At(Item: integer): string;
  begin
   At:='';
   if Item >= Params^.Count then Exit;
   At:=PString(Params^.At(Item))^;
  end;

 function TCmdLine.Present(AParam: string): boolean;
  var Dummy: integer;
  begin
   Present:=Params^.Search(@AParam, Dummy);
  end;

end.
