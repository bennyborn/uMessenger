if srv then
  srv:close()
end

tmr.alarm(1, 2000, 0, function() uMessage("uMessenger","Server up and running, awaiting messages...") end )

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

srv=net.createServer(net.TCP) srv:listen(80,function(conn)

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

        uMessage( request.form.subject,request.form.message );

        conn:send("HTTP/1.1 200 OK\r\nConnection: close\r\nServer: uMessenger\r\nContent-Type: application/json\r\n\r\n");
        conn:send('{ "error" : false }');

      else

        conn:send("HTTP/1.1 200 OK\r\nConnection: close\r\nServer: uMessenger\r\nContent-Type: text/html\r\n\r\n");
        sendFile(conn,"header.html");

        conn:send('<input name="subject" placeholder="Your Name" type="text" maxlength="40" required>');
        conn:send('<input name="message" placeholder="Your Message" type="text" maxlength="127" required>');
        conn:send('<button class="animated infinite pulse">Post message</button>');

        sendFile(conn,"footer.html");

      end

    -- /config
    elseif request.url == "/config" then

      if request.method == "POST" then

        print( request.form.ssid );
        print( request.form.password );

        conn:send("HTTP/1.1 200 OK\r\nConnection: close\r\nServer: uMessenger\r\nContent-Type: application/json\r\n\r\n");
        conn:send('{ "error" : false }');

      else

        conn:send("HTTP/1.1 200 OK\r\nConnection: close\r\nServer: uMessenger\r\nContent-Type: text/html\r\n\r\n");
        sendFile(conn,"header.html");

        conn:send('<p>Please select an access point and enter your password.</p>');
        conn:send('<input name="ssid" placeholder="SSID" type="text" required>');
        conn:send('<input name="password" placeholder="Password" type="text" required>');
        conn:send('<button class="animated infinite pulse">Connect</button>');

        sendFile(conn,"footer.html");

      end

    -- 404 not found
    else

      conn:send("HTTP/1.1 404 Not Found\r\nConnection: close\r\nServer: uMessenger\r\nContent-Type: text/html\r\n\r\n");
      sendFile(conn,"header.html");

      conn:send('<p>404 Not found</p>');

      sendFile(conn,"footer.html");

    end

    conn:on("sent",function(conn) conn:close() end)
  end)
end)