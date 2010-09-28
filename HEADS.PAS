{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}
{$I Compile.INC}

Unit Heads;

Interface

procedure InfoDynamicDebitFormReport2(var f:text;space:string);

Implementation


procedure InfoDynamicDebitFormReport2(var f:text;space:string);
Begin
Writeln(f,Space+'здддбддддддддбддддддддддддддддддддддддддддбддддддддддбддддддддддбдддбддддддддддддддддддддддддддддддддд'+
 +'дддддддддддд©');
 Writeln(f,Space+'ЁN  Ё└═Б═ ╓╝╙Ё┌╗╓ ╝╞╔Ю═Ф╗╗                Ё └╔║╔Б    Ё ┼Ю╔╓╗Б   ЁN  Ё└═Б═ ╓╝╙,┌╗╓ ╝╞╔Ю═Ф╗╗    Ё └╔║╔Б '
 +'Ё ┼Ю╔╓╗Б   ');
 Writeln(f,Space+'юдддаддддддддаддддддддддддддддддддддддддддаддддддддддаддддддддддадддаддддддддддддддддддддддддддддддддд'+
 +'дддддддддддды');
End;

END.

