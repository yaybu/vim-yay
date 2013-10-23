" Vim syntax file
" Language:         YAY

if exists('b:current_syntax')
    finish
endif

let s:cpo_save = &cpo
set cpo&vim

let s:ns_char = '\%(\%([\n\r\uFEFF \t]\)\@!\p\)'
let s:ns_word_char = '\%(\w\|-\)'
let s:ns_uri_char  = '\%(%\x\x\|'.s:ns_word_char.'\|[#/;?:@&=+$,.!~*''()\[\]]\)'
let s:ns_tag_char  = '\%(%\x\x\|'.s:ns_word_char.'\|[#/;?:@&=+$.~*''()]\)'
let s:c_ns_anchor_char = '\%(\%([\n\r\uFEFF \t,\[\]{}]\)\@!\p\)'
let s:c_indicator      = '[\-?:,\[\]{}#&*!|>''"%@`]'
let s:c_flow_indicator = '[,\[\]{}]'

let s:c_verbatim_tag = '!<'.s:ns_uri_char.'\+>'
let s:c_named_tag_handle     = '!'.s:ns_word_char.'\+!'
let s:c_secondary_tag_handle = '!!'
let s:c_primary_tag_handle   = '!'
let s:c_tag_handle = '\%('.s:c_named_tag_handle.
            \         '\|'.s:c_secondary_tag_handle.
            \         '\|'.s:c_primary_tag_handle.'\)'
let s:c_ns_shorthand_tag = s:c_tag_handle . s:ns_tag_char.'\+'
let s:c_non_specific_tag = '!'
let s:c_ns_tag_property = s:c_verbatim_tag.
            \        '\|'.s:c_ns_shorthand_tag.
            \        '\|'.s:c_non_specific_tag

let s:c_ns_anchor_name = s:c_ns_anchor_char.'\+'
let s:c_ns_anchor_property =  '&'.s:c_ns_anchor_name
let s:c_ns_alias_node      = '\*'.s:c_ns_anchor_name

let s:ns_directive_name = s:ns_char.'\+'

let s:ns_local_tag_prefix  = '!'.s:ns_uri_char.'*'
let s:ns_global_tag_prefix = s:ns_tag_char.s:ns_uri_char.'*'
let s:ns_tag_prefix = s:ns_local_tag_prefix.
            \    '\|'.s:ns_global_tag_prefix

let s:ns_plain_safe_out = s:ns_char
let s:ns_plain_safe_in  = '\%('.s:c_flow_indicator.'\@!'.s:ns_char.'\)'

let s:ns_plain_first_in  = '\%('.s:c_indicator.'\@!'.s:ns_char.'\|[?:\-]\%('.s:ns_plain_safe_in.'\)\@=\)'
let s:ns_plain_first_out = '\%('.s:c_indicator.'\@!'.s:ns_char.'\|[?:\-]\%('.s:ns_plain_safe_out.'\)\@=\)'

let s:ns_plain_char_in  = '\%('.s:ns_char.'#\|:'.s:ns_plain_safe_in.'\|[:#]\@!'.s:ns_plain_safe_in.'\)'
let s:ns_plain_char_out = '\%('.s:ns_char.'#\|:'.s:ns_plain_safe_out.'\|[:#]\@!'.s:ns_plain_safe_out.'\)'

let s:ns_plain_out = s:ns_plain_first_out . s:ns_plain_char_out.'*'
let s:ns_plain_in  = s:ns_plain_first_in  . s:ns_plain_char_in.'*'


syn region  yayComment         display oneline start='\%\(^\|\s\)#' end='$'
            \                   contains=yayTodo

execute 'syn region yayDirective oneline start='.string('^\ze%'.s:ns_directive_name.'\s\+').' '.
            \                            'end="$" '.
            \                            'contains=yayTAGDirective,'.
            \                                     'yayYAMLDirective,'.
            \                                     'yayReservedDirective '.
            \                            'keepend'

execute 'syn match yayReservedDirective contained nextgroup=yayComment '.
            \string('%\%(\%(TAG\|YAML\)\s\)\@!'.s:ns_directive_name)

syn region yayFlowString matchgroup=yayFlowStringDelimiter start='"' skip='\\"' end='"'
            \ contains=yayEscape
            \ nextgroup=yayKeyValueDelimiter
syn region yayFlowString matchgroup=yayFlowStringDelimiter start="'" skip="''"  end="'"
            \ contains=yaySingleEscape
            \ nextgroup=yayKeyValueDelimiter
syn match  yayEscape contained '\\\%([\\"abefnrtv\^0_ NLP\n]\|x\x\x\|u\x\{4}\|U\x\{8}\)'
syn match  yaySingleEscape contained "''"

syn match yayBlockScalarHeader contained '\s\+\zs[|>]\%([+-]\=[1-9]\|[1-9]\=[+-]\)\='

syn cluster yayFlow contains=yayFlowString,yayFlowMapping,yayFlowCollection
syn cluster yayFlow      add=yayFlowMappingKey,yayFlowMappingMerge
syn cluster yayFlow      add=yayConstant,yayPlainScalar,yayFloat
syn cluster yayFlow      add=yayTimestamp,yayInteger,yayMappingKeyStart
syn cluster yayFlow      add=yayComment
syn region yayFlowMapping    matchgroup=yayFlowIndicator start='{' end='}' contains=@yayFlow
syn region yayFlowCollection matchgroup=yayFlowIndicator start='\[' end='\]' contains=@yayFlow

execute 'syn match yayPlainScalar /'.s:ns_plain_out.'/'
execute 'syn match yayPlainScalar contained /'.s:ns_plain_in.'/'

syn match yayMappingKeyStart '?\ze\s'
syn match yayMappingKeyStart '?' contained

execute 'syn match yayFlowMappingKey /'.s:ns_plain_in.'\ze\s*:/ contained '.
            \'nextgroup=yayKeyValueDelimiter'
syn match yayFlowMappingMerge /<<\ze\s*:/ contained nextgroup=yayKeyValueDelimiter

syn match yayBlockCollectionItemStart '^\s*\zs-\%(\s\+-\)*\s' nextgroup=yayBlockMappingKey,yayBlockMappingMerge
execute 'syn match yayBlockMappingKey /^\s*\zs'.s:ns_plain_out.'\ze\s*:\%(\s\|$\)/ '.
            \'nextgroup=yayKeyValueDelimiter'
execute 'syn match yayBlockMappingKey /\s*\zs'.s:ns_plain_out.'\ze\s*:\%(\s\|$\)/ contained '.
            \'nextgroup=yayKeyValueDelimiter'
syn match yayBlockMappingMerge /^\s*\zs<<\ze:\%(\s\|$\)/ nextgroup=yayKeyValueDelimiter
syn match yayBlockMappingMerge /<<\ze\s*:\%(\s\|$\)/ nextgroup=yayKeyValueDelimiter contained

syn match   yayKeyValueDelimiter /\s*:/ contained
syn match   yayKeyValueDelimiter /\s*:/ contained

syn keyword yayConstant true True TRUE false False FALSE
syn keyword yayConstant null Null NULL
syn keyword yayExtend extend 
syn keyword yayInclude include
syn match   yayConstant '\<\~\>'

syn match   yayTimestamp /\%([\[\]{}, \t]\@!\p\)\@<!\%(\d\{4}-\d\d\=-\d\d\=\%(\%([Tt]\|\s\+\)\%(\d\d\=\):\%(\d\d\):\%(\d\d\)\%(\.\%(\d*\)\)\=\%(\s*\%(Z\|[+-]\d\d\=\%(:\d\d\)\=\)\)\=\)\=\)\%([\[\]{}, \t]\@!\p\)\@!/

syn match   yayInteger /\%([\[\]{}, \t]\@!\p\)\@<!\%([+-]\=\%(0\%(b[0-1_]\+\|[0-7_]\+\|x[0-9a-fA-F_]\+\)\=\|\%([1-9][0-9_]*\%(:[0-5]\=\d\)\+\)\)\|[1-9][0-9_]*\)\%([\[\]{}, \t]\@!\p\)\@!/
syn match   yayFloat   /\%([\[\]{}, \t]\@!\p\)\@<!\%([+-]\=\%(\%(\d[0-9_]*\)\.[0-9_]*\%([eE][+-]\d\+\)\=\|\.[0-9_]\+\%([eE][-+][0-9]\+\)\=\|\d[0-9_]*\%(:[0-5]\=\d\)\+\.[0-9_]*\|\.\%(inf\|Inf\|INF\)\)\|\%(\.\%(nan\|NaN\|NAN\)\)\)\%([\[\]{}, \t]\@!\p\)\@!/

execute 'syn match yayNodeTag '.string(s:c_ns_tag_property)
execute 'syn match yayAnchor  '.string(s:c_ns_anchor_property)
execute 'syn match yayAlias   '.string(s:c_ns_alias_node)

syn match yayDocumentStart '^---\ze\%(\s\|$\)'
syn match yayDocumentEnd   '^\.\.\.\ze\%(\s\|$\)'


hi def link yayTodo                     Todo
hi def link yayComment                  Comment

hi def link yayDocumentStart            PreProc
hi def link yayDocumentEnd              PreProc

hi def link yayDirectiveName            Keyword

hi def link yayYAMLDirective            yayDirectiveName
hi def link yayReservedDirective        Error
hi def link yayYAMLVersion              Number

hi def link yayString                   String
hi def link yayFlowString               yayString
hi def link yayFlowStringDelimiter      yayString
hi def link yayEscape                   SpecialChar
hi def link yaySingleEscape             SpecialChar

hi def link yayBlockCollectionItemStart Label
hi def link yayBlockMappingKey          Identifier
hi def link yayBlockMappingMerge        Special

hi def link yayFlowMappingKey           Identifier
hi def link yayFlowMappingMerge         Special

hi def link yayMappingKeyStart          Special
hi def link yayFlowIndicator            Special
hi def link yayKeyValueDelimiter        Special

hi def link yayConstant                 Constant

hi def link yayAnchor                   Type
hi def link yayAlias                    Type
hi def link yayNodeTag                  Type

hi def link yayInteger                  Number
hi def link yayFloat                    Float
hi def link yayTimestamp                Number

hi def link yayExtend                   PreProc
hi def link yayInclude                  PreProc

let b:current_syntax = "yay"

unlet s:ns_word_char s:ns_uri_char s:c_verbatim_tag s:c_named_tag_handle s:c_secondary_tag_handle s:c_primary_tag_handle s:c_tag_handle s:ns_tag_char s:c_ns_shorthand_tag s:c_non_specific_tag s:c_ns_tag_property s:c_ns_anchor_char s:c_ns_anchor_name s:c_ns_anchor_property s:c_ns_alias_node s:ns_char s:ns_directive_name s:ns_local_tag_prefix s:ns_global_tag_prefix s:ns_tag_prefix s:c_indicator s:ns_plain_safe_out s:c_flow_indicator s:ns_plain_safe_in s:ns_plain_first_in s:ns_plain_first_out s:ns_plain_char_in s:ns_plain_char_out s:ns_plain_out s:ns_plain_in

let &cpo = s:cpo_save
unlet s:cpo_save

