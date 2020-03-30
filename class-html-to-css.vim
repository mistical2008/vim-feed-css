", NAME: CSS-writer
" Links for relative projects for sublimetext : 
" - https://github.com/hudochenkov/ecsstractor/blob/master/eCSStractor.py
" - https://github.com/vaicine/sublimetext-css-primer/blob/master/cssprimer.py
"
" - Get main *.css filename
" - Get all *.html files array
" - Read each html files to one array
" - Filter html-array by class=".*" pattern
" - Split all items by \s (spaces)
"
" TODO:
" - Get classes from visual selection
" - Check for existing classes in *.css file
" + Get *.css filename from index.html
" - Check *.css for emptiness (rewrite or append)
"
let s:save_cpo = &cpo
set cpo&vim
set fileencoding=utf-8
scriptencoding utf-8
set fileformat=unix

function! GetRunningOS()
  if has("win32")
    return "win"
  endif
  if has("unix")
    if system('uname')=~'Darwin'
      return "mac"
    else
      return "linux"
    endif
  endif
endfunction
let s:os=GetRunningOS()

function! GetClassLines(files) abort
  let l:unite_content = []
  for file in a:files
    " echomsg a:files . " " . file
    echomsg file
    let l:file_content = readfile(file)
    " let l:file_content = readfile(file, "b")
    " echomsg l:file_content
    let l:sorted_content = filter(l:file_content, 'v:val =~ "class="')
    " echomsg l:sorted_content
    call extend(l:unite_content, l:sorted_content)
  endfor
  return l:unite_content
endfunction

function! SanitizeClassList(arr) abort
  let l:classes = []
  for item in a:arr
    let l:cleaned_item = matchstr(item, '\vclass\="\zs.*\ze"')
    call add(l:classes, l:cleaned_item)
  endfor
  let l:cleaned_str = join(l:classes)
  let l:cleaned_arr = split(l:cleaned_str)
  return uniq(l:cleaned_arr)
endfunction

function! GetStylesFile(index) abort
  " - Current file is index % 
  " - read file
    let l:index_content = readfile(a:index)
    " echomsg index_content
    let l:main_css_line = filter(index_content, function('IsMainStyleLine') )[0]
    " echomsg main_css_line
    let l:main_css_file = matchstr(main_css_line, '\v.*href\="[.]*[/]*\zs.*\.css\ze".*')
    " ?: How to chose if multiple link:css lines (vendor styles)
    " - get link:css line
    "   - man.css, style.css, site.css, default.css, template.css, global.css, myappname.css, stylesheet.css
    "   - user defined names array
    " - parse *.css fliename
    " <link rel="stylesheet" href="main.css" />
    return l:main_css_file
endfunction

function! IsMainStyleLine(idx, val)
  return match(a:val, '\v^[ ]+\<link.*rel\="stylesheet".*href\="[\w\W]*.*(main|style|site|default|global|stylesheet|)\.css".*\>') == 0
endfunction

function! InitThisScript() abort
  let s:index_html_path = expand("%:p")
  let s:script_cwd = expand("%:p:h")
  let s:htmls = filter(readdir(s:script_cwd), 'v:val =~ ".html$"')
  " echomsg s:htmls
  " let s:css_file = "main.css"
  let s:css_file = GetStylesFile(s:index_html_path)
  echomsg s:css_file . ". " . s:index_html_path
  let s:class_lines = GetClassLines(s:htmls)
  let s:classes = SanitizeClassList(s:class_lines)
  echo s:classes
endfunction

function! WriteToCSS() abort
  " If visual mode then run function for copying from visual range
  " Else:
  call InitThisScript()
  set fileformat=unix
  set fileformats=unix,dos
  let l:classes_mutated = map(copy(s:classes), '"." . v:val . " {\r\r}\r"')
  echo l:classes_mutated
  call writefile(l:classes_mutated, s:css_file, "bas") 
  echo "All classes written to '" . s:script_cwd . "/" .  s:css_file . "'"
  " echo l:classes_mutated . " " . s:script_cwd . " " . s:css_file
endfunction

" ======================== Commands =============================
if !exists(":CSSexWriteAll")
  command! -nargs=0 CSSexWriteAll call WriteToCSS()
endif

if !exists(":CSSexVis")
  command! -nargs=0 -range CSSexVis <line1>,<line2>call GetClassesVis()
endif

"================================================================================
"                                    Mappings:
"================================================================================
vnoremap <C-T> :CSSexVis<CR>
 
" ========================= Autocmds: =============================
autocmd BufEnter *.html echomsg "Class2css loaded"
" echomsg s:css_file . ". " . s:index_html_path

"================================================================================
"                                 New functions:
"================================================================================
" Function for reading lines from range:
function! GetClassesVis() range
  setlocal fileformat=unix
  let lines = []
  for linenum in range(a:firstline, a:lastline)
    call add(lines, getline(linenum))
  endfor
  let l:class_lines = filter(copy(lines), 'v:val =~ "class="')
  " echomsg l:class_lines
  let l:classes_arr = SanitizeClassList(l:class_lines)
  " echomsg l:res
  let l:res = map(l:classes_arr, '"." . v:val . " {\n\n}\n"')
  echomsg join(l:res, "\n")
  " let @+ = substitute(join(l:res, "\n"), '\n', '\n', 'g')
  let @+ = join(l:res, "\n")
  " let @@ = join(l:classes_raw, ", ")
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo


