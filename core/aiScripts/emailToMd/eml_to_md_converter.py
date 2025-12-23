#!/usr/bin/env python3
"""
Convert .eml files to Markdown format
"""

import email
import base64
import re
import os
import subprocess
from pathlib import Path
import sys
from email.header import decode_header

# Check and install dependencies
def check_dependencies():
    """Check if required packages are installed and install if missing"""
    required_packages = ['html2text']

    for package in required_packages:
        try:
            __import__(package)
        except ImportError:
            print(f"Installing missing dependency: {package}")
            try:
                subprocess.check_call([sys.executable, '-m', 'pip', 'install', '--user', package])
                print(f"Successfully installed {package}")
                # Reload sys.path to pick up newly installed packages
                import site
                import importlib
                importlib.reload(site)
            except subprocess.CalledProcessError as e:
                print(f"Error installing {package}: {str(e)}")
                sys.exit(1)

# Run dependency check
check_dependencies()

import html2text

def decode_email_header(header):
    """Decode email headers that might be encoded"""
    if header is None:
        return ''
    decoded_parts = decode_header(header)
    decoded_string = ''
    for part, encoding in decoded_parts:
        if isinstance(part, bytes):
            if encoding:
                decoded_string += part.decode(encoding)
            else:
                decoded_string += part.decode('utf-8', errors='ignore')
        else:
            decoded_string += part
    return decoded_string

def extract_email_content(msg):
    """Extract text content from email message"""
    body_text = ''
    body_html = ''

    if msg.is_multipart():
        for part in msg.walk():
            content_type = part.get_content_type()
            content_disposition = str(part.get('Content-Disposition'))

            if content_type == 'text/plain' and 'attachment' not in content_disposition:
                charset = part.get_content_charset() or 'utf-8'
                content = part.get_payload(decode=True)
                if content:
                    try:
                        body_text = content.decode(charset, errors='ignore')
                    except:
                        body_text = str(content)
                    break  # Use first plain text part

            elif content_type == 'text/html' and 'attachment' not in content_disposition and not body_text:
                charset = part.get_content_charset() or 'utf-8'
                content = part.get_payload(decode=True)
                if content:
                    try:
                        body_html = content.decode(charset, errors='ignore')
                    except:
                        body_html = str(content)
    else:
        content = msg.get_payload(decode=True)
        if content:
            content_type = msg.get_content_type()
            charset = msg.get_content_charset() or 'utf-8'
            try:
                if content_type == 'text/html':
                    body_html = content.decode(charset, errors='ignore')
                else:
                    body_text = content.decode(charset, errors='ignore')
            except:
                body_text = str(content)

    # Convert HTML to text if we have HTML but no plain text
    if body_html and not body_text:
        h = html2text.HTML2Text()
        h.ignore_links = False
        h.body_width = 0  # Don't wrap lines
        body_text = h.handle(body_html)

    return body_text

def clean_email_body(body_text):
    """Clean up the email body text"""
    if not body_text:
        return ""

    # Remove excessive newlines
    body_text = re.sub(r'\n{3,}', '\n\n', body_text)

    # Remove leading/trailing whitespace
    body_text = body_text.strip()

    return body_text

def sanitize_filename(filename):
    """Sanitize filename to be safe for filesystem"""
    if not filename:
        return "unnamed_attachment"

    # Remove path separators and other dangerous characters
    filename = re.sub(r'[<>:"/\\|?*]', '_', filename)

    # Remove leading/trailing dots and spaces
    filename = filename.strip('. ')

    # Limit length to 200 characters
    if len(filename) > 200:
        name, ext = os.path.splitext(filename)
        filename = name[:200-len(ext)] + ext

    return filename if filename else "unnamed_attachment"

def extract_attachments(msg, attachments_dir, email_name):
    """Extract attachments from email and save to disk

    Returns list of attachment metadata dicts with keys:
    - original_name: Original filename from email
    - saved_name: Sanitized filename saved to disk
    - saved_path: Relative path to attachment
    - size: Size in bytes
    - content_type: MIME type
    """
    attachments = []

    # Create email-specific subdirectory
    email_attachments_dir = attachments_dir / email_name
    email_attachments_dir.mkdir(parents=True, exist_ok=True)

    for part in msg.walk():
        content_disposition = str(part.get('Content-Disposition', ''))

        # Check if this part is an attachment
        if 'attachment' in content_disposition:
            # Get filename
            filename = part.get_filename()
            if filename:
                filename = decode_email_header(filename)
            else:
                # Generate filename from content type
                ext = part.get_content_type().split('/')[-1]
                filename = f"attachment_{len(attachments) + 1}.{ext}"

            # Sanitize filename
            safe_filename = sanitize_filename(filename)

            # Get attachment data
            try:
                payload = part.get_payload(decode=True)
                if payload:
                    # Save to disk
                    attachment_path = email_attachments_dir / safe_filename

                    # Handle duplicate filenames
                    counter = 1
                    while attachment_path.exists():
                        name, ext = os.path.splitext(safe_filename)
                        safe_filename = f"{name}_{counter}{ext}"
                        attachment_path = email_attachments_dir / safe_filename
                        counter += 1

                    with open(attachment_path, 'wb') as f:
                        f.write(payload)

                    # Store metadata
                    attachments.append({
                        'original_name': filename,
                        'saved_name': safe_filename,
                        'saved_path': f"email/attachments/{email_name}/{safe_filename}",
                        'size': len(payload),
                        'content_type': part.get_content_type()
                    })

                    print(f"  Extracted attachment: {filename} ({len(payload)} bytes)")

            except Exception as e:
                print(f"  Warning: Could not extract attachment {filename}: {str(e)}")

    return attachments

def format_attachment_section(attachments):
    """Format attachments metadata for Markdown output"""
    if not attachments:
        return ""

    section = "\n\n---\n\n## Attachments\n\n"

    for att in attachments:
        # Format size
        size_bytes = att['size']
        if size_bytes < 1024:
            size_str = f"{size_bytes} B"
        elif size_bytes < 1024 * 1024:
            size_str = f"{size_bytes / 1024:.1f} KB"
        else:
            size_str = f"{size_bytes / (1024 * 1024):.1f} MB"

        # Add attachment entry
        section += f"- **{att['original_name']}**\n"
        section += f"  - Type: `{att['content_type']}`\n"
        section += f"  - Size: {size_str}\n"
        section += f"  - Location: `{att['saved_path']}`\n\n"

    return section


def validate_email_file(eml_file_path):
    """Validate that email file is parseable before processing
    
    Returns: (valid, error_message)
    - valid: True if email is parseable, False otherwise
    - error_message: None if valid, error description if invalid
    """
    try:
        with open(eml_file_path, 'rb') as f:
            msg = email.message_from_binary_file(f)
            
            # Check for required headers
            if not msg.get('Subject'):
                return False, "Email missing Subject header"
            
            if not msg.get('From'):
                return False, "Email missing From header"
            
            # Validate file is not empty
            if not msg.get_payload():
                return False, "Email has no content"
            
        return True, None
        
    except Exception as e:
        return False, f"Failed to parse email: {str(e)}"


def convert_eml_to_md(eml_file_path, output_dir, attachments_dir=None):
    """Convert a single .eml file to Markdown
    
    Returns: (success, md_file_path, error_message)
    - success: True if conversion succeeded, False otherwise
    - md_file_path: Path to created Markdown file if successful, None otherwise
    - error_message: None if successful, error description if failed
    """
    md_file_path = None
    
    try:
        # Read the .eml file
        with open(eml_file_path, 'r', encoding='utf-8', errors='ignore') as f:
            raw_email = f.read()

        # Parse the email
        msg = email.message_from_string(raw_email)

        # Extract headers
        from_addr = decode_email_header(msg.get('From'))
        to_addr = decode_email_header(msg.get('To'))
        cc_addr = decode_email_header(msg.get('CC'))
        subject = decode_email_header(msg.get('Subject'))
        date = decode_email_header(msg.get('Date'))

        # Extract body
        body_text = extract_email_content(msg)
        body_text = clean_email_body(body_text)

        # Extract attachments if directory provided
        attachments = []
        if attachments_dir:
            eml_filename = Path(eml_file_path).stem
            attachments = extract_attachments(msg, attachments_dir, eml_filename)

        # Create Markdown content
        md_content = f"""# {subject}

**From:** {from_addr}
**To:** {to_addr}
"""

        if cc_addr:
            md_content += f"**CC:** {cc_addr}  \n"

        md_content += f"**Date:** {date}  \n\n"

        md_content += "---\n\n"
        md_content += body_text

        # Add attachments section if any
        if attachments:
            md_content += format_attachment_section(attachments)

        # Create output filename
        eml_filename = Path(eml_file_path).stem
        md_filename = f"{eml_filename}.md"
        md_file_path = os.path.join(output_dir, md_filename)

        # Write Markdown file
        with open(md_file_path, 'w', encoding='utf-8') as f:
            f.write(md_content)

        return True, md_file_path, None

    except Exception as e:
        # Rollback: delete partial Markdown if created
        if md_file_path and os.path.exists(md_file_path):
            try:
                os.remove(md_file_path)
                print(f"  Rolled back partial file: {md_file_path}")
            except Exception as cleanup_error:
                print(f"  Warning: Could not clean up partial file {md_file_path}: {str(cleanup_error)}")
        
        return False, None, str(e)

def main():
    """Main function to convert all .eml files from email/raw to email/ai"""
    # Get the script directory and project root
    script_dir = Path(__file__).parent.resolve()
    # Script lives in core/aiScripts/emailToMd/, so go up 3 levels to project root
    project_root = script_dir.parent.parent.parent

    # Define directory structure relative to project root
    raw_dir = project_root / "email" / "raw"
    ai_dir = project_root / "email" / "ai"
    processed_dir = project_root / "email" / "processed"
    attachments_dir = project_root / "email" / "attachments"

    # Create directories if they don't exist
    raw_dir.mkdir(parents=True, exist_ok=True)
    ai_dir.mkdir(parents=True, exist_ok=True)
    processed_dir.mkdir(parents=True, exist_ok=True)
    attachments_dir.mkdir(parents=True, exist_ok=True)
    print(f"Directory structure ready:")
    print(f"  Raw: {raw_dir}")
    print(f"  AI: {ai_dir}")
    print(f"  Processed: {processed_dir}")
    print(f"  Attachments: {attachments_dir}")

    # Find all .eml files in raw directory
    eml_files = list(raw_dir.glob("*.eml"))

    if not eml_files:
        print(f"No .eml files found in {raw_dir}")
        return

    print(f"\nFound {len(eml_files)} .eml file(s) to convert")

    # Track results for summary report
    successful = []
    failed = []
    
    # Convert each file with transaction-safe operations
    for eml_file in eml_files:
        print(f"\nProcessing: {eml_file.name}")
        
        # Step 1: Validate email is parseable
        print(f"  [1/3] Validating...")
        valid, error_msg = validate_email_file(str(eml_file))
        if not valid:
            print(f"  ✗ Validation failed: {error_msg}")
            failed.append((eml_file.name, f"Validation: {error_msg}"))
            continue
        print(f"  ✓ Valid email")
        
        # Step 2: Convert to Markdown
        print(f"  [2/3] Converting to Markdown...")
        success, md_file_path, error_msg = convert_eml_to_md(str(eml_file), str(ai_dir), attachments_dir)
        if not success:
            print(f"  ✗ Conversion failed: {error_msg}")
            failed.append((eml_file.name, f"Conversion: {error_msg}"))
            continue
        print(f"  ✓ Created {Path(md_file_path).name}")
        
        # Step 3: Only now move original (transaction complete)
        print(f"  [3/3] Moving original to processed...")
        processed_path = processed_dir / eml_file.name
        try:
            eml_file.rename(processed_path)
            print(f"  ✓ Moved to processed")
            successful.append(eml_file.name)
        except Exception as e:
            print(f"  ✗ Error moving file: {str(e)}")
            # Note: Markdown was created successfully, so this is not a complete failure
            # But we'll still track it
            failed.append((eml_file.name, f"Move operation: {str(e)} (Markdown created successfully)"))

    # Print summary report
    print("\n" + "="*60)
    print("CONVERSION SUMMARY")
    print("="*60)
    print(f"Total files: {len(eml_files)}")
    print(f"Successful: {len(successful)}")
    print(f"Failed: {len(failed)}")
    
    if successful:
        print(f"\n✓ Successfully processed ({len(successful)}):")
        for filename in successful:
            print(f"  - {filename}")
    
    if failed:
        print(f"\n✗ Failed to process ({len(failed)}):")
        for filename, reason in failed:
            print(f"  - {filename}")
            print(f"    Reason: {reason}")
        print(f"\nNote: Original .eml files for failed conversions remain in {raw_dir}")
    
    print("="*60)

if __name__ == "__main__":
    main()
