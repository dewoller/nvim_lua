setlocal indentexpr=GetTargetsIndent()

" Only define the function once.
if exists("*GetTargetsIndent")
  finish
endif

function! GetTargetsIndent()
  let prevlnum = prevnonblank(v:lnum - 1) 
  if getline(prevlnum) =~ 'tar_plan('
    return shiftwidth()
  endif
  return(GetRIndent())
endfunction


