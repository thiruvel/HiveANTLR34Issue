grammar Insert;

options
{
output=AST;
ASTLabelType=CommonTree;
backtrack=false;
k=3;
}

tokens {
TOK_INSERT;
TOK_QUERY;
TOK_SELECT;
TOK_SELEXPR;
TOK_FROM;
TOK_TAB;
TOK_TAB_OR_PART;
TOK_PARTSPEC;
TOK_PARTVAL;
TOK_DIR;
TOK_LOCAL_DIR;
TOK_TABREF;
TOK_INSERT_INTO;
TOK_DESTINATION;
TOK_ALLCOLREF;
TOK_TABLE_OR_COL;
TOK_EXPLIST;
TOK_TABCOLNAME;
TOK_TMP_FILE;
TOK_STRINGLITERALSEQUENCE;
TOK_CHARSETLITERAL;
TOK_EXPLAIN;
TOK_IFEXISTS;
TOK_IFNOTEXISTS;
TOK_TABALIAS;
TOK_TABNAME;
}


// Package headers
@header {
package com.yahoo.antlr;
}
@lexer::header {package com.yahoo.antlr;}


@members {
  Stack msgs = new Stack<String>();
}

@rulecatch {
catch (RecognitionException e) {
 reportError(e);
  throw e;
}
}

insertClause
@init { msgs.push("insert clause"); }
@after { msgs.pop(); }
   : KW_INSERT KW_OVERWRITE destination ifNotExists?
        -> ^(TOK_DESTINATION destination ifNotExists?)
   | KW_INSERT KW_INTO KW_TABLE tableOrPartition
       -> ^(TOK_INSERT_INTO ^(tableOrPartition))
   ;

ifNotExists
@init { msgs.push("if not exists clause"); }
@after { msgs.pop(); }
    : KW_IF KW_NOT KW_EXISTS
        -> ^(TOK_IFNOTEXISTS)
    ;

destination
@init { msgs.push("destination specification"); }
@after { msgs.pop(); }
   : KW_LOCAL KW_DIRECTORY StringLiteral
        -> ^(TOK_LOCAL_DIR StringLiteral)
   | KW_DIRECTORY StringLiteral
        -> ^(TOK_DIR StringLiteral)
   | KW_TABLE tableOrPartition
        -> ^(tableOrPartition)
   ;

//----------------------- Rules for parsing selectClause -----------------------------
// select a,b,c ...
selectClause
@init { msgs.push("select clause"); }
@after { msgs.pop(); }
    : KW_SELECT (((KW_ALL | dist=KW_DISTINCT)? selectList))
        -> ^(TOK_SELECT selectList)
    ;

selectList
@init { msgs.push("select list"); }
@after { msgs.pop(); }
    : selectItem ( COMMA  selectItem )* 
        -> selectItem+
    ;

selectItem
@init { msgs.push("selection target"); }
@after { msgs.pop(); }
    : ( selectExpression  ((KW_AS? Identifier) | (KW_AS LPAREN Identifier (COMMA Identifier)* RPAREN))?) 
        -> ^(TOK_SELEXPR selectExpression Identifier*)
    ;


selectExpression
@init { msgs.push("select expression"); }
@after { msgs.pop(); }
    :
    tableAllColumns
    ;

selectExpressionList
@init { msgs.push("select expression list"); }
@after { msgs.pop(); }
    :
    selectExpression (COMMA selectExpression)* 
        -> ^(TOK_EXPLIST selectExpression+)
    ;


//-----------------------------------------------------------------------------------

tableAllColumns
    : STAR
        -> ^(TOK_ALLCOLREF)
    | tableName DOT STAR
        -> ^(TOK_ALLCOLREF tableName)
    ;

// (table|column)
tableOrColumn
@init { msgs.push("table or column identifier"); }
@after { msgs.pop(); }
    : Identifier
        -> ^(TOK_TABLE_OR_COL Identifier)
    ;

//----------------------- Rules for parsing fromClause ------------------------------
// from [col1, col2, col3] table1, [col4, col5] table2
fromClause
@init { msgs.push("from clause"); }
@after { msgs.pop(); }
    : KW_FROM joinSource
        -> ^(TOK_FROM joinSource)
    ;

joinSource
@init { msgs.push("join source"); }
@after { msgs.pop(); }
    : fromSource
    ;

tableAlias
@init {msgs.push("table alias"); }
@after {msgs.pop(); }
    : Identifier
        -> ^(TOK_TABALIAS Identifier)
    ;

fromSource
@init { msgs.push("from source"); }
@after { msgs.pop(); }
    : tableSource
    ;

tableSource
@init { msgs.push("table source"); }
@after { msgs.pop(); }
    : tabname=tableName (alias=Identifier)?
        -> ^(TOK_TABREF $tabname  $alias?)
    ;

tableName
@init { msgs.push("table name"); }
@after { msgs.pop(); }
    : (db=Identifier DOT)? tab=Identifier
        -> ^(TOK_TABNAME $db? $tab)
    ;

constant
@init { msgs.push("constant"); }
@after { msgs.pop(); }
    : Number
    | StringLiteral
    | stringLiteralSequence
    | BigintLiteral
    | SmallintLiteral
    | TinyintLiteral
    | charSetStringLiteral
    ;

stringLiteralSequence
    : StringLiteral StringLiteral+ 
        -> ^(TOK_STRINGLITERALSEQUENCE StringLiteral StringLiteral+)
    ;

charSetStringLiteral
@init { msgs.push("character string literal"); }
@after { msgs.pop(); }
    : csName=CharSetName csLiteral=CharSetLiteral 
        -> ^(TOK_CHARSETLITERAL $csName $csLiteral)
    ;

tableOrPartition
   : tableName partitionSpec? 
        -> ^(TOK_TAB tableName partitionSpec?)
   ;

partitionSpec
    : KW_PARTITION LPAREN partitionVal (COMMA  partitionVal )* RPAREN 
        -> ^(TOK_PARTSPEC partitionVal +)
    ;

partitionVal
    : Identifier (EQUAL constant)? 
        -> ^(TOK_PARTVAL Identifier constant?)
    ;

KW_ALL : 'ALL';
KW_NOT : 'NOT' | '!';
KW_IF : 'IF';
KW_EXISTS : 'EXISTS';
KW_FROM : 'FROM';
KW_AS : 'AS';
KW_INTO	:	'INTO';
KW_SELECT : 'SELECT';
KW_DISTINCT : 'DISTINCT';
KW_INSERT : 'INSERT';
KW_OVERWRITE : 'OVERWRITE';
KW_PARTITION : 'PARTITION';
KW_TABLE: 'TABLE';
KW_DIRECTORY: 'DIRECTORY';
KW_LOCAL: 'LOCAL';
KW_EXPLAIN: 'EXPLAIN';
KW_EXTENDED: 'EXTENDED';
KW_FORMATTED: 'FORMATTED';

// Operators
// NOTE: if you add a new function/operator, add it to sysFuncNames so that describe function _FUNC_ will work.

DOT : '.'; // generated as a part of Number rule
COMMA : ',' ;

LPAREN : '(' ;
RPAREN : ')' ;
EQUAL : '=' | '==';
PLUS : '+';
MINUS : '-';
STAR : '*';

// LITERALS
fragment
Letter
    : 'a'..'z' | 'A'..'Z'
    ;

fragment
HexDigit
    : 'a'..'f' | 'A'..'F'
    ;

fragment
Digit
    : '0'..'9'
    ;

fragment
Exponent
    : ('e' | 'E') ( PLUS|MINUS )? (Digit)+
    ;

StringLiteral
    : ( '\'' ( ~('\''|'\\') | ('\\' .) )* '\''
    | '\"' ( ~('\"'|'\\') | ('\\' .) )* '\"'
    )+
    ;

CharSetLiteral
    :
    StringLiteral
    | '0' 'X' (HexDigit|Digit)+
    ;

BigintLiteral
    :
    (Digit)+ 'L'
    ;

SmallintLiteral
    :
    (Digit)+ 'S'
    ;

TinyintLiteral
    :
    (Digit)+ 'Y'
    ;

Number
    :
    (Digit)+ ( DOT (Digit)* (Exponent)? | Exponent)?
    ;

Identifier
    :
    (Letter | Digit) (Letter | Digit | '_')*
    ;

CharSetName
    :
    '_' (Letter | Digit | '_' | '-' | '.' | ':' )+
    ;

WS  :  (' '|'\r'|'\t'|'\n') {$channel=HIDDEN;}
    ;

