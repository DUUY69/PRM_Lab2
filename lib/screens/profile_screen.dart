import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:printing/printing.dart';
import '../services/analytics_service.dart';
import '../services/pdf_service.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/publication_viewmodel.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
  });

  @override
  State<ProfileScreen> createState() =>
      _ProfileScreenState();
}

class _ProfileScreenState
    extends State<ProfileScreen> {

  Future<void> _exportPdf() async {
    try {
      final publicationProvider =
      context.read<PublicationViewModel>();

      final pdfBytes =
      await PdfService.generateReportBytes(
        topic: publicationProvider.currentTopic,
        papers: publicationProvider.publications,
        journals: publicationProvider.topJournalsOpenAlex,
        authors: publicationProvider.topAuthorsOpenAlex,
        totalPublications:
        publicationProvider.totalOnOpenAlex,
      );

      await AnalyticsService.logExportPdf(
        publicationProvider.currentTopic,
      );

      await Printing.layoutPdf(
        onLayout: (_) async => pdfBytes,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'PDF export completed',
          ),
        ),
      );

    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Export failed: $e',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth =
    context.watch<AuthViewModel>();

    final user =
        auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
        ),
      ),
      body: Padding(
        padding:
        const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage:
              user?.photoURL != null
                  ? NetworkImage(
                user!.photoURL!,
              )
                  : null,
            ),

            const SizedBox(height: 20),

            Text(
              user?.displayName ??
                  'Unknown User',
              style: const TextStyle(
                fontSize: 22,
                fontWeight:
                FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              user?.email ??
                  'No Email',
            ),

            const SizedBox(height: 30),

            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(
                      Icons.picture_as_pdf,
                    ),
                    title: const Text(
                      'Export Research Report',
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                    ),
                    onTap: _exportPdf,
                  ),

                  const Divider(
                    height: 1,
                  ),

                  ListTile(
                    leading: const Icon(
                      Icons.logout,
                    ),
                    title: const Text(
                      'Logout',
                    ),
                    onTap: () async {
                      await auth.signOut();

                      if (context.mounted) {
                        Navigator.pop(
                          context,
                        );
                      }
                    },
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