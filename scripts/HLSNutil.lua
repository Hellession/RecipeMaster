--[[
NOTE! This utilization file is a copy of Elemental Correstialism's ECutil.lua file. It was copied into the different mod I'm making so that if ran together, they don't dirty edit each other, because probably the
EC's util will change. The table this script uses will remain the same, meaning I can't use EC and this utils at the same time!
]]

-- This util now uses a table
ECUtil = {debug = false}

function ECUtil.logEC(what)
	sb.logInfo("[EC] " .. what)
end

function ECUtil.justLog(what)
	if ECUtil.debug == true then
		sb.logInfo("[EC DEBUG] " .. ECUtil.superToString(what))
	end
end

function ECUtil.errorEC(what)
	sb.logError("[EC ERROR] Mod Elemental Correstialism by Hellession has thrown an Exception. Please contact Hellession with this error. Error: " .. what)
end

function ECUtil.logDebug(what)
	if ECUtil.debug == true then
	sb.logInfo("[EC DEBUG] " .. what)
	end
end

function ECUtil.numToWordC(number) -- C stands for Capital, turns the given number into a word starting with a capital
	if number == 0 then
		return "Zero"
	end
	if number == 1 then
		return "One"
	end
	if number == 2 then
		return "Two"
	end
	if number == 3 then
		return "Three"
	end
	if number == 4 then
		return "Four"
	end
	if number == 5 then
		return "Five"
	end
	if number == 6 then
		return "Six"
	end
	if number == 7 then
		return "Seven"
	end
	if number == 8 then
		return "Eight"
	end
	if number == 9 then
		return "Nine"
	end
	if number == 10 then
		return "Ten"
	end
	if number == 11 then
		return "Eleven"
	end
	if number == 12 then
		return "Twelve"
	end
	if number == 13 then
		return "Thirteen"
	end
	if number == 14 then
		return "Fourteen"
	end
	if number == 15 then
		return "Fifteen"
	end
	if number == 16 then
		return "Sixteen"
	end
	if number == 17 then
		return "Seventeen"
	end
	if number == 18 then
		return "Eighteen"
	end
	if number == 19 then
		return "Nineteen"
	end
	if number == 20 then
		return "Twenty"
	end
	if not number then
		ECUtil.errorEC("Incorrect value passed to the utilization function numToWordC: " .. ECUtil.superToString(number))
	end
end

-- turns TABLES into strings
function ECUtil.tostringTable(tabl)
	local toReturn = "{"
	local z = 0
	for aal,aap in pairs(tabl) do
		z = z + 1
		if type(aap) == "table" then
		toReturn = toReturn .. "[" .. tostring(aal) .. "] = " .. ECUtil.tostringTable(aap)
		else
		toReturn = toReturn .. "[" .. tostring(aal) .. "] = " .. tostring(aap)
		end
		if z < #tabl then toReturn = toReturn .. ", " end
	end
	toReturn = toReturn .. "}"
	return toReturn
end

-- LOGS any value
function ECUtil.logValue(val)
	if type(val) == "string" then
		ECUtil.logEC(val)
	elseif type(val) == "number" then
		ECUtil.logEC(tostring(val))
	elseif type(val) == "boolean" then
		ECUtil.logEC(tostring(val))
	elseif type(val) == "nil" then
		ECUtil.logEC(tostring(val))
	elseif type(val) == "function" then
		ECUtil.logEC("This is a function!")
	elseif type(val) == "table" then
		ECUtil.logEC(ECUtil.tostringTable(val))
	else
		ECUtil.logEC("Unknown data type to print, value = " .. type(val))
	end
end

-- TURNS any value into string and returns it, superior to ones above
function ECUtil.superToString(val)
	if type(val) == "string" then
		return val
	elseif type(val) == "number" then
		return tostring(val)
	elseif type(val) == "boolean" then
		return tostring(val)
	elseif type(val) == "nil" then
		return tostring(val)
	elseif type(val) == "function" then
		return ("Function. Returns: " .. val())
	elseif type(val) == "table" then
		return ECUtil.tostringTable(val)
	else
		return ("Data type unknown. Lua would say it's type is: " .. type(val))
	end
end

function ECUtil.itemDescriptorPairs(ourTable) -- iterator function, I guess

end

function ECUtil.round(what) -- lol turns out Starbound also has a round function in its lua, but whatever, mine is for my scripts
	return math.floor(what+0.5)
end

function ECUtil.roundBoundaries(what, min, max)
	local toReturn = math.floor(what+0.5)
	if toReturn < min then toReturn = min end
	if toReturn > max then toReturn = max end
	return toReturn
end

function ECUtil.decimalToHex(input)
    local b,k,out,i,d=16,"0123456789ABCDEF","",0
    while input>0 do
        i=i+1
        input,d=math.floor(input/b),input%b+1
        out=string.sub(k,d,d)..out
    end
    return out
end

-- instead of just returning a hex, it will check if its size is only 1 and will add a 0 before it. It also protects the function from returning nothing, if input is 0
function ECUtil.decimalToHexTwo(input)
    local b,k,out,i,d=16,"0123456789ABCDEF","",0
    while input>0 do
        i=i+1
        input,d=math.floor(input/b),input%b+1
        out=string.sub(k,d,d)..out
    end
		if out == "" then out = "0" end
		if string.len(out) == 1 then out = "0" .. out end
    return out
end

-- takes the input, locates any color codes and removes them. Useful for friendly item names
function ECUtil.removeColorCodes(input)
	return string.gsub(input, "%^.-;", "")
end

function ECUtil.numToLetter(input)
	if input == 1 then
		return "a"
	end
	if input == 2 then
		return "b"
	end
	if input == 3 then
		return "c"
	end
	if input == 4 then
		return "d"
	end
	if input == 5 then
		return "e"
	end
	if input == 6 then
		return "f"
	end
	if input == 7 then
		return "g"
	end
	if input == 8 then
		return "h"
	end
	if input == 9 then
		return "i"
	end
	if input == 10 then
		return "j"
	end
	if input == 11 then
		return "k"
	end
	if input == 12 then
		return "l"
	end
	if input == 13 then
		return "m"
	end
	if input == 14 then
		return "n"
	end
	if input == 15 then
		return "o"
	end
	if input == 16 then
		return "p"
	end
	if input == 17 then
		return "q"
	end
	if input == 18 then
		return "r"
	end
	if input == 19 then
		return "s"
	end
	if input == 20 then
		return "t"
	end
	if input == 21 then
		return "u"
	end
	if input == 22 then
		return "v"
	end
	if input == 23 then
		return "w"
	end
	if input == 24 then
		return "x"
	end
	if input == 25 then
		return "y"
	end
	if input == 26 then
		return "z"
	end
end


-- TABLES AND DICTIONARIES!



-- returns the key matching the value in argument val, in table arg table, using pairs() function(for dictionaries or unordered patterns)
function ECUtil.getKeyOfTableByEPairs(table, val)
	for k, e in pairs(table) do
		if e == val then
			return k
		end
	end
	return nil
end

-- returns the key matching the value in argument val, in table arg table, using ipairs() function(for arrays with strict order, but never dictionaries)
function ECUtil.getKeyOfTableByEIpairs(table, val)
	for k, e in ipairs(table) do
		if e == val then
			return k
		end
	end
	return nil
end

-- returns the key of the first entry in the table
function ECUtil.getKeyOfTableSingle(table)
	for k, e in pairs(table) do
		return k
	end
end

-- returns true, if the value in fArg matches some entry in array sArg(IPAIRS)
function ECUtil.hasMatchingVal(fArg, sArg)
	local result = false
	for _, vvvt in ipairs(sArg) do
		if fArg == vvvt then result = true end
	end
	return result
end

-- returns true, if something exists within the table
function ECUtil.contains(something, table)
	local result = false
	if table then
	for _, vvvy in pairs(table) do
		if vvvy == something then result = true end
	end
	end
	return result
end

-- returns true, if something exists within the table. This is different from contains() that it actually looks up nested tables too.
function ECUtil.containsNested(something, table)
	local result = false
	if table then
	for _, vvvy in pairs(table) do
		if type(vvvy) == "table" then if ECUtil.containsNested(something, vvvy) then result = true end else
		if vvvy == something then result = true end
		end
	end
	end
	return result
end

-- returns true, if the key something exists within this dictionary in table
function ECUtil.containsKey(something, table)
	local result = false
	for kkkyy in pairs(table) do
		if kkkyy == something then result = true end
	end
	return result
end

-- COPIED FROM THE ORIGINAL SB'S util.lua FILE, BECAUSE IT LACKS DOCS, SO I'LL JUST DO IT HERE!
-- Takes the t2 table and merges it into t1, meaning that t1 gets its stuff pre-existing matching values overriden and new values added from t2. t1 remains, t2 dies. Returns the new table.
function ECUtil.mergeTable(t1, t2)
  for k, v in pairs(t2) do
    if type(v) == "table" and type(t1[k]) == "table" then
      util.mergeTable(t1[k] or {}, v)
    else
      t1[k] = v
    end
  end
  return t1
end
