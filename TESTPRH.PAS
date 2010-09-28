{$IfNDEF DPMI}
{$F+}
{$O+}
{$EndIf}


{$I Compile.INC}
Unit TestPrh;

INTERFACE

Uses Glob;

function TestEqualTovar(As:DocumentEditZ):boolean;

{обнаруживает позиции товра с одинаковым кодом товара, но разными
 Сериями,ГТД,Сертификатами выдает окно с перецнем позиций товара,
 результат - TRUE при OK, FALSE при ESC

 использование в модуле PRIHODI.PAS
 Procedure InputPrihodToSklad(As : DocumentEditZ);
 if not TestEqualTovar(As) then exit;}

IMPLEMENTATION

uses DBEngine,Objects,Views,MsgBox,TpDate,Serv,
     ServStr,Dialogs,Drivers,
     App,ColorTxt,DBEngin2,ServStr2,Net,NetDbEng,Utils5;

Type
  PTestEqualPosition = ^TTestEqualPosition;
  TTestEqualPosition = object(TDialog)
    procedure Refresh;
    procedure HandleEvent(var Event: TEvent); virtual;
    Destructor Done;Virtual;
  end;



var WArnBox: PBox;
    WarningList: PBox;
    TestW: PTestEqualPosition;
    ControlSpMarka,ControlMarka,ControlGTD,ControlSert,
    ControlPost: PView;
    PrevS : PString;


function FindOldTovar(As:DocumentEditZ): boolean;


var IORez: word;
    E,ET: PPrihodType;
    s: string;
    i,j: word;
    f: PrihodFileType;
Begin
  FindOldTovar:=FALSE;
  Assign(F,Path^.Dat.ToPrihod+As.D+'.prh');
  IOrez:=IOResult;
  Reset(f);
  IOrez:=Ioresult;
  If IOrez <> 0 Then
  begin
    exit;
  end;

  New(E,Init);

  IOrez:=Lockprihod(As,E,False);
  If IOrez=2 Then
     Begin
      Dispose(E,Done);
      IOrez:=Ioresult;
      Close(f);
      IOrez:=Ioresult;
      Exit;
     End;

  UnLockPrihod(E^.Dat.Document,E^.Dat.DateC);

  while not eof(f) do
  begin
    New(ET,Init);
    ReadPrihod(f,ET);
    if ET^.Dat.StatusDoc=0 then {введенные на склад}
    if StrToInt(E^.Dat.Document)<>StrtoInt(ET^.Dat.Document) then
    {если не текущий документ }
    for i:=1 to ET^.Dat.Amount do
    begin
      for j:=1 to E^.Dat.Amount do
      begin
        if {по коду}
        ET^.Dat.PrihodElement[i].BazKOd=E^.Dat.PrihodElement[j].BazKOd  then
        if (ET^.Dat.PrihodElement[i].Input.Marka<>E^.Dat.PrihodElement[j].Input.Marka)
        or (ET^.Dat.PrihodElement[i].Input.NGTD<>E^.Dat.PrihodElement[j].Input.NGTD)
        or (ET^.Dat.PrihodElement[i].Input.NSertif<>E^.Dat.PrihodElement[j].Input.NSertif) then
        begin
         s:='';

         rFormat(ET^.Dat.Document,CDocNumer);
         s:=ET^.Dat.PrihodElement[i].BazKOd+'│'+ET^.Dat.Document+'│';

         s:=s+ET^.Dat.PrihodElement[i].Input.SpecMarka+'│';

         s:=s+ET^.Dat.PrihodElement[i].Input.Marka+'│';

         s:=s+ET^.Dat.PrihodElement[i].Input.NGTD+'│';

         s:=s+ET^.Dat.PrihodElement[i].Input.NSertif+'│';

         s:=s+ET^.Dat.PrihodElement[i].Input.NMakeKod+'│';

         WarnBox^.List^.Insert(NewStr(s));
         WarnBox^.SetRange(WarnBox^.List^.Count);

         s:='';

         rFormat(E^.Dat.Document,CDocNumer);
         s:=E^.Dat.PrihodElement[j].BazKOd+'│'+E^.Dat.Document+'│';

         s:=s+E^.Dat.PrihodElement[j].Input.SpecMarka+'│';

         s:=s+E^.Dat.PrihodElement[j].Input.Marka+'│';

         s:=s+E^.Dat.PrihodElement[j].Input.NGTD+'│';

         s:=s+E^.Dat.PrihodElement[j].Input.NSertif+'│';

         s:=s+E^.Dat.PrihodElement[j].Input.NMakeKod+'│';

         WarnBox^.List^.Insert(NewStr(s));
         WarnBox^.SetRange(WarnBox^.List^.Count);

         FindOldTovar:=true;
        end;
      end;
    end;
    Dispose(ET,Done);
  end;
  IOrez:=Ioresult;
  Dispose(E,Done);
  IOrez:=Ioresult;
  Close(f);
  IOrez:=Ioresult;
End;






function TestEqualTovar(As:DocumentEditZ):boolean;
var R:TRect;
    i: word;
    s: string;
    Control: PView;
    sKod:ArtikulStr;
    sNAme: string[CName];
BEGIN

TestEqualTovar:=false;


If Pharm=0 Then
 Begin
  TestEqualTovar:=True;
  Exit;
 End;

R.Assign(0,0,0,0);
WarnBox := New(PBox, Init(R, 1, Nil));
WarnBox^.NewList(New(PTextCollection, Init(0,1)));


if FindOldTovar(As) then
Begin
AddProtocol('Предупреждение о поступлении на склад товаров с дублирующимися параметрами','','');

SpecialBeep;
R.Assign(8, 2, 72, 22);
New(TestW, Init(R, 'Внимание'));
TestW^.Options := TestW^.Options or ofCenterX or ofCenterY;

TestW^.HelpCtx:=$F020;

s:='Обнаружены дублирующиеся позиции в документах прихода!';

R.Assign(1, 1, 63, 3);
Control := New(PColoredText, Init(R, ^M+#3+S, $5e));
TestW^.Insert(Control);

R.Assign(63, 4, 64, 14);
Control := New(PScrollBar, Init(R));
TestW^.Insert(Control);

R.Assign(1, 4, 63, 14);
WarningList := New(PBox, Init(R, 1, PScrollbar(Control)));
WarningList^.NewList(New(PTextCollection, Init(0,1)));

for i:=0 to WarnBox^.List^.Count-1 do
begin
  s:=WarnBox^.GetText(i,WarnBox^.List^.Count);
  sName:=GetIdField(FName,copy(s,1,CArtikul));
  Format(sName,CName);
  s:=sName+'│'+s;
  WarningList^.List^.Insert(NewStr(s));
  WarningList^.SetRange(WarnBox^.List^.Count);
end;


WarningList^.FocusItem(0);
TestW^.Insert(WarningList);

  R.Assign(1, 3, 63, 4);
  TestW^.Insert(New(PLabel, Init(R, 'Наименование товара         Код  Nдок Сп.м  '+Seria_Akzis^+'  ГТД  Серт.', WarningList)));
                                                               {12345 1234 12345 12345 12345 12345}
R.Assign(1, 14, 63, 15);
ControlSpMarka := New(PColoredText, Init(R, 'СпецМарка', $7e));
TestW^.Insert(ControlSpMarka);

R.Assign(1, 15, 63, 16);
ControlMarka := New(PColoredText, Init(R, 'Марка', $7e));
TestW^.Insert(ControlMarka);

R.Assign(1, 16, 63, 17);
ControlGTD := New(PColoredText, Init(R, 'ГТД', $7e));
TestW^.Insert(ControlGTD);

R.Assign(1, 17, 63, 18);
ControlSert := New(PColoredText, Init(R, 'Сертификат', $7e));
TestW^.Insert(ControlSert);

R.Assign(1, 18, 63, 19);
ControlPost := New(PColoredText, Init(R, 'Поставщик', $7e));
TestW^.Insert(ControlPost);

TestW^.SelectNext(False);

PrevS:=NewStr('Test');

TestW^.Refresh;

if DeskTop^.ExecView(TestW)=cmOk then TestEqualTovar:=true;
Dispose(Control,Done);
Dispose(WarningList,Done);
Dispose(TestW,Done);
DisposeStr(PrevS);
end
 Else TestEqualTovar:=true;

Dispose(WarnBox,Done);


END;

procedure TTestEqualPosition.Refresh;
var s: string;
    sArt:ArtikulStr;
    R: TRect;
Begin
If (WarningList^.List<>Nil)And(WarningList^.List^.Count>=1) Then
  Begin
   s:=WarningList^.GetText(WarningList^.Focused,WarningList^.List^.Count);
   If s<>PrevS^ Then
   Begin

    DisposeStr(PrevS);
    PrevS:=NewStr(s);

sArt:=Copy(s,1+CName+1+CArtikul+1+CDocNumer+1,CArtikul);
Dispose(ControlSpMarka,Done);
R.Assign(1, 14, 63, 15);
ControlSpMarka := New(PColoredText, Init(R, ' Спец.Марка : '+GetSpecMarkaField(FName,sArt), $7e));
TestW^.Insert(ControlSpMarka);
sArt:=Copy(s,1+CName+1+CArtikul+1+CDocNumer+1+CArtikul+1,CArtikul);
Dispose(ControlMarka,Done);
R.Assign(1, 15, 63, 16);
ControlMarka := New(PColoredText, Init(R,   '      '+Seria_Akzis^+' : '+GetMarkaField(FName,sArt), $7e));
TestW^.Insert(ControlMarka);
sArt:=Copy(s,1+CName+1+CArtikul+1+CDocNumer+1+CArtikul+1+CArtikul+1,CArtikul);
Dispose(ControlGTD,Done);
R.Assign(1, 16, 63, 17);
ControlGTD := New(PColoredText, Init(R,  '       ГТД  : '+GetNGTDField(FName,sArt), $7e));
TestW^.Insert(ControlGTD);
sArt:=Copy(s,1+CName+1+CArtikul+1+CDocNumer+1+CArtikul+1+CArtikul+1+CArtikul+1,CArtikul);
Dispose(ControlSert,Done);
R.Assign(1, 17, 63, 18);
ControlSert := New(PColoredText, Init(R, ' Сертификат : '+GetIdField(FName,sArt), $7e));
TestW^.Insert(ControlSert);
sArt:=Copy(s,1+CName+1+CArtikul+1+CDocNumer+1+CArtikul+1+CArtikul+1+CArtikul+1+CArtikul+1,CArtikul);
Dispose(ControlPost,Done);
R.Assign(1, 18, 63, 19);
ControlPost := New(PColoredText, Init(R, ' Поставщик  : '+
GetMakeField(FName,Copy(sArt,2,CClientKod),StrToInt(Copy(sArt,1,COne))), $7e));
TestW^.Insert(ControlPost);

   End;
  End;
End;

procedure TTestEqualPosition.HandleEvent(var Event: TEvent);
Begin
 Inherited HandleEvent(Event);
   If (Desktop^.Current=PView(TestW)) And (Event.What <> EvKeyDown) Then
             Begin
            if (WarningList^.List<>Nil)And(WarningList^.List^.Count>=1) Then
              Begin
               Refresh;
              End;
             End;
End;

Destructor TTestEqualPosition.Done;
Begin
 Dispose(ControlSpMarka,Done);
 Dispose(ControlMarka,Done);
 Dispose(ControlGTD,Done);
 Dispose(ControlSert,Done);
 Dispose(ControlPost,Done);
 Inherited Done;
End;


BEGIN
END.