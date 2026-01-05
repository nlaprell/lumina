# Notes to Markdown Converter

Converts notes files (.txt, .md, .docx, .textbundle, .html) to standardized Markdown format for AI processing.

## Features

- Processes `.txt`, `.md`, `.docx`, `.textbundle`, and `.html` files
- **OneNote support**: Extracts text from `.docx` exports with heading preservation
- **Bear support**: Parses `.textbundle` format with metadata preservation
- **Apple Notes support**: Converts HTML exports to clean Markdown
- Extracts metadata:
  - Title (from first line or filename)
  - Author (if present in content)
  - Date (from content or file modification time)
- Converts to standardized Markdown format
- Moves processed files to archive

## Dependencies

```bash
pip install -r core/aiScripts/requirements.txt
```

Required packages:
- `html2text==2024.2.26` - HTML to Markdown conversion
- `python-docx==1.1.0` - OneNote .docx parsing

## Usage

```bash
# From project root
python3 core/aiScripts/notesToMd/notes_to_md_converter.py
```

## Directory Structure

```
notes/
├── raw/         # Place notes files here (.txt, .md, .docx, .textbundle, .html)
├── ai/          # Converted Markdown files (AI-readable)
└── processed/   # Original files after conversion
```

## Workflow

### Apple Notes Export

1. In Apple Notes, select a note and choose **File → Export as PDF... → Export as HTML**
   - Or use **File → Export → Export as HTML**
2. Save the `.html` file to `notes/raw/`
3. Run the converter script
4. Converted notes appear in `notes/ai/` with formatting preserved
5. Original files moved to `notes/processed/`

### Bear Export

1. In Bear, select a note and choose **File → Export Notes**
2. Choose **TextBundle** format
3. Save the `.textbundle` file to `notes/raw/`
4. Run the converter script
5. Converted notes appear in `notes/ai/` with metadata preserved
6. Original files moved to `notes/processed/`

### OneNote Export

1. In OneNote, select **File → Export → Export as Word Document (.docx)**
2. Save the `.docx` file to `notes/raw/`
3. Run the converter script
4. Converted notes appear in `notes/ai/`
5. Original files moved to `notes/processed/`

### Plain Text/Markdown Notes

1. Export notes from your note-taking app
2. Save as `.txt` or `.md` files in `notes/raw/`
3. Run the converter script
4. Converted notes appear in `notes/ai/`
5. Original files moved to `notes/processed/`

## Metadata Extraction

The converter looks for:

### Author
- `Author: Name`
- `By: Name`
- `From: Name`
- `Written by: Name`

### Date
- `YYYY-MM-DD` format
- `MM/DD/YYYY` format
- `Month DD, YYYY` format
- Falls back to file modification time

### Title
- First non-empty line of file
- Falls back to filename (without extension)

## Output Format

```markdown
---
# Note: [Title]

**Author**: [Author Name] (if found)
**Date**: [Date]
**Source**: [Original filename]
---

[Note content with cleaned formatting]
```

## Error Handling

- Handles UTF-8 and Latin-1 encodings
- Skips empty files with warning
- Logs errors with full stack traces
- Continues processing even if individual files fail

## Logging

Logs are written to `logs/notes_converter.log` with:
- File processing status
- Metadata extraction results
- Conversion errors
- Summary statistics

Set `LUMINA_DEBUG=1` for verbose console output.

## Dependencies

Uses standard Python libraries only:
- `pathlib` - File path handling
- `re` - Regular expressions for metadata extraction
- `shutil` - File operations
- `datetime` - Timestamp handling

No external dependencies required.
