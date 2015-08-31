/**
 * Created by tt on 28/8/15.
 */



function attach_Click_event() {
    $(".tab_button").click(function () {
        $(".content_section").hide();
        var id = $(this).attr("name");
        $("#" + id).show();
    });
}

function click_approval(){
    $(".approvals").click(function(){
       var approvals =  $(this).siblings(".approval_comments")
      approvals.toggle();
       var hidden =  approvals.find("#approval_type");
        hidden.val($(this).text());
        });
}


