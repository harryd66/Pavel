{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}

{$I Compile.INC}

Unit ArcOst;

{
�맮� --> Selection(13)

Unit Prise

   Function Selection(K:Byte):Boolean;

   Case k Of
     --> 13:New(RazdelWin, Init(R, '��娢 ���⪮�'));

   If C <> cmCancel Then
   Begin
     --> if k=13 Then CalcOstDate(RazdelSelect,M,Assort,sort);
}

INTERFACE

Uses Dialogs, ServStr,Utils;

Procedure CalcOstDate(Const Spis:PBox;Const M:MaskaNew;Const Sort:Word);

IMPLEMENTATION


Uses Objects,Tools,MSGBox, DBEngine, Glob, Serv,
     Printers, TPDate;

Const CZenaZ=10;
      CMAntissaZ=4;

Procedure CalcOstDate(Const Spis:PBox;Const M:MaskaNew;Const Sort:Word);

const Space=' ';
      SeparatorChar='$';
Var OstDAte,
    sDate : TDateString;
    IORez,i,ii: word;
    SklKod: string[CRazdelKod];
    Count, c1: word;
    Mas : Word;
    BufItog: PBufNewItogType;
    ItogBox, TempBox, RBox: PBox;
    R: Trect;
    t: text;
    saRT: ArtikulStr;
    sRazd, oldRazd: string[CRazdelKod];
    kol: word;
    pf: file;
    Zen : Word;
    Zakupka,OutNDS:AllStr;
    s,ws:TMystring;
    RazdelKol,AllKol : LongInt;
    RazdelSumma,AllSumma : Real;
Begin
{If Not Selection(14) Then Exit;}
OstDate:=FDAte;
{DatePeriodDialog(OstDate,StopDate,False);}

If Not(DateDialog(OstDate)) Then Exit;


If FindParam('/EZ') Then
Begin
 Zen:=SelectImport(12);
 If Zen=2 Then Exit;
End
 Else
  Zen:=0;


If Zen=3 Then Exit;



      sDate:=OstDate;
      {if ostDate[1]='0' then delete(ostdate,1,1);}
      Str(StrToInt(Rek.KOd):CRazdelKod,SklKOd);
      RformatZerro(SklKOd,CRAzdelKOd);

      if FExists (Path.ToArchiv+ostDate+'.p'+sklKod) then
      begin
        Assign(pf,Path.ToArchiv+ostDate+'.p'+sklKod);
        IORez:=ioresult;
        Reset(pf,SizeOf(NewItogType));
        IORez:=ioresult;
        If IORez<>0 then
        begin
         MessageBox(^M+#3'�� ���� ������ 䠩� '+Path.ToArchiv+ostDate+'.p'+sklKod+
	    ' ���:'+InTToStr(IORez,CKol),Nil,mfError+mfCAncelButton);
         exit;
        end;
      end
      else
      begin
          MessageBox(^M+#3'�� ������ 䠩� '+Path.ToArchiv+ostDate+'.p'+sklKod
		,Nil,mfError+mfCAncelButton);
          exit;
      End;

  R.Assign(0,0,0,0);
  RBox := New(PBox, Init(R, 1, Nil));
  RBox^.NewList(New(PTextCollection, Init(0,1)));

  For i:=0 To Spis^.List^.Count-1 Do
 Begin
  s:=Spis^.GetText(i,Spis^.List^.Count);
  RBox^.List^.Insert(NewStr(s));
  RBox^.SetRange(RBox^.List^.Count);
 End;


 R.Assign(0,0,0,0);
 ItogBox := New(PBox, Init(R, 1, Nil));
 ItogBox^.NewList(New(PTextCollection, Init(0,1)));

  while not eof(pf) do
      begin
        DInfoMsgShkala('�믮������ �⥭�� ���⪮� . . .',0,FileSize(pf),FilePos(pf));
        New(BufItog,Init);
        Count:=0;
        BlockRead(pf,BufItog^.Point.Dat,BufItg,Count);
        For c1:=1 To Count Do
        Begin
          sArt:=BufItog^.Point.Dat[c1].BazKOd;
          if not TestElement(Copy(sArt,1,2),RBox) then
          begin
            s:='';
            {���}
            s:=s+sArt+SeparatorChar;
            {�� �⤥�����}
            kol:=0;
            kol:=kol+StrToInt(BufItog^.Point.Dat[c1].Ost);

    If Kol>0 Then
    Begin
            ws:=IntToStr(kol,CKol);
            rformat(ws,CKOl);
            s:=s+ws+SeparatorChar;

            Case Zen Of
            0:Begin
               If Abs(StrToReal(BufItog^.Point.Dat[c1].OstE))>0.009 Then
                Begin
                 MyStr(StrToReal(BufItog^.Point.Dat[c1].OstE)/StrToInt(BufItog^.Point.Dat[c1].Ost),
			  CZenaZ,CMantissaZ,
			  Zakupka);
                End
                Else Zakupka:='???';
              End;
            1:Begin
                 Zakupka:=BakGetField(FZakupka,SArt,0);
                 MyStr(StrToReal(Zakupka),CZenaZ,CMantissaZ,Zakupka);
              End;
            Else Zakupka:='???';
            End;

            MyStr(StrToReal(Zakupka)-StrToReal(Zakupka)*
       StrToReal(GetIdField(FNDS,SArt))/(100+StrToReal(GetIdField(FNDS,SArt))),
		  CZenaZ,CMantissaZ,OutNDS);


            Format(Zakupka,CZenaZ);
            Format(OutNDS,CZenaZ);
            s:=s+SeparatorChar+Zakupka+SeparatorChar+OutNDS;

            ItogBox^.List^.Insert(NewStr(s));
            ItogBox^.SetRange(ItogBox^.List^.Count);
    End;{Kol>0}

          End; {not TestElement}
        End; { For c1:=1 }
        Dispose(BufItog,Done);
      end;  { while not eof(pf)}
  NoInfoMsg;

  Dispose(RBox,Done);

  IORez:=ioresult;
  system.close(pf);
  IORez:=ioresult;

   Assign(t,Path.ToTemp+'ostdate.txt');
   IORez:=ioresult;
   rewrite(t);
   IORez:=ioresult;
   If IORez<>0 then
    begin
      MessageBox(#3'�� ���� ������ 䠩� '+Path.ToTemp+'ostdate.txt',Nil,mfError+mfCAncelButton);
      exit;
    end;

  Writeln(T,'�����:'+GetClientField(FClient,Rek.Kod,1)+' ������: '+CurrentPassword);
  Writeln(T,'      � � � � � � �   � � � � � �   � �   � � � � � �    ��  '+SDate);
  writeln(t);
  Write(T,'����஢��: ');
  Case Sort Of
  0:WriteLn(t,'�� ����');
  1:WriteLn(t,'�� ������������');
  Else WriteLn(t);
  End;

  Write(T,'����: ');
  Case Zen Of
  0:WriteLn(t,'�� ��');
  1:WriteLn(t,'�� ���㯪�');
  Else WriteLn(t);
  End;
{
  Write(T,'����: ');
  Case Zen Of
  0:WriteLn(t,'������');
  1:WriteLn(t,'���㯪�1');
  2:WriteLn(t,'���㯪�2');
  Else WriteLn(t);
  End;
}
  AllKol:=0;
  RazdelKol:=0;
  AllSumma:=0;
  RazdelSumma:=0;

  Writeln(T);
  Writeln(t,
  Condensed2[Nprint.Printer]+
  MinInterval2[Nprint.Printer]);

  Write(T,Space+'������������������������������������������������������������������');
  Writeln(t,'���������������������Ŀ');
  Write(T,Space+'����  � ������������                                        ����. ');
  writeln(t,'�  ����    �   ��� ����');
  Write(T,Space+'������������������������������������������������������������������');
  writeln(t,'�����������������������'+Normal[Nprint.Printer]+Condensed2[Nprint.Printer]);
  R.Assign(0,0,0,0);
  TempBox := New(PBox, Init(R, 1, Nil));
  TempBox^.NewList(New(PTextCollection, Init(0,1)));

  OldRazd:='-1';

  if (ItogBox^.List<>nil) and (ItogBox^.List^.Count>0) then
  for i:=0 to ItogBox^.List^.Count-1 do
  BEgin
    DInfoMsgShkala('��ନ����� ���� . . .',0,ItogBox^.List^.Count-1,i);
    s:='';
    s:=s+ItogBox^.GetText(i,ItogBox^.List^.Count);
    sArt:=copy(s,1,CArtikul);
    sRazd:=copy(sArt,1,CRazdelKod);

    if StrToInt(sRazd)<>StrToInt(oldRazd) then
    begin
      if TempBox^.List^.Count>0 then
       begin
        for ii:=0 to TempBox^.List^.Count-1 do
        begin
         ws:='';
         ws:=TempBox^.GetText(ii,TempBox^.List^.Count);
         if sort=0 then
         else
         begin
           sArt:=copy(ws,Pos(separatorChar,ws)+1,CArtikul);
           System.Delete(ws,Pos(separatorChar,ws)+1,CArtikul+1);
           ws:=sArt+SeparatorChar+ws;
         end;
         Zakupka:=Copy(ws,1+CArtikul+1+(CNAme+1+CNAme)+1,CKol);
         RazdelKol:=RazdelKol+StrToInt(Zakupka);
         AllKol:=AllKol+StrToInt(Zakupka);

         While Pos(SeparatorChar,ws)>0 Do
          Begin
           ws[Pos(SeparatorChar,ws)]:=' ';
          End;

         writeln(t,space+' '+ws);{'+'!'+Zakupka+'@'+Copy(ws,1+CArtikul+1+(CNAme+1+CNAme)+1+CKol+1+(CKOl+1)*KolOtdel,CZenaZ));}
{         MemCC(Copy(ws,1+CArtikul+1+(CNAme+1+CNAme)+1+CKol+1,CZenaZ));}
         RazdelSumma:=RazdelSumma+StrToInt(Zakupka)*
	    StrToReal(Copy(ws,1+CArtikul+1+(CNAme+1+CNAme)+1+CKol+1+1,CZenaZ));
         AllSumma:=AllSumma+StrToInt(Zakupka)*
	    StrToReal(Copy(ws,1+CArtikul+1+(CNAme+1+CNAme)+1+CKol+1+1,CZenaZ));

        end;{For}
        TempBox^.NewList(Nil);
        TempBOx^.NewList(New(PTextCollection, Init(0,1)));
       end;{TempBox^.List^.Count>0}


      If I>0 Then
      Begin
      writeln(t,'                                                ____________________________________________');
      writeln(t,'                                                 �ᥣ�:',RazdelKol:8,'�� �� �㬬�:'+
	 RealToStr(RazdelSumma,CIZena,CMantissaZ)+' ��');
      RazdelKol:=0;
      RazdelSumma:=0;
      End;
      writeln(t,'     ������: ',GetRazdel(sRazd));
      writeln(t);
      OldRazd:=sRazd;
    end; {if sRazd<>copy(sArt,1,CRazdelKod) then}

    if sort=0 then
       begin
       {���}
        ws:=GetIDField(FFFName,sArt);
        format(ws,CName+1+CName);
        System.Insert(ws+SeparatorChar,s,1+CArtikul+1);
        TempBox^.List^.Insert(NewStr(s));
        TempBox^.SetRange(TempBox^.List^.Count);
       end
      else
       begin
       {������������}
        ws:=GetIDField(FFFName,sArt);
        format(ws,CName+1+CName);
        s:=ws+SeparatorChar+s;
        TempBox^.List^.Insert(NewStr(s));
        TempBox^.SetRange(TempBox^.List^.Count);
       end;

    if i= ItogBox^.List^.Count-1 then
    begin
      if TempBox^.List^.Count>0 then
       begin
       for ii:=0 to TempBox^.List^.Count-1 do
        begin
         ws:='';
         ws:=TempBox^.GetText(ii,TempBox^.List^.Count);
         if sort=0 then
         else
         begin
           sArt:=copy(ws,Pos(separatorChar,ws)+1,CArtikul);
           System.Delete(ws,Pos(separatorChar,ws)+1,CArtikul+1);
           ws:=sArt+SeparatorChar+ws;
         end;
         Zakupka:=Copy(ws,1+CArtikul+1+(CNAme+1+CNAme)+1,CKol);
         RazdelKol:=RazdelKol+StrToInt(Zakupka);
         AllKol:=AllKol+StrToInt(Zakupka);


         While Pos(SeparatorChar,ws)>0 Do
          Begin
           ws[Pos(SeparatorChar,ws)]:=' ';
          End;

         writeln(t,space+' '+ws);{+'!'+Zakupka+'@'+Copy(ws,1+CArtikul+1+(CNAme+1+CNAme)+1+CKol+1+(CKOl+1)*KolOtdel,CZenaZ));}
         RazdelSumma:=RazdelSumma+
	    StrToInt(Zakupka)*
	    StrToReal(Copy(ws,1+CArtikul+1+(CNAme+1+CNAme)+1+CKol+1+1,
	    CZenaZ));
         AllSumma:=AllSumma+
	    StrToInt(Zakupka)*
	    StrToReal(Copy(ws,1+CArtikul+1+(CNAme+1+CNAme)+1+CKol+1+1,
	    CZenaZ));

         {MemC(Copy(ws,1+CArtikul+1+(CNAme+1+CNAme)+1+CKol+1+(CKOl+1)*KolOtdel+1,
	    CZenaZ));}
        end;{For}

      writeln(t,'                                                ____________________________________________');
      writeln(t,'                                                 �ᥣ�:',RazdelKol:8,'�� �� �㬬�:'+
	 RealToStr(RazdelSumma,CIZena,CMantissaZ)+' ��');
      RazdelKol:=0;
      RazdelSumma:=0;

       TempBox^.NewList(Nil);
       TempBOx^.NewList(New(PTextCollection, Init(0,1)));
      end;
    end;
  End; {for i:=0 to ItogBox^.List^.Count-1}
  NoInfoMsg;

  write(t,space);
  for i:=0 to Length(ws) do write(t,'-');
  writeln(t);
  writeln(t,'                                                 �⮣�:',AllKol:8,'�� �� �㬬�:'+
       RealToStr(AllSumma,CIZena,CMantissaZ)+' ��');
  Writeln(T,Space+'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');

  {Writeln(T,Space+'�⯥�⠭�: "'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');}
  write(t,space);
  for i:=0 to Length(ws) do write(t,'=');

  Dispose(tempBox,Done);
  Dispose(ItogBox,Done);
  writeln(t,Normal[Nprint.Printer]);

  IORez:=ioresult;
  System.Close(t);
  IORez:=ioresult;

  ViewAsText(Path.ToTemp+'ostdate.txt',True);
End;


BEGIN
END.

