var moz, test, file_form;

function test (e) {
  console.log(e);
}

function doc_all () {
  moz = document.all ? false : true; // mozilla doesn't support document.all
}

window.onload = function() {
  doc_all();
  document.getElementById('file_upload').onchange = function(e) {
    read_files(e);
    show_submit();
  };
  
  var body = document.getElementsByTagName('body')[0];
  
  // body.ondragover = function (e) {
  //   e.stopPropagation();
  //   e.preventDefault();
  //   // console.log(e)
  // }
  // 
  // body.ondrop = function (e) {
  //   // e.stopPropagation();
  //   // e.preventDefault();
  //   test = e.dataTransfer.files;
  //   read_files(e.dataTransfer.files);
  // }
}

function read_files (event) {
  var file_list = event.target.files;
  var files_div = document.getElementById('files');
  while(files_div.hasChildNodes()) {
    files_div.removeChild(files_div.lastChild);
  }
  
  for (var i=0; i < file_list.length; i++) {
    // file_list[i];
    
    var file = document.createElement('li');
    if (!moz) { file.innerText   = file_list[i].fileName; }  // Webkit
    else      { file.textContent = file_list[i].fileName; }; // mozilla
    
    files_div.appendChild(file)
  }
}

function show_submit () {
  var submit = document.getElementById('submit');
  submit.style.display = 'block';
}