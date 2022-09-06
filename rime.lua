local rmb = require("number")
local emoji = require("emoji")
function tips(input,seg)
	if input:match("^/%?$") then
		local emoji_tips = "" .. emoji.tips()
		local daxie_tips = "" .. rmb.tips()
		yield(Candidate("tips", seg._start, seg._end, "", emoji_tips))
		yield(Candidate("tips", seg._start, seg._end, "", daxie_tips))
	end
end
local unicode = require("unicode")()
local mydate = require("mydate")()
local english = require("english")()
local basefunc = require("basefunctions")()
--must after function definitions
Emoji_Translator = emoji.translator

english_processor = english.processor
english_segmentor = english.segmentor
english_translator = english.translator
english_filter = english.filter
english_filter0 = english.filter0
Multiline_filter = basefunc.Multiline_filter

-- translators
date_translator = mydate.date_translator
UnicodeTranslator  = unicode.UnicodeTranslator
daxie_translator = rmb.translator

