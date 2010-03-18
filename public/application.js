
jQuery(function () {

  $(".votelink").click(function () {
      var asot_no = $(this).attr('no');
      $.post("/asots/"+asot_no+"/vote", function(data) {
        $("#" + asot_no + "_url").html(data);
      });
      $(this).fadeOut("2000");
      return false;
    });

});
