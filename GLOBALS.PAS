{************************************************}
{                                                }
{   Turbo Vision File Manager Demo               }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

{$X+,V-}

unit Globals;

interface

uses Objects, Drivers, App, Views, Menus, Dialogs, Dos;

type

  PProtectedStream = ^TProtectedStream;
  TProtectedStream = object(TBufStream)
    procedure Error(Code, Info: Integer); virtual;
  end;

  { THCStatusLine is a help context sensitive status line }

  PHCStatusLine = ^THCStatusLine;
  THCStatusLine = object(TStatusLine)
  end;


procedure RegisterGlobals;

var
  RezFile: TResourceFile;
  RezStream: PStream;

implementation

uses MsgBox;

const
  RHCStatusLine : TStreamRec = (
    ObjType : 100;
    VmtLink : Ofs(TypeOf(THCStatusLine)^);
    Load    : @THCStatusLine.Load;
    Store   : @THCStatusLine.Store
  );


{ ----------- General Purpose Routines -------------------- }

procedure RegisterGlobals;
begin
  RegisterType(RHCStatusLine);
end;


{ TProtectedStream }

procedure TProtectedStream.Error(Code, Info: Integer);
begin
  Writeln('Error in stream: Code = ', Code, ' Info = ', Info);
  Halt(1);
end;


{ THCStatusLine }

end. { unit }
