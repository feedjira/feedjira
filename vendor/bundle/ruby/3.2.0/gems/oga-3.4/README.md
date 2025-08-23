# Oga

**NOTE:** my spare time is limited which means I am unable to dedicate a lot of
time on Oga. If you're interested in contributing to FOSS, please take a look at
the open issues and submit a pull request to address them where possible.

Oga is an XML/HTML parser written in Ruby. It provides an easy to use API for
parsing, modifying and querying documents (using XPath expressions). Oga does
not require system libraries such as libxml, making it easier and faster to
install on various platforms. To achieve better performance Oga uses a small,
native extension (C for MRI/Rubinius, Java for JRuby).

Oga provides an API that allows you to safely parse and query documents in a
multi-threaded environment, without having to worry about your applications
blowing up.

From [Wikipedia][oga-wikipedia]:

> Oga: A large two-person saw used for ripping large boards in the days before
> power saws. One person stood on a raised platform, with the board below him,
> and the other person stood underneath them.

The name is a pun on [Nokogiri][nokogiri].

## Versioning Policy

Oga uses the version format `MAJOR.MINOR` (e.g. `2.1`). An increase of the MAJOR
version indicates backwards incompatible changes were introduced. The MINOR
version is _only_ increased when changes are backwards compatible, regardless of
whether those changes are bugfixes or new features. Up until version 1.0 the
code should be considered unstable meaning it can change (and break) at any
given moment.

APIs explicitly tagged as private (e.g. using Ruby's `private` keyword or YARD's
`@api private` tag) are not covered by these rules.

## Examples

Parsing a simple string of XML:

    Oga.parse_xml('<people><person>Alice</person></people>')

Parsing XML using strict mode (disables automatic tag insertion):

    Oga.parse_xml('<people>foo</people>', :strict => true) # works fine
    Oga.parse_xml('<people>foo', :strict => true)          # throws an error

Parsing a simple string of HTML:

    Oga.parse_html('<link rel="stylesheet" href="foo.css">')

Parsing an IO handle pointing to XML (this also works when using
`Oga.parse_html`):

    handle = File.open('path/to/file.xml')

    Oga.parse_xml(handle)

Parsing an IO handle using the pull parser:

    handle = File.open('path/to/file.xml')
    parser = Oga::XML::PullParser.new(handle)

    parser.parse do |node|
      parser.on(:text) do
        puts node.text
      end
    end

Using an Enumerator to download and parse an XML document on the fly:

    enum = Enumerator.new do |yielder|
      HTTPClient.get('http://some-website.com/some-big-file.xml') do |chunk|
        yielder << chunk
      end
    end

    document = Oga.parse_xml(enum)

Parse a string of XML using the SAX parser:

    class ElementNames
      attr_reader :names

      def initialize
        @names = []
      end

      def on_element(namespace, name, attrs = {})
        @names << name
      end
    end

    handler = ElementNames.new

    Oga.sax_parse_xml(handler, '<foo><bar></bar></foo>')

    handler.names # => ["foo", "bar"]

Querying a document using XPath:

    document = Oga.parse_xml <<-EOF
    <people>
      <person id="1">
        <name>Alice</name>
        <age>28</name>
      </person>
    </people>
    EOF

    # The "xpath" method returns an enumerable (Oga::XML::NodeSet) that you can
    # iterate over.
    document.xpath('people/person').each do |person|
      puts person.get('id') # => "1"

      # The "at_xpath" method returns a single node from a set, it's the same as
      # person.xpath('name').first.
      puts person.at_xpath('name').text # => "Alice"
    end

Querying the same document using CSS:

    document = Oga.parse_xml <<-EOF
    <people>
      <person id="1">
        <name>Alice</name>
        <age>28</name>
      </person>
    </people>
    EOF

    # The "css" method returns an enumerable (Oga::XML::NodeSet) that you can
    # iterate over.
    document.css('people person').each do |person|
      puts person.get('id') # => "1"

      # The "at_css" method returns a single node from a set, it's the same as
      # person.css('name').first.
      puts person.at_css('name').text # => "Alice"
    end

Modifying a document and serializing it back to XML:

    document = Oga.parse_xml('<people><person>Alice</person></people>')
    name     = document.at_xpath('people/person[1]/text()')

    name.text = 'Bob'

    document.to_xml # => "<people><person>Bob</person></people>"

Querying a document using a namespace:

    document = Oga.parse_xml('<root xmlns:x="foo"><x:div></x:div></root>')
    div      = document.xpath('root/x:div').first

    div.namespace # => Namespace(name: "x" uri: "foo")

## Features

* Support for parsing XML and HTML(5)
  * DOM parsing
  * Stream/pull parsing
  * SAX parsing
* Low memory footprint
* High performance (taking into account most work happens in Ruby)
* Support for XPath 1.0
* CSS3 selector support
* XML namespace support (registering, querying, etc)
* Windows support

## Requirements

| Ruby     | Required      | Recommended |
|:---------|:--------------|:------------|
| MRI      | >= 2.3.0      | >= 2.6.0    |
| JRuby    | >= 1.7        | >= 1.7.12   |
| Rubinius | Not supported |             |
| Maglev   | Not supported |             |
| Topaz    | Not supported |             |
| mruby    | Not supported |             |

Maglev and Topaz are not supported due to the lack of a C API (that I know of)
and the lack of active development of these Ruby implementations. mruby is not
supported because it's a very different implementation all together.

To install Oga on MRI or Rubinius you'll need to have a working compiler such as
gcc or clang. Oga's C extension can be compiled with both. JRuby does not
require a compiler as the native extension is compiled during the Gem building
process and bundled inside the Gem itself.

## Thread Safety

Oga does not use a unsynchronized global mutable state. As a result of this you
can parse/create documents concurrently without any problems. Modifying
documents concurrently can lead to bugs as these operations are not
synchronized.

Some querying operations will cache data in instance variables, without
synchronization. An example is `Oga::XML::Element#namespace` which will cache an
element's namespace after the first call.

In general it's recommended to _not_ use the same document in multiple threads
at the same time.

## Namespace Support

Oga fully supports parsing/registering XML namespaces as well as querying them
using XPath. For example, take the following XML:

    <root xmlns="http://example.com">
        <bar>bar</bar>
    </root>

If one were to try and query the `bar` element (e.g. using XPath `root/bar`)
they'd end up with an empty node set. This is due to `<root>` defining an
alternative default namespace. Instead you can query this element using the
following XPath:

    *[local-name() = "root"]/*[local-name() = "bar"]

Alternatively, if you don't really care where the `<bar>` element is located you
can use the following:

    descendant::*[local-name() = "bar"]

And if you want to specify an explicit namespace URI, you can use this:

    descendant::*[local-name() = "bar" and namespace-uri() = "http://example.com"]

Like Nokogiri, Oga provides a way to create "dynamic" namespaces.
That is, Oga allows one to query the above document as following:

    document = Oga.parse_xml('<root xmlns="http://example.com"><bar>bar</bar></root>')

    document.xpath('x:root/x:bar', namespaces: {'x' => 'http://example.com'})

Moreover, because Oga assigns the name "xmlns" to default namespaces you can use
this in your XPath queries:

    document = Oga.parse_xml('<root xmlns="http://example.com"><bar>bar</bar></root>')

    document.xpath('xmlns:root/xmlns:bar')

When using this you can still restrict the query to the correct namespace URI:

    document.xpath('xmlns:root[namespace-uri() = "http://example.com"]/xmlns:bar')

## HTML5 Support

Oga fully supports HTML5 including the omission of certain tags. For example,
the following is parsed just fine:

    <li>Hello
    <li>World

This is effectively parsed into:

    <li>Hello</li>
    <li>World</li>

One exception Oga makes is that it does _not_ automatically insert `html`,
`head` and `body` tags. Automatically inserting these tags requires a
distinction between documents and fragments as a user might not always want
these tags to be inserted if left out. This complicates the user facing API as
well as complicating the parsing internals of Oga. As a result I have decided
that Oga _does not_ insert these tags when left out.

A more in depth explanation can be found here:
<https://gitlab.com/yorickpeterse/oga/issues/98#note_45443992>

## Documentation

The documentation is best viewed [on the documentation website][doc-website].

* {file:CONTRIBUTING Contributing}
* {file:changelog Changelog}
* {file:migrating\_from\_nokogiri Migrating From Nokogiri}
* {Oga::XML::Parser XML Parser}
* {Oga::XML::SaxParser XML SAX Parser}
* {file:xml\_namespaces XML Namespaces}

## Why Another HTML/XML parser?

Currently there are a few existing parser out there, the most famous one being
[Nokogiri][nokogiri]. Another parser that's becoming more popular these days is
[Ox][ox]. Ruby's standard library also comes with REXML.

The sad truth is that these existing libraries are problematic in their own
ways. Nokogiri for example is extremely unstable on Rubinius. On MRI it works
because of the non concurrent nature of MRI, on JRuby it works because it's
implemented as Java. Nokogiri also uses libxml2 which is a massive beast of a
library, is not thread-safe and problematic to install on certain platforms
(apparently). I don't want to compile libxml2 every time I install Nokogiri
either.

To give an example about the issues with Nokogiri on Rubinius (or any other
Ruby implementation that is not MRI or JRuby), take a look at these issues:

* <https://github.com/rubinius/rubinius/issues/2957>
* <https://github.com/rubinius/rubinius/issues/2908>
* <https://github.com/rubinius/rubinius/issues/2462>
* <https://github.com/sparklemotion/nokogiri/issues/1047>
* <https://github.com/sparklemotion/nokogiri/issues/939>

Some of these have been fixed, some have not. The core problem remains:
Nokogiri acts in a way that there can be a large number of places where it
*might* break due to throwing around void pointers and what not and expecting
that things magically work. Note that I have nothing against the people running
these projects, I just heavily, *heavily* dislike the resulting codebase one
has to deal with today.

Ox looks very promising but it lacks a rather crucial feature: parsing HTML
(without using a SAX API). It's also again a C extension making debugging more
of a pain (at least for me).

I just want an XML/HTML parser that I can rely on stability wise and that is
written in Ruby so I can actually debug it. In theory it should also make it
easier for other Ruby developers to contribute.

## License

All source code in this repository is subject to the terms of the Mozilla Public
License, version 2.0 unless stated otherwise. A copy of this license can be
found the file "LICENSE" or at <https://www.mozilla.org/MPL/2.0/>.

[nokogiri]: https://github.com/sparklemotion/nokogiri
[oga-wikipedia]: https://en.wikipedia.org/wiki/Japanese_saw#Other_Japanese_saws
[ox]: https://github.com/ohler55/ox
[doc-website]: http://code.yorickpeterse.com/oga/latest/
