{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}
{************************************************}
{                                                }
{   Turbo Vision Demo                            }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

unit Gadgets;

{$S-,D-,Q-}

{ Useful gadgets: clock and heap available viewer }

interface

uses Dos, Objects, Views, App,Glob;

type
  PHeapView = ^THeapView;
  THeapView = object(TView)
    OldMem : LongInt;
    constructor Init(var Bounds: TRect);
    procedure Draw;virtual;
    procedure Update;
  end;

  PClockView = ^TClockView;
  TClockView = object(TView)
    Refresh: Byte;
    LastTime: DateTime;
    TimeStr: string[26];{31}
    Date: string[26];{31}
    constructor Init(var Bounds: TRect);
    procedure Draw; virtual;
    function FormatTimeStr(r,H, M, S, hund: Word): String;virtual;
{    function FormatTimeStr(H, M, S: Word): String; virtual;}
    procedure Update(R : Byte); virtual;
  end;


Var SoundSignal : Boolean;

implementation

uses Drivers,Serv,ServStr,DbEngine,MsgBox,tpDate;

{------ Heap Window object ----------}

Var   GlobalRegimClock : Byte;

constructor THeapView.Init(var Bounds: TRect);
begin
  inherited Init(Bounds);
  OldMem := 0;
end;

procedure THeapView.Draw;
var
  S: String;
  B: TDrawBuffer;
  C: Byte;
begin
  OldMem := MemAvail;
  Str(OldMem:Size.X-2, S);
{  S[1] :=' ';}
  S :='�'+{Fdate}S;
  C := GetColor(14);
  MoveChar(B, ' ', C, Size.X);
  MoveStr(B, S, C);
  WriteLine(0, 0, Size.X, 1,B);
end;


procedure THeapView.Update;
begin
  if (OldMem <> MemAvail) then DrawView;
end;

{-------- ClockView Object --------}

function LeadingZero(w: Word): String;
var s: String;
begin
  Str(w:0, s);
  LeadingZero := Copy('00', 1, 2 - Length(s)) + s;
end;

constructor TClockView.Init(var Bounds: TRect);
begin
  inherited Init(Bounds);
  FillChar(LastTime, SizeOf(LastTime), #$FF);
  TimeStr := '';
  Refresh := 1;
end;


procedure TClockView.Draw;
var
  B: TDrawBuffer;
  C: Byte;
begin                                        {13 ����� �� ᨭ��}
                                             {9.15.50  ���� �� ᨭ��}
                                             {14 ᨭ�� �� �����}
                                             {52 ������ �� ᨭ��}

  If GlobalRegimClock=1 Then C := GetColor(2) {2}
  Else C := GetColor(52);
  MoveChar(B, ' ', C, Size.X);
  MoveStr(B, TimeStr, C);
  WriteLine(0,0, Size.X, 1, B);
end;


procedure TClockView.Update(R : Byte);
var
  h,m,s,hund: word;
  d,mon,g,n : word;
  l1,l2 : LongInt;
begin
If R = 0 Then  GetTime(h,m,s,hund)
   Else
           Begin
           GetDate(s,m,h,hund);
           if s<=1999 Then s:=s-1900
           Else
           s:=s-2000;
           End;
  if (Abs(s - LastTime.sec) >= Refresh){And(R=0)} then
  begin
   If R=0 Then
    with LastTime do
    begin
      Hour := h;
      Min := m;
      Sec := s;
    end;
    TimeStr := FormatTimeStr(r,h, m, s, hund);
    DrawView;

    If (NPrint.Messag=1)And (SoundSignal) Then
    Begin

     l1:=TimeStringToTime(TimeMask,CurrentTimeString('hh:mm:ss'));
     If (l1 <=(TimeStringToTime(TimeMask,NPrint.TimeStop)))
     And (l1>=(TimeStringToTime(TimeMask,NPrint.TimeStart))) Then

{    If (h=15) And (m in [35..45]) Then}
     Begin
      SoundSignal := False;
{$IfDEF Sound}
      SpecialBeep;
      Delay(1000);
      SpecialBeep;
      Delay(500);
      SpecialBeep;
{$EndIf}
MessageBox(^M+#3+NPrint.TextMessag,Nil,mfWarning+mfCancelButton);
{
      DInfoMsg(NPrint.TextMessag);
      SoundSignal := False;
      SpecialBeep;
      Delay(2000);
      SpecialBeep;
      Delay(1500);
      SpecialBeep;
      NoInfoMsg;
}
     End;
    End;

  end;
end;

function TClockView.FormatTimeStr(r,H, M, S, hund: Word): String;
Var st : String[CAll];
    st1 : String[8];
begin
  If FindStrok[0]=#0 Then
  Case r of
{ 0:  FormatTimeStr := '��६�: '+LeadingZero(h)+ ' ��. '+ LeadingZero(m) +
    ' ���. ' + LeadingZero(s)+' ᥪ.';}
 0: {FormatTimeStr := '� '+LeadingZero(h)+ ' ��. '+ LeadingZero(m) +
    ' ���. ' + LeadingZero(s)+' ᥪ.';}
      FormatTimeStr := '� '+LeadingZero(h)+ ':'+ LeadingZero(m) +
    ':' + LeadingZero(s);
 1:  Begin
     Case m Of
{     1:st:='������';
     2:st:='���ࠫ�';
     3:st:='����';
     4:st:='��५�';
     5:st:='���';
     6:st:='���';
     7:st:='���';
     8:st:='������';
     9:st:='�������';
    10:st:='������';
    11:st:='�����';
    12:st:='�������';}
     1:st:='01';
     2:st:='02';
     3:st:='03';
     4:st:='04';
     5:st:='05';
     6:st:='06';
     7:st:='07';
     8:st:='08';
     9:st:='09';
    10:st:='10';
    11:st:='11';
    12:st:='12';
     Else;
     End;
     Case hund Of
{    1:st1:='�������';
     2:st1:='��୨�';
     3:st1:='�।�';
     4:st1:='��⢥�';
     5:st1:='��⭨�';
     6:st1:='�㡡��';
     0:st1:='�����';}
     1:st1:='��';
     2:st1:='��';
     3:st1:='��';
     4:st1:='��';
     5:st1:='��';
     6:st1:='��';
     0:st1:='��';

     Else Str(Hund,st1) ;
     End;
(*     FormatTimeStr := '����:'+st1+ ','+LeadingZero(h)+ ' '+ St{LeadingZero(m)} +
    ' ' + LeadingZero(s)+ '�.';*)
     FormatTimeStr :='� '+st1+ ','+LeadingZero(h)+ '-'+ St{LeadingZero(m)} +
    '-' + LeadingZero(s);
     End;
 1:  FormatTimeStr := '� '+LeadingZero(h)+ '-'+ LeadingZero(m) +
    '-' + LeadingZero(s);
 2:If CurrentPassword[0]<>#0 Then
    FormatTimeStr := '�'+GetOperatorName(CurrentPassword)+' ('+CurrentPassword+')'
    Else FormatTimeStr := '�';
 3:Begin
    st:=GetClientField(FClient,Rek.Kod,1);
    If St[0]<>#0 Then
    FormatTimeStr := '�'+St+' ('+Rek.Kod+')'
    Else FormatTimeStr := '�';
   End;
   Else;
   End;
  If FindStrok[0]<>#0 Then
   Begin
    FormatTimeStr:=' '+FindStrok;
    GlobalRegimClock:=0;
   End
   Else GlobalRegimClock:=1;

end;
Begin
 SoundSignal := True;
end.