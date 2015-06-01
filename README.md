# puppet-lint check for resource like class declarations

It is a common antipattern to declare all classes like

    class { '::ntp': }
    class { '::apache2': }

etc. This is detrimental because these declarations have
hardly any advantages over just using `include`, but incur
a significant limitation.
