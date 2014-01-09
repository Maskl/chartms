(function(){var a;window.firebaseBase="https://chartms.firebaseio.com",window.firebaseTexts="https://chartms.firebaseio.com/texts",window.firebaseData="https://chartms.firebaseio.com/autotests",window.translations={main:"Główna",contact:"Kontakt","admin-panel":"Panel admina",logout:"Wyloguj",close:"Zamknij",login:"Zaloguj się","remember-me":"Zapamiętaj mnie","login-button":"Zaloguj","back-to-main":"Wróć do strony głównej",save:"Zapisz","id-elements-info":"Możesz wstawić element, do którego będziesz mógł się odwołać z poziomu kodu Javascript:<br />[[id-elementu-blokowego]], {{id-elementu-inline}}",title:"Tytuł",header:"Nagłówek",text:"Treść",footer:"Stopka",logoutSuccess:"Pomyślnie wylogowałeś się.",incorectLogin:"Podałeś niepoprawne dane logowania",loggedInFooterLinksStart:"Zalogowany jako ",loggedInFooterLinksEnd:", <a href='admin.html'>Panel administracyjny</a>, ",loggedOutFooterLinks:"<a href='login.html'>Panel administracyjny</a>",saving:"Zapisywanie..."},a=function(a){return a.charAt(0).toUpperCase()+a.slice(1)},window.appOnStart=function(){},window.appOnDataLoaded=function(b){var c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s;h={};for(k in b)r=b[k],h[r.phoneModel]=h[r.phoneModel]||[],h[r.phoneModel].push(r);l=[],_.each(h,function(b){var c,d,e,f,g,h,i,j,k,m,n,o;return o=b.length,f=Number.MAX_VALUE,e=Number.MIN_VALUE,c=0,d=0,m=Number.MAX_VALUE,k=Number.MIN_VALUE,h=0,j=0,_.each(b,function(a){return f=Math.min(+f,a.dpMin),e=Math.max(+e,a.dpMax),c+=+a.dpAvg,d+=+a.dpDev,m=Math.min(+m,a.dtMin),k=Math.max(+k,a.dtMax),h+=+a.dtAvg,j+=+a.dtDev}),g=h/o,i=j/o,n={model:b[0].phoneModel,producent:a(b[0].phoneManufacturer),version:b[0].phoneVersionRelease,dpMin:f,dpMax:e,dpAvg:c/o,dpDev:d/o,freqMin:1e3/k,freqMax:1e3/m,freqAvg:(1e3/(g-i)+1e3/(g+i))/2,freqDev:1e3/(g-i)-(1e3/(g-i)+1e3/(g+i))/2,phoneTestsCount:o},l.push(n)}),i=function(a){var b,c,d,e,f,g,h,i,j,k;return k=a.length,f=Number.MAX_VALUE,e=Number.MIN_VALUE,d=Number.MIN_VALUE,b=0,c=0,j=Number.MAX_VALUE,i=Number.MIN_VALUE,g=0,h=0,_.each(a,function(a){return f=Math.min(f,a.dpMin),e=Math.max(e,a.dpMin),d=Math.max(d,a.dpMax),b+=a.dpAvg,c+=a.dpDev,j=Math.min(j,a.freqMin),i=Math.max(i,a.freqMax),g+=a.freqAvg,h+=a.freqDev}),{dpMin:f,dpMax:d,dpMinMin:f,dpMinMax:e,dpAvg:b/k,dpDev:c/k,freqMin:j,freqMax:i,freqAvg:g/k,freqDev:h/k}},m={},s={},_.each(l,function(a){return m[a.producent]=m[a.producent]||[],m[a.producent].push(a),s[a.version]=s[a.version]||[],s[a.version].push(a)}),p=i(l),n={},_.each(m,function(a,b){return n[b]=i(a)}),o={},_.each(s,function(a,b){return o[b]=i(a)}),$("#tests-count").html(Object.keys(b).length),$("#tests-count-distinct").html(Object.keys(h).length),$("#total-frequency").html(p.freqAvg.toPrecision(2)+"±"+p.freqDev.toPrecision(2)+"Hz (wartości z przedziału "+p.freqMin.toPrecision(2)+" - "+p.freqMax.toPrecision(2)+"Hz)"),$("#total-accuracy").html(p.dpMinMin.toPrecision(2)+" - "+p.dpMinMax.toPrecision(2)+"m/s<sup>2</sup>"),e=[["Producent","Częstotliwość"]],_.each(n,function(a,b){return e.push([b,+a.freqAvg.toPrecision(4)])}),d=google.visualization.arrayToDataTable(e),f={legend:"none",hAxis:{title:"Producent"},vAxis:{title:"Częstotliwość [Hz]"}},c=new google.visualization.ColumnChart(document.getElementById("chart-producent-frequency")),c.draw(d,f),e=[["Producent","Średnia częstotliwość [Hz]","Zakres częstotliowości [Hz]"]],_.each(n,function(a,b){return e.push([b,+a.freqAvg.toPrecision(2)+"±"+ +a.freqDev.toPrecision(2),+a.freqMin.toPrecision(2)+" - "+ +a.freqMax.toPrecision(2)])}),d=google.visualization.arrayToDataTable(e),c=new google.visualization.Table(document.getElementById("table-producent-frequency")),c.draw(d),e=[["Producent","Zmiana przyspieszenia"]],_.each(n,function(a,b){return e.push([b,+a.dpMin.toPrecision(4)])}),d=google.visualization.arrayToDataTable(e),f={legend:"none",hAxis:{title:"Producent"},vAxis:{title:"Zmiana przyspieszenia [m/s2]"}},c=new google.visualization.ColumnChart(document.getElementById("chart-producent-accuracy")),c.draw(d,f),e=[["Producent","Średnia zmiana przyspieszenia [m/s2]","Zakres zmian przyspieszenia [m/s2]"]],_.each(n,function(a,b){return e.push([b,+a.dpAvg.toPrecision(2)+"±"+ +a.dpDev.toPrecision(2),+a.dpMin.toPrecision(2)+" - "+ +a.dpMax.toPrecision(2)])}),d=google.visualization.arrayToDataTable(e),c=new google.visualization.Table(document.getElementById("table-producent-accuracy")),c.draw(d),e=[["Wersja Androida","Częstotliwość"]],_.each(o,function(a,b){return e.push([b,+a.freqAvg.toPrecision(4)])}),d=google.visualization.arrayToDataTable(e),f={legend:"none",hAxis:{title:"Wersja Androida"},vAxis:{title:"Częstotliwość [Hz]"}},c=new google.visualization.ColumnChart(document.getElementById("chart-version-frequency")),c.draw(d,f),e=[["Wersja Androida","Średnia częstotliwość [Hz]","Zakres częstotliowości [Hz]"]],_.each(o,function(a,b){return e.push([b,+a.freqAvg.toPrecision(2)+"±"+ +a.freqDev.toPrecision(2),+a.freqMin.toPrecision(2)+" - "+ +a.freqMax.toPrecision(2)])}),d=google.visualization.arrayToDataTable(e),c=new google.visualization.Table(document.getElementById("table-version-frequency")),c.draw(d),e=[["Wersja Androida","Zmiana przyspieszenia"]],_.each(o,function(a,b){return e.push([b,+a.dpMin.toPrecision(4)])}),d=google.visualization.arrayToDataTable(e),f={legend:"none",hAxis:{title:"Wersja Androida"},vAxis:{title:"Zmiana przyspieszenia [m/s2]"}},c=new google.visualization.ColumnChart(document.getElementById("chart-version-accuracy")),c.draw(d,f),e=[["Wersja Androida","Średnia zmiana przyspieszenia [m/s2]","Zakres zmian przyspieszenia [m/s2]"]],_.each(o,function(a,b){return e.push([b,+a.dpAvg.toPrecision(2)+"±"+ +a.dpDev.toPrecision(2),+a.dpMin.toPrecision(2)+" - "+ +a.dpMax.toPrecision(2)])}),d=google.visualization.arrayToDataTable(e),c=new google.visualization.Table(document.getElementById("table-version-accuracy")),c.draw(d),j=-1,q="",document.URL.indexOf("?")>=0&&(q=document.URL.substring(document.URL.indexOf("?")+1)),e=[["model","producent","ver","tests","f_avg","f_int","da_avg","da_int"]],_.each(l,function(a,b){return q==="phone="+a.model&&(j=b),e.push([a.model,a.producent,a.version,+a.phoneTestsCount,+a.freqAvg.toPrecision(2)+"±"+ +a.freqDev.toPrecision(2),+a.freqMin.toPrecision(2)+" - "+ +a.freqMax.toPrecision(2),+a.dpAvg.toPrecision(2)+"±"+ +a.dpDev.toPrecision(2),+a.dpMin.toPrecision(2)+" - "+ +a.dpMax.toPrecision(2)])}),d=google.visualization.arrayToDataTable(e),c=new google.visualization.Table(document.getElementById("table-whole-data")),c.draw(d),j>=0&&c.setSelection([{row:j,column:null}]),$("body").append("<div id='xxx-table'></div>"),$("body").append("<div id='xxx-chart-t'></div>"),$("body").append("<div id='xxx-chart-x'></div>"),$("body").append("<div id='xxx-chart-y'></div>"),$("body").append("<div id='xxx-chart-z'></div>"),$("body").append("<div id='xxx-chart-rx'></div>"),$("body").append("<div id='xxx-chart-ry'></div>"),$("body").append("<div id='xxx-chart-rz'></div>"),j=-1,q="",document.URL.indexOf("?")>=0&&(q=document.URL.substring(document.URL.indexOf("?")+1)),e=[["model","producent","ver","date","dpMin","dpMax","dpAvg","dpDev","dtMin","dtMax","dtAvg","dtDev"]],g=[];for(k in b)r=b[k],g.push(r),e.push([r.phoneModel,r.phoneManufacturer,r.phoneVersionRelease,r.date,(+r.dpMin).toPrecision(2),(+r.dpMax).toPrecision(2),(+r.dpAvg).toPrecision(2),(+r.dpDev).toPrecision(2),(+r.dtMin).toPrecision(2),(+r.dtMax).toPrecision(2),(+r.dtAvg).toPrecision(2),(+r.dtDev).toPrecision(2)]);return d=google.visualization.arrayToDataTable(e),c=new google.visualization.Table(document.getElementById("xxx-table")),c.draw(d),google.visualization.events.addListener(c,"select",function(){var a,d,e,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z,A;for(b=g[c.getSelection()[0].row],a=[["t","x"]],e=[["t","y"]],i=[["t","z"]],d=[["t","x"]],h=[["t","y"]],j=[["t","z"]],y=+b.autotest_t[0],x=-1,w=z=0,A=b.autotest_t.length;A>=0?A>=z:z>=A;w=A>=0?++z:--z)x!==+b.autotest_t[w]&&(x=+b.autotest_t[w],a.push([(x-y)/1e9,+b.autotest_x[w]]),e.push([(x-y)/1e9,+b.autotest_y[w]]),i.push([(x-y)/1e9,+b.autotest_z[w]]),d.push([(x-y)/1e9,+b.autotest_raw_x[w]]),h.push([(x-y)/1e9,+b.autotest_raw_y[w]]),j.push([(x-y)/1e9,+b.autotest_raw_z[w]]));return k=google.visualization.arrayToDataTable(a),m=google.visualization.arrayToDataTable(e),o=google.visualization.arrayToDataTable(i),l=google.visualization.arrayToDataTable(d),n=google.visualization.arrayToDataTable(h),p=google.visualization.arrayToDataTable(j),q=new google.visualization.LineChart(document.getElementById("xxx-chart-x")),s=new google.visualization.LineChart(document.getElementById("xxx-chart-y")),u=new google.visualization.LineChart(document.getElementById("xxx-chart-z")),r=new google.visualization.LineChart(document.getElementById("xxx-chart-rx")),t=new google.visualization.LineChart(document.getElementById("xxx-chart-ry")),v=new google.visualization.LineChart(document.getElementById("xxx-chart-rz")),f={legend:"none",title:"",hAxis:{title:"t [s]"},vAxis:{title:"a [m/s2]"}},f.title="Przyspieszenie bez grawitacji: oś X",q.draw(k,f),f.title="Przyspieszenie bez grawitacji: oś Y",s.draw(m,f),f.title="Przyspieszenie bez grawitacji: oś Z",u.draw(o,f),f.title="Przyspieszenie: oś X",r.draw(l,f),f.title="Przyspieszenie: oś Y",t.draw(n,f),f.title="Przyspieszenie: oś Z",v.draw(p,f)})}}).call(this);