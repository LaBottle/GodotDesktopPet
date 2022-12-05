$path = $args[0]
$shell = new-object -comobject "Shell.Application"
$item = $shell.Namespace(0).ParseName("$path")
$item.InvokeVerb("delete")