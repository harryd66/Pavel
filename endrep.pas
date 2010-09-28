{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}

{$I Compile.INC}

unit EndRep;

INTERFACE

Uses Dialogs,Drivers,Glob,Access,ServStr,MyCalc,LockInfo,DStat,TStatu,Utils,
     netdbeng,Objects,dbengine,tools,msgbox,tpdate,serv,protect,Printers;

procedure GlobalReport;


implementation


procedure GlobalReport;
const space = ' ';

var FP: PrihodFileType;
    FV: NewVozwratFileType;
    FM: MarketFileType;
    FR: RewisiaFileType;
    Prih: PPrihodType;
    FPO: PereozenkaFileType;
    Poz: PPereozenkaType;
    Vozvr: PNewVozwratType;
    Mark: PSuperMarketType;
    Rewis: PRewisiaType;
    T: text;
    IORez: integer;
    SelList: PStringCollection;
    st,bufst: string;
    nd,ndOb: word;
    sumOtgr, sumSkid: real;
    sumOtgrOb, sumSkidOb: real;
    sumZ, sumO, SumRev, sv: real;
    sumZOb, sumOOb, sumRevOb: real;
    err: boolean;
    DAte : TDAteString;
    AllVersia : Word;



procedure MarkString;
Var Vers:String;
begin
          st:=space;
          {st:=st+IntToStr(nd,CKod);}
          bufSt:=Mark^.Dat.Document;
          rformat(bufst,4);
          st:=st+bufst;
          bufst:=GetClientField(FClient,Mark^.Dat.ClientKod,Mark^.Dat.OperatorSelector);
          format(bufst,CClient);
          st:=st+' '+bufst;
          bufst:= REalToStr(StrToREal(Mark^.Dat.SummaZ)+StrToREal(Mark^.Dat.Skidka),CIZena,CMAntissa);
          sumOtgr:=sumOtgr+StrToReal(Mark^.Dat.SummaZ)+StrToREal(Mark^.Dat.Skidka);
          rFormat(bufSt,CiZena);
          st:=st+' '+bufst;
          bufst:=RealToStr(StrToREal(Mark^.Dat.Skidka),CIZena,CMantissa);
          rFormat(bufSt,CiZena);
          sumSkid:=sumSkid+StrToReal(Mark^.Dat.Skidka);
          st:=st+' '+bufst;
          bufSt:=GetOperatorName(Mark^.Dat.Caption);
          format(bufSt,CKto);
          st:=st+' '+bufst;
          Case Mark^.Dat.DocSelector Of
           0:bufst:='Список   ';
           1:bufst:='Тов.Чек* ';
           2:bufst:='Физ.Л*   ';
           3:bufst:='СФ*      ';
           4:bufst:='СФ Б     ';
           5:bufst:='Дебит*   ';
           6:bufst:='Дебит СФ*';
           7:bufst:='Дебит    ';
           8:bufst:='Дебит СФБ';
           Else
		   bufSt:='   ???   ';
           End;
          st:=st+' '+bufst;
          Writeln(T,space+st);
          inc(nd);
end;



procedure DocString(DocSelector: word);
Var Vers:String;
begin
          st:=space;
          {st:=st+IntToStr(nd,CKod);}
          bufSt:=Mark^.Dat.Document;
          rformat(bufst,4);
          st:=st+bufst;
          bufst:=GetClientField(FClient,Mark^.Dat.ClientKod,Mark^.Dat.OperatorSelector);
          format(bufst,CClient);
          st:=st+' '+bufst;
          sumOtgr:=sumOtgr;
          rFormat(bufSt,CiZena);
          st:=st+' '+bufst;
          st:=st+' '+bufst;
          bufSt:=GetOperatorName(Mark^.Dat.Caption);
          format(bufSt,CKto);
          st:=st+' '+bufst;
          Case DocSelector Of
           0:bufst:='Список   ';
           1:bufst:='Тов.Чек* ';
           Else
		   bufSt:='   ???   ';
           End;
          st:=st+' '+bufst;
          Writeln(T,space+st);
          inc(nd);
end;



procedure PrihString;
begin
          st:=space;
          {st:=st+IntToStr(nd,CKod);}
          bufSt:=Prih^.Dat.Document;
          rformat(bufst,4);
          st:=st+bufst;
          bufst:=GetMAkeField(FClient,Prih^.Dat.MAkeKod,Prih^.Dat.OperatorSelector);
          format(bufst,CClient);
          st:=st+' '+bufst;

          {
          bufst:= RealToStr(StrToREal(Prih^.Dat.SummaZakupka),CIZena,CMAntissa);
          sumZ:=sumZ+StrToReal(Prih^.Dat.SummaZakupka);
          }

          bufst:= RealToStr(StrToREal(Prih^.Dat.SummaO),CIZena,CMAntissa);
          sumZ:=sumZ+StrToReal(Prih^.Dat.SummaO);
          rFormat(bufSt,CiZena);
          st:=st+' '+bufst;

          bufst:=RealToStr(StrToREal(Prih^.Dat.SummaR),CIZena,CMantissa);
          rFormat(bufSt,CiZena);
          sumO:=sumO+StrToReal(Prih^.Dat.SummaR);
          st:=st+' '+bufst;
          bufSt:=GetOperatorName(Prih^.Dat.Caption);
          format(bufSt,CKto);
          st:=st+' '+bufst;
          Case Prih^.Dat.StatusDoc Of
           1:bufst:='Буфер';
           0:bufst:='Введен';
           Else bufSt:='???';
           End;
          st:=st+' '+bufst;
          Writeln(T,space+st);
          inc(nd);
end;



procedure VozvrString;
begin
          st:='';
          bufSt:=Vozvr^.Dat.Document;
          rformat(bufst,4);
          st:=st+bufst;
          bufst:=GetClientField(FClient,Vozvr^.Dat.MakeKod,Vozvr^.Dat.OperatorSelector);
          format(bufst,CClient);
          st:=st+' '+bufst;
          bufst:=Vozvr^.Dat.BasisDoc;
          rformat(bufst,CDocNumer);
          st:=st+' '+bufst;
          bufst:=Vozvr^.Dat.BasisDate;
          format(bufst,CDate);
          st:=st+' '+bufst;

          bufst:=RealToStr(StrToReal(Vozvr^.Dat.SummaR),CIZena,CMAntissa);
          rformat(bufst,CIZena);
          sumO:=sumO+StrToReal(Vozvr^.Dat.SummaR);
          st:=st+' '+bufst;

          bufst:= RealToStr(StrToReal(Vozvr^.Dat.Skidka),CZena,CMAntissa);
          sumZ:=sumZ+StrToReal(Vozvr^.Dat.Skidka);
          rFormat(bufSt,CZena);
          st:=st+' '+bufst;

          bufst:= RealToStr(StrToReal(Vozvr^.Dat.Rashodsumma),10,CMAntissa);
          sv:=sv+StrToReal(Vozvr^.Dat.Rashodsumma);
          rFormat(bufSt,10);
          st:=st+' '+bufst;
         { bufst:=Prih^.Dat.SummaR;
          rFormat(bufSt,CiZena);
          sumO:=sumO+StrToReal(Prih^.Dat.SummaR);
          st:=st+' '+bufst; }
          bufSt:=GetOperatorName(Vozvr^.Dat.Caption);
          format(bufSt,CKto);
          st:=st+' '+bufst;
          Case Vozvr^.Dat.StatusDoc Of
           1:bufst:='Буфер';
           0:bufst:='Введен';
           Else bufSt:='???';
           End;
          format(bufst,6);
          st:=st+' '+bufst;
          Writeln(T,space+st);
          inc(nd);
end;



procedure RewisString;
begin
          st:=space;
          bufSt:=Rewis^.Dat.Document;
          rformat(bufst,4);
          st:=st+bufst;

          bufst:=RealToStr(StrToREal(Rewis^.Dat.Itogo),CIZena,CMAntissa);
          rformat(bufst,CIZENA);
          st:=st+' '+bufst;
          sumRev:=sumRev+StrToReal(Rewis^.Dat.Itogo);

          bufst:=RealToStr(StrToREal(Rewis^.Dat.ItogoPlus),CIZena,CMantissa);
          rformat(bufst,CIZENA);
          st:=st+' '+bufst;
          sumZ:=sumZ+StrToReal(Rewis^.Dat.ItogoPlus);


          bufst:=RealToStr(StrToReal(Rewis^.Dat.ItogoMinus),CIZena,CMantissa);
          rformat(bufst,CIZENA);
          st:=st+' '+bufst;
          sumO:=sumO+StrToReal(Rewis^.Dat.ItogoMinus);


          bufSt:=GetOperatorName(Rewis^.Dat.Caption);
          format(bufSt,CKto);
          st:=st+' '+bufst;
          Writeln(T,space+st);
          inc(nd);
end;



procedure PozString;
begin
          st:=space;
          bufSt:=Poz^.Dat.Document;
          rformat(bufst,4);
          st:=st+bufst;

          bufst:=RealToStr(StrToREal(Poz^.Dat.Itogo_Bak_R_Zena),CIZena,CMAntissa);
          rformat(bufst,CIZENA);
          st:=st+' '+bufst;
          sumRev:=sumRev+StrToReal(Poz^.Dat.Itogo_Bak_R_Zena);
          sumRevOb:=sumRevOb+StrToReal(Poz^.Dat.Itogo_Bak_R_Zena);

          bufst:=RealToStr(StrToREal(Poz^.Dat.Itogo_New_R_Zena),CIZena,CMantissa);
          rformat(bufst,CIZENA);
          st:=st+' '+bufst;
          sumZ:=sumZ+StrToReal(Poz^.Dat.Itogo_New_R_Zena);
          sumZOb:=sumZOb+StrToReal(Poz^.Dat.Itogo_New_R_Zena);


          bufst:=RealToStr(StrToReal(Poz^.Dat.Delta_RZ),CIZena,CMantissa);
          rformat(bufst,CIZENA);
          st:=st+' '+bufst;
          sumO:=sumO+StrToReal(Poz^.Dat.Delta_RZ);
          sumOOb:=sumOOb+StrToReal(Poz^.Dat.Delta_RZ);

          bufst:=Poz^.Dat.TimeC;
          st:=st+' '+bufst;

          bufSt:=GetOperatorName(Poz^.Dat.Caption);
          format(bufSt,CKto);
          st:=st+' '+bufst;
          Writeln(T,space+st);
          inc(nd);
          inc(ndOb);
end;


Var AllTch : String[CIZena];
    AllTchS : String[CIZena];


Begin
   Date:=FDAte;
   If Not(DateDialog(DAte)) Then Exit;

   DInfoMsg('Формирую сводный отчет...');
   New(Mark,Init);
   New(Prih,Init);
   New(Vozvr,Init);
   New(Rewis,Init);
   New(POz,Init);
   err:=False;
   Assign(T,Path.ToTemp+'Svodnrep.txt');
   Rewrite(T);
   AllVersia:=0;
   IORez:=IOResult;
   if IORez <> 0 then
    begin
      MessageBox(^M+#3'Ошибка создания файла '+PAth.ToTemp+'SvodnRep.txt',Nil,
      mfError+mfCancelButton);
      {exit;} err:=true;
    end;
   Writeln(T,space,'Склад: ',GetClientField(FClient,Rek.Kod,1)+'  Оператор: '+CurrentPassword+' EYE & 1997-98');
   Writeln(T);
   Write(T,space+'              СВОДНЫЙ ОТЧЕТ СКЛАДА ',GetClientField(FClient,Rek.Kod,1),' за ',Date);
   if TestOpenDate1(Date) then
          Writeln(T,' (ОТКРЫТ)')
        else
          Writeln(T,' (ЗАКРЫТ)');

   Assign(FM,Path.ToMarket+Date+'.mrk');
   Reset(FM);

   IORez:=IOResult;
   if IORez <> 0 then
    begin
      MessageBox(^M+#3'Ошибка открытия файла '+PAth.ToMArket+Date+'.mrk',Nil,
      mfError+mfCancelButton);
      {exit;} err:=true;
    end;
   AllTch[0]:=#0;;
   Writeln(T);
   Writeln(T,space+'                    РЕЕСТР ДОКУМЕНТОВ ОТГРУЗКИ');
                {    40 МАРКИРОВКА                   6680.76            0.00 БЫКОВА       Список}
Writeln(T,space+'-----------------------------------------------------------------------------------');
Writeln(T,space+'N док  Клиент                Сумма отгрузки          Скидка Оператор     Вид док. В');
Writeln(T,space+'-----------------------------------------------------------------------------------');
   sumOtgrOb:=0;
   sumSkidOb:=0;
   ndOb:=0;
   sumOtgr:=0;
   sumSkid:=0;
   nd:=0;
   if not err then While not eof(FM) do
     begin
       ReadMarket(FM,MArk);
       if (Mark^.Dat.OperatorSelector=1) and (Mark^.Dat.Active) And
      ((Not(Mark^.Dat.Realiz)) Or ((Mark^.Dat.Realiz)And(Mark^.Dat.DocSelector in [5,6,7,8])))
	  then
       begin
         if nd=0 then  Writeln(T,space+'{Межскладские перевозки}');
         MarkString ;
       end;
     end;
 if nd<>0 then
  begin
Writeln(T,space+'-----------------------------------------------------------------------------------');
   Writeln(T,'      Всего:                ',RealToStr(sumOtgr,CiZena,CMantissa),' ',
               RealToStr(sumSkid,CiZena,CMantissa),'       Документов: ',IntToStr(nd,4));
   writeln(T);
   ndOb:=ndOb+nd;
  end;
   close(FM);

   sumOtgrOb:=sumOtgrOb+sumOtgr;
   sumSkidOb:=sumSkidOb+sumSkid;
   sumOtgr:=0;
   sumSkid:=0;
   nd:=0;

   sumOtgrOb:=sumOtgrOb+sumOtgr;
   sumSkidOb:=sumSkidOb+sumSkid;
   sumOtgr:=0;
   sumSkid:=0;
   nd:=0;
   Reset(FM);
   if not err then While not eof(FM) do
     begin
       ReadMarket(FM,MArk);
       if (Mark^.Dat.OperatorSelector=0) and (StrToInt(Mark^.Dat.AgentKod)=0)
       and (Mark^.Dat.Active) And
      ((Not(Mark^.Dat.Realiz)) Or ((Mark^.Dat.Realiz)And(Mark^.Dat.DocSelector in [5,6,7,8]))) Then
       begin
        If (MArk^.Dat.DocSelector=1) Then
         Begin
          Str(StrToReal(Mark^.Dat.SummaZ)+StrToReal(AllTch):CIZena:CMantissa,AllTch);
         End;
        if nd=0 then Writeln(T,space+'{Отгрузки клиенту (пассивные)}');
        MarkString ;
       end;
     end;
 if nd<>0 then
  begin
   Writeln(T,space+'-----------------------------------------------------------------------------------');
   Writeln(T,'      Всего:                ',RealToStr(sumOtgr,CiZena,CMantissa),' ',
               RealToStr(sumSkid,CiZena,CMantissa),'       Документов: ',IntToStr(nd,4));
   Writeln(T);
   ndOb:=ndOb+nd;
  end;
   close(FM);

   Reset(FM);
   sumOtgrOb:=sumOtgrOb+sumOtgr;
   sumSkidOb:=sumSkidOb+sumSkid;
   sumOtgr:=0;
   sumSkid:=0;
   nd:=0;
   if not err then While not eof(FM) do
     begin
       ReadMarket(FM,MArk);
       if (Mark^.Dat.OperatorSelector=0) and (StrToInt(Mark^.Dat.AgentKod)>0)
        and Mark^.Dat.Active And
      ((Not(Mark^.Dat.Realiz)) Or ((Mark^.Dat.Realiz)And(Mark^.Dat.DocSelector in [5,6,7,8])))
	   then
       begin
        If (MArk^.Dat.DocSelector=1) Then
         Begin
          Str(StrToReal(Mark^.Dat.SummaZ)+StrToReal(AllTch):CIZena:CMantissa,AllTch);
         End;
        if nd=0 then Writeln(T,space+'{Отгрузки клиенту (активные)}');
        MarkString ;
       end;
     end;
 if nd<>0 then
  begin
   Writeln(T,space+'-----------------------------------------------------------------------------------');
   Writeln(T,'      Всего:                ',RealToStr(sumOtgr,CiZena,CMantissa),' ',
               RealToStr(sumSkid,CiZena,CMantissa),'       Документов: ',IntToStr(nd,4));
   Writeln(T);
   ndOb:=ndOb+nd;
  end;

   sumOtgrOb:=sumOtgrOb+sumOtgr;
   sumSkidOb:=sumSkidOb+sumSkid;
   Writeln(T,space+'Всего отгр-ка: ',RealToStr(sumOtgrOb,CIZena-5,CMantissa),' Скидка:',
               RealToStr(sumSkidOb,CiZena-5,CMantissa),' Док-тов: ',IntToStr(ndOb,3)+' Устаревших версий: '+
			IntToStr(AllVersia,3));
   Writeln(T);
   Writeln(T,'   Всего ТЧ (товар)      :      ',StrToReal(AllTCh):CiZena:CMantissa);
   Writeln(T);


  err:=false;
  ndOb:=0;
  IORez:=IOResult;
  Assign(FP,Path.ToPrihod+Date+'.prh');
   Reset(FP);
   IORez:=IOResult;
   if IORez <> 0 then
    begin
      MessageBox(^M+#3'Ошибка открытия файла '+Path.ToPrihod+Date+'.prh '+
         'Код: '+IntToStr(IORez,CLitr),Nil,
      mfError+mfCancelButton);
      {exit;} err:=true;
    end;
   Writeln(T);
   Writeln(T,space+'                   РЕЕСТР ДОКУМЕНТОВ ПРИХОДА ');

                  {     1 СОЙФЕРА                         0.00         1958.00 МЯСОЕДОВА    Буфер  }
   writeln(T,space+'----------------------------------------------------------------------------------');
   writeln(T,space+'N док Поставщик              Приход по О/Ц   Приход по Р/Ц Оператор     Статус');
   writeln(T,space+'----------------------------------------------------------------------------------');
   sumOOb:=0;
   sumZOb:=0;

   sumO:=0;
   sumZ:=0;
   nd:=0;
   if not err then While not eof(FP) do
     begin
       ReadpRIHOD(FP,Prih);
       if Prih^.Dat.OperatorSelector=1 then
       begin
        if nd=0 then Writeln(T,space+'{Межскладской приход}');
        PrihString ;
       end;
     end;
 if nd<>0 then
  begin
   writeln(T,space+'----------------------------------------------------------------------------------');
   Writeln(T,'      Всего:                ',RealToStr(sumZ,CiZena,CMantissa),' ',
               RealToStr(sumO,CiZena,CMantissa),'     Документов: ',IntToStr(nd,4));
   writeln(T);
   ndOb:=ndOb+nd;
  end;

   sumOOb:=sumOOb+sumO;
   sumZOb:=sumZOb+sumZ;
   Close(FP);
   IORez:=IOResult;
   Reset(FP);
   IORez:=IOResult;


   sumO:=0;
   sumZ:=0;
   nd:=0;
   if not err then While not eof(FP) do
     begin
       ReadpRIHOD(FP,Prih);
       if Prih^.Dat.OperatorSelector=0 then
       begin
        if nd=0 then Writeln(T,space+'{Приход от клиента}');
        PrihString ;
       end;
     end;
 if nd<>0 then
  begin
   writeln(T,space+'----------------------------------------------------------------------------------');

   Writeln(T,'      Всего:                ',RealToStr(sumZ,CiZena,CMantissa),' ',
               RealToStr(sumO,CiZena,CMantissa),'     Документов: ',IntToStr(nd,4));
   writeln(T);
   ndOb:=ndOb+nd;
  end;
   Close(FP);
   IORez:=IOResult;
   Reset(FP);
   IORez:=IOResult;

   sumOOb:=sumOOb+sumO;
   sumZOb:=sumZOb+sumZ;

   sumO:=0;
   sumZ:=0;
   nd:=0;
   if not err then While not eof(FP) do
     begin
       ReadpRIHOD(FP,Prih);
       if Prih^.Dat.OperatorSelector=2 then
       begin
        if nd=0 then Writeln(T,space+'{Приход по бартеру}');
        PrihString ;
       end;
     end;
  if nd<>0 then
  begin
   writeln(T,space+'----------------------------------------------------------------------------------');
   Writeln(T,'      Всего:                ',RealToStr(sumZ,CiZena,CMantissa),' ',
               RealToStr(sumO,CiZena,CMantissa),'     Документов: ',IntToStr(nd,4));
   writeln(T);
   ndOb:=ndOb+nd;
  end;

   sumOOb:=sumOOb+sumO;
   sumZOb:=sumZOb+sumZ;
   Writeln(T,space+'Всего приход:      О/Ц: ',RealToStr(sumZOb,CiZena,CMantissa),'  Р/Ц: ',RealToStr(sumOOb,CiZena,CMantissa),
           '  Документов: ',IntToStr(ndOb,4));
   if not err then close(FP);


   err:=false;
   ndOb:=0;
   Assign(FV,Path.ToReturn+Date+'.vzw');
   Reset(FV);
   IORez:=IOResult;
   if IORez <> 0 then
    begin
      MessageBox(^M+#3'Ошибка открытия файла '+PAth.ToReturn+Date+'.vzw',Nil,
      mfError+mfCancelButton);
      {exit;} err:=true;
    end;
   Writeln(T);
   Writeln(T,space+'                   РЕЕСТР ДОКУМЕНТОВ ВОЗВРАТА ');

   sumOOb:=0;
   sumZOb:=0;
   sumO:=0;
   sumZ:=0; sv:=0;
                   {   2 КОМСОМОЛЬСКИЙ ООО      78 21-09-99          771.08   -42.42     813.50 БЫКОВА       Введен}
   writeln(T,space+'-----------------------------------------------------------------------------------------------');
   writeln(T,space+'Nдок Клиент             N отгр Дата отг  Сумма возврата Скид.возв  К выдаче Оператор     Статус');
   writeln(T,space+'-----------------------------------------------------------------------------------------------');
   if not err then While not eof(FV) do
     begin
       ReadNewVozwrat(FV,Vozvr);
       VozvrString ;
     end;
   writeln(T,space+'-----------------------------------------------------------------------------------------------');
   Writeln(T,'  Всего возврат на склад: ',RealToStr(sumO,CiZena,CMantissa),
             '  Скидка:', RealToStr(sumZ,CZena,CMantissa),
             '  К выдыче: ',RealToStr(sv,10,CMantissa),'  Документов: ',IntToStr(nd,4){,' ',
               RealToStr(sumO,CiZena,CMantissa)});
  if not err then close(FV);


   err:=false;
   Assign(FR,Path.ToRewisia+Date+'.rwz');
   Reset(FR);
   IORez:=IOResult;
   if IORez <> 0 then
    begin
      MessageBox(^M+#3'Ошибка открытия файла '+PAth.ToRewisia+Date+'.rwz',Nil,
      mfError+mfCancelButton);
      err:=true;
    end;
   Writeln(T);
   Writeln(T,space+'                   РЕЕСТР ДОКУМЕНТОВ РЕВИЗИИ ');

                   {    1            0.00         1254.50        -1254.50 МЯСОЕДОВА}
   writeln(T,space+'------------------------------------------------------------------');
   writeln(T,space+'N док   Всего ревизия   Прих.на склад  Расх.со склада Оператор');
   writeln(T,space+'------------------------------------------------------------------');
   sumOOb:=0;
   sumZOb:=0;
   sumRev:=0;
   sumO:=0;
   sumZ:=0;

   nd:=0;
   if not err then While not eof(FR) do
     begin
       ReadRewisia(FR,Rewis);
       RewisString ;
     end;
   writeln(T,space+'------------------------------------------------------------------');
   Writeln(T,'              Всего ревизия:',RealToStr(sumRev,CiZena,CMantissa),'     Документов: ',IntToStr(nd,4));
   Writeln(T,'              в т.ч. приход:',
              RealToStr(sumZ,CiZena,CMantissa));

   Writeln(T,'                     расход:', RealToStr(sumO,CiZena,CMantissa));
  if not err then close(FR);

   err:=false;
   Assign(FPO,Path.ToCorrect+Date+'.prz');
   Reset(FPO);
   IORez:=IOResult;
   if IORez <> 0 then
    begin
      MessageBox(^M+#3'Ошибка открытия файла '+PAth.ToCorrect+Date+'.prz',Nil,
      mfError+mfCancelButton);
      err:=true;
    end;
   Writeln(T);
   Writeln(T,space+'                   РЕЕСТР ДОКУМЕНТОВ ПЕРЕОЦЕНКИ ');
                   {    1            0.00            0.00            0.00             }
   writeln(T,space+'-------------------------------------------------------------------------');
   writeln(T,space+'N док     Старая Р/Ц.     Новая  Р/Ц.   Всего переоц.  Время    Оператор');
   writeln(T,space+'-------------------------------------------------------------------------');
   sumZOb:=0;
   sumOOb:=0;
   sumRevOb:=0;
   sumOOb:=0;
   sumZOb:=0;
   sumRev:=0;
   sumO:=0;
   sumZ:=0;
   ndOb:=0;
   nd:=0;
   if not err then While not eof(FPO) do
     begin
      ReadPereozenka(FPO,Poz);
      if Poz^.Dat.Vid=0 then
      begin
       if nd=0 then writeln(T,'{Переоценка}');
       PozString ;
      end;
     end;
     writeln(T,space+'-------------------------------------------------------------------------');
     Writeln(T,' Всего:',RealToStr(sumRev,CiZena,CMantissa),' ',
               RealToStr(sumZ,CiZena,CMantissa),' ',RealToStr(sumO,CiZena,CMantissa),'    Документов: ',IntToStr(nd,4));
     writeln(T);

  if not err then reset(FPO);
   nd:=0;
   sumZOb:=0;
   sumOOb:=0;
   sumRevOb:=0;
   if not err then While not eof(FPO) do
     begin
      ReadPereozenka(FPO,Poz);
      if Poz^.Dat.Vid=1 then
      begin
       if nd=0 then writeln(T,'{Переоценка по возвратам}');
       PozString ;
       WRITELN(T,space+'--- Основание: документ N ',Poz^.Dat.DocumentWith,' от ',Poz^.Dat.DateWith);
      end;
     end;
   writeln(T,space+'-------------------------------------------------------------------------');
   Writeln(T,' Всего:',RealToStr(sumRevOb,CiZena,CMantissa),' ',
               RealToStr(sumZOb,CiZena,CMantissa),' ',RealToStr(sumOOb,CiZena,CMantissa),'    Документов: ',IntToStr(nd,4));
   Writeln(T);
   Writeln(T,'           Всего переоценка:',RealToStr(sumO,CiZena,CMantissa),'     Документов: ',IntToStr(ndOb,4));
   Writeln(T,'             по старым. Р/Ц:',
              RealToStr(sumRev,CiZena,CMantissa));

   Writeln(T,'              по новым. Р/Ц:', RealToStr(sumZ,CiZena,CMantissa));
  if not err then close(FPO);

  writeln(T);
  writeln(T,'         Кладовщик     __________________');
  writeln(T,'         Администратор __________________');
  writeln(T,'         Кассир        __________________');
  writeln(T,'         Оператор      __________________');
  writeln(T,'         Учетчик       __________________ ');
  writeln(T);

  Writeln(T,Space,'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
  Writeln(T, Space+'=========================================================================');
  NoInfoMsg;
  close(t);
  Dispose(Poz,Done);
  Dispose(Mark,Done);
  Dispose(Prih,Done);
  Dispose(Vozvr,Done);
  Dispose(Rewis,Done);
  ViewAsText(Path.ToTemp+'Svodnrep.txt',True);
  Report(Path.ToTemp+'Svodnrep.txt','',1,False,False,false);
End;

BEGIN
  {SvodnReport;}
END.