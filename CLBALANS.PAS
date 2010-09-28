
Unit ClBalans;

INTERFACE

Uses ServStr,Objects;
(*Type PClientDolgType = ^TClientDolgType
     TClientDolgType = object(TObject);
        Dat: ClientDolgType;
        constructor Init;
        destructor Done; virtual;
     end; *)

const BufferClientDolgType = 500;

type BufClientDolgType = record
       Dat: array [1..BufferClientDolgType] of ClientDolgType;
     end;

Type PBufClientDolgType = ^BufClientDolgTypePtr;
     BufClientDolgTypePtr =Object(TObject)
     Point :BufClientDolgType;
     Constructor Init;
     Destructor Done; Virtual;
End;



Function TestCalcDolgClient:boolean;



IMPLEMENTATION

Uses Dialogs,Glob,MsgBox,DBEngine,TPDate,
     App, Serv, ColorTxt,Protect,NetDbEng,Printers,Net,ServStr2,
	Utils,Utils1,Utils2,Utils5,Tools,Utils4,Utils3,Access1;

Const

      POsDT         = 1+CClientKod;
      PosD          = 1+CClientKod+CIZena;
      PosOtgr       = 1+CClientKod+CIZena+CIZena;
      PosSkOtgr     = 1+CClientKod+CIZena+CIZena+CIZena;
      PosReturn     = 1+CClientKod+CIZena+CIZena+CIZena+CIZena;
      PosSkReturn   = 1+CClientKod+CIZena+CIZena+CIZena+CIZena+CIZena;
      PosOpl        = 1+CClientKod+CIZena+CIZena+CIZena+CIZena+CIZena+CIZena;
      PosSkOfCons   = 1+CClientKod+CIZena+CIZena+CIZena+CIZena+CIZena+CIZena+CIZena;
      PosRashOtCons = 1+CClientKod+CIZena+CIZena+CIZena+CIZena+CIZena+CIZena+CIZena+CIZena;
      PosOskKon     = 1+CClientKod+CIZena+CIZena+CIZena+CIZena+CIZena+CIZena+CIZena+CIZena+CIZena;
      PosOskKonR    = 1+CClientKod+CIZena+CIZena+CIZena+CIZena+CIZena+CIZena+CIZena+CIZena+CIZena+CIZena;
                {123456789012345123456789012345            3              4               5              6              7}
                {              8             9              10             11}
      Shablon = '           0.00           0.00           0.00           0.00           0.00           0.00           0.00'+
                '           0.00           0.00           0.00           0.00';

Type ClientKodString = string[CClientKOd];


Constructor BufClientDolgTypePtr.Init;
Var c : Word;
Begin
TObject.Init;
For c:=1 To BufferClientDolgType Do
Begin
With Point.Dat[c] Do
 Begin
  Kod:='';
  DolgSF:=0.0;
  DolgSFT:=0.0;
  Dolg  :=0.0;
  DolgT :=0.0;
 End;
End;
End;

destructor BufClientDolgTypePtr.Done;
Begin
 inherited Done;
End;

function CalcDolgKon(E: Pbox):boolean;
Var ClientFile : File;
    ClientElement : PBufClientType;
    Find : Boolean;
    c ,count,i : Word;
    sd,sk: AllStr;
    Ext : TDAteString;
    s,s1,st: string;
    sSumma: string[CIZena];
Begin
New(ClientElement,Init);
CalcDolgKon:=False;
Assign (ClientFile,Path^.Dat.ToClient+'Client.db');
c:=IOResult;
Reset (ClientFile,SizeOf(ClientType));
c:=IOResult;
If c=0 Then
Begin
While Not(Eof(ClientFile)) Do
 Begin
  Count:=0;
  ReadBufClient(ClientFile,ClientElement,Count);
    For c:=1 To Count Do
    Begin
      If ClientElement^.Point.Dat[c].Employ Then
      Begin
        sd[0]:=#0;
        sk[0]:=#0;
        st:=ClientElement^.Point.Dat[c].Kod;
        CalcDolgNew(st,sd,sk);
        {Добавление клиента в список    }
        if (StrToReal(sd)>0.01) then
        begin
         if E^.List^.Count>=0 then
         for i:=0 to E^.List^.Count-1 do
          Begin
            s1:=Copy(E^.GetText(i,E^.List^.Count),1,CClientKod);

            DelSpace(s1);
            DelSpace(st);

            if st=s1 then
            begin
              {memc('1!');}
              find:=true;
              s:='';
              s:=E^.GetText(i,E^.List^.Count);

              sSumma:=RealToStr(StrToReal(sd)+StrToReal(sk),CIZena,CMantissa);
              rformat(sSumma,CIZena);

              System.Delete(s,PosOskKon,CIZena);
              System.Insert(sSumma,s,PosOskKon);

              sSumma:=sd;
              rformat(sSumma,CIZena);

              System.Delete(s,PosOskKonR,CIZena);
              System.Insert(sSumma,s,PosOskKonR);


              E^.List^.AtFree(i);
              E^.SetRange(E^.List^.Count);

              E^.List^.Insert(NewStr(s));
              E^.SetRange(E^.List^.Count);
              break;
           end;
          end;

          if not find then
          begin
            s:=st;
            {долг на начало T}
            sSumma:='0';
            rformat(sSumma,CIZena);
            s:=s+ssumma;
            {долг на начало }
            sSumma:='0';
            rformat(sSumma,CIZena);
            s:=s+ssumma;
            {отгр}
            sSumma:='0';
            rformat(sSumma,CIZena);
            s:=s+ssumma;
            {скидки отгр}
            sSumma:='0';
            rformat(sSumma,CIZena);
            s:=s+ssumma;
            {возвр}
            sSumma:='0';
            rformat(sSumma,CIZena);
            s:=s+ssumma;
            {скидк возвр}
            sSumma:='0';
            rformat(sSumma,CIZena);
            s:=s+ssumma;
            {опл}
            sSumma:='0';
            rformat(sSumma,CIZena);
            s:=s+ssumma;
            {скидк оф конс}
            sSumma:='0';
            rformat(sSumma,CIZena);
            s:=s+ssumma;
            {расх откр конс}
            sSumma:='0';
            rformat(sSumma,CIZena);
            s:=s+ssumma;
            {долг на конец T}
            sSumma:=RealToStr(StrToReal(sd)+StrToReal(sk),CIZena,CMantissa);
            rformat(sSumma,CIZena);
            s:=s+ssumma;
            {долг на конец}
            sSumma:=sd;
            rformat(sSumma,CIZena);
            s:=s+ssumma;

            E^.List^.Insert(NewStr(s));
            E^.SetRange(E^.List^.Count);
           end;

      End;

     End;{For}

 End;{While}

end;
Dispose(ClientElement,Done);
System.Close(ClientFile);
CalcDolgKon:=True;
End
Else
  MessageBox(^M+#3'Ошибка открытия '+Path^.Dat.ToClient+'Client.db',Nil,mfError+mfCancelButton);

End;


Function TestCalcDolgClient:Boolean;
Var Find : Boolean;
    ClientDolgFile : File;{ Of ClientDolgType;}
    BufDlg: PBufClientDolgType;
    ClientDolgElement : ClientDolgType;
    i, c ,count,code : Word;
    t:text;
    TempBox,ErrBox: PBox;
    sSumma:string[CIZena];
    R: TRect;
    st, s,s1,ws: string;
    m: PBufSuperMarketType;
    fm: file;
    fo: file;
    O:pBufOplataRealizasiaType;
    sKod : string[CClientKod];
    v: PNewVozwratType;
    fv: file of NewVozwratType;
    sRashodSumma:string[CIZena];
    raznT,razn: real;
    sName     : String[FFullClient];
    RaznOnly: boolean;
    StartDate, StopDate, sDate: TDateString;
    Start,Stop, tek: longint;
    PrintSumma: string[CIZena];
    k , cc, c1 : Word;
    cle: pBufKurzClientType;
    clf: file;
Begin

 If Not DatePeriodDialog(StartDate,StopDate,true) Then Exit;
  k:=SelectImport(26);

 If k=2 Then Exit;

 if k=1 then RaznOnly:=true
 else RaznOnly:=false;


{Проверка начальной даты}
find:=false;
for i:=1 to 3 do
begin
 if not FExists(Path^.Dat.TOarchiv+DateToDateString(DateMask,DateStringToDate(DateMask,StartDate)-1)
   +'.d'+copy(Rek^.Dat.kod,3,2))
   then StartDate:=DateToDateString(DateMask,DateStringToDate(DateMask,StartDate)-1)
 else
  begin
    find:=true;
    break;
  end;
end;

if not Find then
 begin
  MessageBox(^M+#3'Отсутствует архив долгов за '+StopDate+' !',Nil,mfError+mfCancelButton);
  Exit;
 end;

{проверка конечной даты}
find:=false;
for i:=1 to 3 do
begin
if not (FExists(Path^.Dat.TOarchiv+StopDate+'.d'+copy(Rek^.Dat.kod,3,2)))
   and(DateStringToDate(DateMask,FDate)<>DateStringToDate(DateMask,StopDate))
   and (DateStringToDate(DateMask,StopDate)>DateStringToDate(DateMask,StartDate))then
   StopDate:=DateToDateString(DateMask,DateStringToDate(DateMask,StopDate)-1)
   else
   begin
     find:=true;
     break;
   end;
end;

if not Find then
 begin
  MessageBox(^M+#3'Отсутствует архив долгов за '+StopDate+' !',Nil,mfError+mfCancelButton);
  Exit;
 end;


Assign(ClF,Path^.Dat.ToClientBaseIndex+'client.idx');
c:=ioresult;
Reset (ClF,SizeOf(KurzClientType));
c:=ioresult;
if c<>0 then
 begin
  MessageBox(^M+#3' Не могу открыть файл '+Path^.Dat.ToClientBaseIndex+'client.idx !',Nil,mfError+mfCancelButton);
  Exit;
 end;

 R.Assign(0, 0, 0, 0);
 TempBox := New(PBox, Init(R, 1, Nil));
 TempBox^.NewList(New(PTextCollection, Init(0,1)));

DinfoMsg('Формирую список клиентов',False);
 While Not(Eof(ClF)) Do
  Begin
   New(CLE,Init);
   Count:=0;
   ReadBufKurzClient(ClF,ClE,Count);
   For c:=1 To Count Do
   Begin
     If ClE^.Point.Dat[c].Employ Then
     Begin
      sKod:=IntToStr(ClE^.Point.Dat[c].Kod,CClientKod);
      rformatZerro(sKod,CClientKod);
      s:=sKod+Shablon;
      TempBox^.List^.Insert(NewStr(s));
      TempBox^.SetRange(TempBox^.List^.Count);
     End;
   end;
   Dispose(CLE,Done) ;
  end; {While Not(Eof(ClF))}
Close(CLF);
NoinfoMsg;

 R.Assign(0, 0, 0, 0);
 ErrBox := New(PBox, Init(R, 1, Nil));
 ErrBox^.NewList(New(PTextCollection, Init(0,1)));


Assign (t,Path^.Dat.TOTemp+'testdlg.txt');
c:=IOResult;
Rewrite (t);
c:=IOResult;
If c<>0 Then
 Begin
  Dispose(TempBox,Done);
  Dispose(ErrBox,Done);
  MessageBox(^M+#3'Ошибка создания '+Path^.Dat.TOTemp+'testdlg.txt'+' Код:'+IntToStr(c,CKol),
  nil,mfError+mfCancelButton);
  Exit;
 End;

{Начальная дата-------------------------------------}
DinfoMsg('Формирую список долгов за '+DateToDateString(DateMask,DateStringToDate(DateMask,StartDate)-1),False);
Assign (ClientDolgFile,Path^.Dat.TOarchiv+DateToDateString(DateMask,DateStringToDate(DateMask,StartDate)-1)
       +'.d'+copy(Rek^.Dat.kod,3,2));

c:=IOResult;
Reset (ClientDolgFile,SizeOf(ClientDolgType));
c:=IOResult;
If c<>0 Then
 Begin
  Dispose(ErrBox,Done);
  Dispose(TempBox,Done);
  MessageBox(^M+#3'Ошибка открытия '+Path^.Dat.TOarchiv+DateToDateString(DateMask,DateStringToDate(DateMask,StartDate)-1)
    +'.d'+copy(Rek^.Dat.kod,3,2),Nil,mfError+mfCancelButton);
  close(t);
  c:=IOResult;
  NoinfoMsg;
  Exit;
 End;

 While Not(Eof(ClientDolgFile)) Do
  Begin
   s:='';
   cOunt:=0;
   New(BufDlg,Init);
   BlockRead(ClientDolgFile,BufDlg^.Point,BufferClientDolgType,Count);
   For c1:=1 To Count Do
   Begin
   st:=BufDlg^.Point.Dat[c1].Kod;
   if TempBox^.List^.Count>=0 then
     for i:=0 to TempBox^.List^.Count-1 do
     Begin
        s:=TempBox^.GetText(i,TempBox^.List^.Count);
        s1:=Copy(s,1,CClientKod);

        DelSpace(s1);
        DelSpace(st);

        if st=s1 then
        begin
          find:=true;
          {долг на начало T}
          sSumma:=RealToStr(BufDlg^.Point.Dat[c1].DolgT,CIZena,CMantissa);
          rformat(sSumma,CIZena);
          System.Delete(s,POsDT,CIZena);
          System.Insert(sSumma,s,POsDT);
          {долг на начало }
          sSumma:=RealToStr(BufDlg^.Point.Dat[c1].Dolg,CIZena,CMantissa);
          rformat(sSumma,CIZena);
          System.Delete(s,POsD,CIZena);
          System.Insert(sSumma,s,POsD);

          TempBox^.List^.AtFree(i);
          TempBox^.SetRange(TempBox^.List^.Count);


          TempBox^.List^.Insert(NewStr(s));
          TempBox^.SetRange(TempBox^.List^.Count);
        End; {if st=s1 then}
      end;{for i:=0 to TempBox^.List^.Count-1}
     End; {For c1:=1 To Count Do}
     Dispose(BufDlg,Done);
  End;  {While Not(Eof(ClientDolgFile))}
NoInfoMsg;
(*   if (ClientDolgElement.Dolg>0.009) or (ClientDolgElement.DolgSF>0.009) then
   begin
    {долг на начало T}
    sSumma:=RealToStr(ClientDolgElement.DolgT,CIZena,CMantissa);
    rformat(sSumma,CIZena);
    s:=s+ssumma;
    {долг на начало }
    sSumma:=RealToStr(ClientDolgElement.Dolg,CIZena,CMantissa);
    rformat(sSumma,CIZena);
    s:=s+ssumma;

   {отгр}
    sSumma:='0';
    rformat(sSumma,CIZena);
    s:=s+ssumma;
    {скидки отгр}
    sSumma:='0';
    rformat(sSumma,CIZena);
    s:=s+ssumma;
    {возвр}
    sSumma:='0';
    rformat(sSumma,CIZena);
    s:=s+ssumma;
    {скидк возвр}
    sSumma:='0';
    rformat(sSumma,CIZena);
    s:=s+ssumma;
    {опл}
    sSumma:='0';
    rformat(sSumma,CIZena);
    s:=s+ssumma;
    {скидк оф конс}
    sSumma:='0';
    rformat(sSumma,CIZena);
    s:=s+ssumma;
    {расх откр конс}
    sSumma:='0';
    rformat(sSumma,CIZena);
    s:=s+ssumma;

    {долг на конец T}
    sSumma:='0';
    rformat(sSumma,CIZena);
    s:=s+ssumma;
    {долг на конец по оплате}
    sSumma:='0';
    rformat(sSumma,CIZena);
    s:=s+ssumma;

    TempBox^.List^.Insert(NewStr(s));
    TempBox^.SetRange(TempBox^.List^.Count);

   end;
 End;                                        *)

 c:=IOResult;
 Close(ClientDolgFile);
 c:=IOResult;

{Конечная дата------------------------------}
if not FExists(Path^.Dat.TOarchiv+StopDate+'.d'+copy(Rek^.Dat.kod,3,2)) and
   (DateStringToDate(DateMask,FDate)=DateStringToDate(DateMask,StopDate)) then
begin
DinfoMsg('Формирую список долгов за '+FDate,False);
 CalcDolgKon(TempBox);
NoInfoMsg;
end
ELSE
BEGIN
DinfoMsg('Формирую список долгов за '+StopDate,False);
Assign (ClientDolgFile,Path^.Dat.TOarchiv+StopDate+'.d'+copy(Rek^.Dat.kod,3,2));
c:=IOResult;
Reset (ClientDolgFile,SizeOf(ClientDolgType));
c:=IOResult;

If c<>0 Then
 Begin
  Dispose(ErrBox,Done);
  Dispose(TempBox,Done);
  MessageBox(^M+#3'Ошибка открытия '+Path^.Dat.TOarchiv+StopDate+'.d'+copy(Rek^.Dat.kod,3,2),Nil,mfError+mfCancelButton);
  close(t);
  c:=IOResult;
  NoinfoMsg;
  Exit;
 End;

 While Not(Eof(ClientDolgFile)) Do
  Begin
   cOunt:=0;
   New(BufDlg,Init);
   BlockRead(ClientDolgFile,BufDlg^.Point,BufferClientDolgType,Count);
   For c1:=1 To Count Do
   Begin
     st:=BufDlg^.Point.Dat[c1].Kod;
     {st:=ClientDolgElement.Kod;}
     find:=false;
     if (BufDlg^.Point.Dat[c1].Dolg>0.01) or (BufDlg^.Point.Dat[c1].DolgSF>0.01) then
     begin
     if TempBox^.List^.Count>=0 then
     for i:=0 to TempBox^.List^.Count-1 do
     Begin

        s1:=Copy(TempBox^.GetText(i,TempBox^.List^.Count),1,CClientKod);

        DelSpace(s1);
        DelSpace(st);

        if st=s1 then
        begin
          find:=true;
          s:='';
          s:=TempBox^.GetText(i,TempBox^.List^.Count);

          sSumma:=RealToStr(BufDlg^.Point.Dat[c1].DolgT,CIZena,CMantissa);
          rformat(sSumma,CIZena);

          System.Delete(s,PosOskKon,CIZena);
          System.Insert(sSumma,s,PosOskKon);

          sSumma:=RealToStr(BufDlg^.Point.Dat[c1].Dolg,CIZena,CMantissa);
          rformat(sSumma,CIZena);

          System.Delete(s,PosOskKonR,CIZena);
          System.Insert(sSumma,s,PosOskKonR);


          TempBox^.List^.AtFree(i);
          TempBox^.SetRange(TempBox^.List^.Count);

          TempBox^.List^.Insert(NewStr(s));
          TempBox^.SetRange(TempBox^.List^.Count);
          break;
        end; {if st=s1 then}

     end;  {for i:=0 to TempBox^.List^.Count-1}

        if not find then
        begin
          s:=st;
          {долг на начало T}
          sSumma:='0';
          rformat(sSumma,CIZena);
          s:=s+ssumma;
          {долг на начало }
          sSumma:='0';
          rformat(sSumma,CIZena);
          s:=s+ssumma;
          {отгр}
          sSumma:='0';
          rformat(sSumma,CIZena);
          s:=s+ssumma;
          {скидки отгр}
          sSumma:='0';
          rformat(sSumma,CIZena);
          s:=s+ssumma;
          {возвр}
          sSumma:='0';
          rformat(sSumma,CIZena);
          s:=s+ssumma;
          {скидк возвр}
          sSumma:='0';
          rformat(sSumma,CIZena);
          s:=s+ssumma;
          {опл}
          sSumma:='0';
          rformat(sSumma,CIZena);
          s:=s+ssumma;
          {скидк оф конс}
          sSumma:='0';
          rformat(sSumma,CIZena);
          s:=s+ssumma;
          {расх откр конс}
          sSumma:='0';
          rformat(sSumma,CIZena);
          s:=s+ssumma;
          {долг на конец T}
          sSumma:=RealToStr(BufDlg^.Point.Dat[c1].DolgT,CIZena,CMantissa);
          rformat(sSumma,CIZena);
          s:=s+ssumma;
          {долг на конец}
          sSumma:=RealToStr(BufDlg^.Point.Dat[c1].Dolg,CIZena,CMantissa);
          rformat(sSumma,CIZena);
          s:=s+ssumma;

          TempBox^.List^.Insert(NewStr(s));
          TempBox^.SetRange(TempBox^.List^.Count);
        end; {if not find then}
   End; {if (BufDlg^.Point.Dat[c1].Dolg>0.01)}
   End; {For c1:=1 To Count}
   Dispose(BufDlg,Done);
End; {While Not(Eof(ClientDolgFile)) Do}

c:=IOResult;
close(ClientDolgFile);
c:=IOResult;
NoInfoMsg;
END; {ELSE}

{Начало цикла по датам}
Start:=DateStringToDate(DateMask,StartDate);
Stop:=DateStringToDate(DateMask,StopDate);
for tek:=Start to Stop do
BEGIN
 sDate:=DateToDateString(DateMask,tek);
 {Отгрузки -----------------------------------------}
DinfoMsg('Просматривю отгрузки за '+SDate,False);
 New(m,Init);
 Assign (fm,Path^.Dat.ToMarket+sDate+'.mrk');
 c:=IOResult;
 Reset (fm,SizeOf(SuperMarketType));
 c:=IOResult;

 If c<>0 Then
  Begin
   ErrBox^.List^.Insert(NewStr(' Отсутствуют данные о продажах за '+sDate
        + ' "'+DayString[DayOfWeek(DateStringToDate(DateMask,sDate))]+'" '));
   ErrBox^.SetRange(TempBox^.List^.Count);
  End
 else
 Begin

 while not eof(fm) do
 begin
  {read(fm,m);}
  ReadBufMarket(fm,m,Count);
 for cc:=1 To Count do
 begin
  find:=true;
  {memc('1');}
  {если консигнационный документ}
  if (m^.Point.Dat[cc].Active) then
  if (m^.Point.Dat[cc].OperatorSelector=0) and (m^.Point.Dat[cc].DocSelector in [5,6,7,8]) then
  begin
    {memcc;}
    sKod:=m^.Point.Dat[cc].ClientKod;
    find:=false;
    for i:=0 to TempBox^.List^.Count-1 do
     Begin
        find:=true;
        s1:=Copy(TempBox^.GetText(i,TempBox^.List^.Count),1,CClientKod);
        Format(s1,CClientKOd);
        Format(sKod,CClientKOd);
        {клиент есть в списке}
        if sKod=s1 then
        begin
         s:=TempBox^.GetText(i,TempBox^.List^.Count);
         {Выдано}
         sSumma:=copy(TempBox^.GetText(i,TempBox^.List^.Count),PosOtgr,CIZena);
         Str(StrToReal(sSumma)+StrToReal(m^.Point.Dat[cc].SummaZ)+StrToReal(m^.Point.Dat[cc].Skidka):CIZena:CMantissa,sSumma);
         System.Delete(s,PosOtgr,CIZena);
         System.Insert(sSumma,s,PosOtgr);
         {Скидки}
         sSumma:=copy(TempBox^.GetText(i,TempBox^.List^.Count),PosSkOtgr,CIZena);
         Str(StrToReal(sSumma)+StrToReal(m^.Point.Dat[cc].Skidka):CIZena:CMantissa,sSumma);
         System.Delete(s,PosSkOtgr,CIZena);
         System.Insert(sSumma,s,PosSkOtgr);
         TempBox^.List^.AtFree(i);
         TempBox^.SetRange(TempBox^.List^.Count);
         TempBox^.List^.Insert(NewStr(s));
         TempBox^.SetRange(TempBox^.List^.Count);
         break;
        end;
     end; {for i:=0 to TempBox^.List^.Count-1}
  end;

    if not find then
    begin
     writeln(t,'Клиент '+sKod+' c отгрузкой '+m^.Point.Dat[cc].SummaZ+' от '+sDate+' отсутсвует в архиве долгов!!!');
    end;

  find:=true;
  if (m^.Point.Dat[cc].Active) then
  if (m^.Point.Dat[cc].OperatorSelector=0) and (m^.Point.Dat[cc].DocSelector in [0,1,3,4]) and m^.Point.Dat[cc].Realiz then
  begin
    sKod:=m^.Point.Dat[cc].ClientKod;
    find:=false;

    for i:=0 to TempBox^.List^.Count-1 do
     Begin
        s1:=Copy(TempBox^.GetText(i,TempBox^.List^.Count),1,CClientKod);
        Format(s1,CClientKOd);
        Format(sKod,CClientKOd);
        {клиент есть в списке}
        if sKod=s1 then
        begin
         find:=true;
         s:=TempBox^.GetText(i,TempBox^.List^.Count);
         {Скидки оформлен конс        }

         sSumma:=copy(TempBox^.GetText(i,TempBox^.List^.Count),PosSkOfCons,CIZena);
         Str(StrToReal(sSumma)+StrToReal(m^.Point.Dat[cc].Skidka):CIZena:CMantissa,sSumma);
         System.Delete(s,PosSkOfCons,CIZena);
         System.Insert(sSumma,s,PosSkOfCons);
         TempBox^.List^.AtFree(i);
         TempBox^.SetRange(TempBox^.List^.Count);
         TempBox^.List^.Insert(NewStr(s));
         TempBox^.SetRange(TempBox^.List^.Count);
         break;
        end;
     end; {for i:=0 to TempBox^.List^.Count-1}
    end;
    end;
    if not find then
    begin
     writeln(t,'Клиент '+m^.Point.Dat[cc].ClientKod+' c отгрузкой '+m^.Point.Dat[cc].SummaZ+' от '+sDate
        +' отсутсвует в архиве долгов!!!');

  end;
 end;

 end; {while not eof(fm) do}

 {memc('1');}
 Dispose(m,Done);
 {memc('2');}
 close(fm);
  NoInfoMsg;

 {Возвраты -----------------------------------------}
 DinfoMsg('Просматриваю возвраты за '+SDate,False);
 Assign(fv,Path^.Dat.ToReturn+ SDate +'.vzw');
 c:=IOResult;
 Reset (fv);
 c:=IOResult;

 If c<>0 Then
 Begin
   ErrBox^.List^.Insert(NewStr(' Отсутствуют данные о возвратах за '+sDate
       + ' "'+DayString[DayOfWeek(DateStringToDate(DateMask,sDate))]+'" '));
   ErrBox^.SetRange(TempBox^.List^.Count);
 End
 else
 Begin
   sRashodSumma:='0.0';

   while not eof(fv) do
     begin
       new(v,Init);
       read(fv,v^.Dat);
       sKod:=v^.Dat.MakeKod;

       find:=false;
       if (v^.Dat.OperatorSelector in [0,2]) then
       If (v^.Dat.VidDocument in [4,5]) Then
       for i:=0 to TempBox^.List^.Count-1 do
       Begin
          find:=true;
          s1:=Copy(TempBox^.GetText(i,TempBox^.List^.Count),1,CClientKod);
          Format(s1,CClientKOd);
          Format(sKod,CClientKOd);
          sRashodSumma:='0.0';

          {клиент есть в списке}
          if sKod=s1 then
          begin
            s:=TempBox^.GetText(i,TempBox^.List^.Count);

            if v^.Dat.Rashod then sRashodSumma:=v^.Dat.RashodSumma;

            {величина возврата}
            sSumma:=copy(TempBox^.GetText(i,TempBox^.List^.Count),PosReturn,CIZena);
            Str(StrToReal(sSumma)+StrToReal(v^.Dat.SummaR)
            {  +StrToReal(sRashodSumma)}:CIZena:CMantissa,sSumma);
            System.Delete(s,PosReturn,CIZena);
            System.Insert(sSumma,s,PosReturn);
             {скидка возврата}
            sSumma:=copy(TempBox^.GetText(i,TempBox^.List^.Count),PosSkReturn,CIZena);
            Str(StrToReal(sSumma)+StrToReal(v^.Dat.Skidka):CIZena:CMantissa,sSumma);
            {writeln(ssumma);
            readln;}
            System.Delete(s,PosSkReturn,CIZena);
            System.Insert(sSumma,s,PosSkReturn);
                    {Расход откр конс}
            sSumma:=sRashodSumma;
            rformat(sSumma,CIZena);
            System.Delete(s,PosRashOtCons,CIZena);
            System.Insert(sSumma,s,PosRashOtCons);

           TempBox^.List^.AtFree(i);
           TempBox^.SetRange(TempBox^.List^.Count);
           TempBox^.List^.Insert(NewStr(s));
           TempBox^.SetRange(TempBox^.List^.Count);
           break;

           end; {if sKod=s1}

        end;  {for i:=0 to TempBox^.List^.Count-1}
        Dispose(v,Done);
     end; {while not eof(fv)}
 end;

  close(fv);
 NoInfoMsg;
 {Оплаты -----------------------------------------}
 DinfoMsg('Просматриваю оплаты за '+SDate,False);
 New(o,Init);
 Assign (fo,Path^.Dat.ToOplata+sDate+'.opl');
 c:=IOResult;
 Reset (fo,SizeOf(OplataRealizasiaType));
 c:=IOResult;

 If c<>0 Then
  Begin
   ErrBox^.List^.Insert(NewStr(' Отсутствуют данные об оплатах за '+sDate
       + ' "'+DayString[DayOfWeek(DateStringToDate(DateMask,sDate))]+'" '));
   ErrBox^.SetRange(TempBox^.List^.Count);
  End
 else
 begin

 while not eof(fo) do
 begin
  {read(fo,o);}
  ReadBufOplata(fo,o,Count);
 for cc:=1 to count do
  begin
    sKod:=o^.Point.Dat[cc].ClientKod;
    find:=false;
    for i:=0 to TempBox^.List^.Count-1 do
     Begin
        find:=true;
        s1:=Copy(TempBox^.GetText(i,TempBox^.List^.Count),1,CClientKod);
        Format(s1,CClientKOd);
        Format(sKod,CClientKOd);
        sRashodSumma:='0.0';
        {клиент есть в списке}
        if sKod=s1 then
        begin
         s:=TempBox^.GetText(i,TempBox^.List^.Count);
         {Возвраты}
       (*  if o^.Point.Dat[cc].Vozwrat then
         begin
           Assign(fv,Path^.Dat.ToReturn+o^.Point.Dat[cc].DocDateReturn+'.vzw');
           c:=IOResult;
           Reset (fv);
           c:=IOResult;

           If c<>0 Then
           Begin
              dISPOSE(eRRbOX,dONE);
              Dispose(TempBox,Done);
              Dispose(o,Done);
              MessageBox(^M+#3'Ошибка открытия '+Path^.Dat.ToReturn+o^.Point.Dat[cc].DocDateReturn+'.vzw',
                     Nil,mfError+mfCancelButton);
                close(t);
                NoinfoMsg;
                Exit;
           End;
           sRashodSumma:='0.0';
           while not eof(fv) do
           begin
             read(fv,v);
             DelSpace(o^.Point.Dat[cc].DocNumerReturn);
             DelSpace(v.Document);
             if o^.Point.Dat[cc].DocNumerReturn=v.Document then
             Begin
              If (v.VidDocument in [4,5]) Then
               if v.Rashod then sRashodSumma:=v.RashodSumma;
               break;
             end;
           end;
           close(fv);
          {величина возврата}
          sSumma:=copy(TempBox^.GetText(i,TempBox^.List^.Count),PosReturn,CIZena);
          Str(StrToReal(sSumma)+StrToReal(o^.Point.Dat[cc].SummaZ)
          {+StrToReal(sRashodSumma)}:CIZena:CMantissa,sSumma);
          System.Delete(s,PosReturn,CIZena);
          System.Insert(sSumma,s,PosReturn);
          {скидка возврата}
          sSumma:=copy(TempBox^.GetText(i,TempBox^.List^.Count),PosSkReturn,CIZena);
          Str(StrToReal(sSumma)+StrToReal(o^.Point.Dat[cc].Skidka):CIZena:CMantissa,sSumma);
          {writeln(ssumma);
          readln;}
          System.Delete(s,PosSkReturn,CIZena);
          System.Insert(sSumma,s,PosSkReturn);
                    {Расход откр конс}
          sSumma:=sRashodSumma;
          rformat(sSumma,CIZena);
          System.Delete(s,PosRashOtCons,CIZena);
          System.Insert(sSumma,s,PosRashOtCons)

         end
         else *)
         {Оплаты}
         if not o^.Point.Dat[cc].Vozwrat then
         begin
          sSumma:=copy(TempBox^.GetText(i,TempBox^.List^.Count),PosOpl,CIZena);
          Str(StrToReal(sSumma)+StrToReal(o^.Point.Dat[cc].SummaZ)-StrToReal(o^.Point.Dat[cc].Skidka):CIZena:CMantissa,sSumma);
          System.Delete(s,PosOpl,CIZena);
          System.Insert(sSumma,s,PosOpl);
         end;

         TempBox^.List^.AtFree(i);
         TempBox^.SetRange(TempBox^.List^.Count);
         TempBox^.List^.Insert(NewStr(s));
         TempBox^.SetRange(TempBox^.List^.Count);
         break;
        end;
     end; {for i:=0 to TempBox^.List^.Count-1}

    if not find then
    begin
     write(t,'Клиент '+sKod);
     if o^.Point.Dat[cc].Vozwrat then write(t,' с возвратом ')
     else write(t,' с оплатой ');
     writeln(t,o^.Point.Dat[cc].SummaZ+' отсутсвует в архиве долгов!!!');
    end;

  end; {if (m.OperatorSelector=0) and m.Realiz}

 end; {while not eof(fm) do}
 close(fo);
 end;
 Dispose(o,Done);
 NoInfoMsg;
END;

DinfoMsg('Формирую отчет ...'+StopDate,False);
 Writeln(T,Header+'Склад:'+FormKod(Rek^.Dat.Kod)+' Оператор: '+CurrentPassword);
 Writeln(T,'Дата и время расчета: '+FDate+'  ('+Times+')');
 Write(T,'Вид отчета: ');
  IF  not RaznOnly then
   Writeln(t,'{Полный отчет}')
   else Writeln(t,'{Только разногласия}');


 writeln(t);
 write(t,'БАЛАНСИРОВКА КОНСИГНАЦИОННЫХ ОПЕРАЦИЙ');
 writeln(t,' за период с '+StartDate+' по '+StopDate );
 writeln(t);
Writeln(t,GlobalPrn^.Dat.Condensed2[Nprint^.DAt.Printer]);
Writeln(T,'┌────┬─────────────────────────────────────────────┬──────────┬──────────┬──────────┬──────────┬──────────┬'
+'──────────┬──────────┬──────────┬──────────┬──────────┬──────────┬──────────┬──────────┐');
Writeln(T,'│ Код│Наименование клиента                         │Долг предТ│ Долг пред│  Отгрузка│  Cк. отгр│   Возврат│'
+'  Ск. воз.│    Оплата│Ск.оф.конс│Расх.о.кон│    Долг Т│      Долг│  Ошибка T│    Ошибка│');
Writeln(T,'└────┴─────────────────────────────────────────────┴──────────┴──────────┴──────────┴──────────┴──────────┴'
+'──────────┴──────────┴──────────┴──────────┴──────────┴──────────┴──────────┴──────────┘'+
+HeaderStop);


 for i:=0 to TempBox^.List^.Count-1 do
 begin
   s:=TempBox^.GetText(i,TempBox^.List^.Count);
   raznt:=StrToReal(copy(s,PosDT,CIZena))+
          StrToReal(copy(s,PosOtgr,CIZena))-
          StrToReal(copy(s,PosReturn,CIZena))+
          StrToReal(copy(s,PosRashOtCons,CIZena))-
          StrToReal(copy(s,PosOpl,CIZena))-
          StrToReal(copy(s,PosSkOfCons,CIZena))-
          StrToReal(copy(s,PosOskKon,CIZena));

   razn:=StrToReal(copy(s,PosD,CIZena))+
         StrToReal(copy(s,PosOtgr,CIZena))-
         StrToReal(copy(s,PosSkOtgr,CIZena))-
         StrToReal(copy(s,PosReturn,CIZena))+
         StrToReal(copy(s,PosSkReturn,CIZena))-
         StrToReal(copy(s,PosOpl,CIZena))-
         StrToReal(copy(s,PosOskKonR,CIZena))+
         StrToReal(copy(s,PosRashOtCons,CIZena));

   if StrToReal(copy(s,PosDT,CIZena))+
      StrToReal(copy(s,PosD,CIZena))+
      StrToReal(copy(s,PosOtgr,CIZena))+
      StrToReal(copy(s,PosSkOtgr,CIZena))+
      StrToReal(copy(s,PosReturn,CIZena))+
      StrToReal(copy(s,PosRashOtCons,CIZena))+
      StrToReal(copy(s,PosSkReturn,CIZena))+
      StrToReal(copy(s,PosOpl,CIZena))+
      StrToReal(copy(s,PosSkOfCons,CIZena))+
      StrToReal(copy(s,PosOskKon,CIZena))+
      StrToReal(copy(s,PosOskKonR,CIZena)) > 0.009 then

   if(((abs(raznt)>0.009) or (abs(razn)>0.009)) and RaznOnly) or not RaznOnly then
   Begin
     sKOd:=copy(s,1,CClientKod);
     sName:=GetClientField(FFullClient,sKOd,0);
     Format(sName,CaLL);
     ws:='';
     ws:=ws+' '+sKod+SeparatorChar;
     ws:=ws+sName+SeparatorChar;
     PrintSumma:=copy(s,PosDT,CIZena);
     rformat(PrintSumma,10);
     ws:=ws+PrintSumma+SeparatorChar;
     PrintSumma:=copy(s,PosD,CIZena);
     rformat(PrintSumma,10);
     ws:=ws+PrintSumma+SeparatorChar;
     PrintSumma:=copy(s,PosOtgr,CIZena);
     rformat(PrintSumma,10);
     ws:=ws+PrintSumma+SeparatorChar;
     PrintSumma:=copy(s,PosSkOtgr,CIZena);
     rformat(PrintSumma,10);
     ws:=ws+PrintSumma+SeparatorChar;
     PrintSumma:=copy(s,PosReturn,CIZena);
     rformat(PrintSumma,10);
     ws:=ws+PrintSumma+SeparatorChar;
     PrintSumma:=copy(s,PosSkReturn,CIZena);
     rformat(PrintSumma,10);
     ws:=ws+PrintSumma+SeparatorChar;
     PrintSumma:=copy(s,PosOpl,CIZena);
     rformat(PrintSumma,10);
     ws:=ws+PrintSumma+SeparatorChar;
     PrintSumma:=copy(s,PosSkOfCons,CIZena);
     rformat(PrintSumma,10);
     ws:=ws+PrintSumma+SeparatorChar;
     PrintSumma:=copy(s,PosRashOtCons,CIZena);
     rformat(PrintSumma,10);
     ws:=ws+PrintSumma+SeparatorChar;
     PrintSumma:=copy(s,PosOskKon,CIZena);
     rformat(PrintSumma,10);
     ws:=ws+PrintSumma+SeparatorChar;
     PrintSumma:=copy(s,PosOskKonR,CIZena);
     rformat(PrintSumma,10);
     ws:=ws+PrintSumma+SeparatorChar;

     WRITE(t,wS);
     write(t,raznt:10:CMantissa);
     WRITE(t,SeparatorChar);
     write(t,razn:10:CMantissa);
     WRITELN(t,SeparatorChar)

   end;
 end;

 Writeln(T,'_________________________________________________________________________________________________________________'
 +'__________________________________________________________________________________');
 Writeln(T);

 If ErrBox^.List^.Count>0 then
 begin
   Writeln(t,' ВНИМАНИЕ !');
   for i:=0 to ErrBox^.List^.Count-1 do
    writeln(t,ErrBox^.GetText(i,ErrBox^.List^.Count));
 end;

 Writeln(t);
 Writeln(T,'Отпечатано: '+TodayString(DateMask)+'('+Times+')');
 Writeln(t,'========================================================================================================'+
 GlobalPrn^.Dat.NoCondensed[Nprint^.DAt.Printer]);
 NoInfoMsg;
 close(t);
 Dispose(TempBox,Done);
 Dispose(ErrBox,Done);
 ViewAsText(Path^.Dat.TOTemp+'testdlg.txt','Балансировка консигнационных операций с '+StartDate+' по '+StopDate,True);
 {ReportNew(Path^.Dat.ToTemp+'testdlg.txt','',1,False,False);}
End;

BEGIN
END.