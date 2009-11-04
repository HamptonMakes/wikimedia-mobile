module NativeAppHack
  def self.js
    %|
      var activateButtons = function() {
        $("h2.section_heading").click(function() {
          var id_name = $(this).get(0).id
          var numeric_string = id_name.replace(/[-A-z_]*/, "");
          var section_idx = parseInt(numeric_string);
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
      };
      
      function wm_toggle_section( section_id ) {
        $("h2#section_" + section_id).children("button.show").toggle();
        $("h2#section_" + section_id).children("button.hide").toggle();

        $("div#content_" + section_id).toggle()
        $("div#anchor_" + section_id).toggle()
      }
      
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
    |
  end
end