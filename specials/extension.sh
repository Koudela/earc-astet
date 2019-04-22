#!/bin/bash
#!/bin/bash
typeset extensionName
typeset nextNode

open_extension()
{
    extensionName=${nextNode}
}

close_extension()
{
    extensionName=
}
