%{
/***
* Created by Clark Hathaway for Intro to Compilers (COSC 461, Fall 2021) for HTML2LaTeX
**/

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

int list_type;

// Perform simple translation as: <tag>text</tag> -> \\command{text}
void simple_element(const char *tag, const char *tex) {
    const int tag_len = strlen(tag);

    yytext[yyleng - tag_len - 3] = 0;
    printf("\\%s{%s}", tex, yytext + tag_len + 2);
}

// Perform simple translation as: <tag>text</tag> -> {\\command text}
void simple_font(const char *tag, const char *tex) {
    const int tag_len = strlen(tag);

    yytext[yyleng - tag_len - 3] = 0;
    printf("{\\%s %s}", tex, yytext + tag_len + 2);
}

%}

%option       noyywrap nounput yylineno
%x            COMMENT PARA PRE OL UL LI

%%

"<h1>"[^<]*"</h1>" {
    /**************************************************************************
     * Matched an HTML H1 header so print it out as a LateX section title.
     * The beginning and ending tags need to be stripped off before the
     * title can be formatted in LateX.
     *************************************************************************/
    simple_element("h1", "section");
}

"<h2>"[^<]+"</h2>" {
    /***
    * Matched an HTML H2 header.
    ***/
    simple_element("h2", "subsection");
}

"<h3>"[^<]+"</h3>" {
    /***
    * Matched an HTML H3 header.
    ***/
    simple_element("h3", "subsubsection");
}

"<!--" {
    /**************************************************************************
     * Matched an HTML comment so print it out as a LateX comment. The
     * beginning and ending tags are stripped off before the LateX comment
     * is emitted.
     *************************************************************************/
    printf( "%% " );
    BEGIN COMMENT;
}

"<pre>"[^<]*"</pre>" {
    /**************************************************************************
     * Matched an HTML pre-formatted paragraph so print it out as a LaTeX
     * verbatim environment. The beginning and ending tags need to be stripped
     * off before the paragraph can be formatted in LaTeX.
     *************************************************************************/
     yytext[yyleng-6] = 0;
     printf( "\\begin{verbatim}%s\\end{verbatim}\n", yytext+5 );
}

"<p>" {
    /**************************************************************************
    * Matched the beginning tag of an HTML pararaph element. There may be
    * nested elements inside so we must scan for them or text and print them
    * before matching the closing tag.
    **************************************************************************/
    BEGIN PARA;
}

<PARA>[^<]+/"<" {
    /**************************************************************************
    * Matched text inside a paragraph element. Print the text, including white-
    * space.
    **************************************************************************/
    printf("%s", yytext);
}

<PARA>"</p>" {
    /**************************************************************************
    * Matched the closing tag of a paragraph element.
    **************************************************************************/
    printf("\n\n");
    BEGIN 0;
}

"<ol>" {
    /***
    * Matched an HTML ordered list element.
    ***/
    printf("\\begin{enumerate}\n");
    BEGIN OL;
}

<OL>[^<]+/"<" {
    /***
    * Matched text inside an HTML ordered list element.
    * Do nothing.
    ***/
}

<OL>"</ol>" {
    /***
    * Matched the closing tag of an HTML ordered list element.
    */
    printf("\\end{enumerate}\n");
    BEGIN 0;
}

"<ul>" {
    /***
    * Matched an HTML unordered list.
    ***/
    printf("\\begin{itemize}\n");
    BEGIN UL;
}

<UL>[^<]+/"<" {
    /***
    * Matched text inside an unordered list element.
    * Do nothing.
    ***/
}

<UL>"</ul>" {
    /***
    * Matched the closing tag of an unordered list.
    ***/
    printf("\\end{itemize}\n");
    BEGIN 0;
}

<OL>"<li>" {
    /***
    * Matched a list item inside an ordered list element.
    ***/
    printf("%4s%s", " ", "\\item ");
    list_type = 0;
    BEGIN LI;
}

<UL>"<li>" {
    /***
    * Matched a list item inside an unordered list element.
    ***/
    printf("%4s%s", " ", "\\item ");
    list_type = 1;
    BEGIN LI;
}

<LI>[^<]+/"<" {
    /***
    * Matched the text inside a list item element.
    ***/
    printf("%s", yytext);
}

<LI>"</li>" {
    /***
    * Matched the closing tag of a list item element.
    ***/
    printf("\n\n");
    if (list_type)
        BEGIN UL;
    else
        BEGIN OL;
}

<PARA,OL,UL,LI>"<small>"[^<]+"</small>" {
    /***
    * Match an HTML small text element.
    ***/
    simple_font("small", "scriptsize");
}

<PARA,OL,UL,LI>"<big>"[^<]+"</big>" {
    /***
    * Match an HTML large text element.
    ***/
    simple_font("big", "Large");
}

<PARA,OL,UL,LI>"<b>"[^<]+"</b>" {
    /***
    * Match an HTML boldface text element.
    ***/
    simple_element("b", "textbf");
}

<PARA,OL,UL,LI>"<i>"[^<]+"</i>" {
    /***
    * Match an HTML italics text element.
    ***/
    simple_element("i", "textit");
}

<PARA,OL,UL,LI>"<strong>"[^<]+"</strong>" {
    /***
    * Match an HTML strong text element.
    ***/
    simple_element("strong", "textmd");
}

<PARA,OL,UL,LI>"<em>"[^<]+"</em>" {
    /***
    * Match an HTML emphasized text element.
    ***/
    simple_element("em", "emph");
}

<PARA,OL,UL,LI>"<sup>"[^<]+"</sup"> {
    /***
    * Matched an HTML superscript element.
    ***/
    simple_element("sup", "textsuperscript");
}

<PARA,OL,UL,LI>"<sub>"[^<]+"</sub>" {
    /***
    * Matched an HTML subscript element.
    ***/
    simple_element("sub", "textsubscript");
}

[ \t\n\r]+ {
    /**************************************************************************
     * Matched some whitespace that is not inside of an HTML tag. We
     * just ignore the whitespace.
     *************************************************************************/
}

. {
    /**************************************************************************
     * Matched something that we did not expect to see. Issue an error and
     * exit the program with a failure code.
     *************************************************************************/
    fprintf( stderr, "Unexpected input at line %d: '%s'\n", yylineno, yytext );
    exit( 1 );
}

<COMMENT>"-->" {
    /**************************************************************************
     * Matched an HTML end comment while parsing an HTML comment. Print out
     * a new line and resume normal parsing.
     *************************************************************************/
    printf( "\n" );
    BEGIN 0;
}

<COMMENT>[\n](\r)? {
    /**************************************************************************
     * Matched a newline while parsing an HTML comment. Print out a new
     * line making sure to mark the next line as a comment as well.
     *************************************************************************/
    printf( "\n%% " );
}

<COMMENT>[ \t] {
    /**************************************************************************
     * Matched some white space while parsing an HTML comment. Print out
     * the white space as is.
     *************************************************************************/
    printf( "%s", yytext );
}

<COMMENT>. {
    /**************************************************************************
     * Matched any other text while parsing an HTML comment. Print out
     * the text as is.
     *************************************************************************/
    printf( "%s", yytext );
}

%%

/**************************************************************************
 * The main function for the HTML to LateX converter. Here we do three
 * things:
 *  1. Print out the LateX document header.
 *  2. Invoke the lexer to print out the LateX document
 *  3. Print out the LateX footer.
 *************************************************************************/
int main( int argc, const char *argv[] ) {
    printf( "\\documentclass[12pt]{article}\n" );
    printf( "\\usepackage{fixltx2e}\n" );
    printf( "\n" );
    printf( "\\setlength{\\parindent}{0.0in}\n" );
    printf( "\\setlength{\\parskip}{0.125in}\n" );
    printf( "\n\n" );
    printf( "\\begin{document}\n" );
    yylex();
    printf( "\\end{document}\n" );
    return 0;
}
