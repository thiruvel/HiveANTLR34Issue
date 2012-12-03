package com.yahoo.antlr;

import org.antlr.runtime.*;
import org.antlr.runtime.tree.*;

import java.lang.System;

public class HiveANTLRTest {
    public static void main(String[] args) {
//        String query = "insert overwrite local directory '/tmp' select cols from table_y";
        String query = "insert overwrite table table_x partition (dim_1='a', dim_2='b') select cols from table_y";
        String query_2 = "insert overwrite table x select cols from y";

        InsertLexer lexer = new InsertLexer(new ANTLRStringStream(query.toUpperCase()));
        TokenRewriteStream tokens = new TokenRewriteStream(lexer);
        InsertParser parser = new InsertParser(tokens);

        CommonTreeAdaptor adaptor = new CommonTreeAdaptor();
        parser.setTreeAdaptor(adaptor);
        InsertParser.insertClause_return r;

        try {
            r = parser.insertClause();
        } catch (RecognitionException e) {
            throw new RuntimeException("parse exception");
        }

        System.out.println(dump(r.tree));
    }

    private static String dump(CommonTree node) {
        StringBuilder sb = new StringBuilder(256);
        sb.append("( ").append(node.getText());
        int childCount = node.getChildCount();
        if (childCount > 0) {
            for (int i = 0; i < childCount; i++)
            sb.append(dump((CommonTree)node.getChild(i)));
        }
        sb.append(")");
        return sb.toString();
    }
}