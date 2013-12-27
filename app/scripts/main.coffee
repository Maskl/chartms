google.load("visualization", "1",
	packages: ["corechart", "table"]
)

showError = (message) ->
	$('#alert_placeholder').html('<div class="alert alert-danger"><a class="close" data-dismiss="alert">×</a><span>' + message + '</span></div>')

showWarning = (message) ->
	$('#alert_placeholder').html('<div class="alert alert-warning"><a class="close" data-dismiss="alert">×</a><span>' + message + '</span></div>')

showSuccess = (message) ->
	$('#alert_placeholder').html('<div class="alert alert-success"><a class="close" data-dismiss="alert">×</a><span>' + message + '</span></div>')

capitaliseFirstLetter = (string) ->
	string.charAt(0).toUpperCase() + string.slice(1)

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
		, 1000)

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
			$(".logout").show()
			if window.waitingForLogin
				window.waitingForLogin = false
				window.location = "admin.html"
				success("Pomyślnie zalogowałeś się.")
		else
			console.log "user is logged out"
			$("#auth-footer-text").html("<a href='login.html'>Panel administracyjny</a>")
			$(".logout").hide()

	if window.location.pathname.indexOf("index.html") != -1
		startMainPage()

	if window.location.pathname.indexOf("admin.html") != -1
		startAdminPage()

startAdminPage = ->
	loadData 'https://chartms.firebaseio.com/texts', (data, snapshot, dataRef) ->
		redrawTextsAdmin(data, snapshot, dataRef)

redrawTextsAdmin = (data, snapshot, dataRef) ->
	for key, val of data
		$("#edit_text_" + key + " input").val(val)
		console.log "FF", key, val

	$("button").on "click", (e) ->
		form = $(e.target).parent()
		key = form.attr("id").substr(10)
		val = form.find("input[type=text]").val()
		console.log "XX", key, val
		dataRef.child(key).set(val)
		return false

startMainPage = ->
	loadData 'https://chartms.firebaseio.com/texts', (data, snapshot) ->
		redrawTexts(data, snapshot)
		loadData 'https://chartms.firebaseio.com/accelotests', (data, snapshot) ->
			redrawCharts(data, snapshot)

redrawTexts = (data, snapshot) ->
	for key, val of data
		$("#text_" + key).html(val)

redrawCharts = (data, snapshot) ->

	console.log "D", data, snapshot

	# {Nokia3310: [..., ...], SamsungGalaxy: [..., ...], ...}
	distinctData = {}
	for key, val of data
		distinctData[val.phoneModel] = distinctData[val.phoneModel] or []
		distinctData[val.phoneModel].push val


	# [{model: nokia3310, version: 2.3.6, dpAvg: ..., ...}, ...]
	preparedData = []
	_.each distinctData, (phone) ->
		phoneTestsCount = phone.length
		dpMin = Number.MAX_VALUE
		dpMax = Number.MIN_VALUE
		dpAvgSum = 0
		dpDevSum = 0
		dtMin = Number.MAX_VALUE
		dtMax = Number.MIN_VALUE
		dtAvgSum = 0
		dtDevSum = 0
		_.each phone, (test) =>
			dpMin = Math.min(+dpMin, test.dpMin)
			dpMax = Math.max(+dpMax, test.dpMax)
			dpAvgSum += +test.dpAvg
			dpDevSum += +test.dpDev
			dtMin = Math.min(+dtMin, test.dtMin)
			dtMax = Math.max(+dtMax, test.dtMax)
			dtAvgSum += +test.dtAvg
			dtDevSum += +test.dtDev

		dtAvg = (dtAvgSum / phoneTestsCount)
		dtDev = (dtDevSum / phoneTestsCount)


		phoneData = 
			model: phone[0].phoneModel
			producent: capitaliseFirstLetter(phone[0].phoneManufacturer)
			version: phone[0].phoneVersionRelease
			dpMin: dpMin
			dpMax: dpMax
			dpAvg: dpAvgSum / phoneTestsCount
			dpDev: dpDevSum / phoneTestsCount
			freqMin: 1000 / dtMax
			freqMax: 1000 / dtMin
			freqAvg: (1000 / (dtAvg - dtDev) + 1000 / (dtAvg + dtDev)) / 2
			freqDev: 1000 / (dtAvg - dtDev) - (1000 / (dtAvg - dtDev) + 1000 / (dtAvg + dtDev)) / 2

		preparedData.push phoneData

	
	getAggregates = (table) ->
		tableCount = table.length
		dpMinMin = Number.MAX_VALUE
		dpMinMax = Number.MIN_VALUE
		dpMax = Number.MIN_VALUE
		dpAvgSum = 0
		dpDevSum = 0
		freqMin = Number.MAX_VALUE
		freqMax = Number.MIN_VALUE
		freqAvgSum = 0
		freqDevSum = 0

		_.each table, (el) =>
			dpMinMin = Math.min(dpMinMin, el.dpMin)
			dpMinMax = Math.max(dpMinMax, el.dpMin)
			dpMax = Math.max(dpMax, el.dpMax)
			dpAvgSum += el.dpAvg
			dpDevSum += el.dpDev
			freqMin = Math.min(freqMin, el.freqMin)
			freqMax = Math.max(freqMax, el.freqMax)
			freqAvgSum += el.freqAvg
			freqDevSum += el.freqDev

		return {
			dpMin: dpMinMin
			dpMax: dpMax
			dpMinMin: dpMinMin
			dpMinMax: dpMinMax
			dpAvg: dpAvgSum / tableCount
			dpDev: dpDevSum / tableCount
			freqMin: freqMin
			freqMax: freqMax
			freqAvg: freqAvgSum / tableCount
			freqDev: freqDevSum / tableCount
		}

	producentData = {}
	versionData = {}
	_.each preparedData, (phone) ->
		producentData[phone.producent] = producentData[phone.producent] or []
		producentData[phone.producent].push phone
		versionData[phone.version] = versionData[phone.version] or []			
		versionData[phone.version].push phone

	resultsWhole = getAggregates(preparedData)

	resultsProducent = {}
	_.each producentData, (dataTable, key) ->
		resultsProducent[key] = getAggregates(dataTable)

	resultsVersion = {}
	_.each versionData, (dataTable, key) ->
		resultsVersion[key] = getAggregates(dataTable)

	$("#tests-count").html(data.length)
	$("#tests-count-distinct").html(Object.keys(distinctData).length)

	$("#total-frequency").html(resultsWhole.freqAvg.toPrecision(2) + "±" + resultsWhole.freqDev.toPrecision(2) + 
		"Hz (wartości z przedziału " + resultsWhole.freqMin.toPrecision(2) + " - " + resultsWhole.freqMax.toPrecision(2) + "Hz)")

	$("#total-accuracy").html(resultsWhole.dpMinMin.toPrecision(2) + " - " + resultsWhole.dpMinMax.toPrecision(2) + "m/s<sup>2</sup>")

	# Producent-frequency chart
	chartDataRaw = [["Producent", "Częstotliwość"]]
	_.each resultsProducent, (val, key) =>
		chartDataRaw.push [key, +val.freqAvg.toPrecision(4)]
	
	chartData = google.visualization.arrayToDataTable(chartDataRaw)
	chartOptions =
		legend: "none"
		hAxis:
			title: "Producent"
		vAxis:
			title: "Częstotliwość [Hz]"

	chart = new google.visualization.ColumnChart(document.getElementById("chart-producent-frequency"))
	chart.draw(chartData, chartOptions)

	# Producent-frequency table
	chartDataRaw = [["Producent", "Średnia częstotliwość [Hz]", "Zakres częstotliowości [Hz]"]]
	_.each resultsProducent, (val, key) =>
		chartDataRaw.push [key, +val.freqAvg.toPrecision(2) + "±" + +val.freqDev.toPrecision(2), +val.freqMin.toPrecision(2) + " - " + +val.freqMax.toPrecision(2)]
	
	chartData = google.visualization.arrayToDataTable(chartDataRaw)

	chart = new google.visualization.Table(document.getElementById("table-producent-frequency"))
	chart.draw(chartData)

	# Producent-accuracy chart
	chartDataRaw = [["Producent", "Zmiana przyspieszenia"]]
	_.each resultsProducent, (val, key) =>
		chartDataRaw.push [key, +val.dpMin.toPrecision(4)]
	
	chartData = google.visualization.arrayToDataTable(chartDataRaw)
	chartOptions =
		legend: "none"
		hAxis:
			title: "Producent"
		vAxis:
			title: "Zmiana przyspieszenia [m/s2]"

	chart = new google.visualization.ColumnChart(document.getElementById("chart-producent-accuracy"))
	chart.draw(chartData, chartOptions)

	# Producent-accuracy table
	chartDataRaw = [["Producent", "Średnia zmiana przyspieszenia [m/s2]", "Zakres zmian przyspieszenia [m/s2]"]]
	_.each resultsProducent, (val, key) =>
		chartDataRaw.push [key, +val.dpAvg.toPrecision(2) + "±" + +val.dpDev.toPrecision(2), +val.dpMin.toPrecision(2) + " - " + +val.dpMax.toPrecision(2)]
	
	chartData = google.visualization.arrayToDataTable(chartDataRaw)

	chart = new google.visualization.Table(document.getElementById("table-producent-accuracy"))
	chart.draw(chartData)

	# Version-frequency chart
	chartDataRaw = [["Wersja Androida", "Częstotliwość"]]
	_.each resultsVersion, (val, key) =>
		chartDataRaw.push [key, +val.freqAvg.toPrecision(4)]
	
	chartData = google.visualization.arrayToDataTable(chartDataRaw)
	chartOptions =
		legend: "none"
		hAxis:
			title: "Wersja Androida"
		vAxis:
			title: "Częstotliwość [Hz]"

	chart = new google.visualization.ColumnChart(document.getElementById("chart-version-frequency"))
	chart.draw(chartData, chartOptions)

	# Version-frequency table
	chartDataRaw = [["Wersja Androida", "Średnia częstotliwość [Hz]", "Zakres częstotliowości [Hz]"]]
	_.each resultsVersion, (val, key) =>
		chartDataRaw.push [key, +val.freqAvg.toPrecision(2) + "±" + +val.freqDev.toPrecision(2), +val.freqMin.toPrecision(2) + " - " + +val.freqMax.toPrecision(2)]
	
	chartData = google.visualization.arrayToDataTable(chartDataRaw)

	chart = new google.visualization.Table(document.getElementById("table-version-frequency"))
	chart.draw(chartData)

	# Version-accuracy chart
	chartDataRaw = [["Wersja Androida", "Zmiana przyspieszenia"]]
	_.each resultsVersion, (val, key) =>
		chartDataRaw.push [key, +val.dpMin.toPrecision(4)]
	
	chartData = google.visualization.arrayToDataTable(chartDataRaw)
	chartOptions =
		legend: "none"
		hAxis:
			title: "Wersja Androida"
		vAxis:
			title: "Zmiana przyspieszenia [m/s2]"

	chart = new google.visualization.ColumnChart(document.getElementById("chart-version-accuracy"))
	chart.draw(chartData, chartOptions)

	# Version-accuracy table
	chartDataRaw = [["Wersja Androida", "Średnia zmiana przyspieszenia [m/s2]", "Zakres zmian przyspieszenia [m/s2]"]]
	_.each resultsVersion, (val, key) =>
		chartDataRaw.push [key, +val.dpAvg.toPrecision(2) + "±" + +val.dpDev.toPrecision(2), +val.dpMin.toPrecision(2) + " - " + +val.dpMax.toPrecision(2)]
	
	chartData = google.visualization.arrayToDataTable(chartDataRaw)

	chart = new google.visualization.Table(document.getElementById("table-version-accuracy"))
	chart.draw(chartData)