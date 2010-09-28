
unit DBWatch;

interface

uses Objects,Dos,ServStr;

type
     PFieldRec = ^Fieldrec;
     FieldRec = record
      Name: String[10];
      Who: Char;
      Ln: Word;
      Len, Dec: Word;
      Pos: Word;
     end;

     PFieldCollection = ^TFieldCollection;
     TFieldCollection = object(TCollection)
      procedure FreeItem( P : Pointer); virtual;
     end;

     PDBFile = ^TDBFile;
     TDBFile = object(TObject)
      WriteMode: Byte;
      BaseName: PathStr;
      BaseFile: TBufStream;
      Date, NumRec: LongInt;
      HeaderLen, RecLen: Word;
      Unused: Array [0..31] of Byte;
      NumFields: Integer;
      Loc: LongInt;
      Fields: PCollection;
      constructor Init(FileName : PathStr);
      destructor Done; virtual;
      procedure Read(var Buf; Num: Word);
      procedure Seek(NewLoc: LongInt);
      function  GetField(Name: String;var Buf) : String;
      Procedure GetNField(N: Word;var s:String; var Buf);
      function  GetFieldRec(N : Integer) : PFieldRec;
      procedure OpenMode(Mode: Word);
     end;

implementation

procedure TFieldCollection.FreeItem;
begin
 Dispose(PFieldRec(P));
end;

function NewField(Name: String; Who: Char; Len, Dec: Byte;Pos: Word) : PFieldRec;
 var P: PFieldRec;
begin
 New(P);
 P^.Name := Name;
 while Name[Length(Name)] = ' ' do System.Dec(Name[0]);
 if Length(Name) > Len then P^.Ln := Length(Name) else P^.Ln := Len;
 P^.Who := Who;
 P^.Len := Len;
 P^.Dec := Dec;
 P^.Pos := Pos;
 NewField := P;
end;

procedure TDBFile.OpenMode(Mode: Word);
begin
 BaseFile.Init(BaseName, Mode, 16384);
end;

constructor TDBFile.Init;

type
    frec = record
     Name: Array [0..10] of Char;
     Who: Char;
     Info1: Array [0..3] of Char;
     Len,Dec: Byte;
     Info2: Array [0..13] of Char;
    end;

var FBuf: FRec;
    I, J, RL: Integer;
    S: String;

begin
 inherited Init;

 BaseName := DelSpace(FileName);
 OpenMode(stOpenRead);

 if BaseFile.Status <> stOk then
  begin
   BaseFile.Done;
   Exit;
  end;
 BaseFile.Read(Date, 32);
 if BaseFile.Status <> stOk then begin BaseFile.Done;Exit;end;
 NumFields := (HeaderLen div 32) - 1;
 if NumFields = 0 then begin BaseFile.Done;Exit;end;
 Fields := New(PFieldCollection, Init(NumFields, NumFields));
 RL := 1;

 for I := 1 to NumFields do
  begin
   BaseFile.Read(FBuf, 32);
   Inc(RL, FBuf.Len);
   S := ''; J := 0;
   While FBuf.Name[J] >= #32 do
    begin
     S := S + FBuf.Name[J];
     Inc(J);
    end;
   S[0] := Char(J);
   if (J = 0) or (BaseFile.Status <> stOk) then
      begin Dispose(Fields, Done);BaseFile.Done;Exit;end;
   with FBuf do
   Fields^.Insert(NewField(S, Who, Len, Dec, RL - Len));
  end;

 if RL <> RecLen then
   begin Dispose(Fields, Done);BaseFile.Done;Exit;end;
 Loc := 0;
 BaseFile.Seek(HeaderLen);

end;

procedure TDBFile.Read;
 var I: LongInt;
begin
 if Loc + Num >= NumRec then Num := NumRec - Loc;
 I := LongInt(RecLen)*LongInt(Num);
 if I > 65520 then I := 65520;
 BaseFile.Read(Buf, I);
 Inc(Loc, Num);
end;

procedure TDBFile.Seek;
begin
 BaseFile.Seek(NewLoc * RecLen + HeaderLen);
 Loc := NewLoc;
end;

function TDBFile.GetFieldRec;
begin
 GetFieldRec := Fields^.At(N);
end;

function TDBFile.GetField;
 var I, K, N: Integer;
     B: Array [0..65000] of Char Absolute Buf;
     S: String;
     L: Word;
begin
 I := 0; K := 1;
 While (I < NumFields) and (GetFieldRec(I)^.Name <> Name) do Inc(I);
 K := GetFieldRec(I)^.Pos;
 S := ''; N := I;
 for I := K to K + GetFieldRec(N)^.Len - 1 do S[I - K] := B[I];
 S[0] := Char(GetFieldRec(N)^.Len);
 GetField := S;
end;

Procedure TDBFile.GetNField;
 var I, K, J: Integer;
     B: Array [0..65000] of Char Absolute Buf;
     L: Word;
begin
 K := GetFieldRec(N)^.Pos;

 S := '';
 for I := K to K + GetFieldRec(N)^.Len - 1 do
  Begin
   S[I - K + 1] := B[I];

  End;
 S[0] := Char(GetFieldRec(N)^.Len);

end;

destructor TDBFile.Done;
begin
 Dispose(Fields, Done);
 BaseFile.Done;
end;

Procedure Test;
VAr P : PDBFile;
    i,j : LongInt;
    F: PFieldRec;
    t : Text;
    B : Array [0..65000] of Char;
    s : String;
begin
 New(P, Init('base_tov.dbf'));
 if P = Nil then
  begin
   Write('Cann''t open file');
   Halt;
  end;
 WriteLn('File : ', P^.BaseName);
 WriteLn('Field :');
(*
 for I := 1 to P^.NumFields do
  begin
   F := P^.Fields^.At(I - 1);
   WriteLn(F^.Name : 11, F^.Who : 2, F^.Len : 4, F^.Dec : 4);
  end;

 Assign(t,'output');
 Rewrite(t);
 for I := 1 to P^.NumRec do
  begin
   P^.Read(B,16384);

   for j:=1 to P^.NumFields - 1 do
   Begin
     P^.GetNField(j,s, B);
     Write(s,' ');
   End;

   WriteLn;
  end;
 close(t);
 Readln;
*)
End;

Begin
 Test;
end.