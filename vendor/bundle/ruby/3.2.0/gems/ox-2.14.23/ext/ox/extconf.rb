require 'mkmf'

extension_name = 'ox'
dir_config(extension_name)

parts = RUBY_DESCRIPTION.split(' ')
type = parts[0].downcase
type = 'ree' if 'ruby' == type && RUBY_DESCRIPTION.include?('Ruby Enterprise Edition')
platform = RUBY_PLATFORM
version = RUBY_VERSION.split('.')
puts ">>>>> Creating Makefile for #{type} version #{RUBY_VERSION} on #{platform} <<<<<"

dflags = {
  'RUBY_TYPE' => type,
  (type.upcase + '_RUBY') => nil,
  'RUBY_VERSION' => RUBY_VERSION,
  'RUBY_VERSION_MAJOR' => version[0],
  'RUBY_VERSION_MINOR' => version[1],
  'RUBY_VERSION_MICRO' => version[2]
}

dflags.each do |k, v|
  if v.nil?
    $CPPFLAGS += " -D#{k}"
  else
    $CPPFLAGS += " -D#{k}=#{v}"
  end
end
$CPPFLAGS += ' -Wall'
# puts "*** $CPPFLAGS: #{$CPPFLAGS}"
CONFIG['warnflags'].slice!(/ -Wsuggest-attribute=format/)
CONFIG['warnflags'].slice!(/ -Wdeclaration-after-statement/)
CONFIG['warnflags'].slice!(/ -Wmissing-noreturn/)

have_func('rb_ext_ractor_safe', 'ruby.h')
have_func('pthread_mutex_init')
have_func('rb_enc_interned_str')
have_func('index')

have_header('ruby/st.h')
have_header('sys/uio.h')

have_struct_member('struct tm', 'tm_gmtoff')

create_makefile(extension_name)

`make clean`
