-- zip C樣式API. handle需要zip_close避免資源泄露

-- 創建zip對象
handle = zip_create();
-- 打開内存中的zip對象
handle = zip_openbuffer(buf);
-- 打開zip文件
handle = zip_open(path);
-- 關閉zip對象. 無返回.
zip_close(handle);
-- 刪除zip對象中的資源
zip_remove(handle, "entry/entry_name");
-- 獲取zip對象序列化到buf所需大小
len = zip_getsize(handle);
-- 把zip對象序列化到buf. 失敗返回nil
buf = zip_writeToBuffer(handle);
-- 把zip對象序列化到文件. 返回類型為boolean
zip_writeTo(handle, "1.zip");
-- 在zip對象中添加entry. 返回類型為boolean
zip_add_entry(handle, "entryName", attr, "\x01\x02\x03");
-- 獲取zip對象中entry的内容. 失敗返回nil
buf = zip_get_entry(handle, "entryName");
-- 枚舉zip對象中的資源. 無返回. 回調中可以獲取到handle和entryName進行操作.
zip_foreach(handle, function(handle, entryName)  end);
