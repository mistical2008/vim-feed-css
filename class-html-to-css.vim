" NAME: CSS-writer
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

let s:index_html = "index.html"
let s:cwd = expand("%:p:h")

let s:htmls = filter(readdir(s:cwd), 'v:val =~ ".html$"')
let s:css_file = "main.css"

let s:class_lines = GetClassLines(s:htmls)
let s:classes = SanitizeClassList(s:class_lines)

function WriteToCSS() abort
  let l:classes_mutated = map(copy(s:classes), '"." . v:val . " {\n\n}\n"')
  echo l:classes_mutated
  call writefile(l:classes_mutated, s:css_file, "b")
endfunction
call WriteToCSS()

function GetClassLines(files) abort
  let l:unite_content = []
  for file in a:files
    let l:file_content = readfile(file, "b")
    let l:sorted_content = filter(l:file_content, 'v:val =~ "class="')
    call extend(l:unite_content, l:sorted_content)
  endfor
  return l:unite_content
endfunction

function SanitizeClassList(arr) abort
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

echomsg "All classes written to '" . s:cwd . "/" .  s:css_file . "'"

let &cpo = s:save_cpo
unlet s:save_cpo
