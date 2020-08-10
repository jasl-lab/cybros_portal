function user_sign_in(event, settings) {
  const xhr = event.detail[0];
  xhr.setRequestHeader('JWT-AUD', 'cybros');
}

document.addEventListener("turbolinks:load", function() {
  document.getElementById("user-sign-in").addEventListener("ajax:beforeSend", user_sign_in);
});

