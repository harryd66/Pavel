{$I Compile.INC}
{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}

Unit NetDBEng;


Interface


Uses Glob,ServStr;


Const
       ClientSize={1}SizeOf(ClientType);
       BufClientSize={1}SizeOf(BufClientType);
       OperationSize={1}SizeOf(KassaOperation);
       ItogKassaSize={1}SizeOf(ItogKassa);
       MAkeSize={1}  SizeOf(ClientType);
       SkladSize={1} SizeOf(SkladType);
       IndexSize={1}  SizeOf(IndexType);
       IdSize={1}    SizeOf(BazType);
       MArketSize={1}SizeOf(SuperMarketType);
       RealizSize={1}SizeOf(RealizasiaType);
       PrihodSize={1}SizeOf(PrihodType);
       PrzSize={1}   SizeOf(PereozenkaType);
       OplataSize={1}SizeOf(OplataRealizasiaType);
       ReturnSize={1}SizeOf(NewVozwratType);
      RewisiaSize={1}SizeOf(RewisiaType);
       SkidkaSize={1}SizeOf(SkidkaType);
      OplataBSize={1}SizeOf(OplataBarter);
       BufSkladSize={1}SizeOf(BufSkladType);
       TransportSize={1}SizeOf(TransportType);

{1} Procedure ReadClient(Var F : ClientFileType;Var Element:ClientType );
    Procedure ReadBufClient(Var F : File; Var Element:PBufClientType;Var Count:Word);

{2} Procedure ReadMAke(Var F : ClientFileType; Var Element:ClientType);
{3} Procedure ReadSkladPointer(Var F : SkladFileType;Var Element:PSkladType);
{3} Procedure ReadSklad(Var F : SkladFileType;Var Element:SkladType);
    Procedure ReadBufSklad(Var F : File;Var Element:PBufSkladType;Var Count:Word);

{4} Procedure ReadBazPointer(Var F : BazFileType;Var Element:PBazType);
{4!}Procedure WriteBazPointer(Var F : BazFileType;Var Element:PBazType);
{4} Procedure ReadBaz(Var F : BazFileType;Var Element:BazType);
{5} Procedure ReadPrihod(Var F : PrihodFileType;Var Element:PPrihodType);
{6} Procedure ReadNewVozwrat(Var F : NewVozwratFileType;Var Element:PNewVozwratType);
{7} Procedure ReadMarket(Var F : MarketFileType;Var Element:PSuperMarketType);
{8} Procedure ReadPereozenka(Var F : PereozenkaFileType;Var Element:PPereozenkaType);
{9} Procedure ReadRewisia(Var F : RewisiaFileType;Var Element:PRewisiaType);
{10}Procedure ReadOplata(Var F : OplataRealizasiaFileType;Var Element:OplataRealizasiaType);
    Procedure ReadSkidka(Var F : SkidkaFileType;Var Element:PSkidkaType);
{13}Procedure ReadOplataBarter(Var F : OplataBarterFileType;Var Element:POplataBarter);

{1} Procedure ReadOperation(Var F : OperationFileType;Var Element:KassaOperation );
    Procedure ReadKassa(Var F : ItogKAssaFileType;Var Element:ItogKAssa);

    Procedure GetIndex(Var F : IndexFileType;Var Element:PIndexType);
    Procedure SetIndex(Art:ArtikulStr;Regim:Boolean);

{7} Procedure ReadTransport(Var F : TransportFileType;Var Element:PTransportType);


Implementation


Uses NetCall,Dos,MsgBox;

Procedure ReadClient(Var F : ClientFileType;Var Element:ClientType );
Var IO : Byte;
    Pos:LongInt;
Begin

{$IFDEF NetVersion}
 Pos:=FilePos(f);
 IO:=IOResult;

 Repeat {цикл блокировки}
  Pause(1);
 Until Lock(f,Pos*ClientSize,ClientSize);
{$ENDIF}


{ IO:=IOResult;}

{ IO:=IOResult;}

  Read(f,Element);
{
 IO:=IOResult;

If IO<>0 Then
    MessageBox(^M+#3'(Клиенты) Ошибка чтения файла: '+IntToStr(IO,3),Nil,
    mfError+mfCancelButton);
}

(*
 Repeat {цикл чтения}
  Read(f,Element);
  IO:=IOResult;
  If IO<>0 Then
   Begin
    Seek(f,Pos);
    MessageBox(^M+#3'(Клиенты) Ошибка чтения файла: '+IntToStr(IO,3),Nil,
    mfError+mfCancelButton);
   End;
 Until IO=0;
*)

{$IFDEF NetVersion}
 Repeat
  Unlock(f,(Pos)*ClientSize,ClientSize);
 Until DosError=0;
{$ENDIF}
End;

Procedure ReadMake(Var F : ClientFileType;Var Element:ClientType );
Var IO : Byte;
    Pos:LongInt;
Begin
{$IFDEF NetVersion}
 Pos:=FilePos(f);
 IO:=IOResult;

 Repeat {цикл блокировки}
  Pause(1);
 Until Lock(f,Pos*MAkeSize,MAkeSize);
{$ENDIF}

{ IO:=IOResult;}

  Read(f,Element);
(*
 Repeat {цикл чтения}
  Read(f,Element);
  IO:=IOResult;
  If IO<>0 Then
   Begin
    Seek(f,Pos);
    MessageBox(^M+#3'(Поставщики) Ошибка чтения файла: '+IntToStr(IO,3),Nil,
    mfError+mfCancelButton);
   End;
 Until IO=0;
*)
{$IFDEF NetVersion}
 Repeat
  Unlock(f,(Pos)*MAkeSize,MAkeSize);
 Until DosError=0;
{$ENDIF}
End;


Procedure ReadSkladPointer(Var F : SkladFileType;Var Element:PSkladType);
Var IO : Byte;
    Pos:LongInt;
Begin
{$IFDEF NetVersion}
 Pos:=FilePos(f);
 IO:=IOResult;

 Repeat {цикл блокировки}
  Pause(1);
 Until Lock(f,Pos*SkladSize,SkladSize);
{$ENDIF}
{ IO:=IOResult;}

  Read(f,Element^.DAt);
(*
 Repeat {цикл чтения}
  Read(f,Element^.DAt);
  IO:=IOResult;
  If IO<>0 Then
   Begin
    Seek(f,Pos);
    MessageBox(^M+#3'(Наличие) Ошибка чтения файла: '+IntToStr(IO,3),Nil,
    mfError+mfCancelButton);
   End;
 Until IO=0;
*)

{$IFDEF NetVersion}
 Repeat
  Unlock(f,(Pos)*SkladSize,SkladSize);
 Until DosError=0;
{$ENDIF}
End;


Procedure ReadSklad(Var F : SkladFileType;Var Element:SkladType);
Var IO : Byte;
    Pos:LongInt;
Begin
{$IFDEF NetVersion}
 Pos:=FilePos(f);
 IO:=IOResult;

 Repeat {цикл блокировки}
  Pause(1);
 Until Lock(f,Pos*SkladSize,SkladSize);
{$ENDIF}

{ IO:=IOResult;}

  Read(f,Element);
(*
 Repeat {цикл чтения}
  Read(f,Element);
  IO:=IOResult;
  If IO<>0 Then
   Begin
    Seek(f,Pos);
    MessageBox(^M+#3'(Наличие) Ошибка чтения файла: '+IntToStr(IO,3),Nil,
    mfError+mfCancelButton);
   End;
 Until IO=0;
*)

{$IFDEF NetVersion}
 Repeat
  Unlock(f,(Pos)*SkladSize,SkladSize);
 Until DosError=0;
{$ENDIF}
End;



Procedure ReadBaz(Var F : BazFileType;Var Element:BazType);
Var IO : Byte;
    Pos:LongInt;
Begin
{$IFDEF NetVersion}
 Pos:=FilePos(f);
 IO:=IOResult;

 Repeat {цикл блокировки}
  Pause(1);
 Until Lock(f,Pos*IdSize,IdSize);
{$ENDIF}

{ IO:=IOResult;}

  Read(f,Element);
(*
 Repeat {цикл чтения}
  Read(f,Element);
  IO:=IOResult;
  If IO<>0 Then
   Begin
    Seek(f,Pos);
    MessageBox(^M+#3'(Наименования) Ошибка чтения файла: '+IntToStr(IO,3),Nil,
    mfError+mfCancelButton);
   End;
 Until IO=0;
*)
{$IFDEF NetVersion}
 Repeat
  Unlock(f,(Pos)*IdSize,IdSize);
 Until DosError=0;
{$ENDIF}
End;

Procedure ReadBazPointer(Var F : BazFileType;Var Element:PBazType);
Var IO : Byte;
    Pos:LongInt;
Begin
(*
{$IFDEF NetVersion}
 Pos:=FilePos(f);
 IO:=IOResult;


 Repeat {цикл блокировки}
  Pause(1);
 Until Lock(f,Pos*IdSize,IdSize);
{$ENDIF}

{ IO:=IOResult;}
*)
  Read(f,Element^.DAt);
(*
 Repeat {цикл чтения}
  Read(f,Element^.DAt);
  IO:=IOResult;
  If IO<>0 Then
   Begin
    Seek(f,Pos);
    MessageBox(^M+#3'(Наименования) Ошибка чтения файла: '+IntToStr(IO,3),Nil,
    mfError+mfCancelButton);
   End;
 Until IO=0;
*)
(*
{$IFDEF NetVersion}
 Repeat
  Unlock(f,(Pos)*IdSize,IdSize);
 Until DosError=0;
{$ENDIF}
*)
End;

Procedure WriteBazPointer(Var F : BazFileType;Var Element:PBazType);
Var IO : Byte;
    Pos:LongInt;
Begin
{$IFDEF NetVersion}
 Pos:=FilePos(f);
 IO:=IOResult;
 Repeat {цикл блокировки}
  Pause(1);
 Until Lock(f,Pos*IdSize,IdSize);
{$ENDIF}

{ IO:=IOResult;}

  Write(f,Element^.DAt);

{$IFDEF NetVersion}
 Repeat
  Unlock(f,(Pos)*IdSize,IdSize);
 Until DosError=0;
{$ENDIF}
End;

Procedure ReadPrihod(Var F : PrihodFileType;Var Element:PPrihodType);
Var IO : Byte;
    Pos:LongInt;
Begin
{$IFDEF NetVersion}
 Pos:=FilePos(f);
 IO:=IOResult;

 Repeat {цикл блокировки}
  Pause(1);
 Until Lock(f,Pos*PrihodSize,PrihodSize);
{$ENDIF}

{ IO:=IOResult;}

  Read(f,Element^.DAt);
(*
 Repeat {цикл чтения}
  Read(f,Element^.DAt);
  IO:=IOResult;
  If IO<>0 Then
   Begin
    Seek(f,Pos);
    MessageBox(^M+#3'(Приход) Ошибка чтения файла: '+IntToStr(IO,3),Nil,
    mfError+mfCancelButton);
   End;
 Until IO=0;
*)
{$IFDEF NetVersion}
 Repeat
  Unlock(f,(Pos)*PrihodSize,PrihodSize);
 Until DosError=0;
{$ENDIF}
End;


Procedure ReadMarket(Var F : MarketFileType;Var Element:PSuperMarketType);
Var IO : Byte;
    Pos:LongInt;
Begin
{$IFDEF NetVersion}
 Pos:=FilePos(f);
 IO:=IOResult;

 Repeat {цикл блокировки}
  Pause(1);
 Until Lock(f,Pos*MarketSize,MarketSize);
{$ENDIF}

 IO:=IOResult;
  Read(f,Element^.DAt);
 IO:=IOResult;
If IO<>0 Then
    MessageBox(^M+#3'(Продажа) Ошибка чтения файла: '+IntToStr(IO,3),Nil,
    mfError+mfCancelButton);

(*
 Repeat {цикл чтения}
  Read(f,Element^.DAt);
  IO:=IOResult;
  If IO<>0 Then
   Begin
    Seek(f,Pos);
    MessageBox(^M+#3'(Продажа) Ошибка чтения файла: '+IntToStr(IO,3),Nil,
    mfError+mfCancelButton);
   End;
 Until IO=0;
*)
{$IFDEF NetVersion}
 Repeat
  Unlock(f,(Pos)*MarketSize,MarketSize);
 Until DosError=0;
{$ENDIF}
End;


Procedure ReadNewVozwrat(Var F : NewVozwratFileType;Var Element:PNewVozwratType);
Var IO : Byte;
    Pos:LongInt;
Begin
{$IFDEF NetVersion}
 Pos:=FilePos(f);
 IO:=IOResult;

 Repeat {цикл блокировки}
  Pause(1);
 Until Lock(f,Pos*ReturnSize,ReturnSize);
{$ENDIF}

{ IO:=IOResult;}

  Read(f,Element^.DAt);
(*
 Repeat {цикл чтения}
  Read(f,Element^.DAt);
  IO:=IOResult;
  If IO<>0 Then
   Begin
    Seek(f,Pos);
    MessageBox(^M+#3'(Возврат) Ошибка чтения файла: '+IntToStr(IO,3),Nil,
    mfError+mfCancelButton);
   End;
 Until IO=0;
*)
{$IFDEF NetVersion}
 Repeat
  Unlock(f,(Pos)*ReturnSize,ReturnSize);
 Until DosError=0;
{$ENDIF}

End;


Procedure ReadPereozenka(Var F : PereozenkaFileType;Var Element:PPereozenkaType);
Var IO : Byte;
    Pos:LongInt;
Begin
{$IFDEF NetVersion}
 Pos:=FilePos(f);
 IO:=IOResult;

 Repeat {цикл блокировки}
  Pause(1);
 Until Lock(f,Pos*PrzSize,PrzSize);
{$ENDIF}

{ IO:=IOResult;}

  Read(f,Element^.DAt);

(*
 Repeat {цикл чтения}
  Read(f,Element^.DAt);
  IO:=IOResult;
  If IO<>0 Then
   Begin
    Seek(f,Pos);
    MessageBox(^M+#3'(Переоценка) Ошибка чтения файла: '+IntToStr(IO,3),Nil,
    mfError+mfCancelButton);
   End;
 Until IO=0;
*)

{$IFDEF NetVersion}
 Repeat
  Unlock(f,(Pos)*PrzSize,PrzSize);
 Until DosError=0;
{$ENDIF}
End;


Procedure ReadRewisia(Var F : RewisiaFileType;Var Element:PRewisiaType);
Var IO : Byte;
    Pos:LongInt;
Begin
{$IFDEF NetVersion}
 Pos:=FilePos(f);
 IO:=IOResult;

 Repeat {цикл блокировки}
  Pause(1);
 Until Lock(f,Pos*RewisiaSize,RewisiaSize);
{$ENDIF}

{ IO:=IOResult;}
  Read(f,Element^.DAt);

(*
 Repeat {цикл чтения}
  Read(f,Element^.DAt);
  IO:=IOResult;
  If IO<>0 Then
   Begin
    Seek(f,Pos);
    MessageBox(^M+#3'(Ревизия) Ошибка чтения файла: '+IntToStr(IO,3),Nil,
    mfError+mfCancelButton);
   End;
 Until IO=0;
*)

{$IFDEF NetVersion}
 Repeat
  Unlock(f,(Pos)*RewisiaSize,RewisiaSize);
 Until DosError=0;
{$ENDIF}
End;

Procedure ReadOplata(Var F : OplataRealizasiaFileType;Var Element:OplataRealizasiaType);
Var IO : Byte;
    Pos:LongInt;
Begin
{$IFDEF NetVersion}
 Pos:=FilePos(f);
 IO:=IOResult;

 Repeat {цикл блокировки}
  Pause(1);
 Until Lock(f,Pos*OplataSize,OplataSize);
{$ENDIF}

{ IO:=IOResult;}

  Read(f,Element);
(*
 Repeat {цикл чтения}
  Read(f,Element);
  IO:=IOResult;
  If IO<>0 Then
   Begin
    Seek(f,Pos);
    MessageBox(^M+#3'(Оплата реализации) Ошибка чтения файла: '+IntToStr(IO,3),Nil,
    mfError+mfCancelButton);
   End;
 Until IO=0;
*)
{$IFDEF NetVersion}
 Repeat
  Unlock(f,(Pos)*OplataSize,OplataSize);
 Until DosError=0;
{$ENDIF}
End;

Procedure ReadSkidka(Var F : SkidkaFileType;Var Element:PSkidkaType);
Var IO : Byte;
    Pos:LongInt;
Begin
{$IFDEF NetVersion}
 Pos:=FilePos(f);
 IO:=IOResult;

 Repeat {цикл блокировки}
  Pause(1);
 Until Lock(f,Pos*SkidkaSize,SkidkaSize);
{$ENDIF}

{ IO:=IOResult;}

  Read(f,Element^.Dat);
(*
 Repeat {цикл чтения}
  Read(f,Element^.Dat);
  IO:=IOResult;
  If IO<>0 Then
   Begin
    Seek(f,Pos);
    MessageBox(^M+#3'(Оплата реализации) Ошибка чтения файла: '+IntToStr(IO,3),Nil,
    mfError+mfCancelButton);
   End;
 Until IO=0;
*)

{$IFDEF NetVersion}
 Repeat
  Unlock(f,(Pos)*SkidkaSize,SkidkaSize);
 Until DosError=0;
{$ENDIF}
End;

Procedure ReadBufClient(Var F : File; Var Element:PBufClientType;Var Count:Word);
Var IO : Byte;
    Pos:LongInt;
Begin

Count:=0;
Pos:=FilePos(f);
 IO:=IOResult;
 BlockRead(f,Element^.Point,{SizeOf(Element)}Buffer,Count);
{Pos:=FilePos(f);}
 IO:=IOResult;
If IO<>0 Then
Begin
{$IFDEF NetVersion}
 Seek(f,Pos);
 IO:=IOResult;
{Pos:=FilePos(f); до оптимизации была}
 IO:=IOResult;

 Repeat {цикл блокировки}
  Pause(1);
 Until Lock(f,Pos*ClientSize,BufClientSize);
{$ENDIF}

 BlockRead(f,Element^.Point,{SizeOf(Element)}Buffer,Count);

{$IFDEF NetVersion}
 Repeat
  Unlock(f,(Pos)*ClientSize,BufClientSize);
 Until DosError=0;
{$ENDIF}
 IO:=IOResult;
End;
End;


Procedure ReadOplataBarter(Var F : OplataBarterFileType;Var Element:POplataBarter);
Var IO : Byte;
    Pos:LongInt;
Begin
{$IFDEF NetVersion}
 Pos:=FilePos(f);
 IO:=IOResult;

 Repeat {цикл блокировки}
  Pause(1);
 Until Lock(f,Pos*OplataBSize,OplataBSize);
{$ENDIF}

{ IO:=IOResult;}

  Read(f,Element^.Dat);
(*
 Repeat {цикл чтения}
  Read(f,Element);
  IO:=IOResult;
  If IO<>0 Then
   Begin
    Seek(f,Pos);
    MessageBox(^M+#3'(Оплата реализации) Ошибка чтения файла: '+IntToStr(IO,3),Nil,
    mfError+mfCancelButton);
   End;
 Until IO=0;
*)
{$IFDEF NetVersion}
 Repeat
  Unlock(f,(Pos)*OplataBSize,OplataBSize);
 Until DosError=0;
{$ENDIF}
End;

Procedure ReadOperation(Var F : OperationFileType;Var Element:KassaOperation );
Var IO : Byte;
    Pos:LongInt;
Begin
Pos:=FilePos(f);
 IO:=IOResult;
Read(f,Element);
 IO:=IOResult;
If IO<>0 Then
Begin
{$IFDEF NetVersion}
 Seek(f,Pos);
 IO:=IOResult;
{Pos:=FilePos(f); до оптимизации была}
 IO:=IOResult;

 Repeat {цикл блокировки}
  Pause(1);
 Until Lock(f,Pos*OperationSize,OperationSize);
{$ENDIF}

  Read(f,Element);

{$IFDEF NetVersion}
 Repeat
  Unlock(f,(Pos)*OperationSize,OperationSize);
 Until DosError=0;
{$ENDIF}
 IO:=IOResult;
End;
End;


Procedure ReadKassa(Var F : ItogKAssaFileType;Var Element:ItogKAssa);
Var IO : Byte;
    Pos:LongInt;
Begin
Pos:=FilePos(f);
 IO:=IOResult;
Read(f,Element);
 IO:=IOResult;
If IO<>0 Then
Begin
{$IFDEF NetVersion}
 Seek(f,Pos);
 IO:=IOResult;
{Pos:=FilePos(f); до оптимизации была}
 IO:=IOResult;

 Repeat {цикл блокировки}
  Pause(1);
 Until Lock(f,Pos*ItogKAssaSize,ItogKAssaSize);
{$ENDIF}

  Read(f,Element);

{$IFDEF NetVersion}
 Repeat
  Unlock(f,(Pos)*ItogKAssaSize,ItogKAssaSize);
 Until DosError=0;
{$ENDIF}
 IO:=IOResult;
End;
End;


Procedure GetIndex(Var F : IndexFileType;Var Element:PIndexType);
Var Pos : LongInt;
    IO  : Word;
Begin
 Pos:=0;
{$IFDEF NetVersion}
 IO:=IOResult;
 Repeat {цикл блокировки}
  Pause(1);
 Until Lock(f,Pos*IndexSize,IndexSize);
{$ENDIF}

  Read(f,Element^.Dat);

{$IFDEF NetVersion}
 Repeat
  Unlock(f,(Pos)*IndexSize,IndexSize);
 Until DosError=0;
{$ENDIF}
 IO:=IOResult;
End;

Procedure SetIndex(Art:ArtikulStr;Regim:Boolean);
Var Pos : LongInt;
    IO  : Word;
    IndexFile : IndexFileType;
    Element : PIndexType;
Begin
 Assign(IndexFile,Path.ToRazdel+Copy(Art,1,CRazdelKod)+'.idx');
 IO:=IoResult;
 Reset(IndexFile);
 IO:=IoResult;
 If IO<>0 Then
  Begin
   MessageBox(^M+#3'Ошибка открытия '+Path.ToRazdel+Copy(Art,1,CRazdelKod)+'.idx'+
   ClicProgrammer,Nil,mfError+mfCancelButton);
   Exit;
  End;

 New(Element,Init);{создаем экземпляр объекта}
 Pos:=0;
{$IFDEF NetVersion}
 IO:=IOResult;
 Repeat {цикл блокировки}
  Pause(1);
 Until Lock(IndexFile,Pos*IndexSize,IndexSize);
{$ENDIF}

  Read(IndexFile,Element^.Dat);
  Element^.DAt.Present[StrToInt(Copy(Art,1+CRAzdelKod,CKod))]:=Regim;
  Seek(IndexFile,0);
  Write(IndexFile,Element^.Dat);
  IO:=IOResult;

{$IFDEF NetVersion}
 Repeat
  Unlock(IndexFile,(Pos)*IndexSize,IndexSize);
 Until DosError=0;
{$ENDIF}
 IO:=IOResult;
 System.Close(IndexFile);
 Dispose(Element,Done);
End;


Procedure ReadBufSklad(Var F : File;Var Element:PBufSkladType;Var Count:Word);
Var IO : Byte;
    Pos:LongInt;
Begin
Count:=0;
Pos:=FilePos(f);
 IO:=IOResult;
 BlockRead(f,Element^.Point,BufferDB,Count);
 {Read(f,Element);}
 IO:=IOResult;
If IO<>0 Then
Begin
{$IFDEF NetVersion}
 Seek(f,Pos);
 IO:=IOResult;
{Pos:=FilePos(f); до оптимизации была}
 IO:=IOResult;

 Repeat {цикл блокировки}
  Pause(1);
 Until Lock(f,Pos*SkladSize,BufSkladSize);
{$ENDIF}
  {Read(f,Element);}
  BlockRead(f,Element^.Point,BufferDB,Count);
{$IFDEF NetVersion}
 Repeat
  Unlock(f,(Pos)*SkladSize,BufSkladSize);
 Until DosError=0;
{$ENDIF}
End;
 IO:=IOResult;
End;


Procedure ReadTransport(Var F : TransportFileType;Var Element:PTransportType);
Var IO : Byte;
    Pos:LongInt;
Begin
Pos:=FilePos(f);
 IO:=IOResult;
Read(f,Element^.Dat);
 IO:=IOResult;
If IO<>0 Then
Begin
{$IFDEF NetVersion}
 Seek(f,Pos);
 IO:=IOResult;

 Repeat {цикл блокировки}
  Pause(1);
 Until Lock(f,Pos*TransportSize,TransportSize);
{$ENDIF}

  Read(f,Element^.Dat);

 IO:=IOResult;
If IO<>0 Then
    MessageBox(^M+#3'(Перемещение) Ошибка чтения файла: '+IntToStr(IO,3),Nil,
    mfError+mfCancelButton);

{$IFDEF NetVersion}
 Repeat
  Unlock(f,(Pos)*TransportSize,TransportSize);
 Until DosError=0;
{$ENDIF}
End;
 IO:=IOResult;

End;



End.