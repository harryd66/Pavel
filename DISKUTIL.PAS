Unit DiskUtil;


Interface

Const MrkSeek=0;
      PrhSeek=1;
      DocSeek=2;
      VksSeek=3;
      RetSeek=4;
      OplSeek=5;
      PrzSeek=6;
      RwzSeek=7;
      IntSeek=8;
      ZakSeek=9;
      DlgSeek=10;
      ZakIDXSeek=11;
      MrkIDXSeek=12;


procedure FlushFile;
Procedure MySeek(Regim:Word;Handler:Integer;Pos:LongInt);
Function MyFileSize(Regim:Word;Handler:Integer):LongInt;
Function GetFileSize(Handler:Integer):LongInt;
Function MyFilePos (Regim:Word;Handler:Integer):LongInt;

Implementation

Uses Dos,FileTool,ServStr,Glob,Serv,Protect,TPDate,MsgBox;


Function MyFileSize(Regim:Word;Handler:Integer):LongInt;
Var c:Integer;
    Res: LongInt;
    Regs: Registers;
Begin
 MyFileSize:=0;
 Res:=fSeek(Handler, 0, fsmEnd);
 c:=IOResult;
 If c<>0 Then
  Begin
   MessageBox(^M#3'Ошибка при определении размера файла Код:'+IntToStr(c,CKol),
   Nil,mfError+mfCancelButton);
   Exit;
  End;
 Case Regim Of
   MrkSeek:Begin
            MyFileSize:=Res div SizeOf(SuperMarketType);
           End;
   PrhSeek:Begin
            MyFileSize:=Res div SizeOf(PrihodType);
           End;
   DocSeek:Begin
            MyFileSize:=Res div SizeOf(DocBazType);
           End;
   VksSeek:Begin
            MyFileSize:=Res div SizeOf(DocBazType);
           End;
   RetSeek:Begin
            MyFileSize:=Res div SizeOf(NewVozwratType);
           End;
   OplSeek:Begin
            MyFileSize:=Res div SizeOf(OplataRealizasiaType);
           End;
   PrzSeek:Begin
            MyFileSize:=Res div SizeOf(CorrectType);
           End;
   RwzSeek:Begin
            MyFileSize:=Res div SizeOf(RewisiaType);
           End;
   IntSeek:Begin
            MyFileSize:=Res div SizeOf(TransportType);
           End;
   ZakSeek:Begin
            MyFileSize:=Res div SizeOf(ZakazType);
           End;

   DlgSeek:Begin
            MyFileSize:=Res div SizeOf(RealizasiaType);
           End;
   ZakIDXSeek:Begin
               MyFileSize:=Res div SizeOf(HeaderZakazType);
              End;
   MrkIDXSeek:Begin
               MyFileSize:=Res div SizeOf(SuperMarketTypeIDX);
              End;



 Else;
 End;{Case}
End;


Function GetFileSize(Handler:Integer):LongInt;
Var c:Integer;
    Res: LongInt;
    Regs: Registers;
Begin
 GetFileSize:=0;
 Res:=fSeek(Handler, 0, fsmEnd);
 c:=IOResult;

 If c<>0 Then
  Begin
   MessageBox(^M#3'Ошибка при определении размера файла Код:'+IntToStr(c,CKol),
   Nil,mfError+mfCancelButton);
   Exit;
  End;
 GetFileSize:=Res;
End;


Procedure MySeek(Regim:Word;Handler:Integer;Pos:LongInt);
Var c:Integer;
Begin
 Case Regim Of
   MrkSeek:Begin
            Pos:=Round(Pos * SizeOf(SuperMarketType));
           End;
   PrhSeek:Begin
            Pos:=Round(Pos * SizeOf(PrihodType));
           End;
   DocSeek:Begin
            Pos:=Round(Pos * SizeOf(DocBazType));
           End;
   VksSeek:Begin
            Pos:=Round(Pos * SizeOf(DocBazType));
           End;
   RetSeek:Begin
            Pos:=Round(Pos * SizeOf(NewVozwratType));
           End;
   OplSeek:Begin
            Pos:=Round(Pos * SizeOf(OplataRealizasiaType));
           End;
   PrzSeek:Begin
            Pos:=Round(Pos * SizeOf(CorrectType));
           End;
   RwzSeek:Begin
            Pos:=Round(Pos * SizeOf(RewisiaType));
           End;
   IntSeek:Begin
            Pos:=Round(Pos * SizeOf(TransportType));
           End;
   ZakSeek:Begin
            Pos:=Round(Pos * SizeOf(ZakazType));
           End;
   DlgSeek:Begin
            Pos:=Round(Pos *SizeOf(RealizasiaType));
           End;
   ZakIDXSeek:Begin
               Pos:=Round(Pos * SizeOf(HeaderZakazType));
              End;
   MrkIDXSeek:Begin
               Pos:=Round(Pos * SizeOf(SuperMarketTypeIDX));
              End;
 Else;
 End;{Case}

 fSeek(Handler, Pos, fsmStart);
 c:=IOResult;
 If c<>0 Then
  Begin
   MessageBox(^M#3'Ошибка при определении размера файла Код:'+IntToStr(c,CKol),
   Nil,mfError+mfCancelButton);
   Exit;
  End;
End;

Function MyFilePos(Regim:Word;Handler:Integer):LongInt;
Var c:Integer;
    Res: LongInt;
    Regs: Registers;
Begin
 MyFilePos:=0;
 Res:=fSeek(Handler, 0, fsmCurrent);
 c:=IOResult;
 If c<>0 Then
  Begin
   MessageBox(^M#3'Ошибка при определении размера файла Код:'+IntToStr(c,CKol),
   Nil,mfError+mfCancelButton);
   Exit;
  End;
 Case Regim Of
   MrkSeek:Begin
            MyFilePos:=Res div SizeOf(SuperMarketType);
           End;
   PrhSeek:Begin
            MyFilePos:=Res div SizeOf(PrihodType);
           End;
   DocSeek:Begin
            MyFilePos:=Res div SizeOf(DocBazType);
           End;
   VksSeek:Begin
            MyFilePos:=Res div SizeOf(DocBazType);
           End;
   RetSeek:Begin
            MyFilePos:=Res div SizeOf(NewVozwratType);
           End;
   OplSeek:Begin
            MyFilePos:=Res div SizeOf(OplataRealizasiaType);
           End;
   PrzSeek:Begin
            MyFilePos:=Res div SizeOf(CorrectType);
           End;
   RwzSeek:Begin
            MyFilePos:=Res div SizeOf(RewisiaType);
           End;
   IntSeek:Begin
            MyFilePos:=Res div SizeOf(TransportType);
           End;
   ZakSeek:Begin
            MyFilePos:=Res div SizeOf(ZakazType);
           End;

   DlgSeek:Begin
            MyFilePos:=Res div SizeOf(RealizasiaType);
           End;
   ZakIDXSeek:Begin
               MyFilePos:=Res div SizeOf(HeaderZakazType);
              End;
   MrkIDXSeek:Begin
               MyFilePos:=Res div SizeOf(SuperMarketTypeIDX);
              End;
 Else;
 End;{Case}

End;



procedure FlushFile; assembler;
asm
     MOV    AH,0DH
     INT    21H
end;



End.