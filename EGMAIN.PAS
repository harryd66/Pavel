Uses Objects,
     Dialogs, Drivers;


var t,rez: text;
    i: word;
    E,EE: PBox;
    RR: Trect;
    AP,Party: String;
    s: string;

function win2dos(s:string):string;
var
  Insymbol, Outsymbol: char;
  Innumber, Outnumber: word;
  i:word;
Begin
  win2dos:='';
  for i:=1 to length(s)+1 do
  begin
   insymbol:=s[i];
   innumber:=ord(insymbol);
   if innumber in [192..255] then
                if innumber in [192..239] then
                   outnumber := innumber-64
                else outnumber := innumber-16
             else outnumber := innumber;
             if innumber = 133 then innumber := 168;
             if innumber = 165 then innumber := 184;
   outsymbol:=chr(outnumber);
   s[i]:=outsymbol;
   end;
   win2dos:=s;
End;


BEGIN
  Assign(rez,'d:\eg\egparty.csv');
  i:=ioresult;
  rewrite(rez);
  i:=ioresult;

  Assign(t,'d:\eg\egais');
  i:=ioresult;
  reset(t);
  i:=ioresult;



  RR.Assign(0, 0, 0, 0);
  E := New(PBox, Init(RR, 1, Nil));
  E^.NewList(New(PTextCollection, Init(0,1)));

   RR.Assign(0, 0, 0, 0);
  EE := New(PBox, Init(RR, 1, Nil));
  EE^.NewList(New(PTextCollection, Init(0,1)));

  i:=0;
  while not eof(t) do
  begin
   readln(t,s);
   sYstem.Delete(s,1,5+2);
   System.Delete(s,1,pos(';',s));
   S:=win2dos(s);
   if i<MaxCollectionSize then
   begin
    E^.List^.Insert(NewStr(s));
    E^.SetRange(E^.List^.Count);
   end
   else
   begin
    EE^.List^.Insert(NewStr(s));
    EE^.SetRange(EE^.List^.Count);
   end;
   writeln(i,' ',s);
   inc(i);
  end;

  writeln(1);

  if E^.List^.Count>0 then
  for i:=0 to E^.List^.Count-1 do
  begin
    s:='';
    s:=E^.GetText(i,E^.List^.Count);
    writeln(rez,s);
  end;

  if EE^.List^.Count>0 then
  for i:=0 to EE^.List^.Count-1 do
  begin
    s:='';
    s:=EE^.GetText(i,EE^.List^.Count);
    writeln(rez,s);
  end;


  Dispose(E,Done);
  Dispose(EE,Done);
  close(rez);
  close(t);

END.