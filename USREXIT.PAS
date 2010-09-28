Unit UsrExit;
{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}


Interface

Uses MsgBox,ServStr,Glob,Serv;

Var OldExit : Pointer;

Procedure UserExit;
Function HexB(b:Byte):String;
Function HexW(N:Word):String;

Implementation

Procedure UserExit;
Var ws,Txt : String;
    f : Text;
    c : Byte;
Begin
 Assign(f,'c:\error.txt');
 c:=IOResult;
 Append(f);
 c:=IOResult;
 If c<>0 Then Rewrite(f);
 c:=IOResult;

 ExitProc:=OldExit;
 case ExitCode Of
  1: txt:='Неверный номер функции';
  2: txt:='Не найден файл';
  3: txt:='Не найден путь';
  4: txt:='Слишком много открытых файлов';
  5: txt:='Отказано в доступе к файлу';
  6: txt:='Недопустимый файловый дескриптор';
 12: txt:='Недопустимый код доступа к файлу';
 15: txt:='Недопустимый номер дисковода';
 16: txt:='Нельзя удалить текущий каталог';
 17: txt:='Нельзя указывать разные дисководы';
100: txt:='Ошибка чтения диска';
101: txt:='Ошибка записи на диск';
102: txt:='Файлу не присвоено имя';
103: txt:='Файл не открыт';
104: txt:='Файл не открыт для ввода';
105: txt:='Файл не открыт для вывода';
106: txt:='Неверный числовой формат';
150: txt:='Диск защищен от записи';
151: txt:='Неизвестный модуль';
152: txt:='Диск не готов';
153: txt:='Неопознанная команда';
154: txt:='Ошибка исходных данных';
155: txt:='Неверная длина структуры';
156: txt:='Ошибка установки головок на диске';
157: txt:='Неизвестный тип носителя';
158: txt:='Не найден сектор';
159: txt:='Кончилась бумага на принтере';
160: txt:='Ошибка при записи на устройство';
161: txt:='Ошибка при чтении с устройства';
162: txt:='Сбой аппаратуры';
200: txt:='Деление на ноль';
201: txt:='Ошибка при проверке границ';
202: txt:='Переполнение стека';
203: txt:='Переполнение кучи';
204: txt:='Недопустимая операция с указателем';
205: txt:='Переполнение при операции с плавающей точкой';
206: txt:='Исчезновение порядка при операции с плавающей точкой';
207: txt:='Недопустимая операция с плавающей точкой';
208: txt:='Не инициирован оверлей';
209: txt:='Ошибка чтения оверлейного файла';
210: txt:='Объект не инициализирован';
211: txt:='Вызван абастрактный метод';
212: txt:='Ошибка регистрации потока';
213: txt:='Индекс коллекции выходит за границы диапазона';
214: txt:='Переполнение коллекции';
215: txt:='Арифметическое переполнение';
216: txt:='Ошибка защиты DPMI';
Else Begin
      Str(ExitCode,ws);
      DelSpace(ws);
      txt:='Ошибка N'+ws;
     End;
End;{CAse}

If ExitCode=216 Then
Begin
 Writeln(f,'Аварийное завершение: '+ FDate+'('+Times+') '+txt);
 Writeln(f,'Оператор: '+CurrentPassword);
 Writeln(f,'___________________________________________________________');
 Close(f);
 DelFlag;
End
 Else
  Begin
   Writeln(f,'Аварийное завершение: '+ FDate+'('+Times+') '+txt);
   Writeln(f,'Адрес ошибки: '+HexW(Seg(ErrorAddr^))+':'+HexW(ofs(ErrorAddr^)));
   Writeln(f,'Оператор: '+CurrentPassword);
   Writeln(f,'___________________________________________________________');
   Close(f);
   DelFlag;
   txt:=^M+#3+txt+^M+#3+' по адресу ';
   txt:=txt+HexW(Seg(ErrorAddr^))+':'+HexW(ofs(ErrorAddr^));
   MessageBox(txt,Nil,mfFatalError+mfInsertInApp+mfCancelButton);
  End;
ExitCode:=0;
ErrorAddr:=Nil;
End;{UserExit}


Function HexB(b:Byte):String;
Const HD : Array [0..15] Of Char =('0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F');
Begin
 HexB:=HD [b shr 4]+ HD[b and $F];
End;

Function HexW(N:Word):String;
Begin
 HexW:=HexB(Hi(n))+HexB(Lo(n))
End;

End.