{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}

Unit SmallPrn;

INTERFACE

Uses Glob, NetDBEng,DBEngine,DBEngin2,
     Serv,ServStr,TpDate,ServStr2, Propiss;

Procedure FormSmallMrk(var t: text; E: SupermarketType);

IMPLEMENTATION

{$I Compile.INC}

Const            {123456789012345 1 12345 1234567 12345678}
      SepLine  = '----------------------------------------';
      HeadLine = '������������   :E: ���.: ���� �: �㬬� �';

      CSmallLine = 15;
      CSmallKol = 5;
      CSmallZena = 7;

Procedure FormSmallMrk(var t: text; E: SupermarketType);
Var sName,sName2: String[CName];
    sSmallName,sSmallName2,sSmallName3,sSmallName4: string[CSmallLine];
    sSumma,sAllSumma: String[CIZena];
    sAllKol: string[CKol];
    ws: string;
    i: word;
Begin
  Writeln(t,'      ����⪠ ���㯠⥫� ');
  Writeln(t,'� ���.N '+E.Document+' �� '+E.DateC+' ('+E.TimeC+')');
  Writeln(t,'�����⥫� : ',GetClientField(FClient,E.ClientKod,E.OperatorSelector)+
  '('+E.ClientKod+')');
  Writeln(t,'����� : ',GetAgentField(FAgent,E.AgentKod)+'('+E.AgentKod+')');

  writeln(t,SepLine);
  writeln(t,HeadLine);
  writeln(t,SepLine);

  sAllSumma:='0.00';
  sAllKol:='0';

  for i:=1 to E.Amount do
  begin
    {������������}
    sName:='';
    sName2:='';
    sSmallName:='';
    sSmallName2:='';
    sSmallName3:='';
    sSmallName4:='';

    sName:=GetIdField(FFName,E.MarketElement[i].BazKod);
    sName2:=GetIdField(FName2,E.MarketElement[i].BazKod);

    if ord(sName[0])>CSmallLine then
     begin
       {��ࢠ� ��ப� ������������ � ��� ���⪨� ��ப�}
       sSmallName:=copy(sName,1,CSmallLine);
       sSmallName2:=copy(sName,CSmallLine+1,CSmallLine);
     end
    else
     sSmallName:=sNAme;

    {�᫨ ���� ���� ���� ������������}
    if (ord(sNAme2[0])>0) then
      begin
       ws:=copy(sName2,1,CSmallLine-length(sSmallName2)-1);
       sSmallName2:=sSmallName2+' '+ws;
       System.Delete(sName2,1,length(ws));
      end;

    if ord(sName2[0])>0 then
      begin
       sSmallName3:=copy(sName2,1,CSmallLine);
       System.Delete(sName2,1,CSmallLine);
      end;

    if (ord(sName2[0])>0) then
       sSmallName4:=sName2;

    if (ord(sSmallName4[0])>0) then
    begin
     writeln(t,sSmallName);
     writeln(t,sSmallName2);
     writeln(t,sSmallName3);
     format(sSmallName4,CSmallLine);
     write(t,GlobalPRN^.DAt.Pitch[NPrint^.Dat.Printer]+sSmallName4+':');
    end
    else
    if sSmallName3[0]=#0 then
    begin
      if sSmallName2[0]=#0 then
      begin
      {�᫨ ���� ���⪠� ���窠 ����� ���⠥� ����� ������ ��ப�}
       format(sSmallName,CSmallLine);
       write(t,GlobalPRN^.DAt.Pitch[NPrint^.Dat.Printer]+sSmallName+':');
      end
      else
       begin
        {�᫨ ���� ���⪠� ���窠 �� ����� ���⠥� ����� � ����� ���⪨� ���窨}
        writeln(t,sSmallName);
        format(sSmallName2,CSmallLine);
        write(t,GlobalPRN^.DAt.Pitch[NPrint^.Dat.Printer]+sSmallName2+':');
       end;
    end
    else
    begin
      {�᫨ ����� ���⪠� ���窠 �� ����� ���⠥� 1,2,3 ���⪨� ���窨}
      writeln(t,sSmallName);
      writeln(t,sSmallName2);
      format(sSmallName3,CSmallLine);
      write(t,GlobalPRN^.DAt.Pitch[NPrint^.Dat.Printer]+sSmallName3+':');
    end;

    {��.���}
    write(t,
    copy(GetMeraField(FMera,GetIdField(FMera,E.MarketElement[i].BazKod)),1,1)+':');
    {���}
    rformat(E.MarketElement[i].Input.Kol,CSmallKol);
    write(t,E.MarketElement[i].Input.Kol+':');
    sAllKol:=IntToStr(StrToInt(sAllKOl)+StrToInt(E.MarketElement[i].Input.Kol),CKol);
    {����}
     If E.SkidkaSelector=0 Then{�᫨ ��⮬��}
      MyStr((StrToReal(E.MarketElement[i].Input.Zena)/
      (1+StrToReal(E.MarketElement[i].Input.Proz)/100))
      ,CZena,CMantissa,E.MarketElement[i].Input.Zena){����� 業�}
     Else
       MyStr((StrToReal(E.MarketElement[i].Input.Zena)-
                 StrToReal(E.MarketElement[i].Input.Skidka)),
                    CZena,CMantissa,E.MarketElement[i].Input.Zena);{����� 業�}

    rformat(E.MarketElement[i].Input.Zena,CSmallZena);
    write(t,E.MarketElement[i].Input.Zena+':');
    {�㬬�}
    MyStr(StrToReal(E.MarketElement[i].Input.Zena)*StrToReal(E.MarketElement[i].Input.Kol),CIzena,CMantissa,sSumma);
    rFormat(sSumma,8);
    write(t,sSumma);
    MyStr(StrToReal(sAllSumma)+StrToReal(sSumma),CIZena,CMantissa,sAllSumma);

    writeln(t,GlobalPRN^.DAt.NoPitch[NPrint^.Dat.Printer]);
  end;

  writeln(t,SepLine);
            {123456789012345}
  rFormat(sAllKol,CKol);
  rFormat(sAllSumma,CIZena);
  writeln(t,'�⮣�          :  '+sAllKol+': '+sAllSumma);
  DelSpace(sAllKol);
  DelSpace(sAllSumma);
  Propis(sAllSumma,ws);
  ws[1]:=UpperCase(ws[1]);
  writeln(t,'�ᥣ� ���饭� '+sAllKol+' ������ �� �㬬�:');
  writeln(t,ws);
  writeln(t,'����⨫ _______________');
  writeln(t);
  Writeln(T,TodayString(DateMask)+' "'+DayString[DayOfWeek(ToDay)]+'" ('+Times+')'+
  '   ��� ���㬥��: (', LeadingZero(E.DocSelector),+')');
  writeln(t,'=====================');
End;



BEGIN
END.