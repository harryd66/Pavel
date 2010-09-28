unit sqlext;

(*
   ODBC.DLL Interface Unit, Part II

   Microsoft ODBC "SQL Extensions"

   Translated by Yasser Asmi (CIS 71543,2252)
*)

{$A+,I-,R-,S-,V-,B-,G+,X+,W-}

interface

uses
   wintypes, sql;

const
(* Additional return codes *)
   SQL_STILL_EXECUTING  = 2;

(* SQL extended datatypes *)
   SQL_DATE          = 9;
   SQL_TIME          = 10;
   SQL_TIMESTAMP     = 11;
   SQL_LONGVARCHAR   = -1;
   SQL_BINARY        = -2;
   SQL_VARBINARY     = -3;
   SQL_LONGVARBINARY = 4;
   SQL_BIGINT        = -5;
   SQL_TINYINT       = -6;
   SQL_BIT           = -7;

(* C datatype to SQL datatype mapping *)
   SQL_C_DATE      = SQL_DATE;
   SQL_C_TIME      = SQL_TIME;
   SQL_C_TIMESTAMP = SQL_TIMESTAMP;
   SQL_C_BINARY    = SQL_BINARY;
   SQL_C_BIT       = SQL_BIT;
   SQL_C_TINYINT   = SQL_TINYINT;

(* overrides const in the SQL unit *)
   SQL_TYPE_MIN    = -7;
   SQL_ALL_TYPES   = 0;

(* Access modes *)
   SQL_MODE_READ_WRITE  = 0;
   SQL_MODE_READ_ONLY   = 1;

(* Options for SQLDriverConnect *)
   SQL_DRIVER_NOPROMPT          = 0;
   SQL_DRIVER_COMPLETE          = 1;
   SQL_DRIVER_PROMPT            = 2;
   SQL_DRIVER_COMPLETE_REQUIRED = 3;

(* Special return values for SQLGetData *)
   SQL_NO_TOTAL   = -4;

(* Defines for SQLGetFunctions *)
   SQL_API_SQLALLOCCONNECT     = 1;    (* Core Functions           *)
   SQL_API_SQLALLOCENV         = 2;
   SQL_API_SQLALLOCSTMT        = 3;
   SQL_API_SQLBINDCOL          = 4;
   SQL_API_SQLCANCEL           = 5;
   SQL_API_SQLCOLATTRIBUTES    = 6;
   SQL_API_SQLCONNECT          = 7;
   SQL_API_SQLDESCRIBECOL      = 8;
   SQL_API_SQLDISCONNECT       = 9;
   SQL_API_SQLERROR            = 10;
   SQL_API_SQLEXECDIRECT       = 11;
   SQL_API_SQLEXECUTE          = 12;
   SQL_API_SQLFETCH            = 13;
   SQL_API_SQLFREECONNECT      = 14;
   SQL_API_SQLFREEENV          = 15;
   SQL_API_SQLFREESTMT         = 16;
   SQL_API_SQLGETCURSORNAME    = 17;
   SQL_API_SQLNUMRESULTCOLS    = 18;
   SQL_API_SQLPREPARE          = 19;
   SQL_API_SQLROWCOUNT         = 20;
   SQL_API_SQLSETCURSORNAME    = 21;
   SQL_API_SQLSETPARAM         = 22;
   SQL_API_SQLTRANSACT         = 23;

   SQL_NUM_FUNCTIONS           = 23;

   SQL_EXT_API_START           = 40;

   SQL_API_SQLCOLUMNS          = 40;   (* Level 1 Functions        *)
   SQL_API_SQLDRIVERCONNECT    = 41;
   SQL_API_SQLGETCONNECTOPTION = 42;
   SQL_API_SQLGETDATA          = 43;
   SQL_API_SQLGETFUNCTIONS     = 44;
   SQL_API_SQLGETINFO          = 45;
   SQL_API_SQLGETSTMTOPTION    = 46;
   SQL_API_SQLGETTYPEINFO      = 47;
   SQL_API_SQLPARAMDATA        = 48;
   SQL_API_SQLPUTDATA          = 49;
   SQL_API_SQLSETCONNECTOPTION = 50;
   SQL_API_SQLSETSTMTOPTION    = 51;
   SQL_API_SQLSPECIALCOLUMNS   = 52;
   SQL_API_SQLSTATISTICS       = 53;
   SQL_API_SQLTABLES           = 54;

   SQL_API_SQLBROWSECONNECT    = 55;    (* Level 2 Functions        *)
   SQL_API_SQLCOLUMNPRIVILEGES = 56;
   SQL_API_SQLDATASOURCES      = 57;
   SQL_API_SQLDESCRIBEPARAM    = 58;
   SQL_API_SQLEXTENDEDFETCH    = 59;
   SQL_API_SQLFOREIGNKEYS      = 60;
   SQL_API_SQLMORERESULTS      = 61;
   SQL_API_SQLNATIVESQL        = 62;
   SQL_API_SQLNUMPARAMS        = 63;
   SQL_API_SQLPARAMOPTIONS     = 64;
   SQL_API_SQLPRIMARYKEYS      = 65;
   SQL_API_SQLPROCEDURECOLUMNS = 66;
   SQL_API_SQLPROCEDURES       = 67;
   SQL_API_SQLSETPOS           = 68;
   SQL_API_SQLSETSCROLLOPTIONS = 69;
   SQL_API_SQLTABLEPRIVILEGES  = 70;

   SQL_EXT_API_LAST            = 70;

   SQL_NUM_EXTENSIONS = SQL_EXT_API_LAST - SQL_EXT_API_START + 1;

(* Defines for SQLGetInfo *)
   SQL_INFO_FIRST                       = 0;
   SQL_ACTIVE_CONNECTIONS               = 0;
   SQL_ACTIVE_STATEMENTS                = 1;
   SQL_DATA_SOURCE_NAME                 = 2;
   SQL_DRIVER_HDBC                      = 3;
   SQL_DRIVER_HENV                      = 4;
   SQL_DRIVER_HSTMT                     = 5;
   SQL_DRIVER_NAME                      = 6;
   SQL_DRIVER_VER                       = 7;
   SQL_FETCH_DIRECTION                  = 8;
   SQL_ODBC_API_CONFORMANCE             = 9;
   SQL_ODBC_VER                        = 10;
   SQL_ROW_UPDATES                     = 11;
   SQL_ODBC_SAG_CLI_CONFORMANCE        = 12;
   SQL_SERVER_NAME                     = 13;
   SQL_SEARCH_PATTERN_ESCAPE           = 14;
   SQL_ODBC_SQL_CONFORMANCE            = 15;

   SQL_DATABASE_NAME                   = 16;
   SQL_DBMS_NAME                       = 17;
   SQL_DBMS_VER                        = 18;

   SQL_ACCESSIBLE_TABLES               = 19;
   SQL_ACCESSIBLE_PROCEDURES           = 20;
   SQL_PROCEDURES                      = 21;
   SQL_CONCAT_NULL_BEHAVIOR            = 22;
   SQL_CURSOR_COMMIT_BEHAVIOR          = 23;
   SQL_CURSOR_ROLLBACK_BEHAVIOR        = 24;
   SQL_DATA_SOURCE_READ_ONLY           = 25;
   SQL_DEFAULT_TXN_ISOLATION           = 26;
   SQL_EXPRESSIONS_IN_ORDERBY          = 27;
   SQL_IDENTIFIER_CASE                 = 28;
   SQL_IDENTIFIER_QUOTE_CHAR           = 29;
   SQL_MAX_COLUMN_NAME_LEN             = 30;
   SQL_MAX_CURSOR_NAME_LEN             = 31;
   SQL_MAX_OWNER_NAME_LEN              = 32;
   SQL_MAX_PROCEDURE_NAME_LEN          = 33;
   SQL_MAX_QUALIFIER_NAME_LEN          = 34;
   SQL_MAX_TABLE_NAME_LEN              = 35;
   SQL_MULT_RESULT_SETS                = 36;
   SQL_MULTIPLE_ACTIVE_TXN             = 37;
   SQL_OUTER_JOINS                     = 38;
   SQL_OWNER_TERM                      = 39;
   SQL_PROCEDURE_TERM                  = 40;
   SQL_QUALIFIER_NAME_SEPARATOR        = 41;
   SQL_QUALIFIER_TERM                  = 42;
   SQL_SCROLL_CONCURRENCY              = 43;
   SQL_SCROLL_OPTIONS                  = 44;
   SQL_TABLE_TERM                      = 45;
   SQL_TXN_CAPABLE                     = 46;
   SQL_USER_NAME                       = 47;

   SQL_CONVERT_FUNCTIONS               = 48;
   SQL_NUMERIC_FUNCTIONS               = 49;
   SQL_STRING_FUNCTIONS                = 50;
   SQL_SYSTEM_FUNCTIONS                = 51;
   SQL_TIMEDATE_FUNCTIONS              = 52;

   SQL_CONVERT_BIGINT                  = 53;
   SQL_CONVERT_BINARY                  = 54;
   SQL_CONVERT_BIT                     = 55;
   SQL_CONVERT_CHAR                    = 56;
   SQL_CONVERT_DATE                    = 57;
   SQL_CONVERT_DECIMAL                 = 58;
   SQL_CONVERT_DOUBLE                  = 59;
   SQL_CONVERT_FLOAT                   = 60;
   SQL_CONVERT_INTEGER                 = 61;
   SQL_CONVERT_LONGVARCHAR             = 62;
   SQL_CONVERT_NUMERIC                 = 63;
   SQL_CONVERT_REAL                    = 64;
   SQL_CONVERT_SMALLINT                = 65;
   SQL_CONVERT_TIME                    = 66;
   SQL_CONVERT_TIMESTAMP               = 67;
   SQL_CONVERT_TINYINT                 = 68;
   SQL_CONVERT_VARBINARY               = 69;
   SQL_CONVERT_VARCHAR                 = 70;
   SQL_CONVERT_LONGVARBINARY           = 71;

   SQL_TXN_ISOLATION_OPTION            = 72;
   SQL_ODBC_SQL_OPT_IEF                = 73;

   SQL_INFO_LAST                       = 73;
   SQL_INFO_DRIVER_START               = 1000;

(* "SQL_CONVERT_" return value bitmasks *)

   SQL_CVT_CHAR                        = $00000001;
   SQL_CVT_NUMERIC                     = $00000002;
   SQL_CVT_DECIMAL                     = $00000004;
   SQL_CVT_INTEGER                     = $00000008;
   SQL_CVT_SMALLINT                    = $00000010;
   SQL_CVT_FLOAT                       = $00000020;
   SQL_CVT_REAL                        = $00000040;
   SQL_CVT_DOUBLE                      = $00000080;
   SQL_CVT_VARCHAR                     = $00000100;
   SQL_CVT_LONGVARCHAR                 = $00000200;
   SQL_CVT_BINARY                      = $00000400;
   SQL_CVT_VARBINARY                   = $00000800;
   SQL_CVT_BIT                         = $00001000;
   SQL_CVT_TINYINT                     = $00002000;
   SQL_CVT_BIGINT                      = $00004000;
   SQL_CVT_DATE                        = $00008000;
   SQL_CVT_TIME                        = $00010000;
   SQL_CVT_TIMESTAMP                   = $00020000;
   SQL_CVT_LONGVARBINARY               = $00040000;

(* Conversion functions *)
   SQL_FN_CVT_CONVERT                  = $00000001;

(* String functions *)

   SQL_FN_STR_CONCAT                   = $00000001;
   SQL_FN_STR_INSERT                   = $00000002;
   SQL_FN_STR_LEFT                     = $00000004;
   SQL_FN_STR_LTRIM                    = $00000008;
   SQL_FN_STR_LENGTH                   = $00000010;
   SQL_FN_STR_LOCATE                   = $00000020;
   SQL_FN_STR_LCASE                    = $00000040;
   SQL_FN_STR_REPEAT                   = $00000080;
   SQL_FN_STR_REPLACE                  = $00000100;
   SQL_FN_STR_RIGHT                    = $00000200;
   SQL_FN_STR_RTRIM                    = $00000400;
   SQL_FN_STR_SUBSTRING                = $00000800;
   SQL_FN_STR_UCASE                    = $00001000;
   SQL_FN_STR_ASCII                    = $00002000;
   SQL_FN_STR_CHAR                     = $00004000;

(* Numeric functions *)

   SQL_FN_NUM_ABS                      = $00000001;
   SQL_FN_NUM_ACOS                     = $00000002;
   SQL_FN_NUM_ASIN                     = $00000004;
   SQL_FN_NUM_ATAN                     = $00000008;
   SQL_FN_NUM_ATAN2                    = $00000010;
   SQL_FN_NUM_CEILING                  = $00000020;
   SQL_FN_NUM_COS                      = $00000040;
   SQL_FN_NUM_COT                      = $00000080;
   SQL_FN_NUM_EXP                      = $00000100;
   SQL_FN_NUM_FLOOR                    = $00000200;
   SQL_FN_NUM_LOG                      = $00000400;
   SQL_FN_NUM_MOD                      = $00000800;
   SQL_FN_NUM_SIGN                     = $00001000;
   SQL_FN_NUM_SIN                      = $00002000;
   SQL_FN_NUM_SQRT                     = $00004000;
   SQL_FN_NUM_TAN                      = $00008000;
   SQL_FN_NUM_PI                       = $00010000;
   SQL_FN_NUM_RAND                     = $00020000;

(* Time/date functions *)

   SQL_FN_TD_NOW                       = $00000001;
   SQL_FN_TD_CURDATE                   = $00000002;
   SQL_FN_TD_DAYOFMONTH                = $00000004;
   SQL_FN_TD_DAYOFWEEK                 = $00000008;
   SQL_FN_TD_DAYOFYEAR                 = $00000010;
   SQL_FN_TD_MONTH                     = $00000020;
   SQL_FN_TD_QUARTER                   = $00000040;
   SQL_FN_TD_WEEK                      = $00000080;
   SQL_FN_TD_YEAR                      = $00000100;
   SQL_FN_TD_CURTIME                   = $00000200;
   SQL_FN_TD_HOUR                      = $00000400;
   SQL_FN_TD_MINUTE                    = $00000800;
   SQL_FN_TD_SECOND                    = $00001000;

(* System functions *)

   SQL_FN_SYS_USERNAME                 = $00000001;
   SQL_FN_SYS_DBNAME                   = $00000002;
   SQL_FN_SYS_IFNULL                   = $00000004;

(* Scroll option masks *)

   SQL_SO_FORWARD_ONLY                 = $00000001;
   SQL_SO_KEYSET_DRIVEN                = $00000002;
   SQL_SO_DYNAMIC                      = $00000004;
   SQL_SO_MIXED                        = $00000008;

(* Scroll concurrency option masks *)

   SQL_SCCO_READ_ONLY                  = $00000001;
   SQL_SCCO_LOCK                       = $00000002;
   SQL_SCCO_OPT_TIMESTAMP              = $00000004;
   SQL_SCCO_OPT_VALUES                 = $00000008;

(* Fetch direction option masks *)

   SQL_FD_FETCH_NEXT                   = $00000001;
   SQL_FD_FETCH_FIRST                  = $00000002;
   SQL_FD_FETCH_LAST                   = $00000004;
   SQL_FD_FETCH_PREV                   = $00000008;
   SQL_FD_FETCH_ABSOLUTE               = $00000010;
   SQL_FD_FETCH_RELATIVE               = $00000020;
   SQL_FD_FETCH_RESUME                 = $00000040;

(* Transaction isolation option masks *)

   SQL_TXN_READ_UNCOMMITTED            = $00000001;
   SQL_TXN_READ_COMMITTED              = $00000002;
   SQL_TXN_REPEATABLE_READ             = $00000004;
   SQL_TXN_SERIALIZABLE                = $00000008;
   SQL_TXN_VERSIONING                  = $00000010;

(* options for SQLGetStmtOption/SQLSetStmtOption *)
   SQL_QUERY_TIMEOUT       = 0;
   SQL_MAX_ROWS            = 1;
   SQL_NOSCAN              = 2;
   SQL_MAX_LENGTH          = 3;
   SQL_ASYNC_ENABLE        = 4;
   SQL_BIND_TYPE           = 5;

   SQL_BIND_BY_COLUMN      = 0;    (* Suboption for SQL_BIND_TYPE *)

(* options for SQLSetConnectOption/SQLGetConnectOption *)
   SQL_ACCESS_MODE         = 101;
   SQL_AUTOCOMMIT          = 102;
   SQL_LOGIN_TIMEOUT       = 103;
   SQL_OPT_TRACE           = 104;
   SQL_OPT_TRACEFILE       = 105;
   SQL_TRANSLATE_DLL       = 106;
   SQL_TRANSLATE_OPTION    = 107;
   SQL_TXN_ISOLATION       = 108;
   SQL_CONNECT_OPT_DRVR_START  = 1000;

(*  Column types and scopes in SQLSpecialColumns.  *)
   SQL_BEST_ROWID = 1;
   SQL_ROWVER     = 2;

   SQL_SCOPE_CURROW       = 0;
   SQL_SCOPE_TRANSACTION  = 1;
   SQL_SCOPE_SESSION      = 2;

(* SQLExtendedFetch "fFetchType" values *)
   SQL_FETCH_NEXT      = 1;
   SQL_FETCH_FIRST     = 2;
   SQL_FETCH_LAST      = 3;
   SQL_FETCH_PREV      = 4;
   SQL_FETCH_ABSOLUTE  = 5;
   SQL_FETCH_RELATIVE  = 6;
   SQL_FETCH_RESUME    = 7;

(* SQLExtendedFetch "rgfRowStatus" element values *)
   SQL_ROW_SUCCESS     = 0;
   SQL_ROW_DELETED     = 1;
   SQL_ROW_UPDATED     = 2;
   SQL_ROW_NOROW       = 3;

(* Defines for SQLForeignKeys (returned in result set) *)
   SQL_CASCADE         = 0;
   SQL_RESTRICT        = 1;
   SQL_SET_NULL        = 2;

(* Defines for SQLProcedureColumns (returned in the result set) *)
   SQL_PARAM_TYPE_UNKNOWN  = 0;
   SQL_PARAM_INPUT         = 1;
   SQL_PARAM_INPUT_OUTPUT  = 2;
   SQL_RESULT_COL          = 3;

(* Defines for SQLSetScrollOptions *)
   SQL_CONCUR_READ_ONLY    = 1;
   SQL_CONCUR_LOCK         = 2;
   SQL_CONCUR_TIMESTAMP    = 3;
   SQL_CONCUR_VALUES       = 4;

   SQL_SCROLL_FORWARD_ONLY   = 0;
   SQL_SCROLL_KEYSET_DRIVEN  = -1;
   SQL_SCROLL_DYNAMIC        = -2;

(* Defines for SQLStatistics *)
   SQL_INDEX_UNIQUE    = 0;
   SQL_INDEX_ALL       = 1;
   SQL_ENSURE          = 1;
   SQL_QUICK           = 0;

(* Defines for SQLStatistics (returned in the result set) *)
   SQL_TABLE_STAT      = 0;
   SQL_INDEX_CLUSTERED = 1;
   SQL_INDEX_HASHED    = 2;
   SQL_INDEX_OTHER     = 3;

(* Defines for SQLSetPos *)
   SQL_ENTIRE_ROWSET   = 0;

type
   date_struct = record
                    year : integer;
                    month : word;
                    day : word;
                 end;
   time_struc = record
                   hour : word;
                   minute : word;
                   second : word;
                end;
   timestamp_struct = record
                         year : integer;
                         month : word;
                         day : word;
                         hour : word;
                         minute : word;
                         second : word;
                         fraction : longint;
                      end;


function SQLColumns (stmt : hstmt;
                     szTableQualifier : pchar;
                     cbTableQualifier : integer;
                     szTableOwner : pchar;
                     cbTableOwner : integer;
                     szTableName : pchar;
                     cbTableName : integer;
                     szColumnName : pchar;
                     cbColumnName : integer) : retcode;
function SQLDriverConnect (dbc : hdbc;
                           wnd : hwnd;
                           szConnStrIn : pchar;
                           cbConnStrIn : integer;
                           szConnStrOut : pchar;
                           cbConnStrOutMax : integer;
                           var cbConnStrOut : integer;
                           fDriverCompletion : word) : retcode;
function SQLGetConnectOption (dbc : hdbc;
                              fOption : word;
                              pvParam : pointer) : retcode;

function SQLGetData (stmt : hstmt;
                     icol : word;
                     fCType : integer;
                     rgbValue : pointer;
                     cbValueMax : longint;
                     var cbValue : longint) : retcode;
function SQLGetFunctions (dbc : hdbc;
                          fFunction : word;
                          var fExists : word) : retcode;
function SQLGetInfo (dbc : hdbc;
                     fInfoType : word;
                     rgbInfoValue : pointer;
                     cbInfoValueMax : integer;
                     var cbInfoValue : integer) : retcode;

function SQLGetStmtOption (stmt : hstmt;
                           fOption : word;
                           pvParam : pointer) : retcode;
function SQLGetTypeInfo (stmt : hstmt;
                         fSqlType : integer) : retcode;
function SQLParamData (stmt : hstmt;
                       var rgbValue) : retcode;
function SQLPutData (stmt : hstmt;
                     rgbValue : pointer;
                     cbValue : longint) : retcode;
function SQLSetConnectOption (dbc : hdbc;
                              fOption : word;
                              vParam : dword) : retcode;
function SQLSetStmtOption (stmt : hstmt;
                           fOption : word;
                           vParam : dword) : retcode;
function SQLSpecialColumns (stmt : hstmt;
                            fColType : word;
                            szTableQualifier : pchar;
                            cbTableQualifier : integer;
                            szTableOwner : pchar;
                            cbTableOwner : integer;
                            szTableName : pchar;
                            cbTableName : integer;
                            fScope : word;
                            fNullable : word) : retcode;
function SQLStatistics (stmt : hstmt;
                        szTableQualifier : pchar;
                        cbTableQualifier : integer;
                        szTableOwner : pchar;
                        cbTableOwner : integer;
                        szTableName : pchar;
                        cbTableName : integer;
                        fUnique : word;
                        fAccuracy : word) : retcode;
function SQLTables (stmt : hstmt;
                    szTableQualifier : pchar;
                    cbTableQualifier : integer;
                    szTableOwner : pchar;
                    cbTableOwner : integer;
                    szTableName : pchar;
                    cbTableName : integer;
                    szTableType : pchar;
                    cbTableType : integer) : retcode;
function SQLBrowseConnect (dbc : hdbc;
                           szConnStrIn : pchar;
                           cbConnStrIn : integer;
                           szConnStrOut : pchar;
                           cbConnStrOutMax : integer;
                           var cbConnStrOut : integer) : retcode;
function SQLColumnPrivileges (stmt : hstmt;
                              szTableQualifier : pchar;
                              cbTableQualifier : integer;
                              szTableOwner : pchar;
                              cbTableOwner : integer;
                              szTableName : pchar;
                              cbTableName : integer;
                              szColumnName : pchar;
                              cbColumnName : integer) : retcode;
function SQLDataSources (env : henv;
                         fDirection : word;
                         szDSN : pchar;
                         cbDSNMax : integer;
                         var cbDSN : integer;
                         szDescription : pchar;
                         cbDescriptionMax : integer;
                         var cbDescription : integer) : retcode;
function SQLDescribeParam (stmt : hstmt;
                           ipar : word;
                           var fSqlType : integer;
                           var cbColDef : dword;
                           var ibScale : integer;
                           var fNullable : integer) : retcode;
function SQLExtendedFetch (stmt : hstmt;
                           fFetchType : word;
                           irow : longint;
                           var crow : dword;
                           var rgfRowStatus : word) : retcode;
function SQLForeignKeys (stmt : hstmt;
                         szPkTableQualifier : pchar;
                         cbPkTableQualifier : integer;
                         szPkTableOwner : pchar;
                         cbPkTableOwner : integer;
                         szPkTableName : pchar;
                         cbPkTableName : integer;
                         szFkTableQualifier : pchar;
                         cbFkTableQualifier : integer;
                         szFkTableOwner : pchar;
                         cbFkTableOwner : integer;
                         szFkTableName : pchar;
                         cbFkTableName : integer) : retcode;
function SQLMoreResults (stmt : hstmt) : retcode;
function SQLNativeSql (dbc : hdbc;
                       szSqlStrIn : pchar;
                       cbSqlStrIn : longint;
                       szSqlStr : pchar;
                       cbSqlStrMax : longint;
                       var cbSqlStr : longint) : retcode;
function SQLNumParams (stmt : hstmt;
                       var cpar : integer) : retcode;
function SQLParamOptions (stmt : hstmt;
                          crow : dword;
                          var irow : dword) : retcode;
function SQLPrimaryKeys (stmt : hstmt;
                         szTableQualifier : pchar;
                         cbTableQualifier : integer;
                         szTableOwner : pchar;
                         cbTableOwner : integer;
                         szTableName : pchar;
                         cbTableName : integer) : retcode;
function SQLProcedureColumns (stmt : hstmt;
                              szProcQualifier : pchar;
                              cbProcQualifier : integer;
                              szProcOwner : pchar;
                              cbProcOwner : integer;
                              szProcName : pchar;
                              cbProcName : integer;
                              szColumnName : pchar;
                              cbColumnName : integer) : retcode;
function SQLProcedures (stmt : hstmt;
                        szProcQualifier : pchar;
                        cbProcQualifier : integer;
                        szProcOwner : pchar;
                        cbProcOwner : integer;
                        szProcName : pchar;
                        cbProcName : integer) : retcode;
function SQLSetPos (stmt : hstmt;
                    irow : word;
                    fRefresh : bool;
                    fLock : bool) : retcode;
function SQLSetScrollOptions (stmt : hstmt;
                              fConcurrency : word;
                              crowKeyset : longint;
                              crowRowset : word) : retcode;
function SQLTablePrivileges (stmt : hstmt;
                             szTableQualifier : pchar;
                             cbTableQualifier : integer;
                             szTableOwner : pchar;
                             cbTableOwner : integer;
                             szTableName : pchar;
                             cbTableName : integer) : retcode;

implementation


function SQLGETDATA;               external 'ODBC' index 43;
function SQLCOLUMNPRIVILEGES;      external 'ODBC' index 56;
function SQLPRIMARYKEYS;           external 'ODBC' index 65;
function SQLMORERESULTS;           external 'ODBC' index 61;
function SQLPUTDATA;               external 'ODBC' index 49;
function SQLGETSTMTOPTION;         external 'ODBC' index 46;
function SQLSETSTMTOPTION;         external 'ODBC' index 51;
function SQLNUMPARAMS;             external 'ODBC' index 63;
function SQLSTATISTICS;            external 'ODBC' index 53;
function SQLGETINFO;               external 'ODBC' index 45;
function SQLGETCONNECTOPTION;      external 'ODBC' index 42;
function SQLPARAMOPTIONS;          external 'ODBC' index 64;
function SQLNATIVESQL;             external 'ODBC' index 62;
function SQLGETFUNCTIONS;          external 'ODBC' index 44;
function SQLSETSCROLLOPTIONS;      external 'ODBC' index 69;
function SQLSETCONNECTOPTION;      external 'ODBC' index 50;
function SQLDRIVERCONNECT;         external 'ODBC' index 41;
function SQLTABLES;                external 'ODBC' index 54;
function SQLBROWSECONNECT;         external 'ODBC' index 55;
function SQLDESCRIBEPARAM;         external 'ODBC' index 58;
function SQLTABLEPRIVILEGES;       external 'ODBC' index 70;
function SQLFOREIGNKEYS;           external 'ODBC' index 60;
function SQLPROCEDURECOLUMNS;      external 'ODBC' index 66;
function SQLCOLUMNS;               external 'ODBC' index 40;
function SQLDATASOURCES;           external 'ODBC' index 57;
function SQLEXTENDEDFETCH;         external 'ODBC' index 59;
function SQLPARAMDATA;             external 'ODBC' index 48;
function SQLSPECIALCOLUMNS;        external 'ODBC' index 52;
function SQLGETTYPEINFO;           external 'ODBC' index 47;
function SQLSETPOS;                external 'ODBC' index 68;
function SQLPROCEDURES;            external 'ODBC' index 67;


end.
