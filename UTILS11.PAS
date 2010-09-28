{$I Compile.INC}

{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}
Unit Utils11;

Interface

Uses Glob,TpDate;

Procedure SetLastOst;
Procedure SetLastLocal;
Procedure SetLastCl;
Procedure SetLastSpr;
Procedure GetLastOst;
Procedure GetLastCl;
Procedure GetLastSpr;
Procedure GetLastLocal;
Procedure WriteNewCFG(Var Res : LongInt);



implementation


Uses App,Serv,ServStr,ServStr2,Objects,DbEngine,MsgBox,StHolder,Utils5,Utils4,Net,Mail,ColorTxt,
     Dos,Filetool,NetDbEng,Utils3,NetCall,
     Drivers,Printers,Prise,Protect,MyView,Tools,Validate;


Procedure SetLastOst;
Var txt : Text;
     c  : LongInt;
Begin
 {
 LastOstDate:=ToDay;
 LastOstTime:=CurrentTime;
 }
 Assign(txt,Path^.Dat.ToProgram+'ost.ini');
 c:=Ioresult;
 Rewrite(txt);
 c:=Ioresult;
 If c<>0 Then
  Begin
{   MessageBox(^M+#3'Ошибка установки даты и времени приема остатков!',Nil,mfError+mfCancelButton);}
   Exit;
  End;

 Writeln(txt,LastOstDate);
 Writeln(txt,LastOstTime);
 c:=Ioresult;
 Close(txt);
 c:=Ioresult;
 Desktop^.Redraw;
End;


Procedure SetLastLocal;
Var txt : Text;
     c  : LongInt;
Begin
 LastLocalSynhroDate:=ToDay;
 LastLocalSynhroTime:=CurrentTime;
 Assign(txt,Path^.Dat.ToProgram+'loclan.ini');
 c:=Ioresult;
 Rewrite(txt);
 c:=Ioresult;
 If c<>0 Then
  Begin
{   MessageBox(^M+#3'Ошибка установки даты и времени приема остатков!',Nil,mfError+mfCancelButton);}
   Exit;
  End;
 Writeln(txt,ToDay);
 Writeln(txt,CurrentTime);
 c:=Ioresult;
 Close(txt);
 c:=Ioresult;
 Desktop^.Redraw;
End;



Procedure SetLastCl;
Var txt : Text;
     c  : LongInt;
Begin
 LastClDate:=ToDay;
 LastClTime:=CurrentTime;
 Assign(txt,Path^.Dat.ToProgram+'cl.ini');
 c:=Ioresult;
 Rewrite(txt);
 c:=Ioresult;
 If c<>0 Then
  Begin
{   MessageBox(^M+#3'Ошибка установки даты и времени обновления клиентов!',Nil,mfError+mfCancelButton);}
   Exit;
  End;
 Writeln(txt,ToDay);
 Writeln(txt,CurrentTime);
 c:=Ioresult;
 Close(txt);
 c:=Ioresult;
 Desktop^.Redraw;
End;


Procedure SetLastSpr;
Var txt : Text;
     c  : LongInt;
Begin
 LastSprDate:=ToDay;
 LastSprTime:=CurrentTime;
 Assign(txt,Path^.Dat.ToProgram+'spr.ini');
 c:=Ioresult;
 Rewrite(txt);
 c:=Ioresult;
 If c<>0 Then
  Begin
{   MessageBox(^M+#3'Ошибка установки даты и времени дополнительных справочников!',Nil,mfError+mfCancelButton);}
   Exit;
  End;
 Writeln(txt,ToDay);
 Writeln(txt,CurrentTime);
 c:=Ioresult;
 Close(txt);
 c:=Ioresult;
 Desktop^.Redraw;
End;


Procedure GetLastOst;
Var txt : Text;
     c  : LongInt;
Begin
Assign(txt,Path^.Dat.ToProgram+'ost.ini');
c:=Ioresult;
Reset(txt);
c:=Ioresult;
 If c<>0 Then
  Begin
{ MessageBox(^M+#3'Ошибка чтения даты и времени приема остатков!',Nil,mfError+mfCancelButton);}
 c:=Ioresult;
 Rewrite(txt);
 c:=Ioresult;
 Writeln(txt,ToDay);
 Writeln(txt,CurrentTime);
 c:=Ioresult;
 Close(txt);
 c:=Ioresult;

   LastOstDate:=ToDay;
   LastOstTime:=CurrentTime;
   Exit;
  End;
 If Not Eof(txt) Then Readln(txt,LastOstDate);
 If Not Eof(txt) Then Readln(txt,LastOstTime);
c:=Ioresult;
Close(txt);
c:=Ioresult;
End;


Procedure GetLastLocal;
Var txt : Text;
     c  : LongInt;
Begin
Assign(txt,Path^.Dat.ToProgram+'loclan.ini');
c:=Ioresult;
Reset(txt);
c:=Ioresult;
 If c<>0 Then
  Begin
{ MessageBox(^M+#3'Ошибка чтения даты и времени синхронизации!',Nil,mfError+mfCancelButton);}
 c:=Ioresult;
 Rewrite(txt);
 c:=Ioresult;
 Writeln(txt,ToDay);
 Writeln(txt,CurrentTime);
 c:=Ioresult;
 Close(txt);
 c:=Ioresult;

   LastLocalSynhroDate:=ToDay;
   LastLocalSynhroTime:=CurrentTime;
   Exit;
  End;
 If Not Eof(txt) Then Readln(txt,LastLocalSynhroDate);
 If Not Eof(txt) Then Readln(txt,LastLocalSynhroTime);
c:=Ioresult;
Close(txt);
c:=Ioresult;
End;

Procedure GetLastCl;
Var txt : Text;
     c  : LongInt;
Begin
Assign(txt,Path^.Dat.ToProgram+'cl.ini');
c:=Ioresult;
Reset(txt);
c:=Ioresult;
 If c<>0 Then
  Begin
{   MessageBox(^M+#3'Ошибка установки даты и времени обновления клиентов!',Nil,mfError+mfCancelButton);}
 c:=Ioresult;
 Rewrite(txt);
 c:=Ioresult;
 Writeln(txt,ToDay);
 Writeln(txt,CurrentTime);
 c:=Ioresult;
 Close(txt);
 c:=Ioresult;

   LastClDate:=ToDay;
   LastClTime:=CurrentTime;
   Exit;
  End;
 If Not Eof(txt) Then Readln(txt,LastClDate);
 If Not Eof(txt) Then Readln(txt,LastClTime);
c:=Ioresult;
Close(txt);
c:=Ioresult;
End;


Procedure GetLastSpr;
Var txt : Text;
     c  : LongInt;
Begin
Assign(txt,Path^.Dat.ToProgram+'spr.ini');
c:=Ioresult;
Reset(txt);
c:=Ioresult;
 If c<>0 Then
  Begin
{   MessageBox(^M+#3'Ошибка установки даты и времени обновления дополнительных справочников!',Nil,mfError+mfCancelButton);}
 c:=Ioresult;
 Rewrite(txt);
 c:=Ioresult;
 Writeln(txt,ToDay);
 Writeln(txt,CurrentTime);
 c:=Ioresult;
 Close(txt);
 c:=Ioresult;

   LastSprDate:=ToDay;
   LastSprTime:=CurrentTime;
   Exit;
  End;
 If Not Eof(txt) Then Readln(txt,LastSprDate);
 If Not Eof(txt) Then Readln(txt,LastSprTime);
c:=Ioresult;
Close(txt);
c:=Ioresult;
End;


Procedure WriteNewCFG(Var Res : LongInt);
Var f : Text;
    i : Byte;
    c : Byte;
    SH: TStringHolder;
    txt : Text;
    Comment : String;

Function GetAsString(Name:AllStr):String;
Begin
GetAsString[0]:=#0;
GetAsString:=SH.GetString (Name);
End;

Function GetAsInteger(Name:AllStr):LongInt;
Begin
GetAsInteger:=0;
GetAsInteger:=StrToInt(SH.GetString (Name));
End;

Function GetAsReal(Name:AllStr):Real;
Begin
GetAsReal:=0;
GetAsReal:=StrToReal(SH.GetString (Name));
End;


Procedure Dozapis;
Begin
Comment:=GetAsString('EnableTempLock');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'EnableTempLock=',EnableTempLock);

Comment:=GetAsString('DisableControlOtsr');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'DisableControlOtsr=',DisableControlOtsr);

Comment:=GetAsString('DisableControlMinNazenka');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'DisableControlMinNazenka=',DisableControlMinNazenka);

Comment:=GetAsString('DisableControlMinNazCl');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'DisableControlMinNazCl=',DisableControlMinNazCl);

Comment:=GetAsString('EnableControlOnlyOneCopy');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'EnableControlOnlyOneCopy=',OnlyOneCopy);

Comment:=GetAsString('DisableAutoFlag');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'DisableAutoFlag=',DisableAutoFlagName);

Comment:=GetAsString('DisableOtgruzkaSertif');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'DisableOtgruzkaSertif=',DisableOtgruzkaSertif);

Comment:=GetAsString('EnableSpisanie');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'EnableSpisanie=',EnableSpisanie);

Comment:=GetAsString('EnableDixyZeni');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'EnableDixyZeni=',EnableDixyZeni);

Comment:=GetAsString('EnableControlZakupka');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'EnableControlZakupka=',EnableControlZakupka);


Comment:=GetAsString('ControlPricePosition');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'ControlPricePosition=',ControlPricePosition);

Comment:=GetAsString('EnableSound');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'EnableSound=',EnableSound);

Comment:=GetAsString('ShowPath');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'ShowPath=',ShowPath);

Comment:=GetAsString('ShowMarker');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'ShowMarker=',ShowMarker);

Comment:=GetAsString('EnableMinNazenka');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'EnableMinNazenka=',EnableMinNazenka);

Comment:=GetAsString('GlobalProz');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'GlobalProz=',GlobalProz);

Comment:=GetAsString('MinReturnDate');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'MinReturnDate=',MinReturnDate);

Comment:=GetAsString('TimeActualCash');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'TimeActualCash=',TimeActualCash);

Comment:=GetAsString('AutoRefreshCash');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'AutoRefreshCash=',AutoRefreshCash);

Comment:=GetAsString('RunFromClose');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'RunFromClose=',RunFromClose);

Comment:=GetAsString('ReadOnly');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'ReadOnly=',ReadOnlyConst);

Comment:=GetAsString('Terminal');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'Terminal=',Terminal);

Comment:=GetAsString('ChangeAdress');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'ChangeAdress=',ChangeAdress);

Comment:=GetAsString('DisableControlTulaSpirt');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'DisableControlTulaSpirt=',DisableControlTulaSpirt);


Comment:=GetAsString('EnablePredZakaz');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'EnablePredZakaz=',EnablePredZakaz);


Comment:=GetAsString('EnableTovarIndex');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'EnableTovarIndex=',EnableTovarIndex);


Comment:=GetAsString('EnableDocumentIndex');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'EnableDocumentIndex=',EnableDocumentIndex);

Comment:=GetAsString('EnableOborotIndex');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'EnableOborotIndex=',EnableOborotIndex);

Comment:=GetAsString('EnableManageZeni');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'EnableManageZeni=',EnableManageZeni);

End;



Procedure WriteDistanation;
Begin
Comment:=GetAsString('ToProgram');
If Comment[0]<>#0 Then Writeln(f,';'+Comment);
Writeln(f,'ToProgram='+Path^.Dat.ToProgram);

Comment:=GetAsString('ToUtils');
If Comment[0]<>#0 Then Writeln(f,';'+Comment);
Writeln(f,'ToUtils='+Path^.Dat.ToUtils);

Comment:=GetAsString('ToSPR');
If Comment[0]<>#0 Then Writeln(f,';'+Comment);
Writeln(f,'ToSPR='+Path^.Dat.ToSPR);

Comment:=GetAsString('ToPrihod');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'ToPrihod='+Path^.Dat.ToPrihod);

Comment:=GetAsString('ToMarket');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'ToMarket='+Path^.Dat.ToMarket);

Comment:=GetAsString('ToMarketIndex');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'ToMarketIndex='+Path^.Dat.ToMarketIndex);

Comment:=GetAsString('ToReturn');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'ToReturn='+Path^.Dat.ToReturn);

Comment:=GetAsString('ToCorrect');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'ToCorrect='+Path^.Dat.ToCorrect);

Comment:=GetAsString('ToClient');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'ToClient='+Path^.Dat.ToClient);

Comment:=GetAsString('ToClientBaseIndex');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'ToClientBaseIndex='+Path^.Dat.ToClientBaseIndex);

Comment:=GetAsString('ToClientIndex');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'ToClientIndex='+Path^.Dat.ToClientIndex);

Comment:=GetAsString('ToDolg');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'ToDolg='+Path^.Dat.ToDolg);

Comment:=GetAsString('ToClientReturn');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'ToClientReturn='+Path^.Dat.ToClientReturn);

Comment:=GetAsString('ToClientOplata');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'ToClientOplata='+Path^.Dat.ToClientOplata);

Comment:=GetAsString('ToOplata');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'ToOplata='+Path^.Dat.ToOplata);

Comment:=GetAsString('ToOperator');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'ToOperator='+Path^.Dat.ToOperator);

Comment:=GetAsString('ToName');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'ToName='+Path^.Dat.ToName);

Comment:=GetAsString('ToIndex');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'ToIndex='+Path^.Dat.ToIndex);

Comment:=GetAsString('ToRazdel');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'ToRazdel='+Path^.Dat.ToRazdel);

Comment:=GetAsString('ToSklad');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'ToSklad='+Path^.Dat.ToSklad);

Comment:=GetAsString('ToFantomBaz');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'ToFantomBaz='+Path^.Dat.ToFantomBaz);

Comment:=GetAsString('ToSkidki');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'ToSkidki='+Path^.Dat.ToSkidki);

Comment:=GetAsString('ToModem');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'ToModem='+Path^.Dat.ToModem);

Comment:=GetAsString('ToArchiv');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'ToArchiv='+Path^.Dat.ToArchiv);

Comment:=GetAsString('ArchivCode');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'ArchivCode='+Path^.Dat.ArchivCode);

Comment:=GetAsString('ToReport');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'ToReport='+Path^.Dat.ToReport);

Comment:=GetAsString('ToProtocol');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'ToProtocol='+Path^.Dat.ToProtocol);

Comment:=GetAsString('ToRewisia');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'ToRewisia='+Path^.Dat.ToRewisia);

Comment:=GetAsString('FileFlag');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'FileFlag='+Path^.Dat.FileFlag);

Comment:=GetAsString('ToTemp');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'ToTemp='+Path^.Dat.ToTemp);

Comment:=GetAsString('ToAnalys');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'ToAnalys='+Path^.Dat.ToAnalys);

Comment:=GetAsString('ToBarter');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'ToBarter='+Path^.Dat.ToBarter);

Comment:=GetAsString('ToTransport');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'ToTransport='+Path^.Dat.ToTransport);

Comment:=GetAsString('ToTerminal');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'ToTerminal='+Path^.Dat.ToTerminal);

Comment:=GetAsString('ToRemoteDir');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'ToRemoteDir='+Path^.Dat.ToRemoteDir);

Comment:=GetAsString('ToWinLnk');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'ToWinLnk='+Path^.Dat.ToWinLnk);

Comment:=GetAsString('PriceName');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'PriceName='+Path^.Dat.PriceName);

Comment:=GetAsString('ToFlagDir');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'ToFlagDir='+Path^.Dat.ToFlagDir);

Comment:=GetAsString('ToText');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'ToText='+Path^.Dat.ToText);

Comment:=GetAsString('ToRekwiziti');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'ToRekwiziti='+Path^.Dat.ToRekwiziti);

Comment:=GetAsString('ToPhoto');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'ToPhoto='+Path^.Dat.ToPhoto);


Comment:=GetAsString('ToExcel');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'ToExcel='+Path^.Dat.ToExcel);

(*
Comment:=GetAsString('ToBank');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'ToBank='+Path^.Dat.BAnk);

Comment:=GetAsString('ToInPay');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'ToInPay='+Path^.Dat.InPay);

Comment:=GetAsString('ToOutPay');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'ToOutPay='+Path^.Dat.OutPay);

Comment:=GetAsString('ToPersonalPay');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'ToPersonalPay='+Path^.Dat.PersonalPay);
*)

Comment:=GetAsString('_ToProgram');
If Comment[0]<>#0 Then Writeln(f,';'+Comment);
Writeln(f,'_ToProgram='+NetPath^.Dat.ToProgram);

Comment:=GetAsString('_ToUtils');
If Comment[0]<>#0 Then Writeln(f,';'+Comment);
Writeln(f,'_ToUtils='+NetPath^.Dat.ToUtils);

Comment:=GetAsString('_ToSPR');
If Comment[0]<>#0 Then Writeln(f,';'+Comment);
Writeln(f,'_ToSPR='+NetPath^.Dat.ToSPR);

Comment:=GetAsString('_ToPrihod');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'_ToPrihod='+NetPath^.Dat.ToPrihod);

Comment:=GetAsString('_ToMarket');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'_ToMarket='+NetPath^.Dat.ToMarket);

Comment:=GetAsString('_ToMarketIndex');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'_ToMarketIndex='+NetPath^.Dat.ToMarketIndex);

Comment:=GetAsString('_ToReturn');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'_ToReturn='+NetPath^.Dat.ToReturn);

Comment:=GetAsString('_ToCorrect');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'_ToCorrect='+NetPath^.Dat.ToCorrect);

Comment:=GetAsString('_ToClient');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'_ToClient='+NetPath^.Dat.ToClient);

Comment:=GetAsString('_ToClientBaseIndex');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'_ToClientBaseIndex='+NetPath^.Dat.ToClientBaseIndex);

Comment:=GetAsString('_ToClientIndex');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'_ToClientIndex='+NetPath^.Dat.ToClientIndex);

Comment:=GetAsString('_ToDolg');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'_ToDolg='+NetPath^.Dat.ToDolg);

Comment:=GetAsString('_ToClientReturn');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'_ToClientReturn='+NetPath^.Dat.ToClientReturn);

Comment:=GetAsString('_ToClientOplata');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'_ToClientOplata='+NetPath^.Dat.ToClientOplata);

Comment:=GetAsString('_ToOplata');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'_ToOplata='+NetPath^.Dat.ToOplata);

Comment:=GetAsString('_ToOperator');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'_ToOperator='+NetPath^.Dat.ToOperator);

Comment:=GetAsString('_ToName');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'_ToName='+NetPath^.Dat.ToName);

Comment:=GetAsString('_ToIndex');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'_ToIndex='+NetPath^.Dat.ToIndex);

Comment:=GetAsString('_ToRazdel');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'_ToRazdel='+NetPath^.Dat.ToRazdel);

Comment:=GetAsString('_ToSklad');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'_ToSklad='+NetPath^.Dat.ToSklad);

Comment:=GetAsString('_ToFantomBaz');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'_ToFantomBaz='+NetPath^.Dat.ToFantomBaz);

Comment:=GetAsString('_ToSkidki');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'_ToSkidki='+NetPath^.Dat.ToSkidki);

Comment:=GetAsString('_ToModem');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'_ToModem='+NetPath^.Dat.ToModem);

Comment:=GetAsString('_ToArchiv');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'_ToArchiv='+NetPath^.Dat.ToArchiv);

Comment:=GetAsString('_ArchivCode');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'_ArchivCode='+NetPath^.Dat.ArchivCode);

Comment:=GetAsString('_ToReport');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'_ToReport='+NetPath^.Dat.ToReport);

Comment:=GetAsString('_ToProtocol');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'_ToProtocol='+NetPath^.Dat.ToProtocol);

Comment:=GetAsString('_ToRewisia');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'_ToRewisia='+NetPath^.Dat.ToRewisia);

Comment:=GetAsString('_FileFlag');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'_FileFlag='+NetPath^.Dat.FileFlag);

Comment:=GetAsString('_ToTemp');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'_ToTemp='+NetPath^.Dat.ToTemp);

Comment:=GetAsString('_ToAnalys');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'_ToAnalys='+NetPath^.Dat.ToAnalys);

Comment:=GetAsString('_ToBarter');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'_ToBarter='+NetPath^.Dat.ToBarter);

Comment:=GetAsString('_ToTransport');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'_ToTransport='+NetPath^.Dat.ToTransport);

Comment:=GetAsString('_ToTerminal');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'_ToTerminal='+NetPath^.Dat.ToTerminal);

Comment:=GetAsString('_ToRemoteDir');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'_ToRemoteDir='+NetPath^.Dat.ToRemoteDir);

Comment:=GetAsString('_ToWinLnk');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'_ToWinLnk='+NetPath^.Dat.ToWinLnk);

Comment:=GetAsString('_PriceName');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'_PriceName='+NetPath^.Dat.PriceName);

Comment:=GetAsString('_ToFlagDir');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'_ToFlagDir='+NetPath^.Dat.ToFlagDir);

Comment:=GetAsString('_ToText');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'_ToText='+NetPath^.Dat.ToText);

Comment:=GetAsString('_ToRekwiziti');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'_ToRekwiziti='+NetPath^.Dat.ToRekwiziti);

Comment:=GetAsString('_ToPhoto');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'_ToPhoto='+NetPath^.Dat.ToPhoto);

Comment:=GetAsString('_ToExcel');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'_ToExcel='+NetPath^.Dat.ToExcel);

(*
Comment:=GetAsString('_ToBank');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'_ToBank='+NetPath^.Dat.BAnk);

Comment:=GetAsString('_ToInPay');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'_ToInPay='+NetPath^.Dat.InPay);

Comment:=GetAsString('_ToOutPay');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'_ToOutPay='+NetPath^.Dat.OutPay);

Comment:=GetAsString('_ToPersonalPay');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'_ToPersonalPay='+NetPath^.Dat.PersonalPay);
*)



End;



Begin
If (GlobalReadOnly=1) Or (ReadOnlyConst=1) Then
   Begin
    MessageBox(#3^M+ReadOnlyStr^,Nil,mfWarning+mfCancelButton);
    Exit;
   End;
ClearFind;
Assign (f,PathToConfig^+'sklad.cfg');
Res := IOResult;
Rewrite(f);
Res := IOResult;
If Res <> 0 Then Exit;
Res := IOResult;


Assign (txt,'sklad.lng');
Res := IOResult;
Reset(txt);
Res := IOResult;
If Res <> 0 Then
 Begin
  Close(f);
  Exit;
 End;
Close(txt);
Res := IOResult;

SH.Init;
SH.LoadFromFile ('sklad.lng');

Writeln(f,'Version='+CompileDate);

Writeln(f,'NetComputerName='+GetMachineName);

Writeln(f,'OperatorName='+GetOperatorField(FName,CurrentPassword));
Writeln(f,'Date='+DateToDateString(Datemask,Today));
Writeln(f,'Time='+Times);

WriteDistanation;

For c:=0 To 8 Do
Begin
Comment:=GetAsString('AkzisKoeff['+IntToStr(c,COne)+']');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'AkzisKoeff['+IntToStr(c,COne)+']='+AkzisKoeff[c]);
End;

For c:=1 To 10 Do
Begin
Comment:=GetAsString('NoClientStat['+IntToStr(c,CMantissa)+']');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'NoClientStat['+IntToStr(c,CMantissa)+']='+NoClientStatKod[c]);
End;

Comment:=GetAsString('ShemaAkzis');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'ShemaAkzis=',ShemaAkzis);

Comment:=GetAsString('EnableImport');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'EnableImport=',EnableImport);

Comment:=GetAsString('AllSklads');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'AllSklads=',AllSklads);

Comment:=GetAsString('EnableAverageOtdel');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'EnableAverageOtdel=',EnableAverageOtdel);

Comment:=GetAsString('AverageOtdel');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'AverageOtdel=',AverageOtdel);

Comment:=GetAsString('RegimOtsheta');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'RegimOtsheta=',RegimOtsheta);

Comment:=GetAsString('DefaultSetMarker');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'DefaultSetMarker=',DefaultSetMarker);

Comment:=GetAsString('YesMarker');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'YesMarker=',YesMarker);

Comment:=GetAsString('NoMarker');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'NoMarker=',NoMarker);

Comment:=GetAsString('RemoteAccess');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'RemoteAccess=',RemoteAccess);

Comment:=GetAsString('RemoteProtocol');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'RemoteProtocol=',RemoteProtocol);

Comment:=GetAsString('RemoteScript');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'RemoteScript=',RemoteScript);

Comment:=GetAsString('EnableNewTovar');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'EnableNewTovar=',EnableNewTovar);

Comment:=GetAsString('MarketSD');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'MarketSD=',MarketSD);

Comment:=GetAsString('EnableMarketPassword');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'EnableMarketPassword=',EnableMarketPassword);

Comment:=GetAsString('EnableRouteControl');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'EnableRouteControl=',EnableRouteControl);

Comment:=GetAsString('EnableHandZeni');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'EnableHandZeni=',EnableHandZeni);

Comment:=GetAsString('EnableAntiLock');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'EnableAntiLock=',EnableAntiLock);

Comment:=GetAsString('EnableZakupka');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'EnableZakupka=',EnableZakupka);

Comment:=GetAsString('EnableRazdelSkidka');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'EnableRazdelSkidka=',EnableRazdelSkidka);


Comment:=GetAsString('EnableCommentMrk');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'EnableCommentMrk=',EnableCommentMrk);


Comment:=GetAsString('DisableClose');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'DisableClose=',DisableClose);

Comment:=GetAsString('DisableProtocol');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'DisableProtocol=',DisableProtocol);

Comment:=GetAsString('NetMonitoring');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'NetMonitoring=',NetMonitoring);

Comment:=GetAsString('NewGTD');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'NewGTD=',NewGTD);

Comment:=GetAsString('ShowDialogPrint');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'ShowDialogPrint=',ShowDialogPrint);

Comment:=GetAsString('PrintOGTD');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'PrintOGTD=',PrintOGTD);

Comment:=GetAsString('PrintOPhoto');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'PrintOPhoto=',PrintOPhoto);



Comment:=GetAsString('NetworkPrinters');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'NetworkPrinters=',NetworkPrinters);


Comment:=GetAsString('EnablePeremeshenie');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'EnablePeremeshenie=',EnablePeremeshenie);

Comment:=GetAsString('EnableBarter');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'EnableBarter=',EnableBarter);

Comment:=GetAsString('EnableAnalys');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'EnableAnalys=',EnableAnalys);

Comment:=GetAsString('EnableKassaOperation');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'EnableKassaOperation=',EnableKassaOperation);

Comment:=GetAsString('EnableControlKassa');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'EnableControlKassa=',EnableControlKassa);

Comment:=GetAsString('EnablePrihod');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'EnablePrihod=',EnablePrihod);

Comment:=GetAsString('EnableVeksel');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'EnableVeksel=',EnableVeksel);

Comment:=GetAsString('EnableMarket');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'EnableMarket=',EnableMarket);

Comment:=GetAsString('EnableDolgControl');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'EnableDolgControl=',EnableDolgControl);


Comment:=GetAsString('ShemaNazenka');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'ShemaNazenka=',ShemaNazenka);

Comment:=GetAsString('EnableReturn');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'EnableReturn=',EnableReturn);

Comment:=GetAsString('EnablePereozenka');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'EnablePereozenka=',EnablePereozenka);

Comment:=GetAsString('EnableRewisia');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'EnableRewisia=',EnableRewisia);

Comment:=GetAsString('EnableConsigOplata');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'EnableConsigOplata=',EnableConsigOplata);

Comment:=GetAsString('EnableToolsRun');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'EnableToolsRun=',EnableToolsRun);

Comment:=GetAsString('FiktivSkidka');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'FiktivSkidka=',FiktivSkidka);

Comment:=GetAsString('EnableAutoShk');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'EnableAutoShk=',EnableAutoShk);

Comment:=GetAsString('EnablePosVersion');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'EnablePosVersion=',EnablePosVersion);

Comment:=GetAsString('DisablePack');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'DisablePack=',DisablePack);

Comment:=GetAsString('EnableOtdel');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'EnableOtdel=',EnableOtdel);

Comment:=GetAsString('PrihodFromClient');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'PrihodFromClient=',PrihodFromClient);

Comment:=GetAsString('DefaultRazdelVid');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'DefaultRazdelVid=',DefaultRazdelVid);

Comment:=GetAsString('AutoList');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'AutoList=',AutoList);

Comment:=GetAsString('DefaultSkidka');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'DefaultSkidka=',DefaultSkidka);

Comment:=GetAsString('EnableBron');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'EnableBron=',EnableBron);

Comment:=GetAsString('EnableSHK');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'EnableSHK=',EnableSHK);

Comment:=GetAsString('EnableOtkat');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'EnableOtkat=',EnableOtkat);

Comment:=GetAsString('ZakazShema');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'ZakazShema=',ZakazShema);

Comment:=GetAsString('VidZakupka');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'VidZakupka=',VidZakupka);


Comment:=GetAsString('EnablePrivolye');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'EnablePrivolye=',EnablePrivolye);

Comment:=GetAsString('PrivolyeProz');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'PrivolyeProz=',PrivolyeProz);

Comment:=GetAsString('SortOtgruzka');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'SortOtgruzka=',SortOtgruzka);


Comment:=GetAsString('SortPrihod');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'SortPrihod=',SortPrihod);

Comment:=GetAsString('Printer');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'Printer=',Nprint^.DAt.Printer);

Comment:=GetAsString('Orient');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'Orient=',Nprint^.DAt.Orient);

Comment:=GetAsString('Port');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'Port=',Nprint^.DAt.Port);

Comment:=GetAsString('SwapDisk');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'SwapDisk=',Nprint^.DAt.SwapDisk);

Comment:=GetAsString('Computer');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'Computer=',Nprint^.DAt.Computer);

Comment:=GetAsString('PrintSeparatorPage');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'PrintSeparatorPage=',Nprint^.DAt.PrintSeparatorPage);

Comment:=GetAsString('ShemaPrilB');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'ShemaPrilB=',Nprint^.DAt.ShemaPrilB);



Comment:=GetAsString('Ini');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Write(f,'Ini=');

For c:=1 To Ord(Nprint^.DAt.Ini[0]) Do
Begin
Write(f,'#'+IntToStr(Ord(Nprint^.DAt.Ini[c]),CLitr));
End;
Writeln(f);
{
Comment:=GetAsString('CopyPrihod');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'CopyPrihod=',Nprint^.DAt.CopyPrihod);

Comment:=GetAsString('CopyPrz');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'CopyPrz=',Nprint^.DAt.CopyPrz);

Comment:=GetAsString('CopyNkl');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'CopyNkl=',Nprint^.DAt.CopyNkl);

Comment:=GetAsString('CopyTTN');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'CopyTTN=',Nprint^.DAt.CopyTTN);

Comment:=GetAsString('CopySF');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'CopySF=',Nprint^.DAt.CopySF);

Comment:=GetAsString('CopyReturn');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'CopyReturn=',Nprint^.DAt.CopyReturn);
}

Comment:=GetAsString('CNaklC');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'CNaklC=',NprintC^.DAt.CopyNaklC);


Comment:=GetAsString('CNaklS');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'CNaklS=',NprintC^.DAt.CopyNaklS);


Comment:=GetAsString('CTTNC');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'CTTNC=',NprintC^.DAt.CopyTTNC);


Comment:=GetAsString('CTTNS');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'CTTNS=',NprintC^.DAt.CopyTTNS);


Comment:=GetAsString('CSF');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'CSF=',NprintC^.DAt.CopySF);


Comment:=GetAsString('CProtocol');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'CProtocol=',NprintC^.DAt.CopyProtocol);


Comment:=GetAsString('CPrilog');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'CPrilog=',NprintC^.DAt.CopyPrilog);


Comment:=GetAsString('CPrilog2');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'CPrilog2=',NprintC^.DAt.CopyPrilog2);


Comment:=GetAsString('CShet');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'CShet=',NprintC^.DAt.CopyShet);


Comment:=GetAsString('CPamatka');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'CPamatka=',NprintC^.DAt.CopyPamatka);


Comment:=GetAsString('CGTDTTN');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'CGTDTTN=',NprintC^.DAt.CopyGTDTTN);


Comment:=GetAsString('CPKO');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'CPKO=',NprintC^.DAt.CopyPKO);

Comment:=GetAsString('CRKO');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'CRKO=',NprintC^.DAt.CopyRKO);

Comment:=GetAsString('CPrihod');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'CPrihod=',NprintC^.DAt.CopyPrihod);

Comment:=GetAsString('CReturn');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'CReturn=',NprintC^.DAt.CopyReturn);

Comment:=GetAsString('CPrz');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'CPrz=',NprintC^.DAt.CopyPrz);

Comment:=GetAsString('CRwz');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'CRwz=',NprintC^.DAt.CopyRwz);

Comment:=GetAsString('CZakaz');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'CZakaz=',NprintC^.DAt.CopyZakaz);

Comment:=GetAsString('COtborka');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'COtborka=',NprintC^.DAt.CopyOtborka);

Comment:=GetAsString('CTrans');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'CTrans=',NprintC^.DAt.CopyTrans);

Comment:=GetAsString('CAll');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'CAll=',NprintC^.DAt.CopyAll);


Comment:=GetAsString('CVeksel');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'CVeksel=',NprintC^.DAt.CopyVeksel);

Comment:=GetAsString('CKurzNakl');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'CKurzNakl=',NprintC^.DAt.CopyKurzNakl);

Comment:=GetAsString('AutoAnswerCopy');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'AutoAnswerCopy=',NprintC^.DAt.AutoAnswerCopy);


Comment:=GetAsString('AutoPrintRashod');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'AutoPrintRashod=',NprintC^.DAt.AutoPrintRashod);

{
NprintC^.DAt.CopyZakaz:=GetAsInteger('CZakaz');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

NprintC^.DAt.CopyTrans:=GetAsInteger('CTrans');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

NprintC^.DAt.CopyAll:=GetAsInteger('CAll');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;
}

Comment:=GetAsString('FullSkidka');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'FullSkidka=',Nprint^.DAt.FullSkidka);

Comment:=GetAsString('FullSertif');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'FullSertif=',Nprint^.DAt.FullSertif);

Comment:=GetAsString('FullAkzis');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'FullAkzis=',Nprint^.DAt.FullAkzis);

Comment:=GetAsString('FullGTD');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'FullGTD=',Nprint^.DAt.FullGTD);

Comment:=GetAsString('FullAkzizDate');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'FullAkzizDate=',Nprint^.DAt.FullAkzizDate);

Comment:=GetAsString('FullExpert');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'FullExpert=',Nprint^.DAt.FullExpert);

Comment:=GetAsString('FullName');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'FullName=',Nprint^.DAt.FullName);

Comment:=GetAsString('PrintPhoto');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'PrintPhoto=',Nprint^.DAt.PrintPhoto);

Comment:=GetAsString('PrilogenieNakl');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'PrilogenieNakl=',Nprint^.DAt.PrilogenieNakl);

Comment:=GetAsString('PrintTTN');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'PrintTTN=',Nprint^.DAt.PrintTTN);

Comment:=GetAsString('PrintTorg12');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'PrintTorg12=',Nprint^.DAt.PrintTorg12);

Comment:=GetAsString('PrintOtborka');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'PrintOtborka=',Nprint^.DAt.PrintOtborka);

Comment:=GetAsString('ShemaPhoto');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'ShemaPhoto=',Nprint^.DAt.ShemaPhoto);

Comment:=GetAsString('PrintPrilogGTDTTN');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'PrintPrilogGTDTTN=',Nprint^.DAt.PrintPrilogGTDTTN);

Comment:=GetAsString('DisablePrint');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'DisablePrint=',Nprint^.DAt.DisablePrint);

Comment:=GetAsString('EnablePrintRashAkzis');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'EnablePrintRashAkzis=',Nprint^.DAt.EnablePrintRashetAkzis);

Comment:=GetAsString('Lizensia');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'Lizensia=',Lizensia);

Comment:=GetAsString('EbanyMetro');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'EbanyMetro=',EbanyMetro);

Comment:=GetAsString('DefaultDoc');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'DefaultDoc=',DefaultDoc);

Comment:=GetAsString('DefaultReal');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'DefaultReal=',DefaultReal);

Comment:=GetAsString('MasDocNumer');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'MasDocNumer=',MasDocNumer);

Comment:=GetAsString('DebitDocNumer');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'DebitDocNumer=',DebitDocNumer);

Comment:=GetAsString('Messag');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'Messag=',NPrint^.Dat.Messag);

Comment:=GetAsString('TimeStart');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'TimeStart=',NPrint^.Dat.TimeStart);

Comment:=GetAsString('TimeStop');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'TimeStop=',NPrint^.Dat.TimeStop);

Comment:=GetAsString('TextMessag');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'TextMessag=',NPrint^.Dat.TextMessag);

Comment:=GetAsString('DefaultLizensia');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'DefaultLizensia=',DefaultLizensia);

Comment:=GetAsString('ShowClients');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'ShowClients=',ShowClients);

Comment:=GetAsString('ClientRP');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'ClientRP=',ClientRP);

Comment:=GetAsString('PrihodMax');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'PrihodMax=',PrihodMax:CIZena:CMantissa);

Comment:=GetAsString('ShowNumer');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'ShowNumer=',ShowNumer);

Comment:=GetAsString('EnableCashe');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'EnableCashe=',EnableCashe);

Comment:=GetAsString('EnableFiltr');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'EnableFiltr=',EnableFiltr);

Comment:=GetAsString('ProtectScreen');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'ProtectScreen=',NPrint^.Dat.ProtectScreen);

Comment:=GetAsString('TimeProtectScreen');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'TimeProtectScreen=',NPrint^.Dat.TimeProtectScreen);

Comment:=GetAsString('ScreenSaverName');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'ScreenSaverName=',NPrint^.Dat.ScreenSaverName);

Comment:=GetAsString('Compress');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'Compress=',Compress);

Comment:=GetAsString('AutoMarket');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'AutoMarket=',AutoMarket);

For c:=1 To CMaxSklads Do
Begin
Comment:=GetAsString('ToExternalSklads['+IntToStr(c,CMantissa)+']');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'ToExternalSklads['+IntToStr(c,CMantissa)+']=',PathSklads^.Dat.Path[c]);
End;

For c:=1 To Max30 Do
Begin
Comment:=GetAsString('ToExport['+IntToStr(c,CMantissa)+']');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'ToExport['+IntToStr(c,CMantissa)+']=',PathExpImp^.Dat.ToExport[c]);
End;

For c:=1 To Max30 Do
Begin
Comment:=GetAsString('ToImport['+IntToStr(c,CMantissa)+']');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'ToImport['+IntToStr(c,CMantissa)+']=',PathExpImp^.Dat.ToImport[c]);
End;

For c:=1 To 6 Do
Begin
Comment:=GetAsString('FirstLockKod['+IntToStr(c,COne)+']');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'FirstLockKod['+IntToStr(c,COne)+']=',FirstLockKod[c]);
End;

Comment:=GetAsString('ZeniInZakaz');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'ZeniInZakaz=',ZeniInZakaz);

Comment:=GetAsString('EnableImportMake');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'EnableImportMake=',EnableImportMake);

Comment:=GetAsString('EnableImportGroup');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'EnableImportGroup=',EnableImportGroup);

Comment:=GetAsString('Pharm');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'Pharm=',Pharm);

Comment:=GetAsString('AutoDetect');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'AutoDetect=',AutoDetect);

Comment:=GetAsString('DisablePrintXerox');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'DisablePrintXerox=',DisablePrintXerox);

Comment:=GetAsString('RunFromExit');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'RunFromExit=',RunFromExit);


Dozapis;

Res := IOResult;
Close(f);
Res := IOResult;

DInfoMsg('Кофигурация успешно сохранена!',False);
Delay(1000);
NoInfoMsg;
SH.Done;

AddProtocol('Запись файла конфигурации '+PathToConfig^+'sklad.cfg','','');
End;



End.