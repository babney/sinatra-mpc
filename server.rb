require 'socket'
require 'tree'
require 'mpc'
require 'mpc-monkeypatch'
require 'erb'
require 'json'
require 'sinatra'
require 'settings'

get '/' do
  @mpc = Mpc.new(MPD_HOST, MPD_PORT)
  mpc_stuff = @mpc.ping
  @title = mpc_stuff[:title]
  @album = mpc_stuff[:album]
  @artist = mpc_stuff[:artist]
  @songs = @mpc.current_playlist_songs
  @playing_sym = @mpc.playing? ? "||" : ">"
  erb :"index.html"
end

get '/next' do
  @mpc = Mpc.new(MPD_HOST, MPD_PORT)
  @mpc.next()
  send_current_track
end

get '/prev' do
  @mpc = Mpc.new(MPD_HOST, MPD_PORT)
  @mpc.previous()
  send_current_track  
end

get '/stop' do
  @mpc = Mpc.new(MPD_HOST, MPD_PORT)
  @mpc.stop()
  send_current_track
end

get '/playpause' do
  @mpc = Mpc.new(MPD_HOST, MPD_PORT)
  content_type :json
  sym = ""
  if !@mpc.playing?
    @mpc.play
    sym = "||"
  else
    @mpc.pause
    sym = ">"
  end
  {:sym => sym}.to_json
end

get '/switch_track' do
  @mpc = Mpc.new(MPD_HOST, MPD_PORT)
  @mpc.seek(0,params[:pos])
  send_current_track
end

def send_current_track
  content_type :json
  current = @mpc.ping
  {:title => current[:title], :album => current[:album], :artist => current[:artist]}.to_json
end
