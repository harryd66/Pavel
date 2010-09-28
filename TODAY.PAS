Uses Glob,Serv,ServStr,Access,My_Glob,Dos,MsgBox;

Var i:LongInt;
    SkladFile : File Of SkladType;
    Skl : PSkladType;
    ItogFile  : File Of ItogType;
    Itg : PItogType;

Procedure CalcMArket(PathToFile:String;Var Itg:PItogType);
Var MarketFile : File Of SuperMarketType;
    E : PSuperMarketType;
    i : Byte;
Begin
 Assign(MarketFile,PathToFile+'.mrk');
 i:=IOResult;
 Reset(MarketFile);
 i:=IOResult;
 If i <> 0 Then
  Begin
   Writeln('Ошибка открытия '+PathToFile+'.mrk'+' Продаж не было!!!');
   Exit;
  End;
 New(E,Init);
 While Not(Eof(MarketFile)) Do
  Begin
   Read(MarketFile,E^.Dat);
   If (E^.Dat.Active) And
(Not(E^.Dat.Realiz) Or ((E^.Dat.Realiz)And(E^.Dat.DocSelector in [5,6,7,8]))) Then
   Begin
    For i:=1 To E^.Dat.Amount Do
     Begin
      If (E^.Dat.MarketElement[i].BazKod=Itg^.Dat.BazKod) Then
       Begin
{
      If (Itg^.DAt.BazKod='11000') And (E^.Dat.MarketElement[i].BazKod=Itg^.Dat.BazKod) Then
       Begin
        Readln;
       End;
}
        DelSpace(E^.Dat.MarketElement[i].Input.Kol);
        DelSpace(E^.Dat.MarketElement[i].Input.R_Zena);
        DelSpace(Itg^.Dat.MrkC);
        DelSpace(Itg^.Dat.MrkS);
        DelSpace(Itg^.Dat.MrkEC);
        DelSpace(Itg^.Dat.MrkES);
        Case E^.Dat.OperatorSelector Of
        0:Begin
           Str((StrToInt(E^.Dat.MarketElement[i].Input.Kol)+StrToInt(Itg^.Dat.MrkC)):CKol,
                 Itg^.Dat.MrkC);
           Str((StrToInt(E^.Dat.MarketElement[i].Input.Kol)*StrToReal(E^.Dat.MarketElement[i].Input.R_Zena)
                 +StrToReal(Itg^.Dat.MrkEC)):CIZena:CMantissa,Itg^.Dat.MrkEC);
          End;
        1:Begin
           Str((StrToInt(E^.Dat.MarketElement[i].Input.Kol)+StrToInt(Itg^.Dat.MrkS)):CKol,
                 Itg^.Dat.MrkS);
           Str((StrToInt(E^.Dat.MarketElement[i].Input.Kol)*StrToReal(E^.Dat.MarketElement[i].Input.R_Zena)
                 +StrToReal(Itg^.Dat.MrkES)):CIZena:CMantissa,Itg^.Dat.MrkES);
          End;
        Else;
        End;{CAse}
        DelSpace(Itg^.Dat.MrkC);
        DelSpace(Itg^.Dat.MrkS);
        DelSpace(Itg^.Dat.MrkEC);
        DelSpace(Itg^.Dat.MrkES);
        {Writeln('Пересчет позиции '+Itg^.Dat.BazKod+' завершен!');}
       End;{If (E^.Dat.MarketElement[i].BazKod=Itg^.Dat.BazKod) Then}
     End;{For}
   End;
  End;{While}
{
     MrkC   : String[CKol];
     MrkS   : String[CKol];
     MrkEC  : String[CIZena];
     MrkES  : String[CIZena];
}
 Dispose(E,Done);
 Close(MArketFile);
End;

VAr Txt:Text;

Begin
 Clrscr;
 If (ParamStr(1)='') Or (ParamStr(2)='') Or (ParamStr(3)='')Or
    (ParamStr(4)='') Or (ParamStr(5)='') Then
   Begin
    Writeln('Программе не хватает входных параметров!');
    Writeln('Для работы необходимо:');
    Writeln('1- путь к файлу-дайджесту (c:\NItogo\Arc\01-01-98)');
    Writeln('2- код склада (1,2,3,4,5)');
    Writeln('3- имя и путь к файлу разделов (c:\Nitogo\razdel.db)');
    Writeln('4- путь к файлам наличия на складе (c:\tmp\newskl\main\)');
    Writeln('5- путь к файлу продаж склада (c:\tmp\newskl\market\01-01-98)');
    Halt;
   End;
 Assign(ItogFile,ParamStr(1)+'.i0'+ParamStr(2));
 Rewrite(ItogFile);
 Assign(Txt,'c:\windows\temp\test.txt');
 Rewrite(Txt);
 Assign(RazdelFile,ParamStr(3));
 Reset(RazdelFile);
 ClrScr;
 While Not(Eof(RazdelFile)) Do
  Begin
   Read(RazdelFile,RazdelElement);
   If RazdelElement.Employ Then
    Begin
     Writeln('Обрабатываю раздел: '+RazdelElement.Kod);
     Assign(SkladFile,ParamStr(4)+RazdelElement.Kod+'.db');
     i:=IOResult;
     Reset(SkladFile);
     i:=IOResult;
     If i<>0 Then
      Begin
       Writeln('Процесс преобразования прерван! Ошибка открытия '+ParamStr(4)+RazdelElement.Kod+'.db');
       Beep;
       Close(ItogFile);
       Readln;
       Halt;
      End;
    New(Skl,Init);
    While Not(Eof(SkladFile)) Do
     Begin
      i:=IOResult;
      Read(SkladFile,Skl^.Dat);
      i:=IOResult;
      If i<>0 Then
      Begin
       Writeln('Процесс преобразования прерван! Ошибка чтения '+ParamStr(4)+RazdelElement.Kod+'.db');
       Close(ItogFile);
       Beep;
       readln;
       Halt;
      End;

      If Skl^.Dat.Employ Then
       Begin
        {расчет остатков штутчных и суммарных}
        New(Itg,Init);
        Itg^.Dat.BazKod:=Skl^.Dat.BazKod;
        DelSpace(Skl^.Dat.Input.Kol);
        Itg^.Dat.Ost:=Skl^.Dat.Input.Kol;
        DelSpace(Skl^.Dat.Input.R_Zena);
        Str(StrToReal(Skl^.Dat.Input.R_Zena)*STrToInt(Skl^.Dat.Input.Kol):CIZena:CMantissa,Itg^.Dat.OstE);
        DelSpace(Itg^.Dat.OstE);
        {расчет продаж штучных и сумарных}
        CalcMarket(ParamStr(5),Itg);
        If (StrToInt(Itg^.Dat.Ost)>0) Or
           (StrToInt(Itg^.Dat.MrkC)>0)Or
           (StrToInt(Itg^.Dat.MrkS)>0) Then
                 Begin
                  Write(ItogFile,Itg^.Dat);
            Writeln(txt,Itg^.Dat.BazKod+' '+Itg^.Dat.Ost+' '+Itg^.Dat.MrkC+' '+Itg^.Dat.MrkS);
           End;

        Dispose(Itg,Done)
       End;
     End;
    Close(SkladFile);
    Dispose(Skl,Done);
    End;
  End;
  Close(ItogFile);
  Close(RazdelFile);
  Close(txt);
  Writeln('Процесс преобразования успешно завершен');
End.