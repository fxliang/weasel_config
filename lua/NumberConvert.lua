 --region : NumConvert.lua
 --Date   : 2017-5-11
 --Author : david
 -- Bin 2
 -- Oct 8
 -- Dec 10
 -- Hex 16
 local _convertTable = {
     [0] = "0",
     [1] = "1",
     [2] = "2",
     [3] = "3",
     [4] = "4",
     [5] = "5",
     [6] = "6",
     [7] = "7",
     [8] = "8",
     [9] = "9",
     [10] = "A",
     [11] = "B",
     [12] = "C",
     [13] = "D",
     [14] = "E",
     [15] = "F",
     [16] = "G",
 }
 
 local function GetNumFromChar(char)
     for k, v in pairs(_convertTable) do
         if v == char then return k end
     end
     return 0
 end
 
 local function Convert(dec, x)
     local function fn(num, t)
         if(num < x) then
             table.insert(t, num)
         else
             fn( math.floor(num/x), t)
             table.insert(t, num%x)
         end
     end
     local x_t = {}
     fn(dec, x_t, x)
     return x_t
 end
 
 function ConvertDec2X(dec, x)
     local x_t = Convert(dec, x)
     local text = ""
     for k, v in ipairs(x_t) do
         text = text.._convertTable[v]
     end
     return text
 end
 
 function ConvertStr2Dec(text, x)
     local x_t = {}
     local len = string.len(text)
     local index = len
     while ( index > 0) do
         local char = string.sub(text, index, index)
         x_t[#x_t + 1] = GetNumFromChar(char)
         index = index - 1
     end
     local num = 0
     for k, v in ipairs(x_t) do
         num = num + v * math.pow(x, k - 1) 
     end
     return num
 end
