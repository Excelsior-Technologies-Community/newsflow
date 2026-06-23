import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:get/get.dart';

class ShimmerLoading extends StatelessWidget {
  const ShimmerLoading({super.key});

  @override
  Widget build(BuildContext context) {
    // Fixed colors: use light mode grey variants for both themes
    const Color baseColor = Color(0xFFE0E0E0); // Equivalent to Colors.grey[300]
    const Color highlightColor = Color(0xFFF5F5F5); // Equivalent to Colors.grey[100]

    return ListView.builder(
      itemCount: 5,
      padding: const EdgeInsets.all(15),
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 25),
          child: Shimmer.fromColors(
            baseColor: baseColor,
            highlightColor: highlightColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(height: 15),
                Container(
                  width: 100,
                  height: 15,
                  color: Colors.white,
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  height: 25,
                  color: Colors.white,
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  height: 60,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}