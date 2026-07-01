part of '../accueil/dashboard/parent_home_page.dart';

extension ParentProfileExtension on _ParentHomePageState {
  Widget _buildProfileView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Centré
          Center(
            child: Column(
              children: [
                Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [AppTheme.seaBlue, AppTheme.seaBlue.withOpacity(0.7)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border.all(color: Colors.white, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.seaBlue.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          () {
                            final f = (_parentFirstName ?? '').isNotEmpty ? _parentFirstName![0].toUpperCase() : '';
                            final l = (_parentLastName ?? '').isNotEmpty ? _parentLastName![0].toUpperCase() : '';
                            return '$f$l'.isNotEmpty ? '$f$l' : 'P';
                          }(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Text(
                  '${_parentFirstName ?? ''} ${_parentLastName ?? ''}'.trim().isNotEmpty
                      ? '${_parentFirstName ?? ''} ${_parentLastName ?? ''}'.trim()
                      : 'Votre profil',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Parent d\'élève',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textGrey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // SECTION MES INFORMATIONS
          _buildSectionTitle('MES INFORMATIONS'),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              children: [
                _buildInfoTile(
                  Icons.email_outlined,
                  'EMAIL',
                  (_parentEmail != null && _parentEmail!.isNotEmpty) ? _parentEmail! : 'Non renseigné',
                ),
                const Divider(height: 1, indent: 50),
                _buildInfoTile(
                  Icons.phone_outlined,
                  'TÉLÉPHONE',
                  (_parentPhone != null && _parentPhone!.isNotEmpty) ? _parentPhone! : 'Non renseigné',
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          // SECTION MES ENFANTS
          _buildSectionTitle('ENFANT(S)'),
          SizedBox(
            height: 125, // Augmenté de 110 à 125 pour éviter l'overflow
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: (!_forceAddChild && _childrenData.isNotEmpty)
                  ? _childrenData.length + 1
                  : 1,
              separatorBuilder: (_, __) => const SizedBox(width: 15),
              itemBuilder: (context, index) {
                final bool hasVisibleChildren = !_forceAddChild && _childrenData.isNotEmpty;
                if (_childrenData.isEmpty || _forceAddChild || index == _childrenData.length) {
                  // S'il n'y a pas d'enfant lié, on n'affiche que la carte d'ajout.
                  return _buildAddChildCard();
                }
                return _buildChildProfileCard(_childrenData[index]);
              },
            ),
          ),

          const SizedBox(height: 25),

          // SECTION PREFERENCES
          _buildSectionTitle('PRÉFÉRENCES'),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              children: [
                _buildSwitchTile(
                  'Notifications Push',
                  Icons.notifications_none,
                  _notifPush,
                  (v) => setState(() => _notifPush = v),
                ),
                const Divider(height: 1, indent: 50),
                _buildSwitchTile(
                  'Alertes par SMS',
                  Icons.sms_outlined,
                  _notifSms,
                  (v) => setState(() => _notifSms = v),
                ),
                const Divider(height: 1, indent: 50),
                _buildSwitchTile(
                  'Email',
                  Icons.alternate_email,
                  _notifEmail,
                  (v) => setState(() => _notifEmail = v),
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          // BOUTONS BAS DE PAGE
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.background,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.lock_outline, color: AppTheme.seaBlue),
                ),
                title: const Text(
                  'Changer le mot de passe',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: AppTheme.textGrey,
                ),
                onTap: () {},
              ),
            ),
          ),

          const SizedBox(height: 15),

          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.red.withOpacity(0.1)),
              boxShadow: [
                BoxShadow(color: Colors.red.withOpacity(0.02), blurRadius: 10),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.logout_rounded, color: Colors.red),
                ),
                title: const Text(
                  'Se déconnecter',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Colors.red,
                  ),
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: Colors.redAccent,
                ),
                onTap: () async {
                  await AuthService.logout();
                  if (!context.mounted) return;
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil('/', (route) => false);
                },
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

}
