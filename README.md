
##### **使用帮助**

​`Project introduction: tinym是小型微服务框架. 适用于轻量级业务快速搭建`​

**Usage**: tinym listen password cert.pem privkey.pem ca.pem  
    listen: `服務端監聽的IP和端口`​  
    password: `可選參數, 管理員密碼, 用於生成管理員Cookie`​  
    cert: `可選參數, 服務端支持SSL模式, PEM格式證書文件`​  
    privkey: `可選參數, 服務端支持SSL模式, PEM格式私鑰文件`​  
    verify_ca: `可選參數, Used for Mutual SSL, 用於雙向SSL時驗證客戶端證書`​  

```bash
#基础启动. 默认密码为空
tinym 0.0.0.0:443
#管理员密码启动
tinym 0.0.0.0:443 123456
#微服务框架升级为SSL
tinym 0.0.0.0:443 123456 cert.pem privkey.pem
#微服务框架升级为Mutual SSL
tinym 0.0.0.0:443 123456 cert.pem privkey.pem ca.pem
```

##### 基本概念

###### 能力主机

```c
提供计算能力的机器. 通过login接口登录到微服务框架
用户提供微服务框架基础接口或插件提供的上层接口最终调用能力主机提供的计算能力
```

###### 数据封包

```c
#packet32 隐式约定length <= 0xFFF000 (等效packet24)
{uint32_t length; uint8_t data[];} 其中length为网络序.

#packet24 限制单个数据包大小(0xFFF000)
union u32_t {
	struct {
		uint32_t length : 24;
		uint32_t __zero: 8;
	};
	uint32_t val;
};
{u32_t u32; uint8_t data[];} 其中u32为网络序.
```

###### 权限要求

```c
来自127.0.0.1的所有请求均不受权限要求限制

无: 任意用户可调用
Cookie授权: 用户请求使用的cookie已经被授权.
管理员权限: 用户请求使用的cookie为管理员权限的cookie.

管理员权限生成方式:
function numberToBuffer(number, length)
    local buffer = {};
    for i = 0, length - 1 do
        table.insert(buffer, string.char(number % 256));
        number = math.floor(number / 256);
    end
    return table.concat(buffer);
end
function gen_admin_cookie(password)
	local t = math.floor(os.time() / 60);
	local k = password .. numberToBuffer(t, 8);
	local buf = rc4(k, k);
	local b64 = base64_encode(buf); --urlsafe模式
	return b64;
end
当启动tinym不指定密码时password="";
```

###### 接口重载

```c
表示接口是否会被插件注册的接口重载
例如如果通过插件接口注册"/list", 用户发起的所有"/list"请求均被插件响应
(不再是微服务框架的/list功能)
目前只有插件接口本身不可被重载(/plugin?)
```

‍

##### **基础接口**

###### 注册接口

```c
接口重载: 可重载
权限要求: 无
URI: /login?mid=1a001b00&version=1&addr=100.2.1.77&name=md5srv
用于注册能力主机. 能力主机注册成功返回HTTP 200.
注册成功后当前HTTP所属TCP链接变成能力主机与微服务框架双向通信的隧道.
mid: 长度小于63的字符串. 可以是数字、base64、guid, 没有严格限制
version: 32位数字.
addr: 能力主机的IP地址. 不强制要求为公网IP
name: 能力主机名字. 例如md5srv, 为了更好的标记该能力主机提供md5计算服务

能力主机与微服务框架直接的通信使用packet32数据封包. 其中数据遵守如下协议:
//微服务框架 --> 能力主机
struct Tinym2CM {
	uint32_t taskid;
	uint8_t op;
	uint8_t data[];
};
当op为0时可以理解成是空闲包. 用于能力主机与微服务框架之间的心跳.
心跳遵循如下原则:
a.能力主机在未收到Tinym2CM时主动给微服务框架发送CM2Tinym(taskid=0)
b.微服务框架回应能力主机空闲包Tinym2CM(op=0)
c.能力主机收到空闲包Tinym2CM(op=0)直接丢弃不做任何处理.

//能力主机 --> 微服务框架
struct CM2Tinym {
	uint32_t taskid;
	uint8_t __padding;
	uint8_t fragment; // NoFragment(0) Fragment(1) FragmentEOF(2)
};
当能力主机返回fragment为Fragment(1)时，微服务框架通过chunked形式返回用户HTTP请求.
直到能力主机返回FragmentEOF(2)微服务框架完成chunked返回.
fragment旨在解决单个数据包过大问题.
```

###### 枚举接口

```c
接口重载: 可重载
权限要求: Cookie授权
URI:  /list
枚举接口用于枚举通过login登录的能力主机. 返回能力主机的mid列表. 使用\n分割
```

###### 短隧道接口

```c
接口重载: 可重载
权限要求: Cookie授权
URI: /stunnel?mid=1a001b00&function=1a&nowait=1
用于用户向能力主机发起单次请求. 例如计算一段数据的md5
mid: 指明请求是发给哪个能力主机的
function: 微服务框架会按照16进制数解析并填充Tinym2CM中的op字段.
nowait: 可选参数. 当nowait=1时微服务框架不等待能力主机返回，直接完成用户HTTP请求. 用于单向请求.
```

###### 长隧道接口

```c
接口重载: 可重载
权限要求: Cookie授权
URI:  /ltunnel?mid=1a001b00
用于在用户与能力主机之间建立一个长链接隧道.
mid: 指明请求是发给哪个能力主机的

成功返回HTTP 200. HTTP Content返回二进制数据(taskid)为网络序.
隧道建立成功后. 用户与能力主机直接具备双向通信能力.
用户需自行解析与打包Tinym2CM与CM2Tinym. 用户侧使用packet24数据封包
(微服务框架会将能力主机的packet32转为packet24. 这就是packet32隐式限制length <= 0xFFF000)
```

###### 获取能力主机信息接口

```c
接口重载: 可重载
权限要求: Cookie授权
URI: /dump?mid=1a001b00
mid: 指明获取哪个能力主机的信息

返回二进制格式数据
local stream = NetStream();
stream:write(content);
stream:read32();
stream:read32();
stream:read64();
time = stream:read64();
stream:read32();
stream:read32();
ipaddr = to_ipaddr_string(stream:read32());
version = stream:read32();
local len = stream:read32();
name = stream:read(len);
解析出对应login接口的信息. 其中IP地址是采用uint32存储使用to_ipaddr_string转成字符串形式.

function to_ipaddr_string(int32)
    local b1 = math.floor(int32 / 16777216) % 256;
    local b2 = math.floor(int32 / 65536) % 256;
    local b3 = math.floor(int32 / 256) % 256;
    local b4 = int32 % 256;
    return string.format("%d.%d.%d.%d", b4, b3, b2, b1);
end
```

###### 监听能力主机上线或下线通知

```c
接口重载: 可重载
权限要求: 管理员权限
URI: /watch
调用成功后建立长链接. 接收来自微服务框架的chunked包. 
每个chunked代表一个能力主机上线或者下线
{"mid":"1a001b00", "status":1, "addr":"100.2.1.77", "version":1}
其中status为1代表能力主机上线. 为0代表能力主机下线.
```

###### 校验Cookie是否被授权

```c
接口重载: 可重载
权限要求: 无
URI: /check_cookie
微服务框架会从HTTP Header中取出Cookie并判断是否被授权
```

###### 设置Cookie授权

```c
接口重载: 可重载
权限要求: 管理员权限
URI: /set_cookie?cookie=YmFzZTY0&expire=1800000
cookie: 被设置授权的Cookie
expire: 过期时间. 单位毫秒
```

###### 注册插件接口

```c
接口重载: 不可重载
权限要求: 管理员权限
URI: /plugin?function=set
该请求必须为HTTP Post. content为注册的过滤表达式

过滤表达式支持如下形式:
字符串匹配: 
	最高优先级. 高于微服务框架.

正则表达式: 
	第二高优先级. 高于微服务框架.

通用接管: 
	"*"作为通用接管规则. 在整套体系中是最低匹配优先级. 也就是无人处理的请求会转发给注册"*"的插件.


当插件注册成功后. 插件与微服务框架之间建立双向通信隧道:

数据封包使用packet32
//微服务框架 --> 插件
	struct {
		uint8_t version; //协议版本 固定为0
		uint8_t from;
		uint32_t mid_len;
		uint8_t mid[]; --from为CLI时 mid为用户请求包含的mid
		uint32_t taskid; 
		uint32_t ipaddr; --from为CLI时 ipaddr为用户的IP地址
		uint32_t len; --数据长度
		uint8_t data[]; -- from为CLI时 data部分为HTTP请求头
	};
// 插件 --> 微服务框架
	struct {
		uint8_t version; //协议版本 固定为0
		uint8_t to;
		uint32_t taskid;
		uint32_t len; --数据长度
		uint8_t data[]; -- to为CLI时 data部分为HTTP响应头
	};

其中from与to
#define CLI 1  
#define HEARTBEAT 3 
#define CLIQUIT 4

CLI 
--用户的请求

HEARTBEAT 
--心跳包. 插件主动发给微服务框架. 微服务框架收到后会应答同样的心跳包

CLIQUIT 
--微服务框架主动发给插件, 表示请求的用户链接已断开，插件自行清理资源
--插件主动发给微服务框架, 表示要求微服务框架断开用户请求的链接

```

###### 枚举插件接口

```c
接口重载: 不可重载
权限要求: 管理员权限
URI: /plugin?function=list

返回插件过滤表达式以及IP地址列表. "\n"分割

```

‍
