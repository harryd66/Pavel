{$IfNDEF DPMI}
{$F+}
{$O+}
{$EndIf}


{$I Compile.INC}
Unit TstZak;

INTERFACE

Uses Glob, ServStr;

procedure TestZakDolg;

IMPLEMENTATION

Uses MsgBox, NetDBEng, TPDate, Serv, Dialogs, Objects, Tools, Printers,
     DBEngine, Utils4, Access1;

procedure TestZakDolg;

const Space = ' ';
      CRepZena = CIZena-5;

Var   Zf : File;
      E : PBufHeaderZakazType;
      cc,Count,i,j : word;
      IORez: word;
      DateTrans:TDAteString;
      Start: Longint;
      Cl,Cl1 : String[CCLientKod];
      tDolg   : Double;
      sDolg,sk: string[CIZena];
      tLimit : Double;
      P, ViewBox: PBox;
      Rect: TRect;
      s,ws: string;
      t,gid: text;
      sName: String[CClient];
      sSumma: string[CIZena];
      VidReport: word;
      Star : AllStr;
      StartPos: longint;
Begin

 DateTrans:=FDate;
 if not NewDateDialog(DateTrans) then exit;

 VidReport:=1;
 VidReport:=SelectImport(19);
 If VidReport=2 Then exit;

 Assign(t,Path^.Dat.ToTemp+'zakdlg.txt');
 IORez:=ioresult;
 Rewrite(t);
 IORez:=ioresult;
 If IORez<>0 Then
 Begin
  MessageBox(^M+#3+'Ошибка создания файла '+Path^.Dat.ToTemp+'zakdlg.txt Код:'+
    IntToStr(IORez,CKod),Nil,mfError+
  mfCancelButton);
  Exit;
 End;

 Assign(gid,Path^.Dat.ToMarket+'Zakaz.gid');
 i:=IOResult;
 Reset(gid);
 i:=IOResult;
 If i<>0 Then
 BEgin
  Star:='0';
  MessageBox(^M+#3+'Ошибка открытия файла-маршрутизатора '+Path^.Dat.ToMarket+'Zakaz.gid',Nil,mfError+
  mfCancelButton);
 End
 Else
  Begin
   Readln(gid,Star);
   i:=IOResult;
   System.Close(gid);
   i:=IOResult;
  End;

 StartPos:=StrToInt(Star);

 Assign(ZF,Path^.Dat.ToMarketIndex+'Zakaz.idx');
 IORez:=IOResult;
 Reset(ZF,SizeOf(HeaderZakazType));
 IORez:=IOResult;
 If IORez<>0 Then
 Begin
  Close(t);
  MessageBox(^M+#3+'Ошибка открытия файла '+Path^.Dat.ToMarketIndex+'Zakaz.idx Код:'
    +IntToStr(IORez,CKod),Nil,mfError+
  mfCancelButton);
  Exit;
 End;

 Rect.Assign(0,0,0,0);
 P := New(PBox, Init(Rect, 1, Nil));
 P^.NewList(New(PTextCollection, Init(1,1)));

 Start:=FileSize(ZF);

 If (StartPos-100)>=0 Then
 Begin
  Seek(ZF,StartPos-100);
  StartPos:=StartPos-100;
 End
 Else
 Begin
  Seek(ZF,StartPos);
 End;


 While Not(Eof(ZF)) Do
 Begin
  DInfoMsgShkala('Просматриваю заказы...',StartPos,Start,FilePos(ZF));
  New(E,Init);
  Count:=0;
  ReadBufHeaderZakaz(Zf,E,Count);

  For cc:=1 To Count Do
   Begin
     If (E^.Point.Dat[cc].Oformlenie=1) then
     If (E^.Point.Dat[cc].DateC+E^.Point.Dat[cc].EndDate)=DateStringToDate(DateMask,DateTrans) Then
     if (E^.Point.Dat[cc].OperatorSelector=0) and (E^.Point.Dat[cc].DocSelector in [5,6,7,8]) then
     Begin

      Cl:=IntToStr(E^.Point.Dat[cc].ClientKod,CCLientKod);

      rFormatZerro(Cl,CCLientKod);

      s:='';
       {пишем в лист все заказы с даной датой доставки}
      {if (E^.Point.Dat[cc].SummaZ+tDolg>tLimit) then}
      begin
        {код клиента}
        S:=S+CL+SeparatorChar;
        {дата заказа}
        s:=s+DateToDateString(DateMask,E^.Point.Dat[cc].DateC)+SeparatorChar;
        {номер заказа}
        ws:=IntToStr(E^.Point.Dat[cc].Document,CArtikul);
        rFormat(ws,CArtikul);
        s:=s+ws+SeparatorChar;
        {сумма заказа}
        MyStr(E^.Point.Dat[cc].SummaZ,CIZena,CMantissa,ws);
        rFormat(ws,CRepZena);
        s:=s+ws+SeparatorChar;

        P^.List^.Insert(NewStr(s));
        P^.SetRange(P^.List^.Count);
      end;
     end;
   End; {For cc:=1 To Count Do}

   Dispose(E,Done);
 End; {While Not(Eof(ZF))}

 NoInfoMsg;

 IORez:=IOResult;
 System.Close(ZF);
 IORez:=IOResult;

 Rect.Assign(0,0,0,0);
 ViewBox := New(PBox, Init(Rect, 1, Nil));
 ViewBox^.NewList(New(PTextCollection, Init(1,1)));

 if P^.List^.Count>0 then
 for i:=0 to P^.List^.Count-1 do
 Begin
   s:=P^.GetText(i,P^.List^.Count);
   cl:=copy(s,1,CCLientKod);
   tDolg:=StrToReal(Copy(s,1+CCLientKod+1+CDate+1+CArtikul+1,CRepZena));
   {Для краткого отчета суммируем по клиентам}

   if VidReport=1 then
   if ViewBox^.List^.Count>0 then
   for j:=0 to ViewBox^.List^.Count-1 do
   begin
    ws:=ViewBox^.GetText(j,ViewBox^.List^.Count);
    cl1:=copy(ws,1,CCLientKod);
    if StrToInt(Cl)=StrToInt(Cl1) then
    begin
      tLimit:=StrToReal(Copy(ws,1+CCLientKod+1+CDate+1+CArtikul+1,CRepZena));
      MyStr(tDolg+tLimit,CIZena,CMantissa,sSumma);
      rFormat(sSumma,CRepZena);
      System.Delete(s,1+CCLientKod+1+CDate+1+CArtikul+1,CRepZena);
      System.Insert(sSumma,s,1+CCLientKod+1+CDate+1+CArtikul+1);
      System.Delete(s,1+CCLientKod+1+CDate+1,CArtikul);
      System.Insert(' --- ',s,1+CCLientKod+1+CDate+1);
      ViewBox^.List^.AtFree(j);
      ViewBox^.SetRange(ViewBox^.List^.Count);
      Break;
    end;
   end;

   ViewBox^.List^.Insert(NewStr(s));
   ViewBox^.SetRange(ViewBox^.List^.Count);

 End;


 P^.NewList(Nil);
 P^.NewList(New(PTextCollection, Init(0,1)));

 {Формируем список с превышением лимита}
 if ViewBox^.List^.Count>0 then
 for i:=0 to ViewBox^.List^.Count-1 do
 begin
   DInfoMsgShkala('Формирование отчета  ...',0,ViewBox^.List^.Count-1,i);
   s:=ViewBox^.GetText(i,ViewBox^.List^.Count);
   cl:=copy(s,1,CClientKod);

      {Текущий долг}
      sDolg:='0.0';
      sk:='0.0';
      CalcDolgNew(Cl,sDolg,sk);
      tDolg:=StrToReal(sDolg)-StrToReal(sk);

      {Лимит долга}
      sName:='';
      tLimit:=0.0;
      tLimit:=StrToReal(GetClientField(FLimit,Cl,0));

   sSumma:=Copy(s,1+CCLientKod+1+CDate+1+CArtikul+1,CRepZena);
   if StrToReal(sSumma)+tDolg>Abs(tLimit) then
   begin

      {тек долг}
      MyStr(tDolg,CIZena,CMantissa,ws);
      rFormat(ws,CRepZena);
      s:=s+ws+SeparatorChar;
      {лимит долга}
      MyStr(tLimit,CIZena,CMantissa,ws);
      rFormat(ws,CRepZena);
      s:=s+ws;

      sName:=GetClientField(FClient,Cl,0);
      format(sName,CClient);

      System.Insert(sName+SeparatorChar,s,1+CArtikul);

    P^.List^.Insert(NewStr(s));
    P^.SetRange(P^.List^.Count);
   end;
 end;

 NoInfoMsg;

 Dispose(ViewBox,Done);

 Writeln(t,Header+Space+ 'Склад: ',GetClientField(FClient,Rek^.Dat.Kod,1)+'  Оператор: '+CurrentPassword);
 Write(t,Space,'Вид отчета: ');
 if VidReport=0 then Writeln(t,'полный')
   else Writeln(t,'краткий');
 Writeln(t,Space,'Срок доставки: ',DateTrans);
 Writeln(t,'              КОНТРОЛЬ ПРЕВЫШЕНИЯ ЛИМИТА ДОЛГА ЗАКАЗОВ ');
 Writeln(t,Space,'┌───┬────────────────────┬────────┬─────┬──────────┬──────────┬──────────┐');
 Writeln(t,Space,'│Код│Наименование клиента│ Дата   │N зак│Сумма зак.│Тек. долг │Лимит долг│');
 Writeln(t,Space,'└───┴────────────────────┴────────┴─────┴──────────┴──────────┴──────────┘'+HeaderStop);

 if P^.List^.Count>0 then
 for i:=0 to P^.List^.Count-1 do
 Begin
   s:=P^.GetText(i,P^.List^.Count);
   writeln(t,Space,s);
 End;

 Dispose(P,Done);

 Writeln(t,Space+'─────────────────────────────────────────────────────────────────────────');
 Writeln(t);
 Writeln(t,Space,'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
 Writeln(t,Space+'===========================');


 IORez:=ioresult;
 System.Close(t);
 IORez:=ioresult;

 ViewAsText(Path^.Dat.ToTemp+'zakdlg.txt','Контроль лимита долга (доставка '+DateTrans+')',True);
End;

BEGIN

END.