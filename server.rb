require 'bundler'
require 'socket'
require 'tree'
require 'mpc'
require 'erb'
require 'json'
require 'sinatra'
require 'settings'

enable :sessions

#ugh, this seems really dangerous but I don't feel like writing a wrapper around Mpc at the moment
$library = Mpc.new(MPD_HOST, MPD_PORT).list_library

get '/' do
  #session[:library_pos] = $library.root if session[:library_pos].blank?
  erb :"index.html"
end

get '/controls/:control' do
  @mpc = Mpc.new(MPD_HOST, MPD_PORT)
  if params[:control].match(/next|prev|stop/)
    eval("@mpc.#{params[:control]}")
  elsif params[:control].match(/playpause/)
   if !@mpc.playing?
    @mpc.play
   else
    @mpc.pause
   end
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

get '/show_library' do
  show_library
end

get '/cd' do
  #let's just be lazy and do it by index for now, maybe it'll even be in order
  newdir = nil
  unless params[:index] == ".."
    newdir = $library_pos[params[:index].to_i]
  else
    newdir = $library_pos.parent
  end
  $library_pos = newdir
  show_library
end

def show_library
    content_type :json
  @names = []
  $library_pos.children.each do |node|
    @names << node.name
  end
  @names.to_json
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
