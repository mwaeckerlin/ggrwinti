var baseurl = OC.generateUrl('/apps/ggrwinti')
var timer = {}

function exportTableToCSV($table, filename) {

  var $rows = $table.find('tr:has(td),>div'),

      // Temporary delimiter characters unlikely to be typed by keyboard
      // This is to avoid accidentally splitting the actual contents
      tmpColDelim = String.fromCharCode(11), // vertical tab character
      tmpRowDelim = String.fromCharCode(0), // null character
      
      // actual delimiter characters for CSV format
      colDelim = '";"',
      rowDelim = '"\r\n"',
      
      // Grab text from table into CSV formatted string
      csv = '"' + $rows.map(function (i, row) {
        var $row = $(row),
            $cols = $row.find('td,>div,>a>div');
        
        return $cols.map(function (j, col) {
          var $col = $(col).find('input,textarea')
          if ($col.size()!=1) $col=$(col);
          var text = $col.text()
          if (!text) text=$col.val();

          return text.replace(/"/g, '""'); // escape double quotes
          
        }).get().join(tmpColDelim);
        
      }).get().join(tmpRowDelim)
                       .split(tmpRowDelim).join(rowDelim)
                       .split(tmpColDelim).join(colDelim) + '"';
  
  // Deliberate 'false', see comment below
  if (false && window.navigator.msSaveBlob) {

    var blob = new Blob([decodeURIComponent(csv)], {
      type: 'text/csv;charset=utf8'
    });
    
    // Crashes in IE 10, IE 11 and Microsoft Edge
    // See MS Edge Issue #10396033: https://goo.gl/AEiSjJ
    // Hence, the deliberate 'false'
    // This is here just for completeness
    // Remove the 'false' at your own risk
    window.navigator.msSaveBlob(blob, filename);
    
  } else if (window.Blob && window.URL) {
    // HTML5 Blob        
    var blob = new Blob([csv], { type: 'text/csv;charset=utf8' });
    var csvUrl = URL.createObjectURL(blob);

    $(this)
      .attr({
        'download': filename,
        'href': csvUrl
      });
  } else {
    // Data URI
    var csvData = 'data:application/csv;charset=utf-8,' + encodeURIComponent(csv);

    $(this)
      .attr({
        'download': filename,
        'href': csvData,
        'target': '_blank'
      });
  }
}

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

  // save after edit
  $(".edit").on("input", function(e) {
    var obj = $(this)
    clearTimeout(timer[obj.attr("data-field")+obj.attr("data-id")])
    timer[obj.attr("data-field")+obj.attr("data-id")] = setTimeout(function() {changed(obj)}, 2000)
  }).on("change", function(e) {
    var obj = $(this)
    clearTimeout(timer[obj.attr("data-field")+obj.attr("data-id")])
    changed(obj)
  })

  // filter rows
  $('.filter input').on('input', function(e) {
    var all = $(this).parent().parent().parent().children('.geschaeft')
                     .find('[data-field="'+$(this).attr('data-field')+'"]')
    var matches = all.filter(':contains("'+$(this).val()+'"), *:contains("'+$(this).val()+'"), [value*="'+$(this).val()+'"]')
    var nonmatches = all.not(':contains("'+$(this).val()+'"), *:contains("'+$(this).val()+'"), [value*="'+$(this).val()+'"]')
    nonmatches.closest('div').parent().closest('div').hide()
    matches.closest('div').parent().closest('div').show()
  })

  // save table
  $(".table-export").on('click', function (event) {
    console.log('export table', $(this))
    // CSV
    var args = [$($(this).attr('data-table')), $(this).attr('download')];
    exportTableToCSV.apply(this, args);
    //event.preventDefault()
    //return false
    // If CSV, don't do event.preventDefault() or return false
    // We actually need this to be a typical hyperlink
  });
  
})
