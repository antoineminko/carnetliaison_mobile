import re

file_path = 'lib/features/parent/widgets/child_details_view.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Add _dashboardData and _fetchDashboard
state_class_start = r"class _ChildDetailsViewState extends State<ChildDetailsView>\s+with SingleTickerProviderStateMixin \{"
state_vars = '''
  late TabController _tabController;
  Map<String, dynamic>? _dashboardData;
  bool _isLoadingDashboard = false;

  Future<void> _fetchDashboard() async {
    if (widget.child['fromApi'] != true) return;
    
    setState(() => _isLoadingDashboard = true);
    try {
      final id = widget.child['id'];
      final response = await ApiClient.dio.get('/eleves//dashboard');
      if (mounted) {
        setState(() {
          _dashboardData = response.data;
          _isLoadingDashboard = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingDashboard = false);
    }
  }
'''

content = re.sub(
    r"late TabController _tabController;",
    state_vars.strip(),
    content
)

# Add _fetchDashboard to initState
init_state_replacement = '''
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
    _fetchDashboard();
  }
'''

content = re.sub(
    r"@override\s+void initState\(\) \{\s+super\.initState\(\);\s+_tabController = TabController\(length: 7, vsync: this\);\s+\}",
    init_state_replacement.strip(),
    content
)

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)
