Uses glob,ServStr,Serv;

VAr sklFile : File Of SkladType;
    skl : pSkladType;
    Przf : File Of PereozenkaType;
    Prz : PPereozenkaType;
    RazdelFile : File Of RazdelType;
    RazdelElement : RazdelType;
    RazdelKod : String[2];
    NameKod : String[3];
    F : Boolean;
    PrzCount,c : Word;
    Txt : Text;
    Artikul : ArtikulStr;
    SRZena,SOZena : String[CZena];
    Ok : Boolean;
    ch : Char;

    BazFile : File Of BazType;
    BazElement : PBazType;

Function SetID(C:ArtikulStr;Status:Word): Boolean;
Var l    : LongInt;
    Code : Integer;
    st   : ArtikulStr;
Begin
 st:=c;
 New(BazElement,Init);
 DelSpace(st);
 c:=Copy(st,1,CRazdelKod);
 Assign(BazFile,ParamStr(5)+c+'.id');
 SetID:=False;
 l:=IOResult;
 Reset(BazFile);
 l:=IOResult;
 If l <> 0 Then
 Begin
  Writeln('Ошибка записи в позиции с кодом '+c);
  Readln;
  Exit;
 End
 Else
  Begin
   c:=Copy(st,1+CRazdelKod,CKod);
   L:=StrToInt(C);
   Seek(BazFile,L);
   New(BazElement,Init);
   Read(BazFile,BazElement^.Dat);
   BazElement^.DAt.Market:=1;
   Seek(BazFile,FilePos(BazFile)-1);
   Write(BazFile,BazElement^.Dat);
   Close(BazFile);
   Dispose(BazElement,Done);
   SetID:=True;
  End;
End;

Begin
   If (ParamStr(1)='?') Or (ParamStr(1)='') Then
   Begin
    Writeln('Утилита групповой переоценки, для работы которой требуется:');
    Writeln(' 1 -код склада (Сойфера-0001, КТИ-0002, Мясново - 0003, Резерв-0004)');
    Writeln(' 2 -путь к файлу со структурой "код цена"');
    Writeln(' 3 -путь к файлам *.db включая \');
    Writeln(' 4 -путь к файлам *.prz включая \');
    Writeln(' 5 -путь к файлам *.id включая \');
    Writeln(' 6 -Y или N проводить деблокирование переоцененных позиций');
    Halt;
   End;

   Assign(txt,ParamStr(2));
   c:=IOResult;
   Reset(txt);
   c:=IOResult;

If c<>0 Then
 Begin
  Writeln('Ошибка доступа к файлу данных с новыми ценами');
  Exit;
 End;

   Assign(PrzF,ParamStr(4)+FDate+'.prz');
   c:=IOResult;
   Reset(PrzF);
   c:=IOResult;
If c<>0 Then
 Begin
   c:=IOResult;
   Rewrite(PrzF);
   c:=IOResult;
   If c<>0 Then
   Begin
    Close(txt);
    Writeln('Предварительно надо создать '+ParamStr(4)+FDate+'.prz');
    Exit;
   End;
 End;

   New(Prz,Init);
   Prz^.Dat.Vid:=0;
   Prz^.Dat.Amount:=0;
   Prz^.Dat.SkladKod:=ParamStr(1);
   Prz^.Dat.DateC:=Prz^.Dat.DateM;
   Prz^.Dat.TimeC:=Prz^.Dat.TimeM;

   Str(FileSize(PrzF)+1:CDocNumer,Prz^.Dat.Document);
   DelSpace(Prz^.Dat.Document);
   Seek(PrzF,FileSize(PrzF));

   New(Skl,Init);

   While Not(SeekEof(txt)) Do
    Begin
{Запись переоценки в файл если она заполнена и создание нового экземляра}
       If Prz^.Dat.Amount>=55 Then
       Begin
        Str(StrToReal(Prz^.Dat.Itogo_New_R_Zena)-StrToReal(Prz^.Dat.Itogo_Bak_R_Zena):CIZena:CMantissa
        ,Prz^.Dat.Delta_RZ);
         DelSpace(Prz^.Dat.Delta_RZ);
        Str(StrToReal(Prz^.Dat.Itogo_New_O_Zena)-StrToReal(Prz^.Dat.Itogo_Bak_O_Zena):CIZena:CMantissa
       ,Prz^.Dat.Delta_OZ);
        DelSpace(Prz^.Dat.Delta_OZ);

        Seek(PrzF,FileSize(PrzF));
        Write(PrzF,Prz^.Dat);
        Dispose(Prz,Done);

        New(Prz,Init);
        Prz^.Dat.Vid:=0;
        Prz^.Dat.Amount:=0;
        Prz^.Dat.SkladKod:=ParamStr(1);
        Prz^.Dat.DateC:=Prz^.Dat.DateM;
        Prz^.Dat.TimeC:=Prz^.Dat.TimeM;
        Str(FileSize(PrzF)+1:CDocNumer,Prz^.Dat.Document);
        DelSpace(Prz^.Dat.Document);
        Seek(PrzF,FileSize(PrzF));
       End;

     c:=IOResult;
     Read(txt,Artikul);
     Read(txt,ch);
     ReadLn(txt,SRZena);
     SOZena:=SRZena;

     DelSpace(Artikul);

     If ParamStr(6)='Y' Then
      Begin
       If SetID(Artikul,1) Then Writeln('Позиция '+Artikul+' успешно деблокирована!')
       Else Writeln('Ошибка деблокирования '+Artikul);

      End;

     Str(StrToREal(SRZena):CZena:CMantissa,SRZena);
     DelSpace(SRZena);
     Str(StrToREal(SOZena):CZena:CMantissa,SOZena);
     DelSpace(SOZena);
     RazdelKod:=Copy(Artikul,1,2);
     NAmeKod:=Copy(Artikul,3,3);

     {Открытие файла наличия}
     Assign(sklFile,ParamStr(3)+RazdelKod+'.db');
     c:=IOResult;
     Reset(sklFile);
     c:=IOResult;
     If c<>0 Then
      Begin
       Writeln('Ошибка доступа к файлу '+ParamStr(3)+RazdelKod+'.db в позиции '+Artikul);
       Readln;
       Ok:=False;
      End
      Else Ok :=True;
     If Ok Then
     Begin
      Seek(SklFile,StrToInt(NameKod));
      Read(SklFile,Skl^.Dat);

       Inc(Prz^.Dat.Amount);{счетчик элементов в переоценке}
       Prz^.Dat.Element[Prz^.Dat.Amount].BazKod:=Skl^.Dat.BazKod;
       Prz^.Dat.Element[Prz^.Dat.Amount].Kol:=Skl^.Dat.Input.Kol;
       {старые цены в переоценке}
       Prz^.Dat.Element[Prz^.Dat.Amount].Bak_R_Zena:=Skl^.Dat.Input.R_Zena;
       Prz^.Dat.Element[Prz^.Dat.Amount].Bak_O_Zena:=Skl^.Dat.Input.O_Zena;
       Prz^.Dat.Caption := '00';
       {Итого по старым ценам}
       Str(StrToInt(Skl^.Dat.Input.Kol)*StrToReal(Skl^.Dat.Input.R_Zena)+
	  StrToReal(Prz^.Dat.Itogo_Bak_R_Zena):CIZena:CMantissa,Prz^.Dat.Itogo_Bak_R_Zena);
       DelSpace(Prz^.Dat.Itogo_Bak_R_Zena);
       Str(StrToInt(Skl^.Dat.Input.Kol)*StrToReal(Skl^.Dat.Input.O_Zena)+
	  StrToReal(Prz^.Dat.Itogo_Bak_O_Zena):CIZena:CMantissa,Prz^.Dat.Itogo_Bak_O_Zena);
       DelSpace(Prz^.Dat.Itogo_Bak_O_Zena);
       {пересчитываем складские цены и записываем новую цену на склад}
       Skl^.Dat.Input.O_Zena:=SOZena;
       Skl^.Dat.Input.R_Zena:=SRZena;
       Seek(SklFile,FilePos(SklFile)-1);
       Write(SklFile,Skl^.Dat);
       {новые цены в переоценке}
       Prz^.Dat.Element[Prz^.Dat.Amount].New_R_Zena:=Skl^.Dat.Input.R_Zena;
       Prz^.Dat.Element[Prz^.Dat.Amount].New_O_Zena:=Skl^.Dat.Input.O_Zena;
       {Итого по новым ценам}
       Str(StrToInt(Skl^.Dat.Input.Kol)*StrToReal(Skl^.Dat.Input.R_Zena)+
	  StrToReal(Prz^.Dat.Itogo_New_R_Zena):CIZena:CMantissa,Prz^.Dat.Itogo_New_R_Zena);
       DelSpace(Prz^.Dat.Itogo_New_R_Zena);
       Str(StrToInt(Skl^.Dat.Input.Kol)*StrToReal(Skl^.Dat.Input.O_Zena)+
	  StrToReal(Prz^.Dat.Itogo_New_O_Zena):CIZena:CMantissa,Prz^.Dat.Itogo_New_O_Zena);
       DelSpace(Prz^.Dat.Itogo_New_O_Zena);
       Writeln('Позиция: '+Artikul+' Все ок');
     End;{Ok}
     Close(SklFile);
     c:=IOResult;

    End;{While txt}

       If Prz^.Dat.Amount>0 Then
       Begin
        Str(StrToReal(Prz^.Dat.Itogo_New_R_Zena)-StrToReal(Prz^.Dat.Itogo_Bak_R_Zena):CIZena:CMantissa
        ,Prz^.Dat.Delta_RZ);
         DelSpace(Prz^.Dat.Delta_RZ);
        Str(StrToReal(Prz^.Dat.Itogo_New_O_Zena)-StrToReal(Prz^.Dat.Itogo_Bak_O_Zena):CIZena:CMantissa
       ,Prz^.Dat.Delta_OZ);
        DelSpace(Prz^.Dat.Delta_OZ);

        Seek(PrzF,FileSize(PrzF));
        Write(PrzF,Prz^.Dat);
        c:=IOResult;
        Dispose(Prz,Done);

        New(Prz,Init);
        Prz^.Dat.Vid:=0;
        Str(FileSize(PrzF):CDocNumer,Prz^.Dat.Document);
        DelSpace(Prz^.Dat.Document);
        Seek(PrzF,FileSize(PrzF));
       End;


   Dispose(Skl,Done);
   Dispose(Prz,Done);
   Close(PrzF);
   c:=IOResult;
End.
