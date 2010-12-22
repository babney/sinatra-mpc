require 'bundler'
require 'socket'
require 'tree'
require 'mpc'
require 'erb'
require 'json'
require 'sinatra'

#this should overwrite the defaults, I need to read up on sinatra app configuration to do this right
begin
  require 'settings'
rescue
  puts "couldn't find a settings.rb file, falling back to the defaults"
  require 'settings-default'
end

enable :sessions

#ugh, this seems really dangerous but I don't feel like writing a wrapper around Mpc at the moment
$library = Mpc.new(MPD_HOST, MPD_PORT).list_library

get '/' do
  #session[:library_pos] = $library.root if session[:library_pos].blank?
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
  #let's just be lazy and do it by index for now, maybe it'll even be in order
  dir = "/"
  if params[:dir] == ".."
    dir = $library_pos.parent
  end
  #$library_pos = newdir
  @names = []
  $library.children.each do |node|
    @names << node.name
  end
  @names.to_json
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
