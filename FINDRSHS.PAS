{$I Compile.INC}

{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}
Unit FindRshs;


Interface

Uses ServStr;



Procedure FindRashS(SArt:ArtikulStr);

implementation


Uses Glob,Objects,
     Drivers,Dialogs,Serv,TpDate,MsgBox,Utils3,
	DbEngine,NetDbEng,Printers,Tools;

Procedure FindRashS(SArt:ArtikulStr);
var
  CurDate : TDateString;
  Start,Stop,Cur : LongInt;
  CountPos,c,sh,Count : Word;
  R : TRect;
  SPos,SClient,Space:AllStr;
  StartDate,StopDAte : TDateString;
  E : PBufSuperMarketType;
  f : File;
  Find : Boolean;
  txt : Text;
  NoScreenList1 : PBox;
  s : String;

begin
  ClearFind;

  StartDAte:=FDAte;
  StopDAte:=FDAte;

  If Not(DatePeriodDialog(StartDate,StopDate,False)) Then Exit;

  Start:=DateStringToDate(DateMask,StartDAte);
  Stop:=DateStringToDate(DateMask,StopDAte);

 Assign(txt,Path^.Dat.ToTemp+'findrass.txt');
 c:=IOResult;
 Rewrite(txt);
 c:=IOResult;
 If c<>0 Then
  Begin
   MessageBox(#3'è¨¡ª  á®§¤ ­¨ï '+Path^.Dat.ToTemp+'findrass.txt',Nil,mfError+mfCancelButton);
   Exit;
  End;


 Space[0]:=#0;
 Writeln(txt,Header+Space+'‘ª« ¤: ',GetClientField(FClient,Rek^.Dat.Kod,1)+
 '  ¯¥à â®à: '+CurrentPassword+' EYE & 1997-01');
 Writeln(txt);
 Writeln(txt,Space+'’—…’  ’ƒ“‡Š€Œ Š‹ˆ…’€Œ ‘…’ˆ”ˆŠ€’‚ ‘’‚…’‘’‚ˆŸ §  ¯¥à¨®¤ á '+
 StartDAte+' ¯® '+StopDAte);

 Space:='      ';

 WriteLn(txt,Space+'ˆáª®¬ë© á¥àâ¨ä¨ª â:'+GetIdField(FFFNAme,SArt)+' ('+SArt+')');

                   {123³123456789012345678901234567890123456789012345³1234³1234³12345678³1234567890³12345678³123456789012345}
 Writeln(txt,Space+'ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿');
 Writeln(txt,Space+'³¯¯ Š«¨¥­â                                        Š®¤  N­ª« „ â  ®â£³');
 Writeln(txt,Space+'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ'+HeaderStop);


R.Assign(0,0,0,0);
NoScreenList1 := New(PBox, Init(R, 1, Nil));
NoScreenList1^.NewList(New(PTextCollection, Init(0,1)));

 CountPos:=0;
   For Cur:=Start To Stop Do
   Begin
    CurDate:=DateToDateString(DateMask,Cur);
    DInfoMsgShkala('à®á¬ âà¨¢ î ¯à®¤ ¦¨ §  '+CurDAte+' ...',Start,Stop,Cur);
    Assign(f,Path^.DAt.ToMarket+CurDate+'.mrk');
    c:=IOResult;
    reset(f,SizeOf(SuperMarketType));
    c:=IOResult;
    If c<>0 Then Continue;

    While Not(Eof(f)) Do
     Begin
      New(E,Init);
      Count:=0;
      ReadBufMarket(f,E,Count);
     For c:=1 To Count Do
    Begin
      If E^.Point.DAt[c].Active Then
      If E^.Point.DAt[c].OperatorSelector in [0,2] Then
      If (Not(E^.Point.Dat[c].Realiz)) Or
         ((E^.Point.Dat[c].Realiz) And (E^.Point.Dat[c].DocSelector in [5,6,7,8])) Then
      For sh:=1 To E^.Point.DAt[c].Amount Do
       Begin
        If E^.Point.Dat[c].MarketElement[sh].Input.NSertif=SArt Then
         Begin
          Inc(CountPos);
          sPos:=IntToSTr(CountPos,3);
          RFormat(SPos,3);
          sClient:=GetClientField(FFullClient,E^.Point.DAt[c].ClientKod,E^.Point.DAt[c].OperatorSelector);
          Format(SClient,CAll);
          DelSpace(E^.Point.DAt[c].Document);
          RFormat(E^.Point.DAt[c].Document,CDocNumer);
          {
          Writeln(txt,Space+SPos+' '+SClient+' '+E^.Point.DAt[c].ClientKod+' '+
		E^.Point.DAt[c].Document+' '+E^.Point.DAt[c].DateC);
          }
          NoScreenList1^.List^.Insert(NewStr(SClient+' '+E^.Point.DAt[c].ClientKod+' '+
		E^.Point.DAt[c].Document+' '+E^.Point.DAt[c].DateC));
          NoScreenList1^.SetRange(NoScreenList1^.List^.Count);
          Break;

         End;
       End;{for ¯® ­ ª« ¤­®©}
    End;{For ¯® ¡ãä¥àã}
      Dispose(E,Done);
     End;{While}
    c:=IOResult;
    System.Close(f);
    c:=IOResult;
   End;{For §  ¯¥à¨®¤}


If NoScreenList1^.List^.Count-1>=0 Then
 Begin
   For c:=0 To NoScreenList1^.List^.Count-1 Do
    Begin
     s:=NoScreenList1^.GetText(c,NoScreenList1^.List^.Count);
     sClient:=IntToSTr(c+1,3);
     RFormat(SClient,3);
     Writeln(txt,Space+SClient+' '+s);

    End;
 End;

 Dispose(NoScreenList1,Done);

 Writeln(txt,Space+'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ');
 Writeln(txt,Space+' ‚á¥£® ®â£àã§®ª: ',CountPos:4);
 Writeln(txt);
 Writeln(txt,Space,'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
 Writeln(txt,Space+'====================================================================');

NoInfoMsg;

 c:=IOResult;
 System.Close(txt);
 c:=IOResult;

ViewAsText(Path^.Dat.ToTemp+'findRass.txt',
'‘¯à ¢ª  ¯® ®â£àã§ª ¬ á¥àâ¨ä¨ª â  §  ¯¥à¨®¤ á '+StartDAte+' ¯® '+StopDAte,True);
{ReportNew(Path^.Dat.ToTemp+'findRass.txt','',1,False,False);}


end;






Begin

End.