discard """
  targets: "cpp"
  cmd: "nim $target --cppCompileToNamespace:foo --noMain $options $file"
  output: "42"
"""

{.emit: """/*INCLUDESECTION*/
namespace foo { void NimMain(); }
int main() { foo::NimMain(); }
""".}

echo 42
