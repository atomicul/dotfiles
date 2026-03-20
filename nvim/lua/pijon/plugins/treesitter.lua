-- ============================================================================
-- 0. SHARED HELPERS & TARGETS
-- ============================================================================
local TARGET_NODES = {
    function_definition = "function",
    function_declaration = "function",
    method_definition = "function",
    method_declaration = "function",
    arrow_function = "function",
    lambda = "function",
    class_declaration = "class",
    class_definition = "class",
    struct_specifier = "class",
    struct_declaration = "class",
}

local HIGHLIGHTS = {
    class = "%#Type#",
    ["function"] = "%#Function#",
    comment = "%#Comment#",
    reset = "%*",
}

local function get_name_node(node)
    if node.field then
        local name_nodes = node:field("name")
        if name_nodes and #name_nodes > 0 then return name_nodes[1] end
    end
    for i = 0, node:named_child_count() - 1 do
        local child = node:named_child(i)
        local c_type = child:type()
        if c_type == "identifier" or c_type == "property_identifier" or
            c_type == "type_identifier" or c_type == "name" or
            c_type == "dot_index_expression" or c_type == "method_index_expression" then
            return child
        end
    end
    return nil
end


-- ============================================================================
-- 1. NAVIGATION MODULE (Jump to Signature)
-- ============================================================================
local Navigation = {}

function Navigation.jump_to_signature(skip_anonymous)
    local ts_utils = require("nvim-treesitter.ts_utils")
    local ok, node = pcall(ts_utils.get_node_at_cursor)
    if not ok or not node then return end

    local initial_row = vim.api.nvim_win_get_cursor(0)[1] - 1
    local count = vim.v.count1 -- Grabs the number typed before the command (defaults to 1)

    local target_r, target_c = nil, nil

    while node and count > 0 do
        local category = TARGET_NODES[node:type()]

        if category then
            local skip_this_node = false
            local r, c, _ = node:start()

            -- Skip if we are already on this line (chainability)
            if r == initial_row then
                skip_this_node = true
            end

            -- Handle anonymous skipping
            if skip_anonymous and category == "function" then
                local type = node:type()
                if type == "arrow_function" or type == "lambda" then
                    skip_this_node = true
                elseif not get_name_node(node) then
                    skip_this_node = true
                end
            end

            -- If valid, record it and decrement our count
            if not skip_this_node then
                target_r = r
                target_c = c
                count = count - 1
            end
        end

        -- Keep climbing if we haven't fulfilled the count yet
        if count > 0 then
            node = node:parent()
        end
    end

    -- Perform the jump to the furthest node we found
    if target_r and target_c then
        vim.cmd("normal! m'")
        vim.api.nvim_win_set_cursor(0, { target_r + 1, target_c })
        vim.cmd("normal! zz")
    else
        print("Reached the top level before fulfilling the count.")
    end
end

function Navigation.setup_keymaps()
    vim.keymap.set('n', 'gm', function() Navigation.jump_to_signature(false) end,
        { desc = "Treesitter: Jump to nearest function/class" })

    vim.keymap.set('n', 'gM', function() Navigation.jump_to_signature(true) end,
        { desc = "Treesitter: Jump to nearest named function/class" })
end

-- ============================================================================
-- 2. BREADCRUMBS MODULE (Statusline Context)
-- ============================================================================
local Breadcrumbs = {}

function Breadcrumbs.get_readable_name(node)
    local name_node = get_name_node(node)
    if name_node then return vim.treesitter.get_node_text(name_node, 0) end
    local type = node:type()
    if type == "arrow_function" or type == "lambda" then return "λ" end
    return "<anonymous>"
end

function Breadcrumbs.update_cache()
    local ok, node = pcall(vim.treesitter.get_node)
    if not ok or not node then
        vim.b.ts_breadcrumbs = ""
        return
    end

    local path = {}
    while node do
        local category = TARGET_NODES[node:type()]
        if category then
            local name = Breadcrumbs.get_readable_name(node)
            local color = HIGHLIGHTS[category]
            local colored_name = color .. name .. HIGHLIGHTS.reset
            table.insert(path, 1, colored_name)
        end
        node = node:parent()
    end

    if #path > 0 then
        local separator = HIGHLIGHTS.comment .. " > " .. HIGHLIGHTS.reset
        local prefix = " "
        vim.b.ts_breadcrumbs = prefix .. table.concat(path, separator)
    else
        vim.b.ts_breadcrumbs = ""
    end
end

function Breadcrumbs.setup_autocmd()
    vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "BufEnter", "BufWinEnter", "WinEnter" }, {
        desc = "Cache Treesitter Breadcrumbs for Statusline",
        callback = Breadcrumbs.update_cache,
    })
end

vim.opt.statusline = " %f %{%get(b:, 'ts_breadcrumbs', '')%} %=%l:%c "

-- ============================================================================
-- 3. PLUGIN SPECIFICATION (Lazy.nvim)
-- ============================================================================
return {
    {
        "nvim-treesitter/nvim-treesitter",
        priority = 900,
        dependencies = { "nvim-treesitter/nvim-treesitter-textobjects" },
        config = function()
            require("nvim-treesitter.configs").setup {
                ensure_installed = {
                    "yaml", "python", "html", "javascript", "typescript",
                    "cpp", "c", "lua", "vim", "vimdoc", "query",
                    "markdown", "markdown_inline"
                },
                sync_install = false,
                auto_install = true,
                highlight = { enable = true, additional_vim_regex_highlighting = false },
            }

            Navigation.setup_keymaps()
            Breadcrumbs.setup_autocmd()
        end,
    }
}
