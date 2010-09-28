Unit PrnVeks;

INTERFACE

Uses Glob,ServStr;

Procedure PrintAkt1(Veks: VekselType; Cl:ArtikulStr); {интраст-клиент}
Procedure PrintAkt2(Veks: VekselType; Cl:ArtikulStr); {клиент-триада}
Procedure PrintAkt3(Veks: VekselType; Cl:ArtikulStr); {интраст-триада}
procedure DogVeks1(Veks: VekselType; Cl:ArtikulStr);  {интраст-клиент}
procedure DogVeks2(Veks: VekselType; Cl:ArtikulStr);  {клиент-триада}
procedure SogVeks(Veks: VekselType; Cl:ArtikulStr; DocN:AllStr; DocDat: TDateString);   {}
Procedure PrintOrderVeksel(Veks:VekselType;cl:ArtikulStr;Sdoc:ArtikulStr;SDate:TDAteString);
Procedure PrintVeksel (Veks : VekselType;Cl:ArtikulStr);
procedure SogVeksNew(Veks: VekselType; Cl:ArtikulStr; DocN:AllStr; DocDat: TDateString); {NEW!}
Procedure PrintAktNew(Veks: VekselType; Cl:ArtikulStr);  {NEW!}
Procedure DogVeksNew(Veks: VekselType; Cl:ArtikulStr);   {NEW!}
Procedure PrnComplect(Veks: VekselType; Cl:ArtikulStr; DocN:AllStr; DocDat: TDateString);


IMPLEMENTATION

Uses App,Objects,Views,Vision4,Vision1,Serv,
     MsgBox,dbengine,tools,tpdate,Printers,ServStr2,
     Access1,Validate,NetDBEng,Propiss,Vision6;

{const PathDebug = 'c:\veksel\happy\';}

Procedure PrintAkt1(Veks: VekselType; Cl:ArtikulStr);
const space=' ';
Var Shablon,f: text;
    {Veks : VekselType;}
    nv,nd,TempS,ws,s,test,skol,scl,scll,st,z: string;
    i,j,kol,IORez:word;
    sum:real;
    D,Mm,Y : INteger;
Begin
{Veks:=Veks1;}
If MessageBox(^M+#3'Печатать акты приема-передачи от "Интраста" к клиенту ?',Nil,mfConfirmation+mfOkCancel)<>cmOk Then Exit;

z:=rek^.Dat.kod;
delzerro(z);

s:=GetClientField(FVekselIP,Cl,0);
Test:=s;
DelSpace(Test);
If Test[0]=#0 Then
 Begin
  MessageBox(^M+#3+'Не указано полное имя клиента в именительном падеже!',Nil,mfError+mfCancelButton);
  exit;
 End;
Format(s,CAll-16);
DelSpaceRight(s);
ws:=GetClientField(FSvid,Cl,0);
Format(ws,CAll);
DelSpaceRight(ws);
scl:=GetClientField(FClient,cl,0);
i:=0;

for j:=0 to Maxveksel-1 do
{если есть вексель}
Begin
DelSpace(Veks.Exampl[j+1].numer);
if Veks.Exampl[j+1].numer<>'' then
begin

  if StrToInt(GetClientField(FLizo,Cl,0))=1 then Assign(Shablon,{PathDebug}Path^.Dat.ToText+'akt1.txt');
  if StrToInt(GetClientField(FLizo,Cl,0))=0 then Assign(Shablon,{PathDebug}Path^.Dat.ToText+'akt11.txt');
  IOrez:=ioresult;
  reset(shablon);
  IOrez:=ioresult;
  if iorez<>0 then
    begin
        MessageBox(#3^M+#3'Ошибка открытия файла '+Path^.Dat.ToText+'akt1.txt',Nil,mfError+mfCancelButton);
        Exit;
    end;

  Assign(f,Path^.Dat.ToTemp+'akt1.txt');
  IOrez:=ioresult;
  rewrite(f);
  IOrez:=ioresult;
  if iorez<>0 then
    begin
        MessageBox(#3^M+#3'Ошибка создания файла '+Path^.Dat.ToTemp+'akt1.txt',Nil,mfError+mfCancelButton);
        Exit;
    end;

  nd:=Veks.Exampl[j+1].DogovorNumer+'/'+z;
  format(nd,7);
  nv:=Veks.Exampl[j+1].Numer+'/'+z;
  format(nv,7);


  While Not(Eof(Shablon)) Do
  Begin
  Inc(i);
  TempS:='';
  Readln(Shablon,TempS);
  If Pos('  г. Тула',TempS)>0 Then
   TempS:=TempS+'                                                             '+Veks.Exampl[j+1].Data+' г.';
  If Pos('исполнении  договора  о  продаже  векселей  N',TempS)>0 Then  TempS:=TempS+' '+
       nd+
      '    от  '+Veks.Exampl[j+1].Data+' г.     передал,    а';
  If Pos(' в лице',TempS)>0 Then
     if StrToInt(GetClientField(FLizo,Cl,0))=0
     then TempS:=Format(scl,CClient)+Temps+' '{+'Генерального директора '}+format(s,CAll)
     else TempS:=Format(scl,CClient)+Temps+' '
            +format(s,CAll)+', действующее  на';
  If Pos('основании свидетельства',TempS)>0 Then  TempS:=TempS+'    '+format(ws,CAll)+' принял   вексели,';
  if Pos('  За ОАО "Ивестиционно - трастовая компания',TempS)>0 then Temps:=TempS+' '+scl;
  If POs('▒',TempS)>0 then
       begin
        kol:=0;
        st:='';
        TempS:='';
        inc(kol);
        MyStr(StrToReal(Veks.Exampl[j+1].Summa),CIZena,CMAntissa,Veks.Exampl[j+1].Summa);
        TempS:='               '+format(Veks.Exampl[j+1].Seria,CLitr)+' '+nv+
                '      1  ' +' '+format(Veks.Exampl[j+1].summa,CIZena)+'    '+Veks.Exampl[j+1].Data+' по предъявлении'
                         {+Veks.Exampl[j+1].Data};
        MySTr(StrToReal(st)+StrToReal(Veks.Exampl[j+1].Summa),CIZena,CMantissa,st);
       end;
     skol:= IntToStr(kol,CKod);
     format(skol,CKod);
  if pos('     Всего',Temps)>0 then Temps:=TempS+' '+skol+' шт. на общую сумму '
          +st+' рублей.';
  Writeln(f,Space+TempS);
End;{While}

writeln(f);
{Writeln(f,Space,'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');}

writeln(f,space+'=========================================================================================');

IOrez:=ioresult;
Close(f);
IOrez:=ioresult;

IOrez:=ioresult;
Close(shablon);
IOrez:=ioresult;

If MessageBox(^M+#3'Печатать акт приема-передачи векселей N '+Veks.Exampl[j+1].Numer+'/'+z+' '+
' от интраста клиенту?',Nil,
        mfConfirmation+mfOkCancel)=cmOk Then
Report(Path^.Dat.ToTemp+'akt1.txt','',2,False,False);

end
else break;
End;{For}
{ViewAsText(Path^.Dat.ToTemp+'akt1.txt',true);}

End;


Procedure PrintAkt2(Veks: VekselType; Cl:ArtikulStr);
const space=' ';
Var Shablon,f: text;
    nd,nv,z,TempS,ws,s,test,skol,scl,scll,st: string;
    i,j,kol,IORez:word;
    sum:real;
    D,Mm,Y : INteger;
Begin
If MessageBox(^M+#3'Печатать акты приема-передачи от клиента к нам ?',Nil,mfConfirmation+mfOkCancel)<>cmOk Then Exit;

z:=rek^.Dat.kod;
delzerro(z);

s:=GetClientField(FVekselIP,Cl,0);
Test:=s;
DelSpace(Test);
If Test[0]=#0 Then
 Begin
  MessageBox(^M+#3+'Не указано полное имя клиента в именительном падеже!',Nil,mfError+mfCancelButton);
  exit;
 End;
Format(s,CAll-16);
DelSpaceRight(s);
Format(s,CAll);
ws:=GetClientField(FSvid,Cl,0);
Format(ws,CAll);
DelSpaceRight(ws);
scl:=GetClientField(FClient,cl,0);
  i:=0;

for j:=0 to Maxveksel-1 do
begin
{если есть вексель}
DelSpace(Veks.Exampl[j+1].numer);
if Veks.Exampl[j+1].Numer='' then break;

  if StrToInt(GetClientField(FLizo,Cl,0))=1 then Assign(Shablon,{PathDebug}Path^.Dat.ToText+'akt2.txt');
  if StrToInt(GetClientField(FLizo,Cl,0))=0 then Assign(Shablon,{PathDebug}Path^.Dat.ToText+'akt22.txt');
  IOrez:=ioresult;
  reset(shablon);
  IOrez:=ioresult;
  if iorez<>0 then
    begin
        MessageBox(#3^M+#3'Ошибка открытия файла '+Path^.Dat.ToText+'akt1.txt',Nil,mfError+mfCancelButton);
        Exit;
    end;

  Assign(f,Path^.Dat.ToTemp+'akt1.txt');
  IOrez:=ioresult;
  rewrite(f);
  IOrez:=ioresult;
  if iorez<>0 then
    begin
        MessageBox(#3^M+#3'Ошибка создания файла '+Path^.Dat.ToTemp+'akt1.txt',Nil,mfError+mfCancelButton);
        Exit;
    end;
  Inc(i);

  nd:=Veks.Exampl[j+1].DogovorNumer+'/'+z;
  format(nd,7);
  nv:=Veks.Exampl[j+1].Numer+'/'+z;
  format(nv,7);


  While Not(Eof(Shablon)) Do
  Begin

  TempS:='';
  Readln(Shablon,TempS);
If Pos('  г. Тула',TempS)>0 Then
   TempS:=TempS+'                                                             '+Veks.Exampl[j+1].Data+' г.';
  If Pos('Настоящий акт составлен в том,',TempS)>0 Then
             begin
               if StrToInt(GetClientField(FLizo,Cl,0))=0 then TempS:=TempS+' '
                   +Format(scl,CClient)+' в лице Генерального директора'
                else TempS:=TempS+' '+Format(scl,CClient)+'              в      лице '
             end;
  If Pos(',  действующее  на  основании',TempS)>0 Then
      if StrToInt(GetClientField(FLizo,Cl,0))=1 then TempS:=Format(s,CAll)+Temps
      else TempS:=s+Temps;
  If Pos('во исполнении договора о продаже векселей N',TempS)>0 Then
       if StrToInt(GetClientField(FLizo,Cl,0))=1 then TempS:=format(ws,CAll)+TempS
       else  Temps:=TempS+'  '+nd+' от '+Veks.Exampl[j+1].Data+'  г.     передал,';
  if Pos('г.  передал,',TempS)>0 then
    if StrToInt(GetClientField(FLizo,Cl,0))=1 then Temps:=nd+' от '+Veks.Exampl[j+1].Data+
    TempS;
{!!!}  if POs('▓',TempS)>0 then
{!!!}            begin
{!!!}                System.Delete(TempS,1,1);
{!!!}                Format(scl,CClient);
{!!!}                TempS:=' За '+scl+Temps;
{!!!}            end;
  If POs('▒',TempS)>0 then
       begin
        kol:=0;
        st:='';
        TempS:='';
        inc(kol);
        MyStr(StrToReal(Veks.Exampl[j+1].Summa),CIZena,CMAntissa,Veks.Exampl[j+1].Summa);
        TempS:='               '+format(Veks.Exampl[j+1].Seria,CLitr)+' '+nv+
                '      1  ' +' '+format(Veks.Exampl[j+1].summa,CIZena)+'    '+Veks.Exampl[j+1].Data+
                         {' '+Veks.Exampl[j+1].Data;}' по предъявлении'{+Veks.Exampl[j+1].Data};
        MySTr(StrToReal(st)+StrToReal(Veks.Exampl[j+1].Summa),CIZena,CMantissa,st);
       end;
     skol:= IntToStr(kol,CKod);
     format(skol,CKod);
  if pos('     Всего',Temps)>0 then Temps:=TempS+' '+skol+' шт. на общую сумму '
          +st+' рублей.';
  Writeln(f,Space+TempS);

  End;{While}

writeln(f);
{Writeln(f,Space,'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');}

writeln(f,space+'==========================================================================================');


 IOrez:=ioresult;
 Close(f);
 IOrez:=ioresult;
 Close(shablon);
 IOrez:=ioresult;




If MessageBox(^M+#3'Печатать акт приема-передачи векселей N '+Veks.Exampl[j+1].Numer+'/'+z+' '+
' от клиента к нам?',Nil,
        mfConfirmation+mfOkCancel)=cmOk Then
Report(Path^.Dat.ToTemp+'akt1.txt','',2,False,False);

end
{else break};

 {ViewAsText(Path^.Dat.ToTemp+'akt1.txt',true);}
End;


Procedure PrintAkt3(Veks: VekselType; Cl:ArtikulStr);
const space=' ';
Var Shablon,f: text;
    nd,nv,z,TempS,ws,s,test,skol,scl,scll,st: string;
    i,j,kol,IORez:word;
    sum:real;
    D,Mm,Y : INteger;
Begin
If MessageBox(^M+#3'Печатать акты приема-передачи от нас к "Интрасту" ?',Nil,mfConfirmation+mfOkCancel)<>cmOk Then Exit;

z:=rek^.Dat.kod;
     delzerro(z);

  s:=GetClientField(FVekselIP,Cl,0);
Test:=s;
DelSpace(Test);
If Test[0]=#0 Then
 Begin
  MessageBox(^M+#3+'Не указано полное имя клиента в именительном падеже!',Nil,mfError+mfCancelButton);
  exit;
 End;
Format(s,CAll-16);
DelSpaceRight(s);
format(s,CAll);
ws:=GetClientField(FSvid,Cl,0);
Format(ws,CAll);
DelSpaceRight(ws);
scl:=GetClientField(FClient,cl,0);
  i:=0;

for j:=0 to Maxveksel-1 do
{если есть вексель}
Begin
DelSpace(Veks.Exampl[j+1].numer);
if Veks.Exampl[j+1].Numer<>'' then
Begin

  Assign(Shablon,Path^.Dat.ToText+'akt3.txt');
  IOrez:=ioresult;
  reset(shablon);
  IOrez:=ioresult;
  if iorez<>0 then
    begin
        MessageBox(#3^M+#3'Ошибка открытия файла '+Path^.Dat.ToText+'akt1.txt',Nil,mfError+mfCancelButton);
        Exit;
    end;

  Assign(f,Path^.Dat.ToTemp+'akt1.txt');
  IOrez:=ioresult;
  rewrite(f);
  IOrez:=ioresult;
  if iorez<>0 then
    begin
        MessageBox(#3^M+#3'Ошибка создания файла '+Path^.Dat.ToTemp+'akt1.txt',Nil,mfError+mfCancelButton);
        Exit;
    end;

  nd:=Veks.Exampl[j+1].DogovorNumer+'/'+z;
  format(nd,7);
  nv:=Veks.Exampl[j+1].Numer+'/'+z;
  format(nv,7);


  While Not(Eof(Shablon)) Do
  Begin
  Inc(i);
  TempS:='';
  Readln(Shablon,TempS);
If Pos('  г. Тула',TempS)>0 Then
   TempS:=TempS+'                                                             '+Veks.Exampl[j+1].Data+' г.';
  If Pos('продаже векселей N',TempS)>0 Then  TempS:=TempS+' '+nd+' от  '+
  Veks.Exampl[j+1].Data+
         ' г.  передал, а ОАО "Инвестиционно - трастовая компа-';
  if pos('▒',TempS)>0 then
       begin
        kol:=0;
        st:='';
        inc(kol);
        MyStr(StrToReal(Veks.Exampl[j+1].Summa),CIZena,CMAntissa,Veks.Exampl[j+1].Summa);
        TempS:='               '+format(Veks.Exampl[j+1].Seria,CLitr)+' '+nv+
                '      1  ' +' '+format(Veks.Exampl[j+1].summa,CIZena)+'    '+Veks.Exampl[j+1].Data+
                         {' '+Veks.Exampl[j+1].Data;}
                         ' по предъявлении'{+Veks.Exampl[j+1].Data};
        {Writeln(f,Space+TempS);}
        MySTr(StrToReal(st)+StrToReal(Veks.Exampl[j+1].Summa),CIZena,CMantissa,st);
       end;
     skol:= IntToStr(kol,CKod);
     format(skol,CKod);
  if pos('     Всего',Temps)>0 then Temps:=TempS+' '+skol+' шт. на общую сумму '
          +st+' рублей.';
  Writeln(f,Space+TempS);
End;{While}

writeln(f);
{Writeln(f,Space,'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');}

writeln(f,space+'==========================================================================================');


IOrez:=ioresult;
Close(f);
IOrez:=ioresult;
Close(shablon);
IOrez:=ioresult;

If MessageBox(^M+#3'Печатать акт приема-передачи векселей N '+Veks.Exampl[j+1].Numer+'/'+z+' '+
' от интраста к нам?',Nil,
        mfConfirmation+mfOkCancel)=cmOk Then
Report(Path^.Dat.ToTemp+'akt1.txt','',2,False,False);

{ViewAsText(Path^.Dat.ToTemp+'akt1.txt',true);
readln;}

end
else break;
End;{For}
End;

procedure DogVeks1(Veks: VekselType; Cl:ArtikulStr);
const space=' ';
Var Shablon,f: text;
    nd,nv,z,TempS,ws,s,test,skol,scl,scll,st: string;
    i,j,kol,IORez:word;
Begin
If MessageBox(^M+#3'Печатать договора о продаже вескелей с "Интрастом" ?',Nil,mfConfirmation+mfOkCancel)<>cmOk Then Exit;

z:=rek^.Dat.kod;
     delzerro(z);

s:=GetClientField(FVekselIP,Cl,0);
Test:=s;
DelSpace(Test);
If Test[0]=#0 Then
 Begin
  MessageBox(^M+#3+'Не указано полное имя клиента в именительном падеже!',Nil,mfError+mfCancelButton);
  exit;
 End;
Format(s,CAll-16);
DelSpaceRight(s);
Format(s,CAll);
ws:=GetClientField(FSvid,Cl,0);
Format(ws,CAll);
DelSpaceRight(ws);
scl:=GetClientField(FClient,cl,0);
  i:=0;

for j:=0 to Maxveksel-1 do
begin
{если есть вексель}
DelSpace(Veks.Exampl[j+1].numer);
if Veks.Exampl[j+1].Numer='' then break;

  if StrToInt(GetClientField(FLizo,Cl,0))=1 then Assign(Shablon,{PathDebug}Path^.Dat.ToText+'dogveks1.txt');
  if StrToInt(GetClientField(FLizo,Cl,0))=0 then Assign(Shablon,{PathDebug}Path^.Dat.ToText+'dogvek11.txt');
  IOrez:=ioresult;
  reset(shablon);
  IOrez:=ioresult;
  if iorez<>0 then
    begin
        MessageBox(#3^M+#3'Ошибка открытия файла '+Path^.Dat.ToText+'dogveks1.txt',Nil,mfError+mfCancelButton);
        Exit;
    end;

  Assign(f,Path^.Dat.ToTemp+'dogveks1.txt');
  IOrez:=ioresult;
  rewrite(f);
  IOrez:=ioresult;
  if iorez<>0 then
    begin
        MessageBox(#3^M+#3'Ошибка создания файла '+Path^.Dat.ToTemp+'dogveks1.txt',Nil,mfError+mfCancelButton);
        Exit;
    end;

  nd:=Veks.Exampl[j+1].DogovorNumer+'/'+z;
  format(nd,7);
  nv:=Veks.Exampl[j+1].Numer+'/'+z;
  format(nv,7);


  While Not(Eof(Shablon)) Do
  Begin
   TempS:='';
   Readln(Shablon,TempS);
   If Pos('г. Тула',TempS)>0 Then
   TempS:=TempS+'                                                             '+Veks.Exampl[j+1].Data+' г.';
   if Pos('нии Устава  с  одной  стороны',TempS)>0 then TempS:=TempS+' '+Format(scl,CClient)+
   ' именуемое  "Покупатель",  в  лице';
   if pos('действующего(ей)',TempS)>0 then
       if StrToInt(GetClientField(FLizo,Cl,0))=0 then TempS:='Генерального директора '+format(s,CAll)+TempS
        else TempS:=format(s,CAll)+TempS;
   if pos('с другой стороны,',TempS)>0 then
      if StrToInt(GetClientField(FLizo,Cl,0))=1 then TempS:=format(ws,CAll)+TempS;
   if pos('▒',Temps)>0 then
        begin
          temps:='';
          writeln(f,space+'  '+GetClientField(FClient,Cl,0));
          writeln(f,space+'  '+GetClientField(FAdress,Cl,0));
          writeln(f,space+'  р/с '+GetClientField(FRsh,Cl,0)+' в '+GetClientField(FGde,Cl,0));
          writeln(f,space+'  ИНН '+GetClientField(FINN,Cl,0));
        end;

   Writeln(f,Space+TempS);

  End;

writeln(f);
{Writeln(f,Space,'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');}

writeln(f,space+'==========================================================================================');


IOrez:=ioresult;
Close(f);
IOrez:=ioresult;
Close(shablon);
IOrez:=ioresult;

If MessageBox(^M+#3'Печатать договор о продаже веселей с "ИНТРАСТ" N '+Veks.Exampl[j+1].DogovorNumer+'/'+z+' ?',Nil,
        mfConfirmation+mfOkCancel)=cmOk Then
Report(Path^.Dat.ToTemp+'dogveks1.txt','',2,False,False);

{ViewAsText(Path^.Dat.ToTemp+'dogveks1.txt',true);}

End;{for}

End;

procedure DogVeks2(Veks: VekselType; Cl:ArtikulStr);
const space=' ';
Var Shablon,f: text;
    z,TempS,ws,s,test,skol,scl,scll,st: string;
    i,j,kol,IORez:word;
Begin
If MessageBox(^M+#3'Печатать договора о продаже вескелей с "Триада" ?',Nil,mfConfirmation+mfOkCancel)<>cmOk Then Exit;

   z:=rek^.Dat.kod;
     delzerro(z);

 s:=GetClientField(FVekselIP,Cl,0);
Test:=s;
DelSpace(Test);
If Test[0]=#0 Then
 Begin
  MessageBox(^M+#3+'Не указано полное имя клиента в именительном падеже!',Nil,mfError+mfCancelButton);
  exit;
 End;
Format(s,CAll-16);
DelSpaceRight(s);
Format(s,CAll);
ws:=GetClientField(FSvid,Cl,0);
Format(ws,CAll);
DelSpaceRight(ws);
scl:=GetClientField(FClient,cl,0);
  i:=0;

for j:=0 to Maxveksel-1 do
begin
{если есть вексель}
DelSpace(Veks.Exampl[j+1].numer);
if Veks.Exampl[j+1].Numer='' then break;
  if StrToInt(GetClientField(FLizo,Cl,0))=1 then Assign(Shablon,{PathDebug}Path^.Dat.ToText+'dogveks2.txt');
  if StrToInt(GetClientField(FLizo,Cl,0))=0 then Assign(Shablon,{PathDebug}Path^.Dat.ToText+'dogvek22.txt');
  IOrez:=ioresult;
  reset(shablon);
  IOrez:=ioresult;
  if iorez<>0 then
    begin
        MessageBox(#3^M+#3'Ошибка открытия файла '+Path^.Dat.ToText+'dogveks1.txt',Nil,mfError+mfCancelButton);
        Exit;
    end;

  Assign(f,Path^.Dat.ToTemp+'dogveks1.txt');
  IOrez:=ioresult;
  rewrite(f);
  IOrez:=ioresult;
  if iorez<>0 then
    begin
        MessageBox(#3^M+#3'Ошибка создания файла '+Path^.Dat.ToTemp+'dogveks1.txt',Nil,mfError+mfCancelButton);
        Exit;
    end;


  While Not(Eof(Shablon)) Do
  Begin
   TempS:='';
   Readln(Shablon,TempS);
   If Pos('г. Тула',TempS)>0 Then
   TempS:=TempS+'                                                             '+Veks.Exampl[j+1].Data+' г.';
   if Pos(', именуемое      в      дальнейшем',TempS)>0 then TempS:=Format(scl,CClient)+TempS;
   if pos(', действующего',TempS)>0 then
      if StrToInt(GetClientField(FLizo,Cl,0))=1 then TempS:=format(s,CAll)+TempS
       else TempS:='Генерального директора '+format(s,CAll)+TempS;
   if pos(' с одной стороны,',TempS)>0 then
      if StrToInt(GetClientField(FLizo,Cl,0))=1 then TempS:=format(ws,CAll)+TempS;
   if pos('▒',Temps)>0 then
        begin
          temps:='';
          writeln(f,space+'     '+GetClientField(FClient,Cl,0));
          writeln(f,space+'     '+GetClientField(FAdress,Cl,0));
          writeln(f,space+'     р/с '+GetClientField(FRsh,Cl,0)+' в '+GetClientField(FGde,Cl,0));
          writeln(f,space+'     ИНН '+GetClientField(FINN,Cl,0));
        end;

   Writeln(f,Space+TempS);

  End;

writeln(f);
{Writeln(f,Space,'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');}

writeln(f,space+'==========================================================================================');


IOrez:=ioresult;
Close(f);
IOrez:=ioresult;
Close(shablon);
IOrez:=ioresult;

If MessageBox(^M+#3'Печатать договор о продаже веселей с "ТРИАДА" N '+Veks.Exampl[j+1].DogovorNumer+'/'+z+' ?',Nil,
        mfConfirmation+mfOkCancel)=cmOk Then
Report(Path^.Dat.ToTemp+'dogveks1.txt','',2,False,False);
{ViewAsText(Path^.Dat.ToTemp+'dogveks1.txt',true);}
End;{for}

End;

procedure SogVeks(Veks: VekselType; Cl:ArtikulStr; DocN:AllStr; DocDat: TDateString);
const space=' ';
Var Shablon,f: text;
    TempS,ws,s,test,skol,scl,scll,st: string;
    i,j,kol,IORez:word;
    z:string;
    E : PSuperMarketType;
    Ass : DocumentEditZ;
Begin
If MessageBox(^M+#3'Печатать соглашения о прекращении обязательств ?',Nil,mfConfirmation+mfOkCancel)<>cmOk Then Exit;

     z:=rek^.Dat.kod;
     delzerro(z);

     s:=GetClientField(FVekselIP,Cl,0);
Test:=s;
DelSpace(Test);
If Test[0]=#0 Then
 Begin
  MessageBox(^M+#3+'Не указано полное имя клиента в именительном падеже!',Nil,mfError+mfCancelButton);
  exit;
 End;

Format(s,CAll-16);
DelSpaceRight(s);
Format(s,CAll);
ws:=GetClientField(FSvid,Cl,0);
Format(ws,CAll);
DelSpaceRight(ws);
scl:=GetClientField(FClient,cl,0);
  i:=0;


New(e,Init);
Ass.EditPosition:=DocN;
Ass.D:=DocDat;

If Not GetMarket1(Ass,E) Then
Begin
Dispose(E,Done);
MessageBox(^M+#3+'Не найдена первичная накладная!',Nil,mfError+mfCancelButton);
Exit;
End;



{вариант для доставки-вино}
If ZakazShema=0 Then
Begin
 If E^.Dat.Oformlenie=1 Then
  Begin
   DocN:=E^.Dat.FromZakaz;
   DelSpace(DocN);
   DocN:='ЗЛ '+DocN;
   DocDat:=GetZakazDate(E^.Dat.FromZakaz,FieldEndDate);
   If DocDat='' Then DocDat:=E^.Dat.DateC;
  End;
End
 Else
  Begin
   DocN:=DocN;
   DocDat:=DocDat;
  End;


Dispose(E,Done);




for j:=0 to Maxveksel-1 do
begin
{если есть вексель}
DelSpace(Veks.Exampl[j+1].numer);
if Veks.Exampl[j+1].Numer='' then break;
  if StrToInt(GetClientField(FLizo,Cl,0))=1 then Assign(Shablon,{PathDebug}Path^.Dat.ToText+'soglash.txt');
  if StrToInt(GetClientField(FLizo,Cl,0))=0 then Assign(Shablon,{PathDebug}Path^.Dat.ToText+'soglash1.txt');
  IOrez:=ioresult;
  reset(shablon);
  IOrez:=ioresult;
  if iorez<>0 then
    begin
        MessageBox(#3^M+#3'Ошибка открытия файла '+Path^.Dat.ToText+'soglash.txt',Nil,mfError+mfCancelButton);
        Exit;
    end;

  Assign(f,Path^.Dat.ToTemp+'soglash.txt');
  IOrez:=ioresult;
  rewrite(f);
  IOrez:=ioresult;
  if iorez<>0 then
    begin
        MessageBox(#3^M+#3'Ошибка создания файла '+Path^.Dat.ToTemp+'soglash.txt',Nil,mfError+mfCancelButton);
        Exit;
    end;


  While Not(Eof(Shablon)) Do
  Begin
   TempS:='';
   Readln(Shablon,TempS);
   If Pos('г.Тула',TempS)>0 Then
   TempS:=TempS+'                                                                   '+Veks.Exampl[j+1].Data+' г.';
   if Pos(',    именуемое   в   дальнейшем',TempS)>0 then TempS:=Format(scl,CClient)+TempS;
   if pos(',  действующего на',TempS)>0 then
      if StrToInt(GetClientField(FLizo,Cl,0))=1 then TempS:=format(s,CAll)+TempS
        else TempS:='Генерального директора   '+format(s,CAll)+TempS;
   if pos(',  с  другой стороны,',TempS)>0 then
      if StrToInt(GetClientField(FLizo,Cl,0))=1 then TempS:=format(ws,CAll)+TempS;
   if pos('  1. Поставщик  продукции  в',TempS)>0 then TempS:=TempS+' '+Veks.Exampl[j+1].Data+' г обязался оплатить';
   if pos('приобретенный им у Продавца',TempS)>0  then TempS:=TempS+' '+format(Veks.Exampl[j+1].Summa,CZena)+' руб.';
   if pos('долженность Поставщика продукции',TempS)>0  then TempS:=TempS+' '+format(Veks.Exampl[j+1].Summa,CZena)+' руб.';
   if pos('  2. Продавец векселя в',TempS)>0  then TempS:=TempS+' '+DocN+'/'+z+' от '
              +DocDat+' г. обязал-';
   if pos('продукции составляет',TempS)>0  then TempS:=TempS+' '+format(Veks.Exampl[j+1].Summa,CZena)+' рублей.';
   if pos('производят  взаимное  погашение',TempS)>0  then TempS:=TempS+' '+format(Veks.Exampl[j+1].Summa,CZena);

{!!!}   if pos('▓',Temps)>0 then
{!!!}     begin
{!!!}         System.Delete(temps,1,1);
{!!!}         temps:=temps+'                                 '+scl;
{!!!}     end;

   if pos('▒',Temps)>0 then
        begin
          temps:='';
          if GetClientField(FClient,Cl,0)<>'' then writeln(f,space+'2. '+GetClientField(FClient,Cl,0));
          if GetClientField(FAdress,Cl,0)<>'' then writeln(f,space+'   '+GetClientField(FAdress,Cl,0));
          if GetClientField(FRsh,Cl,0)<>'' then writeln(f,space+'   р/с '+GetClientField(FRsh,Cl,0)+
               ' в '+GetClientField(FGde,Cl,0));
          if GetClientField(FINN,Cl,0)<>'' then writeln(f,space+'   ИНН '+GetClientField(FINN,Cl,0));
        end;

   Writeln(f,Space+TempS);

  End;

writeln(f);
{Writeln(f,Space,'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');}
writeln(f,space+'==========================================================================================');

IOrez:=ioresult;
Close(f);
IOrez:=ioresult;
Close(shablon);
IOrez:=ioresult;

{ViewAsText(Path^.Dat.ToTemp+'soglash.txt',true);}

If MessageBox(^M+#3'Печатать соглашение о прекращении обязательств N '+Veks.Exampl[j+1].DogovorNumer+'/'+z+' ?',Nil,
        mfConfirmation+mfOkCancel)=cmOk Then
Report(Path^.Dat.ToTemp+'soglash.txt','',2,False,False);


End;{for}

End;

Procedure PrintOrderVeksel(Veks:VekselType;cl:ArtikulStr;Sdoc:ArtikulStr;SDate:TDAteString);
Const Space=' ';
Var s,ws1,ws2 : TMyString;
    Txt : Text;
    i,j : LongInt;
Begin
If MessageBox(^M+#3'Печатать ПКО от Интраста клиенту ?',Nil,mfConfirmation+mfOkCancel)<>cmOk Then Exit;
For j:=0 To MaxVeksel-1 Do
Begin
DelSpace(Veks.Exampl[j+1].numer);
If Veks.Exampl[j+1].numer<>'' Then
Begin
Assign(txt,Path^.Dat.ToTemp+'pko.txt');
i:=IOResult;
Rewrite(txt);
i:=IOResult;
Writeln(txt,Space+'Предприятие:                                       ||');
s:='ОАО "ИНТРАСТ"';
Format(s,CAll-5);
Writeln(txt,Space+s+'  '+Rek^.Dat.Kod+'     || '+S);
Writeln(txt,Space+'                                                   ||');
DelZerro(SDoc);
Format(SDoc,CDocNumer);
Format(SDoc,CDocNumer);
Format(Veks.Exampl[j+1].DogovorNumer,CDocNumer);

Writeln(txt,Space+
GlobalPrn^.Dat.Bold[NPrint^.DAt.Printer]+
GlobalPrn^.Dat.Double[Nprint^.DAt.Printer]+'       ПРИХОДНЫЙ КАССОВЫЙ ОРДЕР N '+
Veks.Exampl[j+1].DogovorNumer+
GlobalPrn^.Dat.NoDouble[Nprint^.DAt.Printer]+
GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+'             ||        '
+
GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+
+
GlobalPrn^.Dat.Double[Nprint^.DAt.Printer]+' К В И Т А Н Ц И Я'+
GlobalPrn^.Dat.NoDouble[Nprint^.DAt.Printer]+
GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]);
Writeln(txt,Space+'              от '+Veks.Exampl[j+1].Data+'                          || к приходному кассовому ордеру N '+
Veks.Exampl[j+1].DogovorNumer);
s:=GetClientField(FClient,Cl,0);
Format (s,CClient);
Writeln(Txt,Space+'                                                   ||');
Writeln(txt,Space+'    Принято от '+s+'                ||  Принято от '+s);


Writeln(txt,Space+'Основание:по договору о продаже векселя от '+Veks.Exampl[j+1].Data+'||'+
'  Основание: по договору от '+
Veks.Exampl[j+1].Data{E^.Dat.Document});
Writeln(txt,Space+'                                                   ||');

s:=Veks.Exampl[j+1].Summa;
DelSpace(s);

ws1[0]:=#0;
ws2[0]:=#0;
Propis(s,ws1);
s:=ws1+s;
SpecialFormat(s,ws1,ws2);
Format(ws1,41);
Ws1[1]:=UpperCase(ws1[1]);
Writeln(txt,Space+
GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+ws1+
GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]+'          || '+
GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+ws1+
GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]);
If ws2[0]<>#0 Then
Begin
Format(ws2,41);
Writeln(txt,Space+
GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+ws2+
GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]+'          || '+
GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+ws2+
GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]);
End;
If s[0]<>#0 Then
Begin
Format(s,41);
Writeln(txt,Space+
GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+s+
GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]+'          || '+
GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+s+
GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]);
End;

Format(Veks.Exampl[j+1].Summa,CIZena);
Writeln(txt,Space+'         '+Veks.Exampl[j+1].Summa+' руб.                      ||      '+Veks.Exampl[j+1].Summa+' руб.');
MyStr(StrToReal(Veks.Exampl[j+1].Summa)/6,CIZena,CMantissa,s);
Writeln(txt,Space+'                                                   ||');
Writeln(txt,Space+'                                                   ||');
Writeln(txt,Space+'                                                   ||');
Writeln(txt,Space+'                                                   ||');
Writeln(txt,Space+'                                                   ||');
Writeln(Txt,Space+' Главный бухгалтер: _________    _________         || Главный бухгалтер: ________ _________');
Writeln(Txt,Space+'                     Подпись      Расшифр.         ||                     Подпись  Расшифр.');
Writeln(Txt,Space+' Получил кассир:    _________    _________         || Кассир:            ________ _________');
Writeln(txt,Space+'                     Подпись      Расшифр.         ||                     Подпись  Расшифр.');
Writeln(txt,Space+'============================================================================================');
i:=IOResult;
Close(txt);
i:=IOResult;
If MessageBox(^M+#3'Печатать ПКО N '+Veks.Exampl[j+1].DogovorNumer+'от ИНТРАСТА клиенту?',Nil,
mfConfirmation+mfOkCancel)=cmOk Then
  Begin
   Report(Path^.Dat.ToTemp+'pko.txt','',{Nprint^.DAt.CopyOrder}1,False,False);
  End;
End;{Numer}
End{For}
End;


Procedure PrintVeksel (Veks : VekselType;Cl:ArtikulStr);
Var f : Text;
    {Ex : Monstr;}
    Test,Temps,s,ws,ws1 : String;
    c : Word;
    M : Word;
    i : Word;
    Space,z : ArtikulStr;
    StartStr,D,Mm,Y : Integer;


Begin
Z:=Rek^.Dat.Kod;
Space:='   ';
DelZerro(Z);
{DelSpaceLeft (Ex.Podlegit);}

{DelSpaceLeft (Ex.Mesto1);}

{DelSpaceLeft (Ex.Mesto2);}

Assign(f,Path^.Dat.ToTemp+'vekselp.txt');
c:=IOResult;
Rewrite(f);
c:=IOResult;

If (c<>0) Then
 Begin
  MessageBox(#3^M+#3'Ошибка создания файла '+Path^.Dat.ToTemp+'vekselp.txt!'+
  +' Код:'+IntToStr(c,3),Nil,mfError+mfCancelButton);
  Exit;
 End;


For i:=0 To MaxVeksel-1 Do
Begin
s:=Veks.Exampl[i+1].Summa;
Propis(s,ws);
DelSpace(Veks.Exampl[i+1].Numer);
If Veks.Exampl[i+1].Numer[0]<>#0 Then
Begin
Writeln(f,
GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+Space+'                                         ИНТРАСТ ');
Writeln(f,Space+'                                     ВЕКСЕЛЬ ПРОСТОЙ');
Writeln(f,Space+' N'+Veks.Exampl[i+1].Numer+'/'+z+'                                                      '+
GlobalPrn^.Dat.Italic[Nprint^.DAt.printer]+'Серия:'+
Veks.Exampl[i+1].Seria+
GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]+
GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]);
Writeln(f);
MyStr(StrToReal(Veks.Exampl[i+1].Summa),CIZena,CMAntissa,Veks.Exampl[i+1].Summa);
DelSpace(Veks.Exampl[i+1].Summa);
Writeln(f,Space+'                       на сумму '+
GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+Veks.Exampl[i+1].Summa+' рублей'+
GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]);
Writeln(f);

M:=StrToInt(Copy(Veks.Exampl[i+1].Data,2+2,2));
Case M Of
1: temps:=' Января     ';
2: temps:=' Февраля    ';
3: temps:=' Марта      ';
4: temps:=' Апреля     ';
5: temps:=' Мая        ';
6: temps:=' Июня       ';
7: temps:=' Июля       ';
8: temps:=' Августа    ';
9: temps:=' Сентября   ';
10:temps:=' Октября    ';
11:temps:=' Ноября     ';
12:temps:=' Декабря    ';
Else Temps[0]:=#0;
End;

DateStringToDMY({DateMask}'dd-mm-yyyy',Veks.Exampl[i+1].Data, D, MM, Y);

Writeln(f,
GlobalPrn^.Dat.Double[Nprint^.DAt.Printer]+'                ',Copy(Veks.Exampl[i+1].Data,1,2)+'    '+
+TempS+' 20'+Copy(Veks.Exampl[i+1].Data,7,2),'                        '+'г.ТУЛА') {дата и место сотавления};

{MemC(Veks.Exampl[i+1].Data+' '+TempS+' 20'+Copy(Veks.Exampl[i+1].Data,7,2));}

Writeln(f);

Writeln(f,Space+GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+'            ИНВЕСТИЦИОННО - ТРАСТОВАЯ КОМПАНИЯ "ИНТРАСТ"');
Writeln(f,Space+                          '                  (открытое акционерное общество)'+
GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]);
Writeln(f,Space+
GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+'       г.Тула  Красноармейский пр-т, 7, офис 912. '+
GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]);
Writeln(f,Space+                          'безусловно обязуется оплатить по этому векселю денежную сумму в размере'+
GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]);

s:=Veks.Exampl[i+1].Summa;
Propis(s,ws);

s:=ws;
SpecialFormatVeksel(s,ws,ws1);

UpStr(ws);
UpStr(ws1);

Writeln(f,
GlobalPrn^.Dat.Double[Nprint^.DAt.Printer]+Space+
GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+
ws+' '+ws1+
GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]+
GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]);{пропись 1}
Writeln(f,
GlobalPrn^.Dat.Double[Nprint^.DAt.Printer]+Space+'и проценты из расчета '+Veks.Exampl[i+1].Proz+
+' (НОЛЬ) процентов годовых непосредственно');

ws:=GetClientField(FFullClient{FVekselDP},Cl,0);
Test:=ws;
DelSpace(Test);

If Test[0]=#0 Then
 Begin
  MessageBox('Не указано полное имя клиента в дательном падеже!',Nil,mfError+mfCancelButton);
 End;

Format(ws,CALL);
ws1:=GetClientField(FAdress,Cl,0);
Format(ws1,CALL);
Writeln(f,Space+ws+', '+ws1);
Writeln(f,Space+'или его приказу.');
Writeln(f,Space+'Место платежа: г. Тула');
Writeln(f);
Writeln(f,Space+'Генеральный директор                                                  Семочкин В.Е.');
Writeln(f);
Writeln(f,Space+'                                                                         М.П.');
Writeln(f);
Writeln(f,Space+'                                         ДЛЯ ИНДОССАМЕНТА');
Writeln(f,Space+'1. Платите приказу '+RekSF^.Dat.Name+' '+RekSF^.DAt.Adress);
Writeln(f,Space+'   Подпись индоссанта  '++'_________________ '+GetClientField(FFullClient,Cl,0));
Writeln(f);
Writeln(f,'=======================================================================================');
Close(f);
If MessageBox(^M+#3'Печатать вексель N '+Veks.Exampl[i+1].Numer+'?',Nil,mfConfirmation+mfOkCancel)=cmOk Then
Report(Path^.Dat.ToTemp+'vekselp.txt','',2,False,False);
Rewrite(f)
End;{If}
End;{For}
c:=IOResult;
Close(f);
c:=IOResult;
End;




Procedure PrintAktNew(Veks: VekselType; Cl:ArtikulStr);
const space=' ';
Var Shablon,f: text;
    {Veks : VekselType;}
    nv,nd,TempS,ws,s,test,skol,scl,scll,st,z: string;
    i,j,kol,IORez:word;
    sum:real;
    D,Mm,Y : INteger;
    TempPos:integer;
    TriadaName: string[CAll];
    TriadaDirector: string[CKto];
Begin
{Veks:=Veks1;}
z:=rek^.Dat.kod;
delzerro(z);

s:=GetClientField(FVekselIP,Cl,0);
Test:=s;
DelSpace(Test);
If Test[0]=#0 Then
 Begin
  MessageBox(^M+#3+'Не указано полное имя клиента в именительном падеже!',Nil,mfError+mfCancelButton);
  exit;
 End;
Format(s,CAll-16);
DelSpaceRight(s);
ws:=GetClientField(FSvid,Cl,0);
Format(ws,CAll);
DelSpaceRight(ws);
scl:=GetClientField(FClient,cl,0);
i:=0;

for j:=0 to Maxveksel-1 do
{если есть вексель}
Begin
DelSpace(Veks.Exampl[j+1].numer);
if Veks.Exampl[j+1].numer<>'' then
begin

  Assign(Shablon,Path^.Dat.ToText+'aktveks.txt');
  IOrez:=ioresult;
  reset(shablon);
  IOrez:=ioresult;
  if iorez<>0 then
    begin
        MessageBox(#3^M+#3'Ошибка открытия файла '+Path^.Dat.ToText+'aktveks.txt',Nil,mfError+mfCancelButton);
        Exit;
    end;

  Assign(f,Path^.Dat.ToTemp+'akt1.txt');
  IOrez:=ioresult;
  rewrite(f);
  IOrez:=ioresult;
  if iorez<>0 then
    begin
        MessageBox(#3^M+#3'Ошибка создания файла '+Path^.Dat.ToTemp+'akt1.txt',Nil,mfError+mfCancelButton);
        Exit;
    end;

  writeln(f,
  GlobalPrn^.Dat.OrientAlbom[Nprint^.DAt.Printer],
  GlobalPrn^.Dat.Condensed[Nprint^.DAt.Printer],
  GlobalPrn^.Dat.MinInterval2[Nprint^.DAt.Printer]);

  nd:=Veks.Exampl[j+1].DogovorNumer+'/'+z;
  format(nd,7);
  nv:=Veks.Exampl[j+1].Numer+'/'+z;
  format(nv,7);
  TriadaName:=Rek^.Dat.Name;
  format(TriadaName,CAll);
  TriadaDirector:=Rek^.Dat.Director;
  format(TriadaDirector,CKto);

  While Not(Eof(Shablon)) Do
  Begin
  Inc(i);
  TempS:='';
  Readln(Shablon,TempS);
  {Дата}
  If Pos('г.Тула',TempS)>0 Then
   while pos('01234567',TempS)>0 do
   begin
     TempPos:=pos('01234567',TempS);
     system.delete(Temps,TempPos,CDate);
     system.Insert(Veks.Exampl[j+1].Data,TempS,TempPos);
   end;
  {Триада}
    while pos('VTriadaName',TempS)>0 do
    begin
      TempPos:=pos('VTriadaName',Temps);
      system.delete(Temps,TempPos,CAll);
      system.Insert(TriadaName,TempS,TempPos);
    end;
  {Ген Директор Триада}
    while pos('VTDirector',Temps)>0 do
    Begin
      TempPos:=pos('VTDirector',Temps);
      system.delete(Temps,TempPos,CKto);
      system.Insert(TriadaDirector,TempS,TempPos);
    End;
  {Организация клиента}
  if pos('VClientName',Temps)>0 then
  BEgin
    while pos('VClientName',Temps)>0 do
    Begin
      format(scl,CAll);
      TempPos:=pos('VClientName',Temps);
      system.delete(Temps,TempPos,CAll);
      system.Insert(scl,TempS,TempPos);
    End;

    if StrToInt(GetClientField(FLizo,Cl,0))=1 then
    while pos('Генерального директора',Temps)>0 do
       Begin
        TempPos:=pos('Ген',Temps);
        system.delete(Temps,TempPos,22);
        system.Insert('                      ',TempS,TempPos);
       end;
  end;
  {в лице}
    while pos('VClientKto',Temps)>0 do
    Begin
      format(s,CAll);
      TempPos:=pos('VClientKto',Temps);
      system.delete(Temps,TempPos,CAll);
      system.Insert(s,TempS,TempPos);
    End;
   {свидетельство или Устав}
   if StrToInt(GetClientField(FLizo,Cl,0))=0 then
      while pos('свидетельства',Temps)>0 do
       Begin
        TempPos:=pos('свидетельства',Temps);
        system.delete(Temps,TempPos,13);
        system.Insert(' Устава      ',TempS,TempPos);
       End;
   {номер договора}
    while pos('VNVeks',Temps)>0 do
    Begin
      format(nd,7);
      TempPos:=pos('VNVeks',Temps);
      system.delete(Temps,TempPos,7);
      system.Insert(nd,TempS,TempPos);
    End;
   {дата договора}
    while pos('VDVeks',Temps)>0 do
    Begin
      TempPos:=pos('VDVeks',Temps);
      system.delete(Temps,TempPos,CDate);
      system.Insert(Veks.Exampl[j+1].Data,TempS,TempPos);
    End;


  {свидетельство}
  if pos('VSvidetel',Temps)>0 then
  if StrToInt(GetClientField(FLizo,Cl,0))=1 then
  while pos('VSvidetel',Temps)>0 do
  Begin
      TempPos:=pos('VSvidetel',Temps);
      system.delete(Temps,TempPos,CAll);
      system.Insert(format(ws,CAll),TempS,TempPos);
  End
  else
  while pos('VSvidetel',Temps)>0 do
  Begin
    ws:=' ';
    format(ws,Call+1);
    TempPos:=pos('VSvidetel',Temps);
    system.delete(Temps,TempPos,CAll+1);
    system.Insert(format(ws,CAll+1),TempS,TempPos);
  End;


  If POs('▒',TempS)>0 then
       begin
        kol:=0;
        st:='';
        TempS:='';
        inc(kol);
        MyStr(StrToReal(Veks.Exampl[j+1].Summa),CIZena,CMAntissa,Veks.Exampl[j+1].Summa);
        TempS:='                    '+format(Veks.Exampl[j+1].Seria,CLitr)+' '+nv+
                '      1  ' +' '+format(Veks.Exampl[j+1].summa,CIZena)+'    '+Veks.Exampl[j+1].Data+' по предъявлении'
                         {+Veks.Exampl[j+1].Data};
        MySTr(StrToReal(st)+StrToReal(Veks.Exampl[j+1].Summa),CIZena,CMantissa,st);
        TempS:=TempS+'                         | '+TempS;
       end;
     skol:= IntToStr(kol,CKol);
     rformat(skol,CKol);

  if pos('Всего',Temps)>0 then
     while pos('01234',TempS)>0 do
     begin
      TempPos:=pos('01234',TempS);
      system.delete(Temps,TempPos,CKOl);
      system.Insert(sKOl,TempS,TempPos);
     end;

  if pos('на общую сумму',Temps)>0 then
     while pos('012345678901234',TempS)>0 do
     begin
      TempPos:=pos('012345678901234',TempS);
      system.delete(Temps,TempPos,CIZena);
      system.Insert(st,TempS,TempPos);
     end;

  Writeln(f,Space+TempS);
End;{While}

{writeln(f);}
{Writeln(f,Space,'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');}

{writeln(f,space+'=========================================================================================');}

IOrez:=ioresult;
Close(f);
IOrez:=ioresult;

IOrez:=ioresult;
Close(shablon);
IOrez:=ioresult;
Report(Path^.Dat.ToTemp+'akt1.txt','',1,False,False);

end
else break;
End;{For}
{ViewAsText(Path^.Dat.ToTemp+'akt1.txt',true);}

End;


procedure SogVeksNew(Veks: VekselType; Cl:ArtikulStr; DocN:AllStr; DocDat: TDateString);
const space=' ';
Var Shablon,f: text;
    TempS,ws,s,test,skol,scl,scll,st: string;
    i,j,kol,IORez:word;
    z:string;
    E : PSuperMarketType;
    Ass : DocumentEditZ;
    TriadaName: string[CAll];
    TriadaDirector: string[CKto];
    TempPos: integer;
    ClAdr,CLRSH,ClInn: string [CAll];
    ss,TAdr,TInn: string [CAll];
    TRSH:string;

Begin
  z:=rek^.Dat.kod;
  delzerro(z);
  s:=GetClientField(FVekselIP,Cl,0);
Test:=s;
DelSpace(Test);
If Test[0]=#0 Then
 Begin
  MessageBox(^M+#3+'Не указано полное имя клиента в именительном падеже!',Nil,mfError+mfCancelButton);
  exit;
 End;

Format(s,CAll-16);
DelSpaceRight(s);
Format(s,CAll);
ws:=GetClientField(FSvid,Cl,0);
Format(ws,CAll);
DelSpaceRight(ws);
scl:=GetClientField(FClient,cl,0);
  i:=0;
CLAdr:=GetClientField(FAdress,Cl,0);
format(CLAdr,CALL);
CLRsh:='р/с '+GetClientField(FRsh,Cl,0)+' в '+GetClientField(FGde,Cl,0);
format(ClRsh,CALL);
ClINN:='ИНН '+GetClientField(FINN,Cl,0);
format(ClInn,CALL);

  TriadaName:=Rek^.Dat.Name;
  format(TriadaName,CAll);
  TriadaDirector:=Rek^.Dat.Director;
  format(TriadaDirector,CKto);
  TAdr:=Rek^.Dat.Adress;
  TRSH:='Р/сч '+Rek^.Dat.R_sh+' в '+Rek^.Dat.Gde+' ,БИК '+Rek^.Dat.BIK;
  TInn:='К/сч '+Rek^.Dat.K_sh+' ИНН '+Rek^.Dat.INN;



New(e,Init);
Ass.EditPosition:=DocN;
Ass.D:=DocDat;

If Not GetMarket1(Ass,E) Then
Begin
Dispose(E,Done);
MessageBox(^M+#3+'Не найдена первичная накладная!',Nil,mfError+mfCancelButton);
Exit;
End;



{вариант для доставки-вино}
If ZakazShema=0 Then
Begin
 If E^.Dat.Oformlenie=1 Then
  Begin
   DocN:=E^.Dat.FromZakaz;
   DelSpace(DocN);
   DocN:='ЗЛ '+DocN;
   DocDat:=GetZakazDate(E^.Dat.FromZakaz,FieldEndDate);
   If DocDat='' Then DocDAt:=E^.Dat.DateC;
  End;
End
 Else
  Begin
   DocN:=DocN;
   DocDat:=DocDat;
  End;


Dispose(E,Done);


for j:=0 to Maxveksel-1 do
begin
{если есть вексель}
DelSpace(Veks.Exampl[j+1].numer);
if Veks.Exampl[j+1].Numer='' then break;
  {if StrToInt(GetClientField(FLizo,Cl,0))=1 then Assign(Shablon,Path^.Dat.ToText+'soglash.txt');}
  {if StrToInt(GetClientField(FLizo,Cl,0))=0 then} Assign(Shablon,Path^.Dat.ToText+'sogVEKS.txt');
  IOrez:=ioresult;
  reset(shablon);
  IOrez:=ioresult;
  if iorez<>0 then
    begin
        MessageBox(#3^M+#3'Ошибка открытия файла '+Path^.Dat.ToText+'soglash.txt',Nil,mfError+mfCancelButton);
        Exit;
    end;

  Assign(f,Path^.Dat.ToTemp+'soglash.txt');
  IOrez:=ioresult;
  rewrite(f);
  IOrez:=ioresult;
  if iorez<>0 then
    begin
        MessageBox(#3^M+#3'Ошибка создания файла '+Path^.Dat.ToTemp+'soglash.txt',Nil,mfError+mfCancelButton);
        Exit;
    end;

writeln(f,GlobalPrn^.Dat.OrientAlbom[Nprint^.DAt.Printer],
          GlobalPrn^.Dat.Condensed3[Nprint^.DAt.Printer],
          GlobalPrn^.Dat.MinInterval[Nprint^.DAt.Printer]);

  While Not(Eof(Shablon)) Do
  Begin
   TempS:='';
   Readln(Shablon,TempS);

  {Дата}
  If Pos('г.Тула',TempS)>0 Then
   while pos('01234567',TempS)>0 do
   begin
     TempPos:=pos('01234567',TempS);
     system.delete(Temps,TempPos,CDate);
     system.Insert(Veks.Exampl[j+1].Data,TempS,TempPos);
   end;

  {Триада}
    while pos('VTriadaName',TempS)>0 do
    begin
      TempPos:=pos('VTriadaName',Temps);
      system.delete(Temps,TempPos,CAll);
      system.Insert(TriadaName,TempS,TempPos);
    end;

  {Ген Директор Триада}
    while pos('VTDirector',Temps)>0 do
    Begin
      TempPos:=pos('VTDirector',Temps);
      system.delete(Temps,TempPos,CKto);
      system.Insert(TriadaDirector,TempS,TempPos);
    End;

  {Организация клиента}
  if pos('VClientName',Temps)>0 then
  BEgin
    while pos('VClientName',Temps)>0 do
    Begin
      format(scl,CAll);
      TempPos:=pos('VClientName',Temps);
      system.delete(Temps,TempPos,CAll);
      system.Insert(scl,TempS,TempPos);
    End;

    if StrToInt(GetClientField(FLizo,Cl,0))=1 then
    while pos('Генерального директора',Temps)>0 do
       Begin
        TempPos:=pos('Ген',Temps);
        system.delete(Temps,TempPos,22);
        system.Insert('                      ',TempS,TempPos);
       end;
  end;

   {в лице}
    while pos('VClientKto',Temps)>0 do
    Begin
      format(s,CAll);
      TempPos:=pos('VClientKto',Temps);
      system.delete(Temps,TempPos,CAll);
      system.Insert(s,TempS,TempPos);
    End;

   {свидетельство или Устав}
   if StrToInt(GetClientField(FLizo,Cl,0))=0 then
      while pos('свидетельства',Temps)>0 do
       Begin
        TempPos:=pos('свидетельства',Temps);
        system.delete(Temps,TempPos,13);
        system.Insert(' Устава      ',TempS,TempPos);
       End;
      {свидетельство}
  if pos('VSvidetel',Temps)>0 then
  if StrToInt(GetClientField(FLizo,Cl,0))=1 then
  while pos('VSvidetel',Temps)>0 do
  Begin
      TempPos:=pos('VSvidetel',Temps);
      system.delete(Temps,TempPos,CAll);
      system.Insert(format(ws,CAll),TempS,TempPos);
  End
  else
  while pos('VSvidetel',Temps)>0 do
  Begin
    ws:=' ';
    format(ws,Call+1);
    TempPos:=pos('VSvidetel',Temps);
    system.delete(Temps,TempPos,CAll+1);
    system.Insert(format(ws,CAll+1),TempS,TempPos);
  End;
  {Адрес клиента}
  while pos('VCAdress',Temps)>0 do
  Begin
      TempPos:=pos('VCAdress',Temps);
      system.delete(Temps,TempPos,CAll);
      system.Insert(CLAdr,TempS,TempPos);
  End;
  {Р.с клиента}
  while pos('VCRsh',Temps)>0 do
  Begin
      TempPos:=pos('VCRsh',Temps);
      system.delete(Temps,TempPos,CAll);
      system.Insert(ClRsh,TempS,TempPos);
  End;
  {ИНН Клиента}
  while pos('VCINN',Temps)>0 do
  Begin
      TempPos:=pos('VCINN',Temps);
      system.delete(Temps,TempPos,CAll);
      system.Insert(ClINN,TempS,TempPos);
  End;

  {Адрес Триады}
  while pos('VTAdress',Temps)>0 do
  Begin
      TempPos:=pos('VTAdress',Temps);
      system.delete(Temps,TempPos,Length(TAdr));
      system.Insert(TAdr,TempS,TempPos);
  End;

  {Р.с Триады}
  while pos('VTRsh',Temps)>0 do
  Begin
      TempPos:=pos('VTRsh',Temps);
      system.delete(Temps,TempPos,Length(TRsh));
      system.Insert(TRsh,TempS,TempPos);
  End;

  {ИНН Триады}
  while pos('VTInn',Temps)>0 do
  Begin
      TempPos:=pos('VTInn',Temps);
      system.delete(Temps,TempPos,Length(TINN));
      system.Insert(TINN,TempS,TempPos);
  End;

  {дата договора}
  while pos('VDVeks',Temps)>0 do
    Begin
      TempPos:=pos('VDVeks',Temps);
      system.delete(Temps,TempPos,CDate);
      system.Insert(Veks.Exampl[j+1].Data,TempS,TempPos);
    End;

  {N накладной}
  ss:=DocN+'/'+z;
  Format(ss,7);
  while pos('VNNakl',Temps)>0 do
    Begin
      TempPos:=pos('VNNakl',Temps);
      system.delete(Temps,TempPos,7{Length(DocN+'/'+z)});
      system.Insert({DocN+'/'+z}ss,TempS,TempPos);
    End;

  { Дата накладной}
  while pos('VDNakl',Temps)>0 do
    Begin
      TempPos:=pos('VDNakl',Temps);
      system.delete(Temps,TempPos,Length(DocDat));
      system.Insert(DocDat,TempS,TempPos);
    End;

  { Сумма }
  while pos('VSumma',Temps)>0 do
    Begin
      TempPos:=pos('VSumma',Temps);
      system.delete(Temps,TempPos,CIZena);
      system.Insert(format(Veks.Exampl[j+1].Summa,CIZena),TempS,TempPos);
    End;



(*   If Pos('г.Тула',TempS)>0 Then
   TempS:=TempS+'                                                                   '+Veks.Exampl[j+1].Data+' г.';
   if Pos(',    именуемое   в   дальнейшем',TempS)>0 then TempS:=Format(scl,CClient)+TempS;
   if pos(',  действующего на',TempS)>0 then
      if StrToInt(GetClientField(FLizo,Cl,0))=1 then TempS:=format(s,CAll)+TempS
        else TempS:='Генерального директора   '+format(s,CAll)+TempS;
   if pos(',  с  другой стороны,',TempS)>0 then
      if StrToInt(GetClientField(FLizo,Cl,0))=1 then TempS:=format(ws,CAll)+TempS;
   if pos('  1. Поставщик  продукции  в',TempS)>0 then TempS:=TempS+' '+Veks.Exampl[j+1].Data+' г обязался оплатить';
   if pos('приобретенный им у Продавца',TempS)>0  then TempS:=TempS+' '+format(Veks.Exampl[j+1].Summa,CZena)+' руб.';
   if pos('долженность Поставщика продукции',TempS)>0  then TempS:=TempS+' '+format(Veks.Exampl[j+1].Summa,CZena)+' руб.';
   if pos('  2. Продавец векселя в',TempS)>0  then TempS:=TempS+' '+DocN+'/'+z+' от '
              +DocDat+' г. обязал-';
   if pos('продукции составляет',TempS)>0  then TempS:=TempS+' '+format(Veks.Exampl[j+1].Summa,CZena)+' рублей.';
   if pos('производят  взаимное  погашение',TempS)>0  then TempS:=TempS+' '+format(Veks.Exampl[j+1].Summa,CZena);

{!!!}   if pos('▓',Temps)>0 then
{!!!}     begin
{!!!}         System.Delete(temps,1,1);
{!!!}         temps:=temps+'                                 '+scl;
{!!!}     end;

   if pos('▒',Temps)>0 then
        begin
          temps:='';
          if GetClientField(FClient,Cl,0)<>'' then writeln(f,space+'2. '+GetClientField(FClient,Cl,0));
          if GetClientField(FAdress,Cl,0)<>'' then writeln(f,space+'   '+GetClientField(FAdress,Cl,0));
          if GetClientField(FRsh,Cl,0)<>'' then writeln(f,space+'   р/с '+GetClientField(FRsh,Cl,0)+
               ' в '+GetClientField(FGde,Cl,0));
          if GetClientField(FINN,Cl,0)<>'' then writeln(f,space+'   ИНН '+GetClientField(FINN,Cl,0));
        end;      *)

   Writeln(f,Space+TempS);

  End;

{writeln(f);}
{Writeln(f,Space,'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');}

IOrez:=ioresult;
Close(f);
IOrez:=ioresult;
Close(shablon);
IOrez:=ioresult;

{ViewAsText(Path^.Dat.ToTemp+'soglash.txt',true);}

Report(Path^.Dat.ToTemp+'soglash.txt','',1,False,False);


End;{for}

End;



procedure DogVeksNew(Veks: VekselType; Cl:ArtikulStr);
const space=' ';
Var Shablon,f: text;
    nd,nv,z,TempS,ws,s,test,skol,scl,scll,st: string;
    i,j,kol,IORez:word;
    TriadaName: string[CAll];
    TriadaDirector: string[CKto];
    TempPos: integer;
    ClAdr,CLRSH,ClInn: string [CAll];
    TAdr,TInn: string [CAll];
    TRSH:string;
Begin
z:=rek^.Dat.kod;
     delzerro(z);

s:=GetClientField(FVekselIP,Cl,0);
Test:=s;
DelSpace(Test);
If Test[0]=#0 Then
 Begin
  MessageBox(^M+#3+'Не указано полное имя клиента в именительном падеже!',Nil,mfError+mfCancelButton);
  exit;
 End;
Format(s,CAll-16);
DelSpaceRight(s);
Format(s,CAll);
ws:=GetClientField(FSvid,Cl,0);
Format(ws,CAll);
DelSpaceRight(ws);
scl:=GetClientField(FClient,cl,0);
  i:=0;
CLAdr:=GetClientField(FAdress,Cl,0);
format(CLAdr,CALL);
CLRsh:='р/с '+GetClientField(FRsh,Cl,0)+' в '+GetClientField(FGde,Cl,0);
format(ClRsh,CALL);
ClINN:='ИНН '+GetClientField(FINN,Cl,0);
format(ClInn,CALL);

for j:=0 to Maxveksel-1 do
begin
{если есть вексель}
DelSpace(Veks.Exampl[j+1].numer);
if Veks.Exampl[j+1].Numer='' then break;

{  if StrToInt(GetClientField(FLizo,Cl,0))=1 then Assign(Shablon,Path^.Dat.ToText+'dogveks1.txt');}
{  if StrToInt(GetClientField(FLizo,Cl,0))=0 then} Assign(Shablon,{PathDebug}Path^.Dat.ToText+'dogveks.txt');
  IOrez:=ioresult;
  reset(shablon);
  IOrez:=ioresult;
  if iorez<>0 then
    begin
        MessageBox(#3^M+#3'Ошибка открытия файла '+Path^.Dat.ToText+'dogveks1.txt',Nil,mfError+mfCancelButton);
        Exit;
    end;

  Assign(f,Path^.Dat.ToTemp+'dogveks1.txt');
  IOrez:=ioresult;
  rewrite(f);
  IOrez:=ioresult;
  if iorez<>0 then
    begin
        MessageBox(#3^M+#3'Ошибка создания файла '+Path^.Dat.ToTemp+'dogveks1.txt',Nil,mfError+mfCancelButton);
        Exit;
    end;


    writeln(f,GlobalPrn^.Dat.OrientAlbom[Nprint^.DAt.Printer],
              GlobalPrn^.Dat.Condensed3[Nprint^.DAt.Printer],
              GlobalPrn^.Dat.MinInterval[Nprint^.DAt.Printer]);


  nd:=Veks.Exampl[j+1].DogovorNumer+'/'+z;
  format(nd,7);
  nv:=Veks.Exampl[j+1].Numer+'/'+z;
  format(nv,7);
  TriadaName:=Rek^.Dat.Name;
  format(TriadaName,CAll);
  TriadaDirector:=Rek^.Dat.Director;
  format(TriadaDirector,CKto);
  TAdr:=Rek^.Dat.Adress;
  TRSH:='Р/сч '+Rek^.Dat.R_sh+' в '+Rek^.Dat.Gde+' ,БИК '+Rek^.Dat.BIK;
  TInn:='К/сч '+Rek^.Dat.K_sh+' ИНН '+Rek^.Dat.INN;


  While Not(Eof(Shablon)) Do
  Begin
   TempS:='';
   Readln(Shablon,TempS);
   If Pos('г. Тула',TempS)>0 Then
   while pos('01234567',TempS)>0 do
   begin
     TempPos:=pos('01234567',TempS);
     system.delete(Temps,TempPos,CDate);
     system.Insert(Veks.Exampl[j+1].Data,TempS,TempPos);
   end;

  {Триада}
    while pos('VTriadaName',TempS)>0 do
    begin
      TempPos:=pos('VTriadaName',Temps);
      system.delete(Temps,TempPos,CAll);
      system.Insert(TriadaName,TempS,TempPos);
    end;
  {Ген Директор Триада}
    while pos('VTDirector',Temps)>0 do
    Begin
      TempPos:=pos('VTDirector',Temps);
      system.delete(Temps,TempPos,CKto);
      system.Insert(TriadaDirector,TempS,TempPos);
    End;
  {Организация клиента}
  if pos('VClientName',Temps)>0 then
  BEgin
    while pos('VClientName',Temps)>0 do
    Begin
      format(scl,CAll);
      TempPos:=pos('VClientName',Temps);
      system.delete(Temps,TempPos,CAll);
      system.Insert(scl,TempS,TempPos);
    End;

    if StrToInt(GetClientField(FLizo,Cl,0))=1 then
    while pos('Генерального директора',Temps)>0 do
       Begin
        TempPos:=pos('Ген',Temps);
        system.delete(Temps,TempPos,22);
        system.Insert('                      ',TempS,TempPos);
       end;
  end;
  {в лице}
    while pos('VClientKto',Temps)>0 do
    Begin
      format(s,CAll);
      TempPos:=pos('VClientKto',Temps);
      system.delete(Temps,TempPos,CAll);
      system.Insert(s,TempS,TempPos);
    End;
   {свидетельство или Устав}
   if StrToInt(GetClientField(FLizo,Cl,0))=0 then
      while pos('свидетельства',Temps)>0 do
       Begin
        TempPos:=pos('свидетельства',Temps);
        system.delete(Temps,TempPos,13);
        system.Insert(' Устава      ',TempS,TempPos);
       End;
   {свидетельство}
  if pos('VSvidetel',Temps)>0 then
  if StrToInt(GetClientField(FLizo,Cl,0))=1 then
  while pos('VSvidetel',Temps)>0 do
  Begin
      TempPos:=pos('VSvidetel',Temps);
      system.delete(Temps,TempPos,CAll);
      system.Insert(format(ws,CAll),TempS,TempPos);
  End
  else
  while pos('VSvidetel',Temps)>0 do
  Begin
    ws:=' ';
    format(ws,Call+1);
    TempPos:=pos('VSvidetel',Temps);
    system.delete(Temps,TempPos,CAll+1);
    system.Insert(format(ws,CAll+1),TempS,TempPos);
  End;


  {Адрес клиента}
  while pos('VCAdress',Temps)>0 do
  Begin
      TempPos:=pos('VCAdress',Temps);
      system.delete(Temps,TempPos,CAll);
      system.Insert(CLAdr,TempS,TempPos);
  End;
  {Р.с клиента}
  while pos('VCRsh',Temps)>0 do
  Begin
      TempPos:=pos('VCRsh',Temps);
      system.delete(Temps,TempPos,CAll);
      system.Insert(ClRsh,TempS,TempPos);
  End;
  {ИНН Клиента}
  while pos('VCINN',Temps)>0 do
  Begin
      TempPos:=pos('VCINN',Temps);
      system.delete(Temps,TempPos,CAll);
      system.Insert(ClINN,TempS,TempPos);
  End;

  {Адрес Триады}
  while pos('VTAdress',Temps)>0 do
  Begin
      TempPos:=pos('VTAdress',Temps);
      system.delete(Temps,TempPos,CAll);
      system.Insert(TAdr,TempS,TempPos);
  End;
  {Р.с Триады}
  while pos('VTRsh',Temps)>0 do
  Begin
      TempPos:=pos('VTRsh',Temps);
      system.delete(Temps,TempPos,CAll);
      system.Insert(TRsh,TempS,TempPos);
  End;
  {ИНН Триады}
  while pos('VTInn',Temps)>0 do
  Begin
      TempPos:=pos('VTInn',Temps);
      system.delete(Temps,TempPos,CAll);
      system.Insert(TINN,TempS,TempPos);
  End;



  { If Pos('г. Тула',TempS)>0 Then
   TempS:=TempS+'                                                             '+Veks.Exampl[j+1].Data+' г.';
   if Pos('нии Устава  с  одной  стороны',TempS)>0 then TempS:=TempS+' '+Format(scl,CClient)+
   ' именуемое  "Покупатель",  в  лице';
   if pos('действующего(ей)',TempS)>0 then
       if StrToInt(GetClientField(FLizo,Cl,0))=0 then TempS:='Генерального директора '+format(s,CAll)+TempS
        else TempS:=format(s,CAll)+TempS;
   if pos('с другой стороны,',TempS)>0 then
      if StrToInt(GetClientField(FLizo,Cl,0))=1 then TempS:=format(ws,CAll)+TempS;
   if pos('▒',Temps)>0 then
        begin
          temps:='';
          writeln(f,space+'  '+GetClientField(FClient,Cl,0));
          writeln(f,space+'  '+GetClientField(FAdress,Cl,0));
          writeln(f,space+'  р/с '+GetClientField(FRsh,Cl,0)+' в '+GetClientField(FGde,Cl,0));
          writeln(f,space+'  ИНН '+GetClientField(FINN,Cl,0));
        end;  }

   Writeln(f,Space+TempS);

  End;

{writeln(f);}
{Writeln(f,Space,'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');}

IOrez:=ioresult;
Close(f);
IOrez:=ioresult;
Close(shablon);
IOrez:=ioresult;

Report(Path^.Dat.ToTemp+'dogveks1.txt','',2,False,False);

End;{for}

End;



Procedure PrnComplect(Veks: VekselType; Cl:ArtikulStr; DocN:AllStr; DocDat: TDateString);
Begin
   If MessageBox(#3^M+#3'Провести заполнение векселей?',Nil,mfConfirmation+mfOkCancel)=CmOk Then
    PrintVeksel(Veks,Cl);
   If MessageBox(#3^M+#3'Провести заполнение актов приема-передачи?',Nil,mfConfirmation+mfOkCancel)=CmOk Then
    PrintAktNew(Veks,Cl);
   If MessageBox(#3^M+#3'Провести заполнение договоров о продаже векселей?',Nil,mfConfirmation+mfOkCancel)=CmOk Then
    DogVeksNew(Veks,Cl);
   If MessageBox(#3^M+#3'Провести заполнение соглашения?',Nil,mfConfirmation+mfOkCancel)=CmOk Then
    SogVeksNew(Veks,Cl,DocN,DocDat);

End;






Begin
End.