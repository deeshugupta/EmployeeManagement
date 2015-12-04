function formatRepo(repo) {
  return repo.email || repo.text
}

function formatRepoSelection (repo, k) {
  return repo.email || repo.text
}

$(document).on("submit", "#new-leave-form", function(e){
  // e.preventDefault();
  console.log($("#attendance_emails_to_notify").select2("val"))
});

$(document).on("ready", function(){
  if($("#search_form").length != 0){
    $("#name").autocomplete({
      source: "/search/search_name",
      minLength: 2,
      select: function( event, ui ) {
        this.value = ui.item ? ui.item.value : this.value;
        $(this).data("user_id", ui.item.id);
        console.log($(this).data("user_id"));
        // log( ui.item ?
        //   "Selected: " + ui.item.value + " aka " + ui.item.id :
        //   "Nothing selected, input was " + this.value );
      }
    });

    $("#search_form").on('ajax:beforeSend', function(e, xhr, settings){
      console.log("i m here")
      if($("#name").val() != "" && $("#name").data("user_id") != undefined){
        settings.data += "&user_id=" + $("#name").data("user_id");
        console.log(settings);
      }

    })
  }


  $("#attendance_emails_to_notify").select2({
    ajax: {
      url: "/search/search_emails.json",
      dataType: "json",
      delay: 250,
      data: function (params) {
        return {
          skey: params.term
        };
      },
      processResults: function (data, params) {
        items = JSON.parse(data.items)
        $.each(items, function(i){
          items[i].id = this.email
        });
        console.log(items)
        return {
          results: items
        };
      },
      cache: true
    },
    escapeMarkup: function (markup) { return markup; },
    minimumInputLength: 3,
    templateResult: formatRepo,
    templateSelection: formatRepoSelection
  });
  // $(".select2-selection__choice").each(function(){
  //   $(this).append($(this).attr("title"));
  // });
  $(".select2-selection__choice__remove").on("click", function(){

  });
});

$(document).on("change", "#start_start_date_1i, #start_start_date_2i, #start_start_date_3i, #end_end_date_1i, #end_end_date_2i, #end_end_date_3i", function(e){
  if(!check_date_range("start_start_date", "end_end_date")){
    if($(e.target).attr("id").indexOf("start_start_date") != -1){
      $("#start_start_date_1i option[value='" + $("#end_end_date_1i").val() + "']").prop("selected", true);
      $("#start_start_date_2i option[value='" + $("#end_end_date_2i").val() + "']").prop("selected", true);
      $("#start_start_date_3i option[value='" + $("#end_end_date_3i").val() + "']").prop("selected", true);
    }
    else{
      $("#end_end_date_1i option[value='" + $("#start_start_date_1i").val() + "']").prop("selected", true);
      $("#end_end_date_2i option[value='" + $("#start_start_date_2i").val() + "']").prop("selected", true);
      $("#end_end_date_3i option[value='" + $("#start_start_date_3i").val() + "']").prop("selected", true);
    }

  }
});


function check_date_range(base_start_name, base_end_name){
  start_year = $("#" + base_start_name + "_1i").val()
  start_month = $("#" + base_start_name + "_2i").val()
  start_day = $("#" + base_start_name + "_3i").val()
  end_year = $("#" + base_end_name + "_1i").val()
  end_month = $("#" + base_end_name + "_2i").val()
  end_day = $("#" + base_end_name + "_3i").val()
  start_date = Date.parse(start_year + "-" + start_month + "-" + start_day)
  end_date = Date.parse(end_year + "-" + end_month + "-" + end_day)
  return ((end_date - start_date) >= 0)
}