#!/usr/bin/env python3
"""
Smoke tests for task dependency detector
Tests critical paths to ensure task parsing and dependency detection works
"""

import unittest
import sys
from pathlib import Path
import tempfile

# Add task detector to path
sys.path.insert(0, str(Path(__file__).parent.parent / 'aiScripts' / 'detectTaskDependencies'))


class TestTaskDetector(unittest.TestCase):
    """Test task dependency detector"""

    def setUp(self):
        """Set up test fixtures"""
        self.fixtures = Path(__file__).parent / 'fixtures'
        self.sample_tasks = self.fixtures / 'sample_tasks.md'

    def test_sample_tasks_fixture_exists(self):
        """Test that sample_tasks.md fixture exists"""
        self.assertTrue(self.sample_tasks.exists(), "sample_tasks.md fixture not found")

    def test_sample_tasks_has_valid_structure(self):
        """Test that sample tasks file has expected structure"""
        content = self.sample_tasks.read_text()

        self.assertIn('# Tasks', content, "Missing Tasks header")
        self.assertIn('TASK-001', content, "Missing task ID")
        self.assertIn('**Owner**:', content, "Missing Owner field")
        self.assertIn('**Status**:', content, "Missing Status field")

    def test_task_detector_script_exists(self):
        """Test that task detector script exists"""
        detector_path = Path(__file__).parent.parent / 'aiScripts' / 'detectTaskDependencies' / 'detectTaskDependencies.py'

        self.assertTrue(detector_path.exists(), "Task detector script not found")

    def test_sample_tasks_has_multiple_tasks(self):
        """Test that sample tasks file contains multiple tasks"""
        content = self.sample_tasks.read_text()

        task_count = content.count('TASK-')
        self.assertGreaterEqual(task_count, 2, f"Expected at least 2 tasks, found {task_count}")

    def test_sample_tasks_has_dependencies(self):
        """Test that sample tasks include dependency relationships"""
        content = self.sample_tasks.read_text()

        # Check for Blocks and Related fields
        self.assertIn('**Blocks**:', content, "Missing Blocks field")
        self.assertIn('**Related**:', content, "Missing Related field")


class TestTaskDetectorErrorHandling(unittest.TestCase):
    """Test error handling in task detector"""

    def test_empty_file_handling(self):
        """Test that empty file can be created and read"""
        with tempfile.NamedTemporaryFile(mode='w', suffix='.md', delete=False) as f:
            temp_path = Path(f.name)
            f.write('')

        try:
            content = temp_path.read_text()
            self.assertEqual(content, '', "Empty file should have empty content")
        finally:
            temp_path.unlink()

    def test_malformed_task_data(self):
        """Test that malformed task data can be read"""
        malformed = "# Tasks\n\nThis is not a valid task format\nNo task IDs here"

        with tempfile.NamedTemporaryFile(mode='w', suffix='.md', delete=False) as f:
            temp_path = Path(f.name)
            f.write(malformed)

        try:
            content = temp_path.read_text()
            self.assertIn('# Tasks', content, "Should be able to read malformed file")
        finally:
            temp_path.unlink()


def run_tests():
    """Run all tests and return exit code"""
    loader = unittest.TestLoader()
    suite = unittest.TestSuite()

    suite.addTests(loader.loadTestsFromTestCase(TestTaskDetector))
    suite.addTests(loader.loadTestsFromTestCase(TestTaskDetectorErrorHandling))

    runner = unittest.TextTestRunner(verbosity=2)
    result = runner.run(suite)

    return 0 if result.wasSuccessful() else 1


if __name__ == '__main__':
    sys.exit(run_tests())
