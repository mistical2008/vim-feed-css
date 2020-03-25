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
" - Get *.css filename from index.html
"
let s:save_cpo = &cpo
set cpo&vim
set fileformat=unix
set fileformats=unix,dos

function! s:GetClassLines(files) abort
  let l:unite_content = []
  for file in a:files
    " echomsg a:files
    let l:file_content = readfile(file, "b")
    " echomsg l:file_content
    let l:sorted_content = filter(l:file_content, 'v:val =~ "class="')
    " echomsg l:sorted_content
    call extend(l:unite_content, l:sorted_content)
  endfor
  return l:unite_content
endfunction

function! s:SanitizeClassList(arr) abort
  let l:cleaned_arr = []
  let l:classes = []
  let l:cleaned_str = ""
  for item in a:arr
    let l:cleaned_item = matchstr(item, '\vclass\="\zs.*\ze"')
    call add(l:classes, l:cleaned_item)
  endfor
  let l:cleaned_str = join(l:classes)
  let l:cleaned_arr = split(l:cleaned_str)
  return uniq(l:cleaned_arr)
endfunction

function s:InitThisScript() abort
  let s:index_html = "index.html"
  let s:cwd = expand("%:p:h")
  let s:htmls = filter(readdir(s:cwd), 'v:val =~ ".html$"')
  let s:css_file = "main.css"
  " let class_lines = execute(s:GetClassLines(htmls))
  " let classes = execute(s:SanitizeClassList(class_lines))
  let s:class_lines = s:GetClassLines(s:htmls)
  let s:classes = s:SanitizeClassList(s:class_lines)
" echomsg s:classes
endfunction
call s:InitThisScript()

function! s:WriteToCSS() abort
  let l:classes_mutated = map(copy(s:classes), '"." . v:val . " {\r\r}\r"')
  " echo l:classes_mutated
  call writefile(l:classes_mutated, s:css_file, "ba") | echo "All classes written to '" . s:cwd . "/" .  s:css_file . "'"
endfunction

" ======================== Commands =============================
if !exists(":CSS2html")
  command! -nargs=0 CSS2html call s:WriteToCSS()
endif

" ========================= Mappings =============================
echomsg "Class2css loaded"

let &cpo = s:save_cpo
unlet s:save_cpo
