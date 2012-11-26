require 'sinatra/base'
require 'sinatra-websocket'

class EchoApp < Sinatra::Base
  set :root, File.dirname(__FILE__)
  set :server, 'thin'
  set :sockets, []

  get '/' do
    if !request.websocket?
      erb :index
    else
      request.websocket do |ws|
        ws.onopen do
          ws.send("Hello World!")
          settings.sockets << ws
        end
        ws.onmessage do |msg|
          EM.next_tick { settings.sockets.each{|s| s.send(msg) } }
        end
        ws.onclose do
          warn("wetbsocket closed")
          settings.sockets.delete(ws)
        end
      end
    end
  end

  run! if __FILE__ == $0
end
