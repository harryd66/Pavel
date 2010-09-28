Uses Glob,servstr,TpDate,Serv,Utils,DbEngine,Net,NetDbEng;



Procedure CreatFantomBazFromrezerv;
VAr fskl,fskln : SkladFileType;
    fr : File Of RazdelType;
    c,i : Word;
    l,k : LongInt;
    st : AllStr;
    skl : PSkladType;
    RazdelElement : RAzdelType;
Begin
{открываем db - файл резервного склада}
{создаем новый db файл фантомной базы}
{по позиционно делаем скледующее
   1. читаем запись из резервного склада
   2. обнуляем все отделения кроме первого и снимаем все брони
   3. не забронированный остаток из первого отделения перемещаем в 4-ое
   4. обнуляем остаток первого отделения
   5. записываем полученную запись в созданный файла}

Assign(fr,'razdel.db'{'c:\nitogo\razdel.db'});
c:=IOResult;
Reset(fr);
c:=IOResult;
If c<>0 Then
 Begin
  Writeln('ошибка открытия файла разделов');
  Halt;
 End;

While Not(Eof(fr)) Do
Begin
Read(fr,RAzdelElement);
If RAzdelElement.Employ Then
Begin
st:=RAzdelElement.Kod;
RFormatZerro(st,CMAntissa);
Assign(fskl,ParamStr(3)+{'C:\NITOGO\0004\newskl\MAIN\'}+st+'.db');
l:=IOResult;
Reset(fskl);
l:=IOResult;
If l=0 Then
Begin
Assign(fskln,ParamStr(2){'C:\TEMP\MAIN\'}+st+'.db');
l:=IOResult;
Rewrite(fsklN);
l:=IOResult;
If l=0 Then
 Begin
  Write('Раздел '+st+' Склада Резервный');
  New(Skl,Init);
  While Not(Eof(Fskl)) Do
   Begin
    ReadSklad(fskl,Skl^.Dat);
    If Skl^.Dat.Employ Then
   Begin
    Skl^.Dat.Input.Kol[0]:=#0;
    Skl^.Dat.Input.KolR[0]:=#0;
    For i:=2 to CDivision Do
     Begin
      Skl^.Dat.Input.Division[i,0]:=#0;
      Skl^.Dat.Input.DivisionR[i,0]:=#0;
     End;{For cdivision}

      Str(StrToInt(Skl^.Dat.Input.Division[1])-
          StrToInt(Skl^.Dat.Input.DivisionR[1]):CKOl,Skl^.Dat.Input.Division[5]);

      If StrToInt(Skl^.Dat.Input.Division[5])<0 Then Skl^.Dat.Input.Division[5]:='0';
      DelSpace(Skl^.Dat.Input.Division[5]);

      If RazdelElement.EnableDoc=1 Then
      Begin
       Skl^.Dat.Input.Division[5]:='1000';
       Skl^.Dat.Input.R_Zena:='6.00';
       Skl^.Dat.Input.O_Zena:='6.00';
       Skl^.Dat.Input.Spec_Zena:='6.00';
       Skl^.Dat.Input.Zakupka:='0.0000';
       Skl^.Dat.Input.Zakupka2:='0.0000';
      End;

      Skl^.Dat.Input.Division[1,0]:=#0;
      Skl^.Dat.Input.DivisionR[1,0]:=#0;

    For i:=1 to CDivision Do
     Begin
      Str(StrToInt(Skl^.Dat.Input.Kol)+
          StrToInt(Skl^.Dat.Input.Division[i]):CKOl,Skl^.Dat.Input.Kol);
     End;{For cdivision}
     DelSpace(Skl^.Dat.Input.Kol);
   End;{Employ}
    Seek(fskln,FileSize(FsklN));
    Write(fskln,Skl^.Dat);
   End;{While}

   Dispose(Skl,Done);
   l:=IOResult;
   Close(fskln);
   Writeln(' Ок');
 End
 Else
  Begin
   Writeln('ошибка создания '+Paramstr(2)+{c:\temp\main\'}+st+'.db Код:',l);
  End;

  l:=IOResult;
  close(fskl);
End
 Else
  Begin
    Writeln('ошибка открытия '+ParamStr(3)+{c:\NITOGO\0004\MAIN\'}+st+'.db Код:',l);
  End;

End;{RazdelElement.Employ}
End;{While Razdel}

Close(fr);
c:=IOResult;

End;



Procedure CreatFantomBazFromSoif;
VAr fskl,fskln : SkladFileType;
    fr : File Of RazdelType;
    c,i : Word;
    l,k : LongInt;
    st : AllStr;
    skl : PSkladType;
    sklN : PSkladType;
    RazdelElement : RAzdelType;
Begin
{открываем db - файл резервного склада}
{создаем новый db файл фантомной базы}
{по позиционно делаем скледующее
   1. читаем запись из резервного склада
   2. обнуляем все отделения кроме первого и снимаем все брони
   3. не забронированный остаток из первого отделения перемещаем в 4-ое
   4. обнуляем остаток первого отделения
   5. записываем полученную запись в созданный файла}

Assign(fr,'razdel.db');
c:=IOResult;
Reset(fr);
c:=IOResult;
If c<>0 Then
 Begin
  Writeln('ошибка открытия файла разделов');
  Halt;
 End;

While Not(Eof(fr)) Do
Begin
Read(fr,RAzdelElement);
If RAzdelElement.Employ Then
Begin
st:=RAzdelElement.Kod;
RFormatZerro(st,CMAntissa);
Assign(fskl,ParamStr(4)+{'C:\NITOGO\0001\newskl\MAIN\'}+st+'.db');
l:=IOResult;
Reset(fskl);
l:=IOResult;
If l=0 Then
Begin
Assign(fskln,ParamStr(2){'C:\TEMP\MAIN\'}+st+'.db');
l:=IOResult;
Reset(fsklN);
l:=IOResult;
If l=0 Then
 Begin
  Write('Раздел '+st+' Склада Сойфера');
  New(Skl,Init);
  New(SklN,Init);
  While Not(Eof(Fskl)) Do
   Begin
    ReadSklad(fskl,Skl^.Dat);
    ReadSklad(fskln,SklN^.Dat);

   If Skl^.Dat.Employ Then
   Begin
      Str(StrToInt(Skl^.Dat.Input.Division[1])-
          StrToInt(Skl^.Dat.Input.DivisionR[1]):CKOl,Skln^.Dat.Input.Division[6]);

      If StrToInt(Skln^.Dat.Input.Division[6])<0 Then Skln^.Dat.Input.Division[6]:='0';
      DelSpace(Skln^.Dat.Input.Division[6]);

    Skln^.Dat.Input.Kol[0]:=#0;
    Skln^.Dat.Input.KolR[0]:=#0;

    For i:=1 to CDivision Do
     Begin
      Str(StrToInt(Skln^.Dat.Input.Kol)+
          StrToInt(Skln^.Dat.Input.Division[i]):CKOl,Skln^.Dat.Input.Kol);
     End;{For cdivision}
     DelSpace(Skln^.Dat.Input.Kol);
   End;{Employ}
    Seek(fskln,FilePos(FsklN)-1);
    Write(fskln,Skln^.Dat);
   End;{While}

   Dispose(Skl,Done);
   Dispose(SklN,Done);
   l:=IOResult;
   Close(fskln);
   Writeln(' Ок');
 End
 Else
  Begin
   Writeln('ошибка открытия '+Paramstr(2)+{c:\temp\main\'}+st+'.db Код:',l);
  End;

  l:=IOResult;
  close(fskl);
End
 Else
  Begin
    Writeln('ошибка открытия '+ParamStr(3)+{c:\NITOGO\0004\MAIN\'}+st+'.db Код:',l);
  End;

End;{RazdelElement.Employ}
End;{While Razdel}

Close(fr);
c:=IOResult;

End;


Procedure CreatFantomBazFromKti;
VAr fskl,fskln : SkladFileType;
    fr : File Of RazdelType;
    c,i : Word;
    l,k : LongInt;
    st : AllStr;
    skl : PSkladType;
    sklN : PSkladType;
    RazdelElement : RAzdelType;
Begin
{открываем db - файл резервного склада}
{создаем новый db файл фантомной базы}
{по позиционно делаем скледующее
   1. читаем запись из резервного склада
   2. обнуляем все отделения кроме первого и снимаем все брони
   3. не забронированный остаток из первого отделения перемещаем в 4-ое
   4. обнуляем остаток первого отделения
   5. записываем полученную запись в созданный файла}

Assign(fr,'razdel.db');
c:=IOResult;
Reset(fr);
c:=IOResult;
If c<>0 Then
 Begin
  Writeln('ошибка открытия файла разделов');
  Halt;
 End;

While Not(Eof(fr)) Do
Begin
Read(fr,RAzdelElement);
If RAzdelElement.Employ Then
Begin
st:=RAzdelElement.Kod;
RFormatZerro(st,CMAntissa);
Assign(fskl,ParamStr(5)+{'C:\NITOGO\0001\newskl\MAIN\'}+st+'.db');
l:=IOResult;
Reset(fskl);
l:=IOResult;
If l=0 Then
Begin
Assign(fskln,ParamStr(2){'C:\TEMP\MAIN\'}+st+'.db');
l:=IOResult;
Reset(fsklN);
l:=IOResult;
If l=0 Then
 Begin
  Write('Раздел '+st+' Склада КТИ');
  New(Skl,Init);
  New(SklN,Init);
  While Not(Eof(Fskl)) Do
   Begin
    ReadSklad(fskl,Skl^.Dat);
    ReadSklad(fskln,SklN^.Dat);

   If Skl^.Dat.Employ Then
   Begin
      Str(StrToInt(Skl^.Dat.Input.Division[1])-
          StrToInt(Skl^.Dat.Input.DivisionR[1]):CKOl,Skln^.Dat.Input.Division[7]);

      If StrToInt(Skln^.Dat.Input.Division[7])<0 Then Skln^.Dat.Input.Division[7]:='0';
      DelSpace(Skln^.Dat.Input.Division[7]);

    Skln^.Dat.Input.Kol[0]:=#0;
    Skln^.Dat.Input.KolR[0]:=#0;

    For i:=1 to CDivision Do
     Begin
      Str(StrToInt(Skln^.Dat.Input.Kol)+
          StrToInt(Skln^.Dat.Input.Division[i]):CKOl,Skln^.Dat.Input.Kol);
     End;{For cdivision}
     DelSpace(Skln^.Dat.Input.Kol);
   End;{Employ}
    Seek(fskln,FilePos(FsklN)-1);
    Write(fskln,Skln^.Dat);
   End;{While}

   Dispose(Skl,Done);
   Dispose(SklN,Done);
   l:=IOResult;
   Close(fskln);
   Writeln(' Ок');
 End
 Else
  Begin
   Writeln('ошибка открытия '+Paramstr(2)+{c:\temp\main\'}+st+'.db Код:',l);
  End;

  l:=IOResult;
  close(fskl);
End
 Else
  Begin
    Writeln('ошибка открытия '+ParamStr(3)+{c:\NITOGO\0004\MAIN\'}+st+'.db Код:',l);
  End;

End;{RazdelElement.Employ}
End;{While Razdel}

Close(fr);
c:=IOResult;

End;



Procedure CAlcAndSaveControlSumma;
VAr fskl,fskln : SkladFileType;
    fr : File Of RazdelType;
    c,i : Word;
    l,k : LongInt;
    st : AllStr;
    skl : PSkladType;
    RazdelElement : RAzdelType;
    Summa : AllStr;
    txt : Text;
Begin
Summa[0]:=#0;
Assign(fr,'razdel.db'{'c:\nitogo\razdel.db'});
c:=IOResult;
Reset(fr);
c:=IOResult;
If c<>0 Then
 Begin
  Writeln('ошибка открытия файла разделов');
  Halt;
 End;

While Not(Eof(fr)) Do
Begin
Read(fr,RAzdelElement);
If RAzdelElement.Employ Then
Begin
st:=RAzdelElement.Kod;
RFormatZerro(st,CMAntissa);
Assign(fskl,ParamStr(2)+st+'.db');
l:=IOResult;
Reset(fskl);
l:=IOResult;
If l=0 Then
Begin
  Write('Раздел '+st+' Контрольная сумма');
  New(Skl,Init);
  While Not(Eof(Fskl)) Do
   Begin
    ReadSklad(fskl,Skl^.Dat);

    If Skl^.Dat.Employ Then
     Begin
      MyStr(StrToReal(Summa)+StrToInt(Skl^.Dat.Input.Kol)*StrToReal(Skl^.Dat.Input.R_Zena),
	 CIZena,CMAntissa,Summa);
     End;

   End;{While}

   Dispose(Skl,Done);
   l:=IOResult;
   Close(fskl);
   l:=IOResult;
   Writeln(' Ок');
End
 Else
  Begin
   Writeln('ошибка создания '+Paramstr(2)+{c:\temp\main\'}+st+'.db Код:',l);
  End;


End;{RazdelElement.Employ}
End;{While Razdel}

Close(fr);
c:=IOResult;


Assign(txt,ParamStr(2)+'extrok.txt'{'c:\nitogo\razdel.db'});
c:=IOResult;
Rewrite(txt);
c:=IOResult;
Writeln(txt,Summa);
c:=IOResult;
Close(txt);
c:=IOResult;

End;





Begin
CreatFantomBazFromRezerv;
If FindParam('/1') Then CreatFantomBazFromSoif;
If FindParam('/9') Then CreatFantomBazFromKti;
CAlcAndSaveControlSumma;
End.
