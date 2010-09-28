{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}

Unit Feliks;

{$I Compile.INC}


INTERFACE

procedure CalcFeliks;

IMPLEMENTATION

Uses Dialogs, Drivers, Utils, Prise, TPDate, Glob, ServStr, Objects,
     MSGBox, DBEngine, Utils5, Utils3, Utils4, Serv, Printers, Tools,
     ServStr2,
     NetDbEng;

PROCEDURE CalcFeliks;

const Space = ' ';

var P: PBufPrihodType;
    fP: file;
    IORez,i,j: word;
    R:TRect;
    TempBox, SortBox, ErrBox: PBox;
    sDate,sStart,sStop: TDateString;
    Date,Start,Stop: longint;
    t: text;
    find: boolean;
    Zena: string[CZena];
    Summa: string[CIZena];
    KOl: string[cKol];
    SumKol: string[Ckol+1];
    sArt: string[CArtikul];
    sPost: string[CMakeKod];
    sNumer: String[CName];
    sDatePost: TDateString;
    s: string;
    sKey,sKey1: string;
    sName: string[CName+1+CName];
    sPostName:string[CClient];
    Count,jk: word;
BEGIN

  If Not DatePeriodDialog(sStart,sStop,False) Then Exit;

  Start:=DateStringToDate(DateMask,sStart);
  Stop:=DateStringToDate(DateMask,sStop);

  R.Assign(0,0,0,0);
  TempBox := New(PBox, Init(R, 1, Nil));
  TempBox^.NewList(New(PTextCollection, Init(0,1)));

  R.Assign(0,0,0,0);
  ErrBox := New(PBox, Init(R, 1, Nil));
  ErrBox^.NewList(New(PTextCollection, Init(0,1)));


  for Date:=Start to Stop do
  BEGIN
    DInfoMSGShkala('Просматриваю приходы за '+DateToDateString(DateMask,Date)+' . . . ',Start,Stop,Date);
    sDate:=DateToDateString(DateMask,Date);
    iorez:=ioresult;
    Assign(fp,Path^.Dat.ToPrihod+sDate+'.prh');
    iorez:=ioresult;
    Reset(fp,SizeOf(PrihodType));
    iorez:=ioresult;
    if iorez<>0 then begin
     ErrBox^.List^.Insert(NewStr('Отсутствуют приходы за '+sDate+' ['+DayString[DayOfWeek(Date)]+']'));
     ErrBox^.SetRange(ErrBox^.List^.Count);
     continue;
    end;

  while not eof(fp) do
  Begin
    New(P,Init);
    Count:=0;
    ReadBufPrihod(fp,p,Count);

For jk:=1 To Count Do
Begin

    if P^.Point.DAt[jk].OperatorSelector=0 then
    if P^.Point.DAt[jk].Amount>0 then
    for i:=1 to P^.Point.DAt[jk].Amount do
    begin
      find:=false;
      sArt:=P^.Point.DAt[jk].PrihodElement[i].BazKod;
      format(sArt,CArtikul);
     if StrToInt(sArt)<80000 then
     begin
      sKey:=sArt+SeparatorChar;

      sPost:=P^.Point.DAt[jk].MakeKod;
      format(sPost,CMakeKod);
      sKey:=sKey+sPost+SeparatorChar;

      sNumer:='_'+P^.Point.DAt[jk].rekwizit.Numer;
      rformat(sNumer,CName);
      sKey:=sKey+sNumer+SeparatorChar;

      sDatePost:=P^.Point.DAt[jk].rekwizit.Date;
      format(sdatePost,CDate);
      sKey:=sKey+sDatePost+SeparatorChar;

      if (TempBox<>Nil) and (TempBox^.List^.count>0) then
      for j:=0 to TempBox^.List^.count do
      begin
        s:=TempBox^.GetText(j,TempBox^.List^.count);
        sKey1:=copy(s,1,1+CArtikul+1+CMakeKod+1+CName+1+CDate);
        if sKey=sKey1 then
        begin
         SumKol:=copy(s,1+CArtikul+1+CMakeKod+1+CName+1+CDate+1,CKol+1);
         Summa:=copy(s,1+CArtikul+1+CMakeKod+1+CName+1+CDate+1+(CKol+1)+1,CIZena);
         SumKol:=IntToStr(StrToInt(SumKol)+StrToInt(P^.Point.DAt[jk].PrihodElement[i].Input.kol),CKol+1);
         rformat(SumKol,CKol+1);
         MyStr(StrToReal(Summa)+StrToReal(P^.Point.DAt[jk].PrihodElement[i].Input.Zakupka)
           *StrToReal(P^.Point.DAt[jk].PrihodElement[i].Input.Kol),
             CIZena,CMantissaZ,Summa);
         rformat(Summa,CIZena);

         System.Delete(s,1+CArtikul+1+CMakeKod+1+CName+1+CDate+1,CKol+1);
         System.Insert(SumKol,s,1+CArtikul+1+CMakeKod+1+CName+1+CDate+1);

         System.Delete(s,1+CArtikul+1+CMakeKod+1+CName+1+CDate+1+(CKol+1)+1,CIZena);
         System.Insert(Summa,s,1+CArtikul+1+CMakeKod+1+CName+1+CDate+1+(CKol+1)+1);

         TempBox^.List^.AtFree(j);
         TempBox^.SetRange(TempBox^.List^.Count);

         TempBox^.List^.AtInsert(j,NewStr(s));
         TempBox^.SetRange(TempBox^.List^.Count);
        end;

      end;

      if not find then
      begin
        s:=sKey;
        SumKol:=P^.Point.DAt[jk].PrihodElement[i].Input.kol;
        rformat(SumKol,CKol+1);
        s:=s+SumKol+SeparatorChar;

        MyStr(StrToReal(P^.Point.DAt[jk].PrihodElement[i].Input.Zakupka)
          *StrToReal(P^.Point.DAt[jk].PrihodElement[i].Input.kol),
          CIZena,CMantissaZ,Summa);
        rformat(Summa,CIZena);
        s:=s+Summa;

        TempBox^.List^.Insert(NewStr(s));
        TempBox^.SetRange(TempBox^.List^.Count);
      end;
     end;
    end; {for i:=1 to CMax do}

End; { For jk:=1 To Count Do}

  Dispose(P,Done);

  End; {while not eof(fp) do}

    iorez:=ioresult;
    close(fp);
    iorez:=ioresult;

  END;

  NoInfoMsg;

  R.Assign(0,0,0,0);
  SortBox := New(PBox, Init(R, 1, Nil));
  SortBox^.NewList(New(PTextCollection, Init(0,1)));


  if (TempBox<>nil) and (TempBox^.List^.Count>0) then
  for i:=0 to TempBox^.List^.Count-1 do
  begin
   DInfoMSGShkala('Сортировка отчета . . .  ',0,TempBox^.List^.Count-1,i);
   s:= TempBox^.GetText(i,TempBox^.List^.Count);
   sArt:=Copy(s,1,CArtikul);
   sPost:=Copy(s,1+CArtikul+1,CMakeKod);
   sPostName:=GetMakeField(FFullMake,sPost,0);
   format(sPostName,CClient);
   System.Insert(sPostName+SeparatorChar,s,1+CArtikul+1);
   sName:=GetIDField(FFFName,sArt);
   format(sName,CName+1+CName);
   s:=sName+SeparatorChar+s;

   SortBox^.List^.Insert(NewStr(s));
   SortBox^.SetRange(SortBox^.List^.Count);
  end;

  NoInfoMsg;

  Assign(t,Path^.Dat.ToTemp+'feliks.txt');
  IOrez:=ioresult;
  Rewrite(t);
  IOrez:=ioresult;
  if IORez<>0 then
  begin
   MessageBox(#3^M+#3'Ошибка создания файла '+Path^.Dat.ToTemp+'feliks.txt',Nil,mfError+mfCancelButton);
   Dispose(SortBox,Done);
   Dispose(TempBox,Done);
   Dispose(ErrBox,Done);
   exit;
  end;

  {Writeln(t,'Наименование;Код;Поставщик;Код;N накладной;Дата;Кол-во;Сумма');}
  Writeln(t,Header+Space+'Склад: ',GetClientField(FClient,Rek^.Dat.Kod,1)+'  Оператор: '+CurrentPassword);
  WRiteln(t,'        ОТЧЕТ ПО ПРИХОДАМ ПОСТАВЩИКОВ  с '+sStart+' по '+sStop);
  WriteLN(t,Space+HeaderStop);

Writeln(t,Header+GlobalPrn^.Dat.Condensed[Nprint^.DAt.Printer]
+Space+'┌────────────────────────────────────────────────────┬─────┬────────────────────┬────┬──────────────'+
'────────────┬────────┬──────┬───────────────┐');
Writeln(t,Space+'│           Наименование                             │ Код │   Поставщик        │ Код│  N накладной '
+'поставщика  │ Дата   │Кол-во│  Сумма З/Ц    │');
Writeln(t,Space+'└────────────────────────────────────────────────────┴─────┴────────────────────┴────┴─────────────────────'
+'─────┴────────┴──────┴───────────────┘'+
    HeaderStop);


  if (SortBox<>nil) and (SortBox^.List^.Count>0) then
  for i:=0 to SortBox^.List^.Count-1 do
  begin
   DInfoMSGShkala('Формирую отчет . . .  ',0,SortBox^.List^.Count-1,i);
   s:= SortBox^.GetText(i,SortBox^.List^.Count);
   writeln(t,Space+s);
  end;

  if (ErrBox<>nil) and (ErrBox^.List^.Count>0) then
  begin
   writeln(t);
   writeln(t,Space+'ВНИМАНИЕ!');
   for i:=0 to ErrBox^.List^.Count-1 do
   begin
     s:= ErrBox^.GetText(i,ErrBox^.List^.Count);
     writeln(t,Space+s);
   end;
  end;

  Writeln(t);
  Writeln(t,Space,'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
  Writeln(t,Space+'==========================================================================================================='
  +'======================================');

  NoInfoMsg;

  Dispose(ErrBox,Done);
  Dispose(SortBox,Done);
  Dispose(TempBox,Done);

  IOrez:=ioresult;
  Close(t);
  IOrez:=ioresult;

  ViewAsText(Path^.Dat.ToTemp+'feliks.txt','Анализ приходов поставщика с '+sStart+' по '+sStop,True);

END;

BEGIN
END.
