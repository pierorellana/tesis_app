import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/functional_provider.dart';

class AlertModal extends StatefulWidget {
  final String? summoner;
  const AlertModal({super.key, this.summoner});

  @override
  State<AlertModal> createState() => _AlertModalState();
}

class _AlertModalState extends State<AlertModal> {
  late String summoner;
  @override
  void initState() {
    super.initState();
    summoner = widget.summoner ?? 'normal';
  }

  @override
  Widget build(BuildContext context) {
    final fp = Provider.of<FunctionalProvider>(context);
    final size = MediaQuery.of(context).size;

    return SizedBox(
      height: size.height,
      width: size.width,
      child: Stack(children: fp.alerts),
    );
  }
}
