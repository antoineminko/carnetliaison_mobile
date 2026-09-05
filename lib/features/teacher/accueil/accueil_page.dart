import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_mobile/shared/theme/app_theme.dart';
import 'package:app_mobile/shared/widgets/background_wrapper.dart';
import 'package:app_mobile/features/auth/services/ping_service.dart';
import 'package:app_mobile/features/notifications/services/notifications_service.dart';
import 'package:app_mobile/features/teacher/services/teacher_event_service.dart';

import 'package:app_mobile/features/teacher/accueil/viewmodels/accueil_viewmodel.dart';
import 'package:app_mobile/features/teacher/accueil/widgets/dashboard_home_content.dart';

import 'package:app_mobile/features/teacher/messages/teacher_messages_page.dart';
import 'package:app_mobile/features/teacher/messages/chat_page.dart';
import 'package:app_mobile/features/teacher/profil/teacher_profile_page.dart';
import 'package:app_mobile/features/teacher/agenda/evenement/evenements_view.dart';

class TeacherHomePage extends StatefulWidget {
  const TeacherHomePage({super.key});

  @override
  State<TeacherHomePage> createState() => _TeacherHomePageState();
}

class _TeacherHomePageState extends State<TeacherHomePage> {
  late final AccueilViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = AccueilViewModel();
    _viewModel.loadDashboardData();
    NotificationsService().setOnNotificationReceived(() {
      _viewModel.loadDashboardData();
    });
    PingService.startPinging();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_viewModel.argsProcessed) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        _viewModel.processNavigationArgs(args, context);
        if (args['openChat'] == true || args['initialTab'] == 1) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final conversationId = args['openConversationId'] ?? args['conversationId'];
            if (conversationId != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatPage(
                    conversation: {
                      'conversation_id': int.tryParse(conversationId.toString()),
                      'id': int.tryParse(conversationId.toString()),
                      'status': args['conversationStatus'] ?? 'accepted',
                    },
                  ),
                ),
              );
            }
          });
        }
      }
    }
  }

  @override
  void dispose() {
    PingService.stopPinging();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: BackgroundWrapper(
          child: SafeArea(
            child: Selector<AccueilViewModel, int>(
              selector: (context, vm) => vm.currentIndex,
              builder: (context, currentIndex, child) {
                switch (currentIndex) {
                  case 0:
                    return DashboardHomeContent(
                      onShowNotifications: () => _showNotificationsModal(context),
                    );
                  case 1:
                    return TeacherMessagesPage(onRefresh: _viewModel.loadDashboardData);
                  case 2:
                    return const TeacherEventsView();
                  case 3:
                    return const TeacherProfilePage();
                  default:
                    return const Center(child: Text('Erreur'));
                }
              },
            ),
          ),
        ),
        bottomNavigationBar: const _TeacherBottomNav(),
      ),
    );
  }

  void _showNotificationsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Notifications',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              const Text('Aucune nouvelle notification pour le moment.'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Fermer'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TeacherBottomNav extends StatelessWidget {
  const _TeacherBottomNav();

  int _getTotalUnreadMessages(AccueilViewModel viewModel) {
    int total = 0;
    for (var c in viewModel.conversations) {
      if (ChatPage.activeConversationId != null && c['id'] == ChatPage.activeConversationId) {
        continue;
      }
      final val = c['unread_count'];
      total += (val is int) ? val : (int.tryParse(val?.toString() ?? '0') ?? 0);
    }
    return total;
  }

  int _getTotalPendingAppointments(AccueilViewModel viewModel) {
    int total = 0;
    for (var appt in viewModel.appointments) {
      if (appt is Map && appt['statut'] == 'en_attente') {
        final val = appt['unread_count'];
        int unread = (val is int) ? val : (int.tryParse(val?.toString() ?? '0') ?? 0);
        final id = int.tryParse(appt['id']?.toString() ?? '');
        if (id != null && viewModel.viewedAppointmentIds.contains(id)) {
           unread = 0;
        }
        total += unread;
      }
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AccueilViewModel>();
    final currentIndex = viewModel.currentIndex;
    final totalUnreadMessages = _getTotalUnreadMessages(viewModel);
    final totalPendingAppointments = _getTotalPendingAppointments(viewModel);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          viewModel.setIndex(index);
          if (index == 1) {
            for (var c in viewModel.conversations) {
              if (c is Map) {
                c['unread_count'] = 0;
              }
            }
          }
          if (index == 2) {
            for (var appt in viewModel.appointments) {
              if (appt is Map && appt['statut'] == 'en_attente') {
                final id = int.tryParse(appt['id']?.toString() ?? '');
                if (id != null && !viewModel.viewedAppointmentIds.contains(id)) {
                  viewModel.viewedAppointmentIds.add(id);
                  TeacherEventService.instance.markEventAsRead(id);
                }
              }
            }
          }
        },
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.seaBlue,
        unselectedItemColor: Colors.grey[400],
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
        elevation: 0,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: totalUnreadMessages > 0
                ? Badge(
                    label: Text(
                      totalUnreadMessages > 99
                          ? '99+'
                          : totalUnreadMessages.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                    backgroundColor: Colors.red,
                    child: const Icon(Icons.chat_bubble_outline_rounded),
                  )
                : const Icon(Icons.chat_bubble_outline_rounded),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: totalPendingAppointments > 0
                ? Badge(
                    label: Text(
                      totalPendingAppointments > 99
                          ? '99+'
                          : totalPendingAppointments.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                    backgroundColor: Colors.red,
                    child: const Icon(Icons.calendar_today_rounded),
                  )
                : const Icon(Icons.calendar_today_rounded),
            label: 'Événements',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
