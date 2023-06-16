#//# --------------------------------------------------------------------------------------
#//# Created using Sequence Diagram for Mac
#//# https://www.macsequencediagram.com
#//# https://itunes.apple.com/gb/app/sequence-diagram/id1195426709?mt=12
#//# --------------------------------------------------------------------------------------
title "Sod Architecture"

participant Shell
participant Runner
participant Loader

Shell->Shell: Build.

note over Shell
  "Builds the graph by walking over each node defined in the DSL."
end note

Shell->Runner: Load.

note over Runner
  "Delegates to loader to load option parsers per command/action."
end note

Loader->Loader: Visit.

note over Loader
  "Visits each node in the graph and loads the corresponding option parser per action."
end note

Loader->Runner: Visit.

note over Runner
  "Visits each graph node by parsing and executing upon CLI arguments per command/action."
end note

Runner->Runner: Output.

note over Runner
  "Prints final result, error, or help text."
end note
