unit BuxOtch;

INTERFACE

Uses Glob, ServStr, Serv;


Procedure CalcBux;

IMPLEMENTATION

{$I Compile.INC}

Uses Objects,App,Views,Validate,Dialogs, MsgBox, TPDate,Printers,
     ServStr2,
     NetDbEng,DBEngine, Tools, Utils,Utils5{, DBEngin1};

const
      CShetNumer = 6;

{$IFDEF TABAK}
      CKOl = 6;
{$ENDIF}

Type
     ShElement = Record
     Kol     : String[5];
     Zena    : String[CZena];
     Artikul : String[CArtikul];
     End;


Type
    TShet = Record
    Numer  : String[CShetNumer];
    Dat    : String[CDate];
    Bn     : Word;
    Sklad  : String[COne];
    Client : String[CClientKod];
    Pos    : Array[1..60] Of ShElement;
    ItogoN : String[CIZena];
    ItogoN5: String[CIZena];
    ItogoN3: String[CIZena];
    ItogoN_: String[CIZena];
    ItogoZ : String[CIZena];
    ItogoL : String[CILitr];
  end;


var
    TempBox, VBox: PBOX;
    StartDate,StopDate : TDateString;
    Vid: word;
    Den: LongInt;
    PName: string;

Function TestElementNew (Const S : AllStr;Const P : PBox) : Boolean;
Var ls : Word;
    k  : Byte;
    st : String[CALL];
Begin
TestElementNew:=True;
For ls :=0 To P^.List^.Count Do
Begin
St:=P^.GetText(ls,P^.List^.Count);
ST:=Copy(St,1,CArtikul);
If St=S Then
   Begin
    TestElementNew:=False;
    Break;
   End;
End;
End;


Function PeriodProd:Boolean;
Label 1;
var
  Dlg : PDialog;
  R : TRect;
  Control,ControlStart,ControlStop,ControlVidDoc : PView;
  C : Word;
  l : LongInt;
  s1,s2 : TDateString;

begin
PeriodProd :=False;
s1:=FDate;
s2:=FDate;

1:
R.Assign(20, 8, 57, 13);
New(Dlg, Init(R, 'Период расчета продаж'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx:=$E011;
Dlg^.Palette := dpCyanDialog;

R.Assign(6, 2, 16, 3);
ControlStart := New(PInputLine, Init(R, 8));
Dlg^.Insert(ControlStart);
  PInputLine(ControlStart)^.Validator := New(PPXPictureValidator, Init({'[##-##-9#]'}DateFiltr, True));

{R.Assign(1, 4, 29, 7);
ControlVidDoc := New(PCheckboxes, Init(R,
  NewSItem('Сп',
  NewSItem('ТЧ*',
  NewSItem('ФЛ*',
  NewSItem('СФ*',
  NewSItem('СФБ',
  NewSItem('Д*',
  NewSItem('ДСФ*',
  NewSItem('Д',
  NewSItem('ДСФБ', Nil)))))))))));
ControlVidDoc^.SetData(Vid);
Dlg^.Insert(ControlVidDoc);

R.Assign(1, 3, 26, 4);
Dlg^.Insert(New(PLabel, Init(R, 'Виды документов расхода:', ControlVidDoc)));}


ControlStart^.SetData(s1);

  R.Assign(3, 2, 6, 3);
  Dlg^.Insert(New(PLabel, Init(R, '~с~:', ControlStart)));

R.Assign(20, 2, 30, 3);
ControlStop := New(PInputLine, Init(R, 8));
Dlg^.Insert(ControlStop);
  PInputLine(ControlStop)^.Validator := New(PPXPictureValidator, Init({'[##-##-9#]'}DateFiltr, True));

ControlStop^.SetData(s2);

  R.Assign(16, 2, 20, 3);
  Dlg^.Insert(New(PLabel, Init(R, '~п~о:', ControlStop)));

Dlg^.SelectNext(False);
c:=Desktop^.ExecView(Dlg);
If c<>cmCancel Then
 Begin
   ControlStart^.GetData(s1);
   ControlStop^.GetData(s2);
   {ControlVidDoc^.GetData(Vid);}
   Dispose(ControlStart,Done);
   Dispose(ControlStop,Done);
   {Dispose(ControlVidDoc,Done);}
   Dispose(Dlg,Done);

   If Not(TestDate(s1,L)) Then
    Begin
     MessageBox(^M+#3'Ошибка при вводе начала периода!',Nil,mfError+mfCancelButton);
     Goto 1;
    End;

   If Not(TestDate(s2,L)) Then
    Begin
     MessageBox(^M+#3'Ошибка при вводе конца периода!',Nil,mfError+mfCancelButton);
     Goto 1;
    End;

   StartDate:=s1;
   StopDate:=s2;


   PeriodProd:=True;

   {если даты перепутаны переставляем их}
   If DateStringToDate(DateMask,StopDate)<DateStringToDate(DateMask,StartDate) Then
    Begin
        s1:=StopDate;
        StopDate:=StartDate;
        StartDate:=s1;
    End;
 End
 Else
  Begin
   Dispose(ControlStart,Done);
   Dispose(ControlStop,Done);
   Dispose(ControlVidDoc,Done);
   Dispose(Dlg,Done);
  End;
end;


{$IfNDEF TABAK}
procedure PrihAddToList(Const E:PPrihodType);
var
  sKol: string[CKOL];
  ssumma: string[CIZena];
  Artikul: string[CArtikul];
  sZena: string[CZena+2];
  sName1,sName: string[CName];
  sClient: string[CMakeKod];
  find:boolean;
  i,j:word;
  st,st1,ss:string;
Begin
DInfoMsg('Просматриваю приходы за '+DateToDateString(DateMask,DEn),False);
{Memc(E^.Dat.Document+' '+E^.Dat.SummaZakupka);}
For i:=1 to E^.Dat.Amount do
 begin
  If TempBox^.List^.Count-1>=0 Then
   begin
    find:=false;

    for j:=0 to TempBox^.List^.Count-1 do
      begin
       st1[0]:=#0;
       st1:=Copy(TempBox^.GetText(j,TempBox^.List^.Count),1,CArtikul);
       format(st1,CArtikul);
       Artikul:=E^.Dat.PrihodElement[i].BazKod;
       sClient:=E^.Dat.MakeKod;
       {writeln(sClient);
       readln;}
       {sName1:=GetIdField(FName,st1);
       sName:=GetIdField(FName,E^.Dat.PrihodElement[i].BazKod);}
       format(Artikul,CArtikul);
       format(sClient,CMakeKod);

       if st1=Artikul{sName1=sName} then
        begin
          find:=true;
          st[0]:=#0; ss:='';
          st:=TempBox^.GetText(j,TempBox^.List^.Count);
          sKol:=Copy(TempBox^.GetText(j,TempBox^.List^.Count),1+CArtikul+CIZena+CKol,CKol);
          sKol:=IntToStr(StrToInt(E^.Dat.PrihodElement[i].Input.Kol)+StrToInt(sKol),CKol);
          rformat(sKol,CKol);
          ss:=ss+sKol;
          sZena:='';
   {для альфы}
         if (sClient='0158') and (E^.Dat.OperatorSelector=0)
          then
           begin
          sZena:=E^.Dat.PrihodElement[i].Input.Zakupka2;
          {memc(E^.Dat.PrihodElement[i].Input.Zakupka+' '+E^.Dat.PrihodElement[i].Input.Zakupka2+' '+sZena+'  2!');}
           end
          else
   {для остальных}
          begin

          sZena:=E^.Dat.PrihodElement[i].Input.Zakupka;
         { memc(E^.Dat.PrihodElement[i].Input.Zakupka+' '+E^.Dat.PrihodElement[i].Input.Zakupka2+' '+sZena+' 1!');}
          {writeln(sZena);
          readln }
          end;
         { memc(E^.Dat.PrihodElement[i].Input.Zakupka+' '+E^.Dat.PrihodElement[i].Input.Zakupka2+' '+sZena+' !');}
          sSumma:=Copy(TempBox^.GetText(j,TempBox^.List^.Count),1+CArtikul+CIZena+CKol+CKol,CIZena);
          MyStr(StrToReal(sSumma)+StrToReal(sZena)*StrToReal(E^.Dat.PrihodElement[i].Input.Kol),CIZena,CMantissaZ,sSumma);
          rformat(sSumma,CIZena);
          ss:=ss+sSumma;
          System.Delete(st,1+CArtikul+CIZena+CKol,CKol+CIZena);
          System.Insert(ss,st,1+CArtikul+CIZena+CKol);
          {sKOl:='0';
          sSumma:='0.00';
          rformat(sKol,CKol);
          rformat(sSumma,CIZena);
          st:=st+Skol+sSumma;
          st:=st+Skol+sSumma;}
          {TempBox^.List^.AtDelete(j);
          TempBox^.List^.AtInsert(j,NewStr(st));}
          TempBox^.List^.AtFree(j);
          TempBox^.SetRange(TempBox^.List^.Count);

          TempBox^.List^.Insert(NewStr(st));
          TempBox^.SetRange(TempBox^.List^.Count);

        end;
      end;
    if not find then
      begin
        st[0]:=#0;
        Artikul:=E^.Dat.PrihodElement[i].BazKod;
        sClient:=E^.Dat.MakeKod;
        st:=Artikul;
        sKol:='0';
        sSumma:='0.00';
        rformat(sKol,CKol);
        rformat(sSumma,CIZena);
        st:=st+sKol+sSumma;
    {для альфы}
         if (sClient='0158') and (E^.Dat.OperatorSelector=0)
          then
           begin
            sZena:=E^.Dat.PrihodElement[i].Input.Zakupka2
           end
          else
   {для остальных}
          sZena:=E^.Dat.PrihodElement[i].Input.Zakupka;

        rformat(sZena,CZena+2);
        sKol:=E^.Dat.PrihodElement[i].Input.Kol;
        rformat(skol,CKol);
        st:=st+sKol;
        MyStr(StrToReal(sKol)*StrToReal(sZena),CIZena,CMantissaZ,sSumma);
        rformat(sSumma,CIZena);
        st:=st+sSumma;
        sKol:='0';
        sSumma:='0.00';
        rformat(sKol,CKol);
        rformat(sSumma,CIZena);
        st:=st+sKol+sSumma;
        st:=st+sKol+sSumma;
        TempBox^.List^.Insert(NewStr(st));
      end;
   end;

 end;
 NoinfoMsg;
End;

procedure MarkOptAddToList(Const E:TShet);
var
  Artikul: string[CArtikul];
  sZena: string[CZena];
  sSumma: string[CIZena];
  sName,sName1: string[CName];
  sKol: string[CKOL];
  news,st,st1,st2,ss: string;
  find:boolean;
  i,j,Pos:word;
Begin
DInfoMsg('Просматриваю опт.продажи за '+DateToDateString(DateMask,DEn),False);
For i:=1 to 60 do
begin
 if E.Pos[i].Artikul = '' then break;
{ if E.Pos[i].Artikul = '00035' then
  Begin
  Readln;
  End;  }

    find:=false;
    If Not TestElementNew(E.Pos[i].Artikul,TempBox) Then
     Begin
      Pos:=Location(TempBox,E.Pos[i].Artikul,True);
      News:=TempBox^.GetText(Pos,TempBox^.List^.Count);
      st1[0]:=#0;ss:='';
      st1:=Copy(news,1,CArtikul);
      Artikul:=E.Pos[i].Artikul;
      format(Artikul,CArtikul);
      find:=true;
      {st:=Copy(News,1,CArtikul+CIZena+CKol+CIZena+CKol);}
      st2:=Copy(News,1+CArtikul+CIZena+CKol+CIZena+CKol,CKol);
      sKol:=IntToStr(StrToInt(E.Pos[i].Kol)+StrToInt(st2),CKol);
      rformat(sKol,CKol);
      ss:=ss+sKol;
      sSumma:=Copy(News,1+CArtikul+CIZena+CKol+CIZena+CKol+CKol,CIZena);
      MyStr(StrToReal(sSumma)+StrToReal(E.Pos[i].Zena)*StrToReal(E.Pos[i].Kol),CIZena,CMantissa,sSumma);
      rformat(sSumma,CIZena);
      ss:=ss+sSumma;
      System.Delete(news,1+CArtikul+CIZena+CKol+CIZena+CKol,CKol+CIZena);
      System.Insert(ss,news,1+CArtikul+CIZena+CKol+CIZena+CKol);
      {sKol:='0';
      sSumma:='0.00';
      rformat(sKol,CKol);
      rformat(sSumma,CIZena);
      st:=st+sKol+sSumma;}

      TempBox^.List^.AtFree(Pos);
      TempBox^.SetRange(TempBox^.List^.Count);

      TempBox^.List^.Insert(NewStr(news));
      TempBox^.SetRange(TempBox^.List^.Count);
     End
    Else
     Begin
      st[0]:=#0;
      Artikul:=E.Pos[i].Artikul;
      format(Artikul,CArtikul);
      st:=st+Artikul;
      sKol:='0';
      sSumma:='0.00';
      rformat(sKol,CKol);
      rformat(sSumma,CIZena);
      st:=st+sKol+sSumma+Skol+SSumma;
      sZena:=E.Pos[i].Zena;
      rformat(sZena,CZena);
      sKol:=E.Pos[i].Kol;
      rformat(skol,CKol);
      st:=st+sKol;
      MyStr(StrToReal(sKol)*StrToReal(sZena),CIZena,CMantissa,sSumma);
      rFormat(sSumma,CIZena);
      st:=st+sSumma;
      sKol:='0';
      sSumma:='0.00';
      rformat(sKol,CKol);
      rformat(sSumma,CIZena);
      st:=st+sKol+sSumma;

      TempBox^.List^.Insert(NewStr(st));
      TempBox^.SetRange(TempBox^.List^.Count);
      Find:=True
     End;

end;{for i}
NoInfoMsg;
End;

procedure MarkRoznAddToList(Const E:TShet);
var
  Artikul: string[CArtikul];
  sZena: string[CZena];
  sSumma: string[CIZena];
  sName,sName1: string[CName];
  sKol: string[CKOL];
  news,st,st1,st2,ss: string;
  find:boolean;
  i,j,Pos:word;
Begin
DInfoMsg('Просматриваю розн.продажи за '+DateToDateString(DateMask,DEn),False);
For i:=1 to 60 do
begin
 if E.Pos[i].Artikul = '' then break;
    find:=false;
    If Not TestElement(E.Pos[i].Artikul,TempBox) Then
     Begin
      Pos:=Location(TempBox,E.Pos[i].Artikul,True);
      News:=TempBox^.GetText(Pos,TempBox^.List^.Count);
      st1[0]:=#0;
      st1:=Copy(news,1,CArtikul);
      Artikul:=E.Pos[i].Artikul;
      format(Artikul,CArtikul);
      find:=true;

         st[0]:=#0; ss:='';
         st:=Copy(NewS,1,CArtikul+CIZena+CKol+CIZena+CKol+CIZena+CKol);
         st2:=Copy(NewS,1+CArtikul+CIZena+CKol+CIZena+CKol+CIZena+CKol,CKol);
         sKol:=IntToStr(StrToInt(E.Pos[i].Kol)+StrToInt(st2),CKol);
         rformat(sKol,CKol);
         ss:=ss+sKol;
         sSumma:=Copy(News,1+CArtikul+CIZena+CKol+CIZena+CKol+CKol+CIZena+CKol,CIZena);
         {sZena:=E.Pos[i].Zena;}

         MyStr(StrToReal(sSumma)+StrToReal(E.Pos[i].Zena)*StrToReal(E.Pos[i].Kol),CIZena,CMantissa,sSumma);
         rformat(sSumma,CIZena);
         ss:=ss+sSumma;

         System.Delete(news,1+CArtikul+CIZena+CKol+CIZena+CKol+CIZena+CKol,CKol+CIZena);
         System.Insert(ss,news,1+CArtikul+CIZena+CKol+CIZena+CKol+CIZena+CKol);

      TempBox^.List^.AtFree(Pos);
      TempBox^.SetRange(TempBox^.List^.Count);

      TempBox^.List^.Insert(NewStr(news));
      TempBox^.SetRange(TempBox^.List^.Count);
     End
    Else
     Begin
      Find:=True;
      st[0]:=#0;
      Artikul:=E.Pos[i].Artikul;
      format(Artikul,CArtikul);
      st:=st+Artikul;
      sKol:='0';
      sSumma:='0.00';
      rformat(sKol,CKol);
      rformat(sSumma,CIZena);
      st:=st+sKol+sSumma+Skol+SSumma+Skol+SSumma;
      sZena:=E.Pos[i].Zena;
      rformat(sZena,CZena);
      sKol:=E.Pos[i].Kol;
      rformat(skol,CKol);
      st:=st+sKol;
      MyStr(StrToReal(sKol)*StrToReal(sZena),CIZena,CMantissa,sSumma);
      rFormat(sSumma,CIZena);
      st:=st+sSumma;
      TempBox^.List^.Insert(NewStr(st));
      TempBox^.SetRange(TempBox^.List^.Count);
     End;
end;{for i}
NoInfoMsg;
End;



Procedure CalcBux;
var Date : TDAteString;
    FM: file of TShet;
    FP: PrihodFileType;
    FV: NewVozwratFileType;
    sName: string[CName+1+CName];
    sName2: string[CName];
    sZena: string[CZena];
    sSumma: string[CIZena];
    SumOst,So,Sp,sPO,sPR,Sum_O,SumP,SumPO,SumPR,SrZ,SumZ,SumPRZ: string[CIZena];
    KolO,KolP,KolPO,KolPR: string[CKOL];
    KolOst: string[CKOL];
    Artikul: string[CArtikul];
    sKol: string[CKOL];
    sR,sR1: string[2];
    P: PPrihodType;
    M: TShet;
    V: PNewVozwratType;
    RAbday,Start,Stop: LongInt;
    FO,Txt: text;
    s3 : String;
    l,j,i,ii:word;
    R: TRect;
    s,ss,s1:string;
    n,k:word;
Begin
 vid:=1;
 If Not(PeriodProd) Then Exit;
 Start:=DateStringToDate(DateMask,StartDate);
 Stop:=DateStringToDate(DateMask,StopDate);

 Assign(Txt,Path^.Dat.ToTemp+'buxotch.txt');
 l:=IOResult;
 Rewrite(Txt);
 l:=IOResult;
 If L <> 0 Then
  Begin
   MessageBox(#3^M+#3'Не могу создать файл отчета'+Path^.Dat.ToTemp+'buxotch.txt',Nil,mfError+mfCancelButton);
   Exit;
  End;

 New(P,Init);


 R.Assign(0, 0, 0, 0);
 TempBox := New(PBox, Init(R, 1, Nil));
 TempBox^.NewList(New(PTextCollection, Init(0,1)));

 R.Assign(0, 0, 0, 0);
 VBox := New(PBox, Init(R, 1, Nil));
 VBox^.NewList(New(PTextCollection, Init(0,1)));


 Assign(FO,Path^.Dat.ToMarket+'baza.txt');
   l:=IOResult;
   Reset(fO);
   l:=Ioresult;
   If L <> 0 Then
    Begin                                 {!!!!!BUXGALT!!!}
      MessageBox(#3^M+#3'Не найден файл '+Path^.Dat.ToMarket+'BAZA.TXT',Nil,mfError+mfCancelButton);
      exit;
    End;
 s1:='';
 readln(FO,s1);
 n:=pos('$',s1);
 System.Delete(s1,n,1);
 k:=pos('$',s1)+1;
 Reset(FO);
 while not eof(FO) do
 begin
  s:=''; s1:='';
  readln(FO,s1);
  Artikul:=copy(s1,1,CArtikul);
  sKol:=copy(s1,n+1,k-n+1);
  rformat(sKol,CKol);
  sZena:=copy(s1,k+1,CZena);
  rformat(sZena,CZena);
  s:=Artikul+sKol;
  MyStr(StrToReal(sZena)*StrToReal(sKol),CIZena,CMantissa,sSumma);
  rformat(sSumma,CIZena);
  s:=s+sSumma;
  sKOl:='0';
  sSumma:='0.00';
  rformat(sKol,CKol);
  rformat(sSumma,CIZena);
  s:=s+Skol+sSumma;
  s:=s+Skol+sSumma;
  s:=s+Skol+sSumma;

 { writeln(s);
  readln;}
  TempBox^.List^.Insert(NewStr(s));
      TempBox^.SetRange(TempBox^.List^.Count);
 end;

{ close(txt);
 exit; }

 For Den:=Start To Stop Do
 Begin
   Date:=DateToDateString(DateMask,DEn);

 {Приходы}

              {!!!!!BUXGALT!!!}
   Assign(FP,Path^.Dat.ToMarket+Date+'.prh');
   l:=IOResult;
   Reset(fP);
   l:=Ioresult;
   If L <> 0 Then
    Begin                                 {!!!!!BUXGALT!!!}
     { MessageBox(#3^M+#3'Не найден файл '+Path^.Dat.ToMarket+Date+'.prh',Nil,mfError+mfCancelButton);}
      ;
    End
   else
   begin
    while not eof(FP) do
     begin
      ReadPrihod(FP,P);
      if (P^.Dat.OperatorSelector in [0,2]) then
       if  not ((StrToInt(P^.Dat.Document)=6) and (P^.Dat.DateC='08-01-02'))
       then
      PrihAddToList(P);
     end;

    Close(FP);
   end;
 {Продажи}
  {Опт}
              {!!!!!BUXGALT!!!}
   Assign(FM,Path^.Dat.ToMarket+'opt\'+Date+'.baz');
   l:=IOResult;
   Reset(fM);
   l:=Ioresult;
   If L <> 0 Then
    Begin                                 {!!!!!BUXGALT!!!}
     { MessageBox(#3^M+#3'Не найден файл '+Path^.Dat.ToMarket+Date+'.baz',Nil,mfError+mfCancelButton);}
      ;
    End
   else
   begin
    while not eof(FM) do
     begin
      Read(FM,M);
      MarkOptAddToList(M);
     end;

   Close(FM);
   end;
  {Розница}
              {!!!!!BUXGALT!!!}
   Assign(FM,Path^.Dat.ToMarket+'rozn\'+Date+'.baz');
   l:=IOResult;
   Reset(fM);
   l:=Ioresult;
   If L <> 0 Then
    Begin                                 {!!!!!BUXGALT!!!}
    {  MessageBox(#3^M+#3'Не найден файл '+Path^.Dat.ToMarket+Date+'.baz',Nil,mfError+mfCancelButton);}
      ;
    End
   else
   begin
    while not eof(FM) do
     begin
      Read(FM,M);
      MarkRoznAddToList(M);
     end;

   Close(FM);
   end;


 End; {For Den}
 sr1:='';
 sr:='';
 writeln(txt,'Начало печати');
 Writeln(txt,
'---------------------------------------------------------------------------------------------------'+
'-------------------------------------------');
 Writeln(txt,
' Код     Наименование            Ост.н     Сумма ост.н Прих.     Сумма прих.  Опт. Сумма прод.опт. '+
'Розн. Сумма прод.розн Ост.к Сумма ост. кон.');
 Writeln(txt,
'---------------------------------------------------------------------------------------------------'+
'-------------------------------------------');
{12345 12345678901234567890123456 12345 123456789012345 12345 123456789012345 12345 123456789012345
 12345 123456789012345 12345 123456789012345}

 Sum_O:='0.00';
 rformat(Sum_O,CIZena);
 SumP:='0.00';
 rformat(SumP,CIZena);
 SumPO:='0.00';
 rformat(SumPO,CIZena);
 SumPR:='0.00';
 rformat(SumPR,CIZena);
 SumZ:='0.00';
 rformat(SumZ,CIZena);
 SumPRZ:='0.00';
 rformat(SumPRZ,CIZena);

DInfoMsg('Формируется отчет',False);

 if TempBox^.List^.Count>0 then
 for j:=0 to TempBox^.List^.Count-1 do
  begin
   s:=TempBox^.GetText(j,TempBox^.List^.Count);
   KolO:=Copy(TempBox^.GetText(j,TempBox^.List^.Count),1+Cartikul,Ckol);
   KolP:=Copy(TempBox^.GetText(j,TempBox^.List^.Count),1+Cartikul+CKol+cizENA,Ckol);
   KolPO:=Copy(TempBox^.GetText(j,TempBox^.List^.Count),1+Cartikul+CKol+cizENA+CKol+cizENA,Ckol);
   KolPR:=Copy(TempBox^.GetText(j,TempBox^.List^.Count),1+Cartikul+CKol+cizENA+CKol+cizENA+CKol+cizENA,Ckol);
   sO:=Copy(TempBox^.GetText(j,TempBox^.List^.Count),1+Cartikul+CKol,CIZena);
   sP:=Copy(TempBox^.GetText(j,TempBox^.List^.Count),1+Cartikul+CKol+CIZena+CKol,CIZena);
   sPO:=Copy(TempBox^.GetText(j,TempBox^.List^.Count),1+Cartikul+CKol+CIZena+CKol+CIZena+CKol,CIZena);
   sPR:=Copy(TempBox^.GetText(j,TempBox^.List^.Count),1+Cartikul+CKol+CIZena+CKol+CIZena+CKol+CIZena+CKol,CIZena);
  {Средняя закупка}
  Artikul:=Copy(TempBox^.GetText(j,TempBox^.List^.Count),1,Cartikul);
  sR1:=copy(Artikul,1,2);
  if StrToInt(KolO)+StrToInt(KolP)>0 then
   MyStr((StrToReal(sO)+StrToReal(sP))/(StrToReal(KolO)+StrToReal(KolP)),CIZena,CMantissa,SrZ)
  else
   begin
    srZ:='0.00';
    rformat(srZ,CIZena);
   end;
 if StrToreal(srZ)<0.01 then
   begin
    srz:=BakGetField(FZakupka,Artikul,0);
    rformat(srZ,CIZena);
   end;
  { writeln(Artikul,' ',srZ);
   readln;}
  {Остаток на конец периода}
  if sr1<>'31' then
  begin
   KolOst:=IntToStr(StrToInt(KolO)+StrToInt(KolP)-StrToInt(KolPR)-StrToInt(KolPO),CKOL);
   MyStr(StrToReal(KolOst)*StrToReal(SrZ),CIZena,CMantissa,SumOst);
  end
  else
  begin
   MyStr(StrToReal(KolO)+StrToReal(KolP)-StrToReal(KolPR)-StrToReal(KolPO),CKOL,1,KOlOst);
   MyStr(StrToReal(KolOst)*StrToReal(SrZ),CIZena,CMantissa,SumOst);
  end;
   rformat(KolOst,CKOL);
   rformat(SumOst,CIZena);
   s:=s+KolOst+SumOst;
  { Суммы по столбцам}
   MyStr(StrToReal(Sum_O)+StrToReal(sO),CIZena,CMantissa,Sum_O);
   MyStr(StrToReal(SumP)+StrToReal(sP),CIZena,CMantissa,SumP);
   MyStr(StrToReal(SumPO)+StrToReal(sPO),CIZena,CMantissa,SumPO);
   MyStr(StrToReal(SumPR)+StrToReal(sPR),CIZena,CMantissa,SumPR);
   MyStr(StrToReal(SumZ)+StrToReal(sumOst),CIZena,CMantissa,SumZ);
   MyStr(StrToReal(SumPRZ)+StrToReal(KolPR)*StrToReal(srZ),CIZena,CMantissa,SumPrZ);
  {Наименование}

   sName:=GetIdField(FFFName,Artikul);

   format(sName,CName+1+CName);
   System.Insert(sName,s,1);
   System.Insert(' ',s,1+CArtikul+CName+1+CName+CKol+CIZena+CKol+CIZena+CKol+CIZena+CKol+CIZena+CKol);
   System.Insert(' ',s,1+CArtikul+CName+1+CName+CKol+CIZena+CKol+CIZena+CKol+CIZena+CKol+CIZena);
   System.Insert(' ',s,1+CArtikul+CName+1+CName+CKol+CIZena+CKol+CIZena+CKol+CIZena+CKol);
   System.Insert(' ',s,1+CArtikul+CName+1+CName+CKol+CIZena+CKol+CIZena+CKol+CIZena);
   System.Insert(' ',s,1+CArtikul+CName+1+CName+CKol+CIZena+CKol+CIZena+CKol);
   System.Insert(' ',s,1+CArtikul+CName+1+CName+CKol+CIZena+CKol+CIZena);
   System.Insert(' ',s,1+CArtikul+CName+1+CName+CKol+CIZena+CKol);
   System.Insert(' ',s,1+CArtikul+CName+1+CName+CKol+CIZena);
   System.Insert(' ',s,1+CArtikul+CName+1+CName+CKol);
   System.Insert(' ',s,1+CArtikul+CName+1+CName);
   System.Insert(' ',s,1+CName+1+CName);

   sR1:=copy(Artikul,1,2);

   if sr<>sr1 then
    begin
      if VBox^.List^.Count>0 then
       begin
       for ii:=0 to VBox^.List^.Count-1 do
        begin
         ss:='';
         ss:=VBox^.GetText(ii,VBox^.List^.Count);
         writeln(txt,ss);
        end;
       VBox^.NewList(Nil);
       VBOx^.NewList(New(PTextCollection, Init(0,1)));
      end;

      writeln(txt);
      writeln(txt,'     Раздел: ',GetRazdel(sr1));
      writeln(txt);
      sr:=sr1;
    end;

      VBox^.List^.Insert(NewStr(s));
      VBox^.SetRange(VBox^.List^.Count);

   if j= TempBox^.List^.Count-1 then
    begin
      if VBox^.List^.Count>0 then
       begin
       for ii:=0 to VBox^.List^.Count-1 do
        begin
         ss:='';
         ss:=VBox^.GetText(ii,VBox^.List^.Count);
         writeln(txt,{intToStr(ii,CKod),}ss);
        end;
       VBox^.NewList(Nil);
       VBOx^.NewList(New(PTextCollection, Init(0,1)));
      end;
    end;
  end;
 Writeln(txt,
'---------------------------------------------------------------------------------------------------'+
'-------------------------------------------');
Writeln(txt,'Всего:                                                     Ост.н: ',Sum_O,' Прих.:',SumP,
  '  Опт.:',SumPO,' Розн.:',SumPR,' Ост.к:',Sumz);
Writeln(txt,'                                                                 '+
     '                                                Прод. розн. закуп.:',SumPRZ);

NoInFoMsg;

 Dispose(P,Done);
 Dispose(VBox,Done);
 Dispose(TempBox,Done);
 Close(Txt);
 ViewAsText(Path^.Dat.ToTemp+'buxotch.txt','Отчет для бухгалтерии',True);
{ Report(Path^.Dat.ToTemp+'person.txt','',1,False,False);}

End;

{$ELSE}


procedure PrihAddToList(Const E:PPrihodType);

var
  sKol: string[CKOL];
  ssumma: string[CIZena];
  Artikul: string[CArtikul];
  sZena: string[CIZena];
  sName1,sName: string[CName];
  find:boolean;
  i,j:word;
  st,st1,ss:string;
Begin
DInfoMsg('Просматриваю приходы за '+DateToDateString(DateMask,DEn),False);
For i:=1 to E^.Dat.Amount do
 begin
  If TempBox^.List^.Count-1>=0 Then
   begin
    find:=false;
    for j:=0 to TempBox^.List^.Count-1 do
      begin
       st1[0]:=#0;
       st1:=Copy(TempBox^.GetText(j,TempBox^.List^.Count),1,CArtikul);
       format(st1,CArtikul);
       Artikul:=E^.Dat.PrihodElement[i].BazKod;
       {sName1:=GetIdField(FName,st1);
       sName:=GetIdField(FName,E^.Dat.PrihodElement[i].BazKod);}
       format(Artikul,CArtikul);
       if st1=Artikul{sName1=sName} then
        begin
          find:=true;
          st[0]:=#0; ss:='';
          st:=TempBox^.GetText(j,TempBox^.List^.Count);
          sKol:=Copy(TempBox^.GetText(j,TempBox^.List^.Count),1+CArtikul+CIZena+CKol,CKol);
          sKol:=IntToStr(StrToInt(E^.Dat.PrihodElement[i].Input.Kol)+StrToInt(sKol),CKol);
          rformat(sKol,CKol);
          ss:=ss+sKol;
          SZena:='';
          sZena:=E^.Dat.PrihodElement[i].Input.Zakupka;
         { Writeln(Artikul,' ',sZena,' ',E^.Dat.PrihodElement[i].Input.Zakupka);}
          sSumma:=Copy(TempBox^.GetText(j,TempBox^.List^.Count),1+CArtikul+CIZena+CKol+CKol,CIZena);
         { Writeln(Artikul,' ',sZena);
          readln; }
          MyStr(StrToReal(sSumma)+StrToReal(sZena)*StrToReal(E^.Dat.PrihodElement[i].Input.Kol),CIZena,CMantissaZ,sSumma);
          rformat(sSumma,CIZena);
          ss:=ss+sSumma;
          System.Delete(st,1+CArtikul+CIZena+CKol,CKol+CIZena);
          System.Insert(ss,st,1+CArtikul+CIZena+CKol);
          TempBox^.List^.AtFree(j);
          TempBox^.SetRange(TempBox^.List^.Count);

          TempBox^.List^.Insert(NewStr(st));
          TempBox^.SetRange(TempBox^.List^.Count);

        end;
      end;
    if not find then
      begin
        st[0]:=#0;
        Artikul:=E^.Dat.PrihodElement[i].BazKod;
        st:=Artikul;
        sKol:='0';
        sSumma:='0.00';
        rformat(sKol,CKol);
        rformat(sSumma,CIZena);
        st:=st+sKol+sSumma;
        sZena:=E^.Dat.PrihodElement[i].Input.Zakupka;
        rformat(sZena,CIZena);
        sKol:=E^.Dat.PrihodElement[i].Input.Kol;
        rformat(skol,CKol);
        st:=st+sKol;
        MyStr(StrToReal(sKol)*StrToReal(sZena),CIZena,CMantissaZ,sSumma);
        rformat(sSumma,CIZena);
        st:=st+sSumma;
        sKol:='0';
        sSumma:='0.00';
        rformat(sKol,CKol);
        rformat(sSumma,CIZena);
        st:=st+sKol+sSumma;
        st:=st+sKol+sSumma;
        st:=st+sKol+sSumma;
        st:=st+sKol+sSumma;
        st:=st+sKol;
        TempBox^.List^.Insert(NewStr(st));
      end;
   end;

 end;

 NoinfoMsg;
End;

procedure MarkRoznAddToList(Const E:PSuperMarketType);
var
  Artikul: string[CArtikul];
  sZena: string[CIZena];
  sSumma: string[CIZena];
  sName,sName1: string[CName];
  sKol: string[CKOL];
  news,st,st1,st2,ss: string;
  find:boolean;
  i,j,Pos:word;
Begin
DInfoMsg('Просматриваю розн.продажи за '+DateToDateString(DateMask,DEn),False);

For i:=1 to E^.Dat.Amount  do
begin
 {if E^.Dat.Pos[i].Artikul = '' then break;}
    find:=false;
    If Not TestElement(E^.Dat.MarketElement[i].BazKod,TempBox) Then
     Begin
      Pos:=Location(TempBox,E^.Dat.MarketElement[i].BazKod,True);
      News:=TempBox^.GetText(Pos,TempBox^.List^.Count);
      st1[0]:=#0;
      st1:=Copy(news,1,CArtikul);
      Artikul:=E^.Dat.MarketElement[i].BazKod;
      format(Artikul,CArtikul);
      find:=true;

         st[0]:=#0; ss:='';
         {st:=Copy(NewS,1,CArtikul+CIZena+CKol+CIZena+CKol+CIZena+CKol);}
         st2:=Copy(NewS,1+CArtikul+CIZena+CKol+CIZena+CKol+CIZena+CKol,CKol);
    { if Artikul='01077' then
      begin
         writeln(st2,' ',E^.Dat.MarketElement[i].Input.Kol);
         readln;
      end; }
         sKol:=IntToStr(StrToInt(E^.Dat.MarketElement[i].Input.Kol)+StrToInt(st2),CKol);
         rformat(sKol,CKol);
         ss:=ss+sKol;
         sSumma:=Copy(News,1+CArtikul+CIZena+CKol+CIZena+CKol+CKol+CIZena+CKol,CIZena);
         {sZena:=E.Pos[i].Zena;}

{$IFNDEF BAKALEYA}
    MyStr(StrToReal(sSumma)+StrToReal((E^.Dat.MarketElement[i].Input.Zakupka))*StrToReal(E^.Dat.MarketElement[i].Input.Kol),
	            CIZena,CMantissaZ,sSumma);
{$ELSE}
    MyStr(StrToReal(sSumma)+(StrToReal(E^.Dat.MarketElement[i].Input.Zakupka)+0.2)
      *StrToReal(E^.Dat.MarketElement[i].Input.Kol),CIZena,CMantissaZ,sSumma);
{$ENDIF}


         rformat(sSumma,CIZena);
         ss:=ss+sSumma;

         System.Delete(news,1+CArtikul+CIZena+CKol+CIZena+CKol+CIZena+CKol,CKol+CIZena);
         System.Insert(ss,news,1+CArtikul+CIZena+CKol+CIZena+CKol+CIZena+CKol);

      TempBox^.List^.AtFree(Pos);
      TempBox^.SetRange(TempBox^.List^.Count);

      TempBox^.List^.Insert(NewStr(news));
      TempBox^.SetRange(TempBox^.List^.Count);
     End
    Else
     Begin
      Find:=True;
      st[0]:=#0;
      Artikul:=E^.Dat.MarketElement[i].BazKod;
      format(Artikul,CArtikul);
      st:=st+Artikul;
      sKol:='0';
      sSumma:='0.00';
      rformat(sKol,CKol);
      rformat(sSumma,CIZena);
      st:=st+sKol+sSumma+Skol+SSumma+Skol+SSumma;

{$IFNDEF BAKALEYA}
      sZena:=E^.Dat.MarketElement[i].Input.Zakupka;
{$ELSE}
      MyStr(StrToREal(E^.Dat.MarketElement[i].Input.Zakupka)+0.2,CIZena,CMantissaZ,sZena);
{$ENDIF}

      rformat(sZena,CIZena);
      sKol:=E^.Dat.MarketElement[i].Input.Kol;
      rformat(skol,CKol);
      st:=st+sKol;
      MyStr(StrToReal(sKol)*StrToReal(sZena),CIZena,CMantissaZ,sSumma);
      rFormat(sSumma,CIZena);
      st:=st+sSumma;
      sKol:='0';
      sSumma:='0.00';
      rformat(sKol,CKol);
      rformat(sSumma,CIZena);
      st:=st+sKol+sSumma;
      st:=st+sKol+sSumma;
      st:=st+sKol;
      {st:=st+sKol+sSumma;}
      TempBox^.List^.Insert(NewStr(st));
      TempBox^.SetRange(TempBox^.List^.Count);
     End;
end;{for i}
NoInfoMsg;
End;


procedure MarkOptAddToList(Const E:PSuperMarketType);
var
  Artikul: string[CArtikul];
  sZena: string[CIZena];
  sSumma: string[CIZena];
  sName,sName1: string[CName];
  sKol: string[CKOL];
  news,st,st1,st2,ss,ws,koefficient: string;
  find:boolean;
  i,j,Pos:word;
Begin
DInfoMsg('Просматриваю опт.продажи за '+DateToDateString(DateMask,DEn),False);
For i:=1 to E^.Dat.Amount do
begin


    find:=false;
    If Not TestElement(E^.Dat.MarketElement[i].BazKod,TempBox) Then
     Begin
      Pos:=Location(TempBox,E^.Dat.MarketElement[i].BazKod,True);
      News:=TempBox^.GetText(Pos,TempBox^.List^.Count);
      st1[0]:=#0;ss:='';
      st1:=Copy(news,1,CArtikul);
      Artikul:=E^.Dat.MarketElement[i].BazKod;
      format(Artikul,CArtikul);
      find:=true;
      {st:=Copy(News,1,CArtikul+CIZena+CKol+CIZena+CKol);}
      st2:=Copy(News,1+CArtikul+CIZena+CKol+CIZena+CKol,CKol);
      sKol:=IntToStr(StrToInt(E^.Dat.MarketElement[i].Input.Kol)+StrToInt(st2),CKol);
      rformat(sKol,CKol);
      ss:=ss+sKol;
      sSumma:=Copy(News,1+CArtikul+CIZena+CKol+CIZena+CKol+CKol,CIZena);


      ws:='';
      If E^.Dat.SkidkaSelector=0 Then{Если автомат}
      begin
       DelSpace(E^.Dat.MarketElement[i].Input.Proz);

       MyStr((StrToReal(E^.Dat.MarketElement[i].Input.Zena)/
       (1+StrToReal(E^.Dat.MarketElement[i].Input.Proz)/100)),CIZena,CMantissaZ,ws);

       If E^.DAt.DocSelector in [1,2,3,5,6] Then
       Begin
       Mystr(((1+strtoreal(e^.dat.marketelement[i].Input.SpecNalog)
              /100)),CLitr,CMantissaZ,koefficient);

       {новая цена}

       MyStr(StrToReal(ws){*StrToReal(Koefficient)},CIZena,CMantissaZ,ws);
       End;
      end
      Else
       Begin
       MyStr((StrToReal(E^.Dat.MarketElement[i].Input.Zena)-StrToReal(E^.Dat.MarketElement[i].Input.Skidka))
       ,CIZena,CMantissaZ,ws);


       If E^.DAt.DocSelector in [1,2,3,5,6] Then
       Begin
       Mystr(((1+strtoreal(e^.dat.marketelement[i].Input.SpecNalog)
              /100)),CLitr,CMantissaZ,koefficient);

       {новая цена}
       MyStr(StrToReal(ws){*/StrToReal(Koefficient)},CIZena,CMantissaZ,ws);
       End;
      End;


       MyStr(StrToReal(sSumma)+StrToReal(ws)
	   *StrToReal(E^.Dat.MarketElement[i].Input.Kol),
	        CIZena,CMantissaZ,sSumma);


      rformat(sSumma,CIZena);
      ss:=ss+sSumma;
      System.Delete(news,1+CArtikul+CIZena+CKol+CIZena+CKol,CKol+CIZena);
      System.Insert(ss,news,1+CArtikul+CIZena+CKol+CIZena+CKol);

      TempBox^.List^.AtFree(Pos);
      TempBox^.SetRange(TempBox^.List^.Count);

      TempBox^.List^.Insert(NewStr(news));
      TempBox^.SetRange(TempBox^.List^.Count);
     End
    Else
     Begin
      st[0]:=#0;
      Artikul:=E^.Dat.MarketElement[i].BazKod;
      format(Artikul,CArtikul);
      st:=st+Artikul;
      sKol:='0';
      sSumma:='0.00';
      rformat(sKol,CKol);
      rformat(sSumma,CIZena);
      st:=st+sKol+sSumma+Skol+SSumma;


     (* sZena:=E^.Dat.MarketElement[i].Input.R_Zena{Zakupka}; *)

      ws:='';
      If E^.Dat.SkidkaSelector=0 Then{Если автомат}
      begin
       DelSpace(E^.Dat.MarketElement[i].Input.Proz);

       MyStr((StrToReal(E^.Dat.MarketElement[i].Input.Zena)/
       (1+StrToReal(E^.Dat.MarketElement[i].Input.Proz)/100)),CIZena,CMantissaZ,ws);

       If E^.DAt.DocSelector in [1,2,3,5,6] Then
       Begin
       Mystr(((1+strtoreal(e^.dat.marketelement[i].Input.SpecNalog)
              /100)),CLitr,CMantissaZ,koefficient);

       {новая цена}

       MyStr(StrToReal(ws){*StrToReal(Koefficient)},CIZena,CMantissaZ,ws);
       End;
      end
      Else
       Begin
{       ItogoSkidka:=ItogoSkidka+StrToReal(E^.Dat.MarketElement[i].Input.Skidka)*StrToInt(E^.Dat.MarketElement[i].Input.Kol);
       {сумма скидки}
       MyStr((StrToReal(E^.Dat.MarketElement[i].Input.Zena)-StrToReal(E^.Dat.MarketElement[i].Input.Skidka))
       ,CIZena,CMantissaZ,ws);


       If E^.DAt.DocSelector in [1,2,3,5,6] Then
       Begin
       Mystr(((1+strtoreal(e^.dat.marketelement[i].Input.SpecNalog)
              /100)),CLitr,CMantissaZ,koefficient);

       {новая цена}
       MyStr(StrToReal(ws){*/StrToReal(Koefficient)},CIZena,CMantissaZ,ws);
       End;
      End;


      sZena:=ws;

      rformat(sZena,CIZena);
      {writeln(sZena);
      readln;}
      sKol:=E^.Dat.MarketElement[i].Input.Kol;
      rformat(skol,CKol);
      st:=st+sKol;
      MyStr(StrToReal(sKol)*StrToReal(sZena),CIZena,CMantissaZ,sSumma);
      rFormat(sSumma,CIZena);
      st:=st+sSumma;
      sKol:='0';
      sSumma:='0.00';
      rformat(sKol,CKol);
      rformat(sSumma,CIZena);
      st:=st+sKol+sSumma;
      st:=st+sKol+sSumma;
      st:=st+sKol+sSumma;
      st:=st+sKol;

      TempBox^.List^.Insert(NewStr(st));
      TempBox^.SetRange(TempBox^.List^.Count);
      Find:=True
     End;

end;{for i}
NoInfoMsg;
End;

procedure MarkVozwratAddToList(Const E:PNewVozwratType);
Var
  Artikul: string[CArtikul];
  sZena: string[CIZena];
  sSumma: string[CIZena];
  sName,sName1: string[CName];
  sKol: string[CKOL];
  news,st,st1,st2,ss,sst1: string;
  find:boolean;
  i,j,Pos:word;
Begin
DInfoMsg('Просматриваю розн.возвраты за '+DateToDateString(DateMask,DEn),False);
For i:=1 to E^.Dat.Amount do
begin


    find:=false;
    If Not TestElement(E^.Dat.VozwratElement[i].BazKod,TempBox) Then
     Begin
      Pos:=Location(TempBox,E^.Dat.VozwratElement[i].BazKod,True);
      News[0]:=#0;
      News:=TempBox^.GetText(Pos,TempBox^.List^.Count);
      st1[0]:=#0;ss:='';
      st1:=Copy(news,1,CArtikul);
      Artikul:=E^.Dat.VozwratElement[i].BazKod;
      format(Artikul,CArtikul);
      find:=true;
      st2:=Copy(News,1+CArtikul+CIZena+CKol+CIZena+CKol+CIZena+CKol+CIZena+CKol,CKol);
      sKol:=IntToStr(StrToInt(E^.Dat.VozwratElement[i].Input.Kol)+StrToInt(st2),CKol);
      rformat(sKol,CKol);
      ss:=ss+sKol;
      sSumma:=Copy(News,1+CArtikul+CIZena+CKol+CIZena+CKol+CIZena+CKol+CIZena+CKol+CKol,CIZena);
            sst1:=E^.Dat.VozwratElement[i].Input.Zakupka;
        format(sst1,CIZena);

      MyStr(StrToReal(sSumma)+StrToReal(sst1)*StrToReal(E^.Dat.VozwratElement[i].Input.Kol),
	        CIZena,CMantissaZ,sSumma);

      rformat(sSumma,CIZena);
      ss:=ss+sSumma;
      System.Delete(news,1+CArtikul+CIZena+CKol+CIZena+CKol+CIZena+CKol+CIZena+CKol,CKol+CIZena);
      System.Insert(ss,news,1+CArtikul+CIZena+CKol+CIZena+CKol+CIZena+CKol+CIZena+CKol);
      sKol:='0';
      sSumma:='0.00';
      rformat(sKol,CKol);
      rformat(sSumma,CIZena);
      st:=st+sKol+sSumma;

      TempBox^.List^.AtFree(Pos);
      TempBox^.SetRange(TempBox^.List^.Count);

      TempBox^.List^.Insert(NewStr(news));
      TempBox^.SetRange(TempBox^.List^.Count);
     End
    Else
     Begin
      st[0]:=#0;
      Artikul:=E^.Dat.VozwratElement[i].BazKod;
      format(Artikul,CArtikul);
      st:=st+Artikul;
      sKol:='0';
      sSumma:='0.00';
      rformat(sKol,CKol);
      rformat(sSumma,CIZena);
      st:=st+sKol+sSumma+Skol+SSumma+sKol+sSumma+Skol+SSumma;

            sst1:=E^.Dat.VozwratElement[i].Input.Zakupka;
        format(sst1,CIZena);

      sZena:=sst1;

      rformat(sZena,CIZena);
      sKol:=E^.Dat.VozwratElement[i].Input.Kol;
      rformat(skol,CKol);
      st:=st+sKol;
      MyStr(StrToReal(sKol)*StrToReal(sZena),CIZena,CMantissaZ,sSumma);
      rFormat(sSumma,CIZena);
      st:=st+sSumma;
      sKol:='0';
      sSumma:='0.00';
      rformat(sKol,CKol);
      rformat(sSumma,CIZena);
      st:=st+sKol+sSumma;
      st:=st+sKol;

      TempBox^.List^.Insert(NewStr(st));
      TempBox^.SetRange(TempBox^.List^.Count);
      Find:=True
     End;

end;{for i}
NoInfoMsg;

End;

procedure MarkOPtVozwratAddToList(Const E:PNewVozwratType);
Var
  Artikul: string[CArtikul];
  sZena: string[CIZena];
  sSumma: string[CIZena];
  sName,sName1: string[CName];
  sKol: string[CKOL];
  news,st,st1,st2,ss,sst1,ws,koefficient: string;
  find:boolean;
  i,j,Pos:word;
Begin
DInfoMsg('Просматриваю опт.возвраты за '+DateToDateString(DateMask,DEn),False);
{memc('1');}
For i:=1 to E^.Dat.Amount do
begin


    find:=false;
    If Not TestElement(E^.Dat.VozwratElement[i].BazKod,TempBox) Then
     Begin
      Pos:=Location(TempBox,E^.Dat.VozwratElement[i].BazKod,True);
      News[0]:=#0;
      News:=TempBox^.GetText(Pos,TempBox^.List^.Count);
      st1[0]:=#0;ss:='';
      st1:=Copy(news,1,CArtikul);
      Artikul:=E^.Dat.VozwratElement[i].BazKod;
      format(Artikul,CArtikul);
      find:=true;
      st2:=Copy(News,1+CArtikul+CIZena+CKol+CIZena+CKol+CIZena+CKol+CIZena+CKol+CIZena+CKol,CKol);
      sKol:=IntToStr(StrToInt(E^.Dat.VozwratElement[i].Input.Kol)+StrToInt(st2),CKol);
      rformat(sKol,CKol);
      ss:=ss+sKol;
      sSumma:=Copy(News,1+CArtikul+CIZena+CKol+CIZena+CKol+CIZena+CKol+CIZena+CKol+CIZena+CKol+CKol,CIZena);
        j:=i;
         begin
           begin
      ws:='';
      If E^.Dat.VidDocument in [0,2,4] Then{Если автомат}
      begin
       DelSpace(E^.Dat.VozwratElement[j].Input.LocalProz);

       MyStr((StrToReal(E^.Dat.VozwratElement[j].Input.Zena)/
       (1+StrToReal(E^.Dat.VozwratElement[j].Input.LOcalProz)/100)),CIZena,CMantissaZ,ws);

       Begin
       MyStr(StrToReal(ws),CIZena,CMantissaZ,ws);
       End;
      end
      Else
       Begin
{       ItogoSkidka:=ItogoSkidka+StrToReal(EE^.Dat.MarketElement[j].Input.Skidka)*StrToInt(EE^.Dat.MarketElement[j].Input.Kol);
       {сумма скидки}
       MyStr((StrToReal(E^.Dat.VozwratElement[j].Input.Zena)-StrToReal(E^.Dat.VozwratElement[j].Input.LOcalSkidka))
       ,CIZena,CMantissaZ,ws);


       If E^.DAt.DocSelector in [1,2,3,5,6] Then
       Begin
       (*Mystr(((1+strtoreal(ee^.dat.marketelement[j].Input.SpecNalog)
              /100)),CLitr,CMantissaZ,koefficient); *)

       {новая цена}
       MyStr(StrToReal(ws){*/StrToReal(Koefficient)},CIZena,CMantissaZ,ws);
       End;
      End;


            {writeln(EE^.Dat.MarketElement[j].Input.Zakupka);
            readln; }
            sst1:=ws;
            {break;}
           end;
         end;

        format(sst1,CIZena);

      MyStr(StrToReal(sSumma)+StrToReal(sst1)*StrToReal(E^.Dat.VozwratElement[i].Input.Kol),
	        CIZena,CMantissaZ,sSumma);

      rformat(sSumma,CIZena);
      ss:=ss+sSumma;
      System.Delete(news,1+CArtikul+CIZena+CKol+CIZena+CKol+CIZena+CKol+CIZena+CKol+CIZena+CKol,CKol+CIZena);
      System.Insert(ss,news,1+CArtikul+CIZena+CKol+CIZena+CKol+CIZena+CKol+CIZena+CKol+CIZena+CKol);

      TempBox^.List^.AtFree(Pos);
      TempBox^.SetRange(TempBox^.List^.Count);

      TempBox^.List^.Insert(NewStr(news));
      TempBox^.SetRange(TempBox^.List^.Count);
     End
    Else
     Begin
      st[0]:=#0;
      Artikul:=E^.Dat.VozwratElement[i].BazKod;
      format(Artikul,CArtikul);
      st:=st+Artikul;
      sKol:='0';
      sSumma:='0.00';
      rformat(sKol,CKol);
      rformat(sSumma,CIZena);
      st:=st+sKol+sSumma+Skol+SSumma+sKol+sSumma+Skol+SSumma+Skol+SSumma;

        j:=i;
         begin
           begin
            ws:='';
      If E^.Dat.VidDocument in [0,2,4] Then{Если автомат}
      begin
       DelSpace(E^.Dat.VozwratElement[j].Input.LocalProz);

       MyStr((StrToReal(E^.Dat.VozwratElement[j].Input.Zena)/
       (1+StrToReal(E^.Dat.VozwratElement[j].Input.LocalProz)/100)),CIZena,CMantissaZ,ws);

       If E^.DAt.DocSelector in [1,2,3,5,6] Then
       Begin
       MyStr(StrToReal(ws),CIZena,CMantissaZ,ws);
       End;
      end
      Else
       Begin
       MyStr((StrToReal(E^.Dat.VozwratElement[j].Input.Zena)-StrToReal(E^.Dat.VozwratElement[j].Input.LOcalSkidka))
       ,CIZena,CMantissaZ,ws);


       If E^.DAt.DocSelector in [1,2,3,5,6] Then
       Begin
       MyStr(StrToReal(ws),CIZena,CMantissaZ,ws);
       End;
      End;
            sst1:=ws;
            {break;}
           end;
         end;

        format(sst1,CIZena);

      sZena:=sst1;

      rformat(sZena,CIZena);
      sKol:=E^.Dat.VozwratElement[i].Input.Kol;
      rformat(skol,CKol);
      MyStr(StrToReal(sKol)*StrToReal(sZena),CIZena,CMantissaZ,sSumma);
      rFormat(sSumma,CIZena);
      st:=st+sKol+sSumma;
      sKOl:='0';
      rformat(sKOl,CKOl);
      st:=st+sKol;
      TempBox^.List^.Insert(NewStr(st));
      TempBox^.SetRange(TempBox^.List^.Count);
      Find:=True
     End;

end;{for i}
NoInfoMsg;

End;

procedure PrihSkladAddToList(Const E:PPrihodType);

var
  sKol: string[CKOL];
  ssumma: string[CIZena];
  Artikul: string[CArtikul];
  sZena: string[CIZena];
  sName1,sName: string[CName];
  find:boolean;
  i,j:word;
  st,st1,ss:string;
Begin

DInfoMsg('Просматриваю складские приходы за '+DateToDateString(DateMask,DEn),False);
For i:=1 to E^.Dat.Amount do
 begin
  If TempBox^.List^.Count-1>=0 Then
   begin
    find:=false;
    for j:=0 to TempBox^.List^.Count-1 do
      begin

       st1[0]:=#0;
       st1:=Copy(TempBox^.GetText(j,TempBox^.List^.Count),1,CArtikul);
       format(st1,CArtikul);
       Artikul:=E^.Dat.PrihodElement[i].BazKod;
       {sName1:=GetIdField(FName,st1);
       sName:=GetIdField(FName,E^.Dat.PrihodElement[i].BazKod);}
       format(Artikul,CArtikul);
       if st1=Artikul{sName1=sName} then
        begin
          find:=true;
          st[0]:=#0; ss:='';
          st:=TempBox^.GetText(j,TempBox^.List^.Count);
          sKol:=Copy(TempBox^.GetText(j,TempBox^.List^.Count),1+CArtikul+CIZena+CKol+CIZena+CKol+CIZena+CKol+CIZena+CKol+CIZena
		  +CKol+CIZena,CKol);
          sKol:=IntToStr(StrToInt(E^.Dat.PrihodElement[i].Input.Kol)+StrToInt(sKol),CKol);
          rformat(sKol,CKol);
          ss:=ss+sKol;
          System.Delete(st,1+CArtikul+CIZena+CKol+CKol+CIZena+CKol+CIZena+CKol+CIZena+CKol+CIZena+CKol+CIZena,CKol);
          System.Insert(ss,st,1+CArtikul+CIZena+CKol+CKol+CIZena+CKol+CIZena+CKol+CIZena+CKol+CIZena+CKol+CIZena);

          TempBox^.List^.AtFree(j);
          TempBox^.SetRange(TempBox^.List^.Count);

          TempBox^.List^.Insert(NewStr(st));
          TempBox^.SetRange(TempBox^.List^.Count);

        end;
      end;
    if not find then
      begin
       { memc; }
        st[0]:=#0;
        Artikul:=E^.Dat.PrihodElement[i].BazKod;
        st:=Artikul;
        sKol:='0';
        sSumma:='0.00';
        rformat(sKol,CKol);
        rformat(sSumma,CIZena);
        st:=st+sKol+sSumma;
        st:=st+sKol+sSumma;
        st:=st+sKol+sSumma;
        st:=st+sKol+sSumma;
        st:=st+sKol+sSumma;
        st:=st+sKol+sSumma;

        sKol:=E^.Dat.PrihodElement[i].Input.Kol;
        rformat(skol,CKol);
        st:=st+sKol;
        TempBox^.List^.Insert(NewStr(st));
      end;
   end;

 end;

 NoinfoMsg;
End;

procedure MarkSkladAddToList(Const E:PSuperMarketType);

var
  sKol: string[CKOL];
  ssumma: string[CIZena];
  Artikul: string[CArtikul];
  sZena: string[CIZena];
  sName1,sName: string[CName];
  find:boolean;
  i,j:word;
  st,st1,ss:string;
Begin

DInfoMsg('Просматриваю складские отгрузки за '+DateToDateString(DateMask,DEn),False);
For i:=1 to E^.Dat.Amount do
 begin
  If TempBox^.List^.Count-1>=0 Then
   begin
    find:=false;
    for j:=0 to TempBox^.List^.Count-1 do
      begin

       st1[0]:=#0;
       st1:=Copy(TempBox^.GetText(j,TempBox^.List^.Count),1,CArtikul);
       format(st1,CArtikul);
       Artikul:=E^.Dat.MarketElement[i].BazKod;

       format(Artikul,CArtikul);
       if st1=Artikul{sName1=sName} then
        begin
          find:=true;
          st[0]:=#0; ss:='';
          st:=TempBox^.GetText(j,TempBox^.List^.Count);
          sKol:=Copy(TempBox^.GetText(j,TempBox^.List^.Count),1+CArtikul+CIZena+CKol+CIZena+CKol+CIZena+CKol+CIZena+CKol+CIZena
		  +CKol+CIZena+CKOL,CKol);
          {writeln(sKOl);}
          sKol:=IntToStr(-StrToInt(E^.Dat.MarketElement[i].Input.Kol)+StrToInt(sKol),CKol);
          rformat(sKol,CKol);
          ss:=ss+sKol;
          System.Delete(st,1+CArtikul+CIZena+CKol+CKol+CIZena+CKol+CIZena+CKol+CIZena+CKol+CIZena+CKol+CIZena,CKol);
          System.Insert(ss,st,1+CArtikul+CIZena+CKol+CKol+CIZena+CKol+CIZena+CKol+CIZena+CKol+CIZena+CKol+CIZena);

          TempBox^.List^.AtFree(j);
          TempBox^.SetRange(TempBox^.List^.Count);

          TempBox^.List^.Insert(NewStr(st));
          TempBox^.SetRange(TempBox^.List^.Count);

        end;
      end;
    if not find then
      begin
       { memc; }
        st[0]:=#0;
        Artikul:=E^.Dat.MarketElement[i].BazKod;
        st:=Artikul;
        sKol:='0';
        sSumma:='0.00';
        rformat(sKol,CKol);
        rformat(sSumma,CIZena);
        st:=st+sKol+sSumma;
        st:=st+sKol+sSumma;
        st:=st+sKol+sSumma;
        st:=st+sKol+sSumma;
        st:=st+sKol+sSumma;
        st:=st+sKol+sSumma;

       { sZena:=E^.Dat.PrihodElement[i].Input.Zakupka;
        rformat(sZena,CIZena);}

        sKol:=E^.Dat.MarketElement[i].Input.Kol;
        sKol:=IntToStr(-StrToInt(E^.Dat.MarketElement[i].Input.Kol),CKol);
        rformat(skol,CKol);

        st:=st+sKol;
        {MyStr(StrToReal(sKol)*StrToReal(sZena),CIZena,CMantissa,sSumma);
        rformat(sSumma,CIZena);
        st:=st+sSumma;}
       { writeln(st);
        readln; }
        TempBox^.List^.Insert(NewStr(st));
      end;
   end;

 end;

 NoinfoMsg;
End;

procedure MarkRewisiaAddToList(Const E:PRewisiaType);

var
  sKol: string[CKOL];
  ssumma: string[CIZena];
  Artikul: string[CArtikul];
  sZena: string[CIZena];
  sName1,sName: string[CName];
  find:boolean;
  i,j:word;
  st,st1,ss:string;
Begin

DInfoMsg('Просматриваю ревизии за '+DateToDateString(DateMask,DEn),False);
For i:=1 to E^.Dat.Amount do
 begin
  If TempBox^.List^.Count-1>=0 Then
   begin
    find:=false;
    for j:=0 to TempBox^.List^.Count-1 do
      begin

       st1[0]:=#0;
       st1:=Copy(TempBox^.GetText(j,TempBox^.List^.Count),1,CArtikul);
       format(st1,CArtikul);
       Artikul:=E^.Dat.Element[i].BazKod;
       format(Artikul,CArtikul);
       if st1=Artikul then
        begin
          find:=true;
          st[0]:=#0; ss:='';
          st:=TempBox^.GetText(j,TempBox^.List^.Count);

       If StrToReal(E^.Dat.Element[i].Input.Kol)>0 then
          Begin
           {ПРиходы по закупке}
            Skol:=Copy(TempBox^.GetText(j,TempBox^.List^.Count),1+CArtikul+CIZena+CKol,CKOl);
            sKOl:=IntToStr(StrToInt(sKOl)+StrToInt(E^.Dat.Element[i].Input.Kol),Ckol);
            sSumma:=Copy(TempBox^.GetText(j,TempBox^.List^.Count),1+CArtikul+CIZena+CKol+Ckol,CIZena);
            Str(StrToReal(sSumma)+StrToInt(E^.Dat.Element[i].Input.Kol)*StrToReal(E^.Dat.Element[i].Input.Zakupka)
              :CIZena:CMantissaZ,sSumma);
            rformat(sKol,CKol);
            rFormat(sSumma,CIZena);
            ss:=ss+sKol+SSumma;
            System.Delete(st,1+CArtikul+CIZena+CKol,CKOl+CIZena);
            System.Insert(ss,st,1+CArtikul+CIZena+CKol);
          End
       else
          begin
           {ОПТ по закупке*1.03}
            Skol:=Copy(TempBox^.GetText(j,TempBox^.List^.Count),1+CArtikul+CIZena+CKol+CIZena+CKol,CKOl);
            sKOl:=IntToStr(StrToInt(sKOl)-StrToInt(E^.Dat.Element[i].Input.Kol),Ckol);
            sSumma:=Copy(TempBox^.GetText(j,TempBox^.List^.Count),1+CArtikul+CIZena+CKol+Ckol+CIZena+CKol,CIZena);
            Str(StrToReal(sSumma)-StrToInt(E^.Dat.Element[i].Input.Kol)*StrToReal(E^.Dat.Element[i].Input.Zakupka)*1.03
              :CIZena:CMantissaZ,sSumma);
            rformat(sKol,CKol);
            rFormat(sSumma,CIZena);
            ss:=ss+sKol+SSumma;
            System.Delete(st,1+CArtikul+CIZena+CKol+CIZena+CKol,CKOl+CIZena);
            System.Insert(ss,st,1+CArtikul+CIZena+CKol+CIZena+CKol);
          end;

          TempBox^.List^.AtFree(j);
          TempBox^.SetRange(TempBox^.List^.Count);

          TempBox^.List^.Insert(NewStr(st));
          TempBox^.SetRange(TempBox^.List^.Count);

        end;
      end;
    if not find then
      begin
        st[0]:=#0;
        if StrToInt(E^.Dat.Element[i].Input.Kol)>0 then
          begin
           Artikul:=E^.Dat.Element[i].BazKod;
           st:=Artikul;
           sKol:='0';
           sSumma:='0.00';
           rformat(sKol,CKol);
           rformat(sSumma,CIZena);
           st:=st+sKol+sSumma;
           sZena:=E^.Dat.Element[i].Input.Zakupka;
           rformat(sZena,CIZena);
           sKol:=E^.Dat.Element[i].Input.Kol;
           rformat(skol,CKol);
           st:=st+sKol;
           MyStr(StrToReal(sKol)*StrToReal(sZena),CIZena,CMantissaZ,sSumma);
           rformat(sSumma,CIZena);
           st:=st+sSumma;
           sKol:='0';
           sSumma:='0.00';
           rformat(sKol,CKol);
           rformat(sSumma,CIZena);
           st:=st+sKol+sSumma;
           st:=st+sKol+sSumma;
           st:=st+sKol+sSumma;
           st:=st+sKol+sSumma;
           st:=st+sKol;
          end
        else
          begin
           st[0]:=#0;
           Artikul:=E^.Dat.Element[i].BazKod;
           format(Artikul,CArtikul);
           st:=st+Artikul;
           sKol:='0';
           sSumma:='0.00';
           rformat(sKol,CKol);
           rformat(sSumma,CIZena);
           st:=st+sKol+sSumma+Skol+SSumma;
           sZena:=E^.Dat.Element[i].Input.Zakupka;
           rformat(sZena,CIZena);
           sKol:=IntToStr(-StrToInt(E^.Dat.Element[i].Input.Kol),CKol);
           rformat(skol,CKol);
           st:=st+sKol;
           MyStr(StrToReal(sKol)*StrToReal(sZena)*1.03,CIZena,CMantissaZ,sSumma);
           rFormat(sSumma,CIZena);
           st:=st+sSumma;
           sKol:='0';
           sSumma:='0.00';
           rformat(sKol,CKol);
           rformat(sSumma,CIZena);
           st:=st+sKol+sSumma;
           st:=st+sKol+sSumma;
           st:=st+sKol+sSumma;
           st:=st+sKol;
          end;

        TempBox^.List^.Insert(NewStr(st));
        TempBox^.SetRange(TempBox^.List^.Count);
      end;
   end;

 end;

 NoinfoMsg;
End;



procedure RPAddToList(Const E:PSuperMarketType);

var
  sKol: string[CKOL];
  ssumma: string[CIZena];
  Artikul: string[CArtikul];
  sZena: string[CIZena];
  sName1,sName: string[CName];
  find:boolean;
  i,j:word;
  st,st1,ss:string;
Begin

DInfoMsg('Просматриваю Р/П за '+DateToDateString(DateMask,DEn),False);
For i:=1 to E^.Dat.Amount do
 begin
  If TempBox^.List^.Count-1>=0 Then
   begin
    find:=false;
    for j:=0 to TempBox^.List^.Count-1 do
      begin

       st1[0]:=#0;
       st1:=Copy(TempBox^.GetText(j,TempBox^.List^.Count),1,CArtikul);
       format(st1,CArtikul);
       Artikul:=E^.Dat.MarketElement[i].BazKod;
       format(Artikul,CArtikul);
       if st1=Artikul then
        begin
          find:=true;
          st[0]:=#0; ss:='';
          st:=TempBox^.GetText(j,TempBox^.List^.Count);

      {ОПТ по закупке*1.03}
            Skol:=Copy(TempBox^.GetText(j,TempBox^.List^.Count),1+CArtikul+CIZena+CKol+CIZena+CKol,CKOl);
            sKOl:=IntToStr(StrToInt(sKOl)+StrToInt(E^.Dat.MarketElement[i].Input.Kol),Ckol);
            sSumma:=Copy(TempBox^.GetText(j,TempBox^.List^.Count),1+CArtikul+CIZena+CKol+Ckol+CIZena+CKol,CIZena);
            Str(StrToReal(sSumma)+StrToInt(E^.Dat.MarketElement[i].Input.Kol)
              *StrToReal(E^.Dat.MarketElement[i].Input.Zakupka)*1.03
              :CIZena:CMantissaZ,sSumma);
            rformat(sKol,CKol);
            rFormat(sSumma,CIZena);
            ss:=ss+sKol+SSumma;
            System.Delete(st,1+CArtikul+CIZena+CKol+CIZena+CKol,CKOl+CIZena);
            System.Insert(ss,st,1+CArtikul+CIZena+CKol+CIZena+CKol);


          TempBox^.List^.AtFree(j);
          TempBox^.SetRange(TempBox^.List^.Count);

          TempBox^.List^.Insert(NewStr(st));
          TempBox^.SetRange(TempBox^.List^.Count);

        end;
      end;
    if not find then
      begin
           st[0]:=#0;
           Artikul:=E^.Dat.MarketElement[i].BazKod;
           format(Artikul,CArtikul);
           st:=st+Artikul;
           sKol:='0';
           sSumma:='0.00';
           rformat(sKol,CKol);
           rformat(sSumma,CIZena);
           st:=st+sKol+sSumma+Skol+SSumma;
           sZena:=E^.Dat.MarketElement[i].Input.Zakupka;
           rformat(sZena,CIZena);
           sKol:=IntToStr(StrToInt(E^.Dat.MarketElement[i].Input.Kol),CKol);
           rformat(skol,CKol);
           st:=st+sKol;
           MyStr(StrToReal(sKol)*StrToReal(sZena)*1.03,CIZena,CMantissaZ,sSumma);
           rFormat(sSumma,CIZena);
           st:=st+sSumma;
           sKol:='0';
           sSumma:='0.00';
           rformat(sKol,CKol);
           rformat(sSumma,CIZena);
           st:=st+sKol+sSumma;
           st:=st+sKol+sSumma;
           st:=st+sKol+sSumma;
           st:=st+sKol;

        TempBox^.List^.Insert(NewStr(st));
        TempBox^.SetRange(TempBox^.List^.Count);
      end;
   end;

 end;

 NoinfoMsg;
End;

(*procedure MarkRewisia(Const E:PRewisiaType);

var
  sKol: string[CKOL];
  ssumma: string[CIZena];
  Artikul: string[CArtikul];
  sZena: string[CZena];
  sName1,sName: string[CName];
  find:boolean;
  i,j:word;
  st,st1,ss:string;
Begin

DInfoMsg('Просматриваю ревизии за '+DateToDateString(DateMask,DEn),False);
For i:=1 to E^.Dat.Amount do
 begin
  If TempBox^.List^.Count-1>=0 Then
   begin
    find:=false;
    for j:=0 to TempBox^.List^.Count-1 do
      begin

       st1[0]:=#0;
       st1:=Copy(TempBox^.GetText(j,TempBox^.List^.Count),1,CArtikul);
       format(st1,CArtikul);
       Artikul:=E^.Dat.Element[i].BazKod;
       {sName1:=GetIdField(FName,st1);
       sName:=GetIdField(FName,E^.Dat.PrihodElement[i].BazKod);}
       format(Artikul,CArtikul);
       if st1=Artikul{sName1=sName} then
        begin
          find:=true;

          st[0]:=#0; ss:='';
          st:=TempBox^.GetText(j,TempBox^.List^.Count);
          sKol:=Copy(TempBox^.GetText(j,TempBox^.List^.Count),1+CArtikul+CIZena+CKol+CIZena+CKol+CIZena+CKol+CIZena+CKol+CIZena
		  +CKol+CIZena+CKOL,CKol);
          {writeln(sKOl);}
          sKol:=IntToStr(StrToInt(E^.Dat.Element[i].Input.Kol)+StrToInt(sKol),CKol);
          rformat(sKol,CKol);
          sSumma:={'0.00'}E^.Dat.Element[i].Input.R_Zena;

          rformat(sSumma,CIZena);
          ss:=ss+sKol+sSumma;
          {writeln(Artikul+' '+ss);
          readln;}

          {sZena:=E^.Dat.PrihodElement[i].Input.Zakupka;
          sSumma:=Copy(TempBox^.GetText(j,TempBox^.List^.Count),1+CArtikul+CIZena+CKol+CKol,CIZena);
          MyStr(StrToReal(sSumma)+StrToReal(sZena)*StrToReal(E^.Dat.PrihodElement[i].Input.Kol),CIZena,CMantissaZ,sSumma);
          rformat(sSumma,CIZena);
          ss:=ss+sSumma;}
          System.Delete(st,1+CArtikul+CIZena+CKol+CKol+CIZena+CKol+CIZena+CKol+CIZena+CKol+CIZena+CKol+CIZena,CKol+CIZena);

          System.Insert(ss,st,1+CArtikul+CIZena+CKol+CKol+CIZena+CKol+CIZena+CKol+CIZena+CKol+CIZena+CKol+CIZena);
          {sKOl:='0';
          sSumma:='0.00';
          rformat(sKol,CKol);
          rformat(sSumma,CIZena);
          st:=st+Skol+sSumma;
          st:=st+Skol+sSumma;}
          {TempBox^.List^.AtDelete(j);
          TempBox^.List^.AtInsert(j,NewStr(st));}
         { writeln(st);
          readln; }

          TempBox^.List^.AtFree(j);
          TempBox^.SetRange(TempBox^.List^.Count);

          TempBox^.List^.Insert(NewStr(st));
          TempBox^.SetRange(TempBox^.List^.Count);

        end;
      end;
    if not find then
      begin
       { memc; }
        st[0]:=#0;
        Artikul:=E^.Dat.Element[i].BazKod;
        st:=Artikul;
        sKol:='0';
        sSumma:='0.00';
        rformat(sKol,CKol);
        rformat(sSumma,CIZena);
        st:=st+sKol+sSumma;
        st:=st+sKol+sSumma;
        st:=st+sKol+sSumma;
        st:=st+sKol+sSumma;
        st:=st+sKol+sSumma;
        st:=st+sKol+sSumma;

       { sZena:=E^.Dat.PrihodElement[i].Input.Zakupka;
        rformat(sZena,CZena);}

        sKol:=E^.Dat.Element[i].Input.Kol;
        sKol:=IntToStr(StrToInt(E^.Dat.Element[i].Input.Kol),CKol);
        rformat(skol,CKol);
        sSumma:=E^.Dat.Element[i].Input.R_Zena;
        rformat(sSumma,CIZena);

        {writeln(Artikul,' ',sSumma);
        readln;}

        st:=st+sKol+sSumma;
        {MyStr(StrToReal(sKol)*StrToReal(sZena),CIZena,CMantissaZ,sSumma);
        rformat(sSumma,CIZena);
        st:=st+sSumma;}
       { writeln(st);
        readln; }
        TempBox^.List^.Insert(NewStr(st));
      end;
   end;

 end;

 NoinfoMsg;
End;    *)



Procedure CalcBux;
var Date : TDAteString;
    FM: MarketFileType;
    FP: PrihodFileType;
    FV: NewVozwratFileType;
    sName: string[CName+1+CName];
    sName2: string[CName];
    sZena: string[CIZena];
    sSumma: string[CIZena];
    sV,SumV,sVO,SumVO,SumOst,So,Sp,sPO,sPR,Sum_O,SumP,SumPO,SumPR,SrZ,SumZ,SumPRZ: string[CIZena];
    KolVO,KolV,KolO,KolP,KolPO,KolPR: string[CKOL];
    KolOst,KolSklad: string[CKOL];
    Artikul, Artikul1: string[CArtikul];
    sKol: string[CKOL];
    sSklKOd: string[2];
    sR,sR1: string[2];
    P: PPrihodType;
    M: PSuperMarkettype;
    V: PNewVozwratType;
    RAbday,Start,Stop: LongInt;
    Txt: text;
    s3 : String;
    l,j,i,ii:word;
    R: TRect;
    s,ss,s1:string;
    n,k:word;
    mm3 : Maska3;
    mm9 : Maska9;
    Ostatok:NewItogType;
    FO : file of NewItogType;
    FR: RewisiaFileType;
    RW: PRewisiaType;
    Find: boolean;

Begin
 vid:=1;
 If Not(PeriodProd) Then Exit;;
 Start:=DateStringToDate(DateMask,StartDate);
 Stop:=DateStringToDate(DateMask,StopDate);

 Assign(Txt,Path^.Dat.ToTemp+'buxotch.txt');
 l:=IOResult;
 Rewrite(Txt);
 l:=IOResult;
 If L <> 0 Then
  Begin
   MessageBox(#3^M+#3'Не могу создать файл отчета'+Path^.Dat.ToTemp+'buxotch.txt',Nil,mfError+mfCancelButton);
   Exit;
  End;

 New(P,Init);
 New(m,Init);
 New(V,Init);
 New(RW,Init);

 R.Assign(0, 0, 0, 0);
 TempBox := New(PBox, Init(R, 1, Nil));
 TempBox^.NewList(New(PTextCollection, Init(0,1)));

 R.Assign(0, 0, 0, 0);
 VBox := New(PBox, Init(R, 1, Nil));
 VBox^.NewList(New(PTextCollection, Init(0,1)));
{!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!}

 Den:=Start-1;
 Date:=DateToDateString('DDmmyy',Den);
 DelSpace(Date);
 l:=1;
 sSklKOd:=copy(Rek^.Dat.kod,3,2);
 while not FExists(Path^.Dat.ToArchiv+Date+'.p'+sSklKOd) do
  begin
   dec(Den);
   inc(l);
   if l>5 then
     begin
      MessageBox(#3^M+#3'Отсутствует краткий отчет - '+Path^.Dat.ToArchiv+Date+'.p'+sSklKOd,Nil,mfError+mfCancelButton);
      exit;
     end;
   Date:=DateToDateString('DDmmyy',Den);
   DelSpace(Date);
  end;

 Assign(FO,Path^.Dat.ToArchiv+Date+'.p'+sSklKOd);
   l:=IOResult;
   Reset(fO);
   l:=Ioresult;
   If L <> 0 Then
    Begin                                 {!!!!!BUXGALT!!!}
      MessageBox(#3^M+#3'Не найден файл '+Path^.Dat.ToArchiv+Date+'.p'+sSklKOd,Nil,mfError+mfCancelButton);
      exit;
    End;

 Date:=DateToDateString(DateMask,Den);

  Writeln(txt,GlobalPrn^.Dat.OrientAlbom[NPrint^.DAt.Printer]+
  GlobalPrn^.Dat.MinInterval[NPrint^.DAt.Printer]);
 Writeln(Txt,' Склад:'+GetClientField(FClient,Rek^.Dat.Kod,1));
 writeln(txt,' Остатки на складе за '+Date);

 while not eof(FO) do
 begin
  read(FO,Ostatok);
  Artikul:=Ostatok.BazKod;
  sKol:=Ostatok.Ost;
  rformat(sKol,CKol);
  sSumma:=RealToStr(Ostatok.OstEZ,CIZena,CMantissa);
  rformat(sSumma,CIZena);
  s:=Artikul+sKol+sSumma;
  sKOl:='0';
  sSumma:='0.00';
  rformat(sKol,CKol);
  rformat(sSumma,CIZena);

  s:=s+Skol+sSumma;         {!!!!}
  s:=s+Skol+sSumma;
  s:=s+Skol+sSumma;
  s:=s+Skol+sSumma;
  s:=s+Skol+sSumma;
  s:=s+SKOl;


  TempBox^.List^.Insert(NewStr(s));
      TempBox^.SetRange(TempBox^.List^.Count);
 end;

 Close(FO);

 For Den:=Start To Stop Do
 Begin
   Date:=DateToDateString(DateMask,DEn);

 {Приходы}

   Assign(FP,Path^.Dat.ToPrihod+Date+'.prh');
   l:=IOResult;
   Reset(fP);
   l:=Ioresult;
   If L <> 0 Then
    Begin                                 {!!!!!BUXGALT!!!}
    {  MessageBox(#3^M+#3'Не найден файл '+Path.ToMarket+Date+'.prh',Nil,mfError+mfCancelButton);}
      ;
    End
   else
   begin
    while not eof(FP) do
     begin

      ReadPrihod(FP,P);
      if P^.Dat.OperatorSelector in [0,2] then
        PrihAddToList(P)
	   else PrihSkladAddToList(P);
     end;

    Close(FP);
   end;
 {Продажи}
  {Опт}
   Assign(FM,Path^.Dat.ToMarket+Date+'.mrk');
   l:=IOResult;
   Reset(fM);
   l:=Ioresult;
   If L <> 0 Then
    Begin                                 {!!!!!BUXGALT!!!}
      {MessageBox(#3^M+#3'Не найден файл '+Path.ToMarket+Date+'.mrk',Nil,mfError+mfCancelButton);}
      ;
    End
   else
   begin
    while not eof(FM) do
     begin
      ReadMarket(FM,M);
      If (m^.Dat.Active) Then
      If m^.Dat.OperatorSelector=0 Then
         if (Not(m^.Dat.Realiz) and  (m^.Dat.DocSelector in [3,4])) Or
         (m^.Dat.DocSelector in [6,8])
	   then
         begin
          { Writeln(M^.Dat.Document);
           readln; }
           MarkOptAddToList(M);
         end;
     end;

   Close(FM);
   end;
  {Розница}
   Assign(FM,Path^.Dat.ToMarket+Date+'.mrk');
   l:=IOResult;
   Reset(fM);
   l:=Ioresult;
   If L <> 0 Then
    Begin                                 {!!!!!BUXGALT!!!}
    {  MessageBox(#3^M+#3'Не найден файл '+Path.ToMarket+Date+'.mrk',Nil,mfError+mfCancelButton);}
      ;
    End
   else
   begin
    while not eof(FM) do
     begin
      ReadMarket(FM,M);
      If (m^.Dat.Active) Then
      If m^.Dat.OperatorSelector=0 Then
      if m^.Dat.DocSelector in [0,1,2,5,7] Then
       if not((m^.Dat.Realiz) and  (m^.Dat.DocSelector in [1,2]))
	 then
        MarkRoznAddToList(M);
     end;

   Close(FM);
   end;

{продажи межсклад.}
   Assign(FM,Path^.Dat.ToMarket+Date+'.mrk');
   l:=IOResult;
   Reset(fM);
   l:=Ioresult;
   If L <> 0 Then
    Begin                                 {!!!!!BUXGALT!!!}
    {  MessageBox(#3^M+#3'Не найден файл '+Path.ToMarket+Date+'.mrk',Nil,mfError+mfCancelButton);}
      ;
    End
   else
   begin
    while not eof(FM) do
     begin
      ReadMarket(FM,M);
      If (m^.Dat.Active) Then
      If m^.Dat.OperatorSelector=1 Then
      if m^.Dat.ClientKOd<>'0000' then
     { if m^.Dat.DocSelector in [0,1,2,5,7] Then
       if not((m^.Dat.Realiz) and  (m^.Dat.DocSelector in [1,2]))
	 then                                                        }
        MarkSkladAddToList(M);
     end;

   Close(FM);
   end;


{ВОЗВРАТЫ розн}
   Assign(FV,Path^.Dat.ToReturn+Date+'.vzw');
   l:=IOResult;
   Reset(fV);
   l:=Ioresult;
   If L <> 0 Then
    Begin                                 {!!!!!BUXGALT!!!}
     { MessageBox(#3^M+#3'Не найден файл '+Path.ToMarket+Date+'.vzw',Nil,mfError+mfCancelButton);}
      ;
    End
   else
   begin
    while not eof(FV) do
     begin
      ReadNewVozwrat(FV,V);
     { If (v^.Dat.Active) Then}
      if (v^.Dat.OperatorSelector=0) then
      if v^.Dat.DocSelector in [0,1,2,5,7]{[3,4,6,8]} then
        MarkVozwratAddToList(V);
     end;
   Close(FV);
   end;

{ВОЗВРАТЫ опт}
   Assign(FV,Path^.Dat.ToReturn+Date+'.vzw');
   l:=IOResult;
   Reset(fV);
   l:=Ioresult;
   If L <> 0 Then
    Begin                                 {!!!!!BUXGALT!!!}
      {MessageBox(#3^M+#3'Не найден файл '+Path.ToMarket+Date+'.vzw',Nil,mfError+mfCancelButton);}
      ;
    End
   else
   begin
    while not eof(FV) do
     begin
      ReadNewVozwrat(FV,V);
     { If (v^.Dat.Active) Then }
      if (v^.Dat.OperatorSelector=0) then
      if v^.Dat.DocSelector in {[0,1,2,5,7]}[3,4,6,8] then
        MarkOptVozwratAddToList(V);
     end;
   Close(FV);
   end;

{Ревизия }
   Assign(FR,Path^.Dat.ToRewisia+Date+'.rwz');
   l:=IOResult;
   Reset(fr);
   l:=Ioresult;
   If L <> 0 Then
    Begin                                 {!!!!!BUXGALT!!!}
     { MessageBox(#3^M+#3'Не найден файл '+Path.ToMarket+Date+'.rwz',Nil,mfError+mfCancelButton);}
      ;
    End
   else
   begin
    while not eof(Fr) do
     begin
      ReadRewisia(Fr,rw);
        MarkRewisiaAddToList(rw);
     end;
   Close(Fr);
   end;


{Р/П}
   Assign(FM,Path^.Dat.ToMarket+Date+'.mrk');
   l:=IOResult;
   Reset(fM);
   l:=Ioresult;
   If L <> 0 Then
    Begin
    {  MessageBox(#3^M+#3'Не найден файл '+Path.ToMarket+Date+'.mrk',Nil,mfError+mfCancelButton);}
      ;
    End
   else
   begin
    while not eof(FM) do
     begin
      ReadMarket(FM,M);
      If (m^.Dat.Active) Then
      If m^.Dat.OperatorSelector=1 Then
       if m^.Dat.DocSelector =0 Then
       if m^.Dat.ClientKOd='0000'

	 then
          RPAddToList(M);
     end;

   Close(FM);
   end;


 End; {For Den}

 sr1:='';
 sr:='';
l:=IOResult;

 writeln(txt);
 writeln(txt,'                                О Т Ч Е Т  з а  п е р и о д   с '+DateToDateString(DateMask,Start)
    +' по '+DateToDateString(DateMask,Stop));
 writeln(txt);
 Writeln(txt,GlobalPrn^.Dat.Condensed[NPrint^.DAt.Printer]);
 Writeln(txt,
'-----------------------------------------------------------------------------------------------------------------------------'
+'-------------------------------------------------------------------------------------------------------');
Writeln(txt,
'           Наименование                                Код  Ост.н      Сумма ост.н Прих.      Сумма прих.  Опт. ',
' Сумма прод.опт'
+'. Розн.  Сумма прод.розн  Воз.р.  Сумма воз.розн Воз.о.   Сумма воз.опт. М/скл  Ост.к  Сумма ост.кон');
Writeln(txt,
'---------------------------------------------------------------------------------------------------------------------------'
+'---------------------------------------------------------------------------------------------------------');


 Sum_O:='0.00';
 rformat(Sum_O,CIZena);
 SumP:='0.00';
 rformat(SumP,CIZena);
 SumPO:='0.00';
 rformat(SumPO,CIZena);
 SumPR:='0.00';
 rformat(SumPR,CIZena);
 SumZ:='0.00';
 rformat(SumZ,CIZena);
 SumPRZ:='0.00';
 rformat(SumPRZ,CIZena);
 SumV:='0.00';
 rformat(SumV,CIZena);
 SumVO:='0.00';
 rformat(SumVO,CIZena);

DInfoMsg('Формируется отчет',False);

 if TempBox^.List^.Count>0 then
 for j:=0 to TempBox^.List^.Count-1 do
  begin
   s:=TempBox^.GetText(j,TempBox^.List^.Count);
   KolO:=Copy(s,1+Cartikul,Ckol);
   KolP:=Copy(s,1+Cartikul+CKol+cizENA,Ckol);
   KolPO:=Copy(s,1+Cartikul+CKol+cizENA+CKol+cizENA,Ckol);
   KolPR:=Copy(s,1+Cartikul+CKol+cizENA+CKol+cizENA+CKol+cizENA,Ckol);
   KolV:=Copy(s,1+Cartikul+CKol+cizENA+CKol+cizENA+CKol+cizENA+CKol+cizENA,Ckol);
   KolVO:=Copy(s,1+Cartikul+CKol+cizENA+CKol+cizENA+CKol+cizENA+CKol
        +cizENA+CKol+cizENA,Ckol);
   KolSklad:=Copy(s,1+Cartikul+CKol+cizENA+CKol+cizENA+CKol+cizENA+CKol
        +cizENA+CKol+cizENA+CKol+cizENA,Ckol);
   sO:=Copy(s,1+Cartikul+CKol,CIZena);
   sP:=Copy(s,1+Cartikul+CKol+CIZena+CKol,CIZena);
   sPO:=Copy(s,1+Cartikul+CKol+CIZena+CKol+CIZena+CKol,CIZena);
   sPR:=Copy(s,1+Cartikul+CKol+CIZena+CKol+CIZena+CKol+CIZena+CKol,CIZena);
   sV:=Copy(s,1+Cartikul+CKol+CIZena+CKol+CIZena+CKol+CIZena+CKol+CIZena+CKol,CIZena);
   sVO:=Copy(s,1+Cartikul+CKol+CIZena+CKol+CIZena+CKol+CIZena+CKol+CIZena+CKol
        +CIZena+CKol,CIZena);


  {Средняя закупка}

  Artikul:=Copy(s,1,Cartikul);

 Den:=Stop;
 Date:=DateToDateString('DDmmyy',Den);
 DelSpace(Date);
 l:=1;
 sSklKOd:=copy(Rek^.Dat.kod,3,2);
 while not FExists(Path^.Dat.ToArchiv+Date+'.p'+sSklKOd) do
  begin
   inc(Den);
   inc(l);
   if l>5 then
     begin
      MessageBox(#3^M+#3'Отсутствует краткий отчет '+Path^.Dat.ToArchiv+Date+'.p'+sSklKOd,Nil,mfError+mfCancelButton);
      NoInfoMsg;
      exit;
     end;
   Date:=DateToDateString('DDmmyy',Den);
   DelSpace(Date);
  end;

 Assign(FO,Path^.Dat.ToArchiv+Date+'.p'+sSklKOd);
   l:=IOResult;
   Reset(fO);
   l:=Ioresult;
   If L <> 0 Then
    Begin                                 {!!!!!BUXGALT!!!}
      MessageBox(#3^M+#3'Не найден файл '+Path^.Dat.ToArchiv+Date+'.p'+sSklKOd,Nil,mfError+mfCancelButton);
      NoInfoMsg;
      exit;
    End;

  Find:=False;

  While not eof(FO) do
  begin
   read(FO,Ostatok);
   Artikul1:=Ostatok.BazKod;
   if Artikul1=Artikul then
    begin
     sKol:=Ostatok.Ost;
     rformat(sKol,CKol);
     rformat(sSumma,CIZena);

     if StrToInt(sKOl)>0 then
       Str(Ostatok.OstEZ/StrToReal(sKOl):CIZena:CMantissaZ,SrZ)
     else SrZ:='0.0000';

     rformat(srZ,CIZena);
     Find:=True;
     break;
    end;
  end;

  Close(FO);

  If Not Find then
   begin
   (* if StrToInt(KolO)+StrToInt(KolP)>0 then
     if StrToInt(KolP)>0 then
       MyStr(StrToReal(sP)/
          StrToReal(KolP),CIZena,CMantissa,SrZ)
     else
       MyStr((StrToReal(sO)+StrToReal(sP))/
          (StrToReal(KolO)+StrToReal(KolP)),CIZena,CMantissaZ,SrZ)
    else
     begin
      srZ:=BakGetField(FZakupka,Artikul,0);
      rformat(srZ,CIZena);
    end;  *)
    srZ:='0.0';
   end;

  {Остаток на конец периода}
   KolOst:=IntToStr(StrToInt(KolO)+StrToInt(KolP)-StrToInt(KolPR)-StrToInt(KolPO)+StrToInt(KolV)+StrToInt(KolVO)
     +StrToInt(KolSklad),CKOL);
   MyStr(StrToReal(KolOst)*StrToReal(SrZ),CIZena,CMantissa,SumOst);
   rformat(KolOst,CKOL);
   rformat(SumOst,CIZena);
   s:=s+KolOst+SumOst;
  { Суммы по столбцам}
   MyStr(StrToReal(Sum_O)+StrToReal(sO),CIZena,CMantissa,Sum_O);
   MyStr(StrToReal(SumP)+StrToReal(sP),CIZena,CMantissa,SumP);
   MyStr(StrToReal(SumPO)+StrToReal(sPO),CIZena,CMantissa,SumPO);
   MyStr(StrToReal(SumPR)+StrToReal(sPR),CIZena,CMantissa,SumPR);
   MyStr(StrToReal(SumZ)+StrToReal(sumOst),CIZena,CMantissa,SumZ);
   MyStr(StrToReal(SumPRZ)+StrToReal(KolPR)*StrToReal(srZ),CIZena,CMantissa,SumPrZ);
   MyStr(StrToReal(SumV)+StrToReal(sV),CIZena,CMantissa,SumV);
   MyStr(StrToReal(SumVO)+StrToReal(sVO),CIZena,CMantissa,SumVO);

  {Наименование}

   sName:=GetIdField(FName,Artikul)+GetIdField(FName2,Artikul);
   format(sName,CName+1+CName);
   System.Insert(sName,s,1);

   System.Insert(' ',s,1+CArtikul+CName+1+CName+CKol+CIZena+CKol+CIZena+CKol+CIZena+CKol+CIZena+CKol+CIZena+CKol+CIZena+CKol);
   System.Insert(' ',s,1+CArtikul+CName+1+CName+CKol+CIZena+CKol+CIZena+CKol+CIZena+CKol+CIZena+CKol+CIZena+CKol+CIZena);
   System.Insert(' ',s,1+CArtikul+CName+1+CName+CKol+CIZena+CKol+CIZena+CKol+CIZena+CKol+CIZena+CKol+CIZena+CKol);
   System.Insert(' ',s,1+CArtikul+CName+1+CName+CKol+CIZena+CKol+CIZena+CKol+CIZena+CKol+CIZena+CKol+CIZena);
   System.Insert(' ',s,1+CArtikul+CName+1+CName+CKol+CIZena+CKol+CIZena+CKol+CIZena+CKol+CIZena+CKol);
   System.Insert(' ',s,1+CArtikul+CName+1+CName+CKol+CIZena+CKol+CIZena+CKol+CIZena+CKol+CIZena);
   System.Insert(' ',s,1+CArtikul+CName+1+CName+CKol+CIZena+CKol+CIZena+CKol+CIZena+CKol);
   System.Insert(' ',s,1+CArtikul+CName+1+CName+CKol+CIZena+CKol+CIZena+CKol+CIZena);
   System.Insert(' ',s,1+CArtikul+CName+1+CName+CKol+CIZena+CKol+CIZena+CKol);
   System.Insert(' ',s,1+CArtikul+CName+1+CName+CKol+CIZena+CKol+CIZena);
   System.Insert(' ',s,1+CArtikul+CName+1+CName+CKol+CIZena+CKol);
   System.Insert(' ',s,1+CArtikul+CName+1+CName+CKol+CIZena);
   System.Insert(' ',s,1+CArtikul+CName+1+CName+CKol);
   System.Insert(' ',s,1+CArtikul+CName+1+CName);
   System.Insert(' ',s,1+CName+1+CName);


   sR1:=copy(Artikul,1,2);

   if sr<>sr1 then
    begin
      if VBox^.List^.Count>0 then
       begin
       for ii:=0 to VBox^.List^.Count-1 do
        begin
         ss:='';
         ss:=VBox^.GetText(ii,VBox^.List^.Count);
         writeln(txt,ss);
        end;
       VBox^.NewList(Nil);
       {VBox^.List^.FreeAll;}
       VBOx^.NewList(New(PTextCollection, Init(0,1)));
       {VBox^.SetRange(VBox^.List^.Count);}
      end;
      {memc(sr1+' '+IntToStr(VBox^.List^.Count,3));}
      writeln(txt);
      writeln(txt,'     Раздел: ',GetRazdel(sr1));
      writeln(txt);
      sr:=sr1;
    end;

      VBox^.List^.Insert(NewStr(s));
     { writeln(s);
      readln;}
      VBox^.SetRange(VBox^.List^.Count);

   if j= TempBox^.List^.Count-1 then
    begin
      if VBox^.List^.Count>0 then
       begin
       for ii:=0 to VBox^.List^.Count-1 do
        begin
         ss:='';
         ss:=VBox^.GetText(ii,VBox^.List^.Count);
         writeln(txt,{intToStr(ii,CKod),}ss);
        end;
       VBox^.NewList(Nil);
       VBOx^.NewList(New(PTextCollection, Init(0,1)));
      end;
    end;
  end;

Writeln(txt,
'---------------------------------------------------------------------------------------------------------------------------'
+'-----------------------------------------------------------------------------------------------');

Writeln(txt,'Всего:                                                     Ост.н: ',Sum_O,' Прих.:',SumP,
  '  Опт.:',SumPO,' Розн.:',SumPR,' Ост.к:',Sumz);
Writeln(txt,'                                                                 '+
     '                               Возвраты розн:',SumV);
Writeln(txt,'                                                                 '+
     '                               Возвраты  опт:',SumVO);

Writeln(Txt,' "'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
Writeln(txt,
'============================================================================================================================',
'========='
+'===============================================================================================');


NoInFoMsg;
 Dispose(V,Done);
 Dispose(m,Done);
 Dispose(P,Done);
 Dispose(RW,Done);
 Dispose(VBox,Done);
 Dispose(TempBox,Done);
 Close(Txt);
 ViewAsText(Path^.Dat.ToTemp+'buxotch.txt','Оборотная ведомость с '+StartDate+' по '+StopDate,True);
 {Report(Path^.Dat.ToTemp+'buxotch.txt','',1,False,False);}

End;



{$EndIf}


BEGIN
END.