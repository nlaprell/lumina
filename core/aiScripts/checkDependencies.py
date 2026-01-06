#!/usr/bin/env python3
"""
Dependency checker and installer for Lumina
Checks for required packages and offers to install them
"""

import sys
import subprocess
from pathlib import Path

class DependencyChecker:
    """Check and manage Lumina dependencies"""

    DEPENDENCIES = {
        'html2text': {
            'package': 'html2text==2024.2.26',
            'import_name': 'html2text',
            'description': 'HTML to Markdown conversion (Apple Notes support)',
            'feature': 'Apple Notes (.html) processing'
        },
        'docx': {
            'package': 'python-docx==1.1.0',
            'import_name': 'docx',
            'description': 'Microsoft Office document parsing (OneNote support)',
            'feature': 'OneNote (.docx) processing'
        }
    }

    def __init__(self, verbose=False):
        self.verbose = verbose
        self.missing = {}
        self.available = {}

    def check_all(self):
        """Check all optional dependencies"""
        for name, info in self.DEPENDENCIES.items():
            if self._check_dependency(info['import_name']):
                self.available[name] = info
            else:
                self.missing[name] = info
        return self

    def _check_dependency(self, import_name):
        """Check if a Python package is installed"""
        try:
            __import__(import_name)
            return True
        except ImportError:
            return False

    def get_status(self):
        """Get human-readable status report"""
        report = []

        if self.available:
            report.append("✅ Available:")
            for name, info in self.available.items():
                report.append(f"   • {info['description']}")

        if self.missing:
            report.append("")
            report.append("❌ Missing (features disabled):")
            for name, info in self.missing.items():
                report.append(f"   • {info['description']}")
                report.append(f"     → Disables: {info['feature']}")

        return '\n'.join(report)

    def get_install_command(self):
        """Get pip install command for missing dependencies"""
        if not self.missing:
            return None

        packages = [info['package'] for info in self.missing.values()]
        return f"pip install {' '.join(packages)}"

    def install_interactive(self):
        """Interactively prompt to install missing dependencies"""
        if not self.missing:
            if self.verbose:
                print("✓ All optional dependencies are installed!")
            return True

        print("\n" + "="*70)
        print("MISSING DEPENDENCIES")
        print("="*70)
        print()

        for name, info in self.missing.items():
            print(f"❌ {info['description']}")
            print(f"   Feature disabled: {info['feature']}")
            print()

        print("Install missing dependencies?")
        print()
        install_cmd = self.get_install_command()
        print(f"  Command: {install_cmd}")
        print()

        response = input("Install now? (y/n) [y]: ").strip().lower()

        if response == '' or response == 'y':
            return self._install_packages()
        else:
            print("\n⚠️  Proceeding without optional dependencies.")
            print("   Some note formats will be skipped during conversion.")
            return False

    def _install_packages(self):
        """Install missing packages"""
        print()
        print("Installing packages...")
        print()

        for name, info in self.missing.items():
            print(f"Installing {info['package']}...")
            result = subprocess.run(
                [sys.executable, '-m', 'pip', 'install', info['package']],
                capture_output=False,
                text=True
            )

            if result.returncode != 0:
                print(f"❌ Failed to install {info['package']}")
                return False
            else:
                print(f"✓ Installed {info['package']}")
                print()

        # Re-check dependencies
        self.missing.clear()
        self.available.clear()
        self.check_all()

        if self.missing:
            print("⚠️  Some packages failed to install properly")
            return False
        else:
            print("✅ All dependencies installed successfully!")
            return True

    def print_status(self):
        """Print formatted status"""
        print(self.get_status())


def main():
    """Check dependencies and optionally install missing ones"""
    import argparse

    parser = argparse.ArgumentParser(
        description='Check and install Lumina dependencies',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Check which dependencies are available
  python3 core/aiScripts/checkDependencies.py --check

  # Install missing dependencies interactively
  python3 core/aiScripts/checkDependencies.py --install

  # Show what would be installed (quiet mode)
  python3 core/aiScripts/checkDependencies.py --check --quiet
        """
    )

    parser.add_argument(
        '--check',
        action='store_true',
        help='Check which dependencies are available'
    )
    parser.add_argument(
        '--install',
        action='store_true',
        help='Interactively install missing dependencies'
    )
    parser.add_argument(
        '--quiet', '-q',
        action='store_true',
        help='Minimal output (exit codes: 0=all installed, 1=missing deps)'
    )

    args = parser.parse_args()

    # Default action: check
    if not args.check and not args.install:
        args.check = True

    checker = DependencyChecker(verbose=not args.quiet)
    checker.check_all()

    if args.check:
        if not args.quiet:
            checker.print_status()
        return 0 if not checker.missing else 1

    if args.install:
        success = checker.install_interactive()
        return 0 if success else 1

    return 0


if __name__ == '__main__':
    sys.exit(main())
