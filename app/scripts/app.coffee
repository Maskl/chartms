window.firebaseBase = 'https://chartms.firebaseio.com'
window.firebaseTexts = 'https://chartms.firebaseio.com/example_texts'
window.firebaseData = 'https://chartms.firebaseio.com/example_data'

# Polish translation, you can use any other or leave english version.
# window.translations =
# 	"main": "Główna"
# 	"contact": "Kontakt"
# 	"admin-panel": "Panel admina"
# 	"logout": "Wyloguj"
# 	"close": "Zamknij"
# 	"login": "Zaloguj się"
# 	"remember-me": "Zapamiętaj mnie"
# 	"login-button": "Zaloguj"
# 	"back-to-main": "Wróć do strony głównej"
# 	"save": "Zapisz"
# 	"id-elements-info": "Możesz wstawić element, do którego będziesz mógł się odwołać z poziomu kodu Javascript:<br />[[id-elementu-blokowego]], {{id-elementu-inline}}"
# 	"title": "Tytuł"
# 	"header": "Nagłówek"
# 	"text": "Treść"
# 	"footer": "Stopka"
# 	"logoutSuccess": "Pomyślnie wylogowałeś się."
# 	"incorectLogin": "Podałeś niepoprawne dane logowania"
# 	"loggedInFooterLinksStart": "Zalogowany jako "
# 	"loggedInFooterLinksEnd": ", <a href='admin.html'>Panel administracyjny</a>, "
# 	"loggedOutFooterLinks": "<a href='login.html'>Panel administracyjny</a>"
# 	"saving": "Zapisywanie..."

window.appOnStart = () ->
	console.log "Initialize"

window.appOnDataLoaded = (data, snapshot) ->
	console.log "Loaded data", data

	# Some text
	$("#data-count").text(Object.keys(data).length)

	# And simple chart
	chartDataRaw = [["Cat type", "Age"]]
	for key, val of data
		chartDataRaw.push [key, val]

	chartData = google.visualization.arrayToDataTable(chartDataRaw)
	chartOptions =
		legend: "none"
		hAxis:
			title: "Cat type"
		vAxis:
			title: "Age [years]"

	chart = new google.visualization.ColumnChart(document.getElementById("example-column-chart"))
	chart.draw(chartData, chartOptions)