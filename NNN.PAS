




Procedure CreatIDX;
VAr sklFile : File Of SkladType;
    skl : pSkladType;
    RazdelFile : File Of RazdelType;
    RazdelElement : RazdelType;
    IndexFile : IndexFileType;
    Index : PIndexType;

    IndexFileNew : File Of SkladTypeNew;
    Indexnew : PSkladTypenew;

    F : Boolean;
    c : Word;
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

c:=IOResult;
Assign(IndexFileNew,Path^.Dat.ToIndex+RazdelElement.Kod+'.kdx');
Rewrite(IndexFileNew);
c:=IOResult;
If c<>0 Then
 Begin
  Close(RazdelFile);
  Close(SklFile);
  Close(IndexFile);
  NoInfo;
  MessageBox(^M+#3'Ошибка создания файла индексов '+Path^.Dat.ToIndex+RazdelElement.Kod+'.kdx'+'!',Nil,
  mfError+mfCancelButton);
  Exit;
 End;

   New(Skl,Init);
   New(Index,Init);
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

     IndexNew^.Dat.Name :=GetIdField(FName,Skl^.Dat.BazKod);
     IndexNew^.Dat.Name2:=GetIdField(FName2,Skl^.Dat.BazKod);
     IndexNew^.Dat.Virabotano :=DateStringToDate(DateMask,Skl^.Dat.input.Virabotano);
     IndexNew^.Dat.EnableSklads:=StrToInt(GetIdField(FEnableSklads,Skl^.DAt.BAzKod));
     IndexNew^.Dat.Employ :=Skl^.DAt.Employ;
     IndexNew^.Dat.NSertif :=StrToInt(Skl^.DAt.Input.NSertif);
     For j:=1 To CDivision Do IndexNew^.Dat.Division[j]:=StrToInt(Skl^.Dat.Input.Division[j]);
     For j:=1 To CDivision Do IndexNew^.Dat.DivisionR[j]:=StrToInt(Skl^.Dat.Input.DivisionR[j]);
     IndexNew^.Dat.R_Zena  :=StrToreal(Skl^.Dat.Input.R_Zena);
     IndexNew^.Dat.RegionMarka:=Skl^.Dat.Input.RegionMarka;
     IndexNew^.Dat.BazKod:=StrToInt(Skl^.Dat.BazKod);
     IndexNew^.Dat.Kol:=StrToInt(Skl^.Dat.Input.Kol);
     IndexNew^.Dat.StrihKod:=Skl^.Dat.Input.StrihKod;
     IndexNew^.Dat.NMakeKod:=StrToInt(Skl^.Dat.Input.NMakeKod);
     IndexNew^.Dat.NGroupKod:=StrToInt(Skl^.Dat.Input.NGroupKod);


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
   Write(IndexFile,Index^.Dat);
   Close(IndexFile);
   Close(IndexFileNew);
   Dispose(IndexNew,Done);
   Dispose(Index,Done);
   NoInfo;
   End;
 End;
Close(RazdelFile);
MessageBox(^M+#3'Переиндексация завершена!',Nil,mfInformation+mfCancelButton);
End;
