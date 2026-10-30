#!/bin/bash

PATH=/opt/homebrew/bin:$PATH

display1_current=`m1ddc display 1 get input`
display2_current=`m1ddc display 2 get input`

# Dell 43 inch on M2
if [[ $display1_current == "19" ]]; then
  # Dell 43 inch on M4
  display1_input="15"
else
  display1_input="19"
fi

# Dell 27 inch on M2
if [[ $display2_current == "15" ]]; then
  # Dell 43 inch on M4
  display2_input="27"
else
  display2_input="15"
fi

/opt/homebrew/bin/m1ddc display 2 set input $display2_input
/opt/homebrew/bin/m1ddc display 1 set input $display1_input
