import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_mobile/shared/services/connectivity_service.dart';

class NetworkBanner extends StatelessWidget {
  final Widget child;

  const NetworkBanner({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(
        children: [
          child,
          Consumer<ConnectivityService>(
            builder: (context, connectivity, _) {
              if (connectivity.isOnline) {
                return const SizedBox.shrink();
              }
              return Positioned(
                top: MediaQuery.of(context).padding.top + 10,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade700.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Connexion en cours...',
                          style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
