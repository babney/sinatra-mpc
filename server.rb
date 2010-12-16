require 'socket'
require 'tree'
require 'mpc'
require 'mpc-monkeypatch'
require 'erb'
require 'json'
require 'sinatra'
require 'settings'

#enable :sessions

#ugh, this seems really dangerous but I don't feel like writing a wrapper around Mpc at the moment
mpc = Mpc.new(MPD_HOST, MPD_PORT)
$library = mpc.list_library

get '/' do
#  session[:library_pos] = $library.root if session[:library_pos].blank?
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
  if !@mpc.playing?
    @mpc.play
  else
    @mpc.pause
  end
  send_current_track
end

get '/current_track' do
  send_current_track
end

get '/current_playlist' do
  content_type :json
  @mpc = Mpc.new(MPD_HOST, MPD_PORT)
  @mpc.current_playlist_songs.to_json
end

get '/switch_track' do
  @mpc = Mpc.new(MPD_HOST, MPD_PORT)
  @mpc.seek(0,params[:pos])
  send_current_track
end

def send_current_track
  @mpc = Mpc.new(MPD_HOST, MPD_PORT)
  content_type :json
  sym = ""
  if @mpc.playing?
    sym = "||"
  else
    sym = ">"
  end
  current = @mpc.current_song
  {:title => current[:title], :album => current[:album], :artist => current[:artist], :sym => sym}.to_json
end
