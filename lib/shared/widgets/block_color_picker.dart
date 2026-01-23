// import 'package:flutter/material.dart' hide Title;
// import 'package:flutter_colorpicker/flutter_colorpicker.dart';
// import 'package:telcoai_app/env/theme/app_theme.dart';
// import 'package:telcoai_app/shared/providers/configuration_provider.dart';
// import 'package:telcoai_app/shared/widgets/filled_button.dart';
// import 'package:telcoai_app/shared/widgets/outline_button.dart';
// import 'package:telcoai_app/shared/widgets/title.dart';

// Future<Color?> blockColorPicker({required BuildContext context, required Color? pickerColor}) async {

//   Color? color = await showDialog(
//     context: context,
//     builder: (context) {
//       return AlertDialog(
//         title: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Title(title: context.loc.colorsText, textAlign: TextAlign.center, fontSize: 25),
//               IconButton.filledTonal(
//               style: ButtonStyle(
//                 backgroundColor: WidgetStatePropertyAll(
//                   Theme.brightnessOf(context) == Brightness.dark 
//                   ? AppTheme.gray24 
//                   : AppTheme.secondary2Color
//                 )
//               ),
//               color: AppTheme.titleShowModalBotton,
//               icon: Icon(Icons.invert_colors_off_rounded),
//               onPressed: () {
//                 pickerColor == null;
//                 Navigator.pop(context);
//               },
//             ),
//           ],
//         ),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.end,
//           children: [
//             // IconButton.filledTonal(
//             //   style: ButtonStyle(
//             //     backgroundColor: WidgetStatePropertyAll(
//             //       Theme.brightnessOf(context) == Brightness.dark 
//             //       ? AppTheme.gray24 
//             //       : AppTheme.secondary2Color
//             //     )
//             //   ),
//             //   color: AppTheme.titleShowModalBotton,
//             //   icon: Icon(Icons.invert_colors_off_rounded),
//             //   onPressed: () {
//             //     pickerColor == null;
//             //     Navigator.pop(context);
//             //   },
//             // ),
//             SizedBox(height: 15),
//             BlockPicker(
//               availableColors: AppTheme.availableColors,
//               itemBuilder: (color, isCurrentColor, changeColor) => pickerItemBuilder(context, color, isCurrentColor, changeColor),
//               layoutBuilder: pickerLayoutBuilder,
//               onColorChanged: (value) {
//                 pickerColor = value;
//               },
//               pickerColor: pickerColor
//             ),
//           ],
//         ),
//         actions: [
//           OutlineButtonWidget(
//             width: 80,
//             title: context.loc.cancelText,
//             onPressed: () => Navigator.pop(context),
//           ),
//           FilledButtonWidget(
//             width: 80,
//             text: context.loc.confirmText,
//             textButtonColor: Theme.brightnessOf(context) == Brightness.dark
//                 ? AppTheme.titleShowModalBotton
//                 : AppTheme.dark,
//             color: Theme.brightnessOf(context) == Brightness.dark
//                 ? AppTheme.backgroundColorBlueblack
//                 : Colors.grey[300],
//             onPressed: () => Navigator.pop(context, pickerColor),
//           ),
//         ],
//       );
//     },
//   );

//   if (color == null) return null;
//   return color;
// }

//   double _borderRadius = 30;
//   double _iconSize = 24;
//   int _portraitCrossAxisCount = 4;
//   int _landscapeCrossAxisCount = 5;

//   Widget pickerLayoutBuilder(BuildContext context, List<Color> colors, PickerItem child) {
//     Orientation orientation = MediaQuery.of(context).orientation;

//     return SizedBox(
//       width: 300,
//       height: orientation == Orientation.portrait ? 280 : 240,
//       child: GridView.count(
//         crossAxisCount: orientation == Orientation.portrait ? _portraitCrossAxisCount : _landscapeCrossAxisCount,
//         crossAxisSpacing: 5,
//         mainAxisSpacing: 5,
//         physics: NeverScrollableScrollPhysics(),
//         children: [for (Color color in colors) child(color)],
//       ),
//     );
//   }

//   Widget pickerItemBuilder(BuildContext context, Color color, bool isCurrentColor, void Function() changeColor) {
//   return Column(
//     mainAxisSize: MainAxisSize.min,
//     spacing: 2,
//     children: [
//       Container(
//         width: 44, 
//         height: 44,
//         //margin: const EdgeInsets.all(4),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(_borderRadius),
//           color: color,
//         ),
//         child: Material(
//           elevation: 0,
//           color: Colors.transparent,
//           child: InkWell(
//             onTap: changeColor,
//             borderRadius: BorderRadius.circular(_borderRadius),
//             child: Center(
//               child: AnimatedOpacity(
//                 duration: const Duration(milliseconds: 250),
//                 opacity: isCurrentColor ? 1 : 0,
//                 child: Icon(
//                   Icons.done,
//                   size: _iconSize,
//                   color: useWhiteForeground(color) ? Colors.white : Colors.black,
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//       SizedBox(
//         width: 60,
//         child: Title(
//           title: context.loc.language == "es" ? AppTheme.colorNamesEs[color].toString().toUpperCase() : AppTheme.colorNamesEn[color].toString().toUpperCase(),
//           fontSize: 12.5,
//           textAlign: TextAlign.center,
//         ),
//       ),
//     ],
//   );
// }
