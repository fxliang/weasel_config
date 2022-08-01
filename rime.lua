
function single_char_first_filter(input)
	local l = {}
	for cand in input:iter() do
		if (utf8.len(cand.text) == 1) then
			yield(cand)
		else
			table.insert(l, cand)
		end
	end
	for i, cand in ipairs(l) do
		yield(cand)
	end
end

-- 在词典里面候选支持\r分割分行
-- 方案patch中要添加以下两行
--  engine/filters/+:
--  - lua_filter@Multiline_filter
function Multiline_filter(input)
	for cand in input:iter() do
		if cand.text:match("\\r") then
			local nt = string.gsub(cand.text, "\\r", utf8.char(13))
			local cnd = Candidate("", cand.start, cand._end, nt, cand.comment)
			yield(cnd)
		else
			yield(cand)
		end
	end
end

function test(input, seg)
	local cand = "                    后宮詞\r              白居易【唐代】\r泪湿罗巾梦不成，夜深前殿按歌声。\r红颜未老恩先断，斜倚薰笼坐到明。"
	if string.match(input, "^/bjy$") then
		local pth = package.path
		--local ss = string.gsub(pth, ";", "\r")
		yield(Candidate("time", seg.start, seg._end, cand, ""))
		yield(Candidate("time", seg.start, seg._end, utf8.char(0x30000), ""))
		yield(Candidate("time", seg.start, seg._end, utf8.char(0x30001), ""))
		yield(Candidate("time", seg.start, seg._end, utf8.char(0x30002), ""))
		--yield(Candidate("test", seg.start, seg._end, ss, ""))
	end
end

local unicode = require("unicode")();
local emoji2 = require("emoji2")();
local mydate = require("mydate")();
local english = require("english")();
local rmb = require("number")();
--local emoji = require("emoji")();

--must after function definitions
english_processor = english.processor;
english_segmentor = english.segmentor;
english_translator = english.translator;
english_filter = english.filter;
english_filter0 = english.filter0;

date_translator = mydate.date_translator;
UnicodeTranslator  = unicode.UnicodeTranslator;
Emoji_Translator = emoji2.Emoji_Translator;
daxie_translator = rmb.daxie_translator;
