// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults


$(function() {
  $('button.show').click(function(thing) {
    var section_id = $(this).attr("section_id");
    $("#content_" + section_id).show();
    $(this).hide();
    $('button.hide[section_id=' + section_id + ']').show()
  })
  
  $('button.hide').click(function(thing) {
    var section_id = $(this).attr("section_id");
    $("#content_" + section_id).hide();
    $(this).hide();
    $('button.show[section_id=' + section_id + ']').show()
  })
  
  // Increase Font Size
  $(".increaseFont").click(function(){
    var currentFontSize = $('#article').css('font-size');
    var currentFontSizeNum = parseFloat(currentFontSize, 10);
    var newFontSize = currentFontSizeNum*1.2;
    $('#article').css('font-size', newFontSize);
    return false;
  });

  // Decrease Font Size
  $(".decreaseFont").click(function(){
    var currentFontSize = $('#article').css('font-size');
    var currentFontSizeNum = parseFloat(currentFontSize, 10);
    var newFontSize = currentFontSizeNum*0.8;
    $('#article').css('font-size', newFontSize);
    return false;
  });
  
})

function shouldCache() {
  return($("body").html().indexOf('<h1 class="firstHeading">Search results</h1>') == -1);
}