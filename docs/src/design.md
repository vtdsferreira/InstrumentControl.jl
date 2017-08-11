# Design Summary

## What should good measurement code do?

Anyone who has written code in MATLAB or something comparable (IGOR Pro, in the
author's case) has undoubtedly seen spaghetti code. Often there are many copies
of a measurement routine that differ only slightly, perhaps in the functionality
of what happens inside some for loop, etc.

We would like to have clear, reusable code to avoid redundancy and accidental
errors, both of which consume precious time on the part of the experimenters.
Consider an archetypal measurement scheme wherein we measure a device's response to
various stimuli (perhaps we measure current as a function of applied bias).
We should be able to write just one sweep function to do this.

The idea of *multiple dispatch*, natively supported in Julia, permits writing such
convenient and abstract code. For example, one sweep function could encompass various
sweep methods, where there is a unique method for any particular combination of
stimuli to measure a response. Multiple dispatch would be able to discern which method
to use based on the *types* of stimuli and response passed to the function.
This is just one example where the advantages of multiple dispatch are obvious.
We hope it will more broadly simplify the extension of measurement code while
ensuring continued reliability.

## Summary of Functionality

words
