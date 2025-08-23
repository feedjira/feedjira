require 'mkmf'

if RbConfig::CONFIG['CC'] =~ /clang|gcc/
  $CFLAGS << ' -pedantic'
end

if ENV['DEBUG']
  $CFLAGS << ' -O0 -g'
end

create_makefile('libll')
