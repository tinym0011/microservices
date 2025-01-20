
-- 全局通信C樣式網絡庫

-- 創建服務端
-- 返回handle. 失敗返回nil
-- use_tls. boolean類型是否創建Tls服務端.
-- ipaddr. 監聽的IP地址. 例如"0.0.0.0"
-- port. 監聽的端口. 例如 80
-- accept_cb. 鏈接回調函數
function accept_cb(serv, wait_accept_handle)
    local session = session_alloc(SERV_USE_TLS);
    if session ~= nil then
        local function connect_cb(session_, status)
        end
        local function read_cb(session_, buf) 
        end
        local function close_cb(session_)
        end
        session_set_cb(session, connect_cb, read_cb, close_cb);
        session_accept_client(session, wait_accept_handle);
    end
end
serv = serv_create(use_tls, ipaddr, port, accept_cb);

-- 申請一個session對象. session對象同時用於服務端和客戶端.
-- USE_TLS. boolean類型. 是否為Tls模式的session對象.
-- 返回. 失敗返回nil. 成功返回一個handle.
local session = session_alloc(USE_TLS);

-- 釋放一個session對象的資源. 一般在close_cb中被調用.
-- 返回. 失敗返回nil. 成功返回true
session_free(session);

-- 為session對象設置回調函數.
-- 返回. 失敗返回nil或false. 成功返回true
session_set_cb(session, connect_cb, read_cb, close_cb);

-- 數據寫入session對象. 用於TCP發送數據.
-- buf 為 string類型
-- 返回. 失敗返回nil或false. 成功返回true
session_write(session, buf);

-- 可選函數. 設置session對象可讀狀態.
-- 默認session對象是可讀狀態. 除非調用session_read_stop停止讀.
-- 返回. 失敗返回nil或false. 成功返回true
session_read(session);

-- 可選函數. 設置session對象為不可讀狀態.
-- 返回. 失敗返回nil或false. 成功返回true
session_read_stop(session);

-- 可選函數. 用於判斷session對象是否建立鏈接成功.
-- 返回. 失敗返回nil或false. 成功返回true
session_connected(session);

-- 可選函數. 獲取session對象鏈接對端的IP地址
-- 返回. 失敗返回nil. 成功返回IP地址(string)
ipaddr = session_peername(session);

-- 可選函數. 獲取session對象鏈接對端的證書信息.
-- 返回. 失敗返回nil. 成功返回證書信息(string)
certinfo = session_peer_cert(session);

-- 用於客戶端. 初始化session對象
-- sni. 可選. 用於Tls通信的SNI. 如果session為Tls時SNI為必選.
-- verify_server_ca. 可選. 用於Tls通信驗證服務端證書.
-- cert. 可選. 用於Tls雙向通信. 服務端校驗客戶端.
-- prikey. 可選. 用於Tls雙向通信. 服務端校驗客戶端.
-- proxy_version. 可選. proxy_version設置4為使用socks4. 5為使用socks5.
-- proxy_ipaddr. 可選. 例如 "127.0.0.1"
-- proxy_port. 可選. 例如 8080
-- 返回. 失敗返回nil或false. 成功返回true
session_client_init(session, sni, verify_server_ca, cert, prikey, proxy_version, proxy_ipaddr, proxy_port);

-- 建立TCP鏈接. 用於客戶端
-- ipaddr. 連接的IP地址. 例如"0.0.0.0"
-- port. 連接的端口. 例如 80
session_connect(session, ipaddr, port);


-- 用於服務端accept客戶端鏈接
-- wait_accept_handle. accept_cb回調中的handle
-- verify_client_ca. 可選. 可為nil. 用於Tls雙向通信驗證客戶端證書. 非雙向驗證的Tls應設置為nil.
-- cert. 可選. 用於Tls服務端
-- prikey. 可選. 用於Tls服務端
-- 返回. 失敗返回nil或false. 成功返回true
session_accept_client(session, wait_accept_handle, verify_client_ca, cert, prikey);


-- 關閉session對象. 請注意關閉不等于資源釋放. 必須在close_cb中或其他位置調用session_free釋放資源.
-- 返回. 失敗返回nil. 成功返回true
session_close(session);

-- 用於生成自定義證書
-- sni. 證書使用的CN
-- 返回. 失敗返回nil
-- 返回. 成功返回3個string. 分別為ca cert prikey; 均爲pem格式. ca用於校驗cert和prikey生成的證書.
generate_cert_key(sni);
