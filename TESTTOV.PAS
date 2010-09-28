Unit TestTov;

INTERFACE

Uses Glob,ServStr,Dialogs,Drivers,Serv;

Type
  PSelectTovWindow = ^TSelectTovWindow;
  TSelectTovWindow = object(TDialog)
    procedure DrawCurrent;
    procedure Refresh;
    procedure HandleEvent(var Event: TEvent); virtual;
    Destructor Done; virtual;
  end;


Function SelectTov : Boolean;

IMPLEMENTATION

uses ColorTxt, Objects, Views, MsgBox, Vision1,TpDate,Validate, App,
     DBENGINe,DBENGIN2, printers, Tools, NetDbEng, Utils;


var
 bTov: boolean;
 PrevCurrent:string;
 TovWin : PSelectTovWindow;
 TovFile: File of BazType;
 TovSelect: PBox;
 TovList: PBox;
 TovTest: PBox;
 CountControl: PView;
 sControlDop: PView;
 RazdelControl: PView;
 RazdelCount, RazdelStatus: word;
 mms: Maska;
 UnPack: word;
 c,c1,Count : Word;

Function TestName (Const S : AllStr;Const P : PBox;Const SortN : Word) : Boolean;
Var ls : Word;
    k  : Word;
    st  : String;
Begin
TestName:=True;
If P^.List^.Count>=1 Then
Begin
For ls :=0 To P^.List^.Count-1 Do
Begin
St:=P^.GetText(ls,P^.List^.Count);
{If SortN=0 Then}
k:=Pos('│',St);{может стоять $}
{Else k:=Ord(s[0])-1-CArtikul;}

ST:=Copy(St,1,CName)+copy(St,1+CName+1+CArtikul+1,CName);

If St=S Then
   Begin
    TestName:=False;
    Break;
   End;
End;
End;
End;





Function SelectTov : Boolean;
var R : TRect;
    PostControl,Control: PView;
    CC , IORez, ls: word;
    s: string;
    rr: RazdelType;
    fr: file of RazdelType;
    fid: File;
    id: PBufBazType;
    sRazd : string[CRazdelKOd];
    sKOd: string[CKod];
    {fini: text;}

procedure TestTovar;
var db: PSkladType;
    fdb: file of SkladType;
    nskl: word;
    r: string[CRazdelKod];
    sKod: string[CKod];
    Kod, Code: word;
    sArt: string[CArtikul];
    st: string;
    sKOl:string[CKol];
    i: word;
BEGIN

If (TovSelect^.List<>Nil)And(TovSelect^.List^.Count>0)  Then
begin
 for i:=0 to TovSelect^.List^.Count-1 do
 begin
  DInfoMsgShkala('Тестирую позиции товаров ...',0,TovSelect^.List^.Count-1,i);
  st:=TovSelect^.GetText(i,TovSelect^.List^.COunt);
  sArt:=copy(st,1+CNAME+1,CArtikul);
  r:=copy(sArt,1,CRazdelKod);
  sKOd:=copy(sArt,3,CKod);
  Kod:=StrToInt(sKod);
  sKol:='0';
  for nskl:=1 to Max30 do
   begin
     DelSpace(PathSklads^.Dat.Path[nskl]);
     if PathSklads^.Dat.Path[nskl]<>'' then
     begin
       Assign(fdb,PathSklads^.Dat.Path[nSkl]+'MAIN\'+r+'.db');
       IORez:=ioresult;
       reset(fdb);
       IORez:=ioresult;
       if IORez<>0 then
         begin
           ;
         end;
       New(db,Init);
       IORez:=ioresult;
       seek(fdb,KOd);
       IORez:=ioresult;
       read(fdb,db^.Dat);
       IORez:=ioresult;
       str(StrToInt(sKOl)+StrToInt(db^.Dat.Input.kol):CKOl,sKOl);
       system.close(fdb);
       Dispose(db,Done);
     end; {PathSklads^.Dat.Path[nskl]<>''}
   end; {for nskl:=1 to Max30 do}

  system.Delete(st,1+CName+1+CArtikul+1+CName+1,CKol);
  st:=st+sKOl;
  TovTest^.List^.Insert(NewStr(st));
 end; {for i:=0 to TovSelect^.List^.Count-1 do}
 NoInfoMsg;
end;

END;

procedure PrintTestFile;
var t:text;
    i, IOrez: word;
    st: string;
    sName, sOldName: string[CName+1+CName];
    sArt: string[CArtikul];
    sKOl: string[CKOl];
    sR: string[CRazdelKod];
    sKOd: string[CKOd];
    KOd, Code: word;
    npp: word;
    sGodnost: String[CDSertif];
    sMarka: String[CNSertif];
    sSpecMarka:  String[CSpecMArka];
    sMarkaKod: string[CArtikul];


BEGIN
   DInfoMSG('Формирую отчет...',false);
   Assign(t,Path^.Dat.ToTemp+'test.txt');
   IORez:=ioresult;
   Rewrite(t);
   IORez:=ioresult;
   if IORez<>0 then
     begin
     end;
sOldName:='';
npp:=1;
If (TovTest^.List<>Nil)And(TovTest^.List^.Count>0)  Then
for i:=0 to TovTest^.List^.Count - 1 do
begin
  st:=TovTest^.GetText(i,TovTest^.List^.COunt);
  sName:=copy(st,1,CName)+' '+copy(st,1+CName+1+CArtikul+1,CName);
  sArt:=copy(st,1+CName+1,CArtikul);
  sKol:=copy(st,1+CName+1+CArtikul+1+CName+1,CKOl);
  if sName<>sOldName then
    BEGIN
      writeln(t);
      writeln(t,'_____________________________________________________________________________________________');
      writeln(t,npp:4,'. ',sName);
      sOldName:=sName;
      inc(npp);
    END;
   write(t,'Код: ',SArt,' ');
   sr:=copy(sArt,1,2);
   sKOd:=copy(sArt,3,3);
   val(sKOd,KOd,Code);
   if StrToInt(sKol)=0 then writeln(t,' - свободен')
   else
    begin
     {СпецМарка}
     sMarkaKod:= BakGetField(FSpecMarka,sArt,0);
     sSpecMarka:=GetSpecMarkaField(FName,sMarkaKod);
     format(sSpecMarka,CSpecMArka);
     {Акциз}
     sMarkaKod:=BakGetField(FMarka,sArt,0);
     sMarka:=GetMarkaField(FNAme,sMarkaKod);
     format(sMarka,CNSertif);
     {Реализ. до:}
     sGodnost:=BakGetField(FGodnost,sArt,0);
     format(sGodnost,CDSertif);
     writeln(t,' - Дата выработки: ',BakGetField(FVirabotano,sArt,0),' Реализ. до: ',sGodnost);
     writeln(t,'            Акциз: ',sMarka,' Спец. марка: ',sSpecMarka);
    end;
end;
   writeln(t);
   Writeln(t,' Отпечатано:"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
   writeln(t,'=============================================================================================');
   IORez:=ioresult;
   Close(t);
   IORez:=ioresult;
   NoInfoMsg;
   ViewAsText(Path^.Dat.ToTemp+'test.txt','Тест свободных позиций',True);
   Report(Path^.Dat.ToTemp+'test.txt','',1,False,False);
END;


Begin


R.Assign(2, 2, 77, 22);
New(TovWin, Init(R, 'Выбор наименований'));
TovWin^.Options := TovWin^.Options or ofCenterX or ofCenterY;
TovWin^.HelpCtx:=$E002;


R.Assign(3,2,35,3);
RazdelControl := New(PRadioButtons, Init(R,
 NewSItem('0-16',
 NewSItem('17-58',
 NewSItem('59-99', Nil)))));
TovWin^.Insert(RazdelControl);


R.Assign(48, 18, 56, 19);
CountControl := New(PInputLine, Init(R,6));
CountControl^.HideCursor;
TovWin^.Insert(CountControl);

  R.Assign(34, 18, 48, 19);
  TovWin^.Insert(New(PLabel, Init(R, 'Всего выбрано', CountControl)));


R.Assign(36, 4, 37, 16);
Control := New(PScrollBar, Init(R));
TovWin^.Insert(Control);

R.Assign(3, 17, 55, 18);
sControlDop := New(PColoredText, Init(R, #3+'', $7E));
TovWin^.Insert(sControlDop);



R.Assign(3, 4, 36, 16);
TovList:= New(PBox, Init(R, 1, PScrollbar(Control)));
TovList^.NewList(New(PTextCollection, Init(1,1)));
Assign (fr,PathSklads^.Dat.Path[4]+'main\razdel.db');
IORez:=ioresult;
Reset (fr);
IORez:=ioresult;
 if iorez<>0 then
   begin
    MessageBox(#3'Не могу открыть файл'+PathSklads^.Dat.Path[4]+'main\razdel.db'
    ,nil,mfError+mfCancelButton);
    exit;
   end;

RazdelStatus:=0;
While Not(Eof(fr)) Do
 Begin
  Read(fr,rr);
  DInfoMsgShkala('Формирую список товаров ...',0,FileSize(fr),FilePos(fr));
  If (rr.Employ) and (rr.EnableDoc=0) and (rr.EnableLitr=1) And (StrToInt(rr.kod) <= 16) Then
   Begin
     sRazd:=rr.Kod;
     Assign(fid,PathSklads^.Dat.Path[4]+'id\'+sRazd+'.id');
      iorez:=ioresult;
      Reset(fid,SizeOf(BazType));
      iorez:=ioresult;
      if iorez<>0 then
      begin
        Writeln(PathSklads^.Dat.Path[4]+'id\'+sRazd+'.id');
        exit;
      end;
      new(id,Init);
      while not eof(fid) do
      begin
        {Format (id.Name,CClient);}
        ReadBufBaz(fid,id,count);
        For cc:=1 To Count Do
        Begin
         If id^.Point.Dat[cc].Employ Then
         begin
           format(id^.Point.Dat[cc].Name,CName);
           format(id^.Point.Dat[cc].name2,CName);
           TovList^.List^.Insert(NewStr(id^.Point.Dat[cc].Name+'│'+id^.Point.Dat[cc].BazKod+'│'+id^.Point.Dat[cc].Name2
              +'│    0'));
           TovList^.SetRange(TovList^.List^.Count);
         end;
        end;
      end;
      Dispose(id,Done);
      IORez:=ioresult;
      System.Close(fid);
      IORez:=ioresult;
   End;
 End;
NoInfoMsg;
IORez:=ioresult;
System.Close(fr);
IORez:=ioresult;

TovList^.FocusItem(0);
TovList^.HelpCtx:=$E044;
TovWin^.Insert(TovList);

  R.Assign(6, 3, 25, 4);
  TovWin^.Insert(New(PLabel, Init(R, 'Список товаров', TovList)));

R.Assign(71, 3, 72, 16);
Control := New(PScrollBar, Init(R));
TovWin^.Insert(Control);


R.Assign(38, 3, 71, 16);
TovSelect := New(PBox, Init(R, 1, PScrollbar(Control)));
TovSelect^.NewList(New(PMyCollection, Init(1,1)));

{TovSelect^.FocusItem(1);}
TovSelect^.HelpCtx:=$E041;
TovWin^.Insert(TovSelect);

  R.Assign(39, 2, 65, 3);
  TovWin^.Insert(New(PLabel, Init(R, 'Выбранные наименования', TovSelect)));

s:=IntToStr(TovSelect^.List^.Count,6);
CountControl^.SetData(s);

TovWin^.SelectNext(False);

PrevCurrent:='';

CC := Desktop^.ExecView(TovWin);

If CC <> cmCancel Then
 Begin
       R.Assign(0, 0, 0, 0);
       TovTest := New(PBox, Init(R, 1, PScrollbar(Control)));
       TovTest^.NewList(New(PMyCollection, Init(1,1)));

       TestTovar;
       PrintTestFile;
       Dispose(TovTest, Done);
 End;


Dispose(Control,Done);
Dispose(CountControl,Done);
Dispose(sControlDop,Done);
Dispose(TovList,Done);
Dispose(TovWin,Done);

End;

procedure TSelectTovWindow.HandleEvent(var Event: TEvent);
Var s : String[1+CName+1+CArtikul+1+CName];
    ls : Word;
    count: word;
    fstr,s1 : TMyString;
    Res : Word;
    Logik : Boolean;
    label l1,3;

Begin
  Case Event.What Of
  evKeyDown :
  Case Event.KeyCode Of
   kbEnter  :Begin
                ClearFind;
                inherited HandleEvent(Event);
                If (TovWin^.Current=PView(TovList)) Then
                   Begin
                    Event.What:=evCommand;
                    Event.Command:=CmOk;
                   End;
             End;

   kbGrayPlus: Begin
                ClearFind;
          If ((TovList^.State and sfFocused <> 0)And(TovList^.List^.Count>= 1)) Then
            Begin
               fstr[0]:=#0;
               Res:=0;
               ProdagaWindow:=False;
               ClearFind;
               If MaskaSelect(fstr,Res) Then
                Begin
             DInfoMsg('Минуточку...',True);
             For ls :=0 To TovList^.List^.Count-1 Do
              Begin
               s:=TovList^.GetText(ls,TovList^.List^.Count);
               Logik:=False;
               s1:=Copy(s,1,CName);
               DelSpaceRight(s1);
               Case Res Of
               0:If (Pos(fstr,s1)>0)Or (Pos('*',Fstr)>0)  Then Logik:=True;
               1:If (fstr=s1) Then Logik:=True;
               Else ;
               End;{Case}

               If Logik Then
               If TestElement(Copy(s,1+CName+1,CRazdelKod),TovSelect) Then
                Begin
                 TovSelect^.List^.Insert(NewStr(s));
                 TovSelect^.SetRange(TovSelect^.List^.Count);
                End;{TestElement}
              End;{For}
              NoInfoMsg;
              ProdagaWindow:=False;
              If TovSelect^.Focused+1<TovSelect^.List^.Count Then
              TovSelect^.FocusItem(TovSelect^.List^.Count-1);
              TovSelect^.FocusItem(0);
                End;{Maska}
              Redraw;
              {AddName;}
            End;{Nil}
              ClearEvent(Event);
              End;
   kbGrayMinus,kbAltF2:Begin
                ClearFind;
          If ((TovSelect^.State and sfFocused <> 0)And(TovSelect^.List^.Count>= 1)) Then
            Begin
               fstr[0]:=#0;
               Res:=0;
               ProdagaWindow:=False;
               ClearFind;
               If MaskaSelect(fstr,Res) Then
                Begin
             DInfoMsg('Минуточку...',True);
             3:
             if (TovSelect^.List^.Count>= 1) Then
             For ls :=0 To TovSelect^.List^.Count-1 Do
              Begin
               s:=TovSelect^.GetText(ls,TovSelect^.List^.Count);
               Logik:=False;
               s1:=Copy(s,1,CName);
               DelSpaceRight(s1);
               Case Res Of
               0:If (Pos(fstr,s1)>0)Or (Pos('*',Fstr)>0)  Then Logik:=True;
               1:If (fstr=s1) Then Logik:=True;
               Else ;
               End;{Case}

               If Logik Then
               Begin
                TovSelect^.List^.AtFree(Ls);
                TovSelect^.SetRange(TovSelect^.List^.Count);
                goto 3;
               End;
              End;{For}

             If TovSelect^.Focused>0 Then
             TovSelect^.FocusItem(TovSelect^.Focused);

             If (TovSelect^.Focused>=TovSelect^.List^.Count) and(TovSelect^.Focused>0) Then
             TovSelect^.FocusItem(TovSelect^.Focused-1);


              NoInfoMsg;
              ProdagaWindow:=False;
              TovSelect^.FocusItem(0);
                End;{Maska}
             Redraw;
             {AddName;}
            End;{Nil}
              ClearEvent(Event);
              End;

   kbCtrlIns: Begin
              Count:=0;
          l1:      ClearFind;

            If(TovList^.State and sfFocused <> 0) And (TovList^.List^.Count-1>=1) Then
            Begin
               s:=TovList^.GetText(TovList^.Focused,TovList^.List^.COunt);
          if (Not TestName(Copy(S,1,CName)+copy(S,1+CName+1+CArtikul+1,CName),TovSelect,0)) or (count=0) then
            BEGIN
               If TestElement(Copy(s,1+CName+1,CARtikul),TovSelect) Then
               Begin
               TovSelect^.List^.Insert(NewStr(s));
               TovSelect^.SetRange(TovSelect^.List^.Count);
               s:=Copy(s,1+CName+1,CArtikul);
               TovSelect^.FocusItem(LoCation(TovSelect,S,false));
             If TovSelect^.Focused+1<TovSelect^.List^.Count Then
             TovSelect^.FocusItem(TovSelect^.List^.Count-1);
               End;
               If (TovList^.Focused+1) <  TovList^.List^.Count Then
               TovList^.FocusItem(TovList^.Focused+1);
               ClearEvent(Event);
               s:=IntToStr(TovSelect^.List^.Count,6);
               CountControl^.SetData(s);
               Redraw;
               INC(count);
               goto l1;
            END; {if TestName}
              End;

            End;

  kbCtrLDel: Begin
                ClearFind;
     If (TovSelect^.State and sfFocused <> 0) And (TovSelect^.List<>Nil)And(TovList^.List^.Count>=1) Then
            Begin
             TovSelect^.NewList(nil);
             TovSelect^.NewList(New(PMyCollection, Init(1,25)));
            End;
            ClearEvent(Event);
            s:=IntToStr(TovSelect^.List^.Count,6);
            CountControl^.SetData(s);
             Redraw;
            End;
     kbDel: Begin
                ClearFind;
     If (TovSelect^.State and sfFocused <> 0) And (TovSelect^.List<>Nil)And(TovList^.List^.Count>=1) Then
            Begin
             TovSelect^.List^.AtFree(TovSelect^.Focused);
             TovSelect^.SetRange(TovSelect^.List^.Count);

             If TovSelect^.Focused>0 Then
             TovSelect^.FocusItem(TovSelect^.Focused);

             If (TovSelect^.Focused>=TovSelect^.List^.Count) and(TovSelect^.Focused>0) Then
             TovSelect^.FocusItem(TovSelect^.Focused-1);
             ClearEvent(Event);
             s:=IntToStr(TovSelect^.List^.Count,6);
             CountControl^.SetData(s);
             Redraw;
            End;
            End;
      kbIns: Begin
                ClearFind;
            If(TovList^.State and sfFocused <> 0) And (TovList^.List^.Count-1>=1) Then
            Begin
               s:=TovList^.GetText(TovList^.Focused,TovList^.List^.COunt);
               If TestElement(Copy(s,1+CName+1,CARtikul),TovSelect) Then
               Begin
                TovSelect^.List^.Insert(NewStr(s));
                TovSelect^.SetRange(TovSelect^.List^.Count);
                s:=Copy(s,1+CName+1,CArtikul);
                TovSelect^.FocusItem(LoCation(TovSelect,S,false));
                If TovSelect^.Focused+1<TovSelect^.List^.Count Then
                     TovSelect^.FocusItem(TovSelect^.List^.Count-1);
               End;
               If (TovList^.Focused+1) <  TovList^.List^.Count Then
               TovList^.FocusItem(TovList^.Focused+1);
              End;
              ClearEvent(Event);
               s:=IntToStr(TovSelect^.List^.Count,6);
               CountControl^.SetData(s);
               Redraw;
            End;
    Else;
    End;
    Else;
    End;
  DrawCurrent;
  inherited HandleEvent(Event);
    If (Desktop^.Current=PView(TovWin)) And (Event.What <> EvKeyDown) Then
             Begin

               if (RazdelControl^.State and sfFocused <> 0)Then
                    Begin
                        RazdelControl^.GetData(RazdelCount);
                        If RazdelCount <> RazdelStatus Then
                        Begin
                           ClearFind;
                           RazdelStatus:=RazdelCount;
                           Refresh;
                           Redraw;
                        End;
                    End;
              end;

End;

procedure TSelectTovWindow.Refresh;
var fr: file of RazdelType;
    rr: RazdelType;
    fid: file;
    sRazd: string[CRazdelKOd];
    id: PBufBazType;
    IORez: word;
    count:word;

procedure ReadRazdel;
begin
      sRazd:=rr.Kod;
      Assign(fid,PathSklads^.Dat.Path[4]+'id\'+sRazd+'.id');
      iorez:=ioresult;
      Reset(fid,SizeOf(BazType));
      iorez:=ioresult;
      if iorez<>0 then
      begin
        Writeln(PathSklads^.Dat.Path[4]+'id\'+sRazd+'.id');
        exit;
      end;
      New(id,Init);
      while not eof(fid) do
      begin
        {Format (id.Name,CClient);}
        ReadBufBaz(fid,id,count);
        For c:=1 To Count Do
        Begin
           if id^.Point.Dat[c].Employ then
           begin
             format(id^.Point.Dat[c].Name,CName);
             format(id^.Point.Dat[c].name2,CName);
             TovList^.List^.Insert(NewStr(id^.Point.Dat[c].Name+'│'+id^.Point.Dat[c].BazKod+'│'+id^.Point.Dat[c].Name2+
               '│    0'));
             TovList^.SetRange(TovList^.List^.Count);
           end;
        end;
      end;
      Dispose(id,Done);
      System.Close(fid);
end;


Begin
Assign (fr,PathSklads^.Dat.Path[4]+'main\razdel.db');
IORez:=ioresult;
Reset (fr);
IORez:=ioresult;
 if iorez<>0 then
   begin
    MessageBox(#3'Не могу открыть файл'+PathSklads^.Dat.Path[4]+'main\razdel.db'
    ,nil,mfError+mfCancelButton);
    exit;
   end;

TovList^.NewList(nil);
TovList^.NewList(New(PTextCollection, Init(1,25)));
{AinfoMsg('Формирую список товаров');}
{memc;}
While Not(Eof(fr)) Do
 Begin
  Read(fr,rr);
  DInfoMsgShkala('Формирую список товаров ...',0,FileSize(fr),FilePos(fr));
  If (rr.Employ) and (rr.EnableDoc=0) and (rr.EnableLitr=1) then
   Case RazdelStatus of
   0: Begin

       if StrToInt(rr.kod) <= 16 then ReadRazdel;
      end;
   1: Begin
       if (StrToInt(rr.kod) in [17..58]) then ReadRazdel;
      end;
   2: Begin
       if (StrToInt(rr.kod) in [59..99]) then ReadRazdel;
      end;
   End;
 End;
IORez:=ioresult;
System.Close(fr);
IORez:=ioresult;
NoInfoMsg;
End;

procedure TSelectTovWindow.DrawCurrent;
Var St : TEnjoyStr;
     R : TRect;
Begin
If (TovList^.List<>Nil)And(TovList^.List^.Count>0)  Then
 Begin
  st:=TovList^.GetText(TovList^.Focused,TovList^.List^.Count);
  st:=copy(st,1,CName)+copy(st,1+CName+1+CArtikul+1,CName);
  If St <> PrevCurrent Then
   Begin
    PrevCurrent:=St;
    Dispose(sControlDop,Done);
    R.Assign(3, 17, 55, 18);
    sControlDop := New(PColoredText, Init(R, #3+st, $7E));
    Insert(sControlDop);
   Redraw;
   End;

 End

 Else
  Begin
If PrevCurrent[0]<>#0 Then
Begin
PrevCurrent[0]:=#0;
Dispose(sControlDop,Done);
R.Assign(3, 17, 55, 18);
sControlDop := New(PColoredText, Init(R, #3+'???', $7E));
Insert(sControlDop);
Redraw;
End;
  End;

End;

Destructor TSelectTovWindow.Done;
Begin
TDialog.Done;
End;



BEGIN
END.