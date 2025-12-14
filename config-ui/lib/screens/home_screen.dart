import 'package:flutter/material.dart';
import 'package:config_ui/models/config_model.dart';
import 'package:config_ui/services/config_service.dart';
import 'package:config_ui/screens/jira_config_screen.dart';
import 'package:config_ui/screens/ai_config_screen.dart';
import 'package:config_ui/screens/advanced_config_screen.dart';
import 'package:config_ui/screens/new_tab_screen.dart';
import 'package:config_ui/widgets/save_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ConfigModel _config;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isSaved = false;
  String? _errorMessage;
  final ConfigService _configService = ConfigService();
  
  @override
  void initState() {
    super.initState();
    _loadConfig();
  }
  
  Future<void> _loadConfig() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final config = await _configService.loadConfig();
      print('Loaded config in HomeScreen:');
      print('  jiraBasePath: ${config.jiraBasePath}');
      print('  jiraEmail: ${config.jiraEmail}');
      print('  aiApiKey: ${config.aiApiKey?.substring(0, config.aiApiKey!.length.clamp(0, 20))}...');
      
      setState(() {
        _config = config;
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      print('Error loading config: $e');
      print('Stack trace: $stackTrace');
      setState(() {
        _errorMessage = 'Failed to load configuration: $e';
        _isLoading = false;
      });
    }
  }
  
  Future<void> _saveConfig() async {
    setState(() {
      _isSaving = true;
      _isSaved = false;
      _errorMessage = null;
    });
    
    try {
      // Validate configuration
      final errors = _config.validate();
      if (errors.isNotEmpty) {
        setState(() {
          _errorMessage = errors.join('\n');
          _isSaving = false;
        });
        return;
      }
      
      await _configService.saveConfig(_config);
      
      setState(() {
        _isSaving = false;
        _isSaved = true;
        _errorMessage = null;
      });
      
      // Reset saved status after 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _isSaved = false;
          });
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to save configuration: $e';
        _isSaving = false;
      });
    }
  }
  
  void _onConfigChanged(ConfigModel newConfig) {
    setState(() {
      _config = newConfig;
      _isSaved = false; // Reset saved status when config changes
    });
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('OrbitHub Configuration'),
          bottom: TabBar(
            labelColor: Colors.white, // White selected tab
            unselectedLabelColor: const Color(0xFFB0B0B0), // Muted grey unselected tab
            indicatorColor: const Color(0xFF2196F3), // Blue indicator
            tabs: const [
              Tab(icon: Icon(Icons.bug_report), text: 'Jira'),
              Tab(icon: Icon(Icons.psychology), text: 'AI'),
              Tab(icon: Icon(Icons.settings), text: 'Advanced'),
              Tab(icon: Icon(Icons.tab), text: 'New Tab'),
            ],
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: TabBarView(
                children: [
                  JiraConfigScreen(
                    config: _config,
                    onConfigChanged: _onConfigChanged,
                  ),
                  AIConfigScreen(
                    config: _config,
                    onConfigChanged: _onConfigChanged,
                  ),
                  AdvancedConfigScreen(
                    config: _config,
                    onConfigChanged: _onConfigChanged,
                  ),
                  const NewTabScreen(),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E), // Card background
                border: Border(
                  top: BorderSide(
                    color: const Color(0xFF424242), // Subtle divider
                    width: 1,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SaveButton(
                onPressed: _saveConfig,
                isLoading: _isSaving,
                isSuccess: _isSaved,
                errorMessage: _errorMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

