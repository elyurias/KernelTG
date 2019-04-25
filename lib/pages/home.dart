import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_cupertino_date_picker/flutter_cupertino_date_picker.dart';
import 'package:http/http.dart' as http;
import 'package:local_notifications/local_notifications.dart';
import 'package:path_provider/path_provider.dart';
import 'package:simple_permissions/simple_permissions.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';

import '../scoped-models/main.dart';
import '../widgets/ui_elements/logout_list_tile.dart';

class HomePage extends StatefulWidget {
  final MainModel model;

  HomePage(this.model);

  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  final double listSpec = 4.0;
  List clients;
  List projects;
  List projectsDate;
  String stateText;
  String _mySelection;
  String _mySelection2;
  String idCliente;
  String idProyecto;
  int valor;
  String dateIni = 'Fecha de inicio';
  String dateEnd = "Fecha de fin";
  String _datetimeIni = '';
  String _datetimeEnd = '';
  String _year = "2019";
  String _month = "01";
  String _date = "01";
  String _lang = 'en';
  String _format = 'yyyy-mm-dd';
  bool _showTitleActions = true;
  String url;

  TextEditingController _langCtrl = TextEditingController();
  TextEditingController _formatCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    this.projects = List();
    this.clients = List();
    this.projectsDate = List();
    this.getData();
    this.getProjects(0, 0);
    this.getProjectsDate(0, '0', '0');
    this.requestWritePermission();
    this.createChanel();

    _langCtrl.text = 'en';
    _formatCtrl.text = 'yyyy-mm-dd';
    DateTime now = DateTime.now();
    _year = now.year.toString();
    _month = now.month.toString();
    _date = now.day.toString();
  }

  Future removeNotify(String payload) async {
    await closeWebView();
    await LocalNotifications.removeNotification(0);
  }

  static const AndroidNotificationChannel channel =
      const AndroidNotificationChannel(
    id: 'default_notification11',
    name: 'CustomNotificationChannel',
    description: 'entro',
    importance: AndroidNotificationChannelImportance.HIGH,
    vibratePattern: AndroidVibratePatterns.DEFAULT,
  );

  DecorationImage _buildBackgroundImage() {
    return DecorationImage(
      fit: BoxFit.cover,
      colorFilter:
          ColorFilter.mode(Colors.black.withOpacity(0.5), BlendMode.dstATop),
      image: AssetImage('assets/back_login.jpg'),
    );
  }

  Future createChanel() async {
    await LocalNotifications.createAndroidNotificationChannel(channel: channel);
  }

  Future<void> getData() async {
    var resObCli = await http.get(
      Uri.encodeFull(
          "http://sack.kerneltechnologiesgroup.com/kernelitservices/cliente/obtenerClientes"),
      headers: {"Accept": "application/json"},
    );

    this.setState(() {
      this.clients = json.decode(resObCli.body)["List"];
    });
  }

  Future<void> getProjects(idClient, idProject) async {
    this.getData();
    try {
      var respProjects = await http.get(
        Uri.encodeFull(
            "http://sack.kerneltechnologiesgroup.com/kernelitservices/proyecto/obtenerDatosReporteProyectos/" +
                idClient.toString() +
                "/" +
                idProject.toString() +
                "/a/a/a"),
        headers: {"Accept": "application/json"},
      );

      this.setState(() {
        this.projects = json.decode(respProjects.body)["List"];
      });
    } catch (e) {
      debugPrint(" ERRROR: " + e);
    }
  }

  Future<void> getProjectsDate(
      idClient, String fehcaInicio, String fFin) async {
    var resProjDate = await http.get(
      Uri.encodeFull(
          "http://sack.kerneltechnologiesgroup.com/kernelitservices/proyecto/obtenerDatosReporteProyectos/" +
              idClient.toString() +
              "/a/" +
              fehcaInicio.toString() +
              "/" +
              fFin.toString() +
              "/a"),
      headers: {"Accept": "application/json"},
    );
    this.setState(() {
      projects = json.decode(resProjDate.body)["List"];
    });
  }

  Future<File> downloadExcel(String url, String filename) async {
    http.Client client = new http.Client();
    var req = await client.get(Uri.parse(url));
    var bytes = req.bodyBytes;
    String dir = (await getExternalStorageDirectory()).path;
    File file = new File('$dir/$filename');
    await file.writeAsBytes(bytes);
    return file;
  }

  Future alertDownloadFile(String url) async {
    print('HERE'+url);
    await LocalNotifications.createNotification(
      id: 0,
      title: 'kernel ti',
      content: 'Reporte descargado en archivos',
      androidSettings: new AndroidSettings(
        isOngoing: false,
        channel: channel,
        priority: AndroidNotificationPriority.HIGH,
      ),
      onNotificationClick: new NotificationAction(
          actionText: "dadadad", callback: removeNotify, payload: ""),
    );
  }

  _changeDatetimeIni(int year, int month, int date) {
    setState(() {
      _year = year.toString();
      _month = month.toString();
      _date = date.toString();
      _datetimeIni = '$year-$month-$date';
      dateIni = _year +
          "-" +
          _twoDigits(int.parse(_month)) +
          "-" +
          _twoDigits(int.parse(_date));
      return dateIni;
    });
  }

  static String _twoDigits(int date) {
    return date < 10 ? "0$date" : "$date";
  }

  void _showDatePicker() {
    final bool showTitleActions = false;
    var now = new DateTime.now();
    DatePicker.showDatePicker(
      context,
      showTitleActions: _showTitleActions,
      minYear: 1999,
      maxYear: now.year,
      initialYear: int.parse(_year),
      initialMonth: int.parse(_month),
      initialDate: int.parse(_date),
      cancel: Text(
        'Cancelar',
        style: TextStyle(color: Color.fromARGB(255, 30, 67, 158)),
      ),
      confirm: Text(
        'Aceptar',
        style: TextStyle(color: Color.fromARGB(255, 30, 67, 158)),
      ),
      locale: _lang,
      dateFormat: _format,
      onChanged: (year, month, date) {
        debugPrint('onChanged date: $year-$month-$date');

        if (!showTitleActions) {
          _changeDatetimeIni(year, month, date);
        }
      },
      onConfirm: (year, month, date) {
        _changeDatetimeIni(year, month, date);
      },
    );
  }

  void _showDatePickerEnd() {
    final bool showTitleActions = false;
    var now = new DateTime.now();
    DatePicker.showDatePicker(
      context,
      showTitleActions: _showTitleActions,
      minYear: 1999,
      maxYear: now.year,
      initialYear: int.parse(_year),
      initialMonth: int.parse(_month),
      initialDate: int.parse(_date),
      cancel: Text(
        'Cancelar',
        style: TextStyle(color: Color.fromARGB(255, 30, 67, 158)),
      ),
      confirm: Text(
        'Aceptar',
        style: TextStyle(color: Color.fromARGB(255, 30, 67, 158)),
      ),
      locale: _lang,
      dateFormat: _format,
      onChanged: (year, month, date) {
        debugPrint('onChanged date: $year-$month-$date');

        if (!showTitleActions) {
          _changeDatetimeEnd(year, month, date);
        }
      },
      onConfirm: (year, month, date) {
        _changeDatetimeEnd(year, month, date);
        DateTime now = DateTime.now();
        _year = now.year.toString();
        _month = now.month.toString();
        _date = now.day.toString();
        if (dateIni == 'Fecha de fin') {
          dateIni = _year +
              "-" +
              _twoDigits(int.parse(_month)) +
              "-" +
              _twoDigits(int.parse(_date));
        }

        getProjectsDate(idCliente, dateIni, dateEnd);
      },
    );
  }

  _changeDatetimeEnd(int year, int month, int date) {
    setState(() {
      _year = year.toString();
      _month = month.toString();
      _date = date.toString();
      _datetimeEnd = '$year-$month-$date';
      dateEnd = _year +
          "-" +
          _twoDigits(int.parse(_month)) +
          "-" +
          _twoDigits(int.parse(_date));
      print(dateEnd);
      return dateEnd;
    });
  }

  requestWritePermission() async {
    // ignore: unused_local_variable
    PermissionStatus permissionStatus =
        await SimplePermissions.requestPermission(
            Permission.WriteExternalStorage);
    // ignore: unused_local_variable
    PermissionStatus permissionStatusVibrate =
        await SimplePermissions.requestPermission(Permission.Vibrate);
    /*
    if (permissionStatus == PermissionStatus.authorized && permissionStatusVibrate == PermissionStatus.authorized) {
      setState(() {
        bool _allowWriteFile = true;
      });
    }
    */
  }

  void showToast(String msg, {int duration, int gravity}) {
    Toast.show(msg, context, duration: duration, gravity: gravity);
  }

  Widget _buildSideDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          AppBar(
            automaticallyImplyLeading: false,
            title: Text('Kernel TI'),
            backgroundColor: Color.fromARGB(255, 30, 67, 158),
          ),
          LogoutListTile()
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildSideDrawer(context),
      appBar: AppBar(
        title: Text('Kernel'),
        backgroundColor: Color.fromARGB(255, 30, 67, 158),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: _buildBackgroundImage(),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(top: 10.0),
              width: 300.0,
              child: new DropdownButton(
                hint: Text('Selecciona un cliente'),
                value: _mySelection,
                isExpanded: true,
                onChanged: (newValue) {
                  setState(() {
                    _mySelection = newValue;
                    idCliente = _mySelection;
                    _mySelection2 = null;
                    getProjects(idCliente, "a");
                    getProjectsDate(idCliente, "0", "0");
                    dateIni = "Fecha de inicio";
                    dateEnd = "Fecha de fin";
                  });
                },
                items: clients.map((item) {
                  return new DropdownMenuItem(
                    child: new Text(
                      item['nombre'],
                    ),
                    value: item['id_cliente'].toString(),
                  );
                }).toList(),
              ),
            ),
            Container(
              width: 300.0,
              child: new DropdownButton(
                hint: Text('Selecciona un proyecto'),
                value: _mySelection2,
                isExpanded: true,
                onChanged: (newVal) {
                  if (newVal != null) {
                    _mySelection2 = newVal;
                    idProyecto = _mySelection2;
                    getProjects(idCliente, idProyecto);
                  }
                },
                items: projects.map((item) {
                  return new DropdownMenuItem(
                    child: new Text(item['nombre'].toString()),
                    value: item['idProyecto'].toString(),
                  );
                }).toList(),
              ),
            ),
            new Card(
                color: Color.fromARGB(180, 30, 67, 158),
                child: new Padding(
                  padding: new EdgeInsets.all(3.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      new FlatButton.icon(
                        icon: const Icon(Icons.date_range,
                            size: 28.0, color: Colors.lightBlue),
                        label: new Text(dateIni),
                        color: Colors.white,
                        onPressed: () {
                          _showDatePicker();
                          print(dateIni);
                        },
                      ),
                      new FlatButton.icon(
                        icon: const Icon(Icons.date_range,
                            size: 28.0, color: Colors.lightBlue),
                        label: new Text(dateEnd),
                        color: Colors.white,
                        onPressed: () {
                          _showDatePickerEnd();
                        },
                      ),
                    ],
                  ),
                )),
            Expanded(
              child: new Card(
                color: Color.fromARGB(180, 30, 67, 158),
                elevation: 1.0,
                child: new ListView.builder(
                  itemCount: projects == null ? 0 : projects.length,
                  itemBuilder: (context, i) {
                    return new Container(
                      padding: new EdgeInsets.all(10.0),
                      child: new Card(
                        child: new Container(
                          padding: new EdgeInsets.all(20.0),
                          child: new Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              new Text(
                                "Nombre de cliente : " +
                                    projects[i]['cliente']['nombre'].toString(),
                                style: new TextStyle(
                                    fontSize: 20.0,
                                    color: Color.fromARGB(255, 30, 67, 158)),
                              ),
                              new Text("Proyecto: " +
                                  projects[i]['nombre'].toString()),
                              new Text("Fecha de inicio: " +
                                  projects[i]['fecha_inicio'].toString()),
                              new Text("Fecha de fin: " +
                                  projects[i]['fecha_fin'].toString()),
                              new Text("Horas estimadas: " + "0000"),
                              new Text("horas reales: " +
                                  projects[i]['tiempo_total'].toString()),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            new Card(
              color: Color.fromARGB(180, 30, 67, 158),
              child: new Padding(
                padding: new EdgeInsets.all(3.0),
                child: new Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    new FlatButton.icon(
                      icon: const Icon(Icons.border_clear,
                          size: 28.0, color: Colors.green),
                      label: const Text('Crear EXCEL'),
                      color: Colors.white,
                      onPressed: () {
                        if (idCliente != null &&
                            idCliente != '0' &&
                            idCliente != '' &&
                            idCliente != ' ') {
                          if (idProyecto != null &&
                              idProyecto != '0' &&
                              idProyecto != '' &&
                              idProyecto != ' ') {
                            if ((dateIni != 'Fecha de inicio' &&
                                    dateEnd == 'Fecha de fin') ||
                                (dateIni == 'Fecha de inicio' &&
                                    dateEnd != 'Fecha de fin')) {
                              url =
                                  'http://sack.kerneltechnologiesgroup.com/kernelitservices/proyecto/downloadProyectos/$idCliente/$idProyecto/$dateIni/$dateEnd/null';
                              downloadExcel(url, 'reporte.xlsx');
                              alertDownloadFile(url);
                            } else {
                              url =
                                  'http://sack.kerneltechnologiesgroup.com/kernelitservices/proyecto/downloadProyectos/$idCliente/$idProyecto/a/a/null';
                              downloadExcel(url, 'reporte.xlsx');
                              alertDownloadFile(url);
                            }
                          } else {
                            url =
                                'http://sack.kerneltechnologiesgroup.com/kernelitservices/proyecto/downloadProyectos/$idCliente/a/a/a/null';
                            downloadExcel(url, 'reporte.xlsx');
                            alertDownloadFile(url);
                          }
                        } else {
                          showToast("Selecciona almenos un filtro");
                        }
                      },
                    ),
                    new FlatButton.icon(
                      icon: const Icon(Icons.picture_as_pdf,
                          size: 28.0, color: Colors.redAccent),
                      label: const Text('Crear PDF'),
                      color: Colors.white,
                      onPressed: () {
                        if (idCliente != null &&
                            idCliente != '0' &&
                            idCliente != '' &&
                            idCliente != ' ') {
                          if (idProyecto != null &&
                              idProyecto != '0' &&
                              idProyecto != '' &&
                              idProyecto != ' ') {
                            if ((dateIni != null && dateEnd == null) ||
                                (dateIni == null && dateEnd != null)) {
                              url =
                                  'http://sack.kerneltechnologiesgroup.com/kernelitservices/proyecto/downloadProyectosPdf/$idCliente/$idProyecto/$dateIni/$dateEnd/null';
                              downloadExcel(url, 'reporte.pdf');
                              alertDownloadFile(url);
                            } else {
                              url =
                                  'http://sack.kerneltechnologiesgroup.com/kernelitservices/proyecto/downloadProyectosPdf/$idCliente/$idProyecto/a/a/null';
                              downloadExcel(url, 'reporte.pdf');
                              alertDownloadFile(url);
                            }
                          } else {
                            url =
                                'http://sack.kerneltechnologiesgroup.com/kernelitservices/proyecto/downloadProyectosPdf/$idCliente/a/a/a/null';
                            downloadExcel(url, 'reporte.pdf');
                            alertDownloadFile(url);
                          }
                        } else {
                          showToast("Selecciona almenos un filtro");
                        }
                      },
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
