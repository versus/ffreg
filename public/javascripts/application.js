function spin() {
/*  $('overlay').show();*/
}

function reset_client_form() {
  $('client_select').value = ''; 
  $('client_popup').hide();
  $('client_form').show();
  $('client_name').value = '';
  $('client_email').value = '';
  $('client_address').value = '';
  $('client_phone').value = '';
  $('project_hidden_client_id').value = '';
}

function add_option(select_element, option_name, option_value) {
  optn = document.createElement("OPTION"); 
  optn.text = option_name;
  optn.value = option_value; 
  $(select_element).options[$(select_element).length] = optn;
}


function reset_select(select_element) {
  $(select_element).options.length = 0;
}


function started_loading_people() {
  $('basecamp_project_spinner').show();
  $('project_source_id').disabled = true; 
  $('project_basecamp_project_id').disabled = true; 
  $('project_basecamp_person_id').disabled = true; 
  $('save_button').disabled = true; 
}

function completed_loading_people() {
  $('basecamp_project_spinner').hide();
  $('project_source_id').disabled = false; 
  $('project_basecamp_project_id').disabled = false; 
  $('project_basecamp_person_id').disabled = false; 
  $('save_button').disabled = false;
}

function highlightLogin() {
  if ($('standard_login').style.display == 'none') 
    $('openid_url').activate();
  else
  {
    $('login').activate();
  }
}

function edit_time_entry(path, first_field) {
    new Ajax.Request(path + "?rand=" + calcRand(), {asynchronous:false, evalScripts:true, method:'get'});
    $(first_field).activate();
}

function set_class_name(element, class_name) {
  new Element.ClassNames(element).set(class_name);
}

function confirm_passwords() {
    if ($('user_password').value != "" && $('user_password_confirmation').value != "")
    {
        if ($('user_password').value == $('user_password_confirmation').value)
        {
            set_class_name('password_status', 'valid status');
            $('password_status').innerHTML = "Passwords look good.";
        }
        else
        {
            set_class_name('password_status', 'invalid status');
            $('password_status').innerHTML = "Passwords do not match.";
        }
        $('password_status').show();
    }
}

function hide_if_exists(domid) {
    if ($(domid)) {
        $(domid).hide();
    }
}

function show_if_exists(domid) {
    if ($(domid)) {
        $(domid).show();
    }
}

function disable_if_exists(domid) {
  if ($(domid)) {
    $(domid).disable();
  }
}

function load_projects() {
  new Ajax.Request('/sources/000/basecamp_accounts?rand=' + calcRand(), {
    asynchronous:true, 
    evalScripts:true, 
    method:'get', 
    onComplete:function(request){$('bc_spinner').hide();},
    onLoading:function(request){$('bc_spinner').show();}, 
    parameters:Form.Element.serialize('project_source_id')});
}

function handle_source_error(url) {
  document.location = url
}

var orig_project_form_url = "";
function reset_project_form_url() {
  document.getElementById('project_form').action = orig_project_form_url;
}

function manual_entry_selected(url) {
  new Ajax.Request(url + "?rand=" + calcRand(), {
    asynchronous:true, 
    evalScripts:true, 
    method:'get', 
    onLoading:function(request){$('manual_source_radio_spinner').show()} 
  }); 
  return false;
}

function basecamp_account_selected(url) {
  new Ajax.Request(url + "?rand=" + calcRand(), {
    asynchronous:true, 
    evalScripts:true, 
    method:'get', 
    onLoading:function(request){$('basecamp_account_spinner').show()}
  }); 
  return false;
}

function submit_new_basecamp_account() {
  new Ajax.Request('/sources', {
    asynchronous:true, 
    evalScripts:true, 
    method:'post', 
    parameters:Form.Element.serialize('source_username') + '&' + Form.Element.serialize('source_password') + '&' + Form.Element.serialize('source_url') + '&' + Form.Element.serialize('source_basecamp_domain_id'),
    onLoading:function(request){$('new_basecamp_source_spinner').show()},
    onComplete:function(request){$('new_basecamp_source_spinner').hide()}}
  );
}

function calcRand() {
  var retVal = Math.floor(Math.random() * 1001);
  return retVal;
}

