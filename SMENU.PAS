procedure TEditorApp.InitMenuBar;
var
  R: TRect;
  s : ArtikulStr;
begin
  GetExtent(R);
  s:=' ';
  R.B.Y := R.A.Y + 1;
  MenuBar := New(PMenuBar, Init(R, NewMenu(
      NewSubMenu('На склад', $A001, NewMenu(
      NewItem('Сформировать ~п~риход', 'Ctrl+П',KbCtrlRusP , cmPrihod, hcDosShell,
      NewItem('Сформировать ~в~озврат', 'Ctrl+В',KbCtrlRusW , cmVozwrat, hcDosShell,
      NewItem('Поступление товара на ~с~клад','',KbCtrlRusC, cmInputToSklad, hcDosShell,
      nil)))),
      NewItem('Со склад~а~','',kbNokey,cmSupermarket,$A015,
         NewItem('Долги','',kbNokey,cmDolg,$A055,

      NewSubMenu('~?~', $A070, NewMenu(
      NewSubMenu('Движение ~т~овара',hcDosShell,NewMenu(
{        NewItem('~В~ыборка товара', '',KbNoKey, cmTovarStat, hcDosShell,}
         NewItem('~А~нализ продаж', '',KbNoKey, cmMArketStat, hcDosShell,
         Nil)),
         NewItem('~П~ерсонально', 'Alt-F7',KbAltF7, cmStat, hcDosShell,
         NewItem('~В~ыборка', 'Alt-F8',KbAltF8, cmClientStat, hcDosShell,
         NewItem('~О~плата консигнации', 'Alt-F2',KbAltF2, cmInfoDebit, hcDosShell,
         NewItem('~В~озвраты', 'Alt-F3',KbAltF3, cmInfoReturn, hcDosShell,
      nil)))))),


      NewSubMenu('Док~у~мент', $A005, NewMenu(
      NewItem('Р~е~естр документов отгрузки', 'F2',KbF2, cmReestrDoc, hcDosShell,
      NewItem('П~р~осмотреть', 'F3',KbF3, cmViewDoc, hcDosShell,
      NewItem('~К~орректировать', 'F6',KbF6, cmEditDoc, hcDosShell,
      NewItem('~П~ечатать', 'F9',KbF9, cmPrintDoc, hcDosShell,
      NewLine(
      NewItem('Наличие на ~с~кладе', 'Shift-F1',KbShiftF1 , cmPrintSklad, hcDosShell,
      NewItem('Прайс-~л~ист', 'Shift-F2',KbShiftF2 , cmPrintPreisList, hcDosShell,
      NewItem('Бланк реви~з~ии на складе', 'Shift-F3',KbShiftF3 , cmPrintRewizia, hcDosShell,
      NewItem('Контрольный кассов~ы~й лист', 'Shift-F4',KbShiftF4 , cmPrintKassa, hcDosShell,
      NewItem('~В~едомость "ОСТАТКИ-ОТГРУЗКА"', 'Shift-F5',KbShiftF5 , cmOstatki_Market, hcDosShell,
      NewItem('Оплата конси~г~нации', 'Shift-F6',KbShiftF6 , cmViewOplataRealiz, hcDosShell,
      NewItem('Долги дебиторо~в~', 'Shift-F7',KbShiftF7 , cmPrintDebitDolg, hcDosShell,
      NewItem('Проверка сертификатов', 'Shift-F8',KbShiftF8 , cmFindDSertif, hcDosShell,
{      NewItem('Сводные розни~ч~ные продажи', 'Shift-F8',KbShiftF8 , cmCalcRozniza, hcDosShell,}
      Nil)))))))))))))){)},
      NewSubMenu('Ск~л~ад', $A020, NewMenu(
      NewItem('~П~ереоценка товара', 'F8',KbF8 , cmPereozen, hcDosShell,
      NewItem('Корректирова~т~ь склад', 'F7',KbF7 , cmCorrectSklad, hcDosShell,
      NewItem('Ревизи~я~ на складе', 'Ctrl-Р',KbCtrlRusR , cmRewisia, hcDosShell,
      NewLine(
      NewItem('Ито~г~и дня', 'Alt-Г',KbAltRusG , cmItogi, hcDosShell,
{      NewItem('Максимум/минимум', 'Ctrl-Т',KbCtrlRusT , cmMaxMin, hcDosShell,}
      NewItem('Блокиров~а~ть день', 'Ctrl-З', KbCtrlRusZ , cmLockDay, hcDosShell,
      NewItem('~Д~еблокировать день', 'Ctrl-Д', KbCtrlRusD , cmUnLockDay, hcDosShell,
      NewLine(
      NewSubMenu('П~р~отокол',hcDosShell,NewMenu(
      NewItem('П~р~отокол операций', 'Alt-F6',KbAltF6 , cmViewCorrectSklad, hcDosShell,
      NewItem('Протокол корректировок и во~з~вратов', 'Ctrl-F6',KbCtrlF6 , cmViewCorrectVozwrat, hcDosShell,
      Nil))),
      nil)))))))))){)},
    NewSubMenu('Сервис', $A025, NewMenu(
      NewItem('~К~алькулятор', 'Alt-К',KbAltRusK , cmCalculator, hcDosShell,
      NewItem('Календар~ь~', 'Alt-Ь',KbAltRus , cmCalendar, hcDosShell,
      NewLine(
      NewSubMenu('Конфигураци~я~',hcDosShell,NewMenu(
      NewItem('~Р~азмещение баз данных', '',KbAltRusJa,   cmConfig , hcDosShell,
      NewItem('~П~ечать', '',KbAlt9 ,   cmConfigPrint , hcDosShell,
      NewSubMenu('На~с~тройка продаж',hcDosShell,NewMenu(

      NewItem('~Д~окументы продажи', '',KbNoKey , cmSetupMarketDoc , hcDosShell,
      NewItem('Документы конси~г~нации', '',KbNoKey , cmSetupDebitDoc , hcDosShell,
      NewItem('Разделы и доку~м~енты', '',KbNoKey , cmConfigMarket , hcDosShell, Nil)))),

      NewSubMenu('И~н~струменты',hcDosShell,NewMenu(
      NewItem('~К~онсолидация', '',KbNoKey , cmIndex , hcDosShell,
      NewItem('~В~осстановление индексов товаров', '',KbNoKey , cmReanim , hcDosShell,
      NewItem('В~о~сстановление индексов клиентов', '',KbNoKey , cmReanimClient , hcDosShell,
      NewItem('Б~л~окировать период', '',KbNoKey , cmLockPeriod, hcDosShell,
      NewItem('~Д~еблокировать период','',KbNoKey , cmUnLockPeriod, hcDosShell,
      NewItem('Де~б~локировать документ','',KbNoKey , cmUnLockDoc, hcDosShell,
      NewItem('~А~варийное создание служебных файлов','',KbNoKey , cmCreatSpecialFile, hcDosShell,
      NewItem('Настройка паролей','',KbNoKey , cmSetupPassword, hcDosShell,

      NewSubMenu('В~и~деорежим',hcDosShell,NewMenu(
      NewMarkedItem(S+'~Ц~ветной', '',KbNoKey , cmColor , hcDosShell,
      NewMarkedItem(S+'~Ч~ерно-белый', '',KbNoKey , cmBlack , hcDosShell,
         Nil))),Nil)))))))))),

      NewItem('Скидк~и~', '',KbNoKey , cmSkidki , hcDosShell,
      NewItem('~О~ператоры', '',KbNoKey , cmOperator , hcDosShell,
      NewItem('~Р~еквизиты', 'Alt-Р',KbAltRusR ,   cmRekwiziti , hcDosShell,
      NewItem('Корректировать кассу', '',KbAltSpace ,   cmCorrectKassa , hcDosShell,Nil))))))))),
      NewItem('Копия остатков', 'Alt-F10', kbAltF10, cmCreatReport, hcDosShell,
      NewItem('~В~ыход в OS', '', kbNoKey, cmDosShell, hcDosShell,
      NewItem('В арх~и~в', 'Shift-F10', kbShiftF10, cmCopyToArc, hcDosShell,
      NewItem('~О~ программе', 'F1', kbF1, cmAbout, hcDosShell,
      Nil))))))))),
      NewItem('Выход','',KbAltRusCh , cmQuit, $A030,nil)))))))))));
      PbxMenuBar(MenuBar)^.SetMarker(cmColor);
end;
