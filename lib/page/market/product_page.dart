import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:onanplus/model/model.dart';
import 'package:onanplus/page/common/scanner_page.dart';
import 'package:onanplus/page/market/store_page.dart';
import 'package:onanplus/service/service.dart';
import 'package:onanplus/widget/widget.dart';

class ProductListView extends StatefulWidget {

  final List<Product> products;

  ProductListView({Key key, this.products}): super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ProductListViewState();
  }

}

class _ProductListViewState extends State<ProductListView> {
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemBuilder: (context, index) {
        var item = widget.products[index];

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
      itemCount: widget.products.length
    );
  }

}

/// ===================================================
/// Block of Pages
/// ===================================================
class ProductListPage extends StatefulWidget {

  final bool picker;

  ProductListPage({Key key, this.picker = false }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey(debugLabel: 'Product List');

  final ProductService _productService = ProductService();

  List<Product> _products = [];

  @override
  initState() {
    super.initState();
    _refreshProductList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
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
                    if (widget.picker) {
                      Navigator.pop(context, item);
                    } else {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ProductDetailPage(
                            product: item,
                          ),
                        ),
                      );
                    }
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
      floatingActionButton: !widget.picker ? FloatingActionButton(
        onPressed: () async {
          var barcode = await Navigator.push(_scaffoldKey.currentContext, 
            MaterialPageRoute<String>(
              builder: (context) => ScannerPage(),
              fullscreenDialog: true
            ),
          );

          if(barcode != null) {
            _fetchDetailProduct(_scaffoldKey.currentContext, barcode);
          }
        },
        tooltip: 'Scan barcode',
        child: Icon(CommunityMaterialIcons.barcode_scan),
      ) : Container(),
    );
  }

  Future<void> _refreshProductList() async {
    final products = await _productService.list();
    setState(() {
      _products = products;
    });
  }

  Future<void> _fetchDetailProduct(context, barcode) async {
    var _loadingKey = GlobalKey<State>();
    try {
      LoadingDialog.show(_loadingKey, context);
      var product = await _productService.detail(barcode);
      Navigator.of(_loadingKey.currentContext, rootNavigator: true).pop();
      if(product == null) {
        product = await Navigator.of(_loadingKey.currentContext, rootNavigator: true).push(
          MaterialPageRoute<Product>(
            builder: (context) => ProductCreatePage(barcode: barcode),
          fullscreenDialog: true
        ));
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

class ProductDetailPage extends StatelessWidget {
  final Product product;

  ProductDetailPage({ Key key, @required this.product }) : super(key:key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${product.name}'), 
            Text('${product.barcode}',
              style: TextStyle(
                fontSize: 12.0
              )
            ),
          ],
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              height: 46.0,
              child: Material(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
                child: InkWell(
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
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
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Search or find store...',
                          ),
                          maxLines: 1,
                        ),
                      ),
                      // IconButton(
                      //   icon: Icon(CommunityMaterialIcons.qrcode_scan,
                      //     size: 20.0,
                      //     color: Theme.of(context).textTheme.caption.color,
                      //   ),
                      //   onPressed: () => Navigator.of(context).pushNamed(router.scanCode),
                      // ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => print('add price'),
        child: Icon(CommunityMaterialIcons.plus_one),
      ),
    );
  }

}

class ProductCreatePage extends StatefulWidget {
  final String barcode;

  ProductCreatePage({ Key key, this.barcode }) : super(key:key);

  @override
  State<StatefulWidget> createState() {
    return _ProductCreatePageState();
  }

}

class _ProductCreatePageState extends State<ProductCreatePage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>(debugLabel: 'Product Form');
  final _formKey = GlobalKey<FormState>(debugLabel: 'Form');
  final _name = TextEditingController();
  final _manufacture = TextEditingController();
  final _store = TextEditingController();
  final _amount = TextEditingController();
  final _detail = TextEditingController();
  final _startDate = TextEditingController();
  final _endDate = TextEditingController();

  bool _promotion = false;

  final _priceService = PriceService();
  final _productService = ProductService();
  final _storeService = StoreService();

  Store _selectedStore;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('${widget.barcode}'),
        actions: [
          FlatButton(
            color: Theme.of(context).accentColor,
            onPressed: () {
              if(_formKey.currentState.validate()) {
                final product = Product(
                  barcode: widget.barcode.trim(),
                  name: _name.text.trim(),
                  manufacture: _manufacture.text.trim(),
                  detail: _detail.text.trim()
                );
                _save(_scaffoldKey.currentContext, product);
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
            TextFormField(
              keyboardType: TextInputType.text,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                filled: true,
                labelText: 'Product Name',
                labelStyle: Theme.of(context).textTheme.bodyText1,
                border: InputBorder.none,
                prefixIcon: Icon(CommunityMaterialIcons.box,
                  color: Theme.of(context).accentColor,
                ),
                helperText: 'Format: [BRAND] [SIZE]',
              ),
              controller: _name,
              validator: (value) {
                if(value.isEmpty) {
                  return 'Product name is mandatory';
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
                labelText: 'Manufacture',
                labelStyle: Theme.of(context).textTheme.bodyText1,
                border: InputBorder.none,
                prefixIcon: Icon(CommunityMaterialIcons.office_building,
                  color: Theme.of(context).accentColor,
                ),
              ),
              controller: _manufacture,
            ),
            SizedBox(height: 16.0),
            TextFormField(
              decoration: InputDecoration(
                filled: true,
                border: InputBorder.none,
                labelText: 'Store',
                labelStyle: Theme.of(context).textTheme.bodyText1,
                prefixIcon: Icon(CommunityMaterialIcons.store,
                  color: Theme.of(context).accentColor,
                ),
              ),
              controller: _store,
              validator: (value) {
                if(value.isEmpty) {
                  return 'store is mandatory';
                }
                return null;
              },
              readOnly: true,
              onTap: () async {
                final result = await Navigator.of(_scaffoldKey.currentContext).push(
                  MaterialPageRoute<Store>(
                    builder: (context) => StoreListPage(picker: true,),
                    fullscreenDialog: true
                  ),
                );
                if(result != null) { 
                  if(result is Store) {
                    _selectedStore = result;
                    if(_selectedStore.id == null && _selectedStore.name == null) {
                      final created = await Navigator.of(_scaffoldKey.currentContext).push(
                        MaterialPageRoute<Store>(
                          builder: (context) => StoreCreatePage(picker: true,),
                          fullscreenDialog: true
                        ),
                      );
                      if(created != null) { 
                        if(created is Store) {
                          _selectedStore = created;
                          _store.text = '${_selectedStore.name}';
                        }
                      }
                    }
                    _store.text = '${_selectedStore.name}';
                  } 
                }
              },
            ),
            SizedBox(height: 16.0),
            TextField(
              keyboardType: TextInputType.text,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                filled: true,
                labelText: 'Detail',
                labelStyle: Theme.of(context).textTheme.bodyText1,
                border: InputBorder.none,
                prefixIcon: Icon(CommunityMaterialIcons.details,
                  color: Theme.of(context).accentColor,
                ),
              ),
              minLines: 1,
              maxLines: 2,
              controller: _detail,
            ),
            SizedBox(height: 16.0),
            TextFormField(
              keyboardType: TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                filled: true,
                labelText: 'Price (PC)',
                labelStyle: Theme.of(context).textTheme.bodyText1,
                border: InputBorder.none,
                prefixIcon: Icon(CommunityMaterialIcons.tag,
                  color: Theme.of(context).accentColor,
                ),
                prefixText: 'MYR ',
              ),
              //readOnly: _selectedStore != null ? false : true,
              controller: _amount,
              validator: (value) {
                if(value.isEmpty) {
                  return 'Price is mandatory';
                } else if(double.parse(value) == 0) {
                  return 'Price must be greater than 0';
                }
                return null;
              },
            ),
            SizedBox(height: 16.0),
            Material(
              child: InkWell(
                onTap: () {
                  setState(() {
                    _promotion = !_promotion;
                  });
                },
                child: Row(
                  children: [
                    Checkbox(
                      value: _promotion, 
                      onChanged: (value) {
                        setState(() {
                          _promotion = value;
                        });
                      }
                    ),
                    Text('On Promotion'),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16.0),
            Visibility(
              visible: _promotion,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        filled: true,
                        border: InputBorder.none,
                        labelText: 'Promotion Start',
                        labelStyle: Theme.of(context).textTheme.bodyText1,
                        prefixIcon: Icon(CommunityMaterialIcons.calendar,
                          color: Theme.of(context).accentColor,
                        )
                      ),
                      readOnly: true,
                      controller: _startDate,
                      onTap: () async {
                        final result = await showDatePicker(
                          context: context, 
                          initialDate: DateTime.now(), 
                          firstDate: DateTime.now().add(Duration(days: -30)), 
                          lastDate: DateTime.now().add(Duration(days: 30))
                        );
                        if(result != null) {
                          _startDate.text = result.toString();
                        }
                      },
                    ),
                  ),
                  SizedBox(width: 16.0),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        filled: true,
                        border: InputBorder.none,
                        labelText: 'Promotion End',
                        labelStyle: Theme.of(context).textTheme.bodyText1,
                        prefixIcon: Icon(CommunityMaterialIcons.calendar,
                          color: Theme.of(context).accentColor,
                        )
                      ),
                      readOnly: true,
                      controller: _endDate,
                      onTap: () async {
                        final result = await showDatePicker(
                          context: context, 
                          initialDate: DateTime.now(), 
                          firstDate: DateTime.now(), 
                          lastDate: DateTime.now().add(Duration(days: 180))
                        );
                        if(result != null) {
                          _endDate.text = result.toString();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save(BuildContext context, Product newProduct) async {
    var _loadingKey = GlobalKey<State>();
    try {
      LoadingDialog.show(_loadingKey, context);
      if(_selectedStore.id == null) {
        final store = await _storeService.create(_selectedStore);
        _selectedStore = store;
      }
      final product = await _productService.create(newProduct);
      if(product != null) {
        final price = await _priceService.create(Price(
          product: product,
          store: _selectedStore,
          seller: _selectedStore.name,
          promotion: false,
          unit: 'PC',
          currency: 'MYR',
          amount: double.parse(_amount.text),
          startDate: DateTime.now()
        ));
        if (price != null) {
          Navigator.of(_loadingKey.currentContext, rootNavigator: true).pop();
          Navigator.pop(context, product);
        }
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