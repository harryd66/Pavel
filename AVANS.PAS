{$I Compile.INC}

{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}
Unit Avans;

INTERFACE

Uses Glob, Servstr;

procedure PrintAvansReport(EditKassa: DocumentEdit);

IMPLEMENTATION

Uses Tools,Views, DBEngine,MsgBox,Vision2, Serv, Printers,TPDate,Objects,Dialogs,NetDbEng,NetCall,Dos;

procedure PrintAvansReport(EditKassa: DocumentEdit);
const Space=' ';

var  E : KassaOperation;
     f : OperationFileType;
     Ak : PItogKassa;
     S,s1  : string[150];
     i,c: word;
     test: word;
     Fp : ItogKAssaFileType;
     AS: DocumentEdit;
     t: text;
Begin
Assign(fp,Path.ToClient+EditKassa.D+'.kas');
Reset(fp);
c:=IOResult;
If c=0 Then
Begin
  New(Ak,Init);
  While Not(Eof(Fp)) Do
   Begin
    ReadKassa(Fp,Ak^.DAt);
    if StrToInt(Ak^.DAt.Doc)=StrToInt(EditKassa.EditPosition) then
    begin
     {writeln(GetLizoField(ffName,AK^.DAt.Lizo));
     readln;}
     Assign(t,Path.ToTemp+'avans.txt');
     c:=IOResult;
     Rewrite(t);
     c:=IOResult;
     if c=0 then
     begin
       DelSpace(Ak^.DAt.Doc);
       While(pos('-',EditKassa.D)>0) do System.Delete(EditKassa.D,pos('-',EditKassa.D),1);
       Writeln(t,Space+'ИП Еродский П.Е.');
                 {12345678901234567890123456789012345678901234567890123456789012345678901234567890}
       Writeln(t,Space+'                                           УТВЕРЖДАЮ:');
       Writeln(t,Space+'                                           Отчет в сумме___________________');
       Writeln(t,Space+'      А В А Н С О В Ы Й   О Т Ч Е Т        _____________руб.________коп.___');
       Writeln(t,Space+'      Номер:',Ak^.DAt.Doc,'/',EditKassa.D,' Дата: ',FDate,' г.     Руководитель:');
       Writeln(t,Space+'                                           ________________________________');
       Writeln(t,Space+'                                           "______"_______________20_____г.');
       Writeln(t,Space+'Структурное подразделение________________________________');
       Writeln(t,Space+'Подотчетное лицо: ',GetLizoField(ffName,AK^.DAt.Lizo));
       Writeln(t,Space+'Профессия(должость)________________________________');
Writeln(t,Space+'┌─────────────────────────────┬──────────────────────┐');
Writeln(t,Space+'│Наименование показателя      │Сумма (руб.,коп)      │');
Writeln(t,Space+'├──────────────────┬──────────┼──────────────────────┤');
Writeln(t,Space+'│ Предыдущий аванс │Остаток   │                      │');
Writeln(t,Space+'│                  │Перерасход│                      │');
Writeln(t,Space+'├──────────────────┴──────────┼──────────────────────┤');
Writeln(t,Space+'│Получен аванс: 1. из кассы   │ '+RecognizReal(Ak^.DAt.Summa,CIZena,CMantissa));
Writeln(t,Space+'├─────────────────────────────┼──────────────────────┤');
Writeln(t,Space+'│               2.            │                      │');
Writeln(t,Space+'├─────────────────────────────┼──────────────────────┤');
Writeln(t,Space+'│ Итого получено              │                      │');
Writeln(t,Space+'├─────────────────────────────┼──────────────────────┤');
Writeln(t,Space+'│ Израсходовано               │                      │');
Writeln(t,Space+'├─────────────────────────────┼──────────────────────┤');
Writeln(t,Space+'│ Остаток                     │                      │');
Writeln(t,Space+'├─────────────────────────────┼──────────────────────┤');
Writeln(t,Space+'│ Перерасход                  │                      │');
Writeln(t,Space+'└─────────────────────────────┴──────────────────────┘');
                {12345678901234567890123456789012345678901234567890123456789012345678901234567890}
Writeln(t,Space+'Отчет проверен. К утверждению в сумме_____________________________руб.______коп.');
Writeln(t,Space+'Главный бухгалтер_______________________________________');
Writeln(t,Space+'Остаток внесен      в сумме            руб.    коп.   по кассовому ордеру №______');
Writeln(t,Space+'Перерасход выдан                                      от"_______"_________20____г.');
Writeln(t,Space+'Бухгалтер (кассир)_______________________________________');
Writeln(t,Space+'┌────┬────────────────┬─────────────────────────────┬───────────────────────────────────┬──────────┐');
Writeln(t,Space+'│ №  │  Документ,     │ Наименование документа      │     Сумма расхода                 │Дебет     │');
Writeln(t,Space+'│п/п │  потверждающий │    (расхода)                ├────────────────┬──────────────────┤счета,    │');
Writeln(t,Space+'│    │  расходы       │                             │  по отчету,руб.│ принятая к учету │субсчета  │');
Writeln(t,Space+'│    ├───────┬────────┤                             │                │                  │          │');
Writeln(t,Space+'│    │Дата   │Номер   │                             │                │                  │          │');
Writeln(t,Space+'├────┼───────┼────────┼─────────────────────────────┼────────────────┼──────────────────┼──────────┤');
Writeln(t,Space+'│    │       │        │                             │                │                  │          │');
Writeln(t,Space+'├────┼───────┼────────┼─────────────────────────────┼────────────────┼──────────────────┼──────────┤');
Writeln(t,Space+'│    │       │        │                             │                │                  │          │');
Writeln(t,Space+'├────┼───────┼────────┼─────────────────────────────┼────────────────┼──────────────────┼──────────┤');
Writeln(t,Space+'│    │       │        │                             │                │                  │          │');
Writeln(t,Space+'├────┼───────┼────────┼─────────────────────────────┼────────────────┼──────────────────┼──────────┤');
Writeln(t,Space+'│    │       │        │                             │                │                  │          │');
Writeln(t,Space+'├────┼───────┼────────┼─────────────────────────────┼────────────────┼──────────────────┼──────────┤');
Writeln(t,Space+'│    │       │        │                             │                │                  │          │');
Writeln(t,Space+'└────┴───────┴────────┴─────────────────────────────┼────────────────┼──────────────────┼──────────┤');
Writeln(t,Space+'                                ИТОГО:              │                │                  │          │');
Writeln(t,Space+'                                                    └────────────────┴──────────────────┴──────────┘');
Writeln(t,Space+' Подотчетное лицо_______________________');
Writeln(t);
Writeln(t,Space+'-------------------------------------Линия отреза--------------------------------------------------');
Writeln(t);
Writeln(t,Space+'Расписка.Принят к проверке от_____________________________авансовый отчет № ',Ak^.DAt.Doc,'/',EditKassa.D);
Writeln(t,Space+'         от ',FDate,' г. на сумму ___________________________________руб.____________коп.');
Writeln(t,Space+'Бухгалтер _____________________________________________');
Writeln(t,Space+'  "_____" ___________________ 20_____г.');
Writeln(t);
Writeln(t,Space,'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
  Writeln(t,Space+'==================================================================================================');
       close(t);

       ViewAsText(Path.ToTemp+'avans.txt',True);
     end
     else
     begin
     end;
     {Ak^.DAt.Input[Ak^.DAt.Amount+1].Summa:=StrToReal(sSumma);
     Ak^.DAt.Input[Ak^.DAt.Amount+1].Comment:=Comment;
     inc(Ak^.DAt.Amount);
     LockAndWriteKassaAs(EditKassa,Ak);}
     break;
    end;
   end;
  Dispose(Ak,Done);
END;
End;

BEGIN
END.