var fnames = new Array(), ftypes = new Array(), err_style = '';
fnames[0] = 'EMAIL';
ftypes[0] = 'email';
fnames[1] = 'FNAME';
ftypes[1] = 'text';
fnames[2] = 'LNAME';
ftypes[2] = 'text';

$(function ($) {
  var mce_validator = $("#mc-embedded-subscribe-form").validate({
    errorClass:   'mce_inline_error',
    errorElement: 'div',
    errorStyle:   err_style,
    onkeyup:      function () {},
    onfocusout:   function () {},
    onblur:       function () {}
  });

  $('#mc-embedded-subscribe-form').ajaxForm({
    url: 'http://opennorth.us2.list-manage.com/subscribe/post-json?u=a602fac79ef3dc584bf1a2743&id=1258cb62e9&c=?',
    type: 'GET',
    dataType: 'json',
    contentType: "application/json; charset=utf-8",
    beforeSubmit: function () {
      $('#mce_tmp_error_msg').remove();
      $('.datefield','#mc_embed_signup').each(function () {
        var txt = 'filled';
        var fields = new Array();
        var i = 0;
        $(':text', this).each(function () {
          fields[i] = this;
          i++;
        });
        $(':hidden', this).each(function () {
          if (fields[0].value == 'MM' && fields[1].value == 'DD' && fields[2].value == 'YYYY') {
            this.value = '';
          }
          else if (fields[0].value == '' && fields[1].value == '' && fields[2].value == '') {
            this.value = '';
          }
          else {
            this.value = fields[0].value + '/' + fields[1].value + '/' + fields[2].value;
          }
        });
      });
      return mce_validator.form();
    }, 
    success: mce_success_cb
  });
});

function mce_success_cb(resp) {
  $('#mce-success-response').hide();
  $('#mce-error-response').hide();
  if (resp.result == "success") {
    $('#mce-' + resp.result + '-response').show();
    $('#mce-' + resp.result + '-response').html(resp.msg);
    $('#mc-embedded-subscribe-form').each(function () {
      this.reset();
    });
  }
  else {
    var index = -1;
    var msg;
    try {
      var parts = resp.msg.split(' - ', 2);
      if (parts[1] == undefined) {
        msg = resp.msg;
      }
      else {
        i = parseInt(parts[0]);
        if (i.toString() == parts[0]) {
          index = parts[0];
          msg = parts[1];
        }
        else {
          index = -1;
          msg = resp.msg;
        }
      }
    }
    catch (e) {
      index = -1;
      msg = resp.msg;
    }
    try {
      if (index == -1) {
        $('#mce-' + resp.result + '-response').show();
        $('#mce-' + resp.result + '-response').html(msg);            
      }
      else {
        err_id = 'mce_tmp_error_msg';
        html = '<div id="' + err_id + '" style="' + err_style + '"> ' + msg + '</div>';

        var input_id = '#mc_embed_signup';
        var f = $(input_id);
        if (ftypes[index] == 'address') {
          input_id = '#mce-' + fnames[index] + '-addr1';
          f = $(input_id).parent().parent().get(0);
        }
        else if (ftypes[index] == 'date') {
          input_id = '#mce-' + fnames[index] + '-month';
          f = $(input_id).parent().parent().get(0);
        }
        else {
          input_id = '#mce-' + fnames[index];
          f = $().parent(input_id).get(0);
        }
        if (f) {
          $(f).append(html);
          $(input_id).focus();
        }
        else {
          $('#mce-' + resp.result + '-response').show();
          $('#mce-' + resp.result + '-response').html(msg);
        }
      }
    }
    catch (e) {
      $('#mce-' + resp.result + '-response').show();
      $('#mce-' + resp.result + '-response').html(msg);
    }
  }
}
