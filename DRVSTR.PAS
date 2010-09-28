{$F+,O+,X+}

unit DrvStr;

interface

uses Objects, Drivers;

type

 PWordItem = ^TWordItem;
 TWordItem = object(TObject)
  Index  : word;
  Name   : PString;
  constructor Init(I: word; N: string);
  constructor Load(var S: TStream);
  procedure   Store(var S: TStream);
  destructor Done; virtual;
 end;

 PKbCollection = ^TKbCollection;
 TKbCollection = object(TCollection)
  constructor Init;
  constructor Load(var S: TStream);
  procedure Store(var S: TStream);
  function GetName(I: word): string;
 end;

 PCmCollection = ^TCmCollection;
 TCmCollection = object(TCollection)
  constructor Init;
  constructor Load(var S: TStream);
  procedure Store(var S: TStream);
  function GetName(I: word): string;
 end;

const

 RWordItem : TStreamRec = (
  ObjType: 999;
  VmtLink: Ofs(TypeOf(TWordItem)^);
  Load   : @TWordItem.Load;
  Store  : @TWordItem.Store);

 procedure RegisterDrvStr;

implementation

 constructor TWordItem.Init(I: word; N: string);
  begin
   TObject.Init;
   Index:=I;
   Name:=NewStr(N);
  end;

 constructor TWordItem.Load(var S: TStream);
  begin
   S.Read(Index, SizeOf(word));
   Name:=S.ReadStr;
  end;

 procedure TWordItem.Store(var S: TStream);
  begin
   S.Write(Index, SizeOf(word));
   S.WriteStr(Name);
  end;

 destructor TWordItem.Done;
  begin
   if Name <> nil then DisposeStr(Name);
   TObject.Done;
  end;

{ TKbCollection }

 constructor TKbCollection.Init;
  begin
   TCollection.Init(3, 3);
   Insert(New(PWordItem, Init($0000,'kbNoKey')));
   Insert(New(PWordItem, Init($011b,'kbEsc')));
   Insert(New(PWordItem, Init($0200,'kbAltSpace')));
   Insert(New(PWordItem, Init($0400,'kbCtrlIns')));
   Insert(New(PWordItem, Init($0500,'kbCtrlDel')));
   Insert(New(PWordItem, Init($0700,'kbShiftDel')));
   Insert(New(PWordItem, Init($0e08,'kbBack')));
   Insert(New(PWordItem, Init($0e7f,'kbCtrlBack')));
   Insert(New(PWordItem, Init($0f00,'kbShiftTab')));
   Insert(New(PWordItem, Init($0f09,'kbTab')));
   Insert(New(PWordItem, Init($1000,'kbAltQ')));
   Insert(New(PWordItem, Init($1100,'kbAltW')));
   Insert(New(PWordItem, Init($1200,'kbAltE')));
   Insert(New(PWordItem, Init($1300,'kbAltR')));
   Insert(New(PWordItem, Init($1400,'kbAltT')));
   Insert(New(PWordItem, Init($1500,'kbAltY')));
   Insert(New(PWordItem, Init($1600,'kbAltU')));
   Insert(New(PWordItem, Init($1700,'kbAltI')));
   Insert(New(PWordItem, Init($1800,'kbAltO')));
   Insert(New(PWordItem, Init($1900,'kbAltP')));
   Insert(New(PWordItem, Init($1c0a,'kbCtrlEnter')));
   Insert(New(PWordItem, Init($1c0d,'kbEnter')));
   Insert(New(PWordItem, Init($1e00,'kbAltA')));
   Insert(New(PWordItem, Init($1f00,'kbAltS')));
   Insert(New(PWordItem, Init($2000,'kbAltD')));
   Insert(New(PWordItem, Init($2100,'kbAltF')));
   Insert(New(PWordItem, Init($2200,'kbAltG')));
   Insert(New(PWordItem, Init($2300,'kbAltH')));
   Insert(New(PWordItem, Init($2400,'kbAltJ')));
   Insert(New(PWordItem, Init($2500,'kbAltK')));
   Insert(New(PWordItem, Init($2600,'kbAltL')));
   Insert(New(PWordItem, Init($2c00,'kbAltZ')));
   Insert(New(PWordItem, Init($2d00,'kbAltX')));
   Insert(New(PWordItem, Init($2e00,'kbAltC')));
   Insert(New(PWordItem, Init($2f00,'kbAltV')));
   Insert(New(PWordItem, Init($3000,'kbAltB')));
   Insert(New(PWordItem, Init($3100,'kbAltN')));
   Insert(New(PWordItem, Init($3200,'kbAltM')));
   Insert(New(PWordItem, Init($3b00,'kbF1')));
   Insert(New(PWordItem, Init($3c00,'kbF2')));
   Insert(New(PWordItem, Init($3d00,'kbF3')));
   Insert(New(PWordItem, Init($3e00,'kbF4')));
   Insert(New(PWordItem, Init($3f00,'kbF5')));
   Insert(New(PWordItem, Init($4000,'kbF6')));
   Insert(New(PWordItem, Init($4100,'kbF7')));
   Insert(New(PWordItem, Init($4200,'kbF8')));
   Insert(New(PWordItem, Init($4300,'kbF9')));
   Insert(New(PWordItem, Init($4400,'kbF10')));
   Insert(New(PWordItem, Init($4700,'kbHome')));
   Insert(New(PWordItem, Init($4800,'kbUp')));
   Insert(New(PWordItem, Init($4900,'kbPgUp')));
   Insert(New(PWordItem, Init($4a2d,'kbGrayMinus')));
   Insert(New(PWordItem, Init($4b00,'kbLeft')));
   Insert(New(PWordItem, Init($4d00,'kbRight')));
   Insert(New(PWordItem, Init($4e2b,'kbGrayPlus')));
   Insert(New(PWordItem, Init($4f00,'kbEnd')));
   Insert(New(PWordItem, Init($5000,'kbDown')));
   Insert(New(PWordItem, Init($5100,'kbPgDn')));
   Insert(New(PWordItem, Init($5200,'kbIns')));
   Insert(New(PWordItem, Init($5300,'kbDel')));
   Insert(New(PWordItem, Init($5400,'kbShiftF1')));
   Insert(New(PWordItem, Init($5500,'kbShiftF2')));
   Insert(New(PWordItem, Init($5600,'kbShiftF3')));
   Insert(New(PWordItem, Init($5700,'kbShiftF4')));
   Insert(New(PWordItem, Init($5800,'kbShiftF5')));
   Insert(New(PWordItem, Init($5900,'kbShiftF6')));
   Insert(New(PWordItem, Init($5a00,'kbShiftF7')));
   Insert(New(PWordItem, Init($5b00,'kbShiftF8')));
   Insert(New(PWordItem, Init($5c00,'kbShiftF9')));
   Insert(New(PWordItem, Init($5d00,'kbShiftF10')));
   Insert(New(PWordItem, Init($5e00,'kbCtrlF1')));
   Insert(New(PWordItem, Init($5f00,'kbCtrlF2')));
   Insert(New(PWordItem, Init($6000,'kbCtrlF3')));
   Insert(New(PWordItem, Init($6100,'kbCtrlF4')));
   Insert(New(PWordItem, Init($6200,'kbCtrlF5')));
   Insert(New(PWordItem, Init($6300,'kbCtrlF6')));
   Insert(New(PWordItem, Init($6400,'kbCtrlF7')));
   Insert(New(PWordItem, Init($6500,'kbCtrlF8')));
   Insert(New(PWordItem, Init($6600,'kbCtrlF9')));
   Insert(New(PWordItem, Init($6700,'kbCtrlF10')));
   Insert(New(PWordItem, Init($6800,'kbAltF1')));
   Insert(New(PWordItem, Init($6900,'kbAltF2')));
   Insert(New(PWordItem, Init($6a00,'kbAltF3')));
   Insert(New(PWordItem, Init($6b00,'kbAltF4')));
   Insert(New(PWordItem, Init($6c00,'kbAltF5')));
   Insert(New(PWordItem, Init($6d00,'kbAltF6')));
   Insert(New(PWordItem, Init($6e00,'kbAltF7')));
   Insert(New(PWordItem, Init($6f00,'kbAltF8')));
   Insert(New(PWordItem, Init($7000,'kbAltF9')));
   Insert(New(PWordItem, Init($7100,'kbAltF10')));
   Insert(New(PWordItem, Init($7200,'kbCtrlPrtSc')));
   Insert(New(PWordItem, Init($7300,'kbCtrlLeft')));
   Insert(New(PWordItem, Init($7400,'kbCtrlRight')));
   Insert(New(PWordItem, Init($7500,'kbCtrlEnd')));
   Insert(New(PWordItem, Init($7600,'kbCtrlPgDn')));
   Insert(New(PWordItem, Init($7700,'kbCtrlHome')));
   Insert(New(PWordItem, Init($7800,'kbAlt1')));
   Insert(New(PWordItem, Init($7900,'kbAlt2')));
   Insert(New(PWordItem, Init($7a00,'kbAlt3')));
   Insert(New(PWordItem, Init($7b00,'kbAlt4')));
   Insert(New(PWordItem, Init($7c00,'kbAlt5')));
   Insert(New(PWordItem, Init($7d00,'kbAlt6')));
   Insert(New(PWordItem, Init($7e00,'kbAlt7')));
   Insert(New(PWordItem, Init($7f00,'kbAlt8')));
   Insert(New(PWordItem, Init($8000,'kbAlt9')));
   Insert(New(PWordItem, Init($8100,'kbAlt0')));
   Insert(New(PWordItem, Init($8200,'kbAltMinus')));
   Insert(New(PWordItem, Init($8300,'kbAltEqual')));
   Insert(New(PWordItem, Init($8400,'kbCtrlPgUp')));
  end;

 constructor TKbCollection.Load(var S: TStream);
  begin
   TCollection.Load(S);
  end;

 procedure TKbCollection.Store(var S: TStream);
  begin
   TCollection.Store(S);
  end;

 function TKbCollection.GetName(I: word): string;
  var D: PWordItem;
  function FindIndex(P: PWordItem): boolean;
   begin
    if P^.Index = I then FindIndex:=True
    else FindIndex:=False;
   end;
  begin
   D:=FirstThat(@FindIndex);
   GetName:='';
   if D <> Nil then
    if D^.Name <> Nil then
     GetName:=D^.Name^;
  end;

{ TCmCollection }

 constructor TCmCollection.Init;
  begin
   TCollection.Init(3, 3);
   Insert(New(PWordItem, Init(0,'cmValid')));
   Insert(New(PWordItem, Init(1,'cmQuit')));
   Insert(New(PWordItem, Init(2,'cmError')));
   Insert(New(PWordItem, Init(3,'cmMenu')));
   Insert(New(PWordItem, Init(4,'cmClose')));
   Insert(New(PWordItem, Init(5,'cmZoom')));
   Insert(New(PWordItem, Init(6,'cmResize')));
   Insert(New(PWordItem, Init(7,'cmNext')));
   Insert(New(PWordItem, Init(8,'cmPrev')));
   Insert(New(PWordItem, Init(9,'cmHelp')));
   Insert(New(PWordItem, Init(20,'cmCut')));
   Insert(New(PWordItem, Init(21,'cmCopy')));
   Insert(New(PWordItem, Init(22,'cmPaste')));
   Insert(New(PWordItem, Init(23,'cmUndo')));
   Insert(New(PWordItem, Init(24,'cmClear')));
   Insert(New(PWordItem, Init(25,'cmTile')));
   Insert(New(PWordItem, Init(26,'cmCascade')));
   Insert(New(PWordItem, Init(10,'cmOk')));
   Insert(New(PWordItem, Init(11,'cmCancel')));
   Insert(New(PWordItem, Init(12,'cmYes')));
   Insert(New(PWordItem, Init(13,'cmNo')));
   Insert(New(PWordItem, Init(14,'cmDefault')));
   {Insert(New(PWordItem, Init(,'')));}
  end;

 constructor TCmCollection.Load(var S: TStream);
  begin
   TCollection.Load(S);
  end;

 procedure TCmCollection.Store(var S: TStream);
  begin
   TCollection.Store(S);
  end;

 function TCmCollection.GetName(I: word): string;
  var D: PWordItem;
  function FindIndex(P: PWordItem): boolean;
   begin
    if P^.Index = I then FindIndex:=True
    else FindIndex:=False;
   end;
  begin
   D:=FirstThat(@FindIndex);
   GetName:='';
   if D <> Nil then
    if D^.Name <> Nil then
     GetName:=D^.Name^;
  end;

 procedure RegisterDrvStr;
  begin
   RegisterType(RWordItem);
  end;

end.
