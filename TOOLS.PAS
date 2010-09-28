{$IfNDEF DPMI}

{$F+}
{$O+}
{$M 32760,0,65520}

{$EndIf}
unit Tools;

{$X+,V-}

interface

uses Glob,ServStr,Objects, Views, App,Serv,Drivers,
      MyView;


procedure ViewAsText(const FileName: FNameStr;Reg:Boolean);
procedure CalcNewSrok(Client,Date:TDateString);

function GetRKONumer: string;

var    T: PTextWindow;

implementation

Uses MsgBox,TPDate;


Var p:PFileViewer;

procedure ViewAsText(const FileName: FNameStr;Reg:Boolean);
var
  R: TRect;
  fileToView : File;
  Test : Byte;
begin
  ClearFind;
  Test:=IOResult;
  Assign(FileToView, FileName);
  Reset(FileToView);
  Test := IOResult;
  if Test <> 0 then
  begin
    MessageBox(#3^M+#3'Не могу открыть файл !'+
               #3+^M+#3'Код ошибки ('+IntToStr(Test,3)+')', nil, mfError + mfCancelButton);
    Exit;
  end;
  Close(FileToView);
  R.Assign(0,0,80,23);
  T := New(PTextWindow, Init(R, FileName,Reg));
 If Test=0 Then
  Begin
  T^.Options := T^.Options or ofCentered;
  Desktop^.Insert(T);
 End;
end;

procedure CalcNewSrok(Client,Date:TDateString);
var Cl: ClientType;
    fcl: file of ClientType;
    ClKod: word;
    IOrez: word;
    op: word;
begin
  DelSpace(Client);
  ClKod:=StrToInt(Client);
  Assign(fcl,Path.ToClient+'client.db');
  IOrez:=ioresult;
  reset(fcl);
  IOrez:=ioresult;
  if iorez=0 then
  begin
    if filesize(fcl)<ClKod then
    begin
     close(fcl);
     exit;
    end;

    IOrez:=ioresult;
    seek(fcl,ClKod);
    IOrez:=ioresult;
    read(fcl,cl);
    IOrez:=ioresult;

    op:=DateStringToDate(DateMask,FDate)-DateStringToDate(DateMask,Date);

    if op>(StrToInt(Cl.Punkt[1])+7) then
     begin
      while (op-StrToInt(Cl.Punkt[1])>3) do
      begin
       Cl.Punkt[1]:=IntToStr(StrToInt(Cl.Punkt[1])+7,CRazdelKOd);
       if StrToInt(Cl.Punkt[1])>28 then
       begin
	   Cl.Punkt[1]:='28';
        Cl.Debit:=0;
        break;
       end;
      end;


      IOrez:=ioresult;
      seek(fcl,ClKod);
      IOrez:=ioresult;
      write(fcl,cl);

     end;
    IOrez:=ioresult;
    close(fcl);
    IOrez:=ioresult;
  end;

end;

function GetRKONumer: string;
var t: text;
    IOrez: word;
    s: string;
    n: word;
Begin
 GetRKONumer:='';
 Assign(t,Path.ToMarket+Fdate+'.pkn');
 IOrez:=ioresult;
 reset(t);
 IOrez:=ioresult;
 if iorez<>0 then
 begin
  IOrez:=ioresult;
  rewrite(t);
  IOrez:=ioresult;
  writeln(t,'0');
  IOrez:=ioresult;
  close(t);
 end;

 IOrez:=ioresult;
 reset(t);
 IOrez:=ioresult;

if IOrez=0 then
begin
 readln(t,s);
 close(t);
 n:=StrToInt(s);
 inc(n);
 s:=IntToStr(n,5);
 delSpace(s);
 rewrite(t);
 IOrez:=ioresult;
 writeln(t,s);
 IOrez:=ioresult;
 close(t);
 IOrez:=ioresult;
 GetRKONumer:=s;
end;


End;


end.
