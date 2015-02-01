function waitForWifi()
  maxTries = 10
  count = count + 1
  wifi_ip = wifi.sta.getip()
  if wifi_ip == nil and count < maxTries then
    tmr.alarm(0, 1000,0,waitForWifi)
  elseif count >= maxTries then
    wifi_connected = false
    uMessage("uMessenger","Connection timed out.");
    tmr.alarm(0,3000,0,setupAP)
  else
    wifi_connected = true
    uMessage("uMessenger","Connected. Received IP "..wifi_ip);
    dofile("server.lua")
  end
end


function setupAP()
  wifi.sta.disconnect()
  wifi.setmode(wifi.SOFTAP)
  wifi.ap.config({ssid="uMessenger",pwd="initialSetup"})
  wifi_ip = wifi.ap.getip()
  uMessage("uMessenger","Please connect to 'uMessenger' with password 'initialSetup' and open http://"..wifi_ip..":1337");
  dofile("setupServer.lua")
end


-- Wait for WiFi --
uMessage("uMessenger","Connecting to Wifi...");
count=0
wifi.setmode( wifi.STATION )
wifi.sta.connect()
waitForWifi()