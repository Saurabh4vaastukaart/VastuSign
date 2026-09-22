# VastuSign architecture

## Product boundary

VastuSign is a clean-room implementation. The reference archive and sample PDF
are used to understand product behaviour only. Production code, rule content,
brand assets, API configuration, and report copy must be original or explicitly
licensed.

## Layers

1. Flutter presents onboarding, analysis, reports, plans, and account flows.
2. `flutter_compass` supplies live heading and accuracy events; camera preview
   is optional and remains on-device.
3. Pure Dart direction logic maps normalized angles to a direction scheme.
4. SQLite stores local profiles, properties, measurements, reports, and the
   optional cloud session.
5. The Node.js API validates authenticated measurements and creates a canonical
   report snapshot.
6. Backend SQLite stores users, properties, measurements, and reports with
   foreign keys and WAL enabled.
7. The mobile PDF service renders the report locally for saving and sharing.

## Direction schemes

Normal utilities use 16 sectors of 22.5 degrees. Main entrances use 32 padas of
11.25 degrees. Sector intervals are start-inclusive and end-exclusive. This
prevents the double matches present when both ends are treated as inclusive.

Every classification records:

- raw heading
- normalized heading
- magnetic or true north mode
- OS-provided accuracy
- calibration quality
- direction/pada result
- distance to the nearest sector boundary
- manual override, if any
- capture time and rule version

## Compass contract

The future platform event channel emits a map shaped like:

```json
{
  "heading": 146.4,
  "accuracy": 2.8,
  "quality": "ready",
  "reference": "magnetic",
  "fieldStrength": 47.2,
  "tilt": 1.6,
  "timestamp": "2026-09-14T10:30:00Z"
}
```

The current Android build reads heading and the platform-provided accuracy from
`flutter_compass`. A manual slider stays available for devices without a
magnetometer. True North is exposed in the interface but a production release
must still add actual declination correction before labeling those values as
true-north measurements.

## State and navigation

Riverpod owns feature state. GoRouter owns URL-like navigation. Business logic
does not read widgets or `BuildContext`, making sector rules and report assembly
independently testable.
