Unit EgUtil;

INTERFACE

Uses Glob,ServStr;


procedure Proverka;
function TestKodEgais(FN: string;kod:ArtikulStr; var CodeAP,PartyID: string):boolean;

IMPLEMENTATION
Uses Utils,Utils4,Utils5,
     Objects,StHolder,Protect,DBEngine,
     Dialogs,DBIII,TpDate,NetCall,Dos,NetDbEng;


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



function TestKodEgais(FN: string;kod:ArtikulStr; var CodeAP,PartyID: string):boolean;
Var i: word;
    s: string;
    sKOd:ArtikulStr;
    t: text;
Begin
  TestKodEgais:=false;
  CodeAP:='';
  PartyID:='';

  Assign(t,FN);
  i:=ioresult;
  Reset(t);
  i:=ioresult;

  if i<>0 then
  begin
    {?}
    {AddLog(LogFile,'Ошибка открытия файла связей egais');}
    exit;
  end;

  while not eof(t) do
  begin
    readln(t,s);
    sKOd:=copy(s,2,CArtikul);
    sYstem.Delete(s,1,CArtikul+2);
    if StrToInt(skod)=StrToInt(kod) then
    begin
      CodeAP:=copy(s,1,pos(';',s)-1);
      System.Delete(s,1,pos(';',s));
      PartyID:=win2dos(s);
      i:=ioresult;
      System.Close(t);
      i:=ioresult;
      TestKodEgais:=true;
      break;
    end;
  end;

  i:=ioresult;
  System.Close(t);
  i:=ioresult;

End;

procedure Proverka;
var AP,ID: string;
Begin
 TestKodEgais('i:\egais\egais','23536',AP,ID);
 writeln(AP,'!',ID);
 readln;
End;


END.