require 'socket'
require 'erb'

#this should overwrite the defaults, I need to read up on sinatra app configuration to do this right
begin
  require 'settings'
rescue
  puts "couldn't find a settings.rb file, falling back to the defaults"
  require 'settings-default'
end

#using rackup means I have to set these manually. Lame.
set :views, File.dirname(__FILE__) + '/views'
set :public, File.dirname(__FILE__) + '/public'

enable :sessions

#ugh, this seems really dangerous but it's a lot faster than loading the library over and over.
$library = Mpc.new(MPD_HOST, MPD_PORT).list_library
$mpc = Mpc.new(MPD_HOST, MPD_PORT)

get '/' do
  session[:cwd] = "/" if session[:cwd].nil?
  erb :"index.html"
end

get '/controls/:control' do
  #@mpc = Mpc.new(MPD_HOST, MPD_PORT)
  if params[:control].match(/next|previous|stop|play|pause/)
    eval("$mpc.#{params[:control]}")
  end
  send_current_track
end

get '/current_track' do
  send_current_track
end

get '/current_playlist' do
  content_type :json
  #@mpc = Mpc.new(MPD_HOST, MPD_PORT)
  $mpc.current_playlist_songs.to_json
end

get '/switch_track' do
  #@mpc = Mpc.new(MPD_HOST, MPD_PORT)
  $mpc.seek(0,params[:pos])
  send_current_track
end

get '/show_dir' do
  content_type :json
  segments = []
  #session[:cwd] = params[:dir]
  if params[:dir].nil?
    dir = session[:cwd]
    segments = dir.split "/"
  elsif !(params[:dir] == ".." || params[:dir] == "/")
    dir = session[:cwd] + "/" + params[:dir]
    segments = dir.split "/"
  elsif params[:dir] == ".."
    segments = session[:cwd].split("/")[0..-2]
    dir = segments.join "/"
  elsif params[:dir] == "/"
    segments = []
    dir = "/"
  else # nil?
    dir = session[:cwd]
    segments = dir.split "/"
  end
  session[:cwd] = dir # unsafe?
  pos = $library # start from the root and walk down
  
  segments.each do |segment|
    pos=pos[segment] unless pos[segment].nil?
  end
  names = []
  unless pos.is_leaf?
    pos.children.each do |child|
      names << child.name
    end
  else
    # stay put, give all siblings and self as names, and fix session[:cwd]
    # maybe we should just do a playlist add?
    pos.parent.children.each do |child|
      names << child.name
    end
    session[:cwd] = session[:cwd].split("/")[0..-2].join("/")
  end
  names.to_json
end

get '/add_to_playlist' do
  content_type :json
  #@mpc = Mpc.new(MPD_HOST, MPD_PORT)
  addme = session[:cwd] + "/" + params[:addme]
  fixme = addme.split("/")
  fixme.delete("")
  addme = fixme.join("/")
  puts "trying to add #{addme}"
  $mpc.add_to_playlist(addme)
  $mpc.current_playlist_songs.to_json
end

get '/clear_playlist' do
  content_type :json
  #@mpc = Mpc.new(MPD_HOST, MPD_PORT)
  $mpc.clear!
  #should be empty now
  $mpc.current_playlist_songs.to_json
end

def send_current_track
  #@mpc = Mpc.new(MPD_HOST, MPD_PORT)
  content_type :json
  playing = $mpc.playing?
  current = $mpc.current_song
  if current.nil?
    {:playing => playing}.to_json
  else
    time = $mpc.song_time
    elapsed_i = time.split(":").first.to_i
    elapsed_str = sprintf("%d:%.2d", elapsed_i/60, elapsed_i%60)
    total_i = time.split(":").last.to_i
    total_str = sprintf("%d:%.2d", total_i/60, total_i%60)
    {:title => current[:title], :album => current[:album], :artist => current[:artist], :playing => playing, :elapsed => elapsed_str, :total => total_str}.to_json
  end
end

