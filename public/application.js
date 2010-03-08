
jQuery(function () {

  $(".votelink").click(function () {
      var asot_no = $(this).attr('no');
      $.post("/asots/"+asot_no+"/vote");
      $(this).text("Thanks.");
      $(this).fadeOut("2000");
      return false;
    });

});
