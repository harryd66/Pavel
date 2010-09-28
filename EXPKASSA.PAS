Unit ExpKassa;

interface

Uses Dialogs,Glob,Views,MyCalc,ServStr,Drivers,Utils;

function ReadKassaMarket(sh:string{?};ind: string{?}):boolean;

implementation

uses app,Memory,Dos,MsgBox,Objects,Validate,TpDate,WinDos,Editors,Vision4,
 DbEngine,NetCall,NetDbEng,CPrihod,Protect{,StarSky},Gadgets,ColorTxt,
 Access1,Utils3,Mail,Vision8,Net,Printers,Utils1,MrkTools,Serv,DBIII;


Function TestKassaElement (Const S : AllStr;Const P : PBox) : Boolean;
Var ls : Word;
    k  : Byte;
    st : String[CALL];
Begin
TestKassaElement:=True;
For ls :=0 To P^.List^.Count Do
Begin
St:=P^.GetText(ls,P^.List^.Count);
ST:=Copy(St,1,Ckol+CArtikul);
If St=S Then
   Begin
    TestKassaElement:=False;
    Break;
   End;
End;
End;

Function LocationKassa(Const P:PBox;Const s:ArtikulStr):Word;
Var w,i: Word;
    st : String;
Begin
locationKassa:=0;
For i:=0 To P^.List^.Count Do
  Begin
  LocationKassa:=i;
  st:=P^.GetText(i,P^.List^.Count);
  st:=Copy(st,1,Ckol+CArtikul);
  If St=s Then
               Break;
  End;

  If not(st=s) Then
  Begin
  LocationKassa:=0;
  MessageBox(#3'Элемент ('+s+') в списке не найден!'^M+
  #3'Заменяю его на следующий!'^M++#3+ClicProgrammer,Nil,mfInsertInApp+mfError+mfCancelButton);
  End;
End;

function ReadKassaMarket(sh:string{?};ind: string{?}):boolean;
var MarkBase: DBase3;
    TovBase:  DBase3;
    ChekBase: DBase3;
    NCH: longint;
    TempList : PBox;
    s: String;
    sNCH: string [Ckol];
    sIDCHek: string[6];
    sKodTov: string[CArtikul+1];
    Artikul: string[CArtikul];  {!!!!!!!!!!!!!!!}
    sPOs: string[Ckol+CArtikul];
    sOper: string[10];
    sKol,sKol1: string[Ckol];    {!!!!!!!!!!!!!!!!!!!!}
    sNetNom: string[2];
    sTime: string[11];
    R: TRect;
    fKol,fNch: Float;
    Kol,iNch: word;
    Posit,i,IORez: word;
    fm,fo: text;
    TekDate: string[CDate];
    Separator: char;
Begin

  ReadKassaMarket:=false;
  TekDate:=FDate;

  Separator:='&';

  R.Assign(0,0,0,0);
  TempList := New(PBox, Init(R, 1, Nil));
  TempList^.NewList(New(PTextCollection, Init(0,1)));

{Продажи}

   Assign(fm,Path.ToTerminal+TekDate+'.m'+ind);
   IORez:=ioresult;
   Rewrite(fm);
   IORez:=ioresult;
   if IORez<>0 then
     begin
      MessageBox(^M+#3'Ошибка создания файла'+Path.ToTerminal+TekDate+'.m'+ind,Nil,mfWarning+mfCancelButton);
      Dispose(TempList,done);
      exit;{?}
     end;

  with ChekBase do
   begin
    Assign(Path.ToTerminal+'jc'+sh+'.dbf'); {пpисвоить БД имя}
    if not Open(ReadOnly) then
      begin
        MessageBox(^M+#3'Не могу открыть журнал чеков '+Path.ToTerminal+'jc'+sh+'.dbf',Nil,mfWarning+mfCancelButton);
        Dispose(TempList,done);
        System.close(fm);
        IORez:=ioresult;
        exit;{?}
      end;
   end;


  DInfoMsg('Читаю продажи сервера касс',True);

  with MarkBase do
   begin
    Assign(Path.ToTerminal+'jp'+sh+'.dbf'); {пpисвоить БД имя}
    if Open(ReadOnly) then
     begin
      for NCH:=1 to LastRec do
       begin
           Go_To(nch);
           s:='';

           fNCH:=Num('IDCHEK');
           iNch:=Round(fNch);
           sNch:=IntToStr(iNch,Ckol);
           rFormatZerro(sNch,CKOl);

           sKodTov:=Str('KODPRICE');
           Artikul:=Copy(sKodTov,2,CArtikul);

           sPos:=sNCH+Artikul;

           sOper:=Str('TOPER');

           fKOl:=Num('KOLED');
           KOl:=round(fKol);
           sKol:=IntToStr(Kol,Ckol);
           rformatZerro(sKol,CKol);

           If TestKassaElement(sNCH+Artikul,TempList) Then
           Begin
            {если нет в списке}
            s:=sNCh+Artikul+sKOl;
            TempList^.List^.Insert(NewStr(s));
            TempList^.SetRange(TempList^.List^.Count);
           end
           else
           begin
             Posit:=LocationKassa(TempList,sPOs);
             s:=TempList^.GetText(Posit,TempList^.List^.Count);
             {кол-во товара с повторяющемся в чеке кодом}
             sKol1:='';
             sKOl1:=copy(s,CKOl+CArtikul+1,CKOl);
             {Возвраты и аннуляции}
             DelSpace(sOper);
             if (sOper='Возврат') or (sOper='Аннуляция') then
             Str(StrToInt(sKol)-StrToInt(sKol1):CKol,sKol)
             else
             Str(StrToInt(sKol1)+StrToInt(sKol):CKol,sKol);
             RFormatZerro(SKol,CKol);

             TempList^.List^.AtFree(Posit);
             TempList^.SetRange(TempList^.List^.Count);

             if StrToInt(sKol)>0 then
              begin
               System.Delete(s,CKOl+CArtikul+1,CKOl);
               System.Insert(sKol,s,Ckol+CArtikul+1);
               TempList^.List^.Insert(NewStr(s));
               TempList^.SetRange(TempList^.List^.Count);
              end;
           end;
       end;  {for nch}




       if TempList^.List^.Count>0 then
         for i:=0 to TempList^.List^.Count-1 do
           begin
            ChekBase.Go_to(1);
            s:='';
            s:=TempList^.GetText(i,TempList^.List^.Count);
            {sNCh:=System.copy(s,1,Ckol);}
            sIdchek:='';
            sIdchek:=System.copy(s,1,Ckol);
            rFormat(sIdchek,6);

            ChekBase.Find('IDCHEK',sIdchek);

            sNetnom:=ChekBase.Str('NETNOM');

            sTime:=ChekBase.str('TIME');                 {?????}
            Stime[0]:=#5;
            Format(STime,5);

            System.insert(Separator,s,1+Ckol);
            System.insert(Separator,s,1+Ckol+1+CArtikul);
            System.insert(sNetnom+Separator+sTime+Separator,s,1+Ckol+1+1+CArtikul);

            Writeln(fm,s);
           end;

     end {Open}
     else
     begin
       MessageBox(^M+#3'Не могу открыть журнал покупок '+Path.ToTerminal+'jp'+sh+'.dbf',Nil,mfWarning+mfCancelButton);
       Dispose(TempList,done);
       System.close(fm);
       ChekBase.Close;
       NoInfoMsg;
       exit; {?}
     end;
   end;


  System.Close(fm);
  MarkBase.Close;
  ChekBase.Close;
  NoInfoMsg;
  Dispose(TempList,done);

{Остатки}

  Assign(fo,Path.ToTerminal+TekDate+'.o'+ind);
   IORez:=ioresult;
   Rewrite(fo);
   IORez:=ioresult;
   if IORez<>0 then
     begin
      MessageBox(^M+#3'Ошибка создания файла'+Path.ToTerminal+TekDate+'.o'+ind,Nil,mfWarning+mfCancelButton);
      exit;{?}
     end;

  DInfoMsg('Читаю остатки сервера касс',True);
  with TovBase do
   begin
    Assign(Path.ToTerminal+'base_tov.dbf'); {пpисвоить БД имя}
    if Open(ReadOnly) then
      begin
        with TovBase do
        begin
          for NCH:=1 to LastRec do
            begin
              go_to(nch);
              s:='';
              Artikul:=Str('KODPRICE');
              fKOl:=Num('KOLTOV');
              KOl:=round(fKol);
              sKol:=IntToStr(Kol,Ckol);
              rformat(sKol,CKol);
              s:=Artikul+Separator+sKOl;
              writeln(fo,s);
            end;
        end;
      TovBase.Close;
      end
      else
      begin
        MessageBox(^M+#3'Не могу открыть справочник товаров '+Path.ToTerminal+'base_tov.dbf',Nil,mfWarning+mfCancelButton);
        System.Close(fo);
        NoInfoMsg;
        exit;{?}
      end;
   end;


  System.Close(fo);
  NoInfoMsg;

  ReadKassaMarket:= true;

End;

BEGIN
END.