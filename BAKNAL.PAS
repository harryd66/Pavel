Function PrintSklad_Or_Prise
(Video:Boolean;K:Byte;Const Spis:PBox;Const M:MaskaNew;Const Assort,Sort,Sertif,Akzis:Word):TEnjoyStr;

Var R,R1 : TRect;
    l,lk : Word;
    Txt : Text;
    UnPack,Fas,TempArtikul,ss : AllStr;
    s,ws,ws1,ws2 : string[150];
    Otdel,Pack,P : String[CPack];
    TextSertif,Space : TEnJoyStr;
    RazdelZ,RazdelO,RazdelR,ItogoR,ItogoZ,ItogoO : Real;
    stzz,stRz,stOz : String[CPost];
    E : PSkladType;
    Valuta :Word;
    Withnp,KursUSD : String[CZena];
    Usd : Real;
    Wk : String[CKol];
    VidNal,Regim,i : Byte;
    Ef : SkladFileType;
    SProz : TDAteString;
    Skidka : Boolean;
    Koef : Real;
    Art,Koeffizient : String[CArtikul];
    KoefWord : Word;
    Temp,TempList : PBox;
    WspomList: PBox;
    Separator : String[CLitrMantissa];
    Ansi : Word;
    TipID : LongInt;
    MaxSh,sh,VidPrize : Word;
    ZPrize : Maska24;
    SK : PSkidkaType;
    MMM : ArtikulStr;
    Region : Word;
    VVV, MMMAr  : MAska6;
    VVVS : TAutoString1;
    c : LongInt;

Begin
 PrintSklad_Or_Prise:='           0.00';
 If Video Then
 Assign(Txt,Path.ToTemp+'report.txt')
 Else
 Assign(Txt,Path.ToTemp+'reporti.txt');

 l:=IOResult;
 Rewrite(Txt);
 l:=IOResult;
 If (L <> 0) And (Video) Then
  Begin
   MessageBox(#3^M+#3'Не могу создать файл отчета '+Path.ToTemp+'report.txt',Nil,mfError+mfCancelButton);
  {Dispose(Spis,Done);}
   Exit;
  End;
  R.Assign(0,0,0,0);
  TemplIST := New(PBox, Init(R, 1, Nil));
  TempList^.NewList(New(PTextCollection, Init(0,1)));
  For L:=0 To Spis^.List^.Count-1 Do
 Begin
  s:=Spis^.GetText(l,Spis^.List^.Count);
  TempList^.List^.Insert(NewStr(s));
  TempList^.SetRange(TempList^.List^.Count);
 End;

  {Dispose(Spis,Done);}

 If Video Then
 Begin
   Regim:=SelectSort;
   CAse Regim Of
   0:Begin
  R1.Assign(0,0,0,0);
  WspomlIST := New(PBox, Init(R1, 1, Nil));
  WspomList^.NewList(New(PTextCollection, Init(0,1)));
  For L:=0 To TempList^.List^.Count-1 Do
   Begin
    s:=Copy(TempList^.GetText(l,TempList^.List^.Count),1+CRazdel+1,CRazdelKod)+'│'+
       Copy(TempList^.GetText(l,TempList^.List^.Count),1,CRazdel);
    WspomList^.List^.Insert(NewStr(s));
    WspomList^.SetRange(WspomList^.List^.Count);
   End;

  TEmpList^.NewList(Nil);
  TEmpList^.NewList(New(PTextCollection, Init(0,1)));
  For L:=0 To WspomList^.List^.Count-1 Do
   Begin
    s:=WspomList^.GetText(l,WspomList^.List^.Count);
    TempList^.List^.Insert(NewStr(s));
    TempList^.SetRange(TempList^.List^.Count);
   End;
   Dispose(WspomList,Done);

     End;
   2:Begin
      Close(Txt);
      Dispose(TempList,Done);
      Exit;
     End;

   Else;
   End;


  If k=0 Then
     Begin
     VidNal:=SelectVidNalich;
     If VidNal=3 Then
      Begin
       Close(Txt);
       Dispose(TempList,Done);
       Exit;
      End;
     End;
 End
 Else  Begin
        Regim:=1;
        VidNal:=0;
       End;

Valuta:=0;
KoefWord:=0;
Koef:=1.00;
Koef:=StrToReal(Koeffizient);

If Video Then
Begin

       For c:=1 To 6 Do
        Begin
         MMMAr[c]:=0;
        End;

  If k=1 Then
   Begin
    VidPrize:=SelectPrize(ZPrize,5,Region,True,MMMAr);
  If VidPrize<>0 Then
   Begin
    Close(Txt);
    Dispose(TempList,Done);
    Exit;
   End;


    If Region=4 Then{вариант когда используется резервный регион - спец-прайс}
     Begin

       For c:=1 To 6 Do
        Begin
         VVV[c]:=0;
         VVVS[c]:=MYS[c];
        End;


       For c:=1 To 6{CShkala} Do
        Begin
         If MMMAr{ZPrize}[c]=1 Then
          Begin
           VVV[Round(c{-Region*6})]:=1;
           {MemCC(IntToStr(Round(c-Region*6),CKol));}
          End;
        End;

      If Not GetGranizi(VVV,VVVS) Then
       Begin
        Close(Txt);
        Dispose(TempList,Done);
        Exit;
       End;

     End;

   End;

  TipID:=SelectIDTip;
  If TipID=3 Then
   Begin
    Close(Txt);
    Dispose(TempList,Done);
    Exit;
   End;


  If k in[0,1] Then
 Begin
  If True{(StrtoInt(CurrentPassword) in [0,8,9])} then
   begin
     Valuta:=Kurs(KursUSD);
     Str(StrToReal(KursUsd):CZena:CMantissa,KursUSD);
     If Valuta=2 Then
      Begin
        Close(Txt);
        Dispose(TempList,Done);
        Exit;
      End;
     If Valuta=1 Then Usd:=StrToReal(KursUSD);
   end
  End
   Else
     Begin
      Valuta:=0;
      Usd:=1;
     End;


  If k in[1] Then
  Begin
  {If (StrtoInt(CurrentPassword) in [0,8,9]) then}
   begin
     KoefWord:=Menedger(Koeffizient);
     If KoefWord=2 Then
      Begin
        Close(Txt);
        Dispose(TempList,Done);
        Exit;
      End;
     Koef:=StrToReal(Koeffizient);
   end
  End
   Else
    Begin
     Koef:=1;
    End;


  If {(StrtoInt(CurrentPassword) in [0,8,9]) And} (k in[0,1]) then
   begin
     Ansi:=SelectImport(0);
     If Ansi=2 Then
      Begin
        Close(Txt);
        Dispose(TempList,Done);
        Exit;
      End;
     Case Ansi Of
     0:Separator :='$';
     1:Separator :=' ';
     Else;
     End;
   end
   Else
   Separator:=' ';
End
Else
  Begin
   Separator:=' ';
   TipID:=2;
  End;




  DInfo('Анализирую данные...');

If Video Then
  Begin

  If k=1 Then
  Writeln(Txt,'Предприятие:'+Rek.Name);
  Writeln(Txt,'Склад: '+{GetClientField(FClient,}Rek.Kod{,1)+}+'Оператор: '+CurrentPassword+' EYE & 1999');
  If k=1 Then
   Begin
    Writeln(Txt,'Адрес:'+Rek.Adress+' Телефон: '+Rek.Telefon);
   End;

If k<>1 Then{если не прайс лист}
Begin
  Write(Txt,'Вид отбора: ');
  Case TipId Of
  0:Writeln(txt,'Запрещенные к продаже');
  1:Writeln(txt,'Разрешенные к продаже');
  2:Writeln(txt,'Все');
  Else Writeln(txt);
  End;

  Writeln(Txt,'Выбранные отделения:');
  For l:=1 To CDivision Do
  If M[l]=1 Then Write(txt,l:2,':',Rek.Otdel[l],' ');
  Writeln(Txt);
End;
  Case K Of
  0:Begin

  Case VidNal Of
  0:Begin
Space:='  ';
If Valuta=0 Then
Writeln(Txt,Space+'      Н А Л И Ч И Е   Т О В А Р А   Н А   С К Л А Д Е   (рубли)   '+FDate+'  '+Times)
Else
Begin
Writeln(Txt,Space+'      КУРС USD: ',KursUSD);
Writeln(Txt,Space+'      Н А Л И Ч И Е   Т О В А Р А   Н А   С К Л А Д Е   (USD)   '+FDate+'  '+Times);
End;

Writeln(Txt,Space+'_____________________________________________________________________________________');
Writeln(Txt,Space+' Код  О Наименование товара        Фас Колич   О/Цена   Р/Цена    Сумма Р/Ц  Упаковок');
                  {12345 1 12345678901234567890123456│123│12345│}
Writeln(Txt,Space+'_____________________________________________________________________________________');
    End;
  1:Begin
Space:='';
If Valuta=0 Then
  Writeln(Txt,Space+'               Н А Л И Ч И Е  ТОВАРА НА СКЛАДЕ (рубли) '+FDate+'  '+Times)
Else
 Begin
  Writeln(Txt,Space+'      КУРС USD: ',KursUSD);
  Writeln(Txt,Space+'               Н А Л И Ч И Е  ТОВАРА НА СКЛАДЕ (USD) '+FDate+'  '+Times);
 End;
  Writeln(Txt,Space+'_______________________________________________________________________________________________');
  Writeln(Txt,Space+' Код  О Наименование товара        Фас Колич.  Р/Цена  Сумма по Р/Ц   %     З/Цена Сумма по З/Ц');
 {Writeln(txt,Space+'12345 1 12345678901234567890123456 123 12345 12345678 1234567890123 12345 12345678 1234567890123');}
{Writeln(Txt,Space+' Код  Отд  Наименование товара        Фас Колич  Упаковок');}
  Writeln(Txt,Space+'_______________________________________________________________________________________________');
    End;
    Else;
    End;
    End;          {12345      12345678901234567890123456 12345 12345678 12345678 1234567890123 123456789}
  1:Begin
Space:='';
Writeln(txt);
Writeln(Txt,Space+Rek.Header);
Writeln(txt);
If Valuta=0 Then
Begin
Writeln(Txt,Space+'                     П Р А Й С - Л И С Т   (рубли)    '+FDate);
Writeln(Txt,Space+'('+Times+')');
End
Else
 Begin
  Writeln(Txt,Space+'      КУРС USD: ',KursUSD);
  Writeln(Txt,Space+'                     П Р А Й С - Л И С Т   (USD)    '+FDate);
  Writeln(Txt,Space+'('+Times+')');
 End;


 s:=' Код  Отд  !!! Наименование товара      Фас Цена РЦ ';
{s:=' Код  Отд  Наименование товара        Производитель Фас Цена Р/Ц ';}
    {12345 123  123456789012345678901234 1234567890123 123 12345678 12345678 12345678 12345678 }
    {12345 123  123456789012345678901234 123 12345678 12345678 12345678 12345678 12345678 12345678}
 For sh:=1 To CShkala Do
  Begin
   If ZPrize[sh]=1 Then
    Begin
    ws:=IntToStr(Round(sh-Region*6),CMAntissa);
    RFormat(ws,COne);
    s:=s+' Цена '+ws+' ';
    End;
  End;

 For sh:=1 To 6 Do
  Begin
   If MMMAr[sh]=1 Then
    Begin
    ws:=IntToStr(Round(sh),CMAntissa);
    RFormat(ws,COne);
    s:=s+' Цена '+ws+' ';
    End;
  End;

  s[0]:=Chr(Ord(s[0])-1);
 ws[0]:=#0;
 For sh:=1 To Ord(s[0]) Do
  Begin
    ws[sh]:='_';
    ws[0]:=Chr(sh);
  End;
  MaxSh:=Sh;

CAse Region Of
0:Writeln(Txt,Space+Rek.LizensiaOptPiv[Region+1]);
1:Writeln(Txt,Space+Rek.LizensiaOptPiv[Region+1]);
2:Writeln(Txt,Space+Rek.LizensiaOptPiv[Region+1]);
3:Writeln(Txt,Space+Rek.LizensiaOptPiv[Region+1]);
4:Writeln(Txt,Space+'??');
Else;
End;

Writeln(Txt,Space+ws{'______________________________________________________________________________________________'});
DelSpaceRight(Rek.Shapka1);
If Rek.Shapka1[0]<>#0 Then
 Writeln(Txt,Space+Rek.Shapka1);
DelSpaceRight(Rek.Shapka2);
If Rek.Shapka2[0]<>#0 Then
 Writeln(Txt,Space+Rek.Shapka2);
DelSpaceRight(Rek.Shapka3);
If Rek.Shapka3[0]<>#0 Then
 Writeln(Txt,Space+Rek.Shapka3);

Writeln(Txt,Space+ws{'______________________________________________________________________________________________'});
{Writeln(Txt,Space+' Код  Отд  Наименование товара          Р/Цена   О/Цена Фас   Цена уп.Р/Ц   Цена уп.О/Ц');
Writeln(Txt,Space+'_______________________________________________________________________________________');}
Writeln(Txt,Space+s{' Код  Отд  Наименование товара        Производитель        Фас   О/Цена  Цена+НП   Цена+НП уп.'});
                  {12345 1    12345678901234567890123456 12345678901234567890 123 12345678 12345678 1234567890123}
Writeln(Txt,Space+ws{'______________________________________________________________________________________________'});
New(Sk,Init);
    End;
  2:Begin
Space:='  ';
Writeln(Txt,Space+'          А К Т   Р Е В И З И И   Н А   С К Л А Д Е   от '+FDate+'  '+Times);
Writeln(Txt,Space+'________________________________________________________________________________________');
Writeln(Txt,Space+'                                                                    Реальное наличие');
Writeln(Txt,Space+' Код  Отд  Наименование товара        Колич  Упаковок  Р/Цена,    Колич,     Упаковок');
Writeln(Txt,Space+'                                                         руб        шт');
Writeln(Txt,Space+'________________________________________________________________________________________');
{
Writeln(Txt,Space+'            А К Т   Р Е В И З И И   Н А   С К Л А Д Е   от '+FDate+'  '+Times);
Writeln(Txt,Space+'________________________________________________________________________________________');
Writeln(Txt,Space+'                                                                  Реальное наличие ');
Writeln(Txt,Space+' Код  Отд  Наименование товара        Колич  Упаковок        Колич,шт         Упаковок');
Writeln(Txt,Space+'________________________________________________________________________________________');
}
    End;
  Else;{12345  12  12345678901234567890123456 1234567890 12345 123456789}
  End;
  Writeln(Txt);
  End;{If Video}
  ItogoO:=0;
  ItogoR:=0;
  ItogoZ:=0;
 For L:=0 To TempList^.List^.Count-1 Do
 Begin
  If Regim=0 Then s:=Copy(TempList^.GetText(l,TempList^.List^.Count),1,CRazdelKod)
  Else
  s:=Copy(TempList^.GetText(l,TempList^.List^.Count),1+CRazdel+1,CRazdelKod);

  If TestRazdel(s,M,Assort,TipID) Then
  Begin
     If Video Then
     Begin
      Writeln(Txt,'                                 Раздел: '+GetRazdel(s));
      Writeln(Txt);
     End;{If Video}
      Assign(Ef,Path.ToSklad+s+'.db');
      Reset(Ef);
      New(E,Init);
      RazdelO:=0;
      RazdelR:=0;
      RazdelZ:=0;
   Case K Of
   0:Begin
     If VidNal=0 Then
     Begin
      R.Assign(0, 0, 0, 0);
      Temp := New(PBox, Init(R, 1, Nil));
      Temp^.NewList(New(PTextCollection, Init(0,1)));
      While Not(Eof(ef)) Do
      Begin
       {
        Repeat
        Until Lock(ef,FilePos(ef)*SizeOf(SkladType),SizeOf(SkladType));
       }

          ReadSkladPointer(ef,E);
       {
        Repeat
        UnLock(ef,(FilePos(ef)-1)*SizeOf(SkladType),SizeOf(SkladType));
        Until (DosError=0);
       }

      E^.Dat.Input.Kol[0]:=#0;
      For i:=1 To CDivision Do
        If (M[i]=1) And ((GetIDMArket(E^.Dat.BazKod)=TipID)Or(TipID=2)) Then

       Begin
        {Str((StrToInt(E^.Dat.Baz.Input.Kol)+StrToInt(E^.Dat.Baz.Input.DiviSion[i])):CKol,E^.Dat.Baz.Input.Kol);
       End;}
      DelSpace(E^.Dat.Input.Kol);

      Str(StrToReal(E^.Dat.Input.R_Zena):CZena:CMAntissa,E^.Dat.Input.R_Zena);
      Str(StrToReal(E^.Dat.Input.O_Zena):CZena:CMAntissa,E^.Dat.Input.O_Zena);
      Str(StrToReal(E^.Dat.Input.Zakupka):CZena:CMAntissa,E^.Dat.Input.Zakupka);

      If ((E^.Dat.Employ) And (StrToInt(E^.Dat.Input.DivisionS[i])>0)And(Assort=0))Or
       ((E^.Dat.Employ)And(Assort>0)And(((StrToInt(E^.Dat.Input.DivisionS[i])>0))Or(i<=1)))Then
{
      If (GetIdEmploy(E^.Dat.BazKod) And (StrToInt(E^.Dat.Input.Division[i])>0)And(Assort=0))Or
       (GetIdEmploy(E^.Dat.BazKod)And(Assort>0)And(((StrToInt(E^.Dat.Input.Division[i])>0))Or(i<=1)))Then}
       Begin

        If NPrint.FullName=0 Then Ws:=GetIdField(FName,E^.Dat.Bazkod)
        Else Ws:=GetIdField(FFName,E^.Dat.Bazkod);



        Format(ws,CName);
        RFormat(E^.Dat.Input.DiviSionS[i],CKol);

        UnPack:=GetIdField(FInPack,E^.Dat.Bazkod);
        DelSpace(UnPAck);
        RFormat(UnPack,CInPAck);


        {учет скидки наценки}
        {
        If KoefWord=0 Then
        Begin
         Str(StrToReal(E^.Dat.Input.O_Zena)/Koef:CZena:CMantissa,E^.Dat.Input.O_Zena);
         Str(StrToReal(E^.Dat.Input.R_Zena)/Koef:CZena:CMantissa,E^.Dat.Input.R_Zena);
         DelSpace(E^.Dat.Input.R_Zena);
         DelSpace(E^.Dat.Input.O_Zena);
        End
        Else
        Begin
         Str(StrToReal(E^.Dat.Input.O_Zena)+Koef*StrToReal(E^.Dat.Input.O_Zena)/100:CZena:CMantissa,E^.Dat.Input.O_Zena);
         Str(StrToReal(E^.Dat.Input.R_Zena)+Koef*StrToReal(E^.Dat.Input.R_Zena)/100:CZena:CMantissa,E^.Dat.Input.R_Zena);
         DelSpace(E^.Dat.Input.R_Zena);
         DelSpace(E^.Dat.Input.O_Zena);
        End;
        }

         Str(StrToReal(E^.Dat.Input.O_Zena):CZena:CMantissa,E^.Dat.Input.O_Zena);
         Str(StrToReal(E^.Dat.Input.R_Zena):CZena:CMantissa,E^.Dat.Input.R_Zena);
         DelSpace(E^.Dat.Input.R_Zena);
         DelSpace(E^.Dat.Input.O_Zena);

        {учет валюты}
        If Valuta=0 Then
        Begin
        RFormat(E^.Dat.Input.O_Zena,CZena);
        RFormat(E^.Dat.Input.R_Zena,CZena);
        End
        Else
         Begin
          Str(StrToReal(E^.Dat.Input.O_Zena)/Usd:CZena:CMantissa,E^.Dat.Input.O_Zena);
          Str(StrToReal(E^.Dat.Input.R_Zena)/Usd:CZena:CMantissa,E^.Dat.Input.R_Zena);
          RFormat(E^.Dat.Input.O_Zena,CZena);
          RFormat(E^.Dat.Input.R_Zena,CZena);
         End;
        P:=CalcPackNoFile(GetIdField(FInPack,E^.Dat.Bazkod),E^.Dat.Input.DiviSionS[i]);
        DelSpace(P);
        RFormat(P,CPack);
        Str((StrToInt(E^.Dat.Input.DiviSionS[i])*StrToReal(E^.Dat.Input.R_Zena)):CInputIZena:CMantissa,Strz);
        Str((StrToInt(E^.Dat.Input.DiviSionS[i])*StrToReal(E^.Dat.Input.O_Zena)):CInputIZena:CMantissa,StOz);
        RazdelR:=RazdelR+StrToReal(StRz);
        RazdelO:=RazdelO+StrToReal(StOz);

        DelSpace(stOz);
        RFormat(stOz,CInputIZena-1);
        DelSpace(stRz);
        RFormat(stRz,CInputIZena-1);

        Str(i:1,S);
        If StrToInt(E^.Dat.Input.DivisionS[i])=0 Then S:=' ';

        If GetIdLocked(E^.Dat.BazKod) Then
        Ws:=Space+E^.Dat.BazKod+#249+s+Separator+ws+Separator+UnPack+Separator+E^.Dat.Input.DiviSionS[i]+Separator+
        E^.Dat.Input.O_Zena+Separator+{stOz+}+E^.Dat.Input.R_Zena+Separator+strz+Separator+P
        Else
        Ws:=Space+E^.Dat.BazKod+Separator+s+Separator+ws+Separator+UnPack+Separator+E^.Dat.Input.DiviSionS[i]+Separator+
        E^.Dat.Input.O_Zena+Separator+{stOz+}+E^.Dat.Input.R_Zena+Separator+strz+Separator+P;



        If Sort>0 Then
        Begin
         Otdel[0]:=#0;
         Otdel:=Copy(ws,Ord(Space[0])+1+CArtikul+1,1);
         P:=Copy(ws,Ord(Space[0])+1,CArtikul+1+1);
         Delete(ws,Ord(Space[0])+1,CArtikul+1+1);
         Insert(Otdel,ws,1+Ord(Space[0])+1+CName+1);
         ws:=ws+Separator+P;
        End;
        Temp^.List^.Insert(NewStr(ws));
        Temp^.SetRange(Temp^.List^.Count);
{        Writeln(txt,ws);}
       End;
      End;
      End;
      Close(Ef);
       If ((Temp^.List^.Count-1)>=0) Then
       For lk:=0 To Temp^.List^.Count-1 Do
        Begin
        ws:=Temp^.GetText(lk,Temp^.List^.Count);
        If Sort>0 Then
        Begin
{
         Delete(ws,Ord(Space[0])+1+CName+1+1,2);
         P:=Copy(ws,Ord(ws[0])-CArtikul-2-1,CArtikul+2+2);
         Delete(ws,Ord(ws[0])-CArtikul-2-2,CArtikul+2+2+1);
         Insert(P,ws,Ord(Space[0])+1);
}
         Delete(ws,Ord(Space[0])+1+CName+1+1,1);
         P:=Copy(ws,Ord(ws[0])-CArtikul-1,CArtikul+1+1);
         Delete(ws,Ord(ws[0])-CArtikul-1-1,CArtikul+1+1+1);
         Insert(P,ws,Ord(Space[0])+1);


        End;
        Art:= Copy(ws,Ord(Space[0])+1,CArtikul);
        If GetIdMarket(Art)=0 Then ws:=ws+' З';
        If Video Then
        Begin
         Writeln(txt,Ws);

          If NPrint.FullName=0 Then Ws2:=GetIdField(FName2,Art)
          Else Ws2:=GetIdField(FFName2,Art);
          DelSpaceRight(ws2);

          If ws2[0]<>#0 Then
          Begin
           Format(ws2,CNAme);
           Writeln(txt,Space+'  '+Separator+'    '+Separator+ws2+Separator);
          End;


         If Sertif=1 Then
         Begin
          TempArtikul:=Copy(ws,Ord(Space[0])+1,CArtikul);
          TextSertif:=BakGetField(FSertif,TempArtikul,0);
          DelSpaceRight(TextSertif);
          If TextSertif[0]<>#0 Then
           Begin
            Format(TextSertif,CSertif-1);
            Writeln(Txt,Space+'           Сертификат:'+TextSertif);
           End;
         End;
         If Akzis=1 Then
         Begin
          TempArtikul:=Copy(ws,Ord(Space[0])+1,CArtikul);
          TextSertif:=BakGetField(FAkzis,TempArtikul,0);
          DelSpaceRight(TextSertif);
          If TextSertif[0]<>#0 Then
           Begin
            Format(TextSertif,CSertif-1);
            Writeln(Txt,Space+'           Примечание:'+TextSertif);
           End;
         End;
        End;
        End;
        Dispose(Temp,Done);
If Video Then
Begin
       Writeln(txt,'                                                  _________________________');
Writeln(Txt,Space+'                                            Всего: '
+{,RecognizReal(RazdelO,CIZena,CMantissa),}'        ',RecognizReal(RazdelR,CIZena,CMantissa));
      Writeln(txt);
End;
        ItogoO:=ItogoO+RazdelO;
        ItogoR:=ItogoR+RazdelR;
        ItogoZ:=ItogoZ+RazdelZ;
     End
     Else
      Begin
      R.Assign(0, 0, 0, 0);
      Temp := New(PBox, Init(R, 1, Nil));
      Temp^.NewList(New(PTextCollection, Init(0,1)));
      While Not(Eof(ef)) Do
      Begin
          ReadSkladPointer(ef,E);
          E^.Dat.Input.Kol[0]:=#0;
      For i:=1 To CDivision Do
        If (M[i]=1) And ((GetIDMArket(E^.Dat.BazKod)=TipID)Or(TipID=2)) Then

       Begin
      DelSpace(E^.Dat.Input.Kol);

      Str(StrToReal(E^.Dat.Input.R_Zena):CZena:CMAntissa,E^.Dat.Input.R_Zena);
      Str(StrToReal(E^.Dat.Input.O_Zena):CZena:CMAntissa,E^.Dat.Input.O_Zena);
      Str(StrToReal(E^.Dat.Input.Zakupka):CZena:CMAntissa,E^.Dat.Input.Zakupka);


      If ((E^.Dat.Employ) And (StrToInt(E^.Dat.Input.DivisionS[i])>0)And(Assort=0))Or
       ((E^.Dat.Employ)And(Assort>0)And(((StrToInt(E^.Dat.Input.DivisionS[i])>0))Or(i<=1)))Then
       Begin
        If NPrint.FullName=0 Then Ws:=GetIdField(FName,E^.Dat.Bazkod)
        Else Ws:=GetIdField(FFName,E^.Dat.Bazkod);
        Format(ws,CName);
        RFormat(E^.Dat.Input.DiviSionS[i],CKol);
        UnPack:=GetIdField(FInPack,E^.Dat.Bazkod);
        DelSpace(UnPAck);
        RFormat(UnPack,CInPAck);
{       RFormat(E^.Dat.Input.O_Zena,CZena);
        RFormat(E^.Dat.Input.R_Zena,CZena);}
        {учет скидки наценки}
        {
        If KoefWord=0 Then
        Begin
         Str(StrToReal(E^.Dat.Input.O_Zena)/Koef:CZena:CMantissa,E^.Dat.Input.O_Zena);
         Str(StrToReal(E^.Dat.Input.R_Zena)/Koef:CZena:CMantissa,E^.Dat.Input.R_Zena);
         DelSpace(E^.Dat.Input.R_Zena);
         DelSpace(E^.Dat.Input.O_Zena);
        End
        Else
        Begin
         Str(StrToReal(E^.Dat.Input.O_Zena)+Koef*StrToReal(E^.Dat.Input.O_Zena)/100:CZena:CMantissa,E^.Dat.Input.O_Zena);
         Str(StrToReal(E^.Dat.Input.R_Zena)+Koef*StrToReal(E^.Dat.Input.R_Zena)/100:CZena:CMantissa,E^.Dat.Input.R_Zena);
         DelSpace(E^.Dat.Input.R_Zena);
         DelSpace(E^.Dat.Input.O_Zena);
        End;
        }
         Str(StrToReal(E^.Dat.Input.O_Zena):CZena:CMantissa,E^.Dat.Input.O_Zena);
         Str(StrToReal(E^.Dat.Input.R_Zena):CZena:CMantissa,E^.Dat.Input.R_Zena);
         DelSpace(E^.Dat.Input.R_Zena);
         DelSpace(E^.Dat.Input.O_Zena);

         SProz:='??.??';
         If StrToReal(E^.Dat.Input.Zakupka)>0.009 Then
          Begin
           Str((StrToReal(E^.Dat.Input.R_Zena)-StrToReal(E^.Dat.Input.Zakupka))
		     /StrToReal(E^.Dat.Input.Zakupka)*100:CLitr:CMAntissa,SProz);
          End;


        If Valuta=0 Then
        Begin
        RFormat(E^.Dat.Input.O_Zena,CZena);
        RFormat(E^.Dat.Input.R_Zena,CZena);
        RFormat(E^.Dat.Input.Zakupka,CZena);
        End
        Else
         Begin
          Str(StrToReal(E^.Dat.Input.O_Zena)/Usd:CZena:CMantissa,E^.Dat.Input.O_Zena);
          Str(StrToReal(E^.Dat.Input.R_Zena)/Usd:CZena:CMantissa,E^.Dat.Input.R_Zena);
          Str(StrToReal(E^.Dat.Input.Zakupka)/Usd:CZena:CMantissa,E^.Dat.Input.Zakupka);
          RFormat(E^.Dat.Input.O_Zena,CZena);
          RFormat(E^.Dat.Input.R_Zena,CZena);
          RFormat(E^.Dat.Input.Zakupka,CZena);
         End;

        Str(StrToInt(E^.Dat.Input.DiviSionS[i])*StrToReal(E^.Dat.Input.R_Zena):CInputIZena:CMantissa,Fas);

       {Fas:=GetIdField(FInPack,E^.Dat.Bazkod);
        RFormat(Fas,CInPack);}
{        P:=CalcPackNoFile(GetIdField(FInPack,E^.Dat.Bazkod),E^.Dat.Input.DiviSion[i]);
        DelSpace(P);
        RFormat(P,CPack);}
        Str((StrToInt(E^.Dat.Input.DiviSionS[i])*StrToReal(E^.Dat.Input.R_Zena)):CInputIZena:CMantissa,Strz);
        Str((StrToInt(E^.Dat.Input.DiviSionS[i])*StrToReal(E^.Dat.Input.O_Zena)):CInputIZena:CMantissa,StOz);
        Str((StrToInt(E^.Dat.Input.DiviSionS[i])*StrToReal(E^.Dat.Input.Zakupka)):CInputIZena:CMantissa,StZz);
        DelSpace(stOz);
        RFormat(stOz,CInputIZena);
        DelSpace(stRz);
        RFormat(stRz,CInputIZena);
        RazdelR:=RazdelR+StrToReal(StRz);
        RazdelO:=RazdelO+StrToReal(StOz);
        RazdelZ:=RazdelZ+StrToReal(Stzz);
        Str(i:1,S);

        RFormat(E^.Dat.Input.DiviSionS[i],CKol);

        If StrToInt(E^.Dat.Input.DivisionS[i])=0 Then S:=' ';

        If GetIdLocked(E^.Dat.BazKod) Then
        Ws:=Space+E^.Dat.BazKod+#249+s+Separator+ws+Separator+UnPack+Separator+
           +E^.Dat.Input.DiviSionS[i]+Separator+E^.Dat.Input.R_Zena+Separator+Fas+Separator+SProz+Separator
        Else
        ws:=Space+E^.Dat.BazKod+Separator+s+Separator+ws+Separator+UnPack+Separator+
           +E^.Dat.Input.DiviSionS[i]+Separator+E^.Dat.Input.R_Zena+Separator+Fas+Separator+SProz+Separator;

        Str(StrToInt(E^.Dat.Input.DiviSionS[i])*StrToReal(E^.Dat.Input.Zakupka):CInputIZena-1:CMantissa,Fas);

        ws:=ws+E^.Dat.Input.Zakupka+Separator+Fas;

        If Sort>0 Then
        Begin
         Otdel[0]:=#0;
         Otdel:=Copy(ws,Ord(Space[0])+1+CArtikul+1,1);
         P:=Copy(ws,Ord(Space[0])+1,CArtikul+1+1);
         Delete(ws,Ord(Space[0])+1,CArtikul+1+1);
         Insert(Otdel,ws,1+Ord(Space[0])+1+CName+1);
         ws:=ws+Separator+P;
        End;

        Temp^.List^.Insert(NewStr(ws));
        Temp^.SetRange(Temp^.List^.Count);
{        Writeln(txt,ws);}
       End;
      End;

      End;
      Close(Ef);
       If ((Temp^.List^.Count-1)>=0) Then
       For lk:=0 To Temp^.List^.Count-1 Do
        Begin
        ws:=Temp^.GetText(lk,Temp^.List^.Count);
        If Sort>0 Then
        Begin
         Delete(ws,Ord(Space[0])+1+CName+1+1,1);
         P:=Copy(ws,Ord(ws[0])-CArtikul-1,CArtikul+1+1);
         Delete(ws,Ord(ws[0])-CArtikul-1-1,CArtikul+1+1+1);
         Insert(P,ws,Ord(Space[0])+1);
        End;
        Art:= Copy(ws,Ord(Space[0])+1,CArtikul);
        If GetIdMarket(Art)=0 Then ws:=ws+' З';
{
        If Sort>0 Then
        Begin
         P:=Copy(ws,Ord(ws[0])-CArtikul-2-1,CArtikul+2+2);
         Delete(ws,Ord(ws[0])-CArtikul-2-2,CArtikul+2+2+1);
         Insert(P,ws,Ord(Space[0])+1);
        End;
}
         Writeln(txt,Ws);

          If NPrint.FullName=0 Then Ws2:=GetIdField(FName2,Art)
          Else Ws2:=GetIdField(FFName2,Art);
          DelSpaceRight(ws2);

          If ws2[0]<>#0 Then
          Begin
           Format(ws2,CNAme);
           Writeln(txt,Space+'  '+Separator+'    '+Separator+ws2+Separator);
          End;


         If Sertif=1 Then
         Begin
          TempArtikul:=Copy(ws,Ord(Space[0])+1,CArtikul);
          TextSertif:=BakGetField(FSertif,TempArtikul,0);
          DelSpaceRight(TextSertif);
          If TextSertif[0]<>#0 Then
           Begin
            Format(TextSertif,CSertif-1);
            Writeln(Txt,Space+'           Сертификат:'+TextSertif);
           End;
         End;
         If Akzis=1 Then
         Begin
          TempArtikul:=Copy(ws,Ord(Space[0])+1,CArtikul);
          TextSertif:=BakGetField(FAkzis,TempArtikul,0);
          DelSpaceRight(TextSertif);
          If TextSertif[0]<>#0 Then
           Begin
            Format(TextSertif,CSertif-1);
            Writeln(Txt,Space+'           Примечание:'+TextSertif);
           End;
         End;

        End;
        Dispose(Temp,Done);



If Video Then
Begin
   Writeln(txt,'                                                   __________________________________________');
   Writeln(Txt,Space+'                                            Всего:',
   RecognizReal(RazdelR,CIZena+3,CMantissa),'       ',RecognizReal(RazdelZ,CIZena+3,CMantissa));
   Writeln(txt);
End;
        ItogoO:=ItogoO+RazdelO;
        ItogoR:=ItogoR+RazdelR;
        ItogoZ:=ItogoZ+RazdelZ;
      End;
     End;{наличие}
   2:Begin
      R.Assign(0, 0, 0, 0);
      Temp := New(PBox, Init(R, 1, Nil));
      Temp^.NewList(New(PTextCollection, Init(0,1)));
      While Not(Eof(ef)) Do
      Begin
        {
        Repeat
        Until Lock(ef,FilePos(ef)*SizeOf(SkladType),SizeOf(SkladType));
        }
         ReadSkladPointer(ef,E);

        {
        Repeat
        UnLock(ef,(FilePos(ef)-1)*SizeOf(SkladType),SizeOf(SkladType));
        Until (DosError=0);
        }

      E^.Dat.Input.Kol[0]:=#0;
      For i:=1 To CDivision Do
        If (M[i]=1) And ((GetIDMArket(E^.Dat.BazKod)=TipID)Or(TipID=2)) Then

{        If M[i]=1 Then}
       Begin
        {Str((StrToInt(E^.Dat.Baz.Input.Kol)+StrToInt(E^.Dat.Baz.Input.DiviSion[i])):CKol,E^.Dat.Baz.Input.Kol);
       End;}
       DelSpace(E^.Dat.Input.Kol);

      Str(StrToReal(E^.Dat.Input.R_Zena):CZena:CMAntissa,E^.Dat.Input.R_Zena);
      Str(StrToReal(E^.Dat.Input.O_Zena):CZena:CMAntissa,E^.Dat.Input.O_Zena);
      Str(StrToReal(E^.Dat.Input.Zakupka):CZena:CMAntissa,E^.Dat.Input.Zakupka);

       If ((E^.Dat.Employ) And (StrToInt(E^.Dat.Input.DivisionS[i])>0)And(Assort=0))Or
       ((E^.Dat.Employ)And(Assort>0)And(((StrToInt(E^.Dat.Input.DivisionS[i])>0))Or(i<=1)))Then

{      If (GetIdEmploy(E^.Dat.BazKod) And (StrToInt(E^.Dat.Input.Division[i])>0)And(Assort=0))Or
       (GetIdEmploy(E^.Dat.BazKod)And(Assort>0)And(((StrToInt(E^.Dat.Input.Division[i])>0))Or(i<=1)))Then}
       Begin

        If NPrint.FullName=0 Then Ws:=GetIdField(FName,E^.Dat.Bazkod)
        Else Ws:=GetIdField(FFName,E^.Dat.Bazkod);

        Format(ws,CName);
        RFormat(E^.Dat.Input.DiviSionS[i],CKol);
        P:=CalcPackNoFile(GetIdField(FInPack,E^.Dat.Bazkod),E^.Dat.Input.DiviSionS[i]);
        DelSpace(P);
        RFormat(P,CPack);
        Str(i:2,S);
        If StrToInt(E^.Dat.Input.DivisionS[i])=0 Then S:=' '+' ';
        Str(StrToReal(E^.Dat.Input.R_Zena):CZena:CMantissa,Ss);
        If GetIdLocked(E^.Dat.BazKod) Then
        Ws:=Space+E^.Dat.BazKod+Separator+#249+s+' '+Separator+ws+Separator+E^.Dat.Input.DiviSionS[i]+
        Separator+P+Separator+ss+'    ______________________'
        Else
        Ws:=Space+E^.Dat.BazKod+Separator+' '+s+' '+Separator+ws+Separator+E^.Dat.Input.DiviSionS[i]+
        Separator+P+Separator+ss+'    ______________________';
        If Sort>0 Then
        Begin
         Otdel[0]:=#0;
         Otdel:=Copy(ws,Ord(Space[0])+1+CArtikul+2,2);
         P:=Copy(ws,Ord(Space[0])+1,CArtikul+2+2);
         Delete(ws,Ord(Space[0])+1,CArtikul+2+2);
         Insert(Otdel,ws,1+Ord(Space[0])+1+CName+1);
         ws:=ws+Separator+P;
        End;

        Temp^.List^.Insert(NewStr(ws));
        Temp^.SetRange(Temp^.List^.Count);
       End;
      End;
      End;
      Close(Ef);
       If ((Temp^.List^.Count-1)>=0) Then
       For lk:=0 To Temp^.List^.Count-1 Do
        Begin
        ws:=Temp^.GetText(lk,Temp^.List^.Count);
        If Sort>0 Then
        Begin
         Delete(ws,Ord(Space[0])+1+CName+1+1,2);
         P:=Copy(ws,Ord(ws[0])-CArtikul-2-1,CArtikul+2+2);
         Delete(ws,Ord(ws[0])-CArtikul-2-2,CArtikul+2+2+1);
         Insert(P,ws,Ord(Space[0])+1);
        End;

        Art:= Copy(ws,Ord(Space[0])+1,CArtikul);
        If GetIdMarket(Art)=0 Then ws:=ws+' З';

         Writeln(txt,Ws);


          ws1:=Copy(ws,Ord(Space[0])+1,CArtikul);
          If NPrint.FullName=0 Then Ws2:=GetIdField(FName2,Art)
          Else Ws2:=GetIdField(FFName2,Art);
          DelSpaceRight(ws2);

          If ws2[0]<>#0 Then
          Begin
           Format(ws2,CNAme);
           Writeln(txt,Space+'     '+Separator+'    '+Separator+ws2+Separator);
          End;



        End;
       Writeln(txt);
       Dispose(Temp,Done);
     End;{акт ревизии}
   1:Begin
      R.Assign(0, 0, 0, 0);
      Temp := New(PBox, Init(R, 1, Nil));
      Temp^.NewList(New(PTextCollection, Init(0,1)));
      While Not(Eof(ef)) Do
      Begin
        ReadSkladPointer(ef,E);
        GetSkidka(E^.Dat.BazKod,Sk^.Dat);
        E^.Dat.Input.Kol[0]:=#0;

        If KoefWord=0 Then
        Begin
         Str(StrToReal(E^.Dat.Input.O_Zena)/Koef:CZena:CMantissa,E^.Dat.Input.O_Zena);
         Str(StrToReal(E^.Dat.Input.R_Zena)/Koef:CZena:CMantissa,E^.Dat.Input.R_Zena);
         DelSpace(E^.Dat.Input.R_Zena);
         DelSpace(E^.Dat.Input.O_Zena);
        End
        Else
        Begin
         Str(StrToReal(E^.Dat.Input.O_Zena)+Koef*StrToReal(E^.Dat.Input.O_Zena)/100:CZena:CMantissa,E^.Dat.Input.O_Zena);
         Str(StrToReal(E^.Dat.Input.R_Zena)+Koef*StrToReal(E^.Dat.Input.R_Zena)/100:CZena:CMantissa,E^.Dat.Input.R_Zena);
         DelSpace(E^.Dat.Input.R_Zena);
         DelSpace(E^.Dat.Input.O_Zena);
        End;

        For i:=1 To CDivision Do
        If (M[i]=1) And ((GetIDMArket(E^.Dat.BazKod)=TipID)Or(TipID=2)) Then
{
        If (StrToInt(GetIdField(FMinimum,E^.DAt.BazKod))<=StrToInt(E^.Dat.Input.Division[i]))
	      Or (Assort>0) Then
}
        Begin
        DelSpace(E^.Dat.Input.Kol);

      Str(StrToReal(E^.Dat.Input.R_Zena):CZena-1:CMAntissa,E^.Dat.Input.R_Zena);
      Str(StrToReal(E^.Dat.Input.O_Zena):CZena-1:CMAntissa,E^.Dat.Input.O_Zena);
      Str(StrToReal(E^.Dat.Input.Zakupka):CZena:CMAntissa,E^.Dat.Input.Zakupka);


      If ((E^.Dat.Employ) And (StrToInt(E^.Dat.Input.DivisionS[i])>0)And(Assort=0))Or
       ((E^.Dat.Employ)And(Assort>0)And(((StrToInt(E^.Dat.Input.DivisionS[i])>0))Or(i<=1)))Then

       Begin

        If NPrint.FullName=0 Then Ws:=GetIdField(FName,E^.Dat.Bazkod)
        Else Ws:=GetIdField(FFName,E^.Dat.Bazkod);


        Format(ws,CName-2);
        {учет скидки наценки}




         Str(StrToReal(E^.Dat.Input.O_Zena):CZena-1:CMantissa,E^.Dat.Input.O_Zena);
         Str(StrToReal(E^.Dat.Input.R_Zena):CZena-1:CMantissa,E^.Dat.Input.R_Zena);
         DelSpace(E^.Dat.Input.R_Zena);
         DelSpace(E^.Dat.Input.O_Zena);


        If Valuta=0 Then
        Begin
        RFormat(E^.Dat.Input.O_Zena,CZena-1);
        RFormat(E^.Dat.Input.R_Zena,CZena-1);
        End
        Else
         Begin
          Str(StrToReal(E^.Dat.Input.O_Zena)/Usd:CZena-1:CMantissa,E^.Dat.Input.O_Zena);
          Str(StrToReal(E^.Dat.Input.R_Zena)/Usd:CZena-1:CMantissa,E^.Dat.Input.R_Zena);
          RFormat(E^.Dat.Input.O_Zena,CZena-1);
          RFormat(E^.Dat.Input.R_Zena,CZena-1);
         End;

        Str(StrToREal(E^.Dat.Input.O_Zena)*(1+StrToReal(GetIdField(FNAlog,E^.Dat.BazKod))/100):CZena-1:CMantissa,WithNP);

        Pack:=GetIdField(FInPack,E^.Dat.Bazkod);
        DelSpace(Pack);
        RFormat(Pack,CInPack);
        Str((StrToInt(Pack)*StrToReal(WithNP{E^.Dat.Input.O_Zena})):CInputIZena:CMantissa,StOz);
        DelSpace(stOz);
        RFormat(stOz,CInputIZena);
        Stzz:=BakGetField(FPost,E^.DAt.BAzKod,0);
        If Ord(Stzz[0])>(CPost-2) Then Stzz[0]:=Chr(CPost-2);
        Format(stzz,CPost-2);
        Str(i:2,s);
        If StrToInt(E^.Dat.Input.DivisionS[i])=0 Then S:=' '+' ';

        If GetIdLocked(E^.Dat.BazKod) Then
        Ws:=Space+E^.Dat.BazKod+Separator+#249+s+' '+Separator+ws+Separator+{Stzz+
        Separator}+Pack+Separator+E^.Dat.Input.O_Zena
        Else
        Ws:=Space+E^.Dat.BazKod+Separator+' '+s+' '+Separator+ws+Separator+{Stzz+
        Separator}+Pack+Separator+E^.Dat.Input.O_Zena;



        If Region<>4 Then
       Begin
        For sh:=1 To CShkala Do
         Begin
          If ZPrize[sh]=1 Then
           Begin
            Str(StrToReal(E^.Dat.Input.O_Zena)*
            (StrToReal(Sk^.Dat.Skidka[sh].Proz)):CZena-1:CMAntissa,strz);
            ws:=ws+Separator+Strz;
           End;
         End;
       End
       Else
        Begin
         For sh:=1 To 6 Do
          Begin
           If VVV[sh]=1 Then
            Begin
             Str(StrToReal(E^.Dat.Input.Zakupka)*
             (1+StrToReal(VVVS[sh])/100):CZena-1:CMAntissa,strz);
             ws:=ws+Separator+Strz;
            End;
          End;
        End;
{ WithNP+Separator+stoz{+Separator+Separator+P};
        If Sort>0 Then
        Begin
         Otdel[0]:=#0;
         Otdel:=Copy(ws,Ord(Space[0])+1+CArtikul+2,2);
         P:=Copy(ws,Ord(Space[0])+1,CArtikul+2+2);
         Delete(ws,Ord(Space[0])+1,CArtikul+2+2);
         Insert(Otdel,ws,1+Ord(Space[0])+1+CName+1);
         ws:=ws+Separator+P;
        End;

        Temp^.List^.Insert(NewStr(ws));
        Temp^.SetRange(Temp^.List^.Count);
       End;
       End;
      End;
      Close(Ef);
       If ((Temp^.List^.Count-1)>=0) Then
       For lk:=0 To Temp^.List^.Count-1 Do
        Begin
        ws:=Temp^.GetText(lk,Temp^.List^.Count);
        If Sort>0 Then
        Begin
         Delete(ws,Ord(Space[0])+1+CName+1+1,2);
         P:=Copy(ws,Ord(ws[0])-CArtikul-2-1,CArtikul+2+2);
         Delete(ws,Ord(ws[0])-CArtikul-2-2,CArtikul+2+2+1);
         Insert(P,ws,Ord(Space[0])+1);
        End;
        Art:= Copy(ws,Ord(Space[0])+1,CArtikul);
        If GetIdMarket(Art)=0 Then ws:=ws+' З';

        {MMM:=GetIdField(FMArker,Art);}
        MMM:=GetIdField(FMinimum,Art);
        If StrToInt(BakGetField(FKol,Art,0))<StrToInt(MMM) Then MMM:='@'
        Else MMM[0]:=#0;
        Format(MMM,CInPack);


        If Ansi=1 Then
        Begin
         System.Insert(MMM+Separator,ws,Ord(Space[0])+1+CArtikul+1+4+1);
         Writeln(txt,Ws);


          ws1:=Copy(ws,Ord(Space[0])+1,CArtikul);
          If NPrint.FullName=0 Then Ws2:=GetIdField(FName2,Art)
          Else Ws2:=GetIdField(FFName2,Art);
          DelSpaceRight(ws2);

          If ws2[0]<>#0 Then
          Begin
           Format(ws2,CNAme-2);
           Writeln(txt,Space+'     '+Separator+'    '+Separator+'    '+ws2+Separator);
          End;
        End
          else
           begin
            ws1:=Copy(ws,Ord(Space[0])+1,CArtikul);
            System.Delete(ws,Ord(Space[0])+1+CArtikul+1+4{+1},CNAme);
            If NPrint.FullName=0 Then Ws2:=GetIdField(FFFName,Art)
            Else Ws2:=GetIdField(FFFName,Art);
            DelSpaceRight(ws2);
            ws2:=ws2+'$';
            System.Insert(ws2,ws,Ord(Space[0])+1+CArtikul+1+4{+1});
            System.Insert(MMM+Separator,ws,Ord(Space[0])+1+CArtikul+1+4{+1});
            Writeln(txt,Ws);
           end;

        End;
        Dispose(Temp,Done);
      Writeln(txt);
     End;{прайс}
   Else;
   End;{Case}
      Dispose(E,Done);
  End;
 End;

Case K Of
0:Begin
  If VidNal=0 Then
  Begin
   Writeln(txt,'                                                   ________________________');
   Writeln(Txt,Space+'                                             Всего: '+
   {,RecognizReal(ItogoO,CIZena+3,CMantissa),}'     ',RecognizReal(ItogoR,CIZena+3,CMantissa));
  End;
  If VidNal=1 Then
  Begin
   Writeln(txt,'                                                   __________________________________________');
   Writeln(Txt,Space+'                                            Всего:',
   RecognizReal(ItogoR,CIZena+3,CMantissa),'       ',RecognizReal(ItogoZ,CIZena+3,CMantissa));
  End;
  End;
1:Begin
  Dispose(sk,Done);
  End;
2:Begin
   Writeln(txt);
   Writeln(txt,Space+'                         Сдал Ф.И.О./_________________/  Подпись ___________');
   Writeln(txt);
   Writeln(txt,Space+'                         Сдал Ф.И.О./_________________/  Подпись ___________');
   Writeln(txt);
   Writeln(txt);
   Writeln(txt);
   Writeln(txt,Space+'                         Приняла комиссия в составе:');
   Writeln(txt);
   Writeln(Txt,Space+'                                 1. __________________   Подпись ___________');
   Writeln(txt);
   Writeln(Txt,Space+'                                 2. __________________   Подпись ___________');
   Writeln(txt);
   Writeln(Txt,Space+'                                 3. __________________   Подпись ___________');
   Writeln(txt);
   Writeln(Txt,Space+'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
   Writeln(txt,Space+'========================================================================================');
  End;
Else;
End;
 If (k=0) Then
    Begin
    If VidNal=1 Then
    Begin
     Writeln(Txt,Space+'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
     Writeln(txt,Space+'=============================================================================================')
    End
    Else
     Begin
      Writeln(Txt,Space+'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
      Writeln(txt,Space+'=====================================================================================');
     End;
    End
 Else
 If k<>2 Then
    Begin
     s[0]:=#0;
     For sh:=1 To MaxSh Do
     Begin
     s[sh]:='=';
     s[0]:=Chr(sh);
     End;
   Writeln(Txt,Space+'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
   Writeln(txt,Space+s{'=============================================================================================='});
    End;
 Close(txt);
 Dispose(TempList,Done);
 Str(ItogoR:CIZena:CMantissa,ws);
 PrintSklad_Or_Prise:=ws;
 If Video Then
 Begin
 NoInfo;
 ViewAsText(Path.ToTemp+'report.txt',True);
{ If Not(TestOpenDate(FDate)) Then}
 Report(Path.ToTemp+'report.txt','',1,False,False);
 End;
End;

