{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}

unit ExpImp;

INTERFACE

uses Dialogs;

procedure ExportLinkID;
procedure ExportLinkDb;
procedure ImportLinkID;
procedure ImportLinkDb;


PROCEDURE CalcLink(LinkList:PBox);

IMPLEMENTATION

{$I Compile.INC}
uses Glob,Serv,ServStr,MsgBox,NetDBEng,Net,Utils5,Net1,Views,
     NetCall,DbEngine,Dos,Objects;


VAR Raz: PRazdelType;
    Skl: PSkladType;
    T: text;


Procedure CalcLink(LinkList : PBox);

 var i,IORez: word;
    FS: SkladFileType;
    FR: RazdelFileType;

 Begin
   New(Skl,Init);
   New(Raz,Init);

   Assign(FR,Path^.Dat.ToRazdel+'razdel.db');
   IORez:=0;
   Reset(FR);
   IORez:=IOResult;
   if IORez <> 0 then
     begin
      Dispose(Skl,Done);
      Dispose(Raz,Done);
      Close(t);
      MessageBox(#3^M+#3'Не могу открыть файл '+Path^.Dat.ToRazdel+'razdel.db',Nil,mfError+mfCancelButton);
      exit;
     end;

   {DInfo('Идет идентификация связей товаров и сертификатов ...');}

   while not eof(FR) do
   begin
     Read(FR,Raz^.Dat);
     if (Raz^.Dat.Employ) And (Raz^.Dat.EnableDoc=0) then
     begin
       Assign(FS,Path^.Dat.ToSklad+Raz^.Dat.Kod+'.db');
       IoRez:=0;
       reset(FS);
       IoRez:=IoResult;
       if IORez <> 0 then
       begin
        Close(fr);
        Dispose(Skl,Done);
        Dispose(Raz,Done);
        {NoInfo;}
        MessageBox(#3^M+#3'Не могу открыть файл '+Path^.Dat.ToSklad+Raz^.Dat.Kod+'.db',Nil,mfError+mfCancelButton);
        exit;
       end;

      while not eof(FS) do
       begin
         ReadSklad(FS,Skl^.Dat);
         if (Skl^.Dat.Employ) and (Skl^.Dat.Input.NSertif <> Glob.noSertifStr)
              and (StrToInt(Skl^.Dat.Input.Kol)>0)then
          Begin
           LinkList^.List^.Insert(NewStr('│'+skl^.Dat.Input.NSertif+'│'+skl^.Dat.BazKod));
           LinkList^.SetRange(LinkList^.List^.Count);
          End;
       end;
   IORez:=IOResult;
      close(FS);
   IORez:=IOResult;
     end;
   end;
   {NoInfo;}
   IORez:=IOResult;
   Close(FR);
   IORez:=IOResult;
   Dispose(Skl,Done);
   Dispose(Raz,Done);
 End; {ExportLink}






PROCEDURE ExportLinkID;
Const Separator=';';
var j,i,Count,IORez: word;
    FID: File;
    ID : PBufBazType;
    FR: RazdelFileType;
    s : String;
    SMain,SMarket,
    SEnableDebit,
    SVidNalog,SVidNDS,SRecalc,
    SEnableContract,SOtdel,DVidan,
    SEmploy,SOKP,SBuchGroup,SEnablePrihod,
    SEnableSklads:AllStr;

 Begin
   Assign(T,Path^.Dat.ToUtils+'Linkid.txt');
   IORez:=0;
   Rewrite(T);
   IORez:=IOResult;
   if IORez <> 0 then
     begin
      MessageBox(#3^M+#3'Не могу создать файл '+Path^.Dat.ToUtils+'Linkid.txt',Nil,mfError+mfCancelButton);
      exit;
     end;

   Assign(FR,Path^.Dat.ToRazdel+'razdel.db');
   IORez:=0;
   Reset(FR);
   IORez:=IOResult;
   if IORez <> 0 then
     begin
      Close(t);
      MessageBox(#3^M+#3'Не могу открыть файл '+Path^.Dat.ToRazdel+'razdel.db',Nil,mfError+mfCancelButton);
      exit;
     end;

       Writeln(t,'REM│'+
       +'BazKod'+Separator+
        'FantomKod'+Separator+
	   'Name'+Separator+
        'Name2'+Separator+
        'Litr'+Separator+
        'InPack'+Separator+
        'InPack2'+Separator+
        'Massa'+Separator+
        'Etil'+Separator+
        'Nalog'+Separator+
        'NDS'+Separator+
        'Mera'+Separator+
        'Contract'+Separator+
        'ContractDate'+Separator+
        'DSertif'+Separator+
        'PostKod'+Separator+
        'FirmaPostKod'+Separator+
        'KSertif'+Separator+
        'Caption'+Separator+
        'SMain'+Separator+
        'SMarket'+Separator+
        'SEnableDebit'+Separator+
        'SVidNalog'+Separator+
        'SVidNDS'+Separator+
        'SEnableContract'+Separator+
        'SEmploy'+Separator+
        'SOKP'+Separator+
          'SBuchGroup'+Separator+
          'SEnableSklads'+Separator+
		'NGroupKod'+Separator+
		'SEnablePrihod'+Separator+
		'Marker'+Separator+
		'Min'+Separator+
          'SRecalc'+Separator+
          'SDVidan'+Separator+
		'Class'+Separator+
          'SMetroKod'+Separator+
		'SOtdel');


   New(Raz,Init);

   while not eof(FR) do
   begin
     Read(FR,Raz^.Dat);
     DInfoMsgShkala('Идет экспорт связей ID. Обрабатывается раздел '+Raz^.Dat.Kod+'...',0,FileSize(FR),FilePos(Fr));

     if Raz^.Dat.Employ then
     begin
       Assign(FID,Path^.Dat.ToName+Raz^.Dat.Kod+'.id');
       IoRez:=IoResult;
       reset(FID,SizeOf(BazType));
       IoRez:=IoResult;
       if IORez <> 0 then
       begin
        Close(t);
        IoRez:=IoResult;
        Close(fr);
        Dispose(Raz,Done);
        NoInfoMsg;
        MessageBox(#3^M+#3'Не могу открыть файл '+Path^.Dat.ToName+Raz^.Dat.Kod+'.id',Nil,mfError+mfCancelButton);
        exit;
       end;

       while not eof(FID) do
        begin
         New(Id,Init);
         Count:=0;
         ReadBufBaz(FID,Id,Count);
         For j:=1 To Count Do
          Begin
            With Id^.Point.Dat[j] Do
            Begin
            If (Id^.Point.Dat[j].Employ) Then
             begin

          Format(Name,CNAme);
          Format(Name2,CNAme);
          Format(Litr,CLitr);
          Format(InPack,CInPack);
          Format(InPack2,CInPack);
          Format(Massa,CMAssa);
          Format(Etil,CLitr);
          Format(Nalog,CLitr);
          Format(NDS,CLitr);
          Format(Marker,CLitrMantissa);
          Format(Min,CArtikul);
          RFormatZerro(Mera,CClientKod);
          RFormatZerro(NGroupKod,CClientKod);
          Format(Contract,CContract);
          Format(ContractDate,CDate);
          Format(DSertif,CDate);
          Format(DVidan,CDate);
          RFormatZerro(BazKod,CArtikul);
          RFormatZerro(FantomKod,CArtikul);
          RFormatZerro(PostKod,CClientKod);
          RFormatZerro(FirmaPostKod,CClientKod);
          RFormatZerro(KSertif,CClientKod);
          RFormatZerro(Class,CClientKod);
          RFormatZerro(Caption,CRazdelKod);
          RFormatZerro(MetroKod,CMetroKod);
          SMain  :=IntToStr(Main,COne);
          SMarket:=IntToStr(Market,COne);
          SEnableDebit:=IntToStr(EnableDebit,COne);
          SVidNalog:=IntToStr(VidNalog,COne);
          SVidNDS  :=IntToStr(VidNDS,COne);
          SOtdel   :=IntToStr(Otdel,CArtikul);
          SEnableContract:=IntToStr(EnableContract,COne);
          If Employ Then SEmploy:='1' Else SEmploy:='0';
          SOKP   :=IntToStr(OKP,9);
          SBuchGroup :=IntToStr(BuchGroup,9);
          SEnableSklads:=IntToStr(EnableSklads,10);
          Format(SOKP,9);
          Format(SBuchGroup,9);
          Format(SEnableSklads,10);
          Format(SOtdel,CArtikul);
          SEnablePrihod:=IntToStr(EnablePrihod,COne);
          SRecalc:=IntToStr(Recalc,COne);


       s:='│'+
	     BazKod+Separator+
          FantomKod+Separator+
	     Name+Separator+
          Name2+Separator+
          Litr+Separator+
          InPack+Separator+
          InPack2+Separator+
          Massa+Separator+
          Etil+Separator+
          Nalog+Separator+
          NDS+Separator+
          Mera+Separator+
          Contract+Separator+
          ContractDate+Separator+
          DSertif+Separator+
          PostKod+Separator+
          FirmaPostKod+Separator+
          KSertif+Separator+
          Caption+Separator+
          SMain+Separator+
          SMarket+Separator+
          SEnableDebit+Separator+
          SVidNalog+Separator+
          SVidNDS+Separator+
          SEnableContract+Separator+
          SEmploy+Separator+
          SOKP+Separator+
          SBuchGroup+Separator+
          SEnableSklads+Separator+
		NGroupKod+Separator+
		SEnablePrihod+Separator+
		Marker+Separator+
		Min+Separator+
		SRecalc+Separator+
          DVidan+Separator+
		Class+Separator+
		MetroKod+Separator+
		SOtdel;

          WriteLn(t,s);


             End;{If Employ}
            End;{With}
          End;{For}
         Dispose(Id,Done);
       end;{}
      IoRez:=IoResult;
      close(FID);
      IoRez:=IoResult;
     end;
   end;
   NoInfoMsg;
      IoRez:=IoResult;
   Close(FR);
      IoRez:=IoResult;
   Close(T);
      IoRez:=IoResult;
   Dispose(Raz,Done);
   AddProtocol('Экспорт связей ID',Path^.Dat.ToUtils+'Linkid.txt','');
   MessageBox(^M+#3'Операция успешно завершена!'+^M+
   #3+'Данные экспортированы в '+Path^.Dat.ToUtils+'Linkid.txt',Nil,mfInformation+mfCancelButton);
 End; {ExportLink}




Function WriteNameID(Element:BazType):Boolean;
Var f : File Of BazType;
    c : LongInt;
    s : BazType;
  Nam : ArtikulStr;
Begin
WriteNameID:=False;

 DelSpace(Element.BazKod);
 NAm :=Copy(Element.BazKod,1,CRazdelKod);

  Assign(f,Path^.Dat.ToName+Nam+'.id');
  c:=IOResult;
  Reset(f);
  c:=IOResult;
  If c<>0 Then
   Begin
    Exit;
   End;

   Nam:=Copy(Element.BazKod,1+CRazdelKod,CKod);
   c:=StrToInt(Nam);

   If c>FileSize(f) Then
    Begin
     c:=IOResult;
     System.Close(f);
     c:=IOResult;
     Exit;
    End;

   Seek(f,c);
   c:=IOResult;

   Write(f,Element);
   c:=IOResult;

   Close(f);
   c:=IOResult;
   WriteNameID:=True;
   c:=IOResult;
End;


Function WriteNameDB(Element:SkladType):Boolean;
Var f : File Of SkladType;
    c : LongInt;
    s : SkladType;
  Nam : ArtikulStr;
Begin
WriteNameDB:=False;

 DelSpace(Element.BazKod);
 NAm :=Copy(Element.BazKod,1,CRazdelKod);

  Assign(f,Path^.Dat.ToSklad+Nam+'.db');
  c:=IOResult;
  Reset(f);
  c:=IOResult;
  If c<>0 Then
   Begin
    Exit;
   End;

   Nam:=Copy(Element.BazKod,1+CRazdelKod,CKod);
   c:=StrToInt(Nam);

   If c>FileSize(f) Then
    Begin
     c:=IOResult;
     System.Close(f);
     c:=IOResult;
     Exit;
    End;

   Seek(f,c);
   c:=IOResult;

   Write(f,Element);
   c:=IOResult;

   Close(f);
   c:=IOResult;
   WriteNameDB:=True;
   c:=IOResult;
End;


PROCEDURE ImportLinkID;
var j,i,c,IORez: word;
    s : String;
    E : PBazType;
    Count1,Count : LongInt;

 Begin
   Assign(T,Path^.Dat.ToUtils+'Linkid.txt');
   IORez:=0;
   Reset(T);
   IORez:=IOResult;
   if IORez <> 0 then
     begin
      MessageBox(#3^M+#3'Не могу открыть файл '+Path^.Dat.ToUtils+'Linkid.txt',Nil,mfError+mfCancelButton);
      exit;
     end;

   Count:=0;

   while not eof(t) do
   begin
    Readln(t,s);
    DelSpaceRight(s);
    If s[0]<>#0 Then
    If (Not(Pos('REM',s)=1)) And (Not(Pos(';',s)=1))  Then
    Begin
     Inc(Count);
    End;
   End;

   IORez:=0;
   Close(T);
   IORez:=IOResult;

   IORez:=0;
   Reset(T);
   IORez:=IOResult;

   {DInfoMsg('Идет импорт связей ID ...',False);}
   Count1:=0;
   while not eof(t) do
   begin
    Readln(t,s);

    DelSpaceRight(s);
    If s[0]<>#0 Then
    If (Not(Pos('REM',s)=1)) And (Not(Pos(';',s)=1))  Then
    Begin
    Inc(Count1);
    DInfoMsgShkala('Идет импорт связей ID ...',0,Count,Count1);

  New(E,Init);
  E^.Dat.BazKod:=Copy(s,1+1,CArtikul);

  If GetBazElementS(E^.Dat.BazKod,E^.Dat) Then
  If E^.Dat.Employ Then
  Begin
  With E^.Dat Do
   Begin
    BazKod:=Copy(s,1+1,CArtikul);
    RFormatZerro(BazKod,CArtikul);
    FantomKod:=Copy(s,1+1+CArtikul+1,CArtikul);
    RFormatZerro(FantomKod,CArtikul);
    Name:=Copy(s,1+1+CArtikul+1+CArtikul+1,CName);
    DelSpaceRight(Name);
    Name2:=Copy(s,1+1+CArtikul+1+CArtikul+1+CName+1,CName);
    DelSpaceRight(Name2);
    Litr:=Copy(s,1+1+CArtikul+1+CArtikul+1+CName+1+CName+1,CLitr);
    DelSpaceRight(Litr);
    InPAck:=Copy(s,1+1+CArtikul+1+CArtikul+1+CName+1+CName+1+CLitr+1,CInPack);
    DelSpaceRight(InPack);
    InPAck2:=Copy(s,1+1+CArtikul+1+CArtikul+1+CName+1+CName+1+CLitr+1+CInPack+1,CInPack);
    DelSpaceRight(InPack2);
    Massa:=Copy(s,1+1+CArtikul+1+CArtikul+1+CName+1+CName+1+CLitr+1+CInPack+1+CInPack+1,CMassa);
    DelSpaceRight(Massa);
    Etil:=Copy(s,1+1+CArtikul+1+CArtikul+1+CName+1+CName+1+CLitr+1+CInPack+1+CInPack+1+CMassa+1,CLitr);
    DelSpaceRight(Etil);
    Nalog:=Copy(s,1+1+CArtikul+1+CArtikul+1+CName+1+CName+1+CLitr+1+CInPack+1+CInPack+1+CMassa+1+CLitr+1,CLitr);
    DelSpaceRight(Nalog);
    NDS:=Copy(s,1+1+CArtikul+1+CArtikul+1+CName+1+CName+1+CLitr+1+CInPack+1+CInPack+1+CMassa+1+CLitr+1+CLitr+1,CLitr);
    DelSpaceRight(NDS);
    Mera:=Copy(s,1+1+CArtikul+1+CArtikul+1+CName+1+CName+1+CLitr+1+CInPack+1+CInPack+1+CMassa+1+CLitr+1+CLitr+1+CLitr+1,
    CClientKod);
    DelSpaceRight(Mera);
    RFormatZerro(Mera,CClientKod);
    Contract:=Copy(s,1+1+CArtikul+1+CArtikul+1+CName+1+CName+1+CLitr+1+CInPack+1+CInPack+1+CMassa+1+CLitr+1+CLitr+1+
    CLitr+1+CClientKod+1,CContract);
    DelSpaceRight(Contract);
    ContractDate:=Copy(s,1+1+CArtikul+1+CArtikul+1+CName+1+CName+1+CLitr+1+CInPack+1+CInPack+1+CMassa+1+CLitr+1+CLitr+1+
    CLitr+1+CClientKod+1+CContract+1,CDate);
    DelSpaceRight(ContractDate);
    DSertif:=Copy(s,1+1+CArtikul+1+CArtikul+1+CName+1+CName+1+CLitr+1+CInPack+1+CInPack+1+CMassa+1+CLitr+1+CLitr+1+CLitr+1+
    CClientKod+1+CContract+1+CDate+1,CDate);
    DelSpaceRight(DSertif);
    PostKod:=Copy(s,1+1+CArtikul+1+CArtikul+1+CName+1+CName+1+CLitr+1+CInPack+1+CInPack+1+CMassa+1+CLitr+1+CLitr+1+CLitr+1+
    CClientKod+1+CContract+1+CDate+1+CDate+1,CClientKod);
    RFormatZerro(PostKod,CClientKod);

    FirmaPostKod:=Copy(s,1+1+CArtikul+1+CArtikul+1+CName+1+CName+1+CLitr+1+CInPack+1+CInPack+1+CMassa+1+CLitr+1+CLitr+1+CLitr+
    1+CClientKod+1+CContract+1+CDate+1+CDate+1+CClientKod+1,CClientKod);
    RFormatZerro(FirmaPostKod,CClientKod);

    KSertif:=Copy(s,1+1+CArtikul+1+CArtikul+1+CName+1+CName+1+CLitr+1+CInPack+1+CInPack+1+CMassa+1+CLitr+1+CLitr+1+CLitr+
    1+CClientKod+1+CContract+1+CDate+1+CDate+1+CClientKod+1+CClientKod+1,CClientKod);
    RFormatZerro(KSertif,CClientKod);

    Caption:=Copy(s,1+1+CArtikul+1+CArtikul+1+CName+1+CName+1+CLitr+1+CInPack+1+CInPack+1+CMassa+1+CLitr+1+CLitr+1+CLitr+
    1+CClientKod+1+CContract+1+CDate+1+CDate+1+CClientKod+1+CClientKod+1+CClientKod+1,CRazdelKod);
{
    Caption:=Copy(s,1+1+CArtikul+1+CArtikul+1+CName+1+CName+1+CLitr+1+CInPack+1+CInPack+1+CMassa+1+CLitr+1+CLitr+1+CLitr+
    1+CClientKod+1+CContract+1+CDate+1+CDate+1+CClientKod+1+CClientKod+1+CClientKod+1,CRazdelKod);
}
    Main:=StrToInt(Copy(s,1+1+CArtikul+1+CArtikul+1+CName+1+CName+1+CLitr+1+CInPack+1+CInPack+1+CMassa+1+CLitr+1+CLitr+1+CLitr+
    1+CClientKod+1+CContract+1+CDate+1+CDate+1+CClientKod+1+CClientKod+1+CClientKod+1+CRazdelKod+1,COne));

    Market:=StrToInt(Copy(s,1+1+CArtikul+1+CArtikul+1+CName+1+CName+1+CLitr+1+CInPack+1+CInPack+1+CMassa+1+CLitr+1+CLitr+1+
    CLitr+1+CClientKod+1+CContract+1+CDate+1+CDate+1+CClientKod+1+CClientKod+1+CClientKod+1+CRazdelKod+1+COne+1,COne));

    EnableDebit:=StrToInt(Copy(s,1+1+CArtikul+1+CArtikul+1+CName+1+CName+1+CLitr+1+CInPack+1+CInPack+1+CMassa+1+CLitr+1+
    CLitr+1+CLitr+1+CClientKod+1+CContract+1+CDate+1+CDate+1+CClientKod+1+CClientKod+1+CClientKod+1+CRazdelKod+1+COne+1+COne+1,
    COne));

    VidNalog:=StrToInt(Copy(s,1+1+CArtikul+1+CArtikul+1+CName+1+CName+1+CLitr+1+CInPack+1+CInPack+1+CMassa+1+CLitr+1+CLitr+1+
    CLitr+1+CClientKod+1+CContract+1+CDate+1+CDate+1+CClientKod+1+CClientKod+1+CClientKod+1+CRazdelKod+1+COne+1+COne+1+COne+1,
    COne));

    VidNDS:=StrToInt(Copy(s,1+1+CArtikul+1+CArtikul+1+CName+1+CName+1+CLitr+1+CInPack+1+CInPack+1+CMassa+1+CLitr+1+CLitr+1+
    CLitr+1+CClientKod+1+CContract+1+CDate+1+CDate+1+CClientKod+1+CClientKod+1+CClientKod+1+CRazdelKod+1+COne+1+COne+1+COne+1+
    COne+1,COne));

    EnableContract:=StrToInt(Copy(s,1+1+CArtikul+1+CArtikul+1+CName+1+CName+1+CLitr+1+CInPack+1+CInPack+1+CMassa+1+CLitr+1+
    CLitr+1+CLitr+1+CClientKod+1+CContract+1+CDate+1+CDate+1+CClientKod+1+CClientKod+1+CClientKod+1+CRazdelKod+1+COne+1+COne+1+
    COne+1+COne+1+COne+1,COne));

{ отключен импорт
    If StrToInt(Copy(s,1+1+CArtikul+1+CArtikul+1+CName+1+CName+1+CLitr+1+CInPack+1+CInPack+1+CMassa+1+CLitr+1+
    CLitr+1+CLitr+1+CClientKod+1+CContract+1+CDate+1+CDate+1+CClientKod+1+CClientKod+1+CClientKod+1+CRazdelKod+1+COne+1+COne+1+
    COne+1+COne+1+COne+1+COne+1,COne))=1 Then Employ:=True
    Else Employ:=False;
}
    OKP:=StrToInt(Copy(s,1+1+CArtikul+1+CArtikul+1+CName+1+CName+1+CLitr+1+CInPack+1+CInPack+1+CMassa+1+CLitr+1+
    CLitr+1+CLitr+1+CClientKod+1+CContract+1+CDate+1+CDate+1+CClientKod+1+CClientKod+1+CClientKod+1+CRazdelKod+1+COne+1+COne+1+
    COne+1+COne+1+COne+1+COne+1+COne+1,9));

    BuchGroup:=StrToInt(Copy(s,1+1+CArtikul+1+CArtikul+1+CName+1+CName+1+CLitr+1+CInPack+1+CInPack+1+CMassa+1+CLitr+1+
    CLitr+1+CLitr+1+CClientKod+1+CContract+1+CDate+1+CDate+1+CClientKod+1+CClientKod+1+CClientKod+1+CRazdelKod+1+COne+1+COne+1+
    COne+1+COne+1+COne+1+COne+1+COne+1+9+1,9));

    EnableSklads:=StrToInt(Copy(s,1+1+CArtikul+1+CArtikul+1+CName+1+CName+1+CLitr+1+CInPack+1+CInPack+1+CMassa+1+CLitr+1+
    CLitr+1+CLitr+1+CClientKod+1+CContract+1+CDate+1+CDate+1+CClientKod+1+CClientKod+1+CClientKod+1+CRazdelKod+1+COne+1+COne+1+
    COne+1+COne+1+COne+1+COne+1+COne+1+9+1+9+1,10));

    NGroupKod:=Copy(s,1+1+CArtikul+1+CArtikul+1+CName+1+CName+1+CLitr+1+CInPack+1+CInPack+1+CMassa+1+CLitr+1+
    CLitr+1+CLitr+1+CClientKod+1+CContract+1+CDate+1+CDate+1+CClientKod+1+CClientKod+1+CClientKod+1+CRazdelKod+1+COne+1+COne+1+
    COne+1+COne+1+COne+1+COne+1+COne+1+9+1+9+1+10+1,CClientKod);
    RFormatZerro(NGroupKod,CClientKod);

    Prihod:=StrToInt(Copy(s,1+1+CArtikul+1+CArtikul+1+CName+1+CName+1+CLitr+1+CInPack+1+CInPack+1+CMassa+1+CLitr+1+
    CLitr+1+CLitr+1+CClientKod+1+CContract+1+CDate+1+CDate+1+CClientKod+1+CClientKod+1+CClientKod+1+CRazdelKod+1+COne+1+COne+1+
    COne+1+COne+1+COne+1+COne+1+COne+1+9+1+9+1+10+1+CClientKod+1,COne));

    Marker:=Copy(s,1+1+CArtikul+1+CArtikul+1+CName+1+CName+1+CLitr+1+CInPack+1+CInPack+1+CMassa+1+CLitr+1+
    CLitr+1+CLitr+1+CClientKod+1+CContract+1+CDate+1+CDate+1+CClientKod+1+CClientKod+1+CClientKod+1+CRazdelKod+1+COne+1+COne+1+
    COne+1+COne+1+COne+1+COne+1+COne+1+9+1+9+1+10+1+CClientKod+1+COne+1,CLitrMantissa);
    DelSpaceRight(Marker);

    Min:=Copy(s,1+1+CArtikul+1+CArtikul+1+CName+1+CName+1+CLitr+1+CInPack+1+CInPack+1+CMassa+1+CLitr+1+
    CLitr+1+CLitr+1+CClientKod+1+CContract+1+CDate+1+CDate+1+CClientKod+1+CClientKod+1+CClientKod+1+CRazdelKod+1+COne+1+COne+1+
    COne+1+COne+1+COne+1+COne+1+COne+1+9+1+9+1+10+1+CClientKod+1+COne+1+CLitrMantissa+1,CArtikul);
    DelSpaceRight(Min);

    Recalc:=StrToInt(
    Copy(s,1+1+CArtikul+1+CArtikul+1+CName+1+CName+1+CLitr+1+CInPack+1+CInPack+1+CMassa+1+CLitr+1+
    CLitr+1+CLitr+1+CClientKod+1+CContract+1+CDate+1+CDate+1+CClientKod+1+CClientKod+1+CClientKod+1+CRazdelKod+1+COne+1+COne+1+
    COne+1+COne+1+COne+1+COne+1+COne+1+9+1+9+1+10+1+CClientKod+1+COne+1+CLitrMantissa+1+CArtikul+1,COne));

    DVidan:=Copy(s,1+1+CArtikul+1+CArtikul+1+CName+1+CName+1+CLitr+1+CInPack+1+CInPack+1+CMassa+1+CLitr+1+
    CLitr+1+CLitr+1+CClientKod+1+CContract+1+CDate+1+CDate+1+CClientKod+1+CClientKod+1+CClientKod+1+CRazdelKod+1+COne+1+COne+1+
    COne+1+COne+1+COne+1+COne+1+COne+1+9+1+9+1+10+1+CClientKod+1+COne+1+CLitrMantissa+1+CArtikul+1+COne+1,CDate);

    Class:=Copy(s,1+1+CArtikul+1+CArtikul+1+CName+1+CName+1+CLitr+1+CInPack+1+CInPack+1+CMassa+1+CLitr+1+
    CLitr+1+CLitr+1+CClientKod+1+CContract+1+CDate+1+CDate+1+CClientKod+1+CClientKod+1+CClientKod+1+CRazdelKod+1+COne+1+COne+1+
    COne+1+COne+1+COne+1+COne+1+COne+1+9+1+9+1+10+1+CClientKod+1+COne+1+CLitrMantissa+1+CArtikul+1+COne+1+CDate+1,CClientKod);

    MetroKod:=Copy(s,1+1+CArtikul+1+CArtikul+1+CName+1+CName+1+CLitr+1+CInPack+1+CInPack+1+CMassa+1+CLitr+1+
    CLitr+1+CLitr+1+CClientKod+1+CContract+1+CDate+1+CDate+1+CClientKod+1+CClientKod+1+CClientKod+1+CRazdelKod+1+COne+1+COne+1+
    COne+1+COne+1+COne+1+COne+1+COne+1+9+1+9+1+10+1+CClientKod+1+COne+1+CLitrMantissa+1+CArtikul+1+COne+1+CDAte+1+
    CClientKod+1,CMetroKod);

    Otdel:=StrToInt(Copy(s,1+1+CArtikul+1+CArtikul+1+CName+1+CName+1+CLitr+1+CInPack+1+CInPack+1+CMassa+1+CLitr+1+
    CLitr+1+CLitr+1+CClientKod+1+CContract+1+CDate+1+CDate+1+CClientKod+1+CClientKod+1+CClientKod+1+CRazdelKod+1+COne+1+COne+1+
    COne+1+COne+1+COne+1+COne+1+COne+1+9+1+9+1+10+1+CClientKod+1+COne+1+CLitrMantissa+1+CArtikul+1+COne+1+CDAte+1+
    CClientKod+1+CMetroKod+1,CArtikul));

   End;
   WriteNameID(E^.Dat);
 End;

   Dispose(E,Done);
   End;

 End;{While}

   IORez:=IOResult;
   Close(T);
   IORez:=IOResult;
   NoInfoMsg;

   AddProtocol('Импорт связей ID ',Path^.Dat.ToUtils+'Linkid.txt','');

   If MessageBox(#3'Операция успешно завершена!'+^M+
   #3+'Данные импортированы!'+^M+#3'Провести автоматическую переиндексацию товаров?',Nil,mfInformation+mfOkCancel)=cmOk Then
    Begin
     CreatIDXAuto;
    End;
End; {ImportLinkID}




PROCEDURE ImportLinkDB;
var j,i,c,IORez: word;
    s : String;
    E : PSkladType;
    Count1,Count : LongInt;

 Begin
   Assign(T,Path^.Dat.ToUtils+'Linkdb.txt');
   IORez:=0;
   Reset(T);
   IORez:=IOResult;
   if IORez <> 0 then
     begin
      MessageBox(#3^M+#3'Не могу открыть файл '+Path^.Dat.ToUtils+'Linkdb.txt',Nil,mfError+mfCancelButton);
      exit;
     end;

   Count:=0;

   while not eof(t) do
   begin
    Readln(t,s);
    DelSpaceRight(s);
    If s[0]<>#0 Then
    If (Not(Pos('REM',s)=1)) And (Not(Pos(';',s)=1))  Then
    Begin
     Inc(Count);
    End;
   End;

   IORez:=0;
   Close(T);
   IORez:=IOResult;

   Reset(T);
   IORez:=IOResult;

   {DInfoMsg('Идет импорт связей DB ...',False);}
   Count1:=0;
   while not eof(t) do
   begin
    Readln(t,s);

    DelSpaceRight(s);
    If s[0]<>#0 Then
    If (Not(Pos('REM',s)=1)) And (Not(Pos(';',s)=1))  Then
    Begin
    Inc(Count1);
    DInfoMsgShkala('Идет импорт связей DB ...',0,Count,Count1);

  New(E,Init);
  {Writeln(s);}
  E^.Dat.BazKod:=Copy(s,1+1,CArtikul);
  {Writeln(E^.Dat.BazKod);}

  If GetSkladRecordS(E) Then
  If E^.Dat.Employ Then
  Begin

  With E^.Dat Do
   Begin
    BazKod:=Copy(s,1+1,CArtikul);
    RFormatZerro(BazKod,CArtikul);
    MakeKod:=Copy(s,1+1+CArtikul+1,CClientKod);
    RFormatZerro(MakeKod,CClientKod);
    MakeVid:=StrToInt(Copy(s,1+1+CArtikul+1+CClientKod+1,COne));
    Input.USD:=StrToInt(Copy(s,1+1+CArtikul+1+CClientKod+1+COne+1,COne));
    Input.RegionMarka:=
               StrToInt(Copy(s,1+1+CArtikul+1+CClientKod+1+COne+1+COne+1,COne));
    EnableDebit:=
               StrToInt(Copy(s,1+1+CArtikul+1+CClientKod+1+COne+1+COne+1+COne+1,COne));
{
   If StrToInt(Copy(s,1+1+CArtikul+1+CClientKod+1+COne+1+COne+1+COne+1+COne+1,COne))=1 Then Employ:=True
   Else Employ:=False;
}
    Input.NGTD:=Copy(s,1+1+CArtikul+1+CClientKod+1+COne+1+COne+1+COne+1+COne+1+COne+1,CArtikul);
    RFormatZerro(Input.NGTD,CArtikul);
    Input.Marka:=
                Copy(s,1+1+CArtikul+1+CClientKod+1+COne+1+COne+1+COne+1+COne+1+COne+1+CArtikul+1,CArtikul);
    RFormatZerro(Input.Marka,CArtikul);
    Input.SpecMarka:=
                Copy(s,1+1+CArtikul+1+CClientKod+1+COne+1+COne+1+COne+1+COne+1+COne+1+CArtikul+1+CArtikul+1,CArtikul);
    RFormatZerro(Input.SpecMarka,CArtikul);
    Input.Expert:=
                Copy(s,1+1+CArtikul+1+CClientKod+1+COne+1+COne+1+COne+1+COne+1+COne+1+CArtikul+1+CArtikul+1+CArtikul+1,
			 CArtikul);
    RFormatZerro(Input.Expert,CArtikul);
    Input.NSertif:=
                Copy(s,1+1+CArtikul+1+CClientKod+1+COne+1+COne+1+COne+1+COne+1+COne+1+CArtikul+1+CArtikul+1+CArtikul+1+
			 CArtikul+1,CArtikul);
    RFormatZerro(Input.NSertif,CArtikul);

    Input.NMakeKod:=
                Copy(s,1+1+CArtikul+1+CClientKod+1+COne+1+COne+1+COne+1+COne+1+COne+1+CArtikul+1+CArtikul+1+CArtikul+1+
			 CArtikul+1+CArtikul+1,CArtikul);
    RFormatZerro(Input.NMakeKod,CArtikul);

    Input.StrihKod:=
                Copy(s,1+1+CArtikul+1+CClientKod+1+COne+1+COne+1+COne+1+COne+1+COne+1+CArtikul+1+CArtikul+1+CArtikul+1+
			 CArtikul+1+CArtikul+1+CArtikul+1,CStrihKod);
    DelSpace(Input.StrihKod);

    Input.GRZena:=
                Copy(s,1+1+CArtikul+1+CClientKod+1+COne+1+COne+1+COne+1+COne+1+COne+1+CArtikul+1+CArtikul+1+CArtikul+1+
			 CArtikul+1+CArtikul+1+CArtikul+1+CStrihKod+1,CZenaZ);
    DelSpace(Input.GRZena);

    Input.Proz:=
                Copy(s,1+1+CArtikul+1+CClientKod+1+COne+1+COne+1+COne+1+COne+1+COne+1+CArtikul+1+CArtikul+1+CArtikul+1+
			 CArtikul+1+CArtikul+1+CArtikul+1+CStrihKod+1+CZenaZ+1,CLitr);
    DelSpace(Input.Proz);

    Input.ZenaMarki:=
                Copy(s,1+1+CArtikul+1+CClientKod+1+COne+1+COne+1+COne+1+COne+1+COne+1+CArtikul+1+CArtikul+1+CArtikul+1+
			 CArtikul+1+CArtikul+1+CArtikul+1+CStrihKod+1+CZenaZ+1+CLitr+1,CZenaZ);
    DelSpace(Input.ZenaMarki);

    Input.AkzisSbor:=
                Copy(s,1+1+CArtikul+1+CClientKod+1+COne+1+COne+1+COne+1+COne+1+COne+1+CArtikul+1+CArtikul+1+CArtikul+1+
			 CArtikul+1+CArtikul+1+CArtikul+1+CStrihKod+1+CZenaZ+1+CLitr+1+CZenaZ+1,CZenaZ);
    DelSpace(Input.AkzisSbor);

    Input.Virabotano:=
                Copy(s,1+1+CArtikul+1+CClientKod+1+COne+1+COne+1+COne+1+COne+1+COne+1+CArtikul+1+CArtikul+1+CArtikul+1+
			 CArtikul+1+CArtikul+1+CArtikul+1+CStrihKod+1+CZenaZ+1+CLitr+1+CZenaZ+1+CZenaZ+1,CDate);
    DelSpace(Input.Virabotano);

    Input.Godnost:=
                Copy(s,1+1+CArtikul+1+CClientKod+1+COne+1+COne+1+COne+1+COne+1+COne+1+CArtikul+1+CArtikul+1+CArtikul+1+
			 CArtikul+1+CArtikul+1+CArtikul+1+CStrihKod+1+CZenaZ+1+CLitr+1+CZenaZ+1+CZenaZ+1+CDate+1,CDate);
    DelSpace(Input.Godnost);
   End;{With}

   WriteNameDB(E^.Dat);
   End;{If}


   Dispose(E,Done);
 End;{If}

 End;{While}

   IORez:=IOResult;
   Close(T);
   IORez:=IOResult;
   NoInfoMsg;

   AddProtocol('Импорт связей DB ',Path^.Dat.ToUtils+'Linkdb.txt','');

   If MessageBox(#3'Операция успешно завершена!'+^M+
   #3+'Данные импортированы!'+^M+#3'Провести автоматическую переиндексацию товаров?',Nil,mfInformation+mfOkCancel)=cmOk Then
    Begin
     CreatIDXAuto;
    End;
End; {ImportLinkDB}



PROCEDURE ExportLinkDB;
Const Separator=';';
var j,i,Count,IORez: word;
    FID: File;
    ID : PBufSkladType;
    FR: RazdelFileType;
    s : String;
    SMain,SMarket,
    SEnableDebit,
    SMakeVid,SUSD,
    SVidNalog,SVidNDS,
    SRegion,
    SEnableContract,
    SEmploy,SOKP,SBuchGroup,SEnablePrihod,
    SEnableSklads:AllStr;

 Begin
   Assign(T,Path^.Dat.ToUtils+'Linkdb.txt');
   IORez:=0;
   Rewrite(T);
   IORez:=IOResult;
   if IORez <> 0 then
     begin
      MessageBox(#3^M+#3'Не могу создать файл '+Path^.Dat.ToUtils+'Linkdb.txt',Nil,mfError+mfCancelButton);
      exit;
     end;

   Assign(FR,Path^.Dat.ToRazdel+'razdel.db');
   IORez:=0;
   Reset(FR);
   IORez:=IOResult;
   if IORez <> 0 then
     begin
      Close(t);
      MessageBox(#3^M+#3'Не могу открыть файл '+Path^.Dat.ToRazdel+'razdel.db',Nil,mfError+mfCancelButton);
      exit;
     end;

   New(Raz,Init);

   Writeln(t,'REM│'+
	     'BazKod'+Separator+
          'MakeKod'+Separator+
          'SMakeVid'+Separator+
          'SUSD'+Separator+
	     'SRegion'+Separator+
          'SEnableDebit'+Separator+
          'SEmploy'+Separator+
          'Input.NGTD'+Separator+
          'Input.Marka'+Separator+
          'Input.SpecMarka'+Separator+
          'Input.Expert'+Separator+
          'Input.NSertif'+Separator+
          'Input.NMakeKod'+Separator+
          'Input.StrihKod'+Separator+
          'Input.GRZena'+Separator+
          'Input.Proz'+Separator+
          'Input.ZenaMarki'+Separator+
          'Input.AkzisSbor'+Separator+
          'Input.Virabotano'+Separator+
          'Input.Godnost');



   while not eof(FR) do
   begin
     Read(FR,Raz^.Dat);
     DInfoMsgShkala('Идет экспорт связей DB. Обрабатывается раздел '+Raz^.Dat.Kod+'...',0,FileSize(FR),FilePos(Fr));

     if Raz^.Dat.Employ then
     begin
       Assign(FID,Path^.Dat.ToSklad+Raz^.Dat.Kod+'.db');
       IoRez:=IoResult;
       reset(FID,SizeOf(SkladType));
       IoRez:=IoResult;
       if IORez <> 0 then
       begin
        Close(t);
        IoRez:=IoResult;
        Close(fr);
        Dispose(Raz,Done);
        NoInfoMsg;
        MessageBox(#3^M+#3'Не могу открыть файл '+Path^.Dat.ToSklad+Raz^.Dat.Kod+'.db',Nil,mfError+mfCancelButton);
        exit;
       end;

       while not eof(FID) do
        begin
         New(Id,Init);
         Count:=0;
         ReadBufSklad(FID,Id,Count);
         For j:=1 To Count Do
          Begin
            With Id^.Point.Dat[j] Do
            Begin
            If (Id^.Point.Dat[j].Employ) Then
             begin

          RFormatZerro(BazKod,CArtikul);
          RFormatZerro(MakeKod,CClientKod);
          SMakeVid  :=IntToStr(MakeVid,COne);
          SUSD  :=IntToStr(Input.USD,COne);
          SRegion :=IntToStr(Input.RegionMarka,COne);
          SEnableDebit  :=IntToStr(EnableDebit,COne);
          If Employ Then SEmploy:='1' Else SEmploy:='0';

          RFormatZerro(Input.NGTD,CArtikul);
          RFormatZerro(Input.NMakeKod,CArtikul);
   	     RFormatZerro(Input.Marka,CArtikul);
          RFormatZerro(Input.SpecMarka,CArtikul);
          RFormatZerro(Input.Expert,CArtikul);
	     RFormatZerro(Input.NSertif,CArtikul);
	     RFormatZerro(Input.NMakeKod,CArtikul);
          Format(Input.StrihKod,CStrihKod);
          Format(Input.GRZena,CZenaZ);
          Format(Input.ZenaMarki,CZenaZ);
          Format(Input.AkzisSbor,CZenaZ);
          Format(Input.Proz,CLitr);
          Format(Input.Virabotano,CDate);
          Format(Input.Godnost,CDate);

       s:='│'+
	     BazKod+Separator+
          MakeKod+Separator+
          SMakeVid+Separator+
          SUSD+Separator+
	     SRegion+Separator+
          SEnableDebit+Separator+
          SEmploy+Separator+
          Input.NGTD+Separator+
          Input.Marka+Separator+
          Input.SpecMarka+Separator+
          Input.Expert+Separator+
          Input.NSertif+Separator+
          Input.NMakeKod+Separator+
          Input.StrihKod+Separator+
          Input.GRZena+Separator+
          Input.Proz+Separator+
          Input.ZenaMarki+Separator+
          Input.AkzisSbor+Separator+
          Input.Virabotano+Separator+
          Input.Godnost;

          WriteLn(t,s);


             End;{If Employ}
            End;{With}
          End;{For}
         Dispose(Id,Done);
       end;{}
      IoRez:=IoResult;
      close(FID);
      IoRez:=IoResult;
     end;
   end;
   NoInfoMsg;
      IoRez:=IoResult;
   Close(FR);
      IoRez:=IoResult;
   Close(T);
      IoRez:=IoResult;
   Dispose(Raz,Done);
   AddProtocol('Экспорт связей DB',Path^.Dat.ToUtils+'Linkdb.txt','');
   MessageBox(^M+#3'Операция успешно завершена!'+^M+
   #3+'Данные экспортированы в '+Path^.Dat.ToUtils+'Linkdb.txt',Nil,mfInformation+mfCancelButton);
 End; {ExportLink}









BEGIN
END.