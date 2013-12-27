google.load("visualization", "1",
	packages: ["corechart", "table"]
)

showError = (message) ->
	$('#alert_placeholder').html('<div class="alert alert-danger"><a class="close" data-dismiss="alert">×</a><span>' + message + '</span></div>')

showWarning = (message) ->
	$('#alert_placeholder').html('<div class="alert alert-warning"><a class="close" data-dismiss="alert">×</a><span>' + message + '</span></div>')

showSuccess = (message) ->
	$('#alert_placeholder').html('<div class="alert alert-success"><a class="close" data-dismiss="alert">×</a><span>' + message + '</span></div>')

loadData = (path, callback) ->
	data = []
	waitFor = 0
	dataRef = new Firebase(path)
	dataRef.on 'child_added', (snapshot) =>
		data[snapshot.name()] = snapshot.val()
		waitFor++
		setTimeout( =>
			waitFor--
			if waitFor <= 0
				callback(data, snapshot, dataRef)
		, 100)

$(document).ready ->
	$(".logout").on "click", ->
		window.auth.logout()
		window.location = "index.html"
		showSuccess("Pomyślnie wylogowałeś się.")

	$(".sign-in-btn").on "click", ->
		email = $(".sign-in-email").val()
		password = $(".sign-in-password").val()
		remember = $(".sign-in-remember")[0].checked
		window.waitingForLogin = true
		window.auth.login('password', {
			email: email
			password: password
			rememberMe: remember
		})
		return false

	google.setOnLoadCallback =>
		startApp()


startApp = ->
	window.waitingForLogin = false

	dataRef = new Firebase('https://chartms.firebaseio.com')
	window.auth = new FirebaseSimpleLogin dataRef, (error, user) ->
		if error
			showError("Podałeś niepoprawne dane logowania")
			console.log "Login error!", error
		else if user
			$("#auth-footer-text").html("Zalogowany jako " + user.email + ", <a href='admin.html'>Panel administracyjny</a>, ")
			$(".logout, .admin").show()
			if window.waitingForLogin
				window.waitingForLogin = false
				window.location = "admin.html"
				success("Pomyślnie zalogowałeś się.")
		else
			console.log "user is logged out"
			$("#auth-footer-text").html("<a href='login.html'>Panel administracyjny</a>")
			$(".logout, .admin").hide()

	if window.location.pathname.indexOf("index.html") != -1
		startMainPage()

	if window.location.pathname.indexOf("admin.html") != -1
		startAdminPage()

startAdminPage = ->
	loadData 'https://chartms.firebaseio.com/texts', (data, snapshot, dataRef) ->
		redrawTextsAdmin(data, snapshot, dataRef)

redrawTextsAdmin = (data, snapshot, dataRef) ->
	for key, val of data
		$("#edit_text_" + key + " input[type=text]").val(val)
		$("#edit_text_" + key + " textarea").html(val)

	$(".edit-text-btn").on "click", (e) ->
		form = $(e.target).parent()
		key = form.attr("id").substr(10)
		val = form.find("input[type=text]").val()
		if !val
			val = tinyMCE.get("mce_" + key).getContent()

		$(e.target).text("Zapisywanie...")
		dataRef.child(key).set(val, =>
			$(e.target).text("Zapisz")
		)
		return false

	tinymce.init
		selector: "textarea",
		plugins: [
			"advlist autolink lists link image charmap print preview anchor"
			"searchreplace visualblocks code fullscreen"
			"insertdatetime media table contextmenu paste"
		]
		toolbar: "insertfile undo redo | styleselect | bold italic | alignleft aligncenter alignright alignjustify | bullist numlist outdent indent | link image"

startMainPage = ->
	loadData 'https://chartms.firebaseio.com/texts', (data, snapshot) ->
		redrawTexts(data, snapshot)
		loadData 'https://chartms.firebaseio.com/accelotests', (data, snapshot) ->
			window.redrawCharts(data, snapshot)

redrawTexts = (data, snapshot) ->
	for key, val of data
		val = val.replace(/{{(.*)}}/g, '<span id="$1"></span>')
		val = val.replace(/\[\[(.*)\]\]/g, '<div id="$1"></div>')
		$("#text_" + key).html(val)
