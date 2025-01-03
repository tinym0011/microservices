-- sqlite3 C樣式API.

-- 打開或創建db. 失敗返回nil
db = sqlite3_open("xx.db");
-- 打開或創建db. 失敗返回nil. 具體參見sqlite3 C API.
-- flags 類型為number
-- zVfs 類型為string
db = sqlite3_open_v2("xx.db", flags, zVfs);
-- 關閉db. 無返回值
sqlite3_close(db);
-- 失敗返回nil. 需要調用sqlite3_finalize釋放mt. 具體參見sqlite3 C API. 
mt = sqlite3_prepare(db, sql);
-- 釋放mt. 無返回值
sqlite3_finalize(mt);
-- 返回類型number. 具體參見sqlite3 C API. 
column_count = sqlite3_column_count(mt);
-- 返回類型number. 具體參見sqlite3 C API. 
type = sqlite3_column_type(mt, index);
-- 返回類型string. 具體參見sqlite3 C API. 
name = sqlite3_column_name(mt, index);

-- 返回類型string. 具體參見sqlite3 C API. 
val = sqlite3_column_text(mt, index);
val = sqlite3_column_blob(mt, index);

-- 返回類型number. 具體參見sqlite3 C API. 
val = sqlite3_column_int(mt, index);
val = sqlite3_column_double(mt, index);
val = sqlite3_column_int64(mt, index);

-- sql語句bind參數. 具體參見sqlite3 C API. 
err = sqlite3_bind_text(mt, index, arg);
err = sqlite3_bind_double(mt, index, arg);
err = sqlite3_bind_int(mt, index, arg);
err = sqlite3_bind_int64(mt, index, arg);
err = sqlite3_bind_blob(mt, index, arg);

-- 執行sql語句. 具體參見sqlite3 C API. 
err = sqlite3_step(mt);

-- 設置數據庫變更通知.
-- 返回. 設置失敗返回nil. 取消設置無返回值.
function callback(operation, database, table, rowid)
    -- operation(number). 操作類型. 具體參見sqlite3 C API. 
    -- database(string). 數據庫名
    -- table(string). 表名
    -- rowid(number). 通過rowid可查詢具體的變更内容.
    -- string.format("SELECT * FROM %s.%s WHERE rowid = %d", database, table, rowid)
end
handle = sqlite3_update_hook(db, callback);
sqlite3_update_hook(db, handle); --取消設置
