local vim = vim
local validate = vim.validate
local api = vim.api
local util = require 'completion.util'
local M = {}

----------------------
--  signature help  --
----------------------
M.autoOpenSignatureHelp = function()
  local bufnr = api.nvim_get_current_buf()
  local pos = api.nvim_win_get_cursor(0)
  local line = api.nvim_get_current_line()
  local line_to_cursor = line:sub(1, pos[2])
  if vim.lsp.buf_get_clients() == nil then return end

  local triggered
  for _, value in pairs(vim.lsp.buf_get_clients(0)) do
    if value.resolved_capabilities.signature_help == false or
      value.server_capabilities.signatureHelpProvider == nil then
      return
    end

    if value.resolved_capabilities.hover == false then return end
      triggered = util.checkTriggerCharacter(line_to_cursor,
        value.server_capabilities.signatureHelpProvider.triggerCharacters)
  end

  if triggered then
    -- overwrite signature help here to disable "no signature help" message
    local params = vim.lsp.util.make_position_params()
    vim.lsp.buf_request(0, 'textDocument/signatureHelp', params, function(_, method, result)
      if not (result and result.signatures and result.signatures[1]) then
        return
      end
      local lines = vim.lsp.util.convert_signature_help_to_markdown_lines(result)
      if vim.tbl_isempty(lines) then
        return
      end
      vim.lsp.util.focusable_preview(method, function()
        -- TODO show popup when signatures is empty?
        lines = vim.lsp.util.trim_empty_lines(lines)
        return lines, vim.lsp.util.try_trim_markdown_code_blocks(lines)
      end)
    end)
  end
end


return M
