import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:onanplus/model/model.dart';
import 'package:onanplus/page/page.dart';
import 'package:onanplus/service/service.dart';
import 'package:onanplus/widget/widget.dart';

/// 
/// https://flutterawesome.com/flutter-plugin-to-implement-a-boom-menu/
/// 
class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ProductService _productService = ProductService();

  List<Product> _products = [];

  @override
  initState() {
    super.initState();
    _refreshProductList();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        //titleSpacing: 0.0,
        //automaticallyImplyLeading: false,
        title: Container(
          height: 46.0,
          child: Material(
            color: Colors.grey.withOpacity(0.1),
            // elevation: 2.0,
            //color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
            child: InkWell(
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
              onTap: () => print('searching...'),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.only(left: 8.0, right: 8.0),
                    child: Icon(CommunityMaterialIcons.magnify,
                      color: Theme.of(context).textTheme.caption.color,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      readOnly: true,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Search or find product...',
                      ),
                      maxLines: 1,
                    ),
                    // child: Text('Search or find somerthing...',
                    //   style: TextStyle(
                    //     fontSize: 16.0,
                    //   ),
                    // )
                  ),
                  IconButton(
                    icon: Icon(CommunityMaterialIcons.qrcode_scan,
                      size: 20.0,
                      color: Theme.of(context).textTheme.caption.color,
                    ),
                    onPressed: () async {
                      var barcode = await Navigator.push(_scaffoldKey.currentContext, 
                        MaterialPageRoute<String>(
                          builder: (context) => ScannerPage(),
                          fullscreenDialog: true
                        ),
                      );

                      if(barcode != null) {
                        _fetchDetail(_scaffoldKey.currentContext, barcode);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Container(
        child:Center(
          child: RefreshIndicator(
            child: ListView.separated(
              itemBuilder: (context, index) {
                var item = _products[index];

                return ListTile(
                  title: Text(item.name),
                  subtitle: Text(item.barcode),
                  onTap: () {
                      Navigator.of(context, rootNavigator: true).push(
                      MaterialPageRoute(
                        builder: (context) => ProductDetailPage(
                          product: item,
                        ),
                      ),
                    );
                  },
                );
              }, 
              separatorBuilder: (context, index) => Divider(height: 1.0,), 
              itemCount: _products.length
            ),
            onRefresh: _refreshProductList,
          )
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await showModalBottomSheet(
            context: _scaffoldKey.currentContext, 
            builder: (context) {
              return Container(
                child: ListView(
                  children: [
                    ListTile(
                      leading: CircleAvatar(
                        child: Icon(CommunityMaterialIcons.store,
                          size: 24.0,
                          color: Colors.white,
                        ),
                        backgroundColor: Theme.of(context).accentColor,
                      ),
                      title: Text('Store'),
                      subtitle: Text('Create new store based on your current location'),
                      onTap: () {
                        Navigator.pop(context, 'store');
                      },
                    ),
                    ListTile(
                      leading: CircleAvatar(
                        child: Icon(CommunityMaterialIcons.tag,
                          size: 24.0,
                          color: Colors.white,
                        ),
                        backgroundColor: Theme.of(context).accentColor,
                      ),
                      title: Text('Product Price'),
                      subtitle: Text('Submit new product price based on selected store'),
                      onTap: () {
                        Navigator.pop(context, 'price');
                      },
                    ),
                  ],
                ),
              );
            }
          );
          if (result != null && result is String) {
            if (result == 'store') {
              showModalBottomSheet(
                context: _scaffoldKey.currentContext, 
                builder: (context) => StoreCreatePage(),
              );
              // Navigator.of(_scaffoldKey.currentContext).push(
              //   MaterialPageRoute<Product>(
              //     builder: (context) => StoreCreatePage(),
              //   fullscreenDialog: true
              // ));
            } else if(result == 'price') {
              showModalBottomSheet(
                context: _scaffoldKey.currentContext, 
                builder: (context) => PriceCreatePage(),
              );
              // Navigator.of(_scaffoldKey.currentContext).push(
              //   MaterialPageRoute<Product>(
              //     builder: (context) => PriceCreatePage(),
              //   fullscreenDialog: true
              // ));
            }
          }
        },
        child: Icon(CommunityMaterialIcons.plus)
      ),
      // floatingActionButton: SpeedDial(
      //   animatedIcon: AnimatedIcons.menu_close,
      //   overlayColor: Colors.grey,
      //   overlayOpacity: 0.5,
      //   children: [
      //     SpeedDialChild(
      //       child: Icon(CommunityMaterialIcons.store_24_hour, 
      //         color: Colors.white,
      //       ),
      //       backgroundColor: Colors.redAccent,
      //       onTap: () => print('Add store'),
      //       label: 'New store',
      //       labelStyle: TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
      //       labelBackgroundColor: Colors.redAccent
      //     ),
      //     SpeedDialChild(
      //       child: Icon(CommunityMaterialIcons.tag,
      //         color: Colors.white,
      //       ),
      //       backgroundColor: Colors.green,
      //       onTap: () => print('Add store'),
      //       label: 'New price',
      //       labelStyle: TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
      //       labelBackgroundColor: Colors.green
      //     )
      //   ],
      // ),
    );
  }

  Future<void> _refreshProductList() async {
    final products = await _productService.list();
    setState(() {
      _products = products;
    });
  }

  Future<void> _fetchDetail(context, barcode) async {
    var _loadingKey = GlobalKey<State>();
    try {
      LoadingDialog.show(_loadingKey, context);
      var product = await _productService.detail(barcode);
      Navigator.of(_loadingKey.currentContext, rootNavigator: true).pop();
      //if(info['detail'] == CodeInfo.product) {
      if(product == null) {
        product = await showModalBottomSheet<Product>(
          context: _scaffoldKey.currentContext, 
          isScrollControlled: true,
          builder: (context) {
            return FractionallySizedBox(
              heightFactor: 0.8,
              child: ProductCreatePage(barcode: barcode),
            );
          },
          //builder: (context) =>  ProductCreatePage(barcode: barcode),
        );
        // product = await Navigator.of(_loadingKey.currentContext, rootNavigator: true).push(
        //   MaterialPageRoute<Product>(
        //     builder: (context) => ProductCreatePage(barcode: barcode),
        //   fullscreenDialog: true
        // ));
      }
      if(product != null) {
        Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(
            builder: (context) => ProductDetailPage(
              product: product,
            ),
          ),
        );
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
}