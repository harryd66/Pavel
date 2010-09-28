{$I Compile.INC}

{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}
Unit ViewPrh;


Interface

Uses Glob,ServStr,Dialogs,MyCalc,Drivers;



Type
  PFullScreenPrh = ^TFullScreenPrh;
  TFullScreenPrh = object(TDialog)
       Numer      : ArtikulStr;
       Date       : TDateString;
       ClientKod  : ArtikulStr;
       Calc        : PMyCalculator;
      Function FullScreenPrh(Ass:DocumentEditZ):Boolean;
      procedure DrawCurrent;
      procedure Refresh;
      procedure HandleEvent(var Event: TEvent); virtual;
      Destructor Done;Virtual;
  end;





implementation

Uses Serv,Objects,DbEngine,MsgBox,NetDbEng,Protect,TpDate,Utils1,
     NetCall,Net,WinDos,Access1,Vision5,Utils,DbEngin2,Access,ServStr2,
     Views,ColorTxt,Validate,App,Printers,Vision8,Vision4,Tools,Prise;


Var
    ControlAg,ControlDoc,ControlAllR,ControlAllPAckR,
    Control1,ControlFullName,ControlNMake,ControlOtdel,ControlDo,
    ControlVirabotano,ControlMArka,ControlPack,ControlPost,
    ControlFirmaPost,ControlNGTD,ControlRegion,ControlShKod,
    ControlAkzisSbor,
    ControlAkzis,ControlNSertif,ControlProz1,ControlProz2  :PView;

    PrhWin : PFullScreenPrh;
    WindowList,ScreenList,NoScreenList2,NoScreenList3 : PBox;
    PrevCurrent : String;






Function TFullScreenPrh.FullScreenPrh(Ass:DocumentEditZ):Boolean;
var
  R : TRect;
  ws,s : String;
  AgName,ClName : AllStr;
  c,i,j : Word;
  ff,ff1,ff2 : String;
  F : PrihodFileType;
  E :PPrihodType;
  Find:Boolean;
  SKolish,SDoc,SClientKod,SAgentKod : ArtikulStr;
    SMarka,SNGTD,SExpert,
    sPost,sFirmaPost,SCommentr : String;
    SDate : TDateString;
    ws1,WspomSkidka:String[CIZena];
    Res : Word;
    P : PCommentClientType;
    DDD3,DDD4,DDD,DDD2,Status : AllStr;
    Color : Word;
    AssZ:DocumentEditZ;
    L : PZakazType;
    BArter : AllStr;
    B,BS : PBazType;
    POstawshik : AllStr;
    SProz1,SProz2 : ArtikulStr;


begin
  FullScreenPrh:=False;

  Find := False;

  DInfoMsg('Ищу документ...',True);

  ClearChar(Ass.EditPosition);
  DelSpace(Ass.D);

  AssZ.EditPosition:=Ass.EditPosition;
  AssZ.D:=Ass.D;


  Assign(f,Path^.Dat.ToPrihod+AssZ.D+'.prh');
  c:=IoResult;
  Reset(f);
  c:=IoResult;
  If c<>0 Then
   Begin
    NoInfoMsg;
    MessageBox(^M+#3'Ошибка открытия файла '+Path^.Dat.ToPrihod+AssZ.D+'.prh!'+
    ' Код: '+IntToStr(c,3),Nil,mfError+mfCancelButton);
    Exit;
   End;


  Find := False;
  New(E,Init);


{оптимизация поиск}
   If FileSize(f)>=(StrToInt(Ass.EditPosition)-1) Then
    Begin
     Seek(f,StrToInt(Ass.EditPosition)-1);
     ReadPrihod(F,E);
     DelSpace(E^.DAt.Document);
     DelZerro(E^.Dat.Document);
     ClearChar(E^.Dat.Document);
     If (E^.Dat.DateC=Ass.D) and
     (StrToInt(E^.Dat.Document)=StrToInt(Ass.EditPosition)) Then
            Begin
             Find:=True;
         End
         Else Seek(F,0);
    End;



  While Not(Eof(f)) And Not(Find) Do
   Begin
    ReadPrihod(F,E);
    ClearChar(E^.Dat.Document);
    If (E^.Dat.DateC=Ass.D) and
    (StrToInt(E^.Dat.Document)=StrToInt(Ass.EditPosition)) Then
          Begin
           Find:=True;
           Break;
          End;
   End;
   System.Close(f);



   NoInfoMsg;



If Not Find Then
  Begin
   Dispose(E,Done);
   NoInfoMsg;
   MessageBox(#3^M+#3'Документ прихода N '+Ass.EditPosition+' от '+Ass.D+' не найден!',Nil,mfError+mfCancelButton);
   Exit;
  End;



DInfoMsg('Формирую документы...',True);
ClearFind;

{список с товаром
{12345678901234567890123456│12345│123│12345│1234567890│1234567890│12345678│123456789012345678│
12345│12345│12345│12345│12345│12345│12345│12345│}
{список с полными наименованиями}
{ наименование
  Код
  Код сертификата
  Марка региональная
  Акциз/Серия
  ГТД
  Страна произв
  Фирма производитель
  Выработано
  До
  NMakeKod
  непосред.код поставщика}
{12345678901234567890123456789012345678901234567890123│12345│0│1234567890123456789012345678901234567890│1234567890123456789012
345678901234567890│123456789012345│12345678901234567890123456789012345│12345678│12345678│12345678901234567890│12345}
{список с сертификатами на которые есть ссылка
 Полное название сертификаты
 Код}
{12345678901234567890123456789012345678901234567890123│12345│

}


{Формируем список позиций в перемешку товар и сертификаты}
  {список с товаром}
  R.Assign(0,0,0,0);
  ScreenList := New(PBox, Init(R, 1, Nil));
  ScreenList^.NewList(New(PTextCollection, Init(0,1)));
  {список с полными наименованиями}
  R.Assign(0,0,0,0);
  NoScreenList2 := New(PBox, Init(R, 1, Nil));
  NoScreenList2^.NewList(New(PTextCollection, Init(0,1)));
  {список с сертификатами на которые есть ссылка}
  R.Assign(0,0,0,0);
  NoScreenList3 := New(PBox, Init(R, 1, Nil));
  NoScreenList3^.NewList(New(PTextCollection, Init(0,1)));

{вставляем в список товары}
For c:=1 To E^.Dat.Amount Do
 Begin
  New(B,Init);

 With E^.Dat.PrihodElement[c] Do
  Begin
   B^.Dat.BAzKod:=BazKod;
   GetBazElement(BazKod,B^.DAt);

   If GetRazdelStatus(BazKod) Then  B^.Dat.Name:=#254+B^.Dat.Name;
   Format(B^.Dat.Name,CNAme);
   DelSpace(B^.DAt.InPack);
   RFormat(B^.DAt.InPack,CInPAck);
   Format(B^.DAt.Litr,CLitr);
   MyStr(StrToREal(Input.R_Zena),CZena,CMantissa,Input.R_Zena);
   MyStr(StrToREal(Input.Spec_Zena),CZena,CMantissa,Input.Spec_Zena);
   MyStr(StrToREal(Input.AkzisSbor),CZenaZ,CMantissaZ,Input.AkzisSbor);

If ((EnableZakupka=1))  Then
Begin
   MyStr(StrToREal(Input.Zakupka),CZenaZ,CMantissaZ,Input.Zakupka);
   MyStr(StrToREal(Input.Zakupka2),CZenaZ,CMantissaZ,Input.Zakupka2);
End
Else
 Begin
  Input.Zakupka:=CodeZakupka;
  Input.Zakupka2:=CodeZakupka;
 End;

{$IFDEF Pharm}
  Input.Zakupka2:=Input.Spec_Zena;
  MyStr(StrToREal(Input.Zakupka2),CZenaZ,CMantissaZ,Input.Zakupka2);
{$ENDIF}


   DelSpace(Input.Kol);
   RFormat(Input.Kol,CKol);


   SMarka:=GetMarkaField(FMarka,Input.Marka)+' ['+Input.Marka+']';
   Format(SMarka,CNSertif);

   SNGTD:=GetNGTDField(FNGTD,Input.NGTD)+' ['+Input.NGTD+']';
   Format(SNGTD,CNSertif);

   sPost:=GetPostField(FPost,B^.Dat.PostKod)+' ['+B^.Dat.PostKod+']';
   Format(SPost,CPost);
   sFirmaPost:=GetFirmaPostField(FFirmaPost,B^.Dat.FirmaPostKod)+' ['+B^.Dat.FirmaPostKod+']';
   Format(SFirmaPost,CFirmaPost);

   sExpert:=GetExpertField(FExpert,Input.Expert);
   DelSpaceRight(SExpert);
   SExpert:=SExpert+' ['+Input.Expert+']';
   Format(SExpert,CExpert);
   RFormatZerro(Input.NMAkeKod,CArtikul);
   Format(Input.Virabotano,CDAte);
   Format(Input.Godnost,CDAte);
   Format(Input.StrihKod,CStrihKod);

   ws[0]:=#0;
   For j:=1 To CDivision Do
    Begin
     DelSpace(Input.Division[j]);
     RFormat(Input.Division[j],CKOl);
     ws:=ws+Input.Division[j]+'│';
    End;

   {готовим сроку для экранного списка}
   s:=B^.Dat.NAme+'│'+BazKod+'│'+B^.Dat.InPack+'│'+B^.Dat.Litr+'│'+Input.Kol+
   '│'+Input.R_Zena+'│'+Input.Zakupka+'│'+Input.Zakupka2+'│'+Input.StrihKod+'│'+ws+
   '│'+Input.AkzisSbor+'│'+SExpert;
   ScreenList^.List^.Insert(NewStr(s));
   ScreenList^.SetRange(ScreenList^.List^.Count);

   {готовим строку для списка с полными наименованиями}
{ наименование
  Код
  Код сертификата
  Марка региональная
  Акциз/Серия
  ГТД
  Страна произв
  Фирма производитель
  Выработано
  До
  NMakeKod
  непосред.код поставщика}

  DelSpaceRight(B^.Dat.Name);
  S[0]:=#0;
  s:=B^.Dat.Name+' '+B^.Dat.Name2;
  Format(s,CNAme+1+CNAme);
  Postawshik:=GetMakeField(FClient,Copy(Input.NMakeKod,2,CClientKod),
                  StrToInt(Copy(Input.NMakeKod,1,1)));
  Format(Postawshik,CClient);

  s:=s+'│'+BazKod+'│'+Input.NSertif+'│'+IntToStr(Input.RegionMarka,COne)+'│'+
  SMarka+'│'+
  SNGTD+'│'+sPost+'│'+sFirmaPost+'│'+Input.Virabotano+'│'+
  Input.Godnost+'│'+Postawshik+'│'+Input.NMAkeKod+'│'+Input.AkzisSbor+'│'+SExpert;
  NoScreenList2^.List^.Insert(NewStr(s));
  NoScreenList2^.SetRange(NoScreenList2^.List^.Count);

  {если сертификата нет в списке}
  If TestElement(InPut.NSertif,NoScreenList3) Then
   Begin
    New(Bs,Init);
    RFormatZerro(Input.NSertif,CArtikul);
    BS^.DAt.BAzKod:=Input.NSertif;
    GetBAzElement(Input.NSertif,BS^.Dat);

    s[0]:=#0;
    s:=BS^.Dat.Name+' '+BS^.Dat.Name2;
    Format(s,CNAme+1+CNAme);
    s:=s+'│'+Input.NSertif;
    NoScreenList3^.List^.Insert(NewStr(s));
    NoScreenList3^.SetRange(NoScreenList3^.List^.Count);

    Dispose(BS,Done);
   End;

  End;{With}

  Dispose(B,Done);
End;{For}


DelSpace(E^.Dat.Document);

R.Assign(0, 0, 80, 23);
New(PrhWin, Init(R, 'Просмотр прихода'));
PrhWin^.HelpCtx:=$F336;
PrhWin^.Numer:=E^.Dat.Document;
PrhWin^.Date:=E^.Dat.DateC;
PrhWin^.ClientKod:=IntToStr(E^.DAt.OperatorSelector,COne)+E^.Dat.MAkeKod;

s:='Документ:'+E^.DAt.Document+' от '+E^.Dat.DateC;
R.Assign(1, 0, 2+Ord(s[0])+1, 1);
Control1 := New(PColoredText, Init(R, #3+s, $4E));
PrhWin^.Insert(Control1);

R.Assign(60, 0, 78, 1);
Control1 := New(PColoredText, Init(R, #3+'Всего позиций:'+IntToStr(E^.DAt.Amount,CMAntissa), $4E));
PrhWin^.Insert(Control1);

R.Assign(1, 1, 11, 2);
Control1 := New(PColoredText, Init(R, 'Поставщик:', $74));
PrhWin^.Insert(Control1);

Postawshik:=GetMAkeField(FMAke,E^.DAt.MAkeKod,E^.DAt.OperatorSelector);
Format(Postawshik,CClient);

R.Assign(11, 1, 38, 2);
Control1 := New(PColoredText, Init(R, #3+Postawshik+'│'+E^.DAt.MakeKod, $1F));
PrhWin^.Insert(Control1);

R.Assign(39, 1, 52, 2);
Control1 := New(PColoredText, Init(R, 'Вид операции:', $74));
PrhWin^.Insert(Control1);

R.Assign(52, 1, 58, 2);
Case E^.DAt.OperatorSelector Of
0:Postawshik:='Клиент';
1:Postawshik:='Склад';
2:Postawshik:='Обмен';
Else Postawshik[0]:=#0;;
End;
Control1 := New(PColoredText, Init(R, #3+Postawshik, $7E));
PrhWin^.Insert(Control1);


R.Assign(59, 1, 66, 2);
Control1 := New(PColoredText, Init(R, 'Статус:', $74));
PrhWin^.Insert(Control1);


Case E^.DAt.StatusDoc Of
0:Postawshik:='Введен на скл';
1:Postawshik:='Буфер';
Else Postawshik[0]:=#0;;
End;

R.Assign(66, 1, 79, 2);
Control1 := New(PColoredText, Init(R, #3+Postawshik, $5E));
PrhWin^.Insert(Control1);

R.Assign(33, 17, 42, 18);
Control1 := New(PColoredText, Init(R, 'Оператор:', $74));
PrhWin^.Insert(Control1);

R.Assign(42, 17, 54, 18);
Control1 := New(PColoredText, Init(R, #3+GetOperatorField(FNAme,E^.Dat.CAption), $4E));
PrhWin^.Insert(Control1);


MyStr(StrToReal(E^.DAt.SummaZakupka),CIZena,CMAntissaZ,E^.DAt.SummaZakupka);
DelSpace(E^.DAt.SummaZakupka);
MyStr(StrToReal(E^.DAt.SummaZakupka2),CIZena,CMAntissaZ,E^.DAt.SummaZakupka2);
DelSpace(E^.DAt.SummaZakupka2);
MyStr(StrToReal(E^.DAt.SummaR),CIZena,CMAntissa,E^.DAt.SummaR);
DelSpace(E^.DAt.SummaR);

MyStr(StrToReal(E^.DAt.SummaL),CIZena,CLitrMAntissa,E^.DAt.SummaL);
DelSpace(E^.DAt.SummaL);

SProz1:='???';
SProz2:='???';

  If StrToReal(E^.DAt.SummaZakupka)>0.0009 Then
   BEgin
    MyStr((StrToReal(E^.DAt.SummaR)-StrToReal(E^.DAt.SummaZakupka))/StrToReal(E^.DAt.SummaZakupka)*100,CLitr,CMantissa,SProz1);
    DelSpace(SProz1);
    SProz1:=SProz1+'%';
   End;

  If StrToReal(E^.DAt.SummaZakupka2)>0.0009 Then
   BEgin
    MyStr((StrToReal(E^.DAt.SummaR)-StrToReal(E^.DAt.SummaZakupka2))/StrToReal(E^.DAt.SummaZakupka2)*100,CLitr,CMantissa,
    SProz2);
    DelSpace(SProz2);
    SProz2:=SProz2+'%';
   End;

{$IFDEF Pharm}
If (EnableZakupka=1)  Then
s:=#3+' ЗЦ:'+E^.DAt.SummaZakupka+' ('+SProz1+')'+'  РЦ:'+
E^.DAt.SummaR+'  ('+E^.DAt.SummaL+'л)'
Else
s:=#3+' Р/Ц:'+E^.DAt.SummaR+'  ('+E^.DAt.SummaL+'л)';
{$ELSE}
If (EnableZakupka=1) Then
s:=#3+' ЗЦ:'+E^.DAt.SummaZakupka+' ('+SProz1+')'+' ЗЦ2:'+E^.DAt.SummaZakupka2+' ('+SProz2+')'+'  РЦ:'+
E^.DAt.SummaR+'  ('+E^.DAt.SummaL+'л)'
Else
s:=#3+' Р/Ц:'+E^.DAt.SummaR+'  ('+E^.DAt.SummaL+'л)';
{$ENDIF}

R.Assign(2, 22, 2+Ord(s[0])+1, 23);
Control1 := New(PColoredText, Init(R, s, $4E));
Control1^.Options := Control1^.Options or ofCenterX;
PrhWin^.Insert(Control1);




R.Assign(80, 3, 81, 15);
Control1 := New(PScrollBar, Init(R));
PrhWin^.Insert(Control1);

R.Assign(0, 3, 80, 15);
WindowList := New(PBox, Init(R, 1, PScrollbar(Control1)));
WindowList^.NewList(New(PTextCollection, Init(0,1)));
If ScreenList^.List^.Count>0 Then
 For c:=0 To ScreenList^.List^.Count-1 Do
  Begin
   s:=ScreenList^.GetTExt(c,ScreenList^.List^.Count);
   WindowList^.List^.Insert(NewStr(s));
   WindowList^.SetRange(WindowList^.List^.Count);
  End;

PrhWin^.Insert(WindowList);
WindowList^.FocusItem(0);


  R.Assign(1, 2, 79, 3);
{$IFDEF Pharm}
  PrhWin^.Insert(New(PLabel, Init(R, 'Наименование товара        Код  Фас Литр  Колич.  Р/Цена   З/Цена    Спец.цен',
  WindowList)));
{$Else}
  PrhWin^.Insert(New(PLabel, Init(R, 'Наименование товара        Код  Фас Литр  Колич.  Р/Цена   З/Цена    З/Цена 2',
  WindowList)));
{$EndIf}

R.Assign(2, 15, 56, 16);
ControlFullName := New(PColoredText, Init(R, '???', $7E));
PrhWin^.Insert(ControlFullName);

R.Assign(2, 16, 49, 17);
ControlOtdel := New(PColoredText, Init(R, '???', $71));
PrhWin^.Insert(ControlOtdel);


R.Assign(1, 17, 11, 18);
Control1 := New(PColoredText, Init(R, 'Поставщик:', $74));
PrhWin^.Insert(Control1);

R.Assign(11, 17, 31, 18);
ControlNMake := New(PColoredText, Init(R, '???', $7E));
PrhWin^.Insert(ControlNMake);

R.Assign(68, 16, 74, 17);
Control1 := New(PColoredText, Init(R, 'Марка:', $74));
PrhWin^.Insert(Control1);


R.Assign(74, 16, 78, 17);
ControlRegion := New(PColoredText, Init(R, '???', $74));
PrhWin^.Insert(ControlRegion);

R.Assign(56, 17, 65, 18);
Control1 := New(PColoredText, Init(R, 'Упаковок:', $71));
PrhWin^.Insert(Control1);

R.Assign(65, 17, 74, 18);
ControlPack := New(PColoredText, Init(R, '???', $7E));
PrhWin^.Insert(ControlPack);

R.Assign(1, 18, 5, 19);
Control1 := New(PColoredText, Init(R, 'ГТД:', $74));
PrhWin^.Insert(Control1);

R.Assign(5, 18, 45, 19);
ControlNGTD := New(PColoredText, Init(R, '???', $7E));
PrhWin^.Insert(ControlNGTD);


R.Assign(48, 18, 58, 19);
Control1 := New(PColoredText, Init(R, 'Штрих-код:', $74));
PrhWin^.Insert(Control1);

R.Assign(58, 18, 76, 19);
ControlShKod := New(PColoredText, Init(R, '???', $7E));
PrhWin^.Insert(ControlShKod);

R.Assign(1, 19, 8, 20);
Control1 := New(PColoredText, Init(R, 'Страна:', $74));
PrhWin^.Insert(Control1);

R.Assign(8, 19, 23, 20);
ControlPost := New(PColoredText, Init(R, '???', $7E));
PrhWin^.Insert(ControlPost);

R.Assign(24, 19, 44, 20);
Control1 := New(PColoredText, Init(R, 'Фирма-производитель:', $74));
PrhWin^.Insert(Control1);

R.Assign(44, 19, 79, 20);
ControlFirmaPost := New(PColoredText, Init(R, '???', $7E));
PrhWin^.Insert(ControlFirmaPost);

R.Assign(1, 20, 7, 21);
Control1 := New(PColoredText, Init(R, Seria_Akzis^+':', $74));
PrhWin^.Insert(Control1);

R.Assign(7, 20, 47, 21);
ControlAkzis := New(PColoredText, Init(R, '???', $7E));
PrhWin^.Insert(ControlAkzis);

R.Assign(48, 20, 59, 21);
Control1 := New(PColoredText, Init(R, 'Выработано:', $74));
PrhWin^.Insert(Control1);

R.Assign(59, 20, 67, 21);
ControlVirabotano := New(PColoredText, Init(R, '???', $7E));
PrhWin^.Insert(ControlVirabotano);

R.Assign(68, 20, 71, 21);
Control1 := New(PColoredText, Init(R, 'До:', $74));
PrhWin^.Insert(Control1);

R.Assign(71, 20, 79, 21);
ControlDo := New(PColoredText, Init(R, '???', $7E));
PrhWin^.Insert(ControlDo);

R.Assign(1, 21, 12, 22);
Control1 := New(PColoredText, Init(R, 'Сертификат:', $74));
PrhWin^.Insert(Control1);

R.Assign(12, 21, 73, 22);
ControlNSertif := New(PColoredText, Init(R, '???', $7E));
PrhWin^.Insert(ControlNSertif);

R.Assign(58, 15, 61, 16);
Control1 := New(PColoredText, Init(R, '%1:', $74));
PrhWin^.Insert(Control1);

R.Assign(61, 15, 67, 16);
ControlProz1 := New(PColoredText, Init(R, #3+'???', $7E));
PrhWin^.Insert(ControlProz1);

R.Assign(68, 15, 71, 16);
Control1 := New(PColoredText, Init(R, '%2:', $74));
PrhWin^.Insert(Control1);

R.Assign(71, 15, 77, 16);
ControlProz2 := New(PColoredText, Init(R, #3'???', $7E));
PrhWin^.Insert(ControlProz2);

R.Assign(50, 16, 56, 17);
Control1 := New(PColoredText, Init(R, 'Акциз:', $74));
PrhWin^.Insert(Control1);

R.Assign(56, 16, 66, 17);
ControlAkzisSbor := New(PColoredText, Init(R, #3'???', $7E));
PrhWin^.Insert(ControlAkzisSbor);

PrhWin^.SelectNext(False);
PrevCurrent[0]:=#0;
NoInfoMsg;
i := Desktop^.ExecView(PrhWin);
ClearFind;
If i=cmOk Then FullScreenPrh:=True;

Dispose(Control1,Done);
{
Dispose(ControlFullName,Done);
Dispose(ControlNMake,Done);
Dispose(ControlOtdel,Done);
Dispose(ControlDo,Done);
Dispose(ControlVirabotano,Done);
Dispose(ControlMArka,Done);
Dispose(ControlPack,Done);
Dispose(ControlPost,Done);
Dispose(ControlFirmaPost,Done);
Dispose(ControlNGTD,Done);
Dispose(ControlRegion,Done);
Dispose(ControlShKod,Done);
Dispose(ControlAkzis,Done);
Dispose(ControlNSertif,Done);
Dispose(WindowList,Done);
}
Dispose(PrhWin,Done);

Dispose(E,Done);
Dispose(ScreenList,Done);
Dispose(NoScreenList2,Done);
Dispose(NoScreenList3,Done);
end;

procedure TFullScreenPrh.DrawCurrent;
VAr R : TRect;
    s,s1,sExpert : String;
    Pos1,Pos2 : Word;
    SProz,NSertif,SArtikul : ArtikulStr;
    SZakupka,SRZena : AllStr;
    Color,c : Word;
    SAkzisSbor : Allstr;
Begin
s1:=PStaticText(ControlFullName)^.Text^;
If (PrevCurrent[0]=#0) And (s1<>'???') Then
Begin
Dispose(ControlFullName,Done);
R.Assign(2, 15, 56, 16);
ControlFullName := New(PColoredText, Init(R, '???', $7E));
PrhWin^.Insert(ControlFullName);

Dispose(ControlOtdel,Done);
R.Assign(2, 16, 49, 17);
ControlOtdel := New(PColoredText, Init(R, '1:  ??? 2:  ??? 3:  ??? 4:  ??? 5'+
     ':  ??? 6:  ??? 7:  ??? 8:  ???', $71));
PrhWin^.Insert(ControlOtdel);

Dispose(ControlNMake,Done);
R.Assign(11, 17, 31, 18);
ControlNMake := New(PColoredText, Init(R, '???', $7E));
PrhWin^.Insert(ControlNMake);

Dispose(ControlRegion,Done);
R.Assign(74, 16, 78, 17);
ControlRegion := New(PColoredText, Init(R, '???', $74));
PrhWin^.Insert(ControlRegion);


Dispose(ControlPack,Done);
R.Assign(65, 17, 74, 18);
ControlPack := New(PColoredText, Init(R, '???', $7E));
PrhWin^.Insert(ControlPack);


Dispose(ControlNGTD,Done);
R.Assign(5, 18, 45, 19);
ControlNGTD := New(PColoredText, Init(R, '???', $7E));
PrhWin^.Insert(ControlNGTD);

Dispose(ControlShKod,Done);
R.Assign(58, 18, 76, 19);
ControlShKod := New(PColoredText, Init(R, '???', $7E));
PrhWin^.Insert(ControlShKod);

Dispose(ControlPost,Done);
R.Assign(8, 19, 23, 20);
ControlPost := New(PColoredText, Init(R, '???', $7E));
PrhWin^.Insert(ControlPost);

Dispose(ControlFirmaPost,Done);
R.Assign(44, 19, 79, 20);
ControlFirmaPost := New(PColoredText, Init(R, '???', $7E));
PrhWin^.Insert(ControlFirmaPost);

Dispose(ControlAkzis,Done);
R.Assign(7, 20, 47, 21);
ControlAkzis := New(PColoredText, Init(R, '???', $7E));
PrhWin^.Insert(ControlAkzis);

Dispose(ControlVirabotano,Done);
R.Assign(59, 20, 67, 21);
ControlVirabotano := New(PColoredText, Init(R, '???', $7E));
PrhWin^.Insert(ControlVirabotano);

Dispose(ControlDo,Done);
R.Assign(71, 20, 79, 21);
ControlDo := New(PColoredText, Init(R, '???', $7E));
PrhWin^.Insert(ControlDo);

Dispose(ControlNSertif,Done);
R.Assign(12, 21, 73, 22);
ControlNSertif := New(PColoredText, Init(R, '???', $7E));
PrhWin^.Insert(ControlNSertif);

Dispose(ControlProz1,Done);
R.Assign(61, 15, 67, 16);
ControlProz1 := New(PColoredText, Init(R, #3+'???', $7E));
PrhWin^.Insert(ControlProz1);

Dispose(ControlProz2,Done);
R.Assign(71, 15, 77, 16);
ControlProz2 := New(PColoredText, Init(R, #3+'???', $7E));
PrhWin^.Insert(ControlProz2);

Dispose(ControlAkzisSbor,Done);
R.Assign(56, 16, 66, 17);
ControlAkzisSbor := New(PColoredText, Init(R, #3'???', $7E));
PrhWin^.Insert(ControlAkzisSbor);



End
 Else
  Begin
{сначала то что прорисовывается из текущей строки}
SArtikul:=Copy(PrevCurrent,1+CNAme+1,CArtikul);

s[0]:=#0;
For c:=1 To CDivision Do
 Begin
  s1:=Copy(PrevCurrent,1+CNAme+1+CArtikul+1+CInPAck+1+CLitr+1+CKOl+1+CZenaZ+1+CZenaZ+1+CZena+1+
  CStrihKod+1+(CKol+1)*(C-1),CKol);
  DelSpace(s1);
  RFormat(s1,CKol);
  If StrToInt(s1)>0 Then
   Begin
    s:=s+IntToStr(c,COne)+':';
    s:=s+s1+' ';
   End;
 End;

Dispose(ControlOtdel,Done);
R.Assign(2, 16, 49, 17);
ControlOtdel := New(PColoredText, Init(R, s, $71));
PrhWin^.Insert(ControlOtdel);


s:=Copy(PrevCurrent,1+CNAme+1+CArtikul+1+CInPAck+1+CLitr+1+CKOl+1+CZenaZ+1+CZenaZ+1+CZena+1+
 CStrihKod+1+(CKol+1)*(CDivision)+1,CZenaZ);
DelSpace(s);
Dispose(ControlAkzisSbor,Done);
R.Assign(56, 16, 66, 17);
ControlAkzisSbor := New(PColoredText, Init(R, #3+s, $7E));
PrhWin^.Insert(ControlAkzisSbor);




{читаем количество}
s1:=Copy(PrevCurrent,1+CNAme+1+CArtikul+1+CInPAck+1+CLitr+1,CKOl);
s:=Copy(PrevCurrent,1+CNAme+1+CArtikul+1,CInPAck);
s1:=CAlcPAckNoFile(s,s1);
DelSpace(s1);
RFormat(s1,CPAck);
Dispose(ControlPack,Done);
R.Assign(65, 17, 74, 18);
ControlPack := New(PColoredText, Init(R, s1, $7E));
PrhWin^.Insert(ControlPack);

s1:=Copy(PrevCurrent,1+CNAme+1+CArtikul+1+CInPAck+1+CLitr+1+CKOl+1+CZenaZ+1+CZenaZ+1+CZena+1,CStrihKod);
DelSpace(s1);
Dispose(ControlShKod,Done);
R.Assign(58, 18, 76, 19);
ControlShKod := New(PColoredText, Init(R, s1, $7E));
PrhWin^.Insert(ControlShKod);

{позиция в списке полных наименований}
Pos1:=Location(NoScreenList2,SArtikul,FAlse);
s:=Copy(NoScreenList2^.GetText(Pos1,NoScreenList2^.List^.Count),1,CName+1+CNAme);
DelSpaceRight(s);
Dispose(ControlFullName,Done);
R.Assign(2, 15, 56, 16);
ControlFullName := New(PColoredText, Init(R, s, $7E));
PrhWin^.Insert(ControlFullName);
s:=Copy(NoScreenList2^.GetText(Pos1,NoScreenList2^.List^.Count),1+CName+1+CNAme+1+
CArtikul+1+CArtikul+1,COne);

Color:=$5E;
Case StrToInt(s) Of
0: Begin
    s:='Нет';
    Color:=$5E;
   End;
1: Begin
    s:='Есть';
    Color:=$7E;
   End;
Else s:='???';
End;

Dispose(ControlRegion,Done);
R.Assign(74, 16, 78, 17);
ControlRegion := New(PColoredText, Init(R, #3+s, Color));
PrhWin^.Insert(ControlRegion);

s:=Copy(NoScreenList2^.GetText(Pos1,NoScreenList2^.List^.Count),1+CName+1+CNAme+1+
CArtikul+1+CArtikul+1+COne+1,CNSertif);
DelSpaceRight(s);
Dispose(ControlAkzis,Done);
R.Assign(7, 20, 47, 21);
ControlAkzis := New(PColoredText, Init(R, s, $7E));
PrhWin^.Insert(ControlAkzis);

s:=Copy(NoScreenList2^.GetText(Pos1,NoScreenList2^.List^.Count),1+CName+1+CNAme+1+
CArtikul+1+CArtikul+1+COne+1+CNSertif+1,CNsertif);
DelSpaceRight(s);
Dispose(ControlNGTD,Done);
R.Assign(5, 18, 45, 19);
ControlNGTD := New(PColoredText, Init(R, s, $7E));
PrhWin^.Insert(ControlNGTD);

{
  s:=s+'│'+BazKod+'│'+Input.NSertif+'│'+IntToStr(Input.RegionMarka,COne)+'│'+Input.Marka+'│'+
  Input.NGTD+'│'+Input.Post+'│'+Input.FirmaPost+'│'+Input.Virabotano+'│'+
  Input.Godnost+'│'+Postawshik+'│'+Input.NMAkeKod+'│';
}
s:=Copy(NoScreenList2^.GetText(Pos1,NoScreenList2^.List^.Count),1+CName+1+CNAme+1+
CArtikul+1+CArtikul+1+COne+1+CNSertif+1+CNsertif+1,CPost);
DelSpaceRight(s);
Dispose(ControlPost,Done);
R.Assign(8, 19, 23, 20);
ControlPost := New(PColoredText, Init(R, s, $7E));
PrhWin^.Insert(ControlPost);

s:=Copy(NoScreenList2^.GetText(Pos1,NoScreenList2^.List^.Count),1+CName+1+CNAme+1+
CArtikul+1+CArtikul+1+COne+1+CNSertif+1+CNsertif+1+CPost+1,CFirmaPOst);
DelSpaceRight(s);
Dispose(ControlFirmaPost,Done);
R.Assign(44, 19, 79, 20);
ControlFirmaPost := New(PColoredText, Init(R, s, $7E));
PrhWin^.Insert(ControlFirmaPost);

s:=Copy(NoScreenList2^.GetText(Pos1,NoScreenList2^.List^.Count),1+CName+1+CNAme+1+
CArtikul+1+CArtikul+1+COne+1+CNSertif+1+CNsertif+1+CPost+1+CFirmaPOst+1,CDAte);
DelSpaceRight(s);
Dispose(ControlVirabotano,Done);
R.Assign(59, 20, 67, 21);
ControlVirabotano := New(PColoredText, Init(R, s, $7E));
PrhWin^.Insert(ControlVirabotano);

s:=Copy(NoScreenList2^.GetText(Pos1,NoScreenList2^.List^.Count),1+CName+1+CNAme+1+
CArtikul+1+CArtikul+1+COne+1+CNSertif+1+CNsertif+1+CPost+1+CFirmaPOst+1+CDAte+1,CDAte);
DelSpaceRight(s);
Dispose(ControlDo,Done);
R.Assign(71, 20, 79, 21);
ControlDo := New(PColoredText, Init(R, s, $7E));
PrhWin^.Insert(ControlDo);

s:=Copy(NoScreenList2^.GetText(Pos1,NoScreenList2^.List^.Count),1+CName+1+CNAme+1+
CArtikul+1+CArtikul+1+COne+1+CNSertif+1+CNsertif+1+CPost+1+CFirmaPOst+1+CDAte+1+CDAte+1,CClient);
DelSpaceRight(s);
Dispose(ControlNMake,Done);
R.Assign(11, 17, 31, 18);
ControlNMake := New(PColoredText, Init(R, s, $7E));
PrhWin^.Insert(ControlNMake);


NSertif:=Copy(NoScreenList2^.GetText(Pos1,NoScreenList2^.List^.Count),1+CName+1+CNAme+1+
CArtikul+1,CArtikul);
{позиция в списке полных сертификатов}
Pos2:=Location(NoScreenList3,NSertif,FAlse);
s:=Copy(NoScreenList3^.GetText(Pos2,NoScreenList2^.List^.Count),1,CName+1+CNAme);
DelSpaceRight(s);
s:=s+' ['+NSertif+']';
sExpert:=Copy(PrevCurrent,1+CNAme+1+CArtikul+1+CInPAck+1+CLitr+1+CKOl+1+CZenaZ+1+CZenaZ+1+CZena+1+
+CStrihKod+1+(CKol+1)*(CDivision)+1+CZenaZ+1,CExpert);
DelSpaceRight(SExpert);
s:=s+' '+SExpert;



Dispose(ControlNSertif,Done);
R.Assign(12, 21, 73, 22);
ControlNSertif := New(PColoredText, Init(R, s, $7E));
PrhWin^.Insert(ControlNSertif);

SRZena  :=Copy(PrevCurrent,1+CNAme+1+CArtikul+1+CInPAck+1+CLitr+1+CKOl+1,CZena);
SZakupka:=Copy(PrevCurrent,1+CNAme+1+CArtikul+1+CInPAck+1+CLitr+1+CKOl+1+CZena+1,CZenaZ);
sakzisSbor:=Copy(PrevCurrent,1+CNAme+1+CArtikul+1+CInPAck+1+CLitr+1+CKOl+1+CZenaZ+1+CZenaZ+1+CZena+1+
 CStrihKod+1+(CKol+1)*(CDivision)+1,CZenaZ);
DelSpace(sakzisSbor);

SProz:='???';

If (EnableZakupka=1)  Then
 Begin
  If StrToReal(SZakupka)>0.0009 Then
   BEgin
    MyStr((StrToReal(SRZena)-StrToReal(SZakupka)-StrToReal(SAkzisSbor))/StrToReal(SZakupka)*100,CLitr,CMantissa,SProz)
   End;
 End;


Dispose(ControlProz1,Done);
R.Assign(61, 15, 67, 16);
ControlProz1 := New(PColoredText, Init(R, #3+SProz, $7E));
PrhWin^.Insert(ControlProz1);

{$IFDEF Pharm}
SZakupka:=Copy(PrevCurrent,1+CNAme+1+CArtikul+1+CInPAck+1+CLitr+1+CKOl+1+CZena+1,CZenaZ);
SRZena:=Copy(PrevCurrent,1+CNAme+1+CArtikul+1+CInPAck+1+CLitr+1+CKOl+1+CZena+1+CZenaZ+1,CZenaZ);
sakzisSbor:=Copy(PrevCurrent,1+CNAme+1+CArtikul+1+CInPAck+1+CLitr+1+CKOl+1+CZenaZ+1+CZenaZ+1+CZena+1+
 CStrihKod+1+(CKol+1)*(CDivision)+1,CZenaZ);
DelSpace(sakzisSbor);

SProz:='???';

If (EnableZakupka=1) Then
 Begin
  If StrToReal(SZakupka)>0.0009 Then
   BEgin
    MyStr((StrToReal(SRZena)-StrToReal(SZakupka)-StrToReal(SAkzisSbor))/StrToReal(SZakupka)*100,CLitr,CMantissa,SProz)
   End;
 End;
{$ELSE}
SZakupka:=Copy(PrevCurrent,1+CNAme+1+CArtikul+1+CInPAck+1+CLitr+1+CKOl+1+CZena+1+CZenaZ+1,CZenaZ);
SProz:='???';
sAkzisSbor:=Copy(PrevCurrent,1+CNAme+1+CArtikul+1+CInPAck+1+CLitr+1+CKOl+1+CZenaZ+1+CZenaZ+1+CZena+1+
 CStrihKod+1+(CKol+1)*(CDivision)+1,CZenaZ);
DelSpace(sAkzisSbor);

If (EnableZakupka=1)  Then
 Begin
  If StrToReal(SZakupka)>0.0009 Then
   BEgin
    MyStr((StrToReal(SRZena)-StrToReal(SZakupka)-
    StrToreal(SAkzisSbor))/StrToReal(SZakupka)*100,CLitr,CMantissa,SProz)
   End;
 End;
{$ENDIF}

Dispose(ControlProz2,Done);
R.Assign(71, 15, 77, 16);
ControlProz2 := New(PColoredText, Init(R, #3+SProz, $7E));
PrhWin^.Insert(ControlProz2);

  End;

end;


procedure TFullScreenPrh.Refresh;
Begin
end;

procedure TFullScreenPrh.HandleEvent(var Event: TEvent);
procedure Calculator;
begin
  Calc^.Start;
end;

Var s : String;
    Prom : Word;
    Assistent : DocumentEditZ;
    Sn : ArtikulStr;
Begin

Case Event.What Of
 evCommand :
   Case Event.Command Of
        cmLocalCalc:Calculator;

        cmAllSfB   :Begin
                     ViewElement(Copy(PrhWin^.ClientKod,2,CClientKod),bMake,
				 StrToInt(Copy(PrhWin^.ClientKod,1,1)));
                    End;

  cmPrintReestr:    Begin
                ClearFind;
                Assistent.EditPosition:=PrhWin^.Numer;
                DelSpace(Assistent.EditPosition);
                DelZerro(Assistent.EditPosition);
                Assistent.D:=PrhWin^.Date;
                DelSpace(Assistent.D);

                If MessageBox(^M+#3'Печатать накладную прихода N '+Assistent.EditPosition+' от '+Assistent.D+'?',Nil,
                         mfConfirmation+mfOKCancel)=cmOk Then
                PrintPrihod(Assistent);

                  If (Pharm=1) Then
                  If MessageBox(^M+#3'Печатать накладную комиссии по документу '+Assistent.EditPosition+' от '+
                            Assistent.D+'?',Nil,
                     mfConfirmation+mfOKCancel)=cmOk Then
                    PrintPrihodAsMarket(Assistent);

              Redraw;
                    End;
        Else;
        End;
 Else;
 End;

inherited HandleEvent(Event);


 If (Desktop^.Current=PView(PrhWin)) And (Event.What <> EvKeyDown) Then
     Begin

            if (WindowList^.List<>Nil)And(WindowList^.List^.Count>=1) Then
              Begin
               s:=WindowList^.GetText(WindowList^.Focused,WindowList^.List^.Count);
               If s <> PrevCurrent Then
                 Begin
                  PrevCurrent:=S;
                  DrawCurrent;
                 End;
              End;

     End;


End;

Destructor TFullScreenPrh.Done;
Begin
TDialog.Done;
end;







Begin

End.