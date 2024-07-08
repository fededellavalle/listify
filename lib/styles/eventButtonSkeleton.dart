import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class EventButtonSkeleton extends StatelessWidget {
  final double scaleFactor;

  EventButtonSkeleton({required this.scaleFactor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: 8 * scaleFactor, horizontal: 16 * scaleFactor),
      child: Shimmer.fromColors(
        baseColor: Colors.blueGrey.withOpacity(0.1),
        highlightColor: Colors.grey.shade800,
        child: Container(
          padding: EdgeInsets.all(16 * scaleFactor),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(12 * scaleFactor),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 4 * scaleFactor,
                offset: Offset(0, 2 * scaleFactor),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 50 * scaleFactor,
                height: 80 * scaleFactor,
                decoration: BoxDecoration(
                  color: Colors.grey[850],
                  borderRadius: BorderRadius.circular(12 * scaleFactor),
                ),
              ),
              SizedBox(width: 16 * scaleFactor),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 16 * scaleFactor,
                      color: Colors.grey[850],
                    ),
                    SizedBox(height: 4 * scaleFactor),
                    Container(
                      width: 100 * scaleFactor,
                      height: 14 * scaleFactor,
                      color: Colors.grey[850],
                    ),
                    SizedBox(height: 2 * scaleFactor),
                    Container(
                      width: 80 * scaleFactor,
                      height: 14 * scaleFactor,
                      color: Colors.grey[850],
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey[850]),
            ],
          ),
        ),
      ),
    );
  }
}
