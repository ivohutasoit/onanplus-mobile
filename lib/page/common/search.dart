import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:onanplus/page/common/scanner_page.dart';

class SearchPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: false,
            floating: true,
            //titleSpacing: 0.0,
            //automaticallyImplyLeading: false,
            title: Container(
              height: 36.0,
              child: Material(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.all(Radius.circular(2.0)),
                child: InkWell(
                  borderRadius: BorderRadius.all(Radius.circular(2.0)),
                  onTap: () => print('searching...'),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.only(left: 8.0, right: 8.0),
                        child: Icon(Icons.search,
                          color: Theme.of(context).textTheme.caption.color,
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          readOnly: true,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Search or find something...',
                          ),
                          maxLines: 1,
                        ),
                      ),
                      IconButton(
                        icon: Icon(CommunityMaterialIcons.scanner,
                          size: 20.0,
                          color: Theme.of(context).textTheme.caption.color,
                        ),
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ScannerPage()
                          )
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

}