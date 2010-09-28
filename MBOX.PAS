{$F+,X+,O+,R-}

unit MBox;

interface

uses Objects, Menus;

function ExecMenu(var Bounds: TRect; AMenu: PMenu): word;

implementation

uses App, Views, Drivers;

function ExecMenu(var Bounds: TRect; AMenu: PMenu): word;
 var V: PMenuBox; W: word;
 begin
  V:=New(PMenuBox, Init(Bounds, AMenu, nil));
  W:=DeskTop^.ExecView(V);
  DisposeMenu(V^.Menu);
  Dispose(V, Done);
  ExecMenu:=W;
 end;

end.
