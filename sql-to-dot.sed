#! /bin/sed -nf
1i\
/** @page database Database Schema\
\
@dot\
digraph schema {

# get everithing on one single line
H;$!d;$x

# remove all single-line comment lines
s/\n--[^\n]*//g

# reduce spaces
s,\t\| \+, ,g

# remove multiline comments
:f;s,\(.*\)/\*.*\*/[ \n]*;*,\1,g;tf

# remove empty lines
s,\n\+,\n,g

# remove unknown commands
s,\(;\|\n\) *\(DELIMITER\|USE\|DROP\|CREATE[ \n]\+DATABASE\)[ \n]\+[^;]*;\+,,ig

# convert special characters within quotes
:a;s/^\(\([^"]*"[^",]*"\)*[^"]*"[^"]*\),\([^"]*".*\)/\1\##COMMA##\3/g;ta
:c;s/^\(\([^']*'[^',]*'\)*[^']*'[^']*\),\([^']*'.*\)/\1\##COMMA##\3/g;tc

# backup everything to the buffer
# then analyze only on one create table
:i
h
s,.*\(create[ \n]\+table[^;]*;\).*,\1,ig

# start html table node
s|CREATE[ \n]\+TABLE[ \n]\+\(if[ \n]\+not[ \n]\+exists[ \n]\+\)\?`\?\(\w\+\)`\?|    \2\n        [shape=none, margin=0, label=<\n            <table bgcolor="#dddddd">\n                <tr><td bgcolor="#ddddff" colspan="4"><b>\2</b></td></tr>|ig

# remove key definitions
s/[),][\n ]*\(PRIMARY[ \n]\+\)\?KEY[ \n]\+[^(]*([^)]*)//gi

# move foreign keys as relation to the end
:b;s/\(\w\+\)\([^;]*\)FOREIGN[\n ]\+KEY[ \n]*([ \n]*`\?\([a-z]\+\)`\?[ \n]*)[ \n]*REFERENCES[ \n]*`\?\([a-z]\+\)`\?[ \n]*([ \n]*`\?\([a-z]\+\)`\?[ \n]*)[ \n]*\([^,)]*\)\([,)].*\)/\1\2\7\n \1:\3 -> \4:\5 [label="\6"]##SEMICOLON##/ig;tb

# create table rows
s|[(,][ \n]*`\?\(\w\+\)`\?[ \n]\+\(\w\+\(([^)]\+)\)\?\)[ \n]*\([^,)]*\)[ \n]\+COMMENT[ \n]*["']\([^"']*\)["'][ \n]*|\n                <tr><td align="left" port="\1"><b>\1</b></td><td align="left">\2</td><td align="left">\4</td><td align="left">\5</td></tr>|gi
s|[(,][ \n]*`\?\(\w\+\)`\?[ \n]\+\(\w\+\(([^)]\+)\)\?\)[ \n]*\([^,)]*\)|\n                <tr><td align="left" port="\1"><b>\1</b></td><td align="left">\2</td><td align="left">\4</td></tr>|g

# add line breaks for long lines
s|\(<td[^>]*>[^<]\{30,40\}\)[ \n]\+\([^<]\{20,\}</td>\)|\1<br/>\2|g
#:d;s|\(<br/>[^<]\{30,40\}\)[ \n]\+\([^<]\{20,\}</td>\)|\1<br/>\2|g;td

# add table comment below
:k;tk
s|[ \n]*)[^)]*COMMENT[ \n]*=[ \n]*["']\?\([^"']*\)["']\?[^;]*|\n                <tr><td bgcolor="#ddddff" colspan="4">\1</td></tr>|ig;th
s|)[^);]*;|\n;|ig
:h

# cleanup comment below, add line breaksfor long lines
s|\(<td[^>]*>[^<]\{60,80\}\)[ \n]\+\([^<]\{30,\}</td>\)|\1<br/>\2|g
#:e;s|\(<br/>[^<]\{60,80\}\)[ \n]\+\([^<]\{30,\}</td>\)|\1<br/>\2|g;te

# close table
s|;|\n            </table>\n        >];|ig

# convert ##COMMA## to ,
s|##COMMA##|,|g
# convert ##SEMICOLON## to ;
s,##SEMICOLON##,;,g

# print one table
p
# get buffer back and remove the table that has just been analyzed
x
s,\(.*\)create[ \n]\+table[^;]*;\(.*\),\1\2,ig
ti

$a\
}\
@enddot\
*/
