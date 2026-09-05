import 'package:flutter/material.dart';

class AttendanceStudentCard extends StatelessWidget {
  final int index;
  final String name;
  final bool hasStatus;
  final Color statusColor;
  final String statusText;
  final bool isLate;
  final String? arrivalTime;
  final VoidCallback onTap;

  const AttendanceStudentCard({
    super.key,
    required this.index,
    required this.name,
    required this.hasStatus,
    required this.statusColor,
    required this.statusText,
    required this.isLate,
    this.arrivalTime,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: !hasStatus ? Colors.white : statusColor,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: !hasStatus ? Colors.grey[300]! : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: [
            if (hasStatus)
              BoxShadow(
                color: statusColor.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: !hasStatus
                    ? Colors.grey[100]
                    : Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: !hasStatus ? Colors.grey[600] : Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: !hasStatus
                          ? Colors.black87
                          : (isLate ? Colors.black87 : Colors.white),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (hasStatus)
                    Text(
                      isLate
                          ? 'Retard: ${arrivalTime ?? ''}'
                          : statusText,
                      style: TextStyle(
                        fontSize: 10,
                        color: isLate ? Colors.black54 : Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
