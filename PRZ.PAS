Uses glob,ServStr;

VAr sklFile : File Of SkladType;
    skl : pSkladType;
    Przf : File Of PereozenkaType;
    Prz : PPereozenkaType;
    RazdelFile : File Of RazdelType;
    RazdelElement : RazdelType;
    F : Boolean;
    PrzCount,c : Word;


Begin
   If (ParamStr(1)='?') Or (ParamStr(1)='') Then
   Begin
    Writeln('�⨫�� ��㯯���� ��८業��, ��� ࠡ��� ���ன �ॡ����:');
    Writeln(' 1 -��� ࠧ���� (�ணࠬ�� ��� 䠩� ࠧ���� c:\newskl\main\?.db)');
    Writeln(' 2 -�����樥�� ��८業�� (���ਬ�� 1.1 - 10 %)');
    Writeln(' 3 -��� 䠩�� ��८業.(�ணࠬ�� ��� ᮧ����� 䠩� c:\newskl\correct\?.prz)');
    Writeln(' 4 -���ࠢ����� ��८業�� (1-����� 0 -����)');
    Writeln(' 5 -��� ᪫��� (�� ���� ���� ������� 0001)');
    Halt;
   End;
   Assign(SklFile,'c:\Newskl\Main\'+ParamStr(1)+'.db');
   c:=IOResult;
   Reset(SklFile);
   c:=IOResult;
If c<>0 Then
 Begin
  Writeln('�訡�� ����㯠 � 䠩�� '+'c:\Newskl\Main\'+ParamStr(1)+'.db');
  Exit;
 End;
   Assign(PrzF,'c:\Newskl\Correct\'+ParamStr(3)+'.prz');
   c:=IOResult;
   Reset(PrzF);
   c:=IOResult;
If c<>0 Then
 Begin
  Close(SklFile);
  Writeln('�訡�� ����㯠 � 䠩�� '+'c:\Newskl\Correct\'+ParamStr(3)+'.prz');
  Exit;
 End;

   New(Skl,Init);
   New(Prz,Init);
   Prz^.Dat.Vid:=0;
   Prz^.Dat.Amount:=0;
   Prz^.Dat.SkladKod:=ParamStr(5);
   Prz^.Dat.DateC:=Prz^.Dat.DateM;
   Prz^.Dat.TimeC:=Prz^.Dat.TimeM;

   Str(FileSize(PrzF)+1:CDocNumer,Prz^.Dat.Document);
   DelSpace(Prz^.Dat.Document);
   Seek(PrzF,FileSize(PrzF));

   While Not(Eof(sklFile)) Do
    Begin
     Read(SklFile,Skl^.Dat);
     If (StrToInt(Skl^.Dat.Input.Kol)>0) Then
      Begin
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
        Prz^.Dat.SkladKod:=ParamStr(5);
        Prz^.Dat.DateC:=Prz^.Dat.DateM;
        Prz^.Dat.TimeC:=Prz^.Dat.TimeM;
        Str(FileSize(PrzF)+1:CDocNumer,Prz^.Dat.Document);
        DelSpace(Prz^.Dat.Document);
        Seek(PrzF,FileSize(PrzF));
       End;

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

       {������뢠�� ᪫��᪨� 業�}
       If StrToInt(ParamStr(4))=1 Then
       Begin{�᫨ ��८業�� ����� � �����樥�⮬ ParamStr(2)}
       Seek(SklFile,Filepos(SklFile)-1);
       Str(StrToReal(Skl^.Dat.Input.R_Zena)*StrToReal(ParamStr(2))
	  :CZena:CMantissa,Skl^.Dat.Input.R_Zena);
       Str(StrToReal(Skl^.Dat.Input.O_Zena)*StrToReal(ParamStr(2))
	  :CZena:CMantissa,Skl^.Dat.Input.O_Zena);
       Write(SklFile,Skl^.Dat);
       End
       Else
        Begin
       Seek(SklFile,Filepos(SklFile)-1);
       Str(StrToReal(Skl^.Dat.Input.R_Zena)/StrToReal(ParamStr(2))
	  :CZena:CMantissa,Skl^.Dat.Input.R_Zena);
       Str(StrToReal(Skl^.Dat.Input.O_Zena)/StrToReal(ParamStr(2))
	  :CZena:CMantissa,Skl^.Dat.Input.O_Zena);
       Write(SklFile,Skl^.Dat);
        End;

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
      End;
    End;

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
        Dispose(Prz,Done);

        New(Prz,Init);
        Prz^.Dat.Vid:=0;
        Str(FileSize(PrzF):CDocNumer,Prz^.Dat.Document);
        DelSpace(Prz^.Dat.Document);
        Seek(PrzF,FileSize(PrzF));
       End;


   Dispose(Skl,Done);
   Dispose(Prz,Done);
   Close(SklFile);
   Close(PrzF);
   c:=IOResult;
   Writeln('�� �� - '+PAramStr(1));

End.