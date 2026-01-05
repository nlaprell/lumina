#!/usr/bin/env python3
"""
Convert notes files (.txt, .md) to standardized Markdown format

Processes notes from notes/raw/ directory:
- Reads .txt and .md files
- Extracts metadata (timestamps, author if available)
- Converts to standardized Markdown format
- Saves to notes/ai/ directory
- Moves originals to notes/processed/

Usage:
    python3 core/aiScripts/notesToMd/notes_to_md_converter.py
"""

import os
import re
import shutil
from pathlib import Path
from datetime import datetime
import sys

# Import logger
try:
    from ..logger import get_logger
    logger = get_logger('notes_converter')
except ImportError:
    # Fallback if running as standalone script
    sys.path.insert(0, str(Path(__file__).parent.parent))
    from logger import get_logger
    logger = get_logger('notes_converter')


def sanitize_filename(filename):
    """Sanitize filename to be safe for filesystem"""
    if not filename:
        return "unnamed_note"

    # Remove path separators and other dangerous characters
    filename = re.sub(r'[<>:"/\\|?*]', '_', filename)

    # Remove leading/trailing dots and spaces
    filename = filename.strip('. ')

    # Limit length to 200 characters
    if len(filename) > 200:
        name, ext = os.path.splitext(filename)
        filename = name[:200-len(ext)] + ext

    return filename if filename else "unnamed_note"


def extract_metadata(content, filename):
    """
    Extract metadata from note content

    Looks for common metadata patterns:
    - Date: YYYY-MM-DD or MM/DD/YYYY
    - Author: Author: Name or By: Name
    - Title: First line or filename

    Returns:
        dict: Metadata with keys: title, author, date, original_filename
    """
    metadata = {
        'title': None,
        'author': None,
        'date': None,
        'original_filename': filename
    }

    lines = content.split('\n')

    # Try to extract title from first non-empty line
    for line in lines:
        stripped = line.strip()
        if stripped and not stripped.startswith('#'):
            # Remove common markdown title markers
            metadata['title'] = stripped.lstrip('#').strip()
            break

    # If no title found, use filename without extension
    if not metadata['title']:
        metadata['title'] = Path(filename).stem

    # Look for author patterns
    author_pattern = r'(?:Author|By|From|Written by):\s*([^\n]+)'
    author_match = re.search(author_pattern, content, re.IGNORECASE)
    if author_match:
        metadata['author'] = author_match.group(1).strip()

    # Look for date patterns
    # Pattern 1: YYYY-MM-DD
    date_pattern1 = r'(\d{4}-\d{2}-\d{2})'
    # Pattern 2: MM/DD/YYYY
    date_pattern2 = r'(\d{1,2}/\d{1,2}/\d{4})'
    # Pattern 3: Month DD, YYYY
    date_pattern3 = r'((?:Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)[a-z]*\s+\d{1,2},?\s+\d{4})'

    for pattern in [date_pattern1, date_pattern2, date_pattern3]:
        date_match = re.search(pattern, content, re.IGNORECASE)
        if date_match:
            metadata['date'] = date_match.group(1)
            break

    # If no date found, use file modification time
    if not metadata['date']:
        try:
            file_path = Path('notes/raw') / filename
            if file_path.exists():
                mtime = file_path.stat().st_mtime
                metadata['date'] = datetime.fromtimestamp(mtime).strftime('%Y-%m-%d')
        except Exception as e:
            logger.warning(f"Could not extract file modification time: {e}")
            metadata['date'] = datetime.now().strftime('%Y-%m-%d')

    return metadata


def convert_note_to_markdown(content, metadata):
    """
    Convert note content to standardized Markdown format

    Args:
        content: Original note content
        metadata: Extracted metadata dict

    Returns:
        str: Formatted Markdown content
    """
    markdown = []

    # Add metadata header
    markdown.append("---")
    markdown.append(f"# Note: {metadata['title']}")
    markdown.append("")

    if metadata.get('author'):
        markdown.append(f"**Author**: {metadata['author']}")

    if metadata.get('date'):
        markdown.append(f"**Date**: {metadata['date']}")

    markdown.append(f"**Source**: {metadata['original_filename']}")
    markdown.append("---")
    markdown.append("")

    # Add content
    # Clean up excessive whitespace
    cleaned_content = re.sub(r'\n{3,}', '\n\n', content.strip())
    markdown.append(cleaned_content)

    return '\n'.join(markdown)


def process_notes_file(source_path, raw_dir, ai_dir, processed_dir):
    """
    Process a single notes file

    Args:
        source_path: Path to source file
        raw_dir: Path to raw directory
        ai_dir: Path to AI directory
        processed_dir: Path to processed directory

    Returns:
        bool: True if successful, False otherwise
    """
    try:
        filename = source_path.name
        logger.info(f"Processing: {filename}")

        # Read file content
        try:
            with open(source_path, 'r', encoding='utf-8') as f:
                content = f.read()
        except UnicodeDecodeError:
            # Try with latin-1 encoding as fallback
            logger.warning(f"UTF-8 decode failed for {filename}, trying latin-1")
            with open(source_path, 'r', encoding='latin-1') as f:
                content = f.read()

        if not content.strip():
            logger.warning(f"Empty file: {filename}")
            return False

        # Extract metadata
        metadata = extract_metadata(content, filename)
        logger.debug(f"Extracted metadata: {metadata}")

        # Convert to markdown
        markdown_content = convert_note_to_markdown(content, metadata)

        # Generate output filename
        base_name = Path(filename).stem
        safe_name = sanitize_filename(base_name)
        output_filename = f"{safe_name}.md"

        # Save to AI directory
        output_path = ai_dir / output_filename
        with open(output_path, 'w', encoding='utf-8') as f:
            f.write(markdown_content)

        logger.info(f"Saved to: {output_path}")

        # Move original to processed directory
        processed_path = processed_dir / filename
        shutil.move(str(source_path), str(processed_path))
        logger.info(f"Moved original to: {processed_path}")

        return True

    except Exception as e:
        logger.error(f"Error processing {source_path.name}: {e}", exc_info=True)
        return False


def main():
    """Main conversion workflow"""
    logger.info("Starting notes to Markdown conversion")

    # Define directory paths
    raw_dir = Path('notes/raw')
    ai_dir = Path('notes/ai')
    processed_dir = Path('notes/processed')

    # Create directories if they don't exist
    for directory in [raw_dir, ai_dir, processed_dir]:
        directory.mkdir(parents=True, exist_ok=True)
        logger.debug(f"Ensured directory exists: {directory}")

    # Find all .txt and .md files in raw directory
    notes_files = list(raw_dir.glob('*.txt')) + list(raw_dir.glob('*.md'))

    if not notes_files:
        logger.info("No notes files found in notes/raw/")
        logger.info("Place .txt or .md files in notes/raw/ to process them")
        return 0

    logger.info(f"Found {len(notes_files)} notes file(s) to process")

    # Process each file
    success_count = 0
    fail_count = 0

    for notes_file in notes_files:
        if process_notes_file(notes_file, raw_dir, ai_dir, processed_dir):
            success_count += 1
        else:
            fail_count += 1

    # Summary
    logger.info("=" * 60)
    logger.info("Conversion Summary:")
    logger.info(f"  Successfully converted: {success_count}")
    logger.info(f"  Failed: {fail_count}")
    logger.info(f"  Output directory: {ai_dir.absolute()}")
    logger.info(f"  Processed files moved to: {processed_dir.absolute()}")
    logger.info("=" * 60)

    return 0 if fail_count == 0 else 1


if __name__ == '__main__':
    sys.exit(main())
