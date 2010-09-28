Uses Glob,ServStr,Serv;

Var MakeFile:File Of MAkeType;
    MakeElement : MakeType;
    Position,f : LongInt;

Procedure Clear(Var M:MakeType);
Var Test : Word;
Begin
                 M.Name[0]:=#0;
                 M.Employ:=False;
                 M.Limit[0]:=#0;
                 M.Dogovor[0]:=#0;
                 For Test:=1 To CPunkt Do
                 M.Punkt[Test,0]:=#0;
                 M.Stat:=False;
                 M.Adress[0]:=#0;
                 M.Gorod[0]:=#0;
                 M.Telefon[0]:=#0;
                 M.Gde[0]:=#0;
                 M.INN[0]:=#0;
                 M.R_Sh[0]:=#0;
                 M.SrokLizensia[0]:=#0;
                 M.Debit:=0;
                 M.Messages[0]:=#0;
                 M.Kod[0]:=#0;
                 M.Locked:=False;
                 M.OKONH[0]:=#0;
                 M.OKPO [0]:=#0;
                 M.Enviropment[0]:=#0;
                 M.Debit:=0;
                 M.ClientShkala:=0;
                 M.SrokLizensia[0] :=#0;
                 M.Test_Srok[0]:=#0;
End;


Begin
Assign(MakeFile,ParamStr(1));
Position:=IOResult;
Reset(MakeFile);
Position:=IOResult;

If Position<>0 Then
 Begin
  Writeln('1-Имя и путь к файлу поставщиков (клиентов)!');
  Writeln('2-Количество добавляемых позиций!');
  Halt;
 End;

f:=FileSize(MAkeFile);


For Position:=f To f+StrToInt(ParamStr(2)) Do
Begin
Clear(MakeElement);
MakeElement.Kod:=IntToStr(Position,CClientKod);
RFormatZerro(MakeElement.Kod,CClientKod);
Seek(MakeFile,FileSize(MAkeFile));
Write(MakeFile,MakeElement);
End;

Close(MakeFile);

End.