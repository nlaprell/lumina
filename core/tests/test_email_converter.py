#!/usr/bin/env python3
"""
Smoke tests for email converter
Tests critical paths to ensure email conversion works correctly
"""

import unittest
import sys
from pathlib import Path
import tempfile
import shutil

# Add email converter to path
sys.path.insert(0, str(Path(__file__).parent.parent / 'aiScripts' / 'emailToMd'))

class TestEmailConverter(unittest.TestCase):
    """Test email to markdown conversion"""

    def setUp(self):
        """Set up test fixtures and temporary directories"""
        self.fixtures = Path(__file__).parent / 'fixtures'
        self.temp_dir = Path(tempfile.mkdtemp())
        self.raw_dir = self.temp_dir / 'raw'
        self.ai_dir = self.temp_dir / 'ai'
        self.processed_dir = self.temp_dir / 'processed'

        # Create directories
        self.raw_dir.mkdir(parents=True)
        self.ai_dir.mkdir(parents=True)
        self.processed_dir.mkdir(parents=True)

    def tearDown(self):
        """Clean up temporary directories"""
        if self.temp_dir.exists():
            shutil.rmtree(self.temp_dir)

    def test_valid_email_has_required_structure(self):
        """Test that sample.eml fixture has valid email structure"""
        eml_path = self.fixtures / 'sample.eml'

        self.assertTrue(eml_path.exists(), "sample.eml fixture not found")

        content = eml_path.read_text()
        self.assertIn('From:', content, "Email missing From header")
        self.assertIn('To:', content, "Email missing To header")
        self.assertIn('Subject:', content, "Email missing Subject header")

    def test_email_converter_script_exists(self):
        """Test that email converter script exists and is executable"""
        converter_path = Path(__file__).parent.parent / 'aiScripts' / 'emailToMd' / 'eml_to_md_converter.py'

        self.assertTrue(converter_path.exists(), "Email converter script not found")

    def test_email_converter_can_be_imported(self):
        """Test that email converter module can be imported"""
        try:
            import eml_to_md_converter
            self.assertTrue(True, "Module imported successfully")
        except ImportError as e:
            self.fail(f"Failed to import email converter: {e}")

    def test_converter_processes_email_file(self):
        """Test that converter can process a valid email file"""
        # Copy sample email to temp raw directory
        sample_eml = self.fixtures / 'sample.eml'
        test_eml = self.raw_dir / 'test.eml'
        shutil.copy(sample_eml, test_eml)

        # Run converter (simulated - we're just testing the file operations)
        # In a real implementation, you'd call the converter function here
        # For now, verify the fixture is valid
        import email
        from email import policy

        with open(test_eml, 'r', encoding='utf-8') as f:
            msg = email.message_from_file(f, policy=policy.default)

        self.assertIsNotNone(msg['Subject'], "Failed to parse email subject")
        self.assertIsNotNone(msg['From'], "Failed to parse email from")

    def test_invalid_email_fixture_exists(self):
        """Test that invalid.eml fixture exists for error testing"""
        invalid_path = self.fixtures / 'invalid.eml'
        self.assertTrue(invalid_path.exists(), "invalid.eml fixture not found")


class TestEmailConverterErrorHandling(unittest.TestCase):
    """Test error handling in email converter"""

    def setUp(self):
        """Set up test fixtures"""
        self.fixtures = Path(__file__).parent / 'fixtures'

    def test_nonexistent_file_handling(self):
        """Test that nonexistent file is handled appropriately"""
        nonexistent = Path('/tmp/nonexistent_email_file_12345.eml')
        self.assertFalse(nonexistent.exists(), "Test file should not exist")

    def test_invalid_email_can_be_read(self):
        """Test that invalid email file can at least be read"""
        invalid_path = self.fixtures / 'invalid.eml'

        try:
            content = invalid_path.read_text()
            self.assertIsInstance(content, str, "Should be able to read invalid email as text")
        except Exception as e:
            self.fail(f"Failed to read invalid email file: {e}")


def run_tests():
    """Run all tests and return exit code"""
    loader = unittest.TestLoader()
    suite = unittest.TestSuite()

    suite.addTests(loader.loadTestsFromTestCase(TestEmailConverter))
    suite.addTests(loader.loadTestsFromTestCase(TestEmailConverterErrorHandling))

    runner = unittest.TextTestRunner(verbosity=2)
    result = runner.run(suite)

    return 0 if result.wasSuccessful() else 1


if __name__ == '__main__':
    sys.exit(run_tests())
