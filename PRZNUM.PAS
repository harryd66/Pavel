Uses glob,ServStr,Serv;

VAr sklFile : File Of SkladType;
    skl : pSkladType;
    Przf : File Of PereozenkaType;
    Prz : PPereozenkaType;
    RazdelFile : File Of RazdelType;
    RazdelElement : RazdelType;
    RazdelKod : String[2];
    NameKod : String[3];
    F : Boolean;
    PrzCount,c : Word;
    Txt : Text;
    Artikul : ArtikulStr;
    SRZena,SOZena : String[CZena];
    Ok : Boolean;
    ch : Char;

    BazFile : File Of BazType;
    BazElement : PBazType;

Function SetID(C:ArtikulStr;Status:Word): Boolean;
Var l    : LongInt;
    Code : Integer;
    st   : ArtikulStr;
Begin
 st:=c;
 New(BazElement,Init);
 DelSpace(st);
 c:=Copy(st,1,CRazdelKod);
 Assign(BazFile,ParamStr(5)+c+'.id');
 SetID:=False;
 l:=IOResult;
 Reset(BazFile);
 l:=IOResult;
 If l <> 0 Then
 Begin
  Writeln('�訡�� ����� � ����樨 � ����� '+c);
  Readln;
  Exit;
 End
 Else
  Begin
   c:=Copy(st,1+CRazdelKod,CKod);
   L:=StrToInt(C);
   Seek(BazFile,L);
   New(BazElement,Init);
   Read(BazFile,BazElement^.Dat);
   BazElement^.DAt.Market:=1;
   Seek(BazFile,FilePos(BazFile)-1);
   Write(BazFile,BazElement^.Dat);
   Close(BazFile);
   Dispose(BazElement,Done);
   SetID:=True;
  End;
End;

Begin
   If (ParamStr(1)='?') Or (ParamStr(1)='') Then
   Begin
    Writeln('�⨫�� ��㯯���� ��८業��, ��� ࠡ��� ���ன �ॡ����:');
    Writeln(' 1 -��� ᪫��� (�����-0001, ���-0002, ��᭮�� - 0003, �����-0004)');
    Writeln(' 2 -���� � 䠩�� � ������ன "��� 業�"');
    Writeln(' 3 -���� � 䠩��� *.db ������ \');
    Writeln(' 4 -���� � 䠩��� *.prz ������ \');
    Writeln(' 5 -���� � 䠩��� *.id ������ \');
    Writeln(' 6 -Y ��� N �஢����� �������஢���� ��८業����� ����権');
    Halt;
   End;

   Assign(txt,ParamStr(2));
   c:=IOResult;
   Reset(txt);
   c:=IOResult;

If c<>0 Then
 Begin
  Writeln('�訡�� ����㯠 � 䠩�� ������ � ���묨 業���');
  Exit;
 End;

   Assign(PrzF,ParamStr(4)+FDate+'.prz');
   c:=IOResult;
   Reset(PrzF);
   c:=IOResult;
If c<>0 Then
 Begin
   c:=IOResult;
   Rewrite(PrzF);
   c:=IOResult;
   If c<>0 Then
   Begin
    Close(txt);
    Writeln('�।���⥫쭮 ���� ᮧ���� '+ParamStr(4)+FDate+'.prz');
    Exit;
   End;
 End;

   New(Prz,Init);
   Prz^.Dat.Vid:=0;
   Prz^.Dat.Amount:=0;
   Prz^.Dat.SkladKod:=ParamStr(1);
   Prz^.Dat.DateC:=Prz^.Dat.DateM;
   Prz^.Dat.TimeC:=Prz^.Dat.TimeM;

   Str(FileSize(PrzF)+1:CDocNumer,Prz^.Dat.Document);
   DelSpace(Prz^.Dat.Document);
   Seek(PrzF,FileSize(PrzF));

   New(Skl,Init);

   While Not(SeekEof(txt)) Do
    Begin
{������ ��८業�� � 䠩� �᫨ ��� ��������� � ᮧ����� ������ ��������}
       If Prz^.Dat.Amount>=55 Then
       Begin
        Str(StrToReal(Prz^.Dat.Itogo_New_R_Zena)-StrToReal(Prz^.Dat.Itogo_Bak_R_Zena):CIZena:CMantissa
        ,Prz^.Dat.Delta_RZ);
         DelSpace(Prz^.Dat.Delta_RZ);
        Str(StrToReal(Prz^.Dat.Itogo_New_O_Zena)-StrToReal(Prz^.Dat.Itogo_Bak_O_Zena):CIZena:CMantissa
       ,Prz^.Dat.Delta_OZ);
        DelSpace(Prz^.Dat.Delta_OZ);

        Seek(PrzF,FileSize(PrzF));
        Write(PrzF,Prz^.Dat);
        Dispose(Prz,Done);

        New(Prz,Init);
        Prz^.Dat.Vid:=0;
        Prz^.Dat.Amount:=0;
        Prz^.Dat.SkladKod:=ParamStr(1);
        Prz^.Dat.DateC:=Prz^.Dat.DateM;
        Prz^.Dat.TimeC:=Prz^.Dat.TimeM;
        Str(FileSize(PrzF)+1:CDocNumer,Prz^.Dat.Document);
        DelSpace(Prz^.Dat.Document);
        Seek(PrzF,FileSize(PrzF));
       End;

     c:=IOResult;
     Read(txt,Artikul);
     Read(txt,ch);
     ReadLn(txt,SRZena);
     SOZena:=SRZena;

     DelSpace(Artikul);

     If ParamStr(6)='Y' Then
      Begin
       If SetID(Artikul,1) Then Writeln('������ '+Artikul+' �ᯥ譮 �������஢���!')
       Else Writeln('�訡�� �������஢���� '+Artikul);

      End;

     Str(StrToREal(SRZena):CZena:CMantissa,SRZena);
     DelSpace(SRZena);
     Str(StrToREal(SOZena):CZena:CMantissa,SOZena);
     DelSpace(SOZena);
     RazdelKod:=Copy(Artikul,1,2);
     NAmeKod:=Copy(Artikul,3,3);

     {����⨥ 䠩�� ������}
     Assign(sklFile,ParamStr(3)+RazdelKod+'.db');
     c:=IOResult;
     Reset(sklFile);
     c:=IOResult;
     If c<>0 Then
      Begin
       Writeln('�訡�� ����㯠 � 䠩�� '+ParamStr(3)+RazdelKod+'.db � ����樨 '+Artikul);
       Readln;
       Ok:=False;
      End
      Else Ok :=True;
     If Ok Then
     Begin
      Seek(SklFile,StrToInt(NameKod));
      Read(SklFile,Skl^.Dat);

       Inc(Prz^.Dat.Amount);{���稪 ������⮢ � ��८業��}
       Prz^.Dat.Element[Prz^.Dat.Amount].BazKod:=Skl^.Dat.BazKod;
       Prz^.Dat.Element[Prz^.Dat.Amount].Kol:=Skl^.Dat.Input.Kol;
       {���� 業� � ��८業��}
       Prz^.Dat.Element[Prz^.Dat.Amount].Bak_R_Zena:=Skl^.Dat.Input.R_Zena;
       Prz^.Dat.Element[Prz^.Dat.Amount].Bak_O_Zena:=Skl^.Dat.Input.O_Zena;
       Prz^.Dat.Caption := '00';
       {�⮣� �� ���� 業��}
       Str(StrToInt(Skl^.Dat.Input.Kol)*StrToReal(Skl^.Dat.Input.R_Zena)+
	  StrToReal(Prz^.Dat.Itogo_Bak_R_Zena):CIZena:CMantissa,Prz^.Dat.Itogo_Bak_R_Zena);
       DelSpace(Prz^.Dat.Itogo_Bak_R_Zena);
       Str(StrToInt(Skl^.Dat.Input.Kol)*StrToReal(Skl^.Dat.Input.O_Zena)+
	  StrToReal(Prz^.Dat.Itogo_Bak_O_Zena):CIZena:CMantissa,Prz^.Dat.Itogo_Bak_O_Zena);
       DelSpace(Prz^.Dat.Itogo_Bak_O_Zena);
       {������뢠�� ᪫��᪨� 業� � �����뢠�� ����� 業� �� ᪫��}
       Skl^.Dat.Input.O_Zena:=SOZena;
       Skl^.Dat.Input.R_Zena:=SRZena;
       Seek(SklFile,FilePos(SklFile)-1);
       Write(SklFile,Skl^.Dat);
       {���� 業� � ��८業��}
       Prz^.Dat.Element[Prz^.Dat.Amount].New_R_Zena:=Skl^.Dat.Input.R_Zena;
       Prz^.Dat.Element[Prz^.Dat.Amount].New_O_Zena:=Skl^.Dat.Input.O_Zena;
       {�⮣� �� ���� 業��}
       Str(StrToInt(Skl^.Dat.Input.Kol)*StrToReal(Skl^.Dat.Input.R_Zena)+
	  StrToReal(Prz^.Dat.Itogo_New_R_Zena):CIZena:CMantissa,Prz^.Dat.Itogo_New_R_Zena);
       DelSpace(Prz^.Dat.Itogo_New_R_Zena);
       Str(StrToInt(Skl^.Dat.Input.Kol)*StrToReal(Skl^.Dat.Input.O_Zena)+
	  StrToReal(Prz^.Dat.Itogo_New_O_Zena):CIZena:CMantissa,Prz^.Dat.Itogo_New_O_Zena);
       DelSpace(Prz^.Dat.Itogo_New_O_Zena);
       Writeln('������: '+Artikul+' �� ��');
     End;{Ok}
     Close(SklFile);
     c:=IOResult;

    End;{While txt}

       If Prz^.Dat.Amount>0 Then
       Begin
        Str(StrToReal(Prz^.Dat.Itogo_New_R_Zena)-StrToReal(Prz^.Dat.Itogo_Bak_R_Zena):CIZena:CMantissa
        ,Prz^.Dat.Delta_RZ);
         DelSpace(Prz^.Dat.Delta_RZ);
        Str(StrToReal(Prz^.Dat.Itogo_New_O_Zena)-StrToReal(Prz^.Dat.Itogo_Bak_O_Zena):CIZena:CMantissa
       ,Prz^.Dat.Delta_OZ);
        DelSpace(Prz^.Dat.Delta_OZ);

        Seek(PrzF,FileSize(PrzF));
        Write(PrzF,Prz^.Dat);
        c:=IOResult;
        Dispose(Prz,Done);

        New(Prz,Init);
        Prz^.Dat.Vid:=0;
        Str(FileSize(PrzF):CDocNumer,Prz^.Dat.Document);
        DelSpace(Prz^.Dat.Document);
        Seek(PrzF,FileSize(PrzF));
       End;


   Dispose(Skl,Done);
   Dispose(Prz,Done);
   Close(PrzF);
   c:=IOResult;
End.
