-- 二進制序列化與反序列化對象. NetStream會自動析構釋放資源.

-- 創建對象
-- 失敗返回nil. 成功返回對象句柄.
stream = NetStream();

-- 寫入uint8. 返回值為boolean類型.
stream:write8(12);
-- 寫入uint16. 網絡序. 返回值為boolean類型.
stream:write16(12);
-- 寫入uint32. 網絡序. 返回值為boolean類型.
stream:write32(12);
-- 寫入uint64. 網絡序. 返回值為boolean類型.
stream:write64(12);
-- 寫入buf.  返回值為boolean類型.
stream:write("\x01\x02\x03");

-- 取uint8. 不影響NetStream緩存大小. 失敗返回nil.
val = stream:peek8();
-- 取uint16. 不影響NetStream緩存大小. 返回值調整為主機序. 失敗返回nil.
val = stream:peek16();
-- 取uint32. 不影響NetStream緩存大小. 返回值調整為主機序. 失敗返回nil.
val = stream:peek32();
-- 取uint64. 不影響NetStream緩存大小. 返回值調整為主機序. 失敗返回nil.
val = stream:peek64();
-- 取len長度的内容. 不影響NetStream緩存大小. 失敗返回nil.
buf = stream:peek(len);

-- 取uint8. 影響NetStream緩存大小. 失敗返回nil.
val = stream:read8();
-- 取uint16. 影響NetStream緩存大小. 返回值調整為主機序. 失敗返回nil.
val = stream:read16();
-- 取uint32. 影響NetStream緩存大小. 返回值調整為主機序. 失敗返回nil.
val = stream:read32();
-- 取uint64. 影響NetStream緩存大小. 返回值調整為主機序. 失敗返回nil.
val = stream:read64();
-- 取len長度的内容. 影響NetStream緩存大小. 失敗返回nil.
buf = stream:read(len);

-- 獲取NetStream緩存大小.
-- 返回. 失敗返回nil. 成功返回number類型的長度.
len = stream:size();

-- 重置(清空)NetStream緩存.
-- 返回. 失敗返回nil. 成功返回true.
stream:reset();

-- 返回NetStream整體緩存. 不影響NetStream緩存大小. 
-- 返回. 失敗返回nil. 成功返回string類型的buf.
buf = stream:toString();
