local mgr = {}

--SDK
mgr.SDKMgr = import(".SDKMgr").new()

--定时器启动
mgr.TimerMgr       = import(".TimerMgr").new()

---网络管理
mgr.NetMgr      = import(".NetMgr").new()

--视图管理
mgr.ViewMgr     = import(".ViewMgr").new()

--场景管理
mgr.SceneMgr    = import(".SceneMgr").new()

--效果管理
mgr.EffectMgr   = import(".EffectMgr").new()

--战斗
mgr.FightMgr    = import(".FightMgr").new()

--输入管理
mgr.InputMgr    = import(".InputMgr").new()

--更新
mgr.UpdateMgr  = import(".UpdateMgr").new()

--ai
mgr.AI = import(".AIMgr").new()

--伤害管理
mgr.HurtMgr = import(".HurtMgr").new()

--掉落物管理
mgr.PickMgr = import(".PickMgr").new()

--事物对象管理
mgr.ThingMgr = import(".ThingMgr").new()
--任务管理
mgr.TaskMgr = import(".TaskMgr").new()
--挂机管理
mgr.HookMgr = import(".HookMgr3").new()
--item管理
mgr.ItemMgr = import(".ItemMgr").new()
--飄字管理
mgr.TipsMgr = import(".TipsMgr").new()
--gui
mgr.GuiMgr = import(".GuiMgr").new()
--多文本修改
mgr.TextMgr = import(".TextMgr").new()
--跳跃管理
mgr.JumpMgr = import(".JumpMgr").new()
--buff 管理
mgr.BuffMgr = import(".BuffMgr").new()
--http 请求
mgr.HttpMgr = import(".HttpMgr").new()
--声音管理
mgr.SoundMgr = import(".SoundMgr").new()
--游戏质量管理
mgr.QualityMgr = import(".QualityMgr").new()
--新手管理
mgr.XinShouMgr = import(".XinShouMgr").new()
--界面跳转管理 
mgr.ModuleMgr = import(".ModuleMgr").new() 
--副本管理器
mgr.FubenMgr = import(".FubenMgr").new()
--后台下载
mgr.DownloadMgr = import(".DownloadMgr").new()

mgr.ChatMgr = import(".ChatMgr").new()
--家园管理
mgr.HomeMgr = import(".HomeMgr").new()

mgr.DebugMgr = import(".DebugMgr").new()
--活动管理
mgr.ActivityMgr = import(".ActivityMgr").new()
--宠物管理
mgr.PetMgr = import(".PetMgr").new()
--符文管理
mgr.RuneMgr = import(".RuneMgr").new()
--仙童
mgr.XianTongMgr = import(".XianTongMgr").new()
return mgr