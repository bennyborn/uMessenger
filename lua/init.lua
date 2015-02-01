uMessage = function( title, msg )
  title = string.gsub(title,'#',' ')
  msg = string.gsub(msg,'#',' ')
  print("::MSG::"..title.."#"..msg.."##"..'\n')
end

dofile("connect.lua")