# Email to Markdown Converter

## Purpose
Convert `.eml` email files to Markdown format for AI processing and analysis. Automatically extracts and saves email attachments.

## Usage

**Run from project root directory:**

```bash
python3 ".template/aiScripts/emailToMd/eml_to_md_converter.py"
```

The script will:
1. Create `email/raw/`, `email/ai/`, `email/processed/`, and `email/attachments/` directories in project root (if they don't exist)
2. Read all `.eml` files from `email/raw/`
3. Extract and save any attachments to `email/attachments/<email_name>/`
4. Convert emails to Markdown format with attachment references
5. Save converted files to `email/ai/` as `.md` files
6. Move processed `.eml` files to `email/processed/`

## Directory Structure

Script automatically creates these directories in the **project root**:
- `email/raw/` - Place original `.eml` files here
- `email/ai/` - Converted `.md` files output here
- `email/processed/` - Processed `.eml` files moved here
- `email/attachments/` - Extracted attachments stored here (organized by email name)

## Output Format

Converted Markdown files include:
- Subject (as heading)
- From, To, CC, Date metadata
- Email body content (HTML converted to Markdown)
- **Attachments section** (if email contains attachments):
  - Original filename
  - Content type (MIME type)
  - File size (formatted)
  - Relative path to saved attachment

## Attachment Handling

- **Automatic extraction**: All email attachments are automatically extracted and saved
- **Filename sanitization**: Unsafe characters are removed from filenames
- **Duplicate handling**: Numeric suffixes added if filename already exists
- **Organized storage**: Each email's attachments stored in separate subdirectory
- **Metadata tracking**: Attachment details included in converted Markdown

## Notes for AI Agents

1. **Always run from project root**: Script must be executed from the project root directory, not from within `.template/aiScripts/emailToMd/`
2. **Auto-creates directories**: Script automatically creates all required directories in project root
3. **After conversion**: 
   - Verify `.md` files are in `email/ai/` 
   - Check `email/attachments/` for extracted files
   - Confirm original `.eml` files are moved to `email/processed/`
4. **Error handling**: Check script output for any conversion or extraction errors
5. **Dependencies**: Script auto-installs required packages (html2text)
6. **Attachment references**: Converted Markdown files include full attachment metadata and file paths
