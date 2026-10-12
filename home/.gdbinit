set print pretty off
set print object off
set print static-members off
set print array off
set pagination off
set confirm off
set history save on
set history filename ~/.gdb_history
set history size 10000
set disassembly-flavor intel

define see
  info locals
  info args
end
