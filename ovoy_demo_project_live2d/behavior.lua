--
-- Created by IntelliJ IDEA.
-- User: scottnien
-- Date: 2017/4/24
-- Time: 下午2:09
-- To change this template use File | Settings | File Templates.
--

TAG = "Eirie_lua"

IWPActor=nil
IWPStage=nil
startDraggingSkirt=false
lastPosY =0
currentSkirtUp = 0
isTouchingChest=false
touchedChestStartTime = 0
isTouchingHead=false
touchedHeadStartTime = 0
waitingMotion = false
waitingDrawflag = false
isInAction=false

function onCreate(actor, stage)
  Slog:i(TAG, "[onCreate]")


  IWPActor = actor
  IWPStage  = stage

  actor:addTouchHandler(onTouchActor)
  actor:setDefaultDialogStyle(dialogStyle)

  stage:addEventListener("battery", onBattery)
  stage:addEventListener("power", onPower)
  stage:addEventListener("headset",onHeadset)
  stage:addEventListener("shake",onShake)

  goIdleState()

end

function goIdleState()
  isInAction=false
  Slog:d(TAG, "goIdleState");
  IWPActor:playAnimation("ovoyGirl Idle.mtn", true)
end

dialogStyle = { --設定對話框屬性
  background="images/dialog.png",
  textSize=18,
  positionX = 0.2,
  positionY  = 0.2
}

randomShakeTable = { --搖晃手機
  {chance=0.50, motion="ovoyGirl happy.mtn",  dialog="你要找我跳舞阿？", sound=nil, nextAcrtion=nil, nextDialog=nil},
  {chance=0.50, motion="ovoyGirl happy.mtn",  dialog="你要找我跳舞阿？", sound=nil, nextAcrtion=nil, nextDialog=nil},

}

randomPowerPlugInTable = { --插入充電
  {chance=0.50, motion="ovoyGirl Talk.mtn",  dialog="充滿電，我才有活力唷", sound=nil, nextAcrtion=nil, nextDialog=nil},
  {chance=0.50, motion="ovoyGirl happy.mtn",  dialog="你要找我跳舞阿？", sound=nil, nextAcrtion=nil, nextDialog=nil},
}

randomPowerPlugOutTable = { --拔出充電
  {chance=0.50, motion="ovoyGirl welcome.mtn",  dialog="喔？充夠電了嗎？", sound=nil, nextAcrtion=nil, nextDialog=nil},
  {chance=0.50, motion="ovoyGirl happy.mtn",  dialog="你要找我跳舞阿？", sound=nil, nextAcrtion=nil, nextDialog=nil},
}

randomHeadsetPlugInTable = { --插入耳機
  {chance=0.50, motion="ovoyGirl yes.mtn",  dialog="帶耳機要注意音量唷", sound=nil, nextAcrtion=nil, nextDialog=nil},
  {chance=0.50, motion="ovoyGirl happy.mtn",  dialog="你要找我跳舞阿？", sound=nil, nextAcrtion=nil, nextDialog=nil},
}

randomHeadsetPlugOutTable = { --拔出耳機
  {chance=0.50, motion="ovoyGirl Angry.mtn",  dialog="不准拿掉我的耳機", sound=nil, nextAcrtion=nil, nextDialog=nil},
  {chance=0.50, motion="ovoyGirl happy.mtn",  dialog="你要找我跳舞阿？", sound=nil, nextAcrtion=nil, nextDialog=nil},
}

randomBatteryLowTable = { --沒電狀態
  {chance=0.50, motion="ovoyGirl tired.mtn",  dialog="手機沒電~~我也沒力了", sound=nil, nextAcrtion=nil, nextDialog=nil},
  {chance=0.50, motion="ovoyGirl happy.mtn",  dialog="你要找我跳舞阿？", sound=nil, nextAcrtion=nil, nextDialog=nil},
}

randomBatteryHighTable = { --滿電狀態
  {chance=0.50, motion="ovoyGirl happy.mtn",  dialog="電量全滿，太棒啦！！", sound=nil, nextAcrtion=nil, nextDialog=nil},
  {chance=0.50, motion="ovoyGirl happy.mtn",  dialog="你要找我跳舞阿？", sound=nil, nextAcrtion=nil, nextDialog=nil},
}

randomActionTable = { --點螢幕隨機動作
  {chance=0.100, motion="ovoyGirl tired.mtn",  dialog="好無聊喔，有沒有什麼好玩的事呢？", sound=nil, nextAcrtion=nil, nextDialog=nil},
  {chance=0.100, motion="ovoyGirl tired.mtn", dialog="歐波鷹又不見了，他到底跑去哪了？", sound=nil, nextAcrtion=nil, nextDialog=nil},
  {chance=0.200, motion="ovoyGirl happy.mtn", dialog="歐波鷹出來玩", sound=nil, nextAcrtion=nil, nextDialog=nil},
  {chance=0.200, motion="ovoyGirl Talk.mtn", dialog="今天的天氣好像不錯耶", sound=nil, nextAcrtion=nil, nextDialog=nil},
  {chance=0.200, motion="ovoyGirl yes.mtn", dialog="又有新的角色要加入OvOy互動桌布了", sound=nil, nextAcrtion=nil, nextDialog=nil},
  {chance=0.100, motion="ovoyGirl no.mtn", dialog="不好....", sound=nil, nextAcrtion=nil, nextDialog=nil},
  {chance=0.100, motion="ovoyGirl Talk.mtn", dialog="我最喜歡的顏色是粉紅色唷", sound=nil, nextAcrtion=nil, nextDialog=nil},
}

fortuneActionTable = {
  {chance=0.200, motion="ovoyGirl happy.mtn", dialog="大吉", sound=nil, nextAcrtion=nil, nextDialog=nil},
  {chance=0.200, motion="ovoyGirl welcome.mtn", dialog="中吉", sound=nil, nextAcrtion=nil, nextDialog=nil},
  {chance=0.300, motion="ovoyGirl yes.mtn", dialog="小吉", sound=nil, nextAcrtion=nil, nextDialog=nil},
  {chance=0.100, motion="ovoyGirl Talk.mtn", dialog="普通", sound=nil, nextAcrtion=nil, nextDialog=nil},
  {chance=0.100, motion="ovoyGirl no.mtn", dialog="小兇", sound=nil, nextAcrtion=nil, nextDialog=nil},
  {chance=0.100, motion="ovoyGirl tired.mtn", dialog="兇", sound=nil, nextAcrtion=nil, nextDialog=nil},
}

function onTouchAnywhere()
  randomAction(randomActionTable)
end

function onBattery(para)
  if para == "low" then
    randomAction(randomBatteryLowTable)
  elseif para == "okay" then
    randomAction(randomBatteryHighTable)
  end

end

function onPower(para)
  if para == "connected" then
    randomAction(randomPowerPlugInTable)
  elseif para ==  "disconnected" then
    randomAction(randomPowerPlugOutTable)
  end

end

function onHeadset(para)
  if para == "plugged" then
    randomAction(randomHeadsetPlugInTable)
  elseif para == "unplugged" then
    randomAction(randomHeadsetPlugOutTable)
  end

end

function randomAction(table)
  if (isInAction == true) then
    return
  end

  math.randomseed(os.time())
  local randomVal=math.random(1000)
  local prevVal = 0
  local nextVal = 0
  for k, v in pairs(table) do
    nextVal = prevVal + v.chance*1000;
    if (randomVal > prevVal and randomVal <= nextVal) then
      isInAction = true
      IWPActor:playAnimation(v.motion, true)
      dialog = IWPActor:showActorDialog(v.dialog, 3000)
      if (v.sound ~= null) then
        IWPActor:playSound(v.sound, function()
        Slog:i(TAG,"playsound comleted")
        end)
      end
      if v.next ~= nil then
        IWPStage:removeRunDelay(TOUCH_DELAYFUNC_ID)
        IWPStage:runDelay(TOUCH_DELAYFUNC_ID, function()
        dialog:dismiss()
        IWPActor:playAnimation(v.next, true)
        IWPActor:showActorDialog(v.nextdialog, 2000)
        end, 2000)
        goToIdleLater(5500)
      else
        goToIdleLater(3500)
      end
      return true;
    end
    prevVal  = nextVal;
  end
  return
end

function onShake(para)
  if  waitingDrawflag == true then
    math.randomseed(os.time())
    local randomVal=math.random(1000)
    local prevVal = 0
    local nextVal = 0
    for k, v in pairs(fortuneActionTable) do
      nextVal = prevVal + v.chance*1000;
      if (randomVal > prevVal and randomVal <= nextVal) then
        IWPActor:playAnimation(v.motion, true)
        IWPActor:showActorDialog(v.dialog, 2500)
        isTouchingChest=false
        isTouchingHead=false
        waitingDrawflag = false
        return true;
      end
      prevVal  = nextVal;
    end
    return
  else
    randomAction(randomShakeTable)
  end

end





function onNewDayBegin()
  Slog:i(TAG, "[onNewDayBegin]");

  hasShownTodaysGreeting = false;
end

function onShow(screenOnOrUnlocked)
  Slog:i(TAG, "[onShow]")

  if (screenOnOrUnlocked) then
    Slog:d(TAG, "screenOnOrUnlocked = true")
  else
    Slog:d(TAG, "screenOnOrUnlocked = false")
  end


  date = os.date("*t")

  Slog:d(TAG, "onShow hour=" .. date.hour .. " minute= " .. date.min ..  " second =" .. date.sec)

  --每日問候
  if date.hour >=6 and date.hour < 12  and hasShownTodaysGreeting==false then

    IWPActor:playAnimation("ovoyGirl happy.mtn", true)

    IWPActor:showActorDialog("早安! 又是神清氣爽的一天呢!", 2000)
    hasShownTodaysGreeting=  true;
    return
  end

  --check 整點報時
  if date.min == 0 and lastClockReportHour ~= date.hour  then
    showClockAction(date.hour)
    return
  end

  waitTime =  ((60-date.min) * 60 - date.sec) * 1000;
  Slog:d(TAG, "wait " .. waitTime/1000 .. " sec");

  IWPStage:runDelay(CLOCK_DELAY_FUNCTION_ID, clockDueFunction, waitTime)

  if date.hour ~= lastClockReportHour then
    lastClockReportHour = -1
  end

  -- check 開啟螢幕
  if not screenOnOrUnlocked then
    return
  end

  if date.hour == lastShowHour then
    lastShowHour = date.hour;
    return
  end

  lastShowHour = date.hour;
  IWPActor:showActorDialog("你在找我嗎？", 3000)
  IWPActor:playAnimation("ovoyGirl welcome.mtn", true)
  goToIdleLater(3000)
end

function clockDueFunction()
  date = os.date("*t");
  showClockAction(date.hour);
end


function onHide()
  Slog:d(TAG,"onHide");
  IWPStage:removeRunDelay(CLOCK_DELAY_FUNCTION_ID)
  IWPStage:removeRunDelay(GOTOIDLE_DELAYFUNC_ID)
  IWPStage:removeRunDelay(WAITING_DELAYFUNC_ID)
  IWPStage:removeRunDelay(WAITING_DRAWING_DELAYFUNC_ID)
end

function showClockAction(hour)
  lastClockReportHour = hour
  if hour >12 then
    hour = hour - 12
  end

  if hour ==0 then
    hour = 12
  end


  IWPActor:showActorDialog("現在是" .. hour .. "點唷", 3000)
  IWPActor:playAnimation("ovoyGirl Talk.mtn", true)
  goToIdleLater(6000)

end

function onTouchActor(event)
  Slog:i(TAG, "onTouchActor name=" .. event.name .. " touchPart=" .. event.touchPart .. " X= " .. event.X .. " Y=" .. event.Y);
  if waitingMotion == true then
    return
  end

  if event.name ~= "touchDown" and event.name ~="touchMove" then
    isTouchingChest=false
  end

  if event.touchPart == "chest" and event.name =="touchMove" then
    if isTouchingChest == false then
      isTouchingChest = true
      touchedChestStartTime = os.time()
      return
    else
      duration = os.time() - touchedChestStartTime
      if duration >= 1 then
        isTouchingChest = false
        IWPActor:showActorDialog("不要一直摸人家胸部啦!", 2000)
        IWPActor:playAnimation("ovoyGirl Angry.mtn", true)
        waitingMotion = true
        waiting(3000)
        return
      end
    end
  else
    isTouchingChest=false
  end

  if event.touchPart == "head" and event.name =="touchMove" then
    if isTouchingHead == false then
      isTouchingHead = true
      touchedHeadStartTime = os.time()
      return
    else
      duration = os.time() - touchedHeadStartTime
      if duration >= 1 then
        isTouchingChest = false
        IWPActor:showActorDialog("想抽籤看運勢的話現在可以搖搖手機唷", 2000)
        IWPActor:playAnimation("ovoyGirl Talk.mtn", true)
        waitingDrawflag = true
        waitingMotion = true
        waiting(5000)
        waitingDraw(5000)
        return
      end
    end
  else
    isTouchingHead=false
  end

end


SKIRT_ANIMATE_FUNC_ID = 3
prevTime = 0;


GOTOIDLE_DELAYFUNC_ID = 2
WAITING_DELAYFUNC_ID = 4
WAITING_DRAWING_DELAYFUNC_ID = 5

function goToIdleLater(time)
  IWPStage:removeRunDelay(GOTOIDLE_DELAYFUNC_ID)
  IWPStage:runDelay(GOTOIDLE_DELAYFUNC_ID, function()
  goIdleState()
  end,  time)
end

function waiting(time)
  IWPStage:removeRunDelay(WAITING_DELAYFUNC_ID)
  IWPStage:runDelay(WAITING_DELAYFUNC_ID, function()
  waitingMotion = false
  end,  time)
end

function waitingDraw(time)
  IWPStage:removeRunDelay(WAITING_DRAWING_DELAYFUNC_ID)
  IWPStage:runDelay(WAITING_DRAWING_DELAYFUNC_ID, function()
  waitingDrawflag = false
  end,  time)
end

function onCampaignDialogShow(title)
  Slog:i(TAG, "[onCampaignDialogShow] title=" .. title)
  IWPActor:playAnimation("ovoyGirl happy.mtn", true)
end




-- ==================
-- alarm script start
-- ==================
IWPAlarmClock=nil
isSetAlarmClock=false
function onAlarmClockTrigger(luaAlarmClock, speechWords)
  Slog:d(TAG, "onAlarmClockTrigger:" .. speechWords)
  IWPAlarmClock=luaAlarmClock
  isSetAlarmClock=true;


  date = os.date("*t")
  Slog:d(TAG, "alarm time: hour=" .. date.hour .. " minute= " .. date.min ..  " second =" .. date.sec)
  reportTime = "<font color='#00a1ff'>■ 現在時間 " .. date.hour .. ":" .. date.min .. " ■</font>   "

  alarm_dialog_style = {
    background="images/dialog.png",
    textSize=20,
    positionMode="center_above_actor",
    positionY=0.4,
    textAlign=center,
    width=1.5,
    paddingTop=0.08,
    paddingBottom=0.08
  }

  if speechWords ~= "" then
    IWPActor:showActorDialog(reportTime .. "<br><br>   " .. speechWords, 600000,alarm_dialog_style)
  else
    IWPActor:showActorDialog(reportTime, 600000,alarm_dialog_style)
  end

  IWPActor:playAnimation("ovoyGirl happy.mtn",true,true)

end
