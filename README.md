
## Usage

```dartimport 'package:devaloop_data_list_page/data_list_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final List<DataItem> db = List.generate(
        25,
        (index) => DataItem(
            title: 'Data ${index + 1}', subtitle: 'Data ${index + 1}'));

    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: DataListPage(
        title: 'Product Inventory',
        subtitle: 'Product Inventory',
        initial: () => Future(() async {
          await Future.delayed(const Duration(seconds: 2));
          return Wrapper(total: db.length, data: db.take(10).toList());
        }),
        showMore: (wrapper) => Future<Wrapper>(() async {
          await Future.delayed(const Duration(seconds: 2));
          return Wrapper(
              total: db.length,
              data: db.take(wrapper.data.length + 10).toList());
        }),
        add: (context) => Future(() async {
          await Future.delayed(const Duration(seconds: 10));
          return IsAdded.yes;
        }),
        search: (context) => Future(() async {
          await Future.delayed(const Duration(seconds: 10));
          var searchKeyWord = [
            KeyWord(
              name: 'name',
              label: 'Name',
              hiddenValue: 'Data',
              showedValue: 'Data',
            ),
            KeyWord(
              name: 'detail',
              label: 'Detail',
              hiddenValue: 'Data',
              showedValue: 'Data',
            ),
          ];
          return MapEntry(
              searchKeyWord,
              SearchWrapper(
                searchResult: Wrapper(total: 20, data: db.take(10).toList()),
                showSearchResultMore: (wrapper, searchKeyWord) => Future(() {
                  return MapEntry(searchKeyWord,
                      Wrapper(total: 20, data: db.take(20).toList()));
                }),
              ));
        }),
      ),
    );
  }
}
```
