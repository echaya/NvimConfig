"log config
set autoread 
au CursorHold * checktime 
call feedkeys("lh")

" iwaylog.vim
" Vim syntax file
" Based on messages.vim - syntax file for highlighting kernel messages
if exists("b:current_syntax")
     finish
endif
"we use solarized scheme as a base. It has a very good contrast 
"for log files
"We want to match lines with keywords like FATAL or ERROR
syn match log_error 'c.*<(FATAL|ERROR|ERRORS|FAIL|FAILED|FAILURE|CRITICAL).*'
"The same with WARNING, but we want a different highlighting
"for those lines.
syn match log_warning 'c.*<(WARNING).*'
"Things between quotes are strings
syn region log_string start=/"/ end=/"/ skip=/\./
syn match log_number '0x[0-9a-fA-F]*|[<[0-9a-f]+>]|<d[0-9a-fA-F]*'
syn match log_number '{d{6,}}'
"Match the date: dd/mm/yyyy hh:mm:ss
syn match log_date 'd{2}/d{2}/d{4}s*d{2}:d{2}:d{2}'
"A component is something between brackets
syn match component '[[^]]*]'
"Match IP addresses
syn match internet 'dd*.dd*.dd*.dd*'
"Match IPv6 address, macaddresses and some other stuff
syn match internet '(x*:){5,}xx*'
syn keyword dhcp_keywords DISCOVER OFFER REQUEST ACK INFORM RENEW
syn keyword dhcp_keywords DHCPDISCOVER DHCPOFFER DHCPREQUEST DHCPACK DHCPINFORM DHCPRENEW
syn keyword dhcp_keywords SOLICIT ADVERTISE REPLY
syn keyword hard_keywords CMTS MTA CPE CM
"Now we apply color
hi def link log_string String
hi def link log_error ErrorMsg
hi def link log_warning WarningMsg
hi def log_date guifg=#bbbbbb
hi def component guifg=#bbbbbb
hi def internet guifg=#cccc33
hi def internet guifg=#cccc33
hi def dhcp_keywords guifg=#bbbbdd
hi def hard_keywords guifg=#ddddff guibg=#444444
