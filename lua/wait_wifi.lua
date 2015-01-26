-- from http://www.esp8266.com/viewtopic.php?f=18&t=628
function wait_wifi()
  count = count + 1
  wifi_ip = wifi.sta.getip()
  if wifi_ip == nil and count < 20 then
    tmr.alarm(0, 1000,0,wait_wifi)
  elseif count >= 20 then
    wifi_connected = false
    uMessage("uMessenger","Connection timed out.");
  else
    wifi_connected = true
    uMessage("uMessenger","Connected. Received IP "..wifi_ip);
    dofile("server.lua")
  end
end

-- Wait for WiFi --
uMessage("uMessenger","Connecting to Wifi...");
count=0
wifi.setmode( wifi.STATION )
wifi.sta.config( "BennyBorn", "5936741661153258" )
wifi.sta.connect()
wait_wifi()