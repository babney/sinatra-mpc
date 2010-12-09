require 'socket'
require 'tree'
require 'mpc'
require 'mpc-monkeypatch'
require 'erb'
require 'json'
require 'sinatra'
MPD_HOST="example.org"
MPD_PORT=6600
STREAM_URL="http://example.org:8000/mpd.ogg"

get '/' do
  @mpc = Mpc.new(MPD_HOST, MPD_PORT)
  puts "about to start the magic"
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
  content_type :json
  @mpc.next()
  current = @mpc.current_song
  {:title => current[:title], :album => current[:album], :artist => current[:artist]}.to_json
end

get '/prev' do
  @mpc = Mpc.new(MPD_HOST, MPD_PORT)
  content_type :json
  @mpc.previous()
  current = @mpc.current_song
  {:title => current[:title], :album => current[:album], :artist => current[:artist]}.to_json
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
  content_type :json
  @mpc.seek(0,params[:pos])
  current = @mpc.current_song
  {:title => current[:title], :album => current[:album], :artist => current[:artist]}.to_json
end
