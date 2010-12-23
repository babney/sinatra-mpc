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

#ugh, this seems really dangerous but I don't feel like writing a wrapper around Mpc at the moment
$library = Mpc.new(MPD_HOST, MPD_PORT).list_library

get '/' do
  session[:cwd] = "/" if session[:cwd].nil?
  erb :"index.html"
end

get '/controls/:control' do
  @mpc = Mpc.new(MPD_HOST, MPD_PORT)
  if params[:control].match(/next|previous|stop|play|pause/)
    retried = false
    begin
      eval("@mpc.#{params[:control]}")
    rescue
      if !retried
        sleep 2
        retried = true
        puts "retrying"
        @mpc = Mpc.new(MPD_HOST, MPD_PORT)
        retry
      end
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
  retried = false
  begin
    @mpc.seek(0,params[:pos])
  rescue
    if !retried
      sleep 2
      retried = true
      puts "retrying"
      @mpc = Mpc.new(MPD_HOST, MPD_PORT)
      retry
    end
  end
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
  
  #puts "DEBUG DEBUG DEBUG I have #{segments}"
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
  #not done yet
  content_type :json
  mpc = Mpc.new(MPD_HOST, MPD_PORT)
  addme = session[:cwd] + "/" + params[:add]
  mpc.add_to_playlist(addme)
end

def send_current_track
  @mpc = Mpc.new(MPD_HOST, MPD_PORT)
  content_type :json
  playing = @mpc.playing?
  current = @mpc.current_song
  if current.nil?
    {:playing => playing}.to_json
  else
    {:title => current[:title], :album => current[:album], :artist => current[:artist], :playing => playing}.to_json
  end
end
