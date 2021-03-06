Uses Glob,ServStr,Objects,TPDate,Dos;

Type DocBazType1 = Record
     {Numer: string[CArtikul];}
     Seria : String[CLitr];
	Status: Boolean; {False - ᢮�����; True - �����}
     Data  : TDAteString;
     ClientKod : String[CClientKod];
     AgentKod  : String[CClientKod];
     DocSelector : Word;
     Document:String[CDocNumer];
     Locked : Boolean;
     DateDocument:String[CDate];
     Summa : String[CIZena];
     Proz  : String[CMantissa];
     DogovorNumer : String[CZena];
     DateC : TDateString;
     TimeC : TDateString;
     Caption : String[CRazdelKod];
     End;

Type
    PDocBazType = ^DocBazTypePtr;
    DocBazTypePtr=Object(TObject)
    Dat  :  DocBAzType1;
     Constructor Init;
     Destructor Done; Virtual;
    end;


var df : File Of DocBazType1;
    pd : PDocBazType;
    i:word;

Constructor DocBazTypePtr.Init;
Var i : Integer;
Begin
TObject.Init;
With DAt Do
Begin
     {Numer[0]:=#0;}
     Seria:=SeriaConst;
     Summa[0]:=#0;
     ClientKod[0]:=#0;
     AgentKod[0]:=#0;
     Proz :='0';
     DogovorNumer[0]:=#0;
     DocSelector:=0;
     DateC:=FDate;
	Status:=False; {False - ᢮�����; True - �����}
     Document[0]:=#0;
     DAteDocument[0]:=#0;
     DAta[0]:=#0;
     Locked:=False;
     Caption:=CurrentPAssword;
     DateC[0]:=#0;
     TimeC[0]:=#0;
End;{With}
End;{Constructor}

Destructor DocBazTypePtr.Done;
Begin
 TObject.Done;
End;


function LeadingZero(w : Word) : String;
var
  s : String;
begin
  Str(w:0,s);
  if Length(s) = 1 then
    s := '0' + s;
  LeadingZero := s;
end;


Function Times:TDateString;
Var h,m,s,hund : Word;
Begin
Times:=LeadingZero(h)+':'+LeadingZero(m)+':'+LeadingZero(s);
End;



BEGIN
Assign(df,'c:\veksel.db');
Reset(df);
New(pd,Init);

while not eof(df) do
 begin
   read(df,pd^.DAt);
 end;

 For i:=0 to 1999 Do
  Begin
   Pd^.Dat.Status :=False;
   Pd^.Dat.Locked :=False;
   Pd^.Dat.ClientKod[0] :=#0;
   Pd^.Dat.AgentKod[0] :=#0;

   Pd^.Dat.DocSelector :=0;

   Pd^.Dat.Document[0]:=#0;
   Pd^.Dat.DateDocument[0]:=#0;
   Pd^.Dat.Seria[0]:=#0;
   Pd^.Dat.Summa[0]:=#0;
   Pd^.Dat.Proz :='0';
   Pd^.Dat.DogovorNumer[0]:=#0;

   Write(df,pd^.Dat);
  End;
Dispose(pd,done);
Close(df);
END.