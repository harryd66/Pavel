{$I Compile.INC}

{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}


Unit Net1;

Interface

Uses ServStr,Dialogs,Glob;



Procedure ClientIDX(Regim : Boolean{True-авто;False-запрос});
Procedure CreatIDX;
Procedure CreatIDXAuto;
Procedure CreatIDXAutoOne(Art:ArtikulStr);
Procedure CreatIDIndex;

Procedure LoadRemoteDB;
Procedure FormPerevoski;
Procedure StoreRemoteDB;
Procedure SortList(Var NoScreenList:PBox);


Implementation

Uses Serv,MsgBox,NetCall,Dos,DbEngine,Views,Protect,Access,NetDbEng,Net,
     Memory,MAil,Printers,Tools,Utils5,Utils4,Net3,DbEngin2,
     ServStr2,
     Drivers,App,Objects,TpDate,inplong,ColorTxt,Utils,Utils1,Utils3;


Procedure ClientIDX(Regim : Boolean{True-авто;False-запрос});
Var c : LongInt;
    ws : String;
    ClientFile : File Of ClientType;
    ClientElement :ClientType;
    ClientIdxFile : File Of KurzClientType;
    ClientKurz :KurzClientType;
Begin

If Not Regim Then
 Begin
  If MessageBox(^M+#3'Функция требует монопольного использования базы данных!',Nil,mfWarning+mfOkCancel)<>cmOk Then
  Exit;
 End;
Assign (ClientFile,Path^.Dat.ToClient+'Client.db');
c:=IOResult;
Reset (ClientFile);
c:=IOResult;
Assign (ClientIdxFile,Path^.Dat.ToClientBaseIndex+'Client.idx');
c:=IOResult;
Rewrite (ClientIdxFile);
c:=IOResult;
AInfo('Идет восстановление индексов базы клиентов ...');
c:=0;
While Not(Eof(ClientFile)) Do
 Begin

     Repeat
      Pause(1);
     Until NetCall.Lock(ClientFile,FilePos(ClientFile)*SizeOf(ClientType),SizeOf(ClientType));

     Read(ClientFile,ClientElement);

  Str(c:4,ws);
  While Pos(' ',ws)>0 Do Ws[Pos(' ',ws)]:='0';
  Seek(ClientFile,FilePos(ClientFile)-1);
{
  DelSpace(ClientElement.RegionKod);
  RFormatZerro(ClientElement.RegionKod,CClientKod);
  DelSpace(ClientElement.RouteKod);
  RFormatZerro(ClientElement.RouteKod,CClientKod);
}
  ClientElement.Kod:=ws;

  With ClientElement Do
   Begin
     If Lizo>1 Then Lizo:=0;
   End;


  Write(ClientFile,ClientElement);

  With ClientElement Do
  Begin
  ClientKurz.Name:=Name;
  ClientKurz.Inn:=Copy(Inn,1,CIZena);
  ClientKurz.Kod:=StrToInt(Kod);
  ClientKurz.RouteKod:=StrToInt(RouteKod);
  ClientKurz.RegionKod:=StrToInt(RegionKod);
  ClientKurz.Employ:=Employ;
  ClientKurz.Status:=Status;
  ClientKurz.Main:=Main;
  ClientKurz.FantomKod:=StrToInt(FantomKod);
  End;

  Write(ClientIdxFile,ClientKurz);


     Repeat
      NetCall.UnLock(ClientFile,(FilePos(ClientFile)-1)*SizeOf(ClientType),SizeOf(ClientType));
     Until (DosError=0);


  Inc(c);
 End;
System.Close(ClientFile);
System.Close(ClientIdxFile);
NoInfo;

Assign (ClientFile,Path^.Dat.ToClient+'Make.db');
c:=IOResult;
Reset (ClientFile);
c:=IOResult;
Assign (ClientIdxFile,Path^.Dat.ToClientBaseIndex+'Make.idx');
c:=IOResult;
Rewrite (ClientIdxFile);
c:=IOResult;
AInfo('Идет восстановление индексов базы поставщиков...');
c:=0;
While Not(Eof(ClientFile)) Do
 Begin

     Repeat
      Pause(1);
     Until NetCall.Lock(ClientFile,FilePos(ClientFile)*SizeOf(ClientType),SizeOf(ClientType));

     Read(ClientFile,ClientElement);

  Str(c:4,ws);
  While Pos(' ',ws)>0 Do Ws[Pos(' ',ws)]:='0';
  Seek(ClientFile,FilePos(ClientFile)-1);
  ClientElement.Kod:=ws;

  With ClientElement Do
   Begin
     If Lizo>1 Then Lizo:=0;
   End;
  Write(ClientFile,ClientElement);

  With ClientElement Do
  Begin
  ClientKurz.Name:=Name;
  ClientKurz.Inn:=Copy(Inn,1,CIZena);
  ClientKurz.Kod:=StrToInt(Kod);
  ClientKurz.RegionKod:=StrToInt(RegionKod);
  ClientKurz.RouteKod:=StrToInt(RouteKod);
  ClientKurz.Employ:=Employ;
  ClientKurz.Status:=Status;
  ClientKurz.Main:=Main;
  ClientKurz.FantomKod:=StrToInt(FantomKod);
  End;

  Write(ClientIdxFile,ClientKurz);


     Repeat
      NetCall.UnLock(ClientFile,(FilePos(ClientFile)-1)*SizeOf(ClientType),SizeOf(ClientType));
     Until (DosError=0);


  Inc(c);
 End;
System.Close(ClientFile);
System.Close(ClientIdxFile);
NoInfo;

Assign (ClientFile,Path^.Dat.ToClient+'sklad.db');
c:=IOResult;
Reset (ClientFile);
c:=IOResult;
Assign (ClientIdxFile,Path^.Dat.ToClientBaseIndex+'Sklad.idx');
c:=IOResult;
Rewrite (ClientIdxFile);
c:=IOResult;
AInfo('Идет восстановление индексов базы складов...');
c:=0;
While Not(Eof(ClientFile)) Do
 Begin

     Repeat
      Pause(1);
     Until NetCall.Lock(ClientFile,FilePos(ClientFile)*SizeOf(ClientType),SizeOf(ClientType));

     Read(ClientFile,ClientElement);

  Str(c:4,ws);
  While Pos(' ',ws)>0 Do Ws[Pos(' ',ws)]:='0';
  Seek(ClientFile,FilePos(ClientFile)-1);
  ClientElement.Kod:=ws;
  With ClientElement Do
   Begin
     If Lizo>1 Then Lizo:=0;
   End;
  Write(ClientFile,ClientElement);

  With ClientElement Do
  Begin
  ClientKurz.Name:=Name;
  ClientKurz.Inn:=Copy(Inn,1,CIZena);
  ClientKurz.Kod:=StrToInt(Kod);
  ClientKurz.RouteKod:=StrToInt(RouteKod);
  ClientKurz.RegionKod:=StrToInt(RegionKod);
  ClientKurz.Employ:=Employ;
  ClientKurz.Status:=Status;
  ClientKurz.Main:=Main;
  ClientKurz.FantomKod:=StrToInt(FantomKod);
  End;

  Write(ClientIdxFile,ClientKurz);

     Repeat
      NetCall.UnLock(ClientFile,(FilePos(ClientFile)-1)*SizeOf(ClientType),SizeOf(ClientType));
     Until (DosError=0);


  Inc(c);
 End;
System.Close(ClientFile);
System.Close(ClientIdxFile);
NoInfo;


Assign (ClientFile,Path^.Dat.ToClient+'barter.db');
c:=IOResult;
Reset (ClientFile);
c:=IOResult;
Assign (ClientIdxFile,Path^.Dat.ToClientBaseIndex+'barter.idx');
c:=IOResult;
Rewrite (ClientIdxFile);
c:=IOResult;
AInfo('Идет восстановление индексов базы клиентов...');
c:=0;
While Not(Eof(ClientFile)) Do
 Begin

     Repeat
      Pause(1);
     Until NetCall.Lock(ClientFile,FilePos(ClientFile)*SizeOf(ClientType),SizeOf(ClientType));

     Read(ClientFile,ClientElement);

  Str(c:4,ws);
  While Pos(' ',ws)>0 Do Ws[Pos(' ',ws)]:='0';
  Seek(ClientFile,FilePos(ClientFile)-1);
  ClientElement.Kod:=ws;
  With ClientElement Do
   Begin
     If Lizo>1 Then Lizo:=0;
   End;
  Write(ClientFile,ClientElement);

  With ClientElement Do
  Begin
  ClientKurz.Name:=Name;
  ClientKurz.Inn:=Copy(Inn,1,CIZena);
  ClientKurz.Kod:=StrToInt(Kod);
  ClientKurz.RouteKod:=StrToInt(RouteKod);
  ClientKurz.RegionKod:=StrToInt(RegionKod);
  ClientKurz.Employ:=Employ;
  ClientKurz.Status:=Status;
  ClientKurz.Main:=Main;
  ClientKurz.FantomKod:=StrToInt(FantomKod);
  End;

  Write(ClientIdxFile,ClientKurz);

     Repeat
      NetCall.UnLock(ClientFile,(FilePos(ClientFile)-1)*SizeOf(ClientType),SizeOf(ClientType));
     Until (DosError=0);


  Inc(c);
 End;
System.Close(ClientFile);
System.Close(ClientIdxFile);
NoInfo;


Assign (ClientFile,Path^.Dat.ToClient+'agent.db');
c:=IOResult;
Reset (ClientFile);
c:=IOResult;
Assign (ClientIdxFile,Path^.Dat.ToClientBaseIndex+'agent.idx');
c:=IOResult;
Rewrite (ClientIdxFile);
c:=IOResult;
AInfo('Идет восстановление индексов базы агентов...');
c:=0;
While Not(Eof(ClientFile)) Do
 Begin

     Repeat
      Pause(1);
     Until NetCall.Lock(ClientFile,FilePos(ClientFile)*SizeOf(ClientType),SizeOf(ClientType));

     Read(ClientFile,ClientElement);

  Str(c:4,ws);
  While Pos(' ',ws)>0 Do Ws[Pos(' ',ws)]:='0';
  Seek(ClientFile,FilePos(ClientFile)-1);
  ClientElement.Main:=0;
  ClientElement.Debit:=0;
  ClientElement.Status:=0;
  ClientElement.FantomKod:='0000';
  ClientElement.Kod:=ws;
  With ClientElement Do
   Begin
     If Lizo>1 Then Lizo:=0;
   End;
  Write(ClientFile,ClientElement);

  With ClientElement Do
  Begin
  ClientKurz.Name:=Name;
  ClientKurz.Kod:=StrToInt(Kod);
  ClientKurz.RouteKod:=StrToInt(RouteKod);
  ClientKurz.RegionKod:=StrToInt(RegionKod);
  ClientKurz.Inn:=Copy(Inn,1,CIZena);
  ClientKurz.Employ:=Employ;
  ClientKurz.Status:=Status;
  ClientKurz.Main:=0;
  ClientKurz.FantomKod:=StrToInt('0');
  End;
  Write(ClientIdxFile,ClientKurz);
     Repeat
      NetCall.UnLock(ClientFile,(FilePos(ClientFile)-1)*SizeOf(ClientType),SizeOf(ClientType));
     Until (DosError=0);
  Inc(c);
 End;
System.Close(ClientFile);
System.Close(ClientIdxFile);
NoInfo;

Assign (ClientFile,Path^.Dat.ToClient+'Eksped.db');
c:=IOResult;
Reset (ClientFile);
c:=IOResult;
Assign (ClientIdxFile,Path^.Dat.ToClientBaseIndex+'Eksped.idx');
c:=IOResult;
Rewrite (ClientIdxFile);
c:=IOResult;
AInfo('Идет восстановление индексов базы экспедиторов...');
c:=0;
While Not(Eof(ClientFile)) Do
 Begin

     Repeat
      Pause(1);
     Until NetCall.Lock(ClientFile,FilePos(ClientFile)*SizeOf(ClientType),SizeOf(ClientType));

     Read(ClientFile,ClientElement);

  Str(c:4,ws);
  While Pos(' ',ws)>0 Do Ws[Pos(' ',ws)]:='0';
  Seek(ClientFile,FilePos(ClientFile)-1);
  ClientElement.Debit:=0;
  ClientElement.Status:=0;
  ClientElement.Main:=0;
  ClientElement.FantomKod:='0000';
  ClientElement.Kod:=ws;
  With ClientElement Do
   Begin
     If Lizo>1 Then Lizo:=0;
   End;
  Write(ClientFile,ClientElement);

  With ClientElement Do
  Begin
  ClientKurz.Name:=Name;
  ClientKurz.Kod:=StrToInt(Kod);
  ClientKurz.RouteKod:=StrToInt(RouteKod);
  ClientKurz.RegionKod:=StrToInt(RegionKod);
  ClientKurz.Inn:=Copy(Inn,1,CIZena);
  ClientKurz.Employ:=Employ;
  ClientKurz.Status:=Status;
  ClientKurz.Main:=0;
  ClientKurz.FantomKod:=StrToInt('0');
  End;
  Write(ClientIdxFile,ClientKurz);
     Repeat
      NetCall.UnLock(ClientFile,(FilePos(ClientFile)-1)*SizeOf(ClientType),SizeOf(ClientType));
     Until (DosError=0);
  Inc(c);
 End;
System.Close(ClientFile);
System.Close(ClientIdxFile);
NoInfo;

End;





Procedure FixSize(st:ArtikulStr);
VAr Max,SizeID,SizeDB,SizeSkl : LongInt;
    Id : PBazType;
    FID : BazFileType;
    Db : PSkladType;
    FDb : SkladFileType;
    Skl: PSkidkaType;
    FSkl : SkidkaFileType;
    c1,c,j : LongInt;
    RKod,s : AllStr;
Begin
{
1.вычисляем реальные размеры каждой из баз
2.Ищем максимальный из них но небольше 1000
3.Подгоняем каждую из баз под максимальный размер
}
Max:=0;
RKod:=InTToStr(StrToInt(st),CRazdelKod);
RFormatZerro(RKod,CRazdelKod);

Assign(FId,Path^.Dat.ToName+RKod+'.id');
j:=IOResult;
Reset(FId);
j:=IOResult;
SizeID:=FileSize(FId);
j:=IOResult;
Close(FID);
j:=IOResult;

If Max<SizeID Then Max:=SizeID;


Assign(FDB,Path^.Dat.ToSklad+RKod+'.db');
j:=IOResult;
Reset(FdB);
j:=IOResult;
SizeDB:=FileSize(FdB);
j:=IOResult;
Close(FDb);
j:=IOResult;

If Max<SizeDB Then Max:=SizeDB;


Assign(FSkl,Path^.Dat.ToSkidki+RKod+'.skl');
j:=IOResult;
Reset(FSkl);
j:=IOResult;
SizeSkl:=FileSize(FSkl);
j:=IOResult;
Close(FSkl);
j:=IOResult;

If Max<SizeSkl Then Max:=SizeSkl;


If Max>1000 Then Max:=1000;



{разбираемся c ID}
If SizeID<>MAx Then
 Begin
  If SizeID<Max Then
   Begin
    Assign(FId,Path^.Dat.ToName+RKod+'.id');
    Reset(FId);
    j:=IOResult;
    If j=0 Then
      Begin
          Seek(FId,SizeID);
          New(id,Init);
          For c:=1 To (Max-SizeID) Do
                Begin
                 Str({C+SizeID-1}FilePos(FId):3,S);
                 RFormatZerro(s,3);
                 id^.Dat.BazKod:=RKod+s;
                 id^.Dat.FantomKod:=id^.Dat.BazKod;
                 id^.Dat.Employ:=False;
                 id^.Dat.Caption:=CurrentPassword;
                 Seek(FID,FileSize(FID));
                 Write(FID,id^.Dat);
                End;
          Dispose(id,Done);
          c:=Ioresult;
          Close(FID);
          c:=Ioresult;
      End
        Else
         Begin
          MessageBox(^M+#3'Ошибка открытия '+Path^.Dat.ToName+RKod+'.id Код:'+InTToStr(j,CKol),Nil,mfError+mfCancelButton);
         End;
   End;

  If (SizeID>Max+1) Then
   Begin
    Assign(FID,Path^.Dat.ToName+RKod+'.ID');
    Reset(FID);
    j:=IOResult;
    If j=0 Then
      Begin
          Seek(FID,Max+1);
          Truncate(FID);
          c:=Ioresult;
          Close(FID);
          c:=Ioresult;
      End
        Else
         Begin
          MessageBox(^M+#3'Ошибка открытия '+Path^.Dat.ToSklad+RKod+'.ID Код:'+InTToStr(j,CKol),Nil,mfError+mfCancelButton);
         End;
   End;


 End;

{разбираемся c DB}
If SizeDB<>MAx Then
 Begin
  If SizeDB<Max Then
   Begin
    Assign(FDB,Path^.Dat.ToSklad+RKod+'.db');
    Reset(FDB);
    j:=IOResult;
    If j=0 Then
      Begin
          Seek(FDB,SizeDB);
          New(DB,Init);
          For c:=1 To (Max-SizeDB) Do
                Begin
                 Str({C+SizeDB-1}FilePos(FDB):3,S);
                 RFormatZerro(s,3);
                 DB^.Dat.BazKod:=RKod+s;
                 DB^.Dat.Employ:=False;
                 DB^.Dat.Time:=CurrentTime;
                 DB^.Dat.Date:=DateStringToDAte(DateMask,FDate);
                 Seek(FDB,FileSize(FDB));
                 Write(FDB,DB^.Dat);
                End;
          Dispose(DB,Done);
          c:=Ioresult;
          Close(FDB);
          c:=Ioresult;
      End
        Else
         Begin
          MessageBox(^M+#3'Ошибка открытия '+Path^.Dat.ToSklad+RKod+'.db Код:'+InTToStr(j,CKol),Nil,mfError+mfCancelButton);
         End;
   End;

  If (SizeDB>Max+1) Then
   Begin
    Assign(FDB,Path^.Dat.ToSklad+RKod+'.db');
    Reset(FDB);
    j:=IOResult;
    If j=0 Then
      Begin
          Seek(FDB,Max+1);
          Truncate(FDB);
          c:=Ioresult;
          Close(FDB);
          c:=Ioresult;
      End
        Else
         Begin
          MessageBox(^M+#3'Ошибка открытия '+Path^.Dat.ToSklad+RKod+'.db Код:'+InTToStr(j,CKol),Nil,mfError+mfCancelButton);
         End;
   End;


 End;

{разбираемся c SKL}
If SizeSKL<>MAx Then
 Begin
  If SizeSKL<Max Then
   Begin
    Assign(FSkl,Path^.Dat.ToSkidki+RKod+'.skl');
    Reset(FSKL);
    j:=IOResult;
    If j=0 Then
      Begin
          Seek(FSKL,SizeSKL);
          New(SKL,Init);
          For c:=1 To (Max-SizeSKL) Do
                Begin
                 Str({C+SizeSKL-1}FilePos(FSKL):3,S);
                 RFormatZerro(s,3);

                 For c1:=1 To 6 Do
                 Begin
                  SKL^.Dat.Skidka[c1].Up:='0.00';
                  SKL^.Dat.Skidka[c1].Proz:='0.00';
                 End;
                 SKL^.Dat.Caption:=CurrentPassword;
                 SKL^.Dat.BazKod:=RKod+s;
                 SKL^.Dat.Time:=Times;
                 SKL^.Dat.Date:=FDate;

                 Seek(FSKL,FileSize(FSKL));
                 Write(FSKL,SKL^.Dat);
                End;
          Dispose(SKL,Done);
          c:=Ioresult;
          Close(FSKL);
          c:=Ioresult;
      End
        Else
         Begin
          MessageBox(^M+#3'Ошибка открытия '+Path^.Dat.ToSkidki+RKod+'.skl Код:'+InTToStr(j,CKol),Nil,mfError+mfCancelButton);
         End;
   End;

  If (SizeSKL>Max+1) Then
   Begin
    Assign(FSkl,Path^.Dat.ToSkidki+RKod+'.skl');
    Reset(FSKL);
    j:=IOResult;
    If j=0 Then
      Begin
          Seek(FSKL,Max+1);
          Truncate(FSkl);
          c:=Ioresult;
          Close(FSKL);
          c:=Ioresult;
      End
        Else
         Begin
          MessageBox(^M+#3'Ошибка открытия '+Path^.Dat.ToSkidki+RKod+'.skl Код:'+InTToStr(j,CKol),Nil,mfError+mfCancelButton);
         End;
   End;



 End;


End;






Procedure CreatIDX;
VAr sklFile : File Of SkladType;
    skl : pSkladType;
    RazdelFile : File Of RazdelType;
    RazdelElement : RazdelType;

    IndexFileNew : File Of SkladTypeNew;
    Indexnew : PSkladTypenew;
    Be : PBazType;

    F : Boolean;
    c : Word;
    ch : LongInt;
    SArt : ArtikulStr;
    ws : String;
    k,All : LongInt;
    j : Word;
Begin

If MessageBox(^M+#3'Функция требует монопольного использования базы данных!',Nil,mfWarning+mfOkCancel)<>cmOk Then
Exit;
c:=IOResult;
Assign(RazdelFile,Path^.Dat.ToRazdel+'Razdel.db');
Reset(RazdelFile);
c:=IOResult;
If c<>0 Then
 Begin
  MessageBox(^M+#3'Ошибка доступа к файлу разделов!',Nil,mfError+mfCancelButton);
  Exit;
 End;

While Not(Eof(RazdelFile)) Do
 Begin
  Read(RazdelFile,RazdelElement);
  If RazdelElement.Employ Then
  Begin
   DInfo('Идет восстановление индексов раздела '+RazdelElement.Kod+'...');

   FixSize(RazdelElement.Kod);

   Assign(SklFile,Path^.Dat.ToSklad+RazdelElement.Kod+'.db');
   c:=IOResult;
   Reset(SklFile);
   c:=IOResult;
If c<>0 Then
 Begin
  Close(RazdelFile);
  NoInfo;
  MessageBox(^M+#3'Ошибка доступа к файлу '+Path^.Dat.ToSklad+RazdelElement.Kod+'.db',Nil,mfError+mfCancelButton);
  Exit;
 End;


c:=IOResult;
Assign(IndexFileNew,Path^.Dat.ToIndex+RazdelElement.Kod+'.kdx');
Rewrite(IndexFileNew);
c:=IOResult;
If c<>0 Then
 Begin
  Close(RazdelFile);
  Close(SklFile);
  NoInfo;
  MessageBox(^M+#3'Ошибка создания файла индексов '+Path^.Dat.ToIndex+RazdelElement.Kod+'.kdx'+'!',Nil,
  mfError+mfCancelButton);
  Exit;
 End;

   New(Skl,Init);
   New(IndexNew,Init);
   ch:=0;
   While Not(Eof(sklFile)) Do
    Begin

     Repeat
      Pause(1);
     Until NetCAll.Lock(SklFile,FilePos(SklFile)*SizeOf(SkladType),SizeOf(SkladType));

     Read(SklFile,Skl^.Dat);
     Str(ch:3,ws);
     RFormatZerro(ws,3);
     {While Pos(' ',ws)>0 Do Ws[Pos(' ',ws)]:='0';}


     If Skl^.Dat.Employ Then
     With Skl^.Dat.Input Do
     Begin
      All:=0;
      For k:=1 To CDivision Do
       Begin
          Str(StrToInt(Division[k]):CKol,Division[k]);
          DelSpace(Division[k]);
          All:=All+StrToInt(Division[k]);
        End;
      Str(All:CKol,Skl^.Dat.Input.Kol);
      DelSpace(Skl^.Dat.Input.Kol);
      All:=0;
      For k:=1 To CDivision Do
        Begin
           Str(StrToInt(DivisionR[k]):CKol,DivisionR[k]);
           DelSpace(DivisionR[k]);
           All:=All+StrToInt(DivisionR[k]);
        End;
      Str(All:CKol,Skl^.Dat.Input.KolR);
      DelSpace(Skl^.Dat.Input.KolR);
      MyStr(StrToReal(Skl^.Dat.Input.R_Zena),CZena,CMantissa,Skl^.Dat.Input.R_Zena);
      DelSpace(Skl^.Dat.Input.R_Zena);
      Skl^.Dat.Input.NMAkeKod:=IntToStr(StrToInt(Skl^.Dat.Input.NMAkeKod),CArtikul);
      RFormatZerro(Skl^.Dat.Input.NMAkeKod,CArtikul);
      Skl^.Dat.BazKod:=IntToStr(FilePos(SklFile)-1,3);
      RFormatZerro(Skl^.Dat.BazKod,3);
      Skl^.Dat.BazKod:=RazdelElement.Kod+Skl^.Dat.BazKod;
   Skl^.Dat.Input.NGTD    :=IntToStr(StrToInt(Skl^.Dat.Input.NGTD),CArtikul);
      RFormatZerro(Skl^.Dat.Input.NGTD,CArtikul);
   Skl^.Dat.Input.Marka   :=IntToStr(StrToInt(Skl^.Dat.Input.Marka),CArtikul);
      RFormatZerro(Skl^.Dat.Input.Marka,CArtikul);
      Skl^.Dat.Input.SpecMarka :=IntToStr(StrToInt(Skl^.Dat.Input.SpecMarka),CArtikul);
      RFormatZerro(Skl^.Dat.Input.SpecMarka,CArtikul);
      Skl^.Dat.Input.Expert :=IntToStr(StrToInt(Skl^.Dat.Input.Expert),CArtikul);
      RFormatZerro(Skl^.Dat.Input.Expert,CArtikul);
   Skl^.Dat.Input.NSertif :=IntToStr(StrToInt(Skl^.Dat.Input.NSertif),CArtikul);
      RFormatZerro(Skl^.Dat.Input.NSertif,CArtikul);
      MyStr(StrToReal(Skl^.Dat.Input.O_Zena),CZena,CMantissa,Skl^.Dat.Input.O_Zena);
      DelSpace(Skl^.Dat.Input.O_Zena);
      MyStr(StrToReal(Skl^.Dat.Input.Spec_Zena),CZena,CMantissa,Skl^.Dat.Input.Spec_Zena);
      DelSpace(Skl^.Dat.Input.Spec_Zena);
      Skl^.Dat.Date:=DateStringToDAte(DateMask,FDate);
      Skl^.Dat.Time:=CurrentTime;
      MyStr(StrToReal(Skl^.Dat.Input.Zakupka),CZenaZ,CMantissaZ,Skl^.Dat.Input.Zakupka);

      Skl^.Dat.Input.Caption:=CurrentPassword;
      If Skl^.Dat.Input.RegionMarka>=1 Then Skl^.Dat.Input.RegionMarka:=1
      Else Skl^.Dat.Input.RegionMarka:=0;

     End;{With}

     If Skl^.Dat.Employ Then
     Begin
      New(BE,Init);
      GetBazElement(Skl^.Dat.BazKod,BE^.Dat);
      If Be^.Dat.Main=1 Then
       Begin
        SArt:=Be^.Dat.FantomKod;
        GetBazElement(SArt,BE^.Dat);
        {восстанавливаем базовый код}
        Be^.Dat.BazKod:=Skl^.Dat.BazKod;
        {восстанавливаем ссылочный код}
        Be^.Dat.FantomKod:=SArt;
        Be^.Dat.Main:=1;
       End;
      IndexNew^.Dat.Name :=Be^.Dat.Name;
      IndexNew^.Dat.Name2:=Be^.Dat.Name2;
      IndexNew^.Dat.Main:=Be^.Dat.Main;
      IndexNew^.Dat.FantomKod:=StrToInt(Be^.Dat.FantomKod);
      IndexNew^.Dat.EnableSklads:=Be^.Dat.EnableSklads;
      IndexNew^.Dat.NGroupKod:=StrToInt(Be^.Dat.NGroupKod);
      IndexNew^.Dat.FirmaPostKod:=StrToInt(Be^.Dat.FirmaPostKod);
      IndexNew^.Dat.NMarkaKod:=StrToInt(Skl^.Dat.Input.Marka);
      IndexNew^.Dat.NSpecMarkaKod:=StrToInt(Skl^.Dat.Input.SpecMarka);
      IndexNew^.Dat.NExpertKod:=StrToInt(Skl^.Dat.Input.Expert);
      IndexNew^.Dat.NGTDKod:=StrToInt(Skl^.Dat.Input.NGTD);
      Dispose(BE,Done);
     End
      Else
       Begin
        IndexNew^.Dat.Name :='';
        IndexNew^.Dat.Name2:='';
        IndexNew^.Dat.Main:=0;
        IndexNew^.Dat.FantomKod:=IndexNew^.Dat.BazKod;
        IndexNew^.Dat.EnableSklads:=0;
        IndexNew^.Dat.NGroupKod:=0;
        IndexNew^.Dat.NMarkaKod:=0;
        IndexNew^.Dat.NSpecMarkaKod:=0;
        IndexNew^.Dat.NGTDKod:=0;
        IndexNew^.Dat.NExpertKod:=0;
        IndexNew^.Dat.FirmaPostKod:=0;
       End;

     IndexNew^.Dat.Virabotano :=DateStringToDate(DateMask,Skl^.Dat.input.Virabotano);
     IndexNew^.Dat.Employ :=Skl^.DAt.Employ;
     IndexNew^.Dat.NSertif :=StrToInt(Skl^.DAt.Input.NSertif);

     For j:=1 To CDivision Do IndexNew^.Dat.Division[j]:=StrToInt(Skl^.Dat.Input.Division[j]);
     For j:=1 To CDivision Do IndexNew^.Dat.DivisionR[j]:=StrToInt(Skl^.Dat.Input.DivisionR[j]);
     IndexNew^.Dat.R_Zena  :=StrToreal(Skl^.Dat.Input.R_Zena);
     IndexNew^.Dat.Zakupka :=StrToreal(Skl^.Dat.Input.Zakupka);
     IndexNew^.Dat.Zakupka2:=StrToreal(Skl^.Dat.Input.Zakupka2);
     IndexNew^.Dat.AkzisSbor:=StrToreal(Skl^.Dat.Input.AkzisSbor);

     IndexNew^.Dat.RegionMarka:=Skl^.Dat.Input.RegionMarka;
     IndexNew^.Dat.BazKod:=StrToInt(Skl^.Dat.BazKod);
     IndexNew^.Dat.Kol:=StrToInt(Skl^.Dat.Input.Kol);
     IndexNew^.Dat.StrihKod:=Skl^.Dat.Input.StrihKod;
     IndexNew^.Dat.NMakeKod:=StrToInt(Skl^.Dat.Input.NMakeKod);

     ws:=RazdelElement.Kod+ws;

     Seek(SklFile,FilePos(SklFile)-1);
     Skl^.Dat.BazKod:=ws;
     Write(SklFile,Skl^.Dat);

     Write(IndexFileNew,IndexNew^.Dat);

     Repeat
      NetCall.UnLock(SklFile,(FilePos(SklFile)-1)*SizeOf(SkladType),SizeOf(SkladType));
     Until (DosError=0);

     Inc(ch);
     End;

   Dispose(Skl,Done);
   Close(SklFile);
   Close(IndexFileNew);
   Dispose(IndexNew,Done);
   NoInfo;
   End;
 End;
Close(RazdelFile);
MessageBox(^M+#3'Переиндексация завершена!',Nil,mfInformation+mfCancelButton);
End;



Procedure CreatIDIndex;
VAr sklFile : File Of BazType;
    skl : pBazType;
    RazdelFile : File Of RazdelType;
    RazdelElement : RazdelType;

    F : Boolean;
    c : Word;
    ch : LongInt;
    ws : String;
    k,All : LongInt;
    j : Word;
Begin
If MessageBox(^M+#3'Функция требует монопольного использования базы данных!',Nil,mfWarning+mfOkCancel)<>cmOk Then
Exit;
c:=IOResult;
Assign(RazdelFile,Path^.Dat.ToRazdel+'Razdel.db');
Reset(RazdelFile);
c:=IOResult;
If c<>0 Then
 Begin
  MessageBox(^M+#3'Ошибка доступа к файлу разделов!',Nil,mfError+mfCancelButton);
  Exit;
 End;
While Not(Eof(RazdelFile)) Do
 Begin
  Read(RazdelFile,RazdelElement);
  If RazdelElement.Employ Then
  Begin
   DInfo('Идет восстановление индексов наименований раздела '+RazdelElement.Kod+'...');
   Assign(SklFile,Path^.Dat.ToName+RazdelElement.Kod+'.id');
   c:=IOResult;
   Reset(SklFile);
   c:=IOResult;
If c<>0 Then
 Begin
  Close(RazdelFile);
  NoInfo;
  MessageBox(^M+#3'Ошибка доступа к файлу '+Path^.Dat.ToName+RazdelElement.Kod+'.id',Nil,mfError+mfCancelButton);
  Exit;
 End;


c:=IOResult;

   New(Skl,Init);
   ch:=0;

   While Not(Eof(sklFile)) Do
    Begin

     Repeat
      Pause(1);
     Until NetCAll.Lock(SklFile,FilePos(SklFile)*SizeOf(BazType),SizeOf(BazType));

     Read(SklFile,Skl^.Dat);
     Str(ch:3,ws);
     RFormatZerro(ws,3);
     {While Pos(' ',ws)>0 Do Ws[Pos(' ',ws)]:='0';}


     If Skl^.Dat.Employ Then
     With Skl^.Dat Do
     Begin

     Skl^.Dat.BazKod:=IntToStr(FilePos(SklFile)-1,3);
     RFormatZerro(Skl^.Dat.BazKod,3);
     Skl^.Dat.BazKod:=RazdelElement.Kod+Skl^.Dat.BazKod;

     If Skl^.Dat.Main=0 Then
     Skl^.Dat.FantomKod:=Skl^.Dat.BazKod
     Else
     RFormatZerro(Skl^.Dat.FantomKod,CClientKod);

  Skl^.Dat.Mera    :=IntToStr(StrToInt(Skl^.Dat.Mera),CClientkod);
     RFormatZerro(Skl^.Dat.Mera,CClientkod);


     If Skl^.Dat.Recalc>1 Then Skl^.Dat.Recalc:=1;

  Skl^.Dat.PostKod    :=IntToStr(StrToInt(Skl^.Dat.PostKod),CClientkod);
     RFormatZerro(Skl^.Dat.PostKod,CClientkod);

  Skl^.Dat.FirmaPostKod    :=IntToStr(StrToInt(Skl^.Dat.FirmaPostKod),CClientkod);
     RFormatZerro(Skl^.Dat.FirmaPostKod,CClientkod);

  Skl^.Dat.NGroupKod    :=IntToStr(StrToInt(Skl^.Dat.NGroupKod),CClientkod);
     RFormatZerro(Skl^.Dat.NGroupKod,CClientkod);




     End;{With}


     Seek(SklFile,FilePos(SklFile)-1);
     Write(SklFile,Skl^.Dat);

     Repeat
      NetCall.UnLock(SklFile,(FilePos(SklFile)-1)*SizeOf(BazType),SizeOf(BazType));
     Until (DosError=0);

     Inc(ch);
     End;{While}

   Dispose(Skl,Done);
   c:=IOResult;
   Close(SklFile);
   c:=IOResult;
   NoInfo;
   End;
 End;
c:=IOResult;
Close(RazdelFile);
c:=IOResult;
AddProtocol('Переиндексация наименований успешно завершена!','','');

MessageBox(^M+#3'Переиндексация завершена!',Nil,mfInformation+mfCancelButton);
End;











(*
Procedure CreatIDX;
VAr sklFile : File Of SkladType;
    skl : pSkladType;
    RazdelFile : File Of RazdelType;
    RazdelElement : RazdelType;
    IndexFile : IndexFileType;
    Index : PIndexType;
    F : Boolean;
    c : Word;
    ch : LongInt;
    ws : String;
    k,All : LongInt;

Begin
If MessageBox(^M+#3'Функция требует монопольного использования базы данных!',Nil,mfWarning+mfOkCancel)<>cmOk Then
Exit;
c:=IOResult;
Assign(RazdelFile,Path^.Dat.ToRazdel+'Razdel.db');
Reset(RazdelFile);
c:=IOResult;
If c<>0 Then
 Begin
  MessageBox(^M+#3'Ошибка доступа к файлу разделов!',Nil,mfError+mfCancelButton);
  Exit;
 End;
While Not(Eof(RazdelFile)) Do
 Begin
  Read(RazdelFile,RazdelElement);
  If RazdelElement.Employ Then
  Begin
   DInfo('Идет восстановление индексов раздела '+RazdelElement.Kod+'...');
   Assign(SklFile,Path^.Dat.ToSklad+RazdelElement.Kod+'.db');
   c:=IOResult;
   Reset(SklFile);
   c:=IOResult;
If c<>0 Then
 Begin
  Close(RazdelFile);
  NoInfo;
  MessageBox(^M+#3'Ошибка доступа к файлу '+Path^.Dat.ToSklad+RazdelElement.Kod+'.db',Nil,mfError+mfCancelButton);
  Exit;
 End;

c:=IOResult;
Assign(IndexFile,Path^.Dat.ToIndex+RazdelElement.Kod+'.idx');
Rewrite(IndexFile);
c:=IOResult;
If c<>0 Then
 Begin
  Close(RazdelFile);
  Close(SklFile);
  NoInfo;
  MessageBox(^M+#3'Ошибка создания файла индексов '+Path^.Dat.ToIndex+RazdelElement.Kod+'.idx'+'!',Nil,
  mfError+mfCancelButton);
  Exit;
 End;

   New(Skl,Init);
   New(Index,Init);
   ch:=0;
   While Not(Eof(sklFile)) Do
    Begin

     Repeat
      Pause(1);
     Until NetCAll.Lock(SklFile,FilePos(SklFile)*SizeOf(SkladType),SizeOf(SkladType));

     Read(SklFile,Skl^.Dat);
     Str(ch:3,ws);
     While Pos(' ',ws)>0 Do Ws[Pos(' ',ws)]:='0';

     If Skl^.Dat.Employ Then
     With Skl^.Dat.Input Do
     Begin
      All:=0;
      For k:=1 To CDivision Do
        Begin
           Str(StrToInt(Division[k]):CKol,Division[k]);
           DelSpace(Division[k]);
           All:=All+StrToInt(Division[k]);
        End;
     Str(All:CKol,Skl^.Dat.Input.Kol);
     DelSpace(Skl^.Dat.Input.Kol);

     If StrToInt(Skl^.Dat.Input.Kol)>0 Then
     Index^.Dat.Present[StrToInt(ws)]:=True
     Else
     Index^.Dat.Present[StrToInt(ws)]:=False;

     DelSpace(Skl^.Dat.Input.Kol);



      All:=0;
      For k:=1 To CDivision Do
        Begin
           Str(StrToInt(DivisionR[k]):CKol,DivisionR[k]);
           DelSpace(DivisionR[k]);
           All:=All+StrToInt(DivisionR[k]);
        End;
     Str(All:CKol,Skl^.Dat.Input.KolR);
     DelSpace(Skl^.Dat.Input.KolR);





     MyStr(StrToReal(Skl^.Dat.Input.R_Zena),CZena,CMantissa,Skl^.Dat.Input.R_Zena);
     DelSpace(Skl^.Dat.Input.R_Zena);

     MyStr(StrToReal(Skl^.Dat.Input.O_Zena),CZena,CMantissa,Skl^.Dat.Input.O_Zena);
     DelSpace(Skl^.Dat.Input.O_Zena);

     Skl^.Dat.Date:=DateStringToDAte(DateMask,FDate);
     Skl^.Dat.Time:=CurrentTime;
     MyStr(StrToReal(Skl^.Dat.Input.Zakupka),CZenaZ,CMantissaZ,Skl^.Dat.Input.Zakupka);
    {Skl^.Dat.Input.Akzis1:=#0;
     Skl^.Dat.Input.Sertifikat[0]:=#0;
     Skl^.Dat.Input.Post[0]:=#0;}
     Skl^.Dat.Input.Caption:='00';
     End;


     ws:=RazdelElement.Kod+ws;

     Seek(SklFile,FilePos(SklFile)-1);
     Skl^.Dat.BazKod:=ws;
     Write(SklFile,Skl^.Dat);

     Repeat
      NetCall.UnLock(SklFile,(FilePos(SklFile)-1)*SizeOf(SkladType),SizeOf(SkladType));
     Until (DosError=0);

     Inc(ch);
     End;

   Dispose(Skl,Done);
   Close(SklFile);
   Write(IndexFile,Index^.Dat);
   Close(IndexFile);
   Dispose(Index,Done);
   NoInfo;
   End;
 End;
Close(RazdelFile);
MessageBox(^M+#3'Переиндексация завершена!',Nil,mfInformation+mfCancelButton);
End;
*)


Procedure CreatIDXAutoOne(Art:ArtikulStr);
VAr sklFile : File Of SkladType;
    skl : pSkladType;
    RazdelFile : File Of RazdelType;
    RazdelElement : RazdelType;
    Be : PBazType;
    SArt : ArtikulStr;

    IndexFileNew : File Of SkladTypeNew;
    Indexnew : PSkladTypenew;

    F : Boolean;
    c,k1 : Word;
    ch : LongInt;
    ws : String;
    k,All : LongInt;
    j : Word;
Begin
   DInfoMsg('Идет создание индексов раздела '+Art+'...',False);

   Assign(SklFile,Path^.Dat.ToSklad+Art+'.db');
   c:=IOResult;
   Reset(SklFile);
   c:=IOResult;

If c<>0 Then
 Begin
  NoInfoMsg;
  MessageBox(^M+#3'Ошибка доступа к файлу '+Path^.Dat.ToSklad+Art+'.db',Nil,mfError+mfCancelButton);
  Exit;
 End;


c:=IOResult;
Assign(IndexFileNew,Path^.Dat.ToIndex+Art+'.kdx');
Rewrite(IndexFileNew);
c:=IOResult;
If c<>0 Then
 Begin
  NoInfoMsg;
  Close(SklFile);
  MessageBox(^M+#3'Ошибка создания файла индексов '+Path^.Dat.ToIndex+Art+'.kdx'+'!',Nil,
  mfError+mfCancelButton);
  Exit;
 End;

   New(Skl,Init);
   New(IndexNew,Init);
   ch:=0;
   While Not(Eof(sklFile)) Do
    Begin

     Repeat
      Pause(1);
     Until NetCAll.Lock(SklFile,FilePos(SklFile)*SizeOf(SkladType),SizeOf(SkladType));

     Read(SklFile,Skl^.Dat);
     Str(ch:3,ws);
     While Pos(' ',ws)>0 Do Ws[Pos(' ',ws)]:='0';

     If Skl^.Dat.Employ Then
     With Skl^.Dat.Input Do
     Begin
      All:=0;
      For k:=1 To CDivision Do
        Begin
           Str(StrToInt(Division[k]):CKol,Division[k]);
           DelSpace(Division[k]);
           All:=All+StrToInt(Division[k]);
        End;
     Str(All:CKol,Skl^.Dat.Input.Kol);
     DelSpace(Skl^.Dat.Input.Kol);

      All:=0;
      For k:=1 To CDivision Do
        Begin
           Str(StrToInt(DivisionR[k]):CKol,DivisionR[k]);
           DelSpace(DivisionR[k]);
           All:=All+StrToInt(DivisionR[k]);
        End;
     Str(All:CKol,Skl^.Dat.Input.KolR);
     DelSpace(Skl^.Dat.Input.KolR);


     MyStr(StrToReal(Skl^.Dat.Input.R_Zena),CZena,CMantissa,Skl^.Dat.Input.R_Zena);
     DelSpace(Skl^.Dat.Input.R_Zena);

     MyStr(StrToReal(Skl^.Dat.Input.O_Zena),CZena,CMantissa,Skl^.Dat.Input.O_Zena);
     DelSpace(Skl^.Dat.Input.O_Zena);

     MyStr(StrToReal(Skl^.Dat.Input.Spec_Zena),CZena,CMantissa,Skl^.Dat.Input.Spec_Zena);
     DelSpace(Skl^.Dat.Input.Spec_Zena);


     Skl^.Dat.Input.NMAkeKod:=IntToStr(StrToInt(Skl^.Dat.Input.NMAkeKod),CArtikul);
     RFormatZerro(Skl^.Dat.Input.NMAkeKod,CArtikul);
     Skl^.Dat.BazKod:=IntToStr(FilePos(SklFile)-1,3);
     RFormatZerro(Skl^.Dat.BazKod,3);
     Skl^.Dat.BazKod:=RazdelElement.Kod+Skl^.Dat.BazKod;
    Skl^.Dat.Input.NGTD    :=IntToStr(StrToInt(Skl^.Dat.Input.NGTD),CArtikul);
       RFormatZerro(Skl^.Dat.Input.NGTD,CArtikul);
    Skl^.Dat.Input.Marka   :=IntToStr(StrToInt(Skl^.Dat.Input.Marka),CArtikul);
       RFormatZerro(Skl^.Dat.Input.Marka,CArtikul);
     Skl^.Dat.Input.SpecMarka :=IntToStr(StrToInt(Skl^.Dat.Input.SpecMarka),CArtikul);
       RFormatZerro(Skl^.Dat.Input.SpecMarka,CArtikul);
        Skl^.Dat.Input.Expert :=IntToStr(StrToInt(Skl^.Dat.Input.Expert),CArtikul);
       RFormatZerro(Skl^.Dat.Input.Expert,CArtikul);
    Skl^.Dat.Input.NSertif :=IntToStr(StrToInt(Skl^.Dat.Input.NSertif),CArtikul);
       RFormatZerro(Skl^.Dat.Input.NSertif,CArtikul);

     Skl^.Dat.Date:=DateStringToDAte(DateMask,FDate);
     Skl^.Dat.Time:=CurrentTime;
     MyStr(StrToReal(Skl^.Dat.Input.Zakupka),CZenaZ,CMantissaZ,Skl^.Dat.Input.Zakupka);
     DelSpace(Skl^.Dat.Input.Zakupka);
     MyStr(StrToReal(Skl^.Dat.Input.Zakupka2),CZenaZ,CMantissaZ,Skl^.Dat.Input.Zakupka2);
     DelSpace(Skl^.Dat.Input.Zakupka2);
     MyStr(StrToReal(Skl^.Dat.Input.LastZakupka),CZenaZ,CMantissaZ,Skl^.Dat.Input.LastZakupka);
     DelSpace(Skl^.Dat.Input.LastZakupka);
     Skl^.Dat.Input.Caption:=CurrentPassword;
     If Skl^.Dat.Input.RegionMarka>=1 Then Skl^.Dat.Input.RegionMarka:=1
     Else Skl^.Dat.Input.RegionMarka:=0;
     End;

     {
     IndexNew^.Dat.Name :=GetIdField(FName,Skl^.Dat.BazKod);
     IndexNew^.Dat.Name2:=GetIdField(FName2,Skl^.Dat.BazKod);
     IndexNew^.Dat.EnableSklads:=StrToInt(GetIdField(FEnableSklads,Skl^.DAt.BAzKod));
     }

     If Skl^.Dat.Employ Then
     Begin
     New(BE,Init);
     GetBazElement(Skl^.Dat.BazKod,BE^.Dat);

     If Be^.Dat.Main=1 Then
      Begin
       SArt:=Be^.Dat.FantomKod;
       GetBazElement(SArt,BE^.Dat);
       {восстанавливаем базовый код}
       Be^.Dat.BazKod:=Skl^.Dat.BazKod;
       {восстанавливаем ссылочный код}
       Be^.Dat.FantomKod:=SArt;
       Be^.Dat.Main:=1;
      End;
     IndexNew^.Dat.Name :=Be^.Dat.Name;
     IndexNew^.Dat.Name2:=Be^.Dat.Name2;
     IndexNew^.Dat.Main:=Be^.Dat.Main;
     IndexNew^.Dat.FantomKod:=StrToInt(Be^.Dat.FantomKod);
     IndexNew^.Dat.EnableSklads:=Be^.Dat.EnableSklads;
     IndexNew^.Dat.NGroupKod:=StrToInt(Be^.Dat.NGroupKod);
     IndexNew^.Dat.FirmaPostKod:=StrToInt(Be^.Dat.FirmaPostKod);
     IndexNew^.Dat.NMarkaKod:=StrToInt(Skl^.Dat.Input.Marka);
     IndexNew^.Dat.NSpecMarkaKod:=StrToInt(Skl^.Dat.Input.SpecMarka);
     IndexNew^.Dat.NExpertKod:=StrToInt(Skl^.Dat.Input.Expert);
     IndexNew^.Dat.NGTDKod:=StrToInt(Skl^.Dat.Input.NGTD);
     Dispose(BE,Done);
     End
      Else
       Begin
     IndexNew^.Dat.Name :='';
     IndexNew^.Dat.Name2:='';
     IndexNew^.Dat.Main:=0;
     IndexNew^.Dat.FantomKod:=IndexNew^.Dat.BazKod;
     IndexNew^.Dat.EnableSklads:=0;
     IndexNew^.Dat.NGroupKod:=0;
     IndexNew^.Dat.FirmaPostKod:=0;
     IndexNew^.Dat.NMarkaKod:=0;
     IndexNew^.Dat.NSpecMarkaKod:=0;
     IndexNew^.Dat.NExpertKod:=0;
     IndexNew^.Dat.NGTDKod:=0;
       End;
(*
     New(BE,Init);
     GetBazElement(Skl^.Dat.BazKod,BE^.Dat);
     IndexNew^.Dat.Name :=Be^.Dat.Name;
     IndexNew^.Dat.Name2:=Be^.Dat.Name2;
     IndexNew^.Dat.Main:=Be^.Dat.Main;
     IndexNew^.Dat.FantomKod:=StrToInt(Be^.Dat.FantomKod);
     IndexNew^.Dat.EnableSklads:=Be^.Dat.EnableSklads;
     IndexNew^.Dat.NGroupKod:=StrToInt(Be^.Dat.NGroupKod);
     Dispose(BE,Done);
*)

     IndexNew^.Dat.Virabotano :=DateStringToDate(DateMask,Skl^.Dat.input.Virabotano);
     IndexNew^.Dat.Employ :=Skl^.DAt.Employ;
     IndexNew^.Dat.NSertif :=StrToInt(Skl^.DAt.Input.NSertif);
     For j:=1 To CDivision Do IndexNew^.Dat.Division[j]:=StrToInt(Skl^.Dat.Input.Division[j]);
     For j:=1 To CDivision Do IndexNew^.Dat.DivisionR[j]:=StrToInt(Skl^.Dat.Input.DivisionR[j]);
     IndexNew^.Dat.R_Zena  :=StrToreal(Skl^.Dat.Input.R_Zena);
     IndexNew^.Dat.Zakupka :=StrToreal(Skl^.Dat.Input.Zakupka);
     IndexNew^.Dat.Zakupka2:=StrToreal(Skl^.Dat.Input.Zakupka2);
     IndexNew^.Dat.AkzisSbor:=StrToreal(Skl^.Dat.Input.AkzisSbor);
     IndexNew^.Dat.RegionMarka:=Skl^.Dat.Input.RegionMarka;
     IndexNew^.Dat.BazKod:=StrToInt(Skl^.Dat.BazKod);
     IndexNew^.Dat.Kol:=StrToInt(Skl^.Dat.Input.Kol);
     IndexNew^.Dat.StrihKod:=Skl^.Dat.Input.StrihKod;
     IndexNew^.Dat.NMakeKod:=StrToInt(Skl^.Dat.Input.NMakeKod);


     ws:=RazdelElement.Kod+ws;

     Seek(SklFile,FilePos(SklFile)-1);
     Skl^.Dat.BazKod:=ws;
     Write(SklFile,Skl^.Dat);

     Write(IndexFileNew,IndexNew^.Dat);

     Repeat
      NetCall.UnLock(SklFile,(FilePos(SklFile)-1)*SizeOf(SkladType),SizeOf(SkladType));
     Until (DosError=0);

     Inc(ch);
     End;

   Dispose(Skl,Done);
   Close(SklFile);
   Close(IndexFileNew);
   Dispose(IndexNew,Done);
   NoInfoMsg;
End;






Procedure CreatIDXAuto;
VAr sklFile : File Of SkladType;
    skl : pSkladType;
    RazdelFile : File Of RazdelType;
    RazdelElement : RazdelType;
    Be : PBazType;
    SArt : ArtikulStr;

    IndexFileNew : File Of SkladTypeNew;
    Indexnew : PSkladTypenew;

    F : Boolean;
    c,k1 : Word;
    ch : LongInt;
    ws : String;
    k,All : LongInt;
    j : Word;
Begin
c:=IOResult;
Assign(RazdelFile,Path^.Dat.ToRazdel+'Razdel.db');
Reset(RazdelFile);
c:=IOResult;
If c<>0 Then
 Begin
  MessageBox(^M+#3'Ошибка доступа к файлу разделов!',Nil,mfError+mfCancelButton);
  Exit;
 End;

While Not(Eof(RazdelFile)) Do
 Begin
  Read(RazdelFile,RazdelElement);
  If RazdelElement.Employ Then
  Begin
   DInfoMsgShkala('Идет обновление индексов раздела '+RazdelElement.Kod+'...',
   1,EmployRazdel,StrToInt(RazdelElement.Kod)+1);

   {добавлена синхронизация}
   FixSize(RazdelElement.Kod);{<--снижает производительность при загрузке просто жопа}

   Assign(SklFile,Path^.Dat.ToSklad+RazdelElement.Kod+'.db');
   c:=IOResult;
   Reset(SklFile);
   c:=IOResult;
If c<>0 Then
 Begin
  Close(RazdelFile);
  NoInfo;
  MessageBox(^M+#3'Ошибка доступа к файлу '+Path^.Dat.ToSklad+RazdelElement.Kod+'.db',Nil,mfError+mfCancelButton);
  Exit;
 End;


c:=IOResult;
Assign(IndexFileNew,Path^.Dat.ToIndex+RazdelElement.Kod+'.kdx');
Rewrite(IndexFileNew);
c:=IOResult;
If c<>0 Then
 Begin
  Close(RazdelFile);
  Close(SklFile);
  NoInfo;
  MessageBox(^M+#3'Ошибка создания файла индексов '+Path^.Dat.ToIndex+RazdelElement.Kod+'.kdx'+'!',Nil,
  mfError+mfCancelButton);
  Exit;
 End;

   New(Skl,Init);
   New(IndexNew,Init);
   ch:=0;
   While Not(Eof(sklFile)) Do
    Begin

     Repeat
      Pause(1);
     Until NetCAll.Lock(SklFile,FilePos(SklFile)*SizeOf(SkladType),SizeOf(SkladType));

     Read(SklFile,Skl^.Dat);
     Str(ch:3,ws);
     While Pos(' ',ws)>0 Do Ws[Pos(' ',ws)]:='0';

     If Skl^.Dat.Employ Then
     With Skl^.Dat.Input Do
     Begin
      All:=0;
      For k:=1 To CDivision Do
        Begin
           Str(StrToInt(Division[k]):CKol,Division[k]);
           DelSpace(Division[k]);
           All:=All+StrToInt(Division[k]);
        End;
     Str(All:CKol,Skl^.Dat.Input.Kol);
     DelSpace(Skl^.Dat.Input.Kol);

      All:=0;
      For k:=1 To CDivision Do
        Begin
           Str(StrToInt(DivisionR[k]):CKol,DivisionR[k]);
           DelSpace(DivisionR[k]);
           All:=All+StrToInt(DivisionR[k]);
        End;
     Str(All:CKol,Skl^.Dat.Input.KolR);
     DelSpace(Skl^.Dat.Input.KolR);


     MyStr(StrToReal(Skl^.Dat.Input.R_Zena),CZena,CMantissa,Skl^.Dat.Input.R_Zena);
     DelSpace(Skl^.Dat.Input.R_Zena);

     MyStr(StrToReal(Skl^.Dat.Input.O_Zena),CZena,CMantissa,Skl^.Dat.Input.O_Zena);
     DelSpace(Skl^.Dat.Input.O_Zena);

     MyStr(StrToReal(Skl^.Dat.Input.Spec_Zena),CZena,CMantissa,Skl^.Dat.Input.Spec_Zena);
     DelSpace(Skl^.Dat.Input.Spec_Zena);


     Skl^.Dat.Input.NMAkeKod:=IntToStr(StrToInt(Skl^.Dat.Input.NMAkeKod),CArtikul);
     RFormatZerro(Skl^.Dat.Input.NMAkeKod,CArtikul);
     Skl^.Dat.BazKod:=IntToStr(FilePos(SklFile)-1,3);
     RFormatZerro(Skl^.Dat.BazKod,3);
     Skl^.Dat.BazKod:=RazdelElement.Kod+Skl^.Dat.BazKod;
    Skl^.Dat.Input.NGTD    :=IntToStr(StrToInt(Skl^.Dat.Input.NGTD),CArtikul);
       RFormatZerro(Skl^.Dat.Input.NGTD,CArtikul);
    Skl^.Dat.Input.Marka   :=IntToStr(StrToInt(Skl^.Dat.Input.Marka),CArtikul);
       RFormatZerro(Skl^.Dat.Input.Marka,CArtikul);
     Skl^.Dat.Input.SpecMarka :=IntToStr(StrToInt(Skl^.Dat.Input.SpecMarka),CArtikul);
       RFormatZerro(Skl^.Dat.Input.SpecMarka,CArtikul);
        Skl^.Dat.Input.Expert :=IntToStr(StrToInt(Skl^.Dat.Input.Expert),CArtikul);
       RFormatZerro(Skl^.Dat.Input.Expert,CArtikul);
    Skl^.Dat.Input.NSertif :=IntToStr(StrToInt(Skl^.Dat.Input.NSertif),CArtikul);
       RFormatZerro(Skl^.Dat.Input.NSertif,CArtikul);

     Skl^.Dat.Date:=DateStringToDAte(DateMask,FDate);
     Skl^.Dat.Time:=CurrentTime;
     MyStr(StrToReal(Skl^.Dat.Input.Zakupka),CZenaZ,CMantissaZ,Skl^.Dat.Input.Zakupka);
     DelSpace(Skl^.Dat.Input.Zakupka);
     MyStr(StrToReal(Skl^.Dat.Input.Zakupka2),CZenaZ,CMantissaZ,Skl^.Dat.Input.Zakupka2);
     DelSpace(Skl^.Dat.Input.Zakupka2);
     MyStr(StrToReal(Skl^.Dat.Input.LastZakupka),CZenaZ,CMantissaZ,Skl^.Dat.Input.LastZakupka);
     DelSpace(Skl^.Dat.Input.LastZakupka);
     Skl^.Dat.Input.Caption:=CurrentPassword;
     If Skl^.Dat.Input.RegionMarka>=1 Then Skl^.Dat.Input.RegionMarka:=1
     Else Skl^.Dat.Input.RegionMarka:=0;
     End;

     {
     IndexNew^.Dat.Name :=GetIdField(FName,Skl^.Dat.BazKod);
     IndexNew^.Dat.Name2:=GetIdField(FName2,Skl^.Dat.BazKod);
     IndexNew^.Dat.EnableSklads:=StrToInt(GetIdField(FEnableSklads,Skl^.DAt.BAzKod));
     }

     If Skl^.Dat.Employ Then
     Begin
     New(BE,Init);
     GetBazElement(Skl^.Dat.BazKod,BE^.Dat);

     If Be^.Dat.Main=1 Then
      Begin
       SArt:=Be^.Dat.FantomKod;
       GetBazElement(SArt,BE^.Dat);
       {восстанавливаем базовый код}
       Be^.Dat.BazKod:=Skl^.Dat.BazKod;
       {восстанавливаем ссылочный код}
       Be^.Dat.FantomKod:=SArt;
       Be^.Dat.Main:=1;
      End;
     IndexNew^.Dat.Name :=Be^.Dat.Name;
     IndexNew^.Dat.Name2:=Be^.Dat.Name2;
     IndexNew^.Dat.Main:=Be^.Dat.Main;
     IndexNew^.Dat.FantomKod:=StrToInt(Be^.Dat.FantomKod);
     IndexNew^.Dat.EnableSklads:=Be^.Dat.EnableSklads;
     IndexNew^.Dat.NGroupKod:=StrToInt(Be^.Dat.NGroupKod);
     IndexNew^.Dat.FirmaPostKod:=StrToInt(Be^.Dat.FirmaPostKod);
     IndexNew^.Dat.NMarkaKod:=StrToInt(Skl^.Dat.Input.Marka);
     IndexNew^.Dat.NSpecMarkaKod:=StrToInt(Skl^.Dat.Input.SpecMarka);
     IndexNew^.Dat.NExpertKod:=StrToInt(Skl^.Dat.Input.Expert);
     IndexNew^.Dat.NGTDKod:=StrToInt(Skl^.Dat.Input.NGTD);
     Dispose(BE,Done);
     End
      Else
       Begin
     IndexNew^.Dat.Name :='';
     IndexNew^.Dat.Name2:='';
     IndexNew^.Dat.Main:=0;
     IndexNew^.Dat.FantomKod:=IndexNew^.Dat.BazKod;
     IndexNew^.Dat.EnableSklads:=0;
     IndexNew^.Dat.NGroupKod:=0;
     IndexNew^.Dat.FirmaPostKod:=0;
     IndexNew^.Dat.NMarkaKod:=0;
     IndexNew^.Dat.NSpecMarkaKod:=0;
     IndexNew^.Dat.NExpertKod:=0;
     IndexNew^.Dat.NGTDKod:=0;
       End;
(*
     New(BE,Init);
     GetBazElement(Skl^.Dat.BazKod,BE^.Dat);
     IndexNew^.Dat.Name :=Be^.Dat.Name;
     IndexNew^.Dat.Name2:=Be^.Dat.Name2;
     IndexNew^.Dat.Main:=Be^.Dat.Main;
     IndexNew^.Dat.FantomKod:=StrToInt(Be^.Dat.FantomKod);
     IndexNew^.Dat.EnableSklads:=Be^.Dat.EnableSklads;
     IndexNew^.Dat.NGroupKod:=StrToInt(Be^.Dat.NGroupKod);
     Dispose(BE,Done);
*)

     IndexNew^.Dat.Virabotano :=DateStringToDate(DateMask,Skl^.Dat.input.Virabotano);
     IndexNew^.Dat.Employ :=Skl^.DAt.Employ;
     IndexNew^.Dat.NSertif :=StrToInt(Skl^.DAt.Input.NSertif);
     For j:=1 To CDivision Do IndexNew^.Dat.Division[j]:=StrToInt(Skl^.Dat.Input.Division[j]);
     For j:=1 To CDivision Do IndexNew^.Dat.DivisionR[j]:=StrToInt(Skl^.Dat.Input.DivisionR[j]);
     IndexNew^.Dat.R_Zena  :=StrToreal(Skl^.Dat.Input.R_Zena);
     IndexNew^.Dat.Zakupka :=StrToreal(Skl^.Dat.Input.Zakupka);
     IndexNew^.Dat.Zakupka2:=StrToreal(Skl^.Dat.Input.Zakupka2);
     IndexNew^.Dat.AkzisSbor:=StrToreal(Skl^.Dat.Input.AkzisSbor);
     IndexNew^.Dat.RegionMarka:=Skl^.Dat.Input.RegionMarka;
     IndexNew^.Dat.BazKod:=StrToInt(Skl^.Dat.BazKod);
     IndexNew^.Dat.Kol:=StrToInt(Skl^.Dat.Input.Kol);
     IndexNew^.Dat.StrihKod:=Skl^.Dat.Input.StrihKod;
     IndexNew^.Dat.NMakeKod:=StrToInt(Skl^.Dat.Input.NMakeKod);


     ws:=RazdelElement.Kod+ws;

     Seek(SklFile,FilePos(SklFile)-1);
     Skl^.Dat.BazKod:=ws;
     Write(SklFile,Skl^.Dat);

     Write(IndexFileNew,IndexNew^.Dat);

     Repeat
      NetCall.UnLock(SklFile,(FilePos(SklFile)-1)*SizeOf(SkladType),SizeOf(SkladType));
     Until (DosError=0);

     Inc(ch);
     End;

   Dispose(Skl,Done);
   Close(SklFile);
   Close(IndexFileNew);
   Dispose(IndexNew,Done);
   End;
 End;
NoInfoMsg;
Close(RazdelFile);
End;


{1.просматриваем максимальные размерности по разделам
 2.расширяем  *.db до потребного количества
 5.начинаем сливать новые *.db в старые
   a)если позиции просто не было тогда тупо добавляем ее с
     р/ценой и з/ценой с резервного склада
   б)если позиция есть тогда смотрим
          1)количество добавляемое >0 тогда проверяем цену
                  если цена разная то добавляем товар в переоценку,
            сливаем вошедшее количество в 4,5,6 отделение
            и добавляем в db файл прочие вошедшие аттрибуты
          2)даже если количество на складе 0 а цена разная
            добавляем товар в переоценку

          и в случае a) и в случае б) закупочную цену оставляем складскую
}

Function CreatEkzemplarPrz(VAr PereozenkaElement:PPereozenkaType):Boolean;
Var PereozenkaFile : File Of PereozenkaType;
    i : Word;
Begin
    CreatEkzemplarPrz:=FAlse;
    Assign(PereozenkaFile,Path^.Dat.ToCorrect+FDAte+'.prz');
    i:=IOResult;
    Reset(Pereozenkafile);
    i:=IOResult;
    If I <> 0 Then
    Begin
{  If MessageBox('Файл переоценки '+FDate+'.prz не найден!'^M+
        'Создаю файл? Если вы раньше что-либо переоценили позовите программиста!'+
           +' Код:'+IntToStr(i,3),nil,
           mfConfirmation + mfOkCancel)=cmOk  Then}
        Begin
         If Not(CreatToDayF(DocPereozen,FDate)) Then
            Begin
             Exit;
            End;
         i:=IOResult;
         Reset(PereozenkaFile);
         i:=IOResult;
        End
{
    Else
        Begin
          Exit;
        End;
}
     End;{I<>0}
  PereozenkaElement^.Dat.Document:=InttoStr(FileSize(PereozenkaFile)+1,CDocNumer);
  PereozenkaElement^.Dat.DateC:=FDAte;
  PereozenkaElement^.Dat.TimeC:=Times;
  System.Close(PereozenkaFile);
  CreatEkzemplarPrz:=True;
End;


Function CopyNewDB:Boolean;
VAr fid,fidn : SkladFileType;
    fr : File Of RazdelType;
    c,i,j,shPrz,Count : Word;
    l,k : LongInt;
    st : AllStr;
    skl,SklN : PSkladType;
    RazdelElement : RAzdelType;
    Prz : PPereozenkaType;
    Add : Boolean;
Begin
CopyNewDB:=False;
Assign(fr,Path^.Dat.ToRAzdel+'razdel.db');
c:=IOResult;
Reset(fr);
c:=IOResult;
If c<>0 Then
 Begin
  MessageBox(^M+#3'Ошибка доступа к файлу '+Path^.Dat.ToRAzdel+'razdel.db'+' при синхронизации базы наличия!'+
  ' Код:'+IntToStr(c,ClitrMAntissa),Nil,mfError+mfCancelButton);
  AddProtocol('Ошибка доступа к файлу '+Path^.Dat.ToRAzdel+'razdel.db'+' при синхронизации базы наличия','','');
  Exit;
 End;

New(Prz,Init);
If Not CreatEkzemplarPrz(Prz) Then
 Begin
  Exit;
 End;
shPrz:=1;
While Not(Eof(fr)) Do
Begin
Read(fr,RAzdelElement);
If RAzdelElement.Employ Then
Begin
st:=RAzdelElement.Kod;
RFormatZerro(st,CMAntissa);
Assign(fid,Path^.Dat.ToTemp+'Temp\Main\'+st+'.db');
l:=IOResult;
Reset(fid);
l:=IOResult;
If l=0 Then
Begin
Assign(fidN,PAth^.Dat.ToSklad+st+'.db');
l:=IOResult;
Reset(fidN);
l:=IOResult;
If l=0 Then
 Begin
  DInfoMsgShkala('Выполняется синхронизация базы наличия. Раздел '+
  RazdelElement.Kod+' ... ',1,EmployRazdel,StrToInt(RazdelElement.Kod)+1);
  While Not(Eof(Fid)) Do
   Begin
    New(Skl,Init);
    New(SklN,Init);
    ReadSklad(fid,Skl^.DAt);
    Add:=FAlse;

    If Eof(fidN) Then Add:=True
     Else ReadSklad(fidn,SklN^.DAt);

    If Add Then{если добавляем новую позицию}
     Begin{}
      SklN^.DAt:=Skl^.DAt;
      SklN^.DAt.Date:=DateStringToDAte(DAteMAsk,FDate);
      SklN^.DAt.Time:=CurrentTime;
      SklN^.DAt.Locked:=False;
     End
     Else
      Begin{если позиция в файле есть физически}
       {позиционируемся на шаг назад}
       Seek(Fidn,FilePos(FIdN)-1);
       If Not SklN^.DAt.Employ Then{просто слепо переписываем эту позицию}
        Begin
         SklN^.DAt:=Skl^.DAt;
         SklN^.DAt.Date:=DateStringToDAte(DAteMAsk,FDate);
         SklN^.DAt.Time:=CurrentTime;
         SklN^.DAt.Locked:=False;
        End
        Else
          Begin{если позиция используется}
           If(StrToReal(Skl^.Dat.Input.R_Zena)<>StrToReal(SklN^.Dat.Input.R_Zena))Or
             (StrToReal(Skl^.Dat.Input.O_Zena)<>StrToReal(SklN^.Dat.Input.O_Zena)) Then
             Begin{если необходимо изменять цену}
              Prz^.Dat.Element[shPrz].BazKod:=SklN^.Dat.BazKod;
              Prz^.Dat.Element[shPrz].Kol:=SklN^.Dat.Input.Kol;
              Prz^.Dat.Element[shPrz].Bak_R_Zena:=SklN^.Dat.Input.R_Zena;
              Prz^.Dat.Element[shPrz].Bak_O_Zena:=SklN^.Dat.Input.O_Zena;
              Prz^.Dat.Element[shPrz].New_R_Zena:=Skl^.Dat.Input.R_Zena;;
              Prz^.Dat.Element[shPrz].New_O_Zena:=Skl^.Dat.Input.O_Zena;;
              Prz^.Dat.Caption := CurrentPassword;

              MyStr(StrToInt(SklN^.Dat.Input.Kol)*StrToReal(SklN^.Dat.Input.R_Zena)+
              StrToReal(Prz^.Dat.Itogo_Bak_R_Zena),CIZena,CMantissa,Prz^.Dat.Itogo_Bak_R_Zena);
              DelSpace(Prz^.Dat.Itogo_Bak_R_Zena);

              MyStr(StrToInt(SklN^.Dat.Input.Kol)*StrToReal(SklN^.Dat.Input.O_Zena)+
              StrToReal(Prz^.Dat.Itogo_Bak_O_Zena),CIZena,CMantissa,Prz^.Dat.Itogo_Bak_O_Zena);
              DelSpace(Prz^.Dat.Itogo_Bak_O_Zena);
                                                  {умножаем на новую входящую цену}
              MyStr(StrToInt(SklN^.Dat.Input.Kol)*StrToReal(Skl^.Dat.Input.R_Zena)+
              StrToReal(Prz^.Dat.Itogo_New_R_Zena),CIZena,CMantissa,Prz^.Dat.Itogo_New_R_Zena);
              DelSpace(Prz^.Dat.Itogo_New_R_Zena);
                                                  {умножаем на новую входящую цену}
              MyStr(StrToInt(SklN^.Dat.Input.Kol)*StrToReal(Skl^.Dat.Input.O_Zena)+
              StrToReal(Prz^.Dat.Itogo_New_O_Zena),CIZena,CMantissa,Prz^.Dat.Itogo_New_O_Zena);
              DelSpace(Prz^.Dat.Itogo_New_O_Zena);
              Inc(Prz^.Dat.Amount);
              Inc(shPrz);
              Prz^.Dat.Vid:=0;

              MyStr(StrToReal(Prz^.Dat.Itogo_New_R_Zena)-StrToReal(Prz^.Dat.Itogo_Bak_R_Zena),
              CIZena,CMantissa,Prz^.Dat.Delta_RZ);
              DelSpace(Prz^.Dat.Delta_RZ);

              MyStr(StrToReal(Prz^.Dat.Itogo_New_O_Zena)-StrToReal(Prz^.Dat.Itogo_Bak_O_Zena),
              CIZena,CMantissa,Prz^.Dat.Delta_OZ);
              DelSpace(Prz^.Dat.Delta_OZ);
             End;
           {1.количество по отделениям}
           With SklN^.DAt.Input Do
           Begin
             Division[5]:=Skl^.DAt.Input.Division[5];
             DelSpace(Division[5]);
             Division[6]:=Skl^.DAt.Input.Division[6];
             DelSpace(Division[6]);
             {выключено 28/01/2005 по просьбе гончарова
             для того чтобы можно было использовать 8 отделение для нужд склада
             (идентификации товара возващенного со спара)
             Division[7]:=Skl^.DAt.Input.Division[7];
             DelSpace(Division[7]);
             Division[8]:=Skl^.DAt.Input.Division[8];
             DelSpace(Division[8]);
             }
           End;
           {2.пересчитываем количество Kol}

           {для ебаного копаева иначе не прогружалась закупка}
           If StrToInt(SklN^.Dat.Input.Kol)=0 Then
      Begin
       SklN^.Dat.Input.Zakupka:=Skl^.Dat.Input.Zakupka;
       SklN^.Dat.Input.Zakupka2:=Skl^.Dat.Input.Zakupka2;
            End;

           SklN^.DAt.Input.Kol[0]:=#0;
           For j:=1 To CDivision Do
            Begin
             Str(STrToInt(SklN^.Dat.Input.Kol)+StrToInt(SklN^.Dat.Input.Division[j])
                   :CKol,SklN^.Dat.Input.Kol);
            End;
            DelSpace(SklN^.Dat.Input.Kol);

           {3.новую р/цену с/цену о/цену}
            MyStr(StrToReal(Skl^.Dat.Input.R_Zena),CZena,CMantissa,SklN^.Dat.Input.R_Zena);
            DelSpace(SklN^.Dat.Input.R_Zena);
            MyStr(StrToReal(Skl^.Dat.Input.O_Zena),CZena,CMantissa,SklN^.Dat.Input.O_Zena);
            DelSpace(SklN^.Dat.Input.O_Zena);
            MyStr(StrToReal(Skl^.Dat.Input.Spec_Zena),CZena,CMantissa,SklN^.Dat.Input.Spec_Zena);
            DelSpace(SklN^.Dat.Input.Spec_Zena);

           {4.штрихкод}
           {5.дате позлива и срок реализации}
            With SklN^.DAt.Input Do
            Begin
               USD     :=Skl^.Dat.Input.USD;
               GRZena  :=Skl^.Dat.Input.GRZena;
               Proz    :=Skl^.Dat.Input.Proz;
               NMakeKod:=Skl^.Dat.Input.NMAkeKod;
               NGTD    :=Skl^.Dat.Input.NGTD;
               Marka   :=Skl^.Dat.Input.Marka;
               SpecMarka:=Skl^.Dat.Input.SpecMarka;
               Expert  :=Skl^.Dat.Input.Expert;
               {NGroupKod:=Skl^.Dat.Input.NGroupKod;}
               StrihKod :=Skl^.Dat.Input.StrihKod;
               Virabotano:=Skl^.Dat.Input.Virabotano;
               Godnost :=Skl^.Dat.Input.Godnost;
               NSertif :=Skl^.Dat.Input.NSertif;
               RegionMarka:=Skl^.Dat.Input.RegionMarka;
               AkzisSbor:=Skl^.Dat.Input.AkzisSbor;
               ZenaMarki:=Skl^.Dat.Input.ZenaMarki;
            End;
            SklN^.DAt.MakeKod     :=Skl^.DAt.MakeKod;
            SklN^.DAt.MakeVid     :=Skl^.DAt.MakeVid;
            SklN^.DAt.EnableDebit :=Skl^.DAt.EnableDebit;
            SklN^.DAt.Employ      :=True;
            SklN^.DAt.Date:=DateStringToDAte(DAteMAsk,FDate);
            SklN^.DAt.Time:=CurrentTime;
            SklN^.DAt.Locked      :=False;
          End;
      End;


    l:=IOResult;
    Write(fidn,SklN^.Dat);
    l:=IOResult;
    {если в переоценке кончились позиции тогда сохраняем текущую и создаем новую}
    If Prz^.Dat.Amount=CMAx Then
     Begin
      LockAndWritePereozenkaNoInfo(Prz);
      Dispose(Prz,Done);
      New(Prz,Init);
      CreatEkzemplarPrz(Prz);
      shPrz:=1;
     End;


    Dispose(Skl,Done);
    Dispose(SklN,Done);
   End;{While}
   l:=IOResult;
   Close(fidn);
   l:=IOResult;
 End
 Else
  Begin

    If Prz^.Dat.Amount>0 Then
     Begin
      LockAndWritePereozenkaNoInfo(Prz);
      Dispose(Prz,Done);
      New(Prz,Init);
      shPrz:=1;
     End;
   Dispose(Prz,Done);

   c:=IOResult;
   Close(fr);

   NoInfoMsg;
   MessageBox(^M+#3'Ошибка создания файла '+Path^.Dat.ToSklad+st+'.db'+' при синхронизации базы наличия!'+
   ' Код:'+IntToStr(c,ClitrMAntissa),Nil,mfError+mfCancelButton);
   AddProtocol('Ошибка создания файла '+Path^.Dat.ToSklad+st+'.db'+' при синхронизации базы наличия!','','');
   Exit;
  End;

  l:=IOResult;
  close(fid);
End
 Else
  Begin

    If Prz^.Dat.Amount>0 Then
     Begin
      LockAndWritePereozenkaNoInfo(Prz);
      Dispose(Prz,Done);
      New(Prz,Init);
      shPrz:=1;
     End;
   Dispose(Prz,Done);

   c:=IOResult;
   Close(fr);

   NoInfoMsg;
   MessageBox(^M+#3'Ошибка открытия файла '+Path^.Dat.ToTemp+'\Temp\Main\'+st+'.db'+' при синхронизации базы наличия!'+
   ' Код:'+IntToStr(c,ClitrMAntissa),Nil,mfError+mfCancelButton);
   AddProtocol('Ошибка открытия файла '+Path^.Dat.ToTemp+'\Temp\Main\'+st+'.db'+' при синхронизации базы наличия!','','');
   Exit;
  End;

End;{RazdelElement.Employ}
End;{While Razdel}

    If Prz^.Dat.Amount>0 Then
     Begin
      LockAndWritePereozenkaNoInfo(Prz);
      Dispose(Prz,Done);
      New(Prz,Init);
      shPrz:=1;
     End;

Dispose(Prz,Done);

NoInfoMsg;
c:=IOResult;
Close(fr);
c:=IOResult;
CopyNewDB:=True;
End;


Function DeleteRemoteDB:Boolean;
VAr fid: SkladFileType;
    fr : File Of RazdelType;
    c,i,j,shPrz,Count: Word;
    l,k: LongInt;
    st : AllStr;
    skl: PSkladType;
    RazdelElement: RAzdelType;
Begin
DeleteRemoteDB:=False;
Assign(fr,Path^.Dat.ToRAzdel+'razdel.db');
c:=IOResult;
Reset(fr);
c:=IOResult;
If c<>0 Then
 Begin
  MessageBox(^M+#3'Ошибка доступа к файлу '+Path^.Dat.ToRAzdel+'razdel.db'+' при синхронизации базы наличия!'+
  ' Код:'+IntToStr(c,ClitrMAntissa),Nil,mfError+mfCancelButton);
  AddProtocol('Ошибка доступа к файлу '+Path^.Dat.ToRAzdel+'razdel.db'+' при синхронизации базы наличия','','');
  Exit;
 End;

While Not(Eof(fr)) Do
Begin
Read(fr,RAzdelElement);
If RAzdelElement.Employ Then
Begin
st:=RAzdelElement.Kod;
RFormatZerro(st,CMAntissa);
Assign(fid,PAth^.Dat.ToSklad+st+'.db');
l:=IOResult;
Reset(fid);
l:=IOResult;
If l=0 Then
 Begin
  DInfoMsgShkala('Выполняется выгрузка базы наличия удаленных складов. Раздел '+
  RazdelElement.Kod+' ... ',1,EmployRazdel,StrToInt(RazdelElement.Kod)+1);
  While Not(Eof(Fid)) Do
   Begin
    New(Skl,Init);
    ReadSklad(fid,Skl^.DAt);
     With Skl^.DAt.Input Do
      Begin
       Division[5]:='0';
       Division[6]:='0';
      {выключено 28/01/2005 по просьбе гончарова
       для того чтобы можно было использовать 8 отделение для нужд склада
      (идентификации товара возващенного со спара)
       Division[7]:='0';
       Division[8]:='0';
       }
       Kol[0]:=#0;
       For c:=1 To CDivision Do
           Begin
         Str(StrToInt(Kol)+StrToInt(Division[c]):CKol,Kol);
           End;
       DelSpace(Kol);
      End;

    l:=IOResult;
    Seek(fid,FilePos(Fid)-1);
    Write(fid,Skl^.Dat);
    l:=IOResult;
    {если в переоценке кончились позиции тогда сохраняем текущую и создаем новую}

    Dispose(Skl,Done);
   End;{While}
   l:=IOResult;
   Close(fid);
   l:=IOResult;
 End
 Else
  Begin
   NoInfoMsg;
   MessageBox(^M+#3'Ошибка открытия файла '+Path^.Dat.ToSklad+st+'.db'+' при выгрузке базы наличия удаленных складов!'+
   ' Код:'+IntToStr(c,ClitrMAntissa),Nil,mfError+mfCancelButton);
   AddProtocol('Ошибка открытия файла '+Path^.Dat.ToSklad+st+'.db'+' при выгрузке базы наличия удаленных складов!','','');
   Exit;
  End;

End;{RazdelElement.Employ}
End;{While Razdel}

NoInfoMsg;
c:=IOResult;
Close(fr);
c:=IOResult;
DeleteRemoteDB:=True;
End;






Function UnPackRemoteDB:boolean;
var s:string;
     Result : LongInt;
     Txt : Text;
     FSkl : SkladFileType;
     Skl : PSkladType;
     fr : RAzdelFileType;
     c : Word;
     RAzdelElement : RAzdelType;
     st : AllStr;
     l : LongInt;
     Summa,COntrolSumma : AllStr;

Begin
  UnPackRemoteDB:=FAlse;
  DInfoMsg('Распаковываю базу удаленных складов...',False);
  DoneSysError;
  DoneEvents;
  Application^.HideCursor;
  DoneDosMem;
  SWAPVECTORS;

  s:=Path^.Dat.ToUtils+'rar x -y'+{-av-}' -inul -w'+Path^.Dat.ToTemp+' '+
  Path^.Dat.ToArchiv+Path^.Dat.PriceName{'remote.exe'}+' '+Path^.Dat.ToTemp+NullStr^;

  exec (GetEnv('Comspec'),' /c '+'rd /S /Q '+Path^.Dat.ToTemp+'Temp');
  exec (GetEnv('Comspec'),' /c '+s);
  SWAPVECTORS;
  InitDosMem;
  InitEvents;
  InitSysError;
  Result:=DosError;
  CursorLines:=1543;
  Application^.Redraw;
  NoInfoMsg;

    Case Result Of
    2:MessageBox(#3^M+#3'Файл не найден !',Nil,mfError+mfCancelButton);
    3:MessageBox(#3^M+#3'Путь не найден !',Nil,mfError+mfCancelButton);
    5:MessageBox(#3^M+#3'Доступ невозможен !',Nil,mfError+mfCancelButton);
    6:MessageBox(#3^M+#3'Неверное устройство !',Nil,mfError+mfCancelButton);
    8:MessageBox(#3^M+#3'Недостаточно памяти !',Nil,mfError+mfCancelButton);
   10:MessageBox(#3^M+#3'Неверные настройки !',Nil,mfError+mfCancelButton);
   11:MessageBox(#3^M+#3'Неверный формат !',Nil,mfError+mfCancelButton);
   18:MessageBox(#3^M+#3'Слишком много файлов !',Nil,mfError+mfCancelButton);
   Else
   End;



Assign(fr,Path^.Dat.ToRAzdel+'razdel.db');
c:=IOResult;
Reset(fr);
c:=IOResult;
If c<>0 Then
 Begin
  MessageBox(^M+#3'Ошибка доступа к файлу '+Path^.Dat.ToRAzdel+'razdel.db'+' при проверке контрольных сумм!'+
  ' Код:'+IntToStr(c,ClitrMAntissa),Nil,mfError+mfCancelButton);
  AddProtocol('Ошибка доступа к файлу '+Path^.Dat.ToRAzdel+'razdel.db'+' при проверке контрольных сумм!','','');
  Exit;
 End;

Summa[0]:=#0;
While Not(Eof(fr)) Do
Begin
Read(fr,RAzdelElement);
If RAzdelElement.Employ Then
Begin
st:=RAzdelElement.Kod;
RFormatZerro(st,CMAntissa);
Assign(fskl,Path^.Dat.ToTemp+'Temp\Main\'+st+'.db');
l:=IOResult;
Reset(fskl);
l:=IOResult;
If l=0 Then
 Begin
  DInfoMsgShkala('Выполняется проверка контрольной суммы. Раздел '+
  RazdelElement.Kod+' ... ',1,EmployRazdel,StrToInt(RazdelElement.Kod)+1);
  While Not(Eof(Fskl)) Do
   Begin
    New(Skl,Init);
    ReadSklad(fskl,Skl^.DAt);
    If Skl^.Dat.Employ Then
     Begin
      MyStr(StrToReal(Summa)+StrToInt(Skl^.Dat.Input.Kol)*StrToReal(Skl^.Dat.Input.R_Zena),
         CIZena,CMAntissa,Summa);
     End;
    Dispose(Skl,Done);
   End;{While}
   l:=IOResult;
   Close(fskl);
   l:=IOResult;
 End
 Else
  Begin
   NoInfoMsg;
   MessageBox(^M+#3'Ошибка открытия файла '+Path^.Dat.ToTemp+'Temp\Main\'+st+'.db'+' при проверке контрольных сумм!'+
   ' Код:'+IntToStr(c,ClitrMAntissa),Nil,mfError+mfCancelButton);
   AddProtocol('Ошибка открытия файла '+Path^.Dat.ToTemp+'Temp\Main\'+st+'.db'+' при проверке контрольных сумм!','','');
   Exit;
  End;

End;{RazdelElement.Employ}
End;{While Razdel}

c:=IOResult;
Close(fr);
c:=IOResult;

ControlSumma[0]:=#0;
Assign(txt,Path^.Dat.ToTemp+'Temp\Main\extrok.txt'{'c:\nitogo\razdel.db'});
c:=IOResult;
Reset(txt);
c:=IOResult;
Readln(txt,ControlSumma);
c:=IOResult;
Close(txt);
c:=IOResult;

NoInfoMsg;


If Abs(StrToReal(Summa)-StrToReal(ControlSumma))>0.009 Then
 Begin
  UnpackRemoteDB:=False;
  Exit;
 End;

UnpackRemoteDB:=True;
End;




Function CopyClientDB:boolean;
var s:string;
     Result : LongInt;
     Kuda,Kuda1 : String;
     Key : AllStr;

Begin
  CopyClientDB:=FAlse;
  DInfoMsg('Синхронизирую служебные справочники...',False);
  DoneSysError;
  DoneEvents;
  Application^.HideCursor;
  DoneDosMem;
  SWAPVECTORS;

  Kuda:=Path^.Dat.ToClient;
  Kuda1:=Path^.Dat.ToSpr;
  Kuda[0]:=Chr(Ord(Kuda[0])-1);
  Kuda1[0]:=Chr(Ord(Kuda1[0])-1);

  If FindParam('/WIN2K') Then Key:=' '
  Else
  If FindParam('/W2K3') Then Key:=' '
  Else Key:=' /Y ';
  {копирую barter.db}
  s:='copy /b '+Path^.Dat.ToTemp+'temp\client\barter.*'+' '+Kuda+Key+NullStr^;
  exec (GetEnv('Comspec'),' /c '+s);

  {копирую sklad.db}
  s:='copy /b '+Path^.Dat.ToTemp+'temp\client\sklad.*'+' '+Kuda+Key+NullStr^;
  exec (GetEnv('Comspec'),' /c '+s);

  {копирую eksped.db}
  s:='copy /b '+Path^.Dat.ToTemp+'temp\client\eksped.*'+' '+Kuda+Key+NullStr^;
  exec (GetEnv('Comspec'),' /c '+s);

  {копирую agent.db}
  s:='copy /b '+Path^.Dat.ToTemp+'temp\client\agent.*'+' '+Kuda+Key+NullStr^;
  exec (GetEnv('Comspec'),' /c '+s);

  {копирую client.db}
  s:='copy /b '+Path^.Dat.ToTemp+'temp\client\client.*'+' '+Kuda+Key+NullStr^;
  exec (GetEnv('Comspec'),' /c '+s);

  {копирую make.db}
  s:='copy /b '+Path^.Dat.ToTemp+'temp\client\make.*'+' '+Kuda+Key+NullStr^;
  exec (GetEnv('Comspec'),' /c '+s);

  {копирую group.db}
  s:='copy /b '+Path^.Dat.ToTemp+'temp\SPR\group.*'+' '+Kuda1+Key+NullStr^;
  exec (GetEnv('Comspec'),' /c '+s);

  s:='copy /b '+Path^.Dat.ToTemp+'temp\SPR\ngtd.*'+' '+Kuda1+Key+NullStr^;
  exec (GetEnv('Comspec'),' /c '+s);

  s:='copy /b '+Path^.Dat.ToTemp+'temp\SPR\marka.*'+' '+Kuda1+Key+NullStr^;
  exec (GetEnv('Comspec'),' /c '+s);

  s:='copy /b '+Path^.Dat.ToTemp+'temp\SPR\smarka.*'+' '+Kuda1+Key+NullStr^;
  exec (GetEnv('Comspec'),' /c '+s);

  s:='copy /b '+Path^.Dat.ToTemp+'temp\SPR\expert.*'+' '+Kuda1+Key+NullStr^;
  exec (GetEnv('Comspec'),' /c '+s);

  s:='copy /b '+Path^.Dat.ToTemp+'temp\SPR\mera.*'+' '+Kuda1+Key+NullStr^;
  exec (GetEnv('Comspec'),' /c '+s);

  s:='copy /b '+Path^.Dat.ToTemp+'temp\SPR\lands.*'+' '+Kuda1+Key+NullStr^;
  exec (GetEnv('Comspec'),' /c '+s);

  s:='copy /b '+Path^.Dat.ToTemp+'temp\SPR\firma.*'+' '+Kuda1+Key+NullStr^;
  exec (GetEnv('Comspec'),' /c '+s);

  s:='copy /b '+Path^.Dat.ToTemp+'temp\SPR\region.*'+' '+Kuda1+Key+NullStr^;
  exec (GetEnv('Comspec'),' /c '+s);

  s:='copy /b '+Path^.Dat.ToTemp+'temp\SPR\route.*'+' '+Kuda1+Key+NullStr^;
  exec (GetEnv('Comspec'),' /c '+s);

  s:='copy /b '+Path^.Dat.ToTemp+'temp\SPR\ksertif.*'+' '+Kuda1+Key+NullStr^;
  exec (GetEnv('Comspec'),' /c '+s);

  s:='copy /b '+Path^.Dat.ToTemp+'temp\SPR\class.*'+' '+Kuda1+Key+NullStr^;
  exec (GetEnv('Comspec'),' /c '+s);

  s:='copy /b '+Path^.Dat.ToTemp+'temp\SPR\banks.*'+' '+Kuda1+Key+NullStr^;
  exec (GetEnv('Comspec'),' /c '+s);

  s:='copy /b '+Path^.Dat.ToTemp+'temp\SPR\kassa.*'+' '+Kuda1+Key+NullStr^;
  exec (GetEnv('Comspec'),' /c '+s);

  s:='copy /b '+Path^.Dat.ToTemp+'temp\SPR\personal.*'+' '+Kuda1+Key+NullStr^;
  exec (GetEnv('Comspec'),' /c '+s);

  SWAPVECTORS;
  InitDosMem;
  InitEvents;
  InitSysError;
  Result:=DosError;
  CursorLines:=1543;
  Application^.Redraw;
  NoInfoMsg;

    Case Result Of
    2:MessageBox(#3^M+#3'Файл не найден !',Nil,mfError+mfCancelButton);
    3:MessageBox(#3^M+#3'Путь не найден !',Nil,mfError+mfCancelButton);
    5:MessageBox(#3^M+#3'Доступ невозможен !',Nil,mfError+mfCancelButton);
    6:MessageBox(#3^M+#3'Неверное устройство !',Nil,mfError+mfCancelButton);
    8:MessageBox(#3^M+#3'Недостаточно памяти !',Nil,mfError+mfCancelButton);
   10:MessageBox(#3^M+#3'Неверные настройки !',Nil,mfError+mfCancelButton);
   11:MessageBox(#3^M+#3'Неверный формат !',Nil,mfError+mfCancelButton);
   18:MessageBox(#3^M+#3'Слишком много файлов !',Nil,mfError+mfCancelButton);
   Else
   End;

  CopyClientDB:=True;
End;



Function CopyNewID:Boolean;
VAr fid,fidn : File;
    fr : File Of RazdelType;
    c,i,j,Count : Word;
    l,k : LongInt;
    st : AllStr;
    skl : PBufBazType;
    RazdelElement : RAzdelType;
Begin
CopyNewID:=False;
Assign(fr,Path^.Dat.ToRAzdel+'razdel.db'{'c:\nitogo\razdel.db'});
c:=IOResult;
Reset(fr);
c:=IOResult;
If c<>0 Then
 Begin
  MessageBox(^M+#3'Ошибка доступа к файлу '+Path^.Dat.ToRAzdel+'razdel.db'+' при синхронизации базы наименований!'+
  ' Код:'+IntToStr(c,ClitrMAntissa),Nil,mfError+mfCancelButton);
  AddProtocol('Ошибка доступа к файлу '+Path^.Dat.ToRAzdel+'razdel.db'+' при синхронизации базы наименований','','');
  Exit;
 End;

While Not(Eof(fr)) Do
Begin
Read(fr,RAzdelElement);
If RAzdelElement.Employ Then
Begin
st:=RAzdelElement.Kod;
RFormatZerro(st,CMAntissa);
Assign(fid,Path^.Dat.ToTemp+'Temp\ID\'+st+'.id');
l:=IOResult;
Reset(fid,SizeOf(BazType));
l:=IOResult;
If l=0 Then
Begin
Assign(fidN,PAth^.Dat.ToName+st+'.id');
l:=IOResult;
Rewrite(fidN,SizeOf(BazType));
l:=IOResult;
If l=0 Then
 Begin
  DInfoMsgShkala('Выполняется синхронизация базы наименований. Раздел '+
  RazdelElement.Kod+' ... ',1,EmployRazdel,StrToInt(RazdelElement.Kod)+1);
  While Not(Eof(Fid)) Do
   Begin
    New(Skl,Init);
    ReadBufBaz(fid,Skl,Count);
    BlockWrite(Fidn, Skl^.Point, Count);
    Dispose(Skl,Done);
   End;{While}

   l:=IOResult;
   Close(fidn);
 End
 Else
  Begin
   NoInfoMsg;
   MessageBox(^M+#3'Ошибка создания файла '+Path^.Dat.ToNAme+st+'.id'+' при синхронизации базы наименований!'+
   ' Код:'+IntToStr(c,ClitrMAntissa),Nil,mfError+mfCancelButton);
   AddProtocol('Ошибка создания файла '+Path^.Dat.ToNAme+st+'.id'+' при синхронизации базы наименований!','','');
   Exit;
  End;

  l:=IOResult;
  close(fid);
End
 Else
  Begin
   NoInfoMsg;
   MessageBox(^M+#3'Ошибка открытия файла '+Path^.Dat.ToTemp+'\Temp\Id\'+st+'.id'+' при синхронизации базы наименований!'+
   ' Код:'+IntToStr(c,ClitrMAntissa),Nil,mfError+mfCancelButton);
   AddProtocol('Ошибка открытия файла '+Path^.Dat.ToTemp+'\Temp\Id\'+st+'.id'+' при синхронизации базы наименований!','','');
   Exit;
  End;

End;{RazdelElement.Employ}
End;{While Razdel}
NoInfoMsg;
c:=IOResult;
Close(fr);
c:=IOResult;
CopyNewID:=True;
End;


(*
Function CopyNewMBX:Boolean;
VAr fid,fidn : File;
    fr : File Of RazdelType;
    c,i,j,Count : Word;
    l,k : LongInt;
    st : AllStr;
    skl : PBufExtSkladType;
    RazdelElement : RAzdelType;
Begin
CopyNewMBX:=False;
Assign(fr,Path^.Dat.ToRAzdel+'razdel.db'{'c:\nitogo\razdel.db'});
c:=IOResult;
Reset(fr);
c:=IOResult;
If c<>0 Then
 Begin
  MessageBox(^M+#3'Ошибка доступа к файлу '+Path^.Dat.ToRAzdel+'razdel.db'+' при синхронизации базы аттрибутов!'+
  ' Код:'+IntToStr(c,ClitrMAntissa),Nil,mfError+mfCancelButton);
  AddProtocol('Ошибка доступа к файлу '+Path^.Dat.ToRAzdel+'razdel.db'+' при синхронизации базы аттрибутов','','');
  Exit;
 End;

While Not(Eof(fr)) Do
Begin
Read(fr,RAzdelElement);
If RAzdelElement.Employ Then
Begin
st:=RAzdelElement.Kod;
RFormatZerro(st,CMAntissa);
Assign(fid,Path^.Dat.ToTemp+'Temp\Main\'+st+'.mbx');
l:=IOResult;
Reset(fid,SizeOf(ExtSkladType));
l:=IOResult;
If l=0 Then
Begin
Assign(fidN,Path^.Dat.TOSklad+st+'.mbx');
l:=IOResult;
Rewrite(fidN,SizeOf(ExtSkladType));
l:=IOResult;
If l=0 Then
 Begin
  DInfoMsgShkala('Выполняется синхронизация базы аттрибутов. Раздел '+
  RazdelElement.Kod+' ... ',1,EmployRazdel,StrToInt(RazdelElement.Kod)+1);
  While Not(Eof(Fid)) Do
   Begin
    New(Skl,Init);
    ReadBufExtSklad(fid,Skl,Count);
    BlockWrite(Fidn, Skl^.Point, Count);
    Dispose(Skl,Done);
   End;{While}

   l:=IOResult;
   Close(fidn);
 End
 Else
  Begin
   NoInfoMsg;
   MessageBox(^M+#3'Ошибка создания файла '+Path^.Dat.TOSklad+st+'.mbx'+' при синхронизации базы аттрибутов!'+
   ' Код:'+IntToStr(c,ClitrMAntissa),Nil,mfError+mfCancelButton);
   AddProtocol('Ошибка создания файла '+Path^.Dat.TOSklad+st+'.mbx'+' при синхронизации базы аттрибутов!','','');
   Exit;
  End;

  l:=IOResult;
  close(fid);
End
 Else
  Begin
   NoInfoMsg;
   MessageBox(^M+#3'Ошибка открытия файла '+Path^.Dat.ToTemp+'\Temp\Main\'+st+'.mbx'+' при синхронизации базы аттрибутов!'+
   ' Код:'+IntToStr(c,ClitrMAntissa),Nil,mfError+mfCancelButton);
   AddProtocol('Ошибка открытия файла '+Path^.Dat.ToTemp+'\Temp\Main\'+st+'.mbx'+' при синхронизации базы аттрибутов!',
   '','');
   Exit;
  End;

End;{RazdelElement.Employ}
End;{While Razdel}
NoInfoMsg;
c:=IOResult;
Close(fr);
c:=IOResult;
CopyNewMBX:=True;
End;

*)


Const RecievBuffer=SizeOf(SkidkaType)*400;

Type NoType = Array[1..RecievBuffer] Of Char;

Type PNoType = ^NoTypePtr;
     NoTypePtr =Object(TObject)
     Dat : NoType;
     Constructor Init;
     Destructor Done; Virtual;
     End;

Constructor NoTypePtr.Init;
VAr c: Word;
Begin
TObject.Init;
 For c:=1 To RecievBuffer Do
  begin
   DAt[c]:=#0;
  End;
End;

Destructor NoTypePtr.Done;
Begin
TObject.Done;
End;




Function CopyNewSkl:Boolean;
VAr fid,fidn : File;
    fr : File Of RazdelType;
    c,i,j,Count : Word;
    l,k : LongInt;
    st : AllStr;
    skl : PNoType;
    RazdelElement : RAzdelType;
Begin
CopyNewSkl:=False;
Assign(fr,Path^.Dat.ToRAzdel+'razdel.db'{'c:\nitogo\razdel.db'});
c:=IOResult;
Reset(fr);
c:=IOResult;
If c<>0 Then
 Begin
  MessageBox(^M+#3'Ошибка доступа к файлу '+Path^.Dat.ToRAzdel+'razdel.db'+' при синхронизации базы скидок!'+
  ' Код:'+IntToStr(c,ClitrMAntissa),Nil,mfError+mfCancelButton);
  AddProtocol('Ошибка доступа к файлу '+Path^.Dat.ToRAzdel+'razdel.db'+' при синхронизации базы скидок','','');
  Exit;
 End;

While Not(Eof(fr)) Do
Begin
Read(fr,RAzdelElement);
If RAzdelElement.Employ Then
Begin
st:=RAzdelElement.Kod;
RFormatZerro(st,CMAntissa);
Assign(fid,Path^.Dat.ToTemp+'Temp\skidki\'+st+'.skl');
l:=IOResult;
Reset(fid,SizeOf(SkidkaType));
l:=IOResult;
If l=0 Then
Begin
Assign(fidN,Path^.Dat.TOSkidki+st+'.skl');
l:=IOResult;
Rewrite(fidN,SizeOf(SkidkaType));
l:=IOResult;
If l=0 Then
 Begin
l:=IOResult;
Close(FIdn);
l:=IOResult;
Reset(fidN,SizeOf(SkidkaType));
l:=IOResult;
  DInfoMsgShkala('Выполняется синхронизация базы скидок. Раздел '+
  RazdelElement.Kod+' ... ',1,EmployRazdel,StrToInt(RazdelElement.Kod)+1);
  While Not(Eof(Fid)) Do
   Begin
    New(Skl,Init);
    Count:=400;
    BlockRead(fid,Skl^.Dat,400,Count);
    l:=IOResult;
    {MemC('111='+IntToStr(Count,CMantissa));}
    BlockWrite(Fidn, Skl^.Dat,Count);
   l:=IOResult;
   If l<>0 Then
    Begin
    End;
    Dispose(Skl,Done);
   End;{While}

   l:=IOResult;
   Close(fidn);
 End
 Else
  Begin
   NoInfoMsg;
   MessageBox(^M+#3'Ошибка создания файла '+Path^.Dat.TOSkidki+st+'.skl'+' при синхронизации базы скидок!'+
   ' Код:'+IntToStr(c,ClitrMAntissa),Nil,mfError+mfCancelButton);
   AddProtocol('Ошибка создания файла '+Path^.Dat.TOSkidki+st+'.skl'+' при синхронизации базы скидок!','','');
   Exit;
  End;

  l:=IOResult;
  close(fid);
End
 Else
  Begin
   NoInfoMsg;
   MessageBox(^M+#3'Ошибка открытия файла '+Path^.Dat.ToTemp+'\Temp\Skidki\'+st+'.skl'+' при синхронизации базы скидок!'+
   ' Код:'+IntToStr(c,ClitrMAntissa),Nil,mfError+mfCancelButton);
   AddProtocol('Ошибка открытия файла '+Path^.Dat.ToTemp+'\Temp\Skidki\'+st+'.skl'+' при синхронизации базы скидок!',
   '','');
   Exit;
  End;

End;{RazdelElement.Employ}
End;{While Razdel}
NoInfoMsg;
c:=IOResult;
Close(fr);
c:=IOResult;
CopyNewSkl:=True;
End;


Function CreatFastBAkUp:Boolean;
Var txt : Text;
    Regim,c,Result : Word;
    f : File;
    st1,st2 : TDAteString;
    Prod,Prod1,s1 : TMyString;
    Ext : ArtikulStr;
    KurzDate : TDateString;
    St : TDateString;
    s : String;
begin
CreatFastBAkUp:=False;
If (StrToInt(CurrentPassword)<>0) And (DisableClose=1) Then
 Begin
  MessageBox(^M+#3'С этой рабочей станции нельзя проводить эту операцию!',Nil,mfWarning+mfCancelButton);
  Exit;
 End;

 Str(StrToInt(Rek^.Dat.Kod):2,Ext);
 RFormatZerro(Ext,2);

 s:=FDate;

 c:=IOResult;
 Assign(txt,Path^.Dat.TOReport);
 Rewrite(txt);
 c:=IOResult;
 If c<>0 Then
     Begin
      MessageBox(#3^M+#3'Не могу создать файл листинга!',Nil,mfError+mfCancelButton);
      Exit;
     End;

{продажи}
 If FExists(Path^.Dat.TOMarket+S+'.mrk') Then
  Begin
   Writeln(txt,Path^.Dat.TOMarket+S+'.mrk');
   Writeln(txt,Path^.Dat.TOMarketIndex+S+'.mrx');
  End;

{переоценки}
 If FExists(Path^.Dat.ToCorrect+S+'.prz') Then  Writeln(txt,Path^.Dat.ToCorrect+S+'.prz');

{ревизия}
 If FExists(Path^.Dat.ToRewisia+S+'.rwz') Then  Writeln(txt,Path^.Dat.ToRewisia+S+'.rwz');

{приход}
 If FExists(Path^.Dat.ToPrihod+S+'.prh') Then  Writeln(txt,Path^.Dat.ToPrihod+S+'.prh');

{возврат и хронология возвратов}
 If FExists(Path^.Dat.ToReturn+S+'.vzw') Then  Writeln(txt,Path^.Dat.ToReturn+S+'.vzw');

{оплата реализации}
 If FExists(Path^.Dat.ToOplata+S+'.opl') Then  Writeln(txt,Path^.Dat.ToOplata+S+'.opl');

{оплата отката}
 If FExists(Path^.Dat.ToOplata+S+'.otp') Then  Writeln(txt,Path^.Dat.ToOplata+S+'.otp');

{выдано и принято в счет бартера денег из кассы}
 If FExists(Path^.Dat.ToBarter+S+'.bpl') Then  Writeln(txt,Path^.Dat.ToBarter+S+'.bpl');

{склад количество}
    Writeln(txt,Path^.Dat.ToSklad+'*.db');

    Writeln(txt,Path^.Dat.ToClient+'*.db');

    Writeln(txt,Path^.Dat.ToClient+'*.lck');

    Writeln(txt,Path^.Dat.ToSPR+'*.db');

    Writeln(txt,Path^.Dat.ToSPR+'*.lck');
{склад дополнительные аттрибуты}
    Writeln(txt,Path^.Dat.ToSklad+'*.mbx');

{склад наименования и индексы}
     Writeln(txt,Path^.Dat.ToName+'*.id');

{протокол операций}
 If FExists(Path^.Dat.ToProtocol+S+'.pr') Then  Writeln(txt,Path^.Dat.ToProtocol+S+'.pr');

{протокол возврата}
 If FExists(Path^.Dat.ToProtocol+S+'.vpr') Then Writeln(txt,Path^.Dat.ToProtocol+S+'.vpr');

{копия файла листинга}
     Writeln(txt,Path^.Dat.TOReport);

{долги}
     Writeln(txt,Path^.Dat.ToDolg+'*.dlg');

c:=IOResult;
 Close(txt);
c:=IOResult;


 AddProtocol('Формирование резервной копии перед загрузкой удаленных складов ','','');

 DInfo('Создаю резервную копию данных...');

  If FExists(Path^.Dat.ToUtils+'rar.log') Then
    Begin
     Assign(f,Path^.Dat.ToUtils+'rar.log');
     c:=IOResult;
     Erase(f);
     c:=IOResult;
    End;

  DoneSysError;
  DoneEvents;
  Application^.HideCursor;
  DoneDosMem;
  SWAPVECTORS;
  s1:=FormKod(Rek^.Dat.Kod);
  Delete(s1,1,1);

  s1:='bkp';
  If FExists(Path^.Dat.ToArchiv+s+'.'+'bkp') Then
   Begin
    Assign(f,Path^.Dat.ToArchiv+s+'.'+'bkp');
    Result:=IOResult;
    rewrite(f);
    Result:=IOResult;
    Close(f);
    Result:=IOResult;
   End;

  {для rar}
  s:=Path^.Dat.ToUtils+'rar a -m5 -r '+{-av-}'-inul -dh -ilog -w'+Path^.Dat.ToTemp+' '+Path^.Dat.ToArchiv+s+'.'+s1+' @'+
  Path^.Dat.ToReport{+' '+NullStr^};
  {мой комметрарий}
  exec (GetEnv('Comspec'),' /c '+s);
  {
  s:=FDate;
  s:='arj a '+Path^.Dat.ToArchiv+s+'.'+s1+' -e '+Prod+' '+NullStr;{мой комметрарий}
  {exec (GetEnv('Comspec'),' /c '+s);}
  (*
  s:=FDate;
  s:='arj a '+Path^.Dat.ToArchiv+s+'.'+s1+' -e '+Prod1+' '+NullStr;{мой комметрарий}
  exec (GetEnv('Comspec'),' /c '+s);
  *)
  SWAPVECTORS;
  InitDosMem;
  InitEvents;
  InitSysError;
  Result:=DosError;
  NoInfo;
  GlobalTime:=TimeStringToTime('hh:mm:ss',Times);
  CursorLines:=1543;
  Application^.Redraw;

  If FExists(Path^.Dat.ToUtils+'rar.log') Then
    Begin
     ViewAsText(Path^.Dat.ToUtils+'rar.log','Протокол архивации',False);
    End;

   CursorLines:=1543;
CreatFastBAkUp:=True;

end;



Procedure LoadRemoteDB;
Var f : File;
    Attr : Word;
Begin

If EnableAverageOtdel=0 Then Exit;

If Not(TestOpenDAte1(FDate)) Then
 Begin
  MessageBox(#3^m+#3'Доступ к данным за '+FDAte+' заблокирован!',Nil,mfError+mfCancelButton);
  Exit;
 End;

If (GlobalReadOnly=1) Or (ReadOnlyConst=1) Then
   Begin
    MessageBox(#3^M+ReadOnlyStr^,Nil,mfWarning+mfCancelButton);
    Exit;
   End;

If (StrToInt(CurrentPassword)<>0) And (DisableClose=1) Then
 Begin
  MessageBox(^M+#3'С этой рабочей станции нельзя проводить эту операцию!',Nil,mfWarning+mfCancelButton);
  Exit;
 End;

If MessageBox(^M+Monopolia^,Nil,mfWarning+mfOkCancel)<>cmOk Then Exit;

Assign(f,Path^.Dat.ToArchiv+Path^.Dat.PriceName{'remote.exe'});
If Not FExists(Path^.Dat.ToArchiv+Path^.Dat.PriceName{'remote.exe'}) Then
 Begin
  AddProtocol('Попытка загрузки базы удаленных складов!','Удаленная база не найдена!','');
  MessageBox(^M+#3'Не найдена база удаленных складов!',Nil,mfError+mfCancelButton);
  Exit;
 End
 Else
  Begin
    GetFAttr(f,Attr);
   if doserror<>0 then
     begin
       AddProtocol('Попытка загрузки базы удаленных складов!',
          'Ошибка доступа к файлу базы удаленных складов!','');
       MessageBox(^M+#3+'Ошибка доступа к файлу базы удаленных складов!'^M+
          #3+' Код: '+IntToStr(DosError,CLitrMantissa),Nil,mfError+mfCancelButton);
      Exit;
     end
   else
     begin
       If SystemAttribute(PAth^.Dat.ToArchiv+Path^.Dat.PriceName{'remote.exe'}) Then
        Begin
         AddProtocol('Попытка повторной загрузки базы удаленных складов!',
            '','');
         MessageBox(^M+#3+'Повторная загрузка базы удаленных складов невозможна!',
            Nil,mfError+mfCancelButton);
         Exit;
        End
        Else
         Begin

          If Not UnPackRemoteDB Then
           Begin
            AddProtocol('Ошибка при проверке контрольных сумм!','','');
            MessageBox(^M+#3'Ошибка при проверке контрольных сумм!',Nil,mfError+mfCancelButton);
            Exit;
           End;

          If Not FExists(Path^.Dat.ToTemp+'\temp\main\extrok.txt') Then
           Begin
            AddProtocol('Ошибка при распаковке базы удаленных складов!','','');
            MessageBox(^M+#3'Ошибка при распаковке базы удаленных складов!',Nil,mfError+mfCancelButton);
            Exit;
           End;

           If CreatFastBakUp Then
           AddProtocol('Создание резервной копии успешно завершено!','','')
           Else Exit;

           If CopyClientDB Then
           AddProtocol('Синхронизация служебных справочников успешно завершена!','','')
           Else Exit;

           If CopyNewDB Then
           AddProtocol('Синхронизация базы наличия успешно завершена!','','')
           Else Exit;

           If CopyNewID Then
           AddProtocol('Синхронизация базы наименований успешно завершена!','','')
           Else Exit;
(*
           If CopyNewMBX Then
           AddProtocol('Синхронизация базы аттрибутов успешно завершена!','','')
           Else Exit;
*)
           If CopyNewSkl Then
           AddProtocol('Синхронизация базы скидок успешно завершена!','','')
           Else Exit;

           SetCopyMailAttribute(Path^.Dat.ToArchiv+Path^.Dat.PriceName{'remote.exe'});
           CreatIDXAuto;
           SPRIDX(True);
           ClientIDX(True);{авто}
           AddProtocol('Загрузка базы удаленных складов выполнена успешно!','','');
           SetLoadStatus(FDate);
           MessageBox(#3^M+#3'ВСЕ! Можете работать!',Nil,mfInformation+mfCancelButton);
         End;
     end;
  End;
End;



(*
Procedure FormPerevoski;
Var c,c1,FindOtd,Count : Word;
    StartDAte,StopDAte : TDAteString;
    Sklf : File;
    i : LongInt;
    star : TDAteSTring;
    NoScreenZakaz : PBox;
    Txt : Text;
    R : TRect;
    E : PBufZakazType;
    Start,Stop  : LongInt;
    s : String;
    SArt,SKol,SZena : TDAteString;
    Space,SSkladNAme,Summa,SItogo : AllStr;
    SFullName : String[CNAme+1+CNAme];
Begin
{
 вопрос относительно склада поставщика
 SelectOtkuda
  0:резервный
  1:кти
  2:сойфера
  3:зарезервировано
  4:отказ от расчета
 вопрос относительно даты доставки заказов
}

 If EnableAverageOtdel=0 Then Exit;

 If MessageBox(^M+Monopolia^,Nil,mfWarning+mfOkCancel)<>cmOk Then Exit;

 StartDate:=DateToDateString(DAteMask,DateStringToDAte(DAteMask,FDAte)+1);
 StopDate:=DateToDateString(DAteMask,DateStringToDAte(DAteMask,FDAte)+1);
 FindOtd:=SelOtkuda;

 If FindOtd=4 Then Exit;

 {If Not DatePeriodDialog(StartDate,StopDate,False) Then Exit;}

 If Not NewDateDialog(StartDate) Then Exit;

 StopDAte:=StartDAte;

 SSkladName:='????';
Case FindOtd Of
0:Begin FindOtd:=5;SSkladName:=GetMAkeField(FMake,'0004',1){резервный}End;
1:Begin FindOtd:=6;SSkladName:=GetMAkeField(FMake,'0001',1){сойфера}End;
2:Begin FindOtd:=7;SSkladName:=GetMAkeField(FMake,'0009',1){кти}End;
3:FindOtd:=8;{зарезервировано}
Else Exit;
End;

 Start:=DateStringToDAte(DAteMask,StartDAte);
 Stop :=DateStringToDAte(DAteMask,StopDate);

Assign(Txt,Path^.Dat.ToMarket+'Zakaz.gid');
i:=IOResult;
Reset(Txt);
i:=IOResult;
If i<>0 Then
 BEgin
  MessageBox(^M+#3+'Ошибка открытия файла-маршрутизатора '+Path^.Dat.ToMarket+'Zakaz.gid',Nil,mfError+
  mfCancelButton);
 End
 Else
  Begin
   Readln(txt,Star);
   i:=IOResult;
   System.Close(Txt);
   i:=IOResult;
  End;


Assign(Sklf,Path^.DAt.ToMarket+'zakaz.db');
i:=IOResult;
Reset(Sklf,SizeOf(ZakazType));
i:=IOResult;
If I<>0 Then
 Begin
  MessageBox(^M+#3+'Ошибка открытия файла '+Path^.Dat.ToMarket+'Zakaz.db',Nil,mfError+
  mfCancelButton);
  Exit;
 End;

R.Assign(0, 0, 0, 0);
NoScreenZakaz := New(PBox, Init(R, 1, Nil));
NoScreenZakaz^.NewList(New(PTextCollection, Init(0,1)));


{формируем список забронированного товара по заказам}
If (StrToInt(Star)-10)>=0 Then
Begin
Seek(SklF,StrToInt(Star)-10);
Star:=IntToStr(StrToInt(Star)-10,CKOl);
End
Else
 Begin
  Seek(SklF,StrToInt(Star));
 End;

  New(E,Init);

While Not(Eof(Sklf)) Do
Begin

  DInfoMsgShkala('Формирую заявку для склада '+SSkladName+'...',0,FileSize(SklF)-StrToInt(Star),FilePos(SklF)-StrToInt(Star));

  ReadBufZakaz(Sklf,E,Count);

  For c:=1 To Count Do
   Begin
    {добавляем в список забронированный товар}
   If (E^.Point.Dat[c].Oformlenie=0)  Then
Begin

      E^.Point.Dat[c].DateC:=DateToDAteString(DateMask,
         DateStringToDate(DateMask,E^.Point.Dat[c].DateC)+E^.Point.Dat[c].EndDAte);

  If (DAteStringToDate(DateMask,E^.Point.Dat[c].DAteC)>=Start) And
     (DAteStringToDate(DateMask,E^.Point.Dat[c].DAteC)<=Stop) Then
  Begin

    s[0]:=#0;
    For c1:=1 to E^.Point.Dat[c].Amount Do
     Begin


      If E^.Point.Dat[c].MarketElement[c1].Input.InputDivision=FindOtd Then
   Begin
      If(TestElement(E^.Point.Dat[c].MarketElement[c1].BAzKod,NoScreenZakaz)) Then
        Begin{элемент не найден в списке}
         DelSpace(E^.Point.Dat[c].MarketElement[c1].Input.Kol);
         RFormat(E^.Point.Dat[c].MarketElement[c1].Input.Kol,CKOl);
         s:='│'+E^.Point.Dat[c].MarketElement[c1].BAzKod+'│'+E^.Point.Dat[c].MarketElement[c1].Input.Kol;
        End
        Else {элемент найден в списке}
         Begin
          s:=NoScreenZakaz^.GetText(
             Location(NoScreenZakaz,E^.Point.Dat[c].MarketElement[c1].BAzKod,False),NoScreenZakaz^.List^.Count);
          sKol:=Copy(s,1+1+CArtikul+1,CKol+1);
          Str(StrToInt(SKOl)+StrToInt(E^.Point.Dat[c].MarketElement[c1].Input.Kol):CKol+1,SKOl);
          s:='│'+E^.Point.Dat[c].MarketElement[c1].BAzKod+'│'+SKol;
          NoScreenZakaz^.List^.AtFree(Location(NoScreenZakaz,E^.Point.Dat[c].MArketElement[c1].BAzKod,False));
          NoScreenZakaz^.SetRange(NoScreenZakaz^.List^.Count);
         End;

        NoScreenZakaz^.List^.Insert(NewStr(s));
        NoScreenZakaz^.SetRange(NoScreenZakaz^.List^.Count);
   End;
     End;{For Amount}



    {добавляем в список забронированные сертификаты}
    s[0]:=#0;
    For c1:=1 to E^.Point.Dat[c].AmountS Do
     Begin

      If E^.Point.Dat[c].DocumentElement[c1].Input.InputDivision=FindOtd Then
   Begin
      If(TestElement(E^.Point.Dat[c].DocumentElement[c1].BAzKod,NoScreenZakaz)) Then
        Begin{элемент не найден в списке}
         DelSpace(E^.Point.Dat[c].DocumentElement[c1].Input.Kol);
         RFormat(E^.Point.Dat[c].DocumentElement[c1].Input.Kol,CKOl);
         s:='│'+E^.Point.Dat[c].DocumentElement[c1].BAzKod+'│'+E^.Point.Dat[c].DocumentElement[c1].Input.Kol;
        End
        Else {элемент найден в списке}
         Begin
         s:=NoScreenZakaz^.GetText(
            Location(NoScreenZakaz,E^.Point.Dat[c].DocumentElement[c1].BAzKod,False),
            NoScreenZakaz^.List^.Count);
         sKol:=Copy(s,1+1+CArtikul+1,CKol+1);
         Str(StrToInt(SKOl)+StrToInt(E^.Point.Dat[c].DocumentElement[c1].Input.Kol):CKol+1,SKOl);
         s:='│'+E^.Point.Dat[c].DocumentElement[c1].BAzKod+'│'+SKol;
          NoScreenZakaz^.List^.AtFree(Location(NoScreenZakaz,E^.Point.Dat[c].DocumentElement[c1].BAzKod,False));
          NoScreenZakaz^.SetRange(NoScreenZakaz^.List^.Count);
         End;
        NoScreenZakaz^.List^.Insert(NewStr(s));
        NoScreenZakaz^.SetRange(NoScreenZakaz^.List^.Count);
   End;
     End;{For Amount}
  End;{DAteC}
End;{Oformlenie}

   End;{For Count}
End;{While}
System.Close(Sklf);
i:=IOResult;
{закончили формировать список забронированного товара по заказам}
NoInfoMsg;

Dispose(E,Done);


Assign(Txt,Path^.Dat.ToTemp+'Zajavka.txt');
i:=IOResult;
Rewrite(Txt);
i:=IOResult;
If i<>0 Then
 BEgin
  Dispose(NoScreenZakaz,Done);
  MessageBox(^M+#3+'Ошибка создания '+Path^.Dat.ToTemp+'Zajavka.txt'+' Код:'+
  IntToStr(i,CMAntissa),Nil,mfError+
  mfCancelButton);
  Exit;
 End;

 Space:='';
 Writeln(txt,Header+NoPitch[Nprint^.DAt.Printer]);

 Writeln(txt,Space+ 'Склад: ',GetClientField(FClient,Rek^.Dat.Kod,1)+'  Оператор: '+CurrentPassword+' EYE & 1997-01');
 Writeln(txt);


 Writeln(txt,Space+'           ЗАЯВКА НА ПЕРЕВОЗКУ ТОВАРА СО СКЛАДА '+SSkladName);
 Writeln(txt,Space+' для комплектации заказов подлежащих доставке клиенту в период с '+StartDate+' по '+StopDAte);
 Writeln(txt);
 Writeln(txt,Space+'┌────────────────────────────────────────────────────────────────────────────────────────────┐');
 Writeln(txt,Space+'│N   Код  Наименование товара                                   Колич   Р/Цена   Итого по Р/Ц│');
                   {123│12345│12345678901234567890123456123456789012345678901234561│12345│12345678│1234567890123}
 Writeln(txt,Space+'└────────────────────────────────────────────────────────────────────────────────────────────┘');
 Writeln(txt,Pitch[Nprint^.DAt.Printer]+HeaderStop);

 SItogo[0]:=#0;
 If NoScreenZakaz^.List^.Count-1>=0 Then
 For c:=0 To NoScreenZakaz^.List^.Count-1 Do
  Begin
   s := NoScreenZakaz^.GetText(c, NoScreenZakaz^.List^.Count);
   SKol:=Copy(s,1+1+CArtikul+1,CKol+1);{количество}
   SArt:=Copy(s,1+1,CArtikul);{количество}
   SZena:=BakGetField(FRZena,SArt,0);
   MyStr(StrToReal(SZena),CZena,CMAntissa,SZena);
   MyStr(StrToInt(SKol)*StrToReal(SZena),CInputIZena,CMAntissa,Summa);
   SFullNAme:=GetIdField(FFFNAme,SArt);
   Format(SFullNAme,CNAme+1+CNAme);
   S:=IntToStr(c+1,CLitrMAntissa);
   DelSPace(s);
   DelSpace(SKol);
   RFormat(SKol,CKol);
   RFormat(s,CLitrMAntissa);
   If c<> NoScreenZakaz^.List^.Count-1 Then
   Writeln(txt,Space+s+' '+SArt+' '+SFullName+' '+SKol+' '+SZena+' '+Summa)
   Else
   Writeln(txt,Space+OnlyLink+s+' '+SArt+' '+SFullName+' '+SKol+' '+SZena+' '+Summa);
   MyStr(StrToReal(SITogo)+StRToReal(Summa),CIZena,CMantissa,SItogo);
  End;
 MyStr(StrToReal(SITogo),CIZena,CMantissa,SItogo);
 Writeln(txt,Space+NoPitch[Nprint^.DAt.Printer]);
 Writeln(txt,Space+'──────────────────────────────────────────────────────────────────────────────────────────────');
 Writeln(txt,Space+'Всего позиций: ',NoScreenZakaz^.List^.Count:CKol);
 Writeln(txt,Space+'Всего по Р/Ценам: ',SItogo);
 Writeln(txt);
 Writeln(txt,Space,'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
 Writeln(txt,Space+'==============================================================================================');

 i:=IOResult;
 System.Close(txt);
 i:=IOResult;
 Dispose(NoScreenZakaz,Done);
 AddProtocol('Формирование заявки на перевозку товара со склада '+SSkladName,
 'для комплектации заказов подлежащих доставке клиенту в период с '+StartDate+' по '+StopDAte,'');

 ViewAsText(Path^.Dat.ToTemp+'zajavka.txt',True);
 {ReportNew(Path^.Dat.ToTemp+'zajavka.txt','',1,False,False);}
End;
*)



Procedure SortList(Var NoScreenList:PBox);
VAr TempList : PBox;
    R : TRect;
    S : String;
    c : Word;
    SFullNAme: String;
    SOtd,SKOl,SArt,SRAzd,SSKol,Delta,SSum : AllStr;
Begin
If NoScreenList^.List<>Nil Then
 Begin
  If NoScreenList^.List^.Count-1>=0 Then
  Begin
   R.Assign(0, 0, 0, 0);
   TempList := New(PBox, Init(R, 1, Nil));
   TempList^.NewList(New(PTextCollection, Init(0,1)));

   For c:=0 To NoScreenList^.List^.Count-1 Do
    Begin
     DInfoMsgShkala('Сортирую список...',0,NoScreenList^.List^.Count-1,c);
     s:=NoScreenList^.GetText(c,NoScreenList^.List^.Count);
     SKol:=Copy(s,1+1+CArtikul+1,CKol+1);{количество}
     SArt:=Copy(s,1+1,CArtikul);{код}
     SRAzd:=COpy(SArt,1,CRAzdelKod);
     SFullNAme:=GetIdField(FFFNAme,SArt);
     Format(SFullNAme,CNAme+1+CNAme);
     s:=SRAzd+' '+SFullNAme+'│'+SArt+' '+SKol;
     TempList^.List^.Insert(NewStr(s));
     TempList^.SetRange(TempList^.List^.Count);
    End;{For по}
   NoInfoMsg;

   NoScreenList^.NewList(Nil);
   NoScreenList^.NewList(New(PMyCollection, Init(0,1)));

   For c:=0 To TempList^.List^.Count-1 Do
    Begin
     DInfoMsgShkala('Подготовка списка наименований ...',0,TempList^.List^.Count-1,c);
     s:=TempList^.GetText(c,TempList^.List^.Count);
     System.Delete(s,1,CRAzdelKod+1+(CNAme+1+CNAme));
     NoScreenList^.List^.Insert(NewStr(s));
     NoScreenList^.SetRange(NoScreenList^.List^.Count);
    End;{For по}
   NoInfoMsg;

   Dispose(TempList,Done);
  End;{NoScreenList}
 End;{NoScreenList}
End;{Procedure}



Procedure FormPerevoski;
Var c,c1,FindOtd,Count : Word;
    StartDAte,StopDAte : TDAteString;
    Sklf : File;
    i : LongInt;
    star : TDAteSTring;
    NoScreenZakaz : PBox;
    Txt : Text;
    R : TRect;
    E : PBufZakazType;
    Start,Stop  : LongInt;
    s : String;
    SArt,SKol,SZena : TDAteString;
    Space,SSkladNAme,Summa,SItogo : AllStr;
    Pack,SFullName : String[CNAme+1+CNAme];
Begin
{
 вопрос относительно склада поставщика
 SelectOtkuda
  0:резервный
  1:кти
  2:сойфера
  3:зарезервировано
  4:отказ от расчета
 вопрос относительно даты доставки заказов
}

 If EnableAverageOtdel=0 Then Exit;

 If MessageBox(^M+Monopolia^,Nil,mfWarning+mfOkCancel)<>cmOk Then Exit;

 StartDate:=DateToDateString(DAteMask,DateStringToDAte(DAteMask,FDAte)+1);
 StopDate:=DateToDateString(DAteMask,DateStringToDAte(DAteMask,FDAte)+1);
 FindOtd:=SelOtkuda;

 If FindOtd=4 Then Exit;

 {If Not DatePeriodDialog(StartDate,StopDate,False) Then Exit;}

 If Not NewDateDialog(StartDate) Then Exit;

 StopDAte:=StartDAte;

 SSkladName:='????';
Case FindOtd Of
0:Begin
    FindOtd:=5;
    If StrToInt(Rek^.Dat.Kod)=10 Then
    SSkladName:=GetMAkeField(FMake,'0011',1){резервный продмаркета}
    Else
    SSkladName:=GetMAkeField(FMake,'0004',1){резервный};
  End;
1:Begin FindOtd:=6;SSkladName:=GetMAkeField(FMake,'0001',1){сойфера}End;
(*
             {выключено 28/01/2005 по просьбе гончарова
             для того чтобы можно было использовать 8 отделение для нужд склада
             (идентификации товара возващенного со спара)

2:Begin FindOtd:=7;SSkladName:=GetMAkeField(FMake,'0009',1){кти}End;
3:FindOtd:=8;{зарезервировано}
*)
Else Exit;
End;

 Start:=DateStringToDAte(DAteMask,StartDAte);
 Stop :=DateStringToDAte(DAteMask,StopDate);

Assign(Txt,Path^.Dat.ToMarket+'Zakaz.gid');
i:=IOResult;
Reset(Txt);
i:=IOResult;
If i<>0 Then
 BEgin
  MessageBox(^M+#3+'Ошибка открытия файла-маршрутизатора '+Path^.Dat.ToMarket+'Zakaz.gid',Nil,mfError+
  mfCancelButton);
 End
 Else
  Begin
   Readln(txt,Star);
   i:=IOResult;
   System.Close(Txt);
   i:=IOResult;
  End;


Assign(Sklf,Path^.DAt.ToMarket+'zakaz.db');
i:=IOResult;
Reset(Sklf,SizeOf(ZakazType));
i:=IOResult;
If I<>0 Then
 Begin
  MessageBox(^M+#3+'Ошибка открытия файла '+Path^.Dat.ToMarket+'Zakaz.db',Nil,mfError+
  mfCancelButton);
  Exit;
 End;

R.Assign(0, 0, 0, 0);
NoScreenZakaz := New(PBox, Init(R, 1, Nil));
NoScreenZakaz^.NewList(New(PTextCollection, Init(0,1)));


{формируем список забронированного товара по заказам}
If (StrToInt(Star)-10)>=0 Then
Begin
Seek(SklF,StrToInt(Star)-10);
Star:=IntToStr(StrToInt(Star)-10,CKOl);
End
Else
 Begin
  Seek(SklF,StrToInt(Star));
 End;

  New(E,Init);

While Not(Eof(Sklf)) Do
Begin

  DInfoMsgShkala('Формирую заявку для склада '+SSkladName+'...',0,FileSize(SklF)-StrToInt(Star),FilePos(SklF)-StrToInt(Star));

  ReadBufZakaz(Sklf,E,Count);

  For c:=1 To Count Do
   Begin
    {добавляем в список забронированный товар}
   If (E^.Point.Dat[c].Oformlenie=0)  Then
Begin

      E^.Point.Dat[c].DateC:=DateToDAteString(DateMask,
         DateStringToDate(DateMask,E^.Point.Dat[c].DateC)+E^.Point.Dat[c].EndDAte);

  If (DAteStringToDate(DateMask,E^.Point.Dat[c].DAteC)>=Start) And
     (DAteStringToDate(DateMask,E^.Point.Dat[c].DAteC)<=Stop) Then
  Begin

    s[0]:=#0;
    For c1:=1 to E^.Point.Dat[c].Amount Do
     Begin


      If E^.Point.Dat[c].MarketElement[c1].Input.InputDivision=FindOtd Then
   Begin
      If(TestElement(E^.Point.Dat[c].MarketElement[c1].BAzKod,NoScreenZakaz)) Then
        Begin{элемент не найден в списке}
         DelSpace(E^.Point.Dat[c].MarketElement[c1].Input.Kol);
         RFormat(E^.Point.Dat[c].MarketElement[c1].Input.Kol,CKOl);
         s:='│'+E^.Point.Dat[c].MarketElement[c1].BAzKod+'│'+E^.Point.Dat[c].MarketElement[c1].Input.Kol;
        End
        Else {элемент найден в списке}
         Begin
          s:=NoScreenZakaz^.GetText(
             Location(NoScreenZakaz,E^.Point.Dat[c].MarketElement[c1].BAzKod,False),NoScreenZakaz^.List^.Count);
          sKol:=Copy(s,1+1+CArtikul+1,CKol+1);
          Str(StrToInt(SKOl)+StrToInt(E^.Point.Dat[c].MarketElement[c1].Input.Kol):CKol+1,SKOl);
          s:='│'+E^.Point.Dat[c].MarketElement[c1].BAzKod+'│'+SKol;
          NoScreenZakaz^.List^.AtFree(Location(NoScreenZakaz,E^.Point.Dat[c].MArketElement[c1].BAzKod,False));
          NoScreenZakaz^.SetRange(NoScreenZakaz^.List^.Count);
         End;

        NoScreenZakaz^.List^.Insert(NewStr(s));
        NoScreenZakaz^.SetRange(NoScreenZakaz^.List^.Count);
   End;
     End;{For Amount}



    {добавляем в список забронированные сертификаты}
    s[0]:=#0;
    For c1:=1 to E^.Point.Dat[c].AmountS Do
     Begin

      If E^.Point.Dat[c].DocumentElement[c1].Input.InputDivision=FindOtd Then
   Begin
      If(TestElement(E^.Point.Dat[c].DocumentElement[c1].BAzKod,NoScreenZakaz)) Then
        Begin{элемент не найден в списке}
         DelSpace(E^.Point.Dat[c].DocumentElement[c1].Input.Kol);
         RFormat(E^.Point.Dat[c].DocumentElement[c1].Input.Kol,CKOl);
         s:='│'+E^.Point.Dat[c].DocumentElement[c1].BAzKod+'│'+E^.Point.Dat[c].DocumentElement[c1].Input.Kol;
        End
        Else {элемент найден в списке}
         Begin
         s:=NoScreenZakaz^.GetText(
            Location(NoScreenZakaz,E^.Point.Dat[c].DocumentElement[c1].BAzKod,False),
            NoScreenZakaz^.List^.Count);
         sKol:=Copy(s,1+1+CArtikul+1,CKol+1);
         Str(StrToInt(SKOl)+StrToInt(E^.Point.Dat[c].DocumentElement[c1].Input.Kol):CKol+1,SKOl);
         s:='│'+E^.Point.Dat[c].DocumentElement[c1].BAzKod+'│'+SKol;
          NoScreenZakaz^.List^.AtFree(Location(NoScreenZakaz,E^.Point.Dat[c].DocumentElement[c1].BAzKod,False));
          NoScreenZakaz^.SetRange(NoScreenZakaz^.List^.Count);
         End;
        NoScreenZakaz^.List^.Insert(NewStr(s));
        NoScreenZakaz^.SetRange(NoScreenZakaz^.List^.Count);
   End;
     End;{For Amount}
  End;{DAteC}
End;{Oformlenie}

   End;{For Count}
End;{While}
System.Close(Sklf);
i:=IOResult;
{закончили формировать список забронированного товара по заказам}
NoInfoMsg;

Dispose(E,Done);


Assign(Txt,Path^.Dat.ToTemp+'Zajavka.txt');
i:=IOResult;
Rewrite(Txt);
i:=IOResult;
If i<>0 Then
 BEgin
  Dispose(NoScreenZakaz,Done);
  MessageBox(^M+#3+'Ошибка создания '+Path^.Dat.ToTemp+'Zajavka.txt'+' Код:'+
  IntToStr(i,CMAntissa),Nil,mfError+
  mfCancelButton);
  Exit;
 End;

 Space:='';
 Writeln(txt,Header+GlobalPrn^.Dat.NoPitch[Nprint^.DAt.Printer]);

 Writeln(txt,Space+ 'Склад: ',GetClientField(FClient,Rek^.Dat.Kod,1)+'  Оператор: '+CurrentPassword+' EYE & 1997-01');
 Writeln(txt);


 Writeln(txt,Space+'           ЗАЯВКА НА ПЕРЕВОЗКУ ТОВАРА СО СКЛАДА '+SSkladName);
 Writeln(txt,Space+' для комплектации заказов подлежащих доставке клиенту в период с '+StartDate+' по '+StopDAte);
 Writeln(txt);
 Writeln(txt,Space+'┌──┬─────┬────────────────────────────────────────────┬────────┬──────┬────────┬─────────────┐');
 Writeln(txt,Space+'│N │ Код │Наименование товара                         │Упаковок│Колич │ Р/Цена │ Итого по Р/Ц│');
 Writeln(txt,Space+'└──┴─────┴────────────────────────────────────────────┴────────┴──────┴────────┴─────────────┘');

                    {123│12345│1234567890123456789012345612345678901234567│123456789│12345│12345678│1234567890123}

 Writeln(txt,GlobalPrn^.Dat.Pitch[Nprint^.DAt.Printer]+HeaderStop);

 SortList(NoScreenZakaz);

 SItogo[0]:=#0;
 If NoScreenZakaz^.List^.Count-1>=0 Then
 For c:=0 To NoScreenZakaz^.List^.Count-1 Do
  Begin
   s := NoScreenZakaz^.GetText(c, NoScreenZakaz^.List^.Count);
   SKol:=Copy(s,1+1+CArtikul+1,CKol+1);{количество}
   SArt:=Copy(s,1+1,CArtikul);{количество}
   SZena:=BakGetField(FRZena,SArt,0);
   MyStr(StrToReal(SZena),CZena,CMAntissa,SZena);
   MyStr(StrToInt(SKol)*StrToReal(SZena),CInputIZena,CMAntissa,Summa);
   SFullNAme:=GetIdField(FFFNAme,SArt);
   Format(SFullNAme,CNAme+1+CNAme-(CPAck+1));
   S:=IntToStr(c+1,CLitrMAntissa);
   DelSPace(s);
   DelSpace(SKol);
   RFormat(SKol,CKol);
   RFormat(s,CLitrMAntissa);
   Pack:=CalcPack(SArt,SKol);
   DelSpace(Pack);
   RFormat(Pack,CPAck);

   If c<> NoScreenZakaz^.List^.Count-1 Then
   Writeln(txt,Space+s+SeparatorChar+SArt+SeparatorChar+SFullName+SeparatorChar+Pack+SeparatorChar+SKol+SeparatorChar+SZena+
   SeparatorChar+Summa)
   Else
   Writeln(txt,Space+OnlyLink+s+SeparatorChar+SArt+SeparatorChar+SFullName+SeparatorChar+Pack+SeparatorChar+
   SKol+SeparatorChar+SZena+
   SeparatorChar+Summa);
   MyStr(StrToReal(SITogo)+StRToReal(Summa),CIZena,CMantissa,SItogo);
  End;
 MyStr(StrToReal(SITogo),CIZena,CMantissa,SItogo);
 Writeln(txt,Space+GlobalPrn^.Dat.NoPitch[Nprint^.DAt.Printer]);
 Writeln(txt,Space+'──────────────────────────────────────────────────────────────────────────────────────────────');
 Writeln(txt,Space+'Всего позиций:'+SeparatorChar,NoScreenZakaz^.List^.Count:CKol);
 Writeln(txt,Space+'Всего по Р/Ценам:'+SeparatorChar,SItogo);
 Writeln(txt);
 Writeln(txt,Space,'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
 Writeln(txt,Space+'==============================================================================================');

 i:=IOResult;
 System.Close(txt);
 i:=IOResult;
 Dispose(NoScreenZakaz,Done);
 AddProtocol('Формирование заявки на перевозку товара со склада '+SSkladName,
 'для комплектации заказов подлежащих доставке клиенту в период с '+StartDate+' по '+StopDAte,'');

 ViewAsText(Path^.Dat.ToTemp+'zajavka.txt','Заявка на межскл.перевозку для заказов с '+StartDate+' по '+StopDate
,True);
 {ReportNew(Path^.Dat.ToTemp+'zajavka.txt','',1,False,False);}
End;






Function CalcIndex(ENew:PZakazType;SArt:ArtikulStr;Otd:Word):Word;
Var c : Word;
    Find : Boolean;
BEgin
CalcIndex:=1;
If ENew^.DAt.Amount=0 Then Exit;

Find:=FAlse;

 For c:=1 To ENew^.Dat.Amount Do
 Begin
  If StrToInt(ENew^.Dat.MarketElement[c].BAzKod)=StrToInt(SArt) Then
   If ((ENew^.Dat.MarketElement[c].Input.InputDivision=Otd) And (Otd in SetEnableOtdel))
    Or Not(Otd in SetEnableOtdel)Then
    Begin
     Find:=True;
     Break;
    End;
 End;

If Not Find Then CAlcIndex:=ENew^.DAt.Amount+1
Else CAlcIndex:=c;

End;{Function}


Function CalcIndexD(ENew:PZakazType;SArt:ArtikulStr;Otd:Word):Word;
Var c : Word;
    Find : Boolean;
BEgin
CalcIndexD:=1;
If ENew^.DAt.AmountS=0 Then Exit;


Find:=FAlse;

 For c:=1 To ENew^.Dat.AmountS Do
 Begin
  If StrToInt(ENew^.Dat.DocumentElement[c].BAzKod)=StrToInt(SArt) Then
   If ((ENew^.Dat.DocumentElement[c].Input.InputDivision=Otd) And (Otd in SetEnableOtdel))
    Or Not(Otd in SetEnableOtdel)Then
    Begin
     Find:=True;
     Break;
    End;
 End;

If Not Find Then CAlcIndexD:=ENew^.DAt.AmountS+1
Else CAlcIndexD:=c;
End;{Function}



Procedure PeremeshenieBroni(SArt:ArtikulStr;PKolR:ArtikulStr;Otd:Word);
Var fskl : SkladFileType;
    Pos : ArtikulStr;
    Rz  : ArtikulStr;
    st : ArtikulStr;
    l : LongInt;
    Skl : PSkladType;
Begin
If (Otd in SetEnableOtdel) Then Exit;
 st:=SArt;
 DelSpace(st);
 Rz:=Copy(st,1,CRazdelKod);
 Assign(fskl,Path^.Dat.TOSklad+rz+'.db');
 l:=IOResult;
 Reset(fskl);
 l:=IOResult;
 If l <> 0 Then
 Begin
  BazError(l,Path^.Dat.TOSklad+rz+'.db'+' Код:['+st+']');
  Exit;
 End;
   Pos:=Copy(st,1+CRazdelKod,CKod);
   L:=StrToInt(Pos);
   If l>FileSize(fskl) Then
    Begin
     System.Close(fskl);
     MessageBox(^M+#3'Попытка чтения базы наличия товара ('+st+') '+Pos+' - позиция вне файла!',nil,mfError+mfCancelButton);
     Exit;
    End;
   Seek(fskl,L);
   l:=IOResult;
   New(Skl,Init);
   l:=IOResult;
   ReadSkladPointer(fskl,Skl);
   Seek(fskl,FilePos(FSkl)-1);

   {код для перемещения брони}
   With Skl^.DAt.Input Do
    Begin
     Str(StrToInt(DivisionR[1])+
            StrToInt(PKolR):CKol,DivisionR[1]);
     DelSpace(DivisionR[1]);
     Str(StrToInt(DivisionR[otd])-StrToInt(PKolR):CKol,DivisionR[Otd]);
     If StrToInt(DivisionR[Otd])<0 Then DivisionR[Otd]:='0';
     DelSpace(DivisionR[Otd]);
    End;
   Write(fskl,Skl^.Dat);
   Dispose(Skl,Done);
   l:=IOResult;
   Close(fskl);
   l:=IOResult;
End;




Procedure ConvertZakazToNew(Var fSkl:ZakazFileType;E:PZakazType);
Var Enew : PZakazType;
    c,Count : Word;
Begin
{1.создаем новый экземплар заказа
 2.переписываем в него все базовае характеристика кроме Amount и AmountS
 3.цикл по старому заказу
    цикл по новому заказу}
 {позиционируемся на одну позицию назад}
 Seek(FSkl,FilePos(FSkl)-1);
 New(ENew,Init);
 With ENew^.DAt Do
  Begin
     OperatorSelector:=E^.DAt.OperatorSelector;
     DocSelector:=E^.DAt.DocSelector;
     Versia:=E^.DAt.Versia;
        ShkalaNumer:=E^.DAt.ShkalaNumer;
     SkidkaSelector:=E^.DAt.SkidkaSelector;
     ClientKod:=E^.DAt.ClientKod;
     AgentKod:=E^.DAt.AgentKod;
     EkspeditorKod:=E^.DAt.EkspeditorKod;
     Document:=E^.DAt.Document;
     DocumentComment:=E^.DAt.DocumentComment;
     DateC:=E^.DAt.DateC;
     TimeC:=E^.DAt.TimeC;
     DateM:=E^.DAt.DateM;
     TimeM:=E^.DAt.TimeM;
     SertifSummaZ:=E^.DAt.SertifSummaZ;
     SertifSkidka:=E^.DAt.SertifSkidka;
     SummaZ:=E^.DAt.SummaZ;
     Skidka:=E^.DAt.Skidka;
     SkladKod:=E^.DAt.SkladKod;
     Caption:=E^.DAt.Caption;
     Locked:=E^.DAt.Locked;
     Srok:=E^.DAt.Srok;
     EndDate:=E^.DAt.EndDate;
     DocReal:=E^.DAt.DocReal;
     DocDate:=E^.DAt.DocDate;
     Rashet:=E^.DAt.Rashet;
     Oformlenie:=E^.DAt.Oformlenie;
  End;

  Count:=0;
  For c:=1 To E^.DAt.Amount Do
   Begin
    If StrToInt(E^.DAt.MArketElement[c].Input.Kol)>0 Then
     Begin
      Count:=CalcIndex(ENew,E^.DAt.MArketElement[c].BAzKod,E^.DAt.MArketElement[c].Input.InputDivision);
      ENew^.DAt.MArketElement[Count].BazKod:=E^.DAt.MArketElement[c].BazKod;

      If StrtoInt(ENew^.DAt.MArketElement[Count].Input.KOl)=0 Then
      With ENew^.Dat.MarketElement[Count].Input Do
       Begin
        Zena    :=E^.DAt.MArketElement[c].Input.Zena;
        Skidka  :=E^.DAt.MArketElement[c].Input.Skidka;
        Proz    :=E^.DAt.MArketElement[c].Input.Proz;

        If Not(E^.DAt.MArketElement[c].Input.InputDiviSion in SetEnableOtdel) Then
           InputDiviSion:=1
        Else
           InputDiviSion:=E^.DAt.MArketElement[c].Input.InputDiviSion;

        NSertif  :=E^.DAt.MArketElement[c].Input.NSertif;
        Version :=E^.DAt.MArketElement[c].Input.Version;

       MarkaKod :=E^.DAt.MArketElement[c].Input.MarkaKod;
       SMarkaKod:=E^.DAt.MArketElement[c].Input.SMarkaKod;
       NGTDKod  :=E^.DAt.MArketElement[c].Input.NGTDKod;
       ExpertKod:=E^.DAt.MArketElement[c].Input.ExpertKod;
       Srok     :=E^.DAt.MArketElement[c].Input.Srok;
     Virabotano :=E^.DAt.MArketElement[c].Input.Virabotano;



       End;

        Str(StrToInt(ENew^.Dat.MarketElement[Count].Input.SertifKol)+
           StrToInt(E^.DAt.MArketElement[c].Input.SertifKol):Ckol,
           ENew^.Dat.MarketElement[Count].Input.SertifKol);
        DelSpace(ENew^.DAt.MArketElement[Count].Input.SertifKOl);

      Str(StrToInt(ENew^.DAt.MArketElement[Count].Input.KOl)+
          StrToInt(E^.DAt.MArketElement[c].Input.Kol):CKOl,
                   ENew^.DAt.MArketElement[Count].Input.KOl);
      DelSpace(ENew^.DAt.MArketElement[Count].Input.KOl);

      If ENew^.DAt.Amount<Count Then ENew^.DAt.Amount:=Count;

      PeremeshenieBroni(E^.DAt.MarketElement[c].BAzKod,
                        E^.DAt.MarketElement[c].Input.Kol,
                           E^.DAt.MarketElement[c].Input.InputDivision);

     End;{если есть смысл переносить позицию}
   End;{For}


  Count:=0;
  For c:=1 To E^.DAt.AmountS Do
   Begin
    If StrToInt(E^.DAt.DocumentElement[c].Input.Kol)>0 Then
     Begin
      Count:=CalcIndexD(ENew,E^.DAt.DocumentElement[c].BAzKod,E^.DAt.DocumentElement[c].Input.InputDivision);
      ENew^.DAt.DocumentElement[Count].BazKod:=E^.DAt.DocumentElement[c].BazKod;

      If StrtoInt(ENew^.DAt.DocumentElement[Count].Input.KOl)=0 Then
      With ENew^.Dat.DocumentElement[Count].Input Do
       Begin
        Zena    :=E^.DAt.DocumentElement[c].Input.Zena;
        Skidka  :=E^.DAt.DocumentElement[c].Input.Skidka;
        Proz    :=E^.DAt.DocumentElement[c].Input.Proz;
        If Not(E^.DAt.DocumentElement[c].Input.InputDiviSion in SetEnableOtdel) Then
           InputDiviSion:=1
        Else
           InputDiviSion:=E^.DAt.DocumentElement[c].Input.InputDiviSion;

        NSertif  :=E^.DAt.DocumentElement[c].Input.NSertif;
        Version :=E^.DAt.DocumentElement[c].Input.Version;

       MarkaKod :=E^.DAt.DocumentElement[c].Input.MarkaKod;
       SMarkaKod:=E^.DAt.DocumentElement[c].Input.SMarkaKod;
       NGTDKod  :=E^.DAt.DocumentElement[c].Input.NGTDKod;
       ExpertKod:=E^.DAt.DocumentElement[c].Input.ExpertKod;
       Srok     :=E^.DAt.DocumentElement[c].Input.Srok;
     Virabotano :=E^.DAt.DocumentElement[c].Input.Virabotano;
       End;

      Str(StrToInt(ENew^.DAt.DocumentElement[Count].Input.KOl)+
          StrToInt(E^.DAt.DocumentElement[c].Input.Kol):CKOl,
                   ENew^.DAt.DocumentElement[Count].Input.KOl);
      DelSpace(ENew^.DAt.DocumentElement[Count].Input.KOl);

      If ENew^.DAt.AmountS<Count Then ENew^.DAt.AmountS:=Count;


      PeremeshenieBroni(E^.DAt.DocumentElement[c].BAzKod,
                        E^.DAt.DocumentElement[c].Input.Kol,
                           E^.DAt.DocumentElement[c].Input.InputDivision);

     End;{если есть смысл переносить позицию}
   End;{For}

 Write(Fskl,ENew^.Dat);
 c:=IOResult;

 AddProtocol('Преобразование заказа N '+E^.DAt.Document,'','');

 Dispose(ENew,Done);
End;{Procedure}

(*
Procedure ConvertZakazToNew(Var fSkl:ZakazFileType;E:PZakazType);
Var Enew : PZakazType;
    c,Count : Word;
Begin
{1.создаем новый экземплар заказа
 2.переписываем в него все базовае характеристика кроме Amount и AmountS
 3.цикл по старому заказу
    цикл по новому заказу}
 {позиционируемся на одну позицию назад}
 Seek(FSkl,FilePos(FSkl)-1);
 New(ENew,Init);
 With ENew^.DAt Do
  Begin
     OperatorSelector:=E^.DAt.OperatorSelector;
     DocSelector:=E^.DAt.DocSelector;
     Versia:=E^.DAt.Versia;
        ShkalaNumer:=E^.DAt.ShkalaNumer;
     SkidkaSelector:=E^.DAt.SkidkaSelector;
     ClientKod:=E^.DAt.ClientKod;
     AgentKod:=E^.DAt.AgentKod;
     EkspeditorKod:=E^.DAt.EkspeditorKod;
     Document:=E^.DAt.Document;
     DocumentComment:=E^.DAt.DocumentComment;
     DateC:=E^.DAt.DateC;
     TimeC:=E^.DAt.TimeC;
     DateM:=E^.DAt.DateM;
     TimeM:=E^.DAt.TimeM;
     SertifSummaZ:=E^.DAt.SertifSummaZ;
     SertifSkidka:=E^.DAt.SertifSkidka;
     SummaZ:=E^.DAt.SummaZ;
     Skidka:=E^.DAt.Skidka;
     SkladKod:=E^.DAt.SkladKod;
     Caption:=E^.DAt.Caption;
     Locked:=E^.DAt.Locked;
     Srok:=E^.DAt.Srok;
     EndDate:=E^.DAt.EndDate;
     DocReal:=E^.DAt.DocReal;
     DocDate:=E^.DAt.DocDate;
     Rashet:=E^.DAt.Rashet;
     Oformlenie:=E^.DAt.Oformlenie;
  End;

  Count:=0;
  For c:=1 To E^.DAt.Amount Do
   Begin
    If StrToInt(E^.DAt.MArketElement[c].Input.Kol)>0 Then
     Begin
      Count:=CalcIndex(ENew,E^.DAt.MArketElement[c].BAzKod,E^.DAt.MArketElement[c].Input.InputDivision);
      ENew^.DAt.MArketElement[Count].BazKod:=E^.DAt.MArketElement[c].BazKod;

      If StrtoInt(ENew^.DAt.MArketElement[Count].Input.KOl)=0 Then
      With ENew^.Dat.MarketElement[Count].Input Do
       Begin
        Zena    :=E^.DAt.MArketElement[c].Input.Zena;
        Skidka  :=E^.DAt.MArketElement[c].Input.Skidka;
        Proz    :=E^.DAt.MArketElement[c].Input.Proz;
   InputDiviSion:=1;
       NSertif  :=E^.DAt.MArketElement[c].Input.NSertif;
       SertifKol:=E^.DAt.MArketElement[c].Input.SertifKol;
        Version :=E^.DAt.MArketElement[c].Input.Version;
       End;

      Str(StrToInt(ENew^.DAt.MArketElement[Count].Input.KOl)+
          StrToInt(E^.DAt.MArketElement[c].Input.Kol):CKOl,
                   ENew^.DAt.MArketElement[Count].Input.KOl);
      DelSpace(ENew^.DAt.MArketElement[Count].Input.KOl);

      If ENew^.DAt.Amount<Count Then ENew^.DAt.Amount:=Count;

      PeremeshenieBroni(E^.DAt.MarketElement[c].BAzKod,
                        E^.DAt.MarketElement[c].Input.Kol,
                           E^.DAt.MarketElement[c].Input.InputDivision);

     End;{если есть смысл переносить позицию}
   End;{For}


  Count:=0;
  For c:=1 To E^.DAt.AmountS Do
   Begin
    If StrToInt(E^.DAt.DocumentElement[c].Input.Kol)>0 Then
     Begin
      Count:=CalcIndexD(ENew,E^.DAt.DocumentElement[c].BAzKod,E^.DAt.DocumentElement[c].Input.InputDivision);
      ENew^.DAt.DocumentElement[Count].BazKod:=E^.DAt.DocumentElement[c].BazKod;

      If StrtoInt(ENew^.DAt.DocumentElement[Count].Input.KOl)=0 Then
      With ENew^.Dat.DocumentElement[Count].Input Do
       Begin
        Zena    :=E^.DAt.DocumentElement[c].Input.Zena;
        Skidka  :=E^.DAt.DocumentElement[c].Input.Skidka;
        Proz    :=E^.DAt.DocumentElement[c].Input.Proz;
   InputDiviSion:=1;
       NSertif  :=E^.DAt.DocumentElement[c].Input.NSertif;
       SertifKol:=E^.DAt.DocumentElement[c].Input.SertifKol;
        Version :=E^.DAt.DocumentElement[c].Input.Version;
       End;

      Str(StrToInt(ENew^.DAt.DocumentElement[Count].Input.KOl)+
          StrToInt(E^.DAt.DocumentElement[c].Input.Kol):CKOl,
                   ENew^.DAt.DocumentElement[Count].Input.KOl);
      DelSpace(ENew^.DAt.DocumentElement[Count].Input.KOl);

      If ENew^.DAt.AmountS<Count Then ENew^.DAt.AmountS:=Count;


      PeremeshenieBroni(E^.DAt.DocumentElement[c].BAzKod,
                        E^.DAt.DocumentElement[c].Input.Kol,
                           E^.DAt.DocumentElement[c].Input.InputDivision);

     End;{если есть смысл переносить позицию}
   End;{For}

 Write(Fskl,ENew^.Dat);
 c:=IOResult;

 AddProtocol('Преобразование заказа N '+E^.DAt.Document,'','');

 Dispose(ENew,Done);
End;{Procedure}
*)


Procedure StoreRemoteDB;
Var c,c1,FindOtd,Count : Word;
    StartDAte,StopDAte : TDAteString;
    Sklf : ZakazFileType;
    i : LongInt;
    star : TDAteSTring;
    Txt : Text;
    R : TRect;
    E : PZakazType;
    Start,Stop  : LongInt;
    s : String;
    SArt,SKol,SZena : TDAteString;
    Space,SSkladNAme,Summa,SItogo : AllStr;
    SFullName : String[CNAme+1+CNAme];
    SDAte : TDAteString;
    Find : Boolean;
Begin

If EnableAverageOtdel=0 Then Exit;

If Not(TestOpenDAte1(FDate)) Then
 Begin
  MessageBox(#3^m+#3'Доступ к данным за '+FDAte+' заблокирован!',Nil,mfError+mfCancelButton);
  Exit;
 End;

If (GlobalReadOnly=1) Or (ReadOnlyConst=1) Then
   Begin
    MessageBox(#3^M+ReadOnlyStr^,Nil,mfWarning+mfCancelButton);
    Exit;
   End;

If (StrToInt(CurrentPassword)<>0) And (DisableClose=1) Then
 Begin
  MessageBox(^M+#3'С этой рабочей станции нельзя проводить эту операцию!',Nil,mfWarning+mfCancelButton);
  Exit;
 End;




 If MessageBox(^M+Monopolia^,Nil,mfWarning+mfOkCancel)<>cmOk Then Exit;

 StartDate:=DateToDateString(DAteMask,DateStringToDAte(DAteMask,FDAte)+1);
 StopDate:=DateToDateString(DAteMask,DateStringToDAte(DAteMask,FDAte)+1);

 If Not NewDateDialog(StartDate) Then Exit;

 StopDAte:=StartDAte;

 Start:=DateStringToDAte(DAteMask,StartDAte);
 Stop :=DateStringToDAte(DAteMask,StopDate);

Assign(Txt,Path^.Dat.ToMarket+'Zakaz.gid');
i:=IOResult;
Reset(Txt);
i:=IOResult;
If i<>0 Then
 BEgin
  MessageBox(^M+#3+'Ошибка открытия файла-маршрутизатора '+Path^.Dat.ToMarket+'Zakaz.gid',Nil,mfError+
  mfCancelButton);
 End
 Else
  Begin
   Readln(txt,Star);
   i:=IOResult;
   System.Close(Txt);
   i:=IOResult;
  End;

Assign(Sklf,Path^.DAt.ToMarket+'zakaz.db');
i:=IOResult;
Reset(Sklf);
i:=IOResult;
If I<>0 Then
 Begin
  MessageBox(^M+#3+'Ошибка открытия файла '+Path^.Dat.ToMarket+'Zakaz.db',Nil,mfError+
  mfCancelButton);
  Exit;
 End;



{формируем список забронированного товара по заказам}

If (StrToInt(Star)-10)>=0 Then
Begin
Seek(SklF,StrToInt(Star)-10);
Star:=IntToStr(StrToInt(Star)-10,CKOl);
End
Else
 Begin
  Seek(SklF,StrToInt(Star));
 End;

Find:=False;
New(E,Init);
 While Not(Eof(Sklf)) And Not(Find) Do
 Begin
  DInfoMsgShkala('Тестирую заказы, подлежащие доставке '+StartDate+' ...',0,
  FileSize(SklF)-StrToInt(Star),FilePos(SklF)-StrToInt(Star));

  ReadZakaz(Sklf,E);
  If (E^.Dat.Oformlenie=0)  Then
  Begin
   sdate:=DateToDAteString(DateMask,DateStringToDate(DateMask,E^.Dat.DateC)+E^.Dat.EndDAte);
   If (DAteStringToDate(DateMask,sdate)<Start) Then
    Begin
     Find:=True;
     Break;
    End;{DAteC}
  End;{Oformlenie}
 End;{While}

NoInfoMsg;

If Find Then
 Begin
  System.Close(Sklf);
  i:=IOResult;
  MessageBox(^M+#3'Внимание обнаружен заказ, подлежащий доставке '+SDAte+
  '(N '+E^.Dat.Document+' от '+E^.Dat.DateC+')',Nil,mfFatalError+mfCancelButton);
  Dispose(E,Done);
  Exit;
 End;

Dispose(E,Done);

If (StrToInt(Star)-150)>=0 Then
Begin
Seek(SklF,StrToInt(Star)-150);
Star:=IntToStr(StrToInt(Star)-150,CKOl);
End
Else
 Begin
  Seek(SklF,StrToInt(Star));
 End;


New(E,Init);
While Not(Eof(Sklf)) Do
Begin

  DInfoMsgShkala('Обрабатываю заказы, подлежащие доставке '+StartDate+' ...',0,
  FileSize(SklF)-StrToInt(Star),FilePos(SklF)-StrToInt(Star));

  ReadZakaz(Sklf,E);

   If (E^.Dat.Oformlenie=0)  Then
Begin
      sdate:=DateToDAteString(DateMask,
      DateStringToDate(DateMask,E^.Dat.DateC)+E^.Dat.EndDAte);

  If (DAteStringToDate(DateMask,sdate)>=Start) And
     (DAteStringToDate(DateMask,sdate)<=Stop) Then
  Begin

   If Not(Utils3.TestZakaz(E)) Then
   Begin
    ConvertZakazToNew(sklf,E);{пернос брони в первое отделение}
   End
    Else
     AddProtocol('Заказ '+E^.Dat.Document+' отложен!','EnableAverageOtdel='+IntToStr(EnableAverageOtdel,CKol),'');
  End{DAteC}
   Else
     AddProtocol('Заказ '+E^.Dat.Document+' отложен!','sdate='+SDate,DateToDateString(DateMask,Start)+
  ' '+DateToDateString(DateMask,Stop));

End;{Oformlenie}

End;{While}
System.Close(Sklf);
i:=IOResult;
Dispose(E,Done);

NoInfoMsg;

 AddProtocol('Преобразование заказов, подлежащих доставке '+StartDAte+' успешно завершена','','');

 DeleteRemoteDB;

 AddProtocol('Выгрузка остатков удаленных складов успешно завершена','','');

 CreatIDXAuto;

 SetUnLoadStatus(FDate);

 MessageBox(#3^M+#3'Операция успешно завершена!',Nil,mfInformation+mfCancelButton);
End;









(*

Function SetBankLock(c:ArtikulStr;Var Operator:StrNAme):Boolean;
Var f : File of BankType;
    l : LongInt;
    Code : Integer;
    s : BankType;
    st : ArtikulStr;
Begin
 Operator[0]:=#0;
 DInfoNetMsg('Блокирую банк кодом '+c);
 SetBankLock:=False;
 Assign (F,Path^.Dat.ToBank+'Banks.db');
 l:=IOResult;
 Reset(f);
 l:=IOResult;
 If l <> 0 Then
 Begin
  NoNetInfoMsg;
  MessageBox(^M+#3'Ошибка сетевого открытия справочника банков!',nil,mfError+mfCancelButton);
  Exit;
  {заблокировать клиента не удалось}
 End
 Else
  Begin
   DelSpace(c);
   l:=StrToInt(c);

   If L>FileSize(f) Then
    Begin
     System.Close(f);
     NoNetInfoMsg;
     MessageBox(^M+#3'Блокировка банка - позиция вне файла!',nil,mfError+mfCancelButton);
     Exit;
    End;


   Seek(f,l);
   Repeat
   Pause(1);
   Until Lock(f,FilePos(f)*BankSize,BankSize);{предварительная блокировка}
     Read(f,s);
     If s.Locked Then{если позиция кем-то занята}
      Begin
       If S.LockCAption[0]<>#0 Then
       Begin
       Operator:=s.LockCaption;
       DelSpace(Operator);
       DelSpaceRight(s.ComputerNameLocked);
       Operator:=': '+GetOperatorField(FNAme,Operator)+' \\'+s.ComputerNameLocked;
       End;
       Seek(f,Filepos(f)-1);
       Repeat
        Unlock(f,FilePos(f)*BankSize,BankSize);
       Until DosError=0;
       NoNetInfoMsg;
       Close(f);
       Exit;
      End;
{$IFDEF NetVersion}
      s.Locked:=True;            {проведение вторичной блокировки}
      s.LockCaption:=CurrentPassword;
      s.ComputerNameLocked:=NetComputerName;
{$ENDIF}
      Seek(f,Filepos(f)-1);
      Write(f,s);
      Seek(f,Filepos(f)-1);
      Repeat
      Unlock(f,FilePos(f)*BankSize,BankSize);
      Until DosError=0;
      Close(f);
      NoNetInfoMsg;
      SetBankLock:=True;
      Exit;
  End;
End;




Function SetBankUnLock(c:ArtikulStr):Boolean;
Var f : File of BankType;
    l : LongInt;
    Code : Integer;
    s : BankType;
    st : ArtikulStr;
Begin
 DInfoNetMsg('Деблокирую банк с кодом '+c);
 SetBankUnLock:=False;

 Assign (F,Path^.Dat.ToBank+'Banks.db');
 l:=IOResult;
 Reset(f);
 l:=IOResult;
 If l <> 0 Then
 Begin
  NoNetInfoMsg;
  MessageBox(^m+#3'Ошибка сетевого открытия справочника банков!',nil,mfError+mfCancelButton);
  Exit;
  {заблокировать клиента не удалось}
 End
 Else
  Begin
   DelSpace(c);
   l:=StrToInt(c);
   If L>FileSize(f) Then
    Begin
     System.Close(f);
     NoNetInfoMsg;
     MessageBox(^M+#3'Деблокировка банка - позиция вне файла!',nil,mfError+mfCancelButton);
     Exit;
    End;
   Seek(f,l);
   Repeat
   Pause(1);
   Until (Lock(f,FilePos(f)*BankSize,BankSize));
   Read(f,s);
   s.Locked:=False;            {проведение вторичной деблокировки}
   s.LockCaption[0]:=#0;
   s.ComputerNameLocked[0]:=#0;
   Seek(f,Filepos(f)-1);
   Write(f,s);
   Seek(f,Filepos(f)-1);
   Repeat
   Unlock(f,FilePos(f)*BankSize,BankSize);
   Until DosError=0;
   Close(f);
   NoNetInfoMsg;
   SetBankUnLock:=True;
  End;
End;


Function WriteLockBank(ClientElement:BankType):Boolean;
Var f : File Of BankType;
    c : LongInt;
    s : BankType;
Begin
DInfoNetMsg('Сохраняю информацию о банке с кодом '+ClientElement.Kod+'...');
WriteLockBank:=False;
Assign (F,Path^.Dat.ToBank+'Banks.db');
c:=IOResult;
  Reset(f);
  c:=IOResult;
  If c<>0 Then
   Begin
    NoNetInfoMsg;
    MessageBox(^M+#3'Ошибка сетевого открытия справочника банков!',Nil,mfError+mfCancelButton);
    Exit;
   End;
   DelSpace(ClientElement.Kod);
   c:=StrToInt(ClientElement.Kod);
   Seek(f,c);
   Repeat
   Pause(1);
   Until (Lock(f,FilePos(f)*BankSize,BankSize));

{$IFDEF NetVersion}
   ClientElement.Rcd:=True;
   ClientElement.Locked:=True;
   ClientElement.LockCaption:=CurrentPassword;
   ClientElement.ComputerNameLocked:=NetComputerName;
{$ENDIF}

   Write(f,ClientElement);
   Seek(f,Filepos(f)-1);
   Repeat
   Unlock(f,FilePos(f)*BankSize,BankSize);
   Until DosError=0;
   Close(f);
   NoNetInfoMsg;
   WriteLockBank:=True;
End;



Function TestEmployBankAndLock(TestCod:ArtikulStr):Boolean;
Var f : File Of BankType;
    c : LongInt;
    s : BankType;
Begin
DInfoNetMsg('Блокирую банк с кодом '+TestCod);
TestEmployBankAndLock:=False;
Assign (F,Path^.Dat.ToBank+'Banks.db');
c:=IOResult;
  Reset(f);
  c:=IOResult;
  If c<>0 Then
   Begin
    NoNetInfoMsg;
    MessageBox(^M+#3'Ошибка сетевого открытия справочника банков!',Nil,mfError+mfCancelButton);
    Exit;
   End;
   DelSpace(TestCod);
   c:=StrToInt(testCod);
   Seek(f,c);
   Repeat
   Pause(1);
   Until Lock(f,FilePos(f)*BankSize,BankSize); {предварительная блокировка}

     Read(f,s);

     If s.Locked Then{если позиция кем-то занята}
      Begin
       Seek(f,Filepos(f)-1);
       Repeat
       Unlock(f,FilePos(f)*BankSize,BankSize);
       Until DosError=0;
       NoNetInfoMsg;
       Close(f);
       Exit;
      End;
     if s.employ then {если позиция ужу помечена как используемая}
      begin
       Seek(f,Filepos(f)-1);
       Repeat
        Unlock(f,FilePos(f)*BankSize,BankSize);
       Until DosError=0;
       NoNetInfoMsg;
       Close(f);
       Exit;
      end;
{$IFDEF NetVersion}
      s.Locked:=True;            {проведение вторичной блокировки}
      s.LockCaption:=CurrentPassword;
      s.ComputerNameLocked:=NetComputerName;
{$ENDIF}
      s.Kod:=TestCod;
      Seek(f,Filepos(f)-1);
      Write(f,s);
      Seek(f,Filepos(f)-1);
      Repeat
      Unlock(f,FilePos(f)*BankSize,BankSize);
      Until DosError=0;
      Close(f);
      NoNetInfoMsg;
      TestEmployBankAndLock:=True;
      Exit;
End;
*)







begin

End.