{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}

{$I Compile.INC}



Unit Cp;

Interface

Uses Glob,Dialogs,ServStr,Serv,Utils;

Procedure CreatPrise(Var Txt : Text;VAr Ef:File;M:Maska8;TempBox:PBox;Assort,Sort:Word);

Implementation

Uses App,DBEngine,MsgBox,Tools,Printers,Objects,Views,Propiss,TpDate,Access,
     Validate,NetDBEng,Vision4,Vision5,Vision6,Utils1,Prise,ExpImp;

Procedure CreatPrise;
Const JP=2;


Var l,lk : Word;
    Ps,Fas,TempArtikul,ss : AllStr;
    S : TMyString;
    ws,ws1,ws2 : String;
    Otdel,Pack,P : AllStr;
    TextSertif,Space : TEnJoyStr;
    RazdelO,RazdelR,ItogoR,ItogoO : Real;
    stRz,stOz : String[CPost+5];
    E : PBufSkladType;
    Valuta :Word;
    Wk : String[CKol];
    Skidka : Boolean;
    Koef : Real;
    Art,Koeffizient : String[CArtikul];
    KoefWord : Word;
    Temp,TempList : PBox;
    WspomList: PBox;
    Separator : String[CLitrMantissa];
    Ansi : Word;
    TipID : LongInt;
    Finding : Boolean;
    Msg : ArtikulStr;
    FormPrise,MaxSh,sh,VidPrize : Word;
    ZPrize : Maska6;
    SK : PSkidkaType;
    FormLink:Boolean;
    LinkList : PBox;
    VidZ,c, Count,Bron,TTT : Word;
    FirmaPost,GTD,PPP,PPost : AllStr;


Procedure FormatZeni(E:PBufSkladType;c:Word);
Begin
 Str(StrToReal(E^.Point.Dat[c].Input.R_Zena):CZena:CMAntissa,E^.Point.Dat[c].Input.R_Zena);
 Str(StrToReal(E^.Point.Dat[c].Input.O_Zena):CZena:CMAntissa,E^.Point.Dat[c].Input.O_Zena);
 Str(StrToReal(E^.Point.Dat[c].Input.Zakupka):CZenaZ:CMAntissaZ,E^.Point.Dat[c].Input.Zakupka);
End;



Procedure CalcNewKol(Var E:SkladType;i,Bron:Word);
Begin
      Case Bron Of
{забронированный}
      1:Str(StrToInt(E.Input.DivisionR[i]):CKol,E.Input.Division[i]);
{не забронированный}
      2:Str(StrToInt(E.Input.Division[i])-
            StrToInt(E.Input.DivisionR[i]):CKol,E.Input.Division[i]);
      Else;
      End;
End;




Begin

      While Not(Eof(ef)) Do
      Begin
         New(E,Init);
         Count:=0;
         ReadBufSklad(ef,E,Count);
For c:=1 To Count Do
Begin
        If FormPrise=1 Then GetSkidka(E^.Point.Dat[c].BazKod,Sk^.Dat);

        E^.Point.Dat[c].Input.Kol[0]:=#0;
        If ((GetIDMArket(E^.Point.Dat[c].BazKod)=TipID)Or(TipID=2)) Then
        Begin
        For i:=1 To CDivision Do
        Begin
         If (M[i]=1) Then
         Begin

          CalcNewKol(E^.Point.Dat[c],i,Bron);

          Str(StrToInt(E^.Point.Dat[c].Input.Kol)+StrToInt(E^.Point.Dat[c].Input.Division[i]):CKol,
          E^.Point.Dat[c].Input.Kol);
         End;
        End;

        {DelSpace(E^.Point.Dat[c].Input.Kol);}


         FormatZeni(E,C);
      {
      Str(StrToReal(E^.Point.Dat[c].Input.R_Zena):CZena:CMAntissa,E^.Point.Dat[c].Input.R_Zena);
      Str(StrToReal(E^.Point.Dat[c].Input.O_Zena):CZena:CMAntissa,E^.Point.Dat[c].Input.O_Zena);
      Str(StrToReal(E^.Point.Dat[c].Input.Zakupka):CZenaZ:CMAntissaZ,E^.Point.Dat[c].Input.Zakupka);
      }

      If ((E^.Point.Dat[c].Employ) And (StrToInt(E^.Point.Dat[c].Input.Kol)>0)And(Assort=0))Or
       ((E^.Point.Dat[c].Employ)And(Assort>0)And(((StrToInt(E^.Point.Dat[c].Input.Kol)>0))Or(i<=1)))Then
       Begin

        If NPrint.FullName=0 Then Ws:=GetIdField(FName,E^.Point.Dat[c].Bazkod)
        Else Ws:=GetIdField(FFName,E^.Point.Dat[c].Bazkod);

        Format(ws,CName);
        {учет скидки наценки}
{        If KoefWord=0 Then}
        Begin
         MyStr(StrToReal(E^.Point.Dat[c].Input.O_Zena)/Koef,CZena,CMantissa,E^.Point.Dat[c].Input.O_Zena);
         MyStr(StrToReal(E^.Point.Dat[c].Input.R_Zena)/Koef,CZena,CMantissa,E^.Point.Dat[c].Input.R_Zena);
         DelSpace(E^.Point.Dat[c].Input.R_Zena);
         DelSpace(E^.Point.Dat[c].Input.O_Zena);
        End;
{        Else
        Begin
         MyStr(StrToReal(E^.Point.Dat[c].Input.O_Zena)+Koef*StrToReal(E^.Point.Dat[c].Input.O_Zena)/100,CZena,CMantissa,
            E^.Point.Dat[c].Input.O_Zena);
         MyStr(StrToReal(E^.Point.Dat[c].Input.R_Zena)+Koef*StrToReal(E^.Point.Dat[c].Input.R_Zena)/100,CZena,CMantissa,
            E^.Point.Dat[c].Input.R_Zena);
         DelSpace(E^.Point.Dat[c].Input.R_Zena);
         DelSpace(E^.Point.Dat[c].Input.O_Zena);
        End;
}
        If Valuta=0 Then
        Begin
        RFormat(E^.Point.Dat[c].Input.O_Zena,CZena);
        RFormat(E^.Point.Dat[c].Input.R_Zena,CZena);
        End
        Else
         Begin
          MyStr(StrToReal(E^.Point.Dat[c].Input.O_Zena)/Usd,CZena,CMantissa,E^.Point.Dat[c].Input.O_Zena);
          MyStr(StrToReal(E^.Point.Dat[c].Input.R_Zena)/Usd,CZena,CMantissa,E^.Point.Dat[c].Input.R_Zena);
          RFormat(E^.Point.Dat[c].Input.O_Zena,CZena);
          RFormat(E^.Point.Dat[c].Input.R_Zena,CZena);
         End;

        MyStr(StrToREal(E^.Point.Dat[c].Input.O_Zena)/{*}(1+StrToReal(GetIdField(FNAlog,E^.Point.Dat[c].BazKod))/100),
           CZena,CMantissa,WithNP);

        Pack:=GetIdField(FInPack,E^.Point.Dat[c].Bazkod);
        DelSpace(Pack);
        P:=CalcPackNoFile(Pack,E^.Point.Dat[c].Input.Kol);
        DelSpace(P);

        s:=P;

        If Pos('+',s)>0 Then s[0]:=Chr(Pos('+',s)-1);


        RFormat(Pack,CInPack);
        MyStr((StrToInt(Pack)*StrToReal(WithNP{E^.Point.Dat[c].Input.O_Zena})),CInputIZena-3,CMantissa,StOz);
        DelSpace(stOz);
        RFormat(stOz,CInputIZena-3);

        FirmaPost[0]:=#0;
        GTD[0]:=#0;{номер ГТД}
        PPP[0]:=#0;{поставщик}
        PPost[0]:=#0;{поставщик по коду}

If ((FindParam('/MED'))) And (Ansi=0) Then
Begin
        FirmaPost:=BakGetField(FFirmaPost,E^.Point.Dat[c].BAzKod,0);
        Format(FirmaPost,CFirmaPost);
        PPP:=BakGetField(FPost,E^.Point.Dat[c].BAzKod,0);
        PPost:=BakGetField(FNMakeKod,E^.Point.Dat[c].BAzKod,0);
        GTD:=BakGetField(FNGTD,E^.Point.Dat[c].BAzKod,0);
        Format(GTD,CNSertif);
        Format(PPP,CPost);
End;

        StRz:=BakGetField(FPost,E^.Point.Dat[c].BAzKod,0);
        Format(stRz,CPost+5);


If Not (FindParam('/MED')) Then
Begin
        Case StrToInt(s) Of
        0:    s:='<1   ';
         1..5: s:='<5   ';
        6..10:s:='<10  ';
       11..20:s:='<20  ';
       21..29:s:='<30  ';
        Else  s:='>30  ';
        End;
End
Else
 Begin
  Str(StrToInt(E^.Point.Dat[c].Input.Kol):CKol,s);
 End;

        If StrToInt(E^.Point.Dat[c].Input.Kol{Division[i]})=0 Then S:=' '+' '+' '+'  ';

        If FormPrise=0 Then
        Begin
        If GetIdLocked(E^.Point.Dat[c].BazKod) Then
        Ws:=Space+E^.Point.Dat[c].BazKod+Separator+#249+s+{' '}+Separator+ws+Separator+Strz+
        Separator+FirmaPost+Separator+Pack+Separator+E^.Point.Dat[c].Input.O_Zena+Separator+WithNP+Separator+stoz
        Else
        Ws:=Space+E^.Point.Dat[c].BazKod+Separator+' '+s+{' '}+Separator+ws+Separator+Strz+
        Separator+FirmaPost+Separator+Pack+Separator+E^.Point.Dat[c].Input.O_Zena+Separator+WithNP+Separator+stoz;
        End
        Else
         Begin

        If GetIdLocked(E^.Point.Dat[c].BazKod) Then
        Ws:=Space+E^.Point.Dat[c].BazKod+Separator+#249+s+{' '}+Separator+ws+Separator+{Stzz+
        Separator}+Pack+Separator+E^.Point.Dat[c].Input.O_Zena
        Else
        Ws:=Space+E^.Point.Dat[c].BazKod+Separator+' '+s+{' '}+Separator+ws+Separator+{Stzz+
        Separator}+Pack+Separator+E^.Point.Dat[c].Input.O_Zena;

        For sh:=1 To Max6 Do
         Begin
          If ZPrize[sh]=1 Then
           Begin
            Str(StrToReal(E^.Point.Dat[c].Input.O_Zena)/
            (1+StrToReal(Sk^.Dat.Skidka[sh].Proz)/100):CZena-1:CMAntissa,strz);
            ws:=ws+Separator+Strz;
           End;
         End;

         End;

        If Sort>0 Then
        Begin
         Otdel[0]:=#0;
         {Otdel:=Copy(ws,Ord(Space[0])+1+CArtikul+2,3);}
         P:=Copy(ws,Ord(Space[0])+1,CArtikul+2+3+JP);
         Delete(ws,Ord(Space[0])+1,CArtikul+2+3+JP);
         {Insert(Otdel,ws,1+Ord(Space[0])+1+CName+1);}
         ws:=ws+Separator+P;
        End;

        Temp^.List^.Insert(NewStr(ws));
        Temp^.SetRange(Temp^.List^.Count);
       End;
       End;
End;{For}
       Dispose(E,Done);
      End;{While}
      Close(Ef);


       If ((Temp^.List^.Count-1)>=0) Then
       For lk:=0 To Temp^.List^.Count-1 Do
        Begin
        ws:=Temp^.GetText(lk,Temp^.List^.Count);
        If Sort>0 Then
        Begin
         P:=Copy(ws,Ord(ws[0])-CArtikul-2-2-JP,CArtikul+2+3++JP);
         Delete(ws,Ord(ws[0])-CArtikul-2-3-JP,CArtikul+2+3+JP+1);
         Insert(P,ws,Ord(Space[0])+1);
        End;

        Art:= Copy(ws,Ord(Space[0])+1,CArtikul);
        If GetIdMarket(Art)=0 Then ws:=ws+' З';


        ws1:=Copy(ws,Ord(Space[0])+1,CArtikul);


     If Ansi = 0 Then
      Begin
       ws2:=GetIdField(FFFNAme,ws1);
       DelSpaceRight(ws2);
       Format(ws2,CName+1+CName);
       System.Delete(ws,1+Ord(Space[0])+1+CArtikul+2+3+JP,CName);
       {DelSpace(ws);}
       System.Insert(ws2,ws,1+Ord(Space[0])+1+CArtikul+2+3+JP);
       Writeln(txt,Ws);
      End
     Else
      Begin
{         If NPrint.FullName=0 Then Ws2:=GetIdField(FName2,ws1)
          Else Ws2:=GetIdField(FFName2,ws1);
          DelSpaceRight(ws2);

          If ws2[0]<>#0 Then
          Begin
           Format(ws2,CNAme);
           ws1:=Copy(ws,1+Ord(Space[0])+1+CArtikul+2+3,CName);
           System.Delete(ws,1+Ord(Space[0])+1+CArtikul+2+3,CName);
           System.Insert(ws2,ws,1+Ord(Space[0])+1+CArtikul+2+3);
           Writeln(txt,Space+'     '+Separator+'    '+Separator+ws1+Separator);
          End;
         Writeln(txt,Ws);}

          Writeln(txt,Ws);

          If NPrint.FullName=0 Then Ws2:=GetIdField(FName2,ws1)
          Else Ws2:=GetIdField(FFName2,ws1);
          DelSpaceRight(ws2);

          If ws2[0]<>#0 Then
          Begin
           Format(ws2,CNAme);
           Writeln(txt,Space+'     '+Separator+'      '+Separator+ws2+Separator);
          End;
      End;

{ вариант печати в одну строчку
          Writeln(txt,Ws);

          If NPrint.FullName=0 Then Ws2:=GetIdField(FName2,ws1)
          Else Ws2:=GetIdField(FFName2,ws1);
          DelSpaceRight(ws2);

          If ws2[0]<>#0 Then
          Begin
           Format(ws2,CNAme);
           Writeln(txt,Space+'     '+Separator+'    '+Separator+ws2+Separator);
          End;}
End;

End;{Procedure}