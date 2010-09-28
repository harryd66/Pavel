{$IfNDEF DPMI}
{$F+}
{$O+}

{$EndIf}

Unit CPrihod;


Interface

Uses Glob,ServStr;


Function CorrectMarket(L,PrevMarket:PSuperMarketType;Vid:Byte):Boolean;

Function GetKolMarket(SArt:ArtikulStr;p:Byte;L:PSuperMarketType):LongInt;
Function GetFullKolMarket(SArt:ArtikulStr;L:PSuperMarketType):LongInt;
Function TestMarket(Const s:ArtikulStr;PrevMarket:PSuperMarketType;Vid:Byte;Signal:Boolean):Boolean;
Function FindMarket(Const s:ArtikulStr;L:PSuperMarketType):Boolean;

Implementation

uses Views, MsgBox,Vision2, Serv, Printers,TPDate,Objects,Dialogs,NetDbEng,NetCall,Dos;

VAr PrzFile : PereozenkaFileType;
    Find    : Array [1..CMax] Of Byte;

{
Function GetKol(Sartikul:ArtikulStr;L:PPrihodType):LongInt;
Var i : Byte;
    j : LongInt;
Begin
 j:=0;
 For i:=1 To L^.Dat.Amount Do
  Begin
   If L^.Dat.PrihodElement[i].BazKod=SArtikul Then
   Inc(j,StrToInt(L^.Dat.PrihodElement[i].Input.Kol));
  End;
 GetKol:=j;
End;
}

{******** Вспомогательные процедуры **************************************}
Function GetKolMarket(SArt:ArtikulStr;p:Byte;L:PSuperMarketType):LongInt;
 Var i : Byte;
     j : LongInt;
Begin
 j:=0;
 For i:=1 To CMax Do
  Begin
   If (L^.Dat.MarketElement[i].BazKod=SArt) And (p=L^.Dat.MarketElement[i].Input.DivisionSNumber) Then
   Inc(j,StrToInt(L^.Dat.MarketElement[i].Input.Kol));
  End;
 GetKolMarket:=j;
End;

Function FindMarket(Const s:ArtikulStr;L:PSuperMarketType):Boolean;

 Var i : Byte;
     j : LongInt;
Begin
{если позиции нет тогда возвращает ложь
 если позиция есть тогда - истину}
 FindMarket:=False;
 If L^.Dat.Amount>0 Then
 For i:=1 To L^.Dat.Amount Do
  Begin
   If (L^.Dat.MarketElement[i].BazKod=S) Then
    Begin
     FindMarket:=True;
     Break;
    End;
  End;
End;


Function GetFullKolMarket(SArt:ArtikulStr;L:PSuperMarketType):LongInt;
 Var i : Byte;
     j : LongInt;
Begin
 j:=0;
 For i:=1 To CMax Do
  Begin
   If (L^.Dat.MarketElement[i].BazKod=SArt) Then
   Inc(j,StrToInt(L^.Dat.MarketElement[i].Input.Kol));
  End;
 GetFullKolMarket:=j;
End;

Function GetKolPrihod(SArt:ArtikulStr;p:Byte;L:PPrihodType):LongInt;
 Var i,k : Byte;
     j : LongInt;
Begin
 j:=0;
 For i:=1 To CMax Do
  Begin
    If (L^.Dat.PrihodElement[i].BazKod=SArt) Then
    Inc(j,StrToInt(L^.Dat.PrihodElement[i].Input.DivisionS[p]));
  End;
 GetKolPrihod:=j;
End;

Function GetFullKolPrihod(SArt:ArtikulStr;L:PPrihodType):LongInt;
 Var i,k : Byte;
     j : LongInt;
Begin
j:=0;
 For i:=1 To CMax Do
  Begin
   If (L^.Dat.PrihodElement[i].BazKod=SArt) Then
      Begin
       For k:=1 To CDiviSion Do
        Inc(j,StrToInt(L^.Dat.PrihodElement[i].Input.DivisionS[k]));
      End;
  End;
 GetFullKolPrihod:=j;
End;



{***************************************************************************}


Function TestSkladfromPrihod (L,PrevPrihod : PPrihodType;Var st : AllStr): Boolean;
Var SkladFile : SkladFileType;
    Skl : PSkladType;
    i,p : Byte;
    Ls:LongInt;
    s1,s2 : TEnjoyStr;
Begin
TestSkladfromPrihod:=False;
New(Skl,Init);
{читаем склад по старой накладной}
 For i:=1 To PrevPrihod^.Dat.Amount Do
  Begin
   st:=PrevPrihod^.Dat.PrihodElement[i].BazKod;
   S1:=Copy(PrevPrihod^.Dat.PrihodElement[i].BazKod,1,CRazdelKod);
   Assign(SkladFile,Path.ToSklad+s1+'.db');
   p:=IOResult;
   Reset(SkladFile);
   p:=IOResult;
   If p <> 0 Then
    Begin
     MessageBox('Ошибка доступа к файлу '+S1+'.db!',Nil,mfError+mfCancelButton);
     Exit;
    End;
   Seek(SkladFile,GetFileLocation3(Copy(PrevPrihod^.Dat.PrihodElement[i].BazKod,CRazdelKod+1,CKod)));
   ReadSklad(SkladFile,Skl^.Dat);
   Close(SkladFile);
   For p:=1 To CDivision Do
   If ((StrToInt(Skl^.Dat.Input.DivisionS[p])-GetKolPrihod(Skl^.Dat.BazKod,p,PrevPrihod)+
   GetKolPrihod(Skl^.Dat.BazKod,p,L)) < 0) Then
   Begin
   Str(p:1,s1);
   St:=St+' (отделение '+s1+')';
   Dispose(Skl,Done);
   Exit;
   End;
  End;
{читаем склад по новой накладной}
 For i:=1 To L^.Dat.Amount Do
  Begin
   st:=L^.Dat.PrihodElement[i].BazKod;
   S1:=Copy(L^.Dat.PrihodElement[i].BazKod,1,CRazdelKod);
   Assign(SkladFile,Path.ToSklad+s1+'.db');
   p:=IOResult;
   Reset(SkladFile);
   p:=IOResult;
   If p <> 0 Then
    Begin
     MessageBox('Ошибка доступа к файлу '+S1+'.db!',Nil,mfError+mfCancelButton);
     Exit;
    End;
   Seek(SkladFile,GetFileLocation3(Copy(L^.Dat.PrihodElement[i].BazKod,CRazdelKod+1,CKod)));
   ReadSklad(SkladFile,Skl^.Dat);
   Close(SkladFile);
   For p:=1 To CDivision Do
   If ((StrToInt(Skl^.Dat.Input.DivisionS[p])-GetKolPrihod(Skl^.Dat.BazKod,p,PrevPrihod)+
   GetKolPrihod(Skl^.Dat.BazKod,p,L)) < 0) Then
   Begin
   Str(p:1,s1);
   St:=St+' (отделение '+s1+')';
   Dispose(Skl,Done);
   Exit;
   End;
  End;
Dispose(Skl,Done);
TestSkladfromPrihod:=True;
End;

(*
Function TestSkladfromPrihod (L,PrevPrihod : PPrihodType;Var st : AllStr): Boolean;
Var SkladFile : File Of SkladType;
    Skl : PSkladType;
    i,p : Byte;
    Ls:LongInt;
    s1,s2 : TEnjoyStr;
Begin
TestSkladfromPrihod:=False;
New(Skl,Init);
 For i:=1 To L^.Dat.Amount Do
  Begin
   st:=L^.Dat.PrihodElement[i].BazKod;
   S1:=Copy(L^.Dat.PrihodElement[i].BazKod,1,CRazdelKod);
   Assign(SkladFile,Print.PathToMain+s1+'.db');
   p:=IOResult;
   Reset(SkladFile);
   p:=IOResult;
   If p <> 0 Then
    Begin
     MessageBox('Ошибка доступа к файлу '+S1+'.baz!',Nil,mfError+mfCancelButton);
     Exit;
    End;
   Seek(SkladFile,GetFileLocation3(Copy(L^.Dat.PrihodElement[i].BazKod,CRazdelKod+1,CKod)));
   Read(SkladFile,Skl^.Dat);
   Close(SkladFile);
   For p:=1 To CDivision Do
   If ((StrToInt(Skl^.Dat.Baz.Input.Division[p])-StrToInt(PrevPrihod^.Dat.PrihodElement[i].Input.Division[p])+
   StrToInt(L^.Dat.PrihodElement[i].Input.Division[p])) < 0) Then
   Begin
   Str(p:1,s1);
   St:=St+' (отделение '+s1+')';
   Dispose(Skl,Done);
   Exit;
   End;
{  If ((StrToInt(Skl^.Dat.Baz.Input.Kol)-StrToInt(PrevPrihod^.Dat.PrihodElement[i].Input.Kol)+
   StrToInt(L^.Dat.PrihodElement[i].Input.Kol)) < 0) Then
   Begin
   Dispose(Skl,Done);
   Exit;
   End;}
  End;
Dispose(Skl,Done);
TestSkladfromPrihod:=True;
End;


*)


Function TestSkladfromMarket (L,PrevMarket : PSuperMarketType;Var st : AllStr): Boolean;
Var SkladFile : SkladFileType;
    Skl : PSkladType;
    i,p : Byte;
    Ls:LongInt;
    s1,s2 : TEnjoyStr;
Begin
TestSkladfromMarket:=False;
New(Skl,Init);

{читаем склад по данным старой накладной}
 For i:=1 To PrevMarket^.Dat.Amount Do
  Begin
   st:=PrevMArket^.Dat.MarketElement[i].BazKod;
   S1:=Copy(PrevMArket^.Dat.MarketElement[i].BazKod,1,CRazdelKod);
   Assign(SkladFile,Path.ToSklad+s1+'.db');
   p:=IOResult;
   Reset(SkladFile);
   p:=IOResult;
   If p <> 0 Then
    Begin
     Dispose(Skl,Done);
     MessageBox(^M+'Ошибка доступа к файлу '+S1+'.db!',Nil,mfError+mfCancelButton);
     Exit;
    End;
   Seek(SkladFile,GetFileLocation3(Copy(L^.Dat.MarketElement[i].BazKod,CRazdelKod+1,CKod)));
   ReadSklad(SkladFile,Skl^.Dat);
   Close(SkladFile);
   For p:=1 To CDivision Do
   Begin
   If ((StrToInt(Skl^.Dat.Input.DivisionS[p])+GetKolMarket(Skl^.Dat.BazKod,p,PrevMarket)
   -GetKolMarket(Skl^.Dat.BazKod,p,L)) < 0) Then
    Begin
     Dispose(Skl,Done);
     Str(p:1,s1);
	St:=St+' (отделение '+s1+')';
     Exit;
    End;
   End;
  End;

{читаем склад по данным новой накладной}
 For i:=1 To L^.Dat.Amount Do
  Begin
   st:=L^.Dat.MarketElement[i].BazKod;
   S1:=Copy(L^.Dat.MarketElement[i].BazKod,1,CRazdelKod);
   Assign(SkladFile,Path.ToSklad+s1+'.db');
   p:=IOResult;
   Reset(SkladFile);
   p:=IOResult;
   If p <> 0 Then
    Begin
     Dispose(Skl,Done);
     MessageBox(^M+'Ошибка доступа к файлу '+S1+'.db!',Nil,mfError+mfCancelButton);
     Exit;
    End;
   Seek(SkladFile,GetFileLocation3(Copy(L^.Dat.MarketElement[i].BazKod,CRazdelKod+1,CKod)));
   ReadSklad(SkladFile,Skl^.Dat);
   Close(SkladFile);
   For p:=1 To CDivision Do
   Begin
   If ((StrToInt(Skl^.Dat.Input.DivisionS[p])+GetKolMarket(Skl^.Dat.BazKod,p,PrevMarket)
   -GetKolMarket(Skl^.Dat.BazKod,p,L)) < 0) Then
    Begin
     Dispose(Skl,Done);
     Str(p:1,s1); St:=St+' (отделение '+s1+')';
     Exit;
    End;
   End;
  End;

Dispose(Skl,Done);
TestSkladfromMarket:=True;
End;

Procedure CorrectPereozenkaFromPrihod (L,PrevPrihod:PPrihodType;Date:TDateString;
Regim:Boolean;Document:TDateString;Vid:Byte);
Var i,J,k,p,d : Byte;
    PP : Boolean;
    Prz : PPereozenkaType;
    IBR,IBO,INR,INO,DRZ,DOZ: Real;
Begin
Assign(PrzFile,Path.ToCorrect+Date+'.prz');
I:=IOResult;
Reset(PrzFile);
I:=IOResult;
If I <> 0 Then Exit;
New(Prz,Init);
If Regim Then Seek(PrzFile,StrToInt(ClearChar(Document))-1);
While Not(Eof(PrzFile)) Do
 Begin
  ReadPereozenka(PrzFile,Prz);
  If (Vid=Prz^.Dat.Vid) Then
 Begin
  PP:=False;
  For i:=1 To Prz^.Dat.Amount Do
   Begin
    For J :=1 To CMax Do
     Begin
If ((Prz^.Dat.Element[i].BazKod=L^.Dat.PrihodElement[j].BazKod)Or
    (Prz^.Dat.Element[i].BazKod=PrevPrihod^.Dat.PrihodElement[j].BazKod))And
    (GetFullKolPrihod(Prz^.Dat.Element[i].BazKod,L)<>
     GetFullKolPrihod(Prz^.Dat.Element[i].BazKod,PrevPrihod)) Then
       Begin
        PP:=True;
Str(StrToInt(Prz^.Dat.Element[i].Kol)-StrToInt(PrevPrihod^.Dat.PrihodElement[j].Input.DivisionS[p])
+StrToInt(L^.Dat.PrihodElement[j].Input.DivisionS[p]),Prz^.Dat.Element[i].Kol);
        Prz^.Dat.Caption:=CurrentPassword;
        Prz^.Dat.DateM:=FDate;
        Prz^.Dat.TimeM:=Times;

        IBR:=0;IBO:=0;INR:=0;INO:=0;DRZ:=0;DOZ:=0; {обнуляем все итоговые суммы}

        For k:=1 To Prz^.Dat.Amount Do
         Begin
IBR:=IBR+StrToInt(Prz^.Dat.Element[k].Kol)*StrToReal(Prz^.Dat.Element[k].Bak_R_Zena);
IBO:=IBO+StrToInt(Prz^.Dat.Element[k].Kol)*StrToReal(Prz^.Dat.Element[k].Bak_O_Zena);
INR:=INR+StrToInt(Prz^.Dat.Element[k].Kol)*StrToReal(Prz^.Dat.Element[k].New_R_Zena);
INO:=INO+StrToInt(Prz^.Dat.Element[k].Kol)*StrToReal(Prz^.Dat.Element[k].New_O_Zena);
         End;
         DRZ:=INR-IBR;
         DOZ:=INO-IBO;
         Str(IBR:CIZena:CMantissa,Prz^.Dat.Itogo_Bak_R_Zena);
         Str(IBO:CIZena:CMantissa,Prz^.Dat.Itogo_Bak_O_Zena);
         Str(INR:CIZena:CMantissa,Prz^.Dat.Itogo_New_R_Zena);
         Str(INO:CIZena:CMantissa,Prz^.Dat.Itogo_New_O_Zena);
         Str(DRZ:CIZena:CMantissa,Prz^.Dat.Delta_RZ);
         Str(DOZ:CIZena:CMantissa,Prz^.Dat.Delta_OZ);
       End; {если нужна корректировка переоценки}
     End; {For по приходу}
   End; {For по переоценке в файле}
  If PP Then
  Begin
  Seek(PrzFile,FilePos(PrzFile)-1);
  Write(PrzFile,Prz^.Dat);
  If MessageBox(#3'В результате корректировки прихода'^M+
  #3'возникла необходимость в изменении акта переоценки N '+Prz^.Dat.Document+' от '+Date+''^M+
  #3'Напечатать новый вариант акта?',Nil,mfWarning+mfOkCancel)=cmOk Then
  Begin
  FormAktFile(Prz,Date);
  Report(Path.ToTemp+'pereozp.txt','',NPrint.CopyPrz,False,False,false)
  End;
  End;
 End;
 End;{While Not (Eof)}
Dispose(Prz,Done);
Close(PrzFile);
End;


(*
Procedure CorrectPereozenkaFromPrihod (L,PrevPrihod:PPrihodType;Date:TDateString;Regim:Boolean;Document:TDateString;Vid:Byte);
Var i,J,k,p,d : Byte;
    PP : Boolean;
    Prz : PPereozenkaType;
    IBR,IBO,INR,INO,DRZ,DOZ: Real;
Begin
Assign(PrzFile,Print.PathToCorrect+Date+'.prz');
I:=IOResult;
Reset(PrzFile);
I:=IOResult;
If I <> 0 Then Exit;
New(Prz,Init);
If Regim Then Seek(PrzFile,StrToInt(ClearChar(Document))-1);
While Not(Eof(PrzFile)) Do
 Begin
  Read(PrzFile,Prz^.Dat);
  If (Vid=Prz^.Dat.Vid) Then
 Begin
  PP:=False;
  For i:=1 To Prz^.Dat.Amount Do
   Begin
    For J :=1 To L^.Dat.Amount Do
     Begin
     For p:=1 To CDivision Do
      Begin
If (Prz^.Dat.Element[i].BazKod=L^.Dat.PrihodElement[j].BazKod) And
 ((StrToInt(PrevPrihod^.Dat.PrihodElement[j].Input.DiviSion[p])<>StrToInt(L^.Dat.PrihodElement[j].Input.Division[p]))Or
((StrToReal(PrevPrihod^.Dat.PrihodElement[j].Input.R_Zena)<>StrToReal(L^.Dat.PrihodElement[j].Input.R_Zena))And(Find[j]<>2))Or
((StrToReal(PrevPrihod^.Dat.PrihodElement[j].Input.O_Zena)<>StrToReal(L^.Dat.PrihodElement[j].Input.O_Zena))And(Find[j]<>2)))
Then
       Begin
        PP:=True;
        Str(StrToInt(Prz^.Dat.Element[i].Kol)-StrToInt(PrevPrihod^.Dat.PrihodElement[j].Input.Division[p])
        +StrToInt(L^.Dat.PrihodElement[j].Input.Division[p]),Prz^.Dat.Element[i].Kol);
        Prz^.Dat.Caption:=CurrentPassword;
        Prz^.Dat.DateM:=FDate;
        Prz^.Dat.TimeM:=Times;
{изменения цены}
If Find[j]=1 Then
     Begin
       If Not(Wozwrat) Then
       Begin
        Prz^.Dat.Element[i].Bak_R_Zena:=L^.Dat.PrihodElement[j].Input.R_Zena;
        Prz^.Dat.Element[i].Bak_O_Zena:=L^.Dat.PrihodElement[j].Input.O_Zena;
        Find[j]:=2;
       End
       Else
       Begin
        Prz^.Dat.Element[i].New_R_Zena:=L^.Dat.PrihodElement[j].Input.R_Zena;
        Prz^.Dat.Element[i].New_O_Zena:=L^.Dat.PrihodElement[j].Input.O_Zena;
        Find[j]:=2;
       End;
     End;
If (Prz^.Dat.Document=PrevPrihod^.Dat.DocumentPRZ) And (Regim) And (Find[j]=0) Then
     Begin
      If PrevPrihod^.Dat.PrihodElement[j].Input.Auto Then
       Begin
       If Not(Wozwrat) Then
       Begin
        Prz^.Dat.Element[i].New_R_Zena:=L^.Dat.PrihodElement[j].Input.R_Zena;
        Prz^.Dat.Element[i].New_O_Zena:=L^.Dat.PrihodElement[j].Input.O_Zena;
        Find[j]:=1;
       End
       Else
       Begin
        Prz^.Dat.Element[i].Bak_R_Zena:=L^.Dat.PrihodElement[j].Input.R_Zena;
        Prz^.Dat.Element[i].Bak_O_Zena:=L^.Dat.PrihodElement[j].Input.O_Zena;
        Find[j]:=1;
       End;
       End
       Else
       Begin
       If Not(Wozwrat) Then
       Begin
        Prz^.Dat.Element[i].Bak_R_Zena:=L^.Dat.PrihodElement[j].Input.R_Zena;
        Prz^.Dat.Element[i].Bak_O_Zena:=L^.Dat.PrihodElement[j].Input.O_Zena;
        Find[j]:=2;
       End
       Else
       Begin
        Prz^.Dat.Element[i].New_R_Zena:=L^.Dat.PrihodElement[j].Input.R_Zena;
        Prz^.Dat.Element[i].New_O_Zena:=L^.Dat.PrihodElement[j].Input.O_Zena;
        Find[j]:=2;
       End;
       End;
     End;
{конец изменения цены}

        IBR:=0;IBO:=0;INR:=0;INO:=0;DRZ:=0;DOZ:=0; {обнуляем все итоговые суммы}

        For k:=1 To Prz^.Dat.Amount Do
         Begin
          IBR:=IBR+StrToInt(Prz^.Dat.Element[k].Kol)*StrToReal(Prz^.Dat.Element[k].Bak_R_Zena);
          IBO:=IBO+StrToInt(Prz^.Dat.Element[k].Kol)*StrToReal(Prz^.Dat.Element[k].Bak_O_Zena);
          INR:=INR+StrToInt(Prz^.Dat.Element[k].Kol)*StrToReal(Prz^.Dat.Element[k].New_R_Zena);
          INO:=INO+StrToInt(Prz^.Dat.Element[k].Kol)*StrToReal(Prz^.Dat.Element[k].New_O_Zena);
         End;
         DRZ:=INR-IBR;
         DOZ:=INO-IBO;
         Str(IBR:CIZena:CMantissa,Prz^.Dat.Itogo_Bak_R_Zena);
         Str(IBO:CIZena:CMantissa,Prz^.Dat.Itogo_Bak_O_Zena);
         Str(INR:CIZena:CMantissa,Prz^.Dat.Itogo_New_R_Zena);
         Str(INO:CIZena:CMantissa,Prz^.Dat.Itogo_New_O_Zena);
         Str(DRZ:CIZena:CMantissa,Prz^.Dat.Delta_RZ);
         Str(DOZ:CIZena:CMantissa,Prz^.Dat.Delta_OZ);
       End; {если нужна корректировка переоценки}
      End;{For по отделениям}
     End; {For по приходу}
   End; {For по переоценке в файле}
  If PP Then
  Begin
  Seek(PrzFile,FilePos(PrzFile)-1);
  Write(PrzFile,Prz^.Dat);
  If MessageBox(#3'В результате корректировки прихода'^M+
  #3'возникла необходимость в изменении акта переоценки N '+Prz^.Dat.Document+' от '+Date+''^M+
  #3'Напечатать новый вариант акта?',Nil,mfWarning+mfOkCancel)=cmOk Then
  Begin
  FormAktFile(Prz,Date);
  Report(Path.ToTemp+'report.txt',Print.CopyPrz)
  End;
  End;
 End;
 End;{While Not (Eof)}
Dispose(Prz,Done);
Close(PrzFile);
End;
*)

Procedure CorrectPereozenkaFromMarket (L,PrevMarket:PSuperMarketType;Date:TDateString;Regim:Boolean;Document:TDateString;
Vid:BYte);
Var i,J,k,p,d : Byte;
    PP : Boolean;
    Prz : PPereozenkaType;
    IBR,IBO,INR,INO,DRZ,DOZ: Real;
Begin
Assign(PrzFile,Path.ToCorrect+Date+'.prz');
I:=IOResult;
Reset(PrzFile);
I:=IOResult;
If I <> 0 Then Exit;
New(Prz,Init);
If Regim Then Seek(PrzFile,StrToInt(ClearChar(Document))-1);
While Not(Eof(PrzFile)) Do
 Begin

     {предварительная блокировка перед чтением}
 DInfoNetMsg('Блокирую переоценку в фале за '+DAte+'...');
     Repeat {блокируем участок записи}
      Pause(1);
     Until (Lock(PrzFile,FilePos(PrzFile)*SizeOf(PereozenkaType),SizeOf(PereozenkaType)));
 NoNetInfoMsg;

  Read(PrzFile,Prz^.DAt);

  If Prz^.Dat.Vid=Vid Then
  Begin
  PP:=False;
  For i:=1 To Prz^.Dat.Amount Do
   Begin
    For J :=1 To CMax Do
     Begin
If ((Prz^.Dat.Element[i].BazKod=L^.Dat.MarketElement[j].BazKod)Or
    (Prz^.Dat.Element[i].BazKod=PrevMarket^.Dat.MarketElement[j].BazKod))
And (GetFullKolMarket(Prz^.Dat.Element[i].BazKod,L)<>
     GetFullKolMarket(Prz^.Dat.Element[i].BazKod,PrevMarket))
Then
       Begin
        PP:=True;
        Str(
        StrToInt(Prz^.Dat.Element[i].Kol)+
        GetFullKolMarket(Prz^.Dat.Element[i].BazKod,PrevMarket)-
        GetFullKolMarket(Prz^.Dat.Element[i].BazKod,L),Prz^.Dat.Element[i].Kol);
        Prz^.Dat.Caption:=CurrentPassword;
        Prz^.Dat.DateM:=FDate;
        Prz^.Dat.TimeM:=Times;
        IBR:=0;IBO:=0;INR:=0;INO:=0;DRZ:=0;DOZ:=0; {обнуляем все итоговые суммы}
        For k:=1 To Prz^.Dat.Amount Do
         Begin
          IBR:=IBR+StrToInt(Prz^.Dat.Element[k].Kol)*StrToReal(Prz^.Dat.Element[k].Bak_R_Zena);
          IBO:=IBO+StrToInt(Prz^.Dat.Element[k].Kol)*StrToReal(Prz^.Dat.Element[k].Bak_O_Zena);
          INR:=INR+StrToInt(Prz^.Dat.Element[k].Kol)*StrToReal(Prz^.Dat.Element[k].New_R_Zena);
          INO:=INO+StrToInt(Prz^.Dat.Element[k].Kol)*StrToReal(Prz^.Dat.Element[k].New_O_Zena);
         End;
         DRZ:=INR-IBR;
         DOZ:=INO-IBO;
         Str(IBR:CIZena:CMantissa,Prz^.Dat.Itogo_Bak_R_Zena);
         Str(IBO:CIZena:CMantissa,Prz^.Dat.Itogo_Bak_O_Zena);
         Str(INR:CIZena:CMantissa,Prz^.Dat.Itogo_New_R_Zena);
         Str(INO:CIZena:CMantissa,Prz^.Dat.Itogo_New_O_Zena);
         Str(DRZ:CIZena:CMantissa,Prz^.Dat.Delta_RZ);
         Str(DOZ:CIZena:CMantissa,Prz^.Dat.Delta_OZ);
         Break;
       End; {если нужна корректировка переоценки}
     End; {For по приходу}
   End; {For по переоценке в файле}
  If PP Then
  Begin
   Seek(PrzFile,FilePos(PrzFile)-1);
   Write(PrzFile,Prz^.Dat);
   If MessageBox(#3'В результате корректировки продажи'^M+
   #3'возникла необходимость в изменении акта переоценки N '+Prz^.Dat.Document+' от '+Date+''^M+
   #3'Напечатать новый вариант акта?',Nil,mfWarning+mfOkCancel)=cmOk Then
    Begin
     FormAktFile(Prz,Date);
     Report(Path.ToTemp+'pereozp.txt','',NPrint.CopyPrz,False,False,false)
    End;
  End;
 End;{if prz.vid}

 Repeat {деблокируем участок записи}
  Pause(1);
  UnLock(PrzFile,(FilePos(PrzFile)-1)*SizeOf(PereozenkaType),SizeOf(PereozenkaType));
 Until (DosError=0);

 End;{While Not (Eof)}
Dispose(Prz,Done);
Close(PrzFile);
End;



Function TestPereozenka (Const Date:TDateString;Regim:Boolean;Document:TDateString;s:ArtikulStr;
Vid:Byte;Signal:Boolean):Boolean;
Var i,J,k,p,d : Byte;
    PP : Boolean;
    Prz : PPereozenkaType;
    IBR,IBO,INR,INO,DRZ,DOZ: Real;
Begin
 DInfoMsg('Проверяю переоценки за '+DAte+'...');

TestPereozenka:=False;
Assign(PrzFile,Path.ToCorrect+Date+'.prz');
I:=IOResult;
Reset(PrzFile);
I:=IOResult;
If I <> 0 Then Exit;
New(Prz,Init);

If Regim Then Seek(PrzFile,StrToInt(ClearChar(Document))-1);
PP:=False;
While Not(Eof(PrzFile)) And Not(PP) Do
 Begin
  ReadPereozenka(PrzFile,Prz);
  If Prz^.Dat.Vid=Vid Then
  Begin
  For i:=1 To Prz^.Dat.Amount Do
   begin
    If (Prz^.Dat.Element[i].BazKod=s) Then
     Begin
      PP := True;
      Break;
     End;
   End;
  End;
 End;{While Not (Eof)}
Close(PrzFile);
NoInfoMsg;

If PP And Signal Then
 MessageBox(#3+'Товар с кодом ('+s+') после выписки документа уже был переоценен по акту N '+Prz^.Dat.Document+
 ' от '+Date+
 '. Редактирование этой позиции документа запрещено!',Nil,mfError+mfCancelButton);

Dispose(Prz,Done);
TestPereozenka:=PP;
End;


Function CorrectPrihod(L,PrevPrihod:PPrihodType;Vid:Byte):Boolean;
Var st: AllStr;
    I : Byte ;
    ls,Start,Stop : LongInt;
Begin
 For ls:=1 To CMax Do
 Find[Ls]:=0;
 CorrectPrihod:=False;
 If Not(TestSkladfromPrihod(L,PrevPrihod,st)) Then
  Begin
   MessageBox(#3'Корректировка невозможна!'^M+
   #3'на складе в позиции '+st+' получится отрицательное количество товара!',Nil,mfError+mfCancelButton);
   Exit;
  End;
{  DateMask:=InternationalDate(False,True);}
  Start:=DateStringToDate(DateMask,TekDate);
  Stop:=DateStringToDate(DateMask,FDate);
  CorrectPereozenkaFromPrihod(L,PrevPrihod,TekDate,True,PrevPrihod^.Dat.DocumentPrz,Vid);
  For  Ls:=Start+1 To Stop Do
   Begin
    st:=DelPunkt(DateToDateString(DateMask,Ls));
    CorrectPereozenkaFromPrihod(L,PrevPrihod,St,False,PrevPrihod^.Dat.DocumentPrz,Vid);
   End;
 CorrectPrihod:=True;
End;


Function CorrectMarket(L,PrevMarket:PSuperMarketType;Vid:Byte):Boolean;
Var st: AllStr;
    I : Byte ;
{    DateMask : TDateString;}
    ls,Start,Stop : LongInt;
Begin
 CorrectMarket:=False;
 If Not(TestSkladfromMarket(L,PrevMarket,st)) Then
  Begin
   MessageBox(#3'Корректировка невозможна!'^M+
   #3'на складе в позиции '+st+' получится отрицательное количество товара!',Nil,mfError+mfCancelButton);
   Exit;
  End;
{  DateMask:=InternationalDate(False,True);}
  Start:=DateStringToDate(DateMask,TekDate);
  Stop:=DateStringToDate(DateMask,FDate);
  CorrectPereozenkaFromMarket(L,PrevMarket,TekDate,True,PrevMarket^.Dat.DocumentPrz,Vid);
  For  Ls:=Start+1 To Stop Do
   Begin
    st:=DelPunkt(DateToDateString(DateMask,Ls));
    CorrectPereozenkaFromMarket(L,PrevMarket,St,False,PrevMarket^.Dat.DocumentPrz,Vid);
   End;
 CorrectMarket:=True;
End;


Function TestMarket(Const s:ArtikulStr;PrevMarket:PSuperMarketType;Vid:Byte;Signal:Boolean):Boolean;
Var st: AllStr;
    I : Byte ;
{    DateMask : TDateString;}
    ls,Start,Stop : LongInt;
    l : Boolean;
Begin
  TestMarket:=False;
  l := False;
{  DateMask:=InternationalDate(False,True);}
  Start:=DateStringToDate(DateMask,TekDate);
  Stop:=DateStringToDate(DateMask,FDate);
  l:=TestPereozenka(TekDate,True,PrevMarket^.Dat.DocumentPrz,s,Vid,Signal);
  If Not(l) Then
  For  Ls:=Start+1 To Stop Do
   Begin
    st:=DelPunkt(DateToDateString(DateMask,Ls));
    l:=TestPereozenka(St,False,PrevMarket^.Dat.DocumentPrz,s,Vid,Signal);
    If l Then Break;
   End;
 TestMarket:=l;
End;

Function TestPrihod(Const s:ArtikulStr;PrevPrihod:PPrihodType;Vid:Byte):Boolean;
Var st: AllStr;
    I : Byte ;
{    DateMask : TDateString;}
    ls,Start,Stop : LongInt;
    l : Boolean;
Begin
  TestPrihod:=False;
  l := False;
{ DateMask:=InternationalDate(False,True);}
  Start:=DateStringToDate(DateMask,TekDate);
  Stop:=DateStringToDate(DateMask,FDate);
  l:=TestPereozenka(TekDate,True,PrevPrihod^.Dat.DocumentPrz,s,Vid,True);
  If Not(l) Then
  For  Ls:=Start+1 To Stop Do
   Begin
    st:=DelPunkt(DateToDateString(DateMask,Ls));
    l:=TestPereozenka(St,False,PrevPrihod^.Dat.DocumentPrz,s,Vid,True);
    If l Then Break;
   End;
 TestPrihod:=l;
End;



End.