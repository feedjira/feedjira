package org.libll;

import org.jruby.Ruby;

public class Libll
{
    public static void load(final Ruby runtime)
    {
        org.libll.DriverConfig.load(runtime);
        org.libll.Driver.load(runtime);
    }
}
