# Based on Helix's Monokai Soda (Jimmy Zelinskie):
# https://github.com/helix-editor/helix/blob/master/runtime/themes/monokai_soda.toml
# Align text, keywords, and constants with bat's Monokai Extended:
# Use the terminal's default canvas background; retain UI highlights.
# https://github.com/jonschlinkert/sublime-monokai-extended

# Syntax
set-face global value rgb:be84ff
set-face global type rgb:66d9ef
set-face global variable rgb:f8f8f2
set-face global module rgb:f59762
set-face global function rgb:a6e22e
set-face global string rgb:e6db74
set-face global keyword rgb:f92672
set-face global operator rgb:f92672
set-face global attribute rgb:66d9ef
set-face global comment rgb:75715e+i
set-face global documentation comment
set-face global meta rgb:66d9ef
set-face global builtin rgb:be84ff

# Markup
set-face global title rgb:a6e22e+b
set-face global header rgb:a6e22e+b
set-face global bold rgb:fd971f+b
set-face global italic rgb:fd971f+i
set-face global mono rgb:e6db74
set-face global block rgb:e6db74
set-face global link rgb:fd971f+u
set-face global bullet rgb:a6e22e
set-face global list rgb:a6e22e

# Editor
set-face global Default rgb:f8f8f2,default
set-face global PrimarySelection default,rgb:444444+g
set-face global SecondarySelection default,rgb:444444+g
set-face global PrimaryCursor rgb:222222,rgb:f8f8f2+fg
set-face global SecondaryCursor rgb:222222,rgb:66d9ef+fg
set-face global PrimaryCursorEol PrimaryCursor
set-face global SecondaryCursorEol SecondaryCursor
set-face global CursorLine default,rgb:1c2026
set-face global LineNumbers rgb:75715e,default
set-face global LineNumberCursor rgb:fd971f,default
set-face global LineNumbersWrapped rgb:75715e,default
set-face global MatchingChar default,default+r
set-face global Whitespace rgb:444444,default
set-face global WrapMarker Whitespace
set-face global BufferPadding rgb:444444,default

# Menus, messages, and modeline
set-face global MenuForeground rgb:f8f8f2,rgb:75715e
set-face global MenuBackground rgb:f8f8f2,rgb:444444
set-face global MenuInfo rgb:66d9ef,rgb:444444
set-face global Information rgb:f8f8f2,rgb:444444
set-face global InlineInformation rgb:75715e
set-face global Error rgb:f92672,default+b
set-face global DiagnosticError default,default,rgb:f92672+c
set-face global DiagnosticWarning default,default,rgb:fd971f+c
set-face global DiagnosticHint default,default,rgb:66d9ef+c
set-face global DiagnosticInfo default,default,rgb:66d9ef+c
set-face global StatusLine rgb:f8f8f2,rgb:1b2028
set-face global StatusLineMode rgb:66d9ef,rgb:1b2028
set-face global StatusLineInfo rgb:66d9ef,rgb:1b2028
set-face global StatusLineValue rgb:a6e22e,rgb:1b2028
set-face global StatusCursor rgb:222222,rgb:f8f8f2
set-face global Prompt rgb:66d9ef,default
