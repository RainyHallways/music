# this file should be saved as "UTF-8 with BOM"
$ErrorActionPreference = "Stop"

function Expand-ZIPFile($file, $destination) {
    $file = (Resolve-Path -Path $file).Path
    $destination = (Resolve-Path -Path $destination).Path
    $shell = new-object -com shell.application
    $zip = $shell.NameSpace($file)
    foreach ($item in $zip.items()) {
        $shell.Namespace($destination).copyhere($item)
    }
}

Write-Output '欢迎使用.Dot system一键安装脚本！'
Write-Output '版本号:2.0'
Write-Output '编写者:RainyHallways(2982383819).'

# 检查运行环境
if ($Host.Version.Major -lt 3) {
    Write-Output 'powershell 版本过低，无法一键安装'
    exit
}
if ((Get-ChildItem -Path Env:OS).Value -ine 'Windows_NT') {
    Write-Output '当前操作系统不支持一键安装'
    exit
}
if (![Environment]::Is64BitProcess) {
    Write-Output '暂时不支持32位系统'
    exit
}

if (Test-Path ./.Dot) {
    Write-Output '发现重复，是否删除旧文件并重新安装？'
    $reinstall = Read-Host '请输入 y 或 n (y/n)'
    Switch ($reinstall) { 
        Y { Remove-Item .\.Dot -Recurse -Force } 
        N { exit } 
        Default { exit } 
    } 
}

try {
    py -3.10 --version
    if ($LASTEXITCODE = '0') {
        Write-Output 'python 3.10 已发现，跳过安装'
    }
    else {
        $install_python = $true
        Write-Output 'python 3.10 未发现，将自动安装'
    }
}
catch [System.Management.Automation.CommandNotFoundException] {
    $install_python = $true
    Write-Output 'python 3.10 未发现，将自动安装'
}

New-Item -Path .\.Dot -ItemType Directory

Write-Output '让我们进行一些基础的设置吧！(请输入10-16条服务器信息)'

$qqid = Read-Host '请输入作为机器人的QQ号'
$qqpassword = Read-Host -AsSecureString '请输入作为机器人的QQ密码'
$number = Read-Host '请输入服务器号'
$sn = Read-Host '请输入服务器名称'
$password = Read-Host -AsSecureString '请输入服务器密码(没有请输入123456)'
$mpx = Read-Host '请输入主城的 x 坐标'
$mpy = Read-Host '请输入主城的 y 坐标'
$mpz = Read-Host '请输入主城的 z 坐标'
$ms = Read-Host '货币的计分板ID(不是名称)'
$robotnm = Read-Host '请输入FB辅助用户的用户名(机器人)'
$op1 = Read-Host '请输入服主的游戏名'
$op2 = Read-Host '请输入管理1的游戏名(没有请输入0)'
$op3 = Read-Host '请输入管理2的游戏名(没有请输入0)'
$op4 = Read-Host '请输入管理3的游戏名(没有请输入0)'
$op5 = Read-Host '请输入管理4的游戏名(没有请输入0)'

$loop = $true
while ($loop) {
    $loop = $false
    Write-Output '请选择下载源'
    Write-Output '1、中国大陆'
    Write-Output '2、港澳台或国外'
    $user_in = Read-Host '请输入 1 或 2'
    Switch ($user_in) {
        1 { $source_cn = $true }
        2 { $source_cn = $false }
        Default { $loop = $true }
    }
}

if ($source_cn) {
    # 中国大陆下载源
    $python310 = 'https://mirrors.huaweicloud.com/python/3.10.2/python-3.10.2-amd64.exe'
    $dotsystem = 'http://www.chatbar.menu/chatbarMenu.zip'
}
else {
    # 国际下载源
    $python310 = 'https://www.python.org/ftp/python/3.10.2/python-3.10.2-amd64.exe'
    $dotsystem = 'http://www.chatbar.menu/chatbarMenu.zip'
}

New-Item -Path .\安装库.cmd -ItemType File -Value @"
@echo off
echo If there is no red letter error, the installation is successful. Otherwise rerun.
timeout /t 2
pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple
python -m pip install --upgrade pip
pip install requests
pip install websocket-client
pip install flask
echo If there is no red letter error, the installation is successful. Otherwise rerun.
pause
"@

if ($install_python) {
    Write-Output "正在安装 python"
    Invoke-WebRequest $python310 -OutFile .\python-3.10.2.exe
    Start-Process -Wait -FilePath .\python-3.10.2.exe -ArgumentList "/quiet InstallAllUsers=1 PrependPath=1 Include_test=0"
    Write-Output "python 安装成功"
    Remove-Item python-3.10.2.exe
}

Invoke-WebRequest $dotsystem -O .\chatbarMenu.zip
Expand-ZIPFile chatbarMenu.zip -Destination .\.Dot
Remove-Item chatbarMenu.zip
Remove-Item .\.Dot\python-3.10.2-amd64.exe
Start-Process -Wait -FilePath .\安装库.cmd
Write-Output "安装成功"
Remove-Item 安装库.cmd
Remove-Item .\.Dot\安装库.cmd
Remove-Item .\.Dot\QQgroupRobot\config.yml
Remove-Item .\.Dot\QQgroupRobot\robot.py
Remove-Item .\.Dot\NeteaseServerRobot\robot.json
Remove-Item .\.Dot\NeteaseServerRobot\plugin\群服互通_def.py
Remove-Item .\.Dot\NeteaseServerRobot\plugin\basic_管理员设置_def.py
Remove-Item .\.Dot\NeteaseServerRobot\plugin\basic_主菜单_cmdsrun.py
Remove-Item .\.Dot\NeteaseServerRobot\plugin\htp玩家互传_cmdsrun.py
Remove-Item .\.Dot\NeteaseServerRobot\plugin\tpa玩家互传_cmdsrun.py
Remove-Item .\.Dot\NeteaseServerRobot\plugin\tpa玩家互传_def.py
Remove-Item .\.Dot\NeteaseServerRobot\plugin\金币银行_cmdsrun.py
Remove-Item .\.Dot\NeteaseServerRobot\plugin\协管tp到玩家_cmdsrun.py

New-Item -Path .\.Dot\NeteaseServerRobot\plugin\basic_主菜单_cmdsrun.py -ItemType File -Value @"
match msg:
        case ".help" | "help" | ".帮助": #帮助命令.
            sendcmd("/tellraw "+playername+r''' {"rawtext":[{"text":"<${sn}> \n帮助菜单\n请检查你的游戏id\n部分玩家会因为id无法正常运作"}]}''')
            sendcmd("/tellraw "+playername+r''' {"rawtext":[{"text":"输入§l.kill§r返回重生点,\n输入§l.rtp§r随机传送,\n输入§l.main§r返回主城\n输入§e.shop help§r查看商店帮助\n输入§l.gm0§r改为生存模式\n输入§l.surArea§r去生存区\n输入§a.htp§r 查看玩家互传帮助"}]}''')
            sendcmd("/tellraw "+playername+r''' {"rawtext":[{"text":"输入§l.myself§r查看个人信息\n输入§l.sendtogrp <信息>§r可将信息转发到§6Qgroup§r\n输入§b.admin§r查看管理员菜单帮助\n输入.setsp设置重生点"}]}''')
        case ".admin" | ".admin ": #管理员可以使用的命令的帮助.
            sendcmd("/tellraw "+playername+r''' {"rawtext":[{"text":"<${sn}> \n管理选项 帮助菜单\n§r输入§b.admin ban <玩家名> <时间> [理由] §r封禁玩家(仅管理可用)"}]}''')
        case ".shop help" | ".shop help ": #商店命令帮助.
            sendcmd("/tellraw "+playername+r''' {"rawtext":[{"text":"<${sn}> \n商店命令 帮助菜单\n§r输入§e.shop trans tobank <存金币数> §r可将金币存入银行\n§r输入§e.shop trans frombank <取金币数> §r可将金币从银行取出\n注意: 改游戏名前请将金币从银行全部取出, 否则银行内你存的金币会丢失.\n购买/卖出商品时会在金币余额内进行, 所以在购买前请将金币从银行取出.\n玩家间转账(还没做)会在银行余额内进行, 所以转账前请将金币存入银行."}]}''')
        case ".game" | ".game ": #小游戏的菜单
            sendcmd("/tellraw "+playername+r""" {"rawtext":[{"text":"<${sn}> game--帮助菜单\\n§a.game list §r获取当前租赁服已安装游戏列表以及房间数\\n§a.game stop §r暂停当前游戏\\n§a.game next §r继续当前游戏\\n§a.game run [游戏名] §r运行游戏"}]}""")
            sendcmd("/tellraw "+playername+r""" {"rawtext":[{"text":"§a.game exit §r退出当前游戏\\n§a.game reset §r重新启动当前游戏\\n§a.game resetall§r重制游戏加载记录\\n§a.game totp [游戏名] §r开放房间并邀请玩家进入（一次一个）\\n§a.game detotp §r取消邀请"}]}""")
            sendcmd("/tellraw "+playername+r""" {"rawtext":[{"text":"§a.game roomlist [游戏名]§r列表游戏房间（默认全部）\\n§a.game help §r打开该游戏界面帮助"}]}""")
        case ".ver" | ".version": #查看当前辅助程序版本号
            sendcmd("/tellraw "+playername+r""" {"rawtext":[{"text":"<${sn}> %s"}]}""" % version)
        case ".rtp" | ".rtp " | ".随机传送": #随机传送
            x = random.randint(-100000, 100000)
            z = random.randint(-100000, 100000)
            sendcmd("/tp "+playername+" "+str(x)+" 80 "+ str(z))
            sendcmd("/tellraw "+playername+""" {"rawtext":[{"text":"<${sn}> 已传送到"""+" "+str(x)+" 80 "+str(z)+""""}]}""")
        case ".dp": #去地皮
            sendcmd("/tp "+playername+ " 250250 125 250250")
            sendcmd("/tellraw "+playername+r""" {"rawtext":[{"text":"<${sn}> 已传送到地皮, 顺便一提, 地皮做完就是干完活了."}]}""")
        case ".kill" | ".kill ": #自杀
            sendcmd("/kill "+playername)
        case ".main" | ".main " | ".hub" | ".hub ": #回主城
            sendcmd("/tp "+playername+" ${mpx} ${mpy} ${mpz}")
            sendcmd("/tellraw "+playername+r""" {"rawtext":[{"text":"<${sn}> 传送成功."}]}""")
        case ".me" | ".me " | ".myself" | ".myself ": #个人信息
            sendcmd(r'''/execute '''+playername+'''~~~ /tellraw  @s {"rawtext":[{"text":"====${sn}====\\n玩家名称:"},{"selector":"@s"},{"text":"\\n§4EXP: §r"},{"score":{"name":"@s","objective":"exp"}},{"text":"§4 / §r"},{"score":{"name":"@s","objective":"expCanUpt"}},{"text":"\\n§6等级: §r"},{"score":{"name":"@s","objective":"expLevel"}},{"text":"\\n§e金币: §r"},{"score":{"name":"@s","objective":"coin"}},{"text":"§e 银行金币存款: §r%s\\n§a在线时间: §r"},{"score":{"name":"@s","objective":"time"}},{"text":" §as"}]}''' % getCoin(playername))
            sendcmd(r'''/execute '''+playername+'''~~~ /tellraw  @s {"rawtext":[{"text":"{"score":{"name":"@s","objective":"time"},§as\\n§b跑酷时间: §r"},{"score":{"name":"@s","objective":"parkouring"}},{"text":"§b /\\n§r"},{"score":{"name":"@s","objective":"timeParkour"}},{"text":"§b ticks\\n§r扔雪球关闭\\n§r\\n§r"}]}''')
        case ".shop" | ".shop ": #商店
            sendcmd("/tp "+playername+" 150003 14 150003")
            sendcmd("/tellraw "+playername+r""" {"rawtext":[{"text":"<${sn}> 已传送至商店."}]}""")
        case ".gm0" | ".gamemode 0": #改生存模式
            sendcmd("/gamemode 0 "+playername)
            sendcmd("/tellraw "+playername+r""" {"rawtext":[{"text":"<${sn}> 你的游戏模式已刷新."}]}""")
        case ".surArea": #去生存区
            sendcmd("/tp "+playername+ " 7000 202 7000")
            sendcmd("/tellraw "+playername+r""" {"rawtext":[{"text":"<${sn}> 已传送"}]}""")
        case ".htp" | ".htp ": #玩家互传菜单
            sendcmd("/tellraw "+playername+r""" {"rawtext":[{"text":"<${sn}> \n玩家互传  帮助菜单\n输入§a.htp list §r查询目前的玩家互传列表\n输入§a.htp tp <数字> §r传送到目标玩家\n输入§a.htp totp §r发起传送命令\n输入§a.htp detotp §r取消发起传送命令"}]}""")
        case ".test":
            thread.start_new_thread(loadFunc, ("timeSleep0.txt", playername, ))
            thread.start_new_thread(loadFunc, ("timeSleep1.txt", playername, ))
            thread.start_new_thread(loadFunc, ("timeSleep2.txt", playername, ))
        case ".test2":
            thread.start_new_thread(loadFunc, ("timeSleep30.txt", playername, ))
            thread.start_new_thread(loadFunc, ("timeSleep31.txt", playername, ))
        case ".setsp" | ".spawnpoint" | ".setSP": #重新设置出生点
            sendcmd("""/tellraw @a[name=%s, tag=mainCity] {"rawtext":[{"text":"<§l§4ERROR§r> §c主城无法设置重生点."}]}""" % playername)
            sendcmd("/execute @a[name=%s, tag=!mainCity] ~ ~ ~ /spawnpoint" % playername)
            sendcmd("""/tellraw @a[name=%s, tag=!mainCity] {"rawtext":[{"text":"<${sn}> 已设置"}]}""" % playername)
        case ".stop" | ".restart" | ".reload": #退出
            if playername in adminhigh:
                tellrawText("@a", "§l§6System§r", "§6''.命令''系统正在重启.")
                exitChatbarMenu()
            else:
                tellrawText(playername, "§l§4ERROR§r", "§c权限不足.")
"@

New-Item -Path .\.Dot\NeteaseServerRobot\plugin\htp玩家互传_cmdsrun.py -ItemType File -Value @"
if msg[0:5] == ".htp " and msg != ".htp ":
    htp_txt=""
    for i in msg[5:]:
        if i == "" or i == " ":
            break
        else:
            htp_txt += i
    if htp_txt == "tp": #执行tp传送命令
        htp_txt=""
        for i in msg[8:]:
            if i == "":
                break
            elif i ==" ":
                break
            else:
                htp_txt+=i
        match htp_txt:
            case x:
                if int(x) >= 1 or int(x) <= 100:
                    if eval("tp_"+x) == "当前位无人":
                        sendcmd("/tellraw "+playername+r""" {"rawtext":[{"text":"<§l§4ERROR§r> §c当前互传位暂无玩家, 请检查对方是否重置或正好倒计时结束."}]}""")
                    else:
                        sendcmd("/tp "+playername+" "+eval("tp_"+x))
                        sendcmd("""/tellraw @a {"rawtext":[{"text":"<${sn}> §l"""+playername+"""§r 传送到了 §l"""+eval("tp_"+x)+"""§r 身边."}]}""")
                else:
                    sendcmd("/tellraw "+playername+r""" {"rawtext":[{"text":"<§l§4ERROR§r> §c该栏位不存在."}]}""")
    elif htp_txt =="totp":
        发过互传 = False
        for i in range(1, 100):
            if eval("tp_"+str(i)) == playername:
                sendcmd("/tellraw "+playername+r""" {"rawtext":[{"text":"<§l§4ERROR§r> §c你已经发送过玩家互传了!"}]}""")
                发过互传 = True
                break
        if not 发过互传:
            互传位已满 = True
            for i in range(1, 100):
                if eval("tp_"+str(i)) == "当前位无人":
                    exec("global tp_"+str(i)+"\ntp_"+str(i)+" = playername")
                    exec("global tp_"+str(i)+"_time"+"\ntp_"+str(i)+"_time = 60")
                    exec("global tp_"+str(i)+"_time_use"+"\ntp_"+str(i)+"_time_use = True")
                    sendcmd("/tellraw "+playername+r""" {"rawtext":[{"text":"<${sn}> 玩家互传§l发起成功§r，你的互传位：§l"""+str(i)+"""§r，有效时间：60s"}]}""")
                    sendcmd("""/tellraw @a[name=!"""+playername+"""] {"rawtext":[{"text":"<${sn}> §l"""+playername+""" §r发起了§l玩家互传§r，他的互传位：§l"""+str(i)+"""§r，有效时间:60s\\n输入§a.htp tp """+str(i)+"""§r进行传送"}]}""")
                    互传位已满 = False
                    break
            if 互传位已满:
                sendcmd("/tellraw "+playername+r""" {"rawtext":[{"text":"<§l§4ERROR§r> §c玩家互传当前位已满, 请稍后再试."}]}""")
    elif htp_txt =="detotp":
        取消成功 = False
        for i in range(1, 100):
            if eval("tp_"+str(i)) == playername:
                exec('''global tp_'''+str(i)+'''\ntp_'''+str(i)+''' = "当前位无人"''')
                exec("global tp_"+str(i)+"_time"+"\ntp_"+str(i)+"_time = 0")
                sendcmd("/tellraw "+playername+r""" {"rawtext":[{"text":"<${sn}> 已取消玩家互传."}]}""")
                取消成功 = True
                break
        if not 取消成功:
            sendcmd("/tellraw "+playername+r""" {"rawtext":[{"text":"<§l§4ERROR§r> §c取消失败, 你可能没有发送过玩家互传, 或者是刚好重置了."}]}""")

    elif htp_txt =="list":
        sendcmd("/tellraw "+playername+r""" {"rawtext":[{"text":"<${sn}> "}]}""")
        显示成功 = False
        for i in range(1, 100):
            if eval("tp_"+str(i)) != "当前位无人":
                sendcmd("/tellraw "+playername+r""" {"rawtext":"""+"""[{"text":"输入§a.htp tp """+str(i)+"""§r传送到玩家 §l"""+eval("tp_"+str(i))+"§r (剩余有效时间: §l"+str(eval("tp_"+str(i)+"_time"))+" §rs)"+""""}]}""")
                显示成功 = True
        if not 显示成功:
            sendcmd("/tellraw "+playername+r""" {"rawtext":[{"text":"暂时无传送请求."}]}""")
    elif htp_txt =="help":
        sendcmd("/tellraw "+playername+r""" {"rawtext":[{"text":"<${sn}> \n玩家互传  帮助菜单\n输入§a.htp list §r查询目前的玩家互传列表\n输入§a.htp tp <数字> §r传送到目标玩家\n输入§a.htp totp §r发起传送命令\n输入§a.htp detotp §r取消发起传送命令"}]}""")
    else:
        sendcmd("/tellraw "+playername+""" {"rawtext":[{"text":"<§l§4ERROR§r> §c语法错误! 目标命令"""+htp_txt+"""不存在"}]}""")
"@

New-Item -Path .\.Dot\NeteaseServerRobot\plugin\tpa玩家互传_cmdsrun.py -ItemType File -Value @"
if msg == ".help" or msg == ".help ":
    sendcmd("/tellraw "+playername+r''' {"rawtext":[{"text":"输入§c.tpa§r查看玩家互传(选人版)帮助"}]}''')
if msg[0:4] == ".tpa":
    if msg == ".tpa" or msg == ".tpa ":
        sendcmd("/tellraw "+playername+r""" {"rawtext":[{"text":"<§l§6${sn}§r> \n玩家互传(选人版)  帮助菜单\n输入§c.tpa list §r查询目前的玩家传送请求\n输入§c.tpa <玩家名称> §r向对方发起传送请求\n输入§c.tpa acc §r接受对方请求, 将对方传来\n输入§c.tpa dec §r拒绝对方请求"}]}""")
    elif msg == ".tpa list" or msg == ".tpa list ":
        if len(tpaRequests) == 0:
            tellrawText(playername, "§l§6${sn}§r", "暂无请求.")
        else:
            tpaIndex = 1
            for i in tpaRequests:
                tellrawText(playername, "§l§6${sn}§r", "请求§l§c%d§r: §l%s§r 发送给 §l%s§r, 剩余时间: §l%d§r s" % (tpaIndex, i.playersend, i.playerrecv, i.time))
                tpaIndex += 1
    elif msg == ".tpa acc" or msg == ".tpa acc ":
        tpaBeRequested = False
        for i in tpaRequests:
            if playername == i.playerrecv:
                tpaBeRequested = True
                i.accept()
                break
        if not(tpaBeRequested):
            tellrawText(playername, "§l§4ERROR§r", "§c你没有待处理的请求.")
    elif msg == ".tpa dec" or msg == ".tpa dec ":
        tpaBeRequested = False
        for i in tpaRequests:
            if playername == i.playerrecv:
                tpaBeRequested = True
                i.decline()
                break
        if not(tpaBeRequested):
            tellrawText(playername, "§l§4ERROR§r", "§c你没有待处理的请求.")
    else:
        playerTpaFound = []
        playerTpaToSearch = msg.split(".tpa ")[1]
        for i in allplayers:
            if playerTpaToSearch == i:
                playerTpaFound = []
                playerTpaFound.append(i)
                break
            elif playerTpaToSearch in i:
                playerTpaFound.append(i)
        print(playerTpaFound)
        if len(playerTpaFound) == 0:
            tellrawText(playername, "§l§4ERROR§r", "§c未找到名称包含 §l%s§r§c 的玩家, 无法发起请求." % playerTpaToSearch)
        elif len(playerTpaFound) >= 2:
            tellrawText(playername, "§l§4ERROR§r", "§c有多名玩家名称包含 §l%s§r§c, 无法发起请求:" % playerTpaToSearch)
            playerTpaFoundIndex = 1
            for i in playerTpaFound:
                tellrawText(playername, "§l§4ERROR§r", "§l§c%d§r§c. §l%s§r§c" % (playerTpaFoundIndex, i))
                playerTpaFoundIndex += 1
        else:
            tpaSentRequest = False
            tpaRecvedRequest = False
            for i in tpaRequests:
                if playername == i.playersend:
                    tpaSentRequest = True
                if playerTpaFound[0] == i.playerrecv:
                    tpaRecvedRequest = True
            if tpaSentRequest:
                tellrawText(playername, "§l§4ERROR§r", "§c你已发过请求, 请等对方处理后或等请求过期后再试.")
            elif tpaRecvedRequest:
                tellrawText(playername, "§l§4ERROR§r", "§c对方有未处理的请求, 请等对方处理后或等请求过期后再试.")
            else:
                tpa(playername, playerTpaFound[0], 60)
"@


New-Item -Path .\.Dot\NeteaseServerRobot\plugin\tpa玩家互传_def.py -ItemType File -Value @"
tpaRequests = []
class tpa():
    def __init__(self, playersend, playerrecv, time):
        self.playersend = playersend
        self.playerrecv = playerrecv
        self.time = time
        self.start()
    def start(self):
        tellrawText(self.playersend, "§l§6${sn}§r", "已向玩家 §l%s§r 发起传送请求, 对方有 §l%d§r 秒的时间接受请求." % (self.playerrecv, self.time))
        tellrawText(self.playerrecv, "§l§6${sn}§r", "收到 §l%s§r 发来的传送请求, 你有 §l%d§r 秒的时间接受请求." % (self.playersend, self.time))
        tpaRequests.append(self)
    def accept(self):
        sendcmd("/tp %s %s" % (self.playersend, self.playerrecv))
        tellrawText(self.playersend, "§l§6${sn}§r", "§l%s§r 已接受你的传送请求." % self.playerrecv)
        tellrawText(self.playerrecv, "§l§6${sn}§r", "你已接受 §l%s§r 的传送请求." % self.playersend)
        tpaRequests.remove(self)
    def decline(self):
        tellrawText(self.playersend, "§l§6${sn}§r", "§c§l%s§r§c 已拒绝你的传送请求." % self.playerrecv)
        tellrawText(self.playerrecv, "§l§6${sn}§r", "§c你已拒绝 §l%s§r§c 的传送请求." % self.playersend)
        tpaRequests.remove(self)
    def outdate(self):
        tellrawText(self.playersend, "§l§6${sn}§r", "§c你发给 §l%s§r§c 的传送请求已过期." % self.playerrecv)
        tellrawText(self.playerrecv, "§l§6${sn}§r", "§c§l%s§r§c 发来的传送请求已过期." % self.playersend)
        tpaRequests.remove(self)

"@

New-Item -Path .\.Dot\NeteaseServerRobot\plugin\金币银行_cmdsrun.py -ItemType File -Value @"
if ".shop " in msg:
    shop_txt = msg.split(".shop ")[1]
    if shop_txt[0:6] == "trans ":
        trans_txt = shop_txt.split(" ")[1]
        if trans_txt == "tobank":
            coinToTrans = int(shop_txt.split(" ")[2])
            if coinToTrans > 0 and coinToTrans <= 10000000:
                coinInScore = getScore("${ms}", playername)
                coinInBank = getPlayerData("coin", playername)
                if coinInScore >= coinToTrans:
                    sendcmd("/scoreboard players remove %s ${ms} %d" % (playername, coinToTrans))
                    addPlayerData("coin", playername, coinToTrans)
                    sendcmd("/tellraw "+playername+r""" {"rawtext":[{"text":"<§l§6${sn}§r> 存金币成功, 银行余额: §l%d§r, 金币剩余余额: %d"}]}""" % (coinInBank+coinToTrans, coinInScore-coinToTrans))
                else:
                    sendcmd("/tellraw "+playername+r""" {"rawtext":[{"text":"<§l§4ERROR§r> §c金币不足, 无法存款. 你的金币余额: §l%d"}]}""" % coinInScore)
            else:
                tellrawText(playername, "§l§4ERROR§r", "§c金币数量不正确.")
        if trans_txt == "frombank":
            coinToTrans = int(shop_txt.split(" ")[2])
            if coinToTrans > 0 and coinToTrans <= 10000000:
                coinInScore = getScore("${ms}", playername)
                coinInBank = getPlayerData("coin", playername)
                if coinInBank >= coinToTrans:
                    addPlayerData("coin", playername, coinToTrans*(-1))
                    sendcmd("/scoreboard players add %s ${ms} %d" % (playername, coinToTrans))
                    sendcmd("/tellraw "+playername+r""" {"rawtext":[{"text":"<§l§6${sn}§r> 取金币成功, 银行剩余余额: §l%d§r, 金币余额: %d"}]}""" % (coinInBank-coinToTrans, coinInScore+coinToTrans))
                else:
                    sendcmd("/tellraw "+playername+r""" {"rawtext":[{"text":"<§l§4ERROR§r> §c银行余额不足, 无法取款. 你的银行余额: §l%s"}]}""" % coinInBank)
            else:
                tellrawText(playername, "§l§4ERROR§r", "§c金币数量不正确.")
"@

New-Item -Path .\.Dot\NeteaseServerRobot\plugin\协管tp到玩家_cmdsrun.py -ItemType File -Value @"
if msg == ".admin" or msg == ".admin ":
    sendcmd("/tellraw "+playername+r''' {"rawtext":[{"text":"§r输入§b.admin tp <玩家名> §r传送到该玩家(仅管理可用)"}]}''')
if ".admin tp " in msg and msg[0:4] == ".adm":
    if playername in adminnorm or playername in adminhigh: #若玩家有协管及以上权限.
        playerTotp = msg.split(".admin tp ")[1]
        sendcmd("/tp %s %s" % (playername, playerTotp))
        tellrawText(playername, "§l§6${sn}§r", "成功传送.")
    else: #如果玩家权限不足.
        tellrawText(playername, "§l§4ERROR§r", "§c权限组级别不够.")
"@

# 写入 gocqhttp 配置文件
$realpassword = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($qqpassword))
New-Item -Path .\.Dot\QQgroupRobot\config.yml -ItemType File -Value @"
# go-cqhttp 默认配置文件

account: # 账号相关
  uin: ${qqid} # QQ账号
  password: '${realpassword}' # 密码为空时使用扫码登录
  encrypt: false  # 是否开启密码加密
  status: 0      # 在线状态 请参考 https://docs.go-cqhttp.org/guide/config.html#在线状态
  relogin: # 重连设置
    delay: 3   # 首次重连延迟, 单位秒
    interval: 3   # 重连间隔
    max-times: 0  # 最大重连次数, 0为无限制

  # 是否使用服务器下发的新地址进行重连
  # 注意, 此设置可能导致在海外服务器上连接情况更差
  use-sso-address: true

heartbeat:
  # 心跳频率, 单位秒
  # -1 为关闭心跳
  interval: 5

message:
  # 上报数据类型
  # 可选: string,array
  post-format: string
  # 是否忽略无效的CQ码, 如果为假将原样发送
  ignore-invalid-cqcode: false
  # 是否强制分片发送消息
  # 分片发送将会带来更快的速度
  # 但是兼容性会有些问题
  force-fragment: false
  # 是否将url分片发送
  fix-url: false
  # 下载图片等请求网络代理
  proxy-rewrite: ''
  # 是否上报自身消息
  report-self-message: true
  # 移除服务端的Reply附带的At
  remove-reply-at: false
  # 为Reply附加更多信息
  extra-reply-data: false
  # 跳过 Mime 扫描, 忽略错误数据
  skip-mime-scan: false

output:
  # 日志等级 trace,debug,info,warn,error
  log-level: trace
  # 日志时效 单位天. 超过这个时间之前的日志将会被自动删除. 设置为 0 表示永久保留.
  log-aging: 0
  # 是否在每次启动时强制创建全新的文件储存日志. 为 false 的情况下将会在上次启动时创建的日志文件续写
  log-force-new: false
  # 是否启用 DEBUG
  debug: false # 开启调试模式

# 默认中间件锚点
default-middlewares: &default
  # 访问密钥, 强烈推荐在公网的服务器设置
  access-token: ''
  # 事件过滤器文件目录
  filter: ''
  # API限速设置
  # 该设置为全局生效
  # 原 cqhttp 虽然启用了 rate_limit 后缀, 但是基本没插件适配
  # 目前该限速设置为令牌桶算法, 请参考:
  # https://baike.baidu.com/item/%E4%BB%A4%E7%89%8C%E6%A1%B6%E7%AE%97%E6%B3%95/6597000?fr=aladdin
  rate-limit:
    enabled: false # 是否启用限速
    frequency: 1  # 令牌回复频率, 单位秒
    bucket: 1     # 令牌桶大小

database: # 数据库相关设置
  leveldb:
    # 是否启用内置leveldb数据库
    # 启用将会增加10-20MB的内存占用和一定的磁盘空间
    # 关闭将无法使用 撤回 回复 get_msg 等上下文相关功能
    enable: true

# 连接服务列表
servers:
  # 添加方式，同一连接方式可添加多个，具体配置说明请查看文档
  #- http: # http 通信
  #- ws:   # 正向 Websocket
  #- ws-reverse: # 反向 Websocket
  #- pprof: #性能分析服务器
  # HTTP 通信设置
  - http:
      # 服务端监听地址
      host: 127.0.0.1
      # 服务端监听端口
      port: 5700
      # 反向HTTP超时时间, 单位秒
      # 最小值为5，小于5将会忽略本项设置
      timeout: 5
      # 长轮询拓展
      long-polling:
        # 是否开启
        enabled: false
        # 消息队列大小，0 表示不限制队列大小，谨慎使用
        max-queue-size: 2000
      middlewares:
        <<: *default # 引用默认中间件
      # 反向HTTP POST地址列表
      post:
      #- url: '' # 地址
      #  secret: ''           # 密钥
      - url: http://127.0.0.1:5701/ # 地址
        secret: ''

"@

# 写入 服务器 配置文件
$rpassword = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($password))
New-Item .\.Dot\NeteaseServerRobot\robot.json -Value @"
{"token": "unknown", "server_number": "${number}", "server_passwd": "${rpassword}", "transfer_port": "localhost:8000", "ignore_update": false, "auto_restart": true}
"@

#写入群服互通
New-Item .\.Dot\NeteaseServerRobot\plugin\群服互通_def.py -Value @"
QQgroup = "${qgnumber}" #你的QQ群号
def sendtogroup(where, number, message):
    #使用QQ群机器人程序的api发送信息.
    if len(message) >= 200:
        message = message[:200]+"...消息长度大于200, 已省去剩余部分"
    if where == "group":
        requests.get("http://127.0.0.1:5700/send_group_msg?group_id="+str(number)+"&message="+urllib.parse.quote(message), timeout=2).text.replace("true", "True").replace("false", "False").replace("null", "None")

"@

#写入管理员
New-Item .\.Dot\NeteaseServerRobot\plugin\basic_管理员设置_def.py -Value @"
adminxieg = []
adminnorm = []
adminhigh = ["${robotnm}", "${op1}", "${op2}", "${op3}","${op4}","${op5}"]
"@

#写入 robot.py
New-Item .\.Dot\QQgroupRobot\robot.py -Value @"
import socket
import requests, datetime
import random, os
from flask import Flask, request
import logging
import urllib
import urllib.parse
from websocket import create_connection
import time
log = logging.getLogger('werkzeug') #防止监听日志输出.
log.setLevel(logging.ERROR)
port = 5700
connected = False
def log(rev, filename, text, mode = "a", encoding = None, errors = None, output = True, sendgrp = False, sendpri = False):
    if output:
        print(text, end="")
    try:
        file = open(filename, mode, encoding = "utf-8", errors = errors)
        file.write(text)
        if sendgrp:
            if text[-1:] == "\n":
                sendmsg("group", rev["group_id"], text[:-1])
            else:
                sendmsg("group", rev["group_id"], text)
        if sendpri:
            if text[-1:] == "\n":
                sendmsg("private", rev["user_id"], text[:-1])
            else:
                sendmsg("private", rev["user_id"], text)
    except Exception as err:
        print(err)
    finally:
        file.close()
def groupmsg(rev):
    if rev["raw_message"] == "在线玩家" and (rev['group_id'] == 1 or rev['group_id'] == ${qgnumber} or rev['group_id'] == 2): #获取在线玩家
        try:
            result = eval(requests.get("http://127.0.0.1:5556/api?getTarget=@a", timeout=2).text.replace("true", "True").replace("false", "False").replace("null", "None"))
            final = ""
            plsnum = 0
            for i in result:
                final += i + "\n"
                plsnum += 1
            log(rev, "QQmessages\\"+datetime.datetime.now().strftime("%Y-%m-%d.txt"), "当前在线: "+str(plsnum)+"/40\n"+final, encoding = "gbk", errors = "ignore", sendgrp = True)
        except Exception as err: #程序报错了, 返回原因. (自己修下bug)
            try:
                log(rev, "QQmessages\\"+datetime.datetime.now().strftime("%Y-%m-%d.txt"), "获取失败, 原因:\n"+str(err)+"\n", encoding = "gbk", errors = "ignore", sendgrp = True)
            except:
                print(err)
    if "发到服务器 " in rev["raw_message"] and (rev['group_id'] == 1 or rev['group_id'] == ${qgnumber} or rev['group_id'] == 2):
        try:
            msgtosend = rev["raw_message"].split("发到服务器 ")[1]
            cmdtosend = urllib.parse.quote(r'''tellraw @a {"rawtext":[{"text":"<<§l§6Qgroup§r><%s>§r> %s"}]}''' % (rev["sender"]["nickname"], msgtosend))
            result = requests.get("http://127.0.0.1:5556/api?sendcmd=/"+cmdtosend, timeout=2).text.replace("true", "True").replace("false", "False").replace("null", "None")
            if "成功执行" in result:
                log(rev, "QQmessages\\"+datetime.datetime.now().strftime("%Y-%m-%d.txt"), "发送成功.\n", encoding = "gbk", errors = "ignore")
            else:
                log(rev, "QQmessages\\"+datetime.datetime.now().strftime("%Y-%m-%d.txt"), "发送失败, 原因: \n"+result+"\n", encoding = "gbk", errors = "ignore", sendgrp = True)
        except Exception as err: #程序报错了, 返回原因. (自己修下bug)
            try:
                log(rev, "QQmessages\\"+datetime.datetime.now().strftime("%Y-%m-%d.txt"), "发送失败, 原因:\n"+str(err)+"\n", encoding = "gbk", errors = "ignore", sendgrp = True)
            except:
                print(err)
    if "执行指令 /" in rev["raw_message"] and rev["raw_message"][0] != "<" and (rev['group_id'] == 1 or rev['group_id'] == ${qgnumber} or rev['group_id'] == 2):
        try:
            if rev["sender"]["role"] == "member": #使用者非群主或管理员, 无法使用.
                log(rev, "QQmessages\\"+datetime.datetime.now().strftime("%Y-%m-%d.txt"), "执行失败, 原因:\n只有群主或管理员才能使用.\n", encoding = "gbk", errors = "ignore", sendgrp = True)
            else: #使用者是群主或管理员, 执行操作.
                msgtosend = rev["raw_message"].split("执行指令 /")[1]
                cmdtosend = urllib.parse.quote(msgtosend)
                result = requests.get("http://127.0.0.1:5556/api?sendcmd=/"+cmdtosend, timeout=2).text.replace("true", "True").replace("false", "False").replace("null", "None")
                if "成功执行" in result:
                    log(rev, "QQmessages\\"+datetime.datetime.now().strftime("%Y-%m-%d.txt"), "执行成功.\n", encoding = "gbk", errors = "ignore")
                else:
                    log(rev, "QQmessages\\"+datetime.datetime.now().strftime("%Y-%m-%d.txt"), "执行失败, 原因: \n"+result+"\n", encoding = "gbk", errors = "ignore", sendgrp = True)
        except Exception as err: #程序报错了, 返回原因. (自己修下bug)
            try:
                log(rev, "QQmessages\\"+datetime.datetime.now().strftime("%Y-%m-%d.txt"), "执行失败, 原因:\n"+str(err)+"\n", encoding = "gbk", errors = "ignore", sendgrp = True)
            except:
                print(err)
def sendmsg(where, number, message):
    if len(message) >= 200:
        message = message[:200]+"...消息长度大于200, 已省去剩余部分"
    if where == "group":
        requests.get("http://127.0.0.1:"+str(port)+"/send_group_msg?group_id="+str(number)+"&message="+urllib.parse.quote(message), timeout=2).text.replace("true", "True").replace("false", "False").replace("null", "None")
    if where == "private":
        requests.get("http://127.0.0.1:"+str(port)+"/send_private_msg?user_id="+str(number)+"&message="+urllib.parse.quote(message), timeout=2).text.replace("true", "True").replace("false", "False").replace("null", "None")        
app = Flask(__name__) #开始监听端口, 接收消息.
@app.route("/", methods=["POST"])
def rev_msg():
    rev = request.get_json()
    if rev["post_type"] == "notice": #处理通知
        if rev["notice_type"] == "group_recall" and rev["operator_id"] == rev["user_id"]: #群聊消息撤回记录
            recall = eval(requests.get("http://127.0.0.1:"+str(port)+"/get_msg?message_id="+str(rev["message_id"]), timeout=2).text.replace("true", "True"))["data"]
            recall["message"] = recall["message"].replace("&#91;", "[")
            recall["message"] = recall["message"].replace("&#93;", "]")
            recall["message"] = recall["message"].replace("\r", "")
            if rev["user_id"] != rev["self_id"] and (rev["group_id"] == 1 or rev["group_id"] == 2 or rev["group_id"] == 3): #发送撤回的消息
                sendmsg("group", recall["group_id"], "[CQ:at,qq="+str(rev["user_id"])+"] 撤回的消息是: "+recall["message"])
            rev_message = "["+datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")+"] "+"a group message was recalled: "+str(rev["group_id"])+" "+str(rev["user_id"])+" "+recall["message"]+"\n"
            log(rev, "QQmessages\\"+datetime.datetime.now().strftime("%Y-%m-%d.txt"), rev_message, encoding = "gbk", errors = "ignore")
        if rev["notice_type"] == "friend_recall": #私聊消息撤回记录
            recall = eval(requests.get("http://127.0.0.1:"+str(port)+"/get_msg?message_id="+str(rev["message_id"]), timeout=2).text.replace("true", "True").replace("false", "False"))["data"]
            recall["message"] = recall["message"].replace("&#91;", "[")
            recall["message"] = recall["message"].replace("&#93;", "]")
            recall["message"] = recall["message"].replace("\r", "")
            rev_message = "["+datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")+"] "+"a private message was recalled: "+str(rev["user_id"])+" "+recall["message"]+"\n"
            log(rev, "QQmessages\\"+datetime.datetime.now().strftime("%Y-%m-%d.txt"), rev_message, encoding = "gbk", errors = "ignore")
    if rev["post_type"] == "message" or rev["post_type"] == "message_sent": #处理消息
        rev["raw_message"] = rev["raw_message"].replace("&#91;", "[")
        rev["raw_message"] = rev["raw_message"].replace("&#93;", "]")
        rev["raw_message"] = rev["raw_message"].replace("\r", "")
        if rev["message_type"] == "private": #处理私聊消息
            if rev["post_type"] == "message_sent": #处理私聊自发消息
                rev_message = "["+datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")+"] sentprito "+str(rev["target_id"])+" "+rev["raw_message"]+"\n"
            else: #处理私聊收到的消息
                rev_message = "["+datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")+"] "+rev["message_type"]+" "+str(rev["user_id"])+" "+rev["raw_message"]+"\n"
                if "在吗" == rev["raw_message"] or "在?" == rev["raw_message"] or "在吗?" == rev["raw_message"] or "在？" == rev["raw_message"] or "在吗？" == rev["raw_message"]:
                    sendmsg("private", rev["user_id"], "[程序回复] 有事情直接说就行")
            log(rev, "QQmessages\\"+datetime.datetime.now().strftime("%Y-%m-%d.txt"), rev_message, encoding = "gbk", errors = "ignore")
        if rev["message_type"] == "group": #处理群聊消息
            if rev["post_type"] == "message_sent": #处理群聊自发消息
                rev_message = "["+datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")+"] sentgrpto "+str(rev["group_id"])+" "+rev["raw_message"]+"\n"
            else: #处理群聊收到的消息
                rev_message = "["+datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")+"] "+rev["message_type"]+" "+str(rev["group_id"])+" "+str(rev["user_id"])+" "+rev["raw_message"]+"\n"
            log(rev, "QQmessages\\"+datetime.datetime.now().strftime("%Y-%m-%d.txt"), rev_message, encoding = "gbk", errors = "ignore")
            if len(rev["raw_message"]) <= 500:
                groupmsg(rev) #群聊消息额外功能
    return "OK"
app.run(debug=True, host="127.0.0.1", port=5701) #监听配置

"@

# 写启动程序
New-Item -Path .\启动.cmd -ItemType File -Value @"
cd .Dot\QQgroupRobot
start go-cqhttp.bat
start robot.bat
cd ..
cd ..
cd .Dot\NeteaseServerRobot
@echo off
echo Running robot.exe...
robot.exe
choice /t 2 /d y /n 1>nul
copy /Y robot_new.exe robot.exe >nul
del robot_new.exe 2>nul
%0
"@

Write-Output '安装完成！用点击"启动.cmd"来启动.Dot吧！'

"按任意键退出(关机也行 狗头)." ;
[Console]::Readkey() |　Out-Null ;
Exit ;