var navShowing = false;

$(function() {
  $("button").click(function() {
    var button = $(this);
    var section_id = this.getAttribute("section_id");
    button.hide();
    if(button.hasClass("show")) {
      button.next().show();
      $("#content_" + section_id).show()
      $("#back_to_top_for_" + section_id).show()
    } else {
      $("#content_" + section_id).hide()
      $("#back_to_top_for_" + section_id).hide()
      button.prev().show();
    }
  })
  
  // Make the section headings clickable
  $("h2.section_heading span").click(function(e) {
    $(e.target).parent().children("button:visible").click();
  })
  
  // If we are on iPhone, scroll down and hide URL bar
  if(navigator.userAgent.indexOf("iPhone") > 0) {
    window.scrollTo(0, 1);
  }
  
  $("#logo").click(function() {
    $("#nav").toggle();
  })
  
  $("#clearButton").click(clearText)
});

var clearText = function() {
  document.getElementById("searchField").value = "";
  $("#searchField").val("").focus();
}