## Labki Content Packs (Overview)

This guide explains how Labki will import predefined layouts, templates, and forms from a content repository in future phases.

### Planned Workflow

1. A separate `labki-content` repository will store XML exports for layouts and template/form packs, plus a `manifest.json`.
2. Labki importer extension(s) will provide `Special:LabkiImports` to fetch the manifest and import selected packs using MediaWiki’s `WikiImporter`.
3. Admin-only permission (`labki-import`) will gate imports.

### Repository Structure (planned)

```
labki-content/
├─ manifest.json
├─ layouts/
│  └─ standard_lab_layout.xml
└─ templates/
   └─ ExperimentPack.xml
```

### Current Status

- The importer extension and content repository are not implemented in this initial setup.
- Manual imports can be done via Special:Import if needed for testing.


