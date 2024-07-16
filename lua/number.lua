local confs = {
	{
		comment = " 大写",
		number = { [0] = "零", "壹", "贰", "叁", "肆", "伍", "陆", "柒", "捌", "玖" },
		suffix = { [0] = "", "拾", "佰", "仟" },
		suffix2 = { [0] = "", "万", "亿", "万亿", "亿亿" },
		unit = '元'
	},
	{
		comment = " 小写",
		number = { [0] = "零", "一", "二", "三", "四", "五", "六", "七", "八", "九" },
		suffix = { [0] = "", "十", "百", "千" },
		suffix2 = { [0] = "", "万", "亿", "万亿", "亿亿" },
		unit = '元'
	},
	{
		comment = " 大寫",
		number = { [0] = "零", "壹", "貳", "參", "肆", "伍", "陸", "柒", "捌", "玖" },
		suffix = { [0] = "", "拾", "佰", "仟" },
		suffix2 = { [0] = "", "萬", "億", "萬億", "億億" },
		unit = '圆'

	},
	{
		comment = " 小寫",
		number = { [0] = "零", "一", "二", "三", "四", "五", "六", "七", "八", "九" },
		suffix = { [0] = "", "十", "百", "千" },
		suffix2 = { [0] = "", "萬", "億", "萬億", "億億" },
		unit = '圆'

	},
}

local function read_seg(conf, n)
	local s = ""
	local i = 0
	local zf = true

	while string.len(n) > 0 do
		local d = tonumber(string.sub(n, -1, -1))
		if d ~= 0 then
			s = conf.number[d] .. conf.suffix[i] .. s
			zf = false
		else
			if not zf then
				s = conf.number[0] .. s
			end
			zf = true
		end
		i = i + 1
		n = string.sub(n, 1, -2)
	end

	return i < 4, s
end

local function read_number(conf, n)
	local s = ""
	local i = 0
	local zf = false

	n = string.gsub(n, "^0+", "")

	if n == "" then
		return conf.number[0]
	end

	while string.len(n) > 0 do
		local zf2, r = read_seg(conf, string.sub(n, -4, -1))
		if r ~= "" then
			if zf and s ~= "" then
				s = r .. conf.suffix2[i] .. conf.number[0] .. s
			else
				s = r .. conf.suffix2[i] .. s
			end
		end
		zf = zf2
		i = i + 1
		n = string.sub(n, 1, -5)
	end
	return s .. conf.unit
end

local function read_digit(conf, jiao, fen)
	local s = ""
	if jiao ~= 0 then
		s = s .. conf.number[jiao] .. '角'
	end
	if fen ~= 0 then
		s = s .. conf.number[fen] .. '分'
	end
	return s
end

local function split(input, delimiter)
	input = tostring(input)
	delimiter = tostring(delimiter)
	if (delimiter == "") then return false end
	local pos, arr = 0, {}
	for st, sp in function() return string.find(input, delimiter, pos, true) end do
		table.insert(arr, string.sub(input, pos, st - 1))
		pos = sp + 1
	end
	table.insert(arr, string.sub(input, pos))
	return arr
end

local function Daxie_Translator(input, seg, env)
	local segment = env.engine.context.composition:back()
	if not input:match("^/dx") then return end
	segment.prompt = "/dx\\d\\+(.\\d\\d)?大写金额" 
	if string.match(input, '^/dx%d+') then
		local num = split(string.sub(input, 4), '.')[1]
		local digit = split(string.sub(input, 4), '.')[2]

		local jiao = 0
		local fen = 0

		if digit ~= nil then
			digit = string.sub(digit, 1 )
			jiao = tonumber(string.sub(digit, 1, 1))
			if string.len(digit) > 1 then
				fen = tonumber(string.sub(digit, 2, 2))
			end
		end
		for _, conf in ipairs(confs) do
			local r = read_number(conf, math.floor(num))
			local d = read_digit(conf, jiao, fen)
			yield(Candidate("number", seg.start, seg._end, r..d, conf.comment))
		end
	end
end

local function calc(input, seg, env)
	if string.match(input, '^C=.*$') then
		local exp = string.sub(input, 3)
		local f, err = load('return ' .. exp)
		if f then
			local res = f()
			if res then
				yield(Candidate("calc", seg.start, seg._end, tostring(res), input:sub(3) .. '='))
			end
		end
	end
end

local function hex(input, seg, env)
	if input:match('^/hex[0-9]+$') or input:match('^/Hex[0-9]+$') then
		yield(Candidate("hex", seg.start, seg._end, string.format('%x', tonumber(input:sub(5))), 'hex('..input:sub(5) .. ')'))
	elseif input:match('^H[0-9]+$') then
		yield(Candidate("hex", seg.start, seg._end, string.format('%X', tonumber(input:sub(2))), 'hex('..input:sub(2) .. ')'))
	end
end

local function dec(input, seg)
	if input:match('^/dec[0-9a-fA-F]+$') or input:match('^/Dec[0-9a-fA-F]+$') then
		yield(Candidate('dec', seg._start, seg._end, tonumber(input:sub(5), 16), 'dec(' .. input:sub(5) .. 'h)'))
	elseif input:match('^D[0-9a-fA-F]+$') then
		yield(Candidate('dec', seg._start, seg._end, tonumber(input:sub(2), 16), 'dec(' .. input:sub(2) .. 'h)'))
	end
end

return {func = Daxie_Translator, calc = calc, hex=hex, dec=dec}
