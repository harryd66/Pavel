program TestLFN; { TestLFN.PAS - test program for the file interface }
uses Lfn;      { by David Parsons, <david.parsons@virgin.net }

var
  F: Text;
  S: String;

begin
  WriteLn;
  WriteLn ('Opening for write');
  Assign  (F, 'Long.txt');
  Rewrite (F);
  WriteLn (F, 'Line 1');
  WriteLn (F, 'Line 2');
  WriteLn (F, 'Line 3');
  WriteLn ('Done');
  Close (F);

  Writeln(LFNRename ('Long.txt','LoonestName.csv'));

end.
