{$IfNDEF DPMI}
{$F+}
{$O+}
{$EndIf}


{$I Compile.INC}


{unit dbf;

interface
}

Uses Dos,Servstr;

(* The routines in this file present some fairly general purpose tools for
   accessing dBASE III and dBASE III Plus files from within a Turbo Pascal
   program.  There is much room for improvement: the error checking is
   rudimentary, no routines to access memo files, no buffering of data,
   no support for index files, etc.
   The main routines are:

      FUNCTION OpenDbf(var D : DbfInfoType;) : integer;
      FUNCTION CloseDbf(var D : DbfInfoType) : integer;
      PROCEDURE GetDbfRecord(var D : DbfInfoType; RecNum : real);
      PROCEDURE PutDbfRecord(var D : DbfInfoType; RecNum : real);

      A skeletal program would go something like:
        BEGIN
        {...initialize and get filename of .dbf file into FileName field
            of DbfInfoType Record variable ...  }
        if OpenDbf(...)  { to open the file              }
        {... the rest of your program including calls to
             GetDbfRecord and/or PutDbfRecord as needed  }
        if CloseDbf (...) { to close the file            }
        end.

      Upon exit from the GetDbfRecord Procedure, the CurRecord field of the
      DbfInfoType variable contains the current record contents.  Each field
      can be accessed using its offset into the CurRecord with the variable
      Off in the Fields array.
      Upon entry to the PutDbfRecord Procedure, the CurRecord should contain
      the data that you want to write.

      See the demo program for some examples.
      While I intend to upload more complete routines and better
      documentation at some time, if you should have any problems with
      these routines, please leave me a note.

dBASE III Database File Structure
The structure of a dBASE III database file is composed of a
header and data records.  The layout is given below.
dBASE III DATABASE FILE HEADER:
+---------+-------------------+---------------------------------+
|  BYTE   |     CONTENTS      |          MEANING                |
+---------+-------------------+---------------------------------+
|  0      |  1 byte           | dBASE III version number        |
|         |                   |  (03H without a .DBT file)      |
|         |                   |  (83H with a .DBT file)         |
+---------+-------------------+---------------------------------+
|  1-3    |  3 bytes          | date of last update             |
|         |                   |  (YY MM DD) in binary format    |
+---------+-------------------+---------------------------------+
|  4-7    |  32 bit number    | number of records in data file  |
+---------+-------------------+---------------------------------+
|  8-9    |  16 bit number    | length of header structure      |
+---------+-------------------+---------------------------------+
|  10-11  |  16 bit number    | length of the record            |
+---------+-------------------+---------------------------------+
|  12-31  |  20 bytes         | reserved bytes (version 1.00)   |
+---------+-------------------+---------------------------------+
|  32-n   |  32 bytes each    | field descriptor array          |
|         |                   |  (see below)                    | --+
+---------+-------------------+---------------------------------+   |
|  n+1    |  1 byte           | 0DH as the field terminator     |   |
+---------+-------------------+---------------------------------+   |
|
|
A FIELD DESCRIPTOR:      <------------------------------------------+
+---------+-------------------+---------------------------------+
|  BYTE   |     CONTENTS      |          MEANING                |
+---------+-------------------+---------------------------------+
|  0-10   |  11 bytes         | field name in ASCII zero-filled |
+---------+-------------------+---------------------------------+
|  11     |  1 byte           | field type in ASCII             |
|         |                   |  (C N L D or M)                 |
+---------+-------------------+---------------------------------+
|  12-15  |  32 bit number    | field data address              |
|         |                   |  (address is set in memory)     |
+---------+-------------------+---------------------------------+
|  16     |  1 byte           | field length in binary          |
+---------+-------------------+---------------------------------+
|  17     |  1 byte           | field decimal count in binary   |
+---------+-------------------+--------------------------------
|  18-31  |  14 bytes         | reserved bytes (version 1.00)   |
+---------+-------------------+---------------------------------+
The data records are layed out as follows:
1. Data records are preceeded by one byte that is a
space (20H) if the record is not deleted and an
asterisk (2AH) if it is deleted.
2. Data fields are packed into records with no field
separators or record terminators.
3. Data types are stored in ASCII format as follows:
DATA type      DATA RECORD STORAGE
---------      --------------------------------------------
Character      (ASCII characters)
Numeric        - . 0 1 2 3 4 5 6 7 8 9
Logical        ? Y y N n T t F f  (? when not initialized)
Memo           (10 digits representing a .DBT block number)
Date           (8 digits in YYYYMMDD format, such as
19840704 for July 4, 1984)

This information came directly from the Ashton-Tate Forum.
It can also be found in the Advanced Programmer's Guide available
from Ashton-Tate.
*)

const
   DB3File = 3;
   DB3WithMemo = $83;
   Validtypes : SET OF Char = ['C', 'N', 'L', 'M', 'D'];
   MAX_HEADER = 4129;          { = maximum length of dBASE III header }
   MAX_BYTES_IN_RECORD = 4000; { dBASE III record limit }
   MAX_FIELDS_IN_RECORD = 128; { dBASE III field limit  }
   BYTES_IN_MEMO_RECORD = 512; { dBASE III memo field record size }

(*
   Allow there are some declarations for memo files, the routines to access
   them have not been implemented.
*)

type
   Headertype = ARRAY[0..MAX_HEADER] OF Byte;
   HeaderPrologtype = ARRAY[0..31] OF Byte; { dBASE III header prolog }
   FieldDesctype = ARRAY[0..31] OF Byte; { dBASE III field definitions }
   DbfRecord = ARRAY[0..MAX_BYTES_IN_RECORD] OF Byte; {the 0 offset represents
                                                     the 'deleted' flag.   }
   Str255 = STRING[255];
   Str80 = STRING[80];
   Str64 = STRING[64];
   Str10 = STRING[10];
   Str8 = STRING[8];
   Str2 = STRING[2];
   DbfFiletype = FILE;
   FieldRecord = record
                    Name : Str10;
                    Typ : Char;
                    Len : Byte;
                    Dec : Byte;
                    Off : integer;
                 end;
   FieldArray = ARRAY[1..MAX_FIELDS_IN_RECORD] OF FieldRecord;
   MemoRecord = ARRAY[1..BYTES_IN_MEMO_RECORD] OF Byte;
   MemoFiletype = FILE OF MemoRecord;

   DbfInfoType = record
                    FileName     : Str64;
                    dFile        : DbfFiletype;
                    HeadProlog   : HeaderPrologtype;
                    Updated      : Boolean;
                    WithMemo     : Boolean;
                    DateOfUpdate : Str8;
                    NumRecs      : real;
                    HeadLen      : integer;
                    RecLen       : integer;
                    NumFields    : integer;
                    Fields       : FieldArray;
                    CurRecord    : DbfRecord;
                 end;

{implementation

 Uses Dos,Serv,Servstr;
}

  (*
  Notice that if you need to access more than one .DBF file simultaneously
  you could declare ARRAYs of DbfFiletype, DbfInfoType, etc.
  *)

PROCEDURE ErrorHalt(Msg : Str80);
begin
   WriteLn;
   WriteLn(Msg);
   Halt;
end;

FUNCTION MakeReal(var b) : real;
var
   r : ARRAY[1..4] OF Byte ABSOLUTE b;
begin
   MakeReal := (r[1]*1)+(r[2]*256)+(r[3]*65536.0)+(r[4]*16777216.0);
end;

FUNCTION MakeInt(var b) : integer;
var
   i : integer ABSOLUTE b;
begin
   MakeInt := i;
end;

FUNCTION MakeStr(b : Byte) : Str2;
var
   i : integer;
   s : Str2;
begin
   i := b;
   Str(i:2, s);
   MakeStr := s;
end;



PROCEDURE UpdateHeader(var D : DbfInfoType);
type
   {
   Regtype  = record  case integer of
                 1 : (AX,BX,CX,DX,BP,SI,DI,DS,ES,Flags: integer);
                 2 : (AL,AH,BL,BH,CL,CH,DL,DH : Byte);
              end;
   }

   Regtype = record
  case Integer of
  0: (AX, BX, CX, DX, BP, SI, DI, DS, ES, Flags: Word);
  1: (AL, AH, BL, BH, CL, CH, DL, DH: Byte);
     end;


var
   Reg : Registers;
   r : Real;
begin
   with D do begin
      Reg.AX := $2A00;  { Get DOS Date }
      Intr ($21,Reg);
      HeadProlog[1] := Reg.CX - 1900; {Year}
      HeadProlog[2] := Reg.DH;        {Month}
      HeadProlog[3] := Reg.DL;        {Day}
      r := NumRecs;
      HeadProlog[7] := Trunc(r / 16777216.0);
      r := r - (HeadProlog[7] * 16777216.0);
      HeadProlog[6] := Trunc(r / 65536.0);
      r := r - (HeadProlog[6] * 65536.0);
      HeadProlog[5] := Trunc(r / 256);
      r := r - (HeadProlog[5] * 256);
      HeadProlog[4] := Trunc(r);
      Seek(dFile,0);
      {$I-} BlockWrite(dFile,HeadProlog,SizeOf(HeadProlog)); {$I+}
      if IOResult <> 0 then
         ErrorHalt('Error Closing file.');
   end; {with}
end;


FUNCTION CloseDbf(var D : DbfInfoType) : integer;
var
   b : Byte;
begin
   with D do begin
      if Updated then begin
         UpdateHeader(D);
         b := $1A;
         Seek(dFile,HeadLen+Round(NumRecs*RecLen));
         BlockWrite(dFile,b,1); {Put EOF marker }
      end;
      {$I-} Close(dFile);             {$I+}
      CloseDbf := IOResult;
   end; {with}
end;

PROCEDURE ProcessHeader(var Header : Headertype;
                        var D : DbfInfoType);

  PROCEDURE GetOneFieldDesc(var F; var Field : FieldRecord;
                            var Offset : integer);
  var
     i : integer;
     FD : FieldDesctype ABSOLUTE F;
  begin
     with Field do begin
        i := 0;
        Name := '          ';
        repeat
           Name[Succ(i)] := Chr(FD[i]);
           i := Succ(i);
        until FD[i] = 0;
        Name[0] := Chr(i);
        Typ := Char(FD[11]);
        Len := FD[16];
        Dec := FD[17];
        Off := Offset;
        Offset := Offset+Len;
        if NOT(Typ IN Validtypes) then
           ErrorHalt('Invalid type in Field '+Name);
     end;                    {with}
  end;                      {GetOneFieldDesc}



var
   o,
   i : integer;
begin                       {ProcessHeader}
   with D do begin
      case Header[0] OF
         DB3File : WithMemo := False;
         DB3WithMemo : WithMemo := True;
         else
            ErrorHalt('Not a valid dBASE III File.');
      end;                      {case}
      DateOfUpdate := MakeStr(Header[2])+'/'+MakeStr(Header[3])+'/'
                      + MakeStr(Header[1]);
      NumRecs := MakeReal(Header[4]);
      HeadLen := MakeInt(Header[8]);
      RecLen := MakeInt(Header[10]); { Includes the Deleted Record Flag }
      Updated := FALSE;
      NumFields := 0;
      for i := 0 TO SizeOf(HeadProlog) do
         HeadProlog[i] := Header[i];
      o := 1;                   {Offset within dbf record of current field }
      i := 32;                  {Index for Header }
      while Header[i] <> $0D do begin
         NumFields := Succ(NumFields);
         GetOneFieldDesc(Header[i], Fields[NumFields], o);
         i := i+32;
      end;                    {While}
      if Header[Succ(HeadLen)] = 0 then
         HeadLen := Succ(HeadLen);
   end;                      {With}
end;                        {ProcessHeader}


PROCEDURE GetHeader(var D : DbfInfoType);
var
   Result : integer;
   H      : Headertype;
begin
   with D do begin
      {$I-} BlockRead(dFile, H, MAX_HEADER, Result); {$I+}
      if IOResult <> 0 then
         ErrorHalt('Error reading header.');
      ProcessHeader(H, D);
   end; {with}
end;

FUNCTION OpenDbf(var D : DbfInfoType) : integer;
begin
   with D do begin
      Assign(dFile, FileName);
      {$I-} Reset(dFile, 1); {$I+}    {the '1' parameter sets the record size}
      if IOResult <> 0 then
         ErrorHalt('Error opening data file.');
      GetHeader(D);
      OpenDbf := IOResult;
   end; {with}
end;


PROCEDURE GetDbfRecord(var D : DbfInfoType; RecNum : real);
var
   Result : integer;
begin
   with D do begin
      if RecNum > NumRecs then
         ErrorHalt('Tried to read past EOF.');
      Seek(dFile, HeadLen+Round((RecNum-1)*RecLen));
      BlockRead(dFile, CurRecord, RecLen, Result);
      if Result <> RecLen then
         ErrorHalt('Error reading DBF File');
   end;                      { with }
end;                        {GetDbfRecord}

PROCEDURE PutDbfRecord(var D : DbfInfoType; RecNum : real);
var
   Result : integer;
begin
   with D do begin
      if RecNum > NumRecs then begin
         RecNum := NumRecs + 1;
         NumRecs := RecNum;
      end;
      Seek(dFile, HeadLen+Round((RecNum-1)*RecLen));
      {$I-} BlockWrite(dFile, CurRecord, RecLen, Result); {$I+}
      if IOResult <> 0 then
         ErrorHalt('Error writing to DBF File');
      Updated := TRUE;
   end;                      { with }
end;                        {GetDbfRecord}







(* !!!!!!!!! To enable the Demo program, delete the next line.  !!!!!!!!! *)


type
   PseudoStr = ARRAY[1..255] OF Char;

var
   DemoInfo : DbfInfoType;
   l,
   i,
   j : integer;
   blanks : Str255;
   SizeOfFile,
   r : real;


PROCEDURE List(var D : DbfInfoType);

  PROCEDURE ShowField(var a; var F : FieldRecord);
  var
     Data : PseudoStr ABSOLUTE a;
  begin
     with F do begin
        case Typ OF
           'C',
           'N',
           'L' : Write(Copy(Data, 1, Len));
           'M' : Write('Memo      ');
           'D' : Write(Copy(Data, 5, 2), '/',
                       Copy(Data, 7, 2), '/',
                       Copy(Data, 1, 2));
        end;                    {case}
        if Len <= Length(Name) then
           Write(Copy(blanks, 1, Length(Name)-Pred(Len)))
        else
           Write(' ');
     end;                    {with F}
  end;                      {ShowField}

begin                       {List}
   WriteLn;
   Write('Rec Num ');

   with D do begin
      for i := 1 TO NumFields do
         with Fields[i] do
            if Len >= Length(Name) then
               Write(Name, Copy(blanks, 1, Succ(Len-Length(Name))))
            else
               Write(Name, ' ');
      WriteLn;
      r := 1;
      while r <= NumRecs do begin
         GetDbfRecord(DemoInfo, r);
         WriteLn;
         Write(r:7:0, ' ');
         for i := 1 TO NumFields do
            ShowField(CurRecord[Fields[i].Off], Fields[i]);
         r := r+1;
      end;                    {while r }
   end;                      {with D }
end;                        {List}

PROCEDURE DisplayStructure(var D : DbfInfoType);
var
   row,
   i : integer;
begin
   row := 0;
   with D do begin
      for i := 1 TO NumFields do begin
         with Fields[i] do begin
            if i MOD 22 = 0 then begin
               WriteLn;
               row := 0;
            end;
            row := Succ(row);
            if row MOD 22 = 1 then begin
               ClrScr;
               Write(' #  Field Name   type  Length  Decimal');
               row := 2;
            end;
            GoToXY(1, row);
            Write(i:2, Name:12, Typ:5, Len:9);
            if Typ = 'N' then
               Write(Dec:5);
         end;                  {with Fields}
      end;                    {FOR}
      WriteLn;
   end;                      {with D}
end;                        { DisplayStructure }



begin                         {Demonstration of DBF routines}
   with DemoInfo do begin
      FillChar(blanks, SizeOf(blanks), $20);
      blanks[0] := Chr(255);
      ClrScr;
      GoToXY(10, 10);
      Write('Name of dBASE file (.DBF assumed): ');
      Read(FileName);
      if Pos('.', FileName) = 0 then
         FileName := FileName+'.DBF';
      if OpenDbf(DemoInfo) <> 0 then
         ErrorHalt('Unable to open '+FileName);
      ClrScr;
      SizeOfFile := FileSize(dFile);
      WriteLn('File Name: ', FileName);
      WriteLn('Date Of Last Update: ', DateOfUpdate);
      WriteLn('Number of Records: ', NumRecs:10:0);
      WriteLn('Size of File: ', SizeOfFile:15:0);
      WriteLn('Length of Header: ', HeadLen:11);
      WriteLn('Length of One Record: ', RecLen:7);
      if WithMemo then
         WriteLn('This file contains Memo fields.');
      ClrScr;
      DisplayStructure(DemoInfo);
      ClrScr;
      List(DemoInfo);
      WriteLn;
      if CloseDbf(DemoInfo) <> 0 then
         ErrorHalt('Error closing file.');
   end; {with}
end.                          {of Demo program }




                                                                                                                         