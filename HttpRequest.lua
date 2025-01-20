-- Http客戶端
-- 所有成員函數均返回boolean類型.

--創建Http客戶端實例對象.
local req = HttpRequest(); 

-- 可選. 設置使用使用Tls(Https). 默認不使用Tls
-- req:setTls(use_tls); 

-- 可選. 用於判斷服務端證書是否合法. PEM格式.
-- req:setCA(verfiy_serv_ca); 

-- 可選. 用於雙向驗證的Tls通信. PEM格式.
-- req:setClientCert(cert);
-- req:setClientPrivateKey(privkey);

-- 可選. 用於同步請求. 如果設置同步模式必須在req:Request之後調用req:wait()等待完成;
-- 會使用獨立的UVLoop執行請求. 請注意代碼邏輯是否會造成死鎖.
-- req:setSync();

-- 可選. 設置請求使用代理. 支持socks4. socks5
-- version設置4為socks4. 5為socks5.
-- req:setProxy(version, "127.0.0.1", 8080);

-- 可選. 覆蓋請求的HTTP Header的Host字段.
-- req:setHost(host);
-- 可選. 用於Tls通信設置SNI. 設置Tls后SNI為必選
-- req:setSni(sni);

-- 可選. 設置HTTP Header的Cache字段.
-- req:setCache("no-cache");

-- 可選. 設置HTTP Header.
-- req:setHeader("Cookie", "MTIz");

-- 可選. 設置請求的方法. 默認為GET.
-- req:setMethod("POST");
-- req:setContent(content);

-- 可選. 設置UserAgent
-- req:setUserAgent("X-luac");

-- 可選. 設置接收chunked是否分段返回. 默認false.
-- 如果設置分段返回每接收到一個chunked會調用Request請求時設置的接收回調.
-- 如果不設置會等待接收完所有的chunked進行統一一次回調.
-- req:setFragment(true);

-- 可選. 設置是否接收HTTP Header. 默認false.
-- 如果設置為true接收回調收到的内容會包含HTTP Header. 會多一次回調.
-- req:setRecvHeader(true);

-- 必選. 設置請求的IP地址與端口
req:setIpAddr("127.0.0.1");
req:setPort(80);
-- 必選. 設置請求的URI
req:setUri("/test");

-- 必選. 發起請求.
-- 參數1. 結果返回回調.
-- 參數2. 鏈接結束回調.
req:Request(
  function(code, res)
      -- on_recv
      -- code 為HTTP Code. assert(type(res) == "number");
      -- res 為接收到的内容. assert(type(res) == "string");
  end,
  function()
      -- on_close
      -- 被調用后req不可用. 資源已經釋放.
  end
);

-- 可選. 如果調用req:setSync()設置為同步模式則為必須等待請求完成. 
-- req:wait();

-- 可選. 結束當前請求. 可用於超時機制終止請求.
-- 默認鏈接結束會自動close釋放資源.
-- req:close();
