{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}

Unit DbEngin2;

Interface

Uses Dialogs,Glob,ServStr,DbEngine;


Function GetKSertifEmploy(C:ArtikulStr):Boolean;
Function GetKSertifField(Field:Byte;C:ArtikulStr):String;

Function GetMeraEmploy(C:ArtikulStr):Boolean;
Function GetMeraField(Field:Byte;C:ArtikulStr):String;

Function GetPostEmploy(C:ArtikulStr):Boolean;        {2}
Function GetPostField(Field:Byte;C:ArtikulStr):String;

Function GetFirmaPostEmploy(C:ArtikulStr):Boolean;        {2}
Function GetFirmaPostField(Field:Byte;C:ArtikulStr):String;

Function GetMarkaEmploy(C:ArtikulStr):Boolean;        {2}
Function GetMarkaField(Field:Byte;C:ArtikulStr):String;

Function GetExpertEmploy(C:ArtikulStr):Boolean;        {2}
Function GetExpertField(Field:Byte;C:ArtikulStr):String;

Function GetSpecMarkaEmploy(C:ArtikulStr):Boolean;        {2}
Function GetSpecMarkaField(Field:Byte;C:ArtikulStr):String;


Function GetClassEmploy(C:ArtikulStr):Boolean;        {2}
Function GetClassField(Field:Byte;C:ArtikulStr):String;

Function GetNGTDEmploy(C:ArtikulStr):Boolean;        {2}
Function GetNGTDField(Field:Byte;C:ArtikulStr):String;


Function CalcPackNoFile(Kod,Kol:TDateString):AllStr;
Function CalcPack(Kod,Kol:TDateString):AllStr;

Function GetClient(Var Cl : PClientType;VidOperator:Word):Boolean;
Procedure GetAgent(Var Cl : PClientType);
Procedure GetEksped(Var Cl : PClientType);


Procedure CorrectMarka;
Procedure CorrectNGTD;
Procedure CorrectExpert;
Procedure CorrectSMarka;
Procedure CorrectKSertif;
Procedure CorrectClass;
Procedure CorrectMera;
Procedure CorrectPost;
Procedure CorrectRegion;
Procedure CorrectGroup;
Procedure CorrectRoute;
Procedure CorrectFirma;
Procedure CorrectRazdel(Cod:Integer);
Procedure CorrectBaza(Reg,Sel:Word);



Implementation

{$I Compile.INC}
Uses Memory,Dos,MsgBox,Views,Objects,{Validate,}App,Drivers,Protect,SysTime,
     TPDate,NetDbEng,Serv,Access4,Utils5,Utils7,ColorTxt,Validate,ServStr2,
     Utils1,Utils,Access1,Mail;

Var OldFileMode : Word;


Function GetKSertifEmploy(C:ArtikulStr):Boolean;
Var f : KSertifFileType;
    l : LongInt;
    Code : Integer;
    s : KSertifType;
Begin
 OldFileMode:=FileMode;
 FileMode:=ReadOnlyN;
 Assign (f,Path^.Dat.ToSPR+'ksertif.db');
 GetKSertifEmploy:=False;
 l:=IOResult;
 Reset(f);
 l:=IOResult;
 FileMode:=OldFileMode;
 If l <> 0 Then
 Begin
  MessageBox(^M+#3'Ошибка открытия файла органов сертификации!'+
  ^M+#3+'Код:'+IntToStr(l,3),nil,mfError+mfCancelButton);
  Exit;
 End
 Else
  Begin
   DelSpace(c);
   Val(c,l,Code);

   If l>FileSize(f) Then
    Begin
     System.Close(f);
     l:=IOResult;
     MessageBox(^M+#3'Попытка чтения органа сертификаци '+c+' - позиция вне файла!',nil,mfError+mfCancelButton);
     Exit;
    End;

   Seek(f,l);
   Code:=IOResult;
   ReadKSertif(f,s);
   Close(f);
   GetKSertifEmploy:=S.Employ;
  End;
End;



Function GetKSertifField(Field:Byte;C:ArtikulStr):String;
Var f : KSertifFileType;
    l : LongInt;
    s : KSertifType;
    st : ArtikulStr;
    ss : TMyString;
    Code : Integer;
Begin
 GetKSertifField:=#0;
 ss[0]:=#0;


 If ReadCashSpr(bKSertif,c,ss) Then
   Begin
    GetKSertifField:=ss;
    Exit;
   End;


 OldFileMode:=FileMode;
 FileMode:=ReadOnlyN;
 Assign (f,Path^.Dat.ToSPR+'ksertif.db');
 l:=IOResult;
 Reset(f);
 FileMode:=OldFileMode;
 l:=IOResult;
 If l <> 0 Then
 Begin
  MessageBox(^M+#3'Ошибка открытия файла органов сертификации!'+
  ^M+#3'Код:'+IntToStr(l,3),nil,mfError+mfCancelButton);
  Exit;
 End
 Else
  Begin
   DelSpace(c);
   l:=StrToInt(c);

   If l>FileSize(f) Then
    Begin
     System.Close(f);
     l:=IOResult;
     MessageBox(^M+#3'Попытка чтения органа сертификации '+c+' - позиция вне файла!',nil,mfError+mfCancelButton);
     Exit;
    End;

   Seek(f,l);
   ReadKSertif(f,s);
   Close(f);
   Case Field Of
    FName,
    FKSertif,
    FKtoSertif,
    FPost,
    fClient,
    FMake  : GetKSertifField:=S.KSertif;
    Else;
   End;
  End;

  {If Not(s.Employ) Then GetKSertifField:='!!!ОБЪЕКТ УДАЛЕН!!!';}
End;


Function GetPostEmploy(C:ArtikulStr):Boolean;
Var f : PostFileType;
    l : LongInt;
    Code : Integer;
    s : PostType;
Begin
 OldFileMode:=FileMode;
 FileMode:=ReadOnlyN;
 Assign (f,Path^.Dat.ToSPR+'lands.db');
 GetPostEmploy:=False;
 l:=IOResult;
 Reset(f);
 l:=IOResult;
 FileMode:=OldFileMode;
 If l <> 0 Then
 Begin
  MessageBox(^M+#3'Ошибка открытия файла стран!'+
  ^M+#3+'Код:'+IntToStr(l,3),nil,mfError+mfCancelButton);
  Exit;
 End
 Else
  Begin
   DelSpace(c);
   Val(c,l,Code);

   If l>FileSize(f) Then
    Begin
     System.Close(f);
     l:=IOResult;
     MessageBox(^M+#3'Попытка чтения страны '+c+' - позиция вне файла!',nil,mfError+mfCancelButton);
     Exit;
    End;

   Seek(f,l);
   Code:=IOResult;
   ReadPost(f,s);
   Close(f);
   GetPostEmploy:=S.Employ;
  End;
End;


Function GetMeraEmploy(C:ArtikulStr):Boolean;
Var f : MeraFileType;
    l : LongInt;
    Code : Integer;
    s : MeraType;
Begin
 OldFileMode:=FileMode;
 FileMode:=ReadOnlyN;
 Assign (f,Path^.Dat.ToSPR+'mera.db');
 GetMeraEmploy:=False;
 l:=IOResult;
 Reset(f);
 l:=IOResult;
 FileMode:=OldFileMode;
 If l <> 0 Then
 Begin
  MessageBox(^M+#3'Ошибка открытия файла единиц измерения!'+
  ^M+#3+'Код:'+IntToStr(l,3),nil,mfError+mfCancelButton);
  Exit;
 End
 Else
  Begin
   DelSpace(c);
   Val(c,l,Code);

   If l>FileSize(f) Then
    Begin
     System.Close(f);
     l:=IOResult;
     MessageBox(^M+#3'Попытка чтения единицы измерения '+c+' - позиция вне файла!',nil,mfError+mfCancelButton);
     Exit;
    End;

   Seek(f,l);
   Code:=IOResult;
   ReadMera(f,s);
   Close(f);
   GetMeraEmploy:=S.Employ;
  End;
End;



Function GetFirmaPostEmploy(C:ArtikulStr):Boolean;
Var f : FirmaPostFileType;
    l : LongInt;
    Code : Integer;
    s : FirmaPostType;
Begin
 OldFileMode:=FileMode;
 FileMode:=ReadOnlyN;
 Assign (f,Path^.Dat.ToSPR+'firma.db');
 GetFirmaPostEmploy:=False;
 l:=IOResult;
 Reset(f);
 l:=IOResult;
 FileMode:=OldFileMode;
 If l <> 0 Then
 Begin
  MessageBox(^M+#3'Ошибка открытия файла фирм!'+
  ^M+#3+'Код:'+IntToStr(l,3),nil,mfError+mfCancelButton);
  Exit;
 End
 Else
  Begin
   DelSpace(c);
   Val(c,l,Code);

   If l>FileSize(f) Then
    Begin
     System.Close(f);
     l:=IOResult;
     MessageBox(^M+#3'Попытка чтения фирмы '+c+' - позиция вне файла!',nil,mfError+mfCancelButton);
     Exit;
    End;

   Seek(f,l);
   Code:=IOResult;
   ReadFirmaPost(f,s);
   Close(f);
   GetFirmaPostEmploy:=S.Employ;
  End;
End;

Function GetMarkaEmploy(C:ArtikulStr):Boolean;
Var f : MarkaFileType;
    l : LongInt;
    Code : Integer;
    s : MarkaType;
Begin
 OldFileMode:=FileMode;
 FileMode:=ReadOnlyN;
 Assign (f,Path^.Dat.ToSPR+'marka.db');
 GetMarkaEmploy:=False;
 l:=IOResult;
 Reset(f);
 l:=IOResult;
 FileMode:=OldFileMode;
 If l <> 0 Then
 Begin
  MessageBox(^M+#3'Ошибка открытия файла марок!'+
  ^M+#3+'Код:'+IntToStr(l,3),nil,mfError+mfCancelButton);
  Exit;
 End
 Else
  Begin
   DelSpace(c);
   Val(c,l,Code);

   If l>FileSize(f) Then
    Begin
     System.Close(f);
     l:=IOResult;
     MessageBox(^M+#3'Попытка чтения марки '+c+' - позиция вне файла!',nil,mfError+mfCancelButton);
     Exit;
    End;

   Seek(f,l);
   Code:=IOResult;
   ReadMarka(f,s);
   Close(f);
   GetMarkaEmploy:=S.Employ;
  End;
End;


Function GetExpertEmploy(C:ArtikulStr):Boolean;
Var f : ExpertFileType;
    l : LongInt;
    Code : Integer;
    s : ExpertType;
Begin
 OldFileMode:=FileMode;
 FileMode:=ReadOnlyN;
 Assign (f,Path^.Dat.ToSPR+'Expert.db');
 GetExpertEmploy:=False;
 l:=IOResult;
 Reset(f);
 l:=IOResult;
 FileMode:=OldFileMode;
 If l <> 0 Then
 Begin
  MessageBox(^M+#3'Ошибка открытия файла'+Expert_RegNom^+'!'+
  ^M+#3+'Код:'+IntToStr(l,3),nil,mfError+mfCancelButton);
  Exit;
 End
 Else
  Begin
   DelSpace(c);
   Val(c,l,Code);

   If l>FileSize(f) Then
    Begin
     System.Close(f);
     l:=IOResult;
     MessageBox(^M+#3'Попытка чтения эксп.закл '+c+' - позиция вне файла!',nil,mfError+mfCancelButton);
     Exit;
    End;

   Seek(f,l);
   Code:=IOResult;
   ReadExpert(f,s);
   Close(f);
   GetExpertEmploy:=S.Employ;
  End;
End;


Function GetSpecMarkaEmploy(C:ArtikulStr):Boolean;
Var f : SpecMarkaFileType;
    l : LongInt;
    Code : Integer;
    s : SpecMarkaType;
Begin
 OldFileMode:=FileMode;
 FileMode:=ReadOnlyN;
 Assign (f,Path^.Dat.ToSPR+'SMarka.db');
 GetSpecMarkaEmploy:=False;
 l:=IOResult;
 Reset(f);
 l:=IOResult;
 FileMode:=OldFileMode;
 If l <> 0 Then
 Begin
  MessageBox(^M+#3'Ошибка открытия файла марок!'+
  ^M+#3+'Код:'+IntToStr(l,3),nil,mfError+mfCancelButton);
  Exit;
 End
 Else
  Begin
   DelSpace(c);
   Val(c,l,Code);

   If l>FileSize(f) Then
    Begin
     System.Close(f);
     l:=IOResult;
     MessageBox(^M+#3'Попытка чтения марки '+c+' - позиция вне файла!',nil,mfError+mfCancelButton);
     Exit;
    End;

   Seek(f,l);
   Code:=IOResult;
   ReadSpecMarka(f,s);
   Close(f);
   GetSpecMarkaEmploy:=S.Employ;
  End;
End;

Function GetClassEmploy(C:ArtikulStr):Boolean;
Var f : ClassFileType;
    l : LongInt;
    Code : Integer;
    s : ClassificatorBuchType;
Begin
 OldFileMode:=FileMode;
 FileMode:=ReadOnlyN;
 Assign (f,Path^.Dat.ToSPR+'class.db');
 GetClassEmploy:=False;
 l:=IOResult;
 Reset(f);
 l:=IOResult;
 FileMode:=OldFileMode;
 If l <> 0 Then
 Begin
  MessageBox(^M+#3'Ошибка открытия файла групп!'+
  ^M+#3+'Код:'+IntToStr(l,3),nil,mfError+mfCancelButton);
  Exit;
 End
 Else
  Begin
   DelSpace(c);
   Val(c,l,Code);

   If l>FileSize(f) Then
    Begin
     System.Close(f);
     l:=IOResult;
     MessageBox(^M+#3'Попытка чтения группы '+c+' - позиция вне файла!',nil,mfError+mfCancelButton);
     Exit;
    End;

   Seek(f,l);
   Code:=IOResult;
   ReadClass(f,s);
   Close(f);
   GetClassEmploy:=S.Employ;
  End;
End;



Function GetNGTDEmploy(C:ArtikulStr):Boolean;
Var f : NGTDFileType;
    l : LongInt;
    Code : Integer;
    s : NGTDType;
Begin
 OldFileMode:=FileMode;
 FileMode:=ReadOnlyN;
 Assign (f,Path^.Dat.ToSPR+'ngtd.db');
 GetNGTDEmploy:=False;
 l:=IOResult;
 Reset(f);
 l:=IOResult;
 FileMode:=OldFileMode;
 If l <> 0 Then
 Begin
  MessageBox(^M+#3'Ошибка открытия файла ГТД!'+
  ^M+#3+'Код:'+IntToStr(l,3),nil,mfError+mfCancelButton);
  Exit;
 End
 Else
  Begin
   DelSpace(c);
   Val(c,l,Code);

   If l>FileSize(f) Then
    Begin
     System.Close(f);
     l:=IOResult;
     MessageBox(^M+#3'Попытка чтения ГТД '+c+' - позиция вне файла!',nil,mfError+mfCancelButton);
     Exit;
    End;

   Seek(f,l);
   Code:=IOResult;
   ReadNGTD(f,s);
   Close(f);
   GetNGTDEmploy:=S.Employ;
  End;
End;


Function GetPostField(Field:Byte;C:ArtikulStr):String;
Var f : PostFileType;
    l : LongInt;
    s : PostType;
    st : ArtikulStr;
    Code : Integer;
    ss : TMyString;
Begin
 GetPostField:=#0;
 ss[0]:=#0;


 If ReadCashSpr(bLands,c,ss) Then
   Begin
    GetPostField:=ss;
    Exit;
   End;

 OldFileMode:=FileMode;
 FileMode:=ReadOnlyN;
 Assign (f,Path^.Dat.ToSPR+'lands.db');
 l:=IOResult;
 Reset(f);
 FileMode:=OldFileMode;
 l:=IOResult;
 If l <> 0 Then
 Begin
  MessageBox(^M+#3'Ошибка открытия файла стран!'+
  ^M+#3'Код:'+IntToStr(l,3),nil,mfError+mfCancelButton);
  Exit;
 End
 Else
  Begin
   DelSpace(c);
   l:=StrToInt(c);

   If l>FileSize(f) Then
    Begin
     System.Close(f);
     l:=IOResult;
     MessageBox(^M+#3'Попытка чтения страны '+c+' - позиция вне файла!',nil,mfError+mfCancelButton);
     Exit;
    End;

   Seek(f,l);
   ReadPost(f,s);
   Close(f);
   l:=IOResult;
   Case Field Of
    FName,
    FPost,
    FFirmaPost,
    fClient,
    FMake  : GetPostField:=S.Post;
    Else;
   End;
  End;

  {If Not(s.Employ) Then GetPostField:='!!!СТРАНА УДАЛЕНА!!';}
End;


Function GetMarkaField(Field:Byte;C:ArtikulStr):String;
Var f : MarkaFileType;
    l : LongInt;
    s : MarkaType;
    st : ArtikulStr;
    Code : Integer;
    ss : TMyString;
Begin
 GetMarkaField:=#0;
 ss[0]:=#0;


 If ReadCashSpr(bMarka,c,ss) Then
   Begin
    GetMarkaField:=ss;
    Exit;
   End;
 OldFileMode:=FileMode;
 FileMode:=ReadOnlyN;
 Assign (f,Path^.Dat.ToSPR+'marka.db');
 GetMarkaField:=#0;
 l:=IOResult;
 Reset(f);
 FileMode:=OldFileMode;
 l:=IOResult;
 If l <> 0 Then
 Begin
  MessageBox(^M+#3'Ошибка открытия файла марок!'+
  ^M+#3'Код:'+IntToStr(l,3),nil,mfError+mfCancelButton);
  Exit;
 End
 Else
  Begin
   DelSpace(c);
   l:=StrToInt(c);

   If l>FileSize(f) Then
    Begin
     System.Close(f);
     l:=IOResult;
     MessageBox(^M+#3'Попытка чтения марок '+c+' - позиция вне файла!',nil,mfError+mfCancelButton);
     Exit;
    End;

   Seek(f,l);
   ReadMarka(f,s);
   Close(f);
   l:=IOResult;
   Case Field Of
    FName,
    FMarka : GetMarkaField:=S.Marka;
    Else;
   End;
  End;

  {If Not(s.Employ) Then GetMarkaField:='!!!МАРКА УДАЛЕНА!!';}
End;


Function GetExpertField(Field:Byte;C:ArtikulStr):String;
Var f : ExpertFileType;
    l : LongInt;
    s : ExpertType;
    st : ArtikulStr;
    Code : Integer;
    ss : TMyString;
Begin
 GetExpertField:=#0;
 ss[0]:=#0;

 If ReadCashSpr(bExpert,c,ss) Then
   Begin
    GetExpertField:=ss;
    Exit;
   End;

 OldFileMode:=FileMode;
 FileMode:=ReadOnlyN;
 Assign (f,Path^.Dat.ToSPR+'Expert.db');
 GetExpertField:=#0;
 l:=IOResult;
 Reset(f);
 FileMode:=OldFileMode;
 l:=IOResult;
 If l <> 0 Then
 Begin
  MessageBox(^M+#3'Ошибка открытия файла эксп.закл!'+
  ^M+#3'Код:'+IntToStr(l,3),nil,mfError+mfCancelButton);
  Exit;
 End
 Else
  Begin
   DelSpace(c);
   l:=StrToInt(c);

   If l>FileSize(f) Then
    Begin
     System.Close(f);
     l:=IOResult;
     MessageBox(^M+#3'Попытка чтения эксп.закл '+c+' - позиция вне файла!',nil,mfError+mfCancelButton);
     Exit;
    End;

   Seek(f,l);
   ReadExpert(f,s);
   Close(f);
   l:=IOResult;
   Case Field Of
    FName,
    FExpert : GetExpertField:=S.Expert;
    Else;
   End;
  End;

  {If Not(s.Employ) Then GetExpertField:='!!!ЗАКЛЮЧЕНИЕ УДАЛЕНО!!';}
End;


Function GetSpecMarkaField(Field:Byte;C:ArtikulStr):String;
Var f : SpecMarkaFileType;
    l : LongInt;
    s : SpecMarkaType;
    st : ArtikulStr;
    Code : Integer;
    ss : TMyString;
Begin
 GetSpecMarkaField:=#0;
 ss[0]:=#0;


 If ReadCashSpr(bSMarka,c,ss) Then
   Begin
    GetSpecMarkaField:=ss;
    Exit;
   End;

 OldFileMode:=FileMode;
 FileMode:=ReadOnlyN;
 Assign (f,Path^.Dat.ToSPR+'SMarka.db');
 GetSpecMarkaField:=#0;
 l:=IOResult;
 Reset(f);
 FileMode:=OldFileMode;
 l:=IOResult;
 If l <> 0 Then
 Begin
  MessageBox(^M+#3'Ошибка открытия файла спец.марок!'+
  ^M+#3'Код:'+IntToStr(l,3),nil,mfError+mfCancelButton);
  Exit;
 End
 Else
  Begin
   DelSpace(c);
   l:=StrToInt(c);

   If l>FileSize(f) Then
    Begin
     System.Close(f);
     l:=IOResult;
     MessageBox(^M+#3'Попытка чтения спец.марок '+c+' - позиция вне файла!',nil,mfError+mfCancelButton);
     Exit;
    End;

   Seek(f,l);
   ReadSpecMarka(f,s);
   Close(f);
   l:=IOResult;
   Case Field Of
    FName,
    FSpecMarka : GetSpecMarkaField:=S.SpecMarka;
    Else;
   End;
  End;

  {If Not(s.Employ) Then GetSpecMarkaField:='!!!СПЕЦ.МАРКА УДАЛЕНА!!';}
End;



Function GetClassField(Field:Byte;C:ArtikulStr):String;
Var f : ClassFileType;
    l : LongInt;
    s : ClassificatorBuchType;
    st : ArtikulStr;
    Code : Integer;
    ss : TMyString;
Begin
 GetClassField:=#0;
 ss[0]:=#0;


 If ReadCashSpr(bClass,c,ss) Then
   Begin
    GetClassField:=ss;
    Exit;
   End;

 OldFileMode:=FileMode;
 FileMode:=ReadOnlyN;
 Assign (f,Path^.Dat.ToSPR+'class.db');
 GetClassField:=#0;
 l:=IOResult;
 Reset(f);
 FileMode:=OldFileMode;
 l:=IOResult;
 If l <> 0 Then
 Begin
  MessageBox(^M+#3'Ошибка открытия файла групп!'+
  ^M+#3'Код:'+IntToStr(l,3),nil,mfError+mfCancelButton);
  Exit;
 End
 Else
  Begin
   DelSpace(c);
   l:=StrToInt(c);

   If l>FileSize(f) Then
    Begin
     System.Close(f);
     l:=IOResult;
     MessageBox(^M+#3'Попытка чтения групп '+c+' - позиция вне файла!',nil,mfError+mfCancelButton);
     Exit;
    End;

   Seek(f,l);
   ReadClass(f,s);
   Close(f);
   l:=IOResult;
   Case Field Of
    FName,
    FClass : GetClassField:=S.NAme;
    Else;
   End;
  End;

  {If Not(s.Employ) Then GetSpecMarkaField:='!!!СПЕЦ.МАРКА УДАЛЕНА!!';}
End;



Function GetNGTDField(Field:Byte;C:ArtikulStr):String;
Var f : NGTDFileType;
    l : LongInt;
    s : NGTDType;
    st : ArtikulStr;
    Code : Integer;
    ss : TMyString;
Begin
 GetNGTDField:=#0;
 ss[0]:=#0;


 If ReadCashSpr(bNGTD,c,ss) Then
   Begin
    GetNGTDField:=ss;
    Exit;
   End;
 OldFileMode:=FileMode;
 FileMode:=ReadOnlyN;
 Assign (f,Path^.Dat.ToSPR+'ngtd.db');
 GetNGTDField:=#0;
 l:=IOResult;
 Reset(f);
 FileMode:=OldFileMode;
 l:=IOResult;
 If l <> 0 Then
 Begin
  MessageBox(^M+#3'Ошибка открытия файла ГТД!'+
  ^M+#3'Код:'+IntToStr(l,3),nil,mfError+mfCancelButton);
  Exit;
 End
 Else
  Begin
   DelSpace(c);
   l:=StrToInt(c);

   If l>FileSize(f) Then
    Begin
     System.Close(f);
     l:=IOResult;
     MessageBox(^M+#3'Попытка чтения ГТД '+c+' - позиция вне файла!',nil,mfError+mfCancelButton);
     Exit;
    End;

   Seek(f,l);
   ReadNGTD(f,s);
   Close(f);
   l:=IOResult;
   Case Field Of
    FName,
    FNGTD : GetNGTDField:=S.NGTD;
    Else;
   End;
  End;

  {If Not(s.Employ) Then GetNGTDField:='!!!СПРАВКА ГТД УДАЛЕНА!!'};
End;


Function GetMeraField(Field:Byte;C:ArtikulStr):String;
Var f : MeraFileType;
    l : LongInt;
    s : MeraType;
    st : ArtikulStr;
    Code : Integer;
    ss : TMyString;
Begin
 GetMeraField:=#0;
 ss[0]:=#0;


 If ReadCashSpr(bMera,c,ss) Then
   Begin
    GetMeraField:=ss;
    Exit;
   End;

 OldFileMode:=FileMode;
 FileMode:=ReadOnlyN;
 Assign (f,Path^.Dat.ToSPR+'mera.db');
 GetMeraField:=#0;
 l:=IOResult;
 Reset(f);
 FileMode:=OldFileMode;
 l:=IOResult;
 If l <> 0 Then
 Begin
  MessageBox(^M+#3'Ошибка открытия файла единиц измерения!'+
  ^M+#3'Код:'+IntToStr(l,3),nil,mfError+mfCancelButton);
  Exit;
 End
 Else
  Begin
   DelSpace(c);
   l:=StrToInt(c);

   If l>FileSize(f) Then
    Begin
     System.Close(f);
     l:=IOResult;
     MessageBox(^M+#3'Попытка чтения единицы измерения '+c+' - позиция вне файла!',nil,mfError+mfCancelButton);
     Exit;
    End;

   Seek(f,l);
   ReadMera(f,s);
   Close(f);
   Case Field Of
    FName,
    FMera: GetMeraField:=S.Mera;
    Else;
   End;
  End;

  {If Not(s.Employ) Then GetMeraField:='!!!ЕД.ИЗМ.УДАЛЕНА!!';}
End;






Function GetFirmaPostField(Field:Byte;C:ArtikulStr):String;
Var f : FirmaPostFileType;
    l : LongInt;
    s : FirmaPostType;
    st : ArtikulStr;
    Code : Integer;
    ss : TMyString;
Begin
 GetFirmaPostField:=#0;
 ss[0]:=#0;


 If ReadCashSpr(bFirma,c,ss) Then
   Begin
    GetFirmaPostField:=ss;
    Exit;
   End;
 OldFileMode:=FileMode;
 FileMode:=ReadOnlyN;
 Assign (f,Path^.Dat.ToSPR+'firma.db');
 GetFirmaPostField:=#0;
 l:=IOResult;
 Reset(f);
 FileMode:=OldFileMode;
 l:=IOResult;
 If l <> 0 Then
 Begin
  MessageBox(^M+#3'Ошибка открытия файла фирм!'+
  ^M+#3'Код:'+IntToStr(l,3),nil,mfError+mfCancelButton);
  Exit;
 End
 Else
  Begin
   DelSpace(c);
   l:=StrToInt(c);

   If l>FileSize(f) Then
    Begin
     System.Close(f);
     l:=IOResult;
     MessageBox(^M+#3'Попытка чтения фирмы '+c+' - позиция вне файла!',nil,mfError+mfCancelButton);
     Exit;
    End;

   Seek(f,l);
   ReadFirmaPost(f,s);
   Close(f);
   Case Field Of
    FName,
    FPost,
    FFirmaPost,
    fClient,
    FMake  : GetFirmaPostField:=S.FirmaPost;
    Else;
   End;
  End;

  {If Not(s.Employ) Then GetFirmaPostField:='!!!ФИРМА УДАЛЕНА!!!';}
End;


Procedure CorrectRazdel(Cod:Integer);
Label 1;
Var s  : AllStr;
         c,c1  : LongInt;
         Eb : BazFileType;
         BB : PBAzType;
         Es : SkladFileType;
         KdxF : File Of SkladTypeNew;
         SS : PSKladType;
         Kdx : PSKladTypeNew;
         Skf: SkidkaFileType;
         SkS: PSkidkaType;
         MaxDB,MaxSkl,Max,Pr,Emp : AllStr;
         Setup : String[4];
         EDb : SkladFileType;
         ESkl : SkidkaFileType;
         RKod : ArtikulStr;
         Dlg : PDialog;
         R : TRect;
         Control : PView;
         j : Word;
Begin
ClearFind;

If Not(TestOpenDate1(FDate)) Then
        Begin
         MessageBox(#3^M+#3'Доступ к данным за '+FDate+' заблокирован!',Nil,mfError+mfCancelButton);
         Exit;
        End;

If (GlobalReadOnly=1) Or (ReadOnlyConst=1) Then
   Begin
    MessageBox(#3^M+ReadOnlyStr^,Nil,mfWarning+mfCancelButton);
    Exit;
   End;

{
If Not(TestSetupKurs(FDate)) Then
        Begin
         MessageBox(#3^M+#3'Не установлен курс USD на '+FDate+'!',Nil,mfError+mfCancelButton);
         Exit;
        End;
}

C:=IOResult;

If Not(Password(5)) Then Exit;
s:=IntToSTr(Cod,CMAntissa);
RFormatZerro(s,CMAntissa);
RKod:=S;
Assign(Eb,Path^.Dat.ToName+s+'.id');
Reset(Eb);
C:=IOResult;
If C<>0 Then
Begin
 MessageBox(^M+#3'Ошибка доступа к наименований '+Path^.Dat.ToName+s+'.id!',nil,mfError+mfCancelButton);
 Exit;
End;

Max:=IntToSTr(FileSize(Eb),4);
DInfoMsg('Определяю свойства раздела...',True);
New(BB,Init);
Emp[0]:=#0;
Pr[0]:=#0;
While Not(Eof(Eb)) Do
 BEgin
  ReadBazPointer(Eb,BB);
  If (BB^.DAt.Employ) Then
        Begin
         Str((StrToInt(Emp)+1):4,Emp);{занятые позиции}
         Pr:=Copy(BB^.DAt.BAzKod,3,CKod);{последний занятый код}
        End;
 End;
CLose(Eb);
Dispose(BB,Done);



C:=IOResult;
Assign(EDb,Path^.Dat.ToSklad+s+'.db');
Reset(EDb);
C:=IOResult;
If C<>0 Then
Begin
 NoInfoMsg;
 MessagEbox(^M+#3'Ошибка доступа к '+Path^.Dat.ToSklad+s+'.db!',nil,mfError+mfCancelButton);
 Exit;
End;

MaxDb:=IntToSTr(FileSize(EDb),4);
CLose(Edb);
C:=IOResult;


C:=IOResult;
Assign(ESkl,Path^.Dat.ToSkidki+s+'.Skl');
Reset(ESkl);
C:=IOResult;
If C<>0 Then
Begin
 NoInfoMsg;
 MessagEBox(^M+#3'Ошибка доступа к '+Path^.Dat.ToSkidki+s+'.Skl!',nil,mfError+mfCancelButton);
 Exit;
End;

MaxSkl:=IntToSTr(FileSize(ESkl),4);
CLose(Eskl);
C:=IOResult;






NoInfoMsg;

1:
R.Assign(22, 7, 64, 16);
New(Dlg, Init(R, 'Свойства раздела'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx := $E002;


R.Assign(9,3,23,4);
Control := New(PColoredText, Init(R, 'Всего позиций:', $74));
Dlg^.Insert(Control);

R.Assign(23,3,41,4);
STr(StrToInt(MAx):4,MAx);
STr(StrToInt(MAxDb):4,MAxDb);
STr(StrToInt(MAxSkl):4,MAxSkl);
DelSpace(Max);
DelSpace(MaxDb);
DelSpace(MaxSkl);
Control := New(PColoredText, Init(R, ''+Max+','+MaxDB+','+MaxSkl, $7E));
Dlg^.Insert(Control);

R.Assign(2, 2, 23, 3);
Control := New(PColoredText, Init(R, 'Используется позиций:', $74));
Dlg^.Insert(Control);

If StrToInt(MAx)>0 Then
MyStr(StrToInt(Emp)/StrToInt(Max)*100,CLitr+1,CMantissa,s)
Else s:='0.00';

R.Assign(23, 2, 35, 3);
Control := New(PColoredText, Init(R, Emp+' '+s+'%', $7E));
Dlg^.Insert(Control);

R.Assign(2, 1, 35, 2);
Control := New(PColoredText, Init(R, #3+GetRazdel(Rkod)+' ('+
Rkod+')', $7E));
Dlg^.Insert(Control);

R.Assign(1, 6, 41, 7);
Control := New(PStaticText, Init(R, ''));
Control^.Options := Control^.Options or ofFramed;
Dlg^.Insert(Control);


R.Assign(24, 6, 30, 7);
Control := New(PInputLine, Init(R, 4));
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['0','1','2','3','4','5','6','7','8','9']));

  R.Assign(4, 6, 24, 7);
  Dlg^.Insert(New(PLabel, Init(R, 'Установить позиций:', Control)));

R.Assign(6, 4, 23, 5);
Control := New(PColoredText, Init(R, 'Максимальный код:', $74));
Dlg^.Insert(Control);

R.Assign(23, 4, 35, 5);
If pr[0]=#0 Then Pr:='0';
Control := New(PColoredText, Init(R, Pr+' ('+IntToSTr(StrToInt(Pr),4)+')', $7E));
Dlg^.Insert(Control);

Setup:=Max;
DelSpace(Setup);
Dlg^.SetData(Setup);

Dlg^.SelectNext(False);
c:=Desktop^.ExecView(Dlg);
if c<>cmCancel Then
  BEgin
        Dlg^.GetData(Setup);
        If StrToInt(Setup)<(StrToInt(Pr)+1) Then
         BEgin
          Dispose(Control,Done);
          Dispose(Dlg,Done);
          MessageBox(RestructError^,Nil,mfError+mfCAncelButton);
          Goto 1;
         End;

        If StrToInt(Setup)>(1000) Then
         BEgin
          Dispose(Control,Done);
          Dispose(Dlg,Done);
          MessageBox(^M+#3'Слишком большое количество элементов внутри раздела! ',Nil,
          mfError+mfCAncelButton);
          Goto 1;
         End;

Dispose(Control,Done);
Dispose(Dlg,Done);


DInfoMsg('Провожу реструктуризацию. Ждите ...',True);


        If StrToInt(Setup)>StrToInt(MAx) Then{надо добавлять позиции}
        Begin
         Assign(Eb,Path^.Dat.ToName+RKod+'.id');
         Reset(Eb);
         c:=Ioresult;
         If c=0 Then
         Begin
          Seek(Eb,StrToInt(Max));
          New(bb,Init);
          For c:=1 To (StrToInt(Setup)-StrToInt(MAx)) Do
                Begin
                 Str(C+StrToInt(MAx)-1:3,S);
                 RFormatZerro(s,3);
                 bb^.Dat.BazKod:=RKod+s;
                 bb^.Dat.FantomKod:=bb^.Dat.BazKod;
                 bb^.Dat.Employ:=False;
                 bb^.Dat.Caption:=CurrentPassword;
                 Seek(eb,FileSize(eb));
                 Write(eb,bb^.Dat);
                End;
          Dispose(bb,Done);
          c:=Ioresult;
          Close(Eb);
          c:=Ioresult;
         End{If}
          Else
                Begin
                 NoInfoMsg;
                 MessageBox(^M+#3'Ошибка открытия '+Path^.Dat.ToName+RKod+'.id',Nil,mfError+mfCancelButton);
                 Exit;
                End;{Else}

         Assign(Es,Path^.Dat.ToSklad+RKod+'.db');
         Reset(Es);
         c:=Ioresult;
         If c=0 Then
         Begin
          Seek(Es,StrToInt(Max));
          New(ss,Init);
          For c:=1 To (StrToInt(Setup)-StrToInt(MAx)) Do
                Begin
                 Str(C-1+StrToInt(MAx):3,S);
                 RFormatZerro(s,3);
                 ss^.Dat.BazKod:=RKod+s;
                 ss^.Dat.Employ:=False;
                 ss^.Dat.Time:=CurrentTime;
                 ss^.Dat.Date:=DateStringToDAte(DateMask,FDate);
                 Seek(es,FileSize(es));
                 Write(es,ss^.Dat);
                End;
          Dispose(ss,Done);
          c:=Ioresult;
          Close(Es);
          c:=Ioresult;
         End{If}
          Else
                Begin
                 NoInfoMsg;
                 MessageBox(^M+#3'Ошибка открытия '+Path^.Dat.ToSklad+RKod+'.db',Nil,mfError+mfCancelButton);
                 Exit;
                End;{Else}

         Assign(skf,Path^.Dat.ToSkidki+RKod+'.skl');
         Reset(skf);
         c:=Ioresult;
         If c=0 Then
         Begin
          Seek(skf,StrToInt(Max));
          New(sks,Init);
          For c:=1 To (StrToInt(Setup)-StrToInt(MAx)) Do
                Begin
                 Str(C-1+StrToInt(MAx):3,S);
                 RFormatZerro(s,3);
                 For c1:=1 To 6 Do
                 Begin
                  sks^.Dat.Skidka[c1].Up:='0.00';
                  sks^.Dat.Skidka[c1].Proz:='0.00';
                 End;
                 sks^.Dat.Caption:=CurrentPassword;
                 sks^.Dat.BazKod:=RKod+s;
                 sks^.Dat.Time:=Times;
                 sks^.Dat.Date:=FDate;
                 Seek(skf,FileSize(skf));
                 Write(skf,sks^.Dat);
                End;
          Dispose(sks,Done);
          c:=Ioresult;
          Close(skf);
          c:=Ioresult;
         End{If}
          Else
                Begin
                 NoInfoMsg;
                 MessageBox(^M+#3'Ошибка открытия '+Path^.Dat.ToSkidki+RKod+'.skl',Nil,mfError+mfCancelButton);
                 Exit;
                End;{Else}

         {модернизируем быстпый индекс для открытия окна продаж}
         Assign(KdxF,Path^.Dat.ToInDex+RKod+'.kdx');
         Reset(KdxF);
         c:=Ioresult;
         If c=0 Then
         Begin
          Seek(kdxf,StrToInt(Max));
          New(Kdx,Init);
          For c:=1 To (StrToInt(Setup)-StrToInt(MAx)) Do
                Begin
                 Str(C-1+StrToInt(MAx):3,S);
                 RFormatZerro(s,3);
                 Kdx^.Dat.BazKod:=StrToInt(RKod+s);
                 Kdx^.Dat.Name [0]:=#0;
                 Kdx^.Dat.Name2[0]:=#0;
                 Kdx^.Dat.Virabotano :=0;
                 Kdx^.Dat.NMakeKod:=0;
                 {Kdx^.Dat.NGroupKod:=0;}
                 Kdx^.Dat.FantomKod:=Kdx^.Dat.BazKod;
                 Kdx^.Dat.Employ :=False;
                 Kdx^.Dat.NSertif :=Glob.NoSertif;
                 For j:=1 To CDivision Do Kdx^.Dat.Division[j]:=0;
                 For j:=1 To CDivision Do Kdx^.Dat.DivisionR[j]:=0;
                 Kdx^.Dat.R_Zena  :=0.00;
                 Kdx^.Dat.RegionMarka:=0;
                 Seek(kdxf,FileSize(kdxf));
                 Write(kdxf,kdx^.Dat);
                End;
          Dispose(kdx,Done);
          c:=Ioresult;
          Close(kdxF);
          c:=Ioresult;
         End{If}
          Else
                Begin
                 NoInfoMsg;
                 MessageBox(^M+#3'Ошибка открытия '+Path^.Dat.ToIndex+RKod+'.kdx',Nil,mfError+mfCancelButton);
                 Exit;
                End;{Else}

        End;


If StrToInt(Setup)<=StrToInt(MAx) Then{надо сокращать позиции}
Begin
         Assign(Eb,Path^.Dat.ToName+RKod+'.id');
         Reset(Eb);
         c:=Ioresult;
         If c=0 Then
         Begin
         Seek(Eb,StrToInt(Setup));
         c:=Ioresult;
         Truncate(Eb);
         c:=Ioresult;
         Close(Eb);
         c:=Ioresult;
         End
         Else
          Begin
                NoInfoMsg;
                MessageBox(^M+#3'Ошибка открытия '+Path^.Dat.ToName+RKod+'.id',Nil,mfError+mfCancelButton);
                Exit;
          End;

         Assign(Es,Path^.Dat.ToSklad+RKod+'.db');
         Reset(Es);
         c:=Ioresult;
         If c=0 Then
         Begin
         Seek(Es,StrToInt(Setup));
         c:=Ioresult;
         Truncate(Es);
         c:=Ioresult;
         Close(Es);
         c:=Ioresult;
         End
         Else
          Begin
                NoInfoMsg;
                MessageBox(^M+#3'Ошибка открытия '+Path^.Dat.ToSklad+RKod+'.db',Nil,mfError+mfCancelButton);
                Exit;
          End;


         Assign(skf,Path^.Dat.ToSkidki+RKod+'.skl');
         Reset(skf);
         c:=Ioresult;
         If c=0 Then
         Begin
         Seek(skf,StrToInt(Setup));
         c:=Ioresult;
         Truncate(skf);
         c:=Ioresult;
         Close(skf);
         c:=Ioresult;
         End
         Else
          Begin
                NoInfoMsg;
                MessageBox(^M+#3'Ошибка открытия '+Path^.Dat.ToSkidki+RKod+'.skl',Nil,mfError+mfCancelButton);
                Exit;
          End;


         Assign(kdxF,Path^.Dat.ToIndex+RKod+'.kdx');
         Reset(kdxf);
         c:=Ioresult;
         If c=0 Then
         Begin
         Seek(kdxf,StrToInt(Setup));
         c:=Ioresult;
         Truncate(kdxf);
         c:=Ioresult;
         Close(kdxf);
         c:=Ioresult;
         End
         Else
          Begin
                NoInfoMsg;
                MessageBox(^M+#3'Ошибка открытия '+Path^.Dat.ToIndex+RKod+'.kdx',Nil,mfError+mfCancelButton);
                Exit;
          End;
End;
NoInfoMsg;

   MessageBox(^M+#3+'Реструктаризация успешно завершена!',Nil,mfInformation+mfCancelButton);
   AddProtocol('Реструктаризация раздела ' +RKod,'','');

  End
Else
Begin
Dispose(Control,Done);
Dispose(Dlg,Done);
End;

End;






Procedure CorrectMarka;
Label 1;
Var      s  : AllStr;
         c,c1  : LongInt;
         Eb : File Of MarkaType;
         BB : PMarkaType;
         Max,Pr,Emp : AllStr;
         Setup : String[5];
         RKod : ArtikulStr;
         Dlg : PDialog;
         R : TRect;
         Control : PView;
         j : Word;
Begin
ClearFind;

If Not(TestOpenDate1(FDate)) Then
        Begin
         MessageBox(#3^M+#3'Доступ к данным за '+FDate+' заблокирован!',Nil,mfError+mfCancelButton);
         Exit;
        End;

If (GlobalReadOnly=1) Or (ReadOnlyConst=1) Then
   Begin
    MessageBox(#3^M+ReadOnlyStr^,Nil,mfWarning+mfCancelButton);
    Exit;
   End;


C:=IOResult;

If Not(Password(5)) Then Exit;

Assign(Eb,Path^.Dat.ToSPR+'Marka.db');
Reset(Eb);
C:=IOResult;
If C<>0 Then
Begin
 MessageBox(^M+#3'Ошибка доступа к '+Path^.Dat.ToSPR+'Marka.db',nil,mfError+mfCancelButton);
 Exit;
End;

Max:=IntToSTr(FileSize(Eb),5);
DInfoMsg('Определяю свойства базы...',True);
New(BB,Init);
Emp[0]:=#0;
Pr[0]:=#0;
While Not(Eof(Eb)) Do
 BEgin

 Read(Eb,BB^.Dat);

 If (BB^.DAt.Employ) Then
        Begin
         Str((StrToInt(Emp)+1):5,Emp);{занятые позиции}
         {Pr:=IntToStr(FilePos(Eb),CDate);{последний занятый код}
         Pr:=IntToStr(StrToInt(BB^.DAt.Kod),CArtikul);
        End;


 End;
CLose(Eb);
Dispose(BB,Done);
NoInfoMsg;

1:
R.Assign(22, 7, 61, 16);
New(Dlg, Init(R, 'Свойства базы'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx := $E002;


R.Assign(9,3,23,4);
Control := New(PColoredText, Init(R, 'Всего позиций:', $74));
Dlg^.Insert(Control);

R.Assign(23, 3, 28, 4);
STr(StrToInt(MAx):5,MAx);
Control := New(PColoredText, Init(R, #3+Max, $7E));
Dlg^.Insert(Control);

R.Assign(2, 2, 23, 3);
Control := New(PColoredText, Init(R, 'Используется позиций:', $74));
Dlg^.Insert(Control);

If StrToInt(MAx)>0 Then
MyStr(StrToInt(Emp)/StrToInt(Max)*100,CLitr+1,CMantissa,s)
Else s:='0.00';

R.Assign(23, 2, 38, 3);
Control := New(PColoredText, Init(R, Emp+' '+s+'%', $7E));
Dlg^.Insert(Control);


R.Assign(1, 6, 38, 7);
Control := New(PStaticText, Init(R, ''));
Control^.Options := Control^.Options or ofFramed;
Dlg^.Insert(Control);


R.Assign(24, 6, 31, 7);
Control := New(PInputLine, Init(R, 5));
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['0','1','2','3','4','5','6','7','8','9']));

  R.Assign(4, 6, 24, 7);
  Dlg^.Insert(New(PLabel, Init(R, 'Установить позиций:', Control)));

R.Assign(6, 4, 23, 5);
Control := New(PColoredText, Init(R, 'Максимальный код:', $74));
Dlg^.Insert(Control);

R.Assign(23, 4, 35, 5);
If pr[0]=#0 Then Pr:='0';
Control := New(PColoredText, Init(R, Pr+' ('+IntToSTr(StrToInt(Pr),5)+')', $7E));
Dlg^.Insert(Control);

Setup:=Max;
DelSpace(Setup);
Dlg^.SetData(Setup);

Dlg^.SelectNext(False);
c:=Desktop^.ExecView(Dlg);
if c<>cmCancel Then
  BEgin

        Dlg^.GetData(Setup);
        If StrToInt(Setup)<(StrToInt(Pr)+1) Then
         BEgin
          Dispose(Control,Done);
          Dispose(Dlg,Done);
          MessageBox(RestructError^,Nil,mfError+mfCAncelButton);
          Goto 1;
         End;

Dispose(Control,Done);
Dispose(Dlg,Done);


DInfoMsg('Провожу реструктуризацию. Ждите ...',True);


        If StrToInt(Setup)>StrToInt(MAx) Then{надо добавлять позиции}
        Begin
         Assign(Eb,Path^.Dat.ToSPR+'marka.db');
         Reset(Eb);
         c:=Ioresult;
         If c=0 Then
         Begin
          Seek(Eb,StrToInt(Max));
          New(bb,Init);
          For c:=1 To (StrToInt(Setup)-StrToInt(MAx)) Do
                Begin
   BB^.Dat.Employ :=False;
   Str(C-1+StrToInt(MAx):CArtikul,S);
   BB^.Dat.Kod :=s;
   RFormatZerro(BB^.Dat.Kod,CArtikul);
   BB^.Dat.Marka[0] :=#0;
   BB^.Dat.RCD:=False;
                 Seek(eb,FileSize(eb));
                 Write(eb,bb^.Dat);
                End;
          Dispose(bb,Done);
          c:=Ioresult;
          Close(Eb);
          c:=Ioresult;
         End{If}
          Else
                Begin
                 NoInfoMsg;
                 MessageBox(^M+#3'Ошибка открытия '+Path^.Dat.ToSPR+'marka.db',Nil,mfError+mfCancelButton);
                 Exit;
                End;{Else}

        End;


If StrToInt(Setup)<=StrToInt(MAx) Then{надо сокращать позиции}
Begin
         Assign(Eb,Path^.Dat.ToSPR+'marka.db');
         Reset(Eb);
         c:=Ioresult;
         If c=0 Then
         Begin
         Seek(Eb,StrToInt(Setup));
         c:=Ioresult;
         Truncate(Eb);
         c:=Ioresult;
         Close(Eb);
         c:=Ioresult;
         End
         Else
          Begin
                NoInfoMsg;
                MessageBox(^M+#3'Ошибка открытия '+Path^.Dat.ToSPR+'marka.db',Nil,mfError+mfCancelButton);
                Exit;
          End;

End;
   NoInfoMsg;
   MessageBox(^M+#3+'Реструктаризация успешно завершена!',Nil,mfInformation+mfCancelButton);
   AddProtocol('Реструктаризация базы '+Path^.Dat.ToSPR+'marka.db','','');
   RefreshCashOneSPR(bMarka);
  End
Else
Begin
Dispose(Control,Done);
Dispose(Dlg,Done);


End;

End;


Procedure CorrectSMarka;
Label 1;
Var      s  : AllStr;
         c,c1  : LongInt;
         Eb : File Of SpecMarkaType;
         BB : PSPecMarkaType;
         Max,Pr,Emp : AllStr;
         Setup : String[5];
         RKod : ArtikulStr;
         Dlg : PDialog;
         R : TRect;
         Control : PView;
         j : Word;
Begin
ClearFind;

If Not(TestOpenDate1(FDate)) Then
        Begin
         MessageBox(#3^M+#3'Доступ к данным за '+FDate+' заблокирован!',Nil,mfError+mfCancelButton);
         Exit;
        End;

If (GlobalReadOnly=1) Or (ReadOnlyConst=1) Then
   Begin
    MessageBox(#3^M+ReadOnlyStr^,Nil,mfWarning+mfCancelButton);
    Exit;
   End;


C:=IOResult;

If Not(Password(5)) Then Exit;

Assign(Eb,Path^.Dat.ToSPR+'SMarka.db');
Reset(Eb);
C:=IOResult;
If C<>0 Then
Begin
 MessageBox(^M+#3'Ошибка доступа к '+Path^.Dat.ToSPR+'SMarka.db',nil,mfError+mfCancelButton);
 Exit;
End;

Max:=IntToSTr(FileSize(Eb),5);
DInfoMsg('Определяю свойства базы...',True);
New(BB,Init);
Emp[0]:=#0;
Pr[0]:=#0;
While Not(Eof(Eb)) Do
 BEgin

 Read(Eb,BB^.Dat);

 If (BB^.DAt.Employ) Then
        Begin
         Str((StrToInt(Emp)+1):5,Emp);{занятые позиции}
         {Pr:=IntToStr(FilePos(Eb),CDate);{последний занятый код}
         Pr:=IntToStr(StrToInt(BB^.DAt.Kod),CArtikul);
        End;


 End;
CLose(Eb);
Dispose(BB,Done);
NoInfoMsg;

1:
R.Assign(22, 7, 61, 16);
New(Dlg, Init(R, 'Свойства базы'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx := $E002;


R.Assign(9,3,23,4);
Control := New(PColoredText, Init(R, 'Всего позиций:', $74));
Dlg^.Insert(Control);

R.Assign(23, 3, 28, 4);
STr(StrToInt(MAx):5,MAx);
Control := New(PColoredText, Init(R, #3+Max, $7E));
Dlg^.Insert(Control);

R.Assign(2, 2, 23, 3);
Control := New(PColoredText, Init(R, 'Используется позиций:', $74));
Dlg^.Insert(Control);

If StrToInt(MAx)>0 Then
MyStr(StrToInt(Emp)/StrToInt(Max)*100,CLitr+1,CMantissa,s)
Else s:='0.00';

R.Assign(23, 2, 38, 3);
Control := New(PColoredText, Init(R, Emp+' '+s+'%', $7E));
Dlg^.Insert(Control);


R.Assign(1, 6, 38, 7);
Control := New(PStaticText, Init(R, ''));
Control^.Options := Control^.Options or ofFramed;
Dlg^.Insert(Control);


R.Assign(24, 6, 31, 7);
Control := New(PInputLine, Init(R, 5));
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['0','1','2','3','4','5','6','7','8','9']));

  R.Assign(4, 6, 24, 7);
  Dlg^.Insert(New(PLabel, Init(R, 'Установить позиций:', Control)));

R.Assign(6, 4, 23, 5);
Control := New(PColoredText, Init(R, 'Максимальный код:', $74));
Dlg^.Insert(Control);

R.Assign(23, 4, 35, 5);
If pr[0]=#0 Then Pr:='0';
Control := New(PColoredText, Init(R, Pr+' ('+IntToSTr(StrToInt(Pr),5)+')', $7E));
Dlg^.Insert(Control);

Setup:=Max;
DelSpace(Setup);
Dlg^.SetData(Setup);

Dlg^.SelectNext(False);
c:=Desktop^.ExecView(Dlg);
if c<>cmCancel Then
  BEgin

        Dlg^.GetData(Setup);
        If StrToInt(Setup)<(StrToInt(Pr)+1) Then
         BEgin
          Dispose(Control,Done);
          Dispose(Dlg,Done);
          MessageBox(RestructError^,Nil,mfError+mfCAncelButton);
          Goto 1;
         End;

Dispose(Control,Done);
Dispose(Dlg,Done);


DInfoMsg('Провожу реструктуризацию. Ждите ...',True);


        If StrToInt(Setup)>StrToInt(MAx) Then{надо добавлять позиции}
        Begin
         Assign(Eb,Path^.Dat.ToSPR+'SMarka.db');
         Reset(Eb);
         c:=Ioresult;
         If c=0 Then
         Begin
          Seek(Eb,StrToInt(Max));
          New(bb,Init);
          For c:=1 To (StrToInt(Setup)-StrToInt(MAx)) Do
                Begin
   BB^.Dat.Employ :=False;
   Str(C-1+StrToInt(MAx):CArtikul,S);
   BB^.Dat.Kod :=s;
   RFormatZerro(BB^.Dat.Kod,CArtikul);
   BB^.Dat.SpecMarka[0] :=#0;
   BB^.Dat.RCD:=False;
                 Seek(eb,FileSize(eb));
                 Write(eb,bb^.Dat);
                End;
          Dispose(bb,Done);
          c:=Ioresult;
          Close(Eb);
          c:=Ioresult;
         End{If}
          Else
                Begin
                 NoInfoMsg;
                 MessageBox(^M+#3'Ошибка открытия '+Path^.Dat.ToSPR+'SMarka.db',Nil,mfError+mfCancelButton);
                 Exit;
                End;{Else}

        End;


If StrToInt(Setup)<=StrToInt(MAx) Then{надо сокращать позиции}
Begin
         Assign(Eb,Path^.Dat.ToSPR+'SMarka.db');
         Reset(Eb);
         c:=Ioresult;
         If c=0 Then
         Begin
         Seek(Eb,StrToInt(Setup));
         c:=Ioresult;
         Truncate(Eb);
         c:=Ioresult;
         Close(Eb);
         c:=Ioresult;
         End
         Else
          Begin
                NoInfoMsg;
                MessageBox(^M+#3'Ошибка открытия '+Path^.Dat.ToSPR+'SMarka.db',Nil,mfError+mfCancelButton);
                Exit;
          End;

End;
   NoInfoMsg;
   MessageBox(^M+#3+'Реструктаризация успешно завершена!',Nil,mfInformation+mfCancelButton);
   AddProtocol('Реструктаризация базы '+Path^.Dat.ToSPR+'SMarka.db','','');
   RefreshCashOneSPR(bSMarka);
  End
Else
Begin
Dispose(Control,Done);
Dispose(Dlg,Done);
End;
End;







Procedure CorrectExpert;
Label 1;
Var      s  : AllStr;
         c,c1  : LongInt;
         Eb : File Of ExpertType;
         BB : PExpertType;
         Max,Pr,Emp : AllStr;
         Setup : String[5];
         RKod : ArtikulStr;
         Dlg : PDialog;
         R : TRect;
         Control : PView;
         j : Word;
Begin
ClearFind;

If Not(TestOpenDate1(FDate)) Then
        Begin
         MessageBox(#3^M+#3'Доступ к данным за '+FDate+' заблокирован!',Nil,mfError+mfCancelButton);
         Exit;
        End;

If (GlobalReadOnly=1) Or (ReadOnlyConst=1) Then
   Begin
    MessageBox(#3^M+ReadOnlyStr^,Nil,mfWarning+mfCancelButton);
    Exit;
   End;


C:=IOResult;

If Not(Password(5)) Then Exit;

Assign(Eb,Path^.Dat.ToSPR+'Expert.db');
Reset(Eb);
C:=IOResult;
If C<>0 Then
Begin
 MessageBox(^M+#3'Ошибка доступа к '+Path^.Dat.ToSPR+'Expert.db',nil,mfError+mfCancelButton);
 Exit;
End;

Max:=IntToSTr(FileSize(Eb),5);
DInfoMsg('Определяю свойства базы...',True);
New(BB,Init);
Emp[0]:=#0;
Pr[0]:=#0;
While Not(Eof(Eb)) Do
 BEgin

 Read(Eb,BB^.Dat);

 If (BB^.DAt.Employ) Then
        Begin
         Str((StrToInt(Emp)+1):5,Emp);{занятые позиции}
         {Pr:=IntToStr(FilePos(Eb),CDate);{последний занятый код}
         Pr:=IntToStr(StrToInt(BB^.DAt.Kod),CArtikul);
        End;


 End;
CLose(Eb);
Dispose(BB,Done);
NoInfoMsg;

1:
R.Assign(22, 7, 61, 16);
New(Dlg, Init(R, 'Свойства базы'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx := $E002;


R.Assign(9,3,23,4);
Control := New(PColoredText, Init(R, 'Всего позиций:', $74));
Dlg^.Insert(Control);

R.Assign(23, 3, 28, 4);
STr(StrToInt(MAx):5,MAx);
Control := New(PColoredText, Init(R, #3+Max, $7E));
Dlg^.Insert(Control);

R.Assign(2, 2, 23, 3);
Control := New(PColoredText, Init(R, 'Используется позиций:', $74));
Dlg^.Insert(Control);

If StrToInt(MAx)>0 Then
MyStr(StrToInt(Emp)/StrToInt(Max)*100,CLitr+1,CMantissa,s)
Else s:='0.00';

R.Assign(23, 2, 38, 3);
Control := New(PColoredText, Init(R, Emp+' '+s+'%', $7E));
Dlg^.Insert(Control);


R.Assign(1, 6, 38, 7);
Control := New(PStaticText, Init(R, ''));
Control^.Options := Control^.Options or ofFramed;
Dlg^.Insert(Control);


R.Assign(24, 6, 31, 7);
Control := New(PInputLine, Init(R, 5));
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['0','1','2','3','4','5','6','7','8','9']));

  R.Assign(4, 6, 24, 7);
  Dlg^.Insert(New(PLabel, Init(R, 'Установить позиций:', Control)));

R.Assign(6, 4, 23, 5);
Control := New(PColoredText, Init(R, 'Максимальный код:', $74));
Dlg^.Insert(Control);

R.Assign(23, 4, 35, 5);
If pr[0]=#0 Then Pr:='0';
Control := New(PColoredText, Init(R, Pr+' ('+IntToSTr(StrToInt(Pr),5)+')', $7E));
Dlg^.Insert(Control);

Setup:=Max;
DelSpace(Setup);
Dlg^.SetData(Setup);

Dlg^.SelectNext(False);
c:=Desktop^.ExecView(Dlg);
if c<>cmCancel Then
  BEgin

        Dlg^.GetData(Setup);
        If StrToInt(Setup)<(StrToInt(Pr)+1) Then
         BEgin
          Dispose(Control,Done);
          Dispose(Dlg,Done);
          MessageBox(RestructError^,Nil,mfError+mfCAncelButton);
          Goto 1;
         End;

Dispose(Control,Done);
Dispose(Dlg,Done);


DInfoMsg('Провожу реструктуризацию. Ждите ...',True);


        If StrToInt(Setup)>StrToInt(MAx) Then{надо добавлять позиции}
        Begin
         Assign(Eb,Path^.Dat.ToSPR+'Expert.db');
         Reset(Eb);
         c:=Ioresult;
         If c=0 Then
         Begin
          Seek(Eb,StrToInt(Max));
          New(bb,Init);
          For c:=1 To (StrToInt(Setup)-StrToInt(MAx)) Do
                Begin
   BB^.Dat.Employ :=False;
   Str(C-1+StrToInt(MAx):CArtikul,S);
   BB^.Dat.Kod :=s;
   RFormatZerro(BB^.Dat.Kod,CArtikul);
   BB^.Dat.Expert[0] :=#0;
   BB^.Dat.RCD:=False;
                 Seek(eb,FileSize(eb));
                 Write(eb,bb^.Dat);
                End;
          Dispose(bb,Done);
          c:=Ioresult;
          Close(Eb);
          c:=Ioresult;
         End{If}
          Else
                Begin
                 NoInfoMsg;
                 MessageBox(^M+#3'Ошибка открытия '+Path^.Dat.ToSPR+'Expert.db',Nil,mfError+mfCancelButton);
                 Exit;
                End;{Else}

        End;


If StrToInt(Setup)<=StrToInt(MAx) Then{надо сокращать позиции}
Begin
         Assign(Eb,Path^.Dat.ToSPR+'Expert.db');
         Reset(Eb);
         c:=Ioresult;
         If c=0 Then
         Begin
         Seek(Eb,StrToInt(Setup));
         c:=Ioresult;
         Truncate(Eb);
         c:=Ioresult;
         Close(Eb);
         c:=Ioresult;
         End
         Else
          Begin
                NoInfoMsg;
                MessageBox(^M+#3'Ошибка открытия '+Path^.Dat.ToSPR+'Expert.db',Nil,mfError+mfCancelButton);
                Exit;
          End;

End;
   NoInfoMsg;
   MessageBox(^M+#3+'Реструктаризация успешно завершена!',Nil,mfInformation+mfCancelButton);
   AddProtocol('Реструктаризация базы '+Path^.Dat.ToSPR+'Expert.db','','');
   RefreshCashOneSPR(bExpert);
  End
Else
Begin
Dispose(Control,Done);
Dispose(Dlg,Done);


End;

End;


Procedure CorrectKSertif;
Label 1;
Var      s  : AllStr;
         c,c1  : LongInt;
         Eb : File Of KSertifType;
         BB : PKSertifType;
         Max,Pr,Emp : AllStr;
         Setup : String[5];
         RKod : ArtikulStr;
         Dlg : PDialog;
         R : TRect;
         Control : PView;
         j : Word;
Begin
ClearFind;

If Not(TestOpenDate1(FDate)) Then
        Begin
         MessageBox(#3^M+#3'Доступ к данным за '+FDate+' заблокирован!',Nil,mfError+mfCancelButton);
         Exit;
        End;

If (GlobalReadOnly=1) Or (ReadOnlyConst=1) Then
   Begin
    MessageBox(#3^M+ReadOnlyStr^,Nil,mfWarning+mfCancelButton);
    Exit;
   End;

C:=IOResult;

If Not(Password(5)) Then Exit;

Assign(Eb,Path^.Dat.ToSPR+'KSertif.db');
Reset(Eb);
C:=IOResult;
If C<>0 Then
Begin
 MessageBox(^M+#3'Ошибка доступа к '+Path^.Dat.ToSPR+'KSertif.db',nil,mfError+mfCancelButton);
 Exit;
End;

Max:=IntToSTr(FileSize(Eb),CClientKod);
DInfoMsg('Определяю свойства базы...',True);
New(BB,Init);
Emp[0]:=#0;
Pr[0]:=#0;
While Not(Eof(Eb)) Do
 BEgin

 Read(Eb,BB^.Dat);

 If (BB^.DAt.Employ) Then
        Begin
         Str((StrToInt(Emp)+1):CClientKod,Emp);{занятые позиции}
         {Pr:=IntToStr(FilePos(Eb),CDate);{последний занятый код}
         Pr:=IntToStr(StrToInt(BB^.DAt.Kod),CClientKod);
        End;


 End;
CLose(Eb);
Dispose(BB,Done);
NoInfoMsg;

1:
R.Assign(22, 7, 61, 16);
New(Dlg, Init(R, 'Свойства базы'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx := $E002;


R.Assign(9,3,23,4);
Control := New(PColoredText, Init(R, 'Всего позиций:', $74));
Dlg^.Insert(Control);

R.Assign(23, 3, 28, 4);
STr(StrToInt(MAx):CClientKod,MAx);
Control := New(PColoredText, Init(R, #3+Max, $7E));
Dlg^.Insert(Control);

R.Assign(2, 2, 23, 3);
Control := New(PColoredText, Init(R, 'Используется позиций:', $74));
Dlg^.Insert(Control);

If StrToInt(MAx)>0 Then
MyStr(StrToInt(Emp)/StrToInt(Max)*100,CLitr+1,CMantissa,s)
Else s:='0.00';

R.Assign(23, 2, 38, 3);
Control := New(PColoredText, Init(R, Emp+' '+s+'%', $7E));
Dlg^.Insert(Control);


R.Assign(1, 6, 38, 7);
Control := New(PStaticText, Init(R, ''));
Control^.Options := Control^.Options or ofFramed;
Dlg^.Insert(Control);


R.Assign(24, 6, 31, 7);
Control := New(PInputLine, Init(R, CClientKod));
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['0','1','2','3','4','5','6','7','8','9']));

  R.Assign(4, 6, 24, 7);
  Dlg^.Insert(New(PLabel, Init(R, 'Установить позиций:', Control)));

R.Assign(6, 4, 23, 5);
Control := New(PColoredText, Init(R, 'Максимальный код:', $74));
Dlg^.Insert(Control);

R.Assign(23, 4, 35, 5);
If pr[0]=#0 Then Pr:='0';
Control := New(PColoredText, Init(R, Pr+' ('+IntToSTr(StrToInt(Pr),CClientKod)+')', $7E));
Dlg^.Insert(Control);

Setup:=Max;
DelSpace(Setup);
Dlg^.SetData(Setup);

Dlg^.SelectNext(False);
c:=Desktop^.ExecView(Dlg);
if c<>cmCancel Then
  BEgin

        Dlg^.GetData(Setup);
        If StrToInt(Setup)<(StrToInt(Pr)+1) Then
         BEgin
          Dispose(Control,Done);
          Dispose(Dlg,Done);
          MessageBox(RestructError^,Nil,mfError+mfCAncelButton);
          Goto 1;
         End;

Dispose(Control,Done);
Dispose(Dlg,Done);


DInfoMsg('Провожу реструктуризацию. Ждите ...',True);


        If StrToInt(Setup)>StrToInt(MAx) Then{надо добавлять позиции}
        Begin
         Assign(Eb,Path^.Dat.ToSPR+'KSertif.db');
         Reset(Eb);
         c:=Ioresult;
         If c=0 Then
         Begin
          Seek(Eb,StrToInt(Max));
          New(bb,Init);
          For c:=1 To (StrToInt(Setup)-StrToInt(MAx)) Do
                Begin
   BB^.Dat.Employ :=False;
   Str(C-1+StrToInt(MAx):CClientKOd,S);
   BB^.Dat.Kod :=s;
   RFormatZerro(BB^.Dat.Kod,CClientKod);
   BB^.Dat.KSertif[0] :=#0;
   BB^.Dat.RCD:=False;
                 Seek(eb,FileSize(eb));
                 Write(eb,bb^.Dat);
                End;
          Dispose(bb,Done);
          c:=Ioresult;
          Close(Eb);
          c:=Ioresult;
         End{If}
          Else
                Begin
                 NoInfoMsg;
                 MessageBox(^M+#3'Ошибка открытия '+Path^.Dat.ToSPR+'KSertif.db',Nil,mfError+mfCancelButton);
                 Exit;
                End;{Else}

        End;


If StrToInt(Setup)<=StrToInt(MAx) Then{надо сокращать позиции}
Begin
         Assign(Eb,Path^.Dat.ToSPR+'KSertif.db');
         Reset(Eb);
         c:=Ioresult;
         If c=0 Then
         Begin
         Seek(Eb,StrToInt(Setup));
         c:=Ioresult;
         Truncate(Eb);
         c:=Ioresult;
         Close(Eb);
         c:=Ioresult;
         End
         Else
          Begin
                NoInfoMsg;
                MessageBox(^M+#3'Ошибка открытия '+Path^.Dat.ToSPR+'KSertif.db',Nil,mfError+mfCancelButton);
                Exit;
          End;

End;
   NoInfoMsg;
   MessageBox(^M+#3+'Реструктаризация успешно завершена!',Nil,mfInformation+mfCancelButton);
   AddProtocol('Реструктаризация базы '+Path^.Dat.ToSPR+'KSertif.db','','');
   RefreshCashOneSPR(bKSertif);
  End
Else
Begin
Dispose(Control,Done);
Dispose(Dlg,Done);
End;

End;


Procedure CorrectClass;
Label 1;
Var      s  : AllStr;
         c,c1  : LongInt;
         Eb : File Of ClassificatorBuchTYPE;
         BB : PClassificatorBuchType;
         Max,Pr,Emp : AllStr;
         Setup : String[5];
         RKod : ArtikulStr;
         Dlg : PDialog;
         R : TRect;
         Control : PView;
         j : Word;
Begin
ClearFind;

If Not(TestOpenDate1(FDate)) Then
        Begin
         MessageBox(#3^M+#3'Доступ к данным за '+FDate+' заблокирован!',Nil,mfError+mfCancelButton);
         Exit;
        End;

If (GlobalReadOnly=1) Or (ReadOnlyConst=1) Then
   Begin
    MessageBox(#3^M+ReadOnlyStr^,Nil,mfWarning+mfCancelButton);
    Exit;
   End;

C:=IOResult;

If Not(Password(5)) Then Exit;

Assign(Eb,Path^.Dat.ToSPR+'Class.db');
Reset(Eb);
C:=IOResult;
If C<>0 Then
Begin
 MessageBox(^M+#3'Ошибка доступа к '+Path^.Dat.ToSPR+'Class.db',nil,mfError+mfCancelButton);
 Exit;
End;

Max:=IntToSTr(FileSize(Eb),CClientKod);
DInfoMsg('Определяю свойства базы...',True);
New(BB,Init);
Emp[0]:=#0;
Pr[0]:=#0;
While Not(Eof(Eb)) Do
 BEgin

 Read(Eb,BB^.Dat);

 If (BB^.DAt.Employ) Then
        Begin
         Str((StrToInt(Emp)+1):CClientKod,Emp);{занятые позиции}
         {Pr:=IntToStr(FilePos(Eb),CDate);{последний занятый код}
         Pr:=IntToStr(StrToInt(BB^.DAt.Kod),CClientKod);
        End;


 End;
CLose(Eb);
Dispose(BB,Done);
NoInfoMsg;

1:
R.Assign(22, 7, 61, 16);
New(Dlg, Init(R, 'Свойства базы'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx := $E002;


R.Assign(9,3,23,4);
Control := New(PColoredText, Init(R, 'Всего позиций:', $74));
Dlg^.Insert(Control);

R.Assign(23, 3, 28, 4);
STr(StrToInt(MAx):CClientKod,MAx);
Control := New(PColoredText, Init(R, #3+Max, $7E));
Dlg^.Insert(Control);

R.Assign(2, 2, 23, 3);
Control := New(PColoredText, Init(R, 'Используется позиций:', $74));
Dlg^.Insert(Control);

If StrToInt(MAx)>0 Then
MyStr(StrToInt(Emp)/StrToInt(Max)*100,CLitr+1,CMantissa,s)
Else s:='0.00';

R.Assign(23, 2, 38, 3);
Control := New(PColoredText, Init(R, Emp+' '+s+'%', $7E));
Dlg^.Insert(Control);


R.Assign(1, 6, 38, 7);
Control := New(PStaticText, Init(R, ''));
Control^.Options := Control^.Options or ofFramed;
Dlg^.Insert(Control);


R.Assign(24, 6, 31, 7);
Control := New(PInputLine, Init(R, CClientKod));
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['0','1','2','3','4','5','6','7','8','9']));

  R.Assign(4, 6, 24, 7);
  Dlg^.Insert(New(PLabel, Init(R, 'Установить позиций:', Control)));

R.Assign(6, 4, 23, 5);
Control := New(PColoredText, Init(R, 'Максимальный код:', $74));
Dlg^.Insert(Control);

R.Assign(23, 4, 35, 5);
If pr[0]=#0 Then Pr:='0';
Control := New(PColoredText, Init(R, Pr+' ('+IntToSTr(StrToInt(Pr),CClientKod)+')', $7E));
Dlg^.Insert(Control);

Setup:=Max;
DelSpace(Setup);
Dlg^.SetData(Setup);

Dlg^.SelectNext(False);
c:=Desktop^.ExecView(Dlg);
if c<>cmCancel Then
  BEgin

        Dlg^.GetData(Setup);
        If StrToInt(Setup)<(StrToInt(Pr)+1) Then
         BEgin
          Dispose(Control,Done);
          Dispose(Dlg,Done);
          MessageBox(RestructError^,Nil,mfError+mfCAncelButton);
          Goto 1;
         End;

Dispose(Control,Done);
Dispose(Dlg,Done);


DInfoMsg('Провожу реструктуризацию. Ждите ...',True);


        If StrToInt(Setup)>StrToInt(MAx) Then{надо добавлять позиции}
        Begin
         Assign(Eb,Path^.Dat.ToSPR+'Class.db');
         Reset(Eb);
         c:=Ioresult;
         If c=0 Then
         Begin
          Seek(Eb,StrToInt(Max));
          New(bb,Init);
          For c:=1 To (StrToInt(Setup)-StrToInt(MAx)) Do
                Begin
   BB^.Dat.Employ :=False;
   Str(C-1+StrToInt(MAx):CClientKOd,S);
   BB^.Dat.Kod :=s;
   RFormatZerro(BB^.Dat.Kod,CClientKod);
   BB^.Dat.Name[0] :=#0;
   BB^.Dat.RCD:=False;
                 Seek(eb,FileSize(eb));
                 Write(eb,bb^.Dat);
                End;
          Dispose(bb,Done);
          c:=Ioresult;
          Close(Eb);
          c:=Ioresult;
         End{If}
          Else
                Begin
                 NoInfoMsg;
                 MessageBox(^M+#3'Ошибка открытия '+Path^.Dat.ToSPR+'Class.db',Nil,mfError+mfCancelButton);
                 Exit;
                End;{Else}

        End;


If StrToInt(Setup)<=StrToInt(MAx) Then{надо сокращать позиции}
Begin
         Assign(Eb,Path^.Dat.ToSPR+'Class.db');
         Reset(Eb);
         c:=Ioresult;
         If c=0 Then
         Begin
         Seek(Eb,StrToInt(Setup));
         c:=Ioresult;
         Truncate(Eb);
         c:=Ioresult;
         Close(Eb);
         c:=Ioresult;
         End
         Else
          Begin
                NoInfoMsg;
                MessageBox(^M+#3'Ошибка открытия '+Path^.Dat.ToSPR+'Class.db',Nil,mfError+mfCancelButton);
                Exit;
          End;

End;
   NoInfoMsg;
   MessageBox(^M+#3+'Реструктаризация успешно завершена!',Nil,mfInformation+mfCancelButton);
   AddProtocol('Реструктаризация базы '+Path^.Dat.ToSPR+'Class.db','','');
   RefreshCashOneSPR(bClass);
  End
Else
Begin
Dispose(Control,Done);
Dispose(Dlg,Done);
End;

End;



Procedure CorrectFirma;
Label 1;
Var      s  : AllStr;
         c,c1  : LongInt;
         Eb : File Of FirmaPostType;
         BB : PFirmaPostType;
         Max,Pr,Emp : AllStr;
         Setup : String[5];
         RKod : ArtikulStr;
         Dlg : PDialog;
         R : TRect;
         Control : PView;
         j : Word;
Begin
ClearFind;

If Not(TestOpenDate1(FDate)) Then
        Begin
         MessageBox(#3^M+#3'Доступ к данным за '+FDate+' заблокирован!',Nil,mfError+mfCancelButton);
         Exit;
        End;

If (GlobalReadOnly=1) Or (ReadOnlyConst=1) Then
   Begin
    MessageBox(#3^M+ReadOnlyStr^,Nil,mfWarning+mfCancelButton);
    Exit;
   End;

C:=IOResult;

If Not(Password(5)) Then Exit;

Assign(Eb,Path^.Dat.ToSPR+'Firma.db');
Reset(Eb);
C:=IOResult;
If C<>0 Then
Begin
 MessageBox(^M+#3'Ошибка доступа к '+Path^.Dat.ToSPR+'Firma.db',nil,mfError+mfCancelButton);
 Exit;
End;

Max:=IntToSTr(FileSize(Eb),CClientKod);
DInfoMsg('Определяю свойства базы...',True);
New(BB,Init);
Emp[0]:=#0;
Pr[0]:=#0;
While Not(Eof(Eb)) Do
 BEgin

 Read(Eb,BB^.Dat);

 If (BB^.DAt.Employ) Then
        Begin
         Str((StrToInt(Emp)+1):CClientKod,Emp);{занятые позиции}
         {Pr:=IntToStr(FilePos(Eb),CDate);{последний занятый код}
         Pr:=IntToStr(StrToInt(BB^.DAt.Kod),CClientKod);
        End;


 End;
CLose(Eb);
Dispose(BB,Done);
NoInfoMsg;

1:
R.Assign(22, 7, 61, 16);
New(Dlg, Init(R, 'Свойства базы'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx := $E002;


R.Assign(9,3,23,4);
Control := New(PColoredText, Init(R, 'Всего позиций:', $74));
Dlg^.Insert(Control);

R.Assign(23, 3, 28, 4);
STr(StrToInt(MAx):CClientKod,MAx);
Control := New(PColoredText, Init(R, #3+Max, $7E));
Dlg^.Insert(Control);

R.Assign(2, 2, 23, 3);
Control := New(PColoredText, Init(R, 'Используется позиций:', $74));
Dlg^.Insert(Control);

If StrToInt(MAx)>0 Then
MyStr(StrToInt(Emp)/StrToInt(Max)*100,CLitr+1,CMantissa,s)
Else s:='0.00';

R.Assign(23, 2, 38, 3);
Control := New(PColoredText, Init(R, Emp+' '+s+'%', $7E));
Dlg^.Insert(Control);


R.Assign(1, 6, 38, 7);
Control := New(PStaticText, Init(R, ''));
Control^.Options := Control^.Options or ofFramed;
Dlg^.Insert(Control);


R.Assign(24, 6, 31, 7);
Control := New(PInputLine, Init(R, CClientKod));
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['0','1','2','3','4','5','6','7','8','9']));

  R.Assign(4, 6, 24, 7);
  Dlg^.Insert(New(PLabel, Init(R, 'Установить позиций:', Control)));

R.Assign(6, 4, 23, 5);
Control := New(PColoredText, Init(R, 'Максимальный код:', $74));
Dlg^.Insert(Control);

R.Assign(23, 4, 35, 5);
If pr[0]=#0 Then Pr:='0';
Control := New(PColoredText, Init(R, Pr+' ('+IntToSTr(StrToInt(Pr),CClientKod)+')', $7E));
Dlg^.Insert(Control);

Setup:=Max;
DelSpace(Setup);
Dlg^.SetData(Setup);

Dlg^.SelectNext(False);
c:=Desktop^.ExecView(Dlg);
if c<>cmCancel Then
  BEgin

        Dlg^.GetData(Setup);
        If StrToInt(Setup)<(StrToInt(Pr)+1) Then
         BEgin
          Dispose(Control,Done);
          Dispose(Dlg,Done);
          MessageBox(RestructError^,Nil,mfError+mfCAncelButton);
          Goto 1;
         End;

Dispose(Control,Done);
Dispose(Dlg,Done);


DInfoMsg('Провожу реструктуризацию. Ждите ...',True);


        If StrToInt(Setup)>StrToInt(MAx) Then{надо добавлять позиции}
        Begin
         Assign(Eb,Path^.Dat.ToSPR+'Firma.db');
         Reset(Eb);
         c:=Ioresult;
         If c=0 Then
         Begin
          Seek(Eb,StrToInt(Max));
          New(bb,Init);
          For c:=1 To (StrToInt(Setup)-StrToInt(MAx)) Do
                Begin
   BB^.Dat.Employ :=False;
   Str(C-1+StrToInt(MAx):CClientKOd,S);
   BB^.Dat.Kod :=s;
   RFormatZerro(BB^.Dat.Kod,CClientKod);
   BB^.Dat.FirmaPost[0] :=#0;
   BB^.Dat.RCD:=False;
                 Seek(eb,FileSize(eb));
                 Write(eb,bb^.Dat);
                End;
          Dispose(bb,Done);
          c:=Ioresult;
          Close(Eb);
          c:=Ioresult;
         End{If}
          Else
                Begin
                 NoInfoMsg;
                 MessageBox(^M+#3'Ошибка открытия '+Path^.Dat.ToSPR+'Firma.db',Nil,mfError+mfCancelButton);
                 Exit;
                End;{Else}

        End;


If StrToInt(Setup)<=StrToInt(MAx) Then{надо сокращать позиции}
Begin
         Assign(Eb,Path^.Dat.ToSPR+'Firma.db');
         Reset(Eb);
         c:=Ioresult;
         If c=0 Then
         Begin
         Seek(Eb,StrToInt(Setup));
         c:=Ioresult;
         Truncate(Eb);
         c:=Ioresult;
         Close(Eb);
         c:=Ioresult;
         End
         Else
          Begin
                NoInfoMsg;
                MessageBox(^M+#3'Ошибка открытия '+Path^.Dat.ToSPR+'Firma.db',Nil,mfError+mfCancelButton);
                Exit;
          End;

End;
   NoInfoMsg;
   MessageBox(^M+#3+'Реструктаризация успешно завершена!',Nil,mfInformation+mfCancelButton);
   AddProtocol('Реструктаризация базы '+Path^.Dat.ToSPR+'Firma.db','','');
   RefreshCashOneSPR(bFirma);
  End
Else
Begin
Dispose(Control,Done);
Dispose(Dlg,Done);
End;

End;


Procedure CorrectMera;
Label 1;
Var      s  : AllStr;
         c,c1  : LongInt;
         Eb : File Of MeraType;
         BB : PMeraType;
         Max,Pr,Emp : AllStr;
         Setup : String[5];
         RKod : ArtikulStr;
         Dlg : PDialog;
         R : TRect;
         Control : PView;
         j : Word;
Begin
ClearFind;

If Not(TestOpenDate1(FDate)) Then
        Begin
         MessageBox(#3^M+#3'Доступ к данным за '+FDate+' заблокирован!',Nil,mfError+mfCancelButton);
         Exit;
        End;

If (GlobalReadOnly=1) Or (ReadOnlyConst=1) Then
   Begin
    MessageBox(#3^M+ReadOnlyStr^,Nil,mfWarning+mfCancelButton);
    Exit;
   End;

C:=IOResult;

If Not(Password(5)) Then Exit;

Assign(Eb,Path^.Dat.ToSPR+'Mera.db');
Reset(Eb);
C:=IOResult;
If C<>0 Then
Begin
 MessageBox(^M+#3'Ошибка доступа к '+Path^.Dat.ToSPR+'Mera.db',nil,mfError+mfCancelButton);
 Exit;
End;

Max:=IntToSTr(FileSize(Eb),CClientKod);
DInfoMsg('Определяю свойства базы...',True);
New(BB,Init);
Emp[0]:=#0;
Pr[0]:=#0;
While Not(Eof(Eb)) Do
 BEgin

 Read(Eb,BB^.Dat);

 If (BB^.DAt.Employ) Then
        Begin
         Str((StrToInt(Emp)+1):CClientKod,Emp);{занятые позиции}
         {Pr:=IntToStr(FilePos(Eb),CDate);{последний занятый код}
         Pr:=IntToStr(StrToInt(BB^.DAt.Kod),CClientKod);
        End;


 End;
CLose(Eb);
Dispose(BB,Done);
NoInfoMsg;

1:
R.Assign(22, 7, 61, 16);
New(Dlg, Init(R, 'Свойства базы'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx := $E002;


R.Assign(9,3,23,4);
Control := New(PColoredText, Init(R, 'Всего позиций:', $74));
Dlg^.Insert(Control);

R.Assign(23, 3, 28, 4);
STr(StrToInt(MAx):CClientKod,MAx);
Control := New(PColoredText, Init(R, #3+Max, $7E));
Dlg^.Insert(Control);

R.Assign(2, 2, 23, 3);
Control := New(PColoredText, Init(R, 'Используется позиций:', $74));
Dlg^.Insert(Control);

If StrToInt(MAx)>0 Then
MyStr(StrToInt(Emp)/StrToInt(Max)*100,CLitr+1,CMantissa,s)
Else s:='0.00';

R.Assign(23, 2, 38, 3);
Control := New(PColoredText, Init(R, Emp+' '+s+'%', $7E));
Dlg^.Insert(Control);


R.Assign(1, 6, 38, 7);
Control := New(PStaticText, Init(R, ''));
Control^.Options := Control^.Options or ofFramed;
Dlg^.Insert(Control);


R.Assign(24, 6, 31, 7);
Control := New(PInputLine, Init(R, CClientKod));
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['0','1','2','3','4','5','6','7','8','9']));

  R.Assign(4, 6, 24, 7);
  Dlg^.Insert(New(PLabel, Init(R, 'Установить позиций:', Control)));

R.Assign(6, 4, 23, 5);
Control := New(PColoredText, Init(R, 'Максимальный код:', $74));
Dlg^.Insert(Control);

R.Assign(23, 4, 35, 5);
If pr[0]=#0 Then Pr:='0';
Control := New(PColoredText, Init(R, Pr+' ('+IntToSTr(StrToInt(Pr),CClientKod)+')', $7E));
Dlg^.Insert(Control);

Setup:=Max;
DelSpace(Setup);
Dlg^.SetData(Setup);

Dlg^.SelectNext(False);
c:=Desktop^.ExecView(Dlg);
if c<>cmCancel Then
  BEgin

        Dlg^.GetData(Setup);
        If StrToInt(Setup)<(StrToInt(Pr)+1) Then
         BEgin
          Dispose(Control,Done);
          Dispose(Dlg,Done);
          MessageBox(RestructError^,Nil,mfError+mfCAncelButton);
          Goto 1;
         End;

Dispose(Control,Done);
Dispose(Dlg,Done);


DInfoMsg('Провожу реструктуризацию. Ждите ...',True);


        If StrToInt(Setup)>StrToInt(MAx) Then{надо добавлять позиции}
        Begin
         Assign(Eb,Path^.Dat.ToSPR+'Mera.db');
         Reset(Eb);
         c:=Ioresult;
         If c=0 Then
         Begin
          Seek(Eb,StrToInt(Max));
          New(bb,Init);
          For c:=1 To (StrToInt(Setup)-StrToInt(MAx)) Do
                Begin
   BB^.Dat.Employ :=False;
   Str(C-1+StrToInt(MAx):CClientKOd,S);
   BB^.Dat.Kod :=s;
   RFormatZerro(BB^.Dat.Kod,CClientKod);
   BB^.Dat.Mera[0] :=#0;
   BB^.Dat.RCD:=False;
                 Seek(eb,FileSize(eb));
                 Write(eb,bb^.Dat);
                End;
          Dispose(bb,Done);
          c:=Ioresult;
          Close(Eb);
          c:=Ioresult;
         End{If}
          Else
                Begin
                 NoInfoMsg;
                 MessageBox(^M+#3'Ошибка открытия '+Path^.Dat.ToSPR+'Mera.db',Nil,mfError+mfCancelButton);
                 Exit;
                End;{Else}

        End;


If StrToInt(Setup)<=StrToInt(MAx) Then{надо сокращать позиции}
Begin
         Assign(Eb,Path^.Dat.ToSPR+'Mera.db');
         Reset(Eb);
         c:=Ioresult;
         If c=0 Then
         Begin
         Seek(Eb,StrToInt(Setup));
         c:=Ioresult;
         Truncate(Eb);
         c:=Ioresult;
         Close(Eb);
         c:=Ioresult;
         End
         Else
          Begin
                NoInfoMsg;
                MessageBox(^M+#3'Ошибка открытия '+Path^.Dat.ToSPR+'Mera.db',Nil,mfError+mfCancelButton);
                Exit;
          End;

End;
   NoInfoMsg;
   MessageBox(^M+#3+'Реструктаризация успешно завершена!',Nil,mfInformation+mfCancelButton);
   AddProtocol('Реструктаризация базы '+Path^.Dat.ToSPR+'Mera.db','','');
   RefreshCashOneSPR(bMera);
  End
Else
Begin
Dispose(Control,Done);
Dispose(Dlg,Done);
End;

End;




Procedure CorrectRegion;
Label 1;
Var      s  : AllStr;
         c,c1  : LongInt;
         Eb : File Of RegionType;
         BB : PRegionType;
         Max,Pr,Emp : AllStr;
         Setup : String[5];
         RKod : ArtikulStr;
         Dlg : PDialog;
         R : TRect;
         Control : PView;
         j : Word;
Begin
ClearFind;

If Not(TestOpenDate1(FDate)) Then
        Begin
         MessageBox(#3^M+#3'Доступ к данным за '+FDate+' заблокирован!',Nil,mfError+mfCancelButton);
         Exit;
        End;

If (GlobalReadOnly=1) Or (ReadOnlyConst=1) Then
   Begin
    MessageBox(#3^M+ReadOnlyStr^,Nil,mfWarning+mfCancelButton);
    Exit;
   End;

C:=IOResult;

If Not(Password(5)) Then Exit;

Assign(Eb,Path^.Dat.ToSPR+'Region.db');
Reset(Eb);
C:=IOResult;
If C<>0 Then
Begin
 MessageBox(^M+#3'Ошибка доступа к '+Path^.Dat.ToSPR+'Region.db',nil,mfError+mfCancelButton);
 Exit;
End;

Max:=IntToSTr(FileSize(Eb),CClientKod);
DInfoMsg('Определяю свойства базы...',True);
New(BB,Init);
Emp[0]:=#0;
Pr[0]:=#0;
While Not(Eof(Eb)) Do
 BEgin

 Read(Eb,BB^.Dat);

 If (BB^.DAt.Employ) Then
        Begin
         Str((StrToInt(Emp)+1):CClientKod,Emp);{занятые позиции}
         {Pr:=IntToStr(FilePos(Eb),CDate);{последний занятый код}
         Pr:=IntToStr(StrToInt(BB^.DAt.Kod),CClientKod);
        End;


 End;
CLose(Eb);
Dispose(BB,Done);
NoInfoMsg;

1:
R.Assign(22, 7, 61, 16);
New(Dlg, Init(R, 'Свойства базы'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx := $E002;


R.Assign(9,3,23,4);
Control := New(PColoredText, Init(R, 'Всего позиций:', $74));
Dlg^.Insert(Control);

R.Assign(23, 3, 28, 4);
STr(StrToInt(MAx):CClientKod,MAx);
Control := New(PColoredText, Init(R, #3+Max, $7E));
Dlg^.Insert(Control);

R.Assign(2, 2, 23, 3);
Control := New(PColoredText, Init(R, 'Используется позиций:', $74));
Dlg^.Insert(Control);

If StrToInt(MAx)>0 Then
MyStr(StrToInt(Emp)/StrToInt(Max)*100,CLitr+1,CMantissa,s)
Else s:='0.00';

R.Assign(23, 2, 38, 3);
Control := New(PColoredText, Init(R, Emp+' '+s+'%', $7E));
Dlg^.Insert(Control);


R.Assign(1, 6, 38, 7);
Control := New(PStaticText, Init(R, ''));
Control^.Options := Control^.Options or ofFramed;
Dlg^.Insert(Control);


R.Assign(24, 6, 31, 7);
Control := New(PInputLine, Init(R, CClientKod));
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['0','1','2','3','4','5','6','7','8','9']));

  R.Assign(4, 6, 24, 7);
  Dlg^.Insert(New(PLabel, Init(R, 'Установить позиций:', Control)));

R.Assign(6, 4, 23, 5);
Control := New(PColoredText, Init(R, 'Максимальный код:', $74));
Dlg^.Insert(Control);

R.Assign(23, 4, 35, 5);
If pr[0]=#0 Then Pr:='0';
Control := New(PColoredText, Init(R, Pr+' ('+IntToSTr(StrToInt(Pr),CClientKod)+')', $7E));
Dlg^.Insert(Control);

Setup:=Max;
DelSpace(Setup);
Dlg^.SetData(Setup);

Dlg^.SelectNext(False);
c:=Desktop^.ExecView(Dlg);
if c<>cmCancel Then
  BEgin

        Dlg^.GetData(Setup);
        If StrToInt(Setup)<(StrToInt(Pr)+1) Then
         BEgin
          Dispose(Control,Done);
          Dispose(Dlg,Done);
          MessageBox(RestructError^,Nil,mfError+mfCAncelButton);
          Goto 1;
         End;

Dispose(Control,Done);
Dispose(Dlg,Done);


DInfoMsg('Провожу реструктуризацию. Ждите ...',True);


        If StrToInt(Setup)>StrToInt(MAx) Then{надо добавлять позиции}
        Begin
         Assign(Eb,Path^.Dat.ToSPR+'Region.db');
         Reset(Eb);
         c:=Ioresult;
         If c=0 Then
         Begin
          Seek(Eb,StrToInt(Max));
          New(bb,Init);
          For c:=1 To (StrToInt(Setup)-StrToInt(MAx)) Do
                Begin
   BB^.Dat.Employ :=False;
   Str(C-1+StrToInt(MAx):CClientKOd,S);
   BB^.Dat.Kod :=s;
   RFormatZerro(BB^.Dat.Kod,CClientKod);
   BB^.Dat.RegionName[0] :=#0;
   BB^.Dat.RCD:=False;
                 Seek(eb,FileSize(eb));
                 Write(eb,bb^.Dat);
                End;
          Dispose(bb,Done);
          c:=Ioresult;
          Close(Eb);
          c:=Ioresult;
         End{If}
          Else
                Begin
                 NoInfoMsg;
                 MessageBox(^M+#3'Ошибка открытия '+Path^.Dat.ToSPR+'Region.db',Nil,mfError+mfCancelButton);
                 Exit;
                End;{Else}

        End;


If StrToInt(Setup)<=StrToInt(MAx) Then{надо сокращать позиции}
Begin
         Assign(Eb,Path^.Dat.ToSPR+'Region.db');
         Reset(Eb);
         c:=Ioresult;
         If c=0 Then
         Begin
         Seek(Eb,StrToInt(Setup));
         c:=Ioresult;
         Truncate(Eb);
         c:=Ioresult;
         Close(Eb);
         c:=Ioresult;
         End
         Else
          Begin
                NoInfoMsg;
                MessageBox(^M+#3'Ошибка открытия '+Path^.Dat.ToSPR+'Region.db',Nil,mfError+mfCancelButton);
                Exit;
          End;

End;
   NoInfoMsg;
   MessageBox(^M+#3+'Реструктаризация успешно завершена!',Nil,mfInformation+mfCancelButton);
   AddProtocol('Реструктаризация базы '+Path^.Dat.ToSPR+'Region.db','','');
   RefreshCashOneSPR(bRegion);
  End
Else
Begin
Dispose(Control,Done);
Dispose(Dlg,Done);
End;

End;



Procedure CorrectGroup;
Label 1;
Var      s  : AllStr;
         c,c1  : LongInt;
         Eb : File Of GroupType;
         BB : PGroupType;
         Max,Pr,Emp : AllStr;
         Setup : String[5];
         RKod : ArtikulStr;
         Dlg : PDialog;
         R : TRect;
         Control : PView;
         j : Word;
Begin
ClearFind;

If Not(TestOpenDate1(FDate)) Then
        Begin
         MessageBox(#3^M+#3'Доступ к данным за '+FDate+' заблокирован!',Nil,mfError+mfCancelButton);
         Exit;
        End;

If (GlobalReadOnly=1) Or (ReadOnlyConst=1) Then
   Begin
    MessageBox(#3^M+ReadOnlyStr^,Nil,mfWarning+mfCancelButton);
    Exit;
   End;

C:=IOResult;

If Not(Password(5)) Then Exit;

Assign(Eb,Path^.Dat.ToSPR+'Group.db');
Reset(Eb);
C:=IOResult;
If C<>0 Then
Begin
 MessageBox(^M+#3'Ошибка доступа к '+Path^.Dat.ToSPR+'Group.db',nil,mfError+mfCancelButton);
 Exit;
End;

Max:=IntToSTr(FileSize(Eb),CClientKod);
DInfoMsg('Определяю свойства базы...',True);
New(BB,Init);
Emp[0]:=#0;
Pr[0]:=#0;
While Not(Eof(Eb)) Do
 BEgin

 Read(Eb,BB^.Dat);

 If (BB^.DAt.Employ) Then
        Begin
         Str((StrToInt(Emp)+1):CClientKod,Emp);{занятые позиции}
         {Pr:=IntToStr(FilePos(Eb),CDate);{последний занятый код}
         Pr:=IntToStr(StrToInt(BB^.DAt.Kod),CClientKod);
        End;


 End;
CLose(Eb);
Dispose(BB,Done);
NoInfoMsg;

1:
R.Assign(22, 7, 61, 16);
New(Dlg, Init(R, 'Свойства базы'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx := $E002;


R.Assign(9,3,23,4);
Control := New(PColoredText, Init(R, 'Всего позиций:', $74));
Dlg^.Insert(Control);

R.Assign(23, 3, 28, 4);
STr(StrToInt(MAx):CClientKod,MAx);
Control := New(PColoredText, Init(R, #3+Max, $7E));
Dlg^.Insert(Control);

R.Assign(2, 2, 23, 3);
Control := New(PColoredText, Init(R, 'Используется позиций:', $74));
Dlg^.Insert(Control);

If StrToInt(MAx)>0 Then
MyStr(StrToInt(Emp)/StrToInt(Max)*100,CLitr+1,CMantissa,s)
Else s:='0.00';

R.Assign(23, 2, 38, 3);
Control := New(PColoredText, Init(R, Emp+' '+s+'%', $7E));
Dlg^.Insert(Control);


R.Assign(1, 6, 38, 7);
Control := New(PStaticText, Init(R, ''));
Control^.Options := Control^.Options or ofFramed;
Dlg^.Insert(Control);


R.Assign(24, 6, 31, 7);
Control := New(PInputLine, Init(R, CClientKod));
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['0','1','2','3','4','5','6','7','8','9']));

  R.Assign(4, 6, 24, 7);
  Dlg^.Insert(New(PLabel, Init(R, 'Установить позиций:', Control)));

R.Assign(6, 4, 23, 5);
Control := New(PColoredText, Init(R, 'Максимальный код:', $74));
Dlg^.Insert(Control);

R.Assign(23, 4, 35, 5);
If pr[0]=#0 Then Pr:='0';
Control := New(PColoredText, Init(R, Pr+' ('+IntToSTr(StrToInt(Pr),CClientKod)+')', $7E));
Dlg^.Insert(Control);

Setup:=Max;
DelSpace(Setup);
Dlg^.SetData(Setup);

Dlg^.SelectNext(False);
c:=Desktop^.ExecView(Dlg);
if c<>cmCancel Then
  BEgin

        Dlg^.GetData(Setup);
        If StrToInt(Setup)<(StrToInt(Pr)+1) Then
         BEgin
          Dispose(Control,Done);
          Dispose(Dlg,Done);
          MessageBox(RestructError^,Nil,mfError+mfCAncelButton);
          Goto 1;
         End;

Dispose(Control,Done);
Dispose(Dlg,Done);


DInfoMsg('Провожу реструктуризацию. Ждите ...',True);


        If StrToInt(Setup)>StrToInt(MAx) Then{надо добавлять позиции}
        Begin
         Assign(Eb,Path^.Dat.ToSPR+'Group.db');
         Reset(Eb);
         c:=Ioresult;
         If c=0 Then
         Begin
          Seek(Eb,StrToInt(Max));
          New(bb,Init);
          For c:=1 To (StrToInt(Setup)-StrToInt(MAx)) Do
                Begin
   BB^.Dat.Employ :=False;
   Str(C-1+StrToInt(MAx):CClientKOd,S);
   BB^.Dat.Kod :=s;
   RFormatZerro(BB^.Dat.Kod,CClientKod);
   BB^.Dat.GroupName[0] :=#0;
   BB^.Dat.RCD:=False;
                 Seek(eb,FileSize(eb));
                 Write(eb,bb^.Dat);
                End;
          Dispose(bb,Done);
          c:=Ioresult;
          Close(Eb);
          c:=Ioresult;
         End{If}
          Else
                Begin
                 NoInfoMsg;
                 MessageBox(^M+#3'Ошибка открытия '+Path^.Dat.ToSPR+'Group.db',Nil,mfError+mfCancelButton);
                 Exit;
                End;{Else}

        End;


If StrToInt(Setup)<=StrToInt(MAx) Then{надо сокращать позиции}
Begin
         Assign(Eb,Path^.Dat.ToSPR+'Group.db');
         Reset(Eb);
         c:=Ioresult;
         If c=0 Then
         Begin
         Seek(Eb,StrToInt(Setup));
         c:=Ioresult;
         Truncate(Eb);
         c:=Ioresult;
         Close(Eb);
         c:=Ioresult;
         End
         Else
          Begin
                NoInfoMsg;
                MessageBox(^M+#3'Ошибка открытия '+Path^.Dat.ToSPR+'Group.db',Nil,mfError+mfCancelButton);
                Exit;
          End;

End;
   NoInfoMsg;
   MessageBox(^M+#3+'Реструктаризация успешно завершена!',Nil,mfInformation+mfCancelButton);
   AddProtocol('Реструктаризация базы '+Path^.Dat.ToSPR+'Group.db','','');
   RefreshCashOneSPR(bGroup);
  End
Else
Begin
Dispose(Control,Done);
Dispose(Dlg,Done);
End;

End;



Procedure CorrectRoute;
Label 1;
Var      s  : AllStr;
         c,c1  : LongInt;
         Eb : File Of RouteType;
         BB : PRouteType;
         Max,Pr,Emp : AllStr;
         Setup : String[5];
         RKod : ArtikulStr;
         Dlg : PDialog;
         R : TRect;
         Control : PView;
         j : Word;
Begin
ClearFind;

If Not(TestOpenDate1(FDate)) Then
        Begin
         MessageBox(#3^M+#3'Доступ к данным за '+FDate+' заблокирован!',Nil,mfError+mfCancelButton);
         Exit;
        End;

If (GlobalReadOnly=1) Or (ReadOnlyConst=1) Then
   Begin
    MessageBox(#3^M+ReadOnlyStr^,Nil,mfWarning+mfCancelButton);
    Exit;
   End;

C:=IOResult;

If Not(Password(5)) Then Exit;

Assign(Eb,Path^.Dat.ToSPR+'Route.db');
Reset(Eb);
C:=IOResult;
If C<>0 Then
Begin
 MessageBox(^M+#3'Ошибка доступа к '+Path^.Dat.ToSPR+'Route.db',nil,mfError+mfCancelButton);
 Exit;
End;

Max:=IntToSTr(FileSize(Eb),CClientKod);
DInfoMsg('Определяю свойства базы...',True);
New(BB,Init);
Emp[0]:=#0;
Pr[0]:=#0;
While Not(Eof(Eb)) Do
 BEgin

 Read(Eb,BB^.Dat);

 If (BB^.DAt.Employ) Then
        Begin
         Str((StrToInt(Emp)+1):CClientKod,Emp);{занятые позиции}
         {Pr:=IntToStr(FilePos(Eb),CDate);{последний занятый код}
         Pr:=IntToStr(StrToInt(BB^.DAt.Kod),CClientKod);
        End;


 End;
CLose(Eb);
Dispose(BB,Done);
NoInfoMsg;

1:
R.Assign(22, 7, 61, 16);
New(Dlg, Init(R, 'Свойства базы'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx := $E002;


R.Assign(9,3,23,4);
Control := New(PColoredText, Init(R, 'Всего позиций:', $74));
Dlg^.Insert(Control);

R.Assign(23, 3, 28, 4);
STr(StrToInt(MAx):CClientKod,MAx);
Control := New(PColoredText, Init(R, #3+Max, $7E));
Dlg^.Insert(Control);

R.Assign(2, 2, 23, 3);
Control := New(PColoredText, Init(R, 'Используется позиций:', $74));
Dlg^.Insert(Control);

If StrToInt(MAx)>0 Then
MyStr(StrToInt(Emp)/StrToInt(Max)*100,CLitr+1,CMantissa,s)
Else s:='0.00';

R.Assign(23, 2, 38, 3);
Control := New(PColoredText, Init(R, Emp+' '+s+'%', $7E));
Dlg^.Insert(Control);


R.Assign(1, 6, 38, 7);
Control := New(PStaticText, Init(R, ''));
Control^.Options := Control^.Options or ofFramed;
Dlg^.Insert(Control);


R.Assign(24, 6, 31, 7);
Control := New(PInputLine, Init(R, CClientKod));
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['0','1','2','3','4','5','6','7','8','9']));

  R.Assign(4, 6, 24, 7);
  Dlg^.Insert(New(PLabel, Init(R, 'Установить позиций:', Control)));

R.Assign(6, 4, 23, 5);
Control := New(PColoredText, Init(R, 'Максимальный код:', $74));
Dlg^.Insert(Control);

R.Assign(23, 4, 35, 5);
If pr[0]=#0 Then Pr:='0';
Control := New(PColoredText, Init(R, Pr+' ('+IntToSTr(StrToInt(Pr),CClientKod)+')', $7E));
Dlg^.Insert(Control);

Setup:=Max;
DelSpace(Setup);
Dlg^.SetData(Setup);

Dlg^.SelectNext(False);
c:=Desktop^.ExecView(Dlg);
if c<>cmCancel Then
  BEgin

        Dlg^.GetData(Setup);
        If StrToInt(Setup)<(StrToInt(Pr)+1) Then
         BEgin
          Dispose(Control,Done);
          Dispose(Dlg,Done);
          MessageBox(RestructError^,Nil,mfError+mfCAncelButton);
          Goto 1;
         End;

Dispose(Control,Done);
Dispose(Dlg,Done);


DInfoMsg('Провожу реструктуризацию. Ждите ...',True);


        If StrToInt(Setup)>StrToInt(MAx) Then{надо добавлять позиции}
        Begin
         Assign(Eb,Path^.Dat.ToSPR+'Route.db');
         Reset(Eb);
         c:=Ioresult;
         If c=0 Then
         Begin
          Seek(Eb,StrToInt(Max));
          New(bb,Init);
          For c:=1 To (StrToInt(Setup)-StrToInt(MAx)) Do
                Begin
   BB^.Dat.Employ :=False;
   Str(C-1+StrToInt(MAx):CClientKOd,S);
   BB^.Dat.Kod :=s;
   RFormatZerro(BB^.Dat.Kod,CClientKod);
   BB^.Dat.RouteName[0] :=#0;
   BB^.Dat.RCD:=False;
                 Seek(eb,FileSize(eb));
                 Write(eb,bb^.Dat);
                End;
          Dispose(bb,Done);
          c:=Ioresult;
          Close(Eb);
          c:=Ioresult;
         End{If}
          Else
                Begin
                 NoInfoMsg;
                 MessageBox(^M+#3'Ошибка открытия '+Path^.Dat.ToSPR+'Route.db',Nil,mfError+mfCancelButton);
                 Exit;
                End;{Else}

        End;


If StrToInt(Setup)<=StrToInt(MAx) Then{надо сокращать позиции}
Begin
         Assign(Eb,Path^.Dat.ToSPR+'Route.db');
         Reset(Eb);
         c:=Ioresult;
         If c=0 Then
         Begin
         Seek(Eb,StrToInt(Setup));
         c:=Ioresult;
         Truncate(Eb);
         c:=Ioresult;
         Close(Eb);
         c:=Ioresult;
         End
         Else
          Begin
                NoInfoMsg;
                MessageBox(^M+#3'Ошибка открытия '+Path^.Dat.ToSPR+'Route.db',Nil,mfError+mfCancelButton);
                Exit;
          End;

End;
   NoInfoMsg;
   MessageBox(^M+#3+'Реструктаризация успешно завершена!',Nil,mfInformation+mfCancelButton);
   AddProtocol('Реструктаризация базы '+Path^.Dat.ToSPR+'Route.db','','');
   RefreshCashOneSPR(bRoute);
  End
Else
Begin
Dispose(Control,Done);
Dispose(Dlg,Done);
End;

End;



Procedure CorrectPost;
Label 1;
Var      s  : AllStr;
         c,c1  : LongInt;
         Eb : File Of PostType;
         BB : PPostType;
         Max,Pr,Emp : AllStr;
         Setup : String[5];
         RKod : ArtikulStr;
         Dlg : PDialog;
         R : TRect;
         Control : PView;
         j : Word;
Begin
ClearFind;

If Not(TestOpenDate1(FDate)) Then
        Begin
         MessageBox(#3^M+#3'Доступ к данным за '+FDate+' заблокирован!',Nil,mfError+mfCancelButton);
         Exit;
        End;

If (GlobalReadOnly=1) Or (ReadOnlyConst=1) Then
   Begin
    MessageBox(#3^M+ReadOnlyStr^,Nil,mfWarning+mfCancelButton);
    Exit;
   End;

C:=IOResult;

If Not(Password(5)) Then Exit;

Assign(Eb,Path^.Dat.ToSPR+'lands.db');
Reset(Eb);
C:=IOResult;
If C<>0 Then
Begin
 MessageBox(^M+#3'Ошибка доступа к '+Path^.Dat.ToSPR+'lands.db',nil,mfError+mfCancelButton);
 Exit;
End;

Max:=IntToSTr(FileSize(Eb),CClientKod);
DInfoMsg('Определяю свойства базы...',True);
New(BB,Init);
Emp[0]:=#0;
Pr[0]:=#0;
While Not(Eof(Eb)) Do
 BEgin

 Read(Eb,BB^.Dat);

 If (BB^.DAt.Employ) Then
        Begin
         Str((StrToInt(Emp)+1):CClientKod,Emp);{занятые позиции}
         {Pr:=IntToStr(FilePos(Eb),CDate);{последний занятый код}
         Pr:=IntToStr(StrToInt(BB^.DAt.Kod),CClientKod);
        End;


 End;
CLose(Eb);
Dispose(BB,Done);
NoInfoMsg;

1:
R.Assign(22, 7, 61, 16);
New(Dlg, Init(R, 'Свойства базы'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx := $E002;


R.Assign(9,3,23,4);
Control := New(PColoredText, Init(R, 'Всего позиций:', $74));
Dlg^.Insert(Control);

R.Assign(23, 3, 28, 4);
STr(StrToInt(MAx):CClientKod,MAx);
Control := New(PColoredText, Init(R, #3+Max, $7E));
Dlg^.Insert(Control);

R.Assign(2, 2, 23, 3);
Control := New(PColoredText, Init(R, 'Используется позиций:', $74));
Dlg^.Insert(Control);

If StrToInt(MAx)>0 Then
MyStr(StrToInt(Emp)/StrToInt(Max)*100,CLitr+1,CMantissa,s)
Else s:='0.00';

R.Assign(23, 2, 38, 3);
Control := New(PColoredText, Init(R, Emp+' '+s+'%', $7E));
Dlg^.Insert(Control);


R.Assign(1, 6, 38, 7);
Control := New(PStaticText, Init(R, ''));
Control^.Options := Control^.Options or ofFramed;
Dlg^.Insert(Control);


R.Assign(24, 6, 31, 7);
Control := New(PInputLine, Init(R, CClientKod));
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['0','1','2','3','4','5','6','7','8','9']));

  R.Assign(4, 6, 24, 7);
  Dlg^.Insert(New(PLabel, Init(R, 'Установить позиций:', Control)));

R.Assign(6, 4, 23, 5);
Control := New(PColoredText, Init(R, 'Максимальный код:', $74));
Dlg^.Insert(Control);

R.Assign(23, 4, 35, 5);
If pr[0]=#0 Then Pr:='0';
Control := New(PColoredText, Init(R, Pr+' ('+IntToSTr(StrToInt(Pr),CClientKod)+')', $7E));
Dlg^.Insert(Control);

Setup:=Max;
DelSpace(Setup);
Dlg^.SetData(Setup);

Dlg^.SelectNext(False);
c:=Desktop^.ExecView(Dlg);
if c<>cmCancel Then
  BEgin

        Dlg^.GetData(Setup);
        If StrToInt(Setup)<(StrToInt(Pr)+1) Then
         BEgin
          Dispose(Control,Done);
          Dispose(Dlg,Done);
          MessageBox(RestructError^,Nil,mfError+mfCAncelButton);
          Goto 1;
         End;

Dispose(Control,Done);
Dispose(Dlg,Done);


DInfoMsg('Провожу реструктуризацию. Ждите ...',True);


        If StrToInt(Setup)>StrToInt(MAx) Then{надо добавлять позиции}
        Begin
         Assign(Eb,Path^.Dat.ToSPR+'lands.db');
         Reset(Eb);
         c:=Ioresult;
         If c=0 Then
         Begin
          Seek(Eb,StrToInt(Max));
          New(bb,Init);
          For c:=1 To (StrToInt(Setup)-StrToInt(MAx)) Do
                Begin
   BB^.Dat.Employ :=False;
   Str(C-1+StrToInt(MAx):CClientKOd,S);
   BB^.Dat.Kod :=s;
   RFormatZerro(BB^.Dat.Kod,CClientKod);
   BB^.Dat.Post[0] :=#0;
   BB^.Dat.RCD:=False;
                 Seek(eb,FileSize(eb));
                 Write(eb,bb^.Dat);
                End;
          Dispose(bb,Done);
          c:=Ioresult;
          Close(Eb);
          c:=Ioresult;
         End{If}
          Else
                Begin
                 NoInfoMsg;
                 MessageBox(^M+#3'Ошибка открытия '+Path^.Dat.ToSPR+'lands.db',Nil,mfError+mfCancelButton);
                 Exit;
                End;{Else}

        End;


If StrToInt(Setup)<=StrToInt(MAx) Then{надо сокращать позиции}
Begin
         Assign(Eb,Path^.Dat.ToSPR+'lands.db');
         Reset(Eb);
         c:=Ioresult;
         If c=0 Then
         Begin
         Seek(Eb,StrToInt(Setup));
         c:=Ioresult;
         Truncate(Eb);
         c:=Ioresult;
         Close(Eb);
         c:=Ioresult;
         End
         Else
          Begin
                NoInfoMsg;
                MessageBox(^M+#3'Ошибка открытия '+Path^.Dat.ToSPR+'Lands.db',Nil,mfError+mfCancelButton);
                Exit;
          End;

End;
   NoInfoMsg;
   MessageBox(^M+#3+'Реструктаризация успешно завершена!',Nil,mfInformation+mfCancelButton);
   AddProtocol('Реструктаризация базы '+Path^.Dat.ToSPR+'Lands.db','','');
   RefreshCashOneSPR(bLands);
  End
Else
Begin
Dispose(Control,Done);
Dispose(Dlg,Done);
End;

End;





Procedure CorrectNGTD;
Label 1;
Var      s  : AllStr;
         c,c1  : LongInt;
         Eb : File Of NGTDType;
         BB : PNGTDType;
         Max,Pr,Emp : AllStr;
         Setup : String[5];
         RKod : ArtikulStr;
         Dlg : PDialog;
         R : TRect;
         Control : PView;
         j : Word;
Begin
ClearFind;

If Not(TestOpenDate1(FDate)) Then
        Begin
         MessageBox(#3^M+#3'Доступ к данным за '+FDate+' заблокирован!',Nil,mfError+mfCancelButton);
         Exit;
        End;

If (GlobalReadOnly=1) Or (ReadOnlyConst=1) Then
   Begin
    MessageBox(#3^M+ReadOnlyStr^,Nil,mfWarning+mfCancelButton);
    Exit;
   End;


C:=IOResult;

If Not(Password(5)) Then Exit;

Assign(Eb,Path^.Dat.ToSPR+'NGTD.db');
Reset(Eb);
C:=IOResult;
If C<>0 Then
Begin
 MessageBox(^M+#3'Ошибка доступа к '+Path^.Dat.ToSPR+'NGTD.db',nil,mfError+mfCancelButton);
 Exit;
End;

Max:=IntToSTr(FileSize(Eb),5);
DInfoMsg('Определяю свойства базы...',True);
New(BB,Init);
Emp[0]:=#0;
Pr[0]:=#0;
While Not(Eof(Eb)) Do
 BEgin

 Read(Eb,BB^.Dat);

 If (BB^.DAt.Employ) Then
        Begin
         Str((StrToInt(Emp)+1):5,Emp);{занятые позиции}
         {Pr:=IntToStr(FilePos(Eb),CDate);{последний занятый код}
         Pr:=IntToStr(StrToInt(BB^.DAt.Kod),CArtikul);
        End;


 End;
CLose(Eb);
Dispose(BB,Done);
NoInfoMsg;

1:
R.Assign(22, 7, 61, 16);
New(Dlg, Init(R, 'Свойства базы'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx := $E002;


R.Assign(9,3,23,4);
Control := New(PColoredText, Init(R, 'Всего позиций:', $74));
Dlg^.Insert(Control);

R.Assign(23, 3, 28, 4);
STr(StrToInt(MAx):5,MAx);
Control := New(PColoredText, Init(R, #3+Max, $7E));
Dlg^.Insert(Control);

R.Assign(2, 2, 23, 3);
Control := New(PColoredText, Init(R, 'Используется позиций:', $74));
Dlg^.Insert(Control);

If StrToInt(MAx)>0 Then
MyStr(StrToInt(Emp)/StrToInt(Max)*100,CLitr+1,CMantissa,s)
Else s:='0.00';

R.Assign(23, 2, 38, 3);
Control := New(PColoredText, Init(R, Emp+' '+s+'%', $7E));
Dlg^.Insert(Control);


R.Assign(1, 6, 38, 7);
Control := New(PStaticText, Init(R, ''));
Control^.Options := Control^.Options or ofFramed;
Dlg^.Insert(Control);


R.Assign(24, 6, 31, 7);
Control := New(PInputLine, Init(R, 5));
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['0','1','2','3','4','5','6','7','8','9']));

  R.Assign(4, 6, 24, 7);
  Dlg^.Insert(New(PLabel, Init(R, 'Установить позиций:', Control)));

R.Assign(6, 4, 23, 5);
Control := New(PColoredText, Init(R, 'Максимальный код:', $74));
Dlg^.Insert(Control);

R.Assign(23, 4, 35, 5);
If pr[0]=#0 Then Pr:='0';
Control := New(PColoredText, Init(R, Pr+' ('+IntToSTr(StrToInt(Pr),5)+')', $7E));
Dlg^.Insert(Control);

Setup:=Max;
DelSpace(Setup);
Dlg^.SetData(Setup);

Dlg^.SelectNext(False);
c:=Desktop^.ExecView(Dlg);
if c<>cmCancel Then
  BEgin

        Dlg^.GetData(Setup);
        If StrToInt(Setup)<(StrToInt(Pr)+1) Then
         BEgin
          Dispose(Control,Done);
          Dispose(Dlg,Done);
          MessageBox(RestructError^,Nil,mfError+mfCAncelButton);
          Goto 1;
         End;

Dispose(Control,Done);
Dispose(Dlg,Done);


DInfoMsg('Провожу реструктуризацию. Ждите ...',True);


        If StrToInt(Setup)>StrToInt(MAx) Then{надо добавлять позиции}
        Begin
         Assign(Eb,Path^.Dat.ToSPR+'NGTD.db');
         Reset(Eb);
         c:=Ioresult;
         If c=0 Then
         Begin
          Seek(Eb,StrToInt(Max));
          New(bb,Init);
          For c:=1 To (StrToInt(Setup)-StrToInt(MAx)) Do
                Begin
   BB^.Dat.Employ :=False;
   Str(C-1+StrToInt(MAx):CArtikul,S);
   BB^.Dat.Kod :=s;
   RFormatZerro(BB^.Dat.Kod,CArtikul);
   BB^.Dat.NGTD[0] :=#0;
   BB^.Dat.RCD:=False;
                 Seek(eb,FileSize(eb));
                 Write(eb,bb^.Dat);
                End;
          Dispose(bb,Done);
          c:=Ioresult;
          Close(Eb);
          c:=Ioresult;
         End{If}
          Else
                Begin
                 NoInfoMsg;
                 MessageBox(^M+#3'Ошибка открытия '+Path^.Dat.ToSPR+'NGTD.db',Nil,mfError+mfCancelButton);
                 Exit;
                End;{Else}

        End;


If StrToInt(Setup)<=StrToInt(MAx) Then{надо сокращать позиции}
Begin
         Assign(Eb,Path^.Dat.ToSPR+'NGTD.db');
         Reset(Eb);
         c:=Ioresult;
         If c=0 Then
         Begin
         Seek(Eb,StrToInt(Setup));
         c:=Ioresult;
         Truncate(Eb);
         c:=Ioresult;
         Close(Eb);
         c:=Ioresult;
         End
         Else
          Begin
                NoInfoMsg;
                MessageBox(^M+#3'Ошибка открытия '+Path^.Dat.ToSPR+'NGTD.db',Nil,mfError+mfCancelButton);
                Exit;
          End;

End;
   NoInfoMsg;
   MessageBox(^M+#3+'Реструктаризация успешно завершена!',Nil,mfInformation+mfCancelButton);
   AddProtocol('Реструктаризация базы '+Path^.Dat.ToSPR+'NGTD.db','','');
   RefreshCashOneSPR(bNGTD);
  End
Else
Begin
Dispose(Control,Done);
Dispose(Dlg,Done);
End;
End;







Procedure CorrectBaza(Reg,Sel:Word);
Label 1;
Var s,s1,s2  : AllStr;
         c,c1  : LongInt;
         Max,Pr,Emp : AllStr;
         Setup : String[4];
         RKod : ArtikulStr;
         Dlg : PDialog;
         R : TRect;
      ClientFile : ClientFileType;
      ClientFileIDX : File Of KurzClientType;
         Control : PView;
      BB : PClientType;
      BB1 : KurzClientType;
Begin
ClearFind;

If Not(TestOpenDate1(FDate)) Then
        Begin
         MessageBox(#3^M+#3'Доступ к данным за '+FDate+' заблокирован!',Nil,mfError+mfCancelButton);
         Exit;
        End;

If (GlobalReadOnly=1) Or (ReadOnlyConst=1) Then
   Begin
    MessageBox(#3^M+ReadOnlyStr^,Nil,mfWarning+mfCancelButton);
    Exit;
   End;


C:=IOResult;

If Not(Password(5)) Then Exit;

s[0]:=#0;
s1[0]:=#0;
Case Reg Of
0:Begin
    Case Sel Of
     0:Begin s:=Path^.Dat.ToClient+'Client.db'; s1:='Client.db';
        s2:=Path^.Dat.ToClientBaseIndex+'Client.idx';
	  End;
     1:Begin s:=Path^.Dat.ToClient+'Sklad.db'; s1:='Sklad.db';
        s2:=Path^.Dat.ToClientBaseIndex+'Sklad.idx';
	  End;
     2:Begin s:=Path^.Dat.ToClient+'Barter.db';s1:='Barter.db';
        s2:=Path^.Dat.ToClientBaseIndex+'Barter.idx';
	  End;
     Else;
     End;{CAse}
  End;

1:Begin
    Case Sel Of
     0:Begin s:=Path^.Dat.ToClient+'Make.db'; s1:='Make.db';
        s2:=Path^.Dat.ToClientBaseIndex+'make.idx';
	  End;
     1:Begin s:=Path^.Dat.ToClient+'Sklad.db'; s1:='Sklad.db';
        s2:=Path^.Dat.ToClientBaseIndex+'sklad.idx';
	  End;
     2:Begin s:=Path^.Dat.ToClient+'Barter.db'; s1:='Barter.db';
        s2:=Path^.Dat.ToClientBaseIndex+'Barter.idx';
	  End;
     Else;
     End;{CAse}
  End;
Else;
End;



Assign(ClientFile,s);
C:=IOResult;
Reset(ClientFile);
C:=IOResult;
If C<>0 Then
Begin
 MessageBox(^M+#3'Ошибка доступа к базе!'^M+
 #3+ClicProgrammer^,nil,mfError+mfCancelButton);
 Exit;
End;

Assign(ClientFileIdx,s2);
C:=IOResult;
Reset(ClientFileIDX);
C:=IOResult;
If C<>0 Then
Begin
 Close(ClientFile);
 MessageBox(^M+#3'Ошибка доступа к базе!'^M+
 #3+ClicProgrammer^,nil,mfError+mfCancelButton);
 Exit;
End;


Max:=IntToSTr(FileSize(ClientFile),4);
DInfoMsg('Определяю свойства базы...',True);
New(BB,Init);
Emp[0]:=#0;
Pr[0]:=#0;
While Not(Eof(ClientFile)) Do
 BEgin
  ReadClient(ClientFile,BB^.Dat);
  If (BB^.DAt.Employ) Then
        Begin
         Str((StrToInt(Emp)+1):4,Emp);{занятые позиции}
         Pr:=Copy(BB^.DAt.Kod,1,CClientKod);{последний занятый код}
        End;
 End;

CLose(ClientFile);
CLose(ClientFileIDX);
Dispose(BB,Done);
NoInfoMsg;

1:
R.Assign(21, 7, 58, 16);
New(Dlg, Init(R, 'Свойства базы'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx := $E002;


R.Assign(9, 3, 23, 4);
Control := New(PColoredText, Init(R, 'Всего позиций:', $74));
Dlg^.Insert(Control);

R.Assign(23, 3, 35, 4);
STr(StrToInt(MAx):4,MAx);
Control := New(PColoredText, Init(R, #3+Max, $7E));
Dlg^.Insert(Control);

R.Assign(2, 2, 23, 3);
Control := New(PColoredText, Init(R, 'Используется позиций:', $74));
Dlg^.Insert(Control);

If StrToInt(MAx)>0 Then
MyStr(StrToInt(Emp)/StrToInt(Max)*100,CLitr+1,CMantissa,s)
Else s:='0.00';

R.Assign(23, 2, 35, 3);
Control := New(PColoredText, Init(R, Emp+' '+s+'%', $7E));
Dlg^.Insert(Control);

R.Assign(2, 1, 35, 2);
Control := New(PColoredText, Init(R, #3+s1, $7E));
Dlg^.Insert(Control);

R.Assign(1, 6, 36, 7);
Control := New(PStaticText, Init(R, ''));
Control^.Options := Control^.Options or ofFramed;
Dlg^.Insert(Control);

R.Assign(26, 6, 32, 7);
Control := New(PInputLine, Init(R, 4));
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['0','1','2','3','4','5','6','7','8','9']));

  R.Assign(6, 6, 26, 7);
  Dlg^.Insert(New(PLabel, Init(R, 'Установить позиций:', Control)));

R.Assign(6, 4, 23, 5);
Control := New(PColoredText, Init(R, 'Максимальный код:', $74));
Dlg^.Insert(Control);

R.Assign(23, 4, 35, 5);
If pr[0]=#0 Then Pr:='0';
Control := New(PColoredText, Init(R, Pr+' ('+IntToSTr(StrToInt(Pr),4)+')', $7E));
Dlg^.Insert(Control);

Setup:=Max;
DelSpace(Setup);
Dlg^.SetData(Setup);

Dlg^.SelectNext(False);
c:=Desktop^.ExecView(Dlg);
if c<>cmCancel Then
  BEgin
        Dlg^.GetData(Setup);
        If StrToInt(Setup)<(StrToInt(Pr)+1) Then
         BEgin
          Dispose(Control,Done);
          Dispose(Dlg,Done);
          MessageBox(RestructError^,Nil,mfError+mfCAncelButton);
          Goto 1;
         End;

        If StrToInt(Setup)>=(9999) Then
         BEgin
          Dispose(Control,Done);
          Dispose(Dlg,Done);
          MessageBox(^M+#3'Слишком большое количество элементов внутри базы! ',Nil,
          mfError+mfCAncelButton);
          Goto 1;
         End;

Dispose(Control,Done);
Dispose(Dlg,Done);


DInfoMsg('Провожу реструктуризацию '+s1+'. Ждите ...',True);
{MemC('Расчет');}

        If StrToInt(Setup)>StrToInt(MAx) Then{надо добавлять позиции}
        Begin
         c:=Ioresult;
         Reset(ClientFile);
         c:=Ioresult;
         Reset(ClientFileIDX);
         c:=Ioresult;
         If c=0 Then
         Begin
          Seek(ClientFile,StrToInt(Max));
          Seek(ClientFileIDX,StrToInt(Max));
          New(bb,Init);
          For c:=1 To (StrToInt(Setup)-StrToInt(MAx)) Do
                Begin
                 Str(C+StrToInt(MAx)-1:4,S);
                 RFormatZerro(s,4);
                 bb^.Dat.Kod:=s;
                 bb^.Dat.Employ:=False;

                 bb1.Kod:=StrToInt(s);
                 bb1.Employ:=False;

                 Seek(ClientFile,FileSize(ClientFile));
                 Write(ClientFile,bb^.Dat);

                 Seek(ClientFileIDX,FileSize(ClientFileIDX));
                 Write(ClientFileIDX,bb1);
                End;
          Dispose(bb,Done);
          c:=Ioresult;
          Close(ClientFile);
          c:=Ioresult;
          Close(ClientFileIDX);
          c:=Ioresult;
         End{If}
          Else
                Begin
                 NoInfoMsg;
                 MessageBox(^M+#3'Ошибка открытия базы!'^M+
                 #3+ClicProgrammer^,Nil,mfError+mfCancelButton);
                 Exit;
                End;{Else}
     End
     Else
      Begin
         c:=Ioresult;
         Reset(ClientFile);
         c:=Ioresult;
         Reset(ClientFileIDX);
         c:=Ioresult;
         If c=0 Then
         Begin
         Seek(ClientFile,StrToInt(Setup));
         c:=Ioresult;
         Seek(ClientFileIDX,StrToInt(Setup));
         c:=Ioresult;
         Truncate(ClientFile);
         c:=Ioresult;
         Truncate(ClientFileIDX);
         c:=Ioresult;
         Close(ClientFile);
         c:=Ioresult;
         Close(ClientFileIDX);
         c:=Ioresult;
         End
         Else
          Begin
                NoInfoMsg;
                MessageBox(^M+#3'Ошибка открытия базы!'^M+
                #3+ClicProgrammer^,Nil,mfError+mfCancelButton);
                Exit;
          End;
      End;

NoInfoMsg;

     MessageBox(^M+#3+'Реструктаризация успешно завершена!',Nil,mfInformation+mfCancelButton);
     AddProtocol('Реструктаризация базы ' +s1,'','');
  End
Else
Begin
Dispose(Control,Done);
Dispose(Dlg,Done);
End;

End;





Function CalcPack(Kod,Kol:TDateString):AllStr;
 Var Code : Integer;
     INP,Pack,Itogo  : LongInt;
     ws : AllStr;
Begin
 CalcPack[0]:=#0;
 DElspace(Kol);
 Val(GetIdField(FInPack,Kod),INP,Code);
 Val(Kol,Itogo,Code);
 If Inp=0 Then Exit;
 Pack :=Itogo div Inp;
 If (Itogo-Pack*Inp)<>0 Then
  Begin
   Str(Pack:5,ws);
   Str((Itogo-Pack*Inp):3,Kol);
   ws:=Ws+'+'+Kol;
   Format(Ws,CPack);
  End
  Else
   Begin
    Str(Pack:5,ws);
    Format(Ws,CPack);
   End;
  CalcPack:=Ws;
End;

Function CalcPackNoFile(Kod,Kol:TDateString):AllStr;
 Var INP,Pack,Itogo  : LongInt;
     ws : AllStr;
Begin
 CalcPackNoFile[0]:=#0;
 DElspace(Kol);
 DElspace(Kod);
 Inp:=StrToInt(Kod);
 Itogo:=StrToInt(Kol);
 If Inp=0 Then Exit;
 Pack :=Itogo div Inp;
 If (Itogo-Pack*Inp)<>0 Then
  Begin
   Str(Pack:5,ws);
   Str((Itogo-Pack*Inp):3,Kol);
   ws:=Ws+'+'+Kol;
   Format(Ws,CPack);
  End
  Else
   Begin
    Str(Pack:5,ws);
    Format(Ws,CPack);
   End;
  CalcPackNoFile:=Ws;
End;



Function GetClient(Var Cl : PClientType;VidOperator:Word):Boolean;
Var f : ClientFileType;
    l : LongInt;
    s : ClientType;
    st : ArtikulStr;
    c,Code : Integer;
    ss : AllStr;
Begin
 OldFileMode:=FileMode;
 FileMode:=ReadOnlyN;
 GetClient:=False;

Case VidOperator Of
0:Assign (f,Path^.Dat.ToClient+'Client.db');
1:Assign (f,Path^.Dat.ToClient+'Sklad.db');
2:Assign (f,Path^.Dat.ToClient+'Barter.db');
Else;
End;

 l:=IOResult;
 Reset(f);
 FileMode:=OldFileMode;
 l:=IOResult;
 If l <> 0 Then
 Begin
  MessageBox(^M+#3'Ошибка открытия файла клиентов!'+
  ^M+#3'Код:'+IntToStr(l,3),nil,mfError+mfCancelButton);
  Exit;
 End
 Else
  Begin
   DelSpace(Cl^.DAt.Kod);
   l:=StrToInt(Cl^.DAt.Kod);

   If l>FileSize(f) Then
    Begin
     System.Close(f);
     c:=IOResult;
     MessageBox(^M+#3'Попытка чтения клиента '+Cl^.DAt.Kod+' - позиция вне файла!'^M+
	#3+'Позиция:'+IntToStr(l,CKol)+'('+IntToStr(FileSize(f),CKol)+')',nil,mfError+mfCancelButton);
     Exit;
    End;

   Seek(f,l);
   l:=IOResult;
   ReadClient(f,Cl^.DAt);
   l:=IOResult;
   Close(f);
   l:=IOResult;
   GetClient:=True;
  End;

  If Not(Cl^.Dat.Employ) Then Cl^.Dat.Name:='!!!КЛИЕНТ УДАЛЕН!!!';
End;



Procedure GetAgent(Var Cl : PClientType);
Var f : ClientFileType;
    l : LongInt;
    s : ClientType;
    st : ArtikulStr;
    c,Code : Integer;
    ss : AllStr;
Begin
 OldFileMode:=FileMode;
 FileMode:=ReadOnlyN;
 Assign (f,Path^.Dat.ToClient+'agent.db');
 l:=IOResult;
 Reset(f);
 FileMode:=OldFileMode;
 l:=IOResult;
 If l <> 0 Then
 Begin
  MessageBox(^M+#3'Ошибка открытия файла агентов!'+
  ^M+#3'Код:'+IntToStr(l,3),nil,mfError+mfCancelButton);
  Exit;
 End
 Else
  Begin
   DelSpace(Cl^.DAt.Kod);
   l:=StrToInt(Cl^.DAt.Kod);

   If l>FileSize(f) Then
    Begin
     System.Close(f);
     c:=IOResult;
     MessageBox(^M+#3'Попытка чтения агента '+Cl^.DAt.Kod+' - позиция вне файла!'^M+
	#3+'Позиция:'+IntToStr(l,CKol)+'('+IntToStr(FileSize(f),CKol)+')',nil,mfError+mfCancelButton);
     Exit;
    End;

   Seek(f,l);
   l:=IOResult;
   ReadClient(f,Cl^.DAt);
   l:=IOResult;
   Close(f);
   l:=IOResult;
  End;
  If Not(Cl^.Dat.Employ) Then Cl^.Dat.Name:='!!!АГЕНТ УДАЛЕН!!!';
End;


Procedure GetEksped(Var Cl : PClientType);
Var f : ClientFileType;
    l : LongInt;
    s : ClientType;
    st : ArtikulStr;
    c,Code : Integer;
    ss : AllStr;
Begin
 OldFileMode:=FileMode;
 FileMode:=ReadOnlyN;
 Assign (f,Path^.Dat.ToClient+'Eksped.db');
 l:=IOResult;
 Reset(f);
 FileMode:=OldFileMode;
 l:=IOResult;
 If l <> 0 Then
 Begin
  MessageBox(^M+#3'Ошибка открытия файла экспедиторов!'+
  ^M+#3'Код:'+IntToStr(l,3),nil,mfError+mfCancelButton);
  Exit;
 End
 Else
  Begin
   DelSpace(Cl^.DAt.Kod);
   l:=StrToInt(Cl^.DAt.Kod);

   If l>FileSize(f) Then
    Begin
     System.Close(f);
     c:=IOResult;
     MessageBox(^M+#3'Попытка чтения экспедитора '+Cl^.DAt.Kod+' - позиция вне файла!'^M+
	#3+'Позиция:'+IntToStr(l,CKol)+'('+IntToStr(FileSize(f),CKol)+')',nil,mfError+mfCancelButton);
     Exit;
    End;

   Seek(f,l);
   l:=IOResult;
   ReadClient(f,Cl^.DAt);
   l:=IOResult;
   Close(f);
   l:=IOResult;
  End;
  If Not(Cl^.Dat.Employ) Then Cl^.Dat.Name:='!!!ЭКСПЕД.УДАЛЕН!!!';
End;







End.