$(document).ready(function(){
  $("#logo").click(function() {
    $("#nav").slideToggle("fast");
  })

  $("h2.section_heading").click(function() {
    var section_idx = parseInt($(this).children("a").get(0).id.replace( /section_(\d+)/, "$1" ));
    wm_toggle_section( section_idx );
  })

  $("a").click(function() {
    var link = $(this).get(0)
    if( link.hash.indexOf("#") == 0 ) {
      wm_reveal_for_hash( link.hash )
    }
  })

  if( document.location.hash.indexOf("#") == 0 ) {
    wm_reveal_for_hash( document.location.hash )
  }

});

function wm_reveal_for_hash( hash ) {
 var targetel = $(hash)
 if(targetel) {
   var parentdiv = targetel.parents("div.content_block")
   if(parentdiv && ! parentdiv.is(':visible')) {
     var section_idx = parseInt(parentdiv.get(0).id.replace( /content_(\d+)/, "$1" ));
     wm_toggle_section( section_idx )
   }
 }
}

function wm_toggle_section( section_id ) {
  var buttons = $("a#section_"+section_id).siblings("button.show").toggle();
  var buttonh = $("a#section_"+section_id).siblings("button.hide").toggle();

  $("div#content_"+section_id).slideToggle("fast")
  $("div#anchor_"+section_id).slideToggle("fast")
}

var wm_clearText = function() {
  document.getElementById("searchField").value = "";
  $("#searchField").val("").focus();
}

// If we are on iPhone, scroll down and hide URL bar
if(navigator.userAgent.indexOf("iPhone") > 0) {
  window.scrollTo(0, 1);
}
