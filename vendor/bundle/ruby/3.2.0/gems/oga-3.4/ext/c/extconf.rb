require 'mkmf'

if RbConfig::CONFIG['CC'] =~ /clang|gcc/
  $CFLAGS << ' -pedantic -Wno-implicit-fallthrough'
end

if ENV['DEBUG']
  $CFLAGS << ' -O0 -g'
end

create_makefile('liboga')
