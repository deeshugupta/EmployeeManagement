/**
 * Created by tt on 28/8/15.
 */


function toggle(target){
    var toggleElement = document.getElementById(target)
    if(toggleElement.style.display == 'none'){
        toggleElement.style.display = 'block'
    }
    else{
        toggleElement.style.display = 'none'
    }
    return false

}
function attach_Click_event() {
    $(".tab_button").click(function () {
        console.log("abcd");
        $(".content_section").hide();
        var id = $(this).attr("name");
        $("#" + id).show();
        console.log("clicked");
    });
}
