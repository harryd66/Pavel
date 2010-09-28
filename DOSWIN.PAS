Unit DosWin;

INTERFACE

Const

 koi82win: array[0..127] of byte = (
 $20, $20, $20, $20, $20, $20, $20, $20,
 $20, $20, $20, $20, $20, $20, $20, $20,
 $20, $20, $20, $20, $20, $95, $20, $20,
 $20, $20, $a0, $20, $b0, $20, $b7, $20,
 $20, $20, $20, $b8, $20, $20, $20, $20,
 $20, $20, $20, $20, $20, $20, $20, $20,
 $20, $20, $20, $a8, $20, $20, $20, $20,
 $20, $20, $20, $20, $20, $20, $20, $a9,
 $fe, $e0, $e1, $f6, $e4, $e5, $f4, $e3,
 $f5, $e8, $e9, $ea, $eb, $ec, $ed, $ee,
 $ef, $ff, $f0, $f1, $f2, $f3, $e6, $e2,
 $fc, $fb, $e7, $f8, $fd, $f9, $f7, $fa,
 $de, $c0, $c1, $d6, $c4, $c5, $d4, $c3,
 $d5, $c8, $c9, $ca, $cb, $cc, $cd, $ce,
 $cf, $df, $d0, $d1, $d2, $d3, $c6, $c2,
 $dc, $db, $c7, $d8, $dd, $d9, $d7, $da
);


alt2koi8: array[0..127] of byte = (
 $e1, $e2, $f7, $e7, $e4, $e5, $f6, $fa,
 $e9, $ea, $eb, $ec, $ed, $ee, $ef, $f0,
 $f2, $f3, $f4, $f5, $e6, $e8, $e3, $fe,
 $fb, $fd, $ff, $f9, $f8, $fc, $e0, $f1,
 $c1, $c2, $d7, $c7, $c4, $c5, $d6, $da,
 $c9, $ca, $cb, $cc, $cd, $ce, $cf, $d0,
 $90, $91, $92, $81, $87, $b2, $b4, $a7,
 $a6, $b5, $a1, $a8, $ae, $ad, $ac, $83,
 $84, $89, $88, $86, $80, $8a, $af, $b0,
 $ab, $a5, $bb, $b8, $b1, $a0, $be, $b9,
 $ba, $b6, $b7, $aa, $a9, $a2, $a4, $bd,
 $bc, $85, $82, $8d, $8c, $8e, $8f, $8b,
 $d2, $d3, $d4, $d5, $c6, $c8, $c3, $de,
 $db, $dd, $df, $d9, $d8, $dc, $c0, $d1,
 $b3, $a3, $99, $98, $93, $9b, $9f, $97,
 $9c, $95, $9e, $96, $bf, $9d, $94, $9a
);


function DosToWin(s:string):string;

IMPLEMENTATION

function DosToWin(s:string):string;

Const Digits=['0','1','2','3','4','5','6','7','8','9'];
var i: byte;
begin
  for i:=1 to word(s[0]) do
    begin
       IF Ord(s[i]) > 127 then
       begin
         s[i] := Chr(alt2Koi8[Ord(s[i])-128]);
         s[i] := Chr(Koi82Win[Ord(s[i])-128]);
       end;

       If i>1 Then
        Begin
         If s[i]='.' Then
          If s[i-1] in Digits Then s[i]:=',';
        End;

    end;
  DosToWin:=s;
end;

var f: file of byte;
    a: word;
BEGIN
(*  Assign(f,'c:\Dos2Win.bin');
  rewrite(f);
  for a:=0 to 127 do
  begin
   write(f,Koi82Win[a]);
  end;
  for a:=0 to 127 do
  begin
   write(f,alt2Koi8[a]);
  end;

  close(f); *)
END.

