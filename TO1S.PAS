{$IfNDEF DPMI}
{$F+}
{$O+}

{$EndIf}

Uses Glob,Serv,Servstr,Mail,Utils,Utils4,Utils5,
     Objects,StHolder,Protect,To1sU,
     Dialogs,DBIII,TpDate,NetCall,Dos,NetDbEng;

{$M 65520,0,655360 }

{$I Compile.INC}
{$DEFINE Converter}

Const
 KurzSklad : array[1..30] of Char=('1','2','3','4','5','6','7','8','9','A','B','C','D','E','F','G','H','I','J','K',
 {21 22  23   24  25  26  27  28  29  30}
 'L','M','N','O','P','Q','R','S','T','U');


Procedure CalcNDSSpecial1S(Kod:Word;
                           E:PSuperMArketType;
Var NDS20,
    NDS18,
    NDS10,
    NDS_,
    Litr20,
    Litr18,
    Litr10,
    Litr_,
    ZakupkaOutNDS20,
    ZakupkaOutNDS18,
    ZakupkaOutNDS10,
    ZakupkaOutNDS_,
    NDSZ20,
    NDSZ18,
    NDSZ10,
    NDSZ_,
    Opl20,
    Opl18,
    Opl10,
    Opl_,
    Akzis:Real);

Var l : Word;
    k,j : Byte;
    s,ws,ws1 : String;
    st : String[CMantissa];
    ItogoLitr,PromItogoPos,ItogoPos,ItogoPosZ,NDSPos,ZakupkaOutNDS,
    NDSPosZ : Real;
    Test : LongInt;
    Wspom,SZakupka,
    SLitr,SAkzis,RealZena,ITOGONDS_NP,SummaZena: AllStr;
    ItogNalog,Koefficient,pp : String[CPack];

Begin
    NDS20:=0;
    NDS18:=0;
    NDS10:=0;
    NDS_:=0;
    Litr20:=0;
    Litr18:=0;
    Litr10:=0;
    Litr_:=0;
    ZakupkaOutNDS20:=0;
    ZakupkaOutNDS18:=0;
    ZakupkaOutNDS10:=0;
    ZakupkaOutNDS_:=0;
    NDSZ20:=0;
    NDSZ18:=0;
    NDSZ10:=0;
    NDSZ_:=0;
    Opl20:=0;
    Opl18:=0;
    Opl10:=0;
    Opl_:=0;
    Akzis:=0;

   Koefficient[0]:=#0;

   For l:=1 To E^.Dat.Amount Do
    Begin
     SLitr:=GetIdField(Kod,FLitr,E^.Dat.MarketElement[l].BazKod);

     If Not FindParam('LITR')Then SLitr:='1';

     StrToInt(E^.Dat.MarketElement[l].Input.Kol);
     Str(l:CMantissa,St);
     s:=E^.Dat.MarketElement[l].BazKod;

     If E^.Dat.SkidkaSelector=0 Then{Если автомат}
       MyStr((StrToReal(E^.Dat.MarketElement[l].Input.Zena)/
       (1+StrToReal(E^.Dat.MarketElement[l].Input.Proz)/100))
       ,CZena,CMantissa,ws){новая цена}
     Else
       MyStr((StrToReal(E^.Dat.MarketElement[l].Input.Zena)-
	  StrToReal(E^.Dat.MarketElement[l].Input.Skidka))
            ,CZena,CMantissa,ws);{новая цена}

       If E^.DAt.DocSelector in [{1,2,3,5,6}100] Then
       Begin
       Mystr(((1+strtoreal(E^.dat.marketelement[l].Input.SpecNalog)
              /100)),CLitr,CMantissa,koefficient);
       {новая цена}
       MyStr(StrToReal(ws)/StrToReal(Koefficient),CZena,CMantissa,Ws);
       End;

       If III.Task[Kod].VidZakupka=0 Then
       SZakupka:=E^.dat.marketelement[l].Input.Zakupka
       Else
       SZakupka:=E^.dat.marketelement[l].Input.Zakupka2;

       ItogoPos:=StrToReal(ws)*StrToInt(E^.Dat.MarketElement[l].Input.Kol);
       ItogoPosZ:=StrToReal(SZakupka)*StrToInt(E^.Dat.MarketElement[l].Input.Kol);

       ItogoLitr:=StrToReal(SLitr)*StrToInt(E^.Dat.MarketElement[l].Input.Kol);

       If Not FindParam('LITR')Then
       ItogoLitr:=StrToInt(E^.Dat.MarketElement[l].Input.Kol);



       MyStr(ItogoPosZ,CIZena,CMantissaZ,Wspom);

       NdsPos:=StrToReal(ws)*StrToInt(E^.Dat.MarketElement[l].Input.Kol)*
       StrToReal(E^.Dat.MarketElement[l].Input.NDs)/(100+StrToReal(E^.Dat.MarketElement[l].Input.NDS));

       NdsPosZ:=StrToReal(SZakupka)*StrToInt(E^.Dat.MarketElement[l].Input.Kol)*
       StrToReal(E^.Dat.MarketElement[l].Input.NDs)/(100+StrToReal(E^.Dat.MarketElement[l].Input.NDS));

       MyStr(NDSPosZ,CIZena,CMantissaZ,Ws);
       NdsPosZ:=StrToReal(Ws);

       MyStr(NDSPos,CIZena,CMantissa,Ws);
       NdsPos:=StrToReal(Ws);

       ZakupkaOutNDS:=ItogoPosZ-NDSPosZ;

       MyStr(ZakupkaOutNDS,CIZena,CMantissaZ,Ws);
       ZakupkaOutNDS:=StrToReal(Ws);

     Case E^.Dat.MarketElement[l].Input.VidNDS Of
     0:{НДС 20}
        Begin
         NDS20:=NDS20+NDSPOS;
         Litr20:=Litr20+ItogoLitr;
         ZakupkaOutNDS20:=ZakupkaOutNDS20+ZakupkaOutNDS;
         NDSZ20:=NDSZ20+NDSPOSZ;
         Opl20:=Opl20+ItogoPos;
        End;
     3:{НДС 18}
        Begin
         NDS18:=NDS18+NDSPOS;
         Litr18:=Litr18+ItogoLitr;
         ZakupkaOutNDS18:=ZakupkaOutNDS18+ZakupkaOutNDS;
         NDSZ18:=NDSZ18+NDSPOSZ;
         Opl18:=Opl18+ItogoPos;
        End;
     1:{НДС 10}
        Begin
         NDS10:=NDS10+NDSPOS;
         Litr10:=Litr10+ItogoLitr;
         ZakupkaOutNDS10:=ZakupkaOutNDS10+ZakupkaOutNDS;
         NDSZ10:=NDSZ10+NDSPOSZ;
         Opl10:=Opl10+ItogoPos;
        End;
     2:{НДС прочее}
        Begin
         NDS_:=NDS_+NDSPOS;
         Litr_:=Litr_+ItogoLitr;
         ZakupkaOutNDS_:=ZakupkaOutNDS_+ZakupkaOutNDS;
         NDSZ_:=NDSZ_+NDSPOSZ;
         Opl_:=Opl_+ItogoPos;
        End;
     Else;
     End;

      SAkzis[0]:=#0;
      With III Do
      Begin
      If III.Task[Kod].CalcAkzis=1 Then{производить расчет акцизного сбора}
      Begin

       If (III.Task[Kod].ShemaAkzis=1) And
	  (E^.Dat.MarketElement[l].Input.RegionMarka=1)
	  Then{схема расчета с суммы}
        Begin
        if StrToInt(GetIdField(Kod,FBuchGroup,E^.Dat.MarketElement[l].BazKod)) in [1,2,3,4,7] then
        begin

         if StrToInt(GetIdField(Kod,FBuchGroup,E^.Dat.MarketElement[l].BazKod)) in [1,2,3] then
         MyStr(
	    StrToReal(AkzisKoeff[StrToInt(GetIdField(Kod,FBuchGroup,E^.Dat.MarketElement[l].BazKod))])
	   *0.8
	   *StrToInt(E^.Dat.MarketElement[l].Input.Kol)
	   *StrToReal(GetIdField(Kod,FLitr,E^.Dat.MarketElement[l].BazKod))
	   *StrToReal(GetIdField(Kod,FEtil,E^.Dat.MarketElement[l].BazKod))
        /100,
         CIZena,CMantissaZ,SAkzis)
         Else
         MyStr(
	    StrToReal(AkzisKoeff[StrToInt(GetIdField(Kod,FBuchGroup,E^.Dat.MarketElement[l].BazKod))])
	   *0.65
	   *StrToInt(E^.Dat.MarketElement[l].Input.Kol)
	   *StrToReal(GetIdField(Kod,FLitr,E^.Dat.MarketElement[l].BazKod))
	   *StrToReal(GetIdField(Kod,FEtil,E^.Dat.MarketElement[l].BazKod))
        /100,
         CIZena,CMantissaZ,SAkzis)
        end
        else
        begin
         if StrToInt(GetIdField(Kod,FBuchGroup,E^.Dat.MarketElement[l].BazKod)) in [1,2,3] then
         MyStr(
	    StrToReal(AkzisKoeff[StrToInt(GetIdField(Kod,FBuchGroup,E^.Dat.MarketElement[l].BazKod))])
	   *0.8
	   *StrToInt(E^.Dat.MarketElement[l].Input.Kol)
	   *StrToReal(GetIdField(Kod,FLitr,E^.Dat.MarketElement[l].BazKod))
        ,
         CIZena,CMantissa,SAkzis)
         Else
         MyStr(
	    StrToReal(AkzisKoeff[StrToInt(GetIdField(Kod,FBuchGroup,E^.Dat.MarketElement[l].BazKod))])
	   *0.65
	   *StrToInt(E^.Dat.MarketElement[l].Input.Kol)
	   *StrToReal(GetIdField(Kod,FLitr,E^.Dat.MarketElement[l].BazKod))
        ,
         CIZena,CMantissa,SAkzis)
        end;
        End
        Else
         Begin{схема расчета с единицы продукции}
           If (E^.Dat.MarketElement[l].Input.RegionMarka=1) Then
           MyStr(StrToReal(E^.Dat.MarketElement[l].Input.AkzisSbor)*StrToInt(E^.Dat.MarketElement[l].Input.Kol),
           CIZena,CMantissaZ,SAkzis);
         End;
       AkZis:=Akzis+StrToReal(SAkzis);
      End;
     End;

    End;{For}
End;



{проверяет товар или сертификаты по флагу в базе разделов}
Function TestNoSertif(Kod:Word;Art:ArtikulStr):Boolean;
Var Fr : RazdelFileType;
    RR : RazdelType;
    c : Word;
Begin
TestNoSertif:=False;

If Not fExists(III.Task[Kod].PathToRazdel+'razdel.db') Then
 Begin
   {
   Writeln('Ошибка доступа к файлу разделов '+III.Task[Kod].PathToRazdel+'razdel.db'+
	 +' у объекта '+IntToStr(Kod,CMantissa));
   }
   AddLog(LogFile,'Ошибка доступа к файлу разделов '+III.Task[Kod].PathToRazdel+'razdel.db'+
	 +' у объекта '+IntToStr(Kod,CMantissa));
   Exit;
 End;

 Assign(fr,III.Task[Kod].PathToRazdel+'razdel.db');
 c:=IOResult;
 Reset(fr);
 c:=IOResult;
 If c<>0 Then
  Begin
   {
   Writeln('Ошибка открытия '+III.Task[Kod].PathToRazdel+'razdel.db'+
	 +' у объекта '+IntToStr(Kod,CMantissa)+' Код:'+IntToStr(c,CMantissa));
   }
   AddLog(LogFile,'Ошибка открытия '+III.Task[Kod].PathToRazdel+'razdel.db'+
	 +' у объекта '+IntToStr(Kod,CMantissa)+' Код:'+IntToStr(c,CMantissa));
   Exit;
  End;

 If (FileSize(Fr)>=StrToInt(Copy(Art,1,CRazdelKod))) Then Seek(fr,StrToInt(Copy(Art,1,CRazdelKod)))
 Else
  Begin
   c:=IOResult;
   Close(fr);
   c:=IOResult;
   {Writeln('Попытка позиционирования за EOF для позиции '+Art);}
   AddLog(LogFile,'Попытка позиционирования за EOF для позиции '+Art);
   Exit;
  End;

  Read(fr,RR);

   c:=IOResult;
   Close(fr);
   c:=IOResult;

  If RR.EnableDoc=0 Then TestNoSertif:=True;

End;



Procedure CalcNDSSpecial1SPrihod
(Kod:Word;
                           E:PPrihodType;
Var NDS20,
    NDS10,
    NDS18,
    NDS_,
    Litr20,
    Litr18,
    Litr10,
    Litr_,
    ZakupkaOutNDS20,
    ZakupkaOutNDS18,
    ZakupkaOutNDS10,
    ZakupkaOutNDS_,
    NDSZ20,
    NDSZ18,
    NDSZ10,
    NDSZ_,
    Opl20,
    Opl18,
    Opl10,
    Opl_,
    Akzis:Real);

Var l : Word;
    k,j : Byte;
    s,ws,ws1 : String;
    st : String[CMantissa];
    ItogoLitr,PromItogoPos,ItogoPos,ItogoPosZ,NDSPos,ZakupkaOutNDS,
    NDSPosZ : Real;
    Test : LongInt;
    Wspom,SZakupka,
    SLitr,SAkzis,RealZena,ITOGONDS_NP,SummaZena: AllStr;
    ItogNalog,Koefficient,pp : String[CPack];

Begin
    NDS20:=0;
    NDS18:=0;
    NDS10:=0;
    NDS_:=0;
    Litr20:=0;
    Litr18:=0;
    Litr10:=0;
    Litr_:=0;
    ZakupkaOutNDS20:=0;
    ZakupkaOutNDS18:=0;
    ZakupkaOutNDS10:=0;
    ZakupkaOutNDS_:=0;
    NDSZ20:=0;
    NDSZ18:=0;
    NDSZ10:=0;
    NDSZ_:=0;
    Opl20:=0;
    Opl18:=0;
    Opl10:=0;
    Opl_:=0;
    Akzis:=0;

   Koefficient[0]:=#0;

   For l:=1 To E^.Dat.Amount Do
    Begin
     If Not TestNoSertif(Kod,E^.Dat.PrihodElement[l].BazKod) Then Continue;

     SLitr:=GetIdField(Kod,FLitr,E^.Dat.PrihodElement[l].BazKod);
     If Not FindParam('LITR')Then SLitr:='1';

     StrToInt(E^.Dat.PrihodElement[l].Input.Kol);
     Str(l:CMantissa,St);
     s:=E^.Dat.PrihodElement[l].BazKod;

       MyStr(StrToReal(E^.Dat.PrihodElement[l].Input.R_Zena),CZena,CMantissa,ws);{розничная цена}

       If III.Task[Kod].VidZakupka=0 Then
       SZakupka:=E^.dat.Prihodelement[l].Input.Zakupka
       Else
       SZakupka:=E^.dat.Prihodelement[l].Input.Zakupka2;

       ItogoPos:=StrToReal(ws)*StrToInt(E^.Dat.PrihodElement[l].Input.Kol);
       ItogoPosZ:=StrToReal(SZakupka)*StrToInt(E^.Dat.PrihodElement[l].Input.Kol);

       ItogoLitr:=StrToReal(SLitr)*StrToInt(E^.Dat.PrihodElement[l].Input.Kol);

       If Not FindParam('LITR')Then
       ItogoLitr:=StrToInt(E^.Dat.PrihodElement[l].Input.Kol);



       MyStr(ItogoPosZ,CIZena,CMantissaZ,Wspom);

       NdsPos:=StrToReal(ws)*StrToInt(E^.Dat.PrihodElement[l].Input.Kol)*
       StrToReal(GetIdField(Kod,FNDS,E^.Dat.PrihodElement[l].BazKod))/(100+
	  StrToReal(GetIdField(Kod,FNDS,E^.Dat.PrihodElement[l].BazKod)));

       NdsPosZ:=StrToReal(SZakupka)*
	  StrToInt(E^.Dat.PrihodElement[l].Input.Kol)*
       StrToReal(GetIdField(Kod,FNDS,E^.Dat.PrihodElement[l].BazKod))/
	  (100+StrToReal(GetIdField(Kod,FNDS,E^.Dat.PrihodElement[l].BazKod)));

       MyStr(NDSPosZ,CIZena,CMantissaZ,Ws);
       NdsPosZ:=StrToReal(Ws);

       MyStr(NDSPos,CIZena,CMantissa,Ws);
       NdsPos:=StrToReal(Ws);

       ZakupkaOutNDS:=ItogoPosZ-NDSPosZ;

       MyStr(ZakupkaOutNDS,CIZena,CMantissaZ,Ws);
       ZakupkaOutNDS:=StrToReal(Ws);

     Case StrToInt(GetIdField(Kod,FVidNDS,E^.Dat.PrihodElement[l].BazKod)) Of
     0:{НДС 20}
        Begin
         NDS20:=NDS20+NDSPOS;
         Litr20:=Litr20+ItogoLitr;
         ZakupkaOutNDS20:=ZakupkaOutNDS20+ZakupkaOutNDS;
         NDSZ20:=NDSZ20+NDSPOSZ;
         Opl20:=Opl20+ItogoPos;
        End;
     3:{НДС 18}
        Begin
         NDS18:=NDS18+NDSPOS;
         Litr18:=Litr18+ItogoLitr;
         ZakupkaOutNDS18:=ZakupkaOutNDS18+ZakupkaOutNDS;
         NDSZ18:=NDSZ18+NDSPOSZ;
         Opl18:=Opl18+ItogoPos;
        End;
     1:{НДС 10}
        Begin
         NDS10:=NDS10+NDSPOS;
         Litr10:=Litr10+ItogoLitr;
         ZakupkaOutNDS10:=ZakupkaOutNDS10+ZakupkaOutNDS;
         NDSZ10:=NDSZ10+NDSPOSZ;
         Opl10:=Opl10+ItogoPos;
        End;
     2:{НДС прочее}
        Begin
         NDS_:=NDS_+NDSPOS;
         Litr_:=Litr_+ItogoLitr;
         ZakupkaOutNDS_:=ZakupkaOutNDS_+ZakupkaOutNDS;
         NDSZ_:=NDSZ_+NDSPOSZ;
         Opl_:=Opl_+ItogoPos;
        End;
     Else;
     End;


      SAkzis[0]:=#0;
      With III Do
      Begin
      If III.Task[Kod].CalcAkzis=1 Then{производить расчет акцизного сбора}
      Begin

       If (III.Task[Kod].ShemaAkzis=1) And ((E^.Dat.PrihodElement[l].Input.RegionMarka=1)) Then{схема расчета с суммы}
        Begin
        if StrToInt(GetIdField(Kod,FBuchGroup,E^.Dat.PrihodElement[l].BazKod)) in [1,2,3,4,7] then
        begin

         if StrToInt(GetIdField(Kod,FBuchGroup,E^.Dat.PrihodElement[l].BazKod)) in [1,2,3] then
         MyStr(
	    StrToReal(AkzisKoeff[StrToInt(GetIdField(Kod,FBuchGroup,E^.Dat.PrihodElement[l].BazKod))])
	   *0.8
	   *StrToInt(E^.Dat.PrihodElement[l].Input.Kol)
	   *StrToReal(GetIdField(Kod,FLitr,E^.Dat.PrihodElement[l].BazKod))
	   *StrToReal(GetIdField(Kod,FEtil,E^.Dat.PrihodElement[l].BazKod))
        /100,
         CIZena,CMantissaZ,SAkzis)
         Else
         MyStr(
	    StrToReal(AkzisKoeff[StrToInt(GetIdField(Kod,FBuchGroup,E^.Dat.PrihodElement[l].BazKod))])
	   *0.65
	   *StrToInt(E^.Dat.PrihodElement[l].Input.Kol)
	   *StrToReal(GetIdField(Kod,FLitr,E^.Dat.PrihodElement[l].BazKod))
	   *StrToReal(GetIdField(Kod,FEtil,E^.Dat.PrihodElement[l].BazKod))
        /100,
         CIZena,CMantissaZ,SAkzis)
        end
        else
        begin
         if StrToInt(GetIdField(Kod,FBuchGroup,E^.Dat.PrihodElement[l].BazKod)) in [1,2,3] then
         MyStr(
	    StrToReal(AkzisKoeff[StrToInt(GetIdField(Kod,FBuchGroup,E^.Dat.PrihodElement[l].BazKod))])
	   *0.8
	   *StrToInt(E^.Dat.PrihodElement[l].Input.Kol)
	   *StrToReal(GetIdField(Kod,FLitr,E^.Dat.PrihodElement[l].BazKod))
        ,
         CIZena,CMantissa,SAkzis)
         Else
         MyStr(
	    StrToReal(AkzisKoeff[StrToInt(GetIdField(Kod,FBuchGroup,E^.Dat.PrihodElement[l].BazKod))])
	   *0.65
	   *StrToInt(E^.Dat.PrihodElement[l].Input.Kol)
	   *StrToReal(GetIdField(Kod,FLitr,E^.Dat.PrihodElement[l].BazKod))
        ,
         CIZena,CMantissa,SAkzis)
        end;
        End
        Else
         Begin{схема расчета с единицы продукции}
           If (E^.Dat.PrihodElement[l].Input.RegionMarka=1) Then
           MyStr(StrToReal(E^.Dat.PrihodElement[l].Input.AkzisSbor)*StrToInt(E^.Dat.PrihodElement[l].Input.Kol),
           CIZena,CMantissaZ,SAkzis);
         End;
       AkZis:=Akzis+StrToReal(SAkzis);
      End;
     End;


(*
      SAkzis[0]:=#0;
      If III.Task[Kod].CalcAkzis=1 Then{производить расчет акцизного сбора}
      Begin
       If III.Task[Kod].ShemaAkzis=1 Then{схема расчета с суммы}
        Begin
        if StrToInt(GetIdField(Kod,FBuchGroup,E^.Dat.PrihodElement[l].BazKod)) in [1,2,3,4,7] then
        begin
         MyStr(
	    StrToReal(AkzisKoeff[StrToInt(GetIdField(Kod,FBuchGroup,E^.Dat.PrihodElement[l].BazKod))])
	   /2
	   *StrToInt(E^.Dat.PrihodElement[l].Input.Kol)
	   *StrToReal(GetIdField(Kod,FLitr,E^.Dat.PrihodElement[l].BazKod))
	   *StrToReal(GetIdField(Kod,FEtil,E^.Dat.PrihodElement[l].BazKod))
        /100,
         CIZena,CMantissaZ,SAkzis);
        end
        else
        begin
         MyStr(
	    StrToReal(AkzisKoeff[StrToInt(GetIdField(Kod,FBuchGroup,E^.Dat.PrihodElement[l].BazKod))])
	   /2
	   *StrToInt(E^.Dat.PrihodElement[l].Input.Kol)
	   *StrToReal(GetIdField(Kod,FLitr,E^.Dat.PrihodElement[l].BazKod))
        ,
         CIZena,CMantissa,SAkzis);
        end;
        End
        Else
         Begin{схема расчета с единицы продукции}
           MyStr(StrToReal(E^.Dat.PrihodElement[l].Input.AkzisSbor)*StrToInt(E^.Dat.PrihodElement[l].Input.Kol),
           CIZena,CMantissaZ,SAkzis);
         End;
       AkZis:=Akzis+StrToReal(SAkzis);
      End;
*)
    End;{For}
End;


Procedure CalcOnlyNDS(E:PSuperMArketType;Var NDS20,NDS18,NDS10,NDS_:Real);
Var l : Word;
    k,j : Byte;
    s,ws,ws1 : String;
    st : String[CMantissa];
    PromItogoPos,ItogoPos,NDSPos:Real;
    Wspom,SZakupka,
    RealZena,ITOGONDS_NP,SummaZena: AllStr;
    ItogNalog,Koefficient,pp : String[CPack];

Begin
    NDS20:=0;
    NDS18:=0;
    NDS10:=0;
    NDS_:=0;

   Koefficient[0]:=#0;

   For l:=1 To E^.Dat.Amount Do
    Begin
     StrToInt(E^.Dat.MarketElement[l].Input.Kol);
     Str(l:CMantissa,St);
     s:=E^.Dat.MarketElement[l].BazKod;

     If E^.Dat.SkidkaSelector=0 Then{Если автомат}
       MyStr((StrToReal(E^.Dat.MarketElement[l].Input.Zena)/
       (1+StrToReal(E^.Dat.MarketElement[l].Input.Proz)/100))
       ,CZena,CMantissa,ws){новая цена}
     Else
       MyStr((StrToReal(E^.Dat.MarketElement[l].Input.Zena)-
	  StrToReal(E^.Dat.MarketElement[l].Input.Skidka))
            ,CZena,CMantissa,ws);{новая цена}

       If E^.DAt.DocSelector in [{1,2,3,5,6}100] Then
       Begin
       Mystr(((1+strtoreal(E^.dat.marketelement[l].Input.SpecNalog)
              /100)),CLitr,CMantissa,koefficient);
       {новая цена}
       MyStr(StrToReal(ws)/StrToReal(Koefficient),CZena,CMantissa,Ws);
       End;

       ItogoPos:=StrToReal(ws)*StrToInt(E^.Dat.MarketElement[l].Input.Kol);

       NdsPos:=StrToReal(ws)*StrToInt(E^.Dat.MarketElement[l].Input.Kol)*
       StrToReal(E^.Dat.MarketElement[l].Input.NDs)/(100+StrToReal(E^.Dat.MarketElement[l].Input.NDS));

       MyStr(NDSPos,CIZena,CMantissa,Ws);
       NdsPos:=StrToReal(Ws);

     Case E^.Dat.MarketElement[l].Input.VidNDS Of
     0:{НДС 20}
        Begin
         NDS20:=NDS20+NDSPOS;
        End;
     3:{НДС 20}
        Begin
         NDS18:=NDS18+NDSPOS;
        End;
     1:{НДС 10}
        Begin
         NDS10:=NDS10+NDSPOS;
        End;
     2:{НДС прочее}
        Begin
         NDS_:=NDS_+NDSPOS;
        End;
     Else;
     End;

    End;{For}
End;



Procedure CalcNDSSpecial1SR(Kod:Word;
                           E:PNewVozwratType;
Var NDS20,
    NDS18,
    NDS10,
    NDS_,
    Litr20,
    Litr18,
    Litr10,
    Litr_,
    ZakupkaOutNDS20,
    ZakupkaOutNDS18,
    ZakupkaOutNDS10,
    ZakupkaOutNDS_,
    NDSZ20,
    NDSZ18,
    NDSZ10,
    NDSZ_,
    Opl20,
    Opl18,
    Opl10,
    Opl_,
    Akzis:Real);

Var l : Word;
    k,j : Byte;
    s,ws,ws1 : String;
    st : String[CMantissa];
    ItogoLitr,PromItogoPos,ItogoPos,ItogoPosZ,NDSPos,ZakupkaOutNDS,
    NDSPosZ : Real;
    Test : LongInt;
    Wspom,SZakupka,
    SLitr,SAkzis,RealZena,ITOGONDS_NP,SummaZena: AllStr;
    VNDS : Word;
    ItogNalog,Koefficient,pp : String[CPack];

Begin
    NDS20:=0;
    NDS18:=0;
    NDS10:=0;
    NDS_:=0;
    Litr20:=0;
    Litr18:=0;
    Litr10:=0;
    Litr_:=0;
    ZakupkaOutNDS20:=0;
    ZakupkaOutNDS18:=0;
    ZakupkaOutNDS10:=0;
    ZakupkaOutNDS_:=0;
    NDSZ20:=0;
    NDSZ18:=0;
    NDSZ10:=0;
    NDSZ_:=0;
    Opl20:=0;
    Opl18:=0;
    Opl10:=0;
    Opl_:=0;
    Akzis:=0;

   Koefficient[0]:=#0;

   For l:=1 To E^.Dat.Amount Do
    Begin
     SLitr:=GetIdField(Kod,FLitr,E^.Dat.VozwratElement[l].BazKod);

     If Not FindParam('LITR')Then SLitr:='1';

     StrToInt(E^.Dat.VozwratElement[l].Input.Kol);
     Str(l:CMantissa,St);
     s:=E^.Dat.VozwratElement[l].BazKod;

     If (E^.Dat.VidDocument in [0,2,4]) Then{Если автомат}
       MyStr((StrToReal(E^.Dat.VozwratElement[l].Input.Zena)/
       (1+StrToReal(E^.Dat.VozwratElement[l].Input.LocalProz)/100))
       ,CZena,CMantissa,ws){новая цена}
     Else
       MyStr((StrToReal(E^.Dat.VozwratElement[l].Input.Zena)-
	  StrToReal(E^.Dat.VozwratElement[l].Input.LocalSkidka))
            ,CZena,CMantissa,ws);{новая цена}


       If E^.DAt.DocSelector in [{1,2,3,5,6}100] Then
       Begin
       Mystr(((1+strtoreal(E^.dat.VozwratElement[l].Input.SpecNalog)
              /100)),CLitr,CMantissa,koefficient);
       {новая цена}
       MyStr(StrToReal(ws)/StrToReal(Koefficient),CZena,CMantissa,Ws);
       End;


       If III.Task[Kod].VidZakupka=0 Then
       SZakupka:=E^.dat.VozwratElement[l].Input.Zakupka
	  Else
       SZakupka:=E^.dat.VozwratElement[l].Input.Zakupka2;


       ItogoPos:=StrToReal(ws)*StrToInt(E^.Dat.VozwratElement[l].Input.Kol);
       ItogoPosZ:=StrToReal(SZakupka)*StrToInt(E^.Dat.VozwratElement[l].Input.Kol);
       ItogoLitr:=StrToReal(SLitr)*StrToInt(E^.Dat.VozwratElement[l].Input.Kol);

       If Not FindParam('LITR')Then
       ItogoLitr:=StrToInt(E^.Dat.VozwratElement[l].Input.Kol);

       MyStr(ItogoPosZ,CIZena,CMantissaZ,Wspom);

       NdsPos:=StrToReal(ws)*StrToInt(E^.Dat.VozwratElement[l].Input.Kol)*
       StrToReal(E^.Dat.VozwratElement[l].Input.NDs)/(100+StrToReal(E^.Dat.VozwratElement[l].Input.NDS));

       NdsPosZ:=StrToReal(SZakupka)*StrToInt(E^.Dat.VozwratElement[l].Input.Kol)*
       StrToReal(E^.Dat.VozwratElement[l].Input.NDs)/(100+StrToReal(E^.Dat.VozwratElement[l].Input.NDS));

       MyStr(NDSPosZ,CIZena,CMantissaZ,Ws);
       NdsPosZ:=StrToReal(Ws);

       MyStr(NDSPos,CIZena,CMantissa,Ws);
       NdsPos:=StrToReal(Ws);

       ZakupkaOutNDS:=ItogoPosZ-NDSPosZ;

       MyStr(ZakupkaOutNDS,CIZena,CMantissaZ,Ws);
       ZakupkaOutNDS:=StrToReal(Ws);

       VNDS:=0;
       If Round(StrToReal(E^.Dat.VozwratElement[l].Input.NDS))=20 Then VNDS:=0;
       If Round(StrToReal(E^.Dat.VozwratElement[l].Input.NDS))=18 Then VNDS:=3;
       If Round(StrToReal(E^.Dat.VozwratElement[l].Input.NDS))=10 Then VNDS:=1;
       If Round(StrToReal(E^.Dat.VozwratElement[l].Input.NDS))<10 Then VNDS:=2;


     Case VNDS Of
     0:{НДС 20}
        Begin
         NDS20:=NDS20+NDSPOS;
         Litr20:=Litr20+ItogoLitr;
         ZakupkaOutNDS20:=ZakupkaOutNDS20+ZakupkaOutNDS;
         NDSZ20:=NDSZ20+NDSPOSZ;
         Opl20:=Opl20+ItogoPos;
        End;
     3:{НДС 18}
        Begin
         NDS18:=NDS18+NDSPOS;
         Litr18:=Litr18+ItogoLitr;
         ZakupkaOutNDS18:=ZakupkaOutNDS18+ZakupkaOutNDS;
         NDSZ18:=NDSZ18+NDSPOSZ;
         Opl18:=Opl18+ItogoPos;
        End;
     1:{НДС 10}
        Begin
         NDS10:=NDS10+NDSPOS;
         Litr10:=Litr10+ItogoLitr;
         ZakupkaOutNDS10:=ZakupkaOutNDS10+ZakupkaOutNDS;
         NDSZ10:=NDSZ10+NDSPOSZ;
         Opl10:=Opl10+ItogoPos;
        End;
     2:{НДС прочее}
        Begin
         NDS_:=NDS_+NDSPOS;
         Litr_:=Litr_+ItogoLitr;
         ZakupkaOutNDS_:=ZakupkaOutNDS_+ZakupkaOutNDS;
         NDSZ_:=NDSZ_+NDSPOSZ;
         Opl_:=Opl_+ItogoPos;
        End;
     Else;
     End;

      SAkzis[0]:=#0;
      With III Do
      Begin
      If III.Task[Kod].CalcAkzis=1 Then{производить расчет акцизного сбора}
      Begin

       If (III.Task[Kod].ShemaAkzis=1) And (E^.Dat.VozwratElement[l].Input.RegionMarka=1) Then{схема расчета с суммы}
        Begin
        if StrToInt(GetIdField(Kod,FBuchGroup,E^.Dat.VozwratElement[l].BazKod)) in [1,2,3,4,7] then
        begin

         if StrToInt(GetIdField(Kod,FBuchGroup,E^.Dat.VozwratElement[l].BazKod)) in [1,2,3] then
         MyStr(
	    StrToReal(AkzisKoeff[StrToInt(GetIdField(Kod,FBuchGroup,E^.Dat.VozwratElement[l].BazKod))])
	   *0.8
	   *StrToInt(E^.Dat.VozwratElement[l].Input.Kol)
	   *StrToReal(GetIdField(Kod,FLitr,E^.Dat.VozwratElement[l].BazKod))
	   *StrToReal(GetIdField(Kod,FEtil,E^.Dat.VozwratElement[l].BazKod))
        /100,
         CIZena,CMantissaZ,SAkzis)
         Else
         MyStr(
	    StrToReal(AkzisKoeff[StrToInt(GetIdField(Kod,FBuchGroup,E^.Dat.VozwratElement[l].BazKod))])
	   *0.65
	   *StrToInt(E^.Dat.VozwratElement[l].Input.Kol)
	   *StrToReal(GetIdField(Kod,FLitr,E^.Dat.VozwratElement[l].BazKod))
	   *StrToReal(GetIdField(Kod,FEtil,E^.Dat.VozwratElement[l].BazKod))
        /100,
         CIZena,CMantissaZ,SAkzis)
        end
        else
        begin
         if StrToInt(GetIdField(Kod,FBuchGroup,E^.Dat.VozwratElement[l].BazKod)) in [1,2,3] then
         MyStr(
	    StrToReal(AkzisKoeff[StrToInt(GetIdField(Kod,FBuchGroup,E^.Dat.VozwratElement[l].BazKod))])
	   *0.8
	   *StrToInt(E^.Dat.VozwratElement[l].Input.Kol)
	   *StrToReal(GetIdField(Kod,FLitr,E^.Dat.VozwratElement[l].BazKod))
        ,
         CIZena,CMantissa,SAkzis)
         Else
         MyStr(
	    StrToReal(AkzisKoeff[StrToInt(GetIdField(Kod,FBuchGroup,E^.Dat.VozwratElement[l].BazKod))])
	   *0.65
	   *StrToInt(E^.Dat.VozwratElement[l].Input.Kol)
	   *StrToReal(GetIdField(Kod,FLitr,E^.Dat.VozwratElement[l].BazKod))
        ,
         CIZena,CMantissa,SAkzis)
        end;
        End
        Else
         Begin{схема расчета с единицы продукции}
           If (E^.Dat.VozwratElement[l].Input.RegionMarka=1) Then
           MyStr(StrToReal(E^.Dat.VozwratElement[l].Input.AkzisSbor)*StrToInt(E^.Dat.VozwratElement[l].Input.Kol),
           CIZena,CMantissaZ,SAkzis);
         End;
       AkZis:=Akzis+StrToReal(SAkzis);
      End;
     End;


(*
      SAkzis[0]:=#0;
      If III.Task[Kod].CalcAkzis=1 Then{производить расчет акцизного сбора}
      Begin
       If III.Task[Kod].ShemaAkzis=1 Then{схема расчета с суммы}
        Begin
        if StrToInt(GetIdField(Kod,FBuchGroup,E^.Dat.VozwratElement[l].BazKod)) in [1,2,3,4,7] then
        begin
         MyStr(
	    StrToReal(AkzisKoeff[StrToInt(GetIdField(Kod,FBuchGroup,E^.Dat.VozwratElement[l].BazKod))])
	   /2
	   *StrToInt(E^.Dat.VozwratElement[l].Input.Kol)
	   *StrToReal(GetIdField(Kod,FLitr,E^.Dat.VozwratElement[l].BazKod))
	   *StrToReal(GetIdField(Kod,FEtil,E^.Dat.VozwratElement[l].BazKod))
        /100,
         CIZena,CMantissaZ,SAkzis);
        end
        else
        begin
         MyStr(
	    StrToReal(AkzisKoeff[StrToInt(GetIdField(Kod,FBuchGroup,E^.Dat.VozwratElement[l].BazKod))])
	   /2
	   *StrToInt(E^.Dat.VozwratElement[l].Input.Kol)
	   *StrToReal(GetIdField(Kod,FLitr,E^.Dat.VozwratElement[l].BazKod))
        ,
         CIZena,CMantissa,SAkzis);
        end;
        End
        Else
         Begin{схема расчета с единицы продукции}
           MyStr(StrToReal(E^.Dat.VozwratElement[l].Input.AkzisSbor)*StrToInt(E^.Dat.VozwratElement[l].Input.Kol),
           CIZena,CMantissaZ,SAkzis);
         End;
       AkZis:=Akzis+StrToReal(SAkzis);
      End;
*)
    End;{For}
End;





Procedure ImportOPT(Kod:Word);
Var c : Word;
    E : PSuperMarketType;
    f : MarketFileType;
    SClientKod,
     SKod,
     SDate: AllStr;
    NDS20,
    NDS18,
    NDS10,
    NDS_,
    Litr20,
    Litr18,
    Litr10,
    Litr_,
    ZakupkaOutNDS20,
    ZakupkaOutNDS18,
    ZakupkaOutNDS10,
    ZakupkaOutNDS_,
    NDSZ20,
    NDSZ18,
    NDSZ10,
    NDSZ_,
    Opl20,
    Opl18,
    Opl10,
    Opl_,
    Akzis:Real;
Begin
If Not fExists(III.Task[Kod].PathToMarket+FDate+'.mrk') Then
 Begin
   {
   Writeln('Нет данных для экспорта '+III.Task[Kod].PathToMarket+FDate+'.mrk'+
	 +' у объекта '+IntToStr(Kod,CMantissa));
   }
   AddLog(LogFile,'Нет данных для экспорта '+III.Task[Kod].PathToMarket+FDate+'.mrk'+
	 +' у объекта '+IntToStr(Kod,CMantissa));
   Exit;
 End;


If Not fExists(III.PathToExport+'m'+EDate+'.dbf') Then
Begin
with Base do
begin
 Assign(III.PathToExport+'m'+EDate+'.dbf'); {пpисвоить БД имя}
 Init; {подготовиться к созданию БД}
 AddField('OBJECT','N',5,0);{Код объекта откуда происходит реализация}
 AddField('TYPEOPER','N',1,0);{код операции 1-розница; 0-опт; 2-вз}
 AddField('CLIENTKOD','C',8,0);{код клиента}
 AddField('DOCUMENT','C',10,0);{код клиента}
 AddField('DOGOVOR','N',1,0);{ссылка на основной договор}
 AddField('SF','N',1,0);{код признак генерации СФ}
 AddField('DATE','C',8,0);{код признак генерации СФ}
 AddField('KOL20','N',14,3);{всего литров с НДС20}
 AddField('SOPL20','N',15,2);{к оплате с НДС20}
 AddField('NDSOPL20','N',15,2);{НДС20 в сумме к оплате}
 AddField('SZOUT20','N',15,4);{сумма по ЗЦ без НДС20}
 AddField('SNDSZ20','N',15,4);{сумма НДС20 от З/Ц}
 AddField('KOL10','N',14,3);{всего литров с НДС10}
 AddField('SOPL10','N',15,2);{к оплате с НДС10}
 AddField('NDSOPL10','N',15,2);{НДС10 в сумме к оплате}
 AddField('SZOUT10','N',15,4);{сумма по ЗЦ без НДС10}
 AddField('SNDSZ10','N',15,4);{сумма НДС10 от З/Ц}
 AddField('KOL_','N',14,3);{всего литров с НДС прочее}
 AddField('SOPL_','N',15,2);{к оплате с НДС прочее}
 AddField('NDSOPL_','N',15,2);{НДС прочее в сумме к оплате}
 AddField('SZOUT_','N',15,4);{сумма по ЗЦ без НДС прочее}
 AddField('SNDSZ_','N',15,4);{сумма НДС прочее от З/Ц}
 AddField('AKZIS','N',15,4);{акцизный сбор}
 AddField('DOCOSN','C',9,0);{документ основания}
 AddField('DATEOSN','C',8,0);{дата документа основания}
 AddField('KOL18','N',14,3);{всего литров с НДС20}
 AddField('SOPL18','N',15,2);{к оплате с НДС20}
 AddField('NDSOPL18','N',15,2);{НДС20 в сумме к оплате}
 AddField('SZOUT18','N',15,4);{сумма по ЗЦ без НДС20}
 AddField('SNDSZ18','N',15,4);{сумма НДС20 от З/Ц}

      if Create then
         Open(ReadWrite)
      else
     begin
      {
      Writeln('Ошибка создания '+III.PathToExport+'m'+EDate+
	 '.dbf'+' у объекта '+IntToStr(Kod,CMantissa));
      }
      AddLog(LogFile,'Ошибка создания '+III.PathToExport+'m'+EDate+
	 '.dbf'+' у объекта '+IntToStr(Kod,CMantissa));
      exit;
     end;

  AddLog(LogFile,'Создание базы данных '+III.PathToExport+'m'+EDate+'.dbf'+' успешно завершено');

c:=IOResult;
     Close;
c:=IOResult;
End;{With Base}
End;



 Assign(f,III.Task[Kod].PathToMarket+FDate+'.mrk');
 c:=IOResult;
 Reset(f);
 c:=IOResult;
 If c<>0 Then
  Begin
   {
   Writeln('Ошибка открытия '+III.Task[Kod].PathToMarket+FDate+'.mrk'+
	 +' у объекта '+IntToStr(Kod,CMantissa)+' Код:'+IntToStr(c,CMantissa));
   }
   AddLog(LogFile,'Нет данных для экспорта '+III.Task[Kod].PathToMarket+FDate+'.mrk'+
	 +' у объекта '+IntToStr(Kod,CMantissa)+' Код:'+IntToStr(c,CMantissa));
   Exit;
  End;

 Base.Assign(III.PathToExport+'m'+EDate+'.dbf');
 c:=IOResult;
 Base.Open(ReadWrite);
 c:=IOResult;
 If c<>0 Then
  Begin
   Close(f);
   {
   Writeln('Ошибка открытия '+III.PathToExport+'m'+EDate+'.dbf'+
	 +' у объекта '+IntToStr(Kod,CMantissa)+' Код:'+IntToStr(c,CMantissa));
   }
   AddLog(LogFile,III.PathToExport+'m'+EDate+'.dbf'+
	 +' у объекта '+IntToStr(Kod,CMantissa)+' Код:'+IntToStr(c,CMantissa));
   Exit;
  End;


 New(E,Init);

 While Not(Eof(f)) Do
  Begin
   ReadMarket(f,E);
   If E^.Dat.Active Then{активный}
   If (E^.Dat.OperatorSelector=0)  Then {реализация клиенту}
   If ((E^.Dat.DocSelector in [3,4]) And Not(E^.Dat.Realiz)) Or{не вторичная консигнация}
      (E^.Dat.DocSelector in [6,8]) Then{консигнация}
    Begin
     SClientKod:=IntToStr(E^.Dat.OperatorSelector,COne)+GetBuchKod(Kod,E^.Dat.OperatorSelector,E^.Dat.ClientKod);
     RFormatZerro(SClientKod,8);
     SKod:=IntToStr(StrToInt(E^.Dat.SkladKod),CMantissa);
     RFormatZerro(SKod,CMantissa);
     E^.Dat.Document:=IntToStr(StrToInt(E^.Dat.Document),CDocNumer);
     RFormatZerro(E^.Dat.Document,CDocNumer-1);

     SDate:=E^.Dat.DateC;
     Razvorot(SDate);
     SDate:=ClearChar(SDate);
     CalcNDSSpecial1S(Kod,E,NDS20,NDS18,NDS10,NDS_,Litr20,Litr18,Litr10,Litr_,
	                   ZakupkaOutNDS20,ZakupkaOutNDS18,ZakupkaOutNDS10,ZakupkaOutNDS_,
				    NDSZ20,NDSZ18,NDSZ10,NDSZ_,Opl20,Opl18,Opl10,Opl_,Akzis);

     If (Abs(NDS20)>0.009) Or (Abs(NDS18)>0.009) Or (Abs(NDS10)>0.009) Or (Abs(NDS_)>0.009) Or
	   (Abs(Litr20)>0.009) Or (Abs(Litr18)>0.009)
	   Or (Abs(Litr10)>0.009) Or (Abs(Litr_)>0.009) Or (Abs(ZakupkaOutNDS20)>0.009) Or
	   (Abs(ZakupkaOutNDS10)>0.009)Or  (Abs(ZakupkaOutNDS18)>0.009)
	   Or (Abs(ZakupkaOutNDS_)>0.009) Or
	   (Abs(NDSZ20)>0.009) Or (Abs(NDSZ18)>0.009)
	   Or (Abs(NDSZ10)>0.009) Or (Abs(NDSZ_)>0.009) Or
	   (Abs(Opl20)>0.009) Or (Abs(Opl18)>0.009) Or (Abs(Opl10)>0.009) Or (Abs(Opl_)>0.009) Or
	   (Abs(Akzis)>0.009) Then
     With Base Do
      Begin
       Append; {добавить новую запись}
       WriteNum('OBJECT',StrToInt(E^.Dat.SkladKod));{Код объекта откуда происходит реализация}
       WriteNum('TYPEOPER',0);
       WriteStr('CLIENTKOD',SClientKod);
       WriteStr('DOCUMENT',SDATE+SKOD+E^.Dat.Document);
       WriteNum('DOGOVOR',0);
       WriteNum('SF',1);
       WriteStr('DATE',E^.Dat.DateC);
       WriteNum('KOL20',Litr20);{всего литров с НДС20}
       If FindParam('ZAKUPKAKOL') Then
              WriteNum('KOL20',ZakupkaOutNDS20);{сумма по ЗЦ без НДС20}
       WriteNum('SOPL20',Opl20);{к оплате с НДС20}
       WriteNum('NDSOPL20',NDS20);{НДС20 в сумме к оплате}
       WriteNum('SZOUT20',ZakupkaOutNDS20);{сумма по ЗЦ без НДС20}
       WriteNum('SNDSZ20',NDSZ20);{сумма НДС20 от З/Ц}
       WriteNum('KOL18',Litr18);{всего литров с НДС20}
       If FindParam('ZAKUPKAKOL') Then
              WriteNum('KOL18',ZakupkaOutNDS18);{сумма по ЗЦ без НДС20}

       WriteNum('SOPL18',Opl18);{к оплате с НДС20}
       WriteNum('NDSOPL18',NDS18);{НДС20 в сумме к оплате}
       WriteNum('SZOUT18',ZakupkaOutNDS18);{сумма по ЗЦ без НДС20}
       WriteNum('SNDSZ18',NDSZ18);{сумма НДС20 от З/Ц}
       WriteNum('KOL10',Litr10);{всего литров с НДС10}
       If FindParam('ZAKUPKAKOL') Then
              WriteNum('KOL10',ZakupkaOutNDS10);{сумма по ЗЦ без НДС20}
       WriteNum('SOPL10',Opl10);{к оплате с НДС10}
       WriteNum('NDSOPL10',NDS10);{НДС10 в сумме к оплате}
       WriteNum('SZOUT10',ZakupkaOutNDS10);{сумма по ЗЦ без НДС10}
       WriteNum('SNDSZ10',NDSZ10);{сумма НДС10 от З/Ц}
       WriteNum('KOL_',Litr_);{всего литров с НДС прочее}
       If FindParam('ZAKUPKAKOL') Then
              WriteNum('KOL_',ZakupkaOutNDS_);{сумма по ЗЦ без НДС20}

       WriteNum('SOPL_',OPL_);{к оплате с НДС прочее}
       WriteNum('NDSOPL_',NDS_);{НДС прочее в сумме к оплате}
       WriteNum('SZOUT_',ZakupkaOutNDS_);{сумма по ЗЦ без НДС прочее}
       WriteNum('SNDSZ_',NDSZ_);{сумма НДС прочее от З/Ц}
       WriteNum('AKZIS',AKZIS);{акцизный сбор}
      End;{With}
    End;
  End;

 Dispose(E,Done);

c:=IOResult;
 Close(f);  {закрытие mrk}
c:=IOResult;

c:=IOResult;
 Base.Close;{закрытие DBF}
c:=IOResult;

  AddLog(LogFile,'Импорт оптовой реалиации '+FDate+' для объекта '+IntToStr(Kod,CMantissa)+' успешно завершен');
End;


Procedure ImportINTERNAL(Kod:Word);
Var c : Word;
    E : PSuperMarketType;
    f : MarketFileType;
    SClientKod,
     SKod,
     SDate: AllStr;
    NDS20,
    NDS18,
    NDS10,
    NDS_,
    Litr20,
    Litr18,
    Litr10,
    Litr_,
    ZakupkaOutNDS20,
    ZakupkaOutNDS18,
    ZakupkaOutNDS10,
    ZakupkaOutNDS_,
    NDSZ20,
    NDSZ18,
    NDSZ10,
    NDSZ_,
    Opl20,
    Opl18,
    Opl10,
    Opl_,
    Akzis:Real;
Begin
If Not fExists(III.Task[Kod].PathToMarket+FDate+'.mrk') Then
 Begin
   {
   Writeln('Нет данных для экспорта '+III.Task[Kod].PathToMarket+FDate+'.mrk'+
	 +' у объекта '+IntToStr(Kod,CMantissa));
   }
   AddLog(LogFile,'Нет данных для экспорта '+III.Task[Kod].PathToMarket+FDate+'.mrk'+
	 +' у объекта '+IntToStr(Kod,CMantissa));
   Exit;
 End;


If Not fExists(III.PathToExport+'i'+EDate+'.dbf') Then
Begin
with Base do
begin
 Assign(III.PathToExport+'i'+EDate+'.dbf'); {пpисвоить БД имя}
 Init; {подготовиться к созданию БД}
 AddField('OBJECT','N',5,0);{Код объекта откуда происходит реализация}
 AddField('KOMU','N',5,0);{код клиента-получателя}
 AddField('DOCUMENT','C',9,0);{код клиента}
 AddField('DATE','C',8,0);{код признак генерации СФ}
 AddField('KOL20','N',14,3);{всего литров с НДС20}
 AddField('SOPL20','N',15,2);{к оплате с НДС20}
 AddField('NDSOPL20','N',15,2);{НДС20 в сумме к оплате}
 AddField('SZOUT20','N',15,4);{сумма по ЗЦ без НДС20}
 AddField('SNDSZ20','N',15,4);{сумма НДС20 от З/Ц}
 AddField('KOL10','N',14,3);{всего литров с НДС10}
 AddField('SOPL10','N',15,2);{к оплате с НДС10}
 AddField('NDSOPL10','N',15,2);{НДС10 в сумме к оплате}
 AddField('SZOUT10','N',15,4);{сумма по ЗЦ без НДС10}
 AddField('SNDSZ10','N',15,4);{сумма НДС10 от З/Ц}
 AddField('KOL_','N',14,3);{всего литров с НДС прочее}
 AddField('SOPL_','N',15,2);{к оплате с НДС прочее}
 AddField('NDSOPL_','N',15,2);{НДС прочее в сумме к оплате}
 AddField('SZOUT_','N',15,4);{сумма по ЗЦ без НДС прочее}
 AddField('SNDSZ_','N',15,4);{сумма НДС прочее от З/Ц}
 AddField('AKZIS','N',15,4);{акцизный сбор}
 AddField('DOCOSN','C',9,0);{документ основания}
 AddField('DATEOSN','C',8,0);{дата документа основания}
 AddField('KOL18','N',14,3);{всего литров с НДС18}
 AddField('SOPL18','N',15,2);{к оплате с НДС18}
 AddField('NDSOPL18','N',15,2);{НДС18 в сумме к оплате}
 AddField('SZOUT18','N',15,4);{сумма по ЗЦ без НДС18}
 AddField('SNDSZ18','N',15,4);{сумма НДС18 от З/Ц}

      if Create then
         Open(ReadWrite)
      else
     begin
      {
      Writeln('Ошибка создания '+III.PathToExport+'i'+EDate+
	 '.dbf'+' у объекта '+IntToStr(Kod,CMantissa));
      }
      AddLog(LogFile,'Ошибка создания '+III.PathToExport+'i'+EDate+
	 '.dbf'+' у объекта '+IntToStr(Kod,CMantissa));
      exit;
     end;

  AddLog(LogFile,'Создание базы данных '+III.PathToExport+'i'+EDate+'.dbf'+' успешно завершено');

c:=IOResult;
     Close;
c:=IOResult;
End;{With Base}
End;



 Assign(f,III.Task[Kod].PathToMarket+FDate+'.mrk');
 c:=IOResult;
 Reset(f);
 c:=IOResult;
 If c<>0 Then
  Begin
   {
   Writeln('Ошибка открытия '+III.Task[Kod].PathToMarket+FDate+'.mrk'+
	 +' у объекта '+IntToStr(Kod,CMantissa)+' Код:'+IntToStr(c,CMantissa));
   }
   AddLog(LogFile,'Нет данных для экспорта '+III.Task[Kod].PathToMarket+FDate+'.mrk'+
	 +' у объекта '+IntToStr(Kod,CMantissa)+' Код:'+IntToStr(c,CMantissa));
   Exit;
  End;

 Base.Assign(III.PathToExport+'i'+EDate+'.dbf');
 c:=IOResult;
 Base.Open(ReadWrite);
 c:=IOResult;
 If c<>0 Then
  Begin
   Close(f);
   c:=IOResult;
   {
   Writeln('Ошибка открытия '+III.PathToExport+'i'+EDate+'.dbf'+
	 +' у объекта '+IntToStr(Kod,CMantissa)+' Код:'+IntToStr(c,CMantissa));
   }
   AddLog(LogFile,III.PathToExport+'i'+EDate+'.dbf'+
	 +' у объекта '+IntToStr(Kod,CMantissa)+' Код:'+IntToStr(c,CMantissa));
   Exit;
  End;


 New(E,Init);

 While Not(Eof(f)) Do
  Begin
   ReadMarket(f,E);
   If E^.Dat.Active Then{активный}
   If (E^.Dat.OperatorSelector=1) And (StrToInt(E^.Dat.ClientKod)>0) Then {реализация клиенту}
    Begin
     SClientKod:=E^.Dat.ClientKod;
     RFormatZerro(SClientKod,8);
     SKod:=IntToStr(StrToInt(E^.Dat.SkladKod),CMantissa);
     RFormatZerro(SKod,CMantissa);
     E^.Dat.Document:=IntToStr(StrToInt(E^.Dat.Document),CDocNumer);
     RFormatZerro(E^.Dat.Document,CDocNumer-1);

     SDate:=E^.Dat.DateC;
     Razvorot(SDate);
     SDate:=ClearChar(SDate);

     CalcNDSSpecial1S(Kod,E,NDS20,NDS18,NDS10,NDS_,Litr20,Litr18,Litr10,Litr_,
                      ZakupkaOutNDS20,ZakupkaOutNDS18,ZakupkaOutNDS10,ZakupkaOutNDS_,
				  NDSZ20,NDSZ18,NDSZ10,NDSZ_,Opl20,Opl18,Opl10,Opl_,Akzis);

     If (Abs(NDS20)>0.009) Or (Abs(NDS18)>0.009) Or (Abs(NDS10)>0.009) Or (Abs(NDS_)>0.009) Or
	   (Abs(Litr20)>0.009)
	   Or (Abs(Litr10)>0.009) Or (Abs(Litr18)>0.009) Or (Abs(Litr_)>0.009) Or
	   (Abs(ZakupkaOutNDS20)>0.009) Or (Abs(ZakupkaOutNDS18)>0.009) Or
	   (Abs(ZakupkaOutNDS10)>0.009) Or (Abs(ZakupkaOutNDS_)>0.009) Or
	   (Abs(NDSZ20)>0.009) Or (Abs(NDSZ18)>0.009) Or (Abs(NDSZ10)>0.009) Or
	   (Abs(NDSZ_)>0.009) Or
	   (Abs(Opl20)>0.009) Or (Abs(Opl18)>0.009) Or
	   (Abs(Opl10)>0.009) Or (Abs(Opl_)>0.009) Or
	   (Abs(Akzis)>0.009) Then

     With Base Do
      Begin
       Append; {добавить новую запись}
       WriteNum('OBJECT',StrToInt(E^.Dat.SkladKod));{Код объекта откуда происходит реализация}
       WriteNUM('KOMU',StrToInt(E^.Dat.ClientKod));
       WriteStr('DOCUMENT',SDATE+SKOD+E^.Dat.Document);
       WriteStr('DATE',E^.Dat.DateC);
       WriteNum('KOL20',Litr20);{всего литров с НДС20}

       If FindParam('ZAKUPKAKOL') Then
              WriteNum('KOL20',ZakupkaOutNDS20);{сумма по ЗЦ без НДС20}

       WriteNum('SOPL20',Opl20);{к оплате с НДС20}
       WriteNum('NDSOPL20',NDS20);{НДС20 в сумме к оплате}
       WriteNum('SZOUT20',ZakupkaOutNDS20);{сумма по ЗЦ без НДС20}
       WriteNum('SNDSZ20',NDSZ20);{сумма НДС20 от З/Ц}
       WriteNum('KOL18',Litr18);{всего литров с НДС18}

       If FindParam('ZAKUPKAKOL') Then
              WriteNum('KOL18',ZakupkaOutNDS18);{сумма по ЗЦ без НДС20}

       WriteNum('SOPL18',Opl18);{к оплате с НДС18}
       WriteNum('NDSOPL18',NDS18);{НДС18 в сумме к оплате}
       WriteNum('SZOUT18',ZakupkaOutNDS18);{сумма по ЗЦ без НДС18}
       WriteNum('SNDSZ18',NDSZ18);{сумма НДС18 от З/Ц}
       WriteNum('KOL10',Litr10);{всего литров с НДС10}

       If FindParam('ZAKUPKAKOL') Then
              WriteNum('KOL10',ZakupkaOutNDS10);{сумма по ЗЦ без НДС20}

       WriteNum('SOPL10',Opl10);{к оплате с НДС10}
       WriteNum('NDSOPL10',NDS10);{НДС10 в сумме к оплате}
       WriteNum('SZOUT10',ZakupkaOutNDS10);{сумма по ЗЦ без НДС10}
       WriteNum('SNDSZ10',NDSZ10);{сумма НДС10 от З/Ц}
       WriteNum('KOL_',Litr_);{всего литров с НДС прочее}

       If FindParam('ZAKUPKAKOL') Then
              WriteNum('KOL_',ZakupkaOutNDS_);{сумма по ЗЦ без НДС20}

       WriteNum('SOPL_',OPL_);{к оплате с НДС прочее}
       WriteNum('NDSOPL_',NDS_);{НДС прочее в сумме к оплате}
       WriteNum('SZOUT_',ZakupkaOutNDS_);{сумма по ЗЦ без НДС прочее}
       WriteNum('SNDSZ_',NDSZ_);{сумма НДС прочее от З/Ц}
       WriteNum('AKZIS',AKZIS);{акцизный сбор}
      End;
    End;
  End;

 Dispose(E,Done);

c:=IOResult;
 Close(f);  {закрытие mrk}
c:=IOResult;

c:=IOResult;
 Base.Close;{закрытие DBF}
c:=IOResult;

  AddLog(LogFile,'Импорт внутренних перевозок '+FDate+' для объекта '+IntToStr(Kod,CMantissa)+' успешно завершен');

End;





Procedure ImportPrihodAsINTERNAL(Kod:Word);
Var c : Word;
    E : PPrihodType;
    f : PrihodFileType;
    SClientKod,
     SKod,
     SDate: AllStr;
    NDS20,
    NDS18,
    NDS10,
    NDS_,
    Litr20,
    Litr18,
    Litr10,
    Litr_,
    ZakupkaOutNDS20,
    ZakupkaOutNDS18,
    ZakupkaOutNDS10,
    ZakupkaOutNDS_,
    NDSZ20,
    NDSZ18,
    NDSZ10,
    NDSZ_,
    Opl20,
    Opl18,
    Opl10,
    Opl_,
    Akzis:Real;
Begin
If III.Task[Kod].VirtualPrihod=0 Then Exit;

If Not fExists(III.Task[Kod].PathToPrihod+FDate+'.prh') Then
 Begin
   {
   Writeln('Нет данных для экспорта '+III.Task[Kod].PathToPrihod+FDate+'.prh'+
	 +' у объекта '+IntToStr(Kod,CMantissa));
   }
   AddLog(LogFile,'Нет данных для экспорта '+III.Task[Kod].PathToPrihod+FDate+'.prh'+
	 +' у объекта '+IntToStr(Kod,CMantissa));
   Exit;
 End;


If Not fExists(III.PathToExport+'i'+EDate+'.dbf') Then
Begin
with Base do
begin
 Assign(III.PathToExport+'i'+EDate+'.dbf'); {пpисвоить БД имя}
 Init; {подготовиться к созданию БД}
 AddField('OBJECT','N',5,0);{Код объекта откуда происходит реализация}
 AddField('KOMU','N',5,0);{код клиента-получателя}
 AddField('DOCUMENT','C',9,0);{код клиента}
 AddField('DATE','C',8,0);{код признак генерации СФ}
 AddField('KOL20','N',14,3);{всего литров с НДС20}
 AddField('SOPL20','N',15,2);{к оплате с НДС20}
 AddField('NDSOPL20','N',15,2);{НДС20 в сумме к оплате}
 AddField('SZOUT20','N',15,4);{сумма по ЗЦ без НДС20}
 AddField('SNDSZ20','N',15,4);{сумма НДС20 от З/Ц}
 AddField('KOL10','N',14,3);{всего литров с НДС10}
 AddField('SOPL10','N',15,2);{к оплате с НДС10}
 AddField('NDSOPL10','N',15,2);{НДС10 в сумме к оплате}
 AddField('SZOUT10','N',15,4);{сумма по ЗЦ без НДС10}
 AddField('SNDSZ10','N',15,4);{сумма НДС10 от З/Ц}
 AddField('KOL_','N',14,3);{всего литров с НДС прочее}
 AddField('SOPL_','N',15,2);{к оплате с НДС прочее}
 AddField('NDSOPL_','N',15,2);{НДС прочее в сумме к оплате}
 AddField('SZOUT_','N',15,4);{сумма по ЗЦ без НДС прочее}
 AddField('SNDSZ_','N',15,4);{сумма НДС прочее от З/Ц}
 AddField('AKZIS','N',15,4);{акцизный сбор}
 AddField('DOCOSN','C',9,0);{документ основания}
 AddField('DATEOSN','C',8,0);{дата документа основания}
 AddField('KOL18','N',14,3);{всего литров с НДС18}
 AddField('SOPL18','N',15,2);{к оплате с НДС18}
 AddField('NDSOPL18','N',15,2);{НДС18 в сумме к оплате}
 AddField('SZOUT18','N',15,4);{сумма по ЗЦ без НДС18}
 AddField('SNDSZ18','N',15,4);{сумма НДС18 от З/Ц}

      if Create then
         Open(ReadWrite)
      else
     begin
      {
      Writeln('Ошибка создания '+III.PathToExport+'i'+EDate+
	 '.dbf'+' у объекта '+IntToStr(Kod,CMantissa));
      }
      AddLog(LogFile,'Ошибка создания '+III.PathToExport+'i'+EDate+
	 '.dbf'+' у объекта '+IntToStr(Kod,CMantissa));
      exit;
     end;

  AddLog(LogFile,'Создание базы данных '+III.PathToExport+'i'+EDate+'.dbf'+' успешно завершено');

c:=IOResult;
     Close;
c:=IOResult;
End;{With Base}
End;



 Assign(f,III.Task[Kod].PathToPrihod+FDate+'.prh');
 c:=IOResult;
 Reset(f);
 c:=IOResult;
 If c<>0 Then
  Begin
   {
   Writeln('Ошибка открытия '+III.Task[Kod].PathToPrihod+FDate+'.prh'+
	 +' у объекта '+IntToStr(Kod,CMantissa)+' Код:'+IntToStr(c,CMantissa));
   }
   AddLog(LogFile,'Нет данных для экспорта '+III.Task[Kod].PathToPrihod+FDate+'.prh'+
	 +' у объекта '+IntToStr(Kod,CMantissa)+' Код:'+IntToStr(c,CMantissa));
   Exit;
  End;

 Base.Assign(III.PathToExport+'i'+EDate+'.dbf');
 c:=IOResult;
 Base.Open(ReadWrite);
 c:=IOResult;
 If c<>0 Then
  Begin
   Close(f);
   c:=IOResult;
   {
   Writeln('Ошибка открытия '+III.PathToExport+'i'+EDate+'.dbf'+
	 +' у объекта '+IntToStr(Kod,CMantissa)+' Код:'+IntToStr(c,CMantissa));
   }
   AddLog(LogFile,'Ошибка открытия '+III.PathToExport+'i'+EDate+'.dbf'+
	 +' у объекта '+IntToStr(Kod,CMantissa)+' Код:'+IntToStr(c,CMantissa));
   Exit;
  End;


 New(E,Init);

 While Not(Eof(f)) Do
  Begin
   ReadPrihod(f,E);
   If E^.Dat.StatusDoc=0 Then{введен на склад}
   If (E^.Dat.OperatorSelector in [0,2])  Then {реализация клиенту}
    Begin
     SKod:=IntToStr(StrToInt(E^.Dat.SkladKod),CMantissa);
     RFormatZerro(SKod,CMantissa);
     E^.Dat.Document:=IntToStr(StrToInt(E^.Dat.Document),CDocNumer);
     RFormatZerro(E^.Dat.Document,CDocNumer-1);

     SDate:=E^.Dat.DateC;
     Razvorot(SDate);
     SDate:=ClearChar(SDate);

     CalcNDSSpecial1SPrihod(Kod,E,NDS20,NDS18,NDS10,NDS_,Litr20,Litr18,
	                   Litr10,Litr_,
	                   ZakupkaOutNDS20,ZakupkaOutNDS18,ZakupkaOutNDS10,ZakupkaOutNDS_,
				    NDSZ20,NDSZ18,NDSZ10,NDSZ_,Opl20,Opl18,Opl10,Opl_,Akzis);

     If (Abs(NDS20)>0.009) Or (Abs(NDS18)>0.009) Or (Abs(NDS10)>0.009) Or (Abs(NDS_)>0.009) Or
	   (Abs(Litr20)>0.009) Or (Abs(Litr18)>0.009)
	   Or (Abs(Litr10)>0.009) Or (Abs(Litr_)>0.009) Or (Abs(ZakupkaOutNDS20)>0.009) Or
	   (Abs(ZakupkaOutNDS10)>0.009) Or (Abs(ZakupkaOutNDS18)>0.009)
	    Or (Abs(ZakupkaOutNDS_)>0.009) Or
	   (Abs(NDSZ20)>0.009) Or (Abs(NDSZ18)>0.009) Or (Abs(NDSZ10)>0.009) Or (Abs(NDSZ_)>0.009) Or
	   (Abs(Opl20)>0.009) Or (Abs(Opl18)>0.009) Or (Abs(Opl10)>0.009) Or (Abs(Opl_)>0.009) Or
	   (Abs(Akzis)>0.009) Then

     With Base Do
      Begin
       Append; {добавить новую запись}
       WriteNum('OBJECT',III.BufferSkladKod);{Код объекта откуда происходит реализация}
       WriteNUM('KOMU',StrToInt(E^.Dat.SkladKod));
       WriteStr('DOCUMENT',SDATE+SKOD+E^.Dat.Document);
       WriteStr('DATE',E^.Dat.DateC);
       WriteNum('KOL20',Litr20);{всего литров с НДС20}

       If FindParam('ZAKUPKAKOL') Then
              WriteNum('KOL20',ZakupkaOutNDS20);{сумма по ЗЦ без НДС20}

       WriteNum('SOPL20',Opl20);{к оплате с НДС20}
       WriteNum('NDSOPL20',NDS20);{НДС20 в сумме к оплате}
       WriteNum('SZOUT20',ZakupkaOutNDS20);{сумма по ЗЦ без НДС20}
       WriteNum('SNDSZ20',NDSZ20);{сумма НДС20 от З/Ц}
       WriteNum('KOL18',Litr18);{всего литров с НДС18}
       If FindParam('ZAKUPKAKOL') Then
              WriteNum('KOL18',ZakupkaOutNDS18);{сумма по ЗЦ без НДС20}

       WriteNum('SOPL18',Opl18);{к оплате с НДС18}
       WriteNum('NDSOPL18',NDS18);{НДС18 в сумме к оплате}
       WriteNum('SZOUT18',ZakupkaOutNDS18);{сумма по ЗЦ без НДС18}
       WriteNum('SNDSZ18',NDSZ18);{сумма НДС18 от З/Ц}
       WriteNum('KOL10',Litr10);{всего литров с НДС10}
       If FindParam('ZAKUPKAKOL') Then
              WriteNum('KOL10',ZakupkaOutNDS10);{сумма по ЗЦ без НДС20}

       WriteNum('SOPL10',Opl10);{к оплате с НДС10}
       WriteNum('NDSOPL10',NDS10);{НДС10 в сумме к оплате}
       WriteNum('SZOUT10',ZakupkaOutNDS10);{сумма по ЗЦ без НДС10}
       WriteNum('SNDSZ10',NDSZ10);{сумма НДС10 от З/Ц}
       WriteNum('KOL_',Litr_);{всего литров с НДС прочее}
       If FindParam('ZAKUPKAKOL') Then
              WriteNum('KOL_',ZakupkaOutNDS_);{сумма по ЗЦ без НДС20}

       WriteNum('SOPL_',OPL_);{к оплате с НДС прочее}
       WriteNum('NDSOPL_',NDS_);{НДС прочее в сумме к оплате}
       WriteNum('SZOUT_',ZakupkaOutNDS_);{сумма по ЗЦ без НДС прочее}
       WriteNum('SNDSZ_',NDSZ_);{сумма НДС прочее от З/Ц}
       WriteNum('AKZIS',AKZIS);{акцизный сбор}
      End;
    End;
  End;

 Dispose(E,Done);

c:=IOResult;
 Close(f);  {закрытие prh}
c:=IOResult;

c:=IOResult;
 Base.Close;{закрытие DBF}
c:=IOResult;

  AddLog(LogFile,'Импорт внутренних приходов '+FDate+' для объекта '+IntToStr(Kod,CMantissa)+' успешно завершен');
End;



Procedure ImportPrihod(Kod:Word);
Var c : Word;
    E : PPrihodType;
    f : PrihodFileType;
    SClientKod,
     SKod,
     SDate: AllStr;
    NDS20,
    NDS18,
    NDS10,
    NDS_,
    Litr20,
    Litr18,
    Litr10,
    Litr_,
    ZakupkaOutNDS20,
    ZakupkaOutNDS18,
    ZakupkaOutNDS10,
    ZakupkaOutNDS_,
    NDSZ20,
    NDSZ18,
    NDSZ10,
    NDSZ_,
    Opl20,
    Opl18,
    Opl10,
    Opl_,
    Akzis:Real;
Begin
If III.Task[Kod].ExternalPrihod=0 Then Exit;

If Not fExists(III.Task[Kod].PathToPrihod+FDate+'.prh') Then
 Begin
   {
   Writeln('Нет данных для экспорта '+III.Task[Kod].PathToPrihod+FDate+'.prh'+
	 +' у объекта '+IntToStr(Kod,CMantissa));
   }
   AddLog(LogFile,'Нет данных для экспорта '+III.Task[Kod].PathToPrihod+FDate+'.prh'+
	 +' у объекта '+IntToStr(Kod,CMantissa));
   Exit;
 End;


If Not fExists(III.PathToExport+'p'+EDate+'.dbf') Then
Begin
with Base do
begin
 Assign(III.PathToExport+'p'+EDate+'.dbf'); {пpисвоить БД имя}
 Init; {подготовиться к созданию БД}
 AddField('OBJECT','N',5,0);{Код объекта откуда происходит реализация}
 AddField('KTO','C',8,0);{код клиента-получателя}
 AddField('DOCUMENT','C',9,0);{код клиента}
 AddField('DATE','C',8,0);{код признак генерации СФ}
 AddField('KOL20','N',14,3);{всего литров с НДС20}
 AddField('SOPL20','N',15,2);{к оплате с НДС20}
 AddField('NDSOPL20','N',15,2);{НДС20 в сумме к оплате}
 AddField('SZOUT20','N',15,4);{сумма по ЗЦ без НДС20}
 AddField('SNDSZ20','N',15,4);{сумма НДС20 от З/Ц}
 AddField('KOL10','N',14,3);{всего литров с НДС10}
 AddField('SOPL10','N',15,2);{к оплате с НДС10}
 AddField('NDSOPL10','N',15,2);{НДС10 в сумме к оплате}
 AddField('SZOUT10','N',15,4);{сумма по ЗЦ без НДС10}
 AddField('SNDSZ10','N',15,4);{сумма НДС10 от З/Ц}
 AddField('KOL_','N',14,3);{всего литров с НДС прочее}
 AddField('SOPL_','N',15,2);{к оплате с НДС прочее}
 AddField('NDSOPL_','N',15,2);{НДС прочее в сумме к оплате}
 AddField('SZOUT_','N',15,4);{сумма по ЗЦ без НДС прочее}
 AddField('SNDSZ_','N',15,4);{сумма НДС прочее от З/Ц}
 AddField('AKZIS','N',15,4);{акцизный сбор}
 AddField('DOCOSN','C',25,0);{документ основания}
 AddField('DATEOSN','C',8,0);{дата документа основания}
 AddField('KOL18','N',14,3);{всего литров с НДС18}
 AddField('SOPL18','N',15,2);{к оплате с НДС18}
 AddField('NDSOPL18','N',15,2);{НДС18 в сумме к оплате}
 AddField('SZOUT18','N',15,4);{сумма по ЗЦ без НДС18}
 AddField('SNDSZ18','N',15,4);{сумма НДС18 от З/Ц}

      if Create then
         Open(ReadWrite)
      else
     begin
      {
      Writeln('Ошибка создания '+III.PathToExport+'i'+EDate+
	 '.dbf'+' у объекта '+IntToStr(Kod,CMantissa));
      }
      AddLog(LogFile,'Ошибка создания '+III.PathToExport+'p'+EDate+
	 '.dbf'+' у объекта '+IntToStr(Kod,CMantissa));
      exit;
     end;

  AddLog(LogFile,'Создание базы данных '+III.PathToExport+'p'+EDate+'.dbf'+' успешно завершено');

c:=IOResult;
     Close;
c:=IOResult;
End;{With Base}
End;



 Assign(f,III.Task[Kod].PathToPrihod+FDate+'.prh');
 c:=IOResult;
 Reset(f);
 c:=IOResult;
 If c<>0 Then
  Begin
   {
   Writeln('Ошибка открытия '+III.Task[Kod].PathToPrihod+FDate+'.prh'+
	 +' у объекта '+IntToStr(Kod,CMantissa)+' Код:'+IntToStr(c,CMantissa));
   }
   AddLog(LogFile,'Нет данных для экспорта '+III.Task[Kod].PathToPrihod+FDate+'.prh'+
	 +' у объекта '+IntToStr(Kod,CMantissa)+' Код:'+IntToStr(c,CMantissa));
   Exit;
  End;

 Base.Assign(III.PathToExport+'p'+EDate+'.dbf');
 c:=IOResult;
 Base.Open(ReadWrite);
 c:=IOResult;
 If c<>0 Then
  Begin
   Close(f);
   c:=IOResult;
   {
   Writeln('Ошибка открытия '+III.PathToExport+'i'+EDate+'.dbf'+
	 +' у объекта '+IntToStr(Kod,CMantissa)+' Код:'+IntToStr(c,CMantissa));
   }
   AddLog(LogFile,'Ошибка открытия '+III.PathToExport+'p'+EDate+'.dbf'+
	 +' у объекта '+IntToStr(Kod,CMantissa)+' Код:'+IntToStr(c,CMantissa));
   Exit;
  End;


 New(E,Init);

 While Not(Eof(f)) Do
  Begin
   ReadPrihod(f,E);
   If E^.Dat.StatusDoc=0 Then{введен на склад}
   If (E^.Dat.OperatorSelector in [0,2])  Then {приход от поставщика}
    Begin
     SKod:=IntToStr(StrToInt(E^.Dat.SkladKod),CMantissa);
     RFormatZerro(SKod,CMantissa);
     E^.Dat.Document:=IntToStr(StrToInt(E^.Dat.Document),CDocNumer);
     RFormatZerro(E^.Dat.Document,CDocNumer-1);

     SDate:=E^.Dat.DateC;
     Razvorot(SDate);
     SDate:=ClearChar(SDate);
     RFormatZerro(E^.Dat.Makekod,CClientKod);
     SClientKod:=E^.Dat.Makekod;

     RFormatZerro(SClientKod,6);

     CalcNDSSpecial1SPrihod(Kod,E,NDS20,NDS18,NDS10,NDS_,Litr20,Litr18,
	                   Litr10,Litr_,
	                   ZakupkaOutNDS20,ZakupkaOutNDS18,ZakupkaOutNDS10,ZakupkaOutNDS_,
				    NDSZ20,NDSZ18,NDSZ10,NDSZ_,Opl20,Opl18,Opl10,Opl_,Akzis);

     If (Abs(NDS20)>0.009) Or (Abs(NDS18)>0.009) Or (Abs(NDS10)>0.009) Or (Abs(NDS_)>0.009) Or
	   (Abs(Litr20)>0.009) Or (Abs(Litr18)>0.009)
	   Or (Abs(Litr10)>0.009) Or (Abs(Litr_)>0.009) Or (Abs(ZakupkaOutNDS20)>0.009) Or
	   (Abs(ZakupkaOutNDS10)>0.009) Or (Abs(ZakupkaOutNDS18)>0.009)
	    Or (Abs(ZakupkaOutNDS_)>0.009) Or
	   (Abs(NDSZ20)>0.009) Or (Abs(NDSZ18)>0.009) Or (Abs(NDSZ10)>0.009) Or (Abs(NDSZ_)>0.009) Or
	   (Abs(Opl20)>0.009) Or (Abs(Opl18)>0.009) Or (Abs(Opl10)>0.009) Or (Abs(Opl_)>0.009) Or
	   (Abs(Akzis)>0.009) Then

     With Base Do
      Begin
       Append; {добавить новую запись}
       WriteNum('OBJECT',{III.BufferSkladKod}StrToInt(SKod));{Код объекта откуда происходит реализация}
       WriteStr('KTO','8'+IntToStr(E^.DAt.OperatorSelector,COne)+SClientKod);
       WriteStr('DOCUMENT',SDATE+SKOD+E^.Dat.Document);
       WriteStr('DATE',E^.Dat.DateC);
       WriteNum('KOL20',Litr20);{всего литров с НДС20}

       If FindParam('ZAKUPKAKOL') Then
              WriteNum('KOL20',ZakupkaOutNDS20);{сумма по ЗЦ без НДС20}

       WriteNum('SOPL20',Opl20);{к оплате с НДС20}
       WriteNum('NDSOPL20',NDS20);{НДС20 в сумме к оплате}
       WriteNum('SZOUT20',ZakupkaOutNDS20);{сумма по ЗЦ без НДС20}
       WriteNum('SNDSZ20',NDSZ20);{сумма НДС20 от З/Ц}
       WriteNum('KOL18',Litr18);{всего литров с НДС18}
       If FindParam('ZAKUPKAKOL') Then
              WriteNum('KOL18',ZakupkaOutNDS18);{сумма по ЗЦ без НДС20}

       WriteNum('SOPL18',Opl18);{к оплате с НДС18}
       WriteNum('NDSOPL18',NDS18);{НДС18 в сумме к оплате}
       WriteNum('SZOUT18',ZakupkaOutNDS18);{сумма по ЗЦ без НДС18}
       WriteNum('SNDSZ18',NDSZ18);{сумма НДС18 от З/Ц}
       WriteNum('KOL10',Litr10);{всего литров с НДС10}
       If FindParam('ZAKUPKAKOL') Then
              WriteNum('KOL10',ZakupkaOutNDS10);{сумма по ЗЦ без НДС20}

       WriteNum('SOPL10',Opl10);{к оплате с НДС10}
       WriteNum('NDSOPL10',NDS10);{НДС10 в сумме к оплате}
       WriteNum('SZOUT10',ZakupkaOutNDS10);{сумма по ЗЦ без НДС10}
       WriteNum('SNDSZ10',NDSZ10);{сумма НДС10 от З/Ц}
       WriteNum('KOL_',Litr_);{всего литров с НДС прочее}
       If FindParam('ZAKUPKAKOL') Then
              WriteNum('KOL_',ZakupkaOutNDS_);{сумма по ЗЦ без НДС20}

       WriteStr('DOCOSN',E^.Dat.Rekwizit.Numer);{сумма НДС10 от З/Ц}
       WriteStr('DATEOSN',E^.Dat.Rekwizit.Date);{всего литров с НДС прочее}



       If FindParam('ZAKUPKAKOL') Then
              WriteNum('KOL_',ZakupkaOutNDS_);{сумма по ЗЦ без НДС20}

       WriteNum('SOPL_',OPL_);{к оплате с НДС прочее}
       WriteNum('NDSOPL_',NDS_);{НДС прочее в сумме к оплате}
       WriteNum('SZOUT_',ZakupkaOutNDS_);{сумма по ЗЦ без НДС прочее}
       WriteNum('SNDSZ_',NDSZ_);{сумма НДС прочее от З/Ц}
       WriteNum('AKZIS',AKZIS);{акцизный сбор}
      End;
    End;
  End;

 Dispose(E,Done);

c:=IOResult;
 Close(f);  {закрытие prh}
c:=IOResult;

c:=IOResult;
 Base.Close;{закрытие DBF}
c:=IOResult;

  AddLog(LogFile,'Импорт внешних приходов '+FDate+' для объекта '+IntToStr(Kod,CMantissa)+' успешно завершен');
End;



Procedure AddMarketToMarketList(Var TempBox:PBox;Const E:PSuperMarketType);
Var j,i : Word;
    l:Boolean;
    Artikul : ArtikulStr;
    Find : Boolean;
    s: TMyString;
    ListKol,WKol,wo,wz,wz2,ListZakupka,ListZakupka2,ListOplata:AllStr;
Begin
  For i:=1 To E^.Dat.Amount Do
     Begin
       If E^.Dat.SkidkaSelector=0 Then{Если автомат}
         begin
           DelSpace(E^.Dat.MarketElement[i].Input.Proz);
           MyStr((StrToReal(E^.Dat.MarketElement[i].Input.Zena)/
           (1+StrToReal(E^.Dat.MarketElement[i].Input.Proz)/100)),CZena,CMantissa,E^.Dat.MarketElement[i].Input.Zena);
         End
       Else
         Begin
           MyStr((StrToReal(E^.Dat.MarketElement[i].Input.Zena)-StrToReal(E^.Dat.MarketElement[i].Input.Skidka))
           ,CZena,CMantissa,E^.Dat.MarketElement[i].Input.Zena);
         End;

      If StrToInt(E^.Dat.MarketElement[i].Input.Kol)>0 Then
      If Not TestElement(E^.Dat.MarketElement[i].BazKod,TempBox) Then
       Begin
        s:=TempBox^.GetText(Location(TempBox,E^.Dat.MarketElement[i].BazKod,False),
        TempBox^.List^.Count);

       Str(StrToInt(E^.Dat.MarketElement[i].Input.Kol):CKol,E^.Dat.MarketElement[i].Input.Kol);
       MyStr(StrToReal(E^.Dat.MarketElement[i].Input.Zena),CZena,CMantissa,E^.Dat.MarketElement[i].Input.Zena);
       MyStr(StrToReal(E^.Dat.MarketElement[i].Input.Zakupka),CZenaZ,CMantissaZ,E^.Dat.MarketElement[i].Input.Zakupka);
       MyStr(StrToReal(E^.Dat.MarketElement[i].Input.Zakupka2),CZenaZ,CMantissaZ,E^.Dat.MarketElement[i].Input.Zakupka2);

       MyStr(StrToReal(E^.Dat.MarketElement[i].Input.Zena)*StrToInt(E^.Dat.MarketElement[i].Input.Kol),
            CIZena,CMantissa,wo);

       MyStr(StrToReal(E^.Dat.MarketElement[i].Input.Zakupka)*StrToInt(E^.Dat.MarketElement[i].Input.Kol),
            CIZena,CMantissaz,wz);

       MyStr(StrToReal(E^.Dat.MarketElement[i].Input.Zakupka2)*StrToInt(E^.Dat.MarketElement[i].Input.Kol),
            CIZena,CMantissaz,wz2);

        {Kol в листе}
        ListKol:=Copy(s,1+1+CArtikul+1,CKol+1);
        ListZakupka:= Copy(s,1+1+CArtikul+1+(CKol+1)+1,CIZena);
        ListZakupka2:=Copy(s,1+1+CArtikul+1+(CKol+1)+1+CIZena+1,CIZena);
        ListOplata:=  Copy(s,1+1+CArtikul+1+(CKol+1)+1+CIZena+1+CIZena+1,CIZena);

        Str(StrToInt(ListKol)+StrToInt(E^.Dat.MarketElement[i].Input.Kol):CKOl+1,Wkol);{просчитали новое количество}
        MyStr(StrToReal(ListZakupka)+StrToReal(wz),CIZena,CMAntissaZ,Wz);{просчитали новое количество}
        MyStr(StrToReal(ListZakupka2)+StrToReal(wz2),CIZena,CMAntissaZ,Wz2);{просчитали новое количество}
        MyStr(StrToReal(ListOplata)+StrToReal(wo),CIZena,CMAntissa,Wo);{просчитали новое количество}

        TempBox^.List^.AtFree(Location(TempBox,E^.Dat.MarketElement[i].BazKod,False));
        TempBox^.SetRange(TempBox^.List^.Count);
      End{TestElement}
     Else
      Begin
       WKol[0]:=#0;
       WZ[0]:=#0;
       WZ2[0]:=#0;
       Wo[0]:=#0;

       Str(StrToInt(E^.Dat.MarketElement[i].Input.Kol):CKol,WKol);

       MyStr(StrToReal(E^.Dat.MarketElement[i].Input.Zena)*StrToInt(E^.Dat.MarketElement[i].Input.Kol),
            CIZena,CMantissa,wo);

       MyStr(StrToReal(E^.Dat.MarketElement[i].Input.Zakupka)*StrToInt(E^.Dat.MarketElement[i].Input.Kol),
            CIZena,CMantissaz,wz);

       MyStr(StrToReal(E^.Dat.MarketElement[i].Input.Zakupka2)*StrToInt(E^.Dat.MarketElement[i].Input.Kol),
            CIZena,CMantissaz,wz2);

       Str(StrToInt(WKol):CKol+1,WKol);
       MyStr(StrToReal(Wz),CIZena,CMAntissaZ,wz);
       MyStr(StrToReal(Wz2),CIZena,CMAntissaZ,wz2);
       MyStr(StrToReal(Wo),CIZena,CMAntissaZ,wo);

      End;

        s:='│'+E^.Dat.MarketElement[i].BazKod+'│'+WKol+'│'+wz+'│'+wz2+'│'+wo;
        TempBox^.List^.Insert(NewStr(s));
        TempBox^.SetRange(TempBox^.List^.Count);
     End;{For}
End;{Procedure}



Procedure CalcNDSSpecial1SRozn(Const Kod:Word; Const TempBox:PBox; Var NDS20,NDS18,NDS10,NDS_,Litr20,
Litr18,Litr10,Litr_,
	                   ZakupkaOutNDS20,ZakupkaOutNDS18,ZakupkaOutNDS10,ZakupkaOutNDS_,
				    NDSZ20,NDSZ18,NDSZ10,NDSZ_,Opl20,Opl18,Opl10,Opl_,Akzis:Real);
Var j,i,l : Word;
    Art : ArtikulStr;
    Find : Boolean;
    ws,s: TMyString;
    VNDS,AllItogoBut : LongInt;
    ItogoLitr,ItogoPosZ,ItogoPos,SZakupka,NdsPos,NdsPosZ,ZakupkaOutNDS,
    AllItogo,AllItogoZ,AllItogoZ2 : Real;
    ListKol,WKol,wo,wz,wz2,SLitr,Wspom,StavkaNDS,SAkzis,
    ListZakupka,ListZakupka2,ListOplata:AllStr;
Begin
    NDS20:=0;
    NDS18:=0;
    NDS10:=0;
    NDS_:=0;
    Litr20:=0;
    Litr18:=0;
    Litr10:=0;
    Litr_:=0;
    ZakupkaOutNDS20:=0;
    ZakupkaOutNDS18:=0;
    ZakupkaOutNDS10:=0;
    ZakupkaOutNDS_:=0;
    NDSZ20:=0;
    NDSZ18:=0;
    NDSZ10:=0;
    NDSZ_:=0;
    Opl20:=0;
    Opl18:=0;
    Opl10:=0;
    Opl_:=0;
    Akzis:=0;

  If (TempBox^.List^.Count-1)>=0 Then
  Begin
  For l:=0 To TempBox^.List^.Count-1 Do
   Begin
    s:=TempBox^.GetText(l,TempBox^.List^.Count);
    ws:=Copy(s,1+1+CArtikul+1,(CKol+1));
    Art:=Copy(s,1+1,CArtikul);
    AllItogoBut:=StrToInt(ws);{колич}
    ws:=Copy(s,1+1+CArtikul+1+(CKol+1)+1,CIZena);
    AllItogoZ:=StrToReal(ws);{цены по закупке }
    ws:=Copy(s,1+1+CArtikul+1+(CKol+1)+1+CIZena+1,CIZena);
    AllItogoZ2:=StrToReal(ws);{цены по закупке 2}
    ws:=Copy(s,1+1+CArtikul+1+(CKol+1)+1+CIZena+1+CIZena+1,CIZena);
    AllItogo:=StrToReal(ws);{цены к оплате}

    SLitr:=GetIdField(Kod,FLitr,Art);

    If Not FindParam('LITR')Then SLitr:='1';

    VNDS:=StrToInt(GetIdField(Kod,FVidNDS,Art));
    StavkaNDS:=GetIdField(Kod,FNDS,Art);

       If III.Task[Kod].VidZakupka=0 Then
       SZakupka:=AllItogoZ
	  Else
       SZakupka:=AllItogoZ2;

       ItogoPos:=AllItogo;
       ItogoPosZ:=SZakupka;
       ItogoLitr:=StrToReal(SLitr)*AllItogoBut;

       If Not FindParam('LITR')Then ItogoLitr:=AllItogoBut;

       MyStr(ItogoPosZ,CIZena,CMantissaZ,Wspom);

       NdsPos:=ItogoPos*StrToReal(StavkaNDS)/(100+StrToReal(StavkaNDS));
       NdsPosZ:=ItogoPosZ*StrToReal(StavkaNDS)/(100+StrToReal(StavkaNDS));

       MyStr(NDSPosZ,CIZena,CMantissaZ,Ws);

       NdsPosZ:=StrToReal(Ws);

       MyStr(NDSPos,CIZena,CMantissa,Ws);
       NdsPos:=StrToReal(Ws);

       ZakupkaOutNDS:=ItogoPosZ-NDSPosZ;

       MyStr(ZakupkaOutNDS,CIZena,CMantissaZ,Ws);
       ZakupkaOutNDS:=StrToReal(Ws);

     Case VNDS Of
     0:{НДС 20}
        Begin
         NDS20:=NDS20+NDSPOS;
         Litr20:=Litr20+ItogoLitr;
         ZakupkaOutNDS20:=ZakupkaOutNDS20+ZakupkaOutNDS;
         NDSZ20:=NDSZ20+NDSPOSZ;
         Opl20:=Opl20+ItogoPos;
        End;
     3:{НДС 18}
        Begin
         NDS18:=NDS18+NDSPOS;
         Litr18:=Litr18+ItogoLitr;
         ZakupkaOutNDS18:=ZakupkaOutNDS18+ZakupkaOutNDS;
         NDSZ18:=NDSZ18+NDSPOSZ;
         Opl18:=Opl18+ItogoPos;
        End;
     1:{НДС 10}
        Begin
         NDS10:=NDS10+NDSPOS;
         Litr10:=Litr10+ItogoLitr;
         ZakupkaOutNDS10:=ZakupkaOutNDS10+ZakupkaOutNDS;
         NDSZ10:=NDSZ10+NDSPOSZ;
         Opl10:=Opl10+ItogoPos;
        End;
     2:{НДС прочее}
        Begin
         NDS_:=NDS_+NDSPOS;
         Litr_:=Litr_+ItogoLitr;
         ZakupkaOutNDS_:=ZakupkaOutNDS_+ZakupkaOutNDS;
         NDSZ_:=NDSZ_+NDSPOSZ;
         Opl_:=Opl_+ItogoPos;
        End;
     Else;
     End;

      SAkzis[0]:=#0;
      With III Do
      Begin
      If III.Task[Kod].CalcAkzis=1 Then{производить расчет акцизного сбора}
      Begin

       If (III.Task[Kod].ShemaAkzis=1)  Then{схема расчета с суммы}
        Begin
        if StrToInt(GetIdField(Kod,FBuchGroup,Art)) in [1,2,3,4,7] then
        begin

         if StrToInt(GetIdField(Kod,FBuchGroup,Art)) in [1,2,3] then
         MyStr(
	    StrToReal(AkzisKoeff[StrToInt(GetIdField(Kod,FBuchGroup,Art))])
	   *0.8
	   *AllItogoBut
	   *StrToReal(GetIdField(Kod,FLitr,Art))
	   *StrToReal(GetIdField(Kod,FEtil,Art))
        /100,
         CIZena,CMantissaZ,SAkzis)
         Else
         MyStr(
	    StrToReal(AkzisKoeff[StrToInt(GetIdField(Kod,FBuchGroup,Art))])
	   *0.65
	   *AllItogoBut
	   *StrToReal(GetIdField(Kod,FLitr,Art))
	   *StrToReal(GetIdField(Kod,FEtil,Art))
        /100,
         CIZena,CMantissaZ,SAkzis)
        end
        else
        begin
         if StrToInt(GetIdField(Kod,FBuchGroup,Art)) in [1,2,3] then
         MyStr(
	    StrToReal(AkzisKoeff[StrToInt(GetIdField(Kod,FBuchGroup,Art))])
	   *0.8
	   *AllItogoBut
	   *StrToReal(GetIdField(Kod,FLitr,Art))
        ,
         CIZena,CMantissa,SAkzis)
         Else
         MyStr(
	    StrToReal(AkzisKoeff[StrToInt(GetIdField(Kod,FBuchGroup,Art))])
	   *0.65
	   *AllItogoBut
	   *StrToReal(GetIdField(Kod,FLitr,Art))
        ,
         CIZena,CMantissa,SAkzis)
        end;
        End
        Else
         Begin{схема расчета с единицы продукции}
           {
           MyStr(StrToReal(E^.Dat.VozwratElement[l].Input.AkzisSbor)*StrToInt(E^.Dat.VozwratElement[l].Input.Kol),
           CIZena,CMantissaZ,SAkzis);
           }
         End;
       AkZis:=Akzis+StrToReal(SAkzis);
      End;
     End;


(*
      SAkzis[0]:=#0;
      If III.Task[Kod].CalcAkzis=1 Then{производить расчет акцизного сбора}
      Begin
       If III.Task[Kod].ShemaAkzis=1 Then{схема расчета с суммы}
        Begin
        if StrToInt(GetIdField(Kod,FBuchGroup,Art)) in [1,2,3,4,7] then
        begin
         MyStr(
	    StrToReal(AkzisKoeff[StrToInt(GetIdField(Kod,FBuchGroup,Art))])
	   /2
	   *AllItogoBut
	   *StrToReal(GetIdField(Kod,FLitr,Art))
	   *StrToReal(GetIdField(Kod,FEtil,Art))
        /100,
         CIZena,CMantissaZ,SAkzis);
        end
        else
        begin
         MyStr(
	    StrToReal(AkzisKoeff[StrToInt(GetIdField(Kod,FBuchGroup,Art))])
	   /2
	   *AllItogoBut
	   *StrToReal(GetIdField(Kod,FLitr,Art))
        ,
         CIZena,CMantissa,SAkzis);
        end;
        End
        Else
         Begin{схема расчета с единицы продукции}
           {
           MyStr(StrToReal(E^.Dat.VozwratElement[l].Input.AkzisSbor)*StrToInt(E^.Dat.VozwratElement[l].Input.Kol),
           CIZena,CMantissaZ,SAkzis);
           }
         End;
       AkZis:=Akzis+StrToReal(SAkzis);
      End;
*)

  End;{For}
 End;
End;



Procedure ImportRozn(Kod:Word);
Var c : Word;
    E : PSuperMarketType;
    f : MarketFileType;
    SClientKod,
     SKod,
     SDate: AllStr;
    NDS20,
    NDS18,
    NDS10,
    NDS_,
    Litr20,
    Litr18,
    Litr10,
    Litr_,
    ZakupkaOutNDS20,
    ZakupkaOutNDS18,
    ZakupkaOutNDS10,
    ZakupkaOutNDS_,
    NDSZ20,
    NDSZ18,
    NDSZ10,
    NDSZ_,
    Opl20,
    Opl18,
    Opl10,
    Opl_,
    Akzis:Real;
    TempBox : PBox;
    SNum : ArtikulStr;
Begin
If Not fExists(III.Task[Kod].PathToMarket+FDate+'.mrk') Then
 Begin
   {
   Writeln('Нет данных для экспорта '+III.Task[Kod].PathToMarket+FDate+'.mrk'+
	 +' у объекта '+IntToStr(Kod,CMantissa));
   }
   AddLog(LogFile,'Нет данных для экспорта '+III.Task[Kod].PathToMarket+FDate+'.mrk'+
	 +' у объекта '+IntToStr(Kod,CMantissa));
   Exit;
 End;


If Not fExists(III.PathToExport+'m'+EDate+'.dbf') Then
Begin
with Base do
begin
 Assign(III.PathToExport+'m'+EDate+'.dbf'); {пpисвоить БД имя}
 Init; {подготовиться к созданию БД}
 AddField('OBJECT','N',5,0);{Код объекта откуда происходит реализация}
 AddField('TYPEOPER','N',1,0);{код операции 1-розница; 0-опт; 2-вз}
 AddField('CLIENTKOD','C',8,0);{код клиента}
 AddField('DOCUMENT','C',9,0);{код клиента}
 AddField('DOGOVOR','N',1,0);{ссылка на основной договор}
 AddField('SF','N',1,0);{код признак генерации СФ}
 AddField('DATE','C',8,0);{код признак генерации СФ}
 AddField('KOL20','N',14,3);{всего литров с НДС20}
 AddField('SOPL20','N',15,2);{к оплате с НДС20}
 AddField('NDSOPL20','N',15,2);{НДС20 в сумме к оплате}
 AddField('SZOUT20','N',15,4);{сумма по ЗЦ без НДС20}
 AddField('SNDSZ20','N',15,4);{сумма НДС20 от З/Ц}
 AddField('KOL10','N',14,3);{всего литров с НДС10}
 AddField('SOPL10','N',15,2);{к оплате с НДС10}
 AddField('NDSOPL10','N',15,2);{НДС10 в сумме к оплате}
 AddField('SZOUT10','N',15,4);{сумма по ЗЦ без НДС10}
 AddField('SNDSZ10','N',15,4);{сумма НДС10 от З/Ц}
 AddField('KOL_','N',14,3);{всего литров с НДС прочее}
 AddField('SOPL_','N',15,2);{к оплате с НДС прочее}
 AddField('NDSOPL_','N',15,2);{НДС прочее в сумме к оплате}
 AddField('SZOUT_','N',15,4);{сумма по ЗЦ без НДС прочее}
 AddField('SNDSZ_','N',15,4);{сумма НДС прочее от З/Ц}
 AddField('AKZIS','N',15,4);{акцизный сбор}
 AddField('DOCOSN','C',9,0);{документ основания}
 AddField('DATEOSN','C',8,0);{дата документа основания}
 AddField('KOL18','N',14,3);{всего литров с НДС18}
 AddField('SOPL18','N',15,2);{к оплате с НДС18}
 AddField('NDSOPL18','N',15,2);{НДС18 в сумме к оплате}
 AddField('SZOUT18','N',15,4);{сумма по ЗЦ без НДС18}
 AddField('SNDSZ18','N',15,4);{сумма НДС18 от З/Ц}

      if Create then
         Open(ReadWrite)
      else
     begin
      {
      Writeln('Ошибка создания '+III.PathToExport+'m'+EDate+
	 '.dbf'+' у объекта '+IntToStr(Kod,CMantissa));
      }
      AddLog(LogFile,'Ошибка создания '+III.PathToExport+'m'+EDate+
	 '.dbf'+' у объекта '+IntToStr(Kod,CMantissa));
      exit;
     end;

  AddLog(LogFile,'Создание базы данных '+III.PathToExport+'m'+EDate+'.dbf'+' успешно завершено');

c:=IOResult;
     Close;
c:=IOResult;
End;{With Base}
End;



 Assign(f,III.Task[Kod].PathToMarket+FDate+'.mrk');
 c:=IOResult;
 Reset(f);
 c:=IOResult;
 If c<>0 Then
  Begin
   {
   Writeln('Ошибка открытия '+III.Task[Kod].PathToMarket+FDate+'.mrk'+
	 +' у объекта '+IntToStr(Kod,CMantissa)+' Код:'+IntToStr(c,CMantissa));
   }
   AddLog(LogFile,'Нет данных для экспорта '+III.Task[Kod].PathToMarket+FDate+'.mrk'+
	 +' у объекта '+IntToStr(Kod,CMantissa)+' Код:'+IntToStr(c,CMantissa));
   Exit;
  End;

 Base.Assign(III.PathToExport+'m'+EDate+'.dbf');
 c:=IOResult;
 Base.Open(ReadWrite);
 c:=IOResult;
 If c<>0 Then
  Begin
   Close(f);
   c:=IOResult;
   {
   Writeln('Ошибка открытия '+III.PathToExport+'m'+EDate+'.dbf'+
	 +' у объекта '+IntToStr(Kod,CMantissa)+' Код:'+IntToStr(c,CMantissa));
   }
   AddLog(LogFile,III.PathToExport+'m'+EDate+'.dbf'+
	 +' у объекта '+IntToStr(Kod,CMantissa)+' Код:'+IntToStr(c,CMantissa));
   Exit;
  End;

 New(E,Init);
R.Assign(0, 0, 0, 0);
TempBox := New(PBox, Init(R, 1, Nil));
TempBox^.NewList(New(PTextCollection, Init(0,1)));


 While Not(Eof(f)) Do
  Begin
   ReadMarket(f,E);
    If (E^.Dat.Active) And
    (((E^.Dat.DocSelector=1) And Not(E^.Dat.Realiz) And (E^.Dat.OperatorSelector=0))
    Or (E^.Dat.DocSelector in [5,7])) Then
    Begin
       AddMarketToMarketList(TempBox,E);
    End;
  End;{While}
 Dispose(E,Done);

c:=IOResult;
 Close(f);  {закрытие mrk}
c:=IOResult;


CalcNDSSpecial1SRozn(Kod,TempBox,NDS20,NDS18,NDS10,NDS_,Litr20,Litr18,
                        Litr10,Litr_,ZakupkaOutNDS20,ZakupkaOutNDS18,
				    ZakupkaOutNDS10,ZakupkaOutNDS_,
				    NDSZ20,NDSZ18,NDSZ10,NDSZ_,Opl20,Opl18,
				    Opl10,Opl_,Akzis);


Dispose(TempBox,Done);
{
     SClientKod:=IntToStr(0,COne)+'0999';
     RFormatZerro(SClientKod,8);
}
     SClientKod:=IntToStr(Kod,CMantissa);
     RFormatZerro(SClientKod,CClientKod);
     SClientKod:=III.RoznizaClientPrefix+SClientKod;
     RFormatZerro(SClientKod,8);

     SKod:=IntToStr(Kod,CMantissa);
     RFormatZerro(SKod,CMantissa);
     SNum:=IntToStr((DateStringToDate(DAteMask,FDate)+1)-
     DateStringToDAte(DAteMask,'01-01-'+Copy(FDate,7,2)),CLitrMantissa);
     RFormatZerro(SNum,CLitrMantissa);

     SDate:=FDAte;
     Razvorot(SDate);
     SDate:=ClearChar(SDate);

     If (Abs(NDS20)>0.009) Or (Abs(NDS18)>0.009) Or (Abs(NDS10)>0.009) Or (Abs(NDS_)>0.009) Or
	   (Abs(Litr20)>0.009) or (Abs(Litr18)>0.009)
	   Or (Abs(Litr10)>0.009) Or (Abs(Litr_)>0.009) Or (Abs(ZakupkaOutNDS20)>0.009) Or
        (Abs(ZakupkaOutNDS18)>0.009) Or
	   (Abs(ZakupkaOutNDS10)>0.009) Or (Abs(ZakupkaOutNDS_)>0.009) Or
	   (Abs(NDSZ20)>0.009) Or (Abs(NDSZ18)>0.009) Or (Abs(NDSZ10)>0.009) Or (Abs(NDSZ_)>0.009) Or
	   (Abs(Opl20)>0.009) Or (Abs(Opl18)>0.009) Or (Abs(Opl10)>0.009) Or (Abs(Opl_)>0.009) Or
	   (Abs(Akzis)>0.009) Then
     With Base Do
      Begin
       Append; {добавить новую запись}
       WriteNum('OBJECT',Kod);{Код объекта откуда происходит реализация}
       WriteNum('TYPEOPER',1);{розничная реализация}
       WriteStr('CLIENTKOD',SClientKod);
       WriteStr('DOCUMENT',SDATE+SKOD+SNUM);
       WriteNum('DOGOVOR',0);
       WriteNum('SF',0);{не генерировать СФ}
       WriteStr('DATE',FDate);
       WriteNum('KOL20',Litr20);{всего литров с НДС20}

       If FindParam('ZAKUPKAKOL') Then
              WriteNum('KOL20',ZakupkaOutNDS20);{сумма по ЗЦ без НДС20}

       WriteNum('SOPL20',Opl20);{к оплате с НДС20}
       WriteNum('NDSOPL20',NDS20);{НДС20 в сумме к оплате}
       WriteNum('SZOUT20',ZakupkaOutNDS20);{сумма по ЗЦ без НДС20}
       WriteNum('SNDSZ20',NDSZ20);{сумма НДС20 от З/Ц}
       WriteNum('KOL18',Litr18);{всего литров с НДС18}

       If FindParam('ZAKUPKAKOL') Then
              WriteNum('KOL18',ZakupkaOutNDS18);{сумма по ЗЦ без НДС20}

       WriteNum('SOPL18',Opl18);{к оплате с НДС18}
       WriteNum('NDSOPL18',NDS18);{НДС18 в сумме к оплате}
       WriteNum('SZOUT18',ZakupkaOutNDS18);{сумма по ЗЦ без НДС18}
       WriteNum('SNDSZ18',NDSZ18);{сумма НДС18 от З/Ц}
       WriteNum('KOL10',Litr10);{всего литров с НДС10}

       If FindParam('ZAKUPKAKOL') Then
              WriteNum('KOL10',ZakupkaOutNDS10);{сумма по ЗЦ без НДС20}

       WriteNum('SOPL10',Opl10);{к оплате с НДС10}
       WriteNum('NDSOPL10',NDS10);{НДС10 в сумме к оплате}
       WriteNum('SZOUT10',ZakupkaOutNDS10);{сумма по ЗЦ без НДС10}
       WriteNum('SNDSZ10',NDSZ10);{сумма НДС10 от З/Ц}
       WriteNum('KOL_',Litr_);{всего литров с НДС прочее}

       If FindParam('ZAKUPKAKOL') Then
              WriteNum('KOL_',ZakupkaOutNDS_);{сумма по ЗЦ без НДС20}

       WriteNum('SOPL_',OPL_);{к оплате с НДС прочее}
       WriteNum('NDSOPL_',NDS_);{НДС прочее в сумме к оплате}
       WriteNum('SZOUT_',ZakupkaOutNDS_);{сумма по ЗЦ без НДС прочее}
       WriteNum('SNDSZ_',NDSZ_);{сумма НДС прочее от З/Ц}
       WriteNum('AKZIS',AKZIS);{акцизный сбор}
      End;{With}

c:=IOResult;
 Base.Close;{закрытие DBF}
c:=IOResult;

  AddLog(LogFile,'Импорт розничной реалиации '+FDate+' для объекта '+IntToStr(Kod,CMantissa)+' успешно завершен');
End;



Function GetMarket1(Kod:Word; As:DocumentEditZ;Var E:PSuperMarketType):Boolean;
VAr  ef : MarketFileType;
     Find : Boolean;
     i : Word;
     L : PSuperMarketType;
Begin
  GetMarket1:=False;
  Assign(ef,III.Task[Kod].PathToMarket+As.D+'.mrk');
  i:=IOResult;
  Reset(ef);
  i:=IOResult;
  If i<>0 Then
   Begin
    AddLog(LogFile,'Внимание! Ошибка открытия '+III.Task[Kod].PathToMarket+As.D+'.mrk'+' Код:'+IntToStr(i,CKOl));
    Exit;
   End;

  New(L,Init);
  DelSpace(As.EditPosition);
  Find:=False;

 {оптимизация поиска}
   If FileSize(ef)>(StrToInt(As.EditPosition)-1) Then
    Begin
     Seek(ef,StrToInt(As.EditPosition)-1);
     ReadMarket(ef,L);
     DelSpace(L^.Dat.Document);
     If ((StrToInt(ClearChar(As.EditPosition))=StrToInt(ClearChar(L^.Dat.Document)))And
          (As.D=L^.Dat.DateC) And (L^.Dat.Active)) Then
         Begin
             Find:=True;
         End
         Else Seek(ef,0);
    End;




  While Not(Eof(ef)) And Not(Find) Do
        Begin
         ReadMarket(ef,L);
         DelSpace(L^.Dat.Document);
          If ((StrToInt(ClearChar(As.EditPosition))=StrToInt(ClearChar(L^.Dat.Document)))And
          (As.D=L^.Dat.DateC) And (L^.Dat.Active)) Then Find:=True;
        End;

  If Not(Find) Then
   Begin
    {NoInfoMsg;}
    Dispose(L,Done);
    Close(Ef);
    AddLog(LogFile,'Внимание! Ошибка документ N '+As.EditPosition+' от '+As.D+' в базе продаж не найден!');
    Exit;
   End;
  E^.Dat:=L^.Dat;
  Dispose(L,Done);
  Close(Ef);
  {NoInfoMsg;}
  GetMarket1:=True;
End;





Procedure ImportReturn(Kod:Word);
Var c : Word;
    E : PNewVozwratType;
    Mr : PSuperMarketType;
    f : NewVozwratFileType;
    SClientKod,
    SKod,SDateR,SDate: AllStr;
    NDS20,
    NDS18,
    NDS10,
    NDS_,
    Litr20,
    Litr18,
    Litr10,
    Litr_,
    ZakupkaOutNDS20,
    ZakupkaOutNDS18,
    ZakupkaOutNDS10,
    ZakupkaOutNDS_,
    NDSZ20,
    NDSZ18,
    NDSZ10,
    NDSZ_,
    Opl20,
    Opl18,
    Opl10,
    Opl_,
    Akzis:Real;
    VVV : DocumentEditZ;
Begin

If Not fExists(III.Task[Kod].PathToReturn+FDate+'.vzw') Then
 Begin
   {
   Writeln('Нет данных для экспорта '+III.Task[Kod].PathToReturn+FDate+'.vzw'+
	 +' у объекта '+IntToStr(Kod,CMantissa));
   }
   AddLog(LogFile,'Нет данных для экспорта '+III.Task[Kod].PathToReturn+FDate+'.vzw'+
	 +' у объекта '+IntToStr(Kod,CMantissa));
   Exit;
 End;


If Not fExists(III.PathToExport+'m'+EDate+'.dbf') Then
Begin
with Base do
begin
 Assign(III.PathToExport+'m'+EDate+'.dbf'); {пpисвоить БД имя}
 Init; {подготовиться к созданию БД}
 AddField('OBJECT','N',5,0);{Код объекта откуда происходит реализация}
 AddField('TYPEOPER','N',1,0);{код операции 1-розница; 0-опт; 2-вз}
 AddField('CLIENTKOD','C',8,0);{код клиента}
 AddField('DOCUMENT','C',9,0);{код клиента}
 AddField('DOGOVOR','N',1,0);{ссылка на основной договор}
 AddField('SF','N',1,0);{код признак генерации СФ}
 AddField('DATE','C',8,0);{код признак генерации СФ}
 AddField('KOL20','N',14,3);{всего литров с НДС20}
 AddField('SOPL20','N',15,2);{к оплате с НДС20}
 AddField('NDSOPL20','N',15,2);{НДС20 в сумме к оплате}
 AddField('SZOUT20','N',15,4);{сумма по ЗЦ без НДС20}
 AddField('SNDSZ20','N',15,4);{сумма НДС20 от З/Ц}
 AddField('KOL10','N',14,3);{всего литров с НДС10}
 AddField('SOPL10','N',15,2);{к оплате с НДС10}
 AddField('NDSOPL10','N',15,2);{НДС10 в сумме к оплате}
 AddField('SZOUT10','N',15,4);{сумма по ЗЦ без НДС10}
 AddField('SNDSZ10','N',15,4);{сумма НДС10 от З/Ц}
 AddField('KOL_','N',14,3);{всего литров с НДС прочее}
 AddField('SOPL_','N',15,2);{к оплате с НДС прочее}
 AddField('NDSOPL_','N',15,2);{НДС прочее в сумме к оплате}
 AddField('SZOUT_','N',15,4);{сумма по ЗЦ без НДС прочее}
 AddField('SNDSZ_','N',15,4);{сумма НДС прочее от З/Ц}
 AddField('AKZIS','N',15,4);{акцизный сбор}
 AddField('DOCOSN','C',9,0);{документ основания}
 AddField('DATEOSN','C',8,0);{дата документа основания}
 AddField('KOL18','N',14,3);{всего литров с НДС18}
 AddField('SOPL18','N',15,2);{к оплате с НДС18}
 AddField('NDSOPL18','N',15,2);{НДС18 в сумме к оплате}
 AddField('SZOUT18','N',15,4);{сумма по ЗЦ без НДС18}
 AddField('SNDSZ18','N',15,4);{сумма НДС18 от З/Ц}

      if Create then
         Open(ReadWrite)
      else
     begin
      {
      Writeln('Ошибка создания '+III.PathToExport+'m'+EDate+
	 '.dbf'+' у объекта '+IntToStr(Kod,CMantissa));
      }
      AddLog(LogFile,'Ошибка создания '+III.PathToExport+'m'+EDate+
	 '.dbf'+' у объекта '+IntToStr(Kod,CMantissa));
      exit;
     end;

  AddLog(LogFile,'Создание базы данных '+III.PathToExport+'m'+EDate+'.dbf'+' успешно завершено');

c:=IOResult;
     Close;
c:=IOResult;
End;{With Base}
End;



 Assign(f,III.Task[Kod].PathToReturn+FDate+'.vzw');
 c:=IOResult;
 Reset(f);
 c:=IOResult;
 If c<>0 Then
  Begin
   {
   Writeln('Ошибка открытия '+III.Task[Kod].PathToReturn+FDate+'.vzw'+
	 +' у объекта '+IntToStr(Kod,CMantissa)+' Код:'+IntToStr(c,CMantissa));
   }
   AddLog(LogFile,'Нет данных для экспорта '+III.Task[Kod].PathToReturn+FDate+'.vzw'+
	 +' у объекта '+IntToStr(Kod,CMantissa)+' Код:'+IntToStr(c,CMantissa));
   Exit;
  End;

 Base.Assign(III.PathToExport+'m'+EDate+'.dbf');
 c:=IOResult;
 Base.Open(ReadWrite);
 c:=IOResult;
 If c<>0 Then
  Begin
   Close(f);
   c:=IOResult;
   {
   Writeln('Ошибка открытия '+III.PathToExport+'m'+EDate+'.dbf'+
	 +' у объекта '+IntToStr(Kod,CMantissa)+' Код:'+IntToStr(c,CMantissa));
   }
   AddLog(LogFile,III.PathToExport+'m'+EDate+'.dbf'+
	 +' у объекта '+IntToStr(Kod,CMantissa)+' Код:'+IntToStr(c,CMantissa));
   Exit;
  End;


 New(E,Init);

 While Not(Eof(f)) Do
  Begin
   ReadNewVozwrat(f,E);
   If (E^.Dat.StatusDoc=0) Then{введен на склад}
   If (E^.Dat.OperatorSelector=0)  Then {реализация клиенту}
    Begin

     If E^.DAt.DocSelector in [2,3,4,6,8] Then{оптовые возвраты}
     SClientKod:=IntToStr(E^.Dat.OperatorSelector,COne)+GetBuchKod(Kod,E^.Dat.OperatorSelector,E^.Dat.MakeKod)
     Else
      Begin{розничные возвраты}
       SClientKod:=IntToStr(Kod,CMantissa);
       RFormatZerro(SClientKod,CClientKod);
       SClientKod:=III.RoznizaClientPrefix+SClientKod;
      End;
     RFormatZerro(SClientKod,8);
     SKod:=IntToStr(StrToInt(E^.Dat.SkladKod),CMantissa);
     RFormatZerro(SKod,CMantissa);
     E^.Dat.Document:=IntToStr(StrToInt(E^.Dat.Document),CDocNumer);
     RFormatZerro(E^.Dat.Document,CDocNumer-1);

     SDate:=E^.Dat.DateC;
     Razvorot(SDate);
     SDate:=ClearChar(SDate);



  If (E^.Dat.VidDocument in[2,3])  Then
  Begin
    New(Mr,Init);
    VVV.D:=E^.Dat.BasisDate;
    VVV.EditPosition:=E^.Dat.BasisDoc;
    If GetMarket1(Kod,VVV,Mr) Then
     Begin
      DelSpace(Mr^.DAt.Document);
      DelSpace(Mr^.DAt.DateC);
      E^.Dat.BasisDoc:=Mr^.Dat.DocReal;
      E^.Dat.BasisDate:=DateToDateString(DateMask,Mr^.Dat.DocDate);
     End
     Else
      Begin
      E^.Dat.BasisDoc:='???';
      E^.Dat.BasisDate:='???';
      AddLog(LogFile,'Ошибка! Документ продажи '+vvv.EditPosition+' от '+vvv.D+' не найден');
      {Writeln('Ошибка! Документ продажи '+vvv.EditPosition+' от '+vvv.D+' не найден');}
      End;
    Dispose(Mr,Done);
  End;

  SDateR:=E^.Dat.BasisDate;
  Razvorot(SDateR);
  SDateR:=ClearChar(SDateR);
  E^.Dat.BasisDoc:=IntToStr(StrToInt(E^.Dat.BasisDoc),CDocNumer);
  RFormatZerro(E^.Dat.BasisDoc,CDocNumer-1);

     CalcNDSSpecial1SR(Kod,E,NDS20,NDS18,NDS10,NDS_,Litr20,Litr18,Litr10,Litr_,
	                   ZakupkaOutNDS20,ZakupkaOutNDS18,ZakupkaOutNDS10,ZakupkaOutNDS_,
				    NDSZ20,NDSZ18,NDSZ10,NDSZ_,Opl20,Opl18,Opl10,Opl_,Akzis);

     If (Abs(NDS20)>0.009) Or (Abs(NDS18)>0.009) Or (Abs(NDS10)>0.009) Or (Abs(NDS_)>0.009) Or
	   (Abs(Litr20)>0.009) Or (Abs(Litr18)>0.009) Or (Abs(Litr10)>0.009) Or (Abs(Litr_)>0.009) Or
	   (Abs(ZakupkaOutNDS20)>0.009) Or (Abs(ZakupkaOutNDS10)>0.009) Or (Abs(ZakupkaOutNDS18)>0.009)
 	    Or (Abs(ZakupkaOutNDS_)>0.009) Or
	   (Abs(NDSZ20)>0.009) Or (Abs(NDSZ18)>0.009) Or (Abs(NDSZ10)>0.009) Or
	   (Abs(NDSZ_)>0.009) Or
	   (Abs(Opl20)>0.009) Or (Abs(Opl18)>0.009) Or (Abs(Opl10)>0.009) Or (Abs(Opl_)>0.009) Or
	   (Abs(Akzis)>0.009) Then

     With Base Do
      Begin
       Append; {добавить новую запись}
       WriteNum('OBJECT',StrToInt(E^.Dat.SkladKod));{Код объекта откуда происходит реализация}
       WriteNum('TYPEOPER',2);
       WriteStr('CLIENTKOD',SClientKod);
       WriteStr('DOCUMENT',SDATE+SKOD+E^.Dat.Document);
       WriteNum('DOGOVOR',0);
       If E^.Dat.DocSelector in [3,4,6,8] Then  WriteNum('SF',1){оптовые возвраты}
       Else  WriteNum('SF',0){розничные возвраты};
       WriteStr('DATE',E^.Dat.DateC);
       WriteNum('KOL20',(-1)*Litr20);{всего литров с НДС20}

       If FindParam('ZAKUPKAKOL') Then
              WriteNum('KOL20',(-1)*ZakupkaOutNDS20);{сумма по ЗЦ без НДС20}

       WriteNum('SOPL20',(-1)*Opl20);{к оплате с НДС20}
       WriteNum('NDSOPL20',(-1)*NDS20);{НДС20 в сумме к оплате}
       WriteNum('SZOUT20',(-1)*ZakupkaOutNDS20);{сумма по ЗЦ без НДС20}
       WriteNum('SNDSZ20',(-1)*NDSZ20);{сумма НДС20 от З/Ц}
       WriteNum('KOL18',(-1)*Litr18);{всего литров с НДС18}

       If FindParam('ZAKUPKAKOL') Then
              WriteNum('KOL18',(-1)*ZakupkaOutNDS18);{сумма по ЗЦ без НДС20}

       WriteNum('SOPL18',(-1)*Opl18);{к оплате с НДС18}
       WriteNum('NDSOPL18',(-1)*NDS18);{НДС18 в сумме к оплате}
       WriteNum('SZOUT18',(-1)*ZakupkaOutNDS18);{сумма по ЗЦ без НДС18}
       WriteNum('SNDSZ18',(-1)*NDSZ18);{сумма НДС18 от З/Ц}
       WriteNum('KOL10',(-1)*Litr10);{всего литров с НДС10}

       If FindParam('ZAKUPKAKOL') Then
              WriteNum('KOL10',(-1)*ZakupkaOutNDS10);{сумма по ЗЦ без НДС20}

       WriteNum('SOPL10',(-1)*Opl10);{к оплате с НДС10}
       WriteNum('NDSOPL10',(-1)*NDS10);{НДС10 в сумме к оплате}
       WriteNum('SZOUT10',(-1)*ZakupkaOutNDS10);{сумма по ЗЦ без НДС10}
       WriteNum('SNDSZ10',(-1)*NDSZ10);{сумма НДС10 от З/Ц}
       WriteNum('KOL_',(-1)*Litr_);{всего литров с НДС прочее}

       If FindParam('ZAKUPKAKOL') Then
              WriteNum('KOL_',(-1)*ZakupkaOutNDS_);{сумма по ЗЦ без НДС20}

       WriteNum('SOPL_',(-1)*OPL_);{к оплате с НДС прочее}
       WriteNum('NDSOPL_',(-1)*NDS_);{НДС прочее в сумме к оплате}
       WriteNum('SZOUT_',(-1)*ZakupkaOutNDS_);{сумма по ЗЦ без НДС прочее}
       WriteNum('SNDSZ_',(-1)*NDSZ_);{сумма НДС прочее от З/Ц}
       WriteNum('AKZIS',(-1)*AKZIS);{акцизный сбор}
       WriteStr('DOCOSN',SDateR+SKOD+E^.DAt.BAsisDoc);{документ основания}
       WriteStr('DATEOSN',E^.Dat.BasisDate);{дата документа основания}
      End;
    End;
  End;

 Dispose(E,Done);

c:=IOResult;
 Close(f);  {закрытие vzw}
c:=IOResult;

c:=IOResult;
 Base.Close;{закрытие DBF}
c:=IOResult;

  AddLog(LogFile,'Импорт вовратов '+FDate+' для объекта '+IntToStr(Kod,CMantissa)+' успешно завершен');
End;


Procedure ImportVeksel(Kod:Word);
Var c,count : Word;
    E : VekselType;
    f : File;
    P : PBufDocBazType;
    SClientKod,
     SKod,
     SDate: AllStr;
    NDS20,
    NDS18,
    NDS10,
    NDS_,
    Litr20,
    Litr18,
    Litr10,
    Litr_,
    ZakupkaOutNDS20,
    ZakupkaOutNDS18,
    ZakupkaOutNDS10,
    ZakupkaOutNDS_,
    NDSZ20,
    NDSZ18,
    NDSZ10,
    NDSZ_,
    Opl20,
    Opl18,
    Opl10,
    Opl_,
    Akzis:Real;
    Pos : LongInt;
Begin

If Not fExists(III.Task[Kod].PathToSklad+'veksel.db') Then
 Begin
   {
   Writeln('Нет данных для экспорта '+III.Task[Kod].PathToSklad+'veksel.db'+
	 +' у объекта '+IntToStr(Kod,CMantissa));
   }
   AddLog(LogFile,'Нет данных для экспорта '+III.Task[Kod].PathToSklad+'veksel.db'+
	 +' у объекта '+IntToStr(Kod,CMantissa));
   Exit;
 End;


If Not fExists(III.PathToExport+'v'+EDate+'.dbf') Then
Begin
with Base do
begin
 Assign(III.PathToExport+'v'+EDate+'.dbf'); {пpисвоить БД имя}
 Init; {подготовиться к созданию БД}
 AddField('OBJECT','N',5,0);{Код объекта откуда происходит реализация}
 AddField('CLIENTKOD','C',8,0);{код клиента}
 AddField('DOCUMENT','C',9,0);{номер векселя}
 AddField('DATE','C',8,0);{дата векселя}
 AddField('SUMMA','N',15,4);{сумма векселя}
 AddField('COMMENT','C',50,0);{N  и дата документа основания}

      if Create then
         Open(ReadWrite)
      else
     begin
      {
      Writeln('Ошибка создания '+III.PathToExport+'v'+EDate+
	 '.dbf'+' у объекта '+IntToStr(Kod,CMantissa));
      }
      AddLog(LogFile,'Ошибка создания '+III.PathToExport+'v'+EDate+
	 '.dbf'+' у объекта '+IntToStr(Kod,CMantissa));
      exit;
     end;

  AddLog(LogFile,'Создание базы данных '+III.PathToExport+'v'+EDate+'.dbf'+' успешно завершено');

c:=IOResult;
     Close;
c:=IOResult;
End;{With Base}
End;



 Assign(f,III.Task[Kod].PathToSklad+'veksel.db');
 c:=IOResult;
 Reset(f,SizeOf(DocBazType));
 c:=IOResult;
 If c<>0 Then
  Begin
   {
   Writeln('Ошибка открытия '+III.Task[Kod].PathToSklad+'veksel.db'+
	 +' у объекта '+IntToStr(Kod,CMantissa)+' Код:'+IntToStr(c,CMantissa));
   }
   AddLog(LogFile,'Нет данных для экспорта '+III.Task[Kod].PathToSklad+'veksel.db'+
	 +' у объекта '+IntToStr(Kod,CMantissa)+' Код:'+IntToStr(c,CMantissa));
   Exit;
  End;

 Base.Assign(III.PathToExport+'v'+EDate+'.dbf');
 c:=IOResult;
 Base.Open(ReadWrite);
 c:=IOResult;
 If c<>0 Then
  Begin
   Close(f);
   c:=IOResult;
   {
   Writeln('Ошибка открытия '+III.PathToExport+'v'+EDate+'.dbf'+
	 +' у объекта '+IntToStr(Kod,CMantissa)+' Код:'+IntToStr(c,CMantissa));
   }
   AddLog(LogFile,III.PathToExport+'v'+EDate+'.dbf'+
	 +' у объекта '+IntToStr(Kod,CMantissa)+' Код:'+IntToStr(c,CMantissa));
   Exit;
  End;


While Not(Eof(F)) Do
 Begin

 Count:=0;
 New(P,Init);

 Pos:=FilePos(f);

 Repeat
  Pause(1);
 Until NetCAll.Lock(f,Pos*SizeOf(DocBazType),SizeOf(BufDocBazType));

  BlockRead(F,P^.Point,BufferVKS,Count);

 Repeat
  NetCall.Unlock(f,Pos*SizeOf(DocBazType),SizeOf(BufDocBazType));
 Until (DosError=0);

For c:=1 To Count Do
Begin

 If (P^.Point.Dat[c].Status) Then
  Begin

   If (P^.Point.Dat[c].DateC=FDate) Then
   Begin
     SClientKod:='0'+GetBuchKod(Kod,0,P^.Point.Dat[c].ClientKod);
     SKod:=IntToStr(KOD,CMantissa);
     RFormatZerro(SKod,CMAntissa);
     RFormatZerro(SClientKod,8);
     RFormatZerro(P^.Point.Dat[c].Dogovornumer,CArtikul);
     With Base Do
      Begin
       Append; {добавить новую запись}
       WriteNum('OBJECT',KOD);{Код объекта откуда происходит реализация}
       WriteStr('CLIENTKOD',SClientKod);
       WriteStr('DOCUMENT',SKOD+P^.Point.Dat[c].Dogovornumer);
       WriteStr('DATE',P^.Point.Dat[c].DateC);{дата векселя}
       WriteNum('SUMMA',StrToReal(P^.Point.Dat[c].Summa));{сумма векселя}
       WriteStr('COMMENT',P^.Point.Dat[c].Dogovornumer+'/'+SKod+' по '+P^.Point.Dat[c].Document+' от '+
	  P^.Point.Dat[c].DateC);{N  и дата документа основания}
      End;

   End

  End;{P^.Point.Dat[c].Status}
End;{For}
Dispose(P,Done);
End;{While}

c:=IOResult;
 Close(f);  {закрытие vzw}
c:=IOResult;

c:=IOResult;
 Base.Close;{закрытие DBF}
c:=IOResult;

  AddLog(LogFile,'Импорт векселей '+FDate+' для объекта '+IntToStr(Kod,CMantissa)+' успешно завершен');
End;


Function  TestSFOpl(Kod:Word;Cl:ArtikulStr;Num:ArtikulStr;Date:TDateString):Boolean;
Var Fr : File;
    Er : PBufRealizasiaType;
  Find : Boolean;
     BakFileMode,c : Word;
     c1 , Count : Word;
Begin
TestSfOpl:=False;
DelSpace(cl);
DelSpace(Num);
DelSpace(Date);

Assign(fr,III.Task[Kod].PathToDolg+cl+'.dlg');
c:=IOResult;
Reset(fr,SizeOf(RealizasiaType));

c:=IOResult;
If c<>0 Then
 Begin
  {
  Writeln('Ошибка открытия '+III.Task[Kod].PathToDolg+cl+'.dlg!'+
	 +' у объекта '+IntToStr(Kod,CMantissa)+' Код:'+IntToStr(c,CMantissa));
  }
  AddLog(LogFile,'Ошибка открытия '+III.Task[Kod].PathToDolg+cl+'.dlg!'+
	 +' у объекта '+IntToStr(Kod,CMantissa)+' Код:'+IntToStr(c,CMantissa));
  Exit;
 End;

 Find:=False;
 While Not(Eof(fr)) And Not(Find) Do
  Begin
   cOunt:=0;
   New(Er,Init);
   BlockRead(fr,Er^.Point,BufferDLG,Count);
For c1:=1 To Count Do
Begin
   If(Er^.Point.Dat[c1].Market.Active) Then
   Begin
   DelSpace(Er^.Point.Dat[c1].Market.Document);
   If (Num=Er^.Point.Dat[c1].Market.Document)And
      (DateToDateString(DateMask,Er^.Point.Dat[c1].Market.DateC)=Date) Then
          Begin
           Find:=True;
           TestSFOpl:=(Er^.Point.Dat[c1].Market.DocSelector in [6,8]){Er^.Point.Dat[c1].Sf};
           Break;
          End;
   End;
End;{For}
   Dispose(Er,Done);
   If Find Then Break;
  End;{While}
Close(fr);
End;


Procedure ImportKassa(Kod:Word);
LABEL OPLATA,RETURN,ROZN;
Var c,count : Word;

    Mr,E : PSuperMarketType;
    f : MarketFileType;

    Opl : OplataRealizasiaType;
    fOpl : OplataRealizasiaFileType;

    Ret : PNewVozwratType;
    fRet : NewVozwratFileType;

    SClientKod,
     SKod,
     SDate: AllStr;
    NDS20,
    NDS18,
    NDS10,
    NDS_,
    Litr20,
    Litr18,
    Litr10,
    Litr_,
    ZakupkaOutNDS20,
    ZakupkaOutNDS18,
    ZakupkaOutNDS10,
    ZakupkaOutNDS_,
    NDS,
    NDSZ20,
    NDSZ18,
    NDSZ10,
    NDSZ_,
    Opl20,
    Opl18,
    Opl10,
    Opl_,
    Akzis:Real;
    ReportKassa : Real;
    Pos : LongInt;
    SNum : AllStr;
    Typ : Word;
    VVV : DocumentEditZ;
Begin

If Not fExists(III.PathToExport+'k'+EDate+'.dbf') Then
Begin
with Base do
begin
 Assign(III.PathToExport+'k'+EDate+'.dbf'); {пpисвоить БД имя}
 Init; {подготовиться к созданию БД}

 AddField('OBJECT','N',5,0);{Код объекта откуда происходит реализация}
 AddField('TYPEOPER','N',1,0);
 {0 - оптовые продажи
  1 - опл консигнации
  2 - расходы по возврату оптовые
  3 - расходы по возврату розниные
  4 - розничные продажи по ККМ-счетчик ккм с учетом сертификатов
  }
 AddField('CLIENTKOD','C',8,0);{код клиента}
 AddField('DATE','C',8,0);{дата операции }
 AddField('SOPL','N',15,2);{к оплате}
 AddField('SNDS','N',15,2);{НДС20 в сумме к оплате}
 AddField('DOCOSN','C',9,0);{документ основания}
 AddField('DATEOSN','C',8,0);{дата документа основания}

      if Create then
         Open(ReadWrite)
      else
     begin
      {
      Writeln('Ошибка создания '+III.PathToExport+'k'+EDate+
	 '.dbf'+' у объекта '+IntToStr(Kod,CMantissa));
      }
      AddLog(LogFile,'Ошибка создания '+III.PathToExport+'k'+EDate+
	 '.dbf'+' у объекта '+IntToStr(Kod,CMantissa));
      exit;
     end;

  AddLog(LogFile,'Создание базы данных '+III.PathToExport+'k'+EDate+'.dbf'+' успешно завершено');

c:=IOResult;
     Close;
c:=IOResult;
End;{With Base}
End;

 Base.Assign(III.PathToExport+'k'+EDate+'.dbf');
 c:=IOResult;
 Base.Open(ReadWrite);
 c:=IOResult;
 If c<>0 Then
  Begin
   {
   Writeln('Ошибка открытия '+III.PathToExport+'k'+EDate+'.dbf'+
	 +' у объекта '+IntToStr(Kod,CMantissa)+' Код:'+IntToStr(c,CMantissa));
   }
   AddLog(LogFile,III.PathToExport+'k'+EDate+'.dbf'+
	 +' у объекта '+IntToStr(Kod,CMantissa)+' Код:'+IntToStr(c,CMantissa));
   Exit;
  End;



 ReportKassa:=0;{сумма розничных продаж}

 Assign(f,III.Task[Kod].PathToMarket+FDate+'.mrk');
 c:=IOResult;
 Reset(f);
 c:=IOResult;
 If c<>0 Then
  Begin
   {
   Writeln('Ошибка открытия '+III.Task[Kod].PathToMarket+FDAte+'.mrk'+
	 +' у объекта '+IntToStr(Kod,CMantissa)+' Код:'+IntToStr(c,CMantissa));
   }
   AddLog(LogFile,'Нет данных для экспорта '+III.Task[Kod].PathToMarket+FDate+'.mrk'+
	 +' у объекта '+IntToStr(Kod,CMantissa)+' Код:'+IntToStr(c,CMantissa));
   Goto OPLATA;
  End;

{старт обработки документов из *.mrk
паралельно обрабатываются документы со СФ без отсрочки платежа и
просчитывается сумма розничных продаж}
New(e,Init);
While Not(Eof(F)) Do
 Begin
  ReadMarket(F,E);
  If E^.Dat.Active Then
  If E^.Dat.OperatorSelector=0{только операции с клиентом} Then
  Begin
   If Not (E^.Dat.Realiz) And (E^.DAt.DocSelector in [3{СФ нал}]) Then
    Begin
     {запись в баззу}
     SClientKod:='0'+GetBuchKod(Kod,E^.Dat.OperatorSelector,E^.Dat.ClientKod);
     SKod:=IntToStr(KOD,CMantissa);

     E^.Dat.Document:=IntToStr(StrToInt(E^.Dat.Document),CDocNumer);
     RFormatZerro(E^.Dat.Document,CDocNumer-1);


     NDS20:=0;
     NDS18:=0;
     NDS10:=0;
     NDS_:=0;
     CalcOnlyNDS(E,NDS20,NDS18,NDS10,NDS_);

     SDate:=E^.Dat.DateC;
     Razvorot(SDate);
     SDate:=ClearChar(SDate);

     RFormatZerro(SKod,CMAntissa);
     RFormatZerro(SClientKod,8);

     If (Abs(StrToReal(E^.Dat.SummaZ))>0.009) Or
        (Abs(NDs20+NDs18+Nds10+Nds_)>0.009) Then
     With Base Do
      Begin
       Append; {добавить новую запись}
       WriteNum('OBJECT',KOD);{Код объекта откуда происходит реализация}
       WriteNum('TYPEOPER',0);
       WriteStr('CLIENTKOD',SClientKod);
       WriteStr('DATE',E^.Dat.DateC);
       WriteNum('SOPL',StrToReal(E^.Dat.SummaZ));{к оплате}
       WriteNum('SNDS',NDS20+NDS18+NDS10+NDS_);{НДС от оплаты}
       WriteStr('DOCOSN',SDATE+SKOD+E^.Dat.Document);{документ основание}
       WriteStr('DATEOSN',E^.Dat.DateC);{дата документа основания}
      End;
    End;

   If ((E^.Dat.DocSelector in [0,1]) And Not(E^.Dat.Realiz) And (E^.Dat.Rashet=0)) Then
    ReportKassa:=StrToReal(E^.Dat.SummaZ)+ReportKassa;
   If (Not(E^.Dat.Realiz) And (E^.Dat.DocSelector in [0,1,2,3,4]))Or (E^.Dat.DocSelector in [5,6,7,8]) Then
    ReportKassa:=StrToReal(E^.Dat.SertifSummaZ)+ReportKassa;
  End;{Active OperatorSelector=0}
 End;{While}

Dispose(E,Done);
c:=IOResult;
 Close(f);
c:=IOResult;
{завершена обработка документов из *.mrk}
  AddLog(LogFile,'Импорт продаж за '+FDate+' для объекта '+IntToStr(Kod,CMantissa)+' успешно завершен');


{начинаем обрабатывать файл оплаты консигнации}
OPLATA:
 Assign(fOpl,III.Task[Kod].PathToOplata+FDate+'.opl');
 c:=IOResult;
 Reset(fOpl);
 c:=IOResult;
 If c<>0 Then
  Begin
   {
   Writeln('Ошибка открытия '+III.Task[Kod].PathToOplata+FDAte+'.opl'+
	 +' у объекта '+IntToStr(Kod,CMantissa)+' Код:'+IntToStr(c,CMantissa));
   }
   AddLog(LogFile,'Нет данных для экспорта '+III.Task[Kod].PathToOplata+FDate+'.opl'+
	 +' у объекта '+IntToStr(Kod,CMantissa)+' Код:'+IntToStr(c,CMantissa));
   Goto RETURN;
  End;

While Not(Eof(FOpl)) Do
 Begin
  ReadOplata(FOpl,Opl);
  If Not(Opl.Vozwrat) Then
  If (Opl.Rashet=0) Then
   Begin
    New(E,Init);
    VVV.D:=Opl.DateDoc;
    VVV.EditPosition:=Opl.Document;
 If GetMarket1(Kod,VVV,E) Then
 begin
    If Not (E^.Dat.DocSelector in [6,8]) Then
     Begin
      ReportKassa:=StrToReal(Opl.SummaZ)+ReportKassa;
     End
     Else Begin
          {запись в *.dbf}

     SClientKod:='0'+GetBuchKod(Kod,E^.DAt.OperatorSelector,E^.Dat.ClientKod);
     SKod:=IntToStr(KOD,CMantissa);

     E^.Dat.Document:=IntToStr(StrToInt(E^.Dat.Document),CDocNumer);
     RFormatZerro(E^.Dat.Document,CDocNumer-1);


     NDS20:=0;
     NDS18:=0;
     NDS10:=0;
     NDS_:=0;
     CalcOnlyNDS(E,NDS20,NDS18,NDS10,NDS_);

     SDate:=E^.Dat.DateC;
     Razvorot(SDate);
     SDate:=ClearChar(SDate);

     RFormatZerro(SKod,CMAntissa);
     RFormatZerro(SClientKod,8);

     NDS:=NDS20+NDS18+NDS10+NDS_;

     If StrToReal(E^.DAt.SummaZ)>0 Then
      Begin
       NDS:=NDS*StrToReal(Opl.SummaZ)/StrToReal(E^.DAt.SummaZ);
      End
      Else
       NDS:=0;

     If (Abs(StrToReal(Opl.SummaZ))>0.009) Or
        (Abs(NDs)>0.009) Then
     With Base Do
      Begin
       Append; {добавить новую запись}
       WriteNum('OBJECT',KOD);{Код объекта откуда происходит реализация}
       WriteNum('TYPEOPER',1);
       WriteStr('CLIENTKOD',SClientKod);
       WriteStr('DATE',Opl.DateC);
       WriteNum('SOPL',StrToReal(Opl.SummaZ));{к оплате}
       WriteNum('SNDS',NDS);{НДС от оплаты}
       WriteStr('DOCOSN',SDATE+SKOD+E^.Dat.Document);{документ основание}
       WriteStr('DATEOSN',E^.Dat.DateC);{дата документа основания}
      End;


          End;
 End
  Else
    begin
      AddLog(LogFile,'Ошибка! Документ продажи '+vvv.EditPosition+' от '+vvv.D+' не найден');
      {Writeln('Ошибка! Документ продажи '+vvv.EditPosition+' от '+vvv.D+' не найден');}
      AddLog(LogFile,'Ошибка! Оплата на сумму '+Opl.SummaZ+' не обработана Объект:'+IntToStr(Kod,CKol));
      {Writeln(LogFile,'Ошибка! Оплата на сумму '+Opl.SummaZ+' не обработана Объект:'+IntToStr(Kod,CKol));}
    End;
    Dispose(E,Done);


   End;{Not Opl.Vozwrat (Opl.Rashet=0)}
 End;{Not Eof(FOpl)}


c:=IOResult;
 Close(fOpl);
c:=IOResult;

  AddLog(LogFile,'Импорт оплат оплат за '+FDate+' для объекта '+IntToStr(Kod,CMantissa)+' успешно завершен');

{завершена обработка файла оплаты консигнации}
Return:
{старт обработки возвратов}
 Assign(fRet,III.Task[Kod].PathToReturn+FDate+'.vzw');
 c:=IOResult;
 Reset(fRet);
 c:=IOResult;
 If c<>0 Then
  Begin
   {
   Writeln('Ошибка открытия '+III.Task[Kod].PathToReturn+FDAte+'.vzw'+
	 +' у объекта '+IntToStr(Kod,CMantissa)+' Код:'+IntToStr(c,CMantissa));
   }
   AddLog(LogFile,'Нет данных для экспорта '+III.Task[Kod].PathToReturn+FDate+'.vzw'+
	 +' у объекта '+IntToStr(Kod,CMantissa)+' Код:'+IntToStr(c,CMantissa));
   Goto ROZN;
  End;


New(Ret,Init);
While Not(Eof(FRet)) Do
 Begin
  ReadNewVozwrat(FRet,Ret);
  If Ret^.Dat.Rashod Then
   Begin
    If StRToReal(Ret^.Dat.RashodSumma)>0.009 Then
    Begin

     If Ret^.Dat.DocSelector in [3,4,6,8] Then
      Begin

     Typ:=2;
     SClientKod:='0'+GetBuchKod(Kod,0,Ret^.Dat.MakeKod);
     SKod:=IntToStr(KOD,CMantissa);

     Ret^.Dat.Document:=IntToStr(StrToInt(Ret^.Dat.Document),CDocNumer);
     RFormatZerro(Ret^.Dat.Document,CDocNumer-1);


     NDS20:=0;
     NDS18:=0;
     NDS10:=0;
     NDS_:=0;
{
     CalcNDSSpecial1SR(Kod,Ret,NDS20,NDS10,NDS_,Litr20,Litr10,Litr_,
	                   ZakupkaOutNDS20,ZakupkaOutNDS10,ZakupkaOutNDS_,
				    NDSZ20,NDSZ10,NDSZ_,Opl20,Opl10,Opl_,Akzis);
}
     SDate:=Ret^.Dat.DateC;
     Razvorot(SDate);
     SDate:=ClearChar(SDate);

     RFormatZerro(SKod,CMAntissa);
     RFormatZerro(SClientKod,8);

     NDS:=NDS20+NDS18+NDS10+NDS_;

      End
     Else
       Begin
     Typ:=3;
     SClientKod:=IntToStr(Kod,CMantissa);
     RFormatZerro(SClientKod,CClientKod);
     SClientKod:=III.RoznizaClientPrefix+SClientKod;
     RFormatZerro(SClientKod,8);

     SKod:=IntToStr(Kod,CMantissa);
     RFormatZerro(SKod,CMantissa);
     SNum:=IntToStr((DateStringToDate(DAteMask,FDate)+1)-
     DateStringToDAte(DAteMask,'01-01-'+Copy(FDate,7,2)),CLitrMantissa);
     RFormatZerro(SNum,CLitrMantissa);

     SDate:=FDAte;
     Razvorot(SDate);
     SDate:=ClearChar(SDate);

       End;


     With Base Do
      Begin
       Append; {добавить новую запись}
       WriteNum('OBJECT',KOD);{Код объекта откуда происходит реализация}
       WriteNum('TYPEOPER',Typ);
       WriteStr('CLIENTKOD',SClientKod);
       WriteStr('DATE',Ret^.Dat.DateC);
       WriteNum('SOPL',-StrToReal(Ret^.Dat.RashodSumma));{к оплате}
       WriteNum('SNDS',{NDS}0);{НДС от оплаты}
       WriteStr('DOCOSN',SDATE+SKOD+Ret^.Dat.Document);{документ основание}
       WriteStr('DATEOSN',Ret^.Dat.DateC);{дата документа основания}
      End;




    End;{StRToReal(Ret^.Dat.ReshodSumma)>0}
   End;{Rashod}
 End;{Not Eof(FOpl)}

Dispose(Ret,Done);
c:=IOResult;
 Close(fRet);
c:=IOResult;

  AddLog(LogFile,'Импорт возвратов за '+FDate+' для объекта '+IntToStr(Kod,CMantissa)+' успешно завершен');




{завершение обработки возвратов}
ROZN:
{запись результатов розничных продаж и оплат консигнации по ТЧ}
     SClientKod:=IntToStr(Kod,CMantissa);
     RFormatZerro(SClientKod,CClientKod);
     SClientKod:=III.RoznizaClientPrefix+SClientKod;
     RFormatZerro(SClientKod,8);

     SKod:=IntToStr(Kod,CMantissa);
     RFormatZerro(SKod,CMantissa);
     SNum:=IntToStr((DateStringToDate(DAteMask,FDate)+1)-
     DateStringToDAte(DAteMask,'01-01-'+Copy(FDate,7,2)),CLitrMantissa);
     RFormatZerro(SNum,CLitrMantissa);

     SDate:=FDAte;
     Razvorot(SDate);
     SDate:=ClearChar(SDate);

     If Abs(ReportKassa)>0.009 Then
     With Base Do
      Begin
       Append; {добавить новую запись}
       WriteNum('OBJECT',KOD);{Код объекта откуда происходит реализация}
       WriteNum('TYPEOPER',4);{розничная реализация}
       WriteStr('CLIENTKOD',SClientKod);
       WriteStr('DATE',FDate);
       WriteNum('SOPL',ReportKassa);{к оплате}
     (*WriteNum('SNDS',0);{к оплате}*)
       WriteStr('DOCOSN',SDATE+SKOD+SNUM);{документ основание}
       WriteStr('DATEOSN',FDate);{дата документа основания}
      End;
{запись счетчика ККМ завершена}


c:=IOResult;
 Base.Close;{закрытие DBF}
c:=IOResult;

  AddLog(LogFile,'Импорт розничных оплат за '+FDate+' для объекта '+IntToStr(Kod,CMantissa)+' успешно завершен');
End;









(*************    О С Н О В Н А Я    П Р О Г Р А М М А        ***********)

Function TestOpenDate1(Kod:Word;S:TDateString):Boolean;
Var f : File Of SkladDocNumer;
    Pos,Date : LongInt;
    c : Byte;
    P : PSkladDocNumer;
    j : LongInt;
    Ext : ArtikulStr;
Begin
 TestOpenDAte1:=False;
 Date:=DateStringToDate(DateMask,s);
 Pos:=Date-DateStringToDAte(DateMask,'01-01-98');
 Assign(f,III.Task[Kod].PathToSklad+'date.db');
 c:=IOResult;
 Reset(f);
 c:=IOResult;

 If c<>0 Then
  Begin
   Exit;
  End;

 {If (FileSize(f)<Pos) Then}
 If (FileSize(f)<Pos) Or (Pos<0) Then
  Begin
   c:=IOResult;
   Close(f);
   c:=IOResult;
   Exit;
  End;

 New(P,Init);
 Seek(f,Pos);
 Repeat
  Pause(1);
 Until Lock(f,Pos*SizeOf(SkladDocNumer),SizeOf(SkladDocNumer)); {предварительная блокировка}

 Read(f,P^.Dat);

 If (P^.Dat.Day.Flag) Then TestOpenDAte1:=True;

 Repeat
  Unlock(f,Pos*SizeOf(SkladDocNumer),SizeOf(SkladDocNumer));
 Until (DosError=0);


 Dispose(P,Done);

 c:=IOResult;
 Close(f);

End;






Procedure RunTest;
Var j : Word;
    ss,s : AllStr;
Begin
{определяем текущую дату из FDAte}
{определяем текущую дату из файла}
{если FDAte < чем дата в файле тогда в транду все работу и выход с сообщением}
{тест начинаем со следующей: пример если в файле 20-09-03 то начинаем тестировать с 21-09-03 по текущую дату}

{скнаируем наличие всех касс
 если касс нет тогда пишем в лог и переходим к слудующей дате}
{если кассы есть то взводим флаг равный дате и записываем текущую дату как обработанную}
{ввобще все это чушь т.к. в воскресенье касс с половины складов может не быть}

For j:=1 To CMAxSklads Do
 Begin
  If ReplicationObject[j]=1 Then
  Begin
   s:=IntToStr(j,2);
   RFormatZerro(s,2);
   Format(III.Task[j].ObjectName,CAll);

   If TestOpenDate1(j,FDate) Then ss:='Внимание! Доступ к данным открыт!'
   Else ss:='';

   If Not fExists(III.Task[j].PathToKassa+FDate+'.k'+s) Then
    Begin
    {Writeln(III.Task[j].ObjectName,' - Внимание! Нет отчетных данных');}
     AddLog(LogFile,III.Task[j].ObjectName+' - Внимание! Нет отчетных данных '+ss);
    End
   Else
    Begin
     {Writeln(III.Task[j].ObjectName,' - ОК');}
     AddLog(LogFile,III.Task[j].ObjectName+' - ОК '+ss);
    End;
  End;
 End;

End;



Var CountParam : Integer;
    ss : AllStr;
Begin

 Writeln('Экспорт в 1С бухгалтерию   Версия 2.0.1 от 12/01/2007');
 If FindParam('/?') Then
  Begin
   ShowHelp;
  End;

 ClearIni;

 Filemode:=66;

 j:=1;
 For j:=1 To CMaxSklads Do
  Begin
   If FindParam('/'+KurzSklad[j]{WordToMyHex(j)}) Then ReplicationObject[j]:=1
   Else
   ReplicationObject[j]:=0;
  End;

 {цикл настройки на обрабатываемые задачи}
 For j:=1 To CMaxTasks Do
  Begin
   IndexTasks[j]:=0;
  End;

 If FindParam(StartOPT) Then IndexTasks[1]:=1;{опт}
 If FindParam(StartROZN)   Then IndexTasks[2]:=1;{розница}
 If FindParam(StartINTERNAL) Then IndexTasks[3]:=1;{межсклад}
 If FindParam(StartReturn)   Then IndexTasks[4]:=1;{возвраты}
 If FindParam(StartVeksel)   Then IndexTasks[5]:=1;{векселя}
 If FindParam(StartClient)   Then IndexTasks[6]:=1;{клиентские справочники}
 If FindParam(StartMake)   Then IndexTasks[11]:=1;{клиентские справочники}
 If FindParam(StartBarter)   Then IndexTasks[12]:=1;{клиентские справочники}
 If FindParam(StartPrihod)   Then IndexTasks[13]:=1;{клиентские справочники}
 If FindParam(StartKassa)   Then IndexTasks[7]:=1;{клиентские справочники}





 {цикл настройки на обрабатываемые задачи}
 Starting := False;
 For j:=1 To CMaxTasks Do
  Begin
   If IndexTasks[j]>0 Then Starting:=True;
  End;

 If FindParam(StartClient) Then Starting:=True;





 If Not Starting Then
  Begin
   Writeln('Не обнаружено никаких задач!');
   Halt;
  End;






 If Not(FindParam('OUTDATE')) Then
  Begin
   CountParam:=0;
   If FindParamCount('DECDATE=',CountParam) Then
    Begin
     ss:=ParamStr(CountParam);
     CountParam:=StrToInt(Copy(ss,9,Ord(ss[0])-8));
     FDate:=DateToDateString(DateMask,DateStringToDate(DateMask,FDate)+CountParam);
    End;
  End;


 EDate:=FDate;

 RazVrt8(EDate);

 EDate:=To1sU.ClearChar(EDate);


 Assign(LogFile,'i'+EDate+'.log');
 j:=IoResult;
 Append(LogFile);
 j:=IoResult;
 If j<>0 Then
  Begin
   {SpecialBeep;}
   Writeln('Ошибка открытия лог-файла');
   Rewrite(LogFile);
   j:=IoResult;
   If j<>0 Then
    Begin
     {SpecialBeep;}
     Writeln('Ошибка создания лог-файла');
    End;
  End;

 Assign(Ini,'to1s.ini');
 j:=IoResult;
 Reset(Ini);
 j:=IoResult;
 If j<>0 Then
  Begin
   {Writeln('Ошибка открытия ini-файла');}
   AddLog(LogFile,'Ошибка открытия ini-файла');
   AddLog(LogFile,'Аварийное завершение');
   j:=IoResult;
   Close(LogFile);
   j:=IoResult;
   Exit;
  End;
 j:=IoResult;
 Close(ini);
 j:=IoResult;
 Res:=0;
 ReadNewIni(INI,Res);
 j:=IoResult;
 Close(ini);
 j:=IoResult;
 If Res=1 Then
  Begin
   {Writeln('Ошибка чтения ini-файла');}
   j:=IoResult;
   AddLog(LogFile,'Ошибка чтения ini-файла');
   AddLog(LogFile,'Аварийное завершение');
   j:=IoResult;
   Close(LogFile);
   j:=IoResult;
   Exit;
  End;

 AddLog(LogFile,'Старт автоматического обработчика данных за '+FDAte+' '+
 DayString[DayOfWeek(DateStringToDate(DateMask,FDate))]);


 If FindParam(StartTest) Then
  Begin
   RunTest;
  End;

For j:=1 To CMAxSklads Do
 Begin
  If ReplicationObject[j]=1 Then
  Begin
  If IndexTasks[1]=1 Then ImportOPT(j);
  If IndexTasks[2]=1 Then ImportROZN(j);
  If IndexTasks[13]=1 Then ImportPrihod(j);
  If IndexTasks[3]=1 Then
     Begin
	 ImportINTERNAL(j);
      ImportPrihodAsINTERNAL(j);
	End;
  If IndexTasks[4]=1 Then ImportReturn(j);
  If IndexTasks[5]=1 Then ImportVeksel(j);
  If IndexTasks[7]=1 Then ImportKassa(j);
  End;
 End;

 If FindParam(StartClient) Then ImportClient(1{опорный справочник-сойфера});
 If FindParam(StartMake) Then ImportMake(1{опорный справочник-сойфера});
 If FindParam(StartBarter) Then ImportBarter(1{опорный справочник-сойфера});

 AddLog(LogFile,'Завершение автоматического импорта');
 {конец цикла основной работы}

 I:=IoResult;
 Close(LogFile);
 I:=IoResult;



End.