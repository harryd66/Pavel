{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}
{************************************************}
{                                                }
{   Turbo Vision Demo                            }
{   Copyright (c) 1990 by Borland International  }
{                                                }
{************************************************}

unit MyCalc;

{$S-}
{$R-}
{$Q-}

{ Calculator object. See TVDEMO.PAS for an example
  program that uses this unit.
}
interface

uses App,Drivers, Objects, Views, Dialogs;


Type
  PMyCalculator = ^TMyCalculator;
  TMyCalculator = object(TDialog)
    Procedure Start;
    Procedure Refresh;
    Destructor Done;Virtual;
    Procedure Handleevent(Var Event:TEvent);Virtual;
  end;

Implementation

Uses ColorTxt,Glob,ServStr;


const
  digits : set of char = ['0'..'9', '.', 'E'];


Var CalculatorWindow : PMyCalculator;
    ControlDigit,ControlResult,ControlCalcLine   : PView;

    answer : Extended;
    Wspom,Rashet,Result,rcal : string[CSertif*2];
    i : integer;
    FreshTablo,Stop : Boolean;
    Man : Word;



procedure error(cal : string; var i : integer);
begin
 If Not Stop Then
 Result:=(copy(cal, i - 5, 10) + ' => Ошибка в выражении!');
end;

function clean(var toupper : string) : boolean;
var
  i, l, r : integer;
  t : string;
begin
  t := '';
  l := 0;
  r := 0;
  for i := 1 to length(toupper) do
    if toupper[i] <> ' ' then
    begin
      t := t + upcase(toupper[i]);
      if toupper[i] = '(' then
        l := l + 1;
      if toupper[i] = ')' then
        r := r + 1;
    end;
  if r <> l then
  begin
    Result:=' Требуются скобки ';
    clean := false;
    Stop:=True;
  end
  else
  begin
    if t = '' then
      toupper := '0'
    else
      toupper := t;
    clean := true;
  end;
end;

function fstr(x : extended) : string;
var
  s : string;
begin
 if Not Stop Then
  begin
  str(x:1:9, s);

  if s[1] = ' ' then
    delete(s, 1, 1);
  fstr := s;
  end;
end;

function fval(s : string) : extended;
var
  x : extended;
  code : integer;
begin
 if Not Stop Then
  begin
  val(s, x, code);
  fval := x;
 end;
end;

function prevnum(var temp : string; i : integer) : extended;
var
  oldi : integer;
begin
 if Not Stop Then
Begin
  oldi := i;
  while ((temp[i] in digits) or ((temp[i - 1] = 'E') and (temp[i] in ['+', '-']))) and (i >= 1) do
    dec(i);
  if (temp[i] in ['+', '-']) and ((i = 1) or (temp[i - 1] in ['+', '-', '*', '/'])) then
    dec(i);
  prevnum := fval(copy(temp, i + 1, oldi - i));
  delete(temp, i + 1, oldi - i);
  if stop then exit;
End;
end;

function signs(cal : string; var i : integer) : integer;
var
  sign : integer;
begin
 if Not Stop Then
 Begin
                sign := 1;
  repeat
    if cal[i] = '-' then
    begin
      sign := sign * -1;
      inc(i);
    end
    else
    if cal[i] = '+' then
      inc(i);
  until not(cal[i] in ['-', '+']);
  signs := sign;
 End;
end;

function nextnum(cal : string; var i : integer) : extended;
var
  temp : string;
  sign : integer;
begin
  if Not Stop Then
  Begin
  temp := '';
  sign := signs(cal, i);
  while (cal[i] in digits) and (i <= length(cal)) do
  begin
    temp := temp + cal[i];
    inc(i);
    if (cal[i - 1] = 'E') and (cal[i] in ['+', '-']) then
    begin
      temp := temp + cal[i];
      inc(i);
    end;
  end;
  nextnum := sign * fval(temp);
  End;
end;

function getbrackets(cal : string; var i : integer) : string;
var
  count : integer;
  temp : string;
begin
 If Stop Then Exit;
  count := 1;
  temp := '';
  repeat
 if Not Stop Then
 Begin
                  inc(i);
    if cal[i] = '(' then
      count := count + 1;
    if cal[i] = ')' then
      count := count - 1;
    temp := temp + cal[i];
 End;
  until ((cal[i] = ')') and (count = 0)) Or Stop;
  delete(temp, length(temp), 1);
  inc(i);
  getbrackets := temp;
end;

function doadd(temp : string) : extended;
var
  i : integer;
  tot : extended;
begin
  i := 1;
  tot := nextnum(temp, i);
  If Stop Then Exit;
  repeat
    inc(i);
    case temp[i - 1] of
      '+' :  if Not Stop Then
              tot := tot + nextnum(temp, i);
      '-' :  if Not Stop Then
              tot := tot - nextnum(temp, i);
    end;
  until (i > length(temp)) Or Stop;
  doadd := tot;
end;

function domuls(cal : string) : extended;
var
  n,i, sign : integer;
  cal1,temp, s : string;
  Test : Extended;
begin
  i := 1;
  Domuls:=0;
  temp := '';
  repeat
  If Stop Then Exit;
    case cal[i] of
      '+', '-' : if Not Stop Then
               begin
                   temp := temp + cal[i];
                   inc(i);
                 end
            Else Exit;


      '*' :   If Not Stop Then

               begin
              inc(i);
              sign := signs(cal, i);
              if cal[i] in digits then
              begin
                s := fstr(sign * prevnum(temp, length(temp)) * nextnum(cal,i));
                temp := temp + s;
                If Stop Then Exit;
              end
              else
              if cal[i] = '(' then
              begin
                s := fstr(sign * prevnum(temp, length(temp)) * domuls(getbrackets(cal, i)));
                temp := temp + s;
                If Stop Then Exit;
              end
              else
                Begin
                error(cal, i);
                Stop:=True;
                Exit;
                End;
            end
            Else Exit;


      '/' : if Not Stop Then
               begin
              inc(i);
              sign := signs(cal, i);
              if cal[i] in digits then
              begin
                n:=i;
                Cal1:=Cal;
                If nextnum(cal1, n)<>0 Then
                Begin
                If Not Stop Then
                s := fstr(sign * prevnum(temp, length(temp)) / nextnum(cal,i))
                Else Exit;
                If Stop Then Exit;
                temp := temp + s;
                End
                Else
                Begin
                Result:=' Деление на 0! ';
                Stop:=True;
                Exit;
                End;

              end
              else
              if cal[i] = '(' then
              begin
                n:=i;
                Cal1:=Cal;
                If (sign * domuls(getbrackets(cal1, n)))<>0 Then
                Begin
                If Not Stop Then
                s := fstr(prevnum(temp, length(temp)) / (sign * domuls(getbrackets(cal, i))))
                Else Exit;
                If Stop Then Exit;
                temp := temp + s;
                End
                Else
                Begin
                Result:=' Деление на 0! ';
                Stop:=True;
                Exit;
                End;

              end
              else
                Begin
                error(cal, i);
                Result:=' Деление на 0! ';
                Stop:=True;
                Exit;
                End;
            end
            Else Exit;


      '0'..'9', '.' : If Not Stop Then
                      while (cal[i] in digits) and (i <= length(cal)) do
                      begin
                        temp := temp + cal[i];
                        inc(i);
                        if (cal[i - 1] = 'E') and (cal[i] in ['+', '-']) then
                        begin
                          temp := temp + cal[i];
                          inc(i);
                        end;
                      end
            Else Exit;


      '(' : If Not Stop Then temp := temp + fstr(domuls(getbrackets(cal, i)));

      else
                Begin
                error(cal, i);
                Stop:=True;
                Exit;
                End;
    end;
  until (i > length(cal)) Or Stop ;
  domuls := doadd(temp);
end;

function dopowers(cal : string) : string;
var
  n,i, c : integer;
  x, f : extended;

  function logn(x : extended) : extended;
  begin
  If Not Stop Then
    If x>0 Then
    logn := ln(x)
    Else
     Begin
      Result:=' Логарифм отрицательного числа! ';
      Stop:=True;
      Exit;
     End;
  End;


  function fcnt(var cal : string; var i : integer) : integer;
  var
    j : integer;
  begin
    If Not Stop Then
   Begin

    j := 0;
    while cal[i] = '!' do
    begin
      inc(j);
      dec(i);
    end;
    inc(i);
    delete(cal, i, j);
    fcnt := j;
   End;
  end;

  function fact(x : extended) : extended;
  var
    k, n : word;
    ans : extended;
  begin
    If Not Stop Then
   Begin

    ans := 1;
    if x < 0 then
      fact := ans / (x - x);
    n := trunc(x);
    for k := 2 to n do
      ans := k * ans;
    fact := ans;
   End;
  end;

  function getprev(var cal : string; var i : integer) : extended;
  var
    oldi, count : integer;
  begin
   If Not Stop Then
   Begin

    dec(i);
    oldi := i;
    if cal[i] <> ')' then
    begin
      while ((cal[i] in digits) or ((cal[i - 1] = 'E') and (cal[i] in ['+', '-']))) and (i >= 1) do
        dec(i);
      if (cal[i] in ['+', '-']) and ((i = 1) or (cal[i - 1] in ['+', '-', '*', '/'])) then
        dec(i);
      getprev := fval(copy(cal, i + 1, oldi - i));
      delete(cal, i + 1, oldi - i);
    end
    else
    begin
      count := 1;
      while (cal[i] <> '(') and (count <> 0) and (i >= 1) do
      begin
        dec(i);
        if cal[i] = ')' then
          count := count + 1;
        if cal[i] = '(' then
          count := count - 1;
      end;
      getprev := domuls(dopowers(copy(cal, i + 1, oldi - i - 1)));
      delete(cal, i, oldi - i + 1);
      dec(i);
    end;
   End;
  end;

  function getnext(var cal : string; i : integer) : extended;
  var
    oldi, sign, count : integer;
    temp : string;
  begin
    If Not Stop Then
    Begin
    oldi := i;
    inc(i);
    temp := '';
    sign := signs(cal, i);
    if cal[i] <> '(' then
    begin
      while (cal[i] in digits) and (i <= length(cal)) do
      begin
        temp := temp + cal[i];
        inc(i);
        if (cal[i - 1] = 'E') and (cal[i] in ['+', '-']) then
        begin
          temp := temp + cal[i];
          inc(i);
        end;
      end;
      getnext := sign * fval(temp);
      delete(cal, oldi, i - oldi);
    end
    else
    begin
      count := 1;
      temp := '';
      repeat
        inc(i);
        if cal[i] = '(' then
          count := count + 1;
        if cal[i] = ')' then
          count := count - 1;
        temp := temp + cal[i];
      until (cal[i] = ')') and (count = 0);
      delete(temp, length(temp), 1);
      getnext := sign * domuls(dopowers(temp));
      delete(cal, oldi, i - oldi + 1);
    end;
    End;
  end;

begin
  i := length(cal);
  repeat
    case cal[i] of
      '^' : begin
              x := getnext(cal, i);
              if cal[i - 1] = '!' then
              begin
                dec(i);
                c := fcnt(cal, i);
                f := getprev(cal, i);
                for c := 1 to c do
                  f := fact(f);
                insert(fstr(exp(x * logn(f))), cal, i + 1);
              end
              else
                insert(fstr(exp(x * logn(getprev(cal, i)))), cal, i + 1);
            end;

      '!' : begin
              c := fcnt(cal, i);
              f := getprev(cal, i);
              for c := 1 to c do
                f := fact(f);
              insert(fstr(f), cal, i + 1);
            end;

      else
        dec(i);
    end;
  until (i < 1) Or Stop;
  dopowers := cal;
end;

function dofuncs(cal : string) : string;
var
  i : integer;
  temp : string;

  function next3 : string;
  begin
    next3 := cal[i + 1] + cal[i + 2] + cal[i + 3];
  end;

  function asin(ratio : extended) : extended;
  begin
  If Not Stop Then
   Begin
    If (Ratio<>0) And (((1 - ratio) * (1 + ratio))>0) Then
    asin := arctan(ratio / sqrt((1 - ratio) * (1 + ratio)))
    Else
    Begin
     Result:=' Деление на 0 или квадратный корень из отрицательного числа! ';
     Stop:=True;
     Exit;
    End;
   End;
  end;

  function acos(ratio : extended) : extended;
  begin
  If Not Stop Then
   Begin
    If (Ratio<>0) And (((1 - ratio) * (1 + ratio))>0) Then
    acos := arctan(sqrt((1 - ratio) * (1 + ratio)) / ratio)
    Else
     Begin
     Result:=' Деление на 0 или квадратный корень из отрицательного числа! ';
     Stop:=True;
     Exit;
     End;
   End
  end;

  function atan(ratio : extended) : extended;
  begin
  If Not Stop Then
    atan := arctan(ratio);
  end;

  function tan(angle : extended) : extended;
  begin
  If Not Stop Then
    If Cos(Angle)<>0 Then
    tan := sin(angle) / cos(angle)
    Else
     Begin
      Result:=' Деление на 0 (косинус=0)! ';
      Stop:=True;
      Exit;
     End;

  end;

  function cot(angle : extended) : extended;
  begin
  If Not Stop Then
    If Sin(Angle)<>0 Then
    cot := cos(angle) / sin(angle)
    Else
     Begin
      Result:=' Деление на 0 (синус=0)! ';
      Stop:=True;
      Exit;
     End;
  end;

  function logn(x : extended) : extended;
  begin
  If Not Stop Then
    If x>0 Then
    logn := ln(x)
    Else
     Begin
      Result:=' Логарифм отрицательного числа! ';
      Stop:=True;
      Exit;
     End;
  End;

  function log(x : extended) : extended;
  begin
  If Not Stop Then
    If x>0 Then
    log := logn(x) / 2.302585093
    Else
     Begin
      Result:=' Логарифм отрицательного числа! ';
      Stop:=True;
      Exit;
     End;

  end;



Var N : Integer;
    Cal1: String;

begin
  Dofuncs[0]:=#0;
  i := 1;
  n := i;
  temp := '';
  If Not(Stop) Then;
  repeat
    case cal[i] of
      '+', '-',
      '*', '/',
      '(', ')',
      '^', '!' :If Not Stop Then
                    begin
                   temp := temp + cal[i];
                   inc(i);
                 end
                 Else Exit;

      'S' :If Not Stop Then
               begin
              if next3 = 'IN(' then
              begin
                inc(i, 3);
                temp := temp + fstr(sin(domuls(dopowers(dofuncs(getbrackets(cal, i))))));
                If Stop Then Exit;
              end
              else
              if next3 + cal[i + 4] = 'QRT(' then
              begin
                inc(i, 4);
                n:=i;
                Cal1:=Cal;
                If domuls(dopowers(dofuncs(getbrackets(cal1, n))))>0 Then
                Begin
                If Not Stop Then
                temp := temp + fstr(sqrt(domuls(dopowers(dofuncs(getbrackets(cal, i))))))
                Else Exit;
                If Stop Then Exit;
                End
                Else
                 Begin
                  Result:=' Квадратный корень из отрицательного числа! ';
                  Stop:=True;
                  Exit;
                 End;
              end
              else
                Begin
                error(cal, i);
                Stop:=True;
                Exit;
                End;
            end
             Else Exit;


      'C' :If Not Stop Then
               begin
              if next3 = 'OS(' then
              begin
                inc(i, 3);
                temp := temp + fstr(cos(domuls(dopowers(dofuncs(getbrackets(cal, i))))));
                If Stop Then Exit;
              end
              else
              if next3 = 'OT(' then
              begin
                inc(i, 3);
                temp := temp + fstr(cot(domuls(dopowers(dofuncs(getbrackets(cal, i))))));
                If Stop Then Exit;
              end
              else
                Begin
                error(cal, i);
                Stop:=True;
                Exit;
                End;
            end
              Else Exit;


      'T' :If Not Stop Then
               begin
              if next3 = 'AN(' then
              begin
                inc(i, 3);
                temp := temp + fstr(tan(domuls(dopowers(dofuncs(getbrackets(cal, i))))));
                If Stop Then Exit;
              end
              else
                Begin
                error(cal, i);
                Stop:=True;
                Exit;
                End;
            end
              Else Exit;


      'A' : If Not Stop Then
               begin
              if next3 + cal[i + 4] = 'TAN(' then
              begin
                inc(i, 4);
                temp := temp + fstr(atan(domuls(dopowers(dofuncs(getbrackets(cal, i))))));
                If Stop Then Exit;
              end
              else
              if next3 + cal[i + 4] = 'COS(' then
              begin
                inc(i, 4);
                temp := temp + fstr(acos(domuls(dopowers(dofuncs(getbrackets(cal, i))))));
                If Stop Then Exit;
              end
              else
              if next3 + cal[i + 4] = 'SIN(' then
              begin
                inc(i, 4);
                temp := temp + fstr(asin(domuls(dopowers(dofuncs(getbrackets(cal, i))))));
                If Stop Then Exit;
              end
              else
              if next3 = 'BS(' then
              begin
                inc(i, 3);
                temp := temp + fstr(abs(domuls(dopowers(dofuncs(getbrackets(cal, i))))));
                If Stop Then Exit;
              end
              else
                Begin
                error(cal, i);
                Stop:=True;
                Exit;
                End;
            end
              Else Exit;


      'L' : If Not Stop Then
            begin
              if next3 = 'OG(' then
              begin
                inc(i, 3);
                n:=i;
                Cal1:=Cal;
                If domuls(dopowers(dofuncs(getbrackets(cal1, n))))<>0 Then
                Begin
                If Not Stop Then
                temp := temp + fstr(log(domuls(dopowers(dofuncs(getbrackets(cal, i))))))
                Else Exit;
                If Stop Then Exit;
                End
                Else
                 Begin
                 Result:=' Логарифм отрицательного числа! ';
                 Stop:=True;
                 Exit;
                 End;
              end
              else
              if cal[i + 1] + cal[i + 2] = 'N(' then
              begin
                inc(i, 2);
                n:=i;
                Cal1:=Cal;
                If domuls(dopowers(dofuncs(getbrackets(cal1, n)))) <>0 Then
                Begin
                If Not Stop Then
                temp := temp + fstr(logn(domuls(dopowers(dofuncs(getbrackets(cal, i))))))
                Else Exit;
                If Stop Then Exit;
                End
                Else
                 Begin
                 Result:=' Логарифм отрицательного числа! ';
                 Stop:=True;
                 Exit;
                 End;

              end
              else
                Begin
                error(cal, i);
                Stop:=True;
                Exit;
                End;
            end
              Else Exit;


      'E' : If Not Stop Then
            if next3 = 'XP(' then
            begin
              inc(i, 3);
              temp := temp + fstr(exp(domuls(dopowers(dofuncs(getbrackets(cal, i))))));
              If Stop Then Exit;
            end
            Else Exit;


      'P' : If Not Stop Then
            if cal[i + 1] = 'I' then
            begin
              inc(i, 2);
              temp := temp + fstr(pi);
              If Stop Then Exit;
            end
            else
                Begin
                error(cal, i);
                Stop:=True;
                Exit;
                End;

      '0'..'9', '.' : If Not Stop Then

                      while (cal[i] in digits) and (i <= length(cal)) do
                      begin
                        temp := temp + cal[i];
                        inc(i);
                        if (cal[i - 1] = 'E') and (cal[i] in ['+', '-']) then
                        begin
                          temp := temp + cal[i];
                          inc(i);
                        end
                      end
                      Else Exit;

      else
                Begin
                error(cal, i);
                Stop:=True;
                Exit;
                End;
    end;
  until (i > length(cal)) Or (Stop);
  dofuncs := temp;
end;


Procedure TMyCalculator.Start;
var
  R : TRect;
  Control : PView;
  c:Word;

begin
R.Assign(41, 13, 79, 21);
New(CalculatorWindow, Init(R, 'Калькулятор'));
CalculatorWindow^.HelpCtx:=$E301;


R.Assign(2, 2, 36, 3);
ControlCalcLine := New(PInputLine, Init(R, CSertif));
ControlCalcLine^.Options := ControlCalcLine^.Options or ofFramed;
Wspom[0]:=#0;
Rashet[0]:=#0;
ControlCalcLine^.SetData(Rashet);
CalculatorWindow^.Insert(ControlCalcLine);

  R.Assign(33, 1, 36, 2);
  CalculatorWindow^.Insert(New(PHistory, Init(R, PInputline(ControlCalcLine), 55)));

R.Assign(2, 4, 9, 6);
ControlDigit := New(PRadioButtons, Init(R,
  NewSItem('~2~',
  NewSItem('~4~', Nil))));
ControlDigit^.Options := ControlDigit^.Options or ofFramed;
CalculatorWindow^.Insert(ControlDigit);

  R.Assign(2, 3, 7, 4);
  CalculatorWindow^.Insert(New(PLabel, Init(R, 'Man', ControlDigit)));

ControlDigit^.SetData(Man);
FreshTablo:=True;


Result:='           0.00';
R.Assign(10, 4, 36, 6);
ControlResult := New(PColoredText, Init(R, #3+Result, $31));
ControlResult^.Options := ControlResult^.Options or ofFramed;

CalculatorWindow^.Insert(ControlResult);

{
R.Assign(2, 4, 12, 5);
Control := New(PColoredText, Init(R, 'Результат:', $74));
CalculatorWindow^.Insert(Control);
}
CalculatorWindow^.SelectNext(False);

c:=Desktop^.ExecView(CalculatorWindow);

{Dispose(Control,Done);}
Dispose(CalculatorWindow,Done);
end;

Destructor TMyCalculator.Done;
Begin
Dispose(ControlResult,Done);
Dispose(ControlCalcLine,Done);
TDialog.Done;
End;

Procedure TMyCalculator.HandleEvent(Var Event:TEvent);
VAr Test : Word;
Begin

Case Event.KeyCode Of
 kbEnter,kbCtrlEnter : Begin
                        DelSpaceLeftRight(Rashet);
                        If Rashet[0]<>#0 Then
                        Begin
                        Message(Owner, evBroadcast, cmRecordHistory, nil);
                        DelSpaceLeftRight(Result);
                        ControlCalcLine^.SetDAta(Result);
                        PInputLine(ControlCalcLine)^.SelectAll(False);
                        Event.What:=EvKeyDown;
                        Event.KeyCOde:=kbEnd;
                        PutEvent(Event);
                        End;
                        ClearEvent(Event);
                       End;
Else;
End;

inherited Handleevent(Event);

If (Desktop^.Current=PView(CalculatorWindow)) And (Event.What <> EvKeyDown) Then
Begin
          if (ControlDigit^.State and sfFocused <> 0)Then
              Begin
               ControlDigit^.GetData(Test);
               If Test <> Man Then
               Begin
                FreshTablo:=True;
               End;
              End;

Refresh;
End;
End;

Procedure TMyCalculator.Refresh;
Var r : TRect;
    MAntissa:Word;
Begin

{ Result[0]:=#0;}

 ControlCalcLine^.GetData(wspom);
 ControlDigit^.GetData(Man);
 Case Man Of
 0:Mantissa:=2;
 1:Mantissa:=4;
 Else;
 End;

 If (Wspom<>Rashet) Or (FreshTablo) Then
 Begin
  FreshTablo:=False;
  Rashet:=Wspom;
  DelSpace(Wspom);

  if clean(wspom) And (Wspom[0]<>#0) then
  begin
    Stop:=False;
    answer := domuls(dopowers(dofuncs(Wspom)));
    If Not Stop Then
    Str(answer:CIZena:{CLitrMantissa+2}Mantissa,Result);
  end;
  Dispose(ControlResult,Done);

  R.Assign(10, 4, 36, 6);
  If Stop Then
  ControlResult := New(PColoredText, Init(R, #3+Result, $be))
  Else
  ControlResult := New(PColoredText, Init(R, #3+Result, $31));
  CalculatorWindow^.Insert(ControlResult);
 End;
End;

Begin
 Man:=0;
 FreshTablo:=True;
End.




