package org.liboga;

import org.jruby.Ruby;

public class Liboga
{
    /**
     * Bootstraps the JRuby extension.
     */
    public static void load(final Ruby runtime)
    {
        org.liboga.xml.Lexer.load(runtime);
    }
}
