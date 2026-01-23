// import 'package:flutter/material.dart';
// class RichTextWidget extends StatelessWidget {
//   const RichTextWidget({
//     super.key,
//     this.fontSize = 16,
//     this.textAlign,
//     required this.title,
//     this.fontWeight = FontWeight.w400,
//     this.height,
//     this.color,
//     required this.label,
//     this.istoUpperCase = true,
//   });

//   final String label;
//   final String title;
//   final double? fontSize;
//   final TextAlign? textAlign;
//   final FontWeight? fontWeight;
//   final double? height;
//   final Color? color;
//   final bool? istoUpperCase;

//   @override
//   Widget build(BuildContext context) {
//     return RichText(
//       maxLines: 2,
//       overflow: TextOverflow.ellipsis,
//       text: TextSpan(
//         children: [
//           TextSpan(
//             text: '$label: ',
//             style: TextStyle(
//               color:
//                   color ?? (Theme.of(context).brightness == Brightness.dark
//                       ? AppTheme.whiteText
//                       : AppTheme.dark),
//               fontWeight: FontWeight.bold,
//               fontSize: fontSize,
//               height: height,
//             ),
//           ),
//           TextSpan(
//             text: istoUpperCase == true ? title.toUpperCase() : title,
//             //GlobalHelper.capitalizeEachWord(title),//.toUpperCase(),
//             style: TextStyle(
//               color:
//                   color ?? (Theme.of(context).brightness == Brightness.dark
//                       ? AppTheme.whiteText
//                       : AppTheme.dark),
//               fontWeight: fontWeight,
//               fontSize: fontSize,
//               height: height,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
