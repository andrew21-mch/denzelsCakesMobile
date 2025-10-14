import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../shared/theme/app_theme.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Contact Us'),
        backgroundColor: AppTheme.surfaceColor,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.accentColor,
          unselectedLabelColor: AppTheme.textSecondary,
          indicatorColor: AppTheme.accentColor,
          onTap: (index) => HapticFeedback.lightImpact(),
          tabs: const [
            Tab(text: 'Contact', icon: Icon(Icons.contact_support)),
            Tab(text: 'Location', icon: Icon(Icons.location_on)),
            Tab(text: 'Hours', icon: Icon(Icons.access_time)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildContactTab(),
          _buildLocationTab(),
          _buildHoursTab(),
        ],
      ),
    );
  }

  Widget _buildContactTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Quick Contact Options
          _buildQuickContactSection(),

          const SizedBox(height: 24),

          // Contact Form
          _buildContactForm(),
        ],
      ),
    );
  }

  Widget _buildQuickContactSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: AppTheme.cardShadowColor,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Get in Touch',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
          ),
          const SizedBox(height: 16),

          // Phone
          _buildContactOption(
            icon: Icons.phone,
            title: 'Call Us',
            subtitle: '683 252 520',
            onTap: () {
              HapticFeedback.lightImpact();
              _makePhoneCall('683252520');
            },
          ),

          const SizedBox(height: 12),

          // WhatsApp
          _buildContactOption(
            icon: Icons.chat,
            title: 'WhatsApp',
            subtitle: '683 252 520',
            color: const Color(0xFF25D366),
            onTap: () {
              HapticFeedback.lightImpact();
              _openWhatsApp();
            },
          ),

          const SizedBox(height: 12),

          // Email
          _buildContactOption(
            icon: Icons.email,
            title: 'Email',
            subtitle: 'hello@denzelscakes.com',
            onTap: () {
              HapticFeedback.lightImpact();
              _sendEmail();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContactOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: (color ?? AppTheme.accentColor).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: (color ?? AppTheme.accentColor).withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color ?? AppTheme.accentColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppTheme.textTertiary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: AppTheme.cardShadowColor,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Send us a Message',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
            ),
            const SizedBox(height: 16),

            // Name Field
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Your Name',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Email Field
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email Address',
                prefixIcon: Icon(Icons.email_outlined),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (!value.contains('@')) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Subject Field
            TextFormField(
              controller: _subjectController,
              decoration: const InputDecoration(
                labelText: 'Subject',
                prefixIcon: Icon(Icons.subject_outlined),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a subject';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Message Field
            TextFormField(
              controller: _messageController,
              decoration: const InputDecoration(
                labelText: 'Message',
                prefixIcon: Icon(Icons.message_outlined),
                alignLabelWithHint: true,
              ),
              maxLines: 4,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your message';
                }
                return null;
              },
            ),

            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Send Message'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Map Placeholder
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: AppTheme.accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: AppTheme.accentColor.withValues(alpha: 0.3)),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.map,
                    size: 60,
                    color: AppTheme.accentColor,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Interactive Map',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Coming Soon',
                    style: TextStyle(
                      color: AppTheme.textTertiary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Address Details
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: AppTheme.cardShadowColor,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Our Location',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                ),
                const SizedBox(height: 16),
                _buildLocationDetail(
                  icon: Icons.location_on,
                  title: 'Address',
                  subtitle: 'Makepe, Douala\nCameroon',
                ),
                const SizedBox(height: 16),
                _buildLocationDetail(
                  icon: Icons.directions,
                  title: 'Directions',
                  subtitle: 'Opposite Tradex Rhone Poulenc',
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      _openMaps();
                    },
                    icon: const Icon(Icons.directions),
                    label: const Text('Get Directions'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHoursTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: AppTheme.cardShadowColor,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Business Hours',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
            ),
            const SizedBox(height: 16),
            _buildHourRow('Monday', '8:00 AM - 8:00 PM'),
            _buildHourRow('Tuesday', '8:00 AM - 8:00 PM'),
            _buildHourRow('Wednesday', '8:00 AM - 8:00 PM'),
            _buildHourRow('Thursday', '8:00 AM - 8:00 PM'),
            _buildHourRow('Friday', '8:00 AM - 8:00 PM'),
            _buildHourRow('Saturday', '9:00 AM - 9:00 PM'),
            _buildHourRow('Sunday', '10:00 AM - 6:00 PM'),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.accentColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppTheme.accentColor,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'We deliver fresh cakes daily!\nOrder 24 hours in advance for custom cakes.',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                      ),
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

  Widget _buildLocationDetail({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: AppTheme.accentColor,
          size: 24,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHourRow(String day, String hours) {
    final isToday = _isToday(day);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            day,
            style: TextStyle(
              fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
              color: isToday ? AppTheme.accentColor : AppTheme.textPrimary,
            ),
          ),
          Text(
            hours,
            style: TextStyle(
              fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
              color: isToday ? AppTheme.accentColor : AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  bool _isToday(String day) {
    final today = DateTime.now().weekday;
    final days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    return days[today - 1] == day;
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    HapticFeedback.mediumImpact();

    // Compose email with form data
    final String subject = _subjectController.text.trim();
    final String body = '''
Name: ${_nameController.text.trim()}
Email: ${_emailController.text.trim()}

Message:
${_messageController.text.trim()}

---
Sent from DenzelsCakes Mobile App
''';

    final success = await _sendEmailWithContent(subject, body);

    setState(() {
      _isLoading = false;
    });

    if (success) {
      // Clear form only if email was sent successfully
      _nameController.clear();
      _emailController.clear();
      _subjectController.clear();
      _messageController.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Email client opened with your message. Please send the email to complete your inquiry.'),
            backgroundColor: AppTheme.successColor,
            duration: Duration(seconds: 4),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Could not open email client. Please try the direct email option above.'),
            backgroundColor: AppTheme.errorColor,
            duration: Duration(seconds: 4),
          ),
        );
      }
    }
  }

  void _makePhoneCall(String phoneNumber) async {
    // Try different phone URI formats
    final List<String> phoneFormats = [
      'tel:683252520',
      'tel:+237683252520',
      'tel://683252520',
      'tel://+237683252520'
    ];

    bool callMade = false;

    for (String phoneFormat in phoneFormats) {
      try {
        final Uri phoneUri = Uri.parse(phoneFormat);
// print('Trying to launch: $phoneFormat'); // Debug log

        if (await canLaunchUrl(phoneUri)) {
// print('Can launch: $phoneFormat'); // Debug log
          await launchUrl(phoneUri);
          callMade = true;
          break;
        } else {
// print('Cannot launch: $phoneFormat'); // Debug log
        }
      } catch (e) {
// print('Error with $phoneFormat: $e'); // Debug log
        continue;
      }
    }

    if (!callMade) {
      // Last resort - try without checking canLaunchUrl
      try {
        final Uri directUri = Uri.parse('tel:683252520');
        await launchUrl(directUri);
        callMade = true;
      } catch (e) {
// print('Direct launch failed: $e'); // Debug log
        _showErrorMessage(
            'Phone app not available. Please dial 683 252 520 manually.');
      }
    }
  }

  void _showErrorMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppTheme.errorColor,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  void _openWhatsApp() async {
    const phoneNumber = '237683252520'; // Country code + number
    final List<Uri> whatsappUris = [
      Uri.parse('whatsapp://send?phone=$phoneNumber'), // WhatsApp app
      Uri.parse('https://wa.me/$phoneNumber'), // WhatsApp web
      Uri.parse(
          'https://api.whatsapp.com/send?phone=$phoneNumber'), // Alternative web
    ];

    bool opened = false;
    for (final uri in whatsappUris) {
      try {
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          opened = true;
          break;
        }
      } catch (e) {
        // Try next option
        continue;
      }
    }

    if (!opened) {
      _showErrorMessage(
          'WhatsApp not available. Please message us at +237 683 252 520');
    }
  }

  void _sendEmail() async {
    const subject = 'Inquiry from DenzelsCakes App';
    await _sendEmailWithContent(subject, '');
  }

  Future<bool> _sendEmailWithContent(String subject, String body) async {
    const email = 'hello@denzelscakes.com';

    // Create multiple URI formats for better compatibility
    final List<Uri> emailUris = [
      // Standard mailto with subject and body
      Uri(
        scheme: 'mailto',
        path: email,
        query: _buildEmailQuery(subject, body),
      ),
      // Alternative format
      Uri.parse('mailto:$email?${_buildEmailQuery(subject, body)}'),
    ];

    bool opened = false;
    for (final uri in emailUris) {
      try {
// print('Trying email URI: $uri'); // Debug log
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          opened = true;
          break;
        }
      } catch (e) {
// print('Email URI failed: $e'); // Debug log
        continue;
      }
    }

    if (!opened) {
      // Fallback: try simpler mailto without query parameters
      try {
        final simpleUri = Uri.parse('mailto:$email');
        if (await canLaunchUrl(simpleUri)) {
          await launchUrl(simpleUri, mode: LaunchMode.externalApplication);
          opened = true;
        }
      } catch (e) {
// print('Simple mailto failed: $e'); // Debug log
      }
    }

    if (!opened) {
      _showErrorMessage('No email app available. Please email us at $email');
    }

    return opened;
  }

  String _buildEmailQuery(String subject, String body) {
    final Map<String, String> params = {};

    if (subject.isNotEmpty) {
      params['subject'] = subject;
    }

    if (body.isNotEmpty) {
      params['body'] = body;
    }

    return params.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }

  void _openMaps() async {
    const location = 'Makepe, Douala, Cameroon';
    final List<Uri> mapUris = [
      Uri.parse('geo:0,0?q=${Uri.encodeComponent(location)}'), // Android Maps
      Uri.parse(
          'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(location)}'), // Google Maps web
      Uri.parse(
          'https://maps.apple.com/?q=${Uri.encodeComponent(location)}'), // Apple Maps
    ];

    bool opened = false;
    for (final uri in mapUris) {
      try {
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          opened = true;
          break;
        }
      } catch (e) {
        // Try next option
        continue;
      }
    }

    if (!opened) {
      _showErrorMessage('No maps app available. Please search for: $location');
    }
  }
}
