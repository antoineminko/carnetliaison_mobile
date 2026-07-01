part of 'parent_home_page.dart';

extension DashboardCardsViewExtension on _ParentHomePageState {
  Widget _buildChildProfileCard(Map<String, dynamic> child) {
    final isVerified = child['is_verified'] ?? false;

    return GestureDetector(
      onTap: () {
        if (!isVerified) {
          _showVerifyChildModal(child);
        } else {
          // Déjà vérifié, on peut soit sélectionner l'enfant, soit ne rien faire
          _onChildSelected(_childrenData.indexOf(child));
        }
      },
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isVerified ? Colors.white : Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[100]!),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: child['color'],
                    image: DecorationImage(
                      image: (child['isNetworkImage'] == true)
                          ? NetworkImage(child['image'] as String)
                          : AssetImage(child['image'] as String) as ImageProvider,
                      fit: BoxFit.cover,
                      colorFilter: isVerified
                          ? null
                          : ColorFilter.mode(
                              Colors.black.withOpacity(0.5),
                              BlendMode.darken,
                            ),
                    ),
                  ),
                ),
                if (!isVerified)
                  const Icon(Icons.lock, color: Colors.white, size: 20),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              child['name'],
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: isVerified ? Colors.black : Colors.grey,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              child['grade'],
              style: TextStyle(
                color: isVerified ? AppTheme.seaBlue : Colors.grey,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddChildCard() {
    return GestureDetector(
      onTap: _showAddChildModal,
      child: Container(
        width: 100, // Carré avec bordure pointillée
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.seaBlue.withOpacity(0.3),
            style: BorderStyle.solid,
          ), // Pointillé simulé par dash non dispo simplement
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.add, color: AppTheme.seaBlue, size: 30),
            const SizedBox(height: 5),
            Text(
              'Ajouter',
              style: TextStyle(
                color: AppTheme.seaBlue,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: AppTheme.seaBlue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.school_rounded,
                size: 80,
                color: AppTheme.seaBlue.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 30),
            Text(
              'Bonjour ${_parentFirstName ?? 'Parent'} 👋',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Aucun enfant associé à votre compte.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[800],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Pour accéder aux informations scolaires,\najoutez un enfant à votre espace parent.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _showAddChildModal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.forestGreen,
                  elevation: 5,
                  shadowColor: AppTheme.forestGreen.withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Ajouter un enfant',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildChildrenList() {
    return Column(
      children: _childrenData.asMap().entries.map((entry) {
        final int index = entry.key;
        final Map<String, dynamic> child = entry.value;
        return ChildCard(
          index: index,
          name: child['name'],
          grade: child['grade'],
          school: child['school'],
          image: child['image'] ?? 'assets/images/profil/eleve1.jpg',
          isNetworkImage: child['isNetworkImage'] == true,
          avatarColor: child['color'] ?? const Color(0xFF2596be),
          notifCount: child['notif'] ?? 0,
          isSelected: _selectedChildIndex == index,
          isVerified: child['is_verified'] ?? false,
          onTap: () => _onChildSelected(index),
          attendanceStatus: child['status'] ?? 'En attente',
        );
      }).toList(),
    );
  }

  Widget _buildAddChildButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: GestureDetector(
        onTap: _showAddChildModal,
        child: Container(
          width: double.infinity,
          height: 60,
          decoration: BoxDecoration(
            color: const Color(0xFFEDF7FF),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: Colors.blue.withOpacity(0.3),
              width: 1.5,
              style: BorderStyle.solid,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.person_add_alt_1_rounded, color: Colors.blue),
              SizedBox(width: 10),
              Text(
                'Ajouter un enfant',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMethodCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

}
