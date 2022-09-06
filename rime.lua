require("mydate")
require("unicode")
require("number")
require("emoji")
require("basefunctions")

-- global lua help tips
function Lua_Tips(input,seg, env)
	local segment = env.engine.context.composition:back()
	if input:match("^/$") then 
		segment.prompt = "~? [获得输入帮助]"
		return
	end
	if input:match("^/%?$") then
		segment.prompt = "Lua快捷输入帮助"
		local emoji_tips = "" .. Emoji_Tips()
		local daxie_tips = "" .. Daxie_Tips()
		local unicode_tips = "" .. Unicode_Tips()
		local date_tips = "" .. Date_Tips()

		local alltips = ""
		alltips = alltips .. emoji_tips 
		alltips = alltips .. "\r" .. daxie_tips 
		alltips = alltips .. "\r" .. date_tips
		alltips = alltips .. "\r" .. unicode_tips
		yield(Candidate("tips", seg._start, seg._end, "", alltips))
	end
end

--must after function definitions
local english = require("english")()
english_processor = english.processor
english_segmentor = english.segmentor
english_translator = english.translator
english_filter = english.filter
english_filter0 = english.filter0

