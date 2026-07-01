part of 'parent_home_page.dart';

extension DashboardHeaderViewExtension on _ParentHomePageState {
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isEmptyState ? 'Bienvenue' : 'Enfant(s)',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _isEmptyState ? 'Espace Parent' : 'Portail Multi-Écoles',
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppTheme.textGrey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Row(
            children: [
              InkWell(
                onTap: () => _openNotificationsModal(),
                child: Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.notifications_outlined, size: 28),
                    ),
                    if (_unreadNotificationsCount > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 18,
                            minHeight: 18,
                          ),
                          child: Center(
                            child: Text(
                              '$_unreadNotificationsCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarSection() {
    return SizedBox(
      height: 140,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: _childrenData.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 20),
        itemBuilder: (context, index) {
          if (index == _childrenData.length) {
            return _buildAddAvatar(); // Bouton Ajouter
          }
          final child = _childrenData[index];
          return GestureDetector(
            onTap: () => _onChildSelected(index),
            child: Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: child['color'] as Color,
                        border: Border.all(color: Colors.white, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: (child['isNetworkImage'] == true)
                            ? Image.network(
                                child['image'] as String,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 35,
                                ),
                              )
                            : Image.asset(
                                child['image'] as String,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 35,
                                ),
                              ),
                      ),
                    ),
                    if ((child['notif'] as int) > 0)
                      Positioned(
                        right: -2,
                        top: -2,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Text(
                            '${child['notif']}',
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
                const SizedBox(height: 10),
                Text(
                  child['name'] as String,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(
                    fontWeight: index == 0 ? FontWeight.bold : FontWeight.w500,
                    color: index == 0 ? Colors.blue[800] : Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAddAvatar() {
    return GestureDetector(
      onTap: _showAddChildModal,
      child: Column(
        children: [
          Container(
            width: 60, // Réduit (était 70)
            height: 60,
            margin: const EdgeInsets.only(top: 5), // Alignement visuel
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(
                color: Colors.blueAccent,
                width: 2,
              ), // Bleu rayonnant
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.2),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(Icons.add, color: Colors.blueAccent, size: 28),
          ),
          const SizedBox(height: 15), // Ajusté
          Text(
            'Ajouter',
            style: TextStyle(
              color: Colors.blue[300],
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConvocationBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.sunYellow, AppTheme.sunYellow.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: AppTheme.sunYellow.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Colors.white,
            size: 30,
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'CONVOCATION URGENTE',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  'Mme Eyi (Français) souhaite vous rencontrer pour le suivi de Junior.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppTheme.sunYellow,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'VOIR',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

}
