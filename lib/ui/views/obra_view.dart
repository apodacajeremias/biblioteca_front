import 'package:biblioteca_front/constants.dart';
import 'package:biblioteca_front/models/obra.dart';
import 'package:biblioteca_front/providers/obra_provider.dart';
import 'package:biblioteca_front/providers/search_provider.dart';
import 'package:biblioteca_front/ui/shared/my_elevated_button.dart';
import 'package:biblioteca_front/ui/shared/my_view_title.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';

enum ObraViewType {
  // ignore: constant_identifier_names
  DISPONIBLES('/obras/disponibles', 'Libros disponibles'),
  DEVUELTOS('/obras/devueltos', 'Libros devueltos'),
  PRESTADOS('/obras/prestados', 'Libros prestados');

// URL para buscar la lista segun modalidad
  final String source;
  final String titulo;

  const ObraViewType(this.source, this.titulo);
}

class ObraView extends StatefulWidget {
  final ObraViewType type;

  const ObraView({super.key, required this.type});

  // const ObraView(
  //     {super.key,
  //     required this.titulo,
  //     required this.onSearch,
  //     required this.onFutureLoad});

  @override
  State<ObraView> createState() => _ObraViewState();
}

class _ObraViewState extends State<ObraView> {
  static const _pageSize = 100;

  final PagingController<int, Obra> _pagingController =
      PagingController(firstPageKey: 0);

  @override
  void initState() {
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(
          pageKey, Provider.of<SearchProvider>(context, listen: false).query);
    });
    super.initState();
  }

  Future<void> _fetchPage(int pageKey, String query) async {
    int pageNumber = (pageKey / _pageSize) as int;
    try {
      final newItems = await Provider.of<ObraProvider>(context, listen: false)
          .buscar(widget.type.source,
              page: pageNumber, size: _pageSize, query: query);
      final isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + newItems.length;
        _pagingController.appendPage(newItems, nextPageKey as int?);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Cada vez que se escriba algo en la barra de busqueda, la lista cambia
    Provider.of<SearchProvider>(context);
    _pagingController.refresh();
    return Column(
      children: [
        MyViewTitle(title: widget.type.titulo),
        Expanded(
          child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: defaultPadding, vertical: defaultPadding / 2),
              child: PagedListView<int, Obra>(
                pagingController: _pagingController,
                builderDelegate: PagedChildBuilderDelegate<Obra>(
                  itemBuilder: (context, item, index) => _ObraItem(
                    obra: item,
                  ),
                ),
              )),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }
}

class _ObraItem extends StatelessWidget {
  final Obra obra;

  const _ObraItem({required this.obra});

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(
        obra.nombre ?? '',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      subtitle: Text(
        obra.autor ?? '',
        style: Theme.of(context).textTheme.displaySmall,
      ),
      trailing: MyElevatedButton.done(onPressed: () {}),
      children: [
        if (obra.editorial != null) ...[
          Padding(
            padding: const EdgeInsets.all(defaultPadding / 2),
            child: Text(
              obra.editorial ?? '',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontSize: 12),
            ),
          ),
        ],
        if (obra.sinopsis != null) ...[
          Text(
            'Sinopsis:',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          Padding(
            padding: const EdgeInsets.all(defaultPadding / 2),
            child: Text(
              obra.sinopsis!,
              style: Theme.of(context).textTheme.displaySmall,
            ),
          ),
        ]
      ],
    );
  }
}
