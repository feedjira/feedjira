/* ox.h
 * Copyright (c) 2011, Peter Ohler
 * All rights reserved.
 */

#ifndef OX_H
#define OX_H

#if defined(__cplusplus)
extern "C" {
#if 0
} /* satisfy cc-mode */
#endif
#endif

#define RSTRING_NOT_MODIFIED

#include "ruby.h"
#include "ruby/encoding.h"

#if HAVE_RUBY_ST_H
#include "ruby/st.h"
#else
// Only on travis, local is where it is for all others. Seems to vary depending on the travis machine picked up.
#include "st.h"
#endif

#include "attr.h"
#include "err.h"
#include "helper.h"
#include "slotcache.h"
#include "type.h"

#define raise_error(msg, xml, current) _ox_raise_error(msg, xml, current, __FILE__, __LINE__)

#define MAX_TEXT_LEN 4096

#define SILENT 0
#define TRACE 1
#define DEBUG 2

#define XSD_DATE 0x0001
#define WITH_XML 0x0002
#define WITH_INST 0x0004
#define WITH_DTD 0x0008
#define CIRCULAR 0x0010

#define XSD_DATE_SET 0x0100
#define WITH_XML_SET 0x0200
#define WITH_INST_SET 0x0400
#define WITH_DTD_SET 0x0800
#define CIRCULAR_SET 0x1000

typedef enum {
    UseObj       = 1,
    UseAttr      = 2,
    UseAttrSet   = 3,
    UseArray     = 4,
    UseAMember   = 5,
    UseHash      = 6,
    UseHashKey   = 7,
    UseHashVal   = 8,
    UseRange     = 9,
    UseRangeAttr = 10,
    UseRaw       = 11,
} Use;

typedef enum {
    StrictEffort   = 's',
    TolerantEffort = 't',
    AutoEffort     = 'a',
    NoEffort       = 0,
} Effort;

typedef enum { Yes = 'y', No = 'n', NotSet = 0 } YesNo;

typedef enum { ObjMode = 'o', GenMode = 'g', LimMode = 'l', HashMode = 'h', HashNoAttrMode = 'n', NoMode = 0 } LoadMode;

typedef enum {
    OffSkip = 'o',
    NoSkip  = 'n',
    CrSkip  = 'r',
    SpcSkip = 's',
} SkipMode;

typedef struct _pInfo *PInfo;

typedef struct _parseCallbacks {
    void (*instruct)(PInfo pi, const char *target, Attr attrs, const char *content);
    void (*add_doctype)(PInfo pi, const char *docType);
    void (*add_comment)(PInfo pi, const char *comment);
    void (*add_cdata)(PInfo pi, const char *cdata, size_t len);
    void (*add_text)(PInfo pi, char *text, int closed);
    void (*add_element)(PInfo pi, const char *ename, Attr attrs, int hasChildren);
    void (*end_element)(PInfo pi, const char *ename);
    void (*finish)(PInfo pi);
} *ParseCallbacks;

typedef struct _circArray {
    VALUE         obj_array[1024];
    VALUE        *objs;
    unsigned long size; /* allocated size or initial array size */
    unsigned long cnt;
} *CircArray;

typedef struct _options {
    char           encoding[64];     // encoding, stored in the option to avoid GC invalidation in default values
    char           margin[128];      // left margin for dumping
    int            indent;           // indention for dump, default 2
    int            trace;            // trace level
    char           margin_len;       // margin length
    char           with_dtd;         // YesNo
    char           with_xml;         // YesNo
    char           with_instruct;    // YesNo
    char           circular;         // YesNo
    char           xsd_date;         // YesNo
    char           mode;             // LoadMode
    char           effort;           // Effort
    char           sym_keys;         // symbolize keys
    char           skip;             // skip mode
    char           smart;            // YesNo sax smart mode
    char           convert_special;  // boolean true or false
    char           allow_invalid;    // YesNo
    char           no_empty;         // boolean - no empty elements when dumping
    char           with_cdata;       // boolean - hash_load should include cdata
    char           inv_repl[12];     // max 10 valid characters, first character is the length
    char           strip_ns[64];     // namespace to strip, \0 is no-strip, \* is all, else only matches
    struct _hints *html_hints;       // html hints
    VALUE          attr_key_mod;
    VALUE          element_key_mod;
    rb_encoding   *rb_enc;
} *Options;

// parse information structure
struct _pInfo {
    struct _helperStack helpers;
    struct _err         err;
    char               *str;  // buffer being read from
    char               *end;  // end of original string
    char               *s;    // current position in buffer
    VALUE               obj;
    ParseCallbacks      pcb;
    CircArray           circ_array;
    unsigned long       id;  // set for text types when cirs_array is set
    Options             options;
    VALUE              *marked;
    int                 mark_size;  // allocated size
    int                 mark_cnt;
    char                last;  // last character read, rarely set
};

extern VALUE ox_parse(char *xml, size_t len, ParseCallbacks pcb, char **endp, Options options, Err err);
extern void  _ox_raise_error(const char *msg, const char *xml, const char *current, const char *file, int line);

extern void ox_sax_define(void);

extern char *ox_write_obj_to_str(VALUE obj, Options copts);
extern void  ox_write_obj_to_file(VALUE obj, const char *path, Options copts);

extern struct _options ox_default_options;

extern VALUE Ox;

extern ID ox_abort_id;
extern ID ox_at_column_id;
extern ID ox_at_content_id;
extern ID ox_at_id;
extern ID ox_at_line_id;
extern ID ox_at_pos_id;
extern ID ox_at_value_id;
extern ID ox_attr_id;
extern ID ox_attr_value_id;
extern ID ox_attrs_done_id;
extern ID ox_attributes_id;
extern ID ox_beg_id;
extern ID ox_bigdecimal_id;
extern ID ox_call_id;
extern ID ox_cdata_id;
extern ID ox_comment_id;
extern ID ox_den_id;
extern ID ox_doctype_id;
extern ID ox_end_element_id;
extern ID ox_end_id;
extern ID ox_end_instruct_id;
extern ID ox_error_id;
extern ID ox_excl_id;
extern ID ox_external_encoding_id;
extern ID ox_fileno_id;
extern ID ox_force_encoding_id;
extern ID ox_inspect_id;
extern ID ox_instruct_id;
extern ID ox_jd_id;
extern ID ox_keys_id;
extern ID ox_local_id;
extern ID ox_mesg_id;
extern ID ox_message_id;
extern ID ox_new_id;
extern ID ox_nodes_id;
extern ID ox_num_id;
extern ID ox_parse_id;
extern ID ox_pos_id;
extern ID ox_read_id;
extern ID ox_readpartial_id;
extern ID ox_start_element_id;
extern ID ox_string_id;
extern ID ox_text_id;
extern ID ox_to_c_id;
extern ID ox_value_id;

extern rb_encoding *ox_utf8_encoding;

extern VALUE ox_empty_string;
extern VALUE ox_encoding_sym;
extern VALUE ox_indent_sym;
extern VALUE ox_size_sym;
extern VALUE ox_standalone_sym;
extern VALUE ox_sym_bank;  // Array
extern VALUE ox_version_sym;
extern VALUE ox_zero_fixnum;

extern VALUE ox_date_class;
extern VALUE ox_stringio_class;
extern VALUE ox_struct_class;
extern VALUE ox_time_class;

extern VALUE ox_document_clas;
extern VALUE ox_element_clas;
extern VALUE ox_instruct_clas;
extern VALUE ox_bag_clas;
extern VALUE ox_comment_clas;
extern VALUE ox_raw_clas;
extern VALUE ox_doctype_clas;
extern VALUE ox_cdata_clas;

extern SlotCache ox_class_cache;

extern void ox_init_builder(VALUE ox);

#if defined(__cplusplus)
#if 0
{ /* satisfy cc-mode */
#endif
} /* extern "C" { */
#endif
#endif /* OX_H */
