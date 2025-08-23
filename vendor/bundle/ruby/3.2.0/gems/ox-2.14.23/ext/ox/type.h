/* type.h
 * Copyright (c) 2011, Peter Ohler
 * All rights reserved.
 */

#ifndef OX_TYPE_H
#define OX_TYPE_H

typedef enum {
    NoCode         = 0,
    ArrayCode      = 'a',
    String64Code   = 'b', /* base64 encoded String */
    ClassCode      = 'c',
    Symbol64Code   = 'd', /* base64 encoded Symbol */
    DateCode       = 'D',
    BigDecimalCode = 'B',
    ExceptionCode  = 'e',
    FloatCode      = 'f',
    RegexpCode     = 'g',
    HashCode       = 'h',
    FixnumCode     = 'i',
    BignumCode     = 'j',
    KeyCode        = 'k', /* indicates the value is a hash key, kind of a hack */
    RationalCode   = 'l',
    SymbolCode     = 'm',
    FalseClassCode = 'n',
    ObjectCode     = 'o',
    RefCode        = 'p',
    RangeCode      = 'r',
    StringCode     = 's',
    TimeCode       = 't',
    StructCode     = 'u',
    ComplexCode    = 'v',
    RawCode        = 'x',
    TrueClassCode  = 'y',
    NilClassCode   = 'z',
} Type;

#endif /* OX_TYPE_H */
