$(document).ready(function(){
  $.getJSON('/current_track', {}, function(data){
    replace_current(data)
  })
  $.getJSON('/current_playlist', {}, function(data){
    replace_playlist(data)
  })
})

$(".playlist-item").live("click", function(){
  $.getJSON('/switch_track', {pos: $(this).attr("id")}, function(data){
    replace_current(data)
  })
})

$(".controls span").live("click", function(){
  $.getJSON($(this).attr("id"), {}, function(data){
    replace_current(data)
  })
})

function replace_current(data){
  $("#current_title").html(data.title)
  $("#current_artist").html(data.artist)
  $("#current_album").html(data.album)
  kill_player()
}

function replace_playlist(data){
  var playlist = $(".playlist ul")
  console.log(playlist)
  playlist.empty()
  $.each(data, function(index, playlist_item){
    playlist.append('<li class="playlist-item" id="'+ playlist_item.pos + '">' + playlist_item.artist + ' - ' + playlist_item.title + ' - ' + playlist_item.album + '</li>')
  })
}

function restart_player()
{
  setTimeout("kill_player()",8000);
}
function kill_player(){
  var replace = $("#player").html()
  $("#player").empty()
  $("#player").html(replace)
  $("#player_audio")[0].play()
}
