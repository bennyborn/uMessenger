hex_to_char = function(x)
  return string.char(tonumber(x, 16))
end

unescape = function(data)
  str = string.gsub(data,'+',' ')
  str = str:gsub("%%(%x%x)", hex_to_char)
  return str
end

sendFile = function(conn, filename)
  if file.open(filename, "r") then
    repeat
      local line=file.readline()
      if line then
        conn:send(line);
      end
    until not line
      file.close();
  end
end

-- from http://www.esp8266.com/viewtopic.php?f=19&t=1099
parseRequest = function(request)  
  _, _, method, url = string.find(request, "(%a+)%s([^%s]+)")
  if not url then return nil end
  _, _, path, queryString = string.find(url, "([^%s]+)%?([^%s]+)")
  if queryString then
    query = {}
    for name, value in string.gfind(queryString, "([^&=]+)=([^&=]+)") do
      query[name] = value
    end
  else
    path = url
    query = nil
  end
  form = nil
  uef = string.find(request, "Content%-Type: application/x%-www%-form%-urlencoded")
  if uef then
    _, _, body = string.find(request, "\r\n\r\n(%S+)$")
    if body then
      form = {}
      for name, value in string.gfind(body, "([^&=]+)=([^&=]+)") do
        form[name] = unescape(value)
      end
    end
  end
  return {method = method, url = url, path = path, query = query, queryString = queryString, form = form}
end

srv=net.createServer(net.TCP) srv:listen(1337,function(conn)

  conn:on("receive",function(conn,payload)

    request = parseRequest(payload)

    if request then
      print("Request received: ", request.method, request.url)
    else
      print("Invalid request received.")
      return
    end

    -- /
    if request.url == "/" then

      if request.method == "POST" then

        uMessage("uMessenger","Got network credentials, will restart in 5 seconds...");
        tmr.alarm(0,5000,0,node.restart)

        wifi.setmode( wifi.STATION )
        wifi.sta.config( request.form.ssid, request.form.password )

      else

        conn:send("HTTP/1.1 200 OK\r\nConnection: close\r\nServer: uMessenger\r\nContent-Type: text/html\r\n\r\n");
        sendFile(conn,"setup.html");

      end

    -- 404 not found
    else

      conn:send("HTTP/1.1 404 Not Found\r\nConnection: close\r\nServer: uMessenger\r\nContent-Type: text/html\r\n\r\n");

      conn:send('<html><body>');
      conn:send('<p>404 Not found</p>');
      conn:send('</body></html>');

    end

    conn:on("sent",function(conn) conn:close() end)
  end)
end)