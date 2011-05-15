$(document).ready(function(){
  get_current(true)
  $.getJSON('/current_playlist', {}, function(data){
    replace_playlist(data)
  })
  $.getJSON('/show_dir', {}, function(data){
    replace_library_view(data)
  })
  $("#tabs").tabs()
})

function get_current(killit){
  $.getJSON('/current_track', {}, function(data){
    replace_current(data, killit)
  })
}

setInterval('get_current(false)', 1000)

$(".library .name").live("click", function(){
	$.getJSON('/show_dir', {dir: $(this).html()}, function(data){
    replace_library_view(data)
  })
})

$(".library .add").live("click", function(){
  $.getJSON('/add_to_playlist', {addme: $(this).parent().find(".name").html()}, function(data){
    replace_playlist(data)
  })
})

$(".search-results .add").live("click",function(){
  $.getJSON('/add_to_playlist_from_search', {addme: $(this).parent().find(".file").html()}, function(data){
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

$("#submit-search").live("click", function(){
  $.getJSON('/search', {search: $("#search").val()}, function(data){
    replace_search_list(data)
    $("#tabs").tabs("select", "#search-results")
  })
})

function replace_search_list(data){
  var lib = $(".search-results ul")
  lib.empty()
  $.each(data, function(index, item){
    lib.append('<li class="library-item"><div class="add">+</div><div class="name">' + item.artist + " - " + item.title + " - " + item.album + '</div><div style="clear:both;"></div><div class="hidden file">' + item.file + '</div></li>')
  })
}

function replace_library_view(data){
  var lib = $(".library ul")
  lib.empty()
  lib.append('<li class="library-item"><div class="name">..</div><div style="clear:both;"></div></li>')
  $.each(data, function(index, item){
    lib.append('<li class="library-item"><div class="add">+</div><div class="name">' + item + '</div><div style="clear:both;"></div></li>')
  })
}

function replace_current(data, killit){
  old_title = $("#current_title").html()
  old_artist = $("#current_artist").html()
  old_album = $("#current_album").html()
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
  if((killit == true || old_title != data.title || old_artist != data.artist || old_album != data.album)&& data.playing){
    kill_player()
  }
}

function replace_playlist(data){
  var playlist = $(".playlist ul")
  console.log(playlist)
  playlist.empty()
  $.each(data, function(index, playlist_item){
    playlist.append('<li class="playlist-item"><div class="remove">-</div><div class="name" id="'
    + playlist_item.pos + '">'
    + playlist_item.artist + ' - '
    + playlist_item.title + ' - '
    + playlist_item.album + '</div><div style="clear:both;"></div></li>')
  })
}

function restart_player()
{
  setTimeout("kill_player()",8000);
}

$("#kill-player").live("click", function(){
  kill_player()
})

function kill_player(){
  var replace = $("#player").html()
  $("#player").empty()
  $("#player").html(replace)
  $("#player_audio")[0].play()
}
