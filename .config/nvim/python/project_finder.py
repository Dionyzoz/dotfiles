import os
import glob
import sys
import re
import yaml
from pathlib import Path
import time

SECOND_BRAIN = os.getenv("SECOND_BRAIN")

PROJECTS_DIR = Path(SECOND_BRAIN) / "1-projects" if SECOND_BRAIN else None
TASKS_DIR = Path(SECOND_BRAIN) / "0-tasks" if SECOND_BRAIN else None


ALL_STATUSES = ["idea", "todo", "active", "completed", "abandoned", "blocked"]

RELEVANT_STATUS = [
    "active",
    "todo",
    "idea",
    "completed",
    "blocked",
]

stderr = sys.stderr

# with open("./log.txt", "w") as f:
#     f.write(" ".join(sys.argv))


class FrontMatterUpdate:
    def __init__(self, filepath):
        self.file_obj = open(filepath, "r+", encoding="utf-8")

        content = self.file_obj.read()
        fm_match = re.search(
            r"^---\n(.+?)\n---", content, re.DOTALL
        )  # Front matter portion of file

        self.text = (
            content[fm_match.end() :] if fm_match else content
        )  # Text after the front matter
        self.fm = (
            yaml.safe_load(fm_match.group(1)) if fm_match else {}
        )  # Parse front matter if portion exists

    def __enter__(self):
        return self.fm  # Update front matter within context manager

    def __exit__(self, exc_type, exc_value, traceback):
        if not exc_type:
            # Update front matter while keeping content
            new_content = f"---\n{yaml.safe_dump(self.fm)}---{self.text}"

            self.file_obj.seek(0)
            self.file_obj.write(new_content)
            self.file_obj.truncate()

        self.file_obj.close()


def extract_front_matter(filepath):
    """Extract YAML front matter between --- markers"""
    try:
        with open(filepath, "r", encoding="utf-8") as f:
            content = f.read()
            fm_match = re.search(r"^---\n(.+?)\n---", content, re.DOTALL)
            if fm_match:
                return yaml.safe_load(fm_match.group(1))

    except Exception as e:
        stderr.write(f"Error parsing {filepath}: {str(e)}")

    return {}


def find_projects():
    """Recursively find markdown files matching criteria

    keys for task target type:

        status: If the status is None, in that case it will return the ideas, todos, actives and completed
            You can get multiple statuses by splitting like so: "idea,active"

        project_ref: The file path of the parent project of the tasks that are being requested

    """

    matches = []

    if not PROJECTS_DIR.exists():
        return

    for filepath in glob.glob(str(PROJECTS_DIR / "**" / "*.md"), recursive=True):
        if any(parent.name == "archive" for parent in Path(filepath).parents):
            # dont look for files in folders named archive
            continue

        meta = extract_front_matter(filepath)

        if not meta:
            continue

        if meta.get("type") == "project":
            matches.append(filepath)

    return matches


def find_tasks(project_ref=None, status=None):
    """Recursively find markdown files matching criteria

    keys for task target type:

        status: If the status is None, in that case it will return the ideas, todos, actives and completed
            You can get multiple statuses by splitting like so: "idea,active"

        project_ref: The file path of the parent project of the tasks that are being requested

    """

    tasks_dirs = [TASKS_DIR, PROJECTS_DIR]

    check_status = RELEVANT_STATUS  # If none check all relevant task statuses

    if status:
        check_status = status.split(",")

    matches = {status: [] for status in check_status}  # active key is special

    for tasks_dir in tasks_dirs:
        if not tasks_dir.exists():
            continue

        for filepath in glob.glob(str(tasks_dir / "**" / "*.md"), recursive=True):
            if any(parent.name == "archive" for parent in Path(filepath).parents):
                # dont look for files in folders named archive
                continue

            meta = extract_front_matter(filepath)

            if not meta or meta.get("type") != "task":  # only check task files
                continue

            if meta.get("status", "idea") in check_status:
                if not project_ref or project_ref in [
                    *([meta.get("project")] or meta.get("projects", []))
                ]:
                    if meta.get("status") == "active":
                        matches["active"].append((filepath, meta.get("rank", 0)))

                    else:
                        matches[meta.get("status", "idea")].append(filepath)

    if "active" in check_status:
        matches["active"].sort(key=lambda x: x[1], reverse=True)
        matches["active"] = [
            m[0] for m in matches["active"]
        ]  # could be optimized in place

    print_list = []

    for s in check_status:
        for task in matches[s]:
            print_list.append(
                f"{task},Task{s.capitalize()}"
            )  # append custom highlight group

    return print_list


def link_to_project(filepath, project_file):
    """Link a note/task to a project (:LinkProject)"""
    try:
        project_link = f"{
            Path(project_file).stem
        }"  # get just the name of the project based on the file name

        with FrontMatterUpdate(filepath) as fm:
            if fm.get("project"):
                fm["projects"] = [fm["project"], project_link]
                del fm["project"]

            elif fm.get("projects"):
                fm["projects"].append(project_link)

            else:
                fm["project"] = project_link

    except Exception as e:
        print(f"Error updating rank: {str(e)}", file=stderr)


def nice_rank(filepath):
    """Update or add rank to a task's front matter (:Nice)"""
    try:
        with FrontMatterUpdate(filepath) as fm:
            fm["type"] = "task"
            fm["rank"] = int(time.time())

            fm["status"] = "active"

    except Exception as e:
        print(f"Error updating rank: {str(e)}", file=stderr)


def status_update(filepath, status):
    """Update or set status of a task (:TaskStatus)"""
    try:
        with FrontMatterUpdate(filepath) as fm:
            fm["status"] = status

    except Exception as e:
        print(f"Error removing rank: {str(e)}", file=stderr)


def remove_rank(filepath):
    """Remove rank from a task's front matter"""
    try:
        with FrontMatterUpdate(filepath) as fm:
            if fm and "rank" in fm:
                del fm["rank"]

    except Exception as e:
        print(f"Error removing rank: {str(e)}", file=stderr)


def status_options(filepath):
    """For given file object get the possible statuses"""
    meta = extract_front_matter(filepath)

    return list(set(ALL_STATUSES) - set([meta.get("status")]))


if __name__ == "__main__":
    # time.sleep(10000) # debugging for neovim to see start params
    if not PROJECTS_DIR:
        print("Error: SECOND_BRAIN environment variable not set", file=stderr)
        sys.exit(1)

    if len(sys.argv) > 1:
        if sys.argv[1] == "projects":
            files = find_projects()
            if files:
                print("\n".join(files))

        elif sys.argv[1] == "tasks":
            # time.sleep(10000)  # debugging for neovim to see start params

            project_ref = Path(sys.argv[2]).stem if len(sys.argv) > 2 else None
            files_and_hi = find_tasks(project_ref=project_ref)

            if files_and_hi:
                print("\n".join(files_and_hi))

            with open("./log.txt", "w") as o:
                o.write(" ".join(files_and_hi))

        elif sys.argv[1] == "ranked_tasks":
            files = find_tasks(status="active,todo")
            if files:
                print("\n".join(files))

        elif sys.argv[1] == "nice_rank":
            nice_rank(sys.argv[2])

        elif sys.argv[1] == "status_update":
            status_update(sys.argv[2], sys.argv[3])

        elif sys.argv[1] == "status_options":
            status_options = status_options(sys.argv[2])
            print("\n".join(status_options))

        elif sys.argv[1] == "remove_rank":
            remove_rank(sys.argv[2])

        elif sys.argv[1] == "link_to_project":
            # time.sleep(10000) # debugging for neovim to see start params

            link_to_project(sys.argv[2], sys.argv[3])

        else:
            print(
                "Invalid command. Use 'projects', 'tasks', 'ranked_tasks', 'nice_rank', or 'remove_rank' or 'status_update'",
                file=stderr,
            )
            sys.exit(1)
    else:
        print(
            "Usage: python project_finder.py [projects|tasks|ranked_tasks|nice_rank|remove_rank] [project_file]",
            file=stderr,
        )

        sys.exit(1)
