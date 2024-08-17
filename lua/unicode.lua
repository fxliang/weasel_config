require("NumberConvert")
-- Unicode quick input
---@param input string
---@param seg SegmentReg
local function Unicode_Translator(input, seg, env)
	if not (input:match("^U") or input:match("^/uc") or input:match("^/ur") or input:match("^/un%x+$")) then return end
	local segment = env.engine.context.composition:back()
	if input:match("^U$") or input:match("^/uc$") then
		segment.prompt = "输入[0-9a-fA-F],以[^0-9a-fA-F]分割两个字符，Unicode"
	end
	if input:match("^U%x+") or input:match('^/uc%x+') then
		local cand = ''
		local cmt = ''
		local rinput = ''
		if string.match(input, "^/uc%x+") then
			rinput = string.sub(input, 4)
		else
			rinput = string.sub(input, 2)
		end
		for s in string.gmatch(rinput, '%x+') do
			if(tonumber(s, 16) >= 0x20 and tonumber(s, 16) <= 0x10ffff) then
				cand = cand .. utf8.char(tonumber(s, 16))
				cmt = cmt .. '\\u+' .. string.upper(s)
			end
		end
		if cand ~= "" then
			local cc = Candidate("Unicode", seg.start, seg._end, cand, cmt)
			yield(cc)
		end
	elseif input:match("^/ur%x+-%x+") then
		local st_ = input:sub(4)
		st_ = string.match(st_, "^%x+")
		local end_ = input:match("-%x+")
		end_ = string.sub(end_, 2)
		local st__ = tonumber(st_, 16)
		local end__ = tonumber(end_, 16)
		if end__ < st__ or end__ > 0x10ffff or st__ > 0x10ffff then return end
		local txt = ""
		for c = st__, end__ do 
			txt = txt .. utf8.char(c)
		end
		local cmt = "\\u+" .. st_:upper() .. " ~ " .. "\\u+" .. end_:upper()
		local cc = Candidate("Unicode", seg.start, seg._end, txt, cmt)
		yield(cc)
	elseif input:match("^/un%x+$") then
		local st_ = input:match("^/un(%x+)$")
		local st__ = tonumber(st_, 16)
		local end__ = st__ + 0xff
		if st__ < 0x20 then return end
		for c = st__, end__ do 
			local txt = utf8.char(c)
			local cmt = '\\u+' .. ConvertDec2X(c, 16)
			local cc = Candidate("Unicode", seg.start, seg._end, txt, cmt)
			yield(cc)
		end
	end
end

return {func = Unicode_Translator}

