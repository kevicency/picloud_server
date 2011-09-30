$(document).ready(function() {
  function fileLoaded(e) {
    var img = $("#preview");
    img.attr("src", e.target.result);
  }

  function handleFile(file) {
    var xhr    = new XMLHttpRequest();
    var upload = xhr.upload;
    xhr.open("POST", "/upload" , true);
    xhr.setRequestHeader('X-Filename', file.name);
    xhr.onreadystatechange = function() {
      if (xhr.readyState === 4)
        $("#player").html(xhr.responseText)
    }
    xhr.send(file);

    var reader = new FileReader();
    reader.onloadend = fileLoaded;
    reader.readAsDataURL(file);
  }

  function nullHandler(e) {
    e.stopPropagation();
    e.preventDefault();
  }

  function dropHandler(e) {
    nullHandler(e);

    var files = e.originalEvent.dataTransfer.files
    var count = files.length
    console.log(files.length)
    if (count === 1)
      handleFile(files[0])
  }

  var dropbox = $("#dropbox")
  dropbox.bind("dragenter dragexit dragover", nullHandler)
  dropbox.bind("drop", dropHandler)
  console.log("bound")
});


