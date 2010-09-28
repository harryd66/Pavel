Uses Glob,ServStr,Crt;
Var f : File Of ClientType;
  MakeListElement : ClientType;
   j,Max,i : Integer;
   Razdel : String;
    c : Word;


Begin {программа расширяет указаный в PathStr(1) файл наличия на ParamStr(2)}
 ClrScr;
 If (ParamStr(1)='') Then
   Begin
    Writeln('Программе требуется:');
    Writeln('1 - имя и путь к файлу *.db');
    Halt;
   End;

 Assign(f,ParamStr(1));
 Reset(f);

While Not(Eof(f)) Do
Begin
      read(f,MakeListElement);
      MakeListElement.Name[0]       :=#0;
      MAkeListElement.Dogovor[0] :=#0;
      MAkeListElement.Limit[0]:=#0;
      For c:=1 To CPunkt Do
      MakeListElement.Punkt[c,0]     :=#0;
      MakeListElement.Adress[0]     :=#0;
      MakeListElement.INN[0]        :=#0;
      MakeListElement.R_Sh[0]       :=#0;
      MakeListElement.Gde[0]        :=#0;
      MakeListElement.Gorod[0]      :=#0;
      MakeListElement.Okonh[0]      :=#0;
      MakeListElement.Okpo[0]       :=#0;
      MakeListElement.Enviropment[0]:=#0;
      MakeListElement.Telefon[0]    :=#0;
      MakeListElement.Stat          :=False;
      MakeListElement.Locked        :=False;
      MakeListElement.Employ        :=False;
      MakeListElement.Debit      :=0;
      MAkeListElement.ClientShkala :=0;
      MAkeListElement.SrokLizensia[0]    :=#0;
      MAkeListElement.Messages[0]    :=#0;

      If StrToInt(MAkeListElement.Kod)=0 Then
       Begin
        MakeListElement.Name       :='ПРОБНЫЙ КЛИЕНТ';
        MakeListElement.Employ     :=True;
       End;

      Seek(f,FilePos(f)-1);
      Write(f,MakeListElement);
End;{While}

 Close(f);
 Writeln('All Ok');
End.