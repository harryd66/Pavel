Unit ReplAgnt;

INTERFACE

Uses Glob, ServStr,Objects, Net2, Utils3,Dialogs,Drivers,
     App,ColorTxt,Views,MyCalc;


procedure FindInMail;
{Проверяет каталог входящей почты и обрабатывает
нахлдящиеся там сообщения}

function OtvetFullPreview(Ass : DocumentEditZ):boolean;
{Определяет статус заказа и возвращает false при <>5 (подтверждение)
иначе выводит свое окно просмотра}

function ExClMail:boolean;
{Запуск T-Mail и обработка }

function SendCLMail(AS:DocumentEditZ):boolean;
{формирует документ подлежащий отправке по T-Mail}

Function SetPodpis(AS:DocumentEditZ;p:word):boolean;
{Меняет статус заказа с текущего на p }


procedure Replication;



IMPLEMENTATION

Uses NetDbEng,TPDate,Utils5,Memory,Dos,MsgBox,Utils11,
     Serv,Mail,Net1,ServStr2,DBEngine,StHolder,Hex,
     Utils1,Utils,Access1;


TYPE
  PZView = ^TZView;
  TZView = object(TDialog)
    Calc        : PMyCalculator;
    ControlFull : PBox;
   constructor Init(Const P:PBox;Const s,s1,ws,s2,s3,s4:TMyString;SDoc:ArtikulStr;SDate:TDateString;
                          t:Byte);
   procedure HandleEvent(var Event: TEvent); virtual;
   destructor Done; virtual;
   procedure OpenViewWindow;
  end;



const NadoRefresh = '!!!ОБНОВИТЕ СПРАВОЧНИКИ!!!';

var FList: PBox;
    Control:PView;
    ZView: PZView;
    TestFile : File;


function CopyFileWithList(const E:PBox;msg:string):word;
var i: word;
    s: string;
Begin
CopyFileWithList:=100;
if (E<>nil) and (E^.List^.Count>0) then
Begin
  for i:=0 to E^.List^.Count-1 do
  begin
  s:=E^.GetText(i,E^.List^.Count);
  DInfoMSgShkala(msg+Copy(s,8,40),0,E^.List^.Count-1,i);
  DoneSysError;
  DoneEvents;
  Application^.HideCursor;
  DoneDosMem;
  SwapVectors;

  Exec(GetEnv('Comspec'),' /c '+s+NullStr^);

  SwapVectors;
  InitDosMem;
  InitEvents;
  InitSysError;
  CursorLines:=1543;
  Application^.Redraw;
  NoInfoMsg;
  Case DosError Of
    2:MessageBox(#3^M+#3'Файл не найден !',Nil,mfError+mfCancelButton);
    3:MessageBox(#3^M+#3'Путь не найден !',Nil,mfError+mfCancelButton);
    5:MessageBox(#3^M+#3'Доступ невозможен !',Nil,mfError+mfCancelButton);
    6:MessageBox(#3^M+#3'Неверное устройство !',Nil,mfError+mfCancelButton);
    8:MessageBox(#3^M+#3'Недостаточно памяти !',Nil,mfError+mfCancelButton);
   10:MessageBox(#3^M+#3'Неверные настройки !',Nil,mfError+mfCancelButton);
   11:MessageBox(#3^M+#3'Неверный формат !',Nil,mfError+mfCancelButton);
   18:MessageBox(#3^M+#3'Слишком много файлов !',Nil,mfError+mfCancelButton);
  Else;
  End;
  CopyFileWithList:=DosError;
  End;
End;
NoInfoMsg;
End;



Procedure ClearLockName;
Label 1;
var DirInfo:SearchRec;
    flck: File of LockBazType;
    lck: LockBazType;
    IORez: word;
    r:RazdelType;
    fr : File Of RazdelType;
    Skl : SkladType;
    fdb : SkladFileType;
    Kdx : SkladTypeNew;
    Fkdx : File Of SkladTypeNew;
Begin
  Assign(fr,Path^.Dat.ToRazdel+'razdel.db');
  IORez:=IoResult;
  Reset(fr);
  IORez:=IoResult;
  While Not(Eof(fr)) Do
  Begin
   Read(fr,r);
   DinfoMsgShkala('Снимаю блокировку с раздела ',0,MaxStatRazdel,StrToInt(R.Kod));
   If r.Employ Then
    Begin
    Assign(flck,Path^.Dat.ToName+r.kod+'.lck');
    IOrez:=ioresult;
    reset(flck);
    IOrez:=ioresult;
    If IORez<>0 Then Goto 1;
     while not eof(flck) do
     begin
      read(flck,lck);
      if lck.Locked then
      begin
        lck.locked:=false;
        IOrez:=ioresult;
        seek(flck,FilePos(flck)-1);
        IOrez:=ioresult;
        write(flck,lck);
        IOrez:=ioresult;
      end;
     end;{While}
    IOrez:=ioresult;
    close(flck);
    IOrez:=ioresult;


1:

If EnableZakupka<>1 Then
Begin
    Assign(fdb,Path^.Dat.ToSklad+r.kod+'.db');
    IOrez:=ioresult;
    reset(fdb);
    IOrez:=ioresult;

   If IORez=0 Then
   Begin
     while not eof(fdb) do
     begin
        read(fdb,Skl);
        If Skl.Employ Then
        Begin
        { убрано 10/01/2006 из-за включения механизма
          контроля цен от закупки
        Skl.Input.Zakupka[0]:=#0;
        Skl.Input.Zakupka2[0]:=#0;
        }
        IOrez:=ioresult;
        seek(fdb,FilePos(fdb)-1);
        IOrez:=ioresult;
        write(fdb,Skl);
        IOrez:=ioresult;
        End;
     end;{While}
     IOrez:=ioresult;
     close(fdb);
     IOrez:=ioresult;
   End;{IORez=0}

    Assign(fkdx,Path^.Dat.ToIndex+r.kod+'.kdx');
    IOrez:=ioresult;
    reset(fkdx);
    IOrez:=ioresult;

   If IORez=0 Then
   Begin
     while not eof(fkdx) do
     begin
        read(fkdx,Kdx);
        If Kdx.Employ Then
        Begin
        { убрано 10/01/2006 из-за включения механизма
          контроля цен от закупки
        Kdx.Zakupka:=0;
        Kdx.Zakupka2:=0;
        }
        IOrez:=ioresult;
        seek(fkdx,FilePos(fkdx)-1);
        IOrez:=ioresult;
        write(fkdx,Kdx);
        IOrez:=ioresult;
        End;
     end;{While}
     IOrez:=ioresult;
     close(fKdx);
     IOrez:=ioresult;
   End;{IORez=0}



End;{EnableZakupka}




    End;{R.Employ}
  End;{While}

  IOrez:=ioresult;
  close(fr);
  IOrez:=ioresult;
  NoInfoMsg;
End;


Procedure EraseFile(ss:String);
Var c : Word;
    f : File;
Begin
Assign(f,ss);
c:=IoResult;
Erase(f);
c:=IoResult;
If c<>0 Then
 MessageBox(#3^M+#3+ss+' - ошибка удаления код: '+IntToStr(c,CKol),Nil,mfError+mfCancelButton);
End;



Function ClientExtendedMarka(SArt:ArtikulStr):Boolean;
Var c1,c,k,r : Word;
    s,stRazd: ArtikulStr;
    Max : LongInt;
    Eb  : MarkaFileType;
    bb  : PMarkaType;
    Maximum : LongInt;
Begin

Maximum:=0;

ClientExtendedMarka:=True;

{расчитываем максимальные позиции в разделах}
  If MAximum<StrToInt(SArt) Then Maximum:=StrToInt(SArt);


DInfoMsg('Проверяю размерность базы акц.марок...',True);

  Assign(Eb,Path^.Dat.ToSPR+'marka.db');
  k:=IOResult;
  Reset(Eb);
  k:=IOResult;
  If k<>0 Then
  Begin
   NoInfoMsg;
   MessageBox(^M+#3'Ошибка открытия файла акц.марок!'^M+
   +#3' Код: '+IntToStr(k,CLitrMantissa)+'. '+ClicProgrammer^,nil,mfError+mfCancelButton);
   ClientExtendedMarka:=False;
   Exit;
  End;

  Max:=FileSize(Eb);
  k:=IOResult;
  Close(Eb);
  k:=IOResult;

  If (Maximum+1)>(Max) Then
   Begin

         r:=Ioresult;
         Reset(Eb);
         r:=Ioresult;

         If r=0 Then
         Begin
          Seek(Eb,FileSize(Eb));
          New(bb,Init);
          For k:=1 To (Maximum-MAx) Do
                Begin
                 Str(k+MAx-1:5,S);
                 RFormatZerro(s,CArtikul);
                 bb^.Dat.Kod:=s;
                 bb^.Dat.Employ:=False;
                 Seek(eb,FileSize(eb));
                 Write(eb,bb^.Dat);
                End;
          Str(k+MAx-1:5,S);
          RFormatZerro(s,CArtikul);
          bb^.Dat.Kod:=s;
          bb^.Dat.Employ:=True;
          bb^.Dat.Marka:=NadoRefresh;
          Seek(eb,FileSize(eb));
          Write(eb,bb^.Dat);

          Dispose(bb,Done);
          r:=Ioresult;
          Close(Eb);
          r:=Ioresult;
         End{If}
          Else
                Begin
                 NoInfoMsg;
                 ClientExtendedMarka:=False;
                 MessageBox(^M+#3'Ошибка открытия файла акц.марок Код: '+
                          IntToStr(r,CLitrMantissa)
                 ,Nil,mfError+mfCancelButton);
                 Exit;
                End;{Else}
     End
     else
     Begin
       r:=Ioresult;
       Reset(Eb);
       r:=Ioresult;
       k:=IOResult;
       Seek(Eb,MAximum);
       k:=IOResult;
       New(bb,Init);
       read(Eb,bb^.Dat);
       k:=IOResult;
       if not bb^.Dat.Employ  then
         begin
          bb^.Dat.Employ:=True;
          bb^.Dat.Marka:=NadoRefresh;
          Seek(eb,FilePos(eb)-1);
          Write(eb,bb^.Dat);
         end;
       dispose(bb,Done);
       close(eb);
     End;

NoInfoMsg;
ClientExtendedMarka:=True;
End;{Procedure}

Function ClientExtendedSpecMarka(SArt : ArtikulStr):Boolean;
Var c1,c,k,r : Word;
    s,stRazd: ArtikulStr;
    Max : LongInt;
    Eb  : SpecMarkaFileType;
    bb  : PSpecMarkaType;
    Maximum : LongInt;
Begin
Maximum:=0;
ClientExtendedSpecMarka:=True;

  If MAximum<StrToInt(SArt) Then Maximum:=StrToInt(SArt);


DInfoMsg('Проверяю размерность базы спец.марок...',True);

  Assign(Eb,Path^.Dat.ToSPR+'SMarka.db');
  k:=IOResult;
  Reset(Eb);
  k:=IOResult;
  If k<>0 Then
  Begin
   NoInfoMsg;
   MessageBox(^M+#3'Ошибка открытия файла с.марок!'^M+
   +#3' Код: '+IntToStr(k,CLitrMantissa)+'. '+ClicProgrammer^,nil,mfError+mfCancelButton);
   ClientExtendedSpecMarka:=False;
   Exit;
  End;

  Max:=FileSize(Eb);
  k:=IOResult;
  Close(Eb);
  k:=IOResult;

  If (Maximum+1)>(Max) Then
   Begin
         r:=Ioresult;
         Reset(Eb);
         r:=Ioresult;

         If r=0 Then
         Begin
          Seek(Eb,FileSize(Eb));
          New(bb,Init);
          For k:=1 To (Maximum-MAx) Do
                Begin
                 Str(k+MAx-1:5,S);
                 RFormatZerro(s,CArtikul);
                 bb^.Dat.Kod:=s;
                 bb^.Dat.Employ:=False;
                 Seek(eb,FileSize(eb));
                 Write(eb,bb^.Dat);
                End;

          Str(k+MAx-1:5,S);
          RFormatZerro(s,CArtikul);
          bb^.Dat.Kod:=s;
          bb^.Dat.Employ:=False;
          bb^.Dat.SpecMarka:=NadoRefresh;
          Seek(eb,FileSize(eb));
          Write(eb,bb^.Dat);

          Dispose(bb,Done);
          r:=Ioresult;
          Close(Eb);
          r:=Ioresult;
         End{If}
          Else
                Begin
                 NoInfoMsg;
                 ClientExtendedSpecMarka:=False;
                 MessageBox(^M+#3'Ошибка открытия файла cпец.марок Код: '+
                          IntToStr(r,CLitrMantissa)
                 ,Nil,mfError+mfCancelButton);
                 Exit;
                End;{Else}
     End
     else
     Begin
       r:=Ioresult;
       Reset(Eb);
       r:=Ioresult;
       k:=IOResult;
       Seek(Eb,MAximum);
       k:=IOResult;
       New(bb,Init);
       read(Eb,bb^.Dat);
       k:=IOResult;
       if not bb^.Dat.Employ  then
         begin
          bb^.Dat.Employ:=True;
          bb^.Dat.SpecMarka:=NadoRefresh;
          Seek(eb,FilePos(eb)-1);
          Write(eb,bb^.Dat);
         end;
       dispose(bb,Done);
       close(eb);
     End;


NoInfoMsg;
ClientExtendedSpecMarka:=True;
End;{Procedure}


Function ClientExtendedExpert(SArt : ArtikulStr):Boolean;
Var c1,c,k,r : Word;
    s,stRazd: ArtikulStr;
    Max : LongInt;
    Eb  : ExpertFileType;
    bb  : PExpertType;
    Maximum : LongInt;
Begin
Maximum:=0;
ClientExtendedExpert:=True;

{расчитываем максимальные позиции в разделах}
  If MAximum<StrToInt(SArt) Then Maximum:=StrToInt(SArt);


DInfoMsg('Проверяю размерность базы экспертных заключений...',True);

  Assign(Eb,Path^.Dat.ToSPR+'Expert.db');
  k:=IOResult;
  Reset(Eb);
  k:=IOResult;
  If k<>0 Then
  Begin
   NoInfoMsg;
   MessageBox(^M+#3'Ошибка открытия файла э.заключений!'^M+
   +#3' Код: '+IntToStr(k,CLitrMantissa)+'. '+ClicProgrammer^,nil,mfError+mfCancelButton);
   ClientExtendedExpert:=False;
   Exit;
  End;

  Max:=FileSize(Eb);
  k:=IOResult;
  Close(Eb);
  k:=IOResult;

  If (Maximum+1)>(Max) Then
   Begin
         r:=Ioresult;
         Reset(Eb);
         r:=Ioresult;

         If r=0 Then
         Begin
          Seek(Eb,FileSize(Eb));
          New(bb,Init);
          For k:=1 To (Maximum-MAx) Do
                Begin
                 Str(k+MAx-1:5,S);
                 RFormatZerro(s,CArtikul);
                 bb^.Dat.Kod:=s;
                 bb^.Dat.Employ:=False;
                 Seek(eb,FileSize(eb));
                 Write(eb,bb^.Dat);
                End;
          Str(k+MAx-1:5,S);
          RFormatZerro(s,CArtikul);
          bb^.Dat.Kod:=s;
          bb^.Dat.Employ:=true;
          bb^.Dat.Expert:=NadoRefresh;
          Seek(eb,FileSize(eb));
          Write(eb,bb^.Dat);
          Dispose(bb,Done);
          r:=Ioresult;
          Close(Eb);
          r:=Ioresult;
         End{If}
          Else
                Begin
                 NoInfoMsg;
                 ClientExtendedExpert:=False;
                 MessageBox(^M+#3'Ошибка открытия файла эксп.заключений Код: '+
                          IntToStr(r,CLitrMantissa)
                 ,Nil,mfError+mfCancelButton);
                 Exit;
                End;{Else}
     End
     else
     Begin
       r:=Ioresult;
       Reset(Eb);
       r:=Ioresult;
       k:=IOResult;
       Seek(Eb,MAximum);
       k:=IOResult;
       New(bb,Init);
       read(Eb,bb^.Dat);
       k:=IOResult;
       if not bb^.Dat.Employ  then
         begin
          bb^.Dat.Employ:=True;
          bb^.Dat.Expert:=NadoRefresh;
          Seek(eb,FilePos(eb)-1);
          Write(eb,bb^.Dat);
         end;
       dispose(bb,Done);
       close(eb);
     End;


NoInfoMsg;
ClientExtendedExpert:=True;
End;{Procedure}

Function ClientExtendedFirmaPost(SArt : ArtikulStr):Boolean;
Var c1,c,k,r : Word;
    s,stRazd: ArtikulStr;
    Max : LongInt;
    Eb  : FirmaPostFileType;
    bb  : PFirmaPostType;
    Maximum : LongInt;
Begin

Maximum:=0;

ClientExtendedFirmaPost:=True;

{расчитываем максимальные позиции в разделах}
If MAximum<StrToInt(SArt) Then Maximum:=StrToInt(SArt);

DInfoMsg('Проверяю размерность базы фирм-производителей...',True);

  Assign(Eb,Path^.Dat.ToSPR+'firma.db');
  k:=IOResult;
  Reset(Eb);
  k:=IOResult;
  If k<>0 Then
  Begin
   NoInfoMsg;
   MessageBox(^M+#3'Ошибка открытия файла фирм!'^M+
   +#3' Код: '+IntToStr(k,CLitrMantissa)+'. '+ClicProgrammer^,nil,mfError+mfCancelButton);
   ClientExtendedFirmaPost:=False;
   Exit;
  End;

  Max:=FileSize(Eb);
  k:=IOResult;
  Close(Eb);
  k:=IOResult;

  If (Maximum+1)>(Max) Then
   Begin

         r:=Ioresult;
         Reset(Eb);
         r:=Ioresult;

         If r=0 Then
         Begin
          Seek(Eb,FileSize(Eb));
          New(bb,Init);
          For k:=1 To (Maximum-MAx) Do
                Begin
                 Str(k+MAx-1:4,S);
                 RFormatZerro(s,CClientKod);
                 bb^.Dat.Kod:=s;
                 bb^.Dat.Employ:=False;
                 Seek(eb,FileSize(eb));
                 Write(eb,bb^.Dat);
                End;
          Str(k+MAx-1:4,S);
          RFormatZerro(s,CClientKod);
          bb^.Dat.Kod:=s;
          bb^.Dat.Employ:=true;
          bb^.Dat.FirmaPost:=NadoRefresh;
          Seek(eb,FileSize(eb));
          Write(eb,bb^.Dat);

          Dispose(bb,Done);
          r:=Ioresult;
          Close(Eb);
          r:=Ioresult;
         End{If}
          Else
                Begin
                 NoInfoMsg;
                 ClientExtendedFirmaPost:=False;
                 MessageBox(^M+#3'Ошибка открытия файла фирм Код: '+
                          IntToStr(r,CLitrMantissa)
                 ,Nil,mfError+mfCancelButton);
                 Exit;
                End;{Else}
     End
     else
     Begin
       r:=Ioresult;
       Reset(Eb);
       r:=Ioresult;
       k:=IOResult;
       Seek(Eb,MAximum);
       k:=IOResult;
       New(bb,Init);
       read(Eb,bb^.Dat);
       k:=IOResult;
       if not bb^.Dat.Employ  then
         begin
          bb^.Dat.Employ:=True;
          bb^.Dat.FirmaPost:=NadoRefresh;
          Seek(eb,FilePos(eb)-1);
          Write(eb,bb^.Dat);
         end;
       dispose(bb,Done);
       close(eb);
     End;


NoInfoMsg;
ClientExtendedFirmaPost:=True;
End;{Procedure}

Function ClientExtendedNGTD(SArt : ArtikulStr):Boolean;
Var c1,c,k,r : Word;
    s,stRazd : ArtikulStr;
    Max : LongInt;
    Eb  : NGTDFileType;
    bb  : PNGTDType;
    Maximum : LongInt;
Begin

Maximum:=0;

ClientExtendedNGTD:=True;

If MAximum<StrToInt(SArt) Then Maximum:=StrToInt(SArt);

DInfoMsg('Проверяю размерность базы ГТД...',True);

  Assign(Eb,Path^.Dat.ToSPR+'NGTD.db');
  k:=IOResult;
  Reset(Eb);
  k:=IOResult;
  If k<>0 Then
  Begin
   NoInfoMsg;
   MessageBox(^M+#3'Ошибка открытия файла ГТД!'^M+
   +#3' Код: '+IntToStr(k,CLitrMantissa)+'. '+ClicProgrammer^,nil,mfError+mfCancelButton);
   ClientExtendedNGTD:=False;
   Exit;
  End;

  Max:=FileSize(Eb);
  k:=IOResult;
  Close(Eb);
  k:=IOResult;

  If (Maximum+1)>(Max) Then
   Begin

         r:=Ioresult;
         Reset(Eb);
         r:=Ioresult;

         If r=0 Then
         Begin
          Seek(Eb,FileSize(Eb));
          New(bb,Init);
          For k:=1 To (Maximum-MAx) Do
                Begin
                 Str(k+MAx-1:5,S);
                 RFormatZerro(s,CArtikul);
                 bb^.Dat.Kod:=s;
                 bb^.Dat.Employ:=False;
                 Seek(eb,FileSize(eb));
                 Write(eb,bb^.Dat);
                End;

          Str(k+MAx-1:5,S);
          RFormatZerro(s,CArtikul);
          bb^.Dat.Kod:=s;
          bb^.Dat.Employ:=True;
          bb^.Dat.NGTD:=NadoREfresh;
          Seek(eb,FileSize(eb));
          Write(eb,bb^.Dat);

          Dispose(bb,Done);
          r:=Ioresult;
          Close(Eb);
          r:=Ioresult;
         End{If}
          Else
                Begin
                 NoInfoMsg;
                 ClientExtendedNGTD:=False;
                 MessageBox(^M+#3'Ошибка открытия файла ГТД Код: '+
                          IntToStr(r,CLitrMantissa)
                 ,Nil,mfError+mfCancelButton);
                 Exit;
                End;{Else}
     End
     else
     Begin
       r:=Ioresult;
       Reset(Eb);
       r:=Ioresult;
       k:=IOResult;
       Seek(Eb,MAximum);
       k:=IOResult;
       New(bb,Init);
       read(Eb,bb^.Dat);
       k:=IOResult;
       if not bb^.Dat.Employ  then
         begin
          bb^.Dat.Employ:=True;
          bb^.Dat.NGTD:=NadoRefresh;
          Seek(eb,FilePos(eb)-1);
          Write(eb,bb^.Dat);
         end;
       dispose(bb,Done);
       close(eb);
     End;


NoInfoMsg;
ClientExtendedNGTD:=True;
End;{Procedure}



Function ClientExtendedGroup(SArt : ArtikulStr):Boolean;
Var c1,c,k,r : Word;
    s,stRazd : ArtikulStr;
    Max : LongInt;
    Eb  : GroupFileType;
    bb  : PGroupType;
    Maximum : LongInt;
Begin

Maximum:=0;

ClientExtendedGroup:=True;

If MAximum<StrToInt(SArt) Then Maximum:=StrToInt(SArt);

DInfoMsg('Проверяю размерность базы групп...',True);

  Assign(Eb,Path^.Dat.ToSPR+'Group.db');
  k:=IOResult;
  Reset(Eb);
  k:=IOResult;
  If k<>0 Then
  Begin
   NoInfoMsg;
   MessageBox(^M+#3'Ошибка открытия файла групп!'^M+
   +#3' Код: '+IntToStr(k,CLitrMantissa)+'. '+ClicProgrammer^,nil,mfError+mfCancelButton);
   ClientExtendedGroup:=False;
   Exit;
  End;

  Max:=FileSize(Eb);
  k:=IOResult;
  Close(Eb);
  k:=IOResult;

  If (Maximum+1)>(Max) Then
   Begin

         r:=Ioresult;
         Reset(Eb);
         r:=Ioresult;

         If r=0 Then
         Begin
          Seek(Eb,FileSize(Eb));
          New(bb,Init);
          For k:=1 To (Maximum-MAx) Do
                Begin
                 Str(k+MAx-1:4,S);
                 RFormatZerro(s,CClientKod);
                 bb^.Dat.Kod:=s;
                 bb^.Dat.Employ:=False;
                 Seek(eb,FileSize(eb));
                 Write(eb,bb^.Dat);
                End;
          Str(k+MAx-1:4,S);
          RFormatZerro(s,CClientKod);
          bb^.Dat.Kod:=s;
          bb^.Dat.Employ:=True;
          bb^.Dat.GroupName:=NAdoRefresh;
          Seek(eb,FileSize(eb));
          Write(eb,bb^.Dat);

          Dispose(bb,Done);
          r:=Ioresult;
          Close(Eb);
          r:=Ioresult;
         End{If}
          Else
                Begin
                 NoInfoMsg;
                 ClientExtendedGroup:=False;
                 MessageBox(^M+#3'Ошибка открытия файла групп Код: '+
                          IntToStr(r,CLitrMantissa)
                 ,Nil,mfError+mfCancelButton);
                 Exit;
                End;{Else}
     End
     else
     Begin
       r:=Ioresult;
       Reset(Eb);
       r:=Ioresult;
       k:=IOResult;
       Seek(Eb,MAximum);
       k:=IOResult;
       New(bb,Init);
       read(Eb,bb^.Dat);
       k:=IOResult;
       if not bb^.Dat.Employ  then
         begin
          bb^.Dat.Employ:=True;
          bb^.Dat.GroupName:=NadoRefresh;
          Seek(eb,FilePos(eb)-1);
          Write(eb,bb^.Dat);
         end;
       dispose(bb,Done);
       close(eb);
     End;


NoInfoMsg;
ClientExtendedGroup:=True;
End;{Procedure}



Function ClientExtendedKSertif(SArt : ArtikulStr):Boolean;
Var c1,c,k,r : Word;
    s,stRazd : ArtikulStr;
    Max : LongInt;
    Eb  : KSertifFileType;
    bb  : PKSertifType;
    Maximum : LongInt;
Begin
Maximum:=0;
ClientExtendedKSertif:=True;

{расчитываем максимальные позиции в разделах}
  If MAximum<StrToInt(SArt) Then Maximum:=StrToInt(SArt);

DInfoMsg('Проверяю размерность базы органов сертификации...',True);

  Assign(Eb,Path^.Dat.ToSPR+'ksertif.db');
  k:=IOResult;
  Reset(Eb);
  k:=IOResult;
  If k<>0 Then
  Begin
   NoInfoMsg;
   MessageBox(^M+#3'Ошибка открытия базы органов сертификации!'^M+
   +#3' Код: '+IntToStr(k,CLitrMantissa)+'. '+ClicProgrammer^,nil,mfError+mfCancelButton);
   ClientExtendedKSertif:=False;
   Exit;
  End;

  Max:=FileSize(Eb);
  k:=IOResult;
  Close(Eb);
  k:=IOResult;

  If (Maximum+1)>(Max) Then
   Begin

         r:=Ioresult;
         Reset(Eb);
         r:=Ioresult;

         If r=0 Then
         Begin
          Seek(Eb,FileSize(Eb));
          New(bb,Init);
          For k:=1 To (Maximum-MAx) Do
                Begin
                 Str(k+MAx-1:4,S);
                 RFormatZerro(s,CClientKod);
                 bb^.Dat.Kod:=s;
                 bb^.Dat.Employ:=False;
                 Seek(eb,FileSize(eb));
                 Write(eb,bb^.Dat);
                End;
          Str(k+MAx-1:4,S);
          RFormatZerro(s,CClientKod);
          bb^.Dat.Kod:=s;
          bb^.Dat.Employ:=True;
          bb^.Dat.KSertif:=NadoRefresh;
          Seek(eb,FileSize(eb));
          Write(eb,bb^.Dat);
          Dispose(bb,Done);
          r:=Ioresult;
          Close(Eb);
          r:=Ioresult;
         End{If}
          Else
                Begin
                 NoInfoMsg;
                 ClientExtendedKSertif:=False;
                 MessageBox(^M+#3'Ошибка открытия файла Код: '+IntToStr(r,CLitrMantissa)
                 ,Nil,mfError+mfCancelButton);
                 Exit;
                End;{Else}
     End
     else
     Begin
       r:=Ioresult;
       Reset(Eb);
       r:=Ioresult;
       k:=IOResult;
       Seek(Eb,MAximum);
       k:=IOResult;
       New(bb,Init);
       read(Eb,bb^.Dat);
       k:=IOResult;
       if not bb^.Dat.Employ  then
         begin
          bb^.Dat.Employ:=True;
          bb^.Dat.KSertif:=NadoRefresh;
          Seek(eb,FilePos(eb)-1);
          Write(eb,bb^.Dat);
         end;
       dispose(bb,Done);
       close(eb);
     End;


NoInfoMsg;
ClientExtendedKSertif:=True;
End;{Procedure}






function SetSertifName(kod: ArtikulStr;Name:string):boolean;
var id: BazType;
    fid: file of BazType;
    kdx: SkladTypeNew;
    fk: file of SkladTypeNew;
    res: word;
    sr: string[CRazdelKod];
    skod: string[CKod];
Begin

  SetSertifName:=false;
  sr:=copy(kod,1,CRazdelKod);
  skod:=copy(kod,3,CKod);

  Assign(fid,Path^.Dat.ToName+sr+'.id');
  res:=ioresult;
  reset(fid);
  res:=ioresult;
  if res<>0 then
  begin
    memc(Path^.Dat.ToName+sr+'.id Код:'+IntToStr(Res,CKOl));
    exit;
  end;
  seek(fid,StrToInt(skod));
  res:=ioresult;

  res:=ioresult;
  read(fid,id);
  res:=ioresult;

  Assign(fk,Path^.Dat.ToIndex+sr+'.kdx');
  res:=ioresult;
  reset(fk);
  res:=ioresult;
  if res<>0 then
  begin
    memc(Path^.Dat.ToName+sr+'.kdx Код:'+IntToStr(Res,CKOl));
    exit;
  end;
  res:=ioresult;
  seek(fk,StrToInt(skod));
  res:=ioresult;
  read(fk,kdx);

  id.Name:=Name;
  kdx.Name:=Name;

  res:=ioresult;
  seek(fk,filePos(fk)-1);
  res:=ioresult;
  write(fk,kdx);
  res:=ioresult;


  res:=ioresult;
  seek(fid,filePos(fid)-1);
  res:=ioresult;
  write(fid,id);
  res:=ioresult;

  close(fid);
  res:=ioresult;
  close(fk);
  res:=ioresult;

End;


Function PackMailFileClientNew(FName:TMyString; ClKod:ArtikulStr):boolean;
 var s1:string;
     Result : LongInt;
begin
  PackMailFileClientNew:=False;
  DInfoMsg('Упаковываю почту...',True);

  DoneSysError;
  DoneEvents;
  Application^.HideCursor;
  DoneDosMem;
  SWAPVECTORS;

  exec (Path^.Dat.ToUtils+'rar.exe',' a -m5 -ep -av- -inul -y -w'+Path^.Dat.ToTemp+' '+
  Path^.Dat.ToWinLnk+'OUT\'+Fname+' '+Path^.Dat.ToTemp+TruncStr(FNAme){+' '+NullStr^});

  Result:=DosError;

  SWAPVECTORS;
  InitDosMem;
  InitEvents;
  InitSysError;
  If Result=0 Then
  PackMailFileClientNew:=True;
  CursorLines:=1543;
  NoInfoMsg;
  Application^.Redraw;

  If FExists(Path^.Dat.ToWinLnk+'OUT\'+Fname) Then
    Begin
     PackMailFileClientNew:=True;
    End
  Else
     PackMailFileClientNew:=False;
    Case Result Of
   {0:MessageBox(#3'Упаковка почты успешно завершена!'^M
  +#3'Данные упакованы в '+PathExpImp.ToExport[StrToInt(ClKod)]+Fname,
  Nil,mfInformation+mfCancelButton);}
    2:MessageBox(#3^M+#3'Файл не найден !',Nil,mfError+mfCancelButton);
    3:MessageBox(#3^M+#3'Путь не найден !',Nil,mfError+mfCancelButton);
    5:MessageBox(#3^M+#3'Доступ невозможен !(1)',Nil,mfError+mfCancelButton);
    6:MessageBox(#3^M+#3'Неверное устройство !',Nil,mfError+mfCancelButton);
    8:MessageBox(#3^M+#3'Недостаточно памяти !',Nil,mfError+mfCancelButton);
   10:MessageBox(#3^M+#3'Неверные настройки !',Nil,mfError+mfCancelButton);
   11:MessageBox(#3^M+#3'Неверный формат !',Nil,mfError+mfCancelButton);
   18:MessageBox(#3^M+#3'Слишком много файлов !',Nil,mfError+mfCancelButton);
   Else
   End;
End;

Function UnpackMailFileClientNew(FName:TMyString; ClKod:ArtikulStr):boolean;

var s:string;
     Result : LongInt;

Begin

  UnpackMailFileClientNew:=false;

  DInfoMsg('Распаковываю почту...',True);
  DoneSysError;
  DoneEvents;
  Application^.HideCursor;
  DoneDosMem;

  SWAPVECTORS;

  s:=Path^.Dat.ToUtils+'rar.exe e -inul -y -av- -w'+Path^.Dat.ToTemp+' '+
  Path^.Dat.ToWinLnk+'IN\'+FName+' '+
  Path^.Dat.ToTemp+' '+NullStr^;

  {exec (GetEnv('Comspec'),' /c '+s);}
  exec (Path^.Dat.ToUtils+'rar.exe',' e -inul -y '{-av-} +'-w'+Path^.Dat.ToTemp+' '+
  Path^.Dat.ToWinLnk+'IN\'+FName+' '+
  Path^.Dat.ToTemp{+' '+NullStr^});


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
    5:MessageBox(#3^M+#3'Доступ невозможен !(2)',Nil,mfError+mfCancelButton);
    6:MessageBox(#3^M+#3'Неверное устройство !',Nil,mfError+mfCancelButton);
    8:MessageBox(#3^M+#3'Недостаточно памяти !',Nil,mfError+mfCancelButton);
   10:MessageBox(#3^M+#3'Неверные настройки !',Nil,mfError+mfCancelButton);
   11:MessageBox(#3^M+#3'Неверный формат !',Nil,mfError+mfCancelButton);
   18:MessageBox(#3^M+#3'Слишком много файлов !',Nil,mfError+mfCancelButton);
   Else
   UnpackMailFileClientNew:=true;
   End;
End;


Function UnpackSpr(FName:string):boolean;
var Result:word;
Begin
  UnpackSpr := false;
  AddProtocol('Начало обновления справочников  ','','');
  DoneSysError;
  DoneEvents;
  Application^.HideCursor;
  DoneDosMem;

  SWAPVECTORS;

  exec (Path^.Dat.ToUtils+'rar.exe',' e -inul -y '{-av-} +'-w'+Path^.Dat.ToTemp+' '+
  Path^.Dat.ToWinLnk+'IN\'+FName+' '+
  Path^.Dat.ToSpr{+' '+NullStr^});


  SWAPVECTORS;
  InitDosMem;
  InitEvents;
  InitSysError;
  Result:=DosError;
  CursorLines:=1543;
  Application^.Redraw;

    Case Result Of
    2:MessageBox(#3^M+#3'Файл не найден !',Nil,mfError+mfCancelButton);
    3:MessageBox(#3^M+#3'Путь не найден !',Nil,mfError+mfCancelButton);
    5:MessageBox(#3^M+#3'Доступ невозможен !(3)',Nil,mfError+mfCancelButton);
    6:MessageBox(#3^M+#3'Неверное устройство !',Nil,mfError+mfCancelButton);
    8:MessageBox(#3^M+#3'Недостаточно памяти !',Nil,mfError+mfCancelButton);
   10:MessageBox(#3^M+#3'Неверные настройки !',Nil,mfError+mfCancelButton);
   11:MessageBox(#3^M+#3'Неверный формат !',Nil,mfError+mfCancelButton);
   18:MessageBox(#3^M+#3'Слишком много файлов !',Nil,mfError+mfCancelButton);
   Else
    UnpackSpr := true;
    SetLastSPR;
    AddProtocol('Обновление справочников успешно ЗАВЕРШЕНО ','','');
   end;

End;

Function UnpackClientBase(FName:string): boolean;
var ss: string;
    fcS,fcA: ClientFileType;
    cl: ClientType;
    Res: word;
Begin
  UnpackClientBase:=false;

  DelSpace(FName);

  If Not UnpackMailFileClientNew(FName,ss) Then Exit
  else
   Begin
    EraseFile(Path^.Dat.ToWinLnk+'IN\'+FName);
   End;

  Assign (fcS,Path^.Dat.ToTemp+FName);
  Res := IOResult;
  Reset(fcS);
  Res := IOResult;
  If Res <> 0 Then
   Begin
     MessageBox(#3^M+#3'Ошибка открытия файла '+Path^.Dat.ToTemp+FName+' Код:'+IntToStr(Res,CKol),Nil,mfError+mfCancelButton);
     Exit;
   End;

  Assign (fcA,Path^.Dat.ToClient+'client.db');
  Res := IOResult;
  Reset(fcA);
  Res := IOResult;
  If Res <> 0 Then
   Begin
     MessageBox(#3^M+#3'Ошибка открытия файла '+Path^.Dat.ToClient+'client.db Код:'+
	IntToStr(Res,CKol),Nil,mfError+mfCancelButton);
     close(fcS);
     Exit;
   End;

  while not eof(fcS) do
  begin
    Res := IOResult;
    read(fcS,cl);
    Res := IOResult;
    if StrToInt(cl.kod) > FileSize(FCA) then Continue;
    seek(fcA,StrToInt(cl.kod));
    Res := IOResult;
    write(fcA,cl);
    Res := IOResult;
  end;
  Res := IOResult;
  close(fcA);
  Res := IOResult;
  close(fcS);
  Res := IOResult;
  SetLastCl;
  UnpackClientBase := true;
  EraseFile(Path^.Dat.ToTemp+FName);

End;


Function SelectReplication(Var l : Word):Boolean;
var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  c : Word;
BEGIN

SelectReplication:=false;

l:=0;

R.Assign(15, 8, 50, 12);
New(Dlg, Init(R, 'Синхронизация баз'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx:=$E241;


R.Assign(1, 1, 34, 3);
Control := New(PRadioButtons, Init(R,
  NewSItem('Принять текущие обновления',
  NewSItem('Полная синхронизация', Nil))));

Dlg^.Insert(Control);
Dlg^.SetData(L);
Dlg^.SelectNext(False);

c:=Desktop^.ExecView(Dlg);
If c<>cmCancel Then
 Begin
  Dlg^.GetData(l);
  Dispose(Control,Done);
  Dispose(Dlg,Done);
  SelectReplication:=True;
 End
 Else Begin
       Dispose(Control,Done);
       Dispose(Dlg,Done);
      End;

END;

Function SelectRemoteOperation(Var l : Word):Boolean;
var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  c : Word;

begin
SelectRemoteOperation:=False;
l:=8;
R.Assign(15, 8, 60, 14);
New(Dlg, Init(R, 'Удаленный доступ'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx:=$E241;

R.Assign(1, 1, 44, 5);
Control := New(PCheckboxes, Init(R,
  NewSItem('Запрос обновления остатков',
  NewSItem('Запрос обновления базы клиентов',
  NewSItem('Запрос обновления справочников',
  NewSItem('Принять почту ',
  Nil))))));
Dlg^.Insert(Control);
Dlg^.SetData(L);
Dlg^.SelectNext(False);
c:=Desktop^.ExecView(Dlg);
If c<>cmCancel Then
 Begin
  Dlg^.GetData(l);
  Dispose(Control,Done);
  Dispose(Dlg,Done);
  SelectRemoteOperation:=True;
 End
 Else Begin
       Dispose(Control,Done);
       Dispose(Dlg,Done);
      End;
end;


Procedure FormZaprosFromReplication;
var t: text;
    IORez: word;
    s:string[CKod];
Begin
  s:=IntToStr(StrToInt(Rek^.Dat.Kod),CKod);
  Assign(t,Path^.Dat.ToWinLnk+'out\'+'refresh.'+s);
  IORez:=ioresult;
  Rewrite(t);
  IORez:=ioresult;
  if IOrez=0 then
  begin
   writeln(t,s);
   close(t);
  end;

End;

Procedure FormZaprosFromClient;
var t: text;
    IORez: word;
    s:string[CKod];
Begin
  s:=IntToStr(StrToInt(Rek^.Dat.Kod),CKod);
  Assign(t,Path^.Dat.ToWinLnk+'out\'++'client.'+s);
  IORez:=ioresult;
  Rewrite(t);
  IORez:=ioresult;
  if IOrez=0 then
  begin
   WRITELN(T,S);
   close(t);
  end;

End;

Procedure FormZaprosFromSPR;
var t: text;
    IORez: word;
    s:string[CKod];
Begin
  s:=IntToStr(StrToInt(Rek^.Dat.Kod),CKod);
  Assign(t,Path^.Dat.ToWinLnk+'out\'++'spr.'+s);
  IORez:=ioresult;
  Rewrite(t);
  IORez:=ioresult;
  if IOrez=0 then
  begin
   writeln(t,s);
   IORez:=ioresult;
   close(t);
   IORez:=ioresult;
  end;

End;

function LockAndWritePredZakaz(ss:AllStr;Var L:PZakazType):boolean;
var MarketFile : ZakazFileType;
    IORez, i : word;
    Test : PZakazType;
    AS:DocumentEditZ;
Begin
 LockAndWritePredZakaz:=false;
 Assign(MarketFile,Path^.Dat.ToMarket+'Zakaz.db');
 IOrez:=IOResult;
 Reset(MarketFile);
 IORez:=IOResult;
 If IORez <> 0 Then Begin
                 {AddProtocol();}
                 (*AddLog(Log,ss+'-нет доступа к файлу PZakaz.db код:'+IntToStr(c,CKol)+
			  '. Сообщение отложено');*)
                 MessageBox(#3'Отсутствует файл заявок !'^M+
                  #3+Path^.Dat.ToMarket+'zakaz.db',Nil,
                  mfWarning+mfOkCancel);
                 Exit;
                End;

 New(Test,Init);

 begin
   seek(MarketFile,StrToInt(L^.Dat.Document)-1);
   read(MarketFile,Test^.Dat);

   begin
     Test^.Dat.Skidka:=L^.Dat.Skidka;
     Test^.Dat.SertifSkidka:=L^.Dat.SertifSkidka;
     Test^.Dat.Status:=L^.Dat.Status;
     Test^.Dat.AmountP:=L^.Dat.AmountP;
     Test^.Dat.EndDate:=L^.Dat.EndDate;
     Test^.Dat.Comment1:=L^.Dat.Comment1;
     Test^.Dat.Comment2:=L^.Dat.Comment2;
     {Test^.Dat.ClientNumer:=L^.Dat.ClientNumer;}
     {Test^.Dat.Summa:=L^.Dat.Summa;}
     for i:=1 to L^.Dat.AmountP do
     BEgin
       Test^.Dat.ElementP[i]:=L^.Dat.ElementP[i];
     End;
     IOrez:=IOResult;
     Test^.Dat.Document:=L^.Dat.Document;
     Test^.Dat.DocumentComment:=L^.Dat.DocumentComment;
     seek(MarketFile,FilePos(MarketFile)-1);
     IOrez:=IOResult;
     write(MarketFile,Test^.Dat);
     IOrez:=IOResult;
     LockAndWritePredZakaz:=true;
     {memc(L^.Dat.Document);}
     As.EditPosition:=L^.Dat.Document;
   end;
 end;
 Dispose(test,Done);
 IOrez:=IOResult;
 Close(MarketFile);
 IOrez:=IOResult;

 SEtPodpis(As,5);

End;



function WriteOstFile(FName:string):boolean;

Var sKOd: ArtikulStr;
    sZena: string[CZena];
    sKol,sSumKol: string[CKol];
    IORez,i,j: word;
    P: PBox;
    t: text;
    s: string;
    R: Trect;
    sR: String[CRazdelKod];
    sK: String[CKod];
    fSkl: file of SkladType;
    Skl: SkladType;
    fR: RazdelFileType;
    rr: razdelType;
    Kdx: SkladTypeNew;
    KdxFile : File Of SkladTypeNew;
Begin
 WriteOstFile:=false;
 AddProtocol('Начало обновления остатков ','','');
 {Читаем принятый файл}
 Assign(t,FName);
 IORez:=ioresult;
 Reset(t);
 IORez:=ioresult;
 if IORez<>0 then
 begin
  MessageBox(#3+'Ошибка открытия принятых остатков. Файл '+FNAme+' Код:'+IntToStr(IORez,CKOl),
  Nil,mfWarning+mfOkCancel);
  exit;
 end;

 DinfoMSG('Читаю базу вошедших остатков... ',false);
 R.Assign(0,0,0,0);
 P := New(PBox, Init(R, 1, Nil));
 P^.NewList(New(PTextCollection, Init(1,1)));

 Readln(t,LastOstDate);
 Readln(t,LastOstTime);

 SetLastOst;

 while not eof (t) do
 begin
   readln(t,s);
   P^.List^.Insert(NewStr(s));
   P^.SetRange(P^.List^.Count);
 end;

 IOrez:=ioresult;
 System.Close(t);
 IOrez:=ioresult;
 {Обновляем базу наименований: 1 - все остатки в ноль кроме СертиФ
                               2 - переносим новые остатки }
 NoInfoMSG;

 if (P<>nil) and (P^.List^.Count>0) then
 BEGIN
 {1}
  Assign(fr,Path^.Dat.ToRazdel+'razdel.db');
  IORez:=ioresult;
  Reset(fr);
  IORez:=ioresult;
  if iorez<>0 then
  begin
    MessageBox(#3^M+#3'Ошибка открытия файла '+Path^.Dat.ToRazdel+'razdel.db Код:'+IntToStr(IORez,CKOl),
    Nil,mfError+mfCancelButton);
    exit;
  end;

  while not eof(fr) do
  begin
    read(fr,rr);
    DInfoMSGShkala('Обнуление остатков - раздел '+rr.kod+'...',0,FileSize(fr),FilePos(fr));

    if rr.EnableDoc=0 then sKol:='0'
      else sKol:='100';
    if rr.Employ {and (rr.EnableDoc=0)} then
    begin
      Assign(Fskl,Path^.Dat.TOSklad+rr.kod+'.db');
      IORez:=ioresult;
      Reset(Fskl);
      IORez:=ioresult;
      if IORez<>0 then
       Begin
         MessageBox(#3^M+#3'Ошибка открытия файла '+Path^.Dat.TOSklad+rr.kod+'.db Код:'+IntToStr(IORez,CKOl),Nil,
	    mfError+mfCancelButton);
         exit;
       End;

      Assign(KdxFile,Path^.Dat.ToIndex+rr.kod+'.kdx');
      IORez:=ioresult;
      Reset(KdxFile);
      IORez:=ioresult;
      if IORez<>0 then
      Begin
         MessageBox(#3^M+#3'Ошибка открытия файла '+Path^.Dat.ToIndex+rr.kod+'.kdx Код:'+IntToStr(IORez,CKol),
	    Nil,mfError+mfCancelButton);
         IORez:=ioresult;
         close(Fskl);
         IORez:=ioresult;
         exit;
      End;

      while not eof(fSkl) do
      begin
        read(fskl,skl);
        if Skl.Employ then
        begin
          sSumKol:='0';
          for j:=1 to CDivision do
          begin
            Skl.Input.Division[j]:=sKol;
            Skl.Input.DivisionR[j]:='0';
            sSumKOl:=IntToStr(StrToInt(sSumKol)+StrToInt(sKol),CKol);
          end;

          Skl.Input.Kol:=sSumKol;
          Skl.Input.KolR:='0';

          If EnableZakupka<>1 Then
           Begin
       { убрано 10/01/2006 из-за включения механизма
          контроля цен от закупки

            Skl.Input.Zakupka[0]:=#0;
            Skl.Input.Zakupka2[0]:=#0;
}
           End;

          IORez:=ioresult;
          Seek(KdxfILE,FilePos(fSkl)-1);  {!!!!!!!!!!!!}
          IORez:=ioresult;
          read(KdxFile,kdx);
          IORez:=ioresult;


          If EnableZakupka<>1 Then
           Begin
        { убрано 10/01/2006 из-за включения механизма
          контроля цен от закупки
            Kdx.Zakupka:=0;
            Kdx.Zakupka2:=0;
}
           End;

          for j:=1 to CDivision do
          begin
            if j=5 then Kdx.Division[j]:=StrToInt(sKol)
            else Kdx.Division[j]:=0;
            Kdx.DivisionR[j]:=0;
          end;

          Kdx.Kol:=StrToInt(sSumKol);
          IORez:=ioresult;
          Seek(KdxFile,FilePos(KdxFile)-1);
          IORez:=ioresult;
          write(KdxFile,Kdx);
          IORez:=ioresult;

          IORez:=ioresult;
          Seek(fSkl,FilePos(fSkl)-1);
          IORez:=ioresult;
          write(fSkl,Skl);
          IORez:=ioresult;

        end;
      end;

      IORez:=ioresult;
      System.Close(fSkl);
      IORez:=ioresult;

      IORez:=ioresult;
      System.Close(KdxFile);
      IORez:=ioresult;

    end;
  end;

  NoInfoMSG;

  IORez:=ioresult;
  System.Close(fr);
  IORez:=ioresult;

 {2}
 sKol:='0';

 for i:=0 to P^.List^.Count-1 do
 Begin
   s:=P^.GetText(i,P^.List^.Count);
   sKod:=copy(s,1,Pos(';',s)-1);
   rformatZerro(skod,CArtikul);
   DInfoMsgShkala('Импорт базы остатков позиция '+sKOd,0,P^.List^.Count-1,i);
   sR:=copy(sKod,1,CRazdelKod);
   sK:=copy(sKOd,CRazdelKOd+1,CKOD);
   System.Delete(s,1,Pos(';',s));

   Assign(Fskl,Path^.Dat.TOSklad+sR+'.db');
   IORez:=ioresult;
   Reset(Fskl);
   IORez:=ioresult;
   Assign(KdxFile,Path^.Dat.ToIndex+sR+'.kdx');
   IORez:=ioresult;
   Reset(KdxFile);
   IORez:=ioresult;

   seek(fSkl,StrToInt(sK));
   IORez:=ioresult;
   read(fSkl,Skl);
   IORez:=ioresult;

   seek(KdxFile,StrToInt(sK));
   IORez:=ioresult;
   read(KdxFile,Kdx);
   IORez:=ioresult;


 if Skl.Employ then
   begin
    sZena:=copy(s,1,Pos(';',s)-1);
    rformat(sZena,CZena);
    System.Delete(s,1,Pos(';',s));

    Skl.Input.R_Zena:=sZena;
    Skl.Input.O_Zena:=sZena;
    Kdx.R_Zena:=StrToReal(sZena);

    sSumKol:='0';

    for j:=1 to CDivision do
    begin
      sKol:=copy(s,1,Pos(';',s)-1);
      rformat(sKOl,CKol);
      if j<CDivision then System.Delete(s,1,Pos(';',s));
      Skl.Input.Division[j]:=sKol;
      Kdx.Division[j]:=StrToInt(sKol);
      sSumKOl:=IntToStr(StrToInt(sSumKol)+StrToInt(sKol),CKol);
    end;

    Skl.Input.Kol:=sSumKol;
    Kdx.Kol:=StrToInt(sSumKol);

    IORez:=ioresult;
    Seek(fSkl,FilePos(fskl)-1);
    IORez:=ioresult;
    write(fSkl,Skl);
    IORez:=ioresult;

    IORez:=ioresult;
    Seek(KDXFile,FilePos(KdxFile)-1);
    IORez:=ioresult;
    write(KdxFile,Kdx);
    IORez:=ioresult;

   end; {if Skl.Employ then}

   IORez:=ioresult;
   System.Close(fSkl);
   IORez:=ioresult;
   IORez:=ioresult;
   System.Close(KDXFile);
   IORez:=ioresult;

 End;

 NoInfoMSG;
 END
 Else exit;

 AddProtocol('Обновление остатков успешно ЗАВЕРШЕНО','','');

 WriteOstFile:=true;
End;


procedure WriteMailFile(var t:Text;E:ZakazType);
var i,j: word;
    find: boolean;
    ws: string;

Begin
Writeln(t,'Header=0');
with E do
begin
 Writeln(t,'ClientKod=',ClientKod);
 Writeln(t,'SkladKod=',SkladKod);
 Writeln(t,'AgentKod=',AgentKod);
 Writeln(t,'DocSelector=',DocSelector);
 Writeln(t,'OperatorSelector=',OperatorSelector);
 Writeln(t,'Versia=',Versia);
 Writeln(t,'ShkalaNumer=',ShkalaNumer);
 Writeln(t,'SkidkaSelector=',SkidkaSelector);
 Writeln(t,'ClientNumer=',Document);
 Writeln(t,'Date=',DateC);
 DelSpace(SummaZ);
 Writeln(t,'Summa=',SummaZ);
 DelSpace(SertifSummaZ);
 Writeln(t,'SertifSumma=',SertifSummaZ);
 DelSpace(Skidka);
 Writeln(t,'Skidka=',Skidka);
 DelSpace(SertifSkidka);
 Writeln(t,'SertifSkidka=',SertifSkidka);
 DelSpace(DocDate);
 Writeln(t,'DataOtpr=',FDate);
 Writeln(t,'Amount=',Amount);
 Writeln(t,'PriceDate=',DateC);
 Writeln(t,'TimeC=',TimeC);
 Writeln(t,'DateM=',DateM);
 Writeln(t,'TimeM=',TimeM);
 {Writeln(t,'DateConv=',DateConv);
 Writeln(t,'TimeConv=',TimeConv);}
 Writeln(t,'Status=2');
 Writeln(t,'ZakazNumer=',Document);
 {Writeln(t,'Rezerv=',Rezerv);}
 {Writeln(t,'SendConfirmation=',SendConfirmation);
 Writeln(t,'DateConfirmation=',DateConfirmation);
 Writeln(t,'TimeConfirmation=',TimeConfirmation);}
 Writeln(t,'Srok=',Srok-DateStringToDate(DateMask,DateC));
 Writeln(t,'DateEnd=',DateToDateString(DateMask,DateStringToDate(DateMask,DateC)+EndDate));
 Writeln(t,'Comment1=',Comment1);
 Writeln(t,'Comment2=',Comment2);
 if DocSelector in [3,4,6,8] then
  Writeln(t,'sf=1')
 else  Writeln(t,'sf=0') ;
 if Rashet in [1,2] then
  Writeln(t,'BN=1')
 else  Writeln(t,'BN=0') ;
 Writeln(t,'Caption=',Caption);

 for i:=1 to Amount do
 begin
  Writeln(t,'Element[',i,'].BazKod=',MarketElement[i].BazKod);
  DelSpace(MarketElement[i].Input.Kol);
  Writeln(t,'Element[',i,'].Kol=',MarketElement[i].Input.Kol);

  DelSpace(MarketElement[i].Input.Zena);

  If SkidkaSelector=0 Then{Если автомат}
      begin
       DelSpace(MarketElement[i].Input.Proz);
       MyStr((StrToReal(MarketElement[i].Input.Zena)/
       (1+StrToReal(MarketElement[i].Input.Proz)/100)),CZena,CMantissa,ws);
      end
      else
      MyStr((StrToReal(MarketElement[i].Input.Zena)-StrToReal(MarketElement[i].Input.Skidka))
       ,CZena,CMantissa,ws);

  Writeln(t,'Element[',i,'].Zena=',ws);

  find:=false;
  for j:=1 to AmountS do
    if DocumentElement[j].BazKod=MarketElement[i].Input.NSertif then
    begin
     find:=true;
     break;
    end;
  if find then Writeln(t,'Element[',i,'].NadoSertif=1')
  else Writeln(t,'Element[',i,'].NadoSertif=0');
 { Writeln(t,'Element[',i,'].NadoSertif=',MarketElement[i].Input.NadoSertif);
  Writeln(t,'Element[',i,'].Fakt=',Element[i].Fakt);}
  {Writeln(t,'Element[',i,'].Zakupka=',MarketElement[i].Input.Zakupka);}
 end;

end;

End;


Procedure LoadMailFile(S:String);
LAbel 43,44,45;
Var ss : TMyString;
    txt : Text;
    i : Byte;
    c : Byte;
    SH: TStringHolder;
    SHeader,SClientKod,
    SStatus,SObjectKod : AllStr;
    {Cl : PClientType;}
    DeltaAmount : Word;
    LastAmount : Word;
    FZ: file of ZakazType;
    PZ : PZakazType;
    Skl : PSkladType;
    kdx: SkladTypeNew;
    KDxFile: file of  SkladTypeNew;
    f : File;
    Res: word;
    Attr: SearchRec;
    dt : DateTime;
    sDay:string[2];
    sMonth:string[2];
    sYear:string[2];
    sHour:string[2];
    sMin:string[2];
    sSec:string[2];
    sDate: DateString;
    sTime: DateString;
    SMakeKod: string[CArtikul];
    Db: PSkladType;
    id: PBAzType;
    fDb: file of SkladType;
    fid: file of BAzType;
    sArt: string[CArtikul];
    sR: string[CRazdelKOd];
    sKOd: string[CKOd];
    ws:string;
    wi:integer;


Function GetAsString(Name:AllStr):String;
Begin
GetAsString[0]:=#0;
GetAsString:=SH.GetString (Name);
End;

Function GetAsInteger(Name:AllStr):LongInt;
Begin
GetAsInteger:=0;
GetAsInteger:=StrToInt(SH.GetString (Name));
End;

Function GetAsReal(Name:AllStr):Real;
Begin
GetAsReal:=0;
GetAsReal:=StrToReal(SH.GetString (Name));
End;

Begin

 DInfoMSg('Чтение вошедшего подтверждения...',false);
 ss[0]:=#0;

 If Not UnpackMailFileClientNew(s,ss) Then Exit;

Assign (txt,Path^.Dat.ToTemp+s);
Res := IOResult;
Reset(txt);
Res := IOResult;
If Res <> 0 Then
 Begin
  MessageBox(#3^M+#3'Ошибка открытия файла '+Path^.Dat.ToTemp+s+' Код:'+IntToStr(Res,CKOl),
  Nil,mfError+mfCancelButton);
  Exit;
 End;
Close(txt);
Res := IOResult;

 {Дата и время получения}
 FindFirst(Path^.Dat.ToTemp+s,Archive,Attr);

 UnpackTime(Attr.Time,dt);
 sDay:=IntToStr(dt.day,2);
 rformatzerro(sDay,2);
 sMonth:=IntToStr(dt.Month,2);
 RFormatZerro(sMonth,2);
 sYear:=Copy(IntToStr(dt.Year,4),3,1)+Copy(IntToStr(dt.Year,4),4,1);
 sDate:=sday+'-'+sMonth+'-'+sYear;

 sHour:=IntToStr(dt.Hour,2);
 rformatzerro(sHour,2);
 sMin:=IntToStr(dt.Min,2);
 rformatzerro(sMin,2);
 sSec:=IntToStr(dt.Sec,2);
 rformatzerro(sSec,2);
 sTime:=sHour+':'+sMin+':'+sSec;


SH.Init;
SH.LoadFromFile (Path^.Dat.ToTemp+s);

SHeader:=GetAsString('Header');{предзаказ}
If Not Sh.OkOp Then Begin
                     MessageBox(#3^M+#3'Не обнаружен параметр Header !',Nil,mfError+mfCancelButton);
                     AddProtocol('Не обнаружен параметр Header !','','');
                     Goto 45;
                    End;

{это другая тематика а не предзаказ}
If StrToInt(SHeader)<>0 Then Goto 45;

SObjectKod:=GetAsString('SkladKod');{организация}
If Not Sh.OkOp Then Begin
                     MessageBox(#3^M+#3'Не обнаружен параметр SkladKod !',Nil,mfError+mfCancelButton);
                     AddProtocol('Не обнаружен параметр SkladKod !','','');
                     Goto 45;
                    End;

If Not(StrToInt(SObjectKod) in [1..30]) Then
                    Begin
                     MessageBox(#3^M+#3'Не обнаружен параметр SObjectKod !',Nil,mfError+mfCancelButton);
                     AddProtocol('Не обнаружен параметр SObjectKod !','','');
                     Goto 45;
                    End;

If (StrToInt(SObjectKod)<>StrToInt(Rek^.Dat.Kod)) Then
                    Begin
                     MessageBox(#3^M+#3'Получена накладная для объекта '+SObjectKod+ ' !',Nil,mfError+mfCancelButton);
                     AddProtocol('Получена накладная для объекта '+SObjectKod+ ' !','','');
                     Goto 45;
                    End;


SClientKod:=GetAsString('ClientKod');{клиент}
If Not Sh.OkOp Then Begin
                     MessageBox(#3^M+#3'Не обнаружен параметр ClientKod !',Nil,mfError+mfCancelButton);
                     AddProtocol('Не обнаружен параметр ClientKod !','','');
                     Goto 45;
                    End;
RFormatZerro(SClientKod,CClientKod);


SStatus:=GetAsString('Status');{клиент}
If Not Sh.OkOp Then Begin
                     MessageBox(#3^M+#3'Не обнаружен параметр Status !',Nil,mfError+mfCancelButton);
                     AddProtocol('Не обнаружен параметр Status !','','');
                     Goto 44;
                    End;

If not(StrToInt(SStatus) in [5,6]) Then
                    Begin
                     MessageBox(#3^M+#3'Неверный параметр Status = '+SStatus,Nil,mfError+mfCancelButton);
                     AddProtocol('Неверный параметр Status = '+SStatus,'','');
                     Goto 44;
                    End;
DeltaAmount:=0;
LastAmount:=1;

New(PZ,Init);


{Номер заказа у агента}

Pz^.Dat.Document:=GetAsString('ClientNumer');{номер у клиент}
If Not Sh.OkOp Then Begin
                     MessageBox(#3'ClientNumer'^M,Nil,mfWarning+mfOkCancel);
                     Goto 43;
                    End;


Assign(FZ,Path^.Dat.ToMarket+'zakaz.db');
Res:=ioresult;
reset(FZ);
Res:=ioresult;
if Res<>0 then
begin
 {Message}
 Dispose(PZ,Done);
 exit;
end;

Res:=ioresult;
Seek(FZ,StrToInt(Pz^.Dat.Document)-1);
Res:=ioresult;
read(FZ,PZ^.Dat);
Close(FZ);


Pz^.Dat.ClientKod:=SClientKod;
Pz^.Dat.Status:=StrToInt(SStatus);{получен T-Mail}

Pz^.Dat.AgentKod:=GetAsString('AgentKod');{клиент}
If Not Sh.OkOp Then Begin
                     MessageBox(#3+ss+'- не найден AgentKod. Сообщение отложено'^M,Nil,mfWarning+mfOkCancel);
                     (*AddLog(Log,ss+'- не найден AgentKod. Сообщение отложено');*)
                     Goto 43;
                    End;


{Номер заказа по складу}
Pz^.Dat.PredZakazNumer:=GetAsInteger('ZakazNumer');
If Not Sh.OkOp Then Begin
                     MessageBox(#3'ZakazNumer'^M,Nil,mfWarning+mfOkCancel);
                     (*AddLog(Log,ss+'- не найден ZakazNumer. Сообщение отложено');*)
                     Goto 43;
                    End;


{!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!}
Pz^.Dat.DateC:=GetAsString('Date');
If Not Sh.OkOp Then Begin
                     MessageBox(#3'Date'^M,Nil,mfWarning+mfOkCancel);
                     (*AddLog(Log,ss+'- не найден Date. Сообщение отложено');*)
                     Goto 43;
                    End;

Pz^.Dat.DocDate:=GetAsString('DataOtpr');{дата у клиента}
If Not Sh.OkOp Then Begin
                     MessageBox(#3'DataOtpr'^M,Nil,mfWarning+mfOkCancel);
                     (*AddLog(Log,ss+'- не найден DataOtpr. Сообщение отложено');*)
                     Goto 43;
                    End;

Pz^.Dat.EndDate:=
Abs(DateStringToDate(DateMask,GetAsString('DateEnd'))-
DateStringToDate(DateMask,Pz^.Dat.DateC));{дата у клиента}{дата у клиента}
If Not Sh.OkOp Then Begin
                     MessageBox(#3'DateEnd'^M,Nil,mfWarning+mfOkCancel);
                     (*AddLog(Log,ss+'- не найден DateEnd. Сообщение отложено');*)
                     Goto 43;
                    End;


Pz^.Dat.Amount:=GetAsInteger('Amount');{количество позиций}

If Not Sh.OkOp Then Begin
                     MessageBox(#3+ss+'- не найден AmountAmount'^M,Nil,mfWarning+mfOkCancel);
                     (*AddLog(Log,ss+'- не найден Amount. Сообщение отложено');*)
                     Goto 43;
                    End;

Pz^.Dat.AmountP:=GetAsInteger('AmountP');{количество позиций}

If Not Sh.OkOp Then Begin
                     MessageBox(#3+ss+'- не найден AmountP'^M,Nil,mfWarning+mfOkCancel);
                     (*AddLog(Log,ss+'- не найден Amount. Сообщение отложено');*)
                     Goto 43;
                    End;


Pz^.Dat.SummaZ:=GetAsString('Summa');{сумма у клиента}

Pz^.Dat.Caption:='99';

Pz^.Dat.Comment1:=GetAsString('Comment1');
Pz^.Dat.Comment2:=GetAsString('Comment2');


(*If Not Sh.OkOp Then Begin
                     MessageBox(#3'Defizit'^M,Nil,mfWarning+mfOkCancel);
                     Goto 43;
                    End;     *)


Pz^.Dat.Skidka:=sDate;
Pz^.Dat.SertifSkidka:=sTime;

For c:=1 To Pz^.Dat.AmountP Do
 Begin
  Pz^.Dat.ElementP[c].BazKod:=GetAsString('EP['+IntToStr(c,CKol)+'].BazKod');{}
  RFormatZerro(Pz^.Dat.ElementP[c].BazKod,CArtikul);

If Not Sh.OkOp Then Begin
                     memc('- EP['+IntToStr(c,CKol)+'].BazKod');
                     (*AddLog(Log,ss+'- Element['+IntToStr(c,CKol)+'].BazKod. Сообщение отложено');*)
                     Goto 43;
                    End;

  Pz^.Dat.ElementP[c].Kol:=GetAsString('EP['+IntToStr(c,CKol)+'].Kol');{}
  DelSpace(Pz^.Dat.ElementP[c].Kol);
If Not Sh.OkOp Then Begin
                     memc('- EP['+IntToStr(c,CKol)+'].Kol');
                     (*AddLog(Log,ss+'- Element['+IntToStr(c,CKol)+'].Kol. Сообщение отложено');*)
                     Goto 43;
                    End;

 (* Pz^.Dat.Element[c].NadoSertif:=GetAsInteger('ElementP['+IntToStr(c,CKol)+'].NadoSertif');{}*)

  Pz^.Dat.ElementP[c].Zena:=GetAsString('EP['+IntToStr(c,CKol)+'].Zena');{}
  DelSpace(Pz^.Dat.ElementP[c].Zena);

If Not Sh.OkOp Then Begin
                     memc('- EP['+IntToStr(c,CKol)+'].Zena');
                     (*AddLog(Log,ss+'- Element['+IntToStr(c,CKol)+'].Zena. Сообщение отложено');*)
                     Goto 43;
                    End;
 (* Pz^.Dat.Element[c].Fakt:=StrToInt(GetAsString('ElementP['+IntToStr(c,CKol)+'].Fakt'));*)

  Pz^.Dat.ElementP[c].DivisionNumber:=StrToInt(GetAsString('EP['+IntToStr(c,CKol)+'].DivisionNumber'));



 End;{For}

  NoInfoMsg;

  DInfoMSg('Обновление базы наименований...',false);

  New(Id,Init);
  New(db,init);

For c:=1 To Pz^.Dat.AmountP Do
begin
  {Читаем из баз}
  sArt:=Pz^.Dat.ElementP[c].BazKod;
  sR:=copy(sArt,1,CRazdelKod);
  sKod:=copy(sArt,3,CKod);

{Обновление наличия и наименований}

  Assign(fid,Path^.Dat.ToName+sR+'.id');
  Res:=ioresult;
  Reset(fid);
  Res:=ioresult;
  seek(fid,StrToInt(sKod));
  Res:=ioresult;
  read(fid,id^.Dat);
  Res:=ioresult;

  Assign(fdb,Path^.Dat.ToSklad+sR+'.db');
  Res:=ioresult;
  Reset(fdb);
  Res:=ioresult;
  seek(fdb,StrToInt(sKod));
  Res:=ioresult;
  read(fdb,db^.Dat);
  Res:=ioresult;

  Assign(KdxFile,Path^.Dat.ToIndex+sR+'.kdx');
  Res:=ioresult;
  Reset(KdxFile);
  Res:=ioresult;
  seek(KdxFile,StrToInt(sKod));
  Res:=ioresult;
  read(KdxFile,kdx);
  Res:=ioresult;

  {id}

     id^.Dat.Employ:=true;
     kdx.Employ:=true;
     db^.dat.Employ:=true;

     ws:=GetAsString('EP['+IntToStr(c,CKol)+'].Name');
     if Sh.OkOp then
       begin
        id^.Dat.Name  := ws;
        kdx.Name:= ws;
       end;

     ws:=GetAsString('EP['+IntToStr(c,CKol)+'].Name2');
     if Sh.OkOp then
      begin
       id^.Dat.Name2 :=ws;
       kdx.Name2:=ws;
      end;

     ws:= GetAsString('EP['+IntToStr(c,CKol)+'].Litr');
     if Sh.OkOp then
      begin
       id^.Dat.Litr  :=ws;
      end;

     ws:=GetAsString('EP['+IntToStr(c,CKol)+'].InPack');
     if Sh.OkOp then
      begin
       id^.Dat.InPack:=ws;
      end;

     ws:=GetAsString('EP['+IntToStr(c,CKol)+'].InPack2');
     if Sh.OkOp then
      begin
       id^.Dat.InPack2:=ws;
      end;

     wi:=GetAsInteger('EP['+IntToStr(c,CKol)+'].OKP');
     if Sh.OkOp then
      begin
       id^.Dat.OKP   :=wi;
      end;

     ws:=GetAsString('EP['+IntToStr(c,CKol)+'].Massa');
     if Sh.OkOp then
      begin
       id^.Dat.Massa := ws;
      end;

     wi:= GetAsInteger('EP['+IntToStr(c,CKol)+'].BuchGroup');
     if Sh.OkOp then
      begin
       id^.Dat.BuchGroup :=wi;
      end;

     ws:= GetAsString('EP['+IntToStr(c,CKol)+'].Etil');
     if Sh.OkOp then
      begin
       id^.Dat.Etil  :=ws;
      end;

     ws:=GetAsString('EP['+IntToStr(c,CKol)+'].Class');
     if Sh.OkOp then
       begin
        id^.Dat.Class :=ws;
       end;

     wi:=GetAsInteger('EP['+IntToStr(c,CKol)+'].Market');
     if Sh.OkOp then
      begin
       id^.Dat.Market:=wi;
      end;
     wi:=GetAsInteger('EP['+IntToStr(c,CKol)+'].EnableDebit');
     if Sh.OkOp then
     begin
       id^.Dat.EnableDebit:=wi;
       DB^.dAT.EnableDebit :=wi;
     end;

     wi:=GetAsInteger('EP['+IntToStr(c,CKol)+'].Prihod');
     if Sh.OkOp then id^.Dat.Prihod:=wi;

     wi:=GetAsInteger('EP['+IntToStr(c,CKol)+'].VidNalog');
     if Sh.OkOp then id^.Dat.VidNalog :=wi;

     ws:=GetAsString('EP['+IntToStr(c,CKol)+'].Nalog');
     if Sh.OkOp then id^.Dat.Nalog    := ws;

     wi:=GetAsInteger('EP['+IntToStr(c,CKol)+'].VidNDS');
     if Sh.OkOp then id^.Dat.VidNDS   := wi;

     ws:= GetAsString('EP['+IntToStr(c,CKol)+'].NDS');
     if Sh.OkOp then id^.Dat.NDS      := ws;

     ws:= GetAsString('EP['+IntToStr(c,CKol)+'].Mera');
     if Sh.OkOp then id^.Dat.Mera     :=ws;

     wi:=GetAsInteger('EP['+IntToStr(c,CKol)+'].EnableContract');
     if Sh.OkOp then id^.Dat.EnableContract := wi;

     ws:=GetAsString('EP['+IntToStr(c,CKol)+'].Contract');
     if Sh.OkOp then id^.Dat.Contract :=ws;

     ws:=GetAsString('EP['+IntToStr(c,CKol)+'].ContractDate');
     if Sh.OkOp then id^.Dat.ContractDate :=ws;

     wi:=GetAsInteger('EP['+IntToStr(c,CKol)+'].Otdel');
 {!} if Sh.OkOp then id^.Dat.Otdel :=wi;

     wi:=GetAsInteger('EP['+IntToStr(c,CKol)+'].EnableSklads');
     if Sh.OkOp then
      begin
       id^.Dat.EnableSklads :=wi;
       kdx.EnableSklads :=wi;
      end;

     ws:=GetAsString('EP['+IntToStr(c,CKol)+'].Marker');
 {!} if Sh.OkOp then id^.Dat.Marker   :=ws;

     ws:=GetAsString('EP['+IntToStr(c,CKol)+'].Min');
 {!} if Sh.OkOp then id^.Dat.Min      :=ws;

     ws:=GetAsString('EP['+IntToStr(c,CKol)+'].PostKod');
     if Sh.OkOp then id^.Dat.PostKod  :=ws;



     ws:=GetAsString('EP['+IntToStr(c,CKol)+'].FirmaPostKod');
     if Sh.OkOp then
      begin
       id^.Dat.FirmaPostKod  :=ws;
       kdx.FirmaPostKod  := StrToInt(ws);
       ClientExtendedFirmaPost(ws);
      end;

     ws:=GetAsString('EP['+IntToStr(c,CKol)+'].NGroupKod');
     if Sh.OkOp then
      begin
        id^.Dat.NGroupKod:=ws;
        kdx.NGroupKod:=StrToInt(ws);
        ClientExtendedGroup(ws);
      end;

     wi:= GetAsInteger('EP['+IntToStr(c,CKol)+'].Main');
     if Sh.OkOp then id^.Dat.Main  := wi;

     ws:= GetAsString('EP['+IntToStr(c,CKol)+'].FantomKod');
     if Sh.OkOp then
       begin
        id^.Dat.FantomKod:=ws;
        kdx.FantomKod:=StrToInt(ws);
       end;

     ws:=GetAsString('EP['+IntToStr(c,CKol)+'].NSertif');
     if Sh.OkOp then
       begin
        {id^.Dat.KSertif :=ws;}
        kdx.NSertif :=StrToInt(ws);
       end;

    {db}
     sMakeKod:=GetAsString('EP['+IntToStr(c,CKol)+'].MakeKod');
     if Sh.OkOp then
     begin

      db^.Dat.MakeKod:=copy(sMakeKod,2,CMakeKod);
      db^.Dat.MakeVid     := strToInt(copy(sMakeKod,1,1));
     end;

     wi:=GetAsiNTEGER('EP['+IntToStr(c,CKol)+'].MakeKod');
     db^.Dat.iNPUT.USD     :=wi;

     ws:=GetAsString('EP['+IntToStr(c,CKol)+'].ZenaGR');
     db^.Dat.iNPUT.GRZena  :=ws;

      ws:=GetAsString('EP['+IntToStr(c,CKol)+'].NMakeKod');
      if Sh.OkOp then
      begin
      db^.Dat.iNPUT.NMakeKod:=ws;
      kdx.NMakeKod:=StrToInt(sMakeKod);
      end;

          ws:= GetAsString('EP['+IntToStr(c,CKol)+'].Godnost');
	  db^.Dat.Input.Godnost := ws;

    wi:=GetAsiNTEGER('EP['+IntToStr(c,CKol)+'].RegionMarka');
    if Sh.OkOp then
     begin
      kdx.RegionMarka:=wi;
      db^.Dat.iNPUT.RegionMarka:=wi;
     end;

      ws:= GetAsString('EP['+IntToStr(c,CKol)+'].AkzisSbor');
      if Sh.OkOp then
     begin
       db^.Dat.iNPUT.AkzisSbor:=ws;
       kdx.AkzisSbor:=StrToInt(ws);
     end;

      ws:= GetAsString('EP['+IntToStr(c,CKol)+'].ZenaMarki');
      db^.Dat.iNPUT.ZenaMarki:= ws;

          ws:=GetAsString('EP['+IntToStr(c,CKol)+'].NGTD');
          if Sh.OkOp then
          begin
	   db^.Dat.iNPUT.NGTD:=ws;
           kdx.NGTDKod:=StrtoInt(ws);
           ClientExtendedNGTD(ws);
          end;

          ws:=GetAsString('EP['+IntToStr(c,CKol)+'].Marka');
          if Sh.OkOp then
          begin
           kdx.NMarkaKod:=StrToInt(ws);
	   db^.Dat.iNPUT.Marka  := ws;
           ClientExtendedMarka(ws);
          end;

     ws:= GetAsString('EP['+IntToStr(c,CKol)+'].SMarka');
     if Sh.OkOp then
      begin
          db^.Dat.iNPUT.SpecMarka := ws;
          kdx.NSpecMarkaKod := StrToInt(ws);
          ClientExtendedSpecMarka(ws);
      end;

        ws:=GetAsString('EP['+IntToStr(c,CKol)+'].Expert');
        if Sh.OkOp then
      begin
        db^.Dat.iNPUT.Expert :=ws;
        kdx.NExpertKod :=StrToInt(ws);
        ClientExtendedExpert(ws);
      end;

      ws:=GetAsString('EP['+IntToStr(c,CKol)+'].NSertif');
      if Sh.OkOp then
      begin
	  db^.Dat.iNPUT.NSertif :=ws;
          ws:=GetAsString('EP['+IntToStr(c,CKol)+'].SertifName');
          if Sh.OkOp then
            SetSertifName(db^.Dat.iNPUT.NSertif,ws)
      end;

  Res:=ioresult;
  seek(fid,filepos(fid)-1);
  Res:=ioresult;
  write(fid,id^.dat);
  Res:=ioresult;

  seek(KdxFile,filepos(KdxFile)-1);
  Res:=ioresult;
  write(KdxFile,Kdx);
  Res:=ioresult;

  seek(fdb,filepos(fdb)-1);
  Res:=ioresult;
  write(fdb,db^.dat);
  Res:=ioresult;

  Res:=ioresult;
  close(fid);
  Res:=ioresult;
  close(fdb);
  Res:=ioresult;
  close(KdxFile);
  Res:=ioresult;

end;

  dispose(id,done);
  dispose(db,done);

  NoInfoMsg;

{заказ сформирован его необходимо сохранить}

If LockAndWritePredZakaz(ss,Pz) Then
begin
  EraseFile(Path^.Dat.ToWinLnk+'IN\'+s);{уничтожаем архив в TMail}
  EraseFile(Path^.Dat.ToTemp+s);{уничтожаем распакованный текстовый файл PathToTemp}
end;

43:
Dispose(PZ,Done);

44:
{Dispose(Cl,Done);}

45:

SH.Done;

End;



function FormClientFromAgent(kod:ArtikulStr):boolean;
{формирует Client.db Агента выбором из Склада клиентов с маршрутом=kod
 kod - код маршрута
 PathA - путь к client.db Агента
 PathS - путь к client.db Склада}
var FA,FS: ClientFileType;
    cl: PClientType;
    IORez: word;
    mkod: ArtikulStr;
Begin
  FormClientFromAgent:=false;
  DInfoMSg('Формирую базу агентов...',false);
    {Сохраняем старую базу агентов для маршрута}
  Assign(FA,Path^.Dat.ToClient+'agent.db');
  IORez:=IOresult;
  Reset(FA);
  IORez:=IOresult;
  if IORez=0 then
  begin
   Close(FA);
   Assign(FS,Path^.Dat.ToClient+'agent.bak');
   If FExists(Path^.Dat.ToClient+'agent.bak') then Erase(FS);
   Rename(FA,Path^.Dat.ToClient+'agent.bak');
  end;
  {Новя база клиентов для агента}
  Assign(FA,Path^.Dat.ToClient+'agent.db');
  IORez:=IOresult;
  Rewrite(FA);
  IORez:=IOresult;
  if IORez<>0 then
  begin
    {????????????}
    exit;
  end;

  {Открываем складскую базу}
  Assign(FS,NetPath^.Dat.ToClient+'agent.db');
  IORez:=IOresult;
  Reset(FS);
  IORez:=IOresult;
  if IORez<>0 then
  begin
    {????????????}
    Close(FA);
    ERase(FA);
    Assign(FA,Path^.Dat.ToClient+'agent.bak');
    Rename(FA,Path^.Dat.ToClient+'agent.db');
    exit;
  end;

  {Переносим в новую базу агентов с номером  = kod}

  while not eof(FS) do
  begin
    new(cl,Init);
    ReadClient(FS,cl^.Dat);
    If ((sTRtOiNT(cl^.Dat.Kod)=StrToInt(kod)) and cl^.Dat.Employ)
     then
      begin
      mkod:=cl^.Dat.RouteKod;
      cl^.Dat.Employ:=true
      end
      else cl^.Dat.Employ:=false;

    Write(FA,cl^.Dat);
    Dispose(cl,Done);
  end;

  IORez:=ioresult;
  Close(FA);
  IORez:=ioresult;
  Close(FS);
  IORez:=ioresult;
  NoInfoMsg;

DInfoMSg('Формирую базу клиентов...',false);

  {Сохраняем старую базу клиентов для агента}
  Assign(FA,Path^.Dat.ToClient+'client.db');
  IORez:=IOresult;
  Reset(FA);
  IORez:=IOresult;
  if IORez=0 then
  begin
   Close(FA);
   Assign(FS,Path^.Dat.ToClient+'client.bak');
   If FExists(Path^.Dat.ToClient+'client.bak') then Erase(FS);
   Rename(FA,Path^.Dat.ToClient+'client.bak');
  end;
  {Новя база клиентов для агента}
  Assign(FA,Path^.Dat.ToClient+'client.db');
  IORez:=IOresult;
  Rewrite(FA);
  IORez:=IOresult;
  if IORez<>0 then
  begin
    {????????????}
    exit;
  end;

  {Открываем складскую базу}
  Assign(FS,NetPath^.Dat.ToClient+'client.db');
  IORez:=IOresult;
  Reset(FS);
  IORez:=IOresult;
  if IORez<>0 then
  begin
    {????????????}
    Close(FA);
    ERase(FA);
    Assign(FA,Path^.Dat.ToClient+'client.bak');
    Rename(FA,Path^.Dat.ToClient+'client.db');
    exit;
  end;

  {Переносим в новую базу клиентов с номером маршрута = kod}

  while not eof(FS) do
  begin
    new(cl,Init);
    ReadClient(FS,cl^.Dat);
    If (sTRtOiNT(cl^.Dat.RouteKod)=StrToInt(mkod)) and cl^.Dat.Employ then cl^.Dat.Employ:=true
      else
      case sTRtOiNT(cl^.Dat.Kod) of
      999,1601,335,1748: cl^.Dat.Employ:=true
      else cl^.Dat.Employ:=false;
      end;
    Write(FA,cl^.Dat);
    Dispose(cl,Done);
  end;

  IORez:=ioresult;
  Close(FA);
  IORez:=ioresult;
  Close(FS);
  IORez:=ioresult;
NoInfoMsg;
  if iorez=0 then
  FormClientFromAgent:=true;

ENd;


(*
function FormFileList(sTestDate:TDateString): boolean;
var r: trect;
    FC: ClientFileType;
    cl: Clienttype;
    IOrez: word;
    ClList, MrkList,MrkDopList, ErrList: PBox;
    sKOd: String[CClientKod];
    fhis: file of StatClientType;
    his: StatClientType;
    fcpl: file of ClientOplataRealizasiaType;
    cpl: ClientOplataRealizasiaType;
    fcvz : File Of ClientNewVozwratType;
    cvz : ClientNewVozwratType;
    i: word;
    sDate:TDateString;
    err: text;
    s: string;
    l: word;
    TestDate: longint;
    DirInfo : SearchRec;
Begin

TestDate:=DateStringToDate(DateMask,sTestDate);

{ }

R.Assign(0,0,0,0);

ClList := New(PBox, Init(R, 1, Nil));
ClList^.NewList(New(PTextCollection, Init(1,1)));

{Формируем список клиентов}
Assign(fC,Path^.Dat.ToClient+'client.db');
IORez:=ioresult;
Reset(FC);
IORez:=ioresult;
if IORez<>0 then
Begin
  MessageBox(#3^M+#3'Файл не найден ! '+Path^.Dat.ToClient+'client.db Код:'+
  IntToStr(IORez,CKol),Nil,mfError+mfCancelButton);
  Dispose(ClList,Done);
  exit;
end;

While not eof(FC) do
Begin
  read(fc,cl);
  if cl.Employ then
  begin
   sKOd:=cl.kod;
   ClList^.List^.Insert(NewStr(sKod));
   ClList^.SetRange(ClList^.List^.Count);
  end;
End;

IORez:=ioresult;
System.Close(fc);
IORez:=ioresult;

R.Assign(0,0,0,0);

MrkList := New(PBox, Init(R, 1, Nil));
MrkList^.NewList(New(PTextCollection, Init(1,1)));

R.Assign(0,0,0,0);

ErrList := New(PBox, Init(R, 1, Nil));
ErrList^.NewList(New(PTextCollection, Init(1,1)));


{his}
if (ClList<>nil) and (ClList^.List^.Count>0) then
for i:=0 to ClList^.List^.Count-1 do
Begin

 DInfoMSgShkala('Формирую список файлов для репликации...',0,ClList^.List^.Count-1,i);

 sKOd:=ClList^.GetText(i,ClList^.List^.Count);

 {__________mrk}

 Assign(fHis,NetPath^.Dat.ToClientIndex+sKOd+'.his');
 IOrez:=ioresult;
 reset(fHis);
 IOrez:=ioresult;

 if IORez<>0 then
 begin
   {MessageBox(#3^M+#3'Файл не найден ! '+NetPath^.Dat.ToClientIndex+sKOd+'.his',Nil,mfError+mfCancelButton);}
   ErrList^.List^.Insert(NewStr('Отсутствует файл '+NetPath^.Dat.ToClientIndex+sKOd+'.his'));
   ErrList^.SetRange(ErrList^.List^.Count);
   {continue;}
 end
 else
 begin
  if not CompareFile(Path^.Dat.ToClientIndex+sKOd+'.tdx',NetPath^.Dat.ToClientIndex+sKOd+'.tdx') then
  begin
  MrkList^.List^.Insert(NewStr('copy /b '+NetPath^.Dat.ToClientIndex+sKOd+'.tdx '
     +copy(Path^.Dat.ToClientIndex,1,length(Path^.Dat.ToClientIndex)-1)+' '));
  MrkList^.SetRange(MrkList^.List^.Count);
  end;

  if not CompareFile(Path^.Dat.ToClientIndex+sKOd+'.tlx',NetPath^.Dat.ToClientIndex+sKOd+'.tlx') then
  begin
  MrkList^.List^.Insert(NewStr('copy /b '+NetPath^.Dat.ToClientIndex+sKOd+'.tlx '
     +copy(Path^.Dat.ToClientIndex,1,length(Path^.Dat.ToClientIndex)-1)+' '));
  MrkList^.SetRange(MrkList^.List^.Count);
  end;

  if not CompareFile(Path^.Dat.ToClientIndex+sKOd+'.his',NetPath^.Dat.ToClientIndex+sKOd+'.his') then
  begin
  MrkList^.List^.Insert(NewStr('copy /b '+NetPath^.Dat.ToClientIndex+sKOd+'.his '
     +copy(Path^.Dat.ToClientIndex,1,length(Path^.Dat.ToClientIndex)-1)+' '));
  MrkList^.SetRange(MrkList^.List^.Count);
  end;

 while not Eof(fHis) do
 begin
   read(fHis,His);
   sDate:=DateToDateString(DateMask,his.DateC);

  {ПРОДАЖИ}
   if TestDate<DateStringToDate(DateMask,sDate) then
   if not CompareFile(Path^.Dat.ToMarket+sDate+'.mrk',NetPath^.Dat.ToMarket+sDate+'.mrk') then
   begin
   MrkList^.List^.Insert(NewStr('copy /b '+NetPath^.Dat.ToMarket+sDate+'.mrk '
     +copy(Path^.Dat.ToMarket,1,length(Path^.Dat.ToMarket)-1)+' '));
   MrkList^.SetRange(MrkList^.List^.Count);
   end;

   {ИНДЕКСЫ ПРОДАЖ }
   if TestDate<DateStringToDate(DateMask,sDate) then
   if not CompareFile(Path^.Dat.ToMarketIndex+sDate+'.mrx',NetPath^.Dat.ToMarketIndex+sDate+'.mrx') then
   begin
   MrkList^.List^.Insert(NewStr('copy /b '+NetPath^.Dat.ToMarketIndex+sDate+'.mrx '
     +copy(Path^.Dat.ToMarketIndex,1,length(Path^.Dat.ToMarketIndex)-1)+' '));
   MrkList^.SetRange(MrkList^.List^.Count);
   end;

 end; {while}
 end;{else}

 IOrez:=ioresult;
 Close(fHis);
 IOrez:=ioresult;

 {________________________________cpl}
 Assign(fcpl,NetPath^.Dat.ToClientOplata+sKOd+'.cpl');
 IOrez:=ioresult;
 reset(fcpl);
 IOrez:=ioresult;
 if IORez<>0 then
 begin
   ErrList^.List^.Insert(NewStr('Отсутствует файл '+NetPath^.Dat.ToClientOplata+sKOd+'.cpl'));
   ErrList^.SetRange(ErrList^.List^.Count);
   {continue;}
 end
 else
 if not CompareFile(Path^.Dat.ToClientOplata+sKOd+'.cpl',NetPath^.Dat.ToClientOplata+sKOd+'.cpl') then
 begin
   MrkList^.List^.Insert(NewStr('copy /b '+NetPath^.Dat.ToClientOplata+sKOd+'.cpl '
     +copy(Path^.Dat.ToClientOplata,1,length(Path^.Dat.ToClientOplata)-1)+' '));
   MrkList^.SetRange(MrkList^.List^.Count);

 while not Eof(fcpl) do
 begin
   read(fcpl,cpl);
   sDate:=DateToDateString(DateMask,cpl.DateC);
   if TestDate<DateStringToDate(DateMask,sDate) then
   if not CompareFile(Path^.Dat.ToOplata+sDate+'.opl',NetPath^.Dat.ToOplata+sDate+'.opl') then
   begin
   MrkList^.List^.Insert(NewStr('copy /b '+NetPath^.Dat.ToOplata+sDate+'.opl '+copy(Path^.Dat.ToOplata,1,
   length(Path^.Dat.ToOplata)-1)+
   ' '));
   MrkList^.SetRange(MrkList^.List^.Count);
   end;
 end; {while}
 end; {else}

 IOrez:=ioresult;
 Close(fCpl);
 IOrez:=ioresult;

 {____________________cvz}

 Assign(fcvz,NetPath^.Dat.ToClientReturn+sKOd+'.cvz');
 IOrez:=ioresult;
 reset(fcvz);
 IOrez:=ioresult;
 if IORez<>0 then
 begin
   ErrList^.List^.Insert(NewStr('Отсутствует файл '+NetPath^.Dat.ToClientReturn+sKOd+'.cvz'
   ));
   ErrList^.SetRange(ErrList^.List^.Count);
   {continue;}
 end
 else
 if not CompareFile(Path^.Dat.ToClientOplata+sKOd+'.cpl',NetPath^.Dat.ToClientOplata+sKOd+'.cpl') then
 begin
   MrkList^.List^.Insert(NewStr('copy /b '+NetPath^.Dat.ToClientReturn+sKOd+'.cvz '
     +copy(Path^.Dat.ToClientReturn,1,length(Path^.Dat.ToClientReturn)-1)+' '));
   MrkList^.SetRange(MrkList^.List^.Count);
 while not Eof(fcvz) do
 begin
   read(fcvz,cvz);
   sDate:=DateToDateString(DateMask,cvz.Return.DateC);
   if TestDate<DateStringToDate(DateMask,sDate) then
   if not CompareFile(Path^.Dat.ToReturn+sDate+'.vzw',NetPath^.Dat.ToReturn+sDate+'.vzw') then
   begin
   MrkList^.List^.Insert(NewStr('copy /b '+NetPath^.Dat.ToReturn+sDate+'.vzw '
     +copy(Path^.Dat.ToReturn,1,length(Path^.Dat.ToReturn)-1)+' '));
   MrkList^.SetRange(MrkList^.List^.Count);
   end;
 end;  {while}
 end; {else}

 IOrez:=ioresult;
 Close(fcvz);
 IOrez:=ioresult;

 {dlg}
 if Not CompareFile(Path^.Dat.ToDolg+sKOd+'.dlg',NetPath^.Dat.ToDolg+sKOd+'.dlg ') then
 begin
 MrkList^.List^.Insert(NewStr('copy /b '+NetPath^.Dat.ToDolg+sKOd+'.dlg '
     +copy(Path^.Dat.ToDolg,1,length(Path^.Dat.ToDolg)-1)+' '));
 MrkList^.SetRange(MrkList^.List^.Count);
 end;

 NoinfoMsg;

End;

Dispose(Cllist,Done);

 R.Assign(0,0,0,0);

 MrkDopList := New(PBox, Init(R, 1, Nil));
 MrkDopList^.NewList(New(PTextCollection, Init(1,1)));

 {Наименования}
 MrkDopList^.List^.Insert(NewStr('copy /b '+NetPath^.Dat.ToName+'*.* '
     +copy(Path^.Dat.ToName,1,length(Path^.Dat.ToName)-1)+' '));
 MrkDopList^.SetRange(MrkDopList^.List^.Count);

 MrkDopList^.List^.Insert(NewStr('copy /b '+NetPath^.Dat.ToIndex+'*.* '
     +copy(Path^.Dat.ToIndex,1,length(Path^.Dat.ToIndex)-1)+' '));
 MrkDopList^.SetRange(MrkDopList^.List^.Count);

 {Наличие}
 MrkDopList^.List^.Insert(NewStr('copy /b '+NetPath^.Dat.ToSklad+'*.* '
     +copy(Path^.Dat.ToSklad,1,length(Path^.Dat.ToSklad)-1)+' '));
 MrkDopList^.SetRange(MrkDopList^.List^.Count);

 {Справочники}
 MrkDopList^.List^.Insert(NewStr('copy /b '+NetPath^.Dat.ToSPR+'*.* '
     +copy(Path^.Dat.ToSPR,1,length(Path^.Dat.ToSPR)-1)+' '));
 MrkDopList^.SetRange(MrkDopList^.List^.Count);
 {Операторы}
  MrkDopList^.List^.Insert(NewStr('copy /b '+NetPath^.Dat.ToOperator+'*.* '
     +copy(Path^.Dat.ToOperator,1,length(Path^.Dat.ToOperator)-1)+' '));
 MrkDopList^.SetRange(MrkDopList^.List^.Count);
  {Архив кассы}

DInfoMSg('Формирую список копируемых файлов',false);

  {Архив DLG}
FindFirst(NetPath^.Dat.ToArchiv+'*.d'+copy(Rek^.dat.Kod,3,2), AnyFile, DirInfo);
while DosError = 0 do
begin
   if not CompareFile(Path^.Dat.ToArchiv+DirInfo.Name,NetPath^.Dat.ToArchiv+DirInfo.Name) then
   begin
    MrkDopList^.List^.Insert(NewStr('copy /b '+NetPath^.Dat.ToArchiv+
    DirInfo.Name+
    ' '  +copy(Path^.Dat.ToArchiv,1,length(Path^.Dat.ToArchiv)-1)+' '));
    MrkDopList^.SetRange(MrkDopList^.List^.Count);
   end;
    FindNext(DirInfo);
end;{While}

   {Фотографии}
FindFirst(NetPath^.Dat.ToPhoto+'*.*', AnyFile, DirInfo);
while DosError = 0 do
begin
   if not CompareFile(Path^.Dat.ToPhoto+DirInfo.Name,NetPath^.Dat.ToPhoto+DirInfo.Name) then
   begin
    MrkDopList^.List^.Insert(NewStr('copy /b '+NetPath^.Dat.ToPhoto+
   NetPath^.Dat.ToPhoto+DirInfo.Name +
   ' '  +copy(Path^.Dat.ToPhoto,1,length(Path^.Dat.ToArchiv)-1)+' '));
   MrkDopList^.SetRange(MrkDopList^.List^.Count);
   end;
    FindNext(DirInfo);
end;{While}

    {Скидки}
   MrkDopList^.List^.Insert(NewStr('copy /b '+NetPath^.Dat.ToSkidki+
 '*.*'+
   ' '+copy(Path^.Dat.ToSkidki,1,length(Path^.Dat.ToSkidki)-1)+' '));
   MrkDopList^.SetRange(MrkDopList^.List^.Count);

   {Поставщики}
   MrkDopList^.List^.Insert(NewStr('copy /b '+NetPath^.Dat.ToClient+
 'make.db'+
   ' '+copy(Path^.Dat.ToClient,1,length(Path^.Dat.ToClient)-1)+' '));
   MrkDopList^.SetRange(MrkDopList^.List^.Count);
     MrkDopList^.List^.Insert(NewStr('copy /b '+NetPath^.Dat.ToClient+
 'sklad.db'+
   ' '+copy(Path^.Dat.ToClient,1,length(Path^.Dat.ToClient)-1)+' '));
   MrkDopList^.SetRange(MrkDopList^.List^.Count);
   MrkDopList^.List^.Insert(NewStr('copy /b '+NetPath^.Dat.ToClient+
 'barter.db'+
   ' '+copy(Path^.Dat.ToClient,1,length(Path^.Dat.ToClient)-1)+' '));
   MrkDopList^.SetRange(MrkDopList^.List^.Count);


NoInfoMsg;

if (ErrList<>nil) and (ErrList^.List^.Count>0) then
begin
  Assign(err,Path^.Dat.ToTemp+'reperr.txt');
  IORez:=ioresult;
  Rewrite(err);
  IORez:=ioresult;
  for i:=0 to ErrList^.List^.Count-1 do
  begin
    s:=ErrList^.GetText(i,ErrList^.List^.Count);
    writeln(err,s);
  end;
  IORez:=ioresult;
  system.close(err);
  IORez:=ioresult;
end;

Dispose(ErrList,Done);

CopyFileWithList(MrkList,'Копирование файлов ...');
CopyFileWithList(MrkDopList,'Копирование файлов ...');

  LastOstDate:=ToDay;
  LastOstTime:=CurrentTime;

  SetLastOst;
  SetLastSpr;
  SetLastCl;

Dispose(MrkList,Done);
Dispose(MrkDopList,Done);


End;
*)

function FormFileList(sTestDate:TDateString): boolean;
var r: trect;
    FC: File;
    cl: PBufClienttype;
    IOrez: word;
    ClList, MrkList,MrkDopList, ErrList: PBox;
    sKOd: String[CClientKod];
    fhis: file;
    fcpl: file;
    cpl: PBufClientOplataRealizasiaType;
    fcvz : File;
    cvz : PBufClientNewVozwratType;
    i,j: word;
    sDate:TDateString;
    err: text;
    s: string;
    l: word;
    TestDate: longint;
    SSDate : AllStr;
    DirInfo : SearchRec;
    Dlg: PBufRealizasiaType;
    fDlg: File;
    His : PBufStatClientType;
Begin

TestDate:=DateStringToDate(DateMask,sTestDate);

{ }

R.Assign(0,0,0,0);

ClList := New(PBox, Init(R, 1, Nil));
ClList^.NewList(New(PTextCollection, Init(1,1)));

{Формируем список клиентов}
Assign(fC,Path^.Dat.ToClient+'client.db');
IORez:=ioresult;
Reset(FC,SizeOf(ClientType));
IORez:=ioresult;
if IORez<>0 then
Begin
  MessageBox(#3^M+#3'Файл не найден ! '+Path^.Dat.ToClient+'client.db Код:'+
  IntToStr(IORez,CKol),Nil,mfError+mfCancelButton);
  Dispose(ClList,Done);
  exit;
end;

While not eof(FC) do
Begin
   New(Cl,Init);
   Count:=0;
   BlockRead(fC,Cl^.Point,Buffer,Count);
   For j:=1 To Count Do
   Begin
    if cl^.Point.Dat[j].Employ then
    begin
     RFormatZerro(cl^.Point.Dat[j].Kod,CClientKod);
     sKOd:=cl^.Point.Dat[j].kod;
     ClList^.List^.Insert(NewStr(sKod));
     ClList^.SetRange(ClList^.List^.Count);
    end;
  End;{For}
  Dispose(Cl,Done);
End;{While}


IORez:=ioresult;
System.Close(fc);
IORez:=ioresult;

R.Assign(0,0,0,0);

MrkList := New(PBox, Init(R, 1, Nil));
MrkList^.NewList(New(PTextCollection, Init(1,1)));

R.Assign(0,0,0,0);

ErrList := New(PBox, Init(R, 1, Nil));
ErrList^.NewList(New(PTextCollection, Init(1,1)));


{his}
if (ClList<>nil) and (ClList^.List^.Count>0) then
for i:=0 to ClList^.List^.Count-1 do
Begin

 DInfoMSgShkala('Формирую список файлов для репликации...',0,ClList^.List^.Count-1,i);

 sKOd:=ClList^.GetText(i,ClList^.List^.Count);

 {__________mrk}

 Assign(fHis,NetPath^.Dat.ToClientIndex+sKOd+'.his');
 IOrez:=ioresult;
 reset(fHis,SizeOf(StatClientType));
 IOrez:=ioresult;

 if IORez<>0 then
 begin
   {MessageBox(#3^M+#3'Файл не найден ! '+NetPath^.Dat.ToClientIndex+sKOd+'.his',Nil,mfError+mfCancelButton);}
   ErrList^.List^.Insert(NewStr('Отсутствует файл '+NetPath^.Dat.ToClientIndex+sKOd+'.his'));
   ErrList^.SetRange(ErrList^.List^.Count);
   {continue;}
 end
 else
 begin
  if not CompareFile(Path^.Dat.ToClientIndex+sKOd+'.tdx',NetPath^.Dat.ToClientIndex+sKOd+'.tdx') then
  begin
  MrkList^.List^.Insert(NewStr('copy /b '+NetPath^.Dat.ToClientIndex+sKOd+'.tdx '
     +copy(Path^.Dat.ToClientIndex,1,length(Path^.Dat.ToClientIndex)-1)+' '));
  MrkList^.SetRange(MrkList^.List^.Count);
  end;

  if not CompareFile(Path^.Dat.ToClientIndex+sKOd+'.tlx',NetPath^.Dat.ToClientIndex+sKOd+'.tlx') then
  begin
  MrkList^.List^.Insert(NewStr('copy /b '+NetPath^.Dat.ToClientIndex+sKOd+'.tlx '
     +copy(Path^.Dat.ToClientIndex,1,length(Path^.Dat.ToClientIndex)-1)+' '));
  MrkList^.SetRange(MrkList^.List^.Count);
  end;

  if not CompareFile(Path^.Dat.ToClientIndex+sKOd+'.his',NetPath^.Dat.ToClientIndex+sKOd+'.his') then
  begin
  MrkList^.List^.Insert(NewStr('copy /b '+NetPath^.Dat.ToClientIndex+sKOd+'.his '
     +copy(Path^.Dat.ToClientIndex,1,length(Path^.Dat.ToClientIndex)-1)+' '));
  MrkList^.SetRange(MrkList^.List^.Count);
  end;




 while not Eof(fHis) do
 begin
   New(His,Init);
   Count:=0;
   BlockRead(fHis,His^.Point,BufferHis,Count);
   For j:=1 To Count Do
   Begin
   If His^.Point.Dat[j].Active Then
   Begin
   sDate:=DateToDateString(DateMask,His^.Point.Dat[j].DateC);

  {ПРОДАЖИ}
   s:='';
   if TestDate<DateStringToDate(DateMask,sDate) then
   if not CompareFile(Path^.Dat.ToMarket+sDate+'.mrk',NetPath^.Dat.ToMarket+sDate+'.mrk') then
   begin
   s:='copy /b '+NetPath^.Dat.ToMarket+sDate+'.mrk '
     +copy(Path^.Dat.ToMarket,1,length(Path^.Dat.ToMarket)-1)+' ';
   if not TestHisElement(MrkList,s) then
    begin
     {memc(s+' !');}
     MrkList^.List^.Insert(NewStr(s));
     MrkList^.SetRange(MrkList^.List^.Count);
    end;
   end;

   {ИНДЕКСЫ ПРОДАЖ }
   s:='';
   if TestDate<DateStringToDate(DateMask,sDate) then
   if not CompareFile(Path^.Dat.ToMarketIndex+sDate+'.mrx',NetPath^.Dat.ToMarketIndex+sDate+'.mrx') then
   begin
   s:='copy /b '+NetPath^.Dat.ToMarketIndex+sDate+'.mrx '
     +copy(Path^.Dat.ToMarketIndex,1,length(Path^.Dat.ToMarketIndex)-1)+' ';
   if not TestHisElement(MrkList,s) then
    begin
     MrkList^.List^.Insert(NewStr(s));
     MrkList^.SetRange(MrkList^.List^.Count);
    end;
   end;
   End;{Active}
  End;{For j}
  Dispose(His,Done);
 end; {while}
 end;{else}


 IOrez:=ioresult;
 Close(fHis);
 IOrez:=ioresult;

 {________________________________cpl}
 Assign(fcpl,NetPath^.Dat.ToClientOplata+sKOd+'.cpl');
 IOrez:=ioresult;
 reset(fcpl,SizeOf(ClientOplataRealizasiaType));
 IOrez:=ioresult;
 if IORez<>0 then
 begin
   ErrList^.List^.Insert(NewStr('Отсутствует файл '+NetPath^.Dat.ToClientOplata+sKOd+'.cpl'));
   ErrList^.SetRange(ErrList^.List^.Count);
   {continue;}
 end
 else

 if not CompareFile(Path^.Dat.ToClientOplata+sKOd+'.cpl',NetPath^.Dat.ToClientOplata+sKOd+'.cpl') then
 begin
   MrkList^.List^.Insert(NewStr('copy /b '+NetPath^.Dat.ToClientOplata+sKOd+'.cpl '
     +copy(Path^.Dat.ToClientOplata,1,length(Path^.Dat.ToClientOplata)-1)+' '));
   MrkList^.SetRange(MrkList^.List^.Count);

 while not Eof(fcpl) do
 begin
  New(Cpl,Init);
  Count:=0;
  BloCkRead(fCpl,Cpl^.Point,BufferCOpl,Count);
  For j:=1 To Count Do
  Begin
   sDate:=DateToDateString(DateMask,cpl^.Point.Dat[j].DateC);
   if TestDate<DateStringToDate(DateMask,sDate) then
   if not CompareFile(Path^.Dat.ToOplata+sDate+'.opl',NetPath^.Dat.ToOplata+sDate+'.opl') then
   begin
   MrkList^.List^.Insert(NewStr('copy /b '+NetPath^.Dat.ToOplata+sDate+'.opl '+copy(Path^.Dat.ToOplata,1,
   length(Path^.Dat.ToOplata)-1)+
   ' '));
   MrkList^.SetRange(MrkList^.List^.Count);
   end;
  End;{For j}
  Dispose(Cpl,Done)
 end; {while}

 end; {else}



 IOrez:=ioresult;
 Close(fCpl);
 IOrez:=ioresult;

 {____________________cvz}

 Assign(fcvz,NetPath^.Dat.ToClientReturn+sKOd+'.cvz');
 IOrez:=ioresult;
 reset(fcvz,SizeOf(ClientNewVozwratType));
 IOrez:=ioresult;
 if IORez<>0 then
 begin
   ErrList^.List^.Insert(NewStr('Отсутствует файл '+NetPath^.Dat.ToClientReturn+sKOd+'.cvz'
   ));
   ErrList^.SetRange(ErrList^.List^.Count);
   {continue;}
 end
 else
 if not CompareFile(Path^.Dat.ToClientReturn+sKOd+'.cvz',NetPath^.Dat.ToClientReturn+sKOd+'.cvz') then
 begin
   MrkList^.List^.Insert(NewStr('copy /b '+NetPath^.Dat.ToClientReturn+sKOd+'.cvz '
     +copy(Path^.Dat.ToClientReturn,1,length(Path^.Dat.ToClientReturn)-1)+' '));
   MrkList^.SetRange(MrkList^.List^.Count);

 while not Eof(fcvz) do
 begin
  New(cvz,Init);
  Count:=0;
  BlockRead(fCvz,Cvz^.Point,BufferCVzw,Count);
  For j:=1 To Count Do
  Begin
   sDate:=DateToDateString(DateMask,cvz^.Point.Dat[j].Return.DateC);
   if TestDate<DateStringToDate(DateMask,sDate) then
   if not CompareFile(Path^.Dat.ToReturn+sDate+'.vzw',NetPath^.Dat.ToReturn+sDate+'.vzw') then
   begin
   MrkList^.List^.Insert(NewStr('copy /b '+NetPath^.Dat.ToReturn+sDate+'.vzw '
   +copy(Path^.Dat.ToReturn,1,length(Path^.Dat.ToReturn)-1)+' '));
   MrkList^.SetRange(MrkList^.List^.Count);
   end;

  {ПРОДАЖИ}
   s:='';
   SSDate:=DateToDateString(DateMask,cvz^.Point.Dat[j].Return.BasisDate);
   if TestDate<cvz^.Point.Dat[j].Return.BasisDate then
   if not CompareFile(Path^.Dat.ToMarket+SSDate+'.mrk',NetPath^.Dat.ToMarket+
   SDate+'.mrk') then
   begin
   s:='copy /b '+NetPath^.Dat.ToMarket+SSDate+'.mrk '
     +copy(Path^.Dat.ToMarket,1,length(Path^.Dat.ToMarket)-1)+' ';
   if not TestHisElement(MrkList,s) then
    begin
     MrkList^.List^.Insert(NewStr(s));
     MrkList^.SetRange(MrkList^.List^.Count);
    end;
   end;

   {ИНДЕКСЫ ПРОДАЖ }
   s:='';
   SSDate:=DateToDateString(DateMask,cvz^.Point.Dat[j].Return.BasisDate);
   if TestDate<cvz^.Point.Dat[j].Return.BasisDate then
   if not CompareFile(Path^.Dat.ToMarketIndex+SsDate+'.mrx',NetPath^.Dat.ToMarketIndex+SsDate+'.mrx') then
   begin
   s:='copy /b '+NetPath^.Dat.ToMarketIndex+SsDate+'.mrx '
     +copy(Path^.Dat.ToMarketIndex,1,length(Path^.Dat.ToMarketIndex)-1)+' ';
   if not TestHisElement(MrkList,s) then
    begin
     MrkList^.List^.Insert(NewStr(s));
     MrkList^.SetRange(MrkList^.List^.Count);
    end;
   end;

  End;{For j}
   Dispose(Cvz,Done);
 end;  {while}
 end; {else}


 IOrez:=ioresult;
 Close(fcvz);
 IOrez:=ioresult;

 {dlg}
 if Not CompareFile(Path^.Dat.ToDolg+sKOd+'.dlg',NetPath^.Dat.ToDolg+sKOd+'.dlg ') then
 begin
 {}
 Assign(fDlg,NetPath^.Dat.ToDolg+sKOd+'.dlg');
 IOrez:=ioresult;
 Reset(fDlg,SizeOf(RealizasiaType));
 IOrez:=ioresult;

 if IORez=0 then
 begin

 while not eof(fDlg) do
 begin
  New(Dlg,Init);
  Count:=0;
  BloCkRead(fDlg,Dlg^.Point,BufferDLG,Count);
  For j:=1 To Count Do TestDolgMrkDate(MrkList,Dlg^.Point.Dat[j]);
  Dispose(Dlg,Done);
 end;

 IOrez:=ioresult;
 System.Close(fDlg);
 IOrez:=ioresult;

 end;

 MrkList^.List^.Insert(NewStr('copy /b '+NetPath^.Dat.ToDolg+sKOd+'.dlg '
     +copy(Path^.Dat.ToDolg,1,length(Path^.Dat.ToDolg)-1)+' '));
 MrkList^.SetRange(MrkList^.List^.Count);
 end;

 NoinfoMsg;

End;

Dispose(Cllist,Done);

 R.Assign(0,0,0,0);

 MrkDopList := New(PBox, Init(R, 1, Nil));
 MrkDopList^.NewList(New(PTextCollection, Init(1,1)));

 {Наименования}
 MrkDopList^.List^.Insert(NewStr('copy /b '+NetPath^.Dat.ToName+'*.* '
     +copy(Path^.Dat.ToName,1,length(Path^.Dat.ToName)-1)+' '));
 MrkDopList^.SetRange(MrkDopList^.List^.Count);

 MrkDopList^.List^.Insert(NewStr('copy /b '+NetPath^.Dat.ToIndex+'*.* '
     +copy(Path^.Dat.ToIndex,1,length(Path^.Dat.ToIndex)-1)+' '));
 MrkDopList^.SetRange(MrkDopList^.List^.Count);

 {Наличие}
 MrkDopList^.List^.Insert(NewStr('copy /b '+NetPath^.Dat.ToSklad+'*.* '
     +copy(Path^.Dat.ToSklad,1,length(Path^.Dat.ToSklad)-1)+' '));
 MrkDopList^.SetRange(MrkDopList^.List^.Count);

 {Справочники}
 MrkDopList^.List^.Insert(NewStr('copy /b '+NetPath^.Dat.ToSPR+'*.* '
     +copy(Path^.Dat.ToSPR,1,length(Path^.Dat.ToSPR)-1)+' '));
 MrkDopList^.SetRange(MrkDopList^.List^.Count);
 {Операторы}
  MrkDopList^.List^.Insert(NewStr('copy /b '+NetPath^.Dat.ToOperator+'*.* '
     +copy(Path^.Dat.ToOperator,1,length(Path^.Dat.ToOperator)-1)+' '));
 MrkDopList^.SetRange(MrkDopList^.List^.Count);

(* {Реквизиты}
 MrkList^.List^.Insert(NewStr('copy /b '+NetPath^.Dat.ToRekwiziti+'*.* '
     +copy(Path^.Dat.ToRekwiziti,1,length(Path^.Dat.ToRekwiziti)-1)+' '+NullStr^));
 MrkList^.SetRange(MrkList^.List^.Count);*)

 {Архив кассы}
(*
 MrkList^.List^.Insert(NewStr('copy /b '+NetPath^.Dat.ToArchiv+
 DateToDateString(DateMask,(DateStringToDate(DateMask,FDate)-1))+'.k'+copy(Rek^.dat.Kod,3,2)+
   ' '  +copy(Path^.Dat.ToArchiv,1,length(Path^.Dat.ToArchiv)-1)+' '+NullStr^));
 MrkList^.SetRange(MrkList^.List^.Count);
*)

DInfoMSg('Формирую список копируемых файлов',false);

  {Архив DLG}
FindFirst(NetPath^.Dat.ToArchiv+'*.d'+copy(Rek^.dat.Kod,3,2), Archive, DirInfo);
while DosError = 0 do
begin
   if not CompareFile(Path^.Dat.ToArchiv+DirInfo.Name,NetPath^.Dat.ToArchiv+DirInfo.Name) then
   begin
    MrkDopList^.List^.Insert(NewStr('copy /b '+NetPath^.Dat.ToArchiv+
    DirInfo.Name+
    ' '  +copy(Path^.Dat.ToArchiv,1,length(Path^.Dat.ToArchiv)-1)+' '));
    MrkDopList^.SetRange(MrkDopList^.List^.Count);
   end;
    FindNext(DirInfo);
end;{While}

   {Фотографии}
FindFirst(NetPath^.Dat.ToPhoto+'*.*', Archive, DirInfo);
while DosError = 0 do
begin
   if not CompareFile(Path^.Dat.ToPhoto+DirInfo.Name,NetPath^.Dat.ToPhoto+DirInfo.Name) then
   begin
    MrkDopList^.List^.Insert(NewStr('copy /b '+NetPath^.Dat.ToPhoto+
   NetPath^.Dat.ToPhoto+DirInfo.Name +
   ' '  +copy(Path^.Dat.ToPhoto,1,length(Path^.Dat.ToArchiv)-1)+' '));
   MrkDopList^.SetRange(MrkDopList^.List^.Count);
   end;
    FindNext(DirInfo);
end;{While}

    {Скидки}
   MrkDopList^.List^.Insert(NewStr('copy /b '+NetPath^.Dat.ToSkidki+
 '*.skl'+
   ' '+copy(Path^.Dat.ToSkidki,1,length(Path^.Dat.ToSkidki)-1)+' '));
   MrkDopList^.SetRange(MrkDopList^.List^.Count);

   {Поставщики}
   MrkDopList^.List^.Insert(NewStr('copy /b '+NetPath^.Dat.ToClient+
 'make.db'+
   ' '+copy(Path^.Dat.ToClient,1,length(Path^.Dat.ToClient)-1)+' '));
   MrkDopList^.SetRange(MrkDopList^.List^.Count);
     MrkDopList^.List^.Insert(NewStr('copy /b '+NetPath^.Dat.ToClient+
 'sklad.db'+
   ' '+copy(Path^.Dat.ToClient,1,length(Path^.Dat.ToClient)-1)+' '));
   MrkDopList^.SetRange(MrkDopList^.List^.Count);
   MrkDopList^.List^.Insert(NewStr('copy /b '+NetPath^.Dat.ToClient+
 'barter.db'+
   ' '+copy(Path^.Dat.ToClient,1,length(Path^.Dat.ToClient)-1)+' '));
   MrkDopList^.SetRange(MrkDopList^.List^.Count);


NoInfoMsg;

if (ErrList<>nil) and (ErrList^.List^.Count>0) then
begin
  Assign(err,Path^.Dat.ToTemp+'reperr.txt');
  IORez:=ioresult;
  Rewrite(err);
  IORez:=ioresult;
  for i:=0 to ErrList^.List^.Count-1 do
  begin
    s:=ErrList^.GetText(i,ErrList^.List^.Count);
    writeln(err,s);
  end;
  IORez:=ioresult;
  system.close(err);
  IORez:=ioresult;
end;

Dispose(ErrList,Done);

CopyFileWithList(MrkList,'Копирование файлов ...');
CopyFileWithList(MrkDopList,'Копирование файлов...');

  LastOstDate:=ToDay;
  LastOstTime:=CurrentTime;

  SetLastOst;
  SetLastSpr;
  SetLastCl;

Dispose(MrkList,Done);
Dispose(MrkDopList,Done);


End;



Function SetPodpis(AS:DocumentEditZ;p:word):boolean;
var fId  : file of ZakazType;
    id   : PZakazType;
    lh   : PHeaderZakazType;
    HeaderFile : HeaderZakazFileType;
    find : boolean;
    l    : LongInt;
    Code,OldStatus : Integer;
    st   : ArtikulStr;
    FName: string;
Begin
  SetPodpis:=false;
  find:=false;
 Assign(fId,Path^.Dat.ToMarket+'zakaz.db');
 l:=IOResult;
 Reset(fid);
 l:=IOResult;
 If l <> 0 Then
 Begin
  Errors(Path^.Dat.ToMarket+'zakaz.db :'+IntToStr(l,4));
  AddProtocol(Path^.Dat.ToMarket+'zakaz.db :'+IntToStr(l,4),'','');
  Exit;
 End
 Else
 begin
         New(id,Init);
         Code:=IOResult;
         seek(fId,StrToInt(As.EditPosition)-1);
         Code:=IOResult;
         Read(fid,id^.Dat);
         find:=True;
         OldStatus:=Id^.Dat.Status;
         Id^.Dat.Status:=p;
         Code:=IOResult;
         seek(fId,StrToInt(As.EditPosition)-1);
         Code:=IOResult;
         write(fId,Id^.Dat);
         Code:=IOResult;
         New(Lh,Init);
         ZakazToIndex(Id,Lh);
         l:=IOResult;
         Assign(HeaderFile,Path^.Dat.ToMarketIndex+'zakaz.idx');
         l:=IOResult;
         Reset(HeaderFile);
         l:=IOResult;
         if l<>0 then
         begin
           Close(fid);
           Errors('Ошибка открытия '+Path^.Dat.ToMarketIndex+'zakaz.idx: '+IntToStr(l,4));
           AddProtocol('Ошибка открытия '+Path^.Dat.ToMarketIndex+'zakaz.idx: '+IntToStr(l,4),'','');
           exit
         end;
         l:=IOResult;
         {memc(As.EditPosition);}
         Seek(HeaderFile,StrToInt(As.EditPosition)-1);
         l:=IOResult;
         write(HeaderFile,lh^.dat);
         l:=IOResult;
         if l<>0 then
         begin
           Close(fid);
           Errors('Ошибка записи '+Path^.Dat.ToMarketIndex+'zakaz.idx: '+IntToStr(l,4));
           AddProtocol('Ошибка записи '+Path^.Dat.ToMarketIndex+'zakaz.idx: '+IntToStr(l,4),'','');
           exit
         end;
         System.Close(HeaderFile);
         Dispose(Lh,Done);
     Code:=IOResult;
     Close(fid);
     Code:=IOResult;
     Dispose(Id,Done);

     if (OldStatus=1) and (p=0) then
     begin
       {статус изменился с подписи на оформление прибить файл в T-Mail}
       Fname:=GetExportFileNameClientNew(As,Rek^.Dat.KOd,Rek^.Dat.AgentKOd);
       EraseFile(Path^.Dat.ToWinLnk+'OUT\'+FName);
       If FExists(Path^.Dat.ToTemp+FName) Then EraseFile(Path^.Dat.ToTemp+FName);
     end;
     AddProtocol('Статус заказа N '+As.EditPosition+' изменен с '+IntToStr(OldStatus,3)+' на '+IntToStr(p,3),'','');
     SetPodpis:=true;
 end;

End;

function SendCLMail(AS:DocumentEditZ):boolean;
var f: file of ZakazType;
    fz: text;
    fer: file;
    z: PZakazType;
    IORez:word;
    find, OK: boolean;
    s,FName,ss,ZakName: string;
    Result: LongInt;
    Event : TEvent;
    DZ : PZakazType;

Begin
  SendCLMail:=false;
  OK:=true;
  FName:=Path^.Dat.ToMarket+'zakaz.db';
  If not FExists(FName) then
  begin
    MessageBox(#3'Отсутствует файл заявок !'^M+
         #3+Path^.Dat.ToMarket+'zakaz.db',Nil,
         mfWarning+mfOkCancel);
    exit;
  end;

  ZakName:=GetExportFileNameClientNew(As,Rek^.Dat.KOd,Rek^.Dat.AgentKOd);
  OK:=true;

 (* If FExists(PathExpImp^.Dat.ToExport[1]+ZakName) Then
     Begin
       {If HiddenAttribute(PathExpImp^.Dat.ToExport[1]+ZakName) then}       begin
         OK:=false;
         if MessageBox('Заказ N'+AS.EditPosition+' от '+As.D+' уже был успешно импортирован! Повторить импорт заказа? ',Nil,
            mfWarning+mfOkCancel) = cmOk then Ok:=true
          else exit;
       end;
     End;   *)



{формирование и упаковка заказа}
New(DZ,Init);
GetZakaz(As.EditPosition,DZ);

If DZ^.Dat.Status=0 Then
if FExists(Path^.Dat.ToWinLnk+'out\'+ZakName) then
 begin
   Assign(fer,Path^.Dat.ToWinLnk+'out\'+ZakName);
   Erase(fer);
 end;

Dispose(DZ,Done);


If Ok{not FExists(PathExpImp^.Dat.ToExport[1]+ZakName)} Then
begin

  Assign(f,FName);
  IORez:=ioresult;
  Reset(f);
  IORez:=ioresult;
  find:=false;
  New(z,Init);
  IORez:=ioresult;
  Seek(f,StrToInt(As.EditPosition)-1);
  IORez:=ioresult;
  Read(f,z^.Dat);
  if z^.Dat.Status = 0 then
    begin
     Assign(fz,Path^.Dat.ToTemp+ZakName);
     IORez:=ioresult;
     Rewrite(fz);
     IORez:=ioresult;
     if IORez<>0 then
       begin
         Dispose(z,Done);
         Close(f);
         exit;
       end;
     IORez:=ioresult;

     WriteMailFile(fz,z^.Dat);

     IORez:=ioresult;
     System.Close(fz);
     IORez:=ioresult;

     if  PackMailFileClientNew(ZakName, Rek^.Dat.kod) Then
        begin
          find:=true;
        end;

    {случай не упаковали}
    if not find then
    begin
    AddProtocol('Ошибка подписи заказа N '+AS.EditPosition+' от '+As.D+' !'+
       '  Статус заказа = '+IntToStr(z^.Dat.Status,2),'','');
    MessageBox(^M+#3'Ошибка подписи заказа N '+AS.EditPosition+' от '+As.D+' !'+
       '  Статус заказа = '+IntToStr(z^.Dat.Status,2),Nil,
         mfWarning+mfOkCancel)
    end
    else
     begin
       SetPodpis(As,1);{упаковали}
       AddProtocol('Подпись заказа N'+AS.EditPosition+' от '+As.D,'','');

     Sound(100);
     DInfoMsg('Заказ N'+AS.EditPosition+' от '+As.D+' был успешно подписан!',False);
     NoSound;
     Application^.ClearEvent(Event);
     Application^.GetEvent(Event);
     Application^.ClearEvent(Event);
     repeat
       Application^.GetEvent(Event);
     until (Event.What <> evNothing) And (Event.Command<>cmMenu);
     NoInfoMsg;
     Application^.ClearEvent(Event);
       SendCLMail:=true;
     end;


    end
    Else
      Begin
If z^.Dat.Status in [1,2,5,6] Then
Begin
     Case z^.Dat.Status Of
     1:ss:='Заказ N'+AS.EditPosition+' уже подписан!';
     2:ss:='Заказ N'+AS.EditPosition+' уже отправлен!';
     5:ss:='Заказ N'+AS.EditPosition+' уже подтвержден!';
     6:ss:='Заказ N'+AS.EditPosition+' уже анулирован!';
     Else;
     End;

     Sound(100);
     DInfoMsg(ss,False);
     NoSound;
     Application^.ClearEvent(Event);
     Application^.GetEvent(Event);
     Application^.ClearEvent(Event);
     repeat
       Application^.GetEvent(Event);
     until (Event.What <> evNothing) And (Event.Command<>cmMenu);
     NoInfoMsg;
     Application^.ClearEvent(Event);
End;
      End;

  IORez:=ioresult;
  system.close(f);
  IORez:=ioresult;

   Dispose(z,Done);

End;
End;

function WriteSendFileStatus(FName:string;bName:boolean):boolean;
    {bName = false - подпись по содержимому
     bName = true  - подпись по имени файла}
Var SH: TStringHolder;
    s,ss: TMyString;
    txt: text;
    Res: word;
    Document:ArtikulStr;
    Ass:DocumentEditZ;
    f: file;
Begin
WriteSendFileStatus:=false;
 {распаковываем в Temp}
 {А распаковывать - то нечего! ... одно имя осталось}
DelSpace(FName);
s:=FName;

if not bName then
{по содержимому}
begin
  Assign (txt,Path^.Dat.ToTemp+s);
  Res := IOResult;
  Reset(txt);
  Res := IOResult;
  If Res <> 0 Then
   Begin
    AddProtocol('Ошибка установки статуса отправки'+Path^.Dat.ToTemp+s+' Код:'+IntToStr(Res,CKol),'','');
    MessageBox(#3^M+#3'Файл не найден ! '++Path^.Dat.ToTemp+s+' Код:'+IntToStr(Res,CKol),Nil,mfError+mfCancelButton);
    Exit;
   End;
  Res := IOResult;
  Close(txt);
  Res := IOResult;

  SH.Init;
  SH.LoadFromFile (Path^.Dat.ToTemp+s);

  {читаем номер заказа}
  Document:=SH.GetString('ZakazNumer');

   if SH.OkOp then
   begin
     {устанавливаем статус}
      Ass.EditPosition:=Document;
      if SetPodpis(Ass,2) then
      begin
        WriteSendFileStatus:=true;
        EraseFile(Path^.Dat.ToTemp+s);
      end;
   end
   else
   begin
    Errors('Не обнаружен параметр ZakazNumer ');
    AddProtocol('Не обнаружен параметр ZakazNumer заказа '+s,'','');
   end;

end
else
{по имени файла}
begin
 Ass.EditPosition:=copy(s,2,5);
 if SetPodpis(Ass,2) then
 WriteSendFileStatus:=true;
end;


End;



function InMailSelect(s:string):boolean;
var f: file;
    ss: string;
    kod:word;
    MessFile:text;
    Result: word;
    DirInfo: SearchRec;
Begin
     {обновление клиентской базы}
   if pos(ClientPrefix,s)=1 then
   begin
     AddProtocol('Получено обновление базы клиентов '+s,'','');
     If UnpackClientBase(s) Then ClientIDX(True);
   end;

     {Пришли справочники}
   if pos(SPRPrefix,s)=1 then
   begin
     AddProtocol('Получено обновление справочников '+s,'','');
     ss:='';
      if UnpackSpr(s) then
      begin
        Assign(f,Path^.Dat.ToWinLnk+'IN\'+s);
        Erase(f);
      end;
   End;

   {ответы на заявки}
   if pos(ConfirmationPredZakazPrefix,s)=1 then
   begin
     AddProtocol('Получено подтверждение заказа '+s,'','');
     LoadMailFile(S);
   end;

   {обновление остатков}
   if pos(OstatkiPrefix,s)=1 then
   begin
    {Анализ расширения}
    AddProtocol('Получены остатки '+s,'','');
    kod:=StrToInt(copy(s,pos('.',s)+1,LENGTH(S)-POS('.',s)));

    if kod<>StrToInt(Rek^.Dat.Kod) then
    begin
      {Полученные остатки не соответствуют коду объекта}
      AddProtocol('Полученные остатки не соответствуют коду объекта! Файл '+s,'','');
      EraseFile(Path^.Dat.ToWinLnk+'IN\'+s);
    end
    else
    begin
      ss:='';
      if UnpackMailFileClientNew(s,ss) then
      begin
        Assign(f,Path^.Dat.ToWinLnk+'IN\'+s);
        EraseFile(Path^.Dat.ToWinLnk+'IN\'+s);
      end;

      {В файле остатков на самом деле лежит сообщение}
      If FExists(Path^.Dat.ToTemp+'MESSAGE.'+IntToStr(StrToInt(Rek^.Dat.Kod),CKol)) Then
      begin
        Assign(MessFile,Path^.Dat.ToTemp+'MESSAGE.'+IntToStr(StrToInt(Rek^.Dat.Kod),CKol));
        Result:=ioresult;
        Reset(MessFile);
        Result:=ioresult;
        if Result=0 then
        begin
          while not eof(MessFile) do
          begin
            readln(MessFile,s);
            MessageBox(#3+s,Nil,
                  mfInformation+mfCancelButton);
          end;
        Result:=ioresult;
          close(MessFile);
        Result:=ioresult;
          Erase(MessFile);
        Result:=ioresult;
        end;
      end
      else
      if WriteOstFile(Path^.Dat.ToTemp+s) then
      begin
        Assign(f,Path^.Dat.ToTemp+s);
        Result:=ioresult;
        Erase(f);
        Result:=ioresult;
      end;
      AddProtocol('Закончена обработка входящих остатков '+s,'','');
    end; {else}

   end; {if pos(OstatkiPrefix,s)=1 then}
(*
   {сообщение}
   if pos('MESSAGE',s)=1 then
   begin
     Assign(MessFile,Path^.Dat.ToWinLnk+'IN\'+s);
     Result:=ioresult;
     Reset(MessFile);
     Result:=ioresult;
     if Result=0 then
     begin
       while not eof(MessFile) do
       begin
       readln(MessFile,s);
       MessageBox(^M+#3+s,Nil,
                  mfWarning+mfOkCancel);
       end;
     Result:=ioresult;
       close(MessFile);
     Result:=ioresult;
       Erase(MessFile);
     Result:=ioresult;
       SetLastOst;
     end;
   end;
*)
End;



procedure FindInMail;
var DirInfo:SearchRec;
Begin
  If GlobalSkladsName<>#0 Then
  If GlobalOperatorNAme<>'???' Then
  If GlobalAgentNAme<>'???' Then
  If Not(Glob.Show) And Not(Glob.ShowMsg) Then
  If Not StartProcess Then
Begin
  StartProcess:=True;
  FindFirst(Path^.Dat.ToWinLnk+'IN\'+'*.*', Archive, DirInfo);
  while DosError = 0 do
  begin
    DinfoMsg('Обнаружено необработанное входящее сообщение '+DirInfo.Name,False);
    InMailSelect(DirInfo.Name);
    NoInfoMsg;
    FindNext(DirInfo);
  end;{While}

  DosError := 0;
  FindFirst(Path^.Dat.ToWinLnk+'IN\'+'*.*', Archive, DirInfo);
  while DosError = 0 do
  begin
    EraseFile(Path^.Dat.ToWinLnk+'IN\'+DirInfo.Name);
    FindNext(DirInfo);
  end;{While}
  StartProcess:=False

End;
Desktop^.Redraw;
GlobalTimeMsg1:=TimeStringToTime('hh:mm:ss',Times);
End;


function LocalExClMail(Resive: boolean): boolean;
var DirInfo: SearchRec;
    As:DocumentEditZ;
    ClList,ServList: PBox;
    R: TRect;
    s,ss: string;
    i: word;
    Result: longint;
    f : file;
    MessFile: text;
    kod: word;
Begin
  AddProtocol('Начало сеанса связи по локальной сети','','');
  {Проверка своих почтовых каталогов }
  R.Assign(0, 0, 0, 0);
  ClList := New(PBox, Init(R, 1, Nil));
  ClList^.NewList(New(PTextCollection, Init(1,1)));
  FindFirst(Path^.Dat.ToWinLnk+'out\'+'*.*', Archive, DirInfo);
  while DosError = 0 do
  begin
    ClList^.List^.Insert(NewStr(DirInfo.Name));
    ClList^.SetRange(ClList^.List^.Count);
    FindNext(DirInfo);
  end;

  {Проверка почтовых каталогов сервера}
  R.Assign(0, 0, 0, 0);
  ServList := New(PBox, Init(R, 1, Nil));
  ServList^.NewList(New(PMyCollection, Init(1,1)));

if Resive then
begin
  {SPR}
  FindFirst(NetPath^.Dat.ToWinLnk+Rek^.Dat.AgentKod+'\OUT\'+SPRPrefix+'*.*', Archive, DirInfo);
  while DosError = 0 do
  begin
    ServList^.List^.Insert(NewStr(NetPath^.Dat.ToWinLnk+Rek^.Dat.AgentKod+'\OUT\'+DirInfo.Name));
    ServList^.SetRange(ServList^.List^.Count);
    FindNext(DirInfo);
  end;
  {Подтверждение заказа}
  FindFirst(NetPath^.Dat.ToWinLnk+Rek^.Dat.AgentKod+'\OUT\'+ConfirmationPredZakazPrefix+'*.*', Archive, DirInfo);
  while DosError = 0 do
  begin
    ServList^.List^.Insert(NewStr(NetPath^.Dat.ToWinLnk+Rek^.Dat.AgentKod+'\OUT\'+DirInfo.Name));
    ServList^.SetRange(ServList^.List^.Count);
    FindNext(DirInfo);
  end;
  {Остатки}
  FindFirst(NetPath^.Dat.ToWinLnk+Rek^.Dat.AgentKod+'\OUT\'+OstatkiPrefix+'*.*', Archive, DirInfo);
  while DosError = 0 do
  begin
    ServList^.List^.Insert(NewStr(NetPath^.Dat.ToWinLnk+Rek^.Dat.AgentKod+'\OUT\'+DirInfo.Name));
    ServList^.SetRange(ServList^.List^.Count);
    FindNext(DirInfo);
  end;
  {Обновление клиентской базы}
   FindFirst(NetPath^.Dat.ToWinLnk+Rek^.Dat.AgentKod+'\OUT\'+ClientPrefix+'*.*', Archive, DirInfo);
  while DosError = 0 do
  begin
    ServList^.List^.Insert(NewStr(NetPath^.Dat.ToWinLnk+Rek^.Dat.AgentKod+'\OUT\'+DirInfo.Name));
    ServList^.SetRange(ServList^.List^.Count);
    FindNext(DirInfo);
  end;
  {Сообщение}
  FindFirst(NetPath^.Dat.ToWinLnk+Rek^.Dat.AgentKod+'\OUT\MESSAGE.*', Archive, DirInfo);
  while DosError = 0 do
  begin
    ServList^.List^.Insert(NewStr(NetPath^.Dat.ToWinLnk+Rek^.Dat.AgentKod+'\OUT\'+DirInfo.Name));
    ServList^.SetRange(ServList^.List^.Count);
    FindNext(DirInfo);
  end;
end;

  {если есть подписанные заявки - выкладываем на сервер и ставим подпись}
  if (ClList<>nil) and (ClList^.List^.Count>0) then
  for i:=0 to ClList^.List^.Count-1 do
  begin
   s:=ClList^.GetText(i,ClList^.List^.Count-1);
   DoneSysError;
   DoneEvents;
   Application^.HideCursor;
   DoneDosMem;
   SWAPVECTORS;

   ss:='copy /b '+Path^.Dat.ToWinLnk+'out\'+s+' '+NetPath^.Dat.ToWinLnk++Rek^.Dat.AgentKod+'\IN\'+NullStr^;

   exec (GetEnvMy,' /c '+ss);

   SWAPVECTORS;
   InitDosMem;
   InitEvents;
   Result:=DosExitCode;
   InitSysError;

   if Result<>0 then
   Begin
     MessageBox(#3^M+#3'Ошибка обмена код '+IntToStr(Result,4),Nil,mfError+mfCancelButton);
   End
   else
   begin
   {заявки}
   if pos(PredZakazPrefix,s)=1 then
   if WriteSendFileStatus(s,true) then
     begin
       AddProtocol('Заказ '+s+' успешно отправлен','','');
       Assign(f,Path^.Dat.ToTemp+s);
       Erase(f);
     end;
   { и Все остальное вычищаем}

   Assign(f,Path^.Dat.ToWinLnk+'OUT\'+s);
   erase(f);

   end;

  end;

  {тащим все с сервера и разбираемся - что есть что}
  {тащим}
  if (ServList<>nil) and (ServList^.List^.Count>0) then
  for i:=0 to ServList^.List^.Count-1 do
  begin
   s:=ServList^.GetText(i,ServList^.List^.Count-1);
   DoneSysError;
   DoneEvents;
   Application^.HideCursor;
   DoneDosMem;
   SWAPVECTORS;

   ss:='copy /b '+S+' '+Path^.Dat.ToWinLnk+'in'++NullStr^;

   exec (GetEnvMy,' /c '+ss);

   SWAPVECTORS;
   InitDosMem;
   InitEvents;
   Result:=DosExitCode;
   InitSysError;

   if Result<>0 then
   Begin

   End
   else
   begin
     {почистим сервер}
     Assign(f,s);
     Erase(f);
   end;
  end;

  {разбираемся}
  ServList:=nil;
  R.Assign(0, 0, 0, 0);
  ServList := New(PBox, Init(R, 1, Nil));
  ServList^.NewList(New(PTextCollection, Init(1,1)));

 { FindFirst(Path^.Dat.ToWinLnk+'IN\'+'*.*', Archive, DirInfo);
  while DosError = 0 do
  begin
    ServList^.List^.Insert(NewStr(DirInfo.Name));
    ServList^.SetRange(ServList^.List^.Count);
    FindNext(DirInfo);
  end;  }

  {SPR}
  FindFirst(Path^.Dat.ToWinLnk+'IN\'+SPRPrefix+'*.*', Archive, DirInfo);
  while DosError = 0 do
  begin
    ServList^.List^.Insert(NewStr(DirInfo.Name));
    ServList^.SetRange(ServList^.List^.Count);
    FindNext(DirInfo);
  end;
  {Подтверждение заказа}
  FindFirst(Path^.Dat.ToWinLnk+'IN\'+ConfirmationPredZakazPrefix+'*.*', Archive, DirInfo);
  while DosError = 0 do
  begin
    ServList^.List^.Insert(NewStr(DirInfo.Name));
    ServList^.SetRange(ServList^.List^.Count);
    FindNext(DirInfo);
  end;
  {Остатки}
  FindFirst(Path^.Dat.ToWinLnk+'IN\'+OstatkiPrefix+'*.*', Archive, DirInfo);
  while DosError = 0 do
  begin
    ServList^.List^.Insert(NewStr(DirInfo.Name));
    ServList^.SetRange(ServList^.List^.Count);
    FindNext(DirInfo);
  end;
    {Обновление клиентской базы}
    FindFirst(Path^.Dat.ToWinLnk+'IN\'+ClientPrefix+'*.*', Archive, DirInfo);
  while DosError = 0 do
  begin
    ServList^ .List^.Insert(NewStr(DirInfo.Name));
    ServList^ .SetRange(ServList^ .List^.Count);
    FindNext(DirInfo);
  end;

  {Сообщение}
  FindFirst(Path^.Dat.ToWinLnk+'IN\MESSAGE.*', Archive, DirInfo);
  while DosError = 0 do
  begin
    ServList^.List^.Insert(NewStr(DirInfo.Name));
    ServList^.SetRange(ServList^.List^.Count);
    FindNext(DirInfo);
  end;

  if (ServList<>nil) and (ServList^.List^.Count>0) then
  for i:=0 to ServList^.List^.Count-1 do
  begin
   s:=ServList^.GetText(i,ServList^.List^.Count-1);

   InMailSelect(s);
  End;

  AddProtocol('Завершение сеанса связи по локальной сети','','');
  MessageBox(^M+#3+'Обмен документами по локальной сети завершен!!!',Nil,
                  mfWarning+mfOkCancel);

End;


function FindLocalConnection: boolean;
var Flag: text;
    Result: word;
Begin
  {Проверка сетевого подключения}
  FindLocalConnection:=false;
  Assign(Flag,Path^.Dat.ToRemoteDir+'cl'+Rek^.Dat.AgentKod);
  Result:=ioresult;
  Rewrite(Flag);
  Result:=ioresult;
  if Result=0 then
  Begin
    FindLocalConnection:=true;
    Result:=ioresult;
    Close(Flag);
    Result:=ioresult;
    Erase(Flag);
    Exit;
  End;
End;




function ExClMail:boolean;
var s, s2,SS: string;
    result: longint;
    DirInfo: SearchRec;
    InFirst,InSecond: PBox;
    OutFirst,OutSecond: PBox;
    R:Trect;
    find: boolean;
    i,j, kolOut, kolOst, kolIn: word;
    As:DocumentEditZ;
    sTekDate,sDate: string[CDate];
    Doc: word;
    Ass:DocumentEditZ;
    bLocal : boolean;
    Flag: text;
    f: file;
    l: word;
    M : MAska4;
BEGIN

 if not SelectRemoteOperation(l) then exit;

 FindInMail;

 WordToBit4(l,M);
 Convert4(M);

 If (M[1]=0)And(M[2]=0)And(M[3]=0)And(M[4]=0) Then
  Begin
   {выход если не выбрано ни одной операции}
   Exit;
  End;

 If (M[1]=1) then FormZaprosFromReplication;

 If (M[2]=1) then FormZaprosFromClient;

 If (M[3]=1) then FormZaprosFromSPR;

 if FindLocalConnection then
 begin
 If (M[4]=0) then LocalExClMail(false)
 else LocalExClMail(true);
 exit;
 end;

 {Если не стоит флаг "Принять почту"}
 If (M[4]<>0) then
 begin
  {список файлов перед запуском T-Mail в First входящих}
  R.Assign(0, 0, 0, 0);
  InfIRST := New(PBox, Init(R, 1, Nil));
  InFirst^.NewList(New(PTextCollection, Init(1,1)));                                          {??????}
  FindFirst(Path^.Dat.ToWinLnk+'IN\'+'*.*', Archive, DirInfo);
  while DosError = 0 do
  begin
    InFirst^.List^.Insert(NewStr(DirInfo.Name));
    InFirst^.SetRange(InFirst^.List^.Count);
    FindNext(DirInfo);
  end;
  end;

(*  {обработка неотправленных}
  if (InfIRST<>nil) and (InFirst^.List^.Count>0) then
  for i:=0 to InFirst^.List^.Count-1 do
  begin
   s:=InFirst^.GetText(i,InFirst^.List^.Count);
   MessageBox(^M+#3+'Обнаружено необработанное входящее сообщение '+s,Nil,
                  mfWarning+mfOkCancel);
   InMailSelect(s);
  end;    *)

 if FindLocalConnection then
 begin
 If (M[4]=0) then LocalExClMail(false)
 else LocalExClMail(true);
 exit;
 end;


  {список файлов перед запуском T-Mail в First передаваемых}
  R.Assign(0, 0, 0, 0);
  OutfIRST := New(PBox, Init(R, 1, Nil));
  OutFirst^.NewList(New(PTextCollection, Init(1,1)));                                          {??????}
  FindFirst(Path^.Dat.ToWinLnk+'out\'++PredZakazPrefix+'*.*', Archive, DirInfo);
  while DosError = 0 do
  begin
    OutFirst^.List^.Insert(NewStr(DirInfo.Name));
    OutFirst^.SetRange(OutFirst^.List^.Count);
    FindNext(DirInfo);
  end;

  if OutFirst^.List^.Count>0 then
  begin
    AddProtocol('Файлы к отправке:','','');
    for i:=0 to OutFirst^.List^.Count-1 do
    begin
      s:=OutFirst^.GetText(i,OutFirst^.List^.Count);
      AddProtocol('  '+s,'','');
    end;
  end
  else AddProtocol('Нет файлов к отправке','','');
    {Запуск T-Mail}
  DoneSysError;
  DoneEvents;
  Application^.HideCursor;
  DoneDosMem;
  SWAPVECTORS;

  s:=Path^.Dat.ToWinLnk+'mail.bat';

  AddProtocol('Запуск T-Mail','','');

  exec (GetEnvMy,' /c '+s);

  SWAPVECTORS;
  InitDosMem;
  InitEvents;
  Result:=DosExitCode;
  InitSysError;


  GlobalTime:=TimeStringToTime('hh:mm:ss',Times);
  Application^.Redraw;

  if Result<>0 then
  Begin
  MessageBox(^M+#3+'Ошибка при запуске T-Mail !',Nil,mfError+mfCancelButton);
  AddProtocol('Ошибка при запуске T-Mail','Код '+IntToStr(Result,CKol),'');
  End
  Else
   Begin
    AddProtocol('Завершение сеанса T-Mail','Код '+IntToStr(Result,CKol),'');
   End;
{
  else
  MessageBox(^M+#3+'Обмен документами по телефону завершен!!!',Nil,mfWarning+mfCancelButton);
}



  R.Assign(0, 0, 0, 0);
  InSecond := New(PBox, Init(R, 1, Nil));
  InSecond^.NewList(New(PMyCollection, Init(1,1)));

  R.Assign(0, 0, 0, 0);
  OutSecond := New(PBox, Init(R, 1, Nil));
  OutSecond^.NewList(New(PTextCollection, Init(1,1)));


  {readln;}

  kolOut:=0;
  kolOst:=0;
  kolIn:=0;


  {Поиск оставшихся и пришедших файлов}
  {ВХОДЯЩИЕ}
 If (M[4]<>0) then
 begin
  {FindFirst(Path^.Dat.ToWinLnk+'IN\'+'*.*', Archive, DirInfo);
   while DosError = 0 do
   begin
     InSecond^.List^.Insert(NewStr(DirInfo.Name));
     InSecond^.SetRange(InSecond^.List^.Count);
     FindNext(DirInfo);
   end;}
   {SPR}
  FindFirst(Path^.Dat.ToWinLnk+'IN\'+SPRPrefix+'*.*', Archive, DirInfo);
  while DosError = 0 do
  begin
    InSecond^.List^.Insert(NewStr(DirInfo.Name));
    InSecond^ .SetRange(InSecond^ .List^.Count);
    FindNext(DirInfo);
  end;
  {Подтверждение заказа}
  FindFirst(Path^.Dat.ToWinLnk+'IN\'+ConfirmationPredZakazPrefix+'*.*', Archive, DirInfo);
  while DosError = 0 do
  begin
    InSecond^ .List^.Insert(NewStr(DirInfo.Name));
    InSecond^ .SetRange(InSecond^ .List^.Count);
    FindNext(DirInfo);
  end;
  {Остатки}
  FindFirst(Path^.Dat.ToWinLnk+'IN\'+OstatkiPrefix+'*.*', Archive, DirInfo);
  while DosError = 0 do
  begin
    InSecond^ .List^.Insert(NewStr(DirInfo.Name));
    InSecond^ .SetRange(InSecond^ .List^.Count);
    FindNext(DirInfo);
  end;
  {Обновление клиентской базы}
    FindFirst(Path^.Dat.ToWinLnk+'IN\'+ClientPrefix+'*.*', Archive, DirInfo);
  while DosError = 0 do
  begin
    InSecond^ .List^.Insert(NewStr(DirInfo.Name));
    InSecond^ .SetRange(InSecond^ .List^.Count);
    FindNext(DirInfo);
  end;

  {Сообщение}
  FindFirst(Path^.Dat.ToWinLnk+'IN\MESSAGE.*', Archive, DirInfo);
  while DosError = 0 do
  begin
    InSecond^ .List^.Insert(NewStr(DirInfo.Name));
    InSecond^ .SetRange(InSecond^ .List^.Count);
    FindNext(DirInfo);
  end;
 end;

   {ПЕРЕДАННЫЕ}
   FindFirst(Path^.Dat.ToWinLnk+'OUT\'+'*.*', Archive, DirInfo);
   while DosError = 0 do
   begin
     OutSecond^.List^.Insert(NewStr(DirInfo.Name));
     OutSecond^.SetRange(OutSecond^.List^.Count);
     FindNext(DirInfo);
   end;


  {Сортировка пришедших и оставшихся файлов}
  {first + second +  НЕ ПЕРЕДАЛСЯ
   first + second -  ПЕРЕДАЛСЯ
  }
   if (OutFirst<>nil) and  (OutFirst^.List^.Count>0) then
   for i:=0 to OutFirst^.List^.Count-1 do
   begin
     find:=false;
     s:=OutFirst^.Gettext(i,OutFirst^.LisT^.Count);
     if (OutSecond<>nil) and  (OutSecond^.List^.Count>0) then
     for j:=0 to OutSecond^.List^.Count-1 do
     begin
       s2:=OutSecond^.Gettext(j,OutSecond^.LisT^.Count);
       if s=s2 then
         begin
           find:=true;
           BREAK;
         end;
     end;
     IF find {S НЕ ПЕРЕДАЛСЯ} then
     begin
      {}
      AddProtocol('Не пердан файл '+s,'','');
      inc(kolOst);
     end
     else  {S ПЕРЕДАЛСЯ}
     begin
      Inc(kolOut);
      {устанавливаем Status=2}
      if pos(PredZakazPrefix,s)=1 then
         if WriteSendFileStatus(s,true) then
            AddProtocol('Заказ '+s+' успешно отправлен','','');;
     end;
   end;

  { second + first -  ВОШЕДШИЙ  }
   if (INSecond<>nil) and  (INSecond^.List^.Count>0) then
   for i:=0 to INSecond^.List^.Count-1 do
   begin
     find:=false;
     s:=INSecond^.Gettext(i,InFirst^.LisT^.Count);
     if (Infirst<>nil) and  (Infirst^.List^.Count>0) then
     for j:=0 to Infirst^.List^.Count-1 do
     begin
       s2:=Infirst^.Gettext(j,Infirst^.LisT^.Count);
       if s=s2 then
         begin
           find:=true;
           BREAK;
         end;
     end;

     if not Find {s вошедший } then
     begin
       inc(kolIn);

       InMailSelect(s);

      { memc(s); }

     end;
   end;

  MessageBox('Отправлено файлов: '+IntToStr(kolOut,4)+' '^M+
             'Принято файлов: '+IntToStr(kolIn,4)+' '^M+
             'Не отправлено файлов: '+IntToStr(kolOst,4)+' ',Nil,
                  mfWarning+mfOkCancel);

  Dispose(InSecond,Done);
  Dispose(InFirst,Done);
  Dispose(OutSecond,Done);
  Dispose(OutFirst,Done);

END;

procedure ClearSklad;
var result: longint;
    DirInfo, FileInfo: SearchRec;
    Dir: string;
    ClearList: PBox;
    R: TRect;
    s: string;
    i: word;
BEGIN

  R.Assign(0, 0, 0, 0);
   ClearList := New(PBox, Init(R, 1, Nil));
   ClearList^.NewList(New(PTextCollection, Init(1,1)));

 {  ClearList^.List^.Insert(NewStr('del /?'));
   ClearList^.SetRange(ClearList^.List^.Count); }

   ClearList^.List^.Insert(NewStr('del '+Path^.Dat.ToClientIndex+'*.* /Q'));
   ClearList^.SetRange(ClearList^.List^.Count);

   ClearList^.List^.Insert(NewStr('del '+Path^.Dat.ToMarket+'*.mrk /Q'));
   ClearList^.SetRange(ClearList^.List^.Count);

   ClearList^.List^.Insert(NewStr('del '+Path^.Dat.ToMarket+'??-??-??.cor /Q'));
   ClearList^.SetRange(ClearList^.List^.Count);

   ClearList^.List^.Insert(NewStr('del '+Path^.Dat.ToMarketIndex+'*.mrx /Q'));
   ClearList^.SetRange(ClearList^.List^.Count);

   ClearList^.List^.Insert(NewStr('del '+Path^.Dat.ToClientOplata+'*.* /Q'));
   ClearList^.SetRange(ClearList^.List^.Count);

   ClearList^.List^.Insert(NewStr('del '+Path^.Dat.ToOplata+'*.* /Q'));
   ClearList^.SetRange(ClearList^.List^.Count);

   ClearList^.List^.Insert(NewStr('del '+Path^.Dat.ToClientReturn+'*.* /Q'));
   ClearList^.SetRange(ClearList^.List^.Count);

   ClearList^.List^.Insert(NewStr('del '+Path^.Dat.ToReturn+'*.* /Q'));
   ClearList^.SetRange(ClearList^.List^.Count);

   ClearList^.List^.Insert(NewStr('del '+Path^.Dat.ToDolg+'*.* /Q'));
   ClearList^.SetRange(ClearList^.List^.Count);

 {Наименования}
 ClearList^.List^.Insert(NewStr('del '+Path^.Dat.ToName+'*.* /Q'));
 ClearList^.SetRange(ClearList^.List^.Count);

 ClearList^.List^.Insert(NewStr('del '+Path^.Dat.ToIndex+'*.* /Q'));
 ClearList^.SetRange(ClearList^.List^.Count);

 {Наличие}
 ClearList^.List^.Insert(NewStr('del '+Path^.Dat.ToSklad+'*.* /Q'));
 ClearList^.SetRange(ClearList^.List^.Count);


 {Справочники}
{ ClearList^.List^.Insert(NewStr('del '+Path^.Dat.ToSPR+'*.*'));
 ClearList^.SetRange(ClearList^.List^.Count);}
 {}
(* ClearList^.List^.Insert(NewStr('del '+Path^.Dat.ToOperator+'*.*'));
 ClearList^.SetRange(ClearList^.List^.Count);*)
DInfoMsg('Удаление файлов ... ',false);

if (ClearList<>nil) and (ClearList^.List^.Count>0) then
Begin
  for i:=0 to ClearList^.List^.Count-1 do
  begin
  s:=ClearList^.GetText(i,ClearList^.List^.Count);
  DoneSysError;
  DoneEvents;
  Application^.HideCursor;
  DoneDosMem;
  SwapVectors;
  Exec(GetEnvMy,' /c '+s);

  SwapVectors;
  InitDosMem;
  InitEvents;
  InitSysError;
  CursorLines:=1543;
  Application^.Redraw;
  end;
End;

NoInfoMsg;

  Dispose(ClearList,Done);

END;


procedure Replication;
Var l: word;
Begin

 if FindLocalConnection then
  begin


  if not SelectReplication(l) then Exit;

  AddProtocol('Начало репликации ','','');

  if (l=1) then ClearSklad;


  FormClientFromAgent(Rek^.Dat.AgentKod);
  FormFileList('01-01-05');
  ClientIDX(True);

  ClearLockName;

  AddProtocol('Репликация завершена ','','');
  SetLastLocal;
  MessageBox(#3^M+#3'Синхронизация баз завершена !',Nil,mfError+mfCancelButton);
  Desktop^.Redraw;
  end
  else
  begin
   MessageBox(#3^M+#3'Не установлено подключение к локальной сети !',Nil,mfError+mfCancelButton);
   AddProtocol('Попытка репликации вне сети ','','');
  end;

End;


constructor TZView.Init(Const P:PBox;Const s,s1,ws,s2,s3,s4:TMyString;SDoc:ArtikulStr;SDate:TDateString;
                          t:Byte);
Var R:Trect;
    St : String[80];
    i : Word;
Begin

  R.Assign(0, 0, 80, 23);
  inherited Init(R, 'Просмотр документа');

R.Assign(79, 2, 80, 19);

Control := New(PScrollBar, Init(R));
Insert(Control);

R.Assign(1, 2, 79, 19);

ControlFull := New(PBox, Init(R, 1, PScrollbar(Control)));
ControlFull^.NewList(New(PTextCollection, Init(1,1)));
If (P^.List^.Count-1)>=0 Then
For i:=0 To P^.List^.Count-1 Do
 Begin
  st:=P^.GetText(i,P^.List^.Count);
  ControlFull^.List^.Insert(NewStr(St));
  ControlFull^.SetRange(ControlFull^.List^.Count);
 End;
If t=0 Then
ControlFull^.HelpCtx:=$E555
Else
ControlFull^.HelpCtx:=$E557;
ControlFull^.FocusItem(0);

Insert(ControlFull);

  R.Assign(1, 1, 79, 2);
  Insert(New(PLabel, Init(R, S, ControlFull)));


Str(P^.List^.Count:CMantissa,st);
R.Assign(53, 0, 71, 1);
Control := New(PColoredText, Init(R, 'Всего позиций:'+st, $4E));
Insert(Control);

DelZerro(Sdoc);
R.Assign(2, 0, 28, 1);
Control := New(PColoredText, Init(R, 'Документ:'+SDoc+' от '+SDate, $4E));
Insert(Control);

If S1[0]<>#0 Then
Begin
R.Assign(45, 22, 46+Ord(s1[0]), 23);
Control := New(PColoredText, Init(R, #3+S1, $4E));
{Control^.Options := Control^.Options;}
Insert(Control);
End;

If ws[0]<>#0 Then
Begin
R.Assign(15, 22, 16+Ord(ws[0]), 23);
Control := New(PColoredText, Init(R, #3+ws, $4E));
{Control^.Options := Control^.Options or ofCenterX;}
Insert(Control);
End;

If s4[0]<>#0 Then
Begin
R.Assign(2, 19, 3+Ord(s4[0]), 20);
Control := New(PColoredText, Init(R,#3+s4, $71));
Control^.Options := Control^.Options;
Insert(Control);
End;

R.Assign(1, 20, 14, 21);
Control := New(PColoredText, Init(R,'Комментарий: ', $7E));
Control^.Options := Control^.Options;
Insert(Control);

R.Assign(13, 20, 14+Ord(s2[0]), 21);
Control := New(PColoredText, Init(R, #3+S2, $71));
Control^.Options := Control^.Options or ofCenterX;
Insert(Control);

R.Assign(13, 21, 14+Ord(s3[0]), 22);
Control := New(PColoredText, Init(R, #3+S3, $71));
Control^.Options := Control^.Options or ofCenterX;
Insert(Control);

End;


destructor TZView.Done;
Begin
 {Dispose(Control,Done);
 Dispose(ControlFull,Done);
 Dispose(ControlFull1,Done);}
 inherited Done;
End;

procedure TZView.OpenViewWindow;
Begin
End;



procedure TZView.HandleEvent(var Event: TEvent);

procedure Calculator;
begin
  Calc^.Start;
end;

Begin
  Case Event.What Of

  evCommand :
     Case Event.Command Of
        cmLocalCalc: Calculator;
     cmCancel    : Begin

                 ClearFind;
                 Event.What:=evCommand;
                 Event.Command:=cmClose;
                 PutEvent(Event);
                 ClearEvent(Event);
                End;
     cmClose  : Begin
                  { }
                   inherited HandleEvent(Event);
                   Exit;
                end;
     end;
  end;
  inherited HandleEvent(Event);
End;

function OtvetFullPreview(Ass : DocumentEditZ):boolean;

const posKod=CName+1+CName-Ckol-7;

Var
    E : PZakazType;
    R : TRect;
    f : file of ZakazType;
    c : Word;
    P : PBox;
    s,ws : TMyString;
    Find : Boolean;
    SDoc : ArtikulStr;
    SDate : TDateString;
    ws1:TMyString;
    ZakSumma, FaktSumma: string[CIZena];
    sKol: String[CKol];
    sZena: String[CZena];

procedure AddZakazToList(var s:string;otvet:boolean);
  {otvet=true обработка ElementP - ответная часть заказа
   otvet=false Element - "родная" часть заказа}
var find: boolean;
    i: word;
    ws: string;
    sKOd,sKod1:String[CArtikul];
    sKol: string[CKol];
    sZena: string[CZena];

Begin
  find:=false;
  sKod:=copy(s,1+posKod+1,CArtikul);
  if (P^.List<>nil) and (P^.List^.Count>0) then
  for i:=0 to P^.List^.Count-1 do
  begin
   ws:=P^.GetText(i,P^.List^.Count);
   sKod1:=copy(ws,1+PosKod+1,CArtikul);
   if StrToInt(sKod1)=StrToInt(sKod) then
   Begin
     if Otvet then
     Begin
      {встретились товары с одним кодом, разными отделениями}
       {складывем кол-во, усредняем цену}
       sKol:=IntToStr(StrToInt(copy(s,1+posKod+1+CArtikul+1+Ckol+1,Ckol))
                +StrToInt(copy(ws,1+posKod+1+CArtikul+1+Ckol+1,Ckol)),CKol);

       If StrToInt(sKol)>0.01 Then
       MyStr((StrToReal(copy(s,1+posKod+1+CArtikul+1+Ckol+1,Ckol))*
            StrToReal(copy(s,1+posKod+1+CArtikul+1+Ckol+1+Ckol+1+CZena+1,CZena))+
            StrToReal(copy(ws,1+posKod+1+CArtikul+1+Ckol+1,Ckol))*
            StrToReal(copy(ws,1+posKod+1+CArtikul+1+Ckol+1+Ckol+1+CZena+1,CZena)))/StrToReal(sKol),CZena,CMantissa,sZena)
            Else
            sZena:='0.00';


       rformat(sKol,CKol);
       rformat(sZena,CZena);

       System.Delete(ws,1+posKod+1+CArtikul+1+Ckol+1,Ckol);
       System.Insert(sKol,ws,1+posKod+1+CArtikul+1+Ckol+1);

       System.Delete(ws,1+posKod+1+CArtikul+1+Ckol+1+Ckol+1+CZena+1,CZena);
       System.Insert(sZena,ws,1+posKod+1+CArtikul+1+Ckol+1+Ckol+1+CZena+1);

       P^.List^.AtDelete(i);

       P^.List^.Insert(NewStr(ws));
       P^.SetRange(P^.List^.Count);

     End
     else
     Begin
      {товар присутствует в ответной части}
      {добавляем поля кол-ва и цены в строку}
       sKol:=copy(s,1+posKod+1+CArtikul+1,Ckol);
       sZena:=copy(s,1+posKod+1+CArtikul+1+Ckol+1+Ckol+1,CZena);
       System.Delete(ws,1+posKod+1+CArtikul+1,Ckol);
       System.Insert(sKol,ws,1+posKod+1+CArtikul+1);

       System.Delete(ws,1+posKod+1+CArtikul+1+Ckol+1+Ckol+1,CZena);
       System.Insert(sZena,ws,1+posKod+1+CArtikul+1+Ckol+1+Ckol+1);

       P^.List^.AtDelete(i);

       P^.List^.Insert(NewStr(ws));
       P^.SetRange(P^.List^.Count);
     End;
     find:=true;
     break;
   End;
  end;

  if not Find then
  begin
     P^.List^.Insert(NewStr(s));
     P^.SetRange(P^.List^.Count);
  end;

End;

Begin
Begin

  OldFileMode:=FileMode;
  FileMode:=ReadOnlyN;

  {Assign(f,Path^.Dat.ToPrihod+Ass.d+'.prh');}
  Assign(f,Path^.Dat.ToMarket+'zakaz.db');
  c:=IOResult;
  Reset(f);
  c:=IOResult;
  If c<>0 Then
  Begin
   MessageBox(#3^M+#3'Ошибка доступа к файлу '+Path^.Dat.ToMarket++'zakaz.db Код:'+IntToStr(c,CKOl),Nil,
   mfError+mfCancelButton);
   FileMode:=OldFileMode;
   Exit;
  End;
  DInfo('Ищу документ...');
  New(E,Init);
  Find := False;
  ClearChar(Ass.EditPosition);
  c:=IOResult;
  c:=IOResult;
  seek(f,StrToInt(Ass.EditPosition)-1);
  Read(F,E^.Dat);
  c:=IOResult;
  System.Close(f);
  c:=IOResult;
  FileMode:=OldFileMode;

  if E^.Dat.Status<>5 then
  BEGIN
    OtvetFullPreview:=false;
    Dispose(E,Done);
    Exit;
  END
  ELSE OtvetFullPreview:=true;

Begin
R.Assign(0,0,0,0);
P := New(PBox, Init(R, 1, Nil));
P^.NewList(New(PMyCollection, Init(1,1)));

FaktSumma:='0.00';
{фактически полученный товар}
if E^.Dat.Status in [5,6] then
For c:=1 To E^.Dat.Amountp Do
 Begin

  {Наименование}
  S:=E^.Dat.Elementp[c].BazKod;
  ws:=GetIdField(FName,s);
  Format(ws,posKod);
  s:=ws+'│'+s;
  {Кол-во}
  ws:='0';
  RFormat(ws,CKol);
  s:=s+'│'+ws;

  RFormat(E^.Dat.Elementp[c].Kol,CKol);
  s:=s+'│'+E^.Dat.Elementp[c].Kol;

  {Цена}
  ws:='0.00';
  rformat(ws,CZena);
  s:=s+'│'+ws;

  ws:= E^.Dat.Elementp[c].Zena;
  rformat(ws,CZena);
  s:=s+'│'+ws;

  MyStr(StrToReal(FaktSumma)+StrToReal(E^.Dat.Elementp[c].Zena)*StrToReal(E^.Dat.Elementp[c].Kol),CIZena,CMantissa,FaktSumma);

  AddZakazToList(s,true);

 End;

ZakSumma:='0.00';
{Товар бывший в заказе}
For c:=1 To E^.Dat.Amount Do
 Begin

  {Наименование}
  S:=E^.Dat.MarketElement[c].BazKod;
  ws:=GetIdField(FName,s);
  Format(ws,posKod);
  s:=ws+'│'+s;
  {Кол-во}
  RFormat(E^.Dat.MarketElement[c].Input.Kol,CKol);
  s:=s+'│'+E^.Dat.MarketElement[c].Input.Kol;
  ws:='0';
  RFormat(ws,CKol);
  s:=s+'│'+ws;

  {Цена}
  {ws:= E^.Dat.MarketElement[c].Input.Zena;}
  If E^.Dat.SkidkaSelector=0 Then{Если автомат}
      begin
       DelSpace(E^.Dat.MarketElement[c].Input.Proz);
       MyStr((StrToReal(E^.Dat.MarketElement[c].Input.Zena)/
       (1+StrToReal(E^.Dat.MarketElement[c].Input.Proz)/100)),CZena,CMantissa,ws);
      end
      else
      MyStr((StrToReal(E^.Dat.MarketElement[c].Input.Zena)-StrToReal(E^.Dat.MarketElement[c].Input.Skidka))
       ,CZena,CMantissa,ws);

  MyStr(StrToReal(ZakSumma)+StrToReal(ws)*StrToInt(E^.Dat.MarketElement[c].Input.Kol)
        ,CIZena,CMantissa,ZakSumma);

  rformat(ws,CZena);
  s:=s+'│'+ws;
  ws:='0.00';
  rformat(ws,CZena);
  s:=s+'│'+ws;

  AddZakazToList(s,false);

 End;


P^.FocusItem(0);

s:=E^.Dat.SummaZ;
DelSpace(E^.Dat.SummaZ);
DelSpace(FaktSumma);
s:=' Фактически : '+FaktSumma;
DelSpace(ZakSumma);
ws:=' Сумма заказа : '+ZakSumma{+'*'+E^.Dat.SummaZ};
ws1:='';
ws1:=' Дата доставки: '+DateToDateString(DateMask,E^.Dat.EndDate)+'.';
if E^.Dat.Status in [5,6] then
ws1:=ws1+' Номер N '+IntToStr(E^.Dat.DocumentComment,6)+' в реестре заказов склада';

SDoc:=Format(E^.Dat.Document,CDocNumer);
SDate:=E^.Dat.DateC;

{}

NoInfo;

ZView := New(PZView, Init(P,'Наименование товара                       Код   Колич Факт     Цена   Факт Ц',
s,ws,E^.Dat.Comment1,E^.Dat.Comment2,ws1,
SDoc,SDAte,0));
Application^.InsertWindow(ZView);

Dispose(E,Done);

Dispose(P,Done);
    End;

End;
End;






BEGIN

END.