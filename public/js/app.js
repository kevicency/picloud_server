$(document).ready(function() {

  var isRecommending = false;

  function imageLoaded(e) {
    var img = $("#preview");
    img.attr("src", e.target.result);
    img.css("visibility", "visible");
    $("#preview_alt").remove();
  }

  function showProgress() {
    isRecommending = true;
    $("#songs").empty();
    $("#progress").css("visibility", "visible")
  }

  function hideProgress() {
    isRecommending = false;
    $("#progress").css("visibility", "collapse")
  }

  function handleImage(file) {
    var xhr    = new XMLHttpRequest();
    var upload = xhr.upload;
    xhr.open("POST", "/recommend" , true);
    xhr.onreadystatechange = function() {
      if (xhr.readyState === 4) {
        hideProgress();
        data = {};
        data["songs"] = $.parseJSON(xhr.responseText);
        $.get('/js/songlist.js.tmpl', function(template) {
          $.tmpl(template, data).appendTo("#songs");
        });
      }
    }
    xhr.send(file);
    showProgress();

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

    $("#errors").empty();
    var files = e.originalEvent.dataTransfer.files
    if (!isRecommending && checkFiles(files))
      handleImage(files[0])
  }

  var dropbox = $("#dropbox")
  dropbox.bind("dragenter dragexit dragover", nullHandler)
  dropbox.bind("drop", dropHandler)
});


