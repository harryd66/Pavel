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
      NewStatusKey('~Ctrl-�~ �����.', kbCtrlRusN, cmRefresh,
      NewStatusKey('~F6~ ������.', kbNoKey, CmClose,
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
      NewStatusKey('~'+#17+#217+'~ �롮�', kbNoKey, cmNoNe,
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
         NewStatusKey('~Del~ ����.', kbNoKey, cmNone,
         NewStatusKey('~^Del~ ����.��', kbNoKey, cmNone,
         NewStatusKey('', kbNoKey, CmClose,
         NewStatusKey(Ok, kbCtrlEnter, CmOk,
         NewStatusKey(Cancel, kbEsc, cmCancel,
         NewStatusKey('', kbF10, CmMenu,
         nil)))))),
        NewStatusDef($E043, $E045,{6}
         NewStatusKey('~Ins~ �롮�',kbNoKey,cmNoNe,
         NewStatusKey('~^Ins~ ����� ��',kbNoKey,cmNoNe,
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
         NewStatusKey('~Esc~ �������', kbEsc, cmClose,
         NewStatusKey('', kbEnter, cmNone,Nil)),
        NewStatusDef($E099, $E105,{9}
         NewStatusKey('~Esc~ �������', kbEsc, cmClose,
         NewStatusKey('~Alt-F9~ ����� �ࠢ��', kbAltF9, cmReestrReport,
         NewStatusKey('', kbEnter, cmNone,Nil))),
    NewStatusDef($E140, $E145,{10}
         NewStatusKey(Vibor, kbNoKey, cmNone,
         NewStatusKey('', kbNoKey, CmClose,
         NewStatusKey(Ok, kbCtrlEnter, CmOk,
         NewStatusKey(Cancel, kbEsc, cmCancel,
         NewStatusKey('~Ctrl-�~ �����.', kbCtrlRusN, cmRefresh,
         NewStatusKey(Find, kbNoKey, CmNoNe,
         NewStatusKey('', kbF10, CmMenu,
         nil))))))),
    NewStatusDef($E145, $E155,{11}
         NewStatusKey('~Del~ ����.', kbNoKey, cmNone,
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
         NewStatusKey('~F2~ ����.��室��', kbF2, CmChangeDoc,
         NewStatusKey(Ok, kbCtrlEnter, CmOk,
         NewStatusKey(Cancel, kbEsc, cmCancel,
         NewStatusKey('', kbNoKey, CmClose,
         NewStatusKey('', kbF10, CmMenu,
         nil)))))),
    NewStatusDef($E159, $E159,{13}
         NewStatusKey('~Del~ ����.', kbNoKey, cmNoNe,
         NewStatusKey('~F2~ ����.��室��', kbF2, CmChangeDoc,
         NewStatusKey(Edit, kbNoKey, cmNoNe,
         NewStatusKey(Ok, kbCtrlEnter, CmOk,
         NewStatusKey(Cancel, kbEsc, cmCancel,
         NewStatusKey('', kbNoKey, CmClose,
         NewStatusKey('', kbF10, CmMenu,
         nil))))))),
        NewStatusDef($E160, $E165,{14}
         NewStatusKey('~Alt~+~'+'0..8~ - �������� � N-� ᯨ᮪', kbNoKey, cmNone,
         NewStatusKey(Ok, kbCtrlEnter, CmOk,
         NewStatusKey(Cancel, kbEsc, cmCancel,
         NewStatusKey('', kbNoKey, CmClose,
         NewStatusKey(Find, kbNoKey, CmNoNe,
         nil))))),
    NewStatusDef($E166, $E170,{15}
         NewStatusKey('~Del~ ����.', kbNoKey, cmNone,
         NewStatusKey(NewElement,kbNoKey,cmNoNe,
         NewStatusKey(Vibor, kbNoKey, cmNoNe,
         NewStatusKey(Edit, kbNoKey, cmNoNe,
         NewStatusKey(Cancel, kbEsc, cmCancel,
         NewStatusKey('~Ctrl-�~ �����.', kbCtrlRusN, cmRefresh,
         NewStatusKey(Find, kbNoKey, CmNoNe,
         NewStatusKey('', kbCtrlEnter, CmOk,
         NewStatusKey('', kbF10, CmMenu,
         nil))))))))),
    NewStatusDef($E171, $E175,{16}
         NewStatusKey('~Del~ ����.', kbNoKey, cmNone,
         NewStatusKey(NewElement,kbNoKey,cmNoNe,
         NewStatusKey(Vibor, kbNoKey, cmNoNe,
         NewStatusKey(Edit, kbNoKey, cmNoNe,
         NewStatusKey('~F5~ ���.', kbF5, cmPrintReestr,
         NewStatusKey(Cancel, kbEsc, cmCancel,
         NewStatusKey('~Ctrl-�~ �����.', kbCtrlRusN, cmRefresh,
         NewStatusKey('', kbNoKey, CmClose,
         NewStatusKey('', kbCtrlEnter, CmOk,
         nil))))))))),
        NewStatusDef($E190, $E195,{17}
         NewStatusKey(Enter, kbNoKey, cmNoNe,
         NewStatusKey(Ok, kbCtrlEnter, CmOk,
         NewStatusKey(Cancel, kbEsc, cmCancel,
         NewStatusKey('~Alt-�~ ��������', kbAltRusK, cmLocalCalc,
         nil)))),
        NewStatusDef($E196, $E199,{18}
         NewStatusKey(Enter, kbNoKey, cmNoNe,
         NewStatusKey(Ok, kbCtrlEnter, CmOk,
         NewStatusKey(Cancel, kbEsc, cmCancel,
         NewStatusKey('~Alt-�~ ����.', kbAltRusK, cmLocalCalc,
         NewStatusKey('~+~ ����.', kbGrayPlus, cmLocalSkidka,
         NewStatusKey('~-~ ��業.', kbGrayMinus, cmLocalNazenka,
         nil)))))),
    NewStatusDef($E200, $E205,{19}
         NewStatusKey('~Ins~ ���', kbIns, cmPrintReestr,
         NewStatusKey('~'+#17+#217+'~ ���', kbEnter, cmOplata,
         NewStatusKey('~Alt-�~ ����', kbAltRusIII, CmLocalInfo,
         NewStatusKey('~^F7~ ���',kbCtrlF7, CmDeblock,
         NewStatusKey('~F5~ ���', kbF5, cmFullview,
         NewStatusKey('~Alt-F9~ ��ࠢ', kbAltF9, cmReestrReport,
         NewStatusKey('~F2~ ��ਮ�', kbF2, cmChangeDiapason,
         NewStatusKey(Cancel, kbEsc, cmCancel,
         NewStatusKey('', kbF10, CmMenu,
         NewStatusKey('', kbNoKey, CmClose,
         nil)))))))))),
    NewStatusDef($E210, $E220,{20}
         NewStatusKey('~'+#17+#217+'~ ���४��', kbEnter, cmEdit,
         NewStatusKey('~Ins~ ���', kbIns, cmPrintReestr,
         NewStatusKey('~F5~ ���', kbF5, cmFullview,
         NewStatusKey('~Alt-F9~ ��ࠢ', kbAltF9, cmReestrReport,
         NewStatusKey(Cancel, kbEsc, cmCancel,
         NewStatusKey('~Ctrl-�~ �����', kbCtrlRusN, cmRefresh,
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
      NewStatusKey('~Esc~ �������', kbEsc, cmClose,
      Nil),
      NewStatusDef($E306, $E310,{24}
      NewStatusKey('~'+#17+#217+'~ ?', kbEnter, cmEditPosition,
      NewStatusKey(Ok, kbCtrlEnter, CmOk,
      NewStatusKey(Cancel, kbEsc, cmCancel,
      NewStatusKey('~Alt-�~ ��������', kbAltRusK, cmLocalCalc,
      nil)))),
      NewStatusDef($E315, $E317,{25}
      NewStatusKey('~F5~ ��ᬮ��', kbF5, cmFullview,
      NewStatusKey('~Alt-F9~ ��ࠢ��', kbAltF9, cmReestrReport,
      NewStatusKey(Cancel, kbEsc, cmCancel,
      NewStatusKey(Find, kbNoKey, CmNoNe,
      NewStatusKey('', kbNoKey, CmClose,
      NewStatusKey('', kbF10, CmMenu,
      NewStatusKey('', kbCtrlEnter, CmOk,
      nil))))))),
      NewStatusDef($E555, $E560,{26}
      NewStatusKey(Cancel, kbEsc, cmCancel,
      NewStatusKey('~Alt-�~ ��������', kbAltRusK, cmLocalCalc,
      nil)),
      NewStatusDef($E560, $E565,{27}
      NewStatusKey('~F10~ ������� ⥪�騩 �ணࠬ��� ����', kbF10, cmYes,
      NewStatusKey(Cancel, kbEsc, cmCancel,
      nil)),
      NewStatusDef($E570, $E580,{28}
      NewStatusKey('~Ins~ ���', kbIns, cmPrintReestr,
      NewStatusKey('~F5~ ���', kbF5, cmFullView,
      NewStatusKey('~F2~ ��ਮ�', kbF2, cmChangeDiapason,
      NewStatusKey('~Alt-F9~ ����', kbAltF9, cmReestrReport,
      NewStatusKey('~Alt-�~ ����', kbAltRusIII, CmLocalInfo,
      NewStatusKey('~!~ �����', Ord('!'), cmAnalysFromPeriod,
      NewStatusKey(Cancel, kbEsc, cmCancel,
      NewStatusKey('', kbNoKey, cmClose,
      NewStatusKey('', kbF10, cmMenu,
      nil))))))))),
         NewStatusDef($E616, $E625,{29}
         NewStatusKey('~Ins~ ���', kbIns, cmPrintReestr,
         NewStatusKey('~F5~ ���', kbF5, cmFullView,
         NewStatusKey('~Alt-F9~ ����', kbAltF9, cmReestrReport,
         NewStatusKey('~Alt-�~ ����', kbAltRusIII, CmLocalInfo,
         NewStatusKey('~!~ �����', Ord('!'), cmAnalysFromPeriod,
         NewStatusKey(Cancel, kbEsc, cmCancel,
         nil)))))),
        NewStatusDef($E581, $E585,{30}
         NewStatusKey(Enter, kbNoKey, cmNoNe,
         NewStatusKey('', kbNoKey, CmClose,
         NewStatusKey('~F2~ ��ਮ�', kbF2, cmChangeDiapason,
         NewStatusKey(Cancel, kbEsc, cmCancel,
         NewStatusKey('~F10~ ����', kbF10, cmMenu,
         nil))))),
      NewStatusDef($E585, $E595,{31}
         NewStatusKey('~Ins~ �롮�',kbNoKey,cmNoNe,
         NewStatusKey('~^Ins~ ����� ��',kbNoKey,cmNoNe,
         NewStatusKey('~^'+#17+#217+'~ �����', kbCtrlEnter, CmCalcStat,
         NewStatusKey('~F8~ �������', kbF8, CmAllSpis,
         NewStatusKey('~F9~ �����', kbF9, CmAllSfB,
         NewStatusKey('', kbCtrlRusN, cmRefresh,
         NewStatusKey(Cancel, kbEsc, cmCancel,
         NewStatusKey('', kbNoKey, CmClose,
         NewStatusKey(Menu, kbF10, cmMenu,
         nil))))))))),
      NewStatusDef($E596, $E600,{32}
         NewStatusKey('~Del~ ����.',kbNoKey, cmNone,
         NewStatusKey('~^Del~ ����.��', kbNoKey, cmNone,
         NewStatusKey('~^'+#17+#217+'~ �����', kbCtrlEnter, CmCalcStat,
         NewStatusKey('~F9~ �����', kbF9, CmAllSfB,
         NewStatusKey('', kbCtrlRusN, cmRefresh,
         NewStatusKey(Cancel, kbEsc, cmCancel,
         NewStatusKey('', kbNoKey, CmClose,
         NewStatusKey(Menu, kbF10, cmMenu,
         nil)))))))),
      NewStatusDef($E601, $E605,{33}
         NewStatusKey('~^'+#17+#217+'~ �����', kbCtrlEnter, CmCalcStat,
         NewStatusKey(Cancel, kbEsc, cmCancel,
         NewStatusKey(Menu, kbF10, cmMenu,
         nil))),

      NewStatusDef($F000, $F001,{35}
         NewStatusKey('~^F7~ ����', kbCtrlF7, cmFind,
         NewStatusKey('~Shift-F7~ ������� ����',kbShiftF7, cmNextFind,
         NewStatusKey('~^F9~ ����� ����', kbCtrlF9, cmPrintScreen,
         NewStatusKey('~Esc~ �������', kbEsc, cmClose,
         NewStatusKey('', kbF10, cmMenu,
         nil))))),
      NewStatusDef($F003, $F005,{36}
         NewStatusKey('~^F7~ ����', kbCtrlF7, cmFind,
         NewStatusKey('~Shift-F7~ ������� ����',kbShiftF7, cmNextFind,
         NewStatusKey('~Esc~ �������', kbEsc, cmClose,
         NewStatusKey(Menu, kbF10, cmMenu,
         nil)))),
      NewStatusDef($F006, $F010,{37}
      NewStatusKey('~Alt-�~ ��������', kbAltRusK, cmLocalCalc,
      NewStatusKey('~F2~ ��ନ஢��� ���ᮢ� ����', kbF2, cmFormKassa,
      NewStatusKey('~F3~ �����������', kbF3, cmItogBarter,
      NewStatusKey(Cancel, kbEsc, cmCancel,
      nil)))),
      NewStatusDef($E606, $E608,{38}
      NewStatusKey(Cancel, kbEsc, cmCancel,
      NewStatusKey('~Alt-F9~ ����', kbAltF9, cmReestrReport,
      nil)),


(*
      NewStatusDef($F011, $F015,{39}
      NewStatusKey('~Ins~ �����', kbIns, cmPrintReestr,
      NewStatusKey('~F5~ ��ᬮ��', kbF5, cmFullView,
      NewStatusKey('~Alt-F9~ ����', kbAltF9, cmReestrReport,
      NewStatusKey('~F2~ ��ਮ�', kbF2, cmChangeDiapason,
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
         NewStatusKey('~Alt-�~ ��������', kbAltRusK, cmLocalCalc,
         NewStatusKey('~F4~ ��१ 業�', kbF4, cmTest,
         NewStatusKey('', kbNoKey, CmClose,
      nil)))))),

      NewStatusDef($E611, $E615,{34}
         NewStatusKey('~'+#17+#217+'~ ��ᬮ��', kbEnter, CmView,
         {NewStatusKey('~F9~ ��᪫����', kbF9, CmAllSfB,}
         NewStatusKey('~Alt-F9~ ��ࠢ��', kbAltF9, cmReestrReport,
         NewStatusKey('~Alt-�~ ����.', kbAltRusK, cmLocalCalc,
         NewStatusKey(Cancel, kbEsc, cmCancel,
         NewStatusKey('', kbNoKey, CmClose,
         nil))))),


         newStatusDef($F011, $F015,{39}
      NewStatusKey('~F5~ ������', kbF5, CmDeblock,
      NewStatusKey('~^F5~ ������ ��', kbCtrlF5, cmAllTCh,
      NewStatusKey('~Alt-F9~ ����� ����', kbAltF9, cmReestrReport,
      NewStatusKey('', kbNoKey, CmClose,
      NewStatusKey('~Esc~ �������', kbEsc, cmCancel,
      nil))))),
         NewStatusDef($F016, $F020,{40}
      NewStatusKey(Ok2, kbEnter, cmOk,
      NewStatusKey('', kbCtrlEnter, cmOk,
      NewStatusKey(Cancel2, kbEsc, cmCancel,
      nil))),
         NewStatusDef($F021, $F030,{41}
         NewStatusKey('~'+#17+#217+'~ ��ᬮ��', kbEnter, CmDetal,
         NewStatusKey('~Alt-�~ ��������', kbAltRusK, cmLocalCalc,
         NewStatusKey('~Alt-F9~ ��ࠢ��', kbAltF9, cmReestrReport,
         NewStatusKey(Cancel, kbEsc, cmCancel,
         NewStatusKey('', kbNoKey, CmClose,
         nil))))),
    NewStatusDef($F035, $F045,{10}
         NewStatusKey(Vibor, kbNoKey, cmNone,
         NewStatusKey('', kbNoKey, CmClose,
         NewStatusKey(Ok, kbCtrlEnter, CmOk,
         NewStatusKey(Cancel, kbEsc, cmCancel,
         NewStatusKey('~Ctrl-�~ ���.', kbCtrlRusN, cmRefresh,
         NewStatusKey(Find, kbNoKey, CmNoNe,
         NewStatusKey('~Ctrl-�~ �����', kbCtrlRusSh, CmChangeShkala,
         NewStatusKey('~F7~ ����',kbNoKey, CmNOne,
         NewStatusKey('', kbF10, CmMenu,
         nil))))))))),
    NewStatusDef($F046, $F055,{11}
         NewStatusKey('~Del~ ����.', kbNoKey, cmNone,
         NewStatusKey(Enter, kbNoKey, cmNoNe,
         NewStatusKey(Edit, kbNoKey, cmNoNe,
         NewStatusKey(Cancel, kbEsc, cmCancel,
         NewStatusKey(Find, kbNoKey, CmNoNe,
         NewStatusKey('~Ctrl-�~ �����', kbCtrlRusSh, CmChangeShkala,
         NewStatusKey('', kbNoKey, CmClose,
         NewStatusKey('', kbCtrlEnter, CmOk,
         NewStatusKey('', kbF10, CmMenu,
         nil))))))))),
    NewStatusDef($F060, $F065,{20}
         NewStatusKey('~Ins~ ���', kbIns, cmPrintReestr,
         NewStatusKey('~F5~ ���', kbF5, cmFullview,
         NewStatusKey('~Alt-F9~ ��ࠢ', kbAltF9, cmReestrReport,
         NewStatusKey(Cancel, kbEsc, cmCancel,
         NewStatusKey('~Ctrl-�~ �����', kbCtrlRusN, cmRefresh,
         NewStatusKey('', kbNoKey, CmClose,
         NewStatusKey('', kbF10, CmMenu,
         nil))))))),
    NewStatusDef($F066, $F068,{28}
      NewStatusKey('~Ins~ ���', kbIns, cmPrintReestr,
      NewStatusKey('~F2~ ��ਮ�', kbF2, cmChangeDiapason,
      NewStatusKey('~F5~ ���', kbF5, cmFullView,
      NewStatusKey('~Alt-F9~ ���', kbAltF9, cmReestrReport,
      NewStatusKey('~Ctr-�~ �����', kbCtrlRusN, cmRefresh,
      NewStatusKey(Cancel, kbEsc, cmCancel,
      NewStatusKey('', kbNoKey, cmClose,
      NewStatusKey('', kbF10, cmMenu,
      nil)))))))),

    NewStatusDef($F070, $F075,{28}
      NewStatusKey('~F2~ ���.', kbF2, CmPrihC,
      NewStatusKey('~F3~ ���.', kbF3, CmMrkC,
      NewStatusKey('~F4~ �����.', kbF4, CmReturnC,
      NewStatusKey('~F5~ �����.', kbF5, CmRwz,
      NewStatusKey('~F6~ ��', kbF6, CmRP,
      NewStatusKey('~Alt-F9~ ���.', kbAltF9, CmPrintReestr,
      NewStatusKey('~Esc~ �⬥��', kbEsc, cmCancel,
      NewStatusKey('', kbAltRusK, CmLocalCalc,
      NewStatusKey('', kbNoKey, CmClose,
      nil))))))))),

    NewStatusDef($F076, $F080,{28}
      NewStatusKey('~Ins~ �����', kbIns, CmPrintReestr,
      NewStatusKey('~F5~ ��ᬮ��', kbF5, CmFullView,
      NewStatusKey('~Alt-F9~ �����', kbAltF9, CmReestrReport,
      NewStatusKey('~Alt-�~ ��������', kbAltRusK, CmLocalCalc,
      NewStatusKey('~Esc~ �⬥��', kbEsc, cmCancel,
      NewStatusKey('', kbNoKey, CmClose,
      nil)))))),
    NewStatusDef($F081, $F085,{28}
      NewStatusKey('~Ins~ ���.', kbIns, CmPrintReestr,
      NewStatusKey('~F5~ ���.', kbF5, CmFullView,
      NewStatusKey('~Alt-�~ ���.', kbAltRusIII, CmLocalInfo,
      NewStatusKey('~Alt-F9~ ��ࠢ.', kbAltF9, CmReestrReport,
      NewStatusKey('~Alt-�~ ����.', kbAltRusK, CmLocalCalc,
      NewStatusKey('~Esc~ �⬥��', kbEsc, cmCancel,
      NewStatusKey('', kbNoKey, CmClose,
      nil))))))),
    NewStatusDef($F086, $F090,{34}
      NewStatusKey('~'+#17+#217+'~ ��ᬮ��', kbEnter, CmView,
      NewStatusKey('~F3~ ����.', kbF3, CmAllSf,
      NewStatusKey('~Alt-F9~ ��ࠢ��', kbAltF9, cmReestrReport,
      NewStatusKey('~Alt-�~ ����.', kbAltRusK, cmLocalCalc,
      NewStatusKey(Cancel, kbEsc, cmCancel,
      NewStatusKey('', kbNoKey, CmClose,
      nil)))))),
    NewStatusDef($F091, $F095,
      NewStatusKey('~Ins~ ���', kbIns, cmPrintReestr,
      NewStatusKey('~Alt-F9~ ��ࠢ', kbAltF9, cmReestrReport,
      NewStatusKey(Cancel, kbEsc, cmCancel,
      NewStatusKey('~Alt-�~ ����.', kbAltRusK, CmLocalCalc,
      NewStatusKey('~Ctrl-�~ �����', kbCtrlRusN, cmRefresh,
      NewStatusKey('', kbNoKey, CmClose,
      nil)))))),
    NewStatusDef($F096, $F097,
      NewStatusKey('~Alt-�~ ����.', kbAltRusK, CmLocalCalc,
      NewStatusKey(Cancel, kbEsc, cmCancel,
      nil)),
    NewStatusDef($F098, $F110,{17}
      NewStatusKey('~'+#17+#217+'~ �ࠢ��', kbEnter, cmEdit,
      NewStatusKey(Ok, kbCtrlEnter, CmOk,
      NewStatusKey('~Alt-�~ ��������', kbAltRusK, cmLocalCalc,
      NewStatusKey(Cancel, kbEsc, cmCancel,
      nil)))),
      NewStatusDef($f120, $f130,{1}
      NewStatusKey(NewElement,kbNoKey,cmNoNe,
      NewStatusKey(Vibor, kbNoKey, cmNoNe,
      NewStatusKey(Edit, kbNoKey, cmNoNe,
      NewStatusKey(Cancel, kbEsc, cmCancel,
      NewStatusKey('~Ctrl-�~ �����.', kbCtrlRusN, cmRefresh,
      NewStatusKey('', kbNoKey, CmClose,
      NewStatusKey('', kbCtrlEnter, CmOk,
      NewStatusKey(Menu, kbF10, CmMenu,
      nil)))))))),
      NewStatusDef($f131, $F140,{31}
         NewStatusKey('~Ins~ �롮�',kbNoKey,cmNoNe,
         NewStatusKey('~^Ins~ ����� ��',kbNoKey,cmNoNe,
         NewStatusKey('~F9~ �����', kbF9, CmAllSfB,
         NewStatusKey('', kbCtrlRusN, cmRefresh,
         NewStatusKey(Cancel, kbEsc, cmCancel,
         NewStatusKey('', kbNoKey, CmClose,
         NewStatusKey(Menu, kbF10, cmMenu,
         nil))))))),
      NewStatusDef($f141, $f145,{33}
         NewStatusKey('~F9~ �����', kbF9, CmAllSfB,
         NewStatusKey(Cancel, kbEsc, cmCancel,
         NewStatusKey(Menu, kbF10, cmMenu,
         nil))),
      NewStatusDef($F146, $F150,{32}
         NewStatusKey('~Del~ ����.',kbNoKey, cmNone,
         NewStatusKey('~^Del~ ����.��', kbNoKey, cmNone,
         NewStatusKey('~F9~ �����', kbF9, CmAllSfB,
         NewStatusKey('', kbCtrlRusN, cmRefresh,
         NewStatusKey(Cancel, kbEsc, cmCancel,
         NewStatusKey('', kbNoKey, CmClose,
         NewStatusKey(Menu, kbF10, cmMenu,
         nil))))))),
      NewStatusDef($F155, $F180,{19}
         NewStatusKey('~Ins~ �����', kbIns, cmPrintReestr,
         NewStatusKey('~Alt-F9~ ��ࠢ', kbAltF9, cmReestrReport,
         NewStatusKey('~F2~ ��ਮ�', kbF2, cmChangeDiapason,
         NewStatusKey('~F5~ ���', kbF2, CmReestrReport,
         NewStatusKey('~F7~ ������', kbF7, cmParametr,
         NewStatusKey('~Ctrl-�~ �����.', kbCtrlRusN, cmRefresh,
         NewStatusKey(Cancel, kbEsc, cmCancel,
         NewStatusKey('', kbF10, CmMenu,
         NewStatusKey('', kbNoKey, CmClose,
         nil))))))))),

      NewStatusDef($F181, $F199,{20}
         NewStatusKey('~Ins~ ���', kbIns, cmPrintReestr,
         NewStatusKey('~F2~ ��ਮ�', kbF2, cmChangeDiapason,
         NewStatusKey('~F5~ ���', kbF5, cmFullview,
         NewStatusKey('~F7~ ��ࠬ����', kbF7, cmDocFiltr,
         NewStatusKey('~Alt-F9~ ��ࠢ', kbAltF9, cmReestrReport,
         NewStatusKey(Cancel, kbEsc, cmCancel,
         NewStatusKey('~^�~ �����', kbCtrlRusN, cmRefresh,
         NewStatusKey('', kbNoKey, CmClose,
         NewStatusKey('', kbF10, CmMenu,
         nil))))))))),

      NewStatusDef($F200, $F205,{31}
         NewStatusKey('~Ins~ �롮�',kbNoKey,cmNoNe,
         NewStatusKey('~Alt-F9~ ��ࠢ', kbAltF9, cmReestrReport,
         NewStatusKey(Ok, kbCtrlEnter, CmOk,
         NewStatusKey(Cancel, kbEsc, cmCancel,
         NewStatusKey('', kbNoKey, CmClose,
         nil))))),

      NewStatusDef($F206, $F210,{31}
         NewStatusKey('~F4~ �ࠢ��',kbNoKey,cmNoNe,
         NewStatusKey('~Del~ �������',kbNoKey,cmNoNe,
         NewStatusKey('~Alt-F9~ ��ࠢ', kbAltF9, cmReestrReport,
         NewStatusKey(Ok, kbCtrlEnter, CmOk,
         NewStatusKey(Cancel, kbEsc, cmCancel,
         NewStatusKey('', kbNoKey, CmClose,
         nil)))))),


    NewStatusDef($C200, $C205,{19}
         NewStatusKey('~Ins~ ���', kbIns, cmPrintReestr,
         NewStatusKey('', kbGrayPlus, cmAddKassa,
         NewStatusKey('~-~ �����', kbGrayMinus, cmOutKassa,
         NewStatusKey('~F4~ �����⢠', kbF4, cmProperties,
         NewStatusKey('~F5~ ���', kbF5, cmFullview,
         NewStatusKey('~Alt-F9~ ��ࠢ', kbAltF9, cmReestrReport,
         NewStatusKey('~F2~ ��ਮ�', kbF2, cmChangeDiapason,
         NewStatusKey('', kbCtrlRusN, cmRefresh,
         NewStatusKey(Cancel, kbEsc, cmCancel,
         NewStatusKey('', kbF10, CmMenu,
         NewStatusKey('', kbNoKey, CmClose,
         nil))))))))))),
    NewStatusDef($1000, $1010,{8}
      NewStatusKey('�������� ��祣� �� ��������!!!', kbEsc, cmClose,
      NewStatusKey('', kbEnter, cmNone,Nil)),
           NewStatusDef($1020, $1030,{4}
      NewStatusKey(Enter, kbNoKey, cmNoNe,
      NewStatusKey(Ok, kbCtrlEnter, CmOk,
      NewStatusKey(Cancel, kbEsc, cmCancel,
      NewStatusKey('~F4~ �������⥫쭮', kbF4, cmDopOper,
      NewStatusKey('', kbF10, CmMenu,
         nil))))),

         Nil)))))))))))))))))))))))))));

{     NewStatusKey(Enter+'', kbF1, CmPrihC,
      NewStatusKey('~F2~ ���', kbF2, CmPrihS,
      NewStatusKey('~F3~ �⣊', kbF3, CmMrkC,
      NewStatusKey('~F4~ �⣑', kbF4, CmMrkS,
      NewStatusKey('~F5~ ���', kbF5, CmReturnC,
      NewStatusKey('~F6~ ���', kbF6, CmReturnS,
      NewStatusKey('~F7~ ���', kbF7, CmPrz,
      NewStatusKey('~F8~ ��', kbF8, CmRwz,
      NewStatusKey('~F9~ ��', kbF9, CmRP,
      NewStatusKey('~Alt-F9~ ���', kbAltF9, CmPrintReestr,
      NewStatusKey('~Esc~ ��', kbEsc, cmCancel,
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