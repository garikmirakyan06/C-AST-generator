import json
import sys
from graphviz import Digraph
from pathlib import Path

def add_nodes(dot, node, parent_id=None, counter=[0]):
    """Recursively add nodes from JSON AST to Graphviz."""
    node_id = str(counter[0])
    counter[0] += 1

    label = node.get("kind", "")
    if "textLabel" in node:
        label += f"\n{node['textLabel']}"

    dot.node(node_id, label, shape="box")

    if parent_id is not None:
        dot.edge(parent_id, node_id)

    # Process children
    if "inner" in node and isinstance(node["inner"], list):
        for child in node["inner"]:
            add_nodes(dot, child, node_id, counter)

def main():
    if len(sys.argv) != 2:
        print(f"Usage: python {sys.argv[0]} <json_file>")
        sys.exit(1)

    json_path = Path(sys.argv[1])
    if not json_path.exists():
        print(f"File not found: {json_path}")
        sys.exit(1)

    # Load JSON file
    with open(json_path, "r", encoding="utf-8") as f:
        data = json.load(f)

    # Create Graphviz Digraph
    dot = Digraph(comment="AST")
    add_nodes(dot, data)

    # Save to PDF with same name as JSON file
    output_path = json_path.with_suffix("")
    dot.render(str(output_path), format="pdf", cleanup=True)

    print(f"AST tree saved as {output_path}.pdf")

if __name__ == "__main__":
    main()
