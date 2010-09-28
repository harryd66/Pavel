Unit Vision9;

{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}

{$I Compile.INC}


Interface

Uses Glob,Dialogs,ServStr,Serv,Utils,Vision1;

{procedure TestPr;}

Procedure FormProtSogl(E:PSuperMarketType; Var t:Text;Commissioner:Boolean);
Procedure FormPrilog(E:PSuperMarketType; Var t:Text;Commissioner:Boolean);
Procedure ExportXLSNakl (As: DocumentEditZ);
Procedure RashetProdag(Const Spis:PBox;Const M:Maska8;Const Assort,Sort:Word);
Procedure FormNaklRet(Space :TDateString; Video : Boolean;As :DocumentEditZ;Const E:PSuperMarketType;
                   Var Txt:Text; Var NDS,Itogo,ItogoSkidka,NDS20,NDS10,NDS_:Float;
                            ShowAnswer:Boolean);
Procedure AutoExportXLSNakl (As: DocumentEditZ);

Implementation




Uses DBEngine,DBEngin2,MsgBox,Views,Propiss,TpDate,Access,Tools,Vision6,PrnVeks,Utils3,
     NetDBEng,Printers,Objects,Utils1,Prise,Vision5,Vision7,Vision4,Utils4,
     MrkTools,MrkTool,ServStr2,Mail,
     Protect,Utils5,Drivers,Memory,App,Dos;

Var OldFileMode: Word;

(*
procedure TestPr;
var _E: PSuperMarketType;
  _FE: MarketFileType;
  i: word;

begin
   New(_E,Init);
   Assign(_FE,Path^.Dat.ToMarket+'11-12-00.mrk');
   i:=ioresult;
   Reset(_FE);
   i:=ioresult;
   If i <> 0 Then
  Begin
   NoInfo;
   MessageBox(#3^M+#3'Не могу создать файл '+Path^.Dat.ToTemp+'11-12-00.mrk'+
   +' Код:'+IntToStr(i,3),Nil,mfError+mfCancelButton);
   Exit;
  End;
  {while not eof(_FE) do }
   begin
    ReadMarket(_FE,_E);
    FormProtSogl( true,_E);
   end;
  Dispose(_E);
  Close(_FE);

end;
*)


(*Procedure FormProtSogl(E:PSuperMarketType; Var t:Text;Commissioner:Boolean);
var Separator: Char;
    Space: String;
    l: word;
    s,ws,ws1,st: string;
    Cl : PClientType;
    Rek1 :PRekwiziti;
    koefficient,nazenka:string;
    ZenaR,cvZena: string[CZena];
    Symbol : ArtikulStr;
    Include : Boolean;
Begin

New(Rek1,Init);

  If MessageBox(^M+#3'Включать цены Государственного реестра?',Nil,
  mfConfirmation+mfOkCAncel)=cmOk Then Include:=True
  Else Include:=False;



  DInfoMsg('Формирую протокол согласования цен ...',False);
  Separator := '│';
  Space:=' ';

  New(Cl,Init);
  Cl^.DAt.Kod:=E^.Dat.ClientKod;

  GetClient(Cl,E^.Dat.OperatorSelector);

If Not Commissioner Then
Begin
{$IFNDEF Tabak}
   If E^.Dat.DocSelector in [2,3,4,5,6,7,8] Then Rek1^.Dat:=RekSF^.Dat
   Else Rek1^.Dat:=Rek^.Dat;
{$ELSE}
   If E^.Dat.DocSelector in [3,4,6,8] Then Rek1^.Dat:=RekSF^.Dat
   Else Rek1^.Dat:=Rek^.Dat;
{$ENDIF}
End
Else Rek1:=RekComissioner;


  s:=Cl^.Dat.FullName;
  DelSpaceRight(s);

  DelSpace(E^.Dat.Document);

If Not Commissioner Then
  Writeln(t,OrientAlbom[Nprint^.DAt.Printer]+'  ПРОТОКОЛ СОГЛАСОВАНИЯ ЦЕН N '+E^.Dat.Document+'/'+
  IntToStr(StrToInt(E^.Dat.SkladKod),COne)+
  +' от '+E^.Dat.DateC+
  ' ('+E^.DAt.TimeC+')')
Else
  Writeln(t,OrientAlbom[Nprint^.DAt.Printer]+'  ПРОТОКОЛ СОГЛАСОВАНИЯ ЦЕН N '+'________ от _______');


  Writeln(t);
  DelSpaceRight(Rek1^.Dat.Name);
  Writeln(t,Space+'Согласование свободных отпускных цен на лекарственные средства и изделия медицинского назначения,');
  Writeln(t,Space+'подлежащих продаже по свободным розничным ценам между '+Rek1^.Dat.Name+' и '+s+' ('+E^.DAt.ClientKod+')'+
  MinInterval[Nprint^.DAt.Printer]);

Writeln(t,Space+'┌────────────────────────────┬──────────┬─────────────────────────┬────────┬────────┬──────────────┬────────'+
'┬──────────────┬────────┐');
Writeln(t,Space+'│                            │          │                         │Цена про│Свободн.│Торгов.надбав.│  Цена  '+
'│Торгов.надбав.│Розничн.│');
Writeln(t,Space+'│                            │          │                         │извод.по│отпускн.│оптового звена│ Оплаты '+
'│розничн. звен.│  цена  │');
Writeln(t,Space+'│  Наименование товара       │ Серия    │Предприятие-изготовитель │Гос.реес│цена *  │              │        '+
'│              │за един.│');
Writeln(t,Space+'│                            │          │                         │        │        ├─────┬────────┤        '+
'├─────┬────────┤        │');
Writeln(t,Space+'│                            │          │                         │        │        │  %  │Сумма,р │        '+
'│  %  │Сумма,р │        │');
Writeln(t,Space+'└────────────────────────────┼──────────┼─────────────────────────┼────────┼────────┼─────┼────────┼────────'+
'┼─────┼────────┼────────┤');
                {12│12345678901234567890123456│1234567890│1234567890123456789012345│12345678│12345678│12345│12345678│12345678│
                         12345│12345678│12345678│}

  For l:=1 To E^.Dat.Amount Do
    Begin
     ws:='';
     ws1:='';
{N}  st:=IntToStr(l,CMantissa);
     RFormat(st,2);
     ws:=ws+st;
    { format(st,CMantissa);
     ws:=ws+st; }
{Наименование товара}
     st:=GetIdField(FName,E^.Dat.MarketElement[l].BazKod);
     ws:=ws+' '+Format(st,CName);

{Серия}
     st:=BakGetField(FMarka,E^.Dat.MarketElement[l].BazKod,0);
     Delspace(st);
     ws:=ws+separator+Format(st,10);
{Предприятие изготовитель}
     st:=BakGetField(FPost,E^.Dat.MarketElement[l].BazKod,0);
     ws:=ws+separator+format(st,25);
{Цена произв}


     If Include Then
     Begin
      if StrToInt(BakGetField(FUSD,E^.Dat.MarketElement[l].BazKod,0)) = 1 then
         begin
          s:=E^.Dat.DateC;
          GetKurs(s);
          ZenaR:=BakGetField(FGRZena,E^.Dat.MarketElement[l].BazKod,0);
          If StrToReal(ZenaR)>=0.009 Then
          Mystr(StrToReal(s)*StrToReal(ZenaR),
             CZena,CMantissaZ,st)
          Else
           Begin
            St:='-       ';
           End;
         end
      else
         begin
          ZenaR:=BakGetField(FGRZena,E^.Dat.MarketElement[l].BazKod,0);
          If StrToReal(ZenaR)>=0.009 Then
          st:=ZenaR
          Else
          st:='-       ';
         end;
     End
     Else st:='-';

        ws:=ws+separator+format(st,CZena);

  {подсчитываем цену оплаты - s}
     If E^.Dat.SkidkaSelector=0 Then{Если автомат}
      begin
       DelSpace(E^.Dat.MarketElement[l].Input.Proz);

       MyStr((StrToReal(E^.Dat.MarketElement[l].Input.Zena)/
       (1+StrToReal(E^.Dat.MarketElement[l].Input.Proz)/100)),CZena,CMantissa,s);

       {отключен расчет налога с продажи в товарном чеке}
       If E^.DAt.DocSelector in [{1,}2,3,5,6] Then
       Begin
       Mystr(((1+strtoreal(e^.dat.marketelement[l].Input.SpecNalog)
              /100)),CLitr,CMantissa,koefficient);

{$IFDEF NSP}
       {новая цена}
       MyStr(StrToReal(s){*StrToReal(Koefficient)},CZena,CMantissa,s);
{$ELSE}
       MyStr(StrToReal(s)*StrToReal(Koefficient),CZena,CMantissa,s);
{$ENDIF}
       End;

       {ws:=ws+{' '}+s;}
      end
      Else
      Begin
{       ItogoSkidka:=ItogoSkidka+StrToReal(E^.Dat.MarketElement[l].Input.Skidka)*StrToInt(E^.Dat.MarketElement[l].Input.Kol);
       {сумма скидки}
       MyStr((StrToReal(E^.Dat.MarketElement[l].Input.Zena)-StrToReal(E^.Dat.MarketElement[l].Input.Skidka))
       ,CZena,CMantissa,s);

       {отключен расчет налога с продажи в товарном чеке}
       If E^.DAt.DocSelector in [{1,}2,3,5,6] Then
       Begin
       Mystr(((1+strtoreal(e^.dat.marketelement[l].Input.SpecNalog)
              /100)),CLitr,CMantissa,koefficient);

{$IFDEF NSP}
       {новая цена}
       MyStr(StrToReal(s){*StrToReal(Koefficient)},CZena,CMantissa,s);
{$ELSE}
       MyStr(StrToReal(s)*StrToReal(Koefficient),CZena,CMantissa,s);
{$ENDIF}
       End;

       {ws:=ws+{' '}+s;}
      End;
  {подсчитываем снаб.-сбыт.наценку}
      MyStr((strtoreal(s)*strtoreal(BakGetField(FProz,E^.Dat.MarketElement[l].BazKod,0))/
            (100+strtoreal(BakGetField(FProz,E^.Dat.MarketElement[l].BazKod,0)))),CZena,CMantissa,nazenka);
   {подсчитываем свободн.отпускн.цену}
      MyStr(strtoreal(s)-strtoreal(nazenka),CZena,CMantissa,cvZena);
{свободн.отпускн.ценa}
    ws:=ws+separator+Format(cvZena,CZena);
{Торг.надб. %}
    st:=BakGetField(FProz,E^.Dat.MarketElement[l].BazKod,0);
    MyStr(strtoreal(st),Clitr,CMantissa,st);
    ws:=ws+separator+st;
{Снаб.-сбыт.наценка}
    ws:=ws+separator+nazenka;
{Цена Оплаты}
    ws:=ws+separator+s;
    st:='';
    ws:=ws+separator+Format(st,CLitr);
    ws:=ws+separator+Format(st,CZena);
    ws:=ws+separator+Format(st,CZena);
    ws:=ws+separator;

  ws1:='';
  st:=GetIdField(FName2,E^.Dat.MarketElement[l].BazKod);
  DelSpaceRight(st);
  if st<>'' then
    begin
      st:=GetIdField(FName2,E^.Dat.MarketElement[l].BazKod);
      format(st,CName+CMantissa+1);
      ws1:=st;
      st:='';
      ws1:=ws1+separator+Format(st,10);
      st:=BakGetField(FFirmaPost,E^.Dat.MarketElement[l].BazKod,0);
      DelSpace(st);
      if st<>'' then
        begin
         st:=BakGetField(FFirmaPost,E^.Dat.MarketElement[l].BazKod,0);
         ws1:=ws1+separator+Format(st,25);
        end
        else
        begin
         st:= ' ';
         ws1:=ws1+separator+Format(st,25);
        end;
       st:='';
       ws1:=ws1+separator+Format(st,CZena);
       Delspace(st);
       ws1:=ws1+separator+Format(st,CZena);
       Delspace(st);
       ws1:=ws1+separator+Format(st,CLitr);
       Delspace(st);
       ws1:=ws1+separator+Format(st,CZena);
       Delspace(st);
       ws1:=ws1+separator+Format(st,CZena);
       Delspace(st);
       ws1:=ws1+separator+Format(st,CLitr);
       Delspace(st);
       ws1:=ws1+separator+Format(st,CZena);
       Delspace(st);
       ws1:=ws1+separator+Format(st,CZena);
       ws1:=ws1+separator;
    end
    else
    begin
     st:='';
     st:=BakGetField(FFirmaPost,E^.Dat.MarketElement[l].BazKod,0);
     DelSpaceRight(st);
   if st<>'' then
   begin
     st:='';
     ws1:=ws1+Format(st,CName+CMantissa+1);
     st:='';
     ws1:=ws1+separator+Format(st,10);
     st:='';
     st:=BakGetField(FFirmaPost,E^.Dat.MarketElement[l].BazKod,0);
         ws1:=ws1+separator+Format(st,25);
       st:='';
       ws1:=ws1+separator+Format(st,CZena);
       Delspace(st);
       ws1:=ws1+separator+Format(st,CZena);
       Delspace(st);
       ws1:=ws1+separator+Format(st,CLitr);
       Delspace(st);
       ws1:=ws1+separator+Format(st,CZena);
       Delspace(st);
       ws1:=ws1+separator+Format(st,CZena);
       Delspace(st);
       ws1:=ws1+separator+Format(st,CLitr);
       Delspace(st);
       ws1:=ws1+separator+Format(st,CZena);
       Delspace(st);
       ws1:=ws1+separator+Format(st,CZena);
       Delspace(st);
       ws1:=ws1+separator;
     end;
    end;

Writeln(t,Space+ws);

if ws1<>'' then Writeln(t,Space+ws1);

If l=E^.Dat.Amount Then
Writeln(t,Space+'─────────────────────────────┴──────────┴─────────────────────────┴────────┴────────┴─────┴────────┴────────'+
'┴─────┴────────┴────────┘')
Else
Writeln(t,Space+'─────────────────────────────┼──────────┼─────────────────────────┼────────┼────────┼─────┼────────┼────────'+
'┼─────┼────────┼────────┤');


    End;
Writeln(t);
Writeln(t,Space+'Примечание: * - свободная отпускная цена производителя (поставщика), закупившего товар за счет собственных в'+
'алютных средств.');
Writeln(t,Space+'Сертификаты качества получены посерийно и полностью.');
Writeln(t,Space+'Товары с нулевой наценкой закуплены за счет собственных валютных средств или по договору комиссии.');
Writeln(t);
Writeln(t,Space+'       Поставщик ___________________                  Получатель ___________________');
Writeln(t,Space+'        "_____" ____________ ______ г.                "_____" ____________ ______ г.');

   If E^.Dat.Rashet=2 Then Symbol:='-В'
           Else Symbol:='';

   Writeln(t);
   Writeln(t,Space+'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+
   ')'+Italic[Nprint^.DAt.Printer]+Bold[Nprint^.DAt.Printer]+
   Double[Nprint^.DAt.Printer]+
   '                                                                                   '+
   'Тип документа: (',
   LeadingZero(E^.Dat.DocSelector),+Symbol+')'+NoItalic[Nprint^.DAt.Printer]+NOBold[Nprint^.DAt.Printer]+
                                 NoDouble[Nprint^.DAt.Printer]);

    Writeln(t,Space+'========================================================================='+
    '============================'+
    '==========================='+OrientNormal[Nprint^.DAt.Printer]+
    Normal[Nprint^.DAt.Printer]{+EndPage[Nprint^.DAt.Printer]});

NoInfoMsg;

Dispose(Rek1,Done);
End;  *)

Procedure FormProtSogl(E:PSuperMarketType; Var t:Text;Commissioner:Boolean);
var Separator: Char;
    Space: String;
    l: word;
    s,ss,ws,ws1,st: string;
    Cl : PClientType;
    Rek1 :PRekwiziti;
    koefficient,nazenka:string;
    SKol,sIzgZena,sIzgZenaNDS,sIzgNDS,SNDS,ZenaR,cvZena: string[CZena];
    Symbol : ArtikulStr;
    Include : Boolean;
Begin

New(Rek1,Init);

  {If MessageBox(^M+#3'Включать цены Государственного реестра?',Nil,mfConfirmation+mfOkCAncel)=cmOk}
  If AutoAnswer(^M+#3'Включать цены Государственного реестра?')Then Include:=True
  Else Include:=False;

  DInfoMsg('Формирую протокол согласования цен ...',False);
  Separator := '│';
  Space:=' ';

  New(Cl,Init);
  Cl^.DAt.Kod:=E^.Dat.ClientKod;

  If Not GetClient(Cl,E^.Dat.OperatorSelector) Then
   Begin
    NoInfoMsg;
    Dispose(Cl,Done);
    Dispose(Rek1,Done);
    Exit;
   End;

If Not Commissioner Then
Begin
{$IFNDEF Tabak}
   If E^.Dat.DocSelector in [2,3,4,5,6,7,8] Then Rek1^.Dat:=RekSF^.Dat
   Else Rek1^.Dat:=Rek^.Dat;
{$ELSE}
   If E^.Dat.DocSelector in [3,4,6,8] Then Rek1^.Dat:=RekSF^.Dat
   Else Rek1^.Dat:=Rek^.Dat;
{$ENDIF}
End
Else Rek1:=RekComissioner;


  s:=Cl^.Dat.FullName;
  DelSpaceRight(s);

  DelSpace(E^.Dat.Document);

If Not Commissioner Then
  Writeln(t,GlobalPrn^.Dat.OrientAlbom[Nprint^.DAt.Printer]+'  ПРОТОКОЛ СОГЛАСОВАНИЯ ЦЕН N '+E^.Dat.Document+'/'+
  IntToStr(StrToInt(E^.Dat.SkladKod),COne)+
  +' от '+E^.Dat.DateC+
  ' ('+E^.DAt.TimeC+')')
Else
  Writeln(t,GlobalPrn^.Dat.OrientAlbom[Nprint^.DAt.Printer]+'  ПРОТОКОЛ СОГЛАСОВАНИЯ ЦЕН N '+'________ от _______');


  Writeln(t);
  DelSpaceRight(Rek1^.Dat.Name);
  Writeln(t,Space+'Согласование свободных отпускных цен на лекарственные средства и изделия медицинского назначения,');
  Writeln(t,Space+'подлежащих продаже по свободным розничным ценам между '+Rek1^.Dat.Name+' и '+s+' ('+E^.DAt.ClientKod+')'+
  GlobalPrn^.Dat.MinInterval[Nprint^.DAt.Printer]);
  Writeln(t,
  GlobalPrn^.Dat.MinInterval3[Nprint^.DAt.Printer]+
  GlobalPrn^.Dat.Condensed5[Nprint^.DAt.Printer]);

Writeln(t,Space+
'┌────────────────────────────┬──────────┬─────────────────────────┬─────┬────────┬────────┬────────┬────────┬─────'+
'───┬──────────────┬────────'+'┬────────┬────────┬──────────────┐');
Writeln(t,Space+
'│                            │          │                         │     │Цена за-│        │Цена за-│Цена про│Свобод'+
'н.│Торгов.надбав.│  Цена  '+'│ Сумма  │  Цена  │Торгов.надбав.│');
Writeln(t,Space+
'│                            │          │                         │Кол -│  вода  │ Сумма  │  вода  │извод.по│отпус'+
'кн.│оптового звена│ Оплаты '+'│  НДС   │ Оплаты │розничн. звен.│');
Writeln(t,Space+
'│  Наименование товара       │ Серия    │Предприятие-изготовитель │ во  │ изгот. │  НДС,  │ изгот. │Гос.реес│цена '+
'*  │              │без НДС '+'│за един.│ с НДС  │              │');
Writeln(t,Space+
'│                            │          │                         │     │без НДС │  руб.  │ с НДС  │        │ без '+
'НДС├─────┬────────┤        '+'│ товара │        ├─────┬────────┤');
Writeln(t,Space+
'│                            │          │                         │     │        │        │        │        │     '+
'   │  %  │Сумма,р │        '+'│        │        │  %  │Сумма,р │');
Writeln(t,Space+
'└────────────────────────────┼──────────┼─────────────────────────┼─────┼────────┼────────┼────────┼────────┼─────'+
'───┼─────┼────────┼────────'+'┼────────┼────────┼─────┼────────┤');
                {12│12345678901234567890123456│1234567890│1234567890123456789012345│12345678│12345678│12345│12345678│12345678│
			      12345│12345678│12345678│}

  For l:=1 To E^.Dat.Amount Do
    Begin
     ws:='';
     ws1:='';
{N}  st:=IntToStr(l,CMantissa);
     RFormat(st,2);
     ws:=ws+st;
    { format(st,CMantissa);
     ws:=ws+st; }
{Наименование товара}
     st:=GetIdField(FName,E^.Dat.MarketElement[l].BazKod);
     ws:=ws+' '+Format(st,CName);

{Серия}
     st:=GetMarkaField(FMarka,BakGetField(FMarka,E^.Dat.MarketElement[l].BazKod,0));
     Delspace(st);
     ws:=ws+separator+Format(st,10);
{Предприятие изготовитель}
     st:=GetPostField(FPost,BakGetField(FPost,E^.Dat.MarketElement[l].BazKod,0));
     ws:=ws+separator+format(st,25);
{Цена произв}
  {подсчитываем цену оплаты - s}
     If E^.Dat.SkidkaSelector=0 Then{Если автомат}
      begin
       DelSpace(E^.Dat.MarketElement[l].Input.Proz);

       MyStr((StrToReal(E^.Dat.MarketElement[l].Input.Zena)/
       (1+StrToReal(E^.Dat.MarketElement[l].Input.Proz)/100)),CZena,CMantissa,s);

       {отключен расчет налога с продажи в товарном чеке}
       If E^.DAt.DocSelector in [{1,}2,3,5,6] Then
       Begin
       Mystr(((1+strtoreal(e^.dat.marketelement[l].Input.SpecNalog)
              /100)),CLitr,CMantissa,koefficient);

{$IFDEF NSP}
       {новая цена}
       MyStr(StrToReal(s){*StrToReal(Koefficient)},CZena,CMantissa,s);
{$ELSE}
       MyStr(StrToReal(s)*StrToReal(Koefficient),CZena,CMantissa,s);
{$ENDIF}
       End;

       {ws:=ws+{' '+s;}
      end
      Else
      Begin
{       ItogoSkidka:=ItogoSkidka+StrToReal(E^.Dat.MarketElement[l].Input.Skidka)*StrToInt(E^.Dat.MarketElement[l].Input.Kol);
       {сумма скидки}
       MyStr((StrToReal(E^.Dat.MarketElement[l].Input.Zena)-StrToReal(E^.Dat.MarketElement[l].Input.Skidka))
       ,CZena,CMantissa,s);

       {отключен расчет налога с продажи в товарном чеке}
       If E^.DAt.DocSelector in [{1,}2,3,5,6] Then
       Begin
       Mystr(((1+strtoreal(e^.dat.marketelement[l].Input.SpecNalog)
              /100)),CLitr,CMantissa,koefficient);

{$IFDEF NSP}
       {новая цена}
       MyStr(StrToReal(s){*StrToReal(Koefficient)},CZena,CMantissa,s);
{$ELSE}
       MyStr(StrToReal(s)*StrToReal(Koefficient),CZena,CMantissa,s);
{$ENDIF}
       End;

       {ws:=ws+' '+s;}
      End;

   {подсчитываем цену завода-изготовителя}
    MyStr(strtoreal(s)/
    (1+StrToReal(BakGetField(FProz,E^.Dat.MarketElement[l].BazKod,0))/100),CZena,CMantissa,sIzgZenaNDS);
    RFormat(sIzgZenaNDS,CZena);
   {подсчитываем цену изготовителя без НДС}
    MyStr(StrToReal(sIzgZenaNDS)/(1+StrToReal(E^.Dat.MarketElement[l].Input.NDs)/100),CZena,CMantissa,sIzgZena);
    RFormat(sIzgZena,CZena);
    {подсчитываем сумму ндс изготовителя}
    MyStr(StrToReal(sIzgZenaNDS)-StrToReal(sIzgZena),CZena,CMantissa,SIzgNds);
    RFormat(sIzgNDS,CZena);

    SKol:=IntToStr(StrToInt(E^.Dat.MarketElement[l].Input.Kol),CKol);
    RFormat(sKol,CKol);


    ws:=ws+separator+sKol;{добавили количество}
    ws:=ws+separator+sIzgZena;
    ws:=ws+separator+sIzgNDS;
    ws:=ws+separator+sIzgZenaNDS;


     If Include Then
     Begin
      if StrToInt(BakGetField(FUSD,E^.Dat.MarketElement[l].BazKod,0)) = 1 then
         begin
          ss:=E^.Dat.DateC;
          GetKurs(ss);
          ZenaR:=BakGetField(FGRZena,E^.Dat.MarketElement[l].BazKod,0);
          If StrToReal(ZenaR)>=0.009 Then
          Mystr(StrToReal(ss)*StrToReal(ZenaR),
             CZena,CMantissaZ,st)
          Else
           Begin
            St:='-       ';
           End;
         end
      else
         begin
          ZenaR:=BakGetField(FGRZena,E^.Dat.MarketElement[l].BazKod,0);
          If StrToReal(ZenaR)>=0.009 Then
          st:=ZenaR
          Else
          st:='-       ';
         end;
     End
     Else st:='-';

        ws:=ws+separator+format(st,CZena);



   {подсчитываем свободн.отпускн.цену}
      MyStr(strtoreal(s)/(1+StrToReal(E^.Dat.MarketElement[l].Input.NDs)/100)/
         (1+StrToReal(BakGetField(FProz,E^.Dat.MarketElement[l].BazKod,0))/100),CZena,CMantissa,cvZena);

   {подсчитываем снаб.-сбыт.наценку}
      MyStr(StrToReal(s)/(1+StrToReal(E^.Dat.MarketElement[l].Input.NDs)/100),CZena,CMantissa,st);


      MyStr(StrToReal(s)-StrToReal(ST),CZena,CMantissa,SNds);
      DelSpace(SNds);
      RFormat(SNds,CZena);

      MyStr({(strtoreal(s)/(1+StrToReal(E^.Dat.MarketElement[l].Input.NDs)/100))}
      StrToReal(st)-
      StrToReal(cvZena)
         {(strtoreal(s)/(1+StrToReal(E^.Dat.MarketElement[l].Input.NDs)/100)/
         (1+StrToReal(BakGetField(FProz,E^.Dat.MarketElement[l].BazKod,0))/100))},CZena,CMantissa,Nazenka);

{свободн.отпускн.ценa}
    ws:=ws+separator+Format(cvZena,CZena);
{Торг.надб. %}
    st:=BakGetField(FProz,E^.Dat.MarketElement[l].BazKod,0);
    MyStr(strtoreal(st),Clitr,CMantissa,st);
    ws:=ws+separator+st;
{Снаб.-сбыт.наценка}
    ws:=ws+separator+nazenka;
{Цена Оплаты}
    MyStr(StrToReal(s)/(1+StrToReal(E^.Dat.MarketElement[l].Input.NDs)/100),CZena,CMantissa,st);
    ws:=ws+separator+Format(st,CZena);
    ws:=ws+separator+Format(sNDs,CZena);
    ws:=ws+separator+s;
    st:='';
    ws:=ws+separator+Format(st,CLitr);
    {ws:=ws+separator+Format(st,CZena);}

    ws:=ws+separator+Format(st,CZena);
    ws:=ws+separator;

  ws1:='';
  st:=GetIdField(FName2,E^.Dat.MarketElement[l].BazKod);
  DelSpaceRight(st);
  if st<>'' then
    begin
      st:=GetIdField(FName2,E^.Dat.MarketElement[l].BazKod);
      format(st,CName+CMantissa+1);
      ws1:=st;
      st:='';
      ws1:=ws1+separator+Format(st,10);
      st:=GetIDField(FFirmaPost,E^.Dat.MarketElement[l].BazKod);
      DelSpace(st);
      if st<>NoPostStr then
        begin
         st:=GetFirmaPostField(FFirmaPost,st);
         ws1:=ws1+separator+Format(st,25);
        end
        else
        begin
         st:= ' ';
         ws1:=ws1+separator+Format(st,25);
        end;
       st:='';
       SNDS:='';
       ws1:=ws1+separator+Format(st,CKOl);
       Delspace(st);
       ws1:=ws1+separator+Format(st,CZena);
       Delspace(st);
       ws1:=ws1+separator+Format(st,CZena);
       Delspace(st);
       ws1:=ws1+separator+Format(st,CZena);
       Delspace(st);
       ws1:=ws1+separator+Format(st,CZena);
       Delspace(st);
       ws1:=ws1+separator+Format(st,CZena);
       Delspace(st);
       ws1:=ws1+separator+Format(st,CLitr);
       Delspace(st);
       ws1:=ws1+separator+Format(st,CZena);
       Delspace(st);
       ws1:=ws1+separator+Format(st,CZena);

       Delspace(SNDS);
       ws1:=ws1+separator+Format(SNDS,CZena);

       Delspace(st);
       ws1:=ws1+separator+Format(st,CzENA);
       Delspace(st);
       ws1:=ws1+separator+Format(st,ClITR);
       Delspace(st);
       ws1:=ws1+separator+Format(st,CZena);
       ws1:=ws1+separator;
    end
    else
    begin
     st:='';
     st:=GetIDField(FFirmaPost,E^.Dat.MarketElement[l].BazKod);
     DelSpaceRight(st);
   if st<>NoPostStr then
   begin
     st:='';
     ws1:=ws1+Format(st,CName+CMantissa+1);
     st:='';
     ws1:=ws1+separator+Format(st,10);
     st:='';
     SNDS:='';
     st:=GetFirmaPostField(FFirmaPost,GetIDField(FFirmaPost,E^.Dat.MarketElement[l].BazKod));
         ws1:=ws1+separator+Format(st,25);
       st:='';
       ws1:=ws1+separator+Format(st,CKol);
       Delspace(st);
       ws1:=ws1+separator+Format(st,CZena);
       Delspace(st);
       ws1:=ws1+separator+Format(st,CZena);
       Delspace(st);
       ws1:=ws1+separator+Format(st,CZena);
       Delspace(st);
       ws1:=ws1+separator+Format(st,CZena);
       Delspace(st);
       ws1:=ws1+separator+Format(st,CZena);
       Delspace(st);
       ws1:=ws1+separator+Format(st,CLitr);
       Delspace(st);
       ws1:=ws1+separator+Format(st,CZena);
       Delspace(SNDS);
       ws1:=ws1+separator+Format(SNDS,CZena);
       Delspace(st);
       ws1:=ws1+separator+Format(st,CZena);
       Delspace(st);
       ws1:=ws1+separator+Format(st,CZena);
       Delspace(st);
       ws1:=ws1+separator+Format(st,CLITR);
       Delspace(st);
       ws1:=ws1+separator+Format(st,CZena);
       Delspace(st);
       ws1:=ws1+separator;
     end;
    end;

Writeln(t,Space+ws);

if ws1<>'' then Writeln(t,Space+ws1);

If l=E^.Dat.Amount Then

Writeln(t,Space+
'─────────────────────────────┴──────────┴─────────────────────────┴─────┴────────┴────────┴────────┴────────┴───'
+'─────┴─────┴────────┴────────'+
'┴────────┴────────┴─────┴────────┘')
Else
Writeln(t,Space+
'─────────────────────────────┼──────────┼─────────────────────────┼─────┼────────┼────────┼────────┼────────┼───'
+'─────┼─────┼────────┼────────'+
'┼────────┼────────┼─────┼────────┤');


    End;
Writeln(t,GlobalPrn^.Dat.Normal[Nprint^.DAt.Printer]+
GlobalPrn^.Dat.NoCondensed[Nprint^.DAt.Printer]);
Writeln(t,Space+'Примечание: * - свободная отпускная цена производителя (поставщика), закупившего товар за счет собственных в'+
'алютных средств.');
Writeln(t,Space+'Сертификаты качества получены посерийно и полностью.');
Writeln(t,Space+'Товары с нулевой наценкой закуплены за счет собственных валютных средств или по договору комиссии.');
Writeln(t);
Writeln(t,Space+'       Поставщик ___________________                  Получатель ___________________');
Writeln(t,Space+'        "_____" ____________ ______ г.                "_____" ____________ ______ г.');

   If E^.Dat.Rashet=2 Then Symbol:='-В'
           Else Symbol:='';

   Writeln(t);
   Writeln(t,Space+'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+
   ')'+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
   GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+
   GlobalPrn^.Dat.Double[Nprint^.DAt.Printer]+
   '                                                                                   '+
   'Тип документа: (',
   LeadingZero(E^.Dat.DocSelector),+Symbol+')'+
   GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]+
   GlobalPrn^.Dat.NOBold[Nprint^.DAt.Printer]+
   GlobalPrn^.Dat.NoDouble[Nprint^.DAt.Printer]);

    Writeln(t,Space+'========================================================================='+
    '============================'+
    '==========================='+GlobalPrn^.Dat.OrientNormal[Nprint^.DAt.Printer]+
    GlobalPrn^.Dat.Normal[Nprint^.DAt.Printer]{+EndPage[Nprint^.DAt.Printer]});

NoInfoMsg;
Dispose(Rek1,Done);
End;



Procedure FormPrilog(E:PSuperMarketType; Var t:Text;Commissioner:Boolean);
var Separator: Char;
    Space: String;
    l: word;
    s,ws,ws1,st: string;
    Cl : PClientType;
    Rek1 :PRekwiziti;
    koefficient,nazenka:string;
    ZenaR,cvZena: string[CZena];
    Symbol : ArtikulStr;
    Include : Boolean;
Begin

New(Rek1,Init);

  DInfoMsg('Формирую приложение ...',False);
  Separator := '│';
  Space:='        ';

  New(Cl,Init);
  Cl^.DAt.Kod:=E^.Dat.ClientKod;

  GetClient(Cl,E^.Dat.OperatorSelector);

If Not Commissioner Then
Begin
{$IFNDEF Tabak}
   If E^.Dat.DocSelector in [2,3,4,5,6,7,8] Then Rek1^.Dat:=RekSF^.Dat
   Else Rek1^.Dat:=Rek^.Dat;
{$ELSE}
   If E^.Dat.DocSelector in [3,4,6,8] Then Rek1^.Dat:=RekSF^.Dat
   Else Rek1^.Dat:=Rek^.Dat;
{$ENDIF}
End
Else Rek1:=RekComissioner;


  s:=Cl^.Dat.FullName;
  DelSpaceRight(s);

  DelSpace(E^.Dat.Document);

If Not Commissioner Then
  Writeln(t,GlobalPrn^.Dat.OrientAlbom[Nprint^.DAt.Printer]+
  GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+'          ПРИЛОЖЕНИЕ К НАКЛАДНОЙ N '+
  E^.Dat.Document+'/'+
  IntToStr(StrToInt(E^.Dat.SkladKod),COne)+
  +' от '+E^.Dat.DateC+
  ' ('+E^.DAt.TimeC+')'+GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer])
Else
  Writeln(t,Space+
  GlobalPrn^.Dat.OrientAlbom[Nprint^.DAt.Printer]+
  GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+
  '          ПРИЛОЖЕНИЕ К НАКЛАДНОЙ N '+'________ от _______'+
  +GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]);
  Writeln(T,Space+'Поставщик: '+RekSF^.Dat.Name);
  Writeln(T,Space+'Получатель: ',GetClientField(FFullClient,E^.Dat.ClientKod,E^.Dat.OperatorSelector)+' ('+
    E^.Dat.ClientKod+')'+'    Адрес:'+GetClientField(FAdress,E^.Dat.ClientKod,E^.Dat.OperatorSelector));


  Writeln(t);
  DelSpaceRight(Rek1^.Dat.Name);
  Writeln(t,
  GlobalPrn^.Dat.MinInterval2[Nprint^.DAt.Printer]+
  GlobalPrn^.Dat.Condensed2[Nprint^.DAt.Printer]);

Writeln(t,Space+'┌──┬──────────────────────────┬─────────────────────────┬──────────┬──────────────────────────┬────'+
'────┬────────────────────────────────────────┐');
Writeln(t,Space+'│N │Наименование продукции    │Предприятие-изготовитель │ Серия    │Сертификат                │Срок'+
'    │Кем выдан                               │');
Writeln(t,Space+'│  │                          │                         │          │                          │дейс'+
'твия│                                        │');
Writeln(t,Space+'└──┼──────────────────────────┼─────────────────────────┼──────────┼──────────────────────────┼────'+
'────┼────────────────────────────────────────┘');
                 {12│12345678901234567890123456│1234567890123456789012345│1234567890 12345678901234567890   │12345678│45
                             123456789012345678901234567890
                         │12378│123456789012345678901234567890│
                         12345│12345678│12345678│}

  For l:=1 To E^.Dat.Amount Do
    Begin
     ws:='';
     ws1:='';
{N}  st:=IntToStr(l,CMantissa);
     RFormat(st,3);
     ws:=ws+st;
    { format(st,CMantissa);
     ws:=ws+st; }
{Наименование товара}
     st:=GetIdField(FName,E^.Dat.MarketElement[l].BazKod);
     ws:=ws+Separator+Format(st,CName);
{Предприятие изготовитель}
     st:=GetPostField(FPost,BakGetField(FPost,E^.Dat.MarketElement[l].BazKod,0));
     ws:=ws+separator+format(st,25);
{Серия}
     st:=GetMarkaField(FMarka,BakGetField(FMarka,E^.Dat.MarketElement[l].BazKod,0));
     Delspace(st);
     ws:=ws+separator+Format(st,10);

{Сертификат}
     st:=GetIdField(FName,E^.Dat.MarketElement[l].Input.NSertif);
     ws:=ws+Separator+Format(st,CName);

{выдан}
(*
     st:='';
     ws:=ws+Separator+Format(st,8);
*)

{срок действия}
     st:=GetIdField(FDateSertif,E^.Dat.MarketElement[l].Input.NSertif);
     ws:=ws+Separator+Format(st,8);

{кем выдан}
     st:=GetKSertifField(FKSertif,GetIdField(FKtoSertif,E^.Dat.MarketElement[l].Input.NSertif));
     ws:=ws+Separator+Format(st,40);


  ws1:='';
  st:=GetIdField(FName2,E^.Dat.MarketElement[l].BazKod);
  DelSpaceRight(st);
  if st<>'' then
    begin
      st:=GetIdField(FName2,E^.Dat.MarketElement[l].BazKod);
      format(st,CName);
      ws1:='   │'+st;
      st:='';

      st:=GetIDField(FFirmaPost,E^.Dat.MarketElement[l].BazKod);
      DelSpace(st);
       if st<>NoPostStr then
        begin
         st:=GetFirmaPostField(FFirmaPost,st);
         ws1:=ws1+separator+Format(st,25);
        end
        else
        begin
         st:= ' ';
         ws1:=ws1+separator+Format(st,25);
        end;

       st:='';
       ws1:=ws1+separator+Format(st,10);
       st:='';

{Сертификат}
       st:=GetIdField(FName2,E^.Dat.MarketElement[l].Input.NSertif);
       ws1:=ws1+Separator+Format(st,CName);
(*
{выдан}
       st:='';
       ws1:=ws1+Separator+Format(st,8);
*)
{срок действия}
       st:='';
       ws1:=ws1+Separator+Format(st,8);

{кем выдан}
       st:='';
       ws1:=ws1+Separator+Format(st,40);


    end
    else
    begin
     st:='';
     st:=GetIDField(FFirmaPost,E^.Dat.MarketElement[l].BazKod);
     DelSpaceRight(st);
   if st<>NoPostStr then
   begin
      st:=GetIdField(FName2,E^.Dat.MarketElement[l].BazKod);
      format(st,CName);
      ws1:='   │'+st;
      st:='';
      st:=GetFirmaPostField(FFirmaPost,GetIDField(FFirmaPost,E^.Dat.MarketElement[l].BazKod));
      ws1:=ws1+separator+Format(st,25);
      st:='';
      ws1:=ws1+separator+Format(st,10);


       st:='';
       ws1:=ws1+separator+Format(st,CNAme);
(*
       st:='';
       ws1:=ws1+separator+Format(st,8);
*)
       st:='';
       ws1:=ws1+separator+Format(st,8);
       st:='';
       ws1:=ws1+separator+Format(st,40);
     end;
    end;

Writeln(t,Space+ws+Separator);

if ws1<>'' then Writeln(t,Space+ws1+Separator);

If l=E^.Dat.Amount Then
Writeln(t,Space+'───┴──────────────────────────┴─────────────────────────┴──────────┴──────────────────────────┴───────'+
'─┴────────────────────────────────────────┘')
Else
Writeln(t,Space+'───┼──────────────────────────┼─────────────────────────┼──────────┼──────────────────────────┼───────'+
'─┼────────────────────────────────────────┤');


    End;
Writeln(t,GlobalPrn^.Dat.NoCondensed[Nprint^.DAt.Printer]);


Writeln(t);
Writeln(t);
Writeln(t,Space+'       Поставщик ___________________    ');

   If E^.Dat.Rashet=2 Then Symbol:='-В'
           Else Symbol:='';

   Writeln(t);
{$IFDEF Pharm}
   DelSpaceRight(RekSF^.Dat.AdressCopySertif);
   Writeln(T,Space+GlobalPrn^.Dat.Normal[Nprint^.DAt.Printer]+
   GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+
   ' Документы, удостоверяющие качество вышеперечисленных лекарственных средств, хранятся на складе отправителя по адресу:'^M
   +Space+RekSF^.DAt.AdressCopySertif+' телефон:'+RekSF^.Dat.Telefon+
   GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]);
{$ENDIF}

   Writeln(t,Space+'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+
   ')'+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+
   GlobalPrn^.Dat.Double[Nprint^.DAt.Printer]+
   '                                                 '+
   'Тип документа: (',
   LeadingZero(E^.Dat.DocSelector),+Symbol+')'+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]+
   GlobalPrn^.Dat.NOBold[Nprint^.DAt.Printer]+
                                 GlobalPrn^.Dat.NoDouble[Nprint^.DAt.Printer]);

    Writeln(t,Space+'============================================================================================'+
    +GlobalPrn^.Dat.OrientNormal[Nprint^.DAt.Printer]+
    GlobalPrn^.Dat.Normal[Nprint^.DAt.Printer]);

NoInfoMsg;

Dispose(Rek1,Done);
End;

Procedure Ren(Path1,Path2:String);
Begin
  DoneSysError;
  DoneEvents;
  Application^.HideCursor;
  DoneDosMem;
  SWAPVECTORS;
  exec (Path^.Dat.ToUtils+'lfnrn.exe ',Path1+' '+Path2);
  SWAPVECTORS;
  InitDosMem;
  InitEvents;
  InitSysError;
  CursorLines:=1543;
  Application^.Redraw;
End;




Procedure ExportXLSNakl (As: DocumentEditZ);
Var f : MarketFileType;
    E : PSuperMarketType;
    Copy,l : Word;
    NDS,z,ItogoSkidka,Itogo,
    NDS20,NDS10,NDS_ : Float;
    s : String;
    ws : String[CName];
    koefficient : AllStr;
    pp : String[CPack];
    ws1 : TDateString;
    Find : Boolean;
    {DateMask : TDateString;}
    txt : Text;
    SDoc,SDate,Space : AllStr;
    Barter : String[CMantissa];
    ZakazNumer,ZakazDate,ZakazTime : AllStr;
    AllSum,NewSum  : Float;
    Separator : AllStr;
    FNames : AllStr;
    Skl : PSkladType;
    BBB,BBBS : PBazType;
    PS1,PS2 : PChar;
    OSD : PBox;
    RR : TRect;
    SA : ArtikulStr;
    F1 : File;
Begin
{$IFDEF DPMI}
 Space:='';
 Separator:=';';
 DInfoMsg('Ищу документ...',False);

 New(E,Init);
 If Not GetMarket1(As,E) Then
  Begin
   Dispose(E,Done);
   NoInfoMsg;
   Exit;
  End;


 l:=IOResult;
 FNames:=As.D;
 RazVorot(FNames);
 DelSpace(As.EditPosition);
 ClearChar(As.D);

 Assign(Txt,Path^.Dat.ToTemp+FNames+E^.Dat.ClientKod+'.'+As.EditPosition);
 l:=IOResult;
 Rewrite(Txt);
 l:=IOResult;
 If L <> 0 Then
  Begin
   NoInfoMsg;
   MessageBox(#3^M+#3'Не могу создать файл отчета '+Path^.Dat.ToTemp+FNames+
   E^.Dat.ClientKod+'.'+As.EditPosition+
   +' Код:'+IntToStr(l,3),Nil,mfError+mfCancelButton);
   Dispose(E,Done);
   Exit;
  End;

 NoInfoMsg;

 DInfomsg1('Экспортирую документ...',False);


Writeln(Txt,DosToWin('Оператор: '+E^.Dat.Caption+' Агент: '+E^.Dat.AgentKod+' EYE & 1997-00'));

If Not(E^.Dat.DAteM=E^.Dat.DAteC) Or Not(E^.Dat.TimeM=E^.Dat.TimeC) Then
Writeln(txt,Space{+'Последние изменения:'}+' '+E^.Dat.DAteM+'('+E^.Dat.TimeM+')');

If E^.Dat.OperatorSelector<>2 Then Barter[0]:=#0
Else Barter:='-Б';

SDoc:=E^.Dat.Document;
SDate:=E^.Dat.DateC;

   zakaznumer[0]:=#0;
   zakazDate[0]:=#0;
   zakazTime[0]:=#0;

{вариант для доставки-вино}
If ZakazShema=0 Then
Begin
   If E^.Dat.Oformlenie=1 Then
    Begin
     ZakazNumer:=E^.DAt.FromZakaz;
     DelSpace(ZakazNumer);
     ZakazNumer:='ЗЛ '+ZakazNumer+'/';
     ZakazDate:=GetZakazDate(E^.DAt.FromZakaz,FieldEndDate);
     If ZakazDate='' Then ZakazDate:=E^.Dat.DateC;
     ZakazTime:=GetZakazDate(E^.DAt.FromZakaz,FieldTime);
     If ZakazTime='' Then ZakazTime:=E^.Dat.TimeC;
    End
    Else
     Begin
      ZakazDate:=E^.Dat.DateC;
      ZakazTime:=E^.Dat.TimeC;
     End;
End
 Else
  Begin
      ZakazDate:=E^.Dat.DateC;
      ZakazTime:=E^.Dat.TimeC;
  End;



 WriteLn(Txt,DosToWin('Экспедитор: '+GetEkspedField(FAgent,E^.Dat.EkspeditorKod)));

 Writeln(Txt,DosToWin('                   Д О К У М Е Н Т  N '+ZakazNumer+SDoc+BArter+
   '/'+IntToStr(StrToInt(E^.Dat.SkladKod),CMantissa)
    +' от '+ZakazDate{As.D}+' ('+
    ZakazTime+')'));

If E^.Dat.Oformlenie=1 Then
Begin
Writeln(txt ,DosToWin(SDoc+BArter+'/'+IntToStr(StrToInt(E^.Dat.SkladKod),CMantissa)+
' '+SDate+' ('+E^.Dat.TimeC+')'));
End;

    Writeln(Txt,DosToWin('Получатель: '+GetClientField(FFullClient,E^.Dat.ClientKod,E^.Dat.OperatorSelector)+' ('+
    E^.Dat.ClientKod+')'));
    If E^.Dat.DocSelector in [3,4,6,8] Then
    Begin
    Writeln(Txt,DosToWin('Поставщик: '+RekSF^.Dat.Name)+Separator+DosToWin(E^.Dat.Comment1));
    Writeln(txt,DosToWin('Адрес: '+RekSF^.Dat.Adress)+Separator+DosToWin(E^.Dat.Comment2));
    End
    Else
     Begin
      Writeln(Txt,DosToWin('Поставщик: '+Rek^.Dat.Name)+Separator+DosToWin(E^.Dat.Comment1));
      Writeln(txt,DosToWin('Адрес: '+Rek^.Dat.Adress)+Separator+DosToWin(E^.Dat.Comment2));
     End;

   If E^.Dat.SkidkaSelector=0 Then Writeln(txt,DosToWin('Скидка: Авто '))
   Else Writeln(txt,DosToWin('Скидка: Ручная'));

   Writeln(txt,DosToWin('Тип документа: ('+IntToStr(E^.Dat.DocSelector,CMantissa)+')'));



   If (E^.Dat.Versia>1) And ((Not(E^.Dat.Realiz)) Or ((E^.Dat.Realiz)And Not(E^.Dat.DocSelector in [0,1,2,3,4])))
     Then
    Begin
     Writeln(txt,DosToWin('Версия: '+IntToStr(E^.Dat.Versia,CLitrMantissa)));
    End;

   If E^.Dat.Oformlenie=1 Then
    Begin
     ZakazNumer[0]:=#0;
     ZakazNumer:=E^.DAt.FromZakaz;
     DelSpace(ZakazNumer);
     ZakazNumer:='ЗЛ '+ZakazNumer+'/';
     Writeln(txt,DosToWin('По заказу N '+E^.DAt.FromZakaz));
    End;


 Writeln(txt,DosToWin('п/н'+Separator+'Код'+Separator+'Наименование товара'+Separator+'Фасовка'+Separator+
             'Количество,шт'+Separator+'Упаковок'+Separator+'Цена'+Separator+'Сумма'+Separator+
             'Отделение'+Separator+
             'Ставка НП'+Separator+'Ставка НДС'+Separator+'Страна происхождения'+Separator+
             'Фирма производитель'+Separator+'Номер ГТД'+Separator+Seria_Akzis^+Separator+
             'Сертификат'+Separator+'Выдан'+Separator+'Действителен до'+Separator+'Штрихкод'));


RR.Assign(0, 0, 0, 0);
OSD := New(PBox, Init(RR, 1, Nil));
OSD^.NewList(New(PTextCollection, Init(0,1)));
{создаем список сопроводительных документов в накладной}
Creat_OSD(E,OSD);


   For l:=1 To E^.Dat.Amount Do
    Begin
     Str(l:CMantissa,S);
     Write(txt,S+Separator);

  New(Skl,Init);
  New(BBB,Init);
  New(BBBS,Init);

     Skl^.Dat.BazKod:=E^.Dat.MarketElement[l].BazKod;
     GetSkladRecord(Skl);

     {подставляем СД из накладной расхода}
     If MarketSD=0 Then GetOLD_OSD(OSD,Skl);

     GetBazElement(E^.Dat.MarketElement[l].BazKod,BBB^.Dat);
     GetBazElement(E^.Dat.MarketElement[l].Input.NSertif,BBBS^.Dat);

     If E^.Dat.SkidkaSelector=0 Then{Если автомат}
       MyStr((StrToReal(E^.Dat.MarketElement[l].Input.Zena)/
       (1+StrToReal(E^.Dat.MarketElement[l].Input.Proz)/100)),CZena,CMantissa,ws)
     Else
       MyStr((StrToReal(E^.Dat.MarketElement[l].Input.Zena)-StrToReal(E^.Dat.MarketElement[l].Input.Skidka))
       ,CZena,CMantissa,ws);

       {отключен расчет налога с продажи в товарном чеке}
       If E^.DAt.DocSelector in [2,3,5,6] Then
       Begin
        Mystr(((1+strtoreal(e^.dat.marketelement[l].Input.SpecNalog)
               /100)),CLitr,CMantissa,koefficient);
{$IFDEF NSP}
        MyStr(StrToReal(ws),CZena,CMantissa,ws);
{$ELSE}
        MyStr(StrToReal(ws)*StrToReal(Koefficient),CZena,CMantissa,ws);
{$ENDIF}
       End;

{$IFDEF PHARM}
  SA:=GetIdField(FMain,E^.Dat.MarketElement[l].BazKod);
  If StrToInt(SA)=0 Then SA:=E^.Dat.MarketElement[l].BazKod
  Else SA:=GetIdField(FFantomKod,E^.Dat.MarketElement[l].BazKod);
{$ELSE}
  SA:=E^.Dat.MarketElement[l].BazKod;
{$ENDIF}

  Write(txt,DosToWin({E^.Dat.MarketElement[l].BazKod}
  SA+
  +Separator+BBB^.Dat.Name+' '+BBB^.Dat.Name2+Separator+BBB^.Dat.InPack+
  Separator+E^.Dat.MarketElement[l].Input.Kol+Separator+CalcPackNoFile(BBB^.Dat.InPack,E^.Dat.MarketElement[l].Input.Kol)+
  Separator+ws+Separator+RealToStr(StrToReal(ws)*StrToInt(E^.Dat.MarketElement[l].Input.Kol),CIZena,CMantissa)+
  Separator+IntToStr(E^.Dat.MarketElement[l].Input.DivisionNumber,COne)+Separator+BBB^.Dat.Nalog+
  Separator+BBB^.Dat.NDS+Separator+GetPostField(FPost,BBB^.Dat.PostKod)+Separator+
  GetFirmaPostField(FPost,BBB^.Dat.FirmaPostKod)+
  Separator+GetNGTDField(FNGTD,Skl^.Dat.Input.NGTD)+Separator+
  GetMarkaField(FMarka,Skl^.Dat.Input.Marka)+Separator));
  Write(txt,DosToWin(BBBS^.Dat.Name+' '+BBBS^.Dat.Name2+Separator+BBBS^.Dat.KSertif+Separator+BBBS^.Dat.DSertif+Separator+
  '['+Skl^.Dat.Input.StrihKod+']'));

  WriteLn(txt);

  Dispose(Skl,Done);
  Dispose(BBB,Done);
  Dispose(BBBS,Done);
    End;{For}

  WriteLn(txt,Separator+' '+Separator+' '+Separator+' '+Separator+' '+Separator+' '+Separator+DosToWin('К оплате:')+Separator+
  DosToWin(E^.Dat.SummaZ));
  WriteLn(txt,DosToWin(Separator+' '+Separator+FDate+' '+Times));




 l:=IOResult;
 Close(Txt);
 l:=IOResult;

 Ren(Path^.Dat.ToTemp+FNames+E^.Dat.ClientKod+'.'+As.EditPosition,
 +PathExpImp^.Dat.ToExport[1]+'Doc_N_'+
 E^.Dat.Document+'('+IntToStr(E^.Dat.Versia,CLitrMantissa)+')'+'_'+E^.Dat.DAteC+
 '_Client_('+E^.Dat.ClientKod+').csv');

 NoInfoMsg;
 MessageBox(#3'Экспорт документа успешно завершен! Данные помещены в файл '+
 PathExpImp^.Dat.ToExport[1]+'Doc_N_'+
 E^.Dat.Document+'('+IntToStr(E^.Dat.Versia,CLitrMantissa)+')'+'_'+E^.Dat.DAteC+
 '_Client_('+E^.Dat.ClientKod+').csv',
 Nil,mfInformation+mfCancelButton);

 Dispose(E,Done);
 Dispose(OSD,Done);

{$ENDIF}

End;



Procedure AutoExportXLSNakl (As: DocumentEditZ);
Var f : MarketFileType;
    E : PSuperMarketType;
    Copy,l : Word;
    NDS,z,ItogoSkidka,Itogo,
    NDS20,NDS10,NDS_ : Float;
    s : String;
    ws : String[CName];
    koefficient : AllStr;
    pp : String[CPack];
    ws1 : TDateString;
    Find : Boolean;
    {DateMask : TDateString;}
    txt : Text;
    SDoc,SDate,Space : AllStr;
    Barter : String[CMantissa];
    ZakazNumer,ZakazDate,ZakazTime : AllStr;
    AllSum,NewSum  : Float;
    Separator : AllStr;
    FNames : AllStr;
    Skl : PSkladType;
    BBB,BBBS : PBazType;
    PS1,PS2 : PChar;
    OSD : PBox;
    RR : TRect;
    Cl : PClientType;
    Sa : ArtikulStr;
    F1 : File;
Begin
{$IFDEF DPMI}
 Space:='';
 Separator:=';';
 DInfoMsg('Ищу документ...',False);

 New(E,Init);
 If Not GetMarket1(As,E) Then
  Begin
   Dispose(E,Done);
   NoInfoMsg;
   Exit;
  End;


 New(Cl,Init);

 Cl^.DAt.Kod:=E^.DAt.ClientKod;

 GetClient(Cl,E^.DAt.OperatorSelector);

 If Not (Cl^.Dat.Dopolnenie.EnableExport=1) Then
  Begin
   Dispose(E,Done);
   Dispose(Cl,Done);
   NoInfoMsg;
   Exit;
  End;

 NoInfoMsg;

{$IFDEF Pharm}
 If Not AutoAnswer(^M+#3'Произвести экспорт документа в каталог почты клиента?') Then
{$ELSE}
 If Not AutoAnswer(^M+#3'Произвести экспорт документа?') Then
{$ENDIF}
  Begin
   Dispose(E,Done);
   Dispose(Cl,Done);
   NoInfoMsg;
   Exit;
  End;

 RFormatZerro(Cl^.Dat.Kod,CClientKod);
 l:=IOResult;
 FNames:=As.D;
 RazVorot(FNames);
 DelSpace(As.EditPosition);
 ClearChar(As.D);


 Assign(Txt,Path^.Dat.ToTemp+FNames+Cl^.Dat.Kod+'.'+As.EditPosition);
 l:=IOResult;
 Rewrite(Txt);
 l:=IOResult;
 If L <> 0 Then
  Begin
   NoInfoMsg;
   MessageBox(#3^M+#3'Не могу создать файл отчета '+
   Path^.Dat.ToTemp+FNames+Cl^.Dat.Kod+'.'+As.EditPosition+
   +' Код:'+IntToStr(l,3),Nil,mfError+mfCancelButton);
   Dispose(E,Done);
   Dispose(Cl,Done);
   Exit;
  End;

 NoInfoMsg;


 DInfomsg1('Экспортирую документ...',False);


Writeln(Txt,DosToWin('Оператор: '+E^.Dat.Caption+' Агент: '+E^.Dat.AgentKod+' EYE & 1997-00'));

If Not(E^.Dat.DAteM=E^.Dat.DAteC) Or Not(E^.Dat.TimeM=E^.Dat.TimeC) Then
Writeln(txt,Space{+'Последние изменения:'}+' '+E^.Dat.DAteM+'('+E^.Dat.TimeM+')');

If E^.Dat.OperatorSelector<>2 Then Barter[0]:=#0
Else Barter:='-Б';

SDoc:=E^.Dat.Document;
SDate:=E^.Dat.DateC;

   zakaznumer[0]:=#0;
   zakazDate[0]:=#0;
   zakazTime[0]:=#0;

{вариант для доставки-вино}
If ZakazShema=0 Then
Begin
   If E^.Dat.Oformlenie=1 Then
    Begin
     ZakazNumer:=E^.DAt.FromZakaz;
     DelSpace(ZakazNumer);
     ZakazNumer:='ЗЛ '+ZakazNumer+'/';
     ZakazDate:=GetZakazDate(E^.DAt.FromZakaz,FieldEndDate);
     If ZakazDate='' Then ZakazDate:=E^.Dat.DateC;
     ZakazTime:=GetZakazDate(E^.DAt.FromZakaz,FieldTime);
     If ZakazTime='' Then ZakazTime:=E^.Dat.TimeC;
    End
    Else
     Begin
      ZakazDate:=E^.Dat.DateC;
      ZakazTime:=E^.Dat.TimeC;
     End;
End
 Else
  Begin
      ZakazDate:=E^.Dat.DateC;
      ZakazTime:=E^.Dat.TimeC;
  End;



 WriteLn(Txt,DosToWin('Экспедитор: '+GetEkspedField(FAgent,E^.Dat.EkspeditorKod)));

 Writeln(Txt,DosToWin('                   Д О К У М Е Н Т  N '+ZakazNumer+SDoc+BArter+
   '/'+IntToStr(StrToInt(E^.Dat.SkladKod),CMantissa)
    +' от '+ZakazDate{As.D}+' ('+
    ZakazTime+')'));

If E^.Dat.Oformlenie=1 Then
Begin
Writeln(txt ,DosToWin(SDoc+BArter+'/'+IntToStr(StrToInt(E^.Dat.SkladKod),CMantissa)+
' '+SDate+' ('+E^.Dat.TimeC+')'));
End;

    Writeln(Txt,DosToWin('Получатель: '+GetClientField(FFullClient,E^.Dat.ClientKod,E^.Dat.OperatorSelector)+' ('+
    E^.Dat.ClientKod+')'));
    If E^.Dat.DocSelector in [3,4,6,8] Then
    Begin
    Writeln(Txt,DosToWin('Поставщик: '+RekSF^.Dat.Name)+Separator+DosToWin(E^.Dat.Comment1));
    Writeln(txt,DosToWin('Адрес: '+RekSF^.Dat.Adress)+Separator+DosToWin(E^.Dat.Comment2));
    End
    Else
     Begin
      Writeln(Txt,DosToWin('Поставщик: '+Rek^.Dat.Name)+Separator+DosToWin(E^.Dat.Comment1));
      Writeln(txt,DosToWin('Адрес: '+Rek^.Dat.Adress)+Separator+DosToWin(E^.Dat.Comment2));
     End;

   If E^.Dat.SkidkaSelector=0 Then Writeln(txt,DosToWin('Скидка: Авто '))
   Else Writeln(txt,DosToWin('Скидка: Ручная'));

   Writeln(txt,DosToWin('Тип документа: ('+IntToStr(E^.Dat.DocSelector,CMantissa)+')'));



   If (E^.Dat.Versia>1) And ((Not(E^.Dat.Realiz)) Or ((E^.Dat.Realiz)And Not(E^.Dat.DocSelector in [0,1,2,3,4])))
     Then
    Begin
     Writeln(txt,DosToWin('Версия: '+IntToStr(E^.Dat.Versia,CLitrMantissa)));
    End;

   If E^.Dat.Oformlenie=1 Then
    Begin
     ZakazNumer[0]:=#0;
     ZakazNumer:=E^.DAt.FromZakaz;
     DelSpace(ZakazNumer);
     ZakazNumer:='ЗЛ '+ZakazNumer+'/';
     Writeln(txt,DosToWin('По заказу N '+E^.DAt.FromZakaz));
    End;


 Writeln(txt,DosToWin('п/н'+Separator+'Код'+Separator+'Наименование товара'+Separator+'Фасовка'+Separator+
             'Количество,шт'+Separator+'Упаковок'+Separator+'Цена'+Separator+'Сумма'+Separator+
             'Отделение'+Separator+
             'Ставка НП'+Separator+'Ставка НДС'+Separator+'Страна происхождения'+Separator+
             'Фирма производитель'+Separator+'Номер ГТД'+Separator+Seria_Akzis^+Separator+
             'Сертификат'+Separator+'Выдан'+Separator+'Действителен до'+Separator+'Штрихкод'));


RR.Assign(0, 0, 0, 0);
OSD := New(PBox, Init(RR, 1, Nil));
OSD^.NewList(New(PTextCollection, Init(0,1)));
{создаем список сопроводительных документов в накладной}
Creat_OSD(E,OSD);


   For l:=1 To E^.Dat.Amount Do
    Begin
     Str(l:CMantissa,S);
     Write(txt,S+Separator);

  New(Skl,Init);
  New(BBB,Init);
  New(BBBS,Init);

     Skl^.Dat.BazKod:=E^.Dat.MarketElement[l].BazKod;
     GetSkladRecord(Skl);

     {подставляем СД из накладной расхода}
     If MarketSD=0 Then GetOLD_OSD(OSD,Skl);

     GetBazElement(E^.Dat.MarketElement[l].BazKod,BBB^.Dat);
     GetBazElement(E^.Dat.MarketElement[l].Input.NSertif,BBBS^.Dat);

     If E^.Dat.SkidkaSelector=0 Then{Если автомат}
       MyStr((StrToReal(E^.Dat.MarketElement[l].Input.Zena)/
       (1+StrToReal(E^.Dat.MarketElement[l].Input.Proz)/100)),CZena,CMantissa,ws)
     Else
       MyStr((StrToReal(E^.Dat.MarketElement[l].Input.Zena)-StrToReal(E^.Dat.MarketElement[l].Input.Skidka))
       ,CZena,CMantissa,ws);

       {отключен расчет налога с продажи в товарном чеке}
       If E^.DAt.DocSelector in [2,3,5,6] Then
       Begin
        Mystr(((1+strtoreal(e^.dat.marketelement[l].Input.SpecNalog)
               /100)),CLitr,CMantissa,koefficient);
{$IFDEF NSP}
        MyStr(StrToReal(ws),CZena,CMantissa,ws);
{$ELSE}
        MyStr(StrToReal(ws)*StrToReal(Koefficient),CZena,CMantissa,ws);
{$ENDIF}
       End;

{$IFDEF PHARM}
  SA:=GetIdField(FMain,E^.Dat.MarketElement[l].BazKod);
  If StrToInt(SA)=0 Then SA:=E^.Dat.MarketElement[l].BazKod
  Else SA:=GetIdField(FFantomKod,E^.Dat.MarketElement[l].BazKod);
{$ELSE}
  SA:=E^.Dat.MarketElement[l].BazKod;
{$ENDIF}



  Write(txt,DosToWin({E^.Dat.MarketElement[l].BazKod}
  SA+Separator+BBB^.Dat.Name+' '+BBB^.Dat.Name2+Separator+BBB^.Dat.InPack+
  Separator+E^.Dat.MarketElement[l].Input.Kol+Separator+CalcPackNoFile(BBB^.Dat.InPack,E^.Dat.MarketElement[l].Input.Kol)+
  Separator+ws+Separator+RealToStr(StrToReal(ws)*StrToInt(E^.Dat.MarketElement[l].Input.Kol),CIZena,CMantissa)+
  Separator+IntToStr(E^.Dat.MarketElement[l].Input.DivisionNumber,COne)+Separator+BBB^.Dat.Nalog+
  Separator+BBB^.Dat.NDS+Separator+GetPostField(FPost,BBB^.Dat.PostKod)+Separator+
  GetFirmaPostField(FPost,BBB^.Dat.FirmaPostKod)+
  Separator+GetNGTDField(FNGTD,Skl^.Dat.Input.NGTD)+Separator+
  GetMarkaField(FMarka,Skl^.Dat.Input.Marka)+Separator));
  Write(txt,DosToWin(BBBS^.Dat.Name+' '+BBBS^.Dat.Name2+Separator+BBBS^.Dat.KSertif+Separator+BBBS^.Dat.DSertif+Separator+
  '['+Skl^.Dat.Input.StrihKod+']'));

  WriteLn(txt);

  Dispose(Skl,Done);
  Dispose(BBB,Done);
  Dispose(BBBS,Done);
    End;{For}

  WriteLn(txt,Separator+' '+Separator+' '+Separator+' '+Separator+' '+Separator+' '+Separator+DosToWin('К оплате:')+Separator+
  DosToWin(E^.Dat.SummaZ));
  WriteLn(txt,DosToWin(Separator+' '+Separator+FDate+' '+Times));




 l:=IOResult;
 Close(Txt);
 l:=IOResult;


 Ren(Path^.Dat.ToTemp+FNames+E^.Dat.ClientKod+'.'+As.EditPosition,
 +Cl^.DAt.Dopolnenie.MailPath+Cl^.DAt.Kod+'\OUT\'+'Doc_N_'+
 E^.Dat.Document+'('+IntToStr(E^.Dat.Versia,CLitrMantissa)+')'+'_'+E^.Dat.DAteC+
 '_Client_('+IntToStr(E^.Dat.OperatorSelector,COne)+E^.Dat.ClientKod+').txt');

 NoInfoMsg;
 MessageBox(#3'Экспорт документа успешно завершен! Данные помещены в файл '+
 Cl^.DAt.Dopolnenie.MailPath+Cl^.DAt.Kod+'\OUT\'+'Doc_N_'+
 E^.Dat.Document+'('+IntToStr(E^.Dat.Versia,CLitrMantissa)+')'+'_'+E^.Dat.DAteC+
 '_Client_('+IntToStr(E^.Dat.OperatorSelector,COne)+E^.Dat.ClientKod+').txt',
 Nil,mfInformation+mfCancelButton);

 Dispose(E,Done);
 Dispose(OSD,Done);
 Dispose(Cl,Done);

{$ENDIF}

End;






Function TestElementSpis (Const S : ArtikulStr;Const P : PBox;Const Sort:Word) : Boolean;
Var ls : Word;
    k  : Byte;
    st : String[CALL];
Begin
TestElementSpis:=False;
For ls :=0 To P^.List^.Count-1 Do
Begin
St:=P^.GetText(ls,P^.List^.Count);
k:=Pos('│',St);
If Sort=1 Then
ST:=Copy(St,K+1,CRazdelKod) Else ST:=Copy(St,1,CRazdelKod);
If St=S Then
   Begin
    TestElementSpis:=True;
    Break;
   End;
End;
End;



Procedure CompressReport(Start,Stop:LongInt;Cl:Word;Const TL:PBox;Regim:Word);
Var i,j,l,currentday,max,CurrentWeek,Current,Pos : LongInt;
    WL : PBox;
    MyDate,ws,temps,s : TMyString;
    Itg : PBufNewItogType;
    OneItg : PNewItogType;
    WeekFile : File Of NewItogType;
    ItogFile : File;
    r1 : trect;
    Reiting,SumKol,Ext,Space : TEnJoyStr;
    cc,Count1 : Word;

Begin

 For currentWeek:=1 To 8 Do
 Begin
  Str(CurrentWeek:1,TempS);
  Assign(WeekFile,Path^.Dat.ToTemp+TEmps+'.w'+TempS);
  i:=IOResult;
  Rewrite(WeekFile);
  i:=IOResult;
  Close(WeekFile);
  i:=IOResult;
 End;

  currentDay:=start;
  currentWeek:=1;
  current:=start;

  while current<stop do
begin
 Str(CurrentWeek:1,TempS);
 Assign(WeekFile,Path^.Dat.ToTemp+TEmps+'.w'+TempS);
 i:=IOResult;
 Rewrite(WeekFile);
 i:=IOResult;
  If i=0 Then
    Begin
     {цикл расчета итогов за неделю}
      R1.Assign(0,0,0,0);
      Wl := New(PBox, Init(R1, 1, Nil));
      WL^.NewList(New(PTextCollection, Init(0,1)));
      max:=Current+6;
       For Current:=Current To Max Do
        Begin
         Str(StrToInt(Rek^.Dat.Kod):2,Ext);
         RFormatZerro(Ext,2);
         s:=DAteToDAteString(DateMask,Current);
         MyDate:=S;
         ClearChar(MyDate);
         Assign(ItogFile,Path^.Dat.ToArchiv+MyDate+'.p'+Ext);
         i:=IOResult;
         OldFileMode:=FileMode;
         FileMode:=$42;
         Reset(ItogFile,SizeOf(NewitogType));
         i:=IOResult;
         FileMode:=OldFileMode;
         If i=0 Then
          Begin
           While Not(Eof(ItogFile)) Do
            Begin

    New(Itg,Init);
    Count1:=0;
    BlockRead(ItogFile,Itg^.Point,BufItg,Count1);

    For cc:=1 To Count1 Do
Begin
If TestElementSpis (Copy(Itg^.Point.Dat[cc].BAzKod,1,CRAzdelKod),TL,regim) Then
Begin
    If Not(TestElement(Itg^.Point.Dat[cc].BAzKod,WL)) Then
    Begin

               Pos:= Location(WL,Itg^.Point.Dat[cc].BAzKod,False);
               ws := WL^.GetText(pos,WL^.List^.Count);
               s:=Copy(ws,1+CName+1+CArtikul+1,Ckol);
               temps:=Copy(ws,1+CName+1+CArtikul+1+CKol+1,Ckol);
               {обрезаем строку}
               ws[0]:=chr(1+CName+1+CArtikul);
               {складываем продажи}

               {Str(StrToInt(s)+StrToInt(Itg^.Dat.MrkC):Ckol,s);}

          Case Cl Of
          0:Str(StrToInt(s)+StrToInt(Itg^.Point.Dat[cc].MrkC):CKol,s);{клиент}
          1:Str(StrToInt(s)+StrToInt(Itg^.Point.Dat[cc].MrkS):CKol,s);{склад}
          2:Str(StrToInt(s)+StrToInt(Itg^.Point.Dat[cc].MrkB):CKol,s);{бартер}
          3:Str(StrToInt(s)+StrToInt(Itg^.Point.Dat[cc].MrkC)+StrToInt(Itg^.Point.Dat[cc].MrkS)+
                StrToInt(Itg^.Point.Dat[cc].MrkB):CKol,s);
          Else;
          End;


               {запоминаем последние остатки}
           If (Current=Stop) Then
            Begin
            Str(StrToInt(Itg^.Point.Dat[cc].Ost):Ckol,temps);
            End
            Else TempS[0]:=#0;

               ws:=ws+s+'│'+Temps;

               WL^.List^.AtFree(Pos);
               WL^.SetRange(WL^.List^.Count);

               WL^.List^.Insert(NewStr(ws));
               WL^.SetRange(WL^.List^.Count);
    End
             Else
    Begin
               ws:=GetIdField(FNAme,Itg^.Point.Dat[cc].BAzKod);
               Format(ws,CNAme);


               ws:=ws+'│'+Itg^.Point.Dat[cc].BAzKod+'│';
               Str(StrToInt(Itg^.Point.Dat[cc].MrkC):CKol,Itg^.Point.Dat[cc].MrkC);

          Case Cl Of
          0:Str(StrToInt(Itg^.Point.Dat[cc].MrkC):CKol,Itg^.Point.Dat[cc].MrkC);{клиент}
          1:Str(StrToInt(Itg^.Point.Dat[cc].MrkS):CKol,Itg^.Point.Dat[cc].MrkC);{склад}
          2:Str(StrToInt(Itg^.Point.Dat[cc].MrkB):CKol,Itg^.Point.Dat[cc].MrkC);{бартер}
          3:Str(StrToInt(Itg^.Point.Dat[cc].MrkC)+StrToInt(Itg^.Point.Dat[cc].MrkB)+
                StrToInt(Itg^.Point.Dat[cc].MrkS):CKol,Itg^.Point.Dat[cc].MrkC);
          Else;
          End;

               Str(StrToInt(Itg^.Point.Dat[cc].Ost):CKol,Itg^.Point.Dat[cc].Ost);

               If (Current=Stop) Then
               Str(StrToInt(Itg^.Point.Dat[cc].Ost):Ckol,temps)
               Else
                        TempS[0]:=#0;

               ws:=ws+Itg^.Point.Dat[cc].MrkC+'│'+TempS;
               WL^.List^.Insert(NewStr(ws));
               WL^.SetRange(WL^.List^.Count);
   End;

End;{If TestElementSpis}
  End;{For}
   Dispose(Itg,Done);


 End;{While Not Eof(ItogFile)}

           Close(ItogFile);
          End;{ioresult=0}

        End;{for current}


       If WL^.List^.Count>=1 Then
        Begin
         New(OneItg,Init);
         For l:=0 To WL^.List^.Count-1 Do
          Begin
           OneItg^.Dat.MrkC[0]:=#0;
           OneItg^.Dat.MrkS[0]:=#0;
           OneItg^.Dat.MrkB[0]:=#0;
           OneItg^.Dat.Ost[0]:=#0;
           ws:=WL^.GetText(l,WL^.List^.Count);
           OneItg^.Dat.BazKod:=Copy(ws,1+CName+1,CArtikul);
           OneItg^.Dat.MrkC:=Copy(ws,1+CName+1+CArtikul+1,CKol);
           OneItg^.Dat.Ost:=Copy(ws,1+CName+1+CArtikul+1+CKol+1,CKol);
           Str(StrToInt(OneItg^.Dat.Ost):CKol,OneItg^.Dat.Ost);
           Str(StrToInt(OneItg^.Dat.MrkC):CKol,OneItg^.Dat.MrkC);

           Seek(WeekFile,FileSize(WeekFile));
           Write(WeekFile,OneItg^.Dat);
          End;{For по списку}
         Dispose(OneItg,Done);
        End;{WspomList}
      Dispose(WL,Done);
      Close(WeekFile);
    End;{IOResult=0}
 inc(current);
 inc(CurrentWeek);
end;{While}

End;



Procedure RashetProdag(Const Spis:PBox;Const M:Maska8;Const Assort,Sort:Word);
              {123456123456123456123456123456123456123456123456123456}
Var R,R1 : TRect;
    Txt : Text;
    MyDate,rs,Shablon,s1,RazdelName,Fas,TempArtikul,s,ss : TMyString;
    OstKKK,OstKKKOutBron,ws,ws1,ws2 : String;
    Reiting,SumKol,Ext,Space : TEnJoyStr;
    TempList : PBox;
    WspomList1,WspomList: PBox;
    EdIzm,Regim : Word;
    Separator : ArtikulStr;
    SInPack,MarketKol,MarketPack:string[CPack];
    Art,PositionZena,Date : TDateString;
    l,l1,EE,EE1 : LongInt;
    Pos,j,i,Srok,Day: Word;
    Start : TDAteString;
    Itg : PBufNewItogType;
    ItogFile  : File;{ Of NewItogType;}
    Cl : Word;
    Shapka : Array [1..4] Of String;
    KurzDAte,SZena,Seria,Firma,Strana :AllStr;
    Extend : Boolean;
    cc,Count1 : Word;

Begin
 Separator:=' ';
 Assign(Txt,Path^.Dat.ToTemp+'mrk_ost.txt');
 l:=IOResult;
 Rewrite(Txt);
 l:=IOResult;
 If L <> 0 Then
  Begin
   MessageBox(#3^M+#3'Не могу создать файл отчета '+Path^.Dat.ToTemp+'mrk_ost.txt',Nil,mfError+mfCancelButton);
   {Dispose(Spis,Done);}
   Exit;
  End;
 Close(txt);


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
      Dispose(TempList,Done);
      Exit;
     End;

   Else;
   End;


If Not SelectVidOstatkiMarket(Day,Srok,Start) Then
 Begin
      Dispose(TempList,Done);
      Exit;
 End;

 If Start=FDate Then
  Begin

  s1:=FormKod(Rek^.Dat.Kod);
  Delete(s1,1,2);
  KurzDAte:=FDate;
  ClearChar(KurzDate);

  If FExists(Path^.Dat.ToArchiv+KurzDate+'.p'+s1) Then
   Begin
   If MessageBox(^M+#3'Произвести пересчет информации в архиве текущего дня?',nil,mfConfirmation+mfOkCancel)=cmOk Then
   if Not CreatNewKurzReportFile(Start) then
    Begin
     Dispose(TempList,Done);
     Exit;
    End;
   End
   Else
    Begin
     if Not CreatNewKurzReportFile(Start) then
      Begin
       Dispose(TempList,Done);
       Exit;
      End;
    End;
  End;


 EdIzm:=SelectImport(2);
      If EdIzm=2 Then
      Begin
        Dispose(TempList,Done);
        Exit;
      End;

 Cl:=SelectSpecify(FAlse,5);
      If Cl=4 Then
      Begin
        Dispose(TempList,Done);
        Exit;
      End;


  DInfo('Анализирую остатки и продажи...');
  Append(txt);
  Space:='   ';
  Writeln(Txt,Header+Space+'Склад:'+FormKod(Rek^.Dat.Kod)+' Оператор: '+CurrentPassword);
  Writeln(Txt,Space+'Дата и время расчета: '+FDate+'  ('+Times+')');
  Write(Txt,Space+'Вид отбора отгрузки: ');
  Case Cl Of
  3:Writeln(txt,'{Все}');
  0:Writeln(txt,'{Клиент}');
  1:Writeln(txt,'{Склад}');
  2:Writeln(txt,'{Обмен}');
  Else Writeln(txt);
  End;
  Write(Txt,Space+'Вид сортировки товара: ');
  Case Sort Of
  1:Writeln(txt,'{По наименованию}');
  0:Writeln(txt,'{По кодам}');
  Else Writeln(txt);
  End;

  Write(Txt,Space+'Вид сортировки разделов: ');
  Case Regim Of
  1:Writeln(txt,'{По наименованиям разделов}');
  0:Writeln(txt,'{По кодам разделов}');
  Else Writeln(txt);
  End;
  Write(Txt,Space+'Единицы измерения: ');
  Case EdIzm Of
  0:Writeln(txt,'{Штуки}');
  1:Writeln(txt,'{Упаковки}');
  Else Writeln(txt);
  End;
  Writeln(txt);

 s:=' Код '+SeparatorChar+'Наименование товара      '+SeparatorChar+' Фас';
    {12345 12345678901234567890123456 123}
s1:='                                    ';
EE:=DateStringToDate(DateMask,Start);
if day=0 then
EE1:=EE-Srok+1{чтобы учесть текущий день}
else
EE1:=EE-Srok*7+1;

Space:='    ';
Shablon[0]:=#0;
Writeln(Txt,Space+' ВЕДОМОСТЬ ОСТАТКОВ и ОТГРУЗКИ ТОВАРА за период с '+DAteToDateString(DAteMask,EE1)+' по '+Start);
If Day=0 Then
Writeln(Txt,Space+' Количество дней в расчете: ',Srok:1)
Else
Writeln(Txt,Space+' Количество недель в расчете: ',Srok:1);

Writeln(Txt,Space+'{Обозначения: "-" нет остатков  "?" нет данных}');

Writeln(Txt,Space+GlobalPrn^.Dat.Condensed[Nprint^.DAt.Printer]);


    Str(StrToInt(Rek^.Dat.Kod):2,Ext);
    RFormatZerro(Ext,2);

if day=1 then CompressReport(EE1,EE,Cl,TempList,Regim);



Space:='    ';
j:=1;
For l:=EE1 To EE Do
Begin
ws:=DAteToDAteString('  dd.mm  ',l);
If Day=1 Then ws[1]:='с';
s:=s+SeparatorChar+ws;
if day=1 then
  Begin
   ss:=inttostr(j,COne);
   Format(ss,CMantissa);
  End
else
  ss:=DayString[DayOfWeek(l)];
ss:='    '+ss+'   ';
s1:=s1+' '+ss;
If Day=0 Then
Begin
MyDate:=DAteToDAteString(DateMask,l);
ClearChar(MyDAte);
If Not(FExists(Path^.Dat.ToArchiv+MyDAte+'.p'+Ext)) Then
Shablon:=Shablon+'    ?    '+' '
Else
Shablon:=Shablon+'    -    '+' ';
End
 Else
  Begin
If Not(FExists(Path^.Dat.ToTemp+IntToStr(j,COne)+'.w'+IntToStr(j,COne))) Then
Shablon:=Shablon+'    ?    '+' '
Else
Shablon:=Shablon+'    -    '+' ';
inc(l,6);
if l>ee then break;
  End;
inc(j);
End;

if day=0 then
begin
MyDate:=DAteToDAteString(DateMask,EE);
ClearChar(MyDAte);
If Not(FExists(Path^.Dat.ToArchiv+MyDate+'.p'+Ext)) Then
Shablon:=Shablon+'    ?    ' Else Shablon:=Shablon+'    -    ';
end
else
 begin
If Not(FExists(Path^.Dat.ToTemp+IntToStr(Srok,COne)+'.w'+IntToStr(Srok,COne))) Then
Shablon:=Shablon+'    ?    ' Else Shablon:=Shablon+'    -    ';
 end;

If Day=1 Then
Begin
ws:=DAteToDAteString('   dd.mm ',EE);
ws[1]:='Н';ws[2]:='а';
End;

s:=s+SeparatorChar+'  остат  '+SeparatorChar+'   прод. '+SeparatorChar+'  Рейтинг ';

s1:=s1+SeparatorChar+ws+SeparatorChar+'   E   '+SeparatorChar+'     E';

ws[0]:=#0;
For l:=1 To Ord(s[0]) Do
Begin
ws[l]:='_';
ws[0]:=Chr(l);
End;

rs:=ws;

Shapka[1]:=ws;
Shapka[2]:=s1;
Shapka[3]:=s;
Shapka[4]:=ws+HeaderStop;

{
Writeln(Txt,Space+ws);
Writeln(Txt,Space+s1);
Writeln(Txt,Space+s);
Writeln(Txt,Space+ws);
}


  R1.Assign(0,0,0,0);
  WspomlIST := New(PBox, Init(R1, 1, Nil));
  WspomList^.NewList(New(PTextCollection, Init(0,1)));
  j:=0;
  {New(Itg,Init);}



  For L:=EE1 To EE Do
   Begin
    Str(StrToInt(Rek^.Dat.Kod):2,Ext);
    RFormatZerro(Ext,2);
    s:=DAteToDAteString(DateMask,l);

    If Day=0 Then
    Begin
    MyDate:=S;
    ClearChar(MyDAte);
    Assign(ItogFile,Path^.Dat.ToArchiv+MyDate+'.p'+Ext);
    End
    Else
    Assign(ItogFile,Path^.Dat.ToTemp+IntToStr(j+1,COne)+'.w'+IntToStr(j+1,COne));
    i:=IOResult;
    OldFileMode:=FileMode;
    FileMode:=$42;
    Reset(ItogFile,SizeOf(NewItogType));
    i:=IOResult;
    FileMode:=OldFileMode;

    If i=0 Then
     Begin
      While Not(Eof(ItogFile)) Do
       Begin

    New(Itg,Init);
    Count1:=0;
    BlockRead(ItogFile,Itg^.Point,BufItg,Count1);
    For cc:=1 To Count1 Do
Begin

{ If Not TestElement(Copy(Itg^.Dat.BAzKod,1,CRAzdelKod),TempList) Then}
If TestElementSpis (Copy(Itg^.Point.Dat[cc].BAzKod,1,CRAzdelKod),TempList,regim) Then
   Begin
        If Not(TestElement(Itg^.Point.Dat[cc].BAzKod,WspomList)) Then
         Begin
          Pos:= Location(WspomList,Itg^.Point.Dat[cc].BAzKod,False);
          ws := WspomList^.GetText(pos,WspomList^.List^.Count);
          s:=Copy(ws,1+CName+1+CArtikul+1+(CPack+1)*j,CPack);
          Delete(ws,1+CName+1+CArtikul+1+(CPAck+1)*j,CPAck);

          if day=0 then{для случая расчета по дням}
          begin
          Case Cl Of
          0:Str(StrToInt(s)+StrToInt(Itg^.Point.Dat[cc].MrkC):CPAck,s);{клиент}
          1:Str(StrToInt(s)+StrToInt(Itg^.Point.Dat[cc].MrkS):CPAck,s);{склад}
          2:Str(StrToInt(s)+StrToInt(Itg^.Point.Dat[cc].MrkB):CPAck,s);{бартер}
          3:Str(StrToInt(s)+StrToInt(Itg^.Point.Dat[cc].MrkC)+StrToInt(Itg^.Point.Dat[cc].MrkB)+
                      StrToInt(Itg^.Point.Dat[cc].MrkS):CPAck,s);
          Else;
          End;
          end
           else Str(StrToInt(s)+StrToInt(Itg^.Point.Dat[cc].MrkC):CPAck,s);{для случая недель}


          Insert(s,ws,1+CName+1+CArtikul+1+(CPAck+1)*j);

          If Day=0 Then
          Begin
          If l=EE Then
           Begin
            Delete(ws,Ord(ws[0])-CPAck+1,CPAck);
            Str(StrToInt(Itg^.Point.Dat[cc].Ost):CPAck,s);
            ws:=ws+s;
           End;
          End
          Else
           Begin
          If (j+1)=Srok Then
           Begin
            Delete(ws,Ord(ws[0])-CPAck+1,CPAck);
            Str(StrToInt(Itg^.Point.Dat[cc].Ost):CPAck,s);
            ws:=ws+s;
           End;

           End;

          WspomList^.List^.AtFree(Pos);
          WspomList^.SetRange(WspomList^.List^.Count);

          WspomList^.List^.Insert(NewStr(ws));
          WspomList^.SetRange(WspomList^.List^.Count);
         End
         Else
          Begin
            ws:=GetIdField(FNAme,Itg^.Point.Dat[cc].BAzKod);
            Format(ws,CNAme);

            ws:=ws+'│'+Itg^.Point.Dat[cc].BAzKod+'│'+Shablon;


            Delete(ws,1+CName+1+CArtikul+1+(CPAck+1)*j,CPAck);

          if day=0 Then{для случая расчета по дням}
          Begin
          Case Cl Of
          0:Str(StrToInt(Itg^.Point.Dat[cc].MrkC):CPAck,s);{клиент}
          1:Str(StrToInt(Itg^.Point.Dat[cc].MrkS):CPAck,s);{склад}
          2:Str(StrToInt(Itg^.Point.Dat[cc].MrkB):CPAck,s);{склад}
          3:Str(StrToInt(Itg^.Point.Dat[cc].MrkC)+StrToInt(Itg^.Point.Dat[cc].MrkS)+
                      StrToInt(Itg^.Point.Dat[cc].MrkB):CPAck,s);
          Else;
          End;
          End
          Else Str(StrToInt(Itg^.Point.Dat[cc].MrkC):CPAck,s);{для случая недель}

            {Str(StrToInt(Itg^.Dat.MrkC):CPAck,s);}

            Insert(s,ws,1+CName+1+CArtikul+1+(CPAck+1)*j);
          If Day=0 Then
          Begin
          If l=EE Then
           Begin
            Delete(ws,Ord(ws[0])-CPAck+1,CPAck);
            Str(StrToInt(Itg^.Point.Dat[cc].Ost):CPAck,s);
            ws:=ws+s;
           End;
          End
           Else
            Begin
          If (j+1)=Srok Then
           Begin
            Delete(ws,Ord(ws[0])-CPAck+1,CPAck);
            Str(StrToInt(Itg^.Point.Dat[cc].Ost):CPAck,s);
            ws:=ws+s;
           End;

            End;


            WspomList^.List^.Insert(NewStr(ws));
            WspomList^.SetRange(WspomList^.List^.Count);
          End;
  End;

End;{For cc}
   Dispose(Itg,Done);

 End;{While Not(Eof)}
      Close(ItogFile);{IOResult=0}

     End
      Else
       Begin
       End;


     Inc(j);{счетчик дней}
   End;{for по датам}

{Dispose(Itg,Done);}

{вставить сортировку наименований внутри раздела}
  R.Assign(0,0,0,0);
  WspomlIST1 := New(PBox, Init(R1, 1, Nil));
  WspomList1^.NewList(New(PTextCollection, Init(0,1)));

If WspomList^.List^.Count>=1 Then
Begin
  For j:=0 To WspomList^.List^.Count-1 Do
   Begin
    ws:=WspomList^.GetText(j,WspomList^.List^.Count);
    If Sort=0 Then
    Begin
     ss:=Copy(ws,1+CName+1,CArtikul);
     ws:=ss+'│'+ws;
     Art:=ss;
    End
    Else Art:=Copy(ws,1+CName+1,CArtikul);

    s:=Copy(ws,Ord(ws[0])-CPAck+1,CPAck);
    Delete(ws,Ord(ws[0])-CPAck+1,CPAck);
    If Not(System.Pos('?',s)>0) Then
     Begin
         Str(StrToInt(s):CPAck,s);
      If EdIzm=1 Then
        Begin
         DelSpace(s);
         MarketPack:=CalcPack(Art,s);
         s:=MarketPack;
        End;
     End;
    ws:=ws+s;


    WspomList1^.List^.Insert(NewStr(ws));
    WspomList1^.SetRange(WspomList1^.List^.Count);
   End;{For}
  WspomList^.NewList(Nil);
  WspomList^.NewList(New(PTextCollection, Init(0,1)));
  For j:=0 To WspomList1^.List^.Count-1 Do
   Begin
    ws:=WspomList1^.GetText(j,WspomList1^.List^.Count);
    WspomList^.List^.Insert(NewStr(ws));
    WspomList^.SetRange(WspomList^.List^.Count);
   End;{For}
End;
Dispose(WspomList1,Done);


If WspomList^.List^.Count>=1 Then
 Begin

Extend:=False;
{$IFDEF Pharm}
If MessageBox(^M+#3'Вывести расширенную информацию в отчет?',Nil,mfConfirmation+mfOkCancel)=cmOk Then
  Extend:=True;
{$ENDIF}

Writeln(Txt,Space+Shapka[1]);
Writeln(Txt,Space+Shapka[2]);
Writeln(Txt,Space+Shapka[3]);
Writeln(Txt,Space+Shapka[4]);




 For L:=0 To TempList^.List^.Count-1 Do
 Begin
  If Regim=0 Then s:=Copy(TempList^.GetText(l,TempList^.List^.Count),1,CRazdelKod)
  Else
  s:=Copy(TempList^.GetText(l,TempList^.List^.Count),1+CRazdel+1,CRazdelKod);

If TestElementSpis (S,WspomList,Sort) Then
Begin

  Writeln(Txt);
  Writeln(Txt,Space+'                    Раздел: '+GetRazdel(s));
  Writeln(Txt);

  For j:=0 To WspomList^.List^.Count-1 Do
   Begin
    ws:=WspomList^.GetText(j,WspomList^.List^.Count);
    If Sort=0 Then Delete(ws,1,CArtikul+1);
    ss:=Copy(ws,1+CName+1,CArtikul);
    Art:=ss;
  If StrToInt(Copy(ss,1,CRAzdelKod))=StrToInt(s) Then
  Begin
    Delete(ws,1+CNAme+1,CArtikul+1);
    ws:=ss+SeparatorChar+ws;

  SumKol[0]:=#0;
  Reiting[0]:=#0;
  l1:=0;
  For i:=0 To Srok-1 Do
   Begin
    ss:=Copy(ws,1+CName+1+CArtikul+1+(CPAck+1)*i,CPAck);
    If Not(System.Pos('?',ss)>0) And Not(System.Pos('-',ss)>0) Then inc(l1);
    If EdIzm=1 Then
     Begin
      If Not(System.Pos('?',ss)>0) And Not(System.Pos('-',ss)>0) Then
       Begin
        DelSpace(ss);
        MarketPack:=CalcPack(Art,ss);
        Delete(ws,1+CName+1+CArtikul+1+(CPAck+1)*i,CPAck);
        Insert(MarketPack,ws,1+CName+1+CArtikul+1+(CPAck+1)*i);
       End;
     End;
    ws[1+CName+1+CArtikul+1+(CPAck+1)*i-1]:=SeparatorChar;
    Str(StrToInt(SumKol)+StrToInt(ss):CPAck+1,SumKol);
   End;
  ws[1+CName+1+CArtikul+1+(CPAck+1)*Srok-1]:=SeparatorChar;

  If l1>0 Then Str(StrToInt(SumKol) div l1:CPAck,Reiting)
  Else Reiting:='    ?    ';


  If EdIzm=1 Then
   Begin
    DelSpace(SumKol);
    SumKol:=CalcPack(Art,SumKol);
   End;


If Extend Then
Begin
  If EdIzm=1 Then
   Begin
    DelSpace(Reiting);
    Reiting:=CalcPack(Art,Reiting);
   End;

  OstKKK:=BakGetField(FKol,ART,0);
  If EdIzm=1 Then
   Begin
    DelSpace(OstKKK);
    OstKKK:=CalcPack(Art,OstKKK);
   End;

  OstKKKOutBron:=BakGetField(FKolItog,ART,0);
  If EdIzm=1 Then
   Begin
    DelSpace(OstKKKOutBron);
    OstKKKOutBron:=CalcPack(Art,OstKKKOutBron);
   End;


End;

  ws:=ws+SeparatorChar+SumKol+SeparatorChar+Reiting+SeparatorChar;

  SumKol:=GetIdField(FInPack,Art);
  DelSpace(SumKol);
  RFormat(SumKol,CInPAck);

  Insert(SumKol+SeparatorChar,ws,1+CArtikul+1+CName+1);

   While System.Pos('│',ws)>0 Do
    Begin
     i:=System.Pos('│',ws);
     ws[i]:=SeparatorChar;
    End;


If Extend Then
Begin
  Seria:=GetMarkaField(FMarka,BakGetField(FMarka,Art,0));
  Format(Seria,CAll);
  Firma:=GetFirmaPostField(FFirmaPost,GetIDField(FFirmaPost,Art));
  Format(Firma,CFirmaPost);
  Strana:=GetPostField(FPost,GetIDField(FPost,Art));
  Format(Strana,CPost);
  Reiting:=BakGetField(FZakupka,Art,0);
  DelSpace(Reiting);
  RFormat(Reiting,CZenaZ);
  SZena:=BakGetField(FRZena,Art,0);
  DelSpace(SZena);
  RFormat(SZena,CZena);
End;

  If Extend Then
  Writeln(txt,Space+ws+SeparatorChar+OstKKK+SeparatorChar+
                                     OstKKKOutBron+SeparatorChar+SZena+
                       SeparatorChar+Reiting+SeparatorChar+Firma+
                                   SeparatorChar+Strana+SeparatorChar+Seria)
  Else
  Writeln(txt,Space+ws);

          ws1:=Copy(ws,1,CArtikul);
          If Nprint^.DAt.FullName=0 Then Ws2:=GetIdField(FName2,ws1)
          Else Ws2:=GetIdField(FFName2,ws1);
          DelSpaceRight(ws2);

          If ws2[0]<>#0 Then
          Begin
           Format(ws2,CNAme);
           Writeln(txt,Space+'     '+SeparatorChar+ws2+SeparatorChar);
           {Format(ws2,CName);}
          End;


End;
  End;
   End;

 End;{for по разделам}
 End;

ws[0]:=#0;
For l:=1 To Ord(rs[0]) Do
Begin
ws[l]:='=';
ws[0]:=Chr(l);
End;

Writeln(Txt);
Writeln(Txt,Space+'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
Writeln(Txt,Space+ws+GlobalPrn^.Dat.NoCondensed[Nprint^.DAt.Printer]);
Close(txt);


 Dispose(WspomList,Done);

 Dispose(TempList,Done);
 NoInfo;
 ViewAsText(Path^.Dat.ToTemp+'mrk_ost.txt','Статистика продаж',True);
 {ReportNew(Path^.Dat.ToTemp+'mrk_ost.txt','',NPrintC^.Dat.CopyAll,False,False);}
End;



Procedure FormNaklRet(Space :TDateString; Video : Boolean;As :DocumentEditZ;Const E:PSuperMarketType;
                   Var Txt:Text; Var NDS,Itogo,ItogoSkidka,NDS20,NDS10,NDS_:Float;
                            ShowAnswer:Boolean);
Var l : Word;
    sc,s,ws,ws1 : String;
    Ss : TEnjoyStr;
    st : String[CMantissa];
    pp : String[CPack];
    TTT,ItogoS,NdsPos :Float;
    Local,R : Boolean;
    M : Maska8;
    c : Word;
    Dop : TDateString;
    Nalog:TDateString;
    tempSkidka,tt1,tt2,WspomSkidka,OutputSklad,InputSklad,koefficient:ALLStr;
    DrawSkidka:Boolean;
    Barter : String[CMantissa];
    Zakaznumer,zakazDate,zakazTime:AllStr;

Begin
{$IfDEF DPMI}
   ItogoS:=0;ItogoSkidka:=0;Itogo:=0;{ NDS:=0;} NdsPos:=0;



   zakaznumer[0]:=#0;
   zakazDate[0]:=#0;
   zakazTime[0]:=#0;
(* Отключено из=за проблем с бухгалтерией 26/03/01*)
{вариант для доставки-вино}
If ZakazShema=0 Then
Begin
   If E^.Dat.Oformlenie=1 Then
    Begin
     ZakazNumer:=E^.DAt.FromZakaz;
     DelSpace(ZakazNumer);
     ZakazNumer:='ЗЛ '+ZakazNumer+'/';
     ZakazDate:=GetZakazDate(E^.DAt.FromZakaz,FieldEndDate);
     If ZakazDate='' Then ZakazDate:=E^.Dat.DateC;
     ZakazTime:=GetZakazDate(E^.DAt.FromZakaz,FieldTime);
     If ZakazTime='' Then ZakazTime:=E^.Dat.TimeC;
    End
    Else
     Begin
      ZakazDate:=E^.Dat.DateC;
      ZakazTime:=E^.Dat.TimeC;
     End;
End
Else
  Begin
      ZakazDate:=E^.Dat.DateC;
      ZakazTime:=E^.Dat.TimeC;
  End;


   R:=True;
   Dop[0]:=#0;

   If E^.Dat.OperatorSelector in [0,2] Then Local:=False
   Else Local:=True;

If Not(Video) Then DInfoMsg('Формирую документ. Ждите...',True);

   For l:=1 To E^.Dat.Amount Do
   Begin
   MyStr(StrToReal(E^.Dat.MarketElement[l].Input.Zena)*StrToInt(E^.Dat.MarketElement[l].Input.Kol)
   ,CIZena,CMantissa,ws);
   Itogo:=Itogo+StrToReal(Ws);
   End;

   DrawSkidka:=False;
   Write(txt,Space+'Основание: по документу N '+ZakazNumer+E^.Dat.Document+'/'+
   IntToStr(StrToInt(E^.DAt.SkladKod),COne)+' от '+ZakazDate);

If E^.DAt.Oformlenie=1 Then
Begin
 WriteLn(txt,'  ('+E^.Dat.Document+'/'+IntToStr(StrToInt(E^.DAt.SkladKod),COne)+' '+E^.Dat.DateC+')');
End
Else
Writeln(txt);



If R Then
Begin
 If (E^.Dat.OperatorSelector in [0,2]) Then
 Begin
   Writeln(txt,Header+Space+Dop+'┌──────────────────────────────────────────────────────────────────────────────────┐');
   Writeln(txt,Space+Dop+'│N  Код  Наименование товара        Колич     Цена Итого сумма  Упаковок Отд Примеч│');
   Writeln(txt,Space+Dop+'└──────────────────────────────────────────────────────────────────────────────────┘'+HeaderStop);
 End
  Else
  Begin
   Space:=' ';
   Writeln(txt,Header+Space+Dop+'┌────────────────────────────────────────────────────────────────────────────────────────┐');
   Writeln(txt,Space+Dop+'│N  Код  Наименование товара        Колич     Цена   НП  Итого сумма  Упаковок Отд Примеч│');
   Writeln(txt,Space+Dop+'└────────────────────────────────────────────────────────────────────────────────────────┘'+
   HeaderStop);
  End;
                         { 1 12345│12345678901234567890123456│12345│12345678│12345│1234567890123│123456789│123│1234567│}
End
Else
Begin
   Writeln(txt,Header+Space+Dop+'┌─────────────────────────────────────────────────────────────┐');
   Writeln(txt,Space+Dop+'│N  Код  Наименование товара        Колич     Цена Итого сумма│');
   Writeln(txt,Space+Dop+'└─────────────────────────────────────────────────────────────┘'+HeaderStop);
End;

   c:=0;
   WordToBit8(c,M);
   For l:=1 To E^.Dat.Amount Do
    Begin
     Str(l:CMantissa,St);
     s:=E^.Dat.MarketElement[l].BazKod;
{
     if E^.Dat.MarketElement[l].BazKod='26064'
      Then
      Begin
       Readln;
      End;
}
     {
     If Nprint^.DAt.FullName=0 Then
     ws:=GetIdField(FName,E^.Dat.MarketElement[l].BazKod)
     Else ws:=GetIdField(FFname,E^.Dat.MarketElement[l].BazKod);
     }

     If Nprint^.DAt.FullName=0 Then
     Begin
      ws:=GetIdField(FName,E^.Dat.MarketElement[l].BazKod);
      ws1:=GetIdField(FName2,E^.Dat.MarketElement[l].BazKod);
      DelSpaceRight(ws1);
      If ws1[0]<>#0 Then
          Begin
           Writeln(txt,Space+Dop+'   '+'      '+ws);
        ws:=ws1;
       End;
     End
     Else
         Begin
          ws:=GetIdField(FFName,E^.Dat.MarketElement[l].BazKod);
       ws1:=GetIdField(FFName2,E^.Dat.MarketElement[l].BazKod);
       DelSpaceRight(ws1);
      If ws1[0]<>#0 Then
          Begin
           Writeln(txt,Space+Dop+'   '+'      '+ws);
        ws:=ws1;
       End;
      End;

     Format(ws,CName);
     s:=s+' '+ws;
     DelSpace(E^.Dat.MarketElement[l].Input.Kol);
     ws:=E^.Dat.MarketElement[l].Input.Kol;
     ws:='{'+ws+'}';
     RFormat(ws,CKol+2);
     s:=s+{' '}+ws;


     If E^.Dat.SkidkaSelector=0 Then{Если автомат}
      begin
       DelSpace(E^.Dat.MarketElement[l].Input.Proz);

       MyStr((StrToReal(E^.Dat.MarketElement[l].Input.Zena)/
       (1+StrToReal(E^.Dat.MarketElement[l].Input.Proz)/100)),CZena,CMantissa,ws);

       {отключен расчет налога с продажи в товарном чеке}
       If E^.DAt.DocSelector in [{1,}2,3,5,6] Then
       Begin
       Mystr(((1+strtoreal(e^.dat.marketelement[l].Input.SpecNalog)
              /100)),CLitr,CMantissa,koefficient);

       {новая цена}

{$IFDEF NSP}
       {новая цена}
       MyStr(StrToReal(ws){*StrToReal(Koefficient)},CZena,CMantissa,ws);
{$ELSE}
       MyStr(StrToReal(ws)*StrToReal(Koefficient),CZena,CMantissa,ws);
{$ENDIF}
       End;

       s:=s+{' '}+ws;


  If E^.Dat.OperatorSelector=1 Then
    Begin
     Nalog:=E^.Dat.MarketElement[l].Input.SpecNalog;
     MyStr(StrToReal(Nalog),CLitr,CMantissa,Nalog);
     s:=s+' '+Nalog;
    End;

       MyStr((StrToReal(Ws)*StrToInt(E^.Dat.MarketElement[l].Input.Kol))
       ,CInputIZena-2{в 11 символов},CMantissa,ws);

       ItogoS:=ItogoS+StrToReal(wS);
       s:=s+' '+ws;
      end
     Else
      Begin
{       ItogoSkidka:=ItogoSkidka+StrToReal(E^.Dat.MarketElement[l].Input.Skidka)*StrToInt(E^.Dat.MarketElement[l].Input.Kol);
       {сумма скидки}
       MyStr((StrToReal(E^.Dat.MarketElement[l].Input.Zena)-StrToReal(E^.Dat.MarketElement[l].Input.Skidka))
       ,CZena,CMantissa,ws);


       {отключен расчет налога с продажи в товарном чек}
       If E^.DAt.DocSelector in [{1,}2,3,5,6] Then
       Begin
       Mystr(((1+strtoreal(e^.dat.marketelement[l].Input.SpecNalog)
              /100)),CLitr,CMantissa,koefficient);

{$IFDEF NSP}
       {новая цена}
       MyStr(StrToReal(ws){*StrToReal(Koefficient)},CZena,CMantissa,ws);
{$ELSE}
       MyStr(StrToReal(ws)*StrToReal(Koefficient),CZena,CMantissa,ws);
{$ENDIF}
       End;

       s:=s+{' '}+ws;



  If E^.Dat.OperatorSelector=1 Then
    Begin
     Nalog:=E^.Dat.MarketElement[l].Input.SpecNalog;
     MyStr(StrToReal(Nalog),CLitr,CMantissa,Nalog);
     s:=s+' '+Nalog;
    End;
       MyStr((StrToReal(Ws)*StrToInt(E^.Dat.MarketElement[l].Input.Kol))
       ,CInPutIZena-2,CMantissa,ws);

       ItogoS:=ItogoS+StrToReal(wS);

       s:=s+' '+ws;
      End;

      M[E^.Dat.MarketElement[l].Input.DivisionNumber]:=1;

     NdsPos:=StrToReal(Ws)*

     StrToReal(E^.Dat.MarketElement[l].Input.NDS)/
     (100+StrToReal(E^.Dat.MarketElement[l].Input.NDS));

     {
     StrToReal(BakGetField(FNDS,E^.Dat.MarketElement[l].BazKod,0))/
     (100+StrToReal(BakGetField(FNDS,E^.Dat.MarketElement[l].BazKod,0)));
     }
     MyStr(NdsPos,CIZena,CMantissa,ws);
     NdsPos:=StrToReal(Ws);

     {Nds:=Nds+NdsPos;}

     If R Then {Если не вторичный документ консигнации}
      Begin
      {посчитали упаковки}
      pp:=CalcPack(E^.Dat.MarketElement[l].BazKod,E^.Dat.MarketElement[l].Input.Kol);
      DelSpace(Pp);
      RFormat(Pp,CPack);
      s:=s+' '+pp;
      {добавили отделение}
      Str(E^.Dat.MarketElement[l].Input.DivisionNumber:2,ws);



      {Если скидка автоматическая и не нулевая}
      Case E^.Dat.SkidkaSelector Of
      0:Begin{скидка автоматическая}

       Case Nprint^.DAt.FullSkidka Of
       0:Begin{скидка в процентах}
         If DrawSkidka Then
         Begin
          If (StrToReal(E^.Dat.MarketElement[l].Input.Proz)<>0) Then
           Begin
            TempSkidka:=E^.Dat.MarketElement[l].Input.Proz;

            Format(TempSkidka,CKol+1);
            {если на экран}
            If Video Then ws:=ws+' ('+TempSkidka+')'
            {если на печать}
            Else ws:=ws+' ('+TempSkidka+')';
           End
            Else ws:=ws+'  '+'_______';
          End{DrawSkidka}
         Else
          Begin
           ws:=ws+'  '+'_______';
          End;
         End;{Case FullSkidka 0}

       1:Begin {абсолютная велечина скидки}
         If DrawSkidka Then
         Begin
          If (StrToReal(E^.Dat.MarketElement[l].Input.Proz)<>0) Then
           Begin
            MyStr(StrToReal(E^.Dat.MarketElement[l].Input.Zena)-StrToReal(E^.Dat.MarketElement[l].Input.Zena)/
            (1+StrToReal(E^.Dat.MarketElement[l].Input.Proz)/100),CKol+1,CMantissa,WspomSkidka);
            DelSpace(WspomSkidka);
            Format(WspomSkidka,CKol+1);
            If Video Then ws:=ws+' ('+WspomSkidka+')'
            {если на печать}
            Else ws:=ws+' ('+WspomSkidka+')';
           End
            Else ws:=ws+'  '+'_______';
         End{DrawSkidka}
         Else
          Begin
           ws:=ws+'  '+'_______';
          End;
         End;{Case FullSkidka 1}
         Else;
         End;{Case FullSkidka}

        End;{0 Case}
      1:Begin{скидка ручная}

        Case Nprint^.DAt.FullSkidka Of
        0:Begin{скидка в процентах}
         If DrawSkidka Then
         Begin
         If (Abs(StrToReal(E^.Dat.MarketElement[l].Input.Skidka))>=0.01) Then
          Begin
           If StrToReal(E^.Dat.MarketElement[l].Input.Skidka)>0 Then
            Begin
             If (StrToReal(E^.Dat.MarketElement[l].Input.Zena)-StrToReal(E^.Dat.MarketElement[l].Input.Skidka))>0.009 Then
             MyStr(((StrToReal(E^.Dat.MarketElement[l].Input.Zena))/((StrToReal(E^.Dat.MarketElement[l].Input.Zena)-
             StrToReal(E^.Dat.MarketElement[l].Input.Skidka)))-1)*100
             ,CKol+1,CLitrMantissa,WspomSkidka)
             Else
             WspomSkidka:='100.00';

             MyStr(StrToReal(WspomSkidka){*100},CKol+1,CMantissa,WspomSkidka);
            End
            Else
             Begin
              MyStr((-(Abs(StrToReal(E^.Dat.MarketElement[l].Input.Skidka)))/
              ((StrToReal(E^.Dat.MarketElement[l].Input.Zena)))*100),CKol+1,CMantissa,WspomSkidka);
             End;
            DelSpace(WspomSkidka);
            Format(WspomSkidka,CKol+1);
            {если на экран}
            If Video Then ws:=ws+' ('+WspomSkidka+')'
            {если на печать}
            Else ws:=ws+' ('+WspomSkidka+')';
          End
          Else ws:=ws+'  '+'_______';
         End {DrawSkidka}
         Else
          Begin
           ws:=ws+'  '+'_______';
          End;
          End;{Case FillSkidka 0}
        1:Begin{абсолютная велечина скидки}
        If DrawSkidka Then
        Begin
         If (Abs(StrToReal(E^.Dat.MarketElement[l].Input.Skidka))>0.01) Then
          Begin
           MyStr(StrToReal(E^.Dat.MarketElement[l].Input.Skidka),CKol+1,CMantissa,
           E^.Dat.MarketElement[l].Input.Skidka);
           DelSpace(E^.Dat.MarketElement[l].Input.Skidka);
           Format(E^.Dat.MarketElement[l].Input.Skidka,CKol+1);
           WspomSkidka:=E^.Dat.MarketElement[l].Input.Skidka;

           If Video Then ws:=ws+' ('+WspomSkidka+')'
           {если на печать}
           Else ws:=ws+' ('+WspomSkidka+')';
          End
          Else ws:=ws+'  '+'_______';
        End
         Else
          Begin
             ws:=ws+'  '+'_______';
          End;
          End;{Case FullSkidka 1}
          Else;
          End;{Case FullSkidka}

        End;{1 Case}

      Else;{Case}
      End;{Case}
      End{If r}
      Else
           Begin
            pp[0]:=#0;
            ws[0]:=#0;
           End;
     If Not Video Then s:=GlobalPrn^.Dat.Pitch[Nprint^.DAt.Printer]+s+' '+ws+
	GlobalPrn^.Dat.NoPitch[Nprint^.DAt.Printer]
     Else s:=s+' '+ws;

     If l=E^.Dat.Amount Then s:=ONLYLINK+s;



     Writeln(txt,Space+Dop+St+' '+s);
     If E^.Dat.OperatorSelector in [0,2] Then
     Begin

     If PrintAkzisDoc[2]=1 Then
     Begin
       ss:=BakGetField(FStrihKod{FAkzis},E^.Dat.MarketElement[l].BazKod,0);
       DelSpaceRight(ss);
       If not(ss[0]=#0) Then
        Begin
         Format(ss,CSertif);
         ss:=Space+'   '+'Штрих-код: '+ss;
         Writeln(txt,ss);
        End;
     End;

     End{OperatorSelector}
     Else
      Begin

     If PrintSertifDoc[1]=1 Then
      Begin
       ss:=BakGetField(FSertif,E^.Dat.MarketElement[l].BazKod,0);
       DelSpaceRight(ss);
       If not(ss[0]=#0) Then
        Begin
         Format(ss,CNSertif);
         ss:=Space+'   '+'Сертификат: '+ss;
         Writeln(txt,ss);
        End;
       ss:=BakGetField(FDateSertif,E^.Dat.MarketElement[l].BazKod,0);
       DelSpaceRight(ss);
       If not(ss[0]=#0) Then
        Begin
         Format(ss,CDSertif);
         ss:=Space+'   '+'Срок дейст: '+ss;
         Writeln(txt,ss);
        End;
       ss:=GetKSertifField(FKsertif,BakGetField(FKtoSertif,E^.Dat.MarketElement[l].BazKod,0));
       DelSpaceRight(ss);
       If not(ss[0]=#0) Then
        Begin
         Format(ss,CKSertif);
         ss:=Space+'   '+'     Выдан: '+ss;
         Writeln(txt,ss);
        End;
      End;

     If PrintAkzisDoc[1]=1 Then
     Begin
       ss:=BakGetField(FStrihKod{FAkzis},E^.Dat.MarketElement[l].BazKod,0);
       DelSpaceRight(ss);
       If not(ss[0]=#0) Then
        Begin
         Format(ss,CSertif);
         ss:=Space+'   '+'Штрих-код: '+ss;
         Writeln(txt,ss);
        End;
      End;
       End;
{    s:=BakGetField(FSertif,E^.Dat.MarketElement[l].BazKod,0);
     DelSpaceRight(s);
     If s[0]<>#0 Then
     Begin
     Format(s,CSertif);
     Writeln(Txt,Space+'        Сертификат: '+s);
     End;     }
{     StrToInt(E^.Dat.MArketElement[l].Input.Kol)*Wspom*
     StrToReal(GetNds(E^.Dat.MarketElement[l].BazKod))/(100+StrToReal(GetNds(E^.Dat.MarketElement[l].BazKod)));
{    Nds:=StrToReal(Ws);}
    End;


    ItogoSkidka:=Itogo{+StrToReal(E^.Dat.ENalog)};
    MySTr(ItogoSkidka,CIZena,CMantissa,tt1);
    MySTr(ItogoS,CIZena,CMantissa,tt2);

    ItogoSkidka:=StrToReal(tt1)-StrToReal(tt2){ItogoS};

    DelSpace(E^.Dat.SummaZ);
    RFormat(E^.Dat.SummaZ,CIZena);
    RFormat(E^.Dat.SummaZakupka,CIZena);
{    If Video Then Writeln(txt,Space+'______________________________________________________________________________');}
MyStr(StrToReal(E^.Dat.SummaZ),CIZena,CMantissa,E^.Dat.SummaZ);
MyStr(StrToReal(E^.Dat.SummaZakupka),CIZena,CMantissa,E^.Dat.SummaZakupka);
{DelSpace(E^.Dat.SummaZ);}
If R Then
Begin
  If E^.DAt.OperatorSelector in [0,2] Then
   Begin
    Writeln(txt,Space+Dop+'────────────────────────────────────────────────────────────────────────────────────');
    Writeln(Txt,Space+Dop+'Всего позиций:',E^.Dat.Amount:2,'                Всего  возврат:',Recogniz(E^.Dat.SummaZ)+
    ' Мест:'+CalcMesto(E));

If (Video) And (StrToInt(CurrentPassword)=0) Then
   Begin
    Writeln(Txt,Space+Dop+'                                   Всего закупка:',Recogniz(E^.Dat.SummaZakupka)+
    '    D:'+Recogniz(RealToStr(StrToReal(E^.Dat.SummaZ){-StrToReal(E^.Dat.ENalog)}-StrToReal(E^.Dat.SummaZakupka),
    CIZena,CMantissa)));
   End;

   End
   Else
    Begin
    Writeln(txt,Space+Dop+'──────────────────────────────────────────────────────────────────────────────────────────');
    Writeln(Txt,Space+Dop+'Всего позиций:',E^.Dat.Amount:2,'                      Всего  возврат:',Recogniz(E^.Dat.SummaZ)+
    ' Мест:'+CalcMesto(E));
If (Video) And (StrToInt(CurrentPassword)=0) Then
   Begin
    Writeln(Txt,Space+Dop+'                                         Всего закупка:',Recogniz(E^.Dat.SummaZakupka)+
    '    D:'+Recogniz(RealToStr(StrToReal(E^.Dat.SummaZ){-StrToReal(E^.Dat.ENalog)}-StrToReal(E^.Dat.SummaZakupka),
    CIZena,CMantissa)));
   End;
    End;
End
Else
Begin
    Writeln(txt,Space+Dop+'───────────────────────────────────────────────────────────────');
    Writeln(Txt,Space+Dop+'Всего позиций:',E^.Dat.Amount:2,'                Всего  возврат:',Recogniz(E^.Dat.SummaZ)+
    ' Мест:'+CalcMesto(E));
If (Video) And (StrToInt(CurrentPassword)=0) Then
   Begin
    Writeln(Txt,Space+Dop+'                                   Всего закупка:',Recogniz(E^.Dat.SummaZakupka)+
    '    D:'+Recogniz(RealToStr(StrToReal(E^.Dat.SummaZ){-StrToReal(E^.Dat.ENalog)}-StrToReal(E^.Dat.SummaZakupka),
    CIZena,CMantissa)));

   End;

End;


If Not(Video) Then
Begin
    If E^.Dat.DocSelector in [2,3,4,5,6,8] Then
    Begin
    s:=E^.Dat.SummaZ;
    DelSpace(s);
    Propis(s,ws);
    If r Then
    Writeln(txt,Space+Dop+'────────────────────────────────────────────────────────────────────────────────────')
    Else
    Writeln(txt,Space+Dop+'───────────────────────────────────────────────────────────────');

    ws[1]:=UpperCase(ws[1]);
    If Not Video Then Writeln(txt,Space+Dop+
    GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
    GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+
    GlobalPrn^.Dat.Double[Nprint^.DAt.Printer]+
    ws+
    GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]+
    GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+
    GlobalPrn^.Dat.NoDouble[Nprint^.DAt.Printer])
    Else Writeln(txt,Space+ws);
    If s[0]<>#0 Then
    If Not Video Then Writeln(txt,Space+Dop+
    GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
    GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+
    GlobalPrn^.Dat.Double[Nprint^.DAt.Printer]+
    s+
    GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]+
    GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+
    GlobalPrn^.Dat.NoDouble[Nprint^.DAt.Printer])
    Else Writeln(txt,Space+s);

    If r Then
    Writeln(txt,Space+Dop+'────────────────────────────────────────────────────────────────────────────────────')
    Else
    Writeln(txt,Space+Dop+'─────────────────────────────────────────────────────────────────');
    End;
End;


    Writeln(Txt);


   If Not(Local) Then
   Begin
   If Not(Video) Then
   Begin
    If R Then
    Begin
    Writeln(Txt,Space+Dop+'        Сдал ________       Товар принял, претензий не имею _______')
    End
    Else
    Writeln(Txt,Space+'            Сдал ________       Товар принял, претензий не имею _______')

   End;
   End
   Else
    Begin
    OutPutSklad:=GetClientField(FClient,Rek^.Dat.Kod,1);
    Format(OutPutSklad,CClient);
    InPutSklad:=GetClientField(FClient,E^.Dat.ClientKod,1);
    Format(InPutSklad,CClient);
   If Not(Video) Then
   Begin
 Writeln(Txt,Space+'    '+'  Сдал кладовщик '+OutPutSklad+': __________  Товар принял экспедитор: __________');
 Writeln(txt,Space++'    '+'                                           ФИО                                ФИО');
 Writeln(Txt,Space++'    '+'Принял кладовщик '+InputSklad +': __________  Товар сдал экспедитор  : __________');
 Writeln(txt,Space++'    '+'                                           ФИО                                ФИО');

   End;
   End;

    If E^.Dat.DocSelector in [1,2,3,5,6] Then
    Begin
      Writeln(txt,Space+'{'+RecognizReal(STrToReal(E^.Dat.ENalog),CIZena,CMantissa),'}');
      If StrToReal(E^.Dat.ENalog)>0.009 Then
      Begin
       If StrToReal(E^.Dat.Nalog5)>0.009 Then
       Writeln(txt,Space+' '+RecognizReal(StrToReal(E^.Dat.Nalog5),CIZena,CMantissa)+'-A');
       If StrToReal(E^.Dat.Nalog3)>0.009 Then
       Writeln(txt,Space+' '+RecognizReal(StrToReal(E^.Dat.Nalog3),CIZena,CMantissa)+'-B');
       If StrToReal(E^.Dat.Nalog_)>0.009 Then
       Writeln(txt,Space+' '+RecognizReal(StrToReal(E^.Dat.Nalog_),CIZena,CMantissa)+'-C');
      End;
    End;


   Writeln(Txt,Space{+'Скидка: '},'{'+RecognizReal(ItogoSkidka,CIZena,CMantissa)+'}');

   If Not(Video)Then Write(txt,Space{+' Всего: '},' '+RecognizReal(Itogo,CIZena,CMantissa),
    '                         '+'                       '
    {'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')'})
   Else
   Writeln(Txt,Space{+' Всего: '},' '+RecognizReal(Itogo,CIZena,CMantissa));
   If Not(Video) Then
   Writeln(txt,'  '+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
   GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+
   GlobalPrn^.Dat.Double[Nprint^.DAt.Printer]+' Тип документа: (',
   '27)'+
   GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]+
   GlobalPrn^.Dat.NOBold[Nprint^.DAt.Printer]+
   GlobalPrn^.Dat.NoDouble[Nprint^.DAt.Printer]);
   If (E^.Dat.OperatorSelector in[0,2]) Then
   Writeln(txt,Space+'====================================================================================')
   Else
   Writeln(txt,Space+'==========================================================================================');

If Not(Video) Then NoInfoMsg;
{$ENDIF}
End;






Begin
{
Writeln(DosToWin('Прювет;'));
Readln;
}
END.