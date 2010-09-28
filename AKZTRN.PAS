Unit AkzTrn;

INTERFACE

Uses Glob, ServStr, Dbengin3,DBEngine;

procedure FormAkzTrn(As:DocumentEditZ);

procedure TestFormAkzTrn;


IMPLEMENTATION

Uses App,DBEngin2,MsgBox,Tools,Printers,Objects,Views,Propiss,TpDate,Access,
     Validate,NetDBEng,Vision4,Serv,Utils4,NAstr,Protect,Access1,
     ServStr2, Vision5,Vision6,Utils1,Utils5,Prise,ExpImp;


procedure FormAkzTrn(As:DocumentEditZ);
const Space = ' ';
var E:PSuperMarketType;
    t: text;
    IORez,i: word;
    SAkzis : string[CIZena];
    SAkzisAll : string[CIZena];
    sNum: String[CKod];
    sName,sName2: string[CName];
    sLitr: string[CIZena];
    SumLitr:string[CIZena];
    sMera: string[CZena];
    sEtil: string[CIZena];
    SumEtil: string[CIZena];
    SumKOl: string[CKol];

Begin
 New(E,Init);
 if GetMarket1(As,E) then
 begin
   Assign(t,Path^.Dat.ToTemp+'akztrn.txt');
   IORez:=ioresult;
   Rewrite(t);
   IORez:=ioresult;
   if IORez<>0 then
   begin
     MessageBox(#3^M+#3'¥ ¬®£ã á®§¤ âì ä ©« ®âç¥â  '+Path^.Dat.ToTemp+'akztrn.txt'+
     +' Š®¤:'+IntToStr(l,3),Nil,mfError+mfCancelButton);
     Dispose(E,Done);
     exit;
   end;

Writeln(T,header+Space+'‘ª« ¤:'+GetClientField(FClient,Rek^.Dat.Kod,1)+' ¯¥à â®à: '+GetOperatorField(FName,E.Dat.Caption));

Writeln(t,Space+'    €‘—…’ €Š–ˆ‡‚ € Š €Š‹€„‰ N ',e^.dAT.Document,' ®â ',e^.dAT.DateC);

WRITELN(t,Space+'ÚÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ'
+'ÂÄÄÄÄÄÄÄÄ¿');
WRITELN(t,Space+'³N ³ Š®¤ ³    ¨¬¥­®¢ ­¨¥           ³…¤.¨§¬.³ èâ. ³‹¨âà.   ³ á¯¨àâ  ³‘â ¢. ªæ'
+'³‘ã¬  ªæ.³');
WRITELN(t,Space+'ÀÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄ'
+'ÁÄÄÄÄÄÄÄÄÙ'+HeaderStop);

   SAkzisAll:='           0.00';
   SumKOl:='0';
   SumEtil:='0.00';
   SumLitr:='0.00';

   for i:=1 To E^.Dat.Amount do
   begin

      SAkzis:='    0.00';

      if (ShemaAkzis=0) and (E^.Dat.MarketElement[i].Input.RegionMarka=1) then
      begin
       MyStr(StrToReal(E^.Dat.MarketElement[i].Input.AkzisSbor)*StrToInt(E^.Dat.MarketElement[i].Input.Kol),
       CIZena,CMantissa,SAkzis);
       MyStr(StrToReal(SAkzis)+StrToReal(SAkzisAll),CIZena,CMantissa,SAkzisAll);
      end;

       If (ShemaAkzis=1) and (E^.Dat.MarketElement[i].Input.RegionMarka=1)Then
        Begin
         if StrToInt(GetIdField(FBuchGroup,E^.Dat.MarketElement[i].BazKod)) in [1,2,3,4,7] then
         begin

          if StrToInt(GetIdField(FBuchGroup,E^.Dat.MarketElement[i].BazKod)) in [1,2,3] then
            MyStr(
	     StrToReal(AkzisKoeff[StrToInt(GetIdField(FBuchGroup,E^.Dat.MarketElement[i].BazKod))])
	    *0.8
	    *StrToInt(E^.Dat.MarketElement[i].Input.Kol)
	    *StrToReal(GetIdField(FLitr,E^.Dat.MarketElement[i].BazKod))
	    *StrToReal(GetIdField(FEtil,E^.Dat.MarketElement[i].BazKod))
            /100,
             CIZena,CMantissa,SAkzis)
          Else
           MyStr(
	      StrToReal(AkzisKoeff[StrToInt(GetIdField(FBuchGroup,E^.Dat.MarketElement[i].BazKod))])
	     *0.65
	     *StrToInt(E^.Dat.MarketElement[i].Input.Kol)
	     *StrToReal(GetIdField(FLitr,E^.Dat.MarketElement[i].BazKod))
	     *StrToReal(GetIdField(FEtil,E^.Dat.MarketElement[i].BazKod))
             /100,
             CIZena,CMantissa,SAkzis);

           MyStr(StrToReal(SAkzis)+StrToReal(SAkzisAll),CIZena,CMantissa,SAkzisAll);

         end
        else
        begin
         if StrToInt(GetIdField(FBuchGroup,E^.Dat.MarketElement[i].BazKod)) in [1,2,3] then
         MyStr(
	    StrToReal(AkzisKoeff[StrToInt(GetIdField(FBuchGroup,E^.Dat.MarketElement[i].BazKod))])
	   *0.8
	   *StrToInt(E^.Dat.MarketElement[i].Input.Kol)
	   *StrToReal(GetIdField(FLitr,E^.Dat.MarketElement[i].BazKod))
        ,CIZena,CMantissa,SAkzis)
        Else
         MyStr(
	    StrToReal(AkzisKoeff[StrToInt(GetIdField(FBuchGroup,E^.Dat.MarketElement[i].BazKod))])
	   *0.65
	   *StrToInt(E^.Dat.MarketElement[i].Input.Kol)
	   *StrToReal(GetIdField(FLitr,E^.Dat.MarketElement[i].BazKod))
        ,CIZena,CMantissa,SAkzis);

         MyStr(StrToReal(SAkzis)+StrToReal(SAkzisAll),CIZena,CMantissa,SAkzisAll);
        end;
        End;

        sName2:=GetIdField(FName2,E^.Dat.MarketElement[i].BazKod);
        sName:=GetIdField(FFName,E^.Dat.MarketElement[i].BazKod);
        Format(sName,CName);
        DelSpace(sName2);
        if sName2[0]<>#0 then
         begin
           format(sName2,CName);
           writeln(t,Space+SeparatorChar+SeparatorChar+'        '+sName+SeparatorChar);
         end;
        {®¬¥à}
        sNum:=IntToStr(i,3);
        rFormat(sNum,CKod);
        write(t,Space,sNum,SeparatorChar);
        {Š®¤}
        write(t,E^.Dat.MarketElement[i].BazKod,SeparatorChar);
        { ¨¬¥­®¢ ­¨¥}
        if sName2[0]<>#0 then write(t,sName2+SeparatorChar)
        else write(t,sName+SeparatorChar);

        {…¤ ˆ§¬¥à¥­¨ï}
        sMera:=GetMeraField(FMera,GetIdField(FMera,E^.Dat.MarketElement[i].BazKod));
        rformat(sMera,CZena-1);
        write(t,sMera,SeparatorChar);
        {ª®«-¢®}
        rFormat(E^.Dat.MarketElement[i].Input.Kol,Ckol);
        write(t,E^.Dat.MarketElement[i].Input.Kol,SeparatorChar);
        SumKol:=IntToStr(StrToInt(SumKOl)+StrToInt(E^.Dat.MarketElement[i].Input.Kol),CKol);
        {‹¨âà ¦}
        MyStr(StrToReal(GetIdField(FLitr,E^.Dat.MarketElement[i].BazKod))*
        StrToReal(E^.Dat.MarketElement[i].Input.Kol),CIZena,CLitrMantissa,sLitr);
        rFormat(sLitr,CZena);
        write(t,sLitr,SeparatorChar);
        MyStr(StrToReal(SumLitr)+StrToReal(sLitr),CIZena,CLitrMantissa,SumLitr);
        {‘¯¨àâ}
        MyStr(StrToReal(GetIdField(FEtil,E^.Dat.MarketElement[i].BazKod))
             /100*StrToReal(E^.Dat.MarketElement[i].Input.Kol)
             *StrToReal(GetIdField(FLitr,E^.Dat.MarketElement[i].BazKod)),CIZena,CMantissa,sEtil);
        rFormat(sEtil,CZena);
        write(t,sEtil,SeparatorChar);
        MyStr(StrToReal(SumEtil)+StrToReal(sEtil),CIZena,CMantissaZ,SumEtil);
        {‘â ¢ª  €ªæ}
        IF (e^.Dat.MarketElement[i].Input.RegionMarka=1) then
        begin
          rformat(AkzisKoeff[StrToInt(GetIdField(FBuchGroup,E^.Dat.MarketElement[i].BazKod))],CZena);
          Write(t,AkzisKoeff[StrToInt(GetIdField(FBuchGroup,E^.Dat.MarketElement[i].BazKod))],SeparatorChar);
        end
        else Write(t,'    0.00',SeparatorChar);
        {€ªæ¨§}
        rformat(sAkzis,CZena);
        writeln(t,SAkzis,SeparatorChar);

   end;

WRITELN(t,Space+'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
+'ÄÄÄÄÄÄÄÄÄÄ');

   rFormat(SumKol,CKol);
   write(t,Space+SeparatorChar+SeparatorChar+SeparatorChar+'                     ‚á¥£® ¯® ­ ª« ¤­®©: '
   +SeparatorChar+SumKol,SeparatorChar);
   rFormat(SumLitr,CZena);
   write(t,SumLitr,SeparatorChar);
   RFormat(SumEtil,CZena);
   write(t,SumEtil,SeparatorChar);
   write(t,'    --- ',SeparatorChar);
   DelSpace(SAkzisAll);
   rFormat(SAkzisAll,CZena);
   writeln(t,SAkzisAll,SeparatorChar);

Writeln(T);
Writeln(t,Space+'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
WRITELN(t,Space+'============================================================================='
+'==========');

   IORez:=ioresult;
   Close(t);
   IORez:=ioresult;
 end;

 Dispose(E,Done);

{ ViewAsText(Path^.Dat.TOTemp+'akztrn.txt',' áç¥â  ªæ¨§®¢ ­  ¢­ãâà¥­­¥¥ ¯¥à¥¬¥é¥­¨¥' ,True);}

End;

procedure TestFormAkzTrn;
VAr Ass: DocumentEditZ;
Begin
  Ass.EditPosition := '26';
  Ass.D := '16-05-05';
  FormAkzTrn(Ass);
End;

BEGIN
END.