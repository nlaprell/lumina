#!/usr/bin/env python3
"""
Centralized logging module for Lumina AI scripts

Provides consistent logging across all Python scripts with:
- File and console handlers
- Log rotation (10MB max, 5 backups)
- Configurable log levels
- Environment variable support for debug mode

Usage:
    from logger import get_logger
    logger = get_logger('script_name')
    logger.info("Processing started")
    logger.debug("Detailed info for debugging")
    logger.error("Error occurred", exc_info=True)
"""

import logging
import logging.handlers
import os
from pathlib import Path


def get_logger(name: str) -> logging.Logger:
    """
    Get configured logger with file and console handlers

    Args:
        name: Logger name (typically script name without extension)

    Returns:
        Configured logger instance

    Environment Variables:
        LUMINA_DEBUG: Set to '1', 'true', or 'yes' to enable DEBUG level on console
    """
    logger = logging.getLogger(name)

    # Return existing logger if already configured
    if logger.handlers:
        return logger

    # Set base level to DEBUG to capture everything
    logger.setLevel(logging.DEBUG)

    # Console handler - INFO and above (or DEBUG if enabled)
    console = logging.StreamHandler()

    # Check for debug mode via environment variable
    debug_mode = os.environ.get('LUMINA_DEBUG', '').lower() in ('1', 'true', 'yes')
    console.setLevel(logging.DEBUG if debug_mode else logging.INFO)

    console_format = logging.Formatter('%(levelname)s: %(message)s')
    console.setFormatter(console_format)

    # File handler - DEBUG and above with rotation
    log_dir = Path(__file__).parent.parent.parent / 'logs'
    log_dir.mkdir(exist_ok=True)

    log_file = log_dir / f'{name}.log'
    file_handler = logging.handlers.RotatingFileHandler(
        log_file,
        maxBytes=10 * 1024 * 1024,  # 10MB
        backupCount=5
    )
    file_handler.setLevel(logging.DEBUG)

    file_format = logging.Formatter(
        '%(asctime)s - %(name)s - %(levelname)s - %(message)s',
        datefmt='%Y-%m-%d %H:%M:%S'
    )
    file_handler.setFormatter(file_format)

    # Add handlers to logger
    logger.addHandler(console)
    logger.addHandler(file_handler)

    return logger
