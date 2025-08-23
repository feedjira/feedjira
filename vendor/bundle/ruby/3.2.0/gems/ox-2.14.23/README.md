# Ox gem
A fast XML parser and Object marshaller as a Ruby gem.

[![CI](https://github.com/ohler55/ox/actions/workflows/CI.yml/badge.svg)](https://github.com/ohler55/ox/actions/workflows/CI.yml)

## Installation
    gem install ox

## Documentation

*Documentation*: http://www.ohler.com/ox

## Source

*GitHub* *repo*: https://github.com/ohler55/ox

*RubyGems* *repo*: https://rubygems.org/gems/ox

## Support

[Get supported Ox with a Tidelift Subscription.](https://tidelift.com/subscription/pkg/rubygems-ox?utm_source=rubygems-ox&utm_medium=referral&utm_campaign=readme) Security updates are [supported](https://tidelift.com/security).

## Links of Interest

[Ruby XML Gem Comparison](http://www.ohler.com/dev/xml_with_ruby/xml_with_ruby.html) for a performance comparison between Ox, Nokogiri, and LibXML.

[Fast Ruby XML Serialization](http://www.ohler.com/dev/ruby_object_xml_serialization/ruby_object_xml_serialization.html) to see how Ox can be used as a faster replacement for Marshal.

*Fast JSON parser and marshaller on RubyGems*: https://rubygems.org/gems/oj

*Fast JSON parser and marshaller on GitHub*: https://github.com/ohler55/oj

## Release Notes

See [CHANGELOG.md](CHANGELOG.md)

## Description

Optimized XML (Ox), as the name implies was written to provide speed optimized
XML and now HTML handling. It was designed to be an alternative to Nokogiri and other Ruby
XML parsers in generic XML parsing and as an alternative to Marshal for Object
serialization.

Unlike some other Ruby XML parsers, Ox is self contained. Ox uses nothing
other than standard C libraries so version issues with libXml are not an
issue.

Marshal uses a binary format for serializing Objects. That binary format
changes with releases making Marshal dumped Object incompatible between some
versions. The use of a binary format make debugging message streams or file
contents next to impossible unless the same version of Ruby and only Ruby is
used for inspecting the serialize Object. Ox on the other hand uses human
readable XML. Ox also includes options that allow strict, tolerant, or a mode
that automatically defines missing classes.

It is possible to write an XML serialization gem with Nokogiri or other XML
parsers but writing such a package in Ruby results in a module significantly
slower than Marshal. This is what triggered the start of Ox development.

Ox handles XML documents in three ways. It is a generic XML parser and writer,
a fast Object / XML marshaller, and a stream SAX parser. Ox was written for
speed as a replacement for Nokogiri, Ruby LibXML, and for Marshal.

As an XML parser it is 2 or more times faster than Nokogiri and as a generic
XML writer it is as much as 20 times faster than Nokogiri. Of course different
files may result in slightly different times.

As an Object serializer Ox is up to 6 times faster than the standard Ruby
Marshal.dump() and up to 3 times faster than Marshal.load().

The SAX like stream parser is 40 times faster than Nokogiri and more than 13
times faster than LibXML when validating a file with minimal Ruby
callbacks. Unlike Nokogiri and LibXML, Ox can be tuned to use only the SAX
callbacks that are of interest to the caller. (See the perf_sax.rb file for an
example.)

Ox is compatible with Ruby 2.3, 2.4, 2.5, 2.6, 2.7, 3.0.

### Object Dump Sample:

```ruby
require 'ox'

class Sample
  attr_accessor :a, :b, :c

  def initialize(a, b, c)
    @a = a
    @b = b
    @c = c
  end
end

# Create Object
obj = Sample.new(1, "bee", ['x', :y, 7.0])
# Now dump the Object to an XML String.
xml = Ox.dump(obj)
# Convert the object back into a Sample Object.
obj2 = Ox.parse_obj(xml)
```

### Generic XML Writing and Parsing:

```ruby
require 'ox'

doc = Ox::Document.new

instruct = Ox::Instruct.new(:xml)
instruct[:version] = '1.0'
instruct[:encoding] = 'UTF-8'
instruct[:standalone] = 'yes'
doc << instruct

top = Ox::Element.new('top')
top[:name] = 'sample'
doc << top

mid = Ox::Element.new('middle')
mid[:name] = 'second'
top << mid

bot = Ox::Element.new('bottom')
bot[:name] = 'third'
bot << 'text at bottom'
mid << bot

other_elements = Ox::Element.new('otherElements')
other_elements << Ox::CData.new('<sender>John Smith</sender>')
other_elements << Ox::Comment.new('Director\'s commentary')
# other_elements << Ox::DocType.new('content')
other_elements << Ox::Raw.new('<warning>Be carefull with this! Direct inject into XML!</warning>')
top << other_elements


xml = Ox.dump(doc)

# xml =
# <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
# <top name="sample">
#   <middle name="second">
#     <bottom name="third">text at bottom</bottom>
#   </middle>
#   <otherElements>
#     <![CDATA[<sender>John Smith</sender>]]>
#     <!-- Director's commentary -->
#     <warning>Be carefull with this! Direct inject into XML!</warning>
#   </otherElements>
# </top>
```

### HTML Parsing:

Ox can be used to parse HTML with a few options changes. HTML is often loose in
regard to conformance. For HTML parsing try these options.

```ruby
Ox.default_options = {
    mode:   :generic,
    effort: :tolerant,
    smart:  true
}
```

### SAX XML Parsing:

```ruby
require 'stringio'
require 'ox'

class Sample < ::Ox::Sax
  def start_element(name); puts "start: #{name}";        end
  def end_element(name);   puts "end: #{name}";          end
  def attr(name, value);   puts "  #{name} => #{value}"; end
  def text(value);         puts "text #{value}";         end
end

io = StringIO.new(%{
<top name="sample">
  <middle name="second">
    <bottom name="third"/>
  </middle>
</top>
})

handler = Sample.new()
Ox.sax_parse(handler, io)
# outputs
# start: top
#   name => sample
# start: middle
#   name => second
# start: bottom
#   name => third
# end: bottom
# end: middle
# end: top
```

### Yielding results immediately while SAX XML Parsing:

```ruby
require 'stringio'
require 'ox'

class Yielder < ::Ox::Sax
  def initialize(block); @yield_to = block; end
  def start_element(name); @yield_to.call(name); end
end

io = StringIO.new(%{
<top name="sample">
  <middle name="second">
    <bottom name="third"/>
  </middle>
</top>
})

proc = Proc.new { |name| puts name }
handler = Yielder.new(proc)
puts "before parse"
Ox.sax_parse(handler, io)
puts "after parse"
# outputs
# before parse
# top
# middle
# bottom
# after parse
```

### Parsing XML into a Hash (fast)

```ruby
require 'ox'

xml = %{
<top name="sample">
  <middle name="second">
    <bottom name="third">Rock bottom</bottom>
  </middle>
</top>
}

puts Ox.load(xml, mode: :hash)
puts Ox.load(xml, mode: :hash_no_attrs)

#{:top=>[{:name=>"sample"}, {:middle=>[{:name=>"second"}, {:bottom=>[{:name=>"third"}, "Rock bottom"]}]}]}
#{:top=>{:middle=>{:bottom=>"Rock bottom"}}}
```

### Object XML format

The XML format used for Object encoding follows the structure of the
Object. Each XML element is encoded so that the XML element name is a type
indicator. Attributes of the element provide additional information such as
the Class if relevant, the Object attribute name, and Object ID if
necessary.

The type indicator map is:

- **a** => `Array`
- **b** => `Base64` - only for legacy loads
- **c** => `Class`
- **f** => `Float`
- **g** => `Regexp`
- **h** => `Hash`
- **i** => `Fixnum`
- **j** => `Bignum`
- **l** => `Rational`
- **m** => `Symbol`
- **n** => `FalseClass`
- **o** => `Object`
- **p** => `Ref`
- **r** => `Range`
- **s** => `String`
- **t** => `Time`
- **u** => `Struct`
- **v** => `Complex`
- **x** => `Raw`
- **y** => `TrueClass`
- **z** => `NilClass`

If the type is an Object, type 'o' then an attribute named 'c' should be set
with the full Class name including the Module names. If the XML element
represents an Object then a sub-elements is included for each attribute of
the Object. An XML element attribute 'a' is set with a value that is the
name of the Ruby Object attribute. In all cases, except for the Exception
attribute hack the attribute names begin with an @ character. (Exception are
strange in that the attributes of the Exception Class are not named with a @
suffix. A hack since it has to be done in C and can not be done through the
interpreter.)

Values are encoded as the text portion of an element or in the sub-elements
of the principle. For example, a Fixnum is encoded as:
```xml
<i>123</i>
```
An Array has sub-elements and is encoded similar to this example.
```xml
<a>
  <i>1</i>
  <s>abc</s>
</a>
```
A Hash is encoded with an even number of elements where the first element is
the key and the second is the value. This is repeated for each entry in the
Hash. An example is of { 1 => 'one', 2 => 'two' } encoding is:
```xml
<h>
  <i>1</i>
  <s>one</s>
  <i>2</i>
  <s>two</s>
</h>
```

Ox supports circular references where attributes of one Object can refer to
an Object that refers back to the first Object. When this option is used an
Object ID is added to each XML Object element as the value of the 'a'
attribute.

## Contributors

### Code Contributors

This project exists thanks to all the people who contribute. [[Contribute](CONTRIBUTING.md)].
<a href="https://github.com/ohler55/ox/graphs/contributors"><img src="https://opencollective.com/ohler/contributors.svg?width=890&button=false" /></a>

### Financial Contributors

Become a financial contributor and help us sustain our community. [[Contribute](https://opencollective.com/ohler/contribute)]

#### Individuals

<a href="https://opencollective.com/ohler"><img src="https://opencollective.com/ohler/individuals.svg?width=890"></a>

#### Organizations

Support this project with your organization. Your logo will show up here with a link to your website. [[Contribute](https://opencollective.com/ohler/contribute)]

<a href="https://opencollective.com/ohler/organization/0/website"><img src="https://opencollective.com/ohler/organization/0/avatar.svg"></a>
<a href="https://opencollective.com/ohler/organization/1/website"><img src="https://opencollective.com/ohler/organization/1/avatar.svg"></a>
<a href="https://opencollective.com/ohler/organization/2/website"><img src="https://opencollective.com/ohler/organization/2/avatar.svg"></a>
<a href="https://opencollective.com/ohler/organization/3/website"><img src="https://opencollective.com/ohler/organization/3/avatar.svg"></a>
<a href="https://opencollective.com/ohler/organization/4/website"><img src="https://opencollective.com/ohler/organization/4/avatar.svg"></a>
<a href="https://opencollective.com/ohler/organization/5/website"><img src="https://opencollective.com/ohler/organization/5/avatar.svg"></a>
<a href="https://opencollective.com/ohler/organization/6/website"><img src="https://opencollective.com/ohler/organization/6/avatar.svg"></a>
<a href="https://opencollective.com/ohler/organization/7/website"><img src="https://opencollective.com/ohler/organization/7/avatar.svg"></a>
<a href="https://opencollective.com/ohler/organization/8/website"><img src="https://opencollective.com/ohler/organization/8/avatar.svg"></a>
<a href="https://opencollective.com/ohler/organization/9/website"><img src="https://opencollective.com/ohler/organization/9/avatar.svg"></a>
