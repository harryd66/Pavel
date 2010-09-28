uses Objects, Drivers, Views, App, ExecWin;

type
 TInsApp = object(TApplication)
   constructor Init;
  end;

{========================================================================}
constructor TInsApp.Init;
var
 W: PWindow;
 ExecTerminal: PExecTerminal;
 R: TRect;
begin
 inherited Init;
 R.Assign(1, 1, 70, 20);
 W:=New(PWindow, Init(R, 'Execute', wnNoNumber));
 W^.GetExtent(R);
 R.Grow(-1, -1);
 ExecTerminal:=New(PExecTerminal, Init(R));
 W^.Insert(ExecTerminal);
 InsertWindow(W);
 ExecTerminal^.ExecPrg('ARJ.EXE', 'A FIX.ARJ D:\*.*');
 ExecTerminal^.ExecPrg('PKUNZIP.EXE', '-t D:\BOARD\MUSIC\MUS_CONV.ZIP');
end;

var
 InsApp: TInsApp;
begin
  InsApp.Init;
  InsApp.Run;
  InsApp.Done;
end.

