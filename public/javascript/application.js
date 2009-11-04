/* Super gross hack implemented where MOST of the JS is repeated in lib/native_app_hack.rb 
If you make significant changes here, make sure to update that version too!*/

$(document).ready(function(){
  $("#logo").click(function() {
    $("#nav").toggle();
  })

  $("h2.section_heading").click(function() {
    var section_idx = parseInt($(this).get(0).id.replace( /section_(\d+)/, "$1" ));
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
   if(parentdiv.length > 0 && ! parentdiv.is(':visible')) {
     var section_idx = parseInt(parentdiv.get(0).id.replace( /content_(\d+)/, "$1" ));
     wm_toggle_section( section_idx )
   }
 }
}

function wm_toggle_section( section_id ) {
  $("h2#section_" + section_id).children("button.show").toggle();
  $("h2#section_" + section_id).children("button.hide").toggle();

  $("div#content_" + section_id).toggle()
  $("div#anchor_" + section_id).toggle()
}

var wm_clearText = function() {
  document.getElementById("searchField").value = "";
  $("#searchField").val("").focus();
}

// If we are on iPhone, scroll down and hide URL bar
if(navigator.userAgent.indexOf("iPhone") > 0) {
  window.scrollTo(0, 1);
}
