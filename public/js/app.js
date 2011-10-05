$(document).ready(function() {

  function imageLoaded(e) {
    var img = $("#preview");
    img.attr("src", e.target.result);
  }

  function handleImage(file) {
    var xhr    = new XMLHttpRequest();
    var upload = xhr.upload;
    xhr.open("POST", "/recommend" , true);
    xhr.onreadystatechange = function() {
      if (xhr.readyState === 4) {
        data = {};
        data["songs"] = $.parseJSON(xhr.responseText);
        var playlist = $("#playlist");
        playlist.html("");
        $.get('/js/songlist.js.tmpl', function(template) {
          $.tmpl(template, data).appendTo(playlist);
        });
      }
    }
    xhr.send(file);

    var reader = new FileReader();
    reader.onloadend = imageLoaded;
    reader.readAsDataURL(file);
  }

  function checkFiles(files) {
    var file = files[0];
    if (file.type.match(/image\/\w+/)){
      return file.size != 0;
    }
    else {
      $("<p/>").addClass("error").html("Please drop an image").appendTo("#errors");
    }

    return false;
  }


  function nullHandler(e) {
    e.stopPropagation();
    e.preventDefault();
  }

  function dropHandler(e) {
    nullHandler(e);

    $("#errors").html("");
    var files = e.originalEvent.dataTransfer.files
    if (checkFiles(files))
      handleImage(files[0])
  }

  var dropbox = $("#dropbox")
  dropbox.bind("dragenter dragexit dragover", nullHandler)
  dropbox.bind("drop", dropHandler)
});


