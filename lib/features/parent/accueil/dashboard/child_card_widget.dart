import 'package:flutter/material.dart';

class ChildCard extends StatelessWidget {
  final int index;
  final String name;
  final String grade;
  final String school;
  final String image;
  final bool isNetworkImage;
  final Color avatarColor;
  final int notifCount;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isVerified;
  final String attendanceStatus; // 'En attente', 'Présent', 'Absent', 'En retard'

  const ChildCard({
    super.key,
    required this.index,
    required this.name,
    required this.grade,
    required this.school,
    required this.image,
    this.isNetworkImage = false,
    required this.avatarColor,
    this.notifCount = 0,
    required this.isSelected,
    required this.onTap,
    this.isVerified = true,
    this.attendanceStatus = 'En attente',
  });

  @override
  Widget build(BuildContext context) {
    final Color primaryThemeColor = const Color(0xFF2596be);
    final Color gradeColor = primaryThemeColor.withOpacity(0.1);
    final Color gradeTextColor = primaryThemeColor;
    final Color badgeColor = primaryThemeColor;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: isSelected
              ? Border.all(color: primaryThemeColor, width: 2)
              : Border.all(color: Colors.grey.withOpacity(0.1), width: 1),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? primaryThemeColor.withOpacity(0.15)
                  : Colors.black.withOpacity(0.08),
              blurRadius: 25,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: avatarColor,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: isNetworkImage
                              ? Image.network(
                                  image,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      const SizedBox(),
                                )
                              : Image.asset(
                                  image,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      const SizedBox(),
                                ),
                        ),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    name,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontSize: 19,
                                      fontWeight: FontWeight.w800,
                                      color: isSelected
                                          ? primaryThemeColor
                                          : Colors.black87,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: gradeColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                grade,
                                style: TextStyle(
                                  color: gradeTextColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Icon(
                                  Icons.school,
                                  size: 16,
                                  color: primaryThemeColor,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    school,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            // Badge statut de présence
                            _buildStatusBadge(),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  Container(
                    width: double.infinity,
                    height: 54,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: isSelected
                              ? primaryThemeColor.withOpacity(0.3)
                              : Colors.grey.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: onTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSelected
                            ? primaryThemeColor
                            : Colors.white,
                        foregroundColor: isSelected
                            ? Colors.white
                            : Colors.black87,
                        elevation: 0,
                        side: isSelected
                            ? BorderSide.none
                            : BorderSide(color: Colors.grey[300]!, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            !isVerified
                                ? 'Scanner pour débloquer'
                                : (isSelected ? 'Sélectionné' : 'Sélectionner'),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Icon(!isVerified ? Icons.lock_outline : Icons.arrow_forward_ios_rounded, size: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            if (notifCount > 0)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(24),
                      bottomLeft: Radius.circular(16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: badgeColor.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    '$notifCount message${notifCount > 1 ? 's' : ''}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    IconData icon;
    Color bgColor;
    Color textColor;
    Color borderColor;

    switch (attendanceStatus) {
      case 'Présent':
        icon = Icons.check_circle_outline;
        bgColor = Colors.green[50]!;
        textColor = Colors.green[700]!;
        borderColor = Colors.green[200]!;
        break;
      case 'Absent':
        icon = Icons.cancel_outlined;
        bgColor = Colors.red[50]!;
        textColor = Colors.red[700]!;
        borderColor = Colors.red[200]!;
        break;
      case 'En retard':
        icon = Icons.watch_later_outlined;
        bgColor = Colors.orange[50]!;
        textColor = Colors.orange[800]!;
        borderColor = Colors.orange[200]!;
        break;
      default: // 'En attente'
        icon = Icons.hourglass_empty_rounded;
        bgColor = Colors.grey[100]!;
        textColor = Colors.grey[600]!;
        borderColor = Colors.grey[300]!;
    }

    // Date du jour formatée
    final now = DateTime.now();
    final months = ['jan', 'fév', 'mar', 'avr', 'mai', 'juin',
                    'juil', 'août', 'sep', 'oct', 'nov', 'déc'];
    final dateStr = '${now.day} ${months[now.month - 1]}';

    return Row(
      children: [
        // Badge statut dans un box coloré
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: textColor),
              const SizedBox(width: 5),
              Text(
                attendanceStatus,
                style: TextStyle(
                  fontSize: 12,
                  color: textColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        // Date sur la même ligne
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.calendar_today_outlined, size: 13, color: Colors.grey[400]),
            const SizedBox(width: 4),
            Text(
              dateStr,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
