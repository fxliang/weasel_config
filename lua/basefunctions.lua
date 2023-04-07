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

-- global lua help tips
function Lua_Tips(input,seg, env)
	if input:match("^/$") then 
		local segment = env.engine.context.composition:back()
		segment.prompt = "~? [获得输入帮助]"
		return
	end
	if input:match("^/%?$") then
		local segment = env.engine.context.composition:back()
		segment.prompt = "Lua快捷输入帮助"
		local emoji_tips = Emoji_Tips()
		local daxie_tips = Daxie_Tips()
		local unicode_tips = Unicode_Tips()
		local date_tips = Date_Tips()
		yield(Candidate("tips", seg._start, seg._end, emoji_tips, ""))
		yield(Candidate("tips", seg._start, seg._end, date_tips, ""))
		yield(Candidate("tips", seg._start, seg._end, unicode_tips, ""))
		yield(Candidate("tips", seg._start, seg._end, daxie_tips, ""))
	end
end
-- 在词典里面候选支持\r, \r\n, \n, <br>分割分行
-- &nbsp 表示空格
-- 方案patch中要添加以下两行
--  engine/filters/+:
--  - lua_filter@Multiline_filter
function Multiline_filter(input)
	for cand in input:iter() do
		local nt = cand.text
		if nt:match("\\r\\n") or nt:match("\\r") or nt:match("\\n") or nt:match("<br>") or nt:match("&nbsp") then
			nt = nt:gsub("&nbsp", " ")
			nt = nt:gsub("\\r\\n", "\r")
			nt = nt:gsub("\\r", "\r")
			nt = nt:gsub("\\n", "\r")
			nt = nt:gsub("<br>", "\r")
			local cnd = Candidate("", cand.start, cand._end, nt, cand.comment)
			yield(cnd)
		else
			yield(cand)
		end
	end
end

function Tip_Filter(input, env, cands)
	for cand in input:iter() do
		if cand.type:match("^tip") then
			cand.comment = cand.text
			cand.text = ""
		end
		yield(cand)
	end
end
