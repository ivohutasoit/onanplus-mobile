import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:onanplus/model/model.dart';
import 'package:onanplus/page/market/product_page.dart';
import 'package:onanplus/page/market/store_page.dart';

class PriceCreatePage extends StatefulWidget {
  final Product product;
  final Store store;
  final bool picker;

  PriceCreatePage({Key key, this.product, this.store, this.picker = false }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _PriceCreatePageState();
  }
}

class _PriceCreatePageState extends State<PriceCreatePage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>(debugLabel: 'Product Price Form');
  final _formKey = GlobalKey<FormState>(debugLabel: 'Form');

  final _product = TextEditingController();
  final _store = TextEditingController();
  final _amount = TextEditingController();
  final _startDate = TextEditingController();
  final _endDate = TextEditingController();

  bool _promotion = false;
  Product _selectedProduct;
  Store _selectedStore;

  @override
  void initState() {
    super.initState();
    _selectedProduct = widget.product;
    if(_selectedProduct != null)
      _product.text = _selectedProduct.name;
    _selectedStore = widget.store;
    if(_selectedStore != null)
      _store.text = _selectedStore.name;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('New Product Price'),
        actions: [
          FlatButton(
            color: Theme.of(context).accentColor,
            onPressed: () {
              if(_formKey.currentState.validate()) {
                // final product = Product(
                //   barcode: widget.barcode.trim(),
                //   name: _name.text.trim(),
                //   manufacture: _manufacture.text.trim(),
                //   detail: _detail.text.trim()
                // );
                // _save(_scaffoldKey.currentContext, product);
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
              decoration: InputDecoration(
                filled: true,
                border: InputBorder.none,
                labelText: 'Product',
                labelStyle: Theme.of(context).textTheme.bodyText1,
                prefixIcon: Icon(CommunityMaterialIcons.box,
                  color: Theme.of(context).accentColor,
                ),
              ),
              controller: _product,
              validator: (value) {
                if(value.isEmpty) {
                  return 'product is mandatory';
                }
                return null;
              },
              readOnly: true,
              onTap: () async {
                final result = await Navigator.of(_scaffoldKey.currentContext).push(
                  MaterialPageRoute<Product>(
                    builder: (context) => ProductListPage(picker: true,),
                    fullscreenDialog: true
                  ),
                );
                if(result != null) { 
                  if(result is Product) {
                    print(result);
                    _selectedProduct = result;
                    _product.text = '${_selectedProduct.name}';
                  } 
                }
              },
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

}

class PricePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Show price\'s form or detail with list of stores',
            ),
          ],
        ),
      ),
    );
  }

}