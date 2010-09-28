{$I Compile.INC}
{$DEFINE Converter}

Uses Glob, ServStr, TPDate, StHolder,Ukassa,
     Dos,Objects,Dialogs,Utils,Serv, Utils5,NetDbEng;

Const

 CMaxTasks = 10;
 CMaxSklads = 30;

Const
 KurzSklad : array[1..30] of Char=('1','2','3','4','5','6','7','8','9','A','B','C','D','E','F','G','H','I','J','K',
 {21 22  23   24  25  26  27  28  29  30}
 'L','M','N','O','P','Q','R','S','T','U');

{структура имени файла экспорта}
{
 P1201060.402 приходы
 Z1201060.402 переоценка
 C04450.402   клиента
 M04960.103   поставщики
 B04960.103   бартер
 T04960.103   агенты
 S04960.103   склад
 E04960.103   экспедитор
 G04960.103   группа
 R04960.103   регион
 }


 StartTovar='TOVAR';{4}
 StartRazdel='RAZDEL';{5}
 StartMake='MAKE';
 StartItogi='OSTSQL';
 StartKassa='KASSA';
 StartClass='CLASS';


Type PathTaskElement = Record
PathToRAzdel:String;
PathToOutRazdel:String;
PathToName:String;
PathToOutNAme:String;
PathToMAke:String;
PathToOutMAke:String;
PathToPFile:String;
PathToOutPFile:String;
PathToSPR: String;
End;


Var Path : PathTaskElement;
    ReplicationObject: Array [1..CMaxSklads] Of Byte;{управляется параметрами коммандной строки}
    IndexTasks: Array [1..CMaxTasks] Of Byte;{список задач подлежащих обработке}
    Res : LongInt;
    Starting : Boolean;
    Ini,Log : Text;


Procedure ReadNewIni(Var f : text;Var Res : LongInt);
Var i : Byte;
    c : Byte;
    SH: TStringHolder;

Function GetAsString(Name:AllStr):String;
Begin
GetAsString[0]:=#0;
GetAsString:=SH.GetString (Name);
End;


Begin
Assign (f,'tosql.ini');
Res := IOResult;
Reset(f);
Res := IOResult;
If Res <> 0 Then Exit;
Close(f);
Res := IOResult;
SH.Init;
SH.LoadFromFile ('tosql.ini');


Path.PathToRAzdel:=GetAsString('PathToRAzdel');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;
Path.PathToOutRazdel:=GetAsString('PathToOutRazdel');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

Path.PathToName:=GetAsString('PathToName');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

Path.PathToOutNAme:=GetAsString('PathToOutNAme');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

Path.PathToMAke:=GetAsString('PathToMAke');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

Path.PathToOutMAke:=GetAsString('PathToOutMAke');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

Path.PathToPFile:=GetAsString('PathToPFile');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

Path.PathToOutPFile:=GetAsString('PathToOutPFile');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

Path.PathToSPR:=GetAsString('PathToSPR');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;


SH.Done;
End;


Procedure ClearIni;
VAr c : Word;
Begin
 With Path Do
 Begin
  PathToRAzdel[0]:=#0;
  PathToOutRazdel[0]:=#0;
  PathToName[0]:=#0;
  PathToOutNAme[0]:=#0;
  PathToMAke[0]:=#0;
  PathToOutMAke[0]:=#0;
  PathToPFile[0]:=#0;
  PathToOutPFile[0]:=#0;
 End;{With}
End;





Procedure ShowHelp;
Begin
Writeln('Утилита конвертации баз данных '+CompileDate);
Writeln('Протокол операций tosql.log');
Writeln('Файл конфигурации tosql.ini');
Writeln('Управляется следующими параметрами коммандной строки:');
Writeln('/1 - включить мониторинг изменений для склада N 1');
Writeln('/2 - для склада N 2   /3 - для склада N 3');
Writeln('/4 - для склада N 4   /5 - для склада N 5');
Writeln('/6 - для склада N 6   /7 - для склада N 7');
Writeln('/8 - для склада N 8   /9 - для склада N 9');
Writeln('/A - для склада N 10  /B - для склада N 11');
Writeln('/C - для склада N 12  /D - для склада N 13');
Writeln('/E - для склада N 14  /F - для склада N 15');
Writeln('/G - для склада N 16  /H - для склада N 17');
Writeln('/I - для склада N 18  /J - для склада N 19');
Writeln('/K - для склада N 20  /L - для склада N 21');
Writeln('/M - для склада N 22  /N - для склада N 23');
Writeln('/O - для склада N 24  /P - для склада N 25');
Writeln('/Q - для склада N 26  /R - для склада N 27');
Writeln('/S - для склада N 28  /T - для склада N 29');
Writeln('/U - для склада N 30');
Writeln('ITOGI    - конвертация итогов (*.p??)');
Writeln('MAKE     - конвертация справочника поставщиков (make.db,barter.db)');
Writeln('TOVAR    - конвертация справочника товаров (*.id)');
Writeln('RAZDEL   - конвертация справочника разделов (razdel.db)');
Writeln('KASSA    - конвертация ККЛ (*.k??)');
Writeln('CLASS    - конвертация справочника классов (class.db)');
Halt;
End;



Function ClearChar(S : TDateString):TDateString;
Var i,j : Byte;
    ss  : TDateString;
Begin
DelZerro(s);
j:=1;
ss[0]:=#0;
For i := 1 To Ord(S[0]) Do
 If s[i] in ['1','2','3','4','5','6','7','8','9','0'] Then
  Begin
   ss[j]:=s[i];
   ss[0]:=Chr(j);
   Inc(j);
  End;
ClearChar:=ss;
End;



Procedure AddLog(Var Log:Text;s:String);
Var j : Word;
Begin
 j:=IoResult;
 WriteLn(Log,
 TodayString(DateMask)+'('+Times+')'+'"'+DayString[DayOfWeek(ToDay)]+'"'+'│'+
 s);
 j:=IoResult;
 Writeln('('+Times+') '+s);
 j:=IoResult;
End;


Procedure RazdelToCSV;
Var RazdelFile : File Of RazdelType;
    RazdelElement : RazdelType;
    Txt : Text;
    c : Word;
Begin
  Assign(RazdelFile,Path.PathToRAzdel+'razdel.db');
  c:=IOResult;
  reset(RazdelFile);
  c:=IOResult;
  If c<>0 Then
   Begin
    AddLog(Log,'Ошибка открытия '+Path.PathToRAzdel+'razdel.db');
    Exit;
   End;

  Assign(Txt,Path.PathToOutRazdel+'razdel.csv');
  c:=IOResult;
  Append(Txt);
  c:=IOResult;
  If c<>0 Then
   Begin
    Rewrite(txt);
    c:=IOResult;
    If c<>0 Then
     Begin
      Close(RazdelFile);
      c:=IOResult;
      AddLog(Log,'Ошибка создания '+Path.PathToOutRazdel+'razdel.csv');
      Exit;
     End;
   End;

  While Not Eof(RazdelFile) do
  begin
    Read(RazdelFile,RazdelElement);
    if RazdelElement.Employ then
      BEGIN
       Write(txt,DosToWin(RazdelElement.KOd),';',DosToWin(RazdelElement.Name));
       if RazdelElement.EnableLitr=1 then writeln(txt,';1')
       else writeln(txt,';0');
      END;
  end;

  c:=IOResult;
  Close(txt);
  c:=IOResult;
  Close(RazdelFile);
  c:=IOResult;
  AddLog(Log,'Обработка '+Path.PathToOutRazdel+'razdel.csv успешно завершена!');
End;


Function BakGetField(Field:Byte;C:ArtikulStr;i:Byte):TEnjoyStr;
Var l,kk : LongInt;
    Code : Integer;
    st   : ArtikulStr;
    s,s1 : AllStr;
    SKOl : AllStr;
    OldFileMode : Word;
    fskl : SkladFileType;
    Skl : PSkladType;
Begin
 OldFileMode:=FileMode;
 FileMode:=ReadOnlyN;
 st:=c;
 DelSpace(st);
 c:=Copy(st,1,CRazdelKod);
 Assign(fskl,Path.PathToRAzdel+c+'.db');
 BakGetField[0]:=#0;
 l:=IOResult;
 Reset(fskl);
 l:=IOResult;
 FileMode:=OldFileMode;
 If l <> 0 Then
 Begin
  Writeln('Ошибка открытия ',Path.PathToRAzdel+c+'.db'+' Код:['+st+']');
  AddLog(Log,'Ошибка открытия '+Path.PathToRAzdel+c+'.db'+' Код:['+st+']');
  Exit;
 End
 Else
  Begin
   c:=Copy(st,1+CRazdelKod,CKod);
   L:=StrToInt(C);
   If l>FileSize(fskl) Then
    Begin
     l:=IOResult;
     System.Close(fskl);
     l:=IOResult;
     Writeln('Ошибка открытия ',Path.PathToRAzdel+c+'.db'+' Код:['+st+']');
     AddLog(Log,'Ошибка открытия '+Path.PathToRAzdel+c+'.db'+' Код:['+st+']');
     Exit;
    End;
   Seek(fskl,L);
   l:=IOResult;
   New(Skl,Init);
   l:=IOResult;
   ReadSkladPointer(fskl,Skl);
   l:=IOResult;
   Close(fskl);
   l:=IOResult;
   Case Field Of

  FRegionMarka : BakGetField:=IntToStr(Skl^.Dat.Input.RegionMarka,COne);
  FRZena       : BakGetField:=Skl^.Dat.Input.R_Zena;
  FZAkupka     : BakGetField:=Skl^.Dat.Input.Zakupka;
  FZAkupka2    : BakGetField:=Skl^.Dat.Input.Zakupka2;
  FZenaMarki   : BakGetField:=Skl^.Dat.Input.ZenaMarki;

   Else;
   End;{CAse}
  End;
{ If Not(skl^.Dat.Employ) And (Field in [FFName,FNAme]) Then GetField:='!!!ТОВАР УДАЛЕН!!!';}
  Dispose(skl,Done);
End;



Procedure TovarToCSV;
Var RazdelFile : File Of RazdelType;
    RazdelElement : RazdelType;
    BazFile : File Of BazType;
    BazElement : BazType;
    Txt : Text;
    c : Word;
    SKod : AllStr;
Begin
  Assign(RazdelFile,Path.PathToRAzdel+'razdel.db');
  c:=IOResult;
  reset(RazdelFile);
  c:=IOResult;
  If c<>0 Then
   Begin
    AddLog(Log,'Ошибка открытия '+Path.PathToRAzdel+'razdel.db');
    Exit;
   End;

  Assign(Txt,Path.PathToOutName+'tovar.csv');
  c:=IOResult;
  Append(Txt);
  c:=IOResult;
  If c<>0 Then
   Begin
    Rewrite(txt);
    c:=IOResult;
    If c<>0 Then
     Begin
      Close(RazdelFile);
      c:=IOResult;
      AddLog(Log,'Ошибка создания '+Path.PathToOutName+'tovar.csv');
      Exit;
     End;
   End;

  While Not Eof(RazdelFile) do
  begin
    Read(RazdelFile,RazdelElement);
    if RazdelElement.Employ then
      BEGIN
       RFormatZerro(RazdelElement.Kod,CMAntissa);
       Assign(BazFile,Path.PathToName+RazdelElement.Kod+'.id');
       c:=IOResult;
       Reset(BazFile);
       c:=IOResult;
       If c=0 Then
       Begin
       while not eof(BazFile) do
       Begin
        Read(BazFile,BazElement);
        DelSpaceRight(BazElement.Name);
        DelSpaceRight(BazElement.Name2);
        if BazElement.Employ then
        begin
          sKOd:=copy(BazElement.BazKod,3,3);
          write(txt,sKOd,';',RazdelElement.Kod,';',DosToWin(BazElement.Name)+' '+DosToWin(BazElement.Name2));
          writeln(txt,';'+BazElement.Litr+';'+BazElement.InPack+';',
		IntToStr(StrToInt(BazElement.InPack2),CInPack)+';',
          RealToStr(StrToReal(BazElement.Massa),CMassa,CMantissaZ)+';',
		BazElement.BuchGroup:1,';'+
		IntToStr(StrToInt(BazElement.Class),CClientKod)+';'+
          IntToStr(StrToInt(BazElement.Mera),CClientKod)+';'+
          IntToStr(StrToInt(BazElement.NGroupKod),CClientKod)+';'+
          IntToStr(StrToInt(BazElement.PostKod),CCLientKod)+';'+
          IntToStr(StrToInt(BazElement.FirmaPostKod),CClientKod)+';'+
          RealToStr(StrToReal(BazElement.NDS),CLitr,CMantissa)+';'+
          RealToStr(StrToReal(BazElement.Nalog),CLitr,CMantissa)+';',
          BazElement.Main:1,';',
          IntToStr(StrToInt(BazElement.FantomKod),CArtikul)+';'+
		IntToStr(StrToInt(BakGetField(FRegionMarka,BazElement.BAzKod,0)),COne)+';'+
		RealToStr(StrToReal(BakGetField(FZenaMarki,BazElement.BAzKod,0)),CZenaZ,CMantissaZ)+';'+
		RealToStr(StrToReal(BazElement.Etil),CLitr,CMantissa)+';'+
		RealToStr(StrToReal(BakGetField(FRZena,BazElement.BAzKod,0)),CZena,CMantissa)+';'+
		RealToStr(StrToReal(BakGetField(FZakupka,BazElement.BAzKod,0)),CZenaZ,CMAntissaZ)+';'+
		RealToStr(StrToReal(BakGetField(FZakupka2,BazElement.BAzKod,0)),CZenaZ,CMantissaZ));
        end;{BazElement.Employ}
       End;{While}
        c:=IOResult;
        close(BazFile);
        c:=IOResult;
       End
	   Else{c<>0}
         Begin
          AddLog(Log,'Ошибка открытия '+PAth.PathToName+RazdelElement.Kod+'.id');
         End;


      END;{Employ}
  end;{Eof(RazdelFile)}

  c:=IOResult;
  Close(txt);
  c:=IOResult;
  Close(RazdelFile);
  c:=IOResult;
  AddLog(Log,'Обработка '+Path.PathToOutNAme+'tovar.csv успешно завершена!');
End;



Procedure PToCsv(s:AllStr);
Var ItogFile : File Of NewItogType;
    Itog : NewItogType;
    SSklKod : ArtikulStr;
    st,svid,smake,sKOd,srazd,SDate : AllStr;
    TItog : Text;
    c,IORez,i : Word;
    DAte : LongInt;
    sDiv: array [1..CDivision] of string;
Begin


 sDate:=Copy(s,Pos('.',s)-6,Pos('.',s)-1);
 {RFormatZerro(SDAte,CDAte);}
 {Writeln(SDAte);}


 RFormatZerro(SDAte,6);
 {Writeln(SDAte);}
 SDate:=SDAte[1]+SDAte[2]+'-'+SDAte[3]+SDAte[4]+'-'+SDate[5]+SDAte[6];
 {Writeln(SDAte);}
 Date:=DatestringToDate('dd-mm-yy',sDate);
 {Writeln(DAte);}
 {Writeln(DateToDateString('dd-mm-yy',Date));}

 sSklKOd:=Copy(s,Ord(s[0])-1,2);
 RFormatZerro(sSklKOd,CMantissa);

 If Not StrToInt(sSklKOd) in [1..CMaxSklads] Then
  Begin
   AddLog(Log,'Обработка объекта с кодом '+sSklKOd+' запрещена');
   Exit;
  End;

 If ReplicationObject[StrToInt(sSklKOd)]=0 Then
  Begin
   AddLog(Log,'Обработка объекта с кодом '+sSklKOd+' запрещена');
   Exit;
  End;


  Assign(TItog,Path.PathToOutPFile+'itog.csv');
  c:=IOResult;
  Append(TItog);
  c:=IOResult;
  If c<>0 Then
   Begin
    Rewrite(TItog);
    c:=IOResult;
    If c<>0 Then
     Begin
      c:=IOResult;
      AddLog(Log,'Ошибка создания '+Path.PathToOutPFile+'itog.csv');
      Exit;
     End;
   End;


   Assign(ItogFile,Path.PathToPFile+s);
   IORez:=IOResult;
   Reset(ItogFile);
   IORez:=Ioresult;
   If IORez <> 0 Then
    Begin
      AddLog(Log,'Ошибка открытия '+Path.PathToPFile+s);
      Exit;
    End;


  while not eof(itogFile) do
  begin
    IORez:=ioresult;
    read(itogFile,itog);
    IORez:=ioresult;
    if IOREz<>0 then
      begin
       writeln('Ошибка чтения файла итогов');
       exit;
      end;
    with itog do
    begin
{КЛЮЧ
  Код товара
  код раздела
  код склада
  вид поставщ
  код поставщ
  Дата}
     srazd:=copy(BazKod,1,2);
     sKOd:=copy(BazKod,3,3);
     write(titog,srazd+';');
     write(titog,sKod+';');
     write(titog,sSklKOd+';');
     sDate:=DateToDatestring('dd.mm.yy',Date);
     write(titog,sDate+';');
     {ПОСТАВЩИК}
     smake:=copy(NMakeKod,2,4);
     delspace(smake);
     if smake='' then smake:='0';
     svid:=copy(NMakeKod,1,1);
     DelSpace(sVid);
     if svid='' then svid:='0';
     write(titog,sVid+';');
     write(titog,sMake+';');

   {ОСТАТКИ кол-во}
     write(titog,IntToStr(StrToInt(Ost),CKol)+';');

   {ОСТАТКИ сумма}
     st:=REalToStr(OstE,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st,';');

     st:=REalToStr(OstEZ,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st,';');
     st:=REalToStr(OstEZ2,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st,';');
   {ПРИХОД кол-во}
     write(titog,IntToStr(StrToInt(PrhC),CKol),';');
     write(titog,IntToStr(StrToInt(PrhS),CKol),';');
     write(titog,IntToStr(StrToInt(PrhB),CKol),';');
   {ПРИХОД сумма}
     st:=REalToStr(PrhEC,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st,';');
     st:=REalToStr(PrhECZ,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+';');
     st:=REalToStr(PrhECZ2,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+';');

     st:=REalToStr(PrhES,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st,';');

     st:=REalToStr(PrhESZ,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+';');
     st:=REalToStr(PrhESZ2,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+';');

     st:=REalToStr(PrhEB,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st,';');
     st:=REalToStr(PrhEBZ,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+';');
     st:=REalToStr(PrhEBZ2,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+'0;');

   {ПРОДАЖА кол-во}
     st:=IntToStr(StrToInt(MrkC),CKol);
     Delspace(st);
     write(titog,st,';');
     st:=IntToStr(StrToInt(MrkS),CKol);
     Delspace(st);
     write(titog,st,';');
     st:=IntToStr(StrToInt(MrkB),CKol);
     Delspace(st);
     write(titog,st,';');
    {ПРОДАЖА сумма}
     st:=REalToStr(MrkEC,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st,';');
     st:=REalToStr(MrkECOpl,CIZena,CMantissaz);
     DelSpace(st);
     write(titog,st+';');
     st:=REalToStr(MrkECZ,CIZena,CMantissaz);
     DelSpace(st);
     write(titog,st+';');
     st:=REalToStr(MrkECZ2,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+';');
     st:=REalToStr(MrkES,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st,';');
     st:=REalToStr(MrkESZ,CIZena,CMantissaz);
     Delspace(st);
     write(titog,ST+';');
     st:=REalToStr(MrkESZ2,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+';');
     ST:=REalToStr(MrkEB,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st,';');
     ST:=REalToStr(MrkEBZ,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st,';');
     ST:=REalToStr(MrkEBZ2,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st,';');

     write(titog,IntToStr(StrToInt(MrkOptC),CKol),';');
     st:=REalToStr(MrkOptRZC,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+';');
     st:=REalToStr(MrkOptCOpl,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+';');
    st:=REalToStr(MrkOptCZZ,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+';');
    st:=REalToStr(MrkOptCZZ2,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+';');

     write(titog,IntToStr(StrToInt(MrkRoznC),CKol),';');
     st:=REalToStr(MrkRoznRZC,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+';');
     st:=REalToStr(MrkRoznCOpl,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+';');
    st:=REalToStr(MrkRoznCZZ,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+';');
    st:=REalToStr(MrkRoznCZZ2,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+';');

     write(titog,IntToStr(StrToInt(MrkOptB),CKol),';');
     st:=REalToStr(MrkOptRZB,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+';');
     st:=REalToStr(MrkOptBOpl,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+';');
     st:=REalToStr(MrkOptBZZ,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+';');
     st:=REalToStr(MrkOptBZZ2,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+';');

     write(titog,IntToStr(StrToInt(MrkRoznB),CKol),';');
     st:=REalToStr(MrkRoznRZB,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+';');
     st:=REalToStr(MrkRoznBOpl,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+';');
     st:=REalToStr(MrkRoznBZZ,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+';');
     st:=REalToStr(MrkRoznBZZ2,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+';');

     write(titog,IntToStr(StrToInt(RewKol),CKol),';');
     st:=REalToStr(RewRZ,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+';');
     st:=REalToStr(RewZZ,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+';');
     st:=REalToStr(RewZZ2,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+';');

     write(titog,IntToStr(StrToInt(ReturnOptKol),CKol),';');
     st:=REalToStr(ReturnOptOpl,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+';');
     st:=REalToStr(ReturnOptRZ,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+';');
     st:=REalToStr(ReturnOptZZ,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+';');
     st:=REalToStr(ReturnOptZZ2,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+';');

     write(titog,IntToStr(StrToInt(ReturnRoznKol),CKol),';');
     st:=REalToStr(ReturnRoznOpl,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+';');
     st:=REalToStr(ReturnRoznRZ,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+';');
     st:=REalToStr(ReturnRoznZZ,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+';');
     st:=REalToStr(ReturnRoznZZ2,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+';');
     {ОТДЕЛЕНИЯ
	   остатки}
     for i:=1 to CDivision do
       begin
         sDiv[i]:='';
         sDiv[i]:=sDiv[i]+IntToStr(MRkCDiv[i],CKol)+';';
         sDiv[i]:=sDiv[i]+IntToStr(MrkSDiv[i],CKol)+';';
         sDiv[i]:=sDiv[i]+IntToStr(MrkBDiv[i],CKol)+';';
         sDiv[i]:=sDiv[i]+IntToStr(OstDiv[i],CKol)+';';
         write(titog,sDiv[i]);
       end;

     writeln(titog);

   end;{with itog}
  end;
  IORez:=IOResult;
  close(TItog);
  IORez:=IOResult;
  IORez:=IOResult;
  close(itogFile);
  IORez:=IOResult;
  Erase(itogFile);
  IORez:=IOResult;
  AddLog(Log,'Обработка '+Path.PathToPFile+s+' завершена!');
End;




Procedure PFileToCSV;
Var Txt : Text;
    c : Word;
    SKod : AllStr;
    P : PBox;
    R : TRect;
    s : String;
    DirInfo: SearchRec;         { For Windows, use TSearchRec }
Begin
R.Assign(0,0,0,0);
P := New(PBox, Init(R, 1, Nil));
P^.NewList(New(PTextCollection, Init(0,1)));

 FindFirst(Path.PathToPFile+'*.p??', AnyFile, DirInfo);

 while DosError = 0 do
 begin
   s:=DirInfo.Name;
   Format(s,12);
   s:=s;
   P^.List^.Insert(NewStr(s));
   P^.SetRange(P^.List^.Count);
   FindNext(DirInfo);
 End;{While}


If P^.List^.Count>0 Then
 Begin
  For c:=0 To P^.List^.Count-1 Do
   Begin
    s:=P^.GetText(c,P^.List^.Count);
    DelSpace(s);
    AddLog(Log,'Обнаружен '+Path.PathToPFile+s);
    PToCsv(s);
   End;
 End;{P^.List^.Count>0}


Dispose(P,Done);
End;




Procedure ClassToCsv;
Var ItogFile : File Of ClassificatorBuchType;
    Itog : ClassificatorBuchType;
    ClassKod : ArtikulStr;
    st : String;
    TItog : Text;
    c,IORez,i : Word;
Begin

  Assign(TItog,Path.PathToOutPFile+'class.sql');
  c:=IOResult;
  Append(TItog);
  c:=IOResult;
  If c<>0 Then
   Begin
    Rewrite(TItog);
    c:=IOResult;
    If c<>0 Then
     Begin
      c:=IOResult;
      AddLog(Log,'Ошибка создания '+Path.PathToOutPFile+'class.sql');
      Exit;
     End;
   End;

   Assign(ItogFile,Path.PathToSPR+'class.db');
   IORez:=IOResult;
   Reset(ItogFile);
   IORez:=Ioresult;
   If IORez <> 0 Then
    Begin
      AddLog(Log,'Ошибка открытия '+Path.PathToSPR+'class.db');
      Exit;
    End;


  while not eof(itogFile) do
  begin
    IORez:=ioresult;
    read(itogFile,itog);
    IORez:=ioresult;
    if IOREz<>0 then
      begin
       writeln('Ошибка чтения файла классов');
       AddLog(Log,'Ошибка чтения файла классов');
       exit;
      end;
    with itog do
    begin
{КЛЮЧ
  код класса
  } if Employ then
    begin
     write(titog,'EXECUTE ImportClass '+IntToStr(StrToInt(KOd),CClientKod)+',');

     st:='"'+Name+'"';
     writeln(titog,st);
    end;

   end;{with itog}
  end;
  IORez:=IOResult;
  close(TItog);
  IORez:=IOResult;
  close(itogFile);
  IORez:=IOResult;
  AddLog(Log,'Обработка '+Path.PathToSPR+'class.db'+' завершена!');
End;



Procedure KassaToCsv(s:AllStr);
Var ItogFile : File Of KassaType;
    Itog : KassaType;
    SSklKod : ArtikulStr;
    st,svid,smake,sKOd,srazd,SDate : AllStr;
    TItog : Text;
    TPer: Text;
    c,IORez,i : Word;
    DAte : LongInt;
Begin


 sDate:=Copy(s,1,8);

 Date:=DatestringToDate('dd-mm-yy',sDate);

 sSklKOd:=Copy(s,Ord(s[0])-1,2);
 RFormatZerro(sSklKOd,CMantissa);

 If Not StrToInt(sSklKOd) in [1..CMaxSklads] Then
  Begin
   AddLog(Log,'Обработка объекта с кодом '+sSklKOd+' запрещена');
   Exit;
  End;

 If ReplicationObject[StrToInt(sSklKOd)]=0 Then
  Begin
   AddLog(Log,'Обработка объекта с кодом '+sSklKOd+' запрещена');
   Exit;
  End;


  Assign(TItog,Path.PathToOutPFile+'kassa.sql');
  c:=IOResult;
  Append(TItog);
  c:=IOResult;
  If c<>0 Then
   Begin
    Rewrite(TItog);
    c:=IOResult;
    If c<>0 Then
     Begin
      c:=IOResult;
      AddLog(Log,'Ошибка создания '+Path.PathToOutPFile+'kassa.sql');
      Exit;
     End;
   End;

  Assign(TPer,Path.PathToOutPFile+'per.sql');
  c:=IOResult;
  Append(TPer);
  c:=IOResult;
  If c<>0 Then
   Begin
    Rewrite(TPer);
    c:=IOResult;
    If c<>0 Then
     Begin
      c:=IOResult;
      AddLog(Log,'Ошибка создания '+Path.PathToOutPFile+'per.sql');
      Exit;
     End;
   End;


   Assign(ItogFile,Path.PathToPFile+s);
   IORez:=IOResult;
   Reset(ItogFile);
   IORez:=Ioresult;
   If IORez <> 0 Then
    Begin
      AddLog(Log,'Ошибка открытия '+Path.PathToPFile+s);
      Exit;
    End;


  while not eof(itogFile) do
  begin
    IORez:=ioresult;
    read(itogFile,itog);
    IORez:=ioresult;
    if IOREz<>0 then
      begin
       writeln('Ошибка чтения файла кассы');
       exit;
      end;
    with itog do
    begin
{КЛЮЧ
  код склада
  Дата}
     write(titog,'EXECUTE ImportKassa '+sSklKOd+',');
     sDate:=DateToDatestring('yyyy-mm-dd',Date);
     write(titog,''''+sDate+''',');

     st:=REalToStr(StrToReal(SummaInKassa),CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+',');

     st:=RealToStr(StrToReal(OstatokInKassa),CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+',');

     st:=RealToStr(StrToReal(Sdano),CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+',');

     st:=RealToStr(StrToReal(ExtendedDohod),CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+',');

     st:=RealToStr(StrToReal(Rashod),CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+',');

     st:=RealToStr(StrToReal(DohodAll),CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+',');

     st:=RealToStr(StrToReal(DohodAgent),CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+',');

     st:=RealToStr(StrToReal(DohodSertif),CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+',');

     st:=RealToStr(StrToReal(Prihod),CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+',');

     st:=RealToStr(StrToReal(Ostatok),CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+',');

     st:=RealToStr(StrToReal(RP),CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+',');

     st:=RealToStr(StrToReal(SertifRP),CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+',');

     st:=RealToStr(StrToReal(SummaOutSklad),CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+',');

     st:=RealToStr(StrToReal(Prodagi),CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+',');

     st:=RealToStr(StrToReal(SkProdagi),CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+',');

     st:=RealToStr(StrToReal(SertifProdagi),CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+',');

     st:=RealToStr(StrToReal(SertifSkProdagi),CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+',');

     st:=RealToStr(StrToReal(VidanoConsig),CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+',');

     st:=RealToStr(StrToReal(SkVidanoConsig),CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+',');

     st:=RealToStr(StrToReal(OplataINKassa),CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+',');

     st:=RealToStr(StrToReal(SkOformConsign),CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+',');

     st:=RealToStr(StrToReal(ReturnOutOpenConsig),CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+',');

     st:=RealToStr(StrToReal(SkReturnOutOpenConsig),CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+',');

     st:=RealToStr(StrToReal(ReturnOutMArketDocAndCloseConsig),CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+',');

     st:=RealToStr(StrToReal(SkReturnOutMArketDocAndCloseConsig),CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+',');

     st:=RealToStr(StrToReal(OstatokConsig),CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+',');

     st:=RealToStr(StrToReal(SkOstatokConsig),CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+',');

     st:=RealToStr(StrToReal(Pereozenka),CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+',');

     st:=RealToStr(StrToReal(PereozenkaFromReturn),CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+',');

     st:=RealToStr(StrToReal(RashodFromReturn),CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+',');

     st:=RealToStr(StrToReal(RashodFromReturnOpenConsig),CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+',');

     st:=RealToStr(StrToReal(VidanoSF),CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+',');

     st:=RealToStr(StrToReal(Rewisia),CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+',');

     st:=RealToStr(StrToReal(SNalogP),CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+',');

     st:=RealToStr(StrToReal(SNalogC),CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+',');

     st:=RealToStr(StrToReal(SNalogReturnOpenConsig),CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+',');

     st:=RealToStr(StrToReal(OstatokBarter),CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+',');

     st:=RealToStr(StrToReal(BarterPrihod),CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+',');

     st:=RealToStr(StrToReal(BarterPrihodRZ),CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+',');

     st:=RealToStr(StrToReal(BarterT),CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+',');

     st:=RealToStr(StrToReal(BarterSkidki),CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+',');

     st:=RealToStr(StrToReal(SertifBarterT),CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+',');

     st:=RealToStr(StrToReal(SertifBarterSkidki),CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+',');

     st:=RealToStr(StrToReal(BarterInKassa),CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+',');

     st:=RealToStr(StrToReal(BarterOutKassa),CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+',');

     st:=RealToStr(StrToReal(BNOPlataConsig),CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+',');

     st:=RealToStr(StrToReal(BNProdagi),CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+',');

     st:=RealToStr(StrToReal(BNBarterInKassa),CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+',');

     st:=RealToStr(StrToReal(BNBarterOutKassa),CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+',');

     st:=RealToStr(StrToReal(OstatokPereplatN),CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+',');

     st:=RealToStr(StrToReal(OstatokPereplatB),CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+',');

     st:=RealToStr(StrToReal(OstatokPereplatV),CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+',');

     st:=RealToStr(StrToReal(NewPereplatN),CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+',');

     st:=RealToStr(StrToReal(NewPereplatB),CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+',');

     st:=RealToStr(StrToReal(NewPereplatV),CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+',');

     st:=RealToStr(StrToReal(RashodPereplatN),CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+',');

     st:=RealToStr(StrToReal(RashodPereplatB),CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+',');

     st:=RealToStr(StrToReal(RashodPereplatV),CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+',');

     st:=RealToStr(StrToReal(OstatokAkzis),CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+',');

     st:=RealToStr(StrToReal(ProdagiCAkzis),CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+',');

     st:=RealToStr(StrToReal(ProdagiSAkzis),CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+',');

     st:=RealToStr(StrToReal(ProdagiBAkzis),CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+',');

     st:=RealToStr(StrToReal(VidanoConsigAkzis),CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+',');

     st:=RealToStr(StrToReal(OformlenoConsigAkzis),CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+',');

     st:=RealToStr(StrToReal(PrihodCAkzis),CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+',');

     st:=RealToStr(StrToReal(PrihodSAkzis),CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+',');

     st:=RealToStr(StrToReal(PrihodBAkzis),CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+',');

     st:=RealToStr(StrToReal(ReturnCAkzis),CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+',');

     st:=RealToStr(StrToReal(ReturnSAkzis),CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+',');

     st:=RealToStr(StrToReal(RevisiaAkZis),CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+',');

   st:=RealToStr(StrToReal(EPerewoskiOut),CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+',');

   st:=RealToStr(StrToReal(EPerewoskiInp),CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+',');

   st:=RealToStr(StrToReal(ReportKassa),CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+',');

      st:=RealToStr(StrToReal(PrihodZC),CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+',');

     st:=RealToStr(StrToReal(PrihodZS),CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+',');

     st:=RealToStr(StrToReal(PrihodZB),CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+',');

     st:=RealToStr(StrToReal(OstatokZ),CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+',');

     st:=RealToStr(StrToReal(OstatokConsigZ),CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+',');

     st:=RealToStr(StrToReal(RewisiaZ),CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+',');

     st:=RealToStr(StrToReal(ReturnZ),CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+',');

     st:=RealToStr(StrToReal(MinusDohod),CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+',');

     st:=RealToStr(StrToReal(AllDohod),CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+',');

     st:=RealToStr(StrToReal(AllDohodA),CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+',');

     st:=RealToStr(StrToReal(AllDohodB),CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+',');

     st:=RealToStr(StrToReal(AllDohodS),CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+',');

     st:=RealToStr(StrToReal(OtgruzkaZC),CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+',');

     st:=RealToStr(StrToReal(OtgruzkaZS),CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+',');

     st:=RealToStr(StrToReal(OtgruzkaZB),CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+',');

     st:=RealToStr(StrToReal(OtgruzkaZRP),CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+',');

     st:=RealToStr(StrToReal(PrihodZC2),CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+',');

     st:=RealToStr(StrToReal(PrihodZS2),CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+',');

     st:=RealToStr(StrToReal(PrihodZB2),CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+',');

     st:=RealToStr(StrToReal(OstatokZ2),CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+',');

     st:=RealToStr(StrToReal(RewisiaZ2),CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+',');

     st:=RealToStr(StrToReal(ReturnZ2),CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+',');

     st:=RealToStr(StrToReal(MinusDohod2),CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+',');

     st:=RealToStr(StrToReal(AllDohod2),CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+',');

     st:=RealToStr(StrToReal(AllDohodA2),CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+',');

     st:=RealToStr(StrToReal(AllDohodB2),CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+',');

     st:=RealToStr(StrToReal(AllDohodS2),CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+',');

     st:=RealToStr(StrToReal(OtgruzkaZC2),CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+',');

     st:=RealToStr(StrToReal(OtgruzkaZS2),CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+',');

     st:=RealToStr(StrToReal(OtgruzkaZB2),CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+',');

     st:=RealToStr(StrToReal(OtgruzkaZRP2),CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+',');

     st:=RealToStr(StrToReal(OstatokAZ),CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+',');

     st:=RealToStr(StrToReal(OstatokAZ2),CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+',');

     st:=RealToStr(StrToReal(OstatokNZ),CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+',');

     st:=RealToStr(StrToReal(OstatokNZ2),CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+',');

     st:=RealToStr(StrToReal(Otkat),CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+',');

     st:=RealToStr(StrToReal(AddOtkat),CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+',');

     st:=RealToStr(StrToReal(KillOtkat),CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+',');

     st:=RealToStr(StrToReal(KillOtkatToDay),CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+',');

     st:=RealToStr(StrToReal(OtgruzkaWithOplataWithOutAkzis),CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+',');

     st:=RealToStr(StrToReal(OtgruzkaZRP),CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+',');

     st:=RealToStr(StrToReal(OtgruzkaZRP2),CIZena,CMantissaz);
     Delspace(st);
     writeln(titog,st);



   {ПЕРЕБРОСКИ}
   for i:=1 to CMaxSklads  do
   begin

      write(TPer,'EXECUTE ImpotPerevozki '+sSklKOd+',');
      sDate:=DateToDatestring('yyyy-mm-dd',Date);
      write(TPer,''''+sDate+''',');


     write(tper,i,',');
     st:=RealToStr(StrToReal(PerewoskiOut[i]),CIZena,CMantissaz);
     Delspace(st);
     write(tper,st+',');
     st:=RealToStr(StrToReal(PerewoskiInp[i]),CIZena,CMantissaz);
     Delspace(st);
     write(tper,st+',');
     st:=RealToStr(StrToReal(PerewoskiOutZ[i]),CIZena,CMantissaz);
     Delspace(st);
     write(tper,st+',');
     st:=RealToStr(StrToReal(PerewoskiInpZ[i]),CIZena,CMantissaz);
     Delspace(st);
     write(tper,st+',');
     st:=RealToStr(StrToReal(PerewoskiOutZ2[i]),CIZena,CMantissaz);
     Delspace(st);
     write(tper,st+',');
     st:=RealToStr(StrToReal(PerewoskiInpZ2[i]),CIZena,CMantissaz);
     Delspace(st);
     writeln(tper,st);
   end;
   end;{with itog}
  end;
  IORez:=IOResult;
  close(TItog);
  IORez:=IOResult;
  close(TPer);
  IORez:=IOResult;
  close(itogFile);
  IORez:=IOResult;
  Erase(itogFile);
  IORez:=IOResult;
  AddLog(Log,'Обработка '+Path.PathToPFile+s+' завершена!');
End;

Procedure KFileToCSV;
Var Txt : Text;
    c : Word;
    SKod : AllStr;
    P : PBox;
    R : TRect;
    s : String;
    DirInfo: SearchRec;         { For Windows, use TSearchRec }
Begin
R.Assign(0,0,0,0);
P := New(PBox, Init(R, 1, Nil));
P^.NewList(New(PTextCollection, Init(0,1)));

 FindFirst(Path.PathToPFile+'*.k??', AnyFile, DirInfo);

 while DosError = 0 do
 begin
   s:=DirInfo.Name;
   Format(s,12);
   s:=s;
   P^.List^.Insert(NewStr(s));
   P^.SetRange(P^.List^.Count);
   FindNext(DirInfo);
 End;{While}


If P^.List^.Count>0 Then
 Begin
  For c:=0 To P^.List^.Count-1 Do
   Begin
    s:=P^.GetText(c,P^.List^.Count);
    DelSpace(s);
    AddLog(Log,'Обнаружен '+Path.PathToPFile+s);
    KassaToCsv(s);
   End;
 End;{P^.List^.Count>0}


Dispose(P,Done);
End;



Procedure MakeToCSV;
Var ClientFile : File Of ClientType;
    ClientElement : ClientType;
    Txt : Text;
    c : Word;
Begin
  Assign(Txt,Path.PathToOutMAke+'make.csv');
  c:=IOResult;
  Append(Txt);
  c:=IOResult;
  If c<>0 Then
   Begin
    Rewrite(txt);
    c:=IOResult;
    If c<>0 Then
     Begin
      c:=IOResult;
      AddLog(Log,'Ошибка создания '+Path.PathToOutMAke+'make.csv');
      Exit;
     End;
   End;

Assign (ClientFile,Path.PathToMake+'make.db');
c:=IoResult;
Reset (ClientFile);
c:=IoResult;
  If c<>0 Then
   Begin
    c:=ioresult;
    Close(txt);
    c:=ioresult;
    AddLog(Log,'Ошибка открытия '+Path.PathToMake+'make.db');
    Exit;
   End;

While Not(Eof(ClientFile)) Do
 Begin
  Read(ClientFile,ClientElement);
  If ClientElement.Employ Then
   Begin
    Format (ClientElement.Name,CClient);
    writeln(Txt,ClientElement.Kod+';'+DosToWin(ClientElement.Name)+';0');
   End;
 End;
c:=IoResult;
System.Close(ClientFile);
c:=IoResult;
  AddLog(Log,'Обработка '+Path.PathToOutMAke+'make.csv из make.db успешно завершена!');


Assign (ClientFile,Path.PathToMake+'barter.db');
c:=IoResult;
Reset (ClientFile);
c:=IoResult;
  If c<>0 Then
   Begin
    c:=ioresult;
    Close(txt);
    c:=ioresult;
    AddLog(Log,'Ошибка открытия '+Path.PathToMake+'barter.db');
    Exit;
   End;

While Not(Eof(ClientFile)) Do
 Begin
  Read(ClientFile,ClientElement);
  If ClientElement.Employ Then
   Begin
    Format (ClientElement.Name,CClient);
    writeln(Txt,ClientElement.Kod+';'+DosToWin(ClientElement.Name)+';2');
   End;
 End;

c:=IoResult;
System.Close(ClientFile);
c:=IoResult;

c:=IoResult;
System.Close(Txt);
c:=IoResult;
  AddLog(Log,'Обработка '+Path.PathToOutMAke+'make.csv из barter.db успешно завершена!');
End;{Procedure}





Var  itog: NewItogType;
     fitog: file of NewItogType;
     sDate:DateString;
     Date:LongInt;
     IORez, nSkl, i: word;
     sSklKOd: string[2];
     sDiv: array [1..CDivision] of string;
     st: string;
     smake: string[3];
     sVid:string[1];
     j : Word;
BEGIN

 If FindParam('/?') Then
  Begin
   ShowHelp;
  End;

 ClearIni;

 j:=1;
 For j:=1 To CMaxSklads Do
  Begin
   If FindParam('/'+KurzSklad[j]{WordToMyHex(j)}) Then ReplicationObject[j]:=1
   Else
   ReplicationObject[j]:=0;
  End;

 {цикл настройки на обрабатываемые задачи}
 For j:=1 To CMaxTasks Do
  Begin
   IndexTasks[j]:=0;
  End;

 If FindParam(StartRazdel) Then IndexTasks[1]:=1;{Razdel}
 If FindParam(StartMAke)   Then IndexTasks[2]:=1;{make}
 If FindParam(StartTovar)  Then IndexTasks[3]:=1;{ToVar}
 If FindParam(StartITOGI)  Then IndexTasks[4]:=1;{p-файлы}
 If FindParam(StartKASSA)  Then IndexTasks[5]:=1;{k-файлы}
 If FindParam(StartClass)  Then IndexTasks[6]:=1; {class}

 {цикл настройки на обрабатываемые задачи}
 Starting := False;
 For j:=1 To CMaxTasks Do
  Begin
   If
   IndexTasks[j]>0 Then Starting:=True;
  End;

 If Not Starting Then
  Begin
   Writeln('Не обнаружено никаких задач!');
   Halt;
  End;


 Assign(Log,'tosql.log');
 j:=IoResult;
 Append(Log);
 j:=IoResult;
 If j<>0 Then
  Begin
   {SpecialBeep;}
   Writeln('Ошибка открытия лог-файла');
   Rewrite(Log);
   j:=IoResult;
   If j<>0 Then
    Begin
     {SpecialBeep;}
     Writeln('Ошибка создания лог-файла');
    End;
  End;

 Assign(Ini,'tosql.ini');
 j:=IoResult;
 Reset(Ini);
 j:=IoResult;
 If j<>0 Then
  Begin
   Writeln('Ошибка открытия ini-файла');
   AddLog(Log,'Ошибка открытия ini-файла');
   AddLog(Log,'Аварийное завершение');
   j:=IoResult;
   Close(Log);
   j:=IoResult;
   Exit;
  End;
 j:=IoResult;
 Close(ini);
 j:=IoResult;
 Res:=0;
 ReadNewIni(INI,Res);
 Close(ini);
 j:=IoResult;
 If Res=1 Then
  Begin
   Writeln('Ошибка чтения ini-файла');
   j:=IoResult;
   AddLog(Log,'Ошибка чтения ini-файла');
   AddLog(Log,'Аварийное завершение');
   j:=IoResult;
   Close(Log);
   j:=IoResult;
   Exit;
  End;


For j:=1 To CMaxTasks Do
 Begin
  Case j Of
  1: If IndexTasks[j]=1 Then RazdelToCSV;{разделы}
  2: If IndexTasks[j]=1 Then MakeToCSV;{поставшики make And BArter}
  3: If IndexTasks[j]=1 Then ToVarToCSV;
  4: If IndexTasks[j]=1 Then PFileToCSV;
  5: If IndexTasks[j]=1 Then KFileToCSV;
  6: If IndexTasks[j]=1 Then ClassToCSV;
  Else;
  End;
 End;


 j:=IoResult;
Close(log);
 j:=IoResult;

(*


  Assign(tt,'d:\tovar.csv');
  rewrite(tt);
  Assign(tpost,'d:\postav.csv');
  rewrite(tpost);
  Assign(titog,'d:\itog.csv');
  rewrite(titog);


{РАЗДЕЛЫ И НАИМЕНОВАНИЯ}
  while not eof(fr) do
  begin
    read(fr,r);
    if r.Employ then
      BEGIN
       write(t,DosToWin(r.KOd),';',DosToWin(r.Name));
       if r.EnableLitr=1 then writeln(t,';1')
       else writeln(t,';0');

       Assign(fid,'M:\Newskl\id\'+r.KOd+'.id');
       reset(fid);
       while not eof(fid) do
       Begin
        read(fid,id);
        if id.Employ then
        begin
          sKOd:=copy(id.BazKOd,3,3);
          write(tt,sKOd,';',r.KOd,';',DosToWin(id.Name)+' '+DosToWin(id.Name2));
          writeln(tt,';'+id.Litr+';'+id.InPack);
        end;
       End;
       close(fid);
      END;
  end;

{ИТОГИ}
for nSkl:=1 to 11 do
BEGIN

 { Date:=today-7;
  sDate:=DateToDateString('DDmmyy',Date);
  DelSpace(sDate); }
 sDate:='19-03-03';
 Date:=DatestringToDate('dd-mm-yy',sDate);
 {writeln(Date);}

 sDate:=DateToDateString('DDmmyy',Date);
 sSklKOd:=IntToStr(nSkl,2);
 if sSklKod[0]=#1 then
    begin
      SSklKod[0]:=#2;
      sSklKod[2]:=sSklKod[1];
      sSklKod[1]:='0';
    end;
 DelSpace(sDate);
 Assign(fitog,'y:\arc\'+sDate+'.p'+sSklKOd);
   IORez:=IOResult;
   Reset(fitog);
   IORez:=Ioresult;
   If IORez <> 0 Then
    Begin
      continue;
    End;


  while not eof(fitog) do
  begin
    IORez:=ioresult;
    read(fitog,itog);
    IORez:=ioresult;
    if IOREz<>0 then
      begin
       writeln('Ошибка чтения файла итогов');
       exit;
      end;
    with itog do
    begin
{КЛЮЧ
  Код товара
  код раздела
  код склада
  вид поставщ
  код поставщ
  Дата}
     srazd:=copy(BazKod,1,2);
     sKOd:=copy(BazKod,3,3);
     write(titog,srazd+';');
     write(titog,sKod+';');
     write(titog,sSklKOd+';');
     sDate:=DateToDatestring('dd.mm.yy',Date);
     write(titog,sDate+';');
     {ПОСТАВЩИК}
     smake:=copy(NMakeKod,2,3);
     delspace(smake);
     if smake='' then smake:='0';
     svid:=copy(NMakeKod,1,1);
     DelSpace(sVid);
     if svid='' then svid:='0';
     write(titog,sVid+';');
     write(titog,sMake+';');

   {ОСТАТКИ кол-во}
     write(titog,IntToStr(StrToInt(Ost),CKol)+';');

   {ОСТАТКИ сумма}
     st:=REalToStr(OstE,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st,';');

     st:=REalToStr(OstEZ,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st,';');
     st:=REalToStr(OstEZ2,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st,';');
   {ПРИХОД кол-во}
     write(titog,IntToStr(StrToInt(PrhC),CKol),';');
     write(titog,IntToStr(StrToInt(PrhS),CKol),';');
     write(titog,IntToStr(StrToInt(PrhB),CKol),';');
   {ПРИХОД сумма}
     st:=REalToStr(PrhEC,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st,';');
     st:=REalToStr(PrhECZ,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+';');
     st:=REalToStr(PrhECZ2,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+';');

     st:=REalToStr(PrhES,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st,';');

     st:=REalToStr(PrhESZ,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+';');
     st:=REalToStr(PrhESZ2,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+';');

     st:=REalToStr(PrhEB,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st,';');
     st:=REalToStr(PrhEBZ,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+';');
     st:=REalToStr(PrhEBZ2,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+'0;');

   {ПРОДАЖА кол-во}
     st:=IntToStr(StrToInt(MrkC),CKol);
     Delspace(st);
     write(titog,st,';');
     st:=IntToStr(StrToInt(MrkS),CKol);
     Delspace(st);
     write(titog,st,';');
     st:=IntToStr(StrToInt(MrkB),CKol);
     Delspace(st);
     write(titog,st,';');
    {ПРОДАЖА сумма}
     st:=REalToStr(MrkEC,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st,';');
     st:=REalToStr(MrkECOpl,CIZena,CMantissaz);
     DelSpace(st);
     write(titog,st+';');
     st:=REalToStr(MrkECZ,CIZena,CMantissaz);
     DelSpace(st);
     write(titog,st+';');
     st:=REalToStr(MrkECZ2,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+';');
     st:=REalToStr(MrkES,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st,';');
     st:=REalToStr(MrkESZ,CIZena,CMantissaz);
     Delspace(st);
     write(titog,ST+';');
     st:=REalToStr(MrkESZ2,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+';');
     ST:=REalToStr(MrkEB,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st,';');
     ST:=REalToStr(MrkEBZ,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st,';');
     ST:=REalToStr(MrkEBZ2,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st,';');

     write(titog,IntToStr(StrToInt(MrkOptC),CKol),';');
     st:=REalToStr(MrkOptRZC,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+';');
     st:=REalToStr(MrkOptCOpl,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+';');
    st:=REalToStr(MrkOptCZZ,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+';');
    st:=REalToStr(MrkOptCZZ2,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+';');

     write(titog,IntToStr(StrToInt(MrkRoznC),CKol),';');
     st:=REalToStr(MrkRoznRZC,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+';');
     st:=REalToStr(MrkRoznCOpl,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+';');
    st:=REalToStr(MrkRoznCZZ,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+';');
    st:=REalToStr(MrkRoznCZZ2,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+';');

     write(titog,IntToStr(StrToInt(MrkOptB),CKol),';');
     st:=REalToStr(MrkOptRZB,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+';');
     st:=REalToStr(MrkOptBOpl,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+';');
     st:=REalToStr(MrkOptBZZ,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+';');
     st:=REalToStr(MrkOptBZZ2,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+';');

     write(titog,IntToStr(StrToInt(MrkRoznB),CKol),';');
     st:=REalToStr(MrkRoznRZB,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+';');
     st:=REalToStr(MrkRoznBOpl,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+';');
     st:=REalToStr(MrkRoznBZZ,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+';');
     st:=REalToStr(MrkRoznBZZ2,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+';');

     write(titog,IntToStr(StrToInt(RewKol),CKol),';');
     st:=REalToStr(RewRZ,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+';');
     st:=REalToStr(RewZZ,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+';');
     st:=REalToStr(RewZZ2,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+';');

     write(titog,IntToStr(StrToInt(ReturnOptKol),CKol),';');
     st:=REalToStr(ReturnOptOpl,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+';');
     st:=REalToStr(ReturnOptRZ,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+';');
     st:=REalToStr(ReturnOptZZ,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+';');
     st:=REalToStr(ReturnOptZZ2,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+';');

     write(titog,IntToStr(StrToInt(ReturnRoznKol),CKol),';');
     st:=REalToStr(ReturnRoznOpl,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+';');
     st:=REalToStr(ReturnRoznRZ,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+';');
     st:=REalToStr(ReturnRoznZZ,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+';');
     st:=REalToStr(ReturnRoznZZ2,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+';');
     {ОТДЕЛЕНИЯ
	   остатки}
     for i:=1 to CDivision do
       begin
         sDiv[i]:='';
         sDiv[i]:=sDiv[i]+IntToStr(MRkCDiv[i],CKol)+';';
         sDiv[i]:=sDiv[i]+IntToStr(MrkSDiv[i],CKol)+';';
         sDiv[i]:=sDiv[i]+IntToStr(MrkBDiv[i],CKol)+';';
         sDiv[i]:=sDiv[i]+IntToStr(OstDiv[i],CKol)+';';
         write(titog,sDiv[i]);
       end;

     writeln(titog);

   end;{with itog}
  end;
  close(fitog);
END; {for nSkl:=1 to 11}


  close(titog);
  close(tpost);
  close(t);
  close(tt);
  close(fr);
*)
END.
