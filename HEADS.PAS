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
Writeln(f,Space+'旼컴쩡컴컴컴컫컴컴컴컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컴컴컫컴컴컴컴컴쩡컴쩡컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴'+
 +'컴컴컴컴컴컴�');
 Writeln(f,Space+'쿙  퀎졻� ㄾこ궓� ����졿Ŀ                � 꽖‥�    � 듺ⅳⓥ   쿙  퀎졻� ㄾ�,궓� ����졿Ŀ    � 꽖‥� '
 +'� 듺ⅳⓥ   ');
 Writeln(f,Space+'읕컴좔컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴좔컴컴컴컴컨컴컴컴컴컴좔컴좔컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴'+
 +'컴컴컴컴컴컴�');
End;

END.

