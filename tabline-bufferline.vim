" Name:    tabline-bufferline.vim
" Author:  Frank Willascheck <github.com/fwillascheck>
" Created: 2024 Feb 11
" License: MIT License

" -----------------------------------------------------------------------------

" use normal background color for tabline
highlight TabLineFill NONE
" normal buffer names
highlight User1 NONE
" current buffer name
highlight User2 term=bold,underline cterm=bold,underline gui=bold,underline

const s:SEP = ' '
const s:SEP_SIZE = strlen(s:SEP)

" -----------------------------------------------------------------------------

" buffer navigation with Ctrl+Cursor
noremap <C-Up> <Nop>
noremap <C-Down> <Nop>
noremap <C-Left> <Cmd>bprev<CR>
noremap <C-Right> <Cmd>bnext<CR>

" -----------------------------------------------------------------------------

" remove terminal from buffer list
autocmd TermOpen * call setbufvar(bufnr('%'), '&buflisted', 0)

" -----------------------------------------------------------------------------

function SetTabLine()

    "echo 'SetTabLine()'

    let buf_infos = getbufinfo({'buflisted':1})
    let buf_count = len(buf_infos)

    if buf_count == 1
        set showtabline=0
        return
    else
        set showtabline=2
    endif

    let cur_bufnr = winbufnr(winnr())
    let name_list = []
    let needed_cols = 0

    " calculate needed space for all buffer names
    " build list of buffer names
    " add highlight for current/other buffer
    for buf in buf_infos
         " get short name of buffer
        let buf_name = fnamemodify(buf.name, ':t')
        if buf_name == ''
            let buf_name = '[new]'
        endif
        " add len before adding highlight
        let needed_cols += strlen(buf_name)
        " add highlight
        " must be done here, because later we don't know anymore which the current buffer is
        if buf.bufnr == cur_bufnr
            let buf_name = '%2*'.buf_name
        else
            let buf_name = '%1*'.buf_name
        endif
        call add(name_list, buf_name)
    endfor

    " calc available space with separators and buf_count indicator
    let avail_cols = &columns - (buf_count - 1) * s:SEP_SIZE - 6

    if needed_cols > avail_cols 
        " calc available number of columns for each buffer name
        let buf_cols = avail_cols / buf_count
    else
        " just any large number, because we don't need to care
        let buf_cols = avail_cols
    endif

    "echo 'total='.&columns.' buf_count='.buf_count.' buf_cols='.buf_cols.' needed_cols='.needed_cols.' avail_cols='.avail_cols

    let buf_line = ''

    " build the buffer line
    for buf_name in name_list
        " add separator between buffer names
        if buf_line != ''
            let buf_line .= s:SEP
        endif
        " take care of 3 chars for leading '%1*' or '%2*'
        if strlen(buf_name) - 3 > buf_cols
            " shorten buffer name to available space
            let buf_name = strpart(buf_name, 0, buf_cols - 1 + 3) . '…'
        endif
        let buf_line .= buf_name.'%*'
    endfor

    let &tabline=buf_line.'%= '.cur_bufnr.'/'.buf_count

endfunction

" -----------------------------------------------------------------------------

autocmd BufEnter,BufDelete,BufWrite,VimResized * call SetTabLine()

