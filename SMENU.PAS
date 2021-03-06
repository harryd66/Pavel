procedure TEditorApp.InitMenuBar;
var
  R: TRect;
  s : ArtikulStr;
begin
  GetExtent(R);
  s:=' ';
  R.B.Y := R.A.Y + 1;
  MenuBar := New(PMenuBar, Init(R, NewMenu(
      NewSubMenu('�� ᪫��', $A001, NewMenu(
      NewItem('��ନ஢��� ~�~�室', 'Ctrl+�',KbCtrlRusP , cmPrihod, hcDosShell,
      NewItem('��ନ஢��� ~�~�����', 'Ctrl+�',KbCtrlRusW , cmVozwrat, hcDosShell,
      NewItem('����㯫���� ⮢�� �� ~�~����','',KbCtrlRusC, cmInputToSklad, hcDosShell,
      nil)))),
      NewItem('�� ᪫��~�~','',kbNokey,cmSupermarket,$A015,
         NewItem('�����','',kbNokey,cmDolg,$A055,

      NewSubMenu('~?~', $A070, NewMenu(
      NewSubMenu('�������� ~�~����',hcDosShell,NewMenu(
{        NewItem('~�~롮ઠ ⮢��', '',KbNoKey, cmTovarStat, hcDosShell,}
         NewItem('~�~����� �த��', '',KbNoKey, cmMArketStat, hcDosShell,
         Nil)),
         NewItem('~�~��ᮭ��쭮', 'Alt-F7',KbAltF7, cmStat, hcDosShell,
         NewItem('~�~롮ઠ', 'Alt-F8',KbAltF8, cmClientStat, hcDosShell,
         NewItem('~�~���� ���ᨣ��樨', 'Alt-F2',KbAltF2, cmInfoDebit, hcDosShell,
         NewItem('~�~������', 'Alt-F3',KbAltF3, cmInfoReturn, hcDosShell,
      nil)))))),


      NewSubMenu('���~�~����', $A005, NewMenu(
      NewItem('�~�~���� ���㬥�⮢ ���㧪�', 'F2',KbF2, cmReestrDoc, hcDosShell,
      NewItem('�~�~�ᬮ����', 'F3',KbF3, cmViewDoc, hcDosShell,
      NewItem('~�~��४�஢���', 'F6',KbF6, cmEditDoc, hcDosShell,
      NewItem('~�~�����', 'F9',KbF9, cmPrintDoc, hcDosShell,
      NewLine(
      NewItem('����稥 �� ~�~�����', 'Shift-F1',KbShiftF1 , cmPrintSklad, hcDosShell,
      NewItem('�ࠩ�-~�~���', 'Shift-F2',KbShiftF2 , cmPrintPreisList, hcDosShell,
      NewItem('����� ॢ�~�~�� �� ᪫���', 'Shift-F3',KbShiftF3 , cmPrintRewizia, hcDosShell,
      NewItem('����஫�� ���ᮢ~�~� ����', 'Shift-F4',KbShiftF4 , cmPrintKassa, hcDosShell,
      NewItem('~�~�������� "�������-��������"', 'Shift-F5',KbShiftF5 , cmOstatki_Market, hcDosShell,
      NewItem('����� ����~�~��樨', 'Shift-F6',KbShiftF6 , cmViewOplataRealiz, hcDosShell,
      NewItem('����� ������~�~', 'Shift-F7',KbShiftF7 , cmPrintDebitDolg, hcDosShell,
      NewItem('�஢�ઠ ���䨪�⮢', 'Shift-F8',KbShiftF8 , cmFindDSertif, hcDosShell,
{      NewItem('������ ஧��~�~�� �த���', 'Shift-F8',KbShiftF8 , cmCalcRozniza, hcDosShell,}
      Nil)))))))))))))){)},
      NewSubMenu('��~�~��', $A020, NewMenu(
      NewItem('~�~�८業�� ⮢��', 'F8',KbF8 , cmPereozen, hcDosShell,
      NewItem('���४�஢�~�~� ᪫��', 'F7',KbF7 , cmCorrectSklad, hcDosShell,
      NewItem('������~�~ �� ᪫���', 'Ctrl-�',KbCtrlRusR , cmRewisia, hcDosShell,
      NewLine(
      NewItem('��~�~� ���', 'Alt-�',KbAltRusG , cmItogi, hcDosShell,
{      NewItem('���ᨬ�/������', 'Ctrl-�',KbCtrlRusT , cmMaxMin, hcDosShell,}
      NewItem('�����஢~�~�� ����', 'Ctrl-�', KbCtrlRusZ , cmLockDay, hcDosShell,
      NewItem('~�~������஢��� ����', 'Ctrl-�', KbCtrlRusD , cmUnLockDay, hcDosShell,
      NewLine(
      NewSubMenu('�~�~�⮪��',hcDosShell,NewMenu(
      NewItem('�~�~�⮪�� ����権', 'Alt-F6',KbAltF6 , cmViewCorrectSklad, hcDosShell,
      NewItem('��⮪�� ���४�஢�� � ��~�~��⮢', 'Ctrl-F6',KbCtrlF6 , cmViewCorrectVozwrat, hcDosShell,
      Nil))),
      nil)))))))))){)},
    NewSubMenu('��ࢨ�', $A025, NewMenu(
      NewItem('~�~�������', 'Alt-�',KbAltRusK , cmCalculator, hcDosShell,
      NewItem('��������~�~', 'Alt-�',KbAltRus , cmCalendar, hcDosShell,
      NewLine(
      NewSubMenu('���䨣���~�~',hcDosShell,NewMenu(
      NewItem('~�~����饭�� ��� ������', '',KbAltRusJa,   cmConfig , hcDosShell,
      NewItem('~�~����', '',KbAlt9 ,   cmConfigPrint , hcDosShell,
      NewSubMenu('��~�~�ன�� �த��',hcDosShell,NewMenu(

      NewItem('~�~��㬥��� �த���', '',KbNoKey , cmSetupMarketDoc , hcDosShell,
      NewItem('���㬥��� ����~�~��樨', '',KbNoKey , cmSetupDebitDoc , hcDosShell,
      NewItem('������� � ����~�~����', '',KbNoKey , cmConfigMarket , hcDosShell, Nil)))),

      NewSubMenu('�~�~���㬥���',hcDosShell,NewMenu(
      NewItem('~�~��᮫�����', '',KbNoKey , cmIndex , hcDosShell,
      NewItem('~�~���⠭������� �����ᮢ ⮢�஢', '',KbNoKey , cmReanim , hcDosShell,
      NewItem('�~�~��⠭������� �����ᮢ �����⮢', '',KbNoKey , cmReanimClient , hcDosShell,
      NewItem('�~�~���஢��� ��ਮ�', '',KbNoKey , cmLockPeriod, hcDosShell,
      NewItem('~�~������஢��� ��ਮ�','',KbNoKey , cmUnLockPeriod, hcDosShell,
      NewItem('��~�~����஢��� ���㬥��','',KbNoKey , cmUnLockDoc, hcDosShell,
      NewItem('~�~��਩��� ᮧ����� �㦥���� 䠩���','',KbNoKey , cmCreatSpecialFile, hcDosShell,
      NewItem('����ன�� ��஫��','',KbNoKey , cmSetupPassword, hcDosShell,

      NewSubMenu('�~�~���०��',hcDosShell,NewMenu(
      NewMarkedItem(S+'~�~��⭮�', '',KbNoKey , cmColor , hcDosShell,
      NewMarkedItem(S+'~�~�୮-����', '',KbNoKey , cmBlack , hcDosShell,
         Nil))),Nil)))))))))),

      NewItem('�����~�~', '',KbNoKey , cmSkidki , hcDosShell,
      NewItem('~�~������', '',KbNoKey , cmOperator , hcDosShell,
      NewItem('~�~��������', 'Alt-�',KbAltRusR ,   cmRekwiziti , hcDosShell,
      NewItem('���४�஢��� �����', '',KbAltSpace ,   cmCorrectKassa , hcDosShell,Nil))))))))),
      NewItem('����� ���⪮�', 'Alt-F10', kbAltF10, cmCreatReport, hcDosShell,
      NewItem('~�~�室 � OS', '', kbNoKey, cmDosShell, hcDosShell,
      NewItem('� ���~�~�', 'Shift-F10', kbShiftF10, cmCopyToArc, hcDosShell,
      NewItem('~�~ �ணࠬ��', 'F1', kbF1, cmAbout, hcDosShell,
      Nil))))))))),
      NewItem('��室','',KbAltRusCh , cmQuit, $A030,nil)))))))))));
      PbxMenuBar(MenuBar)^.SetMarker(cmColor);
end;
