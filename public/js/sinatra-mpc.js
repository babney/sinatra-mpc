$(document).ready(function(){
  get_current(true)
  $.getJSON('/current_playlist', {}, function(data){
    replace_playlist(data)
  })
  $.getJSON('/show_dir', {}, function(data){
    replace_library_view(data)
  })
})

function get_current(killit){
  $.getJSON('/current_track', {}, function(data){
    replace_current(data, killit)
  })
}

setInterval('get_current(false)', 5000)

$(".library-item .name").live("click", function(){
	$.getJSON('/show_dir', {dir: $(this).html()}, function(data){
    replace_library_view(data)
  })
})

$(".library-item .add").live("click", function(){
  $.getJSON('/add_to_playlist', {addme: $(this).parent().find(".name").html()}, function(data){
    replace_playlist(data)
  })
})

$(".playlist-item .remove").live("click", function(){
  $.getJSON('/remove_from_playlist', {pos: $(this).parent().find(".name").attr("id")}, function(data){
    replace_playlist(data)
  })
})

$(".playlist-item .name").live("click", function(){
  $.getJSON('/switch_track', {pos: $(this).attr("id")}, function(data){
    replace_current(data, true)
  })
})

$(".controls span.control").live("click", function(){
  $.getJSON("/controls/" + $(this).attr("id"), {}, function(data){
    replace_current(data, true)
  })
})

$("#clear-playlist").live("click", function(){
  $.getJSON('/clear_playlist', {}, function(data){
    replace_playlist(data)
  })
})

function replace_library_view(data){
  var lib = $(".library ul")
  lib.empty()
  lib.append('<li class="library-item"><span class="name">..</span></li>')
  $.each(data, function(index, item){
    lib.append('<li class="library-item"></span><span class="add">+</span><span class="name">' + item + '</li>')
  })
}

function replace_current(data, killit){
  $("#current_title").html(data.title)
  $("#current_artist").html(data.artist)
  $("#current_album").html(data.album)
  $("#current_time").html(data.time)
  if(data.playing){
    $("#play").hide()
    $("#pause").show()
  }
  else{
    $("#pause").hide()
    $("#play").show()
  }
  if(killit == true){
    kill_player()
  }
}

function replace_playlist(data){
  var playlist = $(".playlist ul")
  console.log(playlist)
  playlist.empty()
  $.each(data, function(index, playlist_item){
    playlist.append('<li class="playlist-item"><span class="remove">-</span><span class="name" id="'
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
//  $("#player_audio")[0].play()
}
