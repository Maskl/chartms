window.firebaseBase = 'https://chartms.firebaseio.com'
window.firebaseTexts = 'https://chartms.firebaseio.com/texts'
window.firebaseData = 'https://chartms.firebaseio.com/autotests'

window.translations =
	"main": "Główna"
	"contact": "Kontakt"
	"admin-panel": "Panel admina"
	"logout": "Wyloguj"
	"close": "Zamknij"
	"login": "Zaloguj się"
	"remember-me": "Zapamiętaj mnie"
	"login-button": "Zaloguj"
	"back-to-main": "Wróć do strony głównej"
	"save": "Zapisz"
	"id-elements-info": "Możesz wstawić element, do którego będziesz mógł się odwołać z poziomu kodu Javascript:<br />[[id-elementu-blokowego]], {{id-elementu-inline}}"
	"title": "Tytuł"
	"header": "Nagłówek"
	"text": "Treść"
	"footer": "Stopka"
	"logoutSuccess": "Pomyślnie wylogowałeś się."
	"incorectLogin": "Podałeś niepoprawne dane logowania"
	"loggedInFooterLinksStart": "Zalogowany jako "
	"loggedInFooterLinksEnd": ", <a href='admin.html'>Panel administracyjny</a>, "
	"loggedOutFooterLinks": "<a href='login.html'>Panel administracyjny</a>"
	"saving": "Zapisywanie..."

capitaliseFirstLetter = (string) ->
	string.charAt(0).toUpperCase() + string.slice(1)

window.appOnStart = () ->

window.appOnDataLoaded = (data, snapshot) ->

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
			phoneTestsCount: phoneTestsCount

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

	$("#tests-count").html(Object.keys(data).length)
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

	# Whole data table
	highlightRow = -1
	urlParamsStr = ""
	if document.URL.indexOf('?') >= 0
		urlParamsStr = document.URL.substring(document.URL.indexOf('?') + 1)

	chartDataRaw = [["model", "producent", "ver", "tests", "f_avg", "f_int", "da_avg", "da_int"]]
	_.each preparedData, (phone, it) =>
		if urlParamsStr == "phone=#{phone.model}"
			highlightRow = it
		chartDataRaw.push [
			phone.model
			phone.producent
			phone.version
			+phone.phoneTestsCount
			+phone.freqAvg.toPrecision(2) + "±" + +phone.freqDev.toPrecision(2)
			+phone.freqMin.toPrecision(2) + " - " + +phone.freqMax.toPrecision(2)
			+phone.dpAvg.toPrecision(2) + "±" + +phone.dpDev.toPrecision(2)
			+phone.dpMin.toPrecision(2) + " - " + +phone.dpMax.toPrecision(2)
		]
		
	chartData = google.visualization.arrayToDataTable(chartDataRaw)

	chart = new google.visualization.Table(document.getElementById("table-whole-data"))
	chart.draw(chartData)

	if highlightRow >= 0
		chart.setSelection([{row: highlightRow, column: null}])

	# AUTOTEST!!!
	$("body").append("<div id='xxx-table'></div>")
	$("body").append("<div id='xxx-chart-t'></div>")
	$("body").append("<div id='xxx-chart-x'></div>")
	$("body").append("<div id='xxx-chart-y'></div>")
	$("body").append("<div id='xxx-chart-z'></div>")
	$("body").append("<div id='xxx-chart-rx'></div>")
	$("body").append("<div id='xxx-chart-ry'></div>")
	$("body").append("<div id='xxx-chart-rz'></div>")

	highlightRow = -1
	urlParamsStr = ""
	if document.URL.indexOf('?') >= 0
		urlParamsStr = document.URL.substring(document.URL.indexOf('?') + 1)

	chartDataRaw = [["model", "producent", "ver", "date", "dpMin", "dpMax", "dpAvg", "dpDev", "dtMin", "dtMax", "dtAvg", "dtDev"]]
	
	dataToCharts = []
	for key, val of data
		dataToCharts.push val
		chartDataRaw.push [
			val.phoneModel
			val.phoneManufacturer
			val.phoneVersionRelease
			val.date
			(+val.dpMin).toPrecision(2)
			(+val.dpMax).toPrecision(2)
			(+val.dpAvg).toPrecision(2)
			(+val.dpDev).toPrecision(2)
			(+val.dtMin).toPrecision(2)
			(+val.dtMax).toPrecision(2)
			(+val.dtAvg).toPrecision(2)
			(+val.dtDev).toPrecision(2)
		]
		
	chartData = google.visualization.arrayToDataTable(chartDataRaw)

	chart = new google.visualization.Table(document.getElementById("xxx-table"))
	chart.draw(chartData)

	google.visualization.events.addListener chart, 'select', (e) ->
		data = dataToCharts[chart.getSelection()[0].row]

		chartDataRawX = [["t", "x"]]
		chartDataRawY = [["t", "y"]]
		chartDataRawZ = [["t", "z"]]
		chartDataRawXX = [["t", "x"]]
		chartDataRawYY = [["t", "y"]]
		chartDataRawZZ = [["t", "z"]]

		startT = +data.autotest_t[0]
		lastT = -1
		for i in [0..data.autotest_t.length]
			if lastT == +data.autotest_t[i]
				continue
			lastT = +data.autotest_t[i]
			chartDataRawX.push [(lastT - startT) / 1000000000, +data.autotest_x[i]]
			chartDataRawY.push [(lastT - startT) / 1000000000, +data.autotest_y[i]]
			chartDataRawZ.push [(lastT - startT) / 1000000000, +data.autotest_z[i]]
			chartDataRawXX.push [(lastT - startT) / 1000000000, +data.autotest_raw_x[i]]
			chartDataRawYY.push [(lastT - startT) / 1000000000, +data.autotest_raw_y[i]]
			chartDataRawZZ.push [(lastT - startT) / 1000000000, +data.autotest_raw_z[i]]

		chartDataX = google.visualization.arrayToDataTable(chartDataRawX)
		chartDataY = google.visualization.arrayToDataTable(chartDataRawY)
		chartDataZ = google.visualization.arrayToDataTable(chartDataRawZ)
		chartDataXX = google.visualization.arrayToDataTable(chartDataRawXX)
		chartDataYY = google.visualization.arrayToDataTable(chartDataRawYY)
		chartDataZZ = google.visualization.arrayToDataTable(chartDataRawZZ)

		chartX = new google.visualization.LineChart(document.getElementById("xxx-chart-x"))
		chartY = new google.visualization.LineChart(document.getElementById("xxx-chart-y"))
		chartZ = new google.visualization.LineChart(document.getElementById("xxx-chart-z"))
		chartXX = new google.visualization.LineChart(document.getElementById("xxx-chart-rx"))
		chartYY = new google.visualization.LineChart(document.getElementById("xxx-chart-ry"))
		chartZZ = new google.visualization.LineChart(document.getElementById("xxx-chart-rz"))

		chartOptions =
			legend: "none"
			title: ""
			hAxis:
				title: "t [s]"
			vAxis:
				title: "a [m/s2]"

		chartOptions.title = "Przyspieszenie: oś X"
		chartX.draw(chartDataX, chartOptions)
		chartOptions.title = "Przyspieszenie: oś Y"
		chartY.draw(chartDataY, chartOptions)
		chartOptions.title = "Przyspieszenie: oś Z"
		chartZ.draw(chartDataZ, chartOptions)
		chartOptions.title = "Przyspieszenie bez grawitacji: oś X"
		chartXX.draw(chartDataXX, chartOptions)
		chartOptions.title = "Przyspieszenie bez grawitacji: oś Y"
		chartYY.draw(chartDataYY, chartOptions)
		chartOptions.title = "Przyspieszenie bez grawitacji: oś Z"
		chartZZ.draw(chartDataZZ, chartOptions)