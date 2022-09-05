function tips(input,seg)
	if input:match("^/%?$") then
		local tip = "" .. require("emoji").tips() 
		yield(Candidate("tips", seg._start, seg._end, "", tip))
	end
end
local unicode = require("unicode")()
local mydate = require("mydate")()
local english = require("english")()
local rmb = require("number")()
local basefunc = require("basefunctions")()
--must after function definitions
Emoji_Translator = require("emoji").translator
english_processor = english.processor
english_segmentor = english.segmentor
english_translator = english.translator
english_filter = english.filter
english_filter0 = english.filter0
Multiline_filter = basefunc.Multiline_filter

-- translators
date_translator = mydate.date_translator
UnicodeTranslator  = unicode.UnicodeTranslator
daxie_translator = rmb.daxie_translator

