" eslint will populate quickfix list
setlocal makeprg=npx\ eslint\ --format\ compact\ .
setlocal errorformat=%f:\ line\ %l\\,\ col\ %c\\,\ %m,%-G%.%#
