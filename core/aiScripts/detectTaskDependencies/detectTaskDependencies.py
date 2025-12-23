#!/usr/bin/env python3
"""
Smart Task Dependency Detection
Analyzes task descriptions to automatically detect and suggest dependencies.
"""

import re
import json
import sys
from typing import List, Dict, Set, Tuple, Optional
from pathlib import Path
from dataclasses import dataclass, asdict
from collections import defaultdict

# Import logger
try:
    from ..logger import get_logger
    logger = get_logger('task_dependency_detector')
except ImportError:
    # Fallback if running as standalone script
    sys.path.insert(0, str(Path(__file__).parent.parent))
    from logger import get_logger
    logger = get_logger('task_dependency_detector')


@dataclass
class Task:
    """Represents a task with metadata"""
    id: str
    title: str
    description: str
    owner: str
    status: str
    blocks: List[str]
    related: List[str]
    source: str
    context: str
    deadline: Optional[str] = None


@dataclass
class DependencyDetection:
    """Represents a detected dependency"""
    from_task: str
    to_task: str
    confidence: float
    reason: str
    keywords_found: List[str]


class TaskDependencyDetector:
    """Detects task dependencies using NLP-based analysis"""
    
    # Dependency keywords indicating task relationships
    DEPENDENCY_PATTERNS = {
        'blocks': [
            r'\b(?:after|once|when)\s+(?:TASK-\d+|[\w\s]+)\s+(?:is\s+)?(?:complete|done|finished)',
            r'\brequires?\s+(?:TASK-\d+|[\w\s]+)\s+(?:to\s+)?(?:be\s+)?(?:complete|done|finished)',
            r'\bdepends?\s+on\s+(?:TASK-\d+|[\w\s]+)',
            r'\bblocked\s+by\s+(?:TASK-\d+|[\w\s]+)',
            r'\bwaiting\s+(?:for|on)\s+(?:TASK-\d+|[\w\s]+)',
            r'\bneeds?\s+(?:TASK-\d+|[\w\s]+)\s+(?:first|before)',
        ],
        'related': [
            r'\brelated\s+to\s+(?:TASK-\d+|[\w\s]+)',
            r'\bsimilar\s+to\s+(?:TASK-\d+|[\w\s]+)',
            r'\bconnected\s+(?:with|to)\s+(?:TASK-\d+|[\w\s]+)',
            r'\bsee\s+also\s+(?:TASK-\d+|[\w\s]+)',
            r'\bpart\s+of\s+(?:TASK-\d+|[\w\s]+)',
        ],
        'before': [
            r'\bbefore\s+(?:TASK-\d+|[\w\s]+)',
            r'\bprior\s+to\s+(?:TASK-\d+|[\w\s]+)',
            r'\bmust\s+(?:be\s+)?(?:complete|done)\s+before\s+(?:TASK-\d+|[\w\s]+)',
        ]
    }
    
    # Contextual clues for dependency detection
    CONTEXTUAL_KEYWORDS = {
        'sequential': ['first', 'second', 'third', 'next', 'then', 'finally', 'last'],
        'prerequisite': ['setup', 'install', 'configure', 'initialize', 'prepare'],
        'follow_up': ['cleanup', 'verify', 'test', 'review', 'document'],
    }
    
    def __init__(self, tasks_file: Path):
        """Initialize detector with tasks file path"""
        self.tasks_file = tasks_file
        self.tasks: List[Task] = []
        self.task_map: Dict[str, Task] = {}
        
    def load_tasks(self) -> None:
        """Load tasks from TASKS.md file"""
        if not self.tasks_file.exists():
            raise FileNotFoundError(f"Tasks file not found: {self.tasks_file}")
        
        content = self.tasks_file.read_text()
        self.tasks = self._parse_tasks_from_markdown(content)
        self.task_map = {task.id: task for task in self.tasks}
        
    def _parse_tasks_from_markdown(self, content: str) -> List[Task]:
        """Parse tasks from markdown content"""
        tasks = []
        current_task = None
        
        # Simple regex to find task entries (TASK-XXX format)
        task_pattern = r'#### (TASK-\d+):\s*(.+?)(?=####\s*TASK-|\Z)'
        
        for match in re.finditer(task_pattern, content, re.DOTALL):
            task_id = match.group(1)
            task_content = match.group(2).strip()
            
            # Extract fields
            title_match = re.search(r'\*\*([^*]+)\*\*', task_content)
            title = title_match.group(1) if title_match else ""
            
            owner_match = re.search(r'Owner:\s*([^\n]+)', task_content)
            owner = owner_match.group(1).strip() if owner_match else "TBD"
            
            status_match = re.search(r'Status:\s*([^\n]+)', task_content)
            status = status_match.group(1).strip() if status_match else "Not Started"
            
            blocks_match = re.search(r'Blocks:\s*([^\n]+)', task_content)
            blocks = blocks_match.group(1).strip().split(', ') if blocks_match and blocks_match.group(1).strip() != 'None' else []
            
            related_match = re.search(r'Related:\s*([^\n]+)', task_content)
            related = related_match.group(1).strip().split(', ') if related_match and related_match.group(1).strip() != 'None' else []
            
            source_match = re.search(r'Source:\s*([^\n]+)', task_content)
            source = source_match.group(1).strip() if source_match else ""
            
            context_match = re.search(r'Context:\s*([^\n]+)', task_content)
            context = context_match.group(1).strip() if context_match else ""
            
            deadline_match = re.search(r'Deadline:\s*([^\n]+)', task_content)
            deadline = deadline_match.group(1).strip() if deadline_match and deadline_match.group(1).strip() != 'None' else None
            
            tasks.append(Task(
                id=task_id,
                title=title,
                description=task_content,
                owner=owner,
                status=status,
                blocks=blocks,
                related=related,
                source=source,
                context=context,
                deadline=deadline
            ))
        
        return tasks
    
    def detect_dependencies(self) -> List[DependencyDetection]:
        """Detect all dependencies between tasks"""
        detections = []
        
        for task in self.tasks:
            # Combine context and description for analysis
            full_text = f"{task.context} {task.description}".lower()
            
            # Check for explicit task references
            explicit_deps = self._find_explicit_references(task, full_text)
            detections.extend(explicit_deps)
            
            # Check for keyword-based dependencies
            keyword_deps = self._find_keyword_dependencies(task, full_text)
            detections.extend(keyword_deps)
            
            # Check for contextual dependencies
            contextual_deps = self._find_contextual_dependencies(task)
            detections.extend(contextual_deps)
        
        # Deduplicate and sort by confidence
        detections = self._deduplicate_detections(detections)
        detections.sort(key=lambda x: x.confidence, reverse=True)
        
        return detections
    
    def _find_explicit_references(self, task: Task, text: str) -> List[DependencyDetection]:
        """Find explicit TASK-XXX references in text"""
        detections = []
        
        # Find all TASK-XXX references
        task_refs = re.findall(r'TASK-\d+', text)
        
        for ref in task_refs:
            if ref != task.id and ref in self.task_map:
                # Determine relationship type based on surrounding text
                for dep_type, patterns in self.DEPENDENCY_PATTERNS.items():
                    for pattern in patterns:
                        if re.search(pattern.replace('TASK-\\d+', ref), text, re.IGNORECASE):
                            detections.append(DependencyDetection(
                                from_task=task.id,
                                to_task=ref,
                                confidence=0.95,
                                reason=f"Explicit reference with {dep_type} keyword",
                                keywords_found=[ref, dep_type]
                            ))
                            break
        
        return detections
    
    def _find_keyword_dependencies(self, task: Task, text: str) -> List[DependencyDetection]:
        """Find dependencies based on keywords"""
        detections = []
        
        for dep_type, patterns in self.DEPENDENCY_PATTERNS.items():
            for pattern in patterns:
                matches = re.finditer(pattern, text, re.IGNORECASE)
                for match in matches:
                    detections.append(DependencyDetection(
                        from_task=task.id,
                        to_task="UNKNOWN",  # Will need manual review
                        confidence=0.60,
                        reason=f"Keyword pattern matched: {dep_type}",
                        keywords_found=[match.group(0)]
                    ))
        
        return detections
    
    def _find_contextual_dependencies(self, task: Task) -> List[DependencyDetection]:
        """Find dependencies based on context and task ordering"""
        detections = []
        
        # Check for sequential keywords
        text = f"{task.context} {task.description}".lower()
        
        for category, keywords in self.CONTEXTUAL_KEYWORDS.items():
            for keyword in keywords:
                if keyword in text:
                    # Suggest potential dependencies based on context
                    if category == 'prerequisite':
                        # This task likely blocks others
                        detections.append(DependencyDetection(
                            from_task=task.id,
                            to_task="DOWNSTREAM",
                            confidence=0.40,
                            reason=f"Prerequisite keyword found: {keyword}",
                            keywords_found=[keyword]
                        ))
                    elif category == 'follow_up':
                        # This task likely depends on others
                        detections.append(DependencyDetection(
                            from_task="UPSTREAM",
                            to_task=task.id,
                            confidence=0.40,
                            reason=f"Follow-up keyword found: {keyword}",
                            keywords_found=[keyword]
                        ))
        
        return detections
    
    def _deduplicate_detections(self, detections: List[DependencyDetection]) -> List[DependencyDetection]:
        """Remove duplicate detections, keeping highest confidence"""
        unique = {}
        
        for detection in detections:
            key = (detection.from_task, detection.to_task)
            if key not in unique or detection.confidence > unique[key].confidence:
                unique[key] = detection
        
        return list(unique.values())
    
    def detect_circular_dependencies(self) -> List[List[str]]:
        """Detect circular dependencies in task graph"""
        # Build adjacency list
        graph = defaultdict(set)
        for task in self.tasks:
            for blocked in task.blocks:
                if blocked in self.task_map:
                    graph[task.id].add(blocked)
        
        # Find cycles using DFS
        cycles = []
        visited = set()
        rec_stack = set()
        
        def dfs(node: str, path: List[str]):
            visited.add(node)
            rec_stack.add(node)
            path.append(node)
            
            for neighbor in graph.get(node, []):
                if neighbor not in visited:
                    dfs(neighbor, path.copy())
                elif neighbor in rec_stack:
                    # Found a cycle
                    cycle_start = path.index(neighbor)
                    cycles.append(path[cycle_start:] + [neighbor])
            
            rec_stack.remove(node)
        
        for task in self.tasks:
            if task.id not in visited:
                dfs(task.id, [])
        
        return cycles
    
    def generate_dependency_graph(self, output_file: Path) -> None:
        """Generate Mermaid diagram of task dependencies"""
        lines = ["```mermaid", "graph TD"]
        
        for task in self.tasks:
            # Add task node
            status_symbol = {
                'Completed': '✓',
                'In Progress': '⚙',
                'Blocked': '⛔',
                'Not Started': '○'
            }.get(task.status, '○')
            
            lines.append(f'    {task.id}["{status_symbol} {task.id}: {task.title[:30]}"]')
            
            # Add dependency edges
            for blocked in task.blocks:
                if blocked in self.task_map:
                    lines.append(f'    {task.id} --> {blocked}')
        
        lines.append("```")
        
        output_file.write_text('\n'.join(lines))
    
    def generate_report(self, output_file: Path) -> None:
        """Generate comprehensive dependency analysis report"""
        detections = self.detect_dependencies()
        cycles = self.detect_circular_dependencies()
        
        report_lines = [
            "# Task Dependency Analysis Report",
            f"*Generated: {Path.cwd()}*\n",
            "## Summary",
            f"- Total tasks analyzed: {len(self.tasks)}",
            f"- Dependencies detected: {len(detections)}",
            f"- Circular dependencies found: {len(cycles)}\n",
        ]
        
        if detections:
            report_lines.extend([
                "## Detected Dependencies\n",
                "### High Confidence (>= 0.8)"
            ])
            
            high_conf = [d for d in detections if d.confidence >= 0.8]
            for det in high_conf:
                report_lines.append(
                    f"- **{det.from_task} → {det.to_task}** "
                    f"(confidence: {det.confidence:.0%})"
                )
                report_lines.append(f"  - Reason: {det.reason}")
                report_lines.append(f"  - Keywords: {', '.join(det.keywords_found)}\n")
            
            report_lines.extend([
                "### Medium Confidence (0.5 - 0.8)"
            ])
            
            medium_conf = [d for d in detections if 0.5 <= d.confidence < 0.8]
            for det in medium_conf:
                report_lines.append(
                    f"- **{det.from_task} → {det.to_task}** "
                    f"(confidence: {det.confidence:.0%})"
                )
                report_lines.append(f"  - Reason: {det.reason}\n")
        
        if cycles:
            report_lines.extend([
                "\n## ⚠️ Circular Dependencies Detected\n"
            ])
            
            for i, cycle in enumerate(cycles, 1):
                report_lines.append(f"### Cycle {i}")
                report_lines.append(" → ".join(cycle))
                report_lines.append("")
        
        # Critical path suggestion
        report_lines.extend([
            "\n## Critical Path Analysis\n",
            "Tasks with no dependencies (can start immediately):"
        ])
        
        tasks_with_no_deps = [
            task for task in self.tasks 
            if not task.blocks and task.status == 'Not Started'
        ]
        
        for task in tasks_with_no_deps:
            report_lines.append(f"- {task.id}: {task.title}")
        
        output_file.write_text('\n'.join(report_lines))


def main():
    """Main entry point"""
    import sys
    
    if len(sys.argv) < 2:
        logger.error("Usage: python detectTaskDependencies.py <path_to_TASKS.md>")
        sys.exit(1)
    
    tasks_file = Path(sys.argv[1])
    logger.info(f"Analyzing tasks from: {tasks_file}")
    
    detector = TaskDependencyDetector(tasks_file)
    detector.load_tasks()
    logger.debug(f"Loaded {len(detector.tasks)} tasks")
    
    # Generate outputs
    output_dir = tasks_file.parent
    logger.info("Generating dependency report...")
    detector.generate_report(output_dir / "TASK_DEPENDENCY_REPORT.md")
    logger.info("Generating dependency graph...")
    detector.generate_dependency_graph(output_dir / "TASK_DEPENDENCY_GRAPH.md")
    
    logger.info(f"✓ Analysis complete!")
    logger.info(f"  - Report: {output_dir / 'TASK_DEPENDENCY_REPORT.md'}")
    logger.info(f"  - Graph: {output_dir / 'TASK_DEPENDENCY_GRAPH.md'}")


if __name__ == "__main__":
    main()
