{$X+}

{ Program Demo                                                }
{   Demo the X_Dialog unit                                    }
{                                                             }
{ Donn Aiken, 71150,2011                                      }
{ May 17, 1991                                                }

{ Small example program to show how to create what functions  }
{ as a dialog box that scrolls.                               }
{ Look at TMyListBox object to see how it's done.             }
{                                                             }
{ Based somewhat upon the ListBox example without a scrollbar }
{ by Mike Savage, 71121,3137.
{                                                                             }


program Demo;

uses Serv,Objects, Drivers, Views, Menus, Dialogs, App, MsgBox, X_Dialog;

const
  cmNewDialog = 102;

type
  TMyApp = object(TApplication)
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure InitMenuBar; virtual;
    procedure InitStatusLine; virtual;
    procedure NewDialog;
  end;

  PMyMenuBar = ^TMyMenuBar;
  TMyMenuBar = object (TMenuBar)
    procedure GetEvent (var Event: TEvent); virtual;
  end;

procedure TMyMenuBar.GetEvent (var Event: TEvent);



var
  oe : TEvent;

begin
  TMenuBar.GetEvent (Event);

  if (Event.What = evCommand) and (Event.Command = cmMenu) then
    begin
      oe.What    := evKeyDown;
      oe.KeyCode := kbEnter;
      PutEvent (oe);
    end;
end;

{ TMyApp }
procedure TMyApp.HandleEvent(var Event: TEvent);
begin
  TApplication.HandleEvent(Event);
  case Event.What of
    evCommand :
      begin
        case Event.Command of
          cmNewDialog: NewDialog;
        else
          Exit;
        end;
        ClearEvent(Event);
      end;
  end;
end;

procedure TMyApp.InitMenuBar;
var R: TRect;
begin
  GetExtent(R);
  R.B.Y := R.A.Y + 1;
  MenuBar := New(PMyMenuBar, Init(R, NewMenu(
    NewSubMenu('~L~istBox', hcNoContext, NewMenu(
      NewItem('~D~ialog', 'F2', kbF2, cmNewDialog, hcNoContext,
      NewLine(
      NewItem('E~x~it', 'Alt-X', kbAltRusCh, cmQuit, hcNoContext,
      nil)))),
    nil))));
end;

procedure TMyApp.InitStatusLine;
var R: TRect;
begin
  GetExtent(R);
  R.A.Y := R.B.Y - 1;
  StatusLine := New(PStatusLine, Init(R,
    NewStatusDef(0, $FFFF,
      NewStatusKey('', kbF10, cmMenu,
      NewStatusKey('~Alt-X~ Exit', kbAltRusCh, cmQuit,
      nil)),
    nil)
  ));
end;

procedure TMyApp.NewDialog;
var
  Dialog        : PDialog;
  R             : TRect;
  Control, Labl : PView;
  SC            : PCollection;
  PListBoxData  : PBoxData;
  AScrollBar    : PScrollBar;

begin
MemCC;
    { create collection, insert strings }

    SC := New(PCollection, Init(1, 1));
    SC^.Insert(New (PStringO, Init('Borland')));
    SC^.Insert(New (PStringO, Init('Borland')));



  { create the dialog box }
  R.Assign(10,2,48,15);
  Dialog := New(PDialog, Init(R, 'Demo Dialog'));
  with Dialog^ do
  begin
  new(PListBoxData,Init);
  PListBoxData^.PList := SC;
  FillChar (PListBoxData^.Sel, Sizeof(PListBoxData^.Sel), #0);

  { create the scroll bar }
  R.Assign (35, 3, 36, 9);
  AScrollBar := New(PScrollBar, Init(R));

    R.Assign(3,3,35,9);
    Control := New(PMyListBox, Init(R, 'þ', 2, AScrollBar));

    PMyListBox(Control)^.SelectItem(1);

    Insert (Control);
    Insert (AScrollBar);
    R.Assign(2,2,11,3);
    Labl := New(PLabel, Init(R, '~L~istbox:', Control));
    Insert(Labl);
    R.Assign(3,10,13,12);
    Insert(New(PButton, Init(R, '~O~k', cmOK, bfDefault)));
    R.Assign(14,10,24,12);
    Insert(New(PButton, Init(R, '~C~ancel', cmCancel, bfNormal)));

    SetData(PListBoxData);
  end;

  if (DeskTop^.ExecView(Dialog) = cmOk) then
    Dialog^.GetData (PListBoxData);
  Dispose(PListBoxData, Done);
  Dispose(Dialog, Done);
  Dispose(SC, Done);
MemCC;
end;

var
  MyApp: TMyApp;

begin
  MyApp.Init;
  MyApp.Run;
  MyApp.Done;
end.
