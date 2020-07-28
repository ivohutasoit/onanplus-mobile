import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:onanplus/model/model.dart';
import 'package:onanplus/service/service.dart';
import 'package:onanplus/widget/widget.dart';

class StoreListPage extends StatefulWidget {
  final bool picker;

  StoreListPage({ Key key, this.picker = false }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _StoreListPageState();
}

class _StoreListPageState extends State<StoreListPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>(debugLabel: 'Store List');
  final _storeService = StoreService();

  bool _picker;

  @override
  void initState() {
    super.initState();
    _picker = widget.picker ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      // appBar: AppBar(
      //   //titleSpacing: 0.0,
      //   //automaticallyImplyLeading: false,
      //   title: Container(
      //     height: 36.0,
      //     child: Material(
      //       //color: Colors.grey.withOpacity(0.1),
      //       color: Colors.white,
      //       borderRadius: BorderRadius.all(Radius.circular(2.0)),
      //       child: InkWell(
      //         borderRadius: BorderRadius.all(Radius.circular(2.0)),
      //         //onTap: () => print('searching...'),
      //         child: Row(
      //           children: [
      //             Container(
      //               padding: EdgeInsets.only(left: 8.0, right: 8.0),
      //               child: Icon(CommunityMaterialIcons.magnify,
      //                 color: Theme.of(context).textTheme.caption.color,
      //               ),
      //             ),
      //             Expanded(
      //               child: TextField(
      //                 //readOnly: true,
      //                 decoration: InputDecoration(
      //                   border: InputBorder.none,
      //                   hintText: 'Search or find store...',
      //                 ),
      //                 maxLines: 1,
      //               ),
      //               // child: Text('Search or find somerthing...',
      //               //   style: TextStyle(
      //               //     fontSize: 16.0,
      //               //   ),
      //               // )
      //             ),
      //             // IconButton(
      //             //   icon: Icon(CommunityMaterialIcons.qrcode_scan,
      //             //     size: 20.0,
      //             //     color: Theme.of(context).textTheme.caption.color,
      //             //   ),
      //             //   onPressed: () => Navigator.of(context).pushNamed(router.scanCode),
      //             // ),
      //           ],
      //         ),
      //       ),
      //     ),
      //   ),
      // ),
      body: Center(
        child: FutureBuilder<List<Store>>(
          future: _getAroundStores(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
                return ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (context, index) {
                    final item = snapshot.data[index];
                    return ListTile(
                      title: Text(item.name),
                      subtitle: Text('about ${item.distance * 1000} meters'),
                      onTap: () async {
                        if(_picker) {
                          Navigator.of(_scaffoldKey.currentContext).pop(item);
                        }
                      },
                    );
                  },
                );
              } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              }
            return CircularProgressIndicator();
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if(_picker) {
            Navigator.of(_scaffoldKey.currentContext).pop(Store());
          }
        },
        child: Icon(CommunityMaterialIcons.plus),
      ),
    );
  }

  Future<List<Store>> _getAroundStores() async {
    LocationData currentLocation;
    final location = Location();
    try {
      currentLocation = await location.getLocation();
      return _storeService.around(currentLocation.latitude, currentLocation.longitude);
    } on Exception {
      return null;
    }
  }

}

class StoreDetailPage extends StatelessWidget {
  final String store;

  StoreDetailPage({ Key key, @required this.store }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(store),
      ),
    );
  }
}

class StoreCreatePage extends StatefulWidget {
  final bool picker;

  StoreCreatePage({ Key key, this.picker = false}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _StoreCreatePageState();
}

class _StoreCreatePageState extends State<StoreCreatePage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>(debugLabel: 'Store Form');
  final _formKey = GlobalKey<FormState>(debugLabel: 'Form');

  final _latitude = TextEditingController();
  final _longitude = TextEditingController();
  final _code = TextEditingController();
  final _name = TextEditingController();

  final _storeService = StoreService();

  LocationData _currentLocation;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('New Store'),
        actions: [
          FlatButton(
            color: Theme.of(context).accentColor,
            onPressed: () {
              if(_formKey.currentState.validate()) {
                final store = Store(
                  code: _code.text.trim(),
                  name: _name.text.trim(),
                  latitude: _currentLocation.latitude,
                  longitude: _currentLocation.longitude,
                );
                _save(context, store);
              }
            },
            child: Text('SAVE',
              style: Theme.of(context).textTheme.subtitle1,
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      filled: true,
                      labelText: 'Latitude',
                      labelStyle: Theme.of(context).textTheme.bodyText1,
                      border: InputBorder.none,
                    ),
                    controller: _latitude,
                    validator: (value) {
                      if(value.isEmpty) {
                        return 'Location latitude is mandatory';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(width: 16.0),
                Expanded(
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      filled: true,
                      labelText: 'Longitude',
                      labelStyle: Theme.of(context).textTheme.bodyText1,
                      border: InputBorder.none,
                    ),
                    controller: _longitude,
                    validator: (value) {
                      if(value.isEmpty) {
                        return 'Location longitude is mandatory';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            TextFormField(
              keyboardType: TextInputType.text,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                filled: true,
                labelText: 'Identifier Code',
                labelStyle: Theme.of(context).textTheme.bodyText1,
                border: InputBorder.none,
              ),
              controller: _code,
              validator: (value) {
                if(value.isEmpty) {
                  return 'Identifier code is mandatory';
                }
                return null;
              },
            ),
            SizedBox(height: 16.0),
            TextFormField(
              keyboardType: TextInputType.text,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                filled: true,
                labelText: 'Store Name',
                labelStyle: Theme.of(context).textTheme.bodyText1,
                border: InputBorder.none,
              ),
              controller: _name,
              validator: (value) {
                if(value.isEmpty) {
                  return 'name is mandatory';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save(BuildContext context, Store newStore) async {
    var _loadingKey = GlobalKey<State>();
    try {
      LoadingDialog.show(_loadingKey, context);
      final store = await _storeService.create(newStore);
      Navigator.of(_loadingKey.currentContext, rootNavigator: true).pop();
      if(store != null) {
        Navigator.of(context, rootNavigator: true).pop(store);
      }
    } catch (error) {
      print(error);
      Navigator.of(context, rootNavigator: true).pop();
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text('${error.toString()}'),
          duration: Duration(seconds: 5),
        ),
      );
    } 
  }

  Future<void> _getCurrentLocation() async {
    LocationData locationData;
    final location = Location();
    try {
      locationData = await location.getLocation();
      _latitude.text = locationData.latitude.toString();
      _longitude.text = locationData.longitude.toString();
      setState(() {
        _currentLocation = locationData;
      });
    } on Exception {
      print('error');
    }
  }
}