Apache Hive 0.9 and 0.10 uses ANTLR 3.0.1 to build their grammar Hive.g. When we tried to upgrade antlr to 3.4, many of our test cases failed. We realized that the AST generated in 3.0.1 (and upto 3.2) is different from what is generated using 3.3 onwards. This does not happen for all of the Hive's rules, happens only for some of them. I have included one rule here in Insert.g (subset of Hive.g). The program HiveANTLRTest will dump the tree after parsing a Hive query. When this project is compiled with different versions of antlr, one would see a different tree.

mvn clean test -Dantlr.version=3.2
...
[INFO] --- antlr3-maven-plugin:3.2:antlr (default) @ com.yahoo.antlr ---
[INFO] ANTLR: Processing source directory /Users/thiruvel/Projects/hive/antlr/com.yahoo.antlr/src/main/antlr3
ANTLR Parser Generator  Version 3.2 Sep 23, 2009 14:05:07
com/yahoo/antlr/Insert.g
[INFO] 
...
-------------------------------------------------------
 T E S T S
-------------------------------------------------------
..
[INFO] --- exec-maven-plugin:1.2.1:java (default) @ com.yahoo.antlr ---
( TOK_DESTINATION( TOK_TAB( TOK_TABNAME( TABLE_X))( TOK_PARTSPEC( TOK_PARTVAL( DIM_1)( 'A'))( TOK_PARTVAL( DIM_2)( 'B')))))
[INFO] ------------------------------------------------------------------------
..

mvn clean test -Dantlr.version=3.3
...
[INFO] ANTLR: Processing source directory /Users/thiruvel/Projects/hive/antlr/com.yahoo.antlr/src/main/antlr3
ANTLR Parser Generator  Version 3.3 Nov 30, 2010 12:46:29
com/yahoo/antlr/Insert.g
[INFO] 
...
-------------------------------------------------------
 T E S T S
-------------------------------------------------------
...
[INFO] --- exec-maven-plugin:1.2.1:java (default) @ com.yahoo.antlr ---
( TOK_DESTINATION( TOK_TAB))
..

mvn clean test -Dantlr.version=3.4
..
[INFO] --- antlr3-maven-plugin:3.4:antlr (default) @ com.yahoo.antlr ---
[INFO] ANTLR: Processing source directory /Users/thiruvel/Projects/hive/antlr/com.yahoo.antlr/src/main/antlr3
ANTLR Parser Generator  Version 3.4
com/yahoo/antlr/Insert.g
[INFO] 
..
-------------------------------------------------------
 T E S T S
-------------------------------------------------------
..
[INFO] --- exec-maven-plugin:1.2.1:java (default) @ com.yahoo.antlr ---
( TOK_DESTINATION( TOK_TAB))
..
