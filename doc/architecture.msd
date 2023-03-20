#//# --------------------------------------------------------------------------------------
#//# Created using Sequence Diagram for Mac
#//# https://www.macsequencediagram.com
#//# https://itunes.apple.com/gb/app/sequence-diagram/id1195426709?mt=12
#//# --------------------------------------------------------------------------------------
title "Sod Architecture"

participant Process
participant Register
participant Parse
participant Act

Load->Load: Load.

note over Load
  "Sequentially reduces default configurations into a single merged configuration."
end note

Load->Override: Transfer.

Override->Transform: Override (optional).

note over Override
  "Merges specific overrides."
end note

Transform->Transform: Transform (optional).

note over Transform
  "Sequentially transforms individual values within merged configuration."
end note

Transform->Validate: Transfer.

Validate->Result: Validate

note over Validate
  "Ensures merged and transformed configuration is valid."
end note

note over Result
  "Answers monad with record or errors."
end note
