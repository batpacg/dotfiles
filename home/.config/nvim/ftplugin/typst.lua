vim.api.nvim_create_user_command("TypstOpenPdf", function()
    local filepath = vim.api.nvim_buf_get_name(0)
    if filepath:match "%.typ$" then
        local pdf_path = filepath:gsub("%.typ$", ".pdf")
        vim.system { "xdg-open", pdf_path }
    end
end, {})

vim.api.nvim_create_user_command("TypstCompile", function()
    local filename = vim.fn.expandcmd "%"
    vim.fn.system { "typst", "c", filename }
end, {})

vim.api.nvim_create_user_command("TypstSvg", function()
    local current_line = vim.api.nvim_get_current_line()
    local svg = string.match(current_line, "%./(.*%.svg)")
    if not svg then
        vim.notify(
            "Error: no svg file found in current line!",
            vim.log.levels.ERROR
        )
    end
    if vim.fn.filereadable(svg) ~= 1 then
        vim.system { "touch", svg }
        local svg_template = ([[
        <svg
           width="512"
           height="512"
           viewBox="0 0 135.46667 135.46667"
           version="1.1"
           id="svg1"
           inkscape:version="1.4.2 (ebf0e940d0, 2025-05-08)"
           sodipodi:docname="%s"
           xmlns:inkscape="http://www.inkscape.org/namespaces/inkscape"
           xmlns:sodipodi="http://sodipodi.sourceforge.net/DTD/sodipodi-0.dtd"
           xmlns="http://www.w3.org/2000/svg"
           xmlns:svg="http://www.w3.org/2000/svg">
          <sodipodi:namedview
             id="namedview1"
             pagecolor="#ffffff"
             bordercolor="#ffffff"
             borderopacity="1"
             inkscape:showpageshadow="0"
             inkscape:pageopacity="0"
             inkscape:pagecheckerboard="0"
             inkscape:deskcolor="#505050"
             inkscape:document-units="px"
             inkscape:zoom="2.1241178"
             inkscape:cx="225.0346"
             inkscape:cy="253.28162"
             inkscape:window-width="1920"
             inkscape:window-height="1052"
             inkscape:window-x="0"
             inkscape:window-y="0"
             inkscape:window-maximized="1"
             inkscape:current-layer="layer1" />
        </svg>
        ]]):format(svg)
        vim.system({ "tee", svg }, { stdin = svg_template })
    end
    vim.system { "inkscape", svg }
end, {})

vim.keymap.set({ "n" }, "<LocalLeader>c", ":TypstCompile<CR>")
vim.keymap.set({ "n" }, "<LocalLeader>o", ":TypstOpenPdf<CR>")
vim.keymap.set({ "n" }, "<LocalLeader>i", ":TypstSvg<CR>")
