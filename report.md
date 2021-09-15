# HTML2LaTeX Project Report

## Problem Statement
This project seeks to develop a Lex program that can read HTML tags as input and produce the
appropriate LaTeX commands as output. This is not only a 1-to-1 conversion of these tags to
commands but also a recursive parsing of nested elements. Additionally, this program is developed
against a solution executable that provides a reference translation and formatting scheme.

## The Solution
### Using Lex
Essentially, every translation rule in a Lex program matches a regular expression in the input
and associates it with an action to be taken. When the expression is matched and the action is
called, a simple C procedure is called to perform the translation. There are many benefits to
Lex's approach but for the purposes of how this program is developed, the most important is
the concept of states.

### Automata Theory
In Lex, every translation rule corresponds to a finite automaton -- or, rather, the set of mutually
equivalent automata that recognize the expression. While the use of C code fragments makes any Lex
program Turing Complete, it is the finite automata that recognize the regular expression to be 
matched that allows for nested tags to be handled. Lex has a feature where each action can have
the program enter a state. At the beginning of the program, we define several mutually exclusive
states for the four contexts where there are nested tags: PARA, UL, OL, and LI. By entering the
state corresponding to the HTML tag, the formatting for the inner text & nested elements can be
handled in a manner specific to the outer element.

### Other Notable Implementation Details
* Because ordered and unordered lists both have list items but differ in the corresponding LaTeX
expression to use, they must each have their own state and a global variable is used to store
the type of list for when the list item (LI) state needs to be transitioned back to the UL or OL state.
* Helper functions were defined in the first section of the program to assist in common replacements
for elements in order to save time and avoid redundant code.

## Debugging & Problem Solving
Initially I used the PDF to find glaring errors in the program. Illegal LaTeX commands and incorrect
formatting of font sizes were apparent. Once these became more subtle, I did away with the makefile
test target and only used the actual LaTeX output instead of the PDF format. Using `diff`, it became
easy to identify missing newline characters and other minor mistakes in the output. Working line by
line, these errors were traced back to the translation rule and quickly solved.

## Issues in Completing the Assignment
The most difficult problems were the earliest ones. Determining how to use the states in Lex & using
multiple states for a pattern, among other quirks of the starter code were difficult to glean from
the textbook for the course or any documented material online, including the incomplete documentation
on the official website. After finding the necessary supplemental resources, these issues became
clear. Matching the text with the solution output was tedious, however.