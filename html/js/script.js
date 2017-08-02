var baseurl = OC.generateUrl('/apps/ggrwinti')

$(document).ready(function () {
  $(".edit").on("change input", function(e) {
    try {
      $.ajax({
        url: baseurl+'/geschaefte/'+$(this).attr("data-id"),
        type: 'PUT',
        contentType: 'application/json',
        data: JSON.stringify({
          field: $(this).attr("data-field"),
          value: $(this).val()
        })
      }).done(function (response) {
        console.log("success:", response)
      }).fail(function (response, code) {
        console.log("failed:", response, code)
      })
    } catch (e) {
      console.log("exception:", e)
    }
  })

})
