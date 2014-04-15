package provide "decorator" 1.0

namespace eval @ {}

proc @ { args } {
    set decorator_func_list [lindex $args 0]
    set args [lrange $args 1 end]
    set index 0

    foreach { key val } $args {
        if { $key eq "@" } {
            lappend decorator_func_list $val
            incr index 2
        } else {
            # done with decorator list
            break
        }
    }

    # change the decorator list order from inside to outside
    set decorator_func_list [lreverse $decorator_func_list]

    lassign [lrange $args $index end] method_kw method_name method_args method_body

    # define the procedure
    $method_kw $method_name $method_args $method_body

    if { [namespace which @::${method_name}] ne "" } {
        rename @::${method_name} ""
    }
    # move the original proc to the decorator namespace
    rename ${method_name} @::${method_name}

    set decorated_method @::${method_name}
    set decorator_level 0
    foreach decorator_func $decorator_func_list {
        set wrapper_method_name "@::${method_name}_${decorator_func}_[incr decorator_level]_wrapper"
        set body [list]

        # call the decorator with the original method
        lappend body "$decorator_func $decorated_method"
        lappend body {{*}$args}
        # define the wrapper
        proc $wrapper_method_name { args } [join $body " "]
        # puts "proc $wrapper_method_name { args } [join $body " "]"

        # retain the last wrapped method as the decorated method
        set decorated_method $wrapper_method_name
    }

    # mask the original proc with our final wrapper
    rename $decorated_method ${method_name}

    return ${method_name}
}