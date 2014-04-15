Decorator
=========

```tcl
package require "decorator"

proc makeitalic { func args } {
    return "<i>[$func {*}$args]</i>"
}

proc makebold { func args } {
    return "<b>[$func {*}$args]</b>"
}

# Decorator usage:
@ makebold \
@ makeitalic \
proc say { greeting } {
    return $greeting
}

puts [say "hello world"]
```

```
# Output
<b><i>hello world</i></b>
```