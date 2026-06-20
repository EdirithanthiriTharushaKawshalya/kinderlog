import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kinderlog_core/kinderlog_core.dart';
import '../../providers/website_provider.dart';
import '../../data/models/website_models.dart';
import 'admission_form_screen.dart';

/// Public-facing website: branches, curriculum, gallery, testimonials, and admission CTA.
class PublicWebsiteScreen extends StatefulWidget {
  const PublicWebsiteScreen({super.key});

  @override
  State<PublicWebsiteScreen> createState() => _PublicWebsiteScreenState();
}

class _PublicWebsiteScreenState extends State<PublicWebsiteScreen> {
  int _currentTab = 0;

  @override
  Widget build(BuildContext context) {
    return Consumer<WebsiteProvider>(
      builder: (context, web, _) {
        return Scaffold(
          body: CustomScrollView(
            slivers: [
              // App Bar with website navigation
              SliverAppBar(
                expandedHeight: 260,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppTheme.primaryTeal, Color(0xFF0F766E), Color(0xFF115E59)],
                      ),
                    ),
                    child: SafeArea(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: const Icon(Icons.child_care_rounded, size: 48, color: Colors.white),
                            ),
                            const SizedBox(height: 16),
                            const Text('KinderLog Preschool',
                                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                            const SizedBox(height: 4),
                            Text('Nurturing Young Minds Since 2020',
                                style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.8))),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(56),
                  child: Container(
                    color: Colors.white,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _navTab('Home', 0),
                        _navTab('Branches', 1),
                        _navTab('Gallery', 2),
                        _navTab('Admissions', 3),
                      ],
                    ),
                  ),
                ),
              ),

              // Content based on selected tab
              if (_currentTab == 0) _homeTab(web),
              if (_currentTab == 1) _branchesTab(web),
              if (_currentTab == 2) _galleryTab(web),
              if (_currentTab == 3) _admissionsTab(),

              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          ),
        );
      },
    );
  }

  Widget _navTab(String label, int index) {
    final selected = _currentTab == index;
    return GestureDetector(
      onTap: () => setState(() => _currentTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: selected ? AppTheme.primaryTeal : Colors.transparent, width: 2.5)),
        ),
        child: Text(label, style: TextStyle(
          fontWeight: selected ? FontWeight.bold : FontWeight.w500,
          color: selected ? AppTheme.primaryTeal : Colors.grey[600],
          fontSize: 13,
        )),
      ),
    );
  }

  // ---- Home Tab ----
  SliverToBoxAdapter _homeTab(WebsiteProvider web) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Our Philosophy', style: kTitleLarge),
            const SizedBox(height: 8),
            const Text('At KinderLog, we believe every child is unique. Our curriculum fosters curiosity, creativity, and confidence through play-based learning in a safe, nurturing environment.',
                style: kBodyMedium),
            const SizedBox(height: 24),

            // Features grid
            Row(
              children: [
                _featureCard(Icons.school_rounded, 'Qualified Teachers', 'Montessori & ECE certified'),
                const SizedBox(width: 12),
                _featureCard(Icons.security_rounded, 'Safe Environment', 'CCTV & secure access'),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _featureCard(Icons.restaurant_rounded, 'Nutritious Meals', 'Dietician-approved menu'),
                const SizedBox(width: 12),
                _featureCard(Icons.music_note_rounded, 'Arts & Music', 'Daily creative sessions'),
              ],
            ),
            const SizedBox(height: 28),

            // Testimonials
            const Text('What Parents Say', style: kTitleMedium),
            const SizedBox(height: 12),
            SizedBox(
              height: 140,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: web.testimonials.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final t = web.testimonials[index];
                  return Container(
                    width: 280,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: List.generate(5, (i) => Icon(
                          i < t.rating.floor() ? Icons.star_rounded : Icons.star_outline_rounded,
                          size: 16, color: AppTheme.alertAmber,
                        ))),
                        const SizedBox(height: 8),
                        Expanded(child: Text(t.quote, style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic))),
                        Text('— ${t.parentName} (${t.childName})', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _featureCard(IconData icon, String title, String subtitle) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.primaryTeal, size: 28),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), textAlign: TextAlign.center),
            const SizedBox(height: 2),
            Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey[500]), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  // ---- Branches Tab ----
  SliverList _branchesTab(WebsiteProvider web) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final b = web.branches[index];
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(b.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryTeal)),
                  const SizedBox(height: 4),
                  Row(children: [
                    const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(child: Text(b.address, style: const TextStyle(fontSize: 12, color: Colors.black54))),
                  ]),
                  const SizedBox(height: 4),
                  Row(children: [
                    const Icon(Icons.phone_outlined, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(b.phone, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                    const SizedBox(width: 16),
                    const Icon(Icons.email_outlined, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(b.email, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                  ]),
                  const SizedBox(height: 12),
                  Text(b.description, style: const TextStyle(fontSize: 13, height: 1.5, color: Colors.black87)),
                  const SizedBox(height: 12),
                  Text('Classes: ${b.classNames.join(", ")}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[700])),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6, runSpacing: 6,
                    children: b.facilities.map((f) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryTeal.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(f, style: const TextStyle(fontSize: 11, color: AppTheme.primaryTeal, fontWeight: FontWeight.w600)),
                    )).toList(),
                  ),
                ],
              ),
            ),
          );
        },
        childCount: web.branches.length,
      ),
    );
  }

  // ---- Gallery Tab ----
  SliverToBoxAdapter _galleryTab(WebsiteProvider web) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Virtual Tour & Gallery', style: kTitleLarge),
            const SizedBox(height: 4),
            const Text('Explore our facilities, events, and classrooms.', style: kBodyMedium),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: web.galleryCategories.map((cat) {
                final items = web.gallery.where((g) => g.category == cat).toList();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Text(cat.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.primaryTeal)),
                    ),
                    ...items.map((g) => Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white, borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 60, height: 60,
                            decoration: BoxDecoration(
                              color: AppTheme.bgGrey, borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.image_rounded, color: AppTheme.primaryTeal, size: 28),
                          ),
                          const SizedBox(width: 14),
                          Expanded(child: Text(g.caption, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
                        ],
                      ),
                    )),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  // ---- Admissions Tab ----
  SliverToBoxAdapter _admissionsTab() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Admissions', style: kTitleLarge),
            const SizedBox(height: 8),
            const Text('Enroll your child at KinderLog Preschool. Fill out our online application form and our team will review your submission.',
                style: kBodyMedium),
            const SizedBox(height: 24),

            // Admission process steps
            _stepCard('1', 'Submit Application', 'Fill out the online form with your child\'s details, preferred branch, and upload required documents.'),
            const SizedBox(height: 12),
            _stepCard('2', 'Application Review', 'Our management team reviews your application and verifies submitted documents.'),
            const SizedBox(height: 12),
            _stepCard('3', 'Confirmation', 'Once approved, your child is added to the classroom roster automatically.'),
            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.article_rounded),
                label: const Text('Start Application', style: TextStyle(fontSize: 16)),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AdmissionFormScreen()));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stepCard(String num, String title, String desc) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: AppTheme.primaryTeal, borderRadius: BorderRadius.circular(10)),
            child: Center(child: Text(num, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 2),
                Text(desc, style: const TextStyle(fontSize: 12, color: Colors.black54)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
