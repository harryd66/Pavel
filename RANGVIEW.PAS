{$I Compile.INC}

{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}

Unit RangView;

INTERFACE


Procedure TestRange;


IMPLEMENTATION

Uses Utils3,TPDate,NetDbEng,Utils4,Objects,Utils,
     Serv,DBEngine,Printers,Tools,MsgBox,ServStr2,
     Glob,ServStr,Views,Dialogs;




function TestMrkRange(E:SuperMarketType;Regim: Word):string;
var ws,ws1,s: string;
    i,c: word;
    sKOd: ArtikulStr;
    sZena, sZenaOpl: string[CZena];
    SA,SAgent,SClient : AllStr;

Begin
  TestMrkRange:='';
  ws[0]:=#0;
  if (ListRange^.List<>nil) and (ListRange^.List^.Count>0) then
 Begin
  for c:=1 to e.Amount do
  begin
      SA:=CalcMainKod(e.MarketElement[c].BazKod);
      RFormatZerro(SA,CArtikul);
      for i:=0 to ListRange^.List^.Count-1 do
      begin
       s:=ListRange^.GetText(i,ListRange^.List^.Count-1);
       sKod:=copy(s,1+1,CArtikul);


       if StrToInt(sKOd)=StrToInt(SA) then
         begin
           Case Regim Of
           0:sZena:=copy(s,1+1+CArtikul+1+COne+1,CZena);
           1:sZena:=copy(s,1+1+CArtikul+1+COne+1+CZena+1,CZena);
           2:sZena:=copy(s,1+1+CArtikul+1+COne+1+CZena+1+CZena+1,CZena);
           Else SZena:='';
           End;

           sZenaOpl:=e.MarketElement[c].Input.Zena;

           RFormatZerro(E.ClientKod,CClientKod);

           If E.SkidkaSelector=0 Then{…á«¨  ¢â®¬ â}
           MyStr((StrToReal(e.MarketElement[c].Input.Zena)/
           (1+StrToReal(e.MarketElement[c].Input.Proz)/100))
           ,CZena,CMantissa,sZenaOpl){­®¢ ï æ¥­ }
           Else
           MyStr((StrToReal(e.MarketElement[c].Input.Zena)-
                 StrToReal(e.MarketElement[c].Input.Skidka)),
                    CZena,CMantissa,sZenaOpl);{­®¢ ï æ¥­ }


           if ((StrToReal(sZenaOpl)-StrToReal(sZena)))<-0.005 then
           begin
             {­ ¨¬¥­®¢ ­¨¥}
             ws1:=GetIDField(FName,sKod);
             format(ws1,CName);
             ws:=ws1+SeparatorChar;
             {ª®¤}
             ws:=ws+sKOd+SeparatorChar;
             {ª«¨¥­â}
             SClient:=GetClientField(FClient,E.ClientKod,E.OperatorSelector);
             Format(SClient,CClient);
             ws:=ws+SClient+SeparatorChar;
             {ª®¤ ª«¨¥­â }
             ws:=ws+IntToStr(E.OperatorSelector,COne)+E.ClientKod+SeparatorChar;
             SAgent:=GetAgentField(FAgent,E.AgentKod);
             Format(SAgent,CClient);
             ws:=ws+SAgent+SeparatorChar;
             {ª®¤  £¥­â }
             ws:=ws+E.AgentKod+SeparatorChar;
             {­®¬¥à ¤®ª-â }
             ws1:=e.Document;
             rformat(ws1,CDocNumer);
             ws:=ws+ws1+SeparatorChar;
             {¤ â  ¤®ª-â }
             ws1:=e.DateC;
             format(ws1,CDate);
             ws:=ws+ws1+SeparatorChar;
             {®¯®à­ ï æ¥­ }
             ws1:=sZena;
             rformat(ws1,CZena);
             ws:=ws+ws1+SeparatorChar;
             {ä ªâ¨ç æ¥­ }

             rformat(sZenaOpl,CZena);
             ws:=ws+sZenaOpl+SeparatorChar;
             {®¯à â®à}
             ws1:=GetOperatorField(FName,e.Caption);
             format(ws1,CKto);
             ws:=ws+ws1+SeparatorChar;
             break;
           end;{if (StrToReal(sZena)-StrToReal(sZenaOpl))>0.009 then}
         end;{SKod=..}
      end;{ For ListRange}
  end;{For Amount}
 End;
  TestMrkRange:=ws;
End;


Procedure TestRange;
const space = ' ';

var TempBox: PBox;
    R: TRect;
    StartDate,StopDate: TDateString;
    Start,Stop,Cur: longint;
    F : File;
    Es : PBufSuperMarketType;
    Regim,l: word;
    s: string;
    t: text;
    OldFileMode : Word;
    j,Count : Word;
Begin
  if Not DatePeriodDialog(StartDate,StopDate,false) then Exit;
{
    l:=SelectImport(30);
    Regim:=l;
    If l=4 Then Exit;

    If l=3 Then Exit;
}
    start:=DateStringToDate(DateMask,StartDate);
    stop:=DateStringToDate(DateMask,StopDate);

       Assign(t,Path^.Dat.ToTemp+'testrang.txt');
       l:=IOResult;
       Rewrite(t);
       l:=Ioresult;
       If L <> 0 Then
       Begin
        MessageBox(^M+#3'è¨¡ª  á®§¤ ­¨ï ä ©«  '+Path^.Dat.ToTemp+'testrang.txt'+' !',Nil,mfError+mfCancelButton);
        exit;
       End;
       l:=Ioresult;
       System.Close(t);
       l:=Ioresult;


    R.Assign(0,0,0,0);
    TempBox := New(PBox, Init(R, 1, Nil));
    TempBox^.NewList(New(PTextCollection, Init(0,1)));

  for cur:=Start to Stop do
    begin
       DInfoMsgShkala('ˆ¤¥â ª®­âà®«ì æ¥­®¢ëå ®£à ­¨ç¥­¨© §  '+DateToDateString(DateMask,cur)+'...',start,stop,cur);
       Assign(F,Path^.Dat.ToMarket+DAteToDAteString(DateMask,Cur)+'.mrk');
       l:=IOResult;
       OldFileMode:=FileMode;
       FileMode:=$42;
       Reset(f,SizeOf(SuperMarketType));
       FileMode:=OldFileMode;
       l:=Ioresult;
       If L <> 0 Then Continue;

       While Not(Eof(f)) Do
       Begin
         New(Es,Init);
         Count:=0;
         ReadBufMarket(f,Es,Count);
         For j:=1 To Count Do
         Begin
          If (Es^.Point.Dat[j].Active) Then
          if (Es^.Point.Dat[j].OperatorSelector in [0,2]) then
          if ((Es^.Point.Dat[j].Realiz)and(Es^.Point.Dat[j].DocSelector in [5,6,7,8]))
            or ((Not Es^.Point.Dat[j].Realiz)and(Es^.Point.Dat[j].DocSelector in [1,2,3,4]))then
            Begin
              Regim:=StrToInt(GetClientField(FDisableControlZeni,Es^.Point.Dat[j].ClientKod,
		    Es^.Point.Dat[j].OperatorSelector));
              If Regim<3 Then
              Begin
              s:=TestMrkRange(Es^.Point.Dat[j],Regim);
              if s[0]<>#0 then
               begin
                TempBox^.List^.Insert(NewStr(s));
                TempBox^.SetRange(TempBox^.List^.Count);
               end;
              End;{Regim<3}
            End;
         End;{For}
         Dispose(Es,Done);
       end;
       l:=Ioresult;
       System.Close(f);
       l:=Ioresult;
    end; {for cur:=Start to Stop}

    NoInfoMsg;


 if TempBox^.List^.Count>0 then
 Begin
 l:=IOResult;
 Append(t);
 l:=Ioresult;
 Writeln(t,header+Space+'‘ª« ¤: ',GetClientField(FClient,Rek^.Dat.Kod,1)+'  ¯¥à â®à: '+CurrentPassword+' EYE & 2002');
{
 Write(t,Space+'‚¨¤ ª®­âà®«ï ®£à ­¨ç¥­¨©:');
 Case Regim Of
 0 : Writeln(t,'"Œï£ª¨©"');
 2 : Writeln(t,'"†¥áâª¨©"');
 1 : Writeln(t,'"‘à¥¤­¨©"');
 Else Writeln(t);
 End;
 }
 writeln(t);
 writeln(t,Space+'  Š’‹œ –…‚›• ƒ€ˆ—…ˆ‰ ‡€ …ˆ„ á '+DateToDateString(DateMask,Start)
    +' ¯® '+DateToDateString(DateMask,Stop));
 writeln(t,
 GlobalPrn^.Dat.Condensed[Nprint^.DAt.Printer]+
 GlobalPrn^.Dat.MinInterval2[Nprint^.DAt.Printer]);
 Writeln(t,Space+'ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄ'+
 'ÂÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿');
 Writeln(t,Space+'³  ¨¬¥­®¢ ­¨¥ â®¢ à       ³ Š®¤ ³ Š«¨¥­â             ³ Š®¤ ³ €£¥­â              ³ Š®¤'+
 '³N¤®ª³„ â  ¤®ª³Š®­âà®«ì³–¥­  ®¯«³ ¯¥à â®à   ³');
 Writeln(t,Space+'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄ'+
 'ÁÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÙ'+
 GlobalPrn^.Dat.Normal[Nprint^.DAt.Printer]+HeaderStop);

    if TempBox^.List^.Count>0 then
    for l:=0 to TempBox^.List^.Count-1 do
    begin
     s:=TempBox^.GetText(l,TempBox^.List^.Count);
     writeln(t,Space+' '+s);
    end;

    Writeln(t,Space+'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'+
    GlobalPrn^.Dat.NoCondensed[Nprint^.DAt.Printer]);
    Writeln(t,Space,'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');

    Writeln(t,'===========================================================');
    System.Close(t);
    l:=IOResult;
    ViewAsText(Path^.Dat.ToTemp+'testrang.txt','âç¥â ¯® ª®­âà®«î æ¥­®¢ëå ®£à ­¨ç¥­¨© §  ¯¥à¨®¤ c '+
    DateToDateString(DateMask,Start)+
' ¯® '+DateToDateString(DateMask,Stop),True);
    {Reportnew(Path^.Dat.ToTemp+'testrang.txt','',1,False,False);}
 End
 Else
  Begin
   MessageBox(^M#3+'¯¥à æ¨ï ãá¯¥è­® § ¢¥àè¥­ ! '+
   'è¨¡®ª ­¥ ®¡­ àã¦¥­®!',Nil,mfInformation+mfCancelButton);
  End;

 Dispose(TempBox,Done);

End;



End.