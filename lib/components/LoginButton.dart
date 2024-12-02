import 'package:flutter/material.dart';

class LongButton extends StatelessWidget {
  final String imageAsset;
  final String title;
  final String description;
  final Color backgroundColor;
  final VoidCallback onTap;

  const LongButton({
    required this.imageAsset,
    required this.title,
    required this.description,
    required this.backgroundColor,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double displayWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Container(
        width: displayWidth,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(displayWidth * .04),
          color: backgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(displayWidth * .03),
            splashColor: const Color.fromARGB(255, 255, 255, 255),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: displayWidth * .03,
                vertical: displayWidth * .02, // Ajusta la altura dinámicamente
              ),
              child: Row(
                children: [
                  Image.asset(
                    imageAsset,
                    width: displayWidth * .22,
                    height: displayWidth * .22,
                    fit: BoxFit.cover,
                  ),
                  SizedBox(width: displayWidth * .05),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: displayWidth * .05,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: displayWidth * .0125),
                        Text(
                          description,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: displayWidth * .06,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
