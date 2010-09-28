{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}

Unit Access;

Interface

Uses Dialogs,Glob,Drivers,ServStr,Access3,Access5,
     Utils5,Slava3,Access10;


Type  PDopClientWindow= ^TDopClientWindow;
      TDopClientWindow = object(TDialog)
      Function DopClient(Var Cl:ClientDopolnenieType):Boolean;
  end;



Type
    PAddClientWindow= ^TAddClientWindow;
    TAddClientWindow = object(TDialog)
    Registration : Word;
    Dopolnenie : PDopClientWindow;
    MainWin: PSelClientWindow;
    RegWin : PRegionWindow;
    RouteWin : PRouteWindow;
    BankWin : PBankWindow;
    RRRR,SSSS : Word;
    FoundNoMain: Boolean;
    {SelObj : PSelObjectsWindow;}
    Procedure SetStatus;
    Function AddClient(Cod:Integer; Var ClientElement:ClientType;Reg,Sel:Byte;{Const P:PBox}Art:ArtikulStr):Boolean;
    procedure HandleEvent(var Event: TEvent); virtual;
    Destructor Done;Virtual;
  end;



{
Type
    PAddMAkeWindow= ^TAddMAkeWindow;
    TAddMAkeWindow = object(TDialog)
    RegWin : PRegionWindow;
    Function AddMake( Cod:Integer; Var MakeListElement:ClientType;MakeVid:Byte;VidClienta:Boolean):Boolean;
    procedure HandleEvent(var Event: TEvent); virtual;
    Destructor Done;Virtual;
  end;
}

Type PClientWindow= ^TClientWindow;
     TClientWindow = object(TDialog)
     Add : PAddClientWindow;
     {AddM : PAddMAkeWindow;}
     {Procedure PrintClientInfo(s:ArtikulStr;Reg,Sel:Byte);}
     Procedure ShowClientList(Var st:AllStr;Selector,
     Regim:Word;VidClienta,Net:Boolean;NoLocked1,VidNoLocked1,NoLocked2,VidNoLocked2:Integer;
     Var Res: Word);
     Procedure Refresh(Reg,Sel:Word);
     procedure HandleEvent(var Event: TEvent); virtual;
     Procedure DrawCurrent(Reg,Sel: Byte);
     Destructor Done;Virtual;
  end;

Procedure ViewElement(Cod:ArtikulStr;{код элемента}Reg,Sel:Byte);

Var

 ClientFile : ClientFileType;
 ClientElement : ClientType;
 ClientElement2 : ClientDopolnenieType;

Implementation

{$I Compile.INC}

Uses Printers,Vision4,App,Views,Objects,MsgBox,Serv,ColorTxt,Validate,DbEngine,
     Memory,TpDate,Protect,Net,NetDbEng,NetCall,WinDos,Utils1,Utils3,Net2,
     X_Dialog,DbEngin3,ServStr2,
	Utils4,Utils,DbEngin2,Access1,Access2,InpLong,Utils7;

{Const ReadOnly=66;}


Var

   ControlDolg,ControlEnviropment,
   ControlDolgText,ControlAdress,
   ControlBuch,ControlOtdel,
   ControlINN,ControlLimit,
   ControlStatus,ControlDogovor,
   ControlSrokLizensia,

   ControlName,
   ControlProz,
   ControlFullName,
   ControlStatusLoc,
   ControlDogovorLoc,
   ControlPasport,
   ControlOtrguska,
   ControlDocFiltr,
   ControlDelta,
   ControlDebit,
   ControlDebitS,
   ControlSrokLoc,
   ControlEnvir,
   ControlKTO,
   ControlINNLoc,
   ControlMsg,
   ControlEnvirLoc,
   ControlAdressU,
   ControlAdressF,
   ControlAuto,
   ControlKPP,
   ControlLizo,
   ControlBank,
   ControlBankS,
   ControlGorod,
   ControlRSH,
   ControlOKONH,
   ControlOKPO,
   ControlSvid,
   ControlVidan,
   ControlVIP,
   ControlRegion,
   ControlRegionS,
   ControlLimitLoc,
   ControlOtgruska,
   ControlPeriod,
   ControlTelefon,
   Control1S,
   ControlSkladFiltr,
   ControlSeria,
   ControlIP,
   ControlDP,
   ControlMail,
   ControlPrice,
   ControlLastSverka,
   ControlRoute,
   ControlRouteS,
   ControlMain,
   ControlMainS,
   ControlFantom
   : PView;
   Reg,Sel  : Word;
   ClientWindow : PClientWindow;
   AddClientWin : PAddClientWindow;
   INN,PrevClient : String[35];
   Debitors:Boolean;
   BazNum : PBox;
 OldFileMode : Word;
 ControlDebitList,
 ControlOtgruskaList,
 ControlDebitList1,
 ControlOtgruskaList1 : PMyListBox;

 WithNetLock : Boolean;
 NotLockedCod1   : Integer;
 NotLockedCod2   : Integer;
 VidNotLockedCod1   : Integer;
 VidNotLockedCod2   : Integer;
 CLF : File;
 Cle : PBufKurzClientType;






Procedure TAddClientWindow.SetStatus;
Begin
If ClientElement.Main=1 Then
Begin
Control1S^.Options := Control1S^.Options and not ofSelectable;
ControlFullName^.Options := ControlFullName^.Options and not ofSelectable;
ControlAdressU^.Options := ControlAdressU^.Options and not ofSelectable;
ControlDogovorLoc^.Options := ControlDogovorLoc^.Options and not ofSelectable;
ControlLizo^.Options := ControlLizo^.Options and not ofSelectable;
ControlINNLoc^.Options := ControlINNLoc^.Options and not ofSelectable;
ControlKPP^.Options := ControlKPP^.Options and not ofSelectable;
ControlBank^.Options := ControlBank^.Options and not ofSelectable;
ControlRSH^.Options := ControlRSH^.Options and not ofSelectable;
ControlOKONH^.Options := ControlOKONH^.Options and not ofSelectable;
ControlOKPO^.Options := ControlOKPO^.Options and not ofSelectable;
ControlSvid^.Options := ControlSvid^.Options and not ofSelectable;
ControlEnvir^.Options := ControlEnvir^.Options and not ofSelectable;
ControlVidan^.Options := ControlVidan^.Options and not ofSelectable;
ControlSrokLoc^.Options := ControlSrokLoc^.Options and not ofSelectable;
ControlDocFiltr^.Options := ControlDocFiltr^.Options and not ofSelectable;
End
 Else
  Begin

   If (AddClientWin^.RRRR in [bAgent,bEksped]) And (StrToInt(CurrentPassword)<>0) Then
Control1S^.Options := Control1S^.Options and not ofSelectable
   Else
   Control1S^.Options := Control1S^.Options or ofSelectable;

   ControlFullName^.Options := ControlFullName^.Options or ofSelectable;

If (AddClientWin^.RRRR in [bAgent,bEksped]) Then
ControlAdressU^.Options := ControlAdressU^.Options and not ofSelectable;


ControlAdressU^.Options := ControlAdressU^.Options or ofSelectable;


ControlDogovorLoc^.Options := ControlDogovorLoc^.Options or ofSelectable;
If (AddClientWin^.SSSS=1) Or (AddClientWin^.RRRR=1) Then
ControlDogovorLoc^.Options := ControlDogovorLoc^.Options and not ofSelectable;
If AddClientWin^.RRRR in [bAgent,bEksped] Then
ControlDogovorLoc^.Options := ControlDogovorLoc^.Options and not ofSelectable;


ControlLizo^.Options := ControlLizo^.Options or ofSelectable;
If AddClientWin^.RRRR in [bAgent,bEksped] Then
ControlLizo^.Options := ControlLizo^.Options and not ofSelectable;

ControlINNLoc^.Options := ControlINNLoc^.Options or ofSelectable;
If AddClientWin^.RRRR in [bAgent,bEksped] Then
ControlINNLoc^.Options := ControlINNLoc^.Options and not ofSelectable;



ControlKPP^.Options := ControlKPP^.Options or ofSelectable;
If AddClientWin^.RRRR in [bAgent,bEksped] Then
ControlKPP^.Options := ControlKPP^.Options and not ofSelectable;


ControlBank^.Options := ControlBank^.Options or ofSelectable;
If AddClientWin^.RRRR in [bAgent,bEksped] Then
ControlBank^.Options := ControlBank^.Options and not ofSelectable;


ControlRSH^.Options := ControlRSH^.Options or ofSelectable;
If AddClientWin^.RRRR in [bAgent,bEksped] Then
ControlRSH^.Options := ControlRSH^.Options and not ofSelectable;



ControlOKONH^.Options := ControlOKONH^.Options or ofSelectable;
If AddClientWin^.RRRR in [bAgent,bEksped] Then
ControlOKONH^.Options := ControlOKONH^.Options and not ofSelectable;


ControlOKPO^.Options := ControlOKPO^.Options or ofSelectable;
If AddClientWin^.RRRR in [bAgent,bEksped] Then
ControlOKPO^.Options := ControlOKPO^.Options and not ofSelectable;



ControlSvid^.Options := ControlSvid^.Options or ofSelectable;
If AddClientWin^.RRRR in [bAgent,bEksped] Then
ControlSvid^.Options := ControlSvid^.Options and not ofSelectable;


ControlEnvir^.Options := ControlEnvir^.Options or ofSelectable;
If AddClientWin^.RRRR in [bAgent,bEksped] Then
ControlEnvir^.Options := ControlEnvir^.Options and not ofSelectable;


ControlVidan^.Options := ControlVidan^.Options or ofSelectable;
If AddClientWin^.RRRR in [bAgent,bEksped] Then
ControlVidan^.Options := ControlVidan^.Options and not ofSelectable;


ControlSrokLoc^.Options := ControlSrokLoc^.Options or ofSelectable;
If (AddClientWin^.SSSS=1) Or (AddClientWin^.RRRR=1) Then
ControlSrokLoc^.Options := ControlSrokLoc^.Options and not ofSelectable;
If AddClientWin^.RRRR in [bAgent,bEksped] Then
ControlSrokLoc^.Options := ControlSrokLoc^.Options and not ofSelectable;


ControlDocFiltr^.Options := ControlDocFiltr^.Options or ofSelectable;
If AddClientWin^.RRRR in [bEksped] Then
ControlDocFiltr^.Options := ControlDocFiltr^.Options and not ofSelectable;

  End;


Redraw;

End;






procedure TAddClientWindow.HandleEvent(var Event: TEvent);
Label Start;
Var f,l,r : Boolean;
    Test : Word;
    s : TMyStringNew;
    sss,ss,st : String;
    ClientELement : ClientType;
    CLE : PClientType;


Begin
Case Event.What Of
 evCommand :
   Case Event.Command Of
(*
   cmComment :Begin
               If Registration in [bClient] Then
                Begin
                 If Dopolnenie^.DopClient(ClientElement2) Then
                  Begin
                    ClientElement.Dopolnenie:=ClientElement2;
                    AddClientWin^.SetData(ClientElement);
                  End;
                End;
              End;
*)
   cmSelectRegion : Begin

  If (PView(RegWin)<>Desktop^.TopView)And(ControlRegion^.State and sfFocused <> 0) Then
  Begin
     PStaticText(ControlRegionS)^.GetText(S);
     System.Delete(S,1,1);
     ControlRegion^.GetData(ClientElement.RegionKod);
     s:=s+ClientElement.RegionKod;
     RegWin^.ShowRegionList(s,Test);
     ClientElement.RegionKod:=Copy(s,Pos('│',s)+1,CClientKod);
     ControlRegion^.SetData(ClientElement.RegionKod);
     s[0]:=Chr(Pos('│',s));
     PStaticText(ControlRegionS)^.Text^:=' '+S;
     Case Test Of
      0,3 :FocusNext(True);
      1,2 :FocusNext(False);
     Else;
          End;

     Redraw;

     ClearEvent(Event);
  End
  Else
   ClearEvent(Event);

 End;
(*
   cmSelectMainName:Begin
  If (PView(MainWin)<>Desktop^.TopView)And(ControlFantom^.State and sfFocused <> 0) Then
  Begin
     PStaticText(ControlMainS)^.GetText(S);
     System.Delete(S,1,1);
     ControlFantom^.GetData(ClientElement.FantomKod);
     s:=s+ClientElement.FantomKod;
     MainWin^.ShowMainClient(s,AddClientWin^.RRRR,AddClientWin^.SSSS,Test);
     ClientElement.FantomKod:=Copy(s,Pos('│',s)+1,CClientKod);
     ControlFantom^.SetData(ClientElement.FantomKod);
     s[0]:=Chr(Pos('│',s));
     PStaticText(ControlMainS)^.Text^:=' '+S;
     Case Test Of
      0,3 :FocusNext(True);
      1,2 :FocusNext(False);
     Else;
          End;
     Redraw;

     ClearEvent(Event);
  End
  Else
   ClearEvent(Event);
  End;
*)

              cmSelectMainName : Begin
                               PStaticText(ControlMainS)^.GetText(St);
                               ControlFantom^.GetData(ss);
                               RFormatZerro(ss,CClientKod);
                               st:=st+ss;
Start:
                               MainWin^.ShowMainClient(st,AddClientWin^.RRRR,AddClientWin^.SSSS,Test);
                               ClearEvent(Event);
                               Case Test Of
                               2,3 :Begin
                                     New(CLe,Init);
                                     ss:=Copy(st,Pos('│',st)+1,CClientKod);
                                     ClientELement^.Dat.Kod:=ss;

                                     If GetClient(ClientELement,AddClientWin^.RRRR) Then
                                      Begin
                                       ClientElement.FantomKod:=ss;

With ClientElement Do
Begin
BuchKod  :=ClientELement^.Dat.BuchKod;
FullName :=ClientELement^.Dat.FullName;
Adress   :=ClientELement^.Dat.Adress;
Dogovor  :=ClientELement^.Dat.Dogovor;
Lizo     :=ClientELement^.Dat.Lizo;
INN        :=ClientELement^.Dat.INN;
KPP        :=ClientELement^.Dat.KPP;
BankKod    :=ClientELement^.Dat.BankKod;
R_Sh       :=ClientELement^.Dat.R_Sh;
OKONH      :=ClientELement^.Dat.OKONH;
OKPO       :=ClientELement^.Dat.OKPO;
Svidetelstvo:=ClientELement^.Dat.Svidetelstvo;
Enviropment:=ClientELement^.Dat.Enviropment;
Kto        :=ClientELement^.Dat.Kto;
SrokLizensia :=ClientELement^.Dat.SrokLizensia;
DocFiltr   :=ClientELement^.Dat.DocFiltr;
FantomKod  :=ss;

Control1S^.SetData(BuchKod);
ControlFullName^.SetData(FullName);
ControlAdressU^.SetData(Adress);
ControlDogovorLoc^.SetData(Dogovor);
ControlLizo^.SetData(Lizo);
ControlINNLoc^.SetData(INN);
ControlKPP^.SetData(KPP);
ControlBank^.SetData(BankKod);
ControlRSH^.SetData(R_Sh);
ControlOKONH^.SetData(OKONH);
ControlOKPO^.SetData(OKPO);
ControlSvid^.SetData(Svidetelstvo);
ControlEnvir^.SetData(Enviropment);
ControlVidan^.SetData(Kto);
ControlSrokLoc^.SetData(SrokLizensia);
ControlDocFiltr^.SetData(DocFiltr);
ControlFantom^.SetData(FantomKod);
End;{With}


(*
                                       ControlMainName^.SetDAta(Element.FantomKod);
                                       ControlLine^.SetDAta(Element.Name);
                                       ControlLine2^.SetDAta(Element.Name2);
                                       ControlInPack^.SetDAta(Element.InPack);
                                       ControlInPack2^.SetDAta(Element.InPack2);
                                       ControlLitr^.SetDAta(Element.Litr);
                                       ControlMassa^.SetDAta(Element.Massa);
                                       ControlOkp^.SetDAta(Element.Okp);
                                       ControlBuch^.SetDAta(Element.BuchGroup);
                                       ControlEtil^.SetDAta(Element.Etil);
                                       ControlPrh^.SetDAta(Element.Prihod);
                                       ControlVidNalog^.SetDAta(Element.VidNalog);
                                       ControlNalog^.SetDAta(Element.Nalog);
                                       ControlVidNDS^.SetDAta(Element.VidNDS);
                                       ControlNDS^.SetDAta(Element.NDS);
                                       ControlMera^.SetDAta(Element.Mera);
                                       ControlClass^.SetDAta(Element.Class);
                                       ControlLand^.SetDAta(Element.PostKod);
                                       ControlFirmaPost^.SetDAta(Element.FirmaPostKod);
                                       ControlGroup^.SetDAta(Element.NGroupKod);
                                       ControlContract^.SetDAta(Element.EnableContract);
                                       ControlContractNumer^.SetDAta(Element.Contract);
                                       ControlContractDate^.SetDAta(Element.ContractDate);

                                       ControlSkladFiltr^.SetData(Element.EnableSklads);
                                       ControlOtdel^.SetData(Element.Otdel);
                                       ControlMarker^.SetData(Element.Marker);
                                       ControlMin^.SetData(Element.Min);

*)

RFormatZerro(ClientElement.BankKod,CClientKod);
sss:=GetBankField(FBank,ClientElement.BankKod);
Format(sss,40);
     PStaticText(ControlBankS)^.Text^:=' '+sss+'│';

                                       Dispose(ClientELement,Done);

                                      End
                                      Else
							    Begin
                                        Dispose(ClientELement,Done);
							     Goto Start;
                                       End;
                                     AddClientWin^.SetStatus;
                                     st[0]:=Chr(Pos('│',st));

                                     PStaticText(ControlMains)^.Text^:=' '+St;
                                     FocusNext(False);
                                     ClearEvent(Event);

                                    End;
                               0,1:Begin
                                     AddClientWin^.SetStatus;
                                     FocusNext(True);
                                     ClearEvent(Event);
                                    End;
                                  Else;
                                  End;
                               Redraw;
                               ClearEvent(Event);
                              End;




   cmSelectRoute : Begin
  If (PView(RouteWin)<>Desktop^.TopView)And(ControlRoute^.State and sfFocused <> 0) Then
  Begin
     PStaticText(ControlRouteS)^.GetText(S);
     System.Delete(S,1,1);
     ControlRoute^.GetData(ClientElement.RouteKod);
     s:=s+ClientElement.RouteKod;
     RouteWin^.ShowRouteList(s,Test);
     ClientElement.RouteKod:=Copy(s,Pos('│',s)+1,CClientKod);
     ControlRoute^.SetData(ClientElement.RouteKod);
     s[0]:=Chr(Pos('│',s));
     PStaticText(ControlRouteS)^.Text^:=' '+S;
     Case Test Of
      0,3 :FocusNext(True);
      1,2 :FocusNext(False);
     Else;
          End;
     Redraw;

     ClearEvent(Event);
  End
  Else
   ClearEvent(Event);
 End;

   cmSelectBank : Begin
  If (PView(BankWin)<>Desktop^.TopView)And(ControlBank^.State and sfFocused <> 0) Then
  Begin
     PStaticText(ControlBankS)^.GetText(S);
     System.Delete(S,1,1);
     ControlBank^.GetData(ClientElement.BankKod);
     s:=s+ClientElement.BankKod;
     BankWin^.ShowBankList(s,Test);
     ClientElement.BankKod:=Copy(s,Pos('│',s)+1,CClientKod);
     ControlBank^.SetData(ClientElement.BankKod);
     s[0]:=#0;
	s:=GetBankField(FBank,ClientElement.BankKod);
     Format(s,40);
     s:=s+'│';
     PStaticText(ControlBankS)^.Text^:=' '+S;
     Redraw;
     Case Test Of
      0,3 :FocusNext(True);
      1,2 :FocusNext(False);
     Else;
          End;
     Redraw;

     ClearEvent(Event);
  End
  Else
   ClearEvent(Event);
 End;

   Else;
   End;
   Else;
   End;


 If (PView(RegWin)<>Desktop^.TopView)And(ControlRegion^.State and sfFocused <> 0)
 And (Event.Command<>cmSelectRegion) And
(
 ((AutoList=1) And (Event.What <> EvKeyDown))
 Or
 ((AutoList=0)And(Event.What = EvKeyDown)And(Event.KeyCode=kbConst))
)Then

            Begin
             Event.What:=EvCommand;
             Event.Command:=cmSelectRegion;
             PutEvent(Event);
             ClearEvent(Event);
            End;


 If (PView(RouteWin)<>Desktop^.TopView)And(ControlRoute^.State and sfFocused <> 0)
 And (Event.Command<>cmSelectRoute) And
(
 ((AutoList=1) And (Event.What <> EvKeyDown))
 Or
 ((AutoList=0)And(Event.What = EvKeyDown)And(Event.KeyCode=kbConst))
)Then
            Begin
             Event.What:=EvCommand;
             Event.Command:=cmSelectRoute;
             PutEvent(Event);
             ClearEvent(Event);
            End;


          if (ControlMain^.State and sfFocused <> 0)Then
              Begin
               ControlMain^.GetData(Test);

               If ClientElement.Main<>Test Then
             Begin
              ClientElement.Main:=Test;
              If Test=1 Then{взведен флаг дочерней позиции}
               Begin
                ControlFantom^.Options := ControlFantom^.Options or ofSelectable;
                AddClientWin^.SetStatus;
                FocusNext(False);
               End
               Else
               Begin
                ControlFantom^.Options := ControlFAntom^.Options and not ofSelectable;
                AddClientWin^.SetStatus;
               End
             End
              End;



 If (PView(MainWin)<>Desktop^.TopView)And(ControlFantom^.State and sfFocused <> 0)
 And (Event.Command<>cmSelectMainName) And
(
 ((AutoList=1) And (Event.What <> EvKeyDown))
 Or
 ((AutoList=0)And(Event.What = EvKeyDown)And(Event.KeyCode=kbConst))
)Then
            Begin
             Event.What:=EvCommand;
             Event.Command:=cmSelectMainName;
             PutEvent(Event);
             ClearEvent(Event);
            End;



 If (PView(BankWin)<>Desktop^.TopView)And(ControlBank^.State and sfFocused <> 0)
 And (Event.Command<>cmSelectBank) And
(
 ((AutoList=1) And (Event.What <> EvKeyDown))
 Or
 ((AutoList=0)And(Event.What = EvKeyDown)And(Event.KeyCode=kbConst))
)Then
            Begin
             Event.What:=EvCommand;
             Event.Command:=cmSelectBank;
             PutEvent(Event);
             ClearEvent(Event);
            End;

  inherited HandleEvent(Event);
End;



Function TAddClientWindow.AddClient(Cod:Integer; Var ClientElement:ClientType;Reg,Sel:Byte;
Art:ArtikulStr{Const p:PBox}):Boolean;
Label 1,Restart;
var
  R : TRect;
  Control : PView;
  ClientNum : PBox;
  s : TEnjoyStr;{!!!}
  sss : String;
  j,c: Word;
  k : LongInt;
{  l : Boolean;}
  Event:TEvent;
  Count : Word;
  Operator,ss,SRegName,SRouteNAme : String[CAll];
  SKod,st,SArtik : ArtikulStr;
  LockPosition : PBox;
  Error,FindNoMain : Boolean;
  CLF : File;
  CLE : PBufKurzClientType;
  Cl : PClientType;

begin
ClearFind;

If Not(TestOpenDate1(FDate)) Then
   Begin
    MessageBox(#3^M+#3'Доступ к данным за '+FDate+' заблокирован!',Nil,mfError+mfCancelButton);
    AddClient:=False;
    Exit;
   End;

If (GlobalReadOnly=1) Or (ReadOnlyConst=1) Then
   Begin
    MessageBox(#3^M+ReadOnlyStr^,Nil,mfWarning+mfCancelButton);
    AddClient:=False;
    Exit;
   End;

If Not(TestSetupKurs(FDate)) Then
   Begin
    {MessageBox(#3^M+#3'Не установлен курс USD на '+FDate+'!',Nil,mfError+mfCancelButton);}
    AddClient:=False;
    Exit;
   End;


If Reg in [bClient,bMake] Then
Begin
Case Cod Of
kbGrayPlus,kbAltF1: Begin{добавление клиента}
                     If Not(Password(13)) Then
                      Begin
                       AddClient:=False;
                       Exit;
                      End;
                    End;

  kbF4:Begin{корректировка реквизитов}
                     If Not(Password(13)) Then
                      Begin
                       AddClient:=False;
                       Exit;
                      End;

       End;
Else;
End;
End;

If Reg in [bAgent,bEksped] Then
Begin
Case Cod Of
kbGrayPlus,kbAltF1: Begin{добавление клиента}
                     If Not(Password(14)) Then
                      Begin
                       AddClient:=False;
                       Exit;
                      End;
                    End;

  kbF4:Begin{корректировка реквизитов}
                     If Not(Password(14)) Then
                      Begin
                       AddClient:=False;
                       Exit;
                      End;

       End;
Else;
End;
End;


C:=IOResult;
AddClient:=False;

Case Reg of
bClient:
Case Sel Of
0:sss:=Path^.Dat.ToClient+'Client.db';
1:sss:=Path^.Dat.ToClient+'Sklad.db';
2:sss:=Path^.Dat.ToClient+'Barter.db';
Else exit;
End;

bMake:
Case Sel Of
0:sss:=Path^.Dat.ToClient+'Make.db';
1:sss:=Path^.Dat.ToClient+'Sklad.db';
2:sss:=Path^.Dat.ToClient+'Barter.db';
Else Exit;
End;

bAgent:sss:=Path^.Dat.ToClient+'agent.db';

bEksped:sss:=Path^.Dat.ToClient+'eksped.db';

Else Exit;
End;

Assign(ClientFile,sss);
OldFileMode:=FileMode;
FileMode:=ReadOnlyN;
Reset(ClientFile);
C:=IOResult;
FileMode:=OldFileMode;
If C<>0 Then
Begin
 MessageBox(#3^M+#3'Ошибка доступа к файлу '+sss+' Код:'+IntToStr(C,CKol),nil,mfError+mfCancelButton);
 AddClient:=False;
 Exit;
End;
DInfoMsg('Читаю списки...',False);
 Case Cod Of
  kbGrayPlus,kbAltF1:Begin
     ClientElement.Employ:=True;
     While Not(Eof(ClientFile)) And (ClientElement.Employ) Do
     begin
     ReadClient(ClientFile,ClientElement);
     end;


     If Eof(ClientFile) And (ClientElement.Employ) Then
      Begin
       NoInfoMsg;
       MessageBox(#3^M+#3'Свободных позиций для элемента - нет!',nil,mfWarning+mfCancelButton);
       System.Close(ClientFile);
       AddClient:=False;
       Exit;
      End;
      s:=ClientElement.Kod;
      ClientElement.Name[0]       :=#0;
      ClientElement.FullName[0]       :=#0;
      ClientElement.AdressF[0]     :=#0;
      ClientElement.Adress[0]     :=#0;
      ClientElement.Dogovor[0]     :=#0;
      ClientElement.Limit[0]     :=#0;
      ClientElement.Lizo     :=0;
      ClientElement.INN[0]        :=#0;
      ClientElement.KPP[0]:=#0;
      ClientElement.R_Sh[0]       :=#0;
      ClientElement.BankKod        :=NoBankStr;
      ClientElement.Okonh[0]      :=#0;
      ClientElement.Okpo[0]       :=#0;
      ClientElement.Enviropment[0]:=#0;
      ClientElement.Kto[0]:=#0;
      ClientElement.Svidetelstvo[0]:=#0;
      ClientElement.Passport[0]:=#0;
      ClientElement.Seria[0]:=#0;
      ClientElement.Vidan[0]:=#0;
      ClientElement.FantomKod:='0000';
      ClientElement.Dopolnenie.Price:=0;
      ClientElement.Dopolnenie.Proz:='1.000';
      ClientElement.Dopolnenie.MailPath[0]:=#0;
      ClientElement.Telefon[0]    :=#0;
      ClientElement.Debit      :=0;
      ClientElement.Otgruska   :=0;
      ClientElement.BuchKod   :=NoBuchKod;
      ClientElement.SrokLizensia[0]    :=#0;
      ClientElement.VekselIP[0]    :=#0;
      ClientElement.VekselDP[0]    :=#0;
      ClientElement.Messages[0]:=#0;
      ClientElement.RegionKod:=NoRegionStr;
      ClientElement.DateM:=DateStringToDate(DateMask,FDAte);
      ClientElement.RCD          :=False;
      ClientElement.DocFiltr :=511; {фильтр документов отгразки (511)}
      ClientElement.Status   :=0; {статус клиента по процессингу активен поссивен сб закр ?}
      ClientElement.Period   :='31';{периодичность появления}
      ClientElement.VIP[0]:=#0;{признак особой важности клиента в нем(поле) устанавливается дополнительная отсрочка}
      ClientElement.LastSverka[0]:=#0;
      ClientElement.DateM    :=0;
      ClientElement.TimeM    :=0;

     With ClientElement2 Do
     Begin
     CopyNaklC :=1;
     CopyTTNC  :=1;
     CopySF    :=1;
     CopyProtocol:=1;
     CopyPrilog :=1;
     CopyPrilog2:=1;
     CopyShet   :=1;
     CopyPamatka:=1;
     CopyGTDTTN :=1;
     CopyPKO    :=1;
     CopyRKO    :=1;
     CopyZakaz  :=1;
     EnableAuto :=0;{определяет какие настройки использовать default или персональные}
     Price      :=0;{0-не проводить генерацию;1-проводить автоматическую генерацию}
     EnableExport:=0;{предлагать экспортировать расходные накладные клиентов в почту}
     MailPath   [0]:=#0;{фактический адрес}
     Proz       :='1.000';
     End;{With}

     ClientElement.Dopolnenie:=ClientElement2;


    End;
  kbF4:Begin
     s:={Copy(P^.GetText(P^.Focused,P^.List^.Count),1+CClient+1,CClientKod)}Art;
     Seek(ClientFile,StrToInt(s));
     Repeat
      ReadClient(ClientFile,ClientElement);
     Until (Eof(ClientFile)) Or (ClientElement.Kod=s);
     If Eof(ClientFile) And (ClientElement.Kod<>s) Then
      Begin
       NoInfoMsg;
       MessageBox(#3^M+#3'Элемент в базе не найден!',nil,mfError+mfCancelButton);
       System.Close(ClientFile);
       AddClient:=False;
       Exit;
      End;

      ClientElement.BankKod:=IntToStr(StrToInt(ClientElement.BankKod),CCLientKod);
      RFormatZerro(ClientElement.BankKod,CClientKod);
      ClientElement.RegionKod:=IntToStr(StrToInt(ClientElement.RegionKod),CCLientKod);
      RFormatZerro(ClientElement.RegionKod,CClientKod);
      ClientElement.RouteKod:=IntToStr(StrToInt(ClientElement.RouteKod),CCLientKod);
      RFormatZerro(ClientElement.RouteKod,CClientKod);


    End;
  Else;
 End;
System.Close(ClientFile);

ClientElement2:=ClientElement.Dopolnenie;

FindNoMain:=False;
R.Assign(0, 0, 0, 0);
LockPosition := New(PBox, Init(R, 1, Nil));
LockPosition^.NewList(New(PTextCollection, Init(0,1)));


If reg in [bClient] Then
Begin
Case Reg of
bClient:
Case Sel Of
0:sss:=Path^.Dat.ToClientBaseIndex+'Client.idx';
1:sss:=Path^.Dat.ToClientBaseIndex+'Sklad.idx';
2:sss:=Path^.Dat.ToClientBaseIndex+'Barter.idx';
Else exit;
End;

bMake:
Case Sel Of
0:sss:=Path^.Dat.ToClientBaseIndex+'Make.idx';
1:sss:=Path^.Dat.ToClientBaseIndex+'Sklad.idx';
2:sss:=Path^.Dat.ToClientBaseIndex+'Barter.idx';
Else Exit;
End;

bAgent:sss:=Path^.Dat.ToClientBaseIndex+'agent.idx';

bEksped:sss:=Path^.Dat.ToClientBaseIndex+'eksped.idx';

Else Exit;
End;



If (Cod=kbF4) Then
Begin
 Begin
  If ClientElement.Main=0 Then {если позиция является главной}
   Begin
    {смотрим список подчиненных позиций}

Assign(CLF,sss);
Reset(ClF,SizeOf(KurzClientType));
c:=IOResult;
If C<>0 Then
Begin
 MessageBox(^M+#3'Ошибка доступа к файлу '+sss+' Код:'+IntToStr(c,CKol),nil,mfError+mfCancelButton);
 Dispose(LockPosition,Done);
 NoInfoMsg;
 AddClient:=False;
 Exit;
End;

     DInfoMsg('Проверяю справочник контрагентов...',False);
     While Not(Eof(ClF)) Do
     Begin
      New(CLE,Init);
      ReadBufKurzClient(CLF,CLE,Count);
      For c:=1 To Count Do
       Begin
        If CLE^.Point.Dat[c].Employ And (CLE^.Point.Dat[c].FantomKod=StrToInt(ClientElement.Kod)) And
	     (CLE^.Point.Dat[c].Kod<>StrToInt(ClientElement.Kod)) And (CLE^.Point.Dat[c].Main=1)  Then
         Begin
          {блокируем SetNameLock}
          {если не удалось деблокирем наименования из списка чистим список}
          {добавляем в список}
          SKOd:=IntToStr(CLE^.Point.Dat[c].Kod,CClientKod);
          RFormatZerro(SKod,CClientKod);
          LockPosition^.List^.Insert(NewStr('│'+SKod));
          LockPosition^.SetRange(LockPosition^.List^.Count);
         End;
       End;{For}
      Dispose(CLE,Done);
     End;{While}
     c:=IOResult;
     System.Close(ClF);
     c:=IOResult;
     NoInfoMsg;

Error:=False;
If (LockPosition^.List^.Count-1)>=0 Then
Begin
For Count:=0 To LockPosition^.List^.Count-1 Do
 Begin
   SKod:=Copy(LockPosition^.GetText(Count,LockPosition^.List^.Count),1+1,CClientKod);
   FindNoMain:=True;
  If Not(SetClientLock(SKod,Reg,Sel,Operator)) Then
   Begin
    Beep;
    DInfoMsg('Дочерний контрагент ['+SKod+'] используется'+Operator+'. Не могу заблокировать!',
    False);
    Application^.ClearEvent(Event);
    Application^.ClearEvent(Event);
    repeat
    Application^.GetEvent(Event);
    until (Event.What <> evNothing) And (Event.Command<>cmMenu);
    NoInfoMsg;
    Application^.ClearEvent(Event);
    Error:=True;
    Break;
   End;
 End;
End;


If (Error) And (Count>0) Then
 Begin
  For l:=Count-1 DownTo 0 Do
   Begin
    SKod:=Copy(LockPosition^.GetText(l,LockPosition^.List^.Count),1+1,CClientKod);
    Repeat
    Until SetClientUnLock(SKod,Reg,Sel);
   End;
 End;

If Error Then
 Begin
  Dispose(LockPosition,Done);
  Exit;
 End;

   End;{If Element.Main=0 Then}
 End;{If Not(Status) And  Not(AddSertif) Then}
End;{If (Cod=kbGrayPlus) Or (Cod=kbAltF1) Then}

End;{конец вставки}


1:
If (Cod=kbGrayPlus)Or (Cod=kbAltF1) Then
Begin
R.Assign(0, 0, 80, 23);
End
Else
Begin
R.Assign(0, 0, 80, 23);
End;
If Reg in [0,1] Then
New(AddClientWin, Init(R, 'Контрагент'));

If Reg in [2] Then
New(AddClientWin, Init(R, 'Агент'));

If Reg in [3] Then
New(AddClientWin, Init(R, 'Экспедитор'));


AddClientWin^.Options := AddClientWin^.Options or ofCenterX or ofCenterY;
AddClientWin^.Palette := dpCyanDialog;
AddClientWin^.HelpCtx:=$E011;
AddClientWin^.RRRR:=Reg;
AddClientWin^.SSSS:=Sel;
AddClientWin^.FoundNoMain:=FindNoMain;



If Reg in [bClient] Then AddClientWin^.HelpCtx:=$F955;

AddClientWin^.Registration:=Reg;

R.Assign(9, 1, 31, 2);
ControlName := New(PInputLine, Init(R, CClient));
AddClientWin^.Insert(ControlName);

If Reg in [0,1] Then
Begin
  R.Assign(31, 1, 34, 2);
  Case Reg Of
  0: AddClientWin^.Insert(New(PHistory, Init(R, PInputline(ControlName), 12)));
  1: AddClientWin^.Insert(New(PHistory, Init(R, PInputline(ControlName), 11)));
  Else Begin
        MemC('Недопустимое значение переменной Reg');
        Exit;
       End;
  End;
End;

  R.Assign(1, 1, 9, 2);
Case Reg Of
0: AddClientWin^.Insert(New(PLabel, Init(R, 'К~л~иент:', ControlName)));
1: AddClientWin^.Insert(New(PLabel, Init(R, 'Постав:', ControlName)));
2: AddClientWin^.Insert(New(PLabel, Init(R, ' Агент:', ControlName)));
3: AddClientWin^.Insert(New(PLabel, Init(R, 'Экспед:', ControlName)));
Else;
End;

R.Assign(39, 1, 47, 2);
ControlVIP := New(PInputLine, Init(R, CIZena));
If Reg in [bAgent,bEksped] Then
ControlVIP^.Options := ControlVIP^.Options and not ofSelectable;
AddClientWin^.Insert(ControlVIP);

  R.Assign(34, 1, 39, 2);
  AddClientWin^.Insert(New(PLabel, Init(R, 'VIP:', ControlVIP)));

R.Assign(54, 1, 61, 2);
ControlLimitLoc := New(PInputLine, Init(R, CIZena));
If Reg in [bAgent,bEksped] Then
ControlLimitLoc^.Options := ControlLimitLoc^.Options and not ofSelectable;
AddClientWin^.Insert(ControlLimitLoc);

  R.Assign(47, 1, 54, 2);
  AddClientWin^.Insert(New(PLabel, Init(R, 'Ли~м~ит:', ControlLimitLoc)));

R.Assign(69, 1, 79, 2);
ControlLastSverka := New(PInputLine, Init(R, CDAte));
If Reg in [bAgent,bEksped] Then
ControlLastSverka^.Options := ControlLastSverka^.Options and not ofSelectable;
AddClientWin^.Insert(ControlLastSverka);
  PInputLine(ControlLastSverka)^.Validator := New(PPXPictureValidator, Init('[##-##-##]', True));

  R.Assign(61, 1, 69, 2);
  AddClientWin^.Insert(New(PLabel, Init(R, 'Сверка:', ControlLastSverka)));

R.Assign(9, 2, 52, 3);
ControlStatusLoc := New(PRadioButtons, Init(R,
  NewSItem('Акт',NewSItem('~П~ас',NewSItem('~С~Б',NewSItem('~З~акр',NewSItem('?', Nil)))))));
If Reg in [bAgent,bEksped] Then
ControlStatusLoc^.Options := ControlStatusLoc^.Options and not ofSelectable;
AddClientWin^.Insert(ControlStatusLoc);

  R.Assign(1, 2, 9, 3);
  AddClientWin^.Insert(New(PLabel, Init(R, 'Статус:', ControlStatusLoc)));

R.Assign(61, 2, 66, 3);
ControlPeriod := New(PInputLine, Init(R, CLitrMantissa));
If Reg in [bAgent,bEksped] Then
ControlPeriod^.Options := ControlPeriod^.Options and not ofSelectable;
AddClientWin^.Insert(ControlPeriod);
  PInputLine(ControlPeriod)^.Validator := New(PFilterValidator, Init(['0','1','2','3','4','5','6','7','8','9']));

  R.Assign(53, 2, 61, 3);
  AddClientWin^.Insert(New(PLabel, Init(R, 'Пери~о~д:', ControlPeriod)));


R.Assign(73, 2, 79, 3);
Control1S := New(PInputLine, Init(R, CClientKod));
Control1S^.Options := Control1S^.Options and not ofSelectable;

If (Reg in [bAgent,bEksped]) And (StrToInt(CurrentPassword)<>0) Then
Control1S^.Options := Control1S^.Options and not ofSelectable;
AddClientWin^.Insert(Control1S);
  PInputLine(Control1S)^.Validator := New(PFilterValidator, Init(['0','1','2','3','4','5','6','7','8','9']));

  R.Assign(66, 2, 73, 3);
  AddClientWin^.Insert(New(PLabel, Init(R, 'КОД1С:', Control1S)));


R.Assign(4, 3, 24, 4);
Control := New(PColoredText, Init(R, 'Реквизиты партнера', $4F));
AddClientWin^.Insert(Control);

R.Assign(4, 4, 77, 13);
Control := New(PColoredText, Init(R, '', $3E));
Control^.Options := Control^.Options or ofFramed;
AddClientWin^.Insert(Control);

R.Assign(4, 13, 27, 14);
Control := New(PColoredText, Init(R, 'Реквизиты контрагента', $4F));
AddClientWin^.Insert(Control);

R.Assign(18, 4, 65, 5);
ControlFullName := New(PInputLine, Init(R, CAll));
AddClientWin^.Insert(ControlFullName);

  R.Assign(4, 4, 18, 5);
  AddClientWin^.Insert(New(PLabel, Init(R, 'Полн.назв~а~н.:', ControlFullName)));

R.Assign(18, 5, 65, 6);
ControlAdressU := New(PInputLine, Init(R, CAll));
If Reg in [bAgent,bEksped] Then
ControlAdressU^.Options := ControlAdressU^.Options and not ofSelectable;
AddClientWin^.Insert(ControlAdressU);

  R.Assign(9, 5, 18, 6);
  AddClientWin^.Insert(New(PLabel, Init(R, 'Адрес Ю:', ControlAdressU)));


R.Assign(18, 6, 42, 7);
ControlDogovorLoc := New(PInputLine, Init(R, CAll));
If (Sel=1) Or (Reg=1) Then
ControlDogovorLoc^.Options := ControlDogovorLoc^.Options and not ofSelectable;
If Reg in [bAgent,bEksped] Then
ControlDogovorLoc^.Options := ControlDogovorLoc^.Options and not ofSelectable;
AddClientWin^.Insert(ControlDogovorLoc);

  R.Assign(6, 6, 18, 7);
  AddClientWin^.Insert(New(PLabel, Init(R, 'N Дого~в~ора:', ControlDogovorLoc)));

R.Assign(47, 6, 65, 7);
ControlLizo := New(PRadioButtons, Init(R,
  NewSItem('Юр.',
  NewSItem('Физ.', Nil))));
If Reg in [bAgent,bEksped] Then
ControlLizo^.Options := ControlLizo^.Options and not ofSelectable;
AddClientWin^.Insert(ControlLizo);

  R.Assign(42, 6, 47, 7);
  AddClientWin^.Insert(New(PLabel, Init(R, 'В~и~д:', ControlLizo)));

R.Assign(18, 7, 39, 8);
ControlINNLoc := New(PInputLine, Init(R, CNAme));
If Reg in [bAgent,bEksped] Then
ControlINNLoc^.Options := ControlINNLoc^.Options and not ofSelectable;
AddClientWin^.Insert(ControlINNLoc);

  R.Assign(13, 7, 18, 8);
  AddClientWin^.Insert(New(PLabel, Init(R, 'И~Н~Н:', ControlINNLoc)));



R.Assign(44, 7, 65, 8);
ControlKPP := New(PInputLine, Init(R, CName));
If Reg in [bAgent,bEksped] Then
ControlKPP^.Options := ControlKPP^.Options and not ofSelectable;
AddClientWin^.Insert(ControlKPP);

  R.Assign(39, 7, 44, 8);
  AddClientWin^.Insert(New(PLabel, Init(R, 'КПП:', ControlKPP)));

R.Assign(59, 8, 65, 9);
ControlBank := New(PROInputLine, Init(R, CClientKod));
ControlBank^.Options := ControlBank^.Options and not ofFirstClick;
If Reg in [bAgent,bEksped] Then
ControlBank^.Options := ControlBank^.Options and not ofSelectable;
AddClientWin^.Insert(ControlBank);

  R.Assign(12, 8, 18, 9);
  AddClientWin^.Insert(New(PLabel, Init(R, 'Банк:', ControlBank)));

R.Assign(18, 8, 60, 9);
RFormatZerro(ClientElement.BankKod,CClientKod);
ss:=GetBankField(FBank,ClientElement.BankKod);
Format(ss,40);
ControlBankS := New(PColoredText, Init(R, ' '+ss+'│', $13));
AddClientWin^.Insert(ControlBankS);


(*
R.Assign(36, 19, 42, 20);
ControlRegion := New(PROInputLine, Init(R, CClientKod));
ControlRegion^.Options := ControlRegion^.Options and not ofFirstClick;
AddClientWin^.Insert(ControlRegion);

  R.Assign(1, 19, 9, 20);
  AddClientWin^.Insert(New(PLabel, Init(R, '~Р~егион:', ControlRegion)));

R.Assign(9, 19, 37, 20);
RFormatZerro(ClientElement.RegionKod,CClientKod);
ss:=GetRegionField(FName,ClientElement.RegionKod);
Format(ss,CNAme);
ControlRegionS := New(PColoredText, Init(R, ' '+ss+'│', $13));
AddClientWin^.Insert(ControlRegionS);

*)


{R.Assign(47, 8, 65, 9);}
R.Assign(18, 9, 36, 10);
ControlRSH := New(PInputLine, Init(R, CAll));
If Reg in [bAgent,bEksped] Then
ControlRSH^.Options := ControlRSH^.Options and not ofSelectable;
AddClientWin^.Insert(ControlRSH);

  {R.Assign(39, 8, 47, 9);}
  R.Assign(10, 9, 18, 10);
  AddClientWin^.Insert(New(PLabel, Init(R, 'Р/Счет:', ControlRSH)));

{R.Assign(38, 9, 49, 10);}
R.Assign(43, 9, 51, 10);
ControlOKONH := New(PInputLine, Init(R, CName));
If Reg in [bAgent,bEksped] Then
ControlOKONH^.Options := ControlOKONH^.Options and not ofSelectable;
AddClientWin^.Insert(ControlOKONH);

  {R.Assign(31, 9, 38, 10);}
  R.Assign(36, 9, 43, 10);
  AddClientWin^.Insert(New(PLabel, Init(R, 'ОКОНХ:', ControlOKONH)));

{R.Assign(55, 9, 65, 10);}
R.Assign(57, 9, 65, 10);
ControlOKPO := New(PInputLine, Init(R, CNAme));
If Reg in [bAgent,bEksped] Then
ControlOKPO^.Options := ControlOKPO^.Options and not ofSelectable;
AddClientWin^.Insert(ControlOKPO);

  {R.Assign(49, 9, 55, 10);}
  R.Assign(51, 9, 57, 10);
  AddClientWin^.Insert(New(PLabel, Init(R, 'ОКПО:', ControlOKPO)));

R.Assign(18, 10, 65, 11);
ControlSvid := New(PInputLine, Init(R, CAll));
If Reg in [bAgent,bEksped] Then
ControlSvid^.Options := ControlSvid^.Options and not ofSelectable;
AddClientWin^.Insert(ControlSvid);

  R.Assign(7, 10, 18, 11);
  AddClientWin^.Insert(New(PLabel, Init(R, 'Свид~е~т-во:', ControlSvid)));

R.Assign(18, 11, 65, 12);
ControlEnvir := New(PInputLine, Init(R, CAll));
If Reg in [bAgent,bEksped] Then
ControlEnvir^.Options := ControlEnvir^.Options and not ofSelectable;
AddClientWin^.Insert(ControlEnvir);

  R.Assign(8, 11, 18, 12);
  AddClientWin^.Insert(New(PLabel, Init(R, 'Ли~ц~ензия:', ControlEnvir)));

R.Assign(18, 12, 47, 13);
ControlVidan := New(PInputLine, Init(R, CAll));
If Reg in [bAgent,bEksped] Then
ControlVidan^.Options := ControlVidan^.Options and not ofSelectable;
AddClientWin^.Insert(ControlVidan);

  R.Assign(10, 12, 18, 13);
  AddClientWin^.Insert(New(PLabel, Init(R, 'Выдана:', ControlVidan)));

R.Assign(55, 12, 65, 13);
ControlSrokLoc := New(PInputLine, Init(R, CDate));
If (Sel=1) Or (Reg=1) Then
ControlSrokLoc^.Options := ControlSrokLoc^.Options and not ofSelectable;
If Reg in [bAgent,bEksped] Then
ControlSrokLoc^.Options := ControlSrokLoc^.Options and not ofSelectable;
AddClientWin^.Insert(ControlSrokLoc);
  PInputLine(ControlSrokLoc)^.Validator := New(PPXPictureValidator, Init(DateFiltr, True));

  R.Assign(46, 12, 55, 13);
  AddClientWin^.Insert(New(PLabel, Init(R, 'Сро~к~ до:', ControlSrokLoc)));

R.Assign(66, 4, 76, 13);
ControlDocFiltr := New(PCheckboxes, Init(R,
  NewSItem('Сп  ',
  NewSItem('~Т~ч ',
  NewSItem('ФЛ  ',
  NewSItem('СФ* ',
  NewSItem('СФБ ',
  NewSItem('Д*  ',
  NewSItem('ДСФ ',
  NewSItem('Д   ',
  NewSItem('ДСФБ', Nil)))))))))));
If Reg in [bEksped] Then
ControlDocFiltr^.Options := ControlDocFiltr^.Options and not ofSelectable;
AddClientWin^.Insert(ControlDocFiltr);


{R.Assign(11, 14, 57, 15);}
R.Assign(10, 14, 38, 15);
ControlTelefon := New(PInputLine, Init(R, CName));
AddClientWin^.Insert(ControlTelefon);

  {R.Assign(2, 14, 11, 15);}
  R.Assign(1, 14, 10, 15);
  AddClientWin^.Insert(New(PLabel, Init(R, 'Телефон:', ControlTelefon)));

{R.Assign(69, 14, 79, 15);}
R.Assign(50, 14, 60, 15);
ControlSeria := New(PInputLine, Init(R, CSeriaPassport));
AddClientWin^.Insert(ControlSeria);

  {R.Assign(57, 14, 69, 15);}
  R.Assign(38, 14, 50, 15);
  AddClientWin^.Insert(New(PLabel, Init(R, 'Серия пасп:', ControlSeria)));

{R.Assign(5, 15, 17, 16);}
R.Assign(63, 14, 75, 15);
ControlPasport := New(PInputLine, Init(R, CNumerPassport));
AddClientWin^.Insert(ControlPasport);

  {R.Assign(2, 15, 5, 16);}
  R.Assign(60, 14, 63, 15);
  AddClientWin^.Insert(New(PLabel, Init(R, 'N:', ControlPasport)));

{R.Assign(22, 15, 49, 16);}
R.Assign(6, 15, 31, 16);
ControlKto := New(PInputLine, Init(R, Call));
AddClientWin^.Insert(ControlKto);

  {R.Assign(17, 15, 22, 16);}
  R.Assign(1, 15, 6, 16);
  AddClientWin^.Insert(New(PLabel, Init(R, 'Кем:', ControlKto)));

{R.Assign(13, 16, 42, 17);}
R.Assign(35, 15, 57, 16);
ControlIP := New(PInputLine, Init(R, CAll));
AddClientWin^.Insert(ControlIP);

  {R.Assign(1, 16, 13, 17);}
  R.Assign(31, 15, 35, 16);
  AddClientWin^.Insert(New(PLabel, Init(R, 'ИП:', ControlIP)));

{R.Assign(53, 16, 79, 17);}
R.Assign(61, 15, 79, 16);
ControlDP := New(PInputLine, Init(R, CAll));
AddClientWin^.Insert(ControlDP);

  {R.Assign(42, 16, 53, 17);}
  R.Assign(57, 15, 61, 16);
  AddClientWin^.Insert(New(PLabel, Init(R, 'ДП:', ControlDP)));

{R.Assign(53, 17, 79, 18);}
R.Assign(10, 16, 40, 17);
ControlAdressF := New(PInputLine, Init(R, CAll));
AddClientWin^.Insert(ControlAdressF);

  {R.Assign(44, 17, 53, 18);}
  R.Assign(1, 16, 10, 17);
  AddClientWin^.Insert(New(PLabel, Init(R, 'Адрес ~Ф~:', ControlAdressF)));

R.Assign(46, 16, 79, 17);
ControlAuto := New(PInputLine, Init(R, CSertif));
AddClientWin^.Insert(ControlAuto);

  R.Assign(40, 16, 46, 17);
  AddClientWin^.Insert(New(PLabel, Init(R, 'Авто:', ControlAuto)));


{R.Assign(13, 17, 44, 18);}
R.Assign(12, 17, 79, 18);
ControlMsg := New(PInputLine, Init(R, CSertif));
AddClientWin^.Insert(ControlMsg);

  {R.Assign(2, 17, 13, 18);}
  R.Assign(1, 17, 12, 18);
  AddClientWin^.Insert(New(PLabel, Init(R, 'Сообщение:', ControlMsg)));


{R.Assign(13, 18, 18, 19);}
R.Assign(13, 18, 18, 19);
ControlDelta := New(PInputLine, Init(R, CLitrMantissa));
If Reg in [bAgent,bEksped] Then
ControlDelta^.Options := ControlDelta^.Options and not ofSelectable;
  PInputLine(ControlDelta)^.Validator := New(PFilterValidator, Init(['0','1','2','3','4','5','6','7','8','9']));
AddClientWin^.Insert(ControlDelta);

  {R.Assign(2, 18, 13, 19);}
  R.Assign(2, 18, 13, 19);
  AddClientWin^.Insert(New(PLabel, Init(R, 'Delta Max:', ControlDelta)));

If Reg in [bClient,bMAke] Then
Begin
R.Assign(18, 18, 32, 19);
ControlOtgruska := New(PCheckboxesLong, Init(R,
  NewSItem('Отгр~у~зка', Nil)));

{
If (Sel=1) Or (Reg=1) Then
ControlOtgruska^.Options := ControlOtgruska^.Options and not ofSelectable;
}

AddClientWin^.Insert(ControlOtgruska);

(*
R.Assign(42, 18, 79, 21);
ControlDebit := New(PCheckboxesLong, Init(R,
  NewSItem('~1~',
  NewSItem('~2~',
  NewSItem('~3~',
  NewSItem('~4~',
  NewSItem('~5~',
  NewSItem('~6~',
  NewSItem('~7~',
  NewSItem('~8~',
  NewSItem('~9~',
  NewSItem('1~0~',
  NewSItem('11',
  NewSItem('12',
  NewSItem('13',
  NewSItem('14',
  NewSItem('15', Nil)))))))))))))))));
*)


R.Assign(42, 18, 79, 22);
ControlDebitList := New(PMyListBox, Init(R, 'X', 4, Nil,False{ReadOnlye=False}));
ControlDebitList^.NewList(New(PCollection, Init(0,1)));

For c:=1 To Max30 Do
 Begin
  St:=IntToStr(C,CMantissa);
  RFormatZerro(st,CMantissa);
  ControlDebitList^.List^.Insert(New(PStringO,Init(st)));
  ControlDebitList^.SetRange(ControlDebitList^.List^.Count);
 End;


If (Sel in [1,2]) Or (Reg=bMAke) Then
ControlDebitList^.Options := ControlDebitList^.Options and not ofSelectable;
If Reg in [bAgent,bEksped] Then
ControlDebitList^.Options := ControlDebitList^.Options and not ofSelectable;

AddClientWin^.Insert(ControlDebitList);

  R.Assign(32, 18, 42, 19);
  AddClientWin^.Insert(New(PLabel, Init(R, 'Отсро~ч~ка:', ControlDebitList)));
End;

If Reg in [bAgent,bEksped] Then
Begin
R.Assign(42, 18, 79, 21);

{
ControlOtgruska := New(PCheckboxesLong, Init(R,
  NewSItem('~1~',
  NewSItem('~2~',
  NewSItem('~3~',
  NewSItem('~4~',
  NewSItem('~5~',
  NewSItem('~6~',
  NewSItem('~7~',
  NewSItem('~8~',
  NewSItem('~9~',
  NewSItem('1~0~',
  NewSItem('11',
  NewSItem('12',
  NewSItem('13',
  NewSItem('14',
  NewSItem('15',
  Nil)))))))))))))))));
}

ControlOtgruskaList := New(PMyListBox, Init(R, 'X', 5, Nil,False{ReadOnlye=False}));
ControlOtgruskaList^.NewList(New(PCollection, Init(0,1)));

For c:=1 To Max30 Do
 Begin
  St:=IntToStr(C,CMantissa);
  RFormatZerro(st,CMantissa);
  ControlOtgruskaList^.List^.Insert(New(PStringO,Init(st)));
  ControlOtgruskaList^.SetRange(ControlOtgruskaList^.List^.Count);
 End;

AddClientWin^.Insert(ControlOtgruskaList);

  R.Assign(32, 18, 42, 19);
  AddClientWin^.Insert(New(PLabel, Init(R, 'Отгр~у~зка:', ControlOtgruskaList)));

R.Assign(42, 21, 56, 22);
ControlDebit := New(PCheckboxesLong, Init(R,
  NewSItem('Отсро~ч~ка', Nil)));
If Reg in [bAgent,bEksped] Then
ControlDebit^.Options := ControlDebit^.Options and not ofSelectable;
AddClientWin^.Insert(ControlDebit);
End;


R.Assign(36, 19, 42, 20);
ControlRegion := New(PROInputLine, Init(R, CClientKod));
ControlRegion^.Options := ControlRegion^.Options and not ofFirstClick;
AddClientWin^.Insert(ControlRegion);

  R.Assign(1, 19, 9, 20);
  AddClientWin^.Insert(New(PLabel, Init(R, '~Р~егион:', ControlRegion)));

R.Assign(9, 19, 37, 20);
RFormatZerro(ClientElement.RegionKod,CClientKod);
ss:=GetRegionField(FName,ClientElement.RegionKod);
Format(ss,CNAme);
ControlRegionS := New(PColoredText, Init(R, ' '+ss+'│', $13));
AddClientWin^.Insert(ControlRegionS);


R.Assign(36, 20, 42, 21);
ControlRoute := New(PROInputLine, Init(R, CClientKod));
ControlRoute^.Options := ControlRoute^.Options and not ofFirstClick;
AddClientWin^.Insert(ControlRoute);

  R.Assign(1, 20, 9, 21);
  AddClientWin^.Insert(New(PLabel, Init(R, 'Мар~ш~рут:', ControlRoute)));

R.Assign(9, 20, 37, 21);
RFormatZerro(ClientElement.RouteKod,CClientKod);
ss:=GetRouteField(FName,ClientElement.RouteKod);
Format(ss,CNAme);
ControlRouteS := New(PColoredText, Init(R, ' '+ss+'│', $13));
AddClientWin^.Insert(ControlRouteS);


R.Assign(1, 21, 15, 22);
ControlMain := New(PCheckboxes, Init(R,
  NewSItem('Дочерний', Nil)));
{временно}
{ControlMain^.Options := ControlMain^.Options and not ofSelectable;}


If Reg in [bClient] Then
If AddClientWin^.FoundNoMain Then
ControlMain^.Options := ControlMain^.Options and not ofSelectable;



If Reg in [bClient] Then
If (ClientElement.Main=1) and (StrToInt(CurrentPassword)<>0)  Then
ControlMain^.Options := ControlMain^.Options and not ofSelectable;


If AddClientWin^.FoundNoMain Then
Begin
R.Assign(28, 13, 70, 14);
Control := New(PColoredText,Init(R, '<-Обнаружены дочерние клиенты!', $5E));
AddClientWin^.Insert(Control);
End;


If Reg in [bMake,bAgent,bEksped] Then
ControlMain^.Options := ControlMain^.Options and not ofSelectable;
AddClientWin^.Insert(ControlMain);



R.Assign(36, 21, 42, 22);
RFormatZerro(ClientElement.FantomKod,CClientKod);
ControlFantom := New(PROInputLine, Init(R, CClientKod));
ControlFantom^.Options := ControlFantom^.Options and not ofFirstClick;
{пока}
{ControlFantom^.Options := ControlFantom^.Options and not ofSelectable;}

If Reg in [bMake,bAgent,bEksped] Then{для агентов и экспедиторов}
ControlFantom^.Options := ControlFantom^.Options and not ofSelectable;

If (Reg in [bClient]) And (ClientElement.Main=0) Then{для агентов и экспедиторов}
ControlFantom^.Options := ControlFantom^.Options and not ofSelectable;


AddClientWin^.Insert(ControlFantom);

R.Assign(15, 21, 37, 22);
RFormatZerro(ClientElement.FantomKod,CClientKod);
Case Reg Of
bClient:ss:=GetClientField(FClient,ClientElement.FantomKod,Sel);
bMake:ss:=GetMakeField(FClient,ClientElement.FantomKod,Sel);
bAgent:ss:=GetAgentField(FClient,ClientElement.FantomKod);
bEksped:ss:=GetEkspedField(FClient,ClientElement.FantomKod);
Else;
End;
Format(ss,CClient);
ControlMainS := New(PColoredText, Init(R, ' '+ss+'│', $13));
AddClientWin^.Insert(ControlMainS);



    DelSpaceRight(ClientElement.Name);
    DelSpaceRight(ClientElement.FullName);
    DelSpaceRight(ClientElement.Adress);
    DelSpaceRight(ClientElement.AdressF);
    DelSpaceRight(ClientElement.VekselIP);
    DelSpaceRight(ClientElement.VekselDP);
    DelSpaceRight(ClientElement.Messages);



AddClientWin^.SetData(ClientElement);


If (Cod = kbGrayPlus)Or (Cod=kbAltF1)  Then
Begin
 R.Assign(11, 22, 52, 23);
 ClientNum := New(PBox, Init(R, 6, {PScrollbar(Control)}Nil));
 ClientNum^.NewList(New(PTextCollection, Init(0,1)));

Case Reg of
bClient:
Case Sel Of
0:Assign(ClF,Path^.Dat.ToClientBaseIndex+'Client.idx');
1:Assign(ClF,Path^.Dat.ToClientBaseIndex+'Sklad.idx');
2:Assign(ClF,Path^.Dat.ToClientBaseIndex+'Barter.idx');
Else;
End;

bMake:
Case Sel Of
0:Assign(ClF,Path^.Dat.ToClientBaseIndex+'Make.idx');
1:Assign(ClF,Path^.Dat.ToClientBaseIndex+'Sklad.idx');
2:Assign(ClF,Path^.Dat.ToClientBaseIndex+'Barter.idx');
Else Exit;
End;

bAgent:{агента}
  Assign(ClF,Path^.Dat.ToClientBaseIndex+'agent.idx');
bEksped:{экспедиторы}
  Assign(ClF,Path^.Dat.ToClientBaseIndex+'eksped.idx');

Else Exit;
End;




 OldFileMode:=FileMode;
 FileMode:=ReadOnlyN;

 Reset(ClF,SizeOf(KurzClientType));
 FileMode:=OldFileMode;

 While Not(Eof(ClF)) Do
  Begin
   New(CLE,Init);
   Count:=0;
   ReadBufKurzClient(ClF,ClE,Count);
For c:=1 To Count Do
Begin
   If Not(ClE^.Point.Dat[c].Employ) Then
   Begin
    Sartik:=IntToStr(CLE^.Point.Dat[c].Kod,CClientKod);
    RFormatZerro(Sartik,CClientKod);
    ClientNum^.List^.Insert(NewStr({MakeListElement.Name+}'│'+Sartik{ClientElement.Kod}));
    ClientNum^.SetRange(ClientNum^.List^.Count);
    ClientNum^.FocusItem(ClientNum^.List^.Count);
   End;
End;
   Dispose(Cle,Done);
  End;
 System.Close(ClF);

 If Cod=kbF4 Then ClientNum^.FocusItem(LoCation(ClientNum,s,True))
 Else ClientNum^.FocusItem(0);

 AddClientWin^.Insert(ClientNum);
 ClientNum^.HelpCtx:=$E011;

  R.Assign(1, 22, 11, 23);
  AddClientWin^.Insert(New(PLabel, Init(R, '~Д~оступны:', ClientNum)));
  {AddClientWin^.Insert(Control);}
 End;

 If Cod=kbF4 Then
 Begin
  R.Assign(2, 0, 6, 1);
  Control := New(PColoredText, Init(R, 'Код:', $3E));
  AddClientWin^.Insert(Control);
  R.Assign(6, 0, 10, 1);
  Control := New(PColoredText, Init(R, ClientElement.Kod,$3E));
  AddClientWin^.Insert(Control);



  R.Assign(48, 0, 79, 1);
  Control := New(PColoredText, Init(R, #3+GetOperatorField(FName,ClientElement.LastCaption)+' '+
  DateToDateString(DateMask,ClientElement.DateM)+' '+TimeToTimeString('hh:mm:ss',ClientElement.TimeM), $5E));
  AddClientWin^.Insert(Control);

 End;

AddClientWin^.SelectNext(False);

AddClientWin^.SetStatus;

NoInfoMsg;
c:=Desktop^.ExecView(AddClientWin);
If c<>cmCancel Then
 Begin
    AddClientWin^.GetData(ClientElement);


    ClientElement.Dopolnenie:=ClientElement2;{сохраняем в рабочую переменную дополнительные настройки карточки}

    DelSpaceRight(ClientElement.Name);
    DelSpaceRight(ClientElement.FullName);
    DelSpaceRight(ClientElement.Adress);
    DelSpaceRight(ClientElement.AdressF);
    DelSpaceRight(ClientElement.VekselIP);
    DelSpaceRight(ClientElement.VekselDP);
    DelSpaceRight(ClientElement.Messages);
    DelSpace(ClientElement.SrokLizensia);

{
   PStaticText(ControlRegion)^.GetText(SRegNAme);
   System.Delete(SRegNAme,1,1);
   ClientElement.RegionKod:=Copy(SRegNAme,1+CNAme+1,CCLIentKod);
                                        %
   PStaticText(ControlRoute)^.GetText(SRouteNAme);
   System.Delete(SRouteName,1,1);
   ClientElement.RouteKod:=Copy(SRouteName,1+CNAme+1,CCLIentKod);
}
{
   memC('Debit='+IntToStr(ClientElement.Debit,CKol));
   memC('DocFiltr='+IntToStr(ClientElement.DocFiltr,CKol));
}

   If Not (Reg in [bAgent,bEksped]) Then
   Begin
    If Sel in [0,2] Then
    Begin
    If (ClientElement.SrokLizensia[0]<>#0) Or (DefaultLizensia=1) Then
     Begin
      If Not(TestDate(ClientElement.SrokLizensia,k)) Then
       Begin
        MessageBox(^M+#3'Недопустимое значение срока действия лицензии ('+ClientElement.SrokLizensia+')!',nil,
        mfError+mfCancelButton);
       End;
     End;

     If DateStringToDate(DateMAsk,ClientElement.SrokLizensia)-
        DateStringToDate(DAteMask,FDAte)<=0 Then
        Begin
         SpecialBeep;
         MessageBox(^M+#3'Истек срок действия лицензии ('+ClientElement.SrokLizensia+')!',nil,
         mfWarning+mfCancelButton);
        End;

    End;{ClientVid=0}
   End;

    If ClientElement.Name[0]=#0 Then
   Begin
    MessageBox(^M+#3'Недопустимое имя элемента!',nil,mfError+mfCancelButton);
If (Cod=kbGrayPlus)Or (Cod=kbAltF1) Then
  Begin
   s:=ClientNum^.GetText(ClientNum^.Focused,ClientNum^.List^.Count);
   s:=Copy(s,1+CClient+1,CClientKod);
  ClientNum^.NewList(Nil);
  Dispose(ClientNum,Done);
  End;
  Dispose(Control,Done);
  Dispose(AddClientWin,Done);
    Goto 1;
   End;

    If ClientElement.FullName[0]=#0 Then
   Begin
    MessageBox(^M+#3'Недопустимое полное наименование элемента!',nil,mfError+mfCancelButton);
If (Cod=kbGrayPlus)Or (Cod=kbAltF1) Then
  Begin
   s:=ClientNum^.GetText(ClientNum^.Focused,ClientNum^.List^.Count);
   s:=Copy(s,1+CClient+1,CClientKod);
   ClientNum^.NewList(Nil);
   Dispose(ClientNum,Done);
  End;
   Dispose(Control,Done);
   Dispose(AddClientWin,Done);
   Goto 1;
   End;


  If Reg in [bClient] Then
  Begin
  {страховка на случай изменения}
  If ClientElement.Main=1 Then
   Begin
    If StrToInt(GetClientField(FMain,ClientElement.FantomKod,Reg))=1 Then
     Begin
      MessageBox(^M+#3+'Указанный Вами главный контрагент не может являться таковым! '+
	 'Измените код главной позиции!',nil,
	 mfError+mfCancelButton);

If (Cod=kbGrayPlus)Or (Cod=kbAltF1) Then
  Begin
   s:=ClientNum^.GetText(ClientNum^.Focused,ClientNum^.List^.Count);
   s:=Copy(s,1+CClient+1,CClientKod);
   ClientNum^.NewList(Nil);
   Dispose(ClientNum,Done);
  End;
      Dispose(Control,Done);
      Dispose(AddClientWin,Done);
      Goto 1;
     End;
   End;


  {страховка на случай изменения}
  If Reg in [bClient] Then
 Begin
  If ClientElement.Main=1 Then
  If Cod=kbF4 Then
   Begin
    If StrToInt(ClientElement.FantomKod)=StrToInt(ClientElement.Kod) Then
     Begin
      MessageBox(^M+#3+'Контрагент не может являться дочерним от самого себя!',nil,
	 mfError+mfCancelButton);
      Dispose(Control,Done);
      Dispose(AddClientWin,Done);
      Goto 1;
     End;
   End;

  End
   Else
    ClientElement.Main:=0;
 End
   Else
    ClientElement.Main:=0;




  C:=IOResult;

If (Cod=kbGrayPlus)Or (Cod=kbAltF1) Then
  Begin
   s:=ClientNum^.GetText(ClientNum^.Focused,ClientNum^.List^.Count);
   s:=Copy(s,1+1,CClientKod);
  end;

  {Если добавляем нового клиента то блокируем выбранный код}
  If (Cod=kbGrayPlus)Or (Cod=kbAltF1) Then
  Begin
    If Not(TestEmployClientAndLock(Reg,Sel,s)) Then
    Begin
     Beep;
     DInfoMsg('Не могу заблокировать элемент с кодом '+s+'... Попробуйте изменить код!',False);
     Application^.ClearEvent(Event);
     Application^.ClearEvent(Event);
      repeat
       Application^.GetEvent(Event);
      until (Event.What <> evNothing);
     NoInfoMsg;
     Application^.ClearEvent(Event);
     Dispose(ClientNum,Done);
     Dispose(Control,Done);
     Dispose(AddClientWin,Done);
     Goto 1;
    End;

  End;

  {исходим из того что блокировка удалась}

   UpStr(ClientElement.Name);
   UpStr(ClientElement.FullName);
   UpStr(ClientElement.Adress);
   UpStr(ClientElement.AdressF);
   UpStr(ClientElement.INN);
   UpStr(ClientElement.KPP);
   UpStr(ClientElement.R_Sh);
   UpStr(ClientElement.Seria);
   UpStr(ClientElement.Passport);
   UpStr(ClientElement.Okonh);
   UpStr(ClientElement.Okpo);
   UpStr(ClientElement.Enviropment);
   UpStr(ClientElement.Telefon);
   UpStr(ClientElement.VekselIP);
   UpStr(ClientElement.VekselDP);
   ClientElement.Employ:=True;
   ClientElement.RCD:=False;
   ClientElement.DAteM:=DateStringToDAte(DateMAsk,FDAte);

   RFormatZerro(ClientElement.RegionKod,CCLientKod);


   If ClientElement.Main=0 Then
   ClientElement.FantomKod:=ClientElement.Kod;



   If Reg in [bAgent,bEksped] Then
    Begin
     ClientElement.FantomKod:='0000';
     ClientElement.Main:=0;
     ClientElement.Status:=0;
     With ClientElement.Dopolnenie Do
      Begin
  CopyNaklC   :=1;
  CopyTTNC    :=1;
  CopySF      :=1;
  CopyProtocol:=1;
  CopyPrilog  :=1;
  CopyPrilog2 :=1;
  CopyShet    :=1;
  CopyPamatka :=1;
  CopyGTDTTN  :=1;
  CopyPKO     :=1;
  CopyRKO     :=1;
  CopyZakaz   :=1;
  EnableAuto  :=0;
  Price       :=0;
  EnableExport:=0;
  MailPath    [0]:=#0;
  Proz:='1.000';
      End;

    End;



   If (Cod=kbGrayPlus)Or (Cod=kbAltF1) Then ClientElement.Kod:=s;

   If (Reg=bClient) Then
   If Sel in [0,2] Then
   If StrToInt(ClientElement.BUCHKod)=StrToInt(NoBuchKod) Then ClientElement.BUCHKod:=ClientElement.Kod;

  RFormatZerro(ClientElement.BuchKod,CClientKod);

  ClientElement.DateM:=DateStringToDAte(DateMask,FDate);
  ClientElement.TimeM:=TimeStringToTime('hh:mm:ss',CurrentTimeString('hh:mm:ss'));
  ClientElement.LastCaption:=CurrentPassword;


  {если не удалось записать информацию}
  If Not (WriteLockClient(Reg,Sel,ClientElement)) Then
    Begin
     If (Cod=kbGrayPlus)Or (Cod=kbAltF1) Then Dispose(ClientNum,Done);
     Dispose(Control,Done);
     Dispose(AddClientWin,Done);
     Repeat
     Until (SetClientUnLock(s,Reg,Sel));
     Goto 1;
    End;


If Reg in [BClient] Then
If AddClientWin^.FoundNoMain Then{начинаем править связанные дочерние позиции}
 Begin
   ClientElement.Main:=1;
   ClientElement.FantomKod:=ClientElement.Kod;

Restart:
  For Count:=0 To LockPosition^.List^.Count-1 Do
   Begin

   Art:=Copy(LockPosition^.GetText(Count,LockPosition^.List^.Count),1+1,CClientKod);

   new(CL,init);
   Cl^.Dat.Kod:=Art;
   If GetClient(Cl,Reg) Then
    Begin
     With Cl^.DAt Do
      Begin
       BuchKod  :=ClientELement.BuchKod;
       FullName :=ClientELement.FullName;
       Adress   :=ClientELement.Adress;
       Dogovor  :=ClientELement.Dogovor;
       Lizo     :=ClientELement.Lizo;
       INN        :=ClientELement.INN;
       KPP        :=ClientELement.KPP;
       BankKod    :=ClientELement.BankKod;
       R_Sh       :=ClientELement.R_Sh;
       OKONH      :=ClientELement.OKONH;
       OKPO       :=ClientELement.OKPO;
       Svidetelstvo:=ClientELement.Svidetelstvo;
       Enviropment:=ClientELement.Enviropment;
       Kto        :=ClientELement.Kto;
       SrokLizensia :=ClientELement.SrokLizensia;
       DocFiltr   :=ClientELement.DocFiltr;
       FantomKod  :=ClientELement.Kod;
      End;{With}
    End{If GetClient}
     Else
      Begin
      DInfoMsg('Повторная попытка сохранить данные о клиенте '+Cl^.Dat.Kod,False);
      Dispose(Cl,Done);
      Goto Restart;
      End;


  If Not (WriteLockClient(Reg,Sel,Cl^.Dat)) Then
    Begin
     DInfoMsg('Повторная попытка сохранить данные о клиенте '+Cl^.Dat.Kod,False);
     Dispose(Cl,Done);
     Goto Restart;
    End;

   End;{For}


  For Count:=0 To LockPosition^.List^.Count-1 Do
   Begin
   Art:=Copy(LockPosition^.GetText(Count,LockPosition^.List^.Count),1+1,CClientKod);
   Repeat
   Until (SetClientUnLock(art,Reg,Sel));
   AddProtocol('Связанная корректировка реквизитов клиента ('+Art+')','','');
   End;

End;{FoundNoMain}





  If (Cod=kbGrayPlus)Or (Cod=kbAltF1) Then
  Begin
   If Reg in [bClient,bMake] Then AddProtocol('Добавление нового контрагента:'+ClientElement.Name+' ('+s+')','','');
   If Reg in [bAgent] Then  AddProtocol('Добавление нового агента:'+ClientElement.Name+' ('+s+')','','');
   If Reg in [bEksped] Then  AddProtocol('Добавление нового экспедитора:'+ClientElement.Name+' ('+s+')','','');
   Repeat
   Until (SetClientUnLock(s,Reg,Sel));
  End
  Else
   Begin
   If Reg in [bClient,bMAke] Then
   AddProtocol('Корректировка данных контрагента:'+ClientElement.Name+' ('+ClientElement.Kod+')','','');
   If Reg in [bAgent] Then
   AddProtocol('Корректировка данных агента:'+ClientElement.Name+' ('+ClientElement.Kod+')','','');
   If Reg in [bEksped] Then
   AddProtocol('Корректировка данных экспедитора:'+ClientElement.Name+' ('+ClientElement.Kod+')','','');
   End;
  AddClient:=True;
 End;





If (Cod=kbGrayPlus)Or (Cod=kbAltF1) Then
  Begin
  ClientNum^.NewList(Nil);
  Dispose(ClientNum,Done);
  End;
  Dispose(Control,Done);
  Dispose(LockPosition,Done);
  Dispose(AddClientWin,Done);
  PrevClient[0]:=#0;
end;


Destructor TAddClientWindow.Done;
Begin
ClearFind;

If Registration in [bClient,bMAke] Then
Begin
 Dispose(PMyListBox(ControlDebitList)^.List,Done);
End;

If Registration in [bAgent,bEksped] Then
Begin
 Dispose(PMyListBox(ControlOtgruskaList)^.List,Done);
End;
Dispose(ControlRegion,Done);
Dispose(ControlBank,Done);
Dispose(ControlRoute,Done);
TDialog.Done;
End;



Procedure ViewElement(Cod:ArtikulStr;{код элемента}Reg,Sel:Byte);
Label 1;
var
  R : TRect;
  Control : PView;
  s : TEnjoyStr;{!!!}
  sss : String;
  j,c: Word;
  k : LongInt;
  Dlg : PDialog;
  Event:TEvent;
  Count : Word;
  st,ss,SRegName,SRouteNAme : String[CAll];
  SArtik : ArtikulStr;
 ClientFile : ClientFileType;
 ClientElement : ClientType;
begin
ClearFind;

C:=IOResult;

Case Reg of
bClient:
Case Sel Of
0:sss:=Path^.Dat.ToClient+'Client.db';
1:sss:=Path^.Dat.ToClient+'Sklad.db';
2:sss:=Path^.Dat.ToClient+'Barter.db';
Else exit;
End;

bMake:
Case Sel Of
0:sss:=Path^.Dat.ToClient+'Make.db';
1:sss:=Path^.Dat.ToClient+'Sklad.db';
2:sss:=Path^.Dat.ToClient+'Barter.db';
Else Exit;
End;

bAgent:sss:=Path^.Dat.ToClient+'agent.db';

bEksped:sss:=Path^.Dat.ToClient+'eksped.db';

Else Exit;
End;

Assign(ClientFile,sss);
OldFileMode:=FileMode;
FileMode:=ReadOnlyN;
Reset(ClientFile);
C:=IOResult;
FileMode:=OldFileMode;
If C<>0 Then
Begin
 MessageBox(#3^M+#3'Ошибка доступа к файлу '+sss+' Код:'+IntToStr(C,CKol),nil,mfError+mfCancelButton);
 Exit;
End;

     s:=Cod;
     Seek(ClientFile,StrToInt(s));
     Repeat
      ReadClient(ClientFile,ClientElement);
     Until (Eof(ClientFile)) Or (StrToInt(ClientElement.Kod)=StrToInt(s));

     If Eof(ClientFile) And (StrToInt(ClientElement.Kod)<>StrToInt(s)) Then
      Begin
       NoInfoMsg;
       MessageBox(#3^M+#3'Элемент в базе не найден!',nil,mfError+mfCancelButton);
       System.Close(ClientFile);
       Exit;
      End;

System.Close(ClientFile);

ClientElement.BankKod:=IntToStr(StrToInt(ClientElement.BankKod),CCLientKod);
RFormatZerro(ClientElement.BankKod,CClientKod);

ClientElement.RouteKod:=IntToStr(StrToInt(ClientElement.RouteKod),CClientKOd);
RFormatZerro(ClientElement.RouteKod,CClientKOd);

ClientElement.RegionKod:=IntToStr(StrToInt(ClientElement.RegionKod),CClientKOd);
RFormatZerro(ClientElement.RegionKod,CClientKOd);

ClientElement.FantomKod:=IntToStr(StrToInt(ClientElement.FantomKod),CClientKOd);
RFormatZerro(ClientElement.FantomKod,CClientKOd);

ClientElement.Kod:=IntToStr(StrToInt(ClientElement.Kod),CClientKOd);
RFormatZerro(ClientElement.Kod,CClientKOd);


R.Assign(0, 0, 80, 23);
If Reg in [bClient,bMAke] Then
New(Dlg, Init(R, 'Контрагент'));

If Reg in [bAgent] Then
New(Dlg, Init(R, 'Агент'));

If Reg in [bEksped] Then
New(Dlg, Init(R, 'Экспедитор'));


Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.Palette := dpCyanDialog;
Dlg^.HelpCtx:=$E090;

R.Assign(9, 1, 31, 2);
Control := New(PInputLine, Init(R, CClient));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);

  R.Assign(1, 1, 9, 2);
Case Reg Of
bClient: Dlg^.Insert(New(PLabel, Init(R, 'К~л~иент:', Control)));
bMake: Dlg^.Insert(New(PLabel, Init(R, 'Постав:', Control)));
bAgent: Dlg^.Insert(New(PLabel, Init(R, ' Агент:', Control)));
bEksped: Dlg^.Insert(New(PLabel, Init(R, 'Экспед:', Control)));
Else;
End;

R.Assign(39, 1, 47, 2);
Control := New(PInputLine, Init(R, CIZena));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);

  R.Assign(34, 1, 39, 2);
  Dlg^.Insert(New(PLabel, Init(R, 'VIP:', Control)));

R.Assign(54, 1, 61, 2);
Control := New(PInputLine, Init(R, CIZena));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);

  R.Assign(47, 1, 54, 2);
  Dlg^.Insert(New(PLabel, Init(R, 'Ли~м~ит:', Control)));

R.Assign(69, 1, 79, 2);
Control := New(PInputLine, Init(R, CDAte));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PPXPictureValidator, Init('[##-##-##]', True));

  R.Assign(61, 1, 69, 2);
  Dlg^.Insert(New(PLabel, Init(R, 'Сверка:', Control)));

R.Assign(9, 2, 52, 3);
Control := New(PRadioButtons, Init(R,
  NewSItem('Акт',NewSItem('~П~ас',NewSItem('~С~Б',NewSItem('~З~акр',NewSItem('?', Nil)))))));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);

  R.Assign(1, 2, 9, 3);
  Dlg^.Insert(New(PLabel, Init(R, 'Статус:', Control)));

R.Assign(61, 2, 66, 3);
Control := New(PInputLine, Init(R, CLitrMantissa));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['0','1','2','3','4','5','6','7','8','9']));

  R.Assign(53, 2, 61, 3);
  Dlg^.Insert(New(PLabel, Init(R, 'Пери~о~д:', Control)));


R.Assign(73, 2, 79, 3);
Control := New(PInputLine, Init(R, CClientKod));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['0','1','2','3','4','5','6','7','8','9']));

  R.Assign(66, 2, 73, 3);
  Dlg^.Insert(New(PLabel, Init(R, 'КОД1С:', Control)));


R.Assign(4, 3, 24, 4);
Control := New(PColoredText, Init(R, 'Реквизиты партнера', $4F));
Dlg^.Insert(Control);

R.Assign(4, 4, 77, 13);
Control := New(PColoredText, Init(R, '', $3E));
Control^.Options := Control^.Options or ofFramed;
Dlg^.Insert(Control);

R.Assign(4, 13, 27, 14);
Control := New(PColoredText, Init(R, 'Реквизиты контрагента', $4F));
Dlg^.Insert(Control);

R.Assign(18, 4, 65, 5);
Control := New(PInputLine, Init(R, CAll));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);

  R.Assign(4, 4, 18, 5);
  Dlg^.Insert(New(PLabel, Init(R, 'Полн.назв~а~н.:', Control)));

R.Assign(18, 5, 65, 6);
Control := New(PInputLine, Init(R, CAll));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);

  R.Assign(9, 5, 18, 6);
  Dlg^.Insert(New(PLabel, Init(R, 'Адрес Ю:', Control)));


R.Assign(18, 6, 42, 7);
Control := New(PInputLine, Init(R, CAll));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);

  R.Assign(6, 6, 18, 7);
  Dlg^.Insert(New(PLabel, Init(R, 'N Дого~в~ора:', Control)));

R.Assign(47, 6, 65, 7);
Control := New(PRadioButtons, Init(R,
  NewSItem('Юр.',
  NewSItem('Физ.', Nil))));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);

  R.Assign(42, 6, 47, 7);
  Dlg^.Insert(New(PLabel, Init(R, 'В~и~д:', Control)));

R.Assign(18, 7, 39, 8);
Control := New(PInputLine, Init(R, CNAme));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);

  R.Assign(13, 7, 18, 8);
  Dlg^.Insert(New(PLabel, Init(R, 'И~Н~Н:', Control)));



R.Assign(44, 7, 65, 8);
Control := New(PInputLine, Init(R, CName));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);

  R.Assign(39, 7, 44, 8);
  Dlg^.Insert(New(PLabel, Init(R, 'КПП:', Control)));


{банк}

R.Assign(59, 8, 65, 9);
Control := New(PROInputLine, Init(R, CClientKod));
Control^.Options := Control^.Options and not ofFirstClick;
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);

  R.Assign(12, 8, 18, 9);
  Dlg^.Insert(New(PLabel, Init(R, 'Банк:', Control)));

R.Assign(18, 8, 60, 9);
RFormatZerro(ClientElement.BankKod,CClientKod);
ss:=GetBankField(FBank,ClientElement.BankKod);
Format(ss,40);
Control := New(PColoredText, Init(R, ' '+ss+'│', $13));
Dlg^.Insert(Control);


R.Assign(18, 9, 36, 10);
Control := New(PInputLine, Init(R, CAll));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);

  R.Assign(10, 9, 18, 10);
  Dlg^.Insert(New(PLabel, Init(R, 'Р/Счет:', Control)));


R.Assign(43, 9, 51, 10);
Control := New(PInputLine, Init(R, CName));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);

  R.Assign(36, 9, 43, 10);
  Dlg^.Insert(New(PLabel, Init(R, 'ОКОНХ:', Control)));

R.Assign(57, 9, 65, 10);
Control := New(PInputLine, Init(R, CNAme));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);

  R.Assign(51, 9, 57, 10);
  Dlg^.Insert(New(PLabel, Init(R, 'ОКПО:', Control)));

R.Assign(18, 10, 65, 11);
Control := New(PInputLine, Init(R, CAll));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);

  R.Assign(7, 10, 18, 11);
  Dlg^.Insert(New(PLabel, Init(R, 'Свид~е~т-во:', Control)));

R.Assign(18, 11, 65, 12);
Control := New(PInputLine, Init(R, CAll));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);

  R.Assign(8, 11, 18, 12);
  Dlg^.Insert(New(PLabel, Init(R, 'Ли~ц~ензия:', Control)));

R.Assign(18, 12, 47, 13);
Control := New(PInputLine, Init(R, CAll));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);

  R.Assign(10, 12, 18, 13);
  Dlg^.Insert(New(PLabel, Init(R, 'Выдана:', Control)));

R.Assign(55, 12, 65, 13);
Control := New(PInputLine, Init(R, CDate));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);

  R.Assign(46, 12, 55, 13);
  Dlg^.Insert(New(PLabel, Init(R, 'Сро~к~ до:', Control)));

R.Assign(66, 4, 76, 13);
Control := New(PCheckboxes, Init(R,
  NewSItem('Сп  ',
  NewSItem('Тч ',
  NewSItem('ФЛ  ',
  NewSItem('СФ* ',
  NewSItem('СФБ ',
  NewSItem('Д*  ',
  NewSItem('ДСФ ',
  NewSItem('Д   ',
  NewSItem('ДСФБ', Nil)))))))))));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);


R.Assign(10, 14, 38, 15);
Control := New(PInputLine, Init(R, CName));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);

  {R.Assign(2, 14, 11, 15);}
  R.Assign(1, 14, 10, 15);
  Dlg^.Insert(New(PLabel, Init(R, 'Телефон:', Control)));

{R.Assign(69, 14, 79, 15);}
R.Assign(50, 14, 60, 15);
Control := New(PInputLine, Init(R, CSeriaPassport));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);

  {R.Assign(57, 14, 69, 15);}
  R.Assign(38, 14, 50, 15);
  Dlg^.Insert(New(PLabel, Init(R, 'Серия пасп:', Control)));

{R.Assign(5, 15, 17, 16);}
R.Assign(63, 14, 75, 15);
Control := New(PInputLine, Init(R, CNumerPassport));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);

  {R.Assign(2, 15, 5, 16);}
  R.Assign(60, 14, 63, 15);
  Dlg^.Insert(New(PLabel, Init(R, 'N:', Control)));

{R.Assign(22, 15, 49, 16);}
R.Assign(6, 15, 31, 16);
Control := New(PInputLine, Init(R, Call));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);

  {R.Assign(17, 15, 22, 16);}
  R.Assign(1, 15, 6, 16);
  Dlg^.Insert(New(PLabel, Init(R, 'Кем:', Control)));

{R.Assign(13, 16, 42, 17);}
R.Assign(35, 15, 57, 16);
Control := New(PInputLine, Init(R, CAll));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);

  {R.Assign(1, 16, 13, 17);}
  R.Assign(31, 15, 35, 16);
  Dlg^.Insert(New(PLabel, Init(R, 'ИП:', Control)));

{R.Assign(53, 16, 79, 17);}
R.Assign(61, 15, 79, 16);
Control := New(PInputLine, Init(R, CAll));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);

  {R.Assign(42, 16, 53, 17);}
  R.Assign(57, 15, 61, 16);
  Dlg^.Insert(New(PLabel, Init(R, 'ДП:', Control)));

{R.Assign(53, 17, 79, 18);}
R.Assign(10, 16, 40, 17);
Control := New(PInputLine, Init(R, CAll));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);

  {R.Assign(44, 17, 53, 18);}
  R.Assign(1, 16, 10, 17);
  Dlg^.Insert(New(PLabel, Init(R, 'Адрес ~Ф~:', Control)));

R.Assign(46, 16, 79, 17);
Control := New(PInputLine, Init(R, CSertif));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);

  R.Assign(40, 16, 46, 17);
  Dlg^.Insert(New(PLabel, Init(R, 'Авто:', Control)));


{R.Assign(13, 17, 44, 18);}
R.Assign(12, 17, 79, 18);
Control := New(PInputLine, Init(R, CSertif));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);

  {R.Assign(2, 17, 13, 18);}
  R.Assign(1, 17, 12, 18);
  Dlg^.Insert(New(PLabel, Init(R, 'Сообщение:', Control)));



{R.Assign(13, 18, 18, 19);}
R.Assign(13, 18, 18, 19);
Control := New(PInputLine, Init(R, CLitrMantissa));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);

  {R.Assign(2, 18, 13, 19);}
  R.Assign(2, 18, 13, 19);
  Dlg^.Insert(New(PLabel, Init(R, 'Delta Max:', Control)));



If Reg in [bClient,bMAke] Then
Begin
R.Assign(18, 18, 32, 19);
Control := New(PCheckboxesLong, Init(R,
NewSItem('Отгр~у~зка', Nil)));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);


R.Assign(42, 18, 79, 22);
ControlDebitList1 := New(PMyListBox, Init(R, 'X', 4, Nil,True{ReadOnly=True}));
ControlDebitList1^.NewList(New(PCollection, Init(0,1)));

For c:=1 To Max30 Do
 Begin
  St:=IntToStr(C,CMantissa);
  RFormatZerro(st,CMantissa);
  ControlDebitList1^.List^.Insert(New(PStringO,Init(st)));
  ControlDebitList1^.SetRange(ControlDebitList1^.List^.Count);
 End;
ControlDebitList1^.Options := ControlDebitList1^.Options and not ofSelectable;
Dlg^.Insert(ControlDebitList1);

  R.Assign(32, 18, 42, 19);
  Dlg^.Insert(New(PLabel, Init(R, 'Отсро~ч~ка:', ControlDebitList1)));
End;


If Reg in [bAgent,bEksped] Then
Begin
R.Assign(42, 18, 79, 21);
ControlOtgruskaList1 := New(PMyListBox, Init(R, 'X', 5, Nil,True{ReadOnly=True}));
ControlOtgruskaList1^.NewList(New(PCollection, Init(0,1)));

For c:=1 To Max30 Do
 Begin
  St:=IntToStr(C,CMantissa);
  RFormatZerro(st,CMantissa);
  ControlOtgruskaList1^.List^.Insert(New(PStringO,Init(st)));
  ControlOtgruskaList1^.SetRange(ControlOtgruskaList1^.List^.Count);
 End;
ControlOtgruskaList1^.Options := ControlOtgruskaList1^.Options and not ofSelectable;
Dlg^.Insert(ControlOtgruskaList1);

  R.Assign(32, 18, 42, 19);
  Dlg^.Insert(New(PLabel, Init(R, 'Отгр~у~зка:', ControlOtgruskaList1)));

R.Assign(42, 21, 56, 22);
Control := New(PCheckboxesLong, Init(R,
  NewSItem('Отсро~ч~ка', Nil)));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);
End;


R.Assign(36, 19, 42, 20);
Control := New(PROInputLine, Init(R, CClientKod));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);

  R.Assign(1, 19, 9, 20);
  Dlg^.Insert(New(PLabel, Init(R, '~Р~егион:', Control)));

R.Assign(9, 19, 37, 20);
RFormatZerro(ClientElement.RegionKod,CClientKod);
ss:=GetRegionField(FName,ClientElement.RegionKod);
Format(ss,CNAme);
Control := New(PColoredText, Init(R, ' '+ss+'│', $13));
Dlg^.Insert(Control);


R.Assign(36, 20, 42, 21);
Control := New(PROInputLine, Init(R, CClientKod));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);

  R.Assign(1, 20, 9, 21);
  Dlg^.Insert(New(PLabel, Init(R, 'Мар~ш~рут:', Control)));

R.Assign(9, 20, 37, 21);
RFormatZerro(ClientElement.RouteKod,CClientKod);
ss:=GetRouteField(FName,ClientElement.RouteKod);
Format(ss,CNAme);
Control := New(PColoredText, Init(R, ' '+ss+'│', $13));
Dlg^.Insert(Control);


R.Assign(1, 21, 15, 22);
Control := New(PCheckboxes, Init(R,
  NewSItem('Дочерний', Nil)));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);

R.Assign(36, 21, 42, 22);
RFormatZerro(ClientElement.FantomKod,CClientKod);
Control := New(PROInputLine, Init(R, CClientKod));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);

R.Assign(15, 21, 37, 22);
RFormatZerro(ClientElement.FantomKod,CClientKod);
Case Reg Of
bClient:ss:=GetClientField(FClient,ClientElement.FantomKod,Sel);
bMAke:ss:=GetMakeField(FClient,ClientElement.FantomKod,Sel);
bAgent:ss:=GetAgentField(FClient,ClientElement.FantomKod);
bEksped:ss:=GetEkspedField(FClient,ClientElement.FantomKod);
Else;
End;
Format(ss,CClient);
Control := New(PColoredText, Init(R, ' '+ss+'│', $13));
Dlg^.Insert(Control);



Dlg^.SetData(ClientElement);

  R.Assign(2, 0, 6, 1);
  Control := New(PColoredText, Init(R, 'Код:', $3E));
  Dlg^.Insert(Control);
  R.Assign(6, 0, 10, 1);
  Control := New(PColoredText, Init(R, ClientElement.Kod,$3E));
  Dlg^.Insert(Control);



  R.Assign(48, 0, 79, 1);
  Control := New(PColoredText, Init(R, #3+GetOperatorField(FName,ClientElement.LastCaption)+' '+
  DateToDateString(DateMask,ClientElement.DateM)+' '+TimeToTimeString('hh:mm:ss',ClientElement.TimeM), $5E));
  Dlg^.Insert(Control);

Dlg^.SelectNext(False);
NoInfoMsg;
c:=Desktop^.ExecView(Dlg);


Dispose(Control,Done);

If Reg in [bClient,bMAke] Then
Begin
 Dispose(PMyListBox(ControlDebitList1)^.List,Done);
End;

If Reg in [bAgent,bEksped] Then
Begin
 Dispose(PMyListBox(ControlOtgruskaList1)^.List,Done);
End;


Dispose(Dlg,Done);
end;






Procedure TClientWindow.ShowClientList(Var st:AllStr;Selector,Regim:Word;VidClienta,Net:Boolean;
          NoLocked1,VidNoLocked1,NoLocked2,VidNoLocked2:Integer;Var Res: Word);
Label 1;
var
  R : TRect;
  Control : PView;
  s : String[CSertif];
  c,j: Word;
  Clf : File;
  CLE : PBufKurzClientType;
  Count : Word;
  St1 : ArtikulStr;
begin
ClearFind;
memcc;
Res:=0;
Debitors:=VidClienta;

If InputZakaz<>1 Then
WithNetLock:=Net
Else
WithNetLock:=False;

NotLockedCod1:=NoLocked1;
NotLockedCod2:=NoLocked2;
VidNotLockedCod1:=VidNoLocked1;
VidNotLockedCod2:=VidNoLocked2;
R.Assign(0, 0, 80, 23);
Begin
Case Regim Of
0:New(ClientWindow, Init(R, 'Выбор клиента'));
1:New(ClientWindow, Init(R, 'Выбор поставщика'));
Else;
End;
End;

ClientWindow^.Options := ClientWindow^.Options or ofCenterX Or ofCenterY;


Reg:=Regim;
Sel:=Selector;
R.Assign(79, 1, 80, 18);
Control := New(PScrollBar, Init(R));
ClientWindow^.Insert(Control);

If  Reg=0 Then
Begin
R.Assign(0, 1, 80, 18);
Client := New(PBox, Init(R, 3, PScrollbar(Control)));
Client^.NewList(New(PTextCollection, Init(0,1)));
End
Else
 Begin
  R.Assign(0, 1, 80, 18);
  MakeList := New(PBox, Init(R, 3, PScrollbar(Control)));
  MakeList^.NewList(New(PTextCollection, Init(0,1)));
 End;
Case Reg Of
0:Begin
    Case Selector Of
     0:Assign (ClF,Path^.Dat.ToClientBaseIndex+'Client.idx');
     1:Assign (ClF,Path^.Dat.ToClientBaseIndex+'Sklad.idx');
     2:Assign (ClF,Path^.Dat.ToClientBaseIndex+'Barter.idx');
     Else;
     End;{CAse}
  End;
1:Begin
    Case Selector Of
     0:Assign (ClF,Path^.Dat.ToClientBaseIndex+'Make.idx');
     1:Assign (ClF,Path^.Dat.ToClientBaseIndex+'Sklad.idx');
     2:Assign (ClF,Path^.Dat.ToClientBaseIndex+'Barter.idx');
     Else;
     End;{CAse}
  End;
Else;
End;

c:=IOResult;
OldFileMode:=FileMode;
FileMode:=$42;
Reset (ClF,SizeOf(KurzClientType));
c:=IOResult;
FileMode:=OldFileMode;
If c=0 Then
Begin
{AInfo('Читаю списки...');}
While Not(Eof(ClF)) Do
 Begin
    DInfoMsgShkala('Читаю списки контрагентов. Ждите... ',0,FileSize(CLF),FilePos(CLF));
    Count:=0;
    New(CLE,Init);
    ReadBufKurzClient(Clf,CLE,Count);
  For c:=1 To Count Do

  Begin
  If ClE^.Point.Dat[c].Employ Then
   Begin
    Format (ClE^.Point.Dat[c].Name,CClient);
    St1:=IntToStr(ClE^.Point.Dat[c].Kod,CClientKod);
    RFormatZerro(St1,CClientKod);
    {If (ClE^.Point.Dat[1]=ClE^.Point.Dat[2]) Then;}
    If Reg=0 Then
    Begin
    {If Odd(c) Then}
    Begin
{номер договора}
{адрес фактический}
{лицензия}
    Client^.List^.Insert(NewStr(ClE^.Point.Dat[c].Name+'│'+St1{ClE^.Point.Dat[c].Kod}));
    Client^.SetRange(Client^.List^.Count);
    End;
    End
    Else
    Begin
    MakeList^.List^.Insert(NewStr(ClE^.Point.Dat[c].Name+'│'+St1{ClE^.Point.Dat[c].Kod}));
    MakeList^.SetRange(MakeList^.List^.Count);
    End;
   End;{Employ}
  End;{For}
     Dispose(CLE,Done);
 End;{Eof}
System.Close(ClF);
NoInfoMsg;
End
Else
 Begin
  MessageBox(^M+#3'Ошибка доступа к файлам базы !',nil,mfError+mfCanCelButton);
  Goto 1;
 End;

s:=Copy(st,Pos('│',st)+1{1+CClient+1},CClientKod);

If Reg=0 Then
Begin
Client^.FocusItem(Location(Client,S,ProdagaWindow));
Client^.HelpCtx:=$E171;
ClientWindow^.Insert(Client);
PrevClient:=Copy(Client^.GetText(Client^.Focused,CLient^.List^.Count),1+CClient+1,CClientKod);
End
Else
 Begin
MakeList^.FocusItem(Location(MakeList,S,ProdagaWindow));
MakeList^.HelpCtx:=$E171;
PrevClient:=Copy(MakeList^.GetText(MakeList^.Focused,MakeList^.List^.Count),1+CMake+1,CMakeKod);
ClientWindow^.Insert(MakeList);
 End;

R.Assign(1, 19, 12, 20);
Control := New(PColoredText, Init(R, 'N Договора:', $74));
ClientWindow^.Insert(Control);

R.Assign(1, 18, 12, 19);
Control := New(PColoredText, Init(R, '   Адрес Ф:', $74));
ClientWindow^.Insert(Control);

R.Assign(12, 18, 57, 19);
ControlAdress := New(PColoredText, Init(R, #3+'??', $7E));
ClientWindow^.Insert(ControlAdress);

R.Assign(12, 19, 57, 20);
ControlDogovor := New(PColoredText, Init(R, #3+'??', $7E));
ClientWindow^.Insert(ControlDogovor);

R.Assign(1, 20, 10, 21);
Control := New(PColoredText, Init(R, #3+'Лицензия:', $74));
ClientWindow^.Insert(Control);

R.Assign(10, 20, 55, 21);
ControlEnviropment := New(PColoredText, Init(R, #3+'??', $7E));
ClientWindow^.Insert(ControlEnviropment);



R.Assign(56, 20, 61, 21);
Control := New(PColoredText, Init(R, #3+'ИНН:', $74));
ClientWindow^.Insert(Control);

R.Assign(61, 20, 79, 21);
ControlINN := New(PColoredText, Init(R, #3+'??', $7E));
ClientWindow^.Insert(ControlINN);



R.Assign(1, 21, 7, 22);
Control := New(PColoredText, Init(R, 'Лимит:', $74));
ClientWindow^.Insert(Control);

R.Assign(7, 21, 22, 22);
{If Regim=1 Then
ControlLimit := New(PColoredText, Init(R, #3+GetMAkeField(FLimit,PrevClient,Selector), $7E))
Else}
ControlLimit := New(PColoredText, Init(R, #3{GetClientField(FLimit,PrevClient,Selector)}, $7E));

ClientWindow^.Insert(ControlLimit);

R.Assign(24, 21, 29, 22);
Control := New(PColoredText, Init(R, 'Долг:', $74));
ClientWindow^.Insert(Control);

{
R.Assign(29, 21, 44, 22);
ControlDolg := New(PColoredText, Init(R, #3+'???', $FE));
ClientWindow^.Insert(ControlDolg);
}

               R.Assign(30, 21, 35, 22);
               ControlDolg := New(PColoredText, Init(R, 'Space', $7E));
               ClientWindow^.Insert(ControlDolg);

               R.Assign(36, 21, 44, 22);
               ControlDolgText := New(PColoredText, Init(R, 'Пересчет', $70));
               ClientWindow^.Insert(ControlDolgText);


R.Assign(45, 21, 71, 22);
Control := New(PColoredText, Init(R, 'Срок действия лицензии до:', $74));
ClientWindow^.Insert(Control);

R.Assign(71, 21, 79, 22);
ControlSrokLizensia := New(PColoredText, Init(R, #3+'', $7E));
ClientWindow^.Insert(ControlSrokLizensia);

R.Assign(58, 18, 79, 19);
ControlStatus := New(PColoredText, Init(R, #3+'', $7E));
ClientWindow^.Insert(ControlStatus);

{If VidClienta And (Sel=0) Then
Begin
R.Assign(29, 22, 51, 23);
Control := New(PColoredText, Init(R, #3' F2 - Рассчитать долг', $71));
Control^.Options := Control^.Options or ofCenterX;
ClientWindow^.Insert(Control);
End;}

ClientWindow^.SelectNext(False);
PrevClient[0]:=#0;
NoInfoMsg;



c:=Desktop^.ExecView(ClientWindow);
If c<>CmCancel Then

   If c=CmOk Then Res:=2;
   If c=CmYes Then Res:=3;
   If c=CmCancel Then Res:=1;

   If  Reg=0 Then
   St:=Client^.GetText(Client^.Focused,Client^.List^.Count)
   Else
   St:=MakeList^.GetText(MakeList^.Focused,MakeList^.List^.Count);

   If ShowClients=1 Then
    Begin
     s:=Copy(st,1+CCLient+1,CClientKod);
     If  Reg=0 Then
     s:=GetClientField(FMessages,s,Selector)
     Else
     s:=GetMAkeField(FMessages,s,Selector);
     DelSpaceRight(s);

     If s[0]<>#0 Then
      Begin
       SpecialBeep;
       MessageBox(^M+#3+s,Nil,mfInformation+mfCancelButton);
      End;
     s:=Copy(st,1+CCLient+1,CClientKod);
     If  (((Reg=0) And (Selector in [0,2])) Or
         ((Reg=1) And (Selector in [2]))) And TestComment(s,Selector) Then
        ViewClientCommentProc1(s,Selector);
    End;

1:
{If VidClienta Then }
Dispose(COntrol,Done);
Dispose(ClientWindow,Done);
end;






Procedure TClientWindow.Refresh(Reg,sel:Word);
var
  R : TRect;
  Control : PView;
  s : String[CSertif];
  c,Cod,Count: Word;
  Clf  : File;
  CLE : PBufKurzClientType;
  St1 : artikulStr;
begin
ClearFind;

  If  Reg=0 Then
  Cod:=Client^.Focused
  Else
  Cod:=MakeList^.Focused;

Case Reg Of
0:Begin
{ If Sel = 0 Then Assign (ClientFile,Path^.Dat.ToClient+'Client.db')
  Else Assign (ClientFile,Path^.Dat.ToClient+'Sklad.db');}

    Case Sel Of
     0:Assign (ClF,Path^.Dat.ToClientBaseIndex+'Client.idx');
     1:Assign (ClF,Path^.Dat.ToClientBaseIndex+'Sklad.idx');
     2:Assign (ClF,Path^.Dat.ToClientBaseIndex+'Barter.idx');
     Else;
     End;{CAse}


  Client^.NewList(Nil);
  Client^.NewList(New(PTextCollection, Init(0,1)));
  End;

1:Begin
{ If Sel = 0 Then Assign (ClientFile,Path^.Dat.ToClient+'Make.db')
  Else Assign (ClientFile,Path^.Dat.ToClient+'Sklad.db');}

    Case Sel Of
     0:Assign (ClF,Path^.Dat.ToClientBaseIndex+'Make.idx');
     1:Assign (ClF,Path^.Dat.ToClientBaseIndex+'Sklad.idx');
     2:Assign (ClF,Path^.Dat.ToClientBaseIndex+'Barter.idx');
     Else;
     End;{CAse}

  MakeList^.NewList(Nil);
  MakeList^.NewList(New(PTextCollection, Init(0,1)));
  End;
Else;
End;

c:=IOResult;

OldFileMode:=FileMode;
FileMode:=ReadOnlyN;
Reset (ClF,SizeOf(KurzClientType));
c:=IOResult;
FileMode:=OldFileMode;
If c=0 Then
Begin
{AInfo('Обновляю списки клиентов...');}
While Not(Eof(ClF)) Do
 Begin
    DInfoMsgShkala('Читаю списки контрагентов. Ждите... ',0,FileSize(CLF),FilePos(CLF));
    New(CLE,Init);
    ReadBufKurzClient(Clf,CLE,Count);
  For c:=1 To Count Do
  Begin
  If ClE^.Point.Dat[c].Employ Then
   Begin
    Format (ClE^.Point.Dat[c].Name,CClient);
    St1:=IntToStr(ClE^.Point.Dat[c].Kod,CClientKod);
    RFormatZerro(St1,CClientKod);

    If  Reg=0 Then
    Begin
    Client^.List^.Insert(NewStr(ClE^.Point.Dat[c].Name+'│'+st1{ClE^.Point.Dat[c].Kod}));
    Client^.SetRange(Client^.List^.Count);
    End
    Else
    Begin
    MakeList^.List^.Insert(NewStr(ClE^.Point.Dat[c].Name+'│'+st1{ClE^.Point.Dat[c].Kod}));
    MakeList^.SetRange(MakeList^.List^.Count);
    End;
   End;
  End;{For}
   Dispose(CLE,Done);
 End;
NoInfoMsg;
System.Close(ClF);
If Cod<>0 Then Dec(Cod);

If Reg =0 Then  Client^.FocusItem(Cod);
If Reg =1 Then  MakeList^.FocusItem(Cod);
{NoInfo;}
End
Else
 Begin
  MessageBox(^M+#3'Ошибка доступа к файлам базы !',nil,mfError+mfCanCelButton);
  Exit;
 End;
Redraw;
PrevClient[0]:=#0;
end;


Procedure TClientWindow.DrawCurrent(Reg,Sel: Byte);
Var s: String[CAll];
    R : TRect;
    Cl : PClientType;
    Kod : ArtikulStr;
Begin
  New(Cl,Init);
  Case Reg Of
  0:Begin
     Cl^.DAt.Kod:=Copy(PrevClient,1+CClient+1,CClientKod);
     GetClient(Cl,Sel);
    End;
  1:Begin
     Cl^.DAt.Kod:=Copy(PrevClient,1+CClient+1,CClientKod);
     GetMAke(Cl,Sel);
    End;
  Else;
  End;

  Dispose(COntrolEnviropment,Done);
  R.Assign(10, 20, 55, 21);
  ControlEnviropment := New(PColoredText, Init(R, Cl^.Dat.Enviropment, $7E));
  Insert(ControlEnviropment);

  Dispose(COntrolINN,Done);
  R.Assign(61, 20, 79, 21);
  ControlINN := New(PColoredText, Init(R, Cl^.Dat.INN, $7E));
  ClientWindow^.Insert(ControlINN);

  Dispose(ControlAdress,Done);
  R.Assign(12, 18, 57, 19);
  ControlAdress := New(PColoredText, Init(R, Cl^.Dat.AdressF, $7E));
  ClientWindow^.Insert(ControlAdress);

  Dispose(ControlLimit,Done);
  R.Assign(7, 21, 22, 22);
  ControlLimit := New(PColoredText, Init(R, #3+Cl^.Dat.Limit, $7E));
  Insert(ControlLimit);

If Debitors And (Sel=0) Then
  Begin
  s:=Copy(PrevClient,1+CClient+1,CClientKod);
      If s[0]<>#0 Then
      Begin
{              AInfo('Считаю долг клиента...');}
               {S:=CalcDolg(s);}
               Dispose(ControlDolg,Done);
               Dispose(ControlDolgText,Done);
               R.Assign(30, 21, 35, 22);
               ControlDolg := New(PColoredText, Init(R, 'Space', $7E));
               ClientWindow^.Insert(ControlDolg);

               R.Assign(36, 21, 44, 22);
               ControlDolgText := New(PColoredText, Init(R, 'Пересчет', $70));
               ClientWindow^.Insert(ControlDolgText);

               {s:=Copy(PrevClient,1+CClient+1,CClientKod);}
               {GetClientField(FDebit,s,Sel)}
               If Cl^.Dat.Debit=0 Then s:='КОНСИГНАЦИЯ ЗАПРЕЩЕНА'
               Else  s:='';

               Dispose(ControlStatus,Done);
               R.Assign(58, 18, 79, 19);
               If Ord(s[0])=0 Then
               ControlStatus := New(PColoredText, Init(R, #3+s, $FE))
               Else
               ControlStatus := New(PColoredText, Init(R, #3+s, $5E));
               Insert(ControlStatus);
{              Noinfo;}
      End;
  End;
{ Case Reg Of
  0:s:=GetClientField(FNDogovor,Copy(PrevClient,1+CClient+1,CClientKod),Sel);
  1:s:=GetMakeField(FNDogovor,Copy(PrevClient,1+CClient+1,CClientKod),Sel);
  Else;
  End;}

  Dispose(COntrolDogovor,Done);
  R.Assign(12, 19, 57, 20);
  ControlDogovor := New(PColoredText, Init(R, #3+Cl^.Dat.Dogovor, $7E));
  Insert(ControlDogovor);
{ Case Reg Of
  0:s:=GetClientField(FSrok,Copy(PrevClient,1+CClient+1,CClientKod),Sel);
  1:s:=GetMakeField(FSrok,Copy(PrevClient,1+CClient+1,CClientKod),Sel);
  Else;
  End;}
  Dispose(ControlSrokLizensia,Done);
  R.Assign(71, 21, 79, 22);
  ControlSrokLizensia := New(PColoredText, Init(R, #3+Cl^.Dat.SrokLizensia, $7E));
  Insert(ControlSrokLizensia);

  Dispose(Cl,Done);

  Redraw;
End;



Destructor TClientWindow.Done;
Begin
ClearFind;

Dispose(ControlEnviropment,Done);
Dispose(ControlINN,Done);
Dispose(ControlLimit,Done);
Dispose(ControlDolg,Done);
Dispose(ControlDolgText,Done);
Dispose(ControlDogovor,Done);
Dispose(ControlSrokLizensia,Done);
Dispose(ControlStatus,Done);

If  Reg=0 Then
Dispose(Client,Done)
Else
Dispose(MakeList,Done);
TDialog.Done;
End;









procedure TClientWindow.HandleEvent(var Event: TEvent);
Var R : TRect;
    test : Word;
    s : TMyString;
    L : Boolean;
   Art,cod : ArtikulStr;
   Op : StrName;

Function LockSelect:Boolean;
Var s : String;
    Event : TEvent;
    R : Boolean;
Begin
  LockSelect:=False;
  If  Reg=0 Then
  s:=Client^.GetText(Client^.Focused,Client^.List^.Count)
  Else
  s:=MakeList^.GetText(MakeList^.Focused,MakeList^.List^.Count);
  s:=Copy(s,1+CClient+1,CClientKod);

  If  Reg=0 Then R:=GetClientEmploy(s,Sel);
  If Reg=1 Then R:=GetMakeEmploy(s,Sel);

  If Not(r) Then
   Begin
    Beep;
    DInfoMsg('Не могу заблокировать клиента с кодом '+s+'. Клиент отмечен как удаленный!',False);
    ClearEvent(Event);
    ClearEvent(Event);
    repeat
    Application^.GetEvent(Event);
    {until (Event.What in [evKeyDown,evMouseDown]);}
    until (Event.What <> evNothing);
    NoInfoMsg;
    ClearEvent(Event);
    Event.What:=EvCommand;
    Event.Command:=cmRefresh;
    PutEvent(Event);
    ClearEvent(Event);
    Exit;
   End;



  If InputZakaz<>1 Then
  If ((StrToInt(s)=NotLockedCod1)And(Sel=VidNotLockedCod1))
   Or((StrToInt(s)=NotLockedCod2)And(Sel=VidNotLockedCod2)) Then
    Begin
     LockSelect:=True;
     Exit;
    End;

  If SetClientLock(s,Reg,Sel,Op) Then LockSelect:=True
  Else
   Begin
    Beep;
    If Op[0]<>#0 Then
    DInfoMsg('Клиент ['+s+'] используется '+Op+'! Не могу заблокировать!',False)
    Else
    DInfoMsg('Клиент ['+s+'] запрещен на вашем складе! Не могу заблокировать!',False);
    ClearEvent(Event);
    ClearEvent(Event);
    repeat
    Application^.GetEvent(Event);
    {until (Event.What in [evKeyDown,evMouseDown]);}
    until (Event.What <> evNothing);
    NoInfoMsg;
    ClearEvent(Event);
   End;

End;


Function LockSelect1(Var Art:ArtikulStr):Boolean;
Var s : String;
    Res : Word;
    Event : TEvent;
    R : Boolean;
    CL : PClientType;
Begin
  LockSelect1:=False;

  If  Reg=0 Then
  s:=Client^.GetText(Client^.Focused,Client^.List^.Count)
  Else
  s:=MakeList^.GetText(MakeList^.Focused,MakeList^.List^.Count);

  s:=Copy(s,1+CClient+1,CClientKod);
  Art:=s;

  If Reg=0 Then
  Begin
  New(cl,Init);
  Cl^.Dat.Kod:=art;
  If Not GetClient(Cl,Reg) Then
   Begin
    Dispose(Cl,Done);
    Beep;
    DInfoMsg('Не могу заблокировать клиента с кодом '+art+'. Клиент отмечен как удаленный!',False);
    ClearEvent(Event);
    ClearEvent(Event);
    repeat
    Application^.GetEvent(Event);
    {until (Event.What in [evKeyDown,evMouseDown]);}
    until (Event.What <> evNothing);
    NoInfoMsg;
    ClearEvent(Event);
    Event.What:=EvCommand;
    Event.Command:=cmRefresh;
    PutEvent(Event);
    ClearEvent(Event);
    Exit;
   End;

  If Cl^.DAt.Main=1 Then
   Begin
    Res:=SelectEditRegim;
    If Res=2 Then Begin
                   Dispose(Cl,Done);
                   Exit;
                  End;

    If Res=0 Then
      Begin
	  Art:=Cl^.Dat.KOd;
      End;

    If Res=1 Then
     Begin
	 Art:=Cl^.Dat.FantomKod;
     End;
   End
   Else
    Begin
	 Art:=Cl^.Dat.Kod;
    End;

  Client^.FocusItem(Location(Client,Art,False));
  Redraw;

  Dispose(Cl,Done);
  End;


  If  Reg=0 Then R:=GetClientEmploy(art,Sel);
  If  Reg=1 Then R:=GetMakeEmploy(art,Sel);


  If Not(r) Then
   Begin
    Beep;
    DInfoMsg('Не могу заблокировать клиента с кодом '+art+'. Клиент отмечен как удаленный!',False);
    ClearEvent(Event);
    ClearEvent(Event);
    repeat
    Application^.GetEvent(Event);
    {until (Event.What in [evKeyDown,evMouseDown]);}
    until (Event.What <> evNothing);
    NoInfoMsg;
    ClearEvent(Event);
    Event.What:=EvCommand;
    Event.Command:=cmRefresh;
    PutEvent(Event);
    ClearEvent(Event);
    Exit;
   End;



  If InputZakaz<>1 Then
  If ((StrToInt(art)=NotLockedCod1)And(Sel=VidNotLockedCod1))
   Or((StrToInt(art)=NotLockedCod2)And(Sel=VidNotLockedCod2)) Then
    Begin
     LockSelect1:=True;
     Exit;
    End;

  If SetClientLock(art,Reg,Sel,Op) Then LockSelect1:=True
  Else
   Begin
    Beep;
    If Op[0]<>#0 Then
    DInfoMsg('Клиент ['+art+'] используется '+art+'! Не могу заблокировать!',False)
    Else
    DInfoMsg('Клиент ['+art+'] запрещен на вашем складе! Не могу заблокировать!',False);
    ClearEvent(Event);
    ClearEvent(Event);
    repeat
    Application^.GetEvent(Event);
    {until (Event.What in [evKeyDown,evMouseDown]);}
    until (Event.What <> evNothing);
    NoInfoMsg;
    ClearEvent(Event);
   End;

End;


Function TestEmploy:Boolean;
Var s : String;
    Event : TEvent;
    R : Boolean;
Begin
  TestEmploy:=False;
  If  Reg=0 Then
  s:=Client^.GetText(Client^.Focused,Client^.List^.Count)
  Else
  s:=MakeList^.GetText(MakeList^.Focused,MakeList^.List^.Count);
  s:=Copy(s,1+CClient+1,CClientKod);

  r:=False;
  If  Reg=0 Then R:=GetClientEmploy(s,Sel);
  If Reg=1 Then R:=GetMakeEmploy(s,Sel);

  If Not(r) Then
   Begin
    Beep;
    DInfoMsg('Нельзя работать с клиентом '+s+'. Клиент отмечен как удаленный!',False);
    ClearEvent(Event);
    ClearEvent(Event);
    repeat
    Application^.GetEvent(Event);
    {until (Event.What in [evKeyDown,evMouseDown]);}
    until (Event.What <> evNothing);
    NoInfoMsg;
    ClearEvent(Event);
    Event.What:=EvCommand;
    Event.Command:=cmRefresh;
    PutEvent(Event);
    ClearEvent(Event);
    Exit;
   End
   Else
   TestEmploy:=True;
End;


Procedure UnlockAll;
Var  f : LockBazFileType;
     cl : LockBazType;
     r : Byte;
     cod : ArtikulStr;
Begin
DInfoMsg('Минуточку...',False);
Case Reg Of
0:Begin
 {If Sel = 0 Then Assign (F,Path^.Dat.ToClient+'Client.db')
  Else Assign (F,Path^.Dat.ToClient+'Sklad.db');}
    Case Sel Of
     0:Assign (F,Path^.Dat.ToClient+'Client.lck');
     1:Assign (F,Path^.Dat.ToClient+'Sklad.lck');
     2:Assign (F,Path^.Dat.ToClient+'Barter.lck');
     Else;
     End;{CAse}
  End;
1:Begin
{ If Sel = 0 Then Assign (F,Path^.Dat.ToClient+'Make.db')
  Else Assign (F,Path^.Dat.ToClient+'Sklad.db');}
    Case Sel Of
     0:Assign (F,Path^.Dat.ToClient+'Make.lck');
     1:Assign (F,Path^.Dat.ToClient+'Sklad.lck');
     2:Assign (F,Path^.Dat.ToClient+'Barter.lck');
     Else;
     End;{CAse}
  End;
Else;
End;

r:=IOResult;
Reset(f);
r:=IOResult;
If R<>0 Then
 Begin
  NoInfoMsg;
  Exit;
 End;


While Not(Eof(f)) Do
  Begin
   ReadLockBaz(f,Cl);
   r:=IOResult;

   cl.Locked:=False;
   Seek(f,FilePos(f)-1);
   r:=IOResult;

   Write(f,cl);
   r:=IOResult;

  End;
System.close(f);
   r:=IOResult;
NoInfoMsg;
AddProtocol('Общая деблокировка клиентов {сетевая безопасность транзакций}','','');
End;



begin

  Case Event.What Of
  evKeyDown :

CAse Event.CharCode Of
' '      :Begin

If Debitors And (Sel=0) Then
  Begin
  s:=Copy(Client^.GetText(Client^.Focused,Client^.List^.Count),1+CClient+1,CClientKod);
  If s[0]<>#0 Then
      Begin
               DInfoMsg('Считаю текущую задолженнось клиента...',True);
               S:=CalcDolg(s);
               Dispose(ControlDolg,Done);
               Dispose(ControlDolgText,Done);
               R.Assign(29, 21, 32, 22);
               ControlDolg := New(PColoredText, Init(R, #3+'', $7E));
               ClientWindow^.Insert(ControlDolg);

               R.Assign(29, 21, 44, 22);
               ControlDolgText := New(PColoredText, Init(R, #3+s, $5E));
               ClientWindow^.Insert(ControlDolgText);
               NoInfoMsg;
               Redraw;
      End;
  End;
           End;
Else;
End;
   Else;
   End;


  Case Event.What Of
  evKeyDown :
  Case Event.KeyCode Of
     kbDel: Begin

If Not(TestOpenDate1(FDate)) Then
   Begin
    MessageBox(#3^M+#3'Доступ к данным за '+FDate+' заблокирован!',Nil,mfError+mfCancelButton);
    ClearEvent(Event);
    Exit;
   End;

If (GlobalReadOnly=1) Or (ReadOnlyConst=1) Then
   Begin
    MessageBox(#3^M+ReadOnlyStr^,Nil,mfWarning+mfCancelButton);
    ClearEvent(Event);
    Exit;
   End;


If Not(TestSetupKurs(FDate)) Then
   Begin
    {MessageBox(#3^M+#3'Не установлен курс USD на '+FDate+'!',Nil,mfError+mfCancelButton);}
    ClearEvent(Event);
    Exit;
   End;

     L:=False;
     If  Reg=0 Then
     Begin
      If (Client^.State and sfFocused <> 0) And (Client^.List<>Nil)And(Client^.List^.Count>=2) Then L:=True;
     End
     Else
     Begin
      If (MakeList^.State and sfFocused <> 0) And (MakeList^.List<>Nil)And(MakeList^.List^.Count>=2) Then L:=True;
     End;

     If L Then
            Begin
     If Password(20) Then
             Begin
             s:=#3^M+#3'Желаете удалить запись?';
             If MessageBox(s,nil,mfConfirmation+mfOkCancel)=cmOk
              Then
              Begin
                If  Reg=0 Then
                s:=Client^.GetText(Client^.Focused,Client^.List^.Count)
                Else
                s:=MakeList^.GetText(MakeList^.Focused,MakeList^.List^.Count);
                s:=Copy(s,1+CClient+1,CClientKod);
                If (((StrToInt(s)=NotLockedCod1)And(Sel=VidNotLockedCod1)And(InputZakaz<>1)))
                Or((StrToInt(s)=NotLockedCod2)And(Sel=VidNotLockedCod2)And(InputZakaz<>1)) Then
                Begin
                 ClearEvent(Event);
                 Beep;
                 DInfoMsg(' Клиент с кодом '+s+' сейчас Вами используется. Клиента нельзя удалить!',False);
                 ClearEvent(Event);
                 ClearEvent(Event);
                 repeat
                  Application^.GetEvent(Event);
                 until (Event.What <> evNothing);
                 NoInfoMsg;
                 ClearEvent(Event);
                 Exit;
                End;

              {сетевая блокировка}
               If Not(LockSelect) Then
                Begin
                 ClearEvent(Event);
                 Redraw;
                 Exit;
                End;

                 test := IOResult;
                 If  Reg=0 Then
                 s:=Client^.GetText(Client^.Focused,Client^.List^.Count)
                 Else
                 s:=MakeList^.GetText(MakeList^.Focused,MakeList^.List^.Count);
                 s:=Copy(s,1+CClient+1,CClientKod);

                 If (StrToInt(Rek^.Dat.Kod)=StrToInt(s)) And (Sel=1) Then
                     Begin
                      ClearEvent(Event);
                      Repeat
                      Until (SetClientUnLock(s,Reg,Sel));
                      Exit;
                     End;
                 Case Reg Of
0:begin
 {If Sel = 0 Then Assign (ClientFile,Path^.Dat.ToClient+'Client.db')
  Else Assign (ClientFile,Path^.Dat.ToClient+'Sklad.db');}
     Case Sel Of
     0:Assign (ClientFile,Path^.Dat.ToClient+'Client.db');
     1:Assign (ClientFile,Path^.Dat.ToClient+'Sklad.db');
     2:Assign (ClientFile,Path^.Dat.ToClient+'Barter.db');
     Else;
     End;{CAse}

  end;
1:begin
{ If Sel = 0 Then Assign (ClientFile,Path^.Dat.ToClient+'Make.db')
  Else Assign (ClientFile,Path^.Dat.ToClient+'Sklad.db');}
       Case Sel Of
     0:Assign (ClientFile,Path^.Dat.ToClient+'Make.db');
     1:Assign (ClientFile,Path^.Dat.ToClient+'Sklad.db');
     2:Assign (ClientFile,Path^.Dat.ToClient+'Barter.db');
     Else;
     End;{CAse}

  end;
Else;
End;{CAse}

                 ClientElement.Name[0]:=#0;
                 ClientElement.FullName[0]:=#0;
                 ClientElement.Employ:=False;
                 ClientElement.Limit[0]:=#0;
                 ClientElement.Lizo:=0;
                 ClientElement.Dogovor[0]:=#0;
                 {
                 For Test:=1 To CPunkt Do
                 ClientElement.Punkt[Test,0]:=#0;}
                 ClientElement.RCD:=False;
                 ClientElement.Adress[0]:=#0;
                 ClientElement.AdressF[0]:=#0;
                 ClientElement.BankKod:=NoBankStr;
                 ClientElement.INN[0]:=#0;
                 ClientElement.R_Sh[0]:=#0;
                 ClientElement.SrokLizensia[0]:=#0;
                 ClientElement.Seria[0]:=#0;
                 ClientElement.Passport[0]:=#0;
                 ClientElement.Svidetelstvo[0]:=#0;
                 ClientElement.VekselIP[0]:=#0;
                 ClientElement.VekselDP[0]:=#0;
                 ClientElement.Enviropment[0]:=#0;
                 ClientElement.Debit:=0;
                 ClientElement.Messages[0]:=#0;
                 ClientElement.Vidan[0]:=#0;
                 ClientElement.Kod:=s;

  If Not (WriteLockClient(Reg,Sel,ClientElement)) Then
    Begin
     MessageBox(^M+#3'Ошибка доступа к файлам клиентов !',nil,mfError+mfCanCelButton);
     Repeat
     Until (SetClientUnLock(s,Reg,Sel));
     ClearEvent(Event);
     Exit;
    End;

    Repeat
    Until (SetClientUnLock(s,Reg,Sel));
                 AddProtoCol('Удаление клиента:'+s,'','');
                 If (Reg=0)And(Sel=0) Then
                 If MessageBox(^M+#3+'Удалить персональные файлы клиента?',Nil,MfWarning+mfOkCancel)=cmOk Then
                    DelDolgFile(s);
                 If Reg=0 Then
                 Begin
                  Client^.List^.AtFree(Client^.Focused);
                  Client^.SetRange(Client^.List^.Count);
                  If Client^.Focused>0 Then
                  Client^.FocusItem(Client^.Focused);
                  If (cLIENT^.Focused>=Client^.List^.Count) and(cLIENT^.Focused>0) Then
                  Client^.FocusItem(Client^.Focused-1);
                  End
                 Else
                 Begin
                  MakeList^.List^.AtFree(MakeList^.Focused);
                  MakeList^.SetRange(MakeList^.List^.Count);
                  If MakeList^.Focused>0 Then
                  MakeList^.FocusItem(MakeList^.Focused);
                  If (MakeList^.Focused>=MakeList^.List^.Count) and(MakeList^.Focused>0) Then
                  MakeList^.FocusItem(MakeList^.Focused-1);
                 End;

              End;
              End;
            ClearEvent(Event);
            End;
             Redraw;
            End;
kbF7      :Begin
            If InputFindINN(INN) then
             Begin
              FindINN(Reg,Sel,INN);
              PrevClient[0]:=#0;
              Redraw;
             End;
           End;


kbAlt1         : If Password(13) Then UnlockAll;
kbAltRusD      : If Password(12) Then
                   Begin
                If  Reg=0 Then
                s:=Client^.GetText(Client^.Focused,Client^.List^.Count)
                Else
                s:=MakeList^.GetText(MakeList^.Focused,MakeList^.List^.Count);
                s:=Copy(s,1+CClient+1,CClientKod);

               Repeat
               Until (SetClientUnLock(s,Reg,Sel));

                   End;
kbGrayPlus,kbAltF1,kbF4: Begin
     L:=False;
     If Reg=0 Then
     Begin
If(Client^.State and sfFocused <> 0)And(Not(Event.KeyCode=kbF4))Or
((Event.KeyCode=kbF4)And(Client^.List<>Nil)And(Client^.List^.Count>=1)) Then l:=True;
     End
     Else
     Begin
If(MAkeList^.State and sfFocused <> 0)And(Not(Event.KeyCode=kbF4))Or
((Event.KeyCode=kbF4)And(MAkeList^.List<>Nil)And(MakeList^.List^.Count>=1)) Then l:=True;
     End;
            If L Then
            Begin
              {сетевая блокировка}
      If Event.KeyCode=kbF4 Then
      Begin
      If Reg=0 Then
      Art:=Copy(Client^.GetText(Client^.Focused,Client^.List^.Count),1+CClient+1,CClientKod)
      Else
      Art:=Copy(MakeList^.GetText(MakeList^.Focused,MakeList^.List^.Count),1+CClient+1,CClientKod);

               If Not(LockSelect1(Art)) Then
                         Begin
                           ClearEvent(Event);
                           Exit;
                         End;
      End;

            Case Reg Of
            0:Begin
               If Add^.AddClient(Event.KeyCode,ClientElement,Reg,Sel,{Client}Art) Then
               Begin
               If (Event.KeyCode=kbF4)And(Client^.List<>Nil)And(Client^.List^.Count>=1) Then
                Client^.List^.AtFree(Client^.Focused);
                Format(ClientElement.Name,CClient);
                Client^.List^.Insert(NewStr(ClientElement.Name+'│'+ClientElement.Kod));
                Client^.SetRange(Client^.List^.Count);
                Client^.FocusItem(LoCation(Client,ClientElement.Kod,False));
                Redraw;
               End
               Else
               Begin
                If (Event.KeyCode=kbF4)And(Client^.List<>Nil)And(Client^.List^.Count>=1) Then
                Begin
                s:=Client^.GetText(Client^.Focused,Client^.List^.Count);
                ClientElement.Kod:=Copy(s,1+CClient+1,CClientKod);
                End;
               End;

              End;
            1:Begin

             If Add^.AddClient(Event.KeyCode,ClientElement,Reg,Sel,{MakeList}Art) Then
              Begin
              If (Event.KeyCode=kbF4)And(MakeList^.List<>Nil)And(MakeList^.List^.Count>=1) Then
               MakeList^.List^.AtFree(MakeList^.Focused);
               Format(ClientElement.Name,CClient);
               MakeList^.List^.Insert(NewStr(ClientElement.Name+'│'+ClientElement.Kod));
               MakeList^.SetRange(MakeList^.List^.Count);
               MakeList^.FocusItem(LoCation(MakeList,ClientElement.Kod,False));
               Redraw;
              End
              Else
               Begin
                If (Event.KeyCode=kbF4)And(MakeList^.List<>Nil)And(MakeList^.List^.Count>=1) Then
                Begin
                s:=MakeList^.GetText(MakeList^.Focused,MakeList^.List^.Count);
                ClientElement.Kod:=Copy(s,1+CClient+1,CClientKod);
                End;
               End;
              End;
            Else;
            End;{Case}

            If Event.KeyCode=kbF4 Then
            Begin
               If Reg=0 Then Cod:=ClientElement.Kod;
               If Reg=1 Then Cod:=ClientElement.Kod;


               If Not(((StrToInt(Cod)=NotLockedCod1)And(Sel=VidNotLockedCod1)And(InputZakaz<>1))
                Or((StrToInt(Cod)=NotLockedCod2)And(Sel=VidNotLockedCod2)And(InputZakaz<>1))) Then

               Repeat
               Until (SetClientUnLock(Cod,Reg,Sel));
            End;

            End;
            ClearEvent(Event);
            Redraw;
            End;

kbAltF4: Begin
     L:=False;
     If Reg=0 Then
     Begin
If((Event.KeyCode=kbAltF4)And(Client^.List<>Nil)And(Client^.List^.Count>=1)) Then l:=True;
If Not (Sel in [0,2]) Then l:=False;
(*
Reg=0 {продажа}
sel=0 {клиент}
sel=2 {бартер}

Reg=1 {поставка}
sel=2 {бартер}
*)
     End
     Else
     Begin
If((Event.KeyCode=kbAltF4)And(MAkeList^.List<>Nil)And(MakeList^.List^.Count>=1)) Then l:=True;
If Not (Sel in [2]) Then l:=False;
     End;
            If L Then
            Begin
            If Password(7) Then
            Begin
              {сетевая блокировка}
               If Not(LockSelect) Then
                         Begin
                           ClearEvent(Event);
                           Exit;
                         End;

                If  Reg=0 Then
                s:=Client^.GetText(Client^.Focused,Client^.List^.Count)
                Else
                s:=MakeList^.GetText(MakeList^.Focused,MakeList^.List^.Count);
                s:=Copy(s,1+CClient+1,CClientKod);

                 EditClientCommentProc(s,Sel);

               Repeat
               Until (SetClientUnLock(s,Reg,Sel));
             End;
            End;{L}
            ClearEvent(Event);
            Redraw;
            End;{kbAltF4}

kbAltF3: Begin
     L:=False;
     If Reg=0 Then
     Begin
If((Event.KeyCode=kbAltF3)And(Client^.List<>Nil)And(Client^.List^.Count>=1)) Then l:=True;
If Not (Sel in [0,2]) Then l:=False;
(*
Reg=0 {продажа}
sel=0 {клиент}
sel=2 {бартер}

Reg=1 {поставка}
sel=2 {бартер}
*)
     End
     Else
     Begin
If((Event.KeyCode=kbAltF3)And(MAkeList^.List<>Nil)And(MakeList^.List^.Count>=1)) Then l:=True;
If Not (Sel in [2]) Then l:=False;
     End;
            If L Then
            Begin
                If  Reg=0 Then
                s:=Client^.GetText(Client^.Focused,Client^.List^.Count)
                Else
                s:=MakeList^.GetText(MakeList^.Focused,MakeList^.List^.Count);
                s:=Copy(s,1+CClient+1,CClientKod);
            If Password(7) Then
            Begin
                ViewClientCommentProc(s,Sel);
            End
             Else
                ViewClientCommentProc1(s,Sel);

            End;{L}
            ClearEvent(Event);
            Redraw;
            End;{kbAltF4}
kbF3: Begin
     L:=False;
     If Reg=0 Then
     Begin
      s:=Client^.GetText(Client^.Focused,Client^.List^.Count);
      s:=Copy(s,1+CClient+1,CClientKod);
      ViewElement(s,Reg,Sel);
     End
     Else
     Begin
      s:=MakeList^.GetText(MakeList^.Focused,MakeList^.List^.Count);
      s:=Copy(s,1+CClient+1,CClientKod);
      ViewElement(s,Reg,Sel);
     End;
     ClearEvent(Event);
     Redraw;
      End;

kbF9: Begin
       CorrectBaza(Reg,Sel);
       ClearEvent(Event);
       Redraw;
      End;
{     kbEsc: Begin
              Event.What:=evCommand;
              Event.Command:=cmCancel;
              PutEvent(Event);
            End;
     kbShiftTab,kbCtrlLeft:
            Begin
              Event.What:=evCommand;
              Event.Command:=cmYes;
              PutEvent(Event);
            End;
     kbTab,kbCtrlRight,kbEnter:
            Begin
              Event.What:=evCommand;
              Event.Command:=cmOk;
              PutEvent(Event);
            End;}
      Else;
      End;{KeyDown}
evCommand:
 Case Event.Command Of
 cmRefresh: Refresh(Reg,Sel);

 cmReestrReport:Begin
                   ImportClientInfo(Reg,Sel);
                End;
 cmPrintReestr:
  Begin
     l:=False;
     If Reg=0 Then
     Begin
If(Client^.State and sfFocused <> 0)And(Client^.List<>Nil)And(Client^.List^.Count>=1) Then l:=True;
     End
     Else
     Begin
If(MAkeList^.State and sfFocused <> 0)And(MAkeList^.List<>Nil)And(MakeList^.List^.Count>=1) Then l:=True;
     End;
     If l Then
      Begin
               If Reg=0 Then
               s:=Client^.GetText(Client^.Focused,Client^.List^.Count)
               Else
               s:=MakeList^.GetText(MakeList^.Focused,MakeList^.List^.Count);
               s:=Copy(s,1+CClient+1,CClientKod);
               PrintClientInfo(s,Reg,Sel);
      End;

  End;

  Else;
  End;{evCommand}
      Else;
      End;{*Case*}


  if ((Event.What = evMouseDown) and (Event.Double)) or
     ((Event.What = evKeyDown) and (Event.KeyCode =kbEnter)) Or
     ((Event.What = evKeyDown) and (Event.KeyCode =kbCtrlEnter)) Or
     ((Event.What = evKeyDown) and (Event.KeyCode =kbTab)) Or
     ((Event.What = evKeyDown) and (Event.KeyCode =kbCtrlRight)) Then
  begin
              Event.What:=evCommand;
              Event.Command:=cmOk;
              PutEvent(Event);
              ClearEvent(Event);
  end;

  if ((Event.What = evKeyDown) and (Event.KeyCode =kbShiftTab))Or
     ((Event.What = evKeyDown) and (Event.KeyCode =kbCtrlLeft)) Then
  begin
              Event.What:=evCommand;
              Event.Command:=cmYes;
              PutEvent(Event);
              ClearEvent(Event);
  end;

  if ((Event.What = evKeyDown) and (Event.KeyCode = kbEsc))then
  begin
              Event.What:=evCommand;
              Event.Command:=cmCancel;
              PutEvent(Event);
              ClearEvent(Event);
  end;

 Case Event.What Of
 EvCommand : Begin
             Case Event.Command Of
 cmCancel,cmYes,cmOk,cmNo,cmClose,cmQuit
                     : Begin
                        If WithNetLock  Then
                         Begin
                          If Not(LockSelect) Then
                                   Begin
                                    ClearEvent(Event);
                                    Exit;
                                   End;
                         End
                        Else
                         Begin
                          If Not(TestEmploy) Then
                                   Begin
                                    ClearEvent(Event);
                                    Exit;
                                   End;
                         End;
                       End;

             Else Exit;
             End;
             End;
 Else;
 End;

 if (Event.What = evBroadcast) and
     (Event.Command = cmSelectClient) then ClearEvent(Event);

  inherited HandleEvent(Event);


  If (Desktop^.Current=PView(CLientWindow)) And (Event.What <> EvKeyDown) Then
          Begin
             Case Reg Of
             0:Begin
                If (Client^.List <> Nil) And (Client^.List^.Count>=1) Then
                 Begin
                  s:=Client^.GetText(Client^.Focused,Client^.List^.Count);
                  If s<>PrevClient Then
                   Begin
                    PrevClient:=S;
                    DrawCurrent(Reg,Sel);
                   End;
                 End;

               End;{0}
             1:Begin
                If (MakeList^.List <> Nil) And (MAkeList^.List^.Count>=1) Then
                 Begin
                  s:=MakeList^.GetText(MAkeList^.Focused,MakeList^.List^.Count);
                  If s<>PrevClient Then
                   Begin
                    PrevClient:=S;
                    DrawCurrent(Reg,Sel);
                   End;

                 End;

               End;{1}
             Else;
             End;{Case}
          End;
  {ClearEvent(Event);}
end;


Function TDopClientWindow.DopClient(Var Cl:ClientDopolnenieType):Boolean;
Label 1;
var
  Dlg : PDialog;
  R : TRect;
  CC : ClientDopolnenieType;
  Control : PView;
  c : Word;
begin
DopClient:=False;
cc:=Cl;
1:
R.Assign(14, 5, 66, 18);
New(Dlg, Init(R, 'Дополнительные параметры'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx:= $E011;

R.Assign(21, 1, 25, 2);
Control := New(PInputLong, Init(R, 2, 0, 10, 0));
Dlg^.Insert(Control);

  R.Assign(1, 1, 21, 2);
  Dlg^.Insert(New(PLabel, Init(R, 'Н~а~кладная (клиент):', Control)));

R.Assign(21, 2, 25, 3);
Control := New(PInputLong, Init(R, 2, 0, 10, 0));
Dlg^.Insert(Control);

  R.Assign(7, 2, 21, 3);
  Dlg^.Insert(New(PLabel, Init(R, 'ТТН (клиент):', Control)));

R.Assign(21, 3, 25, 4);
Control := New(PInputLong, Init(R, 2, 0, 10, 0));
Dlg^.Insert(Control);

  R.Assign(17, 3, 21, 4);
  Dlg^.Insert(New(PLabel, Init(R, 'СФ:', Control)));

R.Assign(21, 4, 25, 5);
Control := New(PInputLong, Init(R, 2, 0, 10, 0));
Dlg^.Insert(Control);

  R.Assign(2, 4, 21, 5);
  Dlg^.Insert(New(PLabel, Init(R, 'Протокол согл.цен:', Control)));

R.Assign(21, 5, 25, 6);
Control := New(PInputLong, Init(R, 2, 0, 10, 0));
Dlg^.Insert(Control);

  R.Assign(9, 5, 21, 6);
  Dlg^.Insert(New(PLabel, Init(R, 'Приложение:', Control)));

R.Assign(21, 6, 25, 7);
Control := New(PInputLong, Init(R, 2, 0, 10, 0));
Dlg^.Insert(Control);

  R.Assign(8, 6, 21, 7);
  Dlg^.Insert(New(PLabel, Init(R, 'Приложение~2~:', Control)));

R.Assign(45, 1, 49, 2);
Control := New(PInputLong, Init(R, 2, 0, 10, 0));
Dlg^.Insert(Control);

  R.Assign(39, 1, 45, 2);
  Dlg^.Insert(New(PLabel, Init(R, '~С~чет:', Control)));

R.Assign(45, 2, 49, 3);
Control := New(PInputLong, Init(R, 2, 0, 10, 0));
Dlg^.Insert(Control);

  R.Assign(25, 2, 45, 3);
  Dlg^.Insert(New(PLabel, Init(R, 'Памятка ~н~а сертиф.:', Control)));

R.Assign(45, 3, 49, 4);
Control := New(PInputLong, Init(R, 2, 0, 10, 0));
Dlg^.Insert(Control);

  R.Assign(26, 3, 45, 4);
  Dlg^.Insert(New(PLabel, Init(R, 'Справка к ~Г~ТД/ТТН:', Control)));

R.Assign(45, 4, 49, 5);
Control := New(PInputLong, Init(R, 2, 0, 10, 0));
Dlg^.Insert(Control);

  R.Assign(40, 4, 45, 5);
  Dlg^.Insert(New(PLabel, Init(R, '~П~КО:', Control)));

R.Assign(45, 5, 49, 6);
Control := New(PInputLong, Init(R, 2, 0, 10, 0));
Dlg^.Insert(Control);

  R.Assign(40, 5, 45, 6);
  Dlg^.Insert(New(PLabel, Init(R, '~Р~КО:', Control)));

R.Assign(45, 6, 49, 7);
Control := New(PInputLong, Init(R, 2, 0, 10, 0));
Dlg^.Insert(Control);

  R.Assign(41, 6, 45, 7);
  Dlg^.Insert(New(PLabel, Init(R, 'ЗЛ:', Control)));

R.Assign(1, 7, 49, 8);
Control := New(PCheckboxes, Init(R,
  NewSItem('~И~спользовать настройки печати из карточки', Nil)));
Dlg^.Insert(Control);

R.Assign(1, 8, 49, 9);
Control := New(PCheckboxes, Init(R,
  NewSItem('А~в~томатическая генерация прайс-листа', Nil)));
Dlg^.Insert(Control);

R.Assign(1, 9, 49, 10);
Control := New(PCheckboxes, Init(R,
  NewSItem('Э~к~спорт расходных накладных', Nil)));
Dlg^.Insert(Control);

R.Assign(10, 10, 49, 11);
Control := New(PInputLine, Init(R, CSertif));
Dlg^.Insert(Control);

  R.Assign(1, 10, 10, 11);
  Dlg^.Insert(New(PLabel, Init(R, 'Каталог:', Control)));

R.Assign(14, 11, 21, 12);
Control := New(PInputLine, Init(R, CArtikul));
Dlg^.Insert(Control);

  R.Assign(1, 11, 14, 12);
  Dlg^.Insert(New(PLabel, Init(R, 'Коэффициент:', Control)));

Dlg^.SelectNext(False);
Dlg^.SetData(CC);
c:=Desktop^.ExecView(Dlg);
If c<>cmCancel Then
 Begin
  Dlg^.GetData(CC);
     (*
     CopyNaklC :=1;
     CopyTTNC  :=1;
     CopySF    :=1;
     CopyProtocol:=1;
     CopyPrilog :=1;
     CopyPrilog2:=1;
     CopyShet   :=1;
     CopyPamatka:=1;
     CopyGTDTTN :=1;
     CopyPKO    :=1;
     CopyRKO    :=1;
     CopyZakaz  :=1;
     EnableAuto :=0;{определяет какие настройки использовать default или персональные}
     Price      :=0;{0-не проводить генерацию;1-проводить автоматическую генерацию}
     EnableExport:=0;{предлагать экспортировать расходные накладные клиентов в почту}
     MailPath   [0]:=#0;{фактический адрес}
     Proz       :='1.000';
    *)
  DelSpaceRight(CC.MailPath);
  If cC.MailPath[0]<>#0 Then
  If cC.MailPath[Length(cc.MailPath)]<>'\' Then cc.MailPath:=cc.MailPath+'\';

  If (cc.Price=1) and (Cc.MailPath[0]=#0) Then
   Begin
    MessageBox(^M+#3'Не указан каталог размещения почты!',Nil,mfError+mfCancelButton);
    Dispose(Control,Done);
    Dispose(Dlg,Done);
    Goto 1;
   End;

  If (cc.Price=1) and (StrToReal(Cc.Proz)<0.6) Then
   Begin
    MessageBox(^M+#3'Недопустимый коэффициент для расчета прайса!',Nil,mfError+mfCancelButton);
    Dispose(Control,Done);
    Dispose(Dlg,Done);
    Goto 1;
   End;

   Cl:=cc;
  DopClient:=True;
 End;

Dispose(Control,Done);
Dispose(Dlg,Done);
End;







Begin
INN[0]:=#0;
End.