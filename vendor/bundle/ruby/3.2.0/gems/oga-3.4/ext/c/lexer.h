#ifndef LIBOGA_XML_LEXER_H
#define LIBOGA_XML_LEXER_H

#include "liboga.h"

extern void Init_liboga_xml_lexer();

typedef struct {
    int act;
    int cs;
    int lines;
    int stack[4];
    int top;
} OgaLexerState;

#endif
