require 'socket'
require 'tree'
require 'mpc'
require 'mpc-monkeypatch'
require 'erb'
require 'json'
require 'sinatra'
require 'settings'

#ugh, this seems really dangerous but I don't feel like writing a wrapper around Mpc at the moment
$mpc = Mpc.new(MPD_HOST, MPD_PORT)
$library = $mpc.list_library

get '/' do
  #mpc_stuff = $mpc.current_song
  #@title = mpc_stuff[:title]
  #@album = mpc_stuff[:album]
  #@artist = mpc_stuff[:artist]
  #@songs = $mpc.current_playlist_songs
  @playing_sym = $mpc.playing? ? "||" : ">"
  erb :"index.html"
end

get '/next' do
  $mpc.next()
  send_current_track
end

get '/prev' do
  $mpc.previous()
  send_current_track  
end

get '/stop' do
  $mpc.stop()
  send_current_track
end

get '/playpause' do
  content_type :json
  sym = ""
  if !$mpc.playing?
    $mpc.play
    sym = "||"
  else
    $mpc.pause
    sym = ">"
  end
  {:sym => sym}.to_json
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
  $mpc.seek(0,params[:pos])
  send_current_track
end

def send_current_track
  content_type :json
  current = $mpc.current_song
  {:title => current[:title], :album => current[:album], :artist => current[:artist]}.to_json
end
