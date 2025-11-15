import 'package:flutter/material.dart';

class CustomStatusBar extends StatelessWidget {
  const CustomStatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // JAM
          Text(
            "9:41",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          // ICON signal + wifi + battery
          Row(
            children: const [
              Icon(Icons.signal_cellular_alt, size: 20),
              SizedBox(width: 6),
              Icon(Icons.wifi, size: 20),
              SizedBox(width: 6),
              Icon(Icons.battery_5_bar, size: 24),
            ],
          ),
        ],
      ),
    );
  }
}
