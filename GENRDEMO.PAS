{************************************************}
{                                                }
{   Turbo Vision Demo                            }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

{ Resource generator for TVRDEMO.EXE. This program generates the
  resource file that is used TVRDEMO.PAS. To build this program,
  execute the batch file, MKRDEMO.BAT.

  Note: This program is designed for real-mode use only.
}

program GenRDemo;

uses Drivers, Objects, Views, Dialogs, Menus,ServStr,Glob,App;



{ If you get a FILE NOT FOUND error when compiling this program,
  use the MKRDEMO.BAT file described above.
}

type
  PProtectedStream = ^TProtectedStream;
  TProtectedStream = object(TBufStream)
    procedure Error(Code, Info: Integer); virtual;
  end;

var
  RezFile: TResourceFile;
  RezStream: PStream;

{ TProtectedStream }

procedure TProtectedStream.Error(Code, Info: Integer);
begin
  Writeln('Error in stream: Code = ', Code, ' Info = ', Info);
  Halt(1);
end;

{ Resource procedures }



procedure CreateStatusLine;
var
  R: TRect;
  P,p1: PStatusLine;
  z:PStatusDef;
begin
  R.Assign(0, 24, 80, 25);
  P :=New(PStatusLine, Init(R,
      NewStatusDef($E000, $E001,{1}
      NewStatusKey(NewElement,kbNoKey,cmNoNe,
      NewStatusKey(Vibor, kbNoKey, cmNoNe,
      NewStatusKey(Edit, kbNoKey, cmNoNe,
      NewStatusKey(Cancel, kbEsc, cmCancel,
      NewStatusKey('~Ctrl-Н~ Обнов.', kbCtrlRusN, cmRefresh,
      NewStatusKey('~F6~ Дополн.', kbNoKey, CmClose,
      NewStatusKey('', kbCtrlEnter, CmOk,
      NewStatusKey(Menu, kbF10, CmMenu,
      nil)))))))),
     NewStatusDef($E002, $E005,{2}
      NewStatusKey(Enter, kbNoKey, cmNoNe,
      NewStatusKey('', kbNoKey, CmClose,
      NewStatusKey(Ok, kbCtrlEnter, CmOk,
      NewStatusKey(Cancel, kbEsc, cmCancel,
      NewStatusKey('', kbF10, CmMenu,
      nil))))),
     NewStatusDef($E005, $E010,{3}
      NewStatusKey('~'+#17+#217+'~ Выбор', kbNoKey, cmNoNe,
      NewStatusKey(Uprawlenie, kbNoKey, cmNoNe,
      NewStatusKey(Cancel, kbEsc, cmClose,
      NewStatusKey('', kbF10, CmMenu,
      NewStatusKey('', kbCtrlEnter, CmOk,
         nil))))),
     NewStatusDef($E010, $E011,{4}
      NewStatusKey(Enter, kbNoKey, cmNoNe,
      NewStatusKey(Ok, kbCtrlEnter, CmOk,
      NewStatusKey(Cancel, kbEsc, cmCancel,
      NewStatusKey('', kbNoKey, CmClose,
      NewStatusKey('', kbF10, CmMenu,
         nil))))),
     NewStatusDef($E040, $E042,{5}
         NewStatusKey('~Del~ Удал.', kbNoKey, cmNone,
         NewStatusKey('~^Del~ Удал.все', kbNoKey, cmNone,
         NewStatusKey('', kbNoKey, CmClose,
         NewStatusKey(Ok, kbCtrlEnter, CmOk,
         NewStatusKey(Cancel, kbEsc, cmCancel,
         NewStatusKey('', kbF10, CmMenu,
         nil)))))),
        NewStatusDef($E043, $E045,{6}
         NewStatusKey('~Ins~ Выбор',kbNoKey,cmNoNe,
         NewStatusKey('~^Ins~ Выбрать все',kbNoKey,cmNoNe,
         NewStatusKey('', kbNoKey, CmClose,
         NewStatusKey(Ok, kbCtrlEnter, CmOk,
         NewStatusKey(Cancel, kbEsc, cmCancel,
         NewStatusKey('', kbF10, CmMenu,
         nil)))))),
        NewStatusDef($E080, $E085,{7}
         NewStatusKey(Ok1, kbEnter, cmOk,
         NewStatusKey('', kbCtrlEnter, cmOk,
         NewStatusKey(Cancel, kbEsc, cmClose,
         nil))),
        NewStatusDef($E090, $E096,{8}
         NewStatusKey('~Esc~ Закрыть', kbEsc, cmClose,
         NewStatusKey('', kbEnter, cmNone,Nil)),
        NewStatusDef($E099, $E105,{9}
         NewStatusKey('~Esc~ Закрыть', kbEsc, cmClose,
         NewStatusKey('~Alt-F9~ Печать справки', kbAltF9, cmReestrReport,
         NewStatusKey('', kbEnter, cmNone,Nil))),
    NewStatusDef($E140, $E145,{10}
         NewStatusKey(Vibor, kbNoKey, cmNone,
         NewStatusKey('', kbNoKey, CmClose,
         NewStatusKey(Ok, kbCtrlEnter, CmOk,
         NewStatusKey(Cancel, kbEsc, cmCancel,
         NewStatusKey('~Ctrl-Н~ Обнов.', kbCtrlRusN, cmRefresh,
         NewStatusKey(Find, kbNoKey, CmNoNe,
         NewStatusKey('', kbF10, CmMenu,
         nil))))))),
    NewStatusDef($E145, $E155,{11}
         NewStatusKey('~Del~ Удал.', kbNoKey, cmNone,
         NewStatusKey(Enter, kbNoKey, cmNoNe,
         NewStatusKey(Edit, kbNoKey, cmNoNe,
         NewStatusKey(Cancel, kbEsc, cmCancel,
         NewStatusKey(Find, kbNoKey, CmNoNe,
         NewStatusKey('', kbNoKey, CmClose,
         NewStatusKey('', kbCtrlEnter, CmOk,
         NewStatusKey('', kbF10, CmMenu,
         nil)))))))),
    NewStatusDef($E156, $E158,{12}
         NewStatusKey(Vibor, kbNoKey, cmNoNe,
         NewStatusKey('~F2~ Смен.исходный', kbF2, CmChangeDoc,
         NewStatusKey(Ok, kbCtrlEnter, CmOk,
         NewStatusKey(Cancel, kbEsc, cmCancel,
         NewStatusKey('', kbNoKey, CmClose,
         NewStatusKey('', kbF10, CmMenu,
         nil)))))),
    NewStatusDef($E159, $E159,{13}
         NewStatusKey('~Del~ Удал.', kbNoKey, cmNoNe,
         NewStatusKey('~F2~ Смен.исходный', kbF2, CmChangeDoc,
         NewStatusKey(Edit, kbNoKey, cmNoNe,
         NewStatusKey(Ok, kbCtrlEnter, CmOk,
         NewStatusKey(Cancel, kbEsc, cmCancel,
         NewStatusKey('', kbNoKey, CmClose,
         NewStatusKey('', kbF10, CmMenu,
         nil))))))),
        NewStatusDef($E160, $E165,{14}
         NewStatusKey('~Alt~+~'+'0..8~ - добавить в N-ый список', kbNoKey, cmNone,
         NewStatusKey(Ok, kbCtrlEnter, CmOk,
         NewStatusKey(Cancel, kbEsc, cmCancel,
         NewStatusKey('', kbNoKey, CmClose,
         NewStatusKey(Find, kbNoKey, CmNoNe,
         nil))))),
    NewStatusDef($E166, $E170,{15}
         NewStatusKey('~Del~ Удал.', kbNoKey, cmNone,
         NewStatusKey(NewElement,kbNoKey,cmNoNe,
         NewStatusKey(Vibor, kbNoKey, cmNoNe,
         NewStatusKey(Edit, kbNoKey, cmNoNe,
         NewStatusKey(Cancel, kbEsc, cmCancel,
         NewStatusKey('~Ctrl-Н~ Обнов.', kbCtrlRusN, cmRefresh,
         NewStatusKey(Find, kbNoKey, CmNoNe,
         NewStatusKey('', kbCtrlEnter, CmOk,
         NewStatusKey('', kbF10, CmMenu,
         nil))))))))),
    NewStatusDef($E171, $E175,{16}
         NewStatusKey('~Del~ Удал.', kbNoKey, cmNone,
         NewStatusKey(NewElement,kbNoKey,cmNoNe,
         NewStatusKey(Vibor, kbNoKey, cmNoNe,
         NewStatusKey(Edit, kbNoKey, cmNoNe,
         NewStatusKey('~F5~ Печ.', kbF5, cmPrintReestr,
         NewStatusKey(Cancel, kbEsc, cmCancel,
         NewStatusKey('~Ctrl-Н~ Обнов.', kbCtrlRusN, cmRefresh,
         NewStatusKey('', kbNoKey, CmClose,
         NewStatusKey('', kbCtrlEnter, CmOk,
         nil))))))))),
        NewStatusDef($E190, $E195,{17}
         NewStatusKey(Enter, kbNoKey, cmNoNe,
         NewStatusKey(Ok, kbCtrlEnter, CmOk,
         NewStatusKey(Cancel, kbEsc, cmCancel,
         NewStatusKey('~Alt-К~ Калькулятор', kbAltRusK, cmLocalCalc,
         nil)))),
        NewStatusDef($E196, $E199,{18}
         NewStatusKey(Enter, kbNoKey, cmNoNe,
         NewStatusKey(Ok, kbCtrlEnter, CmOk,
         NewStatusKey(Cancel, kbEsc, cmCancel,
         NewStatusKey('~Alt-К~ Кальк.', kbAltRusK, cmLocalCalc,
         NewStatusKey('~+~ Скид.', kbGrayPlus, cmLocalSkidka,
         NewStatusKey('~-~ Нацен.', kbGrayMinus, cmLocalNazenka,
         nil)))))),
    NewStatusDef($E200, $E205,{19}
         NewStatusKey('~Ins~ Печ', kbIns, cmPrintReestr,
         NewStatusKey('~'+#17+#217+'~ Опл', kbEnter, cmOplata,
         NewStatusKey('~Alt-Ы~ Истор', kbAltRusIII, CmLocalInfo,
         NewStatusKey('~^F7~ Откр',kbCtrlF7, CmDeblock,
         NewStatusKey('~F5~ Просм', kbF5, cmFullview,
         NewStatusKey('~Alt-F9~ Справ', kbAltF9, cmReestrReport,
         NewStatusKey('~F2~ Период', kbF2, cmChangeDiapason,
         NewStatusKey(Cancel, kbEsc, cmCancel,
         NewStatusKey('', kbF10, CmMenu,
         NewStatusKey('', kbNoKey, CmClose,
         nil)))))))))),
    NewStatusDef($E210, $E220,{20}
         NewStatusKey('~'+#17+#217+'~ Коррекция', kbEnter, cmEdit,
         NewStatusKey('~Ins~ Печ', kbIns, cmPrintReestr,
         NewStatusKey('~F5~ Просм', kbF5, cmFullview,
         NewStatusKey('~Alt-F9~ Справ', kbAltF9, cmReestrReport,
         NewStatusKey(Cancel, kbEsc, cmCancel,
         NewStatusKey('~Ctrl-Н~ Обнов', kbCtrlRusN, cmRefresh,
         NewStatusKey('', kbAltRusZ, cmUnlockMarket,
         NewStatusKey('', kbNoKey, CmClose,
         NewStatusKey('', kbF10, CmMenu,
         nil))))))))),
         NewStatusDef($E240, $E245,{21}
         NewStatusKey('', kbNoKey, CmClose,
         NewStatusKey(Ok1, kbEnter, CmOk,
         NewStatusKey('', kbCtrlEnter, CmOk,
         NewStatusKey(Cancel, kbEsc, cmCancel,
         nil)))),
      NewStatusDef($E246, $E250,{22}
      NewStatusKey(Vopros, kbEnter, CmOk,
      NewStatusKey('', kbCtrlEnter, CmOk,
      NewStatusKey(Cancel, kbEsc, cmCancel,
      nil))),
      NewStatusDef($E300, $E305,{23}
      NewStatusKey('~Esc~ Закрыть', kbEsc, cmClose,
      Nil),
      NewStatusDef($E306, $E310,{24}
      NewStatusKey('~'+#17+#217+'~ ?', kbEnter, cmEditPosition,
      NewStatusKey(Ok, kbCtrlEnter, CmOk,
      NewStatusKey(Cancel, kbEsc, cmCancel,
      NewStatusKey('~Alt-К~ Калькулятор', kbAltRusK, cmLocalCalc,
      nil)))),
      NewStatusDef($E315, $E317,{25}
      NewStatusKey('~F5~ Просмотр', kbF5, cmFullview,
      NewStatusKey('~Alt-F9~ Справка', kbAltF9, cmReestrReport,
      NewStatusKey(Cancel, kbEsc, cmCancel,
      NewStatusKey(Find, kbNoKey, CmNoNe,
      NewStatusKey('', kbNoKey, CmClose,
      NewStatusKey('', kbF10, CmMenu,
      NewStatusKey('', kbCtrlEnter, CmOk,
      nil))))))),
      NewStatusDef($E555, $E560,{26}
      NewStatusKey(Cancel, kbEsc, cmCancel,
      NewStatusKey('~Alt-К~ Калькулятор', kbAltRusK, cmLocalCalc,
      nil)),
      NewStatusDef($E560, $E565,{27}
      NewStatusKey('~F10~ Закрыть текущий программный день', kbF10, cmYes,
      NewStatusKey(Cancel, kbEsc, cmCancel,
      nil)),
      NewStatusDef($E570, $E580,{28}
      NewStatusKey('~Ins~ Печ', kbIns, cmPrintReestr,
      NewStatusKey('~F5~ Просм', kbF5, cmFullView,
      NewStatusKey('~F2~ Период', kbF2, cmChangeDiapason,
      NewStatusKey('~Alt-F9~ Отчет', kbAltF9, cmReestrReport,
      NewStatusKey('~Alt-Ы~ Истор', kbAltRusIII, CmLocalInfo,
      NewStatusKey('~!~ Месяц', Ord('!'), cmAnalysFromPeriod,
      NewStatusKey(Cancel, kbEsc, cmCancel,
      NewStatusKey('', kbNoKey, cmClose,
      NewStatusKey('', kbF10, cmMenu,
      nil))))))))),
         NewStatusDef($E616, $E625,{29}
         NewStatusKey('~Ins~ Печ', kbIns, cmPrintReestr,
         NewStatusKey('~F5~ Просм', kbF5, cmFullView,
         NewStatusKey('~Alt-F9~ Отчет', kbAltF9, cmReestrReport,
         NewStatusKey('~Alt-Ы~ Истор', kbAltRusIII, CmLocalInfo,
         NewStatusKey('~!~ Месяц', Ord('!'), cmAnalysFromPeriod,
         NewStatusKey(Cancel, kbEsc, cmCancel,
         nil)))))),
        NewStatusDef($E581, $E585,{30}
         NewStatusKey(Enter, kbNoKey, cmNoNe,
         NewStatusKey('', kbNoKey, CmClose,
         NewStatusKey('~F2~ Период', kbF2, cmChangeDiapason,
         NewStatusKey(Cancel, kbEsc, cmCancel,
         NewStatusKey('~F10~ Меню', kbF10, cmMenu,
         nil))))),
      NewStatusDef($E585, $E595,{31}
         NewStatusKey('~Ins~ Выбор',kbNoKey,cmNoNe,
         NewStatusKey('~^Ins~ Выбрать все',kbNoKey,cmNoNe,
         NewStatusKey('~^'+#17+#217+'~ Расчет', kbCtrlEnter, CmCalcStat,
         NewStatusKey('~F8~ Конкурс', kbF8, CmAllSpis,
         NewStatusKey('~F9~ Запрос', kbF9, CmAllSfB,
         NewStatusKey('', kbCtrlRusN, cmRefresh,
         NewStatusKey(Cancel, kbEsc, cmCancel,
         NewStatusKey('', kbNoKey, CmClose,
         NewStatusKey(Menu, kbF10, cmMenu,
         nil))))))))),
      NewStatusDef($E596, $E600,{32}
         NewStatusKey('~Del~ Удал.',kbNoKey, cmNone,
         NewStatusKey('~^Del~ Удал.все', kbNoKey, cmNone,
         NewStatusKey('~^'+#17+#217+'~ Расчет', kbCtrlEnter, CmCalcStat,
         NewStatusKey('~F9~ Запрос', kbF9, CmAllSfB,
         NewStatusKey('', kbCtrlRusN, cmRefresh,
         NewStatusKey(Cancel, kbEsc, cmCancel,
         NewStatusKey('', kbNoKey, CmClose,
         NewStatusKey(Menu, kbF10, cmMenu,
         nil)))))))),
      NewStatusDef($E601, $E605,{33}
         NewStatusKey('~^'+#17+#217+'~ Расчет', kbCtrlEnter, CmCalcStat,
         NewStatusKey(Cancel, kbEsc, cmCancel,
         NewStatusKey(Menu, kbF10, cmMenu,
         nil))),

      NewStatusDef($F000, $F001,{35}
         NewStatusKey('~^F7~ Поиск', kbCtrlF7, cmFind,
         NewStatusKey('~Shift-F7~ Повторить поиск',kbShiftF7, cmNextFind,
         NewStatusKey('~^F9~ Печать отчета', kbCtrlF9, cmPrintScreen,
         NewStatusKey('~Esc~ Закрыть', kbEsc, cmClose,
         NewStatusKey('', kbF10, cmMenu,
         nil))))),
      NewStatusDef($F003, $F005,{36}
         NewStatusKey('~^F7~ Поиск', kbCtrlF7, cmFind,
         NewStatusKey('~Shift-F7~ Повторить поиск',kbShiftF7, cmNextFind,
         NewStatusKey('~Esc~ Закрыть', kbEsc, cmClose,
         NewStatusKey(Menu, kbF10, cmMenu,
         nil)))),
      NewStatusDef($F006, $F010,{37}
      NewStatusKey('~Alt-К~ Калькулятор', kbAltRusK, cmLocalCalc,
      NewStatusKey('~F2~ Сформировать кассовый лист', kbF2, cmFormKassa,
      NewStatusKey('~F3~ Взаимозачеты', kbF3, cmItogBarter,
      NewStatusKey(Cancel, kbEsc, cmCancel,
      nil)))),
      NewStatusDef($E606, $E608,{38}
      NewStatusKey(Cancel, kbEsc, cmCancel,
      NewStatusKey('~Alt-F9~ Отчет', kbAltF9, cmReestrReport,
      nil)),


(*
      NewStatusDef($F011, $F015,{39}
      NewStatusKey('~Ins~ Печать', kbIns, cmPrintReestr,
      NewStatusKey('~F5~ Просмотр', kbF5, cmFullView,
      NewStatusKey('~Alt-F9~ Отчет', kbAltF9, cmReestrReport,
      NewStatusKey('~F2~ Период', kbF2, cmChangeDiapason,
      NewStatusKey(Cancel, kbEsc, cmCancel,
      nil)))),                       *)
      Nil)))))))))))))))))))))))))))))))))))))));

 P^.Defs^.Next^.{1}
          Next^.{2}
          Next^.{3}
          Next^.{4}
          Next^.{5}
          Next^.{6}
          Next^.{7}
          Next^.{8}
          Next^.{9}
          Next^.{10}
          Next^.{11}
          Next^.{12}
          Next^.{13}
          Next^.{14}
          Next^.{15}
          Next^.{16}
          Next^.{17}
          Next^.{18}
          Next^.{19}
          Next^.{20}
          Next^.{21}
          Next^.{22}
          Next^.{23}
          Next^.{24}
          Next^.{25}
          Next^.{26}
          Next^.{27}
          Next^.{28}
          Next^.{29}
          Next^.{30}
          Next^.{31}
          Next^.{32}
          Next^.{33}
          Next^.{34}
          Next^.{35}
          Next^.{36}
          Next:=
     NewStatusDef($E015, $E018,{4}
         NewStatusKey(Enter, kbNoKey, cmNoNe,
         NewStatusKey(Ok, kbCtrlEnter, CmOk,
         NewStatusKey(Cancel, kbEsc, cmCancel,
         NewStatusKey('~Alt-К~ Калькулятор', kbAltRusK, cmLocalCalc,
         NewStatusKey('~F4~ Через цены', kbF4, cmTest,
         NewStatusKey('', kbNoKey, CmClose,
      nil)))))),

      NewStatusDef($E611, $E615,{34}
         NewStatusKey('~'+#17+#217+'~ Просмотр', kbEnter, CmView,
         {NewStatusKey('~F9~ Раскладка', kbF9, CmAllSfB,}
         NewStatusKey('~Alt-F9~ Справка', kbAltF9, cmReestrReport,
         NewStatusKey('~Alt-К~ Кальк.', kbAltRusK, cmLocalCalc,
         NewStatusKey(Cancel, kbEsc, cmCancel,
         NewStatusKey('', kbNoKey, CmClose,
         nil))))),


         newStatusDef($F011, $F015,{39}
      NewStatusKey('~F5~ Открыть', kbF5, CmDeblock,
      NewStatusKey('~^F5~ Открыть все', kbCtrlF5, cmAllTCh,
      NewStatusKey('~Alt-F9~ Печать отчета', kbAltF9, cmReestrReport,
      NewStatusKey('', kbNoKey, CmClose,
      NewStatusKey('~Esc~ Закрыть', kbEsc, cmCancel,
      nil))))),
         NewStatusDef($F016, $F020,{40}
      NewStatusKey(Ok2, kbEnter, cmOk,
      NewStatusKey('', kbCtrlEnter, cmOk,
      NewStatusKey(Cancel2, kbEsc, cmCancel,
      nil))),
         NewStatusDef($F021, $F030,{41}
         NewStatusKey('~'+#17+#217+'~ Просмотр', kbEnter, CmDetal,
         NewStatusKey('~Alt-К~ Калькулятор', kbAltRusK, cmLocalCalc,
         NewStatusKey('~Alt-F9~ Справка', kbAltF9, cmReestrReport,
         NewStatusKey(Cancel, kbEsc, cmCancel,
         NewStatusKey('', kbNoKey, CmClose,
         nil))))),
    NewStatusDef($F035, $F045,{10}
         NewStatusKey(Vibor, kbNoKey, cmNone,
         NewStatusKey('', kbNoKey, CmClose,
         NewStatusKey(Ok, kbCtrlEnter, CmOk,
         NewStatusKey(Cancel, kbEsc, cmCancel,
         NewStatusKey('~Ctrl-Н~ Обн.', kbCtrlRusN, cmRefresh,
         NewStatusKey(Find, kbNoKey, CmNoNe,
         NewStatusKey('~Ctrl-Ш~ Шкала', kbCtrlRusSh, CmChangeShkala,
         NewStatusKey('~F7~ Серт',kbNoKey, CmNOne,
         NewStatusKey('', kbF10, CmMenu,
         nil))))))))),
    NewStatusDef($F046, $F055,{11}
         NewStatusKey('~Del~ Удал.', kbNoKey, cmNone,
         NewStatusKey(Enter, kbNoKey, cmNoNe,
         NewStatusKey(Edit, kbNoKey, cmNoNe,
         NewStatusKey(Cancel, kbEsc, cmCancel,
         NewStatusKey(Find, kbNoKey, CmNoNe,
         NewStatusKey('~Ctrl-Ш~ Шкала', kbCtrlRusSh, CmChangeShkala,
         NewStatusKey('', kbNoKey, CmClose,
         NewStatusKey('', kbCtrlEnter, CmOk,
         NewStatusKey('', kbF10, CmMenu,
         nil))))))))),
    NewStatusDef($F060, $F065,{20}
         NewStatusKey('~Ins~ Печ', kbIns, cmPrintReestr,
         NewStatusKey('~F5~ Просм', kbF5, cmFullview,
         NewStatusKey('~Alt-F9~ Справ', kbAltF9, cmReestrReport,
         NewStatusKey(Cancel, kbEsc, cmCancel,
         NewStatusKey('~Ctrl-Н~ Обнов', kbCtrlRusN, cmRefresh,
         NewStatusKey('', kbNoKey, CmClose,
         NewStatusKey('', kbF10, CmMenu,
         nil))))))),
    NewStatusDef($F066, $F068,{28}
      NewStatusKey('~Ins~ Печ', kbIns, cmPrintReestr,
      NewStatusKey('~F2~ Период', kbF2, cmChangeDiapason,
      NewStatusKey('~F5~ Просм', kbF5, cmFullView,
      NewStatusKey('~Alt-F9~ Отч', kbAltF9, cmReestrReport,
      NewStatusKey('~Ctr-Н~ Обнов', kbCtrlRusN, cmRefresh,
      NewStatusKey(Cancel, kbEsc, cmCancel,
      NewStatusKey('', kbNoKey, cmClose,
      NewStatusKey('', kbF10, cmMenu,
      nil)))))))),

    NewStatusDef($F070, $F075,{28}
      NewStatusKey('~F2~ Прих.', kbF2, CmPrihC,
      NewStatusKey('~F3~ Отгр.', kbF3, CmMrkC,
      NewStatusKey('~F4~ Возвр.', kbF4, CmReturnC,
      NewStatusKey('~F5~ Ревиз.', kbF5, CmRwz,
      NewStatusKey('~F6~ РП', kbF6, CmRP,
      NewStatusKey('~Alt-F9~ Печ.', kbAltF9, CmPrintReestr,
      NewStatusKey('~Esc~ Отмена', kbEsc, cmCancel,
      NewStatusKey('', kbAltRusK, CmLocalCalc,
      NewStatusKey('', kbNoKey, CmClose,
      nil))))))))),

    NewStatusDef($F076, $F080,{28}
      NewStatusKey('~Ins~ Печать', kbIns, CmPrintReestr,
      NewStatusKey('~F5~ Просмотр', kbF5, CmFullView,
      NewStatusKey('~Alt-F9~ Печать', kbAltF9, CmReestrReport,
      NewStatusKey('~Alt-К~ Калькулятор', kbAltRusK, CmLocalCalc,
      NewStatusKey('~Esc~ Отмена', kbEsc, cmCancel,
      NewStatusKey('', kbNoKey, CmClose,
      nil)))))),
    NewStatusDef($F081, $F085,{28}
      NewStatusKey('~Ins~ Печ.', kbIns, CmPrintReestr,
      NewStatusKey('~F5~ Просм.', kbF5, CmFullView,
      NewStatusKey('~Alt-Ы~ Опл.', kbAltRusIII, CmLocalInfo,
      NewStatusKey('~Alt-F9~ Справ.', kbAltF9, CmReestrReport,
      NewStatusKey('~Alt-К~ Кальк.', kbAltRusK, CmLocalCalc,
      NewStatusKey('~Esc~ Отмена', kbEsc, cmCancel,
      NewStatusKey('', kbNoKey, CmClose,
      nil))))))),
    NewStatusDef($F086, $F090,{34}
      NewStatusKey('~'+#17+#217+'~ Просмотр', kbEnter, CmView,
      NewStatusKey('~F3~ Рекв.', kbF3, CmAllSf,
      NewStatusKey('~Alt-F9~ Справка', kbAltF9, cmReestrReport,
      NewStatusKey('~Alt-К~ Кальк.', kbAltRusK, cmLocalCalc,
      NewStatusKey(Cancel, kbEsc, cmCancel,
      NewStatusKey('', kbNoKey, CmClose,
      nil)))))),
    NewStatusDef($F091, $F095,
      NewStatusKey('~Ins~ Печ', kbIns, cmPrintReestr,
      NewStatusKey('~Alt-F9~ Справ', kbAltF9, cmReestrReport,
      NewStatusKey(Cancel, kbEsc, cmCancel,
      NewStatusKey('~Alt-К~ Кальк.', kbAltRusK, CmLocalCalc,
      NewStatusKey('~Ctrl-Н~ Обнов', kbCtrlRusN, cmRefresh,
      NewStatusKey('', kbNoKey, CmClose,
      nil)))))),
    NewStatusDef($F096, $F097,
      NewStatusKey('~Alt-К~ Кальк.', kbAltRusK, CmLocalCalc,
      NewStatusKey(Cancel, kbEsc, cmCancel,
      nil)),
    NewStatusDef($F098, $F110,{17}
      NewStatusKey('~'+#17+#217+'~ Правка', kbEnter, cmEdit,
      NewStatusKey(Ok, kbCtrlEnter, CmOk,
      NewStatusKey('~Alt-К~ Калькулятор', kbAltRusK, cmLocalCalc,
      NewStatusKey(Cancel, kbEsc, cmCancel,
      nil)))),
      NewStatusDef($f120, $f130,{1}
      NewStatusKey(NewElement,kbNoKey,cmNoNe,
      NewStatusKey(Vibor, kbNoKey, cmNoNe,
      NewStatusKey(Edit, kbNoKey, cmNoNe,
      NewStatusKey(Cancel, kbEsc, cmCancel,
      NewStatusKey('~Ctrl-Н~ Обнов.', kbCtrlRusN, cmRefresh,
      NewStatusKey('', kbNoKey, CmClose,
      NewStatusKey('', kbCtrlEnter, CmOk,
      NewStatusKey(Menu, kbF10, CmMenu,
      nil)))))))),
      NewStatusDef($f131, $F140,{31}
         NewStatusKey('~Ins~ Выбор',kbNoKey,cmNoNe,
         NewStatusKey('~^Ins~ Выбрать все',kbNoKey,cmNoNe,
         NewStatusKey('~F9~ Запрос', kbF9, CmAllSfB,
         NewStatusKey('', kbCtrlRusN, cmRefresh,
         NewStatusKey(Cancel, kbEsc, cmCancel,
         NewStatusKey('', kbNoKey, CmClose,
         NewStatusKey(Menu, kbF10, cmMenu,
         nil))))))),
      NewStatusDef($f141, $f145,{33}
         NewStatusKey('~F9~ Запрос', kbF9, CmAllSfB,
         NewStatusKey(Cancel, kbEsc, cmCancel,
         NewStatusKey(Menu, kbF10, cmMenu,
         nil))),
      NewStatusDef($F146, $F150,{32}
         NewStatusKey('~Del~ Удал.',kbNoKey, cmNone,
         NewStatusKey('~^Del~ Удал.все', kbNoKey, cmNone,
         NewStatusKey('~F9~ Запрос', kbF9, CmAllSfB,
         NewStatusKey('', kbCtrlRusN, cmRefresh,
         NewStatusKey(Cancel, kbEsc, cmCancel,
         NewStatusKey('', kbNoKey, CmClose,
         NewStatusKey(Menu, kbF10, cmMenu,
         nil))))))),
      NewStatusDef($F155, $F180,{19}
         NewStatusKey('~Ins~ Новая', kbIns, cmPrintReestr,
         NewStatusKey('~Alt-F9~ Справ', kbAltF9, cmReestrReport,
         NewStatusKey('~F2~ Период', kbF2, cmChangeDiapason,
         NewStatusKey('~F5~ Печ', kbF2, CmReestrReport,
         NewStatusKey('~F7~ Фильтр', kbF7, cmParametr,
         NewStatusKey('~Ctrl-Н~ Обнов.', kbCtrlRusN, cmRefresh,
         NewStatusKey(Cancel, kbEsc, cmCancel,
         NewStatusKey('', kbF10, CmMenu,
         NewStatusKey('', kbNoKey, CmClose,
         nil))))))))),

      NewStatusDef($F181, $F199,{20}
         NewStatusKey('~Ins~ Печ', kbIns, cmPrintReestr,
         NewStatusKey('~F2~ Период', kbF2, cmChangeDiapason,
         NewStatusKey('~F5~ Просм', kbF5, cmFullview,
         NewStatusKey('~F7~ Параметры', kbF7, cmDocFiltr,
         NewStatusKey('~Alt-F9~ Справ', kbAltF9, cmReestrReport,
         NewStatusKey(Cancel, kbEsc, cmCancel,
         NewStatusKey('~^Н~ Обнов', kbCtrlRusN, cmRefresh,
         NewStatusKey('', kbNoKey, CmClose,
         NewStatusKey('', kbF10, CmMenu,
         nil))))))))),

      NewStatusDef($F200, $F205,{31}
         NewStatusKey('~Ins~ Выбор',kbNoKey,cmNoNe,
         NewStatusKey('~Alt-F9~ Справ', kbAltF9, cmReestrReport,
         NewStatusKey(Ok, kbCtrlEnter, CmOk,
         NewStatusKey(Cancel, kbEsc, cmCancel,
         NewStatusKey('', kbNoKey, CmClose,
         nil))))),

      NewStatusDef($F206, $F210,{31}
         NewStatusKey('~F4~ Правка',kbNoKey,cmNoNe,
         NewStatusKey('~Del~ Уладить',kbNoKey,cmNoNe,
         NewStatusKey('~Alt-F9~ Справ', kbAltF9, cmReestrReport,
         NewStatusKey(Ok, kbCtrlEnter, CmOk,
         NewStatusKey(Cancel, kbEsc, cmCancel,
         NewStatusKey('', kbNoKey, CmClose,
         nil)))))),


    NewStatusDef($C200, $C205,{19}
         NewStatusKey('~Ins~ Печ', kbIns, cmPrintReestr,
         NewStatusKey('', kbGrayPlus, cmAddKassa,
         NewStatusKey('~-~ Оплата', kbGrayMinus, cmOutKassa,
         NewStatusKey('~F4~ Свойства', kbF4, cmProperties,
         NewStatusKey('~F5~ Просм', kbF5, cmFullview,
         NewStatusKey('~Alt-F9~ Справ', kbAltF9, cmReestrReport,
         NewStatusKey('~F2~ Период', kbF2, cmChangeDiapason,
         NewStatusKey('', kbCtrlRusN, cmRefresh,
         NewStatusKey(Cancel, kbEsc, cmCancel,
         NewStatusKey('', kbF10, CmMenu,
         NewStatusKey('', kbNoKey, CmClose,
         nil))))))))))),
    NewStatusDef($1000, $1010,{8}
      NewStatusKey('Пожалуйста ничего не нажимайте!!!', kbEsc, cmClose,
      NewStatusKey('', kbEnter, cmNone,Nil)),
           NewStatusDef($1020, $1030,{4}
      NewStatusKey(Enter, kbNoKey, cmNoNe,
      NewStatusKey(Ok, kbCtrlEnter, CmOk,
      NewStatusKey(Cancel, kbEsc, cmCancel,
      NewStatusKey('~F4~ Дополнительно', kbF4, cmDopOper,
      NewStatusKey('', kbF10, CmMenu,
         nil))))),

         Nil)))))))))))))))))))))))))));

{     NewStatusKey(Enter+'', kbF1, CmPrihC,
      NewStatusKey('~F2~ ПрС', kbF2, CmPrihS,
      NewStatusKey('~F3~ ОтгК', kbF3, CmMrkC,
      NewStatusKey('~F4~ ОтгС', kbF4, CmMrkS,
      NewStatusKey('~F5~ ВзК', kbF5, CmReturnC,
      NewStatusKey('~F6~ ВзС', kbF6, CmReturnS,
      NewStatusKey('~F7~ Прц', kbF7, CmPrz,
      NewStatusKey('~F8~ Рв', kbF8, CmRwz,
      NewStatusKey('~F9~ РП', kbF9, CmRP,
      NewStatusKey('~Alt-F9~ Печ', kbAltF9, CmPrintReestr,
      NewStatusKey('~Esc~ Отм', kbEsc, cmCancel,
      NewStatusKey('', kbAltRusK, CmLocalCalc,
      NewStatusKey('', kbNoKey, CmClose,
      nil))))))))))))),
         Nil))))))));}

  RezFile.Put(P, 'StatusLine');
  Dispose(P, Done);
end;

begin
  RezStream := New(PProtectedStream, Init('sklad.rez', stCreate, 4096));
  RezFile.Init(RezStream);
  RegisterObjects;
  RegisterViews;
  RegisterMenus;
  CreateStatusLine;
  RezFile.Done;
end.