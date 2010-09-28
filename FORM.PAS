{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}

{$I Compile.INC}


Unit Form;

Interface

Uses Glob,Dialogs,ServStr,Vision1,Utils;



Procedure FormNakl(Space :TDateString; Video : Boolean;As :DocumentEditZ;Const E:PSuperMarketType;
                   Var Txt:Text; Var NDS,Itogo,ItogoSkidka,NDS20,NDS10,NDS_,NDS18,NDS16:Float;
                            ShowAnswer:Boolean;Zakaz:Boolean;NewSkidka:Boolean;NewSum:Float;MMM:Maska55);


Procedure CalcDivision(E:PSuperMarketType;Var MMM : Maska8;Var Res:Word);

Procedure PrintOtborka(As:DocumentEditZ;MMMM:MAska8;CopyOtborka:Word;Zakaz:Boolean;VzwTxt:AllStr);


Implementation

Uses DBEngine,DBEngin2,MsgBox,Views,Propiss,TpDate,Access,Tools,Vision6,PrnVeks,Utils3,
     NetDBEng,Printers,Objects,Utils2,Prise,Vision5,Serv,Vision11,
     MrkTools,MrkTool,ServStr2,SmallPrn,App,
     Vision7,Vision9,Vision12,UKassa,Utils5;

{Const ReadOnly=0;}


{$IFDEF DPMI}
Procedure FormNakl(Space :TDateString; Video : Boolean;As :DocumentEditZ;Const E:PSuperMarketType;
                   Var Txt:Text; Var NDS,Itogo,ItogoSkidka,NDS20,NDS10,NDS_,NDS18,NDS16:Float;
                   ShowAnswer:Boolean;Zakaz:Boolean;NewSkidka:Boolean;NewSum:Float;MMM:Maska55);
Var l : Word;
    Ver,s,sc,ws,ws1,ws2,ws3 : TMyString;
    Ss,ss1 : String;
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
    ZenaOtgruzki,TempZakupka : AllStr;
    Separator : AllStr;
    Symbol : ArtikulStr;
    Skl : PSkladType;
    SrokExp : ArtikulStr;
    BBB,BBBS : PBazType;
    ZakazNumer : AllStr;
    OSD : PBox;
    s3,s4 : TMystring;
    PPPStart_,PPPStart,PPPStop : TDAteString;
    RR : TRect;
    AllEd : LongInt;
    {SeparatorS : String;}

Procedure WriteNakl;
Var c : Word;
Begin

{$IFDEF NSP}
    ItogoSkidka:=Itogo{+StrToReal(E^.Dat.ENalog)};
{$ELSE}
    ItogoSkidka:=Itogo+StrToReal(E^.Dat.ENalog);
{$ENDIF}
    MySTr(ItogoSkidka,CIZena,CMantissa,tt1);
    MySTr(ItogoS,CIZena,CMantissa,tt2);

    ItogoSkidka:=StrToReal(tt1)-StrToReal(tt2){ItogoS};

    DelSpace(E^.Dat.SummaZ);
    RFormat(E^.Dat.SummaZ,CIZena);
    RFormat(E^.Dat.SummaZakupka,CIZena);
    RFormat(E^.Dat.SummaZakupka2,CIZena);
{    If Video Then Writeln(txt,Space+'______________________________________________________________________________');}

MyStr(StrToReal(E^.Dat.SummaZ),CIZena,CMantissa,E^.Dat.SummaZ);



MyStr(StrToReal(E^.Dat.SummaZakupka),CIZena,CMantissaZ,E^.Dat.SummaZakupka);
MyStr(StrToReal(E^.Dat.SummaZakupka2),CIZena,CMantissaZ,E^.Dat.SummaZakupka2);
MyStr(StrToReal(E^.Dat.SummaAkzis),CIZena,CMantissaZ,E^.Dat.SummaAkzis);
{DelSpace(E^.Dat.SummaZ);}
If Not(Zakaz) Then
BEgin
If R Then
Begin
  If E^.DAt.OperatorSelector in [0,2] Then
   Begin
    Writeln(txt,Space+Dop+'────────────────────────────────────────────────────────────────────────────────────');
    Writeln(Txt,Space+Dop+'Всего позиций:',E^.Dat.Amount:2,'                Всего к оплате:',Recogniz(E^.Dat.SummaZ)+
    ' Мест:'+CalcMesto(E)+' ',AllED:CKol+1,' Шт');
   If Not(Zakaz) And (R) Then
   If (StrToInt(Rek^.Dat.Kod) in [5]) Then
   Writeln(txt,Space+Dop+'   В т.ч. акциз:',RecognizReal(StrToReal(E^.Dat.SummaAkzis),CIZena,CMantissa));

If (Video) And (StrToInt(CurrentPassword)=0) Then
   Begin
    Writeln(Txt,Space+Dop+'                                   Всего закупка:',Recogniz(E^.Dat.SummaZakupka)+
    '    D:'+Recogniz(RealToStr(StrToReal(E^.Dat.SummaZ){-StrToReal(E^.Dat.ENalog)}-StrToReal(E^.Dat.SummaZakupka),
    CIZena,CMantissaZ)));
    Writeln(Txt,Space+Dop+'                                  Всего закупка2:',Recogniz(E^.Dat.SummaZakupka2)+
    '   D2:'+Recogniz(RealToStr(StrToReal(E^.Dat.SummaZ){-StrToReal(E^.Dat.ENalog)}-StrToReal(E^.Dat.SummaZakupka2),
    CIZena,CMantissaZ)));
   End;
   End
   Else
    Begin
    Writeln(txt,Space+Dop+'──────────────────────────────────────────────────────────────────────────────────────────');
    Writeln(Txt,Space+Dop+'Всего позиций:',E^.Dat.Amount:2,'                      Всего к оплате:',Recogniz(E^.Dat.SummaZ)+
    ' Мест:'+CalcMesto(E)+' ',AllED:CKol+1,' Шт');
   If Not(Zakaz) And (R) Then
   If (StrToInt(Rek^.Dat.Kod) in [5]) Then
   Writeln(txt,Space+Dop+'   В т.ч. акциз:',RecognizReal(StrToReal(E^.Dat.SummaAkzis),CIZena,CMantissa));
{$IFNDEF Tabak}

{$ELSE}
    If E^.Dat.OperatorSelector=1 Then
    Begin
    Writeln(Txt,Space+Dop+'                                         Всего закупка:',Recogniz(E^.Dat.SummaZakupka));
    Writeln(Txt,Space+Dop+'                                        Всего закупка2:',Recogniz(E^.Dat.SummaZakupka2));
    End;
{$ENDIF}

If (Video) And (StrToInt(CurrentPassword)=0) And Not(E^.DAt.OperatorSelector=1) Then
   Begin
    Writeln(Txt,Space+Dop+'                                         Всего закупка:',Recogniz(E^.Dat.SummaZakupka)+
    '    D:'+Recogniz(RealToStr(StrToReal(E^.Dat.SummaZ){-StrToReal(E^.Dat.ENalog)}-StrToReal(E^.Dat.SummaZakupka),
    CIZena,CMantissaZ)));
    Writeln(Txt,Space+Dop+'                                        Всего закупка2:',Recogniz(E^.Dat.SummaZakupka2)+
    '   D2:'+Recogniz(RealToStr(StrToReal(E^.Dat.SummaZ){-StrToReal(E^.Dat.ENalog)}-StrToReal(E^.Dat.SummaZakupka2),
    CIZena,CMantissaZ)));
   End;
    End;
End
Else
Begin
    Writeln(txt,Space+Dop+'───────────────────────────────────────────────────────────────');
    Writeln(Txt,Space+Dop+'Всего позиций:',E^.Dat.Amount:2,'                Всего к оплате:',Recogniz(E^.Dat.SummaZ)+
    ' Мест:'+CalcMesto(E)+' ',AllED:CKol+1,' Шт');
   If Not(Zakaz) And (R) Then
   If (StrToInt(Rek^.Dat.Kod) in [5]) Then
   Writeln(txt,Space+Dop+'   В т.ч. акциз:',RecognizReal(StrToReal(E^.Dat.SummaAkzis),CIZena,CMantissa));

{$IFNDEF Tabak}

{$ELSE}
    If E^.Dat.OperatorSelector=1 Then
    Begin
    Writeln(Txt,Space+Dop+'                                         Всего закупка:',Recogniz(E^.Dat.SummaZakupka));
    Writeln(Txt,Space+Dop+'                                        Всего закупка2:',Recogniz(E^.Dat.SummaZakupka2));
    End;
{$ENDIF}

If (Video) And (StrToInt(CurrentPassword)=0) And Not(E^.DAt.OperatorSelector=1) Then
   Begin
    Writeln(Txt,Space+Dop+'                                   Всего закупка:',Recogniz(E^.Dat.SummaZakupka)+
    '    D:'+Recogniz(RealToStr(StrToReal(E^.Dat.SummaZ){-StrToReal(E^.Dat.ENalog)}-StrToReal(E^.Dat.SummaZakupka),
    CIZena,CMantissaZ)));
    Writeln(Txt,Space+Dop+'                                  Всего закупка2:',Recogniz(E^.Dat.SummaZakupka2)+
    '   D2:'+Recogniz(RealToStr(StrToReal(E^.Dat.SummaZ){-StrToReal(E^.Dat.ENalog)}-StrToReal(E^.Dat.SummaZakupka2),
    CIZena,CMantissaZ)));
   End;

End;

End
Else
 Begin
   Writeln(txt,Space+Dop+'─────────────────────────────────────────────────────────────────────────────');
   Writeln(Txt,Space+Dop+'Всего позиций:',E^.Dat.Amount:2,' Всего к оплате(ориентир):',Recogniz(E^.Dat.SummaZ)+
  ' Мест:'+CalcMesto(E)+' ',AllED:CKol+1,' Шт');
   If Not(Zakaz) And (R) Then
   If (StrToInt(Rek^.Dat.Kod) in [5]) Then
   Writeln(txt,Space+Dop+'   В т.ч. акциз:',RecognizReal(StrToReal(E^.Dat.SummaAkzis),CIZena,CMantissa));

If (Video) And (StrToInt(CurrentPassword)=0) And Not(E^.DAt.OperatorSelector=1) Then
   Begin
    Writeln(Txt,Space+Dop+'                                  Всего закупка(ориентир):',Recogniz(E^.Dat.SummaZakupka)+
    '    D:'+Recogniz(RealToStr(StrToReal(E^.Dat.SummaZ){-StrToReal(E^.Dat.ENalog)}-StrToReal(E^.Dat.SummaZakupka),
    CIZena,CMantissaZ)));
    Writeln(Txt,Space+Dop+'                                 Всего закупка2(ориентир):',Recogniz(E^.Dat.SummaZakupka2)+
    '   D2:'+Recogniz(RealToStr(StrToReal(E^.Dat.SummaZ){-StrToReal(E^.Dat.ENalog)}-StrToReal(E^.Dat.SummaZakupka2),
    CIZena,CMantissaZ)));
   End;
 End;


If Not(Zakaz) Then
Begin
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
    If Not Video Then Writeln(txt,Space+Dop+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
    GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+
    GlobalPrn^.Dat.Double[Nprint^.DAt.Printer]+
    ws+
    GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]+
    GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+GlobalPrn^.Dat.NoDouble[Nprint^.DAt.Printer])
    Else Writeln(txt,Space+ws);
    If s[0]<>#0 Then
    If Not Video Then Writeln(txt,Space+Dop+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
    GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+
    GlobalPrn^.Dat.Double[Nprint^.DAt.Printer]+
    s+
    GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]++GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+
    GlobalPrn^.Dat.NoDouble[Nprint^.DAt.Printer])
    Else Writeln(txt,Space+s);

    If r Then
    Writeln(txt,Space+Dop+'────────────────────────────────────────────────────────────────────────────────────')
    Else
    Writeln(txt,Space+Dop+'───────────────────────────────────────────────────────────────');
    End;
  End;{Not Video}

{$IFNDEF Tabak}
    If (E^.Dat.DocSelector in [2,3,4,6,7,8]) Then{5 исключена т.к. в шапке товарный чек}
{$ELSE}
    If (E^.Dat.DocSelector in [2,3,4,6,7,8]) Then{5 исключена т.к. в шапке товарный чек}
{$ENDIF}
     Begin
       Writeln(txt,Space+Dop+'     В т.ч. НДС:',RecognizReal(Nds,CIZena,CMantissa));

       If NDS20>0.009 Then
       If Not Video Then
       Writeln(txt,Space+Dop+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+'         20%   :'+
	  RecognizReal(NDS20,CIZena,CMantissa)+
          GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer])
       Else
       Writeln(txt,Space+Dop+'         20%   :'+
	  RecognizReal(NDS20,CIZena,CMantissa));

       If NDS18>0.009 Then
       If Not Video Then
       Writeln(txt,Space+Dop+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+'         18%   :'+
	  RecognizReal(NDS18,CIZena,CMantissa)+
          GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer])
       Else
       Writeln(txt,Space+Dop+'         18%   :'+
	  RecognizReal(NDS18,CIZena,CMantissa));

       If NDS16>0.009 Then
       If Not Video Then
       Writeln(txt,Space+Dop+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+'         16%   :'+
	  RecognizReal(NDS16,CIZena,CMantissa)+
          GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer])
       Else
       Writeln(txt,Space+Dop+'         16%   :'+
	  RecognizReal(NDS16,CIZena,CMantissa));

       If NDS10>0.009 Then
       If Not Video Then
       Writeln(txt,Space+Dop+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+'         10%   :'+
	  RecognizReal(NDS10,CIZena,CMantissa)+
          GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer])
       Else
       Writeln(txt,Space+Dop+'         10%   :'+
	  RecognizReal(NDS10,CIZena,CMantissa));

       If NDS_>0.009 Then
       If Not Video Then
       Writeln(txt,Space+Dop+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+'         прочие:'+
	  RecognizReal(NDS_,CIZena,CMantissa)+
          GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer])
       Else
       Writeln(txt,Space+Dop+'         прочие:'+
	  RecognizReal(NDS_,CIZena,CMantissa));

(*
{IFDEF Pharm}
    If Not Video Then
    Writeln(txt,Space+Dop+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+
    GlobalPrn^.Dat.Double[Nprint^.DAt.Printer]+
    'НДС не облагается'+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]+
    GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+GlobalPrn^.Dat.NoDouble[Nprint^.DAt.Printer])
    Else
    Writeln(txt,Space+Dop+'НДС не облагается');
{EndIf}
*)

     End;
End;{Not Zakaz}

    Writeln(Txt);

 {$IFDEF Tabak}
  If Not(Video) Then
  If Nprint^.DAt.FullSkidka=5 Then
  Begin
  Writeln(Txt,Space+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+
  'Внимание! В графе примечание для весового товара указана цена в пересчете за 1кг продукции'+
  GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]+GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]);
  Writeln(txt);
  End;
 {$ENDIF}

   If Not(Local) Then
   Begin
   If Not(Video) Then
   Begin
    If R Then
    Begin
     For c:=1 To CDivision Do
      Begin
       If M[c]=1 Then
        Begin
         s:=Rek^.Dat.Otdel[c];
         Format(s,CIZena);
         Writeln(Txt,Space+Dop+'       Сдал (отделение ',c:1,')  '{+GlobalPrn^.Dat.Bold+s+GlobalPrn^.Dat.NoBold}+
         '__________'+'     Товар принял, претензий не имею '+
         '__________')
        End;
      End;{For}
    End
    Else
    Begin
    Writeln(Txt,Space+'            Сдал ________       Товар принял, претензий не имею _______');
    End;
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
 Writeln(Txt,Space+'    '+'  Сдал кладовщик '+OutPutSklad+': '+'__________'+
 '  Товар принял экспедитор: '+'__________');
 Writeln(txt,Space++'    '+'                                           ФИО                                ФИО');
 Writeln(Txt,Space++'    '+'Принял кладовщик '+InputSklad +': '+'__________'+
 '  Товар сдал экспедитор  : __________');
 Writeln(txt,Space++'    '+'                                           ФИО                                ФИО');

   End;
   End;

If Not(Zakaz) Then
Begin
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


   If Not(Video) And (FiktivSkidka=1) And (NewSkidka) Then
    Begin
     ItogoSkidka:=NewSum;
    End;

{$IFNDEF Pharm}
   Writeln(Txt,Space+'{'+RecognizReal(ItogoSkidka,CIZena,CMantissa)+'}');
{$ENDIF}
End;


   If Not(Video) Then
   Begin
{$IFNDEF Pharm}
{    MemC(IntToStr(E^.Dat.OperatorSelector,CKol)+'+'+E^.Dat.AgentKod);}
    If (StrToInt(E^.DAt.AgentKod)<>0)And(E^.Dat.OperatorSelector in[0,2]) Then
{$ELSE}
    If (E^.Dat.OperatorSelector in[0,2]) Then
{$ENDIF}
     Begin
      s:=GetClientField(FAdressF,E^.DAt.ClientKod,E^.Dat.OperatorSelector);
{$IFDEF Tabak}
      s1:=GetClientField(FClient,E^.DAt.ClientKod,E^.Dat.OperatorSelector);
{$ELSE}
      s1[0]:=#0;
{$ENDIF}

      DelSpaceRight(s);
      DelSpaceRight(s1);
      If s1+s<>'' Then
       Begin
        Writeln(txt,Space+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+
	   GlobalPrn^.Dat.Double[Nprint^.DAt.Printer]+s1+' '+s
        +GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]+GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+
	   GlobalPrn^.Dat.NoDouble[Nprint^.DAt.Printer]);
       End;

     End;
   End;


   If E^.Dat.Rashet=2 Then Symbol:='-В'
   Else Symbol:='';


If Not(Zakaz) Then
Begin
{$IFNDEF Pharm}
   If Not(Video)Then Write(txt,Space{+' Всего: '},' '+RecognizReal(Itogo,CIZena,CMantissa),
    '    '+'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')')
{$ELSE}
   If Not(Video)Then Write(txt,Space{+' Всего: '},' '+RecognizReal(Itogo,CIZena,CMantissa),
    '    '+'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')')
{$ENDIF}

   Else
   Writeln(Txt,Space{+' Всего: '},' '+RecognizReal(Itogo,CIZena,CMantissa));

   If Not(Video) Then
   Writeln(txt,'            '+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+
   GlobalPrn^.Dat.Double[Nprint^.DAt.Printer]+
   ' Тип документа: (',LeadingZero(E^.Dat.DocSelector),+Symbol+') '+ZakazNumer+E^.DAt.Document+'/'+
   IntToStr(StrToInt(E^.Dat.SkladKod),COne)+
   GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]+GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+
   GlobalPrn^.Dat.NoDouble[Nprint^.DAt.Printer]);
End
 Else
  Begin
   If Not(Video)Then WriteLn(txt,Space+''+'"'+DayString[DayOfWeek(ToDay)]+'" '+
   TodayString(DateMask)+'('+Times+')     '+
   +GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+
   GlobalPrn^.Dat.Double[Nprint^.DAt.Printer]+' Тип документа: (',
   LeadingZero(E^.Dat.DocSelector),Symbol+') '+ZakazNumer+IntToStr(StrToInt(E^.Dat.SkladKod),COne)+
   GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]+GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+
   GlobalPrn^.Dat.NoDouble[Nprint^.DAt.Printer]);
  End;
{$IfDEF DPMI}
   If (E^.Dat.OperatorSelector in[0,2]) Then
   Writeln(txt,Space+'=========================================================')
   Else
   Writeln(txt,Space+'=========================================================');
{$ENDIF}
End;


Begin
   If Not Video Then
   Begin
    PPPStart_:=Header;
    PPPStart:=HeaderStop;
    PPPStop:=ONLYLINK;
   End
   Else
    Begin
     PPPStart_[0]:=#0;
     PPPStart[0]:=#0;
     PPPStop[0]:=#0;
    End;

   ItogoS:=0;ItogoSkidka:=0;Itogo:=0;{ NDS:=0;} NdsPos:=0;

   If E^.Dat.DocSelector in [0,1,2,3,4] Then E^.Dat.Srok:=0;

   Str(E^.DAt.Srok-DateStringToDate(DateMask,E^.Dat.DateC):CLitrMAntissa,srokexp);
   DelSpace(SrokExp);



   ZakazNumer[0]:=#0;
   AllEd:=0;

   If Zakaz Then
   Begin
    ZakazNumer:=E^.Dat.FromZakaz;
    DelSpace(ZakazNumer);
    ZakazNumer:='ЗЛ '+ZakazNumer+'/';
   End;

  {If E^.Dat.DocSelector in [0,1,2,3,4] Then E^.Dat.Srok:=0;
   Str(E^.DAt.Srok-DateStringToDate(DateMask,E^.Dat.DateC):CLitrMAntissa,srokexp);
   DelSpace(SrokExp);}


If Not(Zakaz) Then
Begin
   If (E^.Dat.Realiz) And Not(E^.Dat.DocSelector in [5,6,7,8]) Then
   Begin
   R:=False;
   Dop:='          ';
   End
   Else
   Begin
   R:=True;
   Dop[0]:=#0;
   End;
End
Else
   {для случая загрузочной ведомости}
   Begin
   R:=True;
   Dop[0]:=#0;
   End;

   {SeparatorS:='│';}
   If E^.Dat.OperatorSelector in [0,2] Then Local:=False
   Else Local:=True;


   For l:=1 To E^.Dat.Amount Do
   Begin
   MyStr(StrToReal(E^.Dat.MarketElement[l].Input.Zena)*StrToInt(E^.Dat.MarketElement[l].Input.Kol)
   ,CIZena,CMantissa,ws);
   Itogo:=Itogo+StrToReal(Ws);
   End;


   If E^.Dat.SkidkaSelector=0 Then Ver:=Space+'Скидка: Авто '
   Else Ver:=Space+'Скидка: Ручная';

   If (E^.Dat.Versia>1) And ((Not(E^.Dat.Realiz)) Or ((E^.Dat.Realiz)And Not(E^.Dat.DocSelector in [0,1,2,3,4])))
     Then
    Begin
     Ver:=Ver+'                                                             Версия: '+IntToStr(E^.Dat.Versia,CLitrMantissa);
    End;

   Writeln(txt,ver);

   If Not Zakaz Then
 Begin
   If E^.Dat.Oformlenie=1 Then
    Begin
     ZakazNumer[0]:=#0;
     (* Отключено из=за проблем с бухгалтерией 26/03/01*)
     ZakazNumer:=E^.DAt.FromZakaz;
     DelSpace(ZakazNumer);
     ZakazNumer:='ЗЛ '+ZakazNumer+'/';

     If Video Then
     Writeln(txt,Space+Dop+'По заказу N '+E^.DAt.FromZakaz)
     Else
     Writeln(txt,Space+Dop+GlobalPrn^.Dat.Italic[Nprint^.Dat.Printer]+'По заказу N '+E^.DAt.FromZakaz+
        +GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]);
    End;
 End;{If Not Zakaz}

   DrawSkidka:=True;

   If ShowAnswer Then
   Begin
(*выключена 20/03/2004 тк устарела
   If Not(LoCal) Then
   Begin
    If (StrToInt(E^.DAt.AgentKod)<>0) Then
       Begin
        If MessageBox(^M+#3'Включать ставки скидок в накладную?',Nil,mfWarning+mfOkCancel)=cmcancel Then
        DrawSkidka:=False;
       End;{служба доставки}
   End;
*)
   End;

{$IFDEF Pharm}
     If Not Video Then
    Begin
      s3:=E^.Dat.Comment1;
      s4:=E^.Dat.Comment2;
      DelSpaceRight(s3);
      DelSpaceRight(s4);
      If s3+s4<>'' Then
       Begin
        Writeln(txt,Space+Dop+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+
	   GlobalPrn^.Dat.Double[Nprint^.DAt.Printer]+s3+' '+s4+
        +GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]+GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+
	   GlobalPrn^.Dat.NoDouble[Nprint^.DAt.Printer]);
       End;
    End;
{$ENDIF}



{--------------------------------------------------------------------------------------78901234}


If Not(Video) Then
Begin
DInfoMsg('Формирую документ. Ждите...',True);
End;


If Not Zakaz Then
Begin
If R Then
Begin
 If (E^.Dat.OperatorSelector in [0,2]) Then
 Begin
   Writeln(txt,PPPStart_+
               Space+Dop+'┌──────────────────────────────────────────────────────────────────────────────────┐');
   Writeln(txt,Space+Dop+'│N  Код  Наименование товара        Колич     Цена Итого сумма  Упаковок Отд Примеч│');
   Writeln(txt,Space+Dop+'└──────────────────────────────────────────────────────────────────────────────────┘'+PPPStart);
                         { 1 12345│12345678901234567890123456│12345│12345678│12345678901│123456789│123│1234567 │}

 End
  Else
  Begin
   Space:='';
   Writeln(txt,PPPStart_+
               Space+Dop+'┌──────────────────────────────────────────────────────────────────────────────────────────┐');
{$IFNDEF TABAK}
   Writeln(txt,Space+Dop+'│N  Код  Наименование товара        Колич     Цена   НП  Итого сумма  Упаковок Отд Акц.сбор│');
{$ELSE}
   Writeln(txt,Space+Dop+'│N  Код  Наименование товара        Колич     Цена   НП       З/Цена  Упаковок Отд Акц.сбор│');
{$ENDIF}
   Writeln(txt,Space+Dop+'└──────────────────────────────────────────────────────────────────────────────────────────┘'+
   PPPStart);
  End;                   { 1 12345│12345678901234567890123456│12345│12345678│12345│12345678901│123456789│123│123456789│}
	End
Else
Begin
   Writeln(txt,PPPStart_+
               Space+Dop+'┌─────────────────────────────────────────────────────────────┐');
   Writeln(txt,Space+Dop+'│N  Код  Наименование товара        Колич     Цена Итого сумма│');
   Writeln(txt,Space+Dop+'└─────────────────────────────────────────────────────────────┘'+PPPStart);
                         { 1 12345│12345678901234567890123456│12345│12345678│12345678901│123456789│123│1234567│}
End;
End
 Else
  Begin
   Writeln(txt,PPPStart_+
               Space+Dop+'┌─────────────────────────────────────────────────────────────────────────────┐');
   Writeln(txt,Space+Dop+'│                                   Забронировано      Дефицит                │');
   Writeln(txt,Space+Dop+'│N  Код  Наименование товара        Колич.Упаковок  Колич. Упаковок Отд Примеч│');
                         {12│12345│12345678901234567890123456│12345│123456789│12345│123456789│123│123456}
   Writeln(txt,Space+Dop+'└─────────────────────────────────────────────────────────────────────────────┘'+PPPStart);
  End;


RR.Assign(0, 0, 0, 0);
OSD := New(PBox, Init(RR, 1, Nil));
OSD^.NewList(New(PTextCollection, Init(0,1)));
{создаем список сопроводительных документов в накладной}
Creat_OSD(E,OSD);

   c:=0;
   WordToBit8(c,M);
   For l:=1 To E^.Dat.Amount Do
    Begin
     Str(l:CMantissa,St);
     s:=E^.Dat.MarketElement[l].BazKod;

   New(Skl,Init);
   New(BBB,Init);
     Skl^.Dat.BazKod:=E^.Dat.MarketElement[l].BazKod;
     GetSkladRecord(Skl);

     {подставляем СД из накладной расхода}
     If MarketSD=0 Then GetOLD_OSD(OSD,Skl);

     GetBazElement(E^.Dat.MarketElement[l].BazKod,BBB^.Dat);
{     if E^.Dat.MarketElement[l].BazKod='26064'
      Then
      Begin
       Readln;
      End;}
     If Not(E^.DAt.MarketElement[l].Input.Last) Then
     Separator:=' '  Else Separator:=#249;
     If Nprint^.DAt.FullName=0 Then
     Begin
      ws:=BBB^.Dat.Name{GetIdField(FName,E^.Dat.MarketElement[l].BazKod)};
      ws1:=BBB^.Dat.Name2{GetIdField(FName2,E^.Dat.MarketElement[l].BazKod)};
      DelSpaceRight(ws1);
      If ws1[0]<>#0 Then
          Begin
           If MMM[l]=1 Then
           Writeln(txt,Space+Dop+st+Separator+s+#16+ws){маркер отгруженного сертификата}
           Else
           Writeln(txt,Space+Dop+st+Separator+s+' '+ws);
           Separator:=' ';
           st:='  ';
           ws:=ws1;
           s:='     ';
       End;
     End
     Else
         Begin
        ws:=BBB^.Dat.Name{GetIdField(FName,E^.Dat.MarketElement[l].BazKod)};
        ws1:=BBB^.Dat.Name2{GetIdField(FName2,E^.Dat.MarketElement[l].BazKod)};
        DelSpaceRight(ws1);
       If ws1[0]<>#0 Then
          Begin
           If MMM[l]=1 Then
           Writeln(txt,Space+Dop+st+Separator+s+#16+ws){маркер отгруженного сертификата}
           Else
           Writeln(txt,Space+Dop+st+Separator+s+' '+ws);
        Separator:=' ';
        st:='  ';
        ws:=ws1;
        s:='     ';
       End;
      End;
   { If Nprint^.DAt.FullName=0 Then
     ws:=GetIdField(FName,E^.Dat.MarketElement[l].BazKod)
     Else ws:=GetIdField(FFname,E^.Dat.MarketElement[l].BazKod); }
     Format(ws,CName);
     If MMM[l]=1 Then
      Begin
       If ws1[0]<>#0 Then s:=s+' '+ws
       Else s:=s+#16+ws;
      End
     Else
     s:=s+' '+ws;


     DelSpace(E^.Dat.MarketElement[l].Input.Kol);
     ws:=E^.Dat.MarketElement[l].Input.Kol;
     AllEd:=AllEd+StrToInt(E^.Dat.MarketElement[l].Input.Kol);

     ws:='{'+ws+'}';
     RFormat(ws,CKol+2);
     s:=s+{' '}+ws;
     Str(StrToReal(E^.Dat.MarketElement[l].Input.Zakupka):CInputIZena-2{в 11 символов}:CMantissaZ,TempZakupka);

If Not Zakaz Then
Begin

     If E^.Dat.SkidkaSelector=0 Then{Если автомат}
      begin
       DelSpace(E^.Dat.MarketElement[l].Input.Proz);

       MyStr((StrToReal(E^.Dat.MarketElement[l].Input.Zena)/
       (1+StrToReal(E^.Dat.MarketElement[l].Input.Proz)/100)),CZena,CMantissa,ws);

       {отключен расчет налога с продажи в товарном чеке}
       If E^.DAt.DocSelector in [(*{1,}2,3,5,6*)100] Then
       Begin
       Mystr(((1+strtoreal(e^.dat.marketelement[l].Input.SpecNalog)
              /100)),CLitr,CMantissa,koefficient);

       {новая цена}

{$IFDEF NSP}
       MyStr(StrToReal(ws){*StrToReal(Koefficient)},CZena,CMantissa,ws);
{$ELSE}
       MyStr(StrToReal(ws)*StrToReal(Koefficient),CZena,CMantissa,ws);
{$ENDIF}
      End;

       s:=s+{' '}+ws;

       ZenaOtgruzki:=ws;


  If E^.Dat.OperatorSelector=1 Then
    Begin
     Nalog:=E^.Dat.MarketElement[l].Input.SpecNalog;
     MyStr(StrToReal(Nalog),CLitr,CMantissa,Nalog);
     s:=s+' '+Nalog;
    End;

       MyStr((StrToReal(Ws)*StrToInt(E^.Dat.MarketElement[l].Input.Kol))
       ,CInputIZena-2{в 11 символов},CMantissa,ws);

       ItogoS:=ItogoS+StrToReal(wS);

{$IFNDEF TAbak}
       If E^.Dat.OperatorSelector=0 Then
       s:=s+' '+ws
       Else
       s:=s+' '+ws;
{$ELSE}
       If E^.Dat.OperatorSelector in [0,2] Then
       s:=s+' '+ws
       Else
       s:=s+' '+TempZakupka;
{$ENDIF}
      end
     Else
      Begin
{      ItogoSkidka:=ItogoSkidka+StrToReal(E^.Dat.MarketElement[l].Input.Skidka)*StrToInt(E^.Dat.MarketElement[l].Input.Kol);
       {сумма скидки}
       MyStr((StrToReal(E^.Dat.MarketElement[l].Input.Zena)-StrToReal(E^.Dat.MarketElement[l].Input.Skidka))
       ,CZena,CMantissa,ws);

       {отключен расчет налога с продажи в товарном чеке}
       If E^.DAt.DocSelector in [(*{1,}2,3,5,6*)100] Then
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

       ZenaOtgruzki:=ws;

  If E^.Dat.OperatorSelector=1 Then
    Begin
     Nalog:=E^.Dat.MarketElement[l].Input.SpecNalog;
     MyStr(StrToReal(Nalog),CLitr,CMantissa,Nalog);
     s:=s+' '+Nalog;
    End;
       MyStr((StrToReal(Ws)*StrToInt(E^.Dat.MarketElement[l].Input.Kol))
       ,CInPutIZena-2{в 11 символов},CMantissa,ws);

       ItogoS:=ItogoS+StrToReal(wS);

{$IFNDEF TAbak}
       If E^.Dat.OperatorSelector=0 Then
       s:=s+' '+ws
       Else
       s:=s+' '+ws;
{$ELSE}
       If E^.Dat.OperatorSelector in [0,2] Then
       s:=s+' '+ws
       Else
       s:=s+' '+TempZakupka;
{$ENDIF}
      { s:=s+' '+ws;}
      End;

     NdsPos:=StrToReal(Ws)*
     StrToReal(E^.Dat.MarketElement[l].Input.NDS)/
     (100+StrToReal(E^.Dat.MarketElement[l].Input.NDS));
    {StrToReal(BakGetField(FNDS,E^.Dat.MarketElement[l].BazKod,0))/
     (100+StrToReal(BakGetField(FNDS,E^.Dat.MarketElement[l].BazKod,0)));}
     MyStr(NdsPos,CIZena,CMantissa,ws);
     NdsPos:=StrToReal(Ws);
     {Nds:=Nds+NdsPos;}
End;{If Not Zakaz}

      M[E^.Dat.MarketElement[l].Input.DivisionNumber]:=1;

     If R Then {Если не вторичный документ консигнации}
      Begin
      {посчитали упаковки}
      pp:=CalcPackNoFile(BBB^.Dat.InPack{E^.Dat.MarketElement[l].BazKod},E^.Dat.MarketElement[l].Input.Kol);
      DelSpace(Pp);
      RFormat(Pp,CPack);
      If Not(Zakaz) Then
      s:=s+' '+pp
      Else
       Begin
        s:=s+' '+PP+'               ';
       End;
      {добавили отделение}
      Str(E^.Dat.MarketElement[l].Input.DivisionNumber:2,ws);

      {Если скидка автоматическая и не нулевая}

   If E^.Dat.OperatorSelector in [0,2] Then
Begin
      Case E^.Dat.SkidkaSelector Of
      0:Begin{скидка автоматическая}
       Case Nprint^.DAt.FullSkidka Of
       0:Begin{скидка в процентах}
         If DrawSkidka Then
         Begin
          If (StrToReal(E^.Dat.MarketElement[l].Input.Proz)<>0) Then
           Begin
            TempSkidka:=E^.Dat.MarketElement[l].Input.Proz;

            Format(TempSkidka,CProz+1);
            {если на экран}
            If Video Then ws:=ws+' '+'('+TempSkidka+')'
            {если на печать}
            Else ws:=ws+' '+'('+TempSkidka+')';
           End
            Else ws:=ws+' '+' '+'_______';
          End{DrawSkidka}
         Else
          Begin
           ws:=ws+' '+' '+'_______';
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
            Format(WspomSkidka,CProz+1);
            If Video Then ws:=ws+' '+'('+WspomSkidka+')'
            {если на печать}

            Else ws:=ws+' ('+WspomSkidka+')';
           End
            Else ws:=ws+' '+' '+'_______';
         End{DrawSkidka}
         Else
          Begin
           ws:=ws+' '+' '+'_______';
          End;
         End;{Case FullSkidka 1}
       2: Begin
           ws:=ws+' '+' '+'_______';
          End;
      3: Begin
           ws:=ws+' '+RealToStr(StrToReal(E^.Dat.MarketElement[l].Input.Zakupka),CZena,CMantissaZ);
          End;
      4:Begin
           ws:=ws+' '+RealToStr(StrToReal(E^.Dat.MarketElement[l].Input.Zakupka2),CZena,CMantissaZ);
        End;
      5:Begin
           If BBB^.Dat.Recalc=0 Then
           ws:=ws+' '+' '+'_______'
           Else
            Begin
             If StrToReal(BBB^.Dat.Massa)>0.001 Then
             MyStr(StrToReal(ZenaOtgruzki)/StrToReal(BBB^.Dat.Massa),CZena,CMantissa,ZenaOtgruzki)
             Else  ZenaOtgruzki:='   ???  ';
             ws:=ws+' '+ZenaOtgruzki;
            End;
        End;
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
            If Video Then ws:=ws+' '+'('+WspomSkidka+')'
            {если на печать}
            Else ws:=ws+' '+'('+WspomSkidka+')';
          End
          Else ws:=ws+' '+' '+'_______';
         End {DrawSkidka}
         Else
          Begin
           ws:=ws+' '+' '+'_______';
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

           If Video Then ws:=ws+' '+'('+WspomSkidka+')'
           {если на печать}
           Else ws:=ws+' '+'('+WspomSkidka+')';
          End
          Else ws:=ws+' '+' '+'_______';
        End
         Else
          Begin
             ws:=ws+' '+' '+'_______';
          End;
          End;{Case FullSkidka 1}
       2: Begin
           ws:=ws+' '+' '+'_______';
          End;
       3: Begin
           ws:=ws+' '+RealToStr(StrToReal(E^.Dat.MarketElement[l].Input.Zakupka),CZena,CMantissaZ);
          End;
      4:Begin
           ws:=ws+' '+RealToStr(StrToReal(E^.Dat.MarketElement[l].Input.Zakupka2),CZena,CMantissaZ);
        End;
      5:Begin
           If BBB^.Dat.Recalc=0 Then
           ws:=ws+' '+' '+'_______'
           Else
            Begin
             If StrToReal(BBB^.Dat.Massa)>0.001 Then
             MyStr(StrToReal(ZenaOtgruzki)/StrToReal(BBB^.Dat.Massa),CZena,CMantissa,ZenaOtgruzki)
             Else  ZenaOtgruzki:='   ???  ';
             ws:=ws+' '+ZenaOtgruzki;
            End;
        End;
          Else;
          End;{Case FullSkidka}

        End;{1 Case}

      Else;{Case}
      End;{Case}
End
   Else
     Begin
     {эта ветвь печатает ставку акцизного сбора в накладной межскладской}
      MyStr(StrToReal(E^.Dat.MarketElement[l].Input.AkzisSbor){*StrToReal(E^.Dat.MarketElement[l].Input.Kol)},
	    CZenaZ-1,CMantissaZ,wspomSkidka);
      ws:=ws+' '+' '+wspomSkidka;
     End;
      End{If r}
      Else
           Begin
            pp[0]:=#0;
            ws[0]:=#0;
           End;

     If Not Video Then s:=GlobalPrn^.Dat.Pitch[Nprint^.DAt.Printer]+s+' '+ws+
	GlobalPrn^.Dat.NoPitch[Nprint^.DAt.Printer]
     Else s:=s+' '+ws;

     {вставляем номер версии}
     If EnablePosVersion=1 Then
     If E^.Dat.MarketElement[l].Input.Version<>1 Then
     {MemC(IntToStr(E^.Dat.MarketElement[l].Input.Version,CMantissa));}
     If Not Video Then
     s:=s+' '+GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
	IntToStr(E^.Dat.MarketElement[l].Input.Version,CMantissa)+
              GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]
     Else
     s:=s+' '+IntToStr(E^.Dat.MarketElement[l].Input.Version,CMantissa);

 If DefaultSetMArker=1 Then
 Begin
 If E^.DAt.MarketElement[l].Input.RegionMArka=0 Then s:=s+' '+NoMArker
 Else s:=s+' '+YesMArker;
 End;

     If l=E^.Dat.Amount Then s:=PPPStop+s;

     Writeln(txt,Space+Dop+St+Separator+s);

{    Writeln(txt,Space+Dop+St+' '+s);}
{!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!}
If E^.Dat.OperatorSelector in [0,2] Then
Begin
     If PrintSertifDoc[2]=1 Then
      Begin
       If (E^.Dat.MarketElement[l].Input.NSertif[0]<>#0) And
             (E^.Dat.MarketElement[l].Input.NSertif<>NoSertifStr) Then
       Begin
If (E^.Dat.DocSelector<>1) Then
Begin
New(BBBS,Init);
GetBazElement(E^.Dat.MarketElement[l].Input.NSertif,BBBS^.Dat);

           ws1:=BBBS^.Dat.Name{GetIdField(FName,E^.Dat.MarketElement[l].Input.NSertif)};
           DelSpaceRight(ws1);
        ws2:=BBBS^.Dat.Name2{GetIdField(FName2,E^.Dat.MarketElement[l].Input.NSertif)};
           DelSpaceRight(ws2);
           ws2:=ws1+' '+ws2;
           DelSpaceRight(ws2);

        If Not Video Then
           Write(txt,Space+' Сертификат: ',GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+
           ws2+' ('+E^.Dat.MarketElement[l].Input.NSertif+')'+GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+
		 GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer])
        Else
           Write(txt,Space+' Сертификат: ',ws2+' ('+E^.Dat.MarketElement[l].Input.NSertif+')');

      ws1:=BBBS^.Dat.DSertif{GetIDField(FDateSertif,E^.Dat.MarketElement[l].Input.NSertif)};
      DelSpaceRight(ws1);
      If ws1[0]<>#0 Then
          Begin
        If Not(Video) Then
        Begin
         If ws2[0]<>#0 Then
            WriteLn(txt,Space+' Срок дейст: ',GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
		  GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+
            ws1+GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]+' ')
         Else
            WriteLn(txt,Space+'   Срок дейст: ',GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
		  GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+
            ws1+GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]+' ')
        End
        Else
        BEgin
         If ws2[0]<>#0 Then
             WriteLn(txt,Space+' Срок дейст: ',+ws1+' ')
         Else
             WriteLn(txt,Space+'    Срок дейст: ',+ws1+' ');
        End
          End
      Else
      If ws2[0]<>#0 Then Writeln(txt);

      {отключена печать графы кем выдан сертификат
      ws2:=GetIDField(FKtoSertif,E^.Dat.MarketElement[l].Input.NSertif);
      DelSpaceRight(ws2);
      If ws2[0]<>#0 Then
       Begin
           If ws1[0]<>#0 Then
         Begin
          If Not Video Then
        Writeln(txt,' Выдан: ',GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+ws2+
             GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer])
          Else
        Writeln(txt,' Выдан: ',+ws2);
         End
           Else
         Begin
          If Not Video Then
                Writeln(txt,Space+'         Выдан: ',GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+
			 GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+ws2+
                       GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer])
          Else
                Writeln(txt,Space+'         Выдан: ',+ws2);
         End;
       End
      Else  If ws1[0]<>#0 Then Writeln(txt);
     }
Dispose(BBBS,Done);
End;{если не товарный чек}
       End;{сертификаты}
      End;{PrintSertifDoc[2]}


     If PrintAkzisDoc[2]=1 Then
     Begin
       ss:=Skl^.Dat.Input.StrihKod{Akzis1{BakGetField(FAkzis,E^.Dat.MarketElement[l].BazKod,0)};
       DelSpaceRight(ss);
       If not(ss[0]=#0) Then
        Begin
         Format(ss,CSertif);
         If Not(Video) Then ss:=GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+ss+
            GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer];
         ss:=Space+'    Штрих-код: '+ss;

         Writeln(txt,ss);
        End;
     End;


     If PrintExpert[2]=1 Then

     If
     {$IFNDEF Pharm}
	(E^.Dat.MarketElement[l].Input.RegionMarka=1) And
     {$ENDIF}
	(Skl^.Dat.Input.Expert<>NoExpertStr) Then
     Begin
       ss:=GetExpertField(FExpert,Skl^.Dat.Input.Expert);
       DelSpaceRight(ss);
       If not(ss[0]=#0) Then
        Begin
         ss:=ss+' ('+Skl^.Dat.Input.Expert+')';
         If Not(Video) Then ss:=GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+ss+
            GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer];
         ss:=Space+'   '+Expert_RegNom^+': '+ss;
         Writeln(txt,ss);
        End;
     End;

IF Pharm=0 Then
Begin
     If PrintGTD[2]=1 Then
     Begin
       ss[0]:=#0;
       ss1[0]:=#0;
{$IFNDEF Tabak}
       If (Skl^.Dat.Input.NGTD<>NoNGTDStr) Or FindPAram('/DEBUGP') Then
       Begin
        ss:=GetNGTDField(FNGTD,Skl^.Dat.Input.NGTD);
        DelSpaceRight(ss);
       End;

       If BBB^.Dat.PostKod<>NoPostStr Then
       Begin
        ss1:=GetPostField(FPost,BBB^.Dat.PostKod);
        DelSpaceRight(ss1);
       End;


       If (Skl^.Dat.Input.NGTD<>NoNGTDSTr) Or FindPAram('/DEBUGP') Or (BBB^.Dat.PostKod<>NoPostStr) Then
        Begin

         ss:=ss+' ('+Skl^.Dat.Input.NGTD+')';
         If (Skl^.Dat.Input.NGTD<>NoNGTDStr) Or FindPAram('/DEBUGP')  Then
         Begin
         If Not(Video) Then ss:=GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+ss+
	    GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+
            GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer];
         ss:=Space+'  ГТД: '+ss;
         End
         else ss[0]:=#0;

         If BBB^.Dat.PostKod<>NoPostStr Then
         Begin
         ss1:=ss1+' ('+BBB^.Dat.PostKod+')';
         If Not(Video) Then ss1:=GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+ss1+
	    GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+
            GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer];
            If ss[0]=#0 Then
            ss:=ss+'      Производство: '+ss1
            Else
            ss:=ss+' Производство: '+ss1
         End;

         Writeln(txt,ss);
        End;
{$ENDIF}
     End;
End
 Else
  Begin
     If PrintGTD[2]=1 Then
     Begin
       ss[0]:=#0;
       ss1[0]:=#0;
{$IFNDEF Tabak}
       If (Skl^.Dat.Input.NGTD<>NoNGTDStr) Or FindPAram('/DEBUGP') Then
       Begin
        ss:=GetNGTDField(FNGTD,Skl^.Dat.Input.NGTD);
        DelSpaceRight(ss);
       End;

       If BBB^.Dat.FirmaPostKod<>NoPostStr Then
       Begin
        ss1:=GetFirmaPostField(FFirmaPost,BBB^.Dat.FirmaPostKod);
        DelSpaceRight(ss1);
       End;

       If (Skl^.Dat.Input.NGTD<>NoNGTDSTr) Or FindPAram('/DEBUGP') Or (BBB^.Dat.FirmaPostKod<>NoPostStr) Then
        Begin

         ss:=ss+' ('+Skl^.Dat.Input.NGTD+')';
         If (Skl^.Dat.Input.NGTD<>NoNGTDStr) Or FindPAram('/DEBUGP')  Then
         Begin
         If Not(Video) Then ss:=GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+ss+
	    GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+
            GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer];
         ss:=Space+'  ГТД: '+ss;
         End
         else ss[0]:=#0;

         If BBB^.Dat.FirmaPostKod<>NoPostStr Then
         Begin
         ss1:=ss1+' ('+BBB^.Dat.FirmaPostKod+')';
         If Not(Video) Then ss1:=GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+ss1+
	    GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+
            GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer];
            If ss[0]=#0 Then
            ss:=ss+'      Производство: '+ss1
            Else
            ss:=ss+' Производство: '+ss1
         End;

         Writeln(txt,ss);
        End;
{$ENDIF}
     End;
  End;


     If PrintAkzisDate[2]=1 Then
      Begin
       ws1[0]:=#0;
       If Skl^.Dat.Input.Marka<>NoMarkaStr Then
       Begin
       ws1:=GetMarkaField(FMarka,Skl^.Dat.Input.Marka){BakGetField(FMarka,E^.Dat.MarketElement[l].BazKod,0)};
       DelSpaceRight(ws1);
       If ws1[0]<>#0 Then
         Begin
          ws1:=ws1+' ('+Skl^.Dat.Input.Marka+')';
          If Not Video Then
          Write(txt,Space+{'Акцизная марка: '}Seria_Akzis^+': ',GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
		GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+
          ws1+GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]+' ')
          Else
          Write(txt,Space+{'Акцизная марка: '}Seria_Akzis^+': ',ws1+' ')
         End;
       End;

       ws2:=Skl^.Dat.Input.Virabotano;
       DelSpaceRight(ws2);

       If DateStringToDate(DateMask,ws2)<=DateStringToDate(DateMask,'01-01-00') Then
       ws2[0]:=#0;

       If ws2[0]<>#0 Then
        Begin
         If ws1[0]<>#0 Then
          Begin
           If Not Video Then
              WriteLn(txt,'Дата выработки: ',GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
		    GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+
         ws2+GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer])
           Else
              WriteLn(txt,'Дата выработки: ',ws2);
          End
         Else
          Begin
           If Not Video Then
               WriteLn(txt,Space+'Дата выработки: ',GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
			GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+
               ws2+GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer])
           Else
               WriteLn(txt,Space+'Дата выработки: ',ws2);
          End;
        End
       Else
         if ws1[0]<>#0 Then WriteLn(txt);

       ws2:=Skl^.Dat.Input.Godnost{BakGetField(FGodnost,E^.Dat.MarketElement[l].BazKod,0)};
       DelSpaceRight(ws2);


       If DateStringToDate(DateMask,ws2)<=DateStringToDate(DateMask,'01-01-00') Then
       ws2[0]:=#0;



       DelSpaceRight(ws2);
       If ws2[0]<>#0 Then
         Begin
          If Not Video Then
           WriteLn(txt,Space+'Реализовать до: ',GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
		 GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+
           ws2+GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer])
          Else
           WriteLn(txt,Space+'Реализовать до: ',ws2);
         End;
(*   If PrintGTD[2]=1 Then
     Begin
       ss:=Skl1^.Dat.Input.NGTD{BakGetField(FNGTD,E^.Dat.MarketElement[l].BazKod,0)};
       DelSpaceRight(ss);
       ss1:=Skl1^.Dat.Input.Post{BakGetField(FPost,E^.Dat.MarketElement[l].BazKod,0)};
       DelSpaceRight(ss1);
       If (ss[0]<>#0)Or (ss1[0]<>#0) Then
        Begin
         Format(ss,CNSertif);
         If ss[0]<>#0 Then
         Begin
         If Not(Video) Then ss:=GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+ss+
	    GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+
            GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer];
         ss:=Space+'   '+'      N ГТД: '+ss;
         End
         else ss:=Space+'   ';
         If ss1[0]<>#0 Then
         Begin
         If Not(Video) Then ss1:=GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+ss1+
	    GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+
            GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer];
            ss:=ss+' Производство: '+ss1;
         End;
         Writeln(txt,ss);
        End;
     End;*)

      End;{печать акцизных марок и дат розлива}
     End{OperatorSelector}
     Else
      Begin

     If PrintSertifDoc[1]=1 Then
      Begin
       If (E^.Dat.MarketElement[l].Input.NSertif[0]<>#0) And
             (E^.Dat.MarketElement[l].Input.NSertif<>NoSertifStr) Then
       Begin
New(BBBS,Init);
GetBazElement(E^.Dat.MarketElement[l].Input.NSertif,BBBS^.Dat);

           ws1:=BBBS^.Dat.Name{GetIdField(FName,E^.Dat.MarketElement[l].Input.NSertif)};
           DelSpaceRight(ws1);
        ws2:=BBBS^.Dat.Name2{GetIdField(FName2,E^.Dat.MarketElement[l].Input.NSertif)};
           DelSpaceRight(ws2);
           ws2:=ws1+' '+ws2;
           DelSpaceRight(ws2);
        If Not Video Then
           Write(txt,Space+'    Сертификат: ',GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
		 GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+
           ws2+' ('+E^.Dat.MarketElement[l].Input.NSertif+')'+GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+
		 GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer])
        Else
           Write(txt,Space+'    Сертификат: ',ws2+' ('+E^.Dat.MarketElement[l].Input.NSertif+')');

      ws1:=BBBS^.Dat.DSertif{GetIDField(FDateSertif,E^.Dat.MarketElement[l].Input.NSertif)};
      DelSpaceRight(ws1);
      If ws1[0]<>#0 Then
          Begin
        If Not(Video) Then
        Begin
        If ws2[0]<>#0 Then
           WriteLn(txt,Space+'    Срок дейст: ',GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
		 GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+
            ws1+GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]+' ')
        Else
           WriteLn(txt,Space+'    Срок дейст: ',GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
		 GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+
            ws1+GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]+' ')
        End
        Else
           WriteLn(txt,Space+'    Срок дейст: ',+ws1+' ')
          End
        Else If ws2[0]<>#0 Then Writeln(txt);


      If BBBS^.Dat.KSertif<>NoOrganStr Then
       Begin
         ws2:=GetKSertifField(FKSertif,BBBS^.Dat.KSertif);
         DelSpaceRight(ws2);
         ws2:=ws2+' ('+BBBS^.Dat.KSertif+')';
           If ws1[0]<>#0 Then
         Begin
          If Not Video Then
             Writeln(txt,' Выдан: ',GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+ws2+
             GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer])
          Else
	   Writeln(txt,' Выдан: ',ws2);
         End
           Else
         Begin
          If Not Video Then
                Writeln(txt,Space+'         Выдан: ',GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
			 GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]++ws2+
                       GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer])
          Else
                Writeln(txt,Space+'         Выдан: ',+ws2);
         End;
       End
      Else  If ws1[0]<>#0 Then Writeln(txt);
Dispose(BBBS,Done);

      End;{сертификаты}
      End;


     If PrintAkzisDoc[1]=1 Then
     Begin
       ss:=Skl^.Dat.Input.StrihKod{Akzis1{BakGetField(FAkzis,E^.Dat.MarketElement[l].BazKod,0)};
       DelSpaceRight(ss);
       If not(ss[0]=#0) Then
        Begin
         Format(ss,CSertif);
         If Not(Video) Then ss:=GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+ss+
            GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer];
         ss:=Space+'    Штрих-код: '+ss;
         Writeln(txt,ss);
        End;
     End;


     If PrintExpert[1]=1 Then
     If
     {$IFNDEF Pharm}
		(E^.Dat.MarketElement[l].Input.RegionMarka=1) And
     {$ENDIF}
		(Skl^.Dat.Input.Expert<>NoExpertStr) Then
     Begin
       ss:=GetExpertField(FExpert,Skl^.Dat.Input.Expert);
       DelSpaceRight(ss);
       If not(ss[0]=#0) Then
        Begin
         ss:=ss+' ('+Skl^.Dat.Input.Expert+')';
         {Format(ss,CExpert);}
         If Not(Video) Then ss:=GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+ss+
            GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer];
         ss:=Space+'   '+Expert_RegNom^+': '+ss;
         Writeln(txt,ss);
        End;
     End;


     If PrintAkzisDate[1]=1 Then
      Begin
       ws1[0]:=#0;
       If Skl^.Dat.Input.Marka<>NoMarkaStr Then
       Begin
       ws1:=GetMarkaField(FMarka,Skl^.Dat.Input.Marka){BakGetField(FMarka,E^.Dat.MarketElement[l].BazKod,0)};
       DelSpaceRight(ws1);
          ws1:=ws1+' ('+Skl^.Dat.Input.Marka+')';
          If Not Video Then
          Write(txt,Space+{'Акцизная марка: '}Seria_Akzis^+': ',GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
		GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+
          ws1+GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]+' ')
          Else
          Write(txt,Space+{'Акцизная марка: '}Seria_Akzis^+': ',ws1+' ')
       End;
       ws2:=Skl^.Dat.Input.Virabotano{BakGetField(FVirabotano,E^.Dat.MarketElement[l].BazKod,0)};
       DelSpaceRight(ws2);

       If DateStringToDate(DateMask,ws2)<=DateStringToDate(DateMask,'01-01-00') Then
       ws2[0]:=#0;

       If ws2[0]<>#0 Then
        Begin
         If ws1[0]<>#0 Then
          Begin
           If Not Video Then
              WriteLn(txt,'Дата выработки: ',GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
		    GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+
         ws2+GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer])
           Else
              WriteLn(txt,'Дата выработки: ',ws2);
          End
         Else
          Begin
           If Not Video Then
               WriteLn(txt,Space+'Дата выработки: ',GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
			GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+
               ws2+GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer])
           Else
               WriteLn(txt,Space+'Дата выработки: ',ws2);
          End;
        End
       Else
         if ws1[0]<>#0 Then WriteLn(txt);

       ws2:=Skl^.Dat.Input.Godnost{BakGetField(FGodnost,E^.Dat.MarketElement[l].BazKod,0)};
       DelSpaceRight(ws2);

       If DateStringToDate(DateMask,ws2)<=DateStringToDate(DateMask,'01-01-00') Then
       ws2[0]:=#0;

       DelSpaceRight(ws2);
       If ws2[0]<>#0 Then
         Begin
          If Not Video Then
           WriteLn(txt,Space+'Реализовать до: ',GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
		 GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+
           ws2+GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer])
          Else
           WriteLn(txt,Space+'Реализовать до: ',ws2);
         End;

      End;{печать акцизных марок и дат розлива}

If Pharm=0 Then
Begin
     If PrintGTD[1]=1 Then
     Begin
{$IFNDEF Tabak}
{05/05/2004 по просьбе шутова чтобы печатались ГТД и страна только в СФ}
{в версии ТП отключена печать ГТД и производителя в накладной клиента даже если включена настройка}
       ss[0]:=#0;
       ss1[0]:=#0;

       If Skl^.Dat.Input.NGTD<>NoNGTDStr Then
       Begin
        ss:=GetNGTDField(FNGTD,Skl^.Dat.Input.NGTD);
        DelSpaceRight(ss);
       End;

       If BBB^.Dat.PostKod<>NoPostStr Then
       Begin
        ss1:=GetPostField(FFirmaPost,BBB^.Dat.PostKod);
        DelSpaceRight(ss1);
       End;

       If (Skl^.Dat.Input.NGTD<>NoNGTDSTr) Or (BBB^.Dat.PostKod<>NoPostStr) Then
        Begin

         ss:=ss+' ('+Skl^.Dat.Input.NGTD+')';
         If Skl^.Dat.Input.NGTD<>NoNGTDStr Then
         Begin
         If Not(Video) Then ss:=GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+ss+
	    GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+
            GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer];
         ss:=Space+'  ГТД: '+ss;
         End
         else ss[0]:=#0;

         If BBB^.Dat.PostKod<>NoPostStr Then
         Begin
         ss1:=ss1+' ('+BBB^.Dat.PostKod+')';
         If Not(Video) Then ss1:=GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+ss1+
	    GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+
            GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer];
            If ss[0]=#0 Then
            ss:=ss+'      Производство: '+ss1
            Else
            ss:=ss+' Производство: '+ss1
         End;

         Writeln(txt,ss);
        End;
{$ENDIF}
     End;
End
 Else
  Begin
     If PrintGTD[1]=1 Then
     Begin
       ss[0]:=#0;
       ss1[0]:=#0;

       If Skl^.Dat.Input.NGTD<>NoNGTDStr Then
       Begin
        ss:=GetNGTDField(FNGTD,Skl^.Dat.Input.NGTD);
        DelSpaceRight(ss);
       End;

       If BBB^.Dat.FirmaPostKod<>NoPostStr Then
       Begin
        ss1:=GetFirmaPostField(FPost,BBB^.Dat.FirmaPostKod);
        DelSpaceRight(ss1);
       End;

       If (Skl^.Dat.Input.NGTD<>NoNGTDSTr) Or (BBB^.Dat.FirmaPostKod<>NoPostStr) Then
        Begin

         ss:=ss+' ('+Skl^.Dat.Input.NGTD+')';
         If Skl^.Dat.Input.NGTD<>NoNGTDStr Then
         Begin
         If Not(Video) Then ss:=GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+ss+
	    GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+
            GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer];
         ss:=Space+'  ГТД: '+ss;
         End
         else ss[0]:=#0;

         If BBB^.Dat.FirmaPostKod<>NoPostStr Then
         Begin
         ss1:=ss1+' ('+BBB^.Dat.FirmaPostKod+')';
         If Not(Video) Then ss1:=GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+ss1+
	    GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+
            GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer];
            If ss[0]=#0 Then
            ss:=ss+'      Производство: '+ss1
            Else
            ss:=ss+' Производство: '+ss1
         End;

         Writeln(txt,ss);

        End;
     End;
  End;


       End;
    Dispose(Skl,Done);
    Dispose(BBB,Done);

    End;
WriteNakl;

Dispose(OSD,Done);

If Not(Video) Then NoInfoMsg;
End;




{$ELSE}
Procedure FormNakl(Space :TDateString; Video : Boolean;As :DocumentEditZ;Const E:PSuperMarketType;
                   Var Txt:Text; Var NDS,Itogo,ItogoSkidka,NDS20,NDS10,NDS_,NDS18,NDS16:Float;
                            ShowAnswer:Boolean;Zakaz:Boolean;NewSkidka:Boolean;NewSum:Float;MMM:Maska55);
Begin
End;
{$ENDIF}



Procedure CalcDivision(E:PSuperMarketType;Var MMM : Maska8;Var Res:Word);
Var c : Word;
Begin
 Res:=0;
 For c:=1 To E^.Dat.Amount Do
  Begin
   If MMM[E^.DAt.MarketElement[c].Input.DivisionNumber]=0 Then
    Begin
     If StrToInt(E^.DAt.MarketElement[c].Input.Kol)>0 Then
      Begin
       MMM[E^.DAt.MarketElement[c].Input.DivisionNumber]:=1;
       Inc(Res);
      End;
    End;
  End;{For}
End;



Function TestLastPosition(l:Word;E:PSuperMarketType;Cur:Word):Boolean;
Var j : Word;
Begin
TestLastPosition:=True;
 For j:=l+1 To E^.Dat.Amount Do
  Begin
   If E^.DAt.MarkeTElement[j].Input.DivisionNumber=Cur Then
    Begin
     TestLastPosition:=False;
     Exit;
    End;
  End;

End;

Function SelectOtborkaDiv(Var M:Maska8):Boolean;
Label 1;
var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  SOtd : Array[1..CDivision] Of String[CIZena];
  k,j,c : Word;
  MM : Maska8;
Begin
SelectOtborkaDiv:=False;
1:
R.Assign(6, 9, 74, 14);
New(Dlg, Init(R, 'Укажите отделения для печти отоборочных листов'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx := $E002;

MM:=m;
Convert8(mm);
BitToWord8(MM,j);

Invert8(MM);
BitToWord8(MM,k);


For c:=1 To CDivision Do
 Begin
  SOtd[c]:=Rek^.Dat.Otdel[c];
  Format(SOtd[c],12);
 End;

R.Assign(1, 1, 67, 4);
Control := New(PCheckboxes, Init(R,
  NewSItem(SOtd[1]+'(~1~)',
  NewSItem(SOtd[2]+'(~2~)',
  NewSItem(SOtd[3]+'(~3~)',
  NewSItem(SOtd[4]+'(~4~)',
  NewSItem(SOtd[5]+'(~5~)',
  NewSItem(SOtd[6]+'(~6~)',
  NewSItem(SOtd[7]+'(~7~)',
  NewSItem(SOtd[8]+'(~8~)',
  Nil))))))))));
Dlg^.Insert(Control);
PCluster(Control)^.SetButtonState(k, False);

Dlg^.SelectNext(False);
Dlg^.SetData(j);

c:=Desktop^.ExecView(Dlg);
If c<>cmCancel Then
 Begin
  Dlg^.GetData(j);
  If j=0 Then
   Begin
    Dispose(Control,Done);
    Dispose(Dlg,Done);
    Goto 1;
   End;
  WordToBit8(j,M);
  Convert8(M);
  (*
  Writeln;
  Writeln;
  Writeln;
  Writeln;
  Writeln;
  Writeln;
  Writeln;
  Writeln;
  Writeln;
  Writeln;
  Writeln;
  Writeln;
  Writeln;
  Writeln;
  For c:=1 To CDivision Do
   Begin
    Writeln(M[c]);
   End;
  Readln;
  *)
  SelectOtborkaDiv:=True;
 End;
 Dispose(Control,Done);
 Dispose(Dlg,Done);
End;



Procedure PrintOtborka(As:DocumentEditZ;MMMM:MAska8;CopyOtborka:Word;Zakaz:Boolean;VzwTxt:AllStr);
Var txt2 : Text;
    NewCount,BakCopy,
    Position,l,c,Cur: Word;
    AllEd : LongInt;
    E : PSuperMarketType;
    Ez : PZakazType;
    RR : TRect;
    BBB,BBBS : PBazType;
    Skl : PSkladType;
    st,ss1,ss,ws,ws1,ws2 : String;
    koefficient : TDAteString;
    OSD : PBox;
    Oplata : Real;
    ZakazNumer,
    pp,SO,Separator,SOtd,Space,ZenOpl : AllStr;
    Ver,s : String;
    Logik,Video : Boolean;
Begin
 If Not SelectOtborkaDiv(MMMM) Then Exit;
 For Cur:=1 To CDivision Do
 Begin
 If MMMM[Cur]=1 Then
 Begin
 SOtd:=Rek^.Dat.Otdel[Cur];
 Format(SOtd,CIZena);
 DelSpaceRight(SOtd);
 DInfoMsg('Формирую отборочный лист по отделению '+SOtd+'...',FAlse);

 Space:='     ';
 Assign(Txt2,Path^.Dat.ToTemp+'otborka.txt');
 c:=IOResult;
 Rewrite(Txt2);
 c:=IOResult;
 If c <> 0 Then
  Begin
   NoInfo;
   MessageBox(#3^M+#3'Не могу создать файл отчета '+Path^.Dat.ToTemp+'otborka.txt'+
   +' Код:'+IntToStr(c,3),Nil,mfError+mfCancelButton);
   Exit;
  End;


If Zakaz Then{схема обработки если загрузочный лист}
 Begin

 New(Ez,Init);
 If Not GetZakaz(As.EditPosition,EZ) Then
  Begin
   c:=IoResult;
   Close(txt2);
   c:=IoResult;
   Dispose(Ez,Done);
   MessageBox(#3'Заказ N '+As.EditPosition+' не найден!',Nil,mfError+mfCancelButton);
   Exit;
  End;

 {преобразуем заказ в накладную}
 New(E,Init);
 ZakazToMarket(E,Ez);

 E^.Dat.Oformlenie:=1;
 E^.Dat.FromZakaz:=As.EditPosition;
 DelSpace(E^.Dat.FromZakaz);

 End{If Zakaz Then}
 Else
  Begin{схема обработки если накладная}

   New(E,Init);
   If Not GetMarket1(As,E) Then
    Begin
     c:=IoResult;
     Close(txt2);
     c:=IoResult;
     Dispose(E,Done);
     MessageBox(#3'Документ N '+As.EditPosition+' от '+As.D+' не найден!',Nil,mfError+mfCancelButton);
     Exit;
    End;

  End;{Else}


 Writeln(Txt2,Header+Space+'Оператор: '+E^.Dat.Caption+' Агент: '+E^.Dat.AgentKod+' EYE & 1997-00');
 Writeln(Txt2 ,Space+
 GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+' Внимание! Документ предназначен только для внутреннего использования!'+
 GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]+HeaderStop);

If Zakaz Then
 Begin
  s:=DateToDateString(DateMask,DateStringToDate(DateMAsk,E^.Dat.DateC)+Ez^.Dat.EndDate);
  Writeln(Txt2,Space+'Срок доставки заказа до: '+s);
  Case Ez^.Dat.Oformlenie Of
0:Writeln(Txt2,Space+'Статус: Подлежит оформлению');
1:Writeln(Txt2,Space+'Статус: По заказу оформлен - документ N '+Ez^.Dat.DocReal+' от '+Ez^.Dat.DocDate);
2:Writeln(Txt2,Space+'Статус: Заказ анулирован по истечении срока резервирования!');
  Else;
  End;{Case}


  Writeln(Txt2,Header+Space+'          О Т Б О Р О Ч Н Ы Й  л и с т  N '+'ЗЛ '+Ez^.Dat.Document+
  '/'+IntToStr(StrToInt(E^.Dat.SkladKod),CMantissa)+ ' от ',Ez^.Dat.DAteC+' ('+ Ez^.Dat.TimeC+')');

 End{If Zakaz}
 Else
  Begin

  Writeln(Txt2,Header+Space+'          О Т Б О Р О Ч Н Ы Й  л и с т  N '+E^.Dat.Document+VzwTxt+
  '/'+IntToStr(StrToInt(E^.Dat.SkladKod),CMantissa)+ ' от ',E^.Dat.DAteC+' ('+ E^.Dat.TimeC+')');

   If E^.Dat.Oformlenie=1 Then
    Begin
     ZakazNumer[0]:=#0;
     ZakazNumer:=E^.DAt.FromZakaz;
     DelSpace(ZakazNumer);
     ZakazNumer:='ЗЛ '+ZakazNumer+'/';
     Writeln(txt2,Space+GlobalPrn^.Dat.Italic[Nprint^.Dat.Printer]+'По заказу N '+E^.DAt.FromZakaz+
        +GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]);
    End;

  End;

  RR.Assign(0, 0, 0, 0);
  OSD := New(PBox, Init(RR, 1, Nil));
  OSD^.NewList(New(PTextCollection, Init(0,1)));
  Creat_OSD(E,OSD);

   Writeln(Txt2,Space+'                                                            Версия: '+
   IntToStr(E^.Dat.Versia,CLitrMantissa));
   Writeln(Txt2,Space+'Отделение: '+SOtd+' ('+IntToStr(Cur,CKol)+')');
   Writeln(Txt2,Space+'Поставщик: '+GetMakeField(FClient,Rek^.Dat.Kod,1));
   Writeln(Txt2,Space+'Получатель: ',GetClientField(FClient,E^.Dat.ClientKod,E^.Dat.OperatorSelector)+
   ' ('+E^.Dat.ClientKod+')');
   Writeln(txt2,Space+'┌──────────────────────────────────────────────────────────────────────────────┐');
   Writeln(txt2,Space+'│                                     Электронно       Фактически              │');
   Writeln(txt2,Space+'│N  Код  Наименование товара         Колич.  Упаковок Колич. Упаковок Отд Прим.│');
                       {12│12345│12345678901234567890123456│12345│123456789│12345│123456789│123│123456}
   Writeln(txt2,Space+'└──────────────────────────────────────────────────────────────────────────────┘'+
   HeaderStop);

   AllEd:=0;
   Position:=0;
   Oplata:=0;
   NewCount:=0;

   For l:=1 To E^.Dat.Amount Do
    Begin

     If Cur<>E^.Dat.MarketElement[l].Input.DivisionNumber Then Continue;

     {MemC(IntToStr(MMMM[E^.Dat.MarketElement[l].Input.DivisionNumber],CKol));}

     Inc(NewCount);
     Str(NewCount:CMantissa,St);
     s:=E^.Dat.MarketElement[l].BazKod;

     New(Skl,Init);
     New(BBB,Init);
     Inc(Position);

     Skl^.Dat.BazKod:=E^.Dat.MarketElement[l].BazKod;
     GetSkladRecord(Skl);

     {подставляем СД из накладной расхода}
     If MarketSD=0 Then GetOLD_OSD(OSD,Skl);

     GetBazElement(E^.Dat.MarketElement[l].BazKod,BBB^.Dat);

     If Not(E^.DAt.MarketElement[l].Input.Last) Then
     Separator:=' '  Else Separator:=#249;
     If Nprint^.DAt.FullName=0 Then
     Begin
      ws:=BBB^.Dat.Name;
      ws1:=BBB^.Dat.Name2;
      DelSpaceRight(ws1);
      If ws1[0]<>#0 Then
          Begin
           Writeln(txt2,Space+st+Separator+s+' '+ws);
           Separator:=' ';
           st:='  ';
           ws:=ws1;
           s:='     ';
       End;
     End
     Else
         Begin
        ws:=BBB^.Dat.Name{GetIdField(FName,E^.Dat.MarketElement[l].BazKod)};
        ws1:=BBB^.Dat.Name2{GetIdField(FName2,E^.Dat.MarketElement[l].BazKod)};
        DelSpaceRight(ws1);
       If ws1[0]<>#0 Then
          Begin
           Writeln(txt2,Space+st+Separator+s+' '+ws);
        Separator:=' ';
        st:='  ';
        ws:=ws1;
        s:='     ';
       End;
      End;
   { If Nprint^.DAt.FullName=0 Then
     ws:=GetIdField(FName,E^.Dat.MarketElement[l].BazKod)
     Else ws:=GetIdField(FFname,E^.Dat.MarketElement[l].BazKod); }
     Format(ws,CName);

     s:=s+' '+ws;


     DelSpace(E^.Dat.MarketElement[l].Input.Kol);
     ws:=E^.Dat.MarketElement[l].Input.Kol;


     If E^.Dat.SkidkaSelector=0 Then{Если автомат}
      begin
       DelSpace(E^.Dat.MarketElement[l].Input.Proz);

       MyStr((StrToReal(E^.Dat.MarketElement[l].Input.Zena)/
       (1+StrToReal(E^.Dat.MarketElement[l].Input.Proz)/100)),CZena,CMantissa,ZenOpl);

       {отключен расчет налога с продажи в товарном чеке}
       If E^.DAt.DocSelector in [100] Then
       Begin
       Mystr(((1+strtoreal(e^.dat.marketelement[l].Input.SpecNalog)
              /100)),CLitr,CMantissa,koefficient);

       {новая цена}

{$IFDEF NSP}
       MyStr(StrToReal(ZenOpl){*StrToReal(Koefficient)},CZena,CMantissa,ZenOpl);
{$ELSE}
       MyStr(StrToReal(ZenOpl)*StrToReal(Koefficient),CZena,CMantissa,ZenOpl);
{$ENDIF}
      End;
     End
      Else
       Begin

       MyStr((StrToReal(E^.Dat.MarketElement[l].Input.Zena)-
       (StrToReal(E^.Dat.MarketElement[l].Input.Skidka))),CZena,CMantissa,ZenOpl);

       {отключен расчет налога с продажи в товарном чеке}
       If E^.DAt.DocSelector in [100] Then
       Begin
       Mystr(((1+strtoreal(e^.dat.marketelement[l].Input.SpecNalog)
              /100)),CLitr,CMantissa,koefficient);

       {новая цена}

{$IFDEF NSP}
       MyStr(StrToReal(ZenOpl){*StrToReal(Koefficient)},CZena,CMantissa,ZenOpl);
{$ELSE}
       MyStr(StrToReal(ZenOpl)*StrToReal(Koefficient),CZena,CMantissa,ZenOpl);
{$ENDIF}
      End;

       End;


     Oplata:=Oplata+StrToInt(E^.Dat.MarketElement[l].Input.Kol)*StrToReal(ZenOpl);

     AllEd:=AllEd+StrToInt(E^.Dat.MarketElement[l].Input.Kol);

     ws:='{'+ws+'}';
     RFormat(ws,CKol+2);
     s:=s+{' '}+ws;

     pp:=CalcPackNoFile(BBB^.Dat.InPack,E^.Dat.MarketElement[l].Input.Kol);
     DelSpace(Pp);
     RFormat(Pp,CPack);
     Str(E^.Dat.MarketElement[l].Input.DivisionNumber:2,ws);
     s:=s+' '+PP+'                  '+ws+'      ';

     s:=GlobalPrn^.Dat.Pitch[Nprint^.DAt.Printer]+s+GlobalPrn^.Dat.NoPitch[Nprint^.DAt.Printer];

     {вставляем номер версии}
     If EnablePosVersion=1 Then
     If E^.Dat.MarketElement[l].Input.Version<>1 Then
     s:=s+' '+GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
	IntToStr(E^.Dat.MarketElement[l].Input.Version,CMantissa)+
     GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer];

     If DefaultSetMArker=1 Then
     Begin
      If E^.DAt.MarketElement[l].Input.RegionMArka=0 Then s:=s+' '+NoMArker
      Else s:=s+' '+YesMArker;
     End;

   If TestLastPosition(l,E,Cur) Then s:=ONLYLINK+s;

   Writeln(txt2,Space+St+Separator+s);
(*
If E^.Dat.OperatorSelector in [0,2] Then
Begin
     If PrintSertifDoc[2]=1 Then
      Begin
       If (E^.Dat.MarketElement[l].Input.NSertif[0]<>#0) And
             (E^.Dat.MarketElement[l].Input.NSertif<>NoSertifStr) Then
       Begin
If (E^.Dat.DocSelector<>1) Then
Begin
New(BBBS,Init);
GetBazElement(E^.Dat.MarketElement[l].Input.NSertif,BBBS^.Dat);

           ws1:=BBBS^.Dat.Name{GetIdField(FName,E^.Dat.MarketElement[l].Input.NSertif)};
           DelSpaceRight(ws1);
        ws2:=BBBS^.Dat.Name2{GetIdField(FName2,E^.Dat.MarketElement[l].Input.NSertif)};
           DelSpaceRight(ws2);
           ws2:=ws1+' '+ws2;
           DelSpaceRight(ws2);

           Write(txt2,Space+' Сертификат: ',GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
		 GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+
           ws2+' ('+E^.Dat.MarketElement[l].Input.NSertif+')'+GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+
		 GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]);

      ws1:=BBBS^.Dat.DSertif{GetIDField(FDateSertif,E^.Dat.MarketElement[l].Input.NSertif)};
      DelSpaceRight(ws1);
      If ws1[0]<>#0 Then
          Begin
         If ws2[0]<>#0 Then
            WriteLn(txt2,Space+' Срок дейст: ',GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
		  GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+
            ws1+GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]+' ')
         Else
            WriteLn(txt2,Space+'   Срок дейст: ',GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
		  GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+
            ws1+GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]+' ')
          End
      Else
      If ws2[0]<>#0 Then Writeln(txt2);

      {отключена печать графы кем выдан сертификат
      ws2:=GetIDField(FKtoSertif,E^.Dat.MarketElement[l].Input.NSertif);
      DelSpaceRight(ws2);
      If ws2[0]<>#0 Then
       Begin
           If ws1[0]<>#0 Then
         Begin
          If Not Video Then
        Writeln(txt2,' Выдан: ',GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+ws2+
             GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer])
          Else
        Writeln(txt2,' Выдан: ',+ws2);
         End
           Else
         Begin
          If Not Video Then
                Writeln(txt2,Space+'         Выдан: ',GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+
			 GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+ws2+
                       GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer])
          Else
                Writeln(txt2,Space+'         Выдан: ',+ws2);
         End;
       End
      Else  If ws1[0]<>#0 Then Writeln(txt2);
     }
Dispose(BBBS,Done);
End;{если не товарный чек}
       End;{сертификаты}
      End;{PrintSertifDoc[2]}


     If PrintAkzisDoc[2]=1 Then
     Begin
       ss:=Skl^.Dat.Input.StrihKod{Akzis1{BakGetField(FAkzis,E^.Dat.MarketElement[l].BazKod,0)};
       DelSpaceRight(ss);
       If not(ss[0]=#0) Then
        Begin
         Format(ss,CSertif);
         ss:=GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+ss+
            GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer];
         ss:=Space+'    Штрих-код: '+ss;

         Writeln(txt2,ss);
        End;
     End;


     If PrintExpert[2]=1 Then
     If (E^.Dat.MarketElement[l].Input.RegionMarka=1) And
	(Skl^.Dat.Input.Expert<>NoExpertStr) Then
     Begin
       ss:=GetExpertField(FExpert,Skl^.Dat.Input.Expert);
       DelSpaceRight(ss);
       If not(ss[0]=#0) Then
        Begin
         ss:=ss+' ('+Skl^.Dat.Input.Expert+')';
         ss:=GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+ss+
            GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer];
         ss:=Space+'   Эксп.закл.: '+ss;
         Writeln(txt2,ss);
        End;
     End;

IF Pharm=0 Then
Begin
     If PrintGTD[2]=1 Then
     Begin
       ss[0]:=#0;
       ss1[0]:=#0;
{$IFNDEF Tabak}
       If (Skl^.Dat.Input.NGTD<>NoNGTDStr) Or FindPAram('/DEBUGP') Then
       Begin
        ss:=GetNGTDField(FNGTD,Skl^.Dat.Input.NGTD);
        DelSpaceRight(ss);
       End;

       If BBB^.Dat.PostKod<>NoPostStr Then
       Begin
        ss1:=GetPostField(FPost,BBB^.Dat.PostKod);
        DelSpaceRight(ss1);
       End;


       If (Skl^.Dat.Input.NGTD<>NoNGTDSTr) Or FindPAram('/DEBUGP') Or (BBB^.Dat.PostKod<>NoPostStr) Then
        Begin

         ss:=ss+' ('+Skl^.Dat.Input.NGTD+')';
         If (Skl^.Dat.Input.NGTD<>NoNGTDStr) Or FindPAram('/DEBUGP')  Then
         Begin
         ss:=GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+ss+
	    GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+
            GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer];
         ss:=Space+'  ГТД: '+ss;
         End
         else ss[0]:=#0;

         If BBB^.Dat.PostKod<>NoPostStr Then
         Begin
         ss1:=ss1+' ('+BBB^.Dat.PostKod+')';
         ss1:=GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+ss1+
	    GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+
            GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer];
            If ss[0]=#0 Then
            ss:=ss+'      Производство: '+ss1
            Else
            ss:=ss+' Производство: '+ss1
         End;

         Writeln(txt2,ss);
        End;
{$ENDIF}
     End;
End
 Else
  Begin
     If PrintGTD[2]=1 Then
     Begin
       ss[0]:=#0;
       ss1[0]:=#0;
{$IFNDEF Tabak}
       If (Skl^.Dat.Input.NGTD<>NoNGTDStr) Or FindPAram('/DEBUGP') Then
       Begin
        ss:=GetNGTDField(FNGTD,Skl^.Dat.Input.NGTD);
        DelSpaceRight(ss);
       End;

       If BBB^.Dat.FirmaPostKod<>NoPostStr Then
       Begin
        ss1:=GetFirmaPostField(FFirmaPost,BBB^.Dat.FirmaPostKod);
        DelSpaceRight(ss1);
       End;

       If (Skl^.Dat.Input.NGTD<>NoNGTDSTr) Or FindPAram('/DEBUGP') Or (BBB^.Dat.FirmaPostKod<>NoPostStr) Then
        Begin

         ss:=ss+' ('+Skl^.Dat.Input.NGTD+')';
         If (Skl^.Dat.Input.NGTD<>NoNGTDStr) Or FindPAram('/DEBUGP')  Then
         Begin
         ss:=GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+ss+
	    GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+
            GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer];
         ss:=Space+'  ГТД: '+ss;
         End
         else ss[0]:=#0;

         If BBB^.Dat.FirmaPostKod<>NoPostStr Then
         Begin
         ss1:=ss1+' ('+BBB^.Dat.FirmaPostKod+')';
         ss1:=GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+ss1+
	    GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+
            GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer];
            If ss[0]=#0 Then
            ss:=ss+'      Производство: '+ss1
            Else
            ss:=ss+' Производство: '+ss1
         End;

         Writeln(txt2,ss);
        End;
{$ENDIF}
     End;
  End;


     If PrintAkzisDate[2]=1 Then
      Begin
       ws1[0]:=#0;
       If Skl^.Dat.Input.Marka<>NoMarkaStr Then
       Begin
       ws1:=GetMarkaField(FMarka,Skl^.Dat.Input.Marka){BakGetField(FMarka,E^.Dat.MarketElement[l].BazKod,0)};
       DelSpaceRight(ws1);
       If ws1[0]<>#0 Then
         Begin
          ws1:=ws1+' ('+Skl^.Dat.Input.Marka+')';
          Write(txt2,Space+{'Акцизная марка: '}Seria_Akzis^+': ',GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
		GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+
          ws1+GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]+' ')
         End;
       End;

       ws2:=Skl^.Dat.Input.Virabotano;
       DelSpaceRight(ws2);

       If DateStringToDate(DateMask,ws2)<=DateStringToDate(DateMask,'01-01-00') Then
       ws2[0]:=#0;

       If ws2[0]<>#0 Then
        Begin
         If ws1[0]<>#0 Then
          Begin
              WriteLn(txt2,'Дата выработки: ',GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
		    GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+
         ws2+GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer])
          End
         Else
          Begin
               WriteLn(txt2,Space+'Дата выработки: ',GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
			GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+
               ws2+GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer])
          End;
        End
       Else
         if ws1[0]<>#0 Then WriteLn(txt2);

       ws2:=Skl^.Dat.Input.Godnost{BakGetField(FGodnost,E^.Dat.MarketElement[l].BazKod,0)};
       DelSpaceRight(ws2);


       If DateStringToDate(DateMask,ws2)<=DateStringToDate(DateMask,'01-01-00') Then
       ws2[0]:=#0;



       DelSpaceRight(ws2);
       If ws2[0]<>#0 Then
         Begin
           WriteLn(txt2,Space+'Реализовать до: ',GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
		 GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+
           ws2+GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer])
         End;

      End;{печать акцизных марок и дат розлива}
     End{OperatorSelector}
     Else
      Begin

     If PrintSertifDoc[1]=1 Then
      Begin
       If (E^.Dat.MarketElement[l].Input.NSertif[0]<>#0) And
             (E^.Dat.MarketElement[l].Input.NSertif<>NoSertifStr) Then
       Begin
New(BBBS,Init);
GetBazElement(E^.Dat.MarketElement[l].Input.NSertif,BBBS^.Dat);

           ws1:=BBBS^.Dat.Name{GetIdField(FName,E^.Dat.MarketElement[l].Input.NSertif)};
           DelSpaceRight(ws1);
        ws2:=BBBS^.Dat.Name2{GetIdField(FName2,E^.Dat.MarketElement[l].Input.NSertif)};
           DelSpaceRight(ws2);
           ws2:=ws1+' '+ws2;
           DelSpaceRight(ws2);
           Write(txt2,Space+'    Сертификат: ',GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
		 GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+
           ws2+' ('+E^.Dat.MarketElement[l].Input.NSertif+')'+GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+
		 GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]);

      ws1:=BBBS^.Dat.DSertif{GetIDField(FDateSertif,E^.Dat.MarketElement[l].Input.NSertif)};
      DelSpaceRight(ws1);
      If ws1[0]<>#0 Then
          Begin
        If ws2[0]<>#0 Then
           WriteLn(txt2,Space+'    Срок дейст: ',GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
		 GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+
            ws1+GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]+' ')
        Else
           WriteLn(txt2,Space+'    Срок дейст: ',GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
		 GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+
            ws1+GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]+' ')
        End
          End
        Else If ws2[0]<>#0 Then Writeln(txt2);


      If BBBS^.Dat.KSertif<>NoOrganStr Then
       Begin
         ws2:=GetKSertifField(FKSertif,BBBS^.Dat.KSertif);
         DelSpaceRight(ws2);
         ws2:=ws2+' ('+BBBS^.Dat.KSertif+')';
           If ws1[0]<>#0 Then
         Begin
             Writeln(txt2,Space+' Выдан: ',GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+
		   ws2+
             GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer])
         End
           Else
         Begin
                Writeln(txt2,Space+'         Выдан: ',GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
			 GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]++ws2+
                       GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer])
         End;
       End
      Else  If ws1[0]<>#0 Then Writeln(txt2);
Dispose(BBBS,Done);

      End;{сертификаты}
      End;


     If PrintAkzisDoc[1]=1 Then
     Begin
       ss:=Skl^.Dat.Input.StrihKod{Akzis1{BakGetField(FAkzis,E^.Dat.MarketElement[l].BazKod,0)};
       DelSpaceRight(ss);
       If not(ss[0]=#0) Then
        Begin
         Format(ss,CSertif);
         ss:=GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+ss+
            GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer];
         ss:=Space+'    Штрих-код: '+ss;
         Writeln(txt2,ss);
        End;
     End;


     If PrintExpert[1]=1 Then
     If (E^.Dat.MarketElement[l].Input.RegionMarka=1) And (Skl^.Dat.Input.Expert<>NoExpertStr) Then
     Begin
       ss:=GetExpertField(FExpert,Skl^.Dat.Input.Expert);
       DelSpaceRight(ss);
       If not(ss[0]=#0) Then
        Begin
         ss:=ss+' ('+Skl^.Dat.Input.Expert+')';
         {Format(ss,CExpert);}
         ss:=GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+ss+
            GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer];
         ss:=Space+'   Эксп.закл.: '+ss;
         Writeln(txt2,ss);
        End;
     End;


     If PrintAkzisDate[1]=1 Then
      Begin
       ws1[0]:=#0;
       If Skl^.Dat.Input.Marka<>NoMarkaStr Then
       Begin
       ws1:=GetMarkaField(FMarka,Skl^.Dat.Input.Marka){BakGetField(FMarka,E^.Dat.MarketElement[l].BazKod,0)};
       DelSpaceRight(ws1);
          ws1:=ws1+' ('+Skl^.Dat.Input.Marka+')';
          Write(txt2,Space+{'Акцизная марка: '}Seria_Akzis^+': ',GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
		GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+
          ws1+GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]+' ')
       End;
       ws2:=Skl^.Dat.Input.Virabotano{BakGetField(FVirabotano,E^.Dat.MarketElement[l].BazKod,0)};
       DelSpaceRight(ws2);

       If DateStringToDate(DateMask,ws2)<=DateStringToDate(DateMask,'01-01-00') Then
       ws2[0]:=#0;

       If ws2[0]<>#0 Then
        Begin
         If ws1[0]<>#0 Then
          Begin
              WriteLn(txt2,'Дата выработки: ',GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
		    GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+
         ws2+GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer])
          End
         Else
          Begin
               WriteLn(txt2,Space+'Дата выработки: ',GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
			GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+
               ws2+GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer])
          End;
        End
       Else
         if ws1[0]<>#0 Then WriteLn(txt2);

       ws2:=Skl^.Dat.Input.Godnost{BakGetField(FGodnost,E^.Dat.MarketElement[l].BazKod,0)};
       DelSpaceRight(ws2);

       If DateStringToDate(DateMask,ws2)<=DateStringToDate(DateMask,'01-01-00') Then
       ws2[0]:=#0;

       DelSpaceRight(ws2);
       If ws2[0]<>#0 Then
         Begin
           WriteLn(txt2,Space+'Реализовать до: ',GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
		 GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+
           ws2+GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer])
         End;

      End;{печать акцизных марок и дат розлива}

If Pharm=0 Then
Begin
     If PrintGTD[1]=1 Then
     Begin
{$IFNDEF Tabak}
{05/05/2004 по просьбе шутова чтобы печатались ГТД и страна только в СФ}
{в версии ТП отключена печать ГТД и производителя в накладной клиента даже если включена настройка}
       ss[0]:=#0;
       ss1[0]:=#0;

       If Skl^.Dat.Input.NGTD<>NoNGTDStr Then
       Begin
        ss:=GetNGTDField(FNGTD,Skl^.Dat.Input.NGTD);
        DelSpaceRight(ss);
       End;

       If BBB^.Dat.PostKod<>NoPostStr Then
       Begin
        ss1:=GetPostField(FFirmaPost,BBB^.Dat.PostKod);
        DelSpaceRight(ss1);
       End;

       If (Skl^.Dat.Input.NGTD<>NoNGTDSTr) Or (BBB^.Dat.PostKod<>NoPostStr) Then
        Begin

         ss:=ss+' ('+Skl^.Dat.Input.NGTD+')';
         If Skl^.Dat.Input.NGTD<>NoNGTDStr Then
         Begin
         ss:=GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+ss+
	    GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+
            GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer];
         ss:=Space+'  ГТД: '+ss;
         End
         else ss[0]:=#0;

         If BBB^.Dat.PostKod<>NoPostStr Then
         Begin
         ss1:=ss1+' ('+BBB^.Dat.PostKod+')';
         ss1:=GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+ss1+
	    GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+
            GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer];
            If ss[0]=#0 Then
            ss:=ss+'      Производство: '+ss1
            Else
            ss:=ss+' Производство: '+ss1
         End;

         Writeln(txt2,ss);
        End;
{$ENDIF}
     End;
End
 Else
  Begin
     If PrintGTD[1]=1 Then
     Begin
       ss[0]:=#0;
       ss1[0]:=#0;

       If Skl^.Dat.Input.NGTD<>NoNGTDStr Then
       Begin
        ss:=GetNGTDField(FNGTD,Skl^.Dat.Input.NGTD);
        DelSpaceRight(ss);
       End;

       If BBB^.Dat.FirmaPostKod<>NoPostStr Then
       Begin
        ss1:=GetFirmaPostField(FPost,BBB^.Dat.FirmaPostKod);
        DelSpaceRight(ss1);
       End;

       If (Skl^.Dat.Input.NGTD<>NoNGTDSTr) Or (BBB^.Dat.FirmaPostKod<>NoPostStr) Then
        Begin

         ss:=ss+' ('+Skl^.Dat.Input.NGTD+')';
         If Skl^.Dat.Input.NGTD<>NoNGTDStr Then
         Begin
         ss:=GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+ss+
	    GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+
            GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer];
         ss:=Space+'  ГТД: '+ss;
         End
         else ss[0]:=#0;

         If BBB^.Dat.FirmaPostKod<>NoPostStr Then
         Begin
         ss1:=ss1+' ('+BBB^.Dat.FirmaPostKod+')';
         ss1:=GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+ss1+
	    GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+
            GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer];
            If ss[0]=#0 Then
            ss:=ss+'      Производство: '+ss1
            Else
            ss:=ss+' Производство: '+ss1
         End;

         Writeln(txt2,ss);

        End;
     End;
  End;
*)

Video:=False;

If E^.Dat.OperatorSelector in [0,2] Then
Begin
     If PrintSertifDoc[2]=1 Then
      Begin
       If (E^.Dat.MarketElement[l].Input.NSertif[0]<>#0) And
             (E^.Dat.MarketElement[l].Input.NSertif<>NoSertifStr) Then
       Begin
If (E^.Dat.DocSelector<>1) Then
Begin
New(BBBS,Init);
GetBazElement(E^.Dat.MarketElement[l].Input.NSertif,BBBS^.Dat);

           ws1:=BBBS^.Dat.Name{GetIdField(FName,E^.Dat.MarketElement[l].Input.NSertif)};
           DelSpaceRight(ws1);
        ws2:=BBBS^.Dat.Name2{GetIdField(FName2,E^.Dat.MarketElement[l].Input.NSertif)};
           DelSpaceRight(ws2);
           ws2:=ws1+' '+ws2;
           DelSpaceRight(ws2);

        If Not Video Then
           Write(txt2,Space+' Сертификат: ',GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
		 GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+
           ws2+' ('+E^.Dat.MarketElement[l].Input.NSertif+')'+GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+
		 GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer])
        Else
           Write(txt2,Space+' Сертификат: ',ws2+' ('+E^.Dat.MarketElement[l].Input.NSertif+')');

      ws1:=BBBS^.Dat.DSertif{GetIDField(FDateSertif,E^.Dat.MarketElement[l].Input.NSertif)};
      DelSpaceRight(ws1);
      If ws1[0]<>#0 Then
          Begin
        If Not(Video) Then
        Begin
         If ws2[0]<>#0 Then
            WriteLn(txt2,Space+' Срок дейст: ',GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
		  GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+
            ws1+GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]+' ')
         Else
            WriteLn(txt2,Space+'   Срок дейст: ',GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
		  GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+
            ws1+GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]+' ')
        End
        Else
        BEgin
         If ws2[0]<>#0 Then
             WriteLn(txt2,Space+' Срок дейст: ',+ws1+' ')
         Else
             WriteLn(txt2,Space+'    Срок дейст: ',+ws1+' ');
        End
          End
      Else
      If ws2[0]<>#0 Then Writeln(txt2);

      {отключена печать графы кем выдан сертификат
      ws2:=GetIDField(FKtoSertif,E^.Dat.MarketElement[l].Input.NSertif);
      DelSpaceRight(ws2);
      If ws2[0]<>#0 Then
       Begin
           If ws1[0]<>#0 Then
         Begin
          If Not Video Then
        Writeln(txt2,' Выдан: ',GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+ws2+
             GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer])
          Else
        Writeln(txt2,' Выдан: ',+ws2);
         End
           Else
         Begin
          If Not Video Then
                Writeln(txt2,Space+'         Выдан: ',GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+
			 GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+ws2+
                       GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer])
          Else
                Writeln(txt2,Space+'         Выдан: ',+ws2);
         End;
       End
      Else  If ws1[0]<>#0 Then Writeln(txt2);
     }
Dispose(BBBS,Done);
End;{если не товарный чек}
       End;{сертификаты}
      End;{PrintSertifDoc[2]}


     If PrintAkzisDoc[2]=1 Then
     Begin
       ss:=Skl^.Dat.Input.StrihKod{Akzis1{BakGetField(FAkzis,E^.Dat.MarketElement[l].BazKod,0)};
       DelSpaceRight(ss);
       If not(ss[0]=#0) Then
        Begin
         Format(ss,CSertif);
         If Not(Video) Then ss:=GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+ss+
            GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer];
         ss:=Space+'    Штрих-код: '+ss;

         Writeln(txt2,ss);
        End;
     End;


     If PrintExpert[2]=1 Then
     If
{$IFNDEF Pharm}
      (E^.Dat.MarketElement[l].Input.RegionMarka=1) And
{$ENDIF}
	(Skl^.Dat.Input.Expert<>NoExpertStr) Then
     Begin
       ss:=GetExpertField(FExpert,Skl^.Dat.Input.Expert);
       DelSpaceRight(ss);
       If not(ss[0]=#0) Then
        Begin
         ss:=ss+' ('+Skl^.Dat.Input.Expert+')';
         If Not(Video) Then ss:=GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+ss+
            GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer];
         ss:=Space+'   '+Expert_RegNom^+': '+ss;
         Writeln(txt2,ss);
        End;
     End;

IF Pharm=0 Then
Begin
     If PrintGTD[2]=1 Then
     Begin
       ss[0]:=#0;
       ss1[0]:=#0;
{$IFNDEF Tabak}
       If (Skl^.Dat.Input.NGTD<>NoNGTDStr) Or FindPAram('/DEBUGP') Then
       Begin
        ss:=GetNGTDField(FNGTD,Skl^.Dat.Input.NGTD);
        DelSpaceRight(ss);
       End;

       If BBB^.Dat.PostKod<>NoPostStr Then
       Begin
        ss1:=GetPostField(FPost,BBB^.Dat.PostKod);
        DelSpaceRight(ss1);
       End;


       If (Skl^.Dat.Input.NGTD<>NoNGTDSTr) Or FindPAram('/DEBUGP') Or (BBB^.Dat.PostKod<>NoPostStr) Then
        Begin

         ss:=ss+' ('+Skl^.Dat.Input.NGTD+')';
         If (Skl^.Dat.Input.NGTD<>NoNGTDStr) Or FindPAram('/DEBUGP')  Then
         Begin
         If Not(Video) Then ss:=GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+ss+
	    GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+
            GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer];
         ss:=Space+'  ГТД: '+ss;
         End
         else ss[0]:=#0;

         If BBB^.Dat.PostKod<>NoPostStr Then
         Begin
         ss1:=ss1+' ('+BBB^.Dat.PostKod+')';
         If Not(Video) Then ss1:=GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+ss1+
	    GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+
            GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer];
            If ss[0]=#0 Then
            ss:=ss+'      Производство: '+ss1
            Else
            ss:=ss+' Производство: '+ss1
         End;

         Writeln(txt2,ss);
        End;
{$ENDIF}
     End;
End
 Else
  Begin
     If PrintGTD[2]=1 Then
     Begin
       ss[0]:=#0;
       ss1[0]:=#0;
{$IFNDEF Tabak}
       If (Skl^.Dat.Input.NGTD<>NoNGTDStr) Or FindPAram('/DEBUGP') Then
       Begin
        ss:=GetNGTDField(FNGTD,Skl^.Dat.Input.NGTD);
        DelSpaceRight(ss);
       End;

       If BBB^.Dat.FirmaPostKod<>NoPostStr Then
       Begin
        ss1:=GetFirmaPostField(FFirmaPost,BBB^.Dat.FirmaPostKod);
        DelSpaceRight(ss1);
       End;

       If (Skl^.Dat.Input.NGTD<>NoNGTDSTr) Or FindPAram('/DEBUGP') Or (BBB^.Dat.FirmaPostKod<>NoPostStr) Then
        Begin

         ss:=ss+' ('+Skl^.Dat.Input.NGTD+')';
         If (Skl^.Dat.Input.NGTD<>NoNGTDStr) Or FindPAram('/DEBUGP')  Then
         Begin
         If Not(Video) Then ss:=GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+ss+
	    GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+
            GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer];
         ss:=Space+'  ГТД: '+ss;
         End
         else ss[0]:=#0;

         If BBB^.Dat.FirmaPostKod<>NoPostStr Then
         Begin
         ss1:=ss1+' ('+BBB^.Dat.FirmaPostKod+')';
         If Not(Video) Then ss1:=GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+ss1+
	    GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+
            GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer];
            If ss[0]=#0 Then
            ss:=ss+'      Производство: '+ss1
            Else
            ss:=ss+' Производство: '+ss1
         End;

         Writeln(txt2,ss);
        End;
{$ENDIF}
     End;
  End;


     If PrintAkzisDate[2]=1 Then
      Begin
       ws1[0]:=#0;
       If Skl^.Dat.Input.Marka<>NoMarkaStr Then
       Begin
       ws1:=GetMarkaField(FMarka,Skl^.Dat.Input.Marka){BakGetField(FMarka,E^.Dat.MarketElement[l].BazKod,0)};
       DelSpaceRight(ws1);
       If ws1[0]<>#0 Then
         Begin
          ws1:=ws1+' ('+Skl^.Dat.Input.Marka+')';
          If Not Video Then
          Write(txt2,Space+{'Акцизная марка: '}Seria_Akzis^+': ',GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
		GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+
          ws1+GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]+' ')
          Else
          Write(txt2,Space+{'Акцизная марка: '}Seria_Akzis^+': ',ws1+' ')
         End;
       End;

       ws2:=Skl^.Dat.Input.Virabotano;
       DelSpaceRight(ws2);

       If DateStringToDate(DateMask,ws2)<=DateStringToDate(DateMask,'01-01-00') Then
       ws2[0]:=#0;

       If ws2[0]<>#0 Then
        Begin
         If ws1[0]<>#0 Then
          Begin
           If Not Video Then
              WriteLn(txt2,'Дата выработки: ',GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
		    GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+
         ws2+GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer])
           Else
              WriteLn(txt2,'Дата выработки: ',ws2);
          End
         Else
          Begin
           If Not Video Then
               WriteLn(txt2,Space+'Дата выработки: ',GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
			GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+
               ws2+GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer])
           Else
               WriteLn(txt2,Space+'Дата выработки: ',ws2);
          End;
        End
       Else
         if ws1[0]<>#0 Then WriteLn(txt2);

       ws2:=Skl^.Dat.Input.Godnost{BakGetField(FGodnost,E^.Dat.MarketElement[l].BazKod,0)};
       DelSpaceRight(ws2);


       If DateStringToDate(DateMask,ws2)<=DateStringToDate(DateMask,'01-01-00') Then
       ws2[0]:=#0;



       DelSpaceRight(ws2);
       If ws2[0]<>#0 Then
         Begin
          If Not Video Then
           WriteLn(txt2,Space+'Реализовать до: ',GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
		 GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+
           ws2+GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer])
          Else
           WriteLn(txt2,Space+'Реализовать до: ',ws2);
         End;
(*   If PrintGTD[2]=1 Then
     Begin
       ss:=Skl1^.Dat.Input.NGTD{BakGetField(FNGTD,E^.Dat.MarketElement[l].BazKod,0)};
       DelSpaceRight(ss);
       ss1:=Skl1^.Dat.Input.Post{BakGetField(FPost,E^.Dat.MarketElement[l].BazKod,0)};
       DelSpaceRight(ss1);
       If (ss[0]<>#0)Or (ss1[0]<>#0) Then
        Begin
         Format(ss,CNSertif);
         If ss[0]<>#0 Then
         Begin
         If Not(Video) Then ss:=GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+ss+
	    GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+
            GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer];
         ss:=Space+'   '+'      N ГТД: '+ss;
         End
         else ss:=Space+'   ';
         If ss1[0]<>#0 Then
         Begin
         If Not(Video) Then ss1:=GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+ss1+
	    GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+
            GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer];
            ss:=ss+' Производство: '+ss1;
         End;
         Writeln(txt2,ss);
        End;
     End;*)

      End;{печать акцизных марок и дат розлива}
     End{OperatorSelector}
     Else
      Begin

     If PrintSertifDoc[1]=1 Then
      Begin
       If (E^.Dat.MarketElement[l].Input.NSertif[0]<>#0) And
             (E^.Dat.MarketElement[l].Input.NSertif<>NoSertifStr) Then
       Begin
New(BBBS,Init);
GetBazElement(E^.Dat.MarketElement[l].Input.NSertif,BBBS^.Dat);

           ws1:=BBBS^.Dat.Name{GetIdField(FName,E^.Dat.MarketElement[l].Input.NSertif)};
           DelSpaceRight(ws1);
        ws2:=BBBS^.Dat.Name2{GetIdField(FName2,E^.Dat.MarketElement[l].Input.NSertif)};
           DelSpaceRight(ws2);
           ws2:=ws1+' '+ws2;
           DelSpaceRight(ws2);
        If Not Video Then
           Write(txt2,Space+'    Сертификат: ',GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
		 GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+
           ws2+' ('+E^.Dat.MarketElement[l].Input.NSertif+')'+GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+
		 GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer])
        Else
           Write(txt2,Space+'    Сертификат: ',ws2+' ('+E^.Dat.MarketElement[l].Input.NSertif+')');

      ws1:=BBBS^.Dat.DSertif{GetIDField(FDateSertif,E^.Dat.MarketElement[l].Input.NSertif)};
      DelSpaceRight(ws1);
      If ws1[0]<>#0 Then
          Begin
        If Not(Video) Then
        Begin
        If ws2[0]<>#0 Then
           WriteLn(txt2,Space+'    Срок дейст: ',GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
		 GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+
            ws1+GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]+' ')
        Else
           WriteLn(txt2,Space+'    Срок дейст: ',GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
		 GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+
            ws1+GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]+' ')
        End
        Else
           WriteLn(txt2,Space+'    Срок дейст: ',+ws1+' ')
          End
        Else If ws2[0]<>#0 Then Writeln(txt2);


      If BBBS^.Dat.KSertif<>NoOrganStr Then
       Begin
         ws2:=GetKSertifField(FKSertif,BBBS^.Dat.KSertif);
         DelSpaceRight(ws2);
         ws2:=ws2+' ('+BBBS^.Dat.KSertif+')';
           If ws1[0]<>#0 Then
         Begin
          If Not Video Then
             Writeln(txt2,' Выдан: ',GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+ws2+
             GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer])
          Else
	   Writeln(txt2,' Выдан: ',ws2);
         End
           Else
         Begin
          If Not Video Then
                Writeln(txt2,Space+'         Выдан: ',GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
			 GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]++ws2+
                       GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer])
          Else
                Writeln(txt2,Space+'         Выдан: ',+ws2);
         End;
       End
      Else  If ws1[0]<>#0 Then Writeln(txt2);
Dispose(BBBS,Done);

      End;{сертификаты}
      End;


     If PrintAkzisDoc[1]=1 Then
     Begin
       ss:=Skl^.Dat.Input.StrihKod{Akzis1{BakGetField(FAkzis,E^.Dat.MarketElement[l].BazKod,0)};
       DelSpaceRight(ss);
       If not(ss[0]=#0) Then
        Begin
         Format(ss,CSertif);
         If Not(Video) Then ss:=GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+ss+
            GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer];
         ss:=Space+'    Штрих-код: '+ss;
         Writeln(txt2,ss);
        End;
     End;


     If PrintExpert[1]=1 Then
     If
     {$IFNDEF Pharm}
	(E^.Dat.MarketElement[l].Input.RegionMarka=1) And
     {$ENDIF}
	(Skl^.Dat.Input.Expert<>NoExpertStr) Then
     Begin
       ss:=GetExpertField(FExpert,Skl^.Dat.Input.Expert);
       DelSpaceRight(ss);
       If not(ss[0]=#0) Then
        Begin
         ss:=ss+' ('+Skl^.Dat.Input.Expert+')';
         {Format(ss,CExpert);}
         If Not(Video) Then ss:=GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+ss+
            GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer];
         ss:=Space+'   '+Expert_RegNom^+': '+ss;
         Writeln(txt2,ss);
        End;
     End;


     If PrintAkzisDate[1]=1 Then
      Begin
       ws1[0]:=#0;
       If Skl^.Dat.Input.Marka<>NoMarkaStr Then
       Begin
       ws1:=GetMarkaField(FMarka,Skl^.Dat.Input.Marka){BakGetField(FMarka,E^.Dat.MarketElement[l].BazKod,0)};
       DelSpaceRight(ws1);
          ws1:=ws1+' ('+Skl^.Dat.Input.Marka+')';
          If Not Video Then
          Write(txt2,Space+{'Акцизная марка: '}Seria_Akzis^+': ',GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
		GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+
          ws1+GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]+' ')
          Else
          Write(txt2,Space+{'Акцизная марка: '}Seria_Akzis^+': ',ws1+' ')
       End;
       ws2:=Skl^.Dat.Input.Virabotano{BakGetField(FVirabotano,E^.Dat.MarketElement[l].BazKod,0)};
       DelSpaceRight(ws2);

       If DateStringToDate(DateMask,ws2)<=DateStringToDate(DateMask,'01-01-00') Then
       ws2[0]:=#0;

       If ws2[0]<>#0 Then
        Begin
         If ws1[0]<>#0 Then
          Begin
           If Not Video Then
              WriteLn(txt2,'Дата выработки: ',GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
		    GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+
         ws2+GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer])
           Else
              WriteLn(txt2,'Дата выработки: ',ws2);
          End
         Else
          Begin
           If Not Video Then
               WriteLn(txt2,Space+'Дата выработки: ',GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
			GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+
               ws2+GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer])
           Else
               WriteLn(txt2,Space+'Дата выработки: ',ws2);
          End;
        End
       Else
         if ws1[0]<>#0 Then WriteLn(txt2);

       ws2:=Skl^.Dat.Input.Godnost{BakGetField(FGodnost,E^.Dat.MarketElement[l].BazKod,0)};
       DelSpaceRight(ws2);

       If DateStringToDate(DateMask,ws2)<=DateStringToDate(DateMask,'01-01-00') Then
       ws2[0]:=#0;

       DelSpaceRight(ws2);
       If ws2[0]<>#0 Then
         Begin
          If Not Video Then
           WriteLn(txt2,Space+'Реализовать до: ',GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
		 GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+
           ws2+GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer])
          Else
           WriteLn(txt2,Space+'Реализовать до: ',ws2);
         End;

      End;{печать акцизных марок и дат розлива}

If Pharm=0 Then
Begin
     If PrintGTD[1]=1 Then
     Begin
{$IFNDEF Tabak}
{05/05/2004 по просьбе шутова чтобы печатались ГТД и страна только в СФ}
{в версии ТП отключена печать ГТД и производителя в накладной клиента даже если включена настройка}
       ss[0]:=#0;
       ss1[0]:=#0;

       If Skl^.Dat.Input.NGTD<>NoNGTDStr Then
       Begin
        ss:=GetNGTDField(FNGTD,Skl^.Dat.Input.NGTD);
        DelSpaceRight(ss);
       End;

       If BBB^.Dat.PostKod<>NoPostStr Then
       Begin
        ss1:=GetPostField(FFirmaPost,BBB^.Dat.PostKod);
        DelSpaceRight(ss1);
       End;

       If (Skl^.Dat.Input.NGTD<>NoNGTDSTr) Or (BBB^.Dat.PostKod<>NoPostStr) Then
        Begin

         ss:=ss+' ('+Skl^.Dat.Input.NGTD+')';
         If Skl^.Dat.Input.NGTD<>NoNGTDStr Then
         Begin
         If Not(Video) Then ss:=GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+ss+
	    GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+
            GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer];
         ss:=Space+'  ГТД: '+ss;
         End
         else ss[0]:=#0;

         If BBB^.Dat.PostKod<>NoPostStr Then
         Begin
         ss1:=ss1+' ('+BBB^.Dat.PostKod+')';
         If Not(Video) Then ss1:=GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+ss1+
	    GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+
            GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer];
            If ss[0]=#0 Then
            ss:=ss+'      Производство: '+ss1
            Else
            ss:=ss+' Производство: '+ss1
         End;

         Writeln(txt2,ss);
        End;
{$ENDIF}
     End;
End
 Else
  Begin
     If PrintGTD[1]=1 Then
     Begin
       ss[0]:=#0;
       ss1[0]:=#0;

       If Skl^.Dat.Input.NGTD<>NoNGTDStr Then
       Begin
        ss:=GetNGTDField(FNGTD,Skl^.Dat.Input.NGTD);
        DelSpaceRight(ss);
       End;

       If BBB^.Dat.FirmaPostKod<>NoPostStr Then
       Begin
        ss1:=GetFirmaPostField(FPost,BBB^.Dat.FirmaPostKod);
        DelSpaceRight(ss1);
       End;

       If (Skl^.Dat.Input.NGTD<>NoNGTDSTr) Or (BBB^.Dat.FirmaPostKod<>NoPostStr) Then
        Begin

         ss:=ss+' ('+Skl^.Dat.Input.NGTD+')';
         If Skl^.Dat.Input.NGTD<>NoNGTDStr Then
         Begin
         If Not(Video) Then ss:=GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+ss+
	    GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+
            GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer];
         ss:=Space+'  ГТД: '+ss;
         End
         else ss[0]:=#0;

         If BBB^.Dat.FirmaPostKod<>NoPostStr Then
         Begin
         ss1:=ss1+' ('+BBB^.Dat.FirmaPostKod+')';
         If Not(Video) Then ss1:=GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+ss1+
	    GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+
            GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer];
            If ss[0]=#0 Then
            ss:=ss+'      Производство: '+ss1
            Else
            ss:=ss+' Производство: '+ss1
         End;

         Writeln(txt2,ss);

        End;
     End;
  End;


    End;

    Dispose(Skl,Done);
    Dispose(BBB,Done);
   End;



   Writeln(txt2,Space+'───────────────────────────────────────────────────────────────────────────────');
   Writeln(Txt2,Space+'Всего позиций:',Position:2,'      Всего к оплате:',+RealToStr(Oplata,CIZena,CMantissa)+
    ' Мест:'+CalcMestoDiv(E,Cur)+' ',AllED:CKol+1,' Шт');
   Writeln(Txt2);
   Writeln(Txt2,Space+'    '+'  Сдал кладовщик '+SOTD+': '+'__________'+'  Товар принял: '+'__________');
   WriteLn(txt2,Space,' '+'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')'+
   GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+
   GlobalPrn^.Dat.Double[Nprint^.DAt.Printer]+
   '                                   Тип документа: (',
   LeadingZero(E^.Dat.DocSelector),+') '+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]+
   GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+
   GlobalPrn^.Dat.NoDouble[Nprint^.DAt.Printer]);
   Writeln(txt2,Space+'===============================================================================');




   If Zakaz Then Dispose(Ez,Done);
   Dispose(OSD,Done);
   Dispose(E,Done);

   c:=IoResult;
   Close(txt2);
   c:=IoResult;

   NoInfoMsg;

   BakCopy:=NPrintC^.Dat.AutoAnswerCopy;
   NPrintC^.Dat.AutoAnswerCopy:=1;
   ReportNew(Path^.Dat.ToTemp+'otborka.txt','',CopyOtBorka,True,False{Logik});
   NPrintC^.Dat.AutoAnswerCopy:=BakCopy;

 End;{If MMMM[Cur]=1}
 End;{For CDivision}
 NoInfoMsg;
End;{Procedure}



Begin
End.
