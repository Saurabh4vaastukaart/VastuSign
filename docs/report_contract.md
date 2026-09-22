# Report data contract

The mobile app sends measurements, not ready-made report paragraphs. The API
normalizes and validates them, evaluates the published rule set, and freezes an
immutable JSON report snapshot before PDF rendering.

## Core payload

```json
{
  "analysisId": "uuid",
  "propertyId": "uuid",
  "language": "hi-en",
  "northReference": "magnetic",
  "measurements": [
    {
      "utilityId": "main_entrance",
      "heading": 206.2,
      "accuracy": 2.4,
      "quality": "ready",
      "capturedAt": "2026-09-14T10:30:00Z"
    }
  ]
}
```

## Canonical report snapshot

```json
{
  "reportId": "uuid",
  "ruleSetVersion": "2026.09.1",
  "scoringVersion": "score-v1",
  "templateVersion": "report-v1",
  "overallScore": 68,
  "summary": {
    "critical": 2,
    "attention": 3,
    "positive": 4
  },
  "observations": [
    {
      "utilityId": "main_entrance",
      "heading": 206.2,
      "direction": "S7",
      "broadDirection": "SSW",
      "boundaryUncertain": false,
      "score": 40,
      "rating": "critical",
      "effects": [],
      "remedies": [],
      "priority": 1,
      "difficulty": "structural"
    }
  ]
}
```

## Database entities

- `users`
- `properties`
- `analyses`
- `measurements`
- `utilities`
- `direction_schemes`
- `direction_sectors`
- `rule_sets`
- `rules`
- `effects`
- `remedies`
- `products`
- `report_templates`
- `reports`
- `orders`

Reports store the complete evaluated snapshot, not only a URL. A signed private
storage URL can then be regenerated without rerunning newer rules against an old
analysis.

