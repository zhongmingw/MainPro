--
-- Author: yr
-- Date: 2017-07-18 19:12:12
--

HookState = {}
HookState.idle = 0
HookState.fight = 1
HookState.move = 2
HookState.moveComplete = 3
HookState.moveBreak = 4
HookState.pick = 5
HookState.findMonster = 6
HookState.findPlayer = 7
HookState.picking = 8
HookState.stop = 9

HookType = {}
HookType.taskHook = 1
HookType.fubenHook = 2
HookType.bossHook = 3
HookType.gangBossHook = 4
HookType.wenDingHook = 5
HookType.hangLingHook = 6
HookType.fieldHook = 7
HookType.cityHook = 8
HookType.xianmoHook = 9
HookType.awakenHook = 10
HookType.multiBossHook = 11
HookType.shoutaHook = 12
HookType.xmzbHook = 13
HookType.pwsHook = 14
HookType.citywarHook = 15
HookType.xianLvPKHook = 16
HookType.tjdkHook = 17
HookType.xycmHook = 18

HookMoveDo = {}
HookMoveDo.nothing = 0
HookMoveDo.fight = 1
HookMoveDo.pick = 2

HookCache = {}
HookCache.skillList = {}
