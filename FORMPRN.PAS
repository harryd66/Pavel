
Uses Glob,Servstr,Printers,Objects,StHolder,MSgBox;

Type TPrintersFont = record
      Bold : Array [0..3] Of AllStr1;
      NoBold: Array [0..3] Of AllStr1;
      Double: Array [0..3] Of AllStr1;
      NoDouble: Array [0..3] Of AllStr1;
      Pitch : Array [0..3] Of AllStr1;
      NoPitch : Array [0..3] Of AllStr1;
      Condensed0: Array [0..3] Of AllStr1;
      Condensed: Array [0..3] Of AllStr1;
      Condensed2: Array [0..3] Of AllStr1;
      Condensed3: Array [0..3] Of AllStr1;
      Condensed4: Array [0..3] Of AllStr1;
      Condensed5: Array [0..3] Of AllStr1;
      NoCondensed: Array [0..3] Of AllStr1;
      High : Array [0..3] Of AllStr1;
      High1 : Array [0..3] Of AllStr1;
      High2 : Array [0..3] Of AllStr1;
      High3 : Array [0..3] Of AllStr1;
      High4 : Array [0..3] Of AllStr1;
      NoHigh: Array [0..3] Of AllStr1;
      Italic: Array [0..3] Of   AllStr1;
      NoItalic: Array [0..3] Of AllStr1;
      MaxLine:Array [0..3] Of word;
      EndPage : Array [0..3] Of AllStr1;
      DopIni : Array[0..3] of AllStr1;
      OrientNormal : Array[0..3] of AllStr1;
      OrientAlbom  : Array[0..3] of AllStr1;
      MinInterval  : Array[0..3] of AllStr1;
      MinInterval2 : Array[0..3] of AllStr1;
      MinInterval3 : Array[0..3] of AllStr1;
      Normal       : Array[0..3] of AllStr1;
end;

Type PPrintersFont = ^TPrintersFontPtr;
     TPrintersFontPtr = object(TObject)
     Dat: TPrintersFont;
     constructor Init;
     destructor Done; virtual;
     end;




Function StringToOrdString(s:string):string;
var i: word;
    str: string[4];
    rez: string;
Begin
  rez:='';
  for i:=1 to ord(s[0]) do
  begin
    str:='';
    Str:=IntToStr(ord(s[i]),CArtikul);
    DelSpace(str);
    rez:=rez+'#'+str;
  end;
  StringToOrdString:=rez;
End;



Function OrdStringToString(s:string):string;
var i: byte;
    rez: string;
    str: string[4];
Begin
  rez:='';
  while pos('#',s) > 0 do
  begin
    delete(s,1,1);
    i:=pos('#',s);
    if i>0 then
     begin
       str:=copy(s,1,i-1);
       delete(s,1,i-1);
     end
    else str:=s;
    rez:=rez+chr(StrToInt(str));
  end;
  OrdStringToString:=rez;
End;



function LoadPrintersFont(var F:PPrintersFont): boolean;
label 45;
var  SH: TStringHolder;
     i: word;
     t: text;
Begin

  LoadPrintersFont:=false;
  Assign (t,{Path^.Dat.ToTemp+}'printers.ini');
  i := IOResult;
  Reset(t);
  i := IOResult;
  If i <> 0 Then
  Begin
  Exit;
  End;
  i := IOResult;
  Close(t);
  i := IOResult;

  SH.Init;
  SH.LoadFromFile ({Path^.Dat.ToTemp}'printers.ini');

for i:=0 to 3 do
Begin
  With f^.DAt Do
  Bold[i]:=OrdStringToString(SH.GetString('Bold'+IntToStr(i,1)));
  If Not Sh.OkOp Then Begin
                     {MessageBox(#3^M+#3'Не обнаружен параметр Bold'+IntToStr(i,1),Nil,mfError+mfCancelButton);}
                     {Goto 45;}
                    End;
  NoBold[i]:=OrdStringToString(SH.GetString('NoBold'+IntToStr(i,1)));
  If Not Sh.OkOp Then Begin
                     {MessageBox(#3^M+#3'Не обнаружен параметр NoBold'+IntToStr(i,1),Nil,mfError+mfCancelButton);}
                     {Goto 45;}
                    End;
  Double[i]:=OrdStringToString(SH.GetString('Double'+IntToStr(i,1)));
  If Not Sh.OkOp Then Begin
                     {MessageBox(#3^M+#3'Не обнаружен параметр Double'+IntToStr(i,1),Nil,mfError+mfCancelButton);}
                     {Goto 45;}
                    End;
  NoDouble[i]:=OrdStringToString(SH.GetString('NoDouble'+IntToStr(i,1)));
  If Not Sh.OkOp Then Begin
                     {MessageBox(#3^M+#3'Не обнаружен параметр NoDouble'+IntToStr(i,1),Nil,mfError+mfCancelButton);}
                     {Goto 45;}
                    End;
  Pitch[i]:=OrdStringToString(SH.GetString('Pitch'+IntToStr(i,1)));
  If Not Sh.OkOp Then Begin
                     {MessageBox(#3^M+#3'Не обнаружен параметр Pitch'+IntToStr(i,1),Nil,mfError+mfCancelButton);}
                     {Goto 45;}
                    End;
  NoPitch[i]:=OrdStringToString(SH.GetString('NoPitch'+IntToStr(i,1)));
  If Not Sh.OkOp Then Begin
                     {MessageBox(#3^M+#3'Не обнаружен параметр NoPitch'+IntToStr(i,1),Nil,mfError+mfCancelButton);}
                     {Goto 45;}
                    End;
  Condensed0[i]:=OrdStringToString(SH.GetString('Condensed0'+IntToStr(i,1)));
  If Not Sh.OkOp Then Begin
                     {MessageBox(#3^M+#3'Не обнаружен параметр Condensed0'+IntToStr(i,1),Nil,mfError+mfCancelButton);}
                     {Goto 45;}
                    End;
  Condensed[i]:=OrdStringToString(SH.GetString('Condensed'+IntToStr(i,1)));
  If Not Sh.OkOp Then Begin
                     {MessageBox(#3^M+#3'Не обнаружен параметр Condensed'+IntToStr(i,1),Nil,mfError+mfCancelButton);}
                     {Goto 45;}
                    End;
  Condensed2[i]:=OrdStringToString(SH.GetString('Condensed2'+IntToStr(i,1)));
  If Not Sh.OkOp Then Begin
                     {MessageBox(#3^M+#3'Не обнаружен параметр Condensed2'+IntToStr(i,1),Nil,mfError+mfCancelButton);}
                     {Goto 45;}
                    End;
  Condensed3[i]:=OrdStringToString(SH.GetString('Condensed3'+IntToStr(i,1)));
  If Not Sh.OkOp Then Begin
                     {MessageBox(#3^M+#3'Не обнаружен параметр Condensed3'+IntToStr(i,1),Nil,mfError+mfCancelButton);}
                     {Goto 45;}
                    End;
  Condensed4[i]:=OrdStringToString(SH.GetString('Condensed4'+IntToStr(i,1)));
  If Not Sh.OkOp Then Begin
                     {MessageBox(#3^M+#3'Не обнаружен параметр Condensed4'+IntToStr(i,1),Nil,mfError+mfCancelButton);}
                     {Goto 45;}
                    End;
  Condensed5[i]:=OrdStringToString(SH.GetString('Condensed5'+IntToStr(i,1)));
  If Not Sh.OkOp Then Begin
                     {MessageBox(#3^M+#3'Не обнаружен параметр Condensed5'+IntToStr(i,1),Nil,mfError+mfCancelButton);}
                     {Goto 45;}
                    End;
  NoCondensed[i]:=OrdStringToString(SH.GetString('NoCondensed'+IntToStr(i,1)));
  If Not Sh.OkOp Then Begin
                     {MessageBox(#3^M+#3'Не обнаружен параметр NoCondensed'+IntToStr(i,1),Nil,mfError+mfCancelButton);
                     {Goto 45;}
                    End;
  High[i]:=OrdStringToString(SH.GetString('High'+IntToStr(i,1)));
  If Not Sh.OkOp Then Begin
                     {MessageBox(#3^M+#3'Не обнаружен параметр High'+IntToStr(i,1),Nil,mfError+mfCancelButton);}
                     {Goto 45;}
                    End;
  High1[i]:=OrdStringToString(SH.GetString('High1'+IntToStr(i,1)));
  If Not Sh.OkOp Then Begin
                     {MessageBox(#3^M+#3'Не обнаружен параметр High1'+IntToStr(i,1),Nil,mfError+mfCancelButton);}
                     {Goto 45;}
                    End;
  High2[i]:=OrdStringToString(SH.GetString('High2'+IntToStr(i,1)));
  If Not Sh.OkOp Then Begin
                     {MessageBox(#3^M+#3'Не обнаружен параметр High2'+IntToStr(i,1),Nil,mfError+mfCancelButton);}
                     {Goto 45;}
                    End;
  High3[i]:=OrdStringToString(SH.GetString('High3'+IntToStr(i,1)));
  If Not Sh.OkOp Then Begin
                     {MessageBox(#3^M+#3'Не обнаружен параметр High3'+IntToStr(i,1),Nil,mfError+mfCancelButton);}
                     {Goto 45;}
                    End;
  High4[i]:=OrdStringToString(SH.GetString('High4'+IntToStr(i,1)));
  If Not Sh.OkOp Then Begin
                     {MessageBox(#3^M+#3'Не обнаружен параметр High4'+IntToStr(i,1),Nil,mfError+mfCancelButton);}
                     {Goto 45;}
                    End;
  NoHigh[i]:=OrdStringToString(SH.GetString('NoHigh'+IntToStr(i,1)));
  If Not Sh.OkOp Then Begin
                     {MessageBox(#3^M+#3'Не обнаружен параметр NoHigh'+IntToStr(i,1),Nil,mfError+mfCancelButton);}
                     {Goto 45;}
                    End;
  Italic[i]:=OrdStringToString(SH.GetString('Italic'+IntToStr(i,1)));
  If Not Sh.OkOp Then Begin
                     {MessageBox(#3^M+#3'Не обнаружен параметр Italic'+IntToStr(i,1),Nil,mfError+mfCancelButton);}
                     {Goto 45;}
                    End;
  NoItalic[i]:=OrdStringToString(SH.GetString('NoItalic'+IntToStr(i,1)));
  If Not Sh.OkOp Then Begin
                     {MessageBox(#3^M+#3'Не обнаружен параметр NoItalic'+IntToStr(i,1),Nil,mfError+mfCancelButton);}
                     {Goto 45;}
                    End;
  MaxLine[i]:=StrToInt(OrdStringToString(SH.GetString('MaxLine'+IntToStr(i,1))));
  If Not Sh.OkOp Then Begin
                     {MessageBox(#3^M+#3'Не обнаружен параметр MaxLine'+IntToStr(i,1),Nil,mfError+mfCancelButton);}
                     {Goto 45;}
                    End;
  EndPage[i]:=OrdStringToString(SH.GetString('EndPage'+IntToStr(i,1)));
  If Not Sh.OkOp Then Begin
                     {MessageBox(#3^M+#3'Не обнаружен параметр EndPage'+IntToStr(i,1),Nil,mfError+mfCancelButton);}
                     {Goto 45;}
                    End;
  DopIni[i]:=OrdStringToString(SH.GetString(''+IntToStr(i,1)));
  If Not Sh.OkOp Then Begin
                     {MessageBox(#3^M+#3'Не обнаружен параметр '+IntToStr(i,1),Nil,mfError+mfCancelButton);}
                     {Goto 45;}
                    End;
  OrientNormal[i]:=OrdStringToString(SH.GetString('OrientNormal'+IntToStr(i,1)));
  If Not Sh.OkOp Then Begin
                     {MessageBox(#3^M+#3'Не обнаружен параметр OrientNormal'+IntToStr(i,1),Nil,mfError+mfCancelButton);}
                     {Goto 45;}
                    End;
  OrientAlbom[i]:=OrdStringToString(SH.GetString('OrientAlbom'+IntToStr(i,1)));
  If Not Sh.OkOp Then Begin
                     {MessageBox(#3^M+#3'Не обнаружен параметр OrientAlbom'+IntToStr(i,1),Nil,mfError+mfCancelButton);}
                     {Goto 45;}
                    End;
  MinInterval[i]:=OrdStringToString(SH.GetString('MinInterval'+IntToStr(i,1)));
  If Not Sh.OkOp Then Begin
                     {MessageBox(#3^M+#3'Не обнаружен параметр MinInterval'+IntToStr(i,1),Nil,mfError+mfCancelButton);}
                     {Goto 45;}
                    End;
  MinInterval2[i]:=OrdStringToString(SH.GetString('MinInterval2'+IntToStr(i,1)));
  If Not Sh.OkOp Then Begin
                     {MessageBox(#3^M+#3'Не обнаружен параметр MinInterval2'+IntToStr(i,1),Nil,mfError+mfCancelButton);}
                     {Goto 45;}
                    End;
  MinInterval3[i]:=OrdStringToString(SH.GetString('MinInterval3'+IntToStr(i,1)));
  If Not Sh.OkOp Then Begin
                     {MessageBox(#3^M+#3'Не обнаружен параметр MinInterval3'+IntToStr(i,1),Nil,mfError+mfCancelButton);}
                     {Goto 45;}
                    End;
  Normal[i]:=OrdStringToString(SH.GetString('Normal'+IntToStr(i,1)));
  If Not Sh.OkOp Then Begin
                    { MessageBox(#3^M+#3'Не обнаружен параметр Normal'+IntToStr(i,1),Nil,mfError+mfCancelButton);}
                     {Goto 45;}
                    End;
End;{for}

  LoadPrintersFont:=true;

45:

SH.Done;
End;{function}





CONSTRUCTOR TPrintersFontPtr.Init;
var i: byte;
BEGIN
   inherited Init;
   with Dat do
   for i:=0 to 3 do
   begin
      Bold[i]:='';
      NoBold[i]:='';
      Double[i]:='';
      NoDouble[i]:='';
      Pitch[i]:='';
      NoPitch[i]:='';
      Condensed0[i]:='';
      Condensed[i]:='';
      Condensed2[i]:='';
      Condensed3[i]:='';
      Condensed4[i]:='';
      Condensed5[i]:='';
      NoCondensed[i]:='';
      High[i]:='';
      High1[i]:='';
      High2[i]:='';
      High3[i]:='';
      High4[i]:='';
      NoHigh[i]:='';
      Italic[i]:='';
      NoItalic[i]:='';
      MaxLine[i]:=0;
      EndPage[i]:='';
      DopIni[i]:='';
      OrientNormal[i]:='';
      OrientAlbom[i]:='';
      MinInterval[i]:='';
      MinInterval2[i]:='';
      MinInterval3[i]:='';
      Normal[i]:='';
   end;
END;




DESTRUCTOR TPrintersFontPtr.Done;
BEGIN
 inherited Done;
END;


procedure FormPrnList;

var t: text;
    IORez: word;
    i: word;
BEGIN
Assign(t,'c:\printers.ini');
IOrez:=ioresult;
Rewrite(t);
IOrez:=ioresult;
for i:=0 to 3 do  writeln(t,'Bold[',IntToStr(i,1),']=',StringToOrdString(Bold[i]));
for i:=0 to 3 do  writeln(t,'NoBold[',IntToStr(i,1),']=',StringToOrdString(NoBold[i]));
for i:=0 to 3 do  writeln(t,'Double[',IntToStr(i,1),']=',StringToOrdString(Double[i]));
for i:=0 to 3 do  writeln(t,'NoDouble[',IntToStr(i,1),']=',StringToOrdString(NoDouble[i]));
for i:=0 to 3 do  writeln(t,'Pitch[',IntToStr(i,1),']=',StringToOrdString(Pitch[i]));
for i:=0 to 3 do  writeln(t,'NoPitch[',IntToStr(i,1),']=',StringToOrdString(NoPitch[i]));
for i:=0 to 3 do  writeln(t,'Condensed0[',IntToStr(i,1),']=',StringToOrdString(Condensed0[i]));
for i:=0 to 3 do  writeln(t,'Condensed[',IntToStr(i,1),']=',StringToOrdString(Condensed[i]));
for i:=0 to 3 do  writeln(t,'Condensed2[',IntToStr(i,1),']=',StringToOrdString(Condensed2[i]));
for i:=0 to 3 do  writeln(t,'Condensed3[',IntToStr(i,1),']=',StringToOrdString(Condensed3[i]));
for i:=0 to 3 do  writeln(t,'Condensed4[',IntToStr(i,1),']=',StringToOrdString(Condensed4[i]));
for i:=0 to 3 do  writeln(t,'Condensed5[',IntToStr(i,1),']=',StringToOrdString(Condensed5[i]));
for i:=0 to 3 do  writeln(t,'NoCondensed[',IntToStr(i,1),']=',StringToOrdString(NoCondensed[i]));
for i:=0 to 3 do  writeln(t,'High[',IntToStr(i,1),']=',StringToOrdString(High[i]));
for i:=0 to 3 do  writeln(t,'High1[',IntToStr(i,1),']=',StringToOrdString(High1[i]));
for i:=0 to 3 do  writeln(t,'High2[',IntToStr(i,1),']=',StringToOrdString(High2[i]));
for i:=0 to 3 do  writeln(t,'High3[',IntToStr(i,1),']=',StringToOrdString(High3[i]));
for i:=0 to 3 do  writeln(t,'High4[',IntToStr(i,1),']=',StringToOrdString(High4[i]));
for i:=0 to 3 do  writeln(t,'NoHigh[',IntToStr(i,1),']=',StringToOrdString(NoHigh[i]));
for i:=0 to 3 do  writeln(t,'Italic[',IntToStr(i,1),']=',StringToOrdString(Italic[i]));
for i:=0 to 3 do  writeln(t,'NoItalic[',IntToStr(i,1),']=',StringToOrdString(NoItalic[i]));
for i:=0 to 3 do  writeln(t,'MaxLine[',IntToStr(i,1),']=',StringToOrdString(IntToStr(MaxLine[i],3)));
for i:=0 to 3 do  writeln(t,'EndPage[',IntToStr(i,1),']=',StringToOrdString(EndPage[i]));
for i:=0 to 3 do  writeln(t,'DopIni[',IntToStr(i,1),']=',StringToOrdString(DopIni[i]));
for i:=0 to 3 do  writeln(t,'OrientNormal[',IntToStr(i,1),']=',StringToOrdString(OrientNormal[i]));
for i:=0 to 3 do  writeln(t,'OrientAlbom[',IntToStr(i,1),']=',StringToOrdString(OrientAlbom[i]));
for i:=0 to 3 do  writeln(t,'MinInterval[',IntToStr(i,1),']=',StringToOrdString(MinInterval[i]));
for i:=0 to 3 do  writeln(t,'MinInterval2[',IntToStr(i,1),']=',StringToOrdString(MinInterval2[i]));
for i:=0 to 3 do  writeln(t,'MinInterval3[',IntToStr(i,1),']=',StringToOrdString(MinInterval3[i]));
for i:=0 to 3 do  writeln(t,'Normal[',IntToStr(i,1),']=',StringToOrdString(Normal[i]));

IOrez:=ioresult;
close(t);
IOrez:=ioresult;
End;



procedure TestLoadFont;
var Font: PPrintersFont;
    t: text;
    IORez: word;
BEgin
 New(Font,Init);

 Assign(t,'c:\testprn.txt');
 IOrez:=ioresult;
 rewrite(t);
 IOrez:=ioresult;

 if NOT LoadPrintersFont(Font) then writeln(t,'Ошибка загрузки шрифтов');
 writeln(t,Font^.Dat.Bold[2],'Bold',Font^.Dat.NoBold[2]);
 writeln(t,Font^.Dat.Double[2],'Double',Font^.Dat.NoDouble[2]);
 writeln(t,Font^.Dat.Pitch[2],'Pitch',Font^.Dat.NoPitch[2]);
 writeln(t,Font^.Dat.Condensed[2],'Condensed',Font^.Dat.NoCondensed[2]);
 writeln(t,Font^.Dat.Condensed0[2],'Condensed0',Font^.Dat.NoCondensed[2]);
 writeln(t,Font^.Dat.Condensed2[2],'Condensed2',Font^.Dat.NoCondensed[2]);
 writeln(t,Font^.Dat.Condensed3[2],'Condensed3',Font^.Dat.NoCondensed[2]);
 writeln(t,Font^.Dat.Condensed4[2],'Condensed4',Font^.Dat.NoCondensed[2]);
 writeln(t,Font^.Dat.Condensed5[2],'Condensed5',Font^.Dat.NoCondensed[2]);
 writeln(t,Font^.Dat.High[2],'High',Font^.Dat.NoHigh[2]);
 writeln(t,Font^.Dat.High1[2],'High1',Font^.Dat.NoHigh[2]);
 writeln(t,Font^.Dat.High2[2],'High2',Font^.Dat.NoHigh[2]);
 writeln(t,Font^.Dat.High3[2],'High3',Font^.Dat.NoHigh[2]);
 writeln(t,Font^.Dat.High4[2],'High4',Font^.Dat.NoHigh[2]);
 writeln(t,Font^.Dat.Italic[2],'Italic',Font^.Dat.NoItalic[2]);
 writeln(t,Font^.Dat.MinInterval[2],'MinInterval',Font^.Dat.Normal[2]);
 writeln(t,Font^.Dat.MinInterval2[2],'MinInterval2',Font^.Dat.Normal[2]);
 writeln(t,Font^.Dat.MinInterval3[2],'MinInterval3',Font^.Dat.Normal[2]);
 writeln(t,'What''s all');
 IOrez:=ioresult;
 close(t);
 IOrez:=ioresult;
 Dispose(Font,Done);
End;


BEGIN
FormPrnList;
END.