Procedure FormSF( Video : Boolean; E:PSuperMarketType;
                   Var Txt:Text; Var NDS,Itogo,ItogoSkidka,NDS20,NDS10,NDS_:Real;Comissioner:Boolean);
Var l : Word;
    k,j : Byte;
    s,ws,ws1 : String;
    {��� � �ந�����⥫�}
    s2,s3,s4 : String;
    kkk:Text;
    st : String[CMantissa];
    ItogoLitr,PromItogoPos,ItogoPos,NDSPos : Real;
    Test : LongInt;
    SDoc,SDate,SummaNDS : String[CInputIZena];
    RealZena,ITOGONDS_NP,SummaZena: String[CInputIZena];
    Space : AllStr;
    ItogNalog,Koefficient,pp : AllStr;
    Rek1 :Rekwiziti;
    NPNalog,NormalZena,Koeffizient : String[CZena];
    Lg : PSuperMarketType;
    Barter : String[CMantissa];
    Art,Symbol : ArtikulStr;
    Cl : PClientType;
    BBB : PBazType;
    SKL : PExtSkladType;
    ZakazNumer,ZakazDate:AllStr;

Begin

If Not(Video) Then
Begin
DInfoMsg('��ନ��� ���-䠪����. ����...',True);
End;

   New(Cl,Init);
   Cl^.DAt.Kod:=E^.Dat.ClientKod;

   GetClient(Cl,E^.Dat.OperatorSelector);


   DelSpace(E^.Dat.Document);
   DelSpace(E^.Dat.DocReal);
   s:=E^.Dat.Document;
   s:=Bold[NPrint.Printer]+S+NoBold[NPrint.Printer];
   Space:='     ';
   If Not(Comissioner) Then
   Rek1:=RekSF
   Else
   Rek1:=RekComissioner;



   zakaznumer[0]:=#0;
   zakazDate[0]:=#0;
(* �࠭� 26/03/01 �� ��稭� ��壠��ਨ
   If E^.Dat.Oformlenie=1 Then
    Begin
     ZakazNumer:=E^.DAt.FromZakaz;
     DelSpace(ZakazNumer);
     ZakazNumer:='�� '+ZakazNumer+'/';
     ZakazDate:=GetZakazDate(E^.DAt.FromZakaz,FieldDate);
    End
    Else
     Begin
If ((E^.Dat.Realiz) And (E^.Dat.DocSelector in [5,6,7,8])) Or
   (Not (E^.Dat.Realiz) And (E^.Dat.DocSelector in [0,1,2,3,4]))
 Then
      ZakazDate:=E^.Dat.DateC
Else
      ZakazDate:=E^.Dat.DocDate;
     End;
*)


If ((E^.Dat.Realiz) And (E^.Dat.DocSelector in [5,6,7,8])) Or
   (Not (E^.Dat.Realiz) And (E^.Dat.DocSelector in [0,1,2,3,4]))
 Then
      ZakazDate:=E^.Dat.DateC
Else
      ZakazDate:=E^.Dat.DocDate;




if (FindParam('/MED')) Then
Begin
   Writeln(Txt,Condensed[NPrint.Printer]+Space+'��⮢�� ��業���:'+
   Format(Rek1.LizensiaOPTL_V,CAll)+'           '+
   Nocondensed[NPrint.Printer]+
   '                 �ਫ������ N 1');
   Writeln(Txt,Condensed[NPrint.Printer]+Space+'                             '+      Format(Rek1.LizensiaOPTSig,CAll)+
   Nocondensed[NPrint.Printer]+
   '   � ���浪� ������� ��ୠ��� ��⮢-䠪���');
   Writeln(Txt,Condensed[NPrint.Printer]+Space+'                         '+      Format(Rek1.LizensiaOPTPiv,CAll)+
   Nocondensed[NPrint.Printer]+
   ' �� ����� �� ������ �� ����������� �⮨�����');
End
Else
 Begin
   Writeln(Txt,Condensed[NPrint.Printer]+Space+'��⮢�� ��業��� �� ���-��.:'+
   Format(Rek1.LizensiaOPTL_V,CAll)+
   Nocondensed[NPrint.Printer]+
   '                 �ਫ������ N 1');
   Writeln(Txt,Condensed[NPrint.Printer]+Space+'��⮢�� ��業��� �� ᨣ����:'+      Format(Rek1.LizensiaOPTSig,CAll)+
   Nocondensed[NPrint.Printer]+
   '   � ���浪� ������� ��ୠ��� ��⮢-䠪���');
   Writeln(Txt,Condensed[NPrint.Printer]+Space+'��⮢�� ��業��� �� ����:'+      Format(Rek1.LizensiaOPTPiv,CAll)+
   Nocondensed[NPrint.Printer]+
   ' �� ����� �� ������ �� ����������� �⮨�����');
 End;


   Writeln(Txt);
{  Writeln(Txt,Space+'                                               �ਫ������ N 1');
   Writeln(Txt,Space+'                                   � ���浪� ������� ��ୠ��� ��⮢-䠪���');
   Writeln(Txt,Space+'                                �� ����� �� ������ �� ����������� �⮨�����');
   Writeln(txt,Space+'-----------------------------------------------------------------------------------------------');}

{
   Writeln(Txt,Space+
   Bold[NPrint.Printer]+Italic[NPrint.Printer]+'�������� �������! ��������, ����� '+
   High[nPrint.Printer]+'��������'+NoHigh[NPrint.Printer]+Bold[NPrint.Printer]+Italic[NPrint.Printer]+
   ' � 13/06/2000 ���⠢騪�� ����'+
   NoBold[NPrint.Printer]+NoItalic[NPrint.Printer]);

   DelSpaceLeftRight(Rek1.Name);

   Writeln(Txt,Space+'   '+
   Bold[NPrint.Printer]+Italic[NPrint.Printer]+High[NPrint.Printer]+Rek1.Name+'!'+NoHigh[NPrint.Printer]+
   +NoBold[NPrint.Printer]+NoItalic[NPrint.Printer]);

   Writeln(Txt,Space+Bold[NPrint.Printer]+Italic[NPrint.Printer]+
   '  �� ��������� ����᫥��� �� ���㬥�⠬, �믨ᠭ�� ��稭�� � 13/06/2000,'+
   NoBold[NPrint.Printer]+NoItalic[NPrint.Printer]);

   Writeln(Txt,Space+Bold[NPrint.Printer]+Italic[NPrint.Printer]+
   '              �஢���� �� ���� 㪠����� ������᪨� ४����⠬!'+
   NoBold[NPrint.Printer]+NoItalic[NPrint.Printer]);

   Writeln(Txt);
}
   s:=Cl^.Dat.FullNAme{GetClientField(FClient,E^.Dat.ClientKod,E^.Dat.OperatorSelector)};
   Writeln(Txt,Condensed[NPrint.Printer]+Space+
   '���⠢騪:'+Format(Rek1.Name,CAll)+'                    ���㯠⥫�:'+Format(s,CAll));

   s:=Cl^.Dat.Adress{GetClientField(FAdress,E^.Dat.ClientKod,E^.Dat.OperatorSelector)};
   Writeln(Txt,Space+
   '����:'+Format(Rek1.Adress,CAll)+'                        ����:'+Format(s,CAll));

   s:=Cl^.Dat.Telefon{GetClientField(FTelefon,E^.Dat.ClientKod,E^.Dat.OperatorSelector)};
   Writeln(Txt,Space+
   '����䮭:'+Format(Rek1.Telefon,CAll)+'                      ����䮭:'+Format(s,CAll));

{  �ࠫ �� ������������� ��� 㢥��祭�� ���� �� ���� 23.10.98}
   s:=Cl^.Dat.Gorod{GetClientField(FGorod,E^.Dat.ClientKod,E^.Dat.OperatorSelector)};
   Writeln(Txt,Space+
   '��த:'+Format(Rek1.Gde,CAll+20)+'    ��த:'+Format(s,CAll));

   s:=Cl^.Dat.INN{GetClientField(FInn,E^.Dat.ClientKod,E^.Dat.OperatorSelector)};
   Writeln(Txt,Space+
   '���:'+Format(Rek1.INN,CAll)+'                          ���:'+Format(s,CAll));

   s:=Cl^.Dat.R_Sh{GetClientField(FRSh,E^.Dat.ClientKod,E^.Dat.OperatorSelector)};
   Writeln(Txt,Space+
   '������ ���:'+Format(Rek1.R_Sh,CAll)+'               ������ ���:'+Format(s,CAll));

   Writeln(Txt,Space+
   '����.���:'+Format(Rek1.K_Sh,CAll));

   s:=Cl^.Dat.Gde{GetClientField(FGde,E^.Dat.ClientKod,E^.Dat.OperatorSelector)};

   Writeln(Txt,Space+
   '�:'+Format(Rek1.Gde,CAll+20)+'        �:'+Format(s,CAll));
   Writeln(Txt,Space+
   '���:'+Format(Rek1.BIK,CAll));

{  �ࠫ �� ������������� ��� 㢥��祭�� ���� �� ���� 23.10.98
   s:=GetClientField(FOkonh,E^.Dat.ClientKod,E^.Dat.OperatorSelector);
   Writeln(Txt,Space+
   '�����:'+Format(Rek1.Okonh,CAll)+'                        �����:'+Format(s,CAll));

   s:=GetClientField(FOkpo,E^.Dat.ClientKod,E^.Dat.OperatorSelector);
   Writeln(Txt,Space+
   '����:'+Format(Rek1.Okpo,CAll)+'                         ����:'+Format(s,CAll));
}

   s:=Cl^.Dat.Enviropment{GetClientField(FEnvir,E^.Dat.ClientKod,E^.Dat.OperatorSelector)};
   Writeln(Txt,Space+
   '��㧮��ࠢ�⥫� � ��� ����:'+Format({Rek1.Name}
   Rek1.AdressGruza,CClient{All})+
   '                          �������⥫쭮 (N ��業�.):'+Format(s,CAll));
   s:=Cl^.Dat.Adress{GetClientField(FAdress,E^.Dat.ClientKod,E^.Dat.OperatorSelector)};
   ws:=Cl^.Dat.Name{GetClientField(FClient,E^.Dat.ClientKod,E^.Dat.OperatorSelector)};

   Writeln(Txt,Space+
   '��㧮�����⥫� � ��� ����:'+ws+' '+s);
   Writeln(Txt,Space+'� ���⥦��-���⭮�� ���㬥��� N '+'_________'+' �� '+'________');
   Writeln(Txt,NoCondensed[NPrint.Printer]);

DelZerro(E^.Dat.Document);
Barter[0]:=#0;

If E^.Dat.Realiz Then
Begin
ws:=E^.Dat.DAteC;
If E^.Dat.DocSelector in [5,6,7,8] Then
Writeln(Txt,Space+Bold[NPrint.Printer]+Double[NPrint.Printer]+'������: ���㬥�� �������� �����'+Nobold[NPrint.Printer]+
Nodouble[NPrint.Printer])
Else
Writeln(Txt,Space+Bold[NPrint.Printer]+Double[NPrint.Printer]+'������: ���㬥�� ����祭'+Nobold[NPrint.Printer]+
Nodouble[NPrint.Printer]);

ws:=ClearChar(ws);
Writeln(Txt,Space+'                                                                          '+
Bold[NPrint.Printer]+Double[NPrint.Printer]+'��'+ws+E^.Dat.Document{E^.Dat.DocReal}+NOBold[NPrint.Printer]+
NoDouble[NPrint.Printer]{NoItalic});
{   Writeln(txt,Space+Bold+Double+'��� ���㬥��: (',LeadingZero(E^.Dat.DocSelector),')'+NOBold+NoDouble);}

If E^.Dat.OperatorSelector<2 Then Barter[0]:=#0
Else Barter:='-�';

DelSpace(E^.DAt.Document);


If Not Comissioner Then
Begin
If E^.Dat.DocSelector in [5,6,7,8] Then
   Writeln(Txt,Space+High[NPrint.Printer]+Double[NPrint.Printer]+'        ����-������� N '+ZakazNumer+E^.Dat.Document+Barter+
   '/'+IntToStr(StrToInt(E^.DAt.SkladKod),COne)+
   ' �� '+ZakazDate+
   NoHigh[NPrint.Printer]+
   NoDouble[NPrint.Printer])
Else
   Writeln(Txt,Space+High[NPrint.Printer]+Double[NPrint.Printer]+'        ����-������� N '+ZakazNumer+E^.Dat.DocReal+Barter+
   '/'+IntToStr(StrToInt(E^.DAt.SkladKod),COne)+
   ' �� '+ZakazDate{E^.Dat.DocDAte}+
   NoHigh[NPrint.Printer]+
   NoDouble[NPrint.Printer]);
End
Else
 Begin
   If E^.Dat.OperatorSelector<2 Then Barter[0]:=#0
   Else Barter:='-�';
   Writeln(Txt,Space+High[NPrint.Printer]+Double[NPrint.Printer]+'        ����-������� N '+'_________'+
   ' �� '+'__________'+NoHigh[NPrint.Printer]+NoDouble[NPrint.Printer]);
 End;

(* �࠭� 26/03/01 �� ��稭� ��壠��ਨ
If E^.Dat.Oformlenie=1 Then
Begin
If ((E^.Dat.Realiz) And (E^.Dat.DocSelector in [5,6,7,8])) Or
   (Not (E^.Dat.Realiz) And (E^.Dat.DocSelector in [0,1,2,3,4]))
 Then
Writeln(txt,Space+Italic[NPrint.Printer]+Double[NPrint.Printer]+
E^.Dat.Document+barter+'/'+IntToStr(StrToInt(E^.DAt.SkladKod),COne)++' '+E^.Dat.DateC+' ('+E^.Dat.TimeC+')'+
NoItalic[NPrint.Printer]+NoDouble[NPrint.Printer])
Else
Writeln(txt,Space+Italic[NPrint.Printer]+Double[NPrint.Printer]+
E^.Dat.DocReal+barter+'/'+IntToStr(StrToInt(E^.DAt.SkladKod),COne)+' '+E^.Dat.DocDate+' ('+E^.Dat.TimeC+')'+
NoItalic[NPrint.Printer]+NoDouble[NPrint.Printer])
End;
*)
End
Else
 Begin
   If E^.Dat.OperatorSelector<2 Then Barter[0]:=#0
   Else Barter:='-�';


If Not Comissioner Then
Begin
   Writeln(Txt,Space+High[NPrint.Printer]+Double[NPrint.Printer]+'        ����-������� N '+ZakazNumer+E^.Dat.Document+Barter+
   '/'+IntToStr(StrToInt(E^.DAt.SkladKod),COne)+
   ' �� '+ZakazDate+
   NoHigh[NPrint.Printer]+
   NoDouble[NPrint.Printer])
End
Else
 Begin
   Writeln(Txt,Space+High[NPrint.Printer]+Double[NPrint.Printer]+'        ����-������� N '+'_________'+
   ' �� '+'__________'+NoHigh[NPrint.Printer]+NoDouble[NPrint.Printer]);
 End;


(*  �࠭� 26/03/01 �� ��稭� ��壠��ਨ
If E^.Dat.Oformlenie=1 Then
Begin
Writeln(txt,Space+Italic[NPrint.Printer]+Double[NPrint.Printer]+
E^.Dat.Document+barter+'/'+IntToStr(StrToInt(E^.DAt.SkladKod),COne)+' '+E^.Dat.DateC+' ('+E^.Dat.TimeC+')'+
NoItalic[NPrint.Printer]+NoDouble[NPrint.Printer])
End;
*)

 End;

   Space:=' ';
   ItogoSkidka:=0;  Itogo:=0; NDS:=0; NDSPos:=0; ItogoPos:=0;PromitogoPos:=0;
   ItogoLitr:=0; NDS20:=0; NDS10:=0; NDS_:=0;
   Koefficient[0]:=#0;
   For l:=1 To E^.Dat.Amount Do
   Itogo:=Itogo+StrToReal(E^.Dat.MarketElement[l].Input.Zena)*StrToInt(E^.Dat.MarketElement[l].Input.Kol);
{
   Writeln(txt,Space+'---------------------------------------------------------------------------------------------');
   Writeln(txt,Space+'������������ ⮢��        �� �����     ����         �㬬�  ���     �㬬� ���     �⮣� �㬬�');
   Writeln(txt,Space+'                                                             %                     � ��� � ��');
   Writeln(txt,Space+'---------------------------------------------------------------------------------------------');
}

Writeln(txt,Condensed[NPrint.Printer]+Space+'______________________________________________________________________'+'____________________________________________________________________________________');

Writeln(txt,Space+                          'N ������������ ⮢��        '+' ������   �����.    ����       �㬬�  ���      �㬬�     �⮣� �㬬�   �ᥣ�'+'  ��࠭�          ����� ⠬������� ������樨');
Writeln(txt,Space+                          '                             '+' ����७.                              ��.     ������         � ���       ��      �ந�宦�����');
Writeln(txt,Space+                          '                             '+' ����७.                              ��                    � ���       �� ');
Writeln(txt,Space+                          '                             '+' ����७.                              ���                    � ���       �� ');
Writeln(txt,Space+                          '__________________________________________________________________________________________________'+'________________________________________________________');

                    {12345678901234567890123456�123456789012345�123456789012345678901234567�1234�123456789012345}
                                                                     {1234567890123 1234 1234567890123 1234567890123}
   New(Lg,Init);
   k:=1;j:=1;

   For l:=1 To E^.Dat.Amount Do
    Begin

     If testMarketSF(E^.Dat.MarketElement[l].BazKod,Lg,j) Then
      Begin
       Str((StrToInt(Lg^.Dat.MarketElement[j].Input.Kol)+
            StrToInt( E^.Dat.MarketElement[l].Input.Kol)):CKol,Lg^.Dat.MarketElement[j].Input.Kol);
      End
      Else
      Begin
       Lg^.Dat.MarketElement[k]:=E^.Dat.MarketElement[l];
       Inc(k);
       Lg^.DAt.Amount:=k-1;
      End;
    End;
    Lg^.DAt.Amount:=k-1;


   New(BBB,Init);
   New(Skl,Init);

   For l:=1 To Lg^.Dat.Amount Do
    Begin

   s2[0]:=#0;
   s3[0]:=#0;
   s4[0]:=#0;

   Skl^.Dat.BAzKod:=Lg^.Dat.MarketElement[l].BazKod;
   GetExtSkladRecord(Skl);
   GetBazElement(Lg^.Dat.MarketElement[l].BazKod,BBB^.Dat);


     ItogoLitr:=ItogoLitr+StrToReal(BBB^.Dat.Litr{GetIdField(FLitr,Lg^.Dat.MarketElement[l].BazKod)})*
     StrToInt(Lg^.Dat.MarketElement[l].Input.Kol);
     Str(l:CMantissa,St);
     s:=Lg^.Dat.MarketElement[l].BazKod;

     If NPrint.FullName=0 Then
     Begin
      ws:=BBB^.Dat.NAme{GetIdField(FName,Lg^.Dat.MarketElement[l].BazKod)};
      ws1:=BBB^.Dat.NAme2{GetIdField(FName2,Lg^.Dat.MarketElement[l].BazKod)};
      DelSpaceRight(ws1);
      If ws1[0]<>#0 Then
           Begin
            Writeln(txt,Space+'   '+ws);
         ws:=ws1;
        End;
     End
     Else
         Begin
          ws:=BBB^.Dat.NAme{GetIdField(FName,Lg^.Dat.MarketElement[l].BazKod)};
       ws1:=BBB^.Dat.NAme2{GetIdField(FName2,Lg^.Dat.MarketElement[l].BazKod)};
       DelSpaceRight(ws1);
       If ws1[0]<>#0 Then
           Begin
            Writeln(txt,Space+'   '+ws);
         ws:=ws1;
        End;
      End;

     Format(ws,CName);
     s:=ws;
     s4:=IntToStr(l,CMantissa);
     RFormat(s4,CMantissa);
     s:=s4+' '+s{+' '+s3+' '+s2};
     ws:=Lg^.Dat.MarketElement[l].Input.Kol;
     DelSpace(Ws);
     RFormat(ws,CKol);
     s2:=BBB^.Dat.Mera{GetIdField(FMera,Lg^.Dat.MarketElement[l].BazKod)};
     Format(s2,CMera-6);

     s:=s+' '+{GetIdField(FMera,Lg^.Dat.MarketElement[l].BazKod)}s2+' '+ws;
              {��}

     If E^.Dat.SkidkaSelector=0 Then{�᫨ ��⮬��}
       MyStr((StrToReal(Lg^.Dat.MarketElement[l].Input.Zena)/
       (1+StrToReal(Lg^.Dat.MarketElement[l].Input.Proz)/100))
       ,CZena,CMantissa,ws){����� 業�}
     Else
       MyStr((StrToReal(Lg^.Dat.MarketElement[l].Input.Zena)-
                 StrToReal(Lg^.Dat.MarketElement[l].Input.Skidka)),
                    CZena,CMantissa,ws);{����� 業�}


     NormalZena:=ws;


       NPNalog[0]:=#0;
       If E^.DAt.DocSelector in [1,2,3,5,6] Then
       Begin
       Mystr(((1+strtoreal(Lg^.dat.marketelement[l].Input.SpecNalog)
              /100)),CZenaZ,CMantissaZ,koefficient);
       {����� 業�}
       MyStr((StrToReal(NormalZena)-StrToReal(NormalZena)/StrToReal(Koefficient)),CZena,CMantissa,NPNalog);
       MyStr(StrToReal(NPNalog)*StrToInt(Lg^.dat.marketelement[l].Input.Kol),CZena,CMantissa,NPNAlog);
       MyStr(StrToReal(NormalZena)/StrToReal(Koefficient),CZena,CMantissa,RealZena);
       End
       Else
           Begin
            RealZena:=ws;
         MyStr(StrToReal(NPNalog),CZena,CMantissa,NPNalog);
        End;




{��竨 ᪨��� �� 業�}
{!!!!}       ItogoPos:=StrToReal(RealZena{ws})*StrToInt(Lg^.Dat.MarketElement[l].Input.Kol);
{�뫮        ItogoPos:=StrToReal(ws)*StrToInt(Lg^.Dat.MarketElement[l].Input.Kol);}

{���⠫� �㬬� �⮣� � ����樨 � ᪨����}
       NdsPos:=ItogoPos*
       StrToReal(Lg^.Dat.MarketElement[l].Input.NDs)/(100+StrToReal(Lg^.Dat.MarketElement[l].Input.NDS));

       Test:=StrToInt(Lg^.Dat.MarketElement[l].Input.Kol);
       If Test <> 0 Then
       Begin
       MyStr(((ItogoPos-NDSPos)/StrToInt(Lg^.Dat.MarketElement[l].Input.Kol)),CZena,CMantissa,ws);
       MyStr(StrToReal(ws),CZena,CMantissa,ws);
       End
       Else Ws:='        ';

       s:=s+' '+ws;

       MyStr(NDSPos,CIZena,CMantissa,Ws);

       NdsPos:=StrToReal(Ws);

       MyStr((ItogoPos-NDSPos),CInputIZena-2,CMantissa,ws);
{����稫� �㬬� 業� � ᪨���� � ��� ��� � ����樨}

       s:=s+' '+ws;

       PromitogoPos:=PromitogoPos+StrToReal(ws);

       ws:=Lg^.Dat.MarketElement[l].Input.NDS;

       MyStr(StrToReal(ws),CLitr-1,0{CMantissa-1},ws);

       s:=s+' '+Format(Ws,CLitr-1);

       MyStr(NDsPos,CInputIZena-1,CMantissa,ws);
{���⠫� ࠧ��� ��� � ����樨}
       s:=s+' '+ws;

{���⠫� �⠢�� �� � ����樨}
       If Not (E^.DAt.DocSelector in [1,2,3,5,6]) Then ws:='0.00'
       Else
       ws:=Lg^.Dat.MarketElement[l].Input.SpecNalog;
{!!!!}
       ItogoPos:=StrToReal(NormalZena)*StrToInt(Lg^.Dat.MarketElement[l].Input.Kol);
{�뫮  ItogoPos:=StrToReal(RealZena)*StrToInt(Lg^.Dat.MarketElement[l].Input.Kol);}

       MyStr(ItogoPos,CInputIZena-2,CMantissa,ws);
       s:=s+'   '+ws;

       Nds:=Nds+NDSPos;

{ࠧ��ઠ  ��� �� �����䨪�樨}
       Case Lg^.Dat.MarketElement[l].Input.VidNDs Of
       0:Nds20:=Nds20+NdsPos;
       1:Nds10:=Nds10+NdsPos;
       2:Nds_:=Nds_+NdsPos;
       Else;
       End;

(*
       If (StrToReal(Lg^.Dat.MarketElement[l].Input.NDs)<20.01) And
          (StrToReal(Lg^.Dat.MarketElement[l].Input.NDs)>19.99) Then
             Begin
              Nds20:=Nds20+NdsPos;
             End
       Else
          Begin
           If (StrToReal(Lg^.Dat.MarketElement[l].Input.NDs)<10.01) And
              (StrToReal(Lg^.Dat.MarketElement[l].Input.NDs)>9.99) Then
              Begin
                Nds10:=Nds10+NdsPos;
              End
           Else
              Begin
                Nds_:=Nds_+NdsPos;
              End
          End;
*)



{�㬬� ��� �� �/�}

 If PrintGTD[2]=1 Then
  Begin
   s2:=Skl^.Dat.Input.NGTD{BakGetField(FNGTD,Lg^.Dat.MarketElement[l].BazKod,0)};
   s3:=Skl^.Dat.Input.Post{BakGetField(FPost,Lg^.Dat.MarketElement[l].BazKod,0)};
  End;
   DelSpaceRight(s2);
   DelSpaceRight(s3);
   Format(s2,CNSertif-13);
   Format(s3,CPost);


     Writeln(txt,Space+s+' '+NPNalog+' '+s3+' '+s2);

{If PrintGTD[2]=1 Then
  Begin
   s2:=BakGetField(FNGTD,Lg^.Dat.MarketElement[l].BazKod,0);
   s3:=BakGetField(FPost,Lg^.Dat.MarketElement[l].BazKod,0);
   DelSpaceRight(s2);
   DelSpaceRight(s3);
   If (s2[0]<>#0)Or(s3[0]<>#0) Then
    Begin
     Format(s2,CNSertif);
     WriteLn(txt,Space+'N ���/���: '+s2+
                    ' �ந�����⢮:'+s3);
    End;
  End;}
    End;
    DelSpace(E^.Dat.SummaZ);
    RFormat(E^.Dat.SummaZ,CIZena-4);
    DelSpace(E^.Dat.ENalog);
    MyStr(StrToReal(E^.Dat.ENalog),CZena-1,CMantissa,ItogNalog);
    Writeln(txt,Space+'___________________________________________________________________________________________________'+
    '_______________________________________________________'+NoCondensed[NPrint.Printer]);
    MyStr(StrToReal(E^.Dat.SummaZ),CIZena-6,CMantissa,E^.Dat.SummaZ);
    Writeln(Txt,Space+'�ᥣ� ����権:',Lg^.Dat.Amount:2);
    Writeln(Txt,Space+'�ᥣ� � �����:         ',PromItogoPos:CIZena:CMantissa,' ',NDs:CinputIZena-3:CMantissa,
    '  ',E^.Dat.SummaZ);
    if not(FindParam('/MED')) Then
    Writeln(Txt,Space+'�ᥣ� ',ItogoLitr:CILitr:CLitrMantissa,' ���஢ �������쭮� �த�樨');
    Writeln(txt,Space+Condensed[NPrint.Printer]+'_________________________________________________________________________'+
    '____________________________'+
    '_____________________________________________________'+NoCondensed[NPrint.Printer]);
    If E^.Dat.DocSelector in [3,4,6,8] Then
    Begin
    s:=E^.Dat.SummaZ;
    DelSpace(s);
    Propis(s,ws);
    ws[1]:=UpperCase(ws[1]);
    Writeln(txt,Space+Italic[NPrint.Printer]+Bold[NPrint.Printer]+Double[NPrint.Printer]+ws+NoItalic[NPrint.Printer]+
    NoBold[NPrint.Printer]+NoDouble[NPrint.Printer]);
    If s[0]<>#0 Then
    Writeln(txt,Space+Italic[NPrint.Printer]+Bold[NPrint.Printer]+Double[NPrint.Printer]+s+NoItalic[NPrint.Printer]+
    NoBold[NPrint.Printer]+NoDouble[NPrint.Printer])
    End;
    Writeln(txt,Space+Condensed[NPrint.Printer]+'____________________________________________________________________________'+
    '____________________________'+
    '__________________________________________________'+NoCondensed[NPrint.Printer]);
   Writeln(Txt);
   Writeln(Txt,Space+'   �㪮����⥫� �।����� ________                ������ ��壠��� _______');
   Writeln(Txt);
   Writeln(Txt);
   Writeln(Txt,Space+'   ���� _______          �.�.                   �.�.          ����稫 _______');
   Writeln(txt,Space+'                                                       (������� �⢥��⢥����� ���)');

   Writeln(Txt,Space+'   �ਬ�砭��: ��� ���� ������⢨⥫��.���� ���������-���㯠⥫�, ��ன-�த����.');

   If E^.Dat.Rashet=2 Then Symbol:='-�'
   Else Symbol:='';

   Writeln(txt,Space+'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+
   ')'+Italic[NPrint.Printer]+Bold[NPrint.Printer]+
   Double[NPrint.Printer]+'                                                ��� ���㬥��: (',
                     LeadingZero(E^.Dat.DocSelector),+Symbol+')'+NoItalic[NPrint.Printer]+NOBold[NPrint.Printer]+
                                 NoDouble[NPrint.Printer]);

    Writeln(txt,Space+Condensed[NPrint.Printer]+'========================================================================='+
    '============================'+
    '====================================================='+NoCondensed[NPrint.Printer]{+
     EconomodeON[NPrint.Printer]});
   Dispose(Lg,Done);

   Dispose(Cl,Done);
   Dispose(BBB,Done);
   Dispose(Skl,Done);

If Not(Video) Then NoInfoMsg;

End;
