require("NumberConvert")
local Rngs = {
	a = {_start = 0xe000, _end = 0xe00e},
	b = {_start = 0xe00f, _end = 0xe01d},
	c = {_start = 0xe01e, _end = 0xe026},
	d = {_start = 0xe027, _end = 0xe034},
	e = {_start = 0xe035, _end = 0xe048},
	f = {_start = 0xe049, _end = 0xe052},
	g = {_start = 0xe053, _end = 0xe058},
	h = {_start = 0xe059, _end = 0xe068},
	i = {_start = 0xe069, _end = 0xe078},
	j = {_start = 0xe079, _end = 0xe086},
	k = {_start = 0xe087, _end = 0xe091},
	l = {_start = 0xe092, _end = 0xe0a6},
	m = {_start = 0xe0a7, _end = 0xe0b1},
	n = {_start = 0xe0b2, _end = 0xe0bd},
	o = {_start = 0xe0be, _end = 0xe0ce},
	p = {_start = 0xe0cf, _end = 0xe0e0},
	q = {_start = 0xe0e1, _end = 0xe0ef},
	r = {_start = 0xe0f0, _end = 0xe0fb},
	s = {_start = 0xe0fc, _end = 0xe109},
	t = {_start = 0xe10a, _end = 0xe114},
	u = {_start = 0xe115, _end = 0xe121},
	v = {_start = 0xe122, _end = 0xe131},
	w = {_start = 0xe132, _end = 0xe138},
	x = {_start = 0xe139, _end = 0xe145},
	y = {_start = 0xe146, _end = 0xe14c}
}
function Wubi091zg_Translator(input, seg, eng)
	if input:match("^/w[a-z]$") then
		local data = Rngs[ input:match("^/w(.)$") ]
		if not data then return end
		for idx = data._start, data._end do
			--print(idx, ConvertDec2X(idx, 16), utf8.char(idx))
			yield(Candidate("wubi091", seg._start, seg._end, utf8.char(idx), '\\u+' .. ConvertDec2X(idx, 16)))
		end
	end
end
