require 'mkmf'

$CFLAGS << ' -Wno-declaration-after-statement'
create_makefile('system_navigation/method_source_code')
