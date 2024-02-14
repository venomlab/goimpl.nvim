local ts_utils = require("nvim-treesitter.ts_utils")

local M = {}

function M.api_show_error(error)
	print(error)
end

function M.api_get_node_at_cursor()
	return ts_utils.get_node_at_cursor()
end

function M.api_node_type_valid(node)
	if
		node:type() ~= "type_identifier"
		or node:parent():type() ~= "type_spec"
		or node:parent():parent():type() ~= "type_declaration"
	then
		return false
	else
		return true
	end
end

function M.api_get_current_buf()
	return vim.api.nvim_get_current_buf()
end

function M.api_get_node_text(node)
	local buf = M.api_get_current_buf()
	return (vim.treesitter.get_node_text or vim.treesitter.query.get_node_text)(node, buf, {})
end

function M.api_get_var_from_type(type_name)
	return string.lower(string.sub(type_name, 0, 1))
end

function M.api_get_typedef(var_name, type_name)
	return var_name .. " *" .. type_name
end

function M.api_get_currect_directory()
	return vim.fn.fnameescape(vim.fn.expand("%:p:h"))
end

function M.api_ask_for_prompt(prompt, on_complete)
	vim.ui.input({ prompt = prompt }, on_complete)
end

function M.api_generate_impl_lines(dir_name, var_name, type_name, int_name, on_complete)
	local type_def = M.api_get_typedef(var_name, type_name)
	local cmd_args = { "impl", "-dir", dir_name, type_def, int_name }
	local cmd_output = vim.fn.systemlist(cmd_args)
	if not cmd_output then
		M.api_show_error("Error executing 'impl' command")
		return
	end
	if cmd_output[#cmd_output] == "" then
		table.remove(cmd_output, #cmd_output)
	end
	if #cmd_output < 1 then
		M.api_show_error("Command 'impl' return nothing")
		return
	end
	if not string.find(cmd_output[1], var_name .. " %*" .. type_name) then
		M.api_show_error(cmd_output[1])
		return
	end
	on_complete(cmd_output)
end

function M.api_append_lines_after_node(node, lines)
	local _, _, pos, _ = node:parent():parent():range()
	pos = pos + 1
	vim.fn.append(pos, "")
	pos = pos + 1
	vim.fn.append(pos, lines)
end

function M.is_go()
	return vim.bo.filetype == "go"
end

function M.impl()
	if not M.is_go() then
		return
	end
	local node = M.api_get_node_at_cursor()
	if not M.api_node_type_valid(node) then
		M.api_show_error("No type identifier found under cursor")
		return
	end
	local type_name = M.api_get_node_text(node)
	local var_name = M.api_get_var_from_type(type_name)
	local type_def = M.api_get_typedef(var_name, type_name)
	M.api_ask_for_prompt("What interface you want to implement for '" .. type_def .. "': ", function(int_name)
		local dir_name = M.api_get_currect_directory()
		M.api_generate_impl_lines(dir_name, var_name, type_name, int_name, function(type_stubs)
			M.api_append_lines_after_node(node, type_stubs)
		end)
	end)
end
return M
