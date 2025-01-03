-- C樣式二進制緩存qbuf API. 需要調用qbuf_free釋放資源. qbuf(隊列緩存).
-- read 與 peek 的區別. read會改變緩存大小而peek不會.

-- 創建qbuf. 失敗返回nil
qbuf = qbuf_alloc();
-- 重置(清空)qbuf. 無返回
qbuf_reset(qbuf);
-- 清空并且釋放qbuf. 無返回
qbuf_free(qbuf);
-- 返回qbuf緩存長度
len = qbuf_length(qbuf);
-- 寫入數據到qbuf. 返回errno
err = qbuf_write(qbuf, "\x01\x02\x03");
-- 讀取qbuf. 失敗返回nil
buf = qbuf_read(qbuf, size);
-- 讀取指定offset的内容. 失敗返回nil
buf = qbuf_peeki(qbuf, offset, size);
-- 讀取qbuf. 失敗返回nil
buf = qbuf_peek(qbuf, size);
-- 查找指定内容. 失敗返回nil. 成功返回指定内容的offset.
offset = qbuf_find(qbuf, "\r\n\r\n");
-- 取指定類型的數字. 失敗返回nil. 
val = qbuf_peek8(qbuf);
val = qbuf_peek16(qbuf);
val = qbuf_peek32(qbuf);
