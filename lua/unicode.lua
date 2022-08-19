local function unicode()
	-- Unicode quick input
	function UnicodeTranslator(input, seg)
		if string.match(input, "^U%x+") or string.match(input, '^/uc%x+') then
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
		end
	end
end

return unicode

