assert(argc == 3);
local path = argv[3];
assert(type(path) == "string");

function luac(script)
	local func, err = load(script);
	if not func then
		return nil;
	end
	return string.dump(func);
end

local c = luac(file_read(path));
if c then
    file_write(path .. "c", c);
end
