import 'package:flutter/material.dart';
import 'package:kinderlog_core/kinderlog_core.dart';
import '../data/models/website_models.dart';

/// Manages public website content, branches, gallery, and testimonials.
class WebsiteProvider extends ChangeNotifier {
  List<BranchPublicInfo> _branches = [];
  List<GalleryItem> _gallery = [];
  List<Testimonial> _testimonials = [];
  bool _isLoading = false;

  List<BranchPublicInfo> get branches => _branches;
  List<GalleryItem> get gallery => _gallery;
  List<Testimonial> get testimonials => _testimonials;
  bool get isLoading => _isLoading;

  List<String> get galleryCategories =>
      _gallery.map((g) => g.category).toSet().toList()..sort();

  WebsiteProvider() {
    _initMockData();
  }

  void _initMockData() {
    _branches = [
      BranchPublicInfo(
        branchId: 'branch_01',
        name: 'Ambalangoda',
        address: '123 Galle Road, Ambalangoda',
        phone: '+94 91 225 6789',
        email: 'ambalangoda@kinderlog.com',
        description: 'Our flagship campus in the heart of Ambalangoda, featuring state-of-the-art classrooms, a vibrant outdoor play area, and a dedicated arts & crafts studio.',
        facilities: ['Air-conditioned classrooms', 'Outdoor playground', 'Arts & crafts studio', 'Nap room', 'CCTV security', 'Medical room'],
        heroImageUrl: '',
        classNames: ['FS1', 'FS2', 'Yellow', 'Green'],
      ),
      BranchPublicInfo(
        branchId: 'branch_02',
        name: 'Hikkaduwa',
        address: '45 Beach Road, Hikkaduwa',
        phone: '+94 91 226 1234',
        email: 'hikkaduwa@kinderlog.com',
        description: 'Our coastal campus in Hikkaduwa, offering a unique learning environment with a nature garden, music room, and spacious classrooms with ocean views.',
        facilities: ['Nature garden', 'Music & movement room', 'Spacious classrooms', 'Library corner', 'CCTV security', 'Medical room'],
        heroImageUrl: '',
        classNames: ['FS1', 'FS2'],
      ),
    ];

    _gallery = [
      GalleryItem(id: 'gal_1', imageUrl: '', caption: 'Ambalangoda — Outdoor Playground', category: 'facilities'),
      GalleryItem(id: 'gal_2', imageUrl: '', caption: 'Hikkaduwa — Nature Garden', category: 'facilities'),
      GalleryItem(id: 'gal_3', imageUrl: '', caption: 'Annual Sports Day 2026', category: 'events'),
      GalleryItem(id: 'gal_4', imageUrl: '', caption: 'Art Exhibition — FS1 Students', category: 'events'),
      GalleryItem(id: 'gal_5', imageUrl: '', caption: 'FS2 Classroom — Reading Corner', category: 'classroom'),
      GalleryItem(id: 'gal_6', imageUrl: '', caption: 'Yellow Class — Group Activity', category: 'classroom'),
      GalleryItem(id: 'gal_7', imageUrl: '', caption: 'Fire Drill Practice', category: 'safety'),
      GalleryItem(id: 'gal_8', imageUrl: '', caption: 'CCTV Monitoring Station', category: 'safety'),
    ];

    _testimonials = [
      Testimonial(id: 'tst_1', parentName: 'Nimal Perera', childName: 'Amaya', quote: 'KinderLog has been a wonderful experience for our daughter. The teachers are caring and communicative.', rating: 5.0),
      Testimonial(id: 'tst_2', parentName: 'Sarah Johnson', childName: 'Emma', quote: 'The allergy safety protocols gave us peace of mind. Emma loves going to school every day!', rating: 5.0),
      Testimonial(id: 'tst_3', parentName: 'Raj Patel', childName: 'Aanya', quote: 'As newcomers, the staff made the transition so smooth. Highly recommend the Hikkaduwa branch.', rating: 4.5),
    ];
  }

  void addTestimonial(Testimonial t) {
    _testimonials.add(t);
    notifyListeners();
  }
}
