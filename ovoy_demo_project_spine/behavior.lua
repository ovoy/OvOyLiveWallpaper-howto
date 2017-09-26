--
-- Modified by mill_chen
-- Date: 2017/07/26
-- Time: 上午 11:46
-- To change animation dialog API
--
str = "Shine spine lua script"
VERSION = 1
TAG = "OPO_DEMO"
IWPActor=nil
IWPStage=nil

IDLE_ACTION_TIME= 10000
CLOCK_DELAY_FUNCTION_ID = 1
GOTOIDLE_DELAYFUNC_ID = 2
SKIRT_ANIMATE_FUNC_ID = 3
TOUCH_DELAYFUNC_ID=4
IDLE_ACTION_DELAY_FUNCTION_ID=5

shownDialog = nil

lastClockReportHour=-1
lastShowHour =-1
waitClockFunction = nil
isInAction=false
needCalibrate = false


---- tap event action parameters ----------
tapCount = 0
PAN_TRIGGER_DURATION = 3
panheadStartTime = 0;
startPan = false
Complete = true
-------------------------------------------


-- event From Spine client applicaton --------------------------------------
function info()
    Slog:i(TAG, str .. " v:"..VERSION)
end

function onCreate(actor, stage)

    IWPActor = actor
    IWPStage = stage
    actor:addTouchHandler(onTouch)
    actor:setAnimationHandler(onAnimationEvent)
    actor:setDefaultDialogStyle({
        background="images/dialog.png",
        textSize=22,
        positionMode="center_above_actor",
        positionY=0.05
    })

    stage:addEventListener("battery", onBattery)
    stage:addEventListener("power", onPower)
    stage:addEventListener("headset", onHeadset)
    stage:addEventListener("shake", onShake)

    Slog:i(TAG, "[onCreate]")

end


-- device event function ----------------------------------------------------------
function onBattery(para)
    if para == "low" then
        animationAndDialog("Idle", "　好累呦...需要充電...　", 5000, nil, false)
        Slog:i(TAG, "battery low!")
    elseif para == "okay" then
        animationAndDialog("Hand-wave", "　耶！我現在元氣滿滿！　", 5000, nil, false)
        Slog:i(TAG, "battery okay!")
    end
end

function onPower(para)
    if para == "connected" then
        animationAndDialog("Hand-wave", "　來補充果實能量吧！　", 5000, nil, false)
        Slog:i(TAG, "power connected!")
    elseif para == "disconnected" then
        animationAndDialog("Hand-wave", "　呆呆能量補充完畢！　", 5000, nil, false)
        Slog:i(TAG, "power disconnected!")
    end
end

function onHeadset(para)
    if para == "plugged" then
        animationAndDialog("Wonder", "　有什麼好聽的音樂嗎？　", 5000, nil, false)
        Slog:i(TAG, "headset plugged!")
    elseif para == "unplugged" then
        animationAndDialog("Idle", "　讓耳朵休息一下吧！　", 5000, nil, false)
        Slog:i(TAG, "headset unplugged!")
    end
end

function onShake(para)
    animationAndDialog("L_Fly", "　嘿嘿嘿～一起開趴踢囉！　", 5000, nil, false)
    Slog:i(TAG, "shake and dance")
end

-- end of device event function ----------------------------------------------------------


function onShow(screenOnOrUnlocked)
    Slog:i(TAG, "[onShow]")
    if (screenOnOrUnlocked) then
        Slog:d(TAG, "screenOnOrUnlocked = true")
    else
        Slog:d(TAG, "screenOnOrUnlocked = false")
    end

    date = os.date("*t")

    Slog:d(TAG, "onShow hour=" .. date.hour .. " minute= " .. date.min ..  " second =" .. date.sec)

    --check 整點報時
    if lastClockReportHour ~= date.hour  then
        showClockAction(date.hour)
        return
    end

    waitTime =  ((60-date.min) * 60 - date.sec) * 1000;
    Slog:d(TAG, "wait " .. waitTime/1000 .. " sec");

    -- IWPStage:runDelay(CLOCK_DELAY_FUNCTION_ID, clockDueFunction, waitTime)

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
    animationAndDialog("Wonder", "　hi 我是OPO!　", 6000, nil, false)
end


---- pan event action parameters ----------
TAP_COUNT_LIMIT = 3
TAP_DURATION = 1
tapStartTime = 0;
startTap = 0;
-------------------------------------------
function onTouch(event)
    Slog:i(TAG, "[onTouch] name=" .. event.name .. " part=" .. event.touchPart)
    if event.name == "touchDown" then
    elseif event.name == "tap" then

        tapAction()

    elseif event.name == "longPress" then
    elseif event.name == "fling" then
    elseif event.name == "pan" then

        panAction()

    elseif event.name == "panStop" then
        startPan = false
    elseif event.name == "zoom" then
    elseif event.name == "pinch" then
    elseif event.name == "pinchStop" then
    end

    resetTapCount(event)
end


function showClockAction(hour)
    lastClockReportHour = hour
    msg = "，"
    if hour >= 0 and hour <= 4 then
        msg = msg .. "很晚了，早點休息吧:D　"
    elseif hour > 4 and hour <= 6 then
        msg = msg .. "太陽公公還沒出來呢...　"
    elseif hour > 6 and hour <= 8 then
        msg = msg .. "早安！一起吃早餐吧！　"
    elseif hour > 8 and hour <= 11 then
        msg = msg .. "好想出去玩哦～　"
    elseif hour > 11 and hour <= 13 then
        msg = msg .. "中午囉，休息一下吧！　"
    elseif hour > 13 and hour <= 17 then
        msg = msg .. "點心要吃什麼呢？　"
    elseif hour > 17 and hour <= 20 then
        msg = msg .. "回家路上要小心喔！　"
    elseif hour > 20 and hour <= 22 then
        msg = msg .. "學校作業寫完了嗎？　"
    elseif hour > 22 and hour <= 23 then
        msg = msg .. "準備來洗洗睡...Zzz　"
    end


    if hour > 12 then
        hour = hour - 12
    end

    if hour == 0 then
        hour = 12
    end

    msg = "　現在是" .. hour .. "點" .. msg

    animationAndDialog("Wonder", msg, 6000, nil, false)
end

function resetTapCount(event)
    if event.name ~= "tap" and event.name ~= "touchDown" then
        tapCount = 0 --reset tapCount
    end
end

function onAnimationEvent(event)
    if Complete == false then
        Complete = true
        isInAction = false
    end

    if needCalibrate == true and Complete == true then
        needCalibrate = false
        -- calibrate animation
        IWPActor:playAnimation("Idle", false)
    end
end

function tapAction()
    tapCount = tapCount + 1

    if isInAction then
        return
    end

    if startTap == false then
        startTap = true
        tapStartTime = os.time()
    end

    duration = os.time() - tapStartTime
    if duration >= TAP_DURATION then --out of tap time then reset tap parameters
        tapCount = 0 --reset tapCount
        startTap = false
    end

    if tapCount >= TAP_COUNT_LIMIT and Complete == true then
        isInAction = true
        Complete = false
        animationAndDialog("Hand-wave", "　你聽過嗎OvOy嗎？　", 3000, nil, false)
        Slog:i(TAG, "[tapAction] Wonder")
    else

       isInAction = true
        math.randomseed(os.time())
        local ran = math.random(1, 12)
          -- calibrate animation
          IWPActor:playAnimation("Idle", true)
          needCalibrate = true
        if ran == 1 then
            animationAndDialog("L_Fly", "　一直點不累嗎？　", 2500, nil, true)
            Slog:i(TAG, "[tapAction] talk1")
        elseif ran == 2 then
            animationAndDialog("L_Peck", "　...　", 2500, nil, true)
            Slog:i(TAG, "[tapAction] talk2")
        elseif ran == 3 then
            animationAndDialog("Idle", "　...　", 2500, nil, true)
            Slog:i(TAG, "[tapAction] talk3")
        elseif ran == 4 then
            animationAndDialog("Wonder", "　記得回來看看有什麼好桌布上架　", 2500, nil, true)
            Slog:i(TAG, "[tapAction] talk4")
        elseif ran == 5 then
            animationAndDialog("Wonder", "　你媽知道你在這裡找彩蛋嗎？　", 2500, nil, true)
            Slog:i(TAG, "[tapAction] talk5")
        elseif ran == 6 then
            animationAndDialog("L_Peck", "　請勿拍打餵食！　", 2500, nil, true)
            Slog:i(TAG, "[tapAction] talk6")
        elseif ran == 7 then
            animationAndDialog("L_Fly", "　不要滑手機了，起來動一動吧！　", 2500, nil, true)
            Slog:i(TAG, "[tapAction] talk7")
        elseif ran == 8 then
            animationAndDialog("Idle", "　珍奶喝太多，變胖了...　", 2500, nil, true)
            Slog:i(TAG, "[tapAction] talk8")
        elseif ran == 9 then
            animationAndDialog("Hand-wave", "　OvOy　", 2500, nil, true)
            Slog:i(TAG, "[tapAction] talk9")
        elseif ran == 10 then
            animationAndDialog("Idle", "　...　　", 2500, nil, true)
            Slog:i(TAG, "[tapAction] talk10")
        elseif ran == 11 then
            animationAndDialog("L_Fly", "　...　", 2500, nil, true)
            Slog:i(TAG, "[tapAction] talk11")
        elseif ran == 12 then
            animationAndDialog("Hand-wave", "　每天OvOy角色陪伴我，考試都考 100 分　", 2500, nil, true)
            Slog:i(TAG, "[tapAction] talk12")
        end
        tapCount = 0 --reset tapCount
        Complete = false

    end
    goToIdleLater(30000)
end

function panAction()
    if isInAction then
        return
    end

    if (startPan == false) then
        startPan = true
        panheadStartTime = os.time()
    end


    duration = os.time() - panheadStartTime
    if duration >= PAN_TRIGGER_DURATION  and Complete == true then
        isInAction = true
        animationAndDialog("L_Fly", "　哈哈～ 快跟我一起跳～　", 5000, nil, true)
        Slog:i(TAG, "[panAction]dance")
        startPan = false
        Complete = false
    else
        isInAction = true
        animationAndDialog("Wonder", "　嗯嗯，原來如此～　", 3000, nil, true)
        Slog:i(TAG, "[panAction]Wonder")
        Complete = false
    end
    goToIdleLater(30000)
end

function goIdleState()
    isInAction = false
    Slog:d(TAG, "goIdleState");
end

function goToIdleLater(time)
  Slog:d(TAG, "start GOTOIDLE_DELAYFUNC_ID timer ".. time);
  IWPStage:removeRunDelay(GOTOIDLE_DELAYFUNC_ID)
  IWPStage:runDelay(GOTOIDLE_DELAYFUNC_ID, function()
  goIdleState()
  end,  time)
  Slog:d(TAG, "start GOTOIDLE_DELAYFUNC_ID timer end");
end

function touchBKDown(IWPActor, x, y)
    isInAction = false
    IWPActor:runToTarget(x, y)
end


function animationAndDialog(animation, msg, duration, dialogStyle, overrideCurrent)
    if shownDialog ~= nil then
        shownDialog:dismiss()
    end

    if dialogStyle ~= nil then
        shownDialog = IWPActor:showActorDialog(msg, duration, dialogStyle)
    else
        shownDialog = IWPActor:showActorDialog(msg, duration)
    end

    if overrideCurrent then
        IWPActor:playAnimation(animation, overrideCurrent)
    else
        IWPActor:playAnimation(animation)
    end
end
