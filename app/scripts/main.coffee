$(document).ready ->
	$("#dane-z-bazy").html("")

	myDataRef = new Firebase('https://chartms.firebaseio.com/accelotests')
	myDataRef.on('child_added', (snapshot) ->
		data = snapshot.val()
		added = "<b>" + data.phoneModel + "</b> (" + data.dpAvg + ")<br />"
		$("#dane-z-bazy").html($("#dane-z-bazy").html() + added)
 	)

 	