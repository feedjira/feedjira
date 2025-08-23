# Changelog

All changes to the Ox gem are documented here. Releases follow semantic versioning.

## [2.14.23] - 2025-05-27

### Changed

- Comments are no longer space padded to be similar with other XML writers.

## [2.14.22] - 2025-02-11

### Fixed

- Fix issue with first text character lost after unquoted attribute value.

## [2.14.21] - 2025-01-15

### Fixed

- Removed internal dependency on BigDecimal. If BigDecimal is use it
  must now be included in the calling code. This was forced by the
  change in BigDecimal no longer being included in the Ruby core.

## [2.14.20] - 2025-01-12

### Fixed

- The instruction encoding attribute is now used to set the encoding in the `:limited` mode.

## [2.14.19] - 2024-12-25

### Fixed

- Code cleanup in sax.c  to close issue #363.

- Updated the dump options documentation to `:with_xml` option to resolve #352.

- Updated the sax tests to pass to resolve #335.

- Element#replace_text on nil `@nodes` no longer fails. Closes #364.

## [2.14.18] - 2024-03-21

### Fixed

- UTF8 element names now load correctly thansk to @Uelb.

## [2.14.17] - 2023-07-14

### Fixed

- The sax parser in html mode now allows unquoted attribute values with complaints.

## [2.14.16] - 2023-04-11

### Fixed

- Window issue with strndup fixed thats to alexanderfast.

## [2.14.15] - 2023-04-10

### Fixed

- Fixed free on moved pointer.

## [2.14.14] - 2023-01-26

### Fixed

- Change free to xfree on ruby alloced memory.

## [2.14.13] - 2023-01-16

### Fixed

- Fixed the intern cache to handle symbol memory changes.

## [2.14.12] - 2022-12-27

### Fixed

- Updated to support Ruby 3.2.

## [2.14.11] - 2022-03-31

### Fixed

- Missing attribute value no longer crashes with the SAX parser.

## [2.14.10] - 2022-03-10

### Fixed

- Writing strings over 16K to a file with builder no longer causes a crash.

## [2.14.9] - 2022-02-11

### Fixed

- Fixed the `\r` replacement with `\n` with the SAX parser according to https://www.w3.org/TR/2008/REC-xml-20081126/#sec-line-ends.

## [2.14.8] - 2022-02-09

### Fixed

- Renamed internal functions to avoid linking issues where Oj and Ox function names collided.

## [2.14.7] - 2022-02-03

### Fixed

- All classes and symbols are now registered to avoid issues with GC compaction movement.
- Parsing of any size processing instruction is now allowed. There is no 1024 limit.
- Fixed the `\r` replacement with `\n` according to https://www.w3.org/TR/2008/REC-xml-20081126/#sec-line-ends.

### Changed

- Symbol and string caching changed but should have no impact on use
  other than being slightly faster and handles large numbers of cached
  items more efficiently.

## [2.14.6] - 2021-11-03

### Fixed

- Closing tags in builder are now escapped correctly thanks to ezekg.

## [2.14.5] - 2021-06-04

### Fixed

- Fixed RDoc for for Ox::Builder.

## [2.14.4] - 2021-03-19

### Fixed

- Really fixed code issue around HAVE_RB_ENC_ASSOCIATE.

## [2.14.3] - 2021-03-12

### Fixed

- Code issue around HAVE_RB_ENC_ASSOCIATE fixed.

## [2.14.2] - 2021-03-07

### Fixed

- Attribute keys for setting attributes no longer create seemily
  duplicates if symbol and string keys are mixed.

## [2.14.1] - 2021-01-11

### Fixed

- In Ruby 3.0 Range objects are frozen. This version allows Ranges to be created on load.

## [2.14.0] - 2020-12-15

### Added

- The `:with_cdata` option added for the hash_load() function.

## [2.13.4] - 2020-09-11

### Fixed

- Fixed one crash that occurred when a corrupted object encoded string was provided.

## [2.13.3] - 2020-09-03

### Changed

- mkmf have macros used instead of ad-hoc determinations.

## [2.13.2] - 2020-02-05

Skip and missed sequence

### Fixed

- Add &apos; sequence.

- `:skip_off` no longer misses spaces between elements.

## [2.13.1] - 2020-01-30

HTML Sequences

### Added

- All HTML 4 sequence are now supported.

## [2.13.0] - 2020-01-25

HTML Escape Sequences

### Added

- All HTML 4 escape sequences are now parsed.

## [2.12.1] - 2020-01-05

Ruby 2.7.0

### Fixed

- Updated for Ruby 2.7.0. More strict type checking. Function signature changes, and `Object#taint` deprecated.

## [2.12.0] - 2019-12-18

### Added

- Add `no_empty` option to not allow <xyz/> and use <xyz></xyz> instead.

## [2.11.0] - 2019-06-14

### Changed
- Ox::SyntaxError replaces SyntaxError where such an exception would have previously been raised.

### Fixed
- File offsets when using the SAX parser now use `off_t`. Setting
  `-D_FILE_OFFSET_BITS=64` in the Makefile may allow 32 bit systems to access
  files larger than 2^32 in size. This has not been tested.

## [2.10.1] - 2019-05-27

### Fixed
- Remove extra space from doctype dump.

## [2.10.0] - 2018-08-26

### Fixed
- `:element_key_mod` and `:attr_key_mod` options were added to allow keys to be modified when loading.

## [2.9.4] - 2018-07-16

### Fixed
- Fixed issue with malformed object mode input.

## [2.9.3] - 2018-06-12

### Fixed
- Handle `\0` in dumped strings better.
- No `\n` added on dumped if indent is less than zero.

## [2.9.2] - 2018-04-16

### Fixed
- `locate` fixed to cover a missing condition with named child thanks to mberlanda.

### Added
- `locate` supports attribute exists searches thanks to mberlanda.

## [2.9.1] - 2018-04-14

### Fixed
- `prepend_child` added by mberlanda.

## [2.9.0] - 2018-03-13

### Added
- New builder methods for building HTML.
- Examples added.

## [2.8.4] - 2018-03-4

### Fixed
- Commented out debug statement.

## [2.8.3] - 2018-03-3

### Fixed
- Attribute values now escape < and > on dump.

## [2.8.2] - 2017-11-1

### Fixed
- Fixed bug with SAX parser that caused a crash with very long invalid instruction element.
- Fixed SAX parse error with double <source> elements.

## [2.8.1] - 2017-10-27

### Fixed
- Avoid crash with invalid XML passed to Ox.parse_obj().

## [2.8.0] - 2017-09-22

### Fixed
- Added :skip_off mode to make sax callback on every none empty string even if there are not other non-whitespace characters present.

## [2.7.0] - 2017-08-18

### Added
- Two new load modes added, :hash and :hash_no_attrs. Both load an XML document to create a Hash populated with core Ruby objects.

### Fixed
- Worked around Ruby API change for RSTRUCT_LEN so Ruby 2.4.2 does not crash.

## [2.6.0] - 2017-08-9

### Added
- The Element#each() method was added to allow iteration over Element nodes conditionally.
- Element#locate() now supports a [@attr=value] specification.
- An underscore character used in the easy API is now treated as a wild card for valid XML characters that are not valid for Ruby method names.

## [2.5.0] - 2017-05-4

### Added
- Added a :nest_ok option to SAX hints that will ignore the nested check on a tag to accomadate non-compliant HTML.

### Changed
- Set the default for skip to be to skip white space.

## [2.4.13] - 2017-04-21

### Fixed
- Corrected Builder special character handling.

## [2.4.12] - 2017-04-11

### Fixed
- Fixed position in builder when encoding special characters.

## [2.4.11] - 2017-03-19

### Fixed
- Fixed SAX parser bug regarding upper case hints not matching.

## [2.4.10] - 2017-02-13

### Fixed
- Dump is now smarter about which characters to replace with &xxx; alternatives.

## [2.4.9] - 2017-01-25

### Added
- Added a SAX hint that allows comments to be treated like other elements.

## [2.4.8] - 2017-01-15

### Changed
- Tolerant mode now allows case-insensitve matches on elements during parsing. Smart mode in the SAX parser is also case insensitive.

## [2.4.7] - 2016-December-25

### Fixed
- After encountering a <> the SAX parser will continue parsing after reporting an error.

## [2.4.6] - 2016-11-28

### Added
- Added margin option to dump.

## [2.4.5] - 2016-09-11

### Fixed
- Thanks to GUI for fixing an infinite loop in Ox::Builder.

## [2.4.4] - 2016-08-9

### Fixed
- Builder element attributes with special characters are now encoded correctly.
- A newline at end of an XML string is now controlled by the indent value. A value of-1 indicates no terminating newline character and an indentation of zero.

## [2.4.3] - 2016-06-26

### Fixed
- Fixed compiler warnings and errors.
- Updated for Ruby 2.4.0.

## [2.4.2] - 2016-06-23

### Fixed
- Added methods to Ox::Builder to provide output position information.

## [2.4.1] - 2016-04-30

### Added
- Added overlay feature to give control over which elements generate callbacks with the SAX parser.
- Element.locate now includes self if the path is relative and starts with a wildcard.

### Fixed
- Made SAX smarter a little smarter or rather let it handle unquoted string with a / at the end.
- Fixed bug with reporting errors of element names that are too long.

## [2.4.0] - 2016-04-14

### Fixed
- Added Ox::Builder that constructs an XML string or writes XML to a stream using builder methods.

## [2.3.0] - 2016-02-21

### Added
- Added Ox::Element.replace_text() method.
- A invalid_replace option has been added. It will replace invalid XML
  character with a provided string. Strict effort now raises an exception if
  an invalid character is encountered on dump or load.

### Changed
- Ox.load and Ox.parse now allow for a callback block to handle multiple top
  level entities in the input.
- The Ox SAX parser now supports strings as input directly without and IO wrapper.

### Fixed
- Ox::Element nodes variable is now always initialized to an empty Array.
- Ox::Element attributes variable is now always initialized to an empty Hash.

## [2.2.4] - 2016-02-4

### Fixed
- Changed the code to allow compilation on older compilers. No change in
  functionality otherwise.

## [2.2.3] - 2015-December-31

### Fixed
- The convert_special option now applies to attributes as well as elements in
  the SAX parser.

- The convert_special option now applies to the regualr parser as well as the
  SAX parser.

- Updated to work correctly with Ruby 2.3.0.

## [2.2.2] - 2015-10-19

### Fixed
- Fixed problem with detecting invalid special character sequences.

- Fixed bug that caused a crash when an <> was encountered with the SAX parser.

## [2.2.1] - 2015-07-30

### Fixed
- Added support to handle script elements in html.

- Added support for position from start for the sax parser.

## [2.2.0] - 2015-04-20

### Fixed
- Added the SAX convert_special option to the default options.

- Added the SAX smart option to the default options.

- Other SAX options are now taken from the defaults if not specified.

## [2.1.8] - 2015-02-10

### Fixed
- Fixed a bug that caused all input to be read before parsing with the sax
  parser and an IO.pipe.

## [2.1.7] - 2015-01-31

### Fixed
- Empty elements such as <foo></foo> are now called back with empty text.

- Fixed GC problem that occurs with the new GC in Ruby 2.2 that garbage
  collects Symbols.

## [2.1.6] - 2014-December-31

### Fixed
- Update licenses. No other changes.

## [2.1.5] - 2014-December-30

### Fixed
- Fixed symbol intern problem with Ruby 2.2.0. Symbols are not dynamic unless
  rb_intern(). There does not seem to be a way to force symbols created with
  encoding to be pinned.

## [2.1.4] - 2014-December-5

### Fixed
- Fixed bug where the parser always started at the first position in a stringio
  instead of the current position.

## [2.1.3] - 2014-07-25

### Fixed
- Added check for @attributes being nil. Reported by and proposed fix by Elana.

## [2.1.2] - 2014-07-17

### Fixed
- Added skip option to parsing. This allows white space to be collapsed in two
  different ways.

- Added respond_to? method for easy access method checking.

## [2.1.1] - 2014-02-12

### Fixed
- Worked around a module reset and clear that occurs on some Rubies.

## [2.1.0] - 2014-02-2

### Fixed
- Thanks to jfontan Ox now includes support for XMLRPC.

## [2.0.12] - 2013-05-21

### Fixed
- Fixed problem compiling with latest version of Rubinius.

## [2.0.11] - 2013-10-17

### Fixed
- Added support for BigDecimals in :object mode.

## [10.2.10]

### Fixed
- Small fix to not create an empty element from a closed element when using locate().

- Fixed to keep objects from being garbages collected in Ruby 2.x.

## [2.0.9] - 2013-09-2

### Fixed
- Fixed bug that did not allow ISO-8859-1 characters and caused a crash.

## [2.0.8] - 2013-08-6

### Fixed
- Allow single quoted strings in all modes.

## [2.0.7] - 2013-08-4

### Fixed
- Fixed DOCTYPE parsing to handle nested '>' characters.

## [2.0.6] - 2013-07-23

### Fixed
- Fixed bug in special character decoding that chopped of text.

- Limit depth on dump to 1000 to avoid core dump on circular references if the user does not specify circular.

- Handles dumping non-string values for attributes correctly by converting the value to a string.

## [2.0.5] - 2013-07-5

### Fixed
- Better support for special character encoding with 1.8.7.- February 8, 2013

## [2.0.4] - 2013-06-24

### Fixed
- Fixed SAX parser handling of &#nnnn; encoded characters.

## [2.0.3] - 2013-06-12

### Fixed
- Fixed excessive memory allocation issue for very large file parsing (half a gig).

## [2.0.2] - 2013-06-7

### Fixed
- Fixed buffer sliding window off by 1 error in the SAX parser.

## [1] -2-.0

### Fixed
- Added an attrs_done callback to the sax parser that will be called when all
   attributes for an element have been read.

- Fixed bug in SAX parser where raising an exception in the handler routines
   would not cleanup. The test put together by griffinmyers was a huge help.

- Reduced stack use in a several places to improve fiber support.

- Changed exception handling to assure proper cleanup with new stack minimizing.

## [2.0.0] - 2013-04-16

### Fixed
- The SAX parser went through a significant re-write. The options have changed. It is now 15% faster on large files and
   much better at recovering from errors. So much so that the tolerant option was removed and is now the default and
   only behavior. A smart option was added however. The smart option recognizes a file as an HTML file and will apply a
   simple set of validation rules that allow the HTML to be parsed more reasonably. Errors will cause callbacks but the
   parsing continues with the best guess as to how to recover. Rubymaniac has helped with testing and prompted the
   rewrite to support parsing HTML pages.

- HTML is now supported with the SAX parser. The parser knows some tags like \<br\> or \<img\> do not have to be
   closed. Other hints as to how to parse and when to raise errors are also included. The parser does it's best to
   continue parsing even after errors.

- Added symbolize option to the sax parser. This option, if set to false will use strings instead of symbols for
   element and attribute names.

- A contrib directory was added for people to submit useful bits of code that can be used with Ox. The first
   contributor is Notezen with a nice way of building XML.

## [1.9.4] - 2013-03-24

### Fixed
- SAX tolerant mode handle multiple elements in a document better.

## [1.9.3] - 2013-03-22

### Fixed
- mcarpenter fixed a compile problem with Cygwin.

- Now more tolerant when the :effort is set to :tolerant. Ox will let all sorts
   of errors typical in HTML documents pass. The result may not be perfect but
   at least parsed results are returned.

 - Attribute values need not be quoted or they can be quoted with single
     quotes or there can be no =value are all.

 - Elements not terminated will be terminated by the next element
     termination. This effect goes up until a match is found on the element
     name.

- SAX parser also given a :tolerant option with the same tolerance as the string parser.

## [1.9.2] - 2013-03-9

### Fixed
- Fixed bug in the sax element name check that cause a memory write error.

## [1.9.1] - 2013-02-27

### Fixed
- Fixed the line numbers to be the start of the elements in the sax parser.

## [1.9.0] - 2013-02-25

### Fixed
- Added a new feature to Ox::Element.locate() that allows filtering by node Class.

- Added feature to the Sax parser. If @line is defined in the handler it is set to the line number of the xml file
  before making callbacks. The same goes for @column but it is updated with the column.

## [1.8.9] - 2013-02-21

### Fixed
- Fixed bug in element start and end name checking.

## [1.8.8] - 2013-02-17

### Fixed
- Fixed bug in check for open and close element names matching.

## [7] -1-.8

### Fixed
- Added a correct check for element open and close names.

- Changed raised Exceptions to customer classes that inherit from StandardError.

- Fixed a few minor bugs.

## [1.8.6] - 2013-02-7

### Fixed
- Removed broken check for matching start and end element names in SAX mode. The names are still included in the
  handler callbacks so the user can perform the check is desired.

## [1.8.5] - 2013-02-3

### Fixed
- added encoding support for JRuby where possible when in 1.9 mode.

## [1.8.4] - 2013-01-25

### Fixed
- Applied patch by mcarpenter to fix solaris issues with build and remaining undefined @nodes.

## [1.8.3] - 2013-01-24

### Fixed
- Sax parser now honors encoding specification in the xml prolog correctly.

## [1.8.2] - 2013-01-18

### Fixed
- Ox::Element.locate no longer raises and exception if there are no child nodes.

- Dumping an XML document no longer puts a carriage return after processing instructions.

## [1.8.1] - 2012-December-17

### Fixed
- Fixed bug that caused a crash when an invalid xml with two elements and no <?xml?> was parsed. (issue #28)

- Modified the SAX parser to not strip white space from the start of string content.

## [1.8.0] - 2012-December-11

### Fixed
- Added more complete support for processing instructions in both the generic parser and in the sax parser. This change includes and additional sax handler callback for the end of the instruction processing.

## [1.7.1] - 2012-December-6

### Fixed
- Pulled in sharpyfox's changes to make Ox with with Windows. (issue #24)

- Fixed bug that ignored white space only text elements. (issue #26)

## [1.7.0] - 2012-11-27

### Fixed
- Added support for BOM in the SAX parser.

## [1.6.9] - 2012-11-25

### Fixed
- Added support for BOM. They are honored for and handled correctly for UTF-8. Others cause encoding issues with Ruby or raise an error as others are not ASCII compatible..

## [1.6.8] - 2012-11-18

### Fixed
- Changed extconf.rb to use RUBY_PLATFORM.

## [1.6.7] - 2012-11-15

### Fixed
- Now uses the encoding of the imput XML as the default encoding for the parsed output if the default options encoding is not set and the encoding is not set in the XML file prolog.

## [1.6.5] - 2012-10-25

### Fixed
- Special character handling now supports UCS-2 and UCS-4 Unicode characters as well as UTF-8 characters.

## [1.6.4] - 2012-10-24

### Fixed
- Special character handling has been improved. Both hex and base 10 numeric values are allowed up to a 64 bit number
  for really long UTF-8 characters.

## [1.6.3] - 2012-10-22

### Fixed
- Fixed compatibility issues with Linux (Ubuntu) mostly related to pointer sizes.

## [1.6.2] - 2012-10-7

### Fixed
- Added check for Solaris and Linux builds to not use the timezone member of time struct (struct tm).

## [1.6.1] - 2012-10-7

### Fixed
- Added check for Solaris builds to not use the timezone member of time struct (struct tm).
