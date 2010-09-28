Uses Glob,Serv,Servstr,Mail,Utils,Utils4,Utils5,Objects,StHolder,
     Dialogs,DBIII,
     TpDate,NetCall,Dos,NetDbEng;

Var Base : DBase3;


Procedure ExportClientToDBF;
Begin

with Base do
begin
 Assign(ParamStr(2)+'base_tov.dbf'); {пpисвоить БД имя}
 Init; {подготовиться к созданию БД}

 AddField('ParentID','C',8,0);{Код группы-родителя}
 AddField('Code','C',8,0);{код клиента}
 AddField('NAME','C',30,0);{название организации}
 AddField('Lizo','N',1,0);{лицо юридическое физическое}
 AddField('FULLNAME','C',45,0);
 AddField('URADR','C',45,0);
 AddField('ADR','C',45,0);
 AddField('Tel','C',45,0);
 AddField('INN','C',45,0);
 AddField('DocSer','C',45,0);
 AddField('DocNom','C',45,0);
 AddField('DocKEM','C',45,0);
 AddField('DocDate','C',8,0);
 AddField('OSNDOG','C',2,0);

      if Create then
         Open(ReadWrite)
      else
            begin
             Writeln('Ошибка создания '+ParamStr(2)+'base_tov.dbf');
             exit;
            end;
End;{With Base}
End;


Begin
c:=IOResult;
Reset (ClF,SizeOf(ClientType));
c:=IOResult;
If c=0 Then
Begin
{AInfo('Читаю списки...');}
While Not(Eof(ClF)) Do
 Begin
    DInfoMsgShkala('Читаю списки контрагентов. Ждите... ',0,FileSize(CLF),FilePos(CLF));
    Count:=0;
    New(CLE,Init);
    ReadBufClient(Clf,CLE,Count);
  For c:=1 To Count Do

  Begin
  If ClE^.Point.Dat[c].Employ Then
   Begin
    Format (ClE^.Point.Dat[c].Name,CClient);

  With Base Do
  Begin
  Append; {добавить новую запись}
 WriteStr('ParentID','0');{Код группы-родителя}
 WriteStr('Code',ClE^.Point.Dat[c].Kod);{код клиента}
 WriteStr('NAME',ClE^.Point.Dat[c].Name);{название организации}
 WriteNUM('Lizo',ClE^.Point.Dat[c].Lizo);{лицо юридическое физическое}
 WriteStr('FULLNAME',ClE^.Point.Dat[c].FullName);
 WriteStr('URADR',ClE^.Point.Dat[c].Adress);
 WriteStr('ADR',ClE^.Point.Dat[c].FAdress);
 WriteStr('Tel',);
 WriteStr('INN',);
 WriteStr('DocSer',);
 WriteStr('DocNom',);
 WriteStr('DocKEM',);
 WriteStr('DocDate',);
 WriteStr('OSNDOG',);
  End;


   End;{Employ}
  End;{For}
     Dispose(CLE,Done);
 End;{Eof}
System.Close(ClF);
NoInfoMsg;




      While Not(System.Eof(ef)) Do
      Begin
       New(E,Init);
       Count:=0;
       ReadBufSklad(ef,E,Count);

For jjj:=1 To Count Do
Begin

 If GetIdMarket(E^.Point.Dat[jjj].BazKod)=1 Then
 If StrToInt(E^.Point.Dat[jjj].Input.Kol)>0 Then
 Begin

  SArtikul:=E^.Point.Dat[jjj].BAzKod;
  SKol:=E^.Point.Dat[jjj].Input.Kol;
  Str(StrToInt(SKol):CKol,SKol);
  SKod:=E^.Point.Dat[jjj].Input.StrihKod{BazKod,0)};
  RFormatZerro(SKod,CStrihKod-2);
  SZena:=E^.Point.Dat[jjj].Input.R_Zena;
  MySTr(StrToReal(SZena),CZena,CMantissa,SZena);

  New(BBB,Init);
  BBB^.Dat.BazKod:=SArtikul;
  GetBazElement(SArtikul,BBB^.Dat);
  SNAme:=BBB^.DAt.NAme;
  DelSpaceRight(SName);
  SNAme2:=BBB^.DAt.NAme2;
  DelSpaceRight(SName2);
  ws:=SNAme+' '+SName2;
  Format(ws,CName+1+CName);
  Dispose(bbb,Done);

  With BAse Do
  Begin
  Append; {добавить новую запись}
 WriteStr('ParentID','0');{Код группы-родителя}
 WriteStr('Code',);{код клиента}
 WriteStr('NAME',);{название организации}
 WriteNUM('Lizo',);{лицо юридическое физическое}
 WriteStr('FULLNAME',);
 WriteStr('URADR',);
 WriteStr('ADR',);
 WriteStr('Tel',);
 WriteStr('INN',);
 WriteStr('DocSer',);
 WriteStr('DocNom',);
 WriteStr('DocKEM',);
 WriteStr('DocDate',);
 WriteStr('OSNDOG',);
  End;

 End;

End;{For чтения}
Dispose(E,Done);

      End;{While}

      System.Close(Ef);
End;{фильтр разделов с документацией}

     End;{наличие}
BASE.Close;

FileMode:=66;

NoInfoMsg;

i:=IoResult;

 Dispose(TempList,Done);

 NoInfo;

i:=IoResult;
 Assign(ef,Path^.Dat.ToTerminal+'wait_imp.flg');
i:=IoResult;
 Rewrite(ef);
i:=IoResult;
  If i<>0 Then
   Begin
    Messagebox(^M+#3'Ошибка создания файла флага '+Path^.Dat.ToTerminal+'wait_imp.flg!'+
    ClicProgrammer^,Nil,mfError+mfCancelButton);
   End;
 Close(ef);
i:=IoResult;

 Assign(ef,Path^.Dat.ToTerminal+FDate+'.o'+wk);
i:=IoResult;
 Rewrite(ef);
i:=IoResult;
  If i<>0 Then
   Begin
    Messagebox(^M+#3'Ошибка создания файла '+Path^.Dat.ToTerminal+FDate+'.o'+wk+'!'+
    ClicProgrammer^,Nil,mfError+mfCancelButton);
   End;
 Close(ef);
i:=IoResult;

 Assign(ef,Path^.Dat.ToTerminal+FDate+'.m'+wk);
i:=IoResult;
 Rewrite(ef);
i:=IoResult;
  If i<>0 Then
   Begin
    Messagebox(^M+#3'Ошибка создания файла '+Path^.Dat.ToTerminal+FDate+'.m'+wk+'!'+
    ClicProgrammer^,Nil,mfError+mfCancelButton);
   End;
 Close(ef);
i:=IoResult;

 Addprotocol('Экспорт данных в кассовый сервер','Версия: '+wk,'');

 Messagebox(^M+#3'Экспорт базы наличия товара успешно завершен!',
 Nil,mfWarning+mfCancelButton);

End;
