(
//Target auf Lautsprecher Dreiecke projizieren anstatt auf die eigene Kreislaufbahn, damit die Distanz auch mal "vollpegel" beträgt
//Lautsprecher Farbe nach Signalstärke ändern
//yRotation implementieren
//azi und height Werte im Interface sichtbar machen zB mit NumberBoxes
//Teil der Knob actionFunctions der bei allen gleich ist ein Mal formulieren und dann aufrufen
//Spread mit reinarbeiten: durch vergrößerung von tri und triGain und natürlich spread!!

// TEST-KOMMENTAR ZUR GIT DEMO!!!!
// Hallo


var wWidth = 600;
var wHeight = 700;
var run = true;
var phase = 0;
var zoom = 100;
var fluchtPunkt = -10;

//for calculating loudspeaker position
var l = [[1.81,0.2296,-0.515],
	[1.745,0.2288,1.115],
	[1.69,-0.4457,-0.89],
	[1.9,-0.4411,-0.04],
	[1.77,-0.4407,0.775],
	[1.3958,-1.132,-0.4773],
	[1.595,-1.1354,0.3041],
	[1.3276,-1.1459,0.9371],
	[1.3726,-0.2984,1.4998],
	[0.8341,-1.1423,1.3908],
	[0.6096,-0.6896,1.8134],
	[0.3244,0.0702,2.0177],
	[-0.0711,-1.1365,1.6231],
	[-0.2329,-0.3007,1.9962],
	[-0.7359,-0.4703,1.6993],
	[-0.8336,0.271,1.8455],
	[-0.8556,-1.144,1.3879],
	[-1.3684,-0.0172,1.4718],
	[-1.4066,-1.094,1.061],
	[-1.8301,-0.3009,0.9031],
	[-1.6819,-0.9418,0.4893],
	[-2.0415,-0.2945,0.1224],
	[-1.6469,-1.14,-0.1064],
	[-2.0217,0.1459,-0.4818],
	[-1.8613,-0.5429,-0.9013],
	[-1.4486,-1.1501,-0.7858],
	[-1.7117,0.0362,-1.1951],
	[-1.0356,-1.1113,-1.362],
	[-1.2452,-0.2316,-1.6501],
	[-0.8405,0.3191,-1.8758],
	[-0.5066,-1.1491,-1.5665],
	[-0.3741,-0.3006,-2.0011],
	[0.225,1.5665,-0.0037],
	[1.779,0.5124,0.2995],
	[0.8296,1.3243,0.3981],
	[1.2938,0.8564,1.1662],
	[0.3197,1.3608,0.8332],
	[0.8471,0.3117,1.6635],
	[0.3778,0.8932,1.437],
	[-0.3156,0.5427,1.8567],
	[-0.4401,1.2999,0.8322],
	[-0.8889,0.8547,1.2943],
	[-1.6043,0.6925,0.8521],
	[-1.1564,1.2249,0.416],
	[-2.0036,0.3601,0.2701],
	[-0.622,1.511,-0.0126],
	[-1.6598,0.9026,-0.3091],
	[-1.4723,0.612,-1.2587],
	[-0.8638,1.2262,-0.8391],
	[-0.5792,0.9087,-1.5638],
	[-0.0056,1.4177,-0.8875],
	[0.2058,0.711,-1.7508],
	[0.8693,0.8811,-1.3845],
	[0.7804,1.3718,-0.5616],
	[1.4417,0.7167,-0.8108],
	[1.4312,1.0554,-0.1241],
	[0.0831,-1.1415,-1.6517],
	[0.206,-0.1071,-2.0353],
	[0.6863,-0.8267,-1.7084],
	[0.8093,0.1763,-1.8783],
	[0.9892,-1.1329,-1.2142],
	[1.2208,-0.484,-1.3458],
	[1.3564,0.2741,-1.4757]];


var distances = List.newClear(64);
var tri = List.newClear(3);


//Controller start values
var azi = 0;
var height = 0;
var radius = 4;

//real Coordinates
var hypo = cos(asin(abs(height/radius)));//Hypothenuse
var x = cos(degrad(azi))*radius*hypo;
var z = height;
var y = sin(degrad(azi))*radius*hypo;


var xRot = 0;
//rotated Coordinates
var hypoRot = cos(asin(abs(height/radius)));//Hypothenuse
var xRotation = cos(degrad(azi + xRot))*radius*hypo;
var yRot = height;
var zRot = sin(degrad(azi + xRot))*radius*hypo;



//Controller options
var aziSpec = ControlSpec(0,360);
var heightSpec = ControlSpec(-1,1);
var radiusSpec = ControlSpec(1,100);
var rotationSpec = ControlSpec(0,360);

var xRotKnob = Knob.new().value_(cos(degrad(90)));
var aziKnob = Knob.new();
var heightKnob = Knob.new().value_(0.5);
//var radiusKnob = Knob.new().value_(radiusSpec.unmap(radius));

var aziInfo = StaticText().string_("azimuth").minWidth_(80);
var heightInfo = StaticText().string_("height").minWidth_(80);
var radiusInfo = StaticText().string_("radius").minWidth_(80);
var xRotInfo = StaticText().string_("yRotation").minWidth_(80);


// Color options / Amp gain
var colorSpec = ControlSpec(0,255);
var lsRed = 0;
var triGain = List.newClear(3);
var denominator = 1;//gemeinsamer Nenner aus den drei kürzesten Distanzen
var spread = 3;


//Simulation
//var circleX, circleY;//effizienter hier oder in der Funktion zu deklarieren??weil Variable nur in Funktion gebraucht wird

var simulationView;
var windowLayout;

a = Slider2D.new().y_(0.5);
w = Window("Simulation", Rect(200,200,wWidth,wHeight));
g = GridLayout.rows(
	[aziKnob, [a, rows:4], xRotKnob],
	[aziInfo, nil, xRotInfo],
	[heightKnob],
	[heightInfo]
).hSpacing_(50);
//v = View(w, Rect(10,10,w.view.bounds.width-20, 200)).layout_(g).background_(Color.new255(200,0,0,250));


v = View().layout_(g).background_(Color.new255(200,200,160,100));
simulationView = UserView().background_(Color.new255(0,0,0));
windowLayout = GridLayout.rows([v],[simulationView]).setRowStretch(1,2);

w.front.layout_(windowLayout);
w.onClose = {run = false};//stop the thread onClose


//loudspeaker Array:


3.do({|i| triGain.put(i, 2.2)});

//Draw Function
simulationView.drawFunc = {
	var penSpec = ControlSpec(-1*radius, radius, \lin);
	var circleDiameter = penSpec.unmap(zRot)*10+ 4;
	var circleX = zoom * xRotation-circleDiameter/2;
	var circleY = -1* zoom * yRot-circleDiameter/2 + ((height/radius)*zRot*fluchtPunkt) ;


	Pen.width = 2;
	Pen.translate(simulationView.bounds.width/2, simulationView.bounds.height/2);






	l.do({|item, i|
		var d;
		var lsX;
		var lsY;
		var lsDiameter;


		//Betrachtet wird ein Dreieck aus den Punkten: die Lautsprecherposition, der Nullpunkt auf der gleichen Höhe des Lautsprechers (0|y|0) und (x|y|0)
		var lsHypo = sqrt( item[0].pow(2) + item[2].pow(2) );//Abstand vom Lautsprecher bis zum Mittelpunkt auf gleicher Höhe, deshalb wird die y-Koordinate nicht mit einbezogen

		var lsAnka = item[0];
		var lsGegenka = item[2];

		var lsAzi = raddeg ( acos( lsAnka/lsHypo ) );//lsAzi ist der Winkel zwischen Ankatathete und Hypothenuse
		//var lsAzi = raddeg (asin (lsGegenka/lsHypo ));


		if(item[2] < 0, {lsAzi = 360 - lsAzi;});
		lsAzi = lsAzi + xRot;//neuer Winkel um xRot vergrößert

		lsAzi = degrad(lsAzi);//und in radians umgewandelt

		lsAnka = cos(lsAzi)*lsHypo;//lsAnka stellt die x-Koordinate dar


		lsGegenka = sin(lsAzi)*lsHypo;//lsGegenka stellt die z-Koordinate dar

		lsX = lsAnka * zoom;
		lsY = -1 * zoom * item[1] + (item[1] * lsGegenka * fluchtPunkt);

		//triGain.at(2).isFloat.postln;
		denominator = triGain[0] + triGain[1] + triGain[2];
		//(triGain[0] + triGain[1] + triGain[2]).postln;
		if(i == tri[0], {
			lsRed = colorSpec.map( triGain[0]/denominator );
			//lsRed.postln;
			Pen.color = Color.new255(lsRed,0,200);
		},{

				if( i == tri[1], {
					lsRed = colorSpec.map( triGain[1]/denominator );
					Pen.color = Color.new255(lsRed,0,200);

				}, {
						if (i== tri[2], {
							lsRed = colorSpec.map( triGain[2]/denominator );
							Pen.color = Color.new255(lsRed,0,200);
							}, {
							Pen.color = Color.new255(54,140,250);
						});

				});


		});

		lsDiameter = 3*lsGegenka+8;
		Pen.fillOval(Rect(lsX, lsY,lsDiameter,lsDiameter));




		//Calculate distances to loudspeakers
		//get Distances from Target to every loudspeaker and save in list -> distances
		d = sqrt(
			(item[0]-x).pow(2)+
			(item[1]-y).pow(2)+
			(item[2]-z).pow(2));
		//distances.put(i, d);
		distances.add(d);


	});
	//distances.postln;
	spread.do({|item, i|
			//tri[i] = distances.minIndex;
		//("distances.minIndex "++i++" : "++distances.minIndex).postln;
		tri.put(i, distances.minIndex);
		triGain.put(i, distances[distances.minIndex]);
		distances[distances.minIndex] = distances[distances.maxIndex];
		//tri[i].postln;

		});
	//triGain.postln;
	distances.clear;



	//Draw Target
	Pen.use{

		Pen.color = Color.new255(250,250,250);
		Pen.fillOval(Rect(circleX,circleY,circleDiameter,circleDiameter));

	};







};

{while{run}{
	simulationView.refresh;
	0.02.wait;

}}.fork(AppClock);


aziKnob.action_({|v|
	a.x = v.value;
	azi = aziSpec.map(v.value);

	//real Coordinates
	hypo = cos(asin(abs(height/radius)));
	x = cos(degrad(azi))*radius*hypo;
	y = height;
	z = sin(degrad(azi))*radius*hypo;

	//rotated Coordinates
	hypoRot = cos(asin(abs(height/radius)));
	xRotation = cos(degrad(azi + xRot))*radius*hypo;
	yRot = height;
	zRot = sin(degrad(azi + xRot))*radius*hypo;


});
heightKnob.action_({|v|
	a.y = v.value;
	height = heightSpec.map(v.value)*radius;

	//real Coordinates
	hypo = cos(asin(abs(height/radius)));
	x = cos(degrad(azi))*radius*hypo;
	y = height;
	z = sin(degrad(azi))*radius*hypo;

	//rotated Coordinates
	hypoRot = cos(asin(abs(height/radius)));
	xRotation = cos(degrad(azi + xRot))*radius*hypo;
	yRot = height;
	zRot = sin(degrad(azi + xRot))*radius*hypo;
});
/*radiusKnob.action_({|v|
	radius = radiusSpec.map(v.value);
	//radiusInfo.string_("radius");
	height = heightSpec.map(heightKnob.value)*radius;
	//heightInfo.string_("height");
	("Radius: "++radius++"m").postln;

	hypo = cos(asin(abs(height/radius)));
	x = cos(degrad(azi))*radius*hypo;
	y = height;
	z = sin(degrad(azi))*radius*hypo;
	("Target("+x+"|"+y+"|"+z+")").postln;
});*/
a.action_({|v|
	aziKnob.value = v.x;
	heightKnob.value = v.y;
	azi = aziSpec.map(v.x);
	//if(azi > 360 , { azi = azi-360;} );
	height = heightSpec.map(v.y)*radius;
	("Azimuth: "++azi++"°  |  height: "++height++"m").postln;

	//real Coordinates
	hypo = cos(asin(abs(height/radius)));
	x = cos(degrad(azi))*radius*hypo;
	y = height;
	z = sin(degrad(azi))*radius*hypo;

	//rotated Coordinates
	hypoRot = cos(asin(abs(height/radius)));
	xRotation = cos(degrad(azi + xRot))*radius*hypo;
	yRot = height;
	zRot = sin(degrad(azi + xRot))*radius*hypo;
	("Target("+x+"|"+y+"|"+z+")").postln;
});

xRotKnob.action_({|v|

	xRot = rotationSpec.map(v.value);

	//real Coordinates
	hypo = cos(asin(abs(height/radius)));
	x = cos(degrad(azi))*radius*hypo;
	y = height;
	z = sin(degrad(azi))*radius*hypo;


	//rotated Coordinates
	hypoRot = cos(asin(abs(height/radius)));
	xRotation = cos(degrad(azi + xRot))*radius*hypo;
	yRot = height;
	zRot = sin(degrad(azi + xRot))*radius*hypo;




});

)


s = 3;
l = List.newClear(3);
s.do({|i| l.put(i, i); (l).postln;});
l
l[0]+l[1]+l[2]