{*
*   TV Tool Box Version 2.0
*   Copyright (c) 1992, 1993 by Richard W. Hansen
*   All Rights Reserved
*
*
*   TvConst.pas
*   Turbo Vision command constants for Turbo Pascal 7.0.
*
*}

UNIT TvConst;

{$I TVDEFS.INC}

INTERFACE

{ Some keyboard constants Borland left out. }

CONST
  kbCtrlRusF = $1E01;
  kbCtrlRusI = $3002;
  kbCtrlRusC = $2E03;
  kbCtrlRusW = $2004;
  kbCtrlRusU = $1205;
  kbCtrlRusA = $2106;
  kbCtrlRusP = $2207;
  kbCtrlRusR = $2308;
  kbCtrlRusSh = $1709;
  kbCtrlRusO = $240A;
  kbCtrlRusL = $250B;
  kbCtrlRusD = $260C;
  kbCtrlRusMZ = $320D;
  kbCtrlRusT = $310E;
  kbCtrlRusSh1 = $180F;
  kbCtrlRusZ = $1910;
  kbCtrlRusIi = $1011;
  kbCtrlRusK = $1312;
  kbCtrlRusIII = $1F13;
  kbCtrlRusE = $1414;
  kbCtrlRusG = $1615;
  kbCtrlRusM = $2F16;
  kbCtrlRusCC = $1117;
  kbCtrlRusCh = $2D18;
  kbCtrlRusN = $1519;
  kbCtrlRusJa = $2C1A;


CONST
  cmTVTtool1      = 246;
  cmFirstPage     = cmTVTtool1;
  cmLastPage      = cmFirstPage + 1;
  cmNextPage      = cmFirstPage + 2;
  cmPrevPage      = cmFirstPage + 3;
  cmMaximize      = cmFirstPage + 4;
  cmMinimize      = cmFirstPage + 5;
  cmStartJob      = cmFirstPage + 6;
  cmPauseJob      = cmFirstPage + 7;
  cmContinueJob   = cmFirstPage + 8;
  cmCancelJob     = cmFirstPage + 9;

  cmTVTtool2      = 10000;
  cmMarkStart     = cmTVTtool2;
  cmMarkEnd       = cmTVTtool2 + 1000;
  cmCursorMoved   = cmTVTtool2 + 1001;
  cmUpdateView    = cmTVTtool2 + 1002;
  cmEditView      = cmTVTtool2 + 1003;
  cmPrint         = cmTVTtool2 + 1004;
  cmJobComplete   = cmTVTtool2 + 1005;
  cmPopMenu       = cmTVTtool2 + 1006;
  cmTakeItem      = cmTVTtool2 + 1007;
  cmDisplayStr    = cmTVTtool2 + 1008;
  cmDisplayClr    = cmTVTtool2 + 1009;
  cmDragView      = cmTVTtool2 + 1010;
  cmIdentify      = cmTVTtool2 + 1011;
  cmSetId         = cmTVTtool2 + 1012;
  cmFieldError    = cmTVTtool2 + 1013;


CONST
  ofPosIndicator  = $1000;
  ofVScrollBar    = $2000;
  ofHScrollBar    = $4000;


  (*  Picture strings for TPxPictureValidators

   Type of character     Character    Description
   --------------------------------------------------------------------
   Special
                         #            Accept only a digit
                         ?            Accept only a letter
                                      (case-insensitive)
                         &            Accept only a letter, force to
                                      uppercase
                         @            Accept any character
                         !            Accept any character, force to
                                      uppercase
   Match
                         ;            Take next character literally
                         *            Repetition count
                         []           Option
                         {}           Grouping operators
                         ,            Set of alternatives
   All others                         Taken literally

  *)

CONST
  UnsignedPic1      = '#[#][#]*{[;,]###}';
    { unsigned int with optional commas }
CONST
  UnsignedPic2      = '#[#][#]*{;,###}';
    { unsigned int with commas }
CONST
  SignedPic1        = '[-]#[#][#]*{[;,]###}';
    { signed int with optional commas }
CONST
  SignedPic2        = '[-]#[#][#]*{;,###}';     {
    { signed int with commas }
CONST
  MoneyPic1         = '[$]*#.{##,00}';
    { dollars, with comma and optinal dollar sign }
CONST
  MoneyPic2         = '$*#{.##,.00}';
    { dollars, with comma and dollar sign }
CONST
  DatePic1          = '#[#]/#[#]/##';
    { date with 2 digit year (dd/mm/yy or mm/dd/yy) }
CONST
  DatePic2          = '#[#]/#[#]/##[##]';
    { date with 2 or 4 digit year (mm/dd/yy or mm/dd/yyyy) }
CONST
  DatePic3          = '#[#]/#[#]/####';
    { date with 4 digit year (mm/dd/yyyy) }
CONST
  TimePic1          = '{##}:{##}[:{##}]';
    { HH:MM:SS with optional seconds }
CONST
  TimePic2          = '{##}:{##}:{##}';
    { HH:MM:SS }
CONST
  PhonePic1         = '[(###) ]###-####';
    { phone number with optional area code }
CONST
  PhonePic2         = '(###) ###-####';
    { phone number with area code }
CONST
  SSNPic            = '###-##-####';
CONST
  FirstCharUpPic    = '*{&*? }';
    { uppercase the first char of every word }
CONST
  FilenamePic       = '{&*7[&]}.{*3[&]}';
    { filename (no path) with extension }


IMPLEMENTATION
END.
