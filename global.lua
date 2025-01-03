
-- 全局變量
if LUAJIT ~= nil then
    assert(type(LUAJIT) == "number");
    print("LUAJIT: " .. tostring(LUAJIT));
end
assert(type(LUA_VERSION_NUM) == "number");
print("LUA_VERSION_NUM: " .. tostring(LUA_VERSION_NUM));
assert(type(argc) == "number");
print("argc: " .. tostring(argc));
for i = 1, argc do
    assert(type(argv[i]) == "string");
    print("argv[" .. i .. "]: " .. tostring(argv[i]));
end

--json庫
tbl = json.decode([[{"a": 1}]]);
assert(tbl.a == 1);
str = json.encode(tbl);
assert(type(str) == "string");

--dingtalk庫
local access_token = "";
local secret_key = "";
local msg = "";
local ret = dingtalk.send(access_token, secret_key, msg);
assert(type(ret) == "boolean");

-- 全局函數. 等待UV loop執行
wait();

-- 全局函數. 
local msec = 100;
sleep(msec);

-- 全局函數. 高精度時間戳.
local tval = hrtime(); -- tval * 1000000 == ms
sleep(msec);
tval = hrtime() - tval;
assert(tval >= 100 * 1000000);
print("hrtime: " .. tval);
print("hrtime: " .. (tval / 1000000) .. " msec");

-- 全局函數. 創建進程.
-- 支持多個參數. 可選
-- 支持進程退出回調. 可選.
-- 返回pid. 創建進程失敗返回0
function exit_callback(pid)
    assert(type(pid) == "number");
end
pid = exec("cmd.exe", "arg1", "arg2", exit_callback);
assert(type(pid) == "number");
print("exec: " .. pid);

-- 全局函數. 給進程發信號.
-- 注意 pid = 0; 會結束自身進程.
-- signum = 9; 結束進程.
-- signum = 0; 判斷進程是否存在.
-- 返回errno.
local signum = 9;
local err = kill(pid, signum);
assert(type(err) == "number");
print("kill: " .. err);

-- 全局函數. 獲取當前工作目錄.
local cwd = getcwd();
assert(type(cwd) == "string");
print("getcwd: " .. cwd);

-- 全局函數. rc4加解密.
-- 返回: 失敗返回nil. 成功返回string.
local key = "123";
local inp = "12345678";
local outp = rc4(key, inp);
assert(type(outp) == "string");
assert(rc4(key, outp) == inp);

-- 全局函數. base64編碼統一采用URLSafe模式.
local str = "123";
local b64 = base64_encode(str);
assert(type(b64) == "string");
assert(str == base64_decode(b64));
print("base64_encode: " .. b64);

-- 全局函數. 引入特定庫. 目前僅支持pb.
-- 詳細支持: https://github.com/starwing/lua-protobuf
pb = openlib("pb");
assert(pb ~= nil);

-- 全局函數. 定時器.
-- delay_ms 延遲多久執行
-- repeat_ms 如果不爲0. 會每隔repeat_ms時間執行一次.
-- 返回handle. 失敗為nil
local delay_ms = 1000;
local repeat_ms = 0;
tval = hrtime();
handle = timer.exec(delay_ms, repeat_ms, 
    function() 
        print("timer.exec: " .. ((hrtime() - tval) / 1000000)); 
    end
);
wait();

-- 全局函數. 關閉定時器. 無返回值.
timer.close(handle);

-- 全局函數. 讀文件.
-- 失敗返回 nil. 成功返回string為文件内容.
local path = "test.bin";
assert(file_read(path) == nil);

-- 全局函數. 寫文件.
-- 返回boolean類型. 
path = "";
local ret = file_write(path, "");
assert(type(ret) == "boolean");
print("file_write: " .. tostring(ret));
