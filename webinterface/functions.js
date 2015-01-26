$('form').submit(function(){

	$('form button').removeClass('error');

	$.ajax({
		url: document.location.href,
		type: 'POST',
		data: $('form').serialize(),
		success: function (response) {

			$('form input[name="message"]').val('');
			$('form input[name="message"]').focus();

			$('form button').text('Message sent!');
		},
		error: function (e) {
			$('form button').text('Please try again');
			$('form button').addClass('error');
		}
	});

	return false;
});