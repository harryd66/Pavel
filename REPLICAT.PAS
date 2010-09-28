{$I Compile.INC}

{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}
Unit Replicat;

INTERFACE
Uses Glob, Servstr,DosWin;

procedure CopyMainFiles;
Procedure ImportClientInfo(Reg,Sel:Word);

procedure SaveMarketToMainSklad;

IMPLEMENTATION
Uses Drivers,Dialogs,Serv,App,Dos,Memory,Objects,MsgBox,DBEngine,
     Views,Utils;


Procedure ImportClientInfo(Reg,Sel:Word);
Const SeparatorChar=';';
Var f : ClientFileType;
    Rd : ClientType;
    s : String;
    txt : Text;
    i : LongInt;
    Gorod: string;
    Buf: string[1];
Begin
Case Reg Of
0:begin
     Case Sel Of
     0:s:=Path.ToClient+'Client.db';
     1:s:=Path.ToClient+'Sklad.db';
     2:s:=Path.ToClient+'Barter.db';
     Else;
     End;{CAse}

  end;
1:begin
       Case Sel Of
     0:s:=Path.ToClient+'Make.db';
     1:s:=Path.ToClient+'Sklad.db';
     2:s:=Path.ToClient+'Barter.db';
     Else;
     End;{CAse}
  End;
Else;
End;{Case}
DInfoMsg('Импортирую данные. Ждите...');
Assign (F,s);
i:=IOResult;
Reset(f);
i:=IOResult;

If i<>0 Then
 Begin
  NoInfoMsg;
  MessageBox(^M+#3'Ошибка открытия '+s+'! (Код:'+IntToStr(i,CLitrMantissa)+')'+
  ClicProgrammer,Nil,
  mfError+mfCancelButton);
  Exit;
 End;

Assign(txt,Path.ToTemp+'impbaza.csv');
i:=IOResult;
Rewrite(txt);
i:=IOResult;
If i<>0 Then
 Begin
  Close(f);
  NoInfoMsg;
  MessageBox(^M+#3'Ошибка создания '+Path.ToTemp+'impbaza.csv'+'! (Код:'+IntToStr(i,CLitrMantissa)+')'+
  ClicProgrammer,Nil,
  mfError+mfCancelButton);
  Exit;
 End;

Case Reg Of
0:begin
     Case Sel Of
     0:s:=SeparatorChar+'БАЗА КЛИЕНТОВ';
     1:s:=SeparatorChar+'БАЗА СКЛАДОВ';
     2:s:=SeparatorChar+'БАЗА КЛИЕНТОВ (БАРТЕР)';
     Else;
     End;{CAse}

  end;
1:begin
       Case Sel Of
     0:s:=SeparatorChar+'БАЗА ПОСТАВЩИКОВ';
     1:s:=SeparatorChar+'БАЗА СКЛАДОВ';
     2:s:=SeparatorChar+'БАЗА ПОСТАВЩИКА (БАРТЕР)';
     Else;
     End;{CAse}
  End;
Else;
End;{Case}
Writeln(txt,DosToWin(s));
Writeln(txt,DosToWin(s));
Write(txt,DosToWin(
'код контрагента'+SeparatorChar+
'наименование контрагента'+SeparatorChar+
'Договор'+SeparatorChar+
'Консигнация'+SeparatorChar+
'Срок консигнации'+SeparatorChar+
'Условия доставки'+SeparatorChar+
'Вид клиента'+SeparatorChar+
'Маршрут'+SeparatorChar+
'Лимит'+SeparatorChar+
'Город'+SeparatorChar+
'Адрес юридический'+SeparatorChar+
'Адрес фактический'+SeparatorChar+
'Телефон'+SeparatorChar+
'Агент ЗАК'+SeparatorChar+
'Агент ВЭН'+SeparatorChar+
'Контроль просрочки'+SeparatorChar+
'Блокировка'+SeparatorChar
)

);
writeln(txt);
While not(eof(f)) do
 begin
  read(f,Rd);
  If rd.Employ Then
   Begin
    With Rd Do
     Begin

Write(txt,DosToWin(Kod)+SeparatorChar);

Write(txt,DosToWin(Name)+SeparatorChar);

Write(txt,DosToWin(Dogovor)+SeparatorChar);

If Debit=0 Then Write(Txt,DosToWin('запрещена')+SeparatorChar)
Else Write(Txt,DosToWin('разрешена')+SeparatorChar);

Write(txt,Punkt[1]+SeparatorChar);

DelSpace(Punkt[2]);
if Punkt[2]='+' then
Write(txt,DosToWin('Дост.')+SeparatorChar);

if Punkt[2]='-' then
Write(txt,DosToWin('Сам.')+SeparatorChar);

if (Punkt[2]<>'-') and (Punkt[2]<>'+') then
Write(txt,DosToWin('???')+SeparatorChar);

if opt then Write(txt,DosToWin('Опт.')+SeparatorChar)
else Write(txt,DosToWin('Розн.')+SeparatorChar);

Write(txt,Punkt[4]+SeparatorChar);

Write(txt,Limit+SeparatorChar);

Gorod:='';

if pos('Г.',Enviropment)>0 then
begin
  i:=pos('Г.',Enviropment);
  while((Enviropment[i]<>' ') and (Enviropment[i]<>',')) do
  begin
   Gorod:=Gorod+Enviropment[i];
   inc(i);
  end;
end
(*else
if pos('Р-Н',Adress)>0 then
begin
  i:=pos('Р-Н',Adress)+2;
  while((Adress[i]<>' ') {and (Adress[i]<>',')} and (i<>0)) do
  begin
   Gorod:=Gorod+Adress[i];
   Buf:=Gorod[1];
   Gorod[1]:=Gorod[length(Gorod)+1];
   Gorod[length(Gorod)+1]:=Buf[1];
   Dec(i);
   memcc(Gorod);
  end;
end *)
else
if pos('ПОС.',Enviropment)>0 then
begin
  i:=pos('ПОС.',Enviropment);
  while((Enviropment[i]<>' ') and (Enviropment[i]<>',')) do
  begin
   Gorod:=Gorod+Enviropment[i];
   inc(i);
  end;
end
else
if pos('П.',Enviropment)>0 then
begin
  i:=pos('П.',Enviropment);
  while((Enviropment[i]<>' ') and (Enviropment[i]<>',')) do
  begin
   Gorod:=Gorod+Enviropment[i];
   inc(i);
  end;
end;


Write(txt,DosToWin(Gorod)+SeparatorChar);

Write(txt,DosToWin(Adress)+SeparatorChar);

Write(txt,DosToWin(Enviropment)+SeparatorChar);

while pos(';',Telefon)>0 do Telefon[pos(';',Telefon)]:=',';
Write(txt,DosToWin(Telefon)+SeparatorChar);

Write(txt,AgentKod[1]+SeparatorChar);

Write(txt,AgentKod[2]+SeparatorChar);

if NoLimit=0 then
Write(txt,DosToWin('Вкл.')+SeparatorChar)
else Write(txt,DosToWin('Откл.')+SeparatorChar);

if LockTime then
Write(txt,DosToWin('Блок.')+SeparatorChar)
else Write(txt,DosToWin('Разблок.')+SeparatorChar);

Writeln(txt);
i:=IOResult;

     End;
   End;
 end;

Close(f);
i:=IOResult;
Close(txt);
i:=IOResult;

NoInfoMsg;
MessageBox(^M+#3'Данные успешно импортированы в '+Path.ToTemp+'impbaza.csv!',Nil,
  mfInformation+mfCancelButton);
End;



Function SaveRemoteToStatFile(L:PSuperMarketType;S:Boolean):Boolean;
Var Es : PstatClientType;
    Esf : File Of StatClientType;
    i : Byte;
Begin
 SaveRemoteToStatFile:=False;
 Assign(esf,Path.ToClient+L^.Dat.ClientKod+'.his');
 i:=IOResult;
 Reset(esf);
 i:=IOResult;
 If i <> 0 Then
  Begin
   If MessageBox(#3'Файл расчетов с клиентом '^M+#3+Path.ToClient+L^.Dat.ClientKod+'.his не найден!'^M+
   #3'Создать файл заново ?',Nil,mfWarning+mfOkCancel)=cmOk Then
    Begin
        i:=IOResult;
        Rewrite(Esf);
        i:=IOResult;
        If i<>0 Then
         Begin
          MessageBox(^m+#3'Не могу создать файл '^M+
          #3+Path.ToClient+L^.Dat.ClientKod+'.his',Nil,mfError+mfCancelButton);
          Exit;
         End;
    End
    Else Exit;
  End;
 New(Es,Init);
         With Es^.Dat Do
          Begin
        If L^.Dat.DocSelector in [4,8] Then    Rashet:=0
        Else    Rashet:=1;
        Realiz:=L^.Dat.Realiz;
        Document:=L^.Dat.Document;
        ENalog  :=L^.Dat.ENalog;
        Nalog5  :=L^.Dat.Nalog5;
        Nalog3  :=L^.Dat.Nalog3;
        Nalog_  :=L^.Dat.Nalog_;
        SummaZ:=L^.Dat.SummaZ;;
        Skidka:=L^.Dat.Skidka;
        SummaZakupka:=L^.Dat.SummaZakupka;
        Bn.DAte:=L^.Dat.bn.Date;
        Bn.NPlat:=L^.Dat.bn.NPlat;
        Bn.Bank:=L^.Dat.bn.Bank;
        Bn.Summa:=L^.Dat.bn.Summa;
        Caption:=L^.Dat.Caption;
        DateC:=L^.Dat.DateC;;
        TimeC:=L^.Dat.TimeC;
        DateM:=L^.Dat.DateM;
        TimeM:=L^.Dat.TimeM;;
        SkladKod:=FormKod(Rek.Kod);
        ShkalaNumer:=L^.DAt.ShkalaNumer;
        Region:=L^.DAt.Region;
        DocSelector :=L^.Dat.DocSelector;
        SkidkaSelector :=L^.Dat.SkidkaSelector;
        ClientKod:=L^.Dat.ClientKod;
        AgentKod:=L^.Dat.AgentKod;
        Active:=True;
        Sf :=S;
        CalcRaspredelenie(L,Es);
          End;
          i:=IOResult;
          Seek(Esf,FileSize(Esf));
          i:=IOResult;
          Write(Esf,Es^.Dat);
          i:=IOResult;

        If i<>0 Then
         Begin
          DiSpose(Es,Done);
          Close(Esf);
          MessageBox(#3'Ошибка записи в файл '^M+
          #3+Path.ToClient+L^.Dat.ClientKod+'.his'^M+ClicProgrammer+' '+
                IntToStr(i,3),Nil,mfError+mfCancelButton);
          Exit;
         End;

Dispose(Es,Done);
i:=IOResult;
Close(Esf);
i:=IOResult;
SaveRemoteToStatFile:=True;
End;


Function SaveRemoteRealizasToClientFile(E:PSuperMarketType;sf:Boolean):Boolean;
Var l : PRealizasiaType;
    RealFile : File Of RealizasiaType;
    i : Byte;
Begin
 SaveRemoteRealizasToClientFile:=False;
 Assign(RealFile,Path.ToRemoteSklad+'DOLG\'+E^.Dat.ClientKod+'.dlg');
 i:=IOResult;
 Reset(RealFile);
 i:=IOResult;
 If i <> 0 Then
  Begin
   If MessageBox(#3'Файл задолженности клиента '^M+#3+Path.ToDolg+E^.Dat.ClientKod+'.dlg не найден!'^M+
   #3'Создать файл заново?'+
   +' Код:'+IntToStr(i,3),Nil,mfWarning+mfOkCancel)=cmOk Then
    Begin
        i:=IOResult;
        Rewrite(RealFile);
        i:=IOResult;
        If i<>0 Then
         Begin
          MessageBox(^m+#3'Не могу создать файл '^M+
          #3+Path.ToDolg+E^.Dat.ClientKod+'.dlg',Nil,mfError+mfCancelButton);
          Exit;
         End;
    End
    Else Exit;
  End;
  New(l,Init);
  Seek(RealFile,FileSize(RealFile));

  MArketToDolg(E,L);

  {L^.Dat.Market:=E^.Dat;}

  L^.Dat.Dolg:=StrToReal(E^.Dat.SummaZ);
  L^.Dat.Full:=False;
  L^.Dat.PayMent:=False;
  L^.Dat.Sf:=Sf;
  Write(RealFile,L^.Dat);
  Close(RealFile);
  Dispose(L,Done);
  SaveRemoteRealizasToClientFile:=True;
End;


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

  Exec(GetEnv('Comspec'),' /c '+s+' >NUL');

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


procedure CleanSklad;
Var fr: file of RazdelType;
    r: RazdelType;
    fskl: file of SkladType;
    skl: skladtype;
    IOrez,i: word;
    sr:string[CRazdelKod];
    test:text;
    fcl:file of ClientType;
    cl: ClientType;
Begin
  Assign(fcl,Path.ToClient+'client.db');
  IORez:=ioresult;
  reset(fcl);
  IORez:=ioresult;
  if IOrez<>0 then
  begin
   memcc(Path.ToClient+'client.db');
   exit;
  end;

  while not eof(fcl) do
  Begin
    DInfoMSgShkala('Обработка базы клиентов ',0,filesize(fcl),filepos(fcl));
    read(fcl,cl);
    if StrToInt(rek.ven)<>StrToInt(cl.AgentKod[2]) then
    begin
      cl.Employ:=false;
      seek(fcl,FilePos(fcl)-1);
      write(fcl,cl);
    end;
    NoInfoMsg;
  End;

  close(fcl);

  Assign(fr,Path.ToRazdel+'razdel.db');
  IORez:=ioresult;
  reset(fr);
  IORez:=ioresult;
  if IOrez<>0 then
  begin
   memcc(Path.ToRazdel+'razdel.db');
   exit;
  end;
  while not eof(fr) do
  begin
    read(fr,r);
    DInfoMSgShkala('Обработка данных раздела '+r.kod,0,filesize(fr),filepos(fr));
    if r.Employ then
    begin
      Assign(fskl,Path.ToSklad+r.kod+'.db');
      IORez:=ioresult;
      reset(fskl);
      IORez:=ioresult;
      if IOrez<>0 then
      begin
       memcc(Path.ToSklad+r.kod+'.db');
       close(fr);
       exit;
      end;
      while not eof(fskl) do
      begin
       read(fskl,skl);
       skl.Input.kol:=skl.Input.DivisionS[StrToInt(Rek.kod)];
       for i:=1 to CDivision do
       if i<>StrToInt(Rek.kod) then skl.Input.DivisionS[i]:='0'
       else skl.Input.DivisionS[i]:=skl.Input.kol;
       seek(fskl,filepos(fskl)-1);
       write(fskl,skl);
      end;
      close(fskl);
    end; {if r.Employ}
    NoInfoMsg;
  end;
  close(fr);
  CreatIDX;
  ClientIDX;
End;


procedure CopyMainFiles;
var TempList: PBox;
    R:TRect;
    test: text;
    Iorez: word;
Begin

  Assign(test,Path.ToRemoteSklad+'test');
  Iorez:=ioresult;
  rewrite(test);
  Iorez:=ioresult;
  if IOrez<>0 then
  begin
   memcc('Отсутствует соединение с главным складом!');
   exit;
  end;
  close(test);
  erase(test);


R.Assign(0,0,0,0);
TempList := New(PBox, Init(R, 1, Nil));
TempList^.NewList(New(PTextCollection, Init(1,1)));

 {SYSTEM}
 TempList^.List^.Insert(NewStr('copy /b '+Path.ToRemoteSklad+'SYSTEM\*.* '
     +copy(Path.ToOperator,1,length(Path.ToOperator)-1)+' '));
 TempList^.SetRange(TempList^.List^.Count);
 {MAIN}
 TempList^.List^.Insert(NewStr('copy /b '+Path.ToRemoteSklad+'MAIN\*.* '
     +copy(Path.ToSklad,1,length(Path.ToSklad)-1)+' '));
 TempList^.SetRange(TempList^.List^.Count);
 {SKIDKI}
 TempList^.List^.Insert(NewStr('copy /b '+Path.ToRemoteSklad+'SKIDKI\*.* '
     +copy(Path.ToSkidki,1,length(Path.ToSkidki)-1)+' '));
 TempList^.SetRange(TempList^.List^.Count);
 {ID}
 TempList^.List^.Insert(NewStr('copy /b '+Path.ToRemoteSklad+'ID\*.* '
     +copy(Path.ToName,1,length(Path.ToName)-1)+' '));
 TempList^.SetRange(TempList^.List^.Count);
 {Client}
 TempList^.List^.Insert(NewStr('copy /b '+Path.ToRemoteSklad+'CLIENT\*.db '
     +copy(Path.ToClient,1,length(Path.ToClient)-1)+' '));
 TempList^.SetRange(TempList^.List^.Count);

 CopyFileWithList(TempList,'Идет синхронизация с главным складом');

 Dispose(TempList,Done);

 CleanSklad;

end;

procedure SaveMarketToMainSklad;
var fm,fmmain: file of SuperMarketType;
    mrk,mrkmain: PSuperMarketType;
    IORez,i: word;
    test: text;
    sr: string[CRazdelKod];
    skod: string[3];
    fskl: file of SkladType;
    skl: skladType;
    dlg: PRealizasiaType;
    fdlg: file of RealizasiaType;
    sf: boolean;
Begin
  Assign(test,Path.ToRemoteSklad+'test');
  Iorez:=ioresult;
  rewrite(test);
  Iorez:=ioresult;
  if IOrez<>0 then
  begin
   memcc('Отсутствует соединение с главным складом!');
   exit;
  end;
  close(test);
  {Продажи}
  Assign(fm,Path.ToMarket+Fdate+'.mrk');
  IOrez:=ioresult;
  reset(fm);
  IOrez:=ioresult;
  if IORez<>0 then
  begin
    memcC('Нет продаж '+Path.ToMarket+Fdate+'.mrk');
    exit;
  end;

  Assign(fmmain,Path.ToRemoteSklad+'MARKET\'+Fdate+'.mrk');
  IOrez:=ioresult;
  reset(fmmain);
  IOrez:=ioresult;
  if IORez<>0 then
  begin
    IOrez:=ioresult;
    Rewrite(fmmain);
    IOrez:=ioresult;
    if IORez<>0 then
     begin
      memcC('Ошибка '+Path.ToRemoteSklad+'MARKET\'+Fdate+'.mrk');
      exit;
     end;
  end;

  new(mrk,Init);
  new(mrkmain,Init);



  while not eof(fm) do
  begin
    read(fm,mrk^.Dat);
    if mrk^.Dat.Active then
    begin
     mrk^.Dat.SkladKod:='01';
     for i:=1 to mrk^.Dat.Amount do
     begin
      {уменьшаем остатки на 2 отд (rek.kod)}
      sr:=copy(mrk^.Dat.MarketElement[i].BazKOd,1,2);
      skod:=copy(mrk^.Dat.MarketElement[i].BazKOd,3,3);
      Assign(fskl,Path.ToRemoteSklad+'MAIN\'+sr+'.db');
      IORez:=ioresult;
      reset(fskl);
      IORez:=ioresult;
      if iorez<>0 then memcc(Path.ToRemoteSklad+'MAIN\'+sr+'.db');
      seek(fskl,StrToInt(skod));
      IORez:=ioresult;
      read(fskl,skl);
      IORez:=ioresult;
      skl.Input.kol:=IntToStr(StrToInt(skl.Input.kol)-StrToInt(mrk^.Dat.MarketElement[i].Input.kol),CKol);
      skl.Input.DivisionS[StrToInt(rek.kod)]:=
        IntToStr(StrToInt(skl.Input.DivisionS[StrToInt(rek.kod)])-StrToInt(mrk^.Dat.MarketElement[i].Input.kol),CKol);
      IORez:=ioresult;
      seek(fskl,StrToInt(skod));
      IORez:=ioresult;
      write(fskl,skl);
      IORez:=ioresult;
      close(fskl);
      mrk^.Dat.MarketElement[i].Input.DiviSionSNumber:=StrToInt(rek.kod);
     end;
     seek(fmmain,filesize(fmmain));
     mrk^.Dat.Document:=IntToStr(filesize(fmmain)+1,CDocNumer);
     write(fmmain,mrk^.Dat);
     {Долги}
     if mrk^.Dat.DocSelector in [5..8] Then
     Begin
       CreatRemoteClientDolgFile(mrk);
     End;
     If mrk^.Dat.DocSelector in [6,8] Then
     Begin
       Sf:=True;
     End
     Else Sf:=False;

     if mrk^.Dat.DocSelector in [5..8] Then
     SaveRemoteRealizasToClientFile(mrk,sf);
     if mrk^.Dat.Amount>0 then
     SaveToStatFile(mrk,Sf,GetIdRealiz(mrk^.Dat.MarketElement[1].BazKod))
	else SaveToStatFile(mrk,Sf,false);

    end;
  end;

  close(fm);
  close(fmmain);
  Dispose(mrk,Done);
  Dispose(mrkmain,Done);

  MessageBox(^m+#3'Выгрузка продаж завершена! ',Nil,mfError+mfCancelButton);

End;

BEGIN

END.