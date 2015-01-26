if srv then
  srv:close()
end

tmr.alarm(1, 2000, 0, function() uMessage("uMessenger","Server up and running, awaiting messages...") end )

hex_to_char = function(x)
  return string.char(tonumber(x, 16))
end

unescape = function(url)
  str = url:gsub("%%(%x%x)", hex_to_char)
  str = string.gsub(str,'+',' ')
  str = string.gsub(str,'#',' ')
  return str
end

sendFile = function(conn, filename)
  if file.open(filename, "r") then
    conn:send("HTTP/1.1 200 OK\r\nConnection: close\r\nServer: uMessenger\r\nContent-Type: text/html\r\n\r\n");
    repeat
      local line=file.readline()
      if line then
        conn:send(line);
      end
    until not line
      file.close();
  else
    conn:send("HTTP/1.1 404 Not Found\r\nConnection: close\r\nServer: uMessenger\r\nContent-Type: text/html\r\n\r\n");
    conn:send("Page not found");
  end
end 

srv=net.createServer(net.TCP) srv:listen(80,function(conn)

  conn:on("receive",function(conn,payload)

    if string.sub(payload,1,4) == "POST" then

      subject = string.match(payload, 'subject=.+&')
      if subject then subject = unescape(string.sub(subject, 9, string.len(subject)-1 )) end

      message = string.match(payload, 'message=.+$')
      if message then message = unescape(string.sub(message, 9)) end

      print("::MSG::"..subject.."#"..message.."##"..'\n')

    end

    sendFile(conn,"index.html");
    conn:on("sent",function(conn) conn:close() end)
  end)
end)