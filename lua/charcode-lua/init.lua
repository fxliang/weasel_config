local usrdir = rime_api.get_user_data_dir()
-- add user_dir/lua/charcode-lua/?.lua to package path
package.path = package.path .. ';' ..usrdir .. '/lua/charcode-lua/?.lua'

local charcode = require('charcode')
local FilterText = charcode.FilterText
--local conv_to_utf = charcode.conv_to_utf
--local conv_from_utf = charcode.conv_from_utf

local function init(env)
	local engine = env.engine
end

local function filter(input, env)
	local engine = env.engine
	local context = engine.context
	local common_charsets = {'gbk', 'gb2312', 'cjk', 'utf8'}
	local charsets = ''
	for i = 1, #common_charsets do
		if context:get_option(common_charsets[i]) == true then
			charsets = common_charsets[i]
			break
		end
	end
	local is_emoji_enbaled = context:get_option('emoji_suggestion')
	for cand in input:iter() do
		if FilterText(cand.text, charsets, is_emoji_enbaled) then
			yield(cand)
		end
	end
end

return {init = init, func = filter}
