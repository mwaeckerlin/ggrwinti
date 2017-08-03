var baseurl = OC.generateUrl('/apps/ggrwinti')
 var timer = {}
function changed(obj) {
  try {
    $.ajax({
      url: baseurl+'/geschaefte/'+obj.attr("data-id"),
      type: 'PUT',
      contentType: 'application/json',
      data: JSON.stringify({
        field: obj.attr("data-field"),
        value: obj.val()
      })
    }).done(function (response) {
      obj.parent().parent()
         .css('background-color', 'inherit').css('border-color', 'inherit')
         .effect('highlight', {color: '#7F7'}, 1000)
      console.log("success", response)
    }).fail(function (response, code) {
      obj.parent().parent()
         .css('background-color', '#F77').css('border-color', 'red')
      console.log("failed:", response, code)
    })
  } catch (e) {
    console.log("exception:", e)
  }
}
$(document).ready(function () {
  $(".edit").on("input", function(e) {
    var obj = $(this)
    clearTimeout(timer[obj.attr("data-field")+obj.attr("data-id")])
    timer[obj.attr("data-field")+obj.attr("data-id")] = setTimeout(function() {changed(obj)}, 2000)
  }).on("change", function(e) {
    var obj = $(this)
    clearTimeout(timer[obj.attr("data-field")+obj.attr("data-id")])
    changed(obj)
  })
  $('.filter input').on('input', function(e) {
    all = $(this).parent().parent().parent().children('.geschaeft')
                     .find('[data-field="'+$(this).attr('data-field')+'"]')
    matches = all.filter(':contains("'+$(this).val()+'"),[value*="'+$(this).val()+'"]')
    nonmatches = all.not(':contains("'+$(this).val()+'"),[value*="'+$(this).val()+'"]')
    nonmatches.closest('div').parent().hide()
    matches.closest('div').parent().show()
    console.log(matches)
  })  
})
