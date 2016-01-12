function formatRepo(repo) {
  return repo.email || repo.text
}

function formatRepoSelection (repo, k) {
  return repo.email || repo.text
}

$(document).on("submit", "#new-leave-form, .new_attendance, .edit_attendance", function(e){
  e.preventDefault();
  if(($("#attendance_emails_to_notify").val() == null) || ($("#attendance_emails_to_notify").val() == undefined)){
    if(confirm('Do you want to proceed without adding any recepients for your leave approval email')){
      $(this)[0].submit();
    }
  }
  else{
    $(this)[0].submit();
  }
  // e.preventDefault();
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
      }
    });

    $("#manager_name").autocomplete({
      source: "/search/search_manager_name",
      minLength: 2,
      select: function( event, ui ) {
        this.value = ui.item ? ui.item.value : this.value;
        $(this).data("manager_user_id", ui.item.id);
      }
    });

    $("#manager_name").on("change", function(){
      $("#name").val("").data("user_id",undefined);
    });

    $("#name").on("change", function(){
      $("#manager_name").val("").data("manager_user_id",undefined);
    });

    $("#search_form").on('ajax:beforeSend', function(e, xhr, settings){
      if($("#name").val() != "" && $("#name").data("user_id") != undefined){
        settings.data += "&user_id=" + $("#name").data("user_id");
        console.log(settings);
      }

      if($("#manager_name").val() != "" && $("#manager_name").data("manager_user_id") != undefined){
        settings.data += "&manager_user_id=" + $("#manager_name").data("manager_user_id");
        console.log(settings);
      }

    });

    if($("#start_start_date_1i").length != 0){
      for(i=1;i<=3;i++){
        $("#start_start_date_" + i + "i option[value='']").prop("selected", true);
      }
    }

    if($("#end_end_date_1i").length != 0){
      for(i=1;i<=3;i++){
        $("#end_end_date_" + i + "i option[value='']").prop("selected", true);
      }
    }

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

  if($('#notification_recipient_modal').length == 1){
    $('#notification_recipient_modal').foundation({
      reveal: {
        close_on_background_click: false
      }
    });
  }
});


// for pagination while searching for attendances, used on url: /attendances/search_pending_approvals
$(document).on("click", "#search_results .pagination li a", function(e){
  e.preventDefault();
  var $this = $(this);
  var $form = $("#search_form");
  $.ajax({
    url: $this.attr("href"),
    type: "post",
    data: $form.serialize()
  })
})



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

  // if user hasn't selected start date, then return true
  if(start_year == "" && start_month == "" && start_day == ""){
    return true
  }

  // if user hasn't selected end date, then return true
  if(end_year == "" && end_month == "" && end_day == ""){
    return true
  }
  start_date = Date.parse(start_year + "-" + pad(start_month, 2) + "-" + pad(start_day, 2))
  end_date = Date.parse(end_year + "-" + pad(end_month, 2) + "-" + pad(end_day, 2))
  return ((end_date - start_date) >= 0)
}

$(document).on("click", ".reset_start_date", function(){
  $("#start_start_date_1i option[value='']").prop("selected", true)
  $("#start_start_date_2i option[value='']").prop("selected", true)
  $("#start_start_date_3i option[value='']").prop("selected", true)
});

$(document).on("click", ".reset_end_date", function(){
  $("#end_end_date_1i option[value='']").prop("selected", true)
  $("#end_end_date_2i option[value='']").prop("selected", true)
  $("#end_end_date_3i option[value='']").prop("selected", true)
});

$(document).on("click", "input[name='commit']", function(e){
  $(this).closest("form").data("btn", $(this).data("btn"));
})

$(document).on("submit", ".approval_comments", function(e){
  var $form = $(this);
  var btn_action = $form.data("btn");
  e.preventDefault();
  $("input[name='commit_action']").val(btn_action);
  if((btn_action == "approve") && ($form.data("needtoaddnotifiers") == true)){
    $("#attendance_emails_to_notify").data("approval_id", $form.data("approvalid"));
    $('#notification_recipient_modal').foundation('reveal', 'open')
  }
  else{
    $form[0].submit();
  }
});

$(document).on("click", "#modal-approve-leave", function(){
  approval_id = $("#attendance_emails_to_notify").data("approval_id");
  $("#emails_to_notify").remove();
  $("#attendance_emails_to_notify").clone().attr("id", "emails_to_notify").attr("name", "emails_to_notify[]").css('display', 'none').appendTo("form[data-approvalid='" + approval_id + "']");
  $("#emails_to_notify").find("option").prop("selected", true);
  $('#notification_recipient_modal').foundation('reveal', 'close');
  $(".approval_comments")[0].submit();
});

$(document).on("change", "#attendance_emails_to_notify", function(){
  if($(this).val() != null){
    $("#modal-approve-leave").html("Approve");
  }
  else{
    $("#modal-approve-leave").html("Approve without adding Recipients");
  }
});

function reset_emails_to_notify_form(){
  $("#attendance_emails_to_notify option").remove();
  $(".approval_comments").data("approval_id",null);
}

