data = []
waitFor = 0

google.load("visualization", "1",
	packages: ["corechart", "table"]
)

capitaliseFirstLetter = (string) ->
	string.charAt(0).toUpperCase() + string.slice(1)

$(document).ready ->

	google.setOnLoadCallback( =>
		myDataRef = new Firebase('https://chartms.firebaseio.com/accelotests')
		myDataRef.on 'child_added', (snapshot) =>
			newData = snapshot.val()
			data.push newData
			waitFor++
			setTimeout( =>
				waitFor--
				if waitFor <= 0
					redraw()
			, 1000)
	)

	redraw = ->
		# {Nokia3310: [..., ...], SamsungGalaxy: [..., ...], ...}
		distinctData = {}
		_.each data, (el) ->
			distinctData[el.phoneModel] = distinctData[el.phoneModel] or []
			distinctData[el.phoneModel].push el


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

		console.log resultsWhole, resultsProducent, resultsVersion

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
		chartDataRaw = [["Wersja", "Częstotliwość"]]
		_.each resultsVersion, (val, key) =>
			chartDataRaw.push [key, +val.freqAvg.toPrecision(4)]
		
		chartData = google.visualization.arrayToDataTable(chartDataRaw)
		chartOptions =
			legend: "none"
			hAxis:
				title: "Wersja"
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