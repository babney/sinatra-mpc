$(document).ready(function(){
  $.getJSON('/current_track', {}, function(data){
    replace_current(data)
  })
  $.getJSON('/current_playlist', {}, function(data){
    replace_playlist(data)
  })
  $.getJSON('/show_dir', {dir: "/"}, function(data){
    replace_library_view(data)
  })
})

$(".playlist-item").live("click", function(){
  $.getJSON('/switch_track', {pos: $(this).attr("id")}, function(data){
    replace_current(data)
  })
})

$(".controls span").live("click", function(){
  $.getJSON("/controls/" + $(this).attr("id"), {}, function(data){
    replace_current(data)
  })
})

function replace_library_view(data){
  var lib = $(".library ul")
  lib.empty()
  $.each(data, function(index, item){
    lib.append('<li class="library-item" id="' + index + '">' + item + '</li>')
  })
}

function replace_current(data){
  $("#current_title").html(data.title)
  $("#current_artist").html(data.artist)
  $("#current_album").html(data.album)
  if(data.playing){
    $("#play").hide()
    $("#pause").show()
  }
  else{
    $("#pause").hide()
    $("#play").show()
  }
  kill_player()
}

function replace_playlist(data){
  var playlist = $(".playlist ul")
  console.log(playlist)
  playlist.empty()
  $.each(data, function(index, playlist_item){
    playlist.append('<li class="playlist-item" id="'
    + playlist_item.pos + '">'
    + playlist_item.artist + ' - '
    + playlist_item.title + ' - '
    + playlist_item.album + '</li>')
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
