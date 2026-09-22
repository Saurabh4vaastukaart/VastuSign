import 'package:flutter/material.dart';

import '../domain/vastu_category.dart';

const demoCategories = <VastuCategory>[
  VastuCategory(
    id: 'main_entrance',
    name: 'Main Entrance',
    hindiName: 'मुख्य द्वार',
    icon: Icons.door_front_door_outlined,
    scheme: DirectionScheme.entrance32,
  ),
  VastuCategory(
    id: 'kitchen',
    name: 'Kitchen',
    hindiName: 'रसोई',
    icon: Icons.soup_kitchen_outlined,
  ),
  VastuCategory(
    id: 'master_bedroom',
    name: 'Master Bedroom',
    hindiName: 'मुख्य शयनकक्ष',
    icon: Icons.bed_outlined,
  ),
  VastuCategory(
    id: 'bedroom',
    name: 'Bedroom',
    hindiName: 'शयनकक्ष',
    icon: Icons.king_bed_outlined,
  ),
  VastuCategory(
    id: 'toilet',
    name: 'Toilet',
    hindiName: 'शौचालय',
    icon: Icons.bathroom_outlined,
  ),
  VastuCategory(
    id: 'pooja_room',
    name: 'Pooja Room',
    hindiName: 'पूजा कक्ष',
    icon: Icons.temple_hindu_outlined,
  ),
  VastuCategory(
    id: 'drawing_room',
    name: 'Drawing Room',
    hindiName: 'बैठक कक्ष',
    icon: Icons.chair_outlined,
  ),
  VastuCategory(
    id: 'dining_room',
    name: 'Dining Room',
    hindiName: 'भोजन कक्ष',
    icon: Icons.table_restaurant_outlined,
  ),
  VastuCategory(
    id: 'study_room',
    name: 'Study Room',
    hindiName: 'अध्ययन कक्ष',
    icon: Icons.menu_book_outlined,
  ),
  VastuCategory(
    id: 'guest_room',
    name: 'Guest Room',
    hindiName: 'अतिथि कक्ष',
    icon: Icons.single_bed_outlined,
  ),
  VastuCategory(
    id: 'staircase',
    name: 'Staircase',
    hindiName: 'सीढ़ियां',
    icon: Icons.stairs_outlined,
  ),
  VastuCategory(
    id: 'office',
    name: 'Home Office',
    hindiName: 'कार्य कक्ष',
    icon: Icons.work_outline_rounded,
  ),
  VastuCategory(
    id: 'balcony',
    name: 'Balcony',
    hindiName: 'बालकनी',
    icon: Icons.balcony_outlined,
  ),
  VastuCategory(
    id: 'washing_area',
    name: 'Washing Area',
    hindiName: 'धुलाई क्षेत्र',
    icon: Icons.local_laundry_service_outlined,
  ),
  VastuCategory(
    id: 'underground_tank',
    name: 'Underground Tank',
    hindiName: 'भूमिगत जल टैंक',
    icon: Icons.water_drop_outlined,
  ),
  VastuCategory(
    id: 'overhead_tank',
    name: 'Overhead Tank',
    hindiName: 'ऊपरी जल टैंक',
    icon: Icons.water_outlined,
  ),
  VastuCategory(
    id: 'septic_tank',
    name: 'Septic Tank',
    hindiName: 'सेप्टिक टैंक',
    icon: Icons.storage_outlined,
  ),
  VastuCategory(
    id: 'electrical',
    name: 'Electrical Zone',
    hindiName: 'विद्युत क्षेत्र',
    icon: Icons.electrical_services_outlined,
  ),
  VastuCategory(
    id: 'store_room',
    name: 'Store Room',
    hindiName: 'भंडार कक्ष',
    icon: Icons.inventory_2_outlined,
  ),
];
