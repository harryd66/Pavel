unit odbcinst;

(*
   ODBCINST.DLL Interface Unit

   Microsoft ODBC "Installation functions"

   Translated by Yasser Asmi (CIS 71543,2252)
*)


{$A+,I-,R-,S-,V-,B-,G+,X+,W-}

interface

uses
   wintypes;

const
(* SQLConfigDataSource request flags *)
   ODBC_ADD_DSN     = 1;               (* Add data source *)
   ODBC_CONFIG_DSN  = 2;               (* Configure (edit) data source *)
   ODBC_REMOVE_DSN  = 3;               (* Remove data source *)


function SQLInstallDriver (lpszInfFile : pchar;
                           lpszDriver : pchar;
                           lpszPath : pchar;
                           cbPathMax : word;
                           var cbPathOut : word) : bool;
function SQLInstallDriverManager (lpszPath : pchar;
                                  cbPathMax : word;
                                  var cbPathOut : word) : bool;
function SQLGetInstalledDrivers (lpszBuf : pchar;
                                 cbBufMax : word;
                                 var cbBufOut : word) : bool;
function SQLGetAvailableDrivers (lpszInfFile : pchar;
                                 lpszBuf : pchar;
                                 cbBufMax : word;
                                 var cbBufOut : word) : bool;
function SQLConfigDataSource (Parent : hwnd;
                              fRequest : word;
                              lpszDriver : pchar;
                              lpszAttributes : pchar) : bool;
function SQLRemoveDefaultDataSource : bool;
function SQLWriteDSNToIni (lpszDSN : pchar;
                           lpszDriver : pchar) : bool;
function SQLRemoveDSNFromIni (lpszDSN : pchar) : bool;


implementation

function SQLGETAVAILABLEDRIVERS;         external 'ODBCINST' index 5;
function SQLGETINSTALLEDDRIVERS;         external 'ODBCINST' index 4;
function SQLINSTALLDRIVER;               external 'ODBCINST' index 2;
function SQLCONFIGDATASOURCE;            external 'ODBCINST' index 6;
function SQLREMOVEDSNFROMINI;            external 'ODBCINST' index 9;
function SQLINSTALLDRIVERMANAGER;        external 'ODBCINST' index 3;
function SQLREMOVEDEFAULTDATASOURCE;     external 'ODBCINST' index 7;
function SQLWRITEDSNTOINI;               external 'ODBCINST' index 8;

end.
